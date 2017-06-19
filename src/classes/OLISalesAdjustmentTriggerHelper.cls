/*************************************************************************************************************
* Class : OLISalesAdjustmentTriggerHelper
* @author Jeff Lescarbeau
* @CreatedDate  : April 11 2016
* @Purpose: Helper class for the OLI Sales Adjustments
***************************************************************************************************************/
public without sharing class OLISalesAdjustmentTriggerHelper {
    final String CLASSNAME = '\n\n**** OLISalesAdjustmentTriggerHelper .METHODNAME()';

/*
** @author : Appirio
** @date : 04/11/2016
** @description : this method is the class constructor
** @paramaters : none
** @returns : OLISalesAdjustmentTriggerHelper
*/
    public static OLISalesAdjustmentTriggerHelper NewTriggerHelper(){

        OLISalesAdjustmentTriggerHelper newHelper = new OLISalesAdjustmentTriggerHelper();
        return newHelper;
    } 

/*
** @author : Appirio
** @date : 04/11/2016
** @description : this method is the class constructor
** @paramaters : none
** @returns : nothing
*/
    private OLISalesAdjustmentTriggerHelper() {
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OLISalesAdjustmentTriggerHelper Constructor');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
    }

    public void OnAfterInsert(List<Order_Line_Item_Sales_Adjustment__c> pSalesAdjustments, map<Id, Order_Line_Item_Sales_Adjustment__c > pSalesAdjustmentsMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        updateOtherFieldsBasedUponSalesAdjustment(pSalesAdjustments,pSalesAdjustmentsMap,null);
    }

    public void OnAfterUpdate(List<Order_Line_Item_Sales_Adjustment__c> pSalesAdjustments, map<Id, Order_Line_Item_Sales_Adjustment__c > pSalesAdjustmentsMap, map<ID, Order_Line_Item_Sales_Adjustment__c > pSalesAdjustmentsIdToOldMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));   

        updateOtherFieldsBasedUponSalesAdjustment(pSalesAdjustments, pSalesAdjustmentsMap, pSalesAdjustmentsIdToOldMap);
    }

     /*
     * @description A method to update certain fields on the opportunity baesd upon the Sales Adjustment object
     * @author Appirio (Jeff Lescarbeau)
     * @date 12/4/2015
     * @param list of OrderLineItemSalesAdjustment, map of old OrderLineItemSalesAdjustments
     * @returns none
     */   
    public void updateOtherFieldsBasedUponSalesAdjustment(Order_Line_Item_Sales_Adjustment__c [] pSalesAdjustments, map<Id,Order_Line_Item_Sales_Adjustment__c> pSalesAdjustmentsMap, map<ID, Order_Line_Item_Sales_Adjustment__c > pSalesAdjustmentsIdToOldMap){  
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateOtherFieldsBasedUponSalesAdjustment');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));   
        
        Set<Opportunity> opportunityToUpdate = new Set<Opportunity>();
        List<OpportunityLineItem> oppLineItemsToUpdate = new List<OpportunityLineItem>();
        Set<Id> needToUpdateOppOwner = new Set<Id>();
        Set<Id> needToUpdateOppCloseDate = new Set<Id>();
        Set<Id> needToUpdateOLIAmount = new Set<Id>();
        //Set<Id> oliToQuery = new Set<Id>();
        Map<Id,Id> salesAdjustmentToOrderLineItem = new Map<Id,Id>();
        Map<Id,SalesAdjustmentWrapper> adjustmentMap = new Map<Id,SalesAdjustmentWrapper>();

        /*
        * There are three values that can be updated on the opportunity based upon this object
        * Opportunity owner, Opportunity Close Date, Opportunity Amount
        * Owner and Close date are very straighforward, the trickier one is amount
        * For amount we need to find the corresponding Opportunity Line Item, based upon the Order Line Item that this 
        * Sales Adjustment is for (they have a relationship) and update the total on tha opportunity Line Item.
        */

        for(Order_Line_Item_Sales_Adjustment__c olisa : pSalesAdjustments){
            //start building our Map of Sales Adjustments to Order Line Items, it gets used later on in the opportunity query
            //to get the info we need from the Sales Ajustmnets to upodate hte opportunities / line items
            salesAdjustmentToOrderLineItem.put(olisa.OrderLineItem__c, olisa.Id);
            //first lets see if we are updating or inserting
            Order_Line_Item_Sales_Adjustment__c oldOlisa;
            SalesAdjustmentWrapper currAdjustment = new SalesAdjustmentWrapper(olisa);
            SalesAdjustmentWrapper prevAdjustment;
            adjustmentMap.put(currAdjustment.adjustmentId,currAdjustment);

            if(pSalesAdjustmentsIdToOldMap != null) { //if this is null then we are inserting
                //oldOlisa = pSalesAdjustmentsIdToOldMap.get(olisa.Id);
                prevAdjustment = new SalesAdjustmentWrapper(pSalesAdjustmentsIdToOldMap.get(olisa.Id));
            }
           
            //Need to query all the order line items
            //oliToQuery.add(currAdjustment.oliId);
                
            //1. Lets check to see if we need to update the opportunity owner:
            if(currAdjustment.ownerId != null){
                if(prevAdjustment != null){
                    if(currAdjustment.OwnerId != prevAdjustment.OwnerId){
                        currAdjustment.updateOppOwner = true;
                        needToUpdateOppOwner.add(currAdjustment.oliId);
                    }
                } else{
                    currAdjustment.updateOppOwner = true;
                    needToUpdateOppOwner.add(currAdjustment.oliId);
                }
            }

            //2. Lets check to see if we need to update the opportunity Close date:
            if(currAdjustment.earliestProductStartDate != null){
                if(prevAdjustment != null){
                    if(currAdjustment.earliestProductStartDate != prevAdjustment.earliestProductStartDate){
                        currAdjustment.updateOppCloseDate = true;
                        needToUpdateOppCloseDate.add(currAdjustment.oliId);
                    }
                } else{
                    currAdjustment.updateOppCloseDate = true;
                    needToUpdateOppCloseDate.add(currAdjustment.oliId);
                }
            }

            //3. Lets check to see if we need to update the Opportunity Line Item's amount
            if(currAdjustment.salesCredit != null){
                if(prevAdjustment != null){
                    if(currAdjustment.salesCredit != prevAdjustment.salesCredit){
                        currAdjustment.updateOLIAmount = true;
                        needToUpdateOLIAmount.add(currAdjustment.oliId);
                    }   
                } else{
                    currAdjustment.updateOLIAmount = true;
                    needToUpdateOLIAmount.add(currAdjustment.oliId);
                }
            } 
        }
        
        //Need to get the list of order Line Items related to Order Line Items Sales Adjustments. and update them
        list<Order_Line_Item__c> lstOrderlineItemsToUpdate = new list<Order_Line_Item__c>();
        /*Map< Id ,Order_Line_Item__c> mapOrderLI = new Map< Id ,Order_Line_Item__c>([Select Id, 
                                                                                        Earliest_Product_Start_Date__c, 
                                                                                        Sales_Credit__c ,
                                                                                        Owner_on_Start_Date__c ,
                                                                                        Job_Type_based_on_OSD__c,
                                                                                        Sales_Channel_based_on_OSD__c,
                                                                                        Position_Sales_Group_based_on_OSD__c,
                                                                                        Region_based_on_OSD__c ,
                                                                                        Segment_based_on_OSD__c ,
                                                                                        Combined_Region_based_on_OSD__c,
                                                                                        Position_Account_Size_based_on_OSD__c,
                                                                                        Overwritten_by_Adjustment__c
                                                                                        FROM Order_Line_Item__c where id in :oliToQuery ]) ;*/
    
        //First we update all the relevent Order Line Item fields 
        for(SalesAdjustmentWrapper adjustment : adjustmentMap.values()){
             Order_Line_Item__c oLI = new Order_Line_Item__c(Id=adjustment.oliId);
             Order_Line_Item_Sales_Adjustment__c olisa = adjustment.adjustment;
             oLI.Prevent_Manager_Hierachy_Calculations__c = false;
            if(olisa.ADJ_Hierarchy_Manager1__c != null)
                oLI.Prevent_Manager_Hierachy_Calculations__c = true;
            if(olisa.ADJ_Hierarchy_Manager10__c != null)
                oLI.Prevent_Manager_Hierachy_Calculations__c = true;
            if(olisa.ADJ_Hierarchy_Manager2__c != null)
                oLI.Prevent_Manager_Hierachy_Calculations__c = true;
            if(olisa.ADJ_Hierarchy_Manager3__c != null)
                oLI.Prevent_Manager_Hierachy_Calculations__c = true;
            if(olisa.ADJ_Hierarchy_Manager4__c != null)
                oLI.Prevent_Manager_Hierachy_Calculations__c = true;
            if(olisa.ADJ_Hierarchy_Manager5__c != null)
                oLI.Prevent_Manager_Hierachy_Calculations__c = true;
            if(olisa.ADJ_Hierarchy_Manager6__c != null)
                oLI.Prevent_Manager_Hierachy_Calculations__c = true;
            if(olisa.ADJ_Hierarchy_Manager7__c != null)
                oLI.Prevent_Manager_Hierachy_Calculations__c = true;
            if(olisa.ADJ_Hierarchy_Manager8__c != null)
                oLI.Prevent_Manager_Hierachy_Calculations__c = true;
            if(olisa.ADJ_Hierarchy_Manager9__c != null)
                oLI.Prevent_Manager_Hierachy_Calculations__c = true;
            if(oLI.Prevent_Manager_Hierachy_Calculations__c){
                oLI.Hierarchy_Manager1_New__c = olisa.ADJ_Hierarchy_Manager1__c;
                oLI.Hierarchy_Manager2_New__c = olisa.ADJ_Hierarchy_Manager2__c;
                oLI.Hierarchy_Manager3_New__c = olisa.ADJ_Hierarchy_Manager3__c;
                oLI.Hierarchy_Manager4_New__c = olisa.ADJ_Hierarchy_Manager4__c;
                oLI.Hierarchy_Manager5_New__c = olisa.ADJ_Hierarchy_Manager5__c;
                oLI.Hierarchy_Manager6_New__c = olisa.ADJ_Hierarchy_Manager6__c;
                oLI.Hierarchy_Manager7_New__c = olisa.ADJ_Hierarchy_Manager7__c;
                oLI.Hierarchy_Manager8_New__c = olisa.ADJ_Hierarchy_Manager8__c;
                oLI.Hierarchy_Manager9_New__c = olisa.ADJ_Hierarchy_Manager9__c;
                oLI.Hierarchy_Manager10_New__c = olisa.ADJ_Hierarchy_Manager10__c;
            }
             if(olisa.ADJ_Earliest_Product_Start_Date__c != null)
                oLI.Earliest_Product_Start_Date__c =olisa.ADJ_Earliest_Product_Start_Date__c;
             if(String.isNotBlank(olisa.ADJ_Owner_on_Start_Date__c) )
                oLI.Owner_on_Start_Date__c =olisa.ADJ_Owner_on_Start_Date__c ;
             if(String.isNotBlank(olisa.ADJ_Job_Type__c) )
                oLI.Job_Type_based_on_OSD__c=olisa.ADJ_Job_Type__c;
             if(String.isNotBlank(olisa.ADJ_Position_Sales_Channel__c ) )
                oLI.Sales_Channel_based_on_OSD__c =olisa.ADJ_Position_Sales_Channel__c;
             if(String.isNotBlank(olisa.ADJ_Position_Sales_Group__c ) )
                oLI.Position_Sales_Group_based_on_OSD__c =olisa.ADJ_Position_Sales_Group__c;
             if(String.isNotBlank(olisa.ADJ_User_Position_Region__c ) )
                oLI.Region_based_on_OSD__c =olisa.ADJ_User_Position_Region__c ;
             if(String.isNotBlank(olisa.ADJ_Segment__c ))
                oLI.Segment_based_on_OSD__c =olisa.ADJ_Segment__c ;
             if(String.isNotBlank(olisa.ADJ_Combined_Region__c) )
                oLI.Combined_Region_based_on_OSD__c =olisa.ADJ_Combined_Region__c;
             if(String.isNotBlank(olisa.ADJ_Position_Account_Size__c ) )
                oLI.Position_Account_Size_based_on_OSD__c =olisa.ADJ_Position_Account_Size__c ;
             if(olisa.ADJ_Sales_Credit__c != null )
                oLI.Sales_Credit__c=olisa.ADJ_Sales_Credit__c;
             if(String.isNotBlank(olisa.ADJ_Organization__c))
                oLi.Organization_based_on_OSD__c = olisa.ADJ_Organization__c;
             if(String.isNotBlank(olisa.ADJ_Quota_Type__c))
                oLI.Quota_Type__c = olisa.ADJ_Quota_Type__c;
             if(String.isNotBlank(olisa.ADJ_Region_Group__c ))
                 oLI.Region_Group_based_on_OSD__c = olisa.ADJ_Region_Group__c;
             oLI.overwritten_by_Adjustment__c = true;
             
             lstOrderlineItemsToUpdate.add(oLI);
        }       

       
        //Need to get the list of Opportunity Line Items related to Order Line Items. and update their totals
        for(OpportunityLineItem oppLI : [Select Id, TotalPrice, Order_Line_Item_Custom__c from OpportunityLineItem where Order_Line_Item_Custom__c in :needToUpdateOLIAmount ]){
            SalesAdjustmentWrapper adjustmentWrap = adjustmentMap.get(salesAdjustmentToOrderLineItem.get(oppLI.Order_Line_Item_Custom__c));
            //oppLI.TotalPrice = adjustmentMap.get(salesAdjustmentToOrderLineItem.get(oppLI.Order_Line_Item_Custom__c)).adjustment.ADJ_Sales_Credit__c;
            oppLI.TotalPrice = adjustmentWrap.salesCredit;
            oppLineItemsToUpdate.add(oppLI);
        }

        //Need to get the list of Opportunities (based upon order Line item) and update their values as needed (close date and owner)
        for(Order_Line_Item__c orderLI : [Select Id, Order__r.Opportunity__c, Order__r.Opportunity__r.ActualCloseDate__c, Order__r.Opportunity__r.OwnerId 
                                       from Order_Line_Item__c where Id in :needToUpdateOppCloseDate OR Id in :needToUpdateOppOwner ]){
            if(orderLi.Order__r.Opportunity__c != null){
            Opportunity updatedOpp = new Opportunity(Id= orderLi.Order__r.Opportunity__c);

            SalesAdjustmentWrapper adjustmentWrap = adjustmentMap.get(salesAdjustmentToOrderLineItem.get(orderLI.Id));
            adjustmentWrap.oppId = updatedOpp.Id;
            //Lets check to see if we need to update the Owner of the opportunity
            if(adjustmentWrap.updateOppOwner){
                updatedOpp.OwnerId = adjustmentWrap.OwnerId;
                adjustmentWrap.oldOppOwner = orderLI.Order__r.Opportunity__r.OwnerId; //need this to clean up the 
            }

            //Lets check to see if we need to update the Close Date
            if(adjustmentWrap.updateOppCloseDate){
                updatedOpp.Bypass_Close_Date_Validation__c = true;
                updatedOpp.CloseDate = adjustmentWrap.earliestProductStartDate;
            }

            opportunityToUpdate.add(updatedOpp);
            }
        }
        
        //update the line items first, if any
        if(lstOrderlineItemsToUpdate.size() > 0){
            update lstOrderlineItemsToUpdate;
        }
        

        //update the line items first, if any
        if(oppLineItemsToUpdate.size() > 0){
        
            system.debug('oppLineItemsToUpdatesize '+oppLineItemsToUpdate.size());
            update oppLineItemsToUpdate;
        }

        //update the opportunities now, if any
        if(opportunityToUpdate.size() > 0){

            system.debug('opptoupdatesize '+opportunityToUpdate.size());
           // system.assert(false , opportunityToUpdate);
            update new List<Opportunity>(opportunityToUpdate);
            cleanUpOpportunitySplits(adjustmentMap);
        }
    }


    /*
     * @description A method that cleans up the Opportunity Splits for updated opportunity owners
                    We need to delete the split for the old opportunity owner and update the 
                    split for the new opportunity owner to have the old's value
     * @author Appirio (Jeff Lescarbeau)
     * @date 4-11-2016
     * @param wrapper map of Sales Adjustmnet Wrapper
     * @returns none
     */ 
    private void cleanUpOpportunitySplits(Map<Id,SalesAdjustmentWrapper> pAdjustmentMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','cleanUpOpportunitySplits');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        List<OpportunitySplit> splitsToDelete = new List<OpportunitySplit>();
        List<OpportunitySplit> splitsToUpdate = new List<OpportunitySplit>();

        //get a list of all the splits we need to query for first
        //Set<Id> oppsToQuery = new Set<Id>();
        //List<SalesAdjustmentWrapper> wrappers = new List<SalesAdjustmentWrapper>();
        Map<Id,SalesAdjustmentWrapper> oppToAdjustment = new Map<Id,SalesAdjustmentWrapper>();
        Map<Id,Map<Id,OpportunitySplit>> opportunityWithSplits = new Map<Id,Map<Id,OpportunitySplit>>();

        for(SalesAdjustmentWrapper adjWrap : pAdjustmentMap.values()){
            if(adjWrap.updateOppOwner){
                oppToAdjustment.put(adjWrap.oppId,adjWrap);
            }
        }

        //Sylvester Agyen (Appirio) 4/19/16 - Handle extra opportunity split types
        List<OpportunitySplitType>oppSplitType = [select id from OpportunitySplitType where MasterLabel='Revenue'];
        system.debug('oppSplitType '+oppSplitType);

        //query for our Opportunity Splits and construct our Map
        for(OpportunitySplit oppSplit : [Select OpportunityId, SplitOwnerId, Split, SplitPercentage FROM OpportunitySplit Where OpportunityId in :oppToAdjustment.keySet() AND SplitTypeId=:oppSplitType[0].id  ]){
            system.debug('oppSplit '+oppSplit);
            if(opportunityWithSplits.get(oppSplit.OpportunityId) == null){
                opportunityWithSplits.put(oppSplit.OpportunityId, new Map<Id,OpportunitySplit>());
            }
            opportunityWithSplits.get(oppSplit.OpportunityId).put(oppSplit.SplitOwnerId,oppSplit);
        }
        system.debug('opportunityWithSplits '+opportunityWithSplits);

        //now that we have all our details, we can make our updates
        //We will take the SplitAmount from the previousOwner, and update the new
        //opp owner's split with that amount.  Then we will set the previous owner's amount
        //to 0
        for(Id oppId : opportunityWithSplits.keySet()){
            SalesAdjustmentWrapper adjWrap = oppToAdjustment.get(oppId);

            //added check to see if the owner has actually changed. if the owner
            //has not changed we do not need to update the splits
            Double ownerSplitPercentage;
            OpportunitySplit newOwnersSplit = null;
            if(adjWrap.oldOppOwner != adjWrap.OwnerId){
                for(Id splitId : opportunityWithSplits.get(oppId).keySet()){
                    OpportunitySplit currSplit = opportunityWithSplits.get(oppId).get(splitId);
                    system.debug('currSplit '+currSplit);
                    //this means we have found the old owner Split
                    //so we record the split percentage and 
                    //remove old owner from split
                    if(adjWrap.oldOppOwner == currSplit.SplitOwnerId){
                        ownerSplitPercentage = currSplit.SplitPercentage;
                        currSplit.SplitPercentage = 0;
                        splitsToUpdate.add(currSplit);

                        splitsToDelete.add(currSplit);
                    } else if(adjWrap.OwnerId == currSplit.SplitOwnerId){
                        //if we are in here it's because we have found the new owners
                        //split - we update this after we have gone through all the splits 
                        //for this opportunity
                        newOwnersSplit = currSplit;
                        system.debug('newOwnersSplit '+newOwnersSplit);
                    }
                }
            }
 

            //now we need to update the new owners split that to be equal to the previous owners split
            if(newOwnersSplit != null && ownerSplitPercentage != null){
                newOwnersSplit.SplitPercentage = ownerSplitPercentage;
                splitsToUpdate.add(newOwnersSplit);
            }
        }


        //now lets update the splits if we have any
        if(!splitsToUpdate.isEmpty()){
            system.debug('splitsToUpdate '+splitsToUpdate);
            update splitsToUpdate;
            

        }
        //remove previous owner from split
        if(!splitsToDelete.isEmpty()){
            system.debug('splitsToDelete '+splitsToDelete);
            delete splitsToDelete;
            //OpportunitySplitTriggerHandler handler = new OpportunitySplitTriggerHandler(true,splitsToUpdate.size());
            //handler.deleteRecordOLIM(splitsToDelete);
        }

        
    }


    /*
     * @description a class to hold all the relevant information for a Sales Adjustment
     * @author Appirio (Jeff Lescarbeau)
     * @date 4-12-16
    */   
    private class SalesAdjustmentWrapper{
        public Order_Line_Item_Sales_Adjustment__c adjustment;
        public Id OwnerId;
        public Id oldOppOwner;
        public Id oliId;
        public Id adjustmentId;
        public Id oppId;
        public Date earliestProductStartDate;
        public Decimal salesCredit;
        public Boolean updateOppOwner = false;
        public Boolean updateOppCloseDate = false;
        public Boolean updateOLIAmount = false;

        public SalesAdjustmentWrapper(Order_Line_Item_Sales_Adjustment__c pSalesAdjustment){
            this.adjustment = pSalesAdjustment;
            this.adjustmentId = pSalesAdjustment.Id;
            this.OwnerId = pSalesAdjustment.ADJ_Owner_on_Start_Date__c;
            this.oliId = pSalesAdjustment.OrderLineItem__c;
            this.earliestProductStartDate = pSalesAdjustment.ADJ_Earliest_Product_Start_Date__c;
            this.salesCredit = pSalesAdjustment.ADJ_Sales_Credit__c;
        }

    }
}