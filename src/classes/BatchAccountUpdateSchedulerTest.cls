//
// (c) 2015 Appirio, Inc.
//
//  Test class for BatchAccountUpdateScheduler
//
// Feb 25, 2015     Parul Gupta       Original 
//
@isTest
private class BatchAccountUpdateSchedulerTest {

    static testMethod void testBatchAccountUpdateScheduler() {
        Test.startTest();
   
        String CRON_EXP = '0 0 ' + System.now().hour() + ' * * ?';
       
        // Instance of batch class.
        BatchAccountUpdateScheduler scheduler = new BatchAccountUpdateScheduler();
       
        // Schedule the job
        String jobId = System.schedule('testBasicScheduledApex', CRON_EXP, scheduler);
       
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = : jobId];
       
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
       
        Test.stopTest();    
        
    }
    
    @TestSetup
    static void createTestData(){
        // Create test account
        list<Account> accountList = new list<Account>();
        Account usedAccount = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        accountList.add(usedAccount);
        insert accountList;
        
        Contact con = TestDataSetupUtility.createTestContact(accountList[0].id, 'confirst1', 'conlast1', 'con1@email.com');
        insert con;  
        // Create account order and line item      
        Order__c ord = TestDataSetupUtility.createOrder(accountList[0].id, con.Id);
        insert ord;
        
        Date date1YearAgo = date.newInstance(date.today().year()-1, date.today().month(), date.today().day()-1);
        Order_Line_Item__c orderLine = TestDataSetupUtility.createOrderLineItem(ord.id);
        orderLine.EndDate__c = date1YearAgo;
        insert orderLine;       
    }
}