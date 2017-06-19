/*
** @author : Cloud Sherpas Inc.
** @date : 09/04/2014
** @description : Batch class to update Quote Proposal Status as expired.
*/

global class QuoteUpdateBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    global QuoteUpdateBatch(){
        system.debug(LoggingLevel.INFO, '\n\n QuoteUpdateBatch constructor \n\n');
    } 
    
    /**
     ** Get Proposals whose ExpectedEndDate__c passed Todays Date
     **/
    global Database.QueryLocator start(Database.BatchableContext BC){
		system.debug(LoggingLevel.INFO, '\n\n QuoteUpdateBatch.start() \n\n');
        String strQuery = '';
            strQuery += 'Select ID, QuoteStatus__c,Apttus_Proposal__ExpectedEndDate__c';
            strQuery += ' From Apttus_Proposal__Proposal__c';
            strQuery += ' Where LastModifiedDate >= LAST_N_MONTHS:3';
            strQuery += ' AND QuoteStatus__c != \'Expired\'';
            strQuery += ' AND QuoteStatus__c != \'Accepted Online\'';
            strQuery += ' AND QuoteStatus__c != \'Accepted Offline\'';
            strQuery += ' AND Apttus_Proposal__ExpectedEndDate__c != NULL';
            strQuery += ' AND Apttus_Proposal__ExpectedEndDate__c < TODAY';		
        return database.getquerylocator(strQuery);      
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
		system.debug(LoggingLevel.INFO, '\n\n QuoteUpdateBatch.execute() \n\n');
        try{
            for (sObject proposal : scope) {
                proposal.put('QuoteStatus__c', 'Expired'); 
            }
            system.debug('Updating Quote Proposals Status.');
            update scope;
            system.debug('Quote Proposals Status Successfully updated.');
        }catch(Exception ex){
            system.debug('\n\n Exception \n\n'+ex.getMessage());
            system.debug('\n\n StackTrace \n\n'+ex.getStackTraceString());
        }
    }
    
    global void finish(Database.BatchableContext BC) {
		system.debug(LoggingLevel.INFO, '\n\n QuoteUpdateBatch.finish() \n\n');
    }
}