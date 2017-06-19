/*
** @author : Cloud Sherpas Inc.
** @date : 06/11/2014
** @description : Credit Request trigger class to handle CRUD events.
** @story 0523
** @element E1643,E162
*/
public without sharing class CreditRequestTriggerHandler extends BaseTriggerHandler {

    final String CLASSNAME = '\n\n**** UserTriggerHandler.METHODNAME()';
    private integer BatchSize = 0;
     private static Integer RunCount = 0;
    //private boolean TriggerIsExecuting;
    private CreditRequestTriggerHelper helper;
    public static Boolean CreateOrdersAutomatically {get;set;} //JFreese Appirio 01/25/17 S-452628

/*
** @author : Cloud Sherpas Inc.
** @date : 06/11/2014
** @description : the class constructor method
** @paramaters : a Boolean value indicating if a trigger is executing or not, an Integer value indicating the number of records in the batch/list
** @returns : nothing
** @sample call : CreditRequestTriggerHandler handler = new CreditRequestTriggerHandler(Trigger.isExecuting, Trigger.size);
*/
    public CreditRequestTriggerHandler(boolean isExecuting, integer pTriggerSize){

        // trigger is executing
        TriggerIsExecuting = isExecuting;

        // set batch size
        BatchSize = pTriggerSize;

        // set current User profile
        //Profile currentUserProfile = [Select Name From Profile where Id = :UserInfo.getProfileId()];

        // intantiate new trigger helper
        helper = CreditRequestTriggerHelper.NewTriggerHelper();
        /*
            note - developer may want to create new or extent the base helper class specific to an sObject (i.e. AccountTriggerHelper)
        */
        CreateOrdersAutomatically = false;  //JFreese Appirio 01/25/17 S-452628
    }
/*
** @author : Cloud Sherpas Inc.
** @date : 03/07/2014
** @description :  this method handles the 'before insert' event for the trigger; it's purpose is to ...
** @paramaters : an array of Credit Request objects
** @returns : nothing
*/
    public void OnbeforeInsert(List<Credit_Request__c> cRequest){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                helper.populateManagerInfoOnCreditRequest(cRequest);
                //helper.populateManagersOnCreditRequest(cRequest);
            }

    }

    /* Jeff L commenting out - no need for this
    public void OnAfterInsert(List<Credit_Request__c> cRequest, map<Id,Credit_Request__c> pCreditRequestMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                List<Credit_Request__c> newCreditRequest = new List<Credit_Request__c>();
                Map<Id, Credit_Request__c> crToProcess = new Map<Id, Credit_Request__c>();
                Set<Id> managersId = new Set<Id>();
                if(!pCreditRequestMap.isEmpty()){
                    newCreditRequest = [SELECT Id, ManagersManager__c, VP__C,SVP__c FROM Credit_Request__c WHERE Id In: pCreditRequestMap.keySet()];
                }
                if(!newCreditRequest.isEmpty()){
                    for(Credit_Request__c cr : newCreditRequest){
                        if(cr.ManagersManager__c != null){
                            managersId.add(cr.ManagersManager__c);
                            crToProcess.put(cr.ManagersManager__c, cr);
                        }
                    }
                }
                if(!crToProcess.isEmpty()){
                    helper.populateVPandSVPOnCreditRequest(crToProcess);
                }
            }

    } /*
/*
** @author : Cloud Sherpas Inc.
** @date : 06/11/2014
** @description :  this method handles the 'after update' event for the trigger;
** @paramaters : List<Credit_Request__c> cRequest, map<Id,Credit_Request__c> pCreditRequestMap
** @story 0523
** @element E1643,E162
** @returns : nothing
*/
    public void OnAfterUpdate(List<Credit_Request__c> cRequest, map<Id,Credit_Request__c> pCreditRequestMap, map<Id,Credit_Request__c> pCreditRequestOldMap){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                /*RunCount++;
                if(RunCount > 1){
                    return;
                }*/
                helper.afterUpdate(cRequest, pCreditRequestOldMap);

                // Jeff L commented out, this will create duplicate Quotes and opportunities - this functionality has been
                //folded into the helper.afterUpdate logic
                //creditRequestIsApproved(cRequest, pCreditRequestOldMap);
            }

    }

/*
** @author : Appirio Inc.
** @date : 26/11/2014
** @description :  ;
** @paramaters : List<Credit_Request__c> cRequest, map<Id,Credit_Request__c> pCreditRequestMap
*/
/* Jeff L Commented this logic out - it has been folded into the helper.afterUpdate method
private void creditRequestIsApproved(List<Credit_Request__c> pRequest, map<Id,Credit_Request__c> pCreditRequestOldMap){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','creditRequestIsApproved');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        System.debug('===Limits.getQueries==Case' + Limits.getQueries());

        List<Credit_Request__c> cRequest = new List<Credit_Request__c>();
        Set<Id> OrderSet = new Set<Id>();
        map<Id,list<Id>> mapRequestToOrder = new map<Id,list<Id>>();
        Map<Id, String> accountOrganization = new Map<Id,String>();
        for(Credit_Request__c cr : pRequest){
            System.debug('[RB]  - Old Approval Status : ' + pCreditRequestOldMap.get(cr.Id).ApprovalStatus__c + '; New Status : ' + cr.ApprovalStatus__c);
            if(pCreditRequestOldMap.get(cr.Id).ApprovalStatus__c != 'Approved' && cr.ApprovalStatus__c == 'Approved'){
                cRequest.add(cr);
                if(!mapRequestToOrder.containsKey(cr.Order__c)){
                    mapRequestToOrder.put(cr.Order__c,new list<Id>());
                }
                mapRequestToOrder.get(cr.Order__c).add(cr.Id);


            }
        }
        //Jeff L added a reference to the quote/proposal so we can query it later to populate values on the
        // credit order
        Map<Id,Set<Id>> mapProposalToOrder = new Map<Id,Set<Id>>();
        for(Order__c order: [Select Id, AccountOrganization__c, QuoteProposal__c From Order__c where Id in: mapRequestToOrder.keySet() ] ){
            for(Id creditRequestId : mapRequestToOrder.get(order.Id)){
                accountOrganization.put(creditRequestId ,order.AccountOrganization__c );
            }
            //create a relationship between orderID and proposalID
            if(!mapProposalToOrder.containsKey(order.QuoteProposal__c)){
                    mapProposalToOrder.put(order.QuoteProposal__c, new set<Id>());
                }
                mapProposalToOrder.get(order.QuoteProposal__c).add(order.Id);

        }


        if(cRequest.isEmpty()){
            return;//Prevent logic if no Credit request has a status of Approved
        }


        Map<String,Map<String,Id>> RecordtypeId = Utility.GetRecordTypeIdsBySObjectNameSet(new set<String>{'Credit_Request__c','Order__c','Apttus_Proposal__Proposal__c', 'Opportunity'});

        Map<Id, Apttus_Proposal__Proposal__c> mapProposal = new Map<Id, Apttus_Proposal__Proposal__c>();

        List<Apttus_Proposal__Proposal__c> ListProposal = new List<Apttus_Proposal__Proposal__c>();

        //query for proposals using the keyset found above (in the mapProposalToOrder) and then populate
        //them in a map from CreditRequest to Proposal (to be used later to populate billing and posting information on the generated credit order)
        //nested for loop of Proposal > Order > Credit request so we can build a map of creditRequest to Proposal
        For(Apttus_Proposal__Proposal__c appOne : [Select Id,CreditRequest__c,BillingAccount__c,Apttus_Proposal__Account__r.Registration__c,Apttus_Proposal__Account__c,PostingContact__c,BillContact__c From Apttus_Proposal__Proposal__c Where Id IN :mapProposalToOrder.keySet()]){
            for(Id orderId : mapProposalToOrder.get(appOne.Id)){
                for(Id crId : mapRequestToOrder.get(orderId)){
                    mapProposal.put(crId, appOne);
                }
            }

        }
        System.debug('===mapProposal=='+mapProposal);

        List<Order__c> orderList = new List<Order__c>();
        List<Opportunity> OppList = new List<Opportunity>();

        For(Credit_Request__c creditOne : cRequest){

            if(creditOne.CreditScenario__c == 'Credit' && (creditOne.CreditReason__c == 'Tax Error' ||
                creditOne.CreditReason__c == 'Federal or State/Province/HST Tax Issue' ||
                creditOne.CreditReason__c == 'Incorrect tax' )){
                Apttus_Proposal__Proposal__c quote =  mapProposal.get(creditOne.id);
                //Create our new credit order form information from the proposal
                if(quote != null){
                    Order__c order = new Order__c(RecordtypeId = RecordtypeId.get('Order__c').get('Credit'));
                    //Updated as per I-181161 By Vivek Ojha
                    //order.QuoteProposal__c = quote.id;
                    system.debug('###creditOne.CreditType__c###' +creditOne.CreditType__c +creditOne.CreditReason__c);
                    order.Account__c = quote.Apttus_Proposal__Account__c;
                    order.ParentOrder__c = creditOne.Order__c;
                    order.CreditRequest__c = creditOne.Id;
                    order.CreditType__c = creditOne.CreditType__c;
                    //Changed this to a formula field Jeff L. order.CreditReason__c = creditOne.CreditReason__c;
                    order.CreditAmount__c = creditOne.CreditAmount__c;
                    if(accountOrganization.get(creditOne.id) == 'North America'){
                       // updated by Vivek for I-181161
                       order.OrderStatus__c = 'Verified';
                       if(quote != null && quote.BillingAccount__c != null && quote.BillContact__c != null && quote.PostingContact__c != null){
                            order.BillingAccount__c = quote.BillingAccount__c;
                            order.Posting_Contact__c = quote.PostingContact__c;
                            order.BillingContact__c = quote.BillContact__c;
                            system.debug('@@@ Verified....');

                       }
                       /*
                       // When Order status = sent to verification then billing contact and posting contact is required on order
                       if(quote != null && quote.BillingAccount__c != null && quote.BillContact__c != null && quote.PostingContact__c != null){
                            order.BillingAccount__c = quote.BillingAccount__c;
                            order.Posting_Contact__c = quote.PostingContact__c;
                            order.BillingContact__c = quote.BillContact__c;
                            order.OrderStatus__c = 'Sent To Verification';
                            system.debug('@@@Sent to verification..sent....');
                       }
                       */
                   /* }
                    // updated by Vivek for I-181161
                    if(accountOrganization.get(creditOne.id) == 'Europe'){
                        //order.OrderStatus__c = 'Open';
                        order.OrderStatus__c = 'Sent to Verification';
                        system.debug('@@@Sent to verification..sent....');
                    }
                //system.assert(false,order);
                    orderList.add(order);
                }
            }


            if(creditOne.CreditScenario__c == 'Credit and Rebill' && (creditOne.CreditReason__c == 'Change in Non-Standard Payment Terms' ||
                creditOne.CreditReason__c == 'Change in Standard Payment Terms' ||
                creditOne.CreditReason__c == 'Payment term changes' ||
                creditOne.CreditReason__c == 'Billing Start Date Correction' ||
                creditOne.CreditReason__c == 'Incorrect tax' ||
                creditOne.CreditReason__c == 'Payment type incorrect')){

                Opportunity oppNew = new Opportunity();
                OppList.add(oppNew);
                Apttus_Proposal__Proposal__c appNew = new Apttus_Proposal__Proposal__c(RecordtypeId = RecordtypeId.get('Apttus_Proposal__Proposal__c').get('Rebill Proposal'));

                appNew.CreditRequest__c = creditOne.id;
                // Adding posting and bill contact to quote as per I-167336
                 if(!mapProposal.isEmpty()) {
                       Apttus_Proposal__Proposal__c quote =  mapProposal.get(creditOne.id);
                       if(quote != null &&  quote.Apttus_Proposal__Account__c != null && quote.BillingAccount__c != null && quote.BillContact__c != null && quote.PostingContact__c != null){
                        appNew.Apttus_Proposal__Account__c = quote.Apttus_Proposal__Account__c;
                        if(quote.Apttus_Proposal__Account__c != null){
                            appNew.Entity_ID__c = quote.Apttus_Proposal__Account__r.Registration__c;
                        }
                        appNew.BillingAccount__c = quote.BillingAccount__c;
                        appNew.BillContact__c = quote.BillContact__c;
                        appNew.PostingContact__c = quote.PostingContact__c;
                       }
                }

                ListProposal.add(appNew);

            }
        }
        if(!OppList.isEmpty()){
        //insert OppList;
        }

        System.debug('===Before Proposal Insert Queries====' + Limits.getQueries());

        if(!ListProposal.isEmpty()){
           //
            //insert ListProposal;

            if(mapProposal.isEmpty()){
                return;
                }

            ListProposal = [SELECT Id, Apttus_Proposal__Account__c,BillingAccount__c,CreditRequest__c,CreditRequest__r.CreditReason__c,CreditRequest__r.CreditType__c,BillContact__c,PostingContact__c  FROM Apttus_Proposal__Proposal__c WHERE Id IN :ListProposal];

            System.debug('===After Proposal Insert Queries====' + Limits.getQueries());

            for(Apttus_Proposal__Proposal__c apptwo : ListProposal){
                    Order__c childorder1 = new Order__c(RecordtypeId = RecordtypeId.get('Order__c').get('Credit'));
                    childorder1.QuoteProposal__c = apptwo.id;
                    childorder1.Account__c = apptwo.Apttus_Proposal__Account__c;
                    childorder1.CreditRequest__c = apptwo.CreditRequest__c;
                    childorder1.CreditType__c = apptwo.CreditRequest__r.CreditType__c;
                    //Jeff L Commented out to make a formula field instead childorder1.CreditReason__c = apptwo.CreditRequest__r.CreditReason__c;


                    Order__c Childorder2 = new Order__c(RecordtypeId = RecordtypeId.get('Order__c').get('Rebill Order'));
                    childorder2.QuoteProposal__c = apptwo.id;
                    childorder2.Account__c = apptwo.Apttus_Proposal__Account__c;
                    childorder2.CreditRequest__c = apptwo.CreditRequest__c;
                    childorder2.CreditType__c = apptwo.CreditRequest__r.CreditType__c;
                    //Jeff L Commented out to make a formula field instead childorder2.CreditReason__c = apptwo.CreditRequest__r.CreditReason__c;

                    if(accountOrganization.get(apptwo.CreditRequest__c) == 'North America'){


                           if(apptwo.BillingAccount__c != null &&
                                                            apptwo.BillContact__c != null && apptwo.PostingContact__c != null){

                                // Adding billing and posting contact as per I-167336

                                childorder1.BillingContact__c = apptwo.BillContact__c;
                                childorder1.Posting_Contact__c = apptwo.PostingContact__c;
                                childorder1.BillingAccount__c = apptwo.BillingAccount__c;

                                childorder2.BillingContact__c = apptwo.BillContact__c;
                                childorder2.Posting_Contact__c = apptwo.PostingContact__c;
                                childorder2.BillingAccount__c = apptwo.BillingAccount__c;

                                 // We need  billing contact and posting contact for this
                                childorder1.OrderStatus__c = 'Sent To Verification';
                                childorder2.OrderStatus__c = 'Sent To Verification';

                                system.debug('@@@Sent to verification..sent....');

                           }

                    }
                    if(accountOrganization.get(apptwo.CreditRequest__c) == 'Europe'){
                        childorder1.OrderStatus__c = 'Open';
                        childorder2.OrderStatus__c = 'Open';
                    }

                    orderList.add(childorder1);
                    orderList.add(childorder2);

            }
        }

        System.debug('====orderList==='+orderList);

    /* There is no account associated with these orders to be inserted So
       Order will not be allowed to insert as per validation rule on order*/
    /*System.debug('===Before Order Insert Queries====' + Limits.getQueries());
    insert orderList;
    //system.assert(false,orderList);
    System.debug('===Before Order Insert Queries====' + Limits.getQueries());

}*/
}