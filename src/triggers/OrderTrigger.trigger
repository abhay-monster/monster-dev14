trigger OrderTrigger on Order__c (after delete, after insert, after undelete, 
after update, before delete, before update, before insert) { 
    
    // declare handler  
    OrderTriggerHandler handler  = new OrderTriggerHandler(Trigger.isExecuting, Trigger.size);
    if(Trigger.isInsert && Trigger.isBefore){
      
            
           //handler = new OrderTriggerHandler(Trigger.isExecuting, Trigger.size);
                        
            // call the on before update event handler
             handler.OnBeforeInsert(Trigger.new);
                         
    }
    else if(Trigger.isInsert && Trigger.isAfter){
        // after insert event
        
            //handler = new OrderTriggerHandler(Trigger.isExecuting, Trigger.size);
                        
            // call the on before update event handler
                handler.OnAfterInsert(Trigger.new, Trigger.newMap);
                
    }
    else if(Trigger.isUpdate && Trigger.isBefore){
        // before update event
           
            //handler = new OrderTriggerHandler(Trigger.isExecuting, Trigger.size);
                        
            // call the on after update event handler
            handler.OnBeforeUpdate(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
                         
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        // after update event  
            
            //handler = new OrderTriggerHandler(Trigger.isExecuting, Trigger.size);
                        
            // call the on after update event handler
            handler.OnAfterUpdate(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
    }
 
    else if(Trigger.isDelete && Trigger.isAfter){ 
       
            handler = new OrderTriggerHandler(Trigger.isExecuting, Trigger.size);
                        
            // call the on after update event handler
           
            handler.OnAfterDelete(trigger.old);
      
    }
   
}