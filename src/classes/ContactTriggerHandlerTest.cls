@isTest
private class ContactTriggerHandlerTest {
  static Personal_Settings__c personalSettings;
  static IntegrationConfig__c  integConfigSettings;
  static WebServiceEndpoint__c wsEndpoint;
  static Account testAccount;
  static List<Contact> contactList;
  
  public static testMethod void testContactTriggerHandler(){
    createTestData();
      Account account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        insert account;
      ContactTriggerHandler.throwTestBAEException = true;
      Test.startTest();
        Contact contact2 = TestDataSetupUtility.createTestContact(account.Id, 'Test Last Name', 'Test First Name', 'test@gmail.com');
        //try{
          insert contact2;
        //} catch(Exception e){
          //system.assert(e.getMessage().contains('Test Method Error!'));
        //}
         try{
          update contactList;
         } catch(Exception e){
          system.assert(e.getMessage().contains('Primary Sales Contact has already been set for an Account'));
         }
         //try{
          //delete contactList;
        //} catch(Exception e){
          //system.assert(e.getMessage().contains('Test Method Error!'));
        //}
        ContactTriggerHandler.throwTestBAEException = false;
        ContactTriggerHandler.throwTestException = true;
        contact2 = TestDataSetupUtility.createTestContact(account.Id, 'Test Last Name', 'Test First Name', 'test@gmail.com');
        try{
          insert contact2;
        } catch(Exception e){
          system.assert(e.getMessage().contains('creating a duplicate record. We recommend you use an existing record instead'));
        }
         //try{
          //update contactList;
        //} catch(Exception e){
          //system.assert(e.getMessage().contains('A problem has occurred & processing cannot complete successfully'));
        //}
         //try{
          //delete contactList;
        //} catch(Exception e){
         // system.assert(e.getMessage().contains('A problem has occurred & processing cannot complete successfully'));
        //}
        ContactTriggerHandler.throwTestException = false;
        ContactTriggerHandler.throwTestBAEExceptionAfter = true;
        //contact2 = TestDataSetupUtility.createTestContact(account.Id, 'Test Last Name', 'Test First Name', 'test@gmail.com');
        //try{
          //insert contact2;
        //} catch(Exception e){
          //system.assert(e.getMessage().contains('Test Method Error!'));
        //}
         //try{
          //update contact2;
        //} catch(Exception e){
          //system.assert(e.getMessage().contains('Test Method Error!'));
        //}
         //try{
          //delete contact2;
        //} catch(Exception e){
          //system.assert(e.getMessage().contains('Test Method Error!'));
        //}

        ContactTriggerHandler.throwTestBAEExceptionAfter = false;
        ContactTriggerHandler.throwTestExceptionAfter = true;
        contact2 = TestDataSetupUtility.createTestContact(account.Id, 'Test Last Name', 'Test First Name', 'test@gmail.com');
        //try{
          //insert contact2;
        //} catch(Exception e){
          //system.assert(e.getMessage().contains('A problem has occurred & processing cannot complete successfully'));
        //}
         //try{
          //update contactList;
        //} catch(Exception e){
          //system.assert(e.getMessage().contains('A problem has occurred & processing cannot complete successfully'));
        //}
         //try{
          //delete contactList;
        //} catch(Exception e){
          //system.assert(e.getMessage().contains('A problem has occurred & processing cannot complete successfully'));
        //}
        Test.stopTest();
  }

private static void createTestData(){
    //try{
        personalSettings = TestDataSetupUtility.buildPersonalSetting();
            personalSettings.Trigger_Contact__c = true;
            insert personalSettings;

            integConfigSettings = new IntegrationConfig__c(Name ='USPS Integration', 
                                                                Timeout__c=60000,
                                                                IsPaypalTest__c=true,
                                                                EndpointName__c='USPSAddressValidation',
                                                                Username__c='562CLOUD2615');
            insert integConfigSettings;

            wsEndpoint = new WebServiceEndpoint__c(Name='USPSAddressValidation', Endpoint__c='http://production.shippingapis.com/ShippingAPI.dll');
            insert wsEndpoint;

            Account testAccount1 = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TEST AB Account');
            testAccount1.Phone = '+18008008001';
            testAccount1.BillingCountry = 'Norway';
            testAccount1.AgencyFlag__c = true;
            insert testAccount1;

            testAccount = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TEST PB Account');//, 'North America', UserInfo.getUserId());
            testAccount.Phone = '+18008008000';
            testAccount.BillingCountry = 'Philippines';

            insert testAccount;

            RelatedPartner__c testRelatedPartner = new RelatedPartner__c();
             testRelatedPartner.Account__c = testAccount.id;
             testRelatedPartner.Partner__c = testAccount1.id;
             testRelatedPartner.AgencyType__c = 'Billing';
             insert testRelatedPartner;

            

            contactList = new List<Contact>();
            Contact testContact1 = TestDataSetupUtility.createTestContact(testAccount.Id, 'PrimaryBillingTestLastnameOne', 'PrimaryBillingTestFirstnameOne', 'email1@testContact.com');
            testContact1.PrimaryBillingContact__c = true;
            //testContact1.PrimarySalesContact__c = true;
             //testContact1.PrimaryServiceContact__c = true; 
            //insert testContact1;
            //contactList.add(testContact1);

            Contact testContact2 = TestDataSetupUtility.createTestContact(testAccount.Id, 'PrimaryBillingTestLastnameTwo', 'PrimaryBillingTestFirstnameTwo', 'email2@testContact.com');
            testContact2.PrimaryBillingContact__c = true;
            contactList.add(testContact2);
            

            Contact testContact3 = TestDataSetupUtility.createTestContact(testAccount.Id, 'PrimaryBillingTestLastnameThree', 'PrimaryBillingTestFirstnameThree', 'email3@testContact.com');
            testContact3.PrimaryBillingContact__c = false;
            contactList.add(testContact3);
              insert contactList;

              //Contact con = contactList[0];
              //contactList[0].PrimarySalesContact__c = true;
             contactList[0].PrimaryServiceContact__c = true;
            //contactList[0].PrimaryBillingContact__c = false;
            //update con;

           
  }
}