/*
** @author : Phuong Tran
** @date : 10/28/2015
** @description : Trigger for Performance_VFP_Detail__ to monitor system performance
*/
trigger PerformanceVFPDetailTrigger on Performance_VFP_Detail__c (before insert) {
         
    if(Trigger.isInsert && Trigger.isBefore){
            PerfVFPDetailTriggerHandler handler = new PerfVFPDetailTriggerHandler();       
            // call the on before update event handler
            handler.OnBeforeInsert(Trigger.new);     
    } // end if

} // end trigger