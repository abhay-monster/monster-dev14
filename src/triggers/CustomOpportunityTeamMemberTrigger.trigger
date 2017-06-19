/*
** @author : Cloud Sherpas Inc.
** @date : 03/31/2014
** @description : OpportunityTeamMember__c Trigger for all CRUD events. 
*/

trigger CustomOpportunityTeamMemberTrigger on OpportunityTeamMember__c(after delete, after insert, after undelete, after update, before delete, before insert, before update) {
  // declare handler  
  OpportunityTeamMemberTriggerHandler handler;
        
    if(Trigger.isInsert && Trigger.isBefore){
        // before insert event
        //create new instance of AccountTriggerHandler
        handler = new OpportunityTeamMemberTriggerHandler(Trigger.isExecuting, Trigger.size);
  
        //call the on before update event handler
        handler.OnBeforeInsert(Trigger.new);

    }
    else if(Trigger.isInsert && Trigger.isAfter){
        // after insert event
        //create new instance of AccountTriggerHandler
        handler = new OpportunityTeamMemberTriggerHandler(Trigger.isExecuting, Trigger.size);
  
        //call the on before update event handler
        handler.OnAfterInsert(Trigger.new);
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        // after update event          
        handler = new OpportunityTeamMemberTriggerHandler(Trigger.isExecuting, Trigger.size);
                    
        // call the on after update event handler
        handler.OnAfterUpdate(trigger.old,trigger.new,trigger.oldMap, trigger.newMap);    
    }
    else if(Trigger.isDelete && Trigger.isBefore){
        //create new instance of AccountTriggerHandler
        handler = new OpportunityTeamMemberTriggerHandler(Trigger.isExecuting, Trigger.size);
  
        //call the on before update event handler
        handler.OnBeforeDelete(Trigger.old,Trigger.oldmap);
    }
    else if(Trigger.isDelete && Trigger.isAfter){ 
        //create new instance of AccountTriggerHandler
        handler = new OpportunityTeamMemberTriggerHandler(Trigger.isExecuting, Trigger.size);
  
        //call the on before update event handler
        handler.OnAfterDelete(Trigger.old,Trigger.oldmap);
    }
   // else if(Trigger.isUnDelete){ 
    // undelete event        
   // }  
}