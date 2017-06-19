public without sharing class APTS_creditHelper {

    public static string CRReason_termination = 'Termination';
    public static string CRScenario_Credit = 'Credit';
    public static string Apstatus_Approved ='Approved';
    public APTS_creditHelper()
    {

    }


    public static  MAP<id,Order__c> getOrderMAP(set<id> OrderIDSet)
    {
        MAP<id,Order__c> OrderMAP = new MAP<id,Order__c>([SELECT Id, OrderDate__c, Account__r.AccountID__c,
                                                          AgencyCommission__c,
                                                          Opportunity__c,
                                                          QuoteProposal__c,
                                                         PrimarySalesRep__c,
                                                          Account__r.Name ,SalesChannel__c,
                                                          Account__r.Owner.FirstName,
                                                          Account__r.Owner.LastName,
                                                          CurrencyIsoCode  FROM Order__c WHERE Id =: OrderIDSet]);
        return OrderMAP;
    }
    public static list<Credit_Request__c> GenerateCR(set<id> OrderIDSet, MAP<id,Order__c> OrderMAP )
    {
        list<Credit_Request__c> CRlist = new list<Credit_Request__c>();
        User u = [SELECT Organisation__c FROM User WHERE Id = :UserInfo.getUserId()];

        map<String, Id> RecordTypes = Utility.GetRecordTypeIdsBySObjectNameSet(new set<String>{'Credit_Request__c'}).get('Credit_Request__c');
        Id CreditRequestRTId;
        if(u.Organisation__c == 'Asia Pacific'){
            CreditRequestRTId = RecordTypes.get('APAC Credit Request');
        }else if(u.Organisation__c == 'Europe'){
            CreditRequestRTId = RecordTypes.get('EU Credit Request');
        }else if(u.Organisation__c == 'North America'){
            CreditRequestRTId = RecordTypes.get('NA Credit Request');
        }
        system.debug(LoggingLevel.INFO, 'OrderIDSet:'+OrderIDSet);


        system.debug(LoggingLevel.INFO, 'OrderIDSet:'+OrderMAP);
        for(  id Oid  : OrderMAP.keySet() )
        {
            Order__c Orders = OrderMAP.get(Oid);
            Credit_Request__c CreditRequest = new Credit_Request__c();

            CreditRequest.Order__c = Orders.id;
            CreditRequest.RecordTypeId = CreditRequestRTId;
            CreditRequest.BillingAccount__c = Orders.Account__r.Name;
            CreditRequest.BillingCustomerNumber__c = Orders.Account__r.AccountID__c;
            CreditRequest.SalesRep__c = Orders.Account__r.Owner.FirstName + ' '+ Orders.Account__r.Owner.LastName;
            CreditRequest.PrimarySalesRep__c =  Orders.PrimarySalesRep__c;
            CreditRequest.SalesChannel__c = Orders.SalesChannel__c;
            CreditRequest.OrderDate__c = Orders.OrderDate__c;
            CreditRequest.CurrencyIsoCode = Orders.CurrencyIsoCode;
            CreditRequest.CreditReason__c = CRReason_termination ;
            CreditRequest.CreditScenario__c = CRScenario_Credit;
            CreditRequest.ApprovalStatus__c = Apstatus_Approved;
            CRlist.add(CreditRequest);
        }

        return CRlist;
        
    }

    public static List<CreditRequestLineItem__c> GenerateLineItems(set<id> OrderIDSet,MAP<id,id> ProposalOrderMap, MAP<id,id> OrderCRMap )
    {
        MAP<id,Apttus_Proposal__Proposal_Line_Item__c> OrderlinePLIMAP = new MAP<id,Apttus_Proposal__Proposal_Line_Item__c>();
        List<CreditRequestLineItem__c> CRlineItemlist = new List<CreditRequestLineItem__c>();
        List<Apttus_Proposal__Proposal_Line_Item__c> ProposalLineItemList = [select id,
                                                                             Apttus_QPConfig__AssetLineItemId__c,
                                                                             Apttus_QPConfig__AssetLineItemId__r.Order_Line_Item__c,
                                                                             Net_Total__c,
                                                                             Apttus_QPConfig__Quantity2__c,
                                                                             Apttus_Proposal__Product__r.Service_Type__c,
                                                                             Apttus_Proposal__Product__r.name,
                                                                             Apttus_Proposal__Proposal__c,
                                                                             Apttus_QPConfig__StartDate__c,
                                                                             Apttus_QPConfig__EndDate__c,
                                                                             Gross_Total__c
                                                                              FROM Apttus_Proposal__Proposal_Line_Item__c
                                                                             where Apttus_Proposal__Proposal__c = :ProposalOrderMap.keySet()
                                                                             AND Apttus_QPConfig__AssetLineItemId__c <>  null];

        for(Apttus_Proposal__Proposal_Line_Item__c OLI: ProposalLineItemList)
        {

            OrderlinePLIMAP.put(OLI.apttus_QPConfig__AssetLineItemId__r.Order_Line_Item__c, OLI);
        }

        system.debug(LoggingLevel.INFO, 'OrderlinePLIMAP:'+OrderlinePLIMAP);
        system.debug(LoggingLevel.INFO, 'ProposalLineItemList:'+ProposalLineItemList);

        for(Order_Line_Item__c oli : [SELECT Id,
                                      NetTotalAmount__c,
                                      Order__c,
                                      GrossRemainingCreditAmount__c,
                                      APTS_Tax_Amount__c,
                                      VATNationalTaxCode__c,
                                      VATNationalTaxRate__c,
                                      VATNationalTaxAmount__c,
                                      StateProvinceTaxCode__c,
                                      StateProvinceTaxRate__c,
                                      StateProvinceTaxAmount__c,
                                      BasePrice__c,
                                      Remaining_Credit_Amount__c,
                                      ProductNameText__c,
                                      Quantity__c,
                                      Quantity2__c,
                                      BaseUnitPrice__c,
                                      GrossUnitPrice__c,
                                      NetRemainingCreditAmount__c,
                                      AgencyCommission__c,
                                      NetCreditAmount__c,
                                      Xcode_calc__c,
                                      LineType__c,
                                      Name,
                                      CurrencyIsoCode
                                      FROM Order_Line_Item__c
                                      WHERE Order__c = : OrderIDSet])
        {
            If(OrderlinePLIMAP.containsKey(oli.id))
            {
                Apttus_Proposal__Proposal_Line_Item__c TempPLI   = OrderlinePLIMAP.get(oli.id);

                if(oli.VATNationalTaxRate__c == null){
                    oli.VATNationalTaxRate__c = 0.0;
                }
                if(oli.VATNationalTaxAmount__c == null){
                    oli.VATNationalTaxAmount__c = 0.0;
                }

                //   netRemainingCreditAmount.put(oli.Id,oli.NetRemainingCreditAmount__c );
                //   grossRemainingCreditAmount.put(oli.Id,oli.GrossRemainingCreditAmount__c);
                CreditRequestLineItem__c crli = new CreditRequestLineItem__c();
                crli.Credit_Request__c =OrderCRMap.get(oli.Order__c);
                crli.CurrencyIsoCode = oli.CurrencyIsoCode;
                crli.Order_Line_Item__c = oli.Id;
                crli.AgencyCommission__c = oli.AgencyCommission__c;
                crli.Unit_Price__c = oli.GrossUnitPrice__c;
                crli.AvailableCreditAmount__c = oli.GrossRemainingCreditAmount__c == null ? 0 : oli.GrossRemainingCreditAmount__c;
                crli.NetRemainingCreditAmount__c = oli.NetRemainingCreditAmount__c;
                crli.ProductName__c = TempPLI.Apttus_Proposal__Product__r.name;
                crli.OrderLineItemQuantity__c = oli.Quantity2__c;
                crli.Xcode__c = oli.Xcode_calc__c;
                crli.TaxAmount__c = oli.APTS_Tax_Amount__c==null ? 0 :oli.APTS_Tax_Amount__c;
                crli.NetTotalAmount__c = oli.NetTotalAmount__c;
                If(TempPLI.Apttus_Proposal__Product__r.Service_Type__c == 'Subscription')
                {
                    crli.CreditType__c = 'Amount';
                    crli.Quantity__c = TempPLI.Apttus_QPConfig__Quantity2__c;
                    crli.CreditAmount__c = math.abs(TempPLI.Net_Total__c);//oli.Remaining_Credit_Amount__c; //I-209306 changes
                    crli.NetCreditAmount__c = math.abs(TempPLI.Net_Total__c);//oli.GrossRemainingCreditAmount__c;//I-209306 changes

                }else
                {
                    crli.CreditType__c = 'Inventory';
                    crli.Quantity__c = TempPLI.Apttus_QPConfig__Quantity2__c;
                    crli.CreditAmount__c = 0;//oli.Remaining_Credit_Amount__c;
                    crli.NetCreditAmount__c = 0;//oli.GrossRemainingCreditAmount__c;
                }

                crli.VATNationalTaxCode__c = oli.VATNationalTaxCode__c;
                crli.StateProvinceTaxCode__c = oli.StateProvinceTaxCode__c;
                crli.VATNationalTaxRate__c = oli.VATNationalTaxRate__c;
                crli.StateProvinceTaxRate__c = oli.StateProvinceTaxRate__c;
                crli.start_date__C = TempPLI.Apttus_QPConfig__StartDate__c;
                crli.end_date__C = TempPLI.Apttus_QPConfig__EndDate__c;
                crli.CreditAmount__c= math.abs(TempPLI.Gross_Total__c);//I-209306 changes
                System.debug('CreditAmount__c ' + crli.CreditAmount__c);
                //I-214763 changes done by Apttus
                if(crli.CreditAmount__c == crli.NetTotalAmount__c)
                crli.CreditCondition__c='Full';
                else
                crli.CreditCondition__c='Partial';
                
                crli.LineType__c = oli.LineType__c;
                
                CRlineItemlist.add(crli);
            }
        }
        return CRlineItemlist;

    }

    public static list<Credit_Request_License_ID__c> GenerateLicense(List<CreditRequestLineItem__c> CRLIList  )
    {
        list<Credit_Request_License_ID__c> CRLIDList = new list<Credit_Request_License_ID__c>();
        MAP<id,id> CRLToOLIMAP = new MAP<id,id>();

        for(CreditRequestLineItem__c OTemp : CRLIList)
        {
            if(OTemp.CreditType__c == 'Inventory')
            {
                CRLToOLIMAP.put(oTemp.id, oTemp.Order_Line_Item__c);
            }
        }
        MAP<id,Order_Line_Item__c> OLIMAP = new MAP<id,Order_Line_Item__c>(
            [SELECT id,
             (select id,AvailableInventory__c FROM License_IDs__r)
             FROM Order_Line_Item__c
             WHERE ID = :CRLToOLIMAP.values()
            ]
        );
        for(CreditRequestLineItem__c OTemp : CRLIList)
        {
            decimal dQuantity =  OTemp.Quantity__c;
            if(OTemp.CreditType__c == 'Inventory' && dQuantity > 0)
            {
                Order_Line_Item__c OLi = OLIMAP.get(CRLToOLIMAP.get(OTemp.id));
                List<LicenseID__c> LicenseList = OLi.License_IDs__r;

                for(LicenseID__c LicTemp : LicenseList)
                {
                    if(dQuantity > 0 )
                    {
                        Credit_Request_License_ID__c tempLcenseID = new Credit_Request_License_ID__c();
                        tempLcenseID.CreditQuantity__c = LicTemp.AvailableInventory__c > dQuantity ? dQuantity : LicTemp.AvailableInventory__c;
                        tempLcenseID.CreditRequestLineItem__c = OTemp.Id;
                        tempLcenseID.LicenseID__c = LicTemp.Id;
                        CRLIDList.add(tempLcenseID);
                        dQuantity = dQuantity - tempLcenseID.CreditQuantity__c ;
                    }

                }


            }
        }

        return CRLIDList;

    }
    public static list<Order__c> GenerateOrder(list<Credit_Request__c>  CRSet,MAP<id,Order__c> OrderMAP)
    {
        list<Order__c> orderList = new list<Order__c>();
        map<String, map<String, Id>> result = Utility.GetRecordTypeIdsBySObjectNameSet(new set<String>{'Order__c'});
        String orderRecordTypeId = result.get('Order__c').get('Credit');
        for(Credit_Request__c crc : CRSet)
        {
            Order__c newOrder = new Order__c();
            //newOrder.CreditReason__c = crc.CreditReason__c; Jeff Commented out to turn into a formula field
            newOrder.Account__c = OrderMAP.get(crc.Order__c).Account__c;
            newOrder.ParentOrder__c = crc.Order__c;
            newOrder.AgencyCommission__c = OrderMAP.get(crc.Order__c).AgencyCommission__c;
            newOrder.Opportunity__c =  OrderMAP.get(crc.Order__c).Opportunity__c;
            newOrder.QuoteProposal__c =  OrderMAP.get(crc.Order__c).QuoteProposal__c;
            newOrder.CreditRequest__c = crc.id;
            newOrder.CreditType__c = crc.Credit_Type__c ;
            newOrder.RecordTypeId = orderRecordTypeId;
            orderList.add(newOrder);
        }
        System.debug('orderList ' + orderList);
        return orderList;
    }


    public static List<Order_Line_Item__c> generateOrderLineItem(list<CreditRequestLineItem__c> CRLIList, MAP<id,id> CRnewOderMap )
    {
        
        map<String, map<String, Id>> result = Utility.GetRecordTypeIdsBySObjectNameSet(new set<String>{ 'Order_Line_Item__c'});
        String orderLIRecordTypeId = result.get('Order_Line_Item__c').get('Credit Order Line Item');
        List<Order_Line_Item__c> OrderLineItemToBeInserted = new List<Order_Line_Item__c>();
        Map<String,Id> lineItemProductNameMap = new Map<String, Id>();
        set<string> ProductNameSet = new set<string>(); 
        Set<String> setOLI = new Set<String>(); //S-452994 :Added By: Viraj Rana (Apttus)
        
        for(CreditRequestLineItem__c crli : CRLIList){
            ProductNameSet.add(crli.ProductName__c);
            setOLI.add(crli.Order_Line_Item__c); //S-452994 :Added By: Viraj Rana (Apttus)
        }

        for(Product2 prod : [SELECT Id , Name FROM Product2 WHERE Name IN: ProductNameSet ]){
            lineItemProductNameMap.put(prod.Name, Prod.Id);
        }
        
        Map<String,Order_Line_Item__c> mapOLI = new Map<String,Order_Line_Item__c>([Select id,Legacy_Integration_Id__c,Legacy_Quote_Item_Id__c from Order_Line_Item__c where Id in: setOLI]);
        
        for(CreditRequestLineItem__c cr : CRLIList)
        {
            Order_Line_Item__c newOrderLineItems = new Order_Line_Item__c();
            newOrderLineitems.CreditRequestLineItem__c = cr.Id;
            newOrderLineitems.Legacy_Karma_PartNum__c =cr.Order_Line_Item__r.Legacy_Karma_PartNum__c ;
            
            //S-452994 : SFDC PRODUCTION - CR's against migrated orders no longer include Karma Reference Fields - see OR-07498304 and OR-07518200 (two of 4 kickouts).
            //Added By: Viraj Rana (Apttus)
            if(mapOLI.Containskey(cr.Order_Line_Item__c)){
                newOrderLineitems.Legacy_Integration_Id__c =mapOLI.get(cr.Order_Line_Item__c).Legacy_Integration_Id__c;
                newOrderLineitems.Legacy_Quote_Item_Id__c =mapOLI.get(cr.Order_Line_Item__c).Legacy_Quote_Item_Id__c;
            }
            
            newOrderLineItems.CreditAmount__c =  cr.CreditAmount__c;
            if(cr.AvailableCreditAmount__c != null && cr.CreditAmount__c != null)
            {
                newOrderLineItems.Remaining_Credit_Amount__c = cr.AvailableCreditAmount__c - cr.CreditAmount__c;
            }
            newOrderLineItems.Xcode__c = cr.Xcode__c;
            newOrderLineItems.Quantity2__c = cr.Quantity__c;
            newOrderLineItems.RecordTypeId = orderLIRecordTypeId;
            newOrderLineItems.GrossCreditAmount__c = cr.CreditAmount__c;
            newOrderLineItems.Order__c = CRnewOderMap.get(cr.Credit_Request__c);
            //neworderLineItems.AgencyCommission__c = cr.AgencyCommission__c;//removed when field is changed to formula
            
            newOrderLineitems.NetCreditAmount__c = cr.NetCreditAmount__c;
            newOrderLineitems.NetTotalAmount__c = cr.NetTotalAmount__c;
            newOrderLineItems.APTS_Tax_Amount__c = cr.TaxAmount__c;
            newOrderLineItems.Product__c = lineItemProductNameMap.get(cr.ProductName__c);
            newOrderLineItems.EndDate__c = cr.end_date__C;
            newOrderLineItems.StartDate__c = cr.start_date__C;
            newOrderLineItems.LineType__c = cr.LineType__c;// I-199627 changes by Apttus
            OrderLineItemToBeInserted.add(newOrderLineItems);
        }
        return OrderLineItemToBeInserted;
    }

  //  @future
    public  void SendForVerification(set<id> OldProposalset   )
    {
        System.debug('**** Inside APTS_creditHelper.SendForVerification()');
        System.debug(' AvalaraModel.OldProposalset '+OldProposalset);
        List<Order__c> OrderListALL = new List<Order__c>();
        set<id> orginalOrderIds  = new set<id>();
        List<Apttus_Proposal__Proposal__c> ProposalList = [select id, Orig_Order_link__c,
                                                           APTS_Quote_Type__c ,Conversion_Proposal__c,
                                                           Orig_Order_link__r.CreditRequest__c ,
                                                           (select id,
                                                            SentToVerificationBy2__c,
                                                            OrderStatus__c,
                                                            DoNotMsgBtnFlg__c,
                                                            QuoteProposal__r.Conversion_Proposal__c,
                                                            QuoteProposal__r.APTS_Quote_Type__c
                                                            FROM Orders__r)
                                                           FROM Apttus_Proposal__Proposal__c
                                                           WHERE  id  = :OldProposalset
                                                          ];

        for(Apttus_Proposal__Proposal__c oTemp  : ProposalList)
        {
            If(  oTemp.Conversion_Proposal__c  || (string.isnotBlank(oTemp.APTS_Quote_Type__c) && oTemp.APTS_Quote_Type__c == 'Product Conversion'))
            {
                List<Order__c> OrderList = oTemp.Orders__r;

                for(Order__c oOrder : OrderList)
                {
                    OrderListALL.add(oOrder);
                }

                System.debug(' oTemp.Orig_Order_link__c '+oTemp.Orig_Order_link__c);
                orginalOrderIds.add(oTemp.Orig_Order_link__c);
            }
        }
        System.debug(' AvalaraModel.OrderListALL '+OrderListALL);
        System.debug(' orginalOrderIds '+orginalOrderIds);
        if(orginalOrderIds.size() > 0 )
        {
            List<Credit_Request__c> CRlist = [select id,
                                              (
                                                  select id, is_credit__c,
                                                  SentToVerificationBy2__c,
                                                  OrderStatus__c,
                                                  DoNotMsgBtnFlg__c,
                                                  QuoteProposal__r.Conversion_Proposal__c,
                                                  QuoteProposal__r.APTS_Quote_Type__c
                                                  FROM Related_Orders__r
                                              )

                                              FROM Credit_Request__c where order__c = : orginalOrderIds];
            System.debug('CRlist ' + CRlist);
            List<Order__c> CR_OrderList = new List<Order__c>();
            for(Credit_Request__c oCR : CRlist )
            {
                CR_OrderList = oCR.Related_Orders__r;
                if(CR_OrderList.size() > 0)
                {
                    OrderListALL.addAll(CR_OrderList);
                }
                System.debug('CR_OrderList ' + CR_OrderList);
            }
        }

        if(OrderListALL.size() > 0 )
        {
            for(Order__c oOrder : OrderListALL)
            {
                System.debug('^^^ Order ID=' + oOrder.Id +
                            ', QuoteProposal__r.Conversion_Proposal__c=' + oOrder.QuoteProposal__r.Conversion_Proposal__c +
                            ', QuoteProposal__r.APTS_Quote_Type__c=' + oOrder.QuoteProposal__r.APTS_Quote_Type__c +
                            ', DoNotMsgBtnFlg__c=' + oOrder.DoNotMsgBtnFlg__c);
                //Jeff L added this to skip the avalara callout for the conversion orders
                //Per Julie Dumas on I-188987
                if(oOrder.QuoteProposal__r.Conversion_Proposal__c ||
                    (string.isnotBlank(oOrder.QuoteProposal__r.APTS_Quote_Type__c) && oOrder.QuoteProposal__r.APTS_Quote_Type__c == 'Product Conversion') )
                {
                    system.debug(' Skip avalara for these product conversion orders');
                } else
                {
                    System.debug(' Calling AvalaraModel.getOrderTaxFromButton ' + oOrder.id);
                    AvalaraModel.getOrderTaxFromButton(oOrder.id);
                }

                oOrder.SentToVerificationBy2__c =userinfo.getUserId();
                oOrder.OrderStatus__c = 'Sent To Verification';

                /*J Freese Appirio I-214763 4/5/16 DK what this DoNotMsgBtnFlg__c is for but it is populated for only one test record on prod
                  Also SendOrderToSite is the wrong method to use.  Change the approach to that used for Credit & Rebill orders in
                  CreditRequestTriggerHelper.createOrderForCreditRequestAndProposal() where it sets the orders to Sent To Verification
                  It calls BizAppsSiteModel.autoTriggerVerificationForCredit, which sends each order to VerifyOrder()
                if(string.isnotblank(oOrder.DoNotMsgBtnFlg__c) && oOrder.DoNotMsgBtnFlg__c !='No')
                {
                    BizAppsSiteModel.SendOrderToSite(oOrder.id);
                }*/
            }
            Update OrderListALL;
            BizAppsSiteModel.autoTriggerVerificationForCredit(OrderListALL);
        }
    }


}