/*
** @author : Cloud Sherpas Inc.
** @date : 04/14/2014
** @description : OpportunityTeamMember__c Trigger for all CRUD events. 
*/

trigger StandardOpportunityTeamMemberTrigger on OpportunityTeamMember(after delete, after insert, after undelete, after update, before delete, before insert, before update) {
  // declare handler  
  OpportunityTeamMemberTriggerHandler handler;
        
    if(Trigger.isInsert && Trigger.isBefore){
        // before insert event
        try{
            
            //add code here
        }catch(BaseApplicationException bae){
            for(Integer iLoop=0;iLoop<Trigger.size;iLoop++)
            Trigger.old[iLoop].addError(bae.UserFriendlyMessage);
        }     
    }
    else if(Trigger.isInsert && Trigger.isAfter){
        // after insert event
        try{
            //create new instance of OpportunityTeamMemberTriggerHandler
            handler = new OpportunityTeamMemberTriggerHandler(Trigger.isExecuting, Trigger.size);
      
            //call the on before update event handler
            handler.OnAfterInsertStandardOppTeamMember(Trigger.new,Trigger.newmap);
        }catch(BaseApplicationException bae){
            for(Integer iLoop=0;iLoop<Trigger.size;iLoop++)
            Trigger.old[iLoop].addError(bae.UserFriendlyMessage);
        }
    }
    else if(Trigger.isUpdate && Trigger.isBefore){
      // SAMPLE IMPLEMENTATION
    // before update event
    
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        // after update event 
        try{            
            //create new instance of OpportunityTeamMemberTriggerHandler
            handler = new OpportunityTeamMemberTriggerHandler(Trigger.isExecuting, Trigger.size);
      
            //call the on before update event handler
            handler.OnAfterDeleteStandardOppTeamMember(Trigger.new,Trigger.newmap);
        }
        catch(BaseApplicationException bae){ 
           for(Integer iLoop=0;iLoop<Trigger.size;iLoop++){
            trigger.new[iLoop].addError(bae.UserFriendlyMessage);
           }
        }        
    }
    else if(Trigger.isDelete && Trigger.isBefore){
        try{
            //add code here
        }catch(BaseApplicationException bae){
            for(Integer iLoop=0;iLoop<Trigger.size;iLoop++)
            Trigger.old[iLoop].addError(bae.UserFriendlyMessage);
        }
    }
    else if(Trigger.isDelete && Trigger.isAfter){ 
        try{
            //create new instance of AccountTriggerHandler
            handler = new OpportunityTeamMemberTriggerHandler(Trigger.isExecuting, Trigger.size);
      
            //call the on before update event handler
            handler.OnAfterDeleteStandardOppTeamMember(Trigger.old,Trigger.oldmap);
        }catch(BaseApplicationException bae){
            for(Integer iLoop=0;iLoop<Trigger.size;iLoop++)
            Trigger.old[iLoop].addError(bae.UserFriendlyMessage);
        }
    }
    else if(Trigger.isUnDelete){ 
    // undelete event        
    }   
}