/*
** @author : Cloud Sherpas Inc.
** @date : 05/20/2014
** @description : User Trigger for all CRUD events. 
*/
trigger UserTrigger on User (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
    // declare handler  
    UserTriggerHandler handler ;
          
    if(Trigger.isInsert && Trigger.isBefore){
        // before insert event      
    }
    else if(Trigger.isInsert && Trigger.isAfter){ 
        // after insert event
        try{
            
            // create new instance of UserTriggerHandler
            handler = new UserTriggerHandler(Trigger.isExecuting, Trigger.size); 
            
            // call the on After Insert event handler
            handler.OnAfterInsert(trigger.new, trigger.newMap);
        }
        catch(BaseApplicationException bae){
           for(Integer iLoop=0;iLoop<Trigger.size;iLoop++)
            trigger.new[iLoop].addError(bae.UserFriendlyMessage);
        }
        
    }
    else if(Trigger.isUpdate && Trigger.isBefore){      
        // before update event
        try{
            // create new instance of UserTriggerHandler
             handler = new UserTriggerHandler(Trigger.isExecuting, Trigger.size); 
            
            // call the on before update event handler
             handler.OnBeforeUpdate(Trigger.old, trigger.new, Trigger.newMap, Trigger.oldMap);
             
        }catch(BaseApplicationException bae){
            for(Integer iLoop=0;iLoop<Trigger.size;iLoop++)
            Trigger.new[iLoop].addError(bae.UserFriendlyMessage);
        }
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
         
        try{
            // create new instance of UserTriggerHandler
             handler = new UserTriggerHandler(Trigger.isExecuting, Trigger.size); 
            
            // call the on before update event handler
             handler.OnAfterUpdate(Trigger.old, trigger.new, Trigger.newMap, Trigger.oldMap);
             
        }catch(BaseApplicationException bae){
            for(Integer iLoop=0;iLoop<Trigger.size;iLoop++)
            Trigger.new[iLoop].addError(bae.UserFriendlyMessage);
        }
    }
    else if(Trigger.isDelete && Trigger.isBefore){
        // before delete event        
    }
    else if(Trigger.isDelete && Trigger.isAfter){ 
        // after delete event        
    }
    else if(Trigger.isUnDelete){ 
        // undelete event        
    }  
}