public with sharing class BulkFullCreditLoadProcessor{
    private static Id CreditOrderRecordType;
    final static String CLASSNAME = '\n\n**** BulkFullCreditLoadProcessor.METHODNAME()';

    protected Map<String, Map<String, Schema.SObjectField>> sObjectAndFields;
    protected Order__c[] ParentOrderList;
    protected map<Id, Order__c> ParentOrderIdToClonedOrder;
    protected map<Id, Order_Line_Item__c> ParentOLIIdToClonedOLI;
    protected Line_Item_Attribute__c[] ParentLIAList;

    public BulkFullCreditLoadProcessor(Order__c[] pOrderToBeProcessed){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','BulkFullCreditLoadProcessor');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        ParentOrderList = pOrderToBeProcessed;
        createCreditRequestWithItems();
    }

    private void createCreditRequestWithItems(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','createCreditRequestWithItems');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        getAllFields();

        Map<String, Schema.SObjectField> oliFields = sObjectAndFields.get('Order_Line_Item__c');
        Map<Id,Id> mapOrderToCR = new Map<Id,Id> ();
        Map<Id,Id> mapCRToProposal = new Map<Id,Id> ();
        map<String, Id> RecordTypes = Utility.GetRecordTypeIdsBySObjectNameSet(new set<String>{'Credit_Request__c'}).get('Credit_Request__c');
        List<Credit_Request__c> CreditRequestTobeInserted = new List<Credit_Request__c>();
        List<CreditRequestLineItem__c> CreditRequestLineItemTobeInserted = new List<CreditRequestLineItem__c>();
        Id CreditRequestRTId;
        Credit_Request__c CreditRequest;
        List<Order__c> orderList = [  SELECT Id, Payment_Term_text__c, Payment_Method_text__c, Payment_Frequency__c,
                                    BillingStartDt__c,OrderDate__c, Account__r.AccountID__c, Account__r.Name,SalesChannel__c,
                                    Account__r.Owner.FirstName, Account__r.Owner.LastName,
                                    CurrencyIsoCode, New_Number_of_Installment__c  , QuoteProposal__r.Number_of_Installment__c,
                                    Earliest_Product_Start_DT__c, LatestProductEndDate__c,
                                                (SELECT Id, NetTotalAmount__c, APTS_Tax_Amount__c, Option_Bundle_Code__c,HasOptions__c,
                                                 OptionId__c,BasePrice__c,Quantity2__c, Remaining_Credit_Amount__c,
                                                 ProductNameText__c, Quantity__c, BaseUnitPrice__c,
                                                 GrossRemainingCreditAmount__c, NetRemainingCreditAmount__c,
                                                 GrossUnitPrice__c, AvailableInventory__c, AgencyCommission__c,
                                                 GrossTotalAmount__c,Xcode_calc__c, VATNationalTaxCode__c,
                                                 VATNationalTaxRate__c, VATNationalTaxAmount__c, StateProvinceTaxCode__c,
                                                 StateProvinceTaxRate__c, StateProvinceTaxAmount__c, Agency_Discount_Percent__c,
                                                 NetCreditAmount__c, Name, CurrencyIsoCode, IsMessaging__c
                                                 FROM Order_Line_Items__r)  FROM Order__c WHERE Id IN :ParentOrderList ];

        // Insert  credit request for order
        for(Order__c orderRec : orderList){
            CreditRequest = new Credit_Request__c();
            CreditRequest.Order__c = orderRec.Id;
            CreditRequest.BillingAccount__c = orderRec.Account__r.Name;
            CreditRequest.BillingCustomerNumber__c = orderRec.Account__r.AccountID__c;
            CreditRequest.SalesRep__c = orderRec.Account__r.Owner.FirstName + ' '+ orderRec.Account__r.Owner.LastName;
            CreditRequest.PrimarySalesRep__c = orderRec.Account__r.OwnerId;
            CreditRequest.SalesChannel__c = orderRec.SalesChannel__c;
            CreditRequest.OrderDate__c = orderRec.OrderDate__c;
            CreditRequest.CurrencyIsoCode = orderRec.CurrencyIsoCode;
            CreditRequest.Billing_Start_Date__c = orderRec.BillingStartDt__c;
            CreditRequest.PaymentTerm__c = orderRec.Payment_Term_text__c;
            CreditRequest.Payment_Frequency__c = orderRec.Payment_Frequency__c;
            CreditRequest.Payment_Method__c = orderRec.Payment_Method_text__c;
            CreditRequest.New_Number_of_Installments__c = orderRec.New_Number_of_Installment__c;
            CreditRequest.CreditScenario__c = 'Credit';
            CreditRequest.Credit_Type__c = 'Full';
            CreditRequest.CreditReason__c = 'Fraud';
            CreditRequest.DetailedCreditReason__c = 'Bulk Credit Creation - Created By '+ UserInfo.getUserName();
            CreditRequest.RecordTypeId = RecordTypes.get('Locked Credit Request');
            CreditRequest.Whocausedthecredit__c = 'System/Technical';
            CreditRequest.ApprovalStatus__c = 'Approved';
            CreditRequestTobeInserted.add(CreditRequest);
        }
        if(!CreditRequestTobeInserted.isEmpty()) {
            insert CreditRequestTobeInserted;
        }

        for(Credit_Request__c cr : [Select Id, Order__c,Order__r.QuoteProposal__c from Credit_Request__c
                                    where Id IN :CreditRequestTobeInserted]) {
            mapOrderToCR.put(cr.Order__c, cr.Id);
            if(cr.Order__r.QuoteProposal__c != null) {
               mapCRToProposal.put(cr.Id, cr.Order__r.QuoteProposal__c);
            }
        }

        // Insert credit request line items
        for(Order__c orderRec : orderList){
            for(Order_Line_Item__c oli : orderRec.Order_Line_Items__r){

                CreditRequestLineItem__c crli = new CreditRequestLineItem__c();

                if(mapOrderToCR.containsKey(orderRec.Id)){
                    crli.Credit_Request__c = mapOrderToCR.get(orderRec.Id);
                }
                crli.Order_Line_Item__c = oli.Id;
                crli.ProductName__c = oli.ProductNameText__c;
                crli.Unit_Price__c =oli.BaseUnitPrice__c;
                if(oli.VATNationalTaxRate__c == null){
                    oli.VATNationalTaxRate__c = 0.0;
                }
                if(oli.VATNationalTaxAmount__c == null){
                    oli.VATNationalTaxAmount__c = 0.0;
                }
                crli.AgencyCommission__c = oli.Agency_Discount_Percent__c;
                crli.Unit_Price__c = oli.GrossUnitPrice__c;
                //Sberron - I-273961 - 05/13/17
                //Was setting AvailableCreditAmount based on NetRemainingCreditAmount__c, not GrossRemainingCreditAmount__c
                crli.AvailableCreditAmount__c = oli.GrossRemainingCreditAmount__c == null ? 0 : oli.GrossRemainingCreditAmount__c;
                crli.VATNationalTaxCode__c = oli.VATNationalTaxCode__c;
                crli.StateProvinceTaxCode__c = oli.StateProvinceTaxCode__c;
                crli.VATNationalTaxRate__c = oli.VATNationalTaxRate__c;
                crli.StateProvinceTaxRate__c = oli.StateProvinceTaxRate__c;
                crli.OrderLineItemQuantity__c = oli.Quantity2__c;
                crli.NetTotalAmount__c = oli.NetTotalAmount__c;
                crli.NetCreditAmount__c = 0;
                crli.CreditAmount__c = 0;
                crli.NetRemainingCreditAmount__c = oli.NetRemainingCreditAmount__c;
                crli.TaxAmount__c = 0;
                crli.Xcode__c = oli.Xcode_calc__c;
                crli.CurrencyIsoCode = oli.CurrencyIsoCode;
                crli.CreditAmount__c = crli.AvailableCreditAmount__c;
                crli.NetCreditAmount__c = Utility.parseDouble(crli.CreditAmount__c) - (divideBy100(crli.AgencyCommission__c) * Utility.parseDouble(crli.CreditAmount__c));
                crli.TaxAmount__c = oli.APTS_Tax_Amount__c==null ? 0 :oli.APTS_Tax_Amount__c;
                if(oli.isMessaging__c){
                    crli.Quantity__c = oli.AvailableInventory__c;
                } else {
                    crli.Quantity__c = oli.Quantity2__c;
                }
                CreditRequestLineItemTobeInserted.add(crli);
            }
        }

        if(!CreditRequestLineItemTobeInserted.isEmpty()) {
            insert CreditRequestLineItemTobeInserted;
        }

        // create credit order
        if(System.isBatch()) {
            try {
            createCreditOrderInBatch(mapOrderToCR,mapCRToProposal);
            }
            catch(Exception e){
                System.assert(false, '=====Batch Failed in ===BulkFullCreditLoadProcessor');
            }
        }
        else {
         createCreditOrder(mapOrderToCR,mapCRToProposal);
        }
    }

    @future
    public static void createCreditOrder(Map<Id,Id> mapOrderToCR,Map<Id,Id> mapCRToProposal){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','createCreditOrder');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        List<Order__c> ordersTobeUpdated = new  List<Order__c>();
        CreateCreditOrderFromCreditRequest request;
        for(Id orderId : mapOrderToCR.keySet()){
            request = new CreateCreditOrderFromCreditRequest(orderId, mapOrderToCR.get(orderId));
            request.createCreditOrder();
        }
        for(Order__c o : [Select Id,CreditRequest__c,QuoteProposal__c from Order__c Where CreditRequest__c IN :mapCRToProposal.keySet()]){
            if(mapCRToProposal.containsKey(o.CreditRequest__c)){
                o.QuoteProposal__c = mapCRToProposal.get(o.CreditRequest__c);
                ordersTobeUpdated.add(o);
            }
        }
        if(!ordersTobeUpdated.isEmpty()){
            update ordersTobeUpdated;
        }
    }


    public static void createCreditOrderInBatch(Map<Id,Id> mapOrderToCR,Map<Id,Id> mapCRToProposal){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','createCreditOrderInBatch');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        List<Order__c> ordersTobeUpdated = new  List<Order__c>();
        CreateCreditOrderFromCreditRequest request;
        for(Id orderId : mapOrderToCR.keySet()){
            request = new CreateCreditOrderFromCreditRequest(orderId, mapOrderToCR.get(orderId));
            request.createCreditOrder();
        }
        for(Order__c o : [Select Id,CreditRequest__c,QuoteProposal__c,OrderStatus__c,CreditType__c,Organization__c from Order__c Where CreditRequest__c IN :mapOrderToCR.values()]){
            if(mapCRToProposal.containsKey(o.CreditRequest__c)){
                o.QuoteProposal__c = mapCRToProposal.get(o.CreditRequest__c);
            }
             // Set status = 'Sent To Verification' and credit type  = Full 
            // on bulk credit order creation, by Vikas Menon on 15 Feb, 2017 (I-259521,I-259523)
            o.CreditType__c = 'Full';
            /* S-471534 >> if organization is NA then orderstatus should be verified 
               Added by Vikas Menon on 03-May-2017
            */
            if(o.Organization__c == 'North America') {
                o.OrderStatus__c = 'Verified'; 
            }
            else {
                o.OrderStatus__c = 'Sent To Verification';
            }
            
            ordersTobeUpdated.add(o);
        }
        if(!ordersTobeUpdated.isEmpty()){
            update ordersTobeUpdated;
        }
    }

    private void startCloning(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','startCloning');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        getAllFields();
        try{
            ParentOrderIdToClonedOrder = new map<Id, Order__c>();
            for(Order__c po : ParentOrderList){
                /*Order__c co = po.clone(false, true);
                co.ParentOrder__c = po.Id;
                co.BulkCreditLoad__c = false;
                co.RecordTypeId = CreditOrderRecordType;
                ParentOrderIdToClonedOrder.put(po.ParentOrder__c, co);*/
                ParentOrderIdToClonedOrder.put(po.ParentOrder__c, po);
            }
            insert ParentOrderIdToClonedOrder.values();
        }catch(Exception e){
            system.debug('Order Querying and Cloning failed: ' + e);
        }

        try{
            Map<String, Schema.SObjectField> oliFields = sObjectAndFields.get('Order_Line_Item__c');

            set<Id> parentOrderIdSet = ParentOrderIdToClonedOrder.keySet();

            String parentOLIQuery = 'SELECT ';
            for(String sourceAPI : oliFields.keySet()){
                parentOLIQuery += sourceAPI+',';
            }
            parentOLIQuery += getLineItemAttributeQuery();

            parentOLIQuery += ' FROM Order_Line_Item__c WHERE Order__c IN  :parentOrderIdSet';

            ParentOLIIdToClonedOLI = new map<Id, Order_Line_Item__c>();

            ParentLIAList = new Line_Item_Attribute__c[]{};
            Order_Line_Item__c[] poliList = Database.query(parentOLIQuery);
            system.debug('\n\nExtracted Line: ' + poliList + '\n\n');
            for(Order_Line_Item__c ploi : poliList){
                Order_Line_Item__c cloi = ploi.clone(false, true);
                cloi.Order__c = ParentOrderIdToClonedOrder.get(ploi.Order__c).Id;
                ParentOLIIdToClonedOLI.put(ploi.Id,cloi);
                if(cloi.Line_Item_Attributes__r.size() > 0){
                    ParentLIAList.addAll(cloi.Line_Item_Attributes__r);
                }
            }

            insert ParentOLIIdToClonedOLI.values();
        }catch(Exception e){
            system.debug('Order Line Item Querying and Cloning failed: ' + e);
            system.debug('Trace: ' + e.getStackTraceString());
        }

        try{
            Line_Item_Attribute__c[] liaToCloneList = new Line_Item_Attribute__c[]{};
            for(Line_Item_Attribute__c plia : ParentLIAList){
                if(ParentOLIIdToClonedOLI.containsKey(plia.Order_Line_Item__c)){
                    Line_Item_Attribute__c clia = plia.clone(false, true);
                    clia.Order_Line_Item__c = ParentOLIIdToClonedOLI.get(plia.Order_Line_Item__c).Id;
                    liaToCloneList.add(clia);
                }
            }
            insert liaToCloneList;
        }catch(Exception e){
            system.debug('Order Line Attribute Querying and Cloning failed: ' + e);
        }
    }
/**
* @description Assemble line item attribute query
* @author Cloudsherpas
* @date 4-30-2014
* @param none
* @returns none
*/
    private String getLineItemAttributeQuery(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','getLineItemAttributeQuery');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Map<String, Schema.SObjectField> orderFields = sObjectAndFields.get('Line_Item_Attribute__c');
        String orderLineItemQuery = '(SELECT ';
        for(String sourceAPI : orderFields.keySet()){
            orderLineItemQuery += sourceAPI+',';
        }

        orderLineItemQuery = orderLineItemQuery.removeEnd(',');
        orderLineItemQuery += ' FROM Line_Item_Attributes__r)';
        return orderLineItemQuery;
    }

/**
* @description Gets all field detail of Order, Order Line Item, and Line Item Attribute
* @author Cloudsherpas
* @date 4-30-2014
* @param none
* @returns none
*/
    private void getAllFields(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','getAllFields');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Utility util = new Utility();
        sObjectAndFields = util.getAllSObjectFieldsBySObjectName(new Set<String>{
            'Order_Line_Item__c',
            'Line_Item_Attribute__c',
            'Order__c'
        });
    }



    //static members
    public static void startFullCreditLoad(Order__c[] pNewOrderList){
        CreditOrderRecordType = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Credit');
        Order__c[] orderToBeProcessed = new Order__c[]{};
        for(Order__c o : pNewOrderList){
            if(isNeededForFullCredit(o)){
                orderToBeProcessed.add(o);
            }
        }
        if(orderToBeProcessed.size() == 0){
            system.debug('No Order to be processed as BulkFullCreditLoad.');
            return;
        }
        BulkFullCreditLoadProcessor processor = new BulkFullCreditLoadProcessor(orderToBeProcessed);
    }

    public static Boolean isNeededForFullCredit(Order__c pNewOrder){
        Boolean output = false;
        if(pNewOrder.RecordTypeId == CreditOrderRecordType && pNewOrder.CreditType__c == 'Full' && pNewOrder.BulkCreditLoad__c){
            output = true;
        }
        return output;
    }

     public Double divideBy100(Object pValue){
         return pValue != null && pValue != 0 ? Double.valueOf(pValue) / 100 : 0;
    }
}