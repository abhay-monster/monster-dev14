/*
** @author : Phuong Tran
** @date : 11/3/2015
** @description : Utility to check on code coverage; run as scheduled via scheduler class.
*/
public class CodeCoverageUtil {
    
    public static String STATUS_STARTED = 'STARTED';
    public static String STATUS_INPROGRESS = 'INPROGRESS';  
    public static String STATUS_COMPLETED = 'COMPLETED';
   
    // Enqueue all classes containing "Test". 
    public static ID enqueueTests() {
        // Run unmanaged class tests
    ApexClass[] testClasses = 
           [SELECT Id, Name,Body FROM ApexClass 
            WHERE Name LIKE '%Test%' and NamespacePrefix = Null];       
    if (testClasses.size() > 0) {
            ApexTestQueueItem[] queueItems = new List<ApexTestQueueItem>();
           // cannot enqueue a test during a test
           if (!System.Test.isRunningTest()) {
                for (ApexClass cls : testClasses) {
                    queueItems.add(new ApexTestQueueItem(ApexClassId=cls.Id));
                }
                insert queueItems;
                // Get the job ID of the first queue item returned.
                ApexTestQueueItem item = 
                   [SELECT ParentJobId FROM ApexTestQueueItem 
                    WHERE Id=:queueItems[0].Id LIMIT 1];
                Code_Coverage_Batch__c newBatch = new Code_Coverage_Batch__c(ParentJobId__c=item.parentjobid,
                                                                            Batch_Run_Time__c=System.Now(),
                                                                            Batch_Status__c = STATUS_STARTED);
                insert newBatch;
                return item.parentjobid;
            } // end if running test
        }
        return null;

    }

    // Get the status and pass rate for each class
    // whose tests were run by the job.
    // that correspond to the specified job ID.
    public static void checkClassStatus(ID jobId) {
        ApexTestQueueItem[] items = 
           [SELECT ApexClass.Name, Status, ExtendedStatus FROM ApexTestQueueItem 
            WHERE ParentJobId=:jobId];
        if (items <> null && items.size() > 0) {
                Integer numClass = items.size();
                Integer numComplete = 0;
                for (ApexTestQueueItem item : items) {
                    if (item.Status =='Completed' ||item.Status =='Failed' || item.Status =='Aborted' ) {numComplete++;}
                }
                Code_Coverage_Batch__c currentBatch = [SELECT parentjobid__c, batch_status__c, batch_run_time__c, 
                                                       Batch_end_time__c, Batch_total_time__c  
                                                   FROM Code_Coverage_Batch__c
                                                   WHERE parentjobid__c= :jobId];
                if (currentBatch <> null) {
                    currentBatch.batch_status__c = STATUS_INPROGRESS +':'+numComplete + '/' + numClass  ;
                    if (numComplete == numClass && currentBatch.Batch_end_time__c == null) {
                        currentBatch.batch_status__c = STATUS_COMPLETED+':'+numComplete + '/' + numClass  ;
                        currentBatch.Batch_end_time__c = System.now();
                        currentBatch.Batch_total_time__c = currentBatch.Batch_end_time__c.gettime() - currentBatch.batch_run_time__c.gettime();
                        checkMethodStatus(jobId);
                        getAggCodeCoverage();
                    }
                    update currentBatch;
                }
        }
    }

    // Get the result for each test method that was executed.

    public static void checkMethodStatus(ID thisjobId) {
        ApexTestResult[] results = 
           [SELECT Outcome, ApexClass.Name, MethodName, Message, StackTrace 
            FROM ApexTestResult 
            WHERE AsyncApexJobId=:thisjobId];
        if (results<>null && results.size()>0) {
            List<CodeCoverageTestResult__c> newResultList = new List<CodeCoverageTestResult__c>();
            for (ApexTestResult atr : results) {
                CodeCoverageTestResult__c result = new CodeCoverageTestResult__c (jobid__c=thisjobId,
                                                          ApexClassName__c=atr.ApexClass.Name,
                                                          Outcome__c=atr.Outcome);
                if (atr.message != null) {
                    result.Message__c = atr.Message;
                    result.StackTrace__c = atr.StackTrace;
                }
                newResultList.add(result);
            } // end for
            insert newResultList;
        }// end if results >0
        
    }
    
    // Get code coverage from the ApexCodeCoverageAggregate object
    @future(callout=true)
    public static void getAggCodeCoverage() {
        // call the tooling api to get access to the ApexCodeCoverageAggregate object
        HttpResponse toolingQueryResponse = getCodeCovAggFromToolingAPI();
        System.debug(toolingQueryResponse); //*****
        // Get the map of apex attributes by classid's
        Map<String,CodeCov_ApexClass> classMap = populateClassMap();   
        System.debug('map size '+classMap.size());//*****
        // Parse the JSON query results and capture the results in the Code_Coverage__C object
        
        List<Code_Coverage__C> codeCoverageResultList = convertJsonToCodeCov(toolingQueryResponse,classMap);
        insert codeCoverageResultList;
    }  //end method
    
    
    // helperclass to convert json response to list of Code_Coverage__c objects for insertion
    public static List<Code_Coverage__C> convertJsonToCodeCov(HttpResponse toolingQueryResponse, Map<String,CodeCov_ApexClass> classMap) {
        JSONParser parser = JSON.createParser(toolingQueryResponse.getBody());
        String formattedDt = (System.now()).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        String batchid = formattedDt;
        String classname;
        String numLinesCovered;
        String numLinesUncovered;
        List<Code_Coverage__C> codeCoverageResultList = new List<Code_Coverage__c>(); 
                Integer retrievedRecs = 0; // keeps track to see if read the entire coverage fields
                String classid_str = 'DEFAULT';
                Integer numCovLines = 0;
                Integer numUncovLines = 0;
                Integer classSize = 0;
                while (parser.nextToken() != null) {
                    if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'ApexClassOrTriggerId') {
                        retrievedRecs++;
                        parser.nextToken();
                        classid_str = parser.getText();
                        System.debug('class '+classid_str);
                     }// end if
                    else if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'NumLinesCovered') {
                         retrievedRecs++;
                         parser.nextToken();
                         String numCov_str = parser.getText();
                         if (numCov_str <> null && numCov_str <> 'null') {
                             numCovLines = Integer.valueOf(numCov_str);
                         }
                         else {numCovLines = 0;} 
                        System.debug('numcov '+numCovLines);
                     }// end if
                     else if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'NumLinesUncovered') {
                         retrievedRecs++;
                         parser.nextToken();
                         String numUncov_str = parser.getText();
                         if (numUncov_str <> NULL && numUncov_str <> 'null') {
                             numUncovLines = Integer.valueOf(numUncov_str);
                         }
                         else {numUncovLines=0;}
                         System.debug('numUncovLines '+numUncovLines);
                     }// end if
                     // found the 3 items we need per Json record
                     if (retrievedRecs == 3) {
                        String recClassName; 
                        Integer totalLines = numCovLines + numUncovLines;
                        
                        CodeCov_ApexClass currClass = classMap.get(classid_str);
                        if (currClass <> null) {
                            recClassName = currClass.className;
                            classSize = currClass.classSize;
                        }
                        else { 
                            // can't find the class id in either classes or trigger id's
                                recClassName = classid_str;
                            }
                        System.debug('insert: '+formattedDt+'::'+classid_str+'::'+recClassName+'::'+classSize+'::'+numCovLines+'::'+totalLines+'::'+Date.today());
                        Code_Coverage__C CCRec = new Code_Coverage__C(Run_Batch_ID__c = formattedDt,
                                                                    ClassID__c = classid_str,
                                                                    Class_Name__c = recClassName,
                                                                    Class_Size_chars__c =  classSize,
                                                                     Lines_Covered__c = numCovLines,
                                                                     Total_Lines__c = totalLines,
                                                                     Run_Date__c = Date.today()
                                                                    );
                        // don't save if the total_lines is zero as those are test classes
                        if (totalLines > 0) {
                        	codeCoverageResultList.add(CCRec);
                        }
                        //reset the row
                        retrievedRecs = 0;
                        classid_str = 'BLANK';
                        numCovLines = 0;
                        numUncovLines = 0;
                        classSize = 0;
                    } // end if found 3 fields of code coverage we need from json  
                } // end while loop for records
        return codeCoverageResultList;
    } // end convert json method
    
    // helper method to read from tooling api
    public static HttpResponse getCodeCovAggFromToolingAPI()
    {
         // Use tooling api to get the current code coverage from CodeCoverageAggregate Object
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        req.setHeader('Content-Type', 'application/json');
        //String endpointURL = '/services/data/v35.0/tooling/query/?q=Select+ApexClassorTriggerId,NumLinesCovered,NumLinesUncovered,Coverage+from+ApexCodeCoverageAggregate';
        //String endpointURL = Url.getSalesforceBaseUrl().toExternalForm()+'/services/data/v35.0/tooling/query/?q=Select+ApexClassorTriggerId,NumLinesCovered,NumLinesUncovered,Coverage+from+ApexCodeCoverageAggregate';
        //req.setEndpoint(Url.getSalesforceBaseUrl().toExternalForm()+'/services/data/v35.0/tooling/query/?q=Select+ApexClassorTriggerId,NumLinesCovered,NumLinesUncovered,Coverage+from+ApexCodeCoverageAggregate');
        req.setEndpoint('https://monster--dev.cs21.my.salesforce.com/services/data/v35.0/tooling/query/?q=Select+ApexClassorTriggerId,NumLinesCovered,NumLinesUncovered,Coverage+from+ApexCodeCoverageAggregate');
        //req.setEndpoint(endpointURL);
        req.setMethod('GET'); 
        Http h = new Http();
        HttpResponse response = h.send(req);
        return response;
    } 
 
     // helper method to consolidate triggers and classes and key by class id so we can join that with the json 
     // results which come in as class id
     // todo: need to join with userid to get the developer names of the created and modified by
     public static Map<String,CodeCov_ApexClass> populateClassMap() {
        // Get the map of apex classnames to classid's
        Map<String, CodeCov_ApexClass> managedClassTriggMap = new Map<String, CodeCov_ApexClass>();
        List<ApexClass> managedClassesList =  [Select name, id, LengthWithoutComments, CreatedById, 
                                               			LastModifiedById, Body, LastModifiedDate from ApexClass];
        for (ApexClass cls: managedClassesList){
                String str_clsId = (String)cls.Id;
                CodeCov_ApexClass classObj = new CodeCov_ApexClass(cls.Name+'(Class)',
                                                        cls.LengthWithoutComments,
                                                        cls.CreatedById,
                                                        cls.LastModifiedById,
														cls.Body,
                                                        0,
                                                        0,
                                                        0,
                                                        cls.LastModifiedDate
                                                        );
                managedClassTriggMap.put(str_clsId, classObj);
            }
        
        // Get the map of apex triggers to classid's
        List<ApexTrigger> managedTriggerList =  [Select name, id, LengthWithoutComments, CreatedById, 
                                               			LastModifiedById, Body, LastModifiedDate from ApexTrigger];
        Map<String, ApexTrigger> managedTriggerMap = new Map<String, ApexTrigger>();
        for (ApexTrigger cls: managedTriggerList){
                String str_clsId = (String)cls.Id;
                CodeCov_ApexClass classObj = new CodeCov_ApexClass(cls.Name+'(Trigger)',
                                                        cls.LengthWithoutComments,
                                                        cls.CreatedById,
                                                        cls.LastModifiedById,
														cls.Body,
                                                        0,
                                                        0,
                                                        0,
                                                        cls.LastModifiedDate );
                managedClassTriggMap.put(str_clsId, classObj);
            }
        return managedClassTriggMap;
    } // end populateClassMap
    

 

    
}