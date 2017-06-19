/**
 */
@isTest
private class AccountHierarchyCCTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Account acc2 = new Account(name = 'Parentaccount');
        insert acc2;
        
        Account acc3 = new Account(name = 'Parent2account',ParentId = acc2.id);
        insert acc3;
        
        Account acc4 = new Account(name = 'Parent3account',ParentId = acc3.id);
        insert acc4;
        
        Account acc5 = new Account(name = 'Parent4account',ParentId = acc4.id);
        insert acc5;
        
        Account acc6 = new Account(name = 'Parent5account',ParentId = acc5.id);
        insert acc6;
        
        List<Account> acc = new List<Account>();
        acc.add(new Account(name='testAcc',ParentId = acc6.id));
        insert acc;
        
        ApexPages.currentPage().getParameters().put('id',acc[0].id);
        
        ApexPages.StandardSetController setCtrl = new ApexPages.StandardSetController(acc);
        AccountHierarchyCC ahc = new AccountHierarchyCC(setCtrl);
        List<Standard_Reports__c> listReports = new List<Standard_Reports__c>();
        
        listReports.add(new Standard_Reports__c(Name='Activity Report',Report_Id__c = '00Oq0000000Vl6J'));
        listReports.add(new Standard_Reports__c(Name='Contact Report',Report_Id__c = '00Oq0000000Vl6K'));
        listReports.add(new Standard_Reports__c(Name='Opportunity Report',Report_Id__c = '00Oq0000000Vl6M'));
        listReports.add(new Standard_Reports__c(Name='Quote/Proposal Report',Report_Id__c = '00Oq0000000Vl6O'));
        listReports.add(new Standard_Reports__c(Name='Order Report',Report_Id__c = '00Oq0000000Vl6N'));
        listReports.add(new Standard_Reports__c(Name='Case Report',Report_Id__c = '00Oq0000000Vl6K')); 
        
        insert listReports;
        ApexPages.StandardController ctrl = new ApexPages.StandardController(acc[0]);
        AccountHierarchyCC ahc1 = new AccountHierarchyCC(ctrl);
        
        ApexPages.StandardController ctrl2 = new ApexPages.StandardController(acc6);
        AccountHierarchyCC ahc2 = new AccountHierarchyCC(ctrl2);
        
        ApexPages.StandardController ctrl3 = new ApexPages.StandardController(acc5);
        AccountHierarchyCC ahc3 = new AccountHierarchyCC(ctrl3);
        
        ApexPages.StandardController ctrl4 = new ApexPages.StandardController(acc4);
        AccountHierarchyCC ahc4 = new AccountHierarchyCC(ctrl4);
        
        ApexPages.StandardController ctrl5 = new ApexPages.StandardController(acc3);
        AccountHierarchyCC ahc5 = new AccountHierarchyCC(ctrl5);
        
        ApexPages.StandardController ctrl6 = new ApexPages.StandardController(acc2);
        AccountHierarchyCC ahc6 = new AccountHierarchyCC(ctrl6);
    }
}