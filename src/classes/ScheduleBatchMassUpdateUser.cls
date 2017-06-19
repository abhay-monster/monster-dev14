global class ScheduleBatchMassUpdateUser implements Schedulable {
	global void execute(SchedulableContext scMain) {
		BatchMassUpdateUser batch = new BatchMassUpdateUser();
		ID batchId = Database.executeBatch(batch, 200);
	}
}