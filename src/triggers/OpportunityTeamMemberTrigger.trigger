/*
** @author : Cloud Sherpas Inc.
** @date : 03/31/2014
** @description : OpportunityTeamMember__c Trigger for all CRUD events. 
*/

trigger OpportunityTeamMemberTrigger on OpportunityTeamMember__c(after delete, after insert, after undelete, after update, before delete, before insert, before update) {
  // declare handler  
  OpportunityTeamMemberTriggerHandler handler;

/*
** author : Piyush Jain - Appirio
** date : 07/20/2015
** description :  The onBeforeInsert , onBeforeUpdate and isUnDelete Method Does nothing in Handler class hence commenting it
*/
        
if(Trigger.isInsert && Trigger.isBefore){
        // before insert event
        //try{
            //create new instance of AccountTriggerHandler
            //handler = new OpportunityTeamMemberTriggerHandler(Trigger.isExecuting, Trigger.size);
      
            //call the on before update event handler
            //handler.OnBeforeInsert(Trigger.new);
        //}
        /*catch(BaseApplicationException bae){
            for(Integer iLoop=0;iLoop<Trigger.size;iLoop++)
            Trigger.old[iLoop].addError(bae.UserFriendlyMessage);
        }*/     
}
    else if(Trigger.isInsert && Trigger.isAfter){
        // after insert event
        //try{
            //create new instance of AccountTriggerHandler
            handler = new OpportunityTeamMemberTriggerHandler(Trigger.isExecuting, Trigger.size);
      
            //call the on before update event handler
            handler.OnAfterInsert(Trigger.new);
        //}
        /*catch(BaseApplicationException bae){
            for(Integer iLoop=0;iLoop<Trigger.size;iLoop++)
            Trigger.old[iLoop].addError(bae.UserFriendlyMessage);
        }*/
}
    /*else if(Trigger.isUpdate && Trigger.isBefore){
      // SAMPLE IMPLEMENTATION
    // before update event
    
    }*/
    else if(Trigger.isUpdate && Trigger.isAfter){
        // after update event 
        //try{            
            handler = new OpportunityTeamMemberTriggerHandler(Trigger.isExecuting, Trigger.size);
                        
            // call the on after update event handler
            handler.OnAfterUpdate(trigger.old,trigger.new,trigger.oldMap, trigger.newMap);
        //}
        /*catch(BaseApplicationException bae){ 
           for(Integer iLoop=0;iLoop<Trigger.size;iLoop++){
            trigger.new[iLoop].addError(bae.UserFriendlyMessage);
           }
        }*/        
    }
    else if(Trigger.isDelete && Trigger.isBefore){
        //try{
            /*
            ** author : Piyush Jain - Appirio
            ** date : 07/20/2015
            ** description :  The onBeforeDelete Method is not calling the OnBeforeDelete method of Helper Class Rather is calling AfterUpdate method, hence a confusion , hence commenting.
            */
            //create new instance of AccountTriggerHandler
            //handler = new OpportunityTeamMemberTriggerHandler(Trigger.isExecuting, Trigger.size);
      
            //call the on before update event handler
            //handler.OnAfterUpdate(Trigger.old,Trigger.new,Trigger.newmap,Trigger.oldmap);
        //}
        /*catch(BaseApplicationException bae){
            for(Integer iLoop=0;iLoop<Trigger.size;iLoop++)
            Trigger.old[iLoop].addError(bae.UserFriendlyMessage);
        }*/
    }
    else if(Trigger.isDelete && Trigger.isAfter){ 
        //try{
            //create new instance of AccountTriggerHandler
            handler = new OpportunityTeamMemberTriggerHandler(Trigger.isExecuting, Trigger.size);
      
            //call the on before update event handler
            handler.OnAfterDelete(Trigger.old,Trigger.oldmap);
        //}
        /*catch(BaseApplicationException bae){
            for(Integer iLoop=0;iLoop<Trigger.size;iLoop++)
            Trigger.old[iLoop].addError(bae.UserFriendlyMessage);
        }*/
    }
    /*else if(Trigger.isUnDelete){ 
    // undelete event        
    }*/   
}