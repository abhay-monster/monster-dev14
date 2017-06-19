global class FullBulkCreditLoadScheduler implements Schedulable {
    global void execute(SchedulableContext scMain) {
        /* Modified by Vikas Menon 21 Dec, 2016 */
        Integer batchSize = 200; // Default batch size
        // Get batch size from custom setting
        FullBulkCreditLoadBatch__c cs = FullBulkCreditLoadBatch__c.getInstance();
        if(cs.Records_per_batch__c != null) {
            batchSize = Integer.valueOf(cs.Records_per_batch__c);
        }
        FullBulkCreditLoadBatch b= new FullBulkCreditLoadBatch ();
        ID idBatch = Database.executeBatch(b, batchSize);
    }
}