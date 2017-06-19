//
// (c) 2015 Appirio, Inc.
//
//  Test class for LineItemTrigger & LineItemTriggerHandler
//
// Sep 07, 2015     Vivek Ojha      Original 
//
@isTest 
private class LineItemTriggerTest{

    static testMethod void test_QueryPardRulesByOptions() {
       
        Account acc  = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');

		insert acc;

		Opportunity opp = TestDataSetupUtility.createTestOpportunity('TestOpp' , acc.Id);

		insert opp;
		
		Apttus_Config2__PriceList__c aptusConfigPriceList = TestDataSetupUtility.createPriceList('TestPrice',true);
		
        Account billingAcc  = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Billing Account');
		insert billingAcc;
       
		Apttus_Proposal__Proposal__c proposal = TestDataSetupUtility.createProposal(opp.Id);
		Contact c=TestDataSetupUtility.createTestContact(billingAcc.Id,'test1','test1', 'sample1@gmail.com');
		insert c;
		Contact c1=TestDataSetupUtility.createTestContact(acc.Id,'test2','test2', 'sample2@gmail.com');
		insert c1;
		proposal.Apttus_QPConfig__PriceListId__c=aptusConfigPriceList.Id;
		proposal.BillingAccount__c = billingAcc.Id;
		proposal.BillContact__c = c.Id;
		proposal.Apttus_Proposal__Account__c=acc.Id;
		proposal.PostingContact__c = c1.Id;

		insert proposal;
       
        Apttus_Config2__ProductConfiguration__c aptusConfig = TestDataSetupUtility.createTestProductConfig(proposal , acc , aptusConfigPriceList);
		aptusConfig.Apttus_Config2__Status__c = 'Finalized';
		insert aptusConfig;
        
        Test.startTest();
        
        Apttus_Config2__LineItem__c lineItem = TestDataSetupUtility.createLineItemApttus(aptusConfig.Id);
        insert lineItem;
        
        Test.stopTest();
        
    }

}