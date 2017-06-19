@isTest
private class StrategicAccountPlanTriggerHandlerTest {

	private static testMethod void testsap(){
		Personal_Settings__c personalSettings = TestDataSetupUtility.buildPersonalSetting();
		personalSettings.Trigger_Strategic_Account_Plan__c = true;
		insert personalSettings;

		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
		User testUser = TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);
		insert testUser;
		Account testaccount = TestDataSetupUtility.createTestAccount('TESTACCCCH ', 'test ', testUser.Id);
		Account testaccount1 = TestDataSetupUtility.createTestAccount('TESTACCCCH2 ', 'test ', testUser.Id);
		testaccount1.AgencyFlag__c = true;
		insert new List<Account>{testaccount,testaccount1};
		RelatedPartner__c relatedPrtner = TestDataSetupUtility.createTestRelatedPartner(testaccount.Id, testaccount1.Id);
		relatedPrtner.AgencyType__c = 'Billing';
		insert relatedPrtner;
		Strategic_Account_Plan__c saptest = new Strategic_Account_Plan__c(Name = 'Test', Account_Name__c = testaccount.id, 
		VendorEvaluationKeyMetrics__c = 'Option 3');
		Strategic_Account_Plan__c saptest2 = new Strategic_Account_Plan__c(Name = 'Test', Account_Name__c = testaccount.id, 
		VendorEvaluationKeyMetrics__c = 'Option 4');
		Test.startTest();

		try{
			insert new List<Strategic_Account_Plan__c>{saptest, saptest2};
			saptest.VendorEvaluationKeyMetrics__c = 'Option 1';
			saptest2.VendorEvaluationKeyMetrics__c = 'Option 2';

			update new List<Strategic_Account_Plan__c>{saptest, saptest2};
		}
		catch(BaseApplicationException be){}
		catch(Exception e){}
		test.stopTest();
	}

	private static testMethod void testsap2(){
		Personal_Settings__c personalSettings = TestDataSetupUtility.buildPersonalSetting();
		personalSettings.Trigger_Strategic_Account_Plan__c = true;
		insert personalSettings;

		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
		User testUser = TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);
		insert testUser;
		Account testaccount = TestDataSetupUtility.createTestAccount('TESTACCCCH ', 'test ', testUser.Id);
		Account testaccount1 = TestDataSetupUtility.createTestAccount('TESTACCCCH2 ', 'test ', testUser.Id);
		testaccount1.AgencyFlag__c = true;
		//insert new List<Account>{testaccount,testaccount1};
		insert testaccount;
		RelatedPartner__c relatedPrtner = TestDataSetupUtility.createTestRelatedPartner(testaccount.Id, testaccount1.Id);
		relatedPrtner.AgencyType__c = 'Billing';
		//insert relatedPrtner;
		Strategic_Account_Plan__c saptest = new Strategic_Account_Plan__c(Name = 'Test', Account_Name__c = testaccount.id, 
		VendorEvaluationKeyMetrics__c = 'Option 3');
		Test.startTest();

		try{
			insert saptest;
			saptest.VendorEvaluationKeyMetrics__c = 'Option 4';

			update saptest;
		}
		catch(BaseApplicationException be){}
		catch(Exception e){}
		test.stopTest();
	}
}