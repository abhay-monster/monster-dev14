/*
** @author : Cloud Sherpas Inc.
** @date : 03/26/2014
** @description : Task Trigger for all CRUD events. 
*/

//note - Based on Trigger Template created by Mike Leach http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx

trigger TaskTrigger on Task (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    TaskTriggerHandler handler = new TaskTriggerHandler(Trigger.isExecuting, Trigger.size);
    
    if(Trigger.isInsert && Trigger.isBefore){
        
        // before insert event 
        
            // call the on before update event handler
            handler.OnBeforeInsert(Trigger.new);
        
                   
    }
    else if(Trigger.isInsert && Trigger.isAfter){
        
                        
            // call the on before update event handler
            handler.OnAfterInsert(Trigger.new);
          
    }
    
    else if(Trigger.isUpdate && Trigger.isBefore){
        
                        
            // call the on before update event handler
            handler.onBeforeUpdate(Trigger.new, trigger.oldMap);
        
    } 
    else if(Trigger.isUpdate && Trigger.isAfter){
        
            // call the on before update event handler
            handler.OnAfterUpdate(Trigger.new,Trigger.oldMap);
        
    }
    
    else if(Trigger.isDelete && Trigger.isBefore){
        
            handler.onBeforeDelete(Trigger.old, trigger.oldMap);
        
    }
    else if(Trigger.isDelete && Trigger.isAfter){
        
            handler.onAfterDelete(Trigger.old, trigger.oldMap);
        
    }
    
}