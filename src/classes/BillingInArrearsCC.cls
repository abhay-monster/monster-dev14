/**
* @description Class that will clone an Order and it's related Order Line Items and the Line Attributes of Orders Line Item
* @author Cloudsherpas
* @date 4-30-2014
*/
public with sharing class BillingInArrearsCC extends OrderCloner {
/**
* @description The constuctor
* @author Cloudsherpas
* @date 4-30-2014
*/     
    public BillingInArrearsCC(){
        if(ApexPages.currentPage().getParameters().containsKey('id')){
            Id parentOrderId = ApexPages.currentPage().getParameters().get('id');
            init(parentOrderId, 'Billing In Arrears');
        }
    }
}