@isTest
private class OLISalesAdjustmentTriggerTest {
  static testMethod void testRecordCreate(){

      //randowm custom setting needed for inserting opp line items
      TestDataSetupUtility.buildTaxNowCustomSetting();

      //insert our two test users
      User testUser1 = TestDataSetupUtility.createUser('System Administrator', true);
      User testUser2 = TestDataSetupUtility.createUser('System Administrator', true);

      //insert the test account setting the owner to the first test user (the opportunity will inherit the owner)
      Account testAccount = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account -1');
      testAccount.ownerId = testUser1.Id;
      insert testAccount;

      //insert our test opportunity
      Opportunity testOpp = TestDataSetupUtility.createTestOpportunity('testOppty', testAccount.Id);
      insert testOpp;

      //insert our test proposal
      Apttus_Proposal__Proposal__c testProp = TestDataSetupUtility.createApttusProposal(testOpp);
      insert testProp;
      Contact con = TestDataSetupUtility.createTestContact(testAccount.Id, 'confirst1', 'conlast1', 'con1@email.trrs.com');
      insert con;

      //insert our test order
      Order__c testOrder = TestDataSetupUtility.createOrderWithOpportunity(testAccount.Id, testOpp.Id, testProp.Id, con.Id);
      insert testOrder;

      //insert our test order line item
      Order_Line_Item__c testOrderLineItem = TestDataSetupUtility.createOrderLineItem(testOrder.Id);
      insert testOrderLineItem;

      //insert our test opportunity line item, needed to wait for the order created before we could insert it
      OpportunityLineItem testOppLineItem = TestDataSetupUtility.createFullOpportunityLineItem(testOpp.Id);
      testOppLineItem.Order_Line_Item_Custom__c = testOrderLineItem.Id;
      insert testOppLineItem;

      //now insert our Opportunity Splits
      OpportunitySplit split = new OpportunitySplit();
      split.OpportunityId = testOpp.Id;
      split.SplitPercentage = 100;
      split.SplitOwnerId = testUser1.Id;

      OpportunitySplit split2 = new OpportunitySplit();
      split2.OpportunityId = testOpp.Id;
      split2.SplitPercentage = 0;
      split2.SplitOwnerId = testUser2.Id;

      List<OpportunitySplit> splitList = new List<OpportunitySplit>();
      //splitList.add(split);
      splitList.add(split2);
      insert splitList;

      test.startTest();
      //insert our test record with the adjustments that will be made to the opportunity and line items
      Order_Line_Item_Sales_Adjustment__c testOrderLineItemSalesAdjustment = new Order_Line_Item_Sales_Adjustment__c();
      testOrderLineItemSalesAdjustment.OrderLineItem__c = testOrderLineItem.Id;
      testOrderLineItemSalesAdjustment.ADJ_Owner_on_Start_Date__c = testUser2.Id;
      testOrderLineItemSalesAdjustment.ADJ_Earliest_Product_Start_Date__c = Date.today().addDays(25);
      testOrderLineItemSalesAdjustment.ADJ_Sales_Credit__c = 676.67;

      insert testOrderLineItemSalesAdjustment;

      //do our asserts to make sure everything is working
      Opportunity oppQuery = [Select Id, Amount, OwnerId, CloseDate from Opportunity where Id = :testOpp.Id Limit 1];
      system.assertEquals(oppQuery.ownerId, testUser2.Id);
      system.assertEquals(oppQuery.CloseDate, Date.today().addDays(25));
      system.assertEquals(oppQuery.Amount, 676.67);


      //now lets test the update
      testOrderLineItemSalesAdjustment.ADJ_Owner_on_Start_Date__c = testUser1.Id;
      testOrderLineItemSalesAdjustment.ADJ_Earliest_Product_Start_Date__c = Date.today().addDays(20);
      testOrderLineItemSalesAdjustment.ADJ_Sales_Credit__c = 3000;

      update testOrderLineItemSalesAdjustment;

      //do our asserts to make sure everything is working
      oppQuery = [Select Id, Amount, OwnerId, CloseDate from Opportunity where Id = :testOpp.Id Limit 1];
      system.assertEquals(oppQuery.ownerId, testUser1.Id);
      system.assertEquals(oppQuery.CloseDate, Date.today().addDays(20));
      system.assertEquals(oppQuery.Amount, 3000);
      test.stopTest();
  }
}