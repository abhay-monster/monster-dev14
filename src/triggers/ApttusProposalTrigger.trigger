/*
** @author : Cloud Sherpas Inc.
** @date : 04/09/2014
** @description : Apttus_Proposal__Proposal__c Trigger for all CRUD events. 
*/

//note - Based on Trigger Template created by Mike Leach http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx

trigger ApttusProposalTrigger on Apttus_Proposal__Proposal__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) { 
      // declare handler  
    ApttusProposalTriggerHandler handler;
          
    if(Trigger.isInsert && Trigger.isBefore){
        // before insert event 
          
        try{
            
            handler = new ApttusProposalTriggerHandler(Trigger.isExecuting, Trigger.size);
                        system.debug('OnBeforeInsert');
            // call the on before update event handler
            handler.OnBeforeInsert(trigger.new);
        }
        catch(BaseApplicationException bae){ 
           for(Integer iLoop=0;iLoop<Trigger.size;iLoop++) 
           Trigger.new[iLoop].addError(bae.UserFriendlyMessage);
        }
                    
    }
    else if(Trigger.isInsert && Trigger.isAfter){
        // after insert event 
        try{
            
            handler = new ApttusProposalTriggerHandler(Trigger.isExecuting, Trigger.size);
                        
            // call the on before update event handler
            handler.OnAfterInsert(Trigger.new, trigger.oldMap,trigger.newMap);
        }
        catch(BaseApplicationException bae){ 
           for(Integer iLoop=0;iLoop<Trigger.size;iLoop++)
           Trigger.new[iLoop].addError(bae.UserFriendlyMessage);
        }            
    }
    else if(Trigger.isUpdate && Trigger.isBefore){
        // before update event  
        // after insert event
        try{
            
            handler = new ApttusProposalTriggerHandler(Trigger.isExecuting, Trigger.size);
                        
            // call the on before update event handler
            handler.OnBeforeUpdate(trigger.old, trigger.new, trigger.newMap, trigger.oldMap);
        }
        catch(BaseApplicationException bae){ 
           for(Integer iLoop=0;iLoop<Trigger.size;iLoop++)
           Trigger.new[iLoop].addError(bae.UserFriendlyMessage);
        }                      
    }
    //IsTriggerForCloneProposal condition added To Prevent 101 Soql Error,
    else if(Trigger.isUpdate && Trigger.isAfter && ApttusProposalTriggerHandler.IsTriggerForCloneProposal == false){ 
        //
        // after update event  
        try{
            
            handler = new ApttusProposalTriggerHandler(Trigger.isExecuting, Trigger.size);
                        
            // call the on before update event handler
            handler.OnAfterUpdate(Trigger.new, trigger.oldMap,trigger.newMap);
        }
        catch(BaseApplicationException bae){ 
           for(Integer iLoop=0;iLoop<Trigger.size;iLoop++)
           Trigger.new[iLoop].addError(bae.UserFriendlyMessage);
        }
    }
    else if(Trigger.isDelete && Trigger.isBefore){
        // before delete event  
        // event not implemented 
    }
    else if(Trigger.isDelete && Trigger.isAfter){ 
        // after delete event 
                try{
            
            handler = new ApttusProposalTriggerHandler(Trigger.isExecuting, Trigger.size);
                        
            // call the on before update event handler
            handler.OnAfterDelete(Trigger.old);
        }
        catch(BaseApplicationException bae){ 
           for(Integer iLoop=0;iLoop<Trigger.size;iLoop++)
           Trigger.old[iLoop].addError(bae.UserFriendlyMessage);
        } 
    }
    else if(Trigger.isUnDelete){ 
        // undelete event  
        // event not implemented      
    } 
}