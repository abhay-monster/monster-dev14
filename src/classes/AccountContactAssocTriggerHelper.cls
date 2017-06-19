public with sharing class AccountContactAssocTriggerHelper {
  final String CLASSNAME = '\n\n**** AccountContactAssocTriggerHelper.METHODNAME()';
    private String UserProfileName{get; private set;}
    
/*
** @author : Cloud Sherpas Inc.
** @date : 04/17/2014
** @description : static method that instantiates a new instance of the class & sets the user's profile name member variable
** @paramaters : a string - the profile name for the current user
** @returns : a new instance of the AccountTriggerHelper class
*/
    public static AccountContactAssocTriggerHelper NewTriggerHelper(String pUserProfileName){
        
        //final string METHODNAME = CLASSNAME.replace('METHODNAME','NewTriggerHelper');
        //system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        AccountContactAssocTriggerHelper newHelper = new AccountContactAssocTriggerHelper(pUserProfileName);
        return newHelper;
    }
    
/*
** @author : Cloud Sherpas, Inc.
** @date : 04/09/2014
** @description : this method is the class constructor
** @paramaters : String user profile name
** @returns : nothing
*/
    private AccountContactAssocTriggerHelper(String pUserProfileName){  
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','AccountContactAssocTriggerHelper');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        UserProfileName = pUserProfileName;
    }
    
/*
** @author : Cloud Sherpas, Inc.
** @date : 07/16/2014
** @story : 0709
** @element : E1803
** @description : Checks if there's already a primary sales contact in an account 
** @paramaters : Map of AccountContactAssociation__c 
** @returns : nothing
*/   
    public void validatePrimarySalesContact(List<AccountContactAssociation__c> pUpdatedAccounts){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','validatePrimarySalesContact');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        Set<Id> accountSet = new  Set<Id>();
        for(AccountContactAssociation__c aca : pUpdatedAccounts){
            if(aca.PrimarySalesContact__c == true){
                accountSet.add(aca.Account__c);
            }
        }
        //Checks if one of the contact is Primary sales Rep
        Map<Id,Id> contactPrimarySalesContactMap = new Map<Id,Id>();
        if(!accountSet.isEmpty()){
            for(Contact con : [SELECT Id, AccountId, PrimarySalesContact__c FROM Contact WHERE AccountId IN: accountSet]){
                if(con.PrimarySalesContact__c == true){
                    contactPrimarySalesContactMap.put(con.AccountId,con.Id);
                }
            }
        }
        //Checks if one of the related contact is already a primary sales contact
        Map<Id,Id> relContactPrimarySalesContactMap = new Map<Id,Id>();
        if(!accountSet.isEmpty()){
            for(AccountContactAssociation__c aca : [SELECT Id, Account__c, PrimarySalesContact__c FROM AccountContactAssociation__c WHERE Account__c IN: accountSet]){
                if(aca.PrimarySalesContact__c == true){
                    relContactPrimarySalesContactMap.put(aca.Account__c,aca.Id);
                }
            }
        }
        for(AccountContactAssociation__c aca : pUpdatedAccounts){
            if(aca.PrimarySalesContact__c == true){
                if(contactPrimarySalesContactMap.get(aca.Account__c) != null || relContactPrimarySalesContactMap.get(aca.Account__c) != null){
                    aca.addError('There is an existing Primary Sales Contact for the selected account.');
                }
            }
        }
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 07/16/2014
** @story : 0709
** @element : E1803
** @description : Checks if the created related contact is the only one contact for account.
** @paramaters : Map of AccountContactAssociation__c 
** @returns : nothing
*/   
    public void SetPrimarySalesContact(List<AccountContactAssociation__c> pAccounts){
        SObject[] twoObj;
        set<Id> AccountIds = new Set<Id>();
        for(AccountContactAssociation__c aca : pAccounts){
            AccountIds.add(aca.Account__c);
        }
        map<Id,Id> AccountPrimarySalesContactMap = new map<Id,Id>();
        List<Contact> AccountContactList;
        List<AccountContactAssociation__c> AccountACAList;
        if(!AccountIds.isEmpty()){
            AccountContactList =[SELECT Id, AccountId, PrimarySalesContact__c FROM Contact WHERE AccountId IN: AccountIds];
            AccountACAList =[SELECT Id, Account__c, PrimarySalesContact__c FROM AccountContactAssociation__c WHERE Account__c IN: AccountIds];
        } 
        for(AccountContactAssociation__c aca : pAccounts){
            if(AccountContactList.isEmpty() && AccountACAList.isEmpty()){
                aca.PrimarySalesContact__c = true;
            }
        }   
    } 
    
     // There should not be duplicate contact  under Account related list- Related contact
    public void checkDupeContact(List<AccountContactAssociation__c> pAccounts) {

        Set<Id> contactIdSet = new  Set<Id>();
        map<String,AccountContactAssociation__c> mapAccountAssociation = new  map<String,AccountContactAssociation__c>();
        String key = null;
        for(AccountContactAssociation__c aca : pAccounts){
            if(aca.Contact__c != null){
                contactIdSet.add(aca.Contact__c);
            }
        }


        for(AccountContactAssociation__c aca : [Select Id,Name,Contact__c, Account__c from AccountContactAssociation__c Where Contact__c IN :contactIdSet]){
            key = aca.Contact__c + '~' + aca.Account__c;
            mapAccountAssociation.put(key, aca);
        }

        for(AccountContactAssociation__c aca : pAccounts){

            key = aca.Contact__c + '~' + aca.Account__c;
            if(mapAccountAssociation.containsKey(key)){
                AccountContactAssociation__c rec = mapAccountAssociation.get(key);
                aca.addError('Duplicate record found. There is an already Account Contact Association record :: '+ rec.Name);
            }

        }

    }
}