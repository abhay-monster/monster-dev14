public without sharing class OLISalesAdjustmentTriggerHandler extends BaseTriggerHandler{
   final String CLASSNAME = '\n\n**** OLISalesAdjustmentTriggerHandler.METHODNAME()';
   private integer BatchSize = 0;
   private OLISalesAdjustmentTriggerHelper helper;

     public OLISalesAdjustmentTriggerHandler(boolean isExecuting, integer pTriggerSize){ 

        // trigger is executing
        TriggerIsExecuting = isExecuting;

        // set batch size
        BatchSize = pTriggerSize;

        //instantiate the trigger helper
        helper = OLISalesAdjustmentTriggerHelper.NewTriggerHelper();
      }

    public void OnAfterInsert(Order_Line_Item_Sales_Adjustment__c [] pSalesAdjustments, map<Id, Order_Line_Item_Sales_Adjustment__c > pSalesAdjustmentsMap){
      helper.OnAfterInsert(pSalesAdjustments, pSalesAdjustmentsMap);
      //updateOtherFieldsBasedUponSalesAdjustment(pSalesAdjustments, pSalesAdjustmentsMap, null);
    }  
      
    public void OnAfterUpdate(Order_Line_Item_Sales_Adjustment__c [] pSalesAdjustments, map<Id, Order_Line_Item_Sales_Adjustment__c > pSalesAdjustmentsMap, map<ID, Order_Line_Item_Sales_Adjustment__c > pSalesAdjustmentsIdToOldMap){
       helper.OnAfterUpdate(pSalesAdjustments, pSalesAdjustmentsMap, pSalesAdjustmentsIdToOldMap);
       //updateOtherFieldsBasedUponSalesAdjustment(pSalesAdjustments, pSalesAdjustmentsMap, pSalesAdjustmentsIdToOldMap);
     }
   /*
    /*
    * @description A method to update certain fields on the opportunity baesd upon the Sales Adjustment object
    * @author Appirio (Jeff Lescarbeau)
    * @date 12/4/2015
    * @param list of OrderLineItemSalesAdjustment, map of old OrderLineItemSalesAdjustments
    * @returns none
    */   
   /*public void updateOtherFieldsBasedUponSalesAdjustment(Order_Line_Item_Sales_Adjustment__c [] pSalesAdjustments, map<Id,Order_Line_Item_Sales_Adjustment__c> pSalesAdjustmentsMap, map<ID, Order_Line_Item_Sales_Adjustment__c > pSalesAdjustmentsIdToOldMap){  
        
       Map<ID, Order_Line_Item_Sales_Adjustment__c> OLItoupdate = new Map<ID, Order_Line_Item_Sales_Adjustment__c >();
       Map<ID, ID> OLIMap = new Map<ID, ID>();
       Map<ID, Order_Line_Item_Sales_Adjustment__c> opptoupdateone = new Map<ID, Order_Line_Item_Sales_Adjustment__c>();
       
       List<Opportunity> opportunityToUpdate = new List<Opportunity>();
       List<OpportunityLineItem> oppLineItemsToUpdate = new List<OpportunityLineItem>();
       Set<Id> needToUpdateOppOwner = new Set<Id>();
       Set<Id> needToUpdateOppCloseDate = new Set<Id>();
       Set<Id> needToUpdateOLIAmount = new Set<Id>();
       Set<Id> needToUpdateOrderLineItems = new Set<Id>();
       Map<Id,Id> salesAdjustmentToOrderLineItem = new Map<Id,Id>();

       /*
       * There are three values that can be updated on the opportunity based upon this object
       * Opportunity owner, Opportunity Close Date, Opportunity Amount
       * Owner and Close date are very straighforward, the trickier one is amount
       * For amount we need to find the corresponding Opportunity Line Item, based upon the Order Line Item that this 
       * Sales Adjustment is for (they have a relationship) and update the total on tha opportunity Line Item.
       */

     /* for(Order_Line_Item_Sales_Adjustment__c olisa : pSalesAdjustments){
        //start building our Map of Sales Adjustments to Order Line Items, it gets used later on in the opportunity query
        //to get the info we need from the Sales Ajustmnets to upodate hte opportunities / line items
        salesAdjustmentToOrderLineItem.put(olisa.OrderLineItem__c, olisa.Id);
        //first lets see if we are updating or inserting
        Order_Line_Item_Sales_Adjustment__c oldOlisa;
        if(pSalesAdjustmentsIdToOldMap != null) { //if this is null then we are inserting
          oldOlisa = pSalesAdjustmentsIdToOldMap.get(olisa.Id);
        }
          
        //1. Lets check to see if we need to update the Order Line Items
            needToUpdateOrderLineItems.add(olisa.OrderLineItem__c);
               
          

        //1. Lets check to see if we need to update the opportunity owner:
        if(olisa.ADJ_Owner_on_Start_Date__c != null){
          if(oldOlisa != null){
            if(olisa.ADJ_Owner_on_Start_Date__c != oldOlisa.ADJ_Owner_on_Start_Date__c){
              needToUpdateOppOwner.add(olisa.OrderLineItem__c);
            }
          } else{
            needToUpdateOppOwner.add(olisa.OrderLineItem__c);
          }
        }

        //2. Lets check to see if we need to update the opportunity Close date:
        if(olisa.ADJ_Earliest_Product_Start_Date__c != null){
          if(oldOlisa != null){
            if(olisa.ADJ_Earliest_Product_Start_Date__c != oldOlisa.ADJ_Earliest_Product_Start_Date__c){
              needToUpdateOppCloseDate.add(olisa.OrderLineItem__c);
            }
          } else{
            needToUpdateOppCloseDate.add(olisa.OrderLineItem__c);
          }
        }

        //3. Lets check to see if we need to update the Opportunity Line Item's amount
        if(olisa.ADJ_Sales_Credit__c != null){
          if(oldOlisa != null){
            if(olisa.ADJ_Sales_Credit__c != oldOlisa.ADJ_Sales_Credit__c){
              needToUpdateOLIAmount.add(olisa.OrderLineItem__c);
            }
          } else{
            needToUpdateOLIAmount.add(olisa.OrderLineItem__c);
          }
        } 
      }
       
      //Need to get the list of order Line Items related to Order Line Items Sales Adjustments. and update them
      list<Order_Line_Item__c> lstOrderlineItemsToUpdate = new list<Order_Line_Item__c> ();
      Map< Id ,Order_Line_Item__c> mapOrderLI = new Map< Id ,Order_Line_Item__c>([Select Id, 
                                                                                    Earliest_Product_Start_Date__c, 
                                                                                    Sales_Credit__c ,
                                                                                    Owner_on_Start_Date__c ,
                                                                                    Job_Type_based_on_OSD__c,
                                                                                    Sales_Channel_based_on_OSD__c,
                                                                                    Position_Sales_Group_based_on_OSD__c,
                                                                                    Region_based_on_OSD__c ,
                                                                                    Segment_based_on_OSD__c ,
                                                                                    Combined_Region_based_on_OSD__c,
                                                                                    Position_Account_Size_based_on_OSD__c ,
                                                                                    overwritten_by_Adjustment__c
                                                                                    from Order_Line_Item__c where id in :needToUpdateOrderLineItems ]) ;
 
        
       for(Order_Line_Item_Sales_Adjustment__c olisa : pSalesAdjustments){
            Order_Line_Item__c oLI = mapOrderLI.get(olisa.OrderLineItem__c);
            
            oLI.Earliest_Product_Start_Date__c =olisa.ADJ_Earliest_Product_Start_Date__c;
            oLI.Owner_on_Start_Date__c =olisa.ADJ_Owner_on_Start_Date__c ;
            oLI.Job_Type_based_on_OSD__c=olisa.ADJ_Job_Type__c;
            oLI.Sales_Channel_based_on_OSD__c =olisa.ADJ_Position_Sales_Channel__c;
            oLI.Position_Sales_Group_based_on_OSD__c =olisa.ADJ_Position_Sales_Group__c;
            oLI.Region_based_on_OSD__c =olisa.ADJ_User_Position_Region__c ;
            oLI.Segment_based_on_OSD__c =olisa.ADJ_Segment__c ;
            oLI.Combined_Region_based_on_OSD__c =olisa.ADJ_Combined_Region__c;
            oLI.Position_Account_Size_based_on_OSD__c =olisa.ADJ_Position_Account_Size__c ;
            oLI.Sales_Credit__c=olisa.ADJ_Sales_Credit__c;
            oLI.overwritten_by_Adjustment__c = true;
            /*
            oLI.Hierarchy_Manager1_New__c=olisa.ADJ_Hierarchy_Manager1__c;
            oLI.Hierarchy_Manager2_New__c =olisa.ADJ_Hierarchy_Manager2__c;
            oLI.Hierarchy_Manager3_New__c =olisa.ADJ_Hierarchy_Manager3__c;
            oLI.Hierarchy_Manager4_New__c =olisa.ADJ_Hierarchy_Manager4__c;
            oLI.Hierarchy_Manager5_New__c =olisa.ADJ_Hierarchy_Manager5__c;
            oLI.Hierarchy_Manager6_New__c =olisa.ADJ_Hierarchy_Manager6__c;
            oLI.Hierarchy_Manager7_New__c =olisa.ADJ_Hierarchy_Manager7__c;
            oLI.Hierarchy_Manager8_New__c =olisa.ADJ_Hierarchy_Manager8__c;
            oLI.Hierarchy_Manager9_New__c =olisa.ADJ_Hierarchy_Manager9__c;
            oLI.Hierarchy_Manager10_New__c =olisa.ADJ_Hierarchy_Manager10__c;
           */
         /*   lstOrderlineItemsToUpdate.add(oLI);
        }

      
      //Need to get the list of Opportunity Line Items related to Order Line Items. and update their totals
      for(OpportunityLineItem oppLI : [Select Id, TotalPrice, Order_Line_Item_Custom__c from OpportunityLineItem where Order_Line_Item_Custom__c in :needToUpdateOLIAmount ]){
        oppLI.TotalPrice = pSalesAdjustmentsMap.get(salesAdjustmentToOrderLineItem.get(oppLI.Order_Line_Item_Custom__c)).ADJ_Sales_Credit__c;
        oppLineItemsToUpdate.add(oppLI);
      }

      //Need to get the list of Opportunities (based upon order Line item) and update their values as needed (close date and owner)
      for(Order_Line_Item__c orderLI : [Select Id, Order__r.Opportunity__c, Order__r.Opportunity__r.ActualCloseDate__c, Order__r.Opportunity__r.OwnerId 
                                      from Order_Line_Item__c where Id in :needToUpdateOppCloseDate OR Id in :needToUpdateOppOwner ]){
        Opportunity updatedOpp = new Opportunity(Id= orderLi.Order__r.Opportunity__c);

        //Lets check to see if we need to update the Owner of the opportunity
        if(needToUpdateOppOwner.contains(orderLI.Id)){
          updatedOpp.OwnerId = pSalesAdjustmentsMap.get(salesAdjustmentToOrderLineItem.get(orderLI.Id)).ADJ_Owner_on_Start_Date__c;
        }

        //Lets check to see if we need to update the Close Date
        if(needToUpdateOppCloseDate.contains(orderLI.Id)){
          updatedOpp.CloseDate = pSalesAdjustmentsMap.get(salesAdjustmentToOrderLineItem.get(orderLI.Id)).ADJ_Earliest_Product_Start_Date__c;
        }

        opportunityToUpdate.add(updatedOpp);
      }
       
      //update the line items first, if any
      if(lstOrderlineItemsToUpdate.size() > 0){
        update lstOrderlineItemsToUpdate;
      }
       

      //update the line items first, if any
      if(oppLineItemsToUpdate.size() > 0){
        update oppLineItemsToUpdate;
      }

      //update the opportunities now, if any
      if(opportunityToUpdate.size() > 0){
        update opportunityToUpdate;
      }
    }*/
}