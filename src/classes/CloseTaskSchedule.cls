global class CloseTaskSchedule implements Schedulable {

    global void execute(SchedulableContext sc){
        CloseTaskBatch batch = new CloseTaskBatch();
        ID batchprocessid = Database.executeBatch(batch); 
    }
    
}