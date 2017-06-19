/**
* @description Class that will clone an Order and it's related Order Line Items when Create Credit button is clicked in Order's order line item related list
* @author Cloudsherpas
* @date 5-07-2014
*/
public with sharing class CreateCreditOrderCC extends OrderCloner{
    
    private set<Id> OrderLineItemIdSet;
    private string creditType;
/**
* @description The constuctor - initializes order line item ids to be passed on the parent class' init method.
* @author Cloudsherpas
* @date 5-07-2014
*/   
    public CreateCreditOrderCC(){
        try{
             
            Map<String, String> URLParamMap = ApexPages.currentPage().getParameters();
            if(URLParamMap.containsKey('Full')) {
                creditType = 'Full';
            }else if(URLParamMap.containsKey('TaxOnly')){
                creditType = 'Tax Only';
            }else if(URLParamMap.containsKey('Partial')){
                if(URLParamMap.get('Partial') == 'Amount'){
                    creditType = 'Partial - Amount';
                }
                if(URLParamMap.get('Partial') == 'Inventory'){
                    creditType = 'Partial - Inventory';
                }
            }
            if(URLParamMap.containsKey('size')){
                OrderLineItemIdSet = new set<Id>();
                for(Integer i = 0; i < Integer.valueOf(URLParamMap.get('size')); i++){
                    if(URLParamMap.containsKey('li'+i)){
                        OrderLineItemIdSet.add(URLParamMap.get('li'+i));
                    }
                }
                if(OrderLineItemIdSet.size() > 0){
                    //RenderCloneInEditMode = true;               
                    init(OrderLineItemIdSet, 'Credit');
                }
            }
        }catch(Exception e){
            addError('An error occured please contact your administrator.');
            addError('Error: ' + e);
            addError('Error: ' + e.getStackTraceString());
            showBackButton = false;
        }
    }
    
    @TestVisible override protected void handleUniqueProcessBefore(){
        Order_Line_Item__c[] unselectedLineItems = [SELECT Id FROM Order_Line_Item__c WHERE Id NOT IN :OrderLineItemIdSet AND Order__c = :ParentOrder.Id];
        if(unselectedLineItems.size() > 0){
                ParentOrder.CreditType__c = 'Partial';
        }
        
        ClonedOrder.CreditType__c = creditType;
        
        for(Order_Line_Item__c poli : ParentOrderLineItemlist){
            if(creditType == 'Partial - Amount' || creditType == 'Partial - Inventory' || creditType == 'Tax Only') {
                poli.Quantity2__c = 0;
                //poli.NetPrice__c = 0;
            }
        }
    } 
}