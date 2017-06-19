@isTest(SeeAllData=true)
public class CodeCoverageUtilTest {
   
    static testmethod void testCodeCoverageUtil() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new CodeCoverageHTTPMock());
        HttpResponse res = CodeCoverageUtil.getCodeCovAggFromToolingAPI();
        // Verify response received contains fake values
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = res.getBody();
        System.assertEquals(200, res.getStatusCode());
        System.Assert(res <> null && actualValue.contains('ApexCodeCoverageAggregate'));
        Map<String,CodeCov_ApexClass> classMap = CodeCoverageUtil.populateClassMap();
        System.Assert(classMap <> null && classMap.size()>0);
        List<Code_Coverage__C> codeCoverageResultList = CodeCoverageUtil.convertJsonToCodeCov(res,classMap);
        System.Assert(codeCoverageResultList<> null && codeCoverageResultList.size()>0);
        CodeCoverageUtil.getAggCodeCoverage();
        CodeCoverageScheduleHandler handler = new CodeCoverageScheduleHandler('RUNLOCALTEST');
        Id jobid = handler.execute();
        handler.jobId = jobid;
        handler.command = 'CHECKSTATUS';
        handler.execute();
        Code_Coverage_Batch__c newBatch = new Code_Coverage_Batch__c(ParentJobId__c='AAAAAAAAAA',
                                                                            Batch_Run_Time__c=System.Now(),
                                                                            Batch_Status__c = CodeCoverageUtil.STATUS_STARTED); 
        insert newBatch;
        Test.stopTest();
    }
    
    
}