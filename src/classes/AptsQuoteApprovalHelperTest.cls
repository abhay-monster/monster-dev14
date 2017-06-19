@isTest
private class AptsQuoteApprovalHelperTest {
	static User testuser;
	static User testuser1;
	static User manager,manager1,manager2,manager3,manager4,manager5,manager6,manager7,manager8,manager9;
	static Account accnt;
	static Account account1;
    static Apttus_Proposal__Proposal__c proposal;
    static Apttus_Proposal__Proposal__c proposal1;
    static Apttus_Proposal__Proposal__c proposal9;
    static Apttus_Proposal__Proposal__c proposal2;
    static Apttus_Proposal__Proposal__c proposal3;
    static Apttus_Proposal__Proposal__c proposal4;
    static Apttus_Proposal__Proposal__c proposal5;
    static Apttus_Proposal__Proposal__c proposal6;
    static Apttus_Proposal__Proposal__c proposal7;
    static Apttus_Proposal__Proposal__c proposal8;
    static List<Apttus_Proposal__Proposal__c> proposalList;
	static {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
		
	//manager10 = TestDataSetupUtility.createTestUser('Test Manager10', 'System Admin', p.Id);
	//	manager10.Discount_Threshold__c = 12.0;
	//	insert manager10;
		
		manager9 = TestDataSetupUtility.createTestUser('Test Manager9', 'System Admin', p.Id);
		manager9.Discount_Threshold__c = 30.0;
		insert manager9;
		
		manager8 = TestDataSetupUtility.createTestUser('Test Manager8', 'System Admin', p.Id);
		manager8.Discount_Threshold__c = 28.0;
		manager8.ManagerId = manager9.Id;
		insert manager8;
		
		
		manager7 = TestDataSetupUtility.createTestUser('Test Manager7', 'System Admin', p.Id);
		manager7.Discount_Threshold__c = 26.0;
		manager7.ManagerId = manager8.Id;
		insert manager7;
		
		manager6 = TestDataSetupUtility.createTestUser('Test Manager6', 'System Admin', p.Id);
		manager6.Discount_Threshold__c = 24.0;
		manager6.ManagerId = manager7.Id;
		insert manager6;
		
		manager5 = TestDataSetupUtility.createTestUser('Test Manager5', 'System Admin', p.Id);
		manager5.Discount_Threshold__c = 22.0;
		manager5.ManagerId = manager6.Id;
		insert manager5;
		
		manager4 = TestDataSetupUtility.createTestUser('Test Manager4', 'System Admin', p.Id);
		manager4.Discount_Threshold__c = 20.0;
		manager4.ManagerId = manager5.Id;
		insert manager4;
		
		manager3 = TestDataSetupUtility.createTestUser('Test Manager3', 'System Admin', p.Id);
		manager3.Discount_Threshold__c = 18.0;
		manager3.ManagerId = manager4.Id;
		insert manager3;
		
		manager2 = TestDataSetupUtility.createTestUser('Test Manager2', 'System Admin', p.Id);
		manager2.Discount_Threshold__c = 16.0;
		manager2.ManagerId = manager3.Id;
		insert manager2;
		
		manager1 = TestDataSetupUtility.createTestUser('Test Manager1', 'System Admin', p.Id);
		manager1.Discount_Threshold__c = 14.0;
		manager1.ManagerId = manager2.Id;
		insert manager1;
		
		manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
		manager.Discount_Threshold__c = 12.0;
		manager.ManagerId = manager1.Id;
		insert manager;
		
	    testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
	    testUser.ManagerId = manager.Id;
	    testUser.Discount_Threshold__c  = 10.0;
	    insert testuser;
	    testUser1 = TestDataSetupUtility.createTestUser('Test1 ', 'System Admin', p.Id);
	    testUser1.ManagerId = manager.Id;
	    testUser1.Discount_Threshold__c  = 15.0;
	    insert testuser1;
	    
	    	System.runAs(testUser1)
	    	{
	    	 
	    	account1 = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Accnt');
	        system.debug('after account ' + account1);
	        insert account1;
	        
	        
	        //create Opportunity
	        Opportunity opp1 = TestDataSetupUtility.createTestOpportunity('Test Opp1', account1.Id);
	        opp1.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'Opportunity');
	        insert opp1;
	        
	        //Create product2
	        Product2 product1 = TestDataSetupUtility.createProduct('Test product', false); 
	        product1.Convert_From__c = true;
	        product1.Service_Type__c = 'Usage';
	        insert product1;
	        
	        //Create price list
	        Apttus_Config2__PriceList__c price1 = TestDataSetupUtility.createPriceList('USD Price List', false);
	        insert price1; 
	    	    
	    	proposal = TestDataSetupUtility.createProposal('Test Proposal', account1.Id, opp1.Id, 'Accepted Online', false);
	        proposal.Apttus_QPConfig__PriceListId__c = price1.id;
	        proposal.Total_Thresold_Discretionary_Discount__c  = 10;
	        proposal.OwnerId=testuser1.Id;
            proposal.APTS_Quote_Type__c = 'Product Conversion';
	        insert proposal;
	        
	    	}
		
		System.runAs(testUser){
			// Create test account
	        accnt = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account1');
	        system.debug('after account ' + accnt);
	        insert accnt;
	        
	        
	        //create Opportunity
	        Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', accnt.Id);
	        opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'Opportunity');
	        insert opp;
	        
	        //Create product2
	        Product2 product = TestDataSetupUtility.createProduct('Test product1', false); 
	        product.Convert_From__c = true;
	        product.Service_Type__c = 'Usage';
	        insert product;
	        
	        //Create price list
	        Apttus_Config2__PriceList__c price = TestDataSetupUtility.createPriceList('USD Price List', false);
	        insert price; 
	        
	        //create proposal
	        
	        proposal1 = TestDataSetupUtility.createProposal('Test Proposal11', accnt.Id, opp.Id, 'Accepted Online', false);
	        proposal1.Apttus_QPConfig__PriceListId__c = price.id;
	        proposal1.Total_Thresold_Discretionary_Discount__c = 13;
	        proposal1.OwnerId=testuser.Id;
	        
	        
	        proposal2 = TestDataSetupUtility.createProposal('Test Proposal2', accnt.Id, opp.Id, 'Accepted Online', false);
	        proposal2.Apttus_QPConfig__PriceListId__c = price.id;
	        Proposal2.Manager1__c=manager.Id;
	        proposal2.Total_Thresold_Discretionary_Discount__c = 15;
	        proposal2.OwnerId=testuser.Id;
	        
	        proposal3 = TestDataSetupUtility.createProposal('Test Proposal3', accnt.Id, opp.Id, 'Accepted Online', false);
	        proposal3.Apttus_QPConfig__PriceListId__c = price.id;
	        Proposal3.Manager1__c=manager.Id;
	        Proposal3.Manager2__c=manager.Id;
	        proposal3.Total_Thresold_Discretionary_Discount__c  = 17;
	        proposal3.OwnerId=testuser.Id;
	        
	        proposal4 = TestDataSetupUtility.createProposal('Test Proposal4', accnt.Id, opp.Id, 'Accepted Online', false);
	        proposal4.Apttus_QPConfig__PriceListId__c = price.id;
	        proposal4.Total_Thresold_Discretionary_Discount__c  = 19;
	        proposal4.OwnerId=testuser.Id;
	        
	        proposal5 = TestDataSetupUtility.createProposal('Test Proposal5', accnt.Id, opp.Id, 'Accepted Online', false);
	        proposal5.Apttus_QPConfig__PriceListId__c = price.id;
	        proposal5.Total_Thresold_Discretionary_Discount__c  = 21;
	        proposal5.OwnerId=testuser.Id;
	        
	        proposal6 = TestDataSetupUtility.createProposal('Test Proposal6', accnt.Id, opp.Id, 'Accepted Online', false);
	        proposal6.Apttus_QPConfig__PriceListId__c = price.id;
	        proposal6.Total_Thresold_Discretionary_Discount__c  = 23;
	        proposal6.OwnerId=testuser.Id;
	        
	        proposal7 = TestDataSetupUtility.createProposal('Test Proposal7', accnt.Id, opp.Id, 'Accepted Online', false);
	        proposal7.Apttus_QPConfig__PriceListId__c = price.id;
	        proposal7.Total_Thresold_Discretionary_Discount__c  = 25;
	        proposal7.OwnerId=testuser.Id;
	        
	        proposal8 = TestDataSetupUtility.createProposal('Test Proposal8', accnt.Id, opp.Id, 'Accepted Online', false);
	        proposal8.Apttus_QPConfig__PriceListId__c = price.id;
	        proposal8.Total_Thresold_Discretionary_Discount__c  = 27;
	        proposal8.OwnerId=testuser.Id;
	        
	        
	        proposal9 = TestDataSetupUtility.createProposal('Test Proposal1', accnt.Id, opp.Id, 'Accepted Online', false);
	        proposal9.Apttus_QPConfig__PriceListId__c = price.id;
	        proposal9.Total_Thresold_Discretionary_Discount__c  = 29;
	        proposal9.OwnerId=testuser.Id;
	        proposalList=new List<Apttus_Proposal__Proposal__c>{proposal9,proposal1,proposal2,proposal3,proposal4,proposal5,proposal6,proposal7,proposal8};
	        insert proposalList;
		}
	}
	static testMethod void testAptsQuoteHelper(){
		System.runAs(testUser){
			Test.startTest();
			//	AptsQuoteApprovalHelper.updateManager(new List<Apttus_Proposal__Proposal__c>{proposal,proposal2});
				proposalList.add(proposal);
				AptsQuoteApprovalHelper.updateManager(proposalList);
			Test.stopTest();
		}
	}
}