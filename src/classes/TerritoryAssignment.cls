/*
** @author : Jeff L (Appirio)
** @date : 01/12/2016
** @description :   class that supports assigning accounts using territory assignments
*/
public with sharing class TerritoryAssignment {
    final static String CLASSNAME = '\n\n**** TerritoryAssignment.METHODNAME()';
    public List<Account> accountList{get;set;}
    public String territoryQuery {get;set;}
    private List<Account> internalAccountList;
    public boolean reQueryAccount {get;set;}
    public boolean runUpdate {get;set;}
    public List<Account> updateList {public get; private set;}
    public Set<Id> assignedTerritoryCodeSet {public get; private set;}
    public List<TerritoryAssignment__c> processedTerritoryAssignments{public get; private set;}
    public Database.DMLOptions dmloptions;
    private Set<TerritoryAssignment__c> processedTASet;
    public List<TerritoryAssignmentCode__c> territoryAssignmentCodeList{get;set;}
    private TerritoryAssignmentCodeTriggerHelper TAC_helper;


    public TerritoryAssignment(List<Account> pListOfAccounts) {
        final string METHODNAME = CLASSNAME.replace('METHODNAME','TerritoryAssignment Constructor');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        accountList = pListOfAccounts;
        reQueryAccount = true;
        runUpdate = true;
        processedTerritoryAssignments = new List<TerritoryAssignment__c>();
        assignedTerritoryCodeSet = new Set<Id>();
        processedTASet = new Set<TerritoryAssignment__c>();

        // instantiate new TAC helper
        TAC_helper = TerritoryAssignmentCodeTriggerHelper.NewTriggerHelper();
    }


    /*
    ** @author : Jeff L (Appirio)
    ** @date : 01/12/2016
    ** @description : runs the territory assignment logic, we query the territory assignment object and using various rules
                      attempt to match up the accounts being processed to the territory assignment codes
    ** @paramaters : account and territory assignment
    ** @returns : nothing
    */
    public void runTerritoryAssignment(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','runTerritoryAssignment');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '****  Inside '));

        if(accountList == null || accountList.size() == 0){
            //nothing to do here
            return;
        }
        try{
            if(reQueryAccount){
                internalAccountList = getAccountList();
            } else {
                internalAccountList = accountList;
            }

            if(territoryQuery == null){
                territoryQuery = buildQueryString();
            }

            if(territoryAssignmentCodeList == null){
                territoryAssignmentCodeList = Database.query(territoryQuery);
            }

            map<Id, List<TerritoryAssignmentCode__c>> terAssignmentList = new map<Id, List<TerritoryAssignmentCode__c>>();
            for(TerritoryAssignmentCode__c tac : territoryAssignmentCodeList){
                if(terAssignmentList.containsKey(tac.TerritoryAssignment__c)){
                    terAssignmentList.get(tac.TerritoryAssignment__c).add(tac);
                } else {
                    List<TerritoryAssignmentCode__c> tacList = new List<TerritoryAssignmentCode__c>();
                    tacList.add(tac);
                    terAssignmentList.put(tac.TerritoryAssignment__c,tacList);
                }
            }

            List<Account> accToUpdate = new List<Account>();
            Boolean changeTeamMember = false;

            if(!internalAccountList.isEmpty()){
                for(Account acc : internalAccountList){
                    Boolean named = false;
                    Boolean zipCodeRange = false;
                    Boolean inCriteria= false;
                    Boolean addToUpdate= false;
                    if(!territoryAssignmentCodeList.isEmpty()){
                        for(TerritoryAssignmentCode__c tac : territoryAssignmentCodeList){
                            if(acc.AccountID__c != null && acc.AccountID__c == tac.NamedAccount__c){
                                if(tac.TerritoryAssignment__r.OwnerId != null){
                                    updateMatchedAccount(acc,tac,accToUpdate);
                                    named = true;
                                    //now lets mark it as processsed for the batch
                                    TerritoryAssignment__c territoryAs = new TerritoryAssignment__c(Id = tac.TerritoryAssignment__c);
                                    territoryAs.Processed__c = true;
                                    processedTASet.add(territoryAs);
                                }
                            }
                        }
                    }

                    /*JHF Appirio I-190489 Do not include address & related evaluation for batch runs*/
                    if(!named && !System.isBatch()){
                        if(!terAssignmentList.keySet().isEmpty()){
                            for(Id ta : terAssignmentList.keySet()){
                                if(terAssignmentList.containsKey(ta)){
                                    for(TerritoryAssignmentCode__c tac : terAssignmentList.get(ta)){
                                        if (inCriteria){break;}
                                        if(tac.AccountCountry__c != null){
                                            if(acc.ShippingCountry != null && (tac.AccountCountry__c.toUppercase() == acc.ShippingCountry.toUppercase())){
                                                inCriteria = true;
                                            } else {
                                                inCriteria = false;
                                                continue;
                                            }
                                        }
                                        if(tac.AccountGroup__c != null){
                                            if(acc.AccountGroup__c != null && (tac.AccountGroup__c.toUppercase() == acc.AccountGroup__c.toUppercase())){
                                                inCriteria = true;
                                            } else {
                                                inCriteria = false;
                                                continue;
                                            }
                                        }
                                        if(tac.SalesChannel__c != null){
                                            if(acc.SalesChannel__c != null && (tac.SalesChannel__c.toUppercase() == acc.SalesChannel__c.toUppercase())){
                                                inCriteria = true;
                                            } else {
                                                inCriteria = false;
                                                continue;
                                            }
                                        }
                                        if(tac.Segment__c != null){
                                            if(acc.Segment__c != null && (tac.Segment__c.toUppercase() == acc.Segment__c.toUppercase())){
                                                inCriteria = true;
                                            } else {
                                                inCriteria = false;
                                                continue;
                                            }
                                        }
                                        //if(UserInfo.getName() != 'Integration MAPP'){ //JHF Appirio I-213506 6/28/16 per Matt Keefe
                                            if(tac.Account_Size__c != null){
                                                if(acc.Account_Size__c != null && (tac.Account_Size__c.toUppercase() == acc.Account_Size__c.toUppercase())){
                                                    inCriteria = true;
                                                } else {
                                                    inCriteria = false;
                                                    continue;
                                                }
                                            }
                                        //}
                                        if(tac.AccountCountry__c != null && tac.Zip_Code_Start_Number__c != null && tac.Zip_Code_End_Number__c != null){
                                            if(acc.ShippingPostalCode != null && acc.ShippingCountry != null){
                                                zipCodeRange = checkCountryZipcode(acc, tac);
                                            }
                                            if(zipCodeRange){
                                                inCriteria = true;
                                            } else {
                                                inCriteria = false;
                                                continue;
                                            }
                                        }

                                        if(inCriteria){
                                            if(tac.TerritoryAssignment__r.OwnerId != null){
                                                updateMatchedAccount(acc,tac,accToUpdate);
                                                break;
                                            }
                                        }
                                    }
                                }
                                //now lets mark it as processsed for the batch
                                TerritoryAssignment__c territoryAs = new TerritoryAssignment__c(Id = ta);
                                territoryAs.Processed__c = true;
                                processedTASet.add(territoryAs);
                            }
                        }
                    }
                }
            }
            if(processedTASet.size() > 0){
                processedTerritoryAssignments.addAll(processedTASet);
            }

            // I-202123 Remove Duplicate accounts from accToupdate List
            //There is a chance that multiple territory assignment rules
            //could match a single account
            map<Id,Account> accmap = new map<Id,Account> ();
            for(Account acc : accToUpdate){
                if(!accmap.containsKey(acc.Id)){
                    accmap.put(acc.Id, acc);
                }
            }

            updateList = accmap.values();

            // End of remove duplicate accounts

            //updateList = accToUpdate;

            if(runUpdate){
                if(updateList.size() > 0){
                    for (Account a : updateList){
                        system.debug('^^^ TerritoryAssignment.runTerritoryAssignment Updating Account ' + a.Id + ', ownerId=' + a.OwnerId);
                    }
                    SetSendToEmailFlag.fromTerritory = true;
                    Database.SaveResult[] srList = Database.update(updateList, false);

                    Integer updateAccCnt = 0;
                    for(Database.SaveResult saveResult : srList){
                        if(!saveResult.isSuccess()){
                            Database.Error saveResultErrorMessage = saveResult.getErrors()[0];
                            system.debug(LoggingLevel.DEBUG, METHODNAME + '\n\nERROR UPDATING ACCOUNTS:'+ updateList[updateAccCnt]+'::'+ saveResultErrorMessage);
                        }
                        else{
                            List<Account> acc = [SELECT Id, OwnerId from Account WHERE Id =: updateList[updateAccCnt].Id];
                            for (Account a : acc){
                                system.debug('^^^ TerritoryAssignment.runTerritoryAssignment Updated account ' + a.Id + ', ownerId=' + a.OwnerId);
                            }
                        }
                        updateAccCnt++;
                    }
                }
            }
        }catch(DMLException e){
           ExceptionLog.add('DMLException', 'AccountTriggerHelper', 'AccountWithoutTerritory', e.getMessage());
           throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to update Account.' ,e);
        }
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 08/1/2014
** @story : 063
** @element : E1867
** @description : check zipcode
** @paramaters : account and territory assignment
** @returns : nothing
*/

    /*Jonathan Freese Appirio 4/24/16 This method is now defunct as it works for US zipcodes only.
      It is replaced by checkCountryZipcode() developed for I-213506, which required TA processing to work for Canada

    private Boolean checkZipcode(Account zAccount, TerritoryAssignmentCode__c zTerritory){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','checkZipcode');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '****  Inside '));

        try{
            Boolean inRange = false;
            String[] zipAccount = new String[]{};
            String[] zipStart = new String[]{};
            String[] zipEnd = new String[]{};

            if(zAccount.ShippingPostalCode != null && zAccount.ShippingPostalCode.trim() != ''){
                zipAccount = zAccount.ShippingPostalCode.split('-');
                if(zipAccount.size() == 1){
                    zipAccount.add('0000');
                }
            } else {
                return inRange = false;
            }
            if(zipAccount.isEmpty() || (!zipAccount.isEmpty() && !String.isBlank(zipAccount[0].trim()) && !zipAccount[0].trim().isNumeric())){
                return inRange = false;
            }
            if(zTerritory.PostingZipCodeStart__c != null){
                zipStart = zTerritory.PostingZipCodeStart__c.split('-');
                if(zipStart.size() == 1){
                    zipStart.add('0000');
                }
            }
            if(zTerritory.PostingZipCodeEnd__c != null){
                zipEnd = zTerritory.PostingZipCodeEnd__c.split('-');
                if(zipEnd.size() == 1){
                    zipEnd.add('0000');
                }
            }
            if(zipStart.isEmpty()){
                zipStart.add('');
            }
            if(!zipStart[0].trim().isNumeric()){
                zipStart[0] = '';
            }
            if(zipEnd.isEmpty()){
                zipEnd.add('');
            }
            if(!zipEnd[0].trim().isNumeric()){
                zipEnd[0] = '';
            }
            if(!zipAccount[0].trim().isNumeric()){
                system.debug('^^^ checkZipcode inRange = false as zip is not numeric: Account=' + zAccount.Id + ', zipAccount[0].trim()=' + zipAccount[0].trim());
                return inRange = false;
            }
            if(zipAccount[0].trim().isNumeric() && !zipAccount[1].trim().isNumeric()){
                zipAccount[1] ='0000';
            }
            if((zTerritory.PostingZipCodeStart__c == null || zipStart[0].trim() == '') && (zTerritory.PostingZipCodeEnd__c == null || zipEnd[0].trim() == '')){
                inRange = false;
            } else if((zTerritory.PostingZipCodeStart__c != null && zipStart[0].trim() != '') && (zTerritory.PostingZipCodeEnd__c == null || zipEnd[0].trim() == '')){
                //Territory Zip End is missing, only inRange if Account zipcode exactly matches territory zip Start
                if(long.valueof(zipAccount[0].trim()) == long.valueof(zipStart[0].trim()) && long.valueof(zipAccount[1].trim()) == long.valueof(zipStart[1].trim())){
                    inRange = true;
                } else {
                    inRange = false;
                }
            } else if((zTerritory.PostingZipCodeStart__c == null || zipStart[0].trim() == '') && (zTerritory.PostingZipCodeEnd__c != null && zipEnd[0].trim() != '')){
                //Territory Zip Start is missing, only inRange if Account zipcode exactly matches territory zip End
                if(long.valueof(zipAccount[0].trim()) == long.valueof(zipEnd[0].trim()) && long.valueof(zipAccount[1].trim()) == long.valueof(zipEnd[1].trim())){
                    inRange = true;
                } else {
                    inRange = false;
                }
            } else if((zTerritory.PostingZipCodeStart__c != null && zipStart[0].trim() != '') && (zTerritory.PostingZipCodeEnd__c != null && zipEnd[0].trim() != '')){
                //Territory zip Start and zip End both populated
                if(long.valueof(zipAccount[0].trim()) >= long.valueof(zipStart[0].trim()) && long.valueof(zipAccount[0].trim()) <= long.valueof(zipEnd[0].trim())){
                    /*If the account zip5 is within the range of the territory zip Start/End, then consider three possibilities:
                       1) inRange if zip5 > zipStart && zip5 < zipEnd
                       2) if zip5 == zipStart, inRange if zip4 is >= zipStart4
                       3) if zip5 == zipEnd,   inRange if zip4 is <= zipEnd4

                       inRange examples where territory zip Start=05490-1357 and zip End=05492-2468
                       zip5  zip4
                       05490-1116 false
                       05490-2543 true
                       05491      true
                       05491-7845 true
                       05492-1116 true
                       05492-4523 false

                       inRange examples where territory zip Start=05491-1357 and zip End=05491-2468 (same 5-digit zipcode)
                       zip5  zip4
                       05491      false
                       05491-1116 false
                       05491-2001 true  (2nd if sets inRange to true, 3rd if confirms it)
                       05491-3579 false (2nd if sets inRange to true, 3rd if changes it to false)

                    if(long.valueof(zipAccount[0].trim()) > long.valueof(zipStart[0].trim()) && long.valueof(zipAccount[0].trim()) < long.valueof(zipEnd[0].trim())){
                        inRange = true;
                    } else {
                        //do nothing, cannot conclude that inRange = false, only that it is true
                    }
                    if(long.valueof(zipAccount[0].trim()) == long.valueof(zipStart[0].trim())){
                        if(long.valueof(zipAccount[1].trim()) >= long.valueof(zipStart[1].trim())){
                            inRange = true;
                        } else {
                            inRange = false;
                        }
                    }
                    if(long.valueof(zipAccount[0].trim()) == long.valueof(zipEnd[0].trim())){
                        if(long.valueof(zipAccount[1].trim()) <= long.valueof(zipEnd[1].trim())){
                            inRange = true;
                        } else {
                            inRange = false;
                        }
                    }
                } else {
                    inRange = false;
                }
            }
            system.debug('^^^ checkZipcode inRange=' + inRange + ', Account=' + zAccount.Id + ', Territory=' + zTerritory.Id +
                ', Territory Start=' + zTerritory.PostingZipCodeStart__c + ' >> ' + zipStart[0].trim() + ' / ' + zipStart[1].trim() +
                ', End=' + zTerritory.PostingZipCodeEnd__c + ' >> ' + zipEnd[0].trim() + ' / ' + zipEnd[1].trim() +
                ', Account Shipping Zip= ' + zAccount.ShippingPostalCode + ' >> ' + zipAccount[0].trim() + ' / ' + zipAccount[1].trim());
            return inRange;
        }catch(DMLException e){
            ExceptionLog.add('DMLException', 'AccountTriggerHelper', 'checkZipcode', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to check zipcode' ,e);
        }
    }*/


/*
** @author : Jonathan Freese (Appirio)
** @date : 04/24/2016
** @description : I-213506 - Check to see if the Account Posting Zipcode is within the Start/End range of a Territory Assignment Code
** @paramaters : Account and Territory Assignment Code
** @returns : boolean
*/
    private Boolean checkCountryZipcode(Account zAccount, TerritoryAssignmentCode__c zTAC){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','checkCountryZipcode');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '****  Inside '));
        Boolean inRange = false;

        try{
            if (zTAC.AccountCountry__c != null && zTAC.Zip_Code_Start_Number__c != null && zTAC.Zip_Code_End_Number__c != null){
                Integer acctZipcode = actZipNumber(zAccount);
                if (acctZipcode > 0 && acctZipcode >= zTAC.Zip_Code_Start_Number__c && acctZipcode <= zTAC.Zip_Code_End_Number__c){
                    inrange = true;
                }
            }
            return inRange;
        }catch(DMLException e){
            ExceptionLog.add('DMLException', 'TerritoryAssignment', 'checkCountryZipcode', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to check zipcode' ,e);
        }
    }

/*
** @author : Jonathan Freese (Appirio)
** @date : 04/24/2016
** @description : I-213506 - Get the numeric equivalent of an account shipping zipcode
** @paramaters : Account
** @returns : integer
*/
    private Integer actZipNumber(Account zAccount){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','actZipNumber');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '****  Inside '));
        Integer zipNum = 0;

        try{
            if (zAccount.ShippingPostalCode != null && zAccount.ShippingCountry != null){
                String result = TAC_helper.isValid_Zipcode(zAccount.ShippingPostalCode, zAccount.ShippingCountry, false, false);
                if (result == 'isValid'){
                    String result2 = TAC_helper.ZipToNumber(zAccount.ShippingPostalCode, zAccount.ShippingCountry);
                    if(result2.isNumeric()){
                        zipNum = Integer.valueOf(result2);
                    }
                }
            }
            return zipNum;
        }catch(DMLException e){
            ExceptionLog.add('DMLException', 'TerritoryAssignment', 'actZipNumber', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to get numeric zipcode' ,e);
        }
    }

/*
** @author : Jeff L (Appirio)
** @date : 01/12/2016
** @description : builds the query string using dynamic soql - this will get invoked if users do not provide their own query string
** @paramaters : nothing
** @returns : string to query territory assignment rules with
*/
    private string buildQueryString(){
        /* Jeff L added the following logic on 12/30 for I-197522
        * Territory Assignment codes now have > 50K records in them, requiring some changes to the logic
        * when we are querying (we used to query everything, but now we need to be more selective)
        *
        * New Logic: Created some number formula fields so that we can do Zip code checks in the SOQL query itself
        * Also need to account for the other logic (named accounts etc) so that needs to be included in the check as well
        * then run through the logic that already exists to match up records
        */
        String tQuery = 'SELECT Id, AccountCountry__c, AccountGroup__c,NamedAccount__c, SalesChannel__c, Segment__c, Account_Size__c, ' ;
        tQuery += 'PostingZipCodeStart__c, PostingZipCodeEnd__c, ';
        tQuery += 'Zip_Code_Start_Number__c, Zip_Code_End_Number__c, ';
        tQuery += 'TerritoryAssignment__c, TerritoryAssignment__r.OwnerId ';
        tQuery += 'FROM TerritoryAssignmentCode__c WHERE';

        //lets iterate over our accounts and put together what is needed for our where clause
        Set<String> namedAccountSet = new Set<String>();
        Set<Integer> zipcodeSet = new Set<Integer>();
        Map<Integer, String> zipToCountry = new Map<Integer, String>();

        for(Account a : internalAccountList){

            //Named accounts are simple, they are just the account ID custom field
            if(a.AccountID__c != null){
                namedAccountSet.add(a.AccountId__c);
            }
            //Next is zip code, we are ok with pulling all the records that contain a single zip code
            if(a.ShippingPostalCode != null){
                /*I-213506 Jonathan Freese Appirio 4/24/16 This approach is defunct, only works for US zipcodes
                //now we need to do some transformation to get the first 6 digits of the zip code
                String testString = a.ShippingPostalCode.left(5); //this gets us the digits we need
                //need to check if it is numeric or not.
                if(testString.isNumeric()){
                    zipcodeSet.add(Integer.valueOf(testString));
                }*/
                Integer actZipNum = actZipNumber(a);
                if (actZipNum > 0){
                    zipcodeSet.add(actZipNum);
                    zipToCountry.put(actZipNum,a.ShippingCountry);
                }
            }
        }

        //Now we can construct the Where clause of our query! It will consist of three parts
        //a query for named accounts OR where it has no zip code OR where the zip code range matches
        boolean needsOr = false;
        boolean hasWhereClause = false;
        if(namedAccountSet.size() > 0){
            tQuery += ' NamedAccount__c in (';
            for(String name : namedAccountSet){
                tQuery += '\'' + name + '\',';
            }
            //get rid of the last comma
            tQuery = tQuery.left(tQuery.length() - 1);
            tQuery += ')';

            //tQuery += ' OR (PostingZipCodeStart__c = null AND PostingZipCodeEnd__c = null)';
            needsOr = true;
            hasWhereClause = true;
        }

        if(zipcodeSet.size() > 0){
            if(needsOr){
                tQuery += ' OR';
            }

            for(Integer zipCode : zipCodeSet){
                tQuery += ' (Zip_Code_Start_Number__c <= ' + zipCode + ' AND Zip_Code_End_Number__c >= ' + zipCode + ') OR ';
            }
            //remove the last OR  and two spaces from our querystring
            tQuery = tQuery.left(tQuery.length() - 4);
            hasWhereClause = true;
        }

        if(hasWhereClause == false){
            return null; //no where clause, so nothing to query.
        }
        system.debug('!!query!! ' + tQuery);

        return tQuery;
    }

/*
** @author : Jeff L (Appirio)
** @date : 01/12/2016
** @description : queries the list of accounts as needed
** @paramaters : nothing
** @returns : will requery the accounts that were given to the constructor of the code
*/
    private List<Account> getAccountList(){
        Set<Id> accnId = new Set<Id>();
        List<Account> returnList;

        for(Account a : accountList){
                if(!a.DoNotReassign__c){
                    accnId.add(a.Id);
                }
            }
        returnList = [SELECT Id, ShippingStreet,Phone,AccountStatus__c,ShippingCity,ShippingState,
                                            CustomerNumber__c,CustomerDate__c,CustomerLapsedDate__c, TerritoryCode__c,
                                            ShippingPostalCode,ShippingCountry, BillingPostalCode,AccountGroup__c,
                                            SalesChannel__c, Segment__c, Account_Size__c, OwnerId, AccountID__c
                                            FROM Account WHERE Id in : accnId];

        return returnList;
    }


/*
** @author : Jeff L (Appirio)
** @date : 01/28/2016
** @description : when an account is matched, this is the logic that needs to be
                  performed on that account
** @paramaters : nothing
** @returns : will requery the accounts that were given to the constructor of the code
*/
    private void updateMatchedAccount(Account pAccount, TerritoryAssignmentCode__c pTerritoryAssignmentCode, List<Account> pAccountList){
        if(pAccount.OwnerId != pTerritoryAssignmentCode.TerritoryAssignment__r.OwnerId){
            system.debug('^^^ TerritoryAssignment.updateMatchedAccount change account owner from: ' + pAccount.OwnerId + ' to: ' + pTerritoryAssignmentCode.TerritoryAssignment__r.OwnerId);
            pAccount.OwnerId = pTerritoryAssignmentCode.TerritoryAssignment__r.OwnerId;
        }

        pAccount.TerritoryCode__c = pTerritoryAssignmentCode.TerritoryAssignment__c;
        /*J Freese Appirio I-213506 5/3/16 For matches based on zipcode range, we would not
        need to write the Sales Channel, Account Group & Segment back to the matched account,
        because by definition they already match.  But per Matt K we want to write them back
        for when the match is based on Named Account, but write back only if populated.

        JHF Appirio I-213506 Commenting this out again because the named account method
        is defunct, as all TA batch processing is now via dataloader, and this class
        is now for new accounts only, and only matches on zipcode range and these
        fields if they are provided.
        if(pTerritoryAssignmentCode.SalesChannel__c != null){
            pAccount.SalesChannel__c = pTerritoryAssignmentCode.SalesChannel__c;
        }
        if(pTerritoryAssignmentCode.AccountGroup__c != null){
            pAccount.AccountGroup__c = pTerritoryAssignmentCode.AccountGroup__c;
        }
        if(pTerritoryAssignmentCode.Segment__c != null){
            pAccount.Segment__c = pTerritoryAssignmentCode.Segment__c;
        }*/

        if(dmloptions != null){
            pAccount.setOptions(dmloptions);
        }

        pAccountList.add(pAccount);
        assignedTerritoryCodeSet.add(pAccount.TerritoryCode__c);
    }
}