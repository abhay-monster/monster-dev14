public with sharing class AdjustmentOrderCC extends OrderCloner{
     public AdjustmentOrderCC(){
        if(ApexPages.currentPage().getParameters().containsKey('id')){
            Id parentOrderId = ApexPages.currentPage().getParameters().get('id');
            init(parentOrderId, 'Adjustment');
        }
    }
    
    @testvisible override protected void handleUniqueProcessBefore(){
        try{
            if(ParentOrder != null){
                ParentOrder.OrderStatus__c = 'Open';
            }
            if(ParentOrderLineItemlist != null){
                for(Order_Line_Item__c oli : ParentOrderLineItemlist){
                    oli.Quantity2__c = 0;
                    oli.Quantity__c = 0;
                }
            }
        }catch(Exception e){
            addError('An error occurred please contact your administrator.');
        }
    } 
}