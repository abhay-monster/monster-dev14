public with sharing class ForecastQuotaTriggerHandler{


 public void OnBeforeInsert(List<Forecast_Quota__c > newForecastQuotas)
  {
       setOwnerToSalesRep(newForecastQuotas);
  }


 public void OnBeforeUpdate(List<Forecast_Quota__c > newForecastQuotas 
                             , Map<id ,Forecast_Quota__c > newForecastQuotasMap
                             , Map<id ,Forecast_Quota__c > oldForecastQuotasMap)
  {
      list<Forecast_Quota__c > lstForecastQuotasToUpdate = new list<Forecast_Quota__c >();
      for(Forecast_Quota__c fQ :newForecastQuotas  ){
          if(newForecastQuotasMap.get(fQ.id).Sales_Rep__c != oldForecastQuotasMap.get(fQ.id).Sales_Rep__c ){
              lstForecastQuotasToUpdate.add(fQ);
          }
      }
      
      if(lstForecastQuotasToUpdate.size()>0)
          setOwnerToSalesRep(lstForecastQuotasToUpdate );
  
  }


 private void setOwnerToSalesRep(List<Forecast_Quota__c > newForecastQuotas ){
    for(Forecast_Quota__c fQ : newForecastQuotas )  {
        fQ.OwnerId = fQ.Sales_Rep__c;
    }                           
 }


}