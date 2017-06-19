global class BatchProcessHierarchySpend implements Database.Batchable<SObject>, Database.Stateful{
    
    BatchProcessServiceHierarchySpend service;
  
  global BatchProcessHierarchySpend(set<Id> pTopLevelAccountSet){
        // service = new BatchProcessServiceHierarchySpend(pTopLevelAccountSet);
  }
  
  global Database.Querylocator start(Database.Batchablecontext BC){
    system.debug(LoggingLevel.INFO, '\n\n BatchProcessHierarchySpend.start() \n\n');
    return service.GetQueryLocator(service.GetQuery()); 
    return null;
  }
  
  global void execute(Database.Batchablecontext BC, list<SObject> scope){
    system.debug(LoggingLevel.INFO, '\n\n BatchProcessHierarchySpend.execute() \n\n');
    service.ProcessBatch(scope); 
  }
  
  global void finish(Database.Batchablecontext BC){
    system.debug(LoggingLevel.INFO, '\n\n BatchProcessHierarchySpend.finish() \n\n');
    service.FinishBatch(); 
  }

}