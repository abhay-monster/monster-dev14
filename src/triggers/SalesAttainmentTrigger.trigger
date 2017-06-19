/*
** @author : Cloud Sherpas Inc.
** @date : 04/28/2014
** @description : Sales Attinment Trigger for all CRUD events. 
*/
trigger SalesAttainmentTrigger on Sales_Attainment__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    // declare handler  
    SalesAttainmentTriggerHandler handler;
          
    if(Trigger.isInsert && Trigger.isBefore){
        // before insert event 
            handler = new SalesAttainmentTriggerHandler(Trigger.isExecuting, Trigger.size);                        
            // call the on before update event handler
            handler.OnBeforeInsert(Trigger.new);
                  
    }
    
    // following code is not used anywhere So commenting it
    /*
    else if(Trigger.isInsert && Trigger.isAfter){
        // after insert event  
        // event not implemented               
    }
    else if(Trigger.isUpdate && Trigger.isBefore){
        // before update event                    
        // event not implemented 
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        // after update event 
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