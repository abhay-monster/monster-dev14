/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class EventTriggerTest {

    static testMethod void myUnitTest() {
        Account testAcc = TestDataSetupUtility.createTestAccountWithShipping('Test Account');
        testAcc.Phone = '4353453345';
        insert testAcc;
        Contact testCon = TestDataSetupUtility.createTestContact(testAcc.Id, 'Test Last', 'Test First', 'test@test.com');
        testCon.Phone = '3533252332';
        testCon.JobPosition__c = 'Test Position';
        testCon.ContactType__c = 'Test Type';
        insert testCon;
        
        Profile_Permissions__c p = Profile_Permissions__c.getInstance(Userinfo.getProfileId());
        p.Delete_Activities__c = true;
        update p;
        
        
        /*Event evnt = new Event(WhoId = testCon.Id);
        evnt.DurationInMinutes = 20;
        evnt.ActivityDateTime = Datetime.now();
        insert evnt;
        
        evnt.Subject = 'Update event';
        update evnt;
        
        Personal_Settings__c ps = Personal_Settings__c.getInstance(Userinfo.getProfileId());
        ps.Trigger_Activity__c = false;
        update ps;*/
        
        
        Event evnt2 = new Event(WhoId = testCon.Id);
        evnt2.DurationInMinutes = 20;
        try{
            insert evnt2;
        }catch(Exception ex){
            evnt2.ActivityDateTime = Datetime.now() + 20;
            insert evnt2;
        }
        
        try{
            evnt2.Subject = 'Update event';
            evnt2.ActivityDateTime = null;
            update evnt2;
        }catch(Exception ex){
            evnt2.Subject = 'Update event';
            evnt2.ActivityDateTime = Datetime.now() + 20;
            update evnt2;
        }
        
        delete evnt2;
    }
    
    static testMethod void testupdateEventValidSalesActivityonAccount() {

        Account testAcc = TestDataSetupUtility.createTestAccountWithShipping('Test Account');
        testAcc.Phone = '4353453345';
        insert testAcc;
        Contact testCon = TestDataSetupUtility.createTestContact(testAcc.Id, 'Test Last', 'Test First', 'test@test.com');
        testCon.Phone = '3533252332';
        testCon.JobPosition__c = 'Test Position';
        testCon.ContactType__c = 'Test Type';
        insert testCon;
        
        Profile_Permissions__c p = Profile_Permissions__c.getInstance(Userinfo.getProfileId());
        p.Delete_Activities__c = true;
        update p;

        ID ACTION_PLAN_EVENT = Schema.SObjectType.Event.RecordTypeInfosByName.get('Action Plan Event').RecordTypeId;
        Event evnt2 = new Event(WhoId = testCon.Id);
        evnt2.Valid_Sales_Activity__c = true;
        evnt2.DurationInMinutes = 20;        
        try{
            insert evnt2;
        }catch(Exception ex){
            evnt2.ActivityDateTime = Datetime.now() + 20;
            insert evnt2;
        }
        
        Event evnt3 = new Event(WhoId = testCon.Id,WhatId=testAcc.Id);
        evnt3.Valid_Sales_Activity__c = true;
        evnt3.RecordTypeId = ACTION_PLAN_EVENT;
        evnt3.DurationInMinutes = 20;        
        try{
            insert evnt3;
        }catch(Exception ex){
            evnt3.ActivityDateTime = Datetime.now() + 20;
            insert evnt3;
        }
        
        

    }

}