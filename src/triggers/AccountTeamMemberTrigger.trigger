/*
** @author : Cloud Sherpas Inc.
** @date : 03/04/2014
** @description : Account Trigger for all CRUD events. 
*/

//note - Based on Trigger Template created by Mike Leach http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx

trigger AccountTeamMemberTrigger on Account_Team_Member__c (before insert,after delete, after insert, after undelete, after update, before delete, before update) {
    // declare handler  
    AccountTeamMemberTriggerHandler handler;
          
    if(Trigger.isInsert && Trigger.isBefore){
        // before insert event 
        
            handler = new AccountTeamMemberTriggerHandler(Trigger.isExecuting, Trigger.size);
                        
            // call the on after update event handler
            handler.OnBeforeInsert(trigger.new);
        
    }
    else if(Trigger.isInsert && Trigger.isAfter){
        // after insert event
        
            
            handler = new AccountTeamMemberTriggerHandler(Trigger.isExecuting, Trigger.size);
                        
            // call the on after update event handler
            handler.OnAfterInsert(trigger.new);
       
    }
    else if(Trigger.isUpdate && Trigger.isBefore){
        // before update event
       
            
            handler = new AccountTeamMemberTriggerHandler(Trigger.isExecuting, Trigger.size);
                        
            // call the on after update event handler
            handler.OnBeforeUpdate(trigger.old,trigger.new,trigger.oldMap, trigger.newMap);
       
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        // after update event 
                   
            handler = new AccountTeamMemberTriggerHandler(Trigger.isExecuting, Trigger.size);
                        
            // call the on after update event handler
            handler.OnAfterUpdate(trigger.old,trigger.new,trigger.oldMap, trigger.newMap);
         
        
    }
    else if(Trigger.isDelete && Trigger.isBefore){
        // before delete event  
        
            
            handler = new AccountTeamMemberTriggerHandler(Trigger.isExecuting, Trigger.size);
                        
            // call the on after update event handler
            handler.OnBeforeDelete(trigger.old,trigger.oldMap);
       
    }
    else if(Trigger.isDelete && Trigger.isAfter){ 
        if(trigger.old != null){
            handler = new AccountTeamMemberTriggerHandler(Trigger.isExecuting, Trigger.size);
            handler.OnAfterDelete(trigger.old);
        }
        // event not implemented
    }
     
}