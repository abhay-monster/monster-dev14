/*
** @author : Cloud Sherpas Inc.
** @date : 06/11/2014
** @description :   class that supports the '*TriggerHandler' class; it provides the methods called from those classes
*/
public without sharing class CreditRequestTriggerHelper
{
    final String CLASSNAME = '\n\n**** CreditRequestTriggerHelper.METHODNAME()';
    final String ecommRecTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Ecomm').getRecordTypeId();

    // ********* PROPERTIES ***********
    private Map<String, Map<String, Schema.SObjectField>> sObjectAndFields;

    /*
    ** @author : Cloud Sherpas Inc.
    ** @date : 06/11/2014
    ** @description : static method that instantiates a new instance of the class
    ** @paramaters : nothing
    ** @returns : a new instance of the CreditRequestTriggerHelper class
    */
    public static CreditRequestTriggerHelper NewTriggerHelper(){

        //final string METHODNAME = CLASSNAME.replace('METHODNAME','NewTriggerHelper');
        //system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        CreditRequestTriggerHelper newHelper = new CreditRequestTriggerHelper();
        return newHelper;
    }

    /*
    ** @author : Cloud Sherpas, Inc.
    ** @date : 06/11/2014
    ** @description : this method is the class constructor
    ** @paramaters : none
    ** @returns : nothing
    */
    private CreditRequestTriggerHelper(){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','CreditRequestTriggerHelper');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
    }


    /*
    @author : CloudSherpas
    @description :  Will call the updateRequest method
    @date : 06/10/2014
    @story 0523
    @element E1643,E1623
    @param : creditRequest
    @return : nothing
    */
    public void afterUpdate(List<Credit_Request__c> creditRequest, map<Id,Credit_Request__c> creditRequestOldMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','afterUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        system.debug('!!!helper');
        getAllFields();
        cloneOpportunityAndQuoteAndQuoteLineItem(creditRequest, creditRequestOldMap);
        system.debug('^^^End of CreditRequestTriggerHelper.afterUpdate');
        /*Added by Mitali(Appirio) 21/4/17 for S-477615 to prevent the OrderTrigger from Executing when the field
        Count_of_Appoved_Credit_Requests__c on the parent order is updated when a Credit Request is Approved*/
        OrderTriggerHandler.ExecuteTriggers = false;
    }

    /*
    @author : CloudSherpas
    @description :  will do the update/insert of credit request. It will cloned the Opportunity, Quote and Quote Line Item.
                    This is only used for Credit and Rebills
    @date : 06/10/2014
    @story 0523
    @element E1643,E1623
    @param : cRequest
    @return : nothing
    */
    public void cloneOpportunityAndQuoteAndQuoteLineItem(List<Credit_Request__c> pRequest, map<Id,Credit_Request__c> pCreditRequestOldMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','cloneOpportunityAndQuoteAndQuoteLineItem');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        System.debug('===Limits.getQueries===before all logic=' + Limits.getQueries());
        OrderTriggerHandler.ProcessingCreditRequest = true; //Mitali N Appirio T-600146 8/5/17
        List<Credit_Request__c> cRequest = new List<Credit_Request__c>();
        Map<Id,CreditRequestWrapper> cRequestWrapperMap = new Map<Id,CreditRequestWrapper>();
        map<Id, Credit_Request__c> errorDisplayer = new map<Id, Credit_Request__c>();
        map<Id, Id> orderTocRequestMap = new Map<Id,Id>();
        for(Credit_Request__c cr : pRequest){
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>>'+pCreditRequestOldMap.get(cr.Id).ApprovalStatus__c+'>>>>>>>>>>>>>>>>>>>>>>>>'+cr.ApprovalStatus__c);
            if(pCreditRequestOldMap.get(cr.Id).ApprovalStatus__c != 'Approved' && cr.ApprovalStatus__c == 'Approved'){
                cRequest.add(cr);
                orderTocRequestMap.put(cr.Order__c,cr.Id);
                CreditRequestWrapper crw = new CreditRequestWrapper(cr);
                if(crw.CreateOrderAutomatically == true){
                    CreditRequestTriggerHandler.CreateOrdersAutomatically = true; //JFreese Appirio 01/25/17 S-452628
                }

                cRequestWrapperMap.put(cr.Id,crw);
                errorDisplayer.put(cr.Id, cr);
            }
        }

        if(cRequest.isEmpty()){
            return;//Prevent logic if no Credit request has a status of Approved
        }

        List<Case> newCase = new List<Case>();
        Map<String, map<String, Id>> result = Utility.GetRecordTypeIdsBySObjectNameSet(new set<String>{'Credit_Request__c', 'Case', 'Apttus_Proposal__Proposal__c', 'Opportunity'});

        Map<Id, Opportunity> CROpportunityMap = new Map<Id, Opportunity>();
        Map<Id, Apttus_Proposal__Proposal__c> CRQuoteProposalMap = new Map<Id, Apttus_Proposal__Proposal__c>();
        Map<Id, List<Apttus_Proposal__Proposal_Line_Item__c>> CRQuoteLineMap = new Map<Id, List<Apttus_Proposal__Proposal_Line_Item__c>>();
        // Product Configuration
        Map<Id, List<Apttus_Config2__ProductConfiguration__c>> CRQuoteProdConfigMap = new Map<Id, List<Apttus_Config2__ProductConfiguration__c>>();

        // Product Configuration Line Items
        Map<Id, List<Apttus_Config2__LineItem__c>> CRQuoteProdConfigLIMap = new Map<Id, List<Apttus_Config2__LineItem__c>>();


        List<Opportunity> opportunitiesToBeCloned = new List<Opportunity>();
        List<Apttus_Proposal__Proposal__c> quotesToBeCloned = new List<Apttus_Proposal__Proposal__c>();
        List<Apttus_Proposal__Proposal_Line_Item__c> quotesLineToBeCloned = new List<Apttus_Proposal__Proposal_Line_Item__c>();

        // Product Configuration
        List<Apttus_Config2__ProductConfiguration__c> quotesProdConfigtoBeCloned = new List<Apttus_Config2__ProductConfiguration__c>();
        LIST<Apttus_Config2__LineItem__c> quotesProdConfigLinetobeCloned = new List<Apttus_Config2__LineItem__c>();

        Map<Id, Id> crIdToOppIdMap = new map<Id, Id>();
        Map<Id, Id> crIdToQuoteIdMap = new map<Id, Id>();
        Map<Id, Id> crIdToQuoteLineIdMap = new map<Id, Id>();
        //Jeff commented out in favor of Credit Request Wrapper Map
        //map<Id, Credit_Request__c> crIdToCr = new map<Id, Credit_Request__c>();
        Map<String,Map<String,Id>> RecordtypeId = Utility.GetRecordTypeIdsBySObjectNameSet(new set<String>{'Credit_Request__c','Order__c','Apttus_Proposal__Proposal__c', 'Opportunity'});


        for(Order__c order : getOrders(orderTocRequestMap.keySet(),'Account__r.Name' )){
            Id crId = orderTocRequestMap.get(order.Id);
            /*if(order.QuoteProposal__c == null){
                errorDisplayer.get(crId).addError('Parent order does not have a related quote.');
            }*/

            crIdToOppIdMap.put(order.Opportunity__c, crId);
            crIdToQuoteIdMap.put(order.QuoteProposal__c, crId);
            crIdToQuoteLineIdMap.put(order.QuoteProposal__c, crId);

            cRequestWrapperMap.get(crId).OldOrder = order;
        }


        Opportunity getOpp = new Opportunity();
        system.debug('==crIdToOppIdMap=='+crIdToOppIdMap);
        getOpp = getOpportunities(crIdToOppIdMap.keySet());
        map<id, Opportunity> oppIdtoOppMap = new Map<Id, Opportunity>();
        if(getOpp != null) {
            oppIdtoOppMap.put(getOpp.Id, getOpp);
        }
        system.debug('sly 1 '+oppIdtoOppMap);

        Apttus_Proposal__Proposal__c getQuote = new Apttus_Proposal__Proposal__c();
        getQuote = getQuotes(crIdToQuoteIdMap.keySet());
        map<id, Apttus_Proposal__Proposal__c> quoteIdtoquoteMap = new Map<Id, Apttus_Proposal__Proposal__c>();
        Map<id, Apttus_Config2__ProductAttributeValue__c> prodConfiglineItemAttributes = new Map<id, Apttus_Config2__ProductAttributeValue__c>();
        Map<id, Apttus_QPConfig__ProposalProductAttributeValue__c> lineItemAttributes = new Map<id, Apttus_QPConfig__ProposalProductAttributeValue__c >();
        if(getQuote != null){
            quoteIdtoquoteMap.put(getQuote.ID, getQuote);

            List<Apttus_Proposal__Proposal_Line_Item__c> getLineItem = new List<Apttus_Proposal__Proposal_Line_Item__c>();

            getLineItem = getQuotesLineItem(getQuote.Id);

            // Product Configuration
            List<Apttus_Config2__ProductConfiguration__c> getProdConfig = new List<Apttus_Config2__ProductConfiguration__c>();
            getProdConfig = getQuoteConfiguration(getQuote.Id);
            Map<id, List<Apttus_Config2__ProductConfiguration__c>> quotetoProductConfig = new Map<Id, List<Apttus_Config2__ProductConfiguration__c>>();

            // Product Configuration Line Items
            LIST<Apttus_Config2__LineItem__c> getProdConfigLineItem = new List<Apttus_Config2__LineItem__c>();
            getProdConfigLineItem = getQuoteConfigLineItem(getQuote.Id);
            Map<id, List<Apttus_Config2__LineItem__c>> quotetoProdConfigLI = new Map<Id, List<Apttus_Config2__LineItem__c>>();

            //system.debug('^getLineItem' + getLineItem);
            Map<id, List<Apttus_Proposal__Proposal_Line_Item__c>> quoteLineIdtoQuoteLineMap = new Map<Id, List<Apttus_Proposal__Proposal_Line_Item__c>>();


            for (Apttus_QPConfig__ProposalProductAttributeValue__c  attribute : getAttributes(getQuote.Id)) {
                     lineItemAttributes.put(attribute.Apttus_QPConfig__LineItemId__c,attribute);
            }


            for (Apttus_Config2__ProductAttributeValue__c  attribute : getPCLIAttributes(getQuote.Id)) {
                     prodConfiglineItemAttributes.put(attribute.Apttus_Config2__LineItemId__c,attribute);
            }

            if(getLineItem != null){
                for(Apttus_Proposal__Proposal_Line_Item__c pli : getLineItem){
                    //system.debug('\n\n\n\n\n\n\n^pli:' + pli.Id+'\n\n\n\n\n\n');
                    if(quoteLineIdtoQuoteLineMap.containsKey(pli.Apttus_Proposal__Proposal__c)){
                        quoteLineIdtoQuoteLineMap.get(pli.Apttus_Proposal__Proposal__c).add(pli);
                    }else{
                        quoteLineIdtoQuoteLineMap.put(pli.Apttus_Proposal__Proposal__c, new List<Apttus_Proposal__Proposal_Line_Item__c>());
                        quoteLineIdtoQuoteLineMap.get(pli.Apttus_Proposal__Proposal__c).add(pli);
                    }
                }
            }

            // Product Configuration
            if(getProdConfig != null){
                for(Apttus_Config2__ProductConfiguration__c conf : getProdConfig){
                    //system.debug('\n\n\n\n\n\n\n^pli:' + pli.Id+'\n\n\n\n\n\n');
                    if(quotetoProductConfig.containsKey(conf.Apttus_QPConfig__Proposald__c)){
                        quotetoProductConfig.get(conf.Apttus_QPConfig__Proposald__c).add(conf);
                    }else{
                        quotetoProductConfig.put(conf.Apttus_QPConfig__Proposald__c, new List<Apttus_Config2__ProductConfiguration__c>());
                        quotetoProductConfig.get(conf.Apttus_QPConfig__Proposald__c).add(conf);
                    }
                }
            }

            // Product Configuration Line Items
            if(getProdConfigLineItem != null){
                for(Apttus_Config2__LineItem__c confLI : getProdConfigLineItem){
                    if(quotetoProdConfigLI.containsKey(confLI.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c)){
                        quotetoProdConfigLI.get(confLI.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c).add(confLI);
                    }else{
                        quotetoProdConfigLI.put(confLI.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c, new List<Apttus_Config2__LineItem__c>());
                        quotetoProdConfigLI.get(confLI.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c).add(confLI);
                    }
                }
            }

            for(Id oppquoteId : quoteIdtoquoteMap.keySet()){
            CRQuoteProposalMap.put(crIdToQuoteIdMap.get(oppquoteId), quoteIdtoquoteMap.get(oppquoteId));
        }
        //system.debug('quoteLineIdtoQuoteLineMap' + quoteLineIdtoQuoteLineMap.keySet());
        for(Id quoteLineId : quoteLineIdtoQuoteLineMap.keySet()){
            CRQuoteLineMap.put(crIdToQuoteLineIdMap.get(quoteLineId), quoteLineIdtoQuoteLineMap.get(quoteLineId));
            //system.debug('CHECK: ' + crIdToQuoteLineIdMap.get(quoteLineId) + ' = ' + CRQuoteLineMap.get(crIdToQuoteLineIdMap.get(quoteLineId)));
        }

        // Product Configuration
         for(Id quoteLineId : quotetoProductConfig.keySet()){
            CRQuoteProdConfigMap.put(crIdToQuoteLineIdMap.get(quoteLineId), quotetoProductConfig.get(quoteLineId));
            //system.debug('CHECK: ' + crIdToQuoteLineIdMap.get(quoteLineId) + ' = ' + CRQuoteLineMap.get(crIdToQuoteLineIdMap.get(quoteLineId)));
        }

        // Product Configuration Line Items
         for(Id quoteLineId : quotetoProdConfigLI.keySet()){
            CRQuoteProdConfigLIMap.put(crIdToQuoteLineIdMap.get(quoteLineId), quotetoProdConfigLI.get(quoteLineId));
            //system.debug('CHECK: ' + crIdToQuoteLineIdMap.get(quoteLineId) + ' = ' + CRQuoteLineMap.get(crIdToQuoteLineIdMap.get(quoteLineId)));
        }


        }//my if
        for(Id oppId : oppIdtoOppMap.keySet()){
            system.debug('sly 2 '+oppIdtoOppMap);
            CROpportunityMap.put(crIdToOppIdMap.get(oppId), oppIdtoOppMap.get(oppId));
        }


        try{
            system.debug('sly inside try/catch');
            Map<String, Schema.SObjectType> sObjectMap = Schema.getGlobalDescribe() ;
            Schema.SObjectType s = sObjectMap.get('Apttus_Proposal__Proposal__c') ;
            Schema.DescribeSObjectResult resSchema = s.getDescribe() ;
            Map<String,Schema.RecordTypeInfo> recordTypeInfo = resSchema.getRecordTypeInfosByName();
            Id quoRecTypeId = recordTypeInfo.get('Rebill Proposal').getRecordTypeId();


            for(CreditRequestWrapper crw : cRequestWrapperMap.values()){
                system.debug('sly inside for');
                Credit_Request__c cr = crw.CreditRequest;
                Order__c order = crw.OldOrder;
                String caseSubj = 'Credit Request for ' + order.Account__r.Name + ' - ' + order.Name;
                Case nCase = new Case(RecordTypeId = result.get('Case').get('Credit Request'),
                                  Status = 'New',
                                  Order__c = order.Id,
                                  CreditRequest__c = cr.Id, SystemGenerated__c = true );
                nCase.Subject = caseSubj;

                nCase.Organization__c = order.AccountOrganization__c; //Added by Dom 22/10/2014 @ 1:12pm GMT

               // nCase.setOptions(dmlOpts);
                newCase.add(nCase);

                //If we are a credit and rebill then we need to create the Opportunity and Quote/proposal also
                if(crw.CreditAndRebill){
                    system.debug('sly inside if');
                    //Cloning the Opportunity related to the order
                    Opportunity ClonedOpportunity = new Opportunity();
                    if(CROpportunityMap.get(cr.Id) != null){
                        ClonedOpportunity =  CROpportunityMap.get(cr.Id).clone(false,true,false,true)  ;
                        ClonedOpportunity.CreditRequest__c = cr.Id;
                        ClonedOpportunity.CloseDate = system.Now().Date();
                        ClonedOpportunity.RecordTypeId = result.get('Opportunity').get('Rebill Opportunity');
                        ClonedOpportunity.OrderCreated__c = false;
                        ClonedOpportunity.StageName = 'Stage 2 - Proposal';//'Stage 3 - Quote';
                        ClonedOpportunity.IsValidationRequest__c = false; //set this to false otherwise case doesn't get generated on Ready for Validation
                        ClonedOpportunity.Skip_Stage_Validation__c  = True;
                        ClonedOpportunity.Probability = 50;
                        ClonedOpportunity.Legacy_Opportunity_ID__c = '';
                        //system.debug('^ClonedOpportunity.StageName: '+ ClonedOpportunity.StageName);
                        opportunitiesToBeCloned.add(ClonedOpportunity);
                        system.debug('^opportunitiesToBeCloned: '+ opportunitiesToBeCloned);
                    }
                }
            }

            Set<Id> oppId = new Set<Id>();
            Map<Id,Id> creditReqToNewOppId = new Map<Id,Id>();

            if(opportunitiesToBeCloned.size() > 0){
                OpportunityTriggerHandler.PreventRecursion = true;
                OpportunityTriggerHandler.SKIP_OPPORTUNITY_UPDATE = true;
                OpportunityTriggerHandler.ExecuteTriggers = false;
                System.debug('===Limits.getQueries===before===opportunitiesToBeCloned===' + Limits.getQueries());
                insert opportunitiesToBeCloned;
                System.debug('===Limits.getQueries===after===opportunitiesToBeCloned===' + Limits.getQueries());
                for(Opportunity oppo : opportunitiesToBeCloned){
                    oppId.add(oppo.Id);
                    creditReqToNewOppId.put(oppo.CreditRequest__c, oppo.Id);
                    cRequestWrapperMap.get(oppo.CreditRequest__c).Opportunity = oppo;
                }
            }


            //For Credit and Rebill we need to automatically create the Quote/Proposal as well.
            for(CreditRequestWrapper crw : cRequestWrapperMap.values()){
                Credit_Request__c cr = crw.CreditRequest;
                if(crw.CreditAndRebill && crw.OldOrder.RecordTypeId != ecommRecTypeId){
                    //Cloning the Quote/Proposal related to the order
                    Apttus_Proposal__Proposal__c ClonedQuoteProposal = new Apttus_Proposal__Proposal__c();
                    if(CRQuoteProposalMap.get(cr.Id) != null){
                        ClonedQuoteProposal = CRQuoteProposalMap.get(cr.Id).clone(false,true,false,true);
                        ClonedQuoteProposal.CreditRequest__c = cr.Id;
                        ClonedQuoteProposal.ParentOrder__c = cr.Order__c;
                        ClonedQuoteProposal.RecordTypeId = result.get('Apttus_Proposal__Proposal__c').get('Rebill Proposal');
                        ClonedQuoteProposal.Rebill__c = true;
                        if(creditReqToNewOppId.size() > 0) {
                            ClonedQuoteProposal.Apttus_Proposal__Opportunity__c = creditReqToNewOppId.get(cr.Id);
                        }
                        ClonedQuoteProposal.Apttus_Proposal__Primary__c = true;
                        ClonedQuoteProposal.Locked__c=false;
                        if(cr.PaymentTerm__c != null){
                            ClonedQuoteProposal.Payment1_Term__c = cr.PaymentTerm__c;
                        }
                        if(cr.Payment_Frequency__c != null){
                            ClonedQuoteProposal.Payment1_Frequency__c = cr.Payment_Frequency__c;
                        }
                        if(cr.Payment_Method__c != null){
                            ClonedQuoteProposal.Payment_Method1__c = cr.Payment_Method__c;
                        }
                        if(cr.New_Number_of_Installments__c != null){
                            ClonedQuoteProposal.New_Number_of_Installments__c = cr.New_Number_of_Installments__c;
                        }
                        if(cr.Payment_Details__c != null){
                            ClonedQuoteProposal.PaymentDetails__c = cr.Payment_Details__c;
                        }
                        if(cr.Billing_Start_Date__c != null){
                            ClonedQuoteProposal.BillingStartDt__c = cr.Billing_Start_Date__c;
                        }
                        ClonedQuoteProposal.Apttus_QPApprov__Approval_Status__c = 'Not Submitted';
                        ClonedQuoteProposal.Apttus_Proposal__Approval_Stage__c = 'Draft';
                        ClonedQuoteProposal.QuoteStatus__c = 'In Progress';
                        ClonedQuoteProposal.AvalaraResponseCode__c = '';
                        ClonedQuoteProposal.AvalaraResponseMessage__c = '';
                        ClonedQuoteProposal.Avalara_DocDate__c = null;
                        //ClonedQuoteProposal.Avalara_CompanyCode__c = '';
                        ClonedQuoteProposal.Avalara_TimeStamp__c = '';
                        ClonedQuoteProposal.Legacy_Quote_ID__c = '';
                        //Blank out all the paypal fields - just in case
                        ClonedQuoteProposal.PaypalBillToName__c = null;
                        ClonedQuoteProposal.PaypalResultCode__c = null;
                        ClonedQuoteProposal.PaypalResultMessage__c = null;
                        ClonedQuoteProposal.PaypalTransactionTime__c = null;
                        ClonedQuoteProposal.PaypalCardType__c = null;
                        ClonedQuoteProposal.PaypalReferenceNumber__c = null;
                        ClonedQuoteProposal.PaypalSecureTokenID__c = null;

                        quotesToBeCloned.add(ClonedQuoteProposal);
                    }
                }
            }
            //system.debug('^quotesToBeCloned: '+ quotesToBeCloned);
            Set<Id> quoteId = new Set<Id>();
            Apttus_Proposal__Proposal__c quoteToQuoteLineItem = new Apttus_Proposal__Proposal__c();


            Map<Id,Id> creditReqToNewPropId = new Map<Id,Id>();
            if(quotesToBeCloned.size() > 0){
                ApttusProposalTriggerHandler.ExecuteTriggers = false;
               
                System.debug('===Limits.getQueries===before===quotesToBeCloned==' + Limits.getQueries());
                insert quotesToBeCloned;
                System.debug('===Limits.getQueries===after===quotesToBeCloned===' + Limits.getQueries());
                for(Apttus_Proposal__Proposal__c q : quotesToBeCloned){
                    quoteId.add(q.Id);
                    creditReqToNewPropId.put(q.CreditRequest__c, q.Id);
                    cRequestWrapperMap.get(q.CreditRequest__c).Proposal = q;
                }
                /*Appirio Jonathan Freese 4/29/16 I-213036  Need to refresh the tax info, which is currently that of the source quote*/
                if(quoteId.size() > 0){
                    //try{
                        //JFreese Appirio 3/9/17 S-456572
                        system.debug('\n\nNOT Calling asyncronous Avalara callout method AsyncTaxRateProcessing().\n\n');
                        system.debug('^^^ quoteId='+quoteId);
                        system.debug('AsyncTaxRateProcessing will be called in the third queueble in the chain below');
                        /*We can no longer call the future method AvalaraModel.AsyncTaxRateProcessing from here,
                          as it results in:
                          Future method cannot be called from a future or batch method:
                          OpportunityLineItemTriggerHelper.setInternationalOppty(Set<Id>)

                          Nor can we call it in a queueable at this point, because it may result in
                          UNABLE_TO_LOCK_ROW errors on the account or opportunity (the latter from
                          updates to the OpportunityLineItem records resulting from the Proposal line items, etc.

                          The fact that this was a future call in the first place indicates that the code which
                          follows is not time dependent on the Avalara tax update, so we will do the update in
                          the third queueable int hte chain below
                    }catch(Exception e){
                        system.debug('\n\n AsyncTaxRateProcessing error:' + e + '\n\n');
                    }*/
                }
            }

            // Clone Product configuration
            for(CreditRequestWrapper crw : cRequestWrapperMap.values()){
                Credit_Request__c cr = crw.CreditRequest;
                if(crw.CreditAndRebill && crw.OldOrder.RecordTypeId != ecommRecTypeId){
                    //Cloning the Proposal Line Item related to the Proposal
                    Apttus_Config2__ProductConfiguration__c ClonedQuoteConfig = new Apttus_Config2__ProductConfiguration__c();
                    if(CRQuoteProdConfigMap.get(cr.Id) != null){
                        //system.debug('CRQuoteLineMap'+ CRQuoteLineMap.get(cr.Id));
                        for(Apttus_Config2__ProductConfiguration__c appli : CRQuoteProdConfigMap.get(cr.Id)){
                            ClonedQuoteConfig = appli.clone(false,true,false,true);
                            ClonedQuoteConfig.Apttus_QPConfig__Proposald__r=null;
                            ClonedQuoteConfig.Apttus_QPConfig__Proposald__c = creditReqToNewPropId.get(cr.Id);
                            ClonedQuoteConfig.Apttus_Config2__BusinessObjectId__c = Id.valueOf(creditReqToNewPropId.get(cr.Id));
                            quotesProdConfigtoBeCloned.add(ClonedQuoteConfig);

                        }
                    }
                }
            }

            Map<Id,Id> creditReqToNewPropConfigId = new Map<Id,Id>();
            if(quotesProdConfigtoBeCloned.size() > 0){
                System.debug('===Limits.getQueries===before===quotesProdConfigtoBeCloned==' + Limits.getQueries());
                insert quotesProdConfigtoBeCloned;
                System.debug('===Limits.getQueries===after===quotesProdConfigtoBeCloned==' + Limits.getQueries());

                for(Apttus_Config2__ProductConfiguration__c qpc : quotesProdConfigtoBeCloned){
                    for(Apttus_Proposal__Proposal__c q : quotesToBeCloned){
                        if(creditReqToNewPropId.containsKey(q.CreditRequest__c))
                        {
                            creditReqToNewPropConfigId.put(q.CreditRequest__c, qpc.Id);
                            cRequestWrapperMap.get(q.CreditRequest__c).ProductConfiguration = qpc;
                        }
                    }
                }
            }

            // Clone Product configuration Line Items
            list<Apttus_Config2__ProductAttributeValue__c> PCLIattributesToBeCloned = new List<Apttus_Config2__ProductAttributeValue__c>();
            for(CreditRequestWrapper crw : cRequestWrapperMap.values()){
                Credit_Request__c cr = crw.CreditRequest;
                if(crw.CreditAndRebill && crw.OldOrder.RecordTypeId != ecommRecTypeId){
                    //Cloning the Line Item related to the Product Configuration
                    Apttus_Config2__LineItem__c ClonedQuoteConfigLI = new Apttus_Config2__LineItem__c();
                    if(CRQuoteProdConfigLIMap.get(cr.Id) != null){
                        for(Apttus_Config2__LineItem__c qpcli : CRQuoteProdConfigLIMap.get(cr.Id)){
                            ClonedQuoteConfigLI = qpcli.clone(false,true,false,true);
                            ClonedQuoteConfigLI.Apttus_Config2__ConfigurationId__r = null;
                            ClonedQuoteConfigLI.Apttus_Config2__ConfigurationId__c = creditReqToNewPropConfigId.get(cr.Id);
                            //system.debug('^^^ check 2 ClonedQuoteConfigLI.Apttus_Config2__ConfigurationId__c=' + ClonedQuoteConfigLI.Apttus_Config2__ConfigurationId__c + ', source Id=' + qpcli.Id);
                            quotesProdConfigLinetobeCloned.add(ClonedQuoteConfigLI);

                            if(prodConfiglineItemAttributes.containsKey(qpcli.id)) {
                                Apttus_Config2__ProductAttributeValue__c clonedAttribute = prodConfiglineItemAttributes.get(qpcli.id).clone(false,true,false,true);
                                clonedAttribute.Apttus_Config2__LineItemId__r=ClonedQuoteConfigLI;
                                PCLIattributesToBeCloned.add(clonedAttribute);
                            }
                        }
                    }
                }
            }

            if(quotesProdConfigLinetobeCloned.size() > 0){
                System.debug('===Limits.getQueries===before===quotesProdConfigLinetobeCloned==' + Limits.getQueries());
                insert quotesProdConfigLinetobeCloned;
                System.debug('===Limits.getQueries===after===quotesProdConfigLinetobeCloned==' + Limits.getQueries());
            }

            if (PCLIattributesToBeCloned.isEmpty()==false){
                for (Apttus_Config2__ProductAttributeValue__c attribute : PCLIattributesToBeCloned){
                    attribute.Apttus_Config2__LineItemId__c = attribute.Apttus_Config2__LineItemId__r.id;
                }
                System.debug('===Limits.getQueries===before===PCLIattributesToBeCloned==' + Limits.getQueries());
                insert PCLIattributesToBeCloned;
                System.debug('===Limits.getQueries===after===PCLIattributesToBeCloned==' + Limits.getQueries());
            }


            // Jeff L commented out, instead we can do this when we insert the opportunities above
            //updateStage(oppId, quoteId);
            list<Apttus_QPConfig__ProposalProductAttributeValue__c >attributesToBeCloned = new List<Apttus_QPConfig__ProposalProductAttributeValue__c >();
            for(CreditRequestWrapper crw : cRequestWrapperMap.values()){
                Credit_Request__c cr = crw.CreditRequest;
                if(crw.CreditAndRebill && crw.OldOrder.RecordTypeId != ecommRecTypeId){
                    //Cloning the Proposal Line Item related to the Proposal
                    Apttus_Proposal__Proposal_Line_Item__c ClonedQuoteLine = new Apttus_Proposal__Proposal_Line_Item__c();
                    if(CRQuoteLineMap.get(cr.Id) != null){
                        //system.debug('CRQuoteLineMap'+ CRQuoteLineMap.get(cr.Id));
                        for(Apttus_Proposal__Proposal_Line_Item__c appli : CRQuoteLineMap.get(cr.Id)){
                            ClonedQuoteLine = appli.clone(false,true,false,true);
                            if(ClonedQuoteLine.Apttus_Proposal__Sales_Discount__c > 999.9 || ClonedQuoteLine.Apttus_Proposal__Sales_Discount__c < -999.9){
                                ClonedQuoteLine.Apttus_Proposal__Sales_Discount__c = 0;
                            }
                            ClonedQuoteLine.Apttus_Proposal__Proposal__r=null;
                            ClonedQuoteLine.Apttus_Proposal__Proposal__c = creditReqToNewPropId.get(cr.Id);
                            ClonedQuoteLine.Legacy_QuoteLine_ID__c = '';
                            quotesLineToBeCloned.add(ClonedQuoteLine);

                            if(lineItemAttributes.containsKey(appli.id)) {
                                Apttus_QPConfig__ProposalProductAttributeValue__c clonedAttribute = lineItemAttributes.get(appli.id).clone(false,true,false,true);
                                clonedAttribute.Apttus_QPConfig__LineItemId__r=ClonedQuoteLine;
                                attributesToBeCloned.add(clonedAttribute);
                            }
                        }
                    }
                }
            }
            if(quotesLineToBeCloned.size() > 0){
                System.debug('===Limits.getQueries===before===quotesLineToBeCloned==' + Limits.getQueries());
                insert quotesLineToBeCloned;
                System.debug('===Limits.getQueries===after===quotesLineToBeCloned==' + Limits.getQueries());
            }


            if (attributesToBeCloned.isEmpty()==false){
                for (Apttus_QPConfig__ProposalProductAttributeValue__c attribute : attributesToBeCloned){
                    attribute.Apttus_QPConfig__LineItemId__c = attribute.Apttus_QPConfig__LineItemId__r.id;
                }
                System.debug('===Limits.getQueries===before===attributesToBeCloned==' + Limits.getQueries());
                insert attributesToBeCloned;
                System.debug('===Limits.getQueries===after===attributesToBeCloned==' + Limits.getQueries());
            }

            if(newCase.size() > 0){
                System.debug('===Limits.getQueries===before===Case==' + Limits.getQueries());
               insert newCase;
                System.debug('===Limits.getQueries===after===Case==' + Limits.getQueries());
            }


            // Commented due to (I-187366)
            system.debug('sly_c RequestWrapperMap' +cRequestWrapperMap);
            system.debug('^^^Limits.getQueueableJobs() 1: '+Limits.getQueueableJobs()+' out of '+Limits.getLimitQueueableJobs());

            AsyncAutoCreateOrder Async = new AsyncAutoCreateOrder();
            Async.pRequestWrapperMap = cRequestWrapperMap;
            Async.quoteId = quoteId;
            system.debug('^^^Enqueueing Async AsyncAutoCreateOrder()');
            System.enqueueJob(Async);
            system.debug('^^^Enqueued Async AsyncAutoCreateOrder()');
            //createOrderForCreditRequestAndProposal(cRequestWrapperMap);

        }catch(DMLException e){
            //system.assert(false, e.getMessage());
            ExceptionLog.add('DMLException', 'CreditRequestTriggerHelper', 'cloneOpportunityAndQuoteAndQuoteLineItem', e.getMessage());
            system.debug('DMLException CreditRequestTriggerHelper cloneOpportunityAndQuoteAndQuoteLineItem:: '+e);
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Failed to update. Please see system log for details.', e);
        }
    }


    /*
    @author : Appirio
    @description : This AsyncAutoCreateOrder is a queueable class that is used because all of this logic cannot
                    be perfomed in a single transaction
    @date : ??? (original date unkown, jeff L co-opted/updated on 10/26/2015 and continued to update)
    @param : pRequestWrapperMap
    @return : nothing
    */
    public class AsyncAutoCreateOrder implements Queueable {
        public Map<Id,CreditRequestWrapper> pRequestWrapperMap;
        public Set<Id> quoteId;

        public void execute(QueueableContext context){
            List<Order__c> verifiedCreditOrders = createOrderForCreditRequestAndProposal(pRequestWrapperMap);
            system.debug('^^^verifiedCreditOrders: '+verifiedCreditOrders);
            system.debug('^^^Limits.getQueueableJobs() 2: '+Limits.getQueueableJobs()+' out of '+Limits.getLimitQueueableJobs());
            system.debug('^^^CreditRequestTriggerHandler.CreateOrdersAutomatically='+CreditRequestTriggerHandler.CreateOrdersAutomatically);

            //JFreese Appirio 3/4/17 S-456572  Make an opportunity for the verified credit order
            AsyncAutoCreateCreditOpportunity AsyncACCO = new AsyncAutoCreateCreditOpportunity();
            AsyncACCO.creditOrders = verifiedCreditOrders;
            AsyncACCO.quoteId = quoteId;
            Id jobId = System.enqueueJob(AsyncACCO);
        }

        /*
        @author : Appirio
        @description :  This method will create Orders for any credit and rebill credit requests that need them created (there are some types that autocreate them)
        @date : ??? (original date unkown, jeff L co-opted/updated on 10/26/2015 and continued to update)
        @param : pRequestWrapperMap
        @return : nothing
        */
        private List<Order__c> createOrderForCreditRequestAndProposal(Map<Id,CreditRequestWrapper> pRequestWrapperMap){
            system.debug('**** Inside CreditRequestTriggerHelper.createOrderForCreditRequestAndProposal ***');
            System.debug('===Limits.getQueries==createOrderForCreditRequestAndProposal Before' + Limits.getQueries());
            String ecommRecTypeId2 = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Ecomm').getRecordTypeId();


            List<Credit_Request__c> cRequest = new List<Credit_Request__c>();
            Set<Id> cRequestIds = new Set<Id>();
            map<Id,list<Id>> mapRequestToOrder = new map<Id,list<Id>>();
            Map<Id, String> accountOrganization = new Map<Id,String>();
            List<Order__c> orderList = new List<Order__c>();
            List<Opportunity> oppList = new List<Opportunity>();
            Map<String,Map<String,Id>> RecordtypeId = Utility.GetRecordTypeIdsBySObjectNameSet(new set<String>{'Credit_Request__c','Order__c','Apttus_Proposal__Proposal__c', 'Opportunity', 'Order_Line_Item__c'});
            Map<Id, Apttus_Proposal__Proposal__c> mapProposal = new Map<Id, Apttus_Proposal__Proposal__c>();
            for(CreditRequestWrapper crw : pRequestWrapperMap.values()){
                //if(pCreditRequestOldMap.get(cr.Id).ApprovalStatus__c != 'Approved' && cr.ApprovalStatus__c == 'Approved'){
                if(crw.CreateOrderAutomatically){
                    CreditRequestTriggerHandler.CreateOrdersAutomatically = true; //JFreese Appirio 01/25/17 S-452628
                    system.debug('inside of createOrderForCreditRequestAndProposal Create Order Automatically is true');
                    Credit_Request__c cr = crw.CreditRequest;
                    cRequest.add(cr);
                    cRequestIds.add(cr.Id);
                    system.debug('^^^Adding Credit_Request__c '+cr.Id);

                    if(crw.OldOrder != null){
                        accountOrganization.put(cr.Id,crw.OldOrder.AccountOrganization__c);
                    }
                }
            }

            if(cRequest.isEmpty()){
                //*return;//Prevent logic if no Credit request has a status of Approved
                return orderList;//Prevent logic if no Credit request has a status of Approved
            }

            For(Apttus_Proposal__Proposal__c appOne : [Select Id, CreditRequest__c,BillingAccount__c,Apttus_Proposal__Account__r.Registration__c,Apttus_Proposal__Account__c,PostingContact__c,BillContact__c,
                Entity_ID__c, AgencyCommission__c
                From Apttus_Proposal__Proposal__c
                Where CreditRequest__c IN :cRequest]){
                mapProposal.put(appOne.CreditRequest__c, appOne);
            }

            //Account, Billing Accout, billing contact, Posting Contact, Entity ID, International Deal
            /*Credit_Request__c crc = [SELECT Id, CreditReason__c, Order__r.Id, Order__r.Account__c, Order__r.AgencyCommission__c, order__r.BillingAccount__c,
                                        order__r.BillingContact__c, order__r.Posting_Contact__c, Order__r.Entity_ID__c, Order__r.International_Deal__c
                                        FROM Credit_Request__c
                                        WHERE Id =: creditRequestId LIMIT 1];*/
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
                                                                      Order_Line_Item__r.Legacy_Karma_PartNum__c
                                                           FROM CreditRequestLineItem__c
                                                           WHERE Credit_Request__c =: cRequestIds];

            //Available inventory check from site also add these line items to our credit request wrapper object
            map<String, Credit_Request_License_ID__c> siteLicenseIdToCreditRequestId = new map<String, Credit_Request_License_ID__c>();

            /*S-445896 JFreese Appirio 12/1/16 only send one License ID to Site, to avoid APEX Heap error.
                    Per Apttus (Sivaganesh Ramakrishnan 13Nov2016) sending any license in a family
                    tree returns the whole tree structure, so we only need to send one.*/
            Set<String> SFLicenseToSend = new Set<String>();
            Boolean SentOne = false;

            for(CreditRequestLineItem__c crli : CRLIList){
               //create a map to add to our credit request wrapper, for use later
                Map<Id, CreditRequestLineItem__c> crliMap = pRequestWrapperMap.get(crli.Credit_Request__c).CreditRequestLineItems;
                if(crliMap == null){
                    crliMap = new Map<Id, CreditRequestLineItem__c>();
                    pRequestWrapperMap.get(crli.Credit_Request__c).CreditRequestLineItems = crliMap;
                }
                crliMap.put(crli.Id,crli);

                if(crli.CreditType__c == 'Inventory'){
                    for(Credit_Request_License_ID__c license : crli.Credit_Request_License_IDs__r){
                        if(license.LicenseID__r.SiteLicenseID__c != null){
                            siteLicenseIdToCreditRequestId.put(license.LicenseID__r.SiteLicenseID__c, license);
                            if (!SentOne){
                                SFLicenseToSend.add(license.LicenseID__r.SiteLicenseID__c);
                                SentOne = true;
                            }
                        }
                    }
                }
            }

            if(!siteLicenseIdToCreditRequestId.isEmpty()){
                System.debug('===Limits.getQueries==GetLicenseAndRelativesForCreditRequest Before' + Limits.getQueries());
                map<String, Integer> quantityResult = BizAppsSiteModel.GetLicenseAndRelativesForCreditRequest(SFLicenseToSend);
                System.debug('===Limits.getQueries==GetLicenseAndRelativesForCreditRequest After' + Limits.getQueries());

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


            //Credit order list so we can requery to refresh some data later
            Set<Id> creditOrderIds = new Set<Id>();
            For(Credit_Request__c creditOne : cRequest){

                CreditRequestWrapper crw = pRequestWrapperMap.get(creditOne.Id);
                Apttus_Proposal__Proposal__c quote = mapProposal.get(creditOne.Id);
                Order__c parentOrder = crw.OldOrder;
                system.debug('RUN 1');
                system.debug('RUN 2 CREDIT '+crw.credit +'CreditAndRebill '+crw.CreditAndRebill);

                //This is the logic to create the Credit order, it gets associated to the old order and basically cloned from it
                //with just a few modifications
                if(crw.Credit || crw.CreditAndRebill){
                    CreateCreditOrderFromCreditRequest orderCloner = new CreateCreditOrderFromCreditRequest(crw.OldOrderId, crw.CreditRequestId);
                    system.debug('RUN 3');
                    string res = orderCloner.createCreditOrder();
                    system.debug('Response String' + res);
                    //now lets get our new order after the cloner completes
                    crw.creditOrder = orderCloner.newOrder;
                    creditOrderIds.add(orderCloner.newOrder.Id);
                }

                //If it is a credit and rebill, then we need to create the new Rebill Order! which has different
                //requirements than the credit order (associate to the new Opp and Proposal generated above for example)
                if(crw.CreditAndRebill && crw.OldOrder.RecordTypeId != ecommRecTypeId2){
                    system.debug('RUN 4');
                    if(crw.Opportunity != null){
                        Opportunity opp = crw.Opportunity;
                        opp.OrderCreated__c = true; //this triggers the Opportunity to create an order.
                        oppList.add(opp);
                    }
                }
            }

            if(!oppList.isEmpty()){
                system.debug('RUN 5');
                System.debug('===Limits.getQueries==insert opp Before' + Limits.getQueries()+', Limits.getQueueableJobs(): '+Limits.getQueueableJobs()+' out of '+Limits.getLimitQueueableJobs());
                update oppList;
                System.debug('===Limits.getQueries==insert opp After' + Limits.getQueries()+', Limits.getQueueableJobs(): '+Limits.getQueueableJobs()+' out of '+Limits.getLimitQueueableJobs());
            }



            //Now that our Orders have been inserted (And we have the CreditOrder)
            //We need to query to get our Rebill Order and CreditOrder (since it was created from the opportunity) to get updated fields
            for(Order__c order : [Select Id, Opportunity__c, CreditRequest__c, AccountOrganization__c,
                Credit_Reason__c, CreditScenario__c, OrderStatus__c, is_rebill__c, is_credit__c,BillingStartDt__c,
                ParentOrder__r.BillingStartDt__c,CreditRequest__r.CreditReason__c, Account__c from Order__c
                where Opportunity__c in : oppList OR ID in :creditOrderIds]){
                CreditRequestWrapper crw = pRequestWrapperMap.get(order.CreditRequest__c);
                system.debug('>>>>>>>>>>>>Wrapper' + pRequestWrapperMap);
                system.debug('>>>>>>>>>>>>OCR' + order.CreditRequest__c);
                system.debug('>>>>>>>>>>>>' + crw);

                if(order.is_rebill__c){
                    crw.RebillOrder = order;
                } else {
                    crw.CreditOrder = order;
                }


            }


            //now it's time to update all of our order to 'Sent to Verification'
            List<Order__c> ordersToUpdate = new List<Order__c>();
            for(Credit_Request__c creditOne : cRequest){
                CreditRequestWrapper crw = pRequestWrapperMap.get(creditOne.Id);
                if(crw.CreditOrder != null){
                    system.debug('Credit Order: ' + crw.CreditOrder);
                    Order__c credit = crw.CreditOrder;
                    credit.OrderStatus__c = 'Sent To Verification';
                    ordersToUpdate.add(credit);
                }

                if(crw.RebillOrder != null){
                    Order__c rebill = crw.RebillOrder;
                    system.debug('Rebill Order ' + crw.RebillOrder);
                    rebill.OrderStatus__c = 'Sent To Verification';
                    ordersToUpdate.add(rebill);
                }
            }

            if(!ordersToUpdate.isEmpty()){
                //reset this to true
                for (Order__c o : ordersToUpdate){
                    system.debug('^^^updating order '+o.id);
                }
                update ordersToUpdate;

                //now that the orders have been updated we need to send them through BizAppsSiteModel
                BizAppsSiteModel.autoTriggerVerificationForCredit(ordersToUpdate);
            }

            /*JFreese Appirio 3/4/17 S-456572 The credit/rebill orders are now verified, but the runCount
              was > 1 (generally 8/9/10) so no before/after methods were run, so createCreditOpportunity()
              was not called, so the credit order has no opportunity yet.  Return the list of credit orders
              so it can be passed to AsyncAutoCreateCreditOpportunity to create a credit opportunity*/
            /*JFreese Appirio 3/28/17 I-266088 Added International_Deal__c to prevent error on
              OrderTriggerHelper.createCreditOpportunity*/
            List<Order__c> updatedCreditOrders = [Select Id, OrderStatus__c, Opportunity__c, CreditRequest__c,
                                                  is_credit__c, Account__c, CurrencyIsoCode, International_Deal__c
                                                  from Order__c where ID in :creditOrderIds];
            return updatedCreditOrders;
        }
    }

    /*
    @author : JFreese Appirio 3/3/17 S-456572
    @description : AsyncAutoCreateCreditOpportunity is a queueable class that is used because the additional logic
                   for making credit opportunities cannot be added to AsyncAutoCreateOrder
    @date : 3/3/17
    @param : creditOrders
    @return : nothing
    */
    public class AsyncAutoCreateCreditOpportunity implements Queueable {
        public List<Order__c> creditOrders;
        public Set<Id> quoteId;
        //public Boolean IsCreditReqApproved = false;
        public void execute(QueueableContext context){
            createCreditOpportunity(creditOrders);
        }

        private void createCreditOpportunity(List<Order__c> creditOrders){
            system.debug('*** Inside CreditRequestTriggerHelper.createCreditOpportunity ***');

            // this expired with the completion of cloneOpportunityAndQuoteAndQuoteLineItem()
            CreditRequestTriggerHandler.CreateOrdersAutomatically = true;

            if(!creditOrders.isEmpty()){
                for (Order__c o : creditOrders){
                    system.debug('^^^Creating Credit Opportunity for '+o.id);
                }
                /*When the credit order was verified, the runCount was > 1 (generally 8/9/10)
                  so no before/after methods were run, so createCreditOpportunity() was not called,
                  so the credit order has no opportunity yet.  We need to call createCreditOpportunity()
                  from here.  If CreateOrdersAutomatically = true (which it is for this instance)
                  then createCreditOpportunity() also updates the order to set the new opportunity,
                  then calls other method(s) which would have been called from the Verify Order button,
                  and which set key data on the new opportunity.*/

                OrderTriggerHelper OT_Helper = OrderTriggerHelper.NewTriggerHelper();
                OT_Helper.ResetQueries();
                OT_Helper.ordersList = creditOrders;
                OT_Helper.createCreditOpportunity(creditOrders);
            }

            QueueableTaxRateProcessing AsyncTRP  = new QueueableTaxRateProcessing();
            AsyncTRP.pIdSet = quoteId;
            AsyncTRP.pCalledFromObject = 'QUOTE';
            System.enqueueJob(AsyncTRP);
        }
    }


    /*
    @author : JFreese Appirio 3/9/17 S-456572
    @description : call AvalaraModel.AsyncTaxRateProcessingMethods as a queueable
    */
    public class QueueableTaxRateProcessing implements Queueable, Database.AllowsCallouts{
        private set<Id> pIdSet;
        private String pCalledFromObject;

        public void execute(QueueableContext context) {
            AvalaraModel.AsyncTaxRateProcessingMethods (pIdSet , pCalledFromObject);
        }
    }


    /**
    * @description Gets all field detail of Opportunity based on the Id
    * @author Cloudsherpas
    * @date 06/11/2014
    * @story 0523
    * @element E1643,E1623
    * @param IdOfOpportunity
    * @returns Opportunity ParentOpportunity
    */
    private Opportunity getOpportunities(set<Id> IdOfOpportunity){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','getOpportunities');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Opportunity ParentOpportunity = null;
        Map<String, Schema.SObjectField> oppFields = new Map<String, Schema.SObjectField>();
        oppFields = sObjectAndFields.get('Opportunity');
        String oppQuery = 'SELECT ';
        for(String sourceAPI : oppFields.keySet()){
            //this throws an error every single time, Admin or not
            if(sourceAPI != 'contractid'){
                oppQuery += sourceAPI+',';
            }
        }
        oppQuery = oppQuery .removeEnd(',');
        oppQuery += ' FROM Opportunity WHERE Id in : IdOfOpportunity LIMIT 1' ;
        //try{

            for(Opportunity o : Database.query(oppQuery)){
                ParentOpportunity = o;
            }
            return ParentOpportunity;
        /*}catch(Exception e){
            ExceptionLog.add('Exception', 'CreditRequestTriggerHelper', 'getOpportunities', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to get the opportunity.' ,e);
        }*/
    }

    /**
    * @description Gets all field detail of Apttus_Proposal__Proposal__c based on the Id
    * @author Cloudsherpas
    * @date 06/11/2014
    * @story 0523
    * @element E1643,E1623
    * @param IdOfQuote
    * @returns Apttus_Proposal__Proposal__c ParentQuote
    */
    private Apttus_Proposal__Proposal__c getQuotes(set<Id> IdOfQuote){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','getQuotes');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            Map<String, Schema.SObjectField> oppFields = sObjectAndFields.get('Apttus_Proposal__Proposal__c');

            String orderQuery = 'SELECT ';
            for(String sourceAPI : oppFields.keySet()){
                orderQuery += sourceAPI+',';
            }
            orderQuery = orderQuery.removeEnd(',');
            orderQuery += ' FROM Apttus_Proposal__Proposal__c WHERE Id in : IdOfQuote LIMIT 1' ;

            Apttus_Proposal__Proposal__c[] quoteResult = Database.query(orderQuery);
            return quoteResult.isEmpty() ? null : quoteResult[0];
        }catch(Exception e){
            ExceptionLog.add('Exception', 'CreditRequestTriggerHelper', 'getQuotes', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to get the Quote/Proposal.' ,e);
        }
    }
    private List<Apttus_QPConfig__ProposalProductAttributeValue__c> getAttributes(Id IdOfQuote){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','getAttributes');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            Map<String, Schema.SObjectField> oppFields = sObjectAndFields.get('Apttus_QPConfig__ProposalProductAttributeValue__c');

            String orderQuery = 'SELECT ';
            for(String sourceAPI : oppFields.keySet()){
                orderQuery += sourceAPI+',';
            }
            orderQuery = orderQuery.removeEnd(',');
            orderQuery += ' FROM Apttus_QPConfig__ProposalProductAttributeValue__c WHERE Apttus_QPConfig__LineItemId__r.Apttus_Proposal__Proposal__c = : IdOfQuote' ;
            return  Database.query(orderQuery);
        }catch(Exception e){
            ExceptionLog.add('Exception', 'CreditRequestTriggerHelper', 'getAttributes', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to get the attributes.' ,e);
        }
    }

    private List<Apttus_Config2__ProductAttributeValue__c> getPCLIAttributes(Id IdOfQuote){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','getPCLIAttributes');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            Map<String, Schema.SObjectField> oppFields = sObjectAndFields.get('Apttus_Config2__ProductAttributeValue__c');

            String orderQuery = 'SELECT ';
            for(String sourceAPI : oppFields.keySet()){
                orderQuery += sourceAPI+',';
            }
            orderQuery += ' Apttus_Config2__LineItemId__r.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c';
            orderQuery += ' FROM Apttus_Config2__ProductAttributeValue__c WHERE Apttus_Config2__LineItemId__r.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c = : IdOfQuote' ;
            return  Database.query(orderQuery);
        }catch(Exception e){
            ExceptionLog.add('Exception', 'CreditRequestTriggerHelper', 'getPCLIAttributes', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to get the attributes.' ,e);
        }
    }

    /**
    * @description Gets all field detail of Apttus_Proposal__Proposal_Line_Item__c based on the Id
    * @author Cloudsherpas
    * @date 06/12/2014
    * @story 0523
    * @element E1643,E1623
    * @param IdOfQuote
    * @returns List<Apttus_Proposal__Proposal_Line_Item__c> QuoteLine
    */
    private List<Apttus_Proposal__Proposal_Line_Item__c> getQuotesLineItem(Id IdOfQuote){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','getQuotesLineItem');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            Map<String, Schema.SObjectField> oppFields = sObjectAndFields.get('Apttus_Proposal__Proposal_Line_Item__c');
            List<Apttus_Proposal__Proposal_Line_Item__c> QuoteLine = new List<Apttus_Proposal__Proposal_Line_Item__c>();
            String orderQuery = 'SELECT ';
            for(String sourceAPI : oppFields.keySet()){
                orderQuery += sourceAPI+',';
            }
            orderQuery = orderQuery.removeEnd(',');
            orderQuery += ' FROM Apttus_Proposal__Proposal_Line_Item__c WHERE  Apttus_Proposal__Proposal__c = : IdOfQuote' ;

            QuoteLine = Database.query(orderQuery);
            system.debug('QuoteLine'+ QuoteLine);
            return QuoteLine;
        }catch(DMLException e){
            ExceptionLog.add('DMLException', 'CreditRequestTriggerHelper', 'getQuotesLineItem', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to get the Proposal Line Item.' ,e);
        }
    }

    // Product Configuration

    private List<Apttus_Config2__ProductConfiguration__c> getQuoteConfiguration(Id IdOfQuote){


            Map<String, Schema.SObjectField> oppFields = sObjectAndFields.get('Apttus_Config2__ProductConfiguration__c');
            List<Apttus_Config2__ProductConfiguration__c> QuoteLine = new List<Apttus_Config2__ProductConfiguration__c>();
            String Finalized = 'Finalized';
            String orderQuery = 'SELECT ';
            for(String sourceAPI : oppFields.keySet()){
                orderQuery += sourceAPI+',';
            }
            orderQuery = orderQuery.removeEnd(',');
            orderQuery += ' FROM Apttus_Config2__ProductConfiguration__c WHERE  Apttus_QPConfig__Proposald__c = : IdOfQuote';
            orderQuery += ' AND Apttus_Config2__Status__c =: Finalized'; // take only the last prod config

            QuoteLine = Database.query(orderQuery);
            system.debug('QuoteLine'+ QuoteLine);
            return QuoteLine;
    }


    private List<Apttus_Config2__LineItem__c> getQuoteConfigLineItem(Id IdOfQuote){
            Map<String, Schema.SObjectField> oppFields = sObjectAndFields.get('Apttus_Config2__LineItem__c');
            List<Apttus_Config2__LineItem__c> QCLine = new List<Apttus_Config2__LineItem__c>();
            String Finalized = 'Finalized';
            String orderQuery = 'SELECT ';
            for(String sourceAPI : oppFields.keySet()){
                orderQuery += sourceAPI+',';
            }
            orderQuery += ' Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c';
            orderQuery += ' FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c = : IdOfQuote' ;
            orderQuery += ' AND Apttus_Config2__ConfigurationId__r.Apttus_Config2__Status__c =: Finalized'; // take only the line items for the last prod config

            QCLine = Database.query(orderQuery);
            system.debug('QuoteConfigLineItem'+ QCLine);
            return QCLine;
    }




    /**
    * @description Gets all field detail of Order__c based on the Id
    * @author Appirio (JefF)
    * @date 10/27/2015
    * @param IdOfOrders, ExtraQuery
    * @returns List<Order__c> List of Orders
    */
    private List<Order__c> getOrders(Set<Id> IdofOrders, String ExtraQuery){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','getOrders');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            Map<String, Schema.SObjectField> orderFields = sObjectAndFields.get('Order__c');
            List<Order__c> OrderList = new List<Order__c>();
            String orderQuery = 'SELECT ';
            for(String sourceAPI : orderFields.keySet()){
                orderQuery += sourceAPI+',';
            }
            orderQuery = orderQuery.removeEnd(',');

            //Jeff L added this to query some extra relationships needed for logic
            if(ExtraQuery != null){
                orderQuery += ', ' + ExtraQuery;
            }

            orderQuery += ' FROM Order__c WHERE  Id IN: IdofOrders' ;

            OrderList = Database.query(orderQuery);
            system.debug('OrderList'+ OrderList);
            return OrderList;
        }catch(DMLException e){
            ExceptionLog.add('DMLException', 'CreditRequestTriggerHelper', 'getOrders', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to get the Orders.' ,e);
        }
    }

    /**
    * @description Gets all field detail of Opportunity
    * @author Cloudsherpas
    * @date 06/11/2014
    * @story 0523
    * @element E1643,E1623
    * @param none
    * @returns none
    */
    private void getAllFields(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','getAllFields');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Utility util = new Utility();
        sObjectAndFields = new Map<String, Map<String, Schema.SObjectField>>();
        sObjectAndFields  = util.getAllSObjectFieldsBySObjectName(new Set<String>{'Opportunity',
                                                                                  'Apttus_Proposal__Proposal__c',
                                                                                  'Apttus_Proposal__Proposal_Line_Item__c',
                                                                                  'Apttus_Config2__LineItem__c',
                                                                                  'Apttus_Config2__ProductConfiguration__c',
                                                                                  'Apttus_QPConfig__ProposalProductAttributeValue__c',
                                                                                  'Apttus_Config2__ProductAttributeValue__c',
                                                                                  'Order__c'});
    }
    /**
    * @description Update the StageName of Opportunity
    * @author Cloudsherpas
    * @date 07/10/2014
    * @story 0523
    * @element E1643,E1623
    * @param none
    * @returns none
    */
    /*@future
    public static void updateStage(set<Id> oId, set<Id> qId){
        final String CLASSNAME = '\n\n**** CreditRequestTriggerHelper.METHODNAME()';
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateStage');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        //try{
            List<Opportunity> oppToBeUpdated = new  List<Opportunity>();
            List<Opportunity> opp = new  List<Opportunity>([SELECT stageName FROM OPPORTUNITY WHERE ID in : oID]);

            List<Apttus_Proposal__Proposal__c> qToBeUpdated = new  List<Apttus_Proposal__Proposal__c>();
            List<Apttus_Proposal__Proposal__c> quo = new  List<Apttus_Proposal__Proposal__c>([SELECT Id,
                                                                                                    //PaymentTerm__c,
                                                                                                    CreditRequest__c FROM Apttus_Proposal__Proposal__c WHERE ID in : qID]);
            Set<Id> crID = new Set<Id>();
            for(Apttus_Proposal__Proposal__c q : quo){
                crID.add(q.CreditRequest__c);
            }

            List<Credit_Request__c> CreReq = new  List<Credit_Request__c>([SELECT Id
                                                                                  //PaymentTerm__c
                                                                                  FROM Credit_Request__c WHERE ID in : crID]);
            map<Id, String> crPayment = new map<Id, String>();
            for(Credit_Request__c cReq : CreReq){
                crPayment.put(cReq.Id, ''); //cReq.PaymentTerm__c);
            }

            for(Apttus_Proposal__Proposal__c quoteList : quo){
                if(crPayment.get(quoteList.CreditRequest__c) != null){
                    //quoteList.PaymentTerm__c = crPayment.get(quoteList.CreditRequest__c);
                    qToBeUpdated.add(quoteList);
                }
            }
            if(qToBeUpdated.size() > 0){
                update qToBeUpdated;
            }

            for(Opportunity o : opp){
                o.Skip_Stage_Validation__c = True;
                o.stageName = 'Stage 3 - Quote';
                oppToBeUpdated.add(o);
            }
            if(oppToBeUpdated.size() > 0){
                update oppToBeUpdated;
            }
        /*} catch(DMLException e){
            ExceptionLog.add('DMLException', 'CreditRequestTriggerHelper', 'updateStage', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to update Opportunity.' ,e);
        }*/
    /*}*/

    /*
    @author : Appirio
    @description :  Will populate the Manager, ManagersManager, VP, SVP on the credit request
    @date : 12/14/15
    @param : creditRequest
    @return : nothing
    */
    public void populateManagerInfoOnCreditRequest(List<Credit_Request__c> creditRequest){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populateManagerInfoOnCreditRequest');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        Set<Id> userIdsToQuery = new Set<Id>();
        Set<Id> ordersToQuery = new Set<Id>();
        Map<Id, User> userMap = new Map<Id,User>();
        Map<Id,Order__c> orderMap = new Map<Id,Order__c>();
        Map<Id,UserRole> userRoleMap = new Map<Id,UserRole>();
        Set<Id> roleIdtoQuery = new Set<Id>();
        Set<Id> vpAndSVPUsersRoles = new Set<Id>();
        Map<Id,Id> roleToVPsMap = new Map<Id,Id>();
        List<Credit_Request__c> naCreditRequests = new List<Credit_Request__c>();
        //We need to populate the Manager, Managers Manager And in the case of North America the
        //SVP and VP fields with users.

        //First lets get the Manager and Managers Manager of the user who is the primary sales rep.
        for(Credit_Request__c cr : creditRequest){
            if(cr.PrimarySalesRep__c != null){
                userIdsToQuery.add(cr.PrimarySalesRep__c);
            }
            if(cr.Order__c != null){
                 ordersToQuery.add(cr.Order__c);
            }
        }

        //query the users
        if(!userIdsToQuery.isEmpty()){
            for(User u : [SELECT Id, ManagerId, Manager.ManagerId, UserRoleId FROM User WHERE Id in :userIdsToQuery]){
                userMap.put(u.Id, u);
                roleIdToQuery.add(u.UserRoleId);
            }
        }
        //query the order (this is to get the Organiziation needed for later)
        if(!ordersToQuery.isEmpty()){
            orderMap = new Map<Id,Order__c>([Select Id, AccountOrganization__c from Order__c WHERE Id in :ordersToQuery]);
        }

        //really dumb for loop becuase I need to traverse up the role hierachy to see if I can find the SVP and VP
        //Loop over this 5 times to be safe, adds 5 extra queries to our creation logic.  The loop queries the roles
        //gets their parent ides, and then sets up for the next iteration where it will now query the parent IDs
        for(Integer i=0;i<5;i++){
            Set<Id> nextSetToQuery = new Set<Id>();
            for(UserRole ur : [Select Id, DeveloperName, ParentRoleId from UserRole where Id in :roleIdToQuery]){
                userRoleMap.put(ur.ID,ur);
                nextSetToQuery.add(ur.ParentRoleId);
            }
            roleIdToQuery = nextSetToQuery;
        }

        //Finally we have all the details so that we can now populate the fields on the credit requests
        for(Credit_Request__c cr : creditRequest){
            //first we populate the manager and managers manager since all requests need that
            if(userMap.containsKey(cr.PrimarySalesRep__c)){
                cr.Manager__c = userMap.get(cr.PrimarySalesRep__c).ManagerId;
                cr.ManagersManager__c = userMap.get(cr.PrimarySalesRep__c).Manager.ManagerId;

                //now for NA we will get the roleIds needed to query for the Users who are in those roles (so we can populate on the credit request)
                if(orderMap.get(cr.Order__c).AccountOrganization__c == 'North America'){

                    naCreditRequests.add(cr);
                    System.debug('userMap.get(cr.PrimarySalesRep__c).UserRoleId'+userMap.get(cr.PrimarySalesRep__c).UserRoleId);
                    System.debug('cr.PrimarySalesRep__c'+cr.PrimarySalesRep__c);
                    Map<String,Id> crRoles = getVPAndSVPIDs(userRoleMap, userMap.get(cr.PrimarySalesRep__c).UserRoleId);
                    if(crRoles.get('VP') != null){
                        vpAndSVPUsersRoles.add(crRoles.get('VP'));
                    }
                    if(crRoles.get('SVP') != null){
                        vpAndSVPUsersRoles.add(crRoles.get('SVP'));
                    }
                }
            }
        }

        //EU is done now, all the rest of this logic is just for NA
        //Need to find the Users associated with our VP and SVP roles, then finally populate those
        //User Ids on the credit request records
        if(!vpAndSVPUsersRoles.isEmpty()){
            //query users in those roles
            for(User u : [Select Id, UserRoleId from User where UserRoleId in :vpAndSVPUsersRoles]){
                roleToVPsMap.put(u.UserRoleId, u.Id);
            }
        }

        //finally iterate through the credit requests and populate the VP and SVP roles
        for(Credit_Request__c cr : naCreditRequests){
            Map<String,Id> crRoles = getVPAndSVPIDs(userRoleMap, userMap.get(cr.PrimarySalesRep__c).UserRoleId);

            if(crRoles.get('VP') != null){
                cr.VP__c = roleToVPsMap.get(crRoles.get('VP'));
            }
            if(crRoles.get('SVP') != null){
                cr.SVP__c = roleToVPsMap.get(crRoles.get('SVP'));
            }
        }
    }

    /*
    @author : Appirio
    @description : little helper method to figure out what is the VP and SVP given a map or roles
    a starting role
    @date : 12/14/15
    @param : UserRoleMap, StartingUserRoleId
    @return : Map of VP and SVP and their roles
    */
    private Map<String,Id> getVPAndSVPIDs(Map<Id,UserRole> pUserRoleMap, Id pStartingUserRoleId){
        //now iterate through our hierarchy trying to find VP and SVP
        Id vpId;
        Id svpId;

        Id roleToCheck = pStartingUserRoleId;
        System.debug('cr.pStartingUserRoleId'+pStartingUserRoleId);
        System.debug('cr.roleToCheck'+roleToCheck);
        String roleName;
        while((vpId == null || svpId == null) && roleToCheck != null){
            Id nextRole;
            //first lets check if the role is what we are looking for (VP or SVP)
            System.debug('puserRoleMap'+puserRoleMap);
            if(puserRoleMap.containskey(roleToCheck))
                roleName = puserRoleMap.get(roleToCheck).DeveloperName;
            if(roleName.containsIgnoreCase('SVP')){
                svpId = roleToCheck;
            } else if(roleName.containsIgnoreCase('VP')){
                vpId = roleToCheck;
            }

            //Lets see if we have a next role to check - if so keep the for loop going, if not exit
             if(puserRoleMap.containskey(roleToCheck))
                nextRole = pUserRoleMap.get(roleToCheck).ParentRoleId;
            if(nextRole == null){
                break;
            } else {
                roleToCheck = nextRole;
            }
        }

        //now lets build our return data structure
        Map<String,Id> returnMap = new Map<String,Id>();
        returnMap.put('VP',vpId);
        returnMap.put('SVP',svpId);

        return returnMap;
    }


/*
@author : CloudSherpas
@description :  Will call the updateRequest method
@date : 06/10/2014
@story 0523
@element E2162
@param : creditRequest
@return : nothing
*/
/* Jeff L Commented out for a new method for I-192425
    public void populateManagersOnCreditRequest(List<Credit_Request__c> creditRequest){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populateManagersOnCreditRequest');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        User uManager;
        User u = [SELECT Id, ManagerId, ProfileId,Profile.Name, Job_Type__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
        If(u.ManagerId != null){
            uManager = [SELECT Id, ManagerId FROM User WHERE Id =: u.ManagerId LIMIT 1];
        }
        //system.debug('\n\n\n\n u.ManagerId: '+ u.ManagerId +'\n\n\n\n\n');
        //system.debug('\n\n\n\n uManager.Id: '+ uManager.Id +'\n\n\n\n\n');
        /*Commented fetching Profile name Query as it is fetching with above user info*/
        //Profile p = [SELECT Id, Name FROM Profile WHERE Id=: u.ProfileId];
        //system.debug('\n\n\n\n p.Name: '+p.Name+'\n\n\n\n\n');
  /*      for(Credit_Request__c cr : creditRequest){
            String ProfileNameOfLoggedInUser = u.Profile.Name;
            if(ProfileNameOfLoggedInUser != null && ProfileNameOfLoggedInUser.contains('Sales Rep')){
                if(u.ManagerId != null){
                    cr.Manager__c = u.ManagerId;
                }
                if(uManager != null && uManager.ManagerId != null){
                    cr.ManagersManager__c = uManager.ManagerId;
                }
            }
        }
    }*/

/*
@author : CloudSherpas
@description :  Will call the updateRequest method
@date : 06/10/2014
@story 0523
@element E2261
@param : creditRequest
@return : nothing
*/
 /* Jeff L commented out because this was really dumb logic and wrote a better method in I-192425
    public void populateVPandSVPOnCreditRequest(Map<Id, Credit_Request__c> creditRequestMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populateVPandSVPOnCreditRequest');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));


        List<User> managerRoles = new List<User>();
        if(!creditRequestMap.isEmpty()){
            managerRoles =  [SELECT Id,UserRoleId, Job_type__c, ManagerId FROM User WHERE Id In : creditRequestMap.keySet()];
        }
        Map<Id, Credit_Request__c> crToProcessAgain = new Map<Id, Credit_Request__c>();
        List<Credit_Request__c> creditRequestToUpdate = new List<Credit_Request__c>();
        if(!managerRoles.isEmpty()){
            for(User u : managerRoles){
                Credit_Request__c cRequest = creditRequestMap.get(u.Id);
                if(u.Job_type__c != null){
                    Boolean checkedVP = false;
                    Boolean checkedSVP = false;
                    if(cRequest.VP__c == null && u.Job_type__c == 'VP'){
                        cRequest.VP__c = u.Id;
                        checkedVP = true;
                    } else if(cRequest.SVP__c == null && u.Job_type__c == 'SVP'){
                        cRequest.SVP__c = u.Id;
                        checkedSVP= true;
                    }

                    if(checkedVP || checkedSVP){
                        creditRequestToUpdate.add(cRequest);
                    }
                    if(u.ManagerId != null){
                        if(cRequest.VP__c == null || cRequest.SVP__c == null){
                            crToProcessAgain.put(u.ManagerId, cRequest);
                        }
                    }
                } else {
                    if(u.ManagerId != null){
                        if(cRequest.VP__c == null || cRequest.SVP__c == null){
                            crToProcessAgain.put(u.ManagerId, cRequest);
                        }
                    }
                }
            }

            if(!creditRequestToUpdate.isEmpty()){
                update creditRequestToUpdate;
            }

            if(!crToProcessAgain.isEmpty()){
                populateVPandSVPOnCreditRequest(crToProcessAgain);
            }
        }
    }*/

    /*
    @author : Jeff Lescarbeau (Appirio)
    @description :  A CreditRequest Wrapper class, it's use is to hold various details that are needed througout the approval process
                    used so that a bunch of maps are not needed and similar logic is contained in one place
    @date : 10/26/2015
    */
    private class CreditRequestWrapper {

        public Credit_Request__c CreditRequest {get; set;}
        public Opportunity Opportunity {get; set;}
        public Apttus_Proposal__Proposal__c Proposal {get; set;}
        public Apttus_Config2__ProductConfiguration__c ProductConfiguration {get; set;}
        public Order__c OldOrder {get; set;}
        public Order__c CreditOrder {get; set;}
        public Order__c RebillOrder {get; set;}
        public Map<Id,CreditRequestLineItem__c> CreditRequestLineItems {get;set;}

        public Id CreditRequestId {
            get{ return CreditRequest != null ? CreditRequest.Id : null;}
        }
        public Id OppId {
            get{ return Opportunity != null ? Opportunity.Id : null;}
        }
        public Id ProposalId {
            get{ return Proposal != null ? Proposal.Id : null;}
        }
        public Id OldOrderId {
            get{return OldOrder != null ? OldOrder.Id : null;}
        }
        public Boolean Credit {get;set;}
        public Boolean CreditAndRebill {get;set;}
        public Boolean CreateOrderAutomatically {get;set;}

        public CreditRequestWrapper(Credit_Request__c cr){
            CreditRequest = cr;
            if(cr.CreditScenario__c == 'Credit'){
                Credit = true;
                CreditAndRebill = false;
                if(cr.CreditReason__c == 'Tax Error'){
                    CreateOrderAutomatically = true;
                } else{
                    CreateOrderAutomatically = false;
                }
            } else if(cr.CreditScenario__c == 'Credit and Rebill'){
                Credit = false;
                CreditAndRebill = true;


                if(cr.CreditReason__c == 'Change in Non-Standard Payment Terms' ||
                    cr.CreditReason__c == 'Change in Standard Payment Terms' ||
                    cr.CreditReason__c == 'Payment term changes' ||
                    cr.CreditReason__c == 'Billing Start Date Correction' ||
                    cr.CreditReason__c == 'Incorrect tax' ||
                    cr.CreditReason__c == 'Payment type incorrect' ||
                    cr.CreditReason__c == 'Federal or State/Province/HST Tax Issue'){
                    CreateOrderAutomatically = true;
                } else {
                    CreateOrderAutomatically = false;
                }
            }
            /*if (CreateOrderAutomatically){
                /*JFreese Appirio 01/25/17 S-452628
                  Set a flag available to case & order triggers which will let them
                  bypass designated validation rules if we are in CR/Rebill Automated handling
                system.debug('^^^CreateOrderAutomatically is true, so setting CreditRequestTriggerHandler.CreateOrdersAutomatically to true');
                CreditRequestTriggerHandler.CreateOrdersAutomatically = true;
            }else{
                system.debug('^^^CreateOrderAutomatically is false, so not setting CreditRequestTriggerHandler.CreateOrdersAutomatically to true');
            }*/

        }
    }
}