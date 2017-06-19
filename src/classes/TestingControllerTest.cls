@isTest
private class TestingControllerTest{

 static testMethod void TestingController_Test(){
 
    Integration_Attribute__c integration;
    User u1 = [SELECT Id FROM User WHERE profileId IN (SELECT id FROM Profile WHERE Name = 'System Administrator') AND isActive = TRUE LIMIT 1];
    
    System.RunAs(u1){
        Test.StartTest();
        
            integration = new Integration_Attribute__c(Name = 'Test' ,Integration_Type__c='MAPP');
            insert integration;
            
             List<Integration_Attribute__c> integrationLst = new List<Integration_Attribute__c>();
             integrationLst.add(integration);
             
            
            TestingController ctrl = new TestingController();
            ctrl.ias  = integrationLst;
            
            system.assertNotequals(ctrl,null);
        }
     }
}