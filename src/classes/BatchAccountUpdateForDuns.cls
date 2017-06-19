global  class BatchAccountUpdateForDuns implements Database.Batchable<sObject>{
    //implement Star Method
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([Select Id, DunsNumber from Account where DunsNumber != null and CleanStatus = 'NotFound']); 
    }
    //Implement Execute Method
    global void execute(Database.BatchableContext BC, List<Account> aList){
        
        Set<Id> AccountIdSet = new Set<Id>();
        for(Account a: aList){ 
                a.DunsNumber = null;  
        }
       
        Database.SaveResult[] srList = Database.Update(aList, false);
         
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully updated account. Account ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                }
            }
        }
    }
    
    //Implement Finish Method
    global void finish(Database.BatchableContext BC){
    }
}