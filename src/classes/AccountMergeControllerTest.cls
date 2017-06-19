/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class AccountMergeControllerTest {

    static testMethod void myUnitTest() {
        Account testAcc = TestDataSetupUtility.createTestAccountWithShipping('Test Account');
        testAcc.Phone = '4353453345';
        //testAcc.AccountID__c = '12345';
        insert testAcc;
        
        Account testAcc2 = TestDataSetupUtility.createTestAccountWithShipping('Test Account Whoopa');
        testAcc2.Phone = '4353453332';
        testAcc2.ShippingCity = 'Whitewater';
        testAcc2.ShippingPostalCode = '09984';
        testAcc2.ShippingCountryCode = 'US';
        testAcc2.ShippingState = 'Utah';
        testAcc2.ShippingStateCode = 'UT';
        testAcc2.ShippingStreet = '100 Shipping Lane';
        testAcc2.BillingStreet = '47 Yellow Rd';
        testAcc2.BillingCity = 'Niskayuna';
        testAcc2.BillingCountryCode = 'US';
        testAcc2.BillingState = 'New York';
        testAcc2.BillingStateCode = 'NY';
        testAcc2.BillingPostalCode = '12309';

        insert testAcc2;
        
        PageReference pageRef = Page.AccountMerge;
        Test.setCurrentPage(pageRef);
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', testAcc.Id);
        
        AccountMergeController ctrl = new AccountMergeController();
        ctrl.searchText = 'Test Account';
        
        ctrl.constructPage();
        ctrl.search();
        ctrl.selectedAccountId = testAcc.Id;
        //ctrl.validateSearchCrit();
        ctrl.navigateToMergePage();
        ctrl.performMerge();
        ctrl.navigateToSearch();
        ctrl.results[0].isSelected = true;
        ctrl.getSelList();
        ctrl.cancel();
        
    }
}