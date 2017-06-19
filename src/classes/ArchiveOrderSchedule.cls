global class ArchiveOrderSchedule implements Schedulable {

    global void execute(SchedulableContext sc) {
        // We now call the batch class to be scheduled
        ArchiveOrderBatch batch = new ArchiveOrderBatch (); 
        database.executebatch(batch,10);
     }
  
}