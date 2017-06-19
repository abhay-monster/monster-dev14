/**===========================================================================
 * Appirio, Inc
 * Name: TerritoryAssignmentBatch
 * Description: Batch process to assign Accounts based upon Posting Address Zip code
 *
 * Date Modified                Modified By              Description of the update
 * 10th Sep 2015                Parul Gupta              T-431652: Modified Batch process to assign
 																												 Accounts based upon Posting Address Zip code
 ============================================================================*/
global class TerritoryAssignmentBatch implements Database.Batchable<sObject>, Database.Stateful{

    global String updateErrors = '';
	  global Integer batch_ct = 0;
	  global Integer record_ct = 0;
	  global Integer scopeSize = 0;
	  global Integer acc_ct = 0;
      global List<TerritoryAssignmentCode__c> taList;

    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
        //Jeff L I-190489, added null check to query, we only want to get the accounts that actually have a Territory Code associated with them
        String query = TerritoryAssignmentForBatch.buildBatchQuery();
        if(query == null){
            system.debug('No Territories to Process');
            return null;
        }
        system.debug('TerritoryAssignmentBatch :: START :: query' + query);
        taList = TerritoryAssignmentForBatch.batchTerritoryAssignmentCodeList;
        return Database.getQueryLocator(query);
    }

		// Execute Method
    global void execute(Database.BatchableContext BC, List<Account> scope){
    	batch_ct++;
        record_ct += scope.size();
        if (scopeSize==0){
            scopeSize = scope.size();
        }
        TerritoryAssignmentForBatch taBatch = new TerritoryAssignmentForBatch();
        updateErrors += taBatch.TerritoryAssignment(scope,taList);
        acc_ct += taBatch.accountsToUpdate.size();
    }

    // Finish Method
    global void finish(Database.BatchableContext BC){
    	String objectName = 'Account';
        String summary = '';
        summary += record_ct + ' ' + objectName + ' records were processed ';
        summary += 'in ' + batch_ct + ' batches of up to ' + scopeSize + ' records each.<BR><BR>';
        summary += 'The following counts of records were flagged for territory assignment:<BR>';
        summary += acc_ct + ' ' + objectName + ' record(s)<BR>';
        SetSendToEmailFlag.fromTerritory = true;
        ArchiveHelper.processType = 'Territory Assignment';
        ArchiveHelper.subjectText = 'Territory Assignment of';
        ArchiveHelper.sendEmail(objectName, summary, updateErrors);
    }
}