trigger OLISalesAdjustmentTrigger on Order_Line_Item_Sales_Adjustment__c (after insert, after update) { 
    
    // declare handler  
    OLISalesAdjustmentTriggerHandler handler  = new OLISalesAdjustmentTriggerHandler(Trigger.isExecuting, Trigger.size);
    //if(Trigger.isInsert && Trigger.isBefore){
      
            
          // handler.OnBeforeInsert(Trigger.new);
                         
    //}
    //else 
    if(Trigger.isInsert && Trigger.isAfter){
           handler.OnAfterInsert(Trigger.new, Trigger.newMap);
                
    }
   // else if(Trigger.isUpdate && Trigger.isBefore){
        // before update event
           
         //  handler.OnBeforeUpdate(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
                         
    //}
    else if(Trigger.isUpdate && Trigger.isAfter){
        // after update event  
            
            handler.OnAfterUpdate(trigger.new, trigger.newMap, trigger.oldMap);
    }
 
   // else if(Trigger.isDelete && Trigger.isAfter){ 
       
            //handler = new OLISalesAdjustmentTriggerHandler(Trigger.isExecuting, Trigger.size);
                        
            // call the on after update event handler
           
         //   handler.OnAfterDelete(trigger.old);
      
    //}
    
}