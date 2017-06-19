trigger TerritoryAssignmentCodeTrigger on TerritoryAssignmentCode__c (before insert, before update) {
	TerritoryAssignmentCodeTriggerHandler objHandler = new TerritoryAssignmentCodeTriggerHandler(Trigger.isExecuting, Trigger.size);
	if(trigger.isBefore){
		if(trigger.isInsert) {
			objHandler.beforeInsert(trigger.new);
		} else if(trigger.isUpdate) {
			objHandler.beforeUpdate(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
		}
    }
}