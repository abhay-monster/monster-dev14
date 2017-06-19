/*
** @author : Cloud Sherpas Inc.
** @date : 06/11/2014
** @description : <Line_Item_Attribute__c> Trigger for all CRUD events.
*/
trigger LineItemAttributesTrigger on Line_Item_Attribute__c (before insert, before update, after insert, after Update) {
    LineItemAttributesTriggerHandler handler;

    /* This block has no code So commented it
    if(Trigger.isInsert && Trigger.isBefore){
        // before insert event
    }
    else */

    if(Trigger.isInsert && Trigger.isBefore){
             // create new instance of LineItemAttributesTriggerHandler
            handler = new LineItemAttributesTriggerHandler(Trigger.isExecuting, Trigger.size);
            // call the on before update event handler
            handler.OnBeforeInsert(Trigger.new);
    }
    else if(Trigger.isInsert && Trigger.isAfter){
             // create new instance of LineItemAttributesTriggerHandler
            handler = new LineItemAttributesTriggerHandler(Trigger.isExecuting, Trigger.size);
            // call the on before update event handler
            handler.OnAfterInsert(Trigger.new);
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        // after update event
            // create new instance of LineItemAttributesTriggerHandler
            handler = new LineItemAttributesTriggerHandler(Trigger.isExecuting, Trigger.size);

            // call the on before update event handler
            handler.OnAfterUpdate(Trigger.new);
    }
}