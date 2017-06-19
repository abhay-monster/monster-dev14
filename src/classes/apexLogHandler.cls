/***
 *  (c)  Appirio 2009
 *  Author:   Joe Krutulis, Appirio
 *  Purpose:  This class writes error and success logs to the Apex Audit Log object.
 *  Change History:
 ***/ 
 
public with sharing class apexLogHandler { 

  public class For_Testing_Force_Exception extends Exception {}
  
  //public static List<Apex_Log__c> logs = new List<Apex_Log__c>();   
  public static List<apexLogWrapper> lstApexLogWrapper = new List<apexLogWrapper>();
  public static Boolean isSendMail = false;
  
  public static void saveAllLogs() { 
    if (hasLogs()) {
      try {
        for (apexLogWrapper logWrapper : lstApexLogWrapper) {
          stopLogTimes(logWrapper.apex_log);
          if (logWrapper.apex_log.exception_type__c == 'apexLogHandler.For_Testing_Force_Exception') {
            throw new For_Testing_Force_Exception('For testing: all exceptions on logging cannot stop txn & must be caught');
          }
        }
        // Never throw a governor exception while trying to save log records.
        if ((Limits.getLimitDMLStatements() - Limits.getDMLStatements()) > 0 && 
            (Limits.getLimitDMLRows() - Limits.GetDMLRows()) > lstApexLogWrapper.size()) {
          Database.DMLOptions dml = new Database.DMLOptions();
          dml.allowFieldTruncation = true;
          
          List<Apex_Log__c> logs = new List<Apex_Log__c>();
          List<DMLSysException__c> dmlExceptions = new List<DMLSysException__c>();
          String emailBody = '';
          
          for (apexLogWrapper logWrapper : lstApexLogWrapper) {
          	logs.add(logWrapper.apex_log);
          }
          
          Database.insert(logs,dml);
	      	
	      for(apexLogWrapper logWrapper : lstApexLogWrapper){
      		for(DMLSysException__c dmlException : logWrapper.dmlExceptions){
      			dmlException.Apex_Log__c = logWrapper.apex_log.id;
      			dmlExceptions.add(dmlException);
      		}
	      }
          Database.insert(dmlExceptions,dml);
          
          for (apexLogWrapper logWrapper : lstApexLogWrapper) {
          	if(logWrapper.sendEmail){
          		emailBody += 'Apex Log - Record ID : ' + logWrapper.apex_log.Id + '\n';
          		emailBody += JSON.serialize(logWrapper.apex_log) + '\n';
          		if(logWrapper.logDmlExceptions && logWrapper.dmlExceptions.size() > 0){
          			emailBody += 'DML Exceptions :  \n';
          			emailBody += JSON.serialize(logWrapper.dmlExceptions) + '\n';
          		}
          	}
          }
          
          if(String.isNotBlank(emailBody)){	
          	emailLogs(emailBody);
          }
          
        } else {
          system.debug('\n\n>>> ApexAuditLog is hitting DML limits');
          //@TODO consider sendEmail() here
        }
      } catch (Exception ex) {
        System.debug('\n\n>>> ApexAuditLog is swallowing exception on saveLog(): ' + ex);
        //@TODO consider sendEmail() here      
      }
    }
    lstApexLogWrapper = new List<apexLogWrapper>();
  }
  
  public static Boolean hasLogs() {
    return lstApexLogWrapper.size() > 0 ? true : false;
  }

  public static void stopLogTimes(Apex_Log__c log) {
    log.stop_dtm__c = System.now();
    log.stop_ms__c  = System.currentTimeMillis();
  }
  
  public static void emailLogs(String email_Body) {
      
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();    
        mail.setSaveAsActivity(false);
        mail.setTargetObjectId(UserInfo.getUserId());      
        mail.setSubject('Force.com Error Handler');
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setPlainTextBody(email_Body);   
        if (!Test.isRunningTest()) {  
          Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
  }
  
  public class apexLog {
    
    public Apex_Log__c logObj {get;set;}
	public apexLogWrapper logWrapper {get;set;}
	public ApexLogSettings__c currentLogSetting ;
	public System.LoggingLevel currentLoggigLevel;
    
    /* Constructor */
    public apexLog(String classOrTriggerName, String methodName, String msg, System.LoggingLevel loggingLevelVar, String refID) {
      init(classOrTriggerName, methodName, msg, loggingLevelVar, refID);
    }
    
    public apexLog(String classOrTriggerName, String methodName, String msg, System.LoggingLevel loggingLevelVar) {
      init(classOrTriggerName, methodName, msg, loggingLevelVar, null);
    }
    
    public apexLog(String classOrTriggerName, String methodName, String msg) {
      init(classOrTriggerName, methodName, msg, LoggingLevel.DEBUG, null);
    }
    
    public apexLog(String classOrTriggerName, String methodName) {
      init(classOrTriggerName, methodName, null, LoggingLevel.DEBUG, null);
    }
    
    public apexLog(String msg) {
      init(null, null, msg, LoggingLevel.DEBUG, null);
    }
    
    private void init(String classOrTriggerName, String methodName, String msg, System.LoggingLevel loggingLevelVar, String refID){
    	Map<String, ApexLogSettings__c> settings = ApexLogSettings__c.getall();
	    string sig = parseEmptyString(classOrTriggerName) + '::' + parseEmptyString(methodName);
	    logObj = new Apex_Log__c();
	    logObj.class_name__c = parseEmptyString(classOrTriggerName) ;
	    logObj.method_name__c = parseEmptyString(methodName); 
	    logObj.Reference_ID__c = refID;
	    logObj.Message__c = '';
	    if(parseEmptyString(msg) != ''){
	    	logMessage(msg);
	    }
	    startLogTimes();   
	    //to prevent anyone from having to refactor tests out of the gate...
	    if (settings.isEmpty() && test.isRunningTest()){
	    	apexLogWrapper logwrap = new apexLogWrapper();
	    	logwrap.apex_log = logObj;
	    	apexLogHandler.lstApexLogWrapper.add(logwrap);
	    	
	    } else {
	    	if (settings.get('GlobalActivation') != null && settings.get('GlobalActivation').active__c) {
	          if(settings.get(sig) != null){
	          	if (settings.get(sig).active__c) {
	          		initializeLog(settings.get(sig), loggingLevelVar);
	          	}
	          }
	          else{
	          	logObj.class_name__c = 'Global';
	          	logObj.method_name__c = 'Global';
	          	initializeLog(settings.get('GlobalActivation'), loggingLevelVar);
	          }
	       }
	    }	
    }
    
    private void initializeLog(ApexLogSettings__c logSetting, System.LoggingLevel loggingLevelVar){
    	
    	if(logSetting.Log_Level__c ==null){
    		logSetting.Log_Level__c = 4;
    	}
    	
    	currentLogSetting = logSetting;
    	currentLoggigLevel = loggingLevelVar;
    	
    	printDebugMessage(logObj.message__c);

        if(logSetting.Log_Level__c!=null && loggingLevelVar.ordinal() >= logSetting.Log_Level__c ){
            logObj.Log_Type__c = getLoggingLevelName(Integer.valueOf(logSetting.Log_Level__c!=null?logSetting.Log_Level__c:1));        
            
            logWrapper = new apexLogWrapper();
		    logWrapper.apex_log = logObj;
		    logWrapper.logDmlExceptions = logSetting.LogDmlExceptions__c;
		    logWrapper.sendEmail = logSetting.Send_Email__c;
		    logWrapper.dmlExceptions = new List<DMLSysException__c>();
            apexLogHandler.lstApexLogWrapper.add(logWrapper);
        }
    } 
    
    private void printDebugMessage(String msg){
    	
    	if(currentLogSetting != null && currentLoggigLevel != null && currentLogSetting.Activate_System_Logs__c!=null && currentLogSetting.Activate_System_Logs__c){
            if(currentLogSetting.Log_Level__c!=null && currentLoggigLevel.ordinal() >= currentLogSetting.Log_Level__c ){
                System.debug(currentLoggigLevel,msg);                
            } 
        }
    }
    
    private string parseEmptyString(String inputString){
    	return (inputString == null || inputString.trim() == '') ? '' : inputString;
    }

    /* helper methods */
    public void logMessage(String msg) {
      logObj.message__c += msg + '\n';
      printDebugMessage(msg);
    }
    
    public void logDebug(String msg) {
      if(currentLogSetting != null &&  LoggingLevel.DEBUG.ordinal() >= currentLogSetting.Log_Level__c )	{
	      logObj.message__c += msg + '\n';
	      printDebugMessage(msg);
      }
    }
    
    public void logWarn(String msg) {
      if(currentLogSetting != null &&  LoggingLevel.WARN.ordinal() >= currentLogSetting.Log_Level__c )	{
	      logObj.message__c += msg + '\n';
	      printDebugMessage(msg);
      }
    }
    
    public void logError(String msg) {
      if(currentLogSetting != null &&  LoggingLevel.ERROR.ordinal() >= currentLogSetting.Log_Level__c )	{
	      logObj.message__c += msg + '\n';
	      printDebugMessage(msg);
      }
    }

    public void logException(Exception ex) {
      try {
        logObj.exception_cause__c = '' + ex.getCause();
        logObj.message__c += ex.getMessage();
        logObj.exception_type__c = ex.getTypeName();
        logObj.exception_line_Number__c = string.valueOf(ex.getLineNumber());
        logObj.exception_stack_Trace_String__c = ex.getStackTraceString();
        printDebugMessage(ex.getMessage());
        
        if (logWrapper != null && logWrapper.logDmlExceptions == true && ( ex.getTypeName() == 'System.DmlException' || ex.getTypeName() == 'System.EmailException'))
        // if Exception Type = DMLException or EmailException log all DMLExceptions being reported
        {
            DMLSysException__c dmlex;
            for (integer i = 0; i < ex.getNumDml(); i++)
            {
                dmlex = new DMLSysException__c();
                dmlex.DML_Field_Names__c = getFieldNames(ex.getDmlFieldNames(i));
                dmlex.DML_ID__c = ex.getDmlId(i);
                dmlex.DML_Index__c = ex.getDmlIndex(i);
                dmlex.DML_Message__c = getTruncatedSTring(ex.getDmlMessage(i));
                dmlex.DML_Type__c = ex.getDmlType(i).name();
                logWrapper.dmlExceptions.add(dmlex);
            }
        }
      } catch (Exception ex2) {
        System.debug('\n\n>>> ApexAuditLog is swallowing exception on logException(): ' + ex2);
        // An Exception while logging an exception is uglier and more confusing than swallowing the exception
        //consider sendEmail() here
      }
    }

    public void logStatusInfo(Integer statusCode, String statusMessage) {
      logObj.status_code__c = statusCode;
      logObj.status_message__c = statusMessage;
    }

    public void logRequestInfo(String requestInfo) {
      if (logObj.request_info__c == null) logObj.request_info__c = '_';
      logObj.request_info__c += requestInfo + '\n';
      if((logObj.request_info__c).length()>1 && (logObj.request_info__c).indexof('_')==0){
        logobj.request_info__c = (logobj.request_info__c).substring(1);
      }
    }
  
    public void logResponseInfo(String responseInfo) {
      if (logObj.response_info__c == null) logObj.response_info__c = '_';
      logObj.response_info__c += responseInfo + '\n';
      if((logObj.response_info__c).length()>1 && (logObj.response_info__c).indexof('_')==0){
        logobj.response_info__c = (logobj.response_info__c).substring(1);
      }
    }

    private void startLogTimes() {
      logObj.start_dtm__c = System.now();
      logObj.start_ms__c  = System.currentTimeMillis();
    }
   
    public void addLead (Id leadId) {
      logObj.Lead__c = leadId;
    } 
    
    public void saveLogs() {
      apexLogHandler.saveAllLogs();
    }
    
    private String getFieldNames(LIST<String> strings) {
        String fieldnames = '';
        integer i = 0;
        
        for (String fieldname : strings) {
            if ((fieldnames.length() + fieldname.length() + 2) < 32767) {
                fieldnames += fieldname;
                if (i <= strings.size() - 1) fieldnames += ', '; // append a comma if the field name is NOT the last element
                i++;
            }
            else break;
        }
        return fieldnames;
    }
    
    private String getTruncatedString(String s) {
    	   if (s.length() < 32768) return s;
    	   else return String.escapeSingleQuotes(s.substring(0, 32767));
    }
    
    //~Usage : method to give Logging Level (String) by its level in integer
    private String getLoggingLevelName(Integer level){
        if(level == 8){
            return 'NONE';
        }if(level == 7){
            return 'ERROR';
        }else if(level == 6){
            return 'WARN';
        }else if(level == 5){
            return 'INFO';
        }else if(level == 4){
            return 'DEBUG';
        }else if(level == 3){
            return 'FINE';
        }else if(level == 2){
            return 'FINER';
        }else if(level == 1){
            return 'FINEST';
        }
        return 'NONE';
    }
    
  }
  
   public class apexLogWrapper {
   		public Apex_Log__c apex_log {get;set;}
   		public List<DMLSysException__c>	dmlExceptions {get;set;}
   		public Boolean logDmlExceptions {get;set;}
   		public Boolean sendEmail {get;set;}
   }
  
}