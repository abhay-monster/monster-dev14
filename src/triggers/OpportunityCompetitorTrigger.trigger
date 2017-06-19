//------------------------------------------------------------------------------------------------------------
//  Name: OpportunityCompetitorTrigger
//  Date: 14/05/2015
//  Author: Gaurav (Appirio Ind.)
//  Purpose: Trigger for  OpportunityCompetitor__c Object.
//------------------------------------------------------------------------------------------------------------
trigger OpportunityCompetitorTrigger on OpportunityCompetitor__c (after insert , before insert) {

    //Variable which specifies the users/profiles for whom certain trigger code should not be executed
    Boolean executingTrigger = Personal_Settings__c.getInstance().trigger_opportunity__c;

    if (executingTrigger){
        OpportunityCompetitorTriggerHandler handler = new OpportunityCompetitorTriggerHandler (Trigger.isExecuting);
        if(Trigger.isAfter ){
        	if(Trigger.isInsert){
                // calling after insert trigger handler
                handler.afterInsert(Trigger.new);
        	}
        }
        if(Trigger.isBefore ){
        	if(Trigger.isInsert){
                // calling after insert trigger handler
                handler.beforeInsert(Trigger.new);
        	}
        }
    }
}