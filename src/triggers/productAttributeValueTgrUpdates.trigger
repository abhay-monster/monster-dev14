/*
  Apttus Inc.
  Venkata R Sabbella
  updated: 08/11
  Population of attribute values  
  udpated: 10/28
*/
  //test

trigger productAttributeValueTgrUpdates on Apttus_Config2__ProductAttributeValue__c (before insert, before update,after update) {
   if(trigger.isUpdate 
      && trigger.isAfter
      && !ProductAttributeValueHandler.pavHandlerMap.get('AfterUpdate'))
   { 
    //ProductAttributeValueHandler pavHandler=new ProductAttributeValueHandler();
    //list<Apttus_Config2__ProductAttributeValue__c> prodAttValList=pavHandler.copyFieldValuesFromLead(trigger.newmap);
    //update prodAttValList;
    ProductAttributeValueHandler.pavHandlerMap.put('AfterUpdate',true);
    
   }
   
   //if(trigger.isInsert || (trigger.isBefore && ))
   if(trigger.isBefore){
   List<Apttus_Config2__ProductAttributeValue__c> attributeList = new List<Apttus_Config2__ProductAttributeValue__c>();
  // system.debug('******* trigger.new: '+trigger.new);
   for(Apttus_Config2__ProductAttributeValue__c pav: trigger.new){
       if(trigger.isInsert || (trigger.isUpdate && pav.Posting_Locations__c != trigger.oldMap.get(pav.Id).Posting_Location__c)){
         //  system.debug('******* pav.Posting_Locations__c: '+pav.Posting_Locations__c);
           if(pav.Posting_Locations__c != null && pav.Posting_Locations__c != ''){
               attributeList.add(pav);
           }
       }
   }
 //  system.debug('******* attributeList: '+attributeList);
  // system.debug('******* attributeList.size(): '+attributeList.size());
   if(attributeList.size()>0){
       ProductAttributeValueHandler pavHandler=new ProductAttributeValueHandler();
       pavHandler.updateFields(attributeList);
   }
   
       If( trigger.isBefore && trigger.isUpdate)
       {
           ProductAttributeValueHandler pavHandler=new ProductAttributeValueHandler();
            pavHandler.RestoreTheCascadedValue(Trigger.New); 
       }
   //cascade attributes
  } 

}