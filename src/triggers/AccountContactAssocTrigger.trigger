/*
** @author : Cloud Sherpas Inc.
** @date : 07/18/2014
** @description : AccountContactAssociation__c Trigger for all CRUD events. 
** @summary : There are 7 trigger events. 3 BEFORE Events (Insert, Update, Delete), 4 AFTER Events (Insert, Update, Delete, Undelete).
**            Best Practice for trigger development in SF dictates there should be only one trigger class created for each sObject. Using 
**            this template provides single source for all sObject trigger events as well as control over the execution order. 
*/
trigger AccountContactAssocTrigger on AccountContactAssociation__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    AccountContactAssocTriggerHandler handler;
          
    if(Trigger.isInsert && Trigger.isBefore){
        // before insert event 
        try{
            
            handler = new AccountContactAssocTriggerHandler(Trigger.isExecuting, Trigger.size);
            // call the on before update event handler
            handler.OnBeforeInsert(Trigger.new);
            
        }
        catch(BaseApplicationException bae){ 
           for(Integer iLoop=0;iLoop<Trigger.size;iLoop++)
           Trigger.new[iLoop].addError(bae.UserFriendlyMessage);
        }            
    }
    else if(Trigger.isInsert && Trigger.isAfter){
        // after insert event  
        // event not implemented         
    }
    else if(Trigger.isUpdate && Trigger.isBefore){
        // before update event
        try{
            
            handler = new AccountContactAssocTriggerHandler(Trigger.isExecuting, Trigger.size);
                        
            // call the on before update event handler
            handler.OnBeforeUpdate(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
        }
        catch(BaseApplicationException bae){ 
           for(Integer iLoop=0;iLoop<Trigger.size;iLoop++)
           Trigger.new[iLoop].addError(bae.UserFriendlyMessage);
        }                   
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        // after Update event  
        // event not implemented
    }
    else if(Trigger.isDelete && Trigger.isBefore){
        // before delete event  
        // event not implemented 
    }
    else if(Trigger.isDelete && Trigger.isAfter){ 
        // after delete event 
        // event not implemented
    }
    else if(Trigger.isUnDelete){ 
        // undelete event  
        // event not implemented      
    }   
}