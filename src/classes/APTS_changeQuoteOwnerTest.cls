@isTest
private class APTS_changeQuoteOwnerTest{

 static testMethod void testAPTS_changeQuoteOwner(){
 
     Apttus_Proposal__Proposal__c proposal;
         Account acc = TestDataSetupUtility.createTestAccountWithShipping('Test Acocunt'); 
         insert acc;
         Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test opp',acc.Id);
         insert opp;         
         proposal = TestDataSetupUtility.createProposal('Test Proposal', acc.Id, opp.Id, 'Accepted Online', true);
         System.currentPageReference().getParameters(). put( 'id', proposal.Id);
        Test.startTest();
        APTS_changeQuoteOwner ctrl = new APTS_changeQuoteOwner();
        ctrl.ChangeOwner();
        proposal = [select id, ownerID  from Apttus_Proposal__Proposal__c where id =:Proposal.Id];
        System.assertEquals(proposal.ownerID, UserInfo.getUserId());
        Test.stopTest();
       }
}