global class CloseTaskBatch implements Database.Batchable<sObject>{
                   
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Status, LastModifiedDate, RecordTypeId FROM Task WHERE Status = \'Open\'';
        system.debug('Query >> '+ query);
        return Database.getQueryLocator(query); 
        return null;
    } 

    global void execute(Database.BatchableContext BC, List<Task> scope){
        List<Task>  taskToUpdate = new List<Task>();
        DateTime dateCheck = system.now() - 90;
        map<String, map<String, Id>> result = Utility.GetRecordTypeIdsBySObjectNameSet(new set<String>{'Task'});
        if(!scope.isEmpty()){
            for(Task t : scope){
                if(t.LastModifiedDate < dateCheck && (t.RecordTypeId == result.get('Task').get('Action Plan') || t.RecordTypeId == result.get('Task').get('Action Tracker'))){
                    t.Status = 'Completed';
                    taskToUpdate.add(t);
                }
            }
            if(taskToUpdate.size() > 0){
                update taskToUpdate;
            }
        } 
    }
    global void finish(Database.BatchableContext BC){
    } 
}