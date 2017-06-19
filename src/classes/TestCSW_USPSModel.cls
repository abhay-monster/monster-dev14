/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestCSW_USPSModel {
		static User usr;
		static Profile p;
	static {
		 p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
    usr =  TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);
    insert usr;

    /*paymentDetails = new PaymentDetails__c(Name='Asia Pacific', Id__c='a41J0000000ClF4');
    insert paymentDetails;
   	 	//build personal settings
      Personal_Settings__c persSett = TestDataSetupUtility.buildPersonalSetting();
      
      persSett.Trigger_Account__c = true;
      insert persSett;
      
      WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c();
      endpoint.Endpoint__c = 'USPS Integration';
      endpoint.Name = 'USPS Integration';
      insert endpoint;
      
      IntegrationConfig__c integSett = TestDataSetupUtility.buildIntegrationConfigSetting();
      integSett.Name = 'USPS Integration';
      integSett.EndpointName__c = endpoint.Name;
      integSett.PaypalRedirectURL__c = endpoint.Endpoint__c;
      insert integSett;
      
      CountryLimit__c cl = TestDataSetupUtility.createCountryLimit('United States', 'US', 2000, 'Staffing');
      insert cl;
      acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
      acc.Organization__c = 'Europe';
      acc.Account_Type__c = 'Staffing';
      acc.AccountStatus__c  = 'Customer';*/
    }

    static testMethod void myUnitTest() {
    Test.startTest();

   //build personal settings
        Personal_Settings__c persSett = TestDataSetupUtility.buildPersonalSetting();
        
        persSett.Trigger_Account__c = true;
        insert persSett;
        
        WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c();
        endpoint.Endpoint__c = 'USPS Integration';
        endpoint.Name = 'USPS Integration';
        insert endpoint;
        
        IntegrationConfig__c integSett = TestDataSetupUtility.buildIntegrationConfigSetting();
        integSett.Name = 'USPS Integration';
        integSett.EndpointName__c = endpoint.Name;
        integSett.PaypalRedirectURL__c = endpoint.Endpoint__c;
        insert integSett;
        
        CountryLimit__c cl = TestDataSetupUtility.createCountryLimit('United States', 'US', 2000, 'Staffing');
        insert cl;
        Account testAccount = TestDataSetupUtility.createPersonAccount();
        testAccount.BillingPostalCode = '90210';
        testAccount.PersonMailingPostalCode = '90210';
        testAccount.PersonOtherPostalCode = '90210';
        testAccount.Organization__c = 'North America';
        testAccount.Account_Type__c = 'Staffing';
        testAccount.PersonMailingCountryCode = 'US';
        testAccount.PersonOtherCountryCode = 'US';
        //testAccount.IsPersonAccount = true;
        insert testAccount;

        Account a = [Select Id, CreditLimit__c, SalesChannel__c, PersonMailingCountryCode From Account Where Id =: testAccount.Id];
        system.assertEquals('US', a.PersonMailingCountryCode);
        //system.assertEquals(2000, a.CreditLimit__c);    
        //system.assertEquals('Staffing', a.SalesChannel__c);
        
        ////
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User testUser = TestDataSetupUtility.createTestUser('TestFistName', 'TestLastName', adminProfile.Id);
        insert testUser;
        testAccount.OwnerId = testUser.Id; 
        /////
        try{
        update testAccount; 
        }catch(BaseApplicationException e){}
    Test.stopTest();
    }
    
    static testMethod void myUnitTest1() {
    	 system.runAs(usr) {
    Test.startTest();

   //build personal settings
        Personal_Settings__c persSett = TestDataSetupUtility.buildPersonalSetting();
        
        persSett.Trigger_Account__c = true;
        insert persSett;
        
        WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c();
        endpoint.Endpoint__c = 'USPSAddressValidation';
        endpoint.Name = 'USPSAddressValidation';

        insert endpoint;
        
        IntegrationConfig__c integSett = TestDataSetupUtility.buildIntegrationConfigSetting();
        integSett.Name = 'USPS Integration';
        integSett.EndpointName__c = endpoint.Name;
        integSett.PaypalRedirectURL__c = endpoint.Endpoint__c;
        insert integSett;
        
        CountryLimit__c cl = TestDataSetupUtility.createCountryLimit('United States', 'US', 2000, 'Staffing');
        insert cl;

        String RecTypeId= [select Id from RecordType where (Name='Person Account') and (SobjectType='Account')].Id;
        List<Account> accList = new List<Account>();  
		/*accList.add( new Account(RecordTypeID=RecTypeId,FirstName='Test FName',LastName='Test LName',
		  PersonMailingStreet='test@yahoo.com',PersonMailingPostalCode='90210',PersonMailingCity='SFO',
		  PersonEmail='test@yahoo.com',
		  PersonHomePhone='1234567',
		  //IsPersonAccount = true,
		  PersonMobilePhone='12345678' 
		));*/
		 
		Account testAccount = TestDataSetupUtility.createTestAccountWithShipping('Test FName');
		accList.add(testAccount);
		insert accList;

        Account a = [Select Id, CreditLimit__c, SalesChannel__c, ShippingCountryCode From Account Where Id =: testAccount.Id];
        system.assertEquals('US', a.ShippingCountryCode);
        //system.assertEquals(2000, a.CreditLimit__c);    
        //system.assertEquals('Staffing', a.SalesChannel__c);
        
        ////
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User testUser = TestDataSetupUtility.createTestUser('TestFistName', 'TestLastName', adminProfile.Id);
        insert testUser;
        testAccount.OwnerId = testUser.Id; 
        testAccount.ShippingCountryCode = 'US';
        testAccount.ShippingPostalCode = '90210';
        testAccount.BillingCountryCode = 'US';
        testAccount.BillingPostalCode = '90210';
        /////
         try{
        update testAccount; 
        }catch(BaseApplicationException e){} 
        
        String req= '<CityStateLookupResponse>' +
                                '<ZipCode ID="0">' +
                                    '<Zip5>90210</Zip5>' +
                                    '<City>BEVERLY HILLS</City>' +
                                    '<State>CA</State>' +
                                    '<Number>111</Number>'+
                                    '<Error>sdfsfdsf</Error>'+
                                    '<Description>fdfdf</Description>'+
                                    '<Source>fdfdfdf</Source>'+
                                '</ZipCode>' +
                                '<ZipCode ID="1">' +
                                    '<Zip5>20770</Zip5>' +
                                    '<City>GREENBELT</City>' +
                                    '<State>MD</State>' +
                                '</ZipCode>' +
                            '</CityStateLookupResponse>';
        
        CSW_USPSModel USPSConnector = new CSW_USPSModel('USER_ID', Utility.getWebServiceEnpoint('USPSAddressValidation')); 
        XmlStreamReader reader = new XmlStreamReader(req);
        USPSConnector.parseError(reader);
        CSW_USPSModel.test(true);

    Test.stopTest();
    	 }
    }
}