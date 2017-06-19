/*
** @author : Cloud Sherpas Inc.
** @date : 03/04/2014
** @description : Contact Trigger for all CRUD events. 
*/

//note - Based on Trigger Template created by Mike Leach http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx


trigger ContactTrigger on Contact (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    // declare handler  
    ContactTriggerHandler handler;
          
    if(Trigger.isInsert && Trigger.isBefore){
        // before insert event 
        try{
            
            handler = new ContactTriggerHandler(Trigger.isExecuting, Trigger.size);
                        
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
        try{
            
            handler = new ContactTriggerHandler(Trigger.isExecuting, Trigger.size);
                        
            // call the on before update event handler
            handler.OnAfterInsert(Trigger.new,Trigger.newMap);
        }
        catch(BaseApplicationException bae){ 
           for(Integer iLoop=0;iLoop<Trigger.size;iLoop++)
           Trigger.new[iLoop].addError(bae.UserFriendlyMessage);
        }           
    }
    else if(Trigger.isUpdate && Trigger.isBefore){
        // before update event
        
        try{
        handler = new ContactTriggerHandler(Trigger.isExecuting, Trigger.size);      
        
        // call the on before update event handler
        handler.OnBeforeUpdate(Trigger.old,Trigger.new,Trigger.oldmap,Trigger.newmap);   
        
        }
        catch(BaseApplicationException bae){ 
           for(Integer iLoop=0;iLoop<Trigger.size;iLoop++)
           Trigger.new[iLoop].addError(bae.UserFriendlyMessage);
        }         
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        // after update event 
        try{ 
        handler = new ContactTriggerHandler(Trigger.isExecuting, Trigger.size);      
        
        // call the on before update event handler
        handler.OnAfterUpdate(Trigger.old,Trigger.new,Trigger.oldmap,Trigger.newmap);   
        
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
        try{
            
            handler = new ContactTriggerHandler(Trigger.isExecuting, Trigger.size);
                        
            // call the on before update event handler
            handler.OnAfterDelete(trigger.old, trigger.oldMap);
        }
        catch(BaseApplicationException bae){ 
           for(Integer iLoop=0;iLoop<Trigger.size;iLoop++)
           Trigger.old[iLoop].addError(bae.UserFriendlyMessage);
        }
    }
    else if(Trigger.isUnDelete){ 
        // undelete event  
           
    }
}