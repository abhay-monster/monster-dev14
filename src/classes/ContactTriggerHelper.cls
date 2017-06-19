public without sharing class ContactTriggerHelper {
    final String CLASSNAME = '\n\n**** ContactTriggerHelper.METHODNAME()';
    public List<Contact> ContactList {get; set;}
    private List<Account> accountList;
    private List<Contact> contactQueryList;
    public Org_Settings__c orgSettings = Org_Settings__c.getInstance();
    public Integer cutoff = Integer.valueOf(orgSettings.Debug_Log_Record_Count_Cutoff__c); //JFreese Appirio S-435483 4/11/17
    public Id debugId = orgSettings.Debug_Log_Record_ID__c; //JFreese Appirio S-435483 4/11/17



/*
** @author : Cloud Sherpas Inc.
** @date : 04/17/2014
** @description : static method that instantiates a new instance of the class & sets the user's profile name member variable
** @paramaters : a string - the profile name for the current user
** @returns : a new instance of the AccountTriggerHelper class
*/

   public static ContactTriggerHelper NewTriggerHelper(){
        //final string METHODNAME = CLASSNAME.replace('METHODNAME','NewTriggerHelper');
        //system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        ContactTriggerHelper newHelper = new ContactTriggerHelper();
        return newHelper;
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 04/09/2014
** @description : this method is the class constructor
** @paramaters : String user profile name
** @returns : nothing
*/
    private ContactTriggerHelper(){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','ContactTriggerHelper');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

    }

/*
** @author : Appirio Inc
** @date : 10/12/2015
** @description : method is used to reset the triggerhandler, it nulls out the previously queried records
** @paramaters : nothing
** @returns : nothing
*/
    public void ResetQueries(){
        accountList = null;
        contactQueryList = null;
    }

/*
** @author : Appirio Inc (Jeff L)
** @date : 10/13/2015
** @description : this method checks to see if the queried account list is null, if it is it will query to get
the accounts it's use is to help reduce the overall number of queries.
** @paramaters : nothing
** @returns : List of accounts
*/
    private List<Account> queryAccountList(){
        if(accountList == null){
            Set<Id> accIds = new Set<Id>();

            for(Contact c : ContactList){
                if(c.AccountId != null){
                    accIds.add(c.AccountId);

                }
            }
            accountList = new list<account>();
            List<account> accountListQuery = [SELECT Id, Name, Organization__c, PrimaryBillingContact__c,
                                (Select Id,PrimarySalesContact__c,PrimaryServiceContact__c,AccountId  FROM Contacts),
                                PrimaryRelatedAgency__r.Partner__c, Primary_Agency_Contact__c
                            FROM Account
                            WHERE
                            (Id IN: accIds) OR
                    (PrimaryRelatedAgency__r.Partner__c IN: accIds)];
            For(Account a : accountListQuery){

                    accountList.add(a);
            }

            /*accountList = [
            SELECT Id, Name, Organization__c, PrimaryBillingContact__c,
            (Select Id,PrimarySalesContact__c,PrimaryServiceContact__c,AccountId  FROM Contacts),
            PrimaryRelatedAgency__r.Partner__c, Primary_Agency_Contact__c
            FROM Account
            WHERE
            (Id IN: accIds) OR
            (PrimaryRelatedAgency__r.Partner__c IN: accIds)];*/
        }
        return accountList;

    }
/*
** @author : Appirio Inc (Jeff L)
** @date : 10/13/2015
** @description : this method checks to see if the queried contact list is null, if it is it will query to get
the contacts it's use is to help reduce the overall number of queries.
** @paramaters : nothing
** @returns : List of contacts
*/
    private List<Contact> queryContactList(){
        if(contactQueryList == null){
            Set<Id> accIds = new Set<Id>();
            for(Contact c : ContactList){

                if(c.AccountId != null){
                    accIds.add(c.AccountId);

                }
            }

            contactQueryList = [
                SELECT Id, AccountId, PrimarySalesContact__c
                FROM Contact
                WHERE AccountId IN: accIds
            ];
        }

         return contactQueryList;
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 04/18/2014
** @description : remove the PrimaryAgencyContact__c from account partner when contact is deleted
** @paramaters : old contact list
** @returns : nothing
*/
//I-176183

    public void UpdatePrimaryAgencyContactOfRelatedAccounts(Contact[] pNewContact, Map<Id, Contact> pOldContactMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','AddPrimaryAgencyContactOfRelatedAccounts');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        map<Id, Account> agencyIdToPartnerAccount = getAgencyIdWithPartnerAccount(pNewContact);
        list<Account> accToUpdate = new list<Account>();
            for(Contact c : pNewContact){
            boolean flag = false;
                    if (pNewContact.size() <= cutoff || c.Id == debugId){ //JFreese Appirio S-435483 4/11/17
                    system.debug('**** Inside FOR JYOTHi 3333 ');
                }
                if(agencyIdToPartnerAccount.containsKey(c.AccountId)){
                    if (pNewContact.size() <= cutoff || c.Id == debugId){ //JFreese Appirio S-435483 4/11/17
                        system.debug('**** Inside if JYOTHi 2922 ');
                    }
                    Account partnerAccount = agencyIdToPartnerAccount.get(c.AccountId);
                    if(pOldContactMap != null){ //for update event
                        if (pNewContact.size() <= cutoff || c.Id == debugId){ //JFreese Appirio S-435483 4/11/17
                            system.debug('**** Inside if 11 JYOTHi');
                        }
                        if(pOldContactMap.get(c.Id).PrimarySalesContact__c && !c.PrimarySalesContact__c){
                            if (pNewContact.size() <= cutoff || c.Id == debugId){ //JFreese Appirio S-435483 4/11/17
                                system.debug('**** Inside if 1122 JYOTHi');
                            }
                            //system.debug('Removing Primary Agency Contact of \'' + partnerAccount.Name + '\' Account');
                            //partnerAccount.PrimaryAgencyContact__c = null;
                            //Story1651, E2920
                            //Dated Jan152015
                            partnerAccount.Primary_Agency_Contact__c = null;
                            flag = true;
                        }else if(!pOldContactMap.get(c.Id).PrimarySalesContact__c && c.PrimarySalesContact__c){
                            if (pNewContact.size() <= cutoff || c.Id == debugId){ //JFreese Appirio S-435483 4/11/17
                                system.debug('**** Inside if 1133 JYOTHi');
                            }
                            //partnerAccount.PrimaryAgencyContact__c = c.Name;
                            //Story1651,E2920
                            //Dated Jan142015
                            partnerAccount.Primary_Agency_Contact__c = c.Id;
                            flag = true;
                        }
                    }else if(pOldContactMap == null && c.PrimarySalesContact__c){ //for create
                        if (pNewContact.size() <= cutoff || c.Id == debugId){ //JFreese Appirio S-435483 4/11/17
                            system.debug('**** Inside if 1144 JYOTHi');
                        }
                        //partnerAccount.PrimaryAgencyContact__c = c.Name;
                        //Story1651,E2920
                        //Dated Jan142015
                        partnerAccount.Primary_Agency_Contact__c = c.Id;
                        flag = true;
                    }
                    if(flag == true) accToUpdate.add(partnerAccount);
                }
            }
            if(accToUpdate != null && accToUpdate.size() > 0) UpdateAccount(accToUpdate);
    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 04/18/2014
** @description : remove the PrimaryAgencyContact__c from account partner when contact is deleted
** @paramaters : old contact list
** @returns : nothing
*/
    public void RemovePrimaryAgencyContactOfRelatedAccounts(Contact[] pOldContact, Map<Id,Contact> pNewContactMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','RemovePrimaryAgencyContactOfRelatedAccounts');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        map<Id, Account> agencyIdToPartnerAccount = getAgencyIdWithPartnerAccount(pOldContact);
        list<Account> accToUpdate = new list<Account>();
            for(Contact c : pOldContact){
                if(pNewContactMap == null && c.PrimarySalesContact__c && agencyIdToPartnerAccount.containsKey(c.AccountId)){
                    Account partnerAccount = agencyIdToPartnerAccount.get(c.AccountId);
                    //system.debug('Removing Primary Agency Contact of \'' + partnerAccount.Name + '\' Account');
                    //partnerAccount.PrimaryAgencyContact__c = null;
                    //Story1651,E2920
                    //Dated Jan142015
                    partnerAccount.Primary_Agency_Contact__c = null;
                    accToUpdate.add(partnerAccount);
                }
            }
            UpdateAccount(accToUpdate);
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 03/27/2014
** @description : Updates the account and shows error if something happens
** @paramaters : list of accounts to be updated
** @returns : nothing
*/
    private void UpdateAccount(list<Account> pAccountToUpdateList){

        final string METHODNAME = CLASSNAME.replace('METHODNAME', 'UpdateAccountPrimaryRelatedAgency');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
                system.debug('^^^^^^ Jyothi - Size of Account to update' + pAccountToUpdateList.size());
        if(pAccountToUpdateList.size() > 0){
            //try{
                system.debug('^^^^^^ Jyothi - in update Account method');
                update pAccountToUpdateList;
            /*}catch(DMLException dmlex){
                throw BaseApplicationException.NewException(METHODNAME, dmlex.getmessage(), 'Update to Account Primary Related Agency Failed');
            }*/
        }else{
            system.debug('No Account to be updated.');
        }
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 04/18/2014
** @description : create a map that has keys of Agency Account and values of Business Accounts
** @paramaters : list of contacts
** @returns : Map of Ids and Accounts
*/
    private Map<Id, Account> getAgencyIdWithPartnerAccount(list<Contact> pContact){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','getAgencyIdWithPartnerAccount');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        map<Id, Account> agencyIdToPartnerAccount = new Map<Id, Account>();
        set<Id> ParentAccountIdSet = GetAccountIds(pContact);

        if(ParentAccountIdSet != null && ParentAccountIdSet.size() > 0){
            //for(Account a : [SELECT Name, PrimaryAgencyContact__c, PrimaryRelatedAgency__r.Partner__c
            //Story 1651, E2920
            //Dated Jan152015
            /*for(Account a : [SELECT Id, Name, PrimaryRelatedAgency__r.Partner__c, Primary_Agency_Contact__c
                                    FROM Account WHERE PrimaryRelatedAgency__r.Partner__c IN :ParentAccountIdSet]){*/
            for(Account a : queryAccountList()){
               if(a.PrimaryRelatedAgency__r.Partner__c != null && ParentAccountIdSet.contains(a.PrimaryRelatedAgency__r.Partner__c)){
                    agencyIdToPartnerAccount.put(a.PrimaryRelatedAgency__r.Partner__c, a);
                }
            }
        }
        return agencyIdToPartnerAccount;
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 04/18/2014
** @description : get all Account Ids from contact list
** @paramaters : list of Contact
** @returns : Set Of Id
*/
    private Set<Id> GetAccountIds(list<Contact> pContactList){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','GetAccountIds');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Set<Id> ids = new Set<Id>();
        for(Contact con : pContactList){
            if(con.AccountId != null){
                ids.add(con.AccountId);
            }
        }
       return ids;
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
    public void validatePrimarySalesContact(List<Contact> pUpdatedContact){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','validatePrimarySalesContact');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        Set<Id> accountSet = new  Set<Id>();
        for(Contact con : pUpdatedContact){
            if(con.PrimarySalesContact__c == true && con.AccountId != null){
                accountSet.add(con.AccountId);
            }
        }
        //Checks if one of the contact is Primary sales Rep
        List<Contact> AccountContactList;
        List<AccountContactAssociation__c> AccountACAList;
        Map<Id,Id> contactPrimarySalesContactMap = new Map<Id,Id>();
        Map<Id,Id> relContactPrimarySalesContactMap = new Map<Id,Id>();

        if(!accountSet.isEmpty()){
            system.debug('inside'+accountSet);
            //Jeff L commented out to use new query framework
            //for(Contact con : [SELECT Id, AccountId, PrimarySalesContact__c FROM Contact WHERE AccountId IN: accountSet]){
            for(Contact con : queryContactList()){
               //JeffL added check for null accountId, there are >100K rows in this object so if we query with null
                //we get a Non-selective query error
                if(con.PrimarySalesContact__c == true){
                    contactPrimarySalesContactMap.put(con.AccountId,con.Id);
                }
            }
            //Checks if one of the related contact is already a primary sales contact
            for(AccountContactAssociation__c aca : [SELECT Id, Account__c, PrimarySalesContact__c FROM AccountContactAssociation__c WHERE Account__c IN: accountSet]){
                if(aca.PrimarySalesContact__c == true){
                    relContactPrimarySalesContactMap.put(aca.Account__c,aca.Id);
                }
            }

            for(Contact con : pUpdatedContact){
                if(con.PrimarySalesContact__c == true){
                    if(contactPrimarySalesContactMap.get(con.AccountId) != null || relContactPrimarySalesContactMap.get(con.AccountId) != null){
                        if(UserInfo.getName() != 'Integration MAPP'){//I-218547
                            con.addError('There is an existing Primary Sales Contact for the selected account.');
                        }
                    }
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
changes made to this method to move it to before insert.
*/
    public void SetPrimarySalesContact(List<Contact> pUpdatedContact){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','SetPrimarySalesContact');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        //try{
            Id userId = UserInfo.getUserId();
            Id MAPPIntergrationUserId;
            list<User> integUserList = new list<User>();
            boolean doNotExecute;
            boolean setPrimarySalesContact;
            integUserList = [SELECT Id FROM User WHERE FirstName ='Integration' AND LastName ='MAPP' Limit 1];
            system.debug('integUserList' + integUserList);
            if(integUserList.size() > 0){
                MAPPIntergrationUserId = integUserList[0].Id;
                system.debug('MAPPIntegrationUserId' + MAPPIntergrationUserId);
            }
            set<Id> AccountIds = new Set<Id>();
            List<Contact> AccountContactList = new List<Contact>();
            List<AccountContactAssociation__c> AccountACAList = new List<AccountContactAssociation__c>();
            /*for(Contact con : [SELECT Id, AccountId, PrimarySalesContact__c, InternetType__c FROM Contact WHERE Id IN: pNewContactMap.keySet()]){*/
            for(Contact con : pUpdatedContact){
                if(con.AccountId != null){
                    AccountIds.add(con.AccountId);
                }
            }
            if(!AccountIds.isEmpty()){
                /*AccountContactList =[SELECT Id, AccountId, PrimarySalesContact__c FROM Contact WHERE AccountId IN: AccountIds AND Id NOT IN: pNewContactMap.keySet() ];*/
                // Jeff L commented out for new query framework
                //AccountContactList =[SELECT Id, AccountId, PrimarySalesContact__c FROM Contact WHERE AccountId IN: AccountIds ];
                AccountContactList = queryContactList();
                AccountACAList =[SELECT Id, Account__c, PrimarySalesContact__c FROM AccountContactAssociation__c WHERE Account__c IN: AccountIds];
            }
            map<Id,Id> AccountsPrimaryContact = new Map<Id,Id>();
            //Jeff L commented out for new query framework
            //for(Contact cons : [SELECT Id, AccountId FROM Contact WHERE AccountId IN : AccountIds AND PrimarySalesContact__c = true]){
            for(Contact cons : queryContactList()){
                if(cons.PrimarySalesContact__c == true){
                    AccountsPrimaryContact.put(cons.AccountId, cons.Id);
                }
            }
            List<Contact> ContactListToUpdate = new List<Contact>();
            List<Contact> ContactListToUpdate1 = new List<Contact>();
            set<Id> ContactIdsToUpdate = new Set<Id>();
            /*for(Contact con : [SELECT Id, AccountId, PrimarySalesContact__c, InternetType__c FROM Contact WHERE Id IN: pNewContactMap.keySet()]){*/
            for(Contact con : pUpdatedContact){
                setPrimarySalesContact = false;
                Set<String> internetType = new Set<String>();
                 if(userId == MAPPIntergrationUserId && con.InternetType__c != null){

                    for(String s: con.InternetType__c.split(';')){
                        internetType.add(s);
                    }
                    if(con.InternetType__c == 'Internet Primary' || (internetType.contains('Internet Primary') && internetType.contains('Internet Billing'))){
                       con.PrimarySalesContact__c = true;
                       setPrimarySalesContact = true;
                    }
                    else{
                     doNotExecute = true;
                    }
                 }
                 else if((userId != MAPPIntergrationUserId) && (AccountContactList.isEmpty() && AccountACAList.isEmpty())){
                     con.PrimarySalesContact__c = true;
                     setPrimarySalesContact = true;
                  }

                if(setPrimarySalesContact && AccountsPrimaryContact.get(con.AccountId) != null){
                    ContactIdsToUpdate.add(AccountsPrimaryContact.get(con.AccountId));
                 }
                  //ContactListToUpdate.add(con);
            }
            if(!ContactIdsToUpdate.isEmpty() && doNotExecute != true){
                //Jeff L updated for new query framework
                //for(Contact c : [SELECT Id, PrimarySalesContact__c FROM Contact WHERE Id IN: ContactIdsToUpdate]){
                for(Contact c : queryContactList()){
                    if(ContactIdsToUpdate.contains(c.Id)){
                        c.PrimarySalesContact__c = false;
                        ContactListToUpdate1.add(c);
                    }
                }
            }
            if(!ContactListToUpdate1.isEmpty()){
                ContactTriggerHandler.ExecuteTriggers = false;
                update ContactListToUpdate1;
                ContactTriggerHandler.ExecuteTriggers = true; //J Freese Appirio 5/17/16 I-207995
            }
             /*if(!ContactListToUpdate.isEmpty()){
                system.debug('!!!!!!!');
                ContactTriggerHandler.ExecuteTriggers = false;
                update ContactListToUpdate;
            }*/
        /*}catch(Exception e){
            ExceptionLog.add('Exception', 'ContactTriggerHelper', 'SetPrimarySalesContact', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to set Primary Sales Contact checkbox. \n'+ e.getMessage()+e.getLineNumber() ,e);
        }*/
    }
    /*public void SetPrimarySalesContact(List<Contact> pUpdatedContact, Map<Id,Contact> pNewContactMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','SetPrimarySalesContact');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        //try{
            Id userId = UserInfo.getUserId();
            Id MAPPIntergrationUserId;
            list<User> integUserList = new list<User>();
            boolean doNotExecute;
            integUserList = [SELECT Id FROM User WHERE FirstName ='Integration' AND LastName ='MAPP' Limit 1];
            system.debug('integUserList' + integUserList);
            if(integUserList.size() > 0){
                MAPPIntergrationUserId = integUserList[0].Id;
                system.debug('MAPPIntegrationUserId' + MAPPIntergrationUserId);
            }
            set<Id> AccountIds = new Set<Id>();
            List<Contact> AccountContactList;
            List<AccountContactAssociation__c> AccountACAList;
            for(Contact con : [SELECT Id, AccountId, PrimarySalesContact__c, InternetType__c FROM Contact WHERE Id IN: pNewContactMap.keySet()]){
                AccountIds.add(con.AccountId);
            }
            if(!AccountIds.isEmpty()){
                AccountContactList =[SELECT Id, AccountId, PrimarySalesContact__c FROM Contact WHERE AccountId IN: AccountIds AND Id NOT IN: pNewContactMap.keySet() ];
                AccountACAList =[SELECT Id, Account__c, PrimarySalesContact__c FROM AccountContactAssociation__c WHERE Account__c IN: AccountIds];
            }
            map<Id,Id> AccountsPrimaryContact = new Map<Id,Id>();
            for(Contact cons : [SELECT Id, AccountId FROM Contact WHERE AccountId IN : AccountIds AND PrimarySalesContact__c = true]){
                AccountsPrimaryContact.put(cons.AccountId, cons.Id);
            }
            List<Contact> ContactListToUpdate = new List<Contact>();
            List<Contact> ContactListToUpdate1 = new List<Contact>();
            set<Id> ContactIdsToUpdate = new Set<Id>();
            for(Contact con : [SELECT Id, AccountId, PrimarySalesContact__c, InternetType__c FROM Contact WHERE Id IN: pNewContactMap.keySet()]){
                if(AccountsPrimaryContact.get(con.AccountId) != null){
                    ContactIdsToUpdate.add(AccountsPrimaryContact.get(con.AccountId));
                 }
                Set<String> internetType = new Set<String>();
                if(userId == MAPPIntergrationUserId && con.InternetType__c != null){
                    for(String s: con.InternetType__c.split(';')){
                        internetType.add(s);
                    }
                    if(con.InternetType__c == 'Internet Primary' || (internetType.contains('Internet Primary') && internetType.contains('Internet Billing'))){
                       con.PrimarySalesContact__c = true;
                    }
                    else{
                     doNotExecute = true;
                    }
                 }
                 else if((userId != MAPPIntergrationUserId) && (AccountContactList.isEmpty() && AccountACAList.isEmpty())){
                     con.PrimarySalesContact__c = true;
                  }
                  ContactListToUpdate.add(con);

            }
            if(!ContactIdsToUpdate.isEmpty() && doNotExecute != true){
                for(Contact c : [SELECT Id, PrimarySalesContact__c FROM Contact WHERE Id IN: ContactIdsToUpdate]){
                    c.PrimarySalesContact__c = false;
                    ContactListToUpdate1.add(c);
                }
            }
            if(!ContactListToUpdate1.isEmpty()){
                system.debug('!!!!!!!');
                ContactTriggerHandler.ExecuteTriggers = false;
                update ContactListToUpdate1;
            }
            if(!ContactListToUpdate.isEmpty()){
                system.debug('!!!!!!!');
                ContactTriggerHandler.ExecuteTriggers = false;
                update ContactListToUpdate;
            }
        //}catch(Exception e){
         //   ExceptionLog.add('Exception', 'ContactTriggerHelper', 'SetPrimarySalesContact', e.getMessage());
        //    throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to set Primary Sales Contact checkbox. \n'+ e.getMessage()+e.getLineNumber() ,e);
        //}
    }*/
    /*
** @author : Cloud Sherpas, Inc.
** @date : 07/16/2014
** @story : 0709
** @element : E1803
** @description : Checks if there's already a primary sales contact in an account
** @paramaters : Map of AccountContactAssociation__c
** @returns : nothing
*/
    public void UpdateValidationPrimarySalesContact(List<Contact> pUpdatedContact, Map<Id,Contact> pNewContactMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','UpdateValidationPrimarySalesContact');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        Set<Id> accountSet = new  Set<Id>();
        for(Contact con : pUpdatedContact){
            if (pUpdatedContact.size() <= cutoff || con.Id == debugId){ //JFreese Appirio S-435483 4/11/17
                system.debug('&&con&&'+con.email+'new'+pNewContactMap.get(con.Id).email);
            }
            if(con.PrimarySalesContact__c != pNewContactMap.get(con.Id).PrimarySalesContact__c){
                if(con.PrimarySalesContact__c == true){
                    accountSet.add(con.AccountId);
                }
            }
        }
        //Checks if one of the contact is Primary sales Rep
        List<Contact> AccountContactList;
        List<AccountContactAssociation__c> AccountACAList;
        Map<Id,Id> contactPrimarySalesContactMap = new Map<Id,Id>();
        Map<Id,Id> relContactPrimarySalesContactMap = new Map<Id,Id>();
        if(!accountSet.isEmpty()){
            //Jeff L commented out for new 10/13 query framework
            //for(Contact con : [SELECT Id, AccountId, PrimarySalesContact__c FROM Contact WHERE AccountId IN: accountSet AND Id NOT IN: pNewContactMap.keySet()]){
            for(Contact con : queryContactList()){
                if(con.PrimarySalesContact__c == true && accountSet.contains(con.AccountId) && !pNewContactMap.containsKey(con.Id)){
                    contactPrimarySalesContactMap.put(con.AccountId,con.Id);
                }
            }
            //Checks if one of the related contact is already a primary sales contact
            for(AccountContactAssociation__c aca : [SELECT Id, Account__c, PrimarySalesContact__c FROM AccountContactAssociation__c WHERE Account__c IN: accountSet]){
                if(aca.PrimarySalesContact__c == true){
                    relContactPrimarySalesContactMap.put(aca.Account__c,aca.Id);
                }
            }
            for(Contact con : pUpdatedContact){
                if(con.PrimarySalesContact__c == true){
                    if(contactPrimarySalesContactMap.get(con.AccountId) != null || relContactPrimarySalesContactMap.get(con.AccountId) != null){
                        con.addError('There is an existing Primary Sales Contact for the selected account.');
                    }
                }
            }
        }
    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 07/16/2014
** @story : 0451
** @element : E1957
** @description :
** @paramaters :
** @returns : nothing
*/
    public void updateContactFieldsFromMAPP(List<Contact> pUpdatedContact){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateContactFieldsFromMAPP');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        //try{
            for(Contact con : pUpdatedContact){
                if(con.MAPPOwner__c != null){
                    con.OwnerId = con.MAPPOwner__c;
                }
                //if(con.MAPPCreatedById__c != poldContactMap.get(con.Id).MAPPCreatedById__c){
                //  con.CreatedById = con.MAPPCreatedById__c;
                //}
                //if(con.MAPPLastModifiedById__c != poldContactMap.get(con.Id).MAPPLastModifiedById__c){
                //  con.LastModifiedById = con.MAPPLastModifiedById__c;
                //}
            }
        //}catch(Exception dmlex){
            //System.Debug('^^^ Contact EXCEPTION: ' + dmlex.getMessage());
            //throw BaseApplicationException.NewException(METHODNAME, dmlex.getmessage(), 'Failed to update Owner. Please see system log for details.');
        //}
    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 07/16/2014
** @story : 0451
** @element :
** @description : MAPP REP ASSIGNMENT
** @paramaters :
** @returns : nothing
*/
    public void AssignContactFromMAPP(List<Contact> pContact){
      final string METHODNAME = CLASSNAME.replace('METHODNAME','AssignContactFromMAPP');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
      //try{
        for(Contact con: pContact){
            if(con.Account.ownerId != null){
                con.OwnerId = con.Account.ownerId;
            }
        }
      //}catch(Exception e){
        //ExceptionLog.add('Exception', 'OrderTriggerHelper', 'AssignContactFromMAPP', e.getMessage());
          //  throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to assign contact.' ,e);
      //}
    }

    /*
    ** @author : jlaurio Cloud Sherpas, Inc.
    ** @date : 12/03/2014
    ** @story : 0989
    ** @element : 1904
    ** @description : Primary Billing Contact override
    ** @paramaters : List<Contact> Contact List
    ** @returns : nothing
    */

    public void uncheckOtherPrimaryBillingContacts(List<Contact> contactList){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','UncheckOtherPrimaryBillingContacts');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        Logger.push(METHODNAME, Schema.Contact.getSObjectType().getDescribe().getName());
        //try{
            //method variables
            List<Contact> ContactToUpdate = new List<Contact>();
            Set<Id> accountIds = new Set<Id>();
            Set<Id> contactIds = new Set<Id>();
            //list iteration retrieving record ids and account id
            for(Contact currentContact: contactList){
                if(currentContact.PrimaryBillingContact__c==true){
                    contactIds.add(currentContact.Id);
                    accountIds.add(currentContact.AccountId);
                }
            }
            // iterate through other contacts under same account id
            // setting the checkbox to false
            // adding updated record to list for later update DML
            if(!contactIds.isEmpty()){
                for(Contact otherContact: [SELECT Id, AccountId, PrimaryBillingContact__c FROM Contact WHERE AccountId IN:accountIds AND Id NOT IN:contactIds]){
                        if(otherContact.PrimaryBillingContact__c==true){
                        system.debug('unchecking Other Primary Billing Contact' + otherContact);
                        Contact con = otherContact.clone(true, true, true, true);
                        con.PrimaryBillingContact__c=false;
                        ContactToUpdate.add(con);
                    }
                }
                //DML call
                if(!ContactToUpdate.isEmpty()){
                    ContactTriggerHandler.ExecuteTriggers = false;
                    update ContactToUpdate;
                    ContactTriggerHandler.ExecuteTriggers = true; //J Freese Appirio 5/17/16 I-207995
                }
            }

        //}
        //catch(Exception e){
          //  Logger.debugException(Label.ContactUncheckPrimaryBillingContactExceptionLabel+' \n'+ e.getMessage(), null);//Failed to disable other Primary Billing Contact checkbox.
            //Logger.pop();
            //ExceptionLog.add('Exception', 'ContactTriggerHelper', 'UncheckOtherPrimaryBillingContacts', e.getMessage());
            //throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,Label.ContactUncheckPrimaryBillingContactExceptionLabel+' \n'+ e.getMessage() ,e);
        //}
    }

    /*
    ** @author : jlaurio Cloud Sherpas, Inc.
    ** @date : 12/03/2014
    ** @story : 0989
    ** @element : 1904
    ** @description : set Primary Billing Contact on Account
    ** @paramaters : List<Contact> Contact List
    ** @returns : nothing
    */

    public void setAccountRecordPrimaryBillingContact(List<Contact> contactList){



        final string METHODNAME = CLASSNAME.replace('METHODNAME','setAccountRecordPrimaryBillingContact');
        //system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        Logger.push(METHODNAME, Schema.Contact.getSObjectType().getDescribe().getName());
        try{
            // method variables
            List<Account> AccountToUpdate = new List<Account>();
            Set<Id> accountIds = new Set<Id>();
            Set<Id> contactIds = new Set<Id>();
            // list iteration retrieving record ids and account id
            for(Contact currentContact: contactList){
                contactIds.add(currentContact.Id);
                accountIds.add(currentContact.AccountId);
            }
            // collate all accounts of currently processed contacts
            //Jeff L commented out for query limits 10/14
            //Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, PrimaryBillingContact__c FROM Account WHERE Id IN:accountIds]);
            Map<Id,Account> accountMap = new Map<Id,Account>();

            for(Account a : queryAccountList()){
                if(accountIds.contains(a.Id)){
                    accountMap.put(a.Id, a);
                }
            }
        // iterate through current contact to update the PrimaryBillingContact__c of the related Account record
            // adding updated record to list for later update DML
            for(Contact currentContact: contactList){
                if(currentContact.PrimaryBillingContact__c==true){
                    if(accountMap.containsKey(currentContact.AccountId)){
                        Account tempAccount = accountMap.get(currentContact.AccountId);
                        //if the account doesn't have a different primary billing contact then we
                        //don't have to update
                        if(tempAccount.PrimaryBillingContact__c != currentContact.Id){
                            tempAccount.PrimaryBillingContact__c = currentContact.Id;
                            AccountToUpdate.add(tempAccount);
                        }
                    }
                }
            }


            //DML call
            if(!AccountToUpdate.isEmpty()){
                list<AccountShare> lstUserAccountAccess = [SELECT AccountAccessLevel FROM AccountShare WHERE UserOrGroupId=:UserInfo.getUserId() AND AccountAccessLevel!= 'Edit' AND AccountId IN :AccountToUpdate];
                update AccountToUpdate;
            }

        }
        catch(Exception e){

            //Logger.debugException(Label.ContactSetAccountPrimaryBillingContactException + ' \n'+ e.getMessage(), null);//Failed to set Primary Billing Contact lookup on Account.
            //Logger.pop();
            //ExceptionLog.add('Exception', 'ContactTriggerHelper', 'setAccountRecordPrimaryBillingContact', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,Label.ContactSetAccountPrimaryBillingContactException + ' \n'+ e.getMessage() ,e);
        }
    }

    /*
    ** @author : Cloud Sherpas, Inc.
    ** @date : 01/09/2015
    ** @story : 1724
    ** @element : E2153
    ** @description : If a Contact is created from Email2Case Case record, relate the Contact to Case via the Related_Case__c field - JLaurio
    ** @paramaters : Accounts
    ** @returns : nothing
    */
    public void associateContactToRelatedCase(Contact[] pNewContacts, map<ID, Contact> pContactIdToOldContactMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','associateContactToRelatedCase');
        Logger.push(METHODNAME, Schema.Contact.getSObjectType().getDescribe().getName());
        //try{
            Set<Id> caseIds = new Set<Id>();
            Map<Id, Case> contactToCaseMap = new Map<Id, Case>();
            List<Case> caseListForUpdate = new List<Case>();

            //collecting the Related Case Ids for query
            for(Contact pContact:pNewContacts){

                System.debug('Vaibhav '+pNewContacts.size());
                System.debug('Vaibhav see related'+pContact.Related_Case__c);
                if(pContact.Related_Case__c!=null){
                    caseIds.add(pContact.Related_Case__c);
                }
            }

            if(caseIds.size()>0){
                List<Case> caseList = [SELECT Id, AccountId, ContactId FROM Case WHERE Id IN: caseIds];
                //associating the Contact on to the Related Case
                for(Contact pContact:pNewContacts){
                    for(Case pCase:caseList){
                        if(pContact.Related_Case__c == pCase.Id){
                            Case tempCase = pCase;
                            tempCase.ContactId = pContact.Id;
                            caseListForUpdate.add(tempCase);
                        }
                    }
                }

                //DML call
                if(caseListForUpdate != null && !caseListForUpdate.isEmpty()){
                    CaseTriggerHandler.ExecuteTriggers = false;
                    update caseListForUpdate;
                    CaseTriggerHandler.ExecuteTriggers = true; //J Freese Appirio 5/17/16 I-207995
                }
            }
        //}
        /*catch(Exception e){
            Logger.debugException('Failed to associate contact to related cases.'+' \n'+ e.getMessage());//Failed to associate to related cases.
            Logger.pop();
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to associate contact to related cases.'+' \n'+ e.getMessage() ,e);
        }*/
    }

    public void populateOrganization(List<Contact> newConList , Map<Id,Contact> oldContactMap){

    Boolean isUpdate = false;
    Set<Id> accIdSet = new Set<Id>();
    Map<Id,string> accountOrganizationMap = new Map<Id,string>();
    List<Contact> lstToUpdate = new List<Contact>();
    if(oldContactMap != null){
        isUpdate = true;
    }

    for(Contact con : newConList){
        if(!isUpdate){
            accIdSet.add(con.AccountId);
        }else if(isUpdate && con.AccountId != oldContactMap.get(con.Id).AccountId){
            accIdSet.add(con.AccountId);
        }
    }

    if(accIdSet.size()>0){
        //Jeff L moving into new query framework
        //for(Account acc : [Select Id,Organization__c From Account WHERE ID IN :accIdSet AND Organization__c !=null]){
        for(Account acc : queryAccountList()){
            if(accIdSet.contains(acc.Id) && acc.Organization__c != null){
                accountOrganizationMap.put(acc.Id,acc.Organization__c);
            }
        }
    }

    for(Contact con : newConList){
     if(accountOrganizationMap.containsKey(con.AccountId)){

        string organization = accountOrganizationMap.get(con.AccountId);
        con.Organization__c = organization;
        //lstToUpdate.add(con);
      }
   }
 }

      //AP I-159816
    public void setPrimaryBillCon(List<Contact> contactList){
        system.debug('Inside setPrimaryBillCon');
        final string METHODNAME = CLASSNAME.replace('METHODNAME','setPrimaryBillCon');
        //system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        Logger.push(METHODNAME, Schema.Contact.getSObjectType().getDescribe().getName());
        //try{
            List<Contact> ContactToUpdate = new List<Contact>();
            Set<Id> contactIds = new Set<Id>();
            Set<Id> accountIds = new Set<Id>();
            for(Contact currentContact: contactList){
                contactIds.add(currentContact.Id);
                accountIds.add(currentContact.AccountId);
            }
            //List<Contact> contactBillingList = [SELECT Id, PrimaryBillingContact__c,InternetType__c FROM Contact WHERE Id IN:contactIds AND InternetType__c = 'Internet Billing'];
            //system.debug('contactBillingList'+contactBillingList);
            List<Contact> conBillingList = [SELECT Id, PrimaryBillingContact__c,InternetType__c, AccountId FROM Contact WHERE AccountId IN:accountIds AND InternetType__c = 'Internet Billing' AND PrimaryBillingContact__c= true];
            system.debug('conBillingList' + conBillingList);
            Set<Id> accountIdsToUpdate = new Set<Id>();
            for(Contact currentContact: contactList){
                system.debug('currentContact.InternetType__c' + currentContact.InternetType__c);
                //if(currentContact.InternetType__c == 'Internet Billing')
                if(currentContact.InternetType__c != null && (currentContact.InternetType__c == 'Internet Billing' || (currentContact.InternetType__c.contains('Internet Primary') && currentContact.InternetType__c.contains('Internet Billing'))))//modified for I-203412
                {

                    if(currentContact.PrimaryBillingContact__c!=true){
                            currentContact.PrimaryBillingContact__c = true;
                            accountIdsToUpdate.add(currentContact.AccountId);
                            //ContactToUpdate.add(currentContact);
                            system.debug('Primary Billing Contact Set? ' + currentContact);
                    }
                }
            }
            //List<Contact> conBillingList = [SELECT Id, PrimaryBillingContact__c,InternetType__c FROM Contact WHERE AccountId IN:accountIds AND InternetType__c = 'Internet Billing'];
            for(Contact currContact: conBillingList){
                        if(currContact.PrimaryBillingContact__c==true && accountIdsToUpdate.contains(currContact.AccountId)){
                                currContact.PrimaryBillingContact__c = false;
                                ContactToUpdate.add(currContact);
                                system.debug('Primary Billing Contact unSet? ' + currContact);
                        }
            }
            if(!ContactToUpdate.isEmpty()){
                update ContactToUpdate;
            }
        //}
        //catch(Exception e){
            //throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,Label.setPrimaryBillConException + ' \n'+ e.getMessage() ,e);
        //}
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 03/19/2014
** @description : Manage Primary Sales Contact and Primary Service Contact
** @paramaters : Contact Array
** @returns : nothing
** Jeff L moved from TriggerHelper to this class
*/

public void ManagePrimarySalesAndServiceContact(list<Contact> pcontact){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));


        set<Id> accountIdSet = new set<Id>();
        set<id> contactIdSet = new set<Id>();

        for(Contact oContact : pContact){
            accountIdSet.add(oContact.AccountId);
            if(Trigger.isUpdate){
                contactIdSet.add(oContact.id);
            }
        }
        // Jeff L Commented out for query framework
        //list<Account> accountList = [Select Id,(Select Id,PrimarySalesContact__c,PrimaryServiceContact__c,AccountId  FROM Contacts) FROM Account WHERE Id IN : accountIdSet];
        List<Account> accountList = new List<Account>();
        for(Account a : queryAccountList()){
            if(accountIdSet.contains(a.Id)){
                accountList.add(a);
            }
        }
        map<id,integer> accountIdPrimarySalesContactCount = new map<id,Integer>();
        map<id,integer> accountIdPrimaryServiceContactCount = new map<id,Integer>();
        map<id,list<Contact>> accountIdPrimaryServiceContacts = new map<id,List<Contact>>();


        //Count Number of Primary Sales and Primary Service Contact existing for a Account.
        for(Account oAccount : accountList){
            system.debug(oAccount.contacts+'!!!!'+accountList);

           for(Contact oContact : oAccount.Contacts){
               System.debug('Contacts to be entered '+oAccount.Contacts.size());
               if(Trigger.isUpdate){
                system.debug('update entered');
                   if(!contactIdSet.contains(oContact.id)){
                       if(oContact.PrimarySalesContact__c == true){
                           if(accountIdPrimarySalesContactCount.containsKey(oContact.AccountId)){
                                accountIdPrimarySalesContactCount.put(oContact.AccountId, accountIdPrimarySalesContactCount.get(oContact.AccountId) + 1);
                           }else{
                                accountIdPrimarySalesContactCount.put(oContact.AccountId, 1);
                           }

                       }
                           // system.debug('**'+oContact.PrimaryServiceContact__c + '**'+ [select email from contacts where ]);
                       if(oContact.PrimaryServiceContact__c == true){
                           if(accountIdPrimaryServiceContactCount.containsKey(oContact.AccountId)){
                                accountIdPrimaryServiceContactCount.put(oContact.AccountId, accountIdPrimaryServiceContactCount.get(oContact.AccountId) + 1);
                           }else{
                                accountIdPrimaryServiceContactCount.put(oContact.AccountId, 1);
                           }
                           if(!accountIdPrimaryServiceContacts.containskey(oContact.AccountId)){
                                accountIdPrimaryServiceContacts.put(oContact.AccountId, new list<contact>());
                           }
                           accountIdPrimaryServiceContacts.get(oContact.AccountId).add( oContact);
                       }
                    }
                } else{
                    system.debug('Vaibhav insert entered '+ oContact.PrimarySalesContact__c + oContact.PrimaryServiceContact__c);
                    if(oContact.PrimarySalesContact__c == true){
                       if(accountIdPrimarySalesContactCount.containsKey(oContact.AccountId)){
                            accountIdPrimarySalesContactCount.put(oContact.AccountId, accountIdPrimarySalesContactCount.get(oContact.AccountId) + 1);
                       }else{
                            accountIdPrimarySalesContactCount.put(oContact.AccountId, 1);
                       }
                   }

                   if(oContact.PrimaryServiceContact__c == true){
                       if(accountIdPrimaryServiceContactCount.containsKey(oContact.AccountId)){
                            accountIdPrimaryServiceContactCount.put(oContact.AccountId, accountIdPrimaryServiceContactCount.get(oContact.AccountId) + 1);
                       }else{
                            accountIdPrimaryServiceContactCount.put(oContact.AccountId, 1);
                       }
                           if(!accountIdPrimaryServiceContacts.containskey(oContact.AccountId)){
                                accountIdPrimaryServiceContacts.put(oContact.AccountId, new list<contact>());
                           }
                           accountIdPrimaryServiceContacts.get(oContact.AccountId).add( oContact);


                   }
                }
            }
        }
        List<contact> lstContactsToUpdate = new List<contact>();
        //On Inserting Contact check the count for Contact related to attached Account of specific sales and service type.
        for(Contact con : pContact){
            if(con.PrimarySalesContact__c == true){
                if(accountIdPrimarySalesContactCount.containskey(con.AccountId)){
                    if(accountIdPrimarySalesContactCount.get(con.AccountId) >= 1){
                        con.addError('Primary Sales Contact has already been set for an Account');
                    }
                }
            }

            if(con.PrimaryServiceContact__c == true){
                if(accountIdPrimaryServiceContactCount.containskey(con.AccountId)){
                    if(accountIdPrimaryServiceContactCount.get(con.AccountId) >= 1){
                        for(contact c : accountIdPrimaryServiceContacts.get(con.AccountId)){
                            c.PrimaryServiceContact__c = false;
                            lstContactsToUpdate .add(c);
                        }
                    }
                }
            }
        }
        if(lstContactsToUpdate .size() > 0)
            update lstContactsToUpdate ;
    }
/*
** @author : Appirio (Jonathan F)
** @date : 04/05/16
** @description : Make changes to Account address info based on contact address info for Ecomm orders
** @returns : nothing
*/
    public void fixEcomm(List<Contact> pContact){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','fixEcomm');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        String fixed = '';
        String conType = '';

      try{
            set<Id> setAccountIds = new set<Id>();
            for(Contact c : pContact){
              setAccountIds.add(c.AccountId);
            }

            map<String, String> billFields = new map<String, String>{'BillingStreet'     => 'MailingStreet',
                                                                     'BillingCity'       => 'MailingCity',
                                                                     'BillingState'      => 'MailingState',
                                                                     'BillingPostalCode' => 'MailingPostalCode',
                                                                     'BillingCountry'    => 'MailingCountry'};

            map<String, String> primFields = new map<String, String>{'ShippingStreet'     => 'MailingStreet',
                                                                     'ShippingCity'       => 'MailingCity',
                                                                     'ShippingState'      => 'MailingState',
                                                                     'ShippingPostalCode' => 'MailingPostalCode',
                                                                     'ShippingCountry'    => 'MailingCountry'};

            map<Id, Account> mapAcc = new map<Id, Account>();
            String queryStr = 'SELECT Id, ';
            for(String field : billFields.keySet()){
                queryStr += field + ',';
            }
            for(String field : primFields.keySet()){
                queryStr += field + ',';
            }
            queryStr = queryStr.left(queryStr.length() - 1);
            queryStr += ' FROM Account WHERE ID IN (';
            for(String id : setAccountIds){
                queryStr += '\'' + id + '\',';
            }
            queryStr = queryStr.left(queryStr.length() - 1);
            queryStr += ')';
            system.debug('queryStr = '+ queryStr);

            List<Account> ContactAccounts = Database.query(queryStr);
            for(Account a : ContactAccounts){
                mapAcc.put(a.Id,a);
            }

            List<Account> AccountsToUpdate = new List<Account>();
            for(Contact c : pContact){
                System.debug('Contact to fix is '+ c);
                fixed = '';
                conType = '';
                if (mapAcc != null && mapAcc.containskey(c.AccountId)){
                    Account a = new Account();
                    a.Id = mapAcc.get(c.AccountId).Id;
                    //J Freese Appirio 4/8/16 I-I-207995 disable this
                    //per Anu/Shoba, if user changes both primary and billing, resulting in 2 contacts,
                    //then makes a new order and checks “use account info for billing contact”, it will make
                    //a new combined contact(!), which we need to update account from
                    //if (c.InternetType__c.contains('Internet Billing') && c.InternetType__c.contains('Internet Primary')){
                    //    system.Debug('Not updating any account fields based on Contact ' + c.Id + ' as it is the initial combined contact where InternetType__c=' + c.InternetType__c);
                    //}
                    System.debug('Give a look to internet type '+ c.InternetType__c);


                    /* J Freese Appirio I-207995 5/17/2016
                       It is believed that a race condition was occurring on some occasions, in which
                       the former primary contact onAfterUpdate (to uncheck PrimarySalesContact__c) was reaching this point
                       after the new primary contact onAfterInsert, re-setting the Account shipping back to the old address
                       So check for PrimaryBillingContact__c / PrimarySalesContact__c (and remove the else at the start of
                       the Internet Primary block).

                       Also note that there were some instances of [object]TriggerHandler.ExecuteTriggers = false not being followed
                       by [object]TriggerHandler.ExecuteTriggers = true.  The instance in SetPrimarySalesContact() was making the
                       the primary contact insertion disable the onAfterUpdate method (!), preventing this method
                       from being called.  This could equally have been the cause of the current problem.*/
                    if(c.InternetType__c!=Null && c.InternetType__c.contains('Internet Billing')){
                        if(c.PrimaryBillingContact__c == true){
                            conType = 'Billing';
                            for(String aField : billFields.keySet()){
                                String cField = billFields.get(aField);
                                if (c.get(cField) != mapAcc.get(c.AccountId).get(aField)){
                                    a.put(aField, c.get(cField));
                                    fixed += ' ' + aField;
                                }
                            }
                        }
                        else{
                            System.debug('^^^ Ignoring address data for Internet Billing contact ' + c.Id + ' as PrimaryBillingContact__c=' + c.PrimaryBillingContact__c);
                        }
                    }
                        System.debug('Contact to fix is '+ c);

                    if(c.InternetType__c!=Null && c.InternetType__c.contains('Internet Primary')){
                        if(c.PrimarySalesContact__c == true){
                            conType = 'Primary';
                            for(String aField : primFields.keySet()){
                                String cField = primFields.get(aField);
                                if (c.get(cField) != mapAcc.get(c.AccountId).get(aField)){
                                    a.put(aField, c.get(cField));
                                    fixed += ' ' + aField;
                                }
                            }
                        }
                        else{
                            System.debug('^^^ Ignoring address data for Internet Primary contact ' + c.Id + ' as PrimarySalesContact__c=' + c.PrimarySalesContact__c);
                        }
                    }

                    if (fixed != ''){
                        AccountsToUpdate.add(a);
                        system.debug('^^^ Updating account ' + a.id + ' based on ' + conType + ' Contact ' + c.Id + ' (fixed' + fixed + '): ' + a);
                    }
                    else {
                        system.debug('^^^ No changes for account ' + a.id + ' based on ' + conType + ' Contact ' + c.Id + ' InternetType__c=' + c.InternetType__c);
                    }
                }
            }
            if (AccountsToUpdate.size() > 0){
                AccountTriggerHandler.ExecuteTriggers = false;
                update AccountsToUpdate;
                AccountTriggerHandler.ExecuteTriggers = true;
            }
        }
        catch(Exception e){
            ExceptionLog.add('Exception', 'LineItemAttributesTriggerHelper', 'fixEcomm', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to fix key Account field(s) based on Contact.' ,e);
        }
    }
}