//------------------------------------------------------------------------------------------------------------
//  Name: XCodeTrigger 
//  Date: 04/09/2015
//  Author: Gaurav (Appirio Ind.)
//  Purpose: Trigger on Xcode__c Object.
//------------------------------------------------------------------------------------------------------------

trigger XCodeTrigger on Xcode__c (after insert) {
    XCodeTriggerHandler handler ;
    
    if(Trigger.isafter){
        handler  = new XCodeTriggerHandler ();
        if(Trigger.isInsert){
            handler  .afterInsert(trigger.new , trigger.newMap);
        }
    }

}