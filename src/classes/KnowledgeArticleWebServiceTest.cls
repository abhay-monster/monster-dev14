/**
 * Appirio, Inc
 * Name             : KnowledgeArticleWebServiceTest
 * Created Date     : 11 Sept 2015 
 * Created By       : Shailendra Singh (Appirio)
 * Description      : Test class for KnowledgeArticleWebService
 */
@isTest
private class KnowledgeArticleWebServiceTest { 
    private static List<KnowledgeArticleWebService.Filters> filterList;
    private static CSH__kav csh;
	private static User testUser ;
    static void setupTestData(){
    	Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
         testUser =  TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);
         testUser.UserPermissionsKnowledgeUser = true;
         insert testUser;
        //Insert a knowledgeBase record for testing
        CSH_Interface_ID__c interfaceCustomSetting = new CSH_Interface_ID__c(Name = 'en_US27', ChannelName__c = 'HotJobs White Label', Identifier__c = '27', CountryName__c = 'US', LangaugeCode__c = 'en_US');
        insert interfaceCustomSetting;
        
        csh = new CSH__kav(UrlName = 'testurl', Title = 'Test title', access_id__c = 'test', m_Id__c='111', interface_id__c = 'test', Summary = 'test summary', Language = 'en_US');
        insert csh;
        csh = [select id, KnowledgeArticleId, m_Id__c From CSH__kav Where id = :csh.Id];
        System.runAs(testUser){
        	KbManagement.PublishingService.publishArticle(csh.KnowledgeArticleId, true);
        }
        //set up our filterlist for testing
        filterList = new List<KnowledgeArticleWebService.Filters>();
        KnowledgeArticleWebService.Filters f1 = new KnowledgeArticleWebService.Filters();
        f1.Name='interface_id';
        f1.Values='27';
        KnowledgeArticleWebService.Filters f2 = new KnowledgeArticleWebService.Filters();
        f2.Name = 'access_id';
        f2.Values = '1';
        //filterList.add(new KnowledgeArticleWebService.Filters(Name='interface_id', Values='27'));
       // filterList.add(new KnowledgeArticleWebService.Filters(Name='access_id', Values='1'));
       filterList.add(f1);
       filterList.add(f2);
       
    } 

    static testMethod void testFetchArticlesWithSFDCID() {
    	setupTestData();
        Test.startTest();
        KnowledgeArticleWebService.Filters f3 = new KnowledgeArticleWebService.Filters();
        f3.Name='m_Id';
        f3.Values=csh.Id;
        filterList.add(f3);
        //filterList.add(new KnowledgeArticleWebService.Filters(Name='m_Id', Values=csh.Id));
        KnowledgeArticleWebService.AnalyticsReport an = new KnowledgeArticleWebService.AnalyticsReport();
        an.Filters = filterList;
     	
     	
     	KnowledgeArticleWebService.CSVTableSetWrapper returnRecord = KnowledgeArticleWebService.RunAnalyticsReport(an,'|');
        KnowledgeArticleWebService.CSVRowClass row = returnRecord.CSVTableSet[0].CSVTables[0].CSVTable[0].Rows[0];
     	System.assertNotEquals(returnRecord, null);
     	KnowledgeArticleWebService.CSVRowClass rc = new KnowledgeArticleWebService.CSVRowClass();
        KnowledgeArticleWebService.CSVTablecls tc = new KnowledgeArticleWebService.CSVTablecls();
        KnowledgeArticleWebService.CSVTableSet ts = new KnowledgeArticleWebService.CSVTableSet();
        try{
        KnowledgeArticleWebService.CSVTableSet ts2 = new KnowledgeArticleWebService.CSVTableSet(csh,null);
        }catch(Exception e){}
     	Test.stopTest();
    }

    static testMethod void testFetchArticlesWithmID() {
        setupTestData();
        Test.startTest();
        KnowledgeArticleWebService.Filters f3 = new KnowledgeArticleWebService.Filters();
        f3.Name='m_Id';
        f3.Values=csh.m_Id__c;
        filterList.add(f3);
        //filterList.add(new KnowledgeArticleWebService.Filters(Name='m_Id', Values=csh.Id));
        KnowledgeArticleWebService.AnalyticsReport an = new KnowledgeArticleWebService.AnalyticsReport();
        an.Filters = filterList;
        
        
        KnowledgeArticleWebService.CSVTableSetWrapper returnRecord = KnowledgeArticleWebService.RunAnalyticsReport(an,'|');
        KnowledgeArticleWebService.CSVRowClass row = returnRecord.CSVTableSet[0].CSVTables[0].CSVTable[0].Rows[0];
        System.assertNotEquals(returnRecord, null);
        
        Test.stopTest();
    }
}