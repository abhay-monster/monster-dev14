/*
** @author : Cloud Sherpas Inc.
** @date : 03/27/2014
** @description : Related Partner Trigger for all CRUD events. 
*/

//note - Based on Trigger Template created by Mike Leach http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx

trigger RelatedPartnerTrigger on RelatedPartner__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    // declare handler  
    RelatedPartnerTriggerHandler handler;
          
    if(Trigger.isInsert && Trigger.isBefore){
        // before insert event 
        // event not implemented         
    }
    else if(Trigger.isInsert && Trigger.isAfter){
        // after insert event        
            
            handler = new RelatedPartnerTriggerHandler(Trigger.isExecuting, Trigger.size);
                        
            // call the on before update event handler
            handler.OnAfterInsert(trigger.new);
        
    }
    /*else if(Trigger.isUpdate && Trigger.isBefore){
        // before update event
        // event not implemented        
    }*/
    
    else if(Trigger.isUpdate && Trigger.isAfter){
            handler = new RelatedPartnerTriggerHandler(Trigger.isExecuting, Trigger.size);
                        
            // call the on after update event handler
            handler.OnAfterUpdate(trigger.new);
    }
    /*
    else if(Trigger.isDelete && Trigger.isBefore){
        // before delete event  
        // event not implemented      
    }*/
    
    else if(Trigger.isDelete && Trigger.isAfter){ 
        // after delete event 
        handler = new RelatedPartnerTriggerHandler(Trigger.isExecuting, Trigger.size);
                        
        // call the on before update event handler
        handler.OnAfterDelete(trigger.old, trigger.oldMap);
        //handler.OnAfterUpdate(trigger.old);
        
    }
    /*
    else if(Trigger.isUnDelete){ 
        // undelete event  
        // event not implemented      
    } */  
}