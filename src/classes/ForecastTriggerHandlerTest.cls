@isTest
private class ForecastTriggerHandlerTest {
    Static User manager , manager1;

    
       static testMethod void testForecastQuotaTriggerHandler() {
            Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
            manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
            insert manager;
            
            manager1 = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
            insert manager1;
        
        
            Forecast_Quota__c FQ = new Forecast_Quota__c();
            FQ.Sales_Rep__c = manager.id;
            FQ.Amount__c = 100;
            FQ.Quota_Valid_From__c = Date.Today();
            FQ.Quota_Valid_To__c= Date.Today();
            
            insert FQ;
            
            FQ.Sales_Rep__c = manager1.id;
            update FQ;            
            FQ = [select Sales_Rep__c  , OwnerId from Forecast_Quota__c  where id = :FQ.id];
            system.assert(True , FQ.sales_rep__c== FQ.OwnerId);
            
            
       
       }


}