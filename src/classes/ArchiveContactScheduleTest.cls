@isTest
private class ArchiveContactScheduleTest {

  static BatchUser__c batchuser;

  static testMethod void testBatch(){
        User usr = TestDataSetupUtility.createTestUser('Integration','MAPP',UserInfo.getProfileId());
        usr.FirstName =  'Integration';
        usr.LastName =  'MAPP';
        insert usr;

        User usr2 = TestDataSetupUtility.createTestUser('','',UserInfo.getProfileId());
        usr2.FirstName =  'Archiver';
        usr2.LastName =  'Owner';
        insert usr2;

        batchuser = TestDataSetupUtility.createBatchUser(usr2.Id);
        insert batchUser;

        Test.startTest();
        System.runAs(usr){

            Account acc = TestDataSetupUtility.createTestAccount('Test Account', 'North America', UserInfo.getUserId());
            insert acc;
            List<Contact> conList = new List<Contact>();
            conList.add( TestDataSetupUtility.createTestContact(acc.Id, 'PrimaryBillingTestLastnameOne', 'PrimaryBillingTestFirstnameOne', 'email1@testContact.com'));
            conList[0].PrimaryBillingContact__c = true;
            //conList[0].ArchivalStatus__c = null;
            conList[0].ContactStatus__c = 'Inactive' ;
            conList[0].Organization__c  = 'North America';
            conList.add(TestDataSetupUtility.createTestContact(acc.Id, 'PrimaryBillingTestLastnameOne', 'Firstname', 'email2@testContact.com'));
            conList[1].Organization__c  = 'North America';

            // conList[1].ArchivalStatus__c = null;
            conList.add(TestDataSetupUtility.createTestContact(acc.Id, 'PrimaryBillingTestLastnameOne', 'PrimaryBillingTestFirstnameOne', 'email3@testContact.com'));
            //conList[2].ArchivalStatus__c = null;
            insert conList;

            Task t = new Task();
            t.whatId = acc.Id;
            insert t;
            Case cse = new Case(contactID = conList[2].Id);
            insert cse;
            ArchiveContactSchedule batch = new ArchiveContactSchedule ();
            //Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
            String sch = '0 0 5 1 1/4 ?';
            system.schedule('Test ArchiveContactScheduleTest', sch, batch);
        }
        Test.stopTest();
  }



}