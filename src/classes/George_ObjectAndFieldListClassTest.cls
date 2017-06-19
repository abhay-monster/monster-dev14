@isTest
private class George_ObjectAndFieldListClassTest {
  static User usr;
  static {
    Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        usr =  TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);
        insert usr;
      }
  static testMethod void testGeorge_ObjectAndFieldListClass(){
    system.runAs(usr) {
      Test.startTest();
      George_ObjectAndFieldListClass obj = new George_ObjectAndFieldListClass();
      Test.stopTest();
    }
  }
}