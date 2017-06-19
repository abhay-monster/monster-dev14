public with sharing class leadTriggerHandler {

    final String CLASSNAME = '\n\n**** leadTriggerHandler.METHODNAME()';

    public static Integer RunCount = 0;
    public static void onBeforeInsert(List<Lead> newLeads)
    {
        updateBillingAddressFromStandardAddress(newLeads);
        LeadAssignment assignment = new LeadAssignment(newLeads);
        assignment.assignLeads();
    }

    public static void onBeforeUpdate(List<Lead> newLeads, Map<Id, Lead> oldMap)
    {
        updateBillingAddressFromStandardAddress(newLeads);     
    }

    public static void onAfterInsert(List<Lead> newLeads){
        // updateBillingAddressFromStandardAddress(newLeads);
    }

    public static void onAfterUpdate(List<Lead> newLeads, Map<Id, Lead> oldMap){
        if(RunCount > 0) return;
        //addShares(newLeads, oldMap);
        for (Lead l : newLeads){
            system.debug('^^^ leadTriggerHandler updating converted lead: ' + l);
        }
        updateconvertedLead(newLeads, oldMap);   
        createAccountCompetitor(newLeads); // added for S-434351 
        RunCount++;
        system.debug('^^^ leadTriggerHandler updated converted lead');

        //  updateBillingAddressFromStandardAddress(newLeads);
    }

    /*  added by JA for S-434351
    When a lead is converted, a new record is created in the Account Competitor related list 
    and the Competitor and it's Country from the leads record will carry over to the Account Competitor related list record. */
     private static void createAccountCompetitor(List<Lead> newLeads){

        final String CLASSNAME = '\n\n**** leadTriggerHandler.METHODNAME()';
        final string METHODNAME = CLASSNAME.replace('METHODNAME','createAccountCompetitor');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        List <CompetitiveLandscape__c> competitorToInsert = new List <CompetitiveLandscape__c> ();

        for (Integer i = 0; i < newLeads.size(); i++){
            if (newLeads[i].IsConverted == true && newLeads[i].Competitor__c != null) { 
                CompetitiveLandscape__c newAccountCompetitor = new CompetitiveLandscape__c (); 
                newAccountCompetitor.AccountCountry__c = newLeads[i].Posting_Country__c;
                newAccountCompetitor.Competitor__c = newLeads[i].Competitor__c;
                newAccountCompetitor.Account__c = newLeads[i].convertedAccountId;
                competitorToInsert.add(newAccountCompetitor);
            } // end if
        } // end for

        try {
            insert competitorToInsert;
        } catch (system.Dmlexception e) {
            system.debug (e);
        }
    }
// added for S-434351 - END 

    private static void updateconvertedLead(List<Lead> newLeads, Map<Id, Lead> oldMap){
        final String CLASSNAME = '\n\n**** leadTriggerHandler.METHODNAME()';
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateconvertedLead');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        //  try{
        
        Profile userProfile = null;
        for(Profile p :[Select Id, Name from profile where id =: UserInfo.getProfileId()]) {
            userProfile = p;
        }
        
        Id dUser;
        for(User usr : [Select  Id from User where Name like 'Data Governance%' limit 1]){
            dUser = usr.Id;
        }
        //Sylvester commented out
        //boolean IsSaleOpsUser = false;
        //for(Profile p : [Select Id,Name from Profile where Name like '%Sales Operations%' 
        //                 and Id = :UserInfo.getProfileId()]){                     
        //          IsSaleOpsUser = true;          
        //}
        boolean IsSaleOpsUser = false;      
        boolean IsAPACSalesUser = false; // Added by JA for S-460302     
        Org_Settings__c orgSettings = Org_Settings__c.getInstance();        
        system.debug('^^^^^ ORG SETTINGS '+ orgSettings);
        system.debug('^^^^^ USERPROFILE '+userProfile);
        if( userProfile != null && 
            (userProfile.Name == orgSettings.Telemarketing_Inbound__c ||              
            userProfile.Name == orgSettings.Sales_Operations_EU__c ||
            userProfile.Name == orgSettings.Sales_Operations_NA__c ||
            userProfile.Name == orgSettings.Sales_Operations_TA__c ||
            userProfile.Name == orgSettings.Sales_Operations_TA_EU__c)){
            IsSaleOpsUser = true;
        }
        else if( userProfile != null &&  
            (userProfile.Name == orgSettings.Sales_Rep_APAC__c ||
            userProfile.Name == orgSettings.Sales_Operations_APAC__c)) { // Added by JA for S-460302
            IsAPACSalesUser = true; 
            system.debug('^^^^ - orgSettings.APAC');                  
        }
        
        system.debug('SLY - IS SALES USER '+orgSettings);

        List<Id> accList = new List<Id>();
        List<Id> oppList = new List<Id>();
        List<Id> conList = new List<Id>();
        Map<Id,Lead> LeadAccountMap  = new Map<Id,Lead>();
        List<Lead> convertedLeads = [Select Id, convertedAccountId, convertedOpportunityId, ConvertedContactId, IsConverted,LeadSource
                                      from Lead Where Id IN :newLeads];

        for(Lead leadOne : convertedLeads){
            
            System.debug('after update is' + leadone.IsConverted + 'before update is ' + oldMap.get(leadone.Id).IsConverted);
            
            
            if(leadOne.IsConverted ){
                if(leadOne.convertedAccountId != Null){

                    accList.add(leadOne.convertedAccountId);
                    LeadAccountMap.put(leadOne.convertedAccountId,leadOne);
                 }
                if(leadOne.convertedOpportunityId != Null){
                    oppList.add(leadOne.convertedOpportunityId);
                }
                if(leadOne.ConvertedContactId != Null){
                    conList.add(leadOne.ConvertedContactId);
                }
            }
        }

        //Jeff L Commented out < this logic is in AccountTriggerHelper
        List<Account> toUpdateAccount =  new List<Account>();
        List<Case> toInsertCase =  new List<Case>();
        List<Opportunity> toUpdateOpportunity =  new List<Opportunity>();
        Map<Id,Contact> noupdateContact = new Map<Id,Contact>();
        Map<Id,Id> relContactPrimarySalesContactMap = new Map<Id,Id>();
        if(!accList.isEmpty()){
            for(Account accOne : [ Select Id, OwnerId, CreatedDate,Lead_Account_Status__c,
                                    CreatedByID,Lead_Source__c,AccountStatus__c
                                    From Account Where Id IN: accList]){
                system.debug('^^^ leadTriggerHandler.updateconvertedLead Summary of Account: ' + accOne);

                // I-220212 >> Update the lead source field on Account 
                if(LeadAccountMap.containsKey(accOne.Id)){
                    if(LeadAccountMap.get(accOne.Id) != null) {
                        accOne.Lead_Source__c = LeadAccountMap.get(accOne.Id).LeadSource;
                    }
                }
                // As per I-202386, When anybody wants to convert the lead it should get converted to inactive status. 
                //Only sales ops needs to have access to convert a particular lead to "active" status.
                if(IsSaleOpsUser){
                    accOne.Lead_Account_Status__c = 'Active';
                    accOne.AccountStatus__c = 'Candidate';
                }
                else if (IsAPACSalesUser){ // Added by JA for S-460302
                    accOne.Lead_Account_Status__c = 'Inactive';
                    accOne.AccountStatus__c = 'Lead';
                }
                else {
                    accOne.Lead_Account_Status__c = 'Inactive';
                    Case caseNew = new Case();
                    caseNew.RecordTypeId  = Utility.GetRecordTypeIdBySObjectNameAndType('Case', 'New Account Request');
                    caseNew.AccountID = accOne.Id;
                    caseNew.SystemGenerated__c = true;
                    if(dUser != null){
                        caseNew.OwnerId = dUser;
                    }
                    toInsertCase.add(caseNew);
                }

                toUpdateAccount.add(accOne);
            }
        }

        String oppRecTypeId  = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'Lead');
        if(!oppList.isEmpty()){
            //Org_Settings__c orgSettings = Org_Settings__c.getInstance();
            system.debug('SLY -  ORG SETTINGS IN SCOPE? '+orgSettings);
            for(Opportunity oppOne :[Select Id, OwnerID, StageName,OpportunityID__c,account.Name From Opportunity Where Id IN: oppList]){

                if(userProfile != null && (userProfile.Name == orgSettings.Telemarketing_Inbound__c ||
                    userProfile.Name == orgSettings.Sales_Operations_APAC__c ||
                    userProfile.Name == orgSettings.Sales_Operations_EU__c ||
                    userProfile.Name == orgSettings.Sales_Operations_NA__c ||
                    userProfile.Name == orgSettings.Sales_Operations_TA__c ||
                    userProfile.Name == orgSettings.Service_Manager_APAC__c ||
                    userProfile.Name == orgSettings.Service_Manager_EU__c ||
                    userProfile.Name == orgSettings.Service_Manager_NA__c ||
                    userProfile.Name == orgSettings.Service_Operations__c ||
                    userProfile.Name == orgSettings.Service_Rep_APAC__c ||
                    userProfile.Name == orgSettings.Service_Rep_EU__c ||
                    userProfile.Name == orgSettings.Service_Rep_NA__c ||
                    userProfile.Name == orgSettings.Service_Delivery_Bench_Agent_EU__c ||
                    userProfile.Name == orgSettings.MGS_Service_Agent__c ||
                    userProfile.Name == orgSettings.MGS_Service_Manager__c ||
                    userProfile.Name == 'Sales Rep (EU)')) {

                    oppOne.StageName = Label.Default_Lead_conversion_Stage_OPs_and_TM;
                    oppOne.LeadStatus__c = 'Not Started';
                    oppOne.RecordTypeId = oppRecTypeId;
                } else {
                    oppOne.StageName = Label.Default_Lead_Conversion_Stage_Everyone_Else;
                    oppOne.LeadStatus__c = 'Accepted';
                }

                oppOne.Name = oppOne.account.Name + ' ' + oppOne.OpportunityID__c;
                oppOne.Skip_Stage_Validation__c  = true;
                oppOne.ConvertedFromLead__c = true;                
                toUpdateOpportunity.add(oppOne);
            }
        }

        for(Contact con : [SELECT Id, AccountId, PrimarySalesContact__c,PrimaryBillingContact__c FROM Contact WHERE AccountId IN: accList]){
            if(con.PrimarySalesContact__c == true || con.PrimaryBillingContact__c == true){
                noupdateContact.put(con.AccountId, con);
            }
        }

        for(AccountContactAssociation__c aca : [SELECT Id, Account__c, PrimarySalesContact__c FROM AccountContactAssociation__c WHERE Account__c IN: accList]){
                if(aca.PrimarySalesContact__c == true){
                    relContactPrimarySalesContactMap.put(aca.Account__c,aca.Id);
                }
            }
        List<Contact> tobeUpdatedcontact = new List<Contact>();
        for(Contact con : [Select Id, OwnerId, AccountId, PrimarySalesContact__c,PrimaryBillingContact__c FROM Contact WHERE Id IN: conList]){
            if(!noupdateContact.containsKey(con.AccountId) || !relContactPrimarySalesContactMap.containsKey(con.AccountId) ){
                con.PrimarySalesContact__c = true;
                con.PrimaryBillingContact__c = true;
                tobeUpdatedcontact.add(con);
            }
        }

        if(!tobeUpdatedcontact.isEmpty()){
            for (Contact c : tobeUpdatedcontact){
                system.debug('^^^ leadTriggerHandler.updateconvertedLead Updating contact: ' + c);
            }
            update tobeUpdatedcontact;
        }
        if(!toUpdateOpportunity.isEmpty()){
            for (Opportunity o : toUpdateOpportunity){
                system.debug('^^^ leadTriggerHandler.updateconvertedLead Updating opportunity: ' + o);
            }
            update toUpdateOpportunity;
        }

        if(!toInsertCase.isEmpty()){
            for (Case cs : toInsertCase){
                system.debug('^^^ leadTriggerHandler.updateconvertedLead Inserting case: ' + cs);
            }
            //CaseTriggerHandler.ExecuteTriggers = false;
            insert toInsertCase;
        }
       
        if(!toUpdateAccount.isEmpty()){

            update toUpdateAccount;
        }
        
        //}
        //catch(Exception ex){
        //    throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Unable to update Converted Lead', ex);
        //}

    }

    private static void updateBillingAddressFromStandardAddress(List<Lead> newLeads){


        for(Lead ld : newLeads){
            if(ld.Copy_Address_to_Billing_Address__c)
            {
                ld.Street = ld.Posting_Street__c ;
                ld.City = ld.Posting_City__c;
                ld.State = ld.Posting_State_Province__c;
                ld.Country = ld.Posting_Country__c ;
                ld.PostalCode = ld.Posting_Zip_Postal_Code__c;
            }
        }
    }


    // 05.12.2016 - Below code is commented because it is not used anywhere and
    //  method call is commneted out as well. Please uncomment if it is used
    //  anywhere.  

    /*
    ** @author : Appirio Inc
    ** @date : 02/22/2016
    ** @description : method used to add shares, calls a private class to handle bypassing the sharing
    */

   /* private static void addShares(List<Lead> newLeads, Map<Id, Lead> oldMap){
        SkipSharingMethods ssm = new SkipSharingMethods();
        ssm.add_Shares(newLeads, oldMap);
    }

  
    private without sharing class SkipSharingMethods {

        final String CLASSNAME = '\n\n**** leadTriggerHandler.SkipSharingMethods.METHODNAME()';


        private SkipSharingMethods(){
        }

        
        // @author : Appirio Inc
        // @date : 10/09/2015
        // @description : method to update a number of fields on the opportunity when the Order reaches a certain stage
        
        public void add_Shares(List<Lead> newLeads, Map<Id, Lead> oldMap){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','addShares');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

            List<Id> accList = new List<Id>();
            List<Id> conList = new List<Id>();
            List<Id> oppList = new List<Id>();
            List<AccountShare> AccountShareToInsertList = new List<AccountShare>();

            for(Lead leadOne : newLeads){
                if(leadOne.IsConverted && !oldMap.get(leadOne.id).IsConverted){
                    if(leadOne.convertedAccountId != Null){
                        accList.add(leadOne.convertedAccountId);
                     }
                    if(leadOne.convertedContactId != Null){
                        conList.add(leadOne.convertedContactId);
                    }
                    if(leadOne.convertedOpportunityId != Null){
                        oppList.add(leadOne.convertedOpportunityId);
                    }
                }
            }

            if(!accList.isEmpty()){
                for (Id acctId : accList){
                    AccountShareToInsertList.add(new AccountShare(UserOrGroupId=UserInfo.getUserId(), AccountId=acctId, AccountAccessLevel='Edit',OpportunityAccessLevel='Edit',CaseAccessLevel='Edit'));
                }
            }

            Database.SaveResult[] sharingRuleSaveResult = Database.insert(AccountShareToInsertList,false);

            //insert the new shares
            Integer newShareCnt = 0;

            for(Database.SaveResult saveResult: sharingRuleSaveResult){
                if(!saveResult.isSuccess()){
                    Database.Error saveResultErrorMessage = saveResult.getErrors()[0];
                    system.debug(LoggingLevel.DEBUG, METHODNAME + '\n\nERROR ADDING SHARING:'+ AccountShareToInsertList[newShareCnt]+'::'+ saveResultErrorMessage);
                }
                else{
                    List<AccountShare> accShares = [SELECT UserOrGroupId, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel, ContactAccessLevel, rowcause from AccountShare WHERE AccountId =: AccountShareToInsertList[newShareCnt].AccountId];
                    system.debug('^^^ Summary of AccountShares for Account ' + AccountShareToInsertList[newShareCnt].AccountId);
                    for (AccountShare accs : accShares){
                        system.debug(accs);
                    }
                   
                    List<OpportunityShare> oppShares = [SELECT UserOrGroupId, OpportunityId, OpportunityAccessLevel, rowcause from OpportunityShare WHERE OpportunityId IN: oppList];
                    system.debug('^^^ Summary of OpportunityShares for Opportunity IN ' + oppList);
                    for (OpportunityShare opps : oppShares){
                        system.debug(opps);
                    }
                }
                newShareCnt++;
            }
        }

    } */

}