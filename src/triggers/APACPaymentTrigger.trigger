/**=====================================================================
* Appirio, Inc
* Trigger Name: APACPaymentTrigger 
* Description: Trigger for custom object APTS_APAC_Payment__c 
* Created Date: [08/08/2016]
* Created By: Gaurav Gupta (Appirio)
*
* Date Modified                Modified By                  Description of the update
=====================================================================*/

trigger APACPaymentTrigger on APTS_APAC_Payment__c (Before Insert , Before Update) {

    //condition to make Trigger active 
    if(TriggerState.isActive('APACPaymentTrigger')) {
        APACPaymentTriggerHandler handler = new APACPaymentTriggerHandler ();
        
        if(Trigger.isBefore && Trigger.isInsert){
            handler.beforeInsert(Trigger.new, null);
        }
        if(Trigger.isBefore && Trigger.isUpdate){
            handler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }

}