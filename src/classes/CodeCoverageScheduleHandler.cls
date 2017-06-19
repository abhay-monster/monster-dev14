public class CodeCoverageScheduleHandler {
    public String command {get;set;}
    public Id jobId {get;set;}
    
    public CodeCoverageScheduleHandler(String cmd) {
        command = cmd;
    }
   
    
    public Id execute() {
        if (command == 'RUNLOCALTEST') {
            Id jobId = CodeCoverageUtil.enqueueTests();
            return jobId;
        }
        else if (command == 'CHECKSTATUS') {
            CodeCoverageUtil.checkClassStatus(jobId);
            return jobId;
        }
        return null;
        
    }
    
    public void checkStatus() {
        // Get the latest not completed batch
        String inProgress = CodeCoverageUtil.STATUS_INPROGRESS+'%';
        Code_Coverage_Batch__c[] currentBatch = [SELECT parentjobid__c, batch_status__c, batch_run_time__c, 
                                               Batch_end_time__c, Batch_total_time__c  
                                           FROM Code_Coverage_Batch__c
                                           WHERE batch_status__c = :CodeCoverageUtil.STATUS_STARTED OR 
                                                 batch_status__c LIKE :inProgress];
        for (Code_Coverage_Batch__c thisbatch: currentBatch){
            System.debug('jobid: '+thisbatch.parentjobid__c);
            CodeCoverageUtil.checkClassStatus(thisbatch.parentjobid__c);
        }
    }

}