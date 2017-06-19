public with sharing class TerritoryBatchHelper {
    final String CLASSNAME = '\n\n**** AccountTriggerHelper.METHODNAME()';
    
    public TerritoryBatchHelper(){
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

        try{
            Set<Id> accnId = new Set<Id>();
            for(Account a : pUpdatedAccounts){
                if(!a.DoNotReassign__c ){
                    accnId.add(a.Id);
                }
            }
            List<Account> newAccountList = [SELECT ShippingStreet,Phone,AccountStatus__c,ShippingCity,ShippingState,CustomerNumber__c,CustomerDate__c,CustomerLapsedDate__c,Id, TerritoryCode__c, ShippingPostalCode,ShippingCountry, BillingPostalCode,AccountGroup__c, SalesChannel__c,Segment__c, OwnerId, AccountID__c FROM Account WHERE Id in : accnId];
            List<TerritoryAssignmentCode__c> territoryCodeList = [SELECT AccountCountry__c, AccountGroup__c,
                                                                        NamedAccount__c, SalesChannel__c,Segment__c,
                                                                        PostingZipCodeStart__c, PostingZipCodeEnd__c,
                                                                        TerritoryAssignment__c, TerritoryAssignment__r.OwnerId
                                                                  FROM TerritoryAssignmentCode__c];
            

            List<Account> accToUpdate = new List<Account>();
            Boolean changeTeamMember = false;
                                                                  
            for(Account acc : newAccountList){
                Boolean named = false;
                Boolean zipCodeRange = false;
                for(TerritoryAssignmentCode__c tac : territoryCodeList){
                    if(acc.AccountID__c != null && acc.AccountID__c == tac.NamedAccount__c){
                        system.debug('%%'+pUpdatedAccounts);
                        acc.OwnerId = tac.TerritoryAssignment__r.OwnerId;
                        acc.TerritoryCode__c = tac.TerritoryAssignment__c;
                        named = true;
                    }
                }
                if(!named){
                    for(TerritoryAssignmentCode__c tac : territoryCodeList){
                    zipCodeRange = checkZipcode(acc, tac);
                        if((acc.ShippingCountry != null && acc.ShippingCountry == tac.AccountCountry__c) 
                            || (acc.AccountGroup__c != null && acc.AccountGroup__c == tac.AccountGroup__c)
                            || (acc.SalesChannel__c != null && acc.SalesChannel__c == tac.SalesChannel__c)
                            || (acc.ShippingPostalCode != null && zipCodeRange)){
                            acc.OwnerId = tac.TerritoryAssignment__r.OwnerId;
                            acc.TerritoryCode__c = tac.TerritoryAssignment__c;
                        }
                    }
                }
                if(acc.TerritoryCode__c != null){
                    accToUpdate.add(acc);
                }
            }
            if(accToUpdate.size() > 0){
                SetSendToEmailFlag.fromTerritory = true;
              
                Database.SaveResult[] srList = Database.update(accToUpdate, false);
                
                for(Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                    } else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                        }
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
    public Boolean checkZipcode(Account zAccount, TerritoryAssignmentCode__c zTerritory){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','checkZipcode');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '****  Inside '));

        try{
            Boolean inRange = false;
            String[] zipAccount = new String[]{};
            String[] zipStart = new String[]{};
            String[] zipEnd = new String[]{};

            if(zAccount.ShippingPostalCode != null){
                zipAccount = zAccount.ShippingPostalCode.split('-');
                if(zipAccount.size() == 1){
                    zipAccount.add('0000');
                }
            } else {
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
            system.debug('>>zipAccount'+ zipAccount);
            system.debug('>>zipStart'+ zipStart);
            system.debug('>>zipEnd'+ zipEnd);
            if(zTerritory.PostingZipCodeStart__c == null && zTerritory.PostingZipCodeEnd__c == null){
                inRange = false;
            } else if(zTerritory.PostingZipCodeStart__c != null && zTerritory.PostingZipCodeEnd__c == null){
                if(integer.valueof(zipAccount[0]) == integer.valueof(zipStart[0]) && integer.valueof(zipAccount[1]) == integer.valueof(zipStart[1])){
                    inRange = true;
                } else {
                    inRange = false;
                }
            } else if(zTerritory.PostingZipCodeStart__c == null && zTerritory.PostingZipCodeEnd__c != null){
                if(integer.valueof(zipAccount[0]) == integer.valueof(zipEnd[0]) && integer.valueof(zipAccount[1]) == integer.valueof(zipEnd[1])){
                    inRange = true;
                } else {
                    inRange = false;
                }
            } else {
                if(integer.valueof(zipAccount[0]) >= integer.valueof(zipStart[0]) && integer.valueof(zipAccount[0]) <= integer.valueof(zipEnd[0])){
                    if(integer.valueof(zipAccount[1]) >= integer.valueof(zipStart[1]) && integer.valueof(zipAccount[1]) <= integer.valueof(zipEnd[1])){
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
    } 
}