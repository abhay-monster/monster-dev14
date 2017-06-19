public without sharing class TABatchAcctTeamMemberQueueable extends TABatchVirtualQueueable {
//JFreese Appirio 4/12/17 S-475545 Comment out this class as it is not in current use (but may be in future)
//    final String CLASSNAME = '\n\n**** TABatchAcctTeamMemberQueueable.METHODNAME()';
//
//    private List<Account> accountsToUpdate;
//    private Set<Id> assignedTerritoryIds;
//    private List<TerritoryAssignmentTeamMember__c> queryTATMList;
//
//
//    /* @Name: executeBeforeLogic
//    *  @Author: JHF (Appirio)
//    *  @Params: nothing
//    *  @Returns: void
//    *  @Description: overridden before logic, this just gathers up the Opportunities and
//                    builds the opp to account map, and opportunity team member map needed
//                    for the main logic
//    */
//    override protected void executeBeforeLogic(){
//        final string METHODNAME = CLASSNAME.replace('METHODNAME','executeBeforeLogic');
//        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
//
//        assignedTerritoryIds = new Set<Id>();
//        accountsToUpdate = [SELECT Id, TerritoryCode__c
//                            FROM Account WHERE Id IN :accountWrapperMap.keySet()];
//        for(Account acct : accountsToUpdate){
//            assignedTerritoryIds.add(acct.TerritoryCode__c);
//        }
//    }
//
//    /* @Name: executeMainLogic
//    *  @Author: JHF (Appirio)
//    *  @Params: nothing
//    *  @Returns: void
//    *  @Description: override Main Logic, this calls private methods to upsert Account Team Members
//                     from the TA Team Member related list, and update Account shares
//    */
//    override protected void executeMainLogic(){
//        final string METHODNAME = CLASSNAME.replace('METHODNAME','executeMainLogic');
//        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
//        //TODO move this into the queueable itself ;
//
//        if(accountsToUpdate.size() > 0){
//            /*JHF Appirio 6/29/16 I-202496 Update Account Team Members
//              using code copied from TerritoryAssignmentForBatch.cls.*/
//            List<Account_Team_Member__c> listATMToUpsert = new List<Account_Team_Member__c>();
//            listATMToUpsert = evaluateAccountTeamMembers('upsert',accountsToUpdate, assignedTerritoryIds);
//            system.debug('listATMToUpsert.size()=' + listATMToUpsert.size());
//            if(listATMToUpsert.size() > 0){
//                try {
//                    upsert listATMToUpsert;
//                }catch(DMLException e){
//                    ExceptionLog.add('DMLException', 'TABatchAcctTeamMemberQueueable', 'executeMainLogic', e.getMessage());
//                    throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to update Account team member.' ,e);
//                }
//
///*                List<AccountShare> listAcctShareToUpdate = new List<AccountShare>();
//                //listAcctShareToUpdate = updateAccountShares(listATMToUpsert, assignedTerritoryIds);
//                if(listAcctShareToUpdate.size() > 0){
//                    system.debug('listAcctShareToUpdate.size()=' + listAcctShareToUpdate.size());
//                    try {
//                        update listAcctShareToUpdate;
//                }catch(DMLException e){
//                        ExceptionLog.add('DMLException', 'TABatchOppTeamMemberQueueable', 'executeMainLogic', e.getMessage());
//                        throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to update Account Shares.' ,e);
//                    }
//                }*/
//            }
//
//            //Now delete Account Team Members flagged with TA_Team_Member__c if they are no longer TA Team Members
//            List<Account_Team_Member__c> listATMToDelete = new List<Account_Team_Member__c>();
//            listATMToDelete = evaluateAccountTeamMembers('delete',accountsToUpdate, assignedTerritoryIds);
//            system.debug('listATMToDelete.size()=' + listATMToDelete.size());
//            if(listATMToDelete.size() > 0){
//                try {
//                    delete listATMToDelete;
//                }catch(DMLException e){
//                    ExceptionLog.add('DMLException', 'TABatchOppTeamMemberQueueable', 'executeMainLogic', e.getMessage());
//                    throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to delete Account team member.' ,e);
//                }
//            }
//
//        }
//    }
//
//    /* @Name: executeNextQueueable
//    *  @Author: JHF (Appirio)
//    *  @Params: nothing
//    *  @Returns: void
//    *  @Description: overridden next method, calling this method means we have more
//                    accounts to process, it gets the next queueable up and enqueued
//    */
//    override protected void executeNextQueueable(){
//        final string METHODNAME = CLASSNAME.replace('METHODNAME','executeNextQueueable');
//        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
//
//        configObject.offset = offSet + subObjectIdList.size();
//        TABatchAcctTeamMemberQueueable nextQueueable = new TABatchAcctTeamMemberQueueable(configObject);
//        Id jobId = System.enqueueJob(nextQueueable);
//        insertNewQueueableLog(jobId);
//    }
//
//    /* @Name: executeLastLogic
//    *  @Author: JHF (Appirio)
//    *  @Params: nothing
//    *  @Returns: void
//    *  @Description: overridden Last logic, if we are hitting this method it means we
//                    in the last queueable for the Account Team Members, so we need to start the
//                    next queueable (Contacts)
//    */
//    override protected void executeLastLogic(){
//        final string METHODNAME = CLASSNAME.replace('METHODNAME','executeLastLogic');
//        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
//
//        TABatchVirtualQueueable.TABatchConfiguration newConfig = configObject.cloneForNextBatch();
//        newConfig.objectIdList = queryContactList();
//        newConfig.customMetadataString = 'Contact__c';
//        newConfig.objectName = 'Contact';
//
//        TABatchContactQueueable newContactQueueable = new TABatchContactQueueable(newConfig);
//        if(Test.isRunningTest() == false){
//            //Can't chain in a test class
//            //"You can’t chain queueable jobs in an Apex test. Doing so results in an error.
//            //To avoid getting an error, you can check if Apex is running in test context by calling Test.isRunningTest() before chaining jobs."
//            //found here https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_queueing_jobs.htm
//            newContactQueueable.enqueueTA();
//        }
//    }
//
//
//    //Constructors
//    public TABatchAcctTeamMemberQueueable(List<Account> pAccountList, Map<Id,Id> pOldAccountMap, List<Id> pObjectIdList, Integer pOffSet, String pCustomMetadataString){
//        super(pAccountList, pOldAccountMap, pObjectIdList, pOffSet, pcustomMetadataString, 'Account_Team_Member__c');
//    }
//
//    public TABatchAcctTeamMemberQueueable(TABatchVirtualQueueable.TABatchConfiguration pConfigObject){
//        super(pConfigObject);
//    }
//
//
//    /* @Name: queryContactList
//    *  @Author: JHF (Appirio)
//    *  @Params: nothing
//    *  @Returns: List<Id>
//    *  @Description: helper method for querying the contacts needed for the next queueuable
//    */
//    private List<Id> queryContactList(){
//        List<Id> returnList = new List<Id>();
//        Id personAccountRecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Account', 'Person Account');
//        system.debug('personAccountRecordTypeId=' + personAccountRecordTypeId + ', accountWrapperMap.keySet()=' + accountWrapperMap.keySet());
//
//        For(Contact cntct : [Select Id from Contact
//                    where Account.RecordTypeID != : personAccountRecordTypeId
//                    and AccountID in :accountWrapperMap.keySet()]){
//            returnList.add(cntct.Id);
//        }
//
//        return returnList;
//    }
//
//
///*JHF Appirio I-202496 7/1/16 Bulk TA - Secondary rep not getting dropped from opportunity
//  This issue is around Opportunity Team Members (OTM) which need to be added/dropped as
//  a result of Territory Assignment (TA) processing.
//
//  The TA has a related list of TA Team Members, and under I-202496 on 3/17-18/16,
//  the TerritoryAssignmentForBatch.cls was modified to mimic the code for
//  Account Team Members and apply it to Opportunity Team Members.
//
//  That worked as long as the old TA Batch process was in use, but when it was
//  deployed to prod we hit limit exceptions and ended up replacing the whole process
//  with a Dataloader update of Account owners, which then processes the child objects
//  in a thread of queueables.
//
//  The following is a copy of the relevant OTM code from TerritoryAssignmentForBatch.cls*/
//
///*
//** @author : JHF (Appirio)
//** @date : 06/29/16
//** @description : Query for the list of Territory Assignment (TA) Team Members
//** @paramaters : Set of TA IDs
//** @returns : List of TA Team Members
//*/
//    private List<TerritoryAssignmentTeamMember__c> queryTATMList(Set<Id> assignedTerritoryIds){
//        if(queryTATMList == null){
//            queryTATMList = [Select id, TeamMember__c, TeamMemberRole__c, TerritoryAssignment__c,
//                             AccountAccessLevel__c, CaseAccessLevel__c, OpportunityAccessLevel__c
//                             from TerritoryAssignmentTeamMember__c
//                             where TerritoryAssignment__c in : assignedTerritoryIds];
//        }
//        return queryTATMList;
//    }
//
//
///*
//** @author : JHF (Appirio)
//** @date : 06/29/16
//** @description : Gather list of Account Team Members to upsert for updated accounts
//** @paramaters : List of updated accounts, Set of TA IDs
//** @returns : List of Account Team Members to Upsert
//*/
//    private List<Account_Team_Member__c> evaluateAccountTeamMembers(String action, List<Account> updatedAccounts, Set<Id> assignedTerritoryIds){
//        final string METHODNAME = CLASSNAME.replace('METHODNAME','evaluateAccountTeamMembers');
//        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '****  Inside '));
//        system.debug('===assignedTerritoryIds======> '+assignedTerritoryIds);
//
//        List<Account_Team_Member__c> retList = new List<Account_Team_Member__c>();
//        Map<Id, List<TerritoryAssignmentTeamMember__c>> territoryIdToMembersMap = new Map<Id, List<TerritoryAssignmentTeamMember__c>>();
//        Map<Id, List<Account_Team_Member__c>> accountIdToMembersMap = new Map<Id, List<Account_Team_Member__c>>();
//        System.debug('queryTATMList(assignedTerritoryIds)======'+queryTATMList(assignedTerritoryIds) + 'assignedTerritoryIds==='+assignedTerritoryIds);
//
//        for(TerritoryAssignmentTeamMember__c teamMember : queryTATMList(assignedTerritoryIds)){
//            if(!territoryIdToMembersMap.containsKey(teamMember.TerritoryAssignment__c)){
//                    territoryIdToMembersMap.put(teamMember.TerritoryAssignment__c, new List<TerritoryAssignmentTeamMember__c>());
//            }
//            territoryIdToMembersMap.get(teamMember.TerritoryAssignment__c).add(teamMember);
//        }
//
//        system.debug('===territoryIdToMembersMap======> '+territoryIdToMembersMap);
//
//        for(Account_Team_Member__c teamMember : [SELECT Id, UserId__c, TeamMemberRole__c, AccountId__c,
//                                                 AccountAccessLevel__c, CaseAccessLevel__c, OpportunityAccessLevel__c,
//                                                 TA_Team_Member__c
//                                                 FROM Account_Team_Member__c
//                                                 where AccountId__c IN : updatedAccounts]){
//
//        if(!accountIdToMembersMap.containsKey(teamMember.AccountId__c)){
//                accountIdToMembersMap.put(teamMember.AccountId__c, new List<Account_Team_Member__c> ());
//             }
//             accountIdToMembersMap.get(teamMember.AccountId__c).add(teamMember);
//        }
//
//        system.debug('====accountIdToMembersMap======> '+ accountIdToMembersMap);
//
//        for(Account acc : updatedAccounts){
//            if(territoryIdToMembersMap.get(acc.TerritoryCode__c) != null){
//                retList.addAll(getAccountTeamMembers(action, acc.id, accountIdToMembersMap.get(acc.id), territoryIdToMembersMap.get(acc.TerritoryCode__c)));
//            }
//        }
//
//        system.debug('====retList======> '+ retList);
//        return retList;
//    }
//
//
///*
//** @author : JHF (Appirio)
//** @date : 06/29/16
//** @description : Get Account Team Members (ATMs) which need to be updated or deleted based on Territory Assignment Team Members (TATMs)
//** @paramaters : Action, Account ID, List of existing Account Team Members, List of TA Team Members
//** @returns : List of Account Team Members to update or delete, per Action
//*/
//    private List<Account_Team_Member__c> getAccountTeamMembers(String action, Id accountId, List<Account_Team_Member__c> accountTeamMembers,List<TerritoryAssignmentTeamMember__c> territoryTeamMembers){
//
//        Boolean no_TA_Team_Member_Found;
//        Boolean MadeNewTM = false;
//        List<Account_Team_Member__c> AccTeamMembers = new List<Account_Team_Member__c>();
//
//        if (action == 'upsert'){
//            for(TerritoryAssignmentTeamMember__c territoryTM : territoryTeamMembers){
//                Account_Team_Member__c accTM = alreadyExists(territoryTM.TeamMember__c, accountTeamMembers);
//                if(accTM == null){
//                    accTM = new Account_Team_Member__c();
//                    accTM.AccountId__c = accountId;
//                    MadeNewTM = true;
//                    system.debug('Create New Account Team Member record for ' + territoryTM.TeamMember__c);
//                }
//
//                if (MadeNewTM ||                                //There was no ATM matching the TATM, made a new ATM
//                    Set_TA_Team_Member_flag_on_Existing_ATM ||  //TA_Records_per_Queueable__mdt.Set_TA_Team_Member_flag_on_Existing_ATM__c
//                                                                //is true, so set the flag even if the ATM was originally entered manually
//                    accTM.TA_Team_Member__c == true             //Update existing ATM derived from TATM
//                    ){
//                    accTM.TA_Team_Member__c = true;
//                    accTM.UserId__c = territoryTM.TeamMember__c;
//                    accTM.TeamMemberRole__c = territoryTM.TeamMemberRole__c;
//                    accTM.AccountAccessLevel__c = territoryTM.AccountAccessLevel__c;
//                    accTM.CaseAccessLevel__c = territoryTM.CaseAccessLevel__c;
//                    accTM.OpportunityAccessLevel__c = territoryTM.OpportunityAccessLevel__c;
//                    AccTeamMembers.add(accTM);
//                }
//            }
//        }
//        else if (action == 'delete'){
//            for(Account_Team_Member__c accTM : accountTeamMembers){
//                no_TA_Team_Member_Found = true;
//                for(TerritoryAssignmentTeamMember__c territoryTM : territoryTeamMembers){
//                    if (accTM.UserId__c == territoryTM.TeamMember__c){
//                        no_TA_Team_Member_Found = false;
//                    }
//                }
//                if (no_TA_Team_Member_Found && accTM.TA_Team_Member__c == true){
//                    AccTeamMembers.add(accTM);
//                }
//            }
//        }
//        return AccTeamMembers;
//    }
//
//
///*
//** @author : JHF (Appirio)
//** @date : 06/29/16
//** @description : Check whether an Account Team Member exists
//** @paramaters : User ID, List of Account Team Members
//** @returns : Account Team Member
//*/
//    private Account_Team_Member__c alreadyExists(Id userId, List<Account_Team_Member__c> accountTeamMembers){
//        //system.debug('ID Check: ' + userId);
//        if(accountTeamMembers != null) {
//            for(Account_Team_Member__c accTM : accountTeamMembers){
//                system.debug('Existing Account Team Member ' + accTM);
//                if(userId == accTM.UserId__c){
//                    return accTM;
//                }
//            }
//        }
//        return null;
//    }
//
}