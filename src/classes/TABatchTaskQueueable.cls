public without sharing class TABatchTaskQueueable extends TABatchVirtualQueueable {
	final String CLASSNAME = '\n\n**** TABatchTaskQueueable.METHODNAME()';

	private List<Task> taskList;
	private List<Task> tasksToBeUpdated;
	private TA_Records_per_Queueable__mdt batchSetting = getCustomMetadata();

	/* @Name: executeBeforeLogic
	*  @Author: Jeff L (Appirio)
	*  @Params: nothing
	*  @Returns: void
	*  @Description: overridden before logic, this just gathers up the Tasks for the main logic
	*/
	override protected void executeBeforeLogic(){
		final string METHODNAME = CLASSNAME.replace('METHODNAME','executeBeforeLogic');
		system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
		taskList = [Select Id, OwnerId, AccountId, Bypass_All_Validation_Rules__c
					from Task
					where Id in :subObjectIdList
					and Status = 'Open'];
	}

	/* @Name: executeMainLogic
	*  @Author: Jeff L (Appirio)
	*  @Params: nothing
	*  @Returns: void
	*  @Description: override Main Logic, updates the task owner if the Id of the current owner
					is the same as the previous owner.
	*/
	override protected void executeMainLogic(){
		final string METHODNAME = CLASSNAME.replace('METHODNAME','executeMainLogic');
		system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

		tasksToBeUpdated = new List<Task>();
        List<Id> saveIds = new List<Id>();
		Boolean bypassValidationRules = boolean.valueOf(batchSetting.get('Bypass_Validation_Rules__c'));

		for(Task t : taskList){
			//check to see if the owner of the task was the same as the old owner
			if(t.OwnerID == accountWrapperMap.get(t.AccountId).oldOwnerId){
				t.ownerId = accountWrapperMap.get(t.AccountId).newOwnerId;
				//JFreese Appirio S-435483 4/6/17 Bypass all custom validation rules
				if (bypassValidationRules){
					t.Bypass_All_Validation_Rules__c = true;
				}
				tasksToBeUpdated.add(t);
				saveIds.add(t.Id);

			}
		}
		//update tasksToBeUpdated;
		Database.SaveResult[] srList = Database.update(tasksToBeUpdated,false);
		handleSaveErrors(srList, saveIds);
	}

	/* @Name: executeNextQueueable
	*  @Author: Jeff L (Appirio)
	*  @Params: nothing
	*  @Returns: void
	*  @Description: overriden method to call the next Task queueable when needed
	*/
	override protected void executeNextQueueable(){
		final string METHODNAME = CLASSNAME.replace('METHODNAME','executeNextQueueable');
		system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

		configObject.offset = offSet + subObjectIdList.size();
		TABatchTaskQueueable nextQueueable = new TABatchTaskQueueable(configObject);
		Id jobId = System.enqueueJob(nextQueueable);

		insertNewQueueableLog(jobId);
	}

	/* @Name: executeLastLogic
	*  @Author: Jeff L (Appirio)
	*  @Params: nothing
	*  @Returns: void
	*  @Description: overriden method to execute the next queuable once tasks are
					complete. in this case it calls Event
	*/
	override protected void executeLastLogic(){
		final string METHODNAME = CLASSNAME.replace('METHODNAME','executeLastLogic');
		system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

		TABatchVirtualQueueable.TABatchConfiguration newConfig = configObject.cloneForNextBatch();
		newConfig.objectIdList = queryEventList();
		newConfig.customMetadataString = 'Activity__c';
		newConfig.objectName = 'Event';

		TABatchEventQueueable newTaskQueueable = new TABatchEventQueueable(newConfig);
		newTaskQueueable.enqueueTA();
	}

	//Constructors
	public TABatchTaskQueueable(TABatchVirtualQueueable.TABatchConfiguration pConfigObject){
		super(pConfigObject);
	}

 	/* @Name: queryEventList
	*  @Author: Jeff L (Appirio)
	*  @Params: nothing
	*  @Returns: void
	*  @Description:small query to get the list of Events needed for the next queueable
	*/
	private List<Id> queryEventList(){
		List<Id> returnList = new List<Id>();
		for(Event e : [Select Id, AccountId, OwnerId from Event
						Where AccountId in : accountWrapperMap.keySet()
						and EventStatus__c = 'Open']){
			returnList.add(e.Id);
		}

		return returnList;
	}
}