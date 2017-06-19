/*
** @author : Cloud Sherpas Inc.
** @date : 04/23/2014
** @description : Sales_Quotas__c Trigger for all CRUD events. 
*/
trigger SalesQuotaTrigger on Sales_Quotas__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {

    // declare handler  
    SalesQuotaTriggerHandler handler ;
          
    if(Trigger.isInsert && Trigger.isBefore){        
        
        // create new instance of UserTriggerHandler
         handler = new SalesQuotaTriggerHandler(Trigger.isExecuting, Trigger.size);             
        // call the on before update event handler
         handler.onBeforeInsert(trigger.new);
              
    }
    
    /* Following code is not used anywhere So commenting it
    
    else if(Trigger.isInsert && Trigger.isAfter){
        // after insert event
    }
    else if(Trigger.isUpdate && Trigger.isBefore){
        // SAMPLE IMPLEMENTATION
        // before update event
        //try{
            // create new instance of AccountTriggerHandler
            // handler = new AccountTriggerHandler(Trigger.isExecuting, Trigger.size);
            
            // call the on before update event handler
            // handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap, Trigger.oldMap);
        //}
        //catch(BaseApplicationException bae){
        //   for(Integer iLoop=0;iLoop<Trigger.size;iLoop++)
        //    Trigger.old[iLoop].addError(bae.UserFriendlyMessage);
        //}
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
         // after update event      
    }
    else if(Trigger.isDelete && Trigger.isBefore){
        // before delete event        
    }
    else if(Trigger.isDelete && Trigger.isAfter){ 
        // after delete event        
    }
    else if(Trigger.isUnDelete){ 
        // undelete event        
    } */  
}