@isTest
private class ContactTriggerTest {

  static final Integer BULK_RECORD_LIMIT = 100;
  static final String SOBJECT_TASK = 'Task';
  static final String TASK_RECORD_TYPE_ACTION_PLAN_EVENT = 'Action Plan';
  static final Datetime SYSTEM_CURRENT_TIME = System.now().addSeconds(300);
  static final Map<String, Map<String, Id>> RECORD_TYPES = Utility.GetRecordTypeIdsBySObjectNameSet(new set<String>{SOBJECT_TASK});
  static Personal_Settings__c personalSettings;
  static IntegrationConfig__c integConfigSettings;
  static WebServiceEndpoint__c wsEndpoint;
  static List<Contact> contactList;
  static AccountContactAssociation__c accountAsso;
  static Account testacc1 = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TEST AB Account');
  static User testuser;
  static Contact testContact1 = TestDataSetupUtility.createTestContact(testacc1.Id, 'PrimaryBillingTestLastnameOne', 'PrimaryBillingTestFirstnameOne', 'email1@testContact.com');
  static Contact testContact2 = TestDataSetupUtility.createTestContact(testacc1.Id, 'PrimaryBillingTestLastnameTwo', 'PrimaryBillingTestFirstnameTwo', 'email2@testContact.com');
  static Account acctRelated  = TestDataSetupUtility.createTestAccountWithShipping('Test RelatedACCOUNT');

  static {
  
      Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
      testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
      insert testuser;

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
              
      testacc1.AgencyFlag__c = true;
      insert testacc1 ;
        
      accountAsso = new AccountContactAssociation__c(PrimarySalesContact__c = false,Account__c = testacc1.id);
      insert accountAsso;     

      insert acctRelated;

      contactList = new List<Contact>();     

  }

  static testMethod void onBeforeInsertTest() {
      
        testContact2.PrimaryBillingContact__c = false;
        testContact2.Role__c = 'Agency';
        testContact2.PrimarySalesContact__c = true;
        testContact2.PrimaryServiceContact__c = true;
        testContact2.MAPPOwner__c = testuser.id;
        contactList.add(testContact2);
        
        /*Contact testContact = TestDataSetupUtility.createTestContact(testacc1.Id, 'PrimaryBillingTest', 'PrimaryBillingTest', 'email1@testContact.com');
        testContact.PrimaryBillingContact__c = true;
        contactList.add(testContact);
        */
       

        try {
          accountAsso = new AccountContactAssociation__c(PrimarySalesContact__c = true,Account__c = testacc1.id);
          insert accountAsso;
          insert contactList;
        }
        catch(Exception e){
          System.debug(e.getMessage());
          System.assert(e.getMessage().contains('There is an existing Primary Sales Contact for the selected account.'));
        }
  }

  static testMethod void onAfterInsertTest() {
        
        testContact2.PrimaryBillingContact__c = false;
        testContact2.Role__c = 'Agency';
        testContact2.PrimarySalesContact__c = true;
        testContact2.PrimaryServiceContact__c = true;
        testContact2.MAPPOwner__c = testuser.id;
        contactList.add(testContact2);
        
        /*Contact testContact = TestDataSetupUtility.createTestContact(testacc1.Id, 'PrimaryBillingTest', 'PrimaryBillingTest', 'email1@testContact.com');
        testContact.PrimaryBillingContact__c = true;
        contactList.add(testContact);
        */

        Account acct = TestDataSetupUtility.createTestAccountWithShipping('Test ACCOUNT');
        insert acct;

        

        RelatedPartner__c testRelatedPartner = new RelatedPartner__c();
        testRelatedPartner.Account__c = acctRelated.id;
        testRelatedPartner.Partner__c = testacc1.id;
        testRelatedPartner.AgencyType__c  = 'Billing';
        testRelatedPartner.Role__c = 'Agency';
        insert testRelatedPartner;

    
        // Account = new Account('New Account');
        //acctRelated.ParentId = testacc1.id;
        acctRelated.Primary_Agency_Contact__c = contactList[0].id;
        acctRelated.PrimaryRelatedAgency__c = testRelatedPartner.id;
        //acctRelated.AgencyFlag__c = true;

        update acctRelated;

        try {
          accountAsso = new AccountContactAssociation__c(PrimarySalesContact__c = false,Account__c = testacc1.id);
          insert accountAsso;
          insert contactList;
        }
        catch(Exception e){
          System.debug(e.getMessage());
          System.assert(e.getMessage().contains('There is an existing Primary Sales Contact for the selected account.'));
        }

  }


  static testMethod void onBeforeUpdateTest() {

        testContact2.PrimaryBillingContact__c = false;
        testContact2.Role__c = 'Agency';
        testContact2.PrimarySalesContact__c = true;
        testContact2.PrimaryServiceContact__c = true;
        testContact2.MAPPOwner__c = testuser.id;
        contactList.add(testContact2);
    
        testContact1.PrimaryBillingContact__c = false;
        testContact1.Role__c = 'Agency';
        testContact1.PrimarySalesContact__c = false;
        testContact1.PrimaryServiceContact__c = true;
        testContact1.MAPPOwner__c = testuser.id;
        contactList.add(testContact1);

        try {
          accountAsso = new AccountContactAssociation__c(PrimarySalesContact__c = true,Account__c = testacc1.id);
          insert accountAsso;
          insert contactList;
          testContact1.PrimarySalesContact__c = true;
          update testContact1;
        }
        catch(Exception e){
          System.debug(e.getMessage());
          System.assert(e.getMessage().contains('There is an existing Primary Sales Contact for the selected account.'));
        }

}
  


    

  static testMethod void onDeleteTest() {

      Contact testContact3 = TestDataSetupUtility.createTestContact(testacc1.Id, 'PrimaryBillingTestLastnameThree', 'PrimaryBillingTestFirstnameThree', 'email3@testContact.com');
      testContact3.PrimarySalesContact__c = true;
      contactList.add(testContact3);
      insert contactList;

      Account acct = TestDataSetupUtility.createTestAccountWithShipping('Test ACCOUNT');
        insert acct;

        
        RelatedPartner__c testRelatedPartner = new RelatedPartner__c();
        testRelatedPartner.Account__c = acctRelated.id;
        testRelatedPartner.Partner__c = testacc1.id;
        testRelatedPartner.AgencyType__c  = 'Billing';
        testRelatedPartner.Role__c = 'Agency';
        insert testRelatedPartner;

    
        // Account = new Account('New Account');
        //acctRelated.ParentId = testacc1.id;
        acctRelated.Primary_Agency_Contact__c = contactList[0].id;
        acctRelated.PrimaryRelatedAgency__c = testRelatedPartner.id;
        //acctRelated.AgencyFlag__c = true;

        update acctRelated;
        
      delete contactList;

    

  } 
  
}    

  // @description: a test method that validate the batch functionality
  // @param: none
  // @return: void
  // @author: Sudhir Kumar Jagetiya
 /* static testMethod void validateBatch() {

    Account account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
    insert account;

    Test.startTest();
      Contact contact = TestDataSetupUtility.createTestContact(account.Id, 'Test Last Name', 'Test First Name', 'test@gmail.com');
      insert contact;

      contact.PrimarySalesContact__c = true;
      update contact;

      delete contact;

      undelete contact;

      Personal_Settings__c setting = new Personal_Settings__c(Trigger_Contact__c = true);
      insert setting;

      List<Contact> contactList = new List<Contact>();
      for(Integer index = 0; index < BULK_RECORD_LIMIT; index++) {
        contactList.add(TestDataSetupUtility.createTestContact(account.Id, 'Test Last Name' + index, 'Test First Name', 'test' + index + '@gmail.com'));
      }
      insert contactList;

      for(Contact con : contactList) {
        con.PrimarySalesContact__c = true;
        con.PrimaryServiceContact__c = true;
      }
      update contactList;

      delete contactList;

      undelete contactList;
  
      ContactTriggerHandler.isRunningTest = true;
      Contact contact2 = TestDataSetupUtility.createTestContact(account.Id, 'Test Last Name', 'Test First Name', 'test@gmail.com');
      try{
        insert contact2;
      } catch(Exception e){
        system.assert(e.getMessage().contains('Test Method Error!'));
      }
       try{
        update contact;
      } catch(Exception e){
        system.assert(e.getMessage().contains('Test Method Error!'));
      }
       try{
        delete contact;
      } catch(Exception e){
        system.assert(e.getMessage().contains('Test Method Error!'));
      }
      ContactTriggerHandler.isRunningTest = false;
      delete contact;
      ContactTriggerHandler.isRunningTest = true;
       try{
        undelete contact;
      } catch(Exception e){
        system.assert(e.getMessage().contains('Test Method Error!'));
      }
      

    Test.stopTest(); */