@isTest

Private Class OrderLineItemCC_Test{

    static Order_Line_Item__c oli;
    static Order__c o;
    static Personal_Settings__c personalSettings;
   
    static testmethod void testOrderLineItemCC(){
        prepareData();
        Test.startTest();        
        ApexPages.StandardController std = new ApexPages.StandardController(oli);
        OrderLineItemCC controller = new OrderLineItemCC(std);
        
        System.assert(controller.selectedQueue != null);
        
        Test.stopTest();
    }
    
    static void prepareData(){
     Account acc = TestDataSetupUtility.createTestAccount('test',null,null);
     insert acc;
     Contact con = TestDataSetupUtility.createTestContact(acc.Id, 'confirst1', 'conlast1', 'con1@email.com');
     insert con;
     o = TestDataSetupUtility.createOrder(acc.Id, con.Id);
     insert o;
     
     oli = TestDataSetupUtility.createOrderLineItem(o.Id);
     insert oli;
     
    } 
    
    
    static testmethod void testOrderTriggerHandler(){
        
        personalSettings = TestDataSetupUtility.buildPersonalSetting();
        personalSettings.Trigger_Order__c = true;
        insert personalSettings;
        
     Account acc = TestDataSetupUtility.createTestAccount('test',null,null);
     insert acc;
     Contact con = TestDataSetupUtility.createTestContact(acc.Id, 'confirst1', 'conlast1', 'con1@email.com');
     insert con;
     o = TestDataSetupUtility.createOrder(acc.Id, con.Id);
     insert o;
     o.Accept__c = 'Test' ;
     update o;
        
        
    }

}