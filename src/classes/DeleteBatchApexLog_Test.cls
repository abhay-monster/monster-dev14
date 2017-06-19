@isTest
public class DeleteBatchApexLog_Test {
	
	private static testmethod void deleteApexLogTest(){
		
		createTestData(); 
		 
		List<Apex_Log__c> lstApexLog = [SELECT Id FROM Apex_Log__c];
		System.assertEquals(lstApexLog.size(), 5, 'Before starting the batch, 5 record should exists for the Apex log ');
		Test.startTest();
			id batchId = Database.executeBatch(new DeleteBatchApexLog(), 200);
		Test.stopTest();
		lstApexLog = [SELECT Id FROM Apex_Log__c];
		System.assertEquals(lstApexLog.size(), 3, 'After finish the batch, 3 record should exists for the Apex log ');
	}
	
	private static void createTestData(){
		List<ApexLogSettings__c> lstLogSettings = new List<ApexLogSettings__c>();
		ApexLogSettings__c newLogSettings = new ApexLogSettings__c(name='myClass::myMethod',active__c = true, MaxDays__c=0, MaxRecords__c=1);
	    lstLogSettings.add(newLogSettings);
	    ApexLogSettings__c newLogGLobalSettings = new ApexLogSettings__c(name='GlobalActivation',active__c = true, MaxDays__c=0, MaxRecords__c=2);
	    lstLogSettings.add(newLogGlobalSettings);
	    insert lstLogSettings;
	    
	    List<Apex_Log__c> lstApexLogs = new List<Apex_Log__c>();
	    Apex_Log__c savedLog = new Apex_Log__c(class_name__c = 'myClass', method_name__c = 'myMethod', message__c = 'message1');
	    Apex_Log__c savedLog2 = new Apex_Log__c(class_name__c = 'myClass', method_name__c = 'myMethod', message__c = 'message2');
	    Apex_Log__c savedLog3 = new Apex_Log__c(class_name__c = 'myClass', method_name__c = 'myMethod', message__c = 'message3');
	    Apex_Log__c savedLog4 = new Apex_Log__c(class_name__c = 'Global', method_name__c = 'Global', message__c = 'message4');
	    Apex_Log__c savedLog5 = new Apex_Log__c(class_name__c = 'Global', method_name__c = 'Global', message__c = 'message5');
	    lstApexLogs.add(savedLog);
	    lstApexLogs.add(savedLog2);
	    lstApexLogs.add(savedLog3);
	    lstApexLogs.add(savedLog4);
	    lstApexLogs.add(savedLog5);
	    insert lstApexLogs; 
	}

}