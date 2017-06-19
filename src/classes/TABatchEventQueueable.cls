public with sharing class TABatchEventQueueable extends TABatchVirtualQueueable{
	final String CLASSNAME = '\n\n**** TABatchEventQueueable.METHODNAME()';

	private List<Event> eventList;
	private List<Event> eventsToUpdate;
	private TA_Records_per_Queueable__mdt batchSetting = getCustomMetadata();

	/* @Name: executeBeforeLogic
	*  @Author: Jeff L (Appirio)
	*  @Params: nothing
	*  @Returns: void
	*  @Description: overridden before logic, this just gathers up the events for the main logic
	*/
	override protected void executeBeforeLogic(){
		final string METHODNAME = CLASSNAME.replace('METHODNAME','executeBeforeLogic');
		system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

		eventList = [Select Id, OwnerId, AccountId, Bypass_All_Validation_Rules__c from Event where
					Id in :subObjectIdList
					and EventStatus__c = 'Open'];
	}

	/* @Name: executeMainLogic
	*  @Author: Jeff L (Appirio)
	*  @Params: nothing
	*  @Returns: void
	*  @Description: override Main Logic, updates the event owner if the Id of the current owner
					is the same as the previous owner.
	*/
	override protected void executeMainLogic(){
		final string METHODNAME = CLASSNAME.replace('METHODNAME','executeMainLogic');
		system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

		eventsToUpdate = new List<Event>();
        List<Id> saveIds = new List<Id>();
		Boolean bypassValidationRules = boolean.valueOf(batchSetting.get('Bypass_Validation_Rules__c'));

		for(Event e : eventList){
			if(e.OwnerId == accountWrapperMap.get(e.AccountId).oldOwnerId){
				e.ownerId = accountWrapperMap.get(e.AccountId).newOwnerId;
				//JFreese Appirio S-435483 4/6/17 Bypass all custom validation rules
				if (bypassValidationRules){
					e.Bypass_All_Validation_Rules__c = true;
				}
				eventsToUpdate.add(e);
				saveIds.add(e.Id);
			}
		}

		//update eventsToUpdate;
		Database.SaveResult[] srList = Database.update(eventsToUpdate,false);
		handleSaveErrors(srList, saveIds);
	}

	/* @Name: executeNextQueueable
	*  @Author: Jeff L (Appirio)
	*  @Params: nothing
	*  @Returns: void
	*  @Description: overriden method to call the next event queueable when needed
	*/
	override protected void executeNextQueueable(){
		final string METHODNAME = CLASSNAME.replace('METHODNAME','executeNextQueueable');
		system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

		configObject.offset = offSet + subObjectIdList.size();
		TABatchEventQueueable nextQueueable = new TABatchEventQueueable(configObject);
		Id jobId = System.enqueueJob(nextQueueable);
		insertNewQueueableLog(jobId);
	}


	//Constructors
	public TABatchEventQueueable(TABatchVirtualQueueable.TABatchConfiguration pConfigObject){
		super(pConfigObject);
	}
}