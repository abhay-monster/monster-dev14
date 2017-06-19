/*
** @author : Cloud Sherpas Inc.
** @date : 03/03/2014
** @description :   class that supports the '*TriggerHandler' class; it provides the methods called from those classes
*/
public without sharing class TriggerHelper
{
    final String CLASSNAME = '\n\n**** TriggerHelper.METHODNAME()';

    // ********* PROPERTIES ***********
    private String UserProfileName{get; private set;}



/*
** @author : Cloud Sherpas Inc.
** @date : 03/03/2014
** @description : static method that instantiates a new instance of the class & sets the user's profile name member variable
** @paramaters : a string - the profile name for the current user
** @returns : a new instance of the TriggerHelper class
*/
    public static TriggerHelper NewTriggerHelper(String pUserProfileName){

        //final string METHODNAME = CLASSNAME.replace('METHODNAME','NewTriggerHelper');
        //system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        TriggerHelper newHelper = new TriggerHelper(pUserProfileName);
        return newHelper;
    }

/*
** @author : Cloud Sherpas Inc.
** @date : 03/03/2014
** @description : static method that instantiates a new instance of the class
** @paramaters : nothing
** @returns : a new instance of the TriggerHelper class
*/
    public static TriggerHelper NewTriggerHelper(){

        //final string METHODNAME = CLASSNAME.replace('METHODNAME','NewTriggerHelper');
        //system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        TriggerHelper newHelper = new TriggerHelper('');
        return newHelper;
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 03/03/2014
** @description : this method is the class constructor
** @paramaters : none
** @returns : nothing
*/
    private TriggerHelper(String pUserProfileName){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','TriggerHelper');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        UserProfileName = pUserProfileName;
    }
    public TriggerHelper(){
    }

/****************************** ACCOUNT METHODS *******************************/

/*
** @author : Cloud Sherpas, Inc.
** @date : 03/11/2014
** @description : Add the Primary Sales and Service Reps to the Account Team
** @paramaters : Account Array, User Id, User Role String
** @returns : nothing
*/
    public void CreatePrimaryAccountTeamMembers(Account[] pNewAccounts){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','CreatePrimaryAccountTeamMembers');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        list<AccountTeamMember> accountTeamMemberToInsertList = new list<AccountTeamMember>();
        list<Account_Team_Member__c> atmcAccountTeamMemberToInsertList = new list<Account_Team_Member__c>();

        //list of new team members to add
        //AccountShare[] newShareArray = new AccountShare[]{};

        //list of new shares to add
        for(Account oAccount : pNewAccounts){
            AccountTeamMember primarySalesRepMember = new AccountTeamMember();
            primarySalesRepMember.AccountId = oAccount.id;
            primarySalesRepMember.UserId = oAccount.OwnerId;
            primarySalesRepMember.TeamMemberRole = 'Primary Sales Rep';

            accountTeamMemberToInsertList.add(primarySalesRepMember);

            Account_Team_Member__c atmcPrimarySalesRepMember = new Account_Team_Member__c();
            atmcPrimarySalesRepMember.AccountId__c = oAccount.id;
            atmcPrimarySalesRepMember.UserId__c = oAccount.OwnerId;
            atmcPrimarySalesRepMember.TeamMemberRole__c = 'Primary Sales Rep';
            atmcPrimarySalesRepMember.AccountAccessLevel__c = 'Read/Write';
            atmcPrimarySalesRepMember.OpportunityAccessLevel__c = 'Read/Write';
            atmcPrimarySalesRepMember.CaseAccessLevel__c = 'Read/Write';

            atmcAccountTeamMemberToInsertList.add(atmcPrimarySalesRepMember);

            if(oAccount.PrimaryServiceRep__c != NULL){
                AccountTeamMember primaryServiceRepMember = new AccountTeamMember();
                primaryServiceRepMember.AccountId = oAccount.id;
                primaryServiceRepMember.UserId = oAccount.PrimaryServiceRep__c;
                primaryServiceRepMember.TeamMemberRole = 'Primary Service Rep';

                accountTeamMemberToInsertList.add(primaryServiceRepMember);

                Account_Team_Member__c atmcPrimaryServiceRepMember = new Account_Team_Member__c();
                atmcPrimaryServiceRepMember.AccountId__c = oAccount.id;
                atmcPrimaryServiceRepMember.UserId__c = oAccount.PrimaryServiceRep__c;
                atmcPrimaryServiceRepMember.TeamMemberRole__c = 'Primary Service Rep';
                atmcPrimaryServiceRepMember.AccountAccessLevel__c = 'Read/Write';
                atmcPrimaryServiceRepMember.OpportunityAccessLevel__c = 'Read/Write';
                atmcPrimaryServiceRepMember.CaseAccessLevel__c = 'Read/Write';

                atmcAccountTeamMemberToInsertList.add(atmcPrimaryServiceRepMember);

            }
        }

        try{
            if(!accountTeamMemberToInsertList.isEmpty()){
                system.debug('^^^ accountTeamMemberToInsertList='+accountTeamMemberToInsertList);
                CreateNewAccountShare(CreateNewAccountTeamMember(accountTeamMemberToInsertList, Null));
                insert atmcAccountTeamMemberToInsertList;
                //Database.SaveResult[] srList = Database.insert(atmcAccountTeamMemberToInsertList, false);
            }
        }catch(Exception ex){
            throw BaseApplicationException.NewException(METHODNAME, ex.getMessage());
        }
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 03/11/2014
** @description : ...q
** @paramaters : Account Id Set, Primary Team Member Type to List of Accounts Map
** @returns : nothing
*/
    public void UpdatePrimaryAccountTeamMembers2(set<Id> pAccountIdSet ,map<String, list<Account>> pPrimaryTeamMemberTypeToListOfAccountsMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','UpdatePrimaryAccountTeamMembers2');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        if (!pPrimaryTeamMemberTypeToListOfAccountsMap.isEmpty()) {
            Map<Id, List<Account_Team_Member__c>> customTeamMembers = new Map<Id, List<Account_Team_Member__c>>();
            for(Account_Team_Member__c team : [SELECT Id, UserId__c, TeamMemberRole__c, AccountId__c FROM Account_Team_Member__c WHERE AccountId__c IN : pAccountIdSet]){
                if (customTeamMembers.get(team.AccountId__c) == null) {
                    customTeamMembers.put(team.AccountId__c, new List<Account_Team_Member__c>());
                }
                customTeamMembers.get(team.AccountId__c).add(team);
            }
            Map<Id, List<AccountTeamMember>> standardTeamMembers = new Map<Id, List<AccountTeamMember>>();
            for(AccountTeamMember team : [SELECT Id, UserId, TeamMemberRole, AccountId FROM AccountTeamMember WHERE AccountId IN : pAccountIdSet]){
                if (standardTeamMembers.get(team.AccountId) == null) {
                    standardTeamMembers.put(team.AccountId, new List<AccountTeamMember>());
                }
                standardTeamMembers.get(team.AccountId).add(team);
            }

            Map<Id,Account_Team_Member__c> userIdToCustomAccountTeamMemberMap = new Map<Id,Account_Team_Member__c>();
            List<Account_Team_Member__c> customTeamMembersToInsert = new List<Account_Team_Member__c>();
            List<Account_Team_Member__c> customTeamMembersToDelete = new List<Account_Team_Member__c>();
            List<AccountTeamMember> standardTeamMembersToInsert = new List<AccountTeamMember>();
            List<AccountTeamMember> standardTeamMembersToDelete = new List<AccountTeamMember>();
            Boolean hasPrimarySalesRep = false;
            if (pPrimaryTeamMemberTypeToListOfAccountsMap.containsKey('PrimarySalesRep')) {
                for (Account act : pPrimaryTeamMemberTypeToListOfAccountsMap.get('PrimarySalesRep')) {
                    hasPrimarySalesRep = false;
                    // custom account team member
                    if (customTeamMembers.containsKey(act.Id)) {
                        for (Account_Team_Member__c teamMember : customTeamMembers.get(act.Id)) {
                            if (teamMember.TeamMemberRole__c == 'Primary Sales Rep') {
                                if (!hasPrimarySalesRep) {
                                    if (teamMember.UserId__c != act.OwnerId) {
                                        // to delete
                                        customTeamMembersToDelete.add(teamMember);
                                    } else {
                                        hasPrimarySalesRep = true;
                                    }
                                } else {
                                    // to delete
                                    customTeamMembersToDelete.add(teamMember);
                                }
                            }
                        }
                    }
                    // no primary sales rep found
                    if (!hasPrimarySalesRep) {
                        // to insert
                        Account_Team_Member__c newTeamMember = new Account_Team_Member__c(
                            AccountId__c = act.Id,
                            UserId__c = act.OwnerId,
                            TeamMemberRole__c = 'Primary Sales Rep',
                            AccountAccessLevel__c = 'Read/Write',
                            OpportunityAccessLevel__c = 'Read/Write',
                            CaseAccessLevel__c = 'Read/Write'
                        );
                        customTeamMembersToInsert.add(newTeamMember);
                        userIdToCustomAccountTeamMemberMap.put(act.OwnerId, newTeamMember);
                    }

                    hasPrimarySalesRep = false;
                    // standard account team member
                    if (standardTeamMembers.containsKey(act.Id)) {
                        for (AccountTeamMember teamMember : standardTeamMembers.get(act.Id)) {
                            if (teamMember.TeamMemberRole == 'Primary Sales Rep') {
                                if (!hasPrimarySalesRep) {
                                    if (teamMember.UserId != act.OwnerId) {
                                        // to delete
                                        standardTeamMembersToDelete.add(teamMember);
                                    } else {
                                        hasPrimarySalesRep = true;
                                    }
                                } else {
                                    // to delete
                                    standardTeamMembersToDelete.add(teamMember);
                                }
                            }
                        }
                    }
                    // no primary sales rep found
                    if (!hasPrimarySalesRep) {
                        // to insert
                        AccountTeamMember newTeamMember = new AccountTeamMember(
                            AccountId = act.Id,
                            UserId = act.OwnerId,
                            TeamMemberRole = 'Primary Sales Rep'
                        );
                        standardTeamMembersToInsert.add(newTeamMember);
                    }

                }
            }

            // delete
            Database.DeleteResult[] srListDeleteCustom = Database.delete(customTeamMembersToDelete, false);
            Database.DeleteResult[] srListDeleteStandard = Database.delete(standardTeamMembersToDelete, false);
            //delete customTeamMembersToDelete;
            //delete standardTeamMembersToDelete;

            // insert
            //insert customTeamMembersToInsert;
            //insert standardTeamMembersToInsert;
            if(!customTeamMembersToInsert.isEmpty()){

                // remove any list items from that contain null User Ids for Account Team Members to be inserted
                list<Account_Team_Member__c> validatedCustomAccountTeamMemberToInsertList = CreateValidateCustomAccountTeamMemberList(customTeamMembersToInsert);

                // insert list of Custom Account Team Members
                if(!validatedCustomAccountTeamMemberToInsertList.isEmpty()){
                    InsertCustomAccountTeamMembers(validatedCustomAccountTeamMemberToInsertList);
                }
            }
            insert standardTeamMembersToInsert;
            // create new Account Share for newly createded Account Team Members
            /*if (!standardTeamMembersToInsert.isEmpty()) {
                CreateNewAccountShare(CreateNewAccountTeamMember(standardTeamMembersToInsert, userIdToCustomAccountTeamMemberMap));
            }*/
        }
    }

    public void UpdatePrimaryAccountTeamMembers(set<Id> pAccountIdSet ,map<String, list<Account>> pPrimaryTeamMemberTypeToListOfAccountsMap){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','UpdatePrimaryAccountTeamMembers');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Boolean hasPrimarySalesRep;
        Boolean hasPrimaryServiceRep;
        Integer count = 0;

        // create list for insert
        list<AccountTeamMember> accountTeamMemberToInsertList = new list<AccountTeamMember>();
        list<Account_Team_Member__c> customAccountTeamMembersToInsertList = new list<Account_Team_Member__c>();

        // create list for update
        list<AccountTeamMember> accountTeamMembersToUpdateList = new list<AccountTeamMember>();
        list<Account_Team_Member__c> customAccountTeamMembersToUpdateList = new list<Account_Team_Member__c>();
        list<AccountTeamMember> accountTeamMembersToUpdateListUpdated = new list<AccountTeamMember>();
        list<Account_Team_Member__c> customAccountTeamMembersToUpdateListUpdated = new list<Account_Team_Member__c>();
        list<Account_Team_Member__c> customAccountTeamMembersToDeleteList = new list<Account_Team_Member__c>();
        list<AccountTeamMember> accountTeamMembersToDeleteList = new list<AccountTeamMember>();
        Set<Id> prevPrimary = new Set<Id>();
        // create User Id to Custom Account Team Member map for setting Account Sharing rules
        map<Id,Account_Team_Member__c> userIdToCustomAccountTeamMemberMap = new map<Id,Account_Team_Member__c>();

        // create and populate a list of Accounts related to Account Team Members
        system.debug('!!!pAccountIdSet' + pAccountIdSet);
        list<Account> accountList = [SELECT Id, PrimaryServiceRep__c, (SELECT Id, AccountId, UserId, TeamMemberRole FROM AccountTeamMembers) FROM Account WHERE Id IN : pAccountIdSet];

        // create and populate a list of Custom Account Team Members related to the Accounts related to Account Team Members
        list<Account_Team_Member__c> customAccountTeamMemberList = [SELECT Id, AccountId__c, UserId__c, AccountAccessLevel__c, OpportunityAccessLevel__c, CaseAccessLevel__c FROM Account_Team_Member__c WHERE AccountId__c IN : pAccountIdSet];
        system.debug('!!!custom' + customAccountTeamMemberList);
        // create an Account Id to a map of User Id to Custom Account Team Member map
        map<Id, map<Id, Account_Team_Member__c>> accountIdToMapOfUserIdToCustomAccountTeamMemberMap = new  map<Id, map<Id, Account_Team_Member__c>>();

        map<id,id> primaryaccountIdUserIdMap = new map<id,id>();

        // load the Account Id to a map of User Id to Custom Account Team Member map
        for(Account_Team_Member__c oCustomAccountTeamMember : customAccountTeamMemberList){
            if(accountIdToMapOfUserIdToCustomAccountTeamMemberMap.ContainsKey(oCustomAccountTeamMember.AccountId__c)){
                accountIdToMapOfUserIdToCustomAccountTeamMemberMap.get(oCustomAccountTeamMember.AccountId__c).put(oCustomAccountTeamMember.UserId__c, oCustomAccountTeamMember);
            }else{
                accountIdToMapOfUserIdToCustomAccountTeamMemberMap.put(oCustomAccountTeamMember.AccountId__c, new map<Id, Account_Team_Member__c>());
                accountIdToMapOfUserIdToCustomAccountTeamMemberMap.get(oCustomAccountTeamMember.AccountId__c).put(oCustomAccountTeamMember.UserId__c, oCustomAccountTeamMember);
            }
        }
        system.debug('!!!' + pPrimaryTeamMemberTypeToListOfAccountsMap.get('PrimarySalesRep'));
        system.debug('!!!accountList' + accountList);
        for(Account oAccount : accountList){
            if(pPrimaryTeamMemberTypeToListOfAccountsMap.get('PrimarySalesRep') != NULL){
                for(Account oAccountPrimarySaleRep : pPrimaryTeamMemberTypeToListOfAccountsMap.get('PrimarySalesRep')){

                    hasPrimarySalesRep = false;
                    system.debug('!!!standard' + oAccount.AccountTeamMembers);
                    for(AccountTeamMember oAccountTeamMember : oAccount.AccountTeamMembers){

                        // Remove the current Primary Sales Rep by setting Team Member Role to Sales Rep
                        if(oAccountTeamMember.AccountId == oAccountPrimarySaleRep.Id && oAccountTeamMember.TeamMemberRole == 'Primary Sales Rep' ){
                            //oAccountTeamMember.TeamMemberRole = 'Sales Rep';
                            //accountTeamMembersToUpdateList.add(oAccountTeamMember);
                            accountTeamMembersToDeleteList.add(oAccountTeamMember);

                            // Remove the current Primary Sales Rep by setting Custom Team Member Role to Sales Rep
                            if(accountIdToMapOfUserIdToCustomAccountTeamMemberMap.containskey(oAccountTeamMember.AccountId)){
                                if(accountIdToMapOfUserIdToCustomAccountTeamMemberMap.get(oAccountTeamMember.AccountId).containskey(oAccountTeamMember.UserId)){
                                    accountIdToMapOfUserIdToCustomAccountTeamMemberMap.get(oAccountTeamMember.AccountId).get(oAccountTeamMember.UserId).TeamMemberRole__c = 'Unassigned';
                                    //customAccountTeamMembersToUpdateList.add(accountIdToMapOfUserIdToCustomAccountTeamMemberMap.get(oAccountTeamMember.AccountId).get(oAccountTeamMember.UserId));
                                    customAccountTeamMembersToDeleteList.add(accountIdToMapOfUserIdToCustomAccountTeamMemberMap.get(oAccountTeamMember.AccountId).get(oAccountTeamMember.UserId));
                                }
                            }
                        }
                        // User is already an Account Team Member - Update from current role to Primary Sales Rep
                        if(oAccountTeamMember.AccountId == oAccountPrimarySaleRep.Id && oAccountTeamMember.UserId == oAccountPrimarySaleRep.OwnerId && oAccountTeamMember.TeamMemberRole == 'Sales Rep'){
                            oAccountTeamMember.TeamMemberRole = 'Primary Sales Rep';
                            primaryaccountIdUserIdMap.put(oAccountTeamMember.AccountId,oAccountTeamMember.UserId);
                            accountTeamMembersToUpdateList.add(oAccountTeamMember);
                            hasPrimarySalesRep = true;

                            if(accountIdToMapOfUserIdToCustomAccountTeamMemberMap.containskey(oAccountTeamMember.AccountId)){
                                if(accountIdToMapOfUserIdToCustomAccountTeamMemberMap.get(oAccountTeamMember.AccountId).containskey(oAccountTeamMember.UserId)){
                                    accountIdToMapOfUserIdToCustomAccountTeamMemberMap.get(oAccountTeamMember.AccountId).get(oAccountTeamMember.UserId).TeamMemberRole__c = 'Primary Sales Rep';
                                    customAccountTeamMembersToUpdateList.add(accountIdToMapOfUserIdToCustomAccountTeamMemberMap.get(oAccountTeamMember.AccountId).get(oAccountTeamMember.UserId));
                                }
                            }
                        }
                    }

                    if(!hasPrimarySalesRep){
                        count++;
                        system.debug('@@@ count - '+ count);
                        AccountTeamMember primarySalesRepMember = new AccountTeamMember();
                        primarySalesRepMember.AccountId = oAccountPrimarySaleRep.Id;
                        primarySalesRepMember.UserId = oAccountPrimarySaleRep.OwnerId;
                        primarySalesRepMember.TeamMemberRole = 'Primary Sales Rep';

                        accountTeamMemberToInsertList.add(primarySalesRepMember);

                        Account_Team_Member__c customPrimarySalesRepMember = new Account_Team_Member__c();
                        customPrimarySalesRepMember.AccountId__c =  oAccountPrimarySaleRep.Id;
                        customPrimarySalesRepMember.UserId__c =  oAccountPrimarySaleRep.OwnerId;
                        customPrimarySalesRepMember.TeamMemberRole__c = 'Primary Sales Rep';
                        customPrimarySalesRepMember.AccountAccessLevel__c = 'Read/Write';
                        customPrimarySalesRepMember.OpportunityAccessLevel__c = 'Read/Write';
                        customPrimarySalesRepMember.CaseAccessLevel__c = 'Read/Write';

                        customAccountTeamMembersToInsertList.add(customPrimarySalesRepMember);
                        userIdToCustomAccountTeamMemberMap.put(oAccountPrimarySaleRep.OwnerId, customPrimarySalesRepMember);

                    }
                }
            }

            if(pPrimaryTeamMemberTypeToListOfAccountsMap.get('PrimaryServiceRep') != NULL){

                for(Account oAccountPrimaryServiceRep : pPrimaryTeamMemberTypeToListOfAccountsMap.get('PrimaryServiceRep')){

                    hasPrimaryServiceRep = false;

                    for(AccountTeamMember oAccountTeamMember : oAccount.AccountTeamMembers){

                        // Remove the current Primary Service Rep by setting Team Member Role to Service Rep
                        if(oAccountTeamMember.AccountId == oAccountPrimaryServiceRep.Id && oAccountTeamMember.TeamMemberRole == 'Primary Service Rep'){
                            oAccountTeamMember.TeamMemberRole = 'Service Rep';
                            accountTeamMembersToUpdateList.add(oAccountTeamMember);

                            if(accountIdToMapOfUserIdToCustomAccountTeamMemberMap.containskey(oAccountTeamMember.AccountId)){
                                if(accountIdToMapOfUserIdToCustomAccountTeamMemberMap.get(oAccountTeamMember.AccountId).containskey(oAccountTeamMember.UserId)){
                                    accountIdToMapOfUserIdToCustomAccountTeamMemberMap.get(oAccountTeamMember.AccountId).get(oAccountTeamMember.UserId).TeamMemberRole__c = 'Service Rep';
                                    customAccountTeamMembersToUpdateList.add(accountIdToMapOfUserIdToCustomAccountTeamMemberMap.get(oAccountTeamMember.AccountId).get(oAccountTeamMember.UserId));
                                }
                            }
                        }

                        // User is already an Account Team Member - Update from current role to Primary Service Rep
                        if(oAccountTeamMember.AccountId == oAccountPrimaryServiceRep.Id && oAccountTeamMember.UserId == oAccountPrimaryServiceRep.PrimaryServiceRep__c && oAccountTeamMember.TeamMemberRole == 'Service Rep'){
                            if(oAccountPrimaryServiceRep.OwnerId == oAccountPrimaryServiceRep.PrimaryServiceRep__c){
                                oAccountTeamMember.TeamMemberRole = 'Primary Sales/Service Rep';
                            }else{
                                oAccountTeamMember.TeamMemberRole = 'Primary Service Rep';
                            }
                            accountTeamMembersToUpdateList.add(oAccountTeamMember);
                            hasPrimaryServiceRep = true;

                            if(accountIdToMapOfUserIdToCustomAccountTeamMemberMap.containskey(oAccountTeamMember.AccountId)){
                                if(accountIdToMapOfUserIdToCustomAccountTeamMemberMap.get(oAccountTeamMember.AccountId).containskey(oAccountTeamMember.UserId)){
                                    accountIdToMapOfUserIdToCustomAccountTeamMemberMap.get(oAccountTeamMember.AccountId).get(oAccountTeamMember.UserId).TeamMemberRole__c = 'Primary Service Rep';
                                    customAccountTeamMembersToUpdateList.add(accountIdToMapOfUserIdToCustomAccountTeamMemberMap.get(oAccountTeamMember.AccountId).get(oAccountTeamMember.UserId));
                                }
                            }
                        }
                    }

                    if(!hasPrimaryServiceRep){
                        AccountTeamMember primaryServiceRepMember = new AccountTeamMember();
                        primaryServiceRepMember.AccountId = oAccount.id;
                        primaryServiceRepMember.UserId = oAccount.PrimaryServiceRep__c;
                        if(oAccountPrimaryServiceRep.OwnerId == oAccountPrimaryServiceRep.PrimaryServiceRep__c){
                            primaryServiceRepMember.TeamMemberRole = 'Primary Sales/Service Rep';
                        }else{
                            primaryServiceRepMember.TeamMemberRole = 'Primary Service Rep';
                        }

                        accountTeamMemberToInsertList.add(primaryServiceRepMember);

                        Account_Team_Member__c customPrimaryServiceRepMember = new Account_Team_Member__c();
                        customPrimaryServiceRepMember.AccountId__c = oAccount.id;
                        customPrimaryServiceRepMember.UserId__c = oAccount.PrimaryServiceRep__c;
                        customPrimaryServiceRepMember.TeamMemberRole__c = 'Primary Service Rep';
                        customPrimaryServiceRepMember.AccountAccessLevel__c = 'Read/Write';
                        customPrimaryServiceRepMember.OpportunityAccessLevel__c = 'Read/Write';
                        customPrimaryServiceRepMember.CaseAccessLevel__c = 'Read/Write';

                        customAccountTeamMembersToInsertList.add(customPrimaryServiceRepMember);
                        userIdToCustomAccountTeamMemberMap.put(oAccount.PrimaryServiceRep__c,customPrimaryServiceRepMember);
                    }
                }
            }
        }
        // Update Account Team Members and Custom Account Team Members

        if(!accountTeamMembersToUpdateList.isEmpty()){
            UpdateAccountTeamMembers(accountTeamMembersToUpdateList);
            UpdateCustomAccountTeamMembers(customAccountTeamMembersToUpdateList);

         /*
            //check if the Account has primary service rep if not add it to oldest remaining service rep on the team
            // create and populate a list of Accounts related to Account Team Members
            set<Account> updatedaccountList = new set<Account>();
            Integer NumOfPriRep = 0;
            Integer NumOfServiceRep = 0;
            for(Account oAccount : [SELECT Id, PrimaryServiceRep__c, (SELECT Id, AccountId, UserId, TeamMemberRole FROM AccountTeamMembers order by CreatedDate asc) FROM Account WHERE Id IN : pAccountIdSet]){

               for(AccountTeamMember oAccountTeamMember : oAccount.AccountTeamMembers){
                   if(oAccountTeamMember.TeamMemberRole == 'Primary Service Rep'){
                       updatedaccountList.add(oAccount);
                       NumOfPriRep++;
                   }else if(oAccountTeamMember.TeamMemberRole == 'Service Rep'){
                       updatedaccountList.add(oAccount);
                       NumOfServiceRep++;
                   }
               }
            }

            // create and populate a list of Custom Account Team Members related to the Accounts related to Account Team Members
           // list<Account_Team_Member__c> updatedcustomAccountTeamMemberList = [SELECT Id, AccountId__c, UserId__c, AccountAccessLevel__c, OpportunityAccessLevel__c, CaseAccessLevel__c FROM Account_Team_Member__c WHERE AccountId__c IN : pAccountIdSet];

            if(NumOfPriRep == 0 && NumOfServiceRep > 0){
                for(Account oAccount : updatedaccountList ){
                    if(!oAccount.AccountTeamMembers.isEmpty()){
                        for(AccountTeamMember ATM: oAccount.AccountTeamMembers){
                            if(ATM.TeamMemberRole == 'Service Rep'){
                                ATM.TeamMemberRole = 'Primary Service Rep';
                                accountTeamMembersToUpdateListUpdated.add(ATM);
                                if(accountIdToMapOfUserIdToCustomAccountTeamMemberMap.containskey(ATM.AccountId)){
                                    if(accountIdToMapOfUserIdToCustomAccountTeamMemberMap.get(ATM.AccountId).containskey(ATM.UserId)){
                                        accountIdToMapOfUserIdToCustomAccountTeamMemberMap.get(ATM.AccountId).get(ATM.UserId).TeamMemberRole__c = 'Primary Service Rep';
                                        customAccountTeamMembersToUpdateListUpdated.add(accountIdToMapOfUserIdToCustomAccountTeamMemberMap.get(ATM.AccountId).get(ATM.UserId));
                                    }
                                }
                                break;
                            }
                        }
                    }
                }
            }

            UpdateAccountTeamMembers(accountTeamMembersToUpdateListUpdated);
            UpdateCustomAccountTeamMembers(customAccountTeamMembersToUpdateListUpdated);*/
        }
        if(!accountTeamMembersToDeleteList.isEmpty()){
            //delete accountTeamMembersToDeleteList;
            Database.DeleteResult[] srListDelete = Database.delete(accountTeamMembersToDeleteList, false);
        }
        if(!customAccountTeamMembersToDeleteList.isEmpty()){
            //delete customAccountTeamMembersToDeleteList;
            Database.DeleteResult[] srListDelete = Database.delete(customAccountTeamMembersToDeleteList, false);
        }
        // Insert new Custom Account Team Members
        if(!customAccountTeamMembersToInsertList.isEmpty()){

            // remove any list items from that contain null User Ids for Account Team Members to be inserted
            list<Account_Team_Member__c> validatedCustomAccountTeamMemberToInsertList = CreateValidateCustomAccountTeamMemberList(customAccountTeamMembersToInsertList);

            // insert list of Custom Account Team Members
            if(!validatedCustomAccountTeamMemberToInsertList.isEmpty()){
                InsertCustomAccountTeamMembers(validatedCustomAccountTeamMemberToInsertList);
            }
        }

        // create new Account Share for newly createded Account Team Members
        if(!accountTeamMemberToInsertList.isEmpty()){
            CreateNewAccountShare(CreateNewAccountTeamMember(accountTeamMemberToInsertList, userIdToCustomAccountTeamMemberMap));
        }
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 03/11/2014
** @description : ...
** @paramaters : none
** @returns : nothing
*/
    private AccountTeamMember CreatePrimaryAccountTeamMember(Account pAccount){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','CreatePrimaryAccountTeamMember');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        AccountTeamMember primarySalesRepMember = new AccountTeamMember(AccountId = pAccount.id, UserId = pAccount.OwnerId, TeamMemberRole = 'Primary Sales Rep');
        return primarySalesRepMember;
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 03/11/2014
** @description : Validates list by removing any list items that contains null User Ids for Custom Account Team Members
** @paramaters : Custom Account Team Member list
** @returns : Custom Account Team Member list
*/
    private void InsertCustomAccountTeamMembers(list<Account_Team_Member__c> pValidatedCustomAccountTeamMemberToInsertList){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','InsertCustomAccountTeamMembers');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        try{
            //insert pValidatedCustomAccountTeamMemberToInsertList;
            Database.SaveResult[] srList = Database.insert(pValidatedCustomAccountTeamMemberToInsertList, false);
        }catch(DMLException dmlex){
            throw BaseApplicationException.NewException(METHODNAME, dmlex.getMessage(), 'Update to Custom Account Team Members Failed');
        }
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 03/11/2014
** @description : Validates list by removing any list items that contains null User Ids for Custom Account Team Members
** @paramaters : Custom Account Team Member list
** @returns : Custom Account Team Member list
*/
    private list<Account_Team_Member__c> CreateValidateCustomAccountTeamMemberList(list<Account_Team_Member__c> pCustomAccountTeamMemberList){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','CreateValidateCustomAccountTeamMemberList');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        list<Account_Team_Member__c> validatedCustomAccountTeamMemberList = new list<Account_Team_Member__c>();

        for(Account_Team_Member__c oCustomAccountTeamMember : pCustomAccountTeamMemberList){
            if(!String.isBlank(oCustomAccountTeamMember.UserId__c )){
                validatedCustomAccountTeamMemberList.add(oCustomAccountTeamMember);
            }
        }

        return validatedCustomAccountTeamMemberList;
    }


/*
** @author : Cloud Sherpas, Inc.
** @date : 03/11/2014
** @description : Updates list of Custom Account Team Members
** @paramaters : Custom Account Team Member list
** @returns : Nothing
*/
    private void UpdateCustomAccountTeamMembers(list<Account_Team_Member__c> pCustomAccountTeamMembersToUpdateList){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','UpdateCustomAccountTeamMembers');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        try{
            /*Set<Account_Team_Member__c> t = new set<Account_Team_Member__c>();
            t.addAll(pCustomAccountTeamMembersToUpdateList);
            Account_Team_Member__c[] newList = new Account_Team_Member__c[]{};
            newList.addAll(t);
            system.debug('^^^^^^^^^^^^^^^^!' + newList);
            Database.SaveResult[] srList = Database.update(newList, false);
            //system.debug('^^^^^^^^^^^^^^^^!' + pCustomAccountTeamMembersToUpdateList);
            //update newList;
            */
            //update pCustomAccountTeamMembersToUpdateList;
            Database.SaveResult[] srList = Database.update(pCustomAccountTeamMembersToUpdateList, false);
        }catch(DMLException dmlex){
            throw BaseApplicationException.NewException(METHODNAME, dmlex.getMessage(), 'Update to Custom Account Team Members Failed');
        }
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 03/11/2014
** @description : Updates list of Account Team Members
** @paramaters : Account Team Member list
** @returns : Nothing
*/
    private void UpdateAccountTeamMembers(list<AccountTeamMember> pAccountTeamMemberToUpdateList){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','UpdateAccountTeamMembers');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        try{
            /*Set<AccountTeamMember> t = new set<AccountTeamMember>();
            t.addAll(pAccountTeamMemberToUpdateList);
            AccountTeamMember[] newList = new AccountTeamMember[]{};
            newList.addAll(t);
            Database.SaveResult[] srList = Database.update(newList, false);
            //update newList;
            ----------------------------------------------
            system.debug('^^^^^^^^^^^^^^^^!' + pAccountTeamMemberToUpdateList);
            */
            //update pAccountTeamMemberToUpdateList;
            Database.SaveResult[] srList = Database.update(pAccountTeamMemberToUpdateList, false);
        }catch(DMLException dmlex){
            throw BaseApplicationException.NewException(METHODNAME, dmlex.getMessage(), 'Update to Account Team Memebers Failed');
        }
    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 03/11/2014
** @description : ...
** @paramaters : Account Team Member list
** @returns : Account Share list
*/
    private list<AccountShare> CreateNewAccountTeamMember(list<AccountTeamMember> pAccountTeamMemberToInsertList, map<Id,Account_Team_Member__c> pUserIdToCustomAccountTeamMemberMap){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','CreateNewAccountTeamMember');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        list<AccountShare> accountShareToInsertList = new list<AccountShare>();

        Database.SaveResult[] teamMemberSaveResults = Database.insert(pAccountTeamMemberToInsertList,false);

        //insert any valid members then add their share entry if they were successfully added
        Integer newMemberCnt=0;

        for(Database.SaveResult saveResult : teamMemberSaveResults){
            if(!saveResult.isSuccess()){
                Database.Error saveResultErrorMessage =saveResult.getErrors()[0];
                system.debug(LoggingLevel.DEBUG, METHODNAME + '\n\nERROR ADDING TEAM MEMBER:'+ saveResultErrorMessage);
            }else{
                if(pUserIdToCustomAccountTeamMemberMap != NULL){
                    if(!pUserIdToCustomAccountTeamMemberMap.IsEmpty()){
                        if(pUserIdToCustomAccountTeamMemberMap.containsKey(pAccountTeamMemberToInsertList[newMemberCnt].UserId)){
                            accountShareToInsertList.add(new AccountShare(UserOrGroupId=pAccountTeamMemberToInsertList[newMemberCnt].UserId,
                                                                            AccountId=pAccountTeamMemberToInsertList[newMemberCnt].Accountid,
                                                                            AccountAccessLevel= (pUserIdToCustomAccountTeamMemberMap.get(pAccountTeamMemberToInsertList[newMemberCnt].UserId).AccountAccessLevel__c != null) ? pUserIdToCustomAccountTeamMemberMap.get(pAccountTeamMemberToInsertList[newMemberCnt].UserId).AccountAccessLevel__c : 'Edit',
                                                                            OpportunityAccessLevel=(pUserIdToCustomAccountTeamMemberMap.get(pAccountTeamMemberToInsertList[newMemberCnt].UserId).OpportunityAccessLevel__c != null) ? pUserIdToCustomAccountTeamMemberMap.get(pAccountTeamMemberToInsertList[newMemberCnt].UserId).OpportunityAccessLevel__c : 'Edit',
                                                                            CaseAccessLevel=(pUserIdToCustomAccountTeamMemberMap.get(pAccountTeamMemberToInsertList[newMemberCnt].UserId).CaseAccessLevel__c != null) ? pUserIdToCustomAccountTeamMemberMap.get(pAccountTeamMemberToInsertList[newMemberCnt].UserId).CaseAccessLevel__c : 'Edit'));
                        }
                    }else{
                        accountShareToInsertList.add(new AccountShare(UserOrGroupId=pAccountTeamMemberToInsertList[newMemberCnt].UserId, AccountId=pAccountTeamMemberToInsertList[newMemberCnt].Accountid, AccountAccessLevel='Edit',OpportunityAccessLevel='Edit',CaseAccessLevel='Edit'));
                    }
                }else{
                    accountShareToInsertList.add(new AccountShare(UserOrGroupId=pAccountTeamMemberToInsertList[newMemberCnt].UserId, AccountId=pAccountTeamMemberToInsertList[newMemberCnt].Accountid, AccountAccessLevel='Edit',OpportunityAccessLevel='Edit',CaseAccessLevel='Edit'));
                }
            }
            newMemberCnt++;
        }

        return accountShareToInsertList;
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 03/11/2014
** @description : ...
** @paramaters : AccountShare list
** @returns : nothing
*/
    private void CreateNewAccountShare(list<AccountShare> pAccountShareToInsertList){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','CreateNewAccountShare');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        system.debug('^^^ pAccountShareToInsertList='+pAccountShareToInsertList);

        Database.SaveResult[] sharingRuleSaveResult = Database.insert(pAccountShareToInsertList,false);

        //insert the new shares
        Integer newShareCnt = 0;

        for(Database.SaveResult saveResult: sharingRuleSaveResult){
            if(!saveResult.isSuccess()){
                Database.Error saveResultErrorMessage = saveResult.getErrors()[0];
                system.debug(LoggingLevel.DEBUG, METHODNAME + '\n\nERROR ADDING SHARING:'+ pAccountShareToInsertList[newShareCnt]+'::'+ saveResultErrorMessage);
            }
            newShareCnt++;
        }
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 03/11/2014
** @description : Update the Contact Organization__c when the Account Organization__c field is changed
** @paramaters : Account Id Set
** @returns : nothing
*/
    public void UpdateContactOrganization(Set<Id> pAccountIdSet){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','UpdateContactOrganization');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        list<Contact> contactsToUpdate = new list<Contact>();
        list<Account> updateContactOrganizationAccountList = [Select Id, Organization__c, (SELECT Id, Organization__c FROM Contacts) FROM Account WHERE Id IN : pAccountIdSet];

        for(Account oAccount : updateContactOrganizationAccountList){
            for(Contact oContact : oAccount.Contacts){
                oContact.Organization__c = oAccount.Organization__c;
                contactsToUpdate.add(oContact);
            }
        }

        if(!contactsToUpdate.isEmpty()){
            update contactsToUpdate;
        }
    }


/*
** @author : Cloud Sherpas, Inc.
** @date : 03/11/2014
** @description : Update the Contact Organization__c when the Account Organization__c field is changed
** @paramaters : Account Id Set
** @returns : nothing
*/
    public void SyncStandardAndCustomAccountTeamMembers(set<id> accIds){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','SyncStandardAndCustomAccountTeamMembers');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        list<Account_Team_Member__c> UnSyncedTeamMembers  = new list<Account_Team_Member__c>();
        list<Account> QueriedAccountList = new list<Account>();
        //This will get us the Accounts where Keep Account Team is Unchecked while changing the Owner.
        for(Account oAccount: [SELECT id,(SELECT Id, AccountId, UserId, TeamMemberRole FROM AccountTeamMembers),(SELECT Id, AccountId__c, UserId__c, TeamMemberRole__c FROM Account_Team_Members__r) FROM Account WHERE Id IN:accIds]){
            QueriedAccountList.add(oAccount);
            if(!oAccount.AccountTeamMembers.isEmpty() && !oAccount.Account_Team_Members__r.isEmpty()){
                if(oAccount.AccountTeamMembers.size() != oAccount.Account_Team_Members__r.size()){
                    for(Account_Team_Member__c CustomAccountTeamMember : oAccount.Account_Team_Members__r){
                        if(CustomAccountTeamMember.UserId__c == oAccount.AccountTeamMembers[0].UserId){
                            if(CustomAccountTeamMember.TeamMemberRole__c != oAccount.AccountTeamMembers[0].TeamMemberRole ){
                                UnSyncedTeamMembers.add(CustomAccountTeamMember);
                            }
                        }
                    }
                }
            }
        }

        for(Account oAccount : QueriedAccountList){
            if(!oAccount.AccountTeamMembers.isEmpty() && !oAccount.Account_Team_Members__r.isEmpty()){
                if(oAccount.AccountTeamMembers.size() != oAccount.Account_Team_Members__r.size()){
                    for(Account_Team_Member__c CustomAccountTeamMember : oAccount.Account_Team_Members__r){
                        if(CustomAccountTeamMember.UserId__c != oAccount.AccountTeamMembers[0].UserId){
                            UnSyncedTeamMembers.add(CustomAccountTeamMember);
                        }
                    }
                }
            }
        }
        if(!UnSyncedTeamMembers.isEmpty()){
            try{
                delete UnSyncedTeamMembers;
            }catch(Exception e){
                System.debug('Exception is **'+e);
            }
        }
    }

 /********************************* ACCOUNT TEAM MEMBER METHODS **********************************************/
 /*
** @author : Cloud Sherpas, Inc.
** @date : 03/13/2014
** @description : ...
** @paramaters : none
** @returns : nothing
*/
   /* public void updateAccountDataLastTeamed(list<Account_Team_Member__c> pAccountTeamMemberList){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateAccountDataLastTeamed');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        set<Id> AccountIds = new set<Id>();
        Map<Id,List<Account_Team_Member__c>> AccountTeamMembersPerAccountMap = new Map<Id,List<Account_Team_Member__c>>();
        for(Account_Team_Member__c atm : pAccountTeamMemberList){
            //AccountIds.add(atm.AccountId__c);
            AccountTeamMembersPerAccountMap.put(atm.AccountId__c, null);
        }

        if(!AccountIds.isEmpty()){
            List<Account_Team_Member__c> ATMList = [SELECT Id, TeamMemberRole__c FROM Account_Team_Member__c WHERE AccountId__c IN: AccountTeamMembersPerAccountMap.KeySet() AND TeamMemberRole__c = 'Sales Rep'];
            for(Account_Team_Member__c acc : ATMList){
                system.debug('^acc.TeamMemberRole__c: '+acc.TeamMemberRole__c);
                if(!AccountTeamMembersPerAccountMap.containsKey(acc.AccountId__c)){
                    AccountTeamMembersPerAccountMap.get(acc.AccountId__c).add(acc);
                }
            }
        }
        system.debug('^AccountTeamMembersPerAccountMap: '+AccountTeamMembersPerAccountMap);
        Map<Id, Datetime> AccountDAteTeamedMap = new Map<Id,Datetime>();
        for(Account_Team_Member__c atm : pAccountTeamMemberList){
            if(AccountTeamMembersPerAccountMap.containsKey(atm.AccountId__c) && AccountTeamMembersPerAccountMap.get(atm.AccountId__c) == null){
                AccountDAteTeamedMap.put(atm.AccountId__c, system.now());
            }
        }
        system.debug('^AccountDAteTeamedMap: '+AccountDAteTeamedMap);
        List<Account> AccountToBeUpdated = new List<Account>();
        for(Account acc : [SELECT Id FROM Account WHERE Id IN: AccountDAteTeamedMap.keySet()]){
            AccountToBeUpdated.add(acc);
        }

        if(!AccountToBeUpdated.isEmpty()){
            update AccountToBeUpdated;
        }
    }*/
/*
** @author : Cloud Sherpas, Inc.
** @date : 03/13/2014
** @description : ...
** @paramaters : none
** @returns : nothing
*/
    public void updateAccountDataLastUnteamed(list<Account_Team_Member__c> pAccountTeamMemberList){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateAccountDataLastUnteamed');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        try{
            set<Id> AccountIds = new set<Id>();
            for(Account_Team_Member__c atm : pAccountTeamMemberList){
                if(atm.TeamMemberRole__c == 'Sales Rep'){
                    AccountIds.add(atm.AccountId__c);
                }
            }
            system.debug('^AccountIds: '+AccountIds);
            if(!AccountIds.isEmpty()){
                Map<Id,List<Account_Team_Member__c>> ATMMap = new Map<Id,List<Account_Team_Member__c>>();
                for(Id ids: AccountIds){
                    ATMMap.put(ids, new List<Account_Team_Member__c>());
                }
                for(Account_Team_Member__c atm : [SELECT Id, AccountId__c, TeamMemberRole__c FROM Account_Team_Member__c WHERE AccountId__c IN: AccountIds AND TeamMemberRole__c = 'Sales Rep'] ){
                    if(ATMMap.containsKey(atm.AccountId__c)){
                        ATMMap.get(atm.AccountId__c).add(atm);
                    }
                }
                List<Account> AccountToBeUpdated = new List<Account>();
                for(Account acc : [SELECT Id, DateLastUnTeamed__c FROM Account WHERE Id =: AccountIds]){
                    if(ATMMap.containsKey(acc.Id)){
                        if(ATMMap.get(acc.Id).isEmpty()){
                            acc.DateLastUnTeamed__c = System.now();
                            AccountToBeUpdated.add(acc);
                        }
                    }
                }
                if(!AccountToBeUpdated.isEmpty()){
                    update AccountToBeUpdated;
                }
                system.debug('^AccountToBeUpdated: '+AccountToBeUpdated);
            }
        }catch(Exception ex){
            throw BaseApplicationException.NewException(METHODNAME, 'Failed to update the account. Please see system logs for errors.');
        }
    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 03/13/2014
** @description : ...
** @paramaters : none
** @returns : nothing
*/
    public void CreateAccountTeamMembers(list<Account_Team_Member__c> pAccountTeamMemberList){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','CreateAccountTeamMembers');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        list<AccountTeamMember> accountTeamMemberToInsertList = new list<AccountTeamMember>();
        map<Id,Account_Team_Member__c> userIdToCustomAccountTeamMemberMap = new map<Id,Account_Team_Member__c>();

        for(Account_Team_Member__c atmc : pAccountTeamMemberList){
            if(atmc.TeamMemberRole__c != 'Primary Sales Rep' && atmc.TeamMemberRole__c != 'Primary Service Rep'){
                AccountTeamMember newAccountTeamMember = new AccountTeamMember();
                newAccountTeamMember.AccountId = atmc.AccountId__c;
                newAccountTeamMember.UserId = atmc.UserId__c;
                newAccountTeamMember.TeamMemberRole = atmc.TeamMemberRole__c;

                accountTeamMemberToInsertList.add(newAccountTeamMember);

                userIdToCustomAccountTeamMemberMap.put(atmc.UserId__c, atmc);
            }
        }

        try{
            if(!accountTeamMemberToInsertList.isEmpty()){
                CreateNewAccountShare(CreateNewAccountTeamMember(accountTeamMemberToInsertList, userIdToCustomAccountTeamMemberMap));
            }
        }catch(Exception ex){
            throw BaseApplicationException.NewException(METHODNAME, ex.getMessage());
        }
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 03/13/2014
** @description : ...
** @paramaters : none
** @returns : nothing
*/
    public void UpdateAccountTeamMembers(list<Account_Team_Member__c> pAccountTeamMemberList){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','UpdateAccountTeamMembers');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        set<Id> accountIdSet = new set<Id>();
        for(Account_Team_Member__c atmc : pAccountTeamMemberList){
            accountIdSet.add(atmc.AccountId__c);
        }

        list<AccountTeamMember> accountTeamMemberList = [SELECT Id, AccountAccessLevel, AccountId, UserId, TeamMemberRole FROM AccountTeamMember WHERE AccountId IN : accountIdSet];
        map<Id,map<Id,AccountTeamMember>> accountIdToMapOfUserIdToAccountTeamMemberMap = new map<Id,map<Id,AccountTeamMember>>();

        for(AccountTeamMember atm : accountTeamMemberList){
            if(accountIdToMapOfUserIdToAccountTeamMemberMap.ContainsKey(atm.AccountId)){
                accountIdToMapOfUserIdToAccountTeamMemberMap.get(atm.AccountId).put(atm.UserId, atm);
            }else{
                accountIdToMapOfUserIdToAccountTeamMemberMap.put(atm.AccountId, new map<Id,AccountTeamMember>());
                accountIdToMapOfUserIdToAccountTeamMemberMap.get(atm.AccountId).put(atm.UserId, atm);
            }
        }
        list<AccountShare> accountShareList = [SELECT Id, UserOrGroupId, AccountId, AccountAccessLevel, CaseAccessLevel, OpportunityAccessLevel  FROM AccountShare WHERE AccountId = :accountIdSet];
        map<Id,map<Id, AccountShare>> accountIdToMapOfUserIdToAccountShareMap =  new map<Id,map<Id, AccountShare>>();

        for(AccountShare oAccountShare : accountShareList){
            if(accountIdToMapOfUserIdToAccountShareMap.ContainsKey(oAccountShare.AccountId)){
                accountIdToMapOfUserIdToAccountShareMap.get(oAccountShare.AccountId).put(oAccountShare.UserOrGroupId, oAccountShare);
            }else{
                accountIdToMapOfUserIdToAccountShareMap.put(oAccountShare.AccountId, new map<Id,AccountShare>());
                accountIdToMapOfUserIdToAccountShareMap.get(oAccountShare.AccountId).put(oAccountShare.UserOrGroupId, oAccountShare);
            }
        }

        list<AccountTeamMember> accountTeamMemberToBeUpdateList = new list<AccountTeamMember>();
        list<AccountShare> accountShareToBeUpdateList = new list<AccountShare>();

        for(Account_Team_Member__c atmc : pAccountTeamMemberList){

            if(accountIdToMapOfUserIdToAccountTeamMemberMap.containsKey(atmc.AccountId__c)){
                if(accountIdToMapOfUserIdToAccountTeamMemberMap.get(atmc.AccountId__c).containsKey(atmc.UserId__c)){
                    if(accountIdToMapOfUserIdToAccountTeamMemberMap.get(atmc.AccountId__c).get(atmc.UserId__c).TeamMemberRole != atmc.TeamMemberRole__c){
                        accountIdToMapOfUserIdToAccountTeamMemberMap.get(atmc.AccountId__c).get(atmc.UserId__c).TeamMemberRole = atmc.TeamMemberRole__c;
                        accountTeamMemberToBeUpdateList.add(accountIdToMapOfUserIdToAccountTeamMemberMap.get(atmc.AccountId__c).get(atmc.UserId__c));
                    }
                }
            }

            if(accountIdToMapOfUserIdToAccountShareMap.containsKey(atmc.AccountId__c)){
                if(accountIdToMapOfUserIdToAccountShareMap.get(atmc.AccountId__c).containsKey(atmc.UserId__c)){
                    if(accountIdToMapOfUserIdToAccountShareMap.get(atmc.AccountId__c).get(atmc.UserId__c).AccountAccessLevel != atmc.AccountAccessLevel__c){
                        accountIdToMapOfUserIdToAccountShareMap.get(atmc.AccountId__c).get(atmc.UserId__c).AccountAccessLevel = atmc.AccountAccessLevel__c;
                    }

                    if(accountIdToMapOfUserIdToAccountShareMap.get(atmc.AccountId__c).get(atmc.UserId__c).OpportunityAccessLevel != atmc.OpportunityAccessLevel__c){
                        accountIdToMapOfUserIdToAccountShareMap.get(atmc.AccountId__c).get(atmc.UserId__c).OpportunityAccessLevel = atmc.OpportunityAccessLevel__c;
                    }

                    if(accountIdToMapOfUserIdToAccountShareMap.get(atmc.AccountId__c).get(atmc.UserId__c).CaseAccessLevel != atmc.CaseAccessLevel__c){
                        accountIdToMapOfUserIdToAccountShareMap.get(atmc.AccountId__c).get(atmc.UserId__c).CaseAccessLevel = atmc.CaseAccessLevel__c;
                    }

                    accountShareToBeUpdateList.add(accountIdToMapOfUserIdToAccountShareMap.get(atmc.AccountId__c).get(atmc.UserId__c));
                }
            }
        }

        if(!accountTeamMemberToBeUpdateList.isEmpty()){
            update accountTeamMemberToBeUpdateList;
        }

        if(!accountShareToBeUpdateList.isEmpty()){
            try{
                update accountShareToBeUpdateList;
            }catch(Exception e){
                System.debug('Exception is **'+e);
            }
        }
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 03/19/2014
** @description : ...
** @paramaters : Array of Custom Account Team Members
** @returns : nothing
*/
    public void UpdatePrimaryServiceRepOnAccount(Account_Team_Member__c[] pCustomAccountTeamMemberList, map<ID, Account_Team_Member__c> pAccountIdToOldAccountMap, map<ID, Account_Team_Member__c> pAccountIdToUpdatedAccountMap){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','UpdatePrimaryServiceRepOnAccount');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        set<Id> accountIdSet = new set<Id>();
        for(Account_Team_Member__c atm : pCustomAccountTeamMemberList){
            accountIdSet.add(atm.AccountId__c);
        }

        map<Id,Account> accountIdToAccountMap = new map<Id,Account>([SELECT Id, PrimaryServiceRep__c FROM Account WHERE Id IN : accountIdSet]);
        list<Account> accountsToUpdateList = new list<Account>();

        for(Account_Team_Member__c oAccountTeamMembers : pCustomAccountTeamMemberList){

            if(pAccountIdToOldAccountMap.get(oAccountTeamMembers.Id).TeamMemberRole__c == 'Primary Service Rep' && pAccountIdToUpdatedAccountMap.get(oAccountTeamMembers.Id).TeamMemberRole__c != 'Primary Service Rep'){

                if(accountIdToAccountMap.containskey(oAccountTeamMembers.AccountId__c)){
                    //accountIdToAccountMap.get(oAccountTeamMembers.AccountId__c).PrimaryServiceRep__c = null;
                    accountsToUpdateList.add(accountIdToAccountMap.get(oAccountTeamMembers.AccountId__c));
                }
            }
        }

        UpdateAccountList(accountsToUpdateList);
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 03/19/2014
** @description : ...
** @paramaters : List of Accounts
** @returns : nothing
*/
    private void UpdateAccountList(list<Account> pAccountsToUpdateList){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','UpdateAccountList');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        try{
            update pAccountsToUpdateList;
        }catch(DMLException dmlex){
            throw BaseApplicationException.NewException(METHODNAME, dmlex.getMessage(), 'Unable to update Account to remove the Primary Service Rep');
        }
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 03/26/2014
** @description : Update the Primary Service Rep.
** @paramaters : none
** @returns : nothing
*/
    public void UpdatePrimaryServiceRep(list<Account_Team_Member__c> oldCustomATM){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','UpdatePrimaryServiceRep');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        try{
            if(!oldCustomATM.isEmpty() && oldCustomATM!=null ){

                set<id> AccountIDS = new set<Id>();
                list<Account> UpdatePrimaryServiceOnAccount = new list<Account>();
                map<id,id> accountIdMapWithOldestAccountTeamMember = new map<id,id>();
                Integer NumOfPriRep = 0;
                Integer NumOfServiceRep = 0;
                list<Account> UpdatePrimaryServiceToBlankonAccount = new list<Account>();

                //get Account IDs
                for(Account_Team_Member__c oAcctTeamMem : oldCustomATM){
                    if(oAcctTeamMem.AccountId__c != null){
                        AccountIDS.add(oAcctTeamMem.AccountId__c);
                    }
                }
                for(Account oAccount : [SELECT Id, PrimaryServiceRep__c, (SELECT Id, AccountId__c, UserId__c, TeamMemberRole__c FROM Account_Team_Members__r order by CreatedDate asc) FROM Account WHERE Id IN : AccountIDS]){
                    if(oAccount.Account_Team_Members__r != null && !oAccount.Account_Team_Members__r.isEmpty()){
                       for(Account_Team_Member__c oAccountTeamMember : oAccount.Account_Team_Members__r ){
                           if(oAccountTeamMember.TeamMemberRole__c == 'Primary Service Rep'){
                               NumOfPriRep++;
                           }else if(oAccountTeamMember.TeamMemberRole__c == 'Service Rep'){
                               accountIdMapWithOldestAccountTeamMember.put(oAccount.id,oAccountTeamMember.UserId__c);
                               NumOfServiceRep++;
                               break;
                           }
                        }
                    }
                }

                if(NumOfPriRep == 0 && NumOfServiceRep > 0){
                    for(id oAccountId : accountIdMapWithOldestAccountTeamMember.keyset()){
                         if(!accountIdMapWithOldestAccountTeamMember.isEmpty()){
                             if(accountIdMapWithOldestAccountTeamMember.containskey(oAccountId)){
                                 Account act = new Account();
                                 act.id = oAccountId;
                                 act.PrimaryServiceRep__c = accountIdMapWithOldestAccountTeamMember.get(oAccountId);
                                 UpdatePrimaryServiceOnAccount.add(act);
                             }
                         }
                    }
                }else if(NumOfPriRep == 0 && NumOfServiceRep == 0){
                    for(id oAccountId : AccountIDS){
                         Account act = new Account();
                         act.id = oAccountId;
                         act.PrimaryServiceRep__c = null;
                         UpdatePrimaryServiceOnAccount.add(act);
                    }

                }

                if(!UpdatePrimaryServiceOnAccount.isEmpty()){
                    update UpdatePrimaryServiceOnAccount;
                }


            }


        }catch(DMLException dmlex){
            throw BaseApplicationException.NewException(METHODNAME, dmlex.getMessage(), 'Unable to Set Primary Service Rep');
        }
    }


/****************************** CONTACT METHODS *******************************/

/*
** @author : Cloud Sherpas, Inc.
** @date : 03/19/2014
** @description : Manage Primary Sales Contact and Primary Service Contact
** @paramaters : Contact Array
** @returns : nothing
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
        system.debug(contactIdSet+'!!!'+accountIdSet);
        list<Account> accountList = [Select Id,(Select Id,PrimarySalesContact__c,PrimaryServiceContact__c,AccountId  FROM Contacts) FROM Account WHERE Id IN : accountIdSet];
        map<id,integer> accountIdPrimarySalesContactCount = new map<id,Integer>();
        map<id,integer> accountIdPrimaryServiceContactCount = new map<id,Integer>();


        //Count Number of Primary Sales and Primary Service Contact existing for a Account.
        for(Account oAccount : accountList){
            system.debug(oAccount.contacts+'!!!!'+accountList);
           for(Contact oContact : oAccount.Contacts){
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

                       if(oContact.PrimaryServiceContact__c == true){
                           if(accountIdPrimaryServiceContactCount.containsKey(oContact.AccountId)){
                                accountIdPrimaryServiceContactCount.put(oContact.AccountId, accountIdPrimaryServiceContactCount.get(oContact.AccountId) + 1);
                           }else{
                                accountIdPrimaryServiceContactCount.put(oContact.AccountId, 1);
                           }
                       }
                    }
                }else{
                    system.debug('insert enetered'+ oContact.PrimarySalesContact__c + oContact.PrimaryServiceContact__c);
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
                   }
                }
            }
        }

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
                        con.addError('Primary Service Contact has already been set for an Account');
                    }
                }
            }
        }
    }
}