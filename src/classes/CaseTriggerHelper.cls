public without sharing class CaseTriggerHelper {
    final static String CLASSNAME = '\n\n**** CaseTriggerHelper.METHODNAME()';

    private String UserProfileName{get; private set;}

    public static Set<Id> AutoResponseContactsDelete = new Set<Id>();
    public static Set<id> ContactsCreated = new Set<id>();
    public static Set<id> PersonAccountsRemove = new Set<id>();
    public static Boolean isExecuted = false;
    public static Map<Id, Profile> mySelectedProfileMap = new Map<Id, Profile>();





/*
** @author : Cloud Sherpas Inc.
** @date : 04/17/2014
** @description : static method that instantiates a new instance of the class & sets the user's profile name member variable
** @paramaters : a string - the profile name for the current user
** @returns : a new instance of the AccountTriggerHelper class
*/
    public static CaseTriggerHelper NewTriggerHelper(String pUserProfileName){

        //final string METHODNAME = CLASSNAME.replace('METHODNAME','NewTriggerHelper');
        //system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        CaseTriggerHelper newHelper = new CaseTriggerHelper(pUserProfileName);
        /*Jeff L I-230503 Commented out - since we are calling this SAME EXACT QUERY IN THE METHOD ABOVE!
        for(Profile prof : [SELECT Id from Profile where Name IN ('Service Rep (NA)','Sales Rep (NA)')])
            {
               mySelectedProfileMap.put(prof.Id, prof);
            } */
        return newHelper;
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 04/09/2014
** @description : this method is the class constructor
** @paramaters : String user profile name
** @returns : nothing
*/
    private CaseTriggerHelper(String pUserProfileName){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','CaseTriggerHelper');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        //Jeff L I-230503 added this change, don't need to requery if our static variable is already populated
        /*if(mySelectedProfileMap.keySet().size() == 0){
            for(Profile prof : [SELECT Id from Profile where Name IN ('Service Rep (NA)','Sales Rep (NA)')]) {
               mySelectedProfileMap.put(prof.Id, prof);
            }
        }*/

    }

/* Jeff L commented out - this logic is no longer needed due to adding a Catch All queue for cases that are un-assigned to users
** @author : Cloud Sherpas, Inc.
** @date : 05/16/2014
** @Story : 0247
** @Element : E1626
** @description : If the Primary Service Rep is populated on Account, and the case to be created/updated
                  for that Account then assign the Primary Service Rep
                  As Owner of that Case
** @paramaters : list of Cases and Map of CaseIdToCase
** @returns : nothing
*/
 /*   public void updateCaseOwnerWithAccountsPrimaryServiceRep(Case[] pNewCases, Map<Id, Case> pOldCasesMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateCaseOwnerWithAccountsPrimaryServiceRep');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        system.debug('>>>>>>>>>>>>>>>>>>0');
        Map<Id, Account> accountMap = new Map<Id, Account>();
        Set<Id> accountIdSet = new Set<Id>();
        List<Case> updateCaseList = new List<Case>();
        system.debug('>>>>>>>>>>>>>>>>>>1');
        map<String, map<String, Id>> CaseRecordTypes = Utility.GetRecordTypeIdsBySObjectNameSet(new set<string>{'Case'});
       // Id caseProductImplementationRecordTypeId = CaseRecordTypes.get('Case').get('Product Implementation'); as per task T-407869
        system.debug('>>>>>>>>>>>>>>>>>>2');
        for (Case updatedCase : pNewCases) {
            accountIdSet.add(updatedCase.AccountId);
        }
        system.debug('>>>>>>>>>>>>>>>>>>3'+accountIdSet);
        Set<Id> PrimaryServiceRepUserId = new Set<Id>();
        map<Id, User> PrimaryServiceRepUsersMap = new Map<Id,User>();
        for(Account acc : [Select id, PrimaryServiceRep__c, PrimaryServiceRep__r.Email, PrimaryServiceRep__r.FirstName From Account Where Id IN : accountIdSet]) {
            accountMap.put(acc.Id, acc);
            system.debug(acc);
            PrimaryServiceRepUserId.add(acc.PrimaryServiceRep__c);

            //Jeff L moved the logic around to remove extra queries
            User rep = new User();
            rep.Id = acc.PrimaryServiceRep__c;
            rep.Email = acc.PrimaryServiceRep__r.Email;
            rep.FirstName = acc.PrimaryServiceRep__r.FirstName;

            PrimaryServiceRepUsersMap.put(rep.Id, rep);
        }
        system.debug('>>>>>>>>>>>>>>>>>>4');
        //Jeff L Appirio Commented out to fix issue with too many queries (moved map logic into query above)
        //map<Id, User> PrimaryServiceRepUsersMap = new map<Id, User>([SELECT Email, Id, FirstName FROM User WHERE Id IN :PrimaryServiceRepUserId]);

        for (Case updatedCase : pNewCases) {
            //system.debug('>>>>>>>>>>>>>>>>>>6'+accountMap.get(updatedCase.AccountId).PrimaryServiceRep__c);
            if((accountMap.containsKey(updatedCase.AccountId) && accountMap.get(updatedCase.AccountId).PrimaryServiceRep__c!=NULL)  && (trigger.isInsert || (trigger.isUpdate && (updatedCase.RecordTypeId!= pOldCasesMap.get(updatedCase.id).RecordTypeId || updatedCase.OwnerId != pOldCasesMap.get(updatedCase.id).OwnerId)))) {
                 system.debug('>>>>>>>>>>>>>>>>>>7');
                updatedCase.OwnerId = accountMap.get(updatedCase.AccountId).PrimaryServiceRep__c;
                //sends an email to the assigned primary service rep
                User primaryServiceRep = PrimaryServiceRepUsersMap.get(accountMap.get(updatedCase.AccountId).PrimaryServiceRep__c);
                system.debug('>>>>>>>>>>>>>>>>>>5');
                if(primaryServiceRep != null && Trigger.isUpdate){

                    String msg = 'Hi ' + primaryServiceRep.FirstName + '<br /><br />';
                    msg += 'Case <a href=\'/' + updatedCase.Id + '\'>'+updatedCase.CaseNumber+' hase been assigned to you.<br /><br />Regards,';

                    Messaging.Singleemailmessage mail = new Messaging.Singleemailmessage();
                    mail.setToAddresses(new String[]{primaryServiceRep.Email});
                    mail.setSubject('Case Primary Service Rep Assignment Notification');
                    mail.setSenderDisplayName('Salesforce.com');
                    mail.setHtmlBody(msg);
                    Messaging.sendEmail(new Messaging.Email[]{mail}, false);
                }
                //updateCaseList.add(updatedCase);
            }

            //update updateCaseList;
        }
    }*/

    public void updateCaseSLADates(Case[] pNewCases, Map<Id, Case> pOldCasesMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateCaseSLADates');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        BusinessHours defaultHours = [select Id from BusinessHours where IsDefault=true];
        for(Case updatedCase : pNewCases) {
            System.Debug('###'+updatedCase.BusinessHoursId);
            System.Debug('###'+updatedCase.FirstContactCommitment__c);
            if(trigger.isUpdate)System.Debug('###'+pOldCasesMap.get(updatedCase.Id).FirstContactCommitment__c);
            System.Debug('###'+updatedCase.ResolutionCommitment__c);
            if(trigger.isUpdate)System.Debug('###'+pOldCasesMap.get(updatedCase.Id).ResolutionCommitment__c);
            Id hoursToUse = updatedCase.BusinessHoursId!=null?updatedCase.BusinessHoursId:defaultHours.Id;
            if((updatedCase.FirstContactCommitment__c!=NULL) && (trigger.isInsert || (trigger.isUpdate && updatedCase.FirstContactCommitment__c!= pOldCasesMap.get(updatedCase.Id).FirstContactCommitment__c))) {
                long l1 = long.valueOf(string.valueof(updatedCase.FirstContactCommitment__c*3600000));
                System.Debug('### here');
                if(trigger.isInsert) {
                    updatedCase.FirstContactSLA__c = BusinessHours.add(hoursToUse, system.now(), l1);
                }
                else {
                    updatedCase.FirstContactSLA__c = BusinessHours.add(hoursToUse, updatedCase.CreatedDate, l1);
                }
            }
            if(updatedCase.ResolutionCommitment__c!=NULL && (trigger.isInsert || (trigger.isUpdate && updatedCase.ResolutionCommitment__c!= pOldCasesMap.get(updatedCase.Id).ResolutionCommitment__c))) {
                long l2 = long.valueOf(string.valueof(updatedCase.ResolutionCommitment__c*3600000));
                if(trigger.isInsert) {
                    updatedCase.ResolutionSLA__c = BusinessHours.add(hoursToUse, system.now(), l2);
                }
                else {
                    updatedCase.ResolutionSLA__c = BusinessHours.add(hoursToUse, updatedCase.CreatedDate, l2);
                }
            }
        }
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 05/27/2014
** @Story : 0247
** @Element : E1553
** @description : calls assignCaseOwnerWithOrderSentToVerificationByAsync @future method to:
                        if the Case.Account Organization = Europe and Case.Account Service Tier = Core
                        assign the case to the User in the Order.SentToVerificationBy2__c field on Order.
** @returns : nothing
*/
    public void updateCaseOwnerWithOrderSentToVerificationBy(List<Case> pNewCases, map<Id, Case> pOldCaseMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateCaseOwnerWithOrderSentToVerificationBy');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        map<String, map<String, Id>> OrderAndCaseRecordTypes = Utility.GetRecordTypeIdsBySObjectNameSet(new set<string>{'Case'});
        Id caseProductImplementationRecordTypeId = OrderAndCaseRecordTypes.get('Case').get('Product Implementation');

        //Synchronous solution
        set<Id> orderIdSet = new set<Id>();
        for(Case c : pNewCases){
            if(c.RecordTypeId == caseProductImplementationRecordTypeId && c.Order__c != null){
                orderIdSet.add(c.Order__c);
            }
        }
        if (orderIdSet.size() > 0) {
            map<Id, Order__c> caseOrderMap = new map<Id, Order__c> ([
                SELECT SentToVerificationBy2__r.Name, SentToVerificationBy2__c, Id, Account__r.ServiceTier__c, Account__r.Organization__c
                FROM Order__c WHERE Id IN :orderIdSet
            ]);
            if (caseOrderMap.size() > 0) {
                for(Case newCase : pNewCases){
                    Order__c caseOrder = caseOrderMap.get(newCase.Order__c);
                    //system.debug('\n\n'+newCase.Subject +'\nSentToVerificationBy2__c: '+caseOrder.SentToVerificationBy2__c);
                    if(caseOrder != null){
                        if(caseOrder.SentToVerificationBy2__c != null && caseOrder.Account__r.Organization__c == 'Europe' &&
                           (caseOrder.Account__r.ServiceTier__c == 'Core' || newCase.isMediaProduct__c) &&
                        (Trigger.isInsert || (Trigger.isUpdate && pOldCaseMap.get(newCase.Id).LastModifiedDate == pOldCaseMap.get(newCase.Id).CreatedDate))){
                            system.debug('^^^ Set case Subject: ' + newCase.Subject + ' owner to: ' + caseOrderMap.get(newCase.Order__c).SentToVerificationBy2__r.Name + ', ServiceTier__c=' + caseOrder.Account__r.ServiceTier__c + ', isMediaProduct=' + newCase.isMediaProduct__c);
                            newCase.OwnerId = caseOrderMap.get(newCase.Order__c).SentToVerificationBy2__c;
                        }else{
                            system.debug('Not updating owner for Case Subject: ' + newCase.Subject + ', Organization__c=' +caseOrder.Account__r.Organization__c + ', ServiceTier__c=' + caseOrder.Account__r.ServiceTier__c + ', isMediaProduct=' + newCase.isMediaProduct__c);
                        }
                    }
                }
            }
        }
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 05/27/2014
** @Story : 0899
** @Element : E1690
** @description : create related Case records for each Order Line Item that exists that contain a Product with Product Name that starts with "Media", excluding "Media: Career Ad Network"
                        These Case records will all be related to the Case that is already being created when Order Status = Verified. That "Parent Case" cannot be Closed until ALL child/related Cases are Closed.
** @returns : nothing
*/
 /*   public void createChildCaseForMediaOrderLineItems(Case[] pNewCases){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','createChildCaseForMediaOrderLineItems');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        try{
            Id prodImplementationTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Case', 'Product Implementation');

            map<Id,Id> relatedOrderIDToParentCaseId = new map<Id,Id>();
            set<Id> parentIdSet = new set<Id>();
            map<Id,Id> ParentCaseMap = new map<id,Id>();
            Set<Id> OrderIds = new set<Id>();
            for(Case pc : pNewCases){
                OrderIds.add(pc.OrderLineItem__c);
                if(pc.Order__c != null && pc.ParentId == null && pc.RecordTypeId == prodImplementationTypeId){
                    relatedOrderIDToParentCaseId.put(pc.Order__c, pc.Id);
                    parentIdSet.add(pc.Id);
                    system.debug('\n\n\n\n\n pc.OwnerId: '+pc.OwnerId +'\n\n\n\n\nId: '+ pc.Id);
                }
            }
            if(relatedOrderIDToParentCaseId.size() == 0){
                system.debug('No case that references order.');
                return;
            }
            Map<Id,String> OLIProductMap = new Map<Id,String>();
            Order__c[] relatadOrderList = [SELECT Id,
                                            (SELECT Id, ProductNameText__c, Quantity2__c, Name, Order__c,
                                                Product__r.Name, Product__r.Product_Line__c,
                                                Order__r.AccountOrganization__c, Order__r.Name
                                                FROM Order_Line_Items__r)
                                            FROM Order__c
                                            WHERE OrderStatus__c = 'Sent To Verification'
                                            AND Id IN :relatedOrderIDToParentCaseId.keySet()];

            Order_Line_Item__c[] OrderToLineItemList = new Order_Line_Item__c[]{};

            for(Order__c o : relatadOrderList){
                if(o.Order_Line_Items__r != null && o.Order_Line_Items__r.size() > 0){ //check if order has line items
                    for(Order_Line_Item__c oli : o.Order_Line_Items__r){ //loop all order line item
                        OrderToLineItemList.add(oli);
                        OLIProductMap.put(oli.Id,oli.Product__r.Product_Line__c);
                    }
                }
            }

            if(OrderToLineItemList.size() == 0){
                system.debug('No Media Order Line Item to create a case from.');
                return;
            }

            ID ADOPSQueue = User_Queue_IDs__c.getOrgDefaults().ADOPS_Queue__c;
            if(ADOPSQueue == null){
                system.debug('Failed to query ADOPS Queue');
                return;
            }

            Case[] toBeInserted = new Case[]{};
            for(Order_Line_Item__c oli : OrderToLineItemList){
                Case c = new Case();
                c.Subject = oli.ProductNameText__c + ' - Qty: ' + oli.Quantity2__c+ '- Order Id: ' + oli.order__r.Name;
                c.ParentId = relatedOrderIDToParentCaseId.get(oli.Order__c);
                c.OrderLineItem__c = oli.Id;
                c.RecordTypeId = prodImplementationTypeId;
                c.Order__c = oli.Order__c;
                if(isMediaProduct(oli.Product__r.Name) && oli.Order__r.AccountOrganization__c == 'North America'){ //check if line item is a Media line item
                    c.OwnerId = ADOPSQueue;
                }
                if(OLIProductMap.containsKey(oli.Id) && OLIProductMap.get(oli.Id) != null){
                    if(OLIProductMap.get(oli.Id) == 'Job Accessories--Inventory' ||
                       OLIProductMap.get(oli.Id) == 'JOB PACK' ||
                       OLIProductMap.get(oli.Id) == 'Banner-Button--Inventory'){
                        c.Status = 'Closed';
                    }
                }
                toBeInserted.add(c);
            }
            CaseTriggerHandler.ExecuteTriggers = false;
            insert toBeInserted;
            CaseTriggerHandler.ExecuteTriggers = true;
        }catch(Exception e){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Failed to create line item case(s). ', e);
        }
    }*/
/*
** @author : Cloud Sherpas, Inc.
** @date : 05/27/2014
** @Story : 0899
** @Element : E1690
** @description : Check to see if product name is a media type
** @returns : nothing
*/
    public Boolean isMediaProduct(String pProductName){
        return pProductName != null && pProductName.startsWith('Media') && pProductName != 'Media: Career Ad Network';
    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 05/27/2014
** @Story : 0899
** @Element : E1690
** @description : Check to see if all child cases that has order line items with a media product type is all closed
** @returns : nothing
*/
    public void AllChildCaseMediaTypeIsClosed(map<ID, Case> pCaseIdToUpdatedCaseMap, map<ID, Case> pCaseIdToOldCaseMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','AllChildCaseMediaTypeIsClosed');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

         try{
            Id prodImplementationTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Case', 'Product Implementation');
            system.debug('<<prodImplementationTypeId>>'+prodImplementationTypeId);//dps
            set<Id> caseIdToValidate = new set<Id>();
            for(Case pc : pCaseIdToUpdatedCaseMap.values()){
            system.debug('<<pc.Order__c>>' + pc.Order__c + '<<pc.ParentId>>' +pc.ParentId + '<<pc.RecordTypeId >>'  + pc.RecordTypeId + '<<pCaseIdToUpdatedCaseMap.get(pc.Id).Status>>'+pCaseIdToUpdatedCaseMap.get(pc.Id).Status +'<<pCaseIdToUpdatedCaseMap.get(pc.Id).IsClosed>>' + pCaseIdToUpdatedCaseMap.get(pc.Id).IsClosed);
            if(pc.Order__c != null && pc.ParentId == null && pc.RecordTypeId == prodImplementationTypeId &&
                (pCaseIdToUpdatedCaseMap.get(pc.Id).Status == 'Closed' && pCaseIdToUpdatedCaseMap.get(pc.Id).IsClosed)){
                    caseIdToValidate.add(pc.Id);
                    system.debug('<<pc.Id)>>'+pc.Id);//dps
                }
            }
            if(caseIdToValidate.size() == 0){
                system.debug('No case to validate.');
                return;
            }

            Case[] childCases = [SELECT isClosed, Status, Id, ParentId, Subject, CaseNumber
                                        FROM Case WHERE ParentId IN :caseIdToValidate
                                        /*AND Parent.Order__r.OrderStatus__c = 'Verified' */];
            map<Id, StringBuilder> caseIdToErrorMsg = new map<Id, StringBuilder>();

            for(Case cc : childCases){
                system.debug('<<caseIdToValidate>>'+caseIdToValidate);
                system.debug('<<cc.Status>>'+cc.Status);
                system.debug('<<caseIdToValidate.contains(cc.ParentId)>>'+caseIdToValidate.contains(cc.ParentId));
                if((cc.Status != 'Closed' && cc.Status != 'Cancelled') && caseIdToValidate.contains(cc.ParentId)){
                    if(!caseIdToErrorMsg.containsKey(cc.ParentId)){
                        caseIdToErrorMsg.put(cc.ParentId, StringBuilder.NewWithFirstValue(' Unable to close this case. Error: Unclosed order line item Case(s): '));
                    }

                    caseIdToErrorMsg.get(cc.ParentId).Append(cc.CaseNumber + ', ');
                    pCaseIdToUpdatedCaseMap.get(cc.ParentId).addError(caseIdToErrorMsg.get(cc.ParentId).AsString().removeEnd(', ') + '.');
                }
            }
         }catch(Exception e){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Failed to validate case line item(s). ', e);
         }
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 07/02/2014
** @Story : 0899
** @Element : E1727
** @description : Set Order Line Item "Implementation Complete" checkbox equal to TRUE when a related Case with a Product Implementation Record Type status equals closed
** @returns : nothing
*/
    public void SetOrderLineItemImplementationCompleteCheckbox(list<Case> pCaseList){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','SetOrderLineItemImplementationCompleteCheckbox');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        // create Order Line Item Id Set
        set<Id> orderLineItemIdSet = new set<Id>();
        for(Case oCase : pCaseList){
            if(oCase.OrderLineItem__c != null){
                orderLineItemIdSet.add(oCase.OrderLineItem__c);
            }
        }

        // get the Order Line Item Product Implementation Record Type Id
        //Id oliProductImplementationRecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Order_Line_Item__c', 'Product Implementation');
        Id caseRecordType = Utility.GetRecordTypeIdBySObjectNameAndType('Case', 'Product Implementation');

        // create a Order Line Item Id To Order Line Item Map
        map<Id, Order_Line_Item__c> orderLineItemIdToOrderLineItemMap = new map<Id, Order_Line_Item__c>([SELECT Id, ImplementationComplete__c, RecordTypeId FROM Order_Line_Item__c WHERE Id IN :orderLineItemIdSet]);
        list<Order_Line_Item__c> orderLineItemsToUpdate = new list<Order_Line_Item__c>();
        //system.assert(false,'<*pCaseList*>'+pCaseList+'<*caseRecordType*>'+caseRecordType);
        for(Case oCase : pCaseList){
            system.debug('>>oCase.Status ' + oCase.Status + 'oCase.RecordTypeId'+oCase.RecordTypeId +'>>caseRecordType' + caseRecordType);
            if(oCase.Status == 'Closed' && oCase.RecordTypeId == caseRecordType){
                if(orderLineItemIdToOrderLineItemMap.containskey(oCase.OrderLineItem__c)){
                    //if(orderLineItemIdToOrderLineItemMap.get(oCase.OrderLineItem__c).RecordTypeId == oliProductImplementationRecordTypeId && !orderLineItemIdToOrderLineItemMap.get(oCase.OrderLineItem__c).ImplementationComplete__c){
                    if(!orderLineItemIdToOrderLineItemMap.get(oCase.OrderLineItem__c).ImplementationComplete__c){
                        orderLineItemIdToOrderLineItemMap.get(oCase.OrderLineItem__c).ImplementationComplete__c = true;
                        orderLineItemsToUpdate.add(orderLineItemIdToOrderLineItemMap.get(oCase.OrderLineItem__c));
                    }
                }
            }
        }

        if(!orderLineItemsToUpdate.isEmpty()){
            try{
                OrderLineItemTriggerHandler.ExecuteTriggers = false;
                update  orderLineItemsToUpdate;
            }catch(DMLException dmlex){
                ExceptionLog.add(dmlex.getTypeName(), 'CaseTriggerHelper', 'SetOrderLineItemImplementationCompleteCheckbox', dmlex.getMessage());
                throw BaseApplicationException.NewException('CaseTriggerHelper.SetOrderLineItemImplementationCompleteCheckbox()', dmlex.getMessage());
            }
        }
    }

    /*
** @author : Cloud Sherpas, Inc.
** @date : 07/08/2014
** @Story : 0247
** @Element : E1730, E1822
** @description : Set the Child Case owner Id from Parent Case Owner Id.
** @param : Set of ParentId
** @returns : nothing
*/
    public Integer cCount = 0;
    public void caseOwnerUpdate(Case[] pUpdatedCases, map<ID, Case> pCaseIdToOldCaseMap){
      final string METHODNAME = CLASSNAME.replace('METHODNAME','caseOwnerUpdate');
      system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

      try{
            Id prodImplementationTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Case', 'Product Implementation');
          cCount++;
          String owners = '';
          map<Id, Case> ParentCaseIdToParentCaseMap = new map<Id, Case>();
          for(Case c : pUpdatedCases){
            owners += '\n\nCase: ' + c.CaseNumber;
            owners += '\nParentId: ' + c.ParentId;
            owners += '\nOrder: ' + c.Order__c;
            owners += '\nCreateDate: ' + pCaseIdToOldCaseMap.get(c.Id).CreatedDate;
            owners += '\nModifiedDate: ' + pCaseIdToOldCaseMap.get(c.Id).LastModifiedDate;
            owners += '\n\n';
            if(c.ParentId == null && c.Order__c != null && (pCaseIdToOldCaseMap.get(c.Id).CreatedDate == pCaseIdToOldCaseMap.get(c.Id).LastModifiedDate)){
              ParentCaseIdToParentCaseMap.put(c.Id, c);
            }
          }
          system.debug('\n\n'+cCount+'.) Utility caseOwnerUpdate test: ' +owners+ '\n\n');
          system.debug('<<ParentCaseIdToParentCaseMap>>'+ParentCaseIdToParentCaseMap);
          Case[] caseToUpdate = new Case[]{};
          for(Case c : [SELECT OwnerId, ParentId, Parent.Order__r.AccountOrganization__c, Parent.Account.PrimaryServiceRep__c,
                            OrderLineItem__r.Product__r.Name, RecordTypeId
                            FROM Case WHERE ParentId IN :ParentCaseIdToParentCaseMap.keySet()]){

            system.debug('<<inside ParentCaseIdToParentCaseMap>>');
            if(ParentCaseIdToParentCaseMap.containsKey(c.ParentId) && c.OrderLineItem__c != null){
                //For task E1822
                if(c.Parent.Order__r.AccountOrganization__c == 'Europe' && c.RecordTypeId == prodImplementationTypeId &&
                    c.Parent.Account.PrimaryServiceRep__c == null && isMediaProduct(c.OrderLineItem__r.Product__r.Name)){
                    c.OwnerId = UserInfo.getUserId();
                }else if(c.Parent.Order__r.AccountOrganization__c == 'North America' && c.RecordTypeId == prodImplementationTypeId &&
                            isMediaProduct(c.OrderLineItem__r.Product__r.Name)){
                    //system.debug('Prevent assignment for ADOPS queue.');
                }else{
                    c.OwnerId = ParentCaseIdToParentCaseMap.get(c.ParentId).OwnerId;
                }
                caseToUpdate.add(c);
            }
          }
          //Cloud Sherpas, commented out and moved to updateSimilarChildCaseOwner
          //CaseTriggerHandler.ExecuteTriggers = false;
          update caseToUpdate;
      } catch(DMLException dmlex){
            ExceptionLog.add(dmlex.getTypeName(), 'CaseTriggerHelper', 'caseOwnerUpdate', dmlex.getMessage());
            throw BaseApplicationException.NewException('CaseTriggerHelper.caseOwnerUpdate()', dmlex.getMessage());
      }
    }


    public void parentCaseGettingClosed(Case[] pUpdatedCases){
       Set<Id> parentIds = new Set<Id>();
       map<String, map<String, Id>> result = Utility.GetRecordTypeIdsBySObjectNameSet(new set<String>{'Case'});
       for(Case c : pUpdatedCases){
                if(c.status == 'Closed' && c.ParentId == null){
                    parentIds.add(c.Id);
                }
        }
       List<Case> childCases = [SELECT RecordTypeId  ,Status, ParentId FROM CASE WHERE ParentId in : parentIds ];
       if(!childCases.isempty()) {
            map<id , list<case>> mapParentToChildCases = new map<id , list<case>>();
           for(Case cc: childCases ){
             if(!mapParentToChildCases.containskey(cc.ParentId))
                mapParentToChildCases.put(cc.ParentId , new list<case>());

            mapParentToChildCases.get(cc.ParentId).add(cc);
           }

       for(Case c : pUpdatedCases){
            if(mapParentToChildCases.containskey(c.id)){
                for(Case cc:mapParentToChildCases.get(c.id)){
                    if(cc.RecordTypeId == result.get('Case').get('Product Implementation') && cc.status != 'Closed')
                        c.adderror('All child cases need to be closed before closing the parent case');
                }
            }
       }

       }
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 07/16/2014
** @Story : 0247
** @Element : E1811
** @description : Set the status to closed if all child case are closed.
** @param : list of case
** @returns : nothing
**
** TKOM updated for S-481830:
** The Parent case status and sub-status should behave as follows:
**
** 1. If all the child cases within one Parent case are closed as "Auto-Implemented" automatically due to the routing rules. The Parent case will automatically close as Auto-Implemented.
** 2. In any other scenario, the Parent case should remain Open and the agent should close it manually with Sub-Status "Resolved" when the child cases are completed.
*/
    public void closeParentCase(Case[] pCases){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','closeParentCase');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        for(Case c : pCases){
            system.debug('^^^ closeParentCase pCases: status=' + c.Status + ', ParentId=' + c.ParentId);
        }
       // try{
            Set<Id> parentIds = new Set<Id>();
            List<Case> parentCase = new List<Case>();
            List<Case> childCases = New List<Case>();
            List<Case> finalCaseToClose = new List<Case>();
            map<String, map<String, Id>> result = Utility.GetRecordTypeIdsBySObjectNameSet(new set<String>{'Case'});
            for(Case c : pCases){
                //if(c.status == 'Closed' && c.ParentId != null){
                if(c.status == 'Closed' && c.SubStatus__c == 'Auto-Implemented' && c.ParentId != null){ // TKOM updated for S-481830
                    parentIds.add(c.ParentId);
                }
            }
            if(parentIds.isEmpty()){
                return;
            }
            parentCase = [SELECT Id, Status, SubStatus__c, RecordTypeId FROM CASE WHERE Id in : parentIds];
            childCases = [SELECT Id, Status, SubStatus__c, RecordTypeId FROM CASE WHERE ParentId in : parentIds];
            system.debug('^^^ closeParentCase parentCase='+parentCase);
            system.debug('^^^ closeParentCase childCase='+childCases);

            for(Case pc : parentCase){
                if(pc.RecordTypeId == result.get('Case').get('Product Implementation')){
                    Boolean haveOpen = false;
                    //system.assert(false , childCases);
                    for(Case cc : pCases){
                        System.debug('----cc:pCases ' + cc);
                        //Sberron - 11/22/16 - S-445862
                        //Iterate through childCases list, determining if there are open child cases
                        //other than the case being processed.
                        for(Case child : childCases) {
                            System.debug('----child:childCases ' + child);
                            if(child.Id == cc.Id) {
                                System.debug('----childId: ' + child.Id + ' ccId: ' + cc.Id);
                                haveOpen = haveOpen;
                            }
                            // else if (child.Status != 'Closed'){
                            else if (child.Status != 'Closed' && child.SubStatus__c != 'Auto-Implemented'){ // TKOM updated for S-481830
                                System.debug('----childStatus ' + child.Status);
                                haveOpen = true;
                            }
                        }
                        if(pc.Id == cc.ParentId){
                            // if(cc.status != 'Closed'){
                            if(cc.status != 'Closed' && cc.SubStatus__c != 'Auto-Implemented'){ // TKOM updated for S-481830
                                haveOpen = true;
                                break;
                            }
                        }
                    }
                    System.debug('----Have open ' + haveOpen);
                    if(!haveOpen){
                        system.debug('^^^ Closing Parent Case '+ pc.id);
                        pc.Status = 'Closed';
                        pc.SubStatus__c = 'Auto-Implemented'; // TKOM Added for S-481830
                        finalCaseToClose.add(pc);
                    }
                }
            }

            if(finalCaseToClose.size() > 0){
                CaseTriggerHandler.ExecuteTriggers = false;
                update finalCaseToClose;
            }
       /* } catch(DMLException dmlex){
            ExceptionLog.add(dmlex.getTypeName(), 'CaseTriggerHelper', 'closeParentCase', dmlex.getMessage());
            throw BaseApplicationException.NewException('CaseTriggerHelper.closeParentCase()', dmlex.getMessage());
        }*/
    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 07/16/2014
** @Story : 0955
** @Element : E2073
** @description : Set the status to closed if all child case are closed.
** @param : list of case
** @returns : nothing
*/
// Not being used anywhere
   /* public void closeParentCase2(Case[] pUpdatedCases){
      final String CLASSNAME = '\n\n**** CaseTriggerHelper.METHODNAME()';
      final string METHODNAME = CLASSNAME.replace('METHODNAME','closeParentCase2');
      system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

      try{
            Set<Id> parentIds = new Set<Id>();
            Integer counter = 0;
            List<Case> caseToBeClose = new List<Case>();
            List<Case> finalCaseToClose = new List<Case>();
            map<String, map<String, Id>> result = Utility.GetRecordTypeIdsBySObjectNameSet(new set<String>{'Case'});
            map<Id, String> triggerCaseMap = new map<Id, String>();

            for(Case c : pUpdatedCases){
                if( c.ParentId != null){
                    parentIds.add(c.ParentId);
                }
                triggerCaseMap.put(c.Id, c.status);
            }

            //system.debug('\n\n\n\n\n *******parentIds: '+ parentIds +'\n\n\n\n\n');
            Map<Id,Integer> closedCaseMap= new map<Id,Integer>();
            Map<Id,Integer> cancelledCaseMap= new Map<Id,Integer>();
            Map<Id,Integer> newAndOpenCaseMap= new Map<Id,Integer>();
            if(!parentIds.isEmpty()){

              //Jeff L Appirio - updating these aggregate queries to reduce the total numbers of queries
              Id recordTypeId = result.get('Case').get('Product Implementation');

              // We created a query that will be used for two places rather than creating 2 queries
              // List<Case> lstcases = [SELECT Id,ParentId,Status FROM CASE WHERE Id IN : parentIds];


              for(Case c : [SELECT ParentId , status  FROM case
                WHERE (status = 'Open' OR status = 'New' OR status = 'Closed' OR status = 'Cancelled')
                AND parentid IN :parentIds]) {

                //for(Case c : lstcases){

                    Id parentId = c.ParentId;
                    Integer count;
                    if(triggerCaseMap.containsKey(c.Id)){
                        if(triggerCaseMap.get(c.Id) == 'Open' || triggerCaseMap.get(c.Id) == 'New'){
                            count = newAndOpenCaseMap.get(parentId) == null ? 0 : newAndOpenCaseMap.get(parentId);
                            newAndOpenCaseMap.put(parentId,++count);
                        }

                        if(triggerCaseMap.get(c.Id) == 'Closed'){
                            count = closedCaseMap.get(parentId) == null ? 0 : closedCaseMap.get(parentId);
                            closedCaseMap.put(parentId,++count);
                        }

                        if(triggerCaseMap.get(c.Id) == 'Cancelled'){
                            count = cancelledCaseMap.get(parentId) == null ? 0 : cancelledCaseMap.get(parentId);
                            cancelledCaseMap.put(parentId,++count);
                        }
                    }
                    else{
                        if(c.status == 'Open' || c.status == 'New'){
                            count = newAndOpenCaseMap.get(parentId) == null ? 0 : newAndOpenCaseMap.get(parentId);
                            newAndOpenCaseMap.put(parentId,++count);
                        }

                        if(c.status =='Closed'){
                            count = closedCaseMap.get(parentId) == null ? 0 : closedCaseMap.get(parentId);
                            closedCaseMap.put(parentId,++count);
                        }

                        if(c.status == 'Cancelled'){
                            count = cancelledCaseMap.get(parentId) == null ? 0 : cancelledCaseMap.get(parentId);
                            cancelledCaseMap.put(parentId,++count);
                        }
                   }
              }



                for (AggregateResult ar : [SELECT parentid, count(id)
                 FROM case
                 WHERE (status = 'Open' OR status = 'New') AND parentid IN: parentIds
                 AND RecordTypeId =: result.get('Case').get('Product Implementation')
                 GROUP BY ParentId]){
                    newAndOpenCaseMap.put(String.valueOf(ar.get('parentid')), Integer.valueOf(ar.get('expr0')));
                }

                for (AggregateResult ar : [SELECT parentid, count(id)
                 FROM case
                 WHERE status = 'Closed' AND parentid IN: parentIds
                 AND RecordTypeId =: result.get('Case').get('Product Implementation')
                 GROUP BY ParentId]){
                    closedCaseMap.put(String.valueOf(ar.get('parentid')), Integer.valueOf(ar.get('expr0')));
                }
                for (AggregateResult ar : [SELECT parentid, count(id)
             FROM case
             WHERE status = 'Cancelled' AND parentid IN: parentIds
             AND RecordTypeId =: result.get('Case').get('Product Implementation')
             GROUP BY ParentId]){
                cancelledCaseMap.put(String.valueOf(ar.get('parentid')), Integer.valueOf(ar.get('expr0')));
            }

            // To remove Extra query, we used above list
            for(Case cc : [SELECT Id, ParentId, Status FROM CASE WHERE Id IN : parentIds AND ParentId = NULL]){

            //for(Case cc : lstcases) {
                if(cc.ParentId == NULL) {
                    Integer n=0, cl = 0, ca = 0;
                    if(newAndOpenCaseMap.size() > 0){
                        if(newAndOpenCaseMap.containsKey(cc.Id)){
                            n = newAndOpenCaseMap.get(cc.Id);
                        }
                    }
                    if(closedCaseMap.size() > 0){
                        if(closedCaseMap.containsKey(cc.Id)){
                            cl = closedCaseMap.get(cc.Id);
                        }
                    }
                    if(cancelledCaseMap.size() > 0){
                        if(cancelledCaseMap.containsKey(cc.Id)){
                            ca = cancelledCaseMap.get(cc.Id);
                        }
                    }
                        system.debug('\n\n\n\n\n *******n: '+ n
                                       +'\n*******cl: '+cl
                                       +'\n*******ca:'+ca+'\n\n\n\n\n');
                        //final checking
                        if(n==0){
                            if(ca > 0 && cl == 0){
                                //system.debug('\n\n\n\n\n *******closed\n\n\n\n\n');
                                cc.Status ='Cancelled';
                                finalCaseToClose.add(cc);
                            }
                            else if(cl > 0){

                                //system.debug('\n\n\n\n\n *******cancelled\n\n\n\n\n');
                                cc.Status ='Closed';
                                finalCaseToClose.add(cc);
                            }
                        }
                    }
                  }


                  if(!finalCaseToClose.isEmpty()){
                    CaseTriggerHandler.ExecuteTriggers = false;
                    update finalCaseToClose;
                  }

            }

      } catch(Exception dmlex){
            ExceptionLog.add(dmlex.getTypeName(), 'CaseTriggerHelper', 'closeParentCase2', dmlex.getMessage());
            throw BaseApplicationException.NewException('CaseTriggerHelper.closeParentCase()', dmlex.getMessage());
      }
    } */

/*
   * @author Andre Calimlim
   * @date 1.14.2015
   * @param List of Cases
   * @description Method that will update the Organisation field of the Case

    public void updateOrganisation(Case[] pUpdatedCases){
      User u = [Select Organisation__c from User where id =:UserInfo.getUserId()];
       for(Case c: pUpdatedCases){

       }
    }
*/

/*
** @author : Cloud Sherpas, Inc.
** @date : 07/16/2014
** @story : 0920
** @element : E2329
** @description :
** @paramaters :
** @returns : nothing
*/
    public void CloseCase(Case[] pUpdatedCases){
      final string METHODNAME = CLASSNAME.replace('METHODNAME','CloseCase');
      system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

      //try{
        Set<Id> OrderIds = new set<Id>();
        for(Case c : pUpdatedCases){
            OrderIds.add(c.OrderLineItem__c);
            /*system.debug('\n\n\n\n\n c.OrderLineItem__r.Product__c: '+ c.OrderLineItem__r.Product__c +'\n\n\n\n\n');
            if(c.OrderLineItem__r.Product__r.Product_Line__c == 'Job Accessories--Inventory' || c.OrderLineItem__r.Product__r.Product_Line__c == 'JOB PACK' || c.OrderLineItem__r.Product__r.Product_Line__c == 'Banner-Button--Inventory'){
                c.Status = 'Closed';
            }*/
        }
        Map<Id,Boolean> OLIProductMap = new Map<Id,Boolean>();
        if(!OrderIds.isEmpty()){
            for(Order_Line_Item__c oli: [SELECT Id, Product__r.Messaging__c FROM  Order_Line_Item__c WHERE Id IN: OrderIds]){
                System.debug('oliID: ' + oli.Id + ' Messaging__c ' + oli.Product__r.Messaging__c);
                OLIProductMap.put(oli.Id,oli.Product__r.Messaging__c);
            }
        }
        if(!OLIProductMap.isEmpty()){
            for(Case c : pUpdatedCases){
                if(OLIProductMap.get(c.OrderLineItem__c) == TRUE){
                    system.debug('^^^ Closing Case Subject: '+c.Subject + ', OrderLineItem__r.Product__r.Messaging__c='+OLIProductMap.get(c.OrderLineItem__c));
                    c.Status = 'Closed';
                }
            }
        }

      /*}catch(Exception dmlex){
            ExceptionLog.add(dmlex.getTypeName(), 'CaseTriggerHelper', 'CloseCase', dmlex.getMessage());
            throw BaseApplicationException.NewException('CaseTriggerHelper.CloseCase()', dmlex.getMessage());
      }*/

    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 05/27/2014
** @Story : 0899
** @Element : E1690
** @description : Check that the Case Owner of the Parent Case is ALSO the Owner of the children cases when created
** @returns : nothing
*/
 /*   public void setOwnerForChildCases(Case[] pNewCases){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','setOwnerForChildCases');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        Set<Id> ParentCaseIds = new Set<Id>();
        for(Case c : pNewCases ){
            if( c.ParentId != null ){
                ParentCaseIds.add(c.ParentId);
            }
        }
        Map<Id,Id> caseOwnerMap = new Map<Id,Id>();
        if(!ParentCaseIds.isEmpty()){
            for(Case c : [SELECT Id, OwnerId FROM Case WHERE Id IN: ParentCaseIds]){
                caseOwnerMap.put(c.Id, c.OwnerId);
            }
        }
        system.debug('\n\n\n\nParentCaseIds: '+ParentCaseIds);
        List<Case> CasesToUpdate = new List<Case>();
        if(caseOwnerMap.isEmpty()){
            for(Case c : pNewCases ){
                if( c.ParentId != null && caseOwnerMap.containsKey(c.ParentId)){
                    c.OwnerId = caseOwnerMap.get(c.ParentId);
                    CasesToUpdate.add(c);
                }
            }
        }
        if(!CasesToUpdate.isEmpty()){
            CaseTriggerHandler.ExecuteTriggers = false;
            update CasesToUpdate;
            CaseTriggerHandler.ExecuteTriggers = true;
        }
    }*/

    /*
    ** @author : Cloud Sherpas, Inc.
    ** @date : 12/4/2014
    ** @Story : 1669
    ** @Element : E2081, E2439
    ** @description : Updates the child cases with owner similar to the previous owner of the parent case, setting the value to the new owner of the parent case
    ** @returns : nothing
    */
    public void updateSimilarChildCaseOwner(List<Case> pNewCases, Map<ID, Case> pOldCaseMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateSimilarChildCaseOwner');
        //system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside ')); //old logging
        Logger.push(METHODNAME, Schema.Contact.getSObjectType().getDescribe().getName());
       // try{
            map<String, map<String, Id>> CaseRecordTypes = Utility.GetRecordTypeIdsBySObjectNameSet(new set<string>{'Case'});
            Id caseProductImplementationRecordTypeId = CaseRecordTypes.get('Case').get('Product Implementation');

            //method variables
            List<Case> childCasesToUpdate = new List<Case>();
            Set<Id> parentCaseIds = new Set<Id>();
            //Case trigger custom setting retrieval
            CaseTriggerSettings__c triggerSetting = CaseTriggerSettings__c.getInstance(UserInfo.getProfileId());
            if(triggerSetting == null){
                triggerSetting = CaseTriggerSettings__c.getOrgDefaults();
            }
            System.debug('\n\n#*#*#* [updateSimilarChildCaseOwner]triggerSetting='+triggerSetting+'\n\n');
            //list iteration retrieving parent case ids of all records that have the OwnerId field changed
            for(Case newCase: pNewCases){
                if(pOldCaseMap.get(newCase.Id).OwnerId != newCase.OwnerId ){//
                    parentCaseIds.add(newCase.Id);
                }
            }
            //retrieve ADOPS Queue
            List<Group> listADOPSQueue = [SELECT Id FROM Group WHERE Name =:triggerSetting.CaseOwnerQueueName__c AND Type = 'Queue' LIMIT 1];
            Group ADOPSQueue = new Group();//'ADOPS'
            if(listADOPSQueue.size()>0){
                ADOPSQueue = listADOPSQueue[0];
            }
            //retrieve all children cases of the parent
            List<Case> childCases = new List<Case>();
            if(listADOPSQueue.size()>0){
               childCases = [SELECT Id, OwnerId, ParentId FROM Case WHERE ParentId IN: parentCaseIds AND OwnerId!=:ADOPSQueue.Id AND RecordTypeId =:caseProductImplementationRecordTypeId ORDER BY ParentId];
            }
            else{
                childCases = [SELECT Id, OwnerId, ParentId FROM Case WHERE ParentId IN: parentCaseIds AND RecordTypeId =:caseProductImplementationRecordTypeId ORDER BY ParentId];
            }
            //iterate thru all updated cases and its child cases and match those children that
            //have similar values to the parent's previous ownerid value
            for(Case parentCase: pNewCases){
                for(Case childCase:childCases){
                    if(childCase.ParentId == parentCase.Id ){//updated 20141209 As per Jaime D. should only exclude Case owned by AdOPS
                        //&& childCase.OwnerId == pOldCaseMap.get(parentCase.Id).OwnerId
                        Case tempCase = childCase.clone(true, true, true, true);
                        tempCase.OwnerId = parentCase.OwnerId;
                        childCasesToUpdate.add(tempCase);
                    }
                }
            }
            //DML call
            if(childCasesToUpdate != null && !childCasesToUpdate.isEmpty()){
                CaseTriggerHandler.ExecuteTriggers = false;
                update childCasesToUpdate;
            }
       /* }
        catch(Exception e){
            Logger.debugException(Label.CaseUpdateSimilarChildCaseOwner+' \n'+ e.getMessage());//Failed to update child cases owner.
            Logger.pop();
            //ExceptionLog.add('Exception', 'ContactTriggerHelper', 'UncheckOtherPrimaryBillingContacts', e.getMessage());//old logging
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,Label.CaseUpdateSimilarChildCaseOwner+' \n'+ e.getMessage() ,e);
        }*/
    }


    // Added by George Huene 2015-03-02 for Story 3082
    @future
        public static void fillGroupFieldOnInsert(Set<Id> newCaseIds, Boolean CreateOrdersAutomaticallyInFuture)
    {
        final string METHODNAME = CLASSNAME.replace('METHODNAME','fillGroupFieldOnInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        list<case> lstCasesToUpdate = [SELECT Id , Status FROM Case WHERE Id IN:newCaseIds] ;
        if(lstCasesToUpdate.size() > 0) {
            //JFreese Appirio 01/26/17 S-452628  Bypass designated validation rules if we are in CR/Rebill Automated handling
            if(CreateOrdersAutomaticallyInFuture){
                CreditRequestTriggerHandler.CreateOrdersAutomatically = true;
            }
            
             // Shyam 5/10 : S-475566 - Start
            try{
                update lstCasesToUpdate;
            }
            catch (DMLException e){
                for(Case cs : lstCasesToUpdate){
                    cs.addError(e.getMessage());
                }
            }
            // Shyam 5/10 : S-475566 - End
        }
    }


    // Added by George Huene 2015-03-02 for Story 3082
    public void copyQueueNameToGroupField(List<Case> newCases)
    {
        Set<Id> groupIds = new Set<Id>();
        // grab all group ids
        for(Case newCase:newCases){
            if(newCase.ownerId != null && String.valueOf(newCase.OwnerId) != null){
                if(String.valueOf(newCase.OwnerId).startsWith('00G')){
                    groupIds.add(newCase.OwnerId);
                }
            }
        }


        if(groupIds != null && !groupIds.isEmpty())
        {
            // put them in a map
            Map<Id,Group> groupsMap = new Map<Id,Group>([
                SELECT Id, Name
                FROM   Group
                WHERE  Id IN:groupIds
                AND    Type = 'Queue'
                AND    (Name != 'Product HelpDesk' OR DeveloperName != 'Product_HelpDesk')
            ]);


            // copy group name to the Group__c field for reporting
            if(groupsMap != null && !groupsMap.isEmpty()){
                for(Case newCase:newCases){
                    //Jeff L 09/28/15 - added check to see if the case was system generated, only want
                    //to populate if the record was NOT created manually
                    //TKOM 1/12/17 S-452809: removed JeffL's check on system-generated cases.  Group should update for any case, regardless of system-generated flag
                    //if(groupsMap.containsKey(newCase.OwnerId) && newCase.SystemGenerated__c){
                    if(groupsMap.containsKey(newCase.OwnerId)){
                        newCase.Group__c = groupsMap.get(newCase.OwnerId).Name;
                    }
                }
            }
        }
    }


    // Added by Sunny Gill Story S-320213
    //Update by JFreese Appirio 4/26/17 for S-481980
    public void copyQuoteInfoToCase(List<Case> newCases){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','copyQuoteInfoToCase');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        map<String, map<String, Id>> CaseRecordTypes = Utility.GetRecordTypeIdsBySObjectNameSet(new set<string>{'Case'});
        Id OMProcessingReqRT = CaseRecordTypes.get('Case').get('OM Processing Request');
        List<ID> newCasesWithQuoteID = new List<ID>();
        Map<ID,ID> newCasesWithOpportunityID = new Map<ID,ID>();
        Map<Id,Case> newCasesWithQuote = new Map<Id,Case>();
        Set<Id> accIdSet = new Set<Id>();
        for(Case cse : newCases){
            if(cse.recordTypeId == OMProcessingReqRT ){
                if( cse.Proposal_ID__c != null){
                    newCasesWithQuoteID.add(cse.Id);
                    accIdSet.add(cse.AccountId);
                    system.debug('Case Proposal_ID__c='+cse.Proposal_ID__c);
                } else if( cse.Opportunity__c != null){
                    newCasesWithOpportunityID.put(cse.Id,cse.Opportunity__c );
                }
            }
        }

        if(!newCasesWithQuoteID.isEmpty()){
            for(Case c : [SELECT Proposal_ID__r.PostingContact__c,Proposal_ID__r.PostingContact__r.AccountId,
                                Proposal_ID__r.Selling_Country__c,
                                Proposal_ID__r.Language__c,Proposal_ID__r.ParentOrder__c,
                                Proposal_ID__r.Xcode_Name__c,
                                Proposal_ID__r.Quote_Total_Decimal__c,
                                Proposal_ID__r.Apttus_Proposal__Account__r.ownerId,
                                Proposal_ID__r.Apttus_Proposal__Account__r.Primary_Sales_Rep_ID__c,
                                Proposal_ID__r.OwnerId,Quote_Sales_Rep__r.Country From Case WHERE ID IN :newCasesWithQuoteID ]){
                newCasesWithQuote.put(c.Id,c);
            }
        }

        system.debug('newCasesWithQuote: '+newCasesWithQuote);

        set<Id> userIds = new set<Id>();
        for(Id key : newCasesWithQuote.keySet()) {
            Case cs = newCasesWithQuote.get(key);
            if(cs != null && cs.Proposal_ID__c != null){
              userIds.add(cs.Proposal_ID__r.OwnerId);
            }

        }

        map<Id, User> userMap = new map<Id, User>();
        if(!userIds.isEmpty()) {
            userMap = new map<Id,User>([Select Id, Country from User Where Id IN :userIds]);
        }
        system.debug('userMap: '+userMap);



        map<Id, Apttus_Proposal__Proposal__c> newquotesWithOpportunity = new Map<Id, Apttus_Proposal__Proposal__c>();
        Set<Id> casesWithOppUserIdSet = new Set<Id>();
        if(!newCasesWithOpportunityID.keySet().isEmpty()){
            for(Apttus_Proposal__Proposal__c proposal : [SELECT PostingContact__c,Apttus_Proposal__Opportunity__c,
                                                     Selling_Country__c,Language__c,Xcode_Name__c,Quote_Total_Decimal__c,
                                                     Apttus_Proposal__Account__r.ownerId,
                                                     Apttus_Proposal__Account__r.Primary_Sales_Rep_ID__c,
                                                     OwnerId From Apttus_Proposal__Proposal__c WHERE
                                                     Apttus_Proposal__Opportunity__c IN :newCasesWithOpportunityID.Values() AND
                                                     Apttus_Proposal__Primary__c = true])  {
            newquotesWithOpportunity.put(proposal.Apttus_Proposal__Opportunity__c,proposal );
            casesWithOppUserIdSet.add(proposal.OwnerId);

            }
        }

        map<Id, User> userMap1 = new map<Id, User>();
        if(!casesWithOppUserIdSet.isEmpty()) {
            userMap1 = new map<Id,User>([Select Id, Country from User Where Id IN :casesWithOppUserIdSet]);
        }
        system.debug('userMap1: '+userMap1);


        List<Case> updatedCse = new List<Case>();
        for(Case cse : newCases){
            //Update by JFreese Appirio 4/26/17 for S-481980 - this was outside the for loop, busted for multiple cases
            Case updateCase = new Case();
            if(cse.recordTypeId == OMProcessingReqRT ){
                if(cse.Proposal_ID__c != null ){
                    system.debug('Case with proposal to update: '+newCasesWithQuote.get(cse.Id));
                    updateCase.Id = cse.Id;
                    if(cse.AccountId == newCasesWithQuote.get(cse.Id).Proposal_ID__r.PostingContact__r.AccountId){
                        updateCase.ContactId = newCasesWithQuote.get(cse.Id).Proposal_ID__r.PostingContact__c;
                    }
                    updateCase.Primary_Sales_Rep_Lookup__c = newCasesWithQuote.get(cse.Id).Proposal_ID__r.Apttus_Proposal__Account__r.Primary_Sales_Rep_ID__c;
                    updateCase.Order__c = newCasesWithQuote.get(cse.Id).Proposal_ID__r.ParentOrder__c;
                    updateCase.Quote_Sales_Rep__c = newCasesWithQuote.get(cse.Id).Proposal_ID__r.OwnerId ;

                    if(newCasesWithQuote.get(cse.Id).Proposal_ID__c != null && userMap.containsKey(newCasesWithQuote.get(cse.Id).Proposal_ID__r.OwnerId) && (updateCase.Quote_SellingCountry__c == null|| updateCase.Quote_SellingCountry__c == '') ){
                        updateCase.Quote_SellingCountry__c = userMap.get(newCasesWithQuote.get(cse.Id).Proposal_ID__r.OwnerId).Country;
                    }

                    updateCase.Quote_Language__c = newCasesWithQuote.get(cse.Id).Proposal_ID__r.Language__c ;
                    updateCase.Quote_Account_Xcode__c = newCasesWithQuote.get(cse.Id).Proposal_ID__r.Xcode_Name__c ;
                    updateCase.Quote_Total__c = newCasesWithQuote.get(cse.Id).Proposal_ID__r.Quote_Total_Decimal__c ;
                    //updateCase.AccountId = newCasesWithQuote.get(cse.Id).Proposal_ID__r.PostingContact__r.AccountId;
                    updatedCse.add(updateCase);
                } else if(cse.Opportunity__c != null){
                    updateCase.Id = cse.Id;
                    system.debug('Case with opportunity to update: '+newCasesWithOpportunityID.get(cse.Id));
                    if (newCasesWithOpportunityID.get(cse.Id) != null) {
                        Apttus_Proposal__Proposal__c ap = newquotesWithOpportunity.get(newCasesWithOpportunityID.get(cse.Id));
                        if (ap != null) {
                            updateCase.ContactId = ap.PostingContact__c;

                            updateCase.Primary_Sales_Rep_Lookup__c = ap.Apttus_Proposal__Account__r.Primary_Sales_Rep_ID__c;
                            updateCase.Quote_Sales_Rep__c = ap.OwnerId ;
                            if(newCasesWithOpportunityID.get(cse.Id)!= null && userMap1.containsKey(newquotesWithOpportunity.get(newCasesWithOpportunityID.get(cse.Id)).OwnerId)){
                                updateCase.Quote_SellingCountry__c = userMap1.get(newquotesWithOpportunity.get(newCasesWithOpportunityID.get(cse.Id)).OwnerId).Country;
                            }
                            updateCase.Quote_Language__c = ap.Language__c ;
                            updateCase.Quote_Account_Xcode__c = ap.Xcode_Name__c ;
                            //updateCase.AccountId = newquotesWithOpportunity.(newCasesWithOpportunityID.get(cse.Id)).PostingContact__r.AccountId;
                            updateCase.Quote_Total__c = ap.Quote_Total_Decimal__c ;
                        }
                    }
                    updatedCse.add(updateCase);
               }
            }
        }

        if(updatedCse.size() > 0 && !isExecuted){
            isExecuted = true;
            update updatedcse;
        }
    }
    //T-430361 changes
    public void updateFirstContactActual(Case[] pNewCases)
    {
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateFirstContactActual');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        BusinessHours defaultHours = [select Id from BusinessHours where IsDefault=true];
        for(Case updatedCase : pNewCases) {
            Id hoursToUse = updatedCase.BusinessHoursId!=null?updatedCase.BusinessHoursId:defaultHours.Id;
            if(updatedCase.First_Contact_Actual_Date_Time__c!=NULL) {
                updatedCase.First_Contact_Actual__c = BusinessHours.diff(hoursToUse, updatedCase.CreatedDate, updatedCase.First_Contact_Actual_Date_Time__c)/(3600000.0);
            }
        }
    }

    /*
    * UpdateCaseOwnerManagerField: the goal of this function is to populate manager of the Case owner.
    * Appirio Created as part of S-351079 - needed for approval process
    *
    */
    public void updateCaseOwnerManagerField(List<Case> pNewCases, Map<Id,Case> pOldCaseMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateCaseOwnerManagerField');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Set<Id> userIds = new Set<Id>();
        Boolean isUpdate = false;
        Map<Id,Id> userToManager = new Map<Id,Id>();
        List<Case> casesToUpdate = new List<Case>();
        List<Case> casesToCheck = new List <Case>();
        //gather up all the users we need to query for their managers
        for(Case c : pNewCases){
            if(pOldCaseMap != null){
                isUpdate = true;
                if(c.ownerId != pOldCaseMap.get(c.Id).OwnerId){
                    userIds.add(c.ownerId);
                    casesToCheck.add(c);
                }
            } else {
                userIds.add(c.ownerId);
                casesToCheck.add(c);
            }

        }
        //get the Manger Ids
        if(userIds.size() > 0){
            For(user u : [Select Id, ManagerId from User where Id in :userIds]){
                userToManager.put(u.Id, u.ManagerId);
            }
        }

        //finally populate the manager Id's on the cases
        if(casesToCheck.size() > 0){
            for(Case c : casesToCheck){
                Case newC;
                if(isUpdate){
                    newC = new Case();
                    newC.Id = c.Id;
                } else {
                    newC = c;
                }
                if(newC.Owner_Manager__c != userToManager.get(c.OwnerId)){
                    newC.Owner_Manager__c = userToManager.get(c.OwnerId);
                    casesToUpdate.add(newC);
                }

            }
            if(isUpdate){
                update casesToUpdate;
            }
        }
    }

    /* calculateCaseBusinessHours.  This used to be an extra trigger on Case object, Jeff L moved it from
    * the trigger into the case handler instead (was causing extra triggers to fire)  Not 100% sure what all
    * of the code is accomplishing
    *
    */
    public void calculateCaseBusinessHours(List<Case> pNewCases, Map<Id, Case> pOldCaseMap){
        //In the old code there was a before trigger that just set some values and an after that
        //did a lot more logic, we will just assume if the map is null, then we are in the before trigger
        //the after trigger will be handled when the map is populated
      final string METHODNAME = CLASSNAME.replace('METHODNAME','calculateCaseBusinessHours');
      system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        if(pOldCaseMap == null){
            for(Case c : pNewCases){
                c.Last_Status_Change__c = System.now();
                c.Time_With_Customer__c = 0;
                c.Time_With_Support__c = 0;
            }
        } else { //this is the logic for the After trigger
            //Get the stop statuses
            Set<String> stopStatusSet = new Set<String>();
            for (Stop_Status__c stopStatus:[Select Name From Stop_Status__c]) {
                 stopStatusSet.add(stopStatus.Name);
            }
            //Get the default business hours (we might need it)
            BusinessHours defaultHours = [select Id from BusinessHours where IsDefault=true];

            //Get the closed statuses (because at the point of this trigger Case.IsClosed won't be set yet)
            Set<String> closedStatusSet = new Set<String>();
            for (CaseStatus status:[Select MasterLabel From CaseStatus where IsClosed=true]) {
                closedStatusSet.add(status.MasterLabel);
            }
            //For any case where the status is changed, recalc the business hours in the buckets
            for (Case updatedCase:pNewCases) {
                Case oldCase = pOldCaseMap.get(updatedCase.Id);

                if (oldCase.Status!=updatedCase.Status && updatedCase.Last_Status_Change__c!=null) {
                    //OK, the status has changed
                    if (!oldCase.IsClosed) {
                        //We only update the buckets for open cases

                        //On the off-chance that the business hours on the case are null, use the default ones instead
                        Id hoursToUse = updatedCase.BusinessHoursId!=null?updatedCase.BusinessHoursId:defaultHours.Id;

                        //The diff method comes back in milliseconds, so we divide by 3600000 to get hours.
                        Double timeSinceLastStatus = BusinessHours.diff(hoursToUse, updatedCase.Last_Status_Change__c, System.now())/3600000.0;

                        //We decide which bucket to add it to based on whether it was in a stop status before
                        if (stopStatusSet.contains(oldCase.Status)) {
                            updatedCase.Time_With_Customer__c += timeSinceLastStatus;
                        } else {
                            updatedCase.Time_With_Support__c += timeSinceLastStatus;
                        }

                        if (closedStatusSet.contains(updatedCase.Status)) {
                            updatedCase.Case_Age_In_Business_Hours__c = updatedCase.Time_With_Customer__c + updatedCase.Time_With_Support__c;
                        }
                    }

                    updatedCase.Last_Status_Change__c = System.now();
                }
            }
        }
    }

    // Used as mapping for populating Case from Case Routing Rule as was being used in multiple place
    public static Case populateCaseRoutingRuleInfo(Case c, CaseRoutingRule__c cRR){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populateCaseRoutingRuleInfo');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        //Jeff L moved this into the method so it only gets populated as neeeded
        if(mySelectedProfileMap.keySet().size() == 0){
            for(Profile prof : [SELECT Id from Profile where Name IN ('Service Rep (NA)','Sales Rep (NA)')]) {
               mySelectedProfileMap.put(prof.Id, prof);
            }
        }

            Map<Id,String> rtMap = Utility.GetRecordTypeNamesbyIds('Case');
            Map<String,Id> rtMap2 = Utility.GetRecordTypeIdsbyName('Case');

            if(rtMap.get(c.RecordTypeId)!=cRR.CaseRecordType__c && cRR.CaseRecordType__c != null) c.RecordTypeId = rtMap2.get(cRR.CaseRecordType__c);
            c.OwnerId = cRR.OwnerID;
            if(cRR.CaseStatus__c != null) c.status = cRR.CaseStatus__c;
            if(cRR.CaseSubStatus__c != null) c.SubStatus__c = cRR.CaseSubStatus__c;
            if(cRR.CaseIssue__c != null) c.Issue__c = cRR.CaseIssue__c;
            if(cRR.CaseSubIssue__c != null) c.SubIssue__c = cRR.CaseSubIssue__c;
            if(cRR.CaseBusinessHours__c != null) c.BusinessHoursId = cRR.CaseBusinessHours__c;
            if(cRR.FirstContactCommitmentHours__c != null) c.FirstContactCommitment__c = cRR.FirstContactCommitmentHours__c ;
            if(cRR.ResolutionCommitmentHours__c != null) c.ResolutionCommitment__c = cRR.ResolutionCommitmentHours__c;
            if(cRR.CaseLanguage__c != null) c.Language__c = cRR.CaseLanguage__c;
            if(cRR.CaseOrigin__c != null) c.Origin = cRR.CaseOrigin__c;
            c.SystemGenerated__c = cRR.SystemGenerated__c;
            c.Case_Routing_Rule__c = cRR.Id;
            if(cRR.BusinessProcess__c != null)c.BusinessProcess__c = cRR.BusinessProcess__c;
            if(cRR.Group__c != null) c.Group__c = cRR.Group__c; // TKOM added for S-473311
            if(cRR.Organization__c != null && c.Organization__c == null && cRR.CaseRecordType__c == 'EU Sales Support Request') c.Organization__c = cRR.Organization__c; // TKOM Added for S-460088

            //addede by Deepanshu for setting up priority for Sales Rep (NA) and Service Rep (NA) for I-220907

            //Sberron - 1/12-17 - S-445804
            //Flags the case for deletion if the matched routing rule is set to delete case based on attachment types
            //TKOM 1/16/17 - Hi Sam, I had to comment these couple of debug lines out due to Dev -> QA Deployment errors for story S-452809
            //System.debug('----Delete_Case__c BEFORE ' + c.Delete_Case__c);
            //c.Delete_Case__c = cRR.Skip_Case_Creation__c;
            //System.debug('----Delete_Case__c AFTER ' + c.Delete_Case__c);

            if(mySelectedProfileMap.containskey(UserInfo.getProfileId()))
            {
                if(cRR.Case_Priority__c == null)c.Priority = cRR.Case_Priority__c;
            }
            else
            {
                if(cRR.Case_Priority__c != null)c.Priority = cRR.Case_Priority__c;
            }
            if(cRR.Fraud_Monitor_Type__c != null)c.Monitortype__c = cRR.Fraud_Monitor_Type__c;
            if(cRR.Order_Type__c != null)c.Order_Type__c = cRR.Order_Type__c;
            if(cRR.CaseContactSource__c != null)c.ContactSource__c = cRR.CaseContactSource__c;
            if(cRR.Category__c != null)c.Category__c = cRR.Category__c;
            system.debug('<*cRR*>'+cRR);
            if(cRR.Account__c != null && c.AccountId != cRR.Account__c){

                c.AccountId = cRR.Account__c;
                //Commenting due to issue I-191177 - Duplicate Error

                list<Contact> conList = [Select id, AccountId, CreatedDate, Email, FirstName, LastName, RecordType.Name From Contact Where id = :c.ContactId];

                if(!conList.isEmpty()) {

                    Contact con = conList[0];
                    Contact con2 = con.clone(false,true);
                    Id ConRecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Contact', 'Contact');
                    con2.RecordTypeId = ConRecordTypeId;
                    con2.AccountId = cRR.Account__c;
                    con2.MatchingRuleEnabled__c = false;
                    insert con2;
                    System.debug('----con2 ' + con2);
                    c.ContactId = con2.Id;
                    if(ContactsCreated.contains(con.Id)){
                        PersonAccountsRemove.add(con.Accountid);
                    }

                }


            }

            system.debug('new ownerId? ' + c.OwnerId + ' routing rule owner ' + cRR.OwnerId);
        return c;
    }

    //For the product implementation credit requests we need details from the order to populate the owner in certain cases
    public static Case populateCaseRoutingRuleProduct(Case c, CaseRoutingRule__c cRR, Order__c order){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populateCaseRoutingRuleProduct');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Case returnCase = populateCaseRoutingRuleInfo(c, cRR);
        //this is our extra bit of logic and the reason why we need a new method
        if(cRR.Assign_to_Verified_By__c == true){
            //we need to query to get the Verified by user Id (it's just a name)
            if(getOwnerForAssignTo(order) != null){
                returnCase.ownerId = getOwnerForAssignTo(order);
                system.debug('^^^ Setting Case owner to ' + returnCase.ownerId);
            } else {
                //if that value is null we need to default to the user who is calling the method
                returnCase.ownerId = UserInfo.getUserId();
                system.debug('^^^ Setting Case owner to ' + returnCase.ownerId);
            }
        }

        return returnCase;

    }

    public static ID getOwnerForAssignTo(Order__c order){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','getOwnerForAssignTo');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        system.debug('Name query!!' + order.VerifiedBy__c);
         for(User u : [Select Id from User where Name = :order.VerifiedBy__c Limit 1]){
           return u.Id;
        }
        return null;
    }

    public static List<Messaging.SingleEmailMessage> sendAutoReponseEmail(Case c, CaseRoutingRule__c cRR, EmailMessage emsg){
        //Send email to debug list
        Map<String, Id> mapTemplates = Utility.getEmailTemplates();
        String SendToEmail;
        Contact con = new Contact();
        List<String> ccAddresses = new List<String>();

        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();

        if(cRR.Routing_Status__c == 'Debug'){
            String DebugEmails = Label.Email2CaseDebugEmails;
            List<String> lstDebugEmails = DebugEmails.split(';');

            for(String s:lstDebugEmails){
                if(s == lstDebugEmails[0]){
                    con.FirstName = 'Email2Case' + (Math.random()*10000);
                    con.LastName = 'Debug' + DateTime.now();
                    con.Email = s;
                    con.MatchingRuleEnabled__c = false;
                    insert con;
                    AutoResponseContactsDelete.add(con.id);
                    SendToEmail = con.Id;
                }
                else{
                    ccAddresses.add(s);
                }
            }

            /* TKOM - replaced this block with code below
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.WhatId = c.Id;
            message.saveasActivity = true;
            if(cRR.FromAddressforAutoResponse__c != null){
                List<OrgWideEmailAddress> orgadd = [Select id, DisplayName, Address From OrgWideEmailAddress Where Address = :cRR.FromAddressforAutoResponse__c];
                if(orgadd.size()> 0)message.OrgWideEmailAddressId = orgadd[0].id;
            }
            message.targetObjectId = SendToEmail;
            if(ccaddresses.size()>0)message.ccAddresses = ccAddresses;
            message.TemplateId = mapTemplates.get(cRR.AutoResponseTemplate__c);
            messages.add(message);
            */
            // TKOM - S-440395: Adding IF stmt to check for autoresponse template OR from addr being null.  If either one IS null, don't send the message because there is not enough detail to send the email.
            if(cRR.FromAddressforAutoResponse__c != null || cRR.AutoResponseTemplate__c != null){

                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.WhatId = c.Id;
                message.saveasActivity = true;

                List<OrgWideEmailAddress> orgadd = [Select id, DisplayName, Address From OrgWideEmailAddress Where Address = :cRR.FromAddressforAutoResponse__c];
                if(orgadd.size()> 0)message.OrgWideEmailAddressId = orgadd[0].id;

                message.targetObjectId = SendToEmail;
                if(ccaddresses.size()>0)message.ccAddresses = ccAddresses;

                message.TemplateId = mapTemplates.get(cRR.AutoResponseTemplate__c);
                messages.add(message);
             }


        }
        else if(cRR.ForwardIncomingEmailTo__c != null && emsg != null){
            //Send email to forwarding address
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.WhatId = c.Id;
            message.saveasActivity = true;
            if(cRR.FromAddressforAutoResponse__c != null){
                List<OrgWideEmailAddress> orgadd = [Select id, DisplayName, Address From OrgWideEmailAddress Where Address = :cRR.FromAddressforAutoResponse__c];
                if(orgadd.size()> 0)message.OrgWideEmailAddressId = orgadd[0].id;
            }
            message.toaddresses = new List<String>{cRR.ForwardIncomingEmailTo__c};
            message.subject= emsg.subject;
            message.HtmlBody = emsg.htmlbody;
            message.plaintextbody = emsg.textbody;
            messages.add(message);
        }
        if(c.ContactId != null && cRR.Routing_Status__c != 'Debug'){
            SendToEmail = c.ContactId;

            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.WhatId = c.Id;
            message.saveasActivity = true;
            if(cRR.FromAddressforAutoResponse__c != null){
                List<OrgWideEmailAddress> orgadd = [Select id, DisplayName, Address From OrgWideEmailAddress Where Address = :cRR.FromAddressforAutoResponse__c];
                if(orgadd.size()> 0)message.OrgWideEmailAddressId = orgadd[0].id;
            }
            message.targetObjectId = SendToEmail;
            message.TemplateId = mapTemplates.get(cRR.AutoResponseTemplate__c);
            messages.add(message);
        }
        else if(c.suppliedemail != null && cRR.Routing_Status__c != 'Debug'){

            con.LastName = c.SuppliedName;
            con.Email = c.suppliedemail;
            con.MatchingRuleEnabled__c = false;
            insert con;
            AutoResponseContactsDelete.add(con.id);
            SendToEmail = con.Id;

            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.WhatId = c.Id;
            message.saveasActivity = true;
            if(cRR.FromAddressforAutoResponse__c != null){
                List<OrgWideEmailAddress> orgadd = [Select id, DisplayName, Address From OrgWideEmailAddress Where Address = :cRR.FromAddressforAutoResponse__c];
                if(orgadd.size()> 0)message.OrgWideEmailAddressId = orgadd[0].id;
            }
            message.targetObjectId = SendToEmail;
            message.TemplateId = mapTemplates.get(cRR.AutoResponseTemplate__c);
            messages.add(message);
        }

        return messages;
    }

    //Find Winning Contact when duplicates are found on Email2Case
    //updated per I-211754
    public static Id findWinningContact(List<contact> lstContacts){
        Contact winningContact = new Contact();

        for(Contact con:lstContacts){
            if(winningContact.Id == null){
                winningContact = con;
            } else if (winningContact.LastActivityDate == null && con.LastActivityDate != null){
                winningContact = con;
            } else if(winningContact.LastActivityDate == null && con.LastActivityDate == null){
                if(con.LastModifiedDate > winningContact.LastModifiedDate){
                winningContact = con;
                }
            } else if(con.LastActivityDate > winningContact.LastActivityDate){
                    winningContact = con;
            }
        }
        return winningContact.Id;
    }

    @future
    public static void deleteCreatedcontacts(Set<id> setContacts){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','deleteCreatedcontacts');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        List<Contact> lstContacts = new List<Contact>();

        for(Id setId:setContacts){
            Contact c = new Contact (id= setId);
            lstContacts.add(c);
        }

        if(lstContacts.size() > 0){
            try{
                delete lstContacts;
            }
            catch (exception e){
                //do nothing contacts have been deleted in other future method
            }
        }
    }
     public void SetOMRecordType(list<Case> pCaseList){
                map<String, map<String, Id>> CaseRecordTypes = Utility.GetRecordTypeIdsBySObjectNameSet(new set<string>{'Case'});
                Id caseOMRecordTypeId = CaseRecordTypes.get('Case').get('OM Processing Request');
                for(Case oCase : pCaseList){
                    oCase.RecordTypeId = caseOMRecordTypeId;
                }
    }

    /*
    ** @author : Appirio Inc.
    ** @param : list of case
    ** @returns : nothing
    */
    public void shareCasesWithCreator(list<Case> pCaseList){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','shareCasesWithCreator');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        list<CaseShare> lstCaseShare = new list<CaseShare>();
        for(Case oCase : pCaseList){
            CaseShare cs = new CaseShare();
            cs.UserOrGroupId = oCase.CreatedbyId;
            cs.CaseId = oCase.Id;
            cs.CaseAccessLevel = 'Read';
            lstCaseShare.add(cs);
        }

        try{
            insert lstCaseShare;
        }
        catch (exception e){
            system.debug('Error: ' + e.getMessage());
        }

    }

     public void PopulateAttributeDisplayFromPLIOnCase(list<Case> pCaseList){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','PopulateAttributeDisplayFromPLIOnCase');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        Set<Id> lineIDs = new Set<Id>();
        list<Order_Line_Item__c> lstPLI = new list<Order_Line_Item__c>();

        for(Case cs: pCaseList){
            if(cs.OrderLineItem__c!= null) {
                lineIDs.add(cs.OrderLineItem__c);
            }
        }

        if(lineIDs.isEmpty()) return;
        map<Id, Order_Line_Item__c> lineMap = new map<Id, Order_Line_Item__c>(
                                                                  [Select Id,APTS_Attribute_Display__c from Order_Line_Item__c
                                                                   Where Id IN :lineIDs]);
        for(Case cs: pCaseList){
            if(lineMap.containsKey(cs.OrderLineItem__c)){
               cs.Attribute_Display__c = lineMap.get(cs.OrderLineItem__c).APTS_Attribute_Display__c ;
            }
        }
    }


}