@isTest
Private Class QuoteUpdateBatch_Test {
    static Database.QueryLocator QL;
    static Database.BatchableContext BC;
    static List<Apttus_Proposal__Proposal__c > proposalList; 
    static string CORN_EXP = '0 0 0 1 4 ?';
    static testmethod void testQuoteUpdateBatch(){
        prepareData();
        Test.startTest();
        QuoteUpdateBatch obj = new QuoteUpdateBatch();
        QL = obj.start(BC);        
        obj.execute(BC,proposalList);
        // Verify batch has executed and field is updated
        Apttus_Proposal__Proposal__c apttus = [SELECT QuoteStatus__c FROM Apttus_Proposal__Proposal__c  
                                                                    WHERE Id = :proposalList[0].Id];
        System.assert(apttus.QuoteStatus__c == 'Expired');                                                            
        obj.finish(BC);
        Test.stopTest();
    }
    
    static testMethod void schedule_batch(){
        Test.startTest();
        QuoteUpdateScheduler schedular = new QuoteUpdateScheduler();
        string jobid = system.schedule('my batch job', CORN_EXP, schedular);
        CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId]; 
        System.assertEquals(CORN_EXP, ct.CronExpression);
        Test.stopTest();
    }
    
    
    
    static void prepareData(){
     proposalList = new List<Apttus_Proposal__Proposal__c >();
     Account acc = TestDataSetupUtility.createTestAccount('test',null,null);
     insert acc;    
     Opportunity opp = TestDataSetupUtility.createTestOpportunity('TestOpp', acc.Id);
     Apttus_Proposal__Proposal__c apttus= TestDataSetupUtility.createApttusProposal(opp);
     apttus.Apttus_Proposal__Account__c = acc.Id;
     proposalList .add(apttus); 
     apttus= TestDataSetupUtility.createApttusProposal(opp);
     apttus.Apttus_Proposal__Account__c = acc.Id;
     proposalList .add(apttus);
     insert proposalList;           
        
    }
    
}