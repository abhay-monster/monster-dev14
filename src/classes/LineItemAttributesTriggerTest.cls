/*
@author : CloudSherpas
@description : Test the CreditRequestTriggerTest
@date : 06/18/2014
*/
@isTest
private class LineItemAttributesTriggerTest{
    /*
    @author : CloudSherpas
    @description : Test the UpdateRequest method
    @date : 06/18/2014
    */
    static testMethod void testOnInsert(){

        List<Account> accountList = new List<Account>();
        Account usedAccount = TestDataSetupUtility.createTestAccountWithShipping('Test Account');
        usedAccount.Phone = '20011111';
        accountList.add(usedAccount);
        insert accountList;
        
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opportunity', accountList[0].Id);
        oppList.add(opp);
        insert oppList;

        List<Apttus_Proposal__Proposal__c> proList = new List<Apttus_Proposal__Proposal__c>();
        Apttus_Proposal__Proposal__c pro = TestDataSetupUtility.createProposal('Test Proposal1', accountList[0].Id, oppList[0].Id, 'Accepted Online', false);
        proList.add(pro);
        insert proList;

        List<Apttus_Proposal__Proposal_Line_Item__c> proLineItemList = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        Apttus_Proposal__Proposal_Line_Item__c proLineItem = TestDataSetupUtility.createProposalLineItem(proList[0].Id);
        proLineItemList.add(proLineItem);
        insert proLineItemList;
        
        Contact con = TestDataSetupUtility.createTestContact(AccountList[0].Id, 'confirst1', 'conlast1', 'con1@email.com');
        insert con;
        
        Test.starttest();

            List<Order__c> orderList = new List<Order__c>();
            Order__c ord = TestDataSetupUtility.createOrder(AccountList[0].Id, con.Id);
            orderList.add(ord);
            ord.BillingAccount__c = AccountList[0].Id;
            ord.BillingContact__c = con.id;
            ord.Posting_Contact__c = con.id;
            insert orderList;   
            
            List<Order_Line_Item__c> orderLineList = new List<Order_Line_Item__c>();
            Order_Line_Item__c ordLine = TestDataSetupUtility.createOrderLineItem(orderList[0].Id);
            orderLineList.add(ordLine);
            insert orderLineList;
            
           /* List<Order_Line_Item__c> checkOrderLine = [SELECT PostingLocation__c FROM Order_Line_Item__c Where Id =: orderLineList[0].Id];
            system.assertEquals('France', checkOrderLine[0].PostingLocation__c);
            
            List<Line_Item_Attribute__c> lineItemList = new List<Line_Item_Attribute__c>();
            Line_Item_Attribute__c lineItem = TestDataSetupUtility.createLineItemAttribute(orderLineList[0].Id, proLineItemList[0].Id);
            lineItem.Posting_location__c = 'UK';
            lineItemList.add(lineItem);
            insert lineItemList;

            List<Order_Line_Item__c> checkOrderLineFinal = [SELECT PostingLocation__c FROM Order_Line_Item__c Where Id =: orderLineList[0].Id];
            //system.assertEquals('UK', checkOrderLineFinal[0].PostingLocation__c);
            
            List<Line_Item_Attribute__c> checkLineItem = [SELECT Id, Posting_Location__c FROM Line_Item_Attribute__c Where Id =: lineItemList[0].Id];
            checkLineItem[0].Posting_location__c = 'France';
            update checkLineItem;
            
            List<Order_Line_Item__c> checkOrderLineFinalupdate = [SELECT PostingLocation__c FROM Order_Line_Item__c Where Id =: orderLineList[0].Id];
            //system.assertEquals('France', checkOrderLineFinalupdate[0].PostingLocation__c);*/

        Test.stoptest();
    } 
}