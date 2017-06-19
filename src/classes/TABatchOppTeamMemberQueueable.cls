public without sharing class TABatchOppTeamMemberQueueable extends TABatchVirtualQueueable {
//JFreese Appirio 4/12/17 S-475545 Comment out this class as it is not in current use (but may be in future)
//
//    final String CLASSNAME = '\n\n**** TABatchOppTeamMemberQueueable.METHODNAME()';
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
//        /*This ia a little non-intuitive, but will base the queueable batches on opportunity counts,
//          and preserve the original logic from TerritoryAssignmentForBatch.cls.
//
//          Get a list of accounts and their territory assignments for the current batch of opportunities.*/
//        Set<Id> accountIDsToUpdate = new Set<Id>();
//        accountsToUpdate = new List<Account>();
//        assignedTerritoryIds = new Set<Id>();
//
//        //system.debug('subObjectIdList=' + subObjectIdList);
//        for(Opportunity opp : [Select Id, AccountId, Account.TerritoryCode__c from Opportunity
//            where Id in :subObjectIdList and Account.TerritoryCode__c != null]){
//            accountIDsToUpdate.add(opp.AccountId);
//            assignedTerritoryIds.add(opp.Account.TerritoryCode__c);
//        }
//        //system.debug('accountIDsToUpdate=' + accountIDsToUpdate + ', assignedTerritoryIds=' + assignedTerritoryIds);
//        if(accountIDsToUpdate.size() > 0){
//            accountsToUpdate = [Select Id, TerritoryCode__c from Account where Id in :accountIDsToUpdate];
//        }
//    }
//
//    /* @Name: executeMainLogic
//    *  @Author: JHF (Appirio)
//    *  @Params: nothing
//    *  @Returns: void
//    *  @Description: override Main Logic, this calls private methods to upsert Opportunity Team Members
//                     from the TA Team Member related list, and update Opportunity shares
//    */
//    override protected void executeMainLogic(){
//        final string METHODNAME = CLASSNAME.replace('METHODNAME','executeMainLogic');
//        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
//        //TODO move this into the queueable itself ;
//
//        if(accountsToUpdate.size() > 0){
//            /*JHF Appirio 6/29/16 I-202496 Update Opportunity Team Members
//              using code copied from TerritoryAssignmentForBatch.cls.*/
//            List<OpportunityTeamMember> listOTMToUpsert = new List<OpportunityTeamMember>();
//            listOTMToUpsert = evaluateOpportunityTeamMembers('upsert',accountsToUpdate, assignedTerritoryIds);
//            system.debug('listOTMToUpsert.size()=' + listOTMToUpsert.size());
//            if(listOTMToUpsert.size() > 0){
//                try {
//                    upsert listOTMToUpsert;
//                }catch(DMLException e){
//                    ExceptionLog.add('DMLException', 'TABatchOppTeamMemberQueueable', 'executeMainLogic', e.getMessage());
//                    throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to update opportunity team member.' ,e);
//                }
//
//                List<OpportunityShare> listOppShareToUpdate = new List<OpportunityShare>();
//                listOppShareToUpdate = updateOpportunityShares(listOTMToUpsert, assignedTerritoryIds);
//                if(listOppShareToUpdate.size() > 0){
//                    system.debug('listOppShareToUpdate.size()=' + listOppShareToUpdate.size());
//                    try {
//                        update listOppShareToUpdate;
//                }catch(DMLException e){
//                        ExceptionLog.add('DMLException', 'TABatchOppTeamMemberQueueable', 'executeMainLogic', e.getMessage());
//                        throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to update Opportunity Shares.' ,e);
//                    }
//                }
//            }
//
//            //Now delete Opportunity Team Members flagged with TA_Team_Member__c if they are no longer TA Team Members
//            List<OpportunityTeamMember> listOTMToDelete = new List<OpportunityTeamMember>();
//            listOTMToDelete = evaluateOpportunityTeamMembers('delete',accountsToUpdate, assignedTerritoryIds);
//            system.debug('listOTMToDelete.size()=' + listOTMToDelete.size());
//            if(listOTMToDelete.size() > 0){
//                try {
//                    delete listOTMToDelete;
//                }catch(DMLException e){
//                    ExceptionLog.add('DMLException', 'TABatchOppTeamMemberQueueable', 'executeMainLogic', e.getMessage());
//                    throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to delete opportunity team member.' ,e);
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
//                    opportunities to process, it gets the next queueable up and enqueued
//    */
//    override protected void executeNextQueueable(){
//        final string METHODNAME = CLASSNAME.replace('METHODNAME','executeNextQueueable');
//        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
//
//        configObject.offset = offSet + subObjectIdList.size();
//        TABatchOppTeamMemberQueueable nextQueueable = new TABatchOppTeamMemberQueueable(configObject);
//        Id jobId = System.enqueueJob(nextQueueable);
//        insertNewQueueableLog(jobId);
//    }
//
//    /* @Name: executeLastLogic
//    *  @Author: JHF (Appirio)
//    *  @Params: nothing
//    *  @Returns: void
//    *  @Description: overridden Last logic, if we are hitting this method it means we
//                    in the last queueable for the Opportunities, so we need to start the
//                    next queueable (Proposals)
//    */
//    override protected void executeLastLogic(){
//        final string METHODNAME = CLASSNAME.replace('METHODNAME','executeLastLogic');
//        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
//
//        TABatchVirtualQueueable.TABatchConfiguration newConfig = configObject.cloneForNextBatch();
//        newConfig.objectIdList = queryProposalList();
//        newConfig.customMetadataString = 'Proposal__c';
//        newConfig.objectName = 'Apttus_Proposal__Proposal__c';
//
//        TABatchProposalQueueable newPropQueueable = new TABatchProposalQueueable(newConfig);
//        //if(Test.isRunningTest() == false){
//        newPropQueueable.enqueueTA();
//        //}
//    }
//
//
//    //Constructors
//    public TABatchOppTeamMemberQueueable(TABatchVirtualQueueable.TABatchConfiguration pConfigObject){
//        super(pConfigObject);
//    }
//
//
//    /* @Name: queryProposalList
//    *  @Author: JHF (Appirio)
//    *  @Params: nothing
//    *  @Returns: List<Id>
//    *  @Description: helper method for querying the proposals needed for the next
//                    queueuable
//    */
//    private List<Id> queryProposalList(){
//        List<Id> returnList = new List<Id>();
//        Set<String> proposalStatus = new Set<String>{'Inactive' , 'Expired' , 'Closed' };
//
//        For(Apttus_Proposal__Proposal__c prop : [Select Id from Apttus_Proposal__Proposal__c
//                    where QuoteStatus__c not in :proposalStatus
//                    and Apttus_Proposal__Account__c in :accountWrapperMap.keySet()]){
//            returnList.add(prop.Id);
//        }
//
//        return returnList;
//    }
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
//** @description : Gather list of Opportunity Team Members to upsert for updated accounts
//** @paramaters : List of updated accounts, Set of TA IDs
//** @returns : List of Opportunity Team Members to Upsert
//*/
//    private List<OpportunityTeamMember> evaluateOpportunityTeamMembers(String action, List<Account> updatedAccounts, Set<Id> assignedTerritoryIds){
//        final string METHODNAME = CLASSNAME.replace('METHODNAME','evaluateOpportunityTeamMembers');
//        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '****  Inside '));
//        system.debug('===assignedTerritoryIds======> '+assignedTerritoryIds);
//
//        List<OpportunityTeamMember> retList = new List<OpportunityTeamMember>();
//        Map<Id, List<TerritoryAssignmentTeamMember__c>> territoryIdToMembersMap = new Map<Id, List<TerritoryAssignmentTeamMember__c>>();
//        Map<Id, List<Id>> accountIdToOppIdMap = new Map<Id, List<Id>>();
//        List<Opportunity> updatedOpportunities = new List<Opportunity>();
//        Map<Id, List<OpportunityTeamMember>> opportunityIdToMembersMap = new Map<Id, List<OpportunityTeamMember>>();
//
//        for(TerritoryAssignmentTeamMember__c teamMember : queryTATMList(assignedTerritoryIds)){
//                if(!territoryIdToMembersMap.containsKey(teamMember.TerritoryAssignment__c)){
//                        territoryIdToMembersMap.put(teamMember.TerritoryAssignment__c, new List<TerritoryAssignmentTeamMember__c>());
//                }
//                territoryIdToMembersMap.get(teamMember.TerritoryAssignment__c).add(teamMember);
//        }
//
//        system.debug('===territoryIdToMembersMap======> '+territoryIdToMembersMap);
//
//        for(Opportunity opp : [SELECT Id, status__c, AccountId FROM Opportunity where AccountId IN : updatedAccounts AND
//                               isWon = false AND isClosed = false]){ //only open opportunities
//            if(!accountIdToOppIdMap.containsKey(opp.AccountId)){
//                accountIdToOppIdMap.put(opp.AccountId, new List<Id> ());
//            }
//            accountIdToOppIdMap.get(opp.AccountId).add(opp.Id);
//            updatedOpportunities.add(opp);
//        }
//        system.debug('====updatedOpportunities======> ' + updatedOpportunities);
//
//        if(updatedOpportunities.size() > 0){
//            for(OpportunityTeamMember teamMember : [SELECT Id, OpportunityId, UserId, TA_Team_Member__c
//                                                     FROM OpportunityTeamMember
//                                                     where OpportunityId IN : updatedOpportunities]){
//                if(!opportunityIdToMembersMap.containsKey(teamMember.OpportunityId)){
//                    opportunityIdToMembersMap.put(teamMember.OpportunityId, new List<OpportunityTeamMember> ());
//                }
//                opportunityIdToMembersMap.get(teamMember.OpportunityId).add(teamMember);
//            }
//        }
//
//        system.debug('====opportunityIdToMembersMap======> '+ opportunityIdToMembersMap);
//
//        for(Account acc : updatedAccounts){
//            if(territoryIdToMembersMap.get(acc.TerritoryCode__c) != null){
//                for(Id key : accountIdToOppIdMap.keyset()){
//                    if (key == acc.id){
//                        for (Id oppId : accountIdToOppIdMap.get(acc.id)){
//                            retList.addAll(getOpportunityTeamMembers(action, oppId, opportunityIdToMembersMap.get(oppId), territoryIdToMembersMap.get(acc.TerritoryCode__c)));
//                        }
//                    }
//                }
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
//** @description : Get Opportunity Team Members (OTMs) which need to be updated or deleted based on Territory Assignment Team Members (TATMs)
//** @paramaters : Action, Opportunity ID, List of existing Opportunity Team Members, List of TA Team Members
//** @returns : List of Opportunity Team Members to update or delete, per Action
//*/
//    private List<OpportunityTeamMember> getOpportunityTeamMembers(String action, Id opportunityId, List<OpportunityTeamMember> opportunityTeamMembers,List<TerritoryAssignmentTeamMember__c> territoryTeamMembers){
//
//        Boolean no_TA_Team_Member_Found;
//        Boolean MadeNewTM = false;
//        List<OpportunityTeamMember> OppTeamMembers = new List<OpportunityTeamMember>();
//        if (action == 'upsert'){
//            for(TerritoryAssignmentTeamMember__c territoryTM : territoryTeamMembers){
//                OpportunityTeamMember oppTM = alreadyExistsOTM(territoryTM.TeamMember__c, opportunityTeamMembers);
//                if(oppTM == null){
//                    oppTM = new OpportunityTeamMember();
//                    oppTM.OpportunityId = opportunityId;
//                    oppTM.UserId = territoryTM.TeamMember__c;
//                    MadeNewTM = true;
//                    //oppTM.OpportunityAccessLevel = territoryTM.OpportunityAccessLevel__c; not writeable on Standard OpportunityTeamMember, see updateOpportunityShares()
//                    system.debug('Create New Opportunity Team Member record for ' + territoryTM.TeamMember__c);
//                }
//
//                if (MadeNewTM ||                                //There was no OTM matching the TATM, made a new OTM
//                    Set_TA_Team_Member_flag_on_Existing_OTM ||  //TA_Records_per_Queueable__mdt.Set_TA_Team_Member_flag_on_Existing_OTM__c
//                                                                //is true, so set the flag even if the OTM was originally entered manually
//                    oppTM.TA_Team_Member__c == true             //Update existing OTM derived from TATM
//                    ){
//                    oppTM.TA_Team_Member__c = true;
//                    oppTM.TeamMemberRole = territoryTM.TeamMemberRole__c;
//                    OppTeamMembers.add(oppTM);
//                }
//            }
//        }
//        else if (action == 'delete'){
//            for(OpportunityTeamMember oppTM : opportunityTeamMembers){
//                no_TA_Team_Member_Found = true;
//                for(TerritoryAssignmentTeamMember__c territoryTM : territoryTeamMembers){
//                    if (oppTM.UserId == territoryTM.TeamMember__c){
//                        no_TA_Team_Member_Found = false;
//                    }
//                }
//                if (no_TA_Team_Member_Found && oppTM.TA_Team_Member__c == true){
//                    OppTeamMembers.add(oppTM);
//                }
//            }
//        }
//        return OppTeamMembers;
//    }
//
//
///*
//** @author : JHF (Appirio)
//** @date : 06/29/16
//** @description : Update the shares for the Opportunity Team Members
//** @paramaters : List of Opportunity Team Members, set of TA IDs
//** @returns : List of Opportunity shares to update
//** @NOTE: OpportunityAccessLevel is not writeable on the standard OpportunityTeamMember,
//          so use the solution from http://blog.jeffdouglas.com/2011/03/17/opportunityaccesslevel-not-writable/
//*/
//    private List<OpportunityShare> updateOpportunityShares(List<OpportunityTeamMember> updatedOTM, Set<Id> assignedTerritoryIds){
//        List<OpportunityShare> OpportunitySharesToUpdate = new List<OpportunityShare>();
//
//        Map<Id, List<TerritoryAssignmentTeamMember__c>> territoryIdToMembersMap = new Map<Id, List<TerritoryAssignmentTeamMember__c>>();
//        Map<Id, List<OpportunityTeamMember>> OTMIdToMembersMap = new Map<Id, List<OpportunityTeamMember>>();
//        Map<Id, List<OpportunityShare>> OppIdToShareMap = new Map<Id, List<OpportunityShare>>();
//        Set<Id> updatedOpportunities = new Set<Id>();
//        Set<Id> teamMembers = new Set<Id>();
//        Map<String, String> OSLookup = new Map<String, String>{'Read/Write' => 'Edit', 'Read Only' => 'Read'};
//
//
//        for (OpportunityTeamMember otm : updatedOTM){
//            if(!OTMIdToMembersMap.containsKey(otm.UserId)){
//                    OTMIdToMembersMap.put(otm.UserId, new List<OpportunityTeamMember>());
//            }
//            OTMIdToMembersMap.get(otm.UserId).add(otm);
//            updatedOpportunities.add(otm.OpportunityId);
//            teamMembers.add(otm.UserId);
//        }
//
//        List<OpportunityShare> oppShares = new List<OpportunityShare>();
//        oppShares = [SELECT Id, UserOrGroupId, OpportunityId, OpportunityAccessLevel from OpportunityShare
//                     WHERE OpportunityId in : updatedOpportunities AND UserOrGroupId in : teamMembers AND RowCause = 'Team'];
//        for(OpportunityShare os : oppShares){
//            if(!OppIdToShareMap.containsKey(os.OpportunityId)){
//                    OppIdToShareMap.put(os.OpportunityId, new List<OpportunityShare>());
//            }
//            OppIdToShareMap.get(os.OpportunityId).add(os);
//        }
//
//        //Find OpportunityShare records for the upserted OpportunityTeamMembers whose OpportunityAccessLevel != the TA Team Member OpportunityAccessLevel__c
//        for(TerritoryAssignmentTeamMember__c tm : queryTATMList(assignedTerritoryIds)){
//            if(OTMIdToMembersMap.containsKey(tm.TeamMember__c)){
//                for(OpportunityTeamMember otm : OTMIdToMembersMap.get(tm.TeamMember__c)){
//                    if(OppIdToShareMap.containsKey(otm.OpportunityId)){
//                        for(OpportunityShare os : OppIdToShareMap.get(otm.OpportunityId)){
//                            if(os.UserOrGroupId == tm.TeamMember__c){
//                                if(OSLookup.containsKey(tm.OpportunityAccessLevel__c) && os.OpportunityAccessLevel != OSLookup.get(tm.OpportunityAccessLevel__c)){
//                                    system.debug('^^^ Updating OpportunityShare ' + os.Id + ', Opportunity = ' + os.OpportunityId + ', UserOrGroupId=' + os.UserOrGroupId +
//                                                 ', OpportunityAccessLevel: TA_TM=' + tm.OpportunityAccessLevel__c + ', oppShare=' + os.OpportunityAccessLevel);
//                                    OpportunityShare oppShare = new OpportunityShare();
//                                    oppShare.Id = os.Id;
//                                    oppShare.OpportunityAccessLevel = OSLookup.get(tm.OpportunityAccessLevel__c);
//                                    OpportunitySharesToUpdate.add(oppShare);
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//        if(OpportunitySharesToUpdate.size() > 0){
//            system.debug('===OpportunitySharesToUpdate======> ' + OpportunitySharesToUpdate);
//        }
//        else {
//            system.debug('===No OpportunitySharesToUpdate======');
//        }
//        return OpportunitySharesToUpdate;
//    }
//
///*
//** @author : JHF (Appirio)
//** @date : 06/29/16
//** @description : Check whether an Opportunity Team Member exists
//** @paramaters : User ID, List of Opportunity Team Members
//** @returns : Opportunity Team Member
//*/
//    private OpportunityTeamMember alreadyExistsOTM(Id userId, List<OpportunityTeamMember> opportunityTeamMembers){
//        //system.debug('ID Check: ' + userId);
//        if(opportunityTeamMembers != null) {
//            for(OpportunityTeamMember oppTM : opportunityTeamMembers){
//                system.debug('Existing Opportunity Team Member ' + oppTM);
//                if(userId == oppTM.UserId){
//                    return oppTM;
//                }
//            }
//        }
//        return null;
//    }
//
}