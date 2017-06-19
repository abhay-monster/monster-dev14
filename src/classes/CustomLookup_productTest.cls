@isTest
private class CustomLookup_productTest{

 static testMethod void CustomLookup(){
 
     Test.startTest();
     CustomLookup_product ctrl = new CustomLookup_product();
     ctrl.searchByName  = 'Test';
     system.assertNotEquals(null,ctrl);
     Test.stopTest();
 }
}