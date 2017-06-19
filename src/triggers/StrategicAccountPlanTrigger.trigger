/*
** @author : Cloud Sherpas Inc.
** @date : 09/13/2014
** @description : Task Trigger for all CRUD events. 
*/

//note - Based on Trigger Template created by Mike Leach http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx

trigger StrategicAccountPlanTrigger on Strategic_Account_Plan__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
	StrategicAccountPlanTriggerHandler handler = new StrategicAccountPlanTriggerHandler(Trigger.isExecuting, Trigger.size);

	if(Trigger.isInsert && Trigger.isBefore){
        
            // call the on before insert event handler
            handler.OnBeforeInsert(trigger.new);
               
    }
    else if(Trigger.isInsert && Trigger.isAfter){

                        
            // call the on after inser event handler
            handler.OnAfterInsert(trigger.newMap);
 
    }
    
    else if(Trigger.isUpdate && Trigger.isBefore){ 
    	// before update event  
        handler.OnBeforeUpdate(trigger.new);
    } 
    else if(Trigger.isUpdate && Trigger.isAfter){

            // call the on before update event handler
            handler.OnAfterUpdate(trigger.newMap);
  
    }
    
  //  else if(Trigger.isDelete && Trigger.isBefore){
        //Method not Implemented   
//    }
 //   else if(Trigger.isDelete && Trigger.isAfter){
        //Method not Implemented    
//    }
    
 //   else if(Trigger.isUnDelete){
        //Method not Implemented     
 //   } 
}