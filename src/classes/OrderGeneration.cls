/********************************************
Appirio J Freese
9Feb2016
Class to collect order generation methods called by both
OpportunityTriggerHandler and PaypalModel
********************************************/
public without sharing class OrderGeneration
{
    final String CLASSNAME = '\n\n**** OrderGeneration.METHODNAME()';
    public Org_Settings__c orgSettings = Org_Settings__c.getInstance();
    public Integer cutoff = Integer.valueOf(orgSettings.Debug_Log_Record_Count_Cutoff__c); //JFreese Appirio S-435483 4/10/17
    public Id debugId = orgSettings.Debug_Log_Record_ID__c; //JFreese Appirio S-435483 4/11/17


    public static OrderGeneration NewOrderGeneration(){
        OrderGeneration newOrderGeneration = new OrderGeneration();
        return newOrderGeneration;
    }


//TEST FOR E1736
/*
** @author : Cloud Sherpas, Inc.
** @date : 03/28/2014
** @Story: 0699, 0523
** @Task: E1300, E1644
** @description : setCredit Status on Opportuntiy from Account
** @paramaters : list of Opportunity
** @returns : none
** @Updates : WhenEver Order is created for the Opportunity Without Approved Status, mark the Rejected Reason for
              Such Orders as "Missing All Required Approvals"
** @Update Date : 05/15/2014
*/
    public void createOrder(list<Opportunity> pNewOpportunity, Map<Id, Opportunity> pOldOpportunityMap){
    system.debug('***entry****');
        final string METHODNAME = CLASSNAME.replace('METHODNAME','createOrder');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        Id newsPaperRecordTypeId =  Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Newspaper Partner').getRecordTypeId();
        Utility util = new Utility();
        Map<String, Map<String, Schema.SObjectField>> sObjectAndFields = util.getAllSObjectFieldsBySObjectName(new Set<String>{
            'Order_Line_Item__c', 'Apttus_Proposal__Proposal_Line_Item__c',
            'Line_Item_Attribute__c', 'Apttus_QPConfig__ProposalProductAttributeValue__c',
            'OrderTeam__c', 'OpportunityTeamMember__c',
            'Order__c','Apttus_Proposal__Proposal__c'
            // Story 1783, Task E2243
            ,'QuoteProposalId__c'
        });

        if (pNewOpportunity.size() <= cutoff){ //JFreese Appirio S-435483 4/10/17
            system.debug('NEWOPPS '+pNewOpportunity);
            system.debug('OLDOPPSMAP '+pOldOpportunityMap);
        }

        //Story 0780,Task E1638-------------
        map<String, map<String, Id>> RecordTypes = Utility.GetRecordTypeIdsBySObjectNameSet(new Set<String>{'Opportunity', 'Order__c'});
        map<String, Id> OppRecordTypes = RecordTypes.get('Opportunity');
        map<String, Id> OrderRecordTypes = RecordTypes.get('Order__c');
        //------------------------------------

        Map<String, Schema.SObjectField> orderFields = sObjectAndFields.get('Order__c');
        Map<String, Schema.SObjectField> orderSourceFields = sObjectAndFields.get('Apttus_Proposal__Proposal__c');

        try{
            Map<Id, Opportunity> oppIdToOppMap = new Map<Id, Opportunity>();
            if (pNewOpportunity.size() <= cutoff){ //JFreese Appirio S-435483 4/10/17
                system.debug('#######pNewOpportunity###' +pNewOpportunity);
            }

            for(Opportunity opp : pNewOpportunity){
                if (pNewOpportunity.size() <= cutoff || opp.Id == debugId){ //JFreese Appirio S-435483 4/10/17
                    system.debug('#####opp###' +opp.Name);
                    system.debug('**OPP orderCreated__c '+ opp.OrderCreated__c);
                    system.debug('***opp.OrderCreated__c***' +opp.OrderCreated__c + '####pOldOpportunityMap.get(opp.Id).OrderCreated__c####' +pOldOpportunityMap.get(opp.Id).OrderCreated__c);
                }
                if(opp.OrderCreated__c && !pOldOpportunityMap.get(opp.Id).OrderCreated__c){
                    if (pNewOpportunity.size() <= cutoff || opp.Id == debugId){ //JFreese Appirio S-435483 4/10/17
                       system.debug('***entrycheckflag*********');
                    }
                    oppIdToOppMap.put(opp.Id, opp);
                }
            }
            if(oppIdToOppMap.size() == 0){
                system.debug('No Orders to create.');
                return;
            }
            String proposalQuery = 'SELECT ';
            for(String sourceAPI : orderSourceFields.keySet()){
                proposalQuery += sourceAPI+',';
            }

            proposalQuery = proposalQuery.removeEnd(',');
            String innerProposal = ', (' + proposalQuery + ' FROM Proposals__r)';
            proposalQuery += innerProposal + ' FROM Apttus_Proposal__Proposal__c WHERE Apttus_Proposal__Primary__c = true AND ';
            Set<Id> oppIds = oppIdToOppMap.keySet();
            proposalQuery += 'Apttus_Proposal__Opportunity__c IN :oppIds';

            list<Apttus_Proposal__Proposal__c> proposalList = Database.query(proposalQuery);
           // system.assert(false , proposalList );
             Map<Id, Order__c> proposalIdToOrderMap = new Map<Id, Order__c>();
            Integer errorFields = 0;


            RecordTypeIDs__c recordTypeIds= RecordTypeIDs__c.getInstance();

            for(Apttus_Proposal__Proposal__c usedProp : proposalList){
                if(oppIdToOppMap.containsKey(usedProp.Apttus_Proposal__Opportunity__c)){
                    Opportunity opp = oppIdToOppMap.get(usedProp.Apttus_Proposal__Opportunity__c);

                    system.debug('\n\n' + usedProp.Name + ' child proposals: ' + usedProp.Proposals__r.size() + ' \n\n');
                    //for story 0813 task E1736: get all child proposals if multiple quote and international deal is checked otherwise use the current proposal
                    Apttus_Proposal__Proposal__c[] usedProps = usedProp.MultipleQuotes__c && opp.InternationalDeal__c ? usedProp.Proposals__r : new Apttus_Proposal__Proposal__c[]{usedProp};
                    if(usedProps.size() > 0){
                        for(Apttus_Proposal__Proposal__c prop : usedProps){
                            Order__c newOrder = new Order__c();

                            proposalIdToOrderMap.put(prop.Id, newOrder);
                            system.debug('^^^ Proposal ID=' + prop.Id + ', AgencyIO__c=' + prop.AgencyIO__c);

                            //system.debug('***neworder 1** Order_Type__c=' + newOrder.Order_Type__c  );
                            system.debug(LoggingLevel.INFO,'Field not yet available or Invalid API Name in Order object: ');
                            String copy = '^^^ Matching API fields copied from Quote ' + prop.Id + ' to new Order: ';
                            String setOrderType = '';
                            for(String sourceAPI : orderSourceFields.keySet()){
                                String targetAPI = getTargetApttusFieldAPIName(sourceAPI);

                                if(sourceAPI != 'recordtypeid' && prop.get(sourceAPI) != null && orderFields.containsKey(targetAPI)){

                                    //if(orderFields.get(targetAPI).getDescribe().isUpdateable()){
                                    if(targetAPI != 'Id'){
                                        try{

                                            newOrder.put(targetAPI, prop.get(sourceAPI));
                                            copy += targetAPI + '=' + newOrder.get(targetAPI) + ', ';
                                           /* if(targetAPI == 'Order_Type__c'){
                                                newOrder.put(targetAPI,'New');
                                                newOrder.Order_Sequence__c = 'First Time';
                                                setOrderType = '^^^ Set Order.Order_Type__c=' + newOrder.Order_Type__c + ', Order_Sequence__c=' + newOrder.Order_Sequence__c;
                                             }*/
                                        }catch(Exception e){
                                            errorFields++;
                                            system.debug(LoggingLevel.INFO,'Order field error: API Name = ' + targetAPI + ' ');
                                        }
                                    }
                                }else{
                                    if(!orderFields.containsKey(targetAPI) && sourceAPI != 'recordtypeid'){
                                        errorFields++;
                                        system.debug(LoggingLevel.INFO,orderSourceFields.get(sourceAPI).getDescribe().getLabel() + ' type: ' + orderSourceFields.get(sourceAPI).getDescribe().getType());
                                    } else {
                                         system.debug(LoggingLevel.INFO,orderSourceFields.get(sourceAPI).getDescribe().getLabel() + ' type: ' + orderSourceFields.get(sourceAPI).getDescribe().getType());
                                    }

                                }
                            }
                            copy.removeEnd(', ');
                            System.debug(copy);
                            if (setOrderType != ''){System.debug(setOrderType);}
                            //system.debug('***neworder 2** Order_Type__c=' + newOrder.Order_Type__c  );
                            newOrder = hardcodedOrderFields(prop,newOrder,opp);
                            system.debug('***neworder 3** AgencyIO__c=' + newOrder.AgencyIO__c);
                        }
                    }
                }
            }
            //story 1783, task E2243
            //Added by DinoBrinas
            //Story 1783/2895
            List<ProductUserQuoteLine2OrderLine__c> updateQuoteToOrder = new List<ProductUserQuoteLine2OrderLine__c>();
            map<Id, ProductUserQuoteLine2OrderLine__c> mapUpdateQuoteToOrder = new map<Id, ProductUserQuoteLine2OrderLine__c>();
            // This iteration is use to get all Quote/Proposal ID to be used on the other object
            system.debug('There are ' + errorFields + ' field(s) not yet available or Invalid API Name in Order object');
            // Verify if the Quote/Proposal has been successfully populated

            if(proposalIdToOrderMap.size() > 0){
                //JFreese Appirio 3/10/17 S-445803

                /*Jfreese Appirio 4/11/17 S-475349
                    The following approach was created for S-445803/S-473744:
                    1) If the current user is not the Echosign user, then call insertOrder & CreateOLIandVerify,
                       which is effectively exactly the same flow as before the S-445803 edits started.
                    2) Else (the current user is not the Echosign user), then call insertOrder & CreateOLIandVerify
                       in queueables.  It was hoped the brief delay to enqueue would provide enough time to prevent
                       record lock error.  Unfortunately this was not the case, not much improvement.
                       The solution to S-445803/S-473744 is to be found elsewhere, in the Echosign Agreement trigger.

                    However, the same trick is ideal for another problem poased by S-475349, APEX CPU timeouts
                    on very large orders with (e.g.) > 50 line items.  If the flow is diverted to queueables at this
                    point in the Send to Order process, the CPU limits jumps from 10 seconds to 60.

                    So co-opt the approach and rename things a bit to not refer to Echosign.*/

                Set<Id> proposalIds = proposalIdToOrderMap.keySet();
                List<Apttus_Proposal__Proposal_Line_Item__c> propLIs = [SELECT Id from Apttus_Proposal__Proposal_Line_Item__c
                                                                        WHERE Apttus_Proposal__Proposal__c IN: proposalIds];
                String dbg = '^^^There are a total of '+propLIs.size()+' proposal line items to process ';
                if (proposalIds.size() == 1){
                    dbg += 'for the proposal';
                }else {
                    dbg += 'out of a total of '+proposalIds.size()+' proposals';
                }
                system.debug(dbg);

                Boolean enqueueOrderCreationProcess = false;
                Integer maxLineItem = Integer.valueOf(orgSettings.Line_Item_Synch_Cutoff__c);

                if (propLIs.size() > maxLineItem){
                    enqueueOrderCreationProcess = true;
                    dbg = 'The proposal line item count of '+propLIs.size()+' is greater than the ';
                    dbg += 'limit set by Org_Settings__c.Line_Item_Synch_Cutoff__c ('+maxLineItem+'), ';
                    dbg += 'so setting enqueueOrderCreationProcess to '+enqueueOrderCreationProcess;

                    System.debug(dbg);
                }else{
                    System.debug('No change to the processing sequence');
                }

                if (enqueueOrderCreationProcess == false){
                    //This is the original process, now called via two methods
                    String e = insertOrder(proposalIdToOrderMap);
                    if (e != null && e != ''){
                        throw BaseApplicationException.NewException('createOrder', 'Order creation failed: '+e);
                    }
                    CreateOLIandVerify(proposalIdToOrderMap, proposalList, sObjectAndFields);
                }else{
                    //This is the same process broken into queuables
                    queueableInsertOrder one = new queueableInsertOrder();
                    one.proposalIdToOrderMap = proposalIdToOrderMap;
                    one.proposalList = proposalList;
                    one.sObjectAndFields = sObjectAndFields;
                    system.debug('^^^Calling queueable queueableInsertOrder()');
                    System.enqueueJob(one);
                }
            }else{
                system.debug('No order to create.');
            }
        }catch(BaseApplicationException bae){
            throw bae;
        }catch(Exception e){
            throw BaseApplicationException.NewExceptionWithInnerException('createOrder', e.getMessage(), 'Failed to create order. ' + e + '    ', e);
        }
    }

    /*
    @author : JFreese Appirio  3/10/17 S-445803
    @description : Queueable classes for enqueueOrderCreationProcess
    */
    public class queueableInsertOrder implements Queueable {
        public Map<Id, Order__c> proposalIdToOrderMap;
        public Apttus_Proposal__Proposal__c[] proposalList;
        public Map<String, Map<String, Schema.SObjectField>> sObjectAndFields;

        public void execute(QueueableContext context){
            system.debug('^^^Inside queueable queueableInsertOrder()');
            String result = insertOrder(proposalIdToOrderMap);
            system.debug('^^^Finished call to insertOrder()');

            if (result == ''){
                queueableCreateOLIandVerify two = new queueableCreateOLIandVerify();
                two.proposalIdToOrderMap = proposalIdToOrderMap;
                two.proposalList = proposalList;
                two.sObjectAndFields = sObjectAndFields;
               system.debug('^^^Calling queueable queueableCreateOLIandVerify()');
               System.enqueueJob(two);
            }else {
                system.debug('^^^Halting because insertOrder() returned the following error: '+result);
            }
        }
    }
    public class queueableCreateOLIandVerify implements Queueable {
        public Map<Id, Order__c> proposalIdToOrderMap;
        public Apttus_Proposal__Proposal__c[] proposalList;
        public Map<String, Map<String, Schema.SObjectField>> sObjectAndFields;

        public void execute(QueueableContext context){
            system.debug('^^^Inside queueable queueableCreateOLIandVerify()');
            CreateOLIandVerify(proposalIdToOrderMap, proposalList, sObjectAndFields);
            system.debug('^^^Finished call to CreateOLIandVerify()');
        }
    }

    /*
    @author : JFreese Appirio 3/8/17 S-445803
    @description : A method to insert the new order(s)
    @date : 3/8/17
    @param : Map<Id, Order__c> proposalIdToOrderMap
    @return : Exception message
    Note: This is the first section of the original 'if(proposalIdToOrderMap.size() > 0' block
    */
    public static String insertOrder(Map<Id, Order__c> proposalIdToOrderMap){
        system.debug('**** Inside OrderGeneration.insertOrder ****');

        String result ='';
        OrderTriggerHandler.executeUpdateTrigger = false;
        ApttusProposalTriggerHandler.ExecuteTriggers = false;
        AccountTriggerHandler.ExecuteTriggers = false;
        OrderLineItemTriggerHandler.ExecuteUpdate = false;
        system.debug('****proposalIdToOrderMap**' +proposalIdToOrderMap.values());
        try{
            insert proposalIdToOrderMap.values();
        }catch(Exception e){
            result = e.getMessage();
            //throw BaseApplicationException.NewExceptionWithInnerException('createOrder', 'Order creation failed: ' + e,  e);
        }
        return result;
    }

    /*
    @author : JFreese Appirio 3/8/17 S-445803
    @description : A method to Create the Order Line Items, Verify the order and conduct other logic
    @date : 3/8/17
    @param : Map<Id, Order__c> proposalIdToOrderMap
    @return : nothing
    Note: This is the second section of the original 'if(proposalIdToOrderMap.size() > 0' block
    */
    private static void CreateOLIandVerify(Map<Id, Order__c> proposalIdToOrderMap, Apttus_Proposal__Proposal__c[] proposalList, Map<String, Map<String, Schema.SObjectField>> sObjectAndFields){
        system.debug('**** Inside OrderGeneration.CreateOLIandVerify ****');

        List<ProductUserQuoteLine2OrderLine__c> updateQuoteToOrder = new List<ProductUserQuoteLine2OrderLine__c>();
        map<Id, ProductUserQuoteLine2OrderLine__c> mapUpdateQuoteToOrder = new map<Id, ProductUserQuoteLine2OrderLine__c>();

        CreateOrderLineItems(ProposalIdToOrderMap, proposalList, null, sObjectAndFields);
        //CreateOrderTeamMember2(oppIdToOppMap.keySet(), proposalIdToOrderMap.values(), sObjectAndFields);

        /*JFreese Appirio 3/4/17 S-456572
        If we got here via CreditRequestTriggerHelper.AsyncAutoCreateOrder, APTS_Order_QueueInterFace would
        use up the only child queueable, preventing AsyncAutoCreateCreditOpportunity from being run.
        But we don't always want to call APTS_creditHelper.SendForVerification in a future, as we might
        also have gotten here via a future call.  So send via future if in a queueable,
        else if in a future (or in synchronous processing) send via queueable*/
        String dbg = '^^^Preparing to make an asynchronous call to send proposal IDs to APTS_creditHelper.SendForVerification\n';
        if (system.isQueueable()){
            dbg += 'We are already in a queueable job: Limits.getQueueableJobs(): '+Limits.getQueueableJobs()+' out of '+Limits.getLimitQueueableJobs()+', ';
            dbg += 'so call SendForVerification in a future call.';
            system.debug(dbg);
            futureSendForVerification(proposalIdToOrderMap.keySet());
        }else{
            if (system.isFuture()){
                dbg += 'We are not in a queueable but are in a future job: Limits.getQueueableJobs(): '+Limits.getQueueableJobs()+' out of '+Limits.getLimitQueueableJobs()+', ';
            }else{
                dbg += 'We are not in either a queueable or a future job: Limits.getQueueableJobs(): '+Limits.getQueueableJobs()+' out of '+Limits.getLimitQueueableJobs()+', ';
            }
            dbg += 'so call SendForVerification in a queueable.';
            system.debug(dbg);
            ID jobID = System.enqueueJob(new APTS_Order_QueueInterFace(proposalIdToOrderMap.keySet()));
        }
        //   APTS_creditHelper.SendForVerification(proposalIdToOrderMap.keySet());

        //Added by DinoBrinas
        //Story 1783/2895, Task E2243
        // After creating the OrderLineItem above (using CreateOrderLineItems method),
        //   we need to use the orderLineItem Id to fetch all related data particularly
        //   in Quote/Proposal Id, Quote/Proposal Line Item Id, and Contacts.
        // Note: 1. After the user clicks the Send To Order button from the Opportunity page,
        //           NEW OrderLine Item will be created automatically.
        //       2. When you go to the related list of the page Quote and ProposalLineItem,
        //           OrderLineItem,ProposalLineItem, Quote and QuoteLine Item must be inserted
        //           or updated and see to it that the OrderLineItem is latest version.
        //
        // Instantiate a list of Id to be populated by the Quote/ProposalID
        system.debug('^^^ Start Remaining logic');
        List<id> proposalIdToOrderMapIds = new List<id>();
        for(Id proposalIdToOrderMapId : proposalIdToOrderMap.keySet() ){
            proposalIdToOrderMapIds.add(proposalIdToOrderMapId);
        }
        // Fetch the orderLineItem using the Proposal ID
        List<Order_Line_Item__c> ordreLineItemList2 = [SELECT id, proposal__c, SEND_TO_ORDER_QUOTELineItem__c from Order_Line_Item__c
                                                                    where proposal__c IN :proposalIdToOrderMapIds ];
        // Then, fetch all JunctionObject and ProposalLineItem data to be populated or updated
        List<Id> proLineItemIds = new List<id>();
        for(Order_Line_Item__c oProItens : ordreLineItemList2){
            proLineItemIds.add(oProItens.SEND_TO_ORDER_QUOTELineItem__c);
        }
        // The use of this variable is to fetch the existing data on the JunctionObject
        List<ProductUserQuoteLine2OrderLine__c> quoteToOrder2 = [SELECT Quote_Proposal__c, Proposal_Line_Item__c, Order_Line_Item__c
                                                              FROM ProductUserQuoteLine2OrderLine__c
                                                             WHERE Proposal_Line_Item__c IN :proLineItemIds];
        // Fetch the  related ProposalLineItem
        List<Apttus_Proposal__Proposal_Line_Item__c> quoteLineItem2 = [SELECT Apttus_Proposal__Proposal__c
                                                                             , Id
                                                                        FROM Apttus_Proposal__Proposal_Line_Item__c
                                                                       WHERE id IN :proLineItemIds];
        // Iterate the JunctionObject, followed by OrderLineItem
        // if JunctionObject or OrderLineItem is empty or no data were selected,
        //   no action will be made.
        for(ProductUserQuoteLine2OrderLine__c qToOrder : quoteToOrder2 ){
            if( !(qToOrder.Proposal_Line_Item__c == null) ) {
                for(Order_Line_Item__c oOrderLI : ordreLineItemList2){
                    String proposalId_lineItem = qToOrder.Proposal_Line_Item__c;
                    String orderId_lineItem = oOrderLI.SEND_TO_ORDER_QUOTELineItem__c;
                    System.debug('proposalId_lineItem.subString(0,15)  >>>> ' + proposalId_lineItem.subString(0,15) + '   orderId_lineItem  >>>>>' + orderId_lineItem);
                    if(proposalId_lineItem.subString(0,15) == orderId_lineItem ){
                        ProductUserQuoteLine2OrderLine__c updateTempQuoteToOrder = new ProductUserQuoteLine2OrderLine__c();
                        System.debug('qToOrder.Quote_Proposal__c =' + qToOrder.Quote_Proposal__c + '  oOrderLI.proposal__c=' + oOrderLI.proposal__c);
                        updateTempQuoteToOrder.id = qToOrder.id;
                        updateTempQuoteToOrder.Order_Line_Item__c = oOrderLI.id;
                        updateTempQuoteToOrder.Quote_Proposal__c = qToOrder.Quote_Proposal__c;
                        updateTempQuoteToOrder.Proposal_Line_Item__c = qToOrder.Proposal_Line_Item__c;
                        updateQuoteToOrder.add(updateTempQuoteToOrder);
                        mapUpdateQuoteToOrder.put(qToOrder.id,updateTempQuoteToOrder);
                    }
                }
            }
        }

        if (mapUpdateQuoteToOrder.size() > 0){
            system.debug('^^^Updating ProductUserQuoteLine2OrderLine__c records: mapUpdateQuoteToOrder.size()='+mapUpdateQuoteToOrder.size());
            update mapUpdateQuoteToOrder.values();
        }else{
            system.debug('^^^No ProductUserQuoteLine2OrderLine__c records to update');
        }

        // Restrict the order creation process only for online flow I-202296

        map<Id, Order__c> mapOrder = new map<Id, Order__c>([Select Id, QuoteProposal__r.QuoteStatus__c from Order__c
                                                            Where Id IN : proposalIdToOrderMap.values()]);

        Set<ID> orderIdList = new Set<ID>();
        for(Order__c ord : proposalIdToOrderMap.values()){

            if(mapOrder.containsKey(ord.ID) && mapOrder.get(ord.ID) != null){
                if(mapOrder.get(ord.ID).QuoteProposal__c != null && mapOrder.get(ord.ID).QuoteProposal__r.QuoteStatus__c == 'Accepted Online'){
                     orderIdList.add(ord.ID);
                }

            }
        }
        if(orderIdList.size() > 0){
            updateOrderStatusForOnlineFlow(orderIdList);
            system.debug('^^^calling updateOrderStatusForOnlineFlow(orderIdList) '+', orderIdList.size()='+orderIdList.size());
            /*OnlineFlowProcess ofp = new OnlineFlowProcess();
            ofp.setOfOrderIds = orderIdList;
            System.enqueueJob(ofp);*/
        }else{
            system.debug('^^^No records to update via updateOrderStatusForOnlineFlow()');
        }
        //updateOrderStatusForOnlineFlow(orderIdList);
        //system.assert(false, proposalIdToOrderMap);
    }

    /*
    @author : JFreese Appirio 3/4/17 S-456572
    @description : A future callout alternative to APTS_Order_QueueInterFace for when we are already in a queueable
    @date : 3/3/17
    @param : set of proposal IDs
    @return : nothing
    */
    @future
    public static void futureSendForVerification(Set<Id> OldProposalset){
        system.debug('**** Inside OrderGeneration.futureSendForVerification');
        APTS_creditHelper oClass = new APTS_creditHelper();
        oClass.SendForVerification(OldProposalset);
    }

    //JFreese Appirio 3/10/17 S-445803 changed this method to static to make visible to queueable
    private static String getTargetApttusFieldAPIName(String pSourceAPIName){
        String[] sourceApiSplit = pSourceAPIName.split('__');
        String sourcePrefix = sourceApiSplit!=null && sourceApiSplit.size() > 2 ? sourceApiSplit[0] + '__' : '';
        return sourcePrefix == '' ? pSourceAPIName : pSourceAPIName.removeStart(sourcePrefix);
    }



    //JFreese Appirio 3/10/17 S-445803 changed this method to static to make visible to queueable
    private static void CreateOrderLineItems(Map<Id, Order__c> pProposalIdToOrderMap, Apttus_Proposal__Proposal__c[] pProposalList, Map<Id, Order__c> pOppIdToOrderMap, Map<String, Map<String, Schema.SObjectField>> sObjectAndFields){
        system.debug('**** Inside OrderGeneration.CreateOrderLineItems ****');
        set<id> accountIds = new set<id>();

        for (order__c order : pProposalIdToOrderMap.values()){
            accountIds.add(order.account__c);
        }

        map<string,string> accountToXcode = new map<string,string>();
        for (XcodeAccount__c  axcode : [select id,account__c, Xcode__c  from XcodeAccount__c  where account__c in :accountIds and IsPrimary__c =true]){
            accountToXcode.put(axcode.account__c, axcode.id);
        }
        String quoteQuery = 'SELECT ';
        for(String f : sObjectAndFields.get('Apttus_Proposal__Proposal_Line_Item__c').keySet()){
            quoteQuery += f + ',';
        }
        quoteQuery = quoteQuery.removeEnd(',');
        set<Id> propIdSet = pProposalIdToOrderMap.keySet();
        quoteQuery += ',Apttus_Proposal__Proposal__r.XcodeAccount__c,Apttus_Proposal__Proposal__r.Xcode_Name__c';
        quoteQuery += ' FROM Apttus_Proposal__Proposal_Line_Item__c WHERE Apttus_Proposal__Proposal__c IN :propIdSet ';
        quoteQuery +=   'AND Apttus_QPConfig__LineStatus__c <> \'Converted\'';
        try{
            Map<String, Schema.SObjectField> orderLineItemFields = sObjectAndFields.get('Order_Line_Item__c');
            Map<String, Schema.SObjectField> orderLineItemSourceFields = sObjectAndFields.get('Apttus_Proposal__Proposal_Line_Item__c');
            Id oliRecordType = Utility.GetRecordTypeIdBySObjectNameAndType('Order_Line_Item__c', 'Order Line Item');

            Order_Line_Item__c[] orderLineItemToInsert = new Order_Line_Item__c[]{};
            Apttus_Proposal__Proposal_Line_Item__c[] quotesLineItemList = Database.query(quoteQuery);
            system.debug('CHECK ME: pProposalIdToOrderMap=' + pProposalIdToOrderMap);
            if(quotesLineItemList.size() >0){
                Map<Id, Order_Line_Item__c> apttusProposalLineItemMap = new Map<Id, Order_Line_Item__c>();
                String errorFields = 'Order Line Item error fields:';
                for(Apttus_Proposal__Proposal_Line_Item__c lineItem : quotesLineItemList){
                    Order_Line_Item__c orderLineItem = new Order_Line_Item__c();
                    orderLineItem.ProposalLineItem__c = lineItem.Id;
                    String copy = '^^^ Matching API fields copied from QPLI ' + lineItem.Id + ' to new OLI: ';
                    for(String sourceAPI : orderLineItemSourceFields.keySet()){
                        String targetAPI = getTargetApttusFieldAPIName(sourceAPI);
                        try{
                            if(sourceAPI != 'recordtypeid' && lineItem.get(sourceAPI) != null && orderLineItemFields.containsKey(targetAPI)){
                                //if(orderLineItemFields.get(targetAPI).getDescribe().isUpdateable()){
                                if(targetAPI != 'Id'){
                                    //Added validation to check the type matches
                                    orderLineItem.put(targetAPI, lineItem.get(sourceAPI));
                                    copy += targetAPI + '=' + orderLineItem.get(targetAPI) + ', ';
                                }
                            }else{
                                errorFields += '\n' + targetAPI;
                            }

                        }catch(Exception ex){
                            errorFields += '\n' + targetAPI;
                        }
                    }
                    copy.removeEnd(', ');
                    System.debug('copy='+copy);

                    //hardcoding the recordtype, some profiles have other recordtypes as the default
                    orderLineItem.RecordTypeId = oliRecordType;
                    //Couple of Manual Overrides needed due to misnaming:

                    /* Jeff L Commented out as part of 201797
                    if(lineItem.APTTS_Display_List_Price__c == 0)
                        orderLineItem.BasePrice__c = lineItem.APTTS_Display_Net_Price__c;
                    else
                        orderLineItem.BasePrice__c = lineItem.APTTS_Display_List_Price__c;*/

                    //if we are an option we look at a specific field for Base Price
                    if(lineItem.Apttus_QPConfig__LineType__c == 'Option'){
                        orderLineItem.BasePrice__c = lineItem.APTTS_Display_List_Price__c;
                    } else {
                        //if we are not a bundle option we have a different set of fields to look at
                        if(lineItem.APTTS_Display_Base_Extended_Price__c == 0){
                            orderLineItem.BasePrice__c = lineItem.APTTS_Display_Net_Price__c / lineItem.Apttus_QPConfig__Quantity2__c;                                                  }
                        else{
                            //set up some variables for smaller expressions
                            Double baseExtended = lineItem.APTTS_Display_Base_Extended_Price__c / lineItem.Apttus_QPConfig__Quantity2__c;
                            Double displayList = lineItem.APTTS_Display_List_Price__c;

                            //if these are the same - we don't have anything special we need to do
                            if(baseExtended == displayList){
                                orderLineItem.BasePrice__c = baseExtended;
                            } else{
                                //if they are not the same that means there will be ramifications and we need to skip
                                //applying the system discount on the order line item
                                orderLineItem.BasePrice__c = baseExtended;
                                orderLineItem.skip_applying_system_discount__c = true;
                            }

                            if(lineItem.APTTS_Display_Base_Extended_Price__c != lineItem.APTTS_Display_List_Price__c)
                            orderLineItem.BasePrice__c = lineItem.APTTS_Display_Base_Extended_Price__c / lineItem.Apttus_QPConfig__Quantity2__c;
                        }
                    }

                    //This logic is used to save us from Divide by 0 issues:
                    if(lineItem.Extended_List_Price__c != 0){
                         orderLineItem.System_Discount__c = lineItem.System_Discount__c != 0 ? ((lineItem.Extended_List_Price__c - lineItem.Apttus_QPConfig__BaseExtendedPrice__c)/lineItem.Extended_List_Price__c) * 100 : 0;
                    } else {
                        orderLineItem.System_Discount__c = lineItem.System_Discount__c;
                    }
                    //orderLineItem.System_Discount__c = lineItem.System_Discount__c != 0 ? ((lineItem.Extended_List_Price__c - lineItem.Apttus_QPConfig__BaseExtendedPrice__c)/lineItem.Extended_List_Price__c) * 100 : 0;
                    orderLineItem.System_Discount_Amount__c = lineItem.System_Discount_Amount__c;
                    orderLineItem.Discretion_discount__c = lineItem.Apts_Discount__c;
                    orderLineItem.Discretion_discount_Amount__c = lineItem.Discount_Amount__c;
                    orderLineItem.Sales_Discount__c = 0; //Jeff L did this for I-192577
                    //orderLineItem.Total_Discount__c = lineItem.Apts_Total_Discount__c;
                    //orderLineItem.Total_Discount_Amount__c = lineItem.Discount_Amount__c;
                    orderLineItem.Total_Discount_Amount__c =lineItem.System_Discount_Amount__c + lineItem.Discount_Amount__c;
                    order__c order =  pProposalIdToOrderMap.get(lineItem.Apttus_Proposal__Proposal__c);
                    orderLineItem.Proposal__c = order.QuoteProposal__c ;
                    orderLineItem.account_lkp__c=order.account__c;

                    orderLineItem.Order__c =order.Id;
                    orderLineItem.Sales_Credit__c = 0; //this gets set by trigger code later
                    system.debug('^^^OLI Order__c='+orderLineItem.Order__c+', Order__r.CurrencyIsoCode='+order.CurrencyIsoCode+', CurrencyIsoCode='+orderLineItem.CurrencyIsoCode + ', BasePrice__c=' + orderLineItem.BasePrice__c);

                    if (accountToXcode.containsKey(order.account__c)) {
                        //Added by Geeta kumawat Appirio -  I-192321
                        orderLineItem.Xcode_lkp__c= lineItem.Apttus_Proposal__Proposal__r.XcodeAccount__c;
                        orderLineItem.Xcode__c = lineItem.Apttus_Proposal__Proposal__r.Xcode_Name__c;
                        /*orderLineItem.Xcode_lkp__c= accountToXcode.get(order.account__c);*/
                        system.debug('***orderLineItem.Xcode_lkp__c 1**'+orderLineItem.Xcode_lkp__c+'  :::'+accountToXcode.get(order.account__c));
                    }
                    orderLineItem.HasOptions__c = lineItem.Apttus_QPConfig__HasOptions__c;
                    orderLineItem.OptionId__c= lineItem.Apttus_QPConfig__OptionId__c;

                    orderLineItemToInsert.add(orderLineItem);
                    apttusProposalLineItemMap.put(lineItem.Id, orderLineItem);
                }
                system.debug(errorFields);
                insert orderLineItemToInsert;
                orderLineItemToInsert = [select id, Xcode_lkp__c, NetUnitPrice__c , BasePrice__c from Order_Line_Item__c where id in :orderLineItemToInsert];
                system.debug('***orderLineItemToInsert**'+orderLineItemToInsert);
                //Added by Dino Brinas
                //Story 1783/2895
                /*orderLineItemIds = new List<Id>();
                orderLineItemIds.add(orderLineItemToInsert[0].id);*/
                CreateOrderLineItemAttributes(apttusProposalLineItemMap, sObjectAndFields);
            }
        }catch(DMLException e){
            throw BaseApplicationException.NewExceptionWithInnerException('CreateOrderRelatedLists', 'Order creation failed: ' + e,  e);
        }
    }

    //JFreese Appirio 3/10/17 S-445803 changed this method to static to make visible to queueable
    private static void CreateOrderLineItemAttributes(Map<Id, Order_Line_Item__c> pApttusProposalLineItemIdtoOrderLineItemMap,
                                                      Map<String, Map<String, Schema.SObjectField>> pSObjectAndFields){

            system.debug('**** Inside OrderGeneration.CreateOrderLineItemAttributes ****');

            Map<String, Schema.SObjectField> orderLineItemAttributeFields = pSObjectAndFields.get('Line_Item_Attribute__c');
            Map<String, Schema.SObjectField> orderLineItemAttributeSourceFields = pSObjectAndFields.get('Apttus_QPConfig__ProposalProductAttributeValue__c');
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType lineItemSchema = schemaMap.get('Line_Item_Attribute__c');
            Map<String, Schema.SObjectField> lineItemFieldMap = lineItemSchema.getDescribe().fields.getMap();
            String sourceAPIType=null,targetAPIType=null;

            String lineItemQuery = 'SELECT ';
            for(String sourceAPI : orderLineItemAttributeSourceFields.keySet()){
                lineItemQuery += sourceAPI + ',';
            }
            lineItemQuery = lineItemQuery.removeEnd(',');
            Set<Id> apttusLineItemIdSet = pApttusProposalLineItemIdtoOrderLineItemMap.keySet();
            lineItemQuery += ' FROM Apttus_QPConfig__ProposalProductAttributeValue__c WHERE Apttus_QPConfig__LineItemId__c IN :apttusLineItemIdSet';

            Apttus_QPConfig__ProposalProductAttributeValue__c[] apttusLineItemAttributeList = Database.query(lineItemQuery);
            Line_Item_Attribute__c[] lineItemAttributeToInsert = new Line_Item_Attribute__c[]{};
            for(Apttus_QPConfig__ProposalProductAttributeValue__c apttusLineItemAttribute : apttusLineItemAttributeList){
                Line_Item_Attribute__c lineItemAttribute = new Line_Item_Attribute__c();
                String copy = '^^^ Matching API fields copied from QPLI Attribute ' + apttusLineItemAttribute.Id + ' to new OLI Attribute: ';
                for(String sourceAPI : orderLineItemAttributeSourceFields.keySet()){
                    String targetAPI = getTargetApttusFieldAPIName(sourceAPI);

                    if(orderLineItemAttributeSourceFields.containsKey(sourceAPI) && lineItemFieldMap.containsKey(targetAPI)) {
                    sourceAPIType = String.valueOf(orderLineItemAttributeSourceFields.get(sourceAPI).getDescribe().getType());
                    targetAPIType = String.valueOf(lineItemFieldMap.get(targetAPI).getDescribe().getType());
                    System.debug('==@sourceAPIType=='+sourceAPIType+'===targetAPIType==='+targetAPIType);
                    }

                    if(sourceAPI != 'recordtypeid' && apttusLineItemAttribute.get(sourceAPI) != null && orderLineItemAttributeFields.containsKey(targetAPI)){
                        //if(orderLineItemAttributeFields.get(targetAPI).getDescribe().isUpdateable()){
                        try{
                            if(sourceAPIType  != null && targetAPIType != null && sourceAPIType == targetAPIType && targetAPI != 'Id'){
                                lineItemAttribute.put(targetAPI, apttusLineItemAttribute.get(sourceAPI));
                                copy += targetAPI + '=' + lineItemAttribute.get(targetAPI) + ', ';
                            }
                        } catch (Exception ex){
                            copy += 'failed to populate ' + targetAPI + ' : ' + ex.getMessage();
                        }
                    }
                }
                lineItemAttribute.Order_Line_Item__c = pApttusProposalLineItemIdtoOrderLineItemMap.get(apttusLineItemAttribute.Apttus_QPConfig__LineItemId__c).Id;
                lineItemAttribute.LineItemId__c = apttusLineItemAttribute.Apttus_QPConfig__LineItemId__c;
                lineItemAttributeToInsert.add(lineItemAttribute);
                copy.removeEnd(', ');
                System.debug(copy);
            }

            insert lineItemAttributeToInsert;
    }

    private Order__c hardcodedOrderFields(Apttus_Proposal__Proposal__c pProposal, Order__c pOrder, Opportunity pOpportunity){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','hardcodedOrderFields');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Order__c newOrder = pOrder;
        Apttus_Proposal__Proposal__c prop = pProposal;
        Opportunity opp = pOpportunity;

        newOrder.Account__c = opp.AccountId;
        newOrder.Opportunity__c = opp.Id;
        newOrder.QuoteProposal__c = prop.Id;
        //newOrder.Order_Type__c = prop.APTS_Quote_Type__c ;

        if(opp.RecordTypeId ==  Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity','Rebill Opportunity') ||
           /*JFreese Appirio 1/27/17 S-463527
              For Automated Credit & Rebill, the original opportunity is cloned to a new opp of recordType Rebill Opportunity,
              but this is not happening for non-automated Credit & Rebill.  Manisha is making a new story to address that,
              as we don't know if it used to or never did.  For now just include the proposal record type in the logic.*/
            prop.RecordTypeId == Utility.GetRecordTypeIdBySObjectNameAndType('Apttus_Proposal__Proposal__c','Rebill Proposal') ||
            prop.Rebill__c){ // Added by Shyam 2/6 : Story S-467393
            newOrder.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c','Rebill Order');
        }

        newOrder.Payment_Frequency__c = null ; //prop.Payment1_Frequency__c;
        newOrder.Payment_Method_text__c = null ; //prop.Payment_Method__c;
        newOrder.Payment_Term_text__c = null ; //prop.Payment_Term__c;
        newOrder.Payment_Details__c =null ; // prop.PaymentDetails__c;
        newOrder.Installments__c = null ; //prop.Number_of_Installment__c;



        system.debug('*<> Payment Info: ' + newOrder.Payment_Frequency__c + ' ' + newOrder.Payment_Method_text__c + ' ' +newOrder.Payment_Term_text__c);
        newOrder.IsPaypalAuthorizationEmailSent__c = prop.Is_Paypal_Authorization_Email_Sent__c;

        //update for I-193987
        if(prop.AgencyBillingContact__c != null){
            newOrder.AgencyBillingContact__c = prop.AgencyBillingContact__c ;
            //newOrder.Agency__c = opp.Agency__c;
            newOrder.Agency__c = prop.Agency__c;
        }

        if(prop.RecordTypeId == Utility.GetRecordTypeIdBySObjectNameAndType('Apttus_Proposal__Proposal__c', 'GCS Locked') ||
           prop.RecordTypeId == Utility.GetRecordTypeIdBySObjectNameAndType('Apttus_Proposal__Proposal__c', 'GCS Proposal') ){
            newOrder.GCS_Order__c = true;
        }

        //------------------------------------
        // Commented due to S-444897 by Mitali N,Appirio on 4/5/2017
       /* if(opp.Apttus_Approval__Approval_Status__c!= 'Approved' && opp.Apttus_Approval__Approval_Status__c!= 'Not Submitted') {
            newOrder.RejectedReason__c = 'Missing All Required Approvals';
            newOrder.Approval_Status__c = 'Rejected';
        } */
        // Populating order from Opp Agency
        if(prop.RecordTypeId == Utility.GetRecordTypeIdBySObjectNameAndType('Apttus_Proposal__Proposal__c', 'Newspaper Partner') && opp.Agency__c != null) {
            newOrder.BillingAccount__c = opp.Agency__c;
            newOrder.Agency__c = opp.Agency__c;
        }
        /*Code for I-222052, by Deepanshu Soni Appirio, starts*/
        newOrder.CreatedById = null;
        newOrder.CreatedDate = null;
        newOrder.LastModifiedById = null;
        newOrder.LastModifiedDate = null;
        newOrder.WebOrderNumber__c = prop.WebOrderNum__c ;
        /*Code for I-222052, by Deepanshu Soni Appirio, ends*/
        return newOrder;
    }


    @future
    public static void updateOrderStatusForOnlineFlow(Set<Id> orderIDSet){
        system.debug('**** Inside OrderGeneration.updateOrderStatusForOnlineFlow');

        OnlineFlowProcess ofp = new OnlineFlowProcess();
        ofp.setOfOrderIds = orderIDSet;
        System.enqueueJob(ofp);
        /*



            Set<Id> ordersIdsForVerification = new Set<Id>();
            if(orderIDSet == null  || orderIDSet.isEmpty()) {
                return;
            }

            List<Order__c> ordersToProcess = [select id, Account__r.Primary_Xcode__c, Opportunity__r.AutoCreateOrder__c,
                                                Payment_Method_text__c, Account__r.Organization__c, QuoteProposal__r.BillingStartDt__c, OrderDate__c
                                                from Order__c where id in:orderIDSet ];
            List<Line_Item_Attribute__c> orderAttributes = [select id, Job_Inventory__c, Order_Line_Item__r.Order__c from Line_Item_Attribute__c
                                                                where Order_Line_Item__r.Order__c in: orderIDSet];

            Map<ID, List<Line_Item_Attribute__c>> orderIDMapToAttribute = new Map<Id, List<Line_Item_Attribute__c>>();

            for(Line_Item_Attribute__c attr : orderAttributes){
                List<Line_Item_Attribute__c> attrList = orderIDMapToAttribute.get(attr.Order_Line_Item__r.Order__c);

                if(attrList == null) {
                    attrList = new List<Line_Item_Attribute__c>();
                }

                orderIDMapToAttribute.put(attr.Order_Line_Item__r.Order__c, attrList);

            }

            List<Order__c> ordersToBeUpdated= new List<Order__c>();

            Id profileId=userinfo.getProfileId();

            for(Order__c ord : ordersToProcess){

                System.debug(ord.Account__r.Organization__c);
                if(ord.Opportunity__r.AutoCreateOrder__c && (ord.Account__r.Organization__c.toLowerCase() == 'europe' || ord.Account__r.Organization__c.toLowerCase() == 'north america')) {

                    Boolean orderProcessed = true;


                    Boolean validOrderPaymentMethod  = false;

                    If(String.IsNotEmpty(ord.Payment_Method_text__c)){
                        validOrderPaymentMethod = ord.Payment_Method_text__c.toLowerCase() == 'credit card' ||
                                                        ord.Payment_Method_text__c.toLowerCase() == 'invoice' ;
                    }
                    Boolean validXcode = String.IsNotBlank(ord.Account__r.Primary_Xcode__c);

                    Boolean validProducts = true;

                    orderProcessed = validOrderPaymentMethod && validXcode;

                    List<Line_Item_Attribute__c> attributeList = orderIDMapToAttribute.get(ord.id);
                    //checking for products auto provisoned only if given order have valid order payment and valid xcode
                    if(orderProcessed && attributeList != null && attributeList.size() > 0){
                        for(Line_Item_Attribute__c attr : attributeList){
                            if(String.isBlank(attr.Job_Inventory__c) || attr.Job_Inventory__c.toLowerCase() == 'n/a'
                                    ||  attr.Job_Inventory__c.toLowerCase() == 'none')
                                    orderProcessed = false;
                                    break;

                        }
                    }

                    //Updated the logic as per the mail from Jeff after Matt confirm the same.I-177779
                    String orderStatus = 'Sent To Verification';
                    /*
                    if(orderProcessed) {

                        if(ord.Account__r.Organization__c.toLowerCase() == 'europe' ){
                            ord.OrderStatus__c = 'Verified';
                        } else if(ord.Account__r.Organization__c.toLowerCase() == 'north america') {
                            ord.OrderStatus__c = 'Verified';
                        }
                    }
                    */
                    /*ord.OrderStatus__c = orderStatus;

                    ord.BillingStartDt__c = ord.QuoteProposal__r.BillingStartDt__c != null ? ord.QuoteProposal__r.BillingStartDt__c : ord.OrderDate__c;
                    ordersToBeUpdated.add(ord);
                    ordersIdsForVerification.add(ord.Id);

                }

            }
            if(!ordersToBeUpdated.IsEmpty()) {
                //Jeff L 1/25/2016, updated this to true, we want to execute the triggers
                //to send to SITE
                update ordersToBeUpdated;
               /* for(Id oId : ordersIdsForVerification){
                     BizAppsSiteModel.verifyOrderFutureProof(oId,false);
                }  */
            //}
        }
}