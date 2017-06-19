global class BatchProcess12MonthSpend implements Database.Batchable<SObject>, Database.Stateful{
   
BatchProcessService12MonthSpend service = new BatchProcessService12MonthSpend();
  
  global void BatchProcessTemplate(){}
  
  global Database.Querylocator start(Database.Batchablecontext BC){
    system.debug(LoggingLevel.INFO, '\n\n BatchProcess12MonthSpend.start() \n\n');
    return service.GetQueryLocator(service.GetQuery());
    return null;
  }
  
  global void execute(Database.Batchablecontext BC, list<SObject> scope){
    system.debug(LoggingLevel.INFO, '\n\n BatchProcess12MonthSpend.execute() \n\n');
    service.ProcessBatch(scope); 
  }
  
  global void finish(Database.Batchablecontext BC){
    system.debug(LoggingLevel.INFO, '\n\n BatchProcess12MonthSpend.finish() \n\n');
    service.FinishBatch(); 
  }

}