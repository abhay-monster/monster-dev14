/**
 * @author Cloudsherpas
 * @date 12.4.14
 * @description Test class for CustomAccountLookupController class
 */
@isTest
private class CustomAccountLookupControllerTest {
	/* static Account createRec(){
		//TestDataSetupUtility testData = new TestDataSetupUtility();
		Account parentAcc = TestDataSetupUtility.createTestAccount('Test Parent', 'North America', UserInfo.getUserId());
		parentAcc.IsGlobalHQ__c = true;
		insert parentAcc;
		
		List<Account> childAccts = new List<Account>();
		for(Integer i = 0; i < 10; i++){
			Account node = TestDataSetupUtility.createTestAccount('Test Child ' + i, 'North America', UserInfo.getUserId());
			node.ParentId = parentAcc.Id;
			node.IsDomesticHQ__c = true;
			childAccts.add(node);
		}
		insert childAccts;
		//test if 11 accounts has been created
		System.assertEquals(11, [Select Id from Account].size());
		return parentAcc;
	}
	/**
	 * @author Cloudsherpas
	 * @date 12.4.14
	 * @description Positive Test method to verify that the page will load as expected
	 
    static testMethod void testPageLoad() {
    	Account acct = createRec();
        Test.startTest();
        	PageReference pageRef = Page.CustomAccountLookup;
        	Test.setCurrentPage(pageRef);
        	pageRef.getParameters().put('lksrch', acct.Id);
        	pageRef.getParameters().put('txt', 'tst');
        	pageRef.getParameters().put('frm', 'form');
        	CustomAccountLookupController ctrl = new CustomAccountLookupController();
        	System.assertEquals('tst', ctrl.getTextBox());
        	System.assertEquals('form', ctrl.getFormTag());
        Test.stopTest();
    }
    
    /**
	 * @author Cloudsherpas
	 * @date 12.4.14
	 * @description Positive Test method search String AccountId
	 
    static testMethod void testSearchText() {
    	Account acct = createRec();
        Test.startTest();
        	PageReference pageRef = Page.CustomAccountLookup;
        	Test.setCurrentPage(pageRef);
        	pageRef.getParameters().put('lksrch', acct.Id);
        	CustomAccountLookupController ctrl = new CustomAccountLookupController();
        	ctrl.searchStr = [Select AccountId__c from Account where Id = : acct.Id].AccountId__c;
        	System.assertNotEquals(null, ctrl.searchStr);
        	ctrl.search();
        	System.assertEquals(1, ctrl.results.size());
        Test.stopTest();
    } */
}