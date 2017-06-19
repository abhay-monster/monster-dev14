@isTest
private class ProductAttributeValueHandlerTest {
	static User u;
	static Apttus_Config2__LineItem__c aptusLineItem;
	static testMethod void testProductAttributeValueHandler(){
		u = [Select Id from User where Profile.Name =: 'System Administrator' and isActive = true limit 1];
   		system.runAs(u) {
   			createTestData();
   			
			Test.startTest();
				
			  	Apttus_Config2__ProductAttributeValue__c test_ProductAttributeValue1 = new Apttus_Config2__ProductAttributeValue__c(
				Apttus_Config2__LineItemId__c = aptusLineItem.Id);
				test_ProductAttributeValue1.Posting_Locations__c = 'India';
				test_ProductAttributeValue1.Copy_Posting_Location__c = true;
				
				Apttus_Config2__ProductAttributeValue__c test_ProductAttributeValue2 = new Apttus_Config2__ProductAttributeValue__c(
				Apttus_Config2__LineItemId__c = aptusLineItem.Id);
				test_ProductAttributeValue2.Posting_Locations__c = 'United States';
				insert (new List<Apttus_Config2__ProductAttributeValue__c>{test_ProductAttributeValue1,test_ProductAttributeValue2});
				
				List<Apttus_Config2__ProductAttributeValue__c> lstNew = new List<Apttus_Config2__ProductAttributeValue__c>();
				test_ProductAttributeValue1.Posting_Locations__c = 'United States';
				test_ProductAttributeValue2.Posting_Locations__c = 'India';
            	test_ProductAttributeValue2.Cascaded_Attribute_value__c='Variable_Quanity__c=7##Quantity__c=7##';
				lstNew.add(test_ProductAttributeValue1);
				lstNew.add(test_ProductAttributeValue2);
				update lstNew;
				
				//calling method to increase coverage
				map<Id,Apttus_Config2__ProductAttributeValue__c> updatedMap = new map<Id,Apttus_Config2__ProductAttributeValue__c>();
				updatedMap.put(test_ProductAttributeValue1.Id,test_ProductAttributeValue1);
				updatedMap.put(test_ProductAttributeValue2.Id,test_ProductAttributeValue2);
				new ProductAttributeValueHandler().copyFieldValuesFromLead(updatedMap);
				new ProductAttributeValueHandler().populatefields(new List<Apttus_Config2__ProductAttributeValue__c>{test_ProductAttributeValue1,test_ProductAttributeValue2});
			Test.stopTest();
		} 
	}
	
	static void createTestData(){        
		Account acct = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TEST PB Account'); //, 'North America', UserInfo.getUserId());
		acct.Phone = '+18008008000';
		acct.BillingCountry = 'Philippines';
		acct.PrimaryServiceRep__c = u.id;
		acct.Organization__c = 'Europe';
		acct.ServiceTier__c = 'Core';
		insert acct;

		
		Xcode__c xcode = new Xcode__c();        
	    xcode.name = 'test1';
	    insert xcode ;
	    
	    XcodeAccount__c xAcc = new XcodeAccount__c ();
	    xAcc.Xcode__c = xcode.Id;
	    xAcc.Account__c = acct .Id;
	    insert xAcc; 
	    
	    Contact con = TestDataSetupUtility.createTestContact(acct.Id, 'PrimaryBillingTestLastnameOne', 'PrimaryBillingTestFirstnameOne', 'email1@testContact.com');
        con.PrimaryBillingContact__c = true;
        insert con;
        
		Opportunity opp = TestDataSetupUtility.createTestOpportunity('test opp', acct.id);
		insert opp;

		Apttus_Proposal__Proposal__c proposal = TestDataSetupUtility.createProposal(opp.Id);
		proposal.AgencyIO__c = 'Tesst';
		proposal.AgencyCommission__c  = 12;
		
		insert proposal;

		Product2 product = TestDataSetupUtility.createProduct('Test Product', false);
		Product2 product1 = TestDataSetupUtility.createProduct('Test Product1', false);
		insert (new List<Product2>{product,product1});
		Apttus_Config2__PriceList__c aptusConfigPriceList = TestDataSetupUtility.createPriceList('TestPrice', true);


		Apttus_Config2__ProductConfiguration__c aptusConfig = TestDataSetupUtility.createTestProductConfig(proposal, acct, aptusConfigPriceList);
		aptusConfig.Apttus_Config2__Status__c = 'Finalized';

		insert aptusConfig;
		Apttus_Config2__AssetLineItem__c test_AssetLineItem = new Apttus_Config2__AssetLineItem__c(
		Name = 'test value');
		insert test_AssetLineItem;
		Apttus_Config2__ProductOptionComponent__c prodComp = new Apttus_Config2__ProductOptionComponent__c();
		prodComp.Copy_Fields_from_Lead__c = 'Attributes_Defaulted__c,a_test_2__c,quantity__c';
		prodComp.Apttus_Config2__Sequence__c = 12;
		insert prodComp;
		aptusLineItem = TestDataSetupUtility.createLineItemApttus(aptusConfig.Id);

		aptusLineItem.Apttus_Config2__ItemSequence__c = 1.00;    
		aptusLineItem.Apttus_Config2__LineNumber__c = 1.00;
		aptusLineItem.Apttus_Config2__LineStatus__c = 'Amended';
		aptusLineItem.Apttus_Config2__BaseProductId__c = product.id;
		aptusLineItem.Apttus_Config2__OptionId__c = product1.id;
		aptusLineItem.Apttus_Config2__PricingStatus__c = 'Complete';
		aptusLineItem.Apttus_Config2__ProductId__c = product.id;
		aptusLineItem.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
		aptusLineItem.Apttus_Config2__EndDate__c = System.Today();
		aptusLineItem.Apttus_Config2__BasePrice__c = 12.23;
		aptusLineItem.AgencyCommission__c  = 12;
		aptusLineItem.Apttus_Config2__LineType__c = 'Option';
		aptusLineItem.Apttus_Config2__ProductOptionId__c = prodComp.Id;
		insert aptusLineItem;
		Apttus_Config2__ProductAttributeGroup__c aptusGroup = TestDataSetupUtility.createGroup('TestGroup');
		insert aptusGroup;

		Apttus_Config2__ProductAttributeGroupMember__c aptusGrpMember = TestDataSetupUtility.createProductGroupMember('TestGroupMember', aptusGroup.Id, product.Id);

		insert aptusGrpMember;
		
        Integration_Attribute__c integration1 = new Integration_Attribute__c(Name = 'PostingLocationGroupId' ,Integration_Type__c='MAPP');
		integration1.source_object__c = 'Line_Item_Attribute__c';   
		integration1.Source_Field__c = 'Posting_Location__c';
		Integration_Attribute__c integration2 = new Integration_Attribute__c(Name = 'TierId' ,Integration_Type__c='MAPP');
		integration2.source_object__c = 'Line_Item_Attribute__c';        
		integration2.Source_Field__c = 'Posting_Location__c';
        List<Integration_Attribute__c> integrationLst = new List<Integration_Attribute__c>();
        integrationLst.add(integration1);
        integrationLst.add(integration2);
		insert integrationLst;
		
		Integration_Attribute_Value__c integrationValue1 = new Integration_Attribute_Value__c();
		integrationValue1.Integration_Attribute__c = integration1.Id;
		Integration_Attribute_Value__c integrationValue2 = new Integration_Attribute_Value__c();
		integrationValue2.Integration_Attribute__c = integration2.Id;
		
		List<Integration_Attribute_Value__c> integrationValueLst = new List<Integration_Attribute_Value__c>();
        integrationValueLst.add(integrationValue1);
        integrationValueLst.add(integrationValue2);
		insert integrationValueLst;
		
	}
}