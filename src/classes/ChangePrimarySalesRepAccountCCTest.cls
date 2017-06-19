@isTest
private class ChangePrimarySalesRepAccountCCTest{

  static testMethod void ChangePrimary(){
      Account acc; 
     try{
     acc = TestDataSetupUtility.createTestAccountWithShipping('Test Acocunt');
     insert acc;
     }catch(exception e){
            system.assert(false,'Problem Inserting Test data');
        }
         
     Test.startTest();  
            PageReference pageRef = Page.CreateReBill;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('AccountId', acc.id);
            pageRef.getParameters().put('RecordType', '012110000004Pkt');
            pageRef.getParameters().put('targetName', 'Test');
            //pageRef.getParameters().put('quoteName', 'Test');
            ApexPages.StandardController controller = new ApexPages.StandardController(acc);
            ChangePrimarySalesRepAccountCC  ctrl = new ChangePrimarySalesRepAccountCC (controller);
            ctrl.getAccountToUpdate();
            ctrl.saveNewOwner();
            ctrl.cancel();
            
            PageReference pageRef1 = Page.CreateReBill;
            Test.setCurrentPage(pageRef1);
            pageRef1.getParameters().put('AccountId', acc.id);
            pageRef1.getParameters().put('RecordType', '467110000004Pkt');
            
            ApexPages.StandardController controller1 = new ApexPages.StandardController(acc);
            ChangePrimarySalesRepAccountCC  ctrl1 = new ChangePrimarySalesRepAccountCC (controller1);
            ctrl1.getAccountToUpdate();
            system.assertNotEquals(pageRef1 ,null);
            Test.stopTest();       
 
 }
}