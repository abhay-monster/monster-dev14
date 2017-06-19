/*
** @author : Cloud Sherpas Inc.
** @date : 04/23/2014
** @description :   a test class for User trigger
*/
@isTest
public class UserTriggerHelperTest {
  static testMethod void testUserAfterUpdateContact(){
        
        System.runAs(new User(Id=UserInfo.getUserId())) { 
        
        Test.startTest();
        String profileId = TestDataSetupUtility.PROFILE_ID;
        User usedUser = TestDataSetupUtility.createTestUser('Test First Name', 'Test Last Name', profileId );
        usedUser.Status__c = 'Active';
        usedUser.Location__c = 'TW-Philippines'; 
        usedUser.Division__c = 'A-J Regional';
        usedUser.PositionSalesGroup__c = 'Acquisition'; 
        usedUser.PositionSalesChannel__c = 'Campus Consumer'; 
        usedUser.UserPositionRegion__c = 'Canada';
        usedUser.Phone = '4567898765';
        
        insert usedUser;
        
        Sales_Quotas__c sq = TestDataSetupUtility.createTestSalesQuota(usedUser.Id);
        insert sq; 
        MonsterPhoneList__c test_MonsterPhoneList = new MonsterPhoneList__c (
            UserPhone__c = '3456789876',
            User_Name__c = 'test value'
        );
        Id usertest = [Select id From User Where Id=: usedUser.id].Id;
        test_MonsterPhoneList.UserId__c = Id.valueOf(usertest);
        insert test_MonsterPhoneList;
        //Test.startTest();   
        usedUser.PositionSalesChannel__c = 'ZA.Telesales';
        usedUser.UserPositionRegion__c = 'Florence';
        usedUser.Organisation__c = 'Europe';
        usedUser.DefaultCurrencyIsoCode = 'USD';
        usedUser.Title = 'Test Master';
        update usedUser;
              
        Test.stopTest();
        }
    } 
}