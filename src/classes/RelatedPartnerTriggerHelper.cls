/*
** @author : Cloud Sherpas Inc.
** @date : 03/20/2014
** @description :   class that supports the OpportunityTriggerHelper class; it provides the methods called from those classes
*/
public with sharing class RelatedPartnerTriggerHelper
{
    final String CLASSNAME = '\n\n**** RelatedPartnerTriggerHelper.METHODNAME()';

    // ********* PROPERTIES ***********
    private String UserProfileName{get; private set;}

/*
** @author : Cloud Sherpas Inc.
** @date : 03/20/2014
** @description : static method that instantiates a new instance of the class & sets the user's profile name member variable
** @paramaters : a string - the profile name for the current user
** @returns : a new instance of the RelatedPartnerTriggerHelper class
*/
    public static RelatedPartnerTriggerHelper NewTriggerHelper(String pUserProfileName){

        //final string METHODNAME = CLASSNAME.replace('METHODNAME','NewTriggerHelper');
        //system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        RelatedPartnerTriggerHelper newHelper = new RelatedPartnerTriggerHelper(pUserProfileName);
        return newHelper;
    }

/*
** @author : Cloud Sherpas Inc.
** @date : 03/20/2014
** @description : static method that instantiates a new instance of the class
** @paramaters : nothing
** @returns : a new instance of the RelatedPartnerTriggerHelper class
*/
    public static RelatedPartnerTriggerHelper NewTriggerHelper(){

        //final string METHODNAME = CLASSNAME.replace('METHODNAME','NewTriggerHelper');
        //system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        RelatedPartnerTriggerHelper newHelper = new RelatedPartnerTriggerHelper('');
        return newHelper;
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 03/20/2014
** @description : this method is the class constructor
** @paramaters : String user profile name
** @returns : nothing
*/
    private RelatedPartnerTriggerHelper(String pUserProfileName){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','RelatedPartnerTriggerHelper');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        UserProfileName = pUserProfileName;
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 03/27/2014
** @description : this method is the class constructor
** @paramaters : String user profile name
** @returns : nothing
*/
    private set<Id> CreateAccountIdSet(list<sObject> pSObjectList){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','CreateAccountIdSet');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        set<Id> accountIdSet = new set<Id>();

        list<RelatedPartner__c> relatedPartnerList = (list<RelatedPartner__c>)pSObjectList;

        for(RelatedPartner__c relatedPartner : relatedPartnerList){
            accountIdSet.Add(relatedPartner.Account__c);
        }

        return accountIdSet;
    }

    private set<Id> getAccountIdForAgency(list<sObject> pSObjectList){
        list<RelatedPartner__c> relatedPartnerList = (list<RelatedPartner__c>)pSObjectList;
        map<string,string> mapRelatedPartner = new map<string,string>();
        set<Id> accIdToUpdate = new set<Id>();
        for(RelatedPartner__c relatedPartner : relatedPartnerList){
            mapRelatedPartner.put(relatedPartner.Id,relatedPartner.Account__c);
        }
        map<Id,Account> accMap = new map<Id,Account>([Select Id,PrimaryRelatedAgency__c
                                                      from Account Where Id IN :mapRelatedPartner.values()]);
        for(RelatedPartner__c relatedPartner : relatedPartnerList){
            Account acc = accMap.get(mapRelatedPartner.get(relatedPartner.Id));
            if(acc.PrimaryRelatedAgency__c == null || acc.PrimaryRelatedAgency__c == relatedPartner.Id){
                accIdToUpdate.add(acc.Id);
            }
        }
        return accIdToUpdate;
}
/*
** @author : Cloud Sherpas, Inc.
** @date : 03/27/2014
** @description : this method is the class constructor
** @paramaters : String user profile name
** @returns : nothing
*/
    private set<Id> CreatePartnerIdSet(list<sObject> pSObjectList){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','CreatePartnerIdSet');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        set<Id> accountIdSet = new set<Id>();

        list<RelatedPartner__c> relatedPartnerList = (list<RelatedPartner__c>)pSObjectList;

        for(RelatedPartner__c relatedPartner : relatedPartnerList){
            accountIdSet.Add(relatedPartner.Partner__c);
        }

        return accountIdSet;
    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 03/27/2014
** @description : this method is the class constructor
** @paramaters : String user profile name
** @returns : nothing
*/
    private void UpdateAccountPrimaryRelatedAgency(list<Account> pAccountToUpdateList){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','UpdateAccountPrimaryRelatedAgency');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        try{
            update pAccountToUpdateList;
        }catch(DMLException dmlex){
            system.debug('Account to update: ' + pAccountToUpdateList);
            throw BaseApplicationException.NewException(METHODNAME, dmlex.getmessage(), 'Update to Account Primary Related Agency Failed');
        }

    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 03/27/2014
** @description : this method is the class constructor
** @paramaters : String user profile name
** @returns : nothing
*/
    private map<Id, Account> CreateAccountIdToAccountMap(list<sObject> pSObjectList, Boolean isInsert){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','UpdateAccountPrimaryRelatedAgency');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        set<Id> accountIdSet;
        if(isInsert){
            accountIdSet = CreateAccountIdSet(pSObjectList);
        } else {
            accountIdSet = CreatePartnerIdSet(pSObjectList);
        }
        Logger.debug('accountIdSet>>>>' + accountIdSet);
        //Story1652, E2920
        map<Id, Account> accountIdtoAccount = new map<Id,Account>([SELECT HiddenAgencyContactID__c, HiddenAgencyContactName__c, Id, PrimaryRelatedAgency__c, Primary_agency_contact__c FROM Account WHERE Id IN : accountIdSet]);

        return accountIdtoAccount;
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 03/27/2014
** @description : this method is the class constructor
** @paramaters : String user profile name
** @returns : nothing
*/
    public void SetAccountPrimaryRelatedAgency(list<RelatedPartner__c> pRelatedPartner, Boolean isInsert){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','SetAccountPrimaryRelatedAgency');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        Logger.push(METHODNAME, 'RelatedPartner__c');

        list<Account> accountToUpdateList = new list<Account>();


        if(isInsert){
            map<Id, Account> accountIdtoAccount = CreateAccountIdToAccountMap(pRelatedPartner, true);

            Set<Id> primaryAgencyContacts = new Set<Id>();
            for(Id key: accountIdtoAccount.keyset()){
                if(accountIdtoAccount.get(key).primary_agency_contact__c <> null){
                    primaryAgencyContacts.add(accountIdtoAccount.get(key).Primary_agency_contact__c);
                }

            }
            //Logger.debug('primaryAgencyContacts>>>>' + primaryAgencyContacts);
            list<Contact> agencyContactList = [SELECT Id, AccountId, Name FROM Contact
                                                                                    WHERE PrimarySalesContact__c = true AND id IN :primaryAgencyContacts];
            for(RelatedPartner__c relatedPartner : pRelatedPartner){
                Logger.debug('relatedPartner.Role__c>>' + relatedPartner.Role__c + ' && ' + accountIdtoAccount.get(relatedPartner.Account__c).PrimaryRelatedAgency__c);
                if(relatedPartner.Role__c == 'Agency' && String.isBlank(accountIdtoAccount.get(relatedPartner.Account__c).PrimaryRelatedAgency__c)){
                    accountIdtoAccount.get(relatedPartner.Account__c).PrimaryRelatedAgency__c = relatedPartner.Id;
                    //Story1651, E2920
                    //Dated Jan152015
                    Logger.debug('accountIdtoAccount.get(relatedPartner.Account__c)>>>>' +accountIdtoAccount.get(relatedPartner.Account__c));
                    accountToUpdateList.add(accountIdtoAccount.get(relatedPartner.Account__c));
                }
                System.debug('relatedPartner>>>>>>' + relatedPartner);
            }
            for(Contact oContact : agencyContactList){
                if(accountIdtoAccount.containsKey(oContact.AccountId) ){
                    accountIdtoAccount.get(oContact.AccountId).Primary_Agency_Contact__c = oContact.Id;
                    accountToUpdateList.add(accountIdtoAccount.get(oContact.AccountId) );
                }
                System.debug('oContact>>>>>>' + oContact);
            }
        } else {

            map<Id, Account> partnerIdtoAccount = CreateAccountIdToAccountMap(pRelatedPartner, false);
            map<Id, Account> accountIdtoAccount = CreateAccountIdToAccountMap(pRelatedPartner, true);
            Set<Id> primaryAgencyContacts = new Set<Id>();
            Set<Id> accountToUpdateIDs = new Set<Id>(); //I-201924
            /*for(Id key: partnerIdtoAccount.keyset()){
                if(partnerIdtoAccount.get(key).Primary_agency_contact__c != null){
                    primaryAgencyContacts.add(partnerIdtoAccount.get(key).Primary_agency_contact__c);
                }

            }*/

            List<Contact> agencyContactList = [SELECT Id, AccountId, Name FROM Contact
                                                                                    WHERE PrimarySalesContact__c = true AND AccountId IN :partnerIdtoAccount.keyset()];
            //Logger.debug('agencyContactList>>>>' + agencyContactList);
            //Logger.debug('agencyContactList>>>>' + agencyContactList);
            //System.debug('pRelatedPartner>>>>' + pRelatedPartner);
            Map <Id, Id> contactMap = new Map<Id, Id>();
            for(Contact oContact : agencyContactList){
                contactMap.put(oContact.AccountId, oContact.Id);

            }
            for(RelatedPartner__c relatedPartner : pRelatedPartner){

                accountIdtoAccount.get(relatedPartner.Account__c).Primary_Agency_Contact__c = contactMap.get(relatedPartner.Partner__c);
                if(!accountToUpdateIDs.contains(relatedPartner.Account__c)){
                    accountToUpdateIDs.add(relatedPartner.Account__c);
                accountToUpdateList.add(accountIdtoAccount.get(relatedPartner.Account__c));
            }
        }
        }
        System.debug('accountToUpdateList>>>>' + accountToUpdateList);
        UpdateAccountPrimaryRelatedAgency(accountToUpdateList);
        Logger.pop();
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 03/27/2014
** @description : Remove the primary agency contact when a related partner is deleted.
** @paramaters : String user profile name
** @returns : nothing
*/
    public void removePrimaryAgencyContactFromAccount(RelatedPartner__c[] pOldRelatedPartners){
        //Account[] relatedAccountList = [SELECT PrimaryAgencyContact__c FROM Account WHERE Id IN :CreateAccountIdSet(pOldRelatedPartners)];
        //Story1651, E2920
        //Dated Jan152015
        Account[] relatedAccountList = [SELECT Primary_Agency_Contact__c FROM Account WHERE Id IN :getAccountIdForAgency(pOldRelatedPartners)];
        system.debug('Accounts to be updated: ' + relatedAccountList.size());
        Account[] accToUpdate = new Account[]{};

        for(Account a : relatedAccountList){

            //Story1651, E2920
            if(a.Primary_Agency_Contact__c != null){
                a.Primary_Agency_Contact__c = null;
                accToUpdate.add(a);
            }

        }
        if(accToUpdate.size() > 0){

            UpdateAccountPrimaryRelatedAgency(accToUpdate);
        }
    }


/*
** @author : Cloud Sherpas, Inc.
** @date : 09/2/2014
** @description : update the Billing agency field of strategic account plan.
** @paramaters : List of related partners
** @returns : nothing
*/
    /*public void updateBillingAgency(RelatedPartner__c[] pNewRelatedPartners){
        Set<ID> accID = new Set<ID>();
        accID = CreateAccountIdSet(pNewRelatedPartners);
        List<RelatedPartner__c> relatedAccountList = [SELECT Account__c, AgencyType__c, Role__c, Name FROM RelatedPartner__c WHERE Account__c IN : accID];

        system.debug('Accounts to be updated: ' + relatedAccountList.size());
        List<Strategic_Account_Plan__c> sapList = [SELECT Account_Name__c, BillingAgency__c FROM Strategic_Account_Plan__c WHERE Account_Name__c IN : accID];
        List<Strategic_Account_Plan__c> sapToUpdate = new List<Strategic_Account_Plan__c>();
        for(Strategic_Account_Plan__c sap : sapList){
            String billingAgency = '';
            for(RelatedPartner__c rp : relatedAccountList){
                if(sap.Account_Name__c == rp.Account__c && rp.AgencyType__c == 'Billing'){
                    billingAgency = rp.Name;
                }
            }
            if(sap.BillingAgency__c != billingAgency){
                sap.BillingAgency__c = billingAgency;
                sapToUpdate.add(sap);
            }
        }
        if(sapToUpdate.size() > 0){
            update sapToUpdate;
        }
    }*/
}