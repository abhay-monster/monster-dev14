public without sharing class OpportunitySplitTriggerHandler extends BaseTriggerHandler {
    final String CLASSNAME = '\n\n**** OpportunitySplitTriggerHandler.METHODNAME()';
    private OpportunitySplitTriggerHelper helper;

    public OpportunitySplitTriggerHandler(boolean isExecuting, integer pTriggerSize){
        helper = new OpportunitySplitTriggerHelper();
    }
    

    public void OnBeforeInsert(OpportunitySplit[] pNewOpportunitySplit){
        if (Personal_Settings__c.getInstance().Trigger_Opportunity_Split__c ==false){
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        helper.validateUserPermission(pNewOpportunitySplit);
    }

    public void OnAfterInsert(OpportunitySplit[] pNewOpportunitySplit, map<ID, OpportunitySplit> pNewOpportunitySplitMap){
        if (Personal_Settings__c.getInstance().Trigger_Opportunity_Split__c ==false){
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        system.debug('check 1 pNewOpportunitySplit' + pNewOpportunitySplit);
        helper.insertRecordinOLIManager(pNewOpportunitySplit,pNewOpportunitySplitMap);
    }

    public void OnBeforeUpdate(OpportunitySplit[] pNewOpportunitySplit, map<ID, OpportunitySplit> pNewOpportunitySplitMap){
        if (Personal_Settings__c.getInstance().Trigger_Opportunity_Split__c ==false){
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        system.debug('map? ' + pNewOpportunitySplitMap);
        helper.validateUserPermission(pNewOpportunitySplit);
        
    }
    public void OnbeforeDelete(OpportunitySplit[] pOldOpportunitySplit, map<ID, OpportunitySplit> pOldOpportunitySplitMap){
        if (Personal_Settings__c.getInstance().Trigger_Opportunity_Split__c ==false){
            return; // If triggers are off, then exit the method
        }

        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeDelete');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        helper.validateUserPermission(pOldOpportunitySplit);
        helper.deleteRecordOLIM(pOldOpportunitySplit);
    }



    //public void OnAfterDelete(OpportunitySplit[] pOldOpportunitySplit){
    //   if (Personal_Settings__c.getInstance().Trigger_Opportunity_Split__c ==false){
    //        return; // If triggers are off, then exit the method
    //    }
    //    for(OpportunitySplit split : pOldOpportunitySplit){
    //        system.debug('^^^ OpportunitySplitTriggerHandler.OnAfterDelete Successfully deleted OpportunitySplit ' + split.Id);
    //    }
    //}

/*
    public void validateUserForOppSplitPermission(OpportunitySplit[] pOldOpportunitySplit){
        if (Personal_Settings__c.getInstance().Trigger_Opportunity_Split__c ==false){
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','validateUserForOppSplitPermission');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        User currentUser = [Select Id from User Where Id = :UserInfo.getUserId() LIMIT 1];
        List<string> oppIds = new List<string>();
        for(OpportunitySplit split : pOldOpportunitySplit){
            oppIds.add(split.OpportunityId);
            system.debug('^^^ Deleting ' + split);
        }

        map<Id, Opportunity> mapOpportunity = new map<Id, Opportunity>([Select Id, Account.ConvertedFromLead__c, ownerId from Opportunity Where Id IN :oppIds]);
        Boolean ConvertedFromLead = false;

        for(Id id : mapOpportunity.keyset()){
            Opportunity o = mapOpportunity.get(id);
            if (o.Account.ConvertedFromLead__c){
                ConvertedFromLead=true;
            }
        }
        system.debug('^^^ ConvertedFromLead=' + ConvertedFromLead);

        for(OpportunitySplit split : pOldOpportunitySplit) {

            if(mapOpportunity.containsKey(split.OpportunityId) &&
                ( ConvertedFromLead && !(split.SplitownerId == currentUser.Id)) ||
                (!ConvertedFromLead && !(mapOpportunity.get(split.OpportunityId).ownerId == currentUser.Id))
              ){
                if(PermissionCheck.hasPermission('Can_Delete_Opportunity_Splits')==false){
                    split.addError('You are not authorized to perform operation on Opportunity Split');
                    system.debug('^^^ User does not have Custom Permission Can_Delete_Opportunity_Splits and is not the owner of the ' + (ConvertedFromLead ? 'split' : 'opportunity'));
                    system.debug('    This will lead to \'An internal server error has occurred\' AND it will kill any @future calls');
                }
            }
        }

    }

    public List<Order_Line_Item__c> insertRecordinOLIManager(OpportunitySplit[] pNewpportunitySplit, map<ID, OpportunitySplit> newOpportunitySplitMap){
        if (Personal_Settings__c.getInstance().Trigger_Opportunity_Split__c ==false){
            return null; // If triggers are off, then exit the method
        }
        Map<ID, OpportunitySplit> oppList = new Map<ID, OpportunitySplit>();
        Map<ID,ID> ordMap = new Map<ID,ID>();
        Map<ID, Order__c> ordoppMap = new Map<ID, Order__c>();
        List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
    //    Integer counter = 11;
        List<Order_Line_Item_Manager__c> oLIManagersAdd = new List<Order_Line_Item_Manager__c>();
        For(OpportunitySplit oppSFirst : pNewpportunitySplit){
            oppList.put(oppSFirst.OpportunityId, oppSFirst);
            
        }
        system.debug('check 2 oppList' + oppList);
        if(!oppList.keySet().isEmpty()){
            for(Order__c ord : [Select Id, Opportunity__c,Opportunity__r.Owner.Id, Opportunity__r.OwnerId,Opportunity__r.Owner.Name from Order__c where Opportunity__c IN :oppList.keySet()]){
                system.debug('check 5 ord' + ord);
                system.debug('check 6 ord.Opportunity__r.OwnerId' + ord.Opportunity__r.OwnerId);
                system.debug('check 7 oppList.get(ord.Opportunity__c).SplitOwnerId' + oppList.get(ord.Opportunity__c).SplitOwnerId);
               // if(ord.Opportunity__r.OwnerId != oppList.get(ord.Opportunity__c).SplitOwnerId){
                    ordMap.put(ord.Id,oppList.get(ord.Opportunity__c).SplitOwnerId);
                    system.debug('check running?');
                //}
            }
            system.debug('check 3 ordMap' + ordMap);
            if(!ordMap.keySet().isEmpty()){
                
                for(Order_Line_item__c OLIFirst : [Select Id,Order__c,Order__r.Opportunity__c,Order__r.Opportunity__r.Owner.Name from Order_Line_Item__c where Order__c IN :ordMap.keySet()]){
                    oliList.add(OLIFirst);
                }
            }
        }
        
        String profileName = [Select Name from Profile Where Id  =: userinfo.getProfileId()].Name ;
        system.debug('check 4 oliList' + oliList);
        if(!oliList.isEmpty()){
        OrderLineItemTriggerHelper olihelper = new OrderLineItemTriggerHelper(profileName);
        olihelper.populateSecondOppSplitLookup(oliList);
        }
        
        return null;       
        
     /*   if(!oLIManagersAdd.isEmpty()){
            insert oLIManagersAdd;
        } */

       
       
    //}
    
    /*@author  - Sylvester Agyen (Appirio) - 4/22/16
     *@param   - pOldOpportunitySplit = deleted Opportunity split
     *@purpose - Remove Manager records from Order Line Items associated with opportunity's order when split is deleted
    */
    //public void deleteRecordOLIM(OpportunitySplit[] pOldOpportunitySplit){
    //    //get opportunity id from deleted splits
    //    Set<Id> opportunityIds = new Set<Id>();
    //    Set<Id> userDeleted = new Set<Id>();
    //    List<Order_Line_Item_Manager__c>managersToDelete = new List<Order_Line_Item_Manager__c>();

    //    for(OpportunitySplit oppSplit : pOldOpportunitySplit){
    //        opportunityIds.add(oppSplit.OpportunityId);
    //        userDeleted.add(oppSplit.SplitOwnerId);
    //    }
    //    //get order line items from orders whos opportunity is the same as the opportunity id of the deleted split owner
    //    Map<Id,Order_Line_Item__c>lineItemsList = new Map<Id,Order_Line_Item__c>([Select Id, Order__c, Order__r.Opportunity__c from Order_Line_item__c where Order__r.Opportunity__c IN :opportunityIds]);
    //    //Get OLI Managers from order line items
    //    //Map order line item to order line item manager
    //    Map<Id, List<Order_Line_Item_Manager__c>> mapOrderLineItemToManager = new Map<Id, List<Order_Line_Item_Manager__c>>();
    //    for(Order_Line_Item_Manager__c olim : [Select Id,Manager__c,Sales_Rep_ID__c ,Manager_Hierarchy_Level__c,Order_Line_item__c, Secondary_Sales_Rep__c From Order_Line_Item_Manager__c where Order_Line_item__c IN : lineItemsList.keyset()]){
    //            if(!mapOrderLineItemToManager.containsKey(olim.Order_Line_item__c)){
    //                mapOrderLineItemToManager.put(olim.Order_Line_item__c  ,new List<Order_Line_Item_Manager__c>());
    //            }
    //            mapOrderLineItemToManager.get(olim.Order_Line_item__c).add(olim );
    //    }

    //    //match deleted split owner to manager record
    //    for(Id orderLineItemId : mapOrderLineItemToManager.keyset()){
    //        for(Order_Line_Item_Manager__c olim : mapOrderLineItemToManager.get(orderLineItemId)){
    //            if(userDeleted.contains(olim.Sales_Rep_ID__c)){
    //                managersToDelete.add(olim);
    //            }
    //        }
    //    }

    //    if(managersToDelete.size() > 0){
    //        delete managersToDelete;
    //    }
    //}
/*
    public void deleteRecordOLIM(OpportunitySplit[] pOldOpportunitySplit){
         if (Personal_Settings__c.getInstance().Trigger_Opportunity_Split__c ==false){
            return; // If triggers are off, then exit the method
        }
         Set<ID> userDeleted = new Set<Id>();
         Set<Id> oppList = new Set<Id>();
         Set<Id> oliList = new Set<Id>();
         Set<Id> oliupsert = new Set<Id>();
         Set<Id> olimdelete = new Set<Id>();
         Map<Id, List<Order_Line_Item_Manager__c>> maptoOLIM = new Map<Id, List<Order_Line_Item_Manager__c>>();
         List<Order_Line_Item_Manager__c> olimList = new List<Order_Line_Item_Manager__c>();
         List<Order_Line_Item_Manager__c> olimListupsert = new List<Order_Line_Item_Manager__c>();
         For(OpportunitySplit oppSFirst : pOldOpportunitySplit){
             userDeleted.add(oppSFirst.SplitOwnerId);
             oppList.add(oppSFirst.OpportunityId);
         } 
         For(Order_Line_item__c ordList : [Select Id, Order__c, Order__r.Opportunity__c from Order_Line_item__c where Order__r.Opportunity__c IN :oppList]){
             oliList.add(ordList.Id);
         }
         system.debug('---- oliList'+ oliList);
         if(!userDeleted.isEmpty() && !oliList.isEmpty()){
            system.debug('---- running');
             for(Order_Line_Item_Manager__c olim : [Select Id,Manager__c,Sales_Rep_ID__c ,Manager_Hierarchy_Level__c,Order_Line_item__c, Secondary_Sales_Rep__c From Order_Line_Item_Manager__c where Secondary_Sales_Rep__c = true AND Order_Line_item__c
                                                    IN : oliList order by Manager_Hierarchy_Level__c ]){
                 if(!maptoOLIM.containsKey(olim.Order_Line_item__c)){
                     maptoOLIM.put(olim.Order_Line_item__c  ,new list<Order_Line_Item_Manager__c >());
                 }
                 maptoOLIM.get(olim.Order_Line_item__c).add(olim );
             }
             system.debug('---- maptoOLIM'+ maptoOLIM);
             
             for(Id oliId : maptoOLIM.keySet()){
                 system.debug('---- maptoOLIM.keySet() '+maptoOLIM.keySet());
                 boolean hasDeleted = false;
                 Decimal countofDelete = 11;
                 Decimal deletedlevel = 0;
                 Boolean flag = true;
                 for(Order_Line_Item_Manager__c olim : maptoOLIM.get(oliId )){
                     system.debug('---- maptoOLIM.get(oliId ) '+maptoOLIM.get(oliId ));
                     system.debug('---- userDeleted '+userDeleted);
                     //if(userDeleted.contains(olim.Manager__c)){
                    if(userDeleted.contains(olim.Sales_Rep_ID__c)){
                        system.debug('---- running2');
                         deletedlevel =  olim.Manager_Hierarchy_Level__c;
                     }
                     if(deletedlevel != 0 && (olim.Manager_Hierarchy_Level__c - deletedlevel > 0 && olim.Manager_Hierarchy_Level__c - deletedlevel < 10)){
                         system.debug('---- running3');
                         olimList.add(olim);
                         olimdelete.add(olim.Manager__c);
                     }
                 
                     if(userDeleted.contains(olim.Sales_Rep_ID__c)){
                        system.debug('---- running4');
                        olimList.add(olim);
                        hasDeleted = true;
                        countofDelete = olim.Manager_Hierarchy_Level__c;
                        
                     }
                     else if(hasDeleted && !olimdelete.contains(olim.Manager__c)){
                        system.debug('---- running5');
                         olim.Manager_Hierarchy_Level__c = olim.Manager_Hierarchy_Level__c - 10;
                         if(flag){
                            system.debug('---- running6');
                          olim.Manager_Hierarchy_Level__c = countofDelete ;
                          flag = false;
                         }
                         olimListupsert.add(olim);
                         
                     }
                 }
                 
             }
             
         }
         system.debug('---- olimList'+ olimList);
         if(olimList.size()>0){
             delete olimList;
         }
          if(olimListupsert.size()>0){
             upsert olimListupsert;
         }
     }*/

}