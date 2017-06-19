@isTest
Private Class CreditRequestApprovalSummaryCtrl_Test {
    static Credit_Request__c  creditRequest;
    static Apttus_Approval__Approval_Request__c approvalRequest;
    
    static testMethod void testCreditRequestApproval(){
        Test.startTest();
        prepareData();
        ApexPages.StandardController std = new ApexPages.StandardController(approvalRequest);
        CreditRequestApprovalSummaryController controller = new CreditRequestApprovalSummaryController(std );
        System.assert(controller.getCreditRequestSO() != null);
        Test.stopTest();
    }
    
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
    
}