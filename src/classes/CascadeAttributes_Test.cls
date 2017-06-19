@isTest
public class CascadeAttributes_Test {
    // @author: Aakash Khatri
	static User manager, testUser;
	static Account account;
	static Apttus_Proposal__Proposal__c proposal_n;
	
    @isTest
    static void testLineItems() {
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
	        
	        Product2 bundleProduct = TestDataSetupUtility.createProduct('Test product2', false); 
	        bundleProduct.Convert_From__c = true;
	        bundleProduct.Apttus_Config2__ConfigurationType__c = 'Bundle';
	        insert bundleProduct;
	        
	        Product2 optionProduct = TestDataSetupUtility.createProduct('Test product3', false); 
	        optionProduct.Convert_From__c = true;
	        optionProduct.Apttus_Config2__ConfigurationType__c = 'Option';
	        insert optionProduct;
	        
	        //Create price list
	        Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
	        insert priceList; 
            
            // create proposal line item
            Apttus_Config2__PriceListItem__c pli = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 10, Apttus_Config2__ProductId__c = product.Id, Apttus_Config2__ChargeType__c = 'Standard Price');
        	insert pli;
	        
	        //create proposal
	        proposal_n = TestDataSetupUtility.createProposal('Test Proposal', account.Id, opp.Id, 'Accepted Online', false);
	        proposal_n.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Apttus_Proposal__Proposal__c', 'Proposal');
            proposal_n.Apttus_QPConfig__PriceListId__c = priceList.id;        
	        insert proposal_n;	
	        
        
            Apttus_Config2__ProductConfiguration__c config = TestDataSetupUtility.createTestProductConfig(proposal_n,account,priceList);
            insert config;
            //System.debug('config:'+config);
        
            List<Apttus_Config2__LineItem__c> lineItemList = new List<Apttus_Config2__LineItem__c>();
            
            Apttus_Config2__LineItem__c lineItem = TestDataSetupUtility.createLineItemApttus(config.Id);
            lineItem.Apttus_Config2__StartDate__c=System.today();
            lineItem.Apttus_Config2__EndDate__c=System.today()+60;
            lineItem.Apttus_Config2__Comments__c='test';
            lineItem.Apttus_Config2__LineNumber__c = 1;
            lineItem.Apttus_Config2__LineType__c = 'Option';
            lineItem.Apttus_Config2__OptionId__c = product.Id;
            lineItemList.add(lineItem);
            
            /*
            Apttus_Config2__LineItem__c lineItem2 = TestDataSetupUtility.createLineItemApttus(config.Id);
            lineItem2.Apttus_Config2__StartDate__c=System.today();
            lineItem2.Apttus_Config2__EndDate__c=System.today()+60;
            lineItem2.Apttus_Config2__Comments__c='test';
            lineItem2.Apttus_Config2__LineNumber__c = 1;
            lineItem2.Apttus_Config2__LineType__c = 'Option';
            lineItem2.Apttus_Config2__OptionId__c = product.Id;
            lineItemList.add(lineItem2);
            */
            
            
            insert lineItemList;
            
            // create Apttus_Config2__ProductAttributeValue__c
            Apttus_Config2__ProductAttributeValue__c pav = new Apttus_Config2__ProductAttributeValue__c();
            pav.Apttus_Config2__LineItemId__c = lineItem.Id;
            pav.CurrencyIsoCode = 'USD';
            insert pav;
            
            lineItem.Apttus_Config2__AttributeValueId__c = pav.Id;
            update lineItem;
            
            // create Apttus_Config2__ClassificationName__c
    	    Apttus_Config2__ClassificationName__c category = new Apttus_Config2__ClassificationName__c();
    	    category.Name = 'Test Option Group 2';
    	    category.Apttus_Config2__HierarchyLabel__c = 'Test Option Group 2';
    	    insert category;
    	    
    	    // create Apttus_Config2__ClassificationHierarchy__c
    	    Apttus_Config2__ClassificationHierarchy__c ch = new Apttus_Config2__ClassificationHierarchy__c();
    	    ch.Name = 'new hierarchy';
    	    ch.Apttus_Config2__Label__c = 'Test Option Group 2';
    	    ch.Apttus_Config2__HierarchyId__c = category.Id;
    	    insert ch;
    	    
    	    // create Apttus_Config2__ProductOptionGroup__c
    	    Apttus_Config2__ProductOptionGroup__c pog = new Apttus_Config2__ProductOptionGroup__c();
    	    pog.Apttus_Config2__Sequence__c = 1;
    	    pog.Apttus_Config2__ProductId__c = product.Id;
    	    pog.Apttus_Config2__OptionGroupId__c = ch.Id;
    	    insert pog;
    	    
    	    
    	    // create Apttus_Config2__ProductOptionComponent__c
    	    Apttus_Config2__ProductOptionComponent__c poc = new Apttus_Config2__ProductOptionComponent__c();
    	    //poc.Id = 'a1sq00000002JLi';
    	    poc.Apttus_Config2__ComponentProductId__c = product.Id;
    	    poc.Apttus_Config2__ParentProductId__c = bundleProduct.Id;
    	    poc.Apttus_Config2__Sequence__c =1;
    	    poc.Copy_Fields_from_Lead__c = 'CurrencyIsoCode,Location__c';
    	    poc.Apttus_Config2__ProductOptionGroupId__c = pog.Id;
    	    poc.Product_Option_Component_External_ID__c = 'a1s110000001DHsAAM';
    	    poc.Apttus_Config2__RelationshipType__c = 'Option';
    	    test.startTest();
    	    insert poc;
    	    poc = [select Name from Apttus_Config2__ProductOptionComponent__c where id=: poc.Id];

    	    System.debug('***************:*' + poc.Name + ' ' + poc);
    	    try {
                CascadeAttributes ca_false = new CascadeAttributes(pav,lineItem, false);
                System.debug('***************:*' + poc.Name + ' ' + poc);
                Set<Id> newSet = new Set<Id>{product.Id};
                //map<Id,set<string>> testMap = ca_false.getNonLeadingOptions(newSet,bundleProduct.Id);
                CascadeAttributes ca_true = new CascadeAttributes(pav,lineItem, true);
                boolean validateLead = ca_true.validateLeadOption(config.Id, 1, bundleProduct.Id);
                boolean validateLead_1 = ca_true.validateLeadOption(config.Id, 1, bundleProduct.Id);
                boolean validateLead_2 = ca_true.validateLeadOption(config.Id, 1, bundleProduct.Id);
                System.debug('************** validate lead : ' + validateLead);
                System.debug('************** validate lead 2 : ' + validateLead_2);
    	    } catch(Exception e) {
    	      System.debug('********************* Error: '+ e);
    	    }
            
            test.stopTest();
        } 
	}
}