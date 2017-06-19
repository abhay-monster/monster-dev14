trigger OrderLineItemTrigger on Order_Line_Item__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
     // declare handler  
    OrderLineItemTriggerHandler handler  = new OrderLineItemTriggerHandler(Trigger.isExecuting, Trigger.size);
    //private static Integer runCount = 0;
          
    if(Trigger.isInsert && Trigger.isBefore){
        // before insert event         
            
        //handler = new OrderLineItemTriggerHandler(Trigger.isExecuting, Trigger.size);
                    
        // call the on before update event handler
        handler.OnBeforeInsert(Trigger.new);
        

}
    else if(Trigger.isInsert && Trigger.isAfter){
        // after insert event      
            
        //handler = new OrderLineItemTriggerHandler(Trigger.isExecuting, Trigger.size);
                    
        // call the on before update event handler
        handler.OnAfterInsert(Trigger.new, Trigger.newMap);
                  
    }
    else if(Trigger.isUpdate && Trigger.isBefore){
        // before update event
                   
        //handler = new OrderLineItemTriggerHandler(Trigger.isExecuting, Trigger.size);
                    
        // call the on before update event handler
        //if(runCount < 1){
            handler.OnBeforeUpdate(trigger.old, trigger.new, trigger.oldMap, trigger.newMap); 
            //Don't know who put this here but it's wrong!!!! call it in teh handler!!! handler.populateOwnerStartDate(trigger.new);           
        //}                         
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        // after update event         
            
       // handler = new OrderLineItemTriggerHandler(Trigger.isExecuting, Trigger.size);
                    
        // call the on after update event handler
       // if(runCount < 1)
            handler.OnAfterUpdate(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
        //runCount++;
        
    }
    
   
   else if(Trigger.isDelete && Trigger.isBefore){
        handler.OnBeforeDelete(trigger.old);
    }
    /*else if(Trigger.isDelete && Trigger.isAfter){ 
        // after delete event 
        // event not implemented
    }
    else if(Trigger.isUnDelete){ 
        // undelete event  
        // event not implemented      
    } */
}