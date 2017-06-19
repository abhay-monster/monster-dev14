global class CloseEventSchedule implements Schedulable {

    global void execute(SchedulableContext sc){
        CloseEventBatch batch = new CloseEventBatch();
        ID batchprocessid = Database.executeBatch(batch); 
    }
    
}