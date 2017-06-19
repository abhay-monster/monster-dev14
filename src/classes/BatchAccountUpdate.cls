global  class BatchAccountUpdate implements Database.Batchable<sObject>{
    //implement Star Method
    global Database.QueryLocator start(Database.BatchableContext BC){
        //Date date1YearAgo = date.newInstance(date.today().year()-1, date.today().month(), date.today().day());
        //String query = 'SELECT Id, LatestProductEndDate__c, AccountStatus__c, CustomerLapsedDate__c FROM Account WHERE AccountStatus__c!= \'Fraud\' AND AccountStatus__c!= \'Out of Business\' AND LatestProductEndDate__c <' + String.ValueOf(date1YearAgo); // AND Id = \'0011100000ZVwXo\'';
        //String query = 'SELECT Id, LatestProductEndDate__c, AccountStatus__c, CustomerLapsedDate__c FROM Account WHERE AccountStatus__c = \'Customer\' AND LatestProductEndDate__c =' + String.ValueOf(date.today()-1); 

       String query = 'SELECT Id, LatestProductEndDate__c, AccountStatus__c, CustomerLapsedDate__c FROM Account WHERE AccountStatus__c != \'Lapsed Customer\' AND CustomerLapsedDate__c = null AND LatestProductEndDate__c < ' + String.ValueOf(date.today()); 
       // String query = 'select Id, LatestProductEndDate__c, AccountStatus__c, CustomerLapsedDate__c from Account where id = \'0011700000D6FrN\'';
        return Database.getQueryLocator(query); 
    }
    //Implement Execute Method
    global void execute(Database.BatchableContext BC, List<Account> aList){
        
        Set<Id> AccountIdSet = new Set<Id>();
        for(Account a: aList){ 
            if(a.AccountStatus__c == 'Customer'){
                a.AccountStatus__c = 'Lapsed Customer';
                //a.CustomerLapsedDate__c = date.today();
                a.CustomerLapsedDate__c = a.LatestProductEndDate__c.addDays(1) ;
                //system.debug('1LatestProductEndDate__c' + a.LatestProductEndDate__c);
            }
            else if(a.AccountStatus__c == 'Out of Business' || a.AccountStatus__c == 'Fraud' || a.AccountStatus__c == 'Terminated - Compliance'){
                //a.CustomerLapsedDate__c = date.today();
                a.CustomerLapsedDate__c = a.LatestProductEndDate__c.addDays(1) ;
                //system.debug('2LatestProductEndDate__c' + a.LatestProductEndDate__c);
            }
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
                    /* Code added by Deepanshu, for sending a summary email whenever the Execute step encounters an error, starts*/
                    String errorAccount = '';
                    for(Integer i=0;i<srList.size();i++)
                    {
                        
                        Database.Error errors = srList.get(i).getErrors().get(0);
                        String errormsg = errors.getMessage();
                        //errorAccount += errormsg ;
                        errorAccount+=aList.get(i).Id;
                    }   
                     if (Personal_Settings__c.getInstance().Send_Emails__c == true)
                     {
                         String objectName = 'Account';
                         String summary = ' ';
                         summary += err.getMessage() + ' ' ;
                         summary += err.getFields() + ' ' ;
                         //system.assert(false, 'objectName=='+objectName+'errorAccount=='+errorAccount+'summary=='+summary);
                         BatchAccountUpdateHelper.sendEmail(objectName, errorAccount, summary);  
                     }
                     /*Code added by Deepanshu, for sending a summary email whenever the Execute step encounters an error, ends*/
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