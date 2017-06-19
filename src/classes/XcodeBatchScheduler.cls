/**
Scheduler class 
*/
global class XcodeBatchScheduler implements Schedulable{
global void execute(SchedulableContext sc) {
    XcodeBatchClass  b = new XcodeBatchClass(); 
    //Parameters of ExecuteBatch(context,BatchSize)
    database.executebatch(b);
}
}