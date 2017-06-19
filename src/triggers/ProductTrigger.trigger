/*
** @author : Cloud Sherpas Inc.
** @date : 11/18/2014
** @description : Product2 Trigger for all CRUD events. 
*/

//note - Based on Trigger Template created by Mike Leach http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx

trigger ProductTrigger on Product2 (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    
    ApttusProductTriggerHandler handler;
          system.debug( '*** In trigger ProductTrigger' );
    if(Trigger.isInsert && Trigger.isBefore){
      
        
            System.debug(' in trigger Before insert ProductTrigger');
            handler = new ApttusProductTriggerHandler(Trigger.isExecuting, Trigger.size);
                        
            // call the on before update event handler
            handler.OnBeforeInsert(trigger.new);
        
                    
    }
    else if(Trigger.isInsert && Trigger.isAfter){
        // after insert event
        
            
            handler = new ApttusProductTriggerHandler(Trigger.isExecuting, Trigger.size);
            System.debug(' in trigger After insert ProductTrigger');   
            // call the on before update event handler
            handler.OnAfterInsert(Trigger.new, trigger.oldMap);
                   
    }
    else if(Trigger.isUpdate && Trigger.isBefore){
        // before update event  
        // after insert event
        
            
            handler = new ApttusProductTriggerHandler(Trigger.isExecuting, Trigger.size);
            System.debug(' in trigger before update ProductTrigger'); 
            // call the on before update event handler
            handler.OnBeforeUpdate(trigger.old, trigger.new, trigger.newMap, trigger.oldMap);
                             
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        // after update event  
        
            System.debug(' in trigger After update ProductTrigger');
           handler = new ApttusProductTriggerHandler(Trigger.isExecuting, Trigger.size);
                        
            // call the on before update event handler
            handler.OnAfterUpdate(Trigger.new, trigger.oldMap);
        
    }/*
    else if(Trigger.isDelete && Trigger.isBefore){
        // before delete event  
        // event not implemented 
    }
    else if(Trigger.isDelete && Trigger.isAfter){ 
        // after delete event 
                
            System.debug(' in trigger Delete After ProductTrigger');
           handler = new ApttusProductTriggerHandler(Trigger.isExecuting, Trigger.size);
                        
            // call the on before update event handler
            handler.OnAfterDelete(Trigger.old);
        
    }
    else if(Trigger.isUnDelete){ 
        // undelete event  
        // event not implemented      
    }*/
}