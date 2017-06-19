/***************************************************************************************************************************
 * Class Name   : LicenseViewCC_Test
 * Created By   : Rohit B. (Appirio)
 * Class Purpose: Test class of LicenseViewCC class
 * Created Date : July 21, 2015
 *
 * Class Date Modified          Modified By                     Description of the update
 * [Date]                       [Person Name]                   [Short description of modification]
****************************************************************************************************************************/
@isTest
private class LicenseViewCC_Test {
    static Order__c  order1;
    static Order_Line_Item__c orderLineItem,orderLineItem1;
    static LicenseID__c licenseId1,licenseId2,licenseId3,licenseId4;
    static Account acc;
    static Opportunity opp;
    static Xcode__c xcode;
    @isTest
    static void test_method() {

        User usrTest = [Select Id from User where Profile.Name =: 'System Administrator' and isActive = true limit 1];
        system.runAs(usrTest) {

            setupData();

            PageReference pageRef = Page.LicenseView;
            Test.setCurrentPage(pageRef);

            Test.startTest();
            	Test.setMock(WebServiceMock.class, new WebServiceMockImpl());

                ApexPages.CurrentPage().getParameters().put('AccountID', acc.Id);
                ApexPages.currentpage().getParameters().put('SelectedXcodeId',xcode.Id);
                LicenseViewCC obj = new LicenseViewCC();

                obj.getLicenses('testing', null);
                obj.getLicenses('InventoryView', 'MWW');

                obj.getLicenses('ResumeUsageView', 'xyz');
                obj.getLicenses('EnhancementsView', 'Appirio');
                System.assert(obj.getPageOptions() != null);
                System.assert(obj.getViews() != null);
                PageReference pg1 = obj.Back();
                System.assert(pg1.getUrl().contains(acc.Id));
                obj.selectXCode();
                obj.NewPage = '1';
                obj.LicenseView = 'InventoryView';
                obj.ChangePage();
                obj.NewPage = '1';
                obj.LicenseView = 'EnhancementsView';
                obj.ChangePage();
                obj.NewPage = '1';
                obj.LicenseView = 'ResumeUsageView';
                obj.ChangePage();
                obj.changeview();
                obj.SelectXcode();


           /*
            PrevSelectedXcodeId = Id.valueOf(SelectedXcodeId);
            XcodeWrap xw = XcodeWrapMap.get(PrevSelectedXcodeId);
             public String pXcode = xw.xcodeAccount.Xcode__r.Name;
                v3_schemasDatacontractOrg200407Monster.GetCompanyLicenseInfoRequest req = new v3_schemasDatacontractOrg200407Monster.GetCompanyLicenseInfoRequest();
             CSW_schemasMicrosoftCom200310Serializat.ArrayOfint intAr = new CSW_schemasMicrosoftCom200310Serializat.ArrayOfint();
            req.ACLIDs = intAr;
      req.ChannelID = 58;
      req.CompanyXCode = pXcode;
              v3_schemasDatacontractOrg200407Monster.ArrayOfLicenseInfo res = con.GetCompanyLicenseInfo(req, viewType);
      */
            Test.stopTest();
        } // END system.runAs(usrTest) {
    } // END static void test_method_one() {

	@isTest
    static void test_method2() {

        User usrTest = [Select Id from User where Profile.Name =: 'System Administrator' and isActive = true limit 1];
        system.runAs(usrTest) {

            setupData();
            Credit_Request__c cr1 = TestDataSetupUtility.createCreditRequest(order1.Id);
	        cr1.Credit_Type__c = 'Full';
	        Credit_Request__c cr2 = TestDataSetupUtility.createCreditRequest(order1.Id);
	        cr2.Credit_Type__c = 'Partial';
	        insert (new List<Credit_Request__c>{cr1,cr2});

            PageReference pageRef = Page.LicenseView;
            Test.setCurrentPage(pageRef);

            Test.startTest();
            	Test.setMock(WebServiceMock.class, new WebServiceMockImpl());

                ApexPages.CurrentPage().getParameters().put('AccountID', acc.Id);
                ApexPages.currentpage().getParameters().put('SelectedXcodeId',xcode.Id);
                LicenseViewCC obj = new LicenseViewCC();

                obj.getLicenses('testing', null);
                obj.getLicenses('InventoryView', 'MWW');

                obj.getLicenses('ResumeUsageView', 'xyz');
                obj.getLicenses('EnhancementsView', 'Appirio');
                System.assert(obj.getPageOptions() != null);
                System.assert(obj.getViews() != null);
                PageReference pg1 = obj.Back();
                System.assert(pg1.getUrl().contains(acc.Id));
                obj.selectXCode();
                obj.NewPage = '1';
                obj.LicenseView = 'InventoryView';
                obj.ChangePage();
                obj.LicenseView = 'EnhancementsView';
                obj.ChangePage();
                obj.LicenseView = 'ResumeUsageView';
                obj.ChangePage();
                obj.changeview();
                obj.SelectXcode();


           /*
            PrevSelectedXcodeId = Id.valueOf(SelectedXcodeId);
            XcodeWrap xw = XcodeWrapMap.get(PrevSelectedXcodeId);
             public String pXcode = xw.xcodeAccount.Xcode__r.Name;
                v3_schemasDatacontractOrg200407Monster.GetCompanyLicenseInfoRequest req = new v3_schemasDatacontractOrg200407Monster.GetCompanyLicenseInfoRequest();
             CSW_schemasMicrosoftCom200310Serializat.ArrayOfint intAr = new CSW_schemasMicrosoftCom200310Serializat.ArrayOfint();
            req.ACLIDs = intAr;
      req.ChannelID = 58;
      req.CompanyXCode = pXcode;
              v3_schemasDatacontractOrg200407Monster.ArrayOfLicenseInfo res = con.GetCompanyLicenseInfo(req, viewType);
      */
            Test.stopTest();
        } // END system.runAs(usrTest) {
    } // END static void test_method_one() {


    static void setupData() {
        List<IntegrationConfig__c> lstIC = new List<IntegrationConfig__c>();
        IntegrationConfig__c ic1 = new IntegrationConfig__c(
            Name = 'Avalara Integration',
            AvalaraClient__c = 'Monster Worldwide, Inc.',
            AvalaraCompanyCode__c = 'MWW',
            EndpointName__c = 'AvalaraDev',
            IsPaypalTest__c = false,
            Timeout__c = 60000,
            Username__c = 'jlescarbeau@appirio.com',
            Password__c = '6NvqAGdhXM^y',
            USPSUserID__c = '',
            AvalaraCountry__c = '',
            PaypalPartner__c = '',
            PaypalVendor__c = '',
            PaypalRedirectURL__c = ''
        );
        lstIC.add(ic1);
        IntegrationConfig__c ic2 = new IntegrationConfig__c(
            Name = 'Paypal Payflow',
            AvalaraClient__c = '',
            AvalaraCompanyCode__c = '',
            EndpointName__c = 'Payflow-pilot',
            IsPaypalTest__c = true,
            PaypalRedirectURL__c = 'PaypalRedirectURL',
            Timeout__c = 120000,
            PaypalVendor__c = 'monsterv3',
            PaypalPartner__c = 'monster',
            Username__c = 'salesforceadmin',
            Password__c = 'monster8',
            USPSUserID__c = '',
            AvalaraCountry__c = ''
        );
        lstIC.add(ic2);
        IntegrationConfig__c ic3 = new IntegrationConfig__c(
            Name = 'Site Integration',
            AvalaraClient__c = '',
            AvalaraCompanyCode__c = '',
            EndpointName__c = 'MonsterBizAppsSiteRouter',
            IsPaypalTest__c = false,
            Timeout__c = 120000,
            Username__c = '',
            Password__c = '',
            PaypalRedirectURL__c = '',
            PaypalVendor__c = '',
            PaypalPartner__c = '',
            USPSUserID__c = '',
            AvalaraCountry__c = ''
        );
        lstIC.add(ic3);
        IntegrationConfig__c ic4 = new IntegrationConfig__c(
            Name = 'USPS Integration',
            AvalaraClient__c = '',
            AvalaraCompanyCode__c = '',
            EndpointName__c = 'USPSAddressValidation',
            IsPaypalTest__c = false,
            Timeout__c = 60000,
            USPSUserID__c = '562CLOUD2615',
            Username__c = '',
            Password__c = '',
            PaypalRedirectURL__c = '',
            PaypalVendor__c = '',
            PaypalPartner__c = '',
            AvalaraCountry__c = ''
        );
        lstIC.add(ic4);

        insert lstIC;

        List<WebServiceEndpoint__c> lstWSE = new List<WebServiceEndpoint__c>();
        lstWSE.add(new WebServiceEndpoint__c(Name = 'AvalaraDev', Endpoint__c = 'https://development.avalara.net/1.0/tax/get'));
        lstWSE.add(new WebServiceEndpoint__c(Name = 'BoozDummyEndpoint', Endpoint__c = 'http://requestb.in/15jd6cg1'));
        lstWSE.add(new WebServiceEndpoint__c(Name = 'GoogleMapsService', Endpoint__c = 'https://maps.googleapis.com/maps/api/geocode/json?key=AIzaSyD_tM-VWyaiAL0o8vYpXSepR1TIbBYYkoE'));
        lstWSE.add(new WebServiceEndpoint__c(Name = 'MonsterBizAppsSiteRouter', Endpoint__c = 'http://devcrmservice.bizapps.monster.com:1087/Monster.BizApps.SiteRouter/SiteRouterService.svc/legacy'));
        lstWSE.add(new WebServiceEndpoint__c(Name = 'MonsterBizAppsSiteRouterQA', Endpoint__c = 'http://uatcrmservice.bizapps.monster.com:1087/Monster.BizApps.SiteRouter/SiteRouterService.svc/legacy'));
        lstWSE.add(new WebServiceEndpoint__c(Name = 'Payflow-pilot', Endpoint__c = 'https://pilot-payflowpro.paypal.com/'));
        lstWSE.add(new WebServiceEndpoint__c(Name = 'PaypalRedirectURL', Endpoint__c = 'https://payflowlink.paypal.com'));
        lstWSE.add(new WebServiceEndpoint__c(Name = 'USPSAddressValidation', Endpoint__c = 'http://production.shippingapis.com/ShippingAPI.dll'));
        insert lstWSE;


        acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TESTACCCCH1 ');
        insert (new List<Account>{acc});

        xcode = new Xcode__c();
        xcode.name = 'test1';
        insert xcode ;

        XcodeAccount__c xAcc = new XcodeAccount__c ();
        xAcc.Xcode__c = xcode.Id;
        xAcc.Account__c = acc .Id;
        insert xAcc;

        Contact con = TestDataSetupUtility.createTestContact(acc.Id, 'PrimaryBillingTestLastnameOne', 'PrimaryBillingTestFirstnameOne', 'email1@testContact.com');
        con.PrimaryBillingContact__c = true;
        insert con;
        Id oppRT =  Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'Lead');
        opp = TestDataSetupUtility.createTestOpportunity('test',acc.Id);
        opp.InternationalDeal__c = true;
        opp.recordTypeId = oppRT;
        insert opp;
        Id CreditOrderRecordType = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Credit');

        order1 = TestDataSetupUtility.createOrder(acc.Id, con.Id);
        order1.OrderStatus__c = 'Sent To Verification';
        order1.RecordTypeId = CreditOrderRecordType;
        order1.Opportunity__c = opp.Id;
        order1.BillingAccount__c = acc.id;
        order1.ShippingAccount__c = acc.id;
        order1.BillingContact__c = con.id;
        order1.Posting_Contact__c = con.id;
        insert order1;
        /*
        Credit_Request__c cr1 = TestDataSetupUtility.createCreditRequest(order1.Id);
        cr1.Credit_Type__c = 'Full';
        Credit_Request__c cr2 = TestDataSetupUtility.createCreditRequest(order1.Id);
        cr2.Credit_Type__c = 'Partial';
        insert (new List<Credit_Request__c>{cr1,cr2});

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
        licenseId3.SiteLicenseID__c = '21';
        licenseId4 = new LicenseID__c();
        licenseId4.OrderLineItem__c = orderLineItem1.id;
        licenseId4.Xcode__c = xcode.Id;
        licenseId4.SiteLicenseID__c = '12';
        insert (new List<LicenseID__c>{licenseId1,licenseId2,licenseId3,licenseId4}) ;
    }// END static void setupData() {


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
           v3_monsterBizappsSiterouterSiterouterws.GetCompanyLicenseInfoResponse_element response_x = new v3_monsterBizappsSiterouterSiterouterws.GetCompanyLicenseInfoResponse_element();

           v3_schemasDatacontractOrg200407Monster.ArrayOfLicenseInfo responseElement = new v3_schemasDatacontractOrg200407Monster.ArrayOfLicenseInfo();

           v3_schemasDatacontractOrg200407Monster.LicenseInfo obj1 = new v3_schemasDatacontractOrg200407Monster.LicenseInfo();
           obj1.x_licenseID = Integer.valueOf(licenseId1.SiteLicenseID__c);
           obj1.x_orderID = order1.Id;
           v3_schemasDatacontractOrg200407Monster.LicenseInfo obj2 = new v3_schemasDatacontractOrg200407Monster.LicenseInfo();
           obj2.x_licenseID = Integer.valueOf(licenseId2.SiteLicenseID__c);
           obj2.x_orderID = order1.Id;
           v3_schemasDatacontractOrg200407Monster.LicenseInfo obj3 = new v3_schemasDatacontractOrg200407Monster.LicenseInfo();
           obj3.x_licenseID = Integer.valueOf(licenseId3.SiteLicenseID__c);
           v3_schemasDatacontractOrg200407Monster.LicenseInfo obj4 = new v3_schemasDatacontractOrg200407Monster.LicenseInfo();
           obj4.x_licenseID = Integer.valueOf(licenseId4.SiteLicenseID__c);
           List<v3_schemasDatacontractOrg200407Monster.LicenseInfo> lst1 = new List<v3_schemasDatacontractOrg200407Monster.LicenseInfo>();
           lst1.add(obj1);
           lst1.add(obj2);
           lst1.add(obj3);
           lst1.add(obj4);
           responseElement.LicenseInfo  = lst1;

           Map<String, v3_monsterBizappsSiterouterSiterouterws.GetCompanyLicenseInfoResponse_element> response_map_x = new Map<String, v3_monsterBizappsSiterouterSiterouterws.GetCompanyLicenseInfoResponse_element>();
           response_x.GetCompanyLicenseInfoResult = responseElement;
           //response_map_x.put('response_x',response_x);
           response.put('response_x', response_x);
        }
    }

} // END Class LicenseViewCC_Test