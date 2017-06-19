public without sharing class TriggerHelperWithoutSharing {
    private static TriggerHelperWithoutSharing instance;
    final String CLASSNAME = '\n\n**** TriggerHelperWithoutSharing.METHODNAME()';
    public Org_Settings__c orgSettings = Org_Settings__c.getInstance();
    public Integer cutoff = Integer.valueOf(orgSettings.Debug_Log_Record_Count_Cutoff__c); //JFreese Appirio S-435483 4/11/17
    public Id debugId = orgSettings.Debug_Log_Record_ID__c; //JFreese Appirio S-435483 4/11/17

    public static TriggerHelperWithoutSharing getInstance(){
        return instance == null ? new TriggerHelperWithoutSharing() : instance;
    }

    public TriggerHelperWithoutSharing(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','TriggerHelperWithoutSharing');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 07/29/2014
** @Story : 0948
** @Element : E1852
** @description :
**              1.) Max Activity Date field should be updated with the created date of the last created activity/task related to the account.
**              2.) Max Activity Date Owner lookup should be populated with the latest activity/task created.
** @param : list of Task/Activity
** @returns : nothing
*/
    public void updateMaxActivityDateAndOwnerOfAccount(list<SObject> pTaskList){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateMaxActivityDateAndOwnerOfAccount');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            Map<Id, SObject> TaskAccountMap = new Map<Id, SObject>();
            for(SObject t : pTaskList){
                TaskAccountMap.put((Id)t.get('AccountId'), t);
            }
            List<Account> AccountToBeUpdated = new List<Account>();
            if(!TaskAccountMap.isEmpty()){
                for(Account acc: [SELECT Id, MaxActivityDate__c, MaxActivityDateOwner__c FROM Account WHERE Id IN: TaskAccountMap.keySet()] ){
                    if(TaskAccountMap.get(acc.Id).get('CreatedDate') != null ){
                        acc.MaxActivityDate__c = (Datetime)TaskAccountMap.get(acc.Id).get('CreatedDate');
                    }
                    if(TaskAccountMap.get(acc.Id).get('ownerId') != null ){
                        acc.MaxActivityDateOwner__c = (Id)TaskAccountMap.get(acc.Id).get('ownerId');
                    }
                    AccountToBeUpdated.add(acc);
                }
            }

            if(!AccountToBeUpdated.isEmpty()){
                update AccountToBeUpdated;
            }
        }catch(Exception ex){
            ExceptionLog.add(ex.getTypeName(), 'TaskTriggerHelper', 'updateMaxActivityDateAndOwnerOfAccount', ex.getMessage());
            throw BaseApplicationException.NewException('TriggerHelperWithoutSharing.updateMaxActivityDateAndOwnerOfAccount()', 'Failed to update the related Account. Please see system logs for details. \nError: '+ex.getMessage() );
        }
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 03/11/2014
** @description : ...q
** @paramaters : Account Id Set, Primary Team Member Type to List of Accounts Map
** @returns : nothing
Update to address Issue I-167747
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
            List<Account_Team_Member__c> customTeamMembersToUpdate = new List<Account_Team_Member__c>();
            List<AccountTeamMember> standardTeamMembersToInsert = new List<AccountTeamMember>();
            List<AccountTeamMember> standardTeamMembersToDelete = new List<AccountTeamMember>();
            Boolean hasPrimarySalesRep = false;
            Boolean hasPrimarySalesRepAlreadyInTeam = false;
            Account_Team_Member__c cteamMember;
            if (pPrimaryTeamMemberTypeToListOfAccountsMap.containsKey('PrimarySalesRep')) {
                for (Account act : pPrimaryTeamMemberTypeToListOfAccountsMap.get('PrimarySalesRep')) {
                    hasPrimarySalesRep = false;
                    // custom account team member
                    if (customTeamMembers.containsKey(act.Id)) {
                        for (Account_Team_Member__c teamMember : customTeamMembers.get(act.Id)) {

                            if(teamMember.UserId__c == act.OwnerId){
                                customTeamMembersToDelete.add(teamMember);

                            }else if (teamMember.TeamMemberRole__c == 'Primary Sales Rep') {
                                if (!hasPrimarySalesRep) {
                                    if (teamMember.UserId__c != act.OwnerId) {
                                        // to delete I-179994
                                        customTeamMembersToDelete.add(teamMember);
                                        //teamMember.TeamMemberRole__c  = 'Sales Rep' ;
                                        //customTeamMembersToUpdate.add(teamMember);
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
                            if(teamMember.UserId == act.OwnerId){
                                standardTeamMembersToDelete.add(teamMember);
                            }else if (teamMember.TeamMemberRole == 'Primary Sales Rep') {
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
            if(customTeamMembersToUpdate.size()>0)
                update customTeamMembersToUpdate;
            // delete
            if(customTeamMembersToDelete.size() > 0){
                For(Account_Team_Member__c atmd : customTeamMembersToDelete){
                    if (pAccountIdSet.size() <= cutoff || atmd.AccountId__c == debugId){ //JFreese Appirio S-435483 4/11/17
                        system.debug('^^^ customTeamMemberToDelete: ' + atmd);
                    }
                }
                AccountTeamMemberTriggerHandler.CanThrowError = false;
                Database.DeleteResult[] srListDeleteCustom = Database.delete(customTeamMembersToDelete, false);
            }

            if(standardTeamMembersToDelete.size() > 0){
                For(AccountTeamMember atmd : standardTeamMembersToDelete){
                    if (pAccountIdSet.size() <= cutoff || atmd.AccountId == debugId){ //JFreese Appirio S-435483 4/11/17
                        system.debug('^^^ standardTeamMemberToDelete: ' + atmd);
                    }
                }
            Database.DeleteResult[] srListDeleteStandard = Database.delete(standardTeamMembersToDelete, false);
            }

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
                    For(Account_Team_Member__c vcat : validatedCustomAccountTeamMemberToInsertList){
                        if (pAccountIdSet.size() <= cutoff || vcat.AccountId__c == debugId){ //JFreese Appirio S-435483 4/11/17
                            system.debug('^^^ validatedCustomAccountTeamMemberToInsert: ' + vcat);
                        }
                    }
                    InsertCustomAccountTeamMembers(validatedCustomAccountTeamMemberToInsertList);
                }
            }
            if(!standardTeamMembersToInsert.Isempty()){
                Set<id> setUserIds = new Set<id>();
                For(AccountTeamMember act : standardTeamMembersToInsert){
                    setUserIds .add(act.UserId);
                }

                Map <id , user > mapUser = new Map<id,User>([select isActive from User Where ID IN:setUserIds ]);

                List<AccountTeamMember> standardTeamMembersToInsertForActiveUsers = new List<AccountTeamMember>();
                For(AccountTeamMember act : standardTeamMembersToInsert){
                    if(mapUser.get(act.UserId).isActive)
                       standardTeamMembersToInsertForActiveUsers.add(act);
                }
                if(!standardTeamMembersToInsertForActiveUsers.isempty()){
                    For(AccountTeamMember stm : standardTeamMembersToInsertForActiveUsers){
                        if (pAccountIdSet.size() <= cutoff || stm.AccountId == debugId){ //JFreese Appirio S-435483 4/11/17
                            system.debug('^^^ standardTeamMemberToInsertForActiveUser: ' + stm);
                        }
                    }
                    insert standardTeamMembersToInsertForActiveUsers;
                }
             }
            // create new Account Share for newly createded Account Team Members
            /*if (!standardTeamMembersToInsert.isEmpty()) {
                CreateNewAccountShare(CreateNewAccountTeamMember(standardTeamMembersToInsert, userIdToCustomAccountTeamMemberMap));
            }*/
        }
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
}