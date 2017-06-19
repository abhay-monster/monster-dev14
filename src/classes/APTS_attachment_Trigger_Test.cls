@istest
public class APTS_attachment_Trigger_Test {
    	// @author: Aakash Khatri
	static User manager, testUser;
	static Account account;
	static Apttus_Proposal__Proposal__c proposal_n;
	static testMethod void testLineItems() {
	    Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
	    manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
		insert manager;
	    testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
	    testUser.ManagerId = manager.Id;
	    testUser.Discount_Threshold__c  = 10.0;
	    insert testuser;
	    
	    System.runAs(testUser){
			// Create test account
	        account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
	        system.debug('after account ' + account);
	        insert account;
	        
	        
	        //create Opportunity
	        Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', account.Id);
	        opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'GCS Opportunity');
	        insert opp;
	        
	   
	        //Create price list
	        Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
	        insert priceList; 
      
	        
	        //create proposal
	        proposal_n = TestDataSetupUtility.createProposal('Test Proposal', account.Id, opp.Id, 'Accepted Online', false);
	        proposal_n.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Apttus_Proposal__Proposal__c', 'Proposal');
            proposal_n.Apttus_QPConfig__PriceListId__c = priceList.id; 
            proposal_n.Language__c = 'English';
            system.debug('*****************:proposal ' + proposal_n.Language__c);

	        insert proposal_n;	
	       
            Attachment testattachment = new Attachment(name='test'+datetime.now() , body =Blob.valueOf('Test Data') , parentid = proposal_n.id); 
	        insert testattachment;
	        
        } 
	}
}