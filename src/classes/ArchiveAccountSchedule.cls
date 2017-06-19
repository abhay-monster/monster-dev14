global class ArchiveAccountSchedule implements Schedulable {
  global void execute(SchedulableContext sc){
       ArchiveAccountBatch batch = new ArchiveAccountBatch();
        ID batchprocessid = Database.executeBatch(batch);
    }
}