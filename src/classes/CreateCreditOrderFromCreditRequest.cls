/**
* @description Class that will create a credit order and credit order line item
* @author Cloudsherpas
* @date 5-22-2014
*/
public without sharing class CreateCreditOrderFromCreditRequest {
    final String CLASSNAME = '\n\n**** CreateCreditOrderFromCreditRequest.METHODNAME()';
    public String ErrorMessage{get;set;}
    public String CreditPartialErrorMessage{get;set;}
    public string stringURL{get;set;}
    public Id orderId{get;set;}
    public Id creditRequestId{get;set;}
    public Boolean showAlert{get;set;}
    public Order__c newOrder {get;set;}


    public CreateCreditOrderFromCreditRequest(ApexPages.StandardController controller){

    }

    //constructer used to pass in the orderId and credit request Id
    public CreateCreditOrderFromCreditRequest(Id porderId, Id pcreditRequestId){
        orderId = porderId;
        creditRequestId = pcreditRequestId;
    }

/**
* @description A method that will be executed once the page is called.
* @author Cloudsherpas
* @date 5-22-2014
* @param none
* @returns none
*/
    public PageReference executeMethod(){
        orderId =  ApexPages.currentPage().getParameters().get('oid');
        creditRequestId = ApexPages.currentPage().getParameters().get('crid');
        /*map<String, map<String, Id>> result = Utility.GetRecordTypeIdsBySObjectNameSet(new set<String>{'Order__c', 'Order_Line_Item__c'});
        //String recordId = result.get('Account').get('Person Account');
        String orderRecordTypeId = result.get('Order__c').get('Credit');
        String orderLIRecordTypeId = result.get('Order_Line_Item__c').get('Credit Order Line Item');
        Order__c newOrder = new Order__c();
        List<Order_Line_Item__c> OrderLineItemToBeInserted = new List<Order_Line_Item__c>();*/
        String orig = URL.getCurrentRequestUrl().toExternalForm();
        //Modify the URL
        String orig2 = orig.replace('&save_new=1','').replace('&sfdc.override=1','');
        stringURL = '/'+ creditRequestId;


        String result = createCreditOrder();


        if(result == 'Success'){
            PageReference CRPage = new ApexPages.StandardController(newOrder).view();
            CRPage.setRedirect(true);
            return CRPage;
        } else {
            showAlert = true;
            ErrorMessage = result;
            return null;
        }
    }

 public string createCreditOrder(){
    final string METHODNAME = CLASSNAME.replace('METHODNAME','createCreditOrder');
    system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
    OrderTriggerHandler.ProcessingCreditRequest = True; // Mitali N Appirio 5/12/17 I-273786
    String returnString = 'Success';
    newOrder = new Order__c();
    Savepoint sp;
    try {


        Utility util = new Utility();
        Map<String, Map<String, Schema.SObjectField>> sObjectAndFields = util.getAllSObjectFieldsBySObjectName(new Set<String>{
            'Credit_Request__c', 'CreditRequestLineItem__c', 'Credit_Request_License_ID__c',
            'Order_Line_Item__c', 'Order__c'});
        //List<Order_Line_Item__c> OrderLineItemToBeInserted = new List<Order_Line_Item__c>();
        map<Id,Order_Line_Item__c> mapOrderLineItemToBeInserted = new map<Id,Order_Line_Item__c>();

        // Defining Objects
        Map<String, Schema.SObjectField> CRFields = sObjectAndFields.get('Credit_Request__c');
        Map<String, Schema.SObjectField> CRLIFields = sObjectAndFields.get('CreditRequestLineItem__c');
        Map<String, Schema.SObjectField> OrderFields = sObjectAndFields.get('Order__c');
        Map<String, Schema.SObjectField> CRLicFields = sObjectAndFields.get('Credit_Request_License_ID__c');
        Map<String, Schema.SObjectField> OLIFields = sObjectAndFields.get('Order_Line_Item__c');

        // Defining RT
        map<String, map<String, Id>> result = Utility.GetRecordTypeIdsBySObjectNameSet(new set<String>{'Order__c', 'Order_Line_Item__c'});
        String orderRecordTypeId = result.get('Order__c').get('Credit');
        String orderLIRecordTypeId = result.get('Order_Line_Item__c').get('Credit Order Line Item');

        //  Credit Request and Order
        String Query = 'SELECT ';
        for(String sourceAPI : CRFields.keySet()){
            Query += sourceAPI+',';
        }

        for(String sourceAPI : OrderFields.keySet()){
            Query += 'Order__r.' + sourceAPI + ',';
        }

        Query = Query.removeEnd(',');
        Query += ' From Credit_Request__c WHERE ID =\'' + creditRequestId +'\' LIMIT 1';
        system.debug('Check ' + Query);

        //  Credit Request Line
        String CRLIQuery = 'SELECT ';
        for(String sourceAPI : CRLIFields.keySet()){
            CRLIQuery += sourceAPI+',';
        }
        for(String sourceAPI : OLIFields.keySet()){
            CRLIQuery += 'Order_Line_Item__r.' + sourceAPI + ',';
        }

        // Inner Query for Credit_Request_License_IDs__r
        String innerLicenseQuery = 'SELECT ';
        for(String sourceAPI : CRLicFields.keySet()){
            innerLicenseQuery += sourceAPI+',';
        }
        //innerLicenseQuery = innerLicenseQuery.removeEnd(',');

        String FinalinnerLicenseQuery ='(' + innerLicenseQuery + 'LicenseID__r.SiteLicenseID__c FROM Credit_Request_License_IDs__r )';
        CRLIQuery += FinalinnerLicenseQuery + ' From CreditRequestLineItem__c WHERE Credit_Request__c =\'' + creditRequestId + '\'';
        system.debug('Check ' + CRLIQuery);

        list<Credit_Request__c> CRFinalList = Database.query(Query);
        system.debug('Check ' + CRFinalList);
        Credit_Request__c crc = CRFinalList[0];

        list<CreditRequestLineItem__c> CRLIsFinalList = Database.query(CRLIQuery);
        system.debug(CRLIsFinalList);

        checkAvailableInventory(CRLIsFinalList);

        sp = Database.setSavepoint();//saving database status
        
       // system.debug('Bypass_All_Validation_Rules__c '+Bypass_All_Validation_Rules__c );
        //system.debug('Bypass_Credit_Status_Validation__c '+Bypass_Credit_Status_Validation__c );
        newOrder = populateOrderFields(crc,OrderFields);
        newOrder = setHardcodedOrderFields(newOrder,crc);
        system.debug('OrderTriggerHandler.ProcessingCreditRequest '+OrderTriggerHandler.ProcessingCreditRequest );
        system.debug('new Order');
        System.debug('Agency Billing Contact ' + newORder.AgencyBillingContact__c);
        system.debug('createCreditOrder NEWORDER'+newOrder);
        system.debug('>>>>>>>>>>>' + newOrder.Account__c);
        insert newOrder;

         //OrderLineItemToBeInserted = populateOLIFields(CRLIsFinalList, OLIFields, orderLIRecordTypeId, newOrder);
        mapOrderLineItemToBeInserted = populateOLIFields(CRLIsFinalList, OLIFields, orderLIRecordTypeId, newOrder);

        //system.debug('New OrderLineItemToBeInserted ' + OrderLineItemToBeInserted);
        if(!mapOrderLineItemToBeInserted.isEmpty()){
            insert mapOrderLineItemToBeInserted.values();
        }

        createSalesAllocationForCredit(mapOrderLineItemToBeInserted);
        //system.debug('OrderLineItemToBeInserted after insert call '+OrderLineItemToBeInserted);


        } catch (Exception e){

            if(sp != null){
                Database.rollback(sp);
            }
            system.debug('\n\nERROR: '+ e.getMessage() + e.getStackTraceString() + '\n\n');
            returnString = e.getMessage();
            if(returnString.length() > 120){
                returnString = returnString.subString(0,120);
            }
        }




        system.debug('RETURN STRING '+ returnString);
        return returnString;

    }

    private Order__c populateOrderFields(Credit_Request__c pCreditRequest, Map<String, Schema.SObjectField> pOrderFields){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populateOrderFields');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        //we have all the order fields from our describe call
        //need to populate those fields using object notation
        //for our new credit order

        Order__c parentOrder = pCreditRequest.Order__r;
        Order__c returnOrder = new Order__c();
        String errors = '';
        for(String fieldName : pOrderFields.keySet()){
            Schema.SObjectField fieldSchema = pOrderFields.get(fieldName);
            //We used to use isUpdateable() here, but that runs in the context
            //of the logged in user, but we want to populate all fields (since this
            //is without sharing class)
            if(fieldName != 'Id' && fieldName != 'CreatedDate' && fieldName != 'LastModifiedDate' && fieldName !='CreatedById' && fieldName!='LastModifiedById'){
                try{
                    returnOrder.put(fieldName, parentOrder.get(fieldName));
                } catch(Exception ex){
                    errors += ex.getMessage() + ' \n';
                }
            }
        }
        system.debug('Field population errors: ' + errors);

        return returnOrder;
    }

    private Order__c setHardcodedOrderFields(Order__c pCreditOrder, Credit_Request__c pCreditRequest){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','setHardcodedOrderFields');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        //this is the function where we will set the hardcoded fields for the new credit order
        Order__c creditOrder = pCreditOrder;
        Id creditRecordType = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c','Credit');

        creditOrder.ParentOrder__c = pCreditRequest.Order__r.Id;
        creditOrder.CreditRequest__c = pCreditRequest.Id;
        creditOrder.RecordTypeId = creditRecordType;
        creditOrder.OrderStatus__c = 'Open';
        creditOrder.CreditType__c = pCreditRequest.Credit_Type__c;
        creditOrder.CurrencyISOcode = pCreditRequest.currencyISOCode;
        // Set Order date on credit
        creditOrder.OrderDate__c = System.today();
        if(pCreditRequest.Payment_Details__c != null){
            creditOrder.Payment_Details__c = pCreditRequest.Payment_Details__c ;
        }
        if(pCreditRequest.Payment_Method__c != null){
            creditOrder.Payment_Method_text__c = pCreditRequest.Payment_Method__c;
        }
        if(pCreditRequest.PaymentTerm__c != null){
            creditOrder.Payment_Term_text__c = pCreditRequest.PaymentTerm__c;
        }


        // these fields count as not updateable according to the describe earlier
        // master detail doesn't count as updateable, and for some reason anything
        // with a required filtered lookup doesn't get populated either
        /*creditOrder.Account__c = pCreditRequest.Order__r.Account__c;
        creditOrder.AgencyBillingContact__c = pCreditRequest.Order__r.AgencyBillingContact__c;
        creditOrder.Posting_Contact__c = pCreditRequest.Order__r.Posting_Contact__c;
        creditOrder.Primary_Contact__c = pCreditRequest.Order__r.Primary_Contact__c;
        creditOrder.Send_Welcome_Letter_to__c = pCreditRequest.Order__r.Send_Welcome_Letter_to__c;
        creditOrder.BillingContact__c  = pCreditRequest.Order__r.BillingContact__c;
        creditOrder.Agency__c = pCreditRequest.Order__r.Agency__c;*/

        //populate Payment details - these are hardcoded from an issue I-159677
        //Payment frequency is from I-194878
        if(pCreditRequest.Order__r.AccountOrganization__c == 'North America'){
            creditOrder.Payment_Frequency__c = 'Single Payment';
        } else {
            creditOrder.Payment_Frequency__c = 'Single Invoice';
        }
        System.debug('----before Payment_Method__c: ' + creditOrder.Payment_Method_text__c + 'Payment_Term_text__c' + creditOrder.Payment_Term_text__c);
        creditOrder.Payment_Method_text__c = 'Credit';
        creditOrder.Payment_Term_text__c = 'Immediate';
        creditOrder.Installments__c = 1;
        System.debug('----after Payment_Method__c: ' + creditOrder.Payment_Method_text__c + 'Payment_Term_text__c' + creditOrder.Payment_Term_text__c);
        //Various fields that need to be nulled out:

        creditOrder.QuoteProposal__c = null;
        creditOrder.Opportunity__c = null;
        creditOrder.SiteResult__c = null;
        creditOrder.Sent_to_Verification__c = false;
        creditOrder.SiteResultDescription__c = null;
        creditOrder.SentToVerificationDate__c = null;
        creditOrder.SentToVerificationBy__c = null;
        creditOrder.Avalara_Failed__c = null;
        creditOrder.AvalaraResponseCode__c = null;
        creditOrder.AvalaraResponseMessage__c = null;
        creditOrder.Avalara_Tax_ID__c = null;
        creditOrder.Avalara_TimeStamp__c = null;
        creditOrder.VerifiedBy__c = null;
        creditOrder.VerifiedDate__c = null;
        //creditOrder.WebOrderNumber__c = null;  //AS Jan 24,2017 S-445814
        creditOrder.SentToARDate__c = null;
        creditOrder.IntegrationStatus__c = null;
        creditOrder.RejectedDate__c = null;
        creditOrder.RejectedBy__c = null;
        creditOrder.RejectedReason__c = null;
        creditOrder.Legacy_Order_ID__c = null;
        creditOrder.LegacyKarmaID__c = null;

        creditOrder.Detailed_Credit_Reason__c = pCreditRequest.DetailedCreditReason__c;

        //S-437626 JFreese Appirio 10/24/16 Set Billing Start Date if that was the reason for the credit/rebill
        if(pCreditRequest.CreditReason__c == 'Billing Start Date Correction' &&
           pCreditRequest.Billing_Start_Date__c != null){
            system.debug('Overriding default BillingStartDt__c ' + creditOrder.BillingStartDt__c + ' with ' + pCreditRequest.Billing_Start_Date__c + ' because CreditReason__c=' + pCreditRequest.CreditReason__c);
            creditOrder.BillingStartDt__c = pCreditRequest.Billing_Start_Date__c;
        }
        
        /* Newly created Credit order should not have this checkbox = true as per S-472117
           By Vikas Menon on 25 April, 2017 */
           
        creditOrder.Cancelled_by_Ecom_Screening__c = false;  
        
        return creditOrder;
    }

    private void checkAvailableInventory(list<CreditRequestLineItem__c> CRLIlist){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','checkAvailableInventory');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        map<String, Credit_Request_License_ID__c> siteLicenseIdToCreditRequestId = new map<String, Credit_Request_License_ID__c>();

        for(CreditRequestLineItem__c crli : CRLIList){
            if(crli.CreditType__c == 'Inventory'){
                for(Credit_Request_License_ID__c license : crli.Credit_Request_License_IDs__r){
                    if(license.LicenseID__r.SiteLicenseID__c != null){
                        siteLicenseIdToCreditRequestId.put(license.LicenseID__r.SiteLicenseID__c, license);
                    }
                }
            }
        }
        if(!siteLicenseIdToCreditRequestId.isEmpty()){
            map<String, Integer> quantityResult = BizAppsSiteModel.GetLicenseAndRelativesForCreditRequest(siteLicenseIdToCreditRequestId.keySet());

            String defaultMsg = '\\nCredit Request License ID Error(s):';
            String output = defaultMsg;
            if(quantityResult != null && !quantityResult.isEmpty()){
                for(String siteLicense : quantityResult.keySet()){
                    if(siteLicenseIdToCreditRequestId.containsKey(siteLicense)){
                        Credit_Request_License_ID__c item = siteLicenseIdToCreditRequestId.get(siteLicense);
                        Integer quantityToCheck = Integer.valueOf(item.CreditQuantity__c);
                        if(quantityToCheck > quantityResult.get(siteLicense)){
                            output += '\\nError in ' + item.Name + ': ' + ' Credit Quantity is greater than available quantity.';
                        }
                    }
                }
            }
            system.debug('n\nOutput: ' + output + '\n\n');
            if(output != defaultMsg){
                throw BaseApplicationException.NewException('', output);
            }
        }
    }

    private map<Id,Order_Line_Item__c> populateOLIFields(List<CreditRequestLineItem__c> CRLIList, Map<String, Schema.SObjectField> OLIFields, ID Record, Order__c pCreditOrder){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populateOLIFields');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        //List<Order_Line_Item__c> tobeinsertedOLI = new List<Order_Line_Item__c>();
        map<Id,Order_Line_Item__c> tobeinsertedOLI = new map<Id,Order_Line_Item__c>();

        Order_Line_Item__c parentOLI;

        Map<String,Id> lineItemProductNameMap = new Map<String, Id>();
        Set<String> ProductNameSet = new Set<String>();
        for(CreditRequestLineItem__c crli : CRLIList){
            ProductNameSet.add(crli.ProductName__c);
        }
        for(Product2 prod : [SELECT Id , Name FROM Product2 WHERE Name IN: ProductNameSet ]){
             lineItemProductNameMap.put(prod.Name, Prod.Id);
        }
        String errors = '';
        for(CreditRequestLineItem__c crliFirst : CRLIList){
            Order_Line_Item__c newOrderLineItem = new Order_Line_Item__c();
            parentOLI = crliFirst.Order_Line_Item__r;
            //system.debug('PARENT ORDER LINE ITEM BASEPRICE: '+ parentOLI.BasePrice__c);
            for(String fieldName : OLIFields.keySet()){
                Schema.SObjectField fieldSchema = OLIFields.get(fieldName);

                //We used to use isUpdateable() here, but that runs in the context
                //of the logged in user, but we want to populate all fields (since this
                //is without sharing class)
                if(fieldName != 'Id' && fieldName != 'CreatedDate' && fieldName != 'LastModifiedDate' && fieldName !='CreatedById' && fieldName!='LastModifiedById'){
                    try{
                        newOrderLineItem.put(fieldName, parentOLI.get(fieldName));
                    } catch(Exception ex){
                         errors += ex.getMessage() + ' \n';
                    }

                }
            }

            system.debug('populate OLI field errors: ' + errors);
            setHardcodedOLIFields(newOrderLineItem, crliFirst);
            //tobeinsertedOLI.add(newOrderLineItem);
            String lid = String.valueOf(parentOLI.get('Id'));
            tobeinsertedOLI.put(lid ,newOrderLineItem);
        }
        //system.debug('tobeinsertedOLI baseprice' +tobeinsertedOLI[0].BasePrice__c);
        return tobeinsertedOLI;
    }

    private Order_Line_Item__c setHardcodedOLIFields(Order_Line_Item__c pOrderLineItem, CreditRequestLineItem__c pCreditRequesLineItem){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','setHardcodedOLIFields');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Order_Line_Item__c creditLineItem = pOrderLineItem;

        creditLineItem.CreditRequestLineItem__c = pCreditRequesLineItem.Id;
        creditLineItem.CreditAmount__c =  pCreditRequesLineItem.CreditAmount__c;
        if(pCreditRequesLineItem.AvailableCreditAmount__c != null && pCreditRequesLineItem.CreditAmount__c != null){
            creditLineItem.Remaining_Credit_Amount__c = pCreditRequesLineItem.AvailableCreditAmount__c - pCreditRequesLineItem.CreditAmount__c;
        }

        creditLineItem.Quantity2__c = pCreditRequesLineItem.Quantity__c;
        creditLineItem.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Order_Line_Item__c','Credit Order Line Item');
        creditLineItem.GrossCreditAmount__c = pCreditRequesLineItem.CreditAmount__c;
        creditLineItem.Order__c = newOrder.Id;
        creditLineItem.NetCreditAmount__c = pCreditRequesLineItem.NetCreditAmount__c;
        creditLineItem.NetTotalAmount__c = pCreditRequesLineItem.NetTotalAmount__c;
        creditLineItem.APTS_Tax_Amount__c = pCreditRequesLineItem.TaxAmount__c;

        //List of all the fields that need to be nulled
        creditLineItem.Owner_on_Start_Date__c = null;
        creditLineItem.Job_Category__c = null;
        creditLineItem.Position_Sales_Channel__c = null;
        creditLineItem.Position_Sales_Group__c = null;
        creditLineItem.User_Position_Region__c = null;
        creditLineItem.Segment__c = null;
        creditLineItem.Job_Type__c = null;
        creditLineItem.Job_Type_based_on_OSD__c = null;
        creditLineItem.Organization_based_on_OSD__c = null;
        creditLineItem.Combined_Region_based_on_OSD__c = null;
        creditLineItem.Country_based_on_OSD__c = null;
        creditLineItem.Position_Account_Size_based_on_OSD__c = null;
        creditLineItem.Position_Job_Title_based_on_OSD__c = null;
        creditLineItem.Position_Sales_Group_based_on_OSD__c = null;
        creditLineItem.Segment_based_on_OSD__c = null;
        creditLineItem.Hierarchy_Manager1_New__c = null;
        creditLineItem.Hierarchy_Manager10_New__c = null;
        creditLineItem.Hierarchy_Manager2_New__c = null;
        creditLineItem.Hierarchy_Manager3_New__c = null;
        creditLineItem.Hierarchy_Manager4_New__c = null;
        creditLineItem.Hierarchy_Manager5_New__c = null;
        creditLineItem.Hierarchy_Manager6_New__c = null;
        creditLineItem.Hierarchy_Manager7_New__c = null;
        creditLineItem.Hierarchy_Manager8_New__c = null;
        creditLineItem.Hierarchy_Manager9_New__c = null;
        creditLineItem.Rev_Share_Type__c = null;
        creditLineItem.Manager_of_OSD__c = null;
        creditLineItem.Sales_Channel_based_on_OSD__c = null;
        creditLineItem.Region_based_on_OSD__c = null;
        creditLineItem.Region_Group_based_on_OSD__c = null;
        creditLineItem.Result__c = null;
        creditLineItem.ResultDescription__c = null;
        creditLineItem.Earliest_Product_Start_Date__c = null;
        creditLineItem.Partner_Revenue_Share__c = null;
        creditLineItem.ArchivalStatus__c = null;
        creditLineItem.Sales_Credit__c = null;
        creditLineItem.LegacyKarmaID__c = null;
       // creditLineItem.LineType__c = pCreditRequesLineItem.LineType__c;
        /*
        //Added by -- Prashant Gupta, Appirio, S-453882 03/07/17
        creditLineItem.StartDate__c = newOrder.BillingStartDt__c;
        //creditLineItem.StartDate__c = newOrder.ExpectedStartDate__c;
        //creditLineItem.EndDate__c = newOrder.ExpectedEndDate__c;
        //End
        */
        return creditLineItem;
    }

    /*
        Added by Vikas Menon, 16 Dec 2016
        reference to I-248451
        It creates sales allocation records for credit order which is copied from
        original order
    */

    public void createSalesAllocationForCredit(map<Id,Order_Line_Item__c> mapOrderLineItemToBeInserted){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','createSalesAllocationForCredit');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        map<Id,List<RevenueRecognition__c>> OLItoSalesAllocationMap = new map<Id,List<RevenueRecognition__c>>();
        List<RevenueRecognition__c> revenueRecognitionsList = new List<RevenueRecognition__c> ();
        RevenueRecognition__c newRevenueRecognition;
        for(RevenueRecognition__c revenue : [Select Id, Name, Lead__c, LegacyKarmaID__c,MNSTR_Ext_ID__c,OrderLineItem__c,
                                             SplitPercentage__c from RevenueRecognition__c Where OrderLineItem__c IN :mapOrderLineItemToBeInserted.keySet()]){
                if(!OLItoSalesAllocationMap.containsKey(revenue.OrderLineItem__c)){
                    OLItoSalesAllocationMap.put(revenue.OrderLineItem__c, new List<RevenueRecognition__c>());
                }
                OLItoSalesAllocationMap.get(revenue.OrderLineItem__c).add(revenue);
        }


        for(Id lineId : mapOrderLineItemToBeInserted.keySet()){
            if(!OLItoSalesAllocationMap.containsKey(lineId)) continue;
            for(RevenueRecognition__c revenue : OLItoSalesAllocationMap.get(lineId)){
                newRevenueRecognition = revenue.clone(false);
                newRevenueRecognition.OrderLineItem__c = mapOrderLineItemToBeInserted.get(lineId).Id;
                //Sberron - 12/22/16
                //Makes split amounts negative
                newRevenueRecognition.SplitPercentage__c *= -1;
                revenueRecognitionsList.add(newRevenueRecognition);
            }
        }

        if(!revenueRecognitionsList.isEmpty()){
            insert revenueRecognitionsList;
        }
    }

}