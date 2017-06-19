/*
** @author : Apptus- Viraj Rana.
** @date : 11/09/2016
** @description : Unit test class for APTS_EscalateApprovalOnQuote Class
*/

@isTest
private with sharing class APTS_EscalateApprovalOnQuoteTest{
    static User manager, testUser;
    static Account account;
    static Apttus_Proposal__Proposal__c proposal_n;
    
    @isTest
    static void Callconstructor() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        insert manager;
        testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        testUser.Discount_Threshold__c  = 10.0;
        testUser.Apttus_Approval_Escalation__c  = true;
        insert testuser;
        
        System.runAs(testUser){
        
             // Create test account
            account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
            system.debug('after account ' + account);
            //account.Registration__c = entID.Id;
           
            //System.debug('Xdebug__ account entityid: ' + account.Registration__c);
            insert account;
            
            //create Opportunity
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', account.Id);
            opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'GCS Opportunity');
            insert opp;
            
            //Create price list
            Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
            insert priceList; 
            
            // create proposal
            proposal_n = new Apttus_Proposal__Proposal__c();
            proposal_n.Apttus_Proposal__Account__c = account.Id;
            proposal_n.Apttus_Proposal__Opportunity__c = opp.Id;
            proposal_n.Language__c = 'English';
            proposal_n.Selling_Country__c = 'Austria';
            proposal_n.Apttus_QPConfig__PriceListId__c = priceList.Id;
            proposal_n.BillingStreet__c = 'something';
            proposal_n.BillingCity__c = 'something';
            proposal_n.BillingCountry__c = 'Algeria';
            proposal_n.BillingZipPostalCode__c = 'something';
            proposal_n.QuoteStatus__c = 'Accepted Online';
            insert proposal_n;
            
            Apttus__APTS_Agreement__c agmt= new Apttus__APTS_Agreement__c();
            agmt.Apttus__Account__c = account.Id;
            agmt.Name = 'Test Agreement';
            
            insert agmt;
        
            Apttus_Approval__Approval_Process__c processSO  = new Apttus_Approval__Approval_Process__c();
            processSo.Apttus_Approval__Process_Name__c = 'New Aproval Process';
            processSO.Apttus_Approval__Object_Name__c = 'Apttus__APTS_Agreement__c';
            processSO.Apttus_Approval__Object_Label__c = 'Agreement';
            insert processSO;
            
            Apttus_Approval__ApprovalProcessInstance__c api = new Apttus_Approval__ApprovalProcessInstance__c();
            api.Apttus_Approval__BusinessObjectId__c = 'Apttus__APTS_Agreement__c';
            api.Name = 'Test Approval Process Instance';
            api.Apttus_Approval__ApprovalProcessId__c = processSO.Id;
            insert api;
            
            test.Starttest();
            Apttus_Config2__ProductConfiguration__c config = TestDataSetupUtility.createTestProductConfig(proposal_n,account,priceList);
            config.Apttus_Config2__Status__c = 'Finalized';
            insert config;
            
            Apttus_Approval__Approval_Request__c requestSO = Apttus_Approval.TestSupport.createAssignmentRequest(testUser,
                                                                                                                 processSO.Id,
                                                                                                                 agmt.Id,
                                                                                                               'Test Agreement;');
            requestSO.Apttus_Approval__ProcessInstanceId__c = api.Id;
            requestSO.Apttus_Approval__Approval_Status__c = 'Assigned';
            requestSO.Apttus_CQApprov__CartId__c = config.Id;
            requestSO.Apttus_Approval__CanEscalate__c = true;
            requestSO.Is_Escalated_To_User__c = false;
            requestSO.Apttus_Approval__Initial_Submitter__c = testuser.Id;
            upsert requestSO;
            
            apexpages.currentpage().getparameters().put('id' , proposal_n.id);


            ApexPages.StandardController sc = new ApexPages.StandardController(proposal_n);
            APTS_EscalateApprovalOnQuote obj = new APTS_EscalateApprovalOnQuote(sc);
            APTS_EscalateApprovalOnQuote.ApprovalRequestEscalate(requestSO.Id);
            test.Stoptest();
        }
            
    }
    
}