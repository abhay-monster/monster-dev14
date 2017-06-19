//------------------------------------------------------------------------------------------------------------
//  Name: LineItemTrigger 
//  Date: 04/09/2015
//  Author: Gaurav (Appirio Ind.)
//  Purpose: Trigger on Apttus_Config2__LineItem__c Object.
//------------------------------------------------------------------------------------------------------------

trigger LineItemTrigger on Apttus_Config2__LineItem__c(before insert) {
    LineItemTriggerHandler handler ;
    
    if(Trigger.isBefore){
        handler  = new LineItemTriggerHandler ();
        if(Trigger.isInsert){
            handler.beforeInsert(trigger.new);
        }
    }

}