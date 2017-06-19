/**

 */
@isTest
private class TransferAdjustmentAccountAccessCCTest {

    static testMethod void myUnitTest1() {
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
        Order__c originalOrder= TestDataSetupUtility.createOrder(acc.Id, con.Id);
        originalOrder.OrderStatus__c='Verified';
        originalOrder.BillingAccount__c = acc.id;
        originalOrder.ShippingAccount__c = acc.id;
        originalOrder.Account__c = acc.id;
        insert originalOrder;
        
        Order_Line_Item__c oli = TestDataSetupUtility.createOrderLineItem(originalOrder.id);
        oli.Order__c =  originalOrder.Id;
        oli.GrossRemainingCreditAmount__c= 2000;
        oli.EndDate__c= system.today()+1;        
        insert oli;
        
        LicenseID__c license = new LicenseID__c (OrderLineItem__c=oli.Id);
        license.SiteLicenseID__c = '123123123123';
        license.AvailableInventory__c = 2;
        insert license;
        
        List<Order__c> orderList =  [SELECT Id, Name, OrderStatus__c, GrossRemainingCreditAmount__c 
                            FROM Order__c WHERE  Account__c =:acc.Id
                             and  OrderStatus__c IN ('Verified', 'Paid in Full', 'Invoiced')];
        system.debug('orderList::'+orderList);
        ApexPages.currentPage().getParameters().put('AccountID',acc.Id);
        ApexPages.currentPage().getParameters().put('radioSelectValue','test');
        
        TransferAdjustmentAccountAccessCC trnsAccAccess = new TransferAdjustmentAccountAccessCC();
        trnsAccAccess.selectedAction = 'transfer';
        trnsAccAccess.onSelectAction();
    }
    
    static testMethod void myUnitTest() {
        // TO DO: implement unit test
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
        Order__c originalOrder= TestDataSetupUtility.createOrder(acc.Id, con.Id);
        //originalOrder.GrossRemainingCreditAmount__c = 2;
        originalOrder.BillingAccount__c = acc.id;
        originalOrder.ShippingAccount__c = acc.id;
        originalOrder.OrderStatus__c='Verified';
        insert originalOrder;
        
        Order_Line_Item__c oli = TestDataSetupUtility.createOrderLineItem(originalOrder.id);
        oli.Order__c =  originalOrder.Id;
        oli.GrossRemainingCreditAmount__c= 123;
        insert oli;
        
        ApexPages.currentPage().getParameters().put('AccountID',acc.Id);
        ApexPages.currentPage().getParameters().put('radioSelectValue','test');
        
        TransferAdjustmentAccountAccessCC trnsAccAccess = new TransferAdjustmentAccountAccessCC();
        PageReference pr = trnsAccAccess.onSelectAction();
        trnsAccAccess.displayStr(null);
        trnsAccAccess.displayStr('test');
        trnsAccAccess.displayInt(1.2);
        trnsAccAccess.displayInt(null);
        trnsAccAccess.displayDt(Date.today());
        trnsAccAccess.displayDt(null);
        trnsAccAccess.displayDec(3.4);
        trnsAccAccess.displayDec(null);
        trnsAccAccess.displayCurr('test', 1.2);
        trnsAccAccess.displayCurr('test', null);
  		//      Order__c order;
 		//      Order_Line_Item__c[] lines;
        //Test case 1
        trnsAccAccess.selectedAction = 'transfer';
 		//       list<SelectOption> lst = trnsAccAccess.actionList;
        
        TransferAdjustmentAccountAccessCC.OrderWrap ordrWrapper = new TransferAdjustmentAccountAccessCC.OrderWrap();
       
        /* 
        ordrWrapper.order = new Order__c(Account__c=acc.Id,OrderStatus__c='Verified');
        insert ordrWrapper.order;
        
        ordrWrapper.lines.add(new Order_Line_Item__c(Order__c=ordrWrapper.order.Id,GrossRemainingCreditAmount__c=2,EndDate__c=System.today().addDays(4)));
        insert ordrWrapper.lines;
       
        LicenseID__c license = new LicenseID__c (OrderLineItem__c=orderItem.Id);
        insert license;
        */
        
        system.debug('==lst=='+ [SELECT Id, Name, OrderStatus__c, GrossRemainingCreditAmount__c 
                            FROM Order__c WHERE  id =:originalOrder.Id
                              AND OrderStatus__c IN ('Verified', 'Paid in Full', 'Invoiced')]);
                             
        pr = trnsAccAccess.onSelectAction();
        
        pr = trnsAccAccess.selectQuoteID();
        pr = trnsAccAccess.onClickNext();
        pr = trnsAccAccess.onClickCancel();
        
        list<SelectOption> ss = trnsAccAccess.actionList;
        
    }
    
    static testMethod void myUnitTest2() {
        // TO DO: implement unit test
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
        Order__c originalOrder= TestDataSetupUtility.createOrder(acc.Id, con.Id);
         //originalOrder.GrossRemainingCreditAmount__c = 2;
         originalOrder.BillingAccount__c = acc.id;
         originalOrder.ShippingAccount__c = acc.id;
         originalOrder.OrderStatus__c='Verified';
        insert originalOrder;
        
        Order_Line_Item__c oli = TestDataSetupUtility.createOrderLineItem(originalOrder.id);
        oli.Order__c =  originalOrder.Id;
        oli.GrossRemainingCreditAmount__c= 123;
        insert oli;
        
        LicenseID__c license = new LicenseID__c (OrderLineItem__c=oli.Id);
        license.SiteLicenseID__c = '123123123123';
        license.AvailableInventory__c = 2;
        insert license;
        
        ApexPages.currentPage().getParameters().put('AccountID',acc.Id);
        ApexPages.currentPage().getParameters().put('radioSelectValue','test');
        
        TransferAdjustmentAccountAccessCC trnsAccAccess = new TransferAdjustmentAccountAccessCC();
        PageReference pr = trnsAccAccess.onSelectAction();
        trnsAccAccess.selectedAction = 'Adjustment';
        
        TransferAdjustmentAccountAccessCC.OrderWrap ordrWrapper = new TransferAdjustmentAccountAccessCC.OrderWrap();
       
       /* 
        ordrWrapper.order = new Order__c(Account__c=acc.Id,OrderStatus__c='Verified');
        insert ordrWrapper.order;
        
        ordrWrapper.lines.add(new Order_Line_Item__c(Order__c=ordrWrapper.order.Id,GrossRemainingCreditAmount__c=2,EndDate__c=System.today().addDays(4)));
        insert ordrWrapper.lines;
       */
       
        
        
       system.debug('==lst=='+ [SELECT Id, Name, OrderStatus__c, GrossRemainingCreditAmount__c 
                            FROM Order__c WHERE  id =:originalOrder.Id
                              AND OrderStatus__c IN ('Verified', 'Paid in Full', 'Invoiced')]);
                             
        pr = trnsAccAccess.onSelectAction();
        
        pr = trnsAccAccess.selectQuoteID();
        pr = trnsAccAccess.onClickNext();
        pr = trnsAccAccess.onClickCancel();
        
        list<SelectOption> ss = trnsAccAccess.actionList;
        
    }
    
}