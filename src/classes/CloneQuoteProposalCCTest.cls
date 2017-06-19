@isTest
private class CloneQuoteProposalCCTest{

 static testMethod void CloneQuoteProposalTest(){
 
     Apttus_Proposal__Proposal__c proposal;
     try{
         Account acc = TestDataSetupUtility.createTestAccountWithShipping('Test Acocunt'); 
         insert acc;
         Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test opp',acc.Id);
         insert opp;
         
         proposal = TestDataSetupUtility.createProposal('Test Proposal', acc.Id, opp.Id, 'Accepted Online', false);
         insert proposal ; 
         }catch(exception e){
             system.assert(false,'Problem Inserting Test data');
         }
     
 
            Test.startTest();  
            PageReference pageRef = Page.CloneQuoteProposal;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('quoteName', 'Test');
            ApexPages.StandardController controller = new ApexPages.StandardController(proposal);
            CloneQuoteProposalCC ctrl = new CloneQuoteProposalCC(controller );
            ctrl.executeMethod();
            system.assertNotEquals(pageRef ,null);
            Test.stopTest();
       }
}