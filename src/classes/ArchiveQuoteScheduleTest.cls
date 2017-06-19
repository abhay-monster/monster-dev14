@isTest
private class ArchiveQuoteScheduleTest {

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

        Apttus_Proposal__Proposal__c quote = new Apttus_Proposal__Proposal__c();
        insert quote;

        ArchiveQuoteSchedule batch = new ArchiveQuoteSchedule();
        String sch = '0 0 23 * * ?';
        system.schedule('Test Check', sch, batch);
        }
        Test.stopTest();
  }
}