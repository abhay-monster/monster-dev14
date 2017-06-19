global without sharing class PaypalModel {
    final String CLASSNAME = '\n\n**** PaypalModel.METHODNAME() \n\n';

    public static final String INTERNAL_ERROR = '999';
    /*J Freese Appirio 4/17/17 Changed this from 9999 to 999.  If sendToPaypal() fails when called by
      refundPaypalTransaction(), it then calls processRefundReturnedData() which writes this value
      back to order__c.PaypalRefundResultCode__c, which is text(3)*/


    public enum State {INIT,PROCESS,ERROR}

    private map<String, String> ParamToTargetField;
    private map<String, String> ParamToTargetFieldInvoice;
    private map<String, String> ReturnedParam;
    public Id objectId;
    private String RequestBodyString;
    private String Endpoint;
    private PaypalModel.RequestHeader RequestWrap;
    private Apttus_Proposal__Proposal__c UsedQuote;
    private Order__c UsedOrder;
    private Invoices__c usedInvoice;
    public boolean isInvoice = false;
    private  PaypalResult Result;

    public Apttus_Proposal__Proposal__c Proposal {get{ return UsedQuote;}}

    public String SecureTokenID {get; private set;}
    public String Message;

    public Boolean IsCapture = false;
    public Boolean IsRefund = false;

    public PaypalModel(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','PaypalModel');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        RequestWrap =  getRequestHeader();
        RequestBodyString = '';
        Message = '';
    }

    public PaypalModel(Id objId){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','PaypalModel-objId');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        objectId = objId;

        system.debug('Object Id? ' + objId);
        system.debug('Invoices prefix? ' + Schema.Sobjecttype.Invoices__c.getKeyPrefix() );
        system.debug('stringified? ' + ((String)objId).left(3));
        if(Schema.Sobjecttype.Invoices__c.getKeyPrefix() == ((String)objId).left(3)){
            isInvoice = true;
        }

        RequestWrap =  getRequestHeader();
        RequestBodyString = '';
        Message = '';
    }

    webservice static String refundPaypalTransaction(Id pOrderId){
        try{
            system.debug('\n\nInside PaypalModel.refundPaypalTransaction().\n\n');

            Id StandardOrderRT = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Standard');

            Order__c UsedOrder = [SELECT QuoteProposal__c, Id, PaypalCaptureResultCode__c, PaypalCaptureResultMessage__c, PaypalCaptureReferenceNumber__c,
                                                        PaypalRefundResultMessage__c, PaypalRefundResultCode__c, PaypalRefundReferenceNumber__c
                                            FROM Order__c WHERE Id = :pOrderId AND RecordTypeId = :StandardOrderRT];

            if(UsedOrder.PaypalRefundResultMessage__c == 'Approved' && UsedOrder.PaypalRefundResultCode__c == '0'){
                return 'Transaction can not be completed:\n A succesful refund transaction has already been made.';
            }

            if(UsedOrder != null && UsedOrder.QuoteProposal__c != null && UsedOrder.PaypalCaptureResultCode__c == '0' && UsedOrder.PaypalCaptureResultMessage__c == 'Approved'){
                PaypalModel Connection = new PaypalModel();
                Connection.IsRefund = true;
                Connection.getRequiredParamMap();
                Connection.init(UsedOrder, PaypalModel.State.PROCESS);
                Connection.sendToPaypal();
                Connection.processRefundReturnedData();
            }

            return 'Success';
        }catch(Exception e){
            system.debug('\n\n PaypalModel.refundPaypalTransaction error:' + e + '\n\n');
            return 'An error occured';
        }
    }

    public static void PaypalCaptureTransaction(Case[] pUpdateCases, map<Id, Case> pOldCaseMap){
        system.debug('\n\nInside PaypalModel.PaypalCaptureTransaction');
        try{
            if(pUpdateCases.size() != 1){
                system.debug('\n\nExiting paypal capture transaction: Can only accomodate 1 record at a time.');
                return;
            }

            if(pUpdateCases[0].ParentId != null || pUpdateCases[0].OrderLineItem__c != null){
                system.debug('\n\nExiting paypal capture transaction: Can not process child cases..');
                return;
            }

            Id prodImplementationTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Case', 'Product Implementation');

            if(pUpdateCases[0].RecordTypeId != prodImplementationTypeId){
                system.debug('\n\nExiting paypal capture transaction: Can only process Product Implementation cases.');
                return;
            }

            Boolean allClosed = true;
            for(Case childCase : [SELECT Status FROM Case WHERE ParentId = :pUpdateCases[0].Id]){
                if(childCase.Status != 'Closed'){
                    allClosed = false;
                }
            }

            if(pUpdateCases[0].Order__c != null && allClosed && (pUpdateCases[0].Status == 'Closed' && pOldCaseMap.get(pUpdateCases[0].Id).Status != 'Closed')){
                Id StandardOrderRT = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Standard');
                Order__c UsedOrder = [SELECT QuoteProposal__c, Id, PaypalCaptureResultCode__c, PaypalCaptureResultMessage__c FROM Order__c WHERE RecordTypeId = :StandardOrderRT AND Id = :pUpdateCases[0].Order__c];

                if(UsedOrder.PaypalCaptureResultMessage__c == 'In Progress'){
                    system.debug('\n\nUnable to process paypal transaction: Currently in progress.\n\n');
                    return;
                }

                UsedOrder.PaypalCaptureResultCode__c = null;
                UsedOrder.PaypalCaptureResultMessage__c = 'In Progress';
                OrderTriggerHandler.ExecuteTriggers = false;
                update UsedOrder;

                if(UsedOrder != null){
                    SendToPaypalCaptureTransaction(UsedOrder.Id);
                }
                system.debug('\n\nCalling SendToPaypalCaptureTransaction and exiting PaypalCaptureTransaction.');
            }
        }catch(Exception e){
            system.debug('\n\nError: ' + e + '\nTrace' + e.getStackTraceString() + '\n\n');
        }
    }

    @future(callout=true)
    public static void SendToPaypalCaptureTransaction(Id pOrderIdSet){
        system.debug('\n\nInside PaypalModel.SendToPaypalCaptureTransaction');

        Order__c[] UsedOrder;
        try{
            Id StandardOrderRT = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Standard');
            UsedOrder = [SELECT QuoteProposal__c, Id, PaypalAuthResultCode__c, PaypalAuthResultMessage__c FROM Order__c WHERE RecordTypeId = :StandardOrderRT AND Id = :pOrderIdSet];

            if(UsedOrder != null && !UsedOrder.isEmpty() && (UsedOrder[0].PaypalAuthResultCode__c == '0' && (UsedOrder[0].PaypalAuthResultMessage__c == 'Approved' || UsedOrder[0].PaypalAuthResultMessage__c == 'Verified'))){
                PaypalModel Connection = new PaypalModel();
                Connection.IsCapture = true;
                Connection.getRequiredParamMap();
                Connection.init(UsedOrder[0].QuoteProposal__c, PaypalModel.State.PROCESS);
                Connection.sendToPaypal();
                Connection.processCaptureReturnedData();
            }
        }catch(Exception e){
            if(UsedOrder != null && !UsedOrder.isEmpty()){
                Order__c o = UsedOrder[0];
                o.PaypalCaptureReferenceNumber__c = null;
                o.PaypalCaptureResultMessage__c = 'Internal system error.';
                o.PaypalCaptureResultCode__c = null;

                OrderTriggerHandler.ExecuteTriggers = false;
                update o;
            }
            system.debug('\n\nError processing paypal transaction: ' + e + '\nTrace: ' + e.getStackTraceString());
        }
    }

    public String DecodeHashedID(Object hashed){
        return Schema.Sobjecttype.Apttus_Proposal__Proposal__c.getKeyPrefix() +
                    String.valueOf(hashed).right(23).left(8).right(5)  +
                    String.valueOf(hashed).left(10).right(7);
    }

    public PaypalResult sendToPaypal(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','sendToPaypal');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        try{
            generateRequestBody();

            HttpRequest request = new HttpRequest();
            request.setEndPoint(Endpoint);
            request.setMethod('POST');
            request.setBody(RequestBodyString);

            system.debug('request!!! ' + request);

            Http connect = new Http();
            HTTPResponse res;
            try{
                res = connect.send(request);
                system.debug('response!!! ' +res);
            }catch(System.TypeException te){
                if(Test.isRunningTest()){
                    res = new HTTPResponse();
                    res.setBody('SECURETOKEN=176a6609g1343gat1722&RESULT=0&RESPMSG=Approved&SECURETOKENID=' + SecureTokenID);
                }else{
                    system.debug('\n\nError: ' + te + '\n\n');
                }
            }

            String resultString = res.getBody();

            System.debug('\n\nPaypal Result: ' + resultString + '\n\n');
            if(resultString != null){
                PageReference resultGetter = new PageReference('http://output.result?'+resultString);

                if(resultGetter.getParameters() != null && resultGetter.getParameters().size() > 0){
                    Result.SecureToken = resultGetter.getParameters().get('SECURETOKEN');
                    Result.Result = resultGetter.getParameters().get('RESULT');
                    Result.RespMsg = resultGetter.getParameters().get('RESPMSG');
                    Result.SecureTokenID = resultGetter.getParameters().get('SECURETOKENID');

                    if(IsCapture || IsRefund){
                        Result.PNREF = resultGetter.getParameters().get('PNREF');
                    }else{
                        UsedQuote.PaypalSecureTokenID__c = Result.SecureTokenID;
                        system.debug(UsedQuote+'@@@@@@@@@@@@@@');
                        update UsedQuote;
                    }
                }
            }
        }catch(Exception e){
            system.debug('\n\nError: ' + e + '\n\n');
            Result.Result = INTERNAL_ERROR;
            Result.RespMsg = 'Internal Error';
        }
        return Result;
    }

    private void generateRequestBody(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','generateRequestBody');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        try{
            RequestBodyString += 'PARTNER='+getString(RequestWrap.partner) + '&';
            RequestBodyString += 'VENDOR='+getString(RequestWrap.vendor) + '&';
            RequestBodyString += 'USER='+getString(RequestWrap.user) + '&';
            RequestBodyString += 'PWD='+getString(RequestWrap.pwd) + '&';

            RequestBodyString += 'TIMEOUT=60&';
            if(IsCapture){
                RequestBodyString += 'ORIGID='+getString(UsedQuote.PaypalReferenceNumber__c)+'&';
                RequestBodyString += 'TENDER=C&';
                //RequestBodyString += 'TRXTYPE=D&';
                RequestBodyString += 'TRXTYPE=S&';
                RequestBodyString += 'TAXAMT'+getString(UsedQuote.APTTS_Tax_Total__c) + '&';
                RequestBodyString += 'AMT='+getString(UsedQuote.Quote_Total_With_Tax__c) + '&';
                system.debug('\n\nTAX AMOUNT: ' + getString(UsedQuote.APTTS_Tax_Total__c) + '\n\n');
            }else if(IsRefund){
                RequestBodyString += 'ORIGID='+getString(UsedOrder.PaypalCaptureReferenceNumber__c)+'&';
                RequestBodyString += 'TENDER=C&';
                //RequestBodyString += 'TRXTYPE=C&';
                RequestBodyString += 'TRXTYPE=S&';
                RequestBodyString += 'AMT='+getString(UsedQuote.Quote_Total_With_Tax__c) + '&';

            }else{
                //RequestBodyString += 'TRXTYPE=A&';
                RequestBodyString += 'TRXTYPE=S&';

                RequestBodyString += 'TAXAMT='+getString(UsedQuote.APTTS_Tax_Total__c) + '&';
                if(usedInvoice == null){
                    RequestBodyString += 'CURRENCY='+getString(UsedQuote.CurrencyIsoCode) + '&';
                } else {
                    RequestBodyString += 'CURRENCY='+getString(usedInvoice.CurrencyIsoCode) + '&';
                }


                RequestBodyString += 'BILLTOFIRSTNAME='+getString(UsedQuote.BillContact__r.FirstName) + '&';
                RequestBodyString += 'BILLTOLASTNAME='+getString(UsedQuote.BillContact__r.LastName) + '&';
                RequestBodyString += 'BILLTOSTREET='+getString(UsedQuote.BillingStreet__c) + '&';
                RequestBodyString += 'BILLTOCITY='+getString(UsedQuote.BillingCity__c) + '&';
                RequestBodyString += 'BILLTOSTATE='+getString(UsedQuote.BillingAccount__r.BillingStateCode) + '&';
                RequestBodyString += 'BILLTOZIP='+getString(UsedQuote.BillingZipPostalCode__c) + '&';
                RequestBodyString += 'BILLTOCOUNTRY='+getString(UsedQuote.BillingAccount__r.BillingCountryCode) + '&';

                //RequestBodyString += 'SHIPTOFIRSTNAME='+getString(UsedQuote.ShippingCity__c) + '&';
                //RequestBodyString += 'SHIPTOLASTNAME='+getString(UsedQuote.shiptolastname) + '&';
                RequestBodyString += 'SHIPTOSTREET='+getString(UsedQuote.ShippingStreet__c) + '&';
                RequestBodyString += 'SHIPTOCITY='+getString(UsedQuote.ShippingCity__c) + '&';
                RequestBodyString += 'SHIPTOSTATE='+getString(UsedQuote.ShippingStateProvince__c) + '&';
                RequestBodyString += 'SHIPTOZIP='+getString(UsedQuote.ShippingZipPostalCode__c) + '&';
                RequestBodyString += 'SHIPTOCOUNTRY='+getString(UsedQuote.ShippingCountry__c) + '&';

                RequestBodyString += 'CREATESECURETOKEN='+getString(RequestWrap.createsecuretoken) + '&';
                RequestBodyString += 'SECURETOKENID='+getString(RequestWrap.securetokenid) + '&';
                if(usedInvoice == null){
                    //invoice amount gets added later
                    RequestBodyString += 'AMT='+getString(UsedQuote.Quote_Total_With_Tax__c) + '&';
                }
            }

            system.debug('\n\nAMOUNT: ' + getString(UsedQuote.Quote_Total_With_Tax__c) + '\n\n');

            RequestBodyString += 'RETURNURL='+getString(RequestWrap.returnurl) + '&';
            RequestBodyString += 'CANCELURL='+getString(RequestWrap.cancelurl) + '&';
            RequestBodyString += 'ERRORURL='+getString(RequestWrap.errorurl) + '&';
            if(usedInvoice!= null) {
            RequestBodyString += 'AMT='+getString(usedInvoice.InvoiceAmount__c) + '&';
            RequestBodyString += 'COMMENT1='+getString(usedInvoice.InvoiceNumber__c)+'&'; //modified for S-445877
            }
            RequestBodyString += 'CUSTOM='+getString(UsedQuote.BillingAccount__r.Name)+'&';
            //RequestBodyString += 'COMMENT1='+getString(RequestWrap.comment1); //commented for S-445877

            system.debug('\n\n RequestBodyString: ' + RequestBodyString + '\n\n');

        }catch(Exception e){
            system.debug('\n\nError: ' + e + '\nTrace: ' + e.getStackTraceString() + '\n\n');
        }
    }
    /*
    private Integer getStringLength(String pString){
        return pString == null ? 0 : pString.length();
    }*/

    private String getString(Object pString){
        return pString == null ? '' : String.valueOf(pString);
    }

    public class RequestHeader{
        public String partner;
        public String vendor;
        public String user;
        public String pwd;
        public String trxtype;
        public String createsecuretoken;
        public String securetokenid;
        public String returnurl;
        public String cancelurl;
        public String errorurl;
        public String comment1;
        public String tender;
        public String acct;
    }

    public class PaypalResult{
        public String Result;
        public String RespMsg;
        public String SecureToken;
        public String SecureTokenID;
        public String Mode;
        public String RedirectURL;
        public String PNREF;

        public String PaypalURL {get{
            if(SecureToken != null && SecureToken != ''){
                //return RedirectURL + '?SECURETOKEN=' + SecureToken + '&SECURETOKENID=' + SecureTokenID + '&MODE=' + Mode;
                /*Task T-417606 : Redirect URL , Making it static to point it to paypalRedirect page*/
                System.debug('----SecureToken ' + SecureToken);
                System.debug('----SecureTokenID ' + SecureTokenID);
                return '/apex/paypalRedirect' + '?SECURETOKEN=' + SecureToken + '&SECURETOKENID=' + SecureTokenID ;
            }
            return '';
        }}
    }

    public void init(Order__c pOrder, State pCurrentState){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','init');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        if(pOrder != null){
            UsedOrder = pOrder;
            init(pOrder.QuoteProposal__c, pCurrentState);
        }else{
            throw BaseApplicationException.NewException(METHODNAME, 'Order param can not be null', 'Order param can not be null');
        }
    }

    public void init(Invoices__c pInvoice, State pCurrentState){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','init');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        if(pInvoice != null){
            isInvoice = true;
            init(pInvoice.Order__r.QuoteProposal__c, pCurrentState);
            usedInvoice = pInvoice;
        }else{
            throw BaseApplicationException.NewException(METHODNAME, 'Invoices param can not be null', 'Invoices  param can not be null');
        }
    }

    public void init(Object RecordID, State pCurrentState){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','init');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        getSecureTokenID();
        getRequiredParamMap();

        String propQuery = '';
        propQuery += 'SELECT Id, Name, OwnerId,';

        if(pCurrentState == State.INIT){
            propQuery += 'BillContact__r.FirstName, ';
            propQuery += 'BillContact__r.LastName, ';
            propQuery += 'BillingStreet__c, ';
            propQuery += 'BillingCity__c, ';
            propQuery += 'BillingStateProvince__c, ';
            propQuery += 'BillingZipPostalCode__c, ';
            propQuery += 'BillingCountry__c, ';
            propQuery += 'BillingAccount__r.BillingCountryCode, ';
            propQuery += 'BillingAccount__r.BillingStateCode, ';
            propQuery += 'BillingAccount__r.Name,';

            propQuery += 'ShippingCity__c,';
            propQuery += 'ShippingCountry__c,';
            propQuery += 'ShippingStateProvince__c,';
            propQuery += 'ShippingStreet__c,';
            propQuery += 'ShippingZipPostalCode__c,';

            propQuery += 'CurrencyIsoCode,';
            propQuery += 'Quote_Total_With_Tax__c,';
            propQuery += 'APTTS_Tax_Total__c,';
            propQuery += 'AvalaraResponseCode__c, ';
            propQuery += 'PaypalSecureTokenID__c, ';
            propQuery += 'Apttus_Proposal__Opportunity__c ';

            propQuery += 'FROM Apttus_Proposal__Proposal__c ';

            if(isInvoice){
                propQuery += 'WHERE Id = \''+RecordID+'\'';
            } else {
                propQuery += 'WHERE Id = \''+DecodeHashedID(RecordID)+'\'';
               }
        }else if(pCurrentState == State.PROCESS || pCurrentState == PaypalModel.State.ERROR){
            for(String key : ParamToTargetField.keySet()){
                if (key != 'BILLTOLASTNAME'){
                    //Don't want to add PaypalBillToName__c twice
                    propQuery += ParamToTargetField.get(key) + ',';
                }
            }
            if(IsCapture || IsRefund){
                propQuery += 'Quote_Total_With_Tax__c, APTTS_Tax_Total__c, ';
            }
            propQuery += 'Apttus_Proposal__Opportunity__c ';

            propQuery += ' FROM Apttus_Proposal__Proposal__c ';
            //if(IsCapture || IsRefund){
                propQuery += 'WHERE Id = \''+RecordID+'\'';
            //}else{
                propQuery += 'OR PaypalSecureTokenID__c = \''+RecordID+'\'';
            //}
        }else{
            system.debug('\n\nError: Can not proceed on getting proposal record.\n\n');
            return;
        }

        system.debug('\n\nProposal Query: ' + propQuery + '\n\n');
        Apttus_Proposal__Proposal__c[] quoteList = Database.query(propQuery);

        if(quoteList == null || quoteList.size() == 0){
            system.debug('\n\nNo extracted quote from: ' + RecordID + '\n\n');
            return;
        }

        UsedQuote = quoteList[0];
    }

    private Datetime getPaypalTransactionTime(String pStr){
        Datetime output = system.now();
        if(pStr == null) return output;
        try{
            String[] wholeDate = pStr.split(' ');
            String[] dv = wholeDate[0].split('-');

            Integer yr = Integer.valueOf(dv[0]);
            Integer mt = Integer.valueOf(dv[1]);
            Integer dy = Integer.valueOf(dv[2]);

            String[] tv = wholeDate[1].split(':');
            Integer hr = Integer.valueOf(tv[0]);
            Integer mn = Integer.valueOf(tv[1]);
            Integer sc = Integer.valueOf(tv[2]);

            output = Datetime.newInstance(yr, mt, dy, hr, mn, sc);

            system.debug('\n\nRaw Time: ' + pStr + '\nParsed: ' + output + '\n\n');
        }catch(Exception e){
            system.debug('\n\nProblem occured parsing paypal transaction time: '+e+'\n\n');
        }
        return output;
    }

    public void processRefundReturnedData(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','processRefundReturnedData');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        UsedOrder.PaypalRefundReferenceNumber__c = Result.PNREF;
        UsedOrder.PaypalRefundResultCode__c = Result.Result;
        UsedOrder.PaypalRefundResultMessage__c = Result.RespMsg;
        update UsedOrder;
    }

    public void processCaptureReturnedData(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','processCaptureReturnedData');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        system.debug('\n\nCapture Result: ' + Result + '\n\n');

        PaypalModel.OrderCreator oc = new PaypalModel.OrderCreator(UsedQuote);
        oc.getOrderByQuote();
        oc.updateOrderFromCaptureTransaction(Result);
    }

    public void getRequiredParamMap(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','getRequiredParamMap');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        //quote/proposal
        ParamToTargetField = new map<String, String>();
        ParamToTargetField.put('PNREF', 'PaypalReferenceNumber__c');
        ParamToTargetField.put('TRANSTIME', 'PaypalTransactionTime__c');
        ParamToTargetField.put('RESPMSG', 'PaypalResultMessage__c');
        ParamToTargetField.put('RESULT', 'PaypalResultCode__c');
        ParamToTargetField.put('SECURETOKENID', 'PaypalSecureTokenID__c');
        ParamToTargetField.put('CARDTYPE', 'PaypalCardType__c');
        ParamToTargetField.put('BILLTOFIRSTNAME', 'PaypalBillToName__c');
        ParamToTargetField.put('BILLTOLASTNAME', 'PaypalBillToName__c');
        //Invoice
        ParamToTargetFieldInvoice = new map<String, String>();
        ParamToTargetFieldInvoice.put('PNREF', 'Paypal_Reference_Number__c');
        ParamToTargetFieldInvoice.put('TRANSTIME', 'PaypalTransactionTime__c');
        ParamToTargetFieldInvoice.put('RESPMSG', 'Paypal_Result_Message__c');
        ParamToTargetFieldInvoice.put('RESULT', 'Paypal_Result_Code__c');
        ParamToTargetFieldInvoice.put('SECURETOKENID', 'Paypal_Secure_Token_ID__c');
        ParamToTargetFieldInvoice.put('CARDTYPE', 'Paypalcardtype__c');
        ParamToTargetFieldInvoice.put('BILLTOFIRSTNAME', 'PaypalBillToName__c');
        ParamToTargetFieldInvoice.put('BILLTOLASTNAME', 'PaypalBillToName__c');
        String msg = '';
        ReturnedParam = new map<String, String>();
        if(ApexPages.currentPage() != null){
            for(String key : ApexPages.currentPage().getParameters().keySet()){
                if(ParamToTargetField.containsKey(key)){
                    msg += '\n' + key + ' = ' + ApexPages.currentPage().getParameters().get(key);
                    ReturnedParam.put(key, ApexPages.currentPage().getParameters().get(key));
                }
            }
        }
        system.debug('\n\nCHECK\n\n' + msg + '\n\n');
        system.debug('<<ParamToTargetField>>'+ParamToTargetField);
        system.debug('<<ReturnedParam>>'+ReturnedParam);
    }

    public void processAuthReturnedData(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','processAuthReturnedData');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        try{
            Boolean hasChange = false;
            String cardType='';
            String billName='';
            system.debug('<<ParamToTargetFieldkeySet()>>'+ParamToTargetField.keySet());
            system.debug('<<ReturnedParam>>'+ReturnedParam);
            for(String field : ParamToTargetField.keySet()){
                if(ReturnedParam.containsKey(field)){
                    if(usedInvoice == null){
                        //quote/proposal
                        if(field == 'TRANSTIME'){
                            UsedQuote.put(ParamToTargetField.get(field), getPaypalTransactionTime(ReturnedParam.get(field)));
                        } else if(field == 'BILLTOFIRSTNAME'){
                            billName=ReturnedParam.get('BILLTOFIRSTNAME') + ' ' + ReturnedParam.get('BILLTOLASTNAME');
                            UsedQuote.put(ParamToTargetField.get(field), billName);
                        } else if(field == 'BILLTOLASTNAME'){
                            //do nothing, combined with first name
                        } else if (field == 'CARDTYPE'){
                            if('0' == ReturnedParam.get('CARDTYPE')) {
                                cardType = 'Visa';
                            } else if('1' == ReturnedParam.get('CARDTYPE')) {
                                cardType = 'MasterCard';
                            } else if('2' == ReturnedParam.get('CARDTYPE')) {
                                cardType = 'Discover';
                            } else if('3' == ReturnedParam.get('CARDTYPE')) {
                                cardType = 'American Express';
                            } else if('4' == ReturnedParam.get('CARDTYPE')) {
                                cardType = 'Diner’s Club';
                            } else if('5' == ReturnedParam.get('CARDTYPE')) {
                                cardType = 'JCB';
                            } else {
                                cardType = ReturnedParam.get('CARDTYPE');
                            }
                            UsedQuote.put(ParamToTargetField.get(field), cardType);
                        }else{
                            UsedQuote.put(ParamToTargetField.get(field), ReturnedParam.get(field));
                        }
                    } else {
                        //Invoice
                        if(field == 'TRANSTIME'){
                            usedInvoice.put(ParamToTargetFieldInvoice.get(field), getPaypalTransactionTime(ReturnedParam.get(field)));
                        } else if(field == 'BILLTOFIRSTNAME'){
                            billName=ReturnedParam.get('BILLTOFIRSTNAME') + ' ' + ReturnedParam.get('BILLTOLASTNAME');
                            usedInvoice.put(ParamToTargetFieldInvoice.get(field), billName);
                        } else if(field == 'BILLTOLASTNAME'){
                            //do nothing, combined with first name
                        } else if (field == 'CARDTYPE'){
                            if('0' == ReturnedParam.get('CARDTYPE')) {
                                cardType = 'Visa';
                            } else if('1' == ReturnedParam.get('CARDTYPE')) {
                                cardType = 'MasterCard';
                            } else if('2' == ReturnedParam.get('CARDTYPE')) {
                                cardType = 'Discover';
                            } else if('3' == ReturnedParam.get('CARDTYPE')) {
                                cardType = 'American Express';
                            } else if('4' == ReturnedParam.get('CARDTYPE')) {
                                cardType = 'Diner’s Club';
                            } else if('5' == ReturnedParam.get('CARDTYPE')) {
                                cardType = 'JCB';
                            } else {
                                cardType = ReturnedParam.get('CARDTYPE');
                            }
                            usedInvoice.put(ParamToTargetFieldInvoice.get(field), cardType);
                        }else{
                            usedInvoice.put(ParamToTargetFieldInvoice.get(field), ReturnedParam.get(field));
                        }
                    }
                    hasChange = true;
                }
                system.debug('\n\nField: ' +field + ' = ' + hasChange +'\n\n');
            }

            if(hasChange && usedInvoice == null){
                update UsedQuote;

                PaypalModel.OrderCreator oc = new PaypalModel.OrderCreator(UsedQuote);
                oc.getOrderByQuote();
                oc.updateOrderFromAuthTransaction();

                system.debug('\n\n Quote: ' + UsedQuote + '\n\n');

                //Change Start : Gaurav gupta : I-201251 (Remove Order Creation logic)

                /*if(oc.quotesOrders == null || oc.quotesOrders.isEmpty()){
                    if(UsedQuote.Apttus_Proposal__Opportunity__c != null){
                        oc.triggerOpportunityOrderCreation(UsedQuote.Apttus_Proposal__Opportunity__c);
                    }
                }*/

                //Change End: Gaurav gupta : I-201251 (Remove Order Creation logic)

                if(UsedQuote.PaypalResultCode__c == '0'){
                    try{
                        oc.SendOrderToSite();

                        // TKOM S-470329: 'Credit Card Approved' cases should no longer be created.
                        /*Case approvedCase = new Case();
                        approvedCase .SystemGenerated__c = True;
                        approvedCase.OwnerId = UsedQuote.OwnerId;
                        approvedCase.Subject = 'Credit Card Approved';
                        approvedCase.Proposal_ID__c = UsedQuote.Id;
                        approvedCase.ContactId = UsedQuote.BillContact__c;
                        insert approvedCase; */
                    }catch(Exception e){
                        // TKOM S-470329: changed debug message from 'Case creation' to 'Order creation'
                        system.debug('\n\nOrder creation when credit card is approved failed.\n\nError: ' + e + '\nTrace: ' + e.getStackTraceString());
                    }
                    Message = '<p style="text-align: center;">Monster appreciates your business!<br />An Authorization receipt will be sent<br />shortly via email. THANK YOU!!!</p>';
                }else{
                    Task newTask = new Task();
                    newTask.ActivityDate = system.today();
                    newTask.OwnerId = UsedQuote.OwnerId;
                    newTask.Subject = 'Call';
                    newTask.WhatId = UsedQuote.Id;
                    newTask.WhoId = UsedQuote.BillContact__c;
                    newTask.Description = 'Incomplete/Denied Paypal transaction.\nPlease call the customer.';
                    insert newTask;

                    Message = '<p style="text-align: center;">Unsuccessfull transaction.<br />Processing result: '+UsedQuote.PaypalResultMessage__c+'<br /><br />Monster.com customer service rep will be reaching out shortly.</p>';
                }
            } else if(hasChange && usedInvoice != null){
                update usedInvoice;
                Message = '<p style="text-align: center;">Monster appreciates your business!<br />An Authorization receipt will be sent<br />shortly via email. THANK YOU!!!</p>';
            }

            //remove me: for debugging only
        }catch(Exception e){
            system.debug('\n\nError on processReturnedData: ' + e + '\n\n');
            Message = 'An error occured while processing your transaction.';
        }
    }

   /* public void getRequiredParamMap(){
        //quote/proposal
        ParamToTargetField = new map<String, String>();
        ParamToTargetField.put('PNREF', 'PaypalReferenceNumber__c');
        ParamToTargetField.put('TRANSTIME', 'PaypalTransactionTime__c');
        ParamToTargetField.put('RESPMSG', 'PaypalResultMessage__c');
        ParamToTargetField.put('RESULT', 'PaypalResultCode__c');
        ParamToTargetField.put('SECURETOKENID', 'PaypalSecureTokenID__c');
        ParamToTargetField.put('CARDTYPE', 'PaypalCardType__c');
        ParamToTargetField.put('BILLTOFIRSTNAME', 'PaypalBillToName__c');
        ParamToTargetField.put('BILLTOLASTNAME', 'PaypalBillToName__c');
        //Invoice
        ParamToTargetFieldInvoice = new map<String, String>();
        ParamToTargetFieldInvoice.put('PNREF', 'Paypal_Reference_Number__c');
        ParamToTargetFieldInvoice.put('TRANSTIME', 'PaypalTransactionTime__c');
        ParamToTargetFieldInvoice.put('RESPMSG', 'Paypal_Result_Message__c');
        ParamToTargetFieldInvoice.put('RESULT', 'Paypal_Result_Code__c');
        ParamToTargetFieldInvoice.put('SECURETOKENID', 'Paypal_Secure_Token_ID__c');
        ParamToTargetFieldInvoice.put('CARDTYPE', 'Paypalcardtype__c');
        ParamToTargetFieldInvoice.put('BILLTOFIRSTNAME', 'PaypalBillToName__c');
        ParamToTargetFieldInvoice.put('BILLTOLASTNAME', 'PaypalBillToName__c');
        String msg = '';
        ReturnedParam = new map<String, String>();
        if(ApexPages.currentPage() != null){
            for(String key : ApexPages.currentPage().getParameters().keySet()){
                if(ParamToTargetField.containsKey(key)){
                    msg += '\n' + key + ' = ' + ApexPages.currentPage().getParameters().get(key);
                    ReturnedParam.put(key, ApexPages.currentPage().getParameters().get(key));
                }
            }
        }
        system.debug('\n\nCHECK\n\n' + msg + '\n\n');
    }
    */
    public String getPaypalIntegrationAccount() {

        String sellingCountry = null;
        String customSettingRecord = null;

        if(isInvoice) {

            for(Invoices__c invoice : [Select Id,CurrencyIsoCode,Order__r.Quote_Selling_Country__c  from Invoices__c
                                                         Where Id = :objectId and Order__r.Quote_Selling_Country__c != null limit 1]) {

                sellingCountry = invoice.Order__r.Quote_Selling_Country__c;
                if(sellingCountry  == 'United States' && invoice.CurrencyIsoCode == 'USD'){
                    customSettingRecord = 'Invoice - Paypal US - USD';
                }
                else if(sellingCountry  == 'Canada' && invoice.CurrencyIsoCode == 'CAD'){
                    customSettingRecord = 'Invoice - Paypal CA - CAD';
                }
                else if(sellingCountry  == 'Canada' && invoice.CurrencyIsoCode == 'USD'){
                    customSettingRecord = 'Invoice - Paypal CA - USD';
                }
            }

            //customSettingRecord = 'Invoice - Paypal US - USD';
            //customSettingRecord = 'Invoice - Paypal CA - CAD';
            //customSettingRecord = 'Invoice - Paypal CA - USD';


        }
        else {
            for(Apttus_Proposal__Proposal__c quoteRec : [Select Id, Selling_Country__c,CurrencyRef__c from Apttus_Proposal__Proposal__c
                                                         Where Id = :objectId and Selling_Country__c != null limit 1]) {
                sellingCountry = quoteRec.Selling_Country__c;
                if(sellingCountry  == 'United States'){
                    customSettingRecord = 'Paypal US';
                }
                else if(sellingCountry  == 'Canada' && quoteRec.CurrencyRef__c == 'CAD'){
                    customSettingRecord = 'Paypal CA - CAD';
                }
                else if(sellingCountry  == 'Canada' && quoteRec.CurrencyRef__c == 'USD'){
                    customSettingRecord = 'Paypal CA - USD';
                }
            }
        }

        if(customSettingRecord == null) {
            if(isInvoice) {
                customSettingRecord = 'Invoice - Paypal US - USD';
            }
            else {
                customSettingRecord = 'Paypal US';
            }
        }

        return customSettingRecord;

    }

    public PaypalModel.RequestHeader getRequestHeader(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','getRequestHeader');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        String paypalIntegrationRecord = getPaypalIntegrationAccount();
        Utility.IntegrationSetting setting = Utility.getIntegrationSetting(paypalIntegrationRecord);
        PaypalModel.RequestHeader req = new PaypalModel.RequestHeader();

        Endpoint = setting.Endpoint;//https://pilot-payflowpro.paypal.com/
        req.partner = setting.PaypalPartner;
        req.vendor = setting.PaypalVendor;
        req.user = setting.Username;
        req.pwd = setting.Password;
        system.debug('\n\nPartner: '+req.partner+'\n\n');
        //req.trxtype = 'A';
        req.createsecuretoken = 'Y';

        if(ApexPages.currentPage() == null){
            system.debug('\n\nUnable to get current page reference: Not in VF page context.\n\n');
        }else{
            req.returnurl = 'https://' + ApexPages.currentPage().getHeaders().get('Host') + '/cc?status=success';
            req.cancelurl = 'https://' + ApexPages.currentPage().getHeaders().get('Host') + '/cc?status=cancel';
            req.errorurl = 'https://' + ApexPages.currentPage().getHeaders().get('Host') + '/cc?status=error';
            system.debug('\n\nURL: ' + ApexPages.currentPage().getHeaders().get('Host') + '\n\n');
        }
        //code commented for S-445877
        /*if(setting.PaypalMode == 'TEST'){
            system.debug('Payflowlink Test');
            req.comment1 = 'Payflowlink Test';
        }else{
            req.comment1 = 'Payflowlink Live Transaction';
            system.debug('Payflowlink Live Transaction');
        }*/

        Result = new PaypalResult();
        Result.Mode = setting.PaypalMode;
        Result.RedirectURL = setting.PaypalRedirectURL;
        system.debug('@@@@@'+Result);
        return req;

    }

    public String getSecureTokenID(){
        SecureTokenID = String.valueOf(Math.abs(system.Crypto.getRandomInteger())) + String.valueOf(Math.abs(system.Crypto.getRandomInteger()));
        RequestWrap.securetokenid = SecureTokenID;
        return SecureTokenID;
    }



/**********************************************************************************************
** @author : Cloud Sherpas Inc.
** @date : 11/07/2014
** @description : Class that calls the Order Creation processes used by opportunity trigger.
**                  This class is used when the order creation is triggered by Paypal success call.
**********************************************************************************************/
    public without sharing class OrderCreator{
        final String CLASSNAME = '\n\n**** PaypalMode.OrderCreator.METHODNAME()';
        private Map<Id,String> OpportunityIDAndAllocationBasis{get;set;}
        private Id QuoteId;
        private OrderGeneration orderHelper;
        private String OrderStatus;
        public Order__c[] quotesOrders {get; private set;}
        private Apttus_Proposal__Proposal__c UsedQuote;

        public OrderCreator(Apttus_Proposal__Proposal__c pQuote){

            final string METHODNAME = CLASSNAME.replace('METHODNAME','Constructor');
            system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

            QuoteId = pQuote.Id;
            UsedQuote = pQuote;
            if(pQuote.PaypalResultCode__c == '0'){
                //JHF Appirio I-196924 3/24/16 change to Paid in Full
                OrderStatus = 'Paid in Full';
            }else{
                OrderStatus = 'Pending Processing';
            }

            // instantiate new order generator
            orderHelper = OrderGeneration.NewOrderGeneration();
        }

        public void SendOrderToSite(){

            final string METHODNAME = CLASSNAME.replace('METHODNAME','SendOrderToSite');
            system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
			system.debug('<<quotesOrders>>'+quotesOrders);
            if(quotesOrders != null && !quotesOrders.isEmpty()){
                system.debug('\n\nBefore calling IWS: ' + quotesOrders[0].Id + '\n\n');
                if(quotesOrders[0].OrderStatus__c != 'Sent To Verification'){
                    system.debug('\n\nOrder is "Pending Processing". Not valid for IWS.\n\n');
                    return;
                }
                OrderTriggerHandler.ExecuteTriggers = false;
                OrderLineItemTriggerHandler.ExecuteTriggers  = false;
                OpportunityTriggerHandler.SKIP_OPPORTUNITY_UPDATE = true;

                Opportunity parentOpp = new Opportunity();
                parentOpp.Skip_Stage_Validation__c = True;
                parentOpp.Id = UsedQuote.Apttus_Proposal__Opportunity__c;
                parentOpp.StageName = 'Stage 4 - Won';
                update parentOpp;

                try{
                    BizAppsSiteModel.VerifyOrder(quotesOrders[0].Id, quotesOrders[0].is_credit__c);
                }catch(Exception e){
                    system.debug('\n\nIWS Error: ' + e + '\n\n');
                }
            }
        }

        public Order__c[] getOrderByQuote(){

            final string METHODNAME = CLASSNAME.replace('METHODNAME','getOrderByQuote');
            system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

            Id StandardOrderRT = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Standard');
            String orderQuery = '';
                orderQuery += 'SELECT Id, ';
                orderQuery += 'Account__c, ';
                    orderQuery += 'PaypalCaptureReferenceNumber__c, ';
                    orderQuery += 'PaypalCaptureResultMessage__c, ';
                    orderQuery += 'OrderStatus__c, ';
                    orderQuery += 'PaypalCaptureResultCode__c ';
                    orderQuery += 'FROM Order__c  ';
                    orderQuery += 'WHERE QuoteProposal__c = \'' + QuoteId + '\' ';
                    orderQuery += 'AND RecordTypeId = \''+StandardOrderRT+'\' ';

                quotesOrders = Database.query(orderQuery);

            //system.assert(False,'quotesOrders' + quotesOrders);
                system.debug('\n\nExisting Orders: ' + quotesOrders + '\n\nOrderQuery: ' + orderQuery + '\n\n');
				system.debug('<<quotesOrders>>'+quotesOrders);
                return quotesOrders;
        }

        public void updateOrderFromAuthTransaction(){

            final string METHODNAME = CLASSNAME.replace('METHODNAME','updateOrderFromAuthTransaction');
            system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
            //system.assert(False,'quotesOrders' + quotesOrders);
            if(quotesOrders != null && !quotesOrders.isEmpty()){
                for(Order__c o : quotesOrders){
                    o.OrderStatus__c = OrderStatus;
                    o.Payment_Method_text__c = 'Credit Card';
                    o.Payment_Term_text__c = 'Immediate';
                    o.Payment_Frequency__c= 'Single Payment';

                }

                OrderTriggerHandler.ExecuteTriggers = false;
                update quotesOrders;

                //added for I-225488, we want to fire triggers for 'Paid In Full'
                //otherwise there is a chance it could not send through the IWS integration (BizAppsSiteModel)
                OrderTriggerHandler.ExecuteTriggers = true;
                for(Order__c o : quotesOrders){
                    if(o.OrderStatus__c == 'Paid in Full'){
                        System.debug('----Calling VerifyOrder Paid in Full');
                        BizAppsSiteModel.VerifyOrder(o.Id,false);
                    }
                }
            }
        }

        public void updateOrderFromCaptureTransaction(PaypalResult pResult){

            final string METHODNAME = CLASSNAME.replace('METHODNAME','updateOrderFromCaptureTransaction');
            system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

            for(Order__c o : quotesOrders){
                o.PaypalCaptureReferenceNumber__c = pResult.PNREF;
                o.PaypalCaptureResultMessage__c = pResult.RespMsg;
                o.PaypalCaptureResultCode__c = pResult.Result;
            }
            OrderTriggerHandler.ExecuteTriggers = false;
            update quotesOrders;
        }
        /* Not used anywhere
        public void updateOrderByQuote(){

            final string METHODNAME = CLASSNAME.replace('METHODNAME','updateOrderByQuote');
            system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
            /*for(Order__c o : quotesOrders){
                o.PaypalReferenceNumber__c = UsedQuote.PaypalReferenceNumber__c;
                o.PaypalTransactionTime__c = UsedQuote.PaypalTransactionTime__c;
                o.PaypalResultMessage__c = UsedQuote.PaypalResultMessage__c;
                o.PaypalResultCode__c = UsedQuote.PaypalResultCode__c;
                o.PaypalSecureTokenID__c = UsedQuote.PaypalSecureTokenID__c;
            }* /
            update quotesOrders;
        }*/

        public void triggerOpportunityOrderCreation(Id pOppId){

            final string METHODNAME = CLASSNAME.replace('METHODNAME','triggerOpportunityOrderCreation');
            system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

            Opportunity[] parentOppList = [SELECT Id, OrderCreated__c, AccountId, SecondarySalesRep__c, OwnerId FROM Opportunity WHERE Id = :pOppId];

            if(parentOppList != null && !parentOppList.isEmpty()){
                parentOppList[0].OrderCreated__c = true;

                OpportunityTriggerHandler.SKIP_OPPORTUNITY_UPDATE = true;
                update parentOppList[0];
                OpportunityTriggerHandler.SKIP_OPPORTUNITY_UPDATE = false;

                map<Id, Opportunity> oldMap = new map<Id, Opportunity>();
                oldMap.put(parentOppList[0].Id, new Opportunity(Id = parentOppList[0].Id, AccountId = parentOppList[0].AccountId, OrderCreated__c = false));

                //SetAllocationSplitsForPrimaryAndSecondarySalesRep(oldMap, oldMap);
                orderHelper.createOrder(parentOppList, oldMap);
            }
        }
    }
}