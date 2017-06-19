global class CodeCoverageScheduler implements Schedulable{

   global void execute(SchedulableContext SC) {
       CodeCoverageScheduleHandler handler = new CodeCoverageScheduleHandler('RUNLOCALTEST');
       Id newId = handler.execute();
       handler.command = 'CHECKSTATUS';
       handler.jobId = newId;
       handler.execute();
   }

}