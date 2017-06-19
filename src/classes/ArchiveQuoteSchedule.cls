global class ArchiveQuoteSchedule implements Schedulable {

  global void execute(SchedulableContext sc){
        ArchiveQuoteBatch batch = new ArchiveQuoteBatch ();
        ID batchprocessid = Database.executeBatch(batch); 
    }
}