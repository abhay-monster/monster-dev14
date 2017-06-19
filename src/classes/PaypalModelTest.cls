@isTest
private class PaypalModelTest {
    static Order__c  order1 ,order2;
    static Order_Line_Item__c orderLineItem,orderLineItem1;
    static LicenseID__c licenseId1,licenseId2,licenseId3,licenseId4;
    static Account acc;
    static Contact con;
    static Opportunity opp;
    static XcodeAccount__c xAcc;
    static Xcode__c xcode ;
    static List<Credit_Request__c> crList;
    static Invoices__c inv1;
    static case case1, case2;
    static List<Apttus_Proposal__Proposal__c> proList;
    public enum State {INIT,PROCESS,ERROR}

    @isTest
    static void createTestData2(){
        acc = TestDataSetupUtility.createTestAccountWithShipping('Test Account');
        insert acc;
        con = TestDataSetupUtility.createTestContact(acc.Id, 'PrimaryBillingTestLastnameOne', 'PrimaryBillingTestFirstnameOne', 'email1@testContact.com');
        con.PrimaryBillingContact__c = true;
        insert con;
        Id oppRT =  Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'Lead');
        opp = TestDataSetupUtility.createTestOpportunity('test',acc.Id);
        opp.InternationalDeal__c = true;
        opp.recordTypeId = oppRT;
        insert opp;
        
        case1 = new Case();
        case1.AccountId = acc.Id;
        case1.Language__c = 'English';
        case1.ContactId = con.Id;
        case1.ContactSource__c = 'Employer';
        case1.Group__c = 'ADOPS';
        case1.SubStatus__c = 'Unresolved';
        case1.Status = 'Open';
        case1.Issue__c = 'Account Request';
        case1.Priority = '3-Medium';
        case1.Origin = 'Email Inbound';
        case1.Subject = 'Test subject';
        case1.Description = 'test description';
        case1.Category__c = 'Support';
        insert case1;
        
        case2 = new Case();
        case2.AccountId = acc.Id;
        case2.Language__c = 'English';
        case2.ContactId = con.Id;
        case2.ContactSource__c = 'Employer';
        case2.Group__c = 'ADOPS';
        case2.SubStatus__c = 'Unresolved';
        case2.Status = 'Closed';
        case2.Issue__c = 'Account Request';
        case2.Priority = '3-Medium';
        case2.Origin = 'Email Inbound';
        case2.Subject = 'Test subject';
        case2.Description = 'test description';
        case2.Category__c = 'Support';
        case2.ParentId = case1.Id;
        insert case2;
        
        //Prashant Gupta, Appirio
        insert(TestDataSetupUtility.salesChannelCrossReference());
        //End
        
        proList = new List<Apttus_Proposal__Proposal__c>();
        Apttus_Proposal__Proposal__c pro = TestDataSetupUtility.createProposal('Test Proposal1', acc.Id, opp.Id, 'Accepted Online', false);
        pro.PaypalReferenceNumber__c = 'B10P9D9E98C8';
        //pro.PaypalTransactionTime__c = 7/8/2016 3:39 AM;
        //pro.PaypalTransactionTime__c = Today();
        pro.PaypalResultMessage__c = 'Approved';
        pro.PaypalResultCode__c = '0';
        pro.PaypalSecureTokenID__c = '9813545161049301102';
        pro.PaypalCardType__c = 'Visa';
        pro.PaypalBillToName__c = 'JH Freese';
        pro.Selling_Country__c = 'United States';
        pro.SalesChannel__c = 'ECOMM';
        proList.add(pro);
        insert proList;
        String quoteid;
        String PaypalReferenceNumber;
        String PaypalResultMessage;
        String PaypalResultCode;
        String PaypalSecureTokenID;
        String PaypalCardType;
        String PaypalBillToName;
        for(Apttus_Proposal__Proposal__c proquote : proList)
        {
            quoteid = proquote.id;
            PaypalReferenceNumber = proquote.PaypalReferenceNumber__c;
            PaypalResultMessage = proquote.PaypalResultMessage__c;
            PaypalResultCode = proquote.PaypalResultCode__c;
            PaypalSecureTokenID = proquote.PaypalSecureTokenID__c;
            PaypalCardType = proquote.PaypalCardType__c;
        }
        List<Apttus_Proposal__Proposal_Line_Item__c> proLineItemList = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        Apttus_Proposal__Proposal_Line_Item__c proLineItem = TestDataSetupUtility.createProposalLineItem(proList[0].Id);
        proLineItemList.add(proLineItem);
        insert proLineItemList;
               
        Id StandardOrderRecordType = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Standard');
        order1 = TestDataSetupUtility.createOrder(acc.Id);
        order1.OrderStatus__c = 'Sent To Verification';
        order1.RecordTypeId = StandardOrderRecordType;
        order1.Opportunity__c = opp.Id;
        order1.BillingAccount__c = acc.id;
        order1.ShippingAccount__c = acc.id;
        order1.BillingContact__c = con.id;
        order1.Posting_Contact__c = con.id;
        order1.QuoteProposal__c = quoteid;
       // order1.Owner.FirstName = 'Adarsh';
        //order1.Owner.LastName = 'Parthasarathy';
        order1.PaypalCaptureResultCode__c = '0';
        order1.PaypalCaptureResultMessage__c = 'Approved';
        //order1.PaypalCaptureReferenceNumber__c
        order1.PaypalRefundResultMessage__c = 'Not Approved';
        order1.PaypalRefundResultCode__c = '0';
        //order1.PaypalRefundReferenceNumber__c
        order1.SalesChannel__c = 'ECOMM';
        //order1.CreditScenario__c = 'Credit and Rebill';
        //order1.is_credit__c= true ;
        insert order1;
        inv1 = TestDataSetupUtility.createInvoice(order1.id,con.id);       
        insert inv1;
        order2 = TestDataSetupUtility.createOrder(acc.Id);
        order2.OrderStatus__c = 'Sent To Verification';
        order2.RecordTypeId = StandardOrderRecordType;
        order2.Opportunity__c = opp.Id;
        order2.BillingAccount__c = acc.id;
        order2.ShippingAccount__c = acc.id;
        order2.BillingContact__c = con.id;
        order2.Posting_Contact__c = con.id;
        order2.SalesChannel__c = 'ECOMM';
        //order1.CreditScenario__c = 'Credit and Rebill';
        //order1.is_credit__c= true ;
        insert order2;

        xcode = new Xcode__c();
        xcode.name = 'test1';
        insert xcode ;

        xAcc = new XcodeAccount__c ();
        xAcc.Xcode__c = xcode.Id;
        xAcc.Account__c = acc .Id;
        insert xAcc;
       
        //Create product2
        Product2 product = TestDataSetupUtility.createProduct('Test product', false);
        product.Convert_From__c = true;
        product.Service_Type__c = 'Usage';
        product.Messaging__c = true;
        insert product;

        orderLineItem = TestDataSetupUtility.createOrderLineItem(order1.Id);
        //orderLineItem.CreditRequestLineItem__c = lineItem1.Id;
        orderLineItem.Xcode_lkp__c = xAcc.Id;
        orderLineItem.Product__c = product.Id;
        orderLineItem.Result__c = '11';
        orderLineItem1 = TestDataSetupUtility.createOrderLineItem(order1.Id);
        //orderLineItem1.CreditRequestLineItem__c = lineItem2.Id;
        orderLineItem1.Xcode_lkp__c = xAcc.Id;
        orderLineItem1.Product__c = product.Id;
        insert (new List<Order_Line_Item__c>{orderLineItem,orderLineItem1});

    }

    
   @isTest (SeeAllData=false)
    static  void testReturnPayPalTransaction(){
        createTestData2();
        IntegrationConfig__c  intSetting =  TestDataSetupUtility.buildIntegrationConfigSetting();
        intSetting.name = 'Paypal US';
        insert(intSetting);
        intSetting =  TestDataSetupUtility.buildIntegrationConfigSetting();
        intSetting.name = 'Invoice - Paypal US - USD';
        insert(intSetting);
        WebServiceEndpoint__c  webIntSetting =  TestDataSetupUtility.buildWebServiceEndpointSetting();
        insert(webIntSetting);
        test.startTest();
        if(order1.PaypalRefundResultMessage__c == 'Approved' && order1.PaypalRefundResultCode__c == '0'){
                //return 'Transaction can not be completed:\n A succesful refund transaction has already been made.';
                //System.assertEquals('A successful refund transaction has already been made',A successful refund transaction has already been made);
            }

            if(order1 != null && order1.QuoteProposal__c != null && order1.PaypalCaptureResultCode__c == '0' && order1.PaypalCaptureResultMessage__c == 'Approved'){
                //PaypalModel.getRequiredParamMap();
                    PageReference landingPage = Page.PaypalLanding;
                //landingPage.getParameters().put('recordID', usedProp.PaypalHashedId__c);
                landingPage.getParameters().put('status', 'success');
                landingPage.getHeaders().put('Origin', webIntSetting.Endpoint__c);
                //landingPage.getParameters().put('SECURETOKENID', usedProp.PaypalSecureTokenID__c);
                landingPage.getParameters().put('TRANSTIME', String.valueOf(system.now()));
                landingPage.getParameters().put('BILLTOFIRSTNAME', 'first');
                landingPage.getParameters().put('BILLTOLASTNAME', 'last');
                landingPage.getParameters().put('CARDTYPE', '0');
                landingPage.getParameters().put('RESPMSG', 'Approved');
                landingPage.getParameters().put('RESULT', '0');
            
                Test.setCurrentPage(landingPage);
                PaypalModel Connection = new PaypalModel();
                PaypalModel.refundPaypalTransaction(order1.id);
               	Connection.ObjectId = inv1.id;
                Connection.getRequiredParamMap();
                Connection.init(order1, PaypalModel.State.INIT);
                Connection.sendToPaypal();
                Connection.processRefundReturnedData();
                Connection.processAuthReturnedData();
                
                Case orderCase = new Case();
                orderCase.Order__c = order1.Id;
                orderCase.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Case', 'Product Implementation');
                insert orderCase;
                
                map<Id, Case> mapParam = new map<Id, Case>();
                mapParam.put(orderCase.Id, orderCase);
                
                
                Apttus_Proposal__Proposal__c prop = TestDataSetupUtility.createApttusProposal(opp);
                prop.PaypalReferenceNumber__c = 'A11C7C9A8FDE';
                prop.PaypalResultCode__c = '0';
                prop.PaypalResultMessage__c = 'Approved';
                prop.PaypalSecureTokenID__c = '176266609134031722';
                prop.PaypalTransactionTime__c = system.now();
                insert prop;
                PaypalModel.PaypalCaptureTransaction(new Case[]{new Case(Id = orderCase.Id, Order__c = order1.Id, Status = 'Closed', RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Case', 'Product Implementation'))}, mapParam);
        		PaypalModel.OrderCreator paypalorder = new PaypalModel.OrderCreator(proList[0]);
        		paypalorder.getOrderByQuote();
            	paypalorder.SendOrderToSite();
            	paypalorder.updateOrderFromAuthTransaction();
        		paypalorder.triggerOpportunityOrderCreation(prop.Apttus_Proposal__Opportunity__c);
        	    
            }
            Invoices__c newinv = [SELECT id, Order__r.QuoteProposal__c FROM Invoices__c WHERe id = :inv1.id ];
            if(order1 != null && order1.QuoteProposal__c != null && order1.PaypalCaptureResultCode__c == '0' && order1.PaypalCaptureResultMessage__c == 'Approved'){
                //PaypalModel.getRequiredParamMap();
                //system.assert(False,'<<>>' + inv1.id);
                PaypalModel Connection = new PaypalModel(newinv.id);
                Connection.getRequiredParamMap();
                Connection.init(newinv, PaypalModel.State.INIT);
                Connection.sendToPaypal();
                Connection.processAuthReturnedData();
            }
            
            system.debug([SELECT id, Name from Invoices__c]);
        test.stopTest();

    }
}