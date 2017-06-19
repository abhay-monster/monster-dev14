/*
** @author : Cloud Sherpas Inc.
** @date : 03/04/2014
** @description : Opportunity trigger class to handle CRUD events.
*/
public without sharing class OpportunityTriggerHandler extends BaseTriggerHandler{

    final String CLASSNAME = '\n\n**** OpportunityTriggerHandler.METHODNAME()';
    private integer BatchSize = 0;
    private OpportunityTriggerHelper helper;
    private OrderGeneration orderHelper;
    public static Integer RunCount = 0;
    public static Boolean PreventRecursion = true;
    public static Boolean SKIP_OPPORTUNITY_UPDATE = false;
    public static Boolean isCloned = false;
    public static Boolean ExecuteTriggers = Utility.ExecuteOpportunityTrigger == null ? true : Utility.ExecuteOpportunityTrigger;
    public Org_Settings__c orgSettings = Org_Settings__c.getInstance();
    public Integer cutoff = Integer.valueOf(orgSettings.Debug_Log_Record_Count_Cutoff__c); //JFreese Appirio S-435483 4/10/17
    public Id debugId = orgSettings.Debug_Log_Record_ID__c; //JFreese Appirio S-435483 4/11/17


/*
** @author : Cloud Sherpas Inc.
** @date : 03/04/2014
** @description : the class constructor method
** @paramaters : a Boolean value indicating if a trigger is executing or not, an Integer value indicating the number of records in the batch/list
** @returns : nothing
** @sample call : OpportunityTriggerHandler handler = new OpportunityTriggerHandler(Trigger.isExecuting, Trigger.size);
*/
    public OpportunityTriggerHandler(boolean isExecuting, integer pTriggerSize){

        // trigger is executing
        TriggerIsExecuting = isExecuting;

        // set batch size
        BatchSize = pTriggerSize;

        // instantiate new trigger helper
        helper = OpportunityTriggerHelper.NewTriggerHelper();

        // instantiate new order generator
        orderHelper = OrderGeneration.NewOrderGeneration();

        /*
            note - developer may want to create new or extent the base helper class specific to an sObject (i.e. OpportunityTriggerHelper)
        */
    }

/*
** @author : Cloud Sherpas Inc.
** @date : 03/04/2014
** @description :  this method handles the 'before insert' event for the trigger; it's purpose is to ...
** @paramaters : an array of Opportunity objects
** @returns : nothing
*/
    public void OnBeforeInsert(Opportunity[] pOpportunity){
        for(Opportunity opp : pOpportunity){
            if(opp.isclone()){
                opp.Unmodified_Opportunity_Clone__c = true; //SBerron - 2/09/17 - S-461740
            }
            else{
                opp.Unmodified_Opportunity_Clone__c = false;
            }
            system.debug('before insert Ordercreated='+ opp.OrderCreated__c+', StageName='+opp.StageName+', Skip_Stage_Validation__c='+opp.Skip_Stage_Validation__c+', Unmodified_Opportunity_Clone__c='+opp.Unmodified_Opportunity_Clone__c+', CloseDate='+opp.closedate);
            
            //Mitali N Appirio T-600146 9/5/17 to bypass VR when Account Status is Bad/Negative
            if(OrderTriggerHandler.ProcessingCreditRequest != null && OrderTriggerHandler.ProcessingCreditRequest == true){
                opp.Bypass_Credit_Status_Validation__c = true;
            }
            
        }

        if (Personal_Settings__c.getInstance().trigger_opportunity__c==false){
            return; // If triggers are off, then exit the method
        }


        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        //try{
            //for(Opportunity o : pOpportunity ){
              //  o.Skip_Stage_Validation__c = true;
            //}
            //if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){

                // create an Account Id set
                if(ExecuteTriggers){
                    helper.ResetQueries();
                    helper.OpportunityList = pOpportunity;

                    list<Opportunity> lstOppAgencyNotNull = new list<Opportunity>();
                    //This section is modified by Rohit B on 24/Nov/2015 for issue I-189137.        --START--
                    list<Opportunity> lstOppAgencyNull = new list<Opportunity>();
                    for(Opportunity o : pOpportunity){
                        if(o.Agency__c != Null)
                            lstOppAgencyNotNull.add(o);
                        else
                            lstOppAgencyNull.add(o);

                        //if(UserInfo.getName() == 'Integration MAPP'){
                            System.debug('^^^ Incoming Insert Opportunity ' + o);
                        //}
                    }

                    System.debug('[RB] - OpportunityTriggerHandler.OnBeforeInsert :: lstOppAgencyNull = ' + lstOppAgencyNull);
                    if(lstOppAgencyNull.size() > 0)
                        updateAgencyOnOpportunity(lstOppAgencyNull);
                    //This section is modified by Rohit B on 24/Nov/2015 for issue I-189137.        --END--

                    System.debug('[RB] - OpportunityTriggerHandler.OnBeforeInsert :: lstOppAgencyNotNull = ' + lstOppAgencyNotNull);
                    if(lstOppAgencyNotNull.size() > 0)
                         agencyValidationOnOpportunity(lstOppAgencyNotNull);

                    updateAgencyStreetAdderess(pOpportunity);

                    set<Id> accountIdSet = helper.CreateAccountIdSet(pOpportunity);

                    //set Credit status from Account
                    helper.setCreditStatus(pOpportunity);

                    // create an Account Id to Account object Map
                    map<Id, Account> accountIdToAccountMap = helper.CreateAccountIdToAccountMap(accountIdSet);

                    // set the Opportunity of Lead RecordType Owner to the related Account Owner
                    helper.SetOpportunityOfLeadRecordTypeOwnerToAccountOwner(pOpportunity, accountIdToAccountMap);
                    helper.SetOpportunityOfOpportunityRecordTypeOwnerToAccountOwner(pOpportunity, accountIdToAccountMap);

                    helper.SetRepMangersOnOpportunity(pOpportunity, null, null);

                    helper.SetOpportunityKeyInitiativeToAccountKeyInitiative(pOpportunity);

                    //Set Pricebook of every created opportunity - It moved to before insert
                    helper.SetPricebookOfEveryCreatedOpportunity(pOpportunity);
                    helper.SetOpportunityOfRecordType(pOpportunity);
                    helper.updateClonedOpptyRecordType(pOpportunity); //SBerron - 2/09/17 - S-461740
                }
                else{
                    system.debug('^^^ OpportunityTriggerHandler Bypassed OnBeforeInsert ExecuteTriggers=' + ExecuteTriggers);
                }

                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                */
            //}
        //}
        /*catch(BaseApplicationException bae){
            throw bae;
        }
        catch(Exception ex){
            system.debug(LoggingLevel.DEBUG, METHODNAME + ' :: ERROR MESSAGE = ' + ex.getMessage() + '\n\n');
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }*/

        for(Opportunity opp : pOpportunity){
            system.debug('end of before insert Ordercreated'+ opp.OrderCreated__c+', StageName='+opp.StageName+', Skip_Stage_Validation__c='+opp.Skip_Stage_Validation__c);
        }
    }

/*
** @author : Cloud Sherpas Inc.
** @date : 03/04/2014
** @description :  this method handles the 'after insert' event for the trigger; it's purpose is to ...
** @paramaters : an array of Opportunity objects
** @returns : nothing
*/
    public void OnAfterInsert(Opportunity[] pOpportunity){
        for(Opportunity opp : pOpportunity){
            system.debug('afterinsert starting...  Ordercreated'+ opp.OrderCreated__c+', StageName='+opp.StageName+', Skip_Stage_Validation__c='+opp.Skip_Stage_Validation__c);
        }



        if (Personal_Settings__c.getInstance().trigger_opportunity__c==false){
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        //try{
            //if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
            if(ExecuteTriggers){
                helper.ResetQueries();
                helper.OpportunityList = pOpportunity;

                //All Account Team Members with "Sales" in their Team Member Role are added as a Opportunity Team Member in the "Sales Rep" Team Member Role.
                helper.copyAccountSalesTeamMemToOppSalesTeamMem(pOpportunity);

                // Create Opportunity Competitors from Competitive Landscapes related to Account
                helper.CreateOpportunityCompetitorsFromCompetitiveLandscapesRelatedToAccounts(pOpportunity);
                // T-426832
                helper.chatterOnOpportunity(pOpportunity, null);
                // Create default sales credit split record on opportunity creation by Vikas Menon on 06 March, 2017 (S-462090)
                // Dev2QA1 SB commenting 3/07 for deployment to QA1 - uncommented as story is dev complete
                helper.createDefaultSalesCreditOnOpportunity(pOpportunity);


                for(Opportunity o : pOpportunity){
                    system.debug('^^^ OpportunityTriggerHandler End of OnAfterInsert - pOpportunity owner=' + o.ownerId);
                }
            }
            else{
                system.debug('^^^ OpportunityTriggerHandler Bypassed OnAfterInsert ExecuteTriggers=' + ExecuteTriggers);
            }

            //Set Pricebook of every created opportunity - It moved to before insert
            //helper.SetPricebookOfEveryCreatedOpportunity(pOpportunity);
                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                */
           // }
        //if(SkipOppUpdateToPreventRecursion != true)
            //updateSkipValidationToFalse(pOpportunity , false);

        //}
        /*catch(BaseApplicationException bae){
            throw bae;
        }
        catch(Exception ex){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }*/

        for(Opportunity opp : pOpportunity){
            system.debug('afterinsert ending...  Ordercreated'+ opp.OrderCreated__c+', StageName='+opp.StageName+', Skip_Stage_Validation__c='+opp.Skip_Stage_Validation__c);
        }
    }


    /*
    ** @author : Appirio India
    ** @date : 05/June/2015
    ** @description : Update the Skip_Stage_Validation__c field to false after update of opportunities
    ** @paramaters : New list of opportunities that has been updated
                     Boolean value to update Skip_Stage_Validation__c
    ** @returns : nothing
    */
    private void updateSkipValidationToFalse(Opportunity[] newOrUpdatedOpportunities , Boolean flag){
        SkipOppUpdateToPreventRecursion = true;

        List<opportunity> lstUpdatedOpp = [select Skip_Stage_Validation__c ,
                                                  Skip_Amount_Validation__c
                                           from opportunity
                                           where id
                                           IN : newOrUpdatedOpportunities];

        system.debug('===lstUpdatedOpp==='+lstUpdatedOpp);
        List<opportunity> lstOppToBeUpdated = new list<opportunity>();

        //Jeff L added - there is an issue when both of these are updating
        // then the same record gets added to the list, causign an error
        //of trying to update the same record twice in a list
        Set<Id> duplicateCheck = new Set<Id>();
        for(Opportunity o : lstUpdatedOpp){
            if(o.Skip_Stage_Validation__c == True ){
                o.Skip_Stage_Validation__c = flag;
                if(!duplicateCheck.contains(o.Id)){
                    lstOppToBeUpdated.add(o);
                    duplicateCheck.add(o.Id);
                }

            }

            if(o.Skip_Amount_Validation__c== True ){
                o.Skip_Amount_Validation__c= flag;
                if(!duplicateCheck.contains(o.Id)){
                    lstOppToBeUpdated.add(o);
                    duplicateCheck.add(o.Id);
                }
            }


        }
        if(!lstOppToBeUpdated.isempty())
            update lstOppToBeUpdated;
    }




/*
**  @author : Cloud Sherpas Inc.
**  @date : 03/04/2014
**  @description :  this method handles the 'before update' event for the trigger; it's purpose is to ...
**  @paramaters : array of old Opportunity objects, array of new Opportunity object, map of new Opportunities, map of old Opportunities
**  @returns : nothing
*/
    public void OnBeforeUpdate(Opportunity[] pOldOpportunities, Opportunity[] pUpdatedOpportunities, map<ID, Opportunity> pUpdatedOpportunityMap, map<ID, Opportunity> pOldOpportunityMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        system.debug('^^^ Runcount='+ OpportunityTriggerHandler.RunCount + '   ' + PreventRecursion + '    ' + SKIP_OPPORTUNITY_UPDATE);

        for(Opportunity opp : pUpdatedOpportunities){
            if(!opp.isclone())
            //Sberron commented as field was causing deployment to fail
                opp.Unmodified_Opportunity_Clone__c = false;

            if (pUpdatedOpportunities.size() <= cutoff || opp.Id == debugId){ //JFreese Appirio S-435483 4/10/17
                system.debug('beforeupdate starting...  Ordercreated'+ opp.OrderCreated__c+', StageName='+opp.StageName+', Skip_Stage_Validation__c='+opp.Skip_Stage_Validation__c);
                system.debug('Updating opportunity: '+ opp);
            }
             //Mitali N Appirio T-600146 9/5/17 to bypass VR when Account Status is Bad/Negative
           if(OrderTriggerHandler.ProcessingCreditRequest != null && OrderTriggerHandler.ProcessingCreditRequest == true){
                 opp.Bypass_Credit_Status_Validation__c = true;
             }
        }
        if (Personal_Settings__c.getInstance().trigger_opportunity__c==false){
            return; // If triggers are off, then exit the method
        }

        if((OpportunityTriggerHandler.RunCount > 0 && PreventRecursion) || SKIP_OPPORTUNITY_UPDATE || SkipOppUpdateToPreventRecursion ){
            system.debug('^^^ OpportunityTriggerHandler Bypassing OnBeforeUpdate Runcount=' + OpportunityTriggerHandler.RunCount + ', PreventRecursion=' + PreventRecursion + ', SKIP_OPPORTUNITY_UPDATE=' + SKIP_OPPORTUNITY_UPDATE + ', SkipOppUpdateToPreventRecursion=' + SkipOppUpdateToPreventRecursion);
            return;
        }

             if(ExecuteTriggers){

                //validations for competitors
                validateCloseReason(pUpdatedOpportunities, pOldOpportunityMap);

                helper.ResetQueries();
                helper.OpportunityList = pUpdatedOpportunities;

                list<Opportunity> lstOppAgencyNotNull = new list<Opportunity>();
                for(Opportunity o : pUpdatedOpportunities){
                     if(o.Agency__c != Null && pOldOpportunityMap.get(o.Id).Agency__c != o.Agency__c)
                         lstOppAgencyNotNull.add(o);
                }
                if(lstOppAgencyNotNull.size() > 0)
                     agencyValidationOnOpportunity(lstOppAgencyNotNull);

                updateAgencyStreetAdderess(pUpdatedOpportunities);


                helper.BypassingEstimateValueValidation(pUpdatedOpportunities);
                helper.SetRepMangersOnOpportunity(pUpdatedOpportunities, pUpdatedOpportunityMap, pOldOpportunityMap);
                List<Opportunity> OppList = new List<Opportunity>();
                // Cases created only when Order Created = true
                for(Opportunity opp: pUpdatedOpportunities){
                    if(opp.OrderCreated__c && !pOldOpportunityMap.get(opp.Id).OrderCreated__c){
                        OppList.add(opp);
                    }

                    /*if(opp.Amount != pOldOpportunityMap.get(opp.Id).Amount){
                        opp.Skip_Amount_Validation__c = true;
                    }*/

                }
                if(!OppList.isEmpty()){
                    //helper.setOwnerForValidationRequestCases(OppList);
                }

                RunCount++;
                helper.CancelApprovalProcess(pUpdatedOpportunityMap,pOldOpportunityMap);
                system.debug('Opp Handler Run Count: ' + RunCount);

                for(Opportunity o : pUpdatedOpportunities){
                    if (pUpdatedOpportunities.size() <= cutoff || o.Id == debugId){ //JFreese Appirio S-435483 4/10/17
                        system.debug('^^^ OpportunityTriggerHandler End of OnBeforeUpdate - pUpdatedOpportunity owner=' + o.ownerId);
                    }
                }
            }
            else{
                system.debug('^^^ OpportunityTriggerHandler Bypassed OnBeforeUpdate ExecuteTriggers=' + ExecuteTriggers);
             }

            for(Opportunity opp : pUpdatedOpportunities){
                if (pUpdatedOpportunities.size() <= cutoff || opp.Id == debugId){ //JFreese Appirio S-435483 4/10/17
                system.debug('beforeupdate end...  Ordercreated'+ opp.OrderCreated__c+', StageName='+opp.StageName+', Skip_Stage_Validation__c='+opp.Skip_Stage_Validation__c);
                }
            }
    }


    public void updateAgencyStreetAdderess(list<Opportunity> lstNewOpportunity) {
        Map<Id, List<Opportunity>> mapAgencyIdToListOpp = new Map<Id, List<Opportunity>>();
        for(Opportunity opp : lstNewOpportunity) {
            if(opp.Agency__c != null) {
                if(!mapAgencyIdToListOpp.containsKey(opp.Agency__c)) {
                    mapAgencyIdToListOpp.put(opp.Agency__c, new List<Opportunity>());
                }
                mapAgencyIdToListOpp.get(opp.Agency__c).add(opp);
            }
        }

        if(!mapAgencyIdToListOpp.keySet().isEmpty()){
            for(Account agency : [SELECT Id, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry
                        FROM Account
                        WHERE Id IN : mapAgencyIdToListOpp.keySet()]) {

                for(Opportunity o : mapAgencyIdToListOpp.get(agency.Id)) {
                    o.AgencyStreetAddress__c = agency.ShippingStreet + '/n' +  agency.ShippingCity + ', ' + agency.ShippingState +', ' + agency.ShippingPostalCode + ', ' + agency.ShippingCountry;
                }
            }
        }
    }

    /*
    **  @author : Appirio
    **  @date : 05/Sep/2015
    **  @description :  this method handles the 'after update' and 'after Insert' event for the trigger;
    **  @paramaters : array of new Opportunity object
    **  @returns : nothing
    */


    private void agencyValidationOnOpportunity(list<Opportunity> newOpportunity){
        Set<id> setOppAccountIds = new Set<id>();
        for(Opportunity o : newOpportunity){
            if(o.Agency__c != Null)
                setOppAccountIds.add(o.AccountId);
        }
            system.debug('##setOppAccountIds##'+setOppAccountIds);
        list<RelatedPartner__c> lstRelatedPartners = [select Account__c ,Partner__c from RelatedPartner__c where Account__c IN:setOppAccountIds];
            system.debug('@@lstRelatedPartners@@'+lstRelatedPartners);
        Map<id,Set<Id>> mapAccountToRelatedPartners = new Map<id,Set<Id>>();

        for(RelatedPartner__c rp : lstRelatedPartners){
            if(!mapAccountToRelatedPartners.containskey(rp.Account__c))
                mapAccountToRelatedPartners.put(rp.Account__c , new Set <Id>());

            mapAccountToRelatedPartners.get(rp.Account__c).add(rp.Partner__c);
        }
        for(Opportunity o : newOpportunity){
            if(mapAccountToRelatedPartners.containskey(o.AccountId) && !mapAccountToRelatedPartners.get(o.AccountId).contains(o.Agency__c)) {
                o.Agency__c.adderror('Only Account related partners can be added as an Agency on Opportunity');
            }

        }


    }



/*
**  @author : Cloud Sherpas Inc.
**  @date : 03/04/2014
**  @description :  this method handles the 'after update' event for the trigger; it's purpose is to ...
**  @paramaters : array of old Opportunity objects, array of new Opportunity object, map of new Opportunities, map of old Opportunities
**  @returns : nothing
*/
    public void OnAfterUpdate(Opportunity[] pOldOpportunities, Opportunity[] pUpdatedOpportunities, map<ID, Opportunity> OpportunityMapNew, map<ID, Opportunity> pOpportunityMapOld){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        system.debug('^^^ Runcount='+ OpportunityTriggerHandler.RunCount + ' PreventRecursion=' + PreventRecursion + ' SKIP_OPPORTUNITY_UPDATE=' + SKIP_OPPORTUNITY_UPDATE + ' SkipOppUpdateToPreventRecursion=' + SkipOppUpdateToPreventRecursion);

        for(Opportunity opp : pUpdatedOpportunities){
            if (pUpdatedOpportunities.size() <= cutoff || opp.Id == debugId){ //JFreese Appirio S-435483 4/10/17
                system.debug('afterupdate starting...  Ordercreated'+ opp.OrderCreated__c+', StageName='+opp.StageName+', Skip_Stage_Validation__c='+opp.Skip_Stage_Validation__c);
                system.debug('Updated opportunity: '+ opp);
            }
        }

        if (Personal_Settings__c.getInstance().trigger_opportunity__c==false){
            return; // If triggers are off, then exit the method
        }
        if (OrderTriggerHandler.CreatingCreditOpportunity != null && OrderTriggerHandler.CreatingCreditOpportunity) {
            //SBerron - S-473201 - 03/14/17
            //We still want to recalculate splits for credit opportunities
            System.debug('----opptyOnAfterUpdate CreateOrdersAutomatically ' + CreditRequestTriggerHandler.CreateOrdersAutomatically);
            helper.updateOpptySplit(pUpdatedOpportunities, pOpportunityMapOld);
        }
        //SBerron - 4/05-17 - moved here as the update was being bypassed in Account change
        helper.updateSalesCreditSplitSalesRep(pUpdatedOpportunities,pOpportunityMapOld);

        if((OpportunityTriggerHandler.RunCount > 1 && PreventRecursion) || SKIP_OPPORTUNITY_UPDATE || SkipOppUpdateToPreventRecursion ){
            system.debug('^^^ Bypassing OpportunityTriggerHandler OnAfterUpdate Runcount=' + OpportunityTriggerHandler.RunCount + ', PreventRecursion=' + PreventRecursion + ', SKIP_OPPORTUNITY_UPDATE=' + SKIP_OPPORTUNITY_UPDATE + ', SkipOppUpdateToPreventRecursion=' + SkipOppUpdateToPreventRecursion);
            return;
        }
        System.debug('===Limits.getQueries==Opportunity==After Update started====' + Limits.getQueries());
        //try{
            //if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
             if(ExecuteTriggers){
                helper.ResetQueries();
                helper.OpportunityList = pUpdatedOpportunities;
                helper.updateSecondaryTeamMember(pUpdatedOpportunities,pOpportunityMapOld);
                helper.SetAllocationSplitsForPrimaryAndSecondarySalesRep(OpportunityMapNew, pOpportunityMapOld);

                // create a Primary Opportunity Team Member Type To List of Accounts Map
                map<string, list<Opportunity>> primaryTeamMemberTypeToListOfOpportunitiesMap = new map<string, list<Opportunity>>();

                // create an Opportunity Id Set
                /* Jeff L commented out since the logic that is using this method is also commented out
                set<Id> opportunityIdSet = new set<Id>();
                set<Id> updateOwnerAccountIdSet = new set<Id>();

                 Jeff L commented out since the logic that is using this method is also commented out
                for(Opportunity oOpportunity: pUpdatedOpportunities){
                    system.debug('ownerID::'+OpportunityMapNew.get(oOpportunity.Id).OwnerId +'  old::'+ pOpportunityMapOld.get(oOpportunity.Id).OwnerId);
                    // if Opportunity ownership has changed, add the Opportunity to the Primary Sales Rep list
                    if(OpportunityMapNew.get(oOpportunity.Id).OwnerId != pOpportunityMapOld.get(oOpportunity.Id).OwnerId){

                        if(primaryTeamMemberTypeToListOfOpportunitiesMap.containsKey('PrimarySalesRep')){
                            opportunityIdSet.add(oOpportunity.Id);
                            primaryTeamMemberTypeToListOfOpportunitiesMap.get('PrimarySalesRep').add(oOpportunity);
                        }else{
                            opportunityIdSet.add(oOpportunity.Id);
                            list<Opportunity> newOpportunityList = new list<Opportunity>();
                            newOpportunityList.add(oOpportunity);
                            primaryTeamMemberTypeToListOfOpportunitiesMap.put('PrimarySalesRep', newOpportunityList);
                        }
                    }

                    // if Opportunity Primary Service Rep has changed, add the Opportunity to the Primary Service Rep list
                    if(OpportunityMapNew.get(oOpportunity.Id).SecondarySalesRep__c != pOpportunityMapOld.get(oOpportunity.Id).SecondarySalesRep__c){

                        if(primaryTeamMemberTypeToListOfOpportunitiesMap.containsKey('')){
                            opportunityIdSet.add(oOpportunity.Id);
                            primaryTeamMemberTypeToListOfOpportunitiesMap.get('SecondarySalesRep').add(oOpportunity);
                        }else{
                            opportunityIdSet.add(oOpportunity.Id);
                            list<Opportunity> newOpportunityList = new list<Opportunity>();
                            newOpportunityList.add(oOpportunity);
                            primaryTeamMemberTypeToListOfOpportunitiesMap.put('SecondarySalesRep', newOpportunityList);
                        }
                    }

                }*/

                // update the Primary Opportunity Team Members
                //helper.UpdatePrimaryOpportunityTeamMembers(opportunityIdSet, primaryTeamMemberTypeToListOfOpportunitiesMap);
                // moved the previous method due to the errors
               //TODO (commented out by TW) OpportunityTeamingMemberHelper.getInstance().UpdatePrimaryOpportunityTeamMembers(opportunityIdSet, primaryTeamMemberTypeToListOfOpportunitiesMap);
                system.debug(LoggingLevel.INFO, 'createOrderWhenOrderIsCreated Called');
                System.debug('===Limits.getQueries=Opportunity==Before Order created' + Limits.getQueries());
                //creates an order when opporunity create order = TRUE
                if (pUpdatedOpportunities.size() <= cutoff){ //JFreese Appirio S-435483 4/10/17
                    system.debug('HANDLER-BEFORE CREATE ORDER IS CALLED OLDMAP '+ pOpportunityMapOld);
                    system.debug('HANDLER-BEFORE CREATE ORDER IS CALLED NEW '+ pUpdatedOpportunities);
                }
                orderHelper.createOrder(pUpdatedOpportunities, pOpportunityMapOld);

                System.debug('===Limits.getQueries==Opportunity==After Order created' + Limits.getQueries());
                //updates quote agency related to an opportunity when opportunity's agency updates
                helper.updateAgencyOfRelatedQuotes(OpportunityMapNew, pOpportunityMapOld);

                //User Story 0162
                helper.updateQuoteStatus(OpportunityMapNew, pOpportunityMapOld);
                // T-426832
                helper.chatterOnOpportunity(pUpdatedOpportunities, pOpportunityMapOld);

                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                */
            //}
           System.debug('===Limits.getQueries==Opportunity==Before updateTeamMember()' + Limits.getQueries());
           helper.updateTeamMember(pUpdatedOpportunities ,pOpportunityMapOld);
           System.debug('===Limits.getQueries==Opportunity==After updateTeamMember()' + Limits.getQueries());
           if(UserInfo.getName() != 'Integration MAPP'){
               helper.generateOMProccessingCase(pUpdatedOpportunities, pOpportunityMapOld);
           }

           // S-418868 || Modified By - Appttus Support - Viraj Rana || Date: 2016-10-11

           helper.updateQuptesForStage3(OpportunityMapNew, pOpportunityMapOld);

           //SBerron - Appirio - 2/17/17 - S-442900
           helper.updateOpptySplit(pUpdatedOpportunities, pOpportunityMapOld);
           //helper.updateOpptySplit(pUpdatedOpportunities);

        //}
        /*catch(BaseApplicationException bae){
            System.debug('StackTrace:'+bae.getStackTraceString());
            throw bae;
        }
        catch(Exception ex){
            System.debug('StackTrace:'+ex.getStackTraceString());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }*/

        }
        else{
            system.debug('^^^ OpportunityTriggerHandler Bypassed OnAfterUpdate ExecuteTriggers=' + ExecuteTriggers);
        }


        if(SkipOppUpdateToPreventRecursion != true)
            updateSkipValidationToFalse(pUpdatedOpportunities , false);

        for(Opportunity o : pUpdatedOpportunities){
            if (pUpdatedOpportunities.size() <= cutoff || o.Id == debugId){ //JFreese Appirio S-435483 4/10/17
                system.debug('^^^ OpportunityTriggerHandler End of OnAfterUpdate - pUpdatedOpportunity owner=' + o.ownerId + ', Limits.getQueries() ' +Limits.getQueries());
                system.debug('afterupdate end...  Ordercreated'+ o.OrderCreated__c+', StageName='+o.StageName+', Skip_Stage_Validation__c='+o.Skip_Stage_Validation__c);
            }
        }
    // Added By Vikas Menon for S-452703
    helper.removeSplitWhenOwnerChangesonClosedOppty(pUpdatedOpportunities,pOpportunityMapOld);
    // Added By Vikas Menon for S-473433
	helper.updateSalesCreditSplitSalesRep(pUpdatedOpportunities,pOpportunityMapOld);

    }

/*
**  @author : Cloud Sherpas Inc.
**  @date : 03/04/2014
**  @description :  this method handles the 'before delete' event for the trigger; it's purpose is to ...
**  @paramaters : array of old Opportunity objects, map of old Opportunities
**  @returns : nothing
*/


    public void OnBeforeDelete(List<Opportunity> pOldOpportunities){

        validateDeletion(pOldOpportunities);

        if (Personal_Settings__c.getInstance().trigger_opportunity__c==false){
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeDelete');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        //try{
            //if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                // <write code here>
                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                */
           // }
        //}
        /*catch(BaseApplicationException bae){
            throw bae;
        }
        catch(Exception ex){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }*/
    }

    public void validateDeletion(List<Opportunity> oppList){
        Profile profile = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
        for(Opportunity opp : oppList){
            if(profile.Name == 'Sales Operations (APAC)' || profile.Name == 'Sales Operations (EU)' || profile.Name == 'Sales Operations (NA)'){
                opp.addError('This user is not allowed to delete opportunity');
            }
        }
   }




/*
**  @author : Cloud Sherpas Inc.
**  @date : 03/04/2014
**  @description :  this method handles the 'after delete' event for the trigger; it's purpose is to ...
**  @paramaters : array of old Opportunity objects, map of old Opportunities
**  @returns : nothing
*/
  /*  public void OnAfterDelete(Opportunity[] pOldOpportunities, map<ID, SObject> pOpportunityMapOld){
        if (Personal_Settings__c.getInstance().trigger_opportunity__c==false){
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterDelete');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        //try{
            //if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                // <write code here>

                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.

            //}
        }
        catch(BaseApplicationException bae){
            throw bae;
        }
        catch(Exception ex){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }
    } */

/*
**  @author : Cloud Sherpas Inc.
**  @date : 03/04/2014
**  @description :  this method handles the 'Undeleted' event for the trigger; it's purpose is to ...
**  @paramaters : array of new Opportunity object
**  @returns : nothing
*/
  /*  public void OnUndeleted(Opportunity[] pUndeletedOpportunities){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnUndeleted');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        //try{
            //if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                // <write code here>

                //    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                 //          and call the methods from handler.

            //}
        //}
        catch(BaseApplicationException bae){
            throw bae;
        }
        catch(Exception ex){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }
    } */

    // Jeff L moved into Trigger Helper
    //This method is used for updating the Opportunity team member custom object field Team Member to opportunity owner field
    // reference task - T-408190
    //Update method in due of Issue I-167744
    /*
    public void updateTeamMember(list<Opportunity> listOpportunities,map<Id,Opportunity> oldMap){
        system.debug('!!!!!!Inside Update member');
        map<Id,Id> mapOpportunityOwner = new map<Id,Id>();
        //Opportuntities whose owner has been changed
        for(Opportunity opp:listOpportunities){
            if(opp.OwnerId != oldMap.get(opp.Id).OwnerId){
                mapOpportunityOwner.put(opp.Id,opp.OwnerId);
            }
        }

        //List of changed owners already existing as Opp Team member
        map<Id, List<OpportunityTeamMember__c>> oppTeamMembers= new map<Id, List<OpportunityTeamMember__c>>();
        if(mapOpportunityOwner != null && mapOpportunityOwner.size() > 0){

            //Opportunity Team members Query for the changed owner Opps
        for(OpportunityTeamMember__c oppmember:[Select TeamMember__c,TeamRole__c,Opportunity__c,TeamMember__r.Name from OpportunityTeamMember__c where Opportunity__c
                in:mapOpportunityOwner.keyset()]){
                    if(!oppTeamMembers.keySet().contains(oppmember.Opportunity__c)){
                        oppTeamMembers.put(oppmember.Opportunity__c, new List<OpportunityTeamMember__c>());
                    }
                    oppTeamMembers.get(oppmember.Opportunity__c).add(oppmember);
                }
        }


        if(mapOpportunityOwner != null && mapOpportunityOwner.size()>0 && oppTeamMembers.size()>0){

            list<OpportunityTeamMember__c> listOpportunityTeamMember = new list<OpportunityTeamMember__c>();
            list<OpportunityTeamMember__c> deleteOpportunityTeamMember = new list<OpportunityTeamMember__c>();
            OpportunityTeamMember__c member;
            Boolean primarySalesRepExists = false;
            Boolean sameMemberExists = false;
            for(Id oppId : mapOpportunityOwner.KeySet()){
                primarySalesRepExists = false;
                sameMemberExists = false;
                List<OpportunityTeamMember__c> teamMembers = oppTeamMembers.get(oppId);
                for(OpportunityTeamMember__c oppmember: teamMembers){
                    if(oppmember.TeamMember__c == mapOpportunityOwner.get(oppId) ){
                        //deleteOpportunityTeamMember.add(oppmember);
                        oppmember.TeamRole__c = 'Primary Sales Rep';
                        listOpportunityTeamMember.add(oppmember);
                        sameMemberExists = true;
                        primarySalesRepExists = true;
                    }
                }
                for(OpportunityTeamMember__c oppmember: teamMembers){

                    if(oppmember.TeamRole__c == 'Primary Sales Rep' && oppmember.TeamMember__c != mapOpportunityOwner.get(oppId)){
                        primarySalesRepExists = true;
                        if(sameMemberExists){
                            deleteOpportunityTeamMember.add(oppmember);
                        } /*else {
                        oppmember.TeamMember__c = mapOpportunityOwner.get(oppmember.Opportunity__c);
                        listOpportunityTeamMember.add(oppmember);
                        }*/
                /*    }
                }
                if(!primarySalesRepExists){
                    OpportunityTeamMember__c oppTeamMember = new OpportunityTeamMember__c ();
                    oppTeamMember.TeamMember__c = mapOpportunityOwner.get(oppId);
                    oppTeamMember.Split__c = 100.0;
                    oppTeamMember.TeamRole__c = 'Primary Sales Rep';
                    oppTeamMember.Opportunity__c = oppId;
                    oppTeamMember.OpportunityAccess__c = 'Read/Write';
                    listOpportunityTeamMember.add(oppTeamMember);
                }
            }
            system.debug('!!!!!!!!!!!deleteOpportunityTeamMember'+deleteOpportunityTeamMember);
            if(deleteOpportunityTeamMember != null && deleteOpportunityTeamMember.size()>0){
                delete deleteOpportunityTeamMember;
            }
            system.debug('!!!!!!Insode Update member after delete'+listOpportunityTeamMember);
            if(listOpportunityTeamMember != null && listOpportunityTeamMember.size()>0){
                upsert listOpportunityTeamMember;
            }
        }
    }*/

      // Make chatter on oppportunity When SLA checkbox = true
      // Jeff moved this over to Trigger Helper code
      /*public void chatterOnOpportunity(list<Opportunity> listOpportunities,map<Id,Opportunity> oldMap){
            set<Id> accIds = new set<Id>();
            set<Id> ownerIds = new set<Id>();
            boolean isValid;
            List<Opportunity> oppToChatter = new List<Opportunity>();
            for(Opportunity o : listOpportunities){
                isValid = false;
                if(oldMap == null && o.SLA_Missed__c){
                   isValid = true;
                }
                else if(oldMap != null && o.SLA_Missed__c && !oldMap.get(o.Id).SLA_Missed__c){
                    isValid = true;
                }
                if(isValid){
                    oppToChatter.add(o);
                    accIds.add(o.AccountId);
                    ownerIds.add(o.ownerId);
                }
            }

            if(oppToChatter.isEmpty()) return;
            map<Id, User> userMap = new map<Id,User>([Select Id,ManagerId from User Where Id IN :ownerIds]);
            map<Id,Account> accountMap = new map<Id,Account>([Select Id,Organization__c from Account Where Id IN :accIds]);
            String postText = ' SLA has been missed';
            for(Opportunity o : oppToChatter){

                if(accountMap.containsKey(o.AccountId)){
                    string org = accountMap.get(o.AccountId).Organization__c;
                    if(org == 'North America'){
                        set<string> mentionIds = new set<string>();
                        mentionIds.add(o.ownerId);
                        util.postChatterFeed(String.valueOf(o.Id),mentionIds,postText);
                    }
                    else if(org == 'Europe'){
                        set<string> mentionIds = new set<string>();
                        mentionIds.add(o.ownerId);
                        if(userMap.containsKey(o.ownerId) ){
                            if(userMap.get(o.ownerId).ManagerId != null){
                                mentionIds.add(userMap.get(o.ownerId).ManagerId);
                            }
                        }
                        util.postChatterFeed(String.valueOf(o.Id),mentionIds,postText) ;
                    }
                }

            }

    }*/

    //This method is added by Rohit B on 24/Nov/2015 for issue I-189137.        --START--
    void updateAgencyOnOpportunity(list<Opportunity> lstOpp) {
        Map<Id, Account> mapAgencyIdToList = new Map<Id, Account>();
        Set<Id> accountIDs = new Set<Id>();
        System.debug('[RB] - OpportunityTriggerHandler.updateAgencyOnOpportunity :: lstOpp = ' + lstOpp);
        for(Opportunity op : lstOpp)
            accountIDs.add(op.AccountId);
        System.debug('[RB] - OpportunityTriggerHandler.updateAgencyOnOpportunity :: accountIDs = ' + accountIDs);

        for(Account acc : [SELECT Id, AgencyBilled__c, Billing_Agency__c, Agency_Comments__c,
                            ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry,
                            (SELECT Id, Name, Partner__c FROM Related_Partners__r WHERE AgencyType__c = 'Billing' Limit 1)
                            FROM Account WHERE Id in : accountIDs]) {
            if(acc.AgencyBilled__c == 'Yes')
                mapAgencyIdToList.put(acc.Id, acc);
        }
        //System.debug('[RB] - OpportunityTriggerHandler.updateAgencyOnOpportunity :: mapAgencyIdToList = ' + mapAgencyIdToList);

        for(Opportunity o : lstOpp) {
            if(mapAgencyIdToList.get(o.AccountId) != null) {
                if(mapAgencyIdToList.get(o.AccountId).Related_Partners__r != Null) {
                    String agencyID = (mapAgencyIdToList.get(o.AccountId).Related_Partners__r).Partner__c;
                    System.debug('[RB] - OpportunityTriggerHandler.updateAgencyOnOpportunity :: Agency__c = ' + agencyID.left(15));
                    o.Agency__c = agencyID.left(15);
                    o.Agency_Comments__c = mapAgencyIdToList.get(o.AccountId).Agency_Comments__c;
                    o.AgencyStreetAddress__c = mapAgencyIdToList.get(o.AccountId).ShippingStreet + '/n' +  mapAgencyIdToList.get(o.AccountId).ShippingCity + ', ' + mapAgencyIdToList.get(o.AccountId).ShippingState +', ' + mapAgencyIdToList.get(o.AccountId).ShippingPostalCode + ', ' + mapAgencyIdToList.get(o.AccountId).ShippingCountry;
                }
            }
        }
    }
    //This method is added by Rohit B on 24/Nov/2015 for issue I-189137.        --END--

    public void validateCloseReason(List<Opportunity> pUpdatedOpportunities, map<Id, Opportunity> pOldOpportunityMap){
        Map<Id, Integer> mapOpp = new Map<Id, Integer>();
        //system.assert(false,'**pUpdatedOpportunities** '+pUpdatedOpportunities);
        for(Opportunity o : pUpdatedOpportunities){
             if(o.DispositionReason__c == 'Competition' && pOldOpportunityMap.get(o.Id).DispositionReason__c != o.DispositionReason__c){
                 mapOpp.put(o.Id, 0);
             }
        }

        if(mapOpp.keySet().size() > 0){
            for(Opportunity opp : [Select Id, (Select Id from Opportunity_Competitors__r limit 1) from Opportunity where Id IN :mapOpp.keySet()]){
                mapOpp.put(opp.Id, opp.Opportunity_Competitors__r.size());
            }
        }

        for(Opportunity o : pUpdatedOpportunities){
             if(o.DispositionReason__c == 'Competition' && pOldOpportunityMap.get(o.Id).DispositionReason__c != o.DispositionReason__c
                    && mapOpp.get(o.Id) == 0){
                 o.addError('You cannot close an opportunity with Competition reason without having any competitor.');
             }
        }
   }
}