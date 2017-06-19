/*
** @author : Cloud Sherpas Inc.
** @date : 09/11/2014
** @description : Sales Attinment Trigger for all CRUD events. 
*/
@isTest
private class CreateCreditOrderTest {
  static testMethod void myUnitTest() {
        
        Account acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        insert acc;   
        
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp ', acc.Id);
        insert opp; 
        
        Apttus_Proposal__Proposal__c quote = TestDataSetupUtility.createApttusProposal(opp);
        insert quote;
        
        Contact con = TestDataSetupUtility.createTestContact(acc.Id, 'confirst1', 'conlast1', 'con1@email.com');
        insert con;
        
        Order__c ord = TestDataSetupUtility.createOrder(acc.Id, con.Id);
        ord.Opportunity__c = opp.Id;
        ord.QuoteProposal__c = quote.Id;
        insert ord;
        
         
        List<Order_Line_Item__c> OLIList = new List<Order_Line_Item__c>();
        Order_Line_Item__c oli = TestDataSetupUtility.createOrderLineItem(ord.Id);
        insert oli;
        
        Order_Line_Item__c item = [SELECT Id,Name,order__c
         FROM Order_Line_Item__c WHERE Id=: oli.id];
         
         system.debug('******item ****' +item );
        
        LicenseID__c licenseId = new LicenseID__c();
        licenseId.OrderLineItem__c = oli.id;
        //licenseId.SiteLicenseID__c = 'Test';
        insert licenseId ;
        
        LicenseID__c licenseId1 = new LicenseID__c();
        licenseId1.OrderLineItem__c = oli.id;
        licenseId1.SiteLicenseID__c = 'Test';
        insert licenseId1 ;
        
        Credit_Request__c cr = TestDataSetupUtility.createCreditRequest(ord.Id);
        cr.CreditReason__c = 'Tax Error';
        insert cr;
        
        Credit_Request__c cr1 = TestDataSetupUtility.createCreditRequest(ord.Id);
        //cr1.CreditReason__c = 'Tax Error';
        insert cr1;
        
        CreditRequestLineItem__c lineItem1 = new CreditRequestLineItem__c();
        lineItem1.Credit_Request__c = cr1.Id;
        lineItem1.Order_Line_Item__c = oli.id;
        lineItem1.TaxAmount__c = 30;
        lineItem1.CreditType__c = 'Inventory';
        insert lineItem1; 
        
        Credit_Request_License_ID__c creditLicense1 = new Credit_Request_License_ID__c();
        creditLicense1.CreditRequest__c = cr1.Id;
        creditLicense1.CreditRequestLineItem__c = lineItem1.Id;
        creditLicense1.LicenseID__c = licenseId1.Id; 
        insert creditLicense1 ;
        
        CreditRequestLineItem__c lineItem = new CreditRequestLineItem__c();
        lineItem.Credit_Request__c = cr.Id;
        lineItem.CreditType__c = 'Inventory';
        lineItem.Order_Line_Item__c = oli.id;
        lineItem.TaxAmount__c = 30;
        insert lineItem ;
        
        Credit_Request_License_ID__c creditLicense = new Credit_Request_License_ID__c();
        creditLicense.CreditRequest__c = cr.Id;
        creditLicense.CreditRequestLineItem__c = lineItem .Id;
        creditLicense.LicenseID__c = licenseId.Id; 
        insert creditLicense ;
        
        
       
        
        Test.StartTest();
        
        PageReference pageRef = Page.CreateCreditOrderFromCreditRequestPG;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('crid',cr.id);
        ApexPages.currentPage().getParameters().put('oid',ord.id);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(cr);
        CreateCreditOrderFromCreditRequest ctrl = new CreateCreditOrderFromCreditRequest (sc);
        ctrl.executeMethod();
        system.assertNotEquals(ctrl,null);
        
         PageReference pageRef1 = Page.CreateCreditOrderFromCreditRequestPG;
        Test.setCurrentPage(pageRef1);
        ApexPages.currentPage().getParameters().put('crid',cr1.id);
        ApexPages.currentPage().getParameters().put('oid',ord.id);
        ApexPages.Standardcontroller sc1 = new ApexPages.Standardcontroller(cr1);
        CreateCreditOrderFromCreditRequest ctrl1 = new CreateCreditOrderFromCreditRequest (sc1);
        ctrl1.executeMethod();
        system.assertNotEquals(ctrl1,null);
        ctrl = new CreateCreditOrderFromCreditRequest (cr1.id,ord.id);
        Test.STopTest();
        
        }
    }