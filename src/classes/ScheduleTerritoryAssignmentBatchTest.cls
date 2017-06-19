/***********************************************************************************************************
 * Appirio, Inc
 * Name         : ScheduleTerritoryAssignmentBatchTest
 * Created By   : Rohit B. (Appirio)
 * Purpose      : Test class of ScheduleTerritoryAssignmentBatchClass
 * Created Date : 30/Oct/2015
 *
 * Date Modified                Modified By             Description of the update
 * [Date]                       [Person Name]           [Short Description]
 **********************************************************************************************************/
@isTest
private class ScheduleTerritoryAssignmentBatchTest {
	
	@isTest 
	static void test_method1() {
		PageReference pageRef = Page.ScheduleTerritoryAssignmentBatch;
    	Test.setCurrentPage(pageRef);
    	ScheduleTerritoryAssignmentBatchClass ctrlSTAB = new ScheduleTerritoryAssignmentBatchClass();
    	ctrlSTAB.scheduleOption = 'Now';
    	ctrlSTAB.scheduleAndRedirect();
    	System.assertEquals(ctrlSTAB.btnName, 'Abort');
    	ctrlSTAB.scheduleAndRedirect();
    	System.assertEquals(ctrlSTAB.btnName, 'Schedule');
    	ctrlSTAB.scheduleOption = 'Later';
    	ctrlSTAB.scheduleAndRedirect();
    	ctrlSTAB.minToSchedule = 0;
    	ctrlSTAB.scheduleAndRedirect();
    	ctrlSTAB.minToSchedule = 50;
    	ctrlSTAB.scheduleAndRedirect();
    	System.assertEquals(ctrlSTAB.btnName, 'Abort');
    	ctrlSTAB.btnName = 'Schedule';
    	ctrlSTAB.scheduleAndRedirect();
    	System.assertEquals(ctrlSTAB.btnName, 'Abort');
    	ScheduleTerritoryAssignmentBatchClass ctrlSTAB1 = new ScheduleTerritoryAssignmentBatchClass();
    	ctrlSTAB1.scheduleAndRedirect();
    	System.assertEquals(ctrlSTAB1.btnName, 'Schedule');
    	ctrlSTAB1.Cancel();
	}
}