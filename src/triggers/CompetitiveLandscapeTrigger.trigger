/*
** @author : Cloud Sherpas Inc.
** @date : 04/03/2014
** @description : CompetitiveLandscape__c Trigger for all CRUD events. 
*/

//note - Based on Trigger Template created by Mike Leach http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx

trigger CompetitiveLandscapeTrigger on CompetitiveLandscape__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    // declare handler  
    CompetitiveLandscapeTriggerHandler handler;
          
    if(Trigger.isInsert && Trigger.isBefore){
        // before insert event 
        try{
            
            handler = new CompetitiveLandscapeTriggerHandler(Trigger.isExecuting, Trigger.size);
                        
            // call the on before update event handler
            handler.OnBeforeInsert(Trigger.new);
        }
        catch(BaseApplicationException bae){ 
           for(Integer iLoop=0;iLoop<Trigger.size;iLoop++)
           Trigger.new[iLoop].addError(bae.UserFriendlyMessage);
        }            
    }
    else if(Trigger.isInsert && Trigger.isAfter){
        // after insert event
        // event not implemented            
    }
    else if(Trigger.isUpdate && Trigger.isBefore){
        // before update event
        // event not implemented                    
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        // after update event  
        // event not implemented   
    }
    else if(Trigger.isDelete && Trigger.isBefore){
        // before delete event  
        // event not implemented 
    }
    else if(Trigger.isDelete && Trigger.isAfter){ 
        // after delete event 
        // event not implemented
    }
    else if(Trigger.isUnDelete){ 
        // undelete event  
        // event not implemented      
    }   
}