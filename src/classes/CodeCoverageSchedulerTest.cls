@isTest
public class CodeCoverageSchedulerTest {
	private static String CRON_EXP = '0 0 0 3 9 ? 2022';
    
    static testmethod void testCodeCoverageScheduler() {
        Test.startTest();
        String jobId = System.schedule('testCodeCoverageScheduler',CRON_EXP,
	         new CodeCoverageScheduler());
        // Get the information from the CronTrigger API object
      	CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
         FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same
      System.assertEquals(CRON_EXP,ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run
      System.assertEquals('2022-09-03 00:00:00', 
         String.valueOf(ct.NextFireTime));
      Test.stopTest();
    }

        static testmethod void testCodeCoverageStatus() {
        Test.startTest();
        String jobId = System.schedule('testCodeCoverageStatus',CRON_EXP,
	         new CodeCoverageStatusScheduler());
        // Get the information from the CronTrigger API object
      	CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
         FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same
      System.assertEquals(CRON_EXP,ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run
      System.assertEquals('2022-09-03 00:00:00', 
         String.valueOf(ct.NextFireTime));
      Test.stopTest();
    }
    
}