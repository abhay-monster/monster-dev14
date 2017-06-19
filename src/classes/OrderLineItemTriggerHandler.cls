public with sharing class OrderLineItemTriggerHandler extends BaseTriggerHandler{

    final String CLASSNAME = '\n\n**** OrderLineItemTriggerHandler.METHODNAME()';
    private integer BatchSize = 0;
    public static Integer RunCount = 0;
    public static Boolean ExecuteTriggers = true;
    public static Boolean ExecuteUpdate = true;
    public static Boolean ExecuteReportingUpdate = false;

    public static Boolean ExecuteSynch = true;
    OrderLineItemTriggerHelper helper;

   /*
** @author : Cloud Sherpas Inc.
** @date : 04/09/2014
** @description : the class constructor method
** @paramaters : a Boolean value indicating if a trigger is executing or not, an Integer value indicating the number of records in the batch/list
** @returns : nothing
** @sample call : AccountTriggerHandler handler = new AccountTriggerHandler(Trigger.isExecuting, Trigger.size);
*/
    public OrderLineItemTriggerHandler(boolean isExecuting, integer pTriggerSize){

        // trigger is executing
        TriggerIsExecuting = isExecuting;

        // set batch size
        BatchSize = pTriggerSize;


        // intantiate new trigger helper
        helper = OrderLineItemTriggerHelper.NewTriggerHelper('');
        /*
            note - developer may want to create new or extent the base helper class specific to an sObject (i.e. AccountTriggerHelper)
        */
    }
/*
** @author : Cloud Sherpas Inc.
** @date : 04/09/2014
** @description :  this method handles the 'before insert' event for the trigger; it's purpose is to ...
** @paramaters : an array of Order_Line_Item__c objects
** @returns : nothing
*/
    public void OnBeforeInsert(Order_Line_Item__c[] pNewOrderLineItem){
        system.debug('ssssss 1'+pNewOrderLineItem[0].startDate__c + 'end '+pNewOrderLineItem[0].endDate__c);

        if (Personal_Settings__c.getInstance().Trigger_Order__c ==false){
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        if(UserInfo.getName() == 'Integration MAPP'){
            for(Order_Line_Item__c oli : pNewOrderLineItem){
                System.debug('^^^ MAPP Insert Order_Line_Item__c ' + oli);
            }
            helper.fixEcomm(pNewOrderLineItem);
        }

        if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
            //set up the list of line items in the helper
            helper.OrderLineItemList = pNewOrderLineItem;
            helper.ResetQueries();
            //helper.populateOwnerOnStartDateonInsert(pNewOrderLineItem);
            //helper.populateReportingData(pNewOrderLineItem,null);


            helper.updateOrderFieldsFromMAPP(pNewOrderLineItem);
            helper.MatchProductFromMAPP(pNewOrderLineItem);
            helper.CloseCase(pNewOrderLineItem);  // TKOM S-445214: should this be commented out and handled by matching case routing rule instead??
            helper.PopulateAgencyCommission(pNewOrderLineItem);
            helper.populateProductLineAndPartNumber(pNewOrderLineItem);
            //helper.populateOwnerStartDate(pNewOrderLineItem);
            //helper.populateOrderLineitemField(pNewOrderLineItem);
            helper.populateRevenueShareTypeAndPercent(pNewOrderLineItem);
            //T-420968
            //helper.populatePositionData(pNewOrderLineItem, null);
            //setPostingLocation(pNewOrderLineItem);
            //insertEarliestProductStartDate(pNewOrderLineItem,null);
            helper.updateOrderLineItemXCode(pNewOrderLineItem);
            //helper.populateManagerEmail(pNewOrderLineItem);
            //Jeff moved this method to helper class and into before insert
            //helper.setPartnerRevenueShareOnLineItems(pNewOrderLineItem);  //jf & jl 2/2/16 Duplicates work being done by PopulateAgencyCommission()
            helper.populateOrderLineitemFieldLineItemCurrency(pNewOrderLineItem);
            //helper.populateNetTotalAmount(pNewOrderLineItem,null,null);
            helper.setRebillOrderDates(pNewOrderLineItem);
            if(UserInfo.getName() == 'Integration MAPP'){
                helper.PopulateAptsTaxAmt(pNewOrderLineItem);//AP
            }
            //helper.populateOSDFieldOnLineItem(pNewOrderLineItem);
             //I-185156

            for(Order_Line_Item__c ordln : pNewOrderLineItem) {
                ordln.GrossRemainingCreditAmount__c  = ordln.GrossTotalAmount__c;
                ordln.NetRemainingCreditAmount__c  = ordln.NetTotalAmount__c;
            }

            //helper.populateOrderLineItemsSalesCredit(pNewOrderLineItem);
            //system.assert(false , pNewOrderLineItem);
        }
        system.debug('ssssss 2'+pNewOrderLineItem[0].startDate__c + 'end '+pNewOrderLineItem[0].endDate__c);
        helper.setOrderLineItemStartDateOnInsert(pNewOrderLineItem);
        // Populate Non Messaging Available Quantity field on OLI (T-578921) on 20 Feb 2017 by Vikas Menon
        helper.populateNonMessagingAvailableQuantity(pNewOrderLineItem);
    }

    public void OnBeforeDelete(Order_Line_Item__c[] pOldOrderLineItem){
        list<OpportunityLineItem> lstOppLineItems= [SELECT Product2Id ,
                                                               PricebookEntryId ,
                                                               OpportunityId ,
                                                               TotalPrice
                                                        FROM OpportunityLineItem
                                                        where Order_Line_Item_Custom__c IN : pOldOrderLineItem
                                                        AND Proposal_Line_Item__c = null];
            if(lstOppLineItems.size() > 0)
                delete lstOppLineItems;
    }

     /*
    ** @author : Cloud Sherpas Inc.
    ** @date : 04/09/2014
    ** @description :  this method handles the 'after insert' event for the trigger; it's purpose is to ...
    ** @paramaters : an array of Order_Line_Item__c objects
    ** @returns : nothing
    */
    public void OnAfterInsert(Order_Line_Item__c[] pNewOrderLineItem, map<Id, Order_Line_Item__c> pNewOrderLineItemMap){
        system.debug('ssssss 3'+pNewOrderLineItem[0].startDate__c + 'end '+pNewOrderLineItem[0].endDate__c);
        //system.assert(false, 'sadsad');
        if (Personal_Settings__c.getInstance().Trigger_Order__c ==false){
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));


        if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){

            //Set the variables for the trigger handler
            helper.OrderLineItemList = pNewOrderLineItem;
            helper.ResetQueries();
            // S-439187
            helper.updateOpportunity(pNewOrderLineItem);
            //helper.populateSecondOppSplitLookup(pNewOrderLineItem);

            // Set partner Revenue Share on line item - Jeff L commented out 10/12, moved into before code
            //setPartnerRevenueShareOnLineItems(pNewOrderLineItem);
            //setting of QuoteCreated__c flag when an Apptus_proposal is created
            //Commented on June 2014 as per confirmation, we are not updating Parent OLIs
            //helper.SubtractQuantityAndNetPriceToParentLineItem(pNewApttusProposalMap);
            /*
            note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
            and call the methods from handler.
            */
            helper.populateNetTotalAmount(pNewOrderLineItem,null,null);
            helper.CreateRevenueRecognition(pNewOrderLineItem);
            helper.setFinanceOrderTypeAndSequence(pNewOrderLineItem);

            //AP story:3486

            if(UserInfo.getName() == 'Integration MAPP'){
                boolean doNotUpdate = True;
                helper.UpdateXcodeOnOrderLineItem (pNewOrderLineItem,doNotUpdate);
                //helper.PopulateNetPrice(pNewOrderLineItem);
            }

            //helper.EarliestProductStartDate(pNewOrderLineItem, null);
            //AP story:3486
        }
        //Update By Vivek for T-434693
        //I-262375 / S-470803 Jfreese Appirio Revert T-434693 per Matt Keefe
        //helper.updateOptyOwner(pNewOrderLineItem);

        //helper.populateOrderLineItemsSalesCredit(pNewOrderLineItem);

        if(ExecuteSynch){
            helper.syncLineItemsWithOpportunityLineItems(pNewOrderLineItem , pNewOrderLineItemMap);
            ExecuteSynch = false;
        }

        //helper.populateOrderLineItemManagerFields(pNewOrderLineItem, null);

        system.debug('ssssss 4'+pNewOrderLineItem[0].startDate__c + 'end '+pNewOrderLineItem[0].endDate__c);

    }

    /*
** @author : Cloud Sherpas Inc.
** @date : 04/09/2014
** @description :  this method handles the 'after update' event for the trigger; it's purpose is to ...
** @paramaters : an array of Order_Line_Item__c objects
** @returns : nothing
*/
    public void OnAfterUpdate(Order_Line_Item__c[] pOldOrderLineItem, Order_Line_Item__c[] pNewOrderLineItem, map<Id, Order_Line_Item__c> pOldOrderLineItemMap, map<Id, Order_Line_Item__c> pNewOrderLineItemMap){
         system.debug('**sly orderlineItem onafterupdate old'+ pOldOrderLineItem[0]);
         system.debug('**sly orderlineItem onafterupdate new'+ pNewOrderLineItem[0]);

        if (Personal_Settings__c.getInstance().Trigger_Order__c ==false){
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        List<Order_Line_Item__c> tobeProcessedOLI = new List<Order_Line_Item__c>();
        List<Order_Line_Item__c> lineItemsToProcess = new List<Order_Line_Item__c>();

        system.debug('^^^ Runcount=' + Runcount + ', ExecuteUpdate=' + ExecuteUpdate+', pNewOrderLineItem.size()='+pNewOrderLineItem.size());
        if(ExecuteTriggers){
            //helper.populateOrderLineItemManagerFields(pNewOrderLineItem, pOldOrderLineItemMap);
            if(RunCount == 1 || !ExecuteUpdate){
                helper.populateNetTotalAmount(pNewOrderLineItem,pOldOrderLineItemMap,pNewOrderLineItemMap);
                //Special call to syncLineItemsWithOpportunityLineItems for when the OLI.Earliest_Product_Start_Date__c is updated after verification
                if(ExecuteSynch){
                    for(Order_Line_Item__c oli : pNewOrderLineItem){
                        if(oli.Earliest_Product_Start_Date__c != pOldOrderLineItemMap.get(oli.Id).Earliest_Product_Start_Date__c){
                            lineItemsToProcess.add(oli);
                        }
                    }
                    system.debug('lineItemsToProcess(1) '+lineItemsToProcess);
                    if(!lineItemsToProcess.isEmpty()){
                        helper.syncLineItemsWithOpportunityLineItems(lineItemsToProcess , pOldOrderLineItemMap);
                        ExecuteSynch = false;
                    }
                }
                system.debug('^^^ Halting OnAfterUpdate because Runcount=' + Runcount + ', ExecuteUpdate=' + ExecuteUpdate);
                return;
            }

            //Set the variables for the trigger handler
            helper.OrderLineItemList = pNewOrderLineItem;
            helper.ResetQueries();
            helper.CreateRevenueRecognition(pNewOrderLineItem);
            //helper.EarliestProductStartDate(pNewOrderLineItem, pOldOrderLineItemMap);

            RunCount ++;

            for(Order_Line_Item__c oli : pNewOrderLineItem){
                if(oli.Owner_on_Start_Date__c != pOldOrderLineItemMap.get(oli.Id).Owner_on_Start_Date__c)
                    tobeProcessedOLI.add(oli);

           }

            //Update By Vivek for T-434693
            //I-182342 AP 09/29
            //I-262375 / S-470803 Jfreese Appirio Revert T-434693 per Matt Keefe
            /*if(UserInfo.getName() != 'Integration MAPP'){
                helper.updateOptyOwner(tobeProcessedOLI);
                //helper.PopulateNetPrice(pNewOrderLineItem);
            }*/
            system.debug('ExecuteSynch '+ExecuteSynch+', CreditRequestTriggerHandler.CreateOrdersAutomatically='+CreditRequestTriggerHandler.CreateOrdersAutomatically);
            if(ExecuteSynch){
                for(Order_Line_Item__c oli : pNewOrderLineItem){
                    if(oli.ProposalLineItem__c != pOldOrderLineItemMap.get(oli.Id).ProposalLineItem__c
                        ||oli.NetTotalAmount__c != pOldOrderLineItemMap.get(oli.Id).NetTotalAmount__c
                        ||oli.GrossTotalAmount__c != pOldOrderLineItemMap.get(oli.Id).GrossTotalAmount__c
                        ||oli.Quantity2__c != pOldOrderLineItemMap.get(oli.Id).Quantity2__c
                        ||oli.Earliest_Product_Start_Date__c != pOldOrderLineItemMap.get(oli.Id).Earliest_Product_Start_Date__c){
                        lineItemsToProcess.add(oli);
                    }
                    //JFreese Appirio 3/2/17 S-456572
                    if(CreditRequestTriggerHandler.CreateOrdersAutomatically == true){
                        //Not changing the OLI but want to synch it with the new credit opportunity
                        lineItemsToProcess.add(oli);
                    }

                }
                system.debug('lineItemsToProcess(2) '+lineItemsToProcess);
                if(!lineItemsToProcess.isEmpty()){
                    helper.syncLineItemsWithOpportunityLineItems(lineItemsToProcess , pOldOrderLineItemMap);
                    ExecuteSynch = false;
                }
            }

            helper.setFinanceOrderTypeAndSequence(pNewOrderLineItem);

            system.debug('**sly orderlineItem onafterupdate END old'+ pOldOrderLineItem[0]);
            system.debug('**sly orderlineItem onafterupdate END new'+ pNewOrderLineItem[0]);
        }
    }
/*
** @author : Cloud Sherpas Inc.
** @date : 04/09/2014
** @description :  this method handles the 'before update' event for the trigger; it's purpose is to ...
** @paramaters : an array of Order_Line_Item__c objects
** @returns : nothing
*/
    public void OnBeforeUpdate(Order_Line_Item__c[] pOldOrderLineItem, Order_Line_Item__c[] pNewOrderLineItem, map<Id, Order_Line_Item__c> pOldOrderLineItemMap, map<Id, Order_Line_Item__c> pNewOrderLineItemMap){

        system.debug('**sly orderlineItem beforeupdate old'+ pOldOrderLineItem[0]);
         system.debug('**sly orderlineItem beforeupdate new'+ pNewOrderLineItem[0]);
        if (Personal_Settings__c.getInstance().Trigger_Order__c ==false){
            return; // If triggers are off, then exit the method
        }

        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        if(RunCount == 1 || !ExecuteUpdate){
            //have this extra condition if we just want to fire the reporting updates (useful for webAdmin API updates)
            if(ExecuteReportingUpdate){
                 //Set the variables for the trigger handler
                helper.OrderLineItemList = pNewOrderLineItem;
                helper.ResetQueries();
                helper.populateReportingData(pNewOrderLineItem, pOldOrderLineItemMap);
            }
            helper.populateOrderLineItemsSalesCredit(pNewOrderLineItem);

            return;
        }

        if(ExecuteTriggers && IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){

            //Set the variables for the trigger handler
            helper.OrderLineItemList = pNewOrderLineItem;
            helper.ResetQueries();
            //setting of QuoteCreated__c flag when an Apptus_proposal is created
            //Commented on June 2014 as per confirmation, we are not updating Parent OLIs
            //helper.SubtractQuantityAndNetPriceToParentLineItem(pNewOrderLineItemMap);
            /*
                note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                       and call the methods from handler.
            */
            helper.updateOrderFieldsFromMAPP(pNewOrderLineItem);
            helper.MatchProductFromMAPP(pNewOrderLineItem);
            helper.PopulateAgencyCommission(pNewOrderLineItem);
             if(UserInfo.getName() == 'Integration MAPP'){
               helper.PopulateNetPrice(pNewOrderLineItem);
            }
            //List<Order_Line_Item__c> listOrderLineItems = new List<Order_Line_Item__c>();
            //List<Order_Line_Item__c> listOrderLineItemsWithNullProposals = new List<Order_Line_Item__c>();

            /*for(Order_Line_Item__c oLI : pNewOrderLineItem ){
                if(pOldOrderLineItemMap.get(oLI.id).ProposalLineItem__c !=  pNewOrderLineItemMap.get(oLI.id).ProposalLineItem__c ) {
                    if(pNewOrderLineItemMap.get(oLI.id).ProposalLineItem__c!= Null)
                        listOrderLineItems.add(oLI);
                    else
                        listOrderLineItemsWithNullProposals.add(oLI);
                }
            }

            if(listOrderLineItemsWithNullProposals.size()>0){
                for(Order_Line_Item__c oLI : listOrderLineItemsWithNullProposals){
                  oLI.Product_family__c = '';
                  oLI.Product_Category__c = '';
                  oLI.Sub_Category__c = '';
                  oLI.Media_Group__c  = '';
                  oLI.Media_Type__c = '';

                }
            }
            if(listOrderLineItems.size() >0)
                populateProductHierarchyFields(listOrderLineItems); */
            //AP story: 3486
            if(UserInfo.getName() == 'Integration MAPP'){
                    boolean doNotUpdate = False;
                    helper.UpdateXcodeOnOrderLineItem (pNewOrderLineItem,doNotUpdate);

            }
            //AP story: 3486

            //helper.populateOwnerStartDate(pNewOrderLineItem);

            //populateManagerEmail(pNewOrderLineItem);
            /*List<Order_Line_Item__c> orderLineToProcess = new List<Order_Line_Item__c>();
            for(Order_Line_Item__c oli : pNewOrderLineItem){

                if(pOldOrderLineItemMap.get(oli.Id).Owner_on_Start_Date__c != oli.Owner_on_Start_Date__c &&  oli.Owner_on_Start_Date__c != null)
                        orderLineToProcess.add(oli);
            }
                System.debug('Before Update');
                System.debug('Size of List'+orderLineToProcess.size());

                if(orderLineToProcess.size() > 0)
                    helper.populateManagerEmail(orderLineToProcess);*/
            //T-420968
            //helper.populatePositionData(pNewOrderLineItem, pOldOrderLineItemMap);
            //Jeff moved this method to helper class and into before insert
            //helper.setPartnerRevenueShareOnLineItems(pNewOrderLineItem); //jf & jl 2/2/16 Duplicates work being done by PopulateAgencyCommission()
            //helper.populateNetTotalAmount(pNewOrderLineItem,pOldOrderLineItemMap,pNewOrderLineItemMap);
            helper.populateReportingData(pNewOrderLineItem, pOldOrderLineItemMap);
            //insertEarliestProductStartDate(pNewOrderLineItem,pOldOrderLineItemMap);

            //helper.populateOSDFieldOnLineItem(pNewOrderLineItem);
            helper.populateOrderLineItemsSalesCredit(pNewOrderLineItem);
        }
    }


    /*
    ** @author : Appirio
    ** @date : 20/08/2015
    ** @description :  T-420962
    ** @paramaters : an array of Order_Line_Item__c objects
    ** @returns : nothing
    */
    /*public void populateProductHierarchyFields(Order_Line_Item__c[] orderLineItems){

        Set<Id> setProposalLineItems = new set<Id>();
        Set<Id> setOrders = new set<Id>();
        For(Order_Line_Item__c oLI : orderLineItems){
            setProposalLineItems.add(oLI.ProposalLineItem__c);
            setOrders.add(oLI.order__c);
        }

        Map<Id ,Apttus_Proposal__Proposal_Line_Item__c> mapProposals;
        Map<Id ,order__c> mapOrders;
        if(setProposalLineItems.size() > 0){
            mapProposals = new Map<Id ,Apttus_Proposal__Proposal_Line_Item__c>([select Product_Family__c,
                                                                                       Product_Cateogry__c ,
                                                                                       Product_SubCategory__c ,
                                                                                       Media_Group__c ,
                                                                                       Media_Type__c
                                                                                 from Apttus_Proposal__Proposal_Line_Item__c
                                                                                 where Id IN :setProposalLineItems]);
           mapOrders = new Map<Id, order__c>([select OrderStatus__c from order__c where Id IN :setOrders]);
           Apttus_Proposal__Proposal_Line_Item__c proposal ;
          For(Order_Line_Item__c oLI : orderLineItems){
              String status = mapOrders.get(oLI.order__c).OrderStatus__c;
              if(status == 'Verified' || status == 'Resubmitted' || status == 'Negated'
                 || status == 'Paid in Full' || status == 'Full' || status == 'Invoiced' || status == 'Closed'){
                  if(mapProposals !=  null && oLI.ProposalLineItem__c != null && mapProposals.containsKey(oLI.ProposalLineItem__c)){
                      proposal = mapProposals.get(oLI.ProposalLineItem__c);
                      if(proposal != null) {
                          oLI.Product_family__c = proposal.Product_Family__c;
                          oLI.Product_Category__c = proposal.Product_Cateogry__c;
                          oLI.Sub_Category__c = proposal.Product_SubCategory__c;
                          oLI.Media_Group__c  = proposal.Media_Group__c ;
                          oLI.Media_Type__c = proposal.Media_Type__c;
                      }
                  }
              }
          }
        }
    } */

//Jeff L Commenting out 8/28 - this logic should be happening inside of LineItemAttributesTriggerHelper updateOrderLineItem
//Method takes array of orderLineItems and will populate teh Posting Location (Posting Country from the Parent Order record)
//This ends up being used in the creation and calculation of Revenue recognition on the Order Line Item (that code is found
//within the OrderLineItemTriggerHelper.CreateRevenueRecognition)
/*    public void setPostingLocation(Order_Line_Item__c[] orderLineItems){
        Set<ID> orderId = new Set<ID>();
        Map<Id,Order__c> orderMap;
        for(Order_Line_Item__c oli : orderLineItems){
            orderId.add(oli.Order__c);
        }

        //Create a map of the parent Orders for the order line items, grab the posting country from theose orders
        //and populate on the child line items
        orderMap = new Map<Id,Order__c>([Select Id, PostingCountry__c from Order__c where Id in :orderId]);
        if(orderMap != null){
            for(Order_Line_Item__c oli : orderLineItems){
                Order__c matchedOrder = orderMap.get(oli.Order__c);
                if(matchedOrder != null){
                    //oli.PostingLocation__c = matchedOrder.PostingCountry__c;
                    //oli.PostingLocation__c = 'Europe';
                }
            }
        }
    }  */

    /*
        Update the Order line item with
   */

//Jeff L moved this logic into the handler
   /*public void updateOrderLineItemXCode(List<Order_Line_Item__c> lineItems){
        set<Id> accIds = new set<Id>();
        set<Id> orderIds = new set<Id>();
        map<string,List<XcodeAccount__c>> mapXcode = new map<string,List<XcodeAccount__c>>();
        List<Order_Line_Item__c> itemsToUpdate = new List<Order_Line_Item__c>();
        map<string,string> mapOrderAcc = new map<string,string>();
        for(Order_Line_Item__c line : lineItems) {
            if(line.order__c != null && (line.Xcode_lkp__c == null || line.Xcode__c == null)) {
              orderIds.add(line.order__c);
            }
        }
        System.debug('===orderIds==='+orderIds);
        for(Order__c o : [Select Id,Account__c from Order__c Where Id IN :orderIds and Account__c != null]){
            mapOrderAcc.put(o.Id, o.Account__c);
        }
        System.debug('===mapOrderAcc==='+mapOrderAcc);
        if(mapOrderAcc.isEmpty()) return;
        for(Order_Line_Item__c line : lineItems){
            if(mapOrderAcc.containsKey(line.order__c)){
                itemsToUpdate.add(line);
            }
        }
        System.debug('===itemsToUpdate==='+itemsToUpdate);
        for(XcodeAccount__c xAcc : [Select Id,Account__c,Xcode__c,Xcode_Name__c from
                                        XcodeAccount__c Where Account__c IN :mapOrderAcc.values()
                                        AND IsPrimary__c = true ]){
                if(!mapXcode.containsKey(xAcc.Account__c)) {
                    mapXcode.put(xAcc.Account__c,new List<XcodeAccount__c>());
                }
                mapXcode.get(xAcc.Account__c).add(xAcc);
        }
        System.debug('===mapXcode==='+mapXcode);
        if(mapXcode.isEmpty()) return;

        for(Order_Line_Item__c line : itemsToUpdate){
            if(mapOrderAcc.containsKey(line.order__c)){
                string accId = mapOrderAcc.get(line.order__c);
                if(accId != null && mapXcode.containsKey(accId)){
                    for(XcodeAccount__c xcode : mapXcode.get(accId)){
                        line.Xcode_lkp__c = xcode.Id;
                        line.Xcode__c = xcode.Xcode_Name__c;
                        System.debug('===Item Set==='+xcode);
                        break;
                    }
                }
            }
        }
 }*/

 /*   Jeff L commented out - moved into handler and into the before insert instead of after
public void setPartnerRevenueShareOnLineItems(Order_Line_Item__c[] orderLineItems){

        List<Order_Line_Item__c> itemsToUpdate = new  List<Order_Line_Item__c>();

        orderLineItems = [Select Id, Order__c,ProductFamily__c,Partner_Revenue_Share__c  from Order_Line_Item__c
                          Where Id IN :orderLineItems];

        set<string> productFamilySet = new Set<string>();
        set<string> siteChannelds = new Set<string>();
        map<string,string> maplineItem = new map<string,string>();
        map<string, string> mapProdFamilyToPartner = new map<string, string>();

        for(Order_Line_Item__c lineItem : orderLineItems) {

            if(lineItem.Order__c != null) {
                maplineItem.put(lineItem.Id, lineItem.Order__c);
            }

            if(lineItem.ProductFamily__c != null){
                productFamilySet.add(lineItem.ProductFamily__c);
            }
        }
        System.debug('@@==productFamilySet===='+productFamilySet);
        System.debug('@@==maplineItem===='+maplineItem);

        map<Id, Order__c> orderMap = new map<Id, Order__c> ([Select Id , Site_Channel_ID__c
                                                            from Order__c Where Id IN :maplineItem.values()]);

        for(Order__c o : orderMap.values()){
            if(o.Site_Channel_ID__c != null){
                siteChannelds.add(o.Site_Channel_ID__c);
            }
        }

        System.debug('@@==siteChannelds===='+siteChannelds);

        for(Partner_Revenue_Share__c partnerRevenueShare : [Select Id, Product_Family__c, SiteChannelID__c from Partner_Revenue_Share__c
                                                  Where Product_Family__c IN :productFamilySet and SiteChannelID__c IN :siteChannelds] ) {

            mapProdFamilyToPartner.put(partnerRevenueShare.Product_Family__c+partnerRevenueShare.SiteChannelID__c, partnerRevenueShare.Id);
        }

        System.debug('@@==mapProdFamilyToPartner===='+mapProdFamilyToPartner);

         for(Order_Line_Item__c lineItem : orderLineItems) {
              string key = '';
              if(lineItem.ProductFamily__c != null){
                key = lineItem.ProductFamily__c;
              }

              if(lineItem.Order__c != null && orderMap.containsKey(lineItem.Order__c)){
                  if(orderMap.get(lineItem.Order__c).Site_Channel_ID__c != null) {
                    key += orderMap.get(lineItem.Order__c).Site_Channel_ID__c;
                  }
              }

              System.debug('@@==key===='+key);

              if(mapProdFamilyToPartner.containsKey(key)) {
                lineItem.Partner_Revenue_Share__c  =  mapProdFamilyToPartner.get(key);
                itemsToUpdate.add(lineItem);
                System.debug('@@==lineItem.Partner_Revenue_Share__c===='+lineItem.Partner_Revenue_Share__c);
              }

         }

         if(!itemsToUpdate.isEmpty()) {
                update itemsToUpdate;
         }
    }
*/
    /* Jeff L Commenting out for deplyoment
    private void syncLineItemsWithOpportunityLineItems(Order_Line_Item__c[] pNewOrderLineItem , Map<id ,Order_Line_Item__c> mapNewOrderLineItems ){
        if(ExecuteSynch){


        list<Order_Line_Item__c> lstUpdatedOrderLineItems = [SELECT ProposalLineItem__c ,
                                                             product__c ,
                                                             Sales_credit__c ,
                                                             GrossTotalAmount__c ,
                                                             NetTotalAmount__c ,
                                                             Organisation__c,
                                                             ProposalLineItem__r.Apttus_Proposal__Product__c ,
                                                             ProposalLineItem__r.Gross_Total__c,
                                                             ProposalLineItem__r.Quantity1__c ,
                                                             //ProposalLineItem__r.Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__c  ,
                                                             Quantity2__c ,
                                                             Order__r.Opportunity__c ,
                                                             Order__r.Opportunity__r.CurrencyIsoCode
                                                             //ProposalLineItem__r.Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__r.CurrencyIsoCode
                                                             FROM Order_Line_Item__c
                                                             WHERE Id IN : pNewOrderLineItem
                                                             AND ProposalLineItem__c != null
                                                             AND (product__c != null OR ProposalLineItem__r.Apttus_Proposal__Product__c != Null)
                                                            AND order__r.Opportunity__c != null];
        set<id> setOpportunityIds = new set<id>();
        set<id> setProducts = new set<id>();
        set<string> oppCurrencyISOCode = new set<string>();

        list<OpportunityLineItem> lstOppLineItemToUpdate = new list<OpportunityLineItem>();
        list<OpportunityLineItem> lstOppLineItemToInsert = new list<OpportunityLineItem>();

        if(lstUpdatedOrderLineItems.size() > 0 && !trigger.isDelete){
            for(Order_Line_Item__c oLI : lstUpdatedOrderLineItems){
                //setOpportunityIds.add(oLI.ProposalLineItem__r.Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__c);
                setOpportunityIds.add(oLI.Order__r.Opportunity__c);
                if(oLI.product__c != oLI.ProposalLineItem__r.Apttus_Proposal__Product__c && oLI.product__c != null){
                    setProducts.add(oLI.product__c);
                }else{
                    setProducts.add(oLI.ProposalLineItem__r.Apttus_Proposal__Product__c);
                }
                 //oppCurrencyISOCode.add(oLI.ProposalLineItem__r.Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__r.CurrencyIsoCode);
                 oppCurrencyISOCode.add(oLI.Order__r.Opportunity__r.CurrencyIsoCode);
            }
            List<PriceBookEntry> priceBookList = [SELECT Id, Product2Id, Product2.Id, Product2.Name
                                                  FROM PriceBookEntry WHERE Product2Id IN : setProducts
                                                  AND PriceBook2.isStandard=true
                                                  AND CurrencyIsoCode IN:oppCurrencyISOCode
                                                 ];
            map < id , id > mapProductPricebook = new map < id , id >();
            for(PriceBookEntry pBE : priceBookList){
                if(!mapProductPricebook.containskey(pBE.Product2Id))
                    mapProductPricebook.put(pBE.Product2Id ,  pBE.id );

            }
            Map<id , OpportunityLineItem> mapOppLineItems= new Map<id , OpportunityLineItem>([SELECT Product2Id ,
                                                                                              PricebookEntryId ,
                                                                                              OpportunityId ,
                                                                                              Order_Line_Item_Custom__c ,
                                                                                              TotalPrice
                                                                                              FROM OpportunityLineItem
                                                                                              where OpportunityId IN : setOpportunityIds]);


            Map<id , list<OpportunityLineItem>> mapOppToOppLineItems = new Map<id , list<OpportunityLineItem>>();
            for(OpportunityLineItem oppLineItem : mapOppLineItems.values()){

                if(!mapOppToOppLineItems.containskey(oppLineItem.OpportunityId))
                    mapOppToOppLineItems.put(oppLineItem.OpportunityId , new list<OpportunityLineItem>());

                mapOppToOppLineItems.get(oppLineItem.OpportunityId).add(oppLineItem);
            }

            OpportunityLineItem  oppLineItemToInsert;
            Boolean flagToInsert ;
            //system.assert(False , lstUpdatedOrderLineItems);
            for(Order_Line_Item__c oLI : lstUpdatedOrderLineItems){
                flagToInsert = True ;
                //if(mapOppToOppLineItems.containskey(oLI.ProposalLineItem__r.Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__c)){
                if(mapOppToOppLineItems.containskey(oLI.Order__r.Opportunity__c)){
               // for(OpportunityLineItem oppLineItem : mapOppToOppLineItems.get(oLI.ProposalLineItem__r.Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__c)){
                for(OpportunityLineItem oppLineItem : mapOppToOppLineItems.get(oLI.Order__r.Opportunity__c)){
                        if(oppLineItem.Order_Line_Item_Custom__c == oLI.id){
                            flagToInsert = false ;
                            oppLineItem.Order_Line_Item_Custom__c = oLI.Id;
                            if(oLI.Organisation__c == 'North America')
                                oppLineItem.TotalPrice =   oLI.NetTotalAmount__c;
                            else
                                oppLineItem.TotalPrice =   oLI.GrossTotalAmount__c;

                            //oppLineItem.TotalPrice =   oLI.Sales_Credit__c;
                            oppLineItem.Quantity = oLI.Quantity2__c;
                            lstOppLineItemToUpdate.add(oppLineItem);
                        }

                    }
                }

                if(flagToInsert == True){
                    //if( mapProductPricebook.containsKey(oLI.product__c) || ){
                    oppLineItemToInsert = new OpportunityLineItem();
                    //oppLineItemToInsert.OpportunityId = oLI.ProposalLineItem__r.Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__c ;
                    oppLineItemToInsert.OpportunityId = oLI.Order__r.Opportunity__c ;
                    if(oLI.product__c != oLI.ProposalLineItem__r.Apttus_Proposal__Product__c && oLI.product__c != null){
                        if( mapProductPricebook.containsKey(oLI.product__c)) {
                            oppLineItemToInsert.PricebookEntryId = mapProductPricebook.get(oLI.product__c);
                            //oppLineItemToInsert.TotalPrice =   oLI.Sales_Credit__c;
                            //oppLineItemToInsert.Quantity = oLI.Quantity2__c;
                        }else {
                            mapNewOrderLineItems.get(oLI.Id).adderror('Proposal line item having product with pricebook entry can only be added');
                            return;
                        }
                    }else{
                        if( mapProductPricebook.containsKey(oLI.ProposalLineItem__r.Apttus_Proposal__Product__c) ){
                            oppLineItemToInsert.PricebookEntryId = mapProductPricebook.get(oLI.ProposalLineItem__r.Apttus_Proposal__Product__c);
                            //oppLineItemToInsert.TotalPrice =   oLI.ProposalLineItem__r.Gross_Total__c;
                            //oppLineItemToInsert.Quantity = oLI.ProposalLineItem__r.Quantity1__c;
                        }else {
                            mapNewOrderLineItems.get(oLI.Id).adderror('Onlu products having pricebook entries can only be added be added in order line items');
                            return;
                        }

                    }

                    //oppLineItemToInsert.TotalPrice =   oLI.Sales_Credit__c;
                     if(oLI.Organisation__c == 'North America')
                           oppLineItemToInsert.TotalPrice =   oLI.NetTotalAmount__c;
                       else
                           oppLineItemToInsert.TotalPrice =   oLI.GrossTotalAmount__c;
                    if(oLI.Quantity2__c == null ){
                        mapNewOrderLineItems.get(oLI.Id).adderror('Please add a non zero quantity in Order line item');
                        return ;
                    }
                    oppLineItemToInsert.Quantity = oLI.Quantity2__c;
                    oppLineItemToInsert.Order_Line_Item_Custom__c = oLI.Id;

                    lstOppLineItemToInsert.add(oppLineItemToInsert);

                }
                //system.assert(false , lstOppLineItemToInsert);
            }


        }
        if(lstOppLineItemToInsert.size() > 0)
           insert lstOppLineItemToInsert;

        if(lstOppLineItemToUpdate.size() > 0)
            update lstOppLineItemToUpdate;

         ExecuteSynch = false;
        }

    }*/


/* Jeff Commented out and moved to handler code
    public void populateOwnerStartDate(List<Order_Line_Item__c> orderLineItem){

        map<Id , List<Order_Line_Item__c>> orderIdToOrderLineItem = new map<Id , List<Order_Line_Item__c>>();
       // map<Id , Id>
        Set<String> orderStatus = new Set<String>{'Verified' , 'Resubmitted' , 'Negated' , 'Paid in Full' , 'Invoiced' , 'Closed'};

        for(Order_Line_Item__c orderItem : orderLineItem){
            if(orderItem.Owner_on_Start_Date__c == null){
                if(!orderIdToOrderLineItem.containsKey(orderItem.Order__c) )
                    orderIdToOrderLineItem.put(orderItem.Order__c, new List<Order_Line_Item__c>());

                    orderIdToOrderLineItem.get(orderItem.Order__c).add(orderItem);
            }

        }

        for(Order__c order : [Select Id, OrderStatus__c , WebOrderNumber__c , Account__r.OwnerId , PrimarySalesRep__c
                              from Order__c
                              where id in : orderIdToOrderLineItem.keySet() And OrderStatus__c IN :orderStatus]){
                for(Order_Line_Item__c orderItem: orderIdToOrderLineItem.get(order.Id)){
                        if(!string.isBlank(order.WebOrderNumber__c))
                                orderItem.Owner_on_Start_Date__c = order.PrimarySalesRep__c;
                        // Since it is master detail so it cannot be null
                        else
                                orderItem.Owner_on_Start_Date__c = order.Account__r.OwnerId;

            }


        }

        //

        //populateManagerEmail(orderLineItem);
        List<Order_Line_Item__c> orderLineToProcess = new List<Order_Line_Item__c>();
        for(Order_Line_Item__c oli : pNewOrderLineItem){

            if(pOldOrderLineItemMap.get(oli.Id).Owner_on_Start_Date__c != oli.Owner_on_Start_Date__c &&  oli.Owner_on_Start_Date__c != null)
                    orderLineToProcess.add(oli);
        }
            if(orderLineToProcess.size() > 0)
                populateManagerEmail(orderLineToProcess);





    }*/

/* Jeff L commented out and moved to helper class
    public void populateManagerEmail(List<Order_Line_Item__c> orderLineItem){

        map<String,String> userIdToEmailAddress = new map<String,String>();
        Map<String,String> emptyOwnerAtStartDate = new Map<string,String>();
        Map<String, String> intermediateManager = new Map<String, String>();
        for(Order_Line_Item__c order : orderLineItem){
            if(order.Owner_on_Start_Date__c != null){
                emptyOwnerAtStartDate.put(order.Owner_on_Start_Date__c,'');
            }
        }
        if(emptyOwnerAtStartDate.size() > 0 ){

        intermediateManager = getManagerAndEmail(emptyOwnerAtStartDate,userIdToEmailAddress,0);
        intermediateManager = getManagerAndEmail(intermediateManager,userIdToEmailAddress,5);
        for(String key : userIdToEmailAddress.keySet()) {
            System.debug('Key = '+ key + ' value = '+userIdToEmailAddress.get(key));
        }

        System.debug('userIdToEmailAddress >>' + userIdToEmailAddress);
        map<String,String> indexToFieldName = new map<String,String>();

        String fieldName ='';
        for(Order_Line_Item__c oli: orderLineItem) {
            for(String usrToMangId : userIdToEmailAddress.keySet()) {
                if(usrToMangId.startsWith(oli.Owner_on_Start_Date__c)) {
                    fieldName = 'Hierarchy_Manager' + usrToMangId.substringAfterLast('~') + '__c';
                    oli.put(fieldName, userIdToEmailAddress.get(usrToMangId));
                }
            }
        }


        }
    }


    private Map<String,String> getManagerAndEmail(Map<String,String> userId , map<String, String> userIdToEmailAddress , Integer rank){

        Map<String,String> intermediateManager = new Map<String , String>();
        String key = '';
        for(User usr : [Select Id, managerId , manager.Email , manager.managerId , manager.manager.Email ,
                                   manager.manager.managerId , manager.manager.manager.Email ,
                                   manager.manager.manager.managerId , manager.manager.manager.manager.Email,
                                   manager.manager.manager.manager.managerId , manager.manager.manager.manager.manager.Email
                                   From User
                                   where id IN : userId.keySet()]){
            String currentuserId =  String.isNotBlank(userId.get(usr.Id)) ? userId.get(usr.Id) : usr.Id;

            if(usr.managerId != null){
                key = currentuserId + '~' + usr.managerId + '~' + string.valueOf(1 + rank);
                userIdToEmailAddress.put(key,usr.manager.Email);
            }

            if(usr.manager.managerId != null){
                key = currentuserId + '~' + usr.manager.managerId + '~' + string.valueOf(2 + rank);
                userIdToEmailAddress.put(key  , usr.Manager.Manager.Email ) ;
            }
            if(usr.manager.manager.managerId != null){
                key = currentuserId + '~' + usr.manager.manager.managerId + '~' + string.valueOf(3 + rank);
                userIdToEmailAddress.put(key , usr.manager.manager.manager.Email ) ;
            }
            if(usr.manager.manager.manager.managerId != null){
                key = currentuserId + '~' + usr.manager.manager.manager.managerId + '~' + string.valueOf(4 + rank);
                userIdToEmailAddress.put(key , usr.manager.manager.manager.manager.Email ) ;
            }
            if(usr.manager.manager.manager.manager.managerId != null){
                key = currentuserId + '~' + usr.manager.manager.manager.manager.managerId + '~' + string.valueOf(5 + rank);
                userIdToEmailAddress.put(key , usr.manager.manager.manager.manager.manager.Email ) ;

                intermediateManager.put(usr.manager.manager.manager.manager.managerId,usr.Id);
            }
        }

        return intermediateManager;
    }*/

    //We do not want to update the earliest product start date always , it should be updated when order status is Verified','Resubmitted','Negated','Paid in Full','Invoiced','Closed'
    //and it should be triggered from Order object so moving the logic to order trigger ahndler (Sunny G)
   /*public void insertEarliestProductStartDate(list<Order_Line_Item__c> pNewOrderLineItem, map<Id, Order_Line_Item__c> pOldOrderLineItemMap){
        List<Order_Line_Item__c> pUpdatedOrderLineItem = new List<Order_Line_Item__c>();
        List<String> orderStatus = new List<String>{' Verified','Resubmitted','Negated','Paid in Full','Invoiced','Closed'};
        set<Id> updatedOrderId = new set<Id>();
        set<Id> orderId = new set<Id>();
        for(Order_Line_Item__c  lineItem: pNewOrderLineItem){
            if(lineItem.Earliest_Product_Start_Date__c != null && (pOldOrderLineItemMap == null || (lineItem.Earliest_Product_Start_Date__c != pOldOrderLineItemMap.get(lineItem.id).Earliest_Product_Start_Date__c))){
                pUpdatedOrderLineItem.add(lineItem);
                orderId.add(lineItem.Order__c);
            }
        }
        for(Order__c ord :[SELECT id FROM Order__c WHERE id IN:orderId AND OrderStatus__c IN :orderStatus]){
            updatedOrderId.add(ord.Id);
        }
        for(Order_Line_Item__c oLI : pNewOrderLineItem){
            if(updatedOrderId.contains(oLI.order__c)) {
                if(pOldOrderLineItemMap!= null && (pOldOrderLineItemMap.get(oli.Id).StartDate__c == null && oLI.StartDate__c != null)){
                     oLI.Earliest_Product_Start_Date__c = oli.StartDate__c;
                }
                else if(pOldOrderLineItemMap == null){
                    oLI.Earliest_Product_Start_Date__c = oli.StartDate__c;
                }
            }
        }


    }*/
 //Update By Vivek for T-434693
 /* Jeff L moved logic into Trigger Helper class
 public void updateOptyOwner(List<Order_Line_Item__c> orderLineItem){

        map<Id , List<Order_Line_Item__c>> orderIdToOrderLineItem = new map<Id , List<Order_Line_Item__c>>();
        Map<Id,Id> orderOptyIds = new Map<Id,Id>();
        Map<Id,Id> OptyOwnerIdUpdate = new Map<Id,Id>();
        List<Opportunity> tobeUpdated = new List<Opportunity>();

        System.debug('In updateOptyOwner==');

        for(Order_Line_Item__c orderItem : orderLineItem){
            orderOptyIds.put(orderItem.Id,orderItem.Order__c);
           if(!orderIdToOrderLineItem.containsKey(orderItem.Order__c) )
                    orderIdToOrderLineItem.put(orderItem.Order__c, new List<Order_Line_Item__c>());

                    orderIdToOrderLineItem.get(orderItem.Order__c).add(orderItem);
        }

        for(Order__c order : [Select Id, OrderStatus__c ,Opportunity__r.OwnerId, Account__r.OwnerId , PrimarySalesRep__c
                              from Order__c
                              where id in : orderOptyIds.values() ]){
                for(Order_Line_Item__c orderItem: orderIdToOrderLineItem.get(order.Id)){
                        if(order.Opportunity__c != null &&  orderItem.Owner_on_Start_Date__c!= null && order.Opportunity__r.OwnerId != orderItem.Owner_on_Start_Date__c ){
                            order.Opportunity__r.OwnerId = orderItem.Owner_on_Start_Date__c;
                            OptyOwnerIdUpdate.put(order.Opportunity__c,orderItem.Owner_on_Start_Date__c);

                        }
                }


        }
        for(Opportunity opty :[Select Id, OwnerId From Opportunity Where Id IN : OptyOwnerIdUpdate.keySet() AND Organization__c ='North America']){
            if(OptyOwnerIdUpdate.get(opty.Id) != null){
                opty.OwnerId = OptyOwnerIdUpdate.get(opty.Id);
                tobeUpdated.add(opty);
            }
        }
        if(!tobeUpdated.isEmpty()){
            update tobeUpdated;
        }

       System.debug('Out updateOptyOwner=='+tobeUpdated);

    }*/

/* Jeff L moved logic into trigger helper 10/12
     public void populateOrderLineitemField(List<Order_Line_Item__c> orderLineItem){

         List<Id> quoteList = new List<Id>();
         Map<Id,Apttus_Proposal__Proposal_Line_Item__c> quotelineMap = new Map<Id,Apttus_Proposal__Proposal_Line_Item__c>();
         Map<Id,Id> quotelineIDMap = new Map<Id,Id>();
         Map<Id,Apttus_QPConfig__ProposalProductAttributeValue__c> productMap = new Map<Id,Apttus_QPConfig__ProposalProductAttributeValue__c>();
         for(Order_Line_Item__c oliFirst : orderLineItem){
             quoteList.add(oliFirst.Proposal__c);
         }

         if(!quoteList.isEmpty()){
             for(Apttus_Proposal__Proposal_Line_Item__c quoteFirst: [Select Id, Order_Quota_Type__c, Proposal_Locked__c,
                                                                     Sales_Credit_Amount__c, AgencyCommission__c,
                                                                     Agency_Commission_Amount__c, Earliest_Product_Start_Date__c,
                                                                     Owner_on_Start_Date_OSD__c, Manager_of_OSD__c, Sales_Channel_based_on_OSD__c,
                                                                     Region_based_on_OSD__c, Region_Group_based_on_OSD__c, Job_Type_based_on_OSD__c,
                                                                     Organization_based_on_OSD__c From Apttus_Proposal__Proposal_Line_Item__c where Proposal_Locked__c IN :quoteList]){
                 quotelineMap.put(quoteFirst.Proposal_Locked__c,quoteFirst);
                 quotelineIDMap.put(quoteFirst.Id, quoteFirst.Proposal_Locked__c);
             }
         }

         if(!quotelineIDMap.keySet().isEmpty()){
             for(Apttus_QPConfig__ProposalProductAttributeValue__c productFirst : [Select Id, Revenue_Partner__c, Rev_Share__c, APTPS_Rev_Share_Type__c, Apttus_QPConfig__LineItemId__c from
                                                                                   Apttus_QPConfig__ProposalProductAttributeValue__c where Apttus_QPConfig__LineItemId__c IN: quotelineIDMap.keySet()]){
                 if(productFirst != null && productFirst.Apttus_QPConfig__LineItemId__c != null && quotelineMap.containsKey(productFirst.Apttus_QPConfig__LineItemId__c)) {
                     productMap.put(quotelineMap.get(productFirst.Apttus_QPConfig__LineItemId__c).Id,productFirst );
                 }

               }
         }

         for(Order_Line_Item__c oliFirst : orderLineItem){
             if(productMap.containsKey(oliFirst.Proposal__c)){

                 if(productMap.get(oliFirst.Proposal__c).APTPS_Rev_Share_Type__c != Null){
                     oliFirst.Rev_Share_Type__c= productMap.get(oliFirst.Proposal__c).APTPS_Rev_Share_Type__c ;
                 }

                 if(productMap.get(oliFirst.Proposal__c).Rev_Share__c!= Null){
                     oliFirst.Rev_Share__c= productMap.get(oliFirst.Proposal__c).Rev_Share__c ;
                 }

             }



             if(quotelineMap.containsKey(oliFirst.Proposal__c)){

                 string orderQuotatype = quotelineMap.get(oliFirst.Proposal__c).Order_Quota_Type__c ;
                 if(orderQuotatype != Null && orderQuotatype == ''){
                     oliFirst.Order_Quota_Type__c = orderQuotatype;
                 }

                 if(quotelineMap.get(oliFirst.Proposal__c).Sales_Credit_Amount__c != Null){
                     oliFirst.Sales_Credit__c = quotelineMap.get(oliFirst.Proposal__c).Sales_Credit_Amount__c;
                 }

                 if(quotelineMap.get(oliFirst.Proposal__c).AgencyCommission__c != Null){
                     oliFirst.AgencyCommission__c = quotelineMap.get(oliFirst.Proposal__c).AgencyCommission__c;
                 }

                if(quotelineMap.get(oliFirst.Proposal__c).Agency_Commission_Amount__c != Null){
                     oliFirst.Sales_Credit__c = quotelineMap.get(oliFirst.Proposal__c).Agency_Commission_Amount__c;
                 }

                 if(quotelineMap.get(oliFirst.Proposal__c).Earliest_Product_Start_Date__c != Null){
                     oliFirst.Earliest_Product_Start_Date__c = quotelineMap.get(oliFirst.Proposal__c).Earliest_Product_Start_Date__c;
                 }

                 if(quotelineMap.get(oliFirst.Proposal__c).Owner_on_Start_Date_OSD__c != Null){
                     oliFirst.Owner_on_Start_Date__c = quotelineMap.get(oliFirst.Proposal__c).Owner_on_Start_Date_OSD__c;
                 }

                 if(quotelineMap.get(oliFirst.Proposal__c).Manager_of_OSD__c != Null){
                     oliFirst.Manager_of_OSD__c = quotelineMap.get(oliFirst.Proposal__c).Manager_of_OSD__c ;
                 }

                 if(quotelineMap.get(oliFirst.Proposal__c).Sales_Channel_based_on_OSD__c != Null && quotelineMap.get(oliFirst.Proposal__c).Sales_Channel_based_on_OSD__c == ''){
                     oliFirst.Sales_Channel_based_on_OSD__c = quotelineMap.get(oliFirst.Proposal__c).Sales_Channel_based_on_OSD__c;
                 }

                 if(quotelineMap.get(oliFirst.Proposal__c).Region_based_on_OSD__c != Null && quotelineMap.get(oliFirst.Proposal__c).Region_based_on_OSD__c == ''){
                     oliFirst.Region_based_on_OSD__c = quotelineMap.get(oliFirst.Proposal__c).Region_based_on_OSD__c;
                 }

                 if(quotelineMap.get(oliFirst.Proposal__c).Region_Group_based_on_OSD__c != Null && quotelineMap.get(oliFirst.Proposal__c).Region_Group_based_on_OSD__c == ''){
                     oliFirst.Region_Group_based_on_OSD__c = quotelineMap.get(oliFirst.Proposal__c).Region_Group_based_on_OSD__c;
                 }

                 if(quotelineMap.get(oliFirst.Proposal__c).Job_Type_based_on_OSD__c != Null && quotelineMap.get(oliFirst.Proposal__c).Job_Type_based_on_OSD__c == ''){
                     oliFirst.Job_Type_based_on_OSD__c = quotelineMap.get(oliFirst.Proposal__c).Job_Type_based_on_OSD__c ;
                 }

                 if(quotelineMap.get(oliFirst.Proposal__c).Organization_based_on_OSD__c != Null && quotelineMap.get(oliFirst.Proposal__c).Organization_based_on_OSD__c == ''){
                     oliFirst.Organization_based_on_OSD__c = quotelineMap.get(oliFirst.Proposal__c).Organization_based_on_OSD__c;
                 }


             }

         }
     }

   */

}