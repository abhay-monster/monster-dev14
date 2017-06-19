global class ArchiveContactSchedule implements Schedulable {


    global void execute(SchedulableContext sc) {
        // Implement any logic to be scheduled

           // We now call the batch class to be scheduled
        ArchiveContactBatch batch = new ArchiveContactBatch (); 
        String Quarter_EXP = '0 0 5 1 1/4 ?';
        
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(batch,10);
        //system.schedule('ArchiveContactSchedule', Quarter_EXP ,batch );
     }
  
}