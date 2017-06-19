global class DeleteBatchApexLog implements Database.Batchable<SObject>, Database.Stateful, Schedulable {

 /*** Class to delete old Integration log messages.
        Created By : Appirio Hackathon 2012
  ***/
  private Map<String, ApexLogSettings__c> logSettings = ApexLogSettings__c.getall();
  private List<String> lstLogSettingNames = new List<String>();
  private ApexLogSettings__c settingToProcess ;
  private Set<String> apexLogShouldBeKept = new Set<String>();
  
  public DeleteBatchApexLog(){
  	if(logSettings.containsKey('GlobalActivation')){
  		settingToProcess = logSettings.get('GlobalActivation'); 
  		for(String key : logSettings.keyset()){
  			if(key != 'GlobalActivation'){
  				lstLogSettingNames.add(key);
  			}
  		}
  	}
  }
  
  public DeleteBatchApexLog(List<String> logSettingNames){
  	if(logSettingNames != null && logSettingNames.size() > 0){
  		String settingName = logSettingNames[0];
  		settingToProcess = logSettings.get(settingName);
  		logSettingNames.remove(0); 
  		lstLogSettingNames.clear();
  		lstLogSettingNames.addAll(logSettingNames);
  	}
  }

  /*** SCHEDULEABLE INTERFACE Methods ***/
  global void execute(SchedulableContext sc) {
    id batchId = Database.executeBatch(new DeleteBatchApexLog(), 200);
    System.debug('\n\n==> batchId = ' + batchId); 
  }

  /*** BATCHABLE INTERFACE Methods ***/
  global Database.QueryLocator start(Database.BatchableContext context) {
      
      if(logSettings.size() > 0){
      	String query = '';
      	if(settingToProcess != null){
  			query = 'SELECT Id, class_name__c, method_name__c, CreatedDate  FROM Apex_Log__c WHERE ';
  			query += settingToProcess.Name == 'GlobalActivation' ? ' Access_Key__c NOT IN : lstLogSettingNames' : 'Access_Key__c = \'' + settingToProcess.Name + '\'';
  			query += ' ORDER BY CreatedDate DESC';
      	}
      	Database.QueryLocator ans = Database.getQueryLocator(query);
      	return ans;
      }
      return null;      
  }

  global void execute(Database.BatchableContext context, List<SOBject> objects) {
    
    
    if(objects != null && objects.size() > 0 && settingToProcess != null){
    	List<Apex_Log__c> logList = new List<Apex_Log__c>();
		for(SObject sobj: objects) {
			Apex_Log__c integrationLog = (Apex_Log__c)sobj;
			if(apexLogShouldBeKept.size() < settingToProcess.MaxRecords__c ){
				apexLogShouldBeKept.add(integrationLog.id);
			}
			else{
				if(integrationLog.CreatedDate < Datetime.now().addDays(-Integer.valueOf(settingToProcess.MaxDays__c))){
			      	logList.add(integrationLog);
			     }
			}
		}
		if(logList.size() > 0){
			delete logList;
	    	Database.emptyRecycleBin(logList);
		}
    }
  }

  global void finish(Database.BatchableContext context) {
  	if(lstLogSettingNames.size() > 0){
	  	id batchId = Database.executeBatch(new DeleteBatchApexLog(lstLogSettingNames), 200);
	    System.debug('\n\n==> batchId = ' + batchId);
  	}
  }

}