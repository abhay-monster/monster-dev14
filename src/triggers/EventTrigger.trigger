trigger EventTrigger on Event (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
/*
** @author : Cloud Sherpas Inc.
** @date : 07/22/2014
** @description : Event Trigger for all CRUD events. 
*/

//note - Based on Trigger Template created by Mike Leach http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx
    EventTriggerHandler handler = new EventTriggerHandler(Trigger.isExecuting, Trigger.size);
    
    if(Trigger.isInsert && Trigger.isBefore){
               handler.OnBeforeInsert(trigger.new);         
                 
    }
    else if(Trigger.isInsert && Trigger.isAfter){
        //Method not Implemented       
        
            handler.OnAfterInsert(trigger.new);
        
    }
    
    else if(Trigger.isUpdate && Trigger.isBefore){
        //Method not Implemented 
        handler.OnBeforeUpdate(trigger.new);
            
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(trigger.new,Trigger.oldMap);
    }
    
    else if(Trigger.isDelete && Trigger.isBefore){
       
        handler.onBeforeDelete(Trigger.old, trigger.oldMap);
        
    }
    /* Folowing block has no code so commenting it
    else if(Trigger.isDelete && Trigger.isAfter){
        //Method not Implemented    
    }
    
    else if(Trigger.isUnDelete){
        //Method not Implemented     
    } */
}