/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class LicenseIDtriggerTest {

    static testMethod void myUnitTest() {
         Personal_Settings__c ps = new Personal_Settings__c(Validation_Account__c=false,Trigger_Order__c=false);
        insert ps;
        WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c();
        endpoint.Endpoint__c = 'USPS Integration';
        endpoint.Name = 'USPS Integration';
        insert endpoint;
        
        IntegrationConfig__c integSett = TestDataSetupUtility.buildIntegrationConfigSetting();
        integSett.Name = 'USPS Integration';
        integSett.EndpointName__c = endpoint.Name;
        integSett.PaypalRedirectURL__c = endpoint.Endpoint__c;
        insert integSett;
        
        CountryLimit__c cl = TestDataSetupUtility.createCountryLimit('United States', 'US', 2000, 'Staffing');
        insert cl;
        Account acc = new Account(Name='test');
        insert acc;
        
        Contact con = TestDataSetupUtility.createTestContact(acc.Id, 'confirst1', 'conlast1', 'con1@email.com');
        insert con;
        Order__c originalOrder = TestDataSetupUtility.createOrder(acc.Id, con.Id);
        originalOrder.BillingAccount__c = acc.Id;
        originalOrder.BillingContact__c = con.id;
        originalOrder.Posting_Contact__c = con.id;
         //originalOrder.GrossRemainingCreditAmount__c = 2;
         originalOrder.OrderStatus__c='Verified';
        insert originalOrder;
        
        Order_Line_Item__c oli = TestDataSetupUtility.createOrderLineItem(originalOrder.id);
        oli.Order__c =  originalOrder.Id;
        //oli.MAPP_OrderLineItem__c = '42578235';
        oli.GrossRemainingCreditAmount__c= 123;
        insert oli;

      //  oli.MAPP_OrderLineItem__c = ('' +oli.Id).left(15);
      //  update oli;
        
        oli  = [SELECT MAPP_OrderLineItem__c ,Id FROM Order_Line_Item__c  WHERE Id = :oli.Id];
        
        Test.startTest();
        LicenseID__c lId = new LicenseID__c();
        lId.OrderLineItem__c = oli.Id;
        lId.MAPP_OrderLineItem__c = oli.MAPP_OrderLineItem__c;
        insert lId;
        
        lId = [Select MAPP_OrderLineItem__c from LicenseID__c  Where Id = :lId.Id];
        System.debug('===oli.MAPP_OrderLineItem__c ==='+oli.MAPP_OrderLineItem__c +'====='+lId.MAPP_OrderLineItem__c );
        
        Test.stopTest();
    }
}