/*before delete, after delete, after undelete, after insert, 
 after update*/
trigger PartnerRevenueShareTrigger on Partner_Revenue_Share__c (before insert,before update)
{
  PartnerRevenueShareTriggerHandler handler = new PartnerRevenueShareTriggerHandler(Trigger.isExecuting, Trigger.size);

  if(Trigger.isInsert && Trigger.isBefore)
  {
    handler.OnBeforeInsert(Trigger.new);
  }
  /*else if(Trigger.isInsert && Trigger.isAfter)
  {
    handler.OnAfterInsert(Trigger.new);
    PartnerRevenueShareTriggerHandler.OnAfterInsertAsync(Trigger.newMap.keySet());
  }*/
  else if(Trigger.isUpdate && Trigger.isBefore)
  {
    handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
  }

  /*else if(Trigger.isUpdate && Trigger.isAfter)
  {
    handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap);
    PartnerRevenueShareTriggerHandler.OnAfterUpdateAsync(Trigger.newMap.keySet());
  }
  else if(Trigger.isDelete && Trigger.isBefore)
  {
    handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
  }

  else if(Trigger.isDelete && Trigger.isAfter)
  {
    handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
    PartnerRevenueShareTriggerHandler.OnAfterDeleteAsync(Trigger.oldMap.keySet());
  }
  else if(Trigger.isUnDelete)
  {
    handler.OnUndelete(Trigger.new);
  }*/
}