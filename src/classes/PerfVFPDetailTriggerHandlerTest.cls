@isTest
private class PerfVFPDetailTriggerHandlerTest {
    
    static void createTestData(){
        
        Performance_Transaction_Category__c defaultCat = new Performance_Transaction_Category__c(Name='Default Cat',
                                                                                                Category_Priority__c = '1-Critical');
        insert defaultCat;
        Performance_Prod_User_ID_Mapping__c newUser = new Performance_Prod_User_ID_Mapping__c(UserId__c='1111',
                                                                                             User_Name__c = 'TestUser1');
        insert newUser;
        Performance_VFP__c vfp = new Performance_VFP__c(Name='/apex/page',
                                                       Page_Priority__c = '1-Critical', 
                                                       Performance_Transaction_Category__c = defaultCat.Id);
        Performance_VFP__c vfp2 = new Performance_VFP__c(Name='UNKNOWN',
                                                       Page_Priority__c = '1-Critical', 
                                                       Performance_Transaction_Category__c = defaultCat.Id);
        Insert vfp; Insert vfp2;

    }
    
    static testMethod void testTrigger() {
        
        createTestData();
        
        Test.startTest();
                //Create 110 detail objects to test the insertion
        List<Performance_VFP_Detail__c> detailList= new List<Performance_VFP_Detail__c>() ;
        for (Integer x =0; x<110; x++) {
            Performance_VFP_Detail__c detail = new Performance_VFP_Detail__c(pageName__c = '/apex/page',
                                                                            Userid__c = '1111',
                                                                            Batch_timestamp__c = DateTime.now(),
                                                                            DateTime_Executed_ms__c = DateTime.now(),
                                                                             execTime_ms__c = 500,
                                                                             runTime_ms__c = 500);
            detailList.add(detail) ; 
            
        } // end for
        insert detailList;
        //insert detail record that forces new page and user to be created
        Performance_VFP_Detail__c detail = new Performance_VFP_Detail__c(pageName__c = '/apex/newpage',
                                                                            Userid__c = '1111NEW',
                                                                            Batch_timestamp__c = DateTime.now(),
                                                                            DateTime_Executed_ms__c = DateTime.now(),
                                                                             execTime_ms__c = 500,
                                                                             runTime_ms__c = 500);
        insert detail;

        Test.stopTest();
        // Test your steps
        
        Integer rowcount = [Select count() from Performance_VFP_Detail__c ];
        System.assertEquals(rowcount, 111);
        
    }

}