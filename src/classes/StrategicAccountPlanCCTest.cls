@isTest
private class StrategicAccountPlanCCTest {

    static testMethod void testStrategicAccountPlan() {
        Account acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        insert acc;
        
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp ', acc.Id);
        insert opp;
        
        opp.OrderCreated__c = TRUE;
        Test.startTest();
        update opp;
        
        Order__c testOrder = new Order__c(Account__c = acc.id,Opportunity__c = opp.id);
       // Order__c testOrder = [Select id, Name, Account__c, Opportunity__c From Order__c Where Opportunity__c=: opp.Id];
        insert testOrder;
        
        Order_Line_Item__c  oLI3 =TestDataSetupUtility.createOrderLineItem(testOrder.id);
        insert oLI3;

        testOrder.OrderStatus__c = 'Verified';
        testOrder.BillingAccount__c = acc.id;
        testOrder.ShippingAccount__c = acc.id;
        update testOrder;
        Test.stopTest();
        
        Product2 testProduct = new Product2(Name='TestProduct', Isactive=TRUE); 
        insert testProduct;
        list<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
        Order_Line_Item__c oli1 = new Order_Line_Item__c();
        //oli1.Name = testProduct.Name;
        oli1.Order__c = testOrder.Id;
        //oli1.NetPrice__c = 100;
        oli1.Quantity__c = 1;
        oli1.EndDate__c = Date.Today();
        oliList.add(oli1);
        
        Order_Line_Item__c oli2 = new Order_Line_Item__c();
        //oli2.Name = testProduct.Name;
        oli2.Order__c = testOrder.Id;
        //oli2.NetPrice__c = 100;
        oli2.Quantity__c = 1;
        oli2.EndDate__c = Date.Today()+1;
        oliList.add(oli2);
        insert oliList;
                
        Test.setCurrentPage(Page.StrategicAccountPlan);
        ApexPages.StandardController controller = new ApexPages.StandardController(acc);
        StrategicAccountPlanCC sap = new StrategicAccountPlanCC(controller);
        
        //Testing all Warapper class constructor added 3 May 2016
        StrategicAccountPlanCC.AccountStrategyRow AccStraTest = new StrategicAccountPlanCC.AccountStrategyRow('Test Account',acc.id);
        StrategicAccountPlanCC.AccountStrategyRow AccStraTest1 = new StrategicAccountPlanCC.AccountStrategyRow('Test Account','TestProduct',acc.id,testProduct.id);
        StrategicAccountPlanCC.AccountStrategyRow AccStraTest2 = new StrategicAccountPlanCC.AccountStrategyRow('Test Account','TestProduct',acc.id,testProduct.id,null,null,null);
        
        Double quant = AccStraTest2.quantity;
        Double netpri = AccStraTest2.netPrice;
        Date endDate = AccStraTest2.endDate;
       
        sap.AccountId = acc.Id;
        System.debug('!! new Tab ' + sap.NewTabAsPDF);
        System.debug('!! rowData ' + sap.asRowData);
        System.debug('!! mAccountRow ' + sap.mAccountStrategyRow);
        
        //System.assertEquals(sap.asRowData[0].asRow[0].EndDate, Date.Today()+1);
        //System.assertEquals(sap.asRowData[0].asRow[0].quantity, 2);
       // System.assertEquals(sap.asRowData[0].asRow[0].netPrice, 200);
        //System.assertEquals(sap.asRowData[1].quantity, 2);
        // System.assertEquals(sap.asRowData[1].netPrice, 200);
    } 
}