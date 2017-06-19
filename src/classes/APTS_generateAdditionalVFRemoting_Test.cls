@isTest

public class APTS_generateAdditionalVFRemoting_Test {
    
    static User manager, testUser;
	static Account account;
	static Apttus_Proposal__Proposal__c proposal_n;
	
	
    static testMethod void vfRemotingTest() {
        
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
	        insert product;
	        
	        Product2 product1 = TestDataSetupUtility.createProduct('Test Product2', false);
	        product.Convert_From__c = true;
	        insert product1;
	        
	        //Create price list
	        Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
	        insert priceList; 
            
            Apttus_Config2__PriceListItem__c pli = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 10, Apttus_Config2__ProductId__c = product.Id, Apttus_Config2__ChargeType__c = 'Standard Price');
        	insert pli;
	        
	        //create proposal
	        proposal_n = TestDataSetupUtility.createProposal('Test Proposal', account.Id, opp.Id, 'Accepted Online', false);
	        proposal_n.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Apttus_Proposal__Proposal__c', 'Proposal');
            proposal_n.Apttus_QPConfig__PriceListId__c = priceList.id;        
	        
	        insert proposal_n;	
	        
        
            Apttus_Config2__ProductConfiguration__c config = TestDataSetupUtility.createTestProductConfig(proposal_n,account,priceList);
            insert config;
        
        
        
        
        
            // create Apttus_Config2__LineItem__c
            Apttus_Config2__LineItem__c lineItemConfig = TestDataSetupUtility.createLineItemApttus(config.Id);
            lineItemConfig.Apttus_Config2__StartDate__c=System.today();
            lineItemConfig.Apttus_Config2__EndDate__c=System.today()+60;
            lineItemConfig.Apttus_Config2__Comments__c='test';
            lineItemConfig.Select__c = true;
            insert lineItemConfig;
            
            
            ApexPages.currentPage().getParameters().put('id', config.id);
            
            
            // create Apttus_Config2__ProductAttributeValue__c
            Apttus_Config2__ProductAttributeValue__c pAVconfig = new Apttus_Config2__ProductAttributeValue__c();
            pAVconfig.Apttus_Config2__LineItemId__c = lineItemConfig.Id;
            insert pAVconfig;
            
            
            APTS_generateAdditionalVFRemoting remoting = new APTS_generateAdditionalVFRemoting();
            remoting.iYear = 10;
            remoting.years = 20;
            String testURLParam = remoting.URLQueryParameters;
            remoting.URLQueryParameters = '';
            boolean testAction = APTS_generateAdditionalVFRemoting.GenerateAdditionalYearsForSelectedLineItem(lineItemConfig.id, 0, config.id );
            
        }
        
    }
    
    static testMethod void vfRemotingTest2() {
        
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
	        insert product;
	        
	        Product2 product1 = TestDataSetupUtility.createProduct('Test Product2', false);
	        product.Convert_From__c = true;
	        insert product1;
	        
	        //Create price list
	        Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
	        insert priceList; 
            
            Apttus_Config2__PriceListItem__c pli = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 10, Apttus_Config2__ProductId__c = product.Id, Apttus_Config2__ChargeType__c = 'Standard Price');
        	insert pli;
	        
	        //create proposal
	        proposal_n = TestDataSetupUtility.createProposal('Test Proposal', account.Id, opp.Id, 'Accepted Online', false);
	        proposal_n.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Apttus_Proposal__Proposal__c', 'Proposal');
            proposal_n.Apttus_QPConfig__PriceListId__c = priceList.id;        
	        
	        insert proposal_n;	
	        
        
            Apttus_Config2__ProductConfiguration__c config = TestDataSetupUtility.createTestProductConfig(proposal_n,account,priceList);
            insert config;
        
        
        
        
        
            // create Apttus_Config2__LineItem__c
            Apttus_Config2__LineItem__c lineItemConfig = TestDataSetupUtility.createLineItemApttus(config.Id);
            lineItemConfig.Apttus_Config2__StartDate__c=System.today();
            lineItemConfig.Apttus_Config2__EndDate__c=System.today()+60;
            lineItemConfig.Apttus_Config2__Comments__c='test';
            lineItemConfig.Select__c = false;
            insert lineItemConfig;
            
            
            ApexPages.currentPage().getParameters().put('id', lineItemConfig.id);
            
            
            // create Apttus_Config2__ProductAttributeValue__c
            Apttus_Config2__ProductAttributeValue__c pAVconfig = new Apttus_Config2__ProductAttributeValue__c();
            pAVconfig.Apttus_Config2__LineItemId__c = lineItemConfig.Id;
            insert pAVconfig;
            
            
            APTS_generateAdditionalVFRemoting remoting = new APTS_generateAdditionalVFRemoting();
            remoting.iYear = 10;
            remoting.years = 20;
            String testURLParam = remoting.URLQueryParameters;
            remoting.URLQueryParameters = '';
            boolean testAction = APTS_generateAdditionalVFRemoting.GenerateAdditionalYearsForSelectedLineItem(lineItemConfig.id, 0, config.id );
            
        }
        
    }
}