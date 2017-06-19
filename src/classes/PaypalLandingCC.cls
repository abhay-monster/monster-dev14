public without sharing class PaypalLandingCC {
    final String CLASSNAME = '\n\n**** PaypalLandingCC.METHODNAME()';

    private String RecordID;
    public String returnStatus{get; set;}
    private PaypalModel Connection;
    public String[] AjaxResult  {get; set;}
    public String quoteIdorInvoiceId {get; set;}
    private PaypalModel.State CurrentState;
    private map<String, String> param;
    private Order__c order {get; set;}
    private Boolean preventRedirect {get; set;}
    /*private String paypalRefNo ;
    private String resultCode ;
    private String resultMessage ;
    private String transactionTime;
    private String cardType;
    private String billName;*/
    private String isInvoice;
    private map<String, String> ReturnedParam;
    private map<String, String> ParamToTargetField;
    public PaypalLandingCC(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','PaypalLandingCC');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            RecordID = ApexPages.currentPage().getParameters().get('recordID');
            returnStatus = ApexPages.currentPage().getParameters().get('status');
            system.debug('&&test&&' + returnStatus + +RecordID);
            AjaxResult = new String[]{};
            //Connection = new PaypalModel();
            getRequiredParamMap();
            system.debug('Param Map: ' + ReturnedParam);
            quoteIdorInvoiceId = ApexPages.currentPage().getParameters().get('USER1');
            if(quoteIdorInvoiceId.left(3) == Schema.Sobjecttype.Invoices__c.getKeyPrefix()){
                isInvoice = quoteIdorInvoiceId;
            } else {
                isInvoice = ApexPages.currentPage().getParameters().get('IS_INVOICE');
            }
            system.debug('quoteIdorInvoiceId=' + quoteIdorInvoiceId);
            preventRedirect = false;
            /*paypalRefNo = ReturnedParam.get('PNREF');
            resultCode= ReturnedParam.get('RESULT');
            resultMessage = ReturnedParam.get('RESPMSG');
            transactionTime = ReturnedParam.get('TRANSTIME');
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
            If(ReturnedParam.get('BILLTOFIRSTNAME')!=null){
                billName = ReturnedParam.get('BILLTOFIRSTNAME')+' ';
                }
            If(ReturnedParam.get('BILLTOLASTNAME')!=null)
                billName = billName + ReturnedParam.get('BILLTOLASTNAME');
            */
            system.debug('Headers: ' + ApexPages.currentPage().getHeaders());
            if(RecordID != null){ 
                CurrentState = PaypalModel.State.INIT;
                system.debug('INITializing');
            }else if(returnStatus != null && returnStatus == 'success' && ApexPages.currentPage().getParameters().containsKey('SECURETOKENID') ||
                ReturnedParam.get('RESPMSG') != null){
                 system.debug('inside of return status check');
               /* if(!ApexPages.currentPage().getHeaders().containsKey('Origin') || ApexPages.currentPage().getHeaders().get('Origin') != Utility.getWebServiceEnpoint('PaypalRedirectURL')){
                    CurrentState = PaypalModel.State.ERROR;
                     system.debug('22222');
                }else{*/
                    if( ApexPages.currentPage().getParameters().get('USER1') == null){
                        RecordID = ReturnedParam.get('USER1');
                    } else {
                        RecordID = ApexPages.currentPage().getParameters().get('USER1');
                    }

                    CurrentState = PaypalModel.State.PROCESS;
                    system.debug('Current State = ' + CurrentState + ' Record Id = ' + RecordID);
                //}
            }else{
                RecordID = ApexPages.currentPage().getParameters().get('SECURETOKENID');
                CurrentState = PaypalModel.State.ERROR;
            }

            Id propId = null;
            system.debug('Id? ' + RecordId);
            if(RecordID != null && RecordId.length() > 15 && quoteIdorInvoiceId == null) {
                 propId = (Id) DecodeHashedID(RecordID);
            } else {
                if(quoteIdorInvoiceId != null){
                    propId = quoteIdorInvoiceId;
                } else {
                    propId = RecordID;    
                }
            }

            Connection = new PaypalModel(propId);

        }catch(Exception e){
            system.debug('\n\nError: ' + e + '\nTrace: ' + e.getStackTraceString() + '\n\n');
        }


        
    }

    public String DecodeHashedID(Object hashed){
        return Schema.Sobjecttype.Apttus_Proposal__Proposal__c.getKeyPrefix() +
                    String.valueOf(hashed).right(23).left(8).right(5)  +
                    String.valueOf(hashed).left(10).right(7);
    }

    public void getRequiredParamMap(){
        ParamToTargetField = new map<String, String>();
        ParamToTargetField.put('PNREF', 'PaypalReferenceNumber__c');
        ParamToTargetField.put('TRANSTIME', 'PaypalTransactionTime__c');
        ParamToTargetField.put('RESPMSG', 'PaypalResultMessage__c');
        ParamToTargetField.put('RESULT', 'PaypalResultCode__c');
        ParamToTargetField.put('SECURETOKENID', 'PaypalSecureTokenID__c');
        ParamToTargetField.put('CARDTYPE', 'PaypalCardType__c');
        ParamToTargetField.put('BILLTOFIRSTNAME', 'PaypalBillToName__c');
        ParamToTargetField.put('BILLTOLASTNAME', 'PaypalBillToName__c');
        ParamToTargetField.put('USER1','ID');
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


    public PageReference init(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','init');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        system.debug('TESTING!!! ' + ApexPages.currentPage().getParameters());
        if(RecordID == null || CurrentState != PaypalModel.State.INIT){
            system.debug('\n\nNo Avalara Record to process.\n\n');
            return null;
        }

        
        try{
            system.debug('^^^ isInvoice='+isInvoice +', Id.valueOf(Connection.DecodeHashedID(RecordID))='+Id.valueOf(Connection.DecodeHashedID(RecordID)));
            if(isInvoice == null){
                Id propId = (Id)Connection.DecodeHashedID(RecordID);
                Id orderId = getRelatedOrder(propId);
                //if we don't have a order Id then we call avalara using the proposal
                //AvalaraModel.IsToCommit = 'true';
                AvalaraModel.IsToCommit = 'false';
                if(orderId == null){
                    AvalaraModel.ProposalStartTaxRateProcessing(new set<Id>{propId});

                } else {
                    //if we do have an order Id then we mark this as comitted - ignore the quote/proposal
                    AvalaraModel.OrderStartTaxRateProcessing(new set<Id>{orderId});
                }
                //AvalaraModel.IsToCommit = 'false';
                
            }
        }catch(Exception e){
            system.debug('\n\nError: ' + e + '\nTrace: ' + e.getStackTraceString() + '\n\n');
            AjaxResult.add('An internal error occured.');
        }
        return null;
    }


    public String getMessage(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','getMessage');

        if(!AjaxResult.isEmpty()){
            String str = '';
            for(String s : AjaxResult){
                str += s + '<br />';
            }
            return str;
        }

        if(CurrentState == PaypalModel.State.INIT){
            if(Connection.Message != null && Connection.Message != ''){
                return Connection.Message;
            }else{
                if(order!= null && order.OrderStatus__c != 'Open' && order.OrderStatus__c != 'Pending Processing'){
                    preventRedirect = true;
                    return '<p style="text-align: center;">This Paypal link is no longer valid. The Quote has already been processed and will be invoiced. You may pay the invoice by credit card by calling Monster Customer Service at 1-800-MONSTER</p>';
                }
                else return '<p style="text-align: center;">Your patience is appreciated while redirecting you to a secure Paypal page.</p>';
            }
        }else if(CurrentState == PaypalModel.State.PROCESS || CurrentState == PaypalModel.State.ERROR){
            if(Connection != null && Connection.Message != null && Connection.Message != ''){
                return Connection.Message;
            }else{
                return '<p style="text-align: center;">Processing, please wait...</p>';
            }
        }
        return '<p style="text-align: center;">Sorry, an error occurred.</p>';
    }


    public PageReference GetRedirectURL(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','GetRedirectURL');
        returnStatus = ApexPages.currentPage().getParameters().get('status');
        System.debug('^^^ returnStatus=' + returnStatus);
        boolean isProcessAvalara = false;

        try{
            if(returnStatus == null){
                //Sylvester Agyen - 5/27/16 - Prevent paypal page if order exist on quote and is not in open or pending processing status
                if(preventRedirect){
                    return null;
                }

                system.debug('quoteIdorInvoiceId='+ quoteIdorInvoiceId);
                if(isInvoice != null){
                    List<Invoices__c> inv = [Select Order__c, order__r.QuoteProposal__c, UnpaidBalance__c,InvoiceNumber__c,InvoiceAmount__c,Name,order__r.Account__c FROM Invoices__c Where id =: quoteIdorInvoiceId ];
                    Connection.init(inv[0], CurrentState);
                } else {
                    Connection.getRequiredParamMap();
                    Connection.init(RecordID, CurrentState);
                    isProcessAvalara = true;
                }
                system.debug('^^^ RecordID=' + RecordID+', CurrentState=' + CurrentState +
                             ', Connection.Proposal=' + Connection.Proposal + ', Connection=' + Connection);
                if(Connection.Proposal != null){
                    system.debug('^^^ Connection.Proposal != null, so process based on CurrentState=' + CurrentState);
                    if( CurrentState == PaypalModel.State.INIT){
                        if((isProcessAvalara && Connection.Proposal.AvalaraResponseCode__c == 'Success') || !isProcessAvalara ){

                            system.debug('Sending to Paypal as isProcessAvalara=' + isProcessAvalara + ', AvalaraResponseCode__c=' + Connection.Proposal.AvalaraResponseCode__c);
                            PaypalModel.PaypalResult result = Connection.sendToPaypal();
                            system.debug('PaypalModel.PaypalResult=' + result);
                            if(result.Result == '0' && result.SecureTokenID == Connection.SecureTokenID && result.PaypalURL != ''){
                                system.debug('PayPalURL!!!!!!!!! ' + result.PaypalURL);
                                // to send the id of the record we need to append the user1 field.

                                //system.assert(false,quoteIdorInvoiceId);
                                return new PageReference(result.PaypalURL+'&USER1='+ quoteIdorInvoiceId);
                            }else{
                                AjaxResult.add('Paypal connection error.');
                            }
                        }else{
                            system.debug('\n\n Avalara processing failed. \n\n');
                            AjaxResult.add('Internal processing error.111');
                        }
                    }else if(CurrentState == PaypalModel.State.PROCESS || CurrentState == PaypalModel.State.ERROR){
                        Connection.processAuthReturnedData();                        
                         /* Make another callout as per T-525399
                            At the end of the process when we are updating the proposal with during the PaypalModel.ProcessAuthReturnedData()
                            method they want us to make another callout to avalara (now that the user has actually paid for the proposal) and 
                            they want us to make that callout with IsToCommit to be true.  
                            So we are only making the callout to avalara to commit the record once it has been paid for. */
      
                         try{
                                if(isInvoice == null){
                                    Id propId = (Id)Connection.DecodeHashedID(RecordID);
                                    Id orderId = getRelatedOrder(propId);
                                    AvalaraModel.IsToCommit = 'true';
                                    if(orderId == null){
                                        AvalaraModel.ProposalStartTaxRateProcessing(new set<Id>{propId});

                                    } else {
                                        AvalaraModel.OrderStartTaxRateProcessing(new set<Id>{orderId});
                                    }                                                 
                                }  
                            }catch(Exception e){
                                system.debug('\n\nError: ' + e + '\nTrace: ' + e.getStackTraceString() + '\n\n');
                                AjaxResult.add('An internal error occured.'); 
                            }
                    }
                }else{
                    AjaxResult.add('Internal processing error.222');
                }
            }

            if(String.isNotBlank(returnStatus)){
                if(returnStatus.contains('error')){
                    AjaxResult.add('There was an issue processing your payment, please reach out to your monster representative and provide the following: <br />');
                    AjaxResult.add('Paypal Reference Number: <b>' + ReturnedParam.get('PNREF') + '</b>');
                    AjaxResult.add('Response Message: <b>' + ReturnedParam.get('RESPMSG') + '</b>' );
                    AjaxResult.add('Response Code: <b>' + ReturnedParam.get('RESULT') + '</b>');
                }
            }

            /*Mar 9 2016 JFreese - It is believed that this is all old code which never gets hit; commenting out

            else {
                system.debug('^^^ Connection.Proposal != null, so process based on quoteIdorInvoiceId=' + quoteIdorInvoiceId);
                if(quoteIdorInvoiceId != null){
                    if(Invoices__c.sobjecttype.getDescribe().getKeyPrefix() == quoteIdorInvoiceId.substring(0,3)) {
                        system.debug('^^^ Process invoice');
                        Invoices__c inv = [Select Id FROM Invoices__c Where Id =:quoteIdorInvoiceId ];
                        inv.Paypal_Reference_Number__c= paypalRefNo;
                        inv.Paypal_Result_Code__c= resultCode;
                        inv.Paypal_Result_Message__c= resultMessage;
                        inv.PaypalTransactionTime__c= Datetime.valueOf(transactionTime);
                        inv.PaypalCardType__c = cardType;
                        inv.PaypalBillToName__c = billName;

                        update inv;
                    } else {
                        system.debug('^^^ Process quote');
                        Apttus_Proposal__Proposal__c quote = [SELECT Id FROM Apttus_Proposal__Proposal__c WHERE id =: quoteIdorInvoiceId];
                        quote.PaypalReferenceNumber__c = paypalRefNo;
                        quote.PaypalResultCode__c = resultCode;
                        quote.PaypalResultMessage__c = resultMessage;
                        system.debug(transactionTime+'!!!!!');
                        quote.PaypalTransactionTime__c = Datetime.valueOf(transactionTime);
                        quote.PaypalCardType__c = cardType;
                        quote.PaypalBillToName__c = billName;
                        system.debug(quote);

                        update quote;
                    }
                }
                if(returnStatus == 'success'){
                    AjaxResult.add('Transaction Successful! Your Transaction Id is '+ paypalRefNo +'. Please note down for future reference. ');
                }else{
                    AjaxResult.add('Transaction Failed! ERROR CODE:' +resultCode+' '+resultMessage );
                }
                //return new PageReference('https://monster--dev.cs21.my.salesforce.com/'+quoteIdorInvoiceId );
                return null;
            }*/
        }catch(Exception e){
            AjaxResult.add('Internal processing error.333');
            system.debug('\n\nError: ' + e + '\nTrace: ' + e.getStackTraceString() + '\n\n');
        }
        return null;
    }

    /* @Name: getRelatedOrderId
    *  @Author: Jeff L (Appirio)
    *  @Params: Id of a quote/Proposal
    *  @Returns: Id of an order
    *  @Description: This method will figure out if there is a related order
                    for this quote/proposal.  If so we need to mark the order
                    as committed - not the quote/proposal
    */
    private Id getRelatedOrder(Id proposalId){
        List<Order__c> orderList = [Select Id, OrderStatus__c From Order__c where QuoteProposal__c = :proposalId Limit 1];

        if(!orderList.isEmpty()){
            order = orderList[0];
            return orderList[0].Id;
        } else {
            return null;
        }
    }
}