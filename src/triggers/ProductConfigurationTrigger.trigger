/*
** @author : Cloud Sherpas Inc.
** @date : 09/18/2014
** @description : Apttus_Config2__ProductConfiguration__c Trigger for all CRUD events. 
*/

//note - Based on Trigger Template created by Mike Leach http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx

trigger ProductConfigurationTrigger on Apttus_Config2__ProductConfiguration__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
      // declare handler  
    ApttusProductConfigTriggerHandler handler;
          system.debug( '*** In trigger ProductConfigurationTrigger' );
    if(Trigger.isInsert && Trigger.isBefore){
        // before insert event 
      
        try{
            System.debug(' in trigger Before insert ProductConfigurationTrigger');
            //handler = new ApttusProductConfigTriggerHandler(Trigger.isExecuting, Trigger.size);
                        
            // call the on before update event handler
            //handler.OnBeforeInsert(trigger.new);
        }
        catch(BaseApplicationException bae){
           for(Integer iLoop=0;iLoop<Trigger.size;iLoop++) 
           Trigger.new[iLoop].addError(bae.UserFriendlyMessage);
        }
                    
    }
    else if(Trigger.isInsert && Trigger.isAfter){
        // after insert event
        try{
            
            //handler = new ApttusProductConfigTriggerHandler(Trigger.isExecuting, Trigger.size);
                     System.debug(' in trigger After insert ProductConfigurationTrigger');   
            // call the on before update event handler
            //handler.OnAfterInsert(Trigger.new, trigger.oldMap);
        }
        catch(BaseApplicationException bae){ 
           for(Integer iLoop=0;iLoop<Trigger.size;iLoop++)
           Trigger.new[iLoop].addError(bae.UserFriendlyMessage);
        }            
    }
    else if(Trigger.isUpdate && Trigger.isBefore){
        // before update event  
        // after insert event
        try{
            
            //handler = new ApttusProductConfigTriggerHandler(Trigger.isExecuting, Trigger.size);
                       System.debug(' in trigger before update ProductConfigurationTrigger'); 
            // call the on before update event handler
            //handler.OnBeforeUpdate(trigger.old, trigger.new, trigger.newMap, trigger.oldMap);
        }
        catch(BaseApplicationException bae){ 
           for(Integer iLoop=0;iLoop<Trigger.size;iLoop++)
           Trigger.new[iLoop].addError(bae.UserFriendlyMessage);
        }                      
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        // after update event  
        try{
            System.debug(' in trigger After update ProductConfigurationTrigger');
            handler = new ApttusProductConfigTriggerHandler(Trigger.isExecuting, Trigger.size);
                        
            // call the on before update event handler
            handler.OnAfterUpdate(Trigger.new, trigger.oldMap);
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
            System.debug(' in trigger Delete After ProductConfigurationTrigger');
           // handler = new ApttusProductConfigTriggerHandler(Trigger.isExecuting, Trigger.size);
                        
            // call the on before update event handler
            //handler.OnAfterDelete(Trigger.old);
        }
        catch(BaseApplicationException bae){ 
           for(Integer iLoop=0;iLoop<Trigger.size;iLoop++)
           Trigger.old[iLoop].addError(bae.UserFriendlyMessage);
        } 
    }
    else if(Trigger.isUnDelete){ 
        // undelete event  
        // event not implemented      
    } 
}