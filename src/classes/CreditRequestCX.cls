public without sharing class CreditRequestCX {
    final String CLASSNAME = '\n\n**** CreditRequestCX .METHODNAME()';
    private integer totalRecs = 0;
    private integer OffsetSize = 0;
    private integer LimitSize= 100;
    private User RunningUser;
    public Credit_Request__c CreditRequest{get;set;}
    public List<SelectOption> listCreditCondition{get;set;}
    public Order__c Orders{get;set;}
    public Id OrderId{get;set;}
    public PageReference refresh = ApexPages.currentPage();
    public String CreditCondition{get;set;}
    public Boolean requiredForEU {get;set;}
    public Boolean showOutputField{get;set;}
    public Boolean disableCreditAmount{get;set;}
    public list<CreditRequestLineItemWrapper> CreditRequestLineItemList{get;set;}
    public list<NonMsgOLIWrap> NonMsgOLIWrapList{get;set;}
    map<Id,Decimal> netRemainingCreditAmount;
    map<Id,Decimal> grossRemainingCreditAmount;

    public LicenseIDModel LicenseModel {get; set;}
    public String[] AjaxOutput {get; set;}
    public  boolean fullVerifiedOrderFlag{get;set;}
    public boolean ecommCreditRebill{get;set;}
    private Boolean InsertProcess = true;
    private map<Id, CreditRequestLineItem__c> LinesToBeDeleted = new map<Id, CreditRequestLineItem__c>();
    public Boolean hasoption{get;set;}
    public Id CreditRequestRTypeFinalId;

    public String LineDeleteMsg {get{
        String output = '';
        if(!LinesToBeDeleted.isEmpty()){
            output += '\n\n '+ Label.You_unselected + ' ' + LinesToBeDeleted.size() + ' '+ Label.line_s +' \n '+ Label.Unselected_lines_will_be_deleted +'\n\n';
        }
        return output;
    }}

    public CreditRequestCX(ApexPages.StandardController controller){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','CreditRequestCX');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        RunningUser = [SELECT Organisation__c FROM User WHERE Id = :UserInfo.getUserId()];

        AjaxOutput = new String[]{};
        LicenseModel = new LicenseIDModel();

        showOutputField = false;
        disableCreditAmount = false;
        requiredForEU = false;

        try{
            CreditRequestLineItemList = new list<CreditRequestLineItemWrapper>();
            if(ApexPages.currentPage().getParameters().containsKey('oid')){
                initForCreate(runningUser);
            }else{
                initForEdit(controller.getId());
            }
            listCreditCondition = new List<SelectOption>();
            For(CreditCondition__c cnt:CreditCondition__c.getall().values()){
                if(CreditRequest.CreditReason__c == 'Federal or State/Province/HST Tax Issue' || CreditRequest.CreditReason__c == 'Tax Error'){
                        listCreditCondition.add( new SelectOption(cnt.Name,cnt.Name));
                }else{
                    if(cnt.Name != 'Tax'){
                        listCreditCondition.add( new SelectOption(cnt.Name,cnt.Name));
                    }
                }
            }
        }catch(Exception e){
            system.debug('\n\nInit Error: ' + e + '\n\n');
            AddPageErrors(new String[]{Label.Initialization_failed, Label.Please_see_system_logs_for_details, 'Error: ' + e, 'Trace: ' + e.getStackTraceString()});
        }
        parentOrderHasFullCreditVerfiedOrder();
        isEcommCreditRebillOrder();
    }

    private void initForEdit(Id pCRId){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','initForEdit');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        InsertProcess = false;
        LicenseModel.IsInsert = false;
        if(pCRId == null){
            String initError =Label.Invalid_Credit_Request_ID;
            AddPageError(initError);
            throw BaseApplicationException.NewException(initError, initError);
            return;
        }
        Credit_Request__c[] CreditRequestList = [
            SELECT Id,
            BillingAccount__c, BillingCustomerNumber__c, SalesRep__c, SalesChannel__c, OrderDate__c, PaymentTerm__c, Payment_Frequency__c, Payment_Method__c,
            CreditScenario__c, CreditReason__c, DetailedCreditReason__c, InvoiceNumber__c, Whocausedthecredit__c , ApprovalStatus__c,
            Order__c,Order__r.QuoteProposal__r.Number_of_Installment__c,
            (
                SELECT Id,
                Order_Line_Item__c,
                CurrencyIsoCode,
                AgencyCommission__c,
                Unit_Price__c,
                AvailableCreditAmount__c,
                NetRemainingCreditAmount__c,
                ProductName__c,
                OrderLineItemQuantity__c,
                Xcode__c,
                TaxAmount__c,
                NetTotalAmount__c,
                CreditAmount__c,
                NetCreditAmount__c,
                VATNationalTaxCode__c,
                StateProvinceTaxCode__c,
                VATNationalTaxRate__c,
                StateProvinceTaxRate__c,
                CreditType__c,
                Quantity__c
                FROM Credit_Request_Line_Items__r
            )
            FROM Credit_Request__c WHERE Id = :pCRId
        ];

        if(CreditRequestList != null && CreditRequestList.size() > 0){
            CreditRequest = CreditRequestList[0];
            if(!CreditRequest.Credit_Request_Line_Items__r.isEmpty()){
                map<Id, Order_Line_Item__c> OLIMap = new map<Id, Order_Line_Item__c>([SELECT Id,
                     NetTotalAmount__c,
                     HasOptions__c,
                     Option_Bundle_Code__c,
                     OptionId__c,
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
                     AvailableInventory__c,
                     NonMessaging_Available_Quantity__c,  // added for T-578921
                     NetRemainingCreditAmount__c,
                     AgencyCommission__c,
                     NetCreditAmount__c,
                     Xcode_calc__c,
                     Name
                     FROM Order_Line_Item__c WHERE Order__c = :CreditRequest.Order__c]);

                for(CreditRequestLineItem__c crli : CreditRequest.Credit_Request_Line_Items__r){
                    CreditRequestLineItemWrapper item = new CreditRequestLineItemWrapper(crli, OLIMap.get(crli.Order_Line_Item__c));
                    item.selected = true;
                    CreditRequestLineItemList.add(item);
                }
                ComputeCreditAmount();
            }
        }

    }

    private void initForCreate(User u){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','initForCreate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        String recordType = ApexPages.currentPage().getParameters().get('recordtype');
        CreditRequest = new Credit_Request__c();
        OrderId = ApexPages.currentPage().getParameters().get('oid');
        CreditRequest.Order__c = OrderId;
        Id CreditRequestRTId;
        Orders = [SELECT Id, Payment_Term_text__c, Payment_Method_text__c, Payment_Frequency__c,
         BillingStartDt__c,OrderDate__c, Account__r.AccountID__c, Account__r.Name
         ,SalesChannel__c, Account__r.Owner.FirstName, Account__r.Owner.LastName,
         CurrencyIsoCode, New_Number_of_Installment__c  , QuoteProposal__r.Number_of_Installment__c,
         Earliest_Product_Start_DT__c, LatestProductEndDate__c
         FROM Order__c WHERE Id =: OrderId];
        //Get the recordTypeId based on the button clicked by the user.


        map<String, Id> RecordTypes = Utility.GetRecordTypeIdsBySObjectNameSet(new set<String>{'Credit_Request__c'}).get('Credit_Request__c');
        Profile_Permissions__c profilePermissions = Profile_Permissions__c.getInstance(userinfo.getProfileId());

        if(u.Organisation__c == 'Asia Pacific'){
            CreditRequestRTypeFinalId = RecordTypes.get('APAC Credit Request');
            if(profilePermissions.Do_Not_Show_Fraudlent_Order__c == True)
                CreditRequestRTId = RecordTypes.get('APAC Sales'); ////I-219716
            else
                CreditRequestRTId  = CreditRequestRTypeFinalId ;
        }
        else if(u.Organisation__c == 'Europe'){
            CreditRequestRTypeFinalId = RecordTypes.get('EU Credit Request');
            if(profilePermissions.Do_Not_Show_Fraudlent_Order__c == True)
                CreditRequestRTId = RecordTypes.get('EU Sales');
            else
                CreditRequestRTId  = CreditRequestRTypeFinalId ;
            //requiredForEU = true; //Sylvester Agyen (Appirio) - Use this to require "Who Cause Credit" on VF page
        }
        else if(u.Organisation__c == 'North America'){
            CreditRequestRTypeFinalId = RecordTypes.get('NA Credit Request');
            if(profilePermissions.Do_Not_Show_Fraudlent_Order__c == True)
                CreditRequestRTId = RecordTypes.get('NA Sales'); ////I-219716
            else
                CreditRequestRTId  = CreditRequestRTypeFinalId ;
        }
        // I-179701
        if(CreditRequestRTId != null){
            CreditRequest.RecordTypeId = CreditRequestRTId;
        }
        CreditRequest.BillingAccount__c = Orders.Account__r.Name;
        CreditRequest.BillingCustomerNumber__c = Orders.Account__r.AccountID__c;
        CreditRequest.SalesRep__c = Orders.Account__r.Owner.FirstName + ' '+ Orders.Account__r.Owner.LastName;
        CreditRequest.PrimarySalesRep__c = Orders.Account__r.OwnerId;
        CreditRequest.SalesChannel__c = Orders.SalesChannel__c;
        CreditRequest.OrderDate__c = Orders.OrderDate__c;
        CreditRequest.CurrencyIsoCode = Orders.CurrencyIsoCode;
        CreditRequest.Billing_Start_Date__c = Orders.BillingStartDt__c;
        CreditRequest.PaymentTerm__c = Orders.Payment_Term_text__c;
        CreditRequest.Payment_Frequency__c = Orders.Payment_Frequency__c;
        CreditRequest.Payment_Method__c = Orders.Payment_Method_text__c;
        CreditRequest.New_Number_of_Installments__c = Orders.New_Number_of_Installment__c;

        totalRecs = [SELECT COUNT() FROM Order_Line_Item__c WHERE Order__c = : OrderId];
        CreditRequestLineItemList = new list<CreditRequestLineItemWrapper>();
        netRemainingCreditAmount = new map<Id,Decimal>();
        grossRemainingCreditAmount = new map<Id,Decimal>();
        for(Order_Line_Item__c oli : [SELECT Id,
                                                 NetTotalAmount__c,
                                                 GrossRemainingCreditAmount__c,
                                                 APTS_Tax_Amount__c,
                                                 Option_Bundle_Code__c,
                                                 OptionId__c,
                                                 HasOptions__c,
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
                                                 AvailableInventory__c,
                                                 NonMessaging_Available_Quantity__c,  // added for T-578921
                                                 NetRemainingCreditAmount__c,
                                                 AgencyCommission__c,
                                                 NetCreditAmount__c,
                                                 Xcode_calc__c,
                                                 Name,
                                                 isMessaging__c,

                                                 CurrencyIsoCode,
                                                 Agency_Discount_Percent__c
                                      FROM Order_Line_Item__c
                                      WHERE Order__c = : orderId]){
            if(oli.VATNationalTaxRate__c == null){
                oli.VATNationalTaxRate__c = 0.0;
            }
            if(oli.VATNationalTaxAmount__c == null){
                oli.VATNationalTaxAmount__c = 0.0;
            }

            netRemainingCreditAmount.put(oli.Id,oli.NetRemainingCreditAmount__c );
            grossRemainingCreditAmount.put(oli.Id,oli.GrossRemainingCreditAmount__c);
            CreditRequestLineItem__c crli = new CreditRequestLineItem__c();
            crli.CurrencyIsoCode = oli.CurrencyIsoCode;
            crli.Order_Line_Item__c = oli.Id;
            crli.AgencyCommission__c = oli.Agency_Discount_Percent__c;
            crli.Unit_Price__c = oli.GrossUnitPrice__c;
            crli.AvailableCreditAmount__c = oli.GrossRemainingCreditAmount__c == null ? 0 : oli.GrossRemainingCreditAmount__c;
            crli.NetRemainingCreditAmount__c = oli.NetRemainingCreditAmount__c;
            crli.ProductName__c = oli.ProductNameText__c;
            crli.OrderLineItemQuantity__c = oli.Quantity2__c;
            crli.Xcode__c = oli.Xcode_calc__c;
            crli.TaxAmount__c = oli.APTS_Tax_Amount__c==null ? 0 :oli.APTS_Tax_Amount__c;
            crli.NetTotalAmount__c = oli.NetTotalAmount__c;
            crli.CreditAmount__c = 0;//oli.Remaining_Credit_Amount__c;
            crli.NetCreditAmount__c = 0;//oli.GrossRemainingCreditAmount__c;
            crli.VATNationalTaxCode__c = oli.VATNationalTaxCode__c;
            crli.StateProvinceTaxCode__c = oli.StateProvinceTaxCode__c;
            crli.VATNationalTaxRate__c = oli.VATNationalTaxRate__c;
            crli.StateProvinceTaxRate__c = oli.StateProvinceTaxRate__c;

            CreditRequestLineItemList.add(new CreditRequestLineItemWrapper(crli, oli));
            hasoption = oli.HasOptions__c;
        }
    }

    /*
    * @description A method that selects all the record in the table.
    * @author Cloudsherpas
    * @date 6-23-2014
    * @param none
    * @returns none
    */
    public void SelectAllRecord(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','SelectAllRecord');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            if(InsertProcess){
                ChangeCreditConditionInsert();
            }else{
                ChangeCreditConditionEdit();
            }
            if(CreditCondition == 'Full'){
                showOutputField = false;
                for(CreditRequestLineItemWrapper crliw : CreditRequestLineItemList){
                    crliw.selected = true;
                }

            }else if(CreditCondition == 'Partial' || CreditCondition == 'Tax'){
                showOutputField = true;
                for(CreditRequestLineItemWrapper crliw : CreditRequestLineItemList){
                    crliw.selected = false;
                }
            }
            ComputeCreditAmount();
        }catch(Exception ex){
            ApexPages.addMessages(ex);
        }
    }
    /*
    * @description A method that updates the Credit condition.
    * @author Cloudsherpas
    * @date 6-23-2014
    * @param none
    * @returns none
    */
    public void refreshCreditCondition(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','refreshCreditCondition');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            listCreditCondition.clear();

            if(CreditRequest.CreditScenario__c == 'Credit and Rebill'){
                    listCreditCondition.add( new SelectOption('Full','Full'));
                    listCreditCondition.add( new SelectOption('Partial','Partial'));//I-195652 Chatter 2 August by Elizabeth Andrews
                    CreditCondition = 'Full';

            }
            else {
                for(CreditCondition__c cnt:CreditCondition__c.getall().values()){
                    system.debug('==CreditRequest=='+CreditRequest);
                    system.debug('==cc=='+CreditCondition__c.getall().values());


                      if(CreditRequest.CreditReason__c == Label.Goodwill_gesture ||
                       CreditRequest.CreditReason__c == Label.Misunderstanding_on_website ||
                       CreditRequest.CreditReason__c == Label.Order_processed_in_error ||
                       CreditRequest.CreditReason__c == Label.Overlap_on_contracts ||
                       CreditRequest.CreditReason__c == Label.Posting_account_invalid ||
                       CreditRequest.CreditReason__c == Label.Price_discount_currency_incorrect||
                       CreditRequest.CreditReason__c == Label.Product_swap_conversion ||
                       CreditRequest.CreditReason__c == Label.Product_quantity_incorrect ||
                       CreditRequest.CreditReason__c == Label.Products_dissatisfaction ||
                       CreditRequest.CreditReason__c == Label.Sales_reversal ||
                       CreditRequest.CreditReason__c == Label.Service_activation_change ||
                       CreditRequest.CreditReason__c == Label.Unresolved_sales_queries ||
                       CreditRequest.CreditReason__c == Label.Up_Sell ||
                       CreditRequest.CreditReason__c == Label.Client_Error ||
                       CreditRequest.CreditReason__c == Label.Duplicate ||
                       CreditRequest.CreditReason__c == Label.Fraud ||
                       CreditRequest.CreditReason__c == Label.Sales_Concession ||
                       CreditRequest.CreditReason__c == Label.Site_Tech_Issues ||
                       // CreditRequest.CreditReason__c == Label.Technical_Issue ||
                       CreditRequest.CreditReason__c == Label.Termination ||
                       CreditRequest.CreditReason__c == Label.Test_Order
                    ){
                        if(cnt.Name != 'Tax'){
                            listCreditCondition.add( new SelectOption(cnt.Name,cnt.Name));
                            /* *********** testing 123 */
                            if(CreditRequest.CreditReason__c == Label.Client_Error){
                            system.debug('Check for testing ' + listCreditCondition);
                            }

                        }
                    }else if(CreditRequest.CreditReason__c == Label.Technical_Issue){
                        if(cnt.Name == 'Full' && CreditRequest.CreditScenario__c == 'Credit and Rebill'){
                            listCreditCondition.add( new SelectOption(cnt.Name,cnt.Name));
                            CreditCondition = 'Full';
                        }
                        else if(cnt.Name != 'Tax' && CreditRequest.CreditScenario__c == 'Credit'){
                            listCreditCondition.add( new SelectOption(cnt.Name,cnt.Name));
                        }


                    }else if(CreditRequest.CreditReason__c == Label.Upgrade_Services ||
                             CreditRequest.CreditReason__c == Label.Address_VAT_number_invalid ||
                             CreditRequest.CreditReason__c == Label.Billing_account_invalid ||
                             CreditRequest.CreditReason__c == Label.Payment_type_incorrect ||
                             CreditRequest.CreditReason__c == Label.PO_Incorrect_missing ||
                             CreditRequest.CreditReason__c == Label.Sales_channel_incorrect ||
                             CreditRequest.CreditReason__c == Label.Agency_Commission ||
                             CreditRequest.CreditReason__c == Label.Change_in_Non_Standard_Payment_Terms ||
                             CreditRequest.CreditReason__c == Label.Change_in_Standard_Payment_Terms ||
                             CreditRequest.CreditReason__c == Label.Federal_or_State_Province_HST_Tax_Issue ||
                             CreditRequest.CreditReason__c == Label.Order_Detail_Correction ||
                             CreditRequest.CreditReason__c == Label.Product_Conversion ||
                             CreditRequest.CreditReason__c == Label.Incorrect_Tax ||
                             CreditRequest.CreditReason__c == Label.Billing_Start_Date_Correction ||
                             CreditRequest.CreditReason__c == Label.Fraudulent_order
                    ){
                        if(cnt.Name == 'Full'){
                            listCreditCondition.add( new SelectOption(cnt.Name,cnt.Name));
                            CreditCondition = 'Full';
                        }
                    }else if(CreditRequest.CreditReason__c == 'Tax Error'){
                        if(cnt.Name == 'Tax'){
                            listCreditCondition.add( new SelectOption(cnt.Name,cnt.Name));
                            CreditCondition = 'Tax';
                        }
                    }
                }

          }

            if(InsertProcess){
                ChangeCreditConditionInsert();
            }else{
                ChangeCreditConditionEdit();
            }
            SelectAllRecord();
        }catch(Exception ex){
            AddPageErrors(new String[]{'Error: ' + ex, 'Trace: ' + ex.getStackTraceString()});
        }
    }

    public void ChangeCreditConditionEdit(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','ChangeCreditConditionEdit');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        Credit_Request__c[] CreditRequestList = [
            SELECT Id,
            BillingAccount__c, BillingCustomerNumber__c, SalesRep__c, SalesChannel__c, OrderDate__c, Payment_Frequency__c, PaymentTerm__c, Payment_Method__c,
            CreditScenario__c, CreditReason__c, DetailedCreditReason__c, InvoiceNumber__c, Whocausedthecredit__c , ApprovalStatus__c,
            Order__c,
            (
                SELECT Id,
                Order_Line_Item__c,
                CurrencyIsoCode,
                AgencyCommission__c,
                Unit_Price__c,
                AvailableCreditAmount__c,
                NetRemainingCreditAmount__c,
                ProductName__c,
                OrderLineItemQuantity__c,
                Xcode__c,
                TaxAmount__c,
                NetTotalAmount__c,
                CreditAmount__c,
                NetCreditAmount__c,
                VATNationalTaxCode__c,
                StateProvinceTaxCode__c,
                VATNationalTaxRate__c,
                StateProvinceTaxRate__c,
                CreditType__c,
                Quantity__c
                FROM Credit_Request_Line_Items__r
            )
            FROM Credit_Request__c WHERE Id = :CreditRequest.Id
        ];

        if(CreditRequestList != null && CreditRequestList.size() > 0){
            Credit_Request__c TempCreditRequest = CreditRequestList[0];

            if(!CreditRequest.Credit_Request_Line_Items__r.isEmpty()){
                map<Id, Order_Line_Item__c> OLIMap = new map<Id, Order_Line_Item__c>([SELECT Id,
                     NetTotalAmount__c,
                     GrossRemainingCreditAmount__c,
                     HasOptions__c,
                     Option_Bundle_Code__c,
                     OptionId__c,
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
                     AvailableInventory__c,
                     NonMessaging_Available_Quantity__c,  // added for T-578921
                     NetRemainingCreditAmount__c,
                     AgencyCommission__c,
                     Order__c,
                     NetCreditAmount__c,
                     Xcode_calc__c,
                     Name,
                     IsMessaging__c
                     FROM Order_Line_Item__c WHERE Order__c = :CreditRequest.Order__c]);

                for(CreditRequestLineItem__c crli : TempCreditRequest.Credit_Request_Line_Items__r){
                    Order_Line_Item__c oli = OLIMap.get(crli.Order_Line_Item__c);

                    CreditRequestLineItemWrapper crliw = new CreditRequestLineItemWrapper(crli, oli);

                    Double VATNationalTaxAmount = oli.VATNationalTaxAmount__c == null ? 0 : oli.VATNationalTaxAmount__c;
                    Double StateProvinceTaxAmount = oli.StateProvinceTaxAmount__c == null ? 0 : oli.StateProvinceTaxAmount__c;
                    hasoption = oli.HasOptions__c;
                    if(CreditCondition == 'Full'){
                        crli.CreditAmount__c = crli.AvailableCreditAmount__c;
                        crli.NetCreditAmount__c = Utility.parseDouble(crli.CreditAmount__c) - (divideBy100(crli.AgencyCommission__c) * Utility.parseDouble(crli.CreditAmount__c));


                        crli.TaxAmount__c = oli.APTS_Tax_Amount__c==null ? 0 :oli.APTS_Tax_Amount__c;//VATNationalTaxAmount + StateProvinceTaxAmount;
                        //added for I-218666, if it's a non-messaging product then there is no Available inventory
                        if(oli.isMessaging__c){
                            crli.Quantity__c = oli.AvailableInventory__c;
                        } else {
                            crli.Quantity__c = oli.Quantity2__c;
                        }


                    }
                    if(CreditCondition == 'Tax'){
                        crli.TaxAmount__c =  oli.APTS_Tax_Amount__c==null ? 0 :oli.APTS_Tax_Amount__c;//VATNationalTaxAmount + StateProvinceTaxAmount;
                    }
                    if(CreditRequestLineItemList.size() < 1){
                        CreditRequestLineItemList.add(crliw);
                    }
                }
            }
        }
    }
    /*
    * @description A method that makes the Credit Amount inputfield visible but not editable.
    * @author Cloudsherpas
    * @date 6-23-2014
    * @param none
    * @returns none
    */
    public void ChangeCreditConditionInsert(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','ChangeCreditConditionInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        CreditRequestLineItemList.clear();
        try{
            for(Order_Line_Item__c oli : [SELECT Id,
                                                 NetTotalAmount__c,
                                                 APTS_Tax_Amount__c,
                                                 Option_Bundle_Code__c,
                                                 HasOptions__c,
                                                 OptionId__c,
                                                 BasePrice__c,
                                                 Quantity2__c,
                                                 Remaining_Credit_Amount__c,
                                                 ProductNameText__c,
                                                 Quantity__c,
                                                 BaseUnitPrice__c,
                                                 GrossRemainingCreditAmount__c,
                                                 NetRemainingCreditAmount__c,
                                                 GrossUnitPrice__c,
                                                 AvailableInventory__c,
                                                 NonMessaging_Available_Quantity__c,  // added for T-578921
                                                 AgencyCommission__c,
                                                 GrossTotalAmount__c,
                                                 Xcode_calc__c,
                                                 VATNationalTaxCode__c,
                                                 VATNationalTaxRate__c,
                                                 VATNationalTaxAmount__c,
                                                 StateProvinceTaxCode__c,
                                                 StateProvinceTaxRate__c,
                                                 StateProvinceTaxAmount__c,
                                                 Agency_Discount_Percent__c,
                                                 NetCreditAmount__c,
                                                 Name,
                                                 CurrencyIsoCode,
                                                 IsMessaging__c,
                                                 Multi_License__c,
                                                 Number_of_Lic__c
                                          FROM Order_Line_Item__c WHERE Order__c = : orderId]){
                CreditRequestLineItem__c crli = new CreditRequestLineItem__c();
                crli.Order_Line_Item__c = oli.Id;
                crli.ProductName__c = oli.ProductNameText__c;
                crli.Unit_Price__c =oli.BaseUnitPrice__c;
                if(oli.VATNationalTaxRate__c == null){
                    oli.VATNationalTaxRate__c = 0.0;
                }
                if(oli.VATNationalTaxAmount__c == null){
                    oli.VATNationalTaxAmount__c = 0.0;
                }
                system.debug('^oli.VATNationalTaxAmount__c: '+ oli.VATNationalTaxAmount__c);
                system.debug('^oli.StateProvinceTaxRate__c: '+ oli.StateProvinceTaxRate__c);
                system.debug('^oli.StateProvinceTaxAmount__c: '+ oli.StateProvinceTaxAmount__c);
                system.debug('^oli.StateProvinceTaxRate__c: '+ oli.StateProvinceTaxRate__c);
                crli.AgencyCommission__c = oli.Agency_Discount_Percent__c;
                crli.Unit_Price__c = oli.GrossUnitPrice__c;
                crli.AvailableCreditAmount__c = oli.GrossRemainingCreditAmount__c == null ? 0 : oli.GrossRemainingCreditAmount__c;
                crli.VATNationalTaxCode__c = oli.VATNationalTaxCode__c;
                crli.StateProvinceTaxCode__c = oli.StateProvinceTaxCode__c;
                crli.VATNationalTaxRate__c = oli.VATNationalTaxRate__c;
                crli.StateProvinceTaxRate__c = oli.StateProvinceTaxRate__c;
                crli.OrderLineItemQuantity__c = oli.Quantity2__c;
                crli.NetTotalAmount__c = oli.NetTotalAmount__c;
                crli.NetCreditAmount__c = 0;//oli.GrossRemainingCreditAmount__c;
                crli.CreditAmount__c = 0;
                crli.NetRemainingCreditAmount__c = oli.NetRemainingCreditAmount__c;
                crli.TaxAmount__c = 0;
                crli.Xcode__c = oli.Xcode_calc__c;
                crli.CurrencyIsoCode = oli.CurrencyIsoCode;
                hasoption = oli.HasOptions__c;
                CreditRequestLineItemWrapper crliw = new CreditRequestLineItemWrapper(crli, oli);

                Double VATNationalTaxAmount = oli.VATNationalTaxAmount__c == null ? 0 : oli.VATNationalTaxAmount__c;
                Double StateProvinceTaxAmount = oli.StateProvinceTaxAmount__c == null ? 0 : oli.StateProvinceTaxAmount__c;

                if(CreditCondition == 'Full'){
                    //Sberron - S-445801.
                    //Added setScale(2) to prevent incorrect rounding in input field.
                    crli.CreditAmount__c = crli.AvailableCreditAmount__c.setScale(2);
                    crli.NetCreditAmount__c = Utility.parseDouble(crli.CreditAmount__c) - (divideBy100(crli.AgencyCommission__c) * Utility.parseDouble(crli.CreditAmount__c));
                    crli.TaxAmount__c = oli.APTS_Tax_Amount__c==null ? 0 :oli.APTS_Tax_Amount__c;//VATNationalTaxAmount + StateProvinceTaxAmount;
                    //added for I-218666, if it's a non-messaging product then there is no Available inventory
                    if(oli.isMessaging__c){
                        crli.Quantity__c = oli.AvailableInventory__c;
                    }
                    //Sberron - S-456527 - 12/20/16
                    //Multi-license products were causing the quantity to be too high, causing validations to fire
                    if(oli.Multi_License__c) {
                        crli.Quantity__c = oli.AvailableInventory__c / oli.Number_of_Lic__c;
                    }
                     else {
                        crli.Quantity__c = oli.Quantity2__c;
                    }
                }
                if(CreditCondition == 'Tax'){
                    crli.TaxAmount__c = oli.APTS_Tax_Amount__c==null ? 0 :oli.APTS_Tax_Amount__c;//VATNationalTaxAmount + StateProvinceTaxAmount;
                }

                CreditRequestLineItemList.add(crliw);
            }
        }catch(Exception ex){
            ApexPages.addMessages(ex);
        }
    }
    /*
    * @description A method that saves the edited record/s on the list.
    * @author Cloudsherpas
    * @date 6-19-2014
    * @param none
    * @returns none
    */
    public pagereference save(){
        //Prashant Gupta, Appirio, I-259418/S-448929 2/16/17
        Savepoint sp = Database.setSavepoint();
        //End
        final string METHODNAME = CLASSNAME.replace('METHODNAME','Save');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        AjaxOutput.clear();
        system.debug('save called');
        system.debug('required for EU value '+ requiredForEU);

        CreditRequestLineItemWrapper[] UsedCreditRequestLineItemList = new CreditRequestLineItemWrapper[]{};

        try{
            Boolean noneSelected = true;

            if(!CreditRequestLineItemList.isEmpty()){
                for(CreditRequestLineItemWrapper crliw : CreditRequestLineItemList){
                    if(crliw.selected == true){
                        noneSelected = false;
                        UsedCreditRequestLineItemList.add(crliw);
                    }
                }
            }

            String[] ErrorMsgs = new String[]{};

            if(noneSelected && InsertProcess){
                ErrorMsgs.add(Label.No_selected_product_data);
            }

            if(CreditRequest.CreditReason__c == null){
                ErrorMsgs.add(Label.Credit_Reason_is_required);
            }
            //Sylvester Agyen (Appirio) - 3/30/16
            if(requiredForEU == true && (CreditRequest.Whocausedthecredit__c == null || CreditRequest.Whocausedthecredit__c == '')){
                ErrorMsgs.add('Who Caused Credit is required');
            }

            //New Validations for blank fields
            if(CreditRequest.CreditReason__c == Label.Billing_Start_Date_Correction){
                if(CreditRequest.Billing_Start_Date__c == null){
                    ErrorMsgs.add('Please enter Billing Start date before proceeding');
                }

                if(CreditRequest.Billing_Start_Date__c == Orders.BillingStartDt__c){
                    ErrorMsgs.add('Billing Start Date cannot be the same as the original order');
                }
            }

            if(CreditRequest.CreditReason__c == Label.Change_in_Standard_Payment_Terms ||
               CreditRequest.CreditReason__c == Label.Payment_type_incorrect){

                if(CreditRequest.Payment_Frequency__c == Orders.Payment_Frequency__c &&
                    CreditRequest.Payment_Method__c == Orders.Payment_Method_text__c &&
                    CreditRequest.PaymentTerm__c == Orders.Payment_Term_text__c &&
                    CreditRequest.New_Number_of_Installments__c == Orders.New_Number_of_Installment__c){
                    ErrorMsgs.add('Payment Details cannot be the same as the original order');
                }

                if(CreditRequest.Payment_Frequency__c != null &&
                    CreditRequest.Payment_Method__c != null &&
                    CreditRequest.PaymentTerm__c != null ){
                    Payment_Details__c paymentDetails = getPaymentDetails();
                    if(paymentDetails == null){
                        ErrorMsgs.add('You current selection of payment details is not valid');
                    } else {
                        CreditRequest.Payment_Details__c = paymentDetails.Id;

                        /* JeffL 10/3/16 commented out for S-444884
                        if(checkNewNumberOfInstallmentsValidation(CreditRequest.New_Number_of_Installments__c,paymentDetails)){
                            ErrorMsgs.add('New Number of Installments cannot be greater than number of installments');
                        }*/
                    }
                } else {
                    ErrorMsgs.add('Please populate all the payment detail fields');
                }
            }
            //system.assert(false ,Orders.QuoteProposal__r.Number_of_Installment__c);

            /*if(Orders.QuoteProposal__r.Number_of_Installment__c <CreditRequest.New_Number_of_Installments__c){
                ErrorMsgs.add('New number of installments cant be greater than related orders Number of installments');
            }*/

            if(!LicenseModel.QuantityErrors.isEmpty()){
                ErrorMsgs.addAll(LicenseModel.QuantityErrors);
            }

            String[] quantityErrors = LicenseModel.checkInventoryQuantity();
            if(!quantityErrors.isEmpty()){
                ErrorMsgs.addAll(quantityErrors);
            }

            if(!ErrorMsgs.isEmpty()){
                AddPageErrors(ErrorMsgs);
                return null;
            }

            if(CreditCondition != null || CreditCondition!= '')
                CreditRequest.Credit_Type__c = CreditCondition;
                system.debug('Testing **********************' + CreditRequest.Credit_Type__c);

            CreditRequest.RecordTypeId = CreditRequestRTypeFinalId ; //I-219716
            system.debug('^^^Credit Request: '+CreditRequest);
            upsert CreditRequest;

        }catch(Exception ex){
            ApexPages.addMessages(ex);
            //Prashant Gupta, Appirio, I-259418/S-448929 2/16/17
            Database.rollback(sp);
            //End
            return null;
        }
        try{
            system.debug('^^^Credit request upserted, processs CR lineitems');
            List<CreditRequestLineItem__c> CRLineItemToBeInserted = new List<CreditRequestLineItem__c>();
            if(!UsedCreditRequestLineItemList.isEmpty()){
                for(CreditRequestLineItemWrapper crliw : UsedCreditRequestLineItemList){
                    crliw.cr.CreditCondition__c = CreditCondition;
                    if(InsertProcess){
                        crliw.cr.Credit_Request__c = CreditRequest.Id;
                    }
                    //Appirio J Freese 3/14/17 S-473405 Validate Credit line items
                    //Appirio J Freese 3/29/17 I-265292 Temporary fix is to add "Please hit Cancel and try again."
                    if (crliw.cr.CreditType__c == 'Amount'){
                      if (crliw.cr.AvailableCreditAmount__c > 0 && (crliw.cr.CreditAmount__c == null || crliw.cr.CreditAmount__c == 0)){
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning, 'If the Product Data line Type is Amount and the Available Credit Amount is > $0, a non-zero Gross Credit Amount must be provided.  Please hit Cancel and try again.'));
                        Database.rollback(sp);
                        return null;
                      }else if (crliw.cr.AvailableCreditAmount__c == 0 && crliw.cr.CreditAmount__c == null){
                        //OK to have AvailableCreditAmount__c == 0 if it's something like Monster Search Trial - Seat Based
                        crliw.cr.CreditAmount__c = 0; // to prevent 'argument cannot be null'
                      }
                    }
                    if (crliw.cr.CreditType__c == 'Inventory' && (crliw.cr.Quantity__c == null || crliw.cr.Quantity__c == 0)){
                      //Appirio J Freese 3/29/17 I-265292 Temporary fix is to add "Please hit Cancel and try again."
                      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning, 'If Product Data line Type is Inventory, a non-zero Credit Quantity must be provided.  Please hit Cancel and try again.'));
                      Database.rollback(sp);
                      return null;
                    }
                    System.debug('CRLI to be inserted: '+crliw.cr);
                    CRLineItemToBeInserted.add(crliw.cr);
                }
            }
            //Sberron - Appirio - 3/09/17 - S-448929
            Decimal total = 0;
            for (CreditRequestLineItem__c crli : CRLineItemToBeInserted) {
              total += crli.CreditAmount__c;
            }
            if(CRLineItemToBeInserted.size() > 0 && total > 0){
                upsert CRLineItemToBeInserted;
            }
            else if (CRLineItemToBeInserted.size() > 0 && total == 0) {
              //Appirio J Freese 3/29/17 I-265292 Temporary fix is to add "Please hit Cancel and try again."
              ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning, 'Cannot create a Credit Request with amount $0.00.  Please hit Cancel and try again.'));
              Database.rollback(sp);
              return null;
            }

            String[] CRLicenseIdResult = LicenseModel.saveTempLicenseIds();
            if(CRLicenseIdResult != null){
                AddPageErrors(CRLicenseIdResult);
            }

            if(!LinesToBeDeleted.isEmpty()){
                delete LinesToBeDeleted.values();
            }

            PageReference CRPage = new ApexPages.StandardController(CreditRequest).view();
            CRPage.setRedirect(true);
            return CRPage;
        }
        catch(Exception ex){
            system.debug('error on save ' + ex);
            ApexPages.addMessages(ex);
            //Prashant Gupta, Appirio, I-259418/S-448929 2/16/17
            Database.rollback(sp);
            //End
            return null;
        }
    }


    public pagereference parentOrderHasFullCreditVerfiedOrder(){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','parentOrderHasFullCreditVerfiedOrder');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        system.debug('Request' + CreditRequest);
        list<order__c> creditOrders = [SELECT ParentOrder__c FROM Order__c WHERE ParentOrder__c = :CreditRequest.Order__c
                                       AND RecordType.Name = 'Credit' AND  OrderStatus__c = 'Verified'];
        if(creditOrders.size()>0)
            fullVerifiedOrderFlag = true;
        else
            fullVerifiedOrderFlag = false;

        return null;
    }

    public pagereference isEcommCreditRebillOrder() {
        final string METHODNAME = CLASSNAME.replace('METHODNAME','isEcommCreditRebillOrder');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        list<Order__c> order = [SELECT Name, Id FROM Order__c WHERE Id = :CreditRequest.Order__c AND RecordType.Name = 'Ecomm'];
        if(order.size()>0) {
            ecommCreditRebill = true;
        }
        else {
            ecommCreditRebill = false;
        }
        return null;
    }

    /*
    * @description A method that computes the credit Amount.
    * @author Cloudsherpas
    * @date 6-19-2014
    * @param none
    * @returns none
    */
    public void ComputeCreditAmount(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','ComputeCreditAmount');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            AjaxOutput.clear();
            for(CreditRequestLineItemWrapper crliw : CreditRequestLineItemList){
                if (crliw.cr.CreditType__c == null){crliw.cr.CreditType__c = 'Amount';}
                Decimal netCredAmount = crliw.cr.NetCreditAmount__c;

                if(crliw.selected == true){
                    if(LinesToBeDeleted.containsKey(crliw.cr.Id)){
                        LinesToBeDeleted.remove(crliw.cr.Id);
                    }
                }

                if(crliw.selected == true && (crliw.cr.CreditType__c == 'Inventory' || CreditCondition == 'Full')){
                    LicenseModel.addRequest(crliw);//adding of License for processing
                }else if(crliw.selected == true && crliw.cr.CreditType__c == 'Amount'){
                    LicenseModel.removeRequest(crliw.cr);//removing of Licens
                    if(crliw.cr.Quantity__c != null){
                        crliw.cr.Quantity__c = null;
                    }
                    if(crliw.cr.CreditAmount__c != null){
                        computeTaxAmountAndNetCreditAmount(crliw, false);
                    }
                }else if(crliw.selected == true && crliw.cr.CreditType__c == null){
                    LicenseModel.removeRequest(crliw.cr);//removing of Licens
                    if(CreditRequest.CreditReason__c == 'Tax Error'){
                        computeTaxAmountAndNetCreditAmount(crliw, true);
                    }
                }else if(crliw.selected == false){
                    if(InsertProcess){
                        crliw.cr.Quantity__c = null;
                        crliw.cr.CreditAmount__c = null;
                        crliw.cr.CreditType__c = null;
                    }else{
                        //logic to collect line to be deleted
                        if(crliw.cr.Id != null){
                            LinesToBeDeleted.put(crliw.cr.Id, crliw.cr);
                        }
                    }
                    LicenseModel.removeRequest(crliw.cr);//removing of Licens
                }
            }
            LicenseModel.init(CreditCondition);//building the model
            // For non messaging OLI - Added by Vikas Menon on 7 Feb, 2017 (refer to S-445863)
            AddNonMessagingCreditLineItem();

        }catch(Exception ex){
            system.debug('\n\nCreditRequestCX.ComputeCreditAmount Error: ' + ex + '\n\nTrace: ' + ex.getStackTraceString() + '\n\n');
            ApexPages.addMessages(ex);
        }
    }


    /* Method for adding Non messaging OLI to license list
       Added by Vikas Menon on 7 Feb, 2017 (refer to S-445863)
    */

    public void AddNonMessagingCreditLineItem(){
        NonMsgOLIWrapList = new List<NonMsgOLIWrap>();
        for(CreditRequestLineItemWrapper wrap : CreditRequestLineItemList) {
             Order_Line_Item__c line = wrap.ParentLineItem;
             if(wrap.selected && wrap.cr.CreditType__c == 'Inventory' && !line.isMessaging__c) {
                       NonMsgOLIWrap msgWrap = new NonMsgOLIWrap(wrap);
                       msgWrap.title = line.Name + ' - ' + line.ProductNameText__c;
                       NonMsgOLIWrapList.add(msgWrap);
             }
        }

    }



    private Payment_Details__c getPaymentDetails(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','getPaymentDetails');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        Payment_Details__c pDetails;
        try{
            pDetails =
            [
                Select Id, PaymentFrequency__c, Installment_Flag__c, True_Term__c
                FROM Payment_Details__c
                WHERE PaymentFrequency__c = :CreditRequest.Payment_Frequency__c AND
                PaymentTerm__c = :CreditRequest.PaymentTerm__c AND
                PaymentMethod__c = :CreditRequest.Payment_Method__c AND
                Organization__c = :RunningUser.Organisation__c LIMIT 1
            ];
        } catch(Exception ex){
            return null;
        }

        return pDetails;
    }

    /*
    * @description A method that saves the edited record/s on the list.
    * @author Cloudsherpas
    * @date 6-19-2014
    * @param none
    * @returns none
    */
    public pagereference Cancel(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','Cancel');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        PageReference CRPage = new PageReference('/'+ OrderId);
        CRPage.setRedirect(true);
        return CRPage;
    }

    private void AddPageErrors(String[] pTxts){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','AddPageErrors');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        for(String txt : pTxts){
            AddPageError(txt);
        }
    }

    private void AddPageError(String txt){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','AddPageError');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        ApexPages.Message PageError = new ApexPages.Message(ApexPages.Severity.FATAL, txt);
        ApexPages.addMessage(PageError);
    }

    public void ComputeCreditquantity(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','ComputeCreditquantity');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        AjaxOutput.clear();
        try{
            LicenseModel.QuantityErrors.clear();
            for(LicenseIDWrapList wrap : LicenseModel.LicenseIDList){
                Integer CredQty = 0;

                for(LicenseIDWrap item : wrap.LicenseList){
                    try{
                        Integer usedQuantity = item.Quantity == null || item.Quantity == '' ? 0 : Integer.valueOf(item.Quantity);
                        if(usedQuantity <= item.License.AvailableInventory__c){
                            System.debug('----usedQuantity ' + usedQuantity);
                            CredQty += usedQuantity;
                        }else{
                            String errorMsg = item.License.Name + ' '+ Label.error_Cannot_credit_more_quantity_than_is_available_on_the_License_ID +'.';
                            LicenseModel.QuantityErrors.add(errorMsg);
                            AjaxOutput.add(errorMsg);
                        }
                    }catch(Exception e){
                        AjaxOutput.add(Label.Quantity_error+' ' + e);
                    }
                }

                if(CredQty > wrap.ParentWrapper.cr.OrderLineItemQuantity__c){
                    System.debug('----CredQty > ');
                    String errorMsg = Label.Error_on +' ' + wrap.ParentWrapper.ParentLineItem.Name + ': '+ Label.Invalid_credit_quantity +' ' + CredQty + ' '+ Label.is_greater_than +' ' + wrap.ParentWrapper.cr.OrderLineItemQuantity__c + '.';
                    AjaxOutput.add(errorMsg);
                    LicenseModel.QuantityErrors.add(errorMsg);
                    wrap.ParentWrapper.cr.Quantity__c = null;
                    wrap.ParentWrapper.cr.CreditAmount__c = null;
                }else{
                    System.debug('----ELSE');
                    wrap.ParentWrapper.cr.Quantity__c = CredQty == 0 ? null : CredQty;
                    wrap.ParentWrapper.cr.CreditAmount__c = CredQty == 0 ? null : wrap.ParentWrapper.cr.Quantity__c * wrap.ParentWrapper.ParentLineItem.GrossUnitPrice__c;
                    computeTaxAmountAndNetCreditAmount(wrap.ParentWrapper, false);
                }
                System.debug('----CredQty END ' + CredQty);
            }
        }catch(Exception e){
            AjaxOutput.add('Error: ' + e);
        }
    }

    /* Method added for Non message product by Vikas Menon, 7 Feb 2017 */

    public void ComputeCreditquantityForNonMsg(){

        AjaxOutput.clear();
        try{
            for(NonMsgOLIWrap wrap : NonMsgOLIWrapList){

                for(CreditRequestLineItem__c item : wrap.crLineItems){
                    try{
                        Integer CredQty = 0;
                        if(item.Quantity__c > 0) {
                             CredQty  = Integer.valueOf(item.Quantity__c);
                        }
                        // Compare credit quantity with parent OLI field "NonMessaging_Available_Quantity__c" (T-578921)
                        if(CredQty > wrap.ParentWrapper.ParentLineItem.NonMessaging_Available_Quantity__c){
                            System.debug('----CredQty > ');
                            String errorMsg = Label.Error_on +' ' + wrap.ParentWrapper.ParentLineItem.Name + ': '+ Label.Invalid_credit_quantity +' ' + CredQty + ' '+ Label.is_greater_than +' ' + wrap.ParentWrapper.ParentLineItem.NonMessaging_Available_Quantity__c + '.';
                            AjaxOutput.add(errorMsg);
                            wrap.ParentWrapper.cr.Quantity__c = null;
                            wrap.ParentWrapper.cr.CreditAmount__c = null;
                        }else{
                            System.debug('----ELSE');
                            wrap.ParentWrapper.cr.Quantity__c = CredQty == 0 ? null : CredQty;
                            wrap.ParentWrapper.cr.CreditAmount__c = CredQty == 0 ? null : wrap.ParentWrapper.cr.Quantity__c * wrap.ParentWrapper.ParentLineItem.GrossUnitPrice__c;
                            computeTaxAmountAndNetCreditAmount(wrap.ParentWrapper, false);
                        }

                    }catch(Exception e){
                        AjaxOutput.add(Label.Quantity_error+' ' + e);
                    }
                }


            }
        }catch(Exception e){
            AjaxOutput.add('Error: ' + e);
        }
    }


    private void computeTaxAmountAndNetCreditAmount(CreditRequestLineItemWrapper crliw, Boolean IsTaxOnly){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','computeTaxAmountAndNetCreditAmount');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        if(IsTaxOnly){
            crliw.cr.NetCreditAmount__c = Utility.parseDouble(crliw.ParentLineItem.GrossRemainingCreditAmount__c) - (divideBy100(crliw.cr.AgencyCommission__c) * Utility.parseDouble(crliw.ParentLineItem.GrossRemainingCreditAmount__c));
        }else{
            crliw.cr.NetCreditAmount__c = Utility.parseDouble(crliw.cr.CreditAmount__c) - (divideBy100(crliw.cr.AgencyCommission__c) * Utility.parseDouble(crliw.cr.CreditAmount__c));
        }
    //  crliw.cr.TaxAmount__c = ((divideBy100(crliw.cr.VATNationalTaxRate__c)) * Utility.parseDouble(crliw.cr.NetCreditAmount__c)) +
       //         ((divideBy100(crliw.cr.StateProvinceTaxRate__c)) * Utility.parseDouble(crliw.cr.NetCreditAmount__c));

        if(IsTaxOnly){
            crliw.cr.NetCreditAmount__c = null; //setting Net Credit Amt after tac is calculated
        }
    }

    public Double divideBy100(Object pValue){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','divideBy100');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        System.debug(pValue);
        System.debug('divideBy100 ' + pValue != null && pValue != 0 ? Double.valueOf(pValue) / 100 : 0);
        return pValue != null && pValue != 0 ? Double.valueOf(pValue) / 100 : 0;
    }

    /**
    * @description a method that mimics a validation done on the quote/proposal Number_of_installment_restriction
    * @author Appirio
    * @date 5-6-16
    * @param integer number of installments, paymentDetails__c
    * @return true or false if it passes the validation or not
    */
    /* JeffL 10/3/16 commented out for S-444884
    private boolean checkNewNumberOfInstallmentsValidation(Decimal newNumberofInstallments, Payment_Details__c paymentDetails){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','checkNewNumberOfInstallmentsValidation');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        Decimal numberOfInstallments = 0;

        system.debug('newNumberofInstallments ' + newNumberofInstallments);
        system.debug('PaymentDetails' + paymentDetails);
        system.debug('EarliestProductStartDate__c ' + Orders.Earliest_Product_Start_DT__c);
        system.debug('LatestProductEndDate__c ' + Orders.LatestProductEndDate__c);
        if(paymentDetails.PaymentFrequency__c == 'Single Payment' || paymentDetails.PaymentFrequency__c == 'Single Invoice'){
            numberOfInstallments = 1;
        } else if(Orders.Earliest_Product_Start_DT__c != null && paymentDetails.Installment_Flag__c == true
                  && Orders.LatestProductEndDate__c != null && paymentDetails.True_Term__c > 0){
            numberOfInstallments = (Integer)((Orders.Earliest_Product_Start_DT__c.daysBetween(Orders.LatestProductEndDate__c)) / paymentDetails.True_Term__c).round();

        }

        return newNumberofInstallments > numberOfInstallments;
    }*/

    /**
    * @description A wrapper class that adds a select option for every record of Credit Request Line Item object.
    * @author Cloudsherpas
    * @date 6-19-2014
    * @param none
    * @returns none
    */
    public class CreditRequestLineItemWrapper{
        public boolean selected{get;set;}
        public Order_Line_Item__c ParentLineItem {get; private set;}
        public CreditRequestLineItem__c cr{get;set;}

        public  CreditRequestLineItemWrapper(CreditRequestLineItem__c cr, Order_Line_Item__c pParentLineItem){
            system.debug('*** New CreditRequestLineItemWrapper');
            system.debug('CreditRequetLineItem ' + cr);
            system.debug('OLI ' + pParentLineItem);
            ParentLineItem = pParentLineItem;
            this.cr = cr;
            this.selected =  false;
        }
    }

    /**
    * @description A model class that holds all data for license ID part of the page
    * @author Cloudsherpas
    * @date 8-19-2014
    * @param none
    * @returns none
    */

    public class LicenseIDModel{
        public Boolean IsInsert {get; set;}
        public String[] QuantityErrors;
        public String[] TestList {get; set;}
        public LicenseIDWrapList[] LicenseIDList {get; set;}
        public Boolean ShowLicenseList {get{return LicenseIDList != null && LicenseIDList.size() > 0;}}
        public Boolean ShowEmptyMessage {get{return !ShowLicenseList;}}

        private map<Id, LicenseIDWrapList> OLIIdToRequestMap = new map<Id, LicenseIDWrapList>();
        private set<Id> CreditRequestLineIdSet = new set<Id>();
        //Map wil contain the license Id and available quantity
        public map<String, Integer> quantityResult ;
        public LicenseIDModel(){
            IsInsert = true;
            TestList = new String[]{};
            LicenseIDList = new LicenseIDWrapList[]{};
            QuantityErrors = new String[]{};
        }

        public void addRequest(CreditRequestLineItemWrapper pLineItem){
            if(pLineItem != null && !OLIIdToRequestMap.containsKey(pLineItem.cr.Order_Line_Item__c)){
                if(pLineItem.cr.Id != null){
                    CreditRequestLineIdSet.add(pLineItem.cr.Id);
                }
                OLIIdToRequestMap.put(pLineItem.cr.Order_Line_Item__c, new LicenseIDWrapList(pLineItem));
            }
        }

        public void removeRequest(CreditRequestLineItem__c pCr){
            if(pCr != null && OLIIdToRequestMap.containsKey(pCr.Order_Line_Item__c)){
                OLIIdToRequestMap.remove(pCr.Order_Line_Item__c);
                for(Integer i = (LicenseIDList.size() - 1); i >= 0; i--){
                    LicenseIDWrapList lw = LicenseIDList[i];
                    if(lw.LineItem.Order_Line_Item__c == pCr.Order_Line_Item__c){
                        LicenseIDList.remove(i);
                    }
                }
            }
        }

        public void init(String CreditCondition){
            QuantityErrors.clear();
            if(OLIIdToRequestMap.size() > 0){

                LicenseID__c[] licenseIdList = [SELECT Id, Name, SiteLicenseID__c, QuantityProvisioned__c, AvailableInventory__c, OrderLineItem__c, Xcode__c, OrderLineItem__r.Name, OrderLineItem__r.Product__r.Name,
                                                            (SELECT Id, CreditQuantity__c, CreditRequest__c, CreditRequestLineItem__c, LicenseID__c  FROM Credit_Request_License_IDs__r WHERE CreditRequestLineItem__c IN :CreditRequestLineIdSet)
                                                            FROM LicenseID__c WHERE OrderLineItem__c IN :OLIIdToRequestMap.keySet()];

                set<string> setSiteId = new set<string>();

                /*S-445896 JFreese Appirio 12/1/16 only send one License ID to Site, to avoid APEX Heap error.
                      Per Apttus (Sivaganesh Ramakrishnan 13Nov2016) sending any license in a family
                      tree returns the whole tree structure, so we only need to send one.*/
                Boolean SentOne = false;
                for(LicenseID__c listWrap : LicenseIDList){
                    if (!SentOne){
                        setSiteId.add(listWrap.SiteLicenseID__c);
                        SentOne = true;
                    }
                }


                if(!setSiteId.isEmpty()){
                    quantityResult = BizAppsSiteModel.GetLicenseAndRelativesForCreditRequest(setSiteId);
                    system.debug('\n\nCHECK ME: ' + quantityResult + '\n\n');
                }

                for(LicenseID__c license : licenseIdList){
                    license.AvailableInventory__c = quantityResult.get(license.SiteLicenseID__c );
                    //jeff L added for Full requests
                    if(OLIIdToRequestMap.containsKey(license.OrderLineItem__c)){
                        LicenseIDWrapList wList = OLIIdToRequestMap.get(license.OrderLineItem__c);
                        if(wList.LicenseList == null ){
                            this.LicenseIDList.add(wList);
                            wList.LicenseList = new LicenseIDWrap[]{};
                            wList.Title = license.OrderLineItem__r.Name + ' - ' + license.OrderLineItem__r.Product__r.Name;
                        }
                        wList.addLicense(license, IsInsert, CreditCondition);
                    }
                }


                /*LicenseID__c[] licenseIdList = [SELECT Id, Name, SiteLicenseID__c, QuantityProvisioned__c, AvailableInventory__c, OrderLineItem__c, Xcode__c, OrderLineItem__r.Name, OrderLineItem__r.Product__r.Name,
                                                            (SELECT Id, CreditQuantity__c, CreditRequest__c, CreditRequestLineItem__c, LicenseID__c  FROM Credit_Request_License_IDs__r WHERE CreditRequestLineItem__c IN :CreditRequestLineIdSet)
                                                            FROM LicenseID__c WHERE OrderLineItem__c IN :OLIIdToRequestMap.keySet()];

                for(LicenseID__c license : licenseIdList){
                    if(OLIIdToRequestMap.containsKey(license.OrderLineItem__c)){
                        LicenseIDWrapList wList = OLIIdToRequestMap.get(license.OrderLineItem__c);
                        if(wList.LicenseList == null ){
                            this.LicenseIDList.add(wList);
                            wList.LicenseList = new LicenseIDWrap[]{};
                            wList.Title = license.OrderLineItem__r.Name + ' - ' + license.OrderLineItem__r.Product__r.Name;
                        }
                        wList.addLicense(license, IsInsert);
                    }
                }*/
            }
        }

        public String[] checkInventoryQuantity(){
            String[] output = new String[]{};
            try{
                map<String, LicenseIDWrap> licenseToCheck = new map<String, LicenseIDWrap>();
                /*S-445896 JFreese Appirio 12/1/16 only send one License ID to Site, to avoid APEX Heap error.
                      Per Apttus (Sivaganesh Ramakrishnan 13Nov2016) sending any license in a family
                      tree returns the whole tree structure, so we only need to send one.*/
                Set<String> SFLicenseToSend = new Set<String>();
                Boolean SentOne = false;

                for(LicenseIDWrapList listWrap : LicenseIDList){
                    for(LicenseIDWrap itemWrap : listWrap.LicenseList){
                        if(itemWrap.Quantity != null && itemWrap.Quantity != '' && Integer.valueOf(itemWrap.Quantity) != 0){
                            licenseToCheck.put(itemWrap.License.SiteLicenseID__c, itemWrap);
                            if (!SentOne){
                                SFLicenseToSend.add(itemWrap.License.SiteLicenseID__c);
                                SentOne = true;
                            }
                        }
                    }
                }
                if(!licenseToCheck.isEmpty()){
                    map<String, Integer> quantityResult = BizAppsSiteModel.GetLicenseAndRelativesForCreditRequest(SFLicenseToSend);
                    system.debug('\n\nCHECK ME: ' + quantityResult + '\n\n');
                    if(!quantityResult.isEmpty()){
                        for(String siteLicense : quantityResult.keySet()){
                            if(licenseToCheck.containsKey(siteLicense)){
                                LicenseIDWrap itemWrap = licenseToCheck.get(siteLicense);
                                Integer quantityToCheck = Integer.valueOf(itemWrap.Quantity);
                                if(quantityToCheck > quantityResult.get(siteLicense)){
                                    output.add(Label.Error_on +' ' + itemWrap.License.Name + ': ' + ' '+ Label.Credit_Quantity_is_greater_than_available_quantity);
                                }
                            }
                        }
                    }
                }
            }catch(Exception e){

            }
            return output;
        }

        public String[] saveTempLicenseIds(){
            try{
                Credit_Request_License_ID__c[] tempLcenseIDList = new Credit_Request_License_ID__c[]{};
                for(LicenseIDWrapList listWrap : LicenseIDList){
                    for(LicenseIDWrap itemWrap : listWrap.LicenseList){
                        if(itemWrap.Quantity != null && itemWrap.Quantity != '' && Integer.valueOf(itemWrap.Quantity) != 0){
                            Credit_Request_License_ID__c tempLcenseID = itemWrap.CreditLicense == null ? new Credit_Request_License_ID__c() : itemWrap.CreditLicense;
                            tempLcenseID.CreditQuantity__c = Decimal.valueOf(itemWrap.Quantity);
                            tempLcenseID.CreditRequestLineItem__c = listWrap.LineItem.Id;
                            tempLcenseID.LicenseID__c = itemWrap.License.Id;
                            tempLcenseIDList.add(tempLcenseID);
                        }
                    }
                }
                upsert tempLcenseIDList;
                return null;
            }catch(Exception e){
                return new String[]{Label.Request_License_ID_Creation_Error, 'Error: ' + e};
            }
        }
    }

    /**
    * @description A wrapper class that holds collection of license ID record
    * @author Cloudsherpas
    * @date 8-19-2014
    * @param none
    * @returns none
    */
    public class LicenseIDWrapList{
        public String Title {get; set;}
        public CreditRequestLineItem__c LineItem {get{return ParentWrapper.cr;} set;}
        public LicenseIDWrap[] LicenseList {get; set;}
        public Boolean Render {get{return LicenseList.size() > 0;}}
        public CreditRequestLineItemWrapper ParentWrapper;
        private set<Id> LicenseIDSet;

        public LicenseIDWrapList(CreditRequestLineItemWrapper pLineItem){
            ParentWrapper = pLineItem;
            LicenseIDSet = new set<Id>();
        }

        public void addLicense(LicenseID__c pLicense, Boolean pIsInsert, String CreditCondition){
            if(!LicenseIDSet.contains(pLicense.Id)){
                LicenseIDSet.add(pLicense.Id);
                if(pIsInsert){
                    LicenseIDWrap wrap = new LicenseIDWrap();
                    wrap.License = pLicense;
                    //Jeff L added as a default
                    if(CreditCondition == 'Full'){
                        wrap.Quantity = String.valueOf(pLicense.AvailableInventory__c);
                    }

                    LicenseList.add(wrap);
                }else{
                    if(!pLicense.Credit_Request_License_IDs__r.isEmpty()){
                        for(Credit_Request_License_ID__c crId : pLicense.Credit_Request_License_IDs__r){
                            LicenseIDWrap wrap = new LicenseIDWrap();
                            wrap.License = pLicense;
                            wrap.CreditLicense = crId;
                            wrap.Quantity = String.valueOf(crId.CreditQuantity__c);
                            LicenseList.add(wrap);
                        }
                    }
                }
            }
        }
    }
    /**
    * @description A wrapper class that holds single license ID record
    * @author Cloudsherpas
    * @date 8-19-2014
    * @param none
    * @returns none
    */
    public class LicenseIDWrap{
        public String Quantity {get; set;}
        public LicenseID__c License {get; set;}
        public Credit_Request_License_ID__c CreditLicense {get; set;}
    }

    public class NonMsgOLIWrap{
         public String title {get; set;}
         public List<CreditRequestLineItem__c> crLineItems {get; set;}
         public CreditRequestLineItemWrapper ParentWrapper {get; set;}

         public NonMsgOLIWrap(CreditRequestLineItemWrapper pLineItem){
             ParentWrapper = pLineItem;
             crLineItems = new List<CreditRequestLineItem__c>();
             crLineItems.add(ParentWrapper.cr);
         }

    }


    /**
    * @description a method for collecting previously displayed records.
    * @author Cloudsherpas
    * @date 6-19-2014
    * @param none
    * @returns none
    */
    public void previous(){
        OffsetSize = OffsetSize - LimitSize;
    }
    /**
    * @description a method for collecting the next set of records to be displayed.
    * @author Cloudsherpas
    * @date 6-19-2014
    * @param none
    * @returns none
    */
    public void next(){
        OffsetSize = OffsetSize + LimitSize;
    }
    public boolean getprev(){
        if(OffsetSize == 0)
            return true;
        else
            return false;
    }
    public boolean getnxt(){
        if((OffsetSize + LimitSize) > totalRecs)
            return true;
        else
            return false;
    }
}