@isTest
public with sharing class SalesQuotaTriggerHelper_Test {
  static testMethod void testBeforeInsertSQuotaContact(){
        String profileId = TestDataSetupUtility.PROFILE_ID;
        User usedUser = TestDataSetupUtility.createTestUser('Test First Name', 'Test Last Name', profileId );
        usedUser.Status__c = 'Active';        
        usedUser.Division__c = 'A-J Regional';
        usedUser.PositionSalesGroup__c = 'Acquisition'; 
        usedUser.PositionSalesChannel__c = 'Campus Consumer'; 
        usedUser.UserPositionRegion__c = 'Canada';
        insert usedUser;
        
        Test.startTest();
        Sales_Quotas__c sq = TestDataSetupUtility.createTestSalesQuota(usedUser.Id);
        insert sq;  
        
        // Verify that sales quota fields are populated or not
        sq = [ SELECT Id,Division__c,Status__c  FROM Sales_Quotas__c  WHERE Id = :sq.Id ];
        //usedUser  = [SELECT Id,Division__c ,Status__c FROM User WHERE Id = :userUser.Id];
        
        System.assertEquals(sq.Status__c , usedUser.Status__c );
        System.assertEquals(sq.Division__c , usedUser.Division__c );
        
        sq.Location__c = 'TW-Philippines'; 
        update sq;
        
        delete sq;
        
        undelete sq; 
            
        Test.stopTest();
    } 
}