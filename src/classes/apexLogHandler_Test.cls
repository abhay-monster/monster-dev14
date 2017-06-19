@isTest
public class apexLogHandler_Test {

  public class testException extends Exception{}
  
  public class testCauseException extends Exception{}
  
  private static testmethod void apexLogTest(){
    //@TODO ideal to put these record creations in an environment specific test record utilities class
    Lead newLead = new Lead(LastName = 'AppirioAALTest', Company='AppirioAALTestLead');
    insert newLead;
    ApexLogSettings__c newLogSettings = new ApexLogSettings__c(name='myClass::myMethod',active__c = true, MaxDays__c=90, MaxRecords__c=90000);
    insert newLogSettings;
    ApexLogSettings__c newLogGLobalSettings = new ApexLogSettings__c(name='GlobalActivation',active__c = true, MaxDays__c=90, MaxRecords__c=90000);
    insert newLogGlobalSettings;
    apexLogHandler.apexLog testLog = new apexLogHandler.apexLog('myClass','myMethod', 'myMsg');
    testLog.addLead(newLead.Id);
    testLog.logRequestInfo('outbound WS request'); 
    testLog.logResponseInfo('WS response'); 
    testLog.logStatusInfo(1,'myStatusMsg');
    testLog.saveLogs();
    Apex_Log__c savedLog = [SELECT id,class_name__c,method_name__c, status_code__c, status_Message__c,
                                   start_dtm__c,start_ms__c, stop_dtm__c,stop_ms__c, request_info__c,
                                   response_info__c, Lead__c, Reference_ID__c, message__c
                            FROM Apex_Log__c 
                            WHERE ID = :testLog.logObj.id 
                            LIMIT 1 ];
    System.assertEquals(savedLog.class_name__c,'myClass');
    System.assertEquals(savedLog.method_name__c,'myMethod');
    System.assertEquals(savedLog.Message__c,'myMsg');
    System.assert(savedLog.Lead__c == newLead.Id);
    System.assertEquals(testLog.logObj.start_dtm__c, savedLog.start_dtm__c);
    System.assertEquals(testLog.logObj.start_ms__c, savedLog.start_ms__c);
    System.assertEquals(testLog.logObj.stop_ms__c, savedLog.stop_ms__c);
    System.assertEquals(testLog.logObj.stop_dtm__c, savedLog.stop_dtm__c);
    System.assert(savedlog.stop_ms__c >= savedlog.start_ms__c);
    System.assert(savedLog.request_info__c.contains('outbound WS request'));
    System.assert(savedLog.response_info__c.contains('WS response'));
    System.assertEquals(savedLog.status_code__c, 1);
    System.assert(savedLog.status_Message__c.contains('myStatusMsg'));
  }
  
  private static testmethod void testLoggingExceptions(){
    apexLogHandler.apexLog testLog =  new apexLogHandler.apexLog('myClassName', 'myMethodName','myMsg');
    try {
      testException newTestException = new testException('trigger test exception on save');
      newTestException.initCause(new testCauseException('test exception cause'));
      throw newTestException;
    } catch (Exception e) {
      testLog.logException(e);
    }
    testLog.saveLogs();
    Apex_Log__c savedLog = [SELECT Id, exception_cause__c,Message__c,exception_type__c,
                                   exception_Line_Number__c, exception_Stack_Trace_string__c
                            FROM Apex_Log__c 
                            WHERE ID = :testLog.logObj.id 
                            LIMIT 1];
    system.assert(savedLog.exception_cause__c.contains('test exception cause'),'bad exception cause field');
    System.assert(savedLog.Message__c.contains('trigger test exception on save'),'bad exception message field');
    System.assert(savedLog.exception_type__c.contains('apexLogHandler_Test.testException'),'wrong exception type');
  }
  
  private static testmethod void testLoggingDmlExceptions(){
  	ApexLogSettings__c newLogSettings = new ApexLogSettings__c(name='myClass::myMethod',active__c = true, MaxDays__c=90, MaxRecords__c=90000, LogDmlExceptions__c = true, Send_Email__c = true);
    insert newLogSettings;
    ApexLogSettings__c newLogGLobalSettings = new ApexLogSettings__c(name='GlobalActivation',active__c = true, MaxDays__c=90, MaxRecords__c=90000);
    insert newLogGlobalSettings;
    apexLogHandler.apexLog testLog =  new apexLogHandler.apexLog('myClass', 'myMethod','myMsg');
    testLog.logDebug('DebugMsg');
    testLog.logWarn('WarnMsg');
    testLog.logError('ErrorMsg');
    try {
      Account testAccount = new Account(); 
      insert testAccount; // Insert account without filling required field "Name"
    } catch (Exception e) {
      testLog.logException(e);
    }
    testLog.saveLogs();
    Apex_Log__c savedLog = [SELECT Id, exception_cause__c,Message__c,exception_type__c,
                                   exception_Line_Number__c, exception_Stack_Trace_string__c,
                                    (Select Id From DML_Exceptions__r) 
                            FROM Apex_Log__c 
                            WHERE ID = :testLog.logObj.id 
                            LIMIT 1];
    system.assert(savedLog.DML_Exceptions__r.size() > 0);
  }
  
  private static testmethod void testThrowingExceptionOnSaveLog() {
    apexLogHandler.apexLog testLog = new apexLogHandler.apexLog('myClassName','myMethodName','myMsg', LoggingLevel.DEBUG);
    testLog.logException(new apexLogHandler.For_Testing_Force_Exception('ouch'));
    testLog.saveLogs();
    System.assert(testLog.logObj.id == null, 'This log record should not have been inserted.');
  }
  
  private static testMethod void testThrowingExceptionWhileLoggingException() {
    apexLogHandler.apexLog audit = new apexLogHandler.apexLog('myClass','myMethod','myMsg', LoggingLevel.DEBUG, 'myRefId');
    try {
      audit.logException(null);
      audit.logException(null);
    } catch (Exception e) {
      System.assert(true, 'Logging an exception should never throw another exception');
    }
  }
  
  /***  
  // the Following method takes > 2 secs to run, so use it only if you think there's a governor problem
  private static testMethod void testGovernorExceptionGuardClause() {
    apexLogHandler.apexLog audit = new apexLogHandler.apexLog('myClass','myMethod','myRefId','myMsg');
  
    while ((Limits.getLimitDMLStatements() - Limits.getDMLStatements()) > 0) {
       insert new Apex_Audit_Log__c(class_name__c = 'Temporary Test ' + Crypto.getRandomInteger());
    }
    Apex_Log__c dblog = audit.saveLogs();
    System.assert(dblog.id == null, 'This log record should not have been inserted.');
  }
  ***/
  
}