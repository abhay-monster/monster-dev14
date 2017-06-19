// 
// (c) 2016 Appirio, Inc.
//
// This class is a test for the SandboxBuild class
//
// 21 Jul 2016 - Jeff Lescarbeau - Initial creation/POC
//
@isTest
private class SandboxBuildTest {

	@testSetup static void setupTestData(){
		List<IntegrationConfig__c> insertList = new List<IntegrationConfig__c>();

		//Avalara
		IntegrationConfig__c avalaraInt = new IntegrationConfig__c();
		avalaraInt.Name = 'Avalara Integration';
		avalaraInt.EndpointName__c = 'AvalaraProdTest';
		avalaraInt.AvalaraClient__c = 'Monster';
		avalaraInt.AvalaraCompanyCode__c = 'MWW';
		avalaraInt.Username__c = 'testUsername';
		avalaraInt.Password__c = 'testPassword';
		avalaraInt.Timeout__c = 60000;

		insertList.add(avalaraInt);

		//Paypal
		IntegrationConfig__c paypalInt = new IntegrationConfig__c();
		paypalInt.Name = 'Paypal US';
		paypalInt.EndpointName__c = 'PaypalTest';
		paypalInt.Username__c = 'testUsername';
		paypalInt.Password__c = 'testPassword';
		paypalInt.Timeout__c = 60000;

		insertList.add(paypalInt);

		//Site
		IntegrationConfig__c siteInt = new IntegrationConfig__c();
		siteInt.Name = 'Site Integration';
		siteInt.EndpointName__c = 'SiteTest';
		siteInt.Username__c = 'testUsername';
		siteInt.Password__c = 'testPassword';
		siteInt.Timeout__c = 60000;

		insertList.add(siteInt);

		//Address
		IntegrationConfig__c addrInt = new IntegrationConfig__c();
		addrInt.Name = 'ValidateAddress';
		addrInt.EndpointName__c = 'addrTest';
		addrInt.Username__c = 'testUsername';
		addrInt.Password__c = 'testPassword';
		addrInt.Timeout__c = 60000;

		insertList.add(addrInt);

		insert insertList;

		//update default org settings
		Org_Settings__c orgSettings = Org_Settings__c.getOrgDefaults();
		orgSettings.Product_URL__c = 'testUrl';
		insert orgSettings;

		//apttus approvals
		Apttus_Approval__ApprovalsSystemProperties__c approval = new Apttus_Approval__ApprovalsSystemProperties__c();
		approval.Name = 'System Properties';
		approval.Apttus_Approval__InstanceUrl__c = 'fakeURL';
		insert approval;

		//apttus config settings
		Apttus_Config2__ConfigSystemProperties__c apttusConfig = new  Apttus_Config2__ConfigSystemProperties__c();
		apttusConfig.Name = 'System Properties';
		apttusConfig.Apttus_Config2__InstanceUrl__c = 'FakeURL';
		insert apttusConfig;

		//insert test group
		Group testGroup = new Group();
		testGroup.name='TestingGroup43223';
		testGroup.email='jlescarbeau@test.com';
		testGroup.Type = 'QUEUE';
		insert testGroup;

		//insert case routing record
		CaseRoutingRule__c crr = TestDataSetupUtility.createCaseRoutingRecord();
		crr.InboundEmailAddress__c = 'jlescarbeau@test.com';
		insert crr;

		//insert taxnow settings
		TestDataSetupUtility.buildTaxNowCustomSetting();

	}
	
	@isTest static void testConfigUpdate() {
		SandboxBuild testClass = new SandboxBuild();

		Test.testSandboxPostCopyScript(testclass,UserInfo.getOrganizationId(), UserInfo.getOrganizationId(), 'sandboxName');

		//Avalara
		IntegrationConfig__c avalara = IntegrationConfig__c.getInstance('Avalara Integration');
		System.assertEquals('AvalaraDev',avalara.EndpointName__c,'Avalara did not get updated!');
		//Paypal
		IntegrationConfig__c paypal = IntegrationConfig__c.getInstance('Paypal US');
		System.assertEquals('Payflow-pilot',paypal.EndpointName__c,'Paypal did not get updated!');
		//Site
		IntegrationConfig__c site = IntegrationConfig__c.getInstance('Site Integration');
		System.assertEquals('MonsterBizAppsSiteRouterUAT',site.EndpointName__c,'Site did not get updated!');
		//Address
		IntegrationConfig__c address = IntegrationConfig__c.getInstance('ValidateAddress');
		System.assertEquals('AvalaraDevAddress',address.EndpointName__c,'Address did not get updated!');

		//org settings
		Org_Settings__c orgSettings = Org_Settings__c.getOrgDefaults();
		System.assertEquals(Url.getSalesforceBaseUrl().toExternalForm(),orgSettings.Product_URL__c,'Product URL did not get updated!');

		//approval test
		Apttus_Approval__ApprovalsSystemProperties__c approvals = Apttus_Approval__ApprovalsSystemProperties__c.getValues('System Properties');
		System.assertEquals(Url.getSalesforceBaseUrl().toExternalForm(), approvals.Apttus_Approval__InstanceUrl__c, 'Apttus approvals insteance URL did not get updated');

		//Group test
		Group gr = [Select Id, Email from Group where Name = 'TestingGroup43223' Limit 1];
		System.assertEquals('jlescarbeau=test.com@example.com', gr.Email, 'Group email did not update');

		//Case routing rule update
		CaseRoutingRule__c crr = [Select Id, Routing_Status__c From CaseRoutingRule__c where InboundEmailAddress__c = 'jlescarbeau@test.com' Limit 1];
		System.assertEquals('Debug',crr.Routing_Status__c,'Case Routing rule routing status did not update' );

		//Test taxnow setting
		AVA_SFCORE__TaxNowSetting__c taxsett = [Select AVA_SFCORE__Service_URL__c, AVA_SFCORE__Account_Number__c, AVA_SFCORE__License_Key__c
												From AVA_SFCORE__TaxNowSetting__c Limit 1];
		System.assertEquals('https://development.avalara.net/',taxsett.AVA_SFCORE__Service_URL__c,'Tax setting service url did not update');
		System.assertEquals('1100145554',taxsett.AVA_SFCORE__Account_Number__c,'tax settings account number did not update');
		System.assertEquals('E48F06C39A71A1A3',taxsett.AVA_SFCORE__License_Key__c,'tax settings license key did not update');


	}
	
}