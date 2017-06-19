trigger OpportunitySplitTrigger on OpportunitySplit (before insert,after insert, before update,before delete) {

    OpportunitySplitTriggerHandler handler  = new OpportunitySplitTriggerHandler(Trigger.isExecuting, Trigger.size);

    if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new);
    }

    if(Trigger.isInsert && Trigger.isAfter){
         handler.OnAfterInsert(trigger.new, trigger.newMap);
    }

    if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.new, Trigger.newMap);
    }
    
    if(Trigger.isDelete && Trigger.isBefore){
         handler.OnBeforeDelete(trigger.old, trigger.oldMap);
    }
}