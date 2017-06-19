public class OnlineFlowProcess implements Queueable, Database.AllowsCallouts{
        public Set<Id> setOfOrderIds;
        //private Set<id> setProductIds;
        public void execute(QueueableContext context){
            //JFreese Appirio 5/11/17 S-483688 Catch exceptions and write them to the ExceptionLog
            try{
                updateOrderStatusForOnlineFlow(setOfOrderIds);
                // following method is called refer to S-455922 by Vikas Menon on 26 April, 2017
                populateOrderOnCase(setOfOrderIds);
            } catch (Exception ex) {
                ExceptionLog__c xlog = new ExceptionLog__c();
                xlog.TypeOfException__c = 'OnlineFlowProcess Exception';
                xlog.ObjectName__c = 'Order__c';
                xlog.Exception__c = 'The following Order(s) were processed: '+setOfOrderIds;
                xlog.Exception__c += ', resulting in the following exception: '+ex.getMessage()+'\n';
                xlog.Exception__c += ', stacktrace: '+ex.getStackTraceString();
                insert xlog;
            }
        }


        /*
            If Order created from Proposal and OM Processing Case created (applies for echosign Process):
            Order number is auto populated on the Validation Request/OM Processing Request Case
            as per S-455922 by Vikas Menon on 1 May, 2017

        */

        public void populateOrderOnCase(Set<Id> orderIDSet){

            map<Id,Id> mapQuoteToOrder = new map<Id,Id>();
            Set<Id> quoteIds = new set<Id>();
            List<Case> casesToUpdate = new List<Case>();
            for(Order__c o : [Select Id, QuoteProposal__c, Opportunity__c, Opportunity__r.IsValidationRequest__c
                              from Order__c where Id IN :orderIDSet and Opportunity__r.IsValidationRequest__c = true]){
                quoteIds.add(o.QuoteProposal__c);
                mapQuoteToOrder.put(o.QuoteProposal__c, o.Id);
            }
            if(quoteIds.isEmpty()) return;

            map<String, map<String, Id>> result = Utility.GetRecordTypeIdsBySObjectNameSet(new set<String>{'Case'});
            String OMrecordTypeId = result.get('Case').get('OM Processing Request');
            for(Case cs : [Select Id, RecordTypeId, Order__c,Proposal_ID__c from Case
                           Where Proposal_ID__c IN :quoteIds and RecordTypeId = :OMrecordTypeId]){
                if(mapQuoteToOrder.containsKey(cs.Proposal_ID__c)){
                    cs.Order__c = mapQuoteToOrder.get(cs.Proposal_ID__c);
                    casesToUpdate.add(cs);
                }
            }

            if(!casesToUpdate.isEmpty()){
                update casesToUpdate;
            }

        }

        public void updateOrderStatusForOnlineFlow(Set<Id> orderIDSet){
            System.debug('**** Inside OnlineFlowProcess.updateOrderStatusForOnlineFlow()');

            Set<Id> ordersIdsForVerification = new Set<Id>();
            if(orderIDSet == null  || orderIDSet.isEmpty()) {
                return;
            }

            List<Order__c> ordersToProcess = [select Id, (Select Id,Name,Product__c,Product__r.Messaging__c,Xcode__c,Product__r.ProductCode,OptionId__c,OptionId__r.Messaging__c from Order_Line_Items__r),
                                                Account__r.Primary_Xcode__c, Opportunity__r.AutoCreateOrder__c,
                                                Payment_Method_text__c, Account__r.Organization__c, Account__r.PORequired__c,
                                                CustomerPO__c, QuoteProposal__r.BillingStartDt__c,
                                                OrderDate__c, QuoteProposal__r.Payment_Method1__c,
                                                QuoteProposal__r.PaypalResultMessage__c,
                                                Agency__c, AgencyIO__c, QuoteProposal__r.AgencyIO__c,
                                                AgencyBillingContact__c, AgencyBillingContact__r.phone,
                                                BillingContact__c, BillingContact__r.phone,
                                                Contact__c, Contact__r.phone,
                                                Contact_for_Training__c,Contact_for_Training__r.phone,
                                                Posting_Contact__c,Posting_Contact__r.phone,
                                                PrContact__c,PrContact__r.phone,
                                                Primary_Contact__c, Primary_Contact__r.phone,
                                                Send_Welcome_Letter_to__c, Send_Welcome_Letter_to__r.phone,
                                                ShippingContact__c, ShippingContact__r.phone,RecordTypeId,
                                                PrimarySalesRep__r.Combined_Region__c,
                                                PrimarySalesRep__r.Position_Organization__c,
                                                PrimarySalesRep__r.PositionSalesChannel__c,
                                                QuoteProposal__r.Selling_Country__c, QuoteProposal__r.APTPS_Manual_NSSA_Type__c
                                                from Order__c where id in:orderIDSet ];


            List<Order__c> ordersToBeUpdated= new List<Order__c>();

            //setProductIds = new Set<id>();
            for(Order__c ord : ordersToProcess){

                System.debug(ord.Account__r.Organization__c);
                if(ord.Opportunity__r.AutoCreateOrder__c && (ord.Account__r.Organization__c.toLowerCase() == 'europe' ||
                    ord.Account__r.Organization__c.toLowerCase() == 'north america')) {

                    Order__c updatedOrder = populateOrderStatus(ord);
                    /* S-457971: Code Changes started: */
                    //ord.BillingStartDt__c = ord.QuoteProposal__r.BillingStartDt__c != null ? ord.QuoteProposal__r.BillingStartDt__c : ord.OrderDate__c; // commenting the code to prevent populating today's date as Billing Start date on Order
                    if(ord.BillingStartDt__c==null && ord.QuoteProposal__r.BillingStartDt__c != null)
                    {
                        ord.BillingStartDt__c = ord.QuoteProposal__r.BillingStartDt__c;
                    }
                    /* end of Code Changes for S-457971 */
                    ordersToBeUpdated.add(updatedOrder);
                }

               /* for(Order_Line_Item__c oli : ord.Order_Line_Items__r){
                    setProductIds.add(oli.OptionId__c);
                }*/

            }

            if(!ordersToBeUpdated.IsEmpty()) {
                update ordersToBeUpdated;
            }
        }

        //Little helper method to perform our logic to figure out what order status the order should have
        public Order__c populateOrderStatus(Order__c order){
            /*invalid order Payment = ! credit Card and ! invoice
            invalidXcode = Primary xcode is blank
            invalid products = any products that are non messaging on the order
            Agency Order with no Agency I/O (new requirement from I-203835)
            Check for invalid contact phone numbers - check all the contact phones to make sure they all have details I-213332

            if any of the above is true, then go into pending processing
            Otherwise if credit card:
            check if we are paid, if so Paid in Full, if not Pending Processing
            And if none of those conditions are met then we set the status to sent to verification

            T-517656 >> If below picklist values on order doesn't exist on new object 'Sales Channel Cross Reference'
            then we update the order status to 'Pending Processing' and pending processing notes should be populated:
            1) PrimarySalesRep__c.Position_Organization__c   2) PrimarySalesRep__c.PositionSalesChannel__c
            3) PrimarySalesRep__c.Combined_Region__c         4) Quote_Selling_Country__c
            */


            Boolean invalidOrderPayment = false;
            Boolean invalidXcode = false;
            Boolean invalidProducts = false;
            Boolean invalidAgencyIO = false;
            Boolean poRequired = false;
            Boolean invalidContactPhone = false;
            Boolean invalidNSSAType = false;
            string pendingProcNotes = '';



            boolean  isValid = isValidPicklistValuesOnOrder(order);
            if(!isValid){
                order.OrderStatus__c = 'Pending Processing';
                order.Pending_Processing_Notes__c = 'Value not found in Sales Channel Cross Reference';
                return order;
            }

            /* I-225037 >> Echosign Order STV automatically without an Xcode
               if any of the order line items does't have an xcode, we move order to pending processing
               and update the pending processing message to say that "OLI-XXXX is missing an xcode"
            */
            String oliXcodeMsg = '';
             for(Order_Line_Item__c oli : order.Order_Line_Items__r){
                if(oli.Xcode__c == null){
                    oliXcodeMsg = oliXcodeMsg + oli.Name + ' is missing Xcode,\n';
                }
            }

            if(oliXcodeMsg != ''){
                order.OrderStatus__c = 'Pending Processing';
                order.Pending_Processing_Notes__c = oliXcodeMsg;
                return order;
            }

            /* Following logic for finding payment method (Credit card / Invoice) as invalid oayment method is removed as per S-456725
               By Vikas Menon on 11 April, 2017*/

           /* if(String.isNotEmpty(order.Payment_Method_text__c) ){
                String paymentMethod = order.Payment_Method_text__c.toLowerCase();

                invalidOrderPayment = paymentMethod != 'credit card' && paymentMethod != 'invoice';
            } else {
                invalidOrderPayment = true;
            }*/

            //Next lets test for invalidXcode (is it populated)
            invalidXcode = String.isBlank(order.Account__r.Primary_Xcode__c);

           /* Map<id, Product> mapProducts ;
            if( setProductIds.size()>0 ){
                mapProducts = new Map<id, Product>([select Messaging__c from product where id in :setProductIds]);
            }*/

            //lets check for invalid products (non messaging products)
            //even a single one makes the order invalid
            for(Order_Line_Item__c oli : order.Order_Line_Items__r){
            if(oli.Product__r.ProductCode != 'QUOTE BUNDLE' ){
                if(oli.Product__c != null){
                    if(!oli.Product__r.Messaging__c){
                        invalidProducts = true;
                    }
                } else {
                    invalidProducts = true;
                }
              }else{
              //when ProductCode == 'QUOTE BUNDLE'
                if(oli.OptionId__c != null){
                    if(!oli.OptionId__r.Messaging__c){
                        invalidProducts = true;
                    }
                }/* else {
                    invalidProducts = true;
                }  */

              }
            }

            //check for Agency Order and no Agency I/O
            if(order.Agency__c != null && String.isBlank(order.AgencyIO__c) ){
                if (order.QuoteProposal__r.AgencyIO__c != null){
                    System.debug('^^^ Setting AgencyIO__c from proposal, AgencyIO__c=' + order.QuoteProposal__r.AgencyIO__c);
                    order.AgencyIO__c = order.QuoteProposal__r.AgencyIO__c;
                }
                else {
                    invalidAgencyIO = true;
                }
            }


             /* I-207877 >> if the orders recordtype is credit we set the order status to Sent To
               verification and ignore the rest of the checks that we make in this class */
            if(order.RecordTypeId == Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Credit').getRecordTypeId()) {
                order.OrderStatus__c = 'Sent To Verification';
                return order;
            }

            //time to check for contact phone numbers - long block of annoying if statements
            if(order.AgencyBillingContact__c != null && String.isBlank(order.AgencyBillingContact__r.phone)){
                invalidContactPhone = true;
            }
            if(order.BillingContact__c != null && String.isBlank(order.BillingContact__r.phone)){
                invalidContactPhone = true;
            }
            if(order.Contact__c != null && String.isBlank(order.Contact__r.phone)){
                invalidContactPhone = true;
            }
            if(order.Contact_for_Training__c != null && String.isBlank(order.Contact_for_Training__r.phone)){
                invalidContactPhone = true;
            }
            if(order.Posting_Contact__c != null && String.isBlank(order.Posting_Contact__r.phone)){
                invalidContactPhone = true;
            }
            if(order.PrContact__c != null && String.isBlank(order.PrContact__r.phone)){
                invalidContactPhone = true;
            }
            if(order.Primary_Contact__c != null && String.isBlank(order.Primary_Contact__r.phone)){
                invalidContactPhone = true;
            }
            if(order.Send_Welcome_Letter_to__c != null && String.isBlank(order.Send_Welcome_Letter_to__r.phone)){
                invalidContactPhone = true;
            }
            if(order.ShippingContact__c != null && String.isBlank(order.ShippingContact__r.phone)){
                invalidContactPhone = true;
            }

            /*Sylvester A (Appirio) 4/13/16 - I-199213
             * Check if order's account requires PO
            */
            if(order.Account__r.PORequired__c == true && String.isEmpty(order.CustomerPO__c)){
                poRequired = true;
            }
            /*ASuchanek 12/21/16 S-445889 Set Pending Processing also for NSSA Custom Duration */
            if(order.QuoteProposal__r.APTPS_Manual_NSSA_Type__c == 'Custom Duration') {
                invalidNSSAType = true;
                pendingProcNotes = pendingProcNotes + 'NSSA Custom Duration; ';
            }

            //now we will check if any of those are true, if so
            // set the order status to pending processing and return
            if(invalidOrderPayment
                || invalidXcode || invalidProducts || invalidAgencyIO || poRequired || invalidContactPhone || invalidNSSAType){
                //JFreese Appirio 4/12/17 S-473744
                if (invalidOrderPayment) pendingProcNotes += 'invalidOrderPayment='+invalidOrderPayment+', ';
                if (invalidXcode) pendingProcNotes += 'invalidXcode='+invalidXcode+', ';
                if (invalidProducts) pendingProcNotes += 'invalidProducts='+invalidProducts+', ';
                if (invalidAgencyIO) pendingProcNotes += 'invalidAgencyIO='+invalidAgencyIO+', ';
                if (poRequired) pendingProcNotes += 'poRequired='+poRequired+', ';
                if (invalidContactPhone) pendingProcNotes += 'invalidContactPhone='+invalidContactPhone+', ';
                if (invalidNSSAType) pendingProcNotes += 'invalidNSSAType='+invalidNSSAType+', ';
                pendingProcNotes = pendingProcNotes.left(pendingProcNotes.length() - 2);
                System.debug('^^^ Order ID=' + order.Id + ', Pending_Processing_Notes__c='+pendingProcNotes);
                order.OrderStatus__c = 'Pending Processing';
                //JFreese Appirio 5/11/17 S-483688 crop messages which are too long (discovered in S-483688)
                if (pendingProcNotes.length() > 255) pendingProcNotes = pendingProcNotes.left(255);
                order.Pending_Processing_Notes__c = pendingProcNotes;
                return order;
            } else {
                //Now it is time to check if this is a credit card payment, if so we then need to check
                //if paypal was authorized, if true then we mark it as Paid in Full, otherwise it's Pending processsing
                //and if it isn't a credit card, then we mark it Sent to Verification
                if(order.Payment_Method_text__c.toLowerCase() == 'credit card'){
                    //Check the Paypal Result Messge:
                    if(order.QuoteProposal__r.PaypalResultMessage__c == 'Approved'){
                        order.OrderStatus__c = 'Paid in Full';
                       // order.Payment_Method_text__c = 'Credit Card';
                        //order.Payment_Term_text__c = 'Immediate';
                        //order.Payment_Frequency__c= 'Single Payment';
                    } else {
                        order.OrderStatus__c = 'Pending Processing';
                        order.Pending_Processing_Notes__c = 'Credit Card Details needed from the customer';
                    }
                } else {
                    order.OrderStatus__c = 'Sent To Verification';
                }
                System.debug('^^^ Order ID=' + order.Id + ', order.Payment_Method_text__c=' + order.Payment_Method_text__c + ', order.QuoteProposal__r.PaypalResultMessage__c = ' + order.QuoteProposal__r.PaypalResultMessage__c);
                return order;
            }
        }



    public boolean isValidPicklistValuesOnOrder(Order__c order){

            boolean isValid = false;
            System.debug('===#####=='+order.PrimarySalesRep__r.Combined_Region__c+'==='+order.PrimarySalesRep__r.Position_Organization__c+'==='+order.PrimarySalesRep__r.PositionSalesChannel__c+'==='+order.QuoteProposal__r.Selling_Country__c);
            for(Sales_Channel_Cross_Reference__c obj :[ Select Id, Combined_Region__c, Position_Organization__c,
                                                        Position_Sales_Channel__c, Selling_Country__c from
                                                        Sales_Channel_Cross_Reference__c Where
                                                        (Combined_Region__c = :order.PrimarySalesRep__r.Combined_Region__c OR Combined_Region__c = null)
                                                        and (Position_Organization__c = :order.PrimarySalesRep__r.Position_Organization__c OR Position_Organization__c = null)
                                                        and (Position_Sales_Channel__c = :order.PrimarySalesRep__r.PositionSalesChannel__c OR Position_Sales_Channel__c = null)
                                                        and (Selling_Country__c = :order.QuoteProposal__r.Selling_Country__c OR Selling_Country__c = null) LIMIT 1]){
                isValid = true;
            }
            return isValid;
    }



}