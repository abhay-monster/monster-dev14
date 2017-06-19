/****
 *Test class of XcodeBatchClass
 *
 */@isTest
private class XcodeAccountTriggerTest {
	static Personal_Settings__c personalSettings;
	static testmethod void testTrigger() {
		
		createTestData();
		Test.StartTest();
		
		Account testAccount = TestDataSetupUtility.createTestAccountWithShipping('Test Account');

		insert testAccount;

		Order__c testOrder = new Order__c(Account__c = testAccount.id);
		insert testOrder;

		Xcode__c testXcode = new Xcode__c(Name = 'testXcode', Trusted__c = 'N');
		insert testXcode;

		XcodeAccount__c testXcodeAccout = new XcodeAccount__c(Account__c = testAccount.id, Xcode__c = testXcode.id);
		insert testXcodeAccout;
		
		
		update testXcodeAccout;
		delete testXcodeAccout;
		undelete testXcodeAccout;
		
 		XcodeAccount__c testXcodeAccout1 = new XcodeAccount__c(Account__c = testAccount.id, Xcode__c = testXcode.id);
		insert testXcodeAccout1;
		
		update (new List<XcodeAccount__c>{testXcodeAccout,testXcodeAccout1});
	}
	
	
	static testMethod void testTrigger1(){
		createTestData();
		personalSettings.Trigger_Account__c = false;
		update personalSettings;
		Test.StartTest();
		
		Account testAccount = TestDataSetupUtility.createTestAccountWithShipping('Test Account');

		insert testAccount;

		Order__c testOrder = new Order__c(Account__c = testAccount.id);
		insert testOrder;

		Xcode__c testXcode = new Xcode__c(Name = 'testXcode', Trusted__c = 'N');
		insert testXcode;

		XcodeAccount__c testXcodeAccout = new XcodeAccount__c(Account__c = testAccount.id, Xcode__c = testXcode.id);
		insert testXcodeAccout;
		
		
		update testXcodeAccout;
		delete testXcodeAccout;
		undelete testXcodeAccout;
		
 		XcodeAccount__c testXcodeAccout1 = new XcodeAccount__c(Account__c = testAccount.id, Xcode__c = testXcode.id);
		insert testXcodeAccout1;
		
		update (new List<XcodeAccount__c>{testXcodeAccout,testXcodeAccout1});
		delete personalSettings;
		update testXcodeAccout;
		
		
		
	}
	
	static void createTestData(){
		Boolean isExecuting = true;
		Integer pTriggerSize = 2;
		XCodeAccountTriggerHandler testclass2 = new XCodeAccountTriggerHandler(isExecuting, pTriggerSize);

		personalSettings = TestDataSetupUtility.buildPersonalSetting();

		personalSettings.Trigger_Order__c = true;
		personalSettings.Trigger_Account__c = true;
		personalSettings.Trigger_Opportunity__c = true;
		personalSettings.Validation_Account__c = true;
		personalSettings.Validation_Opportunity__c = true;

		insert personalSettings;
		IntegrationConfig__c setting = new IntegrationConfig__c(Name = 'USPS Integration', AvalaraClient__c = 'Monster Worldwide, Inc.',
				AvalaraCompanyCode__c = 'MWW', AvalaraCountry__c = 'MWW', EndpointName__c = 'USPS Integration',IsPaypalTest__c = false,
				Password__c = '6NvqAGdhXM^y',Timeout__c = 60000,Username__c = 'jlescarbeau@appirio.com', PaypalRedirectURL__c = 'PaypalRedirectURL');
			insert setting;
			WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c(Name = 'USPS Integration', Endpoint__c = 'https:development.avalara.net/1.0/tax/get');
			WebServiceEndpoint__c endpoint2 = new WebServiceEndpoint__c(Name = 'PaypalRedirectURL', Endpoint__c = 'https:payflowlink.paypal.com');
			insert new List<WebServiceEndpoint__c>{endpoint, endpoint2};
	}
}