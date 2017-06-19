@isTest
private class CreditRequestApprovalEmailControllerTest{
     static Credit_Request__c  creditRequest;
    static Apttus_Approval__Approval_Request__c approvalRequest;
    
    static void prepareData(){
        Account acc = TestDataSetupUtility.createTestAccount('test',null,null);
        insert acc;
        Contact con = TestDataSetupUtility.createTestContact(acc.Id, 'confirst1', 'conlast1', 'con1@email.com');
        insert con;
        Order__c orderRec = TestDataSetupUtility.createOrder(acc.Id, con.Id);
        insert orderRec;
        creditRequest = TestDataSetupUtility.createCreditRequest(orderRec.Id);
        insert creditRequest ;
        approvalRequest = new Apttus_Approval__Approval_Request__c ();
        approvalRequest.Apttus_Approval__Object_Id__c = creditRequest .Id;
        insert approvalRequest ;        
        
    }

    static testMethod void creditRequest(){
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
        
        Order_Line_Item__c item = [SELECT Id,Name,order__c FROM Order_Line_Item__c WHERE Id=: oli.id];
         
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

        Test.startTest();
        CreditRequestApprovalEmailController ctrl = new CreditRequestApprovalEmailController();
        ctrl.getContext();
        ctrl.getCreditRequestSO();
        Test.stopTest();
     }
}