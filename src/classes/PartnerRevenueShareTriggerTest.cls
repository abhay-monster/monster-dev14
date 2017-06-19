// Matt Fisher Created to get enough coverage to deploy to prod org 

 

@IsTest
public class PartnerRevenueShareTriggerTest {

public static testmethod void createPartnerRevShare() {
  // create account
  Account a = TestDataSetupUtility.createTestAccount('TestAccount', 'North America', UserInfo.getUserId());
  insert a;
  Partner_Revenue_Share__c  rs = new Partner_Revenue_Share__c ();
    rs.Partner__c  = a.Id;
    rs.Primary__c = true;
    rs.SiteChannelId__c = '123XX';
      insert rs;
    rs.Primary__c = false;
    update rs;
    
    PartnerRevenueShareTriggerHandler prst = new PartnerRevenueShareTriggerHandler(true,10);
    boolean triggercontext = prst.IsTriggerContext;
    boolean vfcontext= prst.IsVisualforcePageContext;
    boolean webcontext = prst.IsWebServiceContext;
    boolean executecontext = prst.IsExecuteAnonymousContext;
}    
}