@isTest
public class APTS_ApprovalSubmissionController_Test {
	
	static testMethod void testAPTS_ApprovalSubmissionController(){
		Test.startTest();
		
		Id propId = getProposal().id; 
		ApexPages.currentPage().getParameters().put('sObjectId',propId);
		APTS_ApprovalSubmissionController controller = new APTS_ApprovalSubmissionController();
		controller.BackToProposal();
		controller.SubmitApproval();
		
		Apttus_Config2__ProductConfiguration__c config = new Apttus_Config2__ProductConfiguration__c();
		config.Apttus_QPConfig__Proposald__c = propId;
		config.Apttus_Config2__Status__c = 'test';
		insert config;
		
		controller.PreviewApprovals();
		controller.SubmitComment = 'test';
		try{
		controller.doOk();
		}catch(Exception e){}
		APTS_ApprovalSubmissionController.ApprovalStep appStep = new APTS_ApprovalSubmissionController.ApprovalStep('test','test1',new Apttus_Approval__Approval_Request__c(), 'testComment', false);
		
		Test.stopTest();
	}
	
	private static Apttus_Proposal__Proposal__c getProposal(){
		Apttus_Proposal__Proposal__c proposal = null;
		Account acct = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TestAcct_28_07_15');
		insert acct;
		Contact con = TestDataSetupUtility.createTestContact(acct.Id, 'Test_Last', 'Test_First', 'test@test.com');
		insert con;
		Opportunity oppt = TestDataSetupUtility.createTestOpportunity('TestOppt_28_07_15', acct.Id);
		insert oppt;
		proposal = TestDataSetupUtility.createProposal('TEST_PROP_28_07_15', acct.Id, oppt.Id, 'test', false);
		insert proposal;
		return proposal;
	}
}