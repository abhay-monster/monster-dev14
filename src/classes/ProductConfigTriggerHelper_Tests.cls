/*
@author : Sunny Gill
@description : Test the trigger
@date : 13/07/2015
*/
@isTest
private class ProductConfigTriggerHelper_Tests {
  static Account acc;
  static Apttus_Proposal__Proposal__c proposal;
  static Apttus_Config2__PriceList__c price;
  static Order__c  order1;
  static Apttus_Config2__ProductConfiguration__c config;
  /*
    @author : Sunny Gill
    @description : Test the trigger
    @date : 13/07/2015
    */
    static testMethod void testProductConfigTrigger(){
    Test.startTest();
      config = TestDataSetupUtility.createTestProductConfig(proposal, acc, price);
      
      insert config;
  
      config.Apttus_Config2__IsTransient__c = false;
      config.Apttus_Config2__Status__c = 'Finalized';
      update config;
  
      delete config;
  
      undelete config;
    Test.stopTest();
    }
    
    
    static testMethod void testDiscount(){
      Test.startTest();
          config.Apttus_Config2__Status__c = 'Finalized';
          update config;
      Test.stopTest();
    }

    static testMethod void testProductConfigTrigger1(){
      Test.startTest();
          delete config;
          undelete config;
      Test.stopTest();
    }
    static {
      // Create test account
      acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
      acc.AccountStatus__c = 'Customer';
      acc.Organization__c = 'North America';
      system.debug('after account ' + acc);
      insert acc;
      
      
      //create Opportunity
      Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', acc.Id);
      opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'Opportunity');
      opp.Organization__c = 'North America';
      insert opp;
       
      //Create product2
      Product2 product = TestDataSetupUtility.createProduct('Test product', false);
      product.Convert_From__c = true;
      product.Service_Type__c = 'Usage';
      insert product;
      
      //Create price list
      price = TestDataSetupUtility.createPriceList('USD Price List', false);
      insert price; 
      Contact con = TestDataSetupUtility.createTestContact(acc.Id, 'PrimaryBillingTestLastnameOne', 'PrimaryBillingTestFirstnameOne', 'email1@testContact.com');
        con.PrimaryBillingContact__c = true;
        insert con;
      //create proposal
      proposal = TestDataSetupUtility.createProposal('Test Proposal', acc.Id, opp.Id, 'Accepted Online', false);
      proposal.Apttus_QPConfig__PriceListId__c = price.id;
      proposal.APTS_Quote_Type__c = 'Product Extension';
      //proposal.Organization__c = 'North America';
      
      insert proposal;
      Id CreditOrderRecordType = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Credit');
      order1 = TestDataSetupUtility.createOrder(acc.Id, con.Id);
        order1.OrderStatus__c = 'Verified';
        order1.RecordTypeId = CreditOrderRecordType;
        order1.Opportunity__c = opp.Id;
        order1.BillingAccount__c = acc.id;
        order1.ShippingAccount__c = acc.id;
        // order1.BillingContact__c = con.id; 
        order1.Posting_Contact__c = con.id; 
        order1.OrderDate__c  = Date.today().addMonths(-12);
        
        
        
        Order__c order2 = TestDataSetupUtility.createOrder(acc.Id ,con.Id);
        order2.OrderStatus__c = 'Verified';
        order2.RecordTypeId = CreditOrderRecordType;
        order2.Opportunity__c = opp.Id;
        order2.BillingAccount__c = acc.id;
       // order2.BillingContact__c = con.id; 
        order2.Posting_Contact__c = con.id; 
        order2.OrderDate__c  = Date.today();
        order2.ShippingAccount__c = acc.id;
        insert (new List<Order__c>{order1,order2});
      
      //create AssetLineItem
      Apttus_Config2__AssetLineItem__c assetLineItem = TestDataSetupUtility.createAssetLineItem('Test asset', acc.Id, false);
      assetLineItem.Proposal__c = proposal.Id;
      assetLineItem.Apttus_Config2__ProductId__c = product.id;
      assetLineItem.Apttus_Config2__EndDate__c  = Date.Today().addDays(70);
      insert assetLineItem;
    
    
    config = TestDataSetupUtility.createTestProductConfig(proposal, acc, price);
        insert config;
        
        Apttus_Config2__LineItem__c test_LineItem = new Apttus_Config2__LineItem__c (
        Apttus_Config2__ConfigurationId__c = config.Id,
        Apttus_Config2__ItemSequence__c = 1.00,
        Apttus_Config2__LineNumber__c = 1.00,
        Apttus_Config2__LineStatus__c = 'Amended' ,
        Apttus_Config2__StartDate__c = Date.today(),
        Apttus_Config2__EndDate__c = Date.today(),
        
        CurrencyIsoCode = 'USD' ,
    Apttus_Config2__PrimaryLineNumber__c = 12);
        insert test_LineItem;
        
      
  }
}