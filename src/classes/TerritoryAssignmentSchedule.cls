global class TerritoryAssignmentSchedule implements Schedulable {

    global void execute(SchedulableContext sc){
        TerritoryAssignmentBatch batch = new TerritoryAssignmentBatch();
        ID batchprocessid = Database.executeBatch(batch,50);
    }
    
}