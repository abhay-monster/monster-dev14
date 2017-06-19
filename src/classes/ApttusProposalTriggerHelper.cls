public without sharing class ApttusProposalTriggerHelper {
    final String CLASSNAME = '\n\n**** ApttusProposalTriggerHelper.METHODNAME()';
    // ********* PROPERTIES ***********
    public static Boolean PermitUpdateOfBilling = false; //this will enable modifying the agency when the opportunity agency is modified
    public Org_Settings__c orgSettings = Org_Settings__c.getInstance();
    public Integer cutoff = Integer.valueOf(orgSettings.Debug_Log_Record_Count_Cutoff__c); //JFreese Appirio S-435483 4/11/17
    public Id debugId = orgSettings.Debug_Log_Record_ID__c; //JFreese Appirio S-435483 4/11/17

    private Set<String> DataGovernanceProfiles = new Set<String>{
        'Data Steward',
            'Sales Operations'
            };
                private Set<String> OtherPermittedProfiles = new Set<String>{
                    'Sales Rep (APAC)',
                        'Sales Rep (EU)',
                        'Sales Rep (NA)',
                        'Sales Manager (APAC)',
                        'Sales Manager (EU)',
                        'Sales Manager (NA)',
                        'System Administrator'
                        };
                            private Set<String> editabilityProfiles = new Set<String>{
                                'Sales Operations',
                                    'System Administrator'
                                    };

                                        private String UserProfileName{get; private set;}
    private map<Id, User> UserIdToUserMap{
        get{
            if(UserIdToUserMap == NULL){
                UserIdToUserMap = new map<Id,User>([SELECT Id, ManagerId,UserDefaultPriceList__c,Location__c FROM User LIMIT 50000]);
            }
            return UserIdToUserMap;
        }
        private set;
    }

    /*
** @author : Cloud Sherpas Inc.
** @date : 04/09/2014
** @description : static method that instantiates a new instance of the class & sets the user's profile name member variable
** @paramaters : a string - the profile name for the current user
** @returns : a new instance of the ApttusProposalTriggerHelper class
*/
    public static ApttusProposalTriggerHelper NewTriggerHelper(String pUserProfileName){

        //final string METHODNAME = CLASSNAME.replace('METHODNAME','NewTriggerHelper');
        //system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        ApttusProposalTriggerHelper newHelper = new ApttusProposalTriggerHelper(pUserProfileName);
        return newHelper;
    }
    /*
** @author : Cloud Sherpas, Inc.
** @date : 04/09/2014
** @description : this method is the class constructor
** @paramaters : String user profile name
** @returns : nothing
*/
    private ApttusProposalTriggerHelper(String pUserProfileName){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','ApttusProposalTriggerHelper');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        UserProfileName = pUserProfileName;
    }
    /*
** @author : Cloud Sherpas, Inc.
** @date : 04/09/2014
** @description : this method get the opportunity id in every apttus proposal
** @paramaters : list of Apttus_Proposal__Proposal__c records
** @returns : set of opportunity ids
*/
    public Set<Id> getOpportunityIdSet(Apttus_Proposal__Proposal__c[] pApttusProposal){
        Set<Id> opportunityIDSet = new Set<Id>();
        for(Apttus_Proposal__Proposal__c propsal : pApttusProposal){
            if(propsal.Apttus_Proposal__Opportunity__c != null){
                opportunityIDSet.add(propsal.Apttus_Proposal__Opportunity__c);
            }
        }
        return opportunityIDSet;
    }

    /*
** @author : Cloud Sherpas, Inc.
** @date : 04/15/2014
** @description : populate quote pricelist to user's default pricelist, if the user's default pricelist currency field is equal to
**                              the quote's currency.
** Story 2527 - Price List Should Be Default By User Settings
** @paramaters : list of new Apttus_Proposal__Proposal__c records
** @returns : nothing
*/
    public void PopulateQuotePriceList(Apttus_Proposal__Proposal__c[] pNewApttusProposal){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','PopulateQuotePriceList');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        //User currentUser = [SELECT UserDefaultPriceList__c FROM User WHERE Id = :UserInfo.getUserId()];
        User currentUser  =  UserIdToUserMap.get(UserInfo.getUserId());

        if(currentUser.UserDefaultPriceList__c != null && currentUser.UserDefaultPriceList__c != ''){
            system.debug('User Default Price List: ' + currentUser.UserDefaultPriceList__c);
            list<Apttus_Config2__PriceList__c> pricelists = [SELECT Id, Name, CurrencyIsoCode
                                                             FROM Apttus_Config2__PriceList__c
                                                             WHERE Name = :currentUser.UserDefaultPriceList__c
                                                             LIMIT 1];
            if(pricelists != null && pricelists.size() > 0){
                Apttus_Config2__PriceList__c pricelist = pricelists[0];
                for(Apttus_Proposal__Proposal__c newProp : pNewApttusProposal){
                    if(newProp.CurrencyIsoCode == pricelist.CurrencyIsoCode && newProp.Apttus_QPConfig__PriceListId__c == null){
                        newProp.Apttus_QPConfig__PriceListId__c = pricelist.Id;
                    }
                }//for
            }
        }
    }

    /*
** @author : Cloud Sherpas, Inc.
** @date : 10/31/2014
** @description : Story 2527 - Price List Should Be Default By User Settings
When user manually selects price list on Quote, the currency on Quote should be set to the currency of that price list.
** @paramaters : list of new Apttus_Proposal__Proposal__c and old records
** @returns : nothing
*/
    public void updateQuotePriceListCurrency(Apttus_Proposal__Proposal__c[] pNewApttusProposal, map<Id, Apttus_Proposal__Proposal__c> pOldProposalMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateQuotePriceListCurrency');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Set<Id> priceListIdSet = new Set<Id>();

        for(Apttus_Proposal__Proposal__c newProp : pNewApttusProposal){
            Apttus_Proposal__Proposal__c oldProp = pOldProposalMap.get(newProp.Id);
            if (pNewApttusProposal.size() <= cutoff || newProp.Id == debugId){ //JFreese Appirio S-435483 4/11/17
              System.debug('newProp.Apttus_QPConfig__PriceListId__c'+newProp.Apttus_QPConfig__PriceListId__c);
              System.debug('oldProp.Apttus_QPConfig__PriceListId__c'+oldProp.Apttus_QPConfig__PriceListId__c);
            }
            if(newProp.Apttus_QPConfig__PriceListId__c != null &&
               oldProp.Apttus_QPConfig__PriceListId__c != newProp.Apttus_QPConfig__PriceListId__c){
                   priceListIdSet.add(newProp.Apttus_QPConfig__PriceListId__c);
               }
            //Story 2753 & 2755 - Offline Quote Flow update for all environments
            if(newProp.QuoteStatus__c != oldProp.QuoteStatus__c &&
               newProp.QuoteStatus__c == 'Accepted Offline'){
                   newProp.signed_indicator__c = true;
               }
        }//for

        if(priceListIdSet.isEmpty()){
            //system.debug('No Price List Updated.');
            return;
        }
        //system.debug('priceListIdSet: ' + priceListIdSet);
        Map<Id, Apttus_Config2__PriceList__c> priceListMap = new Map<Id, Apttus_Config2__PriceList__c>(
            [SELECT Id, Name, CurrencyIsoCode
             FROM Apttus_Config2__PriceList__c
             WHERE Id IN :priceListIdSet]);


        for(Apttus_Proposal__Proposal__c newProp : pNewApttusProposal){
            if(newProp.Apttus_QPConfig__PriceListId__c != null &&
               newProp.CurrencyIsoCode != priceListMap.get(newProp.Apttus_QPConfig__PriceListId__c).CurrencyIsoCode){
                   //system.debug('updating Proposal Currenct from : ' + newProp.CurrencyIsoCode);
                   newProp.CurrencyIsoCode = priceListMap.get(newProp.Apttus_QPConfig__PriceListId__c).CurrencyIsoCode;
                   //system.debug('updating Proposal Currenct To : ' + newProp.CurrencyIsoCode);
               }
        }//for
    }

    /*
** @author : Cloud Sherpas, Inc.
** @date : 04/09/2014
** @description : this method is the class constructor
** @paramaters : list of Apttus_Proposal__Proposal__c records
** @returns : nothing
*/
    //Removed and the Opportunity Stage update is done using Trigger
    public void UpdateQuoteCreatedOfOpportunity(Apttus_Proposal__Proposal__c[] pApttusProposal){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','UpdateQuoteCreatedOfOpportunity');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        //system.debug('n\nUpdating of opportunity\'s QuoteCreated__c:');
        Set<Id> opportunityIDSet = getOpportunityIdSet(pApttusProposal);

        list<Opportunity> opportunityList = [SELECT QuoteCreated__c, RecordType.Name FROM Opportunity WHERE Id = :opportunityIDSet];
        list<Apttus_Proposal__Proposal__c> existingProposalList = [SELECT Apttus_Proposal__Opportunity__c
                                                                   FROM Apttus_Proposal__Proposal__c
                                                                   WHERE Apttus_Proposal__Opportunity__c IN :opportunityIDSet];
        Set<Id> oppThatHasProposal = new Set<Id>();
        for(Apttus_Proposal__Proposal__c ep : existingProposalList){
            if(opportunityIDSet.contains(ep.Apttus_Proposal__Opportunity__c)){
                oppThatHasProposal.add(ep.Apttus_Proposal__Opportunity__c);
            }
        }

        if(opportunityList.size() > 0){
            for(Opportunity opp : opportunityList){
                if(opp.recordType.Name != 'GCS Opportunity') {
                    opp.QuoteCreated__c = oppThatHasProposal.contains(opp.Id);
                }
            }
            update opportunityList;
            //system.debug(opportunityList.size() + ' opportunity record(s) updated.\n\n');
        }else{
            system.debug('No opportunity updated.\n\n');
        }
    }


    /*
** @author : Cloud Sherpas, Inc.
** @date : 04/09/2014
** @description : this method is used to remove Agency on the opportunity when the agnecy is removed in the quote.
** @paramaters : an array of Apttus_Proposal__Proposal__c objects
** @returns : nothing
*/
    public void SetAccountOrganization(Apttus_Proposal__Proposal__c[] pNewApttusProposal, Map<Id, Account> accMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','SetAccountOrganization');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        /*Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Organization__c, PricingAccount__c
FROM Account
WHERE Id IN :GetParentAccount(pNewApttusProposal)]);*/
        Map<Id, Account> accountMap = accMap;
        system.debug('Get organization from this accounts: ' + accMap);
        system.debug('Get organization from this accounts: ' + pNewApttusProposal);
        for(Apttus_Proposal__Proposal__c apq : pNewApttusProposal){
            if(accountMap.containsKey(apq.Apttus_Proposal__Account__c)){
                apq.AccountOrganization__c = accountMap.get(apq.Apttus_Proposal__Account__c).Organization__c;
                //Story 1722: set the quote end date automatically
                if(apq.AccountOrganization__c == 'North America' ||
                   apq.AccountOrganization__c == 'Asia Pacific'){
                       //Current Date + 30 days
                       apq.Apttus_Proposal__Proposal_Expiration_Date__c = Date.today().addDays(30);
                       apq.Apttus_Proposal__ExpectedEndDate__c = Date.today().addDays(30);
                       //I-190477 changes
                       apq.Apttus_Proposal__Valid_Until_Date__c= Date.today().addDays(30);
                   }else if(apq.AccountOrganization__c == 'Europe'){
                       //Set Last Day of Current Month
                       apq.Apttus_Proposal__Proposal_Expiration_Date__c = Date.today().addMonths(1).toStartOfMonth().addDays(-1);
                       apq.Apttus_Proposal__ExpectedEndDate__c = Date.today().addMonths(1).toStartOfMonth().addDays(-1);
                       //I-190477 changes
                       apq.Apttus_Proposal__Valid_Until_Date__c= Date.today().addMonths(1).toStartOfMonth().addDays(-1);
                       System.debug('Expiretation Date'+apq.Apttus_Proposal__Proposal_Expiration_Date__c);
                   }
                //CS 8/15/2014 User Story 216: Set Pricing channel from Account
                apq.Pricing_Channel__c = accountMap.get(apq.Apttus_Proposal__Account__c).PricingAccount__c;
            }
        }
    }

    /*
** @author : Cloud Sherpas, Inc.
** @date : 04/09/2014
** @description : prepares account Ids of every quote/proposal
** @paramaters : an array of Apttus_Proposal__Proposal__c records
** @returns : Parent Account Set of Ids
*/
    private Set<Id> GetParentAccount(Apttus_Proposal__Proposal__c[] pNewApttusProposal){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','GetParentAccount');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        Set<Id> accIdSet = new Set<Id>();
        for(Apttus_Proposal__Proposal__c apq : pNewApttusProposal){
            accIdSet.add(apq.Apttus_Proposal__Account__c);
        }
        return accIdSet;
    }

    /*
** @author : Cloud Sherpas, Inc.
** @date : 12/09/2014
** @description : prepares Billing account Ids of every quote/proposal
** @paramaters : an array of Apttus_Proposal__Proposal__c records
** @returns : Billing Account Set of Ids
*/
    /*   private Set<Id> GetBillingAccount(Apttus_Proposal__Proposal__c[] pNewApttusProposal){
final string METHODNAME = CLASSNAME.replace('METHODNAME','GetBillingAccount');
system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
Set<Id> accIdSet = new Set<Id>();
for(Apttus_Proposal__Proposal__c apq : pNewApttusProposal){
if(apq.BillingAccount__c != null)
accIdSet.add(apq.BillingAccount__c);
}
return accIdSet;
}
*/
    private Set<Id> GetBillingContact(Apttus_Proposal__Proposal__c[] pNewApttusProposal){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','GetBillingContact');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        Set<Id> accIdSet = new Set<Id>();
        for(Apttus_Proposal__Proposal__c apq : pNewApttusProposal){
            if(apq.BillContact__c != null)
                accIdSet.add(apq.BillContact__c);
        }
        return accIdSet;
    }

    /*
** @author : Cloud Sherpas, Inc.
** @date : 04/09/2014
** @description : this method is used to remove Agency on the opportunity when the agnecy is removed in the quote.
** @paramaters : an array of Apttus_Proposal__Proposal__c objects
** @returns : nothing
*/
    public void updateOpportunity(Apttus_Proposal__Proposal__c[] pApttusProposal,
                                  map<Id, Apttus_Proposal__Proposal__c> pOldApttusProposalMap,
                                  String eventType){


                                      final string METHODNAME = CLASSNAME.replace('METHODNAME','updateOpportunity');
                                      system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

                                      Set<Id> opportunityIDSet = getOpportunityIdSet(pApttusProposal);
                                      Map<id, Opportunity> opportunityMap = new Map<id, Opportunity>([SELECT ID, Agency__c, StageName
                                                                                                      FROM Opportunity
                                                                                                      WHERE Id IN :opportunityIDSet]);

                                      Map<Id,Opportunity> oppToUpdate = new Map<Id,Opportunity>();
                                      Apttus_Proposal__Proposal__c oldProposal;
                                      Opportunity oppty;
                                      for(Apttus_Proposal__Proposal__c prop : pApttusProposal){
                                          oppty = opportunityMap.get(prop.Apttus_Proposal__Opportunity__c);
                                          if(oppty != null ){
                                              oppty.Skip_Stage_Validation__c = True;
                                          }
                                          if(oppty != null && prop.Agency__c == null && oppty.Agency__c!=null){// changes for locking issue in echosign
                                              oppty.Agency__c = null;
                                              oppToUpdate.put(oppty.Id, oppty);
                                          }
                                          //Story 2277 - Sales Stage isn't updating upon generating quotes
                                          //Story 2452 - "Progress Bar", "Stage" And "Probability (%)" Not Updating
                                          //Story 2522 - Stage Not Updating Correctly

                                          if(oppty != null && prop.Apttus_Proposal__Primary__c){

                                              if(eventType == 'Delete' && oppty.StageName != 'Stage 1 - Needs Assessment'){
                                                  oppty.StageName = 'Stage 1 - Needs Assessment';
                                                  oppToUpdate.put(oppty.Id ,oppty);
                                              }else if(prop.Apttus_Proposal__Approval_Stage__c == 'Draft' && oppty.StageName != 'Stage 2 - Proposal'){
                                                  //oppty.StageName = 'Stage 2 - Proposal';
                                                  oppToUpdate.put(oppty.Id ,oppty);
                                              }else if(prop.Apttus_Proposal__Approval_Stage__c == 'Presented' && oppty.StageName != 'Stage 3 - Quote' && oppty.ReadyForProcessing__c == false){
                                                  oppty.StageName = 'Stage 3 - Quote';
                                                  oppToUpdate.put(oppty.Id ,oppty);
                                              }
                                              // Matt - Proposal Stage changes would not change the Oppty to Stage 4 - Won - I-192464
                                              // Sylvester (Appirio) 3/21/16 - Added check to avoid resetting opp stage from Stage 5 back to stage 4 (I-187441)
                                              else if(((prop.Apttus_Proposal__Approval_Stage__c == 'Approved' || prop.Apttus_Proposal__Approval_Stage__c == 'Accepted')
                                                       && (prop.QuoteStatus__c == 'Accepted Online' || prop.QuoteStatus__c == 'Accepted Offline'))
                                                      && (oppty.StageName != 'Stage 4 - Won' && oppty.StageName !='Stage 5 - Verified by Finance')){
                                                          oppty.StageName = 'Stage 4 - Won';
                                                          oppToUpdate.put(oppty.Id ,oppty);
                                                      }
                                              //2755 and 2753 - Set Oppty Echosign Signed Indicator = Y when Status = Accepted Offline
                                              if(prop.signed_indicator__c == true && !oppty.echosign_indicator__c){// changes for locking issue in echosign
                                                  oppty.echosign_indicator__c = true;
                                              }

                                              if(prop.Primay_Quote_Total_Match__c == 0 && !oppty.Primary_Quote_Totals_Match__c)// changes for locking issue in echosign
                                              {
                                                  oppty.Primary_Quote_Totals_Match__c = true;
                                                  oppToUpdate.put(oppty.Id ,oppty);
                                              }
                                              else if(prop.Primay_Quote_Total_Match__c != 0 && oppty.Primary_Quote_Totals_Match__c)// changes for locking issue in echosign
                                              {
                                                  oppty.Primary_Quote_Totals_Match__c = false;
                                                  oppToUpdate.put(oppty.Id ,oppty);
                                              }
                                          }
                                      }//for
                                      if(oppToUpdate!= null && !oppToUpdate.isEmpty()){
                                          update oppToUpdate.values();
                                      }
                                  }

    /*
** @author : Cloud Sherpas, Inc.
** @date : 04/09/2014
** @description : this method is used to update the parent account billing address when quote's billing address gets updated
** @paramaters : an array of Apttus_Proposal__Proposal__c objects
** @returns : nothing
*/
    public void UpdateAccountBillingAddress(Map<Id, Apttus_Proposal__Proposal__c> pOldApttusProposalMap, list<Apttus_Proposal__Proposal__c> pUpdatedApttusProposalList){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','UpdateAccountBillingAddress');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        set<id> AccountIds = new set<id>();

        for(Apttus_Proposal__Proposal__c oApttusProposal : pUpdatedApttusProposalList ){
            AccountIds.add(oApttusProposal.Apttus_Proposal__Account__c);
            //Cloud Sherpas, commented out to prevent profile hardcoding and leverage custom permissions
            //if(DataGovernanceProfiles.contains(UserProfileName) && oApttusProposal.Agency__c != null){
            if(oApttusProposal.QuoteStatus__c <> 'Accepted Online'  &&
               PermissionCheck.hasPermission('Can_Update_Account_Billing_Address')==true && oApttusProposal.Agency__c != null){
                   system.debug('Adding agency account: ' + oApttusProposal.Agency__c);
                   AccountIds.add(oApttusProposal.Agency__c);
               }
        }
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT id, Name, BillingCity, BillingCountry, BillingState, BillingStreet, BillingPostalCode
                                                            FROM Account WHERE id IN: AccountIds]);
        system.debug('Account to be processed: ' + accountMap);
        list<Account> accountForUpdate = new list<Account>();
        String ModifiedAccountMessage = '';
        for(Apttus_Proposal__Proposal__c newProp : pUpdatedApttusProposalList){
            String modifiedAccountField = '';
            System.debug('accountMap.containsKey(newProp.Agency__c)'+accountMap.containsKey(newProp.Agency__c));
            if(newProp.Agency__c != null && accountMap.containsKey(newProp.Agency__c)){ //for Agency Account billing address update
                Account agencyAccount = accountMap.get(newProp.Agency__c);
                Boolean changedSomething = false;

                if(agencyAccount.BillingCity != newProp.BillingCity__c){
                    agencyAccount.BillingCity = newProp.BillingCity__c;
                    changedSomething = true;
                }
                if(agencyAccount.BillingCountry != newProp.BillingCountry__c){
                    agencyAccount.BillingCountry = newProp.BillingCountry__c;
                    changedSomething = true;
                }
                if(agencyAccount.BillingState != newProp.BillingStateProvince__c){
                    agencyAccount.BillingState = newProp.BillingStateProvince__c;
                    changedSomething = true;
                }
                if(agencyAccount.BillingStreet != newProp.BillingStreet__c){
                    agencyAccount.BillingStreet = newProp.BillingStreet__c;
                    changedSomething = true;
                }
                if(agencyAccount.BillingPostalCode != newProp.BillingZipPostalCode__c){
                    agencyAccount.BillingPostalCode = newProp.BillingZipPostalCode__c;
                    changedSomething = true;
                }
                if(changedSomething){
                    accountForUpdate.add(agencyAccount);
                    system.debug('Applying changes on Agency Account: ' + agencyAccount);
                    system.debug('Agency account to be updated: ' + accountForUpdate.size());
                }
            }

            if(accountMap.containsKey(newProp.Apttus_Proposal__Account__c)){ //for parent account update
                Account usedAccount = accountMap.get(newProp.Apttus_Proposal__Account__c);
                if(pOldApttusProposalMap == null || newProp.BillingCity__c != pOldApttusProposalMap.get(newProp.Id).BillingCity__c){
                    if(usedAccount.BillingCity != newProp.BillingCity__c){
                        modifiedAccountField += '<br />BillingCity:<br />';
                        modifiedAccountField += '<br />OLD: ' + usedAccount.BillingCity;
                        usedAccount.BillingCity = newProp.BillingCity__c;
                        modifiedAccountField += '<br />NEW: ' + usedAccount.BillingCity;
                    }
                }

                if(pOldApttusProposalMap == null || newProp.BillingCountry__c != pOldApttusProposalMap.get(newProp.Id).BillingCountry__c){
                    if(usedAccount.BillingCountry != newProp.BillingCountry__c){
                        modifiedAccountField += '<br /><br />BillingCountry:<br />';
                        modifiedAccountField += '<br />OLD: ' + usedAccount.BillingCountry;
                        usedAccount.BillingCountry = newProp.BillingCountry__c;
                        modifiedAccountField += '<br />NEW: ' + usedAccount.BillingCountry;
                    }
                }

                if(pOldApttusProposalMap == null || newProp.BillingStateProvince__c != pOldApttusProposalMap.get(newProp.Id).BillingStateProvince__c){
                    if(usedAccount.BillingState != newProp.BillingStateProvince__c){
                        modifiedAccountField += '<br /><br />BillingState:<br />';
                        modifiedAccountField += '<br />OLD: ' + usedAccount.BillingState;
                        usedAccount.BillingState = newProp.BillingStateProvince__c;
                        modifiedAccountField += '<br />NEW: ' + usedAccount.BillingState;
                    }
                }

                if(pOldApttusProposalMap == null || newProp.BillingStreet__c != pOldApttusProposalMap.get(newProp.Id).BillingStreet__c){
                    if(usedAccount.BillingStreet != newProp.BillingStreet__c){
                        modifiedAccountField += '<br /><br />BillingStreet:<br />';
                        modifiedAccountField += '<br />OLD: ' + usedAccount.BillingStreet;
                        usedAccount.BillingStreet = newProp.BillingStreet__c;
                        modifiedAccountField += '<br />NEW: ' + usedAccount.BillingStreet;
                    }
                }

                if(pOldApttusProposalMap == null || newProp.BillingZipPostalCode__c != pOldApttusProposalMap.get(newProp.Id).BillingZipPostalCode__c){
                    if(usedAccount.BillingPostalCode != newProp.BillingZipPostalCode__c){
                        modifiedAccountField += '<br /><br />BillingPostalCode:<br />';
                        modifiedAccountField += '<br />OLD: ' + usedAccount.BillingPostalCode;
                        usedAccount.BillingPostalCode = newProp.BillingZipPostalCode__c;
                        modifiedAccountField += 'NEW: ' + usedAccount.BillingPostalCode;
                    }
                }
                if(modifiedAccountField != ''){
                    accountForUpdate.add(usedAccount);
                    system.debug('Parent account to be updated: ' + accountForUpdate.size());
                    ModifiedAccountMessage += '<br /><br />Account ID: ' + usedAccount.Id;
                    ModifiedAccountMessage += '<br />Account Name: ' + usedAccount.Name + '<br />';
                    ModifiedAccountMessage += modifiedAccountField + '<br /><br />';
                    system.debug('Parent Account added for update: ' + usedAccount);
                }
            }
        }
        if(accountForUpdate.size() > 0){
            system.debug('Before update: Parent account to be updated: ' + accountForUpdate.size());
            update accountForUpdate;
            system.debug('Accounts updated Billing Address: ' + accountForUpdate);
            //if(!DataGovernanceProfiles.contains(UserProfileName)){ //SENDS EMAIL IF PROFILE IS NOT (Sales Operation or Data Steward)
            //commented out to prevent hard coded Ids
            if(PermissionCheck.hasPermission('Can_Update_Account_Billing_Address')==false){ //SENDS EMAIL IF PROFILE IS NOT (Sales Operation or Data Steward)
                sendAccountModifiedEmail(ModifiedAccountMessage);
            }
        }
    }
    /*
** @author : Cloud Sherpas, Inc.
** @date : 04/09/2014
** @description : Sends an email to Data Governance and Sales Operation users when an Account w/o Agency's biling address is updated
** @paramaters : A message String
** @returns : nothing
*/
    private void sendAccountModifiedEmail(String ModifiedAccountMessage){
        list<String> emailList = new list<String>();
        system.debug('Send email to:');
        for(User u : [SELECT Id, Name, email FROM User WHERE Profile.Name IN :PermissionCheck.DataGovernanceProfiles]){
            system.debug('\n' + u.Name + '\n+Email: ' + u.Email);
            emailList.add(u.Email);
        }

        Messaging.Singleemailmessage mail = new Messaging.Singleemailmessage();
        mail.setCcAddresses(emailList);
        mail.setSubject('Account Billing Updated via Quote');
        mail.setSenderDisplayName('Salesforce.com');
        mail.setHtmlBody(ModifiedAccountMessage);
        Messaging.sendEmail(new Messaging.Email[]{mail}, false);
    }

    /*
** @author : Cloud Sherpas, Inc.
** @date : 04/09/2014
** @description : this method is used to prevent any change made to the address fields when the agency field is not empty and
user profile is not Data Steward and Sales Operation
** @paramaters : an array of old Apttus_Proposal__Proposal__c Map new Apttus_Proposal__Proposal__c objects
** @returns : nothing
*/
    public void PreventUpdateOfBilling(Map<Id, Apttus_Proposal__Proposal__c> pApttusProposalOldMap, list<Apttus_Proposal__Proposal__c> pUpdatedApttusProposalList){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','PreventUpdateOfBilling');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        system.debug('User profile: ' + UserProfileName);
        /*
for(Apttus_Proposal__Proposal__c newProp : pUpdatedApttusProposalList){
if(!DataGovernanceProfiles.contains(UserProfileName) && !PermitUpdateOfBilling){
Apttus_Proposal__Proposal__c old = pApttusProposalOldMap.get(newProp.Id);
if(
(old.BillingCity__c != newProp.BillingCity__c) ||
old.BillingCountry__c != newProp.BillingCountry__c ||
old.BillingStateProvince__c != newProp.BillingStateProvince__c ||
old.BillingStreet__c != newProp.BillingStreet__c ||
old.BillingZipPostalCode__c != newProp.BillingZipPostalCode__c
){
system.debug('OLD: ' + old.BillingCity__c +' NEW: '+ newProp.BillingCity__c);
system.debug('OLD: ' + old.BillingCountry__c +' NEW: '+ newProp.BillingCountry__c);
system.debug('OLD: ' + old.BillingStateProvince__c +' NEW: '+ newProp.BillingStateProvince__c);
system.debug('OLD: ' + old.BillingStreet__c +' NEW: '+ newProp.BillingStreet__c);
system.debug('OLD: ' + old.BillingZipPostalCode__c +' NEW: '+ newProp.BillingZipPostalCode__c);
if(newProp.Agency__c != null || !OtherPermittedProfiles.contains(UserProfileName)){
newProp.addError(' You do not have the rights to change the Billing Address.');
}else{
if(OtherPermittedProfiles.contains(UserProfileName) && !newProp.MasterBillingAddressUpdate__c){
//newProp.addError(' Updating this quote\'s billing address field(s) will also update parent account\'s address field(s). Please confirm by checking Master Billing Address Update.');
newProp.addError(' To update quote\'s billing address. Please confirm by checking Master Billing Address Update.');
}
}
}
}
}
*/
    }

    /*
** @author : Cloud Sherpas, Inc.
** @date : 04/09/2014
** @description : this method is the used to POpulate Billing contact details on the Proposal.
** @paramaters : an array of Apttus_Proposal__Proposal__c objects
** @returns : nothing
*/
    /* Jeff L commented out - this method isn't being called from anywhere anymore
public void PopulateBillingContactDetails(Apttus_Proposal__Proposal__c[] pApttusProposal, map<Id, Apttus_Proposal__Proposal__c> pOldApttusProposalMap){
final string METHODNAME = CLASSNAME.replace('METHODNAME','PopulateBillingContactDetails');
system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
Set<Id> BillContacts = new Set<Id>();
for(Apttus_Proposal__Proposal__c oApttusProposal : pApttusProposal){
if(oApttusProposal.BillContact__c != null &&
oApttusProposal.BillContact__c != pOldApttusProposalMap.get(oApttusProposal.Id).BillContact__c){
BillContacts.add(oApttusProposal.BillContact__c);
}
if(oApttusProposal.Apttus_Proposal__Primary_Contact__c != oApttusProposal.Primary_Customer_Contact__c){
oApttusProposal.Apttus_Proposal__Primary_Contact__c = oApttusProposal.Primary_Customer_Contact__c;
}
}
if(!BillContacts.isEmpty() && BillContacts != null){
Map<Id,Contact> contactmap = new map<Id,Contact>([SELECT Id, Email, FirstName, LastName, Phone FROM Contact where Id in: BillContacts]);
for(Apttus_Proposal__Proposal__c oApttusProposal : pApttusProposal){
if(oApttusProposal.BillContact__c != pOldApttusProposalMap.get(oApttusProposal.Id).BillContact__c && contactmap.get(oApttusProposal.BillContact__c)!= null){
oApttusProposal.Billing_Contact_First_Name__c = contactmap.get(oApttusProposal.BillContact__c).FirstName;
oApttusProposal.Billing_Contact_Last_Name__c = contactmap.get(oApttusProposal.BillContact__c).LastName;
oApttusProposal.Telephone__c = contactmap.get(oApttusProposal.BillContact__c).Phone;
oApttusProposal.APTS_Billing_Contact_Email_Address__c = contactmap.get(oApttusProposal.BillContact__c).Email;
system.debug('!!!Bill Contact ' +  oApttusProposal.Billing_Contact_First_Name__c + oApttusProposal.Billing_Contact_Last_Name__c);

}
}
}
}*/
    /*
** @author : Cloud Sherpas, Inc.
** @date : 04/09/2014
** @description : this method is the used to copy primary contact file to Apttus primary conatct  on the Proposal.
** @paramaters : an array of Apttus_Proposal__Proposal__c objects
** @returns : nothing
*/
    public void CopyPrimaryContactToAPTTSPrimaryContact(Apttus_Proposal__Proposal__c[] pApttusProposal){
        // Do not call this method when quote is clone.
        //To Prevent 101 Soql Error, Because when Clone the Quote we dont want to execute all the triggers.added by apptus support on 2016/03/11
        if(ApttusProposalTriggerHandler.IsTriggerForCloneProposal) return;


        final string METHODNAME = CLASSNAME.replace('METHODNAME','CopyPrimaryContactToAPTTSPrimaryContact');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        //Story 2619: Contacts on quote should default from account level
        Set<Id> accIdSet = GetParentAccount(pApttusProposal);
        Map<ID, ID> agencyAccountContactIDMap = new Map<ID, ID>();

        System.debug(LoggingLevel.INFO, 'accIdSet:'+accIdSet);
        if(!accIdSet.isEmpty()){
            for(Contact con : [Select ID, accountId
                               From Contact
                               Where accountId in :accIdSet
                               And ContactStatus__c = 'Active'
                               And PrimarySalesContact__c = true]){
                                   agencyAccountContactIDMap.put(con.accountId, con.Id);
                               }
        }

        System.debug(LoggingLevel.INFO, 'agencyAccountContactIDMap:'+agencyAccountContactIDMap);
        for(Apttus_Proposal__Proposal__c proposal : pApttusProposal ){
            if(agencyAccountContactIDMap.containsKey(proposal.Apttus_Proposal__Account__c)){
                proposal.Primary_Customer_Contact__c = agencyAccountContactIDMap.get(proposal.Apttus_Proposal__Account__c);
                proposal.Apttus_Proposal__Primary_Contact__c = proposal.Primary_Customer_Contact__c;
                //proposal.PostingContact__c  = proposal.Primary_Customer_Contact__c;


            }
        }//for
    }

    /*
** @author : Cloud Sherpas, Inc.
** @date : 04/09/2014
** @description : this method is the used to POpulate Billing address on the Proposal.
** @paramaters : an array of Apttus_Proposal__Proposal__c objects
** @returns : nothing
*/
    public void PopulateBillingAddressAndCommission(Apttus_Proposal__Proposal__c[] pApttusProposal, map<Id, Apttus_Proposal__Proposal__c> pOldApttusProposalMap){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','populateBillingCountryAndBillingState');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        set<id> AccountIds = new set<id>();

        //I-160141 changes
        Schema.DescribeFieldResult fieldResult = User.Countrycode.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        Map<String,String> countrycodeMap= new  Map<String,String>();
        for( Schema.PicklistEntry f : ple){
            countrycodeMap.put(f.getLabel(), f.getValue());

        }

        for(Apttus_Proposal__Proposal__c oApttusProposal : pApttusProposal ){
            if(oApttusProposal.BillingAccount__c != null){
                AccountIds.add(oApttusProposal.BillingAccount__c);
            }
            if(oApttusProposal.Agency__c != null){
                AccountIds.add(oApttusProposal.Agency__c);
            }
            if(oApttusProposal.Apttus_Proposal__Account__c != null){
                AccountIds.add(oApttusProposal.Apttus_Proposal__Account__c);
            }
        }

        Map<id,Account> accountIdAccountMap = new map<id,Account>([SELECT id, Name, BillingCity, BillingCountry, BillingState, BillingStreet, BillingPostalCode,CreditLimit__c,PrimaryBillingContact__c
                                                                   FROM Account WHERE id IN: AccountIds]);
        //system.debug('accountIdAccountMap :'+accountIdAccountMap+'accountIdAccountMap.keySet()  :'+accountIdAccountMap.keySet());

        for(Apttus_Proposal__Proposal__c newProp : pApttusProposal){
            Account usedAccount;
            If(newProp.QuoteStatus__c <> 'Accepted Online')
            {
                // if(pOldApttusProposalMap == null || newProp.Agency__c != pOldApttusProposalMap.get(newProp.Id).Agency__c){
                if(pOldApttusProposalMap == null
                   || newProp.BillingAccount__c != pOldApttusProposalMap.get(newProp.Id).BillingAccount__c
                   || newProp.Agency__c != pOldApttusProposalMap.get(newProp.Id).Agency__c
                   || newProp.Apttus_Proposal__Account__c != pOldApttusProposalMap.get(newProp.Id).Apttus_Proposal__Account__c){


                       //added by viraj: 2016-10-13: When we change the agency to blank it will delete the address and commission. Start Address Change

                       if(newProp.Agency__c == null && pOldApttusProposalMap != null && newProp.Agency__c != pOldApttusProposalMap.get(newProp.Id).Agency__c){
                           newProp.Local_Agency_Address__c = '';
                           newProp.AgencyCommission__c = null;
                           newProp.AgencyBillingContact__c = null;
                           newProp.Agency_Billing_Contact_Email_Address__c = null;
                           newProp.AgencyIO__c = '';
                           newProp.BillingAccount__c = newProp.Apttus_Proposal__Account__c;
                           if(accountIdAccountMap.containsKey(newProp.BillingAccount__c) && accountIdAccountMap.get(newProp.BillingAccount__c).PrimaryBillingContact__c != null){
                               newProp.BillContact__c = accountIdAccountMap.get(newProp.BillingAccount__c).PrimaryBillingContact__c;
                           }
                       }
                       //End Address Change

                       if(newProp.Agency__c != null && accountIdAccountMap.containsKey(newProp.Agency__c)){
                           usedAccount = accountIdAccountMap.get(newProp.Agency__c);
                           newProp.Local_Agency_Address__c = usedAccount.BillingStreet+',\r\n'+
                               usedAccount.BillingCity+',\r\n'+
                               usedAccount.BillingState+' - '+
                               usedAccount.BillingPostalCode+'\r\n'+
                               usedAccount.BillingCountry;

                       }else if(newProp.BillingAccount__c != null && accountIdAccountMap.containsKey(newProp.BillingAccount__c)){
                           usedAccount = accountIdAccountMap.get(newProp.BillingAccount__c);
                       }else if(newProp.Apttus_Proposal__Account__c != null && accountIdAccountMap.containsKey(newProp.Apttus_Proposal__Account__c)){
                           usedAccount = accountIdAccountMap.get(newProp.Apttus_Proposal__Account__c);
                       }
                   }
                 //I-160141 changes
                 if(pOldApttusProposalMap == null || newProp.BillingCountry__c != pOldApttusProposalMap.get(newProp.Id).BillingCountry__c){
                        if(countrycodeMap.containsKey(newProp.BillingCountry__c))
                        newProp.Billing_Country_Code__c =countrycodeMap.get(newProp.BillingCountry__c);
                    }


                if(usedAccount != null){
                    system.debug('Account selected for quote billing update.'+usedAccount);
                    if(pOldApttusProposalMap == null || newProp.BillingCountry__c == pOldApttusProposalMap.get(newProp.Id).BillingCountry__c){
                        newProp.BillingCountry__c = usedAccount.BillingCountry;
                        //I-160141 changes
                        if(countrycodeMap.containsKey(newProp.BillingCountry__c))
                        newProp.Billing_Country_Code__c =countrycodeMap.get(newProp.BillingCountry__c);

                    }
                    if(pOldApttusProposalMap == null || newProp.BillingStateProvince__c == pOldApttusProposalMap.get(newProp.Id).BillingStateProvince__c){
                        newProp.BillingStateProvince__c = usedAccount.BillingState;
                    }

                    if(pOldApttusProposalMap == null || newProp.BillingCity__c == pOldApttusProposalMap.get(newProp.Id).BillingCity__c){
                        newProp.BillingCity__c = usedAccount.BillingCity;
                    }

                    if(pOldApttusProposalMap == null || newProp.BillingStreet__c == pOldApttusProposalMap.get(newProp.Id).BillingStreet__c){
                        newProp.BillingStreet__c = usedAccount.BillingStreet;
                    }

                    if(pOldApttusProposalMap == null || newProp.BillingZipPostalCode__c == pOldApttusProposalMap.get(newProp.Id).BillingZipPostalCode__c){
                        newProp.BillingZipPostalCode__c = usedAccount.BillingPostalCode;
                    }

                }
            }
        }
    }

    /*
    ** @author : Apttus - Viraj
    ** @date : 10/14/2016
    ** @description : (Case#  00204135) This Method is for when the Agency is removed from the Quote\Proposal then we have to remove the Agency Commision from the Cart Line Item.
    ** @returns : Nothing
    */

    Public void UpdateConfigurationLineItemAgencyCommissionValue(Apttus_Proposal__Proposal__c[] pNewApttusProposal,Map<Id,Apttus_Proposal__Proposal__c> oldMap,Map<Id,Apttus_Proposal__Proposal__c> NewMap){
        Set<String> setProposalId = new Set<String>();

        for(Apttus_Proposal__Proposal__c obj: pNewApttusProposal){
            System.debug('obj.Agency__c121212' + obj.Agency__c);
            System.debug('obj.Agency__c121212' + oldMap.get(obj.Id).Agency__c);
            //if(obj.Agency__c == null && oldMap.get(obj.Id).Agency__c != null){
                setProposalId.add(obj.Id);
            //}
        }

        If(setProposalId.Size() > 0){
            List<Apttus_Config2__LineItem__c> lstLineItem = [Select id,AgencyCommission__c,Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c
                                                            From Apttus_Config2__LineItem__c
                                                            where Apttus_Config2__ConfigurationId__c in (Select id from Apttus_Config2__ProductConfiguration__c Where Apttus_QPConfig__Proposald__c In : setProposalId and Apttus_Config2__Status__c in ('New','Approval Required','Saved')) ];
            for(Apttus_Config2__LineItem__c objLineItem :lstLineItem){
                if(NewMap.Containskey(objLineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c)){
                    objLineItem.AgencyCommission__c = NewMap.get(objLineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c).AgencyCommission__c ;
                }
            }

            update lstLineItem;
        }

    }

    public void UpdateStateandCountry(Apttus_Proposal__Proposal__c[] pApttusProposal)
    {
        List<SellingCountryAndStateabbreviation__c> lstSellingCountryAndStateabbreviation = SellingCountryAndStateabbreviation__c.getAll().values();

        Map<String,String> mapStateCodeToName = new Map<String,String>();
        Map<String,String> mapCountryCodeToName = new Map<String,String>();

        for(SellingCountryAndStateabbreviation__c SellingCountryAndState : lstSellingCountryAndStateabbreviation)
        {
            mapCountryCodeToName.put(SellingCountryAndState.CountryCode__c, SellingCountryAndState.CountryName__c);
        }
        //System.debug('sweety** mapCountryCodeToName'+ mapCountryCodeToName);

        for(Apttus_Proposal__Proposal__c oApttusProposal : pApttusProposal ){

            // System.debug('sweety**oApttusProposal.BillingCountry__c'+oApttusProposal.BillingCountry__c);
            if(mapCountryCodeToName.containsKey(oApttusProposal.BillingCountry__c))
            {
                //System.debug('sweety** oApttusProposal.BillingCountry__c'+ oApttusProposal.BillingCountry__c);
                oApttusProposal.BillingCountry__c = mapCountryCodeToName.get(oApttusProposal.BillingCountry__c);
            }

            for(SellingCountryAndStateabbreviation__c SellingCountryAndState : lstSellingCountryAndStateabbreviation)
            {
                if(SellingCountryAndState.CountryName__c == oApttusProposal.BillingCountry__c)
                {
                    mapStateCodeToName.put(SellingCountryAndState.StateCode__c, SellingCountryAndState.StateName__c);
                }
            }
            //System.debug('sweety** mapStateCodeToName'+ mapStateCodeToName);
            // System.debug('sweety**oApttusProposal.BillingStateProvince__c'+oApttusProposal.BillingStateProvince__c);
            // for(String str : mapStateCodeToName.keySet())
            // {
            //  system.debug('sweety*'+str);
            // }

            if(mapStateCodeToName.containsKey(oApttusProposal.BillingStateProvince__c))
            {
                //  System.debug('sweety***mapStateCodeToName.get(oApttusProposal.BillingStateProvince__c)'+mapStateCodeToName.get(oApttusProposal.BillingStateProvince__c));
                oApttusProposal.BillingStateProvince__c = mapStateCodeToName.get(oApttusProposal.BillingStateProvince__c);
            }
        }
    }

    /*
** @author : Cloud Sherpas, Inc.
** @date : 04/10/2014
** @description : Sets or Updates Quote Owner Manager and the Quote Owners Managers Manager in a list of Apttus_Proposal__Proposal__c object
** @paramaters : List of Apttus_Proposal__Proposal__c objects, Map of Updated Apttus_Proposal__Proposal__c object, Map of Old Apttus_Proposal__Proposal__c object
** @returns : Nothing
*/
    public void SetQuoteOwnerMangersOnApttusProposalProposal(list<Apttus_Proposal__Proposal__c> pApttusProposalList, map<Id,Apttus_Proposal__Proposal__c> pUpdatedApttusProposalMap, map<Id,Apttus_Proposal__Proposal__c> pOldApttusProposalMap){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','SetQuoteOwnerMangersOnApttusProposalProposal');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        for(Apttus_Proposal__Proposal__c apttusProposal : pApttusProposalList){

            if(pUpdatedApttusProposalMap != NULL){
                if(pUpdatedApttusProposalMap.containsKey(apttusProposal.Id)){

                    if(pUpdatedApttusProposalMap.get(apttusProposal.Id).OwnerId != pOldApttusProposalMap.get(apttusProposal.Id).OwnerId){
                        SetQuoteOwnerManagers(apttusProposal, pApttusProposalList.size());
                    }
                }
            }else{
                SetQuoteOwnerManagers(apttusProposal, pApttusProposalList.size());
            }
        }
    }

    /*
** @author : Cloud Sherpas, Inc.
** @date : 04/10/2014
** @description : Set the Quote Owner Manager and the Quote Owners Managers Manager on a Apttus_Proposal__Proposal__c object
** @paramaters : Apttus_Proposal__Proposal__c
** @returns : Nothing
*/
    private void SetQuoteOwnerManagers(Apttus_Proposal__Proposal__c pApttusProposal, Integer propSize){

        if (propSize <= cutoff){ //JFreese Appirio S-435483 4/10/17
          final string METHODNAME = CLASSNAME.replace('METHODNAME','SetQuoteOwnerManagers');
          system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        }

        if(UserIdToUserMap.containsKey(pApttusProposal.OwnerId) && !String.isBlank(UserIdToUserMap.get(pApttusProposal.OwnerId).ManagerId)){
            pApttusProposal.QuoteOwnerManager__c = UserIdToUserMap.get(pApttusProposal.OwnerId).ManagerId;
        }else{
            pApttusProposal.QuoteOwnerManager__c = NULL;
        }

        if(UserIdToUserMap.containsKey(pApttusProposal.QuoteOwnerManager__c) && !String.isBlank(UserIdToUserMap.get(pApttusProposal.QuoteOwnerManager__c).ManagerId)){
            pApttusProposal.QuoteOwner2ndManager__c = UserIdToUserMap.get(pApttusProposal.QuoteOwnerManager__c).ManagerId;
        }else{
            pApttusProposal.QuoteOwner2ndManager__c = NULL;
        }
    }

    /*
** @author : Cloud Sherpas, Inc.
** @date : 04/11/2014
** @description : Set the Apttus_Proposal__Proposal__c Pricing Channel to Account Pricing Channel
** @paramaters : list of Apttus_Proposal__Proposal__c
** @returns : nothing
*/
    public void SetQuotePricingChannelToAccountDefaultPricingChannel(list<Apttus_Proposal__Proposal__c> pApttusProposalList, map<Id, Account> accMap){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','SetQuotePricingChannelToAccountDefaultPricingChannel');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        /*set<Id> accountIdSet = new set<Id>();
for(Apttus_Proposal__Proposal__c apttusProposal : pApttusProposalList){
accountIdSet.add(apttusProposal.Apttus_Proposal__Account__c);
}

map<Id, Account> accountIdToAccountMap = new map<Id, Account>([SELECT Id, PricingAccount__c FROM Account WHERE Id IN : accountIdSet]);*/
        map<Id, Account> accountIdToAccountMap = accMap;

        for(Apttus_Proposal__Proposal__c apttusProposal : pApttusProposalList){
            if(accountIdToAccountMap.containsKey(apttusProposal.Apttus_Proposal__Account__c)){
                apttusProposal.Pricing_Channel__c = accountIdToAccountMap.get(apttusProposal.Apttus_Proposal__Account__c).PricingAccount__c;
            }
        }
    }

    /*
** @author : Cloud Sherpas, Inc.
** @date : 04/09/2014
** @description : this method is used to default the Payment Method and Payment Term from Account to Proposal Quote.
** @paramaters : an array of Apttus_Proposal__Proposal__c objects
** @returns : nothing
*//*
public void SetPaymentMethodAndPaymentTerm(Apttus_Proposal__Proposal__c[] pNewApttusProposal){
final string METHODNAME = CLASSNAME.replace('METHODNAME','SetPaymentMethodAndPaymentTerm');
system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, PaymentMethod__c, PaymentTerms__c FROM Account WHERE Id IN :GetParentAccount(pNewApttusProposal)]);
system.debug('Get Payment Term and Method from this accounts: ' + accountMap);
for(Apttus_Proposal__Proposal__c apq : pNewApttusProposal){
if(accountMap.containsKey(apq.Apttus_Proposal__Account__c)){
if(accountMap.get(apq.Apttus_Proposal__Account__c).PaymentMethod__c!=NULL) {
apq.PaymentMethod__c = accountMap.get(apq.Apttus_Proposal__Account__c).PaymentMethod__c;
}
if(accountMap.get(apq.Apttus_Proposal__Account__c).PaymentTerms__c!=NULL) {
apq.PaymentTerm__c = accountMap.get(apq.Apttus_Proposal__Account__c).PaymentTerms__c;
}
}
}
} */

    /*
** @author : Cloud Sherpas, Inc.
** @date : 05/13/2014
** @description : this method populates billing Contact field of order from Account's Primary Billing Contact
** @paramaters : List of proposals
** @returns : nothing
** @Element : E1577
** @Story : 0648
*/
    public void populateBillingContactFromAccount(Apttus_Proposal__Proposal__c[] pNewApttusProposal){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populateBillingContactFromAccount');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        /*Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Name , PrimaryBillingContact__c, PrimaryBillingContact__r.Email,
PrimaryBillingContact__r.FirstName, PrimaryBillingContact__r.LastName,
PrimaryBillingContact__r.Phone
FROM Account
WHERE Id IN :GetBillingAccount(pNewApttusProposal)]);*/
        Map<Id, Id> agencyAccountContactIDMap = new Map<Id, Id>();
        Map<Id,Contact> contactdetails = new Map<Id,Contact>();
        /*for(Contact con : [Select ID, accountId, FirstName, LastName, Phone, Email
From Contact
Where accountId in :GetBillingAccount(pNewApttusProposal)
And ContactStatus__c = 'Active'
And PrimarySalesContact__c = true]){
agencyAccountContactIDMap.put(con.accountId, con.Id);
contactdetails.put(con.Id,con);

}
*/

        for(Contact con : [Select ID, accountId, FirstName, LastName, Phone, Email,InvoiceDeliveryMethod__c
                           From Contact
                           Where Id in :GetBillingContact(pNewApttusProposal)
                          ]){
                              contactdetails.put(con.Id,con);

                          }
        /**/
        //Mihir Shah - 10/02/2015
        if (pNewApttusProposal.size() <= cutoff){ //JFreese Appirio S-435483 4/11/17
          system.debug('Get Payment Term and Method from this accounts: ' + agencyAccountContactIDMap);
          system.debug('contactdetails'+contactdetails);
        }
        for(Apttus_Proposal__Proposal__c apq : pNewApttusProposal){
            if (pNewApttusProposal.size() <= cutoff || apq.Id == debugId){ //JFreese Appirio S-435483 4/11/17
              system.debug('apq.QuoteStatus__c: ' + apq.QuoteStatus__c);
              //I-191155 Jeff L moved this into a formula field
              //system.debug('apq.Billing_Contact_First_Name__c: ' + apq.Billing_Contact_First_Name__c);
              //system.debug('apq.Billing_Contact_Last_Name__c: ' + apq.Billing_Contact_Last_Name__c);
              system.debug('apq.BillingAccount__c:  '+apq.BillingAccount__c+'agencyAccountContactIDMap.get(apq.BillingAccount__c)  :'+agencyAccountContactIDMap.get(apq.BillingAccount__c));
            }
            /*if(agencyAccountContactIDMap.containsKey(apq.BillingAccount__c) &&
agencyAccountContactIDMap.get(apq.BillingAccount__c) != null){
// apq.BillContact__c = agencyAccountContactIDMap.get(apq.BillingAccount__c);
// I-191155 Jeff L moved into a formula field
//apq.Billing_Contact_First_Name__c =  contactdetails.get(apq.BillContact__c).FirstName;
//apq.Billing_Contact_Last_Name__c = contactdetails.get(apq.BillContact__c).LastName;
//apq.Telephone__c = contactdetails.get(apq.BillContact__c).Phone;
system.debug('Inside the Condition-->  apq.BillContact__c-->' + apq.BillContact__c);
if(contactdetails.containsKey(apq.BillContact__c))
{
system.debug('Email Found-->');
apq.APTS_Billing_Contact_Email_Address__c = contactdetails.get(apq.BillContact__c).Email;
}
}*/
            //System.assert(false,apq.BillContact__c+'===='+contactdetails+'==='+contactdetails.get(apq.BillContact__c).Email);
            if(contactdetails.containsKey(apq.BillContact__c))
            {
                if (pNewApttusProposal.size() <= cutoff || apq.Id == debugId){ //JFreese Appirio S-435483 4/11/17
                  system.debug('Email Found-->');
                }
                apq.APTS_Billing_Contact_Email_Address__c = contactdetails.get(apq.BillContact__c).Email;
                apq.InvoiceDeliveryMethod__c = contactdetails.get(apq.BillContact__c).InvoiceDeliveryMethod__c;

            }
        }
    }

    /*
** @author : Cloud Sherpas, Inc.
** @date : 15/12/2014
** @description : this method populates primary Xcode from Account in proposal
** @paramaters : List of proposal
** @returns : nothing
** @Element :
** @Story : 2398
*/
    public void populateXcodeFromAccount(Apttus_Proposal__Proposal__c[] pNewApttusProposal){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populateXcodeFromAccount');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        Map<Id, Id> xcodeAccountIDMap = new Map<Id, Id>();
        for(XcodeAccount__c pxcode : [Select Id, Account__c, IsPrimary__c, Xcode__c
                                      From XcodeAccount__c
                                      Where Account__c in :GetParentAccount(pNewApttusProposal)
                                      And IsPrimary__c = true]){
                                          xcodeAccountIDMap.put(pxcode.Account__c,pxcode.Id);

                                      }
        system.debug('Xcode and Accounts :'+xcodeAccountIDMap);
        for(Apttus_Proposal__Proposal__c prop : pNewApttusProposal){
            if(prop.Apttus_Proposal__Account__c != null && xcodeAccountIDMap.get(prop.Apttus_Proposal__Account__c) != null){
                prop.XcodeAccount__c = xcodeAccountIDMap.get(prop.Apttus_Proposal__Account__c);
            }
        }

    }

    /*
Geeta kumawat Appirio
I-192321
12/14/15
*/
    public void updateXcodeOnOrderLineItem(Apttus_Proposal__Proposal__c[] pNewApttusProposal,Map<Id,Apttus_Proposal__Proposal__c> oldMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateXcodeOnOrderLineItem');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        Map<Id, Id> xcodeAccountIDMap = new Map<Id, Id>();
        List<Order_Line_Item__c> oliToBeUpdateList = new List<Order_Line_Item__c>();
        for(Apttus_Proposal__Proposal__c prop  : pNewApttusProposal){

            if(prop.XcodeAccount__c != null && prop.XcodeAccount__c != oldMap.get(prop.Id).XcodeAccount__c){
                xcodeAccountIDMap.put(prop.Id,prop.XcodeAccount__c);
            }

        }
        if(!xcodeAccountIDMap.isEmpty()){

            for(Apttus_Proposal__Proposal__c prop :[Select Id, (Select Id, Xcode_lkp__c From Order_Line_Items__r)
                                                    From Apttus_Proposal__Proposal__c  where Id in :xcodeAccountIDMap.keyset() ]){
                                                        for(Order_Line_Item__c oli : prop.Order_Line_Items__r){
                                                            oli.Xcode_lkp__c = xcodeAccountIDMap.get(prop.Id);
                                                            oliToBeUpdateList.add(oli);
                                                        }
                                                    }

            update oliToBeUpdateList;
        }

    }

    /*
** @author : Cloud Sherpas, Inc.
** @date : 05/19/2014
** @description : this method restricts Edit on Proposal based on criteria
** @paramaters : List of Orders
** @returns : nothing
** @Element : E0286
** @Story : 0161, 0198
*/
    public void restrictEditability(Map<Id, Apttus_Proposal__Proposal__c> pUpdatedApttusProposalMap, Map<Id, Apttus_Proposal__Proposal__c> pOldApttusProposalMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','restrictEditability');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        //Get Opportunity Details - OrderCreated__c
        //A Quote in Order Placed cannot be made active again
        Map<Id, Apttus_Proposal__Proposal__c> proposalOpptyDetailsMap =
            new Map<Id, Apttus_Proposal__Proposal__c>([
                Select ID, Apttus_Proposal__Opportunity__r.OrderCreated__c
                From Apttus_Proposal__Proposal__c
                Where ID IN :pUpdatedApttusProposalMap.keySet()]);

        //system.debug('proposalOpptyDetailsMap:' + proposalOpptyDetailsMap);
        //system.debug('UserProfileName:' + UserProfileName);

        Boolean isOrderCreated = false;
        String oldQuoteStatus;
        for(Apttus_Proposal__Proposal__c proposal: pUpdatedApttusProposalMap.values()){
            //system.debug('proposal.QuoteStatus__c:' + proposal.QuoteStatus__c);
            isOrderCreated = false;
            oldQuoteStatus = pOldApttusProposalMap.get(proposal.ID).QuoteStatus__c;
            try{
                isOrderCreated = proposalOpptyDetailsMap.get(proposal.ID).Apttus_Proposal__Opportunity__r.OrderCreated__c;
            }catch(Exception ex){
                System.debug('Exception occured in restrictEditability:'+ex.getMessage());
            }

            //There is administrative ability to turn a quote 'back on' (Sales Ops, System Admin)
            //Cloud Sherpas, commented out to prevent profile hardcoding and leverage custom permissions
            //if(!editabilityProfiles.contains(UserProfileName)){
            if(PermissionCheck.hasPermission('Can_Turn_On_Quotes')==true){
                //Need the ability to prevent edit on quote once the quote is turned "off"
                //A Quote in Closed cannot be made active again
                if(oldQuoteStatus == 'Inactive' || oldQuoteStatus == 'Expired' || oldQuoteStatus == 'Closed'){
                       //system.debug('Cannot Edit Proposal once the Quote Status is Inactive, Expired or Closed.');
                       proposal.addError('Cannot Edit Proposal once the Quote Status is Inactive, Expired or Closed.');
                   }else if(proposal.QuoteStatus__c == 'Presented Quote' && proposal.QuoteStatus__c == oldQuoteStatus){
                                /*
User Story 0198:
Sales Rep Ability to change payment terms after a quote has been presented online
*/

                                if(!(proposal.Organization__c == 'North America' &&
                                     proposal.Payment_Term__c != pOldApttusProposalMap.get(proposal.ID).Payment_Term__c)){
                                         //system.debug('Cannot Edit Proposal once the Quote Status is Presented Quote.');
                                         proposal.addError('Cannot Edit Proposal once the Quote Status is Presented Quote.');
                                     }
                            }
                // moved it inside the profile based condition.
                if(isOrderCreated &&  proposal.QuoteStatus__c != 'Expired' && proposal.QuoteStatus__c != 'Closed' && proposal.QuoteStatus__c != 'Inactive' &&  proposal.QuoteStatus__c != 'Accepted Offline' &&  proposal.QuoteStatus__c != 'Accepted Online' && proposal.QuoteStatus__c != oldQuoteStatus
                  ){
                      system.debug('A Quote in Order Placed cannot be made active again.');
                      proposal.addError('A Quote in Order Placed cannot be made active again.');
                  }
            }

        }
    }

    /*
** @author : Cloud Sherpas, Inc.
** @date : 05/26/2014
** @description : As a Finance Team I want to be able to set a minimum installment value threshold per country
**                  so that I can dictate installment thresholds on a country to country basis
** @paramaters : List of Orders
** @returns : nothing
** @Element : E1796
** @Story : 0805
*/
    public void checkMinimumInstallment(List<Apttus_Proposal__Proposal__c> pNewApttusProposalList, Map<Id,Apttus_Proposal__Proposal__c>pOldProposalMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','checkMinimumInstallment');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        Map<String, CountryCode__c> countryCodeMap = CountryCode__c.getAll();

        Map<String, InstallmentValueThreshold__c> minInstallValueMap = InstallmentValueThreshold__c.getAll();
        String Key;
        String countryCode;
        Double minInstallmentValue;
        for(Apttus_Proposal__Proposal__c proposal: pNewApttusProposalList){
            //System.Debug('Proposal:'+proposal);
            //System.Debug('Payment__c:'+proposal.Payment__c);
            proposal.NSSA_Minimum_Installment__c = false;
            if(proposal.Payment__c == 'Yes'){
                key = '';
                //System.Debug('Selling_Country__c'+proposal.Selling_Country__c);
                //System.Debug('CurrencyIsoCode'+proposal.CurrencyIsoCode);
                countryCode = countryCodeMap.containsKey(proposal.Selling_Country__c) ?
                    countryCodeMap.get(proposal.Selling_Country__c).Country_Code__c :
                '';
                key = countryCode + '-' + proposal.CurrencyIsoCode;
                // System.Debug('Key:'+key);
                if(minInstallValueMap.containsKey(key)){
                    minInstallmentValue = minInstallValueMap.get(key).Minimum_Installment__c;
                    //System.Debug('minInstallmentValue:' + minInstallmentValue);
                    //System.Debug('Installment_Amount__c:'+proposal.Installment_Amount__c);
                    if(proposal.Installment_Amount__c != null &&
                       proposal.Installment_Amount__c < minInstallmentValue){
                           proposal.NSSA_Minimum_Installment__c = true;
                       }
                    //System.Debug('NSSA_Minimum_Installment__c:'+proposal.NSSA_Minimum_Installment__c);
                }else{
                    System.Debug('Minimum Installment Value not defined for :'+key);
                }
            }
            //Story 2452 - Update QuoteStatus to Accepted Online when echosign updated the Approval Stage to Accepted
            //added Expired check for I-223447
            if( (proposal.Apttus_Proposal__Approval_Stage__c == 'Accepted' &&  proposal.QuoteStatus__c !='Expired') &&
               (proposal.QuoteStatus__c != 'Accepted Online' || proposal.QuoteStatus__c != ' Accepted Offline')){
                   proposal.QuoteStatus__c = 'Accepted Online';
                   updateOpportunityStage(pNewApttusProposalList,pOldProposalMap);

               }
        }//for
        return;
    }

    public void setPaymentDetailsFromAccount(List<Apttus_Proposal__Proposal__c> pNewApttusProposalList, Map<ID, Opportunity> opportunityMap,map<Id, Account> accMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','setPaymentDetailsFromAccount');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));




        map<Id, Account> parentAccountMap = accMap;

        List<Id> agencyAccountIDList = new List<Id>();
        system.debug(LoggingLevel.INFO, 'parentAccountMap:'+parentAccountMap);

        for(Opportunity oppty: opportunityMap.values()){
            if(oppty.Agency__c != null){
                agencyAccountIDList.add(oppty.Agency__c);
            }
        }






        Map<Id, Id> agencyAccountContactIDMap = new Map<Id, Id>();
        //Query Agency Contacts
        if(!agencyAccountIDList.isEmpty()){
            for(Contact con : [Select ID, accountId
                               From Contact
                               Where accountId in :agencyAccountIDList
                               And ContactStatus__c = 'Active'
                               And PrimarySalesContact__c = true]){
                                   agencyAccountContactIDMap.put(con.accountId, con.Id);
                               }
        }
        system.debug(LoggingLevel.INFO, 'agencyAccountContactIDMap:' + agencyAccountContactIDMap);






        for(Apttus_Proposal__Proposal__c prop : pNewApttusProposalList){
            if(parentAccountMap.containsKey(prop.Apttus_Proposal__Account__c)){
                Account acct = parentAccountMap.get(prop.Apttus_Proposal__Account__c);
                prop.PaymentDetails__c = acct.PaymentDetails__c;
                //Story 2373: "Agency Commission" and "Agency Billing Contact" Not Carried Over
                if(opportunityMap.containskey(prop.Apttus_Proposal__Opportunity__c)) {
                    Opportunity opportunity = opportunityMap.get(prop.Apttus_Proposal__Opportunity__c);

                    Account agencyAccount = opportunity.Agency__r;
                    if(agencyAccount != null && opportunity.recordType.Name != 'GCS Opportunity'){

                        // added If condition for  I-227642
                        if(prop.RelatedQuoteProposal__c==null )
                        {
                            prop.Agency__c = opportunity.Agency__c;
                            prop.AgencyCommission__c = opportunity.Agency__r.AgencyCommission__c;
                            //Story : 2706 update the Local Agency Address with Agency billing address.
                            prop.Local_Agency_Address__c = opportunity.Agency__r.BillingStreet+',\r\n'+
                                opportunity.Agency__r.BillingCity+',\r\n'+
                                opportunity.Agency__r.BillingState+' - '+
                                opportunity.Agency__r.BillingPostalCode+'\r\n'+
                                opportunity.Agency__r.BillingCountry;
                            /*if(acct.PrimaryBillingContact__c != null){
                            prop.AgencyBillingContact__c = acct.PrimaryBillingContact__c;
                            }else*/ if(agencyAccountContactIDMap.containsKey(opportunity.Agency__c)){
                                prop.AgencyBillingContact__c = agencyAccountContactIDMap.get(opportunity.Agency__c);
                                //on insert if billing Account is equal to Agency then
                            }
                        }




                       }
                }

            }

        }
    }



    public void setAgencyBillingContactBasedOnAgencyPopulated(List<Apttus_Proposal__Proposal__c> pNewApttusProposalList){
        List<Id> agencyAccountIDList = new List<Id>();

        for(Apttus_Proposal__Proposal__c prop : pNewApttusProposalList){
            if(prop.Agency__c != null)
                agencyAccountIDList.add(prop.Agency__c );

        }

        Map<Id, Id> agencyAccountContactIDMap = new Map<Id, Id>();
        //Query Agency Contacts
        if(!agencyAccountIDList.isEmpty()){
            for(Contact con : [Select ID, accountId
                               From Contact
                               Where accountId in :agencyAccountIDList
                               And ContactStatus__c = 'Active'
                               And PrimarySalesContact__c = true]){
                                   agencyAccountContactIDMap.put(con.accountId, con.Id);
                               }
        }
        //system.assert(false ,agencyAccountContactIDMap );
        system.debug(LoggingLevel.INFO, 'agencyAccountContactIDMap:' + agencyAccountContactIDMap);

        for(Apttus_Proposal__Proposal__c prop : pNewApttusProposalList){
            //system.assert(false ,agencyAccountContactIDMap.containskEy(prop.Agency__c ) );
            if(prop.Agency__c != null && agencyAccountContactIDMap.containskEy(prop.Agency__c ) && prop.AgencyBillingContact__c==null)
                prop.AgencyBillingContact__c = agencyAccountContactIDMap.get(prop.Agency__c);
        }
    }

    /*
** @author : Cloud Sherpas, Inc.
** @date : 05/26/2014
** @description : Will set the payment detail of the parent account when Payment Details is updated
** @paramaters : List of Orders
** @returns : nothing
** @Element : E2076
** @Story : 0942
*/
    // commented as it is not being invoked from anywhere
    /*public void setPaymentDetailsOfAccountFromProposal(List<Apttus_Proposal__Proposal__c> pNewApttusProposalList, map<Id, Apttus_Proposal__Proposal__c> pOldApttusProposalMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','setPaymentDetailsOfAccountFromProposal');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        set<Id> accountIdSet = new set<Id>();
        for(Apttus_Proposal__Proposal__c prop : pNewApttusProposalList){
            if(!prop.Non_Standard_Payment_Request__c && prop.PaymentDetails__c != null && prop.Apttus_Proposal__Account__c != null && pOldApttusProposalMap.get(prop.Id).PaymentDetails__c != prop.PaymentDetails__c){
                accountIdSet.add(prop.Apttus_Proposal__Account__c);
            }
        }
        if(accountIdSet.isEmpty()){
            system.debug('\n\nExiting no updated payment detail.\n\n');
            return;
        }
        map<Id, Account> parentAccountMap = new map<Id, Account>([SELECT PaymentDetails__c FROM Account
                                                                  WHERE Id IN :accountIdSet]);

        if(parentAccountMap.size() == 0){
            system.debug('\n\nExiting no updated payment detail.\n\n');
            return;
        }

        for(Apttus_Proposal__Proposal__c prop : pNewApttusProposalList){
            if(parentAccountMap.containsKey(prop.Apttus_Proposal__Account__c)){
                parentAccountMap.get(prop.Apttus_Proposal__Account__c).PaymentDetails__c = prop.PaymentDetails__c;
            }
        }

        AccountTriggerHandler.ExecuteTriggers = false;
        update parentAccountMap.values();
    }
*/


    /*
** @author : Cloud Sherpas, Inc.
** @date : 11/21/2014
** @description : update the Account Billing Address if Quote billing Address is changed.
** @paramaters : List of proposal
** @returns : nothing
** @Element : E1808
** @Story :0954
*/

    public void updateAccountBillingFromProposal(List<Apttus_Proposal__Proposal__c> pNewApttusProposalList, map<Id, Apttus_Proposal__Proposal__c> pOldApttusProposalMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateAccountBillingFromProposal');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        set<Id> accountIdSet = new set<Id>();
        List<Apttus_Proposal__Proposal__c> changepropoposal= new List<Apttus_Proposal__Proposal__c>();
         //I-160141 changes
        Schema.DescribeFieldResult fieldResult = User.Countrycode.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        Map<String,String> countrycodeMap= new  Map<String,String>();

        for( Schema.PicklistEntry f : ple){
            countrycodeMap.put(f.getValue(),f.getLabel() );


        }


        for(Apttus_Proposal__Proposal__c prop : pNewApttusProposalList){
            //if(prop.QuoteStatus__c <> 'Accepted Online') I-160141
            if(prop.QuoteStatus__c == 'Accepted Online')
            {
                System.debug('prop.BillingStreet__c:: ' + prop.BillingStreet__c+' pOldApttusProposalMap.get(prop.Id).BillingStreet__c  '+pOldApttusProposalMap.get(prop.Id).BillingStreet__c);
                System.debug('prop.BillingCity__c:: ' + prop.BillingCity__c+' pOldApttusProposalMap.get(prop.Id).BillingCity__c  '+pOldApttusProposalMap.get(prop.Id).BillingCity__c);
                System.debug('prop.BillingStateProvince__c:: ' + prop.BillingStateProvince__c+' pOldApttusProposalMap.get(prop.Id).BillingStateProvince__c  '+pOldApttusProposalMap.get(prop.Id).BillingStateProvince__c);
                System.debug('prop.BillingCountry__c:: ' + prop.BillingStreet__c+' pOldApttusProposalMap.get(prop.Id).BillingCountry__c  '+pOldApttusProposalMap.get(prop.Id).BillingCountry__c);
                System.debug('prop.BillingZipPostalCode__c:: ' + prop.BillingZipPostalCode__c+' pOldApttusProposalMap.get(prop.Id).BillingZipPostalCode__c  '+pOldApttusProposalMap.get(prop.Id).BillingZipPostalCode__c);
                  System.debug('prop.Billing_Country_Code__c:: ' + prop.Billing_Country_Code__c+' pOldApttusProposalMap.get(prop.Id).Billing_Country_Code__c  '+pOldApttusProposalMap.get(prop.Id).Billing_Country_Code__c);


                //I-160141 changes
                if(prop.Billing_Country_Code__c!=null && countrycodeMap.containsKey( (prop.Billing_Country_Code__c).trim()  )){

                    prop.BillingCountry__c=countrycodeMap.get((prop.Billing_Country_Code__c).trim() );

                }


                if(prop.BillingStreet__c != pOldApttusProposalMap.get(prop.Id).BillingStreet__c ||
                   prop.BillingCity__c != pOldApttusProposalMap.get(prop.Id).BillingCity__c ||
                   prop.BillingStateProvince__c != pOldApttusProposalMap.get(prop.Id).BillingStateProvince__c ||
                   prop.BillingCountry__c != pOldApttusProposalMap.get(prop.Id).BillingCountry__c ||
                   prop.BillingZipPostalCode__c != pOldApttusProposalMap.get(prop.Id).BillingZipPostalCode__c){
                       changepropoposal.add(prop);
                       accountIdSet.add(prop.Apttus_Proposal__Account__c);
                   }
            }
        }

        if(accountIdSet.isEmpty()){
            system.debug('\n\nExiting no updated payment detail.\n\n');
            return;
        }
        map<Id, Account> parentAccountMap = new map<Id, Account>([SELECT Id, BillingStreet,
                                                                  BillingCity,
                                                                  BillingState,
                                                                  BillingCountry,
                                                                  BillingPostalCode FROM Account
                                                                  WHERE Id IN :accountIdSet]);

        list<Account> changeAccount = new list<Account>();
        for(Apttus_Proposal__Proposal__c prop : changepropoposal){
            if(parentAccountMap.containsKey(prop.Apttus_Proposal__Account__c) &&
               (prop.BillingStreet__c != parentAccountMap.get(prop.Apttus_Proposal__Account__c).BillingStreet ||
                prop.BillingCity__c != parentAccountMap.get(prop.Apttus_Proposal__Account__c).BillingCity ||
                prop.BillingStateProvince__c != parentAccountMap.get(prop.Apttus_Proposal__Account__c).BillingState ||
                prop.BillingCountry__c != parentAccountMap.get(prop.Apttus_Proposal__Account__c).BillingCountry ||
                prop.BillingZipPostalCode__c != parentAccountMap.get(prop.Apttus_Proposal__Account__c).BillingPostalCode)){

                    parentAccountMap.get(prop.Apttus_Proposal__Account__c).BillingStreet = prop.BillingStreet__c;
                    parentAccountMap.get(prop.Apttus_Proposal__Account__c).BillingCity = prop.BillingCity__c;
                    parentAccountMap.get(prop.Apttus_Proposal__Account__c).BillingState = prop.BillingStateProvince__c;
                    parentAccountMap.get(prop.Apttus_Proposal__Account__c).BillingCountry = prop.BillingCountry__c;
                    parentAccountMap.get(prop.Apttus_Proposal__Account__c).BillingPostalCode = prop.BillingZipPostalCode__c;
                    changeAccount.add(parentAccountMap.get(prop.Apttus_Proposal__Account__c));
                }
        }

        if(!changeAccount.isEmpty()){
            AccountTriggerHandler.ExecuteTriggers = false;
            //update parentAccountMap.values(); I-160141--removed the comment
            update parentAccountMap.values();
        }

    }


    /*public void updateContactFromProposal(List<Apttus_Proposal__Proposal__c> pNewApttusProposalList, map<Id, Apttus_Proposal__Proposal__c> pOldApttusProposalMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateContactFromProposal');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        set<Id> contactIdSet = new set<Id>();

        for(Apttus_Proposal__Proposal__c prop : pNewApttusProposalList){
            contactIdSet.add(prop.BillContact__c);
        }

        map<Id, Contact> parentContactMap = new map<Id, Contact>([SELECT Id,FirstName,LastName,email,phone   FROM Contact
                                                                  WHERE Id IN :contactIdSet]);
        System.debug('Sweety***'+parentContactMap);

        list<Contact> changeContact = new list<Contact>();

        for(Apttus_Proposal__Proposal__c prop : pNewApttusProposalList){
            Boolean ChangeValue = False;

            System.debug('Sweety***'+prop.Billing_Contact_First_Name__c);
            System.debug('Sweety***'+parentContactMap.get(prop.BillContact__c).FirstName);
            if(parentContactMap.containsKey(prop.BillContact__c) ){

                If(!string.isBlank(prop.Billing_Contact_First_Name__c) && prop.Billing_Contact_First_Name__c != parentContactMap.get(prop.BillContact__c).FirstName)
                {
                    parentContactMap.get(prop.BillContact__c).FirstName = prop.Billing_Contact_First_Name__c;
                    ChangeValue = true;
                }
                If(!string.isBlank(prop.Billing_Contact_Last_Name__c) && prop.Billing_Contact_Last_Name__c != parentContactMap.get(prop.BillContact__c).LastName){
                    parentContactMap.get(prop.BillContact__c).LastName = prop.Billing_Contact_Last_Name__c;
                    ChangeValue = true;
                }
                If(!string.isBlank(prop.APTS_Billing_Contact_Email_Address__c) && prop.APTS_Billing_Contact_Email_Address__c != parentContactMap.get(prop.BillContact__c).Email){
                    parentContactMap.get(prop.BillContact__c).Email = prop.APTS_Billing_Contact_Email_Address__c;
                    ChangeValue = true;
                }
                If(!string.isBlank(prop.Telephone__c) && prop.Telephone__c != parentContactMap.get(prop.BillContact__c).Phone ){
                    parentContactMap.get(prop.BillContact__c).phone = prop.Telephone__c;
                    ChangeValue = true;
                }
                If(ChangeValue )
                {
                    changeContact.add(parentContactMap.get(prop.BillContact__c));
                }
            }
        }
        System.debug('Sweety***'+changeContact);

        if(!changeContact.isEmpty()){
            AccountTriggerHandler.ExecuteTriggers = false;
            //update parentAccountMap.values(); I-160141--removed the comment
            update parentContactMap.values();
        }

    }*/

    /*
** @author : Cloud Sherpas, Inc.
** @date : 8/26/2014
** @description : User Story 0161: user will not be able to create any quote for a completed opportunity.
** @paramaters : list of Apttus_Proposal__Proposal__c records
** @returns : nothing
*/
    public Map<ID, Opportunity> validateQuoteCreateConditions(List<Apttus_Proposal__Proposal__c> pApttusProposal){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','validateQuoteCreateConditions');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Set<Id> opportunityIDSet = getOpportunityIdSet(pApttusProposal);

        Map<ID, Opportunity> opportunityMap = new Map<ID, Opportunity>(
            [SELECT ID, OrderCreated__c,
             recordTypeID,
             recordType.Name,
             Agency__c,
             Agency__r.BillingStreet,
             Agency__r.BillingCity,
             Agency__r.BillingState,
             Agency__r.BillingCountry,
             Agency__r.BillingPostalCode,
             Agency__r.AgencyCommission__c,
             Agency__r.ShippingStreet,
             Agency__r.ShippingCity,
             Agency__r.ShippingState,
             Agency__r.ShippingCountry,
             Agency__r.ShippingPostalCode
             FROM Opportunity
             WHERE Id = :opportunityIDSet]);

        system.debug(LoggingLevel.INFO, '>>> Proposal Opportunity List:'+opportunityMap);

        Opportunity oppty;
        for(Apttus_Proposal__Proposal__c proposal : pApttusProposal){
            oppty = opportunityMap.get(proposal.Apttus_Proposal__Opportunity__c);
            system.debug('opportunity related to proposal:'+proposal+' Opportunity:'+oppty);
            if((proposal.Clone_Indicator__c == null || proposal.Clone_Indicator__c == '') && // Only for new Proposal, not for clone cases
               oppty != null && oppty.OrderCreated__c == true){
                   system.debug(LoggingLevel.INFO, '>>> Error: Order for this Opportunity is already created.');
                   proposal.addError('New Quote/Proposal cannot be created on Opportunity for which the Order is already created.');
               }
        }
        return opportunityMap;
    }
    /*
** @author : Cloud Sherpas, Inc.
** @date : 8/26/2014
** @description : User Story 1084: on proposal create set defaults Quote Status = In Progress , approval status = NULL, Approval Stage = Draft, if Agency != null then Quote type should be defaulted to Agency
** @paramaters : list of Apttus_Proposal__Proposal__c records
** @returns : nothing
*/
    public void setQuoteDefaults(List<Apttus_Proposal__Proposal__c> pApttusProposal){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','setQuoteDefaults');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        //S-317111 - Removed logic of looged in user to populate selling country and language
        //Story 2362 - Apttus - Sales Reps should be brought right into quote screen
        //Country Map
        /*Map<String, String> CountryCodeNameMap = new Map<String, String>();
for(CountryCode__c countryCode : CountryCode__c.getAll().values()){
CountryCodeNameMap.put(countryCode.Country_Code__c, countryCode.Name);
}
System.debug('>>> CountryCodeNameMap:'+CountryCodeNameMap);

//Language Map
Map<String, String> languageCodeNameMap = new Map<String, String>();
Schema.DescribeFieldResult fieldResult = User.LanguageLocaleKey.getDescribe();
for (Schema.PicklistEntry picklistEntry : fieldResult.getPicklistValues()) {
languageCodeNameMap.put(picklistEntry.getValue(), picklistEntry.getLabel());
}
System.debug('>>> languageCodeNameMap:'+languageCodeNameMap);

String userSellingCountry = null;
//String userLanguage = null;

try{
System.debug('>>>getLocale:'+UserInfo.getLocale());
String userCountryCode = UserInfo.getLocale().split('_', 0)[1];
userSellingCountry = CountryCodeNameMap.get(userCountryCode);
userLanguage = languageCodeNameMap.get(UserInfo.getLanguage());
System.debug('>>> userSellingCountry:' + userSellingCountry + ' userLanguage:'+userLanguage);
}catch(Exception ex){
System.debug('>>>Exception in setQuoteDefaults:'+ex.getMessage());
}
*/
        for(Apttus_Proposal__Proposal__c proposal : pApttusProposal){
            proposal.QuoteStatus__c = 'In Progress';
            proposal.Apttus_QPApprov__Approval_Status__c = 'Not Submitted';
            proposal.Apttus_Proposal__Approval_Stage__c = 'Draft';
            proposal.Apttus_Proposal__ExpectedStartDate__c = Date.Today();
            /*if(proposal.Selling_Country__c == null){
proposal.Selling_Country__c = userSellingCountry;
}
if(proposal.Language__c == null){
proposal.Language__c = userLanguage;
}*/
            if(proposal.Agency__c != null){
                proposal.APTS_Quote_Type__c = 'Agency';
                proposal.BillingAccount__c = proposal.Agency__c;
            }else if(proposal.Agency__c == null && proposal.Apttus_Proposal__Account__c != null){
                proposal.BillingAccount__c = proposal.Apttus_Proposal__Account__c;
            }

        }
    }

    /*
** @author : Clud Sherpas, Inc.
** @date : 10/22/2014
** @description : User Story 2351 - Two Primary Quotes on One Oppty Should Be Not Possible
** @paramaters : list of Apttus_Proposal__Proposal__c records
** @returns : nothing
*/
    public void setRelatedProposalNonPrimary(Apttus_Proposal__Proposal__c[] pNewApttusProposal, map<Id, Apttus_Proposal__Proposal__c> pOldApttusProposalMap,Boolean isUpdate){
        //system.debug(LoggingLevel.INFO, '>>> Inside setProposalPrimary');
        //Check if Proposal is set to primary
        //Get Opportunity IDs
        Set<Id> proposalIDsSet = new Set<Id>();
        Set<Id> opportunityIDsSet = new Set<Id>();
        Apttus_Proposal__Proposal__c oldProposal;
        for(Apttus_Proposal__Proposal__c newProposal : pNewApttusProposal){
            if(newProposal.Apttus_Proposal__Primary__c == true){
                if(isUpdate && pOldApttusProposalMap != null){
                    oldProposal = pOldApttusProposalMap.get(newProposal.Id);
                    if(oldProposal.Apttus_Proposal__Primary__c == false){
                        proposalIDsSet.add(newProposal.Id);
                        system.debug('santoshdebugginginternalId'+newProposal.Id);
                        opportunityIDsSet.add(newProposal.Apttus_Proposal__Opportunity__c);
                    }

                    /* if((newProposal.Apttus_QPConfig__ConfigurationFinalizedDate__c != pOldApttusProposalMap.get(newProposal.Id).Apttus_QPConfig__ConfigurationFinalizedDate__c)
&& newProposal.Apttus_Proposal__Opportunity__r.RecordType.Name == 'GCS Opportunity')
{
newProposal.QuoteStatus__c = 'Accepted Offline';
}*/
                }else{
                    proposalIDsSet.add(newProposal.Id);
                    opportunityIDsSet.add(newProposal.Apttus_Proposal__Opportunity__c);
                }
            }

        }
        //system.debug(LoggingLevel.INFO, '>>> proposalIDsSet:'+proposalIDsSet+' opportunityIDsSet:'+opportunityIDsSet);

        //Get Related Proposals except current list of proposals and primary
        List<Apttus_Proposal__Proposal__c> updateProposalList = new List<Apttus_Proposal__Proposal__c>();
        for(Apttus_Proposal__Proposal__c proposal: [Select ID, Apttus_Proposal__Primary__c
                                                    From Apttus_Proposal__Proposal__c
                                                    Where Apttus_Proposal__Primary__c = true
                                                    AND Apttus_Proposal__Opportunity__c IN :opportunityIDsSet
                                                    AND ID NOT IN :proposalIDsSet]){
                                                        proposal.Apttus_Proposal__Primary__c = false;
                                                        updateProposalList.add(proposal);
                                                    }
        //system.debug(LoggingLevel.INFO, '>>> updateProposalList:'+updateProposalList);




        //Set Others as not primary
        //try{
        if(!updateProposalList.isEmpty()){
            update updateProposalList;
            List<Apttus_Proposal__Proposal_Line_Item__c> lstProposalLineItems = [select id
                                                                                 FROM Apttus_Proposal__Proposal_Line_Item__c
                                                                                 WHERE Apttus_Proposal__Proposal__c IN:updateProposalList];

            if(!lstProposalLineItems.isEmpty()){
                List<OpportunityLineItem> lstLineItems = [select id from OpportunityLineItem
                                                          where Proposal_Line_Item__c IN :lstProposalLineItems ];
                if(!lstLineItems.isEmpty())
                    //system.assert(false , lstLineItems);
                    Delete lstLineItems;
            }

        }

        if(proposalIDsSet.size() > 0){

            list<Apttus_Proposal__Proposal_Line_Item__c> lstProposalLineItemsToSyncWithOpp =[select id
                                                                                             from Apttus_Proposal__Proposal_Line_Item__c
                                                                                             where Apttus_Proposal__Proposal__c IN :proposalIDsSet  ];

            ApttusProposalLineItemTriggerHandler.syncLineItemsWithOpportunityLineItems(lstProposalLineItemsToSyncWithOpp, Null);
        }


        /*}catch(Exception ex){
system.debug(LoggingLevel.INFO, '>>> Error in updating Primary flag on proposals:'+ex.getMessage());
}*/
    }


    /*
JFreese Appirio
I-189006 Get Avalara Tax automatically during cart Finalize
11/13/15
*/
    public void getQuoteTaxOnFinalize(Apttus_Proposal__Proposal__c[] pNewApttusProposal, map<Id, Apttus_Proposal__Proposal__c> pOldApttusProposalMap,Boolean isUpdate){
        Set<Id> proposalIDsSet = new Set<Id>();
        Apttus_Proposal__Proposal__c oldProposal;
        for(Apttus_Proposal__Proposal__c newProposal : pNewApttusProposal){
            if(newProposal.Apttus_QPConfig__ConfigurationFinalizedDate__c != null){
                if(isUpdate && pOldApttusProposalMap != null){
                    oldProposal = pOldApttusProposalMap.get(newProposal.Id);
                    if(newProposal.Apttus_QPConfig__ConfigurationFinalizedDate__c != oldProposal.Apttus_QPConfig__ConfigurationFinalizedDate__c){
                        if(! proposalIDsSet.contains(newProposal.Id))
                            proposalIDsSet.add(newProposal.Id);
                    }
                }else{
                    if(! proposalIDsSet.contains(newProposal.Id))
                        proposalIDsSet.add(newProposal.Id);
                }
            }
        }
        if(proposalIDsSet.size() > 0){
            try{
                system.debug('\n\nCalling asyncronous Avalara callout method ProposalStartTaxRateProcessing().\n\n');
                system.debug('^^^ proposalIDsSet='+proposalIDsSet);
                //String status = AvalaraModel.ProposalStartTaxRateProcessing(proposalIDsSet);
                /*JFreese Appirio 3/12/17 S-442900 The future call now fails with:
                  Future method cannot be called from a future or batch method:
                  OpportunityLineItemTriggerHelper.setInternationalOppty(Set<Id>)
                  So call AsyncTaxRateProcessing in a queuable, which can then call a future.
                AvalaraModel.AsyncTaxRateProcessing (proposalIDsSet , 'QUOTE');*/
              QueueableTaxRateProcessing AsyncTRP  = new QueueableTaxRateProcessing();
              AsyncTRP.pIdSet = proposalIDsSet;
              AsyncTRP.pCalledFromObject = 'QUOTE';
              System.enqueueJob(AsyncTRP);
            }catch(Exception e){
                system.debug('\n\n ProposalStartTaxRateProcessing error:' + e + '\n\n');
            }
        }
    }

    /*
    @author : JFreese Appirio 3/12/17 S-442900
    @description : call AvalaraModel.AsyncTaxRateProcessingMethods as a queueable
    */
    public class QueueableTaxRateProcessing implements Queueable, Database.AllowsCallouts{
        private set<Id> pIdSet;
        private String pCalledFromObject;

        public void execute(QueueableContext context) {
            AvalaraModel.AsyncTaxRateProcessingMethods (pIdSet , pCalledFromObject);
        }
    }

    /*
JFreese Appirio
I-189764 Validate the Agency Billing Contact
12/14/15
*/
    public void validateAgencyBillingContact(List<Apttus_Proposal__Proposal__c> pNewApttusProposalList){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','validateAgencyBillingContact');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        boolean validAgencyBillingContact;


        List<id> agencyIds = new List<id>();
        for(Apttus_Proposal__Proposal__c proposal: pNewApttusProposalList){

            if (proposal.Agency__c != null && proposal.AgencyBillingContact__c != null)
            {
                agencyIds.add(proposal.Agency__c);

            }
        }

        list<contact> lstAgencyContacts = [Select Id,AccountId From Contact WHERE AccountId =: agencyIds];
        list<AccountContactAssociation__c> lstAccountAssociation= [Select Id,Contact__c,Account__c From AccountContactAssociation__c WHERE Account__c =: agencyIds];

        map<id, list<contact>> mapProposalContacts = new map<id, list<contact>>();
        map<id, list<AccountContactAssociation__c>> mapAccountAssociation = new map<id, list<AccountContactAssociation__c>>();

        for (Contact con: lstAgencyContacts){
            if(!mapProposalContacts.containsKey(con.AccountId))
                mapProposalContacts.put(con.AccountId , new list<contact>());
            mapProposalContacts.get(con.AccountId).add(con);
        }

        for (AccountContactAssociation__c accAssoc: lstAccountAssociation){
            if(!mapAccountAssociation.containsKey(accAssoc.Account__c))
                mapAccountAssociation.put(accAssoc.Account__c, new list<AccountContactAssociation__c>());
            mapAccountAssociation.get(accAssoc.Account__c).add(accAssoc);
        }

        for(Apttus_Proposal__Proposal__c proposal: pNewApttusProposalList){

            if (proposal.Agency__c != null && proposal.AgencyBillingContact__c != null)
            {
                validAgencyBillingContact = false;
                //Validate the Agency Billing Contact; must be a contact or related contact on the Agency
                if(mapProposalContacts.containsKey(proposal.Agency__c)){
                    for(Contact con: mapProposalContacts.get(proposal.Agency__c)){
                        if(con.Id == proposal.AgencyBillingContact__c){
                            validAgencyBillingContact = true;
                        }
                    }
                }
                if(mapAccountAssociation.containsKey(proposal.Agency__c)){
                    for(AccountContactAssociation__c aca: mapAccountAssociation.get(proposal.Agency__c)){
                        if(aca.Contact__c == proposal.AgencyBillingContact__c){
                            validAgencyBillingContact = true;
                        }
                    }
                }
                if(!validAgencyBillingContact){
                    proposal.AgencyBillingContact__c.addError('Please choose a contact or related contact for the agency account you have selected.');
                }
            }
        }

        /*for(Apttus_Proposal__Proposal__c proposal: pNewApttusProposalList){
validAgencyBillingContact = false;
if (proposal.Agency__c != null && proposal.AgencyBillingContact__c != null)
{
//Validate the Agency Billing Contact; must be a contact or related contact on the Agency
for(Contact con: [Select Id From Contact WHERE AccountId =: proposal.Agency__c]){
if(con.Id == proposal.AgencyBillingContact__c){
validAgencyBillingContact = true;
}
}
for(AccountContactAssociation__c aca: [Select Contact__c From AccountContactAssociation__c WHERE Account__c =: proposal.Agency__c]){
if(aca.Contact__c == proposal.AgencyBillingContact__c){
validAgencyBillingContact = true;
}
}
if(!validAgencyBillingContact){
proposal.AgencyBillingContact__c.addError('Please choose a contact or related contact for the agency account you have selected.');
}
}
}*/
    }


    /*
** @author : Clud Sherpas, Inc.
** @date : 8/26/2014
** @description : User Story 585: validate that the Quote Total and Payment Details Total match before allowing reps to mark the quote as 'ready'
** @paramaters : list of Apttus_Proposal__Proposal__c records
** @returns : nothing
*/
    // commented this method as it not getting invoked from anywhere
    /*public void setPrimaryQuoteTotalsMatchToOppty(List<Apttus_Proposal__Proposal__c> pNewApttusProposalList, map<Id, Apttus_Proposal__Proposal__c> pOldApttusProposalMap){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','setPrimaryQuoteTotalsMatchToOppty');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        List<Apttus_Proposal__Proposal__c> primaryProposalList = new List<Apttus_Proposal__Proposal__c>();
        for(Apttus_Proposal__Proposal__c proposal : pNewApttusProposalList){
            //Get Primary Proposal List and for APAC only
            SYstem.debug('proposal.Apttus_Proposal__Primary__c'+ proposal.Apttus_Proposal__Primary__c);
            SYstem.debug('proposal.Organization__c'+ proposal.Organization__c);
            if(proposal.Apttus_Proposal__Primary__c &&
               proposal.Organization__c == 'Asia Pacific'){
                   primaryProposalList.add(proposal);
               }
        }

        if(primaryProposalList.isEmpty()){
            //System.debug('No primary Proposal to update totals to Opportunity');
            return;
        }

        Set<Id> opportunityIDSet = getOpportunityIdSet(primaryProposalList);

        Map<ID, Opportunity> opportunityMap = new Map<ID, Opportunity>(
            [SELECT ID, Primary_Quote_Totals_Match__c
             FROM Opportunity
             WHERE Id = :opportunityIDSet]);

        //system.debug('Proposal Opportunity List:'+opportunityMap);

        Opportunity oppty;
        for(Apttus_Proposal__Proposal__c proposal : primaryProposalList){
            oppty = opportunityMap.get(proposal.Apttus_Proposal__Opportunity__c);
            system.debug('opportunity related to proposal:'+proposal+' Opportunity:'+oppty);
            Double TotalTaxAmount =  (proposal.Total_Tax_Amount__c == null) ? 0 : proposal.Total_Tax_Amount__c;
            Double TotalPaymentAmount = (proposal.Total_Payment_Amount__c == null) ? 0 : proposal.Total_Payment_Amount__c ;
            Double TotalBaseExtendedPrice = (proposal.TotalBaseExtendedPrice__c == null) ? 0 : proposal.TotalBaseExtendedPrice__c ;

            if(TotalTaxAmount + TotalPaymentAmount == TotalBaseExtendedPrice){
                oppty.Primary_Quote_Totals_Match__c = true;
            }else{
                oppty.Primary_Quote_Totals_Match__c = false;
            }
            //system.debug('Primary_Quote_Totals_Match:' + oppty.Primary_Quote_Totals_Match__c);
        }//for
        //system.debug('setPrimaryQuoteTotalsMatchToOppty updating Opportunity.');
        update opportunityMap.values();

    }*/

    /*
** @author : Cloud Sherpas, Inc.
** @date : 12/03/2014
** @description : when the quote is Accepted then it triggers the creation of an Order.
We need to check to see if Order Type = Conversion.
If YES then create a second Order with the Record type of “Credit” with the same information as
the 1st order created, the only difference would be a negative amount and the record type of Credit.
** @paramaters : list of Apttus_Proposal__Proposal__c records
** @returns : nothing
*/
    public void productConversion(List<Apttus_Proposal__Proposal__c> pApttusProposal){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','productConversion');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        //try{
        Map<Id,Apttus_Proposal__Proposal__c> propMap = new Map<Id,Apttus_Proposal__Proposal__c>();
        Set<Id> relatedQuote = new Set<Id>();
        List<Order__c> OrderList = new List<Order__c>();
        for(Apttus_Proposal__Proposal__c eachproposal: pApttusProposal){
            relatedQuote.add(eachproposal.Id);
            propMap.put(eachproposal.Id,eachproposal);
        }

        if(!relatedQuote.isEmpty()){
            Utility util = new Utility();
            Map<String, Map<String, Schema.SObjectField>> sObjectAndFields = Util.getAllSObjectFieldsBySObjectName(new Set<String>{'Order__c'});
            map<String, map<String, Id>> OrderAndCaseRecordTypes = Utility.GetRecordTypeIdsBySObjectNameSet(new set<string>{'Order__c'});
            Id creditOrderRecordTypeId = OrderAndCaseRecordTypes.get('Order__c').get('Credit');
            Map<String, Schema.SObjectField> orderFields = sObjectAndFields.get('Order__c');

            String orderQuery = 'SELECT ';
            for(String sourceAPI : orderFields.keySet()){
                orderQuery += sourceAPI+',';
            }
            orderQuery = orderQuery.removeEnd(',');
            orderQuery += ' FROM Order__c WHERE QuoteProposal__c IN :relatedQuote';
            List<Order__c> ParentOrder = Database.query(orderQuery);

            for(Order__c ord : ParentOrder){
                Apttus_Proposal__Proposal__c prop = propMap.get(ord.QuoteProposal__c);
                Order__c ClonedOrder = ord.clone(false, true, false, true);
                ClonedOrder.RecordTypeId = creditOrderRecordTypeId;
                ClonedOrder.ParentOrder__c = Ord.Id;
                ClonedOrder.OrderStatus__c = 'Open';
                if(prop.AccountOrganization__c == 'North America' && prop.PaypalReferenceNumber__c != null
                   && prop.QuoteStatus__c == 'Accepted Offline'){
                       ClonedOrder.OrderStatus__c = 'Paid in Full';
                       ClonedOrder.Payment_Method_text__c = 'Credit Card';
                       ClonedOrder.Payment_Frequency__c = 'Single Payment';
                       ClonedOrder.Payment_Term_text__c = 'Immediate';
                       ClonedOrder.Installments__c = 1;


                   }
                OrderList.add(ClonedOrder);
            }
        }

        if(!OrderList.isEmpty()){
            insert OrderList;
        }
        //system.assert(false,OrderList);
        /* }catch(Exception dmlex){
ExceptionLog.add(dmlex.getTypeName(), 'ApttusProposalTriggerHelper', 'productConversion', dmlex.getMessage());
throw BaseApplicationException.NewException('ApttusProposalTriggerHelper.productConversion()', dmlex.getMessage());
}*/

    }

    public void updateOrderAgencyBillContact(List<Apttus_Proposal__Proposal__c> pApttusProposal, map<Id, Apttus_Proposal__Proposal__c> pOldApttusProposalMap, map<Id, Apttus_Proposal__Proposal__c> pNewApttusProposalMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateOrderAgencyBillContact');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            Map<Id, Order__c> mapOrder = new Map<Id, Order__c>();
            Map<Id, Apttus_Proposal__Proposal__c> mapProposal = new Map<Id, Apttus_Proposal__Proposal__c>();
            List<Order__c> ordList = new List<Order__c>();


            for(Order__c ord : [Select Id, QuoteProposal__c, AgencyBillingContact__c From Order__c where QuoteProposal__c IN :pApttusProposal]){

                if(pNewApttusProposalMap.containsKey(ord.QuoteProposal__c) && pNewApttusProposalMap.get(ord.QuoteProposal__c).AgencyBillingContact__c != null){
                    if(pNewApttusProposalMap.get(ord.QuoteProposal__c).AgencyBillingContact__c != pOldApttusProposalMap.get(ord.QuoteProposal__c).AgencyBillingContact__c){
                        ord.AgencyBillingContact__c = pNewApttusProposalMap.get(ord.QuoteProposal__c).AgencyBillingContact__c ;
                        ordList.add(ord);
                    }
                }
            }
            if(!ordList.isEmpty()){
                update ordList;
            }
        }catch(Exception dmlex){
            ExceptionLog.add(dmlex.getTypeName(), 'ApttusProposalTriggerHelper', 'updateOrderAgencyBillContact', dmlex.getMessage());
            throw BaseApplicationException.NewException('ApttusProposalTriggerHelper.updateOrderAgencyBillContact()', dmlex.getMessage());
        }

    }


    /*
** @author : Cloud Sherpas, Inc.
** @date : 8/26/2014
** @description : terms and condition for Quote type Proposal
Use case 4 :Terms and condition on Proposal Quote type, Language & NO Product assocation.
these types of terms and condition are saved on (Quote_Type_Terms_and_Condition__c)
** @paramaters : list of Apttus_Proposal__Proposal__c records
** @returns : nothing
*/
    public void proposalTermsandcondition(Apttus_Proposal__Proposal__c[] pApttusProposal, map<Id, Apttus_Proposal__Proposal__c> pOldApttusProposalMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','proposalTermsandcondition');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        List<Apttus_Proposal__Proposal__c> proplist = new List<Apttus_Proposal__Proposal__c>();
        for(Apttus_Proposal__Proposal__c eachproposal: pApttusProposal){
            if(pOldApttusProposalMap == null || eachproposal.Language__c != pOldApttusProposalMap.get(eachproposal.Id).Language__c || eachproposal.APTS_Quote_Type__c != pOldApttusProposalMap.get(eachproposal.Id).APTS_Quote_Type__c ){
                proplist.add(eachproposal);
            }
        }

        for(Apttus_Proposal__Proposal__c eachproposal: proplist){
            eachproposal.Terms_and_Conditions_Text__c ='';
            system.debug('eachproposal.Terms_and_Conditions_Text__c'+eachproposal.Terms_and_Conditions_Text__c+'<> is blank'+String.isBlank(eachproposal.Terms_and_Conditions_Text__c));
            List<Terms_and_Conditions__c> Qtandc = [select Name, Quote_Type__c, Language__c, Attribute_1__c from Terms_and_Conditions__c where Quote_Type__c =:eachproposal.APTS_Quote_Type__c and Language__c =:eachproposal.Language__c and Product__c =: null];
            system.debug('Quote Type Terms and Condition'+Qtandc);
            for(Terms_and_Conditions__c eachQtandc : Qtandc){
                if(eachQtandc.Attribute_1__c !=null && eachQtandc.Attribute_1__c !='')
                    if(String.isBlank(eachproposal.Terms_and_Conditions_Text__c))eachproposal.Terms_and_Conditions_Text__c = eachQtandc.Attribute_1__c; else eachproposal.Terms_and_Conditions_Text__c = eachproposal.Terms_and_Conditions_Text__c +' \r\n' +eachQtandc.Attribute_1__c;
            }
        }

    }



    public void CreateAssetTrigger(List<Apttus_Proposal__Proposal__c> pNewApttusProposalList, map<Id, Apttus_Proposal__Proposal__c> pOldApttusProposalMap){
        //system.debug('in Trigger CreateAssetTrigger');
        final string METHODNAME = CLASSNAME.replace('METHODNAME','CreateAssetTrigger');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        String LINETYPE_PRODUCT = 'Product/Service';
        String LINETYPE_OPTION = 'Option';
        ID accountId;
        String RecordtypeName;
        Set<ID> configIds = new Set<ID>();
        Set<Id> proposalIds = new Set<Id>();
        Set<Id> BundleIds = new Set<Id>();
        String approvalStage;
        String approvalStage1;
        approvalStage = 'Accepted Online';
        approvalStage1 = 'Accepted Offline';
        Map<Id,Id> PropLineItemtoLineItem  = new Map<Id,Id>();
        for(Apttus_Proposal__Proposal__c proposal : pNewApttusProposalList){
            Apttus_Proposal__Proposal__c oldProposal = pOldApttusProposalMap.get(proposal.Id);
            accountId = proposal.Apttus_Proposal__Account__c;//keep last one, should be same TODO: find out
            //RecordtypeName = proposal.Record_Type_Name__c;
            //detect transition. TODO: take tare of repeat transition
            /*if(oldProposal.Apttus_Proposal__Approval_Stage__c != approvalStage
&& proposal.Apttus_Proposal__Approval_Stage__c == approvalStage ){
system.debug('Inside trigger condition');
proposalIds.add(proposal.Id);
system.debug('*** proposalIds ' + proposalIds);
}*/
            /*if((oldProposal.QuoteStatus__c != approvalStage || oldProposal.QuoteStatus__c != approvalStage1 )
&& (proposal.QuoteStatus__c == approvalStage || proposal.QuoteStatus__c == approvalStage1) )*/

            /* change thes method get executed when only  Create Asset old value == false and Create Asset new value = true*/
            if(!oldProposal.Create_Assets__c && proposal.Create_Assets__c)  {
                // system.debug('Inside trigger condition');
                proposalIds.add(proposal.Id);
                // system.debug('*** proposalIds ' + proposalIds);
            }
            else{
                return;
            }
        }
        if(proposalIds.size() > 0){
            List<Apttus_Proposal__Proposal_Line_Item__c> proposalItems = [SELECT Id, Apttus_QPConfig__ConfigurationId__c, Apttus_QPConfig__DerivedFromId__c FROM
                                                                          Apttus_Proposal__Proposal_Line_Item__c WHERE Apttus_Proposal__Proposal__c in : proposalIds];
            system.debug('*** proposalItems size ' + proposalItems.size());
            for(Apttus_Proposal__Proposal_Line_Item__c proposalItem: proposalItems){
                if( proposalItem.Apttus_QPConfig__ConfigurationId__c!= null &&  String.valueOf(proposalItem.Apttus_QPConfig__ConfigurationId__c)!='')
                    configIds.add(proposalItem.Apttus_QPConfig__ConfigurationId__c);

                if(proposalItem.Apttus_QPConfig__DerivedFromId__c != null)
                    PropLineItemtoLineItem.put(proposalItem.Id,proposalItem.Apttus_QPConfig__DerivedFromId__c);
            }
        }
        // system.debug('*** configIds size ' + configIds.size());

        //fetch all the line items added to the quote
        List<Apttus_Config2__LineItem__c> lineItems =
            [SELECT Id, Name, Apttus_Config2__ProductId__c,
             Apttus_Config2__OptionId__c, Apttus_Config2__ConfigurationId__c,
             Apttus_Config2__ConfigurationId__r.Apttus_Config2__AccountId__c,
             Apttus_Config2__LineNumber__c,
             Apttus_Config2__ItemSequence__c,
             Apttus_Config2__LineType__c, Apttus_Config2__IsPrimaryLine__c,
             Apttus_Config2__NetPrice__c, Apttus_Config2__PriceListId__c,
             Apttus_Config2__PriceListItemId__c, Apttus_Config2__Frequency__c,
             Apttus_Config2__ChargeType__c,
             Apttus_Config2__PriceType__c, Apttus_Config2__SellingTerm__c,
             Apttus_Config2__SellingFrequency__c, Apttus_Config2__Quantity__c,
             Apttus_Config2__StartDate__c, Apttus_Config2__EndDate__c,
             Apttus_Config2__LineStatus__c,
             Apttus_Config2__BasePrice__c, Apttus_Config2__BaseExtendedPrice__c,
             Apttus_Config2__BasePriceMethod__c, Apttus_Config2__AdjustedPrice__c,
             Apttus_Config2__OptionPrice__c, Apttus_Config2__ExtendedPrice__c,
             Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c,
             Test__c,
             APTS_Unit_Net_Price__c, APTS_Product_Code__c,
             Apttus_Config2__AdjustmentType__c, Apttus_Config2__AdjustmentAmount__c,
             Apttus_Config2__ListPrice__c,
             APTS_Asset_Available_Quantity__c,
             APTS_Product_Service_Type__c,
             Apttus_Config2__AssetLineItemId__c
             FROM Apttus_Config2__LineItem__c
             WHERE
             Apttus_Config2__ConfigurationId__c in : configIds
            ];
        List<Apttus_Config2__LineItem__c> convertedLineItems = new List<Apttus_Config2__LineItem__c>();
        if(lineItems != null && lineItems.size() > 0){
            // System.debug('lineItem[0]='+lineItems[0]);
            //System.debug('lineItem size='+lineItems.size());
            accountId = lineItems[0].Apttus_Config2__ConfigurationId__r.Apttus_Config2__AccountId__c;
        }
        //System.debug('*** accountId = ' + accountId);
        if(accountId == null){
            return;
        }
        // Commenting out below code to have asset reconcilation - 10/7
        /*
List<Apttus_Config2__AssetLineItem__c> addedAssets = [SELECT Id,
Apttus_Config2__AccountId__c,
Name,
Apttus_Config2__BusinessObjectId__c,
Apttus_Config2__BusinessLineItemId__c,
Apttus_Config2__ProductId__c, // = line.ProductId__c, //;
Apttus_Config2__OptionId__c, // = line.OptionId__c, //;
Apttus_Config2__LineNumber__c, // = line.LineNumber__c, //;
Apttus_Config2__ItemSequence__c, // = line.ItemSequence__c, //;
Apttus_Config2__LineType__c, // = line.LineType__c, //;
Apttus_Config2__SellingFrequency__c, // = line.SellingFrequency__c, //;
Apttus_Config2__SellingTerm__c, // = line.SellingTerm__c, //;
Apttus_Config2__Quantity__c, // = line.Quantity__c, //;
Apttus_Config2__StartDate__c, // = line.StartDate__c, //;
Apttus_Config2__EndDate__c, // = line.EndDate__c, //;
Apttus_Config2__NetPrice__c,
Apttus_Config2__ListPrice__c
FROM
Apttus_Config2__AssetLineItem__c
WHERE
Apttus_Config2__BusinessObjectId__c in : configIds
];
*/
        List <Order_Line_Item__c> OrderLI = [SELECT Id,StartDate__c,EndDate__c, AssetLineItemId__c,ProposalLineItem__r.Apttus_QPConfig__DerivedFromId__c FROM Order_Line_Item__c WHERE ProposalLineItem__c IN:PropLineItemtoLineItem.keySet() ]; ///MS-I-177990
        system.debug('****OrderLI' + OrderLI);
        system.debug('****OrderLI' + PropLineItemtoLineItem);
        MAP<id,Order_Line_Item__c> ProposalToOrderMAp = new MAP<id,Order_Line_Item__c>();//I-212493 changes
        for(Order_Line_Item__c OTemp : OrderLI)
        {
            system.debug('****OTemp.ProposalLineItem__c' + OTemp.ProposalLineItem__c);
            ProposalToOrderMAp.put(OTemp.ProposalLineItem__r.Apttus_QPConfig__DerivedFromId__c , Otemp);//I-212493 changes
        }
        // save id list to get attribute values
        Set<ID> lineItemIdList = new Set<ID>();
        //**********************************
        //create asset reocrd for each line item
        //**********************************
        List<Apttus_Config2__AssetLineItem__c> assetItems = new List<Apttus_Config2__AssetLineItem__c>();
        Set<ID> addedAssetIds = new Set<ID>();
        for(Apttus_Config2__LineItem__c line : lineItems){
            if(line.Apttus_Config2__LineStatus__c == 'Amended' ||
               (line.Apttus_Config2__LineStatus__c == 'Converted' &&
                (line.APTS_Product_Service_Type__c == 'Subscription' ||
                 (line.APTS_Product_Service_Type__c == 'Usage' && line.APTS_Asset_Available_Quantity__c == 0)))){

                     convertedLineItems.add(line);
                     addedAssetIds.add(line.Apttus_Config2__AssetLineItemId__c);
                 }
            //original code below
            lineItemIdList.add(line.Id);
            String lineBizId = line.Apttus_Config2__ConfigurationId__c;//TODO:use agreement or proposal id
            //STEP I find if the asset record is already added
            Apttus_Config2__AssetLineItem__c assetItem;
            // Commenting out below code to have asset reconcilation - 10/7
            /*
for(Apttus_Config2__AssetLineItem__c addedAsset : addedAssets){
if(addedAsset.Apttus_Config2__BusinessObjectId__c == lineBizId
&& addedAsset.Apttus_Config2__LineNumber__c == line.Apttus_Config2__LineNumber__c
&& addedAsset.Apttus_Config2__ItemSequence__c == line.Apttus_Config2__ItemSequence__c){
if(!addedAssetIds.contains(addedAsset.Id)){ //TODO: check, this should not happen
assetItem = addedAsset;
addedAssetIds.add(addedAsset.Id);
}
break;
}
}
*/
            if(assetItem == null){
                assetItem = new Apttus_Config2__AssetLineItem__c();
            }
            String recordName = line.Name.substring(3);
            assetItem.Apttus_Config2__AccountId__c = line.Apttus_Config2__ConfigurationId__r.Apttus_Config2__AccountId__c;
            assetItem.Name = recordName;
            //assetItem.Apttus_Config2__LineItemId__c = line.Id;
            assetItem.Apttus_Config2__BusinessObjectId__c = lineBizId;
            assetItem.Apttus_Config2__BusinessLineItemId__c = line.Id;
            assetItem.Apttus_Config2__ProductId__c = line.Apttus_Config2__ProductId__c;
            assetItem.Apttus_Config2__OptionId__c = line.Apttus_Config2__OptionId__c;
            assetItem.Apttus_Config2__LineNumber__c = line.Apttus_Config2__LineNumber__c;
            assetItem.Apttus_Config2__ItemSequence__c = line.Apttus_Config2__ItemSequence__c;
            assetItem.Apttus_Config2__LineType__c = line.Apttus_Config2__LineType__c;
            assetItem.Apttus_Config2__IsPrimaryLine__c = line.Apttus_Config2__IsPrimaryLine__c;
            assetItem.Apttus_Config2__ChargeType__c = line.Apttus_Config2__ChargeType__c;
            assetItem.Apttus_Config2__PriceType__c = line.Apttus_Config2__PriceType__c;
            assetItem.Apttus_Config2__SellingFrequency__c = line.Apttus_Config2__SellingFrequency__c;
            assetItem.Apttus_Config2__SellingTerm__c = line.Apttus_Config2__SellingTerm__c;
            assetItem.Apttus_Config2__Quantity__c = line.Apttus_Config2__Quantity__c;
            //I-212493 changes
            if(ProposalToOrderMAp.get(line.id) !=null && ProposalToOrderMAp.get(line.id).StartDate__c!=null)
            {
                assetItem.Apttus_Config2__StartDate__c = ProposalToOrderMAp.get(line.id).StartDate__c;
            }
            else
            {
                assetItem.Apttus_Config2__StartDate__c = line.Apttus_Config2__StartDate__c;
            }
            //I-212493 changes
             if(ProposalToOrderMAp.get(line.id) !=null && ProposalToOrderMAp.get(line.id).EndDate__c!=null)
            {
                assetItem.Apttus_Config2__EndDate__c = ProposalToOrderMAp.get(line.id).EndDate__c;
            }
            else
            {
                assetItem.Apttus_Config2__EndDate__c = line.Apttus_Config2__EndDate__c;
            }


            assetItem.Apttus_Config2__NetPrice__c = line.Apttus_Config2__NetPrice__c;
            assetItem.Apttus_Config2__AssetStatus__c = line.Apttus_Config2__LineStatus__c;
            //Added Custom
            assetItem.Apttus_Config2__BasePrice__c = line.Apttus_Config2__BasePrice__c;
            assetItem.Apttus_Config2__BaseExtendedPrice__c = line.Apttus_Config2__BaseExtendedPrice__c;
            assetItem.Apttus_Config2__BasePriceMethod__c = line.Apttus_Config2__BasePriceMethod__c;
            assetItem.Apttus_Config2__AdjustedPrice__c = line.Apttus_Config2__AdjustedPrice__c;
            assetItem.Apttus_Config2__OptionPrice__c = line.Apttus_Config2__OptionPrice__c;
            assetItem.Apttus_Config2__ExtendedPrice__c = line.Apttus_Config2__ExtendedPrice__c;
            assetItem.Proposal__c = line.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c;
            assetItem.APTS_Views__c = line.Test__c;
            assetItem.APTS_Unit_Net_Price__c = line.APTS_Unit_Net_Price__c;
            assetItem.APTS_Product_Code__c = line.APTS_Product_Code__c;
            assetItem.APTS_Adjustment_Type__c = line.Apttus_Config2__AdjustmentType__c;
            assetItem.APTS_Adjustment_Amount__c = line.Apttus_Config2__AdjustmentAmount__c;
            assetItem.Apttus_Config2__ListPrice__c = line.Apttus_Config2__ListPrice__c;
            assetItem.Available_Quantity__c = line.Apttus_Config2__Quantity__c;
            system.debug('****ProposalToOrderMAp.size()' + ProposalToOrderMAp.get(line.id));
            system.debug('****line.id.size()' +line.id);
            if(ProposalToOrderMAp.get(line.id) !=null && ProposalToOrderMAp.get(line.id).id !=null)//I-215106 changes
            assetItem.Order_Line_Item__c = ProposalToOrderMAp.get(line.id).id; ///MS-I-177990 //I-212493 changes

            assetItems.add(assetItem);

        }
        system.debug('****assetItems.size()' + assetItems.size());
        system.debug('*** addedAssetIds ' + addedAssetIds + ' addedAssetIds.size()' + addedAssetIds.size());
        if(addedAssetIds != null && addedAssetIds.size() > 0){
            List<Apttus_Config2__AssetLineItem__c> addedAssets = [SELECT Id,
                                                                  Apttus_Config2__AccountId__c,
                                                                  Name,
                                                                  Apttus_Config2__ProductId__c, // = line.ProductId__c, //;
                                                                  Apttus_Config2__OptionId__c, // = line.OptionId__c, //;
                                                                  Apttus_Config2__Quantity__c, // = line.Quantity__c, //;
                                                                  Apttus_Config2__StartDate__c, // = line.StartDate__c, //;
                                                                  Apttus_Config2__EndDate__c, // = line.EndDate__c, //;
                                                                  Available_Quantity__c
                                                                  FROM
                                                                  Apttus_Config2__AssetLineItem__c
                                                                  WHERE
                                                                  id in : addedAssetIds
                                                                 ];
            for(Apttus_Config2__AssetLineItem__c assetItem : addedAssets){
                for(Apttus_Config2__LineItem__c line : convertedLineItems){
                    if(assetItem.id == line.Apttus_Config2__AssetLineItemId__c){
                        //Update Asset End Date with today's date/line item end date
                        if(line.Apttus_Config2__LineStatus__c == 'Amended' || line.APTS_Asset_Available_Quantity__c == 0){
                            assetItem.Apttus_Config2__EndDate__c = line.Apttus_Config2__EndDate__c;
                        }
                        else{
                            //assetItem.Apttus_Config2__Quantity__c = line.APTS_Asset_Available_Quantity__c;
                            assetItem.Available_Quantity__c = line.APTS_Asset_Available_Quantity__c;
                        }
                    }
                }
                assetItems.add(assetItem);
            }
        }
        upsert assetItems;
        // create a map from the list
        Map<Id,Id> LineItemtoassetmap = new Map<Id,Id>();
        for(Apttus_Config2__AssetLineItem__c eachAsset : assetItems){
            if(LineItemtoassetmap.get(eachAsset.Apttus_Config2__BusinessLineItemId__c) == null){
                LineItemtoassetmap.put(eachAsset.Apttus_Config2__BusinessLineItemId__c,eachAsset.Id);
            }
        }

        //******************************
        //update the Order Lien Items with associate Asset Line Item
        //******************************
        system.debug('********LineItemtoassetmap :'+LineItemtoassetmap);
        system.debug('********PropLineItemtoLineItem  :'+PropLineItemtoLineItem);

        for(Order_Line_Item__c eachOrderLine : OrderLI){
            if(eachOrderLine.AssetLineItemId__c != LineItemtoassetmap.get(PropLineItemtoLineItem.get(eachOrderLine.ProposalLineItem__c))){
                eachOrderLine.AssetLineItemId__c = LineItemtoassetmap.get(PropLineItemtoLineItem.get(eachOrderLine.ProposalLineItem__c));
                system.debug('*******updating ordrtlineitem :'+eachOrderLine.id+'\n AssetLineItemId : '+ eachOrderLine.AssetLineItemId__c);
            }
        }
        if(OrderLI != null && !OrderLI.isEmpty())
            update OrderLI;

        //**********************************
        //associate bundle with options
        //**********************************
        List<Apttus_Config2__AssetLineItem__c> bundleLines = [SELECT Id,
                                                              Apttus_Config2__ProductId__c, Apttus_Config2__OptionId__c,
                                                              Apttus_Config2__LineNumber__c,
                                                              Apttus_Config2__BusinessObjectId__c
                                                              FROM Apttus_Config2__AssetLineItem__c
                                                              WHERE Apttus_Config2__BusinessObjectId__c in : configIds
                                                              AND Apttus_Config2__LineType__c = :LINETYPE_PRODUCT
                                                              AND Apttus_Config2__IsPrimaryLine__c = :true
                                                             ];
        system.debug('Mukesh bundleLines '+ bundleLines.size());
        //set Bundle Asset Id
        for(Apttus_Config2__AssetLineItem__c assetItem : assetItems){
            if(assetItem.Apttus_Config2__LineType__c == LINETYPE_OPTION){
                for(Apttus_Config2__AssetLineItem__c bundleItem : bundleLines){
                    if(bundleItem.Apttus_Config2__BusinessObjectId__c == assetItem.Apttus_Config2__BusinessObjectId__c
                       && bundleItem.Apttus_Config2__ProductId__c == assetItem.Apttus_Config2__ProductId__c
                       && bundleItem.Apttus_Config2__LineNumber__c == assetItem.Apttus_Config2__LineNumber__c){
                           assetItem.Apttus_Config2__LineType__c = 'Product/Service';
                           assetItem.Apttus_Config2__IsPrimaryLine__c = True;
                           assetItem.Apttus_Config2__ItemSequence__c = 1;
                           assetItem.Apttus_Config2__ProductId__c = assetItem.Apttus_Config2__OptionId__c;
                           assetItem.Apttus_Config2__OptionId__c = Null;
                           //assetItem.Apttus_Config2__BundleAssetId__c = bundleItem.Id;
                           BundleIds.add(bundleItem.Id);
                           System.debug('MS TEST15'+assetItem.Apttus_Config2__ProductId__c);
                           System.debug('MS TEST16'+assetItem.Apttus_Config2__OptionId__c);
                           break;
                       }
                }
            }
        }
        update assetItems;
        //**********************************
        //copy product attribute values
        //**********************************
        Map<ID, ID> proposalAssetMap = new Map<ID, ID>();
        for(Apttus_Config2__AssetLineItem__c assetItem : assetItems){
            proposalAssetMap.put(assetItem.Apttus_Config2__BusinessLineItemId__c,
                                 assetItem.Id); //BusinessLineItemId__c is either agreement or proposal line item id
        }
        String nsPrefix = 'Apttus_Config2__';
        Set<String> sourceFieldNames = new Set<String>(getCustomFieldNames(Apttus_Config2__ProductAttributeValue__c.getSObjectType()));
        String qryStr = buildSelectClause(nsPrefix + 'ProductAttributeValue__c', new List<String>(sourceFieldNames));
        qryStr += ' FROM ' + nsPrefix + 'ProductAttributeValue__c';
        qryStr += ' WHERE ';
        qryStr += nsPrefix + 'LineItemId__c IN :lineItemIdList';
        qryStr += ' LIMIT 1000';
        List<Apttus_Config2__ProductAttributeValue__c> prodAttrList = Database.query(qryStr);
        List<Apttus_Config2__AssetAttributeValue__c> assetAttrList = new List<Apttus_Config2__AssetAttributeValue__c>();
        if ((prodAttrList != null) && (! prodAttrList.isEmpty())) {
            List<Apttus_Config2__AssetAttributeValue__c> apAttrList = new List<Apttus_Config2__AssetAttributeValue__c>();
            for (Apttus_Config2__ProductAttributeValue__c prodAttr : prodAttrList) {
                Apttus_Config2__AssetAttributeValue__c assetAttr = new Apttus_Config2__AssetAttributeValue__c();
                assetAttr.Apttus_Config2__AssetLineItemId__c =
                    proposalAssetMap.get(prodAttr.Apttus_Config2__LineItemId__c);
                // copy field values from
                for (String fieldName : getCustomFieldNames(Apttus_Config2__AssetAttributeValue__c.getSObjectType()))
                {
                    if(!sourceFieldNames.contains(fieldName)){
                        continue;
                    }
                    // get the field value
                    Object value = prodAttr.get(fieldName);
                    if (value != null) {
                        // set the field value
                        try {
                            assetAttr.put(fieldName, value);
                        } catch (Exception ex) {
                            System.debug(ex.getMessage());
                        }
                    }
                }
                // S-453973 : Found Title Library has restrict checked and N/A value in Apttus_Config2__AssetAttributeValue__c
                // but Title Library is not restricted in Apttus_Config2__ProductAttributeValue__c
                if(assetAttr.Title_Library__c == null || assetAttr.Title_Library__c == ''){
                    assetAttr.Title_Library__c  = 'N/A';
                }
                assetAttrList.add(assetAttr);
            }
            upsert assetAttrList;
        }

        if(BundleIds.size() > 0 )
        {
            List<Apttus_Config2__AssetLineItem__c> bundleLinesMain = [SELECT Id

                                                                      FROM Apttus_Config2__AssetLineItem__c
                                                                      WHERE id = :BundleIds
                                                                     ];
            delete bundleLinesMain;
        }
    }
    //function to get custom field names
    List<String> getCustomFieldNames(Schema.SObjectType sobjectType) {
        // get custom field names from the object
        List<String> fieldNames = new List<String>();
        // get the field metadata
        Schema.DescribesObjectResult metadata = sobjectType.getDescribe();
        for (Schema.SObjectField field : metadata.fields.getMap().values())
        {
            // use the fully qualified field name as the key
            Schema.DescribeFieldResult fldMetadata = field.getDescribe();
            if (fldMetadata.isCustom()) {
                // add the custom field
                fieldNames.add(fldMetadata.getName());
            }
        }
        return fieldNames;
    }

    //build select clause
    String buildSelectClause(String sObjectName, List<String> fieldNames) {
        String query = 'SELECT ';
        // standard fields
        query += 'Id, Name';
        // custom fields
        if (fieldNames != null) {
            for (String fieldName : fieldNames) {
                if (fieldName == 'Id' || fieldName == 'Name') {
                    continue;
                }
                query += ',' + fieldName;
            }
        }
        return query;
    }
    /*
** @author : Cloud Sherpas, Inc.
** @date : 9/18/2014
** @story : 0775
** @element : E2236
** @description : Populate the values of the fields below in the Quote/Proposal object. The values will be coming from the
Partner_Revenue_Share__c object that has the same AccountID as quote and Site Channel ID is the same with
Quote's Sales Channel ID.
- Co_Brand__c
- Monster_Service_Contact__c
- Co_brand_Password_Link__c
- Hiring_URL__c
** @paramaters : list of Apttus_Proposal__Proposal__c records
** @returns : nothing
*/
    public void populateFieldsI(Apttus_Proposal__Proposal__c[] pApttusProposal){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populateFieldsI');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Map<Id,String> AccountSalesChannelMap = new Map<Id,String>();
        for(Apttus_Proposal__Proposal__c eachproposal: pApttusProposal){
            AccountSalesChannelMap.put(eachproposal.AccountID__c, eachproposal.Sales_Channel_ID__c);
        }
        Map<Id, Partner_Revenue_Share__c> PartnerRevenueShareMap = new Map<Id, Partner_Revenue_Share__c>();
        if(!AccountSalesChannelMap.IsEmpty()){
            for(Partner_Revenue_Share__c prs : [SELECT Id, Partner__c, Co_Brand__c, Monster_Service_Contact__c, Co_brand_Password_Link__c, Hiring_URL__c, SiteChannelID__c  FROM Partner_Revenue_Share__c WHERE Partner__c IN: AccountSalesChannelMap.keySet()]){
                if(prs.SiteChannelID__c == AccountSalesChannelMap.get(prs.Partner__c)){
                    PartnerRevenueShareMap.put(prs.Partner__c, prs);
                }
            }
        }
        if(!PartnerRevenueShareMap.IsEmpty()){
            for(Apttus_Proposal__Proposal__c eachproposal: pApttusProposal){
                if(PartnerRevenueShareMap.get(eachproposal.AccountID__c) != null){
                    eachproposal.Monster_Service_Contact__c = PartnerRevenueShareMap.get(eachproposal.AccountID__c).Monster_Service_Contact__c;
                    eachproposal.Co_Brand__c = PartnerRevenueShareMap.get(eachproposal.AccountID__c).Co_Brand__c;
                    eachproposal.Co_brand_Password_Link__c = PartnerRevenueShareMap.get(eachproposal.AccountID__c).Co_brand_Password_Link__c;
                    eachproposal.Hiring_URL__c = PartnerRevenueShareMap.get(eachproposal.AccountID__c).Hiring_URL__c;
                }
            }
        }
    }

    /*
** @author : Apttus
** @date : 05/18/2015
** @description : Updates Quote status to 'Accepted Offline' if quote is finalized from GCS User
** @paramaters : List of new Apttus_Proposal__Proposal__c objects, Map of Old Apttus_Proposal__Proposal__c object
** @returns : Nothing
*/
    public void SetQuoteStatusWhenFinalize(Apttus_Proposal__Proposal__c[] pApttusProposalList,  map<Id,Apttus_Proposal__Proposal__c> pOldApttusProposalMap){

        List<Id> proposalIds = new List<Id>();
        Map<Id,string> proposalsOppRecordTypeMap = new Map<Id,string>();
        Map<Id,string> proposalsAndNewStatus = new Map<Id,string>();
        if(pApttusProposalList != null)
        {
            for(Apttus_Proposal__Proposal__c apttusProposal : pApttusProposalList){
                proposalIds.add(apttusProposal.Id);
            }
        }

        if(proposalIds != null && proposalIds.size() > 0)
        {
            for(Apttus_Proposal__Proposal__c currentProposal: [Select Id,Apttus_Proposal__Opportunity__r.RecordType.Name from Apttus_Proposal__Proposal__c where Id in:proposalIds])
            {
                proposalsOppRecordTypeMap.put(currentProposal.Id, currentProposal.Apttus_Proposal__Opportunity__r.RecordType.Name);
            }
        }


        if(pApttusProposalList != null && proposalsOppRecordTypeMap.size() >0)
        {
            for(Apttus_Proposal__Proposal__c apttusProposal : pApttusProposalList){
                if(apttusProposal.Apttus_QPConfig__ConfigurationFinalizedDate__c != pOldApttusProposalMap.get(apttusProposal.Id).Apttus_QPConfig__ConfigurationFinalizedDate__c){

                    if(proposalsOppRecordTypeMap.containsKey(apttusProposal.Id))
                    {
                        if(proposalsOppRecordTypeMap.get(apttusProposal.Id) == 'GCS Opportunity')
                        {
                            proposalsAndNewStatus.put(apttusProposal.Id, 'Accepted Offline');
                        }
                    }
                }


            }
        }

        if(proposalsAndNewStatus.size() > 0)
        {
            List<Apttus_Proposal__Proposal__c> proposalsToUpdate = new List<Apttus_Proposal__Proposal__c>();
            for(Id propId:proposalsAndNewStatus.keySet())
            {
                Apttus_Proposal__Proposal__c newProp = new Apttus_Proposal__Proposal__c(Id=propId,QuoteStatus__c='Accepted Offline');
                proposalsToUpdate.add(newProp);
            }
            update proposalsToUpdate;
        }

    }

    /*
** @author : Apttus
** @date : 06/05/2015
** @description : Check if the proposal pass throw the approval process but does not have any approval process required.
** @paramaters : List of new Apttus_Proposal__Proposal__c objects
** @returns : Nothing
*/
    public void SetAutoApprovalProcessList(List<Apttus_Proposal__Proposal__c> pApttusProposalList, MAP<id,Apttus_Proposal__Proposal__c> pOldApttusProposalMap )
    {

        Set<id> setProposalId = New Set<id>();
        MAP<id,integer> MAPCount =  new MAP<id,integer>();
        for(Apttus_Proposal__Proposal__c proposalSO : pApttusProposalList){
            If(proposalSO.Apttus_QPApprov__Approval_Status__c != pOldApttusProposalMap.get(proposalSO.id).Apttus_QPApprov__Approval_Status__c)
            {
                setProposalId.add(proposalSO.id);
            }
        }
        AggregateResult[] groupedResults = [select  Apttus_QPApprov__ProposalId__c,Count(id) cnt
                                            from Apttus_Approval__Approval_Request__c
                                            WHERE  Apttus_QPApprov__ProposalId__c =  :setProposalId
                                            group by Apttus_QPApprov__ProposalId__c ];

        for(AggregateResult TempResult : groupedResults ){
            id  TempRequest = (id) TempResult.get('Apttus_QPApprov__ProposalId__c');
            integer Count = (integer) TempResult.get('cnt');


            MAPCount.Put(TempRequest,Count);
        }
        List<Apttus_Proposal__Proposal__c> proposalSOList = [select
                                                             id,Name,
                                                             Apttus_QPApprov__Approval_Status__c ,
                                                             Auto_Approval_Message__c
                                                             from Apttus_Proposal__Proposal__c where id in :setProposalId];




        for(Apttus_Proposal__Proposal__c proposalSO : proposalSOList){
            If(MAPCount.Get(proposalSO.id) != NULL && MAPCount.Get(proposalSO.id) > 0 )
            {
                proposalSO.Auto_Approval_Message__c = proposalSO.Apttus_QPApprov__Approval_Status__c;

            }
            else
            {
                proposalSO.Auto_Approval_Message__c = 'No Approval Needed';
            }
        }

        If(proposalSOList.size() > 0 )
        {
            Update proposalSOList;
        }

    }

    /*
** @author : Apttus
** @date : 08/04/2015
** @description : This method updates the Start Date field of all line items from the quote header Revised Date field
** (Note: Revised date will be populated from the eSignature functionality)
** @paramaters : List of new Apttus_Proposal__Proposal__c objects and List of old Apttus_Proposal__Proposal__c
** @returns : Nothing
*/
    public void PopulateLineItemsStartDateFromRevisedDate(Apttus_Proposal__Proposal__c[] pApttusProposal, map<Id, Apttus_Proposal__Proposal__c> pOldApttusProposalMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','PopulateLineItemsStartDateFromRevisedDate');
        List<Apttus_Proposal__Proposal__c> proplist = new List<Apttus_Proposal__Proposal__c>();
        Set<Id> propIds = new Set<Id>();
        Map<Id,Apttus_Proposal__Proposal__c> proposalMap = new Map<Id,Apttus_Proposal__Proposal__c>();
        for(Apttus_Proposal__Proposal__c eachproposal: pApttusProposal){
            if(pOldApttusProposalMap == null || eachproposal.APTS_Revised_Start_Date__c != pOldApttusProposalMap.get(eachproposal.Id).APTS_Revised_Start_Date__c){
                proplist.add(eachproposal);
                propIds.add(eachproposal.Id);

                /*Date startDate = eachproposal.APTS_Revised_Start_Date__c;
if(Date.today() > eachproposal.APTS_Revised_Start_Date__c)
{
startDate = Date.today();
}
else if(eachproposal.APTS_Revised_Start_Date__c > (eachproposal.Apttus_Proposal__ExpectedEndDate__c + 15))
{
startDate = eachproposal.Apttus_Proposal__ExpectedEndDate__c + 15;
}*/
                proposalMap.put(eachproposal.Id, eachproposal);
                //proposalRevisedDateMap.put(eachproposal.Id, startDate);
            }
        }
        system.debug('propIds.isEmpty()-->' + propIds.isEmpty());
        if(!propIds.isEmpty())
        {
            List<Apttus_Proposal__Proposal_Line_Item__c> lineItems = [Select Id,Apttus_QPConfig__StartDate__c,Apttus_Proposal__Proposal__c from Apttus_Proposal__Proposal_Line_Item__c where Apttus_Proposal__Proposal__c in:propIds];
            for(Apttus_Proposal__Proposal_Line_Item__c currentLineItem:lineItems)
            {
                if(proposalMap.containsKey(currentLineItem.Apttus_Proposal__Proposal__c))
                {
                    Apttus_Proposal__Proposal__c currentProposal = proposalMap.get(currentLineItem.Apttus_Proposal__Proposal__c);
                    integer daysDifference = currentProposal.Apttus_Proposal__ExpectedStartDate__c.daysBetween(currentProposal.Apttus_Proposal__ExpectedEndDate__c);
                    //eachproposal.Apttus_Proposal__ExpectedEndDate__c
                    Date startDate = currentProposal.APTS_Revised_Start_Date__c;
                    Date endDate = currentProposal.Apttus_Proposal__ExpectedEndDate__c;
                    if(Date.today() > currentProposal.APTS_Revised_Start_Date__c)
                    {
                        startDate = Date.today();
                    }
                    else if(currentProposal.APTS_Revised_Start_Date__c > (currentProposal.Apttus_Proposal__ExpectedEndDate__c + 15))
                    {
                        startDate = currentProposal.Apttus_Proposal__ExpectedEndDate__c + 15;
                    }
                    endDate = startDate.addDays(daysDifference);
                    system.debug('startDate-->' + startDate + '  endDate-->' + endDate);
                    currentLineItem.Apttus_QPConfig__StartDate__c = startDate;
                    currentLineItem.Apttus_QPConfig__EndDate__c = endDate;
                }
            }

            if(!lineItems.isEmpty())
            {
                ApttusProposalLineItemTriggerHandler.ExecuteTriggers=false;// changes for locking issue in echosign
                update lineItems;
            }
        }
    }

    /*
** @author : Apttus
** @date : 08/13/2015
** @description : (Story#  S-320222) This method check if the Quote Status is Accepted Online (In the case of Echosign when both parties agreed)
** then update the opportunit's field as it is done in the case when user click on "Ready For Validation" button in Proposal when offline attachment submitted.
** @paramaters : List of new Apttus_Proposal__Proposal__c objects
** @returns : Nothing
*/
    public void updateOpportunityStage(List<Apttus_Proposal__Proposal__c> proposalList, Map<Id,Apttus_Proposal__Proposal__c>pOldProposalMap ){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateOpportunityStage');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        Map<ID,Opportunity> OppsToUpdate = new Map<ID,Opportunity>();
        set<id> OppSet = new set<id>();
        for(Apttus_Proposal__Proposal__c newProp:proposalList)
        {
            SYstem.debug('MS TESTnewProp.QuoteStatus__c '+ newProp.QuoteStatus__c );
            SYstem.debug('MS TESTnewProp.APTS_Quote_Type__c '+ newProp.APTS_Quote_Type__c );


            if((newProp.QuoteStatus__c == 'Accepted Online' && pOldProposalMap.get(newProp.id).QuoteStatus__c != 'Accepted Online' ) ||
                                           ((newProp.QuoteStatus__c == 'Accepted Offline' && pOldProposalMap.get(newProp.id).QuoteStatus__c != 'Accepted Offline') &&  (newProp.Conversion_Proposal__c || newProp.APTS_Quote_Type__c == 'Product Conversion')  ))//I-213467 changes
            {
                if(!OppsToUpdate.containsKey(newProp.OpportunityID__c))
                {
                    /*
                    Opportunity opp = new Opportunity(Id=newProp.OpportunityID__c,ReadyForProcessing__c=true,
                    StageName='Stage 4 - Won',Probability=90,IsValidationRequest__c=true,
                    Skip_Stage_Validation__c=true, OrderCreated__c = true, AutoCreateOrder__c = true);
                    OppsToUpdate.put(newProp.OpportunityID__c, opp);
                    */
                    OppSet.add(newProp.OpportunityID__c);
                }
                newProp.Order_placed__c = true;
            }
        }

        Boolean newMethod = Boolean.valueOf(orgSettings.Echosign_Order_Via_Agreement_Trigger__c); //JFreese Appirio 4/12/17 S-473744
        String dbg = '';
        if(OppSet.size() > 0)
        {
          if (newMethod){ //JFreese Appirio 4/12/17 S-473744
            dbg = '\n\nNot enqueuing APTS_echoSign_IQueue(OppSet) at this time, ';
            dbg += 'because to do so may result in an Unable to Lock Record error ';
            dbg += 'with respect to the contact or account.\n';
            dbg += 'Instead we are using the createOrder method in the Agreement trigger ';
            dbg += 'to enqueue the job when the Data Mapping process is resolved. ';
            dbg += 'This is done in Update_oppty_proposal_on_status_Signed.trigger.\n\n';
            system.debug(dbg);
          }else {
            /* Jeff L - 6-3-16, commenting this out - we can have up to 50 queueable jobs created in one context,
              if we are at that limit we have bigger issues.  Right now this might be breaking because there is a chance other queuables are
              invoked, and this is just blanket stopping this functionality
              //If(Limits.getQueueableJobs() == 0)  //This condition put by Rohit B on 22/Oct/2015 for eliminate too many queueable error.
              */
              System.debug('----enqueueing job OppSet ' + OppSet);
              ID jobID = System.enqueueJob(new APTS_echoSign_IQueue(OppSet));
              //update OppsToUpdate.values();
          }
        }

    }


    //Sylvester Agyen - 4/29/16
    //I-203835
    //Method copies agencyio to order when agencyio is initially set on proposal
    public void setAgencyIOonOrder(List<Apttus_Proposal__Proposal__c> proposalList, Map<Id,Apttus_Proposal__Proposal__c>pOldProposalMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','setAgencyIOonOrder');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        /*J Freese Appirio I-203835 This method was originally written to take action when AgencyIO__c was first populated,
          and copy it down to the order if it existed.

          This was needed because in the Echosign process, the timing of AgencyIO__c population vs order generateion is hard to predict,
          and there were instances where the AgencyIO__c was populated after the order was created (missing the OrderGeneration bulk copy).
          That worked at the time, but then started failing again, as the order did not exist when AgencyIO__c was populated.

          I modified the method to take action whenever the AgencyIO__c is populated, copy it down to the order if the order exists and
          order.AgencyIO__c is null.

          I also modified ApttusProposalTriggerHandler to ALWAYS run this method OnAfterUpdate, even when the other AfterUpdate methods
          are being bypassed to prevent recursion.

          Even that was not sufficient to fix the problem, so I also modified OnlineFlowProcess.cls where it is setting invalidAgencyIO,
          to have it make a last check to see if the proposal AgencyIO__c is populated, and copy it down if so.*/

        List<Apttus_Proposal__Proposal__c>proposalsToProcess = new List<Apttus_Proposal__Proposal__c>();
        List<Order__c>ordersToUpdate = new List<Order__c>();
        Set<id>propSet = new Set<Id>();
        //Payment_Method1__c, CustomerPO__c, APTPS_Contract_Start_Date__c, BillingStreet__c,BillingStateProvince__c,
        //BillingZipPostalCode__c,BillingCountry__c,Billing_Country_Code__c
        for(Apttus_Proposal__Proposal__c newProp :proposalList){
            if(newProp.AgencyIO__c != null || newProp.Payment_Method1__c != '' || newProp.CustomerPO__c != '' || newProp.APTPS_Contract_Start_Date__c != null ){
                propSet.add(newProp.id);
                proposalsToProcess.add(newProp);
            }
        }
        system.debug('^^^ propSet='+propSet);
        if(propSet.size() > 0){
            List<Order__c>results = [select id,Payment_Method_text__c,CustomerPO__c, QuoteProposal__c, AgencyIO__c,APTPS_Contract_Start_Date__c,
                                               BillingStreet__c,BillingStateProvince__c,BillingZipPostalCode__c,BillingCountry__c,Billing_Country_Code__c
                                    from Order__c
                                    where QuoteProposal__c IN:propSet];
          if(results != null){
            for(Order__c ord : results){
              boolean needsUpdate = false;
              for(Apttus_Proposal__Proposal__c newProp :proposalsToProcess){
                if(ord.QuoteProposal__c == newProp.id && ord.AgencyIO__c == null){
                  if(String.isNotBlank(newProp.AgencyIO__c) && ord.AgencyIO__c != newProp.AgencyIO__c){
                    ord.AgencyIO__c = newProp.AgencyIO__c;
                    needsUpdate = true;
                  }
                  /* Issue : S-455153 - Shyam 11/6
                  if(String.isNotBlank(newProp.Payment_Method1__c) && ord.Payment_Method_text__c != newProp.Payment_Method1__c){
                    ord.Payment_Method_text__c = newProp.Payment_Method1__c;
                    needsUpdate = true;
                  }
                  */
                  if(String.isNotBlank(newProp.CustomerPO__c) && ord.CustomerPO__c != newProp.CustomerPO__c){
                    ord.CustomerPO__c = newProp.CustomerPO__c;
                    needsUpdate = true;
                  }
                  if(newProp.APTPS_Contract_Start_Date__c != null && ord.APTPS_Contract_Start_Date__c != newProp.APTPS_Contract_Start_Date__c){
                    ord.APTPS_Contract_Start_Date__c = newProp.APTPS_Contract_Start_Date__c;
                    needsUpdate = true;
                  }
                  if(String.isNotBlank(newProp.BillingStreet__c) && ord.BillingStreet__c != newProp.BillingStreet__c){
                    ord.BillingStreet__c = newProp.BillingStreet__c;
                    needsUpdate = true;
                  }
                  if(String.isNotBlank(newProp.BillingStateProvince__c) && ord.BillingStateProvince__c != newProp.BillingStateProvince__c){
                    ord.BillingStateProvince__c = newProp.BillingStateProvince__c;
                    needsUpdate = true;
                  }
                  if(String.isNotBlank(newProp.BillingZipPostalCode__c) && ord.BillingZipPostalCode__c != newProp.BillingZipPostalCode__c){
                    ord.BillingZipPostalCode__c = newProp.BillingZipPostalCode__c;
                    needsUpdate = true;
                  }
                  if(String.isNotBlank(newProp.BillingCountry__c) && ord.BillingCountry__c != newProp.BillingCountry__c){
                    ord.BillingCountry__c = newProp.BillingCountry__c;
                    needsUpdate = true;
                  }

                  if(needsUpdate){
                    ordersToUpdate.add(ord);
                  }
                }
              }
            }
          }
        }
        if(ordersToUpdate.size() > 0){
           update ordersToUpdate;
        }
    }

    public Boolean GenerateCreditRequest(List<Apttus_Proposal__Proposal__c> proposalList, MAP<id,Apttus_Proposal__Proposal__c> oldProposalMAP){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','GenerateCreditRequest');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        APTS_creditHelper oClass = new APTS_creditHelper();

        set<id> Proposalid = new set<id>();


        for(Apttus_Proposal__Proposal__c prop:proposalList)
        {

            /*
if(prop.APTS_Quote_Type__c == 'Product Conversion' && (prop.Apttus_Proposal__Approval_Stage__c == 'Approved' ||
prop.QuoteStatus__c == 'Accepted Online' ||
prop.QuoteStatus__c == 'Accepted Offline')
&& oldProposalMAP.get(prop.id).Apttus_Proposal__Approval_Stage__c <> prop.Apttus_Proposal__Approval_Stage__c)
*/
            if (proposalList.size() <= cutoff || prop.Id == debugId){ //JFreese Appirio S-435483 4/11/17
              SYstem.debug('prop.APTS_Quote_Type__c'+ prop.APTS_Quote_Type__c);
              SYstem.debug('prop.Apttus_QPConfig__ConfigurationFinalizedDate__c'+ prop.Apttus_QPConfig__ConfigurationFinalizedDate__c);
              SYstem.debug('oldProposalMAP.get(prop.id).Apttus_QPConfig__ConfigurationFinalizedDate__c'+ oldProposalMAP.get(prop.id).Apttus_QPConfig__ConfigurationFinalizedDate__c);
            }
            if( (prop.Conversion_Proposal__c || prop.APTS_Quote_Type__c == 'Product Conversion')//I-213467 changes
               && prop.Apttus_QPConfig__ConfigurationFinalizedDate__c  != oldProposalMAP.get(prop.id).Apttus_QPConfig__ConfigurationFinalizedDate__c)
            {
                Proposalid.add(prop.id);
            }
        }
        SYstem.debug('Proposalid.size() '+ Proposalid.size()  );
        iF(Proposalid.size() > 0)
        {
            ID jobID = System.enqueueJob(new Apts_Credit_QuueInterFace(Proposalid));
            System.debug('Apts_Credit_QuueInterFace'+jobID);
            return true;
        }
        return false;
        // APTS_creditHelper.ProcessProductConversion(Proposalid);


    }

    public Map<Id,User> UserIdToUsersMap()
    {
        return UserIdToUserMap;
    }


    /* Geeta Kumawat Appirio 2/2/16 for I-196924 */
    public void populatePaymentDetailForPaypalPaid(List<Apttus_Proposal__Proposal__c> proposalList, MAP<id,Apttus_Proposal__Proposal__c> oldProposalMAP){
        for(Apttus_Proposal__Proposal__c prop:proposalList){
            if (proposalList.size() <= cutoff || prop.Id == debugId){ //JFreese Appirio S-435483 4/10/17
              System.debug('prop.QuoteStatus__C>>>'+prop.QuoteStatus__C);
            }
            if((prop.AccountOrganization__c == 'North America' && prop.PaypalReferenceNumber__c != null
               && prop.QuoteStatus__c != oldProposalMAP.get(prop.Id).QuoteStatus__c
               && (prop.QuoteStatus__c == 'Accepted Offline' || prop.QuoteStatus__c == 'Accepted Online') )
               || prop.PaypalResultCode__c == '0'){
                   prop.Payment_Method1__c = 'Credit Card';
                   prop.Payment1_Frequency__c = 'Single Payment';
                   prop.Payment1_Term__c = 'Immediate';
                   prop.Installments__c = 1;
               }
        }
    }

/*
** @author : Monster, ASuchanek
** @date : 06/08/2016
** @description : Issue I-220832 - Code supporting DE Template's conditional text
Bring value of DirectDebitDiscount flag from the billing account or agency to the Quote record.
** @paramaters : list of new Apttus_Proposal__Proposal__c and old records
** @returns : nothing
*/
public void updateDirectDebitDiscountFlag(Apttus_Proposal__Proposal__c[] pNewProps, Map<Id,Apttus_Proposal__Proposal__c> mapOldPropVals ) {
     final string METHODNAME = CLASSNAME.replace('METHODNAME','updateDirectDebitDiscountFlag');
     system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

//prepare the data from the accounts; get list of accounts to work with; get the direct debit discoutns
     set<id> setAccountIds = new set<id>();
     for(Apttus_Proposal__Proposal__c oProp : pNewProps ){
          if(oProp.BillingAccount__c != null){
               setAccountIds.add(oProp.BillingAccount__c);
          }
          if(oProp.Agency__c != null){
               setAccountIds.add(oProp.Agency__c);
          }
     }
     Map<id,Account> mapAccounts = new map<id,Account>([SELECT id, DirectDebitDiscount__c FROM Account WHERE id IN: setAccountIds]);
/* Perform the main update logic:
If Agency is present and different from the previous value on the Quote then
  copy Direct Debit Discount from Agency account to Quote
else (agency is not present, work with Billing Account) if BillingAccount is different from previous value
  copy Direct Debit Discount from Billing Account to Quote
*/

     for(Apttus_Proposal__Proposal__c objANewProp : pNewProps) {
          if (mapOldPropVals != null
            && ( objANewProp.Agency__c != mapOldPropVals.get(objANewProp.Id).Agency__c
            || objANewProp.BillingAccount__c != mapOldPropVals.get(objANewProp.Id).BillingAccount__c )) {
               if(objANewProp.Agency__c != null && objANewProp.Agency__c != mapOldPropVals.get(objANewProp.Id).Agency__c ) {
                    objANewProp.Billing_Account_DD_Discount__c = mapAccounts.get(objANewProp.Agency__c).DirectDebitDiscount__c;
               } else if(objANewProp.BillingAccount__c != null && objANewProp.BillingAccount__c != mapOldPropVals.get(objANewProp.Id).BillingAccount__c ) {
                    objANewProp.Billing_Account_DD_Discount__c = mapAccounts.get(objANewProp.BillingAccount__c).DirectDebitDiscount__c;
               }
          }  else if (mapOldPropVals == null) { //for call from OnBeforeInsert
               if (objANewProp.Agency__c != null) {
                 objANewProp.Billing_Account_DD_Discount__c = mapAccounts.get(objANewProp.Agency__c).DirectDebitDiscount__c;}
               else if (objANewProp.BillingAccount__c != null) {
                  objANewProp.Billing_Account_DD_Discount__c = mapAccounts.get(objANewProp.BillingAccount__c).DirectDebitDiscount__c;
               }
          }
     }
}


public void ValidateOwnerSalesChannel(Apttus_Proposal__Proposal__c[] pApttusProposalList) {
  final string METHODNAME = CLASSNAME.replace('METHODNAME','ValidateOwnerSalesChannel');
  system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
   set<Id> primarySalesRepIds = new set<Id>();
  for(Apttus_Proposal__Proposal__c proposal : pApttusProposalList){
       if(proposal.ownerId != null){
            primarySalesRepIds.add(proposal.ownerId);
       }
  }
  map<Id, User> userMap = new map<Id, User> ([Select Id,Combined_Region__c,Position_Organization__c,PositionSalesChannel__c
                                              from User Where Id IN :primarySalesRepIds]);
  system.debug('^^^usermap: ' + usermap);
  set<String> combinedReasonSet = new set<String>();
  set<String> PositionOrgSet = new set<String>();
  set<String> PositionSalesChannelSet = new set<String>();
  set<String> SellingCountrySet = new set<String>();
  set<String> SalesChannelStoreList = new set<String> ();
  //set<id> setOppIds = new Set<Id>();
  List<Sales_Channel_Cross_Reference__c> SaleschannelRecords = new List<Sales_Channel_Cross_Reference__c> ();
  User user;
  boolean IsValid;

  for(Apttus_Proposal__Proposal__c proposal : pApttusProposalList){
      user = userMap.get(proposal.ownerId);

      combinedReasonSet.add(user.Combined_Region__c);
      PositionOrgSet.add(user.Position_Organization__c);
      PositionSalesChannelSet.add(user.PositionSalesChannel__c);
      SellingCountrySet.add(proposal.Selling_Country__c);
      //setOppIds.add(proposal);
      system.debug('Combined region ' + user.Combined_Region__c);
      system.debug('Position Org ' +user.Position_Organization__c);
      system.debug('Position Sales channel ' + user.PositionSalesChannel__c);
      system.debug('Selling Country ' + proposal.Selling_Country__c);
  }

   SaleschannelRecords = [Select Id,Combined_Region__c,Position_Organization__c,
                                               Position_Sales_Channel__c, Selling_Country__c
                                               from Sales_Channel_Cross_Reference__c
                                               Where (Combined_Region__c IN :combinedReasonSet OR Combined_Region__c = null)
                                               AND (Position_Organization__c IN :PositionOrgSet OR Position_Organization__c = null)
                                               AND (Position_Sales_Channel__c IN :PositionSalesChannelSet OR Position_Sales_Channel__c = null)
                                               AND (Selling_Country__c IN :SellingCountrySet OR Selling_Country__c = null) ];

  for(Apttus_Proposal__Proposal__c proposal : pApttusProposalList){
        if(proposal.Apttus_Proposal__Opportunity__c== null || proposal.APTS_Opportunity_Record_Type__c != 'GCS Opportunity' ){
      IsValid = false;
      system.debug('^^^ Apttus_Proposal__Opportunity__c=' + proposal.Apttus_Proposal__Opportunity__c + ', APTS_Opportunity_Record_Type__c=' + proposal.APTS_Opportunity_Record_Type__c +
                   ', isValid=' + isValid);
      user = userMap.get(proposal.ownerId);
      for(Sales_Channel_Cross_Reference__c channel : SaleschannelRecords){
        system.debug('^^^ Channel.Combined_Region__c=' + channel.Combined_Region__c + ', user.Combined_Region__c=' + user.Combined_Region__c +
                     ', channel.Position_Organization__c=' + channel.Position_Organization__c + ', user.Position_Organization__c=' + user.Position_Organization__c +
                     ', channel.Position_Sales_Channel__c=' +channel.Position_Sales_Channel__c + ', user.PositionSalesChannel__c=' + user.PositionSalesChannel__c +
                     ', channel.Selling_Country__c=' + channel.Selling_Country__c + ', proposal.Selling_Country__c=' + proposal.Selling_Country__c+
                     ', isValid=' + IsValid);
           if((channel.Combined_Region__c == user.Combined_Region__c || channel.Combined_Region__c == null)
               && (channel.Position_Organization__c == user.Position_Organization__c || channel.Position_Organization__c == null)
               && (channel.Position_Sales_Channel__c == user.PositionSalesChannel__c || channel.Position_Sales_Channel__c == null)
               && (channel.Selling_Country__c == proposal.Selling_Country__c || channel.Selling_Country__c == null) ) {
                   IsValid = true;
                   break;
           }
      }
      if(!IsValid){
          proposal.addError('Please contact Sales Operations in NA and the Pre-Quote-Check-Team in EU to correct the Primary Sales Profile. The quote cannot be processed until a valid Sales Channel is defined.'+'====='+proposal.Selling_Country__c);
      }
      }
  }

}
/*
** @author : Vikas Menon
** @date : 21/03/2017
** @description : T-586693 - Creating A Record for Opportunity Monthly Budget whenever a new Proposal is created.
** @paramaters : List of Apttus_Proposal__Proposal__c
** @returns : nothing
*/
/*
public void createOppMonthlyBudget(Apttus_Proposal__Proposal__c[] pNewApttusProposal){
    system.debug('$$Called$$');
    Set<Id> oppIds = new Set<Id>();
    Set<Id> userRoleIds = new Set<Id>();
    List<Opportunity_Monthly_Budget__c> oppBudgetList = new List<Opportunity_Monthly_Budget__c>();
    List<Apttus_Proposal__Proposal__c> prosessedProposalList = new  List<Apttus_Proposal__Proposal__c>();
   // Map<Id,Opportunity> mapOfParentOpportunities = new Map<Id,Opportunity>();

    for(UserRole objUser : [Select id from userrole where name like '%PPC%']){
        userRoleIds.add(objUser.Id);
    }
    system.debug('UserRoleids'+userRoleIds);

    for(Apttus_Proposal__Proposal__c obj : pNewApttusProposal){
        if(obj.Earliest_Start_Date__c != Null  && obj.Latest_End_Date__c != null ){
            prosessedProposalList.add(obj);
        }
    }
    system.debug('Prosessed '+prosessedProposalList);

    for(Apttus_Proposal__Proposal__c objAP : prosessedProposalList){
        oppIds.add(objAp.Apttus_Proposal__Opportunity__c);
    }

    if(oppIds.isEmpty() || userRoleIds.isEmpty()){
        return;
    }

    map<Id,Opportunity> oppMap =new Map<Id,Opportunity>([Select owner.UserRoleId ,OpportunityType__c,Amount from Opportunity where id In : oppIds AND OpportunityType__c = 'Contingent' AND owner.UserRoleId in : userRoleIds ]);

    for(Apttus_Proposal__Proposal__c objAP : prosessedProposalList){
         Opportunity opp = new Opportunity();
        if(oppMap.containsKey(objAP.Apttus_Proposal__Opportunity__c)){
             opp = oppMap.get(objAP.Apttus_Proposal__Opportunity__c);
        }
         //createOppBudgetRecord(opp,objAP);
        Opportunity_Monthly_Budget__c objoppBudget = createOppBudgetRecord(opp,objAP);
        oppBudgetList.add(objoppBudget);
    }



    if(!oppBudgetList.isEmpty()){
        system.debug('Opp Budget created');
        insert oppBudgetList;
    }
    }


    public Opportunity_Monthly_Budget__c createOppBudgetRecord(Opportunity opp ,Apttus_Proposal__Proposal__c objAPP){
        system.debug('##This is Called');
        Date startDate = objAPP.Earliest_Start_Date__c; // == proposal Earliest_Start_Date__c
        Date endDate = objAPP.Latest_End_Date__c ;  // == proposal Latest_End_Date__c
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
            index = index.AddMonths(1);
        }
        system.debug('budgetDaysTotal='+budgetDaysTotal+' budgetTotal='+budgetTotal.setScale(2));
        system.debug('budget'+Budget);
        Opportunity_Monthly_Budget__c objoppBudget = new Opportunity_Monthly_Budget__c(
            Related_Opportunity__c = opp.Id , Budget__c = Budget  );
            return objoppBudget;
    }
  */

}