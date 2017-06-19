public without sharing class TABatchContactQueueable extends TABatchVirtualQueueable {
	final String CLASSNAME = '\n\n**** TABatchContactQueueable.METHODNAME()';

	private Map<Id,Id> contactToAccountMap;
	private TA_Records_per_Queueable__mdt batchSetting = getCustomMetadata();

	/* @Name: executeBeforeLogic
	*  @Author: Jeff L (Appirio)
	*  @Params: nothing
	*  @Returns: void
	*  @Description: overridden before logic, this just gathers up the contacts and
					builds the contact to account map needed for the main logic
	*/
	override protected void executeBeforeLogic(){
		final string METHODNAME = CLASSNAME.replace('METHODNAME','executeBeforeLogic');
		system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

		system.debug('^^^ Inside Contact executeBeforeLogic Queue_Thread=' + Queue_Thread + ', configObject.Queue_Thread=' + configObject.Queue_Thread + ', configObject.Queue_Id=' + configObject.Queue_Id);

		contactToAccountMap = new Map<Id,Id>();
		for(Contact con : [Select Id, AccountId, Bypass_All_Validation_Rules__c from Contact where Id in :subObjectIdList]){
			contactToAccountMap.put(con.Id,con.AccountId);
		}
	}

	/* @Name: executeMainLogic
	*  @Author: Jeff L (Appirio)
	*  @Params: nothing
	*  @Returns: void
	*  @Description: overridden Main logic, this updates the contact owner and organization
					based upon the Account related to the contact
	*/
	override protected void executeMainLogic(){
		final string METHODNAME = CLASSNAME.replace('METHODNAME','executeMainLogic');
		system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

		List<Contact> contactsToUpdate = new List<Contact>();
        List<Id> saveIds = new List<Id>();
		Boolean bypassValidationRules = boolean.valueOf(batchSetting.get('Bypass_Validation_Rules__c'));

		for(Id conId : subObjectIdList){
			Id accountId = contactToAccountMap.get(conId);
			Contact c = new Contact(Id=conId);
			c.OwnerId = accountWrapperMap.get(accountId).newOwnerId;
			c.Organization__c = accountWrapperMap.get(accountId).organization;
			//JFreese Appirio S-435483 4/6/17 Bypass all custom validation rules
			if (bypassValidationRules){
				c.Bypass_All_Validation_Rules__c = true;
			}

			contactsToUpdate.add(c);
			saveIds.add(c.Id);
		}
			Database.SaveResult[] srList =  Database.update(contactsToUpdate, false);
			handleSaveErrors(srList, saveIds);
	}

	/* @Name: executeNextQueueable
	*  @Author: Jeff L (Appirio)
	*  @Params: nothing
	*  @Returns: void
	*  @Description: overridden next method, calling this method means we have more
					contacts to process, it gets the next queueable up and enqueued
	*/
	override protected void executeNextQueueable(){
		final string METHODNAME = CLASSNAME.replace('METHODNAME','executeNextQueueable');
		system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

		configObject.offset = offSet + subObjectIdList.size();
		system.debug('^^^ Inside Contact executeNextQueueable Queue_Thread=' + Queue_Thread + ', configObject.Queue_Thread=' + configObject.Queue_Thread + ', configObject.Queue_Id=' + configObject.Queue_Id);
		TABatchContactQueueable nextQueueable = new TABatchContactQueueable(configObject);
		Id jobId = System.enqueueJob(nextQueueable);
		insertNewQueueableLog(jobId);
	}

	/* @Name: executeLastLogic
	*  @Author: Jeff L (Appirio)
	*  @Params: nothing
	*  @Returns: void
	*  @Description: overridden Last logic, if we are hitting this method it means we
					in the last queueable for the Contacts, so we need to start the
					next queueable (Opportunity)
	*/
	override protected void executeLastLogic(){
		final string METHODNAME = CLASSNAME.replace('METHODNAME','executeLastLogic');
		system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

		TABatchVirtualQueueable.TABatchConfiguration newConfig = configObject.cloneForNextBatch();
		newConfig.objectIdList = queryOpportunityList();
		newConfig.customMetadataString = 'Opportunity__c';
		newConfig.objectName = 'Opportunity';
		TABatchOpportunityQueueable newOppQueueable = new TABatchOpportunityQueueable(newConfig);
		if(Test.isRunningTest() == false){
			//can't chain them in test classes, get an error
			newOppQueueable.enqueueTA();
		}
	}

	//Constructors
	public TABatchContactQueueable(List<Account> pAccountList, Map<Id,Id> pOldAccountMap, List<Id> pObjectIdList, Integer pOffSet, String pCustomMetadataString){
		super(pAccountList, pOldAccountMap, pObjectIdList, pOffSet, pcustomMetadataString, 'Contact');
	}

	public TABatchContactQueueable(TABatchVirtualQueueable.TABatchConfiguration pConfigObject){
		super(pConfigObject);
	}

	/* @Name: queryOpportunityList
	*  @Author: Jeff L (Appirio)
	*  @Params: nothing
	*  @Returns: List of Opportunity Ids
	*  @Description: this will query a list of opportunities in preperation for
					passing them into the opportunity queueable
	*/
	private List<Id> queryOpportunityList(){
		final string METHODNAME = CLASSNAME.replace('METHODNAME','queryOpportunityList');
		system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
		List<Id> returnList = new List<Id>();
		Set<String> stage = new Set<String>{'Stage 0 - Lead Generation', 'Stage 1 - Needs Assessment', 'Stage 2 - Proposal', 'Stage 3 - Quote', 'Stage 4 - Won'};
		For(Opportunity opp : [Select Id From opportunity
					where AccountId in :accountWrapperMap.keySet()
					and StageName in :stage]){
			returnList.add(opp.Id);
		}

		return returnList;
	}

}