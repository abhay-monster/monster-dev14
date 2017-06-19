/*****************************************************************************
 * Name             : PartnerRevenueShareHelperClassTest
 * Created By       : Vivek Ojha(Appirio)
 * Created Date     : 03/09/2015
 * Purpose          : Test class for PartnerRevenueShareHelperClass 
 * Note             : 
*****************************************************************************/
@isTest
private class PartnerRevenueShareHelperClassTest {

    static testMethod void test_onlyOnePrimaryInsert() {
       
         // create account
        Account a = TestDataSetupUtility.createTestAccount('TestAccount', 'North America', UserInfo.getUserId());
        insert a;
          
        Partner_Revenue_Share__c  rs1 = new Partner_Revenue_Share__c ();
        rs1.Partner__c  = a.Id;
        rs1.Primary__c = true;
        insert rs1;
            //T-488099 
      //  a.Primary_Partner_RevShare__c = rs1.Id;
     //   update a;
          
 
        Partner_Revenue_Share__c  rs = new Partner_Revenue_Share__c ();
        rs.Partner__c  = a.Id;
        rs.Primary__c = true;
          insert rs;
        rs.Primary__c = false;
        update rs;
        
        Test.startTest();
        
        PartnerRevenueShareTriggerHandler prst = new PartnerRevenueShareTriggerHandler(true,10);
        boolean triggercontext = prst.IsTriggerContext;
        boolean vfcontext= prst.IsVisualforcePageContext;
        boolean webcontext = prst.IsWebServiceContext;
        boolean executecontext = prst.IsExecuteAnonymousContext;
        PartnerRevenueShareHelperClass prShare = new PartnerRevenueShareHelperClass();
        prShare.onlyOnePrimaryInsert(new List<Partner_Revenue_Share__c>{rs});
        
        
        Test.stopTest();
    }
    
    static testMethod void test_onlyOnePrimaryUpdate() {
       
       Map<Id,Partner_Revenue_Share__c> newPrssMap = new Map<Id,Partner_Revenue_Share__c>();
         // create account
        Account a = TestDataSetupUtility.createTestAccount('TestAccount', 'North America', UserInfo.getUserId());
        insert a;
          
        Partner_Revenue_Share__c  rs1 = new Partner_Revenue_Share__c ();
        rs1.Partner__c  = a.Id;
        rs1.Primary__c = true;
        insert rs1;
             
        //T-488099 
      //  a.Primary_Partner_RevShare__c = rs1.Id;
     //   update a;
          
 
        Partner_Revenue_Share__c  rs = new Partner_Revenue_Share__c ();
        rs.Partner__c  = a.Id;
        rs.Primary__c = true;
          insert rs;
        
        newPrssMap.put(rs.Id,rs);
        
        Test.startTest();
         
        PartnerRevenueShareTriggerHandler prst = new PartnerRevenueShareTriggerHandler(true,10);
        boolean triggercontext = prst.IsTriggerContext;
        boolean vfcontext= prst.IsVisualforcePageContext;
        boolean webcontext = prst.IsWebServiceContext;
        boolean executecontext = prst.IsExecuteAnonymousContext;
        
        PartnerRevenueShareHelperClass prShare = new PartnerRevenueShareHelperClass();
        prShare.onlyOnePrimaryUpdate(new List<Partner_Revenue_Share__c>{rs}, newPrssMap);
        
        Test.stopTest();
    }
}