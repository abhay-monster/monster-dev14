/*
** @author : Cloud Sherpas Inc.
** @date : 04/09/2014
** @description : Account trigger  class to handle CRUD events.
*/
public with sharing class ApttusProposalTriggerHandler extends BaseTriggerHandler{
    
    final String CLASSNAME = '\n\n**** ApttusProposalTriggerHandler.METHODNAME()';
    private integer BatchSize = 0;
    private ApttusProposalTriggerHelper helper;
    public static Boolean ExecuteTriggers = true;
    private static Integer RunCountBU = 0; //counter for beforeUpdate
    private static Integer RunCountAU = 0; //counter for afterUpdate
    private static Integer creditrequestCount = 0; //counter for afterUpdate
    public static Boolean PreventRecursion = true;
    public static Boolean IsTriggerForCloneProposal = false;  //To Prevent 101 Soql Error, Because when Clone the Quote we dont want to execute all the triggers.added by apptus support on 2016/03/11
    public static Boolean ExecuteTriggersFromOpportunityUpdate = true; // When proposal is updated from opportunity for the story S-418868 don't need to call the proposal trigger. || Modified By - Appttus Support - Viraj Rana|| Date: 2016-10-11
    
    
    
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
** @date : 04/09/2014
** @description : the class constructor method
** @paramaters : a Boolean value indicating if a trigger is executing or not, an Integer value indicating the number of records in the batch/list
** @returns : nothing
** @sample call : AccountTriggerHandler handler = new AccountTriggerHandler(Trigger.isExecuting, Trigger.size);
*/
    public ApttusProposalTriggerHandler(boolean isExecuting, integer pTriggerSize){
        
        // trigger is executing
        TriggerIsExecuting = isExecuting;
        
        // set batch size
        BatchSize = pTriggerSize;
        //Profile currentUserProfile=[Select Name From Profile where Id = :UserInfo.getProfileId()];
        // intantiate new trigger helper
        helper = ApttusProposalTriggerHelper.NewTriggerHelper(CurrentUserProfileName);
        /*
note - developer may want to create new or extent the base helper class specific to an sObject (i.e. AccountTriggerHelper)
*/
    }
    
    
    /*
** @author : Cloud Sherpas Inc.
** @date : 04/09/2014
** @description :  this method handles the 'after insert' event for the trigger; it's purpose is to ...
** @paramaters : an array of Apttus_Proposal__Proposal__c objects
** @returns : nothing
*/
    public void OnBeforeInsert(Apttus_Proposal__Proposal__c[] pApttusProposalList){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeInsert');
        
        // Test classes fix due to required field at schema level
        if(Test.isRunningTest()){
            Contact con;
            for(Apttus_Proposal__Proposal__c proposal : pApttusProposalList){
                con = TestDataSetupUtility.createTestContact(proposal.Apttus_Proposal__Account__c, 'PrimaryBillingTestLastnameOne', 'PrimaryBillingTestFirstnameOne', 'email1@testContact.com');
                con.PrimaryBillingContact__c = true;
            }
            
            insert con;
            
            for(Apttus_Proposal__Proposal__c proposal : pApttusProposalList){
                proposal.BillContact__c = con.Id;
                proposal.PostingContact__c = con.Id;
            }
        }
        
        //Mitali N Appirio T-600146 8/5/17 to bypass VR when Account Status is Bad/Negative
        for(Apttus_Proposal__Proposal__c proposal : pApttusProposalList){
            if(OrderTriggerHandler.ProcessingCreditRequest != null && OrderTriggerHandler.ProcessingCreditRequest == true){
                proposal.Bypass_Credit_Status_Validation__c = true;
            }
        }
        
        
        if (Personal_Settings__c.getInstance().Trigger_Quote__c ==false){
            return; // If triggers are off, then exit the method
        }
        
        
             
        //Skip updating Oppty in Cloning the Proposal
        OpportunityTriggerHandler.SKIP_OPPORTUNITY_UPDATE = true;
        System.debug('[RB] - OnBeforeInsert[67] => pApttusProposalList : ' + pApttusProposalList);
        if(ExecuteTriggers)
        {
            Set<id> setAccountIds = new Set<id>();
            Set<id> setAgencyAccountIds = new Set<id>();
            Map<id, id> mapProposalIdToAgencyAccIds = new Map<Id,Id>();
            //Map<id, id> mapProposalIdToOwnerIds = new Map<Id,Id>();
            for(Apttus_Proposal__Proposal__c proposal : pApttusProposalList){
                
                
                /*
//system.debug('----propFreq ' + proposal.Payment1_Frequency__c);
// Added by Apttus Support || Case : 00204136 || Date : 10-10-2016
//added a flag To Prevent 101 Soql Error, Because when Clone the Quote we dont want to execute all the triggers.added by apttus support on 2016/03/11 || I-221386
if(!String.IsBlank(proposal.Clone_Indicator__c)){
//IsTriggerForCloneProposal = true;
//Utility.ExecuteOpportunityTrigger = false;
//OrderLineItemTriggerHandler.ExecuteTriggers = false;
//OrderTriggerHandler.ExecuteTriggers = false;
//AccountTriggerHandler.ExecuteTriggers = false;
//ApttusProposalTriggerHandler.ExecuteTriggers = false;
}*/
                
                proposal.Quote_Proposal_Cloned_from__c = proposal.Clone_Indicator__c;
                
                //system.debug('[RB] - OnBeforeInsert[74] => proposal.BillContact__c : ' + proposal.BillContact__c);
                //system.debug('[RB] - OnBeforeInsert[75] => proposal.PostingContact__c : ' + proposal.PostingContact__c);
                
                
                if(proposal.Apttus_Proposal__Account__c != null){
                    setAccountIds.add(proposal.Apttus_Proposal__Account__c);
                }
                if(proposal.Agency__c != null)
                {
                    setAccountIds.add(proposal.Agency__c);
                    mapProposalIdToAgencyAccIds.put(proposal.id, proposal.Agency__c);
                    //mapProposalIdToOwnerIds.put(proposal.id, proposal.Owner.id);
                }
            }
            
            
            // create Quote account map
            map<Id, Account> QuoteAccountMap = new map<Id, Account>([SELECT  Id,Payment_Frequency__c,Tan__c,VATNumber__c,ShippingCountry__c,Organization__c,Owner.PositionSalesChannel__c,PricingAccount__c,PaymentDetails__c,
                                                                     PrimaryBillingContact__c, DirectDebit__c,PaymentMethod__c, PaymentTerm__c,PrimarySalesContact__pc,Registration__c,
                                                                     Registration__r.PrimaryBillingAccount__r.PrimaryBillingContact__c, ShippingStreet,
                                                                     ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry
                                                                     FROM Account Where Id IN :setAccountIds]);
            Map<String, String> CountryLanguageNameMap = new Map<String, String>();
            for(LanguageBasedonCountry__c countryLanguage : LanguageBasedonCountry__c.getAll().values()){
                CountryLanguageNameMap.put(countryLanguage.Name, countryLanguage.Language__c);
            }
            
            Map<String, String> UserToQuoteLocationMap = new Map<String, String>();
            for(LocationBasedOnUserLocation__c userToQuoteLocation : LocationBasedOnUserLocation__c.getAll().values()){
                UserToQuoteLocationMap.put(userToQuoteLocation.Name, userToQuoteLocation.Location__c);
            }
            
            //Update tax Number on quote/proposal [I-170041]
            for(Apttus_Proposal__Proposal__c proposal : pApttusProposalList){
                if(proposal.Apttus_Proposal__Account__c != null){
                    proposal.VAT_Number__c = QuoteAccountMap.get(proposal.Apttus_Proposal__Account__c).VATNumber__c;
                }
                
            }
            
            //if(ExecuteTriggers && IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
            Map<ID, Opportunity> opportunityMap = helper.validateQuoteCreateConditions(pApttusProposalList);
            //set defaults Quote Status = 'In Progress' , approval status = NULL, Approval Stage = Draft
            helper.setQuoteDefaults(pApttusProposalList);
            //update the owner in case of GCS opportunity parent
            updateGCSQuoteOwner(pApttusProposalList);
            
            //Validate the Agency Billing Contact; must be a contact or related contact on the Agency
            helper.validateAgencyBillingContact(pApttusProposalList);
            
            //setting of QuoteCreated__c flag when an Apptus_proposal is created
            helper.PopulateQuotePriceList(pApttusProposalList);
            
            // Pass proposal list with QuoteAccountMap
            //system.debug('check' + QuoteAccountMap);
            helper.SetAccountOrganization(pApttusProposalList, QuoteAccountMap);
            
            helper.SetQuoteOwnerMangersOnApttusProposalProposal(pApttusProposalList, null, null);
            // Pass proposal list with QuoteAccountMap
            helper.SetQuotePricingChannelToAccountDefaultPricingChannel(pApttusProposalList,QuoteAccountMap);
            //helper.SetPaymentMethodAndPaymentTerm(pApttusProposalList);
            //helper.populateBillingContactFromAccount(pApttusProposalList);
            helper.populateXcodeFromAccount(pApttusProposalList);
            // Pass proposal list with QuoteAccountMap
            
            helper.setAgencyBillingContactBasedOnAgencyPopulated(pApttusProposalList);
            helper.populateFieldsI(pApttusProposalList);
            helper.CopyPrimaryContactToAPTTSPrimaryContact(pApttusProposalList);
            //Story 539 - Moved to Validation Callback
            //helper.setAssetProducts(pApttusProposalList);
            //Populate the Billing, Posting and Entity ID on the proposal
            populateBillingContact(pApttusProposalList,null);
            // Pass proposal list with QuoteAccountMap
            
            populatePostingContact(pApttusProposalList,null);
            
            // Do not call this method when quote is clone.
            //To Prevent 101 Soql Error, Because when Clone the Quote we dont want to execute all the triggers.added by apttus support on 2016/03/11
            //if(!ApttusProposalTriggerHandler.IsTriggerForCloneProposal){
            
            
            //}
            populateEntityId(pApttusProposalList,null);
            populateBillAndPrimaryAddress(pApttusProposalList,null);
            
            populateTemplateNameAndSigners(pApttusProposalList);
            populateTranslatedPaymentFields(pApttusProposalList);
            // populateFieldsFromPaymentDetails(pApttusProposalList,null);
            // Pass proposal list with QuoteAccountMap
            setProposalOwner(pApttusProposalList,QuoteAccountMap);
            // Pass proposal list with QuoteAccountMap
            UpdateProposalSalesChannel(pApttusProposalList,QuoteAccountMap);
            
            //!Test.isRunningTest() ApexPages != null &&
            if(Test.isRunningTest() || (ApexPages.currentPage() == null ||
                                        (ApexPages.currentPage() != null && !ApexPages.currentPage().getUrl().Contains('ProposalDeepClone')))
              ){
                  populatePaymentMethodAndPaymentTerms(pApttusProposalList,QuoteAccountMap);
                  helper.setPaymentDetailsFromAccount(pApttusProposalList, opportunityMap,QuoteAccountMap);
              }
            
            
            populatePaymentDetailField(pApttusProposalList,null);
            UpdateAgenctBillingContactEmailAddress(pApttusProposalList);
            Map<Id,User> UserIdToUserMap =  helper.UserIdToUsersMap();
            
            //S-317111 Included logic of posting country and selling country to be populated based on agency if exist else from quote account
            for(Apttus_Proposal__Proposal__c proposal : pApttusProposalList){
                //system.debug('[RB] - OnBeforeInsert[146] => proposal.BillingAccount__c : ' + proposal.BillingAccount__c);
                //system.debug('[RB] - OnBeforeInsert[147] => proposal.AgencyBillingContact__c : ' + proposal.AgencyBillingContact__c);
                //system.debug('[RB] - OnBeforeInsert[148] => proposal.BillContact__c : ' + proposal.BillContact__c);
                //system.debug('[RB] - OnBeforeInsert[149] => proposal.PostingContact__c : ' + proposal.PostingContact__c);
                //Added due to I-183651
                //if(proposal.BillingAccount__c == null){
                if(proposal.Agency__c != null){
                    proposal.BillingAccount__c = proposal.Agency__c;
                }else if(proposal.Apttus_Proposal__Account__c != null){
                    proposal.BillingAccount__c = proposal.Apttus_Proposal__Account__c;
                }
                //}
                //if(proposal.BillContact__c == null){
                
                if(proposal.AgencyBillingContact__c != null){
                    proposal.BillContact__c = proposal.AgencyBillingContact__c;
                }else if(proposal.Apttus_Proposal__Account__r.PrimaryBillingContact__c != null){
                    proposal.BillContact__c = proposal.Apttus_Proposal__Account__r.PrimaryBillingContact__c;
                }
                //}
                //set billing address of quote from parent account or agency account
                helper.PopulateBillingAddressAndCommission(pApttusProposalList, null);
                
                if(proposal.BillContact__c == null || proposal.PostingContact__c == null){
                    proposal.adderror('Both Billing and Posting Contact is required when creating proposal : BillContact = '+proposal.BillContact__c + '; PostingContact = ' + proposal.PostingContact__c);
                    return;
                }
                
                
                Account account = new Account();
                
                Opportunity opportunity = opportunityMap.get(proposal.Apttus_Proposal__Opportunity__c);
                Account agencyAccount = null;
                if(opportunity != null) {
                    agencyAccount = opportunity.Agency__r;
                }
                if(agencyAccount != null)
                {
                    proposal.ShippingAddress__c = (String.IsnotBlank(opportunity.Agency__r.ShippingStreet) ? opportunity.Agency__r.ShippingStreet + ', '  : '')
                        + (String.IsnotBlank(opportunity.Agency__r.ShippingCity) ? opportunity.Agency__r.ShippingCity + ', ' : '' )
                        + (String.IsnotBlank(opportunity.Agency__r.ShippingState) ? opportunity.Agency__r.ShippingState + ', '  : '')
                        + (String.IsnotBlank(opportunity.Agency__r.ShippingCountry) ? opportunity.Agency__r.ShippingCountry+  ', '  : '')
                        + account.ShippingPostalCode;
                    proposal.ShippingCity__c = opportunity.Agency__r.ShippingCity;
                    //proposal.Selling_Country__c = proposal.ShippingCountry__c = opportunity.Agency__r.ShippingCountry;
                    // //I-201842- Shipping country not populating
                    proposal.ShippingCountry__c = opportunity.Agency__r.ShippingCountry;
                    proposal.ShippingStateProvince__c = opportunity.Agency__r.ShippingState;
                    proposal.ShippingStreet__c = opportunity.Agency__r.ShippingStreet;
                    proposal.ShippingZipPostalCode__c = opportunity.Agency__r.ShippingPostalCode;
                }
                else if(proposal.Apttus_Proposal__Account__c != NULL)
                {
                    account = QuoteAccountMap.get(proposal.Apttus_Proposal__Account__c);
                    proposal.APTPS_TAN__c = account.Tan__c ;
                    
                    proposal.ShippingAddress__c = (String.IsnotBlank(account.ShippingStreet) ? account.ShippingStreet + ', '  : '')
                        + (String.IsnotBlank(account.ShippingCity) ? account.ShippingCity + ', ' : '' )
                        + (String.IsnotBlank(account.ShippingState) ? account.ShippingState + ', '  : '')
                        + (String.IsnotBlank(account.ShippingCountry) ? account.ShippingCountry+  ', '  : '')
                        + account.ShippingPostalCode;
                    proposal.ShippingCity__c = account.ShippingCity;
                    //proposal.Selling_Country__c = proposal.ShippingCountry__c = account.ShippingCountry;
                    //I-201842- Shipping country not populating
                    proposal.ShippingCountry__c = account.ShippingCountry;
                    proposal.ShippingStateProvince__c = account.ShippingState;
                    proposal.ShippingStreet__c = account.ShippingStreet;
                    proposal.ShippingZipPostalCode__c = account.ShippingPostalCode;
                }
                
                User currentUser = UserIdToUserMap.get(proposal.OwnerId);
                if(UserToQuoteLocationMap.get(currentUser.Location__c) != null && !proposal.MidContract_Proposal__c && !proposal.Upgrade_Proposal__c     && !proposal.Conversion_Proposal__c && !IsTriggerForCloneProposal)//I-214771 changes
                    proposal.Selling_Country__c = UserToQuoteLocationMap.get(currentUser.Location__c);
                
                //proposal.Selling_Country__c = currentUser.Location__c;
                
                if(CountryLanguageNameMap.get(proposal.Selling_Country__c) != null && !IsTriggerForCloneProposal)
                    proposal.Language__c = CountryLanguageNameMap.get(proposal.Selling_Country__c);
                
                
                //Added by -- Prashant Gupta, Appirio, S-449975 18/04/17
                //system.assert(False,'Code reached here ' + proposal.APTPS_Contract_Start_Date__c);
                if(proposal.APTPS_Contract_Start_Date__c==null && proposal.ContractEndDate__c==null){
                    proposal.APTPS_Contract_Start_Date__c = proposal.Earliest_Start_Date__c;
                    proposal.ContractEndDate__c = proposal.Latest_End_Date__c;
                }else{
                    ExceptionLog__c newException = new ExceptionLog__c();
                    newException.Record_ID__c = proposal.id;
                    newException.TypeOfException__c = 'WARNING';
                    newException.ObjectName__c = 'Quote/Proposal';
                    newException.Exception__c = 'Following Date fields : ';
                    if(proposal.APTPS_Contract_Start_Date__c!=null){
                        newException.Exception__c += '\"Contract Start Date (APTPS_Contract_Start_Date__c)\"';
                    }
                    if(proposal.ContractEndDate__c!=null){
                        newException.Exception__c += '\"Contract End Date (ContractEndDate__c)\"';
                    }
                    newException.Exception__c += ' were overriden';
                    try{
                        insert newException;
                    }catch(exception e){
                        system.debug(LoggingLevel.ERROR, e.getMessage());
                    }
                }
                //End
                
            }
            helper.ValidateOwnerSalesChannel(pApttusProposalList);
            helper.populateBillingContactFromAccount(pApttusProposalList);
            helper.updateDirectDebitDiscountFlag(pApttusProposalList, null); //I-220832
            
        }
        
        //Commented By Viraj To reduce the CPU limt
        /*for (Apttus_Proposal__Proposal__c prop : pApttusProposalList){
system.debug('----OnBeforeInsert AFTER ' + prop.Payment1_Frequency__c);
}*/
    }
    //From Apttus Package When do the clone it will update the old recrod also and because of that it will execute all the triggers.So it casue an SOQL Issue. To prevent that
    //We first get the Page parameters and check does this trigger call from the clone page and if yes then dont execute the triggr for the old recrod.
    //I-221386 || Modified By Apttus Support - Viraj|| Date: 2016-04-11 Commented Because right now not needed
    /*Public static void PreventTriggerOnCloneProposal(Apttus_Proposal__Proposal__c[] pUpdatedApttusProposalList, map<Id, Apttus_Proposal__Proposal__c> pOldApttusProposalMap){
try{
String queryString ='';
queryString = ApexPages.currentPage().getParameters().get('id');
String currentPageURL = ApexPages.currentPage().getUrl();
System.debug('queryString' + queryString);
System.debug('currentPageURL' + currentPageURL);

for(Apttus_Proposal__Proposal__c objProposal : pUpdatedApttusProposalList){
if(objProposal.Id == queryString && currentPageURL.Contains('ProposalDeepClone')){
//if(objProposal.Id == queryString && currentPageURL.Contains('########')){
IsTriggerForCloneProposal = true;
Utility.ExecuteOpportunityTrigger = false;
//ApttusProposalTriggerHandler.ExecuteTriggers = false;
}
}
}Catch(exception ex){
IsTriggerForCloneProposal = false;
}
}*/
    
    // T-421958 : Default values upon Quote/Proposal creation
    
    public void populatePaymentMethodAndPaymentTerms(Apttus_Proposal__Proposal__c[] pNewApttusProposal,  map<Id, Account> QuoteAccountMap){
        
        Map<String, String> CountryCodeNameMap = new Map<String, String>();
        for(CountryCode__c countryCode : CountryCode__c.getAll().values()){
            CountryCodeNameMap.put(countryCode.Name, countryCode.Country_Code__c);
        }
        
        map<string,string>  countryMap = populateEuropeCountryMap();
        
        for(Apttus_Proposal__Proposal__c prop : pNewApttusProposal) {
            if(prop.BIAUsage_Proposal__c == true){
                Continue;
            }
            Account acc = null;
            if(QuoteAccountMap.containsKey(prop.Apttus_Proposal__Account__c)){
                acc = QuoteAccountMap.get(prop.Apttus_Proposal__Account__c);
                //  system.debug('==acc=='+acc);
                prop.Payment_Method1__c = acc.PaymentMethod__c;
                prop.Payment1_Term__c = acc.PaymentTerm__c;
                prop.Payment1_Frequency__c = acc.Payment_Frequency__c;
            }
            
            if(prop.Payment_Method1__c == null && prop.Payment1_Term__c == null){
                if(acc != null && (acc.Organization__c == 'North America' /*|| acc.Organization__c == 'Asia Pacific'*/ ) ){
                    //system.debug('----BEFORE1 freq ' + prop.Payment1_Frequency__c + ' method ' + prop.Payment_Method1__c + ' term ' + prop.Payment1_Term__c);
                    prop.Payment_Method1__c = 'Invoice';
                    prop.Payment1_Term__c = 'Net 30';
                    prop.Payment1_Frequency__c = 'Single Payment';
                    //system.debug('----AFTER1 freq ' + prop.Payment1_Frequency__c + ' method ' + prop.Payment_Method1__c + ' term ' + prop.Payment1_Term__c);
                }
                // Changes Start : By Gaurav Gupta on 21 December 2016 S-445806
                if(acc != null && (/*acc.Organization__c == 'North America' || */ acc.Organization__c == 'Asia Pacific' )){
                    //system.debug('----BEFORE1 freq ' + prop.Payment1_Frequency__c + ' method ' + prop.Payment_Method1__c + ' term ' + prop.Payment1_Term__c);
                    prop.Payment_Method1__c = 'Invoice';
                    prop.Payment1_Term__c = 'Net 30';
                    prop.Payment1_Frequency__c = 'Invoice';
                    //system.debug('----AFTER1 freq ' + prop.Payment1_Frequency__c + ' method ' + prop.Payment_Method1__c + ' term ' + prop.Payment1_Term__c);
                }
                
                // Changes End : By Gaurav Gupta on 21 December 2016 S-445806
            }
            
            if(prop.Payment_Method1__c == null && prop.Payment1_Term__c == null){
                if(acc != null && acc.Organization__c == 'Europe') {
                    
                    if(acc != null && acc.DirectDebit__c){
                        prop.Payment_Method1__c = 'EU Direct Debit';
                    }
                    else {
                        prop.Payment_Method1__c = 'Invoice';
                    }
                    
                    prop.Payment1_Frequency__c = 'Single Invoice';
                    
                    //system.debug('=====prop.Payment1_Term__c==for North america==='+prop.Payment1_Term__c);
                    //system.debug('=====prop.Payment_Method1__c==='+prop.Payment_Method1__c);
                    //system.debug('=====prop.ShippingCountry__c==='+acc.ShippingCountry__c);
                    
                    if(acc != null  && acc.ShippingCountry__c != null && CountryCodeNameMap.containsKey(acc.ShippingCountry__c)){
                        string countryCode = CountryCodeNameMap.get(acc.ShippingCountry__c);
                        //system.debug('=====countryCode==='+countryCode);
                        if(countryCode != null &&  countryMap != null && countryMap.containsKey(countryCode)) {
                            string term = countryMap.get(countryCode);
                            //system.debug('=====term==='+term);
                            if(term != null){
                                prop.Payment1_Term__c = 'Net ' + term;
                                //system.debug('=====prop.Payment1_Term__c==='+prop.Payment1_Term__c);
                            }
                        }
                    }
                    
                } // End of Europe Account Org
            }
        } // For loop
        
    }
    
    
    // Populated as per given google sheet in T-421958
    public  map<string,string>  populateEuropeCountryMap(){
        map<string,string>  mapCountry = new map<string,string>();
        mapCountry.put('AT', '15');
        mapCountry.put('BE', '30');
        mapCountry.put('CH', '30');
        mapCountry.put('DE', '15');
        mapCountry.put('DK', '20');
        mapCountry.put('ES', '30');
        mapCountry.put('FR', '30');
        mapCountry.put('IE', '30');
        mapCountry.put('IT', '30');
        mapCountry.put('LU', '30');
        mapCountry.put('NL', '30');
        mapCountry.put('NO', '20');
        mapCountry.put('SE', '20');
        // For UK
        mapCountry.put('GB', '30');
        return mapCountry;
        
    }
    
    
    
    
    /*
** @author : Cloud Sherpas Inc.
** @date : 04/09/2014
** @description :  this method handles the 'after insert' event for the trigger; it's purpose is to ...
** @paramaters : an array of Apttus_Proposal__Proposal__c objects
** @returns : nothing
*/
    public void OnAfterInsert(Apttus_Proposal__Proposal__c[] pNewApttusProposal, map<Id, Apttus_Proposal__Proposal__c> pOldApttusProposalMap,map<Id, Apttus_Proposal__Proposal__c> pNewApttusProposalMap){
        if (Personal_Settings__c.getInstance().Trigger_Quote__c ==false){
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterInsert');
        
        // system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        //Skip updating Oppty in Cloning the Proposal
        OpportunityTriggerHandler.SKIP_OPPORTUNITY_UPDATE = true;
        
        system.debug('====value of ExecuteTriggers='+ExecuteTriggers);
        try{
            //if(ExecuteTriggers && IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
            if(ExecuteTriggers){
                //setting of QuoteCreated__c flag when an Apptus_proposal is created
                helper.UpdateQuoteCreatedOfOpportunity(pNewApttusProposal);
                helper.updateOpportunity(pNewApttusProposal, pOldApttusProposalMap, 'Insert');
                helper.updateOrderAgencyBillContact(pNewApttusProposal, pOldApttusProposalMap, pNewApttusProposalMap);
                helper.setRelatedProposalNonPrimary(pNewApttusProposal, pOldApttusProposalMap, false);
                helper.getQuoteTaxOnFinalize(pNewApttusProposal, pOldApttusProposalMap, false);
                /*
note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
and call the methods from handler.
*/
            }
        }
        catch(BaseApplicationException bae){
            throw bae;
        }
        catch(Exception ex){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }
        // update by Vivek Ojha for T-434694
        populateOpportunityAmount(pNewApttusProposal);
        
        
    }
    
    /*
** @author : Cloud Sherpas Inc.
** @date : 04/09/2014
** @description :  this method handles the 'before Update' event for the trigger; it's purpose is to ...
** @paramaters : an array of Apttus_Proposal__Proposal__c objects
** @returns : nothing
*/
    public void OnBeforeUpdate( Apttus_Proposal__Proposal__c[] pOldApttusProposalList, Apttus_Proposal__Proposal__c[] pUpdatedApttusProposalList, map<Id, Apttus_Proposal__Proposal__c> pUpdatedApttusProposalMap, map<Id, Apttus_Proposal__Proposal__c> pOldApttusProposalMap){
        
         //Mitali N Appirio T-600146 8/5/17 to bypass VR when Account Status is Bad/Negative
        for (Apttus_Proposal__Proposal__c prop : pUpdatedApttusProposalList){
            if(OrderTriggerHandler.ProcessingCreditRequest != null && OrderTriggerHandler.ProcessingCreditRequest == true){
                 prop.Bypass_Credit_Status_Validation__c = true;
             }
        }
        
        if (Personal_Settings__c.getInstance().Trigger_Quote__c ==false){
            return; // If triggers are off, then exit the method
        }
        
        // When proposal is updated from opportunity for the story S-418868 don't need to call the proposal trigger. || Modified By - Appttus Support - Viraj Rana|| Date: 2016-10-11
        if(ExecuteTriggersFromOpportunityUpdate == false){
            return;
        }
        
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeUpdate');
        //system.debug('Rub Count BU ' + RunCountBU);
        RunCountBU++;
        // system.debug('OnBeforeUpdate RunCountBU='+ApttusProposalTriggerHandler.RunCountBU + ' PreventRecursion='+PreventRecursion);
        if(RunCountBU > 1 && PreventRecursion){
            return;
        }
        
        //Commented By Viraj rana To Reduce the CPU Time
        /*for (Apttus_Proposal__Proposal__c prop : pUpdatedApttusProposalList){
system.debug('^^^ OnBeforeUpdate Starting ID=' + prop.Id + ', AgencyIO__c=' + prop.AgencyIO__c + ', OLD AgencyIO__c=' + pOldApttusProposalMap.get(prop.id).AgencyIO__c);
system.debug('^^^ Is owner Changing? owner: ' + prop.OwnerId + ' old owner: ' + pOldApttusProposalMap.get(prop.id).OwnerId);
}*/
        helper.SetQuoteOwnerMangersOnApttusProposalProposal(pUpdatedApttusProposalList, pUpdatedApttusProposalMap, pOldApttusProposalMap);
        
        // try{
        if(ExecuteTriggers){
            //if(ExecuteTriggers && IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
            //Validate the Agency Billing Contact; must be a contact or related contact on the Agency
            helper.validateAgencyBillingContact(pUpdatedApttusProposalList);
            
            helper.updateQuotePriceListCurrency(pUpdatedApttusProposalList, pOldApttusProposalMap);
            //helper.Custom_field_set_proposal_NSSA_approvals(pUpdatedApttusProposalList);
            populateEntityId(pUpdatedApttusProposalList,pOldApttusProposalMap);
            helper.populatePaymentDetailForPaypalPaid(pUpdatedApttusProposalList,pOldApttusProposalMap);
            populatePaymentDetailField(pUpdatedApttusProposalList,pOldApttusProposalMap);
            // populateFieldsFromPaymentDetails(pUpdatedApttusProposalList,pOldApttusProposalMap);
            populateBillAndPrimaryAddress(pUpdatedApttusProposalList,pUpdatedApttusProposalMap);
            helper.proposalTermsandcondition(pUpdatedApttusProposalList, pOldApttusProposalMap);
            //helper.PreventUpdateOfBilling(pOldApttusProposalMap, pUpdatedApttusProposalList);
            
            helper.restrictEditability(pUpdatedApttusProposalMap, pOldApttusProposalMap);
            helper.checkMinimumInstallment(pUpdatedApttusProposalList,pOldApttusProposalMap);
            helper.populateFieldsI(pUpdatedApttusProposalList);
            //populateBillingContact(pUpdatedApttusProposalList,pOldApttusProposalMap);  --- Sylvester Agyen - commented out I-211764 (to allow changing billing contact)
            //Added
            populatePostingContact(pUpdatedApttusProposalList,pOldApttusProposalMap);
            populateTemplateNameAndSigners(pUpdatedApttusProposalList);
            populateTranslatedPaymentFields(pUpdatedApttusProposalList);
            helper.setAgencyBillingContactBasedOnAgencyPopulated(pUpdatedApttusProposalList);
            //helper.PopulateBillingContactDetails(pUpdatedApttusProposalList, pOldApttusProposalMap);
            List<Apttus_Proposal__Proposal__c> QuoteProposalList = new List<Apttus_Proposal__Proposal__c>();
            for(Apttus_Proposal__Proposal__c app: pUpdatedApttusProposalList){
                if(app.Order_Type__c == 'Conversion' && ((app.QuoteStatus__c != pOldApttusProposalMap.get(app.Id).QuoteStatus__c) && (app.QuoteStatus__c == 'Accepted Online' || app.QuoteStatus__c == 'Accepted Offline'))){
                    QuoteProposalList.add(app);
                }
            }
            //system.assert(false , QuoteProposalList);
            if(!QuoteProposalList.isEmpty()){
                helper.productConversion(QuoteProposalList);
            }
            
            //  system.debug('Apttus Proposal Handler RunCountBU: ' + RunCountBU);
            
            UpdateAgenctBillingContactEmailAddress(pUpdatedApttusProposalList);
            helper.PopulateLineItemsStartDateFromRevisedDate(pUpdatedApttusProposalList,pOldApttusProposalMap);
            helper.UpdateStateandCountry(pUpdatedApttusProposalList);
            helper.updateAccountBillingFromProposal(pUpdatedApttusProposalList, pOldApttusProposalMap);
        }
        //Added due to I-183651
        for(Apttus_Proposal__Proposal__c proposal: pUpdatedApttusProposalList){
            //If the billing account is changed we already have the code to populate the Bill contact
            //if(proposal.BillingAccount__c == null){  I-211764
            
            if(proposal.Agency__c != null && proposal.Agency__c != pOldApttusProposalMap.get(proposal.Id).Agency__c) {
                if(proposal.Agency__c != null){
                    proposal.BillingAccount__c = proposal.Agency__c;
                }else if(proposal.Apttus_Proposal__Account__c != null){
                    proposal.BillingAccount__c = proposal.Apttus_Proposal__Account__c;
                }
                
                
                
                if(proposal.AgencyBillingContact__c != null){
                    proposal.BillContact__c = proposal.AgencyBillingContact__c;
                }else if(proposal.Apttus_Proposal__Account__r.PrimaryBillingContact__c != null ){
                    proposal.BillContact__c = proposal.Apttus_Proposal__Account__r.PrimaryBillingContact__c;
                }
            }
            
            
            // }
        }
        //Sylvester - commenting out - I-211764
        helper.PopulateBillingAddressAndCommission(pUpdatedApttusProposalList, pOldApttusProposalMap);
        
        helper.populateBillingContactFromAccount(pUpdatedApttusProposalList);
        helper.updateDirectDebitDiscountFlag(pUpdatedApttusProposalList, pOldApttusProposalMap); //I-220832
        //}
        /*}
catch(BaseApplicationException bae){
throw bae;
}
catch(Exception ex){
throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
}*/
        
        //Commented By Viraj Rana To reduce the CPU Limit
        /*for (Apttus_Proposal__Proposal__c prop : pUpdatedApttusProposalList){
system.debug('^^^ OnBeforeUpdate Ending ID=' + prop.Id + ', AgencyIO__c=' + prop.AgencyIO__c + ', OLD AgencyIO__c=' + pOldApttusProposalMap.get(prop.id).AgencyIO__c + 'payment frequency new ' + prop.Payment1_Frequency__c + 'payment frequency old ' + pOldApttusProposalMap.get(prop.Id).Payment1_Frequency__c);
}*/
    }
    
    /*
** @author : Appirio
** @date : 28/07/2015
** @description :  Updates the Agency Billing Contact Email Address field on Quote
** @paramaters : an array of Apttus_Proposal__Proposal__c objects
** @returns : nothing
*/
    
    private void UpdateAgenctBillingContactEmailAddress(Apttus_Proposal__Proposal__c[] pNewApttusProposal){
        set<id> setContactIds = new set<id>();
        for(Apttus_Proposal__Proposal__c prposal : pNewApttusProposal){
            setContactIds .add(prposal.AgencyBillingContact__c);
        }
        
        Map<id , contact> mapAgencyContacts = new map<id,contact>([select email from contact where id IN :setContactIds  ]);
        for(Apttus_Proposal__Proposal__c prposal : pNewApttusProposal){
            if(mapAgencyContacts.containskey(prposal.AgencyBillingContact__c))
                prposal.Agency_Billing_Contact_Email_Address__c = mapAgencyContacts.get(prposal.AgencyBillingContact__c).email;
            else
                prposal.Agency_Billing_Contact_Email_Address__c = '';
        }
        
    }
    
    /*
** @author : Cloud Sherpas Inc.
** @date : 04/09/2014
** @description :  this method handles the 'after update' event for the trigger; it's purpose is to ...
** @paramaters : an array of Apttus_Proposal__Proposal__c objects
** @returns : nothing
*/
    public void OnAfterUpdate(Apttus_Proposal__Proposal__c[] pNewApttusProposal, map<Id, Apttus_Proposal__Proposal__c> pOldApttusProposalMap,map<Id, Apttus_Proposal__Proposal__c> pNewApttusProposalMap){
        if (Personal_Settings__c.getInstance().Trigger_Quote__c ==false){
            return; // If triggers are off, then exit the method
        }
        
        // When proposal is updated from opportunity for the story S-418868 don't need to call the proposal trigger. || Modified By - Appttus Support - Viraj Rana|| Date: 2016-10-11
        if(ExecuteTriggersFromOpportunityUpdate == false){
            return;
        }
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterUpdate');
        RunCountAU++;
        // populateEntityId(pNewApttusProposalMap,pOldApttusProposalMap);
        //system.debug('MS Test OnAfterUpdate RunCountAU='+RunCountAU + ' PreventRecursion='+PreventRecursion);
        //system.debug('creditrequestCount'+ creditrequestCount);
        //system.debug('pNewApttusProposal.APTS_Quote_Type__c'+ pNewApttusProposal[0].APTS_Quote_Type__c);
        //system.debug('pNewApttusProposal.Apttus_QPConfig__ConfigurationFinalizedDate__c'+ pNewApttusProposal[0].Apttus_QPConfig__ConfigurationFinalizedDate__c);
        //system.debug('pOldApttusProposalMap.get(prop.id).Apttus_QPConfig__ConfigurationFinalizedDate__c'+ pOldApttusProposalMap.get(pNewApttusProposal[0].id).Apttus_QPConfig__ConfigurationFinalizedDate__c);
        
        //Commented By Viraj Rana To reduce the CPU Limit
        /*for (Apttus_Proposal__Proposal__c prop : pNewApttusProposal){
system.debug('^^^ OnAfterUpdate Starting ID=' + prop.Id + ', AgencyIO__c=' + prop.AgencyIO__c + ', OLD AgencyIO__c=' + pOldApttusProposalMap.get(prop.id).AgencyIO__c);
}*/
        
        If(creditrequestCount < 1 )
        {
            
            If (helper.GenerateCreditRequest(pNewApttusProposal, pOldApttusProposalMap))
            {
                creditrequestCount++;
            }
        }
        if(RunCountAU > 2 && PreventRecursion){
            return;
        }
        if(RunCountAU > 1 && PreventRecursion){
            helper.setAgencyIOonOrder(pNewApttusProposal, pOldApttusProposalMap); //I-203835 need to run this even if other methods are bypassed
            helper.setRelatedProposalNonPrimary(pNewApttusProposal, pOldApttusProposalMap, true); //I-211343 changes
            //system.debug('ApttusProposalTriggerHandler Exiting OnAfterUpdate: RunCountAU=' + RunCountAU + ', PreventRecursion=' + PreventRecursion);
            return;
        }
        //try{
        //if(ExecuteTriggers && IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
        //setting of QuoteCreated__c flag when an Apptus_proposal is created
        
        if(ExecuteTriggers){
            //helper.PopulateLineItemsStartDateFromRevisedDate(pNewApttusProposal,pOldApttusProposalMap);//added temporarily
            helper.updateOpportunity(pNewApttusProposal, pOldApttusProposalMap, 'Update');
            
            //helper.setPaymentDetailsOfAccountFromProposal(pNewApttusProposal, pOldApttusProposalMap);
            
            // helper.SetPrimaryQuoteTotalsMatchToOppty(pNewApttusProposal, pOldApttusProposalMap);
            //helper.GenerateCreditRequest(pNewApttusProposal, pOldApttusProposalMap);
            // helper.updateAccountBillingFromProposal(pNewApttusProposal, pOldApttusProposalMap);
            
            //  helper.setMSASignedAccountFromProposal(pNewApttusProposal, pOldApttusProposalMap); // ** @Story :  S-328762
            
            //AvalaraModel.ProposalProcessTaxRate(pNewApttusProposal, pOldApttusProposalMap);
            helper.CreateAssetTrigger(pNewApttusProposal, pOldApttusProposalMap);
            helper.updateOrderAgencyBillContact(pNewApttusProposal, pOldApttusProposalMap, pNewApttusProposalMap);
            helper.SetAutoApprovalProcessList(pNewApttusProposal, pOldApttusProposalMap);
            //helper.setRelatedProposalNonPrimary(pNewApttusProposal, pOldApttusProposalMap, true);
            helper.getQuoteTaxOnFinalize(pNewApttusProposal, pOldApttusProposalMap, true);
            
            /*
note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
and call the methods from handler.
*/
            
            helper.SetQuoteStatusWhenFinalize(pNewApttusProposal,  pOldApttusProposalMap);
            updateOrdersFormulaFields(pOldApttusProposalMap , pNewApttusProposalMap);
            updateOpportunityStage(pNewApttusProposal, pOldApttusProposalMap );
            helper.updateXcodeOnOrderLineItem(pNewApttusProposal, pOldApttusProposalMap);
            //helper.updateContactFromProposal(pNewApttusProposal, pOldApttusProposalMap);
            
            helper.setAgencyIOonOrder(pNewApttusProposal, pOldApttusProposalMap);
            helper.UpdateConfigurationLineItemAgencyCommissionValue(pNewApttusProposal, pOldApttusProposalMap,pNewApttusProposalMap);
        }
        // update by Vivek Ojha for T-434694
        
        populateOpportunityAmount(pNewApttusProposal);
        //}
        /*}
catch(BaseApplicationException bae){
throw bae;
}
catch(Exception ex){
throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
}*/
        //Commented By Viraj Rana To reduce the CPU Limit
        /*for (Apttus_Proposal__Proposal__c prop : pNewApttusProposal){
system.debug('^^^ OnAfterUpdate Ending ID=' + prop.Id + ', AgencyIO__c=' + prop.AgencyIO__c + ', OLD AgencyIO__c=' + pOldApttusProposalMap.get(prop.id).AgencyIO__c + 'payment frequency new ' + prop.Payment1_Frequency__c + 'payment frequency old ' + pOldApttusProposalMap.get(prop.Id).Payment1_Frequency__c);
}*/
    }
    
    
    /*
Update the stage of opportunity to 'Stage 3 - Quote' When Quote has been Generated
*/
    public void updateOpportunityStage(List<Apttus_Proposal__Proposal__c> proposalList,  map<Id, Apttus_Proposal__Proposal__c> oldMap){
        system.debug('**** Inside ApttusProposalTriggerHandler.updateOpportunityStage ****');
        set<Id> oppIds = new set<Id>();
        List<Opportunity> oppToUpdate = new List<Opportunity>();
        //Added by -- Prashant Gupta, Appirio, S-473142 03/08/17
        Map<id,Apttus_Proposal__Proposal__c> oppVsProposalMap = new Map<id,Apttus_Proposal__Proposal__c>();
        //End
        for(Apttus_Proposal__Proposal__c proposal : proposalList){
            if(proposal.Apttus_Proposal__Approval_Stage__c == 'Generated'
               && proposal.OpportunityID__c != null
               && proposal.Apttus_Proposal__Approval_Stage__c != oldMap.get(proposal.Id).Apttus_Proposal__Approval_Stage__c ){
                   
                   oppIds.add(proposal.OpportunityID__c);
                   //Added by -- Prashant Gupta, Appirio, S-473142 03/08/17
                   oppVsProposalMap.put(proposal.OpportunityID__c,proposal);
                   //End
               }
        }
        //4/29/16 - Sly added more stagename checks to prevent this from updating during echosign processes
        //sberron - 11/08/16 - S-447749. Removed 'ReadyForProcessing__c = false' in below SOQL query.
        for(Opportunity opp : [ SELECT Id, StageName,Skip_Stage_Validation__c,ReadyForProcessing__c  FROM Opportunity WHERE Id IN :oppIds and StageName != 'Stage 3 - Quote']){
            //system.debug('----Before ' + opp.StageName + ' ----');
            if(opp.StageName != 'Stage 3 - Quote' || opp.StageName != 'Stage 4 - Won' || opp.StageName != 'Stage 5 - Verified by Finance' || opp.StageName != 'Closed Lost' || opp.StageName != 'Rejected'
              ){
                  
                  opp.StageName  = 'Stage 3 - Quote';
                  opp.Skip_Stage_Validation__c = true;
                  //system.debug('----After ' + opp.StageName + ' ----');
                  
                  //Added by -- Prashant Gupta, Appirio, S-473142 03/08/17
                  /*system.debug('++Difference in months Between, Earliest Start Date and Latest End Date++' + oppVsProposalMap.get(opp.id).Earliest_Start_Date__c.monthsBetween(oppVsProposalMap.get(opp.id).Latest_End_Date__c));
                    system.debug('++Earliest Start Date++' + oppVsProposalMap.get(opp.id).Earliest_Start_Date__c + '++Last End Date++' + oppVsProposalMap.get(opp.id).Latest_End_Date__c);
                    if(oppVsProposalMap.get(opp.id).Earliest_Start_Date__c.monthsBetween(oppVsProposalMap.get(opp.id).Latest_End_Date__c)>=15){
                    opp.MultiYearDeal__c = true;
                    }
                    //End */
                  //Added Check for Null Values by Mitali N Appirio , S-434452  5/5/17
                  if(oppVsProposalMap.containsKey(opp.id)){
                      if(oppVsProposalMap.get(opp.id).Earliest_Start_Date__c != null && oppVsProposalMap.get(opp.id).Latest_End_Date__c != null){
                          if(oppVsProposalMap.get(opp.id).Earliest_Start_Date__c.monthsBetween(oppVsProposalMap.get(opp.id).Latest_End_Date__c)>=15){
                              opp.MultiYearDeal__c = true;
                          }
                      }
                  }
                  oppToUpdate.add(opp);
              }
        }
        
        if(!oppToUpdate.isEmpty()){
            system.debug('Updating '+oppToUpdate.size()+' opportunity to set Stage to 3 with Skip_Stage_Validation__c = true');
            update oppToUpdate;
            /*JFreese Appirio I-263484 Suppressing this in favor of the workflow created for I-263651,
because if the stageName is changed to BIA/Usage or Contingent by respective workflows,
this update will try to set it back to Stage 3 with Skip_Stage_Validation__c = false,
throwing the VR Opportunity_Stage_Not_Editable_by_Rep.
for(Opportunity opp : oppToUpdate){
opp.Skip_Stage_Validation__c = false;
}
system.debug('Re-updating opportunity to set Skip_Stage_Validation__c = false, stageName = ');
update oppToUpdate;*/
            
        }
        
    }
    
    
    
    
    
    /*
** @author : Cloud Sherpas Inc.
** @date : 03/07/2014
** @description :  this method handles the 'after delete' event for the trigger; it's purpose is to ...
** @paramaters : an array of Apttus_Proposal__Proposal__c objects
** @returns : nothing
*/
    public void OnAfterDelete(Apttus_Proposal__Proposal__c[] pApttusProposal){
        if (Personal_Settings__c.getInstance().Trigger_Quote__c ==false){
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterDlete');
        // system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        try{
            if(ExecuteTriggers && IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                helper.updateOpportunity(pApttusProposal, null, 'Delete');
                //unsetting of QuoteCreated__c flag when an Apptus_proposal is deleted
                //helper.UpdateQuoteCreatedOfOpportunity(pApttusProposal);
                /*
note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
and call the methods from handler.
*/
            }
        }
        catch(BaseApplicationException bae){
            throw bae;
        }
        catch(Exception ex){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }
    }
    
    
    
    /*
** @author : Appirio, Inc.
** @date : 08/06/2015
** @story : S-323564
** @element : T-408279
** @description : populate Billing Contact.
** @paramaters : List of Orders
** @returns : nothing
*/
    private void populateBillingContact(List<Apttus_Proposal__Proposal__c> pApttusProposalList ,Map<Id,Apttus_Proposal__Proposal__c> oldpApttusProposalMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populateBillingContact');
        try{
            set<Id> QuoteAccountId = new Set<Id>();
            set<Id> contactIds = new set<Id>();
            Boolean isUpdate = false;
            
            if(oldpApttusProposalMap != null)
                isUpdate = true;
            
            for(Apttus_Proposal__Proposal__c quote : pApttusProposalList){
                
                if(!isUpdate ){
                    
                    QuoteAccountId.add(quote.BillingAccount__c);
                }
                else if (isUpdate && quote.BillingAccount__c!= oldpApttusProposalMap.get(quote.id).BillingAccount__c){
                    
                    QuoteAccountId.add(quote.BillingAccount__c);
                }
            }
            
            List< AccountContactAssociation__c > relatedAccountContact = [select Contact__c ,
                                                                          Account__c from AccountContactAssociation__c
                                                                          where Account__c IN: QuoteAccountId
                                                                          and Primary_Billing_Contact__c= true];
            
            
            Map<Id, Account> RegistrationAccountDetails = new Map<Id,Account>([SELECT Id,Name,PrimaryBillingContact__pc,Registration__c,PrimaryBillingContact__r.LastName,
                                                                               PrimaryBillingContact__r.FirstName,PrimaryBillingContact__c,
                                                                               Registration__r.PrimaryBillingAccount__r.PrimaryBillingContact__c,
                                                                               Registration__r.PrimaryBillingAccount__r.PrimaryBillingContact__r.FirstName,
                                                                               Registration__r.PrimaryBillingAccount__r.PrimaryBillingContact__r.LastName
                                                                               FROM Account WHERE Id IN: QuoteAccountId]);
            if(!RegistrationAccountDetails.isEmpty()){
                
                for(Apttus_Proposal__Proposal__c quote : pApttusProposalList){
                    //system.debug('**RegistrationAccountDetails.get(quote.Apttus_Proposal__Account__c).Registration__c**' +RegistrationAccountDetails.get(quote.Apttus_Proposal__Account__c).Registration__c);
                    if(quote.BillingAccount__c!= null ){
                        //system.debug('^^^êntry1^^^');
                        quote.BillContact__c = RegistrationAccountDetails.get(quote.BillingAccount__c).PrimaryBillingContact__c;
                        //I-191155 Jeff L moving this populating First Name and Last Name into a formula field
                        /*quote.Billing_Contact_First_Name__c = RegistrationAccountDetails.get(quote.BillingAccount__c).PrimaryBillingContact__r.FirstName;
quote.Billing_Contact_Last_Name__c = RegistrationAccountDetails.get(quote.BillingAccount__c).PrimaryBillingContact__r.LastName;
// Populate Billing Contact First Name and Last name
if(quote.BillContact__c != null){
quote.Billing_Contact_First_Name__c = RegistrationAccountDetails.get(quote.BillingAccount__c).PrimaryBillingContact__r.FirstName;
quote.Billing_Contact_Last_Name__c = RegistrationAccountDetails.get(quote.BillingAccount__c).PrimaryBillingContact__r.LastName;

}*/
                        
                        
                    }
                    if(quote.BillContact__c == null && relatedAccountContact.isEmpty() == false)
                        quote.BillContact__c = relatedAccountContact [0].Contact__c ;
                    /* else{
quote.BillContact__c = RegistrationAccountDetails.get(quote.Apttus_Proposal__Account__c).Registration__r.PrimaryBillingAccount__r.PrimaryBillingContact__c;
system.debug('Check^^^^^^^^^^^' + RegistrationAccountDetails.get(quote.Apttus_Proposal__Account__c).Registration__r.PrimaryBillingAccount__r.PrimaryBillingContact__c);
// Populate Billing Contact First Name and Last name
if(quote.BillContact__c != null){
quote.Billing_Contact_First_Name__c = RegistrationAccountDetails.get(quote.Apttus_Proposal__Account__c).Registration__r.PrimaryBillingAccount__r.PrimaryBillingContact__r.FirstName;
quote.Billing_Contact_Last_Name__c = RegistrationAccountDetails.get(quote.Apttus_Proposal__Account__c).Registration__r.PrimaryBillingAccount__r.PrimaryBillingContact__r.LastName;

}
} */
                    
                    
                }
                
            }
            
        }catch(Exception e){
            ExceptionLog.add('Exception', 'ApttusProposalTrigger', 'populateBillingContact', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to populate BillingContact.'+e.getMessage() ,e);
        }
    }
    
    /*------------------------------------------------------------------------------

Author     :   Jyoti Agarwal
Description:   Populates Enetity field on Quote with related account's entity Id
Task Reference: T-409319

<Date>                 <Name>          <Desc with task/Issue#>

11 June 2015          Jyoti Agarwal     Created(T-409319)
------------------------------------------------------------------------------*/
    
    private static void populateEntityId (List<Apttus_Proposal__Proposal__c> pNewApttusProposalList,Map<Id,Apttus_Proposal__Proposal__c> pOldApttusProposalMap){
        
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> apttusIdSet = new Set<Id>();
        Map<Id,Id> apttusIdToAcccountIdMap = new Map<Id,Id>();
        Map<Id,Id> accountIdToEntityIdMap = new Map<Id,Id>();
        List<Apttus_Proposal__Proposal__c> apttusLst = new List<Apttus_Proposal__Proposal__c>();
        List<Apttus_Proposal__Proposal__c> apttusLstToProcess = new List<Apttus_Proposal__Proposal__c>();
        Boolean isUpdate = pOldApttusProposalMap != null ? true : false;
        
        // to fetch account ids for Inserted/updated Quote
        if(pNewApttusProposalList!=null){
            for(Apttus_Proposal__Proposal__c Apttus : pNewApttusProposalList){
                
                if(!isUpdate || Apttus.Apttus_Proposal__Account__c != pOldApttusProposalMap.get(Apttus.Id).Apttus_Proposal__Account__c){
                    accountIdSet.add(Apttus.Apttus_Proposal__Account__c);
                    apttusLstToProcess.add(Apttus);
                }
            }
        }
        
        // To create map between accountID and Entity Id
        for(Account acc: [SELECT Id,Registration__c FROM Account WHERE ID IN :accountIdSet ]){
            accountIdToEntityIdMap.put(acc.Id,acc.Registration__c);
        }
        
        // to populate enetity Id field on Quote
        for(Apttus_Proposal__Proposal__c apptus : apttusLstToProcess){
            if(accountIdToEntityIdMap.containsKey(apptus.Apttus_Proposal__Account__c)){
                
                apptus.Entity_ID__c = accountIdToEntityIdMap.get(apptus.Apttus_Proposal__Account__c);
            }
        }
    }
    
    /*------------------------------------------------------------------------------

Author     :   Jyoti Agarwal
Description:   Copies value of installment and true term from related payment detail
Task Reference: T-421867

<Date>                 <Name>          <Desc with task/Issue#>

27 July 2015          Jyoti Agarwal     Created(T-421867)
------------------------------------------------------------------------------*/
    private static void populateFieldsFromPaymentDetails (List<Apttus_Proposal__Proposal__c> pNewApttusProposalList,Map<Id,Apttus_Proposal__Proposal__c> pOldApttusProposalMap){
        
        Boolean isInsert = true;
        Set<Id> paymentDetailsIdSet = new Set<Id>();
        Map<Apttus_Proposal__Proposal__c,Id> proposalToPaymentIdMap = new Map<Apttus_Proposal__Proposal__c,Id>();
        Map<Id,Payment_Details__c> paymentDetailsMap = new Map<Id,Payment_Details__c>();
        
        if(pOldApttusProposalMap != null)
            isInsert = false;
        
        for(Apttus_Proposal__Proposal__c proposal :pNewApttusProposalList ){
            
            if(isInsert && proposal.PaymentDetails__c!=null){
                paymentDetailsIdSet.add(proposal.PaymentDetails__c);
                proposalToPaymentIdMap.put(proposal,proposal.PaymentDetails__c);
            }else if(!isInsert && proposal.PaymentDetails__c != pOldApttusProposalMap.get(proposal.Id).PaymentDetails__c){
                paymentDetailsIdSet.add(proposal.PaymentDetails__c);
                proposalToPaymentIdMap.put(proposal,proposal.PaymentDetails__c);
            }
        }
        //system.debug('#######paymentDetailsIdSet######' +paymentDetailsIdSet);
        paymentDetailsMap = new Map<Id,Payment_Details__c>([SELECT Id,Installment_Flag__c,Non_Standard_Payment__c,True_Term__c
                                                            FROM Payment_Details__c WHERE ID IN : paymentDetailsIdSet]);
        
        if(proposalToPaymentIdMap.size() >0){
            for(Apttus_Proposal__Proposal__c proposal : proposalToPaymentIdMap.keySet()){
                
                Id paymentDetailId = proposalToPaymentIdMap.get(proposal);
                if(paymentDetailsMap.containsKey(paymentDetailId)){
                    
                    Payment_Details__c payDetails = paymentDetailsMap.get(paymentDetailId);
                    proposal.Installment__c = payDetails.Installment_Flag__c;
                    proposal.True_Term__c = payDetails.True_Term__c;
                    proposal.Non_Standard_Payment_Request__c = payDetails.Non_Standard_Payment__c;
                    
                }
            }
        }
    }
    
    private static void populatePaymentDetailField (List<Apttus_Proposal__Proposal__c> pNewApttusProposalList,Map<Id,Apttus_Proposal__Proposal__c> pOldApttusProposalMap){
        //system.debug('inside payment details detiail field'+pNewApttusProposalList);
        Boolean isInsert = true;
        String paymentMethod,paymentFrequency , PaymentTerm;
        //Map<Apttus_Proposal__Proposal__c,Id> proposalToPaymentDetailMap = new set<Id,Id>();
        if(pOldApttusProposalMap != null)
            isInsert = false;
        //system.debug(isInsert +' '+ pOldApttusProposalMap);
        for(Apttus_Proposal__Proposal__c proposal : pNewApttusProposalList){
            
            if(isInsert && proposal.Payment_Method__c != null && proposal.Payment_Frequency__c != null
               && proposal.Payment_Term__c != null){
                   
                   //paymentMethod = proposal.Payment_Method__c;
                   //paymentFrequency = proposal.Payment_Frequency__c;
                   //PaymentTerm = proposal.Payment_Term__c;
                   Id paymentDetail = getPaymentDetailId(proposal.Payment_Method__c,proposal.Payment_Frequency__c,proposal.Payment_Term__c,proposal.AccountOrganization__c);
                   
                   if(paymentDetail!=null){
                       proposal.PaymentDetails__c = paymentDetail;
                   }else{
                       
                       proposal.addError('no matching Payment Details could be found, please contact your administrator');
                   }
                   
                   
                   
               }else if(!isInsert &&
                        (proposal.Payment_Method1__c!= null && proposal.Payment1_Frequency__c!= null && proposal.Payment1_Term__c!= null)&&
                        (proposal.Payment1_Frequency__c!= pOldApttusProposalMap.get(proposal.Id).Payment1_Frequency__c||
                         proposal.Payment1_Term__c!= pOldApttusProposalMap.get(proposal.Id).Payment1_Term__c||
                         proposal.Payment_Method1__c!=  pOldApttusProposalMap.get(proposal.Id).Payment_Method1__c)){
                             //system.debug('inside update');
                             Id paymentDetail = getPaymentDetailId(proposal.Payment_Method1__c,proposal.Payment1_Frequency__c,proposal.Payment1_Term__c,proposal.AccountOrganization__c);
                             
                             if(paymentDetail!=null){
                                 proposal.PaymentDetails__c = paymentDetail;
                             }else{
                                 
                                 proposal.addError('no matching Payment Details could be found, please contact your administrator');
                             }
                         }else if(!isInsert &&
                                  proposal.Payment1_Term__c == null && pOldApttusProposalMap.get(proposal.Id).Payment1_Term__c != null){
                                      
                                      proposal.PaymentDetails__c = null;
                                      
                                      
                                  }
        }
        populateFieldsFromPaymentDetails(pNewApttusProposalList,pOldApttusProposalMap);
    }
    
    private static Id getPaymentDetailId(String method,String frequency,String term,string organization){
        //system.debug(method+frequency+term+organization);
        /*JFreese I-177530 - On or around 8/27/2015, someone edited the following query to use ORs instead of ANDs, which
made it select the wrong Payment_Details__c record.   If you intend to edit it back to ORs
please contact Jonathan Freese to discuss.*/
        Id payDetailId = null;
        for(Payment_Details__c detail : [SELECT Id FROM Payment_Details__c WHERE( PaymentFrequency__c =: frequency
                                                                                 AND PaymentMethod__c =: method
                                                                                 AND PaymentTerm__c =: term
                                                                                 AND Organization__c =: organization)
                                         AND Active__c = true LIMIT 1]){
                                             payDetailId = detail.Id;
                                         }
        
        if(payDetailId !=null){
            return payDetailId;
        }else{
            return null;
        }
        
        
    }
    
    
    /*
** @author : Appirio, Inc.
** @date : 08/06/2015
** @story : S-323564
** @element : T-408279
** @description : populate Posting contact.
** @paramaters : List of Orders
** @returns : nothing
*/
    private void populatePostingContact(List<Apttus_Proposal__Proposal__c> pApttusProposalList ,Map<Id,Apttus_Proposal__Proposal__c> oldpApttusProposalMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populatePostingContact');
        try{
            set<Id> QuoteAccountId = new Set<Id>();
            set<Id> contactIds = new set<Id>();
            set<Id> accIds = new set<Id>();
            Map<Id,Contact> ContactDetails = new Map<Id,Contact>();
            Boolean isUpdate = false;
            
            if(oldpApttusProposalMap != null)
                isUpdate = true;
            
            for(Apttus_Proposal__Proposal__c quote : pApttusProposalList){
                
                if(!isUpdate ){
                    
                    QuoteAccountId.add(quote.Apttus_Proposal__Account__c);
                }else if (isUpdate && quote.Apttus_Proposal__Account__c != oldpApttusProposalMap.get(quote.id).Apttus_Proposal__Account__c){
                    
                    QuoteAccountId.add(quote.Apttus_Proposal__Account__c);
                }
            }
            
            List< AccountContactAssociation__c > relatedAccountContact = [select Contact__c ,
                                                                          Account__c from AccountContactAssociation__c
                                                                          where Account__c IN: QuoteAccountId
                                                                          and PrimarySalesContact__c = true];
            
            Map<Id, Account> RegistrationAccountDetails = new Map<Id,Account>([SELECT Id,Name,PrimaryBillingContact__pc,Registration__c,PrimaryBillingContact__r.LastName,
                                                                               PrimaryBillingContact__r.FirstName,PrimaryBillingContact__c,
                                                                               Registration__r.PrimaryBillingAccount__r.PrimaryBillingContact__c,
                                                                               Registration__r.PrimaryBillingAccount__r.PrimaryBillingContact__r.FirstName,
                                                                               Registration__r.PrimaryBillingAccount__r.PrimaryBillingContact__r.LastName
                                                                               FROM Account WHERE Id IN: QuoteAccountId]);
            //for(Account acc : [SELECT Id,Name,Registration__c,Registration__r.PrimaryBillingAccount__c FROM Account Where ID IN : QuoteAccountId]){
            //Added By Viraj Rana,remove the query and use the above map to reduce the SOQL
            for(String strKey : RegistrationAccountDetails.keyset()){
                Account acc = RegistrationAccountDetails.get(strKey);
                if(acc.Registration__c != null && acc.Registration__r.PrimaryBillingAccount__c != null ){
                    accIds.add(acc.Registration__r.PrimaryBillingAccount__c);
                }
                //Sunny G removed this condition and adding the related account to the set so that we can fetch the account details and use that
                //IF we are not finding the primary sales contact on the Entity's primary billing account. Removing the else condition.
                //else {
                //Jeff added this condition, if there is no registration__c (entity) then we want to get the Posting contact from
                //the account itself.  Otherwise this will throw an error if there is now Entity ID at all.
                accIds.add(acc.Id);
                //}
            }
            for(Contact con: [Select Id, Account.id From Contact WHERE AccountId IN: accIds AND PrimarySalesContact__c = true]){
                if(con.AccountId != null){
                    ContactDetails.put(con.AccountId,con);
                }
            }
            for(Apttus_Proposal__Proposal__c quote : pApttusProposalList){
                if(RegistrationAccountDetails.containsKey(quote.Apttus_Proposal__Account__c)){
                    if(ContactDetails.containsKey(RegistrationAccountDetails.get(quote.Apttus_Proposal__Account__c).Registration__r.PrimaryBillingAccount__c)){
                        quote.PostingContact__c = ContactDetails.get(RegistrationAccountDetails.get(quote.Apttus_Proposal__Account__c).Registration__r.PrimaryBillingAccount__c).id;
                    } else {
                        //Jeff added this condition - same reason as above, need to populate posting contact if the Registration__r or Primary Billing Account is not
                        //populated on the Account/Entity
                        if(contactDetails.containsKey(quote.Apttus_Proposal__Account__c)){
                            quote.PostingContact__c = contactDetails.get(quote.Apttus_Proposal__Account__c).id;
                        }
                    }
                }
                
                if(quote.PostingContact__c == Null){
                    if(relatedAccountContact.size() > 0)
                        quote.PostingContact__c = relatedAccountContact[0].Contact__c ; // Will always be one. as there is a validation rule that doesnt let user enter 2 .I-226143
                }
            }
            
        }catch(Exception e){
            ExceptionLog.add('Exception', 'ApttusProposalTrigger', 'populatePostingContact', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to populate PostingContact.'+e.getMessage() ,e);
        }
    }
    
    
    
    /*
** @author : Appirio, Inc. (Jeff L)
** @date : 08/06/2015
** @story : S-323564
** @element : T-408279
** @description : if the parent opportunity is a GCS opportunity - then the owner of the proposal needs to be the Account Owner
** @paramaters : List of Orders
** @returns : nothing
*/
    private void updateGCSQuoteOwner(List<Apttus_Proposal__Proposal__c> pApttusProposalList){
        //get the value of the recordType ID for GCS Opportunities
        Id gcsOppRecordType = (ID)RecordTypeIDs__c.getInstance().Opportunity_GCS_Opportunity__c;
        
        //get the list of opportunities for each proposal so that we can query to see if they are GCS
        Set<Id> oppIdSet = new Set<Id>();
        for(Apttus_Proposal__Proposal__c prop : pApttusProposalList){
            oppIdSet.add(prop.Apttus_Proposal__Opportunity__c);
        }
        
        //Now query to check the recordtype on each opportunity
        Map<Id,Opportunity> gcsOpps = new Map<Id,Opportunity>();
        for(Opportunity opp : [Select Id, RecordTypeId, Account.OwnerId from Opportunity where Id in :oppIdSet]){
            if(opp.RecordTypeId == gcsOppRecordType){
                gcsOpps.put(opp.Id, opp);
            }
        }
        
        //final step - get all the proposals related to GCS Opportunities and change their owners
        for(Apttus_Proposal__Proposal__c prop : pApttusProposalList){
            Opportunity gcsOpp = gcsOpps.get(prop.Apttus_Proposal__Opportunity__c);
            if(gcsOpp != null){
                prop.OwnerId = gcsOpp.Account.OwnerId;
                //system.debug('>>OwnerIdGCS>>' + prop.ownerId);
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
    
    private void updateOrdersFormulaFields (map<Id, Apttus_Proposal__Proposal__c> oldProposalMap ,map<Id, Apttus_Proposal__Proposal__c> newProposalMap){
        
        list<Apttus_Proposal__Proposal__c> lstUpdatedProposals = new   list<Apttus_Proposal__Proposal__c> ();
        
        for(Apttus_Proposal__Proposal__c proposal : newProposalMap.values()){
            if(newProposalMap.get(proposal.id).Agency_Billing_City__c != oldProposalMap.get(proposal.id).Agency_Billing_City__c ||
               newProposalMap.get(proposal.id).Agency_Billing_City_State__c != oldProposalMap.get(proposal.id).Agency_Billing_City_State__c  ||
               newProposalMap.get(proposal.id).Agency_Billing_City_State_Zip__c != oldProposalMap.get(proposal.id).Agency_Billing_City_State_Zip__c  ||
               newProposalMap.get(proposal.id).Agency_Billing_Country__c != oldProposalMap.get(proposal.id).Agency_Billing_Country__c ||
               newProposalMap.get(proposal.id).Agency_Billing_State_Province__c != oldProposalMap.get(proposal.id).Agency_Billing_State_Province__c ||
               newProposalMap.get(proposal.id).Agency_Billing_Street_Address__c != oldProposalMap.get(proposal.id).Agency_Billing_Street_Address__c ||
               newProposalMap.get(proposal.id).Agency_Billing_Zip__c != oldProposalMap.get(proposal.id).Agency_Billing_Zip__c ||
               newProposalMap.get(proposal.id).AgencyCommission__c != oldProposalMap.get(proposal.id).AgencyCommission__c ||
               newProposalMap.get(proposal.id).APTS_Agency_commission_Approval__c != oldProposalMap.get(proposal.id).APTS_Agency_commission_Approval__c||
               newProposalMap.get(proposal.id).Agency_Discount_Amount__c!= oldProposalMap.get(proposal.id).Agency_Discount_Amount__c||
               newProposalMap.get(proposal.id).Local_Agency_Address__c != oldProposalMap.get(proposal.id).Local_Agency_Address__c  ||
               newProposalMap.get(proposal.id).New_Number_of_Installments__c != oldProposalMap.get(proposal.id).New_Number_of_Installments__c ||
               newProposalMap.get(proposal.id).Local_Agency_Cust__c != oldProposalMap.get(proposal.id).Local_Agency_Cust__c
              ){
                  
                  lstUpdatedProposals.add(proposal);
              }
        }
        if(lstUpdatedProposals.size() >0){
            list<Order__c> lstOrders = [select Agency_Billing_City__c,
                                        Agency_Billing_City_State__c ,
                                        Agency_Billing_City_State_Zip__c ,
                                        Agency_Billing_Country__c,
                                        Agency_Billing_State_Province__c,
                                        Agency_Billing_Street_Address__c,
                                        Agency_Billing_Zip__c,
                                        AgencyCommission__c ,
                                        New_Number_of_Installment__c,
                                        Agency_commission_Approval__c,
                                        Agency_Discount_Amount__c,
                                        Local_Agency_Address__c,
                                        Local_Agency_Cust__c ,
                                        QuoteProposal__c
                                        from Order__c where QuoteProposal__c IN :lstUpdatedProposals ] ;
            
            System.debug('lstOrders' + lstOrders);
            System.debug('lstUpdatedProposals' + lstUpdatedProposals);
            map<Id , list<Order__c>> mapListOrderProposals = new map<Id , list<Order__c>>();
            for(Order__c o : lstOrders){
                if(!mapListOrderProposals.containskey(o.QuoteProposal__c))
                    mapListOrderProposals.put(o.QuoteProposal__c , new list<Order__c>());
                mapListOrderProposals.get(o.QuoteProposal__c).add(o);
            }
            
            list<Order__c> lstUpdateOrders = new list<Order__c> ();
            
            for(Apttus_Proposal__Proposal__c proposal : newProposalMap.values()){
                if(mapListOrderProposals.containskey(proposal.id)){
                    for(Order__c o : mapListOrderProposals.get(proposal.id)){
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
                        o.New_Number_of_Installment__c = proposal.New_Number_of_Installments__c ;
                        lstUpdateOrders.add(o);
                    }
                }
            }
            //if(lstUpdateOrders.size() > 0 )
            //update lstUpdateOrders;
        }
    }
    /*------------------------------------------------------------------------------
Description:   Update of Primary Sales Rep of Proposal before Insert
Task Reference:  I-160013
1st July 2015
Dev name- Piyush Jain
------------------------------------------------------------------------------*/
    public static void setProposalOwner(list<Apttus_Proposal__Proposal__c> pApttusProposalList, map<Id, Account> accMap){
        
        Set<id> setAccountIds = new Set<id>();
        /*for(Apttus_Proposal__Proposal__c proposal : pApttusProposalList){
if(proposal.Apttus_Proposal__Account__c != null){
setAccountIds.add(proposal.Apttus_Proposal__Account__c);
}
}

Map<id ,Account> mapAccount = new Map<id ,Account>([select Id, ownerId from Account where id IN :setAccountIds]) ;*/
        Map<id ,Account> mapAccount = accMap;
        
        Account acc;
        for(Apttus_Proposal__Proposal__c proposal : pApttusProposalList){
            if(mapAccount.containsKey(proposal.Apttus_Proposal__Account__c)){
                acc = mapAccount.get(proposal.Apttus_Proposal__Account__c);
                if(acc.ownerId != null){
                    proposal.ownerId = acc.ownerId ;
                    //system.debug('>>OwnerId>>' + proposal.ownerId);
                }
            }
        }
    }
    /*
** @author : Appirio, Inc.
** @date : 23/07/2015
** @story : S-331170
** @element : T-420530
** @description : Update Apttus proposal trigger so that the proposal should pull the Account Owner's sales channel from the user record and populate SalesChannel__c on Quote/Proposal
** @paramaters : List of Quotes
** @returns : nothing
*/
    
    private void UpdateProposalSalesChannel(list<Apttus_Proposal__Proposal__c> pApttusProposalList, map<Id, Account> accMap){
        
        set<Id> AccountIds = new set<Id>();
        Map<Id,String> Accountsales = new Map<Id,String>();
        
        for(Apttus_Proposal__Proposal__c prop :  pApttusProposalList){
            if(String.isBlank(prop.SalesChannel__c)){
                AccountIds.add(prop.Apttus_Proposal__Account__c);
            }
        }
        
        //for(Account acc : [Select id, Owner.PositionSalesChannel__c From Account Where Id IN :AccountIds]){
        for(Account acc : accMap.values()){
            if(acc.Owner.PositionSalesChannel__c != null){
                Accountsales.put(acc.id,acc.Owner.PositionSalesChannel__c);
            }
        }
        
        for(Apttus_Proposal__Proposal__c prop :  pApttusProposalList){
            if(Accountsales.containsKey(prop.Apttus_Proposal__Account__c) && Accountsales.get(prop.Apttus_Proposal__Account__c) != null){
                prop.SalesChannel__c = Accountsales.get(prop.Apttus_Proposal__Account__c);
            }
        }
        
    }
    
    private static void populateBillAndPrimaryAddress (List<Apttus_Proposal__Proposal__c> newProposalList , Map<Id,Apttus_Proposal__Proposal__c> oldProposalMap){
        
        Boolean isUpdate = false;
        Set<Id> agencyIdSet = new set<Id>();
        Map<Apttus_Proposal__Proposal__c,Id> quoteToAgencyId = new Map<Apttus_Proposal__Proposal__c,Id>();
        Map<Id,string> billingCityMap = new Map<Id,string>();
        Map<Id,string> billingStateMap = new Map<Id,string>();
        Map<Id,string> billingStreetMap = new Map<Id,string>();
        Map<Id,string> billingCountryMap = new Map<Id,string>();
        Map<Id,string> BillingPostalCodeMap = new Map<Id,string>();
        
        
        if(oldProposalMap!=null)
            isUpdate = true;
        
        for(Apttus_Proposal__Proposal__c proposal : newProposalList){
            if(!isUpdate && proposal.Agency__c != null){
                
                agencyIdSet.add(proposal.Agency__c);
                
            }else if(isUpdate && proposal.Agency__c != oldProposalMap.get(proposal.Id).Agency__c){
                
                agencyIdSet.add(proposal.Agency__c);
            }
        }
        
        for(Account acc: [Select billingCity,billingState,billingCountry,BillingStreet,BillingPostalCode,shippingCity,shippingState,shippingCountry,shippingStreet,shippingPostalCode from Account Where ID IN :agencyIdSet]){
            
            billingCityMap.put(acc.Id,acc.billingCity);
            billingStateMap.put(acc.Id,acc.billingState);
            //billingCityMap.put(acc.Id,);
            billingStreetMap.put(acc.Id,acc.BillingStreet);
            billingCountryMap.put(acc.Id,acc.billingCountry);
            BillingPostalCodeMap.put(acc.Id,acc.BillingPostalCode);
            
            
        }
        
        for(Apttus_Proposal__Proposal__c proposal : newProposalList){
            
            if(billingCityMap.containsKey(proposal.Agency__c)){
                
                string billCity = billingCityMap.get(proposal.Agency__c);
                proposal.BillingCity__c = billCity;
            }
            
            if(billingStreetMap.containsKey(proposal.Agency__c)){
                
                string billStreet = billingStreetMap.get(proposal.Agency__c);
                proposal.BillingStreet__c = billStreet;
            }
            
            if(billingStateMap.containsKey(proposal.Agency__c)){
                
                string billState = billingStateMap.get(proposal.Agency__c);
                proposal.BillingStateProvince__c = billState;
            }
            
            if(billingCountryMap.containsKey(proposal.Agency__c)){
                
                string billCountry = billingCountryMap.get(proposal.Agency__c);
                proposal.BillingCountry__c = billCountry;
            }
            
            if(BillingPostalCodeMap.containsKey(proposal.Agency__c)){
                
                string billPostal = BillingPostalCodeMap.get(proposal.Agency__c);
                proposal.BillingZipPostalCode__c = billPostal;
            }
            
            
        }
        
        
    }
    
    
    // Added by Vivek Ojha for T-434694
    private static void populateOpportunityAmount(List<Apttus_Proposal__Proposal__c> pNewApttusProposal ){
        
        Map<String,String> proposalOptyMap = new Map<String,String>();
        Map<String,Apttus_Proposal__Proposal__c> optyProposalMap = new Map<String,Apttus_Proposal__Proposal__c>();
        List<Opportunity> optyLst = new List<Opportunity>();
        
        for(Apttus_Proposal__Proposal__c prop : pNewApttusProposal){
            if(prop.Apttus_QPConfig__ConfigurationFinalizedDate__c != null && String.valueOF(prop.Apttus_QPConfig__ConfigurationFinalizedDate__c) != '' && prop.Apttus_Proposal__Primary__c == true &&  prop.QuoteStatus__c != 'Accepted Online'  && prop.QuoteStatus__c != 'Expired'  ){// changes for locking issue in echosign and I-223447
                proposalOptyMap.put(prop.Id,prop.Apttus_Proposal__Opportunity__c);
                optyProposalMap.put(prop.Apttus_Proposal__Opportunity__c,prop);
            }
        }
        for(Opportunity opty :[Select Id,Amount From Opportunity Where Id IN : proposalOptyMap.values() AND Organization__c ='North America']){
            if(optyProposalMap.containsKey(opty.Id)){
                // Commented due to I-191155
                //opty.Amount = optyProposalMap.get(opty.Id).Quote_Total__c;
                opty.Amount = optyProposalMap.get(opty.Id).Net_Total__c;
                opty.Skip_Amount_Validation__c = true;
                optyLst.add(opty);
            }
        }
        if(!optyLst.isEmpty()){
            update optyLst;
        }
        
        
    }
    
    private static void populateTemplateNameAndSigners(List<Apttus_Proposal__Proposal__c> pNewApttusProposal)
    {
        
        Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosById();
        List<Apttus_Proposal__Proposal__c> proposalListToUpdate=new List<Apttus_Proposal__Proposal__c>();
        List<QueryTemplateDefaultSettings__c> defaultSettingList=QueryTemplateDefaultSettings__c.getAll().values();
        for(Apttus_Proposal__Proposal__c proposal:pNewApttusProposal)
        {
            proposal.Template_Name__c = '';
            proposal.Template_Signers__c = 0;
            
            String strTemplateName='';
            String strTemplateSigners='';
            
            for(QueryTemplateDefaultSettings__c defaultSetting:defaultSettingList)
            {
                
                if(defaultSetting.Agency__c==(proposal.Agency__c!=null) && defaultSetting.Country__c == proposal.Selling_Country__c && defaultSetting.Language__c == proposal.Language__c && defaultSetting.Quote_Type__c == proposal.APTS_Quote_Type__c)
                {
                    if(proposal.Template_Name__c != defaultSetting.Default_Template__c || proposal.Template_Signers__c != defaultSetting.Signers__c)
                    {
                        strTemplateName +=  defaultSetting.Default_Template__c + ',' ;
                        strTemplateSigners += defaultSetting.Default_Template__c + ',' + defaultSetting.Signers__c + ':' ;
                    }
                    //break;
                }
                else if(defaultSetting.Agency__c==(proposal.Agency__c!=null) && defaultSetting.Country__c == proposal.Selling_Country__c && defaultSetting.Language__c == proposal.Language__c)
                {
                    
                    //if(defaultSetting.Quote_Type__c == 'Standard' && rtMap.get(proposal.RecordTypeId).getName() == 'Proposal')
                    if(defaultSetting.Quote_Type__c == 'Standard' && proposal.MidContract_Proposal__c == False && proposal.Upgrade_Proposal__c == False && proposal.APTS_Quote_Type__c!='Product Conversion' && proposal.Conversion_Proposal__c == False)
                    {
                        if(proposal.Template_Name__c != defaultSetting.Default_Template__c || proposal.Template_Signers__c != defaultSetting.Signers__c)
                        {
                            strTemplateName += defaultSetting.Default_Template__c + ',' ;
                            strTemplateSigners += defaultSetting.Default_Template__c + ',' + defaultSetting.Signers__c + ':' ;
                            //break;
                        }
                        
                    }
                    if(defaultSetting.Quote_Type__c == 'Asset' && (proposal.MidContract_Proposal__c == True || proposal.Upgrade_Proposal__c == True || proposal.APTS_Quote_Type__c=='Product Conversion' || proposal.Conversion_Proposal__c))//I-213467 changes
                    {
                        if(proposal.Template_Name__c != defaultSetting.Default_Template__c || proposal.Template_Signers__c != defaultSetting.Signers__c)
                        {
                            strTemplateName += defaultSetting.Default_Template__c + ',' ;
                            strTemplateSigners +=  defaultSetting.Default_Template__c + ',' + defaultSetting.Signers__c + ':' ;
                            //break;
                        }
                    }
                }
            }
            proposal.Template_Name__c = strTemplateName;
            proposal.Template_Name_And_Signers__c = strTemplateSigners;
        }
    }
    
    
    //I-198863 changes
    //translate the payment details based on language
    private static void populateTranslatedPaymentFields(List<Apttus_Proposal__Proposal__c> pNewApttusProposal)
    {
        
        List<Apttus_Proposal__Proposal__c> proposalListToUpdate=new List<Apttus_Proposal__Proposal__c>();
        List<PaymentTranslationSettings__c> PaymentTranslationSettingList=PaymentTranslationSettings__c.getAll().values();
        for(Apttus_Proposal__Proposal__c proposal:pNewApttusProposal)
        {
            
            for(PaymentTranslationSettings__c pts:PaymentTranslationSettingList)
            {
                if(pts.Payment_Field_Name__c =='Payment Method' && pts.Language__c== proposal.Language__c &&  pts.Original_Value__c==proposal.Payment_Method1__c)
                {
                    proposal.Translated_Payment_Method__c=pts.Translated_Value__c;
                }
                
                if(pts.Payment_Field_Name__c =='Payment Frequency' && pts.Language__c== proposal.Language__c &&  pts.Original_Value__c==proposal.Payment1_Frequency__c)
                {
                    proposal.Translated_Payment_Frequency__c=pts.Translated_Value__c;
                }
                
                
                if(pts.Payment_Field_Name__c =='Payment Terms' && pts.Language__c== proposal.Language__c &&  pts.Original_Value__c==proposal.Payment1_Term__c)
                {
                    proposal.Translated_Payment_Terms__c=pts.Translated_Value__c;
                }
                
            }
            
        }
    }
    
    
    
}