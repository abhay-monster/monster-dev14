/**
* @description Develop XCode Batch Process . 
* @author Appirio.Inc (JDC)
* @date 05-06-2015
* @last modified 
*/
global class XcodeBatchClass implements Database.Batchable<sObject>{
  global String query;

  global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator('SELECT Xcode__c,Xcode__r.Trusted__c,Xcode__r.CreatedDate FROM XcodeAccount__c Where Xcode__r.CreatedDate < LAST_N_DAYS:20 AND Xcode__r.Trusted__c != \'Y\' AND Account__c IN (Select Account__c From Order__c ord Where ord.CreatedDate < LAST_N_DAYS:20)');
  }  

  global void execute(Database.BatchableContext BC, List<sObject> scope){
      system.debug('Check' + scope);
      map<Id,Xcode__c> xCodes = new map<Id,Xcode__c>();
      For(XcodeAccount__c xcode : (List<XcodeAccount__c>)scope){
          if(String.isBlank(xcode.Xcode__r.Trusted__c) || xcode.Xcode__r.Trusted__c == '?'){
          xCodes.put(xcode.Xcode__c,new Xcode__c(Id = xcode.Xcode__c ,Trusted__c = 'Y' ));
          }
      }  
      update xCodes.values();
      system.debug('Check' + xCodes);
  }
  
  global void finish(Database.BatchableContext BC){
   
  }
    
}