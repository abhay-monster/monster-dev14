@isTest
private class CreateReBillCCTest{

 Order__c order;   
 static testMethod void createReBill(){
     
     Order__c order;
     Opportunity opp;
     try{ 
         Account acc = TestDataSetupUtility.createTestAccountWithShipping('Test Acocunt'); 
         insert acc;
         opp = TestDataSetupUtility.createTestOpportunity('Test opp',acc.Id);
         insert opp;
         Contact con = TestDataSetupUtility.createTestContact(acc.Id, 'confirst1', 'conlast1', 'con1@email.com');
         insert con;
         order = TestDataSetupUtility.createOrder(acc.Id, con.Id);
         insert order;
         }catch(exception e){
             system.assert(false,'Problem Inserting Test data');
         }
         
          Test.startTest();  
            PageReference pageRef = Page.CreateReBill;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('oppName', opp.Name);
            pageRef.getParameters().put('orderId', 'Test');
            pageRef.getParameters().put('quoteName', 'Test');
            ApexPages.StandardController controller = new ApexPages.StandardController(order);
            CreateReBillCC ctrl = new CreateReBillCC(controller);
            ctrl.executeMethod();
            system.assertNotEquals(pageRef ,null);
            Test.stopTest();   
 
      }
}