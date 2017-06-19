/***********************************************************************************************************
 * Appirio, Inc
 * Name         : ScheduleTerritoryAssignmentBatchClass
 * Created By   : Rohit B. (Appirio)
 * Purpose      : Controller class of ScheduleTerritoryAssignmentBatchPage
 * Created Date : 13/Oct/2015
 *
 * Date Modified                Modified By             Description of the update
 * [Date]                       [Person Name]           [Short Description]
 **********************************************************************************************************/
public with sharing class ScheduleTerritoryAssignmentBatchClass {
    String msg;
    public Boolean isEnable {get; set;}
    public String btnName {get; set;}
    public String scheduleOption {get; set;}
    public Integer minToSchedule {get; set;}
    Final String CLASS_NAME = 'TerritoryAssignmentBatch';
    Final String JOB_NAME = 'schTerritoryAssignmentBatch';
    String uName, startTime, jobState, jobStatus, jobID;
    Integer jobStatusNo;
    Map<Integer, String> jobStatusMap = new Map<Integer, String>();
    Map<String, Integer> jobStatusRevMap = new Map<String, Integer>();
    
    public ScheduleTerritoryAssignmentBatchClass() {
        System.debug('[RB] - ScheduleTerritoryAssignmentBatchClass.ScheduleTerritoryAssignmentBatchClass : Constructor Execution Started..');
        isEnable = False;
        btnName = 'Schedule';
        jobStatus = getBatchStatus(CLASS_NAME);
        System.debug('[RB] - ScheduleTerritoryAssignmentBatchClass.ScheduleTerritoryAssignmentBatchClass : jobStatus = ' + jobStatus);
        if(jobStatus == 'ReadyToAbort') {
            msg = 'The status of Class ' + CLASS_NAME + ' is : ' + jobState + '. It is ';
            msg += 'already ran/scheduled by ' + uName + ' and the start time of this job is ' + startTime + '.';
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, msg));
            btnName = 'Abort';
            //isEnable = True;
        } //END if(jobStatus != 'Completed' && jobStatus != 'Aborted' && jobStatus != 'Failed') {
    } //END public ScheduleTerritoryAssignmentBatchClass() { 

    public PageReference scheduleAndRedirect() {
        PageReference page;
        try {
            System.debug('[RB] - ScheduleTerritoryAssignmentBatchClass.scheduleAndRedirect : Method Execution Started..');
            String jobStatus = 'ReadyToGo';
            System.debug('[RB] - ScheduleTerritoryAssignmentBatchClass.scheduleAndRedirect : btnName = ' + btnName);
            
            jobStatus = getBatchStatus(CLASS_NAME);
            
            System.debug('[RB] - ScheduleTerritoryAssignmentBatchClass.scheduleAndRedirect : jobStatus = ' + jobStatus);
                    
            if(btnName == 'Schedule') {
                if(jobStatus == 'ReadyToSchedule') {
                    TerritoryAssignmentBatch TAB = new TerritoryAssignmentBatch();
                    if(scheduleOption=='Now') { 
                        System.debug('[RB] - ScheduleTerritoryAssignmentBatchClass.scheduleAndRedirect : If block..');                                      
                        database.executeBatch(TAB);
                        msg = 'Your ' + CLASS_NAME + ' has been queued for execution successfully.';
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm , msg)); 
                        btnName = 'Abort'; 
                    } //END if(scheduleOption=='Now') {
                    else if(scheduleOption=='Later'){
                        System.debug('[RB] - ScheduleTerritoryAssignmentBatchClass.scheduleAndRedirect : Minutes to Schedule = ' + String.valueOf(minToSchedule));
                        if(String.isBlank(String.valueOf(minToSchedule)))
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error , 'Please specify valid Minutes for schedule.'));
                        else if(minToSchedule < 1)
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error , 'Minutes for schedule can\'t be less than 1.'));
                        else {
                            String jobId = system.scheduleBatch(TAB, JOB_NAME, minToSchedule);
                            msg = 'Your ' + CLASS_NAME + ' has been scheduled for execution after ' + minToSchedule + ' minutes successfully.';
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm , msg));  
                            btnName = 'Abort';
                        } //END else {
                    } //END else if(scheduleOption=='Later'){
                } //END if(scheduleOption=='Now') {
                else {
                    btnName = 'Abort';
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm , msg));
                }
            } //END if(btnName == 'Schedule') {
            else if(btnName == 'Abort') {
                System.debug('[RB] - ScheduleTerritoryAssignmentBatchClass.scheduleAndRedirect : If block..');
                if(jobStatus == 'ReadyToAbort') {
                    System.abortJob(jobID);
                    ApexPages.getMessages().clear();
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, 'Job for batch class ' + CLASS_NAME + ' has been aborted.'));
                    //isEnable = False;
                } //END if(jobStatus == 'Holding' || jobStatus == 'Queued' || jobStatus == 'Preparing' || jobStatus == 'Processing') {
                btnName = 'Schedule';
            } //END else if(btnName == 'Abort') {
        } //END try {
        catch(Exception e) {
            msg = e.getMessage() + ' at ' + e.getLineNumber();
            System.debug('[RB] - ScheduleTerritoryAssignmentBatchClass.scheduleAndRedirect : Error = ' + msg);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, msg));
        } //END catch(Exception e) {
        
        //page.setRedirect(true);
        //return page;
        return null;
    } //END public PageReference saveAndRedirect() {

    public PageReference Cancel() {
        System.debug('[RB] - ScheduleTerritoryAssignmentBatchClass.Cancel : Method Execution Started..');
        PageReference page;
        
        page = new PageReference('/home/home.jsp'); 
        
        page.setRedirect(true);
        return page;
    } //END public PageReference Cancel() {

    private String getBatchStatus(String clsName) {
        System.debug('[RB] - ScheduleTerritoryAssignmentBatchClass.getBatchStatus : Method Execution Started..');
        String jStatus;
        jobStatus = 'ReadyToSchedule';

        List<AsyncApexJob> jobs = [SELECT ID, ApexClassID, ApexClass.Name, Status, CreatedById, CreatedDate
              FROM AsyncApexJob WHERE JobType = 'BatchApex' AND ApexClass.Name =: clsName Order By CreatedDate Desc];

        List<CronTrigger> jobDetails = [SELECT Id, CronJobDetailId, OwnerId, StartTime, State 
              FROM CronTrigger WHERE CronJobDetail.Name = 'schTerritoryAssignmentBatch'];
        
        System.debug('[RB] - ScheduleTerritoryAssignmentBatchClass.getBatchStatus : AsyncApexJob Size = ' + jobs.size());
        System.debug('[RB] - ScheduleTerritoryAssignmentBatchClass.getBatchStatus : CronTrigger Size = ' + jobDetails.size());        
        if(jobDetails.size() > 0) {
            jStatus = jobDetails[0].State; 
            System.debug('[RB] - ScheduleTerritoryAssignmentBatchClass.getBatchStatus : Initial Scheduled Job Status = ' + jobState);
            //jobStatusNo = jobStatusRevMap.get(jStatus);
            if(jStatus == 'Waiting' || jStatus == 'Accquired' || jStatus == 'Executing' || jStatus == 'Paused' || jStatus == 'Blocked' || jStatus == 'Paused_Blocked') {
                jobStatus = 'ReadyToAbort';
                jobState = jStatus;
                jobID = jobDetails[0].Id;
                uName = [SELECT Name FROM User WHERE ID =: jobDetails[0].OwnerId Limit 1].Name;
                startTime = String.valueOf(jobDetails[0].StartTime);
            }
        }
        if(jobs.size() > 0) {
            jStatus = jobs[0].Status; 
            System.debug('[RB] - ScheduleTerritoryAssignmentBatchClass.getBatchStatus : Initial Batch Run Status = ' + jobState);
            //jobStatusNo = jobStatusRevMap.get(jStatus);
            if(jStatus == 'Holding' || jStatus == 'Queued' || jStatus == 'Preparing' || jStatus == 'Processing') {
                jobStatus = 'ReadyToAbort';
                jobState = jStatus;
                jobID = jobs[0].ID;
                uName = [SELECT Name FROM User WHERE ID =: jobs[0].CreatedById Limit 1].Name;
                startTime = String.valueOf(jobs[0].CreatedDate);
            }
        } //END if(jobs.size() > 0) {
        
        System.debug('[RB] - ScheduleTerritoryAssignmentBatchClass.getBatchStatus : Final Status = ' + jobStatus);
        System.debug('[RB] - ScheduleTerritoryAssignmentBatchClass.getBatchStatus : uName = ' + uName + ' & jobStatusNo = ' + String.valueOf(jobStatusNo));
        
        return jobStatus;
    } //END String getBatchStatus(String clsName) {
} //END class scheduleBatchClass {