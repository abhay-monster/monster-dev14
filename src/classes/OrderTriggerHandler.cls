/*------------------------------------------------------------------------------
Author:
Company: Cloud Sherpas Inc.
Description: Handler class for Order
Task Reference:

History
08/06/2015  Pratibha Chhimpa        Added for populatePostingContact,populateBillContact
11/6/2015   Pratibha Chhimpa        Code change in populatePostingContact for if condition to populate billing contact if posting contact in Quote is empty
17/6/2015   Pratibha Chhimpa        Method added populatepaymentdetails to get payment details fields from Account
------------------------------------------------------------------------------*/
public without sharing class OrderTriggerHandler extends BaseTriggerHandler {
    final String CLASSNAME = '\n\n**** OrderTriggerHandler.METHODNAME()';
    private integer BatchSize = 0;
    private OrderTriggerHelper helper;
    public static Boolean SKIP_Method = true;
    public static Boolean ExecuteTriggers = true;
    public static Boolean IncreaseRunCount = true; //JFreese Appirio S-470802 2/23/2017
    private static Integer RunCount = 0;
    public static Boolean PreventRecursion = true;
    public static Boolean executeUpdateTrigger = true;
    public static Boolean RunValidCalculation = false ;
    public static Boolean ForceOpportunityUpdates = false;
    public static Boolean CreatingCreditOpportunity {get;set;} //JFreese Appirio 3/2/17 S-456572
    public static Boolean  ProcessingCreditRequest ; //Mitali N Appirio 8/5/17 T-600146
    //public static Boolean ToAvoidUnableToLock = false;
    /*
    ** @author : Cloud Sherpas Inc.
    ** @date : 03/07/2014
    ** @description : the class constructor method
    ** @paramaters : a Boolean value indicating if a trigger is executing or not, an Integer value indicating the number of records in the batch/list
    ** @returns : nothing
    ** @sample call : ContactTriggerHandler handler = new ContactTriggerHandler(Trigger.isExecuting, Trigger.size);
    */
    public OrderTriggerHandler(boolean isExecuting, integer pTriggerSize){

        // trigger is executing
        TriggerIsExecuting = isExecuting;

        // set batch size
        BatchSize = pTriggerSize;

        // intantiate new trigger helper
        helper = OrderTriggerHelper.NewTriggerHelper();
        /*
        note - developer may want to create new or extent the base helper class specific to an sObject (i.e. AccountTriggerHelper)
        */
        if(RunCount == 0)
        {
            CreatingCreditOpportunity = false;//JFreese Appirio 3/2/17 S-456572
            if(ProcessingCreditRequest != True){ //Mitali N Appirio 12/5/17 I-273786
            ProcessingCreditRequest = false ;//Mitali N Appirio 8/5/17 T-600146
            }
        }
    }
    /*
    ** @author : Cloud Sherpas Inc.
    ** @date : 03/07/2014
    ** @description :  this method handles the 'after insert' event for the trigger; it's purpose is to ...
    ** @paramaters : an array of Contact objects
    ** @returns : nothing
    */
    public void OnbeforeInsert(Order__c[] pNewOrders){
        system.debug('Im called');
        if (Personal_Settings__c.getInstance().Trigger_Order__c ==false){
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnbeforeInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        System.debug('===Limits.getQueries=Order==start of Before Insert()====' + Limits.getQueries());
        system.debug('OrderTriggerHandler.ProcessingCreditRequest'+OrderTriggerHandler.ProcessingCreditRequest);
         for(Order__c o : pNewOrders){
         // Mitali N Appirio T-600146 8/5/17 to bypass VR when Account Status is Bad/Negative.
              if(OrderTriggerHandler.ProcessingCreditRequest != null && OrderTriggerHandler.ProcessingCreditRequest == true){
                     o.Bypass_Credit_Status_Validation__c = true;
                 }
         }
        if(UserInfo.getName() == 'Integration MAPP'){
            for(Order__c o : pNewOrders){
                System.debug('^^^ MAPP Insert Order__c ' + o);
            }
            //helper.fixEcomm(pNewOrders);
        }

        for(Order__c ord : pNewOrders){
            System.debug('^^^ Order Billing Contact='+ ord.BillingContact__c + ', Posting Contact=' + ord.Posting_Contact__c);
        }
        try{
            if(ExecuteTriggers && IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                helper.ResetQueries();
                helper.ordersList = pNewOrders;

                //Jeff L adding for debugging purposes
                for(Order__c o : pNewOrders){
                    system.debug('*<> before insert Order Payment details ' + o.PaymentType__c + o.Payment_Method_text__c + o.Payment_Frequency__c + o.Payment_Details__c);

                    //JFreese Appirio 01/26/17 S-452628  Bypass designated validation rules if we are in CR/Rebill Automated handling
                    if(CreditRequestTriggerHandler.CreateOrdersAutomatically != null && CreditRequestTriggerHandler.CreateOrdersAutomatically == true){
                        system.debug('^^^CreditRequestTriggerHandler.CreateOrdersAutomatically=true, so setting Bypass_Validation_Rules__c to true for new order');
                        o.Bypass_Validation_Rules__c = true;
                    }else{
                        system.debug('^^^CreditRequestTriggerHandler.CreateOrdersAutomatically not true, so NOT setting Bypass_Validation_Rules__c to true for new order');
                    }
                    // Mitali N Appirio T-600146 8/5/17 to bypass VR when Account Status is Bad/Negative.
                    if(OrderTriggerHandler.ProcessingCreditRequest != null && OrderTriggerHandler.ProcessingCreditRequest == true){
                        o.Bypass_Credit_Status_Validation__c = true;
                    }
                }

                helper.populateEntityId(pNewOrders,null,null);
                helper.populateSalesRepsFields(pNewOrders);
                helper.PreventCreationOfCreditOrder(pNewOrders);

                helper.updateOrderFieldsFromMAPP(pNewOrders, null);

                helper.FileCreditNegateCaseOnOrderLineItems(pNewOrders);
                helper.ChangeStatusOfProductImplenetationCases(pNewOrders);
                helper.PopulateOrderPriceListFromMAPP(pNewOrders);
                helper.PopulateOrderPrimarySalesRepFromMAPP(pNewOrders);
                //helper.updateCustumerNumberofAccounts(pNewOrders);// I-213220
                //helper.updateCustomerNumberforAccounts(pNewOrders);//AP
                helper.populateSalesChannelAndPaymentDetails(pNewOrders);
                helper.populateOrderFields(pNewOrders);
                helper.populateBillingAddress(pNewOrders);
                helper.populateCRStatusComment(pNewOrders);
                // As per task T-408279
                //Added By Viraj Rana TO Test unable to lock row error is resolved.
                //if(ToAvoidUnableToLock == false){
                    helper.populatePostingContact(pNewOrders);
                    helper.populateNumberOFInstallment(pNewOrders);
                    helper.populateAgencyBillingContact(pNewOrders);
                    helper.populateBillcontactAndBillingAccount(pNewOrders);
                //}
                helper.populateOrderPaymentDetailsByQuote(pNewOrders);
                populatePaymentDetails(pNewOrders);
                //ToAvoidUnableToLock = false;

                helper.PopulateEcommAgencyInfo(pNewOrders);

                // Populate Site channel Id from quote
                helper.setOrderSiteChannelId(pNewOrders) ;

                helper.PopulateAgencyCommission(pNewOrders);
                helper.updateOrdersFormulaFields(pNewORders);
                helper.setOrderSellingCountry(pNewOrders);
                //Only execute this if this is from the integration
                system.debug('%%test%%' +UserInfo.getName());
                if(UserInfo.getName() == 'Integration MAPP'){
                    system.debug('INTEGRATIONRUN');
                    helper.AssignPrimarySalesRepFROMMAPP(pNewOrders);
                    helper.createOpportunity(pNewOrders);
                    helper.PopulateSiteChannelCountry(pNewOrders);
                    helper.PopulateEcommAgencyInfo(pNewOrders);//I-194400
                    helper.updateOrderXcode(pNewOrders);//I-193348
                    helper.PopulateSiteChannelId(pNewOrders);//S-456747; making the call for just ecomm as per S-461972
                }
                // Set IsValid field on Order
                setIsValidOnOrder(pNewOrders, null);
                // helper.populatePaymentDetailsOnChildCreditOrder(pNewOrders);

                for(Order__c order : pNewOrders){
                    system.debug('^^^ Order to insert: ' + order);
                }
            }

            //Jeff L adding for debugging purposes
            list<order__c> lstAgencyOrders = new list<order__c>();
            set<id> agecyIds = new set<id>();
            for(Order__c o : pNewOrders){
                system.debug('*<> before insert (after code) Order Payment details ' + o.PaymentType__c + o.Payment_Method_text__c + o.Payment_Frequency__c + o.Payment_Details__c);
                if(UserInfo.getName() == 'Integration MAPP'){
                    System.debug('^^^ Insert (after code) Order ' + o);
                }
                if(o.agency__c != null){
                    lstAgencyOrders.add(o);
                    agecyIds.add(o.agency__c );
                    }
            }
            if(lstAgencyOrders.size() > 0)
                helper.populatePrimarySalesRepFromAgency(lstAgencyOrders , agecyIds);
            System.debug('===Limits.getQueries=Order==End of Before Insert()====' + Limits.getQueries());
            helper.populateBillingAddressandContact(pNewOrders, Null);
            helper.updateBillingContactName(pNewOrders, Null);
            // I-214451
            helper.populatePostingContactPhoneEmail(pNewOrders);
            // S-443287
            helper.populateBillingStartDataOnRebill(pNewOrders);
            // S-448479 >> Populate PPC Sales rep on order, by Vikas Menon 14 Dec 2016
            helper.populatePPCSalesRepAsOwner(pNewOrders);
            helper.setOrderOrganization(pNewOrders); //SBerron - S-456389 - 05/08/17
        }
        catch(BaseApplicationException bae){

            throw bae;
        }
        catch(Exception ex){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }
    }
    /*
    ** @author : Cloud Sherpas Inc.
    ** @date : 03/07/2014
    ** @description :  this method handles the 'after insert' event for the trigger; it's purpose is to ...
    ** @paramaters : an array of Contact objects
    ** @returns : nothing
    */
    public void OnAfterInsert(Order__c[] pOrderList, map<Id, Order__c> pOrderIdToNewdOrderMap){
        //Jeff L adding for debugging purposes
        for(Order__c o : pOrderList){
            system.debug('*<> after insert (before code) Order Payment details ' + o.PaymentType__c + o.Payment_Method_text__c + o.Payment_Frequency__c + o.Payment_Details__c + o.Payment_Term_text__c);
        }

        if (Personal_Settings__c.getInstance().Trigger_Order__c ==false){
            return; // If triggers are off, then exit the method
        }
        System.debug('===Limits.getQueries=Order==Start of After Insert()====' + Limits.getQueries());
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterInsert');
       // updateOrderTeam(pOrderIdToNewdOrderMap,null) ;
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        helper.ResetQueries();
        helper.ordersList = pOrderList;
        helper.updateOppRollUps(pOrderList);
        //try{
            if(ExecuteTriggers && IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                List<Order__c> orderList1 = new List<Order__c>();
                for(Order__c ord : pOrderList){
                    if(UserInfo.getName() == 'Integration MAPP' && ord.Account__c != null){
                        orderList1.add(ord);
                    }
                    System.debug('@@Order record:' + ord.OrderDate__c + ' : ' + ord.Account__c);
                }

                if(!orderList1.isEmpty()){
                    helper.AssignOrderTeamMembersFromMAPP(orderList1);
                }
                //BulkFullCreditLoadProcessor.startFullCreditLoad(pOrderList);
                if(UserInfo.getName() != 'Integration MAPP'){// Change by Gaurav Gupta on 12-Jan-2017 for S-460212
                    helper.createCaseForVerifiedOrders(pOrderList, null);
                }
                helper.CountallRecords(pOrderList);
                helper.NegateClosedCases(pOrderList);
                helper.ChangeStatusOfCaseOnOrderToCancelled(pOrderList);
                if(UserInfo.getName() == 'Integration MAPP'){
                    //helper.PopulateSiteChannelCountry(pOrderList);
                    helper.updateCustomerNumberofAccounts(pOrderList,pOrderIdToNewdOrderMap);//AP:11/19//I-247190
                    helper.PopulateSalesRep(pOrderList);//AP S-334603
                    helper.PopulatePaymentDetailsInfo(pOrderList);//AP S-334604, I-204120 10/08/2015
                    helper.populatepayGoOrders(pOrderList);//API-225528/I-218165
                    helper.createTask(pOrderList);//AP S-407471
                    //Sberron - S-452845 - I-252821 - 1/18/2017
                    helper.updateEcommOpptyOwner(pOrderList);
                    //helper.populateSiteChannel(pOrderList);
                    //createOpportunity(pOrderList);
                    //helper.updateCustomerNumberofAccounts(pOrderList,pOrderIdToNewdOrderMap);//AP:11/19//I-247190
                }

                //System.assert(false,'After insert:'+Limits.getDMLStatements());
                insertEarliestProductStartDate(pOrderList, null);
            }
            executeUpdateTrigger = false;
            System.debug('===Limits.getQueries=Order==End of After Insert()====' + Limits.getQueries());

            //Jeff L adding for debugging purposes
            for(Order__c o : pOrderList){
                system.debug('*<> after insert (after code) Order Payment details ' + o.PaymentType__c + o.Payment_Method_text__c + o.Payment_Frequency__c + o.Payment_Details__c+o.Payment_Term_text__c);
            }
            // T-586693 >> Create Oppty monthly budgest records
            helper.createOppMonthlyBudget(pOrderList);
    }

    public void OnBeforeUpdate(Order__c[] pOldOrders, Order__c[] pUpdatedOrders, map<ID, Order__c> pOrderIdToOldOrderMap, map<ID, Order__c> pOrderIdToUpdatedOrderMap){
        if (Personal_Settings__c.getInstance().Trigger_Order__c ==false){
            return; // If triggers are off, then exit the method
        }

         //Commented by Mitali (Appirio) 21/4/17 for S-477615 as the same has now been fixed in CreditRequestTriggerHelper
        // Updated by Prashant Gupta Appirio 19/4/17 for S-481535 to bypass the 101 SOQL Error
       /* for(Order__c o : pUpdatedOrders){
            if(o.Count_of_Appoved_Credit_Requests__c != pOrderIdToOldOrderMap.get(o.id).Count_of_Appoved_Credit_Requests__c)
            {
                return;
            }
        } */
        //End

        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        system.debug('**** RunCount='+RunCount+', IncreaseRunCount='+IncreaseRunCount+', PreventRecursion='+PreventRecursion+', CreatingCreditOpportunity='+CreatingCreditOpportunity);

        //Sberron - S-481450 - 4/27/17
        //Check if we are in TABatchOpportunityQueueable & bypassing custom VRs
        Boolean bypassValidationRules = false;
        if(TABatchProposalQueueable.bypassProposalValidationRules != null){
            bypassValidationRules = TABatchProposalQueueable.bypassProposalValidationRules;
        }
        system.debug('^^^bypassValidationRules = '+bypassValidationRules);

        for (Order__c o : pUpdatedOrders){
            system.debug('^^^ ID='+o.Id+', OrderStatus__c=' + o.OrderStatus__c + ', old OrderStatus__c=' + pOrderIdToOldOrderMap.get(o.Id).OrderStatus__c);
            //Sberron - S-481450 - 4/27/17
            //Set bypass if in TA process
            if (bypassValidationRules) {
                o.Bypass_All_Validation_Rules__c = true;
            }
              // Mitali N Appirio T-600146 8/5/17 to bypass VR when Account Status is Bad/Negative
             if(OrderTriggerHandler.ProcessingCreditRequest != null && OrderTriggerHandler.ProcessingCreditRequest == true){
                 o.Bypass_Credit_Status_Validation__c = true;
             }

        }

         //JFreese Appirio S-470802 2/23/2017, suppressed by OrderLineItemTriggerHelper.setFinanceOrderTypeAndSequence()
        if(IncreaseRunCount){
            RunCount++;
        }
        if(RunValidCalculation)
            setIsValidOnOrder(pUpdatedOrders, pOrderIdToOldOrderMap);

        if(!executeUpdateTrigger){
            system.debug('^^^ Exiting BeforeUpdate because executeUpdateTrigger='+executeUpdateTrigger);
            return;
        }
        if(RunCount > 1 && PreventRecursion){
            system.debug('^^^ Exiting BeforeUpdate because RunCount='+RunCount+' and PreventRecursion='+PreventRecursion);
            return;
        }
        System.debug('===Limits.getQueries=Order==Start of before update()====' + Limits.getQueries());
        helper.showKeyEcommData(pUpdatedOrders,'incoming values');



        try{
            system.debug('\n\n\n\n\n--UpdateFlagOnCreateCreditOrder.updadeFlag: ' + UpdateFlagOnCreateCreditOrder.updadeFlag +'\n\n\n\n');
            helper.ResetQueries();
            helper.ordersList = pUpdatedOrders;

            for (Order__c o : pUpdatedOrders){
                //JFreese Appirio 01/26/17 S-452628  Bypass designated validation rules if we are in CR/Rebill Automated handling
                system.debug('Current value of o.Bypass_Validation_Rules__c='+o.Bypass_Validation_Rules__c);
                if(CreditRequestTriggerHandler.CreateOrdersAutomatically != null && CreditRequestTriggerHandler.CreateOrdersAutomatically == true){
                    system.debug('^^^CreditRequestTriggerHandler.CreateOrdersAutomatically=true, so setting Bypass_Validation_Rules__c to true for order '+o.id);
                    o.Bypass_Validation_Rules__c = true;
                }else{
                    system.debug('^^^CreditRequestTriggerHandler.CreateOrdersAutomatically not true, so NOT setting Bypass_Validation_Rules__c to true for order '+o.id);
                }
            }

            helper.validateLineItemAttributeCountry(pUpdatedOrders, pOrderIdToOldOrderMap);

            //if(ExecuteTriggers && IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
            //helper.RejectOrResubmitOrder(pUpdatedOrders, pOrderIdToOldOrderMap); //This statement is commented by Rohit B on 17/Nov/2015 for preventing record type change to 'Rejected'.
            // updateOrderFieldsFromMAPP method callcommented as per I-196991
            /*if(SKIP_Method){
                helper.updateOrderFieldsFromMAPP(pUpdatedOrders,pOrderIdToOldOrderMap);
            }*/
            //integration triggers
            //BizAppsSiteModel.SubmitOrder(pUpdatedOrders, pOrderIdToOldOrderMap);
           // updateAccountSales(pUpdatedOrders, pOrderIdToOldOrderMap);
            populatePaymentDetails(pUpdatedOrders);
            helper.showKeyEcommData(pUpdatedOrders,'after populatePaymentDetails');
            system.debug('Apttus Order Handler Run Count: ' + OrderTriggerHandler.RunCount);
            List<Order__c> orderList = new List<Order__c>();
            List<Order__c> orderListMAPP = new List<Order__c>();
            List<Order__c> orderList1 = new List<Order__c>();
            List<Order__c> lstAgencyOrders = new List<Order__c>();
            list<order__c> verifiedCreditOrdersNeedingOpp = new list<order__c>();  //JFreese Appirio 2/28/17 S-456572
            Id CreditOrderRecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Credit');
            set<id> agecyIds = new set<id>();
            helper.populateEntityId(pUpdatedOrders,pOrderIdToOldOrderMap,pOrderIdToUpdatedOrderMap);
            for(Order__c ord : pUpdatedOrders){
                if(ord.SiteChannelID__c != null || ord.SiteChannelID__c != '' || ord.SiteChannelID__c != pOrderIdToOldOrderMap.get(ord.Id).SiteChannelID__c){
                    orderList.add(ord);
                }
                if(ord.MAPPPrimarySalesRep__c != pOrderIdToOldOrderMap.get(ord.Id).MAPPPrimarySalesRep__c){
                    orderListMAPP.add(ord);
                }
                if(UserInfo.getName() == 'Integration MAPP' && (ord.Account__c != null && pOrderIdToOldOrderMap.get(ord.Id).Account__c != ord.Account__c)){
                    orderList1.add(ord);
                }
                if(ord.agency__c != null && ord.agency__c != pOrderIdToOldOrderMap.get(ord.id).agency__c ){
                    lstAgencyOrders.add(ord);
                    agecyIds.add(ord.agency__c );
                }

                //JFreese Appirio 2/28/17 S-456572
                if(pOrderIdToOldOrderMap.get(ord.Id).OrderStatus__c != 'Verified' && ord.OrderStatus__c == 'Verified'
                   && ord.RecordTypeId == CreditOrderRecordTypeId && ord.Opportunity__c == null){
                       verifiedCreditOrdersNeedingOpp.add(ord);
                }

            }
            if(lstAgencyOrders.size() > 0)
                helper.populatePrimarySalesRepFromAgency(lstAgencyOrders,agecyIds);

            if(!orderList.isEmpty()){
                helper.PopulateAgencyCommission(orderList);
            }
            if(!orderList1.isEmpty()){
                helper.AssignOrderFromMAPP(orderList1);
                helper.AssignOrderTeamMembersFromMAPP(orderList1);
            }

            //JFreese Appirio 2/28/17 S-456572 Need to this on before update so we can set the opportunity on each order
            if(verifiedCreditOrdersNeedingOpp.size()>0){
                helper.createCreditOpportunity(verifiedCreditOrdersNeedingOpp) ;
            }

            helper.PopulateOrderPrimarySalesRepFromMAPP(orderListMAPP);
            helper.populateBillingAddress(pUpdatedOrders);
            helper.populateSalesChannelAndPaymentDetails(pUpdatedOrders); // I-203384 issue in chatter by Patryk Danowski
            helper.populateAgencyBillingContact(pUpdatedOrders);

            //}
            //System.assert(false,'Before update:'+Limits.getQueries());
            validateEditPermission(pOrderIdToOldOrderMap, pOrderIdToUpdatedOrderMap);

            /** Changes Start by appiro**/
            //helper.populateBillcontactAndBillingAccount(pUpdatedOrders);

            Set<Id> setProposalIds = new Set<Id>();
            List<Order__c> lstOrdersToBeUpdated = new List<Order__c> ();
            for(Order__c o : pUpdatedOrders){
                if(pOrderIdToUpdatedOrderMap.get(o.id).QuoteProposal__c != null &&
                   (pOrderIdToOldOrderMap.get(o.id).QuoteProposal__c !=  pOrderIdToUpdatedOrderMap.get(o.id).QuoteProposal__c)){
                       setProposalIds.add(o.QuoteProposal__c);
                       lstOrdersToBeUpdated.add(o);
                   }
                   system.debug('+++'+pOrderIdToUpdatedOrderMap.get(o.id).QuoteProposal__c + '==='+pOrderIdToOldOrderMap.get(o.id).QuoteProposal__c);
                if(pOrderIdToUpdatedOrderMap.get(o.id).QuoteProposal__c == null && pOrderIdToOldOrderMap.get(o.id).QuoteProposal__c != Null){
                    o.Agency_Billing_City__c =  '';
                    o.Agency_Billing_City_State__c = '';
                    o.Agency_Billing_City_State_Zip__c = '';
                    o.Agency_Billing_Country__c = '';
                    o.Agency_Billing_State_Province__c = '';
                    o.Agency_Billing_Street_Address__c = '';
                    o.Agency_Billing_Zip__c = '';
                    o.AgencyCommission__c = 0;
                    o.Agency_commission_Approval__c = False;
                    o.Agency_Discount_Amount__c = 0;
                    o.Local_Agency_Address__c = '';
                    o.Local_Agency_Cust__c = '';
                }
            }

            if(lstOrdersToBeUpdated.size()>0)
                updateOrdersFormulaFields(setProposalIds , lstOrdersToBeUpdated);
            /** Changes end by appiro**/
            // Set IsValid field on Order
            setIsValidOnOrder(pUpdatedOrders, pOrderIdToOldOrderMap);
            helper.populateBillingAddressandContact(pUpdatedOrders, pOrderIdToOldOrderMap);
            // I-213332
            helper.contactPhoneValidationsOnOrder(pUpdatedOrders,pOrderIdToOldOrderMap);
            helper.updateBillingContactName(pUpdatedOrders, pOrderIdToOldOrderMap);
            helper.ValidateOwnerSalesChannel(pUpdatedOrders, pOrderIdToOldOrderMap);
            helper.setFinanceOrderTypeAndSequence(pUpdatedOrders, pOrderIdToOldOrderMap);
            // I-226539 >> Set Negated order when EcomScreeningCheckbox is setting as true
            helper.SetNegatedOrderOnEcomScreeningCheckbox(pUpdatedOrders, pOrderIdToOldOrderMap);
            helper.setOrderOrganization(pUpdatedOrders); //SBerron - S-456389 - 05/08/17
            System.debug('===Order Before Update Queries===' + Limits.getQueries());

        }
        /*JFreese Appirio 5/11/17 S-483688 commenting this as it is not clear what it does (a try with two catches?)
        catch(BaseApplicationException bae){
            throw bae;
        }*/
        catch(Exception ex){
            //JFreese Appirio 5/11/17 S-483688 if called by OnlineFlowProcess we want the full exception
            if(!system.isQueueable() && !system.isFuture()){
                throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
            }else throw ex;
        }
    }

    public void insertEarliestProductStartDate(Order__c[] pUpdatedOrders, map<ID, Order__c> pOrderIdToOldOrderMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','insertEarliestProductStartDate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        Id EcommOrderRecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Ecomm');
        List<Order_Line_Item__c> pUpdatedOrderLineItem = new List<Order_Line_Item__c>();
        set<Id> updatedOrderId = new set<Id>();
        map<Date, List<Order_Line_Item__c>> populateDateInOrderLineItem = new map<Date, List<Order_Line_Item__c>>();
        map<Id, Date> mapOrderStartDate = new map<Id, Date>();
        List<Order_Line_Item__c> uOLIwithProductStartDate = new List<Order_Line_Item__c>();
        Date currentForLoopDate;
        map<Id, List<Order_Line_Item__c>> orderAndLineItems = new map<Id, List<Order_Line_Item__c>>();
        for(Order__c ord : pUpdatedOrders){
            system.debug('ord.OrderStatus__c ' + ord.OrderStatus__c);
            //system.debug('Old map Order Status ' + pOrderIdToOldOrderMap.get(ord.Id).OrderStatus__c);
            if(((pOrderIdToOldOrderMap == null || ord.OrderStatus__c != pOrderIdToOldOrderMap.get(ord.Id).OrderStatus__c) &&
                    (ord.OrderStatus__c == 'Verified' || ord.OrderStatus__c == 'Resubmitted' ||ord.OrderStatus__c == 'Negated' ||
                     ord.OrderStatus__c == 'Paid in Full' ||ord.OrderStatus__c == 'Invoiced' ||ord.OrderStatus__c == 'Closed'))
                ||
                //J Freese Appirio 4/19/16 I-212312
                (ord.RecordTypeId == EcommOrderRecordTypeId && ord.OrderStatus__c == 'Paid in Full' &&
                 pOrderIdToOldOrderMap.get(ord.Id).Payment_Details__c == null && ord.Payment_Details__c != null)
            ){
                updatedOrderId.add(ord.Id);
            }
        }
        system.debug('updatedOrderId=' + updatedOrderId);
        // // Sberron - 1/06 - commented as .01 story breaking on prod
        if(updatedOrderId.size() > 0){  // Added by Shyam to minimize SOQL
            for(Order_Line_Item__c  lineItem: [SELECT Id,Order__c,StartDate__c,Earliest_Product_Start_Date__c, NetTotalAmount__c FROM Order_Line_Item__c WHERE order__c IN :updatedOrderId
                                                order by StartDate__c asc limit 10000]){
                lineItem.Earliest_Product_Start_Date__c = lineItem.StartDate__c;
                if(!orderAndLineItems.keySet().contains(lineItem.Order__c)){
                    orderAndLineItems.put(lineItem.Order__c, new List<Order_Line_Item__c>());
                }
                orderAndLineItems.get(lineItem.Order__c).add(lineItem);
            }
        }


        for(Id ordId : orderAndLineItems.Keyset()){
            List<Order_Line_Item__c> ordLIs = orderAndLineItems.get(ordId);
             system.debug('ordLIs'+ordLIs);
            for(Order_Line_Item__c li : ordLIs){
                if(li.NetTotalAmount__c > 0){
                    if(populateDateInOrderLineItem.keySet().size() == 0){
                        populateDateInOrderLineItem.put(li.Earliest_Product_Start_Date__c, new List<Order_Line_Item__c>{li});
                        currentForLoopDate = li.Earliest_Product_Start_Date__c;
                        mapOrderStartDate.put(li.Order__c,currentForLoopDate);
                        continue;
                    }

                    if(li.Earliest_Product_Start_Date__c > currentForLoopDate.addDays(364)){
                        populateDateInOrderLineItem.put(li.Earliest_Product_Start_Date__c, new List<Order_Line_Item__c>{li});
                        //populateDateInOrderLineItem.get(currentForLoopDate).add(li);
                        currentForLoopDate = li.Earliest_Product_Start_Date__c;
                    } else{
                        populateDateInOrderLineItem.get(currentForLoopDate).add(li);
                    }
                }
            }
        }

        system.debug('@@@Date' + mapOrderStartDate);

        for(Date dt : populateDateInOrderLineItem.keySet()){
            List<Order_Line_Item__c> ordLIs = populateDateInOrderLineItem.get(dt);
            for(Order_Line_Item__c li : ordLIs){
                li.Earliest_Product_Start_Date__c = dt;
                uOLIwithProductStartDate.add(li);
            }
        }

        for(Id ordId : orderAndLineItems.Keyset()){
            List<Order_Line_Item__c> ordLIs = orderAndLineItems.get(ordId);
            for(Order_Line_Item__c li : ordLIs){
                system.debug('@@@Net' + li.NetTotalAmount__c);
                if(li.NetTotalAmount__c <= 0 && mapOrderStartDate.containsKey(li.Order__c)){
                    li.Earliest_Product_Start_Date__c = mapOrderStartDate.get(li.Order__c);
                    system.debug('@@@NetAdd' + li.Id);
                    uOLIwithProductStartDate.add(li);
                }
            }
        }

        if(uOLIwithProductStartDate.size() > 0){
            system.debug('^^^Updating uOLIwithProductStartDate='+uOLIwithProductStartDate);
            Database.update(uOLIwithProductStartDate);
        }


    }

    public void OnAfterUpdate(Order__c[] pOldOrders, Order__c[] pUpdatedOrders, map<ID, Order__c> pOrderIdToOldOrderMap, map<ID, Order__c> pOrderIdToUpdatedOrderMap){
        if (Personal_Settings__c.getInstance().Trigger_Order__c ==false){
            return; // If triggers are off, then exit the method
        }

        //Commented by Mitali (Appirio) 21/4/17 for S-477615 as the same has now been fixed in CreditRequestTriggerHelper
        // Updated by Prashant Gupta Appirio 19/4/17 for S-481535 to bypass the 101 SOQL Error
        /*for(Order__c o : pUpdatedOrders){
            if(o.Count_of_Appoved_Credit_Requests__c != pOrderIdToOldOrderMap.get(o.id).Count_of_Appoved_Credit_Requests__c)
            {
                return;
            }
        } */
        //End

        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        system.debug('**** RunCount='+RunCount+', IncreaseRunCount='+IncreaseRunCount+', PreventRecursion='+PreventRecursion+', CreatingCreditOpportunity='+CreatingCreditOpportunity);
        for (Order__c o : pUpdatedOrders){
            system.debug('^^^ ID='+o.Id+', OrderStatus__c=' + o.OrderStatus__c + ', old OrderStatus__c=' + pOrderIdToOldOrderMap.get(o.Id).OrderStatus__c);
        }
        // Sberron 1/06 - commented as moving method broke a .01 story on prod
        //I-227753
        if(ForceOpportunityUpdates){
            updateRelatedOpportunityStage(pUpdatedOrders, pOrderIdToOldOrderMap);
            system.debug('call1');
        }

        /* Commented by Shyam 3/6/17 S-459475
        if(OrderTriggerHandler.RunCount > 1 && PreventRecursion && !Test.isrunningTest()){
            system.debug('^^^ Exiting AfterUpdate because RunCount='+RunCount+' and PreventRecursion='+PreventRecursion+' and Test.isrunningTest()='+Test.isrunningTest());
            return;
        }
        if(!executeUpdateTrigger){
            system.debug('^^^ Exiting AfterUpdate because executeUpdateTrigger='+executeUpdateTrigger);
            return;
        }
        if(UserInfo.getName() == 'Integration MAPP'){
            for(Order__c o : poldOrders){
                System.debug('^^^ old Order__c ' + o);
            }
            for(Order__c o : pUpdatedOrders){
                System.debug('^^^ updated Order__c ' + o);
            }
        }
        */

        System.debug('===Limits.getQueries=Order==Start of after update()====' + Limits.getQueries());
        system.debug('\n\n\n\n\n--UpdateFlagOnCreateCreditOrder.updadeFlag: ' + UpdateFlagOnCreateCreditOrder.updadeFlag +'\n\n\n\n');
        // Commented by Shyam 1/23 - S-459475
        // if(ExecuteTriggers && IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
        // Added by Shyam 3/6/17 - S-459475

        //system.assert(false,'<<OrderTriggerHandler.RunCount>>' + OrderTriggerHandler.RunCount + '<<PreventRecursion>>' + PreventRecursion + '<<executeUpdateTrigger>>' + executeUpdateTrigger + '<<Test.isrunningTest()>>'+Test.isrunningTest());
        if(!(OrderTriggerHandler.RunCount > 1 && PreventRecursion && !Test.isrunningTest())){
            if(executeUpdateTrigger && ExecuteTriggers && IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                //Reset the queries and reset the ordersList - this is needed for consolidating queries
                helper.ResetQueries();
                helper.ordersList = pUpdatedOrders;

                helper.updateOppRollUps(pUpdatedOrders);
                //updateOrderTeam(pOrderIdToUpdatedOrderMap,pOrderIdToOldOrderMap);
                System.debug('===Order After Update Queries===updateOrderTeam===' + Limits.getQueries());
                if(UserInfo.getName() != 'Integration MAPP'){
                    helper.updateCustomerNumberofAccounts(pUpdatedOrders, pOrderIdToOldOrderMap);//S-445792
                }
                //JFreese disabled 10/20/16 per Chris Snow
                //helper.updateCustumerNumberofAccounts(pUpdatedOrders, pOrderIdToOldOrderMap);
                if(UserInfo.getName() != 'Integration MAPP'){// Change by Gaurav Gupta on 12-Jan-2017 for S-460212
                    helper.createCaseForVerifiedOrders(pUpdatedOrders, pOrderIdToOldOrderMap);
                }
                helper.setOpportunityApprovalstatusToRejected(pUpdatedOrders, pOrderIdToOldOrderMap);
                helper.ComputeRemainingCreditAmountOfParentOrder(pOrderIdToUpdatedOrderMap);
                helper.ReopenQuoteWhenOrderIsRejected(pUpdatedOrders, pOrderIdToOldOrderMap);
                helper.OpptyWriteBack(pUpdatedOrders, pOrderIdToOldOrderMap);//added by Deepanshu for S-452704
                System.debug('===Order After Update Queries===ReopenQuoteWhenOrderIsRejected===' + Limits.getQueries());
                System.debug('call paid in full');
                BizAppsSiteModel.autoTriggerVerification(pOrderIdToOldOrderMap,pOrderIdToUpdatedOrderMap);
                //Debugging code added by Jeff per SFDC request
                //Integer futureTest = [SELECT COUNT() FROM AsyncApexJob WHERE ApexClass.Name = 'BizAppsSiteModel' AND MethodName = 'VerifyOrder' AND JobType = 'Future' AND Status IN ('Queued', 'Processing', 'Preparing')];
                //system.assert(futureTest != 0);
                //AP S-328699 - nonmessaging part
                /*List<Order__c> Orderlist = [Select Id, Name,DoNotMsgBtnFlg__c from Order__c where Id in:pUpdatedOrders];
                List<Order_Line_Item__c> ordlnList = [select Id,Name from Order_Line_Item__c where Order__c in:Orderlist] ;
                system.debug('ordlnList' + ordlnList);
                List<Line_Item_Attribute__c> lineItemList = [select DoNotMessage__c from Line_Item_Attribute__c where Order_Line_Item__c in:ordlnList];
                //Jeff L - updated this logic to a Set of orders - with iterating over line items, we can get duplicate orders in a list, which causes a DML exception
                //when perfoming an update later on. So we create a set first - than turn it into a list later
                Set<Order__c> orderSet = new Set<Order__c>();
                system.debug('lineItemList' + lineItemList);
                for(Line_Item_Attribute__c lia : lineItemList){
                    system.debug('DoNotMessage' + lia.DoNotMessage__c);
                    for(Order__c orderLn : Orderlist){
                        orderLn.DoNotMsgBtnFlg__c = lia.DoNotMessage__c;
                        system.debug('DoNotMsgBtnFlg' + orderLn.DoNotMsgBtnFlg__c);
                        orderSet.add(orderLn);
                        system.debug('FirstOrderLists' +  orderSet);
                    }
                    if(lia.DoNotMessage__c  == 'No'){
                        system.debug('SecondDoNotMessage' + lia.DoNotMessage__c);
                        //SendOrderToSite(pOrderId);
                        BizAppsSiteModel.autoTriggerVerification(pOrderIdToOldOrderMap,pOrderIdToUpdatedOrderMap);
                    }
                }
                if(orderSet.size() > 0 ){
                    List<Order__c> ordersToUpdate = new List<Order__c>(orderSet);
                    update ordersToUpdate;
                }*///AP S-328699 - nonmessaging part commented out as the 4 non messaging products are not being migrated to Salesforce.
                //helper.EarliestProductStartDate(pUpdatedOrders, pOrderIdToOldOrderMap);//commented out for now due to SOQL exceptions

                //Prevent Recursion for creating Assets
                if(OrderTriggerHandler.RunCount == 1){
                    helper.createAssetsQuoteonOrderStatus(pUpdatedOrders, pOrderIdToOldOrderMap);
                }
                // helper.SendToVerificationCreditAndRebillOrder2(pUpdatedOrders, pOrderIdToOldOrderMap);

                //This method can update Orders, setting OrderTriggerHandler.RunCount to 2,
                //preventing run of createAssetsQuoteonOrderStatus, thus preventing asset creation
                //upsertQuotaType(pUpdatedOrders, pOrderIdToOldOrderMap);

                system.debug('Onafter done.');
                System.debug('===Order After Update Queries===Onafter done===' + Limits.getQueries());
                Set<id> setOrdersToUpdateLineItemsSalesCredit = new Set<id>();


                list<order__c> lstVerfiedOrders = new list<order__c>();
                Map<ID,RecordType> rt_Map = New Map<ID,RecordType>([Select ID, Name From RecordType Where sObjectType = 'Order__c']);
                Set<id> setVerifiedOrdersParentId = new Set<id>();
                Set<id> setVerifiedOrdersCreditRequests= new Set<id>();
                Id EcommOrderRecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Ecomm');
                 list<order__c> lstCreditOrders = new list<order__c>();
                for(Order__c ord : pUpdatedOrders){
                    if((pOrderIdToOldOrderMap.get(ord.Id).OrderStatus__c != ord.OrderStatus__c) &&
                       pOrderIdToOldOrderMap.get(ord.Id).OrderStatus__c != 'Resubmitted' &&
                       pOrderIdToOldOrderMap.get(ord.Id).OrderStatus__c != 'Negated' &&
                       pOrderIdToOldOrderMap.get(ord.Id).OrderStatus__c != 'Verified' &&
                       pOrderIdToOldOrderMap.get(ord.Id).OrderStatus__c != 'Paid in Full' &&
                       pOrderIdToOldOrderMap.get(ord.Id).OrderStatus__c != 'Invoiced' &&
                       pOrderIdToOldOrderMap.get(ord.Id).OrderStatus__c != 'Closed' &&
                       (ord.OrderStatus__c == 'Resubmitted' ||
                        ord.OrderStatus__c == 'Negated' ||
                        ord.OrderStatus__c == 'Verified' ||
                        ord.OrderStatus__c == 'Paid in Full' ||
                        ord.OrderStatus__c == 'Invoiced' ||
                        ord.OrderStatus__c == 'Closed' )
                        ||
                        //J Freese Appirio 4/19/16 I-212312
                        (ord.RecordTypeId == EcommOrderRecordTypeId && ord.OrderStatus__c == 'Paid in Full' &&
                         pOrderIdToOldOrderMap.get(ord.Id).Payment_Details__c == null && ord.Payment_Details__c != null)
                        ){
                            setOrdersToUpdateLineItemsSalesCredit.add(ord.id);
                        }
                    if(pOrderIdToOldOrderMap.get(ord.Id).OrderStatus__c != 'Verified' && ord.OrderStatus__c == 'Verified'
                       && rt_map.get(ord.RecordTypeId).name.containsIgnoreCase('Credit')){
                           lstVerfiedOrders.add(ord);
                           setVerifiedOrdersParentId.add(ord.ParentOrder__c);
                           setVerifiedOrdersCreditRequests.add(ord.CreditRequest__c);
                       }
                    //I-225358
                    if((pOrderIdToOldOrderMap.get(ord.Id).OrderStatus__c != ord.OrderStatus__c) &&
                        (ord.OrderStatus__c == 'Negated' || ord.OrderStatus__c == 'Rejected') &&
                        (rt_map.get(ord.RecordTypeId).Name == 'Credit' || rt_map.get(ord.RecordTypeId).Name == 'Rebill Order')){
                       lstCreditOrders.add(ord);
                    }

                }

                if(lstCreditOrders.size() >0){
                    helper.creditOrderSetGrossNetTotal(lstCreditOrders) ;

                }

                System.debug('^^^ setOrdersToUpdateLineItemsSalesCredit=' + setOrdersToUpdateLineItemsSalesCredit);
                if(setOrdersToUpdateLineItemsSalesCredit.size() > 0){
                    populateOrderLineItemsSalesCredit(setOrdersToUpdateLineItemsSalesCredit);
                }

                if(!lstVerfiedOrders.isEmpty())
                    decrementCreditAmount(lstVerfiedOrders , setVerifiedOrdersParentId , setVerifiedOrdersCreditRequests);

                // Added by Vivek Ojha for T-434699
                //Commented out by JFreese for I-200464; replaced by OrderLineItemTriggerHelper.syncLineItemsWithOpportunityLineItems()
                //updateOpportunityAmount(pUpdatedOrders);

                //T-445611 Keep currency in sync between order and order line item
                syncCurrencyType(pUpdatedOrders,pOrderIdToUpdatedOrderMap);
                pouplateProductHierarchyFields(pUpdatedOrders, pOrderIdToOldOrderMap);
                // when status changes for order, populate the earlist product start date.
                // Commented by Shyam 1/23 - S-459475
                // insertEarliestProductStartDate(pUpdatedOrders, pOrderIdToOldOrderMap); // Commented on 1/31 Shyam

                // As per issue I-187441
                //if(UserInfo.getName() == 'Integration MAPP') {
                updateRelatedOpportunityStage(pUpdatedOrders, pOrderIdToOldOrderMap);
                helper.BulkFullCreditLoadProcess(pUpdatedOrders, pOrderIdToOldOrderMap);
                //}
                //System.assert(false,'After update:'+Limits.getQueries());
                System.debug('===Limits.getQueries=Order==End of after update()====' + Limits.getQueries());


                // Added by Vikas Menon on 22 Feb 2017, (for S-445863)
                helper.updateNonMsgQtyonCreditOrderVerifiedNegated(pUpdatedOrders, pOrderIdToOldOrderMap);
                // Commented as story is in progress, Added by Vikas Menon on 8 March (for S-462334 - In Progress)
                helper.createOrderTeamForOpportunitySalesCreditSplit(pUpdatedOrders, pOrderIdToOldOrderMap);
            }
        }
        // Shyam 1/23 : S-459475
        // when status changes for order, populate the earlist product start date.
        if(!Test.isrunningTest()){
            insertEarliestProductStartDate(pUpdatedOrders, pOrderIdToOldOrderMap);
        }
    }


    /*
    ** @author : Cloud Sherpas Inc.
    ** @date : 03/07/2014
    ** @description :  this method handles the 'after insert' event for the trigger; it's purpose is to ...
    ** @paramaters : an array of Contact objects
    ** @returns : nothing
    */
    public void OnAfterDelete(Order__c[] pOldOrders){
        if (Personal_Settings__c.getInstance().Trigger_Order__c ==false){
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnbeforeDelete');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        try{
            if(ExecuteTriggers && IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){

                helper.CountallRecords(pOldOrders);
            }
        }
        catch(BaseApplicationException bae){
            throw bae;
        }
        catch(Exception ex){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }
    }

    /*
    ** @author : Appirio, Inc.
    ** @date : 08/09/2015
    ** @story :
    ** @element :
    ** @description : Decrement Credit Amount
    ** @paramaters : List of Orders
    ** @returns : nothing
    */
    private void decrementCreditAmount(List<order__c> lstVerfiedOrders , Set<id> setVerifiedOrdersParentId , Set<id> setVerifiedOrdersCreditRequests){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','decrementCreditAmount');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        List<CreditRequestLineItem__c> CRLIList = [SELECT Id, Credit_Request__c, CreditType__c,
                                                   (SELECT Id, Name, LicenseID__r.SiteLicenseID__c,  CreditQuantity__c
                                                    FROM Credit_Request_License_IDs__r),
                                                   AvailableCreditAmount__c,
                                                   TaxAmount__c,
                                                   ProductName__c,
                                                   CreditAmount__c,
                                                   Xcode__c,
                                                   Quantity__c,
                                                   AgencyCommission__c,
                                                   NetCreditAmount__c,
                                                   NetRemainingCreditAmount__c,
                                                   Order_Line_Item__c ,
                                                   Order_Line_Item__r.Legacy_Karma_PartNum__c  ,
                                                   Credit_Request__r.CreditReason__c
                                                   FROM CreditRequestLineItem__c
                                                   WHERE Credit_Request__c =: setVerifiedOrdersCreditRequests];

        map<Id,Decimal> AmountToCreditOnGRCAMap = new map<Id,Decimal>();
        map<Id,Decimal> AmountToCreditOnNRCAMap = new map<Id,Decimal>();

        for(CreditRequestLineItem__c cr : CRLIList){

            if(cr.Credit_Request__r.CreditReason__c== 'Tax Error'){//To accommodate Tax crediting
                AmountToCreditOnGRCAMap.put(cr.Order_Line_Item__c, cr.TaxAmount__c);
                AmountToCreditOnNRCAMap.put(cr.Order_Line_Item__c, cr.TaxAmount__c);
            }else{
                AmountToCreditOnGRCAMap.put(cr.Order_Line_Item__c, cr.CreditAmount__c);
                AmountToCreditOnNRCAMap.put(cr.Order_Line_Item__c, cr.NetCreditAmount__c);
            }
            system.debug('\n\n\n\n +++AmountToCreditOnNRCAMap: '+ AmountToCreditOnNRCAMap +'\nAmountToCreditOnGRCAMap: '+ AmountToCreditOnGRCAMap +'\n\n\n\n');


        }

        list<Order_Line_Item__c> oliname = [SELECT Id,GrossRemainingCreditAmount__c,
                                            NetRemainingCreditAmount__c
                                            FROM Order_Line_Item__c WHERE Order__c IN : setVerifiedOrdersParentId   ];


        list<Order_Line_Item__c> OLIToBeUpdated = new list<Order_Line_Item__c>();
        for(Order_Line_Item__c oli: [SELECT Id,GrossRemainingCreditAmount__c,
                                     NetRemainingCreditAmount__c
                                     FROM Order_Line_Item__c WHERE Order__c IN : setVerifiedOrdersParentId]){
             Boolean updateOLI = false;
             //system.debug('\n\n\n\n ---Id: '+oli.Id+'\nAmountToCreditOnNRCAMap.get(oli.Id): '+ AmountToCreditOnNRCAMap.get(oli.Id) +'\nAmountToCreditOnGRCAMap.get(oli.Id): '+ AmountToCreditOnGRCAMap.get(oli.Id) +'\n oli.oli.GrossRemainingCreditAmount__c: '+oli.GrossRemainingCreditAmount__c+'\noli.NetRemainingCreditAmount__c: '+oli.NetRemainingCreditAmount__c+'\n\n\n\n\n');
             //AS Jan26 2017 S-452779 - fixing using Round() -
             /*JFreese Appirio 2/22/17 S-470675
               AS made some changes in S-452779 to use the round() function, but they were commented out when S-452779 was deployed
               They are not correct anyway, because they would round the two values to the nearest dollar before subtracting.
               Instead, subtract the values and then round to the nearest cent.
               Note that these errors happen when (e.g.) the Parent OLI NetRemainingCreditAmount__c is lower than the
               CreditRequestLineItem__c.NetCreditAmount__c by a very small amount, like 0.0004 dollars.  DK how this comes to be,
               but if the difference is less than 1 cent it should resolve to zero, and now does.*/
             if(AmountToCreditOnNRCAMap.containsKey(oli.Id) && AmountToCreditOnGRCAMap.containsKey(oli.Id)){
                if(AmountToCreditOnNRCAMap.get(oli.Id) != null && oli.NetRemainingCreditAmount__c != null){
                    Decimal nrca = (oli.NetRemainingCreditAmount__c - AmountToCreditOnNRCAMap.get(oli.Id)).setScale(2);
                    system.debug('^^^oli '+oli.Id+' NetRemainingCreditAmount__c='+oli.NetRemainingCreditAmount__c+', AmountToCreditOnNRCAMap='+AmountToCreditOnNRCAMap.get(oli.Id)+', updated NetRemainingCreditAmount__c='+nrca);
                    oli.NetRemainingCreditAmount__c = nrca;
                    updateOLI = true;
                }
                if(AmountToCreditOnGRCAMap.get(oli.Id) != null && oli.GrossRemainingCreditAmount__c != null){
                    Decimal ngca =(oli.GrossRemainingCreditAmount__c - AmountToCreditOnGRCAMap.get(oli.Id)).setScale(2);
                    system.debug('^^^oli '+oli.Id+' GrossRemainingCreditAmount__c='+oli.GrossRemainingCreditAmount__c+', AmountToCreditOnGRCAMap='+AmountToCreditOnGRCAMap.get(oli.Id)+', updated GrossRemainingCreditAmount__c='+ngca);
                    oli.GrossRemainingCreditAmount__c = ngca;
                    updateOLI = true;
                }
                if(updateOLI == true){
                    OLIToBeUpdated.add(oli);
                }
            }
        }

        if(!OLIToBeUpdated.isEmpty()){
            update OLIToBeUpdated;
        }
    }

    /*
    ** @author : Appirio, Inc.
    ** @date : 08/27/2015
    ** @story : S-323692
    ** @element : T-420926
    ** @description : Sales Credit Calculation
    ** @paramaters : List of Orders
    ** @returns : nothing
    */
    private void populateOrderLineItemsSalesCredit(Set<Id> pOrders){
    final string METHODNAME = CLASSNAME.replace('METHODNAME','populateOrderLineItemsSalesCredit');
    system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        List<Order_Line_Item__c> lstOrderLineItems = [Select Id, Product__r.APTPS_Rev_Share_Type__c ,
                                                      Product__r.APTPS_Rev_Share__c ,
                                                      NetTotalAmount__c ,
                                                      GrossTotalAmount__c ,
                                                      Line_Item_Net_Total__c ,
                                                      Quantity2__c, prod_code__c,
                                                      LineType__c
                                                      From Order_Line_Item__c
                                                      Where Order__c IN :pOrders];

        For(Order_Line_Item__c oLI : lstOrderLineItems ){
            //We want to skip all this logic if this is a line item is the bundle header
            system.debug('OLI details? ' + oLI.prod_code__c + ' ' + oLI.LineType__c + ' ' + oLI.Id);
            if(oLI.prod_code__c != null && oLI.LineType__c != null){
                if(oLI.prod_code__c.equalsIgnoreCase('QUOTE BUNDLE') && oLI.LineType__c.equalsIgnoreCase('Product/Service')){
                    continue;
                }
            }

            Decimal quantity = oLI.Quantity2__c == null ? 0 : oLI.Quantity2__c;
            Double netTotalAmount = oLI.NetTotalAmount__c == null ? 0 : oLI.NetTotalAmount__c;
            if(oLI.Product__r != null && oLI.Product__r.APTPS_Rev_Share_Type__c == 'Gross' && oLI.NetTotalAmount__c != null
                                            && oLI.GrossTotalAmount__c != null && oLI.Product__r.APTPS_Rev_Share__c !=  null) {
                oLI.Sales_Credit__c = oLI.NetTotalAmount__c - (oLI.GrossTotalAmount__c * (oLI.Product__r.APTPS_Rev_Share__c/100));
             }
            else If(oLI.Product__r != null && oLI.Product__r.APTPS_Rev_Share_Type__c == 'Net' && oLI.NetTotalAmount__c != null
                                                    && oLI.NetTotalAmount__c != null && oLI.Product__r.APTPS_Rev_Share__c != null) {
                oLI.Sales_Credit__c = oLI.NetTotalAmount__c - (oLI.NetTotalAmount__c * (oLI.Product__r.APTPS_Rev_Share__c/100));
            }
            else
                oLI.Sales_Credit__c = /*oLI.Line_Item_Net_Total__c*/ oLI.NetTotalAmount__c  ;
        }
        if(lstOrderLineItems != null && lstOrderLineItems.size() >0 )
            Update   lstOrderLineItems ;
    }


    //I-175553
    private void validateEditPermission(map<ID, Order__c> pOrderIdToOldOrderMap, map<ID, Order__c> pOrderIdToUpdatedOrderMap){
    final string METHODNAME = CLASSNAME.replace('METHODNAME','validateEditPermission');
    system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));


        Map<String, Schema.SObjectField> M = Schema.SObjectType.Order__c.fields.getMap();
        If(PermissionCheck.hasPermission('Can_only_upload_attachments_on_Orders')) {
            for(Order__c o : pOrderIdToUpdatedOrderMap.values()) {
                //Sberron - S-484218 - 05/11/17
                //Recalculation of Count_of_Approved_Credit_Requests__c rollup on the final approval submit was causing an update of the parent
                //order, resulting in the below error being displayed for certain users
                if (o.Count_of_Approved_Credit_Requests__c != pOrderIdToOldOrderMap.get(o.Id).Count_of_Approved_Credit_Requests__c) {
                    System.debug('----returning as update was caused by rollup summary Count_of_Approved_Credit_Requests__c recalculation');
                    return;
                }
                boolean flag = false;
                for (String str : M.keyset()) {
                    if(o.get(str) != pOrderIdToOldOrderMap.get(o.Id).get(str) && str != 'isValid__c'){
                        flag = true;
                    }
                }
                if(flag){

                    o.addError('You only have permission to upload attachments to this order or change the Is Valid status.');
                }
            }
        }
    }



    // Still Working

    /*
    ** @author : Appirio, Inc.
    ** @date : 17/06/2015
    ** @story : S-319051
    ** @element : I-168557
    ** @description : populate Payment Details
    ** @paramaters : List of Orders
    ** @returns : nothing
    */
    private void populatePaymentDetails(Order__c[] pOrders){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populatePaymentDetails');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            set<Id> AccountId = new Set<Id>();
            set<Id> proposalId = new Set<Id>();
            for(Order__c ord: pOrders){
                AccountId.add(ord.Account__c);
                proposalId.add(ord.QuoteProposal__c);
            }

            Map<Id, Contact> ContactDetails = new Map<Id, Contact>();
            if(!AccountId.isEmpty()){
                // Collecting contact for InvoiceDeliveryMethod field
                for(Contact con: [Select Id,InvoiceDeliveryMethod__c,Account.id From Contact WHERE AccountId IN: AccountId]){
                    if(con.AccountId != null){
                        ContactDetails.put(con.AccountId,con);
                    }
                }
            }
            system.debug('***ContactDetails***' + ContactDetails);
            Map<Id,Apttus_Proposal__Proposal__c> proposalMap = new Map<Id,Apttus_Proposal__Proposal__c>([select id,Latest_End_Date__c , Earliest_Start_Date__c from Apttus_Proposal__Proposal__c where id in :proposalId]);

            //Jeff L added this as part of I-199373, we were querying inside of a for loop previously
            Map<String,Payment_Details__c> paymentDetailsMap = getPaymentDetails(pOrders);
            System.debug('----paymentDetailsMap ' + paymentDetailsMap);

            for(Order__c ord: pOrders){
                if(ContactDetails.containsKey(ord.Account__c)){
                    ord.Invoice_Delivery_Method_text__c = ContactDetails.get(ord.Account__c).InvoiceDeliveryMethod__c;

                }

                /*I-178453 JFreese Appirio 8/31/15 */
                system.debug('query Details ' + ord.Payment_Method_text__c + ' ' + ord.Payment_Frequency__c + ' ' + ord.Payment_Term_text__c + ' ' +ord.AccountOrganization__c);
                //system.debug('paymentDetail::'+paymentDetailsMap);
                if (ord.Payment_Method_text__c != null && ord.Payment_Frequency__c != null &&
                ord.Payment_Term_text__c != null){
                    //SBerron - S-443651 - need to change to Organization__c
                    String key = (ord.Payment_Method_text__c+ord.Payment_Frequency__c+ord.Payment_Term_text__c+ord.Organization__c).toLowerCase();
                    system.debug('keytest ' + key);
                    Payment_Details__c paymentDetail = paymentDetailsMap.get(key);
                    system.debug('paymentDetail::'+paymentDetail);
                    if(paymentDetail!=null){
                        ord.Payment_Details__c = paymentDetail.Id;
                        if(proposalMap.containsKey(ord.QuoteProposal__c) && paymentDetail.Installment_Flag__c && paymentDetail.True_Term__c >0){
                            Apttus_Proposal__Proposal__c prop = proposalMap.get(ord.QuoteProposal__c);
                            system.debug('prop::'+prop);
                            if(prop.Earliest_Start_Date__c != null && prop.Latest_End_Date__c != null && paymentDetail.True_Term__c != null )
                            ord.Installments__c = Math.floor(prop.Earliest_Start_Date__c.daysBetween( prop.Latest_End_Date__c)/paymentDetail.True_Term__c);
                            system.debug('ord.Installments__c::'+ord.Installments__c);
                        }else if (paymentDetail.PaymentFrequency__c == 'Single Payment'){
                            ord.Installments__c = 1;
                        } else {
                            ord.Installments__c = 0;
                        }

                    }else{
                        if(UserInfo.getName() != 'Integration MAPP')
                        {
                            ord.addError(' No payment details are available');
                        }
                    }
                }else {
                    if(UserInfo.getName() != 'Integration MAPP' && ord.QuoteProposal__c != null)
                    {
                        ord.addError(' No Payment Details are available on the related Quote/Proposal.');
                    }
                }
            }
        }catch(Exception e){
            ExceptionLog.add('Exception', 'OrderTriggerHelper', 'populatePaymentDetails', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to  populatePaymentDetails.' ,e);
        }

    }

    /*
    ** @author : Appirio, Inc.
    ** @date : 01/21/2016
    ** @story : I-199373
    ** @description : create a Map of payment details related to the passed in orders
    ** @paramaters : List of Orders
    ** @returns : Map of payment details
    */
    private Map<String,Payment_Details__c> getPaymentDetails(List<Order__c> pOrders){
    final string METHODNAME = CLASSNAME.replace('METHODNAME','getPaymentDetails');
    system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        Set<String> methodSet = new Set<String>();
        Set<String> freqSet = new Set<String>();
        Set<String> termSet = new Set<String>();
        Set<String> orgSet = new Set<String>();
        Map<String, Payment_Details__c> returnMap = new Map<String,Payment_Details__c>();

        for(Order__c ord : pOrders){
            if(ord.Payment_Method_text__c != null && ord.Payment_Frequency__c != null && ord.Payment_Term_text__c != null){
                methodSet.add(ord.Payment_Method_text__c);
                freqSet.add(ord.Payment_Frequency__c);
                termset.add(ord.Payment_Term_text__c);
                orgSet.add(ord.Organization__c); //SBerron - S-443651 - need to change to Organization__c
            }
        }

        //Now with those details we wil query and get the total list of matching payment details and put
        //them in a map of method+frequency+term+org as the key
        system.debug('query details: Method ' + methodSet);
        system.debug('query details: Frequecy ' + freqSet);
        system.debug('query details: Term ' + termSet);
        system.debug('query details Org ' + orgSet);
        for(Payment_Details__c payDeets :[SELECT Id, Installment_Flag__c, True_Term__c, PaymentFrequency__c,
                                            PaymentMethod__c, PaymentTerm__c, Organization__c
                                            FROM Payment_Details__c
                                            WHERE PaymentFrequency__c in :freqSet AND
                                                PaymentTerm__c in :termSet AND
                                                PaymentMethod__c in :methodSet AND
                                                Organization__c in :orgSet]){
            String key = payDeets.PaymentMethod__c + payDeets.PaymentFrequency__c + payDeets.PaymentTerm__c + payDeets.Organization__c;
            returnMap.put(key.toLowerCase(),payDeets);
        }
        return returnMap;
    }

    //Jeff L commented out this method out for I-199373
    /*I-178453 JFreese Appirio 8/31/15 copied from ApttusProposalTriggerHandler*/
    /*
    private static Payment_Details__c getPaymentDetailId(String method,String frequency,String term,string organization){
        system.debug(method+frequency+term+organization);
        List<Payment_Details__c> payDetailList = [SELECT Id,Installment_Flag__c,True_Term__c, PaymentFrequency__c
                                                            FROM Payment_Details__c
                                                            WHERE (PaymentFrequency__c =: frequency
                                                                  AND PaymentMethod__c =: method
                                                                  AND PaymentTerm__c =: term
                                                                  AND Organization__c =: organization)
                                                                AND Active__c = true LIMIT 1] ;

        if(payDetailList !=null && !payDetailList.isEmpty()){
            return payDetailList[0];
        }else{
            return null;
        }


    }
    */


    /*
    ** @author : Appirio, Inc. (Gaurav G)
    ** @date : 25/06/2015
    ** @story : S-323592
    ** @element : T-413051
    ** @description : Update the Order Agency fields.
    ** @paramaters : List of Orders
    ** @returns : nothing
    */

    private void updateOrdersFormulaFields (Set<Id> setProposalIds , list<Order__c> lstNewOrders){
    final string METHODNAME = CLASSNAME.replace('METHODNAME','updateOrdersFormulaFields');
    system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        Map<id , Apttus_Proposal__Proposal__c > mapProposals = new Map<id , Apttus_Proposal__Proposal__c >([select Agency_Billing_City__c,
                                                                                                            Agency_Billing_City_State__c ,
                                                                                                            Agency_Billing_City_State_Zip__c ,
                                                                                                            Agency_Billing_Country__c,
                                                                                                            Agency_Billing_State_Province__c,
                                                                                                            Agency_Billing_Street_Address__c,
                                                                                                            Agency_Billing_Zip__c,
                                                                                                            AgencyCommission__c ,
                                                                                                            APTS_Agency_commission_Approval__c,
                                                                                                            Agency_Discount_Amount__c,
                                                                                                            Local_Agency_Address__c,
                                                                                                            Local_Agency_Cust__c
                                                                                                            from Apttus_Proposal__Proposal__c  where id IN :setProposalIds ]) ;


        Apttus_Proposal__Proposal__c proposal ;
        for(Order__c o : lstNewOrders){
            proposal = mapProposals.get(o.QuoteProposal__c);
            o.Agency_Billing_City__c = proposal.Agency_Billing_City__c;
            o.Agency_Billing_City_State__c = proposal.Agency_Billing_City_State__c;
            o.Agency_Billing_City_State_Zip__c = proposal.Agency_Billing_City_State_Zip__c;
            o.Agency_Billing_Country__c = proposal.Agency_Billing_Country__c;
            o.Agency_Billing_State_Province__c = proposal.Agency_Billing_State_Province__c;
            o.Agency_Billing_Street_Address__c = proposal.Agency_Billing_Street_Address__c;
            o.Agency_Billing_Zip__c = proposal.Agency_Billing_Zip__c;
            o.AgencyCommission__c = proposal.AgencyCommission__c;
            o.Agency_commission_Approval__c = proposal.APTS_Agency_commission_Approval__c;
            o.Agency_Discount_Amount__c = proposal.Agency_Discount_Amount__c;
            o.Local_Agency_Address__c = proposal.Local_Agency_Address__c;
            o.Local_Agency_Cust__c = proposal.Local_Agency_Cust__c;

        }

    }

    /*
    ** @author : Appirio, Inc.
    ** @date : 21/07/2015
    ** @story : S-331170
    ** @element : T-420549
    ** @description : Update order trigger to The order should pull the Account Sales Rep's sales channel from the user record when order is closed
    ** @paramaters : List of Orders
    ** @returns : nothing
    */

    /* Commented due to test class coverage fix - Shyam 1/11 - Method not called from anywhere

    private void updateAccountSales(Order__c [] pNewOrders, Map<Id, Order__c> pOldOrdersMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateAccountSales');
        Logger.push(METHODNAME, 'Order__c');


        set<Id> AccountIds = new set<Id>();
        Map<Id,String> Accountsales = new Map<Id,String>();

        for(Order__c ord :  pNewOrders){
            if(ord.Account__c != null && ((ord.OrderStatus__c == 'Verified' ||ord.OrderStatus__c == 'Resubmitted' ||
                                           ord.OrderStatus__c == 'Negated' ||ord.OrderStatus__c == 'Paid in Full' ||ord.OrderStatus__c == 'Invoiced' ||
                                           ord.OrderStatus__c == 'Closed' ) && (pOldOrdersMap.get(ord.Id).OrderStatus__c!=ord.OrderStatus__c ))){
                                               AccountIds.add(ord.Account__c);
                                           }
        }

        system.debug('Check @@@@@@@@@@@@@@@@@@@@@@@@@@@' + AccountIds);

        if(!AccountIds.isEmpty()){
            for(Account acc : [Select id, Owner.PositionSalesChannel__c From Account Where Id IN :AccountIds]){
                Accountsales.put(acc.id,acc.Owner.PositionSalesChannel__c);
            }
        }
        system.debug('Check @@@@@@@@@@@@@@@@@@@@@@@@@@@' + Accountsales);

        for(Order__c ord :  pNewOrders){
            if(Accountsales.containsKey(ord.Account__c) && Accountsales.get(ord.Account__c) != null){
                ord.SalesChannel__c = Accountsales.get(ord.Account__c);
            }
        }
    }
    */


    /*
    ** @author : Appirio, Inc. (Piyush jain)
    ** @date : 23/07/2015
    ** @story : S-323692
    ** @element : T-420858
    ** @description : Update the Order Line Item QuotaType fields.
    ** @paramaters : List of Orders
    ** @returns : nothing
    */
    /* Jeff L Commented this out 4/8/2016 - for I-210601 - all this logic is no longer needed
    private void upsertQuotaType(Order__c [] pNewOrders, Map<Id, Order__c> pOldOrdersMap){
        system.debug('***upsertQuotaType called');
        final string METHODNAME = CLASSNAME.replace('METHODNAME','upsertQuotaType');
        Logger.push(METHODNAME, 'Order__c');


        set<Id> ordsetId = new set<Id>();
        set<Id> prodIds = new set<Id>();
        map<Id,Product2> mapProduct = new map<Id,Product2>();

        list<Order_Line_Item__c> olitoupdate = new list<Order_Line_Item__c>();

        for(Order__c ord :  pNewOrders){
            system.debug('***upsertQuotaType '+ord.OrderStatus__c);
            if(ord.OrderStatus__c == 'Verified' ||ord.OrderStatus__c == 'Resubmitted' ||
               ord.OrderStatus__c == 'Negated' ||ord.OrderStatus__c == 'Paid in Full' ||ord.OrderStatus__c == 'Invoiced' ||
               ord.OrderStatus__c == 'Closed'){
                   ordsetId.add(ord.Id);
               }
        }
        system.debug(' ***upsertQuotaType ordsetId'+ordsetId);

        if(!ordsetId.isEmpty()){
            for(Order_Line_Item__c oli : [Select Id, Product__c, Quota_Type__c , Order__c From Order_Line_Item__c Where Order__c IN :ordsetId]){
                if(oli.Product__c != null){
                    prodIds.add(oli.Product__c);
                }
            }
        } else {
            return;
        }
        system.debug(' ***upsertQuotaType prodIds'+prodIds);

        if(!prodIds.isEmpty()){
            for(Product2 profirst : [Select Id, Quota_Type__c, Product_Type__c from Product2 Where Id IN :prodIds]){
                mapProduct.put(profirst.Id, profirst);
            }
        } else {
            return;
        }
        system.debug(' ***upsertQuotaType mapProduct'+mapProduct);

        if(!ordsetId.isEmpty()){
            system.debug(' ***upsertQuotaType reached if');
            for(Order_Line_Item__c oli : [Select Id, Product__c, Quota_Type__c , Order__c From Order_Line_Item__c Where Order__c IN :ordsetId]){
              //  system.debug('***upsertQuotaType productkey '+mapProduct.get(oli.Product__c).id );
                system.debug('***upsertQuotaType oli productid '+oli.Product__c);
                system.debug('***upsertQuotaType oli Quota_Type__c '+oli.Quota_Type__c);

                if(mapProduct.containsKey(oli.Product__c) && oli.Quota_Type__c == null){
                    system.debug(' ***upsertQuotaType reached inner for loop');
                    oli.Quota_Type__c = mapProduct.get(oli.Product__c).Product_Type__c;
                    if(mapProduct.get(oli.Product__c).Product_Type__c == 'Premium'){
                        oli.Quota_Type__c = 'Strategic' ;
                        olitoupdate.add(oli);
                    }
                    else {
                     oli.Quota_Type__c = 'Core';
                     olitoupdate.add(oli);
                    }
                }
            }
         }
         system.debug(' ***upsertQuotaType olitoupdate'+olitoupdate);
        if(!olitoupdate.isEmpty()) {
            update olitoupdate;
        }

    }
    */

    // T-424791 >> populate isValid field on Order on insert or update

    public  void setIsValidOnOrder(List<Order__c> orderList, map<Id,Order__c> oldOrderMap){
    final string METHODNAME = CLASSNAME.replace('METHODNAME','setIsValidOnOrder');
    system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        set<Id> accIds = new  set<Id>();
        set<Id> userIds = new  set<Id>();
        List<Order__c> orders = new List<Order__c>();
        // 08/19 - T-428189 : Orders having Validity_Overwritten__c = false can set isValid only
        for(Order__c order : orderList){
            system.debug('Current Order: ' + order.Id + ' Validity overwritten? ' + order.Validity_Overwritten__c);
            if(!order.Validity_Overwritten__c){
                orders.add(order);

                if(order.Account__c != null){
                    accIds.add(order.Account__c);
                }

                if(order.PrimarySalesRep__c != null){
                    userIds.add(order.PrimarySalesRep__c);
                }
            }
        }

        map<Id, Account> mapAccount = new map<Id, Account>([Select Id,Name from Account Where Id IN :accIds]);
        map<Id, User> mapUser= new map<Id, User>([Select Id,Name,Username from User Where Id IN :userIds]);
        List<Order__c> orderToUpdate = new  List<Order__c>();

        for(Order__c order : orders){
            system.debug('Old Order Map? ' + oldOrderMap);

            if(oldOrderMap == null) {
                system.debug('inside of call with no old order map');

                isValidOrder(order,mapAccount,mapUser);
            }
            else {
                system.debug('checking to see if any fields changed');
                // Check order is eligibel to update for isValid field
                ///*order.Sent_to_Verification__c != oldOrderMap.get(order.Id).Sent_to_Verification__c ||*/
                //removed the or condition from the If statement below (I-178018)
                if(order.OrderStatus__c != oldOrderMap.get(order.Id).OrderStatus__c ||
                   order.Payment_Frequency__c != oldOrderMap.get(order.Id).Payment_Frequency__c ||
                   order.Account__c != oldOrderMap.get(order.Id).Account__c ||
                   order.PrimarySalesRep__c != oldOrderMap.get(order.Id).PrimarySalesRep__c ||
                   order.Sent_to_Verification__c != oldOrderMap.get(order.Id).Sent_to_Verification__c) {
                    system.debug('fields changed, checking isValidOrder');
                    //system.debug('qaccount1' + Helper.queryAccountList());
                       isValidOrder(order,mapAccount,mapUser);
                    //system.debug('qaccount2' + Helper.queryAccountList());
                   }
            }
        }
    }


    // Method to find that Order is Valid or not as per requirement
    public void isValidOrder(Order__c orderRecord,map<Id, Account> mapAccount,map<Id, User> mapUser){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','IsValidOrder');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Account acc = null;
        User salesRep = null;

        if(orderRecord.Account__c != null){
            acc = mapAccount.get(orderRecord.Account__c);
        }

        if(orderRecord.PrimarySalesRep__c != null){
            salesRep = mapUser.get(orderRecord.PrimarySalesRep__c);
        }

        system.debug('==acc=='+acc+'===salesrep=='+salesRep);
        system.debug('Order Status ' + orderRecord.OrderStatus__c);
        system.debug('orderRecord.Payment_Frequency__c ' + orderRecord.Payment_Frequency__c);
        system.debug('orderRecord Sent To Verficication ' + orderRecord.Sent_To_Verification__c);
        system.debug('account ' + acc);
        system.debug('Sales rep ' + salesRep);

        if((orderRecord.OrderStatus__c != 'Open' && orderRecord.OrderStatus__c != 'Pending Processing' &&
            orderRecord.OrderStatus__c != 'Rejected' && orderRecord.OrderStatus__c != 'Negated')
           && (orderRecord.Payment_Frequency__c != 'Contingent N/ Contract' && orderRecord.Payment_Frequency__c != 'Contingent Upsell N/ Contract')
           && orderRecord.Sent_to_Verification__c
           && ((acc != null && !(acc.Name.startsWith('PAT'))) || acc == null)
           && ((salesRep!= null && !(salesRep.Username.startsWith('patsalesforce')) && salesRep.Name != 'FRAUD')
               || salesRep == null)
          ) {

              // set the value & return record
              orderRecord.isValid__c = 'Valid';
              System.debug('===Order is Valid===');

          }
        else {
            // set the value & return record
            orderRecord.isValid__c = 'Invalid';
            System.debug('===Order is Invalid=== OrderStatus__c=' + orderRecord.OrderStatus__c + ', Payment_Frequency__c=' + orderRecord.Payment_Frequency__c + ', Sent_to_Verification__c=' + orderRecord.Sent_to_Verification__c + ', acc=' + acc + ', salesRep=' + salesRep);
        }

    }

    // Populate Product Heirarchy fields on order line item
    public void pouplateProductHierarchyFields(Order__c [] pNewOrders, Map<Id, Order__c> oldOrderIdMap) {
    final string METHODNAME = CLASSNAME.replace('METHODNAME','pouplateProductHierarchyFields');
    system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        set<Id> orderIds = new set<Id>();
        map<string,string> mapOrderLineToQuoteLine = new map<string,string>();
        map<Id,Apttus_Proposal__Proposal_Line_Item__c> mapLineItem;
        List<Order_Line_Item__c> orderLineToUpdate = new List<Order_Line_Item__c>();
        for(Order__c o : pNewOrders){
            string status = o.OrderStatus__c;
            if((status == 'Verified' || status == 'Resubmitted' || status == 'Negated'
                || status == 'Paid in Full' || status == 'Full' || status == 'Invoiced' || status == 'Closed') &&
               (oldOrderIdMap.get(o.Id).OrderStatus__c != 'Verified' || oldOrderIdMap.get(o.Id).OrderStatus__c != 'Resubmitted'
                || oldOrderIdMap.get(o.Id).OrderStatus__c != 'Negated' || oldOrderIdMap.get(o.Id).OrderStatus__c != 'Paid in Full'
                || oldOrderIdMap.get(o.Id).OrderStatus__c != 'Full' || oldOrderIdMap.get(o.Id).OrderStatus__c != 'Invoiced'
                || oldOrderIdMap.get(o.Id).OrderStatus__c != 'Closed')){

                    orderIds.add(o.Id);
                }
        }
        System.debug('pouplateProductHierarchyFields=='+orderIds);
        if(orderIds.isEmpty()) return;
        List<Order_Line_Item__c>  orderLineItems = [ Select Id, ProposalLineItem__c,Order__c,
                                                    Product_family__c,Product_Category__c,  Sub_Category__c,
                                                    Media_Group__c,Media_Type__c from Order_Line_Item__c
                                                    Where Order__c IN :orderIds and ProposalLineItem__c != null];

        if(orderLineItems.isEmpty()) return;
        for(Order_Line_Item__c oli : orderLineItems) {
            mapOrderLineToQuoteLine.put(oli.Id, oli.ProposalLineItem__c);
        }
        mapLineItem = new map<Id,Apttus_Proposal__Proposal_Line_Item__c>([select Product_Family__c,Product_Cateogry__c ,
                                                                          Product_SubCategory__c ,
                                                                          Media_Group__c ,
                                                                          Media_Type__c
                                                                          from Apttus_Proposal__Proposal_Line_Item__c
                                                                          where Id IN :mapOrderLineToQuoteLine.values()]);
        System.debug('orderLineItems=='+orderLineItems);
        for(Order_Line_Item__c oli : orderLineItems) {
            if(mapOrderLineToQuoteLine.containsKey(oli.Id) && mapLineItem.containsKey(mapOrderLineToQuoteLine.get(oli.Id))) {
                Apttus_Proposal__Proposal_Line_Item__c proposalLine = mapLineItem.get(mapOrderLineToQuoteLine.get(oli.Id));
                if(proposalLine != null) {
                    oli.Product_family__c = proposalLine.Product_Family__c;
                    oli.Product_Category__c = proposalLine.Product_Cateogry__c;
                    oli.Sub_Category__c = proposalLine.Product_SubCategory__c;
                    oli.Media_Group__c  = proposalLine.Media_Group__c ;
                    oli.Media_Type__c = proposalLine.Media_Type__c;
                    orderLineToUpdate.add(oli);
                }
            }
        }

        if(!orderLineToUpdate.isEmpty()){
            update orderLineToUpdate;
        }

    }


    private static void updateRelatedOpportunityStage(List<Order__c> newOrders, Map<Id, Order__c> oldOrderIdMap){
        system.debug('**** Inside OrderTriggerHandler.updateRelatedOpportunityStage');

        Map<String,String> orderOptyMap = new Map<String,String>();
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
        List<Opportunity> optyLst = new List<Opportunity>();
        Opportunity opp = null;
        for(Order__c ord : newOrders){

            if(ord.Opportunity__c != null && (oldOrderIdMap.get(ord.Id).OrderStatus__c !=  'Verified' && ord.OrderStatus__c == 'Verified')
                || (oldOrderIdMap.get(ord.Id).OrderStatus__c !=  'Pending Processing' && ord.OrderStatus__c == 'Pending Processing')
                || (oldOrderIdMap.get(ord.Id).OrderStatus__c != 'Paid In Full' && ord.OrderStatus__c == 'Paid In Full') ){

                orderOptyMap.put(ord.Id,ord.Opportunity__c);
                system.debug('orderOptyMap' + orderOptyMap);
            }
         }

         if(orderOptyMap.isEmpty()) return;
         oppMap = new Map<Id,Opportunity>([Select Id,StageName, CloseDate From Opportunity Where Id IN :orderOptyMap.values()]);
         Map<Id,Date> orderToEPSD = new Map<Id,Date>();
         for(Order_Line_Item__c oli : [Select Id, Order__c, Earliest_Product_Start_Date__c
                From Order_Line_Item__c
                Where Order__c In :orderOptyMap.keySet()] ){
            if(orderToEPSD.get(oli.Order__c) == null){
                orderToEPSD.put(oli.Order__c,oli.Earliest_Product_Start_Date__c);
            } else {
                Date epsdTest = orderToEPSD.get(oli.Order__c);
                if(epsdTest < oli.Earliest_Product_Start_Date__c){
                    orderToEPSD.put(oli.Order__c, oli.Earliest_Product_Start_Date__c);
                }
            }
         }

         for(Order__c ord : newOrders){
            opp = null;
            if(oppMap.containsKey(ord.Opportunity__c)){
                opp = oppMap.get(ord.Opportunity__c);
                system.debug('opp' +opp);
                if(opp != null){
                    system.debug('orderupdate opp stage before IF : '+opp.StageName);
                    system.debug('orderupdate order status before IF : '+ord.OrderStatus__c);
                    system.debug('orderToEPSD.get(ord.Id) : ' + orderToEPSD.get(ord.Id));

                    //I-221460
                    //if NA then we have one value for close date, EU/APAC use a different value
                    if(ord.OrderStatus__c == 'Pending Processing' && opp.StageName != 'Stage 4 - Won'){
                        opp.StageName = 'Stage 4 - Won';
                        opp.Skip_Stage_Validation__c = true;
                        optyLst.add(opp);
                        system.debug('orderupdate opp stage pending : '+opp.StageName);
                    }
                    //Finanace Hold added for S-456265
                    else if((ord.OrderStatus__c == 'Verified' || ord.OrderStatus__c == 'Paid In Full' || ord.OrderStatus__c =='Invoiced' || ord.OrderStatus__c =='Finanace Hold'  ) && opp.StageName != 'Stage 5 - Verified by Finance'){
                        opp.StageName = 'Stage 5 - Verified by Finance';
                        opp.Skip_Stage_Validation__c = true;

                        //Sberron - S-452704 - 12/21
                        //Oppty CloseDate now being set in OrderTriggerHelper.opptywriteback
                        /*
                        //I-221460 - if NA then we set the Close date of the opp
                        if(ord.Organization__c == 'North America'){
                            if(orderToEPSD.get(ord.Id) != null){
                                opp.CloseDate = orderToEPSD.get(ord.Id);
                                System.debug('----SETTING CloseDate1');
                            }
                            opp.Bypass_Close_Date_Validation__c = true;
                        }
                        */
                        optyLst.add(opp);
                        system.debug('orderupdate opp stage verified : '+opp.StageName);

                    }
                    /*
                    else if(ord.OrderStatus__c == 'Verified' && ord.Organization__c == 'North America'){
                        //I-221460 - if NA then we set the Close date of the opp
                        if(orderToEPSD.get(ord.Id) != null){
                            System.debug('----SETTING CloseDate2');
                            opp.CloseDate = orderToEPSD.get(ord.Id);
                            opp.Bypass_Close_Date_Validation__c = true;
                            optyLst.add(opp);
                        }
                    }
                    */
                }
            }
        }

        if(!optyLst.isEmpty()){
            update optyLst;
        }
    }

    /*
    // Added by Vivek Ojha for T-434699
    /* Commented due to test class coverage fix - Shyam 1/11 - Method not called from anywhere
    private static void updateOpportunityAmount(List<Order__c> newOrders){
        system.debug('**** Inside OrderTriggerHandler.updateOpportunityAmount');

        Map<String,String> orderOptyMap = new Map<String,String>();
        Map<String,Order__c> optyOrderMap = new Map<String,Order__c>();
        List<Opportunity> optyLst = new List<Opportunity>();

        System.debug('== In updateOpportunityAmount ==');
        newOrders = [Select Id,OrderStatus__c,Opportunity__c,Order_item_Sales_Credit_Total__c from Order__c Where Id IN :newOrders];
        for(Order__c ord : newOrders){
            if(ord.OrderStatus__c == 'Verified' ){
                orderOptyMap.put(ord.Id,ord.Opportunity__c);
                optyOrderMap.put(ord.Opportunity__c,ord);
            }
        }

        if(orderOptyMap.isEmpty()) return;

        for(Opportunity opty :[Select Id,Amount From Opportunity Where Id IN : orderOptyMap.values() AND Organization__c ='North America']){

            System.debug('optyOrderMap=='+optyOrderMap + '==opty=='+opty.Id);
            System.debug('optyOrderMap.containsKey(opty.Id)=='+optyOrderMap.containsKey(opty.Id));
            if(optyOrderMap.containsKey(opty.Id)){
                System.debug('sales=='+optyOrderMap.get(opty.Id).Order_item_Sales_Credit_Total__c);
                opty.Amount = optyOrderMap.get(opty.Id).Order_item_Sales_Credit_Total__c;
                optyLst.add(opty);
            }
        }
        if(!optyLst.isEmpty()){
            update optyLst;
        }
       System.debug('== Out updateOpportunityAmount =='+optyLst);
    }
    */

    // Added by Vivek Ojha for T-434704
    // Description : Create Opportunity when Order is created through integration.
    /*
    private static void createOpportunity(List<Order__c> newOrders){

        Map<String,String> orderOptyMap = new Map<String,String>();
        Map<String,Order__c> optyOrderMap = new Map<String,Order__c>();
        List<Opportunity> optyLst = new List<Opportunity>();
        List<Order__c> ordLst = new List<Order__c>();
        set<Id> accIds = new set<Id>();
        Integer counter =0;

        System.debug('== In createOpportunity ==');

        for(Order__c ord : newOrders){
            accIds.add(ord.Account__c);
        }

        Map<Id,Account> accMap = new MAp<Id,Account>([Select Id,CustomerLapsedDate__c,createdDate, AccountStatus__c,OwnerId FROM Account Where Id IN : accIds]);
        for(Order__c ord : newOrders){
            System.debug('ord=='+ord );
            //(Account Status = 'Customer' OR Order.Promotions != null)
            if(accMap.get(ord.Account__c).AccountStatus__c == 'Customer' || ord.Promotions__c != null){

                System.debug('ord.Account__r.AccountStatus__c=='+ord.Account__r.AccountStatus__c);

                Opportunity opty = new Opportunity();
                opty.StageName ='Stage 5 - Verified by Finance';
                if(ord.OrderStatus__c == 'Verified'){
                    opty.StageName ='Stage 5 - Verified by Finance';
                }else if(ord.OrderStatus__c == 'Pending Processing'){
                    opty.StageName ='Stage 4 - Won';
                }
                opty.Amount = ord.Order_item_Sales_Credit_Total__c;
                opty.OwnerId = accMap.get(ord.Account__c).OwnerId;

                opty.AccountId = ord.Account__c;
                opty.CloseDate = Date.today();
                opty.Name = 'Opty From Order ' ;
                if((accMap.get(ord.Account__c).createdDate == System.today()) ||(accMap.get(ord.Account__c).AccountStatus__c == 'Candidate')){
                    opty.OpportunityType__c = 'New Customer';
                }else if(accMap.get(ord.Account__c).CustomerLapsedDate__c != null && ord.OrderDate__c > (accMap.get(ord.Account__c).CustomerLapsedDate__c).addDays(365)){
                    opty.OpportunityType__c ='Winback';
                }else{
                    opty.OpportunityType__c ='Renewal';
                }
                optyLst.add(opty);
                ordLst.add(ord);
                System.debug('optyLst=='+optyLst);

            }
        }
        if(!optyLst.isEmpty()){
            insert optyLst;
        }
        for(Order__c ord : ordLst){
            ord.Opportunity__c =  optyLst[counter].Id;
            counter++;
        }


        System.debug('== Out createOpportunity =='+optyLst+'==ordLst=='+ordLst);
    }
    */

    //  //T-445611
    // // Description : Keep currency in sync between order and order line item.
    private static void syncCurrencyType(List<Order__c> newOrders, map<Id,Order__c> newOrderMap){
        system.debug('**** Inside OrderTriggerHandler.syncCurrencyType');
        List<Order_Line_Item__c> tobeUpdated = new List<Order_Line_Item__c>();
        for(Order_Line_Item__c oli : [Select Id,Order__c,Order__r.CurrencyIsoCode,CurrencyIsoCode FROM Order_Line_Item__c Where Order__c IN : newOrderMap.keySet() limit 1000]){
            if(oli.Order__r.CurrencyIsoCode != oli.CurrencyIsoCode ){
                oli.CurrencyIsoCode = oli.Order__r.CurrencyIsoCode;
                tobeUpdated.add(oli);

            }
        }
        if(tobeUpdated.size()>0)
            update tobeUpdated;

    }
    /*
    ** @author : Adarsh
    ** @date : 05/04/2016
    ** @story :
    ** @Issue : for I-212413
    ** @description : Populate SiteChannelCountry
    ** @paramaters : list of Orders
    ** @returns : nothing
    */
    /*
    public void PopulateSiteChannelCountry(Order__c [] pNewOrders){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','PopulateSiteChannelCountry');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            set<String> OrdSiteId = new set<String>();
            system.debug('pNewOrders'+pNewOrders);
            String PartnerCountry;
            for(Order__c ord : pNewOrders){
                    OrdSiteId.add(ord.SiteChannelID__c);
             }
            system.debug('OrdSiteId'+OrdSiteId);
            List<Partner_Revenue_Share__c> PrsList = [SELECT Id,Country__c FROM Partner_Revenue_Share__c WHERE SiteChannelID__c =: OrdSiteId and Country__c <> null Limit 1];
                //queryPartnerRevenueShare();
            system.debug('PrsList'+PrsList);
            for(Partner_Revenue_Share__c Prs: PrsList){
                     PartnerCountry = Prs.Country__c;
                    system.debug('PrsList1'+ PartnerCountry);

            }
            for(Order__c OrdList: pNewOrders){
                OrdList.SiteChannelCountry__c =  PartnerCountry;
                system.debug('PrsList2'+OrdList.SiteChannelCountry__c );
            }
        }
         catch(Exception e){
            system.debug('errored');
            ExceptionLog.add('Exception', 'OrderTriggerHelper', 'Populate SiteChannelCountry', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to populate SiteChannelCountry on Order.' ,e);
        }
    }*/
}