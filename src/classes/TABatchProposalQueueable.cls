public without sharing class TABatchProposalQueueable extends TABatchVirtualQueueable {
	final String CLASSNAME = '\n\n**** TABatchProposalQueueable.METHODNAME()';

	private Map<Id,Account> accountMap;
	private List<Apttus_Proposal__Proposal__c> proposalList;
	private TA_Records_per_Queueable__mdt batchSetting = getCustomMetadata();
	public static Boolean bypassProposalValidationRules {get;set;} //Sberron - S-481450 - 4/27/17

	/* @Name: executeBeforeLogic
	*  @Author: Jeff L (Appirio)
	*  @Params: nothing
	*  @Returns: void
	*  @Description: overridden before logic, this just gathers up the Proposals and
					builds the account map for the main logic
	*/
	override protected void executeBeforeLogic(){
		final string METHODNAME = CLASSNAME.replace('METHODNAME','executeBeforeLogic');
		system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

		Set<String> proposalStatus = new Set<String>{'Inactive' , 'Expired' , 'Closed' };
		proposalList = new List<Apttus_Proposal__Proposal__c>();
		accountMap = new Map<Id,Account>();
		//we need an accountMap and a proposal Map for this process
		for(Apttus_Proposal__Proposal__c prop : [Select Id, OwnerId, QuoteStatus__c,
					Apttus_Proposal__Account__c, Bypass_All_Validation_Rules__c
					from Apttus_Proposal__Proposal__c
					where QuoteStatus__c not in :proposalStatus
					and Id in :subObjectIdList]){
			proposalList.add(prop);
			Account acc = new Account(Id = prop.Apttus_Proposal__Account__c);
			acc.OwnerId = accountWrapperMap.get(acc.Id).newOwnerId;

			accountMap.put(acc.Id,acc);
		}
	}

	/* @Name: executeMainLogic
	*  @Author: Jeff L (Appirio)
	*  @Params: nothing
	*  @Returns: void
	*  @Description: override Main Logic, this just calls a private method to change
					the owner of the proposal
	*/
	override protected void executeMainLogic(){
		final string METHODNAME = CLASSNAME.replace('METHODNAME','executeMainLogic');
		system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

		ChangeProposalOwner(accountMap, proposalList);
	}

	/* @Name: executeNextQueueable
	*  @Author: Jeff L (Appirio)
	*  @Params: nothing
	*  @Returns: void
	*  @Description: overridden method for calling the next proposal queueable
	*/
	override protected void executeNextQueueable(){
		final string METHODNAME = CLASSNAME.replace('METHODNAME','executeNextQueueable');
		system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

		configObject.offset = offSet + subObjectIdList.size();
		TABatchProposalQueueable nextQueueable = new TABatchProposalQueueable(configObject);
		Id jobId = System.enqueueJob(nextQueueable);
		insertNewQueueableLog(jobId);
	}

	/* @Name: executeLastLogic
	*  @Author: Jeff L (Appirio)
	*  @Params: nothing
	*  @Returns: void
	*  @Description: only gets called when we are the last in the proposal queueables
					it means we need to set up and get the task queueable going
	*/
	override protected void executeLastLogic(){
		final string METHODNAME = CLASSNAME.replace('METHODNAME','executeLastLogic');
		system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

		TABatchVirtualQueueable.TABatchConfiguration newConfig = configObject.cloneForNextBatch();
		newConfig.objectIdList = queryTaskList();
		newConfig.customMetadataString = 'Activity__c';
		newConfig.objectName = 'Task';

		TABatchTaskQueueable newTaskQueueable = new TABatchTaskQueueable(newConfig);
		newTaskQueueable.enqueueTA();
	}

	//Constructors
	public TABatchProposalQueueable(TABatchVirtualQueueable.TABatchConfiguration pConfigObject){
		super(pConfigObject);
		bypassProposalValidationRules = false;
		System.debug('----bypassProposalValidationRules = ' + bypassProposalValidationRules);
	}

 	/* @Name: queryTaskList
 	*  @Author: Jeff L (Appirio)
 	*  @Params: nothing
 	*  @Returns: List<Id>
 	*  @Description: helper method for querying the tasks needed for the next
 					queueuable
 	*/
	private List<Id> queryTaskList(){
		List<Id> returnList = new List<Id>();
		for(Task t : [Select Id, OwnerId, AccountId From Task where Task.AccountId in :accountWrapperMap.keyset()]){
			if(t.OwnerID == accountWrapperMap.get(t.AccountId).oldOwnerId)
			returnList.add(t.Id);
		}
		return returnList;
	}

 	/* @Name: ChangeProposalOwner
 	*  @Author: Jeff L (Appirio)
 	*  @Params: nothing
 	*  @Returns: List<Id>
 	*  @Description: helper method for changing the proposal owner, copied from AccountTriggerhelper
 	*/
	private void ChangeProposalOwner(map<ID, Account> pAccountIdToNewAccountMap, List<Apttus_Proposal__Proposal__c> quoteList){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','changeProposalOwner');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        List<Apttus_Proposal__Proposal__c> listItems = new List<Apttus_Proposal__Proposal__c>();
        List<Id> saveIds = new List<Id>();
		Boolean bypassValidationRules = boolean.valueOf(batchSetting.get('Bypass_Validation_Rules__c'));

        Set<String> proposalStatus = new Set<String>{'Inactive' , 'Expired' , 'Closed' };
        for(Apttus_Proposal__Proposal__c prop : quoteList) {
            if(proposalStatus.contains(prop.QuoteStatus__c) != true){
                Account currAcc = pAccountIdToNewAccountMap.get(prop.Apttus_Proposal__Account__c);
               if(prop.ownerId != currAcc.OwnerId){
                    prop.ownerId = currAcc.OwnerId;
					//JFreese Appirio S-435483 4/6/17 Bypass all custom validation rules
					if (bypassValidationRules){
						prop.Bypass_All_Validation_Rules__c = true;
						bypassProposalValidationRules = true; //Sberron -  S-481334 - 4/27/17
					}
                    listItems.add(prop);
                    saveIds.add(prop.Id);
               }
            }
        }
        if(listItems.size() > 0){
            //update listItems;
            Database.SaveResult[] srList = Database.update(listItems, false);
            handleSaveErrors(srList, saveIds);
        }
    }

}