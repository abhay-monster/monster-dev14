global class ScheduleBatchProcess12MonthSpend implements Schedulable {

    global void execute(SchedulableContext sc){
      system.debug('\n\nScheduleBatchProcess12MonthSpend.execute()\n\n');
        
        BatchProcess12MonthSpend batch = new BatchProcess12MonthSpend();
        ID batchprocessid = Database.executeBatch(batch,10); 
    }
    
}

/************ DO NOT DELETE ******************

Copy this code to "Execute Anonymous" to schedule the batch job

   ScheduleBatchProcess12MonthSpend stcba = new ScheduleBatchProcess12MonthSpend();
    String Sched = '0 0 21 * * ?';
    System.Schedule('Calculate 12 Month Spend', Sched, stcba);
*/