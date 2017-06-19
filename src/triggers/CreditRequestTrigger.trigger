/*
** @author : Cloud Sherpas Inc.
** @date : 06/11/2014
** @description : <CreditRequest__c> Trigger for all CRUD events. 
*/
trigger CreditRequestTrigger on Credit_Request__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    CreditRequestTriggerHandler handler;
    if(Trigger.isInsert && Trigger.isBefore){
        
            // create new instance of CreditRequestTriggerHandler
            handler = new CreditRequestTriggerHandler(Trigger.isExecuting, Trigger.size);
            
            // call the on before update event handler
            handler.OnbeforeInsert(trigger.new);
        
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        
            // create new instance of CreditRequestTriggerHandler
            handler = new CreditRequestTriggerHandler(Trigger.isExecuting, Trigger.size);
            
            // call the on before update event handler
            handler.OnAfterUpdate(Trigger.new, Trigger.newMap, trigger.oldMap);
        
    }
   /* else if(Trigger.isInsert && Trigger.isAfter){
       
            // create new instance of CreditRequestTriggerHandler
            handler = new CreditRequestTriggerHandler(Trigger.isExecuting, Trigger.size);
            
            // call the on before update event handler
            handler.OnAfterInsert(Trigger.new, Trigger.newMap);
        
    }
    /*else if(Trigger.isUpdate && Trigger.isBefore){
        // before update event       
    }
    else if(Trigger.isDelete && Trigger.isBefore){
        // before delete event        
    }
    else if(Trigger.isDelete && Trigger.isAfter){ 
        // after delete event        
    }
    else if(Trigger.isUnDelete){ 
        // undelete event        
    } */

}