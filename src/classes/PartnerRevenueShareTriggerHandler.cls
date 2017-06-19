public with sharing class PartnerRevenueShareTriggerHandler
{
  private boolean m_isExecuting = false;

  private integer BatchSize = 0;

  private PartnerRevenueShareHelperClass helper {get;set;}

  public PartnerRevenueShareTriggerHandler(boolean isExecuting, integer size)
  {
    m_isExecuting = isExecuting;
    BatchSize = size;
    helper = new PartnerRevenueShareHelperClass();
  }

  public void OnBeforeInsert(List<Partner_Revenue_Share__c> newPartnerRevenueShares)
  {
    helper.onlyOnePrimaryInsert(newPartnerRevenueShares);
  }

  /*public void OnAfterInsert(List<Partner_Revenue_Share__c> newPartnerRevenueShares)
  {
  }
 
  @future public static void OnAfterInsertAsync(Set<ID> newPartnerRevenueShareIDs)
  { 
  }*/

  public void OnBeforeUpdate(List<Partner_Revenue_Share__c> oldPartnerRevenueShares, List<Partner_Revenue_Share__c> updatedPartnerRevenueShares, Map<ID, Partner_Revenue_Share__c> PartnerRevenueShareMap)
  {
    helper.onlyOnePrimaryUpdate(oldPartnerRevenueShares,PartnerRevenueShareMap);
  }

  /*public void OnAfterUpdate(List<Partner_Revenue_Share__c> oldPartnerRevenueShares, List<Partner_Revenue_Share__c> updatedPartnerRevenueShares, Map<ID, Partner_Revenue_Share__c> PartnerRevenueShareMap)
  {
  }

  @future public static void OnAfterUpdateAsync(Set<ID> updatedPartnerRevenueShareIDs)
  {
  }

  public void OnBeforeDelete(List<Partner_Revenue_Share__c> PartnerRevenueSharesToDelete, Map<ID, Partner_Revenue_Share__c> PartnerRevenueShareMap)
  {
  }

  public void OnAfterDelete(List<Partner_Revenue_Share__c> deletedPartnerRevenueShares, Map<ID, Partner_Revenue_Share__c> PartnerRevenueShareMap)
  {
  }

  @future public static void OnAfterDeleteAsync(Set<ID> deletedPartnerRevenueShareIDs)
  {
  }

  public void OnUndelete(List<Partner_Revenue_Share__c> restoredPartnerRevenueShares)
  {
  }*/

  // trigger contexts
  public boolean IsTriggerContext
  {get{ return m_isExecuting;}}

  public boolean IsVisualforcePageContext
  {get{ return !IsTriggerContext;}}

  public boolean IsWebServiceContext
  {get{ return !IsTriggerContext;}}

  public boolean IsExecuteAnonymousContext
  {get{ return !IsTriggerContext;}}
}