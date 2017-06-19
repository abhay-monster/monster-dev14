@isTest

Private Class TransferCustonLookupCCTest{
    static Account acc;
    static testmethod void testTransferCustonLookupCC(){
        prepareData();
        Test.startTest();
        System.currentPageReference().getParameters().put('frm','form');
        System.currentPageReference().getParameters().put('txt','test');
        System.currentPageReference().getParameters().put('idfield',acc.Id);
        TransferCustonLookupCC controller = new TransferCustonLookupCC();
        controller.searchString = 'test';
        controller.Search();
        //system.assert(controller.xCodeAccountList.size() > 0);
        system.assert(controller.xCodeList.size() > 0);
        System.assert(controller.getXcodes().size() > 0);        
        System.assert(controller.pageNumber > 0);        
        controller.next();
        controller.previous();
        System.assert(controller.getFormTag() != null);
        System.assert(controller.getTextBox() != null);    
          
        
        
        Test.stopTest();
    }
    
    static void prepareData(){
     acc = TestDataSetupUtility.createTestAccount('test',null,null);
     insert acc;
     
     Xcode__c xcode = new Xcode__c();     
     xcode.name = 'test';
     insert xcode ;
     
     XcodeAccount__c xAcc = new XcodeAccount__c ();
     xAcc.Xcode__c = xcode .Id;
     xAcc.Account__c = acc.Id;
     insert xAcc;
     
     xcode = new Xcode__c();     
     xcode.name = 'test1';
     insert xcode ;
     
     xAcc = new XcodeAccount__c ();
     xAcc.Xcode__c = xcode .Id;
     xAcc.Account__c = acc.Id;
     insert xAcc;
     
    } 

}