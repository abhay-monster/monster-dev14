/*
** @author : Cloud Sherpas Inc.
** @date : 12/11/2014
** @description : Order_Comment__c Trigger for all CRUD events. 
*/
trigger OrderCommentTrigger on Order_Comment__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    // declare handler  
    OrderCommentTriggerHandler handler;

    if(Trigger.isInsert && Trigger.isBefore){
        // before insert event 
        // event not implemented           
    }
    else if(Trigger.isInsert && Trigger.isAfter){
        // after insert event 
        // event not implemented
        handler = new OrderCommentTriggerHandler(Trigger.isExecuting, Trigger.size);
                        
        // call the on after update event handler
        handler.OnAfterInsert(Trigger.new);
    }
    else if(Trigger.isUpdate && Trigger.isBefore){
        // before update event 
        // event not implemented
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        // after update event 
        // event not implemented
        handler = new OrderCommentTriggerHandler(Trigger.isExecuting, Trigger.size);
                        
        // call the on after update event handler
        handler.OnAfterUpdate(Trigger.new, Trigger.oldMap);
    }
    /* Following code is not used So we Commenting it */
    /*
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