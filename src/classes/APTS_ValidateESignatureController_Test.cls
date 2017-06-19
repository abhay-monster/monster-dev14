@isTest
public class APTS_ValidateESignatureController_Test {

    static testMethod void testAPTS_ValidateESignatureController(){
        APTS_ValidateESignatureController controller = new APTS_ValidateESignatureController();
        Apttus_Proposal__Proposal__c proposal = null;
		Account acct = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TestAcct_28_07_15');
		insert acct;
		Contact con = TestDataSetupUtility.createTestContact(acct.Id, 'Test_Last', 'Test_First', 'test@test.com');
		insert con;
		Opportunity oppt = TestDataSetupUtility.createTestOpportunity('TestOppt_28_07_15', acct.Id);
		insert oppt;
        proposal = TestDataSetupUtility.createProposal('TEST_PROP_28_07_15', acct.Id, oppt.Id, 'test', false);
        insert proposal;
        controller.ProposalId = proposal.Id;
        ApexPages.CurrentPage().getParameters().put('id', proposal.Id);
        controller.ValidateForEsignature();
    }
}