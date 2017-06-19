@isTest
private class ClearQuestCCTest{

 static testMethod void ClearQuestCCTest(){
   
     Case caseObj;
     Case caseObj1;
     ExternalTicket__c extTicket;
     ExternalTicket__c extTicket1;
     ExternalTicket__c extTicket2;
     //try{
         Account acc = TestDataSetupUtility.createTestAccountWithShipping('Test Acocunt'); 
         insert acc;
         Contact con = TestDataSetupUtility.createTestContact(acc.id,'Last','First','Test@appirio.com');
         insert con;
         caseObj = new Case(ContactId = con.ID,AccountId = acc.Id,Status = 'Working',Origin = 'Phone');
         insert caseObj ;
         caseObj1 = new Case(ContactId = con.ID,AccountId = acc.Id,Status = 'Working',Origin = 'Phone');
         insert caseObj1;
          
         extTicket = new ExternalTicket__c (name= 'Test Ticket',SourceSystem__c = 'Clearquest',Case__c = caseObj.Id); 
         extTicket1 = new ExternalTicket__c (name= 'Test Ticket 1',SourceSystem__c = 'Clearquest',Case__c = caseObj.Id);
         extTicket2 = new ExternalTicket__c (name= 'Test Ticket 2',SourceSystem__c = 'Clearquest',Case__c = caseObj1.Id);
         insert extTicket1 ;
         insert extTicket ;
         insert extTicket2 ;
         /*}catch(exception e){
         
           system.assert(false,'Test data not Inserted');
           }*/
           
           system.debug('extTicket***' +extTicket);
            Test.startTest();  
            PageReference pageRef = Page.ClearQuest;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('caseId', caseObj.Id);
            ApexPages.StandardController controller = new ApexPages.StandardController(caseObj );
            ClearQuestCC ctrl = new ClearQuestCC(controller );
            
            system.assertNotEquals(pageRef ,null);
            
            PageReference  pageRef1 = Page.ClearQuest;
            Test.setCurrentPage(pageRef1);
            pageRef1.getParameters().put('caseId', caseObj1.Id);
            ApexPages.StandardController controller1 = new ApexPages.StandardController(caseObj1);
            ClearQuestCC ctrl1 = new ClearQuestCC(controller1 );
            
            system.assertNotEquals(pageRef ,null);
            Test.stopTest(); 
 
 }
 
  static testMethod void ClearQuestCCTest1(){
   
     Case caseObj;
     Case caseObj1;
     ExternalTicket__c extTicket;
     //try{
         Account acc = TestDataSetupUtility.createTestAccountWithShipping('Test Acocunt'); 
         insert acc;
         Contact con = TestDataSetupUtility.createTestContact(acc.id,'Last','First','Test@appirio.com');
         insert con;
         caseObj = new Case(ContactId = con.ID,AccountId = acc.Id,Status = 'Working',Origin = 'Phone');
         insert caseObj ;
         caseObj1 = new Case(ContactId = con.ID,AccountId = acc.Id,Status = 'Working',Origin = 'Phone');
         insert caseObj1;
          
         extTicket = new ExternalTicket__c (name= 'Test Ticket',SourceSystem__c = 'Clearquest',Case__c = caseObj.Id); 

         insert extTicket ;

         /*}catch(exception e){
         
           system.assert(false,'Test data not Inserted');
           }*/
           
           system.debug('extTicket***' +extTicket);
            Test.startTest();  
            PageReference pageRef = Page.ClearQuest;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('caseId', caseObj.Id);
            ApexPages.StandardController controller = new ApexPages.StandardController(caseObj );
            ClearQuestCC ctrl = new ClearQuestCC(controller );
            
            //system.assertNotEquals(pageRef ,null);
            
            PageReference  pageRef1 = Page.ClearQuest;
            Test.setCurrentPage(pageRef1);
            pageRef1.getParameters().put('caseId', caseObj1.Id);
            ApexPages.StandardController controller1 = new ApexPages.StandardController(caseObj1);
            ClearQuestCC ctrl1 = new ClearQuestCC(controller1 );
            
            
            ClearQuestCC.CQWrapper obj = new ClearQuestCC.CQWrapper('sdfsd','sdf','ff','f',DateTime.Now(),1,'ff');
           // system.assertNotEquals(pageRef ,null);
            Test.stopTest(); 
 
 }
}