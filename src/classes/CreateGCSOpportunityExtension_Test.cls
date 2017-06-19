@isTest
public class CreateGCSOpportunityExtension_Test {

    static testMethod void testCreateGCSOpportunityExtension(){
        Test.startTest();
        Apttus_Proposal__Proposal__c proposal = null;
		Account acct = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TestAcct_28_07_15');
		
		Account agencyAccount = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Agency Account');
        agencyAccount.AgencyFlag__c = true;
        agencyAccount.CreditStatus__c = 'Ok';
        insert new List<Account> {acct,agencyAccount};
        RelatedPartner__c relatedPartner = TestDataSetupUtility.createTestRelatedPartner(acct.Id,agencyAccount.Id);
        insert relatedPartner;
		Contact con = TestDataSetupUtility.createTestContact(acct.Id, 'Test_Last', 'Test_First', 'test@test.com');
		insert con;
		Opportunity oppt = TestDataSetupUtility.createTestOpportunity('TestOppt_28_07_15', acct.Id);
		insert oppt;
        proposal = TestDataSetupUtility.createProposal('TEST_PROP_28_07_15', acct.Id, oppt.Id, 'test', false);
        insert proposal;
        apexPages.standardController controller = new apexPages.standardController(proposal);
        ApexPages.CurrentPage().getParameters().put('Id',proposal.Id);
        CreateGCSOpportunityExtension ext = new CreateGCSOpportunityExtension();
        System.assertEquals(true, ext.partnerListOptions.size()>1);
        ext.findPartner();
        ext.selectPartnerId = relatedPartner.Id; 
        try{
        	ext.Save();
        }catch(Exception e){}
        ext.Cancel();
        Test.stopTest();
    }
}