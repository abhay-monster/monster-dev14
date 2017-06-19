/** 
 */
@isTest(SeeAllData=true)
private class TaskTriggerHandlerTest {

    static testMethod void myUnitTest() {
       
       User u1 = [SELECT Id FROM User WHERE profileId IN (SELECT id FROM Profile WHERE Name = 'System Administrator') AND isActive = TRUE LIMIT 1];
       System.RunAs(u1){
        
        Test.StartTest();
        Account acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        acc.Organization__c = 'Europe';
        acc.Account_Type__c = 'Staffing';

        insert acc;
        System.debug('*******ACCOUNTOWNER' + acc.OwnerId + '********');
        System.debug('*******PRIMARYSALESREPID' + acc.Primary_Sales_Rep_ID__c + '********');

        
        Contact con = TestDataSetupUtility.createTestContact(acc.Id,'First','Last','Test@gmail.com');
        insert con;
        
        
        
        Opportunity opp = new Opportunity(Name='testOpp',AccountId=acc.Id,StageName='Stage 0 - Lead Generation', CloseDate=System.Today());
        insert opp;
        System.debug('======= '+opp.Id);
        
 
        
        
        Task tsk = new Task(Subject='Account Plan Update Due',Priority='High',WhatId=opp.Id, Description='test',CallDisposition = 'Test',WhoId = con.Id);
        
        
        
       
        
        tsk.RecordTypeId = [Select Id From RecordType WHERE Name ='Telemarketing' and SobjectType ='Task'  limit 1].Id;
        insert tsk;
        tsk.Result__c = 'test';
        tsk.CallDisposition = 'Out of Business';
        update tsk;
        //tsk.CallDisposition = 'Do Not Call';
        //tsk.Phone = '1234567';
        update tsk;
        delete tsk;
        Test.stopTest();
        
        
     }   
       
       
    }
}