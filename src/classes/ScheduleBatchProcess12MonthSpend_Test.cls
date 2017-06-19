@isTest
Private Class ScheduleBatchProcess12MonthSpend_Test{
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    static testMethod void testschedule() {
        Test.StartTest();
         String jobId = System.schedule('ScheduleBatchProcess12MonthSpendTest',
                        CRON_EXP, new ScheduleBatchProcess12MonthSpend());         
         // Get the information from the CronTrigger API object
         CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);

    }

}