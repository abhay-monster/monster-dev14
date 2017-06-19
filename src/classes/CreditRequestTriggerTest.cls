/*
@author : CloudSherpas
@description : Test the CreditRequestTriggerTest
@date : 06/16/2014
*/
@isTest
private class CreditRequestTriggerTest{
    /*
    @author : CloudSherpas
    @description : Test the UpdateRequest method
    @date : 06/16/2014
    */
    @isTest
    static void testOnUpdateRequest(){
        List<Account> accountList = new List<Account>();
        Account usedAccount = TestDataSetupUtility.createTestAccountWithShipping('Test Account');
        usedAccount.Phone = '20011111';
        accountList.add(usedAccount);
        insert accountList;
        
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opportunity', accountList[0].Id);
        
        oppList.add(opp);
        OpportunityTriggerHandler.PreventRecursion = true;
        insert oppList;

        List<Apttus_Proposal__Proposal__c> proList = new List<Apttus_Proposal__Proposal__c>();

        Apttus_Proposal__Proposal__c pro =  TestDataSetupUtility.createProposal('Test Proposal1', accountList[0].Id, oppList[0].Id, 'Accepted Online', false);

        proList.add(pro);
        insert proList;

        List<Apttus_Proposal__Proposal_Line_Item__c> proLineItemList = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        Apttus_Proposal__Proposal_Line_Item__c proLineItem = TestDataSetupUtility.createProposalLineItem(proList[0].Id);
        proLineItemList.add(proLineItem);
        insert proLineItemList;

        Test.starttest();
            List<Order__c> orderList = new List<Order__c>();
            Contact con = TestDataSetupUtility.createTestContact(AccountList[0].Id, 'confirst1', 'conlast1', 'con1@email.com');
            insert con;
            Order__c ord = TestDataSetupUtility.createOrderWithOpportunity(AccountList[0].Id, oppList[0].Id, proList[0].Id, con.Id);
            ord.QuoteProposal__c = proList[0].Id;
            orderList.add(ord);
            insert orderList;
            Order_Line_Item__c orderLine = TestDataSetupUtility.createOrderLineItem(ord.Id);
            insert orderLine;
  
            List<Credit_Request__c> creditRequestList = new List<Credit_Request__c>();
            Credit_Request__c creditRequest = TestDataSetupUtility.createCreditRequest(orderList[0].Id); 
            creditRequest.CreditScenario__c = 'Credit and Rebill';
            creditRequest.ApprovalStatus__c =  'Pending Response';
            creditRequest.CreditReason__c = 'Payment term changes';
            creditRequest.Credit_Type__c = 'Full';
            creditRequestList.add(creditRequest);
            insert creditRequestList;
            Map<Id,Credit_Request__c> creditRequestMapList = new Map<Id,Credit_Request__c>();
            creditRequestMapList.put(creditRequest.Id,creditRequest);
            
            
            List<Credit_Request__c> creditRequestUpdateList = new List<Credit_Request__c>();
            Credit_Request__c updateCredit = new Credit_Request__c();
            updateCredit = [SELECT Id, ApprovalStatus__c,order__c,CreditScenario__c,CreditReason__c,Credit_Type__c,RequestDate__c,Type__c,PrimarySalesRep__c  FROM Credit_Request__c WHERE ApprovalStatus__c =:  'Pending Response'];
            updateCredit.ApprovalStatus__c = 'Approved';
         	updateCredit.CreditReason__c = 'Incorrect tax';
            updateCredit.PaymentTerm__c = 'Net 15';
           	updateCredit.Payment_Method__c = 'Invoice';
        updateCredit.Payment_Frequency__c = 'Monthly';
        updateCredit.Billing_Start_Date__c = system.today();
        updateCredit.New_Number_of_Installments__c = 6;
         	creditRequestUpdateList.add(updateCredit);
            
            
            CreditRequestLineItem__c creditLineItem = new CreditRequestLineItem__c();
            creditLineItem.Credit_Request__c = updateCredit.Id;
            creditLineItem.CreditType__c = 'Inventory';
            creditLineItem.Order_Line_Item__c = orderLine.Id;
            //creditLineItem.CurrencyIsoCode = 'USD - U.S. Dollar';
            creditLineItem.TaxAmount__c = 10;
            creditLineItem.AvailableCreditAmount__c = 10;
            creditLineItem.CreditAmount__c = 10;
            creditLineItem.NetCreditAmount__c = 10;
            creditLineItem.NetRemainingCreditAmount__c = 10;
            creditLineItem.NetTotalAmount__c = 10;
            creditLineItem.VATNationalTaxAmount__c = 10;
            creditLineItem.Unit_Price__c = 10;
            insert creditLineItem;
            
            update updateCredit;
			CreditRequestTriggerHelper helper;
            helper = CreditRequestTriggerHelper.NewTriggerHelper();
            system.debug('creditRequestUpdateList'+creditRequestUpdateList );
            system.debug('creditRequestMapList'+creditRequestMapList );
            //system.assert(False,creditRequestUpdateList);
			helper.afterUpdate(creditRequestUpdateList,creditRequestMapList);
            Integer countCase = 0;
            countCase = [SELECT count() FROM CASE WHERE Status = : 'new'];
            system.assertEquals(countCase, 2);
        Test.stoptest();
    }

    @isTest
    static void creditRequestUpdate1(){
        Credit_Request__c cr;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User testUser = TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);
        insert testUser;

        system.runAs(testUser) {
            Account acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
            insert acc;   
            
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp ', acc.Id);
            insert opp; 
            
            Apttus_Proposal__Proposal__c quote = TestDataSetupUtility.createApttusProposal(opp);
            quote.Apttus_Proposal__Account__c = acc.Id;
            insert quote;
            Contact con = TestDataSetupUtility.createTestContact(acc.Id, 'confirst1', 'conlast1', 'con1@email.com');
            insert con;
            Order__c ord = TestDataSetupUtility.createOrder(acc.Id, con.Id);
            ord.Opportunity__c = opp.Id;
            ord.QuoteProposal__c = quote.Id;
            ord.AccountOrganization__c = 'North America';
            insert ord;

            List<Credit_Request__c> lstCR = new List<Credit_Request__c>();
            cr = TestDataSetupUtility.createCreditRequest(ord.Id);
            cr.ManagersManager__c  = testUser.Id;
            cr.ApprovalStatus__c = 'Not Submitted';
            cr.CreditReason__c = 'Tax Error';
            cr.CreditScenario__c = 'Credit';
            lstCR.add(cr);

            cr = TestDataSetupUtility.createCreditRequest(ord.Id);
            cr.ManagersManager__c  = testUser.Id;
            cr.ApprovalStatus__c = 'Not Submitted';
            cr.CreditReason__c = 'Tax Error';
            cr.CreditScenario__c = 'Credit';
            lstCR.add(cr);

            insert lstCR;
            
            
            
            

            system.debug('[RB] - Approval Status(Insert) : ' + lstCR[0].ApprovalStatus__c + '; Credit Reason(Insert) : ' + lstCR[0].CreditReason__c + '; Credit Scenario(Insert) : ' + lstCR[0].CreditScenario__c);

            String old_Reson = lstCR[0].CreditReason__c;
            Test.startTest();
                lstCR[0].ApprovalStatus__c = 'Approved';
                lstCR[0].CreditReason__c = 'Incorrect tax';

                lstCR[1].ApprovalStatus__c = 'Approved';
                lstCR[1].CreditScenario__c = 'Credit and Rebill';
                lstCR[1].CreditReason__c = 'Change in Non-Standard Payment Terms';
                try{
                    Database.SaveResult[] sr = Database.update(lstCR);
                } catch(Exception e){}
                
             	
                
            Test.stopTest();
            system.assertNotEquals(old_Reson, lstCR[0].CreditReason__c);

            system.debug('[RB] - Approval Status(2ndUpdate) : ' + lstCR[0].ApprovalStatus__c + '; Credit Reason(2ndUpdate) : ' + lstCR[0].CreditReason__c + '; Credit Scenario(2ndUpdate) : ' + lstCR[0].CreditScenario__c);
        }
    }
}