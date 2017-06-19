@isTest
private class BatchKnowledgeGlobalReplaceTest {

	static testMethod void runPositiveTestCase() {
		KB_Global_Search_And_Replace__c kbgsr = new KB_Global_Search_And_Replace__c();
		kbgsr.Apex_BatchId__c = 'Test1';
		insert kbgsr ;
		Test.startTest();
		BatchKnowledgeGlobalReplace batch = new BatchKnowledgeGlobalReplace('Test1');
		Id batchId = Database.executeBatch(batch, 500); 
        System.assertNotEquals(batchId, null);        
		Test.stopTest();
		
	}
}