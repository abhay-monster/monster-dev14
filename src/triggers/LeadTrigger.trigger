trigger LeadTrigger on Lead (before insert, before update, after update, after insert) {

    if(trigger.isAfter){
        if(trigger.isInsert  && Trigger.isAfter){
            leadTriggerHandler.onAfterInsert(trigger.new);
        } else if(Trigger.isUpdate && Trigger.isAfter){
            leadTriggerHandler.onAfterUpdate(trigger.new, trigger.oldMap);        
    }
        
    }
    
    if(trigger.isBefore && trigger.isInsert)
    {
        leadTriggerHandler.onBeforeInsert(trigger.new);
    }
    
    if(trigger.isBefore && trigger.isUpdate)
    {
        leadTriggerHandler.onBeforeUpdate(trigger.new, null);
    }
}