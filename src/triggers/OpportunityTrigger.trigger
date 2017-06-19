/*
** @author : Cloud Sherpas Inc.
** @date : 03/04/2014
** @description : Opportunity Trigger for all CRUD events.
*/

//note - Based on Trigger Template created by Mike Leach http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx

trigger OpportunityTrigger on Opportunity (after delete, after insert, after undelete, after update, before delete, before insert, before update) {

    //Variable which specifies the users/profiles for whom certain trigger code should not be executed
    Boolean executingTrigger = Personal_Settings__c.getInstance().trigger_opportunity__c;

    if (executingTrigger){
        // declare handler
        OpportunityTriggerHandler handler = new OpportunityTriggerHandler(Trigger.isExecuting, Trigger.size);
        if(Trigger.isInsert && Trigger.isBefore){
            // before insert event
            //try{

                // call the on before update event handler
                handler.OnBeforeInsert(Trigger.new);
            //}
            /*catch(BaseApplicationException bae){
               for(Integer iLoop=0;iLoop<Trigger.size;iLoop++)
               Trigger.new[iLoop].addError(bae.UserFriendlyMessage);
            }*/
        }
        else if(Trigger.isInsert && Trigger.isAfter){
            // after insert event
            //try{

                //handler = new OpportunityTriggerHandler(Trigger.isExecuting, Trigger.size);

                // call the on before update event handler
                handler.OnAfterInsert(Trigger.new);
            //}
            /*catch(BaseApplicationException bae){
               for(Integer iLoop=0;iLoop<Trigger.size;iLoop++)
               Trigger.new[iLoop].addError(bae.UserFriendlyMessage);
            }*/
        }
        else if(Trigger.isUpdate && Trigger.isBefore){
            // before update event
             //try{

               // handler = new OpportunityTriggerHandler(Trigger.isExecuting, Trigger.size);

                // call the on before update event handler
                handler.OnBeforeUpdate(trigger.old, trigger.new, trigger.newMap, trigger.oldMap);
            //}
            /*catch(BaseApplicationException bae){
               for(Integer iLoop=0;iLoop<Trigger.size;iLoop++)
               Trigger.new[iLoop].addError(bae.UserFriendlyMessage);
            }*/
        }
        else if(Trigger.isUpdate && Trigger.isAfter){
            // after update event
            //try{

                //handler = new OpportunityTriggerHandler(Trigger.isExecuting, Trigger.size);

                // call the on before update event handler
                handler.OnAfterUpdate(trigger.old, trigger.new, trigger.newMap, trigger.oldMap);
            //}
            /*catch(BaseApplicationException bae){
               for(Integer iLoop=0;iLoop<Trigger.size;iLoop++)
               Trigger.new[iLoop].addError(bae.UserFriendlyMessage);
            }*/
        }


        else if(Trigger.isDelete && Trigger.isBefore){
            //try{

                //handler = new OpportunityTriggerHandler(Trigger.isExecuting, Trigger.size);
                handler.OnBeforeDelete(trigger.old);
            //}
            /*catch(BaseApplicationException bae){
               for(Integer iLoop=0;iLoop<Trigger.size;iLoop++)
               Trigger.new[iLoop].addError(bae.UserFriendlyMessage);
            }*/

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
}