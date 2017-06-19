public with sharing class TerritoryAssignmentCodeTriggerHandler extends BaseTriggerHandler{
    private TerritoryAssignmentCodeTriggerHelper helper;
    private integer BatchSize = 0;


/*
** @author : Appirio (Jonathan Freese)
** @date : 04/21/16
** @description : the class constructor method
** @parameters : nothing
** @returns : nothing
*/
    public TerritoryAssignmentCodeTriggerHandler(boolean isExecuting, integer pTriggerSize){
        // trigger is executing
        TriggerIsExecuting = isExecuting;

        // set batch size
        BatchSize = pTriggerSize;

        // instantiate new trigger helper
        helper = TerritoryAssignmentCodeTriggerHelper.NewTriggerHelper();
    }


	public void beforeInsert(List<TerritoryAssignmentCode__c> newTACs) {
        if (Personal_Settings__c.getInstance().Trigger_Territory_Assignment_Code__c ==false){
            return; // If triggers are off, then exit the method
        }
		helper.process_Zipcodes(newTACs);
	}


	public void beforeUpdate(List<TerritoryAssignmentCode__c> pOldTACs, List<TerritoryAssignmentCode__c> pUpdatedTACs, Map<Id, TerritoryAssignmentCode__c> pTacIdToOldTacMap, Map<Id, TerritoryAssignmentCode__c> pTacIdToUpdatedTacMap) {
        if (Personal_Settings__c.getInstance().Trigger_Territory_Assignment_Code__c ==false){
            return; // If triggers are off, then exit the method
        }
		helper.process_Zipcodes(pUpdatedTACs);
		updateTerritoryAssignmentProcess(pUpdatedTACs, pTacIdToOldTacMap);
	}

	private static void updateTerritoryAssignmentProcess(List<TerritoryAssignmentCode__c> pUpdatedTACs, Map<Id, TerritoryAssignmentCode__c> pTacIdToOldTacMap) {
		Map<Id, TerritoryAssignment__c> mapTerritoryAssgnToUpdate = new Map<Id, TerritoryAssignment__c>();
		//Set<Id> setNewTerritoryAssgn = new Set<Id>();
		//Set<Id> setOldTerritoryAssgn = new Set<Id>();

		for(TerritoryAssignmentCode__c assignCode : pUpdatedTACs) {
			if((assignCode.TerritoryAssignment__c != pTacIdToOldTacMap.get(assignCode.Id).TerritoryAssignment__c) ||
				(assignCode.PostingZipCodeEnd__c != pTacIdToOldTacMap.get(assignCode.Id).PostingZipCodeEnd__c) ||
				(assignCode.PostingZipCodeStart__c != pTacIdToOldTacMap.get(assignCode.Id).PostingZipCodeEnd__c)) {
				TerritoryAssignment__c newTerritoryAssgn = new TerritoryAssignment__c(Id = assignCode.TerritoryAssignment__c);
				newTerritoryAssgn.Processed__c = false;
				mapTerritoryAssgnToUpdate.put(newTerritoryAssgn.Id, newTerritoryAssgn);
				//setNewTerritoryAssgn.add(newTerritoryAssgn.Id);

				TerritoryAssignment__c oldTerritoryAssgn = new TerritoryAssignment__c(Id = pTacIdToOldTacMap.get(assignCode.Id).TerritoryAssignment__c);
				oldTerritoryAssgn.Processed__c = false;
				mapTerritoryAssgnToUpdate.put(oldTerritoryAssgn.Id, oldTerritoryAssgn);
				//setOldTerritoryAssgn.add(oldTerritoryAssgn.Id);//listTerritoryAssgnToUpdate.add(oldTerritoryAssgn);
			}
		}
		update mapTerritoryAssgnToUpdate.values();

		/*List<Account_Team_Member__c> atmToDeleteList = deleteAccountTeamMembers(setOldTerritoryAssgn);
		if(atmToDeleteList != null && atmToDeleteList.size() > 0) {
			delete atmToDeleteList;
		}*/
	}


    /*private static List<Account_Team_Member__c> deleteAccountTeamMembers(Set<Id> setOldTerritoryAssgn){

		List<Account_Team_Member__c> deleteList = new List<Account_Team_Member__c>();
		Map<Id, List<TerritoryAssignmentTeamMember__c>> territoryIdToMembersMap = new Map<Id, List<TerritoryAssignmentTeamMember__c>>();
		Map<Id, List<Account_Team_Member__c>> accountIdToMembersMap = new Map<Id, List<Account_Team_Member__c>>();
		List<Account> listAcc = new List<Account>();

		for(Account acc : [SELECT Id, TerritoryCode__c
							FROM Account
							WHERE TerritoryCode__c IN : setOldTerritoryAssgn]) {
			listAcc.add(acc);
		}

		for(TerritoryAssignmentTeamMember__c teamMember: [Select id, TeamMember__c, TeamMemberRole__c, TerritoryAssignment__c,
    																						AccountAccessLevel__c, CaseAccessLevel__c, OpportunityAccessLevel__c
    																						from TerritoryAssignmentTeamMember__c
    																						where TerritoryAssignment__c in : setOldTerritoryAssgn]){
			if(!territoryIdToMembersMap.containsKey(teamMember.TerritoryAssignment__c)){
					territoryIdToMembersMap.put(teamMember.TerritoryAssignment__c, new List<TerritoryAssignmentTeamMember__c>());
			}
			territoryIdToMembersMap.get(teamMember.TerritoryAssignment__c).add(teamMember);
		}

        for(Account_Team_Member__c teamMember : [SELECT Id, UserId__c, TeamMemberRole__c, AccountId__c,
        																				 AccountAccessLevel__c, CaseAccessLevel__c, OpportunityAccessLevel__c
                                                 FROM Account_Team_Member__c
                                                 where AccountId__c IN : listAcc]){
             if(!accountIdToMembersMap.containsKey(teamMember.AccountId__c)){
                accountIdToMembersMap.put(teamMember.AccountId__c, new List<Account_Team_Member__c> ());
             }
             accountIdToMembersMap.get(teamMember.AccountId__c).add(teamMember);
        }

        for(Account acc : listAcc){
        	if(territoryIdToMembersMap.get(acc.TerritoryCode__c) != null){
        		deleteList.addAll(getAccountTeamMembers(acc.id, accountIdToMembersMap.get(acc.id), territoryIdToMembersMap.get(acc.TerritoryCode__c)));
        	}
        }

        return deleteList;
    }


    private static List<Account_Team_Member__c> getAccountTeamMembers(Id accountId, List<Account_Team_Member__c> accountTeamMembers,
    																														List<TerritoryAssignmentTeamMember__c> territoryTeamMembers){
    	List<Account_Team_Member__c> listAccTeamMemberToDel = new List<Account_Team_Member__c>();
    	for(TerritoryAssignmentTeamMember__c territoryTM : territoryTeamMembers){
    		Account_Team_Member__c accTM = alreadyExists(territoryTM.TeamMember__c, accountTeamMembers);
    		if(accTM != null){
    			listAccTeamMemberToDel.add(accTM);
    		}
    	}
    	return listAccTeamMemberToDel;
    }

    private static Account_Team_Member__c alreadyExists(Id userId, List<Account_Team_Member__c> accountTeamMembers){
    	for(Account_Team_Member__c accTM : accountTeamMembers){
    		if(userId == accTM.UserId__c){
    			return accTM;
    		}
    	}
    	return null;
    }*/
}