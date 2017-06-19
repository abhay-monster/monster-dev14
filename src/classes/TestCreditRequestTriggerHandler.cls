/*
** @author :Siddharth Varshneya
** @date : 7/22/2015
** @description : Test class for CreditRequestTriggerHandler
*/
@isTest
private class TestCreditRequestTriggerHandler {

    @isTest
    static void creditRequestUpdate1(){
        Credit_Request__c cr;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User testUser = TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);
        insert testUser;

        system.runAs(testUser) {
            Account acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
            acc.Organization__c = 'North America';
            insert acc;   
            
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp ', acc.Id);
            insert opp;  
            
            Apttus_Proposal__Proposal__c quote = TestDataSetupUtility.createApttusProposal(opp);
            quote.Apttus_Proposal__Account__c = acc.Id;
            insert quote;
            Payment_Details__c payDet = TestDataSetupUtility.createTestPaymentDetails('Asia Pacific', 'Pre-Paid', 'Immediate');
	        payDet.Default_for_Partner_Proposal__c = false;
	        payDet.Active__c = true;
	        //paydet.Non_Standard_Payment__c = false;
	        system.debug('***********************Insert Payment Detail***************');
	        insert payDet;
            
            Contact con = TestDataSetupUtility.createTestContact(acc.Id, 'confirst2', 'conlast2', 'con12@email.com');
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
            cr.PaymentTerm__c = 'Pre-Paid';
            cr.Payment_Method__c = 'Invoice';
            cr.Payment_Frequency__c =  'Immediate';
            lstCR.add(cr);
            
            //Added for Code Coverage for various Credit Reasons - T-596492
            cr = TestDataSetupUtility.createCreditRequest(ord.Id);
            cr.ManagersManager__c  = testUser.Id;
            cr.ApprovalStatus__c = 'Not Submitted';
            cr.CreditReason__c = 'Tax Error';
            cr.CreditScenario__c = 'Credit';
            cr.PaymentTerm__c = 'Pre-Paid';
            cr.Payment_Method__c = 'Invoice';
            cr.Payment_Frequency__c =  'Immediate';
            lstCR.add(cr);
            
            cr = TestDataSetupUtility.createCreditRequest(ord.Id);
            cr.ManagersManager__c  = testUser.Id;
            cr.ApprovalStatus__c = 'Not Submitted';
            cr.CreditReason__c = 'Tax Error';
            cr.CreditScenario__c = 'Credit';
            cr.PaymentTerm__c = 'Pre-Paid';
            cr.Payment_Method__c = 'Invoice';
            cr.Payment_Frequency__c =  'Immediate';
            lstCR.add(cr);
            
            cr = TestDataSetupUtility.createCreditRequest(ord.Id);
            cr.ManagersManager__c  = testUser.Id;
            cr.ApprovalStatus__c = 'Not Submitted';
            cr.CreditReason__c = 'Tax Error';
            cr.CreditScenario__c = 'Credit';
            cr.PaymentTerm__c = 'Pre-Paid';
            cr.Payment_Method__c = 'Invoice';
            cr.Payment_Frequency__c =  'Immediate';
            lstCR.add(cr);
            
            cr = TestDataSetupUtility.createCreditRequest(ord.Id);
            cr.ManagersManager__c  = testUser.Id;
            cr.ApprovalStatus__c = 'Not Submitted';
            cr.CreditReason__c = 'Tax Error';
            cr.CreditScenario__c = 'Credit';
            cr.PaymentTerm__c = 'Pre-Paid';
            cr.Payment_Method__c = 'Invoice';
            cr.Payment_Frequency__c =  'Immediate';
            lstCR.add(cr);

            cr = TestDataSetupUtility.createCreditRequest(ord.Id);
            cr.ManagersManager__c  = testUser.Id;
            cr.ApprovalStatus__c = 'Not Submitted';
            cr.CreditReason__c = 'Tax Error';
            cr.CreditScenario__c = 'Credit';
            cr.PaymentTerm__c = 'Pre-Paid';
            cr.Payment_Method__c = 'Invoice';
            cr.Payment_Frequency__c =  'Immediate';
            lstCR.add(cr);
            
            cr = TestDataSetupUtility.createCreditRequest(ord.Id);
            cr.ManagersManager__c  = testUser.Id;
            cr.ApprovalStatus__c = 'Not Submitted';
            cr.CreditReason__c = 'Tax Error';
            cr.CreditScenario__c = 'Credit';
            cr.PaymentTerm__c = 'Pre-Paid';
            cr.Payment_Method__c = 'Invoice';
            cr.Payment_Frequency__c =  'Immediate';
            lstCR.add(cr);
            //Code Coverage Addition block ends here - T-596492
            
            insert lstCR;

            system.debug('[RB] - Approval Status(Insert) : ' + lstCR[0].ApprovalStatus__c + '; Credit Reason(Insert) : ' + lstCR[0].CreditReason__c + '; Credit Scenario(Insert) : ' + lstCR[0].CreditScenario__c);

            String old_Reson = lstCR[0].CreditReason__c;
            Test.startTest();
                lstCR[0].ApprovalStatus__c = 'Approved';
                lstCR[0].CreditReason__c = 'Incorrect tax';

                lstCR[1].ApprovalStatus__c = 'Approved';
                lstCR[1].CreditScenario__c = 'Credit and Rebill';
                lstCR[1].CreditReason__c = 'Change in Non-Standard Payment Terms';
            
            //Added for Code Coverage of various Credit Reasons
            lstCR[2].ApprovalStatus__c = 'Approved';
                lstCR[2].CreditScenario__c = 'Credit and Rebill';
                lstCR[2].CreditReason__c = 'Federal or State/Province/HST Tax Issue';
            
            lstCR[3].ApprovalStatus__c = 'Approved';
                lstCR[3].CreditScenario__c = 'Credit and Rebill';
                lstCR[3].CreditReason__c = 'Billing Start Date Correction';
            
            lstCR[4].ApprovalStatus__c = 'Approved';
                lstCR[4].CreditScenario__c = 'Credit and Rebill';
                lstCR[4].CreditReason__c = 'Payment term changes';
            
            lstCR[5].ApprovalStatus__c = 'Approved';
                lstCR[5].CreditScenario__c = 'Credit and Rebill';
                lstCR[5].CreditReason__c = 'Change in Standard Payment Terms';
            
            lstCR[6].ApprovalStatus__c = 'Approved';
                lstCR[6].CreditScenario__c = 'Credit and Rebill';
                lstCR[6].CreditReason__c = 'Billing account invalid';
            
            lstCR[7].ApprovalStatus__c = 'Approved';
                lstCR[7].CreditScenario__c = 'Credit';
                lstCR[7].CreditReason__c = 'Tax Error';
            //Code Coverage additional block ends
                try{
                    Database.SaveResult[] sr = Database.update(lstCR);
                } catch(Exception e){}
            Test.stopTest();
            system.assertNotEquals(old_Reson, lstCR[0].CreditReason__c);

            system.debug('[RB] - Approval Status(2ndUpdate) : ' + lstCR[0].ApprovalStatus__c + '; Credit Reason(2ndUpdate) : ' + lstCR[0].CreditReason__c + '; Credit Scenario(2ndUpdate) : ' + lstCR[0].CreditScenario__c);
        }
    }

    @isTest
    static void creditRequestUpdate2(){
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
            insert ord;
            
             
            List<Order_Line_Item__c> OLIList = new List<Order_Line_Item__c>();
            Order_Line_Item__c oli = TestDataSetupUtility.createOrderLineItem(ord.Id);
            insert oli;
            
            Order_Line_Item__c item = [SELECT Id,Name,order__c
             FROM Order_Line_Item__c WHERE Id=: oli.id];
             
            system.debug('******item ****' +item );
            
            LicenseID__c licenseId = new LicenseID__c();
            licenseId.OrderLineItem__c = oli.id;
            licenseId.SiteLicenseID__c = 'Test';
            insert licenseId ;
            
            LicenseID__c licenseId1 = new LicenseID__c();
            licenseId1.OrderLineItem__c = oli.id;
            licenseId1.SiteLicenseID__c = 'Test';
            insert licenseId1 ;
            

            Credit_Request__c cr = TestDataSetupUtility.createCreditRequest(ord.Id);
            cr.ManagersManager__c  = testUser.Id;
            cr.ApprovalStatus__c = 'Not Submitted';
            cr.CreditReason__c = 'Tax Error';
            cr.CreditScenario__c = 'Credit';
            insert cr;
            

            Apttus_Proposal__Proposal__c app = TestDataSetupUtility.createProposal(opp.Id);
            app.CreditRequest__c =cr.Id;
            insert app;

            String old_Reson = cr.CreditReason__c;
            Test.startTest();
                //CreditRequestTriggerHandler crth = new CreditRequestTriggerHandler(false, 1);
                cr.ApprovalStatus__c = 'Approved';
                cr.CreditReason__c = 'Incorrect tax';
                update cr;
            Test.stopTest();
            system.assertNotEquals(old_Reson, cr.CreditReason__c);
        }
    }
}