/*
@author : Sunny Gill
@description : Test the trigger
@date : 13/07/2015
*/
@isTest
private class ProductConfigurationTrigger_Test {
    static Account acc;
    static Apttus_Proposal__Proposal__c proposal;
    static Apttus_Config2__PriceList__c price;
    static Apttus_Config2__ProductConfiguration__c config;
    /*
    @author : Sunny Gill
    @description : Test the trigger
    @date : 13/07/2015
    */
    static testMethod void testcalculateYOYDiscount(){
        config.Apttus_Config2__Status__c = 'Finalized';
        update config;
    }

    static testMethod void testProductConfigTrigger(){
        delete config;
        undelete config;
    }
    static {
        // Create test account
        acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        system.debug('after account ' + acc);
        insert acc;
        
        
        //create Opportunity
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', acc.Id);
        opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'Opportunity');
        insert opp;
         
        //Create product2
        Product2 product = TestDataSetupUtility.createProduct('Test product', false);
        product.Convert_From__c = true;
        product.Service_Type__c = 'Usage';
        insert product;
        
        //Create price list
        price = TestDataSetupUtility.createPriceList('USD Price List', false);
        insert price; 
        
        //create proposal
        proposal = TestDataSetupUtility.createProposal('Test Proposal', acc.Id, opp.Id, 'Accepted Online', false);
        proposal.Apttus_QPConfig__PriceListId__c = price.id;
        insert proposal;
        
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
            CurrencyIsoCode = 'USD' ,
    Apttus_Config2__PrimaryLineNumber__c = 12);
        insert test_LineItem;

        config.Apttus_Config2__IsTransient__c = false;
        update config;


  }
}