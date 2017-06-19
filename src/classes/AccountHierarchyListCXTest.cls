@isTest
public with sharing class AccountHierarchyListCXTest {
       static Account acc, parentAcc;
       static testMethod void testAccountHierarchy() {
           prepareData();
           Test.startTest();
           ApexPages.currentPage().getParameters().put('id',parentAcc.Id);
           AccountHierarchyListCX ctrl = new AccountHierarchyListCX(new ApexPages.StandardController(parentAcc));
           ApexPages.StandardSetController ssc = ctrl.AccountList;
           System.assert(ctrl.levelOptions.size() > 0);
           //System.assert(ctrl.hasNext);
           ctrl.getAccountPagination();          
           ctrl.getNoAccountMessage();
           ctrl.getPageStatistics();
           ctrl.next();          
           ctrl.previous();
           
           Boolean next = ctrl.hasNext;
           boolean previous = ctrl.hasPrevious;
           Test.stopTest();
       }
       
       static void prepareData(){
           parentAcc = TestDataSetupUtility.createTestAccount('Test','test',UserInfo.getUserId());
           insert parentAcc;
           acc = TestDataSetupUtility.createTestAccountWithShipping('Test_AccountHierarchyListCXTest');
           acc.parentId = parentAcc.Id;
           insert acc;
           
           /*acc = TestDataSetupUtility.createTestAccount('Test_AccountHierarchyListCXTest ','test_AccountHierarchyListCXTest',UserInfo.getUserId());
           acc.parentId = parentAcc.Id;
            acc.BillingStreet = 'Green Street1'; 
            acc.BillingCity = 'NY';
            acc.BillingState = 'California';
            acc.BillingPostalCode = '951223';
            acc.BillingCountry = 'United States'; 
           insert acc;*/
       }
       
}