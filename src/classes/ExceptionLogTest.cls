@isTest
private class ExceptionLogTest {

    static testMethod void test_ExceptionLog_add() {
        
        ExceptionLog.add('Class','TestObject', 'TestFunction','TestException');
        
        list<ExceptionLog__c> exceptionLogList = [SELECT Id, Name, Exception__c, FunctionName__c, ObjectName__c, TypeOfException__c FROM ExceptionLog__c WHERE ObjectName__c = 'TestObject'];
        
        system.assertEquals(exceptionLogList[0].Exception__c, 'TestException');
        system.assertEquals(exceptionLogList[0].FunctionName__c, 'TestFunction');
        system.assertEquals(exceptionLogList[0].ObjectName__c, 'TestObject');
        system.assertEquals(exceptionLogList[0].TypeOfException__c, 'Class');
    } 
}