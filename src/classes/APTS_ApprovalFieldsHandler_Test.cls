@isTest
public class APTS_ApprovalFieldsHandler_Test {
    static Apttus_Proposal__Proposal__c proposal;
    static User manager, testUser;
    static Account account;
    static Apttus_Config2__ProductConfiguration__c  config;
    
    static testMethod void testAPTS_ApprovalFieldsHandler(){
        Test.startTest();
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        insert manager;
        testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        testUser.Discount_Threshold__c  = 10.0;
        insert testuser;
        
         System.runAs(testUser){
            // Create test account
            account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
            system.debug('after account ' + account);
            insert account;
            
            
            //create Opportunity
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', account.Id);
            opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'GCS Opportunity');
            insert opp;
            
            //Create product2
            Product2 product = TestDataSetupUtility.createProduct('Test product1', false); 
            product.Convert_From__c = true;
            product.Service_Type__c = 'Usage';
            insert product;
            
            Product2 product1 = TestDataSetupUtility.createProduct('Test product1', false); 
            product1.Convert_From__c = true;
            product1.Service_Type__c = 'Subscription';
            insert product1;
            
            //Create price list
            Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
            insert priceList; 
            
            Apttus_Config2__PriceListItem__c pli = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 10, Apttus_Config2__ProductId__c = product.Id, Apttus_Config2__ChargeType__c = 'Standard Price');
            insert pli;
            
            //create proposal
            proposal = TestDataSetupUtility.createProposal('Test Proposal', account.Id, opp.Id, 'Accepted Online', false);
            proposal.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Apttus_Proposal__Proposal__c', 'Proposal');
            proposal.Apttus_QPConfig__PriceListId__c = priceList.id;  
            proposal.MidContract_Proposal__c = true;
            proposal.Upgrade_Proposal__c = true;
            insert proposal;    
        
            config = TestDataSetupUtility.createTestProductConfig(proposal,account,priceList);
            insert config;
         }
        
        APTS_ApprovalFieldsHandler handler = new APTS_ApprovalFieldsHandler();
        Apttus_Config2__LineItem__c lineItem = new Apttus_Config2__LineItem__c(Apttus_Config2__LineStatus__c='New',Apttus_Config2__EndDate__c = Date.valueOf(Datetime.now().addDays(10)), Apttus_Config2__StartDate__c =Date.valueOf(Datetime.now()) ,   Apttus_Config2__NetPrice__c=10.0,Apttus_Config2__Quantity__c=5,Apttus_Config2__OptionPrice__c=10,Apttus_Config2__LineType__c='Option',Apttus_Config2__ListPrice__c=5,Apttus_Config2__BasePrice__c=5);
        List<Apttus_Config2__LineItem__c> listLineItem = new List<Apttus_Config2__LineItem__c>{lineItem};
        handler.PopulateApprovalFields(Proposal, config.id, listLineItem);
       // handler.PopulateApprovalFields(getProposal(), config.id, listLineItem);
        handler.addComments = false;
        Test.stopTest();
    }
    
    static testMethod void testAPTS_ApprovalFieldsHandler2(){
        Test.startTest();
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        insert manager;
        testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        testUser.Discount_Threshold__c  = 10.0;
        insert testuser;
        
         System.runAs(testUser){
            // Create test account
            account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
            system.debug('after account ' + account);
            insert account;
            
            
            //create Opportunity
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', account.Id);
            opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'GCS Opportunity');
            insert opp;
            
            //Create product2
            Product2 product = TestDataSetupUtility.createProduct('Test product1', false); 
            product.Convert_From__c = true;
            product.Service_Type__c = 'Usage';
            insert product;
            
            Product2 product1 = TestDataSetupUtility.createProduct('Test product1', false); 
            product1.Convert_From__c = true;
            product1.Service_Type__c = 'Subscription';
            insert product1;
            
            //Create price list
            Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
            insert priceList; 
            
            Apttus_Config2__PriceListItem__c pli = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 10, Apttus_Config2__ProductId__c = product.Id, Apttus_Config2__ChargeType__c = 'Standard Price');
            insert pli;
            
            //create proposal
            proposal = TestDataSetupUtility.createProposal('Test Proposal', account.Id, opp.Id, 'Accepted Online', false);
            proposal.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Apttus_Proposal__Proposal__c', 'Proposal');
            proposal.Apttus_QPConfig__PriceListId__c = priceList.id;  
            proposal.MidContract_Proposal__c = true;
            proposal.Upgrade_Proposal__c = true;
            proposal.APTS_Quote_Type__c = 'Product Conversion';
            insert proposal;    
        
            config = TestDataSetupUtility.createTestProductConfig(proposal,account,priceList);
            insert config;
         }
        
        APTS_ApprovalFieldsHandler handler = new APTS_ApprovalFieldsHandler();
        Apttus_Config2__LineItem__c lineItem = new Apttus_Config2__LineItem__c(Apttus_Config2__LineStatus__c='New',Apttus_Config2__OptionPrice__c = null,Apttus_Config2__EndDate__c = Date.valueOf(Datetime.now().addDays(10)), Apttus_Config2__StartDate__c =Date.valueOf(Datetime.now()) ,   Apttus_Config2__NetPrice__c=10.0,Apttus_Config2__Quantity__c=5,Apttus_Config2__LineType__c='Option',Apttus_Config2__ListPrice__c=5,Apttus_Config2__BasePrice__c=5);
        List<Apttus_Config2__LineItem__c> listLineItem = new List<Apttus_Config2__LineItem__c>{lineItem};
        //Apttus_Proposal__Proposal__c proposal  = getProposal();
        //proposal.APTS_Quote_Type__c = 'Product Conversion';
        //update proposal;
        handler.PopulateApprovalFields(proposal, config.id, listLineItem);
        handler.addComments = false;
        Test.stopTest();
    }
    
    /*
    private static Apttus_Proposal__Proposal__c getProposal(){
        Apttus_Proposal__Proposal__c proposal = null;
        Account acct = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TestAcct_28_07_15');
        insert acct;
        Contact con = TestDataSetupUtility.createTestContact(acct.Id, 'Test_Last', 'Test_First', 'test@test.com');
        insert con;
        Opportunity oppt = TestDataSetupUtility.createTestOpportunity('TestOppt_28_07_15', acct.Id);
        insert oppt;
        proposal = TestDataSetupUtility.createProposal('TEST_PROP_28_07_15', acct.Id, oppt.Id, 'test', false);
        insert proposal;
        return proposal;
    }*/
}