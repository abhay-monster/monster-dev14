global class CloseEventBatch implements Database.Batchable<sObject>{
                  
    global Database.QueryLocator start(Database.BatchableContext BC){  
        String query = 'SELECT Id, EventStatus__c , LastModifiedDate,RecordTypeId FROM Event WHERE EventStatus__c = \'Open\'';
        system.debug('Query >> '+ query);
        return Database.getQueryLocator(query);
        return null;
    }

    global void execute(Database.BatchableContext BC, List<Event> scope){
        DateTime dateCheck = system.now() - 90;
        List<Event> eventToUpdate = new List<Event>();
        map<String, map<String, Id>> result = Utility.GetRecordTypeIdsBySObjectNameSet(new set<String>{'Event'});
        if(!scope.isEmpty()){
            for(Event e : scope){
                if(e.LastModifiedDate < dateCheck && (e.RecordTypeId == result.get('Event').get('Action Plan Event'))){
                    e.EventStatus__c = 'Completed';
                    eventToUpdate.add(e);
                }
            }
            if(eventToUpdate.size() > 0){
                update eventToUpdate;
            }
        }
    }
    global void finish(Database.BatchableContext BC){
    } 
}