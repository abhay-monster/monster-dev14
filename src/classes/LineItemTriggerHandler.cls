public with sharing class LineItemTriggerHandler {

    public void beforeInsert(Apttus_Config2__LineItem__c[] newLineItems )
    {  
        populateAgencyCommision(newLineItems );    
    }
    
    private void populateAgencyCommision(Apttus_Config2__LineItem__c[] newLineItems){
            
            set<id> setConfigIds = new set<id>();
            for(Apttus_Config2__LineItem__c apttusConfigLineItem : newLineItems){
                setConfigIds .add(apttusConfigLineItem .Apttus_Config2__ConfigurationId__c);
            }
            
            Map<id, Apttus_Config2__ProductConfiguration__c> newLineItemsCOnfiguration = 
            new Map<id,Apttus_Config2__ProductConfiguration__c>([SELECT Apttus_QPConfig__Proposald__r.AgencyCommission__c  
                                                                                                           FROM Apttus_Config2__ProductConfiguration__c
                                                                                                           WHERE ID IN:setConfigIds ]);   
            
    

    
        for(Apttus_Config2__LineItem__c apttusConfigLineItem : newLineItems){
            if(newLineItemsCOnfiguration .containsKey(apttusConfigLineItem.Apttus_Config2__ConfigurationId__c) && newLineItemsCOnfiguration .get(apttusConfigLineItem.Apttus_Config2__ConfigurationId__c).Apttus_QPConfig__Proposald__r.AgencyCommission__c != Null)
                apttusConfigLineItem.AgencyCommission__c = newLineItemsCOnfiguration .get(apttusConfigLineItem.Apttus_Config2__ConfigurationId__c).Apttus_QPConfig__Proposald__r.AgencyCommission__c ;
        }
    
    }
    
    
}