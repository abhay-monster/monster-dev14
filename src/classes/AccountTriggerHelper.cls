public without sharing class AccountTriggerHelper {
    final static String CLASSNAME = '\n\n**** AccountTriggerHelper.METHODNAME()';
    public static boolean updateChildFlag = false;
    public Org_Settings__c   settings = Org_Settings__c.getInstance();
    public List<Account> AccountList {get;set;}
    public Map<Id,Account> OldAccountMap {get; set;}
    private List<Account> accountQueriedList;
    public TA_Records_per_Queueable__mdt batchSetting = Utility.getCustomMetadata(); //JFreese Appirio S-435483 4/10/17
    public Boolean TAQueueableDebugMode = boolean.valueOf(batchSetting.get('Debug_mode__c'));
    public Integer cutoff = Integer.valueOf(settings.Debug_Log_Record_Count_Cutoff__c); //JFreese Appirio S-435483 4/11/17
    public Id debugId = settings.Debug_Log_Record_ID__c; //JFreese Appirio S-435483 4/11/17

/*
** @author : Cloud Sherpas Inc.
** @date : 04/17/2014
** @description : static method that instantiates a new instance of the class & sets the user's profile name member variable
** @paramaters : a string - the profile name for the current user
** @returns : a new instance of the AccountTriggerHelper class
*/
    public static AccountTriggerHelper NewTriggerHelper() {
        return  new AccountTriggerHelper();
    }
    public static AccountTriggerHelper NewTriggerHelper(String pUserProfileName){

        //final string METHODNAME = CLASSNAME.replace('METHODNAME','NewTriggerHelper');
        //system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        AccountTriggerHelper newHelper = new AccountTriggerHelper();
        return newHelper;
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 04/09/2014
** @description : this method is the class constructor
** @paramaters : String user profile name
** @returns : nothing
*/

    public AccountTriggerHelper(){

    }

/*
** @author : Appirio Inc
** @date : 10/12/2015
** @description : method is used to reset the triggerhandler, it nulls out the previously queried records
** @paramaters : nothing
** @returns : nothing
*/

    public void ResetQueries(){
        accountQueriedList = null;
        OldAccountMap = null;
    }

    /*
    ** @author : Appirio Inc (Jeff L)
    ** @date : 10/12/2015
    ** @description : this method checks to see if the queried account list is null, if it is it will query to get
    the accounts it's use is to help reduce the overall number of queries.
    ** @paramaters : nothing
    ** @returns : List of accounts
    */
    private List<Account> queryAccountList(){
        if(accountQueriedList == null){
            Set<Id> accountIds = new Set<Id>();
            Set<String> parentDunsNumbers = new Set<String>();
            Set<String> dunsnumbers = new Set<String>();
            Set<Id> parentIds = new Set<Id>();

            for(Account a : AccountList){
                if (AccountList.size() <= cutoff || a.Id == debugId){ //JFreese Appirio S-435483 4/11/17
                    System.debug('----accountList ' + a);
                }
                //needed for UpdateParentThruDandBCompany1, UpdateParentThruDandBCompany
                if(a.ParentCompanyDUNSNumber__c != null && a.ParentCompanyDUNSNumber__c != '' && (a.ParentCompanyDUNSNumber__c != a.DunsNumber)){
                    if (AccountList.size() <= cutoff || a.Id == debugId){ //JFreese Appirio S-435483 4/11/17
                        System.debug('----adding to parentDunsNumbers ' + a.ParentCompanyDUNSNumber__c);
                    }
                    parentDunsNumbers.add(a.ParentCompanyDUNSNumber__c);
                }

                //Needed for populateGlobalHQAccount1 and populateAccountProgram and populateAccountParent, updateAccountFields, updateAccountParent
                if(a.ParentId != null){
                    if (AccountList.size() <= cutoff || a.Id == debugId){ //JFreese Appirio S-435483 4/11/17
                        System.debug('----a.ParentId != null ' + a.ParentId);
                    }
                    accountIds.add(a.ParentId);
                }

                //Needed for getAccountByDUNSNumber
                if(a.DunsNumber != null){
                    if (AccountList.size() <= cutoff || a.Id == debugId){ //JFreese Appirio S-435483 4/11/17
                        System.debug('----a.DunsNumber != null ' + a.DunsNumber);
                    }
                    dunsnumbers.add(a.DunsNumber);
                }

                //Needed for CheckIsGlobalHQ
                if(a.GlobalHQAccount__c != null){
                    if (AccountList.size() <= cutoff || a.Id == debugId){ //JFreese Appirio S-435483 4/11/17
                        System.debug('----a.GlobalHQAccount__c != null ' + a.Id);
                    }
                    accountIds.add(a.Id);
                }

                //OldAccountMap will be populated when it is before or after update
                if(OldAccountMap != null){
                    if (AccountList.size() <= cutoff || a.Id == debugId){ //JFreese Appirio S-435483 4/11/17
                        System.debug('----oldAccountMap ' + oldAccountMap);
                    }
                    //Needed for uncheckIsGlobalHQCheckbox
                    if(OldAccountMap.get(a.Id).GlobalHQAccount__c != null && OldAccountMap.get(a.Id).ParentId == OldAccountMap.get(a.Id).GlobalHQAccount__c){
                        if (AccountList.size() <= cutoff || a.Id == debugId){ //JFreese Appirio S-435483 4/11/17
                            System.debug('----addingGlobalHqAccount ' + OldAccountMap.get(a.Id).GlobalHQAccount__c);
                        }
                        accountIds.add(OldAccountMap.get(a.Id).GlobalHQAccount__c);
                        parentIds.add(OldAccountMap.get(a.Id).GlobalHQAccount__c);
                    }
                    //Needed for updateDescendantsOftheUpdatedAccount
                    if(a.ParentId != OldAccountMap.get(a.Id).ParentId){
                        if (AccountList.size() <= cutoff || a.Id == debugId){ //JFreese Appirio S-435483 4/11/17
                            System.debug('----a.ParentId != OldAccountMap.get(a.Id).ParentId ' + a.ParentId);
                        }
                        accountIds.add(a.ParentId);
                    }
                    //Needed for updateDescendantsOftheUpdatedAccount
                    if(a.GlobalHQAccount__c != OldAccountMap.get(a.Id).GlobalHQAccount__c){
                        if (AccountList.size() <= cutoff || a.Id == debugId){ //JFreese Appirio S-435483 4/11/17
                            System.debug('----a.GlobalHQAccount__c != OldAccountMap.get(a.Id).GlobalHQAccount__c ' + a.Id);
                        }
                        accountIds.add(a.Id);
                    }
                }

            }
            if (AccountList.size() <= cutoff){ //JFreese Appirio S-435483 4/11/17
                System.debug('----parentDunsNumbers ' + parentDunsNumbers);
                System.debug('----accountIds ' + accountIds);
                System.debug('----dunsnumbers ' + dunsnumbers);
                System.debug('----parentIds' + parentIds);
            }
            accountQueriedList = [ SELECT Id, GlobalHQAccount__c, DunsNumber, AccountDunsNumber__c,
            AccountProgram__c, IsGlobalHQ__c, ParentId
            FROM Account WHERE
            (ParentId = null AND DunsNumber IN :parentDunsNumbers) OR
            (Id IN: accountIds) OR
            (DunsNumber IN: dunsnumbers) OR
            (ParentId IN: parentIds)];
        }
        if (AccountList.size() <= cutoff){ //JFreese Appirio S-435483 4/11/17
            System.debug('----accountQueriedList ' + accountQueriedList);
        }
        return accountQueriedList;
    }


/*
** @author : Cloud Sherpas, Inc.
** @date : 07/16/2014
** @story : 0643
** @element : E1807
** @description : Updates Account owner when status is fraud
** @paramaters : Map of account with its Id
** @returns : nothing
*/
    public void UpdateAccountOwner(List<Account> pUpdatedAccounts,  map<ID, Account> pAccountIdToOldAccountMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','UpdateAccountOwner');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Id FraudId = settings.Generic_Fraud_User_Id__c;//[SELECT Id, Name FROM User WHERE Name = 'Generic Fraud' LIMIT 1].Id;
        for(Account acc: pUpdatedAccounts){
            if(acc.AccountStatus__c != pAccountIdToOldAccountMap.get(acc.Id).AccountStatus__c){
                if(acc.AccountStatus__c == 'Fraud'){
                    if(FraudId != null){
                        acc.OwnerId = FraudId;
                    }
                }
            }
        }
    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 07/16/2014
** @story : 0643
** @element : E1807
** @description : Delete all the Account Team Member if the owner is assigned to a User with Fraud profile with GENERIC first/last name
** @paramaters : Map of account with its Id
** @returns : nothing
*/
    public void DeleteAccountTemaMemberOfFraudUsers(List<Account> pUpdatedAccounts,  map<ID, Account> pAccountIdToOldAccountMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','DeleteAccountTemaMemberOfFraudUsers');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Set<Id> AccountOwnerIds = new Set<Id>();
        for(Account acc: pUpdatedAccounts){
            if(acc.OwnerId != pAccountIdToOldAccountMap.get(acc.Id).OwnerId){
                AccountOwnerIds.add(acc.OwnerId);
            }
        }
        Map<Id,User> UserProfileIDMap = new Map<Id,User>();
        if(!AccountOwnerIds.isEmpty()){
            for(User u: [SELECT Id, ProfileId, LastName, FirstName
                            FROM User
                            WHERE Id IN: AccountOwnerIds
                            //AND (Name LIKE '%Fraud%' AND Name LIKE '%Generic%') //Added to prevent none fraud ownered account to delete their team members
                            ]){
                UserProfileIDMap.put(u.Id, u);
            }
        }
        Set<Id> AccountIds = new Set<Id>();
        Id FraudId = settings.Generic_Fraud_User_Id__c;// [SELECT Id, Name FROM Profile WHERE Name = 'Fraud' LIMIT 1].Id;
        for(Account acc: pUpdatedAccounts){
            if(acc.OwnerId != pAccountIdToOldAccountMap.get(acc.Id).OwnerId){
                if((UserProfileIDMap.get(acc.OwnerId).ProfileId == FraudId) && (UserProfileIDMap.get(acc.OwnerId).LastName == 'Generic' || UserProfileIDMap.get(acc.OwnerId).FirstName == 'Generic')){
                    AccountIds.add(acc.Id);
                }
            }
        }
        List<Account_Team_Member__c> AccountTeamMembersToBeDeleted = new List<Account_Team_Member__c>();
        if(!AccountIds.isEmpty()){
            for(Account_Team_Member__c  atm : [Select Id, AccountId__c, UserId__c , AccountId__r.OwnerId
                                                                From Account_Team_Member__c a WHERE
                                                                AccountId__c IN: AccountIds]){
                if(atm.AccountId__r.OwnerId != atm.UserId__c){
                    AccountTeamMembersToBeDeleted.add(atm);
                }
            }
        }
        if(!AccountTeamMembersToBeDeleted.isEmpty()){
            try{
                delete AccountTeamMembersToBeDeleted;
                system.debug('**SUCCESS! ');
            }catch(Exception e){
                throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Failed to delete Account Team Members. Please see system log for details.', e);
            }
        }

    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 04/21/2014
** @story : 0528
** @element : E1301
** @description : Update the Qoute/Proposal's AccountOrganization__c field with the parent's organization
** @paramaters : Map of account with its Id
** @returns : nothing
*/
    /*public void UpdateQuoteProposalOrganization(List<Account> pUpdatedAccounts,  map<ID, Account> pAccountIdToOldAccountMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','UpdateQuoteProposalOrganization');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            Map<Id,Account> AccountorganizationMap = new Map<Id,Account>();
            for(Account acc : pUpdatedAccounts){
                    if(acc.Organization__c != pAccountIdToOldAccountMap.get(acc.Id).Organization__c){ //prevent quote update when there's no change in account's organization
                    AccountorganizationMap.put(acc.Id, acc);
                    }
            }
            List<Apttus_Proposal__Proposal__c> APPToBeUpdated = new List<Apttus_Proposal__Proposal__c>();
            if(AccountorganizationMap.size() > 0){
                for(Apttus_Proposal__Proposal__c app : [Select Id, AccountOrganization__c, Apttus_Proposal__Account__c  FROM Apttus_Proposal__Proposal__c WHERE Apttus_Proposal__Account__c IN : AccountorganizationMap.keySet()]){
                        app.AccountOrganization__c = AccountorganizationMap.get(app.Apttus_Proposal__Account__c).Organization__c;
                        APPToBeUpdated.add(app);
                }
                if(APPToBeUpdated.size() >0){
                    update APPToBeUpdated;
                }
            }
        }catch(Exception bae){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Failed to update Quote/Proposal organization. Please see system log for details.', bae);
        }
    }*/
/*
** @author : Cloud Sherpas, Inc.
** @date : 06/05/2014
** @story : 0908
** @element : E1606
** @description : Checks the following,
                    -- Account must have one Primary Sales Contact
                    -- Primary Sales Contact can be either from the Contact record OR from the new field on the Account Contact Association object
** @paramaters : List of accounts
** @returns : nothing
*/
    public void ValidatePrimarySalesContact(Account[] pNewAccountList){

    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 06/05/2014
** @story : 0908
** @element : E1606
** @description : Update the currency of the account based on the primary sales Rep
** @paramaters : List of accounts
** @returns : nothing
*/   /*
    public void UpdateAccountCurrency(List<Account> pUpdatedAccounts, map<ID, Account> pAccountIdToOldAccountMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','UpdateAccountCurrency');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            Set<Id> userIds = new Set<Id>();
            for(Account acc : pUpdatedAccounts ){
                userIds.add(acc.OwnerId);
            }

            Map<Id, String> fieldMap = new Map<Id, String>();
            for(User usr : [Select DefaultCurrencyIsoCode, Id From User Where Id IN: userIds]){
                fieldMap.put(usr.Id, usr.DefaultCurrencyIsoCode);
            }

            for(Account accList : pUpdatedAccounts){
                if(pAccountIdToOldAccountMap.size() <1){
                    accList.CurrencyIsoCode = fieldMap.get(accList.OwnerId);
                }else{
                    if(accList.ownerId != pAccountIdToOldAccountMap.get(accList.Id).ownerId){
                        accList.CurrencyIsoCode = fieldMap.get(accList.OwnerId);
                    }
                }
            }
        }catch(Exception bae){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Failed to update account\'s currency. Please see system log for details.', bae);
        }
    }
    */
/*
** @author : Cloud Sherpas, Inc.
** @date : 04/18/2014
** @description : get the primary agency contact(contact with Primary Sales Contact field checked) from
                                    the primary related agency(lookup to an agency account)
** @paramaters : String user profile name
** @returns : nothing

    public void PopulatePrimaryAgencyContact(Account[] pNewAccountList){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','PopulatePrimaryAgencyContact');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Map<Id,Account> agencyAccountIdToActualAccount = new Map<Id,Account>();

        for(Account a : pNewAccountList){
            a.PrimaryAgencyContact__c = null; //clean primary agency contact first before applying the new one later
            if(a.PrimaryRelatedAgency__c != null){
                agencyAccountIdToActualAccount.put(a.PrimaryRelatedAgency__c, a);
            }
        }
        if(agencyAccountIdToActualAccount.size() > 0){
            RelatedPartner__c[] partners = [SELECT Partner__c FROM RelatedPartner__c WHERE Id IN :agencyAccountIdToActualAccount.keySet()];

            for(RelatedPartner__c p : partners){
                if(agencyAccountIdToActualAccount.containsKey(p.Id)){
                    Account a = agencyAccountIdToActualAccount.remove(p.Id);
                    agencyAccountIdToActualAccount.put(p.Partner__c, a);
                }
            }
            list<Contact> agencyContactList = [SELECT Id, AccountId, Name FROM Contact
                                                                                WHERE PrimarySalesContact__c = true AND AccountId IN :agencyAccountIdToActualAccount.keySet()];
            for(Contact c : agencyContactList){
                if(agencyAccountIdToActualAccount.containsKey(c.AccountId)){
                    //agencyAccountIdToActualAccount.get(c.AccountId).PrimaryAgencyContact__c = c.Name;
                    //Story1651,E2920
                    //Dated Jan142015
                    agencyAccountIdToActualAccount.get(c.AccountId).Primary_Agency_Contact__c = c.Id;
                }
            }
        }
    }*/
/*
** @author : Appirio Inc
** @date : 10/13/2015
** @description : Jeff L Moved this method to trigger Helper code
** @paramaters : nothing
** @returns : nothing
*/
    public void populateprimaryAgencyContact(List<Account>newAccLst ,Map<Id,Account> oldAccountMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populateprimaryAgencyContact');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Boolean isInsert = true;
        Set<Id> accIdSet = new Set<Id>();
        Set<Id> partnerIdSet = new Set<Id>();
        Map<Id,Id> accToContactIdMap = new Map<Id,Id>();
        Map<Id,Id> accIdToPartnerIdMap = new Map<Id,Id>();
        Map<Id,RelatedPartner__c> acctoPartner = new Map<Id,RelatedPartner__c>();
        List<Account> lstToBeUpdated = new List<Account>();

        if(oldAccountMap != null)
            isInsert = false;

        for(account acc : newAccLst){
            if(isInsert && acc.PrimaryRelatedAgency__c != null){

                accIdSet.add(acc.PrimaryRelatedAgency__c);
            }else if(!isInsert && acc.PrimaryRelatedAgency__c != oldAccountMap.get(acc.id).PrimaryRelatedAgency__c){

                accIdSet.add(acc.PrimaryRelatedAgency__c);
            }
        }

        if(accIdSet.size()>0){
            for(RelatedPartner__c partner : [Select Id,Partner__c,Partner__r.AgencyCommission__c,Account__c From RelatedPartner__c Where Id IN : accIdSet]){

                partnerIdSet.add(partner.Partner__c);
                acctoPartner.put(partner.Account__c , partner);
                accIdToPartnerIdMap.put(partner.Account__c , partner.Partner__c);
            }
        }

        if(partnerIdSet.size()>0){
            for(Contact con : [Select Id,AccountId From Contact Where AccountId IN : partnerIdSet AND PrimarySalesContact__c = true]){

                accToContactIdMap.put(con.AccountId,con.id);
            }
        }

        for(account acc : newAccLst){
        Id partnerId;
        Id conId;
            if(accIdToPartnerIdMap.containsKey(acc.PrimaryRelatedAgency__c))
                partnerId = accIdToPartnerIdMap.get(acc.PrimaryRelatedAgency__c);
            if(acctoPartner.containsKey(acc.PrimaryRelatedAgency__c))
                acc.AgencyCommission__c = acctoPartner.get(acc.PrimaryRelatedAgency__c).Partner__r.AgencyCommission__c;

            if(accToContactIdMap.containsKey(partnerId))
                conId = accToContactIdMap.get(partnerId);

            if(conId !=  null){

                acc.Primary_Agency_Contact__c = conId;
                lstToBeUpdated.add(acc);

            }
        }

        update lstToBeUpdated;

    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 04/23/2014
** @description : Account's BillingCountry is lookuped in the custom Object "CountryLimit__c", if the
                  matching entry found the related credit limit is populated on Account's CreditLimit__c field
** @paramaters : list of Accounts
** @returns : nothing
*/
    public void updateCreditLimtforAccounts(Account[] pNewAccounts, Map<Id, Account> pOldAccountsMap){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateCreditLimtforAccounts');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        final String ORGANIZATION_EUROPE = 'Europe';
    /*
        Map<String, CountryLimit__c> creditDataMap =  new Map<String, CountryLimit__c>();
        for(CountryLimit__c cl : [Select Name, CurrencyISOCode, CreditLimit__c, SalesChannel__c, Country_Code__c From CountryLimit__c]) {
            if(cl.Country_Code__c!=NULL) {
                creditDataMap.put(cl.Country_Code__c, cl);
            }
        }
        Map<String,String> ShippingCountryMap = new Map<String,String>();


        for(Account acc : pNewAccounts){
            if(acc.CreditLimit__c == null && acc.ShippingCountryCode!=NULL){
                String accountType = acc.Account_Type__c;
                if(accountType != null){
                    if(accountType.contains('Staffing')){
                        ShippingCountryMap.put(acc.ShippingCountryCode, 'Staffing-'+ acc.CurrencyIsoCode);
                    }else{
                        ShippingCountryMap.put(acc.ShippingCountryCode, 'Corporate-'+ acc.CurrencyIsoCode);
                    }
                }else{
                    ShippingCountryMap.put(acc.ShippingCountryCode, 'Corporate-'+ acc.CurrencyIsoCode);
                }
            }
        }
        //system.debug('\n\n\n\n ShippingCountryMap: '+ShippingCountryMap+'\n\n\n\n');
        Map<String, CountryLimit__c> CountryLimitMap = new Map<String, CountryLimit__c>();
        if(!ShippingCountryMap.isEmpty()){
            for(CountryLimit__c cl : [SELECT Id, SalesChannel__c, CreditLimit__c, Country_Code__c, CurrencyIsoCode, Name FROM CountryLimit__c WHERE Country_Code__c IN: ShippingCountryMap.keySet() ]){
                String getCountryCode= ShippingCountryMap.get(cl.Country_Code__c);
                String getCurrency ='';
                String getCountryCodeOnly='';
                if(getCountryCode.contains('Staffing')){
                    getCurrency  += getCountryCode.replace('Staffing-','');
                    getCountryCodeOnly +='Staffing';
                }else if(getCountryCode.contains('Corporate')){
                    getCurrency  += getCountryCode.replace('Corporate-','');
                    getCountryCodeOnly +='Corporate';
                }
                system.debug('\n\n\n\n getCurrency: '+getCurrency+'\n\n\n\n');
                system.debug('\n\n\n\n getCountryCodeOnly: '+getCountryCodeOnly+'\n\n\n\n');
                system.debug('\n\n\n\n cl.SalesChannel__c: '+cl.SalesChannel__c+'\n cl.CurrencyIsoCode: '+cl.CurrencyIsoCode+'\n\n\n\n');
                if(cl.SalesChannel__c == getCountryCodeOnly && cl.CurrencyIsoCode == getCurrency){
                    CountryLimitMap.put(cl.Country_Code__c, cl);
                }
            }
            //system.debug('\n\n\n\n CountryLimitMap: '+CountryLimitMap+'\n\n\n\n');
        }
        if(!CountryLimitMap.isEmpty()){
            for(Account acc : pNewAccounts) {
                decimal d = acc.CreditLimit__c;
                //if(acc.Organization__c == ORGANIZATION_EUROPE &&
                if(acc.ShippingCountryCode!=NULL && creditDataMap.containsKey(acc.ShippingCountryCode)) {
                    if(d==NULL || (trigger.isUpdate && acc.ShippingCountryCode != pOldAccountsMap.get(acc.Id).ShippingCountryCode)) {
                        if(CountryLimitMap.containsKey(acc.ShippingCountryCode)){
                            acc.CreditLimit__c = CountryLimitMap.get(acc.ShippingCountryCode).CreditLimit__c;
                        }
                    }
                    if(acc.SalesChannel__c == NULL || (trigger.isUpdate && acc.ShippingCountryCode != pOldAccountsMap.get(acc.Id).ShippingCountryCode)) {
                        if(creditDataMap.containsKey(acc.ShippingCountryCode)){
                            acc.SalesChannel__c = creditDataMap.get(acc.ShippingCountryCode).SalesChannel__c;
                        }
                    }
                }
            }
        }
        */
        Map<String, CountryLimit__c> CountryLimitMap = new Map<String, CountryLimit__c>();
        for(Account acc : pNewAccounts){
            if(acc.ShippingCountryCode != null && (acc.CreditLimit__c == null ||
                    (pOldAccountsMap != null && (acc.ShippingCountryCode != pOldAccountsMap.get(acc.Id).ShippingCountryCode ||
                    acc.Segment__c != pOldAccountsMap.get(acc.Id).Segment__c)))){
                CountryLimitMap.put(acc.ShippingCountryCode, null);
            }
        }

        if(!CountryLimitMap.isEmpty()){
            for(CountryLimit__c cl : [SELECT Id, SalesChannel__c, CreditLimit__c, Country_Code__c, CurrencyIsoCode, Name FROM CountryLimit__c WHERE Country_Code__c IN: CountryLimitMap.keySet()]){
                if(cl.SalesChannel__c != null && cl.CurrencyIsoCode != null){
                    CountryLimitMap.put(cl.Country_Code__c + '~' + cl.CurrencyIsoCode + '~' + cl.SalesChannel__c, cl);
                }
            }
        }

        for(Account acc : pNewAccounts) {
            //acc.CreditLimit__c = null;
            String segment = acc.Segment__c == 'Staffing' ? 'Staffing' : 'Corporate';
            if(acc.ShippingCountryCode != null && (acc.CreditLimit__c == null ||
                    (pOldAccountsMap != null && (acc.ShippingCountryCode != pOldAccountsMap.get(acc.Id).ShippingCountryCode ||
                    acc.Segment__c != pOldAccountsMap.get(acc.Id).Segment__c))) &&
                    CountryLimitMap.containsKey(acc.ShippingCountryCode + '~' + acc.CurrencyIsoCode  + '~' + segment)) {
                acc.CreditLimit__c = CountryLimitMap.get(acc.ShippingCountryCode + '~' + acc.CurrencyIsoCode  + '~' + segment).CreditLimit__c;
            }
        }
    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 04/23/2014
** @story : 0033
** @element : E1354
** @description : Add 1 to the CustomerNumber__c if the status changes from 'Candidate' to 'Customer'
** @paramaters : list of Accounts[]
** @returns : nothing
*/
    //AP commented out this code S-445792
   /* public void updateCustumerNumberforAccounts(Account[] pNewAccounts, Map<Id, Account> pOldAccountsMap){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateCustumerNumberforAccounts');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            Set<Id> AccountIds = new Set<Id>();
            for(Account acc : pNewAccounts){
                system.debug(LoggingLevel.INFO, '1:::'+acc.AccountStatus__c+'   2:::'+pOldAccountsMap.get(acc.Id).AccountStatus__c);
                if(acc.AccountStatus__c == 'Customer' && pOldAccountsMap.get(acc.Id).AccountStatus__c == 'Candidate'){
                    AccountIds.add(acc.Id);
                }
            }
            if(!AccountIds.isEmpty()){
                String Max = '';
                MaximumCustomerNumber__c maxCN = MaximumCustomerNumber__c.getOrgDefaults();
                system.debug('maxCN' + maxCN);
                if (maxCN == null) maxCN = new MaximumCustomerNumber__c();
                decimal lastMax= 0.0;
                for(Account acc : pNewAccounts){
                    system.debug('acc.AccountStatus__c' + acc.AccountStatus__c);
                    system.debug('pOldAccountsMap' + 'pOldAccountsMap.get(acc.Id).AccountStatus__c');
                    if(acc.AccountStatus__c == 'Customer' && pOldAccountsMap.get(acc.Id).AccountStatus__c == 'Candidate'){
                        acc.CustomerNumber__c = String.valueOf(Max + 1);
                        system.debug('Max' + Max);
                        system.debug('acc.CustomerNumber__c' + String.valueOf(Max + 1));
                        //acc.CustomerDate__c = Date.Today();
                        lastMax = decimal.valueOf(acc.CustomerNumber__c);
                        system.debug('lastMax' + lastMax);
                    }
                }
                maxCN.MaxCustNum__c = lastMax;
                system.debug('maxCN.MaxCustNum__c' + maxCN.MaxCustNum__c);
                upsert maxCN;
            }
        }catch(Exception bae){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Failed to update customer number. Please see system log for details.', bae);
        }
    }*/

/*
** @author : Cloud Sherpas, Inc.
** @date : 05/19/2014
** @story : 0265
** @element : E1522
** @description : A method which gets the account based on D-U-N-S Number
** @paramaters : D-U-N-S Number
** @returns : nothing
*/
    public Map<String,Account> getAccountByDUNSNumber(Set<String> AccountDunsNumberSet ){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','getAccountByDUNSNumber');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Map<String, Account> AccountDUNSNumberMap = new Map<String, Account>();
        try{
            if(AccountDunsNumberSet.size() > 0){
                //Jeff L updated to use new query framework
                //for(Account acc: [SELECT Id, AccountDunsNumber__c, DunsNumber FROM Account WHERE DunsNumber IN: AccountDunsNumberSet]){
                    for(Account acc: queryAccountList()){
                        if(AccountDunsNumberSet.contains(acc.DunsNumber)){
                            if( acc.DunsNumber != null){
                                if(!AccountDUNSNumberMap.containsKey(acc.DunsNumber)){
                                    AccountDUNSNumberMap.put(acc.DunsNumber,acc);
                                }
                            }

                        /*if(AccountDUNSNumberMap.containsKey(acc.DunsNumber)){
                            AccountDUNSNumberMap.get(acc.DunsNumber).add(acc);
                        }else{
                            AccountDUNSNumberMap.put(acc.DunsNumber , new List<Account>());
                            AccountDUNSNumberMap.get(acc.DunsNumber).add(acc);
                        }*/
                    }
                }
                if(AccountDUNSNumberMap.size() >0 && !AccountDUNSNumberMap.isEmpty() ){
                    return AccountDUNSNumberMap;
                }
            }
        }catch(Exception bae){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'No selected records. Please see system log for details.', bae);
        }
        return AccountDUNSNumberMap;
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 05/28/2014
** @story : 0715, 0704, 0265
** @element : E1515, E1505, E1522
** @description : Update the Global HQ and Parent Account on the account
** @paramaters : List of accounts
** @returns : nothing
*/
    public void populateGlobalHQAndParentAccount(Account[] pNewAccounts){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populateGlobalHQAndParentAccount');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            Set<String>AccountDunsNumberSet = new Set<String>();
            for(Account acc: pNewAccounts){
                system.debug(LoggingLevel.INFO, 'acc.ParentCompanyDUNSNumber__c:::'+acc);
                if(acc.ParentCompanyDUNSNumber__c != null){
                    AccountDunsNumberSet.add(acc.ParentCompanyDUNSNumber__c);
                }
            }
            Map<Id,List<Account>> parentAccountsMap = new Map<Id,List<Account>>();
            for(Account acc : pNewAccounts){
                if(acc.ParentId != null){
                    if(parentAccountsMap.containsKey(acc.ParentId)){
                        parentAccountsMap.get(acc.ParentId).add(acc);
                    }else{
                        parentAccountsMap.put(acc.ParentId, new list<Account>());
                        parentAccountsMap.get(acc.ParentId).add(acc);
                    }
                }
            }
            for(Account oAccount: pNewAccounts){
                Map<String, Account> AccountDUNSNumberMap = getAccountByDUNSNumber(AccountDunsNumberSet);

                //Checks if parent Account is not null
                if(oAccount.ParentId != null){
                    Account acc = parentAccountsMap.get(oAccount.ParentId)[0];
                    if(acc.GlobalHQAccount__c != null){
                        oAccount.GlobalHQAccount__c = acc.GlobalHQAccount__c;
                      }else if(acc.GlobalHQAccount__c == null){
                        oAccount.GlobalHQAccount__c = acc.Id;
                    }
                    //oAccount.AccountProgram__c = acc.AccountProgram__c;
                    if(oAccount.ParentCompanyDUNSNumber__c != null){
                        if(AccountDUNSNumberMap.size() > 0){
                            oAccount.ParentId = AccountDUNSNumberMap.get(oAccount.ParentCompanyDUNSNumber__c).Id ;
                        }
                    }
                }
            }//End of for loop
        }catch(Exception bae){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Failed to update GlobalHQ, DunsNumber and Parent Account. Please see system log for details.',bae);
        }
    }

    /*
    ** @author : Shyam
    ** @date : 08/17/2016
    ** @description : Updates as per I-199867 [S-313153] - Parent Id is populating as per Global DUNS #
    ** @paramaters :
    ** @returns : nothing
    */
    public void UpdateParentThruDandBCompany(Account[] pNewAccounts,  map<ID, Account> pAccountIdToOldAccountMap ){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','UpdateParentThruDandBCompany');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            map<String, Account> parentAccountDunsNumberToAccount = new map<String, Account>();
            map<String, Account> parentAccountDunsNumberToAccountOld = new map<String, Account>();
            for(Account a : pNewAccounts){
                if (pNewAccounts.size() <= cutoff || a.Id == debugId){ //JFreese Appirio S-435483 4/11/17
                    System.debug('----a.DandbCompanyId ' + a.DandbCompanyId + '----oldAcc ' + pAccountIdToOldAccountMap.get(a.Id).DandbCompanyId);
                    System.debug('----parentId BEFORE ' + a.ParentId);
                }
                //SBerron - S-470489 - added check for old value being null. This was causing the parent to be incorrectly deleted on account clean
                if(a.DandbCompanyId != pAccountIdToOldAccountMap.get(a.Id).DandbCompanyId && pAccountIdToOldAccountMap.get(a.Id).DandbCompanyId != null){
                    a.ParentId = null;
                    if (pNewAccounts.size() <= cutoff || a.Id == debugId){ //JFreese Appirio S-435483 4/11/17
                        System.debug('----parentId AFTER ' + a.ParentId);
                    }
                }
                if(String.isNotBlank(a.GlobalUltimateDUNSNumber__c) && (a.GlobalUltimateDUNSNumber__c != a.DunsNumber)){
                    if (pNewAccounts.size() <= cutoff || a.Id == debugId){ //JFreese Appirio S-435483 4/11/17
                        System.debug('----GlobalUltimateDUNSNumberToAdd ' + a.GlobalUltimateDUNSNumber__c + ' accName ' + a.name);
                    }
                    parentAccountDunsNumberToAccount.put(a.GlobalUltimateDUNSNumber__c, a);
                    parentAccountDunsNumberToAccountOld.put(a.GlobalUltimateDUNSNumber__c, pAccountIdToOldAccountMap.get(a.Id));
                }
            }

            List<Account> parentWithDuns = new List<Account>();
            if(!parentAccountDunsNumberToAccount.keySet().isEmpty()){
                for(Account a : [SELECT Id, DunsNumber FROM Account WHERE ParentId = null AND DunsNumber IN :parentAccountDunsNumberToAccount.keySet()]){
                    if (pNewAccounts.size() <= cutoff || a.Id == debugId){ //JFreese Appirio S-435483 4/11/17
                        System.debug('----query results ' + a);
                    }
                    parentWithDuns.add(a);
                }
            }


            if(parentWithDuns.size() == 0){
                system.debug('Exiting. No account has GlobalUltimateDUNSNumber__c.');
                return; //stops when no account have GlobalUltimateDUNSNumber__c
            }

            //checking of multiple accounts with DunsNumber
            map<String, Integer> dunsNumberToCount = new map<String, Integer>();
            for(Account pa : parentWithDuns){
                if(!dunsNumberToCount.containsKey(pa.DunsNumber)){
                    dunsNumberToCount.put(pa.DunsNumber, 1);
                }else{
                    Integer currentCount = dunsNumberToCount.remove(pa.DunsNumber) + 1;
                    dunsNumberToCount.put(pa.DunsNumber, currentCount);
                }
            }

            for(Account pa : parentWithDuns){
                if (pNewAccounts.size() <= cutoff || pa.Id == debugId){ //JFreese Appirio S-435483 4/11/17
                    System.debug('----Account pa ' + pa);
                }
                Integer count = dunsNumberToCount.containsKey(pa.DunsNumber) ? dunsNumberToCount.get(pa.DunsNumber) : 10;
                if (pNewAccounts.size() <= cutoff || pa.Id == debugId){ //JFreese Appirio S-435483 4/11/17
                    System.debug('----count ' + count);
                }

                if(parentAccountDunsNumberToAccount.get(pa.DunsNumber).DandbCompanyId != parentAccountDunsNumberToAccountOld.get(pa.DunsNumber).DandbCompanyId ){
                    if(parentAccountDunsNumberToAccount.containsKey(pa.DunsNumber) && count == 1){
                        if (pNewAccounts.size() <= cutoff || pa.Id == debugId){ //JFreese Appirio S-435483 4/11/17
                            System.debug('----Account to set ' + parentAccountDunsNumberToAccount.get(pa.DunsNumber));
                            System.debug('----parentId BEFORE SET ' + parentAccountDunsNumberToAccount.get(pa.DunsNumber).ParentId);
                        }
                        parentAccountDunsNumberToAccount.get(pa.DunsNumber).ParentId = pa.Id;
                        if (pNewAccounts.size() <= cutoff || pa.Id == debugId){ //JFreese Appirio S-435483 4/11/17
                            System.debug('----parentId AFTER SET ' + parentAccountDunsNumberToAccount.get(pa.DunsNumber).ParentId);
                        }
                    }
                }
            }

        }catch(Exception bae){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Failed to update parent account. Please see system log for details.',bae);
        }
    }


    /*
    ** @author : Cloud Sherpas, Inc.
    ** @date : 06/05/2014
    ** @description : Updates the Parent account
    ** @paramaters :
    ** @returns : nothing
    */
    /*
    public void UpdateParentThruDandBCompany(Account[] pNewAccounts,  map<ID, Account> pAccountIdToOldAccountMap ){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','UpdateParentThruDandBCompany');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            map<String, Account> parentAccountDunsNumberToAccount = new map<String, Account>();
            map<String, Account> parentAccountDunsNumberToAccountOld = new map<String, Account>();
            for(Account a : pNewAccounts){
                if(a.ParentCompanyDUNSNumber__c != null && a.ParentCompanyDUNSNumber__c != '' && (a.ParentCompanyDUNSNumber__c != a.DunsNumber)){
                    parentAccountDunsNumberToAccount.put(a.ParentCompanyDUNSNumber__c, a);
                    parentAccountDunsNumberToAccountOld.put(a.ParentCompanyDUNSNumber__c, pAccountIdToOldAccountMap.get(a.Id));
                }
            }

            //Account[] parentWithDuns = [SELECT Id, DunsNumber FROM Account WHERE ParentId = null AND DunsNumber IN :parentAccountDunsNumberToAccount.keySet()];
            List<Account> parentWithDuns = new List<Account>();
            for(Account a : queryAccountList()){
                if(a.ParentId == null && parentAccountDunsNumberToAccount.containsKey(a.DunsNumber)){
                    parentWithDuns.add(a);
                }
            }

            if(parentWithDuns.size() == 0){
                system.debug('Exiting. No account has ParentCompanyDUNSNumber__c.');
                return; //stops when no account have ParentCompanyDUNSNumber__c
            }

            //checking of multiple accounts with DunsNumber
            map<String, Integer> dunsNumberToCount = new map<String, Integer>();
            for(Account pa : parentWithDuns){
                if(!dunsNumberToCount.containsKey(pa.DunsNumber)){
                    dunsNumberToCount.put(pa.DunsNumber, 1);
                }else{
                    Integer currentCount = dunsNumberToCount.remove(pa.DunsNumber) + 1;
                    dunsNumberToCount.put(pa.DunsNumber, currentCount);
                }
            }

            for(Account pa : parentWithDuns){
                Integer count = dunsNumberToCount.containsKey(pa.DunsNumber) ? dunsNumberToCount.get(pa.DunsNumber) : 10;
                if(parentAccountDunsNumberToAccount.get(pa.DunsNumber).DandbCompanyId != parentAccountDunsNumberToAccountOld.get(pa.DunsNumber).DandbCompanyId ){
                    if(parentAccountDunsNumberToAccount.containsKey(pa.DunsNumber) && count == 1){
                        parentAccountDunsNumberToAccount.get(pa.DunsNumber).ParentId = pa.Id;
                    }
                }
            }
            /*
            Set<String>AccountDunsNumberSet = new Set<String>();
            for(Account acc : pUpdatedAccounts){
                if(acc.ParentCompanyDUNSNumber__c != ''){
                    AccountDunsNumberSet.add(acc.ParentCompanyDUNSNumber__c);
                }
                //AccountIdSet.add(acc.Id);
            }
            system.debug('^^^^^^^^^^^^^AccountDunsNumberSet: ' + AccountDunsNumberSet);
            Map<String, Account> AccountDUNSNumberMap = getAccountByDUNSNumber(AccountDunsNumberSet);
            system.debug('^^^^^^^^^^^^^AccountDUNSNumberMap: ' + AccountDUNSNumberMap);

            for(Account oAccount : pUpdatedAccounts){
                if(oAccount.parentId == null && (oAccount.DandbCompany != pAccountIdToOldAccountMap.get(oAccount.Id).DandbCompany)){
                    if(AccountDUNSNumberMap.size() > 0){
                        if(AccountDUNSNumberMap.get(oAccount.ParentCompanyDUNSNumber__c)!= null){
                            system.debug('^^^^^^^^^^^^^AccountDUNSNumberMap.get(oAccount.ParentCompanyDUNSNumber__c).Id: '+ AccountDUNSNumberMap.get(oAccount.ParentCompanyDUNSNumber__c).Id);
                            if(AccountDUNSNumberMap.get(oAccount.ParentCompanyDUNSNumber__c).Id != oAccount.Id){
                                if(collectAllDescendantsOfAnAccount(oAccount.Id).size() > 0){
                                    if(!collectAllDescendantsOfAnAccount(oAccount.Id).contains(AccountDUNSNumberMap.get(oAccount.ParentCompanyDUNSNumber__c).Id)){
                                        oAccount.ParentId = AccountDUNSNumberMap.get(oAccount.ParentCompanyDUNSNumber__c).Id ;
                                    }
                                }
                            }
                        }
                    }
                }
            }*/ /*
        }catch(Exception bae){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Failed to update parent account. Please see system log for details.',bae);
        }
    }
    */

/*
** @author : Cloud Sherpas, Inc.
** @date : 05/28/2014
** @story : 0715, 0704, 0265
** @element : E1515, E1505, E1522
** @description : Update the following fields in the account :
                    AccountTeam__c,
                    DateLastTeamed__c,
                    ParentId,
                    GlobalHQAccount__c,
                    AccountProgram__c,
** @paramaters : List of accounts
** @returns : nothing
*/
    public void updateAccountFields(Account[] pUpdatedAccounts, map<ID, Account> pAccountIdToUpdatedAccountMap, map<ID, Account> pAccountIdToOldAccountMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateAccountFields');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            //create a map that gets list of account according to parent account
            Map<Id,List<Account>> parentAccountsMap = new Map<Id,List<Account>>();
            Map<Id,Set<Id>> childAccountsMap = new Map<Id,Set<Id>>();
            set<Id> ParentIdSet = new set<Id>();
            set<Id> AccountIdSet = new set<Id>();
            Set<String>AccountDunsNumberSet = new Set<String>();
            for(Account acc : pUpdatedAccounts){

                if(acc.ParentId != null){
                    ParentIdSet.add(acc.ParentId);
                }
                if(acc.ParentCompanyDUNSNumber__c != null){
                    AccountDunsNumberSet.add(acc.ParentCompanyDUNSNumber__c);
                }
                AccountIdSet.add(acc.Id);
            }
            if(ParentIdSet.size() > 0){
                //Jeff L commented out for new query framework 10/12
                //for(Account acc : [SELECT Id, GlobalHQAccount__c, ParentId, AccountProgram__c FROM Account WHERE Id IN: ParentIdSet]){
                for(Account acc : queryAccountList()){
                    if(ParentIdSet.contains(acc.Id)){
                        if(parentAccountsMap.containsKey(acc.Id)){
                            parentAccountsMap.get(acc.Id).add(acc);
                        }else{
                            parentAccountsMap.put(acc.Id, new List<Account>());
                            parentAccountsMap.get(acc.Id).add(acc);
                        }
                    }
                }
            }

            Map<String, Account> AccountDUNSNumberMap = getAccountByDUNSNumber(AccountDunsNumberSet);
            //get the child of each account
            Map<Id,Account> ChildAccountToUpdateIds = new Map<Id,Account>();
            List<Account> AccountsToBeUpdated = new List<Account>();
            Map<Id, Set<Id>> mapParentsOfAnAccount = new Map<Id, Set<Id>>();

            for(Account oAccount : pUpdatedAccounts){
                /*if(oAccount.ParentId == null && (oAccount.ParentCompanyDUNSNumber__c != null && oAccount.ParentCompanyDUNSNumber__c != 'null' )){
                    if(AccountDUNSNumberMap.size() > 0){
                        if(AccountDUNSNumberMap.get(oAccount.ParentCompanyDUNSNumber__c)!= null){
                            if(AccountDUNSNumberMap.get(oAccount.ParentCompanyDUNSNumber__c).size() ==1){
                                if(AccountDUNSNumberMap.get(oAccount.ParentCompanyDUNSNumber__c)[0].Id != oAccount.Id){
                                    if(collectAllDescendantsOfAnAccount(oAccount.Id).size() > 0){
                                        if(!collectAllDescendantsOfAnAccount(oAccount.Id).contains(AccountDUNSNumberMap.get(oAccount.ParentCompanyDUNSNumber__c)[0].Id)){
                                            oAccount.ParentId = AccountDUNSNumberMap.get(oAccount.ParentCompanyDUNSNumber__c)[0].Id ;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }*/

                //checks if the Account is assigned to a new parent
                if(oAccount.ParentId != pAccountIdToOldAccountMap.get(oAccount.Id).ParentId){
                    if(parentAccountsMap.get(oAccount.ParentId)!= null){
                        Account acc = parentAccountsMap.get(oAccount.ParentId)[0]; //returns the parent account
                        mapParentsOfAnAccount.put(acc.Id, new Set<Id>());
                        if(acc.GlobalHQAccount__c != null){
                            mapParentsOfAnAccount.put(acc.GlobalHQAccount__c, new Set<Id>());
                        }
                        mapParentsOfAnAccount.put(oAccount.ParentId, new Set<Id>());
                    }
                }
            }

            Map<Id, Id> mapMoreLevels = new Map<Id, Id>();
            if(!mapParentsOfAnAccount.keySet().isEmpty()){
                for(Account acc : [SELECT Id, ParentId, Parent.ParentId, Parent.Parent.ParentId, Parent.Parent.Parent.ParentId, Parent.Parent.Parent.Parent.ParentId,
                                Parent.Parent.Parent.Parent.Parent.ParentId FROM Account WHERE Id IN :mapParentsOfAnAccount.KeySet()]){
                    If(acc.ParentId != null){
                        mapParentsOfAnAccount.get(acc.Id).add(acc.ParentId);
                    }
                    if(acc.Parent.ParentId != null){
                        mapParentsOfAnAccount.get(acc.Id).add(acc.Parent.ParentId);
                    }
                    if(acc.Parent.Parent.ParentId != null){
                        mapParentsOfAnAccount.get(acc.Id).add(acc.Parent.Parent.ParentId);
                    }
                    if(acc.Parent.Parent.Parent.ParentId != null){
                        mapParentsOfAnAccount.get(acc.Id).add(acc.Parent.Parent.Parent.ParentId);
                    }
                    if(acc.Parent.Parent.Parent.Parent.ParentId != null){
                        mapParentsOfAnAccount.get(acc.Id).add(acc.Parent.Parent.Parent.Parent.ParentId);
                    }
                    if(acc.Parent.Parent.Parent.Parent.Parent.ParentId != null){
                        mapParentsOfAnAccount.get(acc.Id).add(acc.Parent.Parent.Parent.Parent.Parent.ParentId);
                        mapMoreLevels.put(acc.Parent.Parent.Parent.Parent.Parent.ParentId, acc.Id);
                    }
                }

                for(Account acc : [SELECT Id, ParentId, Parent.ParentId, Parent.Parent.ParentId, Parent.Parent.Parent.ParentId, Parent.Parent.Parent.Parent.ParentId,
                                    Parent.Parent.Parent.Parent.Parent.ParentId FROM Account WHERE Id IN :mapMoreLevels.KeySet()]){
                    if(acc.ParentId != null){
                        mapParentsOfAnAccount.get(mapMoreLevels.get(acc.Id)).add(acc.ParentId);
                    }
                    if(acc.Parent.ParentId != null){
                        mapParentsOfAnAccount.get(mapMoreLevels.get(acc.Id)).add(acc.Parent.ParentId);
                    }
                    if(acc.Parent.Parent.ParentId != null){
                        mapParentsOfAnAccount.get(mapMoreLevels.get(acc.Id)).add(acc.Parent.Parent.ParentId);
                    }
                    if(acc.Parent.Parent.Parent.ParentId != null){
                        mapParentsOfAnAccount.get(mapMoreLevels.get(acc.Id)).add(acc.Parent.Parent.Parent.ParentId);
                    }
                    if(acc.Parent.Parent.Parent.Parent.ParentId != null){
                        mapParentsOfAnAccount.get(mapMoreLevels.get(acc.Id)).add(acc.Parent.Parent.Parent.Parent.ParentId);
                    }
                    if(acc.Parent.Parent.Parent.Parent.Parent.ParentId != null){
                        mapParentsOfAnAccount.get(mapMoreLevels.get(acc.Id)).add(acc.Parent.Parent.Parent.Parent.Parent.ParentId);
                    }
                }
            }

            for(Account oAccount : pUpdatedAccounts){
                //checks if the Account is assigned to a new parent

                if(oAccount.ParentId != pAccountIdToOldAccountMap.get(oAccount.Id).ParentId){
                    if(parentAccountsMap.get(oAccount.ParentId)!= null){
                        Account acc = parentAccountsMap.get(oAccount.ParentId)[0]; //returns the parent account

                        if(!mapParentsOfAnAccount.get(acc.Id).contains(oAccount.Id)){
                            if(acc.GlobalHQAccount__c != null){
                                if(!mapParentsOfAnAccount.get(acc.GlobalHQAccount__c).contains(oAccount.Id)){
                                    oAccount.GlobalHQAccount__c = acc.GlobalHQAccount__c;
                                }
                            }else{
                                if(!mapParentsOfAnAccount.get(oAccount.ParentId).contains(oAccount.Id)){
                                    oAccount.GlobalHQAccount__c = acc.Id;
                                }
                            }
                        }else{
                            oAccount.addError('You can\'t assign a child account as a parent.');
                        }
                        oAccount.AccountProgram__c = acc.AccountProgram__c;
                    }
                }
                /*
                if(oAccount.ParentId != pAccountIdToOldAccountMap.get(oAccount.Id).ParentId){
                                if(parentAccountsMap.get(oAccount.ParentId)!= null){
                                    Account acc = parentAccountsMap.get(oAccount.ParentId)[0]; //returns the parent account
                                    if(!collectAllDescendantsOfAnAccount(oAccount.Id).contains(acc.Id)){
                                        if(acc.GlobalHQAccount__c != null){
                                            if(!collectAllDescendantsOfAnAccount(oAccount.Id).contains(acc.GlobalHQAccount__c)){
                                                oAccount.GlobalHQAccount__c = acc.GlobalHQAccount__c;
                                            }
                                        }else{
                                            if(!collectAllDescendantsOfAnAccount(oAccount.Id).contains(oAccount.ParentId)){
                                                oAccount.GlobalHQAccount__c = acc.Id;
                                            }
                                        }
                                    }else{
                                        oAccount.addError('You can\'t assign a child account as a parent.');
                                    }
                                    oAccount.AccountProgram__c = acc.AccountProgram__c;
                                }
                            }
                */
            }

            if(AccountsToBeUpdated.size() >0){
                update AccountsToBeUpdated;
            }
        }catch(Exception bae){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Failed to update Account. Please see system log for details.',bae);
        }
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 06/05/2014
** @description : Get the list of all descendands of an account
** @paramaters : Account Id
** @returns : nothing
*/
    /* JARVIND - T-566563 -Commented out as this method was not being called. The two places where this was being called are commented out as well.
    public List<Account> getListofDescendantsOfAnAccount(map<Id, Account> parentAccounts){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','getListofDescendantsOfAnAccount');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        system.debug('^^^parentAccounts.keySet()='+parentAccounts.keySet());

        List<Account> AccountList = new List<Account>();
        List<Account> accList = [SELECT Id, GlobalHQAccount__c, ParentId, Parent.GlobalHQAccount__c FROM Account WHERE ParentId IN : parentAccounts.keySet()];
            for (Account child: accList){
                if(parentAccounts.containsKey(child.ParentId)){
                    if(parentAccounts.get(child.ParentId).GlobalHQAccount__c != null && parentAccounts.get(child.ParentId).ParentId != null){
                        child.GlobalHQAccount__c = parentAccounts.get(child.ParentId).GlobalHQAccount__c;
                    }else if(parentAccounts.get(child.ParentId).GlobalHQAccount__c == null && parentAccounts.get(child.ParentId).ParentId == null){
                        child.GlobalHQAccount__c = parentAccounts.get(child.ParentId).Id;
                    }else if(parentAccounts.get(child.ParentId).GlobalHQAccount__c == null && parentAccounts.get(child.ParentId).ParentId != null){
                        child.GlobalHQAccount__c = parentAccounts.get(child.ParentId).Id;
                    }else if(parentAccounts.get(child.ParentId).ParentId == null){
                        child.GlobalHQAccount__c = parentAccounts.get(child.ParentId).Id;
                    }
                    AccountList.add(child);
                }
            }
        system.debug('^^^Summary of Descendants:');
        for (Account a : AccountList){
            system.debug('ID='+a.Id+', GlobalHQAccount__c='+a.GlobalHQAccount__c+', ParentId='+a.ParentId+', Parent.GlobalHQAccount__c='+a.Parent.GlobalHQAccount__c);
        }

        return AccountList;
    }*/

/*
** @author : Cloud Sherpas, Inc.
** @date : 06/05/2014
** @description : Get all the descendands' Id of an account
** @paramaters : Account Id
** @returns : nothing
*/
    /*
    public Set<Id> collectAllDescendantsOfAnAccount(Id i){
        Set<Id> idSet = new Set<Id>();
        List<Account> accList = [SELECT Id FROM Account WHERE ParentId =: i];
        while (!accList.isEmpty()){
            for (Account child: accList){
                idSet.add(child.Id);
            }
            accList = [SELECT Id FROM Account WHERE ParentId IN: accList];
        }
        return idSet;
    }
*/

/*
** @author : Cloud Sherpas, Inc.
** @date : 06/05/2014
** @description : Updates the Account Team checkbox, Date Last Teamed and Date Last UnTeamed.
** @paramaters : list and map of accounts to be updated
** @returns : nothing
*/
    public void updateAccountTeamCheckbox(Account[] pUpdatedAccounts, map<ID, Account> pAccountIdToOldAccountMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateAccountTeamCheckbox');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        for(Account o : pUpdatedAccounts){
            if(o.DateLastTeamed__c != pAccountIdToOldAccountMap.get(o.Id).DateLastTeamed__c){
                o.AccountTeam__c = true;
            }else if(o.DateLastUnTeamed__c != pAccountIdToOldAccountMap.get(o.Id).DateLastUnTeamed__c && o.DateLastUnTeamed__c != null){
                o.AccountTeam__c = false;
            }
        }
    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 06/05/2014
** @description : Updates the Account Team and Date Last UnTeamed.
** @paramaters : list and map of accounts to be updated
** @returns : nothing
*/
    public void updateAccountTeamAndDateLastUnTeamed(Account[] pUpdatedAccounts, map<ID, Account> pAccountIdToUpdatedAccountMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateAccountTeamAndDateLastUnTeamed');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            list<AccountTeamMember> accountTeamMemberList = [SELECT Id, AccountId FROM AccountTeamMember WHERE AccountId IN : pAccountIdToUpdatedAccountMap.keySet()];
            map<Id,list<AccountTeamMember>> accountIdToAccountTeamMemberListMap = new map<Id,list<AccountTeamMember>>();

            for(AccountTeamMember atm : accountTeamMemberList){
                if(accountIdToAccountTeamMemberListMap.containsKey(atm.AccountId)){
                    accountIdToAccountTeamMemberListMap.get(atm.AccountId).add(atm);
                }else{
                    accountIdToAccountTeamMemberListMap.put(atm.AccountId, new list<AccountTeamMember>());
                    accountIdToAccountTeamMemberListMap.get(atm.AccountId).add(atm);
                }
            }

            for(Account oAccount : pUpdatedAccounts){
                if(!String.IsBlank(oAccount.PrimaryServiceRep__c) && oAccount.AccountTeam__c == false){
                    //oAccount.AccountTeam__c = true;
                    //oAccount.DateLastTeamed__c = system.now();
                }
                if(String.IsBlank(oAccount.PrimaryServiceRep__c) && oAccount.AccountTeam__c == true
                    && accountIdToAccountTeamMemberListMap.containsKey(oAccount.Id)
                ){
                    if(accountIdToAccountTeamMemberListMap.get(oAccount.Id).Size() <= 2){
                        oAccount.AccountTeam__c = false;
                        //oAccount.DateLastUnTeamed__c = system.now();
                    }
                }
            }
        }catch(Exception e){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Failed to update Account Team and Date Last Unteamed. Please see system log for details.' + e.getMessage() + e.getLineNumber(),e);
        }
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 06/05/2014
** @description : Update of all descendands of an account
** @paramaters : Account Id
** @returns : nothing
*/
/*
    public void updateDescendantsOftheUpdatedAccount(Account[] pUpdatedAccounts, map<ID, Account> pAccountIdToOldAccountMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateDescendantsOftheUpdatedAccount');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
            List<Account> AccountsToBeUpdated = new List<Account>();
            map<Id, Account> parentAccounts = new map<Id, Account>();
            set<Id> superParentIdSet = new set<Id>();
            for(Account oAccount : pUpdatedAccounts){
                if(oAccount.ParentId != pAccountIdToOldAccountMap.get(oAccount.Id).ParentId){
                    System.debug('superParent put 1 ' + oAccount.ParentId);
                    superParentIdSet.add(oAccount.ParentId);
                }
                if(oAccount.GlobalHQAccount__c != pAccountIdToOldAccountMap.get(oAccount.Id).GlobalHQAccount__c){
                    System.debug('superParent put 2 ' + oAccount.Id);
                    superParentIdSet.add(oAccount.Id);
                }
            }
            System.debug('----superParentIdSet ' + superParentIdSet);

            // Jeff L commented out for new query framework 10/12
            //map<Id, Account> superParent = new map<Id, Account>([SELECT GlobalHQAccount__c, Id FROM Account WHERE Id IN :superParentIdSet]);
            map<Id, Account> superParent = new Map<Id, Account>();
            for(Account a : queryAccountList()){
                if(superParentIdSet.contains(a.Id)){
                    superParent.put(a.Id, a);
                }
            }
            System.debug('----superParent ' + superParent);

            for(Account oAccount : pUpdatedAccounts){
                System.debug('----oAccount ' + oAccount);
                if(superParent.containsKey(oAccount.ParentId)){
                    System.debug('----if Contains ' + superParent.get(oAccount.ParentId).GlobalHQAccount__c == null ? superParent.get(oAccount.ParentId).Id : superParent.get(oAccount.ParentId).GlobalHQAccount__c);
                    oAccount.GlobalHQAccount__c = superParent.get(oAccount.ParentId).GlobalHQAccount__c == null ? superParent.get(oAccount.ParentId).Id : superParent.get(oAccount.ParentId).GlobalHQAccount__c;
                }
                if(oAccount.GlobalHQAccount__c != pAccountIdToOldAccountMap.get(oAccount.Id).GlobalHQAccount__c){
                    if(oAccount.GlobalHQAccount__c == null){
                        System.debug('----GlobalHQAccount__c == null ');
                        parentAccounts.put(oAccount.Id, oAccount);
                    }else{
                        System.debug('----NOT GlobalHQAccount__c == null');
                        parentAccounts.put(oAccount.Id, oAccount);
                    }
                }
                System.debug('----FIRST oAccount.ParentId != pAccountIdToOldAccountMap.get(oAccount.Id).ParentId');
                System.debug('----oAccount.ParentId ' + oAccount.ParentId);
                System.debug('----pAccountIdToOldAccountMap.get(oAccount.Id).ParentId ' + pAccountIdToOldAccountMap.get(oAccount.Id).ParentId);
                if(oAccount.ParentId != pAccountIdToOldAccountMap.get(oAccount.Id).ParentId){
                    parentAccounts.put(oAccount.Id, oAccount);
                }
            }
            System.debug('----parentAccounts ' + parentAccounts);

            AccountsToBeUpdated.addAll(getListofDescendantsOfAnAccount(parentAccounts));
            String IDtoParent = '';
            for (Account acc : AccountsToBeUpdated) {
                String accToAdd = acc.Id + '=' + acc.GlobalHQAccount__c + '\n';
                IDtoParent += accToAdd;
            }
            System.debug('----IDtoParent ' + IDtoParent);
            System.debug('----AccountsToBeUpdated ' + AccountsToBeUpdated);
            if(AccountsToBeUpdated.size() > 0){
                performDescendantsUpdate(IDtoParent);
            }
    }

    //Sberron - S-445847 - 12/15/16
    //Moved update into future method to avoid recursive update error in AccountTrigger
    @future
    public static void performDescendantsUpdate(String AccountGlobalHQAccount) {
        final string METHODNAME = CLASSNAME.replace('METHODNAME','performDescendantsUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        try {
            Map<Id,Id> accToGlobalMap = new Map<Id, Id>();
            List<Account> accountsToUpdate = new List<Account>();

            String[] accs = AccountGlobalHQAccount.split('\n');
            for (String acc : accs) {
                String[] splitAccs = acc.split('=');
                String accToUpdate = splitAccs[0];
                String globalHq = splitAccs[1];
                accToGlobalMap.put(accToUpdate, globalHq);
            }

            for (Account acc : [SELECT Id, Name, GlobalHQAccount__c FROM Account WHERE Id IN :accToGlobalMap.keySet()]) {
                acc.GlobalHQAccount__c = accToGlobalMap.get(acc.Id);
                accountsToUpdate.add(acc);
            }
            if (accountsToUpdate.size() > 0) {
                update accountsToUpdate;
            }
        }
        catch(Exception e) {
            ExceptionLog.add(e.getTypeName(), CLASSNAME, METHODNAME, e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Failed to update. Please see system log for details.',e);
        }
    }
    */
    public void updateDescendantsOftheUpdatedAccount(Account[] pUpdatedAccounts, map<ID, Account> pAccountIdToOldAccountMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateDescendantsOftheUpdatedAccount');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        system.debug('^^^pUpdatedAccounts.size()='+pUpdatedAccounts.size()+', BatchUpdateAccountGlobalHQ.RunningBatchUpdateAccountGlobalHQ='+BatchUpdateAccountGlobalHQ.RunningBatchUpdateAccountGlobalHQ);
        if (BatchUpdateAccountGlobalHQ.RunningBatchUpdateAccountGlobalHQ == true){
            system.debug('Running BatchUpdateAccountGlobalHQ, so bypassing this method');
            return;
        }
        try{
            List<Account> AccountsToBeUpdated = new List<Account>();
            Map<Id, Account> parentAccounts = new Map<Id, Account>();
            Map<Id,Id> newGlobalHQ = new Map<Id,Id>(); //J Freese Appirio 3/18/17 S-470365 The initial map of new GlobalHQ values for the parents
            Set<Id> superParentIdSet = new Set<Id>();
            for(Account oAccount : pUpdatedAccounts){
                if(oAccount.ParentId != pAccountIdToOldAccountMap.get(oAccount.Id).ParentId){
                    superParentIdSet.add(oAccount.ParentId);
                }
                if(oAccount.GlobalHQAccount__c != pAccountIdToOldAccountMap.get(oAccount.Id).GlobalHQAccount__c){
                    superParentIdSet.add(oAccount.Id);
                }
            }
            system.debug('^^^superParentIdSet.size()='+superParentIdSet.size()+', superParentIdSet='+superParentIdSet);

            // Jeff L commented out for new query framework 10/12
            //map<Id, Account> superParent = new map<Id, Account>([SELECT GlobalHQAccount__c, Id FROM Account WHERE Id IN :superParentIdSet]);
            map<Id, Account> superParent = new Map<Id, Account>();
            for(Account a : queryAccountList()){
                if(superParentIdSet.contains(a.Id)){
                    superParent.put(a.Id, a);
                }
            }

            for(Account oAccount : pUpdatedAccounts){
                if(superParent.containsKey(oAccount.ParentId)){
                    oAccount.GlobalHQAccount__c = superParent.get(oAccount.ParentId).GlobalHQAccount__c == null ? superParent.get(oAccount.ParentId).Id : superParent.get(oAccount.ParentId).GlobalHQAccount__c;
                }
                if(oAccount.GlobalHQAccount__c != pAccountIdToOldAccountMap.get(oAccount.Id).GlobalHQAccount__c){
                    if(oAccount.GlobalHQAccount__c == null){
                        parentAccounts.put(oAccount.Id, oAccount);
                    }else{
                        parentAccounts.put(oAccount.Id, oAccount);
                    }
                    newGlobalHQ.put(oAccount.Id,oAccount.GlobalHQAccount__c);
                }
                if(oAccount.ParentId != pAccountIdToOldAccountMap.get(oAccount.Id).ParentId){
                    parentAccounts.put(oAccount.Id, oAccount);
                    newGlobalHQ.put(oAccount.Id,oAccount.GlobalHQAccount__c);
                }
            }
            if (pUpdatedAccounts.size() <= cutoff){ //JFreese Appirio S-435483 4/11/17
                System.debug('----parentAccounts ' + parentAccounts);
            }

            /*Sberron - 2/06/17 - S-445847S. POTENTIAL fix for story.
            AccountsToBeUpdated.addAll(getListofDescendantsOfAnAccount(parentAccounts));
            for(Integer i = 0; i<AccountsToBeUpdated.size(); i++) {
                if (pAccountIdToOldAccountMap.get(AccountsToBeUpdated[i].Id) != null) {
                    AccountsToBeUpdated.remove(i);
                }
            }

            if(AccountsToBeUpdated.size() > 0){
                update AccountsToBeUpdated;
            }*/

            //J Freese Appirio 3/18/17 S-470365 Update GlobalHQ for all child accounts in the heirarchy via batch class
            if (parentAccounts.size() > 0){
                BatchUpdateAccountGlobalHQ batch = new BatchUpdateAccountGlobalHQ(parentAccounts,newGlobalHQ);
                ID jobID = Database.executeBatch(batch, 200);
                system.debug('BatchUpdateAccountGlobalHQ Job ID: '+jobID);
            }

        }catch(Exception e){
            ExceptionLog.add(e.getTypeName(), CLASSNAME, METHODNAME, e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Failed to update. Please see system log for details.',e);
        }
    }

    /*public void UpdateAccountCurrencyBasedOnPostingCountry(map<ID, Account> pAccountIdToNewAccountMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','UpdateAccountCurrencyBasedOnPostingCountry');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Account[] accountList = trigger.isInsert ? [SELECT IsPersonAccount, CreatedDate, LastModifiedDate, AccountSource, ShippingCountry, CurrencyIsoCode, Name FROM Account WHERE Id IN :pAccountIdToNewAccountMap.keySet()] : pAccountIdToNewAccountMap.values();

        CurrencyType[] activeCurrencyList = [SELECT ISOCode FROM CurrencyType WHERE IsActive = true];
        map<String, String> ISOCodeMap = new map<String, String>();
        for(CurrencyType ct : activeCurrencyList){
            ISOCodeMap.put(ct.ISOCode,ct.ISOCode);
        }

        Account[] accountToUpdate = new Account[]{};
        for(Account a : accountList){
            Boolean isDataDotComFirstUpdate = a.AccountSource == 'Data.com' && a.CreatedDate == a.LastModifiedDate && trigger.isUpdate;
            system.debug('\n\nFirst update: ' + isDataDotComFirstUpdate);
            if(!a.IsPersonAccount && a.ShippingCountry != null && (trigger.isInsert || isDataDotComFirstUpdate)){
                String shippingCountry = a.ShippingCountry.left(38);
                system.debug('\n\nShippingCountry for currency update: ' + shippingCountry + '\n\n');
                String ISOCode = Utility.GetCurrencyByCountry(shippingCountry);
                if(ISOCode != 'false' && ISOCodeMap.containsKey(ISOCode)){
                    a.CurrencyIsoCode = ISOCodeMap.get(ISOCode);
                    accountToUpdate.add(a);
                }
            }
        }
        if(trigger.isInsert){
            update accountToUpdate;
        }
    }*/
/*
** @author : Cloud Sherpas, Inc.
** @date : 07/16/2014
** @story : 0946
** @element : E1851
** @description : Set IsDomesticHQ__c and IsGlobalHQ__c of parent Account if it is being set as Domestic HQ or Global HQ of the updated or created account
** @paramaters : List of updated accounts, Map of account with its Id
** @returns : nothing
*/
    public void MarkDomesticAndGlobalAccount(List<Account> pUpdatedAccounts,  map<ID, Account> pAccountIdToOldAccountMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','MarkDomesticAndGlobalAccount');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        //if(Utility.IsNotValidTestRecord('Id', pUpdatedAccounts, new set<String>{'0011100000T8Ucc', '0011100000XMAQi'})){
            //return;
        //}

        try{
            set<Id> GlobalHQAccountIdSet = new set<Id>();
            set<Id> DomesticHQAccountIdSet = new set<Id>();

            set<Id> RemoveGlobalHQAccountIdSet = new set<Id>();
            set<Id> RemoveDomesticHQAccountIdSet = new set<Id>();

            set<Id> DeletedHQAccountIdSet = new set<Id>();

            for(Account a : pUpdatedAccounts){
                system.debug('\n\nCHECK ME: ' + a.Name + '\n\n');
                if(a.DomesticHQAccount__c != null &&
                (trigger.isUpdate && pAccountIdToOldAccountMap.get(a.Id).DomesticHQAccount__c != a.DomesticHQAccount__c)){
                    DomesticHQAccountIdSet.add(a.DomesticHQAccount__c);
                }
                if(a.GlobalHQAccount__c != null &&
                (trigger.isUpdate && pAccountIdToOldAccountMap.get(a.Id).GlobalHQAccount__c != a.GlobalHQAccount__c)){
                    GlobalHQAccountIdSet.add(a.GlobalHQAccount__c);
                }

                if(pAccountIdToOldAccountMap != null){
                    if(a.DomesticHQAccount__c == null && pAccountIdToOldAccountMap.get(a.Id).DomesticHQAccount__c != null){
                        RemoveDomesticHQAccountIdSet.add(pAccountIdToOldAccountMap.get(a.Id).DomesticHQAccount__c);
                        DeletedHQAccountIdSet.add(a.Id);
                    }
                    if(a.GlobalHQAccount__c == null && pAccountIdToOldAccountMap.get(a.Id).GlobalHQAccount__c != null){
                        RemoveGlobalHQAccountIdSet.add(pAccountIdToOldAccountMap.get(a.Id).GlobalHQAccount__c);
                        DeletedHQAccountIdSet.add(a.Id);
                    }
                }
            }

            set<Id> allAccountIdSet = new set<id>();
            allAccountIdSet.addAll(GlobalHQAccountIdSet);
            allAccountIdSet.addAll(DomesticHQAccountIdSet);
            allAccountIdSet.addAll(RemoveGlobalHQAccountIdSet);
            allAccountIdSet.addAll(RemoveDomesticHQAccountIdSet);

            if(allAccountIdSet.size() == 0){
                system.debug('\n\nNo Domestic or Global Account to update.\n\n');
                return;
            }

            Account[] HQAccountList = [SELECT Id, Name, IsDomesticHQ__c, IsGlobalHQ__c, DomesticHQAccount__c, GlobalHQAccount__c, GlobalHQAccountID__c, DomesticHQAccountID__c,
                                                    (SELECT Id FROM DomesticHQAccounts__r WHERE Id NOT IN :DeletedHQAccountIdSet),
                                                    (SELECT Id FROM GlobalHQAccounts__r WHERE Id NOT IN :DeletedHQAccountIdSet)
                                                    FROM Account WHERE Id IN :allAccountIdSet];

            Account[] AccountToUpdate = new Account[]{};
            for(Account hqa : HQAccountList){
                Boolean AddAccount = false;
                if(GlobalHQAccountIdSet.contains(hqa.Id) && hqa.GlobalHQAccount__c == null){
                    system.debug('\n\nSet is Global HQ Account: ' + hqa.Name + '\n\n');
                    hqa.IsGlobalHQ__c = true;
                    AddAccount = true;
                }
                if(DomesticHQAccountIdSet.contains(hqa.Id)){
                    system.debug('\n\nSet is Domestic HQ Account: ' + hqa.Name + '\n\n');
                    hqa.IsDomesticHQ__c = true;
                    AddAccount = true;
                }
                if(RemoveGlobalHQAccountIdSet.contains(hqa.Id) && hqa.GlobalHQAccounts__r.size() == 0){
                    system.debug('\n\nRemove is Global HQ Account: ' + hqa.Name + '\n\n');
                    hqa.IsGlobalHQ__c = false;
                    AddAccount = true;
                }
                if(RemoveDomesticHQAccountIdSet.contains(hqa.Id) && hqa.DomesticHQAccounts__r.size() == 0){
                    system.debug('\n\nRemove is Domestic HQ Account: ' + hqa.Name + '\n\n');
                    hqa.IsDomesticHQ__c = false;
                    AddAccount = true;
                }

                if(AddAccount){
                    AccountToUpdate.add(hqa);
                }
            }

            AccountTriggerHandler.ExecuteTriggers = false;
            update AccountToUpdate;
            AccountTriggerHandler.ExecuteTriggers = true;
        }catch(Exception e){
            system.debug('\n\n' + e + '\n\n');
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Problem updating IsDomesticHQ and IsGlobalHQ.' + e, e);
        }
    }


/************************************************************************************************************************
  I-159680 Jfreese Appirio 1/18/16
  The batch class AccountLevelUpdate sets Account.Level__c to indicate that the account is a
  Parent/Child/StandAlone account with or without orders (Purchasing_Account_Flag__c > 0 or == 0, respectively).

  The original Sherpa version processed all accounts, and first time it was run on production,
  the 23,013 batches of 200 accounts took nearly 30 hours to execute.

  David M requested that the code be modified to only process new or recently modified accounts, so a new field
  (LevelNeedsUpdating__c) and workflow rule (Level Needs Updating) were created on account.  This flags new accounts
  or accounts whose parentID or Purchasing_Account_Flag__c have changed in an update, setting LevelNeedsUpdating__c
  to true so it will be selected by AccountLevelUpdate.  That flagged all child accounts and (parent) accounts
  whose purchase status changes.

  It did not flag newly designated parent accounts, so initially AccountLevelUpdate was modified to process the parents of
  all children in each batch, whether or not the parent was in the batch.  But this approach had two problems:
  1) it would not catch accounts which had been a parent of one child and were de-parented by the child account
  2) if the batch consisted solely of 200 children then a total of 400 accounts would need updating, possible DML problem

  Therefore, this method was created to flick on the LevelNeedsUpdating__c for all new and former parent accounts when
  a child account is created or modified to set or change ParentId.
  ***********************************************************************************************************************/
    public void SetParentLevelNeedsUpdating(List<Account> pUpdatedAccounts,  map<ID, Account> pAccountIdToOldAccountMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','setParentLevelNeedsUpdating');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        try{
            set<Id> ParentIDset = new set<Id>();

            for(Account a : pUpdatedAccounts){
                if(trigger.isInsert && a.ParentId != null){
                    ParentIDset.add(a.ParentId);
                }
                else if(trigger.isUpdate && pAccountIdToOldAccountMap.get(a.Id).ParentId != a.ParentId){
                    if (a.ParentId != null){
                        ParentIDset.add(a.ParentId);
                    }
                    if(pAccountIdToOldAccountMap.get(a.Id).ParentId != null){
                        ParentIDset.add(pAccountIdToOldAccountMap.get(a.Id).ParentId);
                    }
                }
            }

            if(ParentIDset.size() == 0){
                system.debug('\n\nNo Parent Account to update.\n\n');
                return;
            }
            //Sberron - S-445869 - 12/20/16
            //Future method was being called in batch, causing
            if (System.isBatch()) {
                setLevelNeedsUpdating1(ParentIDset);
            }
            else {
                setLevelNeedsUpdating(ParentIDset);
            }
           /* List<Account> AccountList = [SELECT Id, Name, LevelNeedsUpdating__c FROM Account WHERE Id IN :ParentIDset];
            Set<Account> AccountToUpdate = new Set<Account>();
            Account a;
            for(Account acc : AccountList){
                if (acc.LevelNeedsUpdating__c == false){
                    a = new account(id = acc.id , LevelNeedsUpdating__c = true);
                    //acc.LevelNeedsUpdating__c = true;
                    AccountToUpdate.add(a);
                }
            }

            if(AccountToUpdate.size() > 0){
                AccountTriggerHandler.ExecuteTriggers = false;
                 List<Account> AccountToUpdateList = new list<Account>();
                 AccountToUpdateList.addall(AccountToUpdate);
                update AccountToUpdateList;
                AccountTriggerHandler.ExecuteTriggers = true;
            }*/
        }catch(Exception e){
            system.debug('\n\n' + e + '\n\n');
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Problem updating Level_NeedsUpdating__c on parent accounts.' + e, e);
        }
    }

    //Moved into future method for I-222718
    @future
    public static void setLevelNeedsUpdating(Set<id> ParentIDset){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','setLevelNeedsUpdating');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
            List<Account> AccountList = [SELECT Id, Name, LevelNeedsUpdating__c FROM Account WHERE Id IN :ParentIDset];
            Set<Account> AccountToUpdate = new Set<Account>();
            Account a;
            for(Account acc : AccountList){
                if (acc.LevelNeedsUpdating__c == false){
                    a = new account(id = acc.id , LevelNeedsUpdating__c = true);
                    //acc.LevelNeedsUpdating__c = true;
                    AccountToUpdate.add(a);
                }
            }

            if(AccountToUpdate.size() > 0){
                AccountTriggerHandler.ExecuteTriggers = false;
                 List<Account> AccountToUpdateList = new list<Account>();
                 AccountToUpdateList.addall(AccountToUpdate);
                update AccountToUpdateList;
                AccountTriggerHandler.ExecuteTriggers = true;
            }
    }

    //Sberron - S-445869 - 12/20/16
    //Non future method to be called in batch class
    public void setLevelNeedsUpdating1(Set<id> ParentIDset){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','etLevelNeedsUpdating1');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
            List<Account> AccountList = [SELECT Id, Name, LevelNeedsUpdating__c FROM Account WHERE Id IN :ParentIDset];
            Set<Account> AccountToUpdate = new Set<Account>();
            Account a;
            for(Account acc : AccountList){
                if (acc.LevelNeedsUpdating__c == false){
                    a = new account(id = acc.id , LevelNeedsUpdating__c = true);
                    //acc.LevelNeedsUpdating__c = true;
                    AccountToUpdate.add(a);
                }
            }

            if(AccountToUpdate.size() > 0){
                AccountTriggerHandler.ExecuteTriggers = false;
                 List<Account> AccountToUpdateList = new list<Account>();
                 AccountToUpdateList.addall(AccountToUpdate);
                update AccountToUpdateList;
                AccountTriggerHandler.ExecuteTriggers = true;
            }
    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 08/1/2014
** @story : 063
** @element : E1867
** @description : Send Email to the new and old primary sales rep
** @paramaters : List of updated accounts, List of old accounts
** @returns : nothing
*/
    public void SendEmailToOwners(List<Account> pOldAccounts , List<Account> pUpdatedAccounts, Boolean isBatch){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','SendEmailToOwners');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        if (Personal_Settings__c.getInstance().Send_Emails__c ==false){
            return; //If custom setting is set to false, skip this so no emails are sent;
        }
        try{
            Set<Id> newSalesRepId = new Set<Id>();
            for(Account acc : pUpdatedAccounts){
                newSalesRepId.add(acc.OwnerId);
            }
            map<Id, User> newPrimarySaleRepUsersMap = new map<Id, User>([SELECT Email, Id, FirstName, LastName FROM User WHERE Id IN : newSalesRepId]);
            Set<Id> oldSalesRepId = new Set<Id>();
            for(Account acc : pOldAccounts){
                oldSalesRepId.add(acc.OwnerId);
            }
            map<Id, User> oldPrimarySaleRepUsersMap = new map<Id, User>();
            map<Id, User> usersMap = new map<Id, User>();
            List<User> oldOwner = [SELECT Email, Id, FirstName, LastName FROM User WHERE Id IN : oldSalesRepId];
            for (User u : oldOwner) {
                usersMap.put(u.Id, u);
            }
            for (Account oAccount : pOldAccounts) {
                oldPrimarySaleRepUsersMap.put(oAccount.Id, usersMap.get(oAccount.OwnerId));
            }

            if(!isBatch){
                for (Account uAccount : pUpdatedAccounts) {
                    String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + uAccount.id;

                    User primarySaleRep = newPrimarySaleRepUsersMap.get(uAccount.OwnerId);
                    User oldprimarySaleRep = oldPrimarySaleRepUsersMap.get(uAccount.Id);
                    if(primarySaleRep != null){
                        if(primarySaleRep.Email != oldprimarySaleRep.Email){
                            String msg = 'The account ' + uAccount.Name + ' ('+ uAccount.AccountId__c  +') has been reassigned from ';
                            msg+= oldprimarySaleRep.FirstName + ' ' +oldprimarySaleRep.LastName+ ' to ' +primarySaleRep.FirstName + ' ' + primarySaleRep.LastName;
                            msg+= '. <br/>' + fullFileURL;
                            Messaging.Singleemailmessage mail = new Messaging.Singleemailmessage();
                            mail.setToAddresses(new String[]{primarySaleRep.Email});
                            mail.setSubject('An account has been reassigned to you.');
                            mail.setSenderDisplayName('Salesforce.com');
                            mail.setHtmlBody(msg);
                            Messaging.sendEmail(new Messaging.Email[]{mail}, false);
                        }
                    }


                    if(oldprimarySaleRep != null){
                        if(primarySaleRep.Email != oldprimarySaleRep.Email){
                            String msg = 'The account ' + uAccount.Name + ' ('+ uAccount.AccountId__c  +') has been reassigned from ';
                            msg+= oldprimarySaleRep.FirstName + ' ' +oldprimarySaleRep.LastName+ ' to ' +primarySaleRep.FirstName + ' ' + primarySaleRep.LastName;
                            msg+= '. <br/>' + fullFileURL;
                            Messaging.Singleemailmessage mail = new Messaging.Singleemailmessage();
                            mail.setToAddresses(new String[]{oldprimarySaleRep.Email});
                            mail.setSubject('An account has been reassigned from you.');
                            mail.setSenderDisplayName('Salesforce.com');
                            mail.setHtmlBody(msg);
                            Messaging.sendEmail(new Messaging.Email[]{mail}, false);
                        }
                    }

                }
            }
        }catch(DMLException e){
            ExceptionLog.add('DMLException', 'AccountTriggerHelper', 'SendEmailToOwners', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to send email to owners.' ,e);
        }
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 08/1/2014
** @story : 063
** @element : E1867
** @description : Change the opportunity Primary sales rep
** @paramaters : Map of updated accounts
** @returns : nothing
*/
/*    public static void ChangeOpportunityOwner(map<ID, Account> pAccountIdToNewAccountMap,map<Id, List<Account_Team_Member__c>> atm, List<Opportunity> oppList){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','changeOpportunityOwner');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        List<Id> lstUpdatedOwners = new List<Id>();
        List<Id> updateOwners = new List<Id>();
        List<Id>  finalUpdate = new List<Id>();
        Map<Id, OpportunitySplit> oSplit = new Map<Id, OpportunitySplit>();
        try{
            List<Opportunity> oppToBeUpdated = new List<Opportunity>();
            for(Opportunity o : oppList){
                system.debug('^^OwnerId' + o.OwnerId);
                List<Account_Team_Member__c> catm = atm.get(o.AccountId);
                if(!catm.isEmpty()){
                    Boolean inATM = false;
                    for(Account_Team_Member__c customATM : catm){
                        if(o.OwnerId == customATM.UserId__c){
                            inATM = true;
                        }
                    }
                    if(!inATM){
                        o.OwnerId = pAccountIdToNewAccountMap.get(o.AccountId).OwnerId;
                        lstUpdatedOwners.add(pAccountIdToNewAccountMap.get(o.AccountId).OwnerId);
                        oppToBeUpdated.add(o);
                    }
                }
            }
            if(oppToBeUpdated.size() > 0){
                OpportunityTriggerHandler.PreventRecursion = true;
                system.debug('oppToBeUpdated size : '+oppToBeUpdated.size());
                update oppToBeUpdated;
                //Database.SaveResult[] srList = Database.update(oppToBeUpdated, false);

                for(OpportunityTeamMember oppFirst :[Select Id, UserId from OpportunityTeamMember where OpportunityId in : oppToBeUpdated]){
                    updateOwners.add(oppFirst.UserId);
                }

                for(OpportunitySplit osplitFirst : [SELECT OpportunityId, SplitOwnerId FROM OpportunitySplit where OpportunityId IN :oppToBeUpdated]){
                    oSplit.put(osplitFirst.SplitOwnerId, osplitFirst);
                }

                if(!updateOwners.isEmpty()){
                    for(Id idfirst : updateOwners){
                        if(!oSplit.containsKey(idfirst)){
                            finalUpdate.add(idfirst);
                        }
                    }
                }
                if(!finalUpdate.isEmpty()){
                    delete [Select Id from OpportunityTeamMember where UserId in :finalUpdate AND  OpportunityId in : oppToBeUpdated];
                }
            }
        }catch(DMLException e){
            ExceptionLog.add('DMLException', 'AccountTriggerHelper', 'changeOpportunityOwner', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to update opportunity.' ,e);
        }
    }*/





/*
** @author : Cloud Sherpas, Inc.
** @date : 08/1/2014
** @story : 063
** @element : E1867
** @description : Change the proposal Primary sales rep
** @paramaters : Map of updated accounts
** @returns : nothing
*/
/*    public static void ChangeProposalOwner(map<ID, Account> pAccountIdToNewAccountMap, List<Apttus_Proposal__Proposal__c> quoteList){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','changeProposalOwner');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        List<Apttus_Proposal__Proposal__c> listItems = new List<Apttus_Proposal__Proposal__c>();

        Set<String> proposalStatus = new Set<String>{'Inactive' , 'Expired' , 'Closed' };
        for(Apttus_Proposal__Proposal__c prop : quoteList) {
            if(proposalStatus.contains(prop.QuoteStatus__c) != true){
                Account currAcc = pAccountIdToNewAccountMap.get(prop.Apttus_Proposal__Account__c);
               if(prop.ownerId != currAcc.OwnerId){
                    prop.ownerId = currAcc.OwnerId;
                    listItems.add(prop);
               }
            }
        }
        if(listItems.size() > 0){
            update listItems;
            //Database.SaveResult[] srList = Database.update(listItems, false);
        }
    }
*/
/*
** @author : Cloud Sherpas, Inc.
** @date : 08/1/2014
** @story : 063
** @element : E1867
** @description : Change the activity whoid
** @paramaters : Map of updated accounts
** @returns : nothing
*/
/*    public static void ChangeActivityOwner(map<Id, Account> pAccountIdToNewAccountMap, List<Task> taskList, List<Event> eventList,Map<Id,Id> oldAccountOwnerMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','changeActivityOwner');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        try{
            //Task to Update
            if(!taskList.isEmpty()){
                Set<Task> taskToBeUpdatedSet = new Set<Task>();
                List<Task> taskToBeUpdated = new List<Task>();
                for(Task t : taskList){
                    if(t.AccountId != null){
                        //new logic is just that if the old owner is the current owner and the status is open
                        if(t.OwnerId == oldAccountOwnerMap.get(t.AccountId) && t.Status == 'Open'){
                            t.OwnerId = pAccountIdToNewAccountMap.get(t.AccountId).OwnerId;
                            taskToBeUpdatedSet.add(t);
                        }
                    }
                }
                if(taskToBeUpdatedSet.size() > 0){
                    //update taskToBeUpdated;
                    taskToBeUpdated.addAll(taskToBeUpdatedSet);
                    Database.SaveResult[] srList = Database.update(taskToBeUpdated, false);
                    system.debug('check ****************' + srList );
                }
            }

            //Event to Update
            system.debug('check ****************' + eventList);
            if(!eventList.isEmpty()){
                List<Event> eventToBeUpdated = new List<Event>();
                for(Event e : eventList){
                    if(e.AccountId != null){
                        if(e.OwnerId == oldAccountOwnerMap.get(e.AccountId) && e.EventStatus__c == 'Open'){
                            e.OwnerId = pAccountIdToNewAccountMap.get(e.AccountId).OwnerId;
                            eventToBeUpdated.add(e);
                        }
                    }


                    /* Jeff L commented out for I-189185 new logic is above
                    String EventRoleName = e.Owner.UserRole.Name;
                    if(atm.get(e.AccountId) != null){
                    List<Account_Team_Member__c> catm = atm.get(e.AccountId);
                    if(!catm.isEmpty()){
                        Boolean inATM = false;
                        for(Account_Team_Member__c customATM : catm){
                            if(e.OwnerId == customATM.UserId__c){
                                inATM = true;
                            }
                        }
                        if(!inATM && (EventRoleName != null && EventRoleName.toLowerCase().Contains('sales rep')) && e.OwnerId == oldAccountOwnerMap.get(e.AccountId)){
                            e.OwnerId = pAccountIdToNewAccountMap.get(e.AccountId).OwnerId;
                            eventToBeUpdated.add(e);
                        }
                    }
                }*/
/*                }
                if(eventToBeUpdated.size() > 0){
                    //update eventToBeUpdated;
                    ApttusProposalTriggerHandler.ExecuteTriggers = false;
                    Database.SaveResult[] srList = Database.update(eventToBeUpdated, false);
                }
            }
        }catch(DMLException e){
            ExceptionLog.add('DMLException', 'AccountTriggerHelper', 'changeActivityOwner', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to update activities.' ,e);
        }
    }*/

/*
** @author : Cloud Sherpas, Inc.
** @date : 08/1/2014
** @story : 063
** @element : E1867
** @description : check zipcode
** @paramaters : account and territory assignment
** @returns : nothing
*/
   /* public Boolean checkZipcode(Account zAccount, TerritoryAssignmentCode__c zTerritory){
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
                return inRange = false;
            }
            if(zipAccount[0].trim().isNumeric() && !zipAccount[1].trim().isNumeric()){
                zipAccount[1] ='0000';
            }

            if((zTerritory.PostingZipCodeStart__c == null || zipStart[0].trim() == '') && (zTerritory.PostingZipCodeEnd__c == null || zipEnd[0].trim() == '')){
                inRange = false;
            } else if((zTerritory.PostingZipCodeStart__c != null && zipStart[0].trim() != '') && (zTerritory.PostingZipCodeEnd__c == null || zipEnd[0].trim() == '')){
                if(long.valueof(zipAccount[0].trim()) == long.valueof(zipStart[0].trim()) && long.valueof(zipAccount[1].trim()) == long.valueof(zipStart[1].trim())){
                    inRange = true;
                } else {
                    inRange = false;
                }
            } else if((zTerritory.PostingZipCodeStart__c == null || zipStart[0].trim() == '') && (zTerritory.PostingZipCodeEnd__c != null && zipEnd[0].trim() != '')){
                if(long.valueof(zipAccount[0].trim()) == long.valueof(zipEnd[0].trim()) && long.valueof(zipAccount[1].trim()) == long.valueof(zipEnd[1].trim())){
                    inRange = true;
                } else {
                    inRange = false;
                }
            } else if((zTerritory.PostingZipCodeStart__c != null && zipStart[0].trim() != '') && (zTerritory.PostingZipCodeEnd__c != null && zipEnd[0].trim() != '')){
                if(long.valueof(zipAccount[0].trim()) >= long.valueof(zipStart[0].trim()) && long.valueof(zipAccount[0].trim()) <= long.valueof(zipEnd[0].trim())){
                    if(long.valueof(zipAccount[1].trim()) >= long.valueof(zipStart[1].trim()) && long.valueof(zipAccount[1].trim()) <= long.valueof(zipEnd[1].trim())){
                        inRange = true;
                    } else {
                        inRange = false;
                    }
                } else {
                    inRange = false;
                }
            }
            return inRange;
        }catch(DMLException e){
            ExceptionLog.add('DMLException', 'AccountTriggerHelper', 'checkZipcode', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to check zipcode' ,e);
        }
    }*/

@future
    public static void runTerritoryAssignmentInFuture(Set<Id> pAccountIds){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','runTerritoryAssignmentInFuture');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Map<String, Schema.SObjectField> acctFields = Utility.newInstance().getAllSObjectFieldsBySObjectName(new set<String>{'Account'}).get('Account');

        String acctQuery = 'SELECT ';
        for(String sourceAPI : acctFields.keySet()){
            acctQuery += sourceAPI+',';
        }
        acctQuery = acctQuery.removeEnd(',');
        acctQuery += ' FROM Account WHERE Id IN: pAccountIds';
        List<Account> pUpdatedAccounts = Database.query(acctQuery);

        TerritoryAssignment ta = new TerritoryAssignment(pUpdatedAccounts);
        ta.runTerritoryAssignment();
}

/*
** @author : Cloud Sherpas, Inc.
** @date : 08/1/2014
** @story : 063
** @element : E1867
** @description : For Territory assignment
** @paramaters : List of Accounts, Map of updated accounts
** @returns : nothing
*/
    public void AccountWithoutTerritory(List<Account> pUpdatedAccounts){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','AccountWithoutTerritory');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Boolean ConvertedFromLead = false;
        Boolean IsActiveAccount = false;

        Set<Id> pAccountIds = new Set<Id>();
        for(Account a : pUpdatedAccounts){
            system.debug('^^^ AccountWithoutTerritory ConvertedFromLead__c=' + a.ConvertedFromLead__c);
            if(a.ConvertedFromLead__c){ConvertedFromLead=true;}
            if(a.Lead_Account_Status__c == 'Active'){IsActiveAccount=true;}
            pAccountIds.add(a.Id);
        }
        if (ConvertedFromLead){
            system.debug('^^^ Calling future method runTerritoryAssignmentInFuture(' + pAccountIds + ')');
             //  Pending leads is not allowed for assingnment >> I-212381

            Org_Settings__c orgSettings = Org_Settings__c.getInstance();
            List<Profile> profileList = [Select Id, Name from profile where id =: UserInfo.getProfileId()];
            Profile userProfile = profileList[0];
            if(userProfile.Name == orgSettings.Telemarketing_Inbound__c ||
                        userProfile.Name == orgSettings.Sales_Operations_APAC__c ||
                        userProfile.Name == orgSettings.Sales_Operations_EU__c ||
                        userProfile.Name == orgSettings.Sales_Operations_NA__c ||
                        userProfile.Name == orgSettings.Sales_Operations_TA__c ||
                        userProfile.Name == orgSettings.Sales_Operations_TA_EU__c || IsActiveAccount){
                runTerritoryAssignmentInFuture(pAccountIds);
            }
        } else{
            TerritoryAssignment ta = new TerritoryAssignment(pUpdatedAccounts);
        ta.runTerritoryAssignment();
        }
        /* JFreese 2/24/2016 I-192931
           Salesforce has a very odd and apparently undocumented behavior during Lead Conversion.
           After the new account, opportunity and contact have been created and all triggers have been run,
           Salesforce changes the account owner to match the original lead owner, with no triggers or other log entries.
           So if runTerritoryAssignment() runs synchronously and changes the account owner based on territory assignment,
           at the end Salesforce changes the account owner again and throws the following exception to the UI, which is
           not to be found in any log: Insufficient Privileges - You do not have the level of access necessary to perform
           the operation you requested.  Please contact the owner of the record or your administrator if access is necessary*/


        /*try{
            //map<String, map<String, Id>> result = Utility.GetRecordTypeIdsBySObjectNameSet(new set<String>{'Account'});
            //String recordId = result.get('Account').get('Person Account');
            Set<Id> accnId = new Set<Id>();
            Map<Id, Account> accountMap = new Map<Id, Account>();

            for(Account a : pUpdatedAccounts){
                if(!a.DoNotReassign__c){
                    accnId.add(a.Id);
                    accountMap.put(a.Id, a);
                }
            }
            List<Account> newAccountList = [SELECT ShippingStreet,Phone,AccountStatus__c,ShippingCity,ShippingState,
                                            CustomerNumber__c,CustomerDate__c,CustomerLapsedDate__c,Id, TerritoryCode__c,
                                            ShippingPostalCode,ShippingCountry, BillingPostalCode,AccountGroup__c,
                                            SalesChannel__c, OwnerId, AccountID__c
                                            FROM Account WHERE Id in : accnId];



            /* Jeff L added the following logic on 12/30 for I-197522
            * Territory Assignment codes now have > 50K records in them, requiring some changes to the logic
            * when we are querying (we used to query everything, but now we need to be more selective)
            *
            * New Logic: Created some number formula fields so that we can do Zip code checks in the SOQL query itself
            * Also need to account for the other logic (named accounts etc) so that needs to be included in the check as well
            * then run through the logic that already exists to match up records
            */

            /*String tQuery = 'SELECT AccountCountry__c, AccountGroup__c,NamedAccount__c, SalesChannel__c, ';
            tQuery += 'PostingZipCodeStart__c, PostingZipCodeEnd__c, ';
            tQuery += 'Zip_Code_Start_Number_del__c, Zip_Code_End_Number_del__c, ';
            tQuery += 'TerritoryAssignment__c, TerritoryAssignment__r.OwnerId ';
            tQuery += 'FROM TerritoryAssignmentCode__c WHERE';

            /* Old commented out query kept around just in case
            List<TerritoryAssignmentCode__c> territoryCodeList = [SELECT AccountCountry__c, AccountGroup__c,
                                                                        NamedAccount__c, SalesChannel__c,
                                                                        PostingZipCodeStart__c, PostingZipCodeEnd__c,
                                                                        Zip_Code_Start_Number_del__c, Zip_Code_End_Number_del__c
                                                                        TerritoryAssignment__c, TerritoryAssignment__r.OwnerId
                                                                  FROM TerritoryAssignmentCode__c];
            List<TerritoryAssignment__c> taList= [SELECT Id, OwnerId, Name FROM TerritoryAssignment__c];*/

            //lets iterate over our accounts and put together what is needed for our where clause
            /*Set<String> namedAccountSet = new Set<String>();
            Set<Integer> zipcodeSet = new Set<Integer>();
            for(Account a : newAccountList){

                //Named accounts are simple, they are just the account ID custom field
                if(a.AccountID__c != null){
                    namedAccountSet.add(a.AccountId__c);
                }
                //Next is zip code, we are ok with pulling all the records that contain a single zip code
                if(a.ShippingPostalCode != null){
                    //now we need to do some transformation to get the first 6 digits of the zip code
                    String testString = a.ShippingPostalCode.left(5); //this gets us the digits we need
                    //need to check if it is numeric or not.
                    if(testString.isNumeric()){
                        zipcodeSet.add(Integer.valueOf(testString));
                    }
                }
            }

            //Now we can construct the Where clause of our query! It will consist of two parts
            //a query for named accounts OR where the zip code range matches
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
                needsOr = true;
                hasWhereClause = true;
            }

            if(zipcodeSet.size() > 0){
                if(needsOr){
                    tQuery += ' OR';
                }

                for(Integer zipCode : zipCodeSet){
                    tQuery += ' (Zip_Code_Start_Number_del__c <= ' + zipCode + ' AND Zip_Code_End_Number_del__c >= ' + zipCode + ') OR ';
                }
                //remove the last OR  and two spaces from our querystring
                tQuery = tQuery.left(tQuery.length() - 4);
                hasWhereClause = true;
            }

            if(hasWhereClause == false){
                return; //no where clause, so nothing to query.
            }
            system.debug('!!query!! ' + tQuery);
            List<TerritoryAssignmentCode__c> territoryCodeList = new List<TerritoryAssignmentCode__c>();
            map<Id, List<TerritoryAssignmentCode__c>> terAssignmentList = new map<Id, List<TerritoryAssignmentCode__c>>();
            for(TerritoryAssignmentCode__c tac : Database.query(tQuery)){
                territoryCodeList.add(tac);

                if(terAssignmentList.containsKey(tac.TerritoryAssignment__r.Id)){
                    terAssignmentList.get(tac.TerritoryAssignment__r.Id).add(tac);
                } else {
                    List<TerritoryAssignmentCode__c> tacList = new List<TerritoryAssignmentCode__c>();
                    tacList.add(tac);
                    terAssignmentList.put(tac.TerritoryAssignment__r.Id,tacList);
                }
            }

            /*map<Id, List<TerritoryAssignmentCode__c>> terAssignmentList = new map<Id, List<TerritoryAssignmentCode__c>>();
            if(!territoryCodeList.isEmpty()){
                for(TerritoryAssignmentCode__c taCode : territoryCodeList){
                    if(terAssignmentList.containsKey(taCode.TerritoryAssignment__c)){
                        List<TerritoryAssignmentCode__c> tacs = terAssignmentList.get(taCode.TerritoryAssignment__c);
                        tacs.add(taCode);
                        terAssignmentList.put(taCode.TerritoryAssignment__c, tacs);
                    } else {
                        terAssignmentList.put(taCode.TerritoryAssignment__c, new List<TerritoryAssignmentCode__c>{taCode});
                    }
                }
            }*/

            /*List<Account> accToUpdate = new List<Account>();
            Boolean changeTeamMember = false;

           /* map<String, TerritoryAssignmentCode__c> territoryWithNamedAccount = new map<String, TerritoryAssignmentCode__c>();
            for(TerritoryAssignmentCode__c tac : territoryCodeList){
                if(tac.NamedAccount__c != null){
                    territoryWithNamedAccount.put(tac.NamedAccount__c, tac);
                }
            }
            Account[] NamedAccounts = new Account[]{};
            for(Account acc : newAccountList){
                if(territoryWithNamedAccount.containsKey(acc.AccountID__c)){
                    NamedAccounts.add(acc);
                }
            }*/
            /*if(!newAccountList.isEmpty()){
                for(Account acc : newAccountList){
                    Boolean named = false;
                    Boolean zipCodeRange = false;
                    Boolean inCriteria= false;
                    Boolean addToUpdate= false;
                    if(!territoryCodeList.isEmpty()){
                        for(TerritoryAssignmentCode__c tac : territoryCodeList){
                            if(acc.AccountID__c != null && acc.AccountID__c == tac.NamedAccount__c){
                                if(tac.TerritoryAssignment__r.OwnerId != null){
                                    acc.OwnerId = tac.TerritoryAssignment__r.OwnerId;
                                }
                                acc.TerritoryCode__c = tac.TerritoryAssignment__c;
                                named = true;
                            }
                        }
                    }

                    if(!named){
                        if(!terAssignmentList.keySet().isEmpty()){
                            for(Id ta : terAssignmentList.keySet()){
                                if(terAssignmentList.containsKey(ta)){
                                    for(TerritoryAssignmentCode__c tac : terAssignmentList.get(ta)){
                                        if(tac.AccountCountry__c != null){
                                            if(acc.ShippingCountry != null && (tac.AccountCountry__c ==acc.ShippingCountry)){
                                                inCriteria = true;
                                            } else {
                                                inCriteria = false;
                                                continue;
                                            }
                                        }
                                        if(tac.AccountGroup__c != null){
                                            if(acc.AccountGroup__c != null && (tac.AccountGroup__c == acc.AccountGroup__c)){
                                                inCriteria = true;
                                            } else {
                                                inCriteria = false;
                                                continue;
                                            }
                                        }
                                        if(tac.SalesChannel__c != null){
                                            if(acc.SalesChannel__c != null && (tac.SalesChannel__c == acc.SalesChannel__c)){
                                                inCriteria = true;
                                            } else {
                                                inCriteria = false;
                                                continue;
                                            }
                                        }
                                        if(tac.PostingZipCodeStart__c != null || tac.PostingZipCodeEnd__c != null){
                                            if(acc.ShippingPostalCode != null){
                                                zipCodeRange = checkZipcode(acc, tac);
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
                                                acc.OwnerId = tac.TerritoryAssignment__r.OwnerId;
                                            }

                                            acc.TerritoryCode__c = tac.TerritoryAssignment__c;
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if(acc.TerritoryCode__c != null){
                        accToUpdate.add(acc);
                    }
                }
            }
            if(accToUpdate.size() > 0){
                SetSendToEmailFlag.fromTerritory = true;

                Database.SaveResult[] srList = Database.update(accToUpdate, false);
            }
        }catch(DMLException e){
           ExceptionLog.add('DMLException', 'AccountTriggerHelper', 'AccountWithoutTerritory', e.getMessage());
           throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to update Account.' ,e);
        }*/
    }
    /*
** @author : Cloud Sherpas, Inc.
** @date : 08/1/2014
** @story : 063
** @element : E1867
** @description : replace Account teammember
** @paramaters : Map of updated accounts
** @returns : nothing
*/
    public void ReplaceAccountTeamMember(Set<Id> setIds){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','ReplaceAccountTeamMember');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        try{
            List<Account> acnt = [SELECT Id, OwnerId,TerritoryCode__c, (SELECT Id, TeamMemberRole,AccountId FROM AccountTeamMembers WHERE TeamMemberRole = 'Sales Rep'),
                                             (SELECT Id, TeamMemberRole__c,AccountId__c FROM Account_Team_Members__r WHERE TeamMemberRole__c = 'Sales Rep')
                                             FROM Account WHERE Id In: setIds];
            Set<id> terId = new Set<Id>();
            //Map <Id, Account> accMap = new Map<Id, Account>();
            List<AccountTeamMember> satm = new List<AccountTeamMember>();
            List<Account_Team_Member__c> catm = new List<Account_Team_Member__c>();
            List<Account> acntHaveTer = new List<Account>();
            for(Account acc : acnt){
                if(acc.TerritoryCode__c != null){
                    terId.add(acc.TerritoryCode__c);
                    acntHaveTer.add(acc);

                    for(AccountTeamMember astm : acc.AccountTeamMembers){
                        if(astm != null){
                            satm.add(astm);
                        }
                    }
                    for(Account_Team_Member__c actm : acc.Account_Team_Members__r){
                        if(actm != null){
                            catm.add(actm);
                        }
                    }
                }
            }
            List<TerritoryAssignmentTeamMember__c> tatmToTransfer = [SELECT TerritoryAssignment__c, AccountAccessLevel__c, CaseAccessLevel__c, OpportunityAccessLevel__c, TeamMember__c, TeamMemberRole__c FROM TerritoryAssignmentTeamMember__c WHERE TerritoryAssignment__c In : terId];
            List<AccountTeamMember> newATMToInsert = new List<AccountTeamMember>();
            List<Account_Team_Member__c> newCATMToInsert = new List<Account_Team_Member__c>();

            if(!catm.isEmpty()){
                Database.DeleteResult[] srListDelete1 = Database.delete(catm, false);
            }
            if(!satm.isEmpty()){
                Database.DeleteResult[] srListDelete = Database.delete(satm, false);
            }

            if(!tatmToTransfer.isEmpty()){
                for(Account a : acntHaveTer){
                    if(a.TerritoryCode__c != null){
                        for(TerritoryAssignmentTeamMember__c tatm : tatmToTransfer){
                            if(a.TerritoryCode__c == tatm.TerritoryAssignment__c && a.OwnerId != tatm.TeamMember__c){
                                /*AccountTeamMember newATM = new AccountTeamMember();
                                newATM.AccountId = a.Id;
                                newATM.TeamMemberRole = tatm.TeamMemberRole__c;
                                newATM.UserId = tatm.TeamMember__c;
                                newATMToInsert.add(newATM);*/

                                Account_Team_Member__c newCATM = new Account_Team_Member__c();
                                newCATM.AccountId__c = a.Id;
                                newCATM.TeamMemberRole__c = tatm.TeamMemberRole__c;
                                newCATM.UserId__c = tatm.TeamMember__c;
                                newCATMToInsert.add(newCATM);
                            }
                        }
                    }
                }
            }
            if(newCATMToInsert.size() > 0){
                Database.SaveResult[] srList1 = Database.insert(newCATMToInsert, false);
                //insert newCATMToInsert;
            }
            /*system.debug('>>Account team to insert >> ' + newATMToInsert);
            if(newATMToInsert.size() > 0){
                Database.SaveResult[] srList = Database.insert(newATMToInsert, false);
                //insert newATMToInsert;
            }*/


        }catch(DMLException e){
            ExceptionLog.add('DMLException', 'AccountTriggerHelper', 'ReplaceAccountTeamMember', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to update account team member.' ,e);
        }
    }


    public static List<Account> getChangedAccounts(Set<Id> accountIds){
        Date actDate= system.now().date() - 120;
        List<String> stage = new List<String>{'Stage 0 - Lead Generation', 'Stage 1 - Needs Assessment', 'Stage 2 - Proposal', 'Stage 3 - Quote', 'Stage 4 - Won'};
        return [SELECT Id, OwnerId, Name, RecordTypeId,TerritoryCode__c,Organization__c, TA_RunID__c,
                                                (SELECT Id, OwnerId, AccountId FROM Opportunities WHERE StageName IN : stage),
                                                (SELECT Id, OwnerId, AccountId,Organization__c FROM Contacts),
                                                (SELECT Id, OwnerId, AccountId,WhatId, Owner.UserRole.Name,  Status  FROM Tasks WHERE Status = 'Open' AND ActivityDate >: actDate),
                                                (SELECT Id, OwnerId, AccountId,WhatId, Owner.UserRole.Name, EventStatus__c FROM Events WHERE EventStatus__c = 'Open' AND ActivityDate >: actDate),
                                                (SELECT Id, UserId__c, AccountId__c, TeamMemberRole__c, AccountAccessLevel__c, CaseAccessLevel__c, OpportunityAccessLevel__c FROM Account_Team_Members__r),
                                                (SELECT Id, OwnerId, Apttus_Proposal__Account__c,QuoteStatus__c,AccountOrganization__c FROM Apttus_Proposal__SFDC_520_Quote__r WHERE Apttus_Proposal__ExpectedStartDate__c >: actDate)
                                        FROM Account WHERE Id IN :accountIds];

    }

    public static void changeOwner(Set<Id> accountIds, Map<Id,Id> oldAccountOwnerMap, Set<Id> onBeforeUpdateAccountIds){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','changeOwner');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        //JFreese Appirio S-435483 4/10/17 Check to see if all accounts updated
        Set<Id> failedToUpdateAccountIds = new Set<Id>();
        for(Id thisId : onBeforeUpdateAccountIds){
            if(! accountIds.contains(thisId)){
                failedToUpdateAccountIds.add(thisId);
            }
        }

        if (failedToUpdateAccountIds.size() > 0){
            String dbg = '\n**************************************************************************************************************\n';
            dbg += 'NOT Initiating the TABatchContactQueueable because it would fail to start in any case.\n';
            dbg += 'This is because the following account(s) failed to update:\n';
            for (Id thisId : failedToUpdateAccountIds){
                dbg += thisId + '\n';
            }
            dbg += '\nWhen one or more records fail to update due to validation or other errors,\n';
            dbg += 'the call to contactQueueable.enqueueTA() appears to work but nothing happens (it does not enqueue).\n\n';

            dbg += 'This general problem was the subject of Salesforce Support Case Number: 14350507,\n';
            dbg += 'which stated that when "one of the records that is part of the sforce.connection.update\n';
            dbg += 'fails due to a validation error, the other record still hits our after update code \n';
            dbg += '(like we would expect) and it does hit the code that is supposed to fire off a future call,\n';
            dbg += 'but the future call is never enqueued, never shows up in the debug logs, and doesn\'t show up\n';
            dbg += 'in the Apex Jobs tab either."\n\n';

            dbg += 'Salesforce did not have any useful suggestions to fix this problem, and it appears to extend\n';
            dbg += 'to (account) updates from either dataloader or apex anonymous, and to future calls or queueables.\n\n';

            dbg += 'In dataloader the user is informed of the number of success/failed updates, but they may not be aware\n';
            dbg += 'that one or more failures will kill the queuables.\n\n';

            dbg += 'NOTE: If the accounts all update successfully and the queuables are initiated, failures in the updating\n';
            dbg += 'of one or more (e.g.) opportunities will not prevent the enqueueing of the (e.g.) proposal queueable\n';

            dbg += '**************************************************************************************************************\n';
            system.debug(dbg);
            return;
        }

        try{

        //system.debug('>>>>>>>>>>>>>>>>>>>>>>' +ownerChangeThreshold +'>>>>>>' + totalRecordsToUpdate  + '>>>>' +ownerChangeThreshold.Threshold__c );
            Date actDate= system.now().date() - 120;
            Account[] changedAccounts = getChangedAccounts(accountIds);
            List<Id> contactIds = new List<Id>(); //passed into the queueable
            List<Id> accountIdList = new List<Id>(); //passed into the queueable
            Integer totalRecordsToUpdate = 0;
            OwnerChangeThreshold__c ownerChangeThreshold = OwnerChangeThreshold__c.getOrgDefaults();
            Id personAccountRecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Account', 'Person Account');

            for(Id acctId : accountIds){
                accountIdList.add(acctId);
            }

            for(Account a : changedAccounts){
                if(!a.Opportunities.isEmpty()){
                    totalRecordsToUpdate += a.Opportunities.size();

                }

                if(!a.Contacts.isEmpty()){
                    totalRecordsToUpdate += a.Contacts.size();
                    if(a.RecordTypeID != personAccountRecordTypeId){
                        for(Contact con : a.Contacts){
                            contactIds.add(con.Id);
                        }
                    }
                }

                if(!a.Tasks.isEmpty()){
                    totalRecordsToUpdate += a.Tasks.size();
                }
                if(!a.Events.isEmpty()){
                    totalRecordsToUpdate += a.Events.size();
                }
                if(!a.Apttus_Proposal__SFDC_520_Quote__r.isEmpty()){
                    totalRecordsToUpdate += a.Apttus_Proposal__SFDC_520_Quote__r.size();
                }
                if(!a.Account_Team_Members__r.isEmpty()){
                    totalRecordsToUpdate += a.Account_Team_Members__r.size();
                }



            }
            system.debug('>>>>>>>>>>>>>>>>>>>>>>' +ownerChangeThreshold +'>>>>>>' + totalRecordsToUpdate  + '>>>>' +ownerChangeThreshold.Threshold__c );

            TABatchContactQueueable contactQueueable = new TABatchContactQueueable(changedAccounts,oldAccountOwnerMap,contactIds,0,'Contact__c');
            System.debug('Calling contactQueueable.enqueueTA()');
            contactQueueable.enqueueTA();
            System.debug('Called contactQueueable.enqueueTA()');

            /*JFreese 3/27/16 Commenting this out until we are ready to update the TA process DEV2QA1
            TABatchAcctTeamMemberQueueable ATMQueueable = new TABatchAcctTeamMemberQueueable(changedAccounts,oldAccountOwnerMap,accountIdList,0,'AccountTeamMember__c');
            System.debug('Calling ATMQueueable.enqueueTA()');
            ATMQueueable.enqueueTA();
            System.debug('Called ATMQueueable.enqueueTA()');*/
                   /*if(ownerChangeThreshold != null &&  totalRecordsToUpdate > ownerChangeThreshold.Threshold__c){


                 if(!system.isBatch())
                    changeOwnerInFuture(accountIds, oldAccountOwnerMap);

            }else{
                SetSendToEmailFlag.alreadySync = true;
                changeOwnerSecond(changedAccounts,  oldAccountOwnerMap);
            }*/


        }catch(DMLException e){
            ExceptionLog.add('DMLException', 'AccountTriggerHelper', 'changeOwner', e.getMessage());

        }
       /* system.debug('>>>>>>>>>>>>>>>>>>>>>>$$$$' );
        //system.assert(false,'sadsad');
        changeOwnerInFuture(accountIds, oldAccountOwnerMap);*/

    }

    /*@future(callout=true)
    public static void changeOwnerInFuture(Set<Id> accountIds, Map<Id,Id> oldAccountOwnerMap){
    //system.assert(false,'sadsad');
        try{
            Set<Id> newSalesRepId = new Set<Id>();
            Account[] changedAccounts = getChangedAccounts(accountIds);
            changeOwnerSecond(changedAccounts,  oldAccountOwnerMap);


            for(Account acc : changedAccounts){
                newSalesRepId.add(acc.OwnerId);
            }
            User currUser = [SELECT Email, Id, FirstName, LastName FROM User WHERE Id = : Userinfo.getUserId()];

            for (Account uAccount : changedAccounts) {
                    String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + uAccount.id;

                    if(currUser.Email != null){
                        String msg = 'The owner change that you submitted for <a href="'+fullFileURL+'" >'+ uAccount.Name +'</a> has been completed.' ;
                        //msg+= oldprimarySaleRep.FirstName + ' ' +oldprimarySaleRep.LastName+ ' to ' +primarySaleRep.FirstName + ' ' + primarySaleRep.LastName;
                        //msg+= '. <br/>' + fullFileURL;
                        Messaging.Singleemailmessage mail = new Messaging.Singleemailmessage();
                        mail.setToAddresses(new String[]{currUser.Email});
                        mail.setSubject('Owner Change for '+ uAccount.Name);
                        mail.setSenderDisplayName('Salesforce.com');
                        mail.setHtmlBody(msg);

                        if (Personal_Settings__c.getInstance().Send_Emails__c == true){
                            //If custom setting is set to false, skip this so no emails are sent
                            Messaging.sendEmail(new Messaging.Email[]{mail}, false);
                        }

                    }
            }

        }catch(DMLException e){
            ExceptionLog.add('DMLException', 'AccountTriggerHelper', 'changeOwnerInFuture', e.getMessage());

        }
    }

    public static void changeOwnerSecond(Account[] changedAccounts, Map<Id,Id> oldAccountOwnerMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','changeOwnerSecond');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        //try{
          //  TriggerHelper helper = new TriggerHelper();
            //Date actDate= system.now().date() - 120;
            map<String, map<String, Id>> result = Utility.GetRecordTypeIdsBySObjectNameSet(new set<String>{'Account'});
            String recordId = result.get('Account').get('Person Account');

            //map<Id, Account> accountMap = new map<Id, Account>();
            //map<Id, Id> useATMId = new map<Id, Id>();
            //Contact[] cons = new Contact[]{};
            //Opportunity[] opp = new Opportunity[]{};
            //List<Task> tsk = new List<Task>();
            //Event[] evt = new Event[]{};
            //map<Id, List<Account_Team_Member__c>> atm = new map<Id, List<Account_Team_Member__c>>();
            //Apttus_Proposal__Proposal__c[] pro = new Apttus_Proposal__Proposal__c[]{};
            Date actDate= system.now().date() - 120;

            List<Id> contactIds = new List<Id>();

            for(Account a : changedAccounts){
                //accountMap.put(a.Id, a);
                /*if(!a.Opportunities.isEmpty()){
                    for(Opportunity o : a.Opportunities){
                        opp.add(o);
                    }

                    for(Task t : [SELECT Id, OwnerId, AccountId,WhatId, Owner.UserRole.Name, Status  FROM Task WHERE Status = 'Open' AND  WhatId IN :a.Opportunities]){
                        //t.WhatId = a.Id;
                        tsk.add(t);
                    }
                    for(Event e : [SELECT Id, OwnerId, AccountId,WhatId, Owner.UserRole.Name, EventStatus__c FROM Event WHERE EventStatus__c  = 'Open' AND  WhatId IN :a.Opportunities]){
                        //e.WhatId = a.Id;
                        evt.add(e);

                    }

                }

                if(!a.Contacts.isEmpty()){
                    for(Contact con : a.Contacts){
                        if(a.RecordTypeId != recordId ){
                            //con.ownerId = a.OwnerId;
                            //con.Organization__c = a.Organization__c;
                            //cons.add(con);
                            //queueable update
                            contactIds.add(con.Id);
                        }
                    }
                }
            }

                TABatchContactQueueable contactQueueable = new TABatchContactQueueable(changedAccounts,oldAccountOwnerMap,contactIds,0,'Contact__c');
                contactQueueable.enqueueTA();

               /* system.debug('chjeck ************' + a.Tasks);
                if(!a.Tasks.isEmpty()){
                    tsk = [SELECT Id, OwnerId, AccountId,WhatId, Owner.UserRole.Name, Status
                            FROM Task WHERE Status = 'Open' AND  AccountId IN :changedAccounts and ownerId IN :oldAccountOwnerMap.values() AND ActivityDate >: actDate];
                    //for(Task t : a.Tasks){
                    //    tsk.add(t);
                    //}
                    system.debug('ActivityDate >: actDate' + actDate);
                    system.debug(tsk);*/

               /* }
                if(!a.Events.isEmpty()){
                    evt = [SELECT Id, OwnerId, AccountId,WhatId, Owner.UserRole.Name, EventStatus__c
                            FROM Event WHERE EventStatus__c = 'Open' AND AccountId IN :changedAccounts and ownerId IN :oldAccountOwnerMap.values() AND ActivityDate >: actDate ];
                    //for(Event e : a.Events){
                    //    evt.add(e);
                    //}*/

               /* }
                if(!a.Account_Team_Members__r.isEmpty()){
                    List<Account_Team_Member__c> atmList = new List<Account_Team_Member__c>();
                    atmList.addAll(a.Account_Team_Members__r);
                    atm.put(a.Id, atmList);
                }
                if(!a.Apttus_Proposal__SFDC_520_Quote__r.isEmpty()){
                    for(Apttus_Proposal__Proposal__c p : a.Apttus_Proposal__SFDC_520_Quote__r){
                        pro.add(p);
                    }
                }
            }*/



            //if(cons.size() > 0){
                //new queuable logic
                /*TABatchContactQueueable contactQueueable = new TABatchContactQueueable(changedAccounts,oldAccountOwnerMap,contactIds,0,'Contact__c');
                contactQueueable.enqueueTA();*/


                //update cons;
                //try{
                //update cons;
               /* Database.SaveResult[] srList = Database.update(cons, false);
                //}catch(Exception e){System.Debug('^^^ GOT Contact EXCEPTION: ' + e.getMessage());}

                System.debug('srlist.size()='+ srlist.size());

                for (Database.SaveResult sr : srList) {
                    if (!sr.isSuccess()) {
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Contact fields that affected this error: ' + err.getFields());
                        }
                    }
                }*/
            //}

           /* System.debug('ChangeProposalOwner pro =='+pro);
            if(pro.size() > 0){
                //ChangeProposalOwner(accountMap,pro);
                //System.debug('ChangeProposalOwner =='+pro);
            }
            if(opp.size() > 0){
               // ChangeOpportunityOwner(accountMap,atm,opp);

            }
            system.debug('check********' + tsk.size());
            if(tsk.size() > 0 || evt.size() > 0){
                //ChangeActivityOwner(accountMap,tsk,evt,atm,oldAccountOwnerMap);
            }

        }catch(Exception e){
            //J Freese Appirio 6/6/16 I-219529 Send an email if the future callout results in an exception
            System.Debug('^^^ GOT AN EXCEPTION: ' + e.getMessage() + ' ' + e.getLineNumber());
            User currUser = [SELECT Email, Id, FirstName, LastName FROM User WHERE Id = : Userinfo.getUserId()];
            if(currUser.Email != null && System.isFuture() == true){
                String msg = 'The Account ownership changes that you submitted were halted by the following error(s):<BR><BR>';
                msg += e.getMessage();
                Messaging.Singleemailmessage mail = new Messaging.Singleemailmessage();
                mail.setToAddresses(new String[]{currUser.Email});
                mail.setSubject('ERROR(S) From Batch Account Ownership Changes');
                mail.setSenderDisplayName('Salesforce.com');
                mail.setHtmlBody(msg);
                Messaging.sendEmail(new Messaging.Email[]{mail}, false);
            }

            ExceptionLog.add('DMLException', 'AccountTriggerHelper', 'changeOwnerSecond', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to update contact.' ,e);
        }
    }*/

/*
** @author : Cloud Sherpas, Inc.
** @date : 08/1/2014
** @story : 063
** @element : E1867
** @description : Change the contact's owner
** @paramaters : Map of updated accounts
** @returns : nothing
*/
/*
    public void changeOwner(Set<Id> accountIds){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','changeOwner');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
          //  TriggerHelper helper = new TriggerHelper();
            Date actDate= system.now().date() - 120;
            map<String, map<String, Id>> result = Utility.GetRecordTypeIdsBySObjectNameSet(new set<String>{'Account'});
            String recordId = result.get('Account').get('Person Account');
            List<String> stage = new List<String>{'Stage 0 - Lead Generation', 'Stage 1 - Needs Assessment', 'Stage 2 - Proposal', 'Stage 3 - Quote', 'Stage 4 - Won'};
            Account[] changedAccounts = [SELECT Id, OwnerId, RecordTypeId,TerritoryCode__c,Organization__c,
                                                (SELECT Id, OwnerId, AccountId FROM Opportunities WHERE StageName IN : stage),
                                                (SELECT Id, OwnerId, AccountId,Organization__c FROM Contacts),
                                                (SELECT Id, OwnerId, WhatId, Owner.UserRole.Name, Valid_Sales_Activity_Owner__c  FROM Tasks WHERE Status = 'Open' AND ActivityDate >: actDate),
                                                (SELECT Id, OwnerId, WhatId, Owner.UserRole.Name FROM Events WHERE EventStatus__c = 'Open' AND ActivityDate >: actDate),
                                                (SELECT Id, UserId__c, AccountId__c, TeamMemberRole__c, AccountAccessLevel__c, CaseAccessLevel__c, OpportunityAccessLevel__c FROM Account_Team_Members__r),
                                                (SELECT Id, OwnerId, Apttus_Proposal__Account__c,QuoteStatus__c,AccountOrganization__c FROM Apttus_Proposal__SFDC_520_Quote__r WHERE Apttus_Proposal__ExpectedStartDate__c >: actDate)
                                        FROM Account WHERE Id IN :accountIds];



            map<Id, Account> accountMap = new map<Id, Account>();
            map<Id, Id> useATMId = new map<Id, Id>();
            Contact[] cons = new Contact[]{};
            Opportunity[] opp = new Opportunity[]{};
            List<Task> tsk = new List<Task>();
            Event[] evt = new Event[]{};
            map<Id, List<Account_Team_Member__c>> atm = new map<Id, List<Account_Team_Member__c>>();
            Apttus_Proposal__Proposal__c[] pro = new Apttus_Proposal__Proposal__c[]{};


            for(Account a : changedAccounts){
                accountMap.put(a.Id, a);
                if(!a.Opportunities.isEmpty()){
                    for(Opportunity o : a.Opportunities){
                        opp.add(o);
                    }
                }

                if(!a.Contacts.isEmpty()){
                    for(Contact con : a.Contacts){
                        if(a.RecordTypeId != recordId ){
                            con.ownerId = a.OwnerId;
                            con.Organization__c = a.Organization__c;
                            cons.add(con);
                        }
                    }
                }
                if(!a.Tasks.isEmpty()){
                    for(Task t : a.Tasks){
                        tsk.add(t);
                    }
                }
                if(!a.Events.isEmpty()){
                    for(Event e : a.Events){
                        evt.add(e);
                    }
                }
                if(!a.Account_Team_Members__r.isEmpty()){
                    List<Account_Team_Member__c> atmList = new List<Account_Team_Member__c>();
                    atmList.addAll(a.Account_Team_Members__r);
                    atm.put(a.Id, atmList);
                }
                if(!a.Apttus_Proposal__SFDC_520_Quote__r.isEmpty()){
                    for(Apttus_Proposal__Proposal__c p : a.Apttus_Proposal__SFDC_520_Quote__r){
                        pro.add(p);
                    }
                }
            }
            if(cons.size() > 0){
                //update cons;
                Database.SaveResult[] srList = Database.update(cons, false);
            }

            SetSendToEmailFlag.alreadySync = true;
            System.debug('ChangeProposalOwner pro =='+pro);
            if(pro.size() > 0){
                ChangeProposalOwner(accountMap,pro,atm);
                System.debug('ChangeProposalOwner =='+pro);
            }
            if(opp.size() > 0){
                ChangeOpportunityOwner(accountMap,atm,opp);
            }if(tsk.size() > 0 || evt.size() > 0){
                ChangeActivityOwner(accountMap,tsk,evt,atm);
            }

        }catch(DMLException e){
            ExceptionLog.add('DMLException', 'AccountTriggerHelper', 'changeOwner', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to update contact.' ,e);
        }
    }
    */
/*
** @author : Cloud Sherpas, Inc.
** @date : 08/1/2014
** @story : 063
** @element : E1867
** @description : Change the contact's owner
** @paramaters : Map of updated accounts
** @returns : nothing
*/
    public void whenPrimarySalesRepChanged(List<Account> pUpdatedAccountList,  map<ID, Account> pAccountIdToOldAccountMap, Set<Id> onBeforeUpdateAccountIds){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','whenPrimarySalesRepChange');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        try{
            set<Id> AccountThatHasOwnerChanged = new set<Id>();
            List<Account> newAccountChangeOwner = new List<Account>();
            List<Account> oldAccountChangeOwner = new List<Account>();
            Map<Id,Id> oldAccountOwnerMap =  new Map<Id,Id>();
            for(Account a : pUpdatedAccountList){
                if(a.ownerId != pAccountIdToOldAccountMap.get(a.Id).ownerId ||
                    a.TerritoryCode__c != pAccountIdToOldAccountMap.get(a.Id).TerritoryCode__c ||
                    a.TA_RunID__c != pAccountIdToOldAccountMap.get(a.Id).TA_RunID__c){
                    AccountThatHasOwnerChanged.add(a.Id);
                    newAccountChangeOwner.add(a);
                    oldAccountChangeOwner.add(pAccountIdToOldAccountMap.get(a.Id));
                    oldAccountOwnerMap.put(a.Id,pAccountIdToOldAccountMap.get(a.Id).ownerId);
                }
            }

            if(AccountThatHasOwnerChanged.isempty()){
                System.Debug('^^^No Accounts found to process (that changed owner, TerritoryCode__c or TA_RunID__c).');
                return;
            }

            //JFreese Appirio S-435483 4/10/17
            if (TAQueueableDebugMode){
                String dbg ='^^^Account(s) to process via TA queueables: ';
                for(Id a : AccountThatHasOwnerChanged){
                    dbg += a + ', ';
                }
                dbg = dbg.left(dbg.length() - 2);
                system.debug(dbg);
            }

            //changeOwner(AccountThatHasOwnerChanged);
            changeOwner(AccountThatHasOwnerChanged,oldAccountOwnerMap,onBeforeUpdateAccountIds);
            SendEmailToOwners(oldAccountChangeOwner, newAccountChangeOwner, system.isBatch());
        }catch(DMLException e){
            ExceptionLog.add('DMLException', 'AccountTriggerHelper', 'whenPrimarySalesRepChange', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to update contact.' ,e);
        }
    }

 /*
** @author : Cloud Sherpas, Inc.
** @date : 05/28/2014
** @story : 0451
** @element :
** @description : MAPP Rep Assignments
** @paramaters : List of accounts
** @returns : nothing
*/
    public void AssignAccountsFromMAPP(Account[] pNewAccounts){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','AssignAccountsFromMAPP');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        //try{
            for(Account acc : pNewAccounts){
                system.debug('MAPP_Country__c=' + acc.MAPP_Country__c);
                if(acc.MAPP_Country__c == 'US'){
                    system.debug(acc.CreatedDate + acc.SalesRepLogin__c+'asdf');
                    Date myDate;
                    if (acc.CreatedDate != null) {
                        DateTime dT = acc.CreatedDate;
                        myDate = Date.newinstance(dT.year(), dT.month(), dT.day());
                    } else {
                        myDate = Date.Today();
                    }
                    If(myDate  == Date.Today() && acc.SalesRepLogin__c =='ECOMM'){
                        if((acc.DBEmployeeTotal__c >= 1 &&  acc.DBEmployeeTotal__c <= 49)){
                            if(acc.Industry_ID__c== '39' || acc.Industry_ID__c== '40' || acc.Industry_ID__c== '69'){
                                acc.MAPPGroupOwner__c = 'Telesales-—Healthcare';
                            }
                            if(acc.Industry_ID__c== '38' || acc.Industry_ID__c== '68' ){
                                acc.MAPPGroupOwner__c = 'State Local Education';
                            }
                            if(acc.Industry_ID__c== '50' || acc.Industry_ID__c== '51' || acc.Industry_ID__c== '6'){
                                acc.MAPPGroupOwner__c = 'Government.us';
                            }
                            if(acc.Industry_ID__c== '46' || acc.Industry_ID__c== '41' ){
                                acc.MAPPGroupOwner__c = 'Staffing--Telesales';
                            }
                        }
                    }
                }
                if(acc.MAPP_Country__c == 'UK'){
                    acc.MAPPGroupOwner__c = 'E-Commerce.uk';
                }
                if(acc.MAPP_Country__c == 'FR'){
                    acc.MAPPGroupOwner__c = 'E-Commerce.fr';
                }
                if(acc.MAPP_Country__c == 'NL'){
                    acc.MAPPGroupOwner__c = 'NL.TELESALES-ENTERPRISE-NB';
                }
                if(acc.MAPP_Country__c == 'CA'){
                    acc.MAPPGroupOwner__c = 'Telesales.ca';
                }
                if(acc.MAPP_Country__c == 'BE'){
                    acc.MAPPGroupOwner__c = 'E-Commerce.be';
                }
                if(acc.MAPP_Country__c == 'ES'){
                    acc.MAPPGroupOwner__c = 'E-Commerce.es';
                }
                if(acc.MAPP_Country__c == 'IT') {
                    acc.MAPPGroupOwner__c = 'E-Commerce.it';
                }
                if(acc.MAPP_Country__c == 'DK'){
                    acc.MAPPGroupOwner__c = 'DK.TELESALES-SMB-NB';
                }
                if(acc.MAPP_Country__c == 'SE'){
                    acc.MAPPGroupOwner__c = 'SE.TELESALES-SMB-NB';
                }
                if(acc.MAPP_Country__c == 'IE'){
                    acc.MAPPGroupOwner__c = 'IE.FIELDSALES-ENTERPRISE-RN';
                }
                if(acc.MAPP_Country__c == 'LU'){
                    acc.MAPPGroupOwner__c = 'LU.FIELDSALES-ENTERPRISE-NB';
                }
                if(acc.MAPP_Country__c == 'AT'){
                    acc.MAPPGroupOwner__c = 'AT.TELESALES-SMB-NB';
                }
                if(acc.MAPP_Country__c == 'CH'){
                    acc.MAPPGroupOwner__c = 'CH.TELESALES-SMB-NB';
                }
                if(acc.MAPP_Country__c == 'DE'){
                    acc.MAPPGroupOwner__c = 'DE.TELESALES-SMB-NB';
                }
                if(acc.MAPP_Country__c == 'NO'){
                    acc.MAPPGroupOwner__c = 'NO.TELESALES-SMB-NB';
                }
                if(acc.MAPP_Country__c == 'CZ'){
                    acc.MAPPGroupOwner__c = 'CZ.TELESALES-NB';
                }
                if(acc.MAPP_Country__c == 'SK'){
                    acc.MAPPGroupOwner__c = 'SK.TELESALES-SMB-NB';
                }
                if(acc.MAPP_Country__c == 'PL'){
                    acc.MAPPGroupOwner__c = 'PL.ECOM-NB';
                }
                if(acc.MAPP_Country__c == 'HU'){
                    acc.MAPPGroupOwner__c = 'HU.Telesales';
                }
                if(acc.MAPP_Country__c == 'TR'){
                    acc.MAPPGroupOwner__c = 'TR.FIELDSALES';
                }
                if(acc.MAPP_Country__c == 'RU'){
                    acc.MAPPGroupOwner__c = 'RU.FIELDSALES';
                }
                if(acc.MAPP_Country__c == 'ZA'){
                    acc.MAPPGroupOwner__c = 'ZA.Telesales';
                }
                if(acc.MAPP_Country__c == 'MX'){
                    acc.MAPPGroupOwner__c = 'Telesales.MX';
                }
                if(acc.MAPP_Country__c == 'BR'){
                    acc.MAPPGroupOwner__c = 'Telesales.BR';
                }
                if(acc.CreatedById != null){
                    acc.ownerId = acc.CreatedById;
                }
            }
        /*}catch(Exception e){
            ExceptionLog.add('Exception', 'AccountTriggerHelper', 'updateAccountFieldsFromMAPP', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to assign Accounts.' ,e);
        }*/
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 09/17/2014
** @story : 0924
** @element : E2163
** @description : Payment Details Assignment
** @paramaters : list of Accounts[]
** @returns : nothing
** @Modified :Adarsh :06/28/2015:To create EU Account: I-168701
*/
     public void AssignPaymentDetails(Account[] pNewAccounts){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','AssignPaymentDetails');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        final String ORGANIZATION_EUROPE = 'Europe';
        final String ORGANIZATION_ASIAPACIFIC = 'Asia Pacific';
        final String ORGANIZATION_NORTHAMERICA = 'North America';
        List<Account> AccountList = new List<Account>();
        List<Account> accToUpdate = new List<Account>();
        set<String> setShippingCountries = new set<String>();
        //AP I-168701
        set<String> acctidSet = new set<String>();
        set<String> payIdSet = new set<String>();
        set<String>acctCountrySet = new set<String>();
        List<Payment_Details__c> PaymentDetailList = new List<Payment_Details__c>();
        map<String,Payment_Details__c> bbMap = new map<String,Payment_Details__c>();
        //AP

        pNewAccounts = [Select Id,Organization__c,ShippingCountry__c,DirectDebit__c,PaymentDetails__c from Account Where Id = :pNewAccounts];

        try{
            Map<String, String> paymentDetailsMap = new Map<String, String>();
            Set<Id> paymentDetailIds = new Set<Id>();
            //system.debug('getAll'+PaymentDetails__c.getAll().values());
            for (PaymentDetails__c pd : PaymentDetails__c.getAll().values()) {
                 paymentDetailsMap.put(pd.Name, pd.Id__c);
                 paymentDetailIds.add(pd.Id__c);
            }
            Map<Id, Payment_Details__c> paymentDetails = new Map<Id, Payment_Details__c>([SELECT Id, PaymentMethod__c, PaymentTerm__c FROM Payment_Details__c WHERE Id IN :paymentDetailIds]);
            //system.debug('pNewAccounts'+pNewAccounts);
            //AP 06/28 :I-168701
            //if(UserInfo.getName() =='Integration MAPP')
            //{

                for(Account acnt: pNewAccounts){
                        if(acnt.Organization__c != null) {
                            acctidSet.add(acnt.Organization__c);
                        }
                        if(acnt.ShippingCountry__c != null) {
                            setShippingCountries.add(acnt.ShippingCountry__c);
                        }
                        //system.debug('acctidSet' + acctidSet);
                }
                if(!setShippingCountries.isEmpty() && !acctidSet.isEmpty())
                {
                    //String Query = 'select Name,Organization__c,Id from Payment_Details__c where Active__c = True AND Non_Standard_Payment__c =False';
                    PaymentDetailList= [select Name, Organization__c, Id, Set_as_Default_for__c, PaymentFrequency__c,PaymentMethod__c, PaymentTerm__c from Payment_Details__c where Active__c = True AND Organization__c in:acctidSet
                                        AND Non_Standard_Payment__c =False AND Set_as_Default_for__c != null AND Set_as_Default_for__c != '' LIMIT 50000];
                    //system.debug('PaymentDetailList' + PaymentDetailList);
                    for(Payment_Details__c xpayAcc: PaymentDetailList){
                        payIdSet.add(xpayAcc.Organization__c);
                        //system.debug('payIdSet'+ payIdSet);
                        System.debug('===xpayAcc.Set_as_Default_for__c=='+xpayAcc.Set_as_Default_for__c);
                        for(string c : xpayAcc.Set_as_Default_for__c.split(';')){
                            bbMap.put(xpayAcc.Organization__c+'~'+c,xpayAcc);
                        }
                        //system.debug('bbMapput'+bbMap.put(xpayAcc.Organization__c,xpayAcc));
                    }
                }
            //}
            system.debug('@@@@@bbMapput====='+bbMap);
            //AP
            if(!paymentDetailsMap.isEmpty()){
                for(Account acc: pNewAccounts){
                    //system.debug('\n\n\n\n\nacc.ShippingCountryCode: '+acc.ShippingCountryCode+'\n\n\n\n\n');
                    if(acc.Organization__c == ORGANIZATION_EUROPE ){
                        if(acc.ShippingCountry__c != null && PaymentDetailList != null){
                            //acc.PaymentDetails__c = paymentDetailsMap.get(acc.ShippingCountryCode);
                            //AP I-168701
                            //for(Account accln : pNewAccounts){
                                //system.debug('bbMapget' +bbMap.get(accln.Organization__c).Id);
                                //if(UserInfo.getName() =='Integration MAPP')
                                //{
                                    string key = acc.Organization__c+'~'+acc.ShippingCountry__c;
                                    System.debug('@@@key===='+key);
                                    if(bbMap.containsKey(key)) {
                                        acc.PaymentDetails__c= bbMap.get(key).Id;
                                        acc.Payment_Method__c = bbMap.get(key).PaymentMethod__c;
                                        acc.Payment_Term__c = bbMap.get(key).PaymentTerm__c;
                                        acc.Payment_Frequency__c = bbMap.get(key).PaymentFrequency__c;
                                        System.debug('===acc.PaymentDetails__c=='+acc.PaymentDetails__c);
                                    }
                                //}
                                //system.debug('accln.PaymentDetails__c'+accln.PaymentDetails__c);
                            //}//AP
                        }
                    }
                    Id paymentDetailId;
                    /*
                    if(acc.Organization__c == ORGANIZATION_EUROPE && acc.DirectDebit__c == true){
                        paymentDetailId = (Id) paymentDetailsMap.get('EU - Direct Debit');
                        acc.PaymentDetails__c = paymentDetailId;
                        if (paymentDetails.containsKey(paymentDetailId)) {
                            acc.Payment_Method__c = paymentDetails.get(paymentDetailId).PaymentMethod__c;
                            acc.Payment_Term__c = paymentDetails.get(paymentDetailId).PaymentTerm__c;
                        }
                    }*/
                    //AP S-334604 10/08/2015
                    //else{
                    if(acc.Organization__c == ORGANIZATION_EUROPE && UserInfo.getName() =='Integration MAPP'){

                        acc.Payment_Method__c = 'Invoice';

                        if(acc.ShippingCountry__c == 'Austria' || acc.ShippingCountry__c == 'Germany'){
                            acc.Payment_Term__c = 'Net 15';
                        }
                        if(acc.ShippingCountry__c == 'Denmark' || acc.ShippingCountry__c == 'Norway' || acc.ShippingCountry__c == 'Sweden'){
                            acc.Payment_Term__c = 'Net 20';
                        }
                        if(acc.ShippingCountry__c == 'Belgium' || acc.ShippingCountry__c == 'Switzerland'|| acc.ShippingCountry__c == 'Spain'
                                || acc.ShippingCountry__c == 'France'|| acc.ShippingCountry__c == '' || acc.ShippingCountry__c == 'Ireland'
                                || acc.ShippingCountry__c == 'Italy' || acc.ShippingCountry__c == 'Luxembourg' || acc.ShippingCountry__c == 'Netherlands'
                                || acc.ShippingCountry__c == 'United Kingdom'){
                            acc.Payment_Term__c = 'Net 30';
                        }
                    }
                    //}//AP
                    if(acc.Organization__c == ORGANIZATION_ASIAPACIFIC){
                        paymentDetailId = (Id) paymentDetailsMap.get(ORGANIZATION_ASIAPACIFIC);
                        acc.PaymentDetails__c = paymentDetailId;
                        if (paymentDetails.containsKey(paymentDetailId)) {
                            acc.Payment_Method__c = paymentDetails.get(paymentDetailId).PaymentMethod__c;
                            acc.Payment_Term__c = paymentDetails.get(paymentDetailId).PaymentTerm__c;
                        }
                    }
                    if(acc.Organization__c == ORGANIZATION_NORTHAMERICA){
                        paymentDetailId = (Id) paymentDetailsMap.get(ORGANIZATION_NORTHAMERICA);
                        acc.PaymentDetails__c = paymentDetailId;
                        if (paymentDetails.containsKey(paymentDetailId)) {
                            acc.Payment_Method__c = paymentDetails.get(paymentDetailId).PaymentMethod__c;
                            acc.Payment_Term__c = paymentDetails.get(paymentDetailId).PaymentTerm__c;
                        }
                    }

                    if(acc.PaymentDetails__c != null){
                        Account updateAccount = new Account();
                        updateAccount.Id = acc.Id;
                        updateAccount.PaymentDetails__c = acc.PaymentDetails__c;
                        updateAccount.Payment_Method__c = acc.Payment_Method__c;
                        updateAccount.Payment_Term__c = acc.Payment_Term__c;
                        accToUpdate.add(updateAccount);
                    }
                }

                if(!accToUpdate.isEmpty()) {
                    update accToUpdate;
                }
            }
        }catch(Exception e){
            ExceptionLog.add('Exception', 'AccountTriggerHelper', 'AssignPaymentDetails', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to assign Payment Details.' ,e);
        }
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 06/05/2014
** @description : Updates the Account Program based from the Parent Account
** @paramaters :
** @returns : nothing
*/
    public void populateAccountProgram(Account[] pNewAccounts){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populateAccountProgram');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Map<Id,Account> parentAccountsMap = new Map<Id,Account>();
        set<Id> ParentIds = new set<Id>();
        for(Account acc : pNewAccounts){
            if(acc.ParentId != null){
                ParentIds.add(acc.ParentId);
            }
        }
        if(!ParentIds.isEmpty()){
            for(Account acc : queryAccountList()){
                //Jeff L commented out 10/12 for new query framework
                //for(Account acc : [SELECT Id, AccountProgram__c FROM Account WHERE Id IN: ParentIds]){
                if(ParentIds.contains(acc.Id) && acc.AccountProgram__c != null){
                    parentAccountsMap.put(acc.Id, acc);
                }
            }
        }
        if(!parentAccountsMap.IsEmpty()){
            for(Account acc : pNewAccounts){
                if(acc.ParentId != null && parentAccountsMap.get(acc.ParentId) != null){
                    acc.AccountProgram__c = parentAccountsMap.get(acc.ParentId).AccountProgram__c;

                }
            }
        }

    }

/*
** @author : J Freese (APPIRIO)
** @date : 31-Dec-2016
** @description : Update Account Program Field from Parent to all chldren  - S-453964
** @paramaters : Account
** @returns : nothing
*/
    /*JFreese 2/6/17 S-453964 No updates to hierarchical descendents per DMenard
    public void updateAccountProgramInDescendants(Account[] pUpdatedAccounts, map<ID, Account> pAccountIdToOldAccountMap){
          final string METHODNAME = CLASSNAME.replace('METHODNAME','updateAccountProgramInDescendants');
          system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
          Map<Id,Account> IdToAccount = new Map<Id,Account>();
          for(Account acc : pUpdatedAccounts ){
                if(acc.AccountProgram__c != pAccountIdToOldAccountMap.get(acc.Id).AccountProgram__c){
                    IdToAccount.put(acc.Id, acc);
                }
          }
        if(IdToAccount.keySet() == null){
            system.debug('\n\n^^^No Updates to AccountProgram__c\n\n');
            return;
        }
        List<Account> childrenToUpdate = new List<Account>();
        childrenToUpdate = getChildrenToUpdate(IdToAccount) ;
        //system.debug('^^^childrenToUpdate=' + childrenToUpdate);
        if(childrenToUpdate.size()>0){
            update childrenToUpdate;
        }
    }*/

/*
** @author : J Freese (APPIRIO)
** @date : 31-Dec-2016
** @description : Get all children to update for the parent(s)  - S-453964
** @paramaters : Map<Id,Id> ParentToChildMap
** @returns : child accounts to update
*/
    /*JFreese 2/6/17 S-453964 No longer needed but may be useful for identifying account hierarchy
    public static List<Account> getChildrenToUpdate(Map<Id,Account> IdToAccount){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','getChildrenToUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Set<Id> topParent = new Set<Id>();
        List<Account> topParents = new List<Account>();
        List<Account> childAccounts = new List<Account>();
        List<Account> childrenToUpdate = new List<Account>();
        Set<Id> childrenToUpdateIds = new Set<Id>();

        for (Id key : IdToAccount.keySet()) {
            if (IdToAccount.get(key).GlobalHQAccount__c != null){
                topParent.add(IdToAccount.get(key).GlobalHQAccount__c);
            }
            else {
                topParent.add(key);
            }
        }
        topParents = [SELECT Id, Name, ParentId, Parent.Name, AccountProgram__c, AccountProgram__r.Name,
                     (SELECT Id, Name, ParentId, Parent.Name, AccountProgram__c, AccountProgram__r.Name from GlobalHQAccounts__r)
                     FROM Account WHERE Id IN :topParent];

        String child = '';
        String parent = '';
        String updated = ' (****** Account Program just updated ******)';
        for(Account a : topParents){
            if(a.GlobalHQAccounts__r.size() > 0){
                parent = '^^^Summary of child accounts for '+ a.id + ': ' + a.Name + ', Parent: ' + a.Parent.Name + ', Program: ' + a.AccountProgram__r.Name;
                if (IdToAccount.containsKey(a.id)){parent += updated;}
                system.debug(parent);
                for (Account ca : a.globalHQAccounts__r){
                    childAccounts.add(ca);
                    child = ca.id + ': ' + ca.name + ', Parent: ' + ca.Parent.Name + ', Program: ' + ca.AccountProgram__r.Name;
                    if (IdToAccount.containsKey(ca.id)){child += updated;}
                    system.debug(child);
                }
            }
        }

        Boolean foundChild = true;
        Boolean gotOne = false;
        for (Id key : IdToAccount.keySet()) {
            system.debug('^^^Children of ' + IdToAccount.get(key).Id + ': ' + IdToAccount.get(key).Name + ' to update');
            gotOne = false;
            do {
                foundChild = false;
                for (Account a : childAccounts) {
                    if (a.ParentId != null && (a.ParentId == key || childrenToUpdateIds.contains(a.ParentId))){
                        if(! childrenToUpdateIds.contains(a.Id)){
                            a.AccountProgram__c = IdToAccount.get(key).AccountProgram__c;
                            childrenToUpdate.add(a);
                            childrenToUpdateIds.add(a.Id);
                            foundChild = true;
                            gotOne = true;
                            system.debug(a.id + ': ' + a.Name);
                        }
                    }
                }
            } while (foundChild == true);
            if (gotOne == false){
                system.debug('No children found for ' + IdToAccount.get(key).Id + ': ' + IdToAccount.get(key).Name);
            }
        }
        return childrenToUpdate;
    }*/


/*
** @author : Cloud Sherpas, Inc.
** @date : 06/05/2014 , last modified : 12/23/2014
** @description : Updates the Account Program based from the Parent Account
** @paramaters :
** @returns : nothing
*/
    public void populateAccountProgram(Account[] pOldAccounts, Account[] pNewAccounts){
        Map<Id,Account> parentAccountsMap = new Map<Id,Account>();
        set<Id> ParentIds = new set<Id>();
        for(Integer i=0;i<pNewAccounts.size();i++){
            if(pNewAccounts[i].ParentId != null && (pOldAccounts[i].ParentId != pNewAccounts[i].ParentId)){
                ParentIds.add(pNewAccounts[i].ParentId);
            }
        }
        if(!ParentIds.isEmpty()){
            for(Account acc : [SELECT Id, AccountProgram__c FROM Account WHERE Id IN: ParentIds]){
                if(acc.AccountProgram__c != null){
                    parentAccountsMap.put(acc.Id, acc);
                }
            }
        }
        if(!parentAccountsMap.IsEmpty()){
            for(Integer i=0;i<pNewAccounts.size();i++){

                if(pNewAccounts[i].ParentId != null
                    && parentAccountsMap.get(pNewAccounts[i].ParentId) != null
                    && (pOldAccounts[i].ParentId != pNewAccounts[i].ParentId)){
                        pNewAccounts[i].AccountProgram__c = parentAccountsMap.get(pNewAccounts[i].ParentId).AccountProgram__c;

                }
            }
        }
    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 12/16/2014
** @description : Updates the Account Program based from the Parent Account
** @paramaters :
** @returns : nothing
** @story : 1002
** @task : 1919
*/
    public void populateAccountParent(Account[] pNewAccounts){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populateAccountParent');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Map<Id,Account> parentAccountsMap = new Map<Id,Account>();
        set<Id> ParentIds = new set<Id>();
        //set<Id> AccProgramIds = new set<Id>();
        for(Account acc : pNewAccounts){
            if(acc.ParentId != null){
                ParentIds.add(acc.ParentId);
            }
        }
        //Jeff updated to fit into new query framework
        //List<Account> oCAccProgram = [SELECT Id, ParentId FROM Account WHERE Id IN: ParentIds];
        List<Account> oCAccProgram = new List<Account>();
        for(Account a : queryAccountList()){
            if(ParentIds.contains(a.Id)){
                oCAccProgram.add(a);
            }
        }
        for(Account oAcc : oCAccProgram){
            if(oAcc.ParentId != null){
                parentAccountsMap.put(oAcc.Id, oAcc);
            }
        }
        if(!parentAccountsMap.IsEmpty()){
            for(Account acc : pNewAccounts){
                if(acc.ParentId == null && parentAccountsMap.get(acc.Id) != null ){
                    acc.ParentId = parentAccountsMap.get(acc.ParentId).ParentId;
                }else if(acc.ParentId != null && parentAccountsMap.get(acc.Id) != null){
                    acc.ParentId = null;
                }
            }
        }
    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 12/16/2014
** @description : Updates the Account Program based from the Parent Account
** @paramaters :
** @returns : nothing
** @story : 1002
** @task : 1919
*/
    public void updateAccountParent(Account[] pNewAccounts){
    final string METHODNAME = CLASSNAME.replace('METHODNAME','updateAccountParent');
    system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        Map<Id,Account> parentAccountsMap = new Map<Id,Account>();
        set<Id> ParentIds = new set<Id>();
        //set<Id> AccProgramIds = new set<Id>();
        for(Account acc : pNewAccounts){
            if(acc.ParentId != null){
                ParentIds.add(acc.ParentId);
            }
        }
        System.debug('----parentIds ' + ParentIds);

        //Sberron - S-444526 - 12/09
        //Created parentHasParent set to store accounts that are both a child and parent account
        //to prevent their parentId from being nullified on Data loader update
        Set<Id> parentHasParent = new Set<Id>();
        for (Account a : pNewAccounts) {
            for (Account a2 : pNewAccounts) {
                if (a.ParentId == a2.Id && a2.ParentId != null) {
                    parentHasParent.add(a2.Id);
                }
            }
        }
        System.debug('----parentHasParent ' + parentHasParent);
        // Jeff L commented out for new query optimization 10/12
        //List<Account> oCAccProgram = [SELECT Id, ParentId FROM Account WHERE Id IN: ParentIds];
        List<Account> oCAccProgram = new List<Account>();
        for(Account a : queryAccountList()){
            if(ParentIds.contains(a.Id)){
                oCAccProgram.add(a);
            }
        }
        System.debug('----oCAccProgram ' + oCAccProgram);


        for(Account oAcc : oCAccProgram){
            if(oAcc.ParentId != null){
                parentAccountsMap.put(oAcc.Id, oAcc);
            }
        }
        System.debug('----parentAccountsMap ' + parentAccountsMap);

        //Sberron - S-444526 - 12/09
        //Add parentHasParent check
        if(!parentAccountsMap.IsEmpty()){
            for(Account acc : pNewAccounts){
                if(acc.ParentId == null && parentAccountsMap.get(acc.Id) != null ){
                    acc.ParentId = parentAccountsMap.get(acc.ParentId).ParentId;
                }else if(acc.ParentId != null && parentAccountsMap.get(acc.Id) != null && parentHasParent.contains(acc.Id) == false){
                    acc.ParentId = null;
                }
            }
        }
    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 10/29/2014
** @story : 2343
** @element : E2381
** @description : If the "Parent ID" field is removed then the account's "Global HQ Account ID" field should be blank.
** @paramaters : Account Id
** @returns : nothing
*/
public void CheckParentandGlobalHQAccountFields(Account[] pNewAccounts, Map<Id, Account> pOldAccountsMap){
    final string METHODNAME = CLASSNAME.replace('METHODNAME','CheckParentandGlobalHQAccountFields');
    system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
    try{
        for(Account acc : pNewAccounts){
            if(acc.parentId == null && pOldAccountsMap.get(acc.Id).ParentId != acc.parentId){
                acc.GlobalHQAccount__c = null;
            }
        }
    }catch(Exception e){
        ExceptionLog.add(e.getTypeName(), CLASSNAME, METHODNAME, e.getMessage());
        throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Failed to update Global HQ Account to null. Please see system log for details.',e);
    }
}
/*
** @author : Cloud Sherpas, Inc.
** @date : 10/29/2014
** @story : 2343
** @element : E2387
** @description : On new account creation and setting the Parent Account the Global HQ Account ID should update but it does not.
** @paramaters : Account Id
** @returns : nothing
*/
public void populateGlobalHQAccount1(Account[] pNewAccounts){
    final string METHODNAME = CLASSNAME.replace('METHODNAME','populateGlobalHQAccount1');
    system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
    try{
        Set<Id> parentIds = new set<Id>();
        for(Account acc : pNewAccounts){
            if(acc.parentId != null){
                parentIds.add(acc.parentId);
            }
        }
        map<Id,Id> parentGlobalHQAccountMap = new map<Id,Id>();
        if(!parentIds.isEmpty()){
            for(Account acc : queryAccountList()){
                if(parentIds.contains(acc.Id)){
                    parentGlobalHQAccountMap.put(acc.Id, acc.GlobalHQAccount__c);
                }
            }
        }
        for(Account acc : pNewAccounts){
            if( parentGlobalHQAccountMap.containsKey(acc.parentId) && acc.parentId != null){
                if(parentGlobalHQAccountMap.get(acc.parentId) != null){
                    acc.GlobalHQAccount__c = parentGlobalHQAccountMap.get(acc.parentId);
                }else{
                    acc.GlobalHQAccount__c = acc.ParentId;
                }
                //set IsGlobalHQ to false
                acc.IsGlobalHQ__c = false;
                System.debug('----setting IsGlobalHQ__c false');
            }
        }
    }catch(Exception e){
        ExceptionLog.add(e.getTypeName(), CLASSNAME, METHODNAME, e.getMessage());
        throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Failed to populate Global HQ Account. Please see system log for details.',e);
    }
}
/*
** @author : Cloud Sherpas, Inc.
** @date : 10/29/2014
** @story : 2343
** @element : E2390
** @description : If an account has a Parent Account then the Global HQ Account field is updated with the top parent of those accounts. The top parent account's Is Global HQ checkbox should be set to true.
** @paramaters : Account Id
** @returns : nothing
*/
public void CheckIsGlobalHQ(Account[] pNewAccounts, boolean isUpdate){
    final string METHODNAME = CLASSNAME.replace('METHODNAME','CheckIsGlobalHQ');
    system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
    //try{
        Set<Id> AccountGlobalHQAccount = new Set<Id>();
        set<Id> NewAccounts = new set<Id>();
        for(Account acc : pNewAccounts){
            if(acc.GlobalHQAccount__c != null){
                AccountGlobalHQAccount.add(acc.GlobalHQAccount__c);
            }
            NewAccounts.add(acc.Id);
        }
        List<Account> AccountToBeUpdated = new List<Account>();
        if(!AccountGlobalHQAccount.isEmpty()){
            //Jeff L added to fit into new query framework
            //for(Account acc : [SELECT Id,IsGlobalHQ__c FROM Account WHERE Id IN: AccountGlobalHQAccount]){
            for(Account acc : queryAccountList()){
                if(AccountGlobalHQAccount.contains(acc.Id) && acc.IsGlobalHQ__c != true){
                    acc.IsGlobalHQ__c = true;
                    System.debug('----Setting IsGlobalHQ__c true');

                    if(!isUpdate || (isUpdate && !NewAccounts.contains(acc.Id))){
                        AccountToBeUpdated.add(acc);
                    }
                }
            }
        }
        if(!AccountToBeUpdated.isEmpty()){
            AccountTriggerHandler.ExecuteTriggers = false;
            // Shyam 5/2 : S-475556 - Start
            try{
                update AccountToBeUpdated;
            }
            catch (DMLException e){
                for(Account acc : AccountToBeUpdated){
                    acc.addError(e.getMessage());
                }
            }
            // Shyam 5/2 : S-475556 - End
            AccountTriggerHandler.ExecuteTriggers = true;
        }
    /*}catch(Exception e){
        ExceptionLog.add(e.getTypeName(), CLASSNAME, METHODNAME, e.getMessage());
        throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Failed to update Global HQ Account to null. Please see system log for details.',e);
    }*/
}
/*
** @author : Cloud Sherpas, Inc.
** @date : 10/29/2014
** @story : 2343
** @element : E2390
** @description : If the Parent Account and child account relationshipis removed, then the flag should be unchecked.
** @paramaters : Accounts
** @returns : nothing
*/
public void uncheckIsGlobalHQCheckbox(Account[] pNewAccounts, map<ID, Account> pAccountIdToOldAccountMap){
    final string METHODNAME = CLASSNAME.replace('METHODNAME','uncheckIsGlobalHQCheckbox');
    system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
    try{
        Set<Id> ParentAccountIds = new Set<Id>();
        for(Account acc : pNewAccounts){
            if(pAccountIdToOldAccountMap.get(acc.Id).GlobalHQAccount__c != null && pAccountIdToOldAccountMap.get(acc.Id).ParentId == pAccountIdToOldAccountMap.get(acc.Id).GlobalHQAccount__c){
                ParentAccountIds.add(pAccountIdToOldAccountMap.get(acc.Id).GlobalHQAccount__c);
            }
        }
        List<Account> AccountToBeUpdated = new List<Account>();
        List<Account> queryAccountList = queryAccountList();
        if(!ParentAccountIds.isEmpty()){
            Map<Id, List<Account>> ChildAccountMap = new Map<Id,List<Account>>();
            //Jeff commeneted out for new query format 10/12
            //for(Account acc : [SELECT Id,IsGlobalHQ__c, GlobalHQAccount__c,ParentId FROM Account WHERE ParentId IN: ParentAccountIds ]){
            for(Account acc : queryAccountList){
                if(parentAccountIds.contains(acc.ParentId)){
                    if(acc.ParentId == acc.GlobalHQAccount__c){
                        if(ChildAccountMap.containsKey(acc.ParentId)){
                            ChildAccountMap.get(acc.ParentId).Add(acc);
                        }else{
                            ChildAccountMap.put(acc.ParentId, new List<Account>());
                            ChildAccountMap.get(acc.ParentId).add(acc);
                        }
                    }
                }
            }

            for(Account acc : queryAccountList){
                if(parentAccountIds.contains(acc.Id)){
                    if(ChildAccountMap.get(acc.Id).isEmpty()){
                        System.debug('----Setting IsGlobalHQ__c false');
                        acc.IsGlobalHQ__c = false;
                        AccountToBeUpdated.add(acc);
                    }
                }
            }
            /* Jeff L Commented out for new query formant 10/12 added logic to for loop above
            for(Account acc : [SELECT Id,IsGlobalHQ__c FROM Account WHERE Id IN: ParentAccountIds]){
                if(ChildAccountMap.get(acc.Id).isEmpty()){
                    acc.IsGlobalHQ__c = false;
                    AccountToBeUpdated.add(acc);
                }
            }*/
        }
        if(!AccountToBeUpdated.isEmpty()){
             AccountTriggerHandler.ExecuteTriggers = false;
            update AccountToBeUpdated;
             AccountTriggerHandler.ExecuteTriggers = true;
        }
    }catch(Exception e){
        ExceptionLog.add(e.getTypeName(), CLASSNAME, METHODNAME, e.getMessage());
        throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Failed to uncheck IsGlobalHQ checkbox on the parent Account. Please see system log for details.',e);
    }
}
/*
@author : Cloud Sherpas, Inc.
** @date : 06/05/2014
** @description : Updates the Parent account
** @paramaters :
** @returns : nothing
*/
public void UpdateParentThruDandBCompany1(Account[] pNewAccounts){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','UpdateParentThruDandBCompany');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            map<String, Account> parentAccountDunsNumberToAccount = new map<String, Account>();
            map<String, Account> parentAccountDunsNumberToAccountOld = new map<String, Account>();
            for(Account a : pNewAccounts){
                if (pNewAccounts.size() <= cutoff || a.Id == debugId){ //JFreese Appirio S-435483 4/11/17
                    system.debug('a.ParentCompanyDUNSNumber__c='+a.ParentCompanyDUNSNumber__c+', a.DunsNumber='+a.DunsNumber);
                }
                if(a.ParentCompanyDUNSNumber__c != null && a.ParentCompanyDUNSNumber__c != '' && (a.ParentCompanyDUNSNumber__c != a.DunsNumber)){
                    parentAccountDunsNumberToAccount.put(a.ParentCompanyDUNSNumber__c, a);
                    //parentAccountDunsNumberToAccountOld.put(a.ParentCompanyDUNSNumber__c, pAccountIdToOldAccountMap.get(a.Id));
                }
            }

            //Jeff L updated for new query framework 10/12
            //Account[] parentWithDuns = [SELECT Id, DunsNumber FROM Account WHERE ParentId = null AND DunsNumber IN :parentAccountDunsNumberToAccount.keySet()];
            List<Account> parentWithDuns = new List<Account>();
            for(Account a : queryAccountList()){
                if(a.parentId == null && parentAccountDunsNumberToAccount.containsKey(a.DunsNumber)){
                    parentWithDuns.add(a);
                }
            }

            if(parentWithDuns.size() == 0){
                system.debug('Exiting. No account has ParentCompanyDUNSNumber__c.');
                return; //stops when no account have ParentCompanyDUNSNumber__c
            }

            //checking of multiple accounts with DunsNumber
            map<String, Integer> dunsNumberToCount = new map<String, Integer>();
            for(Account pa : parentWithDuns){
                if(!dunsNumberToCount.containsKey(pa.DunsNumber)){
                    dunsNumberToCount.put(pa.DunsNumber, 1);
                }else{
                    Integer currentCount = dunsNumberToCount.remove(pa.DunsNumber) + 1;
                    dunsNumberToCount.put(pa.DunsNumber, currentCount);
                }
            }

            for(Account pa : parentWithDuns){
                Integer count = dunsNumberToCount.containsKey(pa.DunsNumber) ? dunsNumberToCount.get(pa.DunsNumber) : 10;
                if(parentAccountDunsNumberToAccount.containsKey(pa.DunsNumber) && count == 1){
                    parentAccountDunsNumberToAccount.get(pa.DunsNumber).ParentId = pa.Id;
                }
            }
        }catch(Exception bae){
        throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Failed to update parent account. Please see system log for details.',bae);
        }
    }

    /*
    ** @author : Cloud Sherpas, Inc.
    ** @date : 01/09/2015
    ** @story : 1724
    ** @element : E2153
    ** @description : If a Person Account is created from Email2Case Case record, relate the Person Account to Case via the Related_Case__pc field - JLaurio
    ** @paramaters : Accounts
    ** @returns : nothing
    */
    public void associatePersonAccountToRelatedCase(Account[] pNewAccounts, map<ID, Account> pAccountIdToOldAccountMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','associatePersonAccountToRelatedCase');
        Logger.push(METHODNAME, Schema.Contact.getSObjectType().getDescribe().getName());
        //try{
            map<String, map<String, Id>> AccountRecordTypes = Utility.GetRecordTypeIdsBySObjectNameSet(new set<string>{'Account'});
            Id personAccountRecordTypeId = AccountRecordTypes.get('Account').get('Person Account');
            Set<Id> caseIds = new Set<Id>();
            Map<Id, Case> accountToCaseMap = new Map<Id, Case>();
            List<Case> caseListForUpdate = new List<Case>();

            //collecting the Related Case Ids for query
            for(Account pAccount:pNewAccounts){
                if(pAccount.RecordTypeId == personAccountRecordTypeId && pAccount.Related_Case__pc!=null){
                    caseIds.add(pAccount.Related_Case__pc);
                }
            }

            if(caseIds.size()>0){
                List<Case> caseList = [SELECT Id, AccountId, ContactId FROM Case WHERE Id IN: caseIds];
                //associating the Person Account on to the Related Case
                for(Account pAccount:pNewAccounts){
                    for(Case pCase:caseList){
                        if(pAccount.Related_Case__pc == pCase.Id){
                            Case tempCase = pCase;
                            tempCase.AccountId = pAccount.Id;
                            caseListForUpdate.add(tempCase);
                        }
                    }
                }

                //DML call
                if(caseListForUpdate != null && !caseListForUpdate.isEmpty()){
                    CaseTriggerHandler.ExecuteTriggers = false;
                    update caseListForUpdate;
                }
            }
        /*}
        catch(Exception e){
            Logger.debugException('Failed to associate person account to related cases.'+' \n'+ e.getMessage());//Failed to associate to related cases.
            Logger.pop();
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to associate person account to related cases.'+' \n'+ e.getMessage() ,e);
        }*/
    }
/*
** @author : Adarsh
** @date : 07/06/2015
** @story :
** @Issue : I-167039
** @description : Insert Customer Number for new Account created through Site
** @paramaters : list of Accounts[]
** @returns : nothing
*/
    //AP commented out S-445792
   /* public void insertCustomerNumberforAccounts(Account[] pNewAccounts){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','insertCustomerNumberforAccounts');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            Set<Id> AccountIds = new Set<Id>();
            List<Account> insertCus = new List<Account>();
            //List<Account> accList = [select CustomerNumber__c, AccountStatus__c, CustomerDate__c  from account where Id in: pNewAccounts];
            //system.debug('accList' + accList);
            //system.debug('accList.CustomerNumber' + accList.CustomerNumber__c);
            //if(!accList.CustomerNumber
                for(Account acc: pNewAccounts){
                //for(Account acc : accList){
                        AccountIds.add(acc.Id);
                        system.debug('AccountId' + AccountIds);
                        if(!AccountIds.isEmpty()){
                            if(acc.CustomerNumber__c == null){
                                system.debug('calculation' + Math.round((Math.random() * 10000000) + 1));
                                //acc.CustomerNumber__c = 'CUS' + '_' + Double.valueOf(Math.floor((Math.random() * 10000000) + 1));
                                //Integer rand = Math.round((Math.random() * 10000000) + 1);
                                //acc.CustomerNumber__c = 'CUS' + '-' + rand;
                                Integer rand = Math.round((Math.random() * 10000000) + 1);
                                String srand = string.valueof(rand);
                                system.debug('srand' + srand);
                                acc.CustomerNumber__c = srand;
                                system.debug('accCustomerNumber' + acc.CustomerNumber__c);
                                acc.CustomerDate__c=Date.Today();
                                system.debug('CustomerDate' + acc.CustomerDate__c);
                                //if(acc.AccountStatus__c == 'Candidate')
                                //{
                                  acc.AccountStatus__c = 'Customer';
                                  system.debug('AccountStatus' + acc.AccountStatus__c);
                                //}
                                system.debug('acc.CustomerNumber' + acc.CustomerNumber__c);
                                //insertCus.add(acc);
                                //system.debug('insertCus' + insertCus);
                            }
                        }
                }

        }catch(Exception bae){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Failed to update customer number. Please see system log for details.', bae);
        }
    }*/

    //T-429332 created by Appirio
    /* // Not used anywhere
    public void setAccountFieldsNull(List<Account> accList) {
        for(Account acc : accList){
            if(acc.DunsNumber == '' || acc.DunsNumber == null){
                acc.DandbCompany = null;
                acc.AnnualRevenue = null;
                acc.TickerSymbol ='';
                acc.Website = '';
                acc.Industry = '';
                acc.Ownership = '';
                acc.Phone = '';
                acc.Fax = '';
                acc.Site = '';
                acc.Tradestyle = '';
                acc.YearStarted = '';
                acc.Sic = '';
                acc.SicDesc = '';
                acc.NaicsCode = '';
                acc.NaicsDesc = '';
                acc.Description = '';
                acc.NumberOfEmployees = null;
            }
        }
    }
*/
    //T-429334 created by Appirio
    //TKOM - S-445899 - commenting out entire method - emails sent by workflow instead
    /*public void sendEmailWhenAccountStatusChange(List<Account> accList, map<ID, Account> pAccountIdToNewAccountMap, map<ID, Account> pAccountIdToOldAccountMap) {
        final string METHODNAME = CLASSNAME.replace('METHODNAME','sendEmailWhenAccountStatusChange');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Set<Id> activeId = new Set<Id>();
        Set<Id> rejectedId = new Set<Id>();
        Set<Id> fullAccSet = new Set<Id>();
         map<String, map<String, Id>> CaseRecordTypes = Utility.GetRecordTypeIdsBySObjectNameSet(new set<string>{'Case'});
     Id NewAccountReqRT = CaseRecordTypes.get('Case').get('New Account Request');
        for(Account acc : accList){
            if(acc.Lead_Account_Status__c != pAccountIdToOldAccountMap.get(acc.Id).Lead_Account_Status__c ){
                if(acc.Lead_Account_Status__c == 'Active'){
                    activeId.add(acc.Id);
                    fullAccSet.add(acc.Id);
                } else if(acc.Lead_Account_Status__c == 'Rejected'){
                    rejectedId.add(acc.Id);
                    fullAccSet.add(acc.Id);
                }
            }
        }
        map<Id, Case> mapCaseWithActiveAcccount = new map<Id, Case>();
        map<Id, Case> mapCaseWithRejectedAcccount = new map<Id, Case>();
        //Jeff L commented out to consolidate queries 10/13
        /*for(Case cse : [SELECT Id, AccountId, CreatedBy.Email,Account_Name__c,account.AccountID__c FROM Case WHERE recordtypeId = :NewAccountReqRT AND AccountID IN : activeId ]){
            mapCaseWithActiveAcccount.put(cse.AccountId, cse);
        }

        for(Case cse : [SELECT Id,AccountId, CreatedBy.Email,Account_Name__c,account.AccountID__c FROM Case WHERE recordtypeId = :NewAccountReqRT AND AccountID IN : rejectedId]){
            mapCaseWithRejectedAcccount.put(cse.AccountId, cse);
        }*/
    /*
        for(Case cse : [SELECT Id,AccountId, CreatedBy.Email,Account_Name__c,account.AccountID__c FROM Case WHERE recordtypeId = :NewAccountReqRT AND AccountID IN : fullAccSet]){
            if(activeId.contains(cse.AccountId)){
                mapCaseWithActiveAcccount.put(cse.AccountId, cse);
            }
            if(rejectedId.contains(cse.AccountId)){
                mapCaseWithRejectedAcccount.put(cse.AccountId, cse);
            }
        }

        Messaging.SingleEmailMessage mail = null;
        List<String> sendTo = null;
        //Jeff L added this check - UserInfo.getUserId() fails when the data.com clean is run (data.com user must not
        //have a userId or something)
        List<User> currentuserlst=[SELECT Email,Name FROM User WHERE Id= :UserInfo.getUserId()];
        if(currentuserlst.size() > 0 ){
            User currentuser = currentuserlst[0];
            String caseAccountId = null;
            for(Id accountId : mapCaseWithActiveAcccount.keySet()){
                mail = new Messaging.SingleEmailMessage();
                sendTo = new List<String>();
                String email = mapCaseWithActiveAcccount.get(accountId ).CreatedBy.Email;
                sendTo.add(email);
                mail.setToAddresses(sendTo);

                mail.setReplyTo(currentuser.Email);
                mail.setSenderDisplayName(currentuser.Name);

                mail.setSubject('Account Created/Approve '+mapCaseWithActiveAcccount.get(accountId ).Account_Name__c );
                 if(mapCaseWithActiveAcccount.get(accountId) != null){
                    caseAccountId = mapCaseWithActiveAcccount.get(accountId).account.AccountID__c;
                 }
                String body = 'Hi, Your request to create a new account for '+mapCaseWithActiveAcccount.get(accountId ).Account_Name__c +' has been completed. Account <a target="_blank" href="' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + accountId +'" rel="nofollow">'+ caseAccountId +'</a> was created.??';
                mail.setHtmlBody(body);
                mails.add(mail);
        }
        for(Id accountId : mapCaseWithRejectedAcccount.keySet()){
            mail = new Messaging.SingleEmailMessage();
            sendTo = new List<String>();
            String email = mapCaseWithRejectedAcccount.get(accountId ).CreatedBy.Email;
            sendTo.add(email);
            mail.setToAddresses(sendTo);

            mail.setReplyTo(currentuser.Email);
            mail.setSenderDisplayName(currentuser.Name);

            mail.setSubject('Account Request Rejected: '+mapCaseWithRejectedAcccount.get(accountId ).Account_Name__c );

            String body ='Your request to create a new account for '+mapCaseWithRejectedAcccount.get(accountId ).Account_Name__c +' has been rejected';
            mail.setHtmlBody(body);
            mails.add(mail);
        }
        Messaging.sendEmail(mails);
        }
    }
    */

    /*
    ** @author : Appirio
    ** @date : 07/02/2015
    ** @description : T-416900: on before insert of lead convert, update the posting (shipping) address from lead
    ** @paramaters : trigger.new, trigger.newmap
    ** @returns : void
    */
    public void updatePostingAddressFromLeadConvert(List<Account> newAccounts, map<ID, Account> newMap)
    {
        //get a list of lead ids
        Set<Id> leadIds = new Set<Id>();
        for(Account acc : newAccounts){
            if(acc.LeadId__c != null){
                leadIds.add(Id.valueOf(acc.LeadId__c));
            }
        }
        if(leadIds.isEmpty()) return;

        //get the lead data as a map of lead id to lead
        Map<Id,Lead> leadMap =
        new Map<Id,Lead>([select id, Posting_City__c,
            Posting_Country__c,
            Posting_State_Province__c, Posting_Street__c, Posting_Zip_Postal_Code__c from lead where id in :leadIds]);

            Profile ProfileName = [select Name from profile where id = :userinfo.getProfileId()];


        //update the shipping address from lead data
        Org_Settings__c orgSettings = Org_Settings__c.getInstance();
        for(Account acc : newAccounts)
        {    //acc.recordTypeId = '012G00000010ffv' ;
            //system.assert(false , acc.LeadId__c);

            if((acc.LeadId__c != null) && (leadMap.containsKey(acc.LeadId__c)))
            {
                Lead converted = leadMap.get(acc.LeadId__c);
                acc.ConvertedFromLead__c = true ; ////added for /I-219837 - Deepanshu Soni Appirio
                if(converted.Posting_City__c != null ||
                   converted.Posting_Country__c != null ||
                   converted.Posting_State_Province__c != null ||
                   converted.Posting_Street__c != null ||
                   converted.Posting_Zip_Postal_Code__c != null)
                {   //system.assert(false , converted.Posting_City__c);
                    acc.ShippingCity = converted.Posting_City__c;
                    acc.ShippingCountry = converted.Posting_Country__c;
                    acc.ShippingState = converted.Posting_State_Province__c;
                    acc.ShippingStreet = converted.Posting_Street__c;
                    acc.ShippingPostalCode = converted.Posting_Zip_Postal_Code__c;
                    //I-190978 : Account Status on Converted Lead must be Lead
                    if(ProfileName.Name == orgSettings.Sales_Rep_NA__c ||
                       //ProfileName.Name == orgSettings.Sales_Rep_EU__c ||
                       ProfileName.Name == orgSettings.Sales_Rep_Agency_EU__c ||
                       /* S-445851 >> For Sales rep APAC, account status cannot be Lead
                          so commented following line By Vikas Menon 23 Nov 2016*/
                       //ProfileName.Name == orgSettings.Sales_Rep_APAC__c ||
                       ProfileName.Name == orgSettings.Sales_Manager_NA__c ||
                       ProfileName.Name == orgSettings.Sales_Manager_EU__c ||
                       ProfileName.Name == orgSettings.Sales_Manager_APAC__c||
                       ProfileName.Name == orgSettings.Sales_Operations_TA__c||
                       ProfileName.Name == orgSettings.Telemarketing_Inbound__c||
                       ProfileName.Name == orgSettings.Sales_Operations_EU__c||
                       ProfileName.Name == orgSettings.Sales_Operations_TA_EU__c
                    ){
                        acc.AccountStatus__c = 'Lead';
                     }
                }
                else //if the posting address on lead is null, update the account posting address from account billing address
                {
                    acc.ShippingCity = acc.BillingCity;
                    acc.ShippingCountry = acc.BillingCountry;
                    acc.ShippingState = acc.BillingState;
                    acc.ShippingStreet = acc.ShippingStreet;
                    acc.ShippingPostalCode = acc.ShippingPostalCode;
                    // I-190978 : Account Status on Converted Lead must be Lead
                    if(ProfileName.Name == orgSettings.Sales_Rep_NA__c ||
                       //ProfileName.Name == orgSettings.Sales_Rep_EU__c ||
                       ProfileName.Name == orgSettings.Sales_Rep_Agency_EU__c ||
                       /* S-445851 >> For Sales rep APAC, account status cannot be Lead
                          so commented following line By Vikas Menon 23 Nov 2016*/
                       //ProfileName.Name == orgSettings.Sales_Rep_APAC__c ||
                       ProfileName.Name == orgSettings.Sales_Manager_NA__c ||
                       ProfileName.Name == orgSettings.Sales_Manager_EU__c ||
                       ProfileName.Name == orgSettings.Sales_Manager_APAC__c||
                       ProfileName.Name == orgSettings.Sales_Operations_TA__c||
                       ProfileName.Name == orgSettings.Telemarketing_Inbound__c||
                       ProfileName.Name == orgSettings.Sales_Operations_EU__c||
                       ProfileName.Name == orgSettings.Sales_Operations_TA_EU__c
                    ){
                        acc.AccountStatus__c = 'Lead';
                    }
                }
            }
            system.debug('LEAD ACCOUNT status'+acc.AccountStatus__c);
            system.debug('LEAD ACCOUNT leadstatus'+acc.Lead_Account_Status__c);
        }
    }



    // T-414735 - Check permission for creating account directly without conversion
    //Created by Appirio
    public void validateCreateAccountPermission(List<Account> accList) {
        if(PermissionCheck.hasPermission('Create_Accounts_Directly') == false){
            for(Account acc : accList){
                if(!acc.ConvertedFromLead__c && !acc.IsPersonAccount){
                    acc.addError('This User is not allowed to create Account Directly, Accounts can be created from Lead conversion only');
                }
            }
        }
    }

    /*
    ** @author : ?
    ** @date :
    ** @description : Jeff L moved this code from Trigger Handler to the helper
    ** @paramaters : list of accounts
    ** @returns : void
    */

    public void UpdatePhoneNumberFormat(Account[] pUpdatedAccounts){
        for(Account acc: pUpdatedAccounts){
            // Fix Phone Number Formating +1.555.555.1212 to (555) 555-1212 -- S-313135
            String acc1 = '';
            String acc2 = '';
            String acc3 = '';
            if (acc.Phone != NULL) {
                if (acc.Phone.startsWith('+1.'))  {
                    acc.Phone = acc.Phone.substring(3);
                    acc1 = acc.Phone;
                    acc2 = acc.Phone;
                    acc3 = acc.Phone;
                    acc1 = acc1.substringBefore('.');
                    acc2 = acc2.substringBetween('.');
                    acc3 = acc3.substringAfterLast('.');
                    acc.Phone = '(' + acc1 + ') ' + acc2 + '-' + acc3;
                }
            }
        }
    }
/*
** @author : Adarsh
** @date : 02/22/2016
** @story :
** @Issue : I-197888
** @description : Populate primary sales rep on account
** @paramaters : list of Accounts[]
** @returns : nothing
*/
/*public void PopulateEcommPrimarySalesRep(Account[] pNewAccountList){
            final string METHODNAME = CLASSNAME.replace('METHODNAME','PopulateEcommPrimarySalesRep');
            system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
            Set<String> AccountIds= new Set<String>();
            Set<String> ShipAccCountry = new Set<String>();
            Set<String> xAccountIds = new Set<String>();
            Set<String> TAssign = new Set<String>();
            try{
                for(Account Acc: pNewAccountList){
                    AccountIds.add(Acc.Primary_Xcode__c);
                    system.debug('AccountIds'+ AccountIds);
                    ShipAccCountry.add(Acc.ShippingCountry__c);
                    system.debug('ShippingAccCountry'+ ShipAccCountry);
                }
                List<XcodeAccount__c> xaccList = [select Xcode_Employees__c from XcodeAccount__c where Xcode_Name__c in: AccountIds AND Xcode_Employees__c != null limit 1];
                for(XcodeAccount__c xAcc: xaccList){
                    xAccountIds.add(xAcc.Xcode_Employees__c);
                    system.debug('xAccountIds' + xAccountIds);
                }
                List<TerritoryAssignmentCode__c> TacList = [select TerritoryAssignment__c from TerritoryAssignmentCode__c where
                                                            (AccountCountry__c != null AND AccountCountry__c in: ShipAccCountry) OR
                                                            (Employee_Size_Code__c != null AND Employee_Size_Code__c in: xAccountIds)];
                for(TerritoryAssignmentCode__c Tassigned: TacList){
                    TAssign.add(Tassigned.TerritoryAssignment__c);
                    system.debug('TAssign'+ TAssign);
                }
                List<TerritoryAssignment__c> TassignList = [select OwnerId,Owner.Name from TerritoryAssignment__c where Id in: TAssign LIMIT 1];
                for(TerritoryAssignment__c Tassignment: TassignList)
                {
                    for(Account Acnt: pNewAccountList){
                        system.debug('TassignmentOwnerId' + Tassignment.OwnerId);
                        Acnt.OwnerId = Tassignment.OwnerId;
                        system.debug('AcntOwner' + Acnt.OwnerId);
                        system.debug('TassignmentOwner' + Tassignment.Owner.Name);
                    }

                }
            } catch(Exception bae){
                throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Failed to update PrimarySalesRep. Please see system log for details.', bae);
            }
    }*/

/*
** @author : Jeff L (Appirio)
** @date : 06/17/16
** @description : Populate the Account Size on the account, only gets used for Mapp Integration
** @paramaters : list of Accounts, map of old accounts
** @returns : nothing
** @modification : S-432850 - Account Size field shall no longer update based upon value inserted into D&B Employees Total
   Account Size field shall now update upon account create based upon value pulled into the 'Site Number of Employees' field.
** @Modified by : Deepanshu Soni (Appirio)
** @Modification Date : 09/28/016
*/
    public void updateAccountSizeForMapp(List<Account> pAccountList, Map<Id,Account> pOldAccountsMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateAccountSizeForMapp');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        List<Account> accToProccess = new List<Account>();
        for(Account acc : pAccountList){
            //this means we are in an insert trigger
            if(pOldAccountsMap == null){
                accToProccess.add(acc);
            } else if(acc.Site_Number_of_Employees__c != pOldAccountsMap.get(acc.Id).Site_Number_of_Employees__c){
                //if(acc.DBEmployeeTotal__c != pOldAccountsMap.get(acc.Id).DBEmployeeTotal__c){
                //this means we are in an update
                system.debug('in update with account ' + acc.Id);
                accToProccess.add(acc);
            }
        }
       map<String,Integer> accSizeRange = new map<String,Integer>();
        // 1 - Small Business
        // 2 - Mid Market
        // 3 - Enterprise
        accSizeRange.put('1-9', 1);
        accSizeRange.put('10-19', 1);
        accSizeRange.put('20-49', 1);
        accSizeRange.put('50-99', 1);
        accSizeRange.put('100-499', 2);
        accSizeRange.put('500-999', 2);
        accSizeRange.put('1000-1499', 3);
        accSizeRange.put('1500-1999', 3);
        accSizeRange.put('2000-2499', 3);
        accSizeRange.put('2500-4999', 3);
        accSizeRange.put('5000-9999', 3);
        accSizeRange.put('10000+', 3);
        for(Account accProc : accToProccess){
            system.debug('====accProc====='+ accProc);
            if(accSizeRange.get(accProc.Site_Number_of_Employees__c) == 1){
               accProc.Account_Size__c = 'Small Business';
               accProc.NOE_Override__c = true;
            }
            else if(accSizeRange.get(accProc.Site_Number_of_Employees__c) == 2){
                accProc.Account_Size__c = 'Mid Market';
                accProc.NOE_Override__c = true;
            }
            else if(accSizeRange.get(accProc.Site_Number_of_Employees__c) == 3){
                accProc.Account_Size__c = 'Enterprise';
                accProc.NOE_Override__c = true;
            }
        }
        /*for(Account accProc : accToProccess){
            if(accProc.DBEmployeeTotal__c <= 99){
                accProc.Account_Size__c = 'Small Business';
                accProc.NOE_Override__c = true;
            }
            else if(accProc.DBEmployeeTotal__c > 99 && accProc.DBEmployeeTotal__c <=999){
                accProc.Account_Size__c = 'Mid Market';
                accProc.NOE_Override__c = true;
            }
            else if(accProc.DBEmployeeTotal__c > 999){
                accProc.Account_Size__c = 'Enterprise';
                accProc.NOE_Override__c = true;
            }

            system.debug('whats my account size' + accProc.Account_Size__c);
        }*/
    }

    /*
    ** @author : Shyam S (Appirio)
    ** @date : 07/25/16
    ** @description : T-521921 - Update Hierarchy Lock Field, and set true for Manual updation, so that in Data.com process, ParentId couldnot be updated.
    ** @paramaters : Update Hierarchy Lock Field
    ** @returns : nothing
    */
    public void updateHierarchyLock(List<Account> pAccountList, Map<Id,Account> pOldAccountsMap){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateHierarchyLock');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        List<Account> accToProccess = new List<Account>();
        for(Account acc : pAccountList){
            if(acc.Hierarchy_Locked__c && acc.ParentId != pOldAccountsMap.get(acc.Id).ParentId &&
                (UserInfo.getFirstName() == 'Data.com' || acc.CleanStatus != pOldAccountsMap.get(acc.Id).CleanStatus)){

                acc.ParentId = pOldAccountsMap.get(acc.Id).ParentId;
            }
            else if(UserInfo.getFirstName() != 'Data.com' && acc.CleanStatus == pOldAccountsMap.get(acc.Id).CleanStatus
                        && acc.ParentId != pOldAccountsMap.get(acc.Id).ParentId){
                acc.Hierarchy_Locked__c = true;
            }
        }
    }
/**
* @author Adarsh
* @date  10.12.2016
* @story S-445792/
I-242289
*/
    public void populateEcommCustomerNumber(Account[] pNewAccounts){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populateEcommCustomerNumber');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{

            List<Account> AccountsToBeUpdated  = new List<Account>();
            for(Account ac : pNewAccounts){
                    system.debug('ac.CustomerNumber__c' +ac.CustomerNumber__c);
                    if(ac.CustomerNumber__c == null){
                        Account acc = new Account();
                        acc.id = ac.id;
                        //if(acc.CustomerNumber__c != null){
                            acc.AccountStatus__c = 'Customer';
                            acc.CustomerDate__c = Date.Today();
                            acc.CustomerNumber__c =  ac.AutoCustomerNumber__c;
                            AccountsToBeUpdated.add(acc);
                    }
            }

            if(!AccountsToBeUpdated.isEmpty()){
                // AccountTriggerHandler.ExecuteTriggers = false;
                 update AccountsToBeUpdated;
                //AccountTriggerHandler.ExecuteTriggers = true;
            }
        }catch(Exception e){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Failed to populate Ecomm Account customer number. Please see system log for details.', e);
        }

    }

    //Sberron - S-445815 - 12/28/16
    //Populates IsGlobalHQ__c if the account has children and no parent
    public void populateIsGlobalHQ(Account[] accList) {
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populateIsGlobalHQ');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        List<Account> childAccs = new List<Account>([SELECT Id, Name, ParentId FROM Account WHERE ParentId IN :accList AND ParentId != null]);
        Set<Id> parentAccs = new Set<Id>();
        System.debug('----childAccs ' + childAccs);
        for (Account a : childAccs) {
            if (!parentAccs.contains(a.ParentId)) {
                parentAccs.add(a.ParentId);
            }
        }

        for (Account a : accList) {
            if (parentAccs.contains(a.Id) && a.ParentId == null) {
                a.IsGlobalHQ__c = true;
            }
        }
    }
}