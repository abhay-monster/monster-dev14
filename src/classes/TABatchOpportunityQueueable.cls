public without sharing class TABatchOpportunityQueueable extends TABatchVirtualQueueable {
	final String CLASSNAME = '\n\n**** TABatchOpportunityQueueable.METHODNAME()';

	private Map<Id,Id> oppToAccountMap;
	private Map<Id,Account> accountMap;
	private Map<Id, List<Account_Team_Member__c>> accountTeamMembers;
	private List<Opportunity> oppList;
	private TA_Records_per_Queueable__mdt batchSetting = getCustomMetadata();
	public static Boolean bypassOpportunityValidationRules {get;set;} //JFreese Appirio 4/9/17 S-435483



	/* @Name: executeBeforeLogic
	*  @Author: Jeff L (Appirio)
	*  @Params: nothing
	*  @Returns: void
	*  @Description: overridden before logic, this just gathers up the Opportunities and
					builds the opp to account map, and opportunity team member map needed
					for the main logic
	*/
	override protected void executeBeforeLogic(){
		final string METHODNAME = CLASSNAME.replace('METHODNAME','executeBeforeLogic');
		system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

		oppToAccountMap = new Map<Id,Id>();
		oppList = new List<Opportunity>();
		for(Opportunity opp : [Select Id,OwnerId,AccountId, Bypass_All_Validation_Rules__c
			                   from Opportunity where Id in :subObjectIdList]){
			oppToAccountMap.put(opp.Id,opp.AccountId);
			oppList.add(opp);
		}

		accountMap = new Map<Id,Account>();
		//this is needed for the weird logic in ChangeOpportunityOwner
		for(Id aId : oppToAccountMap.values()){
			TABatchVirtualQueueable.AccountWrapper aw = accountWrapperMap.get(aId);
			Account acc = new Account(Id=aId);
			acc.OwnerId = aw.newOwnerId;
			accountMap.put(aID,acc);
		}

		//also needed for the strange ChangeOpportunityOwner logic
		accountTeamMembers = getAccountTeamMembers();

	}

	/* @Name: executeMainLogic
	*  @Author: Jeff L (Appirio)
	*  @Params: nothing
	*  @Returns: void
	*  @Description: override Main Logic, this just calls a private method to change
					the owner of the opportunity
	*/
	override protected void executeMainLogic(){
		final string METHODNAME = CLASSNAME.replace('METHODNAME','executeMainLogic');
		system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
		//TODO move this into the queueable itself ;
		ChangeOpportunityOwner(accountMap,accountTeamMembers,oppList);
	}

	/* @Name: executeNextQueueable
	*  @Author: Jeff L (Appirio)
	*  @Params: nothing
	*  @Returns: void
	*  @Description: overridden next method, calling this method means we have more
					opportunities to process, it gets the next queueable up and enqueued
	*/
	override protected void executeNextQueueable(){
		final string METHODNAME = CLASSNAME.replace('METHODNAME','executeNextQueueable');
		system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

		configObject.offset = offSet + subObjectIdList.size();
		TABatchOpportunityQueueable nextQueueable = new TABatchOpportunityQueueable(configObject);
		Id jobId = System.enqueueJob(nextQueueable);
		insertNewQueueableLog(jobId);
	}

	/* @Name: executeLastLogic
	*  @Author: Jeff L (Appirio)
	*  @Params: nothing
	*  @Returns: void
	*  @Description: overridden Last logic, if we are hitting this method it means we
					in the last queueable for the Opportunities, so we need to start the
					next queueable (Proposals)
	*/
	override protected void executeLastLogic(){
		final string METHODNAME = CLASSNAME.replace('METHODNAME','executeLastLogic');
		system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

		TABatchVirtualQueueable.TABatchConfiguration newConfig = configObject.cloneForNextBatch();
		newConfig.objectIdList = queryProposalList();
		newConfig.customMetadataString = 'Proposal__c';
		newConfig.objectName = 'Apttus_Proposal__Proposal__c';

		TABatchProposalQueueable newOppQueueable = new TABatchProposalQueueable(newConfig);
		//if(Test.isRunningTest() == false){
		newOppQueueable.enqueueTA();
		//}
	}


	//Constructors
	public TABatchOpportunityQueueable(TABatchVirtualQueueable.TABatchConfiguration pConfigObject){
		super(pConfigObject);
        bypassOpportunityValidationRules = false; //JFreese Appirio 4/9/17 S-435483
        system.debug('^^^bypassOpportunityValidationRules='+bypassOpportunityValidationRules); // see TABatchContactQueueable log
	}


 	/* @Name: getAccountTeamMembers
 	*  @Author: Jeff L (Appirio)
 	*  @Params: nothing
 	*  @Returns: Map<Id,List<Account_Team_Member__c>>
 	*  @Description: small helper method that will gather all the account team members
 					For the accounts we are processing (related to our opps)
 	*/
	private Map<Id, List<Account_Team_Member__c>> getAccountTeamMembers(){

		Map<Id,List<Account_Team_Member__c>> returnMap = new Map<Id,List<Account_Team_Member__c>>();

		for(Account_Team_Member__c atm : [Select Id, UserId__c, AccountId__c, TeamMemberRole__c,
					AccountAccessLevel__c, CaseAccessLevel__c, OpportunityAccessLevel__c
					FROM Account_Team_Member__c
					Where AccountId__c in :oppToAccountMap.values()]){
			if(!returnMap.containsKey(atm.AccountId__c)){
				returnMap.put(atm.AccountId__c, new List<Account_Team_Member__c>());
			}
			returnMap.get(atm.AccountId__c).add(atm);
		}

		return returnMap;
	}

 	/* @Name: queryProposalList
 	*  @Author: Jeff L (Appirio)
 	*  @Params: nothing
 	*  @Returns: List<Id>
 	*  @Description: helper method for querying the proposals needed for the next
 					queueuable
 	*/
	private List<Id> queryProposalList(){
		List<Id> returnList = new List<Id>();
		Set<String> proposalStatus = new Set<String>{'Inactive' , 'Expired' , 'Closed' };

		For(Apttus_Proposal__Proposal__c prop : [Select Id from Apttus_Proposal__Proposal__c
					where QuoteStatus__c not in :proposalStatus
					and Apttus_Proposal__Account__c in :accountWrapperMap.keySet()]){
			returnList.add(prop.Id);
		}

		return returnList;
	}

 	/* @Name: getAccountTeamMembers
 	*  @Author: Jeff L (Appirio)
 	*  @Params: Map<Id,Account>, Map<Id,List<Account_Team_Member__c>>, List<Opportunity>
 	*  @Returns: void
 	*  @Description: this actually ws copied from another method in AccountTriggerHelper, added logic to handle the save errors
 	*/
	private void ChangeOpportunityOwner(map<ID, Account> pAccountIdToNewAccountMap,map<Id, List<Account_Team_Member__c>> atm, List<Opportunity> oppList){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','changeOpportunityOwner');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        List<Id> lstUpdatedOwners = new List<Id>();
        List<Id> updateOwners = new List<Id>();
        List<Id>  finalUpdate = new List<Id>();
        Map<Id, OpportunitySplit> oSplit = new Map<Id, OpportunitySplit>();
        try{
            List<Opportunity> oppToBeUpdated = new List<Opportunity>();
	        List<Id> saveIds = new List<Id>();
			Boolean bypassValidationRules = boolean.valueOf(batchSetting.get('Bypass_Validation_Rules__c'));

            for(Opportunity o : oppList){
                //system.debug('^^OwnerId' + o.OwnerId);
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
                        //JFreese Appirio S-435483 4/6/17 Bypass all custom validation rules
						if (bypassValidationRules){
							o.Bypass_All_Validation_Rules__c = true;
						}
                        lstUpdatedOwners.add(pAccountIdToNewAccountMap.get(o.AccountId).OwnerId);
                        oppToBeUpdated.add(o);
                        saveIds.add(o.Id);
                    }
                }
            }
            if(oppToBeUpdated.size() > 0){
                OpportunityTriggerHandler.PreventRecursion = true;
                //update oppToBeUpdated;
                Database.SaveResult[] srList = Database.update(oppToBeUpdated, false);
                handleSaveErrors(srList, saveIds);

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
                	List<OpportunityTeamMember> otmToDelete = [Select Id from OpportunityTeamMember where UserId in :finalUpdate AND  OpportunityId in : oppToBeUpdated];
			        List<Id> deleteIds = new List<Id>();
			        for(OpportunityTeamMember o : otmToDelete){
			        	deleteIds.add(o.Id);
			        }
			        //JFreese Appirio S-435483 4/6/17 Bypass all custom validation rules when the OTM deletion updates the opp
			        //Opportunities are updated in OpportunityTeamMemberTriggerHelper.UpdateoppSalesRepOndelete
			        if (bypassValidationRules){
				        bypassOpportunityValidationRules = true;
				    }
                    Database.DeleteResult[] deleteList = Database.delete(otmToDelete, false);
                    handleDeleteErrors(deleteList, deleteIds);
                }
            }
        }catch(DMLException e){
            ExceptionLog.add('DMLException', 'AccountTriggerHelper', 'changeOpportunityOwner', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to update opportunity.' ,e);
        }
    }
}