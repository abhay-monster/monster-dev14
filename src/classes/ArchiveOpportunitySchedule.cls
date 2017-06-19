global class ArchiveOpportunitySchedule implements Schedulable {
	global void execute(SchedulableContext sc){
        ArchiveOpportunityBatch batch = new ArchiveOpportunityBatch();
        ID batchprocessid = Database.executeBatch(batch); 
    }
}