global class CodeCoverageStatusScheduler implements Schedulable{

   global void execute(SchedulableContext SC) {
       CodeCoverageScheduleHandler handler = new CodeCoverageScheduleHandler('CHECKSTATUS');
       handler.checkStatus();
   }

}