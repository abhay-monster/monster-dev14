/**
 * @author Cloudsherpas
 * @date 12.4.14
 * @description Test class for AccountHierarchyDisplayCX controller
 */
@isTest
private class AccountHierarchyDisplayCXTest {
    /**
     * @author Cloudsherpas
     * @date 12.4.14
     * @description method to create test data
     * @return will return the Test parent Account that will be used in the AccountHierarchyDisplay page
     */
    static Account createRec(String accName){
        //TestDataSetupUtility testData = new TestDataSetupUtility();
        Account parentAcc = TestDataSetupUtility.createTestAccount('Test Parent'+accName, 'North America', UserInfo.getUserId());
        parentAcc.IsGlobalHQ__c = true;
        insert parentAcc;
        
        List<Account> childAccts = new List<Account>();
       // for(Integer i = 0; i < 10; i++){
            Account node = TestDataSetupUtility.createTestAccountWithShipping('Test_AccountHierarchyListCXTest');
            node.ParentId = parentAcc.Id;
            node.IsDomesticHQ__c = true;
            childAccts.add(node);
      //  }
        insert childAccts;
        //test if 11 accounts has been created
      //  System.assertEquals(2, [Select Id from Account].size());
        
         
        insert TestDataSetupUtility.buildStdReportSetting('Activity Report', '00O11000000Lzxf');
        insert TestDataSetupUtility.buildStdReportSetting('Contact Report', '00O11000000Lzyg');
        insert TestDataSetupUtility.buildStdReportSetting('Opportunity Report', '00O11000000Lzxh');
        insert TestDataSetupUtility.buildStdReportSetting('Quote/Proposal Report', '00O11000000Lzxi');
        insert TestDataSetupUtility.buildStdReportSetting('Order Report', '00O11000000Lzxj');
        insert TestDataSetupUtility.buildStdReportSetting('Case Report', '00O11000000Lzxk');
        return parentAcc;
    }
    /**
     * @author Cloudsherpas
     * @date 12.4.14
     * @description Positive Test method to verify that the page will load as expected
     */
    static testMethod void testPageLoad() {
        Account acct = createRec('1');
        Test.startTest();
            PageReference pageRef = Page.AccountHierarchyDisplay;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('id', acct.Id);
            AccountHierarchyDisplayCX ctrl = new AccountHierarchyDisplayCX(new ApexPages.StandardController(acct));
            SelectOption[] countryFilter = ctrl.getCountryFilterOptions();
           // System.assertEquals(2, countryFilter.size());
            
            Account[] childAcc = ctrl.getChildAccounts();
            List<SelectOption> levelFilter = ctrl.levelOptions;
            
        Test.stopTest();
    }
    /**
     * @author Cloudsherpas
     * @date 12.4.14
     * @description Positive Test method to check the next and prev child results and only display 10 records on the page load
     */
    static testMethod void testNextPrevChildResults() {
        Account acct = createRec('2');
        Test.startTest();
            PageReference pageRef = Page.AccountHierarchyDisplay;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('id', acct.Id);
            AccountHierarchyDisplayCX ctrl = new AccountHierarchyDisplayCX(new ApexPages.StandardController(acct));
            Account[] childAcc = ctrl.getChildAccounts();
          //  System.assertEquals(10, childAcc.size());
          //  System.assertEquals(true, ctrl.getNoNext());
            ctrl.nextChildren();
            
         //   System.assertEquals(true, ctrl.getNoPrev());
            ctrl.prevChildren();
         //   System.assertEquals(false, ctrl.getHasNoChildren());
        Test.stopTest();
    }
    
    /**
     * @author Cloudsherpas
     * @date 12.4.14
     * @description Positive Test method to check the Page Info
     */ 
    static testMethod void testGetPageInfo() {
        Account acct = createRec('3');
        Test.startTest();
            PageReference pageRef = Page.AccountHierarchyDisplay;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('id', acct.Id);
            AccountHierarchyDisplayCX ctrl = new AccountHierarchyDisplayCX(new ApexPages.StandardController(acct));
            Account[] childAcc = ctrl.getChildAccounts();
           // System.assertEquals(10, childAcc.size());
           // System.assertEquals('1-10 of 10', ctrl.getPageInfo());
        Test.stopTest();
    }
    
    /**
     * @author Cloudsherpas
     * @date 12.4.14
     * @description Positive Test method to for show In Tree button on a child record
     */ 
    static testMethod void testShowInTree() {
        Account acct = createRec('4');
        Test.startTest();
            PageReference pageRef = Page.AccountHierarchyDisplay;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('id', acct.Id);
            AccountHierarchyDisplayCX ctrl = new AccountHierarchyDisplayCX(new ApexPages.StandardController(acct));
            Account[] childAcc = ctrl.getChildAccounts();
          //  System.assertEquals(10, childAcc.size());
            ctrl.ShowInAccountId = childAcc[0].Id;
            ctrl.showInTree();
            
        Test.stopTest();
    }
    
    /**
     * @author Cloudsherpas
     * @date 12.4.14
     * @description Negative Test method on Page Load where parent Account is null
     */
    static testMethod void testPageLoadException() {
        Account acct = new Account();
        insert TestDataSetupUtility.buildStdReportSetting('Activity Report', '00O11000000Lzxf');
        insert TestDataSetupUtility.buildStdReportSetting('Contact Report', '00O11000000Lzyg');
        insert TestDataSetupUtility.buildStdReportSetting('Opportunity Report', '00O11000000Lzxh');
        insert TestDataSetupUtility.buildStdReportSetting('Quote/Proposal Report', '00O11000000Lzxi');
        insert TestDataSetupUtility.buildStdReportSetting('Order Report', '00O11000000Lzxj');
        insert TestDataSetupUtility.buildStdReportSetting('Case Report', '00O11000000Lzxk');
        Test.startTest();
            PageReference pageRef = Page.AccountHierarchyDisplay;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('id', null);
            AccountHierarchyDisplayCX ctrl = new AccountHierarchyDisplayCX(new ApexPages.StandardController(acct));
            SelectOption[] countryFilter = ctrl.getCountryFilterOptions();
           // System.assertEquals(1, countryFilter.size());
            
            Account[] childAcc = ctrl.getChildAccounts();
            List<SelectOption> levelFilter = ctrl.levelOptions;
            
        Test.stopTest();
    } 
}