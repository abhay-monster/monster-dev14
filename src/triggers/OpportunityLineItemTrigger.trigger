trigger OpportunityLineItemTrigger on OpportunityLineItem (before insert, after insert, before update, after update, before delete, after delete) {

	OpportunityLineItemTriggerHandler handler  = new OpportunityLineItemTriggerHandler(Trigger.isExecuting, Trigger.size);

	if(Trigger.isInsert && Trigger.isBefore){
       handler.OnBeforeInsert(Trigger.new);
    }

    if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(trigger.new, trigger.newMap);
    }

    if(Trigger.isUpdate && Trigger.isBefore){
       handler.OnBeforeUpdate(Trigger.new, Trigger.newMap);
    }

    if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(trigger.new, trigger.newMap);
    }
    
    if(Trigger.isDelete && Trigger.isBefore){
        handler.OnBeforeDelete(trigger.old, trigger.oldMap);
    }
    if(Trigger.isDelete && Trigger.isAfter){
        handler.OnAfterDelete(trigger.old, trigger.oldMap);
    }
}