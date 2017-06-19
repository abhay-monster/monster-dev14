@isTest
private class AccountLevelUpdateScheduleTest {

 static testMethod void batchProcess(){
        
     Account_Level_Values__c customSetting = new Account_Level_Values__c();
     customSetting = TestDataSetupUtility.buildAccountLevelSetting();
     customSetting.Query__c = 'Select Id, Level__c, Purchasing_Account_Flag__c, ParentId from Account WHERE recordtype.name != \'Person Account\' AND LevelNeedsUpdating__c = true limit 50000';
     insert(customSetting);
     Test.StartTest();
     AccountLevelUpdateSchedule  accountLevelUpdate = new AccountLevelUpdateSchedule();
     String chron = '0 0 23 * * ?';        
     system.schedule('Test Sched', chron, accountLevelUpdate );
     Test.StopTest();
 
 }
}