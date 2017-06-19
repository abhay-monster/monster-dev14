/*------------------------------------------------------------------------------
Author:        Sunny Gill
Company:       Appirio
Description:   Test class to test AvalaraModel class
Task Reference: T-408273

History
11-June-15      Sunny Gill      created
------------------------------------------------------------------------------*/
@istest
public with sharing class AvalaraModel_Tests {
    static AvalaraSchema.RequestHeader reqHeader;
    public static final String PROFILE_SYS_ADMIN = 'System Administrator';
    public static Map < String, Schema.SObjectType > GLOBAL_MAP = Schema.getGlobalDescribe();
    private static Map < String, Schema.DescribeSObjectResult > mapSobjectDescribe = new Map < String, Schema.DescribeSObjectResult > ();
    private static Apttus_Proposal__Proposal__c proposal,proposal1;
    static Order_Line_Item__c orderLine,orderLine1,orderLine2;
    static Apttus_Proposal__Proposal_Line_Item__c lineitem,lineitem1;
    private static User sysAdmin = TestDataSetupUtility.createUser('System Administrator', true);
    private static Id rtCredit = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c','Credit');
    private static Id rtRebill = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c','Rebill Order');
    
	static Apttus_Config2__ProductConfiguration__c aptusConfig;
	static Apttus_Config2__LineItem__c  aptusLineItem1,aptusLineItem2,aptusLineItem3;
	static List<Apttus_Config2__LineItem__c> aptusLineItemList;
    
    /*------------------------------------------------------------------------
    Author:        Sunny Gill
    Company:       Appirio
    Description:   A test method to validate and calculate sales tax when clicked from Proposal detail page's
                    Get tax button

    Methods Being Tested: getQuoteTaxFromButton()
    ----------------------------------------------------------------------------*/
    static testMethod void testgetQuoteTaxFromButton() {
        System.runAs(sysAdmin){
            createData();



            IntegrationConfig__c setting = new IntegrationConfig__c(Name = 'Avalara Integration', AvalaraClient__c = 'Monster Worldwide, Inc.',
                AvalaraCompanyCode__c = 'MWW', AvalaraCountry__c = 'MWW', EndpointName__c = 'AvalaraDev',IsPaypalTest__c = false,
                Password__c = '6NvqAGdhXM^y',Timeout__c = 60000,Username__c = 'jlescarbeau@appirio.com', PaypalRedirectURL__c = 'PaypalRedirectURL');
            insert setting;
            WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c(Name = 'AvalaraDev', Endpoint__c = 'https://development.avalara.net/1.0/tax/get');
            WebServiceEndpoint__c endpoint2 = new WebServiceEndpoint__c(Name = 'PaypalRedirectURL', Endpoint__c = 'https://payflowlink.paypal.com');
            insert new List<WebServiceEndpoint__c>{endpoint, endpoint2};


            lineitem = TestDataSetupUtility.createProposalLineItem(proposal.Id);
            lineitem.Apttus_QPConfig__OptionPrice__c = null;
             lineitem.Apttus_QPConfig__LineStatus__c = 'New';
             lineitem.APTS_Is_Agency_Commission_Different__c = 1;
             lineitem.Apttus_QPConfig__NetPrice__c = 10000;
              lineitem.APTS_Extended_List_Price__c= 100;
              lineitem.Apttus_QPConfig__BaseExtendedPrice__c = 1;


              lineitem1 = TestDataSetupUtility.createProposalLineItem(proposal1.Id);
             lineitem1.Apttus_QPConfig__OptionPrice__c = null;
             lineitem1.Apttus_QPConfig__LineStatus__c = 'New';
             lineitem1.APTS_Is_Agency_Commission_Different__c = 1;
             lineitem1.Apttus_QPConfig__NetPrice__c = 10000;
             lineitem1.APTS_Extended_List_Price__c= 100;
             lineitem1.Apttus_QPConfig__BaseExtendedPrice__c = 1;
             insert (new List<Apttus_Proposal__Proposal_Line_Item__c>{lineitem,lineitem1}) ;
             Test.startTest();
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator3());
                //Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
                AvalaraModel model = new AvalaraModel(reqHeader);
                AvalaraModel.getQuoteTaxFromButton(proposal1.Id);
                AvalaraModel.setIstoCommit(proposal1.Id);

            Test.stopTest();
            //AvalaraSchema.GetTaxRequest pRequest = new AvalaraSchema.GetTaxRequest ();
            //AvalaraSchema.GetTaxResponse taxResponse = model.GetTax(pRequest);
        }
    }



    static testMethod void testOrderGenerate(){
        System.runAs(sysAdmin){
            createData();
            IntegrationConfig__c setting = new IntegrationConfig__c(Name = 'Avalara Integration', AvalaraClient__c = 'Monster Worldwide, Inc.',
                AvalaraCompanyCode__c = 'MWW', AvalaraCountry__c = 'MWW', EndpointName__c = 'AvalaraDev',IsPaypalTest__c = false,
                Password__c = '6NvqAGdhXM^y',Timeout__c = 60000,Username__c = 'jlescarbeau@appirio.com', PaypalRedirectURL__c = 'PaypalRedirectURL');
            insert setting;
            WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c(Name = 'AvalaraDev', Endpoint__c = 'https://development.avalara.net/1.0/tax/get');
            WebServiceEndpoint__c endpoint2 = new WebServiceEndpoint__c(Name = 'PaypalRedirectURL', Endpoint__c = 'https://payflowlink.paypal.com');
            insert new List<WebServiceEndpoint__c>{endpoint, endpoint2};
            AvalaraModel model = new AvalaraModel(reqHeader);
            Account acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TESTACCCCH1 ');
            acc.ShippingCountryCode = 'IN';
            acc.ShippingCountry = 'India';
            acc.ShippingState = '';
            Account acc1 = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TESTACCCCH ');
            insert (new List<Account>{acc,acc1});
            Contact con = TestDataSetupUtility.createTestContact(acc.Id, 'confirst1', 'conlast1', 'con1@email.com');
            insert con;
            Order__c pOrder = TestDataSetupUtility.createOrder(acc.Id,con.Id);
            pOrder.QuoteProposal__c = proposal.Id;
            pOrder.Organization__c = 'North America';
            pOrder.Pricing_Channel__c = 'Agency';
            Contact con2 = TestDataSetupUtility.createTestContact(acc1.Id, 'confirst1', 'conlast1', 'con1@email.com');
            insert con2;
            Order__c pOrder1 = TestDataSetupUtility.createOrder(acc1.Id,con2.Id);
            pOrder1.QuoteProposal__c = proposal.Id;
            Order__c pOrder2 = TestDataSetupUtility.createOrder(acc.Id, con.Id);
            pOrder2.Organization__c = 'Europe';
            pOrder2.Pricing_Channel__c = 'Agency';

            pOrder.recordTypeId = rtCredit;
            pOrder1.recordTypeId = rtRebill;
            insert (new List<Order__c>{pOrder,pOrder1,pOrder2});
            orderLine = TestDataSetupUtility.createOrderLineItem(pOrder1.id);
            orderLine1 = TestDataSetupUtility.createOrderLineItem(pOrder.id);
            orderLine2 = TestDataSetupUtility.createOrderLineItem(pOrder2.id);
            insert (new List<Order_Line_Item__c>{orderLine,orderLine1,orderLine2});

             lineitem = TestDataSetupUtility.createProposalLineItem(proposal.Id);
            lineitem.Apttus_QPConfig__OptionPrice__c = null;
             lineitem.Apttus_QPConfig__LineStatus__c = 'New';
             lineitem.APTS_Is_Agency_Commission_Different__c = 1;
             lineitem.Apttus_QPConfig__NetPrice__c = 10000;
              lineitem.APTS_Extended_List_Price__c= 100;
              lineitem.Apttus_QPConfig__BaseExtendedPrice__c = 1;


               lineitem1 = TestDataSetupUtility.createProposalLineItem(proposal1.Id);
             lineitem1.Apttus_QPConfig__OptionPrice__c = null;
             lineitem1.Apttus_QPConfig__LineStatus__c = 'New';
             lineitem1.APTS_Is_Agency_Commission_Different__c = 1;
             lineitem1.Apttus_QPConfig__NetPrice__c = 10000;
             lineitem1.APTS_Extended_List_Price__c= 100;
             lineitem1.Apttus_QPConfig__BaseExtendedPrice__c = 1;
             insert (new List<Apttus_Proposal__Proposal_Line_Item__c>{lineitem,lineitem1}) ;


            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator3());
            AvalaraSchema.GetTaxRequest req =  model.OrderGenerateRequest(pOrder);
            req =  model.OrderGenerateRequest(pOrder1);

            //Custom setting for address
            AvalaraAddressInfo__c addressCustomSetting = new AvalaraAddressInfo__c(Name=  'United States',Address1__c  = 'Test1',Address2__c = 'Test2',Address3__c = 'Test3');
            addressCustomSetting.City__c = 'Abc';
            addressCustomSetting.CountryCode__c =  '01';
            addressCustomSetting.StateProvince__c = 'State';
            addressCustomSetting.ZIPPostalCode__c = '20202';
            insert addressCustomSetting;

            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{proposal.Id},AvalaraModel.QUOTE);
            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{proposal.Id,proposal1.Id},AvalaraModel.QUOTE);
            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{pOrder1.Id},AvalaraModel.ORDER);
            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{pOrder.Id},AvalaraModel.ORDER);
            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{pOrder2.Id},AvalaraModel.ORDER);
            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{pOrder1.Id,pOrder.Id},AvalaraModel.ORDER);



        }

    }


    static testMethod void testOrderGenerate1(){
        System.runAs(sysAdmin){
            createData();
            IntegrationConfig__c setting = new IntegrationConfig__c(Name = 'Avalara Integration', AvalaraClient__c = 'Monster Worldwide, Inc.',
                AvalaraCompanyCode__c = 'MWW', AvalaraCountry__c = 'MWW', EndpointName__c = 'AvalaraDev',IsPaypalTest__c = false,
                Password__c = '6NvqAGdhXM^y',Timeout__c = 60000,Username__c = 'jlescarbeau@appirio.com', PaypalRedirectURL__c = 'PaypalRedirectURL');
            insert setting;
            WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c(Name = 'AvalaraDev', Endpoint__c = 'https://development.avalara.net/1.0/tax/get');
            WebServiceEndpoint__c endpoint2 = new WebServiceEndpoint__c(Name = 'PaypalRedirectURL', Endpoint__c = 'https://payflowlink.paypal.com');
            insert new List<WebServiceEndpoint__c>{endpoint, endpoint2};
            AvalaraModel model = new AvalaraModel(reqHeader);


            Account acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TESTACCCCH1 ');
            acc.ShippingCountryCode = 'IN';
            acc.ShippingCountry = 'India';
            acc.ShippingState = '';
            Account acc1 = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TESTACCCCH ');
            insert (new List<Account>{acc,acc1});
            Contact con = TestDataSetupUtility.createTestContact(acc.Id, 'confirst1', 'conlast1', 'con1@email.com');
            insert con;
            Order__c pOrder = TestDataSetupUtility.createOrder(acc.Id, con.Id);
            pOrder.QuoteProposal__c = proposal.Id;
            pOrder.Organization__c = 'North America';
            pOrder.Pricing_Channel__c = 'Agency';
            Contact con2 = TestDataSetupUtility.createTestContact(acc1.Id, 'confirst1', 'conlast1', 'con1@email.com');
            insert con2;
            Order__c pOrder1 = TestDataSetupUtility.createOrder(acc1.Id,con2.Id);
            pOrder1.QuoteProposal__c = proposal.Id;
            Order__c pOrder2 = TestDataSetupUtility.createOrder(acc.Id, con.Id);
            pOrder2.Organization__c = 'Europe';
            pOrder2.Pricing_Channel__c = 'Agency';

            pOrder.recordTypeId = rtCredit;
            pOrder1.recordTypeId = rtRebill;
            insert (new List<Order__c>{pOrder,pOrder1,pOrder2});

            AvalaraModel.getOrderTaxFromButton(pOrder.Id);
            AvalaraModel.hardcodedTest();
            orderLine = TestDataSetupUtility.createOrderLineItem(pOrder1.id);
            orderLine1 = TestDataSetupUtility.createOrderLineItem(pOrder.id);
            orderLine2 = TestDataSetupUtility.createOrderLineItem(pOrder2.id);
            insert (new List<Order_Line_Item__c>{orderLine,orderLine1,orderLine2});

             lineitem = TestDataSetupUtility.createProposalLineItem(proposal.Id);
            lineitem.Apttus_QPConfig__OptionPrice__c = null;
             lineitem.Apttus_QPConfig__LineStatus__c = 'New';
             lineitem.APTS_Is_Agency_Commission_Different__c = 1;
             lineitem.Apttus_QPConfig__NetPrice__c = 10000;
              lineitem.APTS_Extended_List_Price__c= 100;
              lineitem.Apttus_QPConfig__BaseExtendedPrice__c = 1;


               lineitem1 = TestDataSetupUtility.createProposalLineItem(proposal1.Id);
             lineitem1.Apttus_QPConfig__OptionPrice__c = null;
             lineitem1.Apttus_QPConfig__LineStatus__c = 'New';
             lineitem1.APTS_Is_Agency_Commission_Different__c = 1;
             lineitem1.Apttus_QPConfig__NetPrice__c = 10000;
             lineitem1.APTS_Extended_List_Price__c= 100;
             lineitem1.Apttus_QPConfig__BaseExtendedPrice__c = 1;
             insert (new List<Apttus_Proposal__Proposal_Line_Item__c>{lineitem,lineitem1}) ;


            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());
            AvalaraSchema.GetTaxRequest req =  model.OrderGenerateRequest(pOrder);
            req =  model.OrderGenerateRequest(pOrder1);

            //Custom setting for address
            AvalaraAddressInfo__c addressCustomSetting = new AvalaraAddressInfo__c(Name=  'United States',Address1__c  = 'Test1',Address2__c = 'Test2',Address3__c = 'Test3');
            addressCustomSetting.City__c = 'Abc';
            addressCustomSetting.CountryCode__c =  '01';
            addressCustomSetting.StateProvince__c = 'State';
            addressCustomSetting.ZIPPostalCode__c = '20202';
            insert addressCustomSetting;

            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{proposal.Id},AvalaraModel.QUOTE);
            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{proposal1.Id},AvalaraModel.QUOTE);
            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{proposal.Id,proposal1.Id},AvalaraModel.QUOTE);
            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{pOrder1.Id},AvalaraModel.ORDER);
            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{pOrder.Id},AvalaraModel.ORDER);
            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{pOrder2.Id},AvalaraModel.ORDER);
            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{pOrder1.Id,pOrder.Id},AvalaraModel.ORDER);



        }

    }

    static testMethod void testOrderGenerate2(){
        System.runAs(sysAdmin){
            createData();
            IntegrationConfig__c setting = new IntegrationConfig__c(Name = 'Avalara Integration', AvalaraClient__c = 'Monster Worldwide, Inc.',
                AvalaraCompanyCode__c = 'MWW', AvalaraCountry__c = 'MWW', EndpointName__c = 'AvalaraDev',IsPaypalTest__c = false,
                Password__c = '6NvqAGdhXM^y',Timeout__c = 60000,Username__c = 'jlescarbeau@appirio.com', PaypalRedirectURL__c = 'PaypalRedirectURL');
            insert setting;
            WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c(Name = 'AvalaraDev', Endpoint__c = 'https://development.avalara.net/1.0/tax/get');
            WebServiceEndpoint__c endpoint2 = new WebServiceEndpoint__c(Name = 'PaypalRedirectURL', Endpoint__c = 'https://payflowlink.paypal.com');
            insert new List<WebServiceEndpoint__c>{endpoint, endpoint2};
            AvalaraModel model = new AvalaraModel(reqHeader);
            Account acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TESTACCCCH1 ');
            acc.ShippingCountryCode = 'IN';
            acc.ShippingCountry = 'India';
            acc.ShippingState = '';
            Account acc1 = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TESTACCCCH ');
            insert (new List<Account>{acc,acc1});
            Contact con = TestDataSetupUtility.createTestContact(acc.Id, 'confirst1', 'conlast1', 'con1@email.com');
            insert con;
            Order__c pOrder = TestDataSetupUtility.createOrder(acc.Id, con.Id);
            pOrder.QuoteProposal__c = proposal.Id;
            pOrder.Organization__c = 'North America';
            pOrder.Pricing_Channel__c = 'Agency';
            Contact con2 = TestDataSetupUtility.createTestContact(acc1.Id, 'confirst1', 'conlast1', 'con1@email.com');
            insert con2;
            Order__c pOrder1 = TestDataSetupUtility.createOrder(acc1.Id, con2.Id);
            pOrder1.QuoteProposal__c = proposal.Id;
            Order__c pOrder2 = TestDataSetupUtility.createOrder(acc.Id, con.Id);
            pOrder2.Organization__c = 'Europe';
            pOrder2.Pricing_Channel__c = 'Agency';

            pOrder.recordTypeId = rtCredit;
            pOrder1.recordTypeId = rtRebill;
            insert (new List<Order__c>{pOrder,pOrder1,pOrder2});
            orderLine = TestDataSetupUtility.createOrderLineItem(pOrder1.id);
            orderLine1 = TestDataSetupUtility.createOrderLineItem(pOrder.id);
            orderLine2 = TestDataSetupUtility.createOrderLineItem(pOrder2.id);
            insert (new List<Order_Line_Item__c>{orderLine,orderLine1,orderLine2});

             lineitem = TestDataSetupUtility.createProposalLineItem(proposal.Id);
            lineitem.Apttus_QPConfig__OptionPrice__c = null;
             lineitem.Apttus_QPConfig__LineStatus__c = 'New';
             lineitem.APTS_Is_Agency_Commission_Different__c = 1;
             lineitem.Apttus_QPConfig__NetPrice__c = 10000;
              lineitem.APTS_Extended_List_Price__c= 100;
              lineitem.Apttus_QPConfig__BaseExtendedPrice__c = 1;


               lineitem1 = TestDataSetupUtility.createProposalLineItem(proposal1.Id);
             lineitem1.Apttus_QPConfig__OptionPrice__c = null;
             lineitem1.Apttus_QPConfig__LineStatus__c = 'New';
             lineitem1.APTS_Is_Agency_Commission_Different__c = 1;
             lineitem1.Apttus_QPConfig__NetPrice__c = 10000;
             lineitem1.APTS_Extended_List_Price__c= 100;
             lineitem1.Apttus_QPConfig__BaseExtendedPrice__c = 1;
             insert (new List<Apttus_Proposal__Proposal_Line_Item__c>{lineitem,lineitem1}) ;
            //Custom setting for address
            AvalaraAddressInfo__c addressCustomSetting = new AvalaraAddressInfo__c(Name=  'United States',Address1__c  = 'Test1',Address2__c = 'Test2',Address3__c = 'Test3');
            addressCustomSetting.City__c = 'Abc';
            addressCustomSetting.CountryCode__c =  '01';
            addressCustomSetting.StateProvince__c = 'State';
            addressCustomSetting.ZIPPostalCode__c = '20202';
            insert addressCustomSetting;

            Test.startTest();

            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator2());
            AvalaraSchema.GetTaxRequest req =  model.OrderGenerateRequest(pOrder);
            req =  model.OrderGenerateRequest(pOrder1);

            createData_New();
            AvalaraModel.configStartTaxRateProcessing(new Set<Id>{aptusConfig.id});

            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{proposal.Id},AvalaraModel.QUOTE);
            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{proposal.Id,proposal1.Id},AvalaraModel.QUOTE);
            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{pOrder1.Id},AvalaraModel.ORDER);
            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{pOrder.Id},AvalaraModel.ORDER);
            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{pOrder2.Id},AvalaraModel.ORDER);
            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{pOrder1.Id,pOrder.Id},AvalaraModel.ORDER);
            Test.stopTest();


        }

    }

    static testMethod void testGetTax(){
        System.runAs(sysAdmin){
            createData();
            IntegrationConfig__c setting = new IntegrationConfig__c(Name = 'Avalara Integration', AvalaraClient__c = 'Monster Worldwide, Inc.',
                AvalaraCompanyCode__c = 'MWW', AvalaraCountry__c = 'MWW', EndpointName__c = 'AvalaraDev',IsPaypalTest__c = false,
                Password__c = '6NvqAGdhXM^y',Timeout__c = 60000,Username__c = 'jlescarbeau@appirio.com', PaypalRedirectURL__c = 'PaypalRedirectURL');
            IntegrationConfig__c setting1 = new IntegrationConfig__c(Name = 'ValidateAddress', AvalaraClient__c = 'Monster Worldwide, Inc.',
                AvalaraCompanyCode__c = 'MWW', AvalaraCountry__c = 'MWW', EndpointName__c = 'AvalaraDev',IsPaypalTest__c = false,
                Password__c = '6NvqAGdhXM^y',Timeout__c = 60000,Username__c = 'jlescarbeau@appirio.com', PaypalRedirectURL__c = 'PaypalRedirectURL');
            insert (new List<IntegrationConfig__c>{setting,setting1});
            AvalaraAddressInfo__c avalaraAddress = new AvalaraAddressInfo__c(Name = 'United States',Address1__c = 'Test',City__c = 'Boston', CountryCode__c = '01' , ZIPPostalCode__c = '30202');
            insert avalaraAddress;
            WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c(Name = 'AvalaraDev', Endpoint__c = 'https://development.avalara.net/1.0/tax/get');
            WebServiceEndpoint__c endpoint2 = new WebServiceEndpoint__c(Name = 'PaypalRedirectURL', Endpoint__c = 'https://payflowlink.paypal.com');
            insert new List<WebServiceEndpoint__c>{endpoint, endpoint2};
            AvalaraModel model = new AvalaraModel(reqHeader);
            Account acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TESTACCCCH1 ');
            acc.ShippingCountryCode = 'IN';
            acc.ShippingCountry = 'India';
            acc.ShippingState = '';
            Account acc1 = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TESTACCCCH ');
            insert (new List<Account>{acc,acc1});
            Contact con = TestDataSetupUtility.createTestContact(acc.Id, 'confirst1', 'conlast1', 'con1@email.com');
            insert con;
            Order__c pOrder = TestDataSetupUtility.createOrder(acc.Id, con.Id);
            pOrder.QuoteProposal__c = proposal.Id;
            pOrder.Organization__c = 'North America';
            pOrder.Pricing_Channel__c = 'Agency';
            Contact con2 = TestDataSetupUtility.createTestContact(acc.Id, 'confirst1', 'conlast1', 'con1@email.com');
            insert con2;
            Order__c pOrder1 = TestDataSetupUtility.createOrder(acc1.Id, con2.Id);
            pOrder1.QuoteProposal__c = proposal.Id;
            Order__c pOrder2 = TestDataSetupUtility.createOrder(acc.Id, con.Id);
            pOrder2.Organization__c = 'Europe';
            pOrder2.Pricing_Channel__c = 'Agency';

            pOrder.recordTypeId = rtCredit;
            pOrder1.recordTypeId = rtRebill;
            insert (new List<Order__c>{pOrder,pOrder1,pOrder2});
            orderLine = TestDataSetupUtility.createOrderLineItem(pOrder1.id);
            orderLine1 = TestDataSetupUtility.createOrderLineItem(pOrder.id);
            orderLine2 = TestDataSetupUtility.createOrderLineItem(pOrder2.id);
            insert (new List<Order_Line_Item__c>{orderLine,orderLine1,orderLine2});

             lineitem = TestDataSetupUtility.createProposalLineItem(proposal.Id);
            lineitem.Apttus_QPConfig__OptionPrice__c = null;
             lineitem.Apttus_QPConfig__LineStatus__c = 'New';
             lineitem.APTS_Is_Agency_Commission_Different__c = 1;
             lineitem.Apttus_QPConfig__NetPrice__c = 10000;
              lineitem.APTS_Extended_List_Price__c= 100;
              lineitem.Apttus_QPConfig__BaseExtendedPrice__c = 1;


               lineitem1 = TestDataSetupUtility.createProposalLineItem(proposal1.Id);
             lineitem1.Apttus_QPConfig__OptionPrice__c = null;
             lineitem1.Apttus_QPConfig__LineStatus__c = 'New';
             lineitem1.APTS_Is_Agency_Commission_Different__c = 1;
             lineitem1.Apttus_QPConfig__NetPrice__c = 10000;
             lineitem1.APTS_Extended_List_Price__c= 100;
             lineitem1.Apttus_QPConfig__BaseExtendedPrice__c = 1;
             insert (new List<Apttus_Proposal__Proposal_Line_Item__c>{lineitem,lineitem1}) ;


            AvalaraSchema.GetTaxRequest req =  model.OrderGenerateRequest(pOrder);
            req =  model.OrderGenerateRequest(pOrder1);

            //Custom setting for address
            AvalaraAddressInfo__c addressCustomSetting = new AvalaraAddressInfo__c(Name=  'United States',Address1__c  = 'Test1',Address2__c = 'Test2',Address3__c = 'Test3');
            addressCustomSetting.City__c = 'Abc';
            addressCustomSetting.CountryCode__c =  '01';
            addressCustomSetting.StateProvince__c = 'State';
            addressCustomSetting.ZIPPostalCode__c = '20202';
            insert addressCustomSetting;

            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{proposal.Id},AvalaraModel.QUOTE);
            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{proposal.Id,proposal1.Id},AvalaraModel.QUOTE);
            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{pOrder1.Id},AvalaraModel.ORDER);
            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{pOrder.Id},AvalaraModel.ORDER);
            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{pOrder2.Id},AvalaraModel.ORDER);
            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{pOrder1.Id,pOrder.Id},AvalaraModel.ORDER);

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator3());
            //Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
            //Generating exception
            AvalaraSchema.GetTaxResponse resTax = model.GetTax(req);
            AvalaraSchema.Address addressResponse = new AvalaraSchema.Address();

            AvalaraModel.validateOrUpdateAddress(addressResponse,acc.Id);
            Test.stopTest();
        }

    }

    static testMethod void testGetTax2(){
        System.runAs(sysAdmin){
            createData();
            IntegrationConfig__c setting = new IntegrationConfig__c(Name = 'Avalara Integration', AvalaraClient__c = 'Monster Worldwide, Inc.',
                AvalaraCompanyCode__c = 'MWW', AvalaraCountry__c = 'MWW', EndpointName__c = 'AvalaraDev',IsPaypalTest__c = false,
                Password__c = '6NvqAGdhXM^y',Timeout__c = 60000,Username__c = 'jlescarbeau@appirio.com', PaypalRedirectURL__c = 'PaypalRedirectURL');
            IntegrationConfig__c setting1 = new IntegrationConfig__c(Name = 'ValidateAddress', AvalaraClient__c = 'Monster Worldwide, Inc.',
                AvalaraCompanyCode__c = 'MWW', AvalaraCountry__c = 'MWW', EndpointName__c = 'AvalaraDev',IsPaypalTest__c = false,
                Password__c = '6NvqAGdhXM^y',Timeout__c = 60000,Username__c = 'jlescarbeau@appirio.com', PaypalRedirectURL__c = 'PaypalRedirectURL');
            insert (new List<IntegrationConfig__c>{setting,setting1});
            AvalaraAddressInfo__c avalaraAddress = new AvalaraAddressInfo__c(Name = 'United States',Address1__c = 'Test',City__c = 'Boston', CountryCode__c = '01' , ZIPPostalCode__c = '30202');
            insert avalaraAddress;
            WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c(Name = 'AvalaraDev', Endpoint__c = 'https://development.avalara.net/1.0/tax/get');
            WebServiceEndpoint__c endpoint2 = new WebServiceEndpoint__c(Name = 'PaypalRedirectURL', Endpoint__c = 'https://payflowlink.paypal.com');
            insert new List<WebServiceEndpoint__c>{endpoint, endpoint2};
            AvalaraModel model = new AvalaraModel(reqHeader);
            Account acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TESTACCCCH1 ');
            acc.ShippingCountryCode = 'IN';
            acc.ShippingCountry = 'India';
            acc.ShippingState = '';
            Account acc1 = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TESTACCCCH ');
            insert (new List<Account>{acc,acc1});
            Contact con = TestDataSetupUtility.createTestContact(acc.Id, 'confirst1', 'conlast1', 'con1@email.com');
            insert con;
            Product2 p2 = TestDataSetupUtility.createTestProduct2('Test Product');
            p2.ProductCode = 'QUOTE BUNDLE';
            insert p2;
            Order__c pOrder = TestDataSetupUtility.createOrder(acc.Id, con.Id);
            pOrder.QuoteProposal__c = proposal.Id;
            pOrder.Organization__c = 'North America';
            pOrder.Pricing_Channel__c = 'Agency';
            Contact con2 = TestDataSetupUtility.createTestContact(acc.Id, 'confirst1', 'conlast1', 'con1@email.com');
            insert con2;
            Order__c pOrder1 = TestDataSetupUtility.createOrder(acc1.Id, con2.Id);
            pOrder1.QuoteProposal__c = proposal.Id;
            Order__c pOrder2 = TestDataSetupUtility.createOrder(acc.Id, con.Id);
            pOrder2.Organization__c = 'Europe';
            pOrder2.Pricing_Channel__c = 'Agency';
            pOrder.recordTypeId = rtCredit;
            pOrder1.recordTypeId = rtRebill;
            insert (new List<Order__c>{pOrder,pOrder1,pOrder2});
            orderLine = TestDataSetupUtility.createOrderLineItem(pOrder1.id);
            orderLine1 = TestDataSetupUtility.createOrderLineItem(pOrder.id);
            orderLine2 = TestDataSetupUtility.createOrderLineItem(pOrder2.id);
            orderLine1.Product__c = p2.Id;
            orderLine2.Product__c = p2.Id;
            orderLine1.LineType__c = 'Option';
            insert (new List<Order_Line_Item__c>{orderLine,orderLine1,orderLine2});

             lineitem = TestDataSetupUtility.createProposalLineItem(proposal.Id);
            lineitem.Apttus_QPConfig__OptionPrice__c = null;
             lineitem.Apttus_QPConfig__LineStatus__c = 'New';
             lineitem.APTS_Is_Agency_Commission_Different__c = 1;
             lineitem.Apttus_QPConfig__NetPrice__c = 10000;
              lineitem.APTS_Extended_List_Price__c= 100;
              lineitem.Apttus_QPConfig__BaseExtendedPrice__c = 1;


               lineitem1 = TestDataSetupUtility.createProposalLineItem(proposal1.Id);
             lineitem1.Apttus_QPConfig__OptionPrice__c = null;
             lineitem1.Apttus_QPConfig__LineStatus__c = 'New';
             lineitem1.APTS_Is_Agency_Commission_Different__c = 1;
             lineitem1.Apttus_QPConfig__NetPrice__c = 10000;
             lineitem1.APTS_Extended_List_Price__c= 100;
             lineitem1.Apttus_QPConfig__BaseExtendedPrice__c = 1;
             insert (new List<Apttus_Proposal__Proposal_Line_Item__c>{lineitem,lineitem1}) ;


            AvalaraSchema.GetTaxRequest req =  model.OrderGenerateRequest(pOrder);
            req =  model.OrderGenerateRequest(pOrder1);

            //Custom setting for address
            AvalaraAddressInfo__c addressCustomSetting = new AvalaraAddressInfo__c(Name=  'United States',Address1__c  = 'Test1',Address2__c = 'Test2',Address3__c = 'Test3');
            addressCustomSetting.City__c = 'Abc';
            addressCustomSetting.CountryCode__c =  '01';
            addressCustomSetting.StateProvince__c = 'State';
            addressCustomSetting.ZIPPostalCode__c = '20202';
            insert addressCustomSetting;

            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{proposal.Id},AvalaraModel.QUOTE);
            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{proposal.Id,proposal1.Id},AvalaraModel.QUOTE);
            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{pOrder1.Id},AvalaraModel.ORDER);
            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{pOrder.Id},AvalaraModel.ORDER);
            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{pOrder2.Id},AvalaraModel.ORDER);
            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{pOrder1.Id,pOrder.Id},AvalaraModel.ORDER);

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator2());
            //Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
            //Generating exception
            AvalaraSchema.GetTaxResponse resTax = model.GetTax(req);
            AvalaraSchema.Address addressResponse = new AvalaraSchema.Address();

            AvalaraModel.validateOrUpdateAddress(addressResponse,acc.Id);
            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{pOrder2.Id},AvalaraModel.ORDER);
            Test.stopTest();
        }

    }

    static testMethod void testGetTax3(){
        System.runAs(sysAdmin){
            createData();
            IntegrationConfig__c setting = new IntegrationConfig__c(Name = 'Avalara Integration', AvalaraClient__c = 'Monster Worldwide, Inc.',
                AvalaraCompanyCode__c = 'MWW', AvalaraCountry__c = 'MWW', EndpointName__c = 'AvalaraDev',IsPaypalTest__c = false,
                Password__c = '6NvqAGdhXM^y',Timeout__c = 60000,Username__c = 'jlescarbeau@appirio.com', PaypalRedirectURL__c = 'PaypalRedirectURL');
            IntegrationConfig__c setting1 = new IntegrationConfig__c(Name = 'ValidateAddress', AvalaraClient__c = 'Monster Worldwide, Inc.',
                AvalaraCompanyCode__c = 'MWW', AvalaraCountry__c = 'MWW', EndpointName__c = 'AvalaraDev',IsPaypalTest__c = false,
                Password__c = '6NvqAGdhXM^y',Timeout__c = 60000,Username__c = 'jlescarbeau@appirio.com', PaypalRedirectURL__c = 'PaypalRedirectURL');
            insert (new List<IntegrationConfig__c>{setting,setting1});
            AvalaraAddressInfo__c avalaraAddress = new AvalaraAddressInfo__c(Name = 'United States',Address1__c = 'Test',Address2__c = 'Test2',Address3__c = 'Test3',City__c = 'Boston', CountryCode__c = '01' , ZIPPostalCode__c = '30202');
            insert avalaraAddress;
            WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c(Name = 'AvalaraDev', Endpoint__c = 'https://development.avalara.net/1.0/tax/get');
            WebServiceEndpoint__c endpoint2 = new WebServiceEndpoint__c(Name = 'PaypalRedirectURL', Endpoint__c = 'https://payflowlink.paypal.com');
            insert new List<WebServiceEndpoint__c>{endpoint, endpoint2};
            AvalaraModel model = new AvalaraModel(reqHeader);
            Account acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TESTACCCCH1 ');
            acc.ShippingCountryCode = 'IN';
            acc.ShippingCountry = 'India';
            acc.ShippingState = '';
            Account acc1 = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TESTACCCCH ');
            insert (new List<Account>{acc,acc1});
            Contact con = TestDataSetupUtility.createTestContact(acc.Id, 'confirst1', 'conlast1', 'con1@email.com');
            insert con;
            Order__c pOrder = TestDataSetupUtility.createOrder(acc.Id, con.Id);
            pOrder.QuoteProposal__c = proposal.Id;
            pOrder.Organization__c = 'North America';
            //pOrder.Selling_Country__c = 'United States';
            //pOrder.Pricing_Channel__c = 'Agency';
            Contact con2 = TestDataSetupUtility.createTestContact(acc.Id, 'confirst1', 'conlast1', 'con1@email.com');
            insert con2;
            Product2 p2 = TestDataSetupUtility.createTestProduct2('Test Product');
            p2.ProductCode = 'QUOTE BUNDLE';
            Product2 p3 = TestDataSetupUtility.createTestProduct2('Test Product');
            p3.ProductCode = 'BUNDLE';
            insert new List<Product2>{p2,p3};
            Order__c pOrder1 = TestDataSetupUtility.createOrder(acc1.Id, con2.Id);
            pOrder1.QuoteProposal__c = proposal.Id;
            Order__c pOrder2 = TestDataSetupUtility.createOrder(acc.Id, con.Id);
            pOrder2.Organization__c = 'Europe';
            pOrder2.Pricing_Channel__c = 'Agency';

            pOrder.recordTypeId = rtCredit;
            pOrder1.recordTypeId = rtRebill;
            insert (new List<Order__c>{pOrder,pOrder1,pOrder2});
            orderLine = TestDataSetupUtility.createOrderLineItem(pOrder1.id);
            orderLine.Product__c = p2.Id;
            orderLine1 = TestDataSetupUtility.createOrderLineItem(pOrder.id);
            orderLine1.Product__c = p2.Id;
            orderLine1.LineType__c = 'Option';
            orderLine2 = TestDataSetupUtility.createOrderLineItem(pOrder2.id);
            orderLine2.Product__c = p3.Id;
            insert (new List<Order_Line_Item__c>{orderLine,orderLine1,orderLine2});

             lineitem = TestDataSetupUtility.createProposalLineItem(proposal.Id);
            lineitem.Apttus_QPConfig__OptionPrice__c = null;
             lineitem.Apttus_QPConfig__LineStatus__c = 'New';
             lineitem.APTS_Is_Agency_Commission_Different__c = 1;
             lineitem.Apttus_QPConfig__NetPrice__c = 10000;
              lineitem.APTS_Extended_List_Price__c= 100;
              lineitem.Apttus_QPConfig__BaseExtendedPrice__c = 1;
              lineitem.Apttus_Proposal__Product__c =p2.Id;
             lineitem.Apttus_QPConfig__LineType__c = 'Option';

               lineitem1 = TestDataSetupUtility.createProposalLineItem(proposal1.Id);
             lineitem1.Apttus_QPConfig__OptionPrice__c = null;
             lineitem1.Apttus_QPConfig__LineStatus__c = 'New';
             lineitem1.APTS_Is_Agency_Commission_Different__c = 1;
             lineitem1.Apttus_QPConfig__NetPrice__c = 10000;
             lineitem1.APTS_Extended_List_Price__c= 100;
             lineitem1.Apttus_QPConfig__BaseExtendedPrice__c = 1;
             lineitem1.Apttus_Proposal__Product__c =p2.Id;
             insert (new List<Apttus_Proposal__Proposal_Line_Item__c>{lineitem,lineitem1}) ;


            AvalaraSchema.GetTaxRequest req =  model.OrderGenerateRequest(pOrder);
            req =  model.OrderGenerateRequest(pOrder1);

            //Custom setting for address
            AvalaraAddressInfo__c addressCustomSetting = new AvalaraAddressInfo__c(Name=  'United States',Address1__c  = 'Test1',Address2__c = 'Test2',Address3__c = 'Test3');
            addressCustomSetting.City__c = 'Abc';
            addressCustomSetting.CountryCode__c =  '01';
            addressCustomSetting.StateProvince__c = 'State';
            addressCustomSetting.ZIPPostalCode__c = '20202';
            insert addressCustomSetting;


            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator3());
            Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
            //Generating exception
            AvalaraSchema.GetTaxResponse resTax = model.GetTax(req);
            AvalaraSchema.Address addressResponse = new AvalaraSchema.Address();

            AvalaraModel.validateOrUpdateAddress(addressResponse,acc.Id);
            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{proposal.Id},AvalaraModel.QUOTE);
            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{proposal1.Id},AvalaraModel.QUOTE);
            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{pOrder1.Id},AvalaraModel.ORDER);
            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{pOrder.Id},AvalaraModel.ORDER);
            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{pOrder2.Id},AvalaraModel.ORDER);
            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{pOrder1.Id,pOrder.Id},AvalaraModel.ORDER);
            Test.stopTest();
        }

    }

    static testMethod void testGetTax4(){
        System.runAs(sysAdmin){
            createData();
            IntegrationConfig__c setting = new IntegrationConfig__c(Name = 'Avalara Integration', AvalaraClient__c = 'Monster Worldwide, Inc.',
                AvalaraCompanyCode__c = 'MWW', AvalaraCountry__c = 'MWW', EndpointName__c = 'AvalaraDev',IsPaypalTest__c = false,
                Password__c = '6NvqAGdhXM^y',Timeout__c = 60000,Username__c = 'jlescarbeau@appirio.com', PaypalRedirectURL__c = 'PaypalRedirectURL');
            IntegrationConfig__c setting1 = new IntegrationConfig__c(Name = 'ValidateAddress', AvalaraClient__c = 'Monster Worldwide, Inc.',
                AvalaraCompanyCode__c = 'MWW', AvalaraCountry__c = 'MWW', EndpointName__c = 'AvalaraDev',IsPaypalTest__c = false,
                Password__c = '6NvqAGdhXM^y',Timeout__c = 60000,Username__c = 'jlescarbeau@appirio.com', PaypalRedirectURL__c = 'PaypalRedirectURL');
            insert (new List<IntegrationConfig__c>{setting,setting1});
            AvalaraAddressInfo__c avalaraAddress = new AvalaraAddressInfo__c(Name = 'United States',Address1__c = 'Test',Address2__c = 'Test2',Address3__c = 'Test3',City__c = 'Boston', CountryCode__c = '01' , ZIPPostalCode__c = '30202');
            insert avalaraAddress;
            WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c(Name = 'AvalaraDev', Endpoint__c = 'https://development.avalara.net/1.0/tax/get');
            WebServiceEndpoint__c endpoint2 = new WebServiceEndpoint__c(Name = 'PaypalRedirectURL', Endpoint__c = 'https://payflowlink.paypal.com');
            insert new List<WebServiceEndpoint__c>{endpoint, endpoint2};
            AvalaraModel model = new AvalaraModel(reqHeader);
            Account acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TESTACCCCH1 ');
            acc.ShippingCountryCode = 'IN';
            acc.ShippingCountry = 'India';
            acc.ShippingState = '';
            Account acc1 = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TESTACCCCH ');
            insert (new List<Account>{acc,acc1});
            Contact con = TestDataSetupUtility.createTestContact(acc.Id, 'confirst1', 'conlast1', 'con1@email.com');
            insert con;
            Order__c pOrder = TestDataSetupUtility.createOrder(acc.Id, con.Id);
            pOrder.QuoteProposal__c = proposal.Id;
            pOrder.Organization__c = 'North America';
            pOrder.Pricing_Channel__c = 'Agency';
            Contact con2 = TestDataSetupUtility.createTestContact(acc.Id, 'confirst1', 'conlast1', 'con1@email.com');
            insert con2;
            Product2 p2 = TestDataSetupUtility.createTestProduct2('Test Product');
            p2.ProductCode = 'BUNDLE';
            insert p2;
            Order__c pOrder1 = TestDataSetupUtility.createOrder(acc1.Id, con2.Id);
            pOrder1.QuoteProposal__c = proposal.Id;
            Order__c pOrder2 = TestDataSetupUtility.createOrder(acc.Id, con.Id);
            pOrder2.Organization__c = 'Europe';
            pOrder2.Pricing_Channel__c = 'Agency';

            pOrder.recordTypeId = rtCredit;
            pOrder1.recordTypeId = rtRebill;
            insert (new List<Order__c>{pOrder,pOrder1,pOrder2});
            orderLine = TestDataSetupUtility.createOrderLineItem(pOrder1.id);
            orderLine.Product__c = p2.Id;
            orderLine1 = TestDataSetupUtility.createOrderLineItem(pOrder.id);
            orderLine1.Product__c = p2.Id;
            orderLine1.LineType__c = 'Option';
            orderLine2 = TestDataSetupUtility.createOrderLineItem(pOrder2.id);
            orderLine2.Product__c = p2.Id;
            insert (new List<Order_Line_Item__c>{orderLine,orderLine1,orderLine2});

             lineitem = TestDataSetupUtility.createProposalLineItem(proposal.Id);
            lineitem.Apttus_QPConfig__OptionPrice__c = null;
             lineitem.Apttus_QPConfig__LineStatus__c = 'New';
             lineitem.APTS_Is_Agency_Commission_Different__c = 1;
             lineitem.Apttus_QPConfig__NetPrice__c = 10000;
              lineitem.APTS_Extended_List_Price__c= 100;
              lineitem.Apttus_QPConfig__BaseExtendedPrice__c = 1;


               lineitem1 = TestDataSetupUtility.createProposalLineItem(proposal1.Id);
             lineitem1.Apttus_QPConfig__OptionPrice__c = null;
             lineitem1.Apttus_QPConfig__LineStatus__c = 'New';
             lineitem1.APTS_Is_Agency_Commission_Different__c = 1;
             lineitem1.Apttus_QPConfig__NetPrice__c = 10000;
             lineitem1.APTS_Extended_List_Price__c= 100;
             lineitem1.Apttus_QPConfig__BaseExtendedPrice__c = 1;
             insert (new List<Apttus_Proposal__Proposal_Line_Item__c>{lineitem,lineitem1}) ;


            AvalaraSchema.GetTaxRequest req =  model.OrderGenerateRequest(pOrder);
            req =  model.OrderGenerateRequest(pOrder1);

            //Custom setting for address
            AvalaraAddressInfo__c addressCustomSetting = new AvalaraAddressInfo__c(Name=  'United States',Address1__c  = 'Test1',Address2__c = 'Test2',Address3__c = 'Test3');
            addressCustomSetting.City__c = 'Abc';
            addressCustomSetting.CountryCode__c =  '01';
            addressCustomSetting.StateProvince__c = 'State';
            addressCustomSetting.ZIPPostalCode__c = '20202';
            insert addressCustomSetting;


            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());
            Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
            //Generating exception
            AvalaraSchema.GetTaxResponse resTax = model.GetTax(req);
            AvalaraSchema.Address addressResponse = new AvalaraSchema.Address();

            AvalaraModel.validateOrUpdateAddress(addressResponse,acc.Id);
            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{proposal.Id},AvalaraModel.QUOTE);
            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{proposal.Id,proposal1.Id},AvalaraModel.QUOTE);
            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{pOrder1.Id},AvalaraModel.ORDER);
            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{pOrder.Id},AvalaraModel.ORDER);
            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{pOrder2.Id},AvalaraModel.ORDER);
            AvalaraModel.AsyncTaxRateProcessing(new Set<Id>{pOrder1.Id,pOrder.Id},AvalaraModel.ORDER);
            Test.stopTest();
        }

    }
    static void createData(){
        try {
            Account businessAccount = TestDataSetupUtility.createTestAccountWithShippingAndBilling('businessAccountId');
            businessAccount.Organization__c = 'Europe';
            insert businessAccount;

            Opportunity opp = TestDataSetupUtility.createTestOpportunity('oppNamtest', businessAccount.Id);

            //Id opportunityId = getRecordTypeId('Opportunity','Opportunity');
            //Opportunity opp = createTestOpportunity(businessAccount.Id, opportunityId, true);

            proposal = TestDataSetupUtility.createApttusProposal(opp);

            proposal.Apttus_Proposal__Proposal_Name__c = 'Owens Corning Test';
            proposal.Apttus_Proposal__Opportunity__c = opp.Id;
            proposal.Apttus_Proposal__Account__c = businessAccount.Id;
            proposal.Language__c = 'IN English';
            proposal.Selling_Country__c = 'United States';
            proposal.BillingStreet__c = '2222 W Bella Vista St';
            proposal.BillingCity__c = 'Lakeland';
            proposal.BillingStateProvince__c = 'Florida' ;
            proposal.BillingCountry__c = 'United States';
            proposal.BillingZipPostalCode__c = '33810-0601';
            proposal.BillingAccount__c = businessAccount.Id;

            proposal1 = TestDataSetupUtility.createApttusProposal(opp);
            proposal1.Apttus_Proposal__Proposal_Name__c = 'Owens Corning Test1';
            proposal1.Apttus_Proposal__Opportunity__c = opp.Id;
            proposal1.Apttus_Proposal__Account__c = businessAccount.Id;
            proposal1.Language__c = 'IN English';
            proposal1.Selling_Country__c = 'United States';
            proposal1.BillingStreet__c = '2222 W Bella Vista St';
            proposal1.BillingCity__c = 'Lakeland';
            proposal1.BillingStateProvince__c = 'Florida' ;
            proposal1.BillingCountry__c = 'United States';
            proposal1.BillingZipPostalCode__c = '33810-0601';
            proposal1.APTS_Quote_Type__c = 'Agency';
            proposal1.Agency__c = proposal.Id;
           //   Proposal.Apttus_Proposal__Account__r.Organization__c = 'Europe';

            insert (new List<Apttus_Proposal__Proposal__c>{proposal,proposal1});




            reqHeader = new AvalaraSchema.RequestHeader();
            reqHeader.Username = 'test@gmail.com';
            reqHeader.Password = '1234';
            reqHeader.Client = '123';
            reqHeader.CompanyCode = '1234';
        }catch(Exception e){
            System.assert(false, 'Error in creating data in AvalaraModel_Tests'+e.getMessage());
        }
    }

     /*private static User createUser(String profileName, Boolean isInsert){
        User testUser = new User();
        Profile p;
        List<Profile> listProfile = [SELECT Id from Profile where Name = :profileName];
        if(listProfile.size() > 0) {
            p = listProfile[0];
        } else {
            return null;
        }
        testUser = new User(alias = 'AdmUsr', email='standarduser' + Math.random()  + '@testorg.com',
                                    emailencodingkey='UTF-8',  lastname='Test', languagelocalekey='en_US',
                                    localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles',
                                    username='teststandarduser' + Math.random() + '@testorg.com', IsActive=true,
                                    CompanyName = 'test Company');
        if(isInsert){
            insert testUser;
        }
        return testUser;
    }
     private static Id getRecordTypeId(String recTypeName, String sObjectName) {
        if (!mapSobjectDescribe.containsKey(sObjectName)) {
            Schema.DescribeSObjectResult sobjectDescribe = GLOBAL_MAP.get(sObjectName).getDescribe();
            mapSobjectDescribe.put(sObjectName, sobjectDescribe);
        }
        Schema.DescribeSObjectResult DescribeSObjectResultObj = mapSobjectDescribe.get(sObjectName);
        Map < String, Schema.RecordTypeInfo > rtMapByName = DescribeSObjectResultObj.getRecordTypeInfosByName();
        Id recordTypeId = rtMapByName != null && rtMapByName.containsKey(recTypeName) ? rtMapByName.get(recTypeName).getRecordTypeId() : null;
        return recordTypeId;
    }

     public static Opportunity createTestOpportunity (Id accId, Id recordTypeId, Boolean isInsert) {
        Opportunity opportunity = new Opportunity ();
        opportunity.AccountId = accId;
        opportunity.Name = 'Test'+Math.random();
        opportunity.CloseDate= Date.today()+30;
        opportunity.StageName='Targeting';
        //opportunity.CurrencyIsoCode='USD - U.S. Dollar';
        opportunity.RecordTypeId = recordTypeId;
        if(isInsert) {
          insert opportunity ;
        }
        return opportunity ;
    }
     public static Account createTestAccount(Id recordTypeId, Boolean isInsert) {

        Account account = new Account();
        account.Name = 'TestAcc' + Math.random();
        account.ShippingStreet      = '1 Main St.';
        account.ShippingState       = 'Alaska';
        account.ShippingPostalCode  = '12345';
        account.ShippingCountry     = 'United States';
        account.ShippingCity            = 'Anytown';
        account.Description         = 'This is a test account';
        account.BillingStreet       = '1 Main St.';
        account.BillingState            = 'Alaska';
        account.BillingPostalCode   = '12345';
        account.BillingCountry      = 'United States';
        account.BillingCity         = 'Anytown';
        account.AnnualRevenue       = 10000;
        account.ParentId                = null;
        account.RecordTypeId = recordTypeId;

        if(isInsert) {
          insert account;
        }
        return account;
    }*/

    public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {

            // Create a fake response
            HttpResponse res = new HttpResponse();

            res = new HttpResponse();
            res.setHeader('Content-type', 'application/json');
            AvalaraSchema.GetTaxResponse response = new AvalaraSchema.GetTaxResponse();
            AvalaraSchema.Message msg = new AvalaraSchema.Message();
            msg.Name = 'Test';
            AvalaraSchema.TaxDetail taxDetail1 = new AvalaraSchema.TaxDetail();
            taxDetail1.Country = 'United States';
            AvalaraSchema.TaxDetail taxDetail2 = new AvalaraSchema.TaxDetail();
            taxDetail2.Country = 'India';
            taxDetail2.JurisType = AvalaraSchema.JURIS_TYPE_SPECIAL;
            AvalaraSchema.TaxLine taxLine1 = new AvalaraSchema.TaxLine();
            Order_Line_Item__c oli = [SELECT Id,Name FROM Order_Line_Item__c LIMIT 1];
            taxLine1.LineNo = oli.Name;
            AvalaraSchema.TaxAddress  taxAddress = new AvalaraSchema.TaxAddress();
            taxAddress.AddressCode = 'Shipping';
            response.Messages = new List<AvalaraSchema.Message>{msg};
            response.TaxSummary = new List<AvalaraSchema.TaxDetail>{taxDetail1,taxDetail2};
            response.TaxLines = new List<AvalaraSchema.TaxLine>{taxLine1};
            response.TaxAddresses = new List<AvalaraSchema.TaxAddress>{taxAddress};
            res.setBody(JSON.serialize(response));

            res.setStatusCode(200);
            return res;
        }
    }

   public class MockHttpResponseGenerator1 implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {

            // Create a fake response
            HttpResponse res = new HttpResponse();

            res.setHeader('Content-type', 'application/json');
            String responseString = '{"Test":{"status":"success"}}';
            res.setBody(responseString);

            res.setStatusCode(404);
            res.setStatusCode(404);
            return res;
        }
    }

    public class MockHttpResponseGenerator2 implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {

            // Create a fake response
            HttpResponse res = new HttpResponse();

            res.setHeader('Content-type', 'application/json');

            String responseString = '{"Test":{"status":"success"}}';
            res.setBody(responseString);

            res.setStatusCode(500);
            return res;
        }
    }


    public class MockHttpResponseGenerator3 implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {

             // Create a fake response
            HttpResponse res = new HttpResponse();

            res = new HttpResponse();
            res.setHeader('Content-type', 'application/json');
            AvalaraSchema.GetTaxResponse response = new AvalaraSchema.GetTaxResponse();
            AvalaraSchema.Message msg = new AvalaraSchema.Message();
            msg.Name = 'Test';
            AvalaraSchema.TaxDetail taxDetail1 = new AvalaraSchema.TaxDetail();
            taxDetail1.Country = 'United States';
            taxDetail1.Rate = 10;
            AvalaraSchema.TaxDetail taxDetail2 = new AvalaraSchema.TaxDetail();
            taxDetail2.Rate = 10;
            taxDetail2.Country = 'India';
            taxDetail2.JurisType = AvalaraSchema.JURIS_TYPE_SPECIAL;
            AvalaraSchema.TaxLine taxLine1 = new AvalaraSchema.TaxLine();
            AvalaraSchema.TaxLine taxLine2 = new AvalaraSchema.TaxLine();
            AvalaraSchema.TaxLine taxLine3 = new AvalaraSchema.TaxLine();
            Order_Line_Item__c oli = [SELECT Id,Name FROM Order_Line_Item__c LIMIT 1];
            taxLine1.Taxable= 10;
            Apttus_Proposal__Proposal_Line_Item__c pli = [SELECT Id,Name FROM Apttus_Proposal__Proposal_Line_Item__c LIMIT 1];
            if(pli != null)
                taxLine1.LineNo = pli.Name;
            taxLine2.LineNo = oli.Name;
            taxLine2.Taxable= 10;
            taxLine3.LineNo = oli.Name;
            taxLine3.Taxable= 10;
            AvalaraSchema.TaxAddress  taxAddress = new AvalaraSchema.TaxAddress();
            taxAddress.AddressCode = 'Shipping';
            taxAddress.Address = 'Shipping';
            response.Messages = new List<AvalaraSchema.Message>{msg};
            response.TaxSummary = new List<AvalaraSchema.TaxDetail>{taxDetail1,taxDetail2};
            response.TaxLines = new List<AvalaraSchema.TaxLine>{taxLine1,taxLine2,taxLine3};
            response.TaxAddresses = new List<AvalaraSchema.TaxAddress>{taxAddress};
            res.setBody(JSON.serialize(response));

            res.setStatusCode(200);
            return res;
        }
    }


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

           v3_monsterBizappsSiterouterSiterouterws.GetMultipleLicenseAndRelativesResp_element responseElement = new v3_monsterBizappsSiterouterSiterouterws.GetMultipleLicenseAndRelativesResp_element();
           v3_monsterBizappsSiterouterSiterouterws.ArrayOfGetLicenseAndRelativesResp elem1 = new v3_monsterBizappsSiterouterSiterouterws.ArrayOfGetLicenseAndRelativesResp();
           responseElement.GetLicenseAndRelativesResponses = elem1;

            response.put('response_x', responseElement);
        }
    }
    
    
    
    
    static void createData_New(){
		reqHeader = new AvalaraSchema.RequestHeader();
		reqHeader.Username = 'test@gmail.com';
    	reqHeader.Password = '1234';
    	reqHeader.Client = '123';
    	reqHeader.CompanyCode = '1234';   


    	/*Account acc  = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');

		insert acc;

		Opportunity opp = TestDataSetupUtility.createTestOpportunity('TestOpp' , acc.Id);

		insert opp;
		
        Account billingAcc  = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Billing Account');
		insert billingAcc;
       
		Apttus_Proposal__Proposal__c proposal = TestDataSetupUtility.createProposal(opp.Id);
		Contact c=TestDataSetupUtility.createTestContact(billingAcc.Id,'test1','test1', 'sample1@gmail.com');
		insert c;
		Contact c1=TestDataSetupUtility.createTestContact(acc.Id,'test2','test2', 'sample2@gmail.com');
		insert c1;
		proposal.Apttus_QPConfig__PriceListId__c=aptusConfigPriceList.Id;
		proposal.BillingAccount__c = billingAcc.Id;
		proposal.BillContact__c = c.Id;
		proposal.Apttus_Proposal__Account__c=acc.Id;
		proposal.PostingContact__c = c1.Id;

		insert proposal;*/

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
		
		Apttus_Config2__PriceList__c aptusConfigPriceList = TestDataSetupUtility.createPriceList('TestPrice',true);
		
		List<Product2> productList = new List<Product2>();
		productList.add(TestDataSetupUtility.createProduct('Test Product' ,  false));
		productList.add(TestDataSetupUtility.createProduct('Test Product2' ,  false));
		productList.add(TestDataSetupUtility.createProduct('Test Product3' ,  false));
		productList.add(TestDataSetupUtility.createProduct('Test Product4' ,  false));
		productList[0].Apttus_Config2__ConfigurationType__c = 'Bundle';
		productList[1].Apttus_Config2__ConfigurationType__c = 'Bundle';
	    productList[2].Apttus_Config2__ConfigurationType__c = 'Bundle';
	    productList[3].Apttus_Config2__ConfigurationType__c = 'Standalone';
		insert productList;

        List<Apttus_Config2__PriceListItem__c> pliList=new list<Apttus_Config2__PriceListItem__c>();
		Apttus_Config2__PriceListItem__c pli_1=new Apttus_Config2__PriceListItem__c(Apttus_Config2__Active__c=true,Apttus_Config2__PriceListId__c=aptusConfigPriceList.Id,Apttus_Config2__ProductId__c=productList[0].Id);
		Apttus_Config2__PriceListItem__c pli_2=new Apttus_Config2__PriceListItem__c(Apttus_Config2__Active__c=true,Apttus_Config2__PriceListId__c=aptusConfigPriceList.Id,Apttus_Config2__ProductId__c=productList[1].Id);
		Apttus_Config2__PriceListItem__c pli_3=new Apttus_Config2__PriceListItem__c(Apttus_Config2__Active__c=true,Apttus_Config2__PriceListId__c=aptusConfigPriceList.Id,Apttus_Config2__ProductId__c=productList[2].Id);
        Apttus_Config2__PriceListItem__c pli_4=new Apttus_Config2__PriceListItem__c(Apttus_Config2__Active__c=true,Apttus_Config2__PriceListId__c=aptusConfigPriceList.Id,Apttus_Config2__ProductId__c=productList[3].Id);

		pliList.add(pli_1);
		pliList.add(pli_2);
		pliList.add(pli_3);
		pliList.add(pli_4);
		insert pliList;
		aptusConfig = TestDataSetupUtility.createTestProductConfig(proList[0] , accountList[0] , aptusConfigPriceList);
		aptusConfig.Apttus_Config2__Status__c = 'Finalized';
		insert aptusConfig;

		
		Apttus_Config2__ClassificationName__c categorySample=new Apttus_Config2__ClassificationName__c(Name='sample category',Apttus_Config2__HierarchyLabel__c='sample category',Apttus_Config2__Active__c = true,Apttus_Config2__Type__c='Option Group');
        insert categorySample;
        Apttus_Config2__ClassificationHierarchy__c catHierarchy=new Apttus_Config2__ClassificationHierarchy__c(Name = 'catHierarchyName', Apttus_Config2__Label__c = 'catHierarchyName',Apttus_Config2__HierarchyId__c = categorySample.Id);
        insert catHierarchy;
        Apttus_Config2__ProductOptionGroup__c optionGrp =new Apttus_Config2__ProductOptionGroup__c(Apttus_Config2__OptionGroupId__c = catHierarchy.Id,
        Apttus_Config2__ProductId__c =  productList[2].id, Apttus_Config2__Sequence__c = 1, Apttus_Config2__MinOptions__c = 1,Apttus_Config2__MaxOptions__c = 100);
        insert optionGrp;
        Apttus_Config2__ProductOptionComponent__c prodOptComponent=new Apttus_Config2__ProductOptionComponent__c(Apttus_Config2__ProductOptionGroupId__c = optionGrp.Id,Apttus_Config2__MinQuantity__c = 0,Apttus_Config2__MaxQuantity__c = 25,Apttus_Config2__RelationshipType__c = 'Option',  Apttus_Config2__Sequence__c = 1,Apttus_Config2__ComponentProductId__c =  productList[3].id);
		insert prodOptComponent;
		
		
		
		Apttus_Config2__ProductOptionGroup__c optionGrp1 =new Apttus_Config2__ProductOptionGroup__c(Apttus_Config2__OptionGroupId__c = catHierarchy.Id,
        Apttus_Config2__ProductId__c =  productList[1].id, Apttus_Config2__Sequence__c = 1, Apttus_Config2__MinOptions__c = 1,Apttus_Config2__MaxOptions__c = 100);
        insert optionGrp1;
        Apttus_Config2__ProductOptionComponent__c prodOptComponent1=new Apttus_Config2__ProductOptionComponent__c(Apttus_Config2__ProductOptionGroupId__c = optionGrp1.Id,Apttus_Config2__MinQuantity__c = 0,Apttus_Config2__MaxQuantity__c = 25,Apttus_Config2__RelationshipType__c = 'Option',  Apttus_Config2__Sequence__c = 1,Apttus_Config2__ComponentProductId__c =  productList[3].id);
		insert prodOptComponent1;
		
		
        Apttus_Config2__ProductOptionGroup__c optionGrp2 =new Apttus_Config2__ProductOptionGroup__c(Apttus_Config2__OptionGroupId__c = catHierarchy.Id,
        Apttus_Config2__ProductId__c =  productList[0].id, Apttus_Config2__Sequence__c = 1, Apttus_Config2__MinOptions__c = 1,Apttus_Config2__MaxOptions__c = 100);
        insert optionGrp2;
        Apttus_Config2__ProductOptionComponent__c prodOptComponent2=new Apttus_Config2__ProductOptionComponent__c(Apttus_Config2__ProductOptionGroupId__c = optionGrp1.Id,Apttus_Config2__MinQuantity__c = 0,Apttus_Config2__MaxQuantity__c = 25,Apttus_Config2__RelationshipType__c = 'Option',  Apttus_Config2__Sequence__c = 1,Apttus_Config2__ComponentProductId__c =  productList[1].id);
		insert prodOptComponent2;

        Product2 p2 = TestDataSetupUtility.createTestProduct2('Test Product');
        p2.ProductCode = 'QUOTE BUNDLE';
        
        Product2 p3 = TestDataSetupUtility.createTestProduct2('Test Product2');
        p3.ProductCode = 'QUOTE BUNDLE';
        
        Product2 p4 = TestDataSetupUtility.createTestProduct2('Test Product3');
        p4.ProductCode = 'QUOTE BUNDLE';
        insert new List<Product2>{p2,p3,p4};
        
		aptusLineItemList = new List<Apttus_Config2__LineItem__c>();
		aptusLineItem1= TestDataSetupUtility.createLineItemApttus(aptusConfig.Id);
		aptusLineItem1.Select__c = true;
		aptusLineItem1.Apttus_Config2__ProductId__c = productList[0].Id;
		aptusLineItem1.Apttus_Config2__StartDate__c = Date.today();
		aptusLineItem1.Apttus_Config2__EndDate__c = Date.today();
		aptusLineItem1.Apttus_Config2__IsPrimaryLine__c = true;
		aptusLineItem1.Apttus_Config2__LineType__c='Product/Service';
		aptusLineItem1.Apttus_Config2__HasOptions__c= true;
		aptusLineItem1.Apttus_Config2__LineNumber__c = 1;
		aptusLineItem1.Apttus_Config2__PriceListId__c=aptusConfigPriceList.Id;
		aptusLineItem1.Apttus_Config2__PriceListItemId__c=pliList[0].Id;
		aptusLineItem1.Apttus_Config2__ClassificationId__c=catHierarchy.Id;
		aptusLineItem1.Apttus_Config2__ProductOptionId__c=prodOptComponent2.Id;
		aptusLineItem1.Apttus_Config2__ProductId__c = p2.id;
		aptusLineItemList.add(aptusLineItem1);

		aptusLineItem2= TestDataSetupUtility.createLineItemApttus(aptusConfig.Id);
		aptusLineItem2.Select__c = true;
		aptusLineItem2.Apttus_Config2__ProductId__c = productList[1].Id;
		aptusLineItem2.Apttus_Config2__EndDate__c = Date.today();
		aptusLineItem2.Apttus_Config2__StartDate__c = Date.today();
		aptusLineItem2.Apttus_Config2__IsPrimaryLine__c = true;
		aptusLineItem2.Apttus_Config2__HasOptions__c= true;
		aptusLineItem2.Apttus_Config2__LineType__c='Product/Service';
		aptusLineItem2.Apttus_Config2__LineNumber__c = 2;
		aptusLineItem2.Apttus_Config2__PriceListId__c=aptusConfigPriceList.Id;
		aptusLineItem2.Apttus_Config2__PriceListItemId__c=pliList[1].Id;
		aptusLineItem2.Apttus_Config2__ClassificationId__c=catHierarchy.Id;
		aptusLineItem2.Apttus_Config2__ProductOptionId__c=prodOptComponent1.Id;
		aptusLineItem2.Apttus_Config2__ProductId__c = p3.id;
		aptusLineItemList.add(aptusLineItem2);

		aptusLineItem3= TestDataSetupUtility.createLineItemApttus(aptusConfig.Id);
		aptusLineItem3.Select__c = true;
		aptusLineItem3.Apttus_Config2__ProductId__c = productList[2].Id;
		aptusLineItem3.Apttus_Config2__StartDate__c = Date.today();
		aptusLineItem3.Apttus_Config2__IsPrimaryLine__c = true;
		aptusLineItem3.Apttus_Config2__StartDate__c = Date.today();
		aptusLineItem3.Apttus_Config2__LineNumber__c = 3;
		aptusLineItem3.Apttus_Config2__PriceListId__c=aptusConfigPriceList.Id;
		aptusLineItem3.Apttus_Config2__PriceListItemId__c=pliList[2].Id;
		aptusLineItem3.Apttus_Config2__ClassificationId__c=catHierarchy.Id;
		aptusLineItem3.Apttus_Config2__ProductOptionId__c=prodOptComponent.Id;
		aptusLineItem3.Apttus_Config2__LineType__c='Product/Service';
		aptusLineItem3.Apttus_Config2__HasOptions__c= true;
		aptusLineItem3.Apttus_Config2__ProductId__c = p4.id;
		aptusLineItemList.add(aptusLineItem3);
	
		insert aptusLineItemList;
		
	}
}