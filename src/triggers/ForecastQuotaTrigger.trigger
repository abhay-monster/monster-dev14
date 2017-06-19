trigger ForecastQuotaTrigger on Forecast_Quota__c (before Insert , before Update) {
 ForecastQuotaTriggerHandler handler = new ForecastQuotaTriggerHandler();
 if(trigger.isBefore){
     if(Trigger.isInsert){
         handler.OnBeforeInsert(trigger.new );
     }
     
     if(Trigger.isUpdate){
         handler.OnBeforeUpdate(trigger.new , trigger.newMap , trigger.OldMap);
     }
     
 }

}