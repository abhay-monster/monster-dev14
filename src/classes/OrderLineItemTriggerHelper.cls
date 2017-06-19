public without sharing class OrderLineItemTriggerHelper {
    final String CLASSNAME = '\n\n**** OrderLineItemTriggerHelper.METHODNAME()';
    private String UserProfileName{get; private set;}
    public List<Order_Line_Item__c> OrderLineItemList{get; set;}
    private List<Product2> productList{get; set;}
    private List<Order__c> orderList{get; set;}
    private List<User> userList{get; set;}
    public Org_Settings__c orgSettings = Org_Settings__c.getInstance();
    public Integer cutoff = Integer.valueOf(orgSettings.Debug_Log_Record_Count_Cutoff__c); //JFreese Appirio S-435483 4/10/17
    public Id debugId = orgSettings.Debug_Log_Record_ID__c; //JFreese Appirio S-435483 4/11/17

/*
** @author : Cloud Sherpas Inc.
** @date : 04/09/2014
** @description : static method that instantiates a new instance of the class & sets the user's profile name member variable
** @paramaters : a string - the profile name for the current user
** @returns : a new instance of the ApttusProposalTriggerHelper class
*/
    public static OrderLineItemTriggerHelper NewTriggerHelper(String pUserProfileName){

        //final string METHODNAME = CLASSNAME.replace('METHODNAME','NewTriggerHelper');
        //system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        OrderLineItemTriggerHelper newHelper = new OrderLineItemTriggerHelper(pUserProfileName);
        return newHelper;
    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 04/09/2014
** @description : this method is the class constructor
** @paramaters : String user profile name
** @returns : nothing
*/
    public OrderLineItemTriggerHelper(String pUserProfileName){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','OrderLineItemTriggerHelper');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        UserProfileName = pUserProfileName;

    }

    //T-456297
    /*
    ** @author : (appirio)
    ** @date : 11/25/15
    ** @description : Populate NetTotalAmount field
    ** @paramaters : list of order line items, map of old order line items, map of new order line items
    ** @returns : nothing
    */
    /* public void populateNetTotalAmount(Order_Line_Item__c[] pNewOrderLineItem, map<Id, Order_Line_Item__c> pOldOrderLineItemMap, map<Id, Order_Line_Item__c> pNewOrderLineItemMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populateNetTotalAmount');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        //Jeff L added 1/7/2015 based upon I-195978 - skip this function if it is the MAPP user
        if(UserInfo.getName() == 'Integration MAPP'){
            return;
        }

        Boolean isUpdate = true;
        //Map<Id,Apttus_Proposal__Proposal__c> quoteIdMap ;
        //Set<Id> QuoteIdSet = new Set<Id>();


        if(pOldOrderLineItemMap == null || pNewOrderLineItemMap == null){
            isUpdate = false;
        }*/

        /*
        for(Order_Line_Item__c oL : pNewOrderLineItem){
            If(oL.Proposal__c != null){
                    QuoteIdSet.add(oL.Proposal__c);
            }
        }



        If(QuoteIdSet.size()>0){
         quoteIdMap = New Map<Id,Apttus_Proposal__Proposal__c>([Select Id,Net_Total__c from Apttus_Proposal__Proposal__c
                                                                                                     Where ID IN:QuoteIdSet]);
        }*/

        /*for(Order_Line_Item__c oLI : pNewOrderLineItem){
            //Jeff L added this if statement for I-199529
            //oLI.recalculateFormulas(); //used to make sure we have the latest version of the formula values before we calculate
            if(oLI.RecordTypeId == Utility.GetRecordTypeIdBySObjectNameAndType('Order_Line_Item__c', 'Credit Order Line Item')){
                oLI.NetTotalAmount__c = oLI.NetCreditAmount__c;
            }
            else if(oLI.NetUnitPrice__c != null && oLI.Quantity2__c != null && !isUpdate){
                system.debug('**Net Unit Calcs ');
                system.debug('Net Unit Price ' + oLI.NetUnitPrice__c);
                system.debug('Gross Unit Price ' + oLI.GrossUnitPrice__c);
                system.debug('Quantity ' +oLI.Quantity2__c);
               oLI.NetTotalAmount__c = oLI.NetUnitPrice__c * oLI.Quantity2__c;

            }
            //Jeff L: This logic is WRONG - please do not uncomment, you are putting the total for
            //the entire quote as the total for each line Item on the order!!
            /*if(QuoteIdSet.contains(oLI.Proposal__c) && quoteIdMap.containsKey(oLI.Proposal__c)){
                oLI.NetTotalAmount__c = quoteIdMap.get(oLI.Proposal__c).Net_Total__c;

            }*/
            /*else if(isUpdate && oLI.NetUnitPrice__c != null && oLI.Quantity2__c != null &&
             (pNewOrderLineItemMap.get(oLI.id).NetUnitPrice__c != pOldOrderLineItemMap.get(oLI.id).NetUnitPrice__c ||
             pNewOrderLineItemMap.get(oLI.id).Quantity2__c != pOldOrderLineItemMap.get(oLI.id).Quantity2__c)){
              oLI.NetTotalAmount__c = oLI.NetUnitPrice__c * oLI.Quantity2__c;

            }
        }

    }*/

    /* @Name: populateNetTotalAmount
    *  @Author: Jeff L (Appirio)
    *  @Params: lists and maps for new order line items, and old order line items
    *  @Returns: void
    *  @Description: This calculates the Net total amount, needs to be done in the after triggers because the formula
                     fields do not populate in the before triggers - which leads to incorrect values
    */
    public void populateNetTotalAmount(Order_Line_Item__c[] pNewOrderLineItem, map<Id, Order_Line_Item__c> pOldOrderLineItemMap, map<Id, Order_Line_Item__c> pNewOrderLineItemMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populateNetTotalAmount');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        //Jeff L added 1/7/2015 based upon I-195978 - skip this function if it is the MAPP user
        if(UserInfo.getName() == 'Integration MAPP'){
            return;
        }

        Boolean isUpdate = true;
        if(pOldOrderLineItemMap == null || pNewOrderLineItemMap == null){
            isUpdate = false;
        }

        List<Order_Line_Item__c> oliToUpdate = new List<Order_Line_Item__c>();
        for(Order_Line_Item__c oLI : pNewOrderLineItem){
            system.debug('>>> Net Unit Calcs ');
            system.debug('>>> Net Unit Price ' + Integer.Valueof(oLI.NetUnitPrice__c));
            system.debug('>>> Gross Unit Price ' + Integer.Valueof(oLI.GrossUnitPrice__c));
            system.debug('>>> Quantity ' + oLI.Quantity2__c);
            Order_Line_Item__c updatedOLI = new Order_Line_Item__c(Id=oLI.Id);
            //Jeff L added this if statement for I-199529
            if(oLI.RecordTypeId == Utility.GetRecordTypeIdBySObjectNameAndType('Order_Line_Item__c', 'Credit Order Line Item')){
                updatedOLI.NetTotalAmount__c = oLI.NetCreditAmount__c;
                system.debug('>>> Updated Net Total Amount ' + updatedoLI.NetTotalAmount__c);
                system.debug('>>> Net Credit Amount ' + oLI.NetCreditAmount__c);
                oliToUpdate.add(updatedOLI);
            }
            else if(oLI.NetUnitPrice__c != null && oLI.Quantity2__c != null && !isUpdate){
                system.debug('**Net Unit Calcs ');
                system.debug('Net Unit Price ' + oLI.NetUnitPrice__c);
                system.debug('Gross Unit Price ' + oLI.GrossUnitPrice__c);
                system.debug('Quantity ' +oLI.Quantity2__c);
               updatedOLI.NetTotalAmount__c = oLI.NetUnitPrice__c * oLI.Quantity2__c;
               oliToUpdate.add(updatedOLI);
            }

            else if(isUpdate && oLI.NetUnitPrice__c != null && oLI.Quantity2__c != null &&
                        (pNewOrderLineItemMap.get(oLI.id).NetUnitPrice__c != pOldOrderLineItemMap.get(oLI.id).NetUnitPrice__c ||
                        pNewOrderLineItemMap.get(oLI.id).Quantity2__c != pOldOrderLineItemMap.get(oLI.id).Quantity2__c)){
                updatedOLI.NetTotalAmount__c = oLI.NetUnitPrice__c * oLI.Quantity2__c;
                // No change just marked
                updatedOLI.NetRemainingCreditAmount__c = updatedOLI.NetRemainingCreditAmount__c;
                // End
                oliToUpdate.add(updatedOLI);
            }
        }

        if(oliToUpdate.size() > 0){
            OrderLineItemTriggerHandler.ExecuteTriggers = false;
            OrderLineItemTriggerHandler.ExecuteReportingUpdate = false;
            update oliToUpdate;
            OrderLineItemTriggerHandler.ExecuteTriggers = true;
            OrderLineItemTriggerHandler.ExecuteReportingUpdate = true;
        }
    }



    /*
    ** @author : Appirio Inc (Jeff L)
    ** @date : 10/12/2015
    ** @description : this method checks to see if the product list is null, if it is it will query to get the products
    it's use is to help reduce the overall number of queries.
    ** @paramaters : nothing
    ** @returns : List of product2s
    */
    private List<Product2> queryProduct2List(){
        if(productList == null){
            Set<String> mappProductIds = new Set<String>();
            Set<Id> productIds = new Set<Id>();

            for(Order_Line_Item__c oli : OrderLineItemList){
                if(oli.MAPPProduct__c != null){
                    mappProductIds.add(oli.MAPPProduct__c);
                }
                if(oli.Product__c != null){
                    productIds.add(oli.Product__c);
                }
            }

            productList = [ SELECT Id, ProductCode, Product_Line__c FROM Product2 WHERE ProductCode IN: mappProductIds OR Id IN: productIds ];
        }

        return productList;
    }

    /*
    ** @author : Appirio Inc (Jeff L)
    ** @date : 10/12/2015
    ** @description : this method checks to see if the order list is null, if it is it will query to get the orderd
    it's use is to help reduce the overall number of queries.
    ** @paramaters : nothing
    ** @returns : List of Orders
    */
    private List<Order__c> queryOrderList(){
        if(orderList == null){
            Set<Id> orderIds = new Set<Id>();

            for(Order_Line_Item__c oli : OrderLineItemList){
                if(oli.Order__c != null){
                    orderIds.add(oli.Order__c);
                }
            }

            orderList = [ SELECT Id,Xcode__c, Account__c, Agency__c,AgencyCommission__c, SiteChannelID__c, Site_Channel_ID__c, OrderStatus__c , WebOrderNumber__c ,
            Account__r.OwnerId , PrimarySalesRep__c, Opportunity__r.InternationalDeal__c, QuoteProposal__r.NetOrderAmount__c,
            QuoteProposal__r.BillingCountry__c, QuoteProposal__r.CurrencyIsoCode, QuoteProposal__r.Name, RecordTypeId, CurrencyIsoCode,
            Name, Archive_Billing_Xcode__c, Archive_Posting_Xcode__c,  Opportunity__r.OwnerId, Is_rebill__c,Is_Credit__c, Order_Sequence__c,
            Finance_Order_Type_pickList__c, NetTotalAmount__c, Account__r.CustomerDate__c, Account__r.WinbackDate__c, OrderDate__c ,RecordType.Name
            FROM Order__c
            WHERE Id In: orderIds ];
        }

        return orderList;
    }

    /*
    ** @author : Appirio Inc (Jeff L)
    ** @date : 10/12/2015
    ** @description : this method checks to see if the User list is null, if it is it will query to get the Users
    it's use is to help reduce the overall number of queries.
    ** @paramaters : nothingt
    ** @returns : List of Users
    */
    private List<User> queryUsersList(){
        if(userList == null){
            Set<Id> userIds = new Set<Id>();

            for(Order_Line_Item__c oli : OrderLineItemList){
                userIds.add(oli.Owner_on_Start_Date__c);
            }

            userList = [SELECT Id,PositionSalesChannel__c,PositionSalesGroup__c,UserPositionRegion__c,
                                Segment__c,Job_Type__c, Organisation__c, Combined_Region__c, PositionJobTitle__c,
                                Region_Group__c, Position_Account_Size__c, Country,
                                managerId , manager.Email , manager.managerId , manager.manager.Email ,
                                manager.manager.managerId , manager.manager.manager.Email ,
                                manager.manager.manager.managerId , manager.manager.manager.manager.Email,
                                manager.manager.manager.manager.managerId , manager.manager.manager.manager.manager.Email
                                FROM User WHERE Id IN :userIds];
        }

        return userList;
    }
    /*
    ** @author : Appirio Inc (Jeff L)
    ** @date : 10/12/2015
    ** @description : this will reset the List objects so that the queries will occur again when their respective
    functions are called
    ** @paramaters : nothing
    ** @returns : nothing
    */
    public void ResetQueries(){
        productList = null;
        orderList = null;
        userList = null;
    }


    /* // Not used anywhere
    private Double parseDouble(Object val){
        return val == null ? 0 : Double.valueOf(val);
    }*/

    /*
    ** @author :?
    ** @date : 10/12/2015
    ** @description : Jeff L moved this from the Handler to the helper class
    ** @paramaters : list of Order Line Items
    ** @returns : void
    */
    public void updateOrderLineItemXCode(List<Order_Line_Item__c> lineItems){
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

        if(orderIds.isEmpty())return;  //Added by Geeta kumawat Appirio -   I-192321
        for(Order__c o : queryOrderList()){
            if(o.Account__c != null){
                mapOrderAcc.put(o.Id, o.Account__c);
            }
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
    }

    public void CreateRevenueRecognition(list<Order_Line_Item__c> pOrderLineItems){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','CreateRevenueRecognition');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        //set<Id> opptyIdSet = new set<Id>();
        //map<Id, Opportunity> oppIdtoOpportunityMap = new map<Id, Opportunity>([SELECT Id, InternationalDeal__c FROM Opportunity WHERE Id IN : opptyIdSet]);

        //map<Id, Id> orderLineItemAndOrderMap = new map<Id, Id>();
        Id CreditOrderRecordType = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Credit');
        Set<Id> orderLineIdsToCheck = new Set<Id>();
        Map<Id,Order_Line_Item__c> oliMap = new Map<Id,Order_Line_Item__c>();
        //map<Id, Id> orderLineItemAndOrderMap = new map<Id, Id>();
        Set<Id> OrderIdSet = new Set<Id>();
        Set<Order_Line_Item__c> cisOli = new Set<Order_Line_Item__c>();
        Map<Id, Order_Line_Item__c> almaMap = new Map<Id, Order_Line_Item__c>();
        List<Order_Line_Item__c> almaOli = new List<Order_Line_Item__c>();

        for(Order_Line_Item__c oli: pOrderLineItems){
            //orderLineItemMap.put(oli.Id, oli.Order__c);
            OrderIdSet.add(oli.Order__c);
            oliMap.put(oli.Id, oli);

            //Sberron - S-452474 - 12-07-16.
            //List to store all Custom International Sponsorships
            if (oli.isCIS__c) {
                cisOli.add(oli);
            }
            //SBerron - S-452483 - 03/14/17
            //List to store Alma products
            if (oli.Alma_Product__c) {
                almaMap.put(oli.Id, oli);
            }
        }
        System.debug('----cisOli: ' + cisOli + ' oliMap: ' + oliMap);
        //Before anything else, we want to check if there are any Sales Allocations already created for order line items
        for(RevenueRecognition__c rr : [Select Id, OrderLineItem__c from RevenueRecognition__c where OrderLineItem__c in :oliMap.keySet()]){
            oliMap.remove(rr.OrderLineItem__c);
            almaMap.remove(rr.OrderLineItem__c);
        }

        List<Order__c> parentOrderList = new List<Order__c>();
        for(Order__c o : queryOrderList()){
            if(o.RecordTypeId != CreditOrderRecordType){
                parentOrderList.add(o);
            }
        }
        //SBerron - S-452483 - 03/14/17
        //Add map values to list for iteration
        almaOli.addAll(almaMap.values());
        Map<Id, Order_Line_Item__c> oliIdToOrder = new Map<Id, Order_Line_Item__c>();
        if (almaOli != null) {
            for (Order_Line_Item__c oli : [SELECT Order__r.Quote_Selling_Country__c, AttributeValueId__r.Posting_Locations__c FROM Order_Line_Item__c WHERE Id IN:almaOli]) {
                oliIdToOrder.put(oli.Id, oli);
            }
        }
        System.debug('almaOLI ' + almaOli);
        System.debug('----oliIdToOrder ' + oliIdToOrder);
        /* Jeff L commented out for query framework replaced code with above for loop
        Order__c[] parentOrderList = [SELECT ID, Opportunity__r.InternationalDeal__c, QuoteProposal__r.NetOrderAmount__c, QuoteProposal__r.BillingCountry__c, QuoteProposal__r.CurrencyIsoCode, QuoteProposal__r.Name
                                                FROM Order__c WHERE RecordTypeId != :CreditOrderRecordType AND Id IN: OrderIdSet];*/

        system.debug('!!!ParentOrderList ' + ParentOrderList);

        if(parentOrderList == null || parentOrderList.size() == 0){
            system.debug('\n\nNo order for CreateRevenueRecognition.\n\n');
            return;
        }

        /*
        CurrencyType[] currencyTypeList = [SELECT ConversionRate, IsoCode FROM CurrencyType WHERE IsActive = true];
        map<String, Double> ISOCodeToConversionRate = new map<String, Double>();
        for(CurrencyType c : currencyTypeList){
            ISOCodeToConversionRate.put(c.IsoCode, c.ConversionRate);
        }*/

        map<Id,Boolean> OrderandOpportunityMap = new Map<Id,Boolean>();
        if(OrderIdSet.size() > 0){
            for(Order__c ord : parentOrderList){
                //Jeff L. Commented out if statement and check per Matt Keefe on I-173649
                //if(ValidAmountAndCountrySalesAllocation(ord, ISOCodeToConversionRate)){ //For Task E1731: prevent if billing country is Germany and NetOrderAmount__c < 5000
                OrderandOpportunityMap.put(ord.Id, ord.Opportunity__r.InternationalDeal__c);
               // }
            }
        }
        map<Id, RevenueRecognitionSplits__c> RevenueRecognitionSplitsMap = new map<Id, RevenueRecognitionSplits__c>();
        for(RevenueRecognitionSplits__c rrs : [SELECT Id, PostingLocation__c, ProductFamily__c FROM RevenueRecognitionSplits__c ]){
            RevenueRecognitionSplitsMap.put(rrs.Id, rrs);
        }

        //Jeff L added this > there are cases where te PostingLocation__c is null or "Match Country" and we need to check a related object instead
        //Order Line Item > ProposalLineItem__c > Apttus_QPConfig__AttributeValueId__c > Country__c,
        Set<Id> oliCountryCheckSet = new Set<Id>();
        for(Order_Line_Item__c oli : oliMap.values()){
            if( (oli.PostingLocation__c == null || oli.PostingLocation__c == 'Match Country') && oli.ProductFamily__c != null){
                oliCountryCheckSet.add(oli.Id);
            }
        }
        System.debug('----oliCountryCheckSet ' + oliCountryCheckSet);

        Map<Id,String> oliToCountry = new Map<Id,String>();
        for(Order_Line_Item__c oli : [Select Id, ProposalLineItem__r.Apttus_QPConfig__AttributeValueId__r.Country__c
            FROM Order_Line_Item__c WHERE ID IN: oliCountryCheckSet]){
            oliToCountry.put(oli.Id,oli.ProposalLineItem__r.Apttus_QPConfig__AttributeValueId__r.Country__c);
        }

        //Sberron - S-452474 - 12-07-16.
        //Find Alternate Products for all Custom International Sponsorship products
        Map<Id, String> IDToProductMap = new Map<Id, String>();
        if(!cisOli.isEmpty()) {
            Map<Id, String> stringAlts = new Map<Id, String>();
            for (Order_Line_Item__c oli : cisOli) {
                System.debug('----altProd ' + oli.Alternative_Product__c);
                stringAlts.put(oli.Id, oli.Alternative_Product__c);
            }
            Map<String, String> altProductFamily = new Map<String, String>();
            for (Product2 altProduct : [SELECT Id, Name, Family FROM Product2 WHERE Name in :stringAlts.values()]) {
                altProductFamily.put(altProduct.Name, altProduct.Family);
            }
            for (Id recordId : stringAlts.keySet()) {
                IDToProductMap.put(recordId, altProductFamily.get(stringAlts.get(recordId)));
            }
            System.debug('----IDToProductMap ' + IDToProductMap);
        }


        Map<Id, Id> OLIAndRRIdMap = new Map<Id,Id>();
        for(Order_Line_Item__c oli : oliMap.values()){
        system.debug('%%OrderandOpportunityMap.get(oli.Order__c)%%' +OrderandOpportunityMap.get(oli.Order__c));
            if(OrderandOpportunityMap.get(oli.Order__c) == true && IsNotStarterPackProduct(oli)/*for task E1731*/){
                system.debug('Posting location and PRoduct Family ' + oli.PostingLocation__c + ' ' + oli.ProductFamily__c);
                if(oli.ProductFamily__c != null){
                    //Country is either going to be the posting location, or the country on the
                    //Attribute object (see query above for the relation)
                    String country;
                    if(oli.PostingLocation__c != null && oli.PostingLocation__c != 'Match Country'){
                        country = oli.PostingLocation__c;
                    } else if(oliToCountry.containsKey(oli.Id)){
                        country = oliToCountry.get(oli.Id);
                    }

                    if(country != null){
                        for(Id ids:RevenueRecognitionSplitsMap.keySet()){
                            if(country == RevenueRecognitionSplitsMap.get(ids).PostingLocation__c &&
                               oli.ProductFamily__c == RevenueRecognitionSplitsMap.get(ids).ProductFamily__c){
                                   System.debug('Found a Match for RR and OLI');
                                OLIAndRRIdMap.put(ids, oli.Id);
                            }
                        }
                    }
                }
                //Sberron - S-452474 - 12-07-16.
                //adds CIS Revenue Recognition to OLIAndRRIdMap to create new revenue recognition (sales allocation)
                if (oli.isCIS__c && cisOli.contains(oli) && IDToProductMap.get(oli.Id) != null) {
                    String country;
                    country = oliToCountry.get(oli.Id);
                    String productFamily;
                    productFamily = IDToProductMap.get(oli.Id);
                    if (country != null) {
                        for (Id ids : RevenueRecognitionSplitsMap.keyset()) {
                            if (country == RevenueRecognitionSplitsMap.get(ids).PostingLocation__c &&
                                productFamily == RevenueRecognitionSplitsMap.get(ids).ProductFamily__c) {
                                System.debug('----Found a match for CIS RR and OLI');
                                OLIAndRRIdMap.put(ids, oli.Id);
                            }
                        }
                    }
                }
            }
        }

        List<RevenueRecognition__c> RRToBeInsertedList = new  List<RevenueRecognition__c>();
        system.debug('OLI and RRID Map empty? ' + OLIAndRRIdMap.isEmpty() );
        system.debug('OLI and RRID map ' + OLIAndRRIdMap);

        //SBerron - S-452483 - 03/14/17
        //Map to store custom settings with split %
        //Generate 1 split with % from AlmaProductSalesAllocationSplits__c custom setting. 2nd split is remaining %
        Boolean isAlma = false;
        Map<String, AlmaProductSalesAllocationSplits__c> customSettingMap = AlmaProductSalesAllocationSplits__c.getAll();
        //Map<String, CurrencyByCountry__c> countryCustomSettingMap = CurrencyByCountry__c.getAll();
        if (almaOli != null) {
            for (Order_Line_Item__c almaLineItem : almaOli) {
                System.debug('----almaLineItem PostingLocation__c ' + almaLineItem.PostingLocation__c);
                Decimal total = 100;
                if (oliIdToOrder.containsKey(almaLineItem.Id)
                    && oliIdToOrder.get(almaLineItem.Id).AttributeValueId__r.Posting_Locations__c != null
                    && oliIdToOrder.get(almaLineItem.Id).Order__r.Quote_Selling_Country__c != null) {
                    String oliPostingLocation = oliIdToOrder.get(almaLineItem.Id).AttributeValueId__r.Posting_Locations__c;
                    String quoteSellingCountry = oliIdToOrder.get(almaLineItem.Id).Order__r.Quote_Selling_Country__c;

                    RevenueRecognition__c rr1 = new RevenueRecognition__c();
                    rr1.Name = oliPostingLocation;
                    rr1.SplitPercentage__c = customSettingMap.get(oliPostingLocation).SplitPercentage__c;
                    rr1.OrderLineItem__c = almaLineItem.Id;
                    rr1.CurrencyIsoCode = 'EUR';
                    //if (countryCustomSettingMap.containsKey(oliPostingLocation)) {
                    //    rr1.CurrencyIsoCode = countryCustomSettingMap.get(oliPostingLocation).ISOCode__c;
                    //}
                    RRToBeInsertedList.add(rr1);

                    System.debug('----rr1 ' + rr1);
                    total -= rr1.SplitPercentage__c;

                    if (total > 0) {
                        RevenueRecognition__c rr2 = new RevenueRecognition__c();
                        rr2.Name = quoteSellingCountry;
                        rr2.SplitPercentage__c = total;
                        rr2.OrderLineItem__c = almaLineItem.Id;
                        rr2.CurrencyIsoCode = 'EUR';
                        //if (countryCustomSettingMap.containsKey(oliPostingLocation)) {
                        //    rr2.CurrencyIsoCode = countryCustomSettingMap.get(quoteSellingCountry).ISOCode__c;
                        //}
                        RRToBeInsertedList.add(rr2);

                        System.debug('----rr2 ' + rr2);
                    }

                    isAlma = true;
                }
                System.debug('----almaLineItem ' + almaLineItem);
                System.debug('----almaPostingLocation ' + almaLineItem.PostingLocation__c);
                System.debug('----quoteSelling Country ' + oliIdToOrder.get(almaLineItem.Id));
            }
        }

        if(!OLIAndRRIdMap.isEmpty() && !isAlma){
            Map<id,Set<Id>> RevenueRecognitionSplitChildrenMap = new Map<id,Set<Id>>();
                for(Country_Revenue_Split__c crs : [SELECT Id, RevenueRecognitionSplit__c, Name, CurrencyIsoCode, Lead__c, SplitPercentage__c FROM Country_Revenue_Split__c WHERE RevenueRecognitionSplit__c =:  OLIAndRRIdMap.keySet() ]){

                    RevenueRecognition__c rr = new RevenueRecognition__c();
                    rr.Name = crs.Name ;
                    rr.CurrencyIsoCode = crs.CurrencyIsoCode ;
                    rr.Lead__c = crs.Lead__c ;
                    rr.SplitPercentage__c = crs.SplitPercentage__c ;
                    rr.OrderLineItem__c = OLIAndRRIdMap.get(crs.RevenueRecognitionSplit__c);
                    RRToBeInsertedList.add(rr);
                    system.debug('Inside of Country Revenue Split query' + rr);
                }
        }

        try{
            if(RRToBeInsertedList.size() > 0){
                insert RRToBeInsertedList;
            }
        }catch(Exception e){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Failed to insert Revenue Recognition. Please see logs for details.', e);
        }
    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 07/08/2014
** @description : check to see if order line item's product is not a starter pack
** @paramaters : order line item to check
** @returns : Boolean
*/
    private Boolean IsNotStarterPackProduct(Order_Line_Item__c pLineItem){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','IsNotStarterPackProduct');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        String productName = pLineItem.ProductNameText__c == null ? '' : pLineItem.ProductNameText__c;
        Boolean output = !productName.toLowerCase().contains('starter pack');
        system.debug('\n\nOLI: ' + pLineItem.Name + '\nproduct: ' + productName + '\nIsNotStarterPackProduct?: ' + output + '\n\n');
        return output;
    }
/*
    Jeff L. Commented out per Matt Keefe on I-173649
** @author : Cloud Sherpas, Inc.
** @date : 07/08/2014
** @description : check to see if :
                         -order's Billing Country is "Germany" and NetOrderAmount__c is not less than 5000
                         -order's Billing Country is "United States" and NetOrderAmount__c is not less than 1000
** @paramaters : Order to check,
                        map of currency ISO Code to Exchange Rate for the currency ISO Code
** @returns : Boolean

    private Boolean ValidAmountAndCountrySalesAllocation(Order__c pOrder, map<String, Double> pISOCodeToConversionRate){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','ValidAmountAndCountrySalesAllocation');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Double DollarNetAmount = pOrder.QuoteProposal__r.NetOrderAmount__c == null ? 0 : pOrder.QuoteProposal__r.NetOrderAmount__c;
        if(pISOCodeToConversionRate.containsKey(pOrder.QuoteProposal__r.CurrencyIsoCode) && DollarNetAmount != 0){
            DollarNetAmount = DollarNetAmount / pISOCodeToConversionRate.get(pOrder.QuoteProposal__r.CurrencyIsoCode);
        }

        Double RequiredAmount;
        String BillingCountry = pOrder.QuoteProposal__r.BillingCountry__c;
        if(BillingCountry == 'Germany'){
            RequiredAmount = 5000;
        }else if(BillingCountry == 'United States'){ //Added for element E1747
            RequiredAmount = 1000;
        }

        Boolean output = RequiredAmount == null ? true : (DollarNetAmount > RequiredAmount);

        system.debug('\n\nQuote: ' + pOrder.QuoteProposal__r.Name +
                            '\nBilling Country: ' + BillingCountry +
                            '\nNet Amount: ' +DollarNetAmount+
                            '\nRequired Amount: ' +RequiredAmount+
                            '\nValid for sales alloc?: ' + output + '\n\n');

        return output;
    }
    */
/*
** @author : Cloud Sherpas, Inc.
** @date : 07/16/2014
** @story : 0451
** @element : E1957
** @description :
** @paramaters :
** @returns : nothing
*/
    public void updateOrderFieldsFromMAPP(list<Order_Line_Item__c> pOrderLineItems){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateOrderFieldsFromMAPP');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            for(Order_Line_Item__c oli : pOrderLineItems){
                if(oli.MAPPAttributeValueId__c != null){
                    oli.AttributeValueId__c = oli.MAPPAttributeValueId__c;
                }
                if(oli.MAPPClassificationId__c != null){
                    oli.ClassificationId__c = oli.MAPPClassificationId__c;
                }
            }
        }catch(Exception e){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Problem Attribute Value and Classification Id field. ' + e, e);
        }
    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 07/16/2014
** @story : 2258
** @element :
** @description :
** @paramaters :
** @returns : nothing
*/


    /* 05.19 - Commented out this method as it is not used anywhere.
       Please Uncomment if it need to be used  */

   /* public void MatchOrderFromOLIMAPPOrder(list<Order_Line_Item__c> pOrderLineItems){
        set<Id> MAPPOrderIdSet = new set<Id>();
        for(Order_Line_Item__c oli : pOrderLineItems){
            if(oli.MAPP_Order_ID__c != null){
                MAPPOrderIdSet.add(oli.MAPP_Order_ID__c);
            }
        }
        Map<String,Id> OrderAndMAPPOrderIdMap = new Map<String, Id>();
        if(!MAPPOrderIdSet.IsEmpty()){
            for(Order__c ord : [SELECT Id, MAPP_Order_ID__c FROM Order__c WHERE MAPP_Order_ID__c IN: MAPPOrderIdSet]){
                OrderAndMAPPOrderIdMap.put(ord.MAPP_Order_ID__c, ord.Id);
            }
        }
        if(!OrderAndMAPPOrderIdMap.IsEmpty()){
            for(Order_Line_Item__c oli : pOrderLineItems){
                if(oli.MAPP_Order_ID__c != null){
                    if(OrderAndMAPPOrderIdMap.containsKey(oli.MAPP_Order_ID__c) && OrderAndMAPPOrderIdMap.get(oli.MAPP_Order_ID__c) != null){
                        oli.Order__c = OrderAndMAPPOrderIdMap.get(oli.MAPP_Order_ID__c);
                    }
                }
            }
        }
    }
    */
/*
** @author : Cloud Sherpas, Inc.
** @date : 07/16/2014
** @story : 2258
** @element :
** @description :
** @paramaters :
** @returns : nothing
*/
    public void MatchProductFromMAPP(list<Order_Line_Item__c> pOrderLineItems){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','MatchProductFromMAPP');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            set<String> MAPPProductCodeSet = new set<String>();
            for(Order_Line_Item__c oli : pOrderLineItems){
                if(oli.MAPPProduct__c != null){
                    MAPPProductCodeSet.add(oli.MAPPProduct__c);
                }
            }
            Map<String,Id> ProductAndMAPPOrderIdMap = new Map<String, Id>();
            if(!MAPPProductCodeSet.IsEmpty()){
                for(Product2 prod : queryProduct2List()){
                    //if(MAPPProductCodeSet.contains(prod.Id)){//AP I-187076
                    if(MAPPProductCodeSet.contains(prod.ProductCode)){
                        ProductAndMAPPOrderIdMap.put(prod.ProductCode, prod.Id);
                    }
                }
            }
            if(!ProductAndMAPPOrderIdMap.IsEmpty()){
                for(Order_Line_Item__c oli : pOrderLineItems){
                    if(oli.MAPPProduct__c != null && (ProductAndMAPPOrderIdMap.containsKey(oli.MAPPProduct__c) && ProductAndMAPPOrderIdMap.get(oli.MAPPProduct__c) != null)){
                            oli.Product__c = ProductAndMAPPOrderIdMap.get(oli.MAPPProduct__c);
                    }
                }
            }
        }catch(Exception e){
             ExceptionLog.add('Exception', 'OrderTriggerHelper', 'MatchProductFromMAPP', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to populate Product. Please see system logs for details. ' ,e);
        }
    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 07/16/2014
** @story : 0920
** @element : E2329
** @description :
** @paramaters :
** @returns : nothing
*/
    public void CloseCase(list<Order_Line_Item__c> pOrderLineItems){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','CloseCase');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            Set<Id> OliSet = new set<Id>();
            for(Order_Line_Item__c oli : pOrderLineItems){
                 If(oli.Product__r.Product_Line__c == 'Job Accessories--Inventory' || oli.Product__r.Product_Line__c == 'JOB PACK' || oli.Product__r.Product_Line__c == 'Banner-Button--Inventory'){
                    OliSet.add(oli.Id);
                 }
            }
            List<Case> CaseIds = new List<Case>();
            if(!OliSet.isEmpty()){
                for(Case c : [Select Id, Status, OrderLineItem__c FROM Case WHERE OrderLineItem__c IN: OliSet]){
                    c.Status = 'Closed';
                    CaseIds.add(c);
                }
            }
            if(!CaseIds.isEmpty()){
                Update CaseIds;
            }

        }catch(Exception e){
            ExceptionLog.add('Exception', 'OrderTriggerHelper', 'CloseCase', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to close the case. Please see system logs for details. ' ,e);
        }
    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 11/13/2014
** @story :
** @element :
** @description :
** @paramaters :
** @returns : nothing
*/
    public void PopulateAgencyCommission(list<Order_Line_Item__c> pOrderLineItems){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','PopulateAgencyCommission');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            Map<Id, Order__c> orderMap = new Map<Id, Order__c>();
            Map<Id, Product2> productMap = null ;
            Set<Id> orderIdSet = new Set<Id>();
            Set<Id> accountIdSet = new Set<Id>();
            Set<Id> optionIds = new Set<Id>();
            //Set<Id> SiteIdSet = new Set<Id>();//AP 3590
            Set<Id> agencyIdSet = new Set<Id>();
            Set<String> SiteIdSet = new Set<String>();
            List<Account> accountList = new List<Account>();
            for(Order_Line_Item__c oli : pOrderLineItems){
                orderIdSet.add(oli.Order__c);
            }

            for(Order__c ord : queryOrderList()){
                system.debug('ord' + ord);
                accountIdSet.add(ord.Account__c);
                if(ord.SiteChannelID__c != null)
                    SiteIdSet.add(ord.SiteChannelID__c);//AP 3590
                orderMap.put(ord.Id, ord);
                if(ord.Agency__c != null)
                    agencyIdSet.add(ord.Agency__c);
                system.debug('orderMap.put(ord.Id, ord)' + orderMap.put(ord.Id, ord));
            }

            // Check for bundle product
            for(Order_Line_Item__c oli : pOrderLineItems){
                if(oli.OptionId__c != null){
                    optionIds.add(oli.OptionId__c);
                }
            }

            if(!optionIds.isEmpty()) {
                productMap = new Map<Id, Product2>([Select Id,Family from Product2 Where Id IN :optionIds and Family != null]);
            }


            //List<Partner_Revenue_Share__c> prsList = [SELECT Id, Product_Family__c, RevenueSHare__c, Partner__c, SiteChannelID__c FROM Partner_Revenue_Share__c WHERE Partner__c In: accountIdSet];
            List<Partner_Revenue_Share__c> prsList = [SELECT Id, Product_Family__c, RevenueSHare__c, Partner__c, SiteChannelID__c FROM Partner_Revenue_Share__c WHERE SiteChannelID__c In: SiteIdSet or Partner__c in :agencyIdSet];//AP 3560
            system.debug('prsList' + prsList);
            system.debug('pOrderLineItems' + pOrderLineItems);
            List<Order_Line_Item__c> UpdateAgencyList = new List<Order_Line_Item__c>();
            boolean isbundle = false;
            for(Order_Line_Item__c oli : pOrderLineItems){
                isbundle = false;
                if(UserInfo.getName() == 'Integration MAPP'){//I-202555
                    if(oli.Product_Type__c == 'Core'){
                        oli.Quota_Type__c = 'Core';
                    }
                    if(oli.Product_Type__c == 'Premium'){
                        oli.Quota_Type__c = 'Strategic';
                    }

                }
                if(oli.ProductFamily__c != null || oli.OptionId__c != null){

                    if(productMap != null && productMap.containsKey(oli.OptionId__c)){
                        isbundle = true;
                    }
                    system.debug('IsBundle...' + isbundle);
                    for(Partner_Revenue_Share__c prs : prsList){
                        system.debug('prs' + prs);
                        system.debug(' hello 1 orderMap.get(oli.Order__c).Account__c' + orderMap.get(oli.Order__c).Account__c);
                        system.debug('hello2'+ prs.Partner__c);
                        system.debug('hello3' + orderMap.get(oli.Order__c).SiteChannelID__c);
                        system.debug('hello4' + prs.SiteChannelID__c);
                        //if(orderMap.get(oli.Order__c).Account__c == prs.Partner__c){
                        //system.debug('first if');
                         //&&
                         if(orderMap.get(oli.Order__c).SiteChannelID__c == prs.SiteChannelID__c || orderMap.get(oli.Order__c).Agency__c == prs.Partner__c){
                            system.debug('second if');
                            system.debug('hello 5' + prs.Product_Family__c);
                            system.debug('hello 6' + oli.ProductFamily__c);
                            system.debug('hello 7' + prs.Product_Family__c);
                            system.debug('hello 9' + prs.RevenueShare__c);

                            if(prs.Product_Family__c != null && (oli.ProductFamily__c == prs.Product_Family__c
                            || (isbundle && productMap.get(oli.OptionId__c) != null
                            && productMap.get(oli.OptionId__c).Family == prs.Product_Family__c))){
                                //updated due to T-454887
                                oli.Partner_Revenue_Share__c = prs.Id;
                                oli.Revenue_Share_Percent__c = prs.RevenueShare__c;
                                system.debug('oli.Revenue_Share_Percent__c' + oli.Revenue_Share_Percent__c);
                                system.debug('hello 8' +  oli.AgencyCommission__c);

                             }
                             else{
                                    if(UserInfo.getName() == 'Integration MAPP'){
                                         oli.Partner_Revenue_Share__c = prs.Id;
                                         oli.Revenue_Share_Percent__c = prs.RevenueShare__c;
                                         system.debug('imapp oli.Revenue_Share_Percent__c' + oli.Revenue_Share_Percent__c);

                                     }
                             }
                        }

                    }
                }
                else {
                    if(!orderMap.isEmpty()){
                        if(orderMap.containsKey(oli.Order__c) && orderMap.get(oli.Order__c).AgencyCommission__c != null){
                            oli.AgencyCommission__c = orderMap.get(oli.Order__c).AgencyCommission__c;

                        }
                    }
                }
            }
        }catch(Exception e){
            ExceptionLog.add('Exception', 'OrderLineItemTriggerHelper', 'PopulateAgencyCommission', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to populate Agency Commission field. Please see system logs for details. ' ,e);
        }
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 11/20/2014
** @story : 2729
** @element : E2417
** @description : Populate Product Line and Part Number
** @paramaters : List of Order Line Item
** @returns : nothing
*/
    public void populateProductLineAndPartNumber(list<Order_Line_Item__c> pOrderLineItems){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populateProductLineAndPartNumber');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            Map<Id, Order_Line_Item__c> productIdOrderLineItem = new Map<Id, Order_Line_Item__c>();
            for(Order_Line_Item__c oli : pOrderLineItems){
                if(oli.Product__c != null){
                    productIdOrderLineItem.put(oli.Product__c, oli);
                }
            }
            List<Product2> pro = new List<Product2>();
            if(!productIdOrderLineItem.isEmpty()){
                for(Product2 p : queryProduct2List()){
                    if(productIdOrderLineItem.containsKey(p.Id)){
                        pro.add(p);
                    }
                }
            } else {
                return;
            }
            if(!pro.isEmpty()){
                for(Product2 p : pro){
                    Order_Line_Item__c ordLI = productIdOrderLineItem.get(p.Id);
                    if(p.ProductCode != null){
                        ordLI.PartNumber__c = p.ProductCode;
                    }
                    if(p.Product_Line__c != null){
                        ordLI.ProductLine__c = p.Product_Line__c;
                    }
                }
            }
        }catch(Exception e){
            ExceptionLog.add('Exception', 'OrderLineItemTriggerHelper', 'populateProductLineAndPartNumber', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to populate Product Code/Product line field. Please see system logs for details. ' ,e);
        }
    }

    /*
    ** @author : Adarsh
    ** @date : 04/06/2015
    ** @story : 3486
    ** @element :
    ** @description : Copy Xcode to OLI.
    ** @paramaters : Set of Order Id's, Account Id's
    ** @returns : nothing
    */
    public void UpdateXcodeOnOrderLineItem (list<Order_Line_Item__c> pNewOrderLineItem,boolean doNotUpdate){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','UpdateXcodeOnOrderLineItem');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        try{
            set<id> ordidsSet = new set<id>();
            set<Id> OrdAcctIdsSet = new Set<Id>();
            List<Account> acctList = new List<Account>();
            List<Order__c> ordList = new List<Order__c>();
            List<Order__c> orderList = new List<Order__c>();
            Set<Id> orderSet = new set<Id>();
            List<Xcode__c> xcodeNameList = new List<Xcode__c>();
            List<XcodeAccount__c> xAccountList = new List<XcodeAccount__c>();
            List<Xcode__c> xCodeList = new List<Xcode__c>();
            set<Id> xCodeIdsSet = new Set<Id>();
            map<Id,XcodeAccount__c> bbMap = new map<Id,XcodeAccount__c>();
            for(Order_Line_Item__c oli: pNewOrderLineItem){
                    ordidsSet.add(oli.Order__c);
            }
            for(Order__c ord : queryOrderList()){
                OrdAcctIdsSet.add(ord.Account__c);
                ordList.add(ord);
            }
            xAccountList = [Select name, Xcode__c, Account__c from XcodeAccount__c where Account__c in:OrdAcctIdsSet];
            //Jeff moved logic into query framework
            //ordList = [Select id, name, Archive_Billing_Xcode__c, Archive_Posting_Xcode__c from Order__c where id in: ordidsSet];
            for(XcodeAccount__c xAcc: xAccountList ){
                xCodeIdsSet.add(xAcc.Xcode__c);
                bbMap.put(xAcc.xcode__c,xAcc);// id of xcode
            }
            xcodeNameList = [Select id,name from Xcode__c where id in: xCodeIdsSet];
            for(Order__c o: ordList){
                //if(o.Order_Line_Items__r != null && o.Order_Line_Items__r.size()>0){// already on oli record
                    for(Xcode__c xName: xcodeNameList ){
                        if(xName.name != null){
                            system.debug('Billing' + o.Archive_Billing_Xcode__c);
                            system.debug('Posting' + o.Archive_Posting_Xcode__c);
                            if(xName.name == o.Archive_Billing_Xcode__c || xName.name == o.Archive_Posting_Xcode__c){
                                xCodeList.add(xName);
                                orderList.add(o);
                                orderSet.add(o.Id);
                            }
                        }
                    }
                //}
            }
            //Jeff L - Don't need to query this, we can get it from the line items passed into the method
            //List<Order_Line_Item__c>ordlnList = [select Xcode__c,order__c, Xcode_lkp__c,Xcode_Id__c from Order_Line_Item__c where order__c in :orderList AND Id in: pNewOrderLineItem] ;
            List<Order_Line_Item__c> ordlnList = new List<Order_Line_Item__c>();
            for(Order_Line_Item__c oli: pNewOrderLineItem){
                    if(orderSet.contains(oli.Order__c)){
                        ordlnList.add(oli);
                    }
            }
            List<Order_Line_Item__c> UpdateordList = new List<Order_Line_Item__c>();
            for(Xcode__c xco: xCodeList){
                for(Order_Line_Item__c ordln : ordlnList){

                    Order_Line_Item__c oli = new Order_Line_Item__c();
                    oli.Id = ordln.Id;
                    oli.Xcode__c = xco.Name;
                    oli.Xcode_Id__c = xco.Id;
                    if(bbMap.containsKey(ordln.Xcode_Id__c)){
                        oli.Xcode_lkp__c = bbMap.get(ordln.Xcode_Id__c).Id;
                        UpdateordList.add(oli);
                    }

                    /*Need to create a new record instead of this logic
                    ordln.Xcode__c = xco.Name;
                    ordln.Xcode_Id__c = xco.Id;
                    if(bbMap.containsKey(ordln.Xcode_Id__c)){
                        ordln.Xcode_lkp__c = bbMap.get(ordln.Xcode_Id__c).Id;
                        UpdateordList.add(ordln);
                    }*/
                }
            if(UpdateordList != null && doNotUpdate== True){
                try
                {
                    update UpdateordList;
                }
                catch (DmlException e){
                    system.debug('update error');
                }

            }
          }
        }
        catch(Exception e){
            system.debug('errored');
            ExceptionLog.add('Exception', 'OrderLineItemTriggerHelper', 'UpdateXcodeOnOrderLineItem', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to copy Xcode on OLI.' ,e);
        }
    }
    /*
    ** @author : Adarsh
    ** @date : 05/06/2015
    ** @story : 3486
    ** @element :
    ** @description : Populate NetPrice.
    ** @paramaters : Set of Order Id's, Account Id's
    ** @returns : nothing
    */
    public void PopulateNetPrice (list<Order_Line_Item__c> pNewOrderLineItem){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','PopulateNetPrice ');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        try{

                List<Order_Line_Item__c> UpdateordList = new List<Order_Line_Item__c>();
            /*for(Order_Line_Item__c oli: pNewOrderLineItem){
                    oli.NetPrice__c = oli.AdjustedPrice__c * oli.Quantity2__c;
                    UpdateordList.add(oli);
                }*/

            //Jeff L. This code is not needed - you get this information from the list of objects passed into the methods automatically
            //List<Order_Line_Item__c>ordlnList = [select NetPrice__c,AdjustedPrice__c,Quantity2__c from Order_Line_Item__c where Id in: pNewOrderLineItem] ;
            //system.debug('ordlnList'+ordlnList );

            for(Order_Line_Item__c ordln : pNewOrderLineItem)
            {

                //Order_Line_Item__c newOLI = new Order_Line_Item__c();
                //newOLI.Id = ordln.Id;
                //J Freese 4/6/16 Add a check to prevent Exception = Attempt to de-reference a null object
                /*if (ordln.AdjustedPrice__c != null && ordln.Quantity2__c != null) {
                    newOLI.NetTotalAmount__c = ordln.AdjustedPrice__c * ordln.Quantity2__c;
                }*///I-218373


                        system.debug('RevenueSharePercent' + ordln.Revenue_Share_Percent__c);
                        system.debug('ordln.Agency_Discount_Amount__c' + ordln.Agency_Discount_Amount__c);
                        if(ordln.Revenue_Share_Percent__c != null && ordln.Revenue_Share_Percent__c!= 0.000 ){    //I-199845 & //I-224184 08/10
                            system.debug('Inside AP if');
                            system.debug('ordln.GrossTotalAmount__c' + ordln.GrossTotalAmount__c);
                            ordln.NetTotalAmount__c = ordln.GrossTotalAmount__c - (ordln.Revenue_Share_Percent__c/100 * ordln.GrossTotalAmount__c );
                            system.debug('newOLI.NetTotalAmount__c' + ordln.NetTotalAmount__c);

                        }
                        else if (ordln.Agency_Discount_Amount__c!= null && ordln.Agency_Discount_Amount__c!= 0.00 ){
                            system.debug('Inside AP elseif');
                            system.debug('ordln.GrossTotalAmount__c' + ordln.GrossTotalAmount__c);
                            ordln.NetTotalAmount__c = (ordln.GrossTotalAmount__c - ordln.Agency_Discount_Amount__c);
                            system.debug('ordln.Agency_Discount_Amount__c' + ordln.Agency_Discount_Amount__c);
                            system.debug('newOLI.NetTotalAmount__c' + ordln.NetTotalAmount__c);

                        }
                        else{
                                system.debug('Inside AP else');
                                if (ordln.NetUnitPrice__c != null && ordln.Quantity2__c != null)
                                {
                                    //need to round it to two digits before calcuating
                                    //ordln.NetTotalAmount__c = ordln.NetUnitPrice__c.setScale(2) * ordln.Quantity2__c;
                                    ordln.NetTotalAmount__c = ordln.NetUnitPrice__c.setScale(7) * ordln.Quantity2__c;//S-443302  AP changed scale to 7
                                    system.debug('newOLI.NetTotalAmount__c' + ordln.NetTotalAmount__c);
                                }
                        }

                        //if we are populating the NetTotalAmount, we need to make sure we populate the remaining credit amount as well
                        //I-222762
                        ordln.NetRemainingCreditAmount__c = ordln.NetTotalAmount__c;

            }

           /* if(UpdateordList != null){
                try
                {
                    system.debug('hello1');
                    update UpdateordList;
                    system.debug('hello2');
                }
                catch (DmlException e){
                    system.debug('update error');
                }
            }*/
        }
        catch(Exception e){
            system.debug('errored');
            ExceptionLog.add('Exception', 'OrderLineItemTriggerHelper', 'PopulateNetPrice ', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to populate NetPrice OLI.' ,e);
        }
    }

    /*
    ** @author : Matt F
    ** @date : 05/06/2015
    ** @story : S-328682
    ** @element :
    ** @description : Copy attribute from order line item to line item attribute
    ** @paramaters :
    ** @returns : nothing
    */
     public void CopyAttributes(list<Order_Line_Item__c> pOrderLineItems){


     }

      /*
    ** @author : Appirio (Jeff L)
    ** @date : 01/26/2016
    ** @story : I-182108
    ** @description : consolidates a number of methods that should be run together
    ** @paramaters : list of order line items, map of old orderlineItems
    ** @returns : nothing
    */
 // Commented out as not being referrenced anywhere
    public void populateReportingData(List<Order_Line_Item__c> pNewOrderLineItem, map<Id,Order_Line_Item__c> pOldOrderLineItemMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populatePositionData');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        List<Order_Line_Item__c> oliToUpdate = populateOwnerStartDate(pNewOrderLineItem);

        //populateManagerEmail(oliToUpdate);
        //Jeff L commented out for now, causing error currently when hitting Send To Verification button
        populateManagersLookup(pNewOrderLineItem, pOldOrderLineItemMap);
     //   populateSecondOppSplitLookup(pNewOrderLineItem);
        populatePositionData(pNewOrderLineItem, pOldOrderLineItemMap);
        populateOSDFieldOnLineItem(oliToUpdate);
    }


    /*
    ** @author : Sunny G
    ** @date : 07/23/2015
    ** @story : S-323692
    ** @element :
    ** @description : Earliest Product Start Date grouped by year.
    ** @paramaters :
    ** @returns : nothing
    */
    private void populatePositionData(Order_Line_Item__c[] pNewOrderLineItem, map<Id, Order_Line_Item__c> pOldOrderLineItemMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populatePositionData');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        Boolean isUpdate = false;
        set<id> userId = new set<Id>();
        if(pOldOrderLineItemMap == null){
            isUpdate = false;
        }
        for(Order_Line_Item__c oLI : pNewOrderLineItem){
            If(oLI.Owner_on_Start_Date__c != null && !isUpdate){
                userId.add(oLI.Owner_on_Start_Date__c);
            } else if(oLI.Owner_on_Start_Date__c != null && isUpdate){ //&& oLI.Owner_on_Start_Date__c != pOldOrderLineItemMap.get(oLI.id).Owner_on_Start_Date__c){
                userId.add(oLI.Owner_on_Start_Date__c);
            }
        }

        //Jeff L modified to use new query framework
        map<id, User> userMap = new map<Id, User>();
        for(User u : queryUsersList()){
            userMap.put(u.Id, u);
        }

        for(Order_Line_Item__c oLI : pNewOrderLineItem){

            User usr = userMap.get(oLI.Owner_on_Start_Date__c);
            if(usr != null){
                oLI.Position_Sales_Channel__c = usr.PositionSalesChannel__c;
                oLI.Position_Sales_Group__c = usr.PositionSalesGroup__c;
                oLI.User_Position_Region__c = usr.UserPositionRegion__c;
                oLI.Segment__c = usr.Segment__c;
                oLI.Job_Type__c = usr.Job_Type__c;
                oLI.Organisation__c = usr.Organisation__c;
                oLI.Combined_Region__c = usr.Combined_Region__c;
                oLI.Position_Job_Title__c = usr.PositionJobTitle__c;
                oLI.Region_Group__c = usr.Region_Group__c;
                oLI.Position_Account_Size__c = usr.Position_Account_Size__c;
                oLI.Country__c = usr.country;
            } else {
                oLI.Position_Sales_Channel__c = null;
                oLI.Position_Sales_Group__c = null;
                oLI.User_Position_Region__c = null;
                oLI.Segment__c = null;
                oLI.Job_Type__c = null;
                oLI.Organisation__c = null;
                oLI.Combined_Region__c = null;
                oLI.Position_Job_Title__c = null;
                oLI.Region_Group__c = null;
                oLI.Position_Account_Size__c = null;
                oLI.Country__c = null;
            }
        }
    }

    /*
    ** @author : Sunny G
    ** @date : 07/23/2015
    ** @story : S-323692
    ** @element :
    ** @description : Populates the manager's email
    ** @paramaters :
    ** @returns : nothing
    */
    /*
    private void populateManagerEmail(List<Order_Line_Item__c> orderLineItem){

        map<String,String> userIdToName = new map<String,String>();

        Map<String,String> emptyOwnerAtStartDate = new Map<string,String>();
        Map<String, String> intermediateManager = new Map<String, String>();
        for(Order_Line_Item__c order : orderLineItem){
            if(order.Owner_on_Start_Date__c != null){
                emptyOwnerAtStartDate.put(order.Owner_on_Start_Date__c,'');
            }
        }

        if(emptyOwnerAtStartDate.size() > 0 ){

            intermediateManager = getManagerAndName(emptyOwnerAtStartDate,userIdToName,0);

            intermediateManager = getManagerAndName(intermediateManager,userIdToName,5);

            for(String key : userIdToName.keySet()) {
                System.debug('Key = '+ key + ' value = '+userIdToName.get(key));
            }

            System.debug('userIdToName >>' + userIdToName);
            map<String,String> indexToFieldName = new map<String,String>();

            String fieldName ='';
            for(Order_Line_Item__c oli: orderLineItem) {
                for(String usrToMangName : userIdToName.keySet()) {
                    if(usrToMangName.startsWith(oli.Owner_on_Start_Date__c)) {
                        fieldName = 'Hierarchy_Manager' + usrToMangName.substringAfterLast('~') + '__c';
                        oli.put(fieldName, userIdToName.get(usrToMangName));
                    }
                }
            }
        }
    }
    */

    //Author : Shyam
    public void populateManagersLookup(List<Order_Line_Item__c> pNewOrderLineItem, map<Id, Order_Line_Item__c> pOldOrderLineItemMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populateManagersLookup');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        map<String, List<Id>> userIdwithManagers = new map<String, List<Id>>();
        List<Order_Line_Item_Manager__c> oLIManagersAdd = new List<Order_Line_Item_Manager__c> ();
        Set<String> setOLIDelete = new Set<String> ();
        Set<String> setOLIUpdate = new Set<String> ();
        Boolean isUpdate = true;
        if(pOldOrderLineItemMap == null){
            isUpdate = false;
        }

        String fieldName ='';
        system.debug('check************1' + pNewOrderLineItem);
        system.debug('check************2' + pOldOrderLineItemMap);
        for(Order_Line_Item__c oLI : pNewOrderLineItem){
          //  if(oLI.overwritten_by_Adjustment__c == false){  T-494947
            system.debug('check************3' + oLI.Owner_on_Start_Date__c);
            system.debug(pOldOrderLineItemMap.get(oLI.id).Owner_on_Start_Date__c);
            if (oLI.Owner_on_Start_Date__c != null && !isUpdate){
                userIdwithManagers.put(oLI.Owner_on_Start_Date__c, null);
            }
            else if(oLI.Owner_on_Start_Date__c != null && isUpdate && !oLI.Prevent_Manager_Hierachy_Calculations__c && oLI.Owner_on_Start_Date__c != pOldOrderLineItemMap.get(oLI.id).Owner_on_Start_Date__c){
                userIdwithManagers.put(oLI.Owner_on_Start_Date__c, null);
                system.debug('runnnn 1');
                setOLIDelete.add(oLI.Id);
                for(Integer counter = 1; counter <= 10; counter++){
                    oLI.put('Hierarchy_Manager' + String.valueOf(counter) + '_New__c', null);
                }
            }
            else if(oLI.Owner_on_Start_Date__c == null && isUpdate && !oLI.Prevent_Manager_Hierachy_Calculations__c && oLI.Owner_on_Start_Date__c != pOldOrderLineItemMap.get(oLI.id).Owner_on_Start_Date__c){
                setOLIDelete.add(oLI.Id);
                system.debug('runnnn 2');
                for(Integer counter = 1; counter <= 10; counter++){
                    oLI.put('Hierarchy_Manager' + String.valueOf(counter) + '_New__c', null);
                }
            }
            else if(isUpdate){
                Boolean isNull = false;
                for(Integer counter = 1; counter <= 10; counter++){
                    fieldName = 'Hierarchy_Manager' + String.valueOf(counter) + '_New__c';

                    if(oLI.get(fieldName) == null){
                        isNull = true;
                    }
                    else if(isNull){
                        oLI.addError(Label.Hierarchy_Error_on_OLI_Trigger);
                    }
                    system.debug('runnnn 2' + oLI);

                    if(oLI.get(fieldName) != pOldOrderLineItemMap.get(oLI.id).get(fieldName)){
                        setOLIUpdate.add(oLI.Id);
                        setOLIDelete.add(oLI.Id);
                        system.debug('runnnn 3');
                    }
                }

                if(setOLIUpdate.contains(oLI.Id)){
                    for(Integer counter = 1; counter <= 10; counter++){
                        fieldName = 'Hierarchy_Manager' + String.valueOf(counter) + '_New__c';

                        if(oLI.get(fieldName) != null){
                            oLIManagersAdd.add(new Order_Line_Item_Manager__c(Manager__c = String.valueOf(oLI.get(fieldName)), Order_Line_Item__c = oLI.id, Manager_Hierarchy_Level__c = counter, Sales_Rep_ID__c = oLI.Owner_on_Start_Date__c));
                        }
                    }
                }
              }
          //  }
        }
        system.debug('runnnn 3' + userIdwithManagers);
        if(userIdwithManagers.keySet().size() > 0 ){

            userIdwithManagers = getManagersList(userIdwithManagers);

            for(Order_Line_Item__c oLI : pNewOrderLineItem){
                if (oLI.Owner_on_Start_Date__c != null && (!isUpdate ||
                        (isUpdate && oLI.Owner_on_Start_Date__c != pOldOrderLineItemMap.get(oLI.id).Owner_on_Start_Date__c))
                        && userIdwithManagers.containsKey(oLI.Owner_on_Start_Date__c)){

                    Integer counter = 1;
                    for(Id userId : userIdwithManagers.get(oLI.Owner_on_Start_Date__c)){
                        fieldName = 'Hierarchy_Manager' + String.valueOf(counter) + '_New__c';
                        oLI.put(fieldName, userId);
                        system.debug(fieldName + '@@@@' + userId);
                        oLIManagersAdd.add(new Order_Line_Item_Manager__c(Manager__c = userId, Order_Line_Item__c = oLI.id, Manager_Hierarchy_Level__c = counter, Sales_Rep_ID__c = oLI.Owner_on_Start_Date__c));
                        counter++;
                    }
                }
            }
        }

        system.debug('----populateManagersLookup setOLIDelete '+setOLIDelete);
        if(setOLIDelete.size() > 0){
            List<Order_Line_Item_Manager__c> oLIManagersDelete = [Select Id from Order_Line_Item_Manager__c where Order_Line_Item__c IN :setOLIDelete];
            if(oLIManagersDelete.size() > 0){
                delete oLIManagersDelete;
            }
        }

        system.debug('---- populateManagersLookup oLIManagersAdd '+oLIManagersAdd);
        if(oLIManagersAdd.size() > 0){
            List<Order_Line_Item_Manager__c>managers = populateOrderLineItemManagerFields(oLIManagersAdd);
            system.debug('---- populateManagersLookup managers '+managers);
            insert managers;
            //insert populateOrderLineItemManagerFields(oLIManagersAdd);
            populateSecondOppSplitLookup(pNewOrderLineItem);
        }

    }

    public void populateSecondOppSplitLookup(List<Order_Line_Item__c> pNewOrderLineItem){

        List<OLIM> lstOLIM = new List<OLIM>();
        Set<Id> setOpp = new Set<Id>();
        Set<Id> orderIds = new set<Id>();
        List<Order_Line_Item_Manager__c> olimdelete = new List<Order_Line_Item_Manager__c>();
        for(Order_Line_Item_Manager__c olim : [Select Id, Order_Line_Item__c from Order_Line_Item_Manager__c Where Secondary_Sales_Rep__c = true AND Order_Line_Item__c IN :pNewOrderLineItem]){
            olimdelete.add(olim);
        }
        system.debug('xxxxx - olimdelete '+olimdelete);
        if(olimdelete.size() > 0){
            delete olimdelete;
        }
        for(Order_Line_Item__c oli : [Select Id, Order__c,Order__r.Opportunity__c,Order__r.Opportunity__r.OwnerId FROM Order_Line_Item__c where Id in :pNewOrderLineItem]) {
            OLIM olimObj = new OLIM();
            olimObj.OLI = oli.Id;
            olimObj.orders = oli.Order__c;
            olimObj.oppowner = oli.Order__r.Opportunity__r.OwnerId;
            olimObj.OppId = oli.order__r.Opportunity__c;
            olimObj.OppSplitOwnerIdMap = new Map<Id, Id>();
            setOpp.add(oli.order__r.Opportunity__c);
            orderIds.add(oli.Order__c);

            lstOLIM.add(olimObj);
        }
        if (setOpp.size() <= cutoff){ //JFreese Appirio S-435483 4/10/17
            system.debug('xxxxx - lstOLIM '+lstOLIM);
        }

        Set<Id> setSplitOwnerId = new Set<Id>();
        map<String, List<Id>> userIdwithManagers = new map<String, List<Id>>();
        if(!setOpp.isEmpty() && !lstOLIM.isEmpty()){
        For(OpportunitySplit opptySplit : [Select SplitOwnerId,Id,OpportunityId FROM OpportunitySplit where OpportunityId in : setOpp]) {
            for(OLIM olimObj : lstOLIM) {
                if(olimObj.OppId == opptySplit.OpportunityId) {
                    //olimObj.ManagerId.add(opptySplit.SplitOwnerId);
                    if(olimObj.oppowner != opptySplit.SplitOwnerId){
                    olimObj.OpptySplitOwnerId = opptySplit.SplitOwnerId;
                    olimObj.OppSplitOwnerIdMap.put(opptySplit.Id,opptySplit.SplitOwnerId);
                    userIdwithManagers.put(opptySplit.SplitOwnerId, new List<Id>());
                   }
                }
            }
        }
        }
        if (setOpp.size() <= cutoff){ //JFreese Appirio S-435483 4/10/17
            system.debug('xxxxx - userIdwithManagers '+userIdwithManagers);
            system.debug('xxxxx - getManagersList' + getManagersList(userIdwithManagers) );
        }
        //getManaGERS
        if(!userIdwithManagers.keySet().isEmpty()){
            userIdwithManagers = getManagersList(userIdwithManagers);
        }
        if (setOpp.size() <= cutoff){ //JFreese Appirio S-435483 4/10/17
            system.debug('xxxxx - userIdwithManagers after managers '+userIdwithManagers);
            system.debug('xxxxx - userIdwithManagers keySet() '+userIdwithManagers.keyset());
        }
        // list secondMap = new Map<Id,List<Id>>();
        List<Order_Line_Item_Manager__c> oLIManagersAdd = new List<Order_Line_Item_Manager__c>();
        Integer counter = 0;
        Integer mastercounter = 0;
        if(!userIdwithManagers.keySet().isEmpty()){
        for(OLIM olimObj : lstOLIM) {
            //mastercounter = 1;
            if(!olimObj.OppSplitOwnerIdMap.keyset().isEmpty()){
            for(Id oppSplitId : olimObj.OppSplitOwnerIdMap.keyset()) {
                if(userIdwithManagers.containsKey(olimObj.OppSplitOwnerIdMap.get(oppSplitId))){
                    // Create 11th

                    //Sylvester Agyen - (appirio) - commented out due to I-213353 4/22/16
                    //oLIManagersAdd.add(new Order_Line_Item_Manager__c(Manager__c = olimObj.OppSplitOwnerIdMap.get(oppSplitId),
                    //                                                Secondary_Sales_Rep__c = true,
                    //                                                Manager_Hierarchy_Level__c = mastercounter,
                    //                                                Order_Line_Item__c = olimObj.OLI,
                    //                                                Sales_Rep_ID__c = olimObj.OppSplitOwnerIdMap.get(oppSplitId)));


                    counter = mastercounter + 1;

                    if(userIdwithManagers.containsKey(olimObj.OppSplitOwnerIdMap.get(oppSplitId))){

                        for(Id mId : userIdwithManagers.get(olimObj.OppSplitOwnerIdMap.get(oppSplitId))){

                            if (setOpp.size() <= cutoff || mId == debugId){ //JFreese Appirio S-435483 4/10/17
                                system.debug('xxxxx - mId *******' + mId);
                            }
                            oLIManagersAdd.add(new Order_Line_Item_Manager__c(Manager__c = mid,
                                                                              Secondary_Sales_Rep__c = true,
                                                                              Manager_Hierarchy_Level__c = counter,
                                                                              Order_Line_Item__c = olimObj.OLI,
                                                                              Sales_Rep_ID__c = olimObj.OppSplitOwnerIdMap.get(oppSplitId)));
                            counter ++;

                        }
                    }
                    mastercounter = 0;
                }
            }

        }
        }
        }

        system.debug('xxxxx - oLIManagersAdd '+oLIManagersAdd);
        if(oLIManagersAdd.size() > 0){
            insert populateOrderLineItemManagerFields(oLIManagersAdd);
        }

       /* final string METHODNAME = CLASSNAME.replace('METHODNAME','populateSecondOppSplitLookup');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        map<String, List<Id>> userIdwithManagers = new map<String, List<Id>>();
        List<Id> userManager = new List<Id>();
        Map<Id,Order_Line_Item__c> Ordermap = new Map<Id,Order_Line_Item__c>();
        List<Id> oppList = new List<Id>();
        List<User> userID = new List<User>();
        List<Order_Line_Item_Manager__c> oLIManagersAdd = new List<Order_Line_Item_Manager__c> ();
        List<Order_Line_Item_Manager__c> oLIManagersDelete = new List<Order_Line_Item_Manager__c> ();

        system.debug(pNewOrderLineItem);

        // collecting basics
        for(Order_Line_Item__c oli : pNewOrderLineItem){
            oppList.add(oli.Order__r.Opportunity__c);
            Ordermap.put(oli.Order__r.Opportunity__c,oli);
            userID.add(oli.Order__r.Opportunity__r.Owner);
        }
        system.debug('check 1' + Ordermap);

        // Delete all olim to re-arrange order line item manager again.
        for(Order_Line_Item_Manager__c olim : [Select Secondary_Sales_Rep__c, Id, Order_Line_Item__c  from Order_Line_Item_Manager__c where Order_Line_Item__c IN : pNewOrderLineItem and Secondary_Sales_Rep__c = true]){
                    oLIManagersDelete.add(olim);
        }



        if(!oppList.isEmpty()){
            for(Order_Line_Item__c oli : pNewOrderLineItem){
                Integer counter = 11;
                for(Opportunitysplit oppFirst : [Select SplitOwnerId,OpportunityId from OpportunitySplit where OpportunityId IN :Ordermap.keySet() AND SplitOwnerId NOT IN :userID]){
                    if(Ordermap.containsKey(oppFirst.OpportunityId)){
                        oLIManagersAdd.add(new Order_Line_Item_Manager__c(Manager__c = oppFirst.SplitOwnerId,Secondary_Sales_Rep__c = true,Manager_Hierarchy_Level__c = counter, Order_Line_Item__c = oli.id));
                        userManager.add(oppFirst.SplitOwnerId);
                        counter = counter  + 10;
                    }
                }
            }
         }


         if(oLIManagersDelete.size()>0){
            delete oLIManagersDelete;
        }
        system.debug('finaly' + oLIManagersAdd);
        if(oLIManagersAdd.size() > 0){
          insert oLIManagersAdd;
        } */

    }

    public class OLIM{

        Id OLI;
        Id orders;
        Id OppId;
        Id oppowner;
        Map<Id,Id> OppSplitOwnerIdMap = new Map<Id,Id>();
        Id OpptySplitOwnerId;
        //List<Id> ManagerId;
        public OLIM() {
            //ManagerId = new List<Id>();
        }
    }
    /*
    ** @author : Sunny G
    ** @date : 07/23/2015
    ** @story : S-323692
    ** @element :
    ** @description : Populates the manager's Alias
    ** @paramaters :
    ** @returns : nothing
    */
    /*
    private Map<String,String> getManagerAndName(Map<String,String> userId , map<String, String> userIdToName , Integer rank){

        Map<String,String> intermediateManager = new Map<String , String>();
        String key = '';
        //Jeff Logic was incapable of quering 10 managers . We atleast need 2 queries to populate 10 fields of manager.
        //Jeff's logic was populating the same managers in fields 6 to 10 as it was in 1 to 5.
        for(User usr : [Select Id, managerId , manager.Alias , manager.managerId , manager.manager.Alias ,
                                   manager.manager.managerId , manager.manager.manager.Alias ,
                                   manager.manager.manager.managerId , manager.manager.manager.manager.Alias,
                                   manager.manager.manager.manager.managerId , manager.manager.manager.manager.manager.Alias
                                   From User
                                   where id IN : userId.keySet()]){
            String currentuserId =  String.isNotBlank(userId.get(usr.Id)) ? userId.get(usr.Id) : usr.Id;

            if(usr.managerId != null){
                key = currentuserId + '~' + usr.managerId + '~' + string.valueOf(1 + rank);
                userIdToName.put(key,usr.manager.Alias);
            }

            if(usr.manager.managerId != null){
                key = currentuserId + '~' + usr.manager.managerId + '~' + string.valueOf(2 + rank);
                userIdToName.put(key  , usr.Manager.Manager.Alias ) ;
            }
            if(usr.manager.manager.managerId != null){
                key = currentuserId + '~' + usr.manager.manager.managerId + '~' + string.valueOf(3 + rank);
                userIdToName.put(key , usr.manager.manager.manager.Alias ) ;
            }
            if(usr.manager.manager.manager.managerId != null){
                key = currentuserId + '~' + usr.manager.manager.manager.managerId + '~' + string.valueOf(4 + rank);
                userIdToName.put(key , usr.manager.manager.manager.manager.Alias ) ;
            }
            if(usr.manager.manager.manager.manager.managerId != null){
                key = currentuserId + '~' + usr.manager.manager.manager.manager.managerId + '~' + string.valueOf(5 + rank);
                userIdToName.put(key , usr.manager.manager.manager.manager.manager.Alias ) ;

                intermediateManager.put(usr.manager.manager.manager.manager.managerId,usr.Id);
            }
        }
        return intermediateManager;
    }
        */

    // Author : Shyam
    private map<String, List<Id>> getManagersList(map<String, List<Id>> userIdwithManagers){

        Map<String,String> intermediateManager = new Map<String , String>();

        for(User usr : [Select Id, managerId, manager.managerId, manager.manager.managerId, manager.manager.manager.managerId,
                                   manager.manager.manager.manager.managerId from User
                                   where id IN : userIdwithManagers.keySet()]){

            userIdwithManagers.put(usr.Id, new List<Id>());
            if(usr.managerId != null){
                userIdwithManagers.get(usr.Id).add(usr.managerId);
            }
            if(usr.manager.managerId != null){
                userIdwithManagers.get(usr.Id).add(usr.manager.managerId);
            }
            if(usr.manager.manager.managerId != null){
                userIdwithManagers.get(usr.Id).add(usr.manager.manager.managerId);
            }
            if(usr.manager.manager.manager.managerId != null){
                userIdwithManagers.get(usr.Id).add(usr.manager.manager.manager.managerId);
            }
            if(usr.manager.manager.manager.manager.managerId != null){
                userIdwithManagers.get(usr.Id).add(usr.manager.manager.manager.manager.managerId);
                intermediateManager.put(usr.manager.manager.manager.manager.managerId, usr.Id);
            }
        }
        if(intermediateManager.keySet().size() > 0){
            for(User usr : [Select Id, managerId, manager.managerId, manager.manager.managerId, manager.manager.manager.managerId,
                                       manager.manager.manager.manager.managerId from User
                                       where id IN : intermediateManager.keySet()]){

                if(usr.managerId != null){
                    userIdwithManagers.get(intermediateManager.get(usr.Id)).add(usr.managerId);
                }
                if(usr.manager.managerId != null){
                    userIdwithManagers.get(intermediateManager.get(usr.Id)).add(usr.manager.managerId);
                }
                if(usr.manager.manager.managerId != null){
                    userIdwithManagers.get(intermediateManager.get(usr.Id)).add(usr.manager.manager.managerId);
                }
                if(usr.manager.manager.manager.managerId != null){
                    userIdwithManagers.get(intermediateManager.get(usr.Id)).add(usr.manager.manager.manager.managerId);
                }
                if(usr.manager.manager.manager.manager.managerId != null){
                    userIdwithManagers.get(intermediateManager.get(usr.Id)).add(usr.manager.manager.manager.manager.managerId);
                }
            }
        }
        return userIdwithManagers;
    }

    /*
    ** @author : Appirio Inc
    ** @date : ?
    ** @story : ?
    ** @element :
    ** @description : Populates the owner on start date field based upon the order status
    ** @paramaters :
    ** @returns : nothing
    */
   private List<Order_Line_Item__c> populateOwnerStartDate(List<Order_Line_Item__c> orderLineItem){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populateOwnerStartDate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        //List<Order_Line_Item__c> updatedList = new List<Order_Line_Item__c>();
        map<Id , List<Order_Line_Item__c>> orderIdToOrderLineItem = new map<Id , List<Order_Line_Item__c>>();

        Set<String> orderStatus = new Set<String>{'Verified' , 'Resubmitted' , 'Negated' , 'Paid in Full' , 'Invoiced' , 'Closed'};

        for(Order_Line_Item__c orderItem : orderLineItem){
            system.debug('Is Owner ON Start Date NUll? ' + orderItem.Owner_on_Start_Date__c);
            if(orderItem.Owner_on_Start_Date__c == null){
                if(!orderIdToOrderLineItem.containsKey(orderItem.Order__c) ){
                    orderIdToOrderLineItem.put(orderItem.Order__c, new List<Order_Line_Item__c>());
                }

                    orderIdToOrderLineItem.get(orderItem.Order__c).add(orderItem);
            }
        }

        if(orderIdToOrderLineItem != null && orderIdToOrderLineItem.size() > 0){
            for(Order__c order : queryOrderList()){
                if(orderStatus.contains(order.OrderStatus__c)){
                    system.debug(order.Id);
                    if(orderIdToOrderLineItem.get(order.Id) != null){
                        for(Order_Line_Item__c orderItem: orderIdToOrderLineItem.get(order.Id)){
                            //if(!string.isBlank(order.WebOrderNumber__c)){
                            if(order.OrderStatus__c == 'Verified'){
                                orderItem.Owner_on_Start_Date__c = order.Account__r.OwnerId; //added by Deepanshu for S-467511, to set OSD = Account Owner, only if Order is in Verified Status
                            }
                            else{
                                orderItem.Owner_on_Start_Date__c = order.PrimarySalesRep__c; // if order not 'Verified', update OSD with Rep
                            }
                                // Since it is master detail so it cannot be null
                          //  } else{
                                //orderItem.Owner_on_Start_Date__c = order.Account__r.OwnerId;
                            //}
                            //updatedList.add(orderItem);
                        }
                    }
                }
            }
        }

        return orderLineItem;
    }

    /*
    ** @author : Appirio Inc
    ** @date : ?
    ** @story : ?
    ** @element :
    ** @description : Jeff L moved logic into before trigger instead of after, also moved to handler
    ** @paramaters :
    ** @returns : nothing
    */
  /*  public void setPartnerRevenueShareOnLineItems(Order_Line_Item__c[] orderLineItems){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','setPartnerRevenueShareOnLineItems');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        set<string> productFamilySet = new Set<string>();
        set<string> siteChannelds = new Set<string>();
        map<string, string> mapProdFamilyToPartner = new map<string, string>();

        for(Order_Line_Item__c lineItem : orderLineItems) {

            if(lineItem.ProductFamily__c != null){
                productFamilySet.add(lineItem.ProductFamily__c);
            }
        }

        map<Id, Order__c> orderMap = new map<Id, Order__c> ();
        //Jeff L updated logic to use new query framework
        for(Order__c o : queryOrderList()){
            orderMap.put(o.Id,o);
        }

        for(Order__c o : orderMap.values()){
            if(o.Site_Channel_ID__c != null){
                siteChannelds.add(o.Site_Channel_ID__c);
            }
        }


        for(Partner_Revenue_Share__c partnerRevenueShare : [Select Id, Product_Family__c, SiteChannelID__c from Partner_Revenue_Share__c
                                                  Where Product_Family__c IN :productFamilySet and SiteChannelID__c IN :siteChannelds] ) {

            mapProdFamilyToPartner.put(partnerRevenueShare.Product_Family__c+partnerRevenueShare.SiteChannelID__c, partnerRevenueShare.Id);
        }


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


            if(mapProdFamilyToPartner.containsKey(key)) {
                lineItem.Partner_Revenue_Share__c  =  mapProdFamilyToPartner.get(key);
            }
        }
    } */


    /*
    ** @author : Appirio Inc
    ** @date : ?
    ** @story : ?
    ** @element :
    ** @description : Jeff L moved logic into trigger helper, Update By Vivek for T-434693
    ** @paramaters :
    ** @returns : nothing
    */
    /*I-262375 / S-470803 Jfreese Appirio Revert T-434693 per Matt Keefe
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

        for(Order__c order : queryOrderList()){
            if(orderIdToOrderLineItem.containsKey(order.Id)) // Added by Rohit B on 06/Nov/2015
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

    private void populateOSDFieldOnLineItem(List<Order_Line_Item__c> orderLineItem) {

        final string METHODNAME = CLASSNAME.replace('METHODNAME','populateOSDFieldOnLineItem');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        set<Id> userIds = new set<Id>();
        set<Id> prodIds = new set<Id>();
        set<Id> orderIds = new set<Id>();
        Set<String> orderStatus = new Set<String>{'Verified' , 'Resubmitted' , 'Negated' , 'Paid in Full' , 'Invoiced' , 'Closed'};
        system.debug('$$testing$$' +orderLineItem);
        for(Order_Line_Item__c lineItem : orderLineItem){
        system.debug('@@@lineItem@@'  +lineItem);
        //system.assert(lineItem.Owner_on_Start_Date__c != null , true);
            if(lineItem.Owner_on_Start_Date__c != null){
                userIds.add(lineItem.Owner_on_Start_Date__c);
            }
            if(lineItem.Product__c != null){
                prodIds.add(lineItem.Product__c);
            }
            if(lineItem.order__c != null){
                orderIds.add(lineItem.order__c);
            }

        }

        map<Id,User> mapUser = new map<Id,User>([Select Id, Region_Group__c, Country, ManagerId,PositionSalesChannel__c,Position_Organization__c,UserPositionRegion__c,
                                                 Segment__c, PositionSalesGroup__c, PositionJobTitle__c, Combined_Region__c,Position_Account_Size__c, Job_Type__c
                                                 from User Where Id = :userIds]);

        //map<Id,Product2> mapProduct = new map<Id,Product2>([Select Id, Quota_Type__c from Product2 Where Id IN :prodIds]);

        map<Id,Order__c> mapOrder = new map<Id,Order__c>([Select Id, OrderStatus__c from Order__c Where Id IN :orderIds and OrderStatus__c IN :orderStatus]);

        for(Order_Line_Item__c lineItem : orderLineItem){
            if(mapUser.containskey(lineItem.Owner_on_Start_Date__c) && mapOrder.containskey(lineItem.Order__c) && lineItem.overwritten_by_Adjustment__c == false ) {

                lineItem.Country_based_on_OSD__c = mapUser.get(lineItem.Owner_on_Start_Date__c).Country;
                lineItem.Sales_Channel_based_on_OSD__c = mapUser.get(lineItem.Owner_on_Start_Date__c).PositionSalesChannel__c;
                lineItem.Organization_based_on_OSD__c =  mapUser.get(lineItem.Owner_on_Start_Date__c).Position_Organization__c;
                lineItem.Region_based_on_OSD__c =  mapUser.get(lineItem.Owner_on_Start_Date__c).UserPositionRegion__c;
                lineItem.Segment_based_on_OSD__c =  mapUser.get(lineItem.Owner_on_Start_Date__c).Segment__c;
                lineItem.Manager_of_OSD__c =  mapUser.get(lineItem.Owner_on_Start_Date__c).ManagerId;
                lineItem.Region_Group_based_on_OSD__c =  mapUser.get(lineItem.Owner_on_Start_Date__c).Region_Group__c;
                lineItem.Position_Sales_Group_based_on_OSD__c =  mapUser.get(lineItem.Owner_on_Start_Date__c).PositionSalesGroup__c;
                lineItem.Position_Job_Title_based_on_OSD__c =  mapUser.get(lineItem.Owner_on_Start_Date__c).PositionJobTitle__c;
                lineItem.Combined_Region_based_on_OSD__c =  mapUser.get(lineItem.Owner_on_Start_Date__c).Combined_Region__c;
                lineItem.Position_Account_Size_based_on_OSD__c =  mapUser.get(lineItem.Owner_on_Start_Date__c).Position_Account_Size__c;
                lineItem.Job_Type_based_on_OSD__c =  mapUser.get(lineItem.Owner_on_Start_Date__c).Job_Type__c;

                //Commented out by Sylvester Agyen - (Appirio) - Line is overriding previous changes in another class
                //if(mapProduct.containskey(lineItem.Product__c)) {
                //    lineItem.Quota_Type__c = mapProduct.get(lineItem.Product__c).Quota_Type__c;

                //}
            }
        }
     }


     public void populateRevenueShareTypeAndPercent(List<Order_Line_Item__c> orderLineItem){

         Map<Id,Product2> productIDMap = new Map<Id,Product2>();
         set<Id> prodIDs = new set<Id>();

         for(Order_Line_Item__c oliFirst : orderLineItem){
            if(oliFirst.Product__c != null){
                prodIDs.add(oliFirst.Product__c);
            }
         }

        if(!prodIDs.isEmpty()){
            for(Product2 pr : [ Select Id, APTPS_Rev_Share__c, APTPS_Rev_Share_Type__c
                                from Product2 where Id IN :prodIDs ]){
                 productIDMap.put(pr.Id, pr);
             }
         }


         for(Order_Line_Item__c oliFirst : orderLineItem){

             if(productIDMap.containsKey(oliFirst.Product__c)){
                oliFirst.Rev_Share_Type__c= productIDMap.get(oliFirst.Product__c).APTPS_Rev_Share_Type__c;
                oliFirst.Rev_Share__c= productIDMap.get(oliFirst.Product__c).APTPS_Rev_Share__c;
             }
         }

     }

    /*
    ** @author : Appirio Inc (Jeff L)
    ** @date : 10/30/2015
    ** @description : This method will popoulate the Currency on the order line item so that it matches it's order
    ** @paramaters : list of order line items
    ** @returns : nothing
    */
     public void populateOrderLineitemFieldLineItemCurrency(List<Order_Line_Item__c> pNewOrderLineItem ){
        //put together a map of order ID to line item, then get the orders and update the line items currency
        Map<Id,List<Order_Line_Item__c>> orderToOliMap = new Map<Id,List<Order_Line_Item__c>>();
        for(Order_Line_Item__c oli : pNewOrderLineItem){
            if(orderToOliMap.get(oli.Order__c) == null){
                orderToOliMap.put(oli.Order__c, new List<Order_Line_Item__c>());
            }
            orderToOliMap.get(oli.Order__c).add(oli);
        }

        for(Order__c order : queryOrderList()){
           for(Order_Line_Item__c oli :orderToOliMap.get(order.Id)){
                oli.CurrencyIsoCode = order.CurrencyIsoCode;
           }
        }
     }


    /*
    ** @author : Appirio Inc (Gaurav G)
    ** @date : 10/28/2015
    ** @description : This method will sync the order line items with their respective opportunity line items
    ** @paramaters : list of order line items, map of order line items
    ** @returns : nothing
    */
    public void syncLineItemsWithOpportunityLineItems(Order_Line_Item__c[] pNewOrderLineItem , Map<id ,Order_Line_Item__c> mapNewOrderLineItems ){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','syncLineItemsWithOpportunityLineItems');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Set<String> orderStatus = new Set<String>{'Verified' , 'Resubmitted' , 'Negated' , 'Paid in Full' , 'Invoiced' , 'Closed'};

        list<Order_Line_Item__c> lstUpdatedOrderLineItems = [SELECT ProposalLineItem__c ,
                                                             Product__c,
                                                             Sales_credit__c ,
                                                             GrossTotalAmount__c ,
                                                             NetTotalAmount__c ,
                                                             NetUnitPrice__c,
                                                             Organisation__c,
                                                             Product__r.ProductCode,
                                                             LineType__c,
                                                             OptionId__c,
                                                             ProposalLineItem__r.Apttus_Proposal__Product__c ,
                                                             ProposalLineItem__r.Gross_Total__c,
                                                             ProposalLineItem__r.Quantity1__c ,
                                                             //ProposalLineItem__r.Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__c  ,
                                                             Quantity2__c ,
                                                             Order__r.OrderStatus__c,
                                                             Order__r.Opportunity__c ,
                                                             Order__r.Opportunity__r.CurrencyIsoCode,
                                                             Order__r.Opportunity__r.Organization__c,
                                                             AttributeValueId__r.Posting_Locations__c, //SBerron - S-473201 - 03/14/17
                                                             AttributeValueId__r.Country__c
                                                             FROM Order_Line_Item__c
                                                             WHERE Id IN : pNewOrderLineItem
                                                             //AND ProposalLineItem__c != null
                                                             AND (Product__c != null OR ProposalLineItem__r.Apttus_Proposal__Product__c != Null)
                                                            AND order__r.Opportunity__c != null];

        system.debug('syncMETHOD - lstUpdatedOrderLineItems '+lstUpdatedOrderLineItems);

        set<id> setOpportunityIds = new set<id>();
        set<id> setProducts = new set<id>();
        set<string> oppCurrencyISOCode = new set<string>();

        //SBerron - S-473201 - 03/14/17
        //get picklist values for country
        Schema.DescribeFieldResult fieldResult = OpportunityLineItem.Split_Country__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        Set<String> lstPickvals=new Set<String>();
        for (Schema.PicklistEntry a : ple ) {
            lstPickvals.add(a.getValue());
        }
        System.debug('----lstPickvals ' + lstPickvals);

        list<OpportunityLineItem> lstOppLineItemToUpdate = new list<OpportunityLineItem>();
        list<OpportunityLineItem> lstOppLineItemToInsert = new list<OpportunityLineItem>();

        if(lstUpdatedOrderLineItems.size() > 0 && !trigger.isDelete){
            system.debug('syncMETHOD - RUNNING 1 ');
            for(Order_Line_Item__c oLI : lstUpdatedOrderLineItems){
                setOpportunityIds.add(oLI.Order__r.Opportunity__c);
                Id oliProductId = getProductIdFromOLI(oLI);
                if(oliProductId != null){
                    setProducts.add(oliProductId);
                }
                 oppCurrencyISOCode.add(oLI.Order__r.Opportunity__r.CurrencyIsoCode);
            }

            system.debug('syncMETHOD %%%setProducts%%' +setProducts);

            List<PriceBookEntry> priceBookList = [SELECT Id, Product2Id, Product2.Id, Product2.Name
                                                  FROM PriceBookEntry
                                                   WHERE Product2Id IN : setProducts
                                                  /*AND PriceBook2.isStandard=true*/
                                                  AND CurrencyIsoCode IN:oppCurrencyISOCode
                                                 ];
            system.debug('syncMETHOD Currency ISO code ' + oppCurrencyISOCode);
            system.debug('syncMETHOD %%priceBookList%% ' + priceBookList);
            map < id , id > mapProductPricebook = new map < id , id >();
            for(PriceBookEntry pBE : priceBookList){
                if(!mapProductPricebook.containskey(pBE.Product2Id))
                    mapProductPricebook.put(pBE.Product2Id ,  pBE.id );

            }
            Map<id , OpportunityLineItem> mapOppLineItems= new Map<id , OpportunityLineItem>([SELECT Product2Id ,
                                                                                              PricebookEntryId ,
                                                                                              OpportunityId ,
                                                                                              Order_Line_Item_Custom__c ,
                                                                                              Proposal_Line_Item__c,
                                                                                              TotalPrice,
                                                                                              LockTotalPrice__c
                                                                                              FROM OpportunityLineItem
                                                                                              where OpportunityId IN : setOpportunityIds]);
            system.debug('syncMETHOD  mapOppLineItems '+ mapOppLineItems);


            Map<id , list<OpportunityLineItem>> mapOppToOppLineItems = new Map<id , list<OpportunityLineItem>>();
            for(OpportunityLineItem oppLineItem : mapOppLineItems.values()){

                if(!mapOppToOppLineItems.containskey(oppLineItem.OpportunityId))
                    mapOppToOppLineItems.put(oppLineItem.OpportunityId , new list<OpportunityLineItem>());

                mapOppToOppLineItems.get(oppLineItem.OpportunityId).add(oppLineItem);
            }

            OpportunityLineItem  oppLineItemToInsert;
            Boolean flagToInsert ;

            //JFreese Appirio 3/2/17 S-456572
            Integer index;
            Integer notCredit; //Correction factor for standard (1) vs credit (-1)
            if (OrderTriggerHandler.CreatingCreditOpportunity == true){notCredit=-1;}
            else {notCredit=1;}
            system.debug('^^^OrderTriggerHandler.CreatingCreditOpportunity='+OrderTriggerHandler.CreatingCreditOpportunity+', notCredit='+notCredit);

            for(Order_Line_Item__c oLI : lstUpdatedOrderLineItems){
                /* Jeff L -  this new logic is to make sure that we are NOT attepmting to sync the
                Quote Bundle order line item for quote bundles we have all the products listed in the option field
                and one extra product for the QuoteBundle itself. we only want to sync the "real" products and not
                the quote bundle product. So lets test right at the beginning.
                */

                //JFreese Appirio 3/2/17 S-456572
                for (Integer i=0; i < pNewOrderLineItem.size(); i++){
                    if (pNewOrderLineItem[i].Id == oLI.Id) {index=i;}
                }

                if(oLI.Product__r.ProductCode != null && oLI.Product__r.ProductCode.equalsIgnoreCase('QUOTE BUNDLE') && oLI.LineType__c == 'Product/Service'){
                    continue;
                }

                flagToInsert = True ;
                system.debug('syncMETHOD mapOppToOppLineItems.containskey: '+ mapOppToOppLineItems.containskey(oLI.Order__r.Opportunity__c));
                if(mapOppToOppLineItems.containskey(oLI.Order__r.Opportunity__c)){

                    for(OpportunityLineItem oppLineItem : mapOppToOppLineItems.get(oLI.Order__r.Opportunity__c)){
                        System.debug('----IsLocked? ' + oppLineItem.LockTotalPrice__c);
                        if(oppLineItem.Order_Line_Item_Custom__c == oLI.id ||
                            (oppLineItem.Proposal_Line_Item__c != null && (oppLineItem.Proposal_Line_Item__c == oLi.ProposalLineItem__c))) {
                            flagToInsert = false ;
                            oppLineItem.Order_Line_Item_Custom__c = oLI.Id;
                            oppLineItem.Proposal_Line_Item__c = oLi.ProposalLineItem__c ;

                            if(oppLineItem.LockTotalPrice__c == false) {
                                //JFreese Appirio 3/28/16 I-266088 Per Manisha write back gross for all
                                oppLineItem.TotalPrice =   oLI.GrossTotalAmount__c * notCredit;
                            }

                            //JFreese Appirio 3/2/17 S-456572
                            /*3/9/17 Disable this resurrected check as it is thrown incorrectly when the Gross Credit Amount (GCA)
                              is specified.  Manisha agreed that we do not need it, as we control valid data at the
                              front end of the credit request process ensuring either a quant or GCA are provided.
                            if(oLI.Quantity2__c == null || oLI.Quantity2__c == 0){ //JFreese Appirio 3/1/17 S-456572
                                //mapNewOrderLineItems.get(oLI.Id).adderror('Please set a non-zero quantity in Order line item');
                                pNewOrderLineItem[index].adderror('Please set a non-zero quantity in Order line item');
                               return ;
                            }*/

                            //JFreese Appirio 3/2/17 S-456572
                            oppLineItem.Quantity = oLI.Quantity2__c * notCredit;
                            lstOppLineItemToUpdate.add(oppLineItem);
                        }
                    }
                }

                if(flagToInsert == True){
                    //if this is a quote bundle product then we get the product from the option field, if it isn't then we can just grab it from the
                    //the regular product field OR the proposalLineItem product field (if it exists)
                    Id productId = getProductIdFromOLI(oLI);

                    //if this is null we have no product and probably have bigger issues
                    if(productId == null){
                        continue;
                    }

                    oppLineItemToInsert = new OpportunityLineItem();

                    oppLineItemToInsert.OpportunityId = oLI.Order__r.Opportunity__c ;
                    if( mapProductPricebook.containsKey(productId)){
                        oppLineItemToInsert.PricebookEntryId = mapProductPricebook.get(productId);
                    } else {
                        //mapNewOrderLineItems.get(oLI.Id).adderror('No PriceBookEntry record found for product ID = ' + productId + ' and Currency ISO code ' + oppCurrencyISOCode);
                        //JFreese Appirio 3/1/17 S-456572
                        pNewOrderLineItem[index].adderror('No PriceBookEntry record found for product ID = ' + productId + ' and Currency ISO code ' + oppCurrencyISOCode);
                        return;
                    }

                    /*JFreese Appirio 3/1/17 S-456572 This check never worked before, though we did not know it because
                      it only checked for null, not for zero.  When I added zero I found that it could not add an error
                      to mapNewOrderLineItems.get(oLI.Id).  Instead the error needs to be added to the original
                      oli in the pNewOrderLineItem list*/
                    /*3/9/17 Disable this resurrected check as it is thrown incorrectly when the Gross Credit Amount (GCA)
                      is specified.  Manisha agreed that we do not need it, as we control valid data at the
                      front end of the credit request process ensuring either a quant or GCA are provided.
                    if(oLI.Quantity2__c == null || oLI.Quantity2__c == 0){
                        //mapNewOrderLineItems.get(oLI.Id).adderror('Please add a non zero quantity in Order line item');
                        pNewOrderLineItem[index].adderror('Please set a non-zero quantity in Order line item');
                        return ;
                    }*/

                    system.debug('Current OLI ' + oLI.Id + ' Current OLI net total? ' + oLI.NetTotalAmount__c);
                    //Order_Line_Item__c testingOLI = mapNewOrderLineItems.get(oLI.Id);
                    system.debug('Current OLI - quantity and Net Unit Price ' + oLI.Quantity2__c + ' ' + oLI.NetUnitPrice__c);

                    //If this is NA and an Insert NetTotalAmount__c may be blank, it's
                    //a field that gets calculated and there is a good chance it is not populated
                    //at this point.  If that is the case we can do the calculation ourselves since it is simple
                    if (oppLineItemToInsert.LockTotalPrice__c == false) {
                        //JFreese Appirio 3/28/16 I-266088 Per Manisha write back gross for all
                        oppLineItemToInsert.TotalPrice =   oLI.GrossTotalAmount__c * notCredit;

                        if(oppLineItemToInsert.TotalPrice == null){
                            oppLineItemToInsert.TotalPrice = 0;
                        }

                        /*JFreese Appirio 3/16/17 S-456572 If the credit OLI was created by Amount (not Inventory)
                          then the Quantity2__c is null.  If so, set the Opp LI Quantity to 1 (* notCredit)*/
                        if (oLI.Quantity2__c == null || oLI.Quantity2__c == 0){
                            oppLineItemToInsert.Quantity = 1 * notCredit;
                        }else{
                            oppLineItemToInsert.Quantity = oLI.Quantity2__c * notCredit;
                        }
                        oppLineItemToInsert.Order_Line_Item_Custom__c = oLI.Id;

                        //SBerron - S-473201 - 03/14/17
                        //if we are inserting credit opportunity line items, set the split country to calculate splits
                        if (OrderTriggerHandler.CreatingCreditOpportunity != null && OrderTriggerHandler.CreatingCreditOpportunity) {
                            System.debug('----opplineitem for credit oppty');

                            String postingLocation = oLI.AttributeValueId__r.Posting_Locations__c;
                            String attributeCountry = oli.AttributeValueId__r.Country__c;
                             System.debug('----postingLocation ' + postingLocation);
                             System.debug('----attributeCountry ' + attributeCountry);
                            if (postingLocation != null && lstPickvals.contains(postingLocation)) {
                                oppLineItemToInsert.Split_Country__c = postingLocation;
                            }
                            else if (attributeCountry != null && lstPickvals.contains(attributeCountry)) {
                                oppLineItemToInsert.Split_Country__c = attributeCountry;
                            }
                        }

                        lstOppLineItemToInsert.add(oppLineItemToInsert);
                        system.debug('OLI details: ');
                        system.debug(oppLineItemToInsert);
                    }
                }
            }
        }
        if(lstOppLineItemToInsert.size() > 0){
            system.debug('List of line items to insert');
            for(OpportunityLineItem opLineItem : lstOppLineItemToInsert){
                system.debug(opLineItem);
            }

           insert lstOppLineItemToInsert;
        }

        if(lstOppLineItemToUpdate.size() > 0){
            update lstOppLineItemToUpdate;
        }
    }

    /*Author: Jeff Lescarbeau (Appirio)
    * Method: getProductIdFromOli
    * Description: if this is a quote bundle product then we get the product from the option field, if it isn't then we can just grab it from
    *    the regular product field OR the proposalLineItem product field (if it exists)
    * Parameters: Order Line Item to check for ProductId
    *
    */
    private ID getProductIdFromOLI(Order_Line_Item__c pOrderLineItem){
        Id productId;
        if(pOrderLineItem.product__c != null && pOrderLineItem.Product__r.ProductCode != null &&
           pOrderLineItem.Product__r.ProductCode.equalsIgnoreCase('QUOTE BUNDLE') && pOrderLineItem.LineType__c == 'Option'){
            productId = pOrderLineItem.OptionId__c;
        } else if(pOrderLineItem.product__c != null){
            productId = pOrderLineItem.Product__c;
        } else if(pOrderLineItem.ProposalLineItem__r != null && pOrderLineItem.ProposalLineItem__r.Apttus_Proposal__Product__c != null){
            productId = pOrderLineItem.ProposalLineItem__r.Apttus_Proposal__Product__c;
        }

        return productId;
    }

/*
** @author : Appirio, Inc.
** @date : 01/06/2016
** @story/Issue : I-197689
** @description : Sales Credit Calculation
** @paramaters : List of Order Line Items
** @returns : nothing
*/
    public void populateOrderLineItemsSalesCredit(List<Order_Line_Item__c> pOrderLineItems){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populateOrderLineItemsSalesCredit');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        //we don't want to do this calculation for Bundle headers
        List<Order_Line_Item__c> listToCheck = new List<Order_Line_Item__c>();
        // Shyam - Appirio - 11/18
        Map<Id, Product2> mapProduct = new Map<Id, Product2>();

        for(Order_Line_Item__c oli : pOrderLineItems){
            system.debug('OLI? ' + oli);
            system.debug('OLI Prod Code: ' + oli.prod_code__c + 'OLI LineType: ' + oli.LineType__c);
            if(oli.prod_code__c == null || oli.LineType__c == null){
                listToCheck.add(oli);
                // Shyam - Appirio - 11/18 - Start
                if(oli.Product__c != null){
                    mapProduct.put(oli.Product__c, null);
                }
                // Shyam - Appirio - 11/18 - End
            } else if(!oli.prod_code__c.equalsIgnoreCase('QUOTE BUNDLE') ||
                (oli.prod_code__c.equalsIgnoreCase('QUOTE BUNDLE') && !oli.LineType__c.equalsIgnoreCase('Product/Service')) ){
                listToCheck.add(oli);
                // Shyam - Appirio - 11/18 - Start
                if(oli.Product__c != null){
                    mapProduct.put(oli.Product__c, null);
                }
                // Shyam - Appirio - 11/18 - End
            }
        }

        // Shyam - Appirio - 11/18 - Start
        if(mapProduct.keySet().size() > 0){
            mapProduct = new Map<Id, Product2>([Select Id, APTPS_Rev_Share_Type__c, APTPS_Rev_Share__c  from Product2 where Id IN :mapProduct.keySet()]);
        }
        // Shyam - Appirio - 11/18 - End

        //system.assert(false ,listToCheck );
        //List<Order_Line_Item__c> orderLineItemsToQuery = checkIfOrderStatusVerified(listToCheck);

        //For(Order_Line_Item__c oLI : orderLineItemsToQuery ){
        for(Order_Line_Item__c oLI : listToCheck ){
            //Sylvester Agyen (Appiro) 6/21/16 - I-200295 - Prevent code from running when performing adjustments
            if(oLI.overwritten_by_Adjustment__c == true){
                //do nothing
            }
            else{
                Decimal quantity = oLI.Quantity2__c == null ? 0 : oLI.Quantity2__c;
                Double netTotalAmount = oLI.NetTotalAmount__c == null ? 0 : oLI.NetTotalAmount__c;

                //Order_Line_Item__c updatedOLI = new Order_Line_Item__c(id=oLI.Id);

                // Shyam - Appirio - 11/18 - Start
                if(oLI.Product__c != null && mapProduct.get(oLI.Product__c).APTPS_Rev_Share_Type__c == 'Gross' && oLI.NetTotalAmount__c != null
                                                && oLI.GrossTotalAmount__c != null && mapProduct.get(oLI.Product__c).APTPS_Rev_Share__c !=  null) {
                    system.debug('im i causing trouble 1');
                    oLI.Sales_Credit__c = oLI.NetTotalAmount__c - (oLI.GrossTotalAmount__c * mapProduct.get(oLI.Product__c).APTPS_Rev_Share__c/100);
                }
                else If(oLI.Product__c != null && mapProduct.get(oLI.Product__c).APTPS_Rev_Share_Type__c == 'Net' && oLI.NetTotalAmount__c != null
                                                        && oLI.NetTotalAmount__c != null && mapProduct.get(oLI.Product__c).APTPS_Rev_Share__c != null) {
                    system.debug('im i causing trouble 2');
                    oLI.Sales_Credit__c = oLI.NetTotalAmount__c - (oLI.NetTotalAmount__c * mapProduct.get(oLI.Product__c).APTPS_Rev_Share__c/100);
                }
                // Shyam - Appirio - 11/18 - End

                /*Code added for I-226558, by Deepanshu Soni Appirio, starts*/
                else if(oLI.RecordTypeId == Utility.GetRecordTypeIdBySObjectNameAndType('Order_Line_Item__c', 'Credit Order Line Item'))
                    {
                        /*
                        if( oLI.Sales_Credit__c != null)
                        {
                            oLI.Sales_Credit__c = oLI.Sales_Credit__c * -1 ;
                        }
                        */
                        system.debug('im i causing trouble 2.1');
                        if(oLI.NetTotalAmount__c != null){
                            oLI.Sales_Credit__c =  oLI.NetTotalAmount__c * -1;
                        }
                    }
                /*Code added for I-226558, by Deepanshu Soni Appirio, ends*/
                else{
                    system.debug('im i causing trouble 3');
                    oLI.Sales_Credit__c =  oLI.NetTotalAmount__c  ;
                }
            }

        }


    }


/*
// Method to populate Order line item manager fields
public void populateOrderLineItemManagerFields(Order_Line_Item__c[] pNewOrderLineItem, map<Id, Order_Line_Item__c> pOldOrderLineItemMap){
    List<Order_Line_Item__c> lineITemtoProcess = new List<Order_Line_Item__c>();
    List<Order_Line_Item_Manager__c> managerListToUpdate = new List<Order_Line_Item_Manager__c>();
    if(pOldOrderLineItemMap == null) {
        for(Order_Line_Item__c line : pNewOrderLineItem){
            if(line.Owner_on_Start_Date__c != null){
                lineITemtoProcess.add(line);
            }
        }
    }
    else {
        for(Order_Line_Item__c line : pNewOrderLineItem){
            if(line.Owner_on_Start_Date__c != null && line.Owner_on_Start_Date__c != pOldOrderLineItemMap.get(line.Id).Owner_on_Start_Date__c){
                lineITemtoProcess.add(line);
            }
        }
    }

    List<Order_Line_Item__c> lineITemList = [Select Id,Region_based_on_OSD__c,Job_Type_based_on_OSD__c,Organization_based_on_OSD__c,Region_Group_based_on_OSD__c,
    Owner_on_Start_Date__c,Owner_on_Start_Date__r.Id,
    (Select Region_based_on_OSD__c,Job_Type_based_on_OSD__c,Organization_based_on_OSD__c,Region_Group_based_on_OSD__c,
    Sales_Rep_ID__c from Order_Line_Item_Managers__r) from Order_Line_Item__c Where Id IN : lineITemtoProcess];

    for(Order_Line_Item__c oLI : lineITemList) {
        for(Order_Line_Item_Manager__c olm : oLI.Order_Line_Item_Managers__r) {
            olm.Region_based_on_OSD__c = oLI.Region_based_on_OSD__c;
            olm.Job_Type_based_on_OSD__c = oLI.Job_Type_based_on_OSD__c;
            olm.Organization_based_on_OSD__c = oLI.Organization_based_on_OSD__c;
            olm.Region_Group_based_on_OSD__c = oLI.Region_Group_based_on_OSD__c;
            if(oLI.Owner_on_Start_Date__c != null) {
                olm.Sales_Rep_ID__c = oLI.Owner_on_Start_Date__r.Id;
            }
            managerListToUpdate.add(olm);
        }
    }
    if(!managerListToUpdate.isEmpty()){
        update managerListToUpdate;
    }
}
*/

/*
** @author : Appirio, Inc.
** @date : 04/08/2016
** @description : populateOrderLineItemManagerFields
** @paramaters : List of Order Line Item Managers
** @returns : List<Order_Line_Item_Manager__c>
*/
public List<Order_Line_Item_Manager__c> populateOrderLineItemManagerFields(List<Order_Line_Item_Manager__c> lstOLIManagers){

    Map<Id, User> mapUser = new Map<Id, User>();

    for(Order_Line_Item_Manager__c oliM : lstOLIManagers){
        if(oliM.Sales_Rep_ID__c != null){
            mapUser.put(oliM.Sales_Rep_ID__c, null);
        }
    }

    mapUser = new Map<Id, User>([Select Id, UserPositionRegion__c, Region_Group__c, Position_Organization__c, Job_Type__c from User Where Id IN : mapUser.keySet()]);

    for(Order_Line_Item_Manager__c oliM : lstOLIManagers){
        if(oliM.Sales_Rep_ID__c != null && mapUser.containsKey(oliM.Sales_Rep_ID__c)){
            oliM.Region_based_on_OSD__c = mapUser.get(oliM.Sales_Rep_ID__c).UserPositionRegion__c;
            oliM.Job_Type_based_on_OSD__c = mapUser.get(oliM.Sales_Rep_ID__c).Job_Type__c;
            oliM.Organization_based_on_OSD__c = mapUser.get(oliM.Sales_Rep_ID__c).Position_Organization__c;
            oliM.Region_Group_based_on_OSD__c = mapUser.get(oliM.Sales_Rep_ID__c).Region_Group__c;
        }
    }
    return lstOLIManagers;
}

/*
** @author : Appirio, Inc.
** @date : 01/06/2016
** @story/Issue : I-197689
** @description : determines if an order line item needs to have sales credit calculated (based upon order status)
** @paramaters : List of Order Line Items
** @returns : Set of order Line Item Ids
*/
/*
// PChilton 1/23/17 - commenting out checkIfOrderStatusVerified as the only call to this, populateOrderLineItemsSalesCredit
//                    (in this same Helper Class), is commented out.
//                    Done to help improve test class code coverage per S-461979 & T-566564
    public List<Order_Line_Item__c> checkIfOrderStatusVerified(List<Order_Line_Item__c> pOrderLineItems){
        List<Order_Line_Item__c> returnIdSet = new List<Order_Line_Item__c>();

        //lets create a map of orders to status, it will help our check later run faster
        Map<Id,String> orderIdToStatusMap = new Map<Id,String>();
        for(Order__c ord : queryOrderList()){
            orderIdToStatusMap.put(ord.Id,ord.OrderStatus__c);
        }

        //now lets check our line items agains the status
        for(Order_Line_Item__c oli : pOrderLineItems){
            String status = orderIdToStatusMap.get(oli.Order__c);

            if(status == 'Resubmitted' ||
                status == 'Negated' ||
                status == 'Verified' ||
                status == 'Paid in Full' ||
                status == 'Invoiced' ||
                status == 'Closed'){
                returnIdSet.add(oli);
            }
        }
        return returnIdSet;
    }
// PChilton 1/23/17 - end of commented out section
*/
    /*
** @author : Adarsh
** @date : 01/25/2016
** @story/Issue : I-192930/I-219918
** @description : Populating APTSTaxAmount with StateTaxAmount/VATNationalTaxAmount for ecomm orders
** @paramaters : List of Order Line Items
** @returns :
*/
    public void PopulateAptsTaxAmt (list<Order_Line_Item__c> pNewOrderLineItem){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','PopulateAptsTaxAmt');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        try{
               for(Order_Line_Item__c oli: pNewOrderLineItem){
                    if(oli.StateTaxAmount__c != null)
                    {
                        oli.APTS_Tax_Amount__c = oli.StateTaxAmount__c;
                    }
                    else if(oli.VATNationalTaxAmount__c != null)
                    {
                        oli.APTS_Tax_Amount__c = oli.VATNationalTaxAmount__c;
                    }
                   system.debug('StartDate' + oli.StartDate__c);
                   if(oli.StartDate__c !=null)//I-219918 Populating EPSD for ecomm
                    {
                        oli.Earliest_Product_Start_Date__c = oli.StartDate__c;
                    }

                }
        }
        catch(Exception e){
            system.debug('errored');
            ExceptionLog.add('Exception', 'OrderLineItemTriggerHelper', 'PopulateAptsTaxAmt', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to Populate AptsTaxAmt.' ,e);
        }
    }
    /*
    ** @author : GG (Appirio)
    ** @date : 04/11/2016
    ** @description : if Start date is less than today on insertion of orderLineItem , then set start date to today
                    originally created for I-210710
    ** @paramaters : List of Orders
    */
    public void setOrderLineItemStartDateOnInsert(List<Order_Line_Item__c> pNewOrderLineItem){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','setOrderLineItemStartDateOnInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        set<id> setProposalIds = new set<id>();
        Date Startdate;
        //Date Enddate;
        Map<id ,Apttus_Proposal__Proposal__c> mapProposals;
        for(Order_Line_Item__c oLI : pNewOrderLineItem){
            if(oLI.Proposal__c != null)
                setProposalIds.add(oLI.Proposal__c);
        }
        if(setProposalIds.size()>0){
            mapProposals = new Map<id ,Apttus_Proposal__Proposal__c>([ SELECT Id, MidContract_Proposal__c,
                                                                     Upgrade_Proposal__c
                                                                     FROM Apttus_Proposal__Proposal__c
                                                                     WHERE Id IN : setProposalIds]);
        }

        //also create a Map with all the Orders - we want to skip this logic for rebill orders
        Map<Id,Order__c> orderMap = new Map<Id,Order__c>();
        for(Order__c ord : queryOrderList()){
            orderMap.put(ord.Id,ord);
            Startdate = ord.OrderDate__c;
        }
        Map<id,Order_Line_Item__c> pNewOrderLineItemCR = new Map<id,Order_Line_Item__c> ([select Order__r.CreditScenario__c
                                                                                        from Order_Line_Item__c
                                                                                        where id =: pNewOrderLineItem] );
        for(Order_Line_Item__c oLI : pNewOrderLineItem){
            //if the order is a rebill order - we skip this logic
            if(orderMap.get(oli.Order__c).Is_rebill__c || orderMap.get(oli.Order__c).Is_Credit__c){
                continue;
            }
            //if the proposal is a midcontract proposal - skip this logic - [can't remember issue number]
            if(oLI.Proposal__c != null && mapProposals.get(oLI.Proposal__c).MidContract_Proposal__c == true){
                continue;
            }

            //if the proposal is an upgrade then skip this logic - I-216464
            if(oLI.Proposal__c != null && mapProposals.get(oLI.Proposal__c).Upgrade_Proposal__c == true){
                continue;
            }


            system.debug('>>>>>>>>>>>>Set Dates Now');
            system.debug('EcommType'+orderMap.get(oLI.Order__c).RecordType.Name);
            //if((oLI.startDate__c < date.today() && orderMap.get(oLI.Order__c).RecordType.Name != 'Rebill') || orderMap.get(oLI.Order__c).RecordType.Name !='Ecomm'){
            if(orderMap.get(oLI.Order__c).RecordType.Name !='Ecomm'){
                if(oLI.startDate__c < date.today() && orderMap.get(oLI.Order__c).RecordType.Name != 'Rebill'){
                    system.debug('InsideSetDate');
                    oLI.EndDate__C= oLI.EndDate__C.addDays(oLI.startDate__c.daysBetween(date.today()));
                    oLI.startDate__c = date.today();
                }
            }
            //system.debug('EcommType'+orderMap.get(oLI.Order__c).RecordType.Name);
            else if(orderMap.get(oLI.Order__c).RecordType.Name =='Ecomm'){//I-220427
               system.debug('InsideMAPPdate');
               oLI.startDate__c = Startdate;
               oLI.EndDate__C= oLI.EndDate__C.addDays(oLI.startDate__c.daysBetween(Startdate));

            }

       }
    }
    /*
    ** @author : Sylvester Agyen (Appirio)
    ** @date : 03/16/2016
    ** @description : Set Rebill Order line item start and end dates to orginal order's line item start and end dates
    ** @paramaters : List of Orders
*/
    public void setRebillOrderDates(List<Order_Line_Item__c> pNewOrderLineItem){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','setRebillOrderDates');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        List<Order_Line_Item__c> orginalOrderLineItems = new List<Order_Line_Item__c>();
        Set<Id> parentRBorders = new Set<Id>();
        //Get id's of rebill orders if line item's Order_Record_Type__c is set to RebillOrder
        for(Order_Line_Item__c li : pNewOrderLineItem){
            if(li.Order_Record_Type__c == 'RebillOrder'){
                parentRBorders.add(li.Order__c);
            }
        }
        //if rebill orders were found above, get those rebill order's original parent order ids
        Map<Id, Id>mapRebillOrderToParentOrder = new Map<Id, Id>();
        Set<Id> parentOrderIds = new Set<Id>();

        if(parentRBorders.size() >0){
            List<Order__c>rebillOrders = [select id, ParentOrder__c from Order__c where id IN:parentRBorders];
            for(Order__c ro : rebillOrders){
                //parentOrderIds.add(ro.ParentOrder__c); //rebill orders parent order ids
                mapRebillOrderToParentOrder.put(ro.id, ro.ParentOrder__c); //maps rebill order id to it's parent order id
            }
        }
        //use rebill orders orrginal parent ids to get their line items
        if(mapRebillOrderToParentOrder.values().size() > 0){
            orginalOrderLineItems= [select id, Product__c, Order__c,startDate__c, endDate__c from Order_Line_Item__c where Order__c IN:mapRebillOrderToParentOrder.values()];
            //if line items were found, match and set dates
            if(orginalOrderLineItems.size() > 0){
              for(Order_Line_Item__c rli : pNewOrderLineItem){
                for(Order_Line_Item__c oli : orginalOrderLineItems){
                    if((rli.Product__c == oli.Product__c) && (mapRebillOrderToParentOrder.get(rli.Order__c) == oli.Order__c)){    // Set start and end dates if line item products and original orders match
                        //Prashant Gupta, Appirio, S-453882 06-04-17
                        rli.startDate__c = oli.startDate__c;
                        rli.endDate__c   = oli.endDate__c;
                        //End
                    }
                }
              }
            }
        }
    }


/*
** @author : Appirio (Jonathan F)
** @date : 03/31/16
** @description : Make changes to incoming Order Line Item records for Ecomm orders
** @returns : nothing
*/
    public void fixEcomm(list<Order_Line_Item__c> pNewOrderLineItem){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','fixEcomm');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        String fixed = '';

        try{
            set<Id> setIds = new set<Id>();
            for(Order_Line_Item__c oli : pNewOrderLineItem){
              setIds.add(oli.Order__c);
            }

            //Map of direct fields: {'sourceField' => 'destField'} - if destField != sourceField, copy sourceField to destField
            map<String, String> directFields = new map<String, String>{'CurrencyIsoCode' => 'CurrencyIsoCode',
                                                                       'PriceListId__c'  => 'PriceListId__c'   //I-211465
                                                                      };

            String relatedObject = 'order__r';
            //Map of related fields: {'sourceField' => 'destField'} - if destField != relatedObject.sourceField, copy relatedObject.sourceField to destField
            map<String, String> relatedFields = new map<String, String>();

            map<Id, Order__c> mapSrc = new map<Id, Order__c>();
            String queryStr = 'SELECT Id, ';
            for(String field : directFields.keySet()){
                queryStr += field + ',';
            }
            for(String field : relatedFields.keySet()){
                queryStr += relatedObject + '.' + field + ',';
            }
            queryStr = queryStr.left(queryStr.length() - 1);
            queryStr += ' FROM Order__c WHERE ID IN (';
            for(String id : setIds){
                queryStr += '\'' + id + '\',';
            }
            queryStr = queryStr.left(queryStr.length() - 1);
            queryStr += ')';
            system.debug('queryStr = '+ queryStr);

            List<Order__c> ord = Database.query(queryStr);
            for(Order__c o : ord){
                mapSrc.put(o.Id,o);
            }

            for(Order_Line_Item__c dest : pNewOrderLineItem){
                //First, some hard-coded fixes specified by Manisha for I-211465 J Freese Appirio 4/7/16
                dest.PriceMethod__c = 'Per Unit';
                dest.PriceType__c = 'One Time';
                fixed = 'PriceMethod__c PriceType__c';
                if(dest.LineType__c == null){//I-218373
                       dest.LineType__c = 'Ecomm';
                   }

                if (mapSrc != null && mapSrc.containskey(dest.Order__c)){
                    //process the direct references
                    for(String sourceField : directFields.keySet()){
                        String destField = directFields.get(sourceField);
                        system.debug('>>> dest.get(destField) = ' + dest.get(destField));
                        system.debug('>>> mapSrc.get(dest.Order__c).get(sourceField) = '  + mapSrc.get(dest.Order__c).get(sourceField));
                        if (dest.get(destField) != mapSrc.get(dest.Order__c).get(sourceField)){
                            dest.put(destField, mapSrc.get(dest.Order__c).get(sourceField));
                            fixed += ' ' + destField;
                        }
                    }

                    //process the related object references
                    for(String sourceField : relatedFields.keySet()){
                        String destField = relatedFields.get(sourceField);
                        SObject relObject = mapSrc.get(dest.Order__c).getSobject(relatedObject);
                        if (relObject != null && dest.get(destField) != mapSrc.get(dest.Order__c).getSobject(relatedObject).get(sourceField)){
                            dest.put(destField, mapSrc.get(dest.Order__c).getSobject(relatedObject).get(sourceField));
                            fixed += ' ' + destField;
                        }
                    }
                }
                if (fixed != ''){
                    system.debug('^^^ Updated MAPP Order_Line_Item__c  (fixed ' + fixed + '): ' + dest);
                }
            }
        }
        catch(Exception e){
            ExceptionLog.add('Exception', 'OrderLineItemTriggerHelper', 'fixEcomm', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to fix key field(s) on Order_Line_Item__c.' ,e);
        }
    }

    //sylvester agyen - 4/25/16 -
    //set owner on start date when order line item is inserted.
    //This owner on start date is used to set managers list on line item

     /* 05.19.2016 Commented out this method as it is not used anywhere right now.
       There is also a method call in trigger handler but it is commented
       Please Uncomment if it need to be used  */

    /* public  void populateOwnerOnStartDateonInsert(List<Order_Line_Item__c> pNewOrderLineItems){
        Set<Id>oliIDs = new Set<Id>();
        List<Order_Line_Item__c>result = new List<Order_Line_Item__c>();
        for(Order_Line_Item__c oli : pNewOrderLineItems){
             oliIDs.add(oli.id);
        }
        if(oliIDs != null){
          result = [select id, Order__c, Order__r.Opportunity__r.OwnerId From Order_Line_Item__c where id IN:oliIDs];
        }
        if(result !=null){
            for(Order_Line_Item__c newOli : pNewOrderLineItems){
                for(Order_Line_Item__c oli : result){
                    if(newOli.Order__c == oli.Order__c){
                        newOli.Owner_on_Start_Date__c = oli.Order__r.Opportunity__r.OwnerId;
                    }
                }
            }
        }
    } */

/*
** @author : Appirio (Jeff L)
** @date : 07/25/16
** @description : Populates the finance order type and finance sequence on the Order I-184385
** @returns : nothing
*/
    public void setFinanceOrderTypeAndSequence(list<Order_Line_Item__c> pNewOrderLineItem){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','setFinanceOrderTypeAndSequence');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        List<Order__c> ordersToUpdate = new List<Order__c>();
        Map<Id,Order__c> orderMap = new Map<Id,Order__c>(queryOrderList());
        Map<Id,List<Order_Line_Item__c>> orderToOliMap = new Map<Id,List<Order_Line_Item__c>>();
        List<Order_Line_Item__c> oliToProcess = new List<Order_Line_Item__c>();
        //Get all the related orders and their information
        //iterate over the order line items to  see if their orders
        // financial Order Type or Finance Order Sequence needs
        //to be updated

        //put together a map of oli to Orders, needed for checking if all OLI's are
        //0 on an order before marking it as Not Applicable
        for(Order_Line_Item__c oli : pNewOrderLineItem){
            Order__c orderToTest = orderMap.get(oli.Order__c);
            if(orderToTest.OrderStatus__c == 'Sent To Verification' ||
                orderToTest.OrderStatus__c == 'Paid in Full' ||
                orderToTest.OrderStatus__c == 'Verified' ||
                orderToTest.OrderStatus__c == 'Invoiced'){
                if(orderToOliMap.get(oli.Order__c) == null){
                    orderToOliMap.put(oli.Order__c, new List<Order_Line_Item__c>());
                }
                orderToOliMap.get(oli.Order__c).add(oli);
                oliToProcess.add(oli);
            }
        }


        for(Order_Line_Item__c oli : oliToProcess){
            //use our helper method to calculate
            Order__c calcedOrder = calcFinanceOrderTypeAndSequence(oli, orderMap.get(oli.Order__c), orderToOliMap.get(oli.Order__c));
            if(calcedOrder != null){
                ordersToUpdate.add(calcedOrder);
                system.debug('^^^ Order to update: ID=' + calcedOrder.Id);
            }
        }

        if(ordersToUpdate.size() > 0){
            OrderTriggerHandler.ExecuteTriggers = false;
            OrderTriggerHandler.IncreaseRunCount = false; //JFreese Appirio S-470802 2/23/2017
            update ordersToUpdate;
            OrderTriggerHandler.ExecuteTriggers = true;
            OrderTriggerHandler.IncreaseRunCount = true; //JFreese Appirio S-470802 2/23/2017
        }else{
            system.debug('^^^ No orders to update');
        }

    }

    /*
    ** @author : Appirio (Jeff L)
    ** @date : 07/25/16
    ** @description : populates the finance order type on the Order I-184385
    ** @returns : nothing
    */
    private Order__c calcFinanceOrderTypeAndSequence(Order_Line_Item__c pOrderLineItem, Order__c pOrder, List<Order_Line_Item__c> pOtherOLI){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','calcFinanceOrderTypeAndSequence');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        system.debug('>>> Winback Date 1 ' + pOrder.Account__r.WinbackDate__c);

        Order__c returnOrder = null;
        Boolean recordUpdated = false;
        Boolean orderTypeMatched = false;

        //We have three values: "New", "Existing", "Winback", "Not Applicable"
        //Different logic for each one

        //Easiset is "Not Applicable" - If the Order Line Item has no net total
        //then check to see if the order has a net total, if it's 0 then the order
        //is "Not Applicable"
        //system.debug('Order Line Item Unit Price ' + pOrderLineItem.NetUnitPrice__c);
        //system.debug('Order Net total amount ' + pOrder.NetTotalAmount__c);
        system.debug('>>> Order Line Item Unit Price ' + Integer.Valueof(pOrderLineItem.NetUnitPrice__c));
        system.debug('>>> Order Net total amount ' + Integer.Valueof(pOrder.NetTotalAmount__c));
        system.debug('>>> Winback Date 2 ' + pOrder.Account__r.WinbackDate__c);
        if(pOrderLineItem.NetUnitPrice__c.round() == 0 && (pOrder.NetTotalAmount__c == null || pOrder.NetTotalAmount__c.round() == 0 )){
            //now lets check the order Order Line Items on the order, just to make
            //sure we indeed have 0 for all the totals
            system.debug('Inside of Matching Not Applicable');
            orderTypeMatched = true;
            Double netTotal = 0;
            for(Order_Line_Item__c oli : pOtherOLI){
                netTotal += oli.NetUnitPrice__c;
            }

            system.debug('net total ' + netTotal);

            //now check if the total is truely 0
            if(netTotal == 0){
                //now lets check the fields, and update if needed
                if(pOrder.Finance_Order_Type_pickList__c != 'Not Applicable Order' ||
                    pOrder.Order_Sequence__c != 'Not Applicable Order'){
                    pOrder.Finance_Order_Type_pickList__c = 'Not Applicable Order';
                    pOrder.Order_Sequence__c = 'Not Applicable Order';
                    recordUpdated = true;
                }
            }
        } else {
            //Next up we need to check for "New", "Existing" or "Winback"
            //First thing is to check to see if we have a winback date
            system.debug('Checking Winback Date ' + pOrder.Account__r.WinbackDate__c);
            if(pOrder.Account__r.WinbackDate__c != null){
                //check to see if it is within a year of winback date
                if(pOrder.Account__r.WinbackDate__c.daysBetween(pOrder.OrderDate__c) < 365){
                    orderTypeMatched = true;
                    system.debug('Winback date Within a year');
                    if(pOrder.Finance_Order_Type_pickList__c != 'Winback'){
                        pOrder.Finance_Order_Type_pickList__c = 'Winback';

                        recordUpdated = true;
                    }

                    //Sequence is based upon if it's the same day as the winback day or not
                    if(pOrder.Account__r.WinbackDate__c == pOrder.OrderDate__c){
                        if(pOrder.Order_Sequence__c != 'First Time'){
                            pOrder.Order_Sequence__c = 'First Time';
                            recordUpdated = true;
                        }
                    } else {
                        if(pOrder.Order_Sequence__c != 'Follow-Up'){
                            pOrder.Order_Sequence__c = 'Follow-Up';
                            recordUpdated = true;
                        }
                    }
                }
            }

            //if no match after testing for Winback, then lets check new
            if(pOrder.Account__r.CustomerDate__c != null && orderTypeMatched == false){
                system.debug('About to check CustomerDate__c ' + pOrder.Account__r.CustomerDate__c);
                //check to see if it's within one year of the customer date
                if(pOrder.Account__r.CustomerDate__c.daysBetween(pOrder.OrderDate__c) < 365){
                    orderTypeMatched = true;
                    system.debug('customer date Within a year');
                    if(pOrder.Finance_Order_Type_pickList__c != 'New'){
                        pOrder.Finance_Order_Type_pickList__c = 'New';
                        recordUpdated = true;
                    }

                    //similar to winback, Sequence is based upon if it's the same day or not
                    if(pOrder.Account__r.CustomerDate__c == pOrder.OrderDate__c){
                        if(pOrder.Order_Sequence__c != 'First Time'){
                            pOrder.Order_Sequence__c = 'First Time';
                            recordUpdated = true;
                        }
                    } else {
                        if(pOrder.Order_Sequence__c != 'Follow-Up'){
                            pOrder.Order_Sequence__c = 'Follow-Up';
                            recordUpdated = true;
                        }
                    }
                }
            }

            //Finally - if we haven't had any matches yet then we default it to "Existing"
            if(orderTypeMatched == false){
                system.debug('Nothing matched - settings to Existing');
                if(pOrder.Finance_Order_Type_pickList__c != 'Existing'){
                    pOrder.Finance_Order_Type_pickList__c = 'Existing';
                    recordUpdated = true;
                }
                if(pOrder.Order_Sequence__c != 'Follow-Up'){
                    pOrder.Order_Sequence__c = 'Follow-Up';
                    recordUpdated = true;
                }
            }
        }

        if(recordUpdated){
            system.debug('Updated Order Finance Order Type ' + pOrder.Finance_Order_Type_pickList__c);
            system.debug('Updated Order Finance Order Sequence ' + pOrder.Order_Sequence__c);
            pOrder.Skip_Sequence_and_Type_Validation__c = true;
            returnOrder = pOrder;
        }

        //this will return null if no update was made
        return returnOrder;
    }

    /*
    ** @author : Appirio (Shyam S)
    ** @date : 09/16/16
    ** @description : Update opportunity as per Offer_Code__c logic [S-439187]
    ** @returns : nothing
    */
    public void updateOpportunity(list<Order_Line_Item__c> pNewOrderLineItem){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateOpportunity');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Set<Id> setOppOmitted = new Set<Id>();
        Set<Id> setOppIncluded = new Set<Id>();
        Map<Id, Opportunity> mapOpp = new Map<Id, Opportunity>();
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for(Order_Line_Item__c oli : pNewOrderLineItem){
            System.debug('----oli ' + oli);
            // No promo code or having promo code not starting with NA1
            System.debug('----oli.OfferCode ' + oli.Offer_Code__c);
            if(oli.Offer_Code__c == null || !oli.Offer_Code__c.toLowerCase().startsWith('na1')){
                setOppOmitted.add(oli.Order__c);
            }
            else if(oli.Offer_Code__c.toLowerCase().startsWith('na1')){
                setOppIncluded.add(oli.Order__c);
            }
        }
        for(Order__c ord : [Select Id, Opportunity__c, Opportunity__r.StageName, Opportunity__r.Account.AccountStatus__c, OpportunityType__c from Order__c where
                            Id IN :setOppOmitted OR Id IN :setOppIncluded]){
            //if(System.today() == ord.Account__r.CustomerDate__c  && String.isNotBlank(ord.Opportunity__c)){
            ////Added by -- Prashant Gupta, Appirio, S-469456 03/07/17
            if(ord.Opportunity__c != null && setOppOmitted.contains(ord.Id) && ord.OpportunityType__c != 'BIA/Usage' && ord.OpportunityType__c != 'Contingent'){
                mapOpp.put(ord.Id, new Opportunity(Id = ord.Opportunity__c, ForecastCategoryName = 'Omitted'));
            }

            if(ord.Opportunity__c != null && (setOppIncluded.contains(ord.Id) || ord.Opportunity__r.Account.AccountStatus__c == 'Customer' || ord.Opportunity__r.Account.AccountStatus__c == 'Lapsed Customer' || ord.Opportunity__r.Account.AccountStatus__c == 'Candidate')
                    && ord.Opportunity__r.StageName == 'Stage 4 - Won' && ord.OpportunityType__c != 'BIA/Usage' && ord.OpportunityType__c != 'Contingent'){
                mapOpp.put(ord.Id, new Opportunity(Id = ord.Opportunity__c, ForecastCategoryName = 'Commit'));
            }
            else if(ord.Opportunity__c != null && (setOppIncluded.contains(ord.Id) || ord.Opportunity__r.Account.AccountStatus__c == 'Customer' || ord.Opportunity__r.Account.AccountStatus__c == 'Lapsed Customer' || ord.Opportunity__r.Account.AccountStatus__c == 'Candidate')
                    && ord.Opportunity__r.StageName == 'Stage 5 - Verified by Finance' && ord.OpportunityType__c != 'BIA/Usage' && ord.OpportunityType__c != 'Contingent'){
                mapOpp.put(ord.Id, new Opportunity(Id = ord.Opportunity__c, ForecastCategoryName = 'Closed'));
            }
            //End
        }

        //system.assert(False,'>>' + mapOpp);
        if(mapOpp.values().size() > 0){
            update mapOpp.values();
        }
    }


     /*
    ** @author : Appirio (Vikas Menon)
    ** @date : 20 Feb 2017
    ** @description : Populate Non Messaging Available Quantity field on OLI (T-578921)
    ** @returns : nothing
    */
    public void populateNonMessagingAvailableQuantity(list<Order_Line_Item__c> pNewOrderLineItem){

            set<Id> productIds = new set<Id> ();
            map<Id, Product2> mapProduct = new map<Id, Product2>();

            Product2 OLIproduct;
            for(Order_Line_Item__c oli : pNewOrderLineItem) {
                if(oli.RecordTypeId == Utility.GetRecordTypeIdBySObjectNameAndType('Order_Line_Item__c', 'Order Line Item')){
                    if(oli.Product__c != null && !productIds.contains(oli.Product__c)){
                        productIds.add(oli.Product__c);
                    }
                    if(oli.OptionId__c != null && !productIds.contains(oli.OptionId__c)){
                        productIds.add(oli.OptionId__c);
                    }
                }
            }

            if(productIds.isEmpty()) return;

            mapProduct = new map<Id, Product2>([Select Id, Messaging__c from Product2 Where ID IN :productIds]);
            // if Product__r.Messaging__c and OptionId__r.Messaging__c are false on OLI then populate NonMessaging_Available_Quantity__c
            // field with Quantity2__c
            for(Order_Line_Item__c oli : pNewOrderLineItem) {
                  boolean isValid = false;
                  if(oli.Product__c != null && oli.OptionId__c == null){
                      if(mapProduct.containsKey(oli.Product__c) && !mapProduct.get(oli.Product__c).Messaging__c){
                          isValid = true;
                      }
                  }
                  else if(oli.Product__c == null && oli.OptionId__c != null){
                      if(mapProduct.containsKey(oli.OptionId__c) && !mapProduct.get(oli.OptionId__c).Messaging__c){
                          isValid = true;
                      }
                  }
                  else if(oli.Product__c != null && oli.OptionId__c != null){
                      if(!mapProduct.get(oli.Product__c).Messaging__c && !mapProduct.get(oli.OptionId__c).Messaging__c){
                          isValid = true;
                      }
                  }

                  if(isValid){
                      oli.NonMessaging_Available_Quantity__c = oli.Quantity2__c;
                  }

            }

    }










}