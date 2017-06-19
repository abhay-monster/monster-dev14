/*
** @author : Cloud Sherpas Inc.
** @date : 03/04/2014
** @description : Apttus_QPConfig__ProposalProductAttributeValue__c Trigger for all CRUD events. 
** @summary : There are 7 trigger events. 3 BEFORE Events (Insert, Update, Delete), 4 AFTER Events (Insert, Update, Delete, Undelete).
**            Best Practice for trigger development in SF dictates there should be only one trigger class created for each sObject. Using 
**            this template provides single source for all sObject trigger events as well as control over the execution order. 
*/
trigger PropProdAttributeValueTrigger on Apttus_QPConfig__ProposalProductAttributeValue__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    PropProdAttributeValueTriggerHandler handler;
          
   /* if(Trigger.isInsert && Trigger.isBefore){
        // before insert event 
        try{
            
        }
        catch(BaseApplicationException bae){ 
           for(Integer iLoop=0;iLoop<Trigger.size;iLoop++)
           Trigger.new[iLoop].addError(bae.UserFriendlyMessage);
        }            
    }
    else */
    if(Trigger.isInsert && Trigger.isAfter){
        // after insert event
        
            
            handler = new PropProdAttributeValueTriggerHandler(Trigger.isExecuting, Trigger.size);
                        
            // call the on before update event handler
            handler.OnAfterInsert(Trigger.new);
               
    }
    else if(Trigger.isUpdate && Trigger.isBefore){
        // before update event        
            
            handler = new PropProdAttributeValueTriggerHandler(Trigger.isExecuting, Trigger.size);
                        
            // call the on before update event handler
            handler.OnBeforeUpdate(trigger.new, trigger.oldMap);
                        
    }
    //SBerron - Appirio - 3/02/17 - S-442900
    else if (Trigger.isUpdate && Trigger.isAfter) {

        handler = new PropProdAttributeValueTriggerHandler(Trigger.isExecuting, Trigger.size);

        handler.OnAfterUpdate(Trigger.new, Trigger.OldMap);
    }
    /*
    else if(Trigger.isUpdate && Trigger.isAfter){
        // after update event  
        try{
        // before delete event  
        // event not implemented 
        }
        catch(BaseApplicationException bae){ 
           for(Integer iLoop=0;iLoop<Trigger.size;iLoop++)
           Trigger.new[iLoop].addError(bae.UserFriendlyMessage);
        }  
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
    }*/    
}