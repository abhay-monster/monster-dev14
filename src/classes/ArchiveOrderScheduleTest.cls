@isTest
private class ArchiveOrderScheduleTest {

  static BatchUser__c batchuser;

  static testMethod void testBatch(){

        User usr = TestDataSetupUtility.createTestUser('Integration','MAPP',UserInfo.getProfileId());
        usr.FirstName =  'Integration';
        usr.LastName =  'MAPP';
        insert usr;

        User usr2 = TestDataSetupUtility.createTestUser('','',UserInfo.getProfileId());
        usr2.FirstName =  'Archive';
        usr2.LastName =  'Owner';
        insert usr2;

        batchuser = TestDataSetupUtility.createBatchUser(usr2.Id);
        insert batchUser;

        Test.startTest();
        System.runAs(usr){

         Account acc = TestDataSetupUtility.createTestAccount('Test Account', 'North America', UserInfo.getUserId());
        insert acc;
        Contact con = TestDataSetupUtility.createTestContact(acc.Id, 'PrimaryBillingTestLastnameOne', 'PrimaryBillingTestFirstnameOne', 'email1@testContact.com');
        con.PrimaryBillingContact__c = true;
        con.ArchivalStatus__c = '';
        con.ContactStatus__c = 'Inactive' ;
        con.Organization__c  = 'North America';
        insert con;


        Order__c test_Order = new Order__c (
        Account__c = acc.Id,
        OrderDate__c = system.today()

        );

        insert test_Order;

        Order__c test_Order2 = new Order__c (
        Account__c = acc.Id,
        OrderDate__c = system.today().addyears(-4)

        );

        insert test_Order2;

        Order_Line_Item__c test_OrderLineItem = new Order_Line_Item__c (
        Order__c = test_Order.Id

        );

        insert test_OrderLineItem;

        ArchiveOrderSchedule batch = new ArchiveOrderSchedule();
        String sch = '0 0 5 1 1/4 ?';
        system.schedule('Test Check', sch, batch);
        }
        Test.stopTest();
  }
}