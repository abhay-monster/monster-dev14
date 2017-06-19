/*
** @author : Cloud Sherpas Inc.
** @date : 03/04/2014
** @description : Account Trigger for all CRUD events.
** @summary : There are 7 trigger events. 3 BEFORE Events (Insert, Update, Delete), 4 AFTER Events (Insert, Update, Delete, Undelete).
**            Best Practice for trigger development in SF dictates there should be only one trigger class created for each sObject. Using
**            this template provides single source for all sObject trigger events as well as control over the execution order.
*/

//note - Based on Trigger Template created by Mike Leach http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx

trigger AccountTrigger on Account (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    // declare handler
    AccountTriggerHandler handler;

    if(Trigger.isInsert && Trigger.isBefore){
        // before insert event


            handler = new AccountTriggerHandler(Trigger.isExecuting, Trigger.size);
            // call the on before update event handler
            handler.OnBeforeInsert(Trigger.new, Trigger.newMap);
            system.debug('==Trigger.new=='+Trigger.new);

          /*  if(Test.isRunningTest()){
                for(Account acc:Trigger.new){
                    acc.ShippingCity = 'Shipping City';
                    acc.ShippingPostalCode = '3344';
                    acc.ShippingCountry = null;
                    acc.ShippingStateCode='IN';
                    acc.ShippingCountryCode = 'US';
                    acc.ShippingState = null;
                    acc.ShippingStreet = '2298 PostingStreet';
                    acc.BillingStreet = null;
                    acc.BillingCity = null;
                    acc.BillingCountry = null;
                    acc.BillingState = null;
                    acc.BillingPostalCode = null;
                    acc.BillingCountryCode = null;

                }
            }*/

            system.debug('==Trigger.new=='+Trigger.new);

    }
    else if(Trigger.isInsert && Trigger.isAfter){
        // after insert event
        system.debug('==Trigger.new=='+Trigger.new);

            handler = new AccountTriggerHandler(Trigger.isExecuting, Trigger.size);

            // call the on before update event handler
            handler.OnAfterInsert(Trigger.new,trigger.newMap, trigger.oldMap);

    }
    else if(Trigger.isUpdate && Trigger.isBefore){
        // before update event

            system.debug('Starting Account before update');
            handler = new AccountTriggerHandler(Trigger.isExecuting, Trigger.size);

            // call the on before update event handler
            handler.OnBeforeUpdate(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
            
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        // after update event


            handler = new AccountTriggerHandler(Trigger.isExecuting, Trigger.size);

            // call the on after update event handler
           handler.OnAfterUpdate(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);

    }/*
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
    }   */
}