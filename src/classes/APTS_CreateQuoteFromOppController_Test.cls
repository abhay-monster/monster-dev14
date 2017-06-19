@isTest
public class APTS_CreateQuoteFromOppController_Test {

	static testMethod void testAPTS_CreateQuoteFromOppController(){
		Account acct = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TestAcct_28_07_15');
		insert acct;
		Opportunity oppt = TestDataSetupUtility.createTestOpportunity('TestOppt_28_07_15', acct.Id);
		insert oppt;
		ApexPages.currentPage().getParameters().put('oppid', oppt.Id);
		APTS_CreateQuoteFromOppController controller = new APTS_CreateQuoteFromOppController();
		controller.createAndRedirect();
		controller.doCancel();
		controller.HasErrors = false;
	}
}