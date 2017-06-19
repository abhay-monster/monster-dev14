/*
** @author : Cloud Sherpas Inc.
** @date : 03/04/2014
** @description : Credit Request Line Item Trigger for all CRUD events. 
** @summary : There are 7 trigger events. 3 BEFORE Events (Insert, Update, Delete), 4 AFTER Events (Insert, Update, Delete, Undelete).
**            Best Practice for trigger development in SF dictates there should be only one trigger class created for each sObject. Using 
**            this template provides single source for all sObject trigger events as well as control over the execution order. 
*/
trigger CreditRequestLineItemTrigger on CreditRequestLineItem__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    // declare handler  
    CreditRequestLineItemTriggerHandler handler;
          
    if(Trigger.isInsert && Trigger.isBefore){
        // before insert event 
        handler = new CreditRequestLineItemTriggerHandler(Trigger.isExecuting, Trigger.size);
        // call the on before update event handler
        handler.OnBeforeInsert(Trigger.new);        
    }
    /*else if(Trigger.isInsert && Trigger.isAfter){
        // after insert event
        handler = new CreditRequestLineItemTriggerHandler(Trigger.isExecuting, Trigger.size);        
    }*/
    /*else if(Trigger.isUpdate && Trigger.isBefore){
        // before update event
        handler = new CreditRequestLineItemTriggerHandler(Trigger.isExecuting, Trigger.size);
        // call the on before update event handler
        handler.OnBeforeInsert(Trigger.new);               
    }*/
 /*   else if(Trigger.isUpdate && Trigger.isAfter){
        // before delete event  
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
    } */
}