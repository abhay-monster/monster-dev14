global class BatchAccountUpdateForDunsScheduler implements Schedulable {
   //Implement Execute Method
   global void execute(SchedulableContext sc){
      BatchAccountUpdateForDuns bau = new BatchAccountUpdateForDuns();
      database.executeBatch(bau,20);
   }
}