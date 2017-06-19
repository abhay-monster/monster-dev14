/*
** @author : Cloud Sherpas Inc.
** @date : 04/28/2014
** @description : Sales Attinment Trigger for all CRUD events. 
*/
@isTest
private class SalesAttainmentTriggerTest {
    static testMethod void myUnitTest() {
        String profileId = TestDataSetupUtility.PROFILE_ID;
        User usedUser = TestDataSetupUtility.createTestUser('Test First Name', 'Test Last Name', profileId );
        usedUser.Status__c = 'Active';
        usedUser.Location__c = 'TW-Philippines'; 
        usedUser.Division__c = 'A-J Regional';
        usedUser.PositionSalesGroup__c = 'Acquisition'; 
        usedUser.PositionSalesChannel__c = 'Campus Consumer'; 
        usedUser.UserPositionRegion__c = 'Canada';
        insert usedUser;
        
        
        Sales_Quotas__c sq = TestDataSetupUtility.createTestSalesQuota(usedUser.Id);
        insert sq;  
        
        Sales_Attainment__c sa = TestDataSetupUtility.createTestSalesAttainment(sq.Id);
        insert sa;      
        
        update sa;
        
        delete sa;
        
        undelete sa;
    } 
}