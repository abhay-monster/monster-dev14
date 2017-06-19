/**
** 23 JUL 2015 JFreese Appirio - update for I-172894 Adjustment functionality not working in QA org
**/

global class BizAppsSiteModel {
    final static String CLASSNAME = '\n\n**** BizAppsSiteModel .METHODNAME()';
    public static Integer OLIcount = 0; // Total count of OLI for the order
    public static Integer countOLI = 0; // Total count of OLI processed
    public static String packMsg = '';
    public static List<Order_Line_Item__c> oliToBeUpdated = new Order_Line_Item__c[]{};
    public static List<LicenseID__c> lisenseToBeInserted = new LicenseID__c[]{};

    //Prashant
    Public static Map<id,LicenseID__c> newLicenseMap = new Map<id,LicenseID__c>();
    //End

    global class SubmitOrderException extends Exception {
        public integer ResultCode {get;set;}
        public string ResultDescription {get;set;}
        public SubmitOrderException(integer resultCode, string resultDescription) {
            this.ResultCode = resultCode;
            this.ResultDescription = resultDescription;
            this.setMessage('(' + resultCode+') ' + resultDescription);
        }
    }
    webservice static String ProcessCreditInventory(Id pOrderId){
        system.debug('\n\n**** Inside BizAppsSiteModel.ProcessCreditInventory()\n\n');
        String output = '';

        Id CreditOrderRecordType = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Credit');
     //     Id rebillOrderRecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Rebill Order').getRecordTypeId();

        Order__c CreditOrder = [
            SELECT Id, RecordTypeId, Name, OrderStatus__c,CreditRequest__c,Organization__c,AccountOrganization__c,
            (
                SELECT Id, Name, Quantity2__c,

                CreditRequestLineItem__c,
                CreditRequestLineItem__r.Order_Line_Item__c,
                CreditRequestLineItem__r.CreditCondition__c,
                CreditRequestLineItem__r.CreditType__c
                FROM Order_Line_Items__r
            )
            FROM Order__c WHERE Id = :pOrderId
        ];

      // Order__c rebillOrder = [SELECT Id, OrderStatus__c, CreditRequest__c FROM Order__c WHERE CreditRequest__c  =:CreditOrder.CreditRequest__c AND RecordTypeId =: rebillOrderRecordTypeId limit 1];

        if(CreditOrder.RecordTypeId != CreditOrderRecordType || CreditOrder.OrderStatus__c != 'Sent To Verification'){
            system.debug('\n\nNo Credit Order for integration. \n\n');
            return '';
        }

        system.debug('\n\nProcessing ' + CreditOrder.Name + ' for Site Inventory Credit.\n\n');

        //Original Order Line Item ID to Credit Order Line Item
        map<Id, Order_Line_Item__c> FullLineItems = new map<Id, Order_Line_Item__c>();
        map<Id, Order_Line_Item__c> PartialLineItems = new map<Id, Order_Line_Item__c>();
        set<Id> OriginalLineItemIdSet = new set<Id>();
        set<Id> InventoryCreditRequestLineIdSet = new set<Id>();
        for(Order_Line_Item__c creditLine : CreditOrder.Order_Line_Items__r){

            if(creditLine.CreditRequestLineItem__r.Order_Line_Item__c != null){
                OriginalLineItemIdSet.add(creditLine.CreditRequestLineItem__r.Order_Line_Item__c);
                if(creditLine.CreditRequestLineItem__r.CreditCondition__c == 'Full'){
                    FullLineItems.put(creditLine.CreditRequestLineItem__r.Order_Line_Item__c, creditLine);
                }else if(creditLine.CreditRequestLineItem__r.CreditCondition__c == 'Partial' && creditLine.CreditRequestLineItem__r.CreditType__c == 'Inventory'){
                    PartialLineItems.put(creditLine.CreditRequestLineItem__r.Order_Line_Item__c, creditLine);
                    InventoryCreditRequestLineIdSet.add(creditLine.CreditRequestLineItem__c);
                }
            }
        }

        map<Id, Credit_Request_License_ID__c> UsedPartialOriginalLicenseIdToCreditLicense = new map<Id, Credit_Request_License_ID__c>();
        Credit_Request_License_ID__c[] creditLicenseList = [SELECT LicenseID__c, CreditQuantity__c FROM Credit_Request_License_ID__c WHERE CreditRequestLineItem__c IN :InventoryCreditRequestLineIdSet];
        for(Credit_Request_License_ID__c creditLicense : creditLicenseList){
            UsedPartialOriginalLicenseIdToCreditLicense.put(creditLicense.LicenseID__c, creditLicense);
        }

        map<Id, Order_Line_Item__c> OriginalOrderLineItems = new map<Id, Order_Line_Item__c>([
                SELECT
                    Id,
                    Name,
                    Order__c,
                    ExpireAll__c,
                    Order__r.SiteDestination__c,
                    AdjustmentReason__c,
                    AdjustmentType__c,
                    TrackingTicketID__c,
                    Notes__c,
                    Contract_Duration__c,
                    Has_Auto_Refresh__c,
                    Has_Bolding__c,
                    Job_Board_ID__c,
                    License_Provision_Method__c,
                    PostingDuration__c,
                    PostingLocationGroup__c,
                    PostingLocationGroupID__c,
                    Refresh_Interval__c,
                    Tier_Id__c,
                    Unlimited_Job_Postings__c,
                    Order__r.OrderStatus__c,
                    Status__c,
                    Result__c,
                    ResultDescription__c,
                    Quantity2__c,
                    (SELECT
                        Id,
                        Name,
                        OrderLineItem__c,
                        TransferAmount__c,
                        Xcode__c,
                        Xcode__r.IntegrationXcode__c,
                        OrderLineItem__r.Quantity2__c,
                        AvailableInventory__c,
                        SiteLicenseID__c,
                        AdditionalActions__c,
                        LicenseID__c
                    FROM License_IDs__r)
                FROM Order_Line_Item__c WHERE Id IN :OriginalLineItemIdSet
            ]);

        if(!FullLineItems.isEmpty()){
            output += ProcessFullCredit(FullLineItems, OriginalOrderLineItems);
        }
        if(!PartialLineItems.isEmpty()){
            output += ProcessPartialCredit(PartialLineItems, OriginalOrderLineItems, UsedPartialOriginalLicenseIdToCreditLicense);
        }
        system.debug('OutPut!!!' + output);
        //if it is a success then we want to update the credit order line items and credit order results with success or error
        List<Order_Line_Item__c> oliToUpdate = new List<Order_Line_Item__c>();
        For(Order_Line_Item__c oli : [Select Id, Result__c, ResultDescription__c from Order_Line_Item__c where Order__c = :CreditOrder.Id]){
            if(output.contains('Success')){
                oli.Result__c = '0';
                oli.ResultDescription__c = 'Success';
            } else{
                oli.Result__c = 'Error';
            }   oli.ResultDescription__c = 'See Original Order for details on Errors';

            oliToUpdate.add(oli);
        }

        //now lets update the Order with Success or failure
        Order__c creditOrderToUpdate = new Order__c(Id=pOrderId);
        if(output.contains('Success')){
            creditOrderToUpdate.SiteResult__c = 'Success';
            creditOrderToUpdate.SiteResultDescription__c = 'Success';
        } else{
            creditOrderToUpdate.SiteResult__c = 'Error';
            creditOrderToUpdate.SiteResultDescription__c = 'See Original Order for details on Errors';
        }

        if(CreditOrder.AccountOrganization__c != 'Europe'){
            creditOrderToUpdate.OrderStatus__c='Verified';
        }

        update creditOrderToUpdate;

        return output;
    }

    private static String ProcessFullCredit(map<Id, Order_Line_Item__c> pOriginalOrderLineIdToCreditLineMap, map<Id, Order_Line_Item__c> pOriginalOrderLineItems){
        system.debug('\n\n**** Inside BizAppsSiteModel.ProcessFullCredit()\n\n');
        String output = '';
        try{
            map<Id, Order_Line_Item__c> LineItemsToExpire = new map<Id, Order_Line_Item__c>();
            for(Order_Line_Item__c origLineItem : pOriginalOrderLineItems.values()){
                if(pOriginalOrderLineIdToCreditLineMap.containsKey(origLineItem.Id)){
                    LineItemsToExpire.put(origLineItem.Id, origLineItem);
                }
            }

            if(!LineItemsToExpire.isEmpty()){
                output = ProcessTerminateAllLicenses(LineItemsToExpire, false); //T-486761
            }
        }catch(Exception e){
            throw BaseApplicationException.NewException('ProcessFullCredit', 'Full Credit error: ' + e);
        }
        return output;
    }

    private static String ProcessPartialCredit(map<Id, Order_Line_Item__c> pOriginalOrderLineIdToCreditLineMap, map<Id, Order_Line_Item__c> pOriginalOrderLineItems, map<Id, Credit_Request_License_ID__c> pUsedPartialOriginalLicenseIdToCreditLicense){
        system.debug('\n\n**** Inside BizAppsSiteModel.ProcessPartialCredit()\n\n');
        String output = '';
        try{
            map<Id, TransferAndAdjustmentProcessCC.LineWrapList[]> pLineWraps = new map<Id, TransferAndAdjustmentProcessCC.LineWrapList[]>();
            map<Id, Order_Line_Item__c> pOrderLineItemMap = new map<Id, Order_Line_Item__c>();
            System.debug('pOriginalOrderLineIdToCreditLineMap'+pOriginalOrderLineIdToCreditLineMap);
            for(Order_Line_Item__c orinalOLI : pOriginalOrderLineItems.values()){
                System.debug('Original Odli:'+orinalOLI.Id);
                if(pOriginalOrderLineIdToCreditLineMap.containsKey(orinalOLI.Id)){

                    pOrderLineItemMap.put(orinalOLI.Id, orinalOLI);
                    orinalOLI.AdjustmentType__c = 'Decrease';
                    orinalOLI.Notes__c = 'Partial Inventory Credit Transaction.';
                    pLineWraps.put(orinalOLI.Id, new TransferAndAdjustmentProcessCC.LineWrapList[]{});
                    for(LicenseID__c originalLicense : orinalOLI.License_IDs__r){
                        //if(pUsedPartialOriginalLicenseIdToCreditLicense.containsKey(originalLicense.Id)){
                            TransferAndAdjustmentProcessCC.LineWrapList wrapList = new TransferAndAdjustmentProcessCC.LineWrapList();
                            wrapList.ParentLicenseId = originalLicense;

                            Integer amount = Integer.valueOf(pOriginalOrderLineIdToCreditLineMap.get(orinalOLI.Id).Quantity2__c);
                            TransferAndAdjustmentProcessCC.LineWrap wrap = new TransferAndAdjustmentProcessCC.LineWrap();
                            wrap.Amount = amount == null ? 0 : amount;
                            wrapList.LineWraps = new TransferAndAdjustmentProcessCC.LineWrap[]{wrap};
                            pLineWraps.get(orinalOLI.Id).add(wrapList);
                       // }
                    }
                }
            }

            String[] resultList = BizAppsSiteModel.AdjustmentIntegrationProcess(pLineWraps, pOrderLineItemMap);
            for(String str : resultList){
                output += str + '\n\n';
            }
        }catch(Exception e){
            throw BaseApplicationException.NewException('ProcessPartialCredit', 'Partial Credit error: ' + e);
        }
        return output;
    }

    webservice static String TerminateAllLicenses(Id pOrderLineItemId){
        system.debug('\n\n**** Inside BizAppsSiteModel.TerminateAllLicenses()\n\n');
        String output = 'Termination Error: Internal error occured.';
        try{
            Order_Line_Item__c OrderLine = [
                SELECT Id, ExpireAll__c, ResultDescription__c, Result__c,
                    (SELECT Id, Name, SiteLicenseID__c, ItemResult__c, QuantityTerminated__c, CompanyXcode__c, AvailableInventory__c, OrderLineItem__c,LicenseID__c FROM License_IDs__r)
                FROM Order_Line_Item__c
                WHERE Id = :pOrderLineItemId
            ];

            if(OrderLine == null){
                output = '\n\nNo order line item for TerminateAllLicenses processing.\n\n';
                system.debug(output);
                return output;
            }
            map<Id, Order_Line_Item__c> pOrderLineItems = new map<Id, Order_Line_Item__c>();
            pOrderLineItems.put(OrderLine.Id, OrderLine);
            return ProcessTerminateAllLicenses(pOrderLineItems, true);
        }catch(Exception e){
            system.debug('\n\nError: ' + e + '\n\nTrace: ' + e.getStackTraceString() + '\n\n');
            output = 'Internal Error: ' + e;
        }
        return output;
    }

    webservice static String TerminateAllLicenses2(Id pOrderLineItemId, Boolean ExpireAll){
        system.debug('\n\n**** Inside BizAppsSiteModel.TerminateAllLicenses2()\n\n');
        String output = 'Termination Error: Internal error occured.';
        try{
            Order_Line_Item__c OrderLine = [
                SELECT Id, ExpireAll__c, ResultDescription__c, Result__c,
                    (SELECT Id, Name, SiteLicenseID__c, ItemResult__c, QuantityTerminated__c, CompanyXcode__c, AvailableInventory__c, OrderLineItem__c,LicenseID__c FROM License_IDs__r)
                FROM Order_Line_Item__c
                WHERE Id = :pOrderLineItemId
            ];

            if(OrderLine == null){
                output = '\n\nNo order line item for TerminateAllLicenses processing.\n\n';
                system.debug(output);
                return output;
            }
            map<Id, Order_Line_Item__c> pOrderLineItems = new map<Id, Order_Line_Item__c>();
            pOrderLineItems.put(OrderLine.Id, OrderLine);
            return ProcessTerminateAllLicenses(pOrderLineItems, ExpireAll);
        }catch(Exception e){
            system.debug('\n\nError: ' + e + '\n\nTrace: ' + e.getStackTraceString() + '\n\n');
            output = 'Internal Error: ' + e;
        }
        return output;
    }

    private static String ProcessTerminateAllLicenses(map<Id, Order_Line_Item__c> pOrderLineItems, Boolean ExpireAll){
        system.debug('\n\n**** Inside BizAppsSiteModel.ProcessTerminateAllLicenses()\n\n');

        String output = '';
        try{

            v3_monsterBizappsSiterouterSiterouterws.legacy connection = new v3_monsterBizappsSiterouterSiterouterws.legacy();

            // these values are now set by custom settings via Utility George Huene 2015-03-27
            // connection.timeout_x = 120000;
            // connection.endpoint_x = Utility.getWebServiceEnpoint('MonsterBizAppsSiteRouter');

            v3_monsterBizappsSiterouterSiterouterws.TerminateAllLicensesRequest_element request = new v3_monsterBizappsSiterouterSiterouterws.TerminateAllLicensesRequest_element();
            request.ExpireAll = ExpireAll;
            request.Requester = 'Karma';//Has Enum values withouth salesforce.com
            request.ModifyingUserID = UserInfo.getName();
            request.LicenseIDs = new v3_schemasMicrosoftCom200310SerializA.ArrayOfint();
            request.LicenseIDs.int_x = new Integer[]{};

            map<Integer, LicenseID__c> LicenseMap = new map<Integer, LicenseID__c>();
            map<Id, LicenseID__c[]> ParentLicenseIdToChildLicenseList = new map<Id, LicenseID__c[]>();

            for(Order_Line_Item__c OrderLine : pOrderLineItems.values()){
                if(OrderLine.License_IDs__r != null && !OrderLine.License_IDs__r.isEmpty()){
                    for(LicenseID__c license : OrderLine.License_IDs__r){
                        if(license.SiteLicenseID__c != null){
                            if(license.LicenseID__c == null){//send only the parent License, because it will also terminate all related licenses
                                request.LicenseIDs.int_x.add(Integer.valueOf(license.SiteLicenseID__c));
                                LicenseMap.put(Integer.valueOf(license.SiteLicenseID__c), license);
                            }else{
                                if(!ParentLicenseIdToChildLicenseList.containsKey(license.LicenseID__c)){
                                    ParentLicenseIdToChildLicenseList.put(license.LicenseID__c, new LicenseID__c[]{});
                                }
                                ParentLicenseIdToChildLicenseList.get(license.LicenseID__c).add(license);
                            }
                        }
                    }
                }
            }

            system.debug('Request!' + request);
            v3_monsterBizappsSiterouterSiterouterws.TerminateAllLicensesResult_element terminateResult = connection.TerminateAllLicensesOptimized(request);

            system.debug('\n\nTerminate All License Response: \n\n' + terminateResult + '\n\n');


            map<Id, String> OrderLineResultDetail = new map<Id, String>();
            for(Order_Line_Item__c OrderLine : pOrderLineItems.values()){
                OrderLine.Result__c = 'Terminate: ' + terminateResult.ResponseCode;
                OrderLineResultDetail.put(OrderLine.Id, '');
                if (terminateResult.ResponseCode != 'Success'){
                    OutPut=terminateResult.ResponseCode;
                }
            }

            if(terminateResult.TerminateAllLicensesResponseItems != null){
                if(terminateResult.TerminateAllLicensesResponseItems.TerminateAllLicensesResponseItem != null && terminateResult.TerminateAllLicensesResponseItems.TerminateAllLicensesResponseItem.size() > 0){
                    map<Id, LicenseID__c> licensesToBeUpdated = new map<Id, LicenseID__c>();
                    for(v3_monsterBizappsSiterouterSiterouterws.TerminateAllLicensesResponseItem item : terminateResult.TerminateAllLicensesResponseItems.TerminateAllLicensesResponseItem){
                        LicenseID__c currentLicense = LicenseMap.get(item.RequestedTerminationLicenseID);
                        if(currentLicense != null){
                            if(item.TerminatedLicenses != null && item.TerminatedLicenses.TerminatedLicense.size() > 0){
                                for(v3_monsterBizappsSiterouterSiterouterws.TerminatedLicense licenseItem : item.TerminatedLicenses.TerminatedLicense){

                                    if(licenseItem.ItemResult != null){
                                        if(OrderLineResultDetail.containsKey(currentLicense.OrderLineItem__c)){
                                            String currentResultDetail = OrderLineResultDetail.remove(currentLicense.OrderLineItem__c);
                                            currentResultDetail += '\nLicense: ' + currentLicense.Name;
                                            currentResultDetail += '\nResult: ' + licenseItem.ItemResult.Result;
                                            currentResultDetail += '\nDetail: ' + licenseItem.ItemResult.ResultDescription + '\n';
                                            OrderLineResultDetail.put(currentLicense.OrderLineItem__c, currentResultDetail);
                                        }
                                        currentLicense.IntegrationStatus__c = 'Site Result Code: ' + licenseItem.ItemResult.Result;
                                        currentLicense.IntegrationDetail__c = licenseItem.ItemResult.ResultDescription;

                                        if(licenseItem.ItemResult.Result == 0){
                                            Integer Terminated = licenseItem.QuantityTerminated == null ? 0 : Integer.valueOf(licenseItem.QuantityTerminated);
                                            Integer PrevAvailable = currentLicense.AvailableInventory__c == null ? 0 : Integer.valueOf(currentLicense.AvailableInventory__c);
                                            Integer Available = PrevAvailable - Terminated;
                                            currentLicense.QuantityTerminated__c = Terminated;
                                            currentLicense.AvailableInventory__c = Available < 0 ? 0 : Available;
                                            if(ParentLicenseIdToChildLicenseList.containsKey(currentLicense.Id)){
                                                for(LicenseID__c childLicenseId : ParentLicenseIdToChildLicenseList.get(currentLicense.Id)){
                                                    childLicenseId.AvailableInventory__c = 0;
                                                    if(!licensesToBeUpdated.containsKey(childLicenseId.Id)){
                                                        licensesToBeUpdated.put(childLicenseId.Id, childLicenseId);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    if(!licensesToBeUpdated.containsKey(currentLicense.Id)){
                                        licensesToBeUpdated.put(currentLicense.Id, currentLicense);
                                    }
                                }
                            }
                        }
                    }

                    update licensesToBeUpdated.values();
                }
            }

            Order_Line_Item__c[] OLIToUpdate = new Order_Line_Item__c[]{};
            if(!OrderLineResultDetail.isEmpty()){
                for(Order_Line_Item__c OrderLine : pOrderLineItems.values()){
                    if(OrderLineResultDetail.containsKey(OrderLine.Id)){
                        OrderLine.ResultDescription__c = OrderLineResultDetail.get(OrderLine.Id);
                        OLIToUpdate.add(OrderLine);
                        system.debug('OrderLine Results ' + OrderLine.Result__c + ' ' + OrderLine.ResultDescription__c);
                    }
                }
            }

            update OLIToUpdate;

            if (output == ''){
                output = 'Success';
            }
        }catch(Exception e){
            system.debug('\n\nError: ' + e + '\n\nTrace: ' + e.getStackTraceString() + '\n\n');
            output = 'Internal Error: ' + e;
        }
        return output;
    }

    public static String TerminateAllLicenses(map<Id, Order_Line_Item__c> pOrderLineItems, Boolean ExpireAll){
        system.debug('\n\n**** Inside BizAppsSiteModel.ProcessTerminateAllLicenses()\n\n');

        String output = '';
        try{

            v3_monsterBizappsSiterouterSiterouterws.legacy connection = new v3_monsterBizappsSiterouterSiterouterws.legacy();

            // these values are now set by custom settings via Utility George Huene 2015-03-27
            // connection.timeout_x = 120000;
            // connection.endpoint_x = Utility.getWebServiceEnpoint('MonsterBizAppsSiteRouter');

            v3_monsterBizappsSiterouterSiterouterws.TerminateAllLicensesRequest_element request = new v3_monsterBizappsSiterouterSiterouterws.TerminateAllLicensesRequest_element();
            request.ExpireAll = ExpireAll;
            request.Requester = 'Karma';//Has Enum values withouth salesforce.com
            request.ModifyingUserID = UserInfo.getName();
            request.LicenseIDs = new v3_schemasMicrosoftCom200310SerializA.ArrayOfint();
            request.LicenseIDs.int_x = new Integer[]{};

            map<Integer, LicenseID__c> LicenseMap = new map<Integer, LicenseID__c>();
            map<Id, LicenseID__c[]> ParentLicenseIdToChildLicenseList = new map<Id, LicenseID__c[]>();

            for(Order_Line_Item__c OrderLine : pOrderLineItems.values()){
                if(OrderLine.License_IDs__r != null && !OrderLine.License_IDs__r.isEmpty()){
                    for(LicenseID__c license : OrderLine.License_IDs__r){
                        if(license.SiteLicenseID__c != null){
                            if(license.LicenseID__c == null){//send only the parent License, because it will also terminate all related licenses
                                request.LicenseIDs.int_x.add(Integer.valueOf(license.SiteLicenseID__c));
                                LicenseMap.put(Integer.valueOf(license.SiteLicenseID__c), license);
                            }else{
                                if(!ParentLicenseIdToChildLicenseList.containsKey(license.LicenseID__c)){
                                    ParentLicenseIdToChildLicenseList.put(license.LicenseID__c, new LicenseID__c[]{});
                                }
                                ParentLicenseIdToChildLicenseList.get(license.LicenseID__c).add(license);
                            }
                        }
                    }
                }
            }

            v3_monsterBizappsSiterouterSiterouterws.TerminateAllLicensesResult_element terminateResult = connection.TerminateAllLicensesOptimized(request);

            system.debug('\n\nTerminate All License Response: \n\n' + terminateResult + '\n\n');


            map<Id, String> OrderLineResultDetail = new map<Id, String>();
            for(Order_Line_Item__c OrderLine : pOrderLineItems.values()){
                OrderLine.Result__c = 'Terminate: ' + terminateResult.ResponseCode;
                OrderLineResultDetail.put(OrderLine.Id, '');
            }

            if(terminateResult.TerminateAllLicensesResponseItems != null){
                if(terminateResult.TerminateAllLicensesResponseItems.TerminateAllLicensesResponseItem != null && terminateResult.TerminateAllLicensesResponseItems.TerminateAllLicensesResponseItem.size() > 0){
                    map<Id, LicenseID__c> licensesToBeUpdated = new map<Id, LicenseID__c>();
                    for(v3_monsterBizappsSiterouterSiterouterws.TerminateAllLicensesResponseItem item : terminateResult.TerminateAllLicensesResponseItems.TerminateAllLicensesResponseItem){
                        LicenseID__c currentLicense = LicenseMap.get(item.RequestedTerminationLicenseID);
                        if(currentLicense != null){
                            if(item.TerminatedLicenses != null && item.TerminatedLicenses.TerminatedLicense.size() > 0){
                                for(v3_monsterBizappsSiterouterSiterouterws.TerminatedLicense licenseItem : item.TerminatedLicenses.TerminatedLicense){

                                    if(licenseItem.ItemResult != null){
                                        if(OrderLineResultDetail.containsKey(currentLicense.OrderLineItem__c)){
                                            String currentResultDetail = OrderLineResultDetail.remove(currentLicense.OrderLineItem__c);
                                            currentResultDetail += '\nLicense: ' + currentLicense.Name;
                                            currentResultDetail += '\nResult: ' + licenseItem.ItemResult.Result;
                                            currentResultDetail += '\nDetail: ' + licenseItem.ItemResult.ResultDescription + '\n';
                                            OrderLineResultDetail.put(currentLicense.OrderLineItem__c, currentResultDetail);
                                        }
                                        currentLicense.IntegrationStatus__c = 'Site Result Code: ' + licenseItem.ItemResult.Result;
                                        currentLicense.IntegrationDetail__c = licenseItem.ItemResult.ResultDescription;

                                        if(licenseItem.ItemResult.Result == 0){
                                            Integer Terminated = licenseItem.QuantityTerminated == null ? 0 : Integer.valueOf(licenseItem.QuantityTerminated);
                                            Integer PrevAvailable = currentLicense.AvailableInventory__c == null ? 0 : Integer.valueOf(currentLicense.AvailableInventory__c);
                                            Integer Available = PrevAvailable - Terminated;
                                            currentLicense.QuantityTerminated__c = Terminated;
                                            currentLicense.AvailableInventory__c = Available < 0 ? 0 : Available;
                                            if(ParentLicenseIdToChildLicenseList.containsKey(currentLicense.Id)){
                                                for(LicenseID__c childLicenseId : ParentLicenseIdToChildLicenseList.get(currentLicense.Id)){
                                                    childLicenseId.AvailableInventory__c = 0;
                                                    if(!licensesToBeUpdated.containsKey(childLicenseId.Id)){
                                                        licensesToBeUpdated.put(childLicenseId.Id, childLicenseId);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    if(!licensesToBeUpdated.containsKey(currentLicense.Id)){
                                        licensesToBeUpdated.put(currentLicense.Id, currentLicense);
                                    }
                                }
                            }
                        }
                    }

                    update licensesToBeUpdated.values();
                }
            }

            Order_Line_Item__c[] OLIToUpdate = new Order_Line_Item__c[]{};
            if(!OrderLineResultDetail.isEmpty()){
                for(Order_Line_Item__c OrderLine : pOrderLineItems.values()){
                    if(OrderLineResultDetail.containsKey(OrderLine.Id)){
                        OrderLine.ResultDescription__c = OrderLineResultDetail.get(OrderLine.Id);
                        OLIToUpdate.add(OrderLine);
                    }
                }
            }

            update OLIToUpdate;

            output = 'Success';
        }catch(Exception e){
            system.debug('\n\nError: ' + e + '\n\nTrace: ' + e.getStackTraceString() + '\n\n');
            output = 'Internal Error: ' + e;
        }
        return output;
    }
    /* // comment out 12.11.2014 by Andre merged into autoTriggerVerification method instead
    public static void processPaidInFull(Map<Id,Order__c> oldOrders, Map<Id,Order__c> newOrders){
        System.debug('Processing PaidInFull');
        for (Order__c order:newOrders.values()){
            if (order.OrderStatus__c=='Paid in Full' && oldOrders.get(order.id).OrderStatus__c!=order.OrderStatus__c){
                SendOrderToSiteAsync(order.id);
            }
        }
    }*/
    /**
     * @author Cloudsherpas
     * @date 12.4.14
     * @description method to call the SendOrderToSiteAsync method based on the criteria from auto verification formula field.
     * @param oldOrders - a Map of Order records old values
     * @param newOrders - a Map of Order records new values
     **/
    public static void autoTriggerVerification(Map<Id,Order__c> oldOrders, Map<Id,Order__c> newOrders){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','autoTriggerVerification');
        system.debug('**** Inside BizAppsSiteModel.autoTriggerVerification()');
        if(System.isFuture()){
            system.debug('Exiting BizAppsSiteModel.autoTriggerVerification() as it is being called from a future method');
            return;
        }
        Logger.push(METHODNAME, 'Order__c');
        system.debug('---autoTriggerVerification step1');

        List<Order__c> specialCreditAndRebills = new List<Order__c>();
        for (Order__c order:newOrders.values()){
            system.debug('---autoTriggerVerification step3');
            // when order status changes and the auto-verification flag is set to true, perform the appropriate IWS callout
            // the check to see if order status has changed is to ensure that this code is not refired continuosly if an error occurs
            if ((oldOrders.get(order.id).OrderStatus__c!=order.OrderStatus__c) && (order.Auto_Trigger_Verification__c )){
                system.debug('Passed Condition and will do a future callout to SendOrderToSiteAsync.  Old OrderStatus__c=' + oldOrders.get(order.id).OrderStatus__c + ', OrderStatus__c=' + order.OrderStatus__c);

                 //6/20/16 - Sylvester Agyen (Appirio) - I-222025 - Prevent Paid in Full orders from going through verfication again
                if(order.OrderStatus__c == 'Paid in Full' && oldOrders.get(order.id).OrderStatus__c == 'Verified' ){
                    system.debug('paid in full stopped');
                    continue;
                }

                //Jeff L - new logic needed for some credit and rebill scenarios, the are not sent to SITe
                system.debug('OrderCreditScenario ' + order.CreditScenario__c);
                if(order.CreditScenario__c == 'Credit and Rebill'){
                    system.debug('OrderCreditReason ' + order.Credit_Reason__c);
                    if(isSentToSite(order.Credit_Reason__c)){
                        system.debug('1 - CreditScenario__c = ' + order.CreditScenario__c + ' Calling Future VerifyOrder(' + order.id + ',' + order.is_credit__c+ ')');
                        VerifyOrder(order.id,order.is_credit__c); //if we are able to send this to site, then lets verify

                    } else {
                        specialCreditAndRebills.add(order);
                        system.debug('InsideSpecialCreditAndRebills');
                    }
                } else {
                    //Not a credit and rebill, so we don't have to do a seperate check
                    system.debug('2 - CreditScenario__c = ' + order.CreditScenario__c + ' Calling Future VerifyOrder(' + order.id + ',' + order.is_credit__c+ ')');
                    VerifyOrder(order.id,order.is_credit__c);
                }
            } else {
                system.debug('Failed Condition, no future callout to SendOrderToSiteAsync.  Old OrderStatus__c=' + oldOrders.get(order.id).OrderStatus__c + ', OrderStatus__c=' + order.OrderStatus__c);
            }
        }
        system.debug('---autoTriggerVerification step5');
        //do our special logic for Credit and Rebills that do not need to be sent to site
        if(!specialCreditAndRebills.isEmpty()){
            assignLicensesToCreditAndRebill(specialCreditAndRebills);
        }
        Logger.pop();
    }

    /**
     * @author Appirio
     * @date 11.12.15
     * @description method to call the VerifyOrder method based on the criteria from auto verification formula field.
     *              This specifically is used inside of CreditRequestTriggerHelper
     * @param porders - a list of orders that need to be sent to SITE etc
     **/
    public static void autoTriggerVerificationForCredit(List<Order__c> porders){
        system.debug('**** Inside BizAppsSiteModel.autoTriggerVerificationForCredit()');
        List<Order__c> specialCreditAndRebills = new List<Order__c>();
        for(Order__c order : pOrders){
            //Jeff L - new logic needed for some credit and rebill scenarios, the are not sent to SITe
            system.debug('TEST order ' + order.Id);
            system.debug('OrderCreditScenario ' + order.CreditScenario__c);
            system.debug('OrderCreditReason ' + order.Credit_Reason__c);
            if(order.CreditScenario__c == 'Credit and Rebill'){
                if(isSentToSite(order.Credit_Reason__c)){
                    system.debug('3 - CreditScenario__c = ' + order.CreditScenario__c + ' Calling Future VerifyOrder(' + order.id + ',' + order.is_credit__c+ ')');
                    VerifyOrder(order.id,order.is_credit__c); //if we are able to send this to site, then lets verify
                } else {
                    system.debug('InsideSpecialCreditAndRebills');
                    specialCreditAndRebills.add(order);
                }
            } else {
                //Not a credit and rebill, so we don't have to do a seperate check
                system.debug('4 - CreditScenario__c = ' + order.CreditScenario__c + ' Calling Future VerifyOrder(' + order.id + ',' + order.is_credit__c+ ')');
                    VerifyOrder(order.id,order.is_credit__c);
                }
            }
        //do our special logic for Credit and Rebills that do not need to be sent to site
        if(!specialCreditAndRebills.isEmpty()){
            system.debug('specialCreditAndRebills '+specialCreditAndRebills);
            assignLicensesToCreditAndRebill(specialCreditAndRebills);
        }
    }

    @future(callout=true)
    public static void VerifyOrder(Id pOrderId, boolean isCredit){
        system.debug('**** Inside BizAppsSiteModel.VerifyOrder(' + pOrderId + ',' + isCredit + ')');
        if (isCredit){
            ProcessCreditInventory(pOrderId);
        }
        else {

            Integer numOfLics = 0;
            for(LicenseId__c lic : [SELECT Id, OrderLineItem__r.Order__c from LicenseId__c WHERE OrderLineItem__r.Order__c = :pOrderId]){
                numOfLics++;
            }

            if(numOfLics == 0){
                SendOrderToSite(pOrderId);
            }

            /*Jeff L commented this out - bad logic, if there were 3 order line items we would end up calling
            SendOrderToSite 3 times.
             //AP  I-171591/I-192330
                 system.debug('pOrderId' + pOrderId);
                 Order__c OrderName = [Select Id, Name from Order__c where Id =:pOrderId];
                 List<Order_Line_Item__c> orderLineItems = [Select Id from Order_Line_Item__c where Order__c =:OrderName.Id];
                 for(Order_Line_Item__c  OLILine : orderLineItems)
                 {
                      system.debug('OLILine' + OLILine);
                      List<LicenseID__c> licenseId = [Select Id from LicenseID__c where OrderLineItem__c =:OLILine.Id LIMIT 1];
                      if(licenseId.size() == 0){
                            SendOrderToSite(pOrderId);
                           }

                  }*/
            }
    }

   /*
    * @author George Huene
    * @date 04.09.2015
    * @description method to call from javascript so user get immediate response
    * @param pOrderId - database id for order record
    * @param isCredit - whether or not this order is credit
    */ // added for story 3268
    webservice static String JSVerifyOrder(Id pOrderId, Boolean isCredit)
    {
        if (isCredit){
            return ProcessCreditInventory(pOrderId);
        } else {

            return SendOrderToSite(pOrderId);
        }
    }

    webservice static string SendOrderToSite(Id pOrderId){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','SendOrderToSite');
        Logger.push(METHODNAME, 'Order__c');
        string resultMessage='';
        system.debug('\n\n**** Inside BizAppsSiteModel.SendOrderToSite()\n\n');
             Order__c orderToSubmit = [
                SELECT AccountOrganization__c ,Organization__c , Id, QuoteProposal__c,Name,QuoteProposal__r.Payment_Method1__c,
                    TotalProducts__c,Opportunity__c, Notes__c, Promotions__c, OrderDate__c, SiteDestination__c,
                    SiteChannelID__c,OrderStatus__c,Account__r.Id,Account__r.BillingCountryCode, Account__r.AccountID__c,
                    Account__r.CompanyFraudStatus__c, SiteResult__c, SiteResultDescription__c,CreditCardTransactionResponseCode__c,
                    RecordTypeId, PaypalAuthResultMessage__c, Payment_Method__c, MAPP_Payment_Frequency__c,
                    PaypalAuthReferenceNumber__c,PaypalAuthSecureTokenID__c,Primary_SalesRep_Email__c,Posting_Contact__c,Posting_Contact__r.Name,Posting_Contact_Email__c,
                    (SELECT Id, Name,Xcode_calc__c,xcode_lkp__c,Xcode_Id__c,xcode_lkp__r.xcode__r.name,EndDate__c,
                        IsInventory__c, Product__c, Product__r.Legacy_Product_ID__c,Promotion__c,Product__r.Messaging__c,
                        OptionId__r.Messaging__c, Quantity2__c,StartDate__c,Result__c,ResultDescription__c,Do_Not_Provision__c
                    FROM Order_Line_Items__r
                    /*JFreese Appirio 1/12/17 S-448654 Apply this filter inside submitOrder(*/
                    //Where Do_Not_Provision__c = false
                    )
                    FROM Order__c
                WHERE Id = :pOrderId
            ];
              //List<Order__c>


        system.debug('OrderSubmitcall'+orderToSubmit);
        set<xcodeaccount__c> xcodes = new set<xcodeaccount__c>();
        for (order_line_item__c oli : orderToSubmit.order_line_items__r){
            xcodes.add(oli.xcode_lkp__r);
            system.debug('allxcodes' + oli.xcode_lkp__r);
            OLIcount++; // Total count of OLI for the order
        }

         system.debug('xcodesall' + xcodes);
        //blank out result fields
        orderToSubmit.SiteResult__c = ''; //'Result Code: ' + result.Result;
        orderToSubmit.SiteResultDescription__c ='';// result.ResultDescription;
        boolean hasErrors=false;
        /*JFreese Appirio 1/12/17 S-448654 Include informational message(s) in the SiteResultDescription*/
        countOLI = 0; // Total count of OLI processed
        String srd ='';
        for (xcodeaccount__c xcode:xcodes){
                string xcodeName = xcode!=null ? xcode.xcode__r.name : 'No Xcode';
                try {
                        system.debug('Calling submitOrder (' + orderToSubmit.Id + ', ' + xcodeName + ')');
                        packMsg = '';
                        submitOrder(orderToSubmit, xcode);
                        srd += packMsg;
                        system.debug('Completed call to submitOrder (' + orderToSubmit.Id + ', ' + xcodeName + ')');
                }catch (SubmitOrderException csEx){
                    hasErrors = true;
                    orderToSubmit.SiteResult__c += xcodeName + ' - ' + csEx.resultCode +'\n';
                    srd += packMsg + xcodeName + ' - ' + csEx.resultDescription +'\n';
                    Logger.debugException(csEx,null);
                }catch (Exception ex){
                    hasErrors=true;
                    orderToSubmit.SiteResult__c += xcodeName + ' -  Exception \n';
                    srd += packMsg + xcodeName + ' - ' + ex.getMessage() +'\n\n';
                    Logger.debugException(ex,null);
                }
        }

        //JFreese Appirio 1/12/17 S-448654 Commit any changes we have accumulated
                /*try {
                    update agreementsToUpdate;
                } catch (System.DmlException e) {
                    for (Integer i = 0; i < e.getNumDml(); i++) {
                        thisError += 'ERROR: Agreement '+e.getDmlId(i)+' - '+e.getDmlMessage(i);
                        if (e.getDmlType(i) != null) thisError += ', Status Code: '+e.getDmlType(i);
                        thisError += '<br>';
                    }
                }*/


        if (oliToBeUpdated.size() > 0){
            try{
                system.debug('Updating ' + oliToBeUpdated.size()+' OLIs');
                update oliToBeUpdated;
            /*}catch (Exception ex){
                hasErrors=true;
                orderToSubmit.SiteResult__c += ' DML Exception \n';
                srd += ' ***Failed to Update Line Items*** ' + ex.getMessage() +'\n\n';
                Logger.debugException(ex,null);
            }*/
            } catch (System.DmlException e) {
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    orderToSubmit.SiteResult__c += ' DML Exception \n';
                    srd += ' ***Failed to Update Line Items*** '+e.getDmlId(i)+' - '+e.getDmlMessage(i);
                    if (e.getDmlType(i) != null) srd += ', Status Code: '+e.getDmlType(i);
                    srd += '\n\n';
                    Logger.debugException(e,null);
                }
            }
        }
        if (lisenseToBeInserted.size() > 0){
            try{
                system.debug('Inserting ' + lisenseToBeInserted.size()+' Licenses');
                insert lisenseToBeInserted;
            /*}catch (Exception ex){
                hasErrors=true;
                orderToSubmit.SiteResult__c += ' DML Exception \n';
                srd += ' ***Failed to Insert Licenses*** ' + ex.getMessage() +'\n\n';
                Logger.debugException(ex,null);
            }*/
            } catch (System.DmlException e) {
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    orderToSubmit.SiteResult__c += ' DML Exception \n';
                    srd += ' ***Failed to Insert Licenses*** '+e.getDmlId(i)+' - '+e.getDmlMessage(i);
                    if (e.getDmlType(i) != null) srd += ', Status Code: '+e.getDmlType(i);
                    srd += '\n\n';
                    Logger.debugException(e,null);
                }
            }
        }


        if (!hasErrors){
            orderToSubmit.SiteResult__c = 'Success';
            orderToSubmit.SiteResultDescription__c ='Success:\n'+srd;

            if(orderToSubmit.AccountOrganization__c != 'Europe'){
                setNAOrderStatus(orderToSubmit);
            }

            system.debug('^^^ Updating order '+orderToSubmit.ID+': OrderStatus__c='+orderToSubmit.OrderStatus__c);
            //the following code is used to make sure the reporting fields get updated on the order line items
            OrderLineItemTriggerHandler.ExecuteReportingUpdate = true;
            update orderToSubmit;

            //update new Opportunity(Id=orderToSubmit.Opportunity__c, Skip_Stage_Validation__c=true, StageName='Stage 5 - Verified by Finance');
            OrderLineItemTriggerHandler.ExecuteReportingUpdate = false;

        // T-484201 - If there are errors while verification then we will check for messaging or non messaging
        } else {
            orderToSubmit.SiteResultDescription__c = srd;

            system.debug('^^^ submitOrder Errors - order ' + orderToSubmit.ID+': OrderStatus__c='+orderToSubmit.OrderStatus__c + ', SiteResult__c=' + orderToSubmit.SiteResult__c + ', SiteResultDescription__c=' + orderToSubmit.SiteResultDescription__c);

            /*JFreese Appirio 1/12/17 S-448654 This is not needed now that not sending to site
              (due to Do_Not_Provision__c, non-messaging or already provisioned) is no longer an error
              We just need the handling for site and DML exceptions*/

            /*boolean IsAllNonMsg = true;

             for (order_line_item__c oli : orderToSubmit.order_line_items__r){
                if(oli.Product__r.Messaging__c) {
                    IsAllNonMsg = false;
                }
            }

            if(IsAllNonMsg){
                if(orderToSubmit.AccountOrganization__c != 'Europe' && orderToSubmit.OrderStatus__c != 'Paid in Full'){
                    orderToSubmit.OrderStatus__c = 'Verified';
                }
            }
            else {
                if(orderToSubmit.SiteResultDescription__c.contains('No Line Items are in the correct state to Message, please contact your system admin for more information')) {
                    if(orderToSubmit.OrderStatus__c != 'Paid in Full' && orderToSubmit.OrderStatus__c != 'Verified'){
                        orderToSubmit.OrderStatus__c = 'Sent to verification';
                    }

                }
            }
            system.debug('^^^ Order Summary IsAllNonMsg=' +  IsAllNonMsg + ', OrderStatus__c=' + orderToSubmit.OrderStatus__c);*/

            update orderToSubmit;
        }

        try {//S-444964
              system.debug('insidetryS-444964');
              if((orderToSubmit.OrderStatus__c == 'Paid in Full' || orderToSubmit.OrderStatus__c == 'Verified'||orderToSubmit.OrderStatus__c =='Invoiced')&& UserInfo.getName() != 'Integration MAPP'){
                system.debug('insideifS-444964');
                update new Opportunity(Id=orderToSubmit.Opportunity__c, StageName='Stage 5 - Verified by Finance');
              }
        }catch (Exception ex){
            Logger.debugException(ex,null);
        }

       /* try {
            orderToSubmit.OrderStatus__c = 'Verified';
            update orderToSubmit;
        }catch (Exception ex){
            Logger.debugException(ex,null);
            try {
                update new Order__c(OrderStatus__c = 'Verified',Id=orderToSubmit.id, SiteResult__c = 'Salesforce update error', SiteResultDescription__c = ex.getMessage());
            } catch (Exception dmlEx){
                // do nothing; specifically have empty catch to try and save error description back to the order record but if that fails do nothing
                // as the error is already logged.
            }
        }*/


        Logger.pop();
        return orderToSubmit.SiteResultDescription__c;

      }


    /* @Name: setNAOrderStatus
    *  @Author: Jeff L (Appirio)
    *  @Params: an order
    *  @Returns: null
    *  @Description: This method will set the order status and payment
                    details of the NA record passed into it. Based upon
                    I-215468
    */
    private static void setNAOrderStatus(Order__c pOrder){
        system.debug('\n\n**** Inside BizAppsSiteModel.setNAOrderStatus()\n\n');

        Id ecommRecordType = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Ecomm');

        system.debug('^^^ Before setNAOrderStatus ID=' + pOrder.Id + ', Payment_Method_text__c=' + pOrder.Payment_Method_text__c + ', Payment_Term_text__c=' + pOrder.Payment_Term_text__c + ', Payment_Frequency__c=' + pOrder.Payment_Frequency__c + ', OrderStatus__c=' + pOrder.OrderStatus__c);

        //first do the ecomm checks and logic
        if(pOrder.RecordTypeId == ecommRecordType){
            if(String.isNotBlank(pOrder.CreditCardTransactionResponseCode__c) &&
                pOrder.MAPP_Payment_Frequency__c == 'Pre-Paid'){

                pOrder.OrderStatus__c = 'Paid in Full';
                pOrder.Payment_Method_text__c = 'Credit Card';
                pOrder.Payment_Term_text__c = 'Immediate';
                pOrder.Payment_Frequency__c = 'Single Payment';

            } else {
                pOrder.OrderStatus__c = 'Verified';
                pOrder.Payment_Method_text__c = 'Invoice';
                pOrder.Payment_Term_text__c = 'Net 30';
                pOrder.Payment_Frequency__c = 'Single Payment';
            }
        } else {
            //Non-Ecomm checks
            if(String.isNotBlank(pOrder.PaypalAuthReferenceNumber__c) &&
                String.isNotBlank(pOrder.PaypalAuthSecureTokenID__c)){
                    pOrder.OrderStatus__c = 'Paid in Full';
                    pOrder.Payment_Method_text__c = 'Credit Card';
                    pOrder.Payment_Term_text__c = 'Immediate';
                    pOrder.Payment_Frequency__c = 'Single Payment';
                    } else if(pOrder.Payment_Method_text__c == 'Credit Card'){
                        //if we are credit card but have not paid by credit card
                        //then it should be swtiched
                        pOrder.OrderStatus__c = 'Verified';
                        pOrder.Payment_Method_text__c = 'Invoice';
                        pOrder.Payment_Term_text__c = 'Net 30';
                        pOrder.Payment_Frequency__c = 'Single Payment';

                    } else {
                        //finally we just want to set to verified if the rest
                        //is not true
                        pOrder.OrderStatus__c = 'Verified';
                    }
        }
        system.debug('^^^ After  setNAOrderStatus ID=' + pOrder.Id + ', OrderStatus__c=' + pOrder.OrderStatus__c + ', Payment_Method_text__c=' + pOrder.Payment_Method_text__c + ', Payment_Term_text__c=' + pOrder.Payment_Term_text__c + ', Payment_Frequency__c=' + pOrder.Payment_Frequency__c);
    }


    private static void  submitOrder(Order__c orderToSubmit, xcodeaccount__c XcodeAccount){
            system.debug('\n\n**** Inside BizAppsSiteModel.submitOrder()\n\n');
            system.debug('^^^Submitting order ID '+orderToSubmit.ID+' Order Line Items for XCode '+XcodeAccount.xcode__r.name);

            v3_monsterBizappsSiterouterSiterouterws.legacy connection = new v3_monsterBizappsSiterouterSiterouterws.legacy();
            connection.timeout_x = 120000;
            connection.endpoint_x = Utility.getWebServiceEnpoint('MonsterBizAppsSiteRouter');

            v3_monsterBizappsSiterouterSiterouterws.ArrayOfAttribute Attributes = new v3_monsterBizappsSiterouterSiterouterws.ArrayOfAttribute();
            Attributes.Attribute = new v3_monsterBizappsSiterouterSiterouterws.Attribute[]{};

            v3_monsterBizappsSiterouterSiterouterws.Attribute attr2 = new v3_monsterBizappsSiterouterSiterouterws.Attribute();
            attr2.Key = 'EbizUser';
            attr2.Value = '0';
            Attributes.Attribute.add(attr2);

            v3_monsterBizappsSiterouterSiterouterws.Attribute attr3 = new v3_monsterBizappsSiterouterSiterouterws.Attribute();
            attr3.Key = 'Source';
            attr3.Value = 'SalesForce';
            Attributes.Attribute.add(attr3);

            //AP S-328685
            v3_monsterBizappsSiterouterSiterouterws.Attribute attr4 = new v3_monsterBizappsSiterouterSiterouterws.Attribute();
            attr4.Key = 'ProvisionSourceKarma';
            attr4.Value = '1';
            Attributes.Attribute.add(attr4);

            v3_monsterBizappsSiterouterSiterouterws.submitOrderRequest_element requestData = new v3_monsterBizappsSiterouterSiterouterws.submitOrderRequest_element();
            requestData.Attributes = Attributes;
            requestData.Notes = orderToSubmit.Notes__c == null ? '' : orderToSubmit.Notes__c;
            requestData.OrderID = orderToSubmit.Id;
            requestData.OrderNumber = orderToSubmit.Name;
            requestData.PurchaseDate = orderToSubmit.OrderDate__c;
            requestData.SiteDestination = orderToSubmit.SiteDestination__c;
            requestData.CompanyFraudStatus = orderToSubmit.Account__r.CompanyFraudStatus__c;
            requestData.CountryCode = orderToSubmit.Account__r.BillingCountryCode;
            requestData.ExternalAccountID = orderToSubmit.Account__r.Id;
            requestData.Promotions = new v3_schemasMicrosoftCom200310SerializA.ArrayOfint();
            requestData.Promotions.int_x = new Integer[]{0};

            if(orderToSubmit.Posting_Contact__c != null) {
                requestData.CustomerName = orderToSubmit.Posting_Contact__r.Name;
            }
            requestData.CustomerEmail = orderToSubmit.Posting_Contact_Email__c;
            requestData.SalesRepEmail = orderToSubmit.Primary_SalesRep_Email__c;


            //With issues
            requestData.CompanyFraudStatus = 'Unknown';
            //requestData.ChannelID = 58;//orderToSubmit.SiteChannelID__c; //Invalid data type//S-456747 AP
            //S-456747
            //Sberron -1/20 - I-254377
            //Site channel was being set to null breaking orders on prod.
            System.debug('----Setting requestData.ChannelId');
            Integer SiteChannel;
            String Channel = orderToSubmit.SiteChannelID__c;
            if (Channel != null) {
                SiteChannel = Integer.Valueof(Channel);
                System.debug('---- SITE CHANNEL NOT NULL - Setting SiteChannel to ' + SiteChannel);
            }
            else {
                SiteChannel = 58;
                System.debug('----SITE CHANNEL NULL - Setting SiteChannel to ' + SiteChannel);
            }
            requestData.ChannelID = SiteChannel;
            requestData.CompanyXcode=XcodeAccount.xcode__r.name;


             //Line Item Request Packing
            /*JFreese Appirio 1/12/17 S-448654
                This story tested the condition where there were two OLI, one messaging (to be sent to site),
                one non-messaging (not sent to site).  Before clicking Send to Verification, one of the
                OLI was updated to select a different AccountXcode, so the order had two xCodes, one for
                each OLI.  The result was that the messaging OLI did not get provisioned.

                The messaging OLI did indeed get sent to site, but the code was only updating the OLI and
                inserts the licenses when (OLIcount == countOLI), in other words when all OLI have been
                processed.

                But the XCode with a single non-messaging product was not added to the request, and
                that was treated as an error, which halted the process before the counts could be compared.

                Changes:
                 - handle OLIs not sent to Site with an informational packMsg rather than an error
                 - rename the xcodeaccount__c argument to XcodeAccount
                 - move the Do_Not_Provision__c down to here to include it in the packMsg
                 - treat the failure of Site to return a license as an error, even if site result = 0
                 - commit all OLIs and licenses gathered, no count comparison, after the XCodes are processed
            */
            map<Id, Order_Line_Item__c> OLIMap = new map<Id, Order_Line_Item__c>();
            Integer XcodeLineCt = 0; // count of OLI for the current XCode
            Integer nonMessagingCt = 0;
            Integer preProvCt = 0;
            Integer doNotProvCt = 0;
            Integer notSent = 0;
            String reasons = '';
            if(orderToSubmit.Order_Line_Items__r != null && !orderToSubmit.Order_Line_Items__r.isEmpty()){
                for(Order_Line_Item__c oli : orderToSubmit.Order_Line_Items__r){
                    if (oli.Xcode_lkp__r.id == XcodeAccount.id) {
                        if (oli.Do_Not_Provision__c == false){
                            OLIMap.put(oli.Id, oli);
                        }
                        countOLI++;
                        XcodeLineCt++;

                        //count the OLIs that will not be sent to Site
                        if (oli.result__c == '0'){
                            preProvCt++;
                        }
                        else if (oli.Do_Not_Provision__c == true){
                            doNotProvCt++;
                        }
                        else if (oli.product__r.Messaging__c == false && oli.OptionId__r.Messaging__c == false){
                            nonMessagingCt++;
                        }
                    }
                }
                system.debug('^^^Total count of OLI for the order='+OLIcount+', OLI processed='+countOLI +', OLI Count for this XCode='+XcodeLineCt);
                system.debug('Reason(s) not to Send to Site: nonMessagingCt='+nonMessagingCt+', preProvCt='+preProvCt+', doNotProvCt='+doNotProvCt);
                system.debug('^^^Packing OLIMap:'+OLIMap);
                requestData.LineItems = PackOrderLineItemForOrderSubmit(OLIMap);

                packMsg = XcodeAccount.xcode__r.name+' has '+XcodeLineCt+' associated order line item'+(XcodeLineCt > 1 ? 's':'')+'; ';
                if(requestData.LineItems.OrderLineItem.size() == 0){packMsg += 'none were';}
                else if (requestData.LineItems.OrderLineItem.size() == 1){packMsg += '1 was';}
                else if (requestData.LineItems.OrderLineItem.size() == XcodeLineCt){packMsg += 'all were';}
                else {packMsg += requestData.LineItems.OrderLineItem.size()+' were';}
                packMsg += ' sent to Site';

                notSent = XcodeLineCt - requestData.LineItems.OrderLineItem.size();
                if(requestData.LineItems.OrderLineItem.size() <> XcodeLineCt){
                    packMsg += ' (';
                    if (nonMessagingCt > 0){reasons += nonMessagingCt+': non-messaging';}
                    if (preProvCt > 0){
                        reasons += (reasons.length() > 0 ? ', ':'');
                        reasons += preProvCt+': already provisioned (Integration Result = 0)';
                    }
                    if (doNotProvCt > 0){
                        reasons += (reasons.length() > 0 ? ', ':'');
                        reasons += doNotProvCt+': flagged Do Not Provision';
                    }
                    packMsg += reasons + ')';
                }
                packMsg += '\n';

                if(requestData.LineItems.OrderLineItem.size() > 0){
                    System.debug('****Packed Line Item Attributes for submittal to Site****');
                    for(v3_monsterBizappsSiterouterSiterouterws.OrderLineItem oli : requestData.LineItems.OrderLineItem){
                        //for(v3_monsterBizappsSiterouterSiterouterws.OrderLineItem oli : ar.OrderLineItem){
                            system.debug('OLI ID '+oli.OrderLineItemRowID);
                            for(v3_monsterBizappsSiterouterSiterouterws.Attribute attr : oli.Attributes.Attribute){
                                system.debug('Attribute: ' + attr.Key + ' ' + attr.Value );
                            }
                        //}
                    }
                }
                else {
                    system.debug('^^^There are no OLI to send to Site for this XCode');
                }
            }else{
                /*This should "never" be the case, because SendOrderToSite() gathered all XCodes
                  for the Orders OLIs, then called this method for each XCode, so it should
                  always find at least one OLI for processing.  It may not find any to send
                  to Site if all of the OLI have non-messaging products*/
                system.debug('\n\n'+orderToSubmit.Name +' has no line items for processing.\n\n');
            }

        String errMsg='';
        if (requestData.LineItems.OrderLineItem.isEmpty()==false) {
            v3_monsterBizappsSiterouterSiterouterws.SubmitOrderResult_element result = connection.SubmitOrderOptimized(requestData);
            system.debug('\n\nSite integration result: ' + result + '\n\n');

            if(result.LineItemResults != null){
                if(result.LineItemResults.OrderItemResult != null){
                    //Order_Line_Item__c[] oliToBeUpdated = new Order_Line_Item__c[]{};
                    //LicenseID__c[] lisenseToBeInserted = new LicenseID__c[]{};
                    for(v3_monsterBizappsSiterouterSiterouterws.OrderItemResult line : result.LineItemResults.OrderItemResult){
                        Order_Line_Item__c usedOli = OLIMap.get(line.LineItemRowID);
                        system.debug('usedOli' + usedOli);
                        if(usedOli != null){
                            usedOli.Result__c = String.valueOf(line.Result);
                            usedOli.ResultDescription__c = line.ResultDescription;
                            oliToBeUpdated.add(usedOli);
                            if(line.LicenseID != null && line.LicenseID != 0){
                                if(Line.LicenseIDs != null){
                                    //there is at least one product that returns more than one license
                                    //I-235979
                                    for(Integer licId : Line.LicenseIDs.int_x){
                                        LicenseID__c license = new LicenseID__c();
                                        license.SiteLicenseID__c = String.valueOf(licId);
                                        license.OrderLineItem__c = usedOli.Id;
                                        license.AvailableInventory__c = usedOli.Quantity2__c;
                                        license.QuantityProvisioned__c = usedOli.Quantity2__c;
                                        license.Xcode__c = XcodeAccount.xcode__c;
                                        lisenseToBeInserted.add(license);
                                    }

                                } else {
                                    LicenseID__c license = new LicenseID__c();
                                    license.SiteLicenseID__c = String.valueOf(line.LicenseID);
                                    license.OrderLineItem__c = usedOli.Id;
                                    license.AvailableInventory__c = usedOli.Quantity2__c;
                                    license.QuantityProvisioned__c = usedOli.Quantity2__c;
                                    license.Xcode__c = XcodeAccount.xcode__c;
                                    lisenseToBeInserted.add(license);
                                }

                            }else{
                                //JFreese Appirio 1/12/17 S-448654 No license returned
                                errMsg += 'ERROR: Site did not return a license for '+usedOli.name+'\n';
                            }
                        }
                    }
                }
            }

            //JFreese Appirio 1/12/17 S-448654 Throw an exception if result <> 0 or No license returned
            if (result.result<>0) {
                if (errMsg != ''){
                    throw new SubmitOrderException(result.Result,result.ResultDescription);
                }
                else {
                    throw new SubmitOrderException(result.Result,result.ResultDescription+'\n'+errMsg);
                }
            }
            else if (errMsg != ''){
                throw new SubmitOrderException(result.Result,errMsg);
            }
        }
    }

    //Method that is used to add the attributes and generate the line items for messaging out
    public static v3_monsterBizappsSiterouterSiterouterws.ArrayOfOrderLineItem PackOrderLineItemForOrderSubmit(map<Id, Order_Line_Item__c> pOrderLines){
        system.debug('\n\n**** Inside BizAppsSiteModel.PackOrderLineItemForOrderSubmit()\n\n');
        system.debug('Instantiating attributeMgr');
        IntegrationAttributeManager attributeMgr = new IntegrationAttributeManager('IWS');
        system.debug('Instantiated attributeMgr');
        set<id> oliIds = pOrderLines.keyset();
        system.debug('oliIds' + oliIds);
        /*string soql = 'select Order_line_Item__r.Product__r.ProductCode, Order_line_Item__r.LineNumber__c,Order_line_Item__r.StartDate__c, Order_line_Item__r.EndDate__c, Order_line_Item__r.Quantity2__c, Order_line_Item__r.product__r.id, Order_line_Item__r.order__r.id,' + attributeMgr.generateSoqlFields()
            + ' from Line_Item_Attribute__c where Order_line_Item__c in :oliIds and Order_line_Item__r.product__r.Messaging__c=true and Order_line_Item__r.Result__c<>\'0\'';*/
        string soql = 'select Order_line_Item__r.Product__r.ProductCode, Order_line_Item__r.LineNumber__c,Order_line_Item__r.StartDate__c, Order_line_Item__r.EndDate__c, Order_line_Item__r.Quantity2__c, Order_line_Item__r.product__r.id, Order_line_Item__r.order__r.id,' + attributeMgr.generateSoqlFields()
            + ' from Line_Item_Attribute__c where Order_line_Item__c in :oliIds and (Order_line_Item__r.product__r.Messaging__c=true or Order_line_Item__r.OptionId__r.Messaging__c=true) and Order_line_Item__r.Result__c<>\'0\'';//AP for bundles
        list<Line_Item_Attribute__c> lineItems = database.query(soql);
        v3_monsterBizappsSiterouterSiterouterws.ArrayOfOrderLineItem output = new v3_monsterBizappsSiterouterSiterouterws.ArrayOfOrderLineItem();
        output.OrderLineItem = new v3_monsterBizappsSiterouterSiterouterws.OrderLineItem[]{};
        Integer c = 1;
        for(Line_Item_Attribute__c lia : lineItems){
                map<string, sobject> sourceMap = new map<string,sobject>{'Line_Item_Attribute__c'=>lia,''=>lia.Order_line_Item__r, 'Order_Line_Item__c'=>lia.Order_line_Item__r, 'Product'=>lia.Order_line_Item__r.product__r};
                v3_monsterBizappsSiterouterSiterouterws.OrderLineItem line = new v3_monsterBizappsSiterouterSiterouterws.OrderLineItem();
                line.OrderLineItemRowID = lia.Order_line_Item__r.Id;
                line.ProductID = lia.Order_line_Item__r.Product__r.ProductCode;
                line.Quantity =  Integer.valueOf(lia.Order_line_Item__r.Quantity2__c);
                /*Break an OLI for debugging,
                    - missing product throws a Site error and returns no license
                    - phony product such as MBOGUSXJOB does not throw a Site error and does return a license
                    - negative quantity does not throw a Siote error and returns no license
                //if (lia.Order_line_Item__c == 'a4fq00000000XZtAAM'){line.ProductID='';}
                //if (lia.Order_line_Item__c == 'a4fq00000000XZjAAM'){line.Quantity=-10;}*/
                line.LineNumber = Integer.valueOf(lia.Order_line_Item__r.LineNumber__c);
                line.IsInventory = true;//oli.IsInventory__c;
                line.PendingCount = 0;
                line.PendingDate = DateTime.now();
                line.StartDate = lia.Order_line_Item__r.StartDate__c;
                line.ExpirationDate = lia.Order_line_Item__r.EndDate__c;
                line.LicenseID = 0;
                line.Promotion = 0;//Integer.valueOf(oli.Promotion__c);
                line.RelateOrderLineItemRowID = '0';
                line.RelatedLicenseID = 1;
                //This iterates through the integration attributes and it set the attributes array on the generated line item
                v3_monsterBizappsSiterouterSiterouterws.ArrayOfAttribute Attributes = new v3_monsterBizappsSiterouterSiterouterws.ArrayOfAttribute();
                Attributes.Attribute = new v3_monsterBizappsSiterouterSiterouterws.Attribute[]{};
                set<string>keys = new set<string>();
                for (IntegrationAttributeManager.IntegrationAttribute ia : attributeMgr.primaryAttributes.values()) {
                    for (IntegrationAttributeManager.KeyValuePair attribute : ia.getMatchingAttributes(sourceMap) ) {
                    if(keys.contains(attribute.key)==false){
                        v3_monsterBizappsSiterouterSiterouterws.Attribute attr = new v3_monsterBizappsSiterouterSiterouterws.Attribute();
                        attr.Key = attribute.key;
                        attr.Value = attribute.value;
                        Attributes.Attribute.add(attr);
                        keys.add(attribute.key);
                     }
                   }
                }

                line.Attributes = Attributes;
                output.OrderLineItem.add(line);

        }
        return output;
    }

/*
** @author : Cloud Sherpas Inc.
** @date : 09/16/2014
** @description : called from afterUpdate of Orders, Submits order to site when order status is verified (NOTE: Currently the functionality is moved to "Verify Order" button on Order object)
** @paramaters : trigger.new, trigger.oldMap
** @returns : none
*/
    public static void SubmitOrder(Order__c[] pUpdatedOrderList, map<Id, Order__c> pOldOrderMap){
        system.debug('\n\n**** Inside BizAppsSiteModel.SubmitOrder()\n\n');

        if(pUpdatedOrderList.size() > 1){
            system.debug('Detected multiple orders. Stopping site integration.');
            return;
        }

        list<Order__c> verifiedOrder = new list<Order__c>();
        for(Order__c o : pUpdatedOrderList){
            if(o.OrderStatus__c == 'Verified' && pOldOrderMap.get(o.Id).OrderStatus__c != 'Verified'){
                o.SiteResult__c = 'Processing';
                o.SiteResultDescription__c = 'Currently in progress. Please refresh the page to see the result.';
                verifiedOrder.add(o);
            }
        }

        if(!verifiedOrder.isEmpty()){
            system.debug('Starting site integration for Order: ' + verifiedOrder[0].Name);
            SendOrderToSite(verifiedOrder[0].Id);
        }else{
            system.debug('\n\n No order for SITE submit process.\n\n');
        }
    }

    public static String[] AdjustmentIntegrationProcess(map<Id, TransferAndAdjustmentProcessCC.LineWrapList[]> pLineWraps, map<Id, Order_Line_Item__c> pOrderLineItemMap){
        system.debug('\n\n**** Inside BizAppsSiteModel.AdjustmentIntegrationProcess()\n\n');
        IntegrationAttributeManager attributeMgr = new IntegrationAttributeManager('IWS');
        set<id> oliIds = pOrderLineItemMap.keyset();
        /* JFreese Appirio - I-172894 Change sourceObject from Order_line_Item__c to Line_Item_Attribute__c
           to match the previous fix made by JLescarbeau in PackOrderLineItemForOrderSubmit().*/
        string soql = 'select Order_line_Item__r.Id, Order_line_Item__r.Quantity2__c, Order_line_Item__r.AdjustmentReason__c, Order_line_Item__r.AdjustmentType__c, ' +
        ' Order_line_Item__r.TrackingTicketID__c, Order_line_Item__r.Order__r.SiteDestination__c, Order_line_Item__r.Notes__c,' + attributeMgr.generateSoqlFields() +
        ' from Line_Item_Attribute__c where Order_line_Item__c in :oliIds and Order_line_Item__r.product__r.Messaging__c=true';
        map<id,Line_Item_Attribute__c> lineItems = new map<id,Line_Item_Attribute__c>();
            for (Line_Item_Attribute__c oliAttributes : database.query(soql)){
                lineItems.put(oliAttributes.Order_Line_Item__r.Id, oliAttributes);
            }

        String[] output = new String[]{};
        try{
            map<Integer, LicenseID__c> SiteLicenseIdTLicenseID = new map<Integer, LicenseID__c>();

            v3_monsterBizappsSiterouterSiterouterws.LicenseAdjustment[] LicenseAdjustmentList = new v3_monsterBizappsSiterouterSiterouterws.LicenseAdjustment[]{};
            for(Order_Line_Item__c pOrderLineItem :pOrderLineItemMap.values()){
                map<string, sobject> sourceMap = new map<string,sobject>{'Line Item'=>pOrderLineItem, 'Order'=>pOrderLineItem.order__r};
                Line_Item_Attribute__c oliAttribute = lineItems.get(pOrderLineItem.id);
                if (oliAttribute!=null) {
                    sourceMap.put('Line_Item_Attributes__c', oliAttribute);
                }
                for(TransferAndAdjustmentProcessCC.LineWrapList wrapList : pLineWraps.get(pOrderLineItem.Id)){
                    for(TransferAndAdjustmentProcessCC.LineWrap line : wrapList.LineWraps){
                        v3_monsterBizappsSiterouterSiterouterws.LicenseAdjustment LicenseAdjustment = new v3_monsterBizappsSiterouterSiterouterws.LicenseAdjustment();

                        LicenseAdjustment.LicenseID = Integer.valueOf(wrapList.ParentLicenseId.SiteLicenseID__c);//244681184;//invalid mapping, can be Name field of License ID, (e.g. for LID-0000000005, use 0000000005)

                        //no mapping
                        LicenseAdjustment.AdjustmentID = '4-2CYWFRK';//wrapList.ParentLicenseId.Xcode__r.IntegrationXcode__c;//required, no idea
                        LicenseAdjustment.AdditionalActions = wrapList.ParentLicenseId.AdditionalActions__c == null ? 'None' : wrapList.ParentLicenseId.AdditionalActions__c; //mapping is identified needs to be created on the proper object
                        LicenseAdjustment.RequestID = '4-2CYWFSD';//wrapList.ParentLicenseId.Id; //can be a different custom object Id

                        //probably invalid mapping
                        LicenseAdjustment.TrackingTicketType = 0; //can be a custom setting or a new custom object
                        LicenseAdjustment.Source = 0; //no idea
                        LicenseAdjustment.ReasonCode = 1; //can be a custom setting or a new custom object

                        //probably correct mapping
                        LicenseAdjustment.AdjustmentReason =  pOrderLineItem.AdjustmentReason__c; //'CustomerError'; NEEDS TO BE ADDED ON Transfer and Adjustment VF page
                        LicenseAdjustment.AdjustmentType = pOrderLineItem.AdjustmentType__c; //'Increase'; NEEDS TO BE ADDED ON Transfer and Adjustment VF page
                        LicenseAdjustment.Count = line.Amount; //1;
                        LicenseAdjustment.LineItemRowID = pOrderLineItem.Id; //'1-2G7PECJ';
                        LicenseAdjustment.ModifyingUserID = UserInfo.getName(); //'MNICHAM';
                        LicenseAdjustment.Notes = pOrderLineItem.Notes__c == null ? '' : pOrderLineItem.Notes__c; //'Customer Error'; NEEDS TO BE ADDED ON Transfer and Adjustment VF page
                        LicenseAdjustment.TrackingTicketID = pOrderLineItem.TrackingTicketID__c; //''; propably dependent on TrackingTicketType
                        LicenseAdjustment.OrderID = pOrderLineItem.Order__c; //'1-2G7OAIP';
                        LicenseAdjustment.SiteDestination = pOrderLineItem.Order__r.SiteDestination__c; //'NA';

                         set<string>keys = new set<string>();
                        LicenseAdjustment.Attributes =  new v3_monsterBizappsSiterouterSiterouterws.ArrayOfAttribute();
                        LicenseAdjustment.Attributes.Attribute = new list<v3_monsterBizappsSiterouterSiterouterws.Attribute>();
                         for (IntegrationAttributeManager.IntegrationAttribute ia : attributeMgr.primaryAttributes.values()) {
                            for (IntegrationAttributeManager.KeyValuePair attribute : ia.getMatchingAttributes(sourceMap) ) {
                                if (keys.contains(attribute.key)==false){
                                    v3_monsterBizappsSiterouterSiterouterws.Attribute attr = new v3_monsterBizappsSiterouterSiterouterws.Attribute();
                                    attr.Key = attribute.key;
                                    attr.Value = attribute.value;
                                    LicenseAdjustment.Attributes.Attribute.add(attr);
                                    keys.add(attribute.key);
                                }
                           }
                         }

                        SiteLicenseIdTLicenseID.put(LicenseAdjustment.LicenseID, wrapList.ParentLicenseId);
                        LicenseAdjustmentList.add(LicenseAdjustment);
                    }
                }
            }

            v3_monsterBizappsSiterouterSiterouterws.legacy connection = new v3_monsterBizappsSiterouterSiterouterws.legacy();

            //method call
            v3_monsterBizappsSiterouterSiterouterws.SubmitAdjustLicenseResult_element result = connection.SubmitAdjustLicense(LicenseAdjustmentList);

            output.add('Adjustment Result: ' + result.Result);
            output.add('Result Description: ' + result.ResultDescription);


            map<Id, Order_Line_Item__c> LineItemsToUpdate = new map<Id, Order_Line_Item__c>();
            map<Id, LicenseID__c> LicenseToUpdate = new map<Id, LicenseID__c>();
            if(result.LineItemResults != null && result.LineItemResults.AdjustmentItemResult != null){
                for(v3_monsterBizappsSiterouterSiterouterws.AdjustmentItemResult resultItem : result.LineItemResults.AdjustmentItemResult){

                    Order_Line_Item__c pOrderLineItem = pOrderLineItemMap.get(resultItem.LineItemRowID);
                    if(pOrderLineItem != null){
                        pOrderLineItem.Result__c = result.Result;
                        pOrderLineItem.ResultDescription__c = result.ResultDescription;

                        if(resultItem.LicenseID != null && SiteLicenseIdTLicenseID.containsKey(resultItem.LicenseID)){
                            LicenseID__c currentLIcense = SiteLicenseIdTLicenseID.get(resultItem.LicenseID);
                            Integer newInventory;
                            if(pOrderLineItem.AdjustmentType__c == 'Increase'){
                                newInventory = currentLIcense.AvailableInventory__c == null ? resultItem.AffectedCount : resultItem.AffectedCount + Integer.valueOf(currentLIcense.AvailableInventory__c);
                            }else{
                                newInventory = currentLIcense.AvailableInventory__c == null || currentLIcense.AvailableInventory__c < resultItem.AffectedCount ? 0 : Integer.valueOf(currentLIcense.AvailableInventory__c) - resultItem.AffectedCount;
                            }
                            currentLIcense.AvailableInventory__c = newInventory;
                            currentLIcense.QuantityProvisioned__c = newInventory;
                            system.debug('^^^Adjusted AvailableInventory__c=' + currentLIcense.AvailableInventory__c + ' and QuantityProvisioned__c=' + currentLIcense.QuantityProvisioned__c);

                            if(!LicenseToUpdate.containsKey(currentLIcense.Id)){
                                LicenseToUpdate.put(currentLIcense.Id, currentLIcense);
                            }
                        }
                        if(!LineItemsToUpdate.containsKey(pOrderLineItem.Id)){
                            LineItemsToUpdate.put(pOrderLineItem.Id, pOrderLineItem);
                        }
                    }
                }
            }
            if(!LineItemsToUpdate.isEmpty()){
                update LineItemsToUpdate.values();
            }
            if(!LicenseToUpdate.isEmpty()){
                update LicenseToUpdate.values();
            }
        }catch(Exception e){
               output.add('Encountered error: ' + e.getMessage());
        }

        return output;
    }

    public static String[] TransferIntegrationProcess(TransferAndAdjustmentProcessCC.LineWrapList[] pLineWraps, Order_Line_Item__c pOrderLineItem){
        system.debug('\n\n**** Inside BizAppsSiteModel.TransferIntegrationProcess()\n\n');

        String[] output = new String[]{};
        String[] ParentLicenseError = new String[]{};
        system.debug('pLineWraps='+pLineWraps);

        try{
            set<Id> xcodeIdSet = new set<Id>();
            for(TransferAndAdjustmentProcessCC.LineWrapList wrapList : pLineWraps){
                if(wrapList.ParentLicenseId.SiteLicenseID__c == null){
                    ParentLicenseError.add(wrapList.ParentLicenseId.Name + ' has no Site License ID.');
                }else{
                    for(TransferAndAdjustmentProcessCC.LineWrap line : wrapList.LineWraps){
                        if(line.AccXId.trim() != '' && line.AccXId != null){
                            line.License.Xcode__c = line.AccXId;
                            system.debug('>> xcodeacc='+line.License.Xcode__c);
                        }
                        if(line.License.Xcode__c != null){
                            xcodeIdSet.add(line.License.Xcode__c);
                        }
                    }
                }
            }
            system.debug('>> xcodeIDset='+xcodeIdSet);
            if(!ParentLicenseError.isEmpty()){
                output.addAll(ParentLicenseError);
                return output;
            }

            if(xcodeIdSet.isEmpty()){
                output.add('No line with Xcode.');
                return output;
            }

            map<Id, Xcode__c> usedXcodeMap = new map<Id, Xcode__c>([SELECT Id, Name FROM Xcode__c WHERE Id IN :xcodeIdSet]);
            system.debug('usedXcodeMap.size()=' + usedXcodeMap.size() + ', usedXcodeMap=' + usedXcodeMap);

            v3_monsterBizappsSiterouterSiterouterws.ArrayOfTransferInventoryItem TransferInventoryItems = new v3_monsterBizappsSiterouterSiterouterws.ArrayOfTransferInventoryItem();
            TransferInventoryItems.TransferInventoryItem = new v3_monsterBizappsSiterouterSiterouterws.TransferInventoryItem[]{};

            TransferAndAdjustmentProcessCC.LineWrapList[] withErrors = new TransferAndAdjustmentProcessCC.LineWrapList[]{};
            //If there is already a license with the same site id, the transfered quantity will be added to that license do not create a new license
            LicenseID__c[] existingLicenses = [SELECT SiteLicenseID__c,Name, AvailableInventory__c, Xcode__c
                                                            FROM LicenseID__c
                                                            WHERE OrderLineItem__c = :pOrderLineItem.Id  and SiteLicenseID__c!=null];

            //system.debug('existingLicenses='+existingLicenses);
            map<String, Sobject> licenseIdMap = sCollection.stringMap(existingLicenses, 'SiteLicenseID__c');
            map<String, Sobject> licenseXcodeMap = sCollection.stringMap(existingLicenses, 'Xcode__c');
            system.debug ('licenseIdMap=' + licenseIdMap);
            system.debug ('licenseXcodeMap=' + licenseXcodeMap);

            map<String, TransferAndAdjustmentProcessCC.LineWrap> licensesToSend = new map<String, TransferAndAdjustmentProcessCC.LineWrap>();
            map<Integer, LicenseID__c> parentLicenseMap = new map<Integer, LicenseID__c>();
            for(TransferAndAdjustmentProcessCC.LineWrapList wrapList : pLineWraps){
                parentLicenseMap.put(Integer.valueOf(wrapList.ParentLicenseId.SiteLicenseID__c), wrapList.ParentLicenseId);
                Integer sumOfQuantityToTransfer = 0;

                 for(TransferAndAdjustmentProcessCC.LineWrap line : wrapList.LineWraps){
                    if(line.License.Xcode__c != null){
                        LicenseID__c License = (LicenseID__c)licenseXcodeMap.get(line.License.Xcode__c);
                        v3_monsterBizappsSiterouterSiterouterws.TransferInventoryItem item = new v3_monsterBizappsSiterouterSiterouterws.TransferInventoryItem();
                        item.ExternalTransferInventoryID = '2-2E52ONT';//not mapped yet
                        //item.LineItemID = pOrderLineItem.Id;
                        //Sberron - S-402215 - 4/24/17
                        //All new License Ids were being set to the 'last' line item. Now setting to parent license Id line item
                        item.LineItemID = wrapList.ParentLicenseId.OrderLineItem__c;
                        item.TransferQuantity = line.Amount;
                        sumOfQuantityToTransfer += item.TransferQuantity == null ? 0 : item.TransferQuantity;
                        item.TransferredFromLicenseID = Integer.valueOf(wrapList.ParentLicenseId.SiteLicenseID__c);
                        item.OriginalResourceLicenseID = item.TransferredFromLicenseID;
                        item.OrderID = pOrderLineItem.Order__c;

                        item.TransferredToLicenseID = (License != null && License.SiteLicenseID__c !=null && License.SiteLicenseID__c != '') ? Integer.valueOf(License.SiteLicenseID__c ): 0;
                        if (License != null && License.SiteLicenseID__c == '0'){
                            system.debug('***** SiteLicenseID__c is (probably) based on a failed previous transfer attempt.  ' +
                                         'This is (probably) not a problem, as the item.TransferredToLicenseID will be set to 0, ' +
                                         'as it would be if there were no existing LIDs with this xcode.  ' +
                                         'BUT the associated LID with Site Licence ID = 0 should probably be manually deleted.');
                        }
                        item.TransferredToCompanyXcode = usedXcodeMap.containsKey(line.License.Xcode__c) ? usedXcodeMap.get(line.License.Xcode__c).Name : null;
                        TransferInventoryItems.TransferInventoryItem.add(item);
                        licensesToSend.put(item.TransferredToCompanyXcode, line);
                       }
                }

                if(sumOfQuantityToTransfer > wrapList.ParentLicenseId.AvailableInventory__c){
                    withErrors.add(wrapList);
                }
            }
            if (licensesToSend.size() > 0){system.debug('licensesToSend='+licensesToSend);}

            if(withErrors.size() > 0){
                for(TransferAndAdjustmentProcessCC.LineWrapList errorWrap : withErrors){
                    output.add('Error on ' + errorWrap.ParentLicenseId.Name + ': Sum of all "Transfer Amount" can not exceed "Available Quantity".');
                }
                return output;
            }

            String line = '===================================================================================================================================';
            String summaryOut = '\n\n' + line + '\n';
            summaryOut += 'Summary of information sent to Site:\n';
            for(v3_monsterBizappsSiterouterSiterouterws.TransferInventoryItem item : TransferInventoryItems.TransferInventoryItem){
                summaryOut += 'Transfer Inventory ID: ' + item.ExternalTransferInventoryID;
                summaryOut += ', Transfer from: ' + item.TransferredFromLicenseID;
                summaryOut += ', Transfer to: ' + item.TransferredToLicenseID;
                summaryOut += ', Transfer to xCode: ' + item.TransferredToCompanyXcode;
                summaryOut += ', Amount: ' + item.TransferQuantity;
                summaryOut += ', LineItemID: ' + item.LineItemID;
                //summaryOut += ' Available Inventory: ' += wrapList.ParentLicenseId.AvailableInventory__c;
                summaryOut += '\n';
            }
            summaryOut += line + '\n\n';
            system.debug (summaryOut);

            v3_monsterBizappsSiterouterSiterouterws.legacy connection = new v3_monsterBizappsSiterouterSiterouterws.legacy();
            v3_monsterBizappsSiterouterSiterouterws.TransferInventoryResult_element result = connection.TransferInventory(UserInfo.getName(), 'Karma', TransferInventoryItems);

            String summaryIn = '\n\n' + line + '\n';
            summaryIn += 'Summary of information returned from Site:\n';
            if(result != null){
                summaryIn += 'Summary ResponseCode: ' + result.ResponseCode + '\n';
                if(result.TransferInventoryResponseItems != null){
                    if(result.TransferInventoryResponseItems.TransferInventoryResponseItem != null){
                        for(v3_monsterBizappsSiterouterSiterouterws.TransferInventoryResponseItem transferItem : result.TransferInventoryResponseItems.TransferInventoryResponseItem){
                            v3_monsterBizappsSiterouterSiterouterws.TransferInventoryItem Item = transferItem.Item;
                            v3_monsterBizappsSiterouterSiterouterws.ResponseResult ItemResult = transferItem.ItemResult;
                            summaryIn += 'Response Result: ' + ItemResult.Result;
                            summaryIn += ', Transfer Inventory ID: ' + item.ExternalTransferInventoryID;
                            summaryIn += ', Transfer from: ' + item.TransferredFromLicenseID;
                            summaryIn += ', Transfer to: ' + item.TransferredToLicenseID;
                            summaryIn += ', Transfer to xCode: ' + item.TransferredToCompanyXcode;
                            summaryIn += ', Amount: ' + item.TransferQuantity;
                            summaryIn += ', Response Result Description: ' + itemResult.ResultDescription;
                            summaryIn += '\n';
                        }
                    }
                }
            }
            summaryIn += line + '\n\n';
            system.debug (summaryIn);

            //system.debug('\n\nTransfer Result: ' + result + '\n\n');

            if(result != null){
                output.add('Transfer Result: ' + result.ResponseCode);
            }


            list<LicenseID__c> licensesToBeSaved = new list<LicenseID__c>();


            if(result.TransferInventoryResponseItems != null){
                if(result.TransferInventoryResponseItems.TransferInventoryResponseItem != null){
                    LicenseID__c[] newLicenseToInsert = new LicenseID__c[]{};
                    map<Id, LicenseID__c> parentToUpdate = new map<Id, LicenseID__c>();
                    set<Id> xcodeIdOfLicenseSet = new set<Id>();
                    for(v3_monsterBizappsSiterouterSiterouterws.TransferInventoryResponseItem transferItem : result.TransferInventoryResponseItems.TransferInventoryResponseItem){
                        if(transferItem.Item != null){
                            v3_monsterBizappsSiterouterSiterouterws.TransferInventoryItem Item = transferItem.Item;
                            v3_monsterBizappsSiterouterSiterouterws.ResponseResult ItemResult = transferItem.ItemResult;
                            system.debug('##licensesToSend :'+licensesToSend+'\n Item.TransferredToCompanyXcode::'+Item.TransferredToCompanyXcode);
                            system.debug('##ItemResult.Result ::'+ItemResult.Result);
                            if(licensesToSend.containsKey(Item.TransferredToCompanyXcode) && ItemResult.Result == 0){
                                system.debug('check 2 licensesToBeSaved='+licensesToBeSaved);
                                LicenseID__c parentLicense = parentLicenseMap.get(Item.TransferredFromLicenseID);
                                if(parentLicense != null){
                                    //system.debug('parentLicense='+parentLicense);
                                    /*S-447283 JFreese 10/19/16 This is the only substantive change made for this story
                                      The following wrap instantiation was coopting the existing licensesToBeSaved (if any),
                                      so that (e.g.) by the time 3 new wraps had been added to licensesToBeSaved, it
                                      contained three versions of the third license, so only that one got saved.
                                      TransferAndAdjustmentProcessCC.LineWrap wrap = licensesToSend.get(Item.TransferredToCompanyXcode);*/

                                    TransferAndAdjustmentProcessCC.LineWrap wrap = new TransferAndAdjustmentProcessCC.LineWrap();
                                    wrap.License.Xcode__c = licensesToSend.get(Item.TransferredToCompanyXcode).License.xcode__c;
                                    Integer transferQuantity = Item.TransferQuantity != null ? Item.TransferQuantity : 0;
                                    wrap.License.SiteLicenseID__c = String.valueOf(Item.TransferredToLicenseID);
                                    wrap.License.TransferAmount__c = transferQuantity;
                                    wrap.License.AvailableInventory__c = transferQuantity; //JFreese 10/20/16 this seems suspicious
                                    wrap.License.QuantityProvisioned__c = transferQuantity;
                                    wrap.License.OrderLineItem__c = Item.LineItemID;
                                    wrap.License.LicenseID__c = parentLicense.Id;
                                    system.debug('wrap=' + wrap);
                                    system.debug('check 2A licensesToBeSaved='+licensesToBeSaved);


                                    system.debug('licenseIdMap='+licenseIdMap);
                                    if(licenseIdMap.containsKey(wrap.License.SiteLicenseID__c)){
                                        system.debug('New license ' + wrap.License.SiteLicenseID__c + ' is in the licenseIdMap: Update its quantities');
                                        LicenseID__c newLicense = (LicenseID__c)licenseIdMap.get(wrap.License.SiteLicenseID__c);
                                        Decimal newVal = newLicense.AvailableInventory__c == null ? 0 : newLicense.AvailableInventory__c;
                                        Decimal oldVal = wrap.License.AvailableInventory__c == null ? 0 : wrap.License.AvailableInventory__c;
                                        newLicense.AvailableInventory__c = newVal + oldVal;
                                        newLicense.QuantityProvisioned__c = newVal + oldVal;
                                        system.debug('Combined oldVal ' + oldVal + ' and newVal ' + newVal + ' into newLicense: ' + newLicense);
                                        licensesToBeSaved.add(newLicense);
                                        //Prashant
                                        newLicenseMap.put(newLicense.LicenseID__c,newLicense);
                                        //End
                                    }else{
                                        system.debug('New license ' + wrap.License.SiteLicenseID__c + ' is not in the licenseIdMap');
                                        //newLicenseToInsert.add(wrap.License);
                                        licensesToBeSaved.add(wrap.License);
                                        //Prashant
                                        newLicenseMap.put(wrap.License.LicenseID__c,wrap.License);
                                        //End
                                    }
                                    if(wrap.License.Xcode__c != null){
                                        xcodeIdOfLicenseSet.add(wrap.License.Xcode__c);
                                    }
                                    Integer parentAvailable = parentLicense.AvailableInventory__c != null ? Integer.valueOf(parentLicense.AvailableInventory__c) : 0;
                                    Integer available = parentAvailable - transferQuantity;
                                    parentLicense.AvailableInventory__c = available > 0 ? Decimal.valueOf(available) : 0;
                                    if(!parentToUpdate.containsKey(parentLicense.Id)){
                                        parentToUpdate.put(parentLicense.Id, parentLicense);
                                    }
                                }
                            }
                        }
                    }

                    /*
                    //If there is already a license with the same site id, the transfered quantity will be added to that license do not create a new license
                    LicenseID__c[] existingLicenses = [SELECT SiteLicenseID__c,Name, AvailableInventory__c, Xcode__c
                                                            FROM LicenseID__c
                                                            WHERE OrderLineItem__c = :pOrderLineItem.Id  and SiteLicenseID__c!=null];

                    map<String, Sobject> licenseIdMap = sCollection.stringMap(existingLicenses, 'SiteLicenseID__c');


                    list<LicenseID__c> licensesToBeSaved = new list<LicenseID__c>();
                    for(LicenseID__c LID : newLicenseToInsert){
                        if(licenseIdMap.containsKey(LID.SiteLicenseID__c)){
                            system.debug('^^^Found existing matching LicenseID__c record for license ' + LID + ' - will add to its Available Inventory and Quantity Provisioned');
                            LicenseID__c newLicense = (LicenseID__c)licenseIdMap.get(LID.SiteLicenseID__c);
                            Decimal newVal = newLicense.AvailableInventory__c == null ? 0 : newLicense.AvailableInventory__c;
                            Decimal oldVal = LID.AvailableInventory__c == null ? 0 : LID.AvailableInventory__c;
                            newLicense.AvailableInventory__c = newVal + oldVal;
                            newLicense.QuantityProvisioned__c = newVal + oldVal;
                            system.debug('^^^Combined oldVal ' + oldVal + ' and newVal ' + newVal + ' to set AvailableInventory__c=' + newLicense.AvailableInventory__c + ' and QuantityProvisioned__c=' + newLicense.QuantityProvisioned__c);
                            licensesToBeSaved.add(newLicense);
                        }else{
                            licensesToBeSaved.add(LID);
                        }
                    }*/

                    if(!parentToUpdate.isEmpty()){
                        licensesToBeSaved.addAll(parentToUpdate.values());
                    }

                    /*S-445896 JFreese Appirio - add debugs to the cleaning process
                        The upsert below can result in EXCEPTION_THROWN|[1451]|System.ListException: Duplicate id in list: a64q00000000LQxAAM
                        This now seems to occur only (?) when an xcode is not fully set up on site, in which case
                        the "Summary of information returned from Site:" in the log will have a Description like
                        "Cannot transfer license because of invalid BoardID and CompanyID combination.
                         - LicenseID: 266545453; CompanyXCode: xtest116x"
                        Then all the (subsequent?) transactions will fail (have no description)
                        and the upsert will generate the duplicate exception.
                        Manisha said this (broken xcode) is a rare corner case on Prod, so not to focus on it.
                        But it is all too common on Dev and probably not uncommon on QA, so adding debugs.*/
                    if(!licensesToBeSaved.isEmpty()){
                        system.debug('^^^ Before cleaning, ' + licensesToBeSaved.size() + ' licensesToBeSaved:');
                        for(LicenseID__c lid : licensesToBeSaved){
                            System.debug('SiteLicenseID__c=' + lid.SiteLicenseID__c + ', ' + 'Xcode__c=' + lid.Xcode__c + ', ' + 'TransferAmount__c=' + lid.TransferAmount__c + ', ' + 'AvailableInventory__c=' + lid.AvailableInventory__c + ', ' + 'QuantityProvisioned__c=' + lid.QuantityProvisioned__c + ', ' + 'OrderLineItem__c=' + lid.OrderLineItem__c + ', ' + 'LicenseID__c=' + lid.LicenseID__c);
                        }
                        set<LicenseID__c> cleaner = new set<LicenseID__c>();
                        cleaner.addAll(licensesToBeSaved);
                        system.debug('^^^ ' + cleaner.size() + ' records in cleaner:');
                        for(LicenseID__c lid : cleaner){
                            System.debug('SiteLicenseID__c=' + lid.SiteLicenseID__c + ', ' + 'Xcode__c=' + lid.Xcode__c + ', ' + 'TransferAmount__c=' + lid.TransferAmount__c + ', ' + 'AvailableInventory__c=' + lid.AvailableInventory__c + ', ' + 'QuantityProvisioned__c=' + lid.QuantityProvisioned__c + ', ' + 'OrderLineItem__c=' + lid.OrderLineItem__c + ', ' + 'LicenseID__c=' + lid.LicenseID__c);
                        }
                        licensesToBeSaved.clear();
                        licensesToBeSaved.addAll(cleaner);
                        system.debug('^^^ After cleaning, ' + licensesToBeSaved.size() + ' licensesToBeSaved to be upserted:');
                        for(LicenseID__c lid : licensesToBeSaved){
                            System.debug('SiteLicenseID__c=' + lid.SiteLicenseID__c + ', ' + 'Xcode__c=' + lid.Xcode__c + ', ' + 'TransferAmount__c=' + lid.TransferAmount__c + ', ' + 'AvailableInventory__c=' + lid.AvailableInventory__c + ', ' + 'QuantityProvisioned__c=' + lid.QuantityProvisioned__c + ', ' + 'OrderLineItem__c=' + lid.OrderLineItem__c + ', ' + 'LicenseID__c=' + lid.LicenseID__c);
                        }
                        upsert licensesToBeSaved;
                    }
                    output.add('Transfer completed.');
                }
            }
        }catch(Exception e){
            system.debug('\n\nError: ' + e + '\nTrace: ' + e.getStackTraceString() + '\n\n');
            output.add('Encountered error: ' + e);
        }

        return output;
    }

    //BizAppsSiteModel.GetLicenseAndRelativesForCreditRequest(new set<String>{'241807998'});
    public static map<String, Integer> GetLicenseAndRelativesForCreditRequest(set<String> pSiteLicenseIdSet){
        system.debug('\n\n**** Inside BizAppsSiteModel.GetLicenseAndRelativesForCreditRequest()\n\n');
        try{
            /*S-445896 JFreese Appirio 12/1/16 We should only send ONE License ID to Site, to avoid APEX Heap error.
                Per Apttus (Sivaganesh Ramakrishnan 13Nov2016) sending any license in a family
                tree returns the whole tree structure, so we only need to send one.

                This has been fixed in:
                1) TransferAndAdjustmentProcessCC.cls (which prompted this story)
                2) CreditRequestCX.cls; checkInventoryQuantity() & init()
                3) CreditRequestTriggerHelper.cls: used in createOrderForCreditRequestAndProposal()
                4) CreateCreditOrderFromCreditRequest.cls

                It has not been fixed in:
                1) AccountAdvancedQuoteHelper.cls (callout is not not currently used)
                2) TransferAdjustmentAccountAccessCC.cls (all references commented out)*/

            v3_monsterBizappsSiterouterSiterouterws.ArrayOfGetLicenseAndRelativesReq request = new v3_monsterBizappsSiterouterSiterouterws.ArrayOfGetLicenseAndRelativesReq();
            request.GetLicenseAndRelativesReq = new v3_monsterBizappsSiterouterSiterouterws.GetLicenseAndRelativesReq[]{};
            for(String license : pSiteLicenseIdSet){
                if(license.length() > 9){
                    continue;
                }
                Integer siteLicense = Integer.valueOf(license);
                v3_monsterBizappsSiterouterSiterouterws.GetLicenseAndRelativesReq req = new v3_monsterBizappsSiterouterSiterouterws.GetLicenseAndRelativesReq();
                req.LicenseID = siteLicense;
                //req.LicenseID = license;
                request.GetLicenseAndRelativesReq.add(req);
            }
            system.debug('^^^ request='+request);

            //Jeff L 08/17 - added an extra check in case there is no values - if there are none then the websevice just returns an error instead
            if(request.GetLicenseAndRelativesReq.size() > 0){
                v3_monsterBizappsSiterouterSiterouterws.legacy connection = new v3_monsterBizappsSiterouterSiterouterws.legacy();
                v3_monsterBizappsSiterouterSiterouterws.ArrayOfGetLicenseAndRelativesResp response = connection.GetMultipleLicenseAndRelatives(request);
                system.debug('res:::'+response);

                if(response.GetLicenseAndRelativesResp != null){
                    return PrepResponseForGetLicenseAndRelativesForCreditRequest(response.GetLicenseAndRelativesResp, pSiteLicenseIdSet);
                }
            }

        }catch(Exception e){
            system.debug('\n\nGetLicenseAndRelativesForCreditRequest error: '+e+'\n'+e.getStackTraceString()+'\n\n');
            throw e;
        }
        return null;
    }

    private static map<String, Integer> PrepResponseForGetLicenseAndRelativesForCreditRequest(v3_monsterBizappsSiterouterSiterouterws.GetLicenseAndRelativesResp[] pResponse, set<String> pSiteLicenseIdSet){
        system.debug('\n\n**** Inside BizAppsSiteModel.PrepResponseForGetLicenseAndRelativesForCreditRequest()\n\n');

        map<String, Integer> returnOutput = new map<String, Integer>();

        String output = '\n\n';
        for(v3_monsterBizappsSiterouterSiterouterws.GetLicenseAndRelativesResp result : pResponse){
            if(result.GetLicenseAndRelativesResponseItems != null && result.GetLicenseAndRelativesResponseItems.GetLicenseAndRelativesResponseItem != null && result.GetLicenseAndRelativesResponseItems.GetLicenseAndRelativesResponseItem.size() > 0){
                output += 'size: ' + result.GetLicenseAndRelativesResponseItems.GetLicenseAndRelativesResponseItem.size();
                for(v3_monsterBizappsSiterouterSiterouterws.GetLicenseAndRelativesResponseItem item : result.GetLicenseAndRelativesResponseItems.GetLicenseAndRelativesResponseItem){
                    output += '\n CompanyName:' + item.CompanyName;
                    output += '\n CompanyXcode:' + item.CompanyXcode;
                    output += '\n AvailableQuantity:' + item.AvailableQuantity;
                    output += '\n Quantity:' + item.Quantity;
                    output += '\n Consumable:' + item.Consumable;
                    output += '\n OriginalLicenseID:' + item.OriginalLicenseID;
                    output += '\n ResourceACLID:' + item.ResourceACLID;
                    output += '\n ResourceLicenseID:' + item.ResourceLicenseID;
                    output += '\n TransferredFromLicenseID:' + item.TransferredFromLicenseID;
                    output += '\n ItemResult:\n';
                    returnOutput.put(String.valueOf(item.ResourceLicenseID), item.AvailableQuantity);
                }
            }
        }
        system.debug(output + '\n\n');
        return returnOutput;
    }

    //Used for Jeff's Testing purposes - please do not use
    //BizAppsSiteModel.GetLicenseAndRelativesForCreditRequest(new set<String>{'241807998'});
/*    public static map<String, Integer> GetLicenseAndRelativesForCreditRequestJeff(set<String> pSiteLicenseIdSet){
        system.debug('\n\n**** Inside BizAppsSiteModel.GetLicenseAndRelativesForCreditRequest()\n\n');
        try{
            v3_monsterBizappsSiterouterSiterouterws.ArrayOfGetLicenseAndRelativesReq request = new v3_monsterBizappsSiterouterSiterouterws.ArrayOfGetLicenseAndRelativesReq();
            request.GetLicenseAndRelativesReq = new v3_monsterBizappsSiterouterSiterouterws.GetLicenseAndRelativesReq[]{};
            for(String license : pSiteLicenseIdSet){
                if(license.length() > 9){
                    continue;
                }
                Integer siteLicense = Integer.valueOf(license);
                v3_monsterBizappsSiterouterSiterouterws.GetLicenseAndRelativesReq req = new v3_monsterBizappsSiterouterSiterouterws.GetLicenseAndRelativesReq();
                req.LicenseID = siteLicense;
                //req.LicenseID = license;
                request.GetLicenseAndRelativesReq.add(req);
            }

            //Jeff L 08/17 - added an extra check in case there is no values - if there are none then the websevice just returns an error instead
            if(request.GetLicenseAndRelativesReq.size() > 0){
                v3_monsterBizappsSiterouterSiterouterws.legacy connection = new v3_monsterBizappsSiterouterSiterouterws.legacy();
                System.debug('Jeff Test: Before Limit Heap Size ' + Limits.getHeapSize());
                System.debug('Jeff Test: Before Limit CPU Time ' + Limits.getCpuTime());
                v3_monsterBizappsSiterouterSiterouterws.ArrayOfGetLicenseAndRelativesResp response = connection.GetMultipleLicenseAndRelativesJeff(request);
                System.debug('Jeff Test: After Limit Heap Size ' + Limits.getHeapSize());
                System.debug('Jeff Test: After Limit CPU Time ' + Limits.getCpuTime());
                system.debug('res:::'+response);
                if(response.GetLicenseAndRelativesResp != null){
                    return PrepResponseForGetLicenseAndRelativesForCreditRequestJeff(response.GetLicenseAndRelativesResp, pSiteLicenseIdSet);
                }
            }

        }catch(Exception e){
            system.debug('\n\nGetLicenseAndRelativesForCreditRequest error: '+e+'\n'+e.getStackTraceString()+'\n\n');
            throw e;
        }
        return null;
    }
*/

    //Used for Jeff's Testing purposes - please do not use
/*    private static map<String, Integer> PrepResponseForGetLicenseAndRelativesForCreditRequestJeff(v3_monsterBizappsSiterouterSiterouterws.GetLicenseAndRelativesResp[] pResponse, set<String> pSiteLicenseIdSet){
        system.debug('\n\n**** Inside BizAppsSiteModel.PrepResponseForGetLicenseAndRelativesForCreditRequest()\n\n');

        map<String, Integer> returnOutput = new map<String, Integer>();

        String output = '\n\n';
        for(v3_monsterBizappsSiterouterSiterouterws.GetLicenseAndRelativesResp result : pResponse){
            if(result.GetLicenseAndRelativesResponseItems != null && result.GetLicenseAndRelativesResponseItems.GetLicenseAndRelativesResponseItem != null && result.GetLicenseAndRelativesResponseItems.GetLicenseAndRelativesResponseItem.size() > 0){
                output += 'size: ' + result.GetLicenseAndRelativesResponseItems.GetLicenseAndRelativesResponseItem.size();
                for(v3_monsterBizappsSiterouterSiterouterws.GetLicenseAndRelativesResponseItem item : result.GetLicenseAndRelativesResponseItems.GetLicenseAndRelativesResponseItem){
                    output += '\n CompanyName:' + item.CompanyName;
                    output += '\n CompanyXcode:' + item.CompanyXcode;
                    output += '\n AvailableQuantity:' + item.AvailableQuantity;
                    output += '\n Quantity:' + item.Quantity;
                    output += '\n Consumable:' + item.Consumable;
                    output += '\n OriginalLicenseID:' + item.OriginalLicenseID;
                    output += '\n ResourceACLID:' + item.ResourceACLID;
                    output += '\n ResourceLicenseID:' + item.ResourceLicenseID;
                    output += '\n TransferredFromLicenseID:' + item.TransferredFromLicenseID;
                    output += '\n ItemResult:\n';
                    returnOutput.put(String.valueOf(item.ResourceLicenseID), item.AvailableQuantity);
                }
            }
        }
        system.debug(output + '\n\n');
        return returnOutput;
    }
*/

/*
** @author : Appirio (JefF)
** @date : 10/29/2015
** @description : there are a set of Credit reasons that do not send data to site, they are contained in a
                   custom setting, this small method checks and returns if an order should be sent to site or not
** @paramaters : String reason to check (credit reason from an order)
** @returns : Boolean
*/
    private static boolean isSentToSite(String reasonToCheck){
        system.debug('\n\n**** Inside BizAppsSiteModel.isSentToSite()\n\n');

        //we store the set of reasons in a custom setting, create a set from it so our checks are fast

        Set<String> setOfReasons = new Set<String>();
        for(CreditReasonSiteBypass__c cr : CreditReasonSiteBypass__c.getAll().Values()){
            setOfReasons.add(cr.Credit_Reason__c);
        }
            system.debug('!!!isSentToSite reasonToCheck ' + reasonToCheck);
            system.debug('!!!isSentToSite setOfReasons '+ setOfReasons);

        if(setOfReasons.contains(reasonToCheck)){
            return false;
        }
        else{
            return true;
        }
        //return !setOfReasons.contains(reasonToCheck);
    }
/*
** @author : Appirio (JefF)
** @date : 10/29/2015
** @description : There are a special set of credit reasons that do not flow anything to Site,
                    Instead we assigned the original Order's Liceneses to the rebill orders line items
** @paramaters : List of orders
** @returns : Boolean
*/
    private static void assignLicensesToCreditAndRebill(List<Order__c> orderList){
        system.debug('*** Inside of assignLicensesToCreditAndRebill');
        /*if this is a credit Order, then we just make sure it is set to Verified and call it a day (the real logic happens on the Rebill)
        if this is the rebill order, we need to get the Orderlineitems, get the original order line items, find their licenses and move the licesnses
        from the original order line items in the rebill order line items*/
        List<Order__c> creditOrdersToMarkAsVerified = new List<Order__c>(); //our credit orders that will be marked as verified
        Set<Id> rebillOrdersToProcess = new Set<Id>(); //our rebill orders that we will get line items for
        Set<Id> creditRequestIds = new Set<Id>();

        for(Order__c order : orderList){
            system.debug('Inside of Order loop rebill?' + order.is_rebill__c + ' credit? ' + order.is_credit__c + ' ID: ' + order.Id);
            if(order.is_rebill__c){
                rebillOrdersToProcess.add(order.Id);
                creditRequestIds.add(order.CreditRequest__c);
            }

            system.debug('Order Status? ' + order.OrderStatus__c + ', organization=' + order.AccountOrganization__c);
            if(order.OrderStatus__c != 'Verified' && order.AccountOrganization__c != 'Europe'){
                Order__c updateOrder = new Order__c(id=order.Id,OrderStatus__c = 'Verified');
                creditOrdersToMarkAsVerified.add(updateOrder);
            }
        }

        //now that we have the list of rebill order Ids, lets get their line items and put it in a map
        //of credit request IDs
        Map<Id,List<Order_Line_Item__c>> newLineMap = new Map<Id,List<Order_Line_Item__c>>();
        For(Order_Line_Item__c oli : [Select Id, Product__c, Quantity2__c, Xcode_lkp__c, Order__r.CreditRequest__c
            from Order_Line_Item__c where Order__c IN :rebillOrdersToProcess]){
             /*List<Order_Line_Item__c> oliList = newLineMap.get(oli.Order__r.CreditRequest__c);
            if(oliList == null){
                oliList = new List<Order_Line_Item__c>();
                newLineMap.put(oli.Order__r.CreditRequest__c,oliList);
            }
            oliList.add(oli);*/

            if(!newLineMap.containskey(oli.Order__r.CreditRequest__c))
                newLineMap.put(oli.Order__r.CreditRequest__c , new list<Order_Line_Item__c>());

            newLineMap.get(oli.Order__r.CreditRequest__c).add(oli);
        }
        //lets get a map of orderlineItem Ids to credit requests and a set to query the line items and licenses with
        Map<Id,CreditRequestLineItem__c> oldLineMap = new Map<Id,CreditRequestLineItem__c>();
        For(CreditRequestLineItem__c crli : [Select Id, Credit_Request__c, Order_Line_Item__c, Order_Line_Item__r.Product__c,
            Order_Line_Item__r.Quantity2__c, Order_Line_Item__r.Xcode_lkp__c
            from CreditRequestLineItem__c where Credit_Request__c in :creditRequestIds]){

            oldLineMap.put(crli.Order_Line_Item__c,crli);
        }

        //And now we can finally query the licenses, match them to the right new Order line item, and update them
        List<LicenseID__c> licsToUpdate = new List<LicenseId__c>();
        set<Id> licIds = new set<Id>();
        Set<Id> matchedLicenses = new Set<Id>();
        //List<Order_Line_Item__c> oliAmountsToUpdate = new List<Order_Line_Item__c>();
        for(LicenseId__c lic : [Select Id, OrderLineItem__c from LicenseId__c where OrderLineItem__c in :oldLineMap.keyset()]){
            CreditRequestLineItem__c crli = oldLineMap.get(lic.OrderLineItem__c);
            system.debug('>>>>>>>>>>>>>>' + newLineMap.get(crli.Credit_Request__c));
            For(Order_Line_Item__c oli : newLineMap.get(crli.Credit_Request__c)){
            system.debug('>>>>>>>>>>>>>>' + oli.Product__c + '>>>>>>>>>>>>' + oli.Xcode_lkp__c);
            system.debug('>>>>>>>>>>>>>>' + crli.Order_Line_Item__r.Product__c + '>>>>>>>>>>>>' + crli.Order_Line_Item__r.Xcode_lkp__c);
                if(!matchedLicenses.contains(oli.Id) && !licIds.contains(lic.Id)){
                    //now try and match based upon product and quantity and xcodeaccount
                    if(oli.Product__c == crli.Order_Line_Item__r.Product__c &&
                        oli.Xcode_lkp__c == crli.Order_Line_Item__r.Xcode_lkp__c){
                        system.debug('Matched!! ' + oli + ' ' + crli);
                        lic.OrderLineItem__c = oli.Id;
                        licsToUpdate.add(lic);
                        matchedLicenses.add(oli.Id);
                        licIds.add(lic.Id);
                        //Now we need to update the remaining credit amounts on the orginial line item
                        //so that users cannot create another credit request for amounts
                        /*Order_Line_Item__c oldOLI = crli.Order_Line_Item__r;
                        oldOLI.GrossRemainingCreditAmount__c = 0;
                        oldOLI.NetRemainingCreditAmount__c = 0;
                        oldOLI.Remaining_Credit_Amount__c = 0;
                        oliAmountsToUpdate.add(oldOLI);*/

                    }
                }
            }
        }

        //lets update and licenses that have new OLI's now
        if(!licsToUpdate.isEmpty()){
            system.debug('Lics to update' + licsToUpdate);
            update licsToUpdate;
        }

        //Lets update the old order line items so that they no longer have
        //any remaining credits
        /*if(!oliAmountsToUpdate.isEmpty()){
            update oliAmountsToUpdate;
        }*/


        //lets update the credit orders
        if(!creditOrdersToMarkAsVerified.isEmpty()){
            OrderTriggerHandler.ExecuteTriggers = false;
            update creditOrdersToMarkAsVerified;
            OrderTriggerHandler.ExecuteTriggers = true;
        }
    }
}