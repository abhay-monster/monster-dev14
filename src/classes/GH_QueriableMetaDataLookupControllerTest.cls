@isTest
private class GH_QueriableMetaDataLookupControllerTest {
  static User usr;
  static {
    Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        usr =  TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);
        insert usr;
      }
  static testMethod void testGH_QueriableMetaDataLookupController(){
    system.runAs(usr) {
      Test.startTest();
      GH_QueriableMetaDataLookupController obj = new GH_QueriableMetaDataLookupController();
      obj.queryStr = 'GH_QueriableMetaDataLookupController';
      obj.getResults();
      obj.notQueryStr = 'XYZ';
      obj.getResults();
      Test.stopTest();
    }
  }
}