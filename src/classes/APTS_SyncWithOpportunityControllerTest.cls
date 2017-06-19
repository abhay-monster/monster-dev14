@isTest

public with sharing class APTS_SyncWithOpportunityControllerTest {
	static testMethod void createData(){
        Account acc  = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
		insert acc;

		List<Contact> lstCon = new List<Contact>();
		Contact con = TestDataSetupUtility.createTestContact(acc.Id, 'Test 1', 'Last 1', 'test@test.com');
		lstCon.add(con);
        Contact con2 = TestDataSetupUtility.createTestContact(acc.Id, 'Test 2', 'Last 2', 'con@test.com');
        lstCon.add(con2);
        insert lstCon;

        acc.PrimaryBillingContact__c = lstCon[0].Id;
        update acc;

		Opportunity opp = TestDataSetupUtility.createTestOpportunity('TestOpp' , acc.Id);
		insert opp;


		Apttus_Proposal__Proposal__c proposal = TestDataSetupUtility.createProposal(opp.Id);
		proposal.BillContact__c = lstCon[0].Id;
        proposal.PostingContact__c = lstCon[1].Id;
        //proposal.Apttus_Proposal__Primary__c = true;
		insert proposal;

		Product2 product = TestDataSetupUtility.createProduct('Test Product' ,  true);

		Apttus_Config2__PriceList__c aptusConfigPriceList = TestDataSetupUtility.createPriceList('TestPrice',true);


		Apttus_Config2__ProductConfiguration__c aptusConfig = TestDataSetupUtility.createTestProductConfig(proposal , acc , aptusConfigPriceList);
		aptusConfig.Apttus_Config2__Status__c = 'Finalized';

		insert aptusConfig;

		Apttus_Config2__LineItem__c aptusLineItem = TestDataSetupUtility.createLineItemApttus(aptusConfig.Id);
		
		
		insert aptusLineItem;
		Apttus_Config2__ProductAttributeGroup__c aptusGroup = TestDataSetupUtility.createGroup('TestGroup');
		insert aptusGroup;

		Apttus_Config2__ProductAttributeGroupMember__c aptusGrpMember = TestDataSetupUtility.createProductGroupMember('TestGroupMember' , aptusGroup.Id,product.Id);
		
		insert aptusGrpMember; 
        
        Apttus_Proposal__Proposal_Line_Item__c proposalLineItem = TestDataSetupUtility.createProposalLineItem(proposal.Id);
		//proposalLineItem.Apttus_Proposal__Primary__c = true;
		proposalLineItem.Apttus_Proposal__Proposal__c = proposal.Id;
		proposalLineItem.Apttus_QPConfig__ConfigurationId__c = aptusConfig.Id;
		//proposalLineItem.Apttus_Proposal__Product__c = product.Id;
		proposalLineItem.Apttus_QPConfig__DerivedFromId__c = aptusLineItem.Id;
		insert proposalLineItem;
        
        //Set test page
        Test.setCurrentPage(Page.APTS_SyncWithOpportunity);
        
        //Set test page parameter
        ApexPages.currentPage().getParameters().put('ID', proposal.Id);
        //Call test page constructer
        APTS_SyncWithOpportunityController APTSSyncWithOpportunityController  = new APTS_SyncWithOpportunityController();
        APTSSyncWithOpportunityController.SyncWithOpportunity();  
    }
}