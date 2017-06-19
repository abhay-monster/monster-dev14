@isTest
public class CreateSalesQuotaCC_Test{

 static testMethod void testSaleQuote(){
        
        Test.starttest();
        Sales_Quotas__c quota = TestDataSetupUtility.createTestSalesQuota(UserInfo.getUserId());   
        insert quota;     
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(quota);
        CreateSalesQuotaCC ctrl = new CreateSalesQuotaCC(sc);
        // Verify New URL is created 
        System.assert(ctrl.stringURL != null);
        Test.stopTest();
        
  }      
}