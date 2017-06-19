public without sharing class OrderTriggerHelper {

   final String CLASSNAME = '\n\n**** OrderTriggerHelper .METHODNAME()';
   private List<Apttus_Proposal__Proposal__c> quoteList;
   private List<Partner_Revenue_Share__c> partnerRevShareList;
   private List<Account> accountList;
   public List<Order__c> ordersList;
   private static boolean avoidRecurssion = TRUE;
/* test
** @author : Cloud Sherpas Inc.
** @date : 03/20/2014
** @description : static method that instantiates a new instance of the class
** @paramaters : nothing
** @returns : a new instance of the OpportunityTeamMemberTriggerHelper class
*/
    public static OrderTriggerHelper NewTriggerHelper(){

        //final string METHODNAME = CLASSNAME.replace('METHODNAME','NewTriggerHelper');
        //system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        OrderTriggerHelper newHelper = new OrderTriggerHelper();
        return newHelper;
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 04/09/2014
** @description : this method is the class constructor
** @paramaters : String user profile name
** @returns : nothing
*/
    private OrderTriggerHelper(){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','OrderTriggerHelper');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

    }
/*
** @author : Appirio Inc
** @date : 09/25/2015
** @description : method is used to reset the triggerhandler, it nulls out the previously queried records
** @paramaters : nothing
** @returns : nothing
*/

    public void ResetQueries(){
        quoteList = null;
        ordersList = null;
        partnerRevShareList = null;
    }

/*
** @author : Appirio Inc.
** @date : 09/25/2015
** @description : this method will return a list of Quote/Proposals, it will query if the list doesn't already exist
    The main use for this function is to reduce the mumber of Quote/Proposal queries and to consolidate them
** @paramaters : none
** @returns : list of Quote/Proposals related to those orders
*/
    private List<Apttus_Proposal__Proposal__c> queryQuoteProposal(){

        if(quoteList == null){

            Set<Id> quoteIds = new Set<Id>();
            for(Order__c o : ordersList){
                if(o.QuoteProposal__c != null){
                    quoteIds.add(o.QuoteProposal__c);
                }
            }

            quoteList = new List<Apttus_Proposal__Proposal__c>();
            // Shyam 1/30 : S-443026
            if(quoteIds.size() > 0){
                quoteList = [
                SELECT Id, New_Number_of_Installments__c, PostingContact__c, BillContact__c, BillContact__r.AccountId,Payment_Method1__c,Payment1_Term__c,Payment1_Frequency__c,
                    Payment_Frequency__c, Payment_Term__c, Payment_Method__c, Installments__c,Active__c, AgencyBillingContact__c,
                    Site_Channel_ID__c, Entity_ID__c, Agency_Billing_City__c, Agency_Billing_City_State__c ,
                    Agency_Billing_City_State_Zip__c , Agency_Billing_Country__c, Agency_Billing_State_Province__c,
                    Agency_Billing_Street_Address__c, Agency_Billing_Zip__c, AgencyCommission__c , APTS_Agency_commission_Approval__c,
                    Agency_Discount_Amount__c, Local_Agency_Address__c, Local_Agency_Cust__c, Create_Assets__c ,Number_of_Installment__c, BillingAccount__c,Agency__c
                FROM Apttus_Proposal__Proposal__c
                WHERE Id in :quoteIds
                ];

            }
        }

        return quoteList;
    }

/*
** @author : Appirio Inc.
** @date : 02/19/2016
** @description : this method will return a list of Partner Revenue Shares, it will query if the list doesn't already exist
    The main use for this function is to reduce the mumber of Partner Revenue Shares queries and to consolidate them
** @paramaters : none
** @returns : list of Partner Revenue Shares related to those orders
*/
    private List<Partner_Revenue_Share__c> queryPartnerRevenueShare(){
        if(partnerRevShareList == null){
            Set<String> channelIds = new Set<String>();
            for(Order__c o : ordersList){
                if(String.isNotBlank(o.SiteChannelID__c)){
                    channelIds.add(o.SiteChannelID__c);
                }
            }

            partnerRevShareList = [
                SELECT Id, Product_Family__c, Partner__c, SiteChannelID__c, MB_Sales_Rep_Login__c,RevenueShare__c,MB_Live_Channel_Flag__c,Country__c
                FROM Partner_Revenue_Share__c
                WHERE SiteChannelID__c IN :channelIds
                ORDER BY CreatedDate ASC limit 1
                ];
        }

        return partnerRevShareList;
    }
/*
** @author : Appirio Inc.
** @date : 02/19/2016
** @description : this method will return a list of Accounts, it will query if the list doesn't already exist
    The main use for this function is to reduce the mumber of Account queries and to consolidate them
** @paramaters : none
** @returns : list of Accounts related to those orders
*/
    private List<Account> queryAccountList(){
        system.debug('!!! account List ' + accountList);
        if(accountList == null){
            Set<Id> accountIds = new Set<Id>();
            for(Order__c o : ordersList){
                system.debug('!!! Orders List ' + ordersList);
                if(o.Account__c != null){
                    accountIds.add(o.Account__c);
                }
            }
            system.debug('!!! here');
            accountList = [
            SELECT  Id, OwnerId, AccountStatus__c,AutoCustomerNumber__c,CustomerNumber__c,Lead_Account_Status__c,
            CustomerDate__c, VATNumber__c, Organization__c,
            PaymentDetails__c, Fax,Discount__c,Name,Account_Type__c,PhoneExtension__c,
            Primary_Service_Rep_Name__c, AgencyFlag__c,Primary_Agency_Contact__c,
            Primary_Agency_Contact__r.Name,Phone,PrimaryBillingContact__r.LeadSource,
            SalesChannel__c,ShippingCity,createdDate,
            ShippingCountry__c,ShippingState,ShippingStreet,PrimaryRelatedAgency__c,
            ShippingStateCode,Site,Primary_Xcode__c,PrimaryServiceRep__c,PrimaryServiceRep__r.Name,
            Primary_Sales_Rep_ID__c,CustomerLapsedDate__c,BillingStreet,
            BillingState,BillingPostalCode,BillingCountry,BillingCity,PrimaryBillingContact__c,
            CR_Status_Comment__c,OWner.Name,Suppress_Invoice_Detail__c,
                (SELECT Id, UserId, TeamMemberRole,AccountAccessLevel
                    FROM AccountTeamMembers
                    WHERE TeamMemberRole Like '%Sales%'
                    ORDER BY CreatedDate ASC
                )
            FROM Account
            WHERE Id in :accountIds
            ];
        }
        return accountList;
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 05/13/2014
** @Story : 0780
** @Element : E1608
** @description : Prevents creation of child credit order when a full credit is already verified on a parent order
** @paramaters : New Order List
** @returns : nothing
*/
    public void PreventCreationOfCreditOrder(list<Order__c> pNewOrders){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','PreventCreationOfCreditOrder');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Id CreditOrderRecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Credit');

        Set<Id> parentOrderIdSet = new Set<Id>();
        for(Order__c o : pNewOrders){
            if(o.RecordTypeId == CreditOrderRecordTypeId){
                parentOrderIdSet.add(o.ParentOrder__c);
            }
        }
        if(parentOrderIdSet.size() == 0){
            system.debug('No parent record to check if there\'s already a full credit.');
            return; //stops execution if there are no parent order to be processed
        }

        Order__c[] creditOrders = [SELECT ParentOrder__c FROM Order__c WHERE ParentOrder__c IN :parentOrderIdSet AND CreditType__c = 'Full' AND  OrderStatus__c = 'Verified'];
        map<Id, Order__c> parentIdToFullCreditOrder = new map<Id, Order__c>();
        system.debug('<<<<creditorder>>>>'+creditOrders);

        for(Order__c o : creditOrders){
            parentIdToFullCreditOrder.put(o.ParentOrder__c, o);
        }

        for(Order__c o : pNewOrders){
            if(parentIdToFullCreditOrder.containsKey(o.ParentOrder__c)){
                o.addError('You can\'t create a credit order because there\'s already a verified full credit order existing for this specific order.');
            }
        }
    }

   public void creditOrderSetGrossNetTotal(list<order__c> lstCreditOrders){

       list<Order_Line_Item__c> lstOrderLineItems = [select NetRemainingCreditAmount__c ,
                                                            GrossRemainingCreditAmount__c,
                                                            CreditRequestLineItem__r.Order_Line_Item__c ,
                                                            CreditRequestLineItem__r.Order_Line_Item__r.NetRemainingCreditAmount__c,
                                                            CreditRequestLineItem__r.Order_Line_Item__r.GrossRemainingCreditAmount__c
                                                    from Order_Line_Item__c
                                                    where Order__c IN :lstCreditOrders];
       //system.assert(false ,lstOrderLineItems);
       if(lstOrderLineItems.size() >0){
       list<Id> lstOrderLineItemsToBeUpdatedIds = new list<Id>();
       for(Order_Line_Item__c OLI : lstOrderLineItems){
           lstOrderLineItemsToBeUpdatedIds.add(OLI.CreditRequestLineItem__r.Order_Line_Item__c);
       }

       //system.assert(false,lstOrderLineItemsToBeUpdatedIds);
       Map< Id,Order_Line_Item__c> mapOrderLineItemsToBeUpdated = new map<id,Order_Line_Item__c>([select
                                                                                                     NetRemainingCreditAmount__c,
                                                                                                    GrossRemainingCreditAmount__c,
                                                                                                    NetTotalAmount__c,
                                                                                                    GrossTotalAmount__c
                                                                                                    from Order_Line_Item__c
                                                                                                    where id in:lstOrderLineItemsToBeUpdatedIds]);
       // system.assert(false ,'mapOrderLineItemsToBeUpdated'+mapOrderLineItemsToBeUpdated);
       if(mapOrderLineItemsToBeUpdated.keySet().size() > 0){
           for(Order_Line_Item__c OLI : lstOrderLineItems){
               /*  Modified by Vikas Menon 18 Nov. 2016 for S-445817
                   if NetRemainingCreditAmount__c is null then we set it to 0 */
               //system.assert(false,'show result '+mapOrderLineItemsToBeUpdated.get(OLI.CreditRequestLineItem__r.Order_Line_Item__c));

                if(mapOrderLineItemsToBeUpdated.get(OLI.CreditRequestLineItem__r.Order_Line_Item__c).NetRemainingCreditAmount__c == null){
                    mapOrderLineItemsToBeUpdated.get(OLI.CreditRequestLineItem__r.Order_Line_Item__c).NetRemainingCreditAmount__c = 0;
                 }
                 if(mapOrderLineItemsToBeUpdated.get(OLI.CreditRequestLineItem__r.Order_Line_Item__c).GrossRemainingCreditAmount__c == null){
                    mapOrderLineItemsToBeUpdated.get(OLI.CreditRequestLineItem__r.Order_Line_Item__c).GrossRemainingCreditAmount__c = 0;
                 }
                /* End */
               mapOrderLineItemsToBeUpdated.get(OLI.CreditRequestLineItem__r.Order_Line_Item__c).NetRemainingCreditAmount__c = mapOrderLineItemsToBeUpdated.get(OLI.CreditRequestLineItem__r.Order_Line_Item__c).NetTotalAmount__c;
               mapOrderLineItemsToBeUpdated.get(OLI.CreditRequestLineItem__r.Order_Line_Item__c).GrossRemainingCreditAmount__c = mapOrderLineItemsToBeUpdated.get(OLI.CreditRequestLineItem__r.Order_Line_Item__c).GrossTotalAmount__c;
           }
       }
       update (mapOrderLineItemsToBeUpdated.values());
     }
   }




/*
** @author : Cloud Sherpas, Inc.
** @date : 05/13/2014
** @Story : 0780
** @Element : E1608
** @description : Compute RemainingCreditAmount: (Parent order amount) - (Sum of all verified credit orders amount)
** @paramaters : Map of updated Orders, map of old orders
** @returns : nothing
*/
    public void ComputeRemainingCreditAmountOfParentOrder(Map<Id, Order__c> pNewOrdersMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','ComputeRemainingCreditAmountOfParentOrder');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Id CreditOrderRecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Credit');
        Set<String> acceptedType = new Set<String>{'Verified', 'Sent to A/R', 'Invoiced'};
        Set<Id> parentOrderIdSet = new Set<Id>();
        for(Order__c o : pNewOrdersMap.values()){
            if(acceptedType.contains(o.OrderStatus__c) && o.RecordTypeId == CreditOrderRecordTypeId){
                parentOrderIdSet.add(o.ParentOrder__c);
            }
        }
        if(parentOrderIdSet.size() == 0){
            system.debug('No parent record to process RemainingCreditAmount__c.');
            return; //stops execution if there are no parent order to be processed
        }
        /*For Deployment Purposes
        map<Id, Order__c> parentOrders = new map<Id, Order__c>([SELECT Id, NetTotalAmount__c, RemainingCreditAmount__c,
                                                                                            (SELECT Amount__c, NetTotalAmount__c, ParentOrder__c FROM Orders__r WHERE OrderStatus__c IN :acceptedType AND RecordTypeId = :CreditOrderRecordTypeId)
                                                                                            FROM Order__c WHERE Id IN :parentOrderIdSet]);
        Order__c[] parentOrderToModify = new Order__c[]{};
        for(Order__c o : pNewOrdersMap.values()){
            if(parentOrders.containsKey(o.ParentOrder__c)){
                Order__c po = parentOrders.get(o.ParentOrder__c);
                Double orderTotal = Utility.parseDouble(po.NetTotalAmount__c);
                Double childOrderAmountSum = 0;
                system.debug('Order children size: ' + po.Orders__r.size());
                for(Order__c co : po.Orders__r){
                    if(co.Id == o.Id){
                        childOrderAmountSum += Utility.parseDouble(o.NetTotalAmount__c);
                    }else{
                        childOrderAmountSum += Utility.parseDouble(co.NetTotalAmount__c);
                    }
                }
                system.debug('Test Child Order Amount Sum: ' + childOrderAmountSum);
                if((orderTotal - childOrderAmountSum) < 0){
                    Double maxAmount = Utility.parseDouble(o.NetTotalAmount__c) - (childOrderAmountSum - orderTotal);
                    String errorStr = ' Invalid amount. This credit order can only have a maximum Order Total of ' + maxAmount + '.';
                    throw BaseApplicationException.NewException(METHODNAME, errorStr);
                }else{
                    po.RemainingCreditAmount__c = (orderTotal - childOrderAmountSum);
                    parentOrderToModify.add(po);
                }
            }
        }

        update parentOrderToModify;
        For Deployment Purposes*/
    }




/*
** @author : Cloud Sherpas, Inc.
** @date : 05/13/2014
** @description : set parent oportunity's approval status to "Rejected" when order's status is "Rejected"
** @paramaters : List of Orders
** @returns : nothing
*/
    public void setOpportunityApprovalstatusToRejected(Order__c [] pNewOrders, Map<Id, Order__c> pOldOrdersMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','setOpportunityApprovalstatusToRejected');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Set<Id> parentOpportunityIdset = new Set<Id>();
        for(Order__c newOrder : pNewOrders){
            system.debug('Approval status old: ' + pOldOrdersMap.get(newOrder.Id).Approval_Status__c);
            system.debug('Approval status new: ' + newOrder.Approval_Status__c);
            if(newOrder.Approval_Status__c != pOldOrdersMap.get(newOrder.Id).Approval_Status__c && newOrder.Approval_Status__c == 'Rejected'){
                parentOpportunityIdset.add(newOrder.Opportunity__c);
            }
        }
        system.debug('Number of opportunity to reject: ' + parentOpportunityIdset.size());
        if(parentOpportunityIdset.size() > 0){
            Opportunity[] oppToUpdate = new Opportunity[]{};
            for(Opportunity opp : [SELECT Apttus_Approval__Approval_Status__c FROM Opportunity WHERE Id IN :parentOpportunityIdset]){
                opp.Apttus_Approval__Approval_Status__c = 'Rejected';
                oppToUpdate.add(opp);
            }
            update oppToUpdate;
        }
    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 05/13/2014
** @description : this method populates the Secondary sales rep and Primary Sales Rep field
** @paramaters : List of Orders
** @returns : nothing
*/
    public void populateSalesRepsFields(Order__c [] pNewOrders){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populateSalesRepsFields');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        Set<Id> OpportunityIds = new Set<Id>();
        system.debug('<<pNewOrders>>'+pNewOrders);
        for(Order__c ord : pNewOrders){
            OpportunityIds.add(ord.Opportunity__c);
        }
        //commented due to story#3058
        /*
        if(OpportunityIds.size() > 0){
            Map<Id,Opportunity> OppMap = new Map<Id,Opportunity>();
            for(Opportunity opp: [SELECT Id, OwnerId, OrderCreated__c , SecondarySalesRep__c FROM Opportunity WHERE Id IN: OpportunityIds ]){
                if(opp.OrderCreated__c == true){
                    OppMap.put(opp.Id , opp);
                }
            }
            for(Order__c ord: pNewOrders){
                if(OppMap.get(ord.Opportunity__c) != null){
                    ord.SecondarySalesRep__c = OppMap.get(ord.Opportunity__c).SecondarySalesRep__c;
                    ord.PrimarySalesRep__c= OppMap.get(ord.Opportunity__c).OwnerId;
                }
            }
        }*/
        system.debug('<<OpportunityIds>>'+OpportunityIds);

        //start of new code due to story #3058
        if(OpportunityIds.size() > 0){
            Map<Id,Opportunity> OppMap = new Map<Id,Opportunity>();
            Set<Id> accountIds = new Set<Id>();

            //retrieving oppty recordtype
            //Id opportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Opportunity Dummy Record Type').getRecordTypeId();

            //retrieving oppty details
            // Shyam 1/30 : S-443026
            List<Opportunity> pOpportunityList = new List<Opportunity>();
            if(OpportunityIds.size() > 0){
                pOpportunityList = [SELECT Id, OwnerId, OrderCreated__c , SecondarySalesRep__c, AccountId, Account.OwnerId,Account.Owner.Combined_Region__c ,Account.Owner.Position_Organization__c,RecordTypeId FROM Opportunity WHERE Id IN: OpportunityIds ];
            }
            //getting all account ids of oppty for query
            //collating oppty details via oppty id

            for(Opportunity opp: pOpportunityList){
                if(opp.OrderCreated__c == true){
                    accountIds.add(opp.AccountId);
                    OppMap.put(opp.Id , opp);
                }
            }

            if(accountIds.size()>0){
                //collating all sales account team members via account id
                Map<Id,Account> accountIdToAccountMap = new Map<Id,Account>();
                For(Account a : queryAccountList()){
                    if(accountIds.contains(a.Id)){
                        accountIdToAccountMap.put(a.Id,a);
                    }

                }
                /*map<Id, Account> accountIdToAccountMap = new map<Id, Account>([SELECT Id,OwnerId,
                                                                                    (SELECT Id, UserId, TeamMemberRole,AccountAccessLevel
                                                                                        FROM AccountTeamMembers
                                                                                        WHERE TeamMemberRole like '%Sales%' ORDER BY CreatedDate ASC
                                                                                    )
                                                                                FROM Account WHERE Id IN : accountIds]);*/
                map<id,id> AccountIdSecondaryUserIdMap = new map<id,id>();
                //building map for the first non-owner sales account team member per account

                for(Opportunity oOpportunity : pOpportunityList){
                    if(accountIdToAccountMap.containskey(oOpportunity.AccountId)){
                        for(AccountTeamMember oAccountTeamMember : accountIdToAccountMap.get(oOpportunity.AccountId).AccountTeamMembers){
                            system.debug('DEBUG SECONDARY LOGIC Owner Id:' + oOpportunity.OwnerId + 'ATM User Id' + oAccountTeamMember.UserId);
                            system.debug('<<oAccountTeamMember>>'+oAccountTeamMember);
                            if(oOpportunity.Account.OwnerId != oAccountTeamMember.UserId){
                                 AccountIdSecondaryUserIdMap.put(oOpportunity.AccountId,oAccountTeamMember.UserId);
                                 break;
                            }
                        }
                    }
                }
                //actual salesrep assignment from account
                for(Order__c ord: pNewOrders){
                    if(OppMap.get(ord.Opportunity__c) != null){
                        if(AccountIdSecondaryUserIdMap.containsKey((OppMap.get(ord.Opportunity__c)).AccountId)){
                            ord.SecondarySalesRep__c = AccountIdSecondaryUserIdMap.get((OppMap.get(ord.Opportunity__c)).AccountId);
                        }
                        ord.PrimarySalesRep__c= (OppMap.get(ord.Opportunity__c)).Account.OwnerId;
                        ord.Combined_Region__c = (OppMap.get(ord.Opportunity__c)).Account.Owner.Combined_Region__c ;
                        ord.Position_Organization__c= (OppMap.get(ord.Opportunity__c)).Account.Owner.Position_Organization__c;
                    }
                }
            }
        }
        //end of new code due to story #3058
    }
    /**
     * @author Cloudsherpas
     * @date 12.4.14
     * @description method to create a Product Implementation Case when order is Standard and Status is Sent to Verification.
     * @param pNewOrders - an Array of Order records
     * @param pOldOrdersMap - the map of old Order records
     */
    public void createCaseForVerifiedOrders (Order__c [] pNewOrders, Map<Id, Order__c> pOldOrdersMap) {

        final string METHODNAME = CLASSNAME.replace('METHODNAME','createCaseForVerifiedOrders');

        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        Logger.push(METHODNAME, 'Order__c');
if(avoidRecurssion) {
            map<String, map<String, Id>> OrderAndCaseRecordTypes = Utility.GetRecordTypeIdsBySObjectNameSet(new set<string>{'Order__c', 'Case'});
            map<String, Id> orderRecordTypes = OrderAndCaseRecordTypes.get('Order__c');


            Id caseProductImplementationRecordTypeId = OrderAndCaseRecordTypes.get('Case').get('Product Implementation');
            List<Order__c> newOrder = new List<Order__c>();
            List<Order__c> newOrder2 = new List<Order__c>(); //JFreese Appirio S-460308 / S-481187 4/14/17
            system.debug('**pNewOrders.size()***'+pNewOrders.size());
            Set<Id> accountIds = new Set<Id>();
            Set<Id> newOrderIds = new Set<Id>();
            Map<Id,Id> accountIdToPrimarySalesRep = new Map<Id,Id>();
            //First query the orders and their related objects that we will use below
            //also need to query Priamry Sales Contacts so we do that in a seperate
            //query below.

            if(pNewOrders.size()>0){
                // TKOM S-445214 - updated query to include PrimaryServiceRep__c, Agency__c, Agency__r.Name, Language__c, ProductLine__c and ProductFamily__c
                for(Order__c o : [
                        SELECT Id, Name, Account__c, Account__r.Name, Account__r.PrimaryServiceRep__c, Agency__c, Agency__r.Name, RecordTypeId, OrderStatus__c, QuoteProposal__c,QuoteProposal__r.Language__c,RecordType.Name,
                                (SELECT Id,Order__c, Order__r.Name,Order__r.Account__c,LineType__c, prod_code__c,
                                Product_Name_for_Case__c, ProductNameText__c,ProductFamily__c, ProductLine__c, Quantity2__c,RecordType.Name
                                FROM Order_Line_Items__r)
                            FROM Order__c WHERE Id IN :pNewOrders and recordtype.Name!= 'Ecomm']){// Ecomm Change by Gaurav Gupta on 18-Jan-2017 for S-460212

                    newOrder.add(o);
                    accountIds.add(o.Account__c);
                    newOrderIds.add(o.Id);
                }


                //get the primary sales contacts and build a map to reference later
                For(Contact c : [SELECT Id, AccountId
                        FROM Contact
                        WHERE PrimarySalesContact__c = true AND
                        AccountId IN :accountIds ]){

                    accountIdToPrimarySalesRep.put(c.AccountId,c.Id);
                }
            }
            list<Case> caseToInsertList = new list<Case>();
            //Map<Id,Case> ordertoCaseMap = new Map<Id,Case>();
            //list<Case> childCaseToInsert = new list<Case>();
            Map<Id,Order__c> orderMap = new Map<Id,Order__c>();

            //Jeff L Commenting out this whole line - we are using custom routing not assignment rules
            /*//Fetching the assignment rules on case
            AssignmentRule AR = new AssignmentRule();
            AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];

            //Creating the DMLOptions for "Assign using active assignment rules" checkbox
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            if(AR!=NULL) {
                dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
            }*/
            //we will use this to determine if the child cases need to be generated
            boolean generateChildCases = false;
            for(Order__c o : newOrder){
                //Will add Product Implementation Cases to List for insert DML
                // if(((o.RecordTypeId == orderRecordTypes.get('Standard') && o.OrderStatus__c == 'Sent To Verification')
                /* S-448650.  PChilton 12/14/16, 2017.01 - Added check for Contingent Record Type. */
                // if((((o.RecordTypeId == orderRecordTypes.get('Standard') || o.RecordTypeId == orderRecordTypes.get('Contingent')) && o.OrderStatus__c == 'Sent To Verification')
                /* S-448650.  PChilton 12/14/16, 2017.01 - Subsequent update to story states there should be no check for Record Type. */
                String str = '^^^ID='+o.Id+', OrderStatus__c='+o.OrderStatus__c+', trigger.isInsert='+trigger.isInsert+
                             ', trigger.isUpdate='+trigger.isUpdate;
                if (trigger.isUpdate){
                    str += ', Old.RecordTypeId='+pOldOrdersMap.get(o.Id).RecordTypeId+', o.RecordTypeId='+o.RecordTypeId+
                           ', Old.OrderStatus__c='+pOldOrdersMap.get(o.Id).OrderStatus__c+', o.OrderStatus__c='+o.OrderStatus__c;
                }
                system.debug(str);

                //prashant debug
                system.debug('RecordTYpe' + o.RecordType.Name);
                 // Prod imp cases should be created for STV and Paid In Full status (refer S-457014)
                // Modified by Vikas Menon Appirio on 6 Jan, 2017 S-457014
                 if(((o.OrderStatus__c == 'Sent To Verification' || o.OrderStatus__c == 'Paid in Full'
                    /*I-159896 JFreese Appirio 9/30/16 - Set this up and now not needed, retain in case wanted in the future
                    || (o.RecordTypeId == orderRecordTypes.get('Ecomm') && o.OrderStatus__c == 'Pending Processing')*/
                    )&&/* Added by -- Prashant Gupta, Appirio, S-460308 03/07/17*/
                    o.RecordType.Name !='Credit' &&
                    (trigger.isInsert ||
                    (trigger.isUpdate
                    && (pOldOrdersMap.get(o.Id).RecordTypeId!=o.RecordTypeId ||
                     pOldOrdersMap.get(o.Id).OrderStatus__c!=o.OrderStatus__c)
                     )
                     )
                    )) {
                    /*JFreese Appirio 1/18/17 Someone added the following line of code without comment sometime
                     between Jan 10 & 15, 2017.  It is totally bogus as it will disable all child cases
                     (It restricts them to Ecomm, then the code further down returns if Ecomm)
                     I am commenting it out.
                    if(Trigger.isupdate && o.recordtype.name == 'Ecomm'&& o.OrderStatus__c == 'Paid in Full'){*/
                    generateChildCases = true;
/*
                        OrderMap.put(o.Id, o);
                        Case newCase = new Case();
                        newCase.SystemGenerated__c = True;
                        newCase.Order__c = o.Id;
                        newCase.AccountId = o.Account__c;
                        newCase.RecordTypeId = caseProductImplementationRecordTypeId;
                        newCase.Subject = System.Label.CS_Product_Implementation_for+' '+o.Account__r.Name +' '+o.Name;
                        newCase.Sub_Type__c = 'Line Item Fulfillment';
                       // newCase.setOptions(dmlOpts);
                        OrderMap.put(o.Id, o);
                        caseToInsertList.add(newCase);
 */

 //TK associate Primary Sales Contact and Proposal to the new Cases
 //Jeff L commented out, don't do this it's a query in a for loop. Also if there are no results this type of query results in an error
                       // Contact primarySalesContact;
                       // primarySalesContact = [SELECT Id, PrimarySalesContact__c, Account.Name from Contact where PrimarySalesContact__c = true and Account.Id = :o.Account__c LIMIT 1];

                        OrderMap.put(o.Id, o);
                        Case newCase = new Case();
                        newCase.SystemGenerated__c = True;
                        newCase.Order__c = o.Id;
                        newCase.AccountId = o.Account__c;
                        newCase.ContactId = accountIdToPrimarySalesRep.get(o.Account__c);
                        newCase.Proposal_ID__c = o.QuoteProposal__c;

                        newCase.RecordTypeId = caseProductImplementationRecordTypeId;
                        newCase.Subject = System.Label.CS_Product_Implementation_for+' '+o.Account__r.Name +' '+o.Name;
                        newCase.Sub_Type__c = 'Line Item Fulfillment';


                        // TKOM S-445214 - added new case fields for product implementation case routing logic
                        // Product Family and Product Name will be pulled as formula fields from Order Line Item product
                        // newCase.AccountPrimaryServiceRep__c = o.Account__r.PrimaryServiceRep__c; // Formula Field
                        /* DEV2QA1 - SBerron commented out 3/07 for deployment to QA1 */
                        newCase.Agency__c = o.Agency__c;
                        newCase.AgencyLookup__c = o.Agency__c;
                        newCase.Language__c = o.QuoteProposal__r.Language__c;
                        system.Debug(':::: updated fields on parent case: newCase.Agency__c - ' + newCase.Agency__c);
                        system.Debug(':::: updated fields on parent case: newCase.AgencyLookup__c - ' + newCase.AgencyLookup__c);
                        system.Debug(':::: updated fields on parent case: newCase.Language__c - ' + newCase.Language__c);
                        // END DEV2QA1 comment out section
                        // newCase.setOptions(dmlOpts);
                        OrderMap.put(o.Id, o);
                        caseToInsertList.add(newCase);
                        system.debug('^^^ newCase to insert with subject '+newCase.Subject);

                        /*JFreese Appirio S-460308 / S-481187 4/14/17
                          For a credit & rebill, when the credit order is sent to verification, both the
                          credit & rebill orders are changed to STV.  Per S-460308 the credit order should not
                          get any product implementation cases.  But if we pass newOrder to processCases,
                          it will try to make children for the credit order, which has no parent and causes
                          "Attempt to de-reference a null object.""  So only send orders for which we just
                          generated a parent case (and thus want child cases)*/
                        newOrder2.add(o); // List to pass to processCases
                        //}
                }
                else {
                    system.debug('^^^No cases to create for ID '+o.Id);
                }
            }

            if(!caseToInsertList.isEmpty()){
                /*I-159896 JFreese Appirio 9/30/16 - Set this up and now not needed, retain in case wanted in the future
                if(UserInfo.getName() == 'Integration MAPP'){
                    //process in future because else get too many SOQL 101 error
                    system.debug('Processing case(s) in future: ' + caseToInsertList);
                    List<String> caseToInsert = new List<String>();
                    for(Case c : caseToInsertList){
                        caseString cs = new caseString(c.SystemGenerated__c, c.Order__c, c.AccountId, c.ContactId, c.Proposal_ID__c, c.RecordTypeId, c.Subject, c.Sub_Type__c);
                        caseToInsert.add(JSON.serialize(cs));
                    }
                    processCasesInFuture(generateChildCases, caseToInsert, newOrderIds);
                }
                else{*/
                    processCases(generateChildCases, caseToInsertList, newOrder2);
                //}
            }
        }
    }


    /*
    ** @author : Appirio (J Freese)
    ** @date : 09/21/16
    ** @description : insert cases, method extracted from createCaseForVerifiedOrders() to run synch or async
    ** @returns : nothing
    */
    public void processCases(Boolean generateChildCases, List<Case> caseToInsertList, List<Order__c> newOrder){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','processCases');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        map<String, map<String, Id>> OrderAndCaseRecordTypes = Utility.GetRecordTypeIdsBySObjectNameSet(new set<string>{'Order__c', 'Case'});
        Id caseProductImplementationRecordTypeId = OrderAndCaseRecordTypes.get('Case').get('Product Implementation');
        Map<Id,Case> ordertoCaseMap = new Map<Id,Case>();
        list<Case> childCaseToInsert = new list<Case>();

        if(!caseToInsertList.isEmpty()){
            system.debug('Inserting new Implementation record(s) [parent] !!!');
            insert caseToInsertList;
            avoidRecurssion = false;
        }

        for(Case firstCase : [Select Order__c,Id,AccountId,
                                    ContactId , Proposal_ID__c, BypassValidationsSTV__c from Case Where Order__c IN :newOrder]){
            ordertoCaseMap.put(firstCase.Order__c,firstCase);
        }

        //Without this boolean it was creating a ton of child cases
        if(generateChildCases){
            if(UserInfo.getName() == 'Integration MAPP'){
                //system.debug('Not processing child cases as there are not yet any order line items.');
                //system.debug('Child cases are processed by LineItemAttributesTriggerHelper.processChildCases()');
                return;
            }
            system.debug('childcases run1');
            set<id> setCaseIds = new set<id>();
            for(Order__c o : newOrder){
                List<Order_Line_Item__c>oLI = o.Order_Line_Items__r;
                system.debug('oLI '+ oLI + 'size: '+oLI.size());
                for(Order_Line_Item__c firstOli : oLI){
                    //Sylvester Agyen (5/12/16)- Do not create case for bundle header I-203458
                    system.debug('firstOli.LineType__c '+firstOli.LineType__c);
                    system.debug('firstOli.prod_code__c '+firstOli.prod_code__c);
                    if(firstOli.LineType__c != null && firstOli.LineType__c.equalsIgnoreCase ('Product/Service') && firstOli.prod_code__c.equalsIgnoreCase('QUOTE BUNDLE')){
                        continue;
                    }
                    else{
                        system.debug('childcases run2');
                        Case newCase = new Case();
                        newCase.SystemGenerated__c = True;
                        newCase.Order__c = firstOli.Order__c;

                        Case parentCase = ordertoCaseMap.get(firstOli.Order__c);
                        if(parentCase != null){
                            newCase.ParentId = parentCase.Id;
                            parentCase.BypassValidationsSTV__c = true; //SB - 2/07-16 - S-467631.
                            // parentCase.OrderLineItem__c = firstOli.id;// S-435321 Change by Gaurav Gupta on 18-11-2016  // TKOM commented out for S-445214 - parent PI case should not have any OLI specified
                            if(!setCaseIds.contains(parentCase.id)){
                                childCaseToInsert.add(parentCase); // S-435321 Change by Gaurav Gupta on 18-11-2016
                                setCaseIds.add(parentCase.id);
                             }

                        }
                        newCase.ContactId= parentCase.ContactId;// S-435321 Change by Gaurav Gupta on 18-11-2016
                        newCase.Proposal_ID__c= parentCase.Proposal_ID__c;// S-435321 Change by Gaurav Gupta on 18-11-2016

                        newCase.OrderLineItem__c = firstOli.id;
                        newCase.RecordTypeId = caseProductImplementationRecordTypeId;
                        newCase.AccountId = firstOli.Order__r.Account__c;


                        // TKOM S-445214 - added new case fields for product implementation case routing logic
                        //newCase.AccountPrimaryServiceRep__c = parentCase.PrimaryServiceRep__c; //formula field
                        /*DEV2QA1 - SBerron commented out 3/07 for deployment to QA1 */
                        newCase.Agency__c = o.Agency__c;
                        newCase.AgencyLookup__c = o.Agency__c;
                        newCase.Language__c = o.QuoteProposal__r.Language__c;
                        //newCase.ProductName__c = firstOli.Product_Name_for_Case__c;  // use formula field ProductNameFormula__c instead
                        // newCase.ProductFamily__c = firstOli.ProductFamilyFormula__c; // Field doesn't exist yet!
                        // newCase.PostingCountry__c = parentCase.PostingCountry__c; // Field doesn't exist yet!
                        system.debug(':::: updated fields on child case: newCase.Agency__c - ' + newCase.Agency__c);
                        system.debug(':::: updated fields on child case: newCase.AgencyLookup__c - ' + newCase.AgencyLookup__c);
                        system.debug(':::: updated fields on child case: newCase.Language__c - ' + newCase.Language__c);
                        // END DEV2QA1 comment out section


                        String account = '';
                        if(firstOli.Order__r.Account__c != null){
                            account = firstOli.Order__r.Account__c;
                        }
                        system.debug('firstOli.Product_Name_for_Case__c~~~ '+firstOli.Product_Name_for_Case__c);
                        newCase.Subject = firstOli.Product_Name_for_Case__c + ' - ' + 'Qty: '+firstOli.Quantity2__c + ' - ' + firstOli.Order__r.Name;
                        system.debug('newCase.Subject~~~ '+newCase.Subject);
                        newCase.Sub_Type__c = 'Line Item Fulfillment';
                       // newCase.setOptions(dmlOpts);
                        childCaseToInsert.add(newCase);
                        system.debug('childCaseToInsert~~~ '+childCaseToInsert);
                    }
                }
            }

            if(!childCaseToInsert.isEmpty()){
                Upsert childCaseToInsert;
                system.debug('childCaseToInsert~~~AFTER '+childCaseToInsert);
                system.debug('Inserting a new Implementation record [child] !!!');
                avoidRecurssion = false;
            }
        }
    }

    /*I-159896 JFreese Appirio 9/30/16 - Set this up and now not needed, retain in case wanted in the future
    @future(callout=true)
    public static void processCasesInFuture(Boolean generateChildCases, List<String> caseToInsert, Set<Id> newOrderIds){
        system.debug('**** Inside processCasesInFuture');

        List<Case> caseToInsertList = new List<Case>();
        List<Order__c> newOrder = new List<Order__c>();
        OrderTriggerHelper helper = OrderTriggerHelper.NewTriggerHelper();

        if (caseToInsert.size() > 0){
            caseString cs = null;
            for (String cti : caseToInsert)
            {
                cs = (caseString) JSON.deserialize(cti, caseString.class);
                Case c = new Case();
                c.SystemGenerated__c = cs.sysGen;
                c.Order__c = cs.order;
                c.AccountId = cs.account;
                c.ContactId = cs.contact;
                c.Proposal_ID__c = cs.proposal;
                c.RecordTypeId = cs.recordType;
                c.Subject = cs.subject;
                c.Sub_Type__c = cs.subType;
                caseToInsertList.add(c);
                system.debug('Case to insert: ' + c);
            }
        }

        if(newOrderIds.size() > 0){
            for(Order__c o : [
                SELECT Id, Name, Account__c, Account__r.Name, RecordTypeId, OrderStatus__c, QuoteProposal__c,
                        (SELECT Id,Order__c, Order__r.Name,Order__r.Account__c,LineType__c, prod_code__c,
                        Product_Name_for_Case__c, ProductNameText__c,Quantity2__c
                        FROM Order_Line_Items__r)
                    FROM Order__c WHERE Id IN :newOrderIds])
            {
                newOrder.add(o);
                system.debug('newOrder order: ' + o);
            }
        }

        if(!caseToInsertList.isEmpty()){
            system.debug('processCases(generateChildCases, caseToInsertList, newOrder): ' + generateChildCases + caseToInsertList + newOrder);
            helper.processCases(generateChildCases, caseToInsertList, newOrder);
        }
    }

    public with sharing class caseString {
        public Boolean sysGen {set; get;}
        public Id order {set; get;}
        public Id account {set; get;}
        public Id contact {set; get;}
        public Id proposal {set; get;}
        public Id recordType {set; get;}
        public String subject {set; get;}
        public String subType {set; get;}

        public caseString(Boolean sg, Id o, Id a, Id c, Id p, Id r, String s, String st){
            sysGen = sg;
            order = o;
            account = a;
            contact = c;
            proposal = p;
            recordType = r;
            subject = s;
            subType = st;
        }
    }*/

    /*
    ** @author : Appirio (J Freese)
    ** @date : 10/14/16
    ** @description : Summarize key Ecomm data for debugging
    ** @returns : nothing
    */
    public void showKeyEcommData(List<Order__c> orders, String description){
        for(Order__c o : orders){
            if(o.RecordTypeName__c == 'Ecomm'){
                String out = '\n\nKey Ecomm Data';
                if (description.length() > 0){
                    out += ' (' + description + ')';
                }
                out += ': ID=' + o.Id;
                out += ', OrderStatus__c=' + o.OrderStatus__c;
                out += ', Payment_Method_text__c=' + o.Payment_Method_text__c;
                out += ', Payment_Term_text__c=' + o.Payment_Term_text__c;
                out += ', Payment_Frequency__c=' + o.Payment_Frequency__c;
                out += ', Installments__c=' + o.Installments__c;
                out += ', PaypalAuthReferenceNumber__c=' + o.PaypalAuthReferenceNumber__c;
                out += ', SiteChannelCountry__c=' + o.SiteChannelCountry__c;
                out += ', SalesChannel__c=' + o.SalesChannel__c;
                out += ', Position_Organization__c=' + o.Position_Organization__c;
                out += ', Combined_Region__c=' + o.Combined_Region__c;
                out += ', MAPP_Archive_Credit_Card_Type__c=' + o.MAPP_Archive_Credit_Card_Type__c;
                out += '\n\n';
                system.debug(out);
            }
        }
    }


    /*
** @author : Cloud Sherpas, Inc.
** @date : 07/01/2014
** @Story : 0776
** @Element : E1684
** @description : When Order Status is set to Rejected, go to the related Quote/Proposal and set the Quote Status to "In Progress" and Active to "True" so the Sales Rep can correct any relevant data
** @paramaters : list of updated Order, Map of updated Orders, map of old orders
** @returns : nothing
*/
    public void ReopenQuoteWhenOrderIsRejected(Order__c[] pUpdatedOrder, Map<Id, Order__c> pNewOrdersMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','ReopenQuoteWhenOrderIsRejected');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        try{
            set<Id> quoteToUpdateIdSet = new set<Id>();

            for(Order__c o : pUpdatedOrder){
                if(pNewOrdersMap.get(o.Id).OrderStatus__c != 'Rejected' && o.OrderStatus__c == 'Rejected'){
                    quoteToUpdateIdSet.add(o.QuoteProposal__c);
                }
            }
            if(quoteToUpdateIdSet.size() == 0){
                system.debug('No quote to reopen.');
                return;
            }
            //Jeff L commented out to consolidate queries 10/13
            //Apttus_Proposal__Proposal__c[] quotestoUpdateList = [SELECT Name, QuoteStatus__c, Active__c FROM Apttus_Proposal__Proposal__c WHERE Id IN :quoteToUpdateIdSet];
            List<Apttus_Proposal__Proposal__c> quotestoUpdateList = queryQuoteProposal();
            List<Apttus_Proposal__Proposal__c> ProposalToUpdate = new List<Apttus_Proposal__Proposal__c>();
            for(Apttus_Proposal__Proposal__c quote : quotestoUpdateList){
                if(quoteToUpdateIdSet.contains(quote.Id)){
                    if(!quote.Active__c){
                        quote.Active__c = true;
                        system.debug('Quote ' + quote.Name + ' reactivated.');
                        ProposalToUpdate.add(quote);
                    }
                }
            }

            if(ProposalToUpdate != null && !ProposalToUpdate.isEmpty())
                 update ProposalToUpdate;
        }catch(Exception e){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Unable to reactivate related Quote/Proposal. ', e);
        }
    }

      /*
** @author : Cloud Sherpas, Inc.
** @date : 09/26/2014
** @Story :
** @Element :
** @description : When (Order Status = Verified) OR (Order Status = Sent to Verification) OR (Order Status = Paid in Full) OR (Order Status = Invoiced) go to the related Quote/Proposal and create assets boolean.
** @paramaters : list of updated Order, Map of updated Orders, map of old orders Create_Assets__c
** @returns : nothing
*/
    public void createAssetsQuoteonOrderStatus(Order__c[] pUpdatedOrder, Map<Id, Order__c> pOrderIdToOldOrderMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','createAssetsQuoteonOrderStatus');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        try{
            set<Id> quoteToUpdateIdSet = new set<Id>();
            Order__c oldOrder;
            for(Order__c o : pUpdatedOrder){
                oldOrder = pOrderIdToOldOrderMap.get(o.Id);
                system.debug(LoggingLevel.INFO, '^^^ oldOrder.OrderStatus__c='+oldOrder.OrderStatus__c+', o.OrderStatus__c='+o.OrderStatus__c);
                if(o.OrderStatus__c == 'Verified' && oldOrder.OrderStatus__c != o.OrderStatus__c){
                        quoteToUpdateIdSet.add(o.QuoteProposal__c);
                }
            }
            system.debug(LoggingLevel.INFO, 'Order for which Asset to be created:'+quoteToUpdateIdSet);

            if(quoteToUpdateIdSet.size() == 0){
                system.debug('No Asset to be creted.');
                return;
            }

           /* Jeff L. Commented out for query consolidation 10/13
           Apttus_Proposal__Proposal__c[] quotestoUpdateList = [SELECT Name, QuoteStatus__c, Active__c, Create_Assets__c
                                                                    FROM Apttus_Proposal__Proposal__c
                                                                    WHERE Id IN :quoteToUpdateIdSet
                                                                    AND Create_Assets__c = false];*/

            List<Apttus_Proposal__Proposal__c> ProposalToUpdate = new List<Apttus_Proposal__Proposal__c>();

            // Jeff L. Commented out for query consolidation 10/13
            //for(Apttus_Proposal__Proposal__c quote : quotestoUpdateList){
            for(Apttus_Proposal__Proposal__c quote : queryQuoteProposal()){
                if(quoteToUpdateIdSet.contains(quote.ID) && quote.Create_Assets__c == false){
                    quote.Create_Assets__c = true;
                    ProposalToUpdate.add(quote);
                    system.debug('Quote ' + quote.Name + ' Create_Assets__c'+ quote.Create_Assets__c );
                }
            }

            if(!ProposalToUpdate.isEmpty()){
                ApttusProposalTriggerHandler.PreventRecursion = true;
                update ProposalToUpdate;
                ApttusProposalTriggerHandler.PreventRecursion = false;
            }

        }catch(Exception e){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Unable to update the Quote Create Assets field ', e);
        }
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 07/21/2014
** @Story : 0776
** @Element : E1684
** @description : When Order Status is set to rejected by the "Reject Order" button in the UI
                        -- Record Type needs to be updated to new record type of Rejected Order
                        -- Owner needs to be changed to Order Management Queue
** @paramaters : list of updated Order, Map of updated Orders, map of old orders
** @returns : nothing
*/
//This statement is commented by Rohit B on 17/Nov/2015 for preventing record type change to 'Rejected'.
    /*public void RejectOrResubmitOrder(Order__c[] pUpdatedOrder, Map<Id, Order__c> pNewOrdersMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','RejectOrder');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Id RejectedRecordtypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Rejected Order');
        Id StandardRecordtypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Standard');

        for(Order__c o : pUpdatedOrder){
            if(o.OrderStatus__c == 'Rejected' && pNewOrdersMap.get(o.Id).OrderStatus__c != 'Rejected'){
                o.RecordTypeId = RejectedRecordtypeId;
            }
        }
    }
*/
/*
** @author : Cloud Sherpas, Inc.
** @date : 08/12/2014
** @Story : 0312
** @Element : E1885
** @description : When a credit Order Status is set to "Sent to Verification" using the Send to Verification button:                        -- Record Type needs to be updated to new record type of Rejected Order
                        -- Change the status of the rebill order which is a result of the credit request process
** @paramaters : list of updated Order, Map of updated Orders, map of old orders
** @returns : nothing
*/

    //commented By Mohit P : as not bieng called from anywhere
    /*public void SendToVerificationCreditAndRebillOrder(Order__c[] pUpdatedOrder, Map<Id, Order__c> pNewOrdersMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','SendToVerificationCreditAndRebillOrder');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            Id orderRecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Credit').getRecordTypeId();
            Id rebillOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Rebill Opportunity').getRecordTypeId();
            set<Id> crIdSet = new set<Id>();
            for(Order__c o: pUpdatedOrder){
                if(o.RecordTypeId == orderRecordTypeId && o.OrderStatus__c == 'Sent To Verification'){
                    crIdSet.add(o.CreditRequest__c);
                }
            }
            set<Id> oppIdSet = new set<Id>();
            set<Id> orderIdSet = new set<Id>();
            for(Credit_Request__c cr : [SELECT Id,Order__c FROM Credit_Request__c WHERE Id IN: crIdSet]){
                orderIdSet.add(cr.Order__c);
            }
            List<Order__c> OrderList = new List<Order__c>();

            for(Id oId : orderIdSet){
                Order__c order = new Order__c();
                order.Id = oId;
                order.OrderStatus__c = 'Sent To Verification';
            }

            // Jeff L Appirio commented out to remove extra queries
            //for(Order__c o: [SELECT Id FROM Order__c WHERE Id IN: orderIdSet]){
              //  o.OrderStatus__c ='Sent To Verification';
                //OrderList.add(o);
            //}
            if(!OrderList.isEmpty()){
                update OrderList;
            }
        }catch(Exception e){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Update related Rebill Order. Please see system logs for details.', e);
        }
    }*/
/*
** @author : Cloud Sherpas, Inc.
** @date : 08/12/2014
** @Story : 0312
** @Element : E1885
** @description : When a credit Order Status is set to "Sent to Verification" using the Send to Verification button:
                        -- Record Type needs to be updated to new record type of Rejected Order
                        -- Change the status of the rebill order which is a result of the credit request process
                        -- Throw an error if there a rebill order currently created on the credit order's parent credit request
** @paramaters : list of updated Order, Map of updated Orders, map of old orders
** @returns : nothing
*/
    //commented By Mohit P : as not bieng called from anywhere
    /*public void SendToVerificationCreditAndRebillOrder2(Order__c[] pUpdatedOrder, Map<Id, Order__c> pOldOrdersMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','SendToVerificationCreditAndRebillOrder');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            Id orderRecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Credit').getRecordTypeId();
            Id rebillOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Rebill Opportunity').getRecordTypeId();
            Id rebillOrderRecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Rebill Order').getRecordTypeId();
            set<Id> crIdSet = new set<Id>();
            Map<Id,Order__c> creditOrderRebillMap = new map<Id,Order__c>();
            for(Order__c o: pUpdatedOrder){
                if(o.RecordTypeId == orderRecordTypeId && (o.OrderStatus__c == 'Verified'  && pOldOrdersMap.get(o.id).OrderStatus__c!= o.OrderStatus__c)){
                    creditOrderRebillMap.put(o.CreditRequest__c, o);
                }
            }

            map<Id, Order__c> creditRequestIdToRebillOrderMap = new map<Id, Order__c>();
            for(Order__c rebillOrder: [SELECT Id, OrderStatus__c, CreditRequest__c, is_credit__c FROM Order__c WHERE CreditRequest__c IN: creditOrderRebillMap.keySet() AND RecordTypeId =: rebillOrderRecordTypeId]){
                System.debug('Sending');
                if(rebillOrder.CreditRequest__c != null){
                     BizAppsSiteModel.VerifyOrder(rebillOrder.id,rebillOrder.is_credit__c);

                    //creditRequestIdToRebillOrderMap.put(rebillOrder.CreditRequest__c, rebillOrder);
                }
            }

            /*List<Order__c> OrderList = new List<Order__c>();
            for(Order__c creditOrder: creditOrderRebillMap.values()){
                if(creditRequestIdToRebillOrderMap.containsKey(creditOrder.CreditRequest__c) ){
                    Order__c rebillOrder = creditRequestIdToRebillOrderMap.get(creditOrder.CreditRequest__c);
                    BizAppsSiteModel.SendOrderToSiteAsync(rebillOrder.id);
               //     rebillOrder.OrderStatus__c = creditOrder.OrderStatus__c;

                 //   OrderList.add(rebillOrder);
                }else{
                    if((creditOrder.CreditScenario__c == 'Credit and Rebill' && (pOldOrdersMap.get(creditOrder.Id).OrderStatus__c  != 'Sent To Verification' && creditOrder.OrderStatus__c == 'Sent To Verification')) ||
                        (creditOrder.CreditScenario__c == 'Credit and Rebill' && (pOldOrdersMap.get(creditOrder.Id).OrderStatus__c  != 'Verified' && creditOrder.OrderStatus__c == 'Verified'))){
                        creditOrder.addError('Cannot send a credit order to verification unless the corresponding rebill order has been created.');
                    }
                }
            }
        ///*  if(!OrderList.isEmpty()){
         //       update OrderList;
          //  }
        }catch(BaseApplicationException bae){
            throw bae;
        }catch(Exception e){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Failed to update related Rebill Order. Please see system logs for details.', e);
        }
    }*/

/*
** @author : Cloud Sherpas, Inc.
** @date : 08/25/2014
** @story : 0886
** @element : E2085
** @description : Count all record under the opportunity
** @paramaters : List of Order
** @returns : nothing
*/
    public void CountallRecords(List<Order__c> pOldOrdersList){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','CountallRecords');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        try{
            Set<Id> oppIds = new Set<Id>();
            for(Order__c ords : pOldOrdersList){
                if(ords.Opportunity__c != null){
                    oppIds.add(ords.Opportunity__c);
                }
            }
            system.debug('\n\noppIds: ' + oppIds + '\n\n');

            if(oppIds.size() == 0){
                system.debug('\n\nNo opportunity to proceed.\n\n');
                return;
            }

            List<Opportunity> oppListToUpdate = new List<Opportunity>();
            AggregateResult[] OrderCount = [SELECT Opportunity__c, COUNT(Id) FROM Order__c WHERE Opportunity__c In : oppIds GROUP BY Opportunity__c];
            //Jeff L commented out to reduce number of queries, all we really want is the Opp Id and we get that from the earlier query
            //map<Id, Opportunity> oppMap = new map<Id, Opportunity>([SELECT Id, Number_of_Orders__c FROM Opportunity WHERE Id IN : oppIds]);

            for(AggregateResult o : OrderCount){
                //Opportunity opp = oppMap.get((Id)o.get('Opportunity__c'));
                if(o.get('Opportunity__c') != null){
                    Opportunity opp = new Opportunity(Id=(Id)o.get('Opportunity__c'));
                    opp.Number_of_Orders__c = Double.valueOf(o.get('expr0'));
                    oppListToUpdate.add(opp);
                }
            }
            if(oppListToUpdate.size() > 0){
                //Jeff L added 10/13 to reduce query issues
                Utility.ExecuteOpportunityTrigger = false;
                update oppListToUpdate;
                Utility.ExecuteOpportunityTrigger = true;
            }
        }catch(DMLException e){
            ExceptionLog.add('DMLException', 'AccountTriggerHelper', 'CountallRecords', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to update contact.' ,e);
        }
    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 08/25/2014
** @Story : 0955
** @Element : E2073
** @description :  If a Credit Order is created (Order with a record type of "Credit") against an existing Order and Order Line Items,
                change the status of all OPEN Product Implementation
                s (Cases with Product Implementation record type) related to
                those Order Line Items, to "Cancelled". (NOTE: DO NOT "Cancel" the "Parent" case or the Case that is related to the Order,
                if there is one or more related cases that are "Open" or "Completed". Only cancel the parent case if ALL related
                Cases = "Cancelled")
** @paramaters : list of updated Order, Map of updated Orders, map of old orders
** @returns : nothing
*/
    public void ChangeStatusOfProductImplenetationCases(Order__c[] pUpdatedOrder){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','ChangeStatusOfProductImplenetationCases');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            Id CreditRecordtypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Credit');
            Id ProductImplementationCaseRecordtypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Case', 'Product Implementation');
            set<Id> OrderIdSet = new set<Id>();
            for(Order__c o : pUpdatedOrder){
                if(o.RecordTypeId == CreditRecordtypeId && o.ParentOrder__c != null){
                    OrderIdSet.add(o.ParentOrder__c);
                }
            }
            set<Id> OrderLineItemParentIdSet = new set<Id>();
            List<Case> CaseToBeUpdated = new List<Case>();
            Map<Id,set<Id>> ChildrenCaseOpenOrClosedMap = new Map<Id,set<Id>>();

            if(!OrderIdSet.isEmpty()){
                for(Order_Line_Item__c o : [SELECT Id FROM Order_Line_Item__c WHERE Order__c IN: OrderIdSet]){
                    OrderLineItemParentIdSet.add(o.Id);
                }
            }
            Map<Id,List<Case>> OLICasesMap = new Map<Id,List<Case>>();
            if(!OrderLineItemParentIdSet.IsEmpty()){
                for(Case ca : [SELECT id,Status, OrderLineItem__c FROM Case WHERE OrderLineItem__c IN: OrderLineItemParentIdSet AND ParentId != null AND(Status = 'Open' OR Status = 'New') ]){
                    ca.Status = 'Cancelled';
                    CaseToBeUpdated.add(ca);
                }
            }
            if(!CaseToBeUpdated.isEmpty()){
                update CaseToBeUpdated;
            }
        }catch(Exception e){
            ExceptionLog.add('Exception', 'OrderTriggerHelper', 'negateClosedCases', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to update the status of Cases to \'Cancelled\'.' ,e);
        }
    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 08/25/2014
** @Story : 0955
** @Element : E2073
** @description :  If a Credit Order is created against an existing Order/Order Line Items, and if a Product Implementation Case is
                already closed or "Completed" related to an Order Line Item, then create a Case with a record type of "Credit/Negate"
                against those Order Line Items.
** @paramaters : list of updated Order
** @returns : nothing
*/
    public void NegateClosedCases(Order__c[] pUpdatedOrder){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','NegateClosedCases');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
       // try{
            Id CreditRecordtypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Credit');
            Id ProductImplementationCaseRecordtypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Case', 'Product Implementation');
            Id CreditNegateCaseRecordtypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Case', 'Credit/Negate');
            set<Id> creditRequestIdSet = new set<Id>();
            map<Id,Order__c> OrderMap = new Map<Id,Order__c>();
            for(Order__c o : pUpdatedOrder){
                if(o.RecordTypeId == CreditRecordtypeId && o.ParentOrder__c != null){
                    creditRequestIdSet.add(o.CreditRequest__c);
                    OrderMap.put(o.ParentOrder__c, o);
                }
            }
            set<Id> OrderLineItemParentIdSet = new set<Id>();
            set<Id> ParentCaseRelatedToOrderIds = new set<Id>();
            Map<Id,List<Case>> ChildrenCaseOpenOrClosedMap = new Map<Id,List<Case>>();

            if(!creditRequestIdSet.isEmpty()){
                for(CreditRequestLineItem__c crLi : [SELECT Id,Order_Line_Item__c FROM CreditRequestLineItem__c WHERE Credit_Request__c IN: creditRequestIdSet]){
                    OrderLineItemParentIdSet.add(crLi.Order_Line_Item__c);
                }
            }
            system.debug('###OrderLineItemParentIdSet###' +OrderLineItemParentIdSet);
            List<Case> CasesToBeInsert = new List<Case>();
            set<Id> OLICaseCreated = new Set<Id>();
            if(!OrderLineItemParentIdSet.isEmpty()){
                for(Case ca : [SELECT id,
                                      Status,
                                      ParentId,
                                      AccountId,
                                      Subject,
                                      ContactId,
                                      issue__c,
                                      Origin,
                                      Priority,
                                      OrderLineItem__c,
                                      ResolutionCommitment__c,
                                      ResolutionSLA__c,
                                      DateTimeFirstClosed__c,
                                      ownerId,
                                      Order__c
                                FROM Case
                                //WHERE ParentId IN: ParentCaseRelatedToOrderIds
                                WHERE OrderLineItem__c IN:OrderLineItemParentIdSet
                                AND RecordTypeId =: ProductImplementationCaseRecordtypeId
                                AND Status = 'Closed' order By CaseNumber]){
                    system.debug('***ca**' +ca);
                    if(!OLICaseCreated.contains(ca.OrderLineItem__c)){
                    OLICaseCreated.add(ca.OrderLineItem__c);
                    Case newCase = new Case();
                    newCase.SystemGenerated__c = True;
                    newCase.RecordTypeId = CreditNegateCaseRecordtypeId;
                    newCase.OrderLineItem__c = ca.OrderLineItem__c;
                    if(OrderMap.containskey(ca.Order__c)){
                        newCase.AccountId = OrderMap.get(ca.Order__c).Account__c;
                        newCase.Order__c = OrderMap.get(ca.Order__c).Id;
                        newCase.PrimarySalesRepID__c = OrderMap.get(ca.Order__c).Account__r.OwnerId;
                    }
                    newCase.Subject = 'Credit ' + ca.Subject;
                    newCase.SalesChannel__c = 'Not Applicable';
                    newCase.Category__c ='Support';
                    newCase.CustomerProblemDetail__c = 'Credit the closed cases on the related Order.';
                    newCase.Status = 'New';
                    newCase.Channel__c = 'None';
                    newCase.Issue__c = 'Other';
                    newCase.Origin = 'Email';
                    newCase.Priority = '3-Medium';

                    newCase.LegacyKarmaSR__c = 'None';
                    newCase.LegacyRigthtNowIncident__c = 'None';
                    newCase.ownerId = ca.ownerId;
                    CasesToBeInsert.add(newCase);
                    }
                }
            }
            system.debug('%%%CasesToBeInsert%%%' +CasesToBeInsert);
            if(!CasesToBeInsert.isEmpty()){
                system.debug('$$entry$$$');
                insert CasesToBeInsert;
            }
        /*}catch(Exception e){
            ExceptionLog.add('Exception', 'OrderTriggerHelper', 'negateClosedCases', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to insert Credit/Negate cases.' ,e);
        }*/
    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 08/25/2014
** @Story : 0955
** @Element : E2073
** @description :   If a Negate Order is created (Order with a record type of "Negate") against an Order/Order Line Item,
                    create a "Credit/Negate" Case for each Order Line Item on that original Order.
** @paramaters : list of updated Order
** @returns : nothing
*/
    public void FileCreditNegateCaseOnOrderLineItems(Order__c[] pUpdatedOrder){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','FileCreditNegateCaseOnOrderLineItems');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            Id NegateOrderRecordtypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Negate');
            Id CreditNegateCaseRecordtypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Case', 'Credit/Negate');
            set<Id> OrderIdSet = new set<Id>();
            map<Id,Order__c> OrderMap = new Map<Id,Order__c>();
            for(Order__c ord: pUpdatedOrder){
                if(ord.RecordTypeId == NegateOrderRecordtypeId){
                    OrderIdSet.add(ord.ParentOrder__c);
                    OrderMap.put(ord.ParentOrder__c, ord);
                }
            }
            Map<Id, Case> orderLineItemCasesMap = new Map<Id, Case>();
            // 1/30 Shyam : S-443026
            if(!OrderIdSet.isEmpty()){
                for(Case ca : [SELECT Id, ownerId, OrderLineItem__c, Status FROM Case WHERE Order__c IN: OrderIdSet]){
                    orderLineItemCasesMap.put(ca.OrderLineItem__c, ca);
                }
            }

            List<Case> CasesToBeInsert = new List<Case>();
            if(!OrderIdSet.isEmpty() ){
                for(Order_Line_Item__c o : [SELECT Id, Name,Quantity2__c, Order__c, Order__r.Name,Account_lkp__c, Account_lkp__r.Name FROM Order_Line_Item__c WHERE Order__c IN: OrderIdSet]){
                    Case newCase = new Case();
                    newCase.SystemGenerated__c = True;
                    newCase.RecordTypeId = CreditNegateCaseRecordtypeId;
                    newCase.OrderLineItem__c = o.Id;
                    newCase.AccountId = OrderMap.get(o.Order__c).Account__c;
                    newCase.Subject = 'Remove -' + o.Name + '- Qty:' + o.Quantity2__c + '-Order Id:' + o.Order__r.Name + '--' + o.Account_lkp__r.Name;
                    newCase.Type = 'Remove Inventory';
                    newCase.Sub_Type__c = 'Remove Inventory';
                    newCase.SalesChannel__c = 'Not Applicable';
                    newCase.Category__c ='Support';
                    newCase.CustomerProblemDetail__c = 'File Negate cases on each Order Line Item.';
                    newCase.Status = 'New';
                    newCase.Channel__c = 'None';
                    newCase.Issue__c = 'Other';
                    newCase.Origin = 'Email';
                    newCase.Priority = '3-Medium';
                    newCase.PrimarySalesRepID__c = OrderMap.get(o.Order__c).Account__r.OwnerId;
                    newCase.LegacyKarmaSR__c = 'None';
                    newCase.LegacyRigthtNowIncident__c = 'None';
                    newCase.OwnerId = orderLineItemCasesMap.get(o.Id).OwnerId;
                    CasesToBeInsert.add(newCase);
                }
            }
            List<Case> CasesToUpdate = new List<Case>();
            if(!CasesToBeInsert.isEmpty()){
                insert CasesToBeInsert;
            }
        }catch(Exception e){
            ExceptionLog.add('Exception', 'OrderTriggerHelper', 'FileCreditNegateCaseOnOrderLineItems', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to insert Credit/Negate cases on order line items.' ,e);
        }
    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 08/25/2014
** @Story : 0955
** @Element : E2073
** @description :   If a Negate Order is created (Order with a record type of "Negate") against an Order/Order Line Item,
                    create a "Credit/Negate" Case for each Order Line Item on that original Order.
** @paramaters : list of updated Order
** @returns : nothing
*/
    public void ChangeStatusOfCaseOnOrderToCancelled(Order__c[] pUpdatedOrder){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','ChangeStatusOfCaseOnOrderToCancelled');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            Id NegateOrderRecordtypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Negate');
            Id CreditNegateCaseRecordtypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Credit');
            system.debug('<<NegateOrderRecordtypeId>>'+NegateOrderRecordtypeId);
            system.debug('<<CreditNegateCaseRecordtypeId>>'+CreditNegateCaseRecordtypeId);
            set<Id> NegateCreditOrderIdSet = new set<Id>();
            map<Id,Order__c> OrderMap = new Map<Id,Order__c>();
            for(Order__c ord: pUpdatedOrder){
                if(ord.RecordTypeId == NegateOrderRecordtypeId || ord.RecordTypeId == CreditNegateCaseRecordtypeId){

                    NegateCreditOrderIdSet.add(ord.ParentOrder__c);
                    system.debug('$$add'+ord.ParentOrder__c);
                }
            }
            List<Case> CasesToUpdate = new List<Case>();
            system.debug('<<NegateCreditOrderIdSet>>'+NegateCreditOrderIdSet);
            system.debug('<<pUpdatedOrder>>'+pUpdatedOrder);
            if(!NegateCreditOrderIdSet.isEmpty() ){
                system.debug('$$Inside');
                for(Case ca : [SELECT Id, Status FROM Case WHERE Order__c IN:NegateCreditOrderIdSet AND ParentId != null AND(Status = 'New' OR Status = 'Open')]){
                    ca.Status = 'Cancelled';
                    CasesToUpdate.add(ca);
                }
            }
            if(!CasesToUpdate.IsEmpty()){
                CaseTriggerHandler.ExecuteTriggers = false;
                update CasesToUpdate;
            }
        }catch(Exception e){
             ExceptionLog.add('Exception', 'OrderTriggerHelper', 'ChangeStatusOfCaseOnOrderToCancelled', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to cancel cases on the original order.' ,e);
        }
    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 07/16/2014
** @story : 0451
** @element : E1957
** @description :
** @paramaters :
** @returns : nothing
*/
    public void updateOrderFieldsFromMAPP(Order__c[] pUpdatedOrder, map<ID, Order__c> pOrderIdToOldOrderMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateOrderFieldsFromMAPP');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        for(Order__c ord: pUpdatedOrder){
            if(ord.MAPPQuoteProposal__c != null){
                ord.QuoteProposal__c = ord.MAPPQuoteProposal__c;
            }
            if(ord.MAPPSentToVerificationBy2__c != null){
                ord.SentToVerificationBy2__c = ord.MAPPSentToVerificationBy2__c;
            }
            if(ord.MAPPPriceListId__c != null){
                ord.PriceListId__c = ord.MAPPPriceListId__c;
            }
            if(ord.MAPPBillingAccount__c != null){
                ord.BillingAccount__c = ord.MAPPBillingAccount__c;
            }
            if(ord.MAPPBillingContact__c != null){
                ord.BillingContact__c = ord.MAPPBillingContact__c;
            }
            if(ord.MAPP_Archive_Posting_Contact__c != null)//AP I-171810
            {
               ord.Posting_Contact__c = ord.MAPP_Archive_Posting_Contact__c;
            }


            if(pOrderIdToOldOrderMap == null && ord.MAPP_Archive_Posting_Customer_PO__c != null)//AP I-196977
            {
               ord.CustomerPO__c = ord.MAPP_Archive_Posting_Customer_PO__c;
            }
            else if(pOrderIdToOldOrderMap != null && ord.MAPP_Archive_Posting_Customer_PO__c != null
                                && pOrderIdToOldOrderMap.get(ord.Id).MAPP_Archive_Posting_Customer_PO__c != ord.MAPP_Archive_Posting_Customer_PO__c ){

               ord.CustomerPO__c = ord.MAPP_Archive_Posting_Customer_PO__c;

            }

            if(UserInfo.getName() == 'Integration MAPP')//AP I-175038
            {
                Id EcommRecordtypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Ecomm');
                ord.RecordTypeId = EcommRecordtypeId;
                // ord.Order_Sequence__c = 'First Time';//AP I-202773 Jeff L commented out for I-184385
                ord.BillingStartDt__c = null;//AP I-215491
                /*if( ord.IntegrationStatus__c != 'In Progress'){//I-221617
                    ord.IntegrationStatus__c = 'Insert In Progress';
                }*/
            }
            else{//AP I-215491
                if (ord.BillingStartDt__c == null){
                    //S-437626 JFreese Appirio 10/24/16 Don't override existing Billing Start Date value,
                    //as it may have been set to a user specified date by CreateCreditOrderFromCreditRequest
                    /* S-457971: Code Changes started: */
                    //ord.BillingStartDt__c = ord.OrderDate__c;  // S-457971: Commenting this code to stop populating the Billing Start Date as today() on Orders
                    ord.BillingStartDt__c=ord.QuoteProposal__r.BillingStartDt__c; // S-457971: populates Proposal's billing start date as the Order's billing start date
                    /* end of Code Changes for S-457971 */
                }
            }

        }
        OrderTriggerHandler.SKIP_Method = false;
    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 07/16/2014
** @story : 0451
** @element : E1957
** @description :
** @paramaters :
** @returns : nothing
*/
    public void AssignOrderFromMAPP(Order__c[] pOrders){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','AssignOrderFromMAPP');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            for(Order__c ord: pOrders){
                ord.PrimarySalesRep__c = ord.Account__r.ownerId;
            }
            OrderTriggerHandler.SKIP_Method = false;
        }catch(Exception e){
             ExceptionLog.add('Exception', 'OrderTriggerHelper', 'AssignOrderFromMAPP', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to assign orders.' ,e);
        }
    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 07/16/2014
** @story :
** @element :
** @description :
** @paramaters :
** @returns : nothing
*/
    public void PopulateOrderPriceListFromMAPP(Order__c[] pUpdatedOrder){
        set<String> PriceListNameSet = new set<String>();
        for(Order__c ord : pUpdatedOrder){
            if(ord.MAPP_Price_List__c != null){
                PriceListNameSet.add(ord.MAPP_Price_List__c);
            }
        }
        Map<String, Id> PriceListMap = new Map<String, Id>();
        if(!PriceListNameSet.isEmpty()){
            for(Apttus_Config2__PriceList__c acp : [SELECT Id, Name FROM Apttus_Config2__PriceList__c WHERE Name IN: PriceListNameSet ]){
                PriceListMap.put(acp.Name, acp.Id);
            }
        }
        if(!PriceListMap.isEmpty()){
            for(Order__c ord : pUpdatedOrder){
                if(ord.MAPP_Price_List__c != null && PriceListMap.get(ord.MAPP_Price_List__c) != null){
                    ord.Price_List__c = PriceListMap.get(ord.MAPP_Price_List__c);
                    //JFreese Apprio 4/6/16 I-211465
                    ord.PriceListId__c = PriceListMap.get(ord.MAPP_Price_List__c);
                }
            }
        }
    }

/*
** @author : Appirio
** @date : 07/16/2014
** @story :
** @element : E1957
** @description :
** @paramaters :
** @returns : nothing
*/
    public void populatePrimarySalesRepFromAgency(Order__c[] lstAgencyOrders,set<id> agecyIds ){

        map<id,Account> mapAccount = new map<id,Account> ([SELECT
                                                            OwnerId, Owner.PositionSalesChannel__c,
                                                            Partner_Flag__c ,
                                                            Owner.Combined_Region__c, Owner.Position_Organization__c
                                                            FROM Account WHERE Id IN:agecyIds]);

        Id newspaperRecordtypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Newspaper Partner');
        for(Order__c o : lstAgencyOrders){
            if(mapAccount.get(o.agency__c).Partner_Flag__c  == true){
                o.PrimarySalesRep__c = mapAccount.get(o.agency__c).OwnerId;
                if(o.PrimarySalesRep__c != null){
                    o.SalesChannel__c = mapAccount.get(o.agency__c).Owner.PositionSalesChannel__c;
                    o.Position_Organization__c = mapAccount.get(o.agency__c).Owner.Position_Organization__c;
                    o.Combined_Region__c = mapAccount.get(o.agency__c).Owner.Combined_Region__c;
                }
             }
        }
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 07/16/2014
** @story :
** @element : E1957
** @description :
** @paramaters :
** @returns : nothing
*/
    public void PopulateOrderPrimarySalesRepFromMAPP(Order__c[] pUpdatedOrder){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','PopulateOrderPrimarySalesRepFromMAPP');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            set<String> PrimarySalesRepNameSet = new set<String>();
            for(Order__c ord : pUpdatedOrder){
                if(ord.MAPPPrimarySalesRep__c != null){
                    PrimarySalesRepNameSet.add(ord.MAPPPrimarySalesRep__c);
                }
            }
            Map<String, Id> UserNameMap = new Map<String, Id>();
            if(!PrimarySalesRepNameSet.isEmpty()){
                for(User usr : [SELECT Id, Username  FROM User WHERE Username  IN: PrimarySalesRepNameSet ]){
                    UserNameMap.put(usr.Username , usr.Id);
                }
            }
            if(!UserNameMap.isEmpty()){
                for(Order__c ord : pUpdatedOrder){
                    if(ord.MAPPPrimarySalesRep__c != null && UserNameMap.get(ord.MAPPPrimarySalesRep__c) != null){
                        ord.PrimarySalesRep__c = UserNameMap.get(ord.MAPPPrimarySalesRep__c);
                    }
                }
            }
        }catch(Exception e){
             ExceptionLog.add('Exception', 'OrderTriggerHelper', 'PopulateOrderPrimarySalesRepFromMAPP', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to change Primary Sales Rep. Please see system logs for details. ' ,e);
        }
    }
/**
     * @author Cloud Sherpas, Inc.
     * @date  12.12.2014
     * @story  3059
     * @description  update Account to the CustomerNumber__c and Account Status if the Account status is 'Candidate' and Order Status is changed to Sent to Verification
     * @param pNewOrders - list of Accounts[]
     * @param pOldOrdersMap - Map of Account record's old values
     */
    /*public void updateCustumerNumberofAccounts(Order__c [] pNewOrders, Map<Id, Order__c> pOldOrdersMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateCustumerNumberforAccounts');
        Logger.push(METHODNAME, 'Order__c');
        if(UserInfo.getName() == 'Integration MAPP')
        {return;} //I-234964
        try{
            set<Id> AccountIds = new set<Id>();
            Id StandardOrderRecordtypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Standard');
            for(Order__c ord :  pNewOrders){
                if((ord.Account__c != null && ord.RecordTypeId == StandardOrderRecordtypeId) && (ord.OrderStatus__c == 'Sent To Verification' && (pOldOrdersMap.get(ord.Id).OrderStatus__c!=ord.OrderStatus__c ))){
                    AccountIds.add(ord.Account__c);
                }
            }
            List<Account> AccountsToBeUpdated = new List<Account>();
            if(!AccountIds.isEmpty()){
                String Max = '';
                MaximumCustomerNumber__c maxCN = MaximumCustomerNumber__c.getOrgDefaults();
                if (maxCN == null) maxCN = new MaximumCustomerNumber__c();
                Max = String.valueOf(maxCN.MaxCustNum__c.longvalue() + 1);
                maxCN.MaxCustNum__c = decimal.valueOf(Max);
                upsert maxCN;
                for(Account acc : queryAccountList()){
                    if(AccountIds.contains(acc.Id)){
                        if(acc.AccountStatus__c == 'Candidate'){
                            acc.AccountStatus__c = 'Customer';
                            acc.CustomerDate__c = Date.Today();
                            acc.CustomerNumber__c =  Max;
                            AccountsToBeUpdated.add(acc);
                        }
                    }
                }
                if(!AccountsToBeUpdated.isEmpty()){
                    AccountTriggerHandler.ExecuteTriggers = false;
                    update AccountsToBeUpdated;
                }
            }
        }catch(Exception e){
            Logger.debugException(e, null);
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to update the Account. Please see system logs for details. ' ,e);
        }
        Logger.pop();
    }*/


/*
** @author : Cloud Sherpas, Inc.
** @date : 11/20/2014
** @story : 2729
** @element : E2417
** @description : Populate sales channel and payment details
** @paramaters : List of Order
** @returns : nothing
*/
    public void populateSalesChannelAndPaymentDetails(Order__c[] pUpdatedOrder){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populateSalesChannelAndPaymentDetails');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        Map<Id, Order__c> accountsIdOrder = new Map<Id, Order__c>();
        Map<ID, Id> accountAndOwnerId = new Map<Id, Id>();
        Map<Id, Order__c> accAgencyOrder = new Map<Id,Order__c>();
        for(Order__c o : pUpdatedOrder){
            accountsIdOrder.put(o.Account__c, o);
            if(o.Agency__c != null){
                accAgencyOrder.put(o.Agency__c,o);
            }
        }
        //List<Account> accountList = [SELECT Id, VATNumber__c,OwnerId, Organization__c, SalesChannel__c, PaymentDetails__c FROM Account WHERE Id in: accountsIdOrder.keySet()];
        List<Account> accountList = new List<Account>();
        List<Account> agencyList = new List<Account>();
        for(Account a : queryAccountList()){
            if(accountsIdOrder.keySet().contains(a.Id)){
                accountList.add(a);
                 accountAndOwnerId.put(a.Id, a.OwnerId);
            }
            if(accAgencyOrder.keySet().contains(a.Id)){
                agencyList.add(a);
            }
        }
        Map<Id,user> userList = new Map<Id,User>([SELECT PositionSalesChannel__c FROM User Where Id IN :accountAndOwnerId.Values()]) ;
        system.debug('##List '+agencyList);
        for(Account ag : agencyList){
            Order__c ordagency = accAgencyOrder.get(ag.Id);
            system.debug('%%Acc'+ag.name);
            if(ag.VATNumber__c != null){
                ordagency.Agency_VAT__c = ag.VATNumber__c;
            }
        }
        for(Account a : accountList){
            Order__c ord= accountsIdOrder.get(a.Id);
            if(a.SalesChannel__c != null && ord.SalesChannel__c == null){
                ord.SalesChannel__c = userList.get(accountAndOwnerId.get(a.Id)).PositionSalesChannel__c;
            }
            if(a.VATNumber__c != null && ord.VAT_Number__c == null){
                ord.VAT_Number__c = a.VATNumber__c;
            }
            if(a.PaymentDetails__c != null && ord.AccountOrganization__c == null){
                ord.AccountOrganization__c = a.Organization__c;
                //ord.Payment_Details__c = a.PaymentDetails__c;
            }
            //I-211402
            if(UserInfo.getName() == 'Integration MAPP'){
                System.debug('----ord.Organization__c BEFORE ' + ord.Organization__c);
                ord.Organization__c = a.Organization__c;
                System.debug('----ord.Organization__c AFTER ' + ord.Organization__c);
                ord.Installments__c = 1;
            }
        }
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 12/05/2014
** @story : 2845
** @element : E2442
** @description : Populate fields when order is created
** @paramaters : List of Order
** @returns : nothing
*/
    public void populateOrderFields(Order__c[] pUpdatedOrder){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populateOrderFields');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        Set<Id> accIds = new Set<id>();
        Set<Id> billingAccIds = new Set<id>();
        Map<Id, Id> accOrder = new Map<Id, Id>();
        Map<Id, Id> shippingContactId = new Map<Id, Id>();
        for(Order__c o : pUpdatedOrder){
            accIds.add(o.Account__c);
            accOrder.put(o.Id, o.Account__c);
            if(o.BillingAccount__c != null){
                billingAccIds.add(o.BillingAccount__c);
                //Jeff L 08/17 - added because accountlist query doesn't use billingAccIds anymore
                accIds.add(o.BillingAccount__c);
            }
            if(o.ShippingContact__c != null){
                shippingContactId.put(o.id, o.ShippingContact__c);
            }
        }

         //Story1651,E2920
        //Dated Jan152015

        // Refactor code : Merge two account queries into single queries
        /*List<Account> accountList = new List<Account>([SELECT Id,Fax,Discount__c,Name,Account_Type__c,PhoneExtension__c,Primary_Service_Rep_Name__c,
                                                                             AgencyFlag__c,Primary_Agency_Contact__c,Primary_Agency_Contact__r.Name,
                                                                             CustomerNumber__c,Phone,PrimaryBillingContact__r.LeadSource,
                                                                             SalesChannel__c,OwnerId,
                                                                             ShippingCity,ShippingCountry__c,
                                                                             ShippingState,ShippingStreet,PrimaryRelatedAgency__c,
                                                                             ShippingStateCode,Site,Primary_Xcode__c,PrimaryServiceRep__c,PrimaryServiceRep__r.Name
                                                       FROM Account
                                                       WHERE Id In: accIds]);*/
        //Jeff L Feb22, added to our query framework instead
        List<Account> accList = new List<Account>();
        for(Account a : queryAccountList()){
            if(accIds.contains(a.Id)){
                accList.add(a);
            }
        }



        /*List<Account> billingAccountList = new List<Account>([SELECT Id,Fax,Phone,PhoneExtension__c,Name,Primary_Xcode__c
                                                       FROM Account
                                                       WHERE Id In: billingAccIds]);

        Map<Id, Account> billingaccMap = new Map<Id, Account>();
        if(!billingAccountList.isEmpty()){
            for(Account baList : billingAccountList){
                billingaccMap.put(baList.Id, baList);
            }
        }*/

        Map<Id, Account> billingaccMap = new Map<Id, Account>();

        for(Account acc : accList){
            if(billingAccIds.contains(acc.Id)){
                billingaccMap.put(acc.Id, acc);
            }

        }

        Map<Id, Id> accPrimaryRelatedAgency = new Map<Id, Id>();
        Map<Id, Account> accMap = new Map<Id, Account>();
        Map<Id, Id> accPartner = new Map<Id, Id>();
        Map<Id, RelatedPartner__c> accPartnerMap = new Map<Id, RelatedPartner__c>();
        Map<Id, Account> accountPartnerMap = new Map<Id, Account>();

        system.debug('@@accList'+acclist);
        if(!accList.isEmpty()){
            for(Account aList : accList){
                if(aList.PrimaryRelatedAgency__c != null){
                    accPrimaryRelatedAgency.put(aList.Id, aList.PrimaryRelatedAgency__c);
                }
                accMap.put(aList.Id, aList);
            }

            // Shyam 1/30 : S-443026
            List<RelatedPartner__c> relatedPartnerList = new List<RelatedPartner__c>();
            if(!accPrimaryRelatedAgency.isEmpty()){
                relatedPartnerList = new List<RelatedPartner__c>([SELECT Id, Partner__c,
                                                                             Role__c
                                                                              FROM RelatedPartner__c
                                                                              WHERE Id In: accPrimaryRelatedAgency.Values()
                                                                              AND Partner__c != null]);
            }
            if(!relatedPartnerList.isEmpty()){
                for(RelatedPartner__c rp : relatedPartnerList){
                    accPartner.put(rp.Id, rp.Partner__c);
                    accPartnerMap.put(rp.Id, rp);

                }
                //Story1651,E2920
                //Dated Jan152015
                //Added fields Primary_Agency_Contact__r.name
                accountPartnerMap = new Map<Id, Account>([SELECT Id,Fax,Discount__c,Name,
                                                                             Primary_Agency_Contact__c,
                                                                             Primary_Agency_Contact__r.Name,
                                                                             AgencyFlag__c,PO_Box__pc,
                                                                             CustomerNumber__c,Phone,ShippingPostalCode,
                                                                             SalesChannel__c,Owner.Name,
                                                                             ShippingCity,ShippingCountry__c,
                                                                             ShippingState,ShippingStreet,
                                                                             ShippingStateCode,Site,Primary_Xcode__c,PrimaryServiceRep__c, PrimaryServiceRep__r.Name
                                                                       FROM Account
                                                                       WHERE Id In: accPartner.Values()]);
            }
        }
        // Shyam 1/30 : S-443026
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        if(!ShippingContactId.isEmpty()){

            contactMap = new Map<Id, Contact>([SELECT Id, FirstName, LastName,ContactSource__c FROM Contact WHERE ID in: ShippingContactId.values()]);
        }
        for(Order__c ord : pUpdatedOrder){
            //JFreese Appirio I-189801 set BillingCustomer__c on order creation
            //Jeff commented out - ended up deciding to use a fromula instead of code
            //ord.BillingCustomer__c = ord.CustomerNumber__c;

            //ord.Archive_Billing_Contact__c = ord.Billing_Contact_Name__c;

            ord.Archive_Billing_Customer_Number__c = ord.Billing_Customer_Number__c;
            ord.Archive_Billing_Profile_Id__c = ord.BillingProfileId__c;
            ord.Archive_Billing_Sales_Rep__c = ord.PrimarySalesRepName__c;
            ord.Archive_Billing_Ship_To_City__c = ord.BillingCity__c;
            ord.Archive_Billing_Ship_To_Country__c = ord.BillingCountry__c;
            ord.Archive_Billing_Ship_To_Province__c = ord.BillingStateProvince__c;
            ord.Archive_Billing_Ship_To_State__c = ord.BillingStateProvince__c;
            ord.Archive_Billing_Ship_To_Street_Address__c = ord.BillingStreet__c;
            ord.Archive_Billing_Ship_To_Street_Address_2__c = ord.BillingAddress__c;
            ord.Archive_Billing_Ship_To_Zip__c = ord.BillingZipPostalCode__c;
            ord.Archive_Billing_Ship_To_PO_Box__c = ord.BillingPOBox__c;
            ord.Archive_Posting_Agency_IO__c = ord.AgencyIO__c;
            //ord.Archive_Posting_Contact__c = ord.PostingContact__c;
            ord.Archive_Posting_Customer_Number__c = ord.CustomerNumber__c;
            ord.Archive_Posting_Customer_PO__c = ord.CustomerPO__c;
            ord.Archive_Posting_Member_Flag__c = string.valueof(ord.Member__c);
            //ord.Archive_Posting_Phone_Number__c = ord.Archive_Posting_Phone_Number__c;
            ord.Archive_Posting_Profile_Id__c = ord.PostingProfile__c;
            ord.Archive_Posting_Sales_Rep__c = ord.PrimarySalesRepName__c;
            ord.Archive_Posting_Sales_Rep_Manager__c = ord.PrimarySalesManager__c;
            ord.Archive_Posting_Ship_To_City__c = ord.PostingCity__c;
            ord.Archive_Posting_Ship_To_Country__c = ord.PostingCountry__c;
            ord.Archive_Posting_Ship_To_Province__c = ord.PostingStateProvince__c;
            ord.Archive_Posting_Ship_To_State__c = ord.PostingStateProvince__c;
            ord.Archive_Posting_Ship_To_PO_Box__c = ord.ShippingAddress__c;
            ord.Archive_Posting_Ship_To_Street_Address__c = ord.StreetAddress__c;
            ord.Archive_Posting_Ship_To_Street_Address_2__c = ord.StreetAddress__c;

            //ord.Archive_Posting_Ship_To_Zip__c = ord.PostalCode__c;
            ord.Archive_Posting_Ship_To_Zip__c = ord.ShippingZipPostalCode__c;

            ord.Archive_Billing_Xcode__c = ord.BillingXCode__c;
            ord.Archive_Posting_Xcode__c = ord.PostingXcode__c;

            if(ord.BillingAccount__c != null && billingaccMap.containsKey(ord.BillingAccount__c)){
                Account billAccount = billingaccMap.get(ord.BillingAccount__c);
                ord.Archive_Billing_Account_Name__c = billAccount.Name;
                ord.Archive_Billing_Fax__c = billAccount.Fax;
                ord.Archive_Billing_Phone__c = billAccount.Phone;
                ord.Archive_Billing_Phone_Ext__c = billAccount.PhoneExtension__c;
                //ord.Archive_Billing_Xcode__c = billAccount.Primary_Xcode__c;
            }
            if(ord.ShippingContact__c != null && contactMap.containsKey(ord.ShippingContact__c)){
                //if(contactMap.containsKey(ord.ShippingContact__c)){
                String contactName = contactMap.get(ord.ShippingContact__c).FirstName + ' ' + contactMap.get(ord.ShippingContact__c).LastName;
                ord.Archive_Posting_Contact__c = contactName;
                ord.Archive_Posting_Contact_Lead_Source__c = contactMap.get(ord.ShippingContact__c).ContactSource__c;
                //}
            }
            Id aPrimaryRA = accPrimaryRelatedAgency.get(ord.Account__c);
            Id aPartner = accPartner.get(aPrimaryRA);
            Account postingAccount = accMap.get(ord.Account__c);
            Account relatedAccount = accountPartnerMap.get(aPartner);
            RelatedPartner__c relPartner = accPartnerMap.get(aPrimaryRA);
            system.debug('Related Partner'+relPartner+'Related Account '+relatedAccount );
            if(relatedAccount != null && relPartner != null){
                ord.Archive_Local_Agency_Account_Name__c = relatedAccount.Name;
                if(relPartner.Role__c == 'Agency'){
                    ord.Archive_Agency_Fax__c = relatedAccount.Fax;
                    ord.Archive_Local_Agency_Account_Discount__c = string.valueof(relatedAccount.Discount__c);
                    ord.Archive_Local_Agency_Agency_Flag__c = string.valueof(relatedAccount.AgencyFlag__c);
                    //ord.Archive_Local_Agency_Contact__c = relatedAccount.PrimaryAgencyContact__c;
                    //Story1651, E2920
                    //Dated Jan152015
                    ord.Archive_Local_Agency_Contact__c = relatedAccount.Primary_Agency_Contact__r.Name;
                    ord.Archive_Local_Agency_Customer_Number__c = relatedAccount.CustomerNumber__c;
                    ord.Archive_Local_Agency_Phone_Number__c = relatedAccount.Phone;
                    ord.Archive_Local_Agency_Sales_Channel__c = relatedAccount.SalesChannel__c;
                    ord.Archive_Local_Agency_Sales_Rep__c = relatedAccount.Owner.Name;
                    ord.Archive_Local_Agency_Ship_To_City__c = relatedAccount.ShippingCity;
                    ord.Archive_Local_Agency_Ship_To_Country__c = relatedAccount.ShippingCountry__c;
                    ord.Archive_Local_Agency_Ship_To_State__c = relatedAccount.ShippingState;
                    ord.Archive_Local_Agency_Ship_To_Street_Addr__c = relatedAccount.ShippingStreet;
                    ord.Archive_Local_Agency_Ship_To_Street_Add2__c = relatedAccount.ShippingStreet;

                    ord.Archive_Local_Agency_Ship_To_PO_Box__c = relatedAccount.PO_Box__pc;

                    ord.Archive_Local_Agency_Ship_To_Zip__c = relatedAccount.ShippingPostalCode;
                    ord.Archive_Local_Agency_Site__c = relatedAccount.Site;
                    ord.Archive_Local_Agency_Xcode__c = relatedAccount.Primary_Xcode__c;
                    ord.Archive_Local_Agency_MS_Rep__c = relatedAccount.PrimaryServiceRep__r.Name;
                }
            }
            if(postingAccount != null){
                ord.Archive_Posting_Account_Name__c = postingAccount.Name;
                ord.Archive_Posting_Account_Type__c = postingAccount.Account_Type__c;
                ord.Archive_Posting_Agency_Flag__c = string.valueof(postingAccount.AgencyFlag__c);
                ord.Archive_Posting_Sales_Channel__c = postingAccount.SalesChannel__c;
                ord.Archive_Posting_Site__c = postingAccount.Site;
                ord.Archive_Shipping_Fax__c = postingAccount.Fax;
                ord.Archive_Shipping_Phone__c = postingAccount.Phone;
                ord.Archive_Shipping_Phone_Ext__c = postingAccount.PhoneExtension__c;
                ord.Archive_Posting_Phone_Number__c = postingAccount.Phone;
                //ord.Archive_Posting_Contact_Lead_Source__c = postingAccount.PrimaryBillingContact__r.ContactSource__c;
                ord.Archive_Posting_MS_Rep__c = postingAccount.Primary_Service_Rep_Name__c;
                //ord.Archive_Posting_Xcode__c = postingAccount.Primary_Xcode__c;

            }
        }
    }
    /*
** @author : Cloud Sherpas, Inc.
** @date : 11/13/2014
** @story :
** @element :
** @description :
** @paramaters :
** @returns : nothing
*/
    public void PopulateAgencyCommission(Order__c[] pOrder){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','PopulateAgencyCommission');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            Map<String,Id> PRSPartner = new Map<String,Id>();
            Set<String> SiteChannelIdSet = new Set<String>();
            List<Order__c> checkedOrderList = new List<Order__c>();

            for(Order__c ord : pOrder){
                if(ord.SiteChannelID__c != null && ord.SiteChannelID__c != ''){
                    SiteChannelIdSet.add(ord.SiteChannelID__c);
                    checkedOrderList.add(ord);
                    system.debug('^^^Order '+ord.Id+' SiteChannelID__c='+ord.SiteChannelID__c);
                }

            }

            if(checkedOrderList.size() == 0){
                system.debug('^^^No Orders with SiteChannelID__c populated');
                return;
            }


            for(Partner_Revenue_Share__c prs : queryPartnerRevenueShare()){
                PRSPartner.put(prs.SiteChannelID__c, prs.Partner__c);
            }
            if(!PRSPartner.isEmpty()){
                system.debug('^^^PRSPartner map: '+PRSPartner);
                for(Order__c ord : checkedOrderList){
                    ord.Agency__c = PRSPartner.get(ord.SiteChannelID__c);
                }
            }
        }catch(Exception e){
            ExceptionLog.add('Exception', 'OrderTriggerHelper', 'PopulateAgencyCommission', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to populate Agency field. Please see system logs for details. ' ,e);
        }
    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 12/18/2014
** @story : 0451
** @element : E2428
** @description : Copy the Primary sales rep of the Account (only for ECOMM Orders)
** @paramaters : List of Orders
** @returns : nothing
*/
    public void AssignPrimarySalesRepFROMMAPP(Order__c[] pOrder){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','AssignPrimarySalesRepFROMMAPP');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        try{
            set<String> orderSiteChannelIds = new Set<String>();
            List<Order__c> checkedOrderList = new List<Order__c>();

            for(Order__c ord : pOrder){
                if(ord.SiteChannelID__c != null && ord.Account__c != null){
                    orderSiteChannelIds.add(ord.SiteChannelID__c);
                    checkedOrderList.add(ord);
                }
            }
            Map<Id,Id> AccountSalesRepMap = new Map<Id,Id>();
            Map<String,Partner_Revenue_Share__c> OrderPRSMap = new Map<String,Partner_Revenue_Share__c>();
            Map<String,Id> PartnerUserMap = new Map<String, Id>();
            //Map<Id,String> AccountIds = new Map<Id,String>();
            //set<String> SalesRepLogins = new set<String>();
            //set<Id> noPRS = new set<Id>();
            if(!orderSiteChannelIds.isEmpty()){
                //for(Partner_Revenue_Share__c prs : [SELECT Id, Partner__c, SiteChannelID__c, MB_Sales_Rep_Login__c FROM Partner_Revenue_Share__c WHERE SiteChannelID__c IN: orderSiteChannelIds order by CreatedDate ASC]){
                for(Partner_Revenue_Share__c prs : queryPartnerRevenueShare()){
                    if(orderSiteChannelIds.contains(prs.SiteChannelID__c)){
                        OrderPRSMap.put(prs.SiteChannelID__c, prs);
                    }
                }
                if(!OrderPRSMap.isEmpty()){
                    for(String ids : OrderPRSMap.keySet()){
                        if(OrderPRSMap.get(ids).Partner__c != null){
                            for(Account acc : [SELECT Id, Primary_Sales_Rep_ID__c FROM Account WHERE Id =: OrderPRSMap.get(ids).Partner__c]){
                                AccountSalesRepMap.put(acc.Id,acc.Primary_Sales_Rep_ID__c);
                            }
                        }
                        if(OrderPRSMap.get(ids).Partner__c == null && OrderPRSMap.get(ids).MB_Sales_Rep_Login__c != null){
                            for(User urs : [SELECT Id FROM User WHERE FederationIdentifier =: OrderPRSMap.get(ids).MB_Sales_Rep_Login__c]){
                                PartnerUserMap.put(OrderPRSMap.get(ids).MB_Sales_Rep_Login__c, urs.Id);
                            }
                        }
                    }
                }
            }
            if(!OrderPRSMap.isEmpty()){
                for(Order__c ord : checkedOrderList){
                    if(OrderPRSMap.get(ord.SiteChannelID__c) != null){
                        if(OrderPRSMap.get(ord.SiteChannelID__c).Partner__c != null){
                            ord.PrimarySalesRep__c = AccountSalesRepMap.get(OrderPRSMap.get(ord.SiteChannelID__c).Partner__c);
                        }else if(OrderPRSMap.get(ord.SiteChannelID__c).Partner__c == null && OrderPRSMap.get(ord.SiteChannelID__c).MB_Sales_Rep_Login__c != null ){
                            if(PartnerUserMap.get(OrderPRSMap.get(ord.SiteChannelID__c).MB_Sales_Rep_Login__c) != null){
                                ord.PrimarySalesRep__c = PartnerUserMap.get(OrderPRSMap.get(ord.SiteChannelID__c).MB_Sales_Rep_Login__c);
                            }
                        }else{
                            ord.OrderStatus__c = 'Ecomm Exception';
                            ord.Description__c = 'Partner Revenue Share record does not have Partner Record or Sales Rep identified';
                        }
                    }

                }
            }
        }catch(Exception e){
             ExceptionLog.add('Exception', 'OrderTriggerHelper', 'AssignPrimarySalesRepFROMMAPP1', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to assign Primary sales rep.'+e ,e);
        }
    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 12/18/2014
** @story : 0451
** @element : E2428
** @description : Copy the Account Team Members to Order Team Members (only for ECOMM Orders)
** @paramaters : List of Orders
** @returns : nothing
*/
   public void AssignOrderTeamMembersFromMAPP(Order__c[] pOrder){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','AssignOrderTeamMembersFromMAPP');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            set<Id> AccountIds = new Set<Id>();
            for(Order__c ord : pOrder){
                if(ord.Account__c != null){
                    AccountIds.add(ord.Account__c);
                }
            }
            Map<Id,Set<Id>> AccountTeamMemberMap = new Map<Id,Set<Id>>();
            if(!AccountIds.isEmpty()){
                for(Account_Team_Member__c atm : [SELECT Id, AccountId__c,UserId__c FROM Account_Team_Member__c WHERE AccountId__c IN: AccountIds]){
                    if(AccountTeamMemberMap.containsKey(atm.AccountId__c)){
                        AccountTeamMemberMap.get(atm.AccountId__c).add(atm.UserId__c);
                    }else{
                        AccountTeamMemberMap.put(atm.AccountId__c , new Set<Id>());
                        AccountTeamMemberMap.get(atm.AccountId__c).add(atm.UserId__c);
                    }
                }
            }
            List<OrderTeam__c> OrderTeamToBeCreated = new List<OrderTeam__c>();
            if(!AccountTeamMemberMap.isEmpty()){
                for(Order__c ord: pOrder){
                    if(AccountTeamMemberMap.get(ord.Account__c) != null){
                        for(Id ids: AccountTeamMemberMap.get(ord.Account__c)){
                            OrderTeam__c ot = new OrderTeam__c();
                            ot.Order__c = ord.Id;
                            ot.TeamMember__c = ids;
                            OrderTeamToBeCreated.add(ot);
                        }
                    }
                }
            }
            if(!OrderTeamToBeCreated.isEmpty()){
                insert OrderTeamToBeCreated;
            }
        }catch(Exception e){
             ExceptionLog.add('Exception', 'OrderTriggerHelper', 'AssignOrderTeamMembersFromMAPP', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to update order team.' ,e);
        }
    }
    /**
     * @author Andre calimlim
     * @date 1.6.2015
     * @story 1091
     * @element E2023
     * @description This method will update the Finance Order Type based from the ordersToUpdateFOT mapped values
     * @param ordersToUpdateFOT - a List of Orders that will be updated
     */
    /*public void updateFinancialOrderType(List<Order__c> orderList){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateFinancialOrderType');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        Logger.push(METHODNAME, 'Order__c');

        Set<Id> orderIds = new Set<Id>();
        Set<Id> acctSet = new Set<Id>();
        for(Order__c ord : orderList){
            acctSet.add(ord.Account__c);
            if(ord.ParentOrder__c != null){
                orderIds.add(ord.ParentOrder__c);
            }

        }
        try{
            List<Order__c> ordersToUpdateFOT = new List<Order__c>();

            Map<Id, String> orderMap = new Map<Id, String>();
            Map<Id, Order__c> parentOrderMap;
            if(!orderIds.isEmpty()){
                parentOrderMap = new Map<Id, Order__c>([Select Id, Finance_Order_Type_pickList__c from Order__c where Id in : orderIds]);
            }
            if(!acctSet.isEmpty()){
                //Jeff L commented out to use new query framework
                //Map<Id, Account> acctMap = new Map<Id, Account>([Select Id, CustomerDate__c, CustomerLapsedDate__c, AccountStatus__c from Account where Id in : acctSet]);
                Map<Id,Account> acctMap = new Map<Id,Account>();
                for(Account a : queryAccountList()){
                    if(acctSet.contains(a.Id)){
                        acctMap.put(a.Id,a);
                    }
                }

                Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Order__c.getRecordTypeInfosById();

                for(Order__c ord : orderList){
                    Logger.debug('FOT picklist:' + ord.ParentOrder__r.Finance_Order_Type_pickList__c);
                    if(acctMap.get(ord.Account__c).AccountStatus__c == 'Candidate'){
                        orderMap.put(ord.Id, 'New');
                    } else {
                        if(rtMap.get(ord.RecordTypeId).getName() == 'Credit' && !parentOrderMap.isEmpty()){
                            orderMap.put(ord.Id, parentOrderMap.get(ord.ParentOrder__c).Finance_Order_Type_pickList__c);
                        } else if(ord.OrderDate__c == acctMap.get(ord.Account__c).CustomerDate__c){
                            orderMap.put(ord.Id, 'New');
                        } else if((acctMap.get(ord.Account__c).CustomerLapsedDate__c != null) && (monthsDiff(acctMap.get(ord.Account__c).CustomerLapsedDate__c.date(), ord.OrderDate__c) > 12)){
                            orderMap.put(ord.Id, 'Winback');
                        } else if((acctMap.get(ord.Account__c).CustomerLapsedDate__c != null) && (monthsDiff(acctMap.get(ord.Account__c).CustomerLapsedDate__c.date(), ord.OrderDate__c) <= 12)){
                            orderMap.put(ord.Id, 'Lapsed');
                        } else if(acctMap.get(ord.Account__c).AccountStatus__c == 'Customer'){
                            orderMap.put(ord.Id, 'Existing');
                        }
                    }

                }
            }

            if(!orderMap.isEmpty()){
                for(Order__c ord : [Select Id, Finance_Order_Type_pickList__c from Order__c where Id in : orderMap.keySet()]){
                    ord.Finance_Order_Type_pickList__c = orderMap.get(ord.Id);
                    ordersToUpdateFOT.add(ord);
                }
            }
            if(!ordersToUpdateFOT.isEmpty()){
                update ordersToUpdateFOT;
            }
        } catch (Exception ex){
            Logger.debugException(ex,null);
        }

        Logger.pop();
    }
    /**
     * @author Andre calimlim
     * @date 1.6.2015
     * @story 1091
     * @element E2023
     * @description This method will get the difference of months between dates
     * @param startDate - Date type indicating the start date
     * @param endDate - Date type indicating the end date
     * @return Integer value of the result between dates
     */
    /*private Integer monthsDiff(Date startDate, Date endDate){
        Integer monthDiff = startDate.monthsBetween(endDate);
        if (endDate.day() > startDate.day()){
            monthDiff++;
        }

        return monthDiff;
    }*/
/*
** @author : Cloud Sherpas, Inc.
** @date : 01/12/2014
** @story : 0451
** @element : E2498
** @description : populate Billing Address when quote/proposal is null.
** @paramaters : List of Orders
** @returns : nothing
*/
    public void populateBillingAddress(Order__c[] pOrders){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populateBillingAddress');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
       // try{
            set<Id> OrderAccountSet = new Set<Id>();
            for(Order__c ord: pOrders){
                if(UserInfo.getName() == 'Integration MAPP'){
                    if(ord.QuoteProposal__c == null){
                        OrderAccountSet.add(ord.Account__c);
                    }
                }
            }
            Map<Id, Account> AccountDetailsMap = new Map<Id,Account>();
            if(!OrderAccountSet.isEmpty()){
                //Jeff L commented out 2.22.16 for new query framework
                //for(Account ac : [SELECT Id, BillingStreet, BillingState, BillingPostalCode, BillingCountry, BillingCity FROM Account WHERE Id IN: OrderAccountSet]){
                for(Account a : queryAccountList()){
                    if(OrderAccountSet.contains(a.Id)){
                        AccountDetailsMap.put(a.Id, a);
                    }
                }
            }
            if(!AccountDetailsMap.isEmpty()){
                for(Order__c ord: pOrders){
                    ord.BillingCity__c = AccountDetailsMap.get(ord.Account__c).BillingCity;
                    ord.BillingCountry__c = AccountDetailsMap.get(ord.Account__c).BillingCountry;
                    ord.BillingStreet__c = AccountDetailsMap.get(ord.Account__c).BillingStreet;
                    ord.BillingStateProvince__c = AccountDetailsMap.get(ord.Account__c).BillingState;
                    ord.BillingZipPostalCode__c = AccountDetailsMap.get(ord.Account__c).BillingPostalCode;
                }
            }
       // }catch(Exception e){
           //  ExceptionLog.add('Exception', 'OrderTriggerHelper', 'populateBillingAddress', e.getMessage());
           // throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to populate billing address.' ,e);
        //}
    }


   //I-193729
   public void populateBillingAddressandContact(Order__c[] pOrders, Map<Id,Order__c> oldOrdersMap){

        set<Id> OrderAccountSet = new Set<Id>();
        Map<Id, Account> AccountDetailsMap = new Map<Id,Account>();
        for(Order__c ord : pOrders){
            if(oldOrdersMap != null && ord.BillingAccount__c != null && ord.BillingAccount__c != oldOrdersMap.get(ord.Id).BillingAccount__c){
                OrderAccountSet.add(ord.BillingAccount__c);
            }else{
                if(oldOrdersMap == null && ord.BillingAccount__c != null)
                OrderAccountSet.add(ord.BillingAccount__c);
            }
        }
         if(!OrderAccountSet.isEmpty()){
            //Jeff L commented out 2.22.16 for new query framework
            for(Account ac : [SELECT Id, PrimaryBillingContact__c,PrimaryBillingContact__r.FirstName,PrimaryBillingContact__r.LastName,BillingStreet, BillingState, BillingPostalCode, BillingCountry, BillingCity FROM Account WHERE Id IN: OrderAccountSet]){
            //for(Account a : queryAccountList()){
                if(OrderAccountSet.contains(ac.Id)){
                    AccountDetailsMap.put(ac.Id, ac);
                }
            }
        }

         if(!AccountDetailsMap.isEmpty()){
                for(Order__c ord: pOrders){
                    if(AccountDetailsMap.containsKey(ord.BillingAccount__c) && AccountDetailsMap.get(ord.BillingAccount__c) != null) {
                        ord.BillingCity__c = AccountDetailsMap.get(ord.BillingAccount__c).BillingCity;
                        ord.BillingCountry__c = AccountDetailsMap.get(ord.BillingAccount__c).BillingCountry;
                        ord.BillingStreet__c = AccountDetailsMap.get(ord.BillingAccount__c).BillingStreet;
                        ord.BillingStateProvince__c = AccountDetailsMap.get(ord.BillingAccount__c).BillingState;
                        ord.BillingZipPostalCode__c = AccountDetailsMap.get(ord.BillingAccount__c).BillingPostalCode;
                        // I-212627
                        if(ord.QuoteProposal__c == null) {
                            ord.BillingContact__c = AccountDetailsMap.get(ord.BillingAccount__c).PrimaryBillingContact__c;
                        }

                    }
                }
        }



   }


    /*
** @author : Appirio, Inc.
** @date : 02/06/2015
** @story : S-319051
** @element : T-406236
** @description : populate CR Status Comment from BillingAccount__c's CR Status Comment.
** @paramaters : List of Orders
** @returns : nothing
*/
    public void populateCRStatusComment(Order__c[] pOrders){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populateCRStatusComment');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            set<Id> OrderAccountId = new Set<Id>();
            for(Order__c ord: pOrders){
                 OrderAccountId.add(ord.BillingAccount__c);
            }

            Map<Id, Account> AccountDetails = new Map<Id,Account>();
            if(!OrderAccountId.isEmpty()){
                //Jeff L commented out for new query framework 2.22.16
                //for(Account ac : [SELECT CR_Status_Comment__c FROM Account WHERE Id IN: OrderAccountId]){
                for(Account a : queryAccountList()){
                    if(OrderAccountId.contains(a.Id)){
                        AccountDetails.put(a.Id, a);
                    }
                }
            }
            if(!AccountDetails.isEmpty()){
                for(Order__c ord: pOrders){
                    if(AccountDetails.containsKey(ord.BillingAccount__c))
                    ord.CR_Status_Comment__c = AccountDetails.get(ord.BillingAccount__c).CR_Status_Comment__c;
                    }
            }
        }catch(Exception e){
             ExceptionLog.add('Exception', 'OrderTriggerHelper', 'populateCRStatusComment', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to populate CR Status Comment.' ,e);
        }
    }

    public void populateEntityId(Order__c[] pOrders, Map<Id,Order__c> oldOrdersMap , Map<Id,Order__c> newOrdersMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populateEntityId');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        Map<Id, Id> quoteIdToEntityIdMap = new Map<Id,Id>();
        Map<Order__c, Id> orderIdToQuoteIdMap = new Map<Order__c,Id>();
        set<Id> quoteIdSet = new Set<Id>();
        Boolean isUpdate = true;
        Id quoteId;
        if(oldOrdersMap == null){
            isUpdate = false;
          }
        try{

            if(isUpdate == false){
                for(Order__c ord: pOrders){
                     quoteIdSet.add(ord.QuoteProposal__c);
                     orderIdToQuoteIdMap.put(ord,ord.QuoteProposal__c);
                }
            }else{

                for(Id  ord: oldOrdersMap.keySet()){

                    if(newOrdersMap.get(ord).QuoteProposal__c!= null && newOrdersMap.get(ord).QuoteProposal__c != oldOrdersMap.get(ord).QuoteProposal__c ){

                    Id quote_Id = newOrdersMap.get(ord).QuoteProposal__c;
                    quoteIdSet.add(quote_Id );
                    orderIdToQuoteIdMap.put(newOrdersMap.get(ord),quote_Id );

                   }
                }

            }

            if(!quoteIdSet.isEmpty()){
                for(Apttus_Proposal__Proposal__c apttus : queryQuoteProposal()){
                    if(quoteIdSet.contains(apttus.Id)){
                        quoteIdToEntityIdMap.put(apttus.id,apttus.Entity_ID__c);
                    }
                }
            }

            if(!quoteIdSet.isEmpty()){
                for(Order__c ord: pOrders){

                    if(orderIdToQuoteIdMap.containsKey(ord)){
                         quoteId = orderIdToQuoteIdMap.get(ord);
                    }

                    if(quoteIdToEntityIdMap.containsKey(quoteId)){
                        if(ord.Posting_Contact__c == null)
                             ord.Entity_ID__c = quoteIdToEntityIdMap.get(quoteId);
                    }

                }

            }


        }catch(Exception e){
             ExceptionLog.add('Exception', 'OrderTriggerHelper', 'populateEntityId', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to populate CR Status Comment.' ,e);
        }
    }

/*
** @author : Adarsh
** @date : 07/06/2015
** @story :
** @Issue : I-167039
** @description : Creating customer number for existing Candidate Account
** @paramaters : list of Accounts[]
** @returns : nothing
*/
    /*public void updateCustomerNumberforAccounts(Order__c[] pOrder){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateCustomerNumberforAccounts');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            Set<Id> AccountIds = new Set<Id>();
            Set<Id> OrdAcctIdsSet = new Set<Id>();
            List<Account> insertCus = new List<Account>();
            //system.debug('accList' + accList);
            //Jeff L commented out, no need to query here
            //for(Order__c ord : [SELECT Id, Account__c FROM Order__c WHERE Id In: pOrder]){
            for(Order__c ord : pOrder){
                OrdAcctIdsSet.add(ord.Account__c);
            }
            //Jeff L commented out to use new query framework 2.22.16
            //List<Account> accList = [select CustomerNumber__c from account where Id in: OrdAcctIdsSet];
            List<Account> accList = new List<Account>();
            for(Account a : queryAccountList()){
                if(OrdAcctIdsSet.contains(a.Id)){
                    accList.add(a);
                }
            }
            system.debug('accList' + accList);
            for(Account acc : accList){
                    AccountIds.add(acc.Id);
                    system.debug('AccountId' + AccountIds);
                    if(!AccountIds.isEmpty()){
                        system.debug('accCustomerNumber' + acc.CustomerNumber__c);
                        if(acc.CustomerNumber__c == null){
                            system.debug('calculation' + Math.round((Math.random() * 10000000) + 1));
                            //acc.CustomerNumber__c = 'CUS' + '_' + Double.valueOf(Math.floor((Math.random() * 10000000) + 1));
                            Integer rand = Math.round((Math.random() * 10000000) + 1);
                            //acc.CustomerNumber__c = 'CUS' + '-' + rand;
                            String srand = string.valueOf(rand);
                            acc.CustomerNumber__c = srand;
                            system.debug('acc.CustomerNumber' + acc.CustomerNumber__c);
                            acc.CustomerDate__c=Date.Today();
                            system.debug('CustomerDate' + acc.CustomerDate__c);
                            system.debug('accAccountStatus' + acc.AccountStatus__c);
                            //if(acc.AccountStatus__c == 'Candidate' || acc.AccountStatus__c == null)
                            //{
                                acc.AccountStatus__c = 'Customer';
                            //}
                            system.debug('AccountStatus' + acc.AccountStatus__c);
                            insertCus.add(acc);
                        }
                    }
            }
             if(insertCus != null)
             {
                upsert insertCus;
             }
        }
        catch(Exception bae){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Failed to update customer number. Please see system log for details.', bae);
        }
    }*/
    /* Commenting this code as the instance of this code already exists in updateCustumerNumberofAccounts.
     * Also the code updateCustomerNumberforAccounts is in particular for ecomm orders.
    public void updateCustomerNumberforAccounts(Order__c[] pOrder){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateCustomerNumberforAccounts');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            Set<Id> AccountIds = new Set<Id>();
            Set<Id> OrdAcctIdsSet = new Set<Id>();
            List<Account> insertCus = new List<Account>();
            for(Order__c ord : pOrder){
                if(ord.Agency__c != null){
                    OrdAcctIdsSet.add(ord.Agency__c);
                }
            }
            String Max = '';
            MaximumCustomerNumber__c maxCN = MaximumCustomerNumber__c.getOrgDefaults();
            if (maxCN == null) maxCN = new MaximumCustomerNumber__c();
            List<Account> AccountsToBeUpdated = new List<Account>();
            for(Account acc : [SELECT  Id, CustomerNumber__c, CustomerDate__c, AccountStatus__c FROM Account WHERE Id in :OrdAcctIdsSet and CustomerNumber__c = null and AccountStatus__c = 'Candidate']){
                Max = String.valueOf(maxCN.MaxCustNum__c.longvalue() + 1);
                maxCN.MaxCustNum__c = decimal.valueOf(Max);
                acc.AccountStatus__c = 'Customer';
                acc.CustomerDate__c = Date.Today();
                acc.CustomerNumber__c =  Max;
                AccountsToBeUpdated.add(acc);
            }
            if(!AccountsToBeUpdated.isEmpty()){
                AccountTriggerHandler.ExecuteTriggers = false;
                update AccountsToBeUpdated;
                upsert maxCN;
            }
        }
        catch(Exception bae){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Failed to update customer number. Please see system log for details.', bae);
        }
    }*/

/*
** @author : Appirio, Inc.
** @date : 08/06/2015
** @story : S-323564
** @element : T-408279
** @description : populate Posting Contact From Quote PostingContact__c
** @paramaters : List of Orders
** @returns : nothing
*/
    public void populatePostingContact(Order__c[] pOrders){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populatePostingContact');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            set<Id> QuoteId = new Set<Id>();
            for(Order__c ord: pOrders){
                if(ord.Posting_Contact__c == null){
                    QuoteId.add(ord.QuoteProposal__c);
                }
            }

            Map<Id, Apttus_Proposal__Proposal__c> QuoteDetails = new Map<Id,Apttus_Proposal__Proposal__c>();

            //Jeff L. Updated 9/25/15 to use new autogenerated query!
            if(!QuoteId.isEmpty()){
                for(Apttus_Proposal__Proposal__c  quote : queryQuoteProposal()){
                    if(QuoteId.contains(quote.Id)){
                        QuoteDetails.put(quote.Id, quote);
                    }
                }
            }
            system.debug('***QuoteDetails***' +QuoteDetails +'^^^^^^^^^^^^^' +QuoteId);
            for(Order__c ord: pOrders){
                    if(ord.Posting_Contact__c == null){
                if(QuoteDetails.containsKey(ord.QuoteProposal__c)){
                    system.debug(QuoteDetails.get(ord.QuoteProposal__c));
                    system.debug(QuoteDetails.get(ord.QuoteProposal__c).PostingContact__c);
                    Id conId = QuoteDetails.get(ord.QuoteProposal__c).PostingContact__c ;
                    if(conId != null){
                        ord.Posting_Contact__c  = conId ;
                        system.debug('***conId ***' +conId );
                    }
                    else{
                        ord.Posting_Contact__c = QuoteDetails.get(ord.QuoteProposal__c).BillContact__c ;
                    }

                }}
                system.debug(ord.Posting_Contact__c+'!!!@@@');
            }
            system.debug('!!!!!!!!!!!!!!!');
        }catch(Exception e){
            ExceptionLog.add('Exception', 'OrderTriggerHelper', 'populatePostingContact', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to  populatePostingContact.' ,e);
        }
    }

/*
** @author : Appirio, Inc.
** @date :
** @element :
** @description :
** @paramaters : List of Orders
** @returns : nothing
*/
    public void populateNumberOFInstallment(Order__c[] pOrders){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populateNumberOFInstallment');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            set<Id> QuoteId = new Set<Id>();
            for(Order__c ord: pOrders){
                if(ord.New_Number_of_Installment__c == null){
                    QuoteId.add(ord.QuoteProposal__c);
                }
            }

            Map<Id, Apttus_Proposal__Proposal__c> QuoteDetails = new Map<Id,Apttus_Proposal__Proposal__c>();

            //Jeff L. Updated 9/25/15 to use new autogenerated query!
            if(!QuoteId.isEmpty()){
                for(Apttus_Proposal__Proposal__c  quote : queryQuoteProposal()){
                    if(QuoteId.contains(quote.Id)){
                        QuoteDetails.put(quote.Id, quote);
                    }
                }
            }
            system.debug('***QuoteDetails***' +QuoteDetails +'^^^^^^^^^^^^^' +QuoteId);
            for(Order__c ord: pOrders){

                if(QuoteDetails.containsKey(ord.QuoteProposal__c)){
                     system.debug(QuoteDetails.get(ord.QuoteProposal__c).New_Number_of_Installments__c);
                  //  Id conId = QuoteDetails.get(ord.QuoteProposal__c).New_Number_of_Installments__c;
                    if(QuoteDetails.get(ord.QuoteProposal__c).New_Number_of_Installments__c != null){
                        ord.New_Number_of_Installment__c= QuoteDetails.get(ord.QuoteProposal__c).New_Number_of_Installments__c;
                   //     system.debug('***conId ***' +conId );
                    }


                }
                // system.debug(ord.Posting_Contact__c+'!!!@@@');
            }
            system.debug('!!!!!!!!!!!!!!!');
        }catch(Exception e){
            ExceptionLog.add('Exception', 'OrderTriggerHelper', 'populateNumberOFInstallment', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to  populateNumberOFInstallment.' ,e);
        }
    }

 public void populateAgencyBillingContact(Order__c[] pOrders){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populateAgencyBillingContact');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            Set<Id> QuoteId = new Set<Id>();
            List<Order__c> ordersToCheck = new List<Order__c>();
            for(Order__c ord: pOrders){
                /*if(ord.QuoteProposal__c != null && ord.Agency__c != null){
                    QuoteId.add(ord.QuoteProposal__c);
                    ordersToCheck.add(ord);
                }*/
                if(ord.QuoteProposal__c != null)
                    QuoteId.add(ord.QuoteProposal__c);
                if(ord.Agency__c != null)
                    ordersToCheck.add(ord);

            }

            Map<Id, Apttus_Proposal__Proposal__c> QuoteDetails = new Map<Id,Apttus_Proposal__Proposal__c>();

            //Jeff L. Updated 9/25/15 to use new autogenerated query!
            if(!QuoteId.isEmpty()){
                for(Apttus_Proposal__Proposal__c  quote : queryQuoteProposal()){
                    if(QuoteId.contains(quote.Id)){
                        QuoteDetails.put(quote.Id, quote);
                    }
                }
            }
            system.debug('***QuoteDetails***' +QuoteDetails +'^^^^^^^^^^^^^' +QuoteId);
            Map<Id,List<Order__c>> ordersThatNeedAgency = new Map<Id,List<Order__c>>();
            for(Order__c ord: ordersToCheck){
                /*
                if(QuoteDetails.containsKey(ord.QuoteProposal__c)){
                     system.debug(QuoteDetails.get(ord.QuoteProposal__c).AgencyBillingContact__c);
                  //  Id conId = QuoteDetails.get(ord.QuoteProposal__c).New_Number_of_Installments__c;
                    if(QuoteDetails.get(ord.QuoteProposal__c).AgencyBillingContact__c != null){
                        ord.AgencyBillingContact__c = QuoteDetails.get(ord.QuoteProposal__c).AgencyBillingContact__c ;
                        //ord.Agency__c = QuoteDetails.get(ord.QuoteProposal__c).Agency__c;
                   //     system.debug('***conId ***' +conId );
                    } else {
                        //this means that we will need to query for the agency and get the primary billing contact from there
                        if(ordersThatNeedAgency.get(ord.Agency__c) == null){
                            ordersThatNeedAgency.put(ord.Agency__c, new List<Order__c>());
                        }
                        ordersThatNeedAgency.get(ord.Agency__c).add(ord);
                    }
                }

                */


                if(QuoteDetails.containsKey(ord.QuoteProposal__c)){
                     system.debug(QuoteDetails.get(ord.QuoteProposal__c).AgencyBillingContact__c);
                  //  Id conId = QuoteDetails.get(ord.QuoteProposal__c).New_Number_of_Installments__c;
                    if(QuoteDetails.get(ord.QuoteProposal__c).AgencyBillingContact__c != null){
                        ord.AgencyBillingContact__c = QuoteDetails.get(ord.QuoteProposal__c).AgencyBillingContact__c ;
                        //ord.Agency__c = QuoteDetails.get(ord.QuoteProposal__c).Agency__c;
                   //     system.debug('***conId ***' +conId );
                     }
                    }
                    if(!QuoteDetails.containsKey(ord.QuoteProposal__c) || QuoteDetails.get(ord.QuoteProposal__c).AgencyBillingContact__c == null) {
                        //this means that we will need to query for the agency and get the primary billing contact from there
                        if(ordersThatNeedAgency.get(ord.Agency__c) == null){
                            ordersThatNeedAgency.put(ord.Agency__c, new List<Order__c>());
                        }
                        ordersThatNeedAgency.get(ord.Agency__c).add(ord);
                    }


                // system.debug(ord.Posting_Contact__c+'!!!@@@');
                system.debug('ord.AgencyBillingContact__c ' + ord.AgencyBillingContact__c);
                system.debug('ord.Agency ' + ord.Agency__c);
            }

            if(!ordersThatNeedAgency.isEmpty()){
                For(Account agency : [Select Id, PrimaryBillingContact__c from Account where Id in :ordersThatNeedAgency.keySet()]){
                    for(Order__c ord : ordersThatNeedAgency.get(agency.Id)){
                        ord.AgencyBillingContact__c = agency.PrimaryBillingContact__c;
                    }
                }
            }

        }catch(Exception e){
            ExceptionLog.add('Exception', 'OrderTriggerHelper', 'populateAgencyBillingContact', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to  populateAgencyBillingContact.' ,e);
        }
    }


/*
** @author : Appirio, Inc.
** @date : 08/06/2015
** @story : S-323564
** @element : T-408279
** @description : populate Bill Contact From Quote billing Contact
** @paramaters : List of Orders
** @returns : nothing
*/
    public void populateBillcontactAndBillingAccount(Order__c[] pOrders){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populateBillcontact');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            set<Id> QuoteId = new Set<Id>();
            List<Order__c> ordersToUpdate = new List<Order__c>();
            for(Order__c ord: pOrders){
                if(ord.BillingContact__c == null){
                    QuoteId.add(ord.QuoteProposal__c);
                    ordersToUpdate.add(ord);
                }
            }

            Map<Id, Apttus_Proposal__Proposal__c> QuoteDetails = new Map<Id,Apttus_Proposal__Proposal__c>();

            //Jeff L. Updated 9/25/15 to use new autogenerated query!
            if(!QuoteId.isEmpty()){
                for(Apttus_Proposal__Proposal__c  quote : queryQuoteProposal()){
                    if(QuoteId.contains(quote.Id)){

                        QuoteDetails.put(quote.Id, quote);

                        // Commented due to I-212627, billing contact on order should come from quote billing contact

                        /*for(Order__c ord: ordersToUpdate){
                            if(quote.Id == ord.QuoteProposal__c){
                               boolean contactPopulated = false;
                                // Jeff L updated for new logic 11/10/2015
                                //if the order has an agency, then we need to populate the billing contact from the agency

                               if(ord.Agency__c != null){
                                    ord.BillingAccount__c = ord.Agency__c;
                                    if(ord.AgencyBillingContact__c != null){
                                        ord.BillingContact__c = ord.AgencyBillingContact__c;
                                        contactPopulated = true;
                                    }
                                }

                                //No agency or we haven't found the contact yet - lets try the quote/proposal
                               if(!contactPopulated){
                                if(quote.BillContact__c != null){
                                    ord.BillingAccount__c = quote.BillingAccount__c;
                                    ord.BillingContact__c = quote.BillContact__c;
                                    contactPopulated = true;
                                }
                             }
                            }
                        } */

                        // Added below code due to I-212627

                        for(Order__c ord: ordersToUpdate){
                            if(quote.Id == ord.QuoteProposal__c){
                               boolean contactPopulated = false;

                                if(quote.BillContact__c != null){
                                    ord.BillingAccount__c = quote.BillingAccount__c;
                                    ord.BillingContact__c = quote.BillContact__c;
                                    contactPopulated = true;
                                }

                                if(!contactPopulated){
                                   if(ord.Agency__c != null){
                                        ord.BillingAccount__c = ord.Agency__c;
                                        if(ord.AgencyBillingContact__c != null){
                                            ord.BillingContact__c = ord.AgencyBillingContact__c;
                                            contactPopulated = true;
                                        }
                                    }
                                }
                            }
                        }


                    }
                }
            }


            /*system.debug('***QuoteDetails***' +QuoteDetails +'^^^^^^^^^^^^^' +QuoteId);
            for(Order__c ord: ordersToUpdate){
                boolean contactPopulated = false;
                // Jeff L updated for new logic 11/10/2015
                //if the order has an agency, then we need to populate the billing contact from the agency
                if(ord.Agency__c != null){
                    ord.BillingAccount__c = ord.Agency__c;
                    if(ord.AgencyBillingContact__c != null){
                        ord.BillingContact__c = ord.AgencyBillingContact__c;
                        contactPopulated = true;
                    }
                }

                //No agency or we haven't found the contact yet - lets try the quote/proposal
                if(!contactPopulated){
                    Apttus_Proposal__Proposal__c proposal = QuoteDetails.get(ord.Id);
                    if(proposal != null && proposal.BillContact__c != null){
                        ord.BillingAccount__c = proposal.BillingAccount__c;
                        ord.BillingContact__c = proposal.BillContact__c;
                        contactPopulated = true;
                    }
                }

                /* Jeff L Commented out
                if(Proposal.BillingContact__c != null)
                 //if(proposal.BillingAccount__c == null){
                    if(ord.Agency__c != null){
                        ord.BillingAccount__c = ord.Agency__c;
                    }else if(ord.Account__c != null){
                        ord.BillingAccount__c = ord.Account__c;
                    }
                 //}
                 //if(proposal.BillContact__c == null){
                    if(ord.AgencyBillingContact__c != null){
                        ord.BillingContact__c = ord.AgencyBillingContact__c;
                    }else if(ord.Account__r.PrimaryBillingContact__c != null){
                        ord.BillingContact__c = ord.Account__r.PrimaryBillingContact__c;
                    }*/
                 //}*/


        }catch(Exception e){
            ExceptionLog.add('Exception', 'OrderTriggerHelper', 'populateBillcontact', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to  populate Billcontact.' ,e);
        }
    }

/*
** @author : Appirio, Inc. (Piyush jain)
** @date : 23/07/2015
** @story : S-317617
** @element : T-421927
** @description : Populate Order Payment Details By Values from Quote/Proposal
** @paramaters : List of Orders
** @returns : nothing
*/
    public void populateOrderPaymentDetailsByQuote(Order__c[] pNewOrders){

        set<Id> quoteIds = new set<Id>();
        List<Order__c> ordersToCheck = new List<Order__c>();
        for(Order__c ord: pNewOrders) {
            if(ord.QuoteProposal__c != null &&
                (ord.Payment_Frequency__c == null ||
                ord.Payment_Method_text__c == null ||
                ord.Payment_Term_text__c == null)){

                system.debug('order QuoteId ' + ord.QuoteProposal__c);
                quoteIds.add(ord.QuoteProposal__c);
                ordersToCheck.add(ord);
            }
        }

        Map<Id,Apttus_Proposal__Proposal__c> mapQuoteId = new Map<Id,Apttus_Proposal__Proposal__c>();

        //Jeff L. Updated 9/25/15 to use new autogenerated query!
        For(Apttus_Proposal__Proposal__c quote : queryQuoteProposal()){
            system.debug('Inside of queryQuoteProposal - quote ID ' + quote.Id);
            if(quoteIds.contains(quote.Id)){
                mapQuoteId.put(quote.Id, quote);
            }
        }

        for(Order__c ord: ordersToCheck) {
            if(mapQuoteId.containsKey(ord.QuoteProposal__c)){

                ord.Payment_Frequency__c = mapQuoteId.get(ord.QuoteProposal__c).Payment1_Frequency__c;
                ord.Payment_Method_text__c = mapQuoteId.get(ord.QuoteProposal__c).Payment_Method1__c;
                ord.Payment_Term_text__c = mapQuoteId.get(ord.QuoteProposal__c).Payment1_Term__c;
                ord.Installments__c = mapQuoteId.get(ord.QuoteProposal__c).Number_of_Installment__c;
                system.debug('*<> Payment Info: ' + ord.Payment_Frequency__c + ' ' + ord.Payment_Method_text__c + ' ' +ord.Payment_Term_text__c + ' ' +ord.Installments__c);
            }
        }

    }
/*
** @author : Appirio, Inc.
** @date : ?
** @description : Set the SiteChannel Id on an Order based upon the quote/proposal
** @paramaters : List of Orders
** @returns : nothing
*/
    public void setOrderSiteChannelId(Order__c[] pNewOrders){
        set<Id> proposalIds = new set<Id>();
        for(Order__c o : pNewOrders) {
            if(o.QuoteProposal__c != null) {
                proposalIds.add(o.QuoteProposal__c);
            }
        }

        if(proposalIds.isEmpty()) return;

        map<Id, Apttus_Proposal__Proposal__c> proposalMap = new map<Id, Apttus_Proposal__Proposal__c>();

        //Jeff L. Updated 9/25/15 to use new autogenerated query!
        for(Apttus_Proposal__Proposal__c quote : queryQuoteProposal()){
            if(proposalIds.contains(quote.Id) && quote.Site_Channel_ID__c != null){
                proposalMap.put(quote.Id,quote);
            }
        }


        for(Order__c o : pNewOrders) {
            if(o.QuoteProposal__c != null && proposalMap != null && proposalMap.containsKey(o.QuoteProposal__c)) {
                //o.Site_Channel_ID__c = proposalMap.get(o.QuoteProposal__c).Site_Channel_ID__c;
                o.SiteChannelID__c = proposalMap.get(o.QuoteProposal__c).Site_Channel_ID__c;
            }

        }

    }

/*
** @author : Appirio, Inc. (Gaurav G)
** @date : 25/06/2015
** @story : S-323592
** @element : T-413051
** @description : Update the Order Agency fields.
** @paramaters : List of Orders
** @returns : nothing
*/

    public void updateOrdersFormulaFields (list<Order__c> lstNewOrders){
        Set<Id> quoteIdSet = new Set<Id>();

        for(Order__c ord : lstNewOrders){
            quoteIdSet.add(ord.QuoteProposal__c);
        }


        Map<id , Apttus_Proposal__Proposal__c > mapProposals = new Map<id , Apttus_Proposal__Proposal__c >();

        for( Apttus_Proposal__Proposal__c quote : queryQuoteProposal() ){
            if(quoteIdSet.contains(quote.Id)){
                mapProposals.put(quote.Id,quote);
            }
        }


        Apttus_Proposal__Proposal__c proposal ;
        for(Order__c o : lstNewOrders){
            proposal = mapProposals.get(o.QuoteProposal__c);
            //Jeff L 09/28/2015 - added null check, there is a case where if the order is from MAPP then it will
            //not have a proposal.
            if(proposal != null){
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

    }

/*
** @author : Adarsh
** @date :
** @story :S-334603
** @Issue :
** @description : PopulateSalesRep - Jeff updated to reduce number of SOQL queries,
                  Jeff L 01/10/2016 according to I-197511 we are only going to grab
                  the Owner who has been set at the Account level we will NOT be using territory
                  assignment rules here anymore.
** @paramaters :
** @returns : nothing
*/
    public void PopulateSalesRep (Order__c [] pNewOrders){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','PopulateSalesRep');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            Set<Id> ordAccontIdSet = new Set<ID>();
            Set<Id> OrdAcctIdsSet = new Set<ID>();
            Map<Id,Id> accountIdToOwnerMap = new Map<Id,Id>();
            List<Order__c> ordersToUpdate = new List<Order__c>();
            Set<String> prslogin = new Set<String>();
            Set<String> prsMBlogin = new Set<String>();
            Set<String> OrdSiteIds = new Set<String>();
            Set<String> prsSiteIds = new Set<String>();
            Set<String> AccountIds= new Set<String>();
            Set<String> ShipAccCountry = new Set<String>();
            Set<String> xAccountIds = new Set<String>();
            Set<String> TAssign = new Set<String>();
            String ExistOwner;
            String QuoteSellingCountry;//I-196334
            String Orgnization;
            String ProfileId;
            Datetime accCreateddate;
            Datetime orderCreateddate;
            Boolean LiveChannelFlag;
            Id ownerId;
            String SalesChannel;
            String Shipcountry;
            List<Profile> userProfiles = new List<Profile>();
            for(Order__c ord : pNewOrders){
                ordAccontIdSet.add(ord.Account__c);
                QuoteSellingCountry = ord.Quote_Selling_Country__c;
                Orgnization = ord.Organization__c;
                OrdAcctIdsSet.add(ord.Account__c);
                orderCreateddate = ord.CreatedDate;
            }

            List<Account> ExistaccntList = new List<Account>();
            for(Account a : queryAccountList()){
                if(OrdAcctIdsSet.contains(a.Id)){
                    ExistaccntList.add(a);
                }
                accCreateddate = a.CreatedDate;
                Shipcountry = a.ShippingCountry__c;
            }
            Long dt1Long = orderCreateddate.getTime();
            system.debug('dt1Long' + dt1Long);
            Long dt2Long = accCreateddate.getTime();
            system.debug('dt2Long' + dt2Long);
            Long milliseconds = dt1Long - dt2Long;
            system.debug('milliseconds' + milliseconds);
            Long seconds = milliseconds / 1000;
            system.debug('seconds' + seconds);
            Long minutes = seconds / 60;
            system.debug('minutes' + minutes);
            for(Account ExistAcnt: ExistaccntList){
                ExistOwner= ExistAcnt.Owner.Name;
            }
            for(Order__c ordPrs: pNewOrders){
                    if(String.isNotBlank(ordPrs.SiteChannelID__c)){
                        OrdSiteIds.add(ordPrs.SiteChannelID__c);
                    }
             }
             List<Partner_Revenue_Share__c> PrsList = queryPartnerRevenueShare();
             system.debug('PrsList' + PrsList);
             for(Partner_Revenue_Share__c Prs: PrsList){
                    if(OrdSiteIds.contains(Prs.SiteChannelID__c)){
                        prsSiteIds.add(Prs.SiteChannelID__c);
                        system.debug('prsSiteIds' + prsSiteIds);
                        prsMBlogin.add(Prs.MB_Sales_Rep_Login__c);//I-186042
                        prslogin.add(Prs.Partner__c);
                    }
                    LiveChannelFlag = Prs.MB_Live_Channel_Flag__c;
                }
                List<Account> PartaccntList = [select OwnerId,Owner.Name,Primary_Xcode__c,ShippingCountry__c  from account where Id in: prslogin];
                if(!PrsList.isEmpty() && LiveChannelFlag == true ){
                    system.debug('salesrep1');
                    if(minutes>=2){
                        List<Order__c> updatedateOrdList = new List<Order__c>();
                        for(Account usrowner: PartaccntList){
                            ownerId = usrowner.ownerId;
                         }

                        for(Order__c existOrd: pNewOrders){
                            Order__c ord = new Order__c();
                            ord.Id = existOrd.Id;
                            ord.PrimarySalesRep__c = ownerId;
                            ord.SalesChannel__c = 'Partner';
                            ord.Combined_Region__c   = 'Newspapers';
                            ord.Position_Organization__c = 'Newspapers';
                            updatedateOrdList.add(ord);
                        }
                        update updatedateOrdList;

                    }
                    else{
                        system.debug('salesrep2');
                        if(!prsSiteIds.isEmpty()){
                            List<Order__c> UpdateprsOrdList = new List<Order__c>();
                            List<Account> UpdateprsAccList = new List<Account>();
                            if(!PartaccntList.isEmpty()){
                                for(Account usrowner: PartaccntList){
                                ownerId = usrowner.ownerId;
                                }
                                List<User> partneruser = [select PositionSalesChannel__c,Position_Organization__c,Combined_Region__c  from User where Id =:ownerId];
                                for(Account usr: PartaccntList)
                                {
                                   for(Account prsAcnt: ExistaccntList){
                                        Account acc = new Account();
                                        acc.Id = prsAcnt.Id;
                                        acc.OwnerId = usr.OwnerId;
                                        system.debug('prsAcnt.OwnerId' + prsAcnt.OwnerId);
                                        UpdateprsAccList.add(acc);
                                    }
                                    for(User prsuserord: partneruser ){
                                        SalesChannel = prsuserord.PositionSalesChannel__c;
                                        for(Order__c prsOrdList: pNewOrders){
                                            Order__c ord = new Order__c();
                                            ord.Id = prsOrdList.Id;
                                            ord.PrimarySalesRep__c = usr.OwnerId;
                                            ord.Combined_Region__c   = prsuserord.Combined_Region__c;
                                            ord.Position_Organization__c = prsuserord.Position_Organization__c;
                                            if(!prslogin.isEmpty() && LiveChannelFlag == true){
                                                if(SalesChannel != '') {
                                                    ord.SalesChannel__c = SalesChannel;
                                                }
                                                else
                                                {
                                                  ord.SalesChannel__c = 'Partner';
                                                }

                                            } else {
                                                system.debug('first default ECOMM');
                                                ord.SalesChannel__c = 'ECOMM';
                                            }
                                            if(PrsList.isEmpty()){
                                                system.debug('Non Partner');
                                                if(SalesChannel !=''){
                                                    ord.SalesChannel__c = SalesChannel;
                                                }
                                                else {
                                                    ord.SalesChannel__c = 'ECOMM';
                                                }
                                            }
                                            system.debug('prsOrdList.PrimarySalesRep__c' + prsOrdList.PrimarySalesRep__c);
                                            UpdateprsOrdList.add(ord);
                                        }
                                    }
                                }
                            }
                            else{
                                system.debug('salesrep3');
                                List<User> userlist = [Select Id,PositionSalesChannel__c,Position_Organization__c,Combined_Region__c from User where  Network_Domain_Login__c in:prsMBlogin limit 1];
                                system.debug('userlist' + userlist);
                                if(!userlist.isEmpty()){
                                    for(User usr1: userlist){
                                        SalesChannel = usr1.PositionSalesChannel__c;
                                        for(Account prsAcnt1: ExistaccntList){
                                            Account acc = new Account();
                                            acc.Id = prsAcnt1.Id;
                                            acc.OwnerId = usr1.Id;
                                            UpdateprsAccList.add(acc);
                                        }
                                        for(Order__c prsOrdList1: pNewOrders){
                                            Order__c ord = new Order__c();
                                            ord.Id = prsOrdList1.Id;
                                            ord.PrimarySalesRep__c = usr1.Id;
                                            ord.Combined_Region__c   = usr1.Combined_Region__c;
                                            ord.Position_Organization__c = usr1.Position_Organization__c;
                                            if(!prslogin.isEmpty() && LiveChannelFlag == true){
                                                if(SalesChannel != '') {
                                                      ord.SalesChannel__c = SalesChannel;
                                                    }
                                                  else
                                                  {
                                                      ord.SalesChannel__c = 'Partner';
                                                    }

                                            } else {
                                                system.debug('first default ECOMM');
                                                ord.SalesChannel__c = 'ECOMM';

                                            }
                                            if(PrsList.isEmpty()){
                                                system.debug('Non Partner');
                                                if(SalesChannel !=''){
                                                 ord.SalesChannel__c = SalesChannel;
                                                }
                                                else {
                                                    ord.SalesChannel__c = 'ECOMM';
                                              }
                                            }
                                            UpdateprsOrdList.add(ord);
                                        }
                                    }
                                }else{
                                    system.debug('salesrep4');
                                    if(Orgnization == 'North America')
                                    {
                                        userProfiles = [Select Id from Profile where Name= 'Sales Rep (NA)' limit 1];
                                    }
                                    if(Orgnization == 'Europe')
                                    {
                                        userProfiles = [Select Id from Profile where Name ='Sales Rep (EU)'  limit 1];
                                    }
                                    if(Orgnization == 'Asia Pacific')
                                    {
                                        userProfiles = [Select Id from Profile where Name= 'Sales Rep (APAC)'   limit 1];
                                    }
                                    for(Profile Prof: userProfiles)
                                    {
                                       ProfileId = Prof.Id;
                                    }
                                    List<User> userdefault = [Select Id,PositionSalesChannel__c,Position_Organization__c,Combined_Region__c from User where Country =: QuoteSellingCountry and IsActive = True and ProfileId=:ProfileId limit 1];
                                    system.debug('userdefault' + userdefault);
                                        for(User usrdef: userdefault){
                                            SalesChannel = usrdef.PositionSalesChannel__c;
                                            for(Account prsdefAcnt: ExistaccntList){
                                                Account acc = new Account();
                                                acc.Id = prsdefAcnt.Id;
                                                acc.OwnerId = usrdef.Id;
                                                UpdateprsAccList.add(acc);
                                            }
                                            for(Order__c prsdefOrdList: pNewOrders){
                                                Order__c ord = new Order__c();
                                                ord.Id = prsdefOrdList.Id;
                                                ord.PrimarySalesRep__c = usrdef.Id;
                                                ord.Combined_Region__c   = usrdef.Combined_Region__c;
                                                ord.Position_Organization__c = usrdef.Position_Organization__c;
                                                if(!prslogin.isEmpty() && LiveChannelFlag == true){
                                                    if(SalesChannel != '') {
                                                          ord.SalesChannel__c = SalesChannel;
                                                    }
                                                    else
                                                    {
                                                          ord.SalesChannel__c = 'Partner';
                                                     }

                                                } else {
                                                    system.debug('first default ECOMM');
                                                    ord.SalesChannel__c = 'ECOMM';
                                                }
                                                if(PrsList.isEmpty()){
                                                    system.debug('Non Partner');
                                                    if(SalesChannel !=''){
                                                     ord.SalesChannel__c = SalesChannel;
                                                    }
                                                    else {
                                                        ord.SalesChannel__c = 'ECOMM';
                                                    }
                                                }
                                                UpdateprsOrdList.add(ord);
                                            }
                                        }
                                    }
                            }

                            system.debug('UpdateprsAccList' + UpdateprsAccList);
                            //J Freese Appirio 4/15/16 I-211537  Disable triggers to prevent Too Many SOQL MAPP Exception
                            if (UpdateprsAccList.size() > 0){
                                AccountTriggerHandler.ExecuteTriggers = false;
                                update UpdateprsAccList;
                                AccountTriggerHandler.ExecuteTriggers = true;
                            }
                            system.debug('updateprsOrdList' + UpdateprsOrdList);
                            if (UpdateprsOrdList.size() > 0){
                                OrderTriggerHandler.ExecuteTriggers = false;
                                update UpdateprsOrdList;
                                OrderTriggerHandler.ExecuteTriggers = true;
                            }

                        }
                    }
                }
                else{
                    system.debug('salesrep5');
                    if(ExistOwner!='Integration MAPP'){
                        List<Order__c> UpdateExistOrdList = new List<Order__c>();
                        for(Account ownerAcntt: ExistaccntList){
                            ownerId = ownerAcntt.OwnerId;
                        }
                        List<User> existTAuser = [select PositionSalesChannel__c,Position_Organization__c,Combined_Region__c  from User where Id =: ownerId];
                        for(Account ExistAcntt: ExistaccntList){
                            for(User existTAusrdef: existTAuser ){
                                SalesChannel = existTAusrdef.PositionSalesChannel__c;
                                for(Order__c ExistOrdList: pNewOrders){
                                    if(ExistOrdList.Account__c == ExistAcntt.Id){
                                        Order__c ord = new Order__c();
                                        ord.Id = ExistOrdList.Id;
                                        ord.PrimarySalesRep__c = ExistAcntt.OwnerId;
                                        if(Shipcountry != QuoteSellingCountry ){
                                            ord.Position_Organization__c = 'ECOMM';
                                            ord.SalesChannel__c = 'ECOMM';
                                        }
                                        else{
                                            ord.Combined_Region__c   = existTAusrdef.Combined_Region__c;
                                            ord.Position_Organization__c = existTAusrdef.Position_Organization__c;
                                            /*if(!prslogin.isEmpty()){

                                              if(SalesChannel != '') {
                                                  ord.SalesChannel__c = SalesChannel;
                                                }
                                                else
                                                {
                                                  ord.SalesChannel__c = 'Partner';
                                                }

                                              } else {
                                                system.debug('first default ECOMM');
                                                ord.SalesChannel__c = 'ECOMM';

                                              }
                                              if(PrsList.isEmpty()){*/
                                                system.debug('Non Partner');
                                                if(SalesChannel !=''){
                                                 ord.SalesChannel__c = SalesChannel;
                                                }
                                                else {
                                                  ord.SalesChannel__c = 'ECOMM';
                                                }
                                              //}
                                        }
                                        system.debug('ExistOrdList.PrimarySalesRep__c' + ExistOrdList.PrimarySalesRep__c);
                                        UpdateExistOrdList.add(ord);
                                    }
                                }
                            }
                        }

                        //J Freese Appirio 4/15/16 I-211537  Disable triggers to prevent Too Many SOQL MAPP Exception
                        if (UpdateExistOrdList.size() > 0){
                            OrderTriggerHandler.ExecuteTriggers = false;
                            update UpdateExistOrdList;
                            OrderTriggerHandler.ExecuteTriggers = true;
                        }
                    }

                    else{
                        system.debug('salesrep6');
                        List<Account> UpdateAccList = new List<Account>();
                        List<Order__c> UpdateOrdList = new List<Order__c>();
                       /* if(Orgnization == 'North America')
                        {
                            userProfiles = [Select Id from Profile where Name= 'Sales Rep (NA)' limit 1];
                        }
                        if(Orgnization == 'Europe')
                        {
                            userProfiles = [Select Id from Profile where Name ='Sales Rep (EU)'  limit 1];
                        }
                        if(Orgnization == 'Asia Pacific')
                        {
                            userProfiles = [Select Id from Profile where Name= 'Sales Rep (APAC)'   limit 1];
                        }
                        for(Profile Prof: userProfiles)
                        {
                           ProfileId = Prof.Id;
                        }*/
                        /*List<User> userdefault1 = [Select Id from User where Country =: QuoteSellingCountry and IsActive = True and ProfileId=:ProfileId limit 1];*/
                        //List<User> userdefault1 = [Select Id,PositionSalesChannel__c,Position_Organization__c,Combined_Region__c from User where Country =: QuoteSellingCountry and IsActive = True and ProfileId=:ProfileId limit 1];
                        string aliasname = Utility.GetMappPrimarySalesRep(QuoteSellingCountry);
                        List<User> userdefault1 = [Select Id,PositionSalesChannel__c,Position_Organization__c,Combined_Region__c from User where alias =: aliasname  limit 1];
                        system.debug('testuserdefault1' + userdefault1);
                        for(User usrdef1: userdefault1){
                            SalesChannel = usrdef1.PositionSalesChannel__c;
                             for(Account defAcnt: ExistaccntList){
                                 Account acc = new Account();
                                 acc.Id = defAcnt.Id;
                                 acc.OwnerId = usrdef1.Id;
                                 system.debug('testusrdef1.Id' + usrdef1.Id);
                                 system.debug('testacc.OwnerId' + acc.OwnerId);
                                 UpdateAccList.add(acc);
                              }
                             for(Order__c defOrdList: pNewOrders){
                                Order__c ord = new Order__c();
                                ord.Id = defOrdList.Id;
                                ord.PrimarySalesRep__c = usrdef1.Id;
                                ord.Combined_Region__c   = usrdef1.Combined_Region__c;
                                ord.Position_Organization__c = usrdef1.Position_Organization__c;
                               /* if(!prslogin.isEmpty() && LiveChannelFlag == true){
                                  if(SalesChannel != '') {
                                      ord.SalesChannel__c = SalesChannel;
                                    }
                                    else
                                    {
                                      ord.SalesChannel__c = 'Partner';
                                    }

                                    }
                                    else {
                                    system.debug('first default ECOMM');
                                    ord.SalesChannel__c = 'ECOMM';
                                    }
                                    if(PrsList.isEmpty()){*/
                                      system.debug('Non Partner');
                                      if(SalesChannel !=''){
                                       ord.SalesChannel__c = SalesChannel;
                                      }
                                      else {
                                        ord.SalesChannel__c = 'ECOMM';
                                      }
                                    //}
                                UpdateOrdList.add(ord);
                            }
                        }

                        //J Freese Appirio 4/15/16 I-211537  Disable triggers to prevent Too Many SOQL MAPP Exception
                        system.debug('UpdateAccList' + UpdateAccList);
                        if (UpdateAccList.size() > 0){
                            AccountTriggerHandler.ExecuteTriggers = false;
                            update UpdateAccList;
                            AccountTriggerHandler.ExecuteTriggers = true;
                        }
                        system.debug('UpdateOrdList' + UpdateOrdList);
                        if (UpdateOrdList.size() > 0){
                            OrderTriggerHandler.ExecuteTriggers = false;
                            update UpdateOrdList;
                            OrderTriggerHandler.ExecuteTriggers = true;
                        }
                    }
                }
            //}commented out else
        } catch(Exception bae){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Failed to update PrimarySalesRep. Please see system log for details.', bae);
        }

    }

/*
** @author : Adarsh
** @date : 10/08/2015
** @story :
** @Issue : S-334604 & I-204120
** @description : Populate Payment Details info and Site channel
** @paramaters : list of Orders
** @returns : nothing
*/
    public void PopulatePaymentDetailsInfo(Order__c [] pNewOrders){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','PopulatePaymentDetailsInfo');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
       //try{
            system.debug('pNewOrders' + pNewOrders);
            Set<Id> newOrdId = new Set<Id>();
            Set<Id> newAccId = new Set<Id>();
            Set<Id> newAccountId = new Set<Id>();
            Set<String> OrdSiteIds = new Set<String>();
            Set<String> partnernames = new Set<String>();
            String OwnerName;
            //String SalesChannel;
            String CombinedRegion;
            String PosOrg;
            Boolean LiveChannelFlag;
            //String PartnerFlag;
            String paymentFreq ='Single Payment';
            for(Order__c newOrder: pNewOrders){
                newOrdId.add(newOrder.Id);
                newAccId.add(newOrder.Account__c);
                system.debug('newOrdId'+ newOrdId);
                OrdSiteIds.add(newOrder.SiteChannelID__c);
            }
            List<Partner_Revenue_Share__c> PrsList = queryPartnerRevenueShare();
            if(!PrsList.isEmpty()){
                for(Partner_Revenue_Share__c Prs: PrsList){
                    if(OrdSiteIds.contains(Prs.SiteChannelID__c)){
                       partnernames.add(Prs.Partner__c);
                    }
                    LiveChannelFlag = Prs.MB_Live_Channel_Flag__c;
                }
            }
            system.debug('partnernames' + partnernames);
            /*List<Order__c> newOrdList= [select Id, PrimarySalesRep__c from Order__c where Id in :newOrdId];
      for(Order__c newOrderList: newOrdList){
                newAccountId.add(newOrderList.Account__c);
        OwnerName= newOrderList.PrimarySalesRep__c;
        system.debug('OwnerName' + OwnerName);
            }*/
            List<Account> accntList = [select Id from Account where Id in :partnernames OR Id in : newAccId];
            //Updating This to use the new query Framework
            //List<Account> AccList = [SELECT Id,Suppress_Invoice_Detail__c from Account WHERE Id in: newAccId ];
            List<Account> AccList = new List<Account>();
            for(Account a : queryAccountList()){
                if(newAccId.contains(a.Id)){
                    AccList.add(a);
                OwnerName= a.Owner.Name;
                    system.debug('OwnerName' + OwnerName);
                }
            }
            system.debug('AccList' + AccList);
      /* AP List<User> userList = [select PositionSalesChannel__c,Position_Organization__c,Combined_Region__c  from User where Name =: OwnerName];
        for(User u: userList){
        SalesChannel = u.PositionSalesChannel__c;
        CombinedRegion = u.Combined_Region__c;
        PosOrg = u.Position_Organization__c;
                system.debug('SalesChannel' + SalesChannel);
      } AP */
            List<Order__c> OrderList = pNewOrders;
            List<Order__c> UpdateOrdList = new List<Order__c>();
            for(Order__c ord: OrderList){
                Order__c ordln = new Order__c(Id = ord.Id);
                system.debug('ord org '+ord.Organization__c);
                //I-211622 Jonathan Freese Appirio - set order status updates first
                if(ord.MAPP_Payment_Frequency__c== 'Pre-Paid'){ordln.OrderStatus__c = 'Paid in Full';}
                else if(ord.MAPP_Payment_Frequency__c== 'EU Pre-Paid'){ordln.OrderStatus__c = 'Sent to Verification';}

                //I-211622 Adarsh P - set Partner payment terms
                if(!PrsList.isEmpty() && LiveChannelFlag == true ){
                    ordln.Payment_Method_text__c = 'Partner';
                    ordln.Payment_Term_text__c = 'Immediate';
                    ordln.Payment_Frequency__c= 'Single Payment';
                    ordln.Installments__c = 1;
                }
                else{
                    //if(ord.MAPP_Payment_Frequency__c== 'PayPal (Ecomm only)'){//I-219918
                      //  ordln.Payment_Method_text__c = 'PayPal (Ecomm only)';
                    if(ord.MAPP_Payment_Frequency__c== 'Paypal'){
                        ordln.Payment_Method_text__c = 'PayPal';
                        ordln.Payment_Term_text__c = 'Net 30';
                        ordln.Payment_Frequency__c= paymentFreq;
                    }
                    if(ord.MAPP_Payment_Frequency__c== 'Invoice'){
                        ordln.Payment_Method_text__c = 'Invoice';
                        ordln.Payment_Term_text__c = 'Net 30';
                        ordln.Payment_Frequency__c= paymentFreq;
                    }
                    if(ord.MAPP_Payment_Frequency__c== 'Pre-Paid'){
                        ordln.Payment_Method_text__c = 'Credit Card';
                        ordln.Payment_Term_text__c = 'Immediate';
                        ordln.Payment_Frequency__c= paymentFreq;
                    }
                    if(ord.MAPP_Payment_Frequency__c== 'Zero Value'){
                        ordln.Payment_Method_text__c = 'Invoice';
                        ordln.Payment_Term_text__c = 'Immediate';
                        if (ord.Organization__c == 'Europe') {  // JA - Added if condition for I-219035
                            paymentFreq ='Single Invoice';
                        }
                        ordln.Payment_Frequency__c= paymentFreq;
                    }
                    if(ord.MAPP_Payment_Frequency__c== 'EU Pre-Paid'){
                        ordln.Payment_Method_text__c = 'Credit Card';
                        ordln.Payment_Term_text__c = 'Immediate';
                        ordln.Payment_Frequency__c= 'Pre-Paid';
                    }
                    if(ord.MAPP_Payment_Frequency__c== 'EU Net 15'){
                        ordln.Payment_Method_text__c = 'Invoice';
                        ordln.Payment_Term_text__c = 'Net 15';
                        ordln.Payment_Frequency__c= 'Single Invoice';
                    }
                    if(ord.MAPP_Payment_Frequency__c== 'EU Net 20'){
                        ordln.Payment_Method_text__c = 'Invoice';
                        ordln.Payment_Term_text__c = 'Net 20';
                        ordln.Payment_Frequency__c= 'Single Invoice';
                    }
                    if(ord.MAPP_Payment_Frequency__c== 'EU Net 30'){
                        ordln.Payment_Method_text__c = 'Invoice';
                        ordln.Payment_Term_text__c = 'Net 30';
                        ordln.Payment_Frequency__c= 'Single Invoice';
                    }
                    if(ord.MAPP_Payment_Frequency__c== 'EU Net 45'){
                        ordln.Payment_Method_text__c = 'Invoice';
                        ordln.Payment_Term_text__c = 'Net 45';
                        ordln.Payment_Frequency__c= 'Single Invoice';
                    }
                }
                 for(Account accln: AccList){
                    system.debug('accln' + accln);
                    system.debug('acclnsuppress' + accln.Suppress_Invoice_Detail__c);
                    if(accln.Suppress_Invoice_Detail__c != null){
                        system.debug('insideif');
                        ordln.Suppress_Invoice_Detail__c = accln.Suppress_Invoice_Detail__c;
                    }
                    else
                    {
                        system.debug('else');
                        ordln.Suppress_Invoice_Detail__c = 'Suppress Unit Price and Net Total Detail';
                    }
                }
                /*ordln.BillingStartDt__c = ord.OrderDate__c;*/
                if(ord.Organization__c == 'North America' && ord.MAPP_Payment_Frequency__c != 'Pre-Paid')//I-219912
                {
                    system.debug('paymentMethod verify runs');
                    //ordln.OrderStatus__c = 'Verified';
                    ordln.ICS_OrderStatus__c = 'Verified';//AP S-445901

                }
                /*Code for I-230995, by Deepanshu Soni Appirio, starts*/
                if(ord.Organization__c == 'North America' && ord.CreditCardTransactionResponseCode__c != null)
                 {
                    //ordln.OrderStatus__c = 'Paid in Full';
                    ordln.ICS_OrderStatus__c = 'Paid in Full';//AP S-445901
                    ordln.Payment_Method_text__c = 'Credit Card';
                    ordln.Payment_Term_text__c = 'Immediate';
                    ordln.Payment_Frequency__c= 'Single Payment';
                    ordln.Installments__c = 1 ;
                 }
                 /*Code for I-230995, by Deepanshu Soni Appirio, ends*/
                 /*Code for I-235067, by Deepanshu Soni Appirio, starts*/
                 /*if(ord.Organization__c == 'North America' && ord.CreditCardTransactionResponseCode__c != null && ord.MAPP_Payment_Frequency__c == 'Paypal'){
                    ordln.OrderStatus__c = 'Paid in Full';
                    ordln.Payment_Method_text__c = 'Paypal';
                    ordln.Payment_Term_text__c = 'Immediate';
                    ordln.Payment_Frequency__c= 'Single Payment';
                    ordln.Installments__c = 1 ;
                    ordln.MAPP_Archive_Credit_Card_Type__c = ' PayPal';

                 }*///moved code to populatepayGoOrders method for S-446033
                 /*Code for I-235067, by Deepanshu Soni Appirio, ends*/
                /* AP if(!partnernames.isEmpty() && LiveChannelFlag == true){

                    if(SalesChannel != '') {
                          ordln.SalesChannel__c = SalesChannel;
                        }
                      else
                      {
                          ordln.SalesChannel__c = 'Partner';
                        }

                    } else {
                        system.debug('first default ECOMM');
                        ordln.SalesChannel__c = 'ECOMM';

                    }
                    if(PrsList.isEmpty()){
                        system.debug('Non Partner');
                        if(SalesChannel !=''){
                         ordln.SalesChannel__c = SalesChannel;
                        }
                        else {
                            ordln.SalesChannel__c = 'ECOMM';
                      }
                    }
                    ordln.Combined_Region__c   = CombinedRegion;
                    ordln.Position_Organization__c = PosOrg;  AP*/
                UpdateOrdList.add(ordln);

                system.debug('ordSTATUS '+ordln.OrderStatus__c);
                system.debug('Values' + ordln.Payment_Method_text__c );
                system.debug('Term'+ ordln.Payment_Term_text__c);
                system.debug('Freqq' + ordln.Payment_Frequency__c);
            }
             if(!UpdateOrdList.isEmpty())
             {

                system.debug('UpdateStarting');
                OrderTriggerHandler.RunValidCalculation  = true;
                OrderTriggerHandler.ForceOpportunityUpdates = true;
                update UpdateOrdList;
                OrderTriggerHandler.ForceOpportunityUpdates = false;
                OrderTriggerHandler.RunValidCalculation  = true;

             }

       // }catch(Exception bae){
          //  throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Failed to update PopulatePaymentDetailsInfo. Please see system log for details.', bae);
       // }
    }

      // Added by Vivek Ojha for T-434704
      // Moved to Helper class by Jeff L. 10/19/2015
      // Description : Create Opportunity when Order is created through integration.
    public void createOpportunity(List<Order__c> newOrders){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','CreateOpportunity');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        List<Opportunity> optyLst = new List<Opportunity>();
        List<Order__c> ordLst = new List<Order__c>();
        set<Id> accIds = new set<Id>();
        Integer counter = 0;
        list<Account> lstAccountsToUpdate = new list<Account>();
        for(Order__c ord : newOrders){
            accIds.add(ord.Account__c);
        }
        //Jeff L commented out in favor of new query framework
        // Map<Id,Account> accMap = new MAp<Id,Account>([Select Id, Name, CustomerLapsedDate__c, createdDate, AccountStatus__c,OwnerId, Organization__c, BillingCountry FROM Account Where Id IN : accIds]);
        Map<Id,Account> accMap = new Map<Id,Account>();
        for(Account a : queryAccountList()){
            if(accIds.contains(a.Id)){
                accMap.put(a.Id,a);
            }
        }
        for(Order__c ord : newOrders){
            Account currAcc = accMap.get(ord.Account__c);
            //I219915 - removed checks for account status, we normally want to always
            //be creating opportunities for these MAPP orders
            //if(ord.Promotions__c != null){

                Opportunity opty = new Opportunity();
                opty.StageName ='Stage 5 - Verified by Finance';
                system.debug('orderstatustoday' + ord.OrderStatus__c);
                if(ord.OrderStatus__c == 'Verified' || ord.OrderStatus__c =='Paid in Full' || ord.OrderStatus__c =='Invoiced' ){//S-444964
                    opty.StageName ='Stage 5 - Verified by Finance';
                }else if(ord.OrderStatus__c == 'Pending Processing'){
                    opty.StageName ='Stage 4 - Won';
                }
                opty.Amount = ord.Order_item_Sales_Credit_Total__c;
                opty.OwnerId = currAcc.OwnerId;
                opty.CloseDate = Date.today();
                if(currAcc.Lead_Account_Status__c == 'Inactive'){
                    currAcc.Lead_Account_Status__c  = 'Active';
                    lstAccountsToUpdate .add(currAcc);
                }
                opty.AccountId = ord.Account__c;
                String AccountName = currAcc.Name;
                if(AccountName.length()>88)
                {
                    opty.Name =String.valueOf(currAcc.Name).substring(0, 86)+ '_OpportunityID To Be Populated' ;//S-449207
                }
                else
                {
                    opty.Name = currAcc.Name + '_OpportunityID To Be Populated' ; //this will ensure the name gets updated by opp naming workflow
                }
                opty.Organization__c = currAcc.Organization__c;
                opty.AccountCountry__c = currAcc.BillingCountry;
                opty.OrderCreated__c = true; //
                opty.CurrencyIsoCode = ord.CurrencyIsoCode;

                if(System.now().date().format()==currAcc.CreatedDate.date().format()|| currAcc.AccountStatus__c == 'Candidate'){
                    opty.OpportunityType__c = 'New Customer';
                    opty.ForecastCategoryName = 'Commit';
                }else if(currAcc.CustomerLapsedDate__c != null && ord.OrderDate__c > (currAcc.CustomerLapsedDate__c).addDays(365)){
                    opty.OpportunityType__c ='Winback';
                }else{
                    opty.OpportunityType__c ='Renewal';
                }
                optyLst.add(opty);
                ordLst.add(ord);
                System.debug('optyLst=='+optyLst);
            //}
        }
        if(!optyLst.isEmpty()){
            system.debug('lstAccountsToUpdate' + lstAccountsToUpdate);
            if(lstAccountsToUpdate .size()>0)
                update lstAccountsToUpdate ;

            insert optyLst;
        }
        for(Order__c ord : ordLst){
            ord.Opportunity__c =  optyLst[counter].Id;
            System.debug('----oppty OWNER ' + optyLst[counter].ownerId);
            counter++;
        }


        System.debug('== Out createOpportunity =='+optyLst+'==ordLst=='+ordLst);
    }


    /*
    ** @author : Appirio Inc (Jonathan F) S-456572
    ** @date : 02/28/2017
    ** @description : Create forcasting opportunity for credit order
    ** @paramaters : list of just verified credit orders
    ** @returns : nothing
    */
    public void createCreditOpportunity(List<Order__c> newOrders){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','CreateCreditOpportunity');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        OrderTriggerHandler.CreatingCreditOpportunity = true; //use to control downstream flow that would otherwise overwrite the owner
        Map<Id,Id> PPC_ParentOppOwner = new Map<Id,Id>();
        List<Opportunity> optyLst = new List<Opportunity>();
        List<Order__c> ordLst = new List<Order__c>();
        List<Order__c> parentInfo = new List<Order__c>();
        set<Id> accIds = new set<Id>();
        Integer counter = 0;
        list<Account> lstAccountsToUpdate = new list<Account>();
        for(Order__c ord : newOrders){
            accIds.add(ord.Account__c);
        }

        Map<Id,Account> accMap = new Map<Id,Account>();
        for(Account a : queryAccountList()){
            if(accIds.contains(a.Id)){
                accMap.put(a.Id,a);
            }
        }

        String dbg='';
        for(order__c o : [SELECT id, ParentOrder__c, ParentOrder__r.Opportunity__c, ParentOrder__r.Opportunity__r.ownerId,
                             ParentOrder__r.Opportunity__r.owner.UserRoleId, ParentOrder__r.Opportunity__r.owner.UserRole.name
                             FROM order__c WHERE id IN: newOrders]){
            dbg = 'Original Opportunity owner role: ParentOrder__c='+o.ParentOrder__c + ', ';
            dbg += 'ParentOrder__r.Opportunity__c='+o.ParentOrder__r.Opportunity__c + ',\n';
            dbg += 'ParentOrder__r.Opportunity__r.ownerId='+o.ParentOrder__r.Opportunity__r.ownerId + ', ';
            dbg += 'ParentOrder__r.Opportunity__r.owner.UserRole.name='+o.ParentOrder__r.Opportunity__r.owner.UserRole.name;
            system.debug(dbg);
            if(o.ParentOrder__r.Opportunity__r.owner.UserRole.name.containsIgnoreCase('PPC')){
                PPC_ParentOppOwner.put(o.id,o.ParentOrder__r.Opportunity__r.ownerId);
            }
        }
        system.debug('PPC_ParentOppOwner: '+PPC_ParentOppOwner);

        for(Order__c ord : newOrders){
            Account currAcc = accMap.get(ord.Account__c);
            Opportunity opty = new Opportunity();
            opty.StageName ='Stage 5 - Verified by Finance';

            /*opty.Amount = ord.GrossCreditAmount__c * -1;
              Cannot do this here or it will get overwritten by the opportunity line items total value.
              Instead set the quantity and total of each opp line line item to negative in
              OrderLineItemTriggerHelper.syncLineItemsWithOpportunityLineItems*/

            if (PPC_ParentOppOwner.containsKey(ord.Id)){
                system.debug('^^^Original Opportunity owner is a PPC user, so set new opportunity owner to the same user');
                opty.OwnerId = PPC_ParentOppOwner.get(ord.Id);
            }
            else{
                system.debug('^^^Original Opportunity owner is not a PPC user, so set new opportunity owner to the account owner');
                opty.OwnerId = currAcc.OwnerId;
            }

            /*Not specified in the AC*/
            //Id oppLockedRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Opportunity Locked').getRecordTypeId();
            //opty.RecordTypeId = oppLockedRecordTypeId;

            OrderTriggerHandler.ProcessingCreditRequest = true;  //Mitali N Appirio T-600146 8/5/17
            opty.CloseDate = Date.Today();  //AC say to use Verified Date on credit order but that is not set yet
            opty.ForecastCategoryName = 'Closed';
            opty.AccountId = ord.Account__c;
            String AccountName = currAcc.Name;
            if(AccountName.length()>88)
            {
                opty.Name =String.valueOf(currAcc.Name).substring(0, 86)+ '_OpportunityID To Be Populated' ;//S-449207
            }
            else
            {
                opty.Name = currAcc.Name + '_OpportunityID To Be Populated' ; //this will ensure the name gets updated by opp naming workflow
            }
            opty.Organization__c = currAcc.Organization__c;
            opty.AccountCountry__c = currAcc.BillingCountry;
            opty.OrderCreated__c = true; //
            opty.CurrencyIsoCode = ord.CurrencyIsoCode;
            //SBerron - S-473201 - 03/14/17
            opty.InternationalDeal__c = ord.International_Deal__c;

            optyLst.add(opty);
            ordLst.add(ord);
            System.debug('optyLst=='+optyLst);
        }
        if(!optyLst.isEmpty()){
            system.debug('lstAccountsToUpdate' + lstAccountsToUpdate);
            if(lstAccountsToUpdate .size()>0)
                update lstAccountsToUpdate ;

            insert optyLst;
        }
        for(Order__c ord : ordLst){
            ord.Opportunity__c =  optyLst[counter].Id;
            System.debug('----oppty OWNER ' + optyLst[counter].ownerId);
            counter++;
        }
        System.debug('== Out createCreditOpportunity =='+optyLst+'==ordLst=='+ordLst);

        if(CreditRequestTriggerHandler.CreateOrdersAutomatically != true){
            system.debug('^^^Done with createCreditOpportunity() because CreditRequestTriggerHandler.CreateOrdersAutomatically='+CreditRequestTriggerHandler.CreateOrdersAutomatically);
            return;
        }
        /********************************************************************************************************
         ********************************************************************************************************
           If this method was called from CreditRequestTriggerHelper.AsyncAutoCreateCreditOpportunity(),
           rather than from the OrderTriggerHandler.OnBeforeUpdate block, the the order will not be updated.
           So we need to:
               1) update the credit order to set the new opportunity
               2) synch the credit order OLI back to the new opportunity
         ********************************************************************************************************
         ********************************************************************************************************/
        system.debug('^^^Continuing to process the credit order(s) because CreditRequestTriggerHandler.CreateOrdersAutomatically='+CreditRequestTriggerHandler.CreateOrdersAutomatically);
        if(!ordLst.isEmpty()){
            //1) update the credit order to set the new opportunity
            List<Order__c> ordersToUpdate = new List<Order__c>();
            for(Order__c o : ordLst){
                Order__c newOrder = new Order__c();
                newOrder.Id = o.Id;
                newOrder.Opportunity__c = o.Opportunity__c;
                ordersToUpdate.add(newOrder);
            }
            OrderTriggerHandler.executeUpdateTrigger = false;
            system.debug('^^^Updating the credit order(s) to set the new opportunity');
            update ordersToUpdate;
            OrderTriggerHandler.executeUpdateTrigger = true;

            //New context; order update found runCount==0 and set OrderTriggerHandler.CreatingCreditOpportunity to false
            OrderTriggerHandler.CreatingCreditOpportunity = true; //use to control downstream flow

            //2) synch the credit order OLI back to the new opportunity
            system.debug('^^^Checking for order line items on the credit order to synch to the new credit opportunity');
            //query taken from OrderLineItemTriggerHelper.syncLineItemsWithOpportunityLineItems
/*            list<Order_Line_Item__c> orderLineItems = [SELECT Id, ProposalLineItem__c ,
                                                            Product__c,
                                                            Sales_credit__c ,
                                                            GrossTotalAmount__c ,
                                                            NetTotalAmount__c ,
                                                            NetUnitPrice__c,
                                                            Organisation__c,
                                                            Product__r.ProductCode,
                                                            LineType__c,
                                                            OptionId__c,
                                                            ProposalLineItem__r.Apttus_Proposal__Product__c ,
                                                            ProposalLineItem__r.Gross_Total__c,
                                                            ProposalLineItem__r.Quantity1__c ,
                                                            //ProposalLineItem__r.Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__c  ,
                                                            Quantity2__c ,
                                                            Order__r.OrderStatus__c,
                                                            Order__r.Opportunity__c ,
                                                            Order__r.Opportunity__r.CurrencyIsoCode,
                                                            Order__r.Opportunity__r.Organization__c
                                                            //ProposalLineItem__r.Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__r.CurrencyIsoCode
                                                            FROM Order_Line_Item__c
                                                            WHERE Order__c IN : ordersToUpdate
                                                            //AND ProposalLineItem__c != null
                                                            AND (Product__c != null OR ProposalLineItem__r.Apttus_Proposal__Product__c != Null)
                                                            AND order__r.Opportunity__c != null];

            Map<id ,Order_Line_Item__c> mapOrderLineItems = new Map<id ,Order_Line_Item__c>();
            for(Order_Line_Item__c oli : orderLineItems){mapOrderLineItems.put(oli.Id,oli);}
            if (orderLineItems.size() > 0){
                OrderLineItemTriggerHelper OLIT_Helper = OrderLineItemTriggerHelper.NewTriggerHelper('');
                OLIT_helper.OrderLineItemList = orderLineItems;
                OLIT_helper.ResetQueries();
                system.debug('^^^Synching credit order line items with the new credit opportunity');
                OLIT_helper.syncLineItemsWithOpportunityLineItems(orderLineItems,mapOrderLineItems);
            }*/

            //query taken from OrderLineItemTriggerHelper.syncLineItemsWithOpportunityLineItems
            list<Order_Line_Item__c> orderLineItems = [SELECT Id FROM Order_Line_Item__c
                                                            WHERE Order__c IN : ordersToUpdate
                                                            AND (Product__c != null OR ProposalLineItem__r.Apttus_Proposal__Product__c != Null)
                                                            AND order__r.Opportunity__c != null];
            if (orderLineItems.size() > 0){
                update orderLineItems;
            }
        }
    }


    /*
    ** @author : Appirio Inc
    ** @date : 10/09/2015
    ** @description : method used to update opportunity, calls a private class to handle bypassing the sharing
    */
    public void updateOppRollUps(List<Order__c> pOrderList){
               SkipSharingMethods ssm = new SkipSharingMethods();
        ssm.updateOppRollUps(pOrderList);
    }

/*
** @author : Appirio Inc
** @date : 10/09/2015
** @description : private class without sharing for methods that need to skip sharing
*/
    private without sharing class SkipSharingMethods {

        private SkipSharingMethods(){

        }

        /*
        ** @author : Appirio Inc
        ** @date : 10/09/2015
        ** @description : method to update a number of fields on the opportunity when the Order reaches a certain stage
        */
        public void updateOppRollUps(List<Order__c> pOrderList) {

            Set<Id> setOppIdsToUpdate = new Set<Id>();
            Map<Id, List<Order__c>> mapOppIdToListOrder = new Map<Id, List<Order__c>>();
            List<Opportunity> listOppToUpdate = new List<Opportunity>();
            for(Order__c o : pOrderList) {
                if(o.Opportunity__c != null){
                    setOppIdsToUpdate.add(o.Opportunity__c);
                }
            }

            system.debug('=====setOppIdsToUpdate===' + setOppIdsToUpdate);
            for(Order__c od : [SELECT Id, GrossTotalAmount__c, GrossTotalAmountWithTax__c, Opportunity__c
                            FROM Order__c
                            WHERE Opportunity__c IN : setOppIdsToUpdate]) {

                if(!mapOppIdToListOrder.containsKey(od.Opportunity__c)) {
                    mapOppIdToListOrder.put(od.Opportunity__c, new List<Order__c>());
                }
                mapOppIdToListOrder.get(od.Opportunity__c).add(od);
            }
            system.debug('=====mapOppIdToListOrder===' + mapOppIdToListOrder);

            for(Id oppId : mapOppIdToListOrder.keyset()) {
                if(oppId != null){
                    Decimal totalGrossAmt = 0;
                    Decimal totalGrossAmtWithTax = 0;
                    for(Order__c odr : mapOppIdToListOrder.get(oppId)) {
                        totalGrossAmt += odr.GrossTotalAmount__c;
                        totalGrossAmtWithTax += odr.GrossTotalAmountWithTax__c;
                    }

                    Opportunity opp = new Opportunity();
                    boolean isUpdated = false;
                    opp.Id = oppId;
                    /* We will only update oppty if GrossTotalAmount__c and GrossTotalAmountWithTax__c is changed
                       Added By Vikas Menon on 15 March, 2017 (S-472018)
                    */
                    if(opp.GrossTotalAmount__c != totalGrossAmt){
                        opp.GrossTotalAmount__c = totalGrossAmt;
                        isUpdated = true;
                    }
                    if(opp.GrossTotalAmountWithTax__c != totalGrossAmtWithTax){
                        opp.GrossTotalAmountWithTax__c = totalGrossAmtWithTax;
                        isUpdated = true;
                    }
                    if(isUpdated){
                        listOppToUpdate.add(opp);
                    }
                }

                system.debug('=====listOppToUpdate===' + listOppToUpdate);

            }
            if(listOppToUpdate.size() > 0){
                update listOppToUpdate;
            }
        }
    }


   /*
** @author : Adarsh
** @date : 02/04/2016
** @story :
** @Issue : I-194400
** @description : Populate Agency Fields on Order
** @paramaters : list of Orders
** @returns : nothing
*/
    public void PopulateEcommAgencyInfo(Order__c [] pNewOrders){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','PopulateEcommAgencyInfo');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
         set<Id> OrdAcctIdsSet = new Set<Id>();
         set<String> OrdSiteId = new set<String>();
         set<String> prslogin = new set<String>();
         String CustNum;
         Boolean LiveChannelFlag;
         try{
                for(Order__c ord : pNewOrders){
                    OrdAcctIdsSet.add(ord.Account__c);
                    OrdSiteId.add(ord.SiteChannelID__c);
                }
                //List<Account> accntList = [select Id, BillingStreet, BillingState, BillingPostalCode, BillingCountry, BillingCity from account where Id in: OrdAcctIdsSet];
                String AccountId;
                system.debug('OrdAcctIdsSet' + OrdAcctIdsSet);
                //List<Partner_Revenue_Share__c> PrsList = [select SiteChannelID__c, Partner__c from Partner_Revenue_Share__c where SiteChannelID__c in: OrdSiteId limit 1];
                List<Partner_Revenue_Share__c> PrsList = queryPartnerRevenueShare();
                    if(!PrsList.isEmpty()){
                        for(Partner_Revenue_Share__c Prs: PrsList){
                            If(OrdSiteId.contains(Prs.SiteChannelID__c)){
                                prslogin.add(Prs.Partner__c);
                            }
                            LiveChannelFlag = Prs.MB_Live_Channel_Flag__c;
                            /* Jeff L commented out 4/4/16 - this causes the Agency Discount to be doubled up
                            for(Order__c OrdL: pNewOrders){
                                OrdL.AgencyCommission__c =Prs.RevenueShare__c;
                            }*/
                        }
                        //if(LiveChannelFlag == true){//AP I-215362
                            List<Account> PartaccntList = [select CustomerNumber__c,Discount__c,PrimaryBillingContact__c, RegistrationNumber__c,
                                                                  BillingStreet, BillingState, BillingPostalCode, BillingCountry, BillingCity
                                                                  from Account where Id in: prslogin limit 1];
                            system.debug('PartaccntList' + PartaccntList);
                            for(Account Acnt: PartaccntList){
                                   system.debug('PrimaryBillingContact__c'+Acnt.PrimaryBillingContact__c);
                                   AccountId = Acnt.Id;
                                   AccountId =AccountId.substring(0,15);
                                   CustNum = Acnt.CustomerNumber__c;
                                   system.debug('AccountId' + AccountId);
                                   for(Order__c OrdList: pNewOrders){
                                        OrdList.Agency__c = Acnt.Id;
                                        if(CustNum != null){
                                            OrdList.AgencyIO__c = CustNum;
                                            OrdList.Local_Agency_Cust__c = CustNum;
                                        }
                                        else
                                        {OrdList.AgencyIO__c = 'Non-Agency';}
                                        OrdList.Agency_Billing_Street_Address__c = Acnt.BillingStreet;
                                        OrdList.Agency_Billing_State_Province__c = Acnt.BillingState;
                                        OrdList.Agency_Billing_Country__c = Acnt.BillingCountry;
                                        OrdList.Agency_Billing_Zip__c = Acnt.BillingPostalCode;
                                        OrdList.Agency_Billing_City__c = Acnt.BillingCity;
                                        OrdList.Agency_Billing_City_State_Zip__c = Acnt.BillingCity +' '+Acnt.BillingState +' '+Acnt.BillingPostalCode;
                                        OrdList.Agency_Billing_City_State__c = Acnt.BillingCity +' '+Acnt.BillingState;
                                        OrdList.AgencyBillingContact__c = Acnt.PrimaryBillingContact__c;
                                        //J Freese Appirio 4/13/16 I-194400
                                        OrdList.AgencyReg__c = Acnt.RegistrationNumber__c;

                                   }
                               }
                        }
                //AP}
                /*List<Contact> ConList = [SELECT Id FROM contact WHERE Account_ID_Text__c =: AccountId and PrimaryBillingContact__c =: true limit 1];
                for(Contact con: ConList){
                       for(Order__c OrdLi: pNewOrders){
                            OrdLi.AgencyBillingContact__c  = con.Id;
                       }
                }*/
            }

         catch(Exception e){
            system.debug('errored');
            ExceptionLog.add('Exception', 'OrderTriggerHelper', 'PopulateEcommAgencyInfo', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to populate Agency Info on Order.' ,e);
        }
}

    /*
    ** @author : Adarsh
    ** @date : 02/17/2016
    ** @story :
    ** @Issue : I-193348
    ** @description : Populate Xcode Field on Order
    ** @paramaters : list of Orders
    ** @returns : nothing
    */
    public void updateOrderXcode(Order__c[] pOrder){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateOrderXcode');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            Set<String> xcodeIds = new Set<String>();
            Set<Id> OrdAcctIdsSet = new Set<Id>();
            for(Order__c ord : pOrder){
                OrdAcctIdsSet.add(ord.Account__c);
            }
            //Jeff L commented out for new query framework 2/22/16
            //List<Account> accList = [select Primary_Xcode__c from account where Id in: OrdAcctIdsSet];
            List<Account> accList = new List<Account>();
            for(Account a : queryAccountList()){
                if(OrdAcctIdsSet.contains(a.Id)){
                    accList.add(a);
                }
            }
            for(Account acc : accList){
                xcodeIds.add(acc.Primary_Xcode__c);
                system.debug('xcodeIds' + xcodeIds);
            }
            List<Xcode__c> xcodeList = [select Id from Xcode__c where Name in: xcodeIds];
            system.debug('xcodeList' + xcodeList);
            for(Xcode__c xcodl : xcodeList){
                for(Order__c ordlist : pOrder ){
                 system.debug('xcodl.Id' +xcodl.Id);
                 ordlist.Xcode__c = xcodl.Id;
                }
            }
        }
        catch(Exception bae){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Failed to update Xcode on order. Please see system log for details.', bae);
        }
    }


///*
//    ** @author : Sylvester Agyen (Appirio)
//    ** @date : 03/14/2016
//    ** @description : Set Rebill Order line item start and end dates to orginal order's line item start and end dates
//    ** @paramaters : List of Orders
//*/
//    public void setRebillOrderDates(List<Order__c> newOrders){
//        final string METHODNAME = CLASSNAME.replace('METHODNAME','setRebillOrderDates');
//        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
//        //Get Rebill Recordtype
//        String  recType = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Rebill Order').getRecordTypeId();
//        List<Id> rebillOrders = new List<Id>();
//        Set<Id>parentOrders = new Set<Id>();

//        for(Order__c order : newOrders){
//            if(order.RecordTypeId == recType){
//                rebillOrders.add(order.Id);             //holds ids of orders identified as rebill orders
//                parentOrders.add(order.ParentOrder__c); //holds ids of parent orders for rebill orders
//            }
//        }

//        List<Order_Line_Item__c> roLineItems          = [select id, Product__c, Order__c, Order__r.ParentOrder__c ,startDate__c, endDate__c from Order_Line_Item__c where Order__c IN:rebillOrders];
//        List<Order_Line_Item__c> parentOrderLineItems = [select id, Product__c, Order__c, Order__r.ParentOrder__c ,startDate__c, endDate__c from Order_Line_Item__c where Order__c IN:parentOrders];
//        List<Order_Line_Item__c>updateList = new List<Order_Line_Item__c>();
//        //Match rebill line item to orginal order line item
//        for(Order_Line_Item__c rli : roLineItems){
//            system.debug('setRebillOrderDates rebillLI dates start '+ rli.startDate__c + 'end '+rli.endDate__c);
//            for(Order_Line_Item__c oli : parentOrderLineItems){
//                system.debug('setRebillOrderDates parentOrderLineItems dates start '+ oli.startDate__c + 'end '+oli.endDate__c);
//                if((rli.Product__c == oli.Product__c) && (rli.Order__r.ParentOrder__c == oli.Order__c)){    // Set start and end dates if line item products and original orders match
//                    system.debug('boo!!');
//                    rli.startDate__c = oli.startDate__c;
//                    rli.endDate__c   = oli.endDate__c;
//                    updateList.add(rli);
//                }
//            }
//        }
//        try{
//            system.debug('setRebillOrderDates updateList ' +updateList);
//            update updateList;
//        }catch(DmlException e){
//            system.debug('setRebillOrderDates updateList error: '+e);
//        }
//    }

    /*
    ** @author : Appirio (Jonathan F)
    ** @date : 03/28/16
    ** @description : Make changes to incoming Ecomm orders
    ** @returns : nothing
    */

    /* Commented due to test class coverage fix - Shyam 1/11 - Method not called from anywhere
    public void fixEcomm(Order__c[] pOrder){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','fixEcomm');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        String fixed = '';

        try{
            set<Id> setIds = new set<Id>();
            for(Order__c o : pOrder){
              setIds.add(o.Agency__c);
            }

            //Map of direct fields: {'sourceField' => 'destField'} - if destField != sourceField, copy sourceField to destField
            map<String, String> directFields = new map<String, String>();

            String relatedObject = 'agency__r';
            //Map of related fields: {'sourceField' => 'destField'} - if destField != relatedObject.sourceField, copy relatedObject.sourceField to destField
            map<String, String> relatedFields = new map<String, String>();

            map<Id, Account> mapSrc = new map<Id, Account>();
            String queryStr = 'SELECT Id, ';
            for(String field : directFields.keySet()){
                queryStr += field + ',';
            }
            for(String field : relatedFields.keySet()){
                queryStr += relatedObject + '.' + field + ',';
            }
            queryStr = queryStr.left(queryStr.length() - 1);
            queryStr += ' FROM Account WHERE ID IN (';
            for(String id : setIds){
                queryStr += '\'' + id + '\',';
            }
            queryStr = queryStr.left(queryStr.length() - 1);
            queryStr += ')';
            system.debug('queryStr = '+ queryStr);

            List<Account> Accounts = Database.query(queryStr);
            for(Account a : Accounts){
                mapSrc.put(a.Id,a);
            }

            for(Order__c dest : pOrder){
                fixed = '';
                if (mapSrc != null && mapSrc.containskey(dest.Agency__c)){
                    //process the direct references
                    for(String sourceField : directFields.keySet()){
                        String destField = directFields.get(sourceField);
                        if (dest.get(destField) != mapSrc.get(dest.Agency__c).get(sourceField)){
                            dest.put(destField, mapSrc.get(dest.Agency__c).get(sourceField));
                            fixed += ' ' + destField;
                        }
                    }

                    //process the related object references
                    for(String sourceField : relatedFields.keySet()){
                        String destField = relatedFields.get(sourceField);
                        SObject relObject = mapSrc.get(dest.Agency__c).getSobject(relatedObject);
                        if (relObject != null && dest.get(destField) != mapSrc.get(dest.Agency__c).getSobject(relatedObject).get(sourceField)){
                            dest.put(destField, mapSrc.get(dest.Agency__c).getSobject(relatedObject).get(sourceField));
                            fixed += ' ' + destField;
                        }
                    }
                }
                if (fixed != ''){
                    system.debug('^^^ Updated MAPP Order__c  (fixed ' + fixed + '): ' + dest);
                }
            }
        }
        catch(Exception e){
            ExceptionLog.add('Exception', 'OrderTriggerHelper', 'fixEcomm', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to fix key field(s) on order.' ,e);
        }
    }
    */


    /*
    ** @author : Appirio (Sylvester Agyen)
    ** @date : 03/31/16
    ** @description : Set selling country on order
    ** @returns : nothing
    */
    public void setOrderSellingCountry(List<Order__c>newOrders){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','setOrderSellingCountry');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Map<Id,Id>orderToParentMap = new Map<Id,Id>();
        for(Order__c order : newOrders){
            // Order does not have a parent order, set selling country to order's Quote_Selling_Country__c
            if(String.isEmpty(order.Selling_Country__c) && order.ParentOrder__c == null){
                order.Selling_Country__c = order.Quote_Selling_Country__c;
            }
            // Order has a parent order. Map to it's parent
            else if(String.isEmpty(order.Selling_Country__c) && order.ParentOrder__c != null){
                orderToParentMap.put(order.id, order.ParentOrder__c);
            }
        }
        //Query parent fields
        // Shyam 1/30 : S-443026
        Map<Id,Order__c> parentResults = new Map<Id,Order__c>();
        if(!orderToParentMap.isEmpty()){
            parentResults = new Map<Id,Order__c>([select id, Quote_Selling_Country__c from Order__c where id IN:orderToParentMap.values()]);

        }
        if(parentResults.size() > 0){ //Found parents
            for(Order__c order : newOrders){
                // set selling country to parent's Quote_Selling_Country__c
                order.Selling_Country__c = parentResults.get(order.ParentOrder__c).Quote_Selling_Country__c;
            }
        }
    }

    // I-213332 >> Contact Phone number cannot be null for contacts on orders

    public void contactPhoneValidationsOnOrder(Order__c [] pNewOrders, Map<Id, Order__c> pOldOrdersMap){

        set<Id> lstVerifiedOrdersId = new set<Id>();
        String msg = '';

        // Filter out the verified orders

        for(Order__c ord : pNewOrders) {


            if(pOldOrdersMap.get(ord.Id).OrderStatus__c != 'Sent To Verification' && ord.OrderStatus__c == 'Sent To Verification'){
                lstVerifiedOrdersId.add(ord.Id);
            }
        }

        // Validate contacts phone exists on order

        map<Id, Order__c> orderMap = new map<Id, Order__c>([Select Id, AgencyBillingContact__c, AgencyBillingContact__r.phone, BillingContact__c, BillingContact__r.phone,
                             Contact__c, Contact__r.phone, Contact_for_Training__c,Contact_for_Training__r.phone, Posting_Contact__c,
                             Posting_Contact__r.phone, PrContact__c,PrContact__r.phone, Primary_Contact__c, Primary_Contact__r.phone,
                             Send_Welcome_Letter_to__c, Send_Welcome_Letter_to__r.phone, ShippingContact__c, ShippingContact__r.phone
                            from Order__c Where Id In :lstVerifiedOrdersId]);

        for(Order__c orderRecord : pNewOrders){

            if(orderMap.containsKey(orderRecord.Id)) {

                Order__c ord = orderMap.get(orderRecord.Id);

                msg += (ord.AgencyBillingContact__c != null && String.isBlank(ord.AgencyBillingContact__r.phone)) ? 'Agency Billing Contact,' : '';
                msg += (ord.BillingContact__c != null && String.isBlank(ord.BillingContact__r.phone)) ? 'Billing Contact,' : '';
                msg += (ord.Contact__c != null && String.isBlank(ord.Contact__r.phone)) ? 'Contact__c,' : '';
                msg += (ord.Contact_for_Training__c != null && String.isBlank(ord.Contact_for_Training__r.phone)) ? 'Contact for Training,' : '';
                msg += (ord.Posting_Contact__c != null && String.isBlank(ord.Posting_Contact__r.phone)) ? 'Posting Contact,' : '';
                msg += (ord.PrContact__c != null && String.isBlank(ord.PrContact__r.phone)) ? 'PrContact,' : '';
                msg += (ord.Primary_Contact__c != null && String.isBlank(ord.Primary_Contact__r.phone)) ? 'Primary Contact,' : '';
                msg += (ord.Send_Welcome_Letter_to__c != null && String.isBlank(ord.Send_Welcome_Letter_to__r.phone)) ? 'Send Welcome Letter to,' : '';
                msg += (ord.ShippingContact__c != null && String.isBlank(ord.ShippingContact__r.phone)) ? 'ShippingContact,' : '';

                if(msg != ''){

                    orderRecord.addError('There are some contacts on order that do not have phone number which is as following :  '+msg);
                }
          }

        }

    }

     // T-497285
    public void updateBillingContactName(List<Order__c> newOrders, Map<Id, Order__c> oldOrderIdMap){


        Set<Id> contactIds = new set<Id>();

        for(Order__c ord : newOrders) {
            if(oldOrderIdMap == null && ord.BillingContact__c != null){
                contactIds.add(ord.BillingContact__c);
            }
            else if(ord.BillingContact__c != null && ord.BillingContact__c != oldOrderIdMap.get(ord.Id).BillingContact__c){
                contactIds.add(ord.BillingContact__c);
            }
        }

        if(contactIds.isEmpty()) return;

        map<Id,Contact> mapCon = new map<Id,contact> ([Select Id, LastName, FirstName from Contact where Id IN :contactIds]);

        for(Order__c ord : newOrders) {
            if(mapCon.containsKey(ord.BillingContact__c)){
                ord.Billing_Contact_Name__c = mapCon.get(ord.BillingContact__c).FirstName + ' ' + mapCon.get(ord.BillingContact__c).LastName;
            }
        }

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
    public void PopulateSiteChannelCountry(Order__c [] pNewOrders){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','PopulateSiteChannelCountry');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            set<String> OrdSiteId = new set<String>();
            List<Order__c> UpdateOrdList = new List<Order__c>();
            system.debug('pNewOrders'+pNewOrders);
            String PartnerCountry;
            String Channelid;
            for(Order__c ord : pNewOrders){
                    OrdSiteId.add(ord.SiteChannelID__c);
                    Channelid = ord.SiteChannelID__c;
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
                if(Channelid == '58'){//I-212413
                    OrdList.SiteChannelCountry__c = 'United States';
                }
                else{
                    OrdList.SiteChannelCountry__c =  PartnerCountry;
                    system.debug('PrsList2'+OrdList.SiteChannelCountry__c );
                    //UpdateOrdList.add(OrdList);
                }
              OrdList.IntegrationStatus__c = 'Insert In Progress';
            }
            //update UpdateOrdList;
        }
         catch(Exception e){
            system.debug('errored');
            ExceptionLog.add('Exception', 'OrderTriggerHelper', 'Populate SiteChannelCountry', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to populate SiteChannelCountry on Order.' ,e);
        }
}



public void ValidateOwnerSalesChannel(Order__c[] orderList, map<ID, Order__c> pOrderIdToOldOrderMap) {

  set<Id> primarySalesRepIds = new set<Id>();
  set<id> setOppIds = new Set<Id>();
  List<Order__c> ordersTobeProcessed = new List<Order__c>();
    system.debug('<<orderList>>'+orderList);
    system.debug('<<pOrderIdToOldOrderMap>>'+pOrderIdToOldOrderMap);
  for(Order__c ord : orderList){
       setOppIds .add(ord.Opportunity__c);
       if(ord.OrderStatus__c != pOrderIdToOldOrderMap.get(ord.Id).OrderStatus__c && (ord.OrderStatus__c == 'Sent To Verification' && ord.Organization__c != 'Europe'))  {//S-484487 AP 05/16
            system.debug('primary sales rep? ' + ord.PrimarySalesRep__c + ' ' + ord.Id);
           if(ord.PrimarySalesRep__c != null){
                primarySalesRepIds.add(ord.PrimarySalesRep__c);
                ordersTobeProcessed.add(ord);
           }
       }
  }

  if(ordersTobeProcessed.isEmpty()) return;
  map<id,Opportunity> mapOpp = new map<id,Opportunity>([select RecordType.name from Opportunity where id IN :setOppIds]);
  map<Id, User> userMap = new map<Id, User> ([Select Id,Combined_Region__c,Position_Organization__c,PositionSalesChannel__c
                                              from User Where Id IN :primarySalesRepIds]);
  set<String> combinedReasonSet = new set<String>();
  set<String> PositionOrgSet = new set<String>();
  set<String> PositionSalesChannelSet = new set<String>();
  set<String> SellingCountrySet = new set<String>();
  set<String> SalesChannelStoreList = new set<String> ();
  List<Sales_Channel_Cross_Reference__c> SaleschannelRecords = new List<Sales_Channel_Cross_Reference__c> ();
  User user;
  Boolean IsValid;

  //JFreese Appirio 5/11/17 S-483688 - was using orderList which failed for multiple orders with mixed status & PrimarySalesRep__c
  for(Order__c order : ordersTobeProcessed){
      user = userMap.get(order.PrimarySalesRep__c);
      system.debug('is user populated? ' + user);
      combinedReasonSet.add(user.Combined_Region__c);
      PositionOrgSet.add(user.Position_Organization__c);
      PositionSalesChannelSet.add(user.PositionSalesChannel__c);
      SellingCountrySet.add(order.Quote_Selling_Country__c);

  }

  SaleschannelRecords = [Select Id,Combined_Region__c,Position_Organization__c,
                                               Position_Sales_Channel__c, Selling_Country__c
                                               from Sales_Channel_Cross_Reference__c
                                               Where (Combined_Region__c IN :combinedReasonSet OR Combined_Region__c = null)
                                               AND (Position_Organization__c IN :PositionOrgSet OR Position_Organization__c = null)
                                               AND (Position_Sales_Channel__c IN :PositionSalesChannelSet OR Position_Sales_Channel__c = null)
                                               AND (Selling_Country__c IN :SellingCountrySet OR Selling_Country__c = null) ];

    //JFreese Appirio 1/17/17 I-252831 requested changes from S-449446 be reverted
    //Id ecommId = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Ecomm').getRecordTypeId(); // Changes  By Gaurav Gupta on 22 December 2016 for  S-449446
    //JFreese Appirio 5/11/17 S-483688 - was using orderList which failed for multiple orders with mixed status & PrimarySalesRep__c
    for(Order__c order : ordersTobeProcessed){
        if(order.Opportunity__c == null ||  mapOpp.get(order.Opportunity__c).RecordType.Name  !=  'GCS Opportunity') { //&& order.recordtypeId != ecommId )   {// Changes  By Gaurav Gupta on 22 December 2016 for  S-449446
      user = userMap.get(order.PrimarySalesRep__c);
      IsValid = false;
      for(Sales_Channel_Cross_Reference__c channel : SaleschannelRecords){

           if((channel.Combined_Region__c == user.Combined_Region__c || channel.Combined_Region__c == null)
               && (channel.Position_Organization__c == user.Position_Organization__c || channel.Position_Organization__c == null)
               && (channel.Position_Sales_Channel__c == user.PositionSalesChannel__c || channel.Position_Sales_Channel__c == null)
               && (channel.Selling_Country__c == order.Quote_Selling_Country__c || channel.Selling_Country__c == null) ) {
                   IsValid = true;
                   break;
           }
      }
      if(!IsValid){
          order.addError('Please contact Sales Operations in NA and the Pre-Quote-Check-Team in EU to correct the Primary Sales Profile. The order cannot be processed until a valid Sales Channel is defined.');
      } }
  }



}

    /*
    ** @author : Shyam
    ** @date : 07/08/2016
    ** @story :
    ** @Issue : for I-220471
    ** @description : Populate validateLineItemAttributeCountry
    ** @paramaters : list of Orders
    ** @returns : nothing
    */
    public void validateLineItemAttributeCountry(Order__c [] pNewOrders, Map<Id, Order__c> pOldOrdersMap){

        set<Id> lstVerifiedOrdersId = new set<Id>();
        String msg = '';

        // Filter out the verified orders
        for(Order__c ord : pNewOrders) {
            if(pOldOrdersMap.get(ord.Id).OrderStatus__c != ord.OrderStatus__c && (ord.OrderStatus__c == 'Paid in Full'
                    || ord.OrderStatus__c == 'Verified')){ lstVerifiedOrdersId.add(ord.Id);
            }
        }

        // Validate
        map<Id, Order_Line_Item__c> orderMap = new map<Id, Order_Line_Item__c>();

        for(Order_Line_Item__c oLI : [Select Id, Order__c, (Select Id, Country__c, Order_Line_Item__c from Line_Item_Attributes__r where Country__c = null or Country__c = 'Select One')
                         from Order_Line_Item__c where Order__c In :lstVerifiedOrdersId]){
            orderMap.put(oLI.Order__c, oLI);
        }

         for(Order__c ord : pNewOrders) {
            if(orderMap.containsKey(ord.Id)){
                if(orderMap.get(ord.Id).Line_Item_Attributes__r.size() > 0){
                    ord.addError('You are not able to update order status to Verified/Paid in Full, because of '
                        + orderMap.get(ord.Id).Line_Item_Attributes__r[0].Order_Line_Item__c + ' has invalid country Attribule value.');
                }
            }
        }
    }

    /*
    ** @author : Appirio (Jeff L)
    ** @date : 07/25/16
    ** @description : Populates the finance order type and finance sequence on the Order I-184385
    ** @returns : nothing
    */
    public void setFinanceOrderTypeAndSequence(list<Order__c> pNewOrders, Map<Id,Order__c> oldOrderMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','setFinanceOrderTypeAndSequence');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        List<Order__c> ordersToUpdate = new List<Order__c>();
        Map<Id,Order__c> orderMap = new Map<Id,Order__c>(pNewOrders);
        Map<Id,List<Order_Line_Item__c>> orderToOliMap = new Map<Id,List<Order_Line_Item__c>>();
        List<Order_Line_Item__c> oliToProcess = new List<Order_Line_Item__c>();
        Set<Id> orderIdsToQuery = new Set<Id>();
        //Get all the related orders and their information
        //iterate over the order line items to  see if their orders
        // financial Order Type or Finance Order Sequence needs
        //to be updated

        //put together a map of oli to Orders, needed for checking if all OLI's are
        //0 on an order before marking it as Not Applicable


        for(Order__c ord : pNewOrders){
            if( (ord.OrderStatus__c == 'Sent To Verification' && oldOrderMap.get(ord.Id).OrderStatus__c != 'Sent To Verification') ||
                (ord.OrderStatus__c == 'Paid in Full' && oldOrderMap.get(ord.Id).OrderStatus__c != 'Paid in Full') ||
                (ord.OrderStatus__c == 'Verified' && oldOrderMap.get(ord.Id).OrderStatus__c != 'Verified') ||
                (ord.OrderStatus__c == 'Invoiced' && oldOrderMap.get(ord.Id).OrderStatus__c != 'Invoiced')){
                orderIdsToQuery.add(ord.Id);
            }
        }

        Map<Id,Order__c> orderTestMap = new Map<Id,Order__c>();
        for(Order_Line_Item__c oli : [Select Id, Order__r.Id, Order__r.NetTotalAmount__c,
             Order__r.Order_Sequence__c,Order__r.Finance_Order_Type_pickList__c,
             Order__r.Account__r.WinbackDate__c, Order__r.OrderDate__c, Order__r.Account__r.CustomerDate__c,
             NetUnitPrice__c
             From Order_Line_Item__c
             where Order__c IN :orderIdsToQuery]){

            if(orderToOliMap.get(oli.Order__c) == null){
                orderToOliMap.put(oli.Order__c, new List<Order_Line_Item__c>());
            }
            orderToOliMap.get(oli.Order__c).add(oli);
            oliToProcess.add(oli);
            orderTestMap.put(oli.Order__r.Id, oli.Order__r);
        }


        for(Order_Line_Item__c oli : oliToProcess){
            //use our helper method to calculate
            Order__c calcedOrder = calcFinanceOrderTypeAndSequence(oli, orderTestMap.get(oli.Order__c), orderToOliMap.get(oli.Order__c));
            if(calcedOrder != null){
                Order__c origOrder = orderMap.get(oli.Order__c);
                origOrder.Order_Sequence__c = calcedOrder.Order_Sequence__c;
                origOrder.Finance_Order_Type_pickList__c = calcedOrder.Finance_Order_Type_pickList__c;
                origOrder.Skip_Sequence_and_Type_Validation__c = true;
            }
        }
        system.debug('qaccount1' + queryAccountList());
    }

    /*
    ** @author : Appirio (Jeff L)
    ** @date : 07/25/16
    ** @description : populates the finance order type on the Order I-184385
    ** @returns : nothing
    */
    private Order__c calcFinanceOrderTypeAndSequence(Order_Line_Item__c pOrderLineItem, Order__c pOrder, List<Order_Line_Item__c> pOtherOLI){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','calcFinanceOrderTypeAndSequence');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Order__c returnOrder = null;
        Boolean recordUpdated = false;
        Boolean orderTypeMatched = false;

        //We have three values: "New", "Existing", "Winback", "Not Applicable"
        //Different logic for each one

        //Easiset is "Not Applicable" - If the Order Line Item has no net total
        //then check to see if the order has a net total, if it's 0 then the order
        //is "Not Applicable"
        system.debug('Order Line Item Unit Price ' + pOrderLineItem.NetUnitPrice__c);
        system.debug('Order Net total amount ' + pOrder.NetTotalAmount__c);
        if(pOrderLineItem.NetUnitPrice__c.round() == 0 && (pOrder.NetTotalAmount__c == null || pOrder.NetTotalAmount__c.round() == 0 )){
            //now lets check the order Order Line Items on the order, just to make
            //sure we indeed have 0 for all the totals
            system.debug('Inside of Matching Not Applicable');
            orderTypeMatched = true;
            Double netTotal = 0;
            for(Order_Line_Item__c oli : pOtherOLI){
                netTotal += oli.NetUnitPrice__c;
            }

            system.debug('net total ' + netTotal);

            //now check if the total is truely 0
            if(netTotal == 0){
                //now lets check the fields, and update if needed
                if(pOrder.Finance_Order_Type_pickList__c != 'Not Applicable Order' ||
                    pOrder.Order_Sequence__c != 'Not Applicable Order'){
                    pOrder.Finance_Order_Type_pickList__c = 'Not Applicable Order';
                    pOrder.Order_Sequence__c = 'Not Applicable Order';
                    recordUpdated = true;
                }
            }
        } else {
            //Next up we need to check for "New", "Existing" or "Winback"
            //First thing is to check to see if we have a winback date
            system.debug('Checking Winback Date ' + pOrder.Account__r.WinbackDate__c);
            if(pOrder.Account__r.WinbackDate__c != null){
                //check to see if it is within a year of winback date
                if(pOrder.Account__r.WinbackDate__c.daysBetween(pOrder.OrderDate__c) < 365){
                    orderTypeMatched = true;
                    system.debug('Winback date Within a year');
                    if(pOrder.Finance_Order_Type_pickList__c != 'Winback'){
                        pOrder.Finance_Order_Type_pickList__c = 'Winback';

                        recordUpdated = true;
                    }

                    //Sequence is based upon if it's the same day as the winback day or not
                    if(pOrder.Account__r.WinbackDate__c == pOrder.OrderDate__c){
                        if(pOrder.Order_Sequence__c != 'First Time'){
                            pOrder.Order_Sequence__c = 'First Time';
                            recordUpdated = true;
                        }
                    } else {
                        if(pOrder.Order_Sequence__c != 'Follow-Up'){
                            pOrder.Order_Sequence__c = 'Follow-Up';
                            recordUpdated = true;
                        }
                    }
                }
            }

            //if no match after testing for Winback, then lets check new
            if(pOrder.Account__r.CustomerDate__c != null && orderTypeMatched == false){
                system.debug('About to check CustomerDate__c ' + pOrder.Account__r.CustomerDate__c);
                //check to see if it's within one year of the customer date
                if(pOrder.Account__r.CustomerDate__c.daysBetween(pOrder.OrderDate__c) < 365){
                    orderTypeMatched = true;
                    system.debug('customer date Within a year');
                    if(pOrder.Finance_Order_Type_pickList__c != 'New'){
                        pOrder.Finance_Order_Type_pickList__c = 'New';
                        recordUpdated = true;
                    }

                    //similar to winback, Sequence is based upon if it's the same day or not
                    if(pOrder.Account__r.CustomerDate__c == pOrder.OrderDate__c){
                        if(pOrder.Order_Sequence__c != 'First Time'){
                            pOrder.Order_Sequence__c = 'First Time';
                            recordUpdated = true;
                        }
                    } else {
                        if(pOrder.Order_Sequence__c != 'Follow-Up'){
                            pOrder.Order_Sequence__c = 'Follow-Up';
                            recordUpdated = true;
                        }
                    }
                }
            }

            //Finally - if we haven't had any matches yet then we default it to "Existing"
            if(orderTypeMatched == false){
                system.debug('Nothing matched - settings to Existing');
                if(pOrder.Finance_Order_Type_pickList__c != 'Existing'){
                    pOrder.Finance_Order_Type_pickList__c = 'Existing';
                    recordUpdated = true;
                }
                if(pOrder.Order_Sequence__c != 'Follow-Up'){
                    pOrder.Order_Sequence__c = 'Follow-Up';
                    recordUpdated = true;
                }
            }
        }

        if(recordUpdated){
            system.debug('Updated Order Finance Order Type ' + pOrder.Finance_Order_Type_pickList__c);
            system.debug('Updated Order Finance Order Sequence ' + pOrder.Order_Sequence__c);
            pOrder.Skip_Sequence_and_Type_Validation__c = true;
            returnOrder = pOrder;
        }

        //this will return null if no update was made
        return returnOrder;
    }

    /*
    ** @author : Adarsh
    ** @date : 08/02/16
    ** @description : I-225528/S-446033
    ** @returns : nothing
    */
    public void populatepayGoOrders(Order__c [] pNewOrders){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populatepayGoOrders');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Map<Id,String> xcodeIDToName = new Map<Id,String>();
        List<Order__c> ordersToCheck = new List<Order__c>();
        List<Order__c> ordersToUpdate = new List<Order__c>();
        Boolean LiveChannelFlag;
        try{
            //iterate through the orders and see if any meet our conditions
            //for the rest of this method - it's all based upon the Site Channel ID
            for(Order__c ord : pNewOrders){
                String scID = String.isBlank(ord.SiteChannelID__c) ? '0' : ord.SiteChannelID__c;
                if(scID == '58' || scID == '13' ||
                    scID == '14' || scID.length() == 4){
                    ordersToCheck.add(ord);
                    //initialize with null - will be populated below
                    xcodeIdToName.put(ord.Xcode__c, null);
                }
            }

            for(Xcode__c currXcode : [SELECT Id, Name FROM xcode__c WHERE Id IN :xcodeIdToName.keyset()]){
                xcodeIdToName.put(currXcode.Id,currXcode.Name);
            }
            List<Partner_Revenue_Share__c> PrsList = queryPartnerRevenueShare();
            system.debug('PrsList' + PrsList);
            for(Partner_Revenue_Share__c Prs: PrsList){
                LiveChannelFlag = Prs.MB_Live_Channel_Flag__c;
                system.debug('LiveChannelFlagPaygo' + LiveChannelFlag);
            }
            system.debug('logiccheckPaygo');
            /*if(LiveChannelFlag == False)
            {return;} */
            for(Order__c ord : ordersToCheck){
                system.debug('&&Order '+ord);
                Order__c updOrder = new Order__c(Id = ord.Id);
                String xCodeName = xcodeIdToName.get(ord.Xcode__c);
                String scID = String.isBlank(ord.SiteChannelID__c) ? '0' : ord.SiteChannelID__c;
                String postingCountry = ord.PostingCountry__c;
                String paymentFreq = ord.MAPP_Payment_Frequency__c;
                String salesChannel = ord.SalesChannel__c;
                String creditCardResponseCode = ord.CreditCardTransactionResponseCode__c;
                String Organization = ord.Organization__c;
                //58 = Monster US
                if(scID == '58'){
                    system.debug('Site Channel ID is 58');

                    if(xCodeName.startsWithIgnoreCase('xnppaygo') || xCodeName.startsWithIgnoreCase('xpaygo')){
                        system.debug('xcode Name begins with xnppaygo');
                        //#2 in requirements document
                        //updOrder.OrderStatus__c = 'Verified';
                        updOrder.ICS_OrderStatus__c = 'Verified';//AP S-445901
                        system.debug('comment20');
                        updOrder.SiteChannelCountry__c = 'United States';
                        updOrder.SalesChannel__c = 'Partner';
                        updOrder.Position_Organization__c = 'Newspapers';
                        updOrder.Combined_Region__c = 'Newspapers';
                        updOrder.Payment_Method_text__c = 'Partner';
                        updOrder.Payment_Frequency__c = 'Single Payment';
                        updOrder.Payment_Term_text__c =  'Immediate';
                        updOrder.Installments__c = 1;
                    }
                   else{ //xcode is Not Like 'xnppaygo%'
                        system.debug('xcode name DOES NOT begin with xnppaygo');
                        if(postingCountry != 'United States'){
                            system.debug('Posting Country is not United States');
                            if(paymentFreq == 'Pre-Paid'){
                                system.debug('Payment Method is Credit Card');
                                //#4 in requirements document
                                //updOrder.OrderStatus__c = 'Paid in Full';
                                updOrder.ICS_OrderStatus__c = 'Paid in Full';//AP S-445901
                                system.debug('comment19');
                                updOrder.SiteChannelCountry__c = 'United States';
                                updOrder.SalesChannel__c = 'ECOMM';
                                updOrder.Position_Organization__c = 'ECOMM';
                                updOrder.Combined_Region__c = null;
                                updOrder.Payment_Method_text__c = 'Credit Card';
                                updOrder.Payment_Frequency__c = 'Single Payment';
                                updOrder.Payment_Term_text__c =  'Immediate';
                                updOrder.Installments__c = 1;
                            } else {

                                    system.debug('Payment Method IS NOT Credit Card');
                                    //#5 in requirements document
                                    //updOrder.OrderStatus__c = 'Verified';
                                    updOrder.ICS_OrderStatus__c = 'Verified';//AP S-445901
                                    system.debug('comment18');
                                    updOrder.SiteChannelCountry__c = 'United States';
                                    updOrder.SalesChannel__c = 'ECOMM';
                                    updOrder.Position_Organization__c = 'ECOMM';
                                    updOrder.Combined_Region__c = null;
                                    updOrder.Payment_Method_text__c = 'Invoice';
                                    updOrder.Payment_Frequency__c = 'Single Payment';
                                    updOrder.Payment_Term_text__c =  'Net 30';
                                    updOrder.Installments__c = 1;

                            }
                        }

                       else{ //Posting Country is United States
                            system.debug('Posting Country is United States');
                            if(salesChannel == 'Partner'){
                                system.debug('Sales Channel is Partner');
                                if(paymentFreq == 'Pre-Paid'){
                                    system.debug('Payment Method Credit Card');
                                    //#6 in requirements document
                                    //updOrder.OrderStatus__c = 'Paid in Full';
                                    updOrder.ICS_OrderStatus__c = 'Paid in Full';//AP S-445901
                                    system.debug('comment17');
                                    updOrder.SiteChannelCountry__c = 'United States';
                                    updOrder.SalesChannel__c = 'ECOMM';
                                    updOrder.Position_Organization__c = 'ECOMM';
                                    updOrder.Combined_Region__c = null;
                                    updOrder.Payment_Method_text__c = 'Credit Card';
                                    updOrder.Payment_Frequency__c = 'Single Payment';
                                    updOrder.Payment_Term_text__c =  'Immediate';
                                    updOrder.Installments__c = 1;
                                } else {

                                        system.debug('Payment Method IS NOT Credit Card');
                                        //#7 in requirements document
                                        //updOrder.OrderStatus__c = 'Verified';
                                        updOrder.ICS_OrderStatus__c = 'Verified';//AP
                                        system.debug('comment16');
                                        updOrder.SiteChannelCountry__c = 'United States';
                                        updOrder.SalesChannel__c = 'ECOMM';
                                        updOrder.Position_Organization__c = 'ECOMM';
                                        updOrder.Combined_Region__c = null;
                                        updOrder.Payment_Method_text__c = 'Invoice';
                                        updOrder.Payment_Frequency__c = 'Single Payment';
                                        updOrder.Payment_Term_text__c =  'Net 30';
                                        updOrder.Installments__c = 1;

                                }
                            } else {
                                system.debug('Sales Channel IS NOT Partner');
                                if(paymentFreq == 'Pre-Paid'){
                                    system.debug('Payment Method is Credit Card');
                                    //#8 in requirements document
                                    //we don't populate Sales Channel, Position Organization
                                    //and Combined region we just accept what has already
                                    //been populated
                                    //updOrder.OrderStatus__c = 'Paid in Full';
                                    updOrder.ICS_OrderStatus__c = 'Paid in Full';//AP S-445901
                                    system.debug('comment15');
                                    updOrder.SiteChannelCountry__c = 'United States';
                                    updOrder.Payment_Method_text__c = 'Credit Card';
                                    updOrder.Payment_Frequency__c = 'Single Payment';
                                    updOrder.Payment_Term_text__c =  'Immediate';
                                    updOrder.Installments__c = 1;
                                } else {

                                    system.debug('Payment Method IS NOT Credit Card');
                                    //#9 in requirements document
                                    //we don't populate Sales Channel, Position Organization
                                    //and Combined region we just accept what has already
                                    //been populated
                                    //updOrder.OrderStatus__c = 'Verified';
                                    updOrder.ICS_OrderStatus__c = 'Verified';//AP S-445901
                                    system.debug('comment14');
                                    updOrder.SiteChannelCountry__c = 'United States';
                                    updOrder.Payment_Method_text__c = 'Invoice';
                                    updOrder.Payment_Frequency__c = 'Single Payment';
                                    updOrder.Payment_Term_text__c =  'Net 30';
                                    updOrder.Installments__c = 1;
                                }
                            }
                        }

                   }
                } else if(scID == '13' || scID == '14'){
                    //if(LiveChannelFlag == False)
                    system.debug('Site Channel Id is 13 or 14');
                    if(postingCountry != 'Canada'){
                        system.debug('Posting Country is not Canada');
                        if(paymentFreq == 'Pre-Paid'){
                            system.debug('Payment Method is Credit Card');
                            //#10 in requirements document
                            //updOrder.OrderStatus__c = 'Paid in Full';
                            updOrder.ICS_OrderStatus__c = 'Paid in Full';//AP
                            system.debug('comment13');
                            updOrder.SiteChannelCountry__c = 'Canada';
                            updOrder.SalesChannel__c = 'ECOMM';
                            updOrder.Position_Organization__c = 'ECOMM';
                            updOrder.Combined_Region__c = null;
                            updOrder.Payment_Method_text__c = 'Credit Card';
                            updOrder.Payment_Frequency__c = 'Single Payment';
                            updOrder.Payment_Term_text__c =  'Immediate';
                            updOrder.Installments__c = 1;
                        } else {
                            system.debug('Payment Method IS NOT Credit Card');
                            //#11 in the requirements document
                            //updOrder.OrderStatus__c = 'Verified';
                            updOrder.ICS_OrderStatus__c = 'Verified';//AP
                            system.debug('comment12');
                            updOrder.SiteChannelCountry__c = 'Canada';
                            updOrder.SalesChannel__c = 'ECOMM';
                            updOrder.Position_Organization__c = 'ECOMM';
                            updOrder.Combined_Region__c = null;
                            updOrder.Payment_Method_text__c = 'Invoice';
                            updOrder.Payment_Frequency__c = 'Single Payment';
                            updOrder.Payment_Term_text__c =  'Net 30';
                            updOrder.Installments__c = 1;
                        }
                    }

                    else {
                        system.debug('Posting Address is Canada');
                        if(paymentFreq == 'Pre-Paid'){
                            system.debug('Payment Method is Credit Card');
                            //#12 in requirements document
                            //we don't populate Sales Channel, Position Organization
                            //and Combined region we just accept what has already
                            //been populated
                            //updOrder.OrderStatus__c = 'Paid in Full';
                            updOrder.ICS_OrderStatus__c = 'Paid in Full';//AP
                            system.debug('comment11');
                            updOrder.SiteChannelCountry__c = 'Canada';
                            updOrder.Payment_Method_text__c = 'Credit Card';
                            updOrder.Payment_Frequency__c = 'Single Payment';
                            updOrder.Payment_Term_text__c =  'Immediate';
                            updOrder.Installments__c = 1;
                        }
                       else {
                            system.debug('Payment Method IS NOT Credit Card');
                            //#13 in requirements document
                            //we don't populate Sales Channel, Position Organization
                            //and Combined region we just accept what has already
                            //been populated
                            //updOrder.OrderStatus__c = 'Verified';
                            updOrder.ICS_OrderStatus__c = 'Verified';//AP
                            system.debug('comment10');
                            updOrder.SiteChannelCountry__c = 'Canada';
                            updOrder.Payment_Method_text__c = 'Invoice';
                            updOrder.Payment_Frequency__c = 'Single Payment';
                            updOrder.Payment_Term_text__c =  'Net 30';
                            updOrder.Installments__c = 1;
                        }
                    }
                } else if(scID.length() == 4){
                    if(LiveChannelFlag == True){
                    //#3 in requirements document
                    //updOrder.OrderStatus__c = 'Paid in Full';
                    updOrder.ICS_OrderStatus__c = 'Paid in Full';//AP
                    system.debug('comment9');
                    updOrder.SiteChannelCountry__c = 'United States';
                    updOrder.SalesChannel__c = 'Partner';
                    updOrder.Position_Organization__c = 'Newspapers';
                    updOrder.Combined_Region__c = 'Newspapers';
                    updOrder.Payment_Method_text__c = 'Partner';
                    updOrder.Payment_Frequency__c = 'Single Payment';
                    updOrder.Payment_Term_text__c =  'Immediate';
                    updOrder.Installments__c = 1;
                    }
                }
                // AP S-446033
                System.debug('Organization' + Organization);
                System.debug('scID' + scID);
                System.debug('creditCardResponseCode' + creditCardResponseCode);
                System.debug('paymentFreq' + paymentFreq);
                if(Organization == 'North America' && (scID == '58' || scID == '13' || scID == '14') && creditCardResponseCode != null && paymentFreq == 'Paypal'){
                    System.debug('EnteredPaypal');
                    //updOrder.OrderStatus__c = 'Paid in Full';
                    updOrder.ICS_OrderStatus__c = 'Paid in Full';//AP
                    system.debug('comment8');
                    updOrder.Payment_Method_text__c = 'Paypal';
                    updOrder.Payment_Term_text__c = 'Immediate';
                    updOrder.Payment_Frequency__c= 'Single Payment';
                    updOrder.Installments__c = 1 ;
                    updOrder.MAPP_Archive_Credit_Card_Type__c = ' PayPal';

                 }
                ordersToUpdate.add(updOrder);
            }
            system.debug('ordersToUpdatepaygo' +  ordersToUpdate);
            OrderTriggerHandler.ExecuteTriggers = false;
            Update ordersToUpdate;
            OrderTriggerHandler.ExecuteTriggers = true;

        } catch (Exception ex){
            system.debug('errored');
            ExceptionLog.add('Exception', 'OrderTriggerHelper', 'populatepayGoOrders', ex.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed populatepayGoOrders.' , ex);
        }
    }


/* IF user clicked on Cancelled_by_Ecom_Screening__c checkbox then
   1. Let's use negation type of 'All inventory'
   2. Let's use a rejected reason of 'Fraud'. It doesn't exist right now; please add it.
   3. Set the order status to Negated if Integration status is Not processed.
   4. An order status of 'Negated' will exclude the order from ICS and we don't need to set the Integration status in any specific way.*/

    public void SetNegatedOrderOnEcomScreeningCheckbox(Order__c [] pupdatedOrders, map<Id, Order__c> oldMap){
        List<Order__c> ordersToBeProcessed = new List<Order__c>();
        for(Order__c o : pupdatedOrders){
            if(o.Cancelled_by_Ecom_Screening__c && !oldMap.get(o.Id).Cancelled_by_Ecom_Screening__c
            && (o.IntegrationStatus__c  == 'Not Processed' || o.IntegrationStatus__c  == 'Exceptions Found'
            || o.IntegrationStatus__c  == 'Erro\r')){
                o.NegationType__c = 'All Jobs Inventory';
                o.RejectedReason__c = 'Fraud/Compliance Cancelled';
                o.OrderStatus__c = 'Negated';

            }
        }
    }


    public void BulkFullCreditLoadProcess(Order__c [] pupdatedOrders, map<Id, Order__c> oldMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','BulkFullCreditLoadProcess');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        List<Order__c> ordersToBeProcessed = new List<Order__c>();
        for(Order__c o : pupdatedOrders){
            if(o.BulkCreditLoad__c && !oldMap.get(o.Id).BulkCreditLoad__c) {
                ordersToBeProcessed.add(o);
            }
        }
         // Call bulkfullcreditload class
        if(ordersToBeProcessed.size() > 0){
            BulkFullCreditLoadProcessor processor = new BulkFullCreditLoadProcessor(ordersToBeProcessed);
        }
    }


 public void populatePostingContactPhoneEmail(Order__c [] newOrders){

    set<Id> billConIds = new set<Id>();
    set<Id> accIds = new set<Id>();
    Contact con;
    Account acc;
    for(Order__c o : newOrders){
        if(o.Posting_Contact__c != null) {
            billConIds.add(o.Posting_Contact__c);
        }
        if(o.Account__c != null) {
            accIds.add(o.Account__c);
        }
    }
    if(billConIds.isEmpty()) return;
    map<Id, Contact> mapcon = new map<Id, Contact> ([Select Id, Phone, Email from Contact
                                                     Where Id IN :billConIds and (phone != null or email != null)]);
    map<Id, Account> mapAcc = new map<Id, Account> ([Select Id,Account_Type__c  from Account Where Id IN :accIds and Account_Type__c != null]);
    for(Order__c o : newOrders){
        if(mapcon.containsKey(o.Posting_Contact__c)) {
            con = mapcon.get(o.Posting_Contact__c);
            if(con.email != null) {
                o.Posting_Contact_Email__c = con.email;
            }
            if(con.phone != null) {
                o.Posting_Contact_Phone__c = con.phone;
            }
        }
        if(mapAcc.containsKey(o.Account__c)){
            acc = mapAcc.get(o.Account__c);
            o.Account_Type__c = acc.Account_Type__c;
        }
    }
 }

   /*
    ** @author : Adarsh
    ** @date : 09/29/16
    ** @description : S-407471
    **
    */
    public void createTask(Order__c [] pNewOrders){
    final string METHODNAME = CLASSNAME.replace('METHODNAME','createTask');
    system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
    List<Task> tskLst = new List<Task>();
    List<Order__c> ordLst = new List<Order__c>();
    List<Account> ExistaccntList = new List<Account>();
    Set<Id> newAccId = new Set<Id>();
    String accOwnerId;
    for(Order__c newOrder: pNewOrders){
        newAccId.add(newOrder.Account__c);
    }
    List<Account> accntList = [select Id,OwnerId from Account where Id in: newAccId];
        //for(Account a : queryAccountList()){//commented this out and instead introduced extra query below for resolving the caching problem which caused I-238359
        for(Account a : accntList){
            accOwnerId= a.OwnerId;
        }

        for(Order__c ord : pNewOrders){
            system.debug('$$Ord '+ord);
            if (ord.Organization__c == 'North America')
            {
                Task tsk = new Task();
                tsk.whatId = ord.Id;
                system.debug('tskid' + tsk);
                tsk.Subject = 'Follow-Up Ecomm Order: Web Order ' + ord.WebOrderNumber__c +  ' Dated: ' +ord.OrderDate__c;
                tsk.Type = 'Call - Outbound';
                tsk.ActivityType__c = 'Call - Outbound';
                tsk.Priority = '1 - ASAP';
                tsk.ActivityDate =  ord.OrderDate__c.addDays(2);
                tsk.OwnerId = accOwnerId;
                tskLst.add(tsk);
            }

                //ordLst.add(ord);
        }

            insert tskLst;
    }
/**
     * @author Adarsh
     * @date  10.12.2016
     * @story S-445792
     */
    public void updateCustomerNumberofAccounts(Order__c [] pNewOrders, Map<Id, Order__c> pOldOrdersMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateCustomerNumberofAccounts');
        Logger.push(METHODNAME, 'Order__c');
        try{
            set<Id> AccountIds = new set<Id>();
            Id StandardOrderRecordtypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Standard');
            Id EcommRecordtypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Ecomm');
            for(Order__c ord :  pNewOrders){
               if(ord.RecordTypeId == EcommRecordtypeId){
                   AccountIds.add(ord.Account__c);
                }
                else{
                    // As per I-265883, Customer number generation functionality should work for all recordtypes So removing only
                    // Standard recordtype check
                    // By Vikas Menon on 29 March 2017
                    if((ord.Account__c != null)
                        && ((ord.OrderStatus__c == 'Sent To Verification' || ord.OrderStatus__c == 'Pending Processing')
                        && (pOldOrdersMap.get(ord.Id).OrderStatus__c!=ord.OrderStatus__c ))){
                        AccountIds.add(ord.Account__c);
                    }

                    // if BillingAccount__c != Account__c then we need to populate customer number on BillingAccount__c as well
                    // Modified by Vikas Menon, 22 March, 2017 (refer to S-449971)
                     //As per I-265883, Customer number generation functionality should work for all recordtypes So removing only
                    // Standard recordtype check By Vikas Menon on 29 March 2017
                    if((ord.BillingAccount__c != null)
                        && ((ord.OrderStatus__c == 'Sent To Verification' || ord.OrderStatus__c == 'Pending Processing')
                        && (pOldOrdersMap.get(ord.Id).OrderStatus__c!=ord.OrderStatus__c ))){
                        AccountIds.add(ord.BillingAccount__c);
                    }
                }
            }
            List<Account> AccountsToBeUpdated = new List<Account>();
            if(!AccountIds.isEmpty()){
                for(Account acc : [Select Id,AccountStatus__c,CustomerLapsedDate__c,CustomerDate__c,CustomerNumber__c,AutoCustomerNumber__c
                                   from Account Where Id IN :AccountIds]){
                // We need to use billing account as well so need a seprate query by vikas menon  refer to S-449971
                //for(Account acc : queryAccountList()){
                    //if(AccountIds.contains(acc.Id)){
                        if(acc.AccountStatus__c == 'Candidate' || acc.CustomerNumber__c == null || UserInfo.getName() =='Integration MAPP'){
                            if(acc.AccountStatus__c != 'Customer'){//I-247190
                                acc.AccountStatus__c = 'Customer';
                                acc.CustomerLapsedDate__c = null; // PC 12/21/16 upd of LapsedDate for S-456849
                            }
                            if(acc.CustomerDate__c == null)
                            {
                                acc.CustomerDate__c = Date.Today();
                            }
                            if(acc.CustomerNumber__c == null){
                                acc.CustomerNumber__c = acc.AutoCustomerNumber__c;
                            }
                            system.debug('acccustomer' + acc);
                            AccountsToBeUpdated.add(acc);
                            system.debug('acctobeupdated' + AccountsToBeUpdated);
                        }
                    //}
                }
            }
            if(!AccountsToBeUpdated.isEmpty()){
                    AccountTriggerHandler.ExecuteTriggers = False;
                    update AccountsToBeUpdated;
                    AccountTriggerHandler.ExecuteTriggers = True;
            }
        }catch(Exception e){
            Logger.debugException(e, null);
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to update the Account. Please see system logs for details. ' ,e);
        }
        Logger.pop();
    }

public void populateBillingStartDataOnRebill(Order__c [] newOrders){

    Id RebillRecordtypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Rebill Order');
    set<Id> parentIds = new set<Id>();
    set<Id> cRIds = new set<Id>();
    for(Order__c o : newOrders){
        if(o.ParentOrder__c != null && o.RecordTypeId == RebillRecordtypeId) {
            cRIds.add(o.CreditRequest__c);
            parentIds.add(o.ParentOrder__c);
        }
    }
    if(parentIds.isEmpty()) return;

    map<Id, Order__c> mapOrder = new map<Id, Order__c>([Select Id,BillingStartDt__c from Order__c Where Id IN :parentIds]);
    map<Id, Credit_Request__c> mapCR = new map<Id, Credit_Request__c>([Select Id,CreditReason__c from Credit_Request__c Where Id IN :cRIds]);
    for(Order__c o : newOrders){
      if(o.CreditRequest__c == null || (mapCR.containsKey(o.CreditRequest__c) && mapCR.get(o.CreditRequest__c).CreditReason__c != 'Billing Start Date Correction'))  {
        if(mapOrder.containsKey(o.ParentOrder__c)) {
           o.BillingStartDt__c = mapOrder.get(o.ParentOrder__c).BillingStartDt__c;
        }
      }
    }
}

/*
** @author : APPRIO (Deepanshu Soni)
** @date : 09-DEC-2016
** @description : S-452704
** @paramaters : List of Orders
** @returns : nothing
*/
    public void OpptyWriteBack(Order__c [] pNewOrders, Map<Id, Order__c> pOldOrdersMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OpptyWriteBack');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        system.debug('^^^OrderTriggerHandler.CreatingCreditOpportunity='+OrderTriggerHandler.CreatingCreditOpportunity);
        if (OrderTriggerHandler.CreatingCreditOpportunity == true){
            String dbg='^^^NOT processing this opportunity, as OrderTriggerHandler.CreatingCreditOpportunity='+OrderTriggerHandler.CreatingCreditOpportunity+': ';
            dbg += 'it is a Credit Opportunity created by OrderTriggerHelper.createCreditOpportunity(),\n';
            dbg += 'which set the opportunity owner to the original opp owner if that owner is a PPC user, ';
            dbg += 'else it set it to the account owner, so this method is being bypassed.';
            system.debug(dbg);
            return;
        }

        Set<Id> setOppIds = new Set<Id>();
        Set<Id> setOLIIds = new Set<Id>();
        List<Opportunity> opptyToUpdate = new List<Opportunity>();
        List<OpportunityLineItem> opptyLineItemToUpdate = new List<OpportunityLineItem>();
        Map<Id, Order__c> opptyToOrderMap = new Map<Id, Order__c>();
        Map<Id,Decimal> orderToOLIGrossAmtMap = new Map<Id,Decimal>();
        for(Order__c ord : pNewOrders){
            if(ord.OrderStatus__c != null && ((ord.OrderStatus__c == 'Verified' || ord.OrderStatus__c == 'Paid in Full' )
                                          && (pOldOrdersMap.get(ord.Id).OrderStatus__c!=ord.OrderStatus__c ))){
                setOppIds.add(ord.Opportunity__c);
                opptyToOrderMap.put(ord.Opportunity__c, ord);
            }
        }

        if (setOppIds != null) {
                for(Opportunity oppty : [SELECT Id, OwnerId FROM Opportunity WHERE Id IN :setOppIds]){
                    DateTime dT = opptyToOrderMap.get(oppty.Id).SentToVerificationDate__c;
                if (dt != null) {
                    oppty.Bypass_Close_Date_Validation__c = true;
                    oppty.CloseDate = dT.date();
                    system.debug('^^^ Updating Opportunity '+oppty.Id+' CloseDate to '+oppty.CloseDate);
                }
                if (oppty.OwnerId != opptyToOrderMap.get(oppty.Id).PrimarySalesRep__c){
                    system.debug('^^^ Changing Opportunity '+oppty.Id+' OwnerId from '+oppty.OwnerId+' to '+opptyToOrderMap.get(oppty.Id).PrimarySalesRep__c);
                }
                oppty.OwnerId = opptyToOrderMap.get(oppty.Id).PrimarySalesRep__c;
                opptyToUpdate.add(oppty);
            }
        }

        /*JHF Appirio 2/28/17 commenting this out as it is not used
        for(Order_Line_Item__c ordLineItem : [SELECT Id, Order__c, Gross_Total_Amount_Rpt__c FROM Order_Line_Item__c WHERE Order__c IN :pNewOrders]){
            orderToOLIGrossAmtMap.put(ordLineItem.Id, ordLineItem.Gross_Total_Amount_Rpt__c);
        }*/

        if (setOppIds != null) {
            for(OpportunityLineItem OppLineItem : [SELECT Id, TotalPrice, OpportunityId, Order_Line_Item_Custom__r.GrossTotalAmount__c, LockTotalPrice__c FROM OpportunityLineItem WHERE OpportunityId IN :setOppIds]){
                if (OppLineItem.Order_Line_Item_Custom__c != null) {
                    system.debug('^^^OppLineItem.TotalPrice='+OppLineItem.TotalPrice+', OppLineItem.Order_Line_Item_Custom__r.GrossTotalAmount__c='+OppLineItem.Order_Line_Item_Custom__r.GrossTotalAmount__c);
                    if(OppLineItem.TotalPrice != OppLineItem.Order_Line_Item_Custom__r.GrossTotalAmount__c){
                        system.debug('^^^OpportunitySplit(s) for Opportunity '+OppLineItem.OpportunityId+' will be updated');
                    }
                    OppLineItem.TotalPrice = OppLineItem.Order_Line_Item_Custom__r.GrossTotalAmount__c;
                    OppLineItem.LockTotalPrice__c = true;
                    opptyLineItemToUpdate.add(OppLineItem);
                }
            }
        }

        if (opptyToUpdate != null) {
            update opptyToUpdate;
        }
        if (opptyLineItemToUpdate != null) {
            update opptyLineItemToUpdate;
        }
    }


     /*
            Method Name - populatePPCSalesRepAsOwner
                          Written by Vikas Menon 14 Dec 2016
            Puspose :     System will set the PPC Sales rep as the Primary Sales Rep on order, where the PPC Sales Rep is set as the owner on the
                          Opportunity and quote, on an account they do not own.System will set the Sales Channel, Combined Region and Position
                          Org values from the PPC Sales Rep (S-448479)
    */

    public void populatePPCSalesRepAsOwner(Order__c [] pNewOrders){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populatePPCSalesRepAsOwner');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        set<Id> quoteIds = new set<Id>();
        set<Id> oppIds = new set<Id>();
        List<Apttus_Proposal__Proposal__c> quoteList = new List<Apttus_Proposal__Proposal__c>();
        map<Id, Id> mapQuoteToOwner = new map<Id, Id>();
        Id CreditOrderRecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Credit');
        // Get the PPC Role Ids
        set<Id> ppcRoleIds = new set<Id>();
        for(UserRole role : [Select Id, Name from UserRole Where Name like '%PPC%']){
            ppcRoleIds.add(role.Id);
        }

        for(Order__c o :pNewOrders){
            // As per S-448479, The logic will apply to both Offline and Echosign opportunity --> quote --> order process flows
            // So this logic will not apply or credit orders, added recrod type check, Modified by Vikas Menon, 18 Jan '17   (to fix I-252891)
            if(o.QuoteProposal__c != null && o.RecordTypeId != CreditOrderRecordTypeId){
                quoteIds.add(o.QuoteProposal__c);
            }
        }
        if(quoteIds.isEmpty()) return;
        // Query the proposal of order whose owner id and related opportunity owner id is PPC sales rep (having role name contains PPC)
        for(Apttus_Proposal__Proposal__c prop : [ SELECT Id, owner.UserroleId, ownerId,Apttus_Proposal__Account__r.owner.UserRoleId,
                                                  Apttus_Proposal__Account__r.ownerId,
                                                  Apttus_Proposal__Opportunity__r.owner.UserRoleId
                                                  FROM Apttus_Proposal__Proposal__c WHERE Id IN :quoteIds
                                                  AND owner.UserroleId IN :ppcRoleIds
                                                  AND Apttus_Proposal__Opportunity__r.owner.UserRoleId IN :ppcRoleIds]){
                                                  //AND Apttus_Proposal__Account__r.owner.UserRoleId NOT IN :ppcRoleIds] ){
            // I-253121 >> Account owner should not be same as proposal owner, we need to check owner id not PPC role
            // Modified by Vikas Menon, 18 Jan '17   (to fix I-252891)
            if(prop.Apttus_Proposal__Account__r.ownerId != prop.ownerId) {
                mapQuoteToOwner.put(prop.Id, prop.ownerId);
            }
        }
        if(mapQuoteToOwner.isEmpty())
        return;
        System.debug('----mapQuoteToOwner ' + mapQuoteToOwner);
        // Get user details - Sales channel, Position org and Combined region
        map<Id, User> mapUser = new map<Id, User>([ Select Id,PositionSalesChannel__c, Position_Organization__c,
                                                    Combined_Region__c from User Where Id IN :mapQuoteToOwner.values()]);

        System.debug('----mapUser ' + mapUser);
        // Set the order PrimarySalesRep__c as PPC Sales Rep
        for(Order__c o :pNewOrders){
            if(o.QuoteProposal__c != null && mapQuoteToOwner.containsKey(o.QuoteProposal__c)){
               Id ownerId = mapQuoteToOwner.get(o.QuoteProposal__c);
               System.debug('----PrimarySalesRep BEFORE ' + o.PrimarySalesRep__c);
               o.PrimarySalesRep__c = ownerId;
               System.debug('----PrimarySalesRep AFTER ' + o.PrimarySalesRep__c);
               if(mapUser.containsKey(ownerId)){
                   User u = mapUser.get(ownerId);
                   o.SalesChannel__c = u.PositionSalesChannel__c;
                   o.Combined_Region__c = u.Combined_Region__c;
                   o.Position_Organization__c = u.Position_Organization__c;
               }
            }
        }

    }
    /*
    ** @author : Adarsh
    ** @date : 01/05/2017
    ** @description : S-456747
    ** @paramaters : List of Orders
    ** @returns : nothing
    */
    public void PopulateSiteChannelId(Order__c [] pNewOrders){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','PopulateSiteChannelId');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
         String Country;
         String SiteChannelId;
         String OrderSiteChannelId;
         try{
                for(Order__c ord : pNewOrders){
                    Country = ord.Quote_Selling_Country__c;
                    system.debug('Country' + Country);
                    OrderSiteChannelId = ord.SiteChannelID__c;
                    system.debug('OrderSiteChannelId' + OrderSiteChannelId);
                }
                if(OrderSiteChannelId == null){
                    if(Country == 'United States'){
                        for(Order__c order : pNewOrders){
                            order.SiteChannelID__c = '58';
                            order.Site_Channel_ID__c = '58';
                        }
                    }
                    else{
                        List<Partner_Revenue_Share__c> PrsList = [
                        SELECT Id, SiteChannelID__c
                        FROM Partner_Revenue_Share__c
                        WHERE Country__c =: Country
                        ORDER BY CreatedDate DESC limit 1
                        ];
                        for(Partner_Revenue_Share__c prs : PrsList){
                            SiteChannelId = prs.SiteChannelID__c;
                            system.debug('SiteChannelId' + SiteChannelId);
                        }
                        for(Order__c order : pNewOrders){
                            order.SiteChannelID__c = SiteChannelId;
                            order.Site_Channel_ID__c = SiteChannelId;
                        }
                    }
                }

            }

         catch(Exception e){
            system.debug('errored');
            ExceptionLog.add('Exception', 'OrderTriggerHelper', 'PopulateSiteChannelId', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to populate SiteChannelId on Order.' ,e);
        }
    }

    //Sberron - S-452845 - I-252821 - 1/18/2017
    //After ecomm order is inserted and account owner updated, the opportunity owner is changed to the account owner.
    public void updateEcommOpptyOwner(Order__c[] pNewOrders) {
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateEcommOpptyOwner');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        try {
            List<Opportunity> opptyToUpdate = new List<Opportunity>();
            List<Id> opptyIds = new List<Id>();
            Map<Id, Id> opptyToAcc = new Map<Id, Id>();

            for (Order__c ord : pNewOrders) {
                opptyIds.add(ord.Opportunity__c);
                opptyToAcc.put(ord.Opportunity__c, ord.Account__c);
            }

            Map<Id, Account> accMap = new Map<Id, Account>();
            for (Account acc : [SELECT Id, Name, OwnerId FROM Account WHERE Id IN :opptyToAcc.values()]) {
                accMap.put(acc.Id, acc);
            }
            System.debug('----accMap' + accMap);

            for (Id opptyId : opptyIds) {
                Opportunity updatedOppty = new Opportunity(Id=opptyId);
                updatedOppty.OwnerId = accMap.get(opptyToAcc.get(updatedOppty.Id)).ownerId;
                opptyToUpdate.add(updatedOppty);
            }

            if (opptyToUpdate != null) {
                update opptyToUpdate;
            }
        }

        catch (Exception e) {
            System.debug('---Could not update opportunity owner');
            ExceptionLog.add('Exception', 'OrderTriggerHelper', 'updateEcommOpptyOwner', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Could not update opportunity owner.' ,e);
        }
    }

        /*
    ** @author : APPIRIO (Vikas Menon)
    ** @date : 22-Feb-2016
       @Description : As per S-445863 (T-578936,T-578927)
        Scenario 1 : When Order is Verified then
                     Find OLI which have a non-messaging product (Product__r.Messaging__c == false && OptionId__r.Messaging__c == false)
                     If non-messaging, update the corresponding OLI on the parent order (CreditRequestLineItem__r.Order_Line_Item__c)
                     to subtract the credit OLI.Quantity2__c from the parent OLI.NonMessaging_Available_Quantity__c
        Scenario 2 : When Order is Negated then
                     Find OLI which have a non-messaging product (Product__r.Messaging__c == false && OptionId__r.Messaging__c == false)
                     If non-messaging, update the corresponding OLI on the parent order (CreditRequestLineItem__r.Order_Line_Item__c)
                     to add the credit OLI.Quantity2__c to the parent OLI.NonMessaging_Available_Quantity__c

    */
    public void updateNonMsgQtyonCreditOrderVerifiedNegated(Order__c [] pNewOrders, Map<Id, Order__c> pOldOrdersMap){
            final string METHODNAME = CLASSNAME.replace('METHODNAME','updateNonMsgQtyonCreditOrderVerifiedNegated');
            Logger.push(METHODNAME, 'Order__c');
            List<Order__c> verifiedCreditOrders = new  List<Order__c>();
            List<Order__c> negatedCreditOrders = new  List<Order__c>();

            Id CreditOrderRecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Credit');
            for(Order__c o : pNewOrders){

                if(pOldOrdersMap.get(o.Id).OrderStatus__c != o.OrderStatus__c && o.RecordTypeID == CreditOrderRecordTypeId){

                    if(o.OrderStatus__c == 'Verified') {
                        verifiedCreditOrders.add(o);
                    }
                    if(o.OrderStatus__c == 'Negated') {
                        negatedCreditOrders.add(o);
                    }
                 }
            }

            // Call for method which subtract Credit OLI from parent OLI field "NonMessaging_Available_Quantity__c"
            if(!verifiedCreditOrders.isEmpty()) {
                updateNonMsgQtyonCreditOrder(verifiedCreditOrders, false);
            }

           // Call for method which adds Credit OLI to parent OLI field "NonMessaging_Available_Quantity__c"
            if(!negatedCreditOrders.isEmpty()) {
               updateNonMsgQtyonCreditOrder(negatedCreditOrders, true);

            }

    }

    /*   ** @author : APPIRIO (Vikas Menon)
         ** @date : 22-Feb-2016
        Description : Called by method updateNonMsgQtyonCreditOrderVerifiedNegated()
        This Method updates Parent OLI field "NonMessaging_Available_Quantity__c" with credit OLI field quantity2__c based
        on isCredited flag */

    public void updateNonMsgQtyonCreditOrder(Order__c [] crOrders, boolean isCredited){

            List<Order_Line_Item__c> oliToProcess = new  List<Order_Line_Item__c>();
            map<Id, Decimal> mapOLI = new map<Id, Decimal>();

            // Get all non messaging OLI and store it into map
            for(Order_Line_Item__c oli : [Select Id, product__r.messaging__c, OptionId__r.messaging__c, quantity2__c, NonMessaging_Available_Quantity__c,
                                          CreditRequestLineItem__c, CreditRequestLineItem__r.Order_Line_Item__c
                                          from Order_Line_Item__c Where Order__c IN :crOrders and product__r.messaging__c = false
                                          and OptionId__r.messaging__c = false and CreditRequestLineItem__c != null and
                                          CreditRequestLineItem__r.Order_Line_Item__c != null and Quantity2__c >= 0]) {
                  mapOLI.put(oli.CreditRequestLineItem__r.Order_Line_Item__c, oli.Quantity2__c);
            }
            if(mapOLI.isEmpty()) return;
            // Update parent OLI field "NonMessaging_Available_Quantity__c" with child OLI quantity
            for(Order_Line_Item__c parentOLI : [Select Id, NonMessaging_Available_Quantity__c from Order_Line_Item__c Where ID IN :mapOLI.keySet()]){
                if(mapOLI.containsKey(parentOLI.Id)) {
                    if(String.isBlank(String.valueOf(parentOLI.NonMessaging_Available_Quantity__c))){
                        parentOLI.NonMessaging_Available_Quantity__c = 0;
                    }
                    if(isCredited) {
                        parentOLI.NonMessaging_Available_Quantity__c += mapOLI.get(parentOLI.Id);
                    }
                    else {
                        parentOLI.NonMessaging_Available_Quantity__c -= mapOLI.get(parentOLI.Id);
                    }
                    oliToProcess.add(parentOLI);
                }
            }
            // Update parent OLI
            if(!oliToProcess.isEmpty()){
                upsert oliToProcess;
            }

    }


   // Added method for S-462334, When order is verified then order team record will be inserted based on related opportunity's sales credit split records
   // By Vikas Menon , 9 March 2017
   public void createOrderTeamForOpportunitySalesCreditSplit(Order__c [] pNewOrders, Map<Id, Order__c> pOldOrdersMap){

            List<OrderTeam__c> orderTeamToInsert = new List<OrderTeam__c>();
            List<Order__c> verifiedOrders = new List<Order__c>();
            set<Id> oppIds = new set<Id>();
            map<Id, List<Sales_Credit_Splits__c>> mapOppToSplit = new map<Id, List<Sales_Credit_Splits__c>>();
            for(Order__c o : pNewOrders){
                if(pOldOrdersMap.get(o.Id).OrderStatus__c != o.OrderStatus__c && o.OrderStatus__c == 'Verified' && o.Opportunity__c != null){
                         verifiedOrders.add(o);
                         oppIds.add(o.Opportunity__c);
                }

            }
            if(oppIds.isEmpty()) return;
            for(Sales_Credit_Splits__c split : [Select Id,Opportunity__c,Teaming_Rep__c,Teaming_Split_amount__c,Teaming_rep_split_for_Revenue__c,
                                                Teaming_Rep_Type__c from Sales_Credit_Splits__c Where Opportunity__c IN :oppIds]){
                   if(!mapOppToSplit.containsKey(split.Opportunity__c)){
                        mapOppToSplit.put(split.Opportunity__c, new List<Sales_Credit_Splits__c>());
                   }
                   mapOppToSplit.get(split.Opportunity__c).add(split);

            }
            if(mapOppToSplit.isEmpty()) return;
            for(Order__c o : verifiedOrders) {

                if(!mapOppToSplit.containsKey(o.Opportunity__c)) continue;
                for(Sales_Credit_Splits__c split : mapOppToSplit.get(o.Opportunity__c)){

                    OrderTeam__c orderTeam = new OrderTeam__c(order__c=o.Id);
                    orderTeam.TeamMember__c = split.Teaming_Rep__c;
                    orderTeam.Allocation_Type__c = split.Teaming_Rep_Type__c;
                    orderTeam.Split__c = split.Teaming_rep_split_for_Revenue__c;
                    orderTeam.Allocation_Value__c = split.Teaming_Split_amount__c;
                    if(split.Teaming_Rep__c == o.PrimarySalesRep__c) {
                        orderTeam.Owner_on_Start_Date__c = true;
                    }
                    orderTeamToInsert.add(orderTeam);

                }
            }
            if(!orderTeamToInsert.isEmpty()){
                insert orderTeamToInsert;
            }

   }


   /*
** @author : Vikas Menon
** @date : 26/04/2017
** @description : T-586693 - Creating A Record for Opportunity Monthly Budget whenever a new Proposal is created.
** @paramaters : List of Apttus_Proposal__Proposal__c
** @returns : nothing
*/

public void createOppMonthlyBudget(Order__c [] newOrders){
    system.debug('$$Called$$');
    Set<Id> oppIds = new Set<Id>();
    Set<Id> userRoleIds = new Set<Id>();
    List<Order__c> prosessedOrderList = new  List<Order__c>();
   // Map<Id,Opportunity> mapOfParentOpportunities = new Map<Id,Opportunity>();

    for(UserRole objUser : [Select id from userrole where name like '%PPC%']){
        userRoleIds.add(objUser.Id);
    }
    system.debug('UserRoleids'+userRoleIds);

    for(Order__c o : [select Id,QuoteProposal__c,QuoteProposal__r.Earliest_Start_Date__c,QuoteProposal__r.Latest_End_Date__c, Opportunity__c
                     from Order__c where Id In :newOrders and QuoteProposal__c != null and QuoteProposal__r.Earliest_Start_Date__c != Null
                     and QuoteProposal__r.Latest_End_Date__c != Null and Opportunity__c != null]){

            prosessedOrderList.add(o);
            oppIds.add(o.Opportunity__c);

    }

    if(oppIds.isEmpty() || userRoleIds.isEmpty()){
        return;
    }
    system.debug('oppIds....'+oppIds);
    map<Id,Opportunity> oppMap =new Map<Id,Opportunity>([Select owner.UserRoleId ,OpportunityType__c,Amount from Opportunity where id In : oppIds AND Amount > 0 AND OpportunityType__c = 'Contingent' AND owner.UserRoleId in : userRoleIds ]);

    if(oppMap.isEmpty()) return;

    List<Opportunity_Monthly_Budget__c> oppBudgetToInsert = new List<Opportunity_Monthly_Budget__c>();
    for(Order__c objAP : prosessedOrderList){
         Opportunity opp = new Opportunity();
        if(oppMap.containsKey(objAP.Opportunity__c)){
             opp = oppMap.get(objAP.Opportunity__c);
             system.debug('==roleid==='+opp.owner.userRoleID+'====OpportunityType__c==='+opp.OpportunityType__c);
              //createOppBudgetRecord(opp,objAP);
             List<Opportunity_Monthly_Budget__c> oppBudgetList = createOppBudgetRecord(opp,objAP);
             if(!oppBudgetList.isEmpty()){
                oppBudgetToInsert.addAll(oppBudgetList);
             }
        }

    }

    if(!oppBudgetToInsert.isEmpty()){
        system.debug('Opp Budget created');
        // Delete existing opportunity monthly budget records while creating new ones on send to order
        List<Opportunity_Monthly_Budget__c> oppBudgetToDelete = [Select Id from Opportunity_Monthly_Budget__c Where Related_Opportunity__c IN :oppIds];
        if(!oppBudgetToDelete.isEmpty()){
            delete oppBudgetToDelete;
        }
        // Now insert new ones
        insert oppBudgetToInsert;
    }
}


    public List<Opportunity_Monthly_Budget__c> createOppBudgetRecord(Opportunity opp ,Order__c objAPP){
        system.debug('##This is Called');
        List<Opportunity_Monthly_Budget__c> monthlyBudgetToInsert = new List<Opportunity_Monthly_Budget__c>();
        Date startDate = objAPP.QuoteProposal__r.Earliest_Start_Date__c; // == proposal Earliest_Start_Date__c
        Date endDate = objAPP.QuoteProposal__r.Latest_End_Date__c ;  // == proposal Latest_End_Date__c
        system.debug('DATES '+ startDate + ' '+ endDate );
        Date startStartMo = startDate.toStartOfMonth(); //beginning of the first month
        Date startEndMo = endDate.toStartOfMonth(); //beginning of the last month
        Date firstDay;
        Date lastDay;
        Date index = startStartMo; //Create Month text field from index
        Decimal estValue = opp.Amount; // == Opportunity Amount
        Decimal Budget = 0;
        Decimal budgetTotal = 0;
        Integer contractDays = startDate.daysBetween(endDate) + 1; // include both the start and end day
        Integer contractMos = startDate.monthsBetween(endDate);
        Integer daysInMonth;
        Integer BudgetDays=0;
        Integer budgetDaysTotal=0;
        system.debug('startDate='+startDate+', endDate='+endDate+', contractDays='+contractDays+', contractMos='+contractMos+', startStartMo='+startStartMo+', startEndMo='+startEndMo);
        String dbg = '';


        while(index <= startEndMo)
        {
            daysInMonth=date.daysInMonth(index.year(), index.month());

            if(index == startStartMo){
                firstDay = startDate;
                lastDay = index.addDays(daysInMonth - 1);
                BudgetDays = daysInMonth - startDate.day() + 1; // include the start day
                dbg = 'first month start: '+index.format();
            }
            else if(index == startEndMo){
                firstDay = index;
                lastDay = endDate;
                BudgetDays = index.daysBetween(endDate) + 1; // include the end day
                dbg = 'last month start: '+index.format();
            }
            else {
                firstDay = index;
                lastDay = index.addDays(daysInMonth - 1);
                BudgetDays = daysInMonth;
                dbg = 'middle month start: '+index.format();
            }
            Budget = estValue * BudgetDays / contractDays;
            budgetTotal += Budget;
            budgetDaysTotal += BudgetDays;

            dbg += ', days in month = '+daysInMonth;
            dbg += ', firstDay='+firstDay.format()+', lastDay='+lastDay.format();
            dbg += ', BudgetDays='+BudgetDays;
            dbg += ', Budget='+Budget.setScale(2);
            system.debug(dbg);
            system.debug('budgetDaysTotal='+budgetDaysTotal+' budgetTotal='+budgetTotal.setScale(2));
            system.debug('budget'+Budget);
            index = index.AddMonths(1);
            Opportunity_Monthly_Budget__c oppBudget = new Opportunity_Monthly_Budget__c(
            Related_Opportunity__c = opp.Id , Budget__c = Budget, FirstDay__c = firstDay,LastDay__c=lastDay,BudgetDays__c=BudgetDays,System_Generated__c=true);
            String monthName = DateTime.newInstance(firstDay.year(), firstDay.month(),firstDay.day()).format('MMMMM');
            oppBudget.Month__c = monthName + ' '+ firstDay.year();
            monthlyBudgetToInsert.add(oppBudget);
        }


        return monthlyBudgetToInsert;
    }

    /*
    ** @author : SBerron
    ** @date : 05/08/17
    ** @description : S-456389. Set Order Organization__c field based on the Order.Quote_Selling_Country__c field
    ** @paramaters : Order__c record
    ** @returns : nothing
    */
    public void setOrderOrganization(List<Order__c> ordList) {
        final string METHODNAME = CLASSNAME.replace('METHODNAME','setOrderOrganization');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Map<String, Quote_Selling_Country_to_Organization__c> countryToOrgMapping = Quote_Selling_Country_to_Organization__c.getAll();

        for (Order__c ord : OrdList) {
            if (countryToOrgMapping.containsKey(ord.Quote_Selling_Country__c)) {
                String newOrg = countryToOrgMapping.get(ord.Quote_Selling_Country__c).Organization__c;
                if (ord.Organization__c != null && ord.Organization__c != newOrg) {
                    System.debug('----Setting Order Organization to ' + newOrg);
                    ord.Organization__c = newOrg;
                }
            }
        }
    }
}