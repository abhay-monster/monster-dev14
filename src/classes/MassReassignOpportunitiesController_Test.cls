/*
Author : Shyam Sundar (Appirio)
*/

@isTest 
private class MassReassignOpportunitiesController_Test {
    
    static testmethod void testReassign(){
        
        Account testAccount = TestDataSetupUtility.createTestAccountWithShipping('test');
        insert testAccount;
                
        Opportunity testOpty = TestDataSetupUtility.createTestOpportunity('testOpp', testAccount.Id);
        testOpty.StageName = 'Stage 1 - Needs Assessment';
        testOpty.CloseDate = System.today()+1;
        testOpty.AccountId=testAccount.Id;
        testOpty.Name='testOpty';
        testOpty.Type = 'Existing Business';
        insert testOpty;
        
        MassReassignOpportunitiesController controller = new MassReassignOpportunitiesController();
        controller.refreshOptyList();
        controller.filterId = controller.listviewoptions[1].getValue();
        controller.refreshOptyList();
        controller.searchRecord.stageName = 'Stage 1 - Needs Assessment';
        controller.helperRecord.ClosedDate_From__c=System.today()-2;
        controller.helperRecord.ClosedDate_To__c=System.today()+2;
        controller.helperRecord.From__c=System.today()-2;
        controller.helperRecord.To__c=System.today()+2;
        controller.searchRecord.Type = 'Existing Business';
        controller.refreshOptyListBySearch();
        
        System.assert(controller.optyList.size()>0);
        
        controller.optyList[0].selected = true;
        controller.helperRecord.Assign_to__c = UserInfo.getUserId();
        controller.Assign();
        
        
        
    }
}