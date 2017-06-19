public with sharing class PartnerRevenueShareHelperClass
{
  public static Set<Id> recordsInTriggerContext;
  public static Integer updateTriggerNum;

  public PartnerRevenueShareHelperClass(){}

  public void onlyOnePrimaryInsert(List<Partner_Revenue_Share__c> prss)
  {
    Set<Id> partnerAccIds = new Set<Id>();
    List<Partner_Revenue_Share__c> changedRevShares = new List<Partner_Revenue_Share__c>();

    if(recordsInTriggerContext == null)
      recordsInTriggerContext = new Set<Id>();

    for(Partner_Revenue_Share__c prs:prss)
    {
      if(prs.Partner__c != null && prs.Primary__c == true)
      {
        if(partnerAccIds.contains(prs.Partner__c))
          prs.Primary__c = false;
        else
          partnerAccIds.add(prs.Partner__c);
      }
    }

    if(partnerAccIds != null && !partnerAccIds.isEmpty())
    {
      for(Account partnerAcc:[
        SELECT Id, 
        (
          SELECT Id, Primary__c 
          FROM   Partner_Revenue_Shares__r 
          WHERE  Primary__c = true
        ) 
        FROM   Account 
        WHERE Id IN:partnerAccIds
      ]){
        for(Partner_Revenue_Share__c prs:partnerAcc.Partner_Revenue_Shares__r)
        {
          if(prs.Primary__c = true)
          {
            prs.Primary__c = false;
            changedRevShares.add(prs);
          }
        }
      }

      if(changedRevShares != null && !changedRevShares.isEmpty())
        update changedRevShares;
    }
  }


  public void onlyOnePrimaryUpdate(List<Partner_Revenue_Share__c> oldPrss, Map<Id,Partner_Revenue_Share__c> newPrssMap)
  {
    Set<Id> partnerAccIds = new Set<Id>();
    List<Partner_Revenue_Share__c> changedRevShares = new List<Partner_Revenue_Share__c>();

    if(updateTriggerNum == null)
      updateTriggerNum = 0;

    updateTriggerNum++;
    System.debug('\n\nPartnerRevenueShareHelperClass.onlyOnePrimaryUpdate() '+updateTriggerNum+'\n\n');

    if(recordsInTriggerContext == null)
      recordsInTriggerContext = new Set<Id>();

    recordsInTriggerContext.addAll(newPrssMap.keySet());

    for(Partner_Revenue_Share__c prs:newPrssMap.values())
    {
      if(prs.Partner__c != null && prs.Primary__c)
      {
        if(partnerAccIds.contains(prs.Partner__c))
          prs.Primary__c = false;
        else
          partnerAccIds.add(prs.Partner__c);
      }
    }

    if(partnerAccIds != null && !partnerAccIds.isEmpty())
    {
      for(Account partnerAcc:[
        SELECT Id, 
        (
          SELECT Id, Primary__c 
          FROM   Partner_Revenue_Shares__r 
          WHERE  Primary__c = true
        ) 
        FROM   Account 
        WHERE  Id IN:partnerAccIds 
        AND    Id NOT IN:recordsInTriggerContext
      ]){
        for(Partner_Revenue_Share__c prs:partnerAcc.Partner_Revenue_Shares__r)
        {
          if(!recordsInTriggerContext.contains(prs.Id))
          {
            prs.Primary__c = false;
            changedRevShares.add(prs);
          }
        }
      }

      if(changedRevShares != null && !changedRevShares.isEmpty())
        update changedRevShares;
    }
  }
}