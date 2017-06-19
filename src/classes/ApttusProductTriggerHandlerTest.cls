@isTest

public with sharing class ApttusProductTriggerHandlerTest{

	static User testuser;
	static Product2 testProduct;

	static {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
	    testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
	    insert testuser;

	    testProduct = new Product2();
	    testProduct.Name='testProduct';
	    testProduct.Discount_Threshold__c=0;
	    testProduct.Eligible_Selling_Country__c = 'Russia';
	     
	}

	static testmethod void testofTrigger(){

		System.runAs(testUser){

			Test.startTest();

			insert testProduct;

			Product2 assertProduct = [SELECT Id, Eligible_Selling_Country__c FROM Product2 WHERE Id=: testProduct.Id];

			System.assertEquals(assertProduct.Eligible_Selling_Country__c, 'Russia');

			testProduct.Eligible_Selling_Country__c = 'Norway';

			update testProduct;

			Test.stopTest();

			Product2 assertProduct1 = [SELECT Id, Eligible_Selling_Country__c FROM Product2 WHERE Id=: testProduct.Id];

			System.assertEquals(assertProduct1.Eligible_Selling_Country__c, 'Norway');

		}

		
	}

}