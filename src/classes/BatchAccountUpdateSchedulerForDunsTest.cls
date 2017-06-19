//
// (c) 2015 Appirio, Inc.
//

@isTest
private class BatchAccountUpdateSchedulerForDunsTest {

    static testMethod void testBatchAccountUpdateScheduler() {
        Test.startTest();
   
        String CRON_EXP = '0 0 ' + System.now().hour() + ' * * ?';
       
        // Instance of batch class.
        BatchAccountUpdateForDunsScheduler scheduler = new BatchAccountUpdateForDunsScheduler();
       
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
        usedAccount.DunsNumber = '12345';
        usedAccount.CleanStatus = 'NotFound';
        accountList.add(usedAccount);
        insert accountList;
     
    }
}