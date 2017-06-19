/*
** @author : Cloud Sherpas Inc.
** @date : 03/04/2014
** @description : Account Trigger for all CRUD events. 
*/

//note - Based on Trigger Template created by Mike Leach http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx

trigger CaseTrigger on Case (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    // declare handler  
    CaseTriggerHandler handler = new CaseTriggerHandler(Trigger.isExecuting, Trigger.size);
    if(Trigger.isInsert && Trigger.isBefore){
        // before insert event 
        handler.OnBeforeInsert(Trigger.new);      
    }
    else if(Trigger.isInsert && Trigger.isAfter){
        // after insert event
       // try{
            
            //handler = new CaseTriggerHandler(Trigger.isExecuting, Trigger.size);
                        
            // call the on before update event handler
            handler.OnAfterInsert(Trigger.new);
        /*}
        catch(BaseApplicationException bae){ 
           for(Integer iLoop=0;iLoop<Trigger.size;iLoop++)
           Trigger.new[iLoop].addError(bae.UserFriendlyMessage);
        }  */          
    }
    else if(Trigger.isUpdate && Trigger.isBefore){
        // before update event 
            handler.OnBeforeUpdate(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);                  
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        // after update event  
         //try{
            
            //handler = new CaseTriggerHandler(Trigger.isExecuting, Trigger.size);
                        
            // call the on after update event handler
                handler.OnAfterUpdate(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
        /*}
        catch(BaseApplicationException bae){ 
           for(Integer iLoop=0;iLoop<Trigger.size;iLoop++)
           Trigger.new[iLoop].addError(bae.UserFriendlyMessage);
        }*/
    }
    else if(Trigger.isDelete && Trigger.isBefore){
        // before delete event  
        // event not implemented
        
        // added per S--352424
        for  (Case c: trigger.old){
            if (c.Current_User_Profile__c == 'Data Steward' || c.Current_User_Profile__c == 'Order Management (EU)'){
                c.adderror('You do not have permission to delete Cases.');
            }
        }
        

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