/****
*Test class of XcodeBatchClass
*
*/
@isTest
private class XcodeBatchClassSchTest{
  static testmethod void  testschedule(){
      Test.StartTest();
      
      Account testAccount = new Account(Name='Test Account');
      insert testAccount;
      
      Order__c testOrder = new Order__c(Account__c = testAccount.id);
      insert testOrder;
      
      Xcode__c testXcode = new Xcode__c(Name = 'testXcode',Trusted__c = 'N');
      insert testXcode;
      
      XcodeAccount__c testXcodeAccout = new XcodeAccount__c(Account__c = testAccount.id,Xcode__c = testXcode.id);
      insert testXcodeAccout;
      
      XcodeBatchScheduler sh1 = new XcodeBatchScheduler();      
      String sch = '0  00 1 3 * ?';
      system.schedule('Test', sch, sh1);
      
      Test.stopTest();
     }
    }