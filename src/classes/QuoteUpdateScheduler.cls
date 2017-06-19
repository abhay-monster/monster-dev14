/*
** @author : Cloud Sherpas Inc.
** @date : 09/04/2014
** @description : Scheduler class for QuoteUpdateBatch
*/
global class QuoteUpdateScheduler implements Schedulable {

    global void execute(SchedulableContext sc){
        QuoteUpdateBatch batch = new QuoteUpdateBatch();
        ID batchprocessid = Database.executeBatch(batch);
        system.debug('\n\n QuoteUpdateBatch batchprocessid:' + batchprocessid);
    }
    
}