global class BatchAccountUpdateScheduler implements Schedulable {
   //Implement Execute Method
   global void execute(SchedulableContext sc){
      BatchAccountUpdate bau = new BatchAccountUpdate();
      database.executeBatch(bau,20);
   }
}