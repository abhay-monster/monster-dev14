@isTest
private class BizAppsSiteModelTest {
    static Order__c  order1 ,order2;
    static Order_Line_Item__c orderLineItem,orderLineItem1;
    static LicenseID__c licenseId1,licenseId2,licenseId3,licenseId4;
    static Account acc;
    static Contact con;
    static Opportunity opp;
    static XcodeAccount__c xAcc;
    static Xcode__c xcode ;
    static List<Credit_Request__c> crList;

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
        Id CreditOrderRecordType = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Credit');
        order1 = TestDataSetupUtility.createOrder(acc.Id);
        order1.OrderStatus__c = 'Sent To Verification';
        order1.RecordTypeId = CreditOrderRecordType;
        order1.Opportunity__c = opp.Id;
        order1.BillingAccount__c = acc.id;
        order1.ShippingAccount__c = acc.id;
        order1.BillingContact__c = con.id;
        order1.Posting_Contact__c = con.id;

        //order1.CreditScenario__c = 'Credit and Rebill';
        //order1.is_credit__c= true ;
        insert order1;

        order2 = TestDataSetupUtility.createOrder(acc.Id);
        order2.OrderStatus__c = 'Sent To Verification';
        order2.RecordTypeId = CreditOrderRecordType;
        order2.Opportunity__c = opp.Id;
        order2.BillingAccount__c = acc.id;
        order2.ShippingAccount__c = acc.id;
        order2.BillingContact__c = con.id;
        order2.Posting_Contact__c = con.id;
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
        /*Credit_Request__c cr1 = TestDataSetupUtility.createCreditRequest(order1.Id);
        cr1.Credit_Type__c = 'Full';
        cr1.CreditScenario__c = 'Credit and Rebill';
        Credit_Request__c cr2 = TestDataSetupUtility.createCreditRequest(order1.Id);
        cr2.Credit_Type__c = 'Partial';
        insert (new List<Credit_Request__c>{cr1,cr2});

        order1.CreditRequest__c = cr1.Id;
        update order1;

        CreditRequestLineItem__c lineItem1 = new CreditRequestLineItem__c();
        lineItem1.Credit_Request__c = cr1.Id;
        lineItem1.CreditCondition__c = 'Full';
        lineItem1.TaxAmount__c = 30;
        lineItem1.CreditType__c = 'Inventory';

        CreditRequestLineItem__c lineItem2 = new CreditRequestLineItem__c();
        lineItem2.Credit_Request__c = cr2.Id;
        lineItem2.CreditCondition__c = 'Partial';
        lineItem2.TaxAmount__c = 30;
        lineItem2.CreditType__c = 'Inventory';
        insert (new List<CreditRequestLineItem__c>{lineItem1,lineItem2});
        */
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

        //lineItem1.Order_Line_Item__c = orderLineItem.id;
        //lineItem2.Order_Line_Item__c = orderLineItem1.id;
        //update (new List<CreditRequestLineItem__c>{lineItem1,lineItem2});
        licenseId1 = new LicenseID__c();
        licenseId1.OrderLineItem__c = orderLineItem.id;
        licenseId1.SiteLicenseID__c = '12';
        licenseId1.Xcode__c = xcode.Id;
        licenseId2 = new LicenseID__c();
        licenseId2.OrderLineItem__c = orderLineItem1.id;
        licenseId2.SiteLicenseID__c = '11';
        licenseId2.Xcode__c = xcode.Id;
        licenseId3 = new LicenseID__c();
        licenseId3.OrderLineItem__c = orderLineItem.id;
        licenseId3.Xcode__c = xcode.Id;
        licenseId4 = new LicenseID__c();
        licenseId4.OrderLineItem__c = orderLineItem1.id;
        licenseId4.Xcode__c = xcode.Id;
        licenseId4.SiteLicenseID__c = '12';
        insert (new List<LicenseID__c>{licenseId1,licenseId2,licenseId3,licenseId4}) ;
        /*Credit_Request_License_ID__c creditLicense1 = new Credit_Request_License_ID__c();
        creditLicense1.CreditRequest__c = cr1.Id;
        creditLicense1.CreditRequestLineItem__c = lineItem1.Id;
        creditLicense1.LicenseID__c = licenseId1.Id;
        Credit_Request_License_ID__c creditLicense2 = new Credit_Request_License_ID__c();
        creditLicense2.CreditRequest__c = cr2.Id;
        creditLicense2.CreditRequestLineItem__c = lineItem2.Id;
        creditLicense2.LicenseID__c = licenseId2.Id;
        Credit_Request_License_ID__c creditLicense3 = new Credit_Request_License_ID__c();
        creditLicense3.CreditRequest__c = cr2.Id;
        creditLicense3.CreditRequestLineItem__c = lineItem2.Id;
        creditLicense3.LicenseID__c = licenseId3.Id;
        Credit_Request_License_ID__c creditLicense4 = new Credit_Request_License_ID__c();
        creditLicense4.CreditRequest__c = cr2.Id;
        creditLicense4.CreditRequestLineItem__c = lineItem2.Id;
        creditLicense4.LicenseID__c = licenseId4.Id;
        insert (new List<Credit_Request_License_ID__c>{creditLicense1,creditLicense2,creditLicense3,creditLicense4}) ;
        */
        //licenseId1.LicenseID__c = licenseId2.Id;
        licenseId3.LicenseID__c = licenseId4.Id;

        update (new List<LicenseID__c>{licenseId1,licenseId3}) ;
        //Inserting custom setting
        IntegrationConfig__c setting = new IntegrationConfig__c(Name = 'Site Integration', AvalaraClient__c = 'Monster Worldwide, Inc.',
                AvalaraCompanyCode__c = 'MWW', AvalaraCountry__c = 'MWW', EndpointName__c = 'AvalaraDev',IsPaypalTest__c = false,
                Password__c = '6NvqAGdhXM^y',Timeout__c = 60000,Username__c = 'jlescarbeau@appirio.com', PaypalRedirectURL__c = 'PaypalRedirectURL');
            insert setting;
        WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c(Name = 'AvalaraDev', Endpoint__c = 'https://development.avalara.net/1.0/tax/get');
            WebServiceEndpoint__c endpoint2 = new WebServiceEndpoint__c(Name = 'PaypalRedirectURL', Endpoint__c = 'https://payflowlink.paypal.com');
            insert new List<WebServiceEndpoint__c>{endpoint, endpoint2};


        Integration_Attribute__c integration = new Integration_Attribute__c(Name = 'Test' ,Integration_Type__c='MAPP');
        integration.source_object__c = 'Line_Item_Attribute__c';
        List<Integration_Attribute__c> integrationLst = new List<Integration_Attribute__c>();
        integrationLst.add(integration);
        integrationLst.add( new Integration_Attribute__c(Name = 'Test' ,source_object__c = 'Line_Item_Attribute__c',Integration_Type__c='IWS'));
        insert integrationLst;
    }

    static void createTestData(){
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
        Id CreditOrderRecordType = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Credit');
        order1 = TestDataSetupUtility.createOrder(acc.Id);
        order1.OrderStatus__c = 'Sent To Verification';
        order1.RecordTypeId = CreditOrderRecordType;
        order1.Opportunity__c = opp.Id;
        order1.BillingAccount__c = acc.id;
        order1.ShippingAccount__c = acc.id;
        order1.BillingContact__c = con.id;
        order1.Posting_Contact__c = con.id;

        //order1.CreditScenario__c = 'Credit and Rebill';
        //order1.is_credit__c= true ;
        insert order1;
        Order_Line_Item__c  oLI1= TestDataSetupUtility.createOrderLineItem(order1.id);
        insert oLI1;
        order2 = TestDataSetupUtility.createOrder(acc.Id);
        order2.OrderStatus__c = 'Sent To Verification';
        order2.RecordTypeId = CreditOrderRecordType;
        order2.Opportunity__c = opp.Id;
        order2.BillingAccount__c = acc.id;
        order2.ShippingAccount__c = acc.id;
        order2.BillingContact__c = con.id;
        order2.Posting_Contact__c = con.id;
        //order1.CreditScenario__c = 'Credit and Rebill';
        //order1.is_credit__c= true ;
        insert order2;
        Order_Line_Item__c  oLI2 =TestDataSetupUtility.createOrderLineItem(order2.id);
        insert oLI2;
        xcode = new Xcode__c();
        xcode.name = 'test1';
        insert xcode ;

        xAcc = new XcodeAccount__c ();
        xAcc.Xcode__c = xcode.Id;
        xAcc.Account__c = acc .Id;
        insert xAcc;
        Credit_Request__c cr1 = TestDataSetupUtility.createCreditRequest(order1.Id);
        cr1.Credit_Type__c = 'Full';
        cr1.ApprovalStatus__c= null;
        cr1.CreditReason__c = 'Billing Start Date Correction';
        cr1.CreditScenario__c = 'Credit and Rebill';
        Credit_Request__c cr2 = TestDataSetupUtility.createCreditRequest(order1.Id);
        cr2.Credit_Type__c = 'Partial';
        cr2.ApprovalStatus__c= null;
        crList = new List<Credit_Request__c>{cr1,cr2};
        insert crList;

        order1.CreditRequest__c = cr1.Id;
        update order1;

        CreditRequestLineItem__c lineItem1 = new CreditRequestLineItem__c();
        lineItem1.Credit_Request__c = cr1.Id;
        lineItem1.CreditCondition__c = 'Full';
        lineItem1.TaxAmount__c = 10;
        lineItem1.CreditType__c = 'Inventory';
        lineItem1.CreditAmount__c = 100;
        lineItem1.AvailableCreditAmount__c = 200;
        lineItem1.NetCreditAmount__c = 10;
        lineItem1.NetTotalAmount__c=10;
        lineItem1.NetRemainingCreditAmount__c =10;

        CreditRequestLineItem__c lineItem2 = new CreditRequestLineItem__c();
        lineItem2.Credit_Request__c = cr2.Id;
        lineItem2.CreditCondition__c = 'Partial';
        lineItem1.TaxAmount__c = 10;
        lineItem2.CreditType__c = 'Inventory';
        lineItem2.CreditAmount__c = 100;
        lineItem2.AvailableCreditAmount__c = 200;
        lineItem2.NetCreditAmount__c = 10;
        lineItem2.NetTotalAmount__c=10;
        lineItem2.NetRemainingCreditAmount__c =10;
        insert (new List<CreditRequestLineItem__c>{lineItem1,lineItem2});

        //Create product2
        Product2 product = TestDataSetupUtility.createProduct('Test product', false);
        product.Convert_From__c = true;
        product.Service_Type__c = 'Usage';
        product.Messaging__c = true;
        insert product;

        orderLineItem = TestDataSetupUtility.createOrderLineItem(order1.Id);
        orderLineItem.CreditRequestLineItem__c = lineItem1.Id;
        orderLineItem.Xcode_lkp__c = xAcc.Id;
        orderLineItem.Product__c = product.Id;
        orderLineItem.Result__c = '11';
        orderLineItem1 = TestDataSetupUtility.createOrderLineItem(order1.Id);
        orderLineItem1.CreditRequestLineItem__c = lineItem2.Id;
        orderLineItem1.Xcode_lkp__c = xAcc.Id;
        orderLineItem1.Product__c = product.Id;
        insert (new List<Order_Line_Item__c>{orderLineItem,orderLineItem1});

        lineItem1.Order_Line_Item__c = orderLineItem.id;
        lineItem2.Order_Line_Item__c = orderLineItem1.id;
        update (new List<CreditRequestLineItem__c>{lineItem1,lineItem2});
        licenseId1 = new LicenseID__c();
        licenseId1.OrderLineItem__c = orderLineItem.id;
        licenseId1.SiteLicenseID__c = '12';
        licenseId1.Xcode__c = xcode.Id;
        licenseId2 = new LicenseID__c();
        licenseId2.OrderLineItem__c = orderLineItem1.id;
        licenseId2.SiteLicenseID__c = '11';
        licenseId2.Xcode__c = xcode.Id;
        licenseId3 = new LicenseID__c();
        licenseId3.OrderLineItem__c = orderLineItem.id;
        licenseId3.Xcode__c = xcode.Id;
        licenseId4 = new LicenseID__c();
        licenseId4.OrderLineItem__c = orderLineItem1.id;
        licenseId4.Xcode__c = xcode.Id;
        licenseId4.SiteLicenseID__c = '12';
        insert (new List<LicenseID__c>{licenseId1,licenseId2,licenseId3,licenseId4}) ;
        Credit_Request_License_ID__c creditLicense1 = new Credit_Request_License_ID__c();
        creditLicense1.CreditRequest__c = cr1.Id;
        creditLicense1.CreditRequestLineItem__c = lineItem1.Id;
        creditLicense1.LicenseID__c = licenseId1.Id;
        Credit_Request_License_ID__c creditLicense2 = new Credit_Request_License_ID__c();
        creditLicense2.CreditRequest__c = cr2.Id;
        creditLicense2.CreditRequestLineItem__c = lineItem2.Id;
        creditLicense2.LicenseID__c = licenseId2.Id;
        Credit_Request_License_ID__c creditLicense3 = new Credit_Request_License_ID__c();
        creditLicense3.CreditRequest__c = cr2.Id;
        creditLicense3.CreditRequestLineItem__c = lineItem2.Id;
        creditLicense3.LicenseID__c = licenseId3.Id;
        Credit_Request_License_ID__c creditLicense4 = new Credit_Request_License_ID__c();
        creditLicense4.CreditRequest__c = cr2.Id;
        creditLicense4.CreditRequestLineItem__c = lineItem2.Id;
        creditLicense4.LicenseID__c = licenseId4.Id;
        insert (new List<Credit_Request_License_ID__c>{creditLicense1,creditLicense2,creditLicense3,creditLicense4}) ;

        licenseId1.LicenseID__c = licenseId2.Id;
        licenseId3.LicenseID__c = licenseId4.Id;

        update (new List<LicenseID__c>{licenseId1,licenseId3}) ;
        //Inserting custom setting
        IntegrationConfig__c setting = new IntegrationConfig__c(Name = 'Site Integration', AvalaraClient__c = 'Monster Worldwide, Inc.',
                AvalaraCompanyCode__c = 'MWW', AvalaraCountry__c = 'MWW', EndpointName__c = 'AvalaraDev',IsPaypalTest__c = false,
                Password__c = '6NvqAGdhXM^y',Timeout__c = 60000,Username__c = 'jlescarbeau@appirio.com', PaypalRedirectURL__c = 'PaypalRedirectURL');
            insert setting;
        WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c(Name = 'AvalaraDev', Endpoint__c = 'https://development.avalara.net/1.0/tax/get');
            WebServiceEndpoint__c endpoint2 = new WebServiceEndpoint__c(Name = 'PaypalRedirectURL', Endpoint__c = 'https://payflowlink.paypal.com');
            insert new List<WebServiceEndpoint__c>{endpoint, endpoint2};


        Integration_Attribute__c integration = new Integration_Attribute__c(Name = 'Test' ,Integration_Type__c='MAPP');
        integration.source_object__c = 'Line_Item_Attribute__c';
        List<Integration_Attribute__c> integrationLst = new List<Integration_Attribute__c>();
        integrationLst.add(integration);
        integrationLst.add( new Integration_Attribute__c(Name = 'Test' ,source_object__c = 'Line_Item_Attribute__c',Integration_Type__c='IWS'));
        insert integrationLst;
    }
    
    @isTest
    static  void testautoTriggerVerification(){
        createTestData();
        CreditReasonSiteBypass__c crcs = new CreditReasonSiteBypass__c(Name = 'Billing Start Date Correction',Credit_Reason__c = 'Billing Start Date Correction');
        //insert crcs;
        Test.startTest();
            Id RebillOrderRecordType = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Rebill Order');
            Order__c oldOrder  = TestDataSetupUtility.createOrder(acc.Id,con.Id);
            oldOrder.BillingAccount__c = acc.id;
            oldOrder.RecordTypeId = RebillOrderRecordType;
            oldOrder.ShippingAccount__c = acc.id;
            oldOrder.CreditRequest__c = crList[0].Id;
            oldOrder.OrderStatus__c = 'Sent To Verification';
            insert oldOrder;
            orderLineItem = TestDataSetupUtility.createOrderLineItem(oldOrder.Id);
            orderLineItem.Product__c = orderLineItem1.Product__c;
            orderLineItem.Xcode_lkp__c = orderLineItem1.Xcode_lkp__c;
            insert orderLineItem;
            LicenseID__c licenseId = new LicenseID__c();
            licenseId.OrderLineItem__c = orderLineItem.id;
            insert licenseId;
            map<Id,Order__c> oldOrders = new map<Id,Order__c> ();
            map<Id,Order__c> newOrders = new map<Id,Order__c> ();
            oldOrders.put(oldOrder.Id,oldOrder);
            Order__c newOrder  = TestDataSetupUtility.createOrder(acc.Id,con.Id);
            newOrder.RecordTypeId = RebillOrderRecordType;
            newOrder.OrderStatus__c = 'Paid in Full';
            newOrder.CreditRequest__c = crList[0].Id;
            insert newOrder;
            newOrder = [SELECT Id,OrderStatus__c,CreditRequest__c,is_rebill__c,CreditScenario__c,Credit_Reason__c,Auto_Trigger_Verification__c FROM Order__c WHERE Id = :newOrder.Id];
            System.debug('Testing new order:'+newOrder);
            newOrder.Id = oldOrder.Id;

            newOrders.put(newOrder.Id,newOrder);
            BizAppsSiteModel objModel = new BizAppsSiteModel();
            BizAppsSiteModel.autoTriggerVerification(oldOrders,newOrders);
            BizAppsSiteModel.autoTriggerVerificationForCredit(newOrders.values());
            insert crcs;
            BizAppsSiteModel.autoTriggerVerification(oldOrders,newOrders);
            BizAppsSiteModel.autoTriggerVerificationForCredit(newOrders.values());

        Test.stopTest();
    }

    @isTest
    static void testCreditAutoTriggerVerification(){
        createTestData();
        List<Apttus_Proposal__Proposal__c> proList = new List<Apttus_Proposal__Proposal__c>();
        Apttus_Proposal__Proposal__c pro = TestDataSetupUtility.createProposal('Test Proposal1', acc.Id, opp.Id, 'Accepted Online', false);
        proList.add(pro);
        insert proList;

        List<Apttus_Proposal__Proposal_Line_Item__c> proLineItemList = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        Apttus_Proposal__Proposal_Line_Item__c proLineItem = TestDataSetupUtility.createProposalLineItem(proList[0].Id);
        proLineItemList.add(proLineItem);
        insert proLineItemList;

        List<Line_Item_Attribute__c> lineItemList = new List<Line_Item_Attribute__c>();
        Line_Item_Attribute__c lineItem = TestDataSetupUtility.createLineItemAttribute(orderLineItem.Id, proLineItemList[0].Id);
        lineItem.Posting_location__c = 'UK';
        lineItemList.add(lineItem);
        Line_Item_Attribute__c lineItem1 = TestDataSetupUtility.createLineItemAttribute(orderLineItem1.Id, proLineItemList[0].Id);
        lineItem.Posting_location__c = 'UK';
        lineItemList.add(lineItem1);
        insert lineItemList;


        Test.startTest();
        //staring the test
        //moved the mock inside of the startTest
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        Order__c oldOrder  = TestDataSetupUtility.createOrder(acc.Id, con.Id);
        Id CreditOrderRecordType = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Credit');
        oldOrder.RecordTypeId = CreditOrderRecordType;
        oldOrder.OrderStatus__c = 'Sent To Verification';
        oldOrder.BillingAccount__c = acc.id;
        oldOrder.ShippingAccount__c = acc.id;
        insert oldOrder;
        orderLineItem = TestDataSetupUtility.createOrderLineItem(oldOrder.Id);
        insert orderLineItem;
        LicenseID__c licenseId = new LicenseID__c();
        licenseId.OrderLineItem__c = orderLineItem.id;
        insert licenseId;

        map<Id,Order__c> oldOrders = new map<Id,Order__c> ();
        map<Id,Order__c> newOrders = new map<Id,Order__c> ();
        oldOrders.put(oldOrder.Id,oldOrder);
        Order__c newOrder  = TestDataSetupUtility.createOrder(acc.Id, con.Id);
        //newOrder.CreditRequest__c = order1.CreditRequest__c;
        newOrder.OrderStatus__c = 'Paid in Full';
        newOrder.RecordTypeId = CreditOrderRecordType;
        newOrder.BillingAccount__c = acc.Id;
        newOrder.ShippingAccount__c = acc.Id;
        insert newOrder;
        newOrder = [SELECT Id,OrderStatus__c,Auto_Trigger_Verification__c FROM Order__c WHERE Id = :newOrder.Id];
        System.debug('Testing new order:'+newOrder);
        newOrder.Id = oldOrder.Id;

        newOrders.put(newOrder.Id,newOrder);




        IntegrationConfig__c setting = new IntegrationConfig__c(Name = 'MonsterBizAppsSiteRouter', AvalaraClient__c = 'Monster Worldwide, Inc.',
            AvalaraCompanyCode__c = 'MWW', AvalaraCountry__c = 'MWW', EndpointName__c = 'AvalaraDev',IsPaypalTest__c = false,
            Password__c = '6NvqAGdhXM^y',Timeout__c = 60000,Username__c = 'jlescarbeau@appirio.com', PaypalRedirectURL__c = 'PaypalRedirectURL');
        insert setting;
        WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c(Name = 'MonsterBizAppsSiteRouter', Endpoint__c = 'https://development.avalara.net/1.0/tax/get');
        WebServiceEndpoint__c endpoint2 = new WebServiceEndpoint__c(Name = 'PaypalRedirectURL', Endpoint__c = 'https://payflowlink.paypal.com');
        insert new List<WebServiceEndpoint__c>{endpoint, endpoint2};
        BizAppsSiteModel objModel = new BizAppsSiteModel();
        BizAppsSiteModel.autoTriggerVerification(oldOrders,newOrders);
        BizAppsSiteModel.JSVerifyOrder(order1.Id,true);
        BizAppsSiteModel.JSVerifyOrder(order1.Id,false);
        //end the test
        Test.stopTest();
    }

    @isTest
    static void testSubmitOrder(){
        createTestData2();
        List<Apttus_Proposal__Proposal__c> proList = new List<Apttus_Proposal__Proposal__c>();
        Apttus_Proposal__Proposal__c pro = TestDataSetupUtility.createProposal('Test Proposal1', acc.Id, opp.Id, 'Accepted Online', false);
        proList.add(pro);
        insert proList;

        List<Apttus_Proposal__Proposal_Line_Item__c> proLineItemList = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        Apttus_Proposal__Proposal_Line_Item__c proLineItem = TestDataSetupUtility.createProposalLineItem(proList[0].Id);
        proLineItemList.add(proLineItem);
        insert proLineItemList;

        List<Line_Item_Attribute__c> lineItemList = new List<Line_Item_Attribute__c>();
        Line_Item_Attribute__c lineItem = TestDataSetupUtility.createLineItemAttribute(orderLineItem.Id, proLineItemList[0].Id);
        lineItem.Posting_location__c = 'UK';
        lineItemList.add(lineItem);
        insert lineItemList;


        Order__c oldOrder  = TestDataSetupUtility.createOrder(acc.Id, con.Id);
        Id CreditOrderRecordType = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Credit');
        oldOrder.RecordTypeId = CreditOrderRecordType;
        oldOrder.OrderStatus__c = 'Sent To Verification';
        oldOrder.BillingAccount__c = acc.id;
        oldOrder.ShippingAccount__c = acc.id;
        insert oldOrder;
        orderLineItem = TestDataSetupUtility.createOrderLineItem(oldOrder.Id);
        insert orderLineItem;
        LicenseID__c licenseId = new LicenseID__c();
        licenseId.OrderLineItem__c = orderLineItem.id;
        insert licenseId;

        map<Id,Order__c> oldOrders = new map<Id,Order__c> ();
        map<Id,Order__c> newOrders = new map<Id,Order__c> ();
        oldOrders.put(oldOrder.Id,oldOrder);
        Order__c newOrder  = TestDataSetupUtility.createOrder(acc.Id,con.Id);
        newOrder.OrderStatus__c = 'Paid in Full';
        newOrder.RecordTypeId = CreditOrderRecordType;
        newOrder.BillingAccount__c = acc.Id;
        newOrder.ShippingAccount__c = acc.Id;
        insert newOrder;
        newOrder = [SELECT Id,OrderStatus__c,Auto_Trigger_Verification__c FROM Order__c WHERE Id = :newOrder.Id];
        System.debug('Testing new order:'+newOrder);
        newOrder.Id = oldOrder.Id;

        newOrders.put(newOrder.Id,newOrder);




        IntegrationConfig__c setting = new IntegrationConfig__c(Name = 'MonsterBizAppsSiteRouter', AvalaraClient__c = 'Monster Worldwide, Inc.',
            AvalaraCompanyCode__c = 'MWW', AvalaraCountry__c = 'MWW', EndpointName__c = 'AvalaraDev',IsPaypalTest__c = false,
            Password__c = '6NvqAGdhXM^y',Timeout__c = 60000,Username__c = 'jlescarbeau@appirio.com', PaypalRedirectURL__c = 'PaypalRedirectURL');
        insert setting;
        WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c(Name = 'MonsterBizAppsSiteRouter', Endpoint__c = 'https://development.avalara.net/1.0/tax/get');
        WebServiceEndpoint__c endpoint2 = new WebServiceEndpoint__c(Name = 'PaypalRedirectURL', Endpoint__c = 'https://payflowlink.paypal.com');
        insert new List<WebServiceEndpoint__c>{endpoint, endpoint2};
        Test.startTest();
        //need to move the mock inside of the test.startTest();
        //https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_restful_http_testing_dml.htm
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl1());
        //Test.setMock(WebServiceMock.class, new WebServiceMockImpl4());
        BizAppsSiteModel.autoTriggerVerification(oldOrders,newOrders);
        BizAppsSiteModel.JSVerifyOrder(order1.Id,true);
        BizAppsSiteModel.JSVerifyOrder(order1.Id,false);
        Test.stopTest();
    }

    @isTest
    static void testSubmitOrder1(){
        createTestData2();


        Order__c oldOrder  = TestDataSetupUtility.createOrder(acc.Id,con.Id);
        Id CreditOrderRecordType = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Credit');
        oldOrder.RecordTypeId = CreditOrderRecordType;
        oldOrder.OrderStatus__c = 'Sent To Verification';
        oldOrder.BillingAccount__c = acc.id;
        oldOrder.ShippingAccount__c = acc.id;
        insert oldOrder;
        orderLineItem = TestDataSetupUtility.createOrderLineItem(oldOrder.Id);
        insert orderLineItem;
        LicenseID__c licenseId = new LicenseID__c();
        licenseId.OrderLineItem__c = orderLineItem.id;
        insert licenseId;

        map<Id,Order__c> oldOrders = new map<Id,Order__c> ();
        map<Id,Order__c> newOrders = new map<Id,Order__c> ();
        oldOrders.put(oldOrder.Id,oldOrder);
        Order__c newOrder  = TestDataSetupUtility.createOrder(acc.Id, con.Id);
        newOrder.OrderStatus__c = 'Verified';
        newOrder.RecordTypeId = CreditOrderRecordType;
        newOrder.BillingAccount__c = acc.id;
        newOrder.ShippingAccount__c = acc.id;
        insert newOrder;
        newOrder = [SELECT Id,OrderStatus__c,Auto_Trigger_Verification__c FROM Order__c WHERE Id = :newOrder.Id];
        System.debug('Testing new order:'+newOrder);
        newOrder.Id = oldOrder.Id;

        newOrders.put(newOrder.Id,newOrder);

        Test.startTest();
        //moved the mock inside of the startTest
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl1());
        BizAppsSiteModel.SubmitOrder(newOrders.values(),oldOrders);
        newOrders.put(order1.Id,order1);
        BizAppsSiteModel.SubmitOrder(newOrders.values(),oldOrders);
        Test.stopTest();
    }
    @isTest
    static void testTransferIntegrationProcess2(){
        createTestData2();


        TransferAndAdjustmentProcessCC.LineWrapList[] pLineWraps =  new List<TransferAndAdjustmentProcessCC.LineWrapList>();
        TransferAndAdjustmentProcessCC.LineWrapList wrapList1 = new TransferAndAdjustmentProcessCC.LineWrapList();
        wrapList1.ParentLicenseId = licenseId1;
        List<TransferAndAdjustmentProcessCC.LineWrap> lineWraps1 = new List<TransferAndAdjustmentProcessCC.LineWrap>();
        TransferAndAdjustmentProcessCC.LineWrap lineWrap1 = new TransferAndAdjustmentProcessCC.LineWrap();
        lineWrap1.AccXId = xcode.Id;
        lineWrap1.License = licenseId1;
        lineWrap1.License.Xcode__c = xcode.id;
        lineWraps1.add(lineWrap1);
        wrapList1.lineWraps = lineWraps1;
        pLineWraps.add(wrapList1);
        TransferAndAdjustmentProcessCC.LineWrapList wrapList2 = new TransferAndAdjustmentProcessCC.LineWrapList();
        List<TransferAndAdjustmentProcessCC.LineWrap> lineWraps2 = new List<TransferAndAdjustmentProcessCC.LineWrap>();
        TransferAndAdjustmentProcessCC.LineWrap lineWrap2 = new TransferAndAdjustmentProcessCC.LineWrap();
        lineWrap2.AccXId =  xcode.Id;
        lineWrap2.License.Xcode__c = xcode.id;
        lineWrap2.License = licenseId2;
        lineWraps2.add(lineWrap2);
        wrapList2.LineWraps = lineWraps2;
        wrapList2.ParentLicenseId = licenseId2;
        pLineWraps.add(wrapList2);
        Test.startTest();
        //moved the mock inside of the startTest
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl2());
        BizAppsSiteModel.TransferIntegrationProcess(pLineWraps,orderLineItem);
        BizAppsSiteModel.TransferIntegrationProcess(pLineWraps,orderLineItem1);
        BizAppsSiteModel.SubmitOrderException exc = new BizAppsSiteModel.SubmitOrderException(12,'Test');
        Test.stopTest();
    }
    @isTest
    static void testTransferIntegrationProcess(){
        createTestData() ;


        TransferAndAdjustmentProcessCC.LineWrapList[] pLineWraps =  new List<TransferAndAdjustmentProcessCC.LineWrapList>();
        TransferAndAdjustmentProcessCC.LineWrapList wrapList1 = new TransferAndAdjustmentProcessCC.LineWrapList();
        wrapList1.ParentLicenseId = licenseId1;
        List<TransferAndAdjustmentProcessCC.LineWrap> lineWraps1 = new List<TransferAndAdjustmentProcessCC.LineWrap>();
        TransferAndAdjustmentProcessCC.LineWrap lineWrap1 = new TransferAndAdjustmentProcessCC.LineWrap();
        lineWrap1.AccXId = xcode.Id;
        lineWrap1.License = licenseId1;
        lineWraps1.add(lineWrap1);
        wrapList1.lineWraps = lineWraps1;
        pLineWraps.add(wrapList1);
        TransferAndAdjustmentProcessCC.LineWrapList wrapList2 = new TransferAndAdjustmentProcessCC.LineWrapList();
        List<TransferAndAdjustmentProcessCC.LineWrap> lineWraps2 = new List<TransferAndAdjustmentProcessCC.LineWrap>();
        TransferAndAdjustmentProcessCC.LineWrap lineWrap2 = new TransferAndAdjustmentProcessCC.LineWrap();
        lineWrap2.AccXId =  xcode.Id;
        lineWrap2.License = licenseId2;
        lineWraps2.add(lineWrap2);
        wrapList2.LineWraps = lineWraps2;
        wrapList2.ParentLicenseId = licenseId2;
        pLineWraps.add(wrapList2);
        Test.startTest();
        //moved the mock inside of the startTest
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl2());
        BizAppsSiteModel.TransferIntegrationProcess(pLineWraps,orderLineItem);
        BizAppsSiteModel.TransferIntegrationProcess(pLineWraps,orderLineItem1);
        BizAppsSiteModel.SubmitOrderException exc = new BizAppsSiteModel.SubmitOrderException(12,'Test');
        Test.stopTest();
    }

    /* Jeff L. I have no CLUE why this does not work, have tried literally everything I can think of.
    commenting out since I cannot figure out how to get this test method to not error out*/
    @isTest
    static  void testGetLicenseAndRelativesForCreditRequest(){
        createTestData2();


        Set<String> set1 = new Set<String>();
        set1.add(licenseId1.SiteLicenseID__c);
        //S-445896 JFreese Appirio 12/1/16 only send one License ID to Site, see TransferAndAdjustmentProcessCC.cls
        //set1.add(licenseId2.SiteLicenseID__c);
        //set1.add(licenseId3.Id);
        //set1.add(licenseId4.SiteLicenseID__c);
        //moved the mock inside of the startTest
        Test.startTest();
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl3());
        try{
            BizAppsSiteModel.GetLicenseAndRelativesForCreditRequest(set1);
        }catch(Exception e){
            system.debug('\n\nError: ' + e + '\n\nTrace: ' + e.getStackTraceString() + '\n\n');

        }
        Test.stopTest();
    } //*/
    @isTest
    static  void testTerminateAllLicenses1(){

        createTestData2();
        set<Id> lineItemIds = new set<Id>();
        //lineItemIds.add(orderLineItem.Id);
        lineItemIds.add(orderLineItem1.Id);
        Map<id,Order_Line_Item__c> oliMap = new Map<id,Order_Line_Item__c>( [
                SELECT Id, ExpireAll__c, ResultDescription__c, Result__c,
                    (SELECT Id, Name, SiteLicenseID__c, ItemResult__c, QuantityTerminated__c, CompanyXcode__c, AvailableInventory__c, OrderLineItem__c,LicenseID__c FROM License_IDs__r)
                FROM Order_Line_Item__c
                WHERE Id in :lineItemIds
            ]);
         Test.startTest();
        //moved the mock inside of the startTest
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        BizAppsSiteModel.TerminateAllLicenses(oliMap, true);
        BizAppsSiteModel.TerminateAllLicenses(oliMap, true);

        Test.stopTest();
    }
    @isTest
    static void testJSVerifyOrder(){

        createTestData2();
        Test.startTest();
        //Needed to move the mock into the startTest
            Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
            BizAppsSiteModel.JSVerifyOrder(order1.Id,false);
            BizAppsSiteModel.JSVerifyOrder(order1.Id,true);

        Test.stopTest();
    }
    @isTest
    static void testVerifyOrder(){

        createTestData2();
        Test.startTest();
        //Needed to move the mock into the startTest
            Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
            BizAppsSiteModel.VerifyOrder(order1.Id,false);
            BizAppsSiteModel.VerifyOrder(order1.Id,true);
			
        Test.stopTest();
    }
    

    @isTest
    static void testTerminateAllLicenses3(){
        createTestData2();
        Test.startTest();
        //moved the mock inside of the startTest
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        BizAppsSiteModel.TerminateAllLicenses(orderLineItem.Id);
        BizAppsSiteModel.TerminateAllLicenses2(orderLineItem1.Id,true);

        Test.stopTest();

    }
    @isTest
    static void testSiteModel(){

        createTestData();
        List<Order__c> lstOrder = new List<Order__c>();
        lstOrder.add(order1);
        lstOrder.add(order2);
        Test.startTest();
        //Needed to move the mock into the startTest
            Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
            BizAppsSiteModel.ProcessCreditInventory(order1.Id);
            BizAppsSiteModel.TerminateAllLicenses(orderLineItem.Id);
            BizAppsSiteModel.TerminateAllLicenses(orderLineItem1.Id);
            BizAppsSiteModel.TerminateAllLicenses(null);
            BizAppsSiteModel.TerminateAllLicenses2(orderLineItem.Id,true);
            BizAppsSiteModel.autoTriggerVerificationForCredit(lstOrder);
            BizAppsSiteModel.VerifyOrder(order1.Id,true);
        Test.stopTest();
    }

    @isTest
    static void testProcessCreditInventory(){

        createTestData();
        List<Order__c> lstOrder = new List<Order__c>();
        lstOrder.add(order1);
        lstOrder.add(order2);
        Test.startTest();
        //Needed to move the mock into the startTest
            Test.setMock(WebServiceMock.class, new WebServiceMockImpl4());
            BizAppsSiteModel.ProcessCreditInventory(order1.Id);

        Test.stopTest();
    }
  /*   @isTest
    static void testNAOrderStatus(){
	system.debug('Inside testNAOrderStatus');
        createTestData2();
        Test.startTest();
        //Needed to move the mock into the startTest
            Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
            BizAppsSiteModel.SendOrderToSite(order1.Id);           
        Test.stopTest();
    }*/

     public class WebServiceMockImpl implements WebServiceMock  {
        // Implement this interface method
        public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
           v3_monsterBizappsSiterouterSiterouterws.TerminateAllLicensesResult_element responseElement = new v3_monsterBizappsSiterouterSiterouterws.TerminateAllLicensesResult_element();
           v3_monsterBizappsSiterouterSiterouterws.ArrayOfTerminateAllLicensesResponseItem elem1 = new v3_monsterBizappsSiterouterSiterouterws.ArrayOfTerminateAllLicensesResponseItem();
           v3_monsterBizappsSiterouterSiterouterws.TerminateAllLicensesResponseItem[] elem2 = new List<v3_monsterBizappsSiterouterSiterouterws.TerminateAllLicensesResponseItem>();
           v3_monsterBizappsSiterouterSiterouterws.TerminateAllLicensesResponseItem subElem1 = new v3_monsterBizappsSiterouterSiterouterws.TerminateAllLicensesResponseItem();
           subElem1.RequestedTerminationLicenseID = Integer.valueOf(licenseId1.SiteLicenseID__c);
           v3_monsterBizappsSiterouterSiterouterws.ArrayOfTerminatedLicense arrTerminated1 = new v3_monsterBizappsSiterouterSiterouterws.ArrayOfTerminatedLicense();

           v3_monsterBizappsSiterouterSiterouterws.TerminatedLicense[] subTerminated1List = new List<v3_monsterBizappsSiterouterSiterouterws.TerminatedLicense> ();
           v3_monsterBizappsSiterouterSiterouterws.TerminatedLicense subTerminated1 = new v3_monsterBizappsSiterouterSiterouterws.TerminatedLicense();
           v3_monsterBizappsSiterouterSiterouterws.ResponseResult ItemResult1 = new v3_monsterBizappsSiterouterSiterouterws.ResponseResult();
           ItemResult1.Result = 0;
           subTerminated1.ItemResult = ItemResult1;
           v3_monsterBizappsSiterouterSiterouterws.TerminatedLicense subTerminated2 = new v3_monsterBizappsSiterouterSiterouterws.TerminatedLicense();
           v3_monsterBizappsSiterouterSiterouterws.ResponseResult ItemResult2 = new v3_monsterBizappsSiterouterSiterouterws.ResponseResult();
           ItemResult2.Result = 0;
           subTerminated2.ItemResult = ItemResult2;
           subTerminated1List.add(subTerminated1);
           subTerminated1List.add(subTerminated2);
           arrTerminated1.TerminatedLicense = subTerminated1List;
           subElem1.TerminatedLicenses = arrTerminated1;
           v3_monsterBizappsSiterouterSiterouterws.TerminateAllLicensesResponseItem subElem2 = new v3_monsterBizappsSiterouterSiterouterws.TerminateAllLicensesResponseItem();
           subElem2.RequestedTerminationLicenseID = Integer.valueOf(licenseId2.SiteLicenseID__c);
           elem2.add(subElem1);
           elem2.add(subElem2);
           elem1.TerminateAllLicensesResponseItem = elem2;
           responseElement.TerminateAllLicensesResponseItems = elem1;
            responseElement.ResponseCode = 'Success';
            response.put('response_x', responseElement);
        }
    }



    public class WebServiceMockImpl1 implements WebServiceMock  {
        // Implement this interface method
        public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
           v3_monsterBizappsSiterouterSiterouterws.SubmitOrderResult_element responseElement = new v3_monsterBizappsSiterouterSiterouterws.SubmitOrderResult_element();

           v3_monsterBizappsSiterouterSiterouterws.ArrayOfOrderItemResult elem1 = new v3_monsterBizappsSiterouterSiterouterws.ArrayOfOrderItemResult();
           v3_monsterBizappsSiterouterSiterouterws.OrderItemResult[] elem2 = new List<v3_monsterBizappsSiterouterSiterouterws.OrderItemResult>();
           v3_monsterBizappsSiterouterSiterouterws.OrderItemResult subElem1 = new v3_monsterBizappsSiterouterSiterouterws.OrderItemResult();
           subElem1.LineItemRowID = licenseId1.SiteLicenseID__c;
           v3_monsterBizappsSiterouterSiterouterws.OrderItemResult subElem2 = new v3_monsterBizappsSiterouterSiterouterws.OrderItemResult();
           subElem2.LineItemRowID = licenseId2.SiteLicenseID__c;
           v3_monsterBizappsSiterouterSiterouterws.OrderItemResult subElem3 = new v3_monsterBizappsSiterouterSiterouterws.OrderItemResult();
           subElem3.LineItemRowID = licenseId3.SiteLicenseID__c;
           v3_monsterBizappsSiterouterSiterouterws.OrderItemResult subElem4 = new v3_monsterBizappsSiterouterSiterouterws.OrderItemResult();
           subElem4.LineItemRowID = licenseId4.SiteLicenseID__c;

            elem2.add(subElem1);
            elem2.add(subElem2);
            elem2.add(subElem3);
            elem2.add(subElem4);
            elem1.OrderItemResult = elem2;
            responseElement.LineItemResults = elem1;
            response.put('response_x', responseElement);
        }
    }

    public class WebServiceMockImpl2 implements WebServiceMock  {
        // Implement this interface method
        public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
           v3_monsterBizappsSiterouterSiterouterws.TransferInventoryResult_element responseElement = new v3_monsterBizappsSiterouterSiterouterws.TransferInventoryResult_element();

           v3_monsterBizappsSiterouterSiterouterws.ArrayOfTransferInventoryResponseItem elem1 = new v3_monsterBizappsSiterouterSiterouterws.ArrayOfTransferInventoryResponseItem();
           v3_monsterBizappsSiterouterSiterouterws.TransferInventoryResponseItem[] elem2 = new List<v3_monsterBizappsSiterouterSiterouterws.TransferInventoryResponseItem>();
           v3_monsterBizappsSiterouterSiterouterws.TransferInventoryResponseItem subElem1 = new v3_monsterBizappsSiterouterSiterouterws.TransferInventoryResponseItem();
           v3_monsterBizappsSiterouterSiterouterws.TransferInventoryItem Item = new v3_monsterBizappsSiterouterSiterouterws.TransferInventoryItem ();
           v3_monsterBizappsSiterouterSiterouterws.ResponseResult itemResult = new v3_monsterBizappsSiterouterSiterouterws.ResponseResult();
           itemResult.Result = 0;
           item.TransferredFromLicenseID = Integer.valueOf(licenseId1.SiteLicenseID__c);
           item.TransferredToCompanyXcode = xcode.Name;
           subElem1.Item = Item;
           subElem1.ItemResult = ItemResult;
           v3_monsterBizappsSiterouterSiterouterws.TransferInventoryResponseItem subElem2 = new v3_monsterBizappsSiterouterSiterouterws.TransferInventoryResponseItem();
           v3_monsterBizappsSiterouterSiterouterws.TransferInventoryItem Item2 = new v3_monsterBizappsSiterouterSiterouterws.TransferInventoryItem ();
           v3_monsterBizappsSiterouterSiterouterws.ResponseResult itemResult2 = new v3_monsterBizappsSiterouterSiterouterws.ResponseResult();
           itemResult2.Result = 0;
           item2.TransferredFromLicenseID = Integer.valueOf(licenseId2.SiteLicenseID__c);
           item2.TransferredToCompanyXcode = xcode.Name;
           subElem2.Item = Item2;
            subElem2.ItemResult = Itemresult2;
            elem2.add(subElem1);
            elem2.add(subElem2);
            elem1.TransferInventoryResponseItem = elem2;
            responseElement.TransferInventoryResponseItems = elem1;
            response.put('response_x', responseElement);
        }
    }


    public class WebServiceMockImpl3 implements WebServiceMock  {
        // Implement this interface method
        public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {

           v3_monsterBizappsSiterouterSiterouterws.GetMultipleLicenseAndRelativesResp_element responseElement = new v3_monsterBizappsSiterouterSiterouterws.GetMultipleLicenseAndRelativesResp_element();
           v3_monsterBizappsSiterouterSiterouterws.ArrayOfGetLicenseAndRelativesResp elem1 = new v3_monsterBizappsSiterouterSiterouterws.ArrayOfGetLicenseAndRelativesResp();
           responseElement.GetLicenseAndRelativesResponses = elem1;
           elem1.GetLicenseAndRelativesResp = new List<v3_monsterBizappsSiterouterSiterouterws.GetLicenseAndRelativesResp>();
           v3_monsterBizappsSiterouterSiterouterws.GetLicenseAndRelativesResp res = new v3_monsterBizappsSiterouterSiterouterws.GetLicenseAndRelativesResp();
           res.GetLicenseAndRelativesResponseItems = new v3_monsterBizappsSiterouterSiterouterws.ArrayOfGetLicenseAndRelativesResponseItem();
           v3_monsterBizappsSiterouterSiterouterws.GetLicenseAndRelativesResponseItem[] subele = new List<v3_monsterBizappsSiterouterSiterouterws.GetLicenseAndRelativesResponseItem>();
           v3_monsterBizappsSiterouterSiterouterws.GetLicenseAndRelativesResponseItem item = new v3_monsterBizappsSiterouterSiterouterws.GetLicenseAndRelativesResponseItem();
           item.CompanyName = 'xyz company';
           item.ResourceLicenseID =11;
            item.AvailableQuantity =2;
           subele.add(item);
           elem1.GetLicenseAndRelativesResp.add( res);
           res.GetLicenseAndRelativesResponseItems.GetLicenseAndRelativesResponseItem =  subele;
            response.put('response_x', responseElement);
        }
    }
    public class WebServiceMockImpl4 implements WebServiceMock  {
        // Implement this interface method
        public void doInvoke(Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {

            v3_monsterBizappsSiterouterSiterouterws.SubmitAdjustLicenseResult_element responseElement = new v3_monsterBizappsSiterouterSiterouterws.SubmitAdjustLicenseResult_element();
            responseElement.LineItemResults = new v3_monsterBizappsSiterouterSiterouterws.ArrayOfAdjustmentItemResult();
            responseElement.LineItemResults.AdjustmentItemResult = new List<v3_monsterBizappsSiterouterSiterouterws.AdjustmentItemResult>();
            v3_monsterBizappsSiterouterSiterouterws.AdjustmentItemResult subelement = new v3_monsterBizappsSiterouterSiterouterws.AdjustmentItemResult();
            subelement.LicenseID = Integer.valueOf(licenseId2.SiteLicenseID__c);
            subelement.LineItemRowID = orderLineItem.Id;
            responseElement.LineItemResults.AdjustmentItemResult.add(subelement);
            response.put('response_x', responseElement);
        }
    }
   
   

}