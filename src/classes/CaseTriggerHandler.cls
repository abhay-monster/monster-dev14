/*------------------------------------------------------------------------------
Author:  Piyush Jain
Company:       Appirio
Description:   Handler Class for Case Trigger
Task Reference:

History
12th June 2015   OnCaseBeforeInsert T-409887
12th June 2015   OnCaseBeforeUpdate T-409887
------------------------------------------------------------------------------*/

public without sharing class CaseTriggerHandler extends BaseTriggerHandler {
    final String CLASSNAME = '\n\n**** CaseTriggerHandler.METHODNAME()';
    private integer BatchSize = 0;
    private CaseTriggerHelper helper;
    //private Profile CurrentUserProfile;
    public static Boolean ExecuteTriggers = true;
    public static Integer RunCount = 0;
    public static Boolean bypassRuncount = false;
    private  static String CurrentUserProfileName {
        get {
                if(CurrentUserProfileName == null){

                    Profile p = [Select Name From Profile where Id = :UserInfo.getProfileId()];
                    CurrentUserProfileName = p.name;
                }


                return CurrentUserProfileName;
        }
        set;
    }
/*
** @author : Cloud Sherpas Inc.
** @date : 03/07/2014
** @description : the class constructor method
** @paramaters : a Boolean value indicating if a trigger is executing or not, an Integer value indicating the number of records in the batch/list
** @returns : nothing
** @sample call : AccountTriggerHandler handler = new AccountTriggerHandler(Trigger.isExecuting, Trigger.size);
*/
    public CaseTriggerHandler(boolean isExecuting, integer pTriggerSize){

        // trigger is executing
        TriggerIsExecuting = isExecuting;

        // set batch size
        BatchSize = pTriggerSize;//

        // set current User profile
        //CurrentUserProfile = [Select Name From Profile where Id = :UserInfo.getProfileId()];

        // intantiate new trigger helper
        helper = CaseTriggerHelper.NewTriggerHelper(CurrentUserProfileName);
        /*
            note - developer may want to create new or extent the base helper class specific to an sObject (i.e. AccountTriggerHelper)
        */
    }

     private void updateQuoteSalesRepOnOpp(Case[] newOrUpdatedCases){
        list<Case> lstCasesToBeUpdate = new list<case>();
        list<Id> lstQuoteProposals = new list<Id>();
        for(Case c : newOrUpdatedCases){
            if(c.Proposal_ID__c != null){
                lstQuoteProposals.add(c.Proposal_ID__c);
                lstCasesToBeUpdate.add(c);
            }
        }

        Map<id , Apttus_Proposal__Proposal__c> mapQuoteProposal= new Map<id , Apttus_Proposal__Proposal__c>([select ownerId
                                                                                                            from Apttus_Proposal__Proposal__c
                                                                                                            where id IN:lstQuoteProposals]);

        for(Case c : lstCasesToBeUpdate){
            c.Quote_Sales_Rep__c = mapQuoteProposal.get(c.Proposal_ID__c).ownerId;
        }

     }

/*
** @author : Cloud Sherpas Inc.
** @date : 03/07/2014
** @description :  this method handles the 'before insert' event for the trigger; it's purpose is to ...
** @paramaters : an array of Account objects
** @returns : nothing
*/
    public void OnBeforeInsert(List<Case> pCases){

        if (Personal_Settings__c.getInstance().trigger_case__c==false){
            system.debug('^^^ Case trigger is disabled, returning');
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        for(Case c : pCases){
            System.debug('----Case ' + c);
            SyStem.debug('xxx before insert start case owners:: '+c.OwnerId +' is Media? :: '+c.isMediaProduct__c+ ' Organization:: ' +c.Organization__c);
            system.debug('Case Subject? ' + c.Subject);
        }

        // omProcessingRequestLogic(newCaseList); Jeff L replaced method with below
        caseAssignContact(pCases);
        caseAssignmentProcessingLogic(pCases);
        helper.copyQueueNameToGroupField(pCases);

       // try{
            if(ExecuteTriggers) {
                for(Case c : pCases){
                    //JFreese Appirio 01/26/17 S-452628  Bypass designated validation rules if we are in CR/Rebill Automated handling
                    if(CreditRequestTriggerHandler.CreateOrdersAutomatically != null && CreditRequestTriggerHandler.CreateOrdersAutomatically == true){
                        system.debug('^^^CreditRequestTriggerHandler.CreateOrdersAutomatically=true, so setting Bypass_Validation_Rules__c to true for new case');
                        c.Bypass_Validation_Rules__c = true;
                    }else{
                        system.debug('^^^CreditRequestTriggerHandler.CreateOrdersAutomatically not true, so NOT setting Bypass_Validation_Rules__c to true for new case');
                    }
                }

                updateQuoteSalesRepOnOpp(pCases);
                //if(ExecuteTriggers && IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){


                   // note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                   //        and call the methods from handler.


                //helper.updateCaseOwnerWithOrderSentToVerificationBy(pCases, null); //- Call from inside caseAssignmentProcessingLogic(pCases);
                helper.updateCaseSLADates(pCases, Null);
                // helper.CloseCase(pCases); // TKOM S-478969 - commented out - we no longer want to close Messaging product cases, as it is now handled by routing rules.
                //helper.updateCaseOwnerWithAccountsPrimaryServiceRep(pCases, Null);
                helper.calculateCaseBusinessHours(pCases, null);
                checkCaseOwnerProfile(pCases,null);
                populateCaseSalesRepField(pCases);
                //caseRoutingLogic(pCases);
                helper.updateFirstContactActual(pCases);
                // Populate Attribute display from PLI on case - I-203436
                helper.PopulateAttributeDisplayFromPLIOnCase(pCases);
                if(UserInfo.getName() == 'Integration MAPP'){//AP I-195812
                    helper.SetOMRecordType(pCases);
                }

            }
                //helper.updateOrganisation(pCases);
                //helper.setOwnerForChildCases(pCases);
                //helper.setOwnerForValidationRequestCases(pCases);
                //helper.parentCaseGettingClosed(pCases);
                helper.updateCaseOwnerManagerField(pCases, null);
                helper.closeParentCase(pCases);

            for(Case c : pCases){
                system.debug('^^^ CaseTriggerHandler End of OnBeforeInsert - pCase status=' + c.Status + ', Owner=' + c.OwnerId);
            }

            //}
        /*}
        catch(BaseApplicationException bae){
            throw bae;
        }
        catch(Exception ex){
            system.debug(LoggingLevel.DEBUG, METHODNAME + ' :: ERROR MESSAGE = ' + ex.getMessage() + '\n\n');
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }*/
        for(Case c : pCases){
          SyStem.debug('xxx before insert end case owners:: '+c.OwnerId +'is Media? ::'+c.isMediaProduct__c+ 'Organization:: ' +c.Organization__c);
          system.debug('Case Subject? ' + c.Subject);
        }
    }

/*
** @author : Cloud Sherpas Inc.
** @date : 03/07/2014
** @description :  this method handles the 'after insert' event for the trigger; it's purpose is to ...
** @paramaters : an array of Account objects
** @returns : nothing
*/
    public void OnAfterInsert(Case[] pCases){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        if (Personal_Settings__c.getInstance().trigger_case__c==false){
            system.debug('^^^ Case trigger is disabled, returning');
            return; // If triggers are off, then exit the method
        }

        for(Case c : pCases){
            System.debug('----Case After Insert ' + c);
          SyStem.debug('xxx after insert start case owners:: '+c.OwnerId +'is Media? ::'+c.isMediaProduct__c+ 'Organization:: ' +c.Organization__c);
          system.debug('Case Subject? ' + c.Subject);
        }

        helper.copyQuoteInfoToCase(pCases);
        RunCount++;
        if(ExecuteTriggers) {
        //try{
            //if(ExecuteTriggers && IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){

                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                */
                //helper.updateCaseOwnerWithOrderSentToVerificationBy(pCases);
                //Jeff L commented out this logic - it is in the Order Trigger Handler now
            //helper.createChildCaseForMediaOrderLineItems(pCases);

            // added by George Huene 2015-03-02 for Story 3082
            //JFreese Appirio 10/16/15 I-185135
            //log showed: Future method cannot be called from a future or batch method
            //Believed to be due to nested calls to this method, so do not let it call itself
            if(!System.isBatch() && !system.isFuture()){
                //JFreese Appirio 01/26/17 S-452628  Bypass designated validation rules if we are in CR/Rebill Automated handling
                Boolean CreateOrdersAutomaticallyInFuture = false;
                if(CreditRequestTriggerHandler.CreateOrdersAutomatically != null && CreditRequestTriggerHandler.CreateOrdersAutomatically == true){
                    CreateOrdersAutomaticallyInFuture = true;
                }
                system.debug('^^^ Calling fillGroupFieldOnInsert with CreateOrdersAutomaticallyInFuture='+CreateOrdersAutomaticallyInFuture);
                CaseTriggerHelper.fillGroupFieldOnInsert((new Map<Id,Case>(pCases)).keySet(),CreateOrdersAutomaticallyInFuture);
            }

            helper.shareCasesWithCreator(pCases);
            createSharingRule(pCases);
            sendAutoReponseEmail(pCases);

                //helper.setOwnerForChildCases(pCases);
                //helper.closeParentCase2(pCases);
                //helper.setOwnerForValidationRequestCases(pCases);
            //}
        /*}
        catch(BaseApplicationException bae){
            throw bae;
        }
        catch(Exception ex){
            system.debug(LoggingLevel.DEBUG, METHODNAME + ' :: ERROR MESSAGE = ' + ex.getMessage() + '\n\n');
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }*/
            for(Case c : pCases){
                system.debug('^^^ CaseTriggerHandler End of OnAfterInsert - pCase status=' + c.Status + ', Owner=' + c.OwnerId);
            }

        }

        for(Case c : pCases){
          SyStem.debug('xxx after insert end case owners:: '+c.OwnerId +'is Media? ::'+c.isMediaProduct__c+ 'Organization:: ' +c.Organization__c);
          system.debug('Case Subject? ' + c.Subject);
        }

    }

/*
**  @author : Cloud Sherpas Inc.
**  @date : 03/07/2014
**  @description :  this method handles the 'before update' event for the trigger; it's purpose is to ...
**  @paramaters : array of old Account objects, array of new Account object, map of new Accounts, map of old Accounts
**  @returns : nothing
*/
    public void OnBeforeUpdate(Case[] pOldCases, Case[] pUpdatedCases, map<ID, Case> pCaseIdToOldCaseMap, map<ID, Case> pCaseIdToUpdatedCaseMap){
        if (Personal_Settings__c.getInstance().trigger_case__c==false){
            system.debug('^^^ Case trigger is disabled, returning');
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        for(Case c : pUpdatedCases){
            SyStem.debug('xxx before update start case owners:: '+c.OwnerId +'is Media? ::'+c.isMediaProduct__c+ 'Organization:: ' +c.Organization__c);
            system.debug('Case Subject? ' + c.Subject);
        }

        RunCount++;
        if(RunCount > 1 && !bypassRuncount) {
            return;
        }

        if(ExecuteTriggers) {
            for(Case c : pUpdatedCases){
                //JFreese Appirio 01/26/17 S-452628  Bypass designated validation rules if we are in CR/Rebill Automated handling
                //TKOM S-478912: also turning off validation for APAC cases
                system.debug('Current value of c.Bypass_Validation_Rules__c='+c.Bypass_Validation_Rules__c);
                if(CreditRequestTriggerHandler.CreateOrdersAutomatically != null && CreditRequestTriggerHandler.CreateOrdersAutomatically == true){
                    system.debug('^^^CreditRequestTriggerHandler.CreateOrdersAutomatically=true, so setting Bypass_Validation_Rules__c to true for case '+c.id);
                    c.Bypass_Validation_Rules__c = true;
                }
                else if(c.Organization__c == 'Asia Pacific'){
                    system.debug('^^^APAC Case, so setting Bypass_Validation_Rules__c to true for case '+c.id);
                    c.Bypass_Validation_Rules__c = true;
                }
                else{
                    system.debug('^^^CreditRequestTriggerHandler.CreateOrdersAutomatically not true, so NOT setting Bypass_Validation_Rules__c to true for case '+c.id);
                }
            }


        //try{
                updateQuoteSalesRepOnOpp(pUpdatedCases);
                populateCaseSalesRepField(pUpdatedCases);
            //if(ExecuteTriggers && IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){

                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                */
                //helper.closeParentCase2(pUpdatedCases);
                helper.parentCaseGettingClosed(pUpdatedCases);
                helper.closeParentCase(pUpdatedCases);

                helper.AllChildCaseMediaTypeIsClosed(pCaseIdToUpdatedCaseMap, pCaseIdToOldCaseMap);
                //CloudSherpas, 12.18.2014 - commmented out line 133, not needed for Before Update event.
                //helper.updateCaseOwnerWithAccountsPrimaryServiceRep(pUpdatedCases, pCaseIdToOldCaseMap);
                helper.updateCaseOwnerWithOrderSentToVerificationBy(pUpdatedCases, pCaseIdToOldCaseMap);
                helper.updateCaseSLADates(pUpdatedCases, pCaseIdToOldCaseMap);

                // Added by George Huene 2015-03-02 for story 3082
                helper.copyQueueNameToGroupField(pUpdatedCases);
                checkCaseOwnerProfile(pUpdatedCases,pCaseIdToOldCaseMap);
                helper.updateFirstContactActual(pUpdatedCases);
                helper.calculateCaseBusinessHours(pUpdatedCases, pCaseIdToOldCaseMap);
        }
                //helper.closeParentCase(pUpdatedCases);
            //}
       /* }
        catch(BaseApplicationException bae){
            throw bae;
        }
        catch(Exception ex){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }  */
        for(Case c : pUpdatedCases){
          SyStem.debug('xxx before update start case owners:: '+c.OwnerId +'is Media? ::'+c.isMediaProduct__c+ 'Organization:: ' +c.Organization__c);
          system.debug('Case Subject? ' + c.Subject);
        }
    }

/*
**  @author : Cloud Sherpas Inc.
**  @date : 07/02/2014
**  @description :  this method handles the 'after update' event for the trigger; it's purpose is to ...
**  @paramaters : array of old Account objects, array of new Account object, map of new Accounts, map of old Accounts
**  @returns : nothing
*/
    public void OnAfterUpdate(Case[] pOldCases, Case[] pUpdatedCases, map<ID, Case> pCaseIdToOldCaseMap, map<ID, Case> pCaseIdToUpdatedCaseMap){
        for(Case c : pUpdatedCases){
          SyStem.debug('xxx after update start case owners:: '+c.OwnerId +'is Media? ::'+c.isMediaProduct__c+ 'Organization:: ' +c.Organization__c);
          system.debug('Case Subject? ' + c.Subject);
        }
        if (Personal_Settings__c.getInstance().trigger_case__c==false){
            system.debug('^^^ Case trigger is disabled, returning');
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        system.debug('#1 ' + ExecuteTriggers);
        RunCount++;
        if(RunCount > 1 && !bypassRuncount) {
            return;
        }


        //try{
            //if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                if(ExecuteTriggers){
                    //helper.closeParentCase(pUpdatedCases);
                    helper.SetOrderLineItemImplementationCompleteCheckbox(pUpdatedCases);
                    helper.caseOwnerUpdate(pUpdatedCases, pCaseIdToOldCaseMap);
                    helper.updateSimilarChildCaseOwner(pUpdatedCases, pCaseIdToOldCaseMap);//@Story : 1669 @Element : E2081, E2439
                    helper.copyQuoteInfoToCase(pUpdatedCases);
                    helper.updateCaseOwnerManagerField(pUpdatedCases, pCaseIdToOldCaseMap);
                    //Paypal Stuff
                    PaypalModel.PaypalCaptureTransaction(pUpdatedCases, pCaseIdToOldCaseMap);
                }



                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                */

           // }
       /* }
        catch(BaseApplicationException bae){
            throw bae;
        }
        catch(Exception ex){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }   */

        for(Case c : pUpdatedCases){
          SyStem.debug('xxx after update start case owners:: '+c.OwnerId +'is Media? ::'+c.isMediaProduct__c+ 'Organization:: ' +c.Organization__c);
          system.debug('Case Subject? ' + c.Subject);

          //TKOM S-478912: turning back on validation for APAC cases
          system.debug('Current value of c.Bypass_Validation_Rules__c='+c.Bypass_Validation_Rules__c);
          if(c.Organization__c == 'Asia Pacific' && c.Bypass_Validation_Rules__c==true){
              system.debug('^^^APAC Case, so setting Bypass_Validation_Rules__c back to false or case '+c.id);
              c.Bypass_Validation_Rules__c = false;
          }
          else{
              system.debug('^^^CreditRequestTriggerHandler.CreateOrdersAutomatically not true, so NOT setting Bypass_Validation_Rules__c to true for case '+c.id);
          }


        }
    }


   /* Jeff L commented out - isn't being called from anywhere
   public static void onCaseBeforeInsert(list<Case> newCaseList){

    }

    public static void onCaseBeforeUpdate(map<Id, Case> newMap, map<Id, Case> oldMap){
        list<Case> newCaseList = new list<Case>();

        if(ExecuteTriggers){
            for(Id caseId : newMap.keySet()){
                if(newMap.get(caseId).AccountId != oldMap.get(caseId).AccountId){
                    newCaseList.add(newMap.get(caseId));
                }
            }
            if(!newCaseList.isEmpty()){
                populateCaseSalesRepField(newCaseList);
            }
        }

        //removing before update
        //omProcessingRequestLogic(newCaseList);
    }*/

    /*------------------------------------------------------------------------------
    Description:   Update of Primary Sales Rep Manager of Case before Insert
    Task Reference:  T-409887
    12th June 2015
    Dev name- Piyush Jain
    ------------------------------------------------------------------------------*/
    private static void populateCaseSalesRepField(list<Case> newCaseList) {
        Final String CLASSNAME = '\n\n**** CaseTriggerHandler.METHODNAME()';
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populateCaseSalesRepField');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        list<Case> caseList= new list<Case>();
        map<Id,list<Case>> mapCases = new map<Id,list<Case>>();
        for(Case cse : newCaseList) {
            System.debug('cse >>' + cse);
            if(!mapCases.containskey(cse.AccountId)){
                mapCases.put(cse.AccountId,new list<Case>());
            }
            mapCases.get(cse.AccountId).add(cse);
        }

        System.debug('mapCases >>' + mapCases);

        if(mapCases != null && mapCases.size()>0){
        map<Id,Account> mapAccount = new map<Id,Account>([SELECT Id, PrimarySalesRepManager__c FROM Account WHERE Id IN : mapCases.keyset()]);
            System.debug('mapAccount >>'+ mapAccount);
            for(String accId : mapCases.keyset()) {
                if(mapAccount != null && mapAccount.containskey(accId) && mapCases.containskey(accId)){
                    for(Case cs : mapCases.get(accId)) {
                        Account acc= mapAccount.get(accId);
                        if(cs.Primary_Sales_Rep_Manager__c != acc.PrimarySalesRepManager__c){
                            cs.Primary_Sales_Rep_Manager__c = acc.PrimarySalesRepManager__c;
                            caseList.add(cs);
                        }
                    }
                }
            }
        }
    }

    /*private static void caseRoutingLogic(List<Case> lstCases){
        User currentuser = [Select Id,Name,Email,Country from User where Id=:userinfo.getuserId()];
        map<Id,List<Case>> mapRecordTypeIdToCases = new map<Id,List<Case>>();
        Map<String,Id> recordNameToIdMap = new Map<String,Id>();
        Map<Id,Id> recTypeToOwnerMap = new Map<Id,Id>();
        List<Case> parentSharingRecordTypeCases = new List<Case>();
        List<Case> registrationRecordTypeCases = new List<Case>();

        Id parentRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Parent/Child Inventory Sharing').getRecordTypeId();
        ID registrationRecordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Registration/VATFiscal Code').getRecordTypeId();

        //Id accountRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Account Name/Address change').getRecordTypeId();

        for(Case newCase : lstCases){

            if(newCase.recordTypeId != parentRecordTypeId && newCase.recordTypeId != registrationRecordTypeID){
                if(!mapRecordTypeIdToCases.containsKey(newCase.recordTypeId))
                    mapRecordTypeIdToCases.put(newCase.recordTypeId,new List<Case>());

                mapRecordTypeIdToCases.get(newCase.recordTypeId).add(newCase);
            }else if(newCase.recordTypeId == parentRecordTypeId){

                parentSharingRecordTypeCases.add(newCase);
            }else if(newCase.recordTypeId == registrationRecordTypeID){
                registrationRecordTypeCases.add(newCase);
            }

        }

        for(RecordType  recType :[SELECT id,Name
                                       FROM RecordType
                                     WHERE SobjectType='Case' AND Id IN :mapRecordTypeIdToCases.keyset()]){


                   recordNameToIdMap.put( recType.Name,recType.id);
          }

          for(CaseRoutingRule__c caseRouting : [Select Id,QuoteSellingCountry__c,CaseRecordType__c,OwnerId,CaseOwner__c from CaseRoutingRule__c where QuoteSellingCountry__c  =:  currentuser.Country
                                    AND CaseRecordType__c IN :recordNameToIdMap.KeySet()]){

                    if(recordNameToIdMap.containsKey(caseRouting.CaseRecordType__c)){

                        recTypeToOwnerMap.put(recordNameToIdMap.get(caseRouting.CaseRecordType__c), caseRouting.OwnerId);
                    }

        }

         for(Case newCase : lstCases){

                if(recTypeToOwnerMap.containsKey(newCase.recordTypeId)){

                    newCase.OwnerId = recTypeToOwnerMap.get(newCase.recordTypeId);


                }
        }
        System.debug('parentSharingRecordTypeCases=='+parentSharingRecordTypeCases);
        Map<String,id> queueNameToId = new Map<String,Id>();
       //updated by Vivek
        Set<String> queueLst = new Set<String>{'DACH.EMP.Core','FR.EMP.Core','IT.EMP.Core','ES.EMP.Core','NL.EMP.Core','UKIE.EMP.Core','SE.EMP.Core','DACH.OMT','South.OMT','North.OMT','Data Governance'};
    for(QueueSobject queue : [Select Id, SobjectType, QueueId, Queue.Name From QueueSobject where Queue.Name IN: queueLst]){

            queueNameToId.put(queue.Queue.Name,queue.QueueId);
        }
        if(parentSharingRecordTypeCases.size()>0){
            for(Case parentTypeCase : parentSharingRecordTypeCases){
                System.debug('parentTypeCase'+parentTypeCase+'parentSharingRecordTypeCases=='+currentuser.Country+'currentuser=='+currentuser);
                if(currentuser.Country == 'Germany' || currentuser.Country == 'Switzerland' || currentuser.Country == 'Austria'){

                    parentTypeCase.OwnerId = queueNameToId.get('DACH.EMP.Core');
                }else if(currentuser.Country == 'France' || currentuser.Country == 'Belgium' || currentuser.Country == 'Luxembourg'){

                    parentTypeCase.OwnerId = queueNameToId.get('FR.EMP.Core');
                }else if(currentuser.Country == 'Italy'){
                    parentTypeCase.OwnerId = queueNameToId.get('IT.EMP.Core');
                }else if(currentuser.Country == 'Spain'){
                    parentTypeCase.OwnerId = queueNameToId.get('ES.EMP.Core');
                }else if(currentuser.Country == 'NetherLands'){

                    parentTypeCase.OwnerId = queueNameToId.get('NL.EMP.Core');

                }else if(currentuser.Country ==  'Sweden' || currentuser.Country == 'Denmark' || currentuser.Country == 'Norway'){
                    parentTypeCase.OwnerId = queueNameToId.get('SE.EMP.Core');
                }else if(currentuser.Country == 'UK' || currentuser.Country == 'United Kingdom'  || currentuser.Country == 'Ireland'){
                    parentTypeCase.OwnerId = queueNameToId.get('UKIE.EMP.Core');

                }
                System.debug('parentTypeCase.OwnerId =='+parentTypeCase.OwnerId );
            }


        }
        if(registrationRecordTypeCases.size()>0){
            for(Case registrationTypeCase : registrationRecordTypeCases){
                System.debug('registrationTypeCase'+registrationTypeCase+'registrationTypeCase=='+currentuser.Country+'currentuser=='+currentuser);
                if(currentuser.Country == 'Germany' || currentuser.Country == 'Switzerland' || currentuser.Country == 'Austria'){

                    registrationTypeCase.OwnerId = queueNameToId.get('DACH.OMT');
                }else if(currentuser.Country == 'France' || currentuser.Country == 'Italy' || currentuser.Country == 'Spain'){

                    registrationTypeCase.OwnerId = queueNameToId.get('South.OMT');
                }else if(currentuser.Country == 'Belgium' || currentuser.Country == 'Luxembourg' || currentuser.Country == 'NetherLands' || currentuser.Country ==  'Sweden' || currentuser.Country == 'Denmark' || currentuser.Country == 'Norway' || currentuser.Country == 'UK' || currentuser.Country == 'United Kingdom'  || currentuser.Country == 'Ireland'){
                    registrationTypeCase.OwnerId = queueNameToId.get('North.OMT');
                }else if(currentuser.Country == 'United States' || currentuser.Country == 'Canada' ){

                    registrationTypeCase.OwnerId = queueNameToId.get('Data Governance');

                }
                System.debug('registrationTypeCase.OwnerId =='+registrationTypeCase.OwnerId );
            }


        }
    }*/

    /*------------------------------------------------------------------------------
    Description:
    Task Reference:  T-419626
    17 June 2015
    Dev name-
    ------------------------------------------------------------------------------*/

  /*  private static void omProcessingRequestLogic(List<Case> newCases){
        ID omProcessingReuestRecordtypeid = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OM Processing Request').getRecordTypeId();
        List<case> lstOmProcessingRequestCases = new List<Case>();
        set<string> setQuoteSellingCountry= new set<string>();
        Set<id> setOfCaseQuotesId = new set<id>();
        for(Case c : newCases ){
            if(c.RecordTypeId == omProcessingReuestRecordtypeid ){
                lstOmProcessingRequestCases.add(c);

                if(c.Quote_Selling_Country__c != null || c.Quote_Selling_Country__c != '')
                    setQuoteSellingCountry.add(c.Quote_Selling_Country__c);


                if(c.Proposal_ID__c != null)
                    setOfCaseQuotesId.add(c.Proposal_ID__c);
            }
        }

        //
        if(lstOmProcessingRequestCases.size()>0){

            map<id,Apttus_Proposal__Proposal__c> mapCaseRelatedQuotes ;
            if(setOfCaseQuotesId.size() > 0){
               mapCaseRelatedQuotes  = new map<id,Apttus_Proposal__Proposal__c>([select CurrencyRef__c from Apttus_Proposal__Proposal__c where Id in : setOfCaseQuotesId]);
            }


            //CaseRoutingRule__c records which are of Record type 'OM Processing' and Country equal to Case Quote_Selling_Country__c
            list<CaseRoutingRule__c> routingRules = [SELECT CaseBusinessHours__c,
                                                                  QuoteSellingCountry__c ,
                                                                  OwnerId ,
                                                                  CaseStatus__c ,
                                                                  FirstContactCommitmentHours__c ,
                                                                  ResolutionCommitmentHours__c ,
                                                                  BusinessProcess__c
                                                           FROM CaseRoutingRule__c
                                                           WHERE CaseRecordType__c= 'OM Processing Request'];
                                                           //AND QuoteSellingCountry__c IN :setQuoteSellingCountry ];
             list<CaseRoutingRule__c> lstCaseRoutingRule = new list<CaseRoutingRule__c>();
             list<CaseRoutingRule__c> lstCaseRoutingRuleExceptionVersion = new list<CaseRoutingRule__c>();
             for(CaseRoutingRule__c rule : routingRules){
                if(rule.QuoteSellingCountry__c != null && setQuoteSellingCountry.contains(rule.QuoteSellingCountry__c)){
                    lstCaseRoutingRule.add(rule);
                }
                else if(rule.QuoteSellingCountry__c == '') {
                    lstCaseRoutingRuleExceptionVersion.add(rule);
                }
             }


            //system.assert(false , setQuoteSellingCountry );
            Map<String , CaseRoutingRule__c> mapCountryToCaseRoutingRules = new Map<String , CaseRoutingRule__c>();

            if(lstCaseRoutingRule.size() > 0){
                for(CaseRoutingRule__c cRR : lstCaseRoutingRule){
                    mapCountryToCaseRoutingRules.put(cRR.QuoteSellingCountry__c , cRR );
                }
            }
            //

            /*list<CaseRoutingRule__c> lstCaseRoutingRuleExceptionVersion = [SELECT CaseBusinessHours__c,
                                                                                  QuoteSellingCountry__c ,
                                                                                  OwnerId ,
                                                                                  CaseStatus__c ,
                                                                                  FirstContactCommitmentHours__c ,
                                                                                  ResolutionCommitmentHours__c ,
                                                                                  BusinessProcess__c
                                                                           FROM CaseRoutingRule__c
                                                                           WHERE CaseRecordType__c= 'OM Processing Request'
                                                                           AND QuoteSellingCountry__c = ''];



            for(Case c : newCases){
                CaseRoutingRule__c  cRR ;
                if(mapCountryToCaseRoutingRules.containsKey(c.Quote_Selling_Country__c)){
                    cRR = (mapCountryToCaseRoutingRules.get(c.Quote_Selling_Country__c));
                    } else {

                    if(lstCaseRoutingRuleExceptionVersion.size() > 0)
                        cRR = lstCaseRoutingRuleExceptionVersion[0] ;
                    //else
                        //c.adderror('No matching Case Routing Rule Record Found' , True);


                    }

                    if(cRR != null){
                        c.OwnerId = cRR.OwnerId;
                        c.status = cRR.CaseStatus__c ;
                        c.BusinessHoursId = cRR.CaseBusinessHours__c;
                        c.FirstContactCommitment__c = cRR.FirstContactCommitmentHours__c ;
                        c.ResolutionCommitment__c = cRR.ResolutionCommitmentHours__c;
                    }
                    if(c.Proposal_ID__c != null){

                        if(mapCaseRelatedQuotes.get(c.Proposal_ID__c).CurrencyRef__c =='USD' && c.QuoteTotal__c > 50000){
                             c.Priority = 'High';
                        }else{
                            CurrencyUtil convert = new CurrencyUtil ();
                            Decimal quoteAmount = convert.convertToUSD(mapCaseRelatedQuotes.get(c.Proposal_ID__c).CurrencyRef__c , c.QuoteTotal__c);
                            if(quoteAmount > 50000)
                                c.Priority = 'High';
                        }
                    }
                Map<string,ISO_Countries__c> mapCountryCodes = ISO_Countries__c.getAll();
                Map<string,ISO_Languages__c> mapLanguageCodes = ISO_Languages__c.getAll();

                String countryCode;
                String languageCode;
                String orderType;

                if(mapCountryCodes .containskey(c.Quote_Selling_Country__c))
                    countryCode = mapCountryCodes .get(c.Quote_Selling_Country__c).ISO_Code__c;
                else
                    countryCode  = '';

                if(mapLanguageCodes .containskey(c.Quote_Selling_Country__c))
                    languageCode= mapLanguageCodes .get(c.Quote_Selling_Country__c).ISO_Code__c;
                else
                    languageCode= '';

                 if(c.Order_Type__c == null)
                     orderType = '';
                  else
                      orderType = c.Order_Type__c;

                //system.assert(false , cRR.BusinessProcess__c);
                if(cRR != null && cRR.BusinessProcess__c != null){
                c.BusinessProcess__c = cRR.BusinessProcess__c.replace('[CountryCode]' , countryCode  )
                                                             .replace('[LanguageCode]' ,languageCode )
                                                             .replace('[OrderType]' , '') ;
                }
            }
            //

        }
    }*/

    /*
    Method to handle both the creation of new Person Account for Email2Case and relate to
    relevant Contact if multiple matches were found in Email2Case creation
    */
    private static void caseAssignContact(List<Case> newCases){
        Final String CLASSNAME = '\n\n**** CaseTriggerHandler.METHODNAME()';
        final string METHODNAME = CLASSNAME.replace('METHODNAME','caseAssignContact');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Set<String> SuppliedEmails = new Set<String>();
        List<Case> nonMatchedCases = new List<Case>();

        //Find if Cases are being created with no matched Contact but with a supplied Email
        for(Case c:newCases){
            if(c.ContactId == null && c.SuppliedEmail != null){
                system.debug('inside null check for case: ' + c.ContactID + ' email: ' + c.SuppliedEmail);
                SuppliedEmails.add(c.SuppliedEmail);
                nonMatchedCases.add(c);
            }
        }

        if(SuppliedEmails.isEmpty()){
            system.debug('supplied emails is empty, exiting method');
            return;
        }

        //Search to find if we did not match due to multiple Contacts existing
        List<Contact> listContacts = [Select id, Email, Account.RecordType.Name, LastActivityDate, LastModifiedDate From Contact Where Email IN :SuppliedEmails];
        Map<String,List<Contact>> MapEmployer = new Map<String,List<Contact>>();
        Map<String,List<Contact>> MapPerson = new Map<String,List<Contact>>();
        for(Contact con: listContacts){
            System.Debug('###'+con + ' ' + con.Account.RecordType.Name);
            if(con.Account.RecordType.Name == 'Business Accounts'){
                if(!MapEmployer.containsKey(con.Email)){
                    MapEmployer.put(Con.Email,new List<Contact>());
                }
                MapEmployer.get(con.Email).add(con);
            }
            else if(con.Account.RecordType.Name == 'Person Account'){
                if(!MapPerson.containsKey(con.Email)){
                    MapPerson.put(Con.Email,new List<Contact>());
                }
                MapPerson.get(con.Email).add(con);
            }

        }
        System.Debug('###'+MapEmployer);
        System.Debug('###'+Mapperson);
        List<Contact> lstContacts = new List<Contact>();
        List<Case> NewContactCases = new List<Case>();
        Id personAccountRecordType = Utility.GetRecordTypeIdBySObjectNameAndType('Account', 'Person Account');
        List<Account> lstNewPersonAccounts = new List<Account>();
        Account newPersonAccount;
        SuppliedEmails.clear();

        for(Case c:nonMatchedCases){
            System.Debug('###'+c.SuppliedEmail);
            //Matches were found
            if(MapEmployer.containsKey(c.SuppliedEmail)){
                lstContacts = MapEmployer.get(c.SuppliedEmail);
                c.ContactID = CaseTriggerHelper.findWinningContact(lstContacts);
            }
            else if (MapPerson.containsKey(c.suppliedEmail)){
                lstContacts = MapPerson.get(c.SuppliedEmail);
                System.Debug('###'+lstContacts);
                c.ContactID = CaseTriggerHelper.findWinningContact(lstContacts);
            }
            //Matches were not
            else{
                newPersonAccount = new Account();
                if(c.SuppliedName != null){
                    List<String> Name = c.SuppliedName.split(' ',2);
                    if(Name.size()==1)newPersonAccount.LastName = Name[0];
                    if(Name.size()==2){
                        newPersonAccount.FirstName = Name[0];
                        newPersonAccount.LastName = Name[1];
                    }
                    newPersonAccount.PersonEmail = c.SuppliedEmail;
                    newPersonAccount.Organization__c = c.Organization__c;
                    newPersonAccount.Organization__pc = c.Organization__c;
                    newPersonAccount.RecordTypeId = personAccountRecordType;
                    newPersonAccount.PersonLeadSource = 'Email2Case';
                    /* TKOM I-271224: Added above line (PersonLeadSource) to avoid validation error when creating the new person acct:

                        13:00:48.304 (844895272)|FATAL_ERROR|System.DmlException: Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, APAC Consumer: Lead Source is required: [PersonLeadSource]

                        Class.CaseTriggerHandler.caseAssignContact: line 816, column 1
                        Class.CaseTriggerHandler.OnBeforeInsert: line 102, column 1
                        Trigger.CaseTrigger: line 14, column 1

                    */
                    lstNewPersonAccounts.add(newPersonAccount);
                    SuppliedEmails.add(c.suppliedEmail);
                    NewContactCases.add(c);
                }
            }
        }

        if(lstNewPersonAccounts.size()>0) {
            insert lstNewPersonAccounts;
            listContacts = [Select id, Email, Account.RecordType.Name, LastActivityDate, LastModifiedDate From Contact Where Email IN :SuppliedEmails];
            Map<String, Contact> MapNewContacts = new Map<String,Contact>();

            for(Contact con:listContacts){
                MapNewContacts.put(con.Email,con);
            }

            for(Case c: newCases){
                if(MapNewContacts.containsKey(c.suppliedEmail)){
                    c.ContactId = MapNewContacts.get(c.SuppliedEmail).Id;
                    CaseTriggerHelper.ContactsCreated.add(MapNewContacts.get(c.SuppliedEmail).Id);
                }
            }
        }
    }

    /*
    **------------------------------------------------------------------------------
    Description: Function to handle case assignment using the case routing rules object.  Generalized enough so that it will be
    easy to add extra requirements as needed
    Story Reference: S-318990
    19 Aug 2015
    Dev name - Jeff Lescarbeau
    ------------------------------------------------------------------------------
    **
    **
    **
    */
    private void caseAssignmentProcessingLogic(List<Case> newCases){
        Final String CLASSNAME = '\n\n**** CaseTriggerHandler.METHODNAME()';
        final string METHODNAME = CLASSNAME.replace('METHODNAME','caseAssignmentProcessingLogic');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        ID omProcessingReuestRecordtypeid = Utility.GetRecordTypeIdBySObjectNameAndType('Case','OM Processing Request');
        ID creditLimitRecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Case','Request re Credit Limit');
        ID newRequestRecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Case','New Account Request');
        ID gcsRecordTypeID = Utility.GetRecordTypeIdBySObjectNameAndType('Case','GCS');
        Id parentRecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Case','Parent/Child Inventory Sharing');
        ID registrationRecordTypeID = Utility.GetRecordTypeIdBySObjectNameAndType('Case','Registration/VATFiscal Code');
        ID productImplementationRecordTypeID = Utility.GetRecordTypeIdBySObjectNameAndType('Case','Product Implementation');
        ID creditNegateRecordTypeID = Utility.GetRecordTypeIdBySObjectNameAndType('Case', 'Credit/Negate');
        ID creditRequestRecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Case', 'Credit Request');

        // TKOM S-460088
         ID euSalesSupportRecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Case', 'EU Sales Support Request');

        Map<id,RecordType> mapDCRTs = new Map<id,RecordType>([Select Id, Name From RecordType Where SobjectType = 'Case' and Description like 'Data Cleansing%']);
        Set<String> DCRTNames = new Set<String>();
        for(RecordType rt:mapDCRTs.values()){
            DCRTNames.add(rt.Name);
        }
        system.debug('xxxx DCRTNames '+DCRTNames);
        List<case> lstOmProcessingRequestCases = new List<Case>();
        List<case> lstcreditRequestRecordTypeId = new List<Case>();

        set<string> setQuoteSellingCountry= new set<string>();
        Set<Id> setAccountIdsToQuery = new set<Id>();
        Set<id> setOfCaseQuotesId = new set<id>();
        Set<Id> setOfCaseOrderIds = new Set<Id>();
        User currentuser = [Select Id,Name,Email,Country,Location__c from User where Id=:userinfo.getuserId()]; //
        system.debug('xxxx currentuser '+currentuser);
        Boolean isWebtoCase = false;

        for(Case c : newCases ){

            //if we are a cloned email to case, we are already assigned
            //and we do not need to be routed again (this will route to the
            //wrong queue)
            if(c.Cloned_Email_To_Case__c){
                continue;
            }
            //Logic needed omProcessing Record Type
            if(c.RecordTypeId == omProcessingReuestRecordtypeid ){
                lstOmProcessingRequestCases.add(c);

                if(c.Quote_SellingCountry__c != null || c.Quote_SellingCountry__c != ''){
                    setQuoteSellingCountry.add(c.Quote_SellingCountry__c);
                }
                if(c.Proposal_ID__c != null){
                    setOfCaseQuotesId.add(c.Proposal_ID__c);
                }
            }
            //Logic needed for the Credit Request Record Type
            else if(c.RecordTypeId == creditLimitRecordTypeId){
                lstcreditRequestRecordTypeId.add(c);
            }
            //logic needed for the Product Implementation Record Type
            else if(c.RecordTypeId == productImplementationRecordTypeID || c.RecordTypeId == creditNegateRecordTypeID){
                if(c.AccountId != null){
                    setAccountIdsToQuery.add(c.AccountId);
                }

                if(c.Order__c != null){
                    setOfCaseOrderIds.add(c.Order__c);
                }
            }

            if(c.Brand__c != null){
                isWebtoCase = true;
            }
        }

        //Find all Quote Proposals related to Cases
        map<id,Apttus_Proposal__Proposal__c> mapCaseRelatedQuotes ;
        if(setOfCaseQuotesId.size() > 0){
           mapCaseRelatedQuotes  = new map<id,Apttus_Proposal__Proposal__c>([select CurrencyRef__c ,
                                                                                      Net_Total__c,
                                                                                     //Quote_Total__c ,
                                                                                     Language__c ,
                                                                                     Order_Type__c,
                                                                                     RecordType.Name
                                                                             from Apttus_Proposal__Proposal__c
                                                                             where Id in : setOfCaseQuotesId]);
        }

        //Find all accounts related to product cases:
        Map<Id,Account> mapAccounts;
        if(setAccountIdsToQuery.size() > 0){
            mapAccounts = new Map<Id,Account>([Select Id, PrimaryServiceRep__c, ServiceTier__c From Account where Id in :setAccountIdsToQuery]);
        }
        //Find all Orders related to cases
        Map<Id,Order__c> mapOrders;
        if(setOfCaseOrderIds.size() > 0){
            mapOrders = new Map<Id,Order__c>([Select Id, VerifiedBy__c from Order__c where Id in :setOfCaseOrderIds]);
        }

        //Query CaseRoutingRule__c to get the routing rules needed
        List<CaseRoutingRule__c> routingRules = isWebtoCase ? CaseRoutingUtility.getCaseRoutingRulesWeb() : CaseRoutingUtility.getCaseRoutingRulesInternal();
        Map<String,List<CaseRoutingRule__c>> mapCaseRoutingRule = new map<String,List<CaseRoutingRule__c>>();


         //This map is specific for OM Processing currently
         Map<String , CaseRoutingRule__c> mapCountryAndRecordTypeToCaseRoutingRules = new Map<String , CaseRoutingRule__c>();
         //This map is specific for Product Implementation routing
         //Map<String, CaseRoutingRule__c> mapServiceTierAndCountryToCaseRoutingRule = new Map<String, CaseRoutingRule__c>();
         CaseRoutingRule__c omProcessingRuleException;
         CaseRoutingRule__c omProcessingRuleRebillException;
         CaseRoutingRule__c catchAllRule;

         // Find all relevant Case Routing Rules and populate into Maps based upon Record Type Name
        system.debug(':::: Get list of all CaseRoutingRule__c to process and build rule keys for matching later.');
         for(CaseRoutingRule__c rule : routingRules){
           // Uncomment next line to output full list of rules to DEBUG logs.  Commenting out to save log space.
           //system.debug('CaseRoutingRule__c: ' + rule.Id + ' :: ' + rule.Name + ' -- CaseRecordType__c=' + rule.CaseRecordType__c);

            //lets first process the OM Processing Routing rules
            if(rule.CaseRecordType__c == 'OM Processing Request'){

                if(rule.QuoteSellingCountry__c != null && setQuoteSellingCountry.contains(rule.QuoteSellingCountry__c)){
                    if(!mapCaseRoutingRule.containsKey('OM Processing Request')){
                        mapCaseRoutingRule.put('OM Processing Request',new List<CaseRoutingRule__c>());

                    }
                    mapCaseRoutingRule.get('OM Processing Request').add(rule);
                    mapCountryAndRecordTypeToCaseRoutingRules.put(rule.QuoteSellingCountry__c + rule.Quote_Record_Type__c, rule);
                }
                else if(rule.QuoteSellingCountry__c == '' || rule.QuoteSellingCountry__c == null ) {
                    if(rule.Quote_Record_Type__c == 'Proposal Locked'){
                        omProcessingRuleException = rule;
                    }
                    if(rule.Quote_Record_Type__c == 'Rebill Proposal'){
                        omProcessingRuleRebillException = rule;
                    }
                }
            }
            //check the rules for Credit Limit and add to our map
            else if(rule.CaseRecordType__c == 'Request re Credit Limit'){

                if(!mapCaseRoutingRule.containsKey('Request re Credit Limit')){
                        mapCaseRoutingRule.put('Request re Credit Limit',new List<CaseRoutingRule__c>());

                    }
                mapCaseRoutingRule.get('Request re Credit Limit').add(rule);
            }
            /*else if(rule.CaseRecordType__c == 'New Account Request'){
                if(!mapCaseRoutingRule.containsKey('Data Governance')){
                        mapCaseRoutingRule.put('Data Governance',new List<CaseRoutingRule__c>());
                    }
                mapCaseRoutingRule.get('Data Governance').add(rule);
            }*/
            else if(rule.CaseRecordType__c == 'GCS'){

                //Normal GCS routing
                if(rule.Case_Subject__c == null && rule.CaseContactSource__c != null && rule.CaseContactSource__c != 'Sales' && rule.CaseLanguage__c != null && rule.Billing_Country__c != null){
                    rule.Case_Subject__c = 'CatchAll';
                }

                if(!mapCaseRoutingRule.containsKey('GCS'+rule.CaseContactSource__c+rule.CaseLanguage__c+rule.Billing_Country__c+rule.Case_Subject__c)){
                        mapCaseRoutingRule.put('GCS'+rule.CaseContactSource__c+rule.CaseLanguage__c+rule.Billing_Country__c+rule.Case_Subject__c,new List<CaseRoutingRule__c>());
                //}
                mapCaseRoutingRule.get('GCS'+rule.CaseContactSource__c+rule.CaseLanguage__c+rule.Billing_Country__c+rule.Case_Subject__c).add(rule);

                }
                // Sales to Service scenario - doesn't care about Subject, so remove it from the key
                else if(rule.CaseContactSource__c == 'Sales' && rule.CaseLanguage__c != null && rule.Billing_Country__c != null && rule.Case_Request_Type__c != null){  //TK 9/5/16 S-440359: added Case_Request_Type__c
                    if(!mapCaseRoutingRule.containsKey('GCS'+rule.CaseContactSource__c+rule.CaseLanguage__c+rule.Billing_Country__c+rule.Case_Request_Type__c)){ //TK 9/5/16 S-440359: added Case_Request_Type__c
                        mapCaseRoutingRule.put('GCS'+rule.CaseContactSource__c+rule.CaseLanguage__c+rule.Billing_Country__c+rule.Case_Request_Type__c,new List<CaseRoutingRule__c>());

                    }
                    mapCaseRoutingRule.get('GCS'+rule.CaseContactSource__c+rule.CaseLanguage__c+rule.Billing_Country__c+rule.Case_Request_Type__c).add(rule);
                }
            }

            // TKOM S-460088
            //Logic needed for the EU Sales Support Request Record Type
            else if(rule.CaseRecordType__c == 'EU Sales Support Request'){
              string ruleKeyEUSalesSupport = 'EU Sales Support Request';// + '|Org=' + rule.Organization__c;

              if(!mapCaseRoutingRule.containsKey(ruleKeyEUSalesSupport)){
                  mapCaseRoutingRule.put(ruleKeyEUSalesSupport, new List<CaseRoutingRule__c>());
                  system.debug('::: cRR ruleKeyEUSalesSupport: ' + ruleKeyEUSalesSupport + ' :: ' + 'CaseRoutingRule__c: ' + rule.Id + ' :: ' + rule.Name + ' -- CaseRecordType__c=' + rule.CaseRecordType__c);
              }
              mapCaseRoutingRule.get(ruleKeyEUSalesSupport).add(rule);
            }


            /*else if(rule.CaseRecordType__c == 'Parent/Child Inventory Sharing'){
                if(!mapCaseRoutingRule.containsKey('Parent/Child Inventory Sharing|'+rule.Current_User_Country__c)){
                        mapCaseRoutingRule.put('Parent/Child Inventory Sharing|'+rule.Current_User_Country__c,new List<CaseRoutingRule__c>());
                    }
                mapCaseRoutingRule.get('Parent/Child Inventory Sharing|'+rule.Current_User_Country__c).add(rule);
            }
            else if(rule.CaseRecordType__c == 'Registration/VATFiscal Code'){
                if(!mapCaseRoutingRule.containsKey('Registration/VATFiscal Code|'+rule.Current_User_Country__c)){
                        mapCaseRoutingRule.put('Registration/VATFiscal Code|'+rule.Current_User_Country__c,new List<CaseRoutingRule__c>());
                    }
                mapCaseRoutingRule.get('Registration/VATFiscal Code|'+rule.Current_User_Country__c).add(rule);
            }*/

            /*
            // BEGIN OLD Product Implementation Routing
            else if(rule.CaseRecordType__c == 'Product Implementation'){

                string ruleKey = 'Product Implementation ' + rule.Service_Tier__c + rule.Organization__c;
                if(!mapCaseRoutingRule.containsKey(ruleKey)){
                        mapCaseRoutingRule.put(ruleKey,new List<CaseRoutingRule__c>());
                    }
                mapCaseRoutingRule.get(ruleKey).add(rule);

                //Need this map for some EU countries.
                if(rule.Billing_Country__c != null){
                    mapServiceTierAndCountryToCaseRoutingRule.put(rule.Service_Tier__c + rule.Billing_Country__c, rule);
                }
            } // END OLD Product Implementation Routing
            */

            //TKOM S-481927: NEW Credit/Negate Routing: route only by Organization
            else if(rule.CaseRecordType__c == 'Credit/Negate'){
              string ruleKeyCredNegOrg = 'CreditNegate' + '|Org=' + rule.Organization__c;
                if(!mapCaseRoutingRule.containsKey(ruleKeyCredNegOrg)){
                    mapCaseRoutingRule.put(ruleKeyCredNegOrg, new List<CaseRoutingRule__c>());
                    system.debug('::: cRR ruleKeyCredNegOrg: ' + ruleKeyCredNegOrg + ' :: ' + 'CaseRoutingRule__c: ' + rule.Id + ' :: ' + rule.Name + ' -- CaseRecordType__c=' + rule.CaseRecordType__c);
                }
                mapCaseRoutingRule.get(ruleKeyCredNegOrg).add(rule);
                //system.debug(':::: mapCaseRoutingRule.get(ruleKeyOrg): ' + mapCaseRoutingRule.get(ruleKeyOrg));

              /* Commented out for future use, in case there are org-specific routing requirements at a later date.
              if(rule.Organization__c == 'Asia Pacific'){
                  // APAC-specific logic here
              }
              else if(rule.Organization__c == 'North America'){
                  // NA-specific logic here
              }
              else if(rule.Organization__c == 'Europe'){
                  // EU-specific logic here
              }*/
            }


            //TKOM S-445214: new product implementation routing logic
            else if(rule.CaseRecordType__c == 'Product Implementation'){

              // Create different rule keys for different routing scenarios:
              string ruleKeyOrg = 'Product Implementation' + '|Org=' + rule.Organization__c;
              string ruleKeyMediaProduct = 'Product Implementation' + '|Media Product=' + rule.Media_Product__c;
              string ruleKeyAgency = 'Product Implementation' + '|Agency=' + rule.Agency_Account__c;
              string ruleKeyNAProductFamily = 'Product Implementation' + '|Org=' + rule.Organization__c + '|ProdFam=' + rule.Product_Family__c + '|SvcTier='  + rule.Service_Tier__c;// + rule.Case_Subject__c;
              string ruleKeyNAProductName = 'Product Implementation' + '|Org=' + rule.Organization__c + '|ProdName=' + rule.Product_Name__r.Name + '|SvcTier='  + rule.Service_Tier__c;// + rule.Case_Subject__c;
              string ruleKeyNAServiceTier = 'Product Implementation' + '|Org=' + rule.Organization__c + '|SvcTier='  + rule.Service_Tier__c;// + rule.Case_Subject__c;
              string ruleKeyEUProductFamily = 'Product Implementation' + '|Org=' + rule.Organization__c + '|ProdFam=' + rule.Product_Family__c + '|SvcTier='  + rule.Service_Tier__c;// + rule.Case_Subject__c;
              string ruleKeyEUProductName = 'Product Implementation' + '|Org=' + rule.Organization__c + '|ProdName=' + rule.Product_Name__r.Name + '|SvcTier='  + rule.Service_Tier__c;// + rule.Case_Subject__c;
              string ruleKeyEUProductFamilyCountryLang = 'Product Implementation' + '|Org=' + rule.Organization__c + '|ProdFam=' + rule.Product_Family__c + '|SvcTier='  + rule.Service_Tier__c + '|PostingCountry='  + rule.Posting_Country__c + '|QuoteLang='  + rule.Proposal_Language__c;// + rule.Case_Subject__c;
              string ruleKeyEUProductNameCountryLang = 'Product Implementation' + '|Org=' + rule.Organization__c + '|ProdName=' + rule.Product_Name__r.Name + '|SvcTier='  + rule.Service_Tier__c + '|PostingCountry='  + rule.Posting_Country__c + '|QuoteLang='  + rule.Proposal_Language__c;// + rule.Case_Subject__c;
              string ruleKeyEUServiceTierCountryLang = 'Product Implementation' + '|Org=' + rule.Organization__c + '|SvcTier='  + rule.Service_Tier__c + '|PostingCountry='  + rule.Posting_Country__c + '|QuoteLang='  + rule.Proposal_Language__c;// + rule.Case_Subject__c;
              string ruleKeyEUServiceTier = 'Product Implementation' + '|Org=' + rule.Organization__c + '|SvcTier='  + rule.Service_Tier__c;// + rule.Case_Subject__c;
              // TKOM added below rulekeys for S-475343
              string ruleKeyEUProductFamilyCountry = 'Product Implementation' + '|Org=' + rule.Organization__c + '|ProdFam=' + rule.Product_Family__c + '|SvcTier='  + rule.Service_Tier__c + '|PostingCountry='  + rule.Posting_Country__c;// + rule.Case_Subject__c;
              string ruleKeyEUProductNameCountry = 'Product Implementation' + '|Org=' + rule.Organization__c + '|ProdName=' + rule.Product_Name__r.Name + '|SvcTier='  + rule.Service_Tier__c + '|PostingCountry='  + rule.Posting_Country__c;// + rule.Case_Subject__c;
              string ruleKeyEUServiceTierCountry = 'Product Implementation' + '|Org=' + rule.Organization__c + '|SvcTier='  + rule.Service_Tier__c + '|PostingCountry='  + rule.Posting_Country__c;// + rule.Case_Subject__c;



              // First check ORG, for APAC this is the only matching criteria
              if(rule.Organization__c == 'Asia Pacific'){
                if(!mapCaseRoutingRule.containsKey(ruleKeyOrg)){
                    mapCaseRoutingRule.put(ruleKeyOrg, new List<CaseRoutingRule__c>());
                    system.debug('::: cRR ruleKeyOrg: ' + ruleKeyOrg + ' :: ' + 'CaseRoutingRule__c: ' + rule.Id + ' :: ' + rule.Name + ' -- CaseRecordType__c=' + rule.CaseRecordType__c);
                }
                mapCaseRoutingRule.get(ruleKeyOrg).add(rule);
                //system.debug(':::: mapCaseRoutingRule.get(ruleKeyOrg): ' + mapCaseRoutingRule.get(ruleKeyOrg));
              }
              // For NA, we route in the following order:
              // 1 - Media Product Flag - if NOT a media product, then:
              // 2 - Product Family, Service Tier, Subject - if NO single matching rule, then:
              // 3 - Product Name, Service Tier, Subject - if NO single matching rule, then:
              // 4 - Service Tier, Subject - if NO single matching rule, then:
              // 5 - Catchall
              else if(rule.Organization__c == 'North America'){
                if(rule.Media_Product__c == true) {
                  if(!mapCaseRoutingRule.containsKey(ruleKeyMediaProduct)){
                      mapCaseRoutingRule.put(ruleKeyMediaProduct, new List<CaseRoutingRule__c>());
                      system.debug('::: cRR ruleKeyMediaProduct: ' + ruleKeyMediaProduct + ' :: ' + 'CaseRoutingRule__c: ' + rule.Id + ' :: ' + rule.Name + ' -- CaseRecordType__c=' + rule.CaseRecordType__c);
                  }
                  mapCaseRoutingRule.get(ruleKeyMediaProduct).add(rule);
                  //system.debug(':::: mapCaseRoutingRule.get(ruleKeyMediaProduct): ' + mapCaseRoutingRule.get(ruleKeyMediaProduct));
                }

                else if(rule.Product_Family__c != null && rule.Product_Name__c == null && rule.Service_Tier__c != null){//} && rule.Case_Subject__c != null){
                  if(!mapCaseRoutingRule.containsKey(ruleKeyNAProductFamily)){
                    mapCaseRoutingRule.put(ruleKeyNAProductFamily, new List<CaseRoutingRule__c>());
                    system.debug('::: cRR ruleKeyNAProductFamily: ' + ruleKeyNAProductFamily + ' :: ' + 'CaseRoutingRule__c: ' + rule.Id + ' :: ' + rule.Name + ' -- CaseRecordType__c=' + rule.CaseRecordType__c);

                  }
                  mapCaseRoutingRule.get(ruleKeyNAProductFamily).add(rule);
                }
                else if(rule.Product_Name__c != null && rule.Service_Tier__c != null && rule.Product_Family__c == null){// && rule.Case_Subject__c != null){
                  if(!mapCaseRoutingRule.containsKey(ruleKeyNAProductName)){
                    mapCaseRoutingRule.put(ruleKeyNAProductName, new List<CaseRoutingRule__c>());
                    system.debug('::: cRR ruleKeyNAProductName: ' + ruleKeyNAProductName + ' :: ' + 'CaseRoutingRule__c: ' + rule.Id + ' :: ' + rule.Name + ' -- CaseRecordType__c=' + rule.CaseRecordType__c);

                  }
                  mapCaseRoutingRule.get(ruleKeyNAProductName).add(rule);
                }
                else if(rule.Service_Tier__c != null && rule.Product_Name__c == null && rule.Product_Family__c == null){// && rule.Case_Subject__c != null){
                  if(!mapCaseRoutingRule.containsKey(ruleKeyNAServiceTier)){
                    mapCaseRoutingRule.put(ruleKeyNAServiceTier, new List<CaseRoutingRule__c>());
                    system.debug('::: cRR ruleKeyNAServiceTier: ' + ruleKeyNAServiceTier + ' :: ' + 'CaseRoutingRule__c: ' + rule.Id + ' :: ' + rule.Name + ' -- CaseRecordType__c=' + rule.CaseRecordType__c);

                  }
                  mapCaseRoutingRule.get(ruleKeyNAServiceTier).add(rule);
                }

              }
              // For EU, we route in the following order:
              // 1 - Agency Account Name - if NO single matching rule, then:
              // 2 - Product Family, Service Tier, Account Posting Country, Proposal Language, Subject - if NO single matching rule, then:
              // 3 - Product Name, Service Tier, Account Posting Country, Proposal Language, Subject - if NO single matching rule, then:
              // 4 - Service Tier, Account Posting Country, Proposal Language, Subject - if NO single matching rule, then:
              // 5 - Catchall
              else if(rule.Organization__c == 'Europe'){

                if(rule.Agency_Account__c != null) {
                  system.debug(':::: AGENCY: ' + rule.Agency_Account__c + ' : ' + rule.Agency_Account__r.Name);
                  if(!mapCaseRoutingRule.containsKey(ruleKeyAgency)){
                      mapCaseRoutingRule.put(ruleKeyAgency, new List<CaseRoutingRule__c>());
                      system.debug('::: cRR ruleKeyAgency: ' + ruleKeyAgency + ' :: ' + 'CaseRoutingRule__c: ' + rule.Id + ' :: ' + rule.Name + ' -- CaseRecordType__c=' + rule.CaseRecordType__c);
                  }
                  mapCaseRoutingRule.get(ruleKeyAgency).add(rule);
                }

                else if(rule.Product_Family__c != null && rule.Product_Name__c == null && rule.Service_Tier__c != null && rule.Posting_Country__c != null &&  rule.Proposal_Language__c != null){// && rule.Case_Subject__c != null){
                  if(!mapCaseRoutingRule.containsKey(ruleKeyEUProductFamilyCountryLang)){
                    mapCaseRoutingRule.put(ruleKeyEUProductFamilyCountryLang, new List<CaseRoutingRule__c>());
                    system.debug('::: cRR ruleKeyEUProductFamilyCountryLang: ' + ruleKeyEUProductFamilyCountryLang + ' :: ' + 'CaseRoutingRule__c: ' + rule.Id + ' :: ' + rule.Name + ' -- CaseRecordType__c=' + rule.CaseRecordType__c);

                  }
                  mapCaseRoutingRule.get(ruleKeyEUProductFamilyCountryLang).add(rule);
                }

                // TKOM added for S-475343
                else if(rule.Product_Family__c != null && rule.Product_Name__c == null && rule.Service_Tier__c != null && rule.Posting_Country__c != null){// && rule.Case_Subject__c != null){
                  if(!mapCaseRoutingRule.containsKey(ruleKeyEUProductFamilyCountry)){
                    mapCaseRoutingRule.put(ruleKeyEUProductFamilyCountry, new List<CaseRoutingRule__c>());
                    system.debug('::: cRR ruleKeyEUProductFamilyCountry: ' + ruleKeyEUProductFamilyCountry + ' :: ' + 'CaseRoutingRule__c: ' + rule.Id + ' :: ' + rule.Name + ' -- CaseRecordType__c=' + rule.CaseRecordType__c);

                  }
                  mapCaseRoutingRule.get(ruleKeyEUProductFamilyCountry).add(rule);
                }

                else if(rule.Product_Family__c == null && rule.Product_Name__c != null && rule.Service_Tier__c != null  && rule.Posting_Country__c != null &&  rule.Proposal_Language__c != null){// && rule.Case_Subject__c != null){
                  if(!mapCaseRoutingRule.containsKey(ruleKeyEUProductNameCountryLang)){
                    mapCaseRoutingRule.put(ruleKeyEUProductNameCountryLang, new List<CaseRoutingRule__c>());
                    system.debug('::: cRR ruleKeyEUProductNameCountryLang: ' + ruleKeyEUProductNameCountryLang + ' :: ' + 'CaseRoutingRule__c: ' + rule.Id + ' :: ' + rule.Name + ' -- CaseRecordType__c=' + rule.CaseRecordType__c);

                  }
                  mapCaseRoutingRule.get(ruleKeyEUProductNameCountryLang).add(rule);
                }

                // TKOM added for S-475343
                else if(rule.Product_Family__c == null && rule.Product_Name__c != null && rule.Service_Tier__c != null  && rule.Posting_Country__c != null ){// && rule.Case_Subject__c != null){
                  if(!mapCaseRoutingRule.containsKey(ruleKeyEUProductNameCountry)){
                    mapCaseRoutingRule.put(ruleKeyEUProductNameCountry, new List<CaseRoutingRule__c>());
                    system.debug('::: cRR ruleKeyEUProductNameCountry: ' + ruleKeyEUProductNameCountry + ' :: ' + 'CaseRoutingRule__c: ' + rule.Id + ' :: ' + rule.Name + ' -- CaseRecordType__c=' + rule.CaseRecordType__c);

                  }
                  mapCaseRoutingRule.get(ruleKeyEUProductNameCountry).add(rule);
                }
                else if(rule.Product_Family__c != null && rule.Product_Name__c == null && rule.Service_Tier__c != null){// && rule.Case_Subject__c != null){
                  if(!mapCaseRoutingRule.containsKey(ruleKeyEUProductFamily)){
                    mapCaseRoutingRule.put(ruleKeyEUProductFamily, new List<CaseRoutingRule__c>());
                    system.debug('::: cRR ruleKeyEUProductFamily: ' + ruleKeyEUProductFamily + ' :: ' + 'CaseRoutingRule__c: ' + rule.Id + ' :: ' + rule.Name + ' -- CaseRecordType__c=' + rule.CaseRecordType__c);

                  }
                  mapCaseRoutingRule.get(ruleKeyEUProductFamily).add(rule);
                }
                else if(rule.Product_Family__c == null && rule.Product_Name__c != null && rule.Service_Tier__c != null){// && rule.Case_Subject__c != null){
                  if(!mapCaseRoutingRule.containsKey(ruleKeyEUProductName)){
                    mapCaseRoutingRule.put(ruleKeyEUProductName, new List<CaseRoutingRule__c>());
                    system.debug('::: cRR ruleKeyEUProductName: ' + ruleKeyEUProductName + ' :: ' + 'CaseRoutingRule__c: ' + rule.Id + ' :: ' + rule.Name + ' -- CaseRecordType__c=' + rule.CaseRecordType__c);

                  }
                  mapCaseRoutingRule.get(ruleKeyEUProductName).add(rule);
                }
                else if(rule.Product_Family__c == null && rule.Product_Name__c == null && rule.Service_Tier__c != null  && rule.Posting_Country__c != null &&  rule.Proposal_Language__c != null){// && rule.Case_Subject__c != null){
                  if(!mapCaseRoutingRule.containsKey(ruleKeyEUServiceTierCountryLang)){
                    mapCaseRoutingRule.put(ruleKeyEUServiceTierCountryLang, new List<CaseRoutingRule__c>());
                    system.debug('::: cRR ruleKeyEUServiceTierCountryLang: ' + ruleKeyEUServiceTierCountryLang + ' :: ' + 'CaseRoutingRule__c: ' + rule.Id + ' :: ' + rule.Name + ' -- CaseRecordType__c=' + rule.CaseRecordType__c);
                  }
                  mapCaseRoutingRule.get(ruleKeyEUServiceTierCountryLang).add(rule);
                }

                // TKOM added for S-475343
                else if(rule.Product_Family__c == null && rule.Product_Name__c == null && rule.Service_Tier__c != null  && rule.Posting_Country__c != null){// && rule.Case_Subject__c != null){
                  if(!mapCaseRoutingRule.containsKey(ruleKeyEUServiceTierCountry)){
                    mapCaseRoutingRule.put(ruleKeyEUServiceTierCountry, new List<CaseRoutingRule__c>());
                    system.debug('::: cRR ruleKeyEUServiceTierCountry: ' + ruleKeyEUServiceTierCountry + ' :: ' + 'CaseRoutingRule__c: ' + rule.Id + ' :: ' + rule.Name + ' -- CaseRecordType__c=' + rule.CaseRecordType__c);
                  }
                  mapCaseRoutingRule.get(ruleKeyEUServiceTierCountry).add(rule);
                }

                else if(rule.Product_Family__c == null && rule.Product_Name__c == null && rule.Service_Tier__c != null){// && rule.Case_Subject__c != null){
                  if(!mapCaseRoutingRule.containsKey(ruleKeyEUServiceTier)){
                    mapCaseRoutingRule.put(ruleKeyEUServiceTier, new List<CaseRoutingRule__c>());
                    system.debug('::: cRR ruleKeyEUServiceTier: ' + ruleKeyEUServiceTier + ' :: ' + 'CaseRoutingRule__c: ' + rule.Id + ' :: ' + rule.Name + ' -- CaseRecordType__c=' + rule.CaseRecordType__c);
                  }
                  mapCaseRoutingRule.get(ruleKeyEUServiceTier).add(rule);
                }

              }
          }
          //  END of new Product Implementation Routing logic


            else if(DCRTNames.contains(rule.CaseRecordType__c)){

                string rulekey = rule.CaseRecordType__c + '|' + rule.Current_User_Country__c;
                if(!mapCaseRoutingRule.containsKey(ruleKey)){
                    mapCaseRoutingRule.put(ruleKey,new List<CaseRoutingRule__c>());

                }
                mapCaseRoutingRule.get(ruleKey).add(rule);
            }
            else if(rule.CaseRecordType__c == 'Credit Request'){

                if(!mapCaseRoutingRule.containsKey('Credit Request')){
                        mapCaseRoutingRule.put('Credit Request',new List<CaseRoutingRule__c>());

                    }
                mapCaseRoutingRule.get('Credit Request').add(rule);
            }

         }

        catchAllRule = getCatchAllRule();
        List<Case> euMediaCoreCases = new List<Case>();
        for(Case c : newCases){
            system.debug('Case ' + c.Id + ' Recordtype=' + c.recordTypeId + ' SystemGenerated__c=' + c.SystemGenerated__c + ' and Creates Unrouted Cases=' + PermissionCheck.hasPermission('Creates_unrouted_cases'));

            //if we are a cloned email to case, we are already assigned
            //and we do not need to be routed again (this will route to the
            //wrong queue)
            if(c.Cloned_Email_To_Case__c){
                continue;
            }

            //J Freese Appirio I-218370 5/15/16 Disable routing only if not system generated and has Creates_unrouted_cases permission
            if(c.SystemGenerated__c == False && PermissionCheck.hasPermission('Creates_unrouted_cases')){
                System.debug('NOT routing Case ' + c.Id + ' as SystemGenerated__c=' + c.SystemGenerated__c + ' and Creates Unrouted Cases' + PermissionCheck.hasPermission('Creates_unrouted_cases'));
            }
            else {
            //if(c.SystemGenerated__c == True){
            //boolean that will determine if we need to use the catch all rule
            //if no other rule is found
            boolean ruleAssigned = false;
            CaseRoutingRule__c  cRR;
            //First lets do the logic for the creditRequest record Type
            system.debug('Routing Case: ' + c);
            if(c.RecordTypeId == creditLimitRecordTypeId && mapCaseRoutingRule.containsKey('Request re Credit Limit')){
                system.debug('xxx runnnnn 1 ');
                cRR = mapCaseRoutingRule.get('Request re Credit Limit')[0];
                System.debug('??????????++++++++++' + crr ); //right now we are only using the first one that comes back, but this logic could change in the future
                c = CaseTriggerHelper.populateCaseRoutingRuleInfo(c,cRR);
                ruleAssigned = true;
            }
            /*else if(c.RecordTypeId == newRequestRecordTypeId && mapCaseRoutingRule.containsKey('Data Governance')){
                cRR = mapCaseRoutingRule.get('Data Governance')[0];
                System.debug('??????????++++++++++' + crr ); //right now we are only using the first one that comes back, but this logic could change in the future
                c = CaseTriggerHelper.populateCaseRoutingRuleInfo(c,cRR);
                ruleAssigned = true;
            }*/
            else if(c.RecordTypeId == creditRequestRecordTypeId && mapCaseRoutingRule.containsKey('Credit Request')){
                system.debug('xxx runnnnn 2 ');
                for(CaseRoutingRule__c routingRule : mapCaseRoutingRule.get('Credit Request')){
                    if(routingRule.Organization__c == c.Organization__c){
                        cRR = routingRule;
                        c = CaseTriggerHelper.populateCaseRoutingRuleInfo(c,cRR);
                        ruleAssigned = true;
                        break;
                    }
                }
            }
            //This is all the logic needed for the omProcessingRequest Record Type
            //Jeff L. added more logic because we have to route differently based upon the recordType of the Quote/PRoposal, rebills go one way, Proposals go another
            else if(c.RecordTypeId == omProcessingReuestRecordtypeid){
                system.debug('xxx runnnnn 3 ');
                if(c.Proposal_ID__c != null && mapCaseRelatedQuotes.get(c.Proposal_Id__c) != null){
                    if(mapCountryAndRecordTypeToCaseRoutingRules.containsKey(c.Quote_SellingCountry__c + mapCaseRelatedQuotes.get(c.Proposal_Id__c).RecordType.Name)){
                        cRR = (mapCountryAndRecordTypeToCaseRoutingRules.get(c.Quote_SellingCountry__c + mapCaseRelatedQuotes.get(c.Proposal_Id__c).RecordType.Name));
                    } else {
                        if(omProcessingRuleException != null && mapCaseRelatedQuotes.get(c.Proposal_Id__c).RecordType.Name == 'Proposal Locked'){
                            cRR = omProcessingRuleException;
                        }
                        else if (omProcessingRuleRebillException != null && mapCaseRelatedQuotes.get(c.Proposal_Id__c).RecordType.Name == 'Rebill Proposal'){
                            cRR = omProcessingRuleRebillException;
                        }
                    }
                //system.assert(false , cRR );
                }
                //else {
                //    if(omProcessingRuleException != null && mapCaseRelatedQuotes.get(c.Proposal_Id__c).RecordType.Name == 'Proposal Locked'){
                //        cRR = omProcessingRuleException;
                //    }
                //    else if (omProcessingRuleRebillException != null && mapCaseRelatedQuotes.get(c.Proposal_Id__c).RecordType.Name == 'Rebill Proposal'){
                //        cRR = omProcessingRuleRebillException;
                //    }
                //}


                System.debug('==CRR==='+cRR) ;

                if(cRR != null){
                    c = CaseTriggerHelper.populateCaseRoutingRuleInfo(c,cRR);
                    ruleAssigned = true;
                }

                if(c.Proposal_ID__c != null){
                    // replaced Quote_Total__c with Net_Total__c due to I-191155
                    if(mapCaseRelatedQuotes.get(c.Proposal_ID__c).CurrencyRef__c =='USD' && mapCaseRelatedQuotes.get(c.Proposal_ID__c).Net_Total__c > 50000){
                       c.Priority = 'High';

                       }else{
                        CurrencyUtil convert = new CurrencyUtil ();
                        // replaced Quote_Total__c with Net_Total__c due to I-191155
                        Decimal quoteAmount = convert.convertToUSD(mapCaseRelatedQuotes.get(c.Proposal_ID__c).CurrencyRef__c , mapCaseRelatedQuotes.get(c.Proposal_ID__c).Net_Total__c);
                        if(quoteAmount > 50000)
                        c.Priority = 'High';
                    }
                }

                Map<string,ISO_Countries__c> mapCountryCodes = ISO_Countries__c.getAll();
                Map<string,ISO_Languages__c> mapLanguageCodes = ISO_Languages__c.getAll();

                //For this next section we need to replace certain parts of the string in BusinessProcess__c with
                //language code and Country Code and Order Type
                String countryCode;
                String languageCode;
                String orderType;

                if(mapCountryCodes .containskey(c.Quote_SellingCountry__c))
                countryCode = mapCountryCodes .get(c.Quote_SellingCountry__c).ISO_Code__c;
                else
                countryCode  = '';

                if(c.Proposal_ID__c != null && mapCaseRelatedQuotes.get(c.Proposal_ID__c)!= null && mapLanguageCodes .containskey(mapCaseRelatedQuotes.get(c.Proposal_ID__c).Language__c))
                languageCode= mapLanguageCodes .get(mapCaseRelatedQuotes.get(c.Proposal_ID__c).Language__c ).ISO_Code__c;
                else
                languageCode= '';

                if(c.Proposal_ID__c != null && mapCaseRelatedQuotes.get(c.Proposal_ID__c)!= null )
                    orderType = mapCaseRelatedQuotes.get(c.Proposal_ID__c).Order_Type__c;
                else
                    orderType = '';
                if(orderType == null)
                {
                    orderType ='';
                }

                if(cRR != null && cRR.BusinessProcess__c != null){
                    System.debug('cRR.BusinessProcess__c'+cRR.BusinessProcess__c);
                    System.debug('cRR'+cRR);
                    System.debug('countryCode'+countryCode);
                    System.debug('languageCode'+languageCode);
                     System.debug('orderType'+orderType);

                    c.BusinessProcess__c = cRR.BusinessProcess__c.replace('[CountryCode]' , countryCode  ).replace('[LanguageCode]', languageCode).replace('[OrderType]', orderType);
                }

                 System.debug('===Case==='+c);
            }
            else if(c.RecordTypeId == gcsRecordTypeID){
                system.debug('xxx runnnnn 4 ');
                //Jeff L. Added rules for GCS case record type for Inventory Adjustment
                //For these cases no rules are assigned - the creator of the Case is the owner
                //they get routed using an approval process instead
                if(c.Issue__c == 'InventoryAdjustment/Allocation'){
                    c.Approval_Status__c = 'Not Submitted';
                    ruleAssigned = true;
                }
                else if(mapCaseRoutingRule.containsKey('GCS'+c.ContactSource__c+c.Language__c+c.BillingCountry__c+c.Subject)){
                    //Web to Case routing
                    cRR = mapCaseRoutingRule.get('GCS'+c.ContactSource__c+c.Language__c+c.BillingCountry__c+c.Subject)[0];
                    c = CaseTriggerHelper.populateCaseRoutingRuleInfo(c,cRR);
                    ruleAssigned = true;
                }
                else if(mapCaseRoutingRule.containsKey('GCS'+c.ContactSource__c+c.Language__c+c.BillingCountry__c+c.Subject)){
                    // Normal GCS Routing
                    cRR = mapCaseRoutingRule.get('GCS'+c.ContactSource__c+c.Language__c+c.BillingCountry__c+c.Subject)[0];
                    c = CaseTriggerHelper.populateCaseRoutingRuleInfo(c,cRR);
                    ruleAssigned = true;
                }
                else if(mapCaseRoutingRule.containsKey('GCS'+c.ContactSource__c+c.Language__c+c.BillingCountry__c+c.Request_Type__c)){
                    //TK 9/5/16 S-440359: added Case_Request_Type__c for Internal Sales to GCS Case routing with Request Type
                    cRR = mapCaseRoutingRule.get('GCS'+c.ContactSource__c+c.Language__c+c.BillingCountry__c+c.Request_Type__c)[0];
                    c = CaseTriggerHelper.populateCaseRoutingRuleInfo(c,cRR);
                    ruleAssigned = true;
                }
                else if(mapCaseRoutingRule.containsKey('GCS'+c.ContactSource__c+c.Language__c+c.BillingCountry__c+'CatchAll')){
                    //Catch all rule for GCS EKB queue
                    cRR = mapCaseRoutingRule.get('GCS'+c.ContactSource__c+c.Language__c+c.BillingCountry__c+'CatchAll')[0];
                    c = CaseTriggerHelper.populateCaseRoutingRuleInfo(c,cRR);
                    ruleAssigned = true;
                }
            }
            /*else if(c.RecordTypeId == parentRecordTypeId && mapCaseRoutingRule.containsKey('Parent/Child Inventory Sharing|'+currentuser.Country)){
                cRR = mapCaseRoutingRule.get('Parent/Child Inventory Sharing|'+currentuser.Country)[0];
                c = CaseTriggerHelper.populateCaseRoutingRuleInfo(c,cRR);
                ruleAssigned = true;
            }
            else if(c.RecordTypeId == registrationRecordTypeID && mapCaseRoutingRule.containsKey('Registration/VATFiscal Code|'+currentuser.Country)){
                cRR = mapCaseRoutingRule.get('Registration/VATFiscal Code|'+currentuser.Country)[0];
                c = CaseTriggerHelper.populateCaseRoutingRuleInfo(c,cRR);
                ruleAssigned = true;
            }*/
            else if(mapDCRTs.containsKey(c.RecordTypeId)){
                system.debug('xxx runnnnn 5 ');
                RecordType RecordType = mapDCRTs.get(c.RecordTypeId);
                if(mapCaseRoutingRule.containsKey(RecordType.Name + '|' + currentuser.Location__c)){
                    cRR = mapCaseRoutingRule.get(RecordType.Name + '|' + currentuser.Location__c)[0];
                    c = CaseTriggerHelper.populateCaseRoutingRuleInfo(c,cRR);
                    ruleAssigned = true;
                }
            }

            /*
            // OLD Product Implementation Routing - pre- S-445214
            else if (c.RecordTypeId == productImplementationRecordTypeID || c.RecordTypeId == creditNegateRecordTypeID){
                system.debug('xxx runnnnn 6 ');
                string ruleKey = 'Product Implementation ' + c.AccountServiceTier__c + c.Account_Organization__c ;
                system.debug('RuleKey ' +ruleKey);
                //Order of operations for production implementation routing::
                //1. If this is a media product then we assign to one specific queue
                //2. Check to see if the related Account has a primary service rep - if so assign it
                //3. Different Service Tiers (field on account) have different requirements
                //    a. Use the routing rules objects to route based mainly upon Service Tier
                //

                //first check if its a media product, we have special rules for the media products
                if(c.isMediaProduct__c){
                    system.debug('is a media product?!');
                    if(c.Account_Organization__c == 'North America'){
                        if(User_Queue_IDs__c.getInstance().ADOPS_Queue__c != null) {
                            c.OwnerId = User_Queue_IDs__c.getInstance().ADOPS_Queue__c;
                            ruleAssigned = true;
                        }
                    } else {
                        //Do not reassign owner here; call to updateCaseOwnerWithOrderSentToVerificationBy() below will
                        //update owner for EU Media or Core
                            euMediaCoreCases.add(c);
                            ruleAssigned = true;
                        }
                } else {
                    system.debug('not a Media product! ');
                    //its not a media product, so lets check if it has a
                    //primary service rep and assign if so
                    if(c.AccountId!= null && mapAccounts.containskey(c.AccountId)){
                        Account caseAccount = mapAccounts.get(c.AccountId);

                        if(mapAccounts.get(c.AccountId).PrimaryServiceRep__c != null && mapAccounts.get(c.AccountId).PrimaryServiceRep__c != null){
                            c.OwnerId = mapAccounts.get(c.AccountId).PrimaryServiceRep__c;
                            system.debug('^^^ Setting case owner to PrimaryServiceRep ' + c.OwnerId);
                            ruleAssigned = true;
                        }
                         //next up lets find the routing rule based upon service tier
                         else if(mapCaseRoutingRule.containsKey(ruleKey)){
                            system.debug('Map contained the Key! ');
                            system.debug('rulekey: '+rulekey);
                            //if north america then we just assign based on rule,
                            //EU is trickier and has differe queues based upon country
                            if(c.Account_Organization__c == 'North America'){
                                cRR = mapCaseRoutingRule.get(rulekey)[0];
                                c = CaseTriggerHelper.populateCaseRoutingRuleInfo(c,cRR);
                                ruleAssigned = true;
                                system.debug('cRR:: '+cRR);
                            } else {
                                //this is the EU case, we need to see if multiple rules exist or not
                                system.debug('Inside EU case routing rule ' + ruleKey + ', ' + mapCaseRoutingRule.get(ruleKey).size() + ' Routing Rule(s) ' + mapCaseRoutingRule.get(ruleKey));

                                if(mapCaseRoutingRule.get(ruleKey).size() == 1){
                                    //since there is only one, this is easy and we assign just one
                                    cRR =  mapCaseRoutingRule.get(rulekey)[0];
                                    system.debug('EU routing rule: ' + cRR);
                                    c = CaseTriggerHelper.populateCaseRoutingRuleProduct(c,cRR, mapOrders.get(c.Order__c));
                                    ruleAssigned = true;
                                } else {
                                    //this means we have more than 1 rule in our list for EU - lets use the country map
                                    //to get the right one
                                    string euRuleKey = c.AccountServiceTier__c + c.AccountBillingCountry__c;
                                    if(mapServiceTierAndCountryToCaseRoutingRule.containsKey(euRuleKey)){
                                        cRR = mapServiceTierAndCountryToCaseRoutingRule.get(euRuleKey);
                                        system.debug('EU routing rule based on AccountBillingCountry: ' + cRR);
                                        c = CaseTriggerHelper.populateCaseRoutingRuleProduct(c,cRR, mapOrders.get(c.Order__c));
                                        ruleAssigned = true;
                                    }
                                }
                            }
                        }
                    }
                }
                system.debug('xxx runnnnn 7 ');
            }  //  END of OLD product implementation routing
            */

            // TKOM S-481927: NEW Credit/Negate Routing: route only by Organization
            else if (c.RecordTypeId == creditNegateRecordTypeID){
                system.debug('xxx Credit/Negate ');
                // Create different rule keys based on case details to try and match a ruleKey from the routing rules:
                string ruleKeyCredNegOrg = 'CreditNegate' + '|Org=' + c.Account_Organization__c;
                system.debug('::: case ruleKeyCredNegOrg: ' + ruleKeyCredNegOrg);

                if(!ruleAssigned && mapCaseRoutingRule.containsKey(ruleKeyCredNegOrg)){
                    system.debug(':::: Matched ruleKeyCredNegOrg');
                    system.debug(':::: mapCaseRoutingRule.get(ruleKeyCredNegOrg).size(): ' + mapCaseRoutingRule.get(ruleKeyCredNegOrg).size());
                    if( mapCaseRoutingRule.get(ruleKeyCredNegOrg).size() == 1){
                      system.debug(':::: found EXACT MATCH - assign cRR and update Case');
                      cRR = mapCaseRoutingRule.get(ruleKeyCredNegOrg)[0];
                      c = CaseTriggerHelper.populateCaseRoutingRuleInfo(c,cRR);
                      ruleAssigned = true;
                      system.debug('cRR:: '+cRR);
                    }
                } // END Org matching
                else system.debug(':::: Did not match ruleKeyCredNegOrg -- SKIPPING');
            }


            // TKOM S-445214: NEW Product Implementation Routing
            else if (c.RecordTypeId == productImplementationRecordTypeID){
                system.debug('xxx runnnnn 6 ');
                // Create different rule keys based on case details to try and match a ruleKey from the routing rules:
                string ruleKeyOrg = 'Product Implementation' + '|Org=' + c.Account_Organization__c;
                string ruleKeyMediaProduct = 'Product Implementation' + '|Media Product=' + c.IsMediaProduct__c;
                string ruleKeyAgency = 'Product Implementation' + '|Agency=' + c.AgencyLookup__c;
                string ruleKeyNAProductFamily = 'Product Implementation' + '|Org=' + c.Account_Organization__c + '|ProdFam=' +c.ProductFamilyFormula__c + '|SvcTier='  + c.AccountServiceTier__c;// + c.Subject;
                string ruleKeyNAProductName = 'Product Implementation' + '|Org=' + c.Account_Organization__c + '|ProdName=' + c.ProductNameFormula__c + '|SvcTier='  + c.AccountServiceTier__c;// + c.Subject;
                string ruleKeyNAServiceTier = 'Product Implementation' + '|Org=' + c.Account_Organization__c + '|SvcTier='  + c.AccountServiceTier__c;// + c.Subject;
                string ruleKeyEUProductFamilyCountryLang = 'Product Implementation' + '|Org=' + c.Account_Organization__c + '|ProdFam=' + c.ProductFamilyFormula__c + '|SvcTier='  + c.AccountServiceTier__c + '|PostingCountry='  + c.AccountPostingCountry__c + '|QuoteLang='  + c.Language__c;// + c.Subject;
                string ruleKeyEUProductNameCountryLang = 'Product Implementation' + '|Org=' + c.Account_Organization__c + '|ProdName=' + c.ProductNameFormula__c + '|SvcTier='  + c.AccountServiceTier__c + '|PostingCountry='  + c.AccountPostingCountry__c + '|QuoteLang='  + c.Language__c;// + c.Subject;
                string ruleKeyEUProductFamily = 'Product Implementation' + '|Org=' + c.Account_Organization__c + '|ProdFam=' + c.ProductFamilyFormula__c + '|SvcTier='  + c.AccountServiceTier__c;// + c.Subject;
                string ruleKeyEUProductName = 'Product Implementation' + '|Org=' + c.Account_Organization__c + '|ProdName=' + c.ProductNameFormula__c + '|SvcTier='  + c.AccountServiceTier__c;// + c.Subject;
                string ruleKeyEUServiceTierCountryLang = 'Product Implementation' + '|Org=' + c.Account_Organization__c + '|SvcTier='  + c.AccountServiceTier__c + '|PostingCountry='  + c.AccountPostingCountry__c + '|QuoteLang='  + c.Language__c;// + c.Subject;
                string ruleKeyEUServiceTier = 'Product Implementation' + '|Org=' + c.Account_Organization__c + '|SvcTier='  + c.AccountServiceTier__c;// + c.Subject;

                // TKOM added below rulekeys for S-475343
                string ruleKeyEUProductFamilyCountry = 'Product Implementation' + '|Org=' + c.Account_Organization__c + '|ProdFam=' + c.ProductFamilyFormula__c + '|SvcTier='  + c.AccountServiceTier__c + '|PostingCountry='  + c.AccountPostingCountry__c;// + c.Subject;
                string ruleKeyEUProductNameCountry = 'Product Implementation' + '|Org=' + c.Account_Organization__c + '|ProdName=' + c.ProductNameFormula__c + '|SvcTier='  + c.AccountServiceTier__c + '|PostingCountry='  + c.AccountPostingCountry__c;// + c.Subject;
                string ruleKeyEUServiceTierCountry = 'Product Implementation' + '|Org=' + c.Account_Organization__c + '|SvcTier='  + c.AccountServiceTier__c + '|PostingCountry='  + c.AccountPostingCountry__c;// + c.Subject;


                system.debug('::: case ruleKeyOrg: ' + ruleKeyOrg);
                system.debug('::: case ruleKeyMediaProduct: ' + ruleKeyMediaProduct);
                system.debug('::: case ruleKeyAgency: ' + ruleKeyAgency);
                system.debug('::: case ruleKeyNAProductFamily: ' + ruleKeyNAProductFamily);
                system.debug('::: case ruleKeyNAProductName: ' + ruleKeyNAProductName);
                system.debug('::: case ruleKeyNAServiceTier: ' + ruleKeyNAServiceTier);
                system.debug('::: case ruleKeyEUProductFamily: ' + ruleKeyEUProductFamily);
                system.debug('::: case ruleKeyEUProductName: ' + ruleKeyEUProductName);
                system.debug('::: case ruleKeyEUProductFamilyCountryLang: ' + ruleKeyEUProductFamilyCountryLang);
                system.debug('::: case ruleKeyEUProductNameCountryLang: ' + ruleKeyEUProductNameCountryLang);
                system.debug('::: case ruleKeyEUServiceTierCountryLang: ' + ruleKeyEUServiceTierCountryLang);
                system.debug('::: case ruleKeyEUProductFamilyCountry: ' + ruleKeyEUProductFamilyCountry);
                system.debug('::: case ruleKeyEUProductNameCountry: ' + ruleKeyEUProductNameCountry);
                system.debug('::: case ruleKeyEUServiceTierCountry: ' + ruleKeyEUServiceTierCountry);
                system.debug('::: case ruleKeyEUServiceTier: ' + ruleKeyEUServiceTier);

                //Boolean subjectContainsMatch=c.Subject.contains(rule.Case_Subject__c);

                //Order of operations for production implementation routing:
                // For APAC:
                // Check ORG, for APAC this is the only matching criteria
                //
                // For NA, we route in the following order:
                // 1 - Media Product Flag - if NOT a media product, then:
                // 2 - Product Family, Service Tier, Subject - if NO single matching rule, then:
                // 3 - Product Name, Service Tier, Subject - if NO single matching rule, then:
                // 4 - Service Tier, Subject - if NO single matching rule, then:
                // 5 - Catchall
                //
                // For EU, we route in the following order:
                // 1 - Agency Account Name - if NO single matching rule, then:
                // 2 - Product Family, Service Tier, Account Posting Country, Proposal Language, Subject - if NO single matching rule, then:
                // 3 - Product Name, Service Tier, Account Posting Country, Proposal Language, Subject - if NO single matching rule, then:
                // 4 - Service Tier, Account Posting Country, Proposal Language, Subject - if NO single matching rule, then:
                // 5 - Catchall

                // first, route for APAC
                if(c.Account_Organization__c == 'Asia Pacific'){
                  system.debug('Org = APAC');

                  if(!ruleAssigned && mapCaseRoutingRule.containsKey(ruleKeyOrg)){
                      system.debug(':::: Matched ruleKeyOrg');
                      system.debug(':::: mapCaseRoutingRule.get(ruleKeyOrg).size(): ' + mapCaseRoutingRule.get(ruleKeyOrg).size());
                      if( mapCaseRoutingRule.get(ruleKeyOrg).size() == 1){
                        system.debug(':::: found EXACT MATCH - assign cRR and update Case');
                        cRR = mapCaseRoutingRule.get(ruleKeyOrg)[0];
                        c = CaseTriggerHelper.populateCaseRoutingRuleInfo(c,cRR);
                        ruleAssigned = true;
                        system.debug('cRR:: '+cRR);
                      }
                  } // END Org matching
                  else system.debug(':::: Did not match ruleKeyOrg -- SKIPPING');
                } // END APAC

                // next, route for NA
                else if(c.Account_Organization__c == 'North America'){
                  system.debug('Org = NA');

                  if(!ruleAssigned && c.isMediaProduct__c && mapCaseRoutingRule.containsKey(ruleKeyMediaProduct)){
                    system.debug('is Media Product!');
                    system.debug(':::: Matched ruleKeyMediaProduct');
                    system.debug(':::: mapCaseRoutingRule.get(ruleKeyMediaProduct).size(): ' + mapCaseRoutingRule.get(ruleKeyMediaProduct).size());
                    if(mapCaseRoutingRule.get(ruleKeyMediaProduct).size() == 1){
                      system.debug(':::: found EXACT MATCH - assign cRR and update Case');
                      cRR = mapCaseRoutingRule.get(ruleKeyMediaProduct)[0];
                      c = CaseTriggerHelper.populateCaseRoutingRuleInfo(c,cRR);
                      ruleAssigned = true;
                      system.debug('cRR:: '+cRR);
                    }
                    else system.debug(':::: Did not match exactly one ruleKeyMediaProduct -- SKIPPING');
                  } // END MediaProduct matching

                  if (!ruleAssigned && mapCaseRoutingRule.containsKey(ruleKeyNAProductFamily)){
                    system.debug(':::: Matched ruleKeyNAProductFamily');
                    system.debug(':::: mapCaseRoutingRule.get(ruleKeyNAProductFamily).size(): ' + mapCaseRoutingRule.get(ruleKeyNAProductFamily).size());
                    if(mapCaseRoutingRule.get(ruleKeyNAProductFamily).size() == 1){
                      system.debug(':::: found EXACT MATCH - assign cRR and update Case');
                      cRR = mapCaseRoutingRule.get(ruleKeyNAProductFamily)[0];
                      c = CaseTriggerHelper.populateCaseRoutingRuleInfo(c,cRR);
                      ruleAssigned = true;
                      system.debug('cRR:: '+cRR);
                    }
                    else system.debug(':::: Did not match exactly one ruleKeyNAProductFamily -- SKIPPING');
                  } // END NAProductFamily matching

                  if (!ruleAssigned && mapCaseRoutingRule.containsKey(ruleKeyNAProductName)){
                    system.debug(':::: Matched ruleKeyNAProductName');
                    system.debug(':::: mapCaseRoutingRule.get(ruleKeyNAProductName).size(): ' + mapCaseRoutingRule.get(ruleKeyNAProductName).size());
                    if(mapCaseRoutingRule.get(ruleKeyNAProductName).size() == 1){
                      system.debug(':::: found EXACT MATCH - assign cRR and update Case');
                      cRR = mapCaseRoutingRule.get(ruleKeyNAProductName)[0];
                      c = CaseTriggerHelper.populateCaseRoutingRuleInfo(c,cRR);
                      ruleAssigned = true;
                      system.debug('cRR:: '+cRR);
                    }
                    else system.debug(':::: Did not match exactly one ruleKeyNAProductName -- SKIPPING');
                  } // END NAProductName matching


                  if (!ruleAssigned && mapCaseRoutingRule.containsKey(ruleKeyNAServiceTier)){
                    system.debug(':::: Matched ruleKeyNAServiceTier');
                    system.debug(':::: mapCaseRoutingRule.get(ruleKeyNAServiceTier).size(): ' + mapCaseRoutingRule.get(ruleKeyNAServiceTier).size());
                    //list<CaseRoutingRule__c> lstPotentialMatches = new list<CaseRoutingRule__c>(); // new list to hold potential routing matches, for subject checking.

                    if( mapCaseRoutingRule.get(ruleKeyNAServiceTier).size() == 1){
                      system.debug(':::: found EXACT MATCH - assign cRR and update Case');
                      cRR = mapCaseRoutingRule.get(ruleKeyNAServiceTier)[0];
                      c = CaseTriggerHelper.populateCaseRoutingRuleInfo(c,cRR);
                      ruleAssigned = true;
                      system.debug('cRR:: '+cRR);
                    }
                    /* TKOM S-455214: this is where the Subject Matching logic should happen, but it will be split to a separate story and done later.  Leaving some messy code commented out until then.
                    else if (mapCaseRoutingRule.get(ruleKeyNAServiceTier).size() > 1){
                        // If matched >1 rulekeys
                        // for each of the multiple matching keys, check for a match based on subject.
                        // If no matching subject rulekey, find any key that matches without subject.  If still no match, skip to next section.
                        // This basically works if there are no duplicate rules. There is still room for improvement on this logic.  We should build a new list/map of unique potential matching rules and then do the below subject matching logic to find the correct match.



                        system.debug(':::: looping through multiple matching rules for potential subject matches');
                        for (CaseRoutingRule__c rr : mapCaseRoutingRule.get(ruleKeyNAServiceTier)){

                          system.debug('rr:: '+rr);
                          if(rr.Case_Subject__c != null && c.Subject.contains(rr.Case_Subject__c)) {

                            system.debug(':::: found MATCH WITH SUBJECT criteria - add to potential match list');
                            lstPotentialMatches.add(rr);
                            //cRR = rr;
                            //c = CaseTriggerHelper.populateCaseRoutingRuleInfo(c,cRR);
                            //ruleAssigned = true;
                            //system.debug('cRR:: '+cRR);
                          }
                          else if (!ruleAssigned && rr.Case_Subject__c == null){
                            system.debug(':::: Did not match subject criteria - assigning to matching rule without subject');
                            cRR = rr;
                            c = CaseTriggerHelper.populateCaseRoutingRuleInfo(c,cRR);
                            ruleAssigned = true;
                            system.debug('cRR:: '+cRR);
                          }
                        }
                    }// END Subject Matching logic
                    */
                    // If matched 0 rulekeys, skip - no subject matching needed.
                    else system.debug(':::: Did not match exactly one ruleKeyNAServiceTier -- SKIPPING');

                  } // END NAServiceTier matching
                } // END NA

                  // next, route for EU
                  else if(c.Account_Organization__c == 'Europe'){
                    system.debug('Org = EU');
                    //first check if there is an Agency, we have special rules for Agencies.
                    if(c.AgencyLookup__c != null){
                      if (!ruleAssigned && mapCaseRoutingRule.containsKey(ruleKeyAgency)){
                        system.debug(':::: Matched ruleKeyAgency');
                        system.debug(':::: mapCaseRoutingRule.get(ruleKeyAgency).size(): ' + mapCaseRoutingRule.get(ruleKeyAgency).size());
                        if( mapCaseRoutingRule.get(ruleKeyAgency).size() == 1){
                          system.debug(':::: found EXACT MATCH - assign cRR and update Case');
                          cRR = mapCaseRoutingRule.get(ruleKeyAgency)[0];
                          c = CaseTriggerHelper.populateCaseRoutingRuleInfo(c,cRR);
                          ruleAssigned = true;
                          system.debug('cRR:: '+cRR);
                        }
                        else system.debug(':::: Did not match exactly one ruleKeyAgency -- SKIPPING');
                      }
                    }

                    if (!ruleAssigned && mapCaseRoutingRule.containsKey(ruleKeyEUProductFamilyCountryLang)){
                      system.debug(':::: Matched ruleKeyEUProductFamilyCountryLang');
                      system.debug(':::: mapCaseRoutingRule.get(ruleKeyEUProductFamilyCountryLang).size(): ' + mapCaseRoutingRule.get(ruleKeyEUProductFamilyCountryLang).size());
                      if( mapCaseRoutingRule.get(ruleKeyEUProductFamilyCountryLang).size() == 1){
                        system.debug(':::: found EXACT MATCH - assign cRR and update Case');
                        cRR = mapCaseRoutingRule.get(ruleKeyEUProductFamilyCountryLang)[0];
                        c = CaseTriggerHelper.populateCaseRoutingRuleInfo(c,cRR);
                        ruleAssigned = true;
                        system.debug('cRR:: '+cRR);
                      }
                      else system.debug(':::: Did not match exactly one ruleKeyEUProductFamilyCountryLang -- SKIPPING');
                    }

                    // TKOM added for S-475343
                    if (!ruleAssigned && mapCaseRoutingRule.containsKey(ruleKeyEUProductFamilyCountry)){
                      system.debug(':::: Matched ruleKeyEUProductFamilyCountry');
                      system.debug(':::: mapCaseRoutingRule.get(ruleKeyEUProductFamilyCountry).size(): ' + mapCaseRoutingRule.get(ruleKeyEUProductFamilyCountry).size());
                      if( mapCaseRoutingRule.get(ruleKeyEUProductFamilyCountry).size() == 1){
                        system.debug(':::: found EXACT MATCH - assign cRR and update Case');
                        cRR = mapCaseRoutingRule.get(ruleKeyEUProductFamilyCountry)[0];
                        c = CaseTriggerHelper.populateCaseRoutingRuleInfo(c,cRR);
                        ruleAssigned = true;
                        system.debug('cRR:: '+cRR);
                      }
                      else system.debug(':::: Did not match exactly one ruleKeyEUProductFamilyCountry -- SKIPPING');
                    }

                    if (!ruleAssigned && mapCaseRoutingRule.containsKey(ruleKeyEUProductNameCountryLang)){
                      system.debug(':::: Matched ruleKeyEUProductNameCountryLang');
                      system.debug(':::: mapCaseRoutingRule.get(ruleKeyEUProductNameCountryLang).size(): ' + mapCaseRoutingRule.get(ruleKeyEUProductNameCountryLang).size());
                      if( mapCaseRoutingRule.get(ruleKeyEUProductNameCountryLang).size() == 1){
                        system.debug(':::: found EXACT MATCH - assign cRR and update Case');
                        cRR = mapCaseRoutingRule.get(ruleKeyEUProductNameCountryLang)[0];
                        c = CaseTriggerHelper.populateCaseRoutingRuleInfo(c,cRR);
                        ruleAssigned = true;
                        system.debug('cRR:: '+cRR);
                      }
                      else system.debug(':::: Did not match exactly one ruleKeyEUProductNameCountryLang -- SKIPPING');
                    }

                    // TKOM added for S-475343
                    if (!ruleAssigned && mapCaseRoutingRule.containsKey(ruleKeyEUProductNameCountry)){
                      system.debug(':::: Matched ruleKeyEUProductNameCountry');
                      system.debug(':::: mapCaseRoutingRule.get(ruleKeyEUProductNameCountry).size(): ' + mapCaseRoutingRule.get(ruleKeyEUProductNameCountry).size());
                      if( mapCaseRoutingRule.get(ruleKeyEUProductNameCountry).size() == 1){
                        system.debug(':::: found EXACT MATCH - assign cRR and update Case');
                        cRR = mapCaseRoutingRule.get(ruleKeyEUProductNameCountry)[0];
                        c = CaseTriggerHelper.populateCaseRoutingRuleInfo(c,cRR);
                        ruleAssigned = true;
                        system.debug('cRR:: '+cRR);
                      }
                      else system.debug(':::: Did not match exactly one ruleKeyEUProductNameCountry -- SKIPPING');
                    }

                    if (!ruleAssigned && mapCaseRoutingRule.containsKey(ruleKeyEUProductFamily)){
                      system.debug(':::: Matched ruleKeyEUProductFamily');
                      system.debug(':::: mapCaseRoutingRule.get(ruleKeyEUProductFamily).size(): ' + mapCaseRoutingRule.get(ruleKeyEUProductFamily).size());
                      if( mapCaseRoutingRule.get(ruleKeyEUProductFamily).size() == 1){
                        system.debug(':::: found EXACT MATCH - assign cRR and update Case');
                        cRR = mapCaseRoutingRule.get(ruleKeyEUProductFamily)[0];
                        c = CaseTriggerHelper.populateCaseRoutingRuleInfo(c,cRR);
                        ruleAssigned = true;
                        system.debug('cRR:: '+cRR);
                      }
                      else system.debug(':::: Did not match exactly one ruleKeyEUProductFamily -- SKIPPING');
                    }

                    if (!ruleAssigned && mapCaseRoutingRule.containsKey(ruleKeyEUProductName)){
                      system.debug(':::: Matched ruleKeyEUProductName');
                      system.debug(':::: mapCaseRoutingRule.get(ruleKeyEUProductName).size(): ' + mapCaseRoutingRule.get(ruleKeyEUProductName).size());
                      if( mapCaseRoutingRule.get(ruleKeyEUProductName).size() == 1){
                        system.debug(':::: found EXACT MATCH - assign cRR and update Case');
                        cRR = mapCaseRoutingRule.get(ruleKeyEUProductName)[0];
                        c = CaseTriggerHelper.populateCaseRoutingRuleInfo(c,cRR);
                        ruleAssigned = true;
                        system.debug('cRR:: '+cRR);
                      }
                      else system.debug(':::: Did not match exactly one ruleKeyEUProductName -- SKIPPING');
                    }

                    if (!ruleAssigned && mapCaseRoutingRule.containsKey(ruleKeyEUServiceTierCountryLang)){

                      system.debug(':::: Matched ruleKeyEUServiceTierCountryLang');
                      system.debug(':::: mapCaseRoutingRule.get(ruleKeyEUServiceTierCountryLang).size(): ' + mapCaseRoutingRule.get(ruleKeyEUServiceTierCountryLang).size());
                      if( mapCaseRoutingRule.get(ruleKeyEUServiceTierCountryLang).size() == 1){
                        system.debug(':::: found EXACT MATCH - assign cRR and update Case');
                        cRR = mapCaseRoutingRule.get(ruleKeyEUServiceTierCountryLang)[0];
                        c = CaseTriggerHelper.populateCaseRoutingRuleInfo(c,cRR);
                        ruleAssigned = true;
                        system.debug('cRR:: '+cRR);
                      }

                    /* TKOM S-473115: this is where the Subject Matching logic should happen.
                    Leaving some messy code commented out until I can complete it.
                    if (!ruleAssigned && mapCaseRoutingRule.containsKey(ruleKeyEUServiceTierCountryLang)){
                      system.debug(':::: Matched ruleKeyEUServiceTierCountryLang');
                      system.debug(':::: mapCaseRoutingRule.get(ruleKeyEUServiceTierCountryLang).size(): ' + mapCaseRoutingRule.get(ruleKeyEUServiceTierCountryLang).size());
                      if( mapCaseRoutingRule.get(ruleKeyEUServiceTierCountryLang).size() == 1){
                        system.debug(':::: found EXACT MATCH - assign cRR and update Case');
                        cRR = mapCaseRoutingRule.get(ruleKeyEUServiceTierCountryLang)[0];
                        c = CaseTriggerHelper.populateCaseRoutingRuleInfo(c,cRR);
                        ruleAssigned = true;
                        system.debug('cRR:: '+cRR);
                      }

                      else if (mapCaseRoutingRule.get(ruleKeyEUServiceTierCountryLang).size() > 1){
                          // If matched >1 rulekeys
                          // for each of the multiple matching keys, check for a match based on subject.
                          // If no matching subject rulekey, find any key that matches without subject.  If still no match, skip to next section.
                          system.debug(':::: looping through multiple matching rules for potential subject matches');
                          for (CaseRoutingRule__c rr : mapCaseRoutingRule.get(ruleKeyEUServiceTierCountryLang)){

                            system.debug('rr:: '+rr);
                            if(!ruleAssigned && ((rr.Case_Subject__c != null && c.Subject.contains(rr.Case_Subject__c)) || rr.Case_Subject__c == null )) {
                              system.debug(':::: found EXACT MATCH WITH SUBJECT criteria - assign cRR and update Case');
                              cRR = rr;
                              c = CaseTriggerHelper.populateCaseRoutingRuleInfo(c,cRR);
                              ruleAssigned = true;
                              system.debug('cRR:: '+cRR);
                            }
                            else if (!ruleAssigned && rr.Case_Subject__c == null){
                              system.debug(':::: Did not match subject criteria - assigning to matching rule without subject');
                              cRR = rr;
                              c = CaseTriggerHelper.populateCaseRoutingRuleInfo(c,cRR);
                              ruleAssigned = true;
                              system.debug('cRR:: '+cRR);
                            }
                          }
                      } // END Subject Matching logic
                      */

                      // If matched 0 rulekeys, skip - no subject matching needed.
                      else system.debug(':::: Did not match exactly one ruleKeyEUServiceTierCountryLang -- SKIPPING');

                    } // END EUServiceTierCountryLang matching

                    // TKOM added for S-475343
                    if (!ruleAssigned && mapCaseRoutingRule.containsKey(ruleKeyEUServiceTierCountry)){

                      system.debug(':::: Matched ruleKeyEUServiceTierCountry');
                      system.debug(':::: mapCaseRoutingRule.get(ruleKeyEUServiceTierCountry).size(): ' + mapCaseRoutingRule.get(ruleKeyEUServiceTierCountry).size());
                      if( mapCaseRoutingRule.get(ruleKeyEUServiceTierCountry).size() == 1){
                        system.debug(':::: found EXACT MATCH - assign cRR and update Case');
                        cRR = mapCaseRoutingRule.get(ruleKeyEUServiceTierCountry)[0];
                        c = CaseTriggerHelper.populateCaseRoutingRuleInfo(c,cRR);
                        ruleAssigned = true;
                        system.debug('cRR:: '+cRR);
                      }
                      // If matched 0 rulekeys, skip - no subject matching needed.
                      else system.debug(':::: Did not match exactly one ruleKeyEUServiceTierCountry -- SKIPPING');

                    } // END EUServiceTierCountry matching

                    if (!ruleAssigned && mapCaseRoutingRule.containsKey(ruleKeyEUServiceTier)){

                      system.debug(':::: Matched ruleKeyEUServiceTier');
                      system.debug(':::: mapCaseRoutingRule.get(ruleKeyEUServiceTier).size(): ' + mapCaseRoutingRule.get(ruleKeyEUServiceTier).size());
                      if( mapCaseRoutingRule.get(ruleKeyEUServiceTier).size() == 1){
                        system.debug(':::: found EXACT MATCH - assign cRR and update Case');
                        cRR = mapCaseRoutingRule.get(ruleKeyEUServiceTier)[0];
                        c = CaseTriggerHelper.populateCaseRoutingRuleInfo(c,cRR);
                        ruleAssigned = true;
                        system.debug('cRR:: '+cRR);
                      }

                      // If matched 0 rulekeys, skip - no subject matching needed.
                      else system.debug(':::: Did not match exactly one ruleKeyEUServiceTier -- SKIPPING');

                    } // END EUServiceTier matching
                  } //END EU

                //TKOM S-473116 Primary Svc Rep Assignment
                system.debug(':::: Check if cRR has AssignToPrimaryServiceRep flag set (only for NA & EU)');
                if(ruleAssigned && cRR.Assign_To_Primary_Service_Rep__c && c.AccountId!= null && mapAccounts.containskey(c.AccountId) && c.Account_Organization__c != 'Asia Pacific'){
                    Account caseAccount = mapAccounts.get(c.AccountId);

                    if(mapAccounts.get(c.AccountId).PrimaryServiceRep__c != null && mapAccounts.get(c.AccountId).PrimaryServiceRep__c != null){
                        c.OwnerId = mapAccounts.get(c.AccountId).PrimaryServiceRep__c;
                        system.debug('^^^ Setting case owner to PrimaryServiceRep ' + c.OwnerId);
                    }

                } // END S-473116 Primary Svc Rep Assignment
                else system.debug(':::: AssignToPrimaryServiceRep flag not set -- SKIPPING');

                system.debug('xxx runnnnn 7 ');
            }  //  END of NEW product implementation routing

            // TKOM S-460088
            //Logic needed for the EU Sales Support Request Record Type
            else if (c.RecordTypeId == euSalesSupportRecordTypeId){
                system.debug(':::: EU Sales Support Request routing ::::');
                // Create different rule keys based on case details to try and match a ruleKey from the routing rules:
                string ruleKeyEUSalesSupport = 'EU Sales Support Request';// + '|Org=' + c.Account_Organization__c;

                system.debug('::: case ruleKeyEUSalesSupport: ' + ruleKeyEUSalesSupport);
                if(!ruleAssigned && mapCaseRoutingRule.containsKey(ruleKeyEUSalesSupport)){
                    system.debug(':::: Matched ruleKeyEUSalesSupport');
                    system.debug(':::: mapCaseRoutingRule.get(ruleKeyEUSalesSupport).size(): ' + mapCaseRoutingRule.get(ruleKeyEUSalesSupport).size());
                    if( mapCaseRoutingRule.get(ruleKeyEUSalesSupport).size() == 1){
                      system.debug(':::: found EXACT MATCH - assign cRR and update Case');
                      cRR = mapCaseRoutingRule.get(ruleKeyEUSalesSupport)[0];
                      c = CaseTriggerHelper.populateCaseRoutingRuleInfo(c,cRR);
                      ruleAssigned = true;
                      system.debug('cRR:: '+cRR);
                    }
                }
                else system.debug(':::: Did not match ruleKeyEUSalesSupport -- SKIPPING');
            }




            //Assign our Catch All rule since no other was found

            if(ruleAssigned == false && catchAllRule != null) {
                system.debug('xxx runnnnn 8 ');
                system.debug('Did not find any matching rules - Use CatchAllRule ' + catchAllrule);
                cRR = catchAllRule;
                 //update from OwnerID to CaseOwner__c and again cRR.OwnerID By Vivek.
                if(cRR.OwnerID != null){
                  c.OwnerId = cRR.OwnerID;
                  c.Case_routing_Rule__c = cRR.Id;
                  c.SystemGenerated__c = true;
                }

            }
          }
        }
        //TKOM S-445214: no longer need to do this for product implementation cases - commenting out.
       // helper.updateCaseOwnerWithOrderSentToVerificationBy(euMediaCoreCases, null); //update owner for EU Media or Core
    }

    private void sendAutoReponseEmail(List<Case> cases){
        Final String CLASSNAME = '\n\n**** CaseTriggerHandler.METHODNAME()';
        final string METHODNAME = CLASSNAME.replace('METHODNAME','sendAutoReponseEmail');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Set<id> setCRRs = new Set<id>();
        List<CaseRoutingRule__c> routingRules = CaseRoutingUtility.getCaseRoutingRules();
        Map<id,CaseRoutingRule__c> MapRoutingRules = new Map<id,CaseRoutingRule__c>();
        List<Messaging.SingleEmailMessage>messages = new List<Messaging.SingleEmailMessage>();

        for(CaseRoutingRule__c cRR:routingRules){
            MapRoutingRules.put(cRR.Id,cRR);
        }

        for(Case c:cases){
            if(c.Case_Routing_Rule__c != null){
                CaseRoutingRule__c cRR = MapRoutingRules.get(c.Case_Routing_Rule__c);
                System.Debug('##cRR#'+cRR);
                if(cRR.AutoResponseTemplate__c != null){
                    messages.addall(CaseTriggerHelper.sendAutoReponseEmail(c,cRR,null));
                }
            }
        }

        if(messages.size()>0){
            try{
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                if (results[0].success) {
                    System.debug('The email was sent successfully.');
                } else {
                    System.debug('The email failed to send: '
                          + results[0].errors[0].message);
                }
            }
            catch(exception e){
                System.Debug('###'+e.getMessage());
            }
        }

        if(CaseTriggerHelper.AutoResponseContactsDelete.size()>0) CaseTriggerHelper.deleteCreatedcontacts(CaseTriggerHelper.AutoResponseContactsDelete);

    }

    /*private void createCaseRoutingRule(List<Case> cases){
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Request').getRecordTypeId();
        List<CaseRoutingRule__c> caseRoutingRuleList = new List<CaseRoutingRule__c>();

        List<Id> userId = new List<Id>();
         for(Case cs : cases){
            if(cs.RecordTypeId == caseRecordTypeId){
                userId.add(cs.OwnerId);
            }
        }
        System.debug('userId >>' + userId);
        caseRoutingRuleList = [Select Id , Active__c , CaseRecordType__c,OwnerId from CaseRoutingRule__c
                                Where Active__c = true AND CaseRecordType__c = 'Credit Request' LIMIT 1];
        System.debug('caseRoutingRuleList >>' +  caseRoutingRuleList.size());
         if(caseRoutingRuleList !=  null && caseRoutingRuleList.size() > 0 && !userId.isEmpty()){
            if(caseRoutingRuleList[0].OwnerId !=  userId[0])
                caseRoutingRuleList[0].OwnerId =  userId[0];

         }
         else{
            CaseRoutingRule__c csrouting = new CaseRoutingRule__c();
            csrouting.Name = 'Credit Check';
            csrouting.CaseRecordType__c = 'Credit Request';
            if(!userId.isEmpty()) {
                csrouting.OwnerId = userId[0];
            }
            csrouting.Active__c = true;
            csrouting.CaseStatus__c = 'Open';
            caseRoutingRuleList.add(csrouting);

         }
        System.debug('caseRoutingRuleList >>' +  caseRoutingRuleList.size());
        if(caseRoutingRuleList.size() > 0){
            upsert caseRoutingRuleList;
        }


    }*/
    /*------------------------------------------------------------------------------
    Description:   Check Case Owner should not be of Sales Profile
    Task Reference:  T-422402
    28th July 2015
    Dev name- Piyush Jain
    ------------------------------------------------------------------------------*/

    private static void checkCaseOwnerProfile(list<Case> newCaseList, Map<id,Case> oldCaseMap) {

        Final String CLASSNAME = '\n\n**** CaseTriggerHandler.METHODNAME()';
        final string METHODNAME = CLASSNAME.replace('METHODNAME','checkCaseOwnerProfile');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        set<Id> caseOwnerId = new set<Id>();

        for(Case cse : newCaseList) {
            if(oldCaseMap == null) {
                caseOwnerId.add(cse.OwnerId);
            }
            else if(oldCaseMap.get(cse.Id).OwnerId <> cse.OwnerId) {
                caseOwnerId.add(cse.OwnerId);
            }
        }

        Map<Id,User> caseOwnerUser =  new Map<Id,User>([SELECT Id, Profile.Name from User where id IN : caseOwnerId]);
        Org_Settings__c mc = Org_Settings__c.getOrgDefaults();
        String profileName ;
        System.debug('>>>>>>>>>>>>>>>>' + mc);

        for(Case cse: newCaseList){

            if(caseOwnerUser.containsKey(cse.OwnerId)){

                profileName = caseOwnerUser.get(cse.OwnerId).Profile.Name;
                System.debug('>>>>>>>> profileName >>>>>>>> ' + profileName);
                if(profileName == mc.Sales_Rep_NA__c || (profileName == mc.Sales_Rep_EU__c)
                   || (profileName == mc.Sales_Rep_APAC__c) || (profileName == mc.Sales_Manager_APAC__c)
                   || (profileName == mc.Sales_Manager_EU__c) || (profileName == mc.Sales_Manager_NA__c)
                   || (profileName == mc.Sales_Operations_NA__c)  || (profileName == mc.Sales_Operations_APAC__c) || (profileName == mc.Sales_Operations_EU__c)
                   || (profileName == mc.Sales_Operations_TA__c)){
                    if(profileName == mc.Sales_Rep_NA__c && Trigger.isInsert) //This condition is added by Rohit B on 23/Nov/2015 for issue I-191726.
                        continue;
                   Trigger.new[0].adderror('There are no routing rules that are defined for this case, since Sales users are not allowed to own case records, a case cannot be created - please contact your administrator');
                }
            }
        }
    }


    private void createSharingRule(list<Case> newCaseList){
        Final String CLASSNAME = '\n\n**** CaseTriggerHandler.METHODNAME()';
        final string METHODNAME = CLASSNAME.replace('METHODNAME','createSharingRule');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Set<Id> caseOwnerId = new Set<Id>();
        Map<Id,String> recordTypeIdToName = new Map<Id,String>();
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName();

        for(String str : rtMapByName.keyset()){

            recordTypeIdToName.put(rtMapByName.get(str).getRecordTypeId() , str);
        }
        System.debug('recordTypeIdToName >>' + recordTypeIdToName  );

        Map<String, Case_Access__c> caseAccess = Case_Access__c.getAll();
        System.debug('caseAccess >>' + caseAccess);
        for(Case cse : newCaseList) {
            if(cse.ownerId != null) {
                caseOwnerId.add(cse.OwnerId);
            }

        }

        Map<Id,User> caseOwnerUser =  new Map<Id,User>([SELECT Id, UserRole.Name from User where id IN : caseOwnerId]);
        String roleName ;
        String recordTypeName;
        for(Case cse: newCaseList){

            if(caseOwnerUser.containsKey(cse.OwnerId)){
                RoleName = caseOwnerUser.get(cse.OwnerId).UserRole.Name;
                if(RoleName != null){
                    if(caseAccess.containskey(RoleName) && caseAccess.get(RoleName) != null && recordTypeIdToName.containsKey(cse.RecordTypeId)){

                        recordTypeName = recordTypeIdToName.get(cse.RecordTypeId);
                        recordTypeName = recordTypeName.replaceAll('-', '_').replaceAll(' ', '_').replaceAll('/', '_') + '__c';
                        System.debug('recordTypeName >>' + recordTypeName);
                        System.debug('RoleName >>' + RoleName);
                        if(caseAccess.get(RoleName).get(recordTypeName) == false)
                        cse.adderror('Don\'t have the edit rights' );


                    }
                }
            }
        }



    }

    /* @Name: getCatchAllRule
    *  @Author: Shyam S (Appirio)
    *  @Params: None
    *  @Returns: CaseRoutingRule__c
    *  @Description: gets the Catch all rule from the org settings custom setting
                     will return null if that setting is blank
    */
    private CaseRoutingRule__c getCatchAllRule(){
        Final String CLASSNAME = '\n\n**** CaseTriggerHandler.METHODNAME()';
        final string METHODNAME = CLASSNAME.replace('METHODNAME','getCatchAllRule');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        CaseRoutingRule__c returnRule;
        Org_Settings__c orgSetting = Org_Settings__c.getOrgDefaults();
        if(orgSetting.Catch_All_Rule__c != null){
            returnRule = [
                Select Id, OwnerId, CaseRecordType__c, CaseStatus__c, CaseIssue__c, CaseOrigin__c, Fraud_Monitor_Type__c,
                    CaseContactSource__c, Account__c, CaseSubStatus__c, CaseSubIssue__c, CaseBusinessHours__c, FirstContactCommitmentHours__c,
                    ResolutionCommitmentHours__c, CaseLanguage__c, SystemGenerated__c, BusinessProcess__c, Case_Priority__c,
                    Order_Type__c, Category__c, Routing_Status__c, FromAddressforAutoResponse__c,
                    AutoResponseTemplate__c, ForwardIncomingEmailTo__c, Proposal_Language__c, Organization__c
                from CaseRoutingRule__c
                where Id = :orgSetting.Catch_All_Rule__c
                LIMIT 1];
        }

        if(returnRule == null){
            System.debug(logginglevel.WARN, 'No default case routing rule could be found - this could be an issue!!');
        }

        return returnRule;
    }



}