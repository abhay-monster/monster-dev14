/*
** @author : Cloud Sherpas Inc.
** @date : 03/20/2014
** @description :   class that supports the OpportunityTriggerHelper class; it provides the methods called from those classes
*/
public without sharing class OpportunityTriggerHelper
{
    final String CLASSNAME = '\n\n**** OpportunityTriggerHelper.METHODNAME()';
    private Map<string,string> userNameEmailMap = new Map<string,string>();
    // ********* PROPERTIES ***********
    private Map<Id,String> OpportunityIDAndAllocationBasis{get;set;}
    //Added by Dino Brinas
    //Story 1783/2895
    public List<Id> orderLineItemIds;
    private List<Account> accountList;
    private List<OpportunityTeamMember__c> teamMemberList;
    private List<Opportunity> oppList;
    private List<Apttus_Proposal__Proposal__c> proposalList;
    public List<Opportunity> OpportunityList{get; set;}

    private map<Id, User> UserIdToUserMap{
        get{
            if(UserIdToUserMap == NULL){
                UserIdToUserMap = new map<Id,User>([SELECT Id, ManagerId FROM User]);
            }
            return UserIdToUserMap;
        }
        private set;
    }
    public Org_Settings__c orgSettings = Org_Settings__c.getInstance();
    public Integer cutoff = Integer.valueOf(orgSettings.Debug_Log_Record_Count_Cutoff__c); //JFreese Appirio S-435483 4/10/17
    public Id debugId = orgSettings.Debug_Log_Record_ID__c; //JFreese Appirio S-435483 4/11/17


    /*
** @author : Cloud Sherpas Inc.
** @date : 03/20/2014
** @description : static method that instantiates a new instance of the class
** @paramaters : nothing
** @returns : a new instance of the OpportunityTriggerHelper class
*/
    public static OpportunityTriggerHelper NewTriggerHelper(){

        //final string METHODNAME = CLASSNAME.replace('METHODNAME','NewTriggerHelper');
        //system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        OpportunityTriggerHelper newHelper = new OpportunityTriggerHelper();
        return newHelper;
    }

    /*
** @author : Cloud Sherpas, Inc.
** @date : 03/20/2014
** @description : this method is the class constructor
** @paramaters : String user profile name
** @returns : nothing
*/
    public OpportunityTriggerHelper(){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','OpportunityTriggerHelper');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

    }

    /*
** @author : Cloud Sherpas, Inc.
** @date : 03/20/2014
** @description : Creates a set of Account Ids realted to Opportunities
** @paramaters : list of Opportunity
** @returns : set of Account Ids
*/
    public set<Id> CreateAccountIdSet(list<Opportunity> pOpportunityList){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','CreateAccountIdSet');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        set<Id> accountIdSet = new set<Id>();

        for(Opportunity oOpportunity : pOpportunityList){
            accountIdSet.add(oOpportunity.AccountId);
        }

        return accountIdSet;
    }

    /*
** @author : Cloud Sherpas, Inc.
** @date : 03/20/2014
** @description : Creates a set of Account Ids realted to Opportunities
** @paramaters : list of Opportunity
** @returns : set of Account Ids
*/
    public set<Id> CreateOpportunityIdSet(list<Opportunity> pOpportunityList){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','CreateOpportunityIdSet');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        set<Id> opportunityIdSet = new set<Id>();

        for(Opportunity oOpportunity : pOpportunityList){
            opportunityIdSet.add(oOpportunity.id);
        }

        return opportunityIdSet;
    }

    /*
** @author : Appirio Inc
** @date : 10/12/2015
** @description : method is used to reset the triggerhandler, it nulls out the previously queried records
** @paramaters : nothing
** @returns : nothing
*/
    public void ResetQueries(){
        accountList = null;
        teamMemberList = null;
        proposalList = null;
        oppList = null;
    }

    /*
** @author : Appirio Inc (Jeff L)
** @date : 10/12/2015
** @description : this method checks to see if the queried account list is null, if it is it will query to get
the accounts it's use is to help reduce the overall number of queries.
** @paramaters : nothing
** @returns : List of accounts
*/
    private List<Account> queryAccountList(){
        if(accountList == null){
            Set<Id> accIds = new Set<Id>();
            accIds = CreateAccountIdSet(OpportunityList);

            accountList = [
                SELECT ID, name, CreditStatus__c, OwnerId, KeyInitiative__c, Organization__c,
                IsPersonAccount,
                (SELECT Id, UserId__c, TeamMemberRole__c ,AccountAccessLevel__c
                 FROM Account_Team_Members__r WHERE
                 TeamMemberRole__c like '%Sales%'
                 ORDER BY CreatedDate ASC),
                (SELECT AccountCountry__c, CurrencyIsoCode, Id, Competitor__c
                 FROM Competitive_Landscapes__r
                 WHERE Competitor__c != NULL)
                FROM Account
                WHERE Id IN: accIds];
        }

        return accountList;

    }

    /*
** @author : Appirio Inc (Jeff L)
** @date : 10/13/2015
** @description : this method checks to see if the queried team member list is null, if it is it will query to get
the team member it's use is to help reduce the overall number of queries.
** @paramaters : nothing
** @returns : List of Opportunity Team members
*/
    private List<OpportunityTeamMember__c> queryTeamMember(){
        if(teamMemberList == null){
            Set<Id> oppIds = new Set<Id>();
            oppIds = CreateOpportunityIdSet(OpportunityList);

            teamMemberList = [
                Select Id, TeamMember__c, Opportunity__c,
                TeamRole__c,TeamMember__r.Name
                FROM OpportunityTeamMember__c
                WHERE Opportunity__c IN: oppIds];
        }
        return teamMemberList;
    }

    /*
** @author : Appirio Inc (Jeff L)
** @date : 10/13/2015
** @description : this method checks to see if the queried Opportunity list is null, if it is it will query to get
the Opportunity it's use is to help reduce the overall number of queries.
** @paramaters : nothing
** @returns : List of Opps
*/
    private List<Opportunity> queryOpportunity(){
        Set<Id> oppIds = new Set<Id>();
        if(oppList == null){
            oppIds = CreateOpportunityIdSet(OpportunityList);

            oppList = [
                SELECT Apttus_Approval__Approval_Status__c, Id, IsClosed, IsWon, StageName,
                Owner.Country, Owner.TeamingChannel__c, SecondarySalesRep__r.Country,
                SecondarySalesRep__r.TeamingChannel__c, TeamingType__c,
                (SELECT Id, TeamMember__c, Split__c FROM Opportunity_Team_Members__r)
                FROM Opportunity
                WHERE Id IN: oppIds
            ];
        }
        if (oppIds.size() <= cutoff){ //JFreese Appirio S-435483 4/10/17
            system.debug('oppList'+oppList);
        }

        return oppList;
    }
    /*
** @author : Appirio Inc (Jeff L)
** @date : 10/13/2015
** @description : this method checks to see if the queried Proposal list is null, if it is it will query to get
the Proposal it's use is to help reduce the overall number of queries.
** @paramaters : nothing
** @returns : List of Proposals
*/

    private List<Apttus_Proposal__Proposal__c> queryProposal(){
        if(proposalList == null){
            Set<Id> oppIds = new Set<Id>();
            oppIds = CreateOpportunityIdSet(OpportunityList);

            proposalList = [
                SELECT Agency__c, Apttus_Proposal__Opportunity__c, QuoteStatus__c, Apttus_Proposal__Primary__c
                FROM Apttus_Proposal__Proposal__c
                WHERE Apttus_Proposal__Opportunity__c IN: oppIds
            ];
        }

        return proposalList;
    }


    /*
** @author : Cloud Sherpas, Inc.
** @date : 03/20/2014
** @description : Bypassing Estimate Value validation rule
** @Story 0888
** @Task E1603
** @paramaters : new opportunity list
** @returns : nothing
*/
    public void BypassingEstimateValueValidation(list<Opportunity> pUpdatedOpportunityList){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','BypassingEstimateValueValidation');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        set<Id> AccountIdSet = new set<Id>();
        for(Opportunity o : pUpdatedOpportunityList){
            if(o.AccountId != null){
                AccountIdSet.add(o.AccountId);
            }
        }

        // Jeff L updated for new query framework
        // map <Id, Account> AccountIdToAccountMap = new map<Id,Account>([SELECT Id, IsPersonAccount FROM Account WHERE Id IN :AccountIdSet]);
        map <Id, Account> AccountIdToAccountMap = new map<Id,Account>();
        for(Account a : queryAccountList()){
            if(AccountIdSet.contains(a.Id)){
                AccountIdToAccountMap.put(a.Id,a);
            }
        }

        for(Opportunity opp : pUpdatedOpportunityList){
            if ((AccountIdToAccountMap.containsKey(opp.AccountId) && AccountIdToAccountMap.get(opp.AccountId).IsPersonAccount) && opp.Amount == 0){
                opp.Amount = 1;
                //opp.Skip_Amount_Validation__c = true;
            }else if(opp.Amount > 0){
                opp.Amount = opp.Amount;
                //opp.Skip_Amount_Validation__c = true;
            }
        }
    }

    /*
** @author : Cloud Sherpas, Inc.
** @date : 03/20/2014
** @description : Creates a set of Account Ids to Account Map
** @paramaters : set of Account Ids
** @returns : map of Account Id to Account
*/
    public map<Id, Account> CreateAccountIdToAccountMap(set<Id> pAccountIdSet){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','CreateAccountIdToAccountMap');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        // get Account Owner Id to set the Opportunity Owner
        //Jeff L commented out to use our query framework
        //map<Id, Account> accountIdToAccountMap = new map<Id, Account>([SELECT id, OwnerId, KeyInitiative__c FROM Account WHERE Id IN : pAccountIdSet]);
        map<Id, Account> accountIdToAccountMap = new Map<Id, Account>();
        for(Account a : queryAccountList()){
            accountIdToAccountMap.put(a.Id, a);
        }

        return accountIdToAccountMap;
    }

    /*
** @author : Cloud Sherpas, Inc.
** @date : 03/28/2014
** @description : setCredit Status on Opportuntiy from Account
** @paramaters : list of Opportunity
** @returns : none
*/
    public void updateAgencyOfRelatedQuotes(Map<Id, Opportunity> pNewOpportunityMap, Map<Id, Opportunity> pOldOpportunityMap){
        Set<Id> oppIds = new Set<Id>();
        for(Opportunity opp : pNewOpportunityMap.values()){
            if(opp.Agency__c != pOldOpportunityMap.get(opp.Id).Agency__c){
                oppIds.add(opp.Id);
            }
        }
        if(oppIds.size() == 0){
            system.debug('No opportunity which has their agency updated.');
            return;
        }

        /* Jeff L commented out for query framework
Apttus_Proposal__Proposal__c[] proposalsToUpdate = [SELECT Agency__c, Apttus_Proposal__Opportunity__c, QuoteStatus__c
FROM Apttus_Proposal__Proposal__c
WHERE Apttus_Proposal__Opportunity__c IN :oppIds];*/

        List<Apttus_Proposal__Proposal__c> proposalsToUpdate = queryProposal();

        for(Apttus_Proposal__Proposal__c prop : proposalsToUpdate){
            if(pNewOpportunityMap.containsKey(prop.Apttus_Proposal__Opportunity__c)){
                prop.Agency__c = pNewOpportunityMap.get(prop.Apttus_Proposal__Opportunity__c).Agency__c;
            }
        }
        try{
            ApttusProposalTriggerHelper.PermitUpdateOfBilling = true;
            update proposalsToUpdate;
            ApttusProposalTriggerHelper.PermitUpdateOfBilling = false;
        }catch(Exception e){
            throw BaseApplicationException.NewExceptionWithInnerException('updateAgencyOfRelatedQuotes',
                                                                          e.getMessage()+'\nStack Trace: '+e.getStackTraceString(), 'Failed to update related quote(s) agency field.', e);
        }
    }

    /*
** @author : Cloud Sherpas, Inc.
** @date : 08/26/2014
** @description : User Story 0162 - When Quote is converted to Order,
Quote Status for non Primary Status should be systematically flagged as �Expired�.
** @paramaters : list of Opportunity, Proposals
** @returns : none
*/
    public void updateQuoteStatus(Map<Id, Opportunity> pNewOpportunityMap, Map<Id, Opportunity> pOldOpportunityMap){
        Set<Id> oppIds = new Set<Id>();
        system.debug('inside updateQuoteStatus.');

        for(Opportunity opp : pNewOpportunityMap.values()){
            if(opp.OrderCreated__c &&
               !pOldOpportunityMap.get(opp.Id).OrderCreated__c && !opp.AutoCreateOrder__c){
                   oppIds.add(opp.Id);
               }
        }
        if(oppIds.size() == 0){
            system.debug('No opportunity which has Order Created.');
            return;
        }
        /* Jeff L commented out for new query framework
Apttus_Proposal__Proposal__c[] proposalsToUpdate = [SELECT Agency__c, Apttus_Proposal__Opportunity__c, QuoteStatus__c
FROM Apttus_Proposal__Proposal__c
WHERE Apttus_Proposal__Opportunity__c IN :oppIds
AND Apttus_Proposal__Primary__c = false];
*/

        List<Apttus_Proposal__Proposal__c> proposalsToUpdate = new List<Apttus_Proposal__Proposal__c>();
        for(Apttus_Proposal__Proposal__c prop : queryProposal()){
            if(prop.Apttus_Proposal__Primary__c == false){
                proposalsToUpdate.add(prop);
            }
        }

        system.debug('proposalsToUpdate:'+proposalsToUpdate);
        for(Apttus_Proposal__Proposal__c prop : proposalsToUpdate){
            prop.QuoteStatus__c = 'Expired';
            system.debug('proposal to update:'+prop);
        }

        try{
            if(!proposalsToUpdate.isEmpty()){
                update proposalsToUpdate;
            }
        }catch(Exception e){
            throw BaseApplicationException.NewExceptionWithInnerException('updateQuoteStatus',
                                                                          e.getMessage()+'\nStack Trace: '+e.getStackTraceString(), 'Failed to update related quote(s) Status field.', e);
        }
    }



    /*
** @author : Cloud Sherpas, Inc.
** @date : 03/28/2014
** @description : Order Team Members creation
If Opportunity's Estimated Value is less than Threshold Value
the Related Order record's Approval Status marked as "Rejected" and
Order Team member whose currecntly Owner of that Opportunity gets Split value
of 100 % and all other members gets Split as Zero
** @paramaters : Map of Order and Dynamic Map for capturing Opportunity Team Member and Order Team Members fields
** @returns : none
*/
    /* private void CreateOrderTeamMember(Map<Id, Order__c> OpportunityIdToOrderMap, Map<String, Map<String, Schema.SObjectField>> pSObjectAndFields){
final string METHODNAME = CLASSNAME.replace('METHODNAME','CreateOrderTeamMember');
system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

Map<String, Schema.SObjectField> oppTeamMemberFields = pSObjectAndFields.get('OrderTeam__c');
Map<String, Schema.SObjectField> oppTeamMemberSourceFields = pSObjectAndFields.get('OpportunityTeamMember__c');

String oppTeamMemberQuery = 'SELECT ';
for(String sourceAPI : oppTeamMemberSourceFields.keySet()){
oppTeamMemberQuery += sourceAPI + ',';
}
oppTeamMemberQuery = oppTeamMemberQuery.removeEnd(',');

Set<Id> oppIds = OpportunityIdToOrderMap.keySet();
oppTeamMemberQuery += ',Opportunity__r.Amount, Opportunity__r.OwnerId, Opportunity__r.CurrencyIsoCode FROM OpportunityTeamMember__c WHERE Opportunity__c IN :oppIds';

OpportunityTeamMember__c[] oppTeamMembers = Database.query(oppTeamMemberQuery);
//Iterate on Opp Team Members and create map of Oppty Id and Opp Owner
system.debug('OpportunityTeamMember__c to be cloned in OrderTeam__c: ' + oppTeamMembers.size());

Map<String, OpportunityThreshold__c> oppThresholdMap =  new Map<String, OpportunityThreshold__c>();
for(OpportunityThreshold__c ot : [Select Name, CurrencyISOCode, Threshold__c From OpportunityThreshold__c]) {
if(ot.CurrencyISOCode!=NULL) {
oppThresholdMap.put(ot.CurrencyISOCode, ot);
}
}

list<OrderTeam__c> orderTeamToInsertList = new list<OrderTeam__c>();
set<Id> orderUpdateSet = new set<Id>();
for(OpportunityTeamMember__c member : oppTeamMembers){
OrderTeam__c orderMember = new OrderTeam__c();
for(String sourceAPI : oppTeamMemberSourceFields.keySet()){
String targetAPI = getTargetApttusFieldAPIName(sourceAPI);
if(sourceAPI != 'recordtypeid' && member.get(sourceAPI) != null && oppTeamMemberFields.containsKey(targetAPI)){
if(oppTeamMemberFields.get(targetAPI).getDescribe().isUpdateable()){
orderMember.put(targetAPI, member.get(sourceAPI));
}
}
}

orderMember.Order__c = OpportunityIdToOrderMap.get(member.Opportunity__c).Id;
orderMember.OrderAccess__c = member.OpportunityAccess__c;
if(oppThresholdMap.containsKey(member.Opportunity__r.CurrencyIsoCode) && member.Opportunity__r.Amount < oppThresholdMap.get(member.Opportunity__r.CurrencyIsoCode).Threshold__c) {
if(member.TeamMember__c == member.Opportunity__r.OwnerId) {
orderMember.split__c = member.Split__c;

}
else{
orderMember.split__c = member.Split__c;
}
orderUpdateSet.add(orderMember.Order__c);
}
//system.debug('^OpportunityIDAndAllocationBasis.get(member.Opportunity__c): '+ OpportunityIDAndAllocationBasis.get(member.Opportunity__c) );
if(OpportunityIDAndAllocationBasis.get(member.TeamMember__c) != null){
orderMember.AllocationBasis__c = OpportunityIDAndAllocationBasis.get(member.TeamMember__c);
}
orderTeamToInsertList.add(orderMember);
}
system.debug('^orderTeamToInsertList: '+orderTeamToInsertList);
insert orderTeamToInsertList;
updateOrderAsRejected(orderUpdateSet);
} */

    /*
** @author : Cloud Sherpas, Inc.
** @date : 03/28/2014
** @description : Order Team Members creation
If Opportunity's Estimated Value is less than Threshold Value
the Related Order record's Approval Status marked as "Rejected" and
Order Team member whose currecntly Owner of that Opportunity gets Split value
of 100 % and all other members gets Split as Zero
** @paramaters : Map of Order and Dynamic Map for capturing Opportunity Team Member and Order Team Members fields
** @returns : none
*/
    /* private void CreateOrderTeamMember2(set<Id> pOpportunityIdSet, Order__c[] pOrderList, Map<String, Map<String, Schema.SObjectField>> pSObjectAndFields){
final string METHODNAME = CLASSNAME.replace('METHODNAME','CreateOrderTeamMember');
system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

Map<String, Schema.SObjectField> oppTeamMemberFields = pSObjectAndFields.get('OrderTeam__c');
Map<String, Schema.SObjectField> oppTeamMemberSourceFields = pSObjectAndFields.get('OpportunityTeamMember__c');

String oppTeamMemberQuery = 'SELECT ';
for(String sourceAPI : oppTeamMemberSourceFields.keySet()){
oppTeamMemberQuery += sourceAPI + ',';
}
oppTeamMemberQuery = oppTeamMemberQuery.removeEnd(',');

oppTeamMemberQuery += ',Opportunity__r.Amount, Opportunity__r.OwnerId, Opportunity__r.CurrencyIsoCode FROM OpportunityTeamMember__c WHERE Opportunity__c IN :pOpportunityIdSet';

OpportunityTeamMember__c[] oppTeamMembers = Database.query(oppTeamMemberQuery);
//Iterate on Opp Team Members and create map of Oppty Id and Opp Owner
system.debug('OpportunityTeamMember__c to be cloned in OrderTeam__c: ' + oppTeamMembers.size());

Map<String, OpportunityThreshold__c> oppThresholdMap =  new Map<String, OpportunityThreshold__c>();
for(OpportunityThreshold__c ot : [Select Name, CurrencyISOCode, Threshold__c From OpportunityThreshold__c]) {
if(ot.CurrencyISOCode!=NULL) {
oppThresholdMap.put(ot.CurrencyISOCode, ot);
}
}

map<Id, OpportunityTeamMember__c[]> oppIdToTeamMemberListMap = new map<Id, OpportunityTeamMember__c[]>();
for(OpportunityTeamMember__c otm : oppTeamMembers){
if(!oppIdToTeamMemberListMap.containsKey(otm.Opportunity__c)){
oppIdToTeamMemberListMap.put(otm.Opportunity__c , new OpportunityTeamMember__c[]{});
}
if(oppIdToTeamMemberListMap.containsKey(otm.Opportunity__c)){
oppIdToTeamMemberListMap.get(otm.Opportunity__c).add(otm);
}
}

list<OrderTeam__c> orderTeamToInsertList = new list<OrderTeam__c>();
set<Id> orderUpdateSet = new set<Id>();
for(Order__c createdOrder : pOrderList){
if(oppIdToTeamMemberListMap.containsKey(createdOrder.Opportunity__c)){
for(OpportunityTeamMember__c member : oppIdToTeamMemberListMap.get(createdOrder.Opportunity__c)){
OrderTeam__c orderMember = new OrderTeam__c();
for(String sourceAPI : oppTeamMemberSourceFields.keySet()){
String targetAPI = getTargetApttusFieldAPIName(sourceAPI);
if(sourceAPI != 'recordtypeid' && member.get(sourceAPI) != null && oppTeamMemberFields.containsKey(targetAPI)){
if(oppTeamMemberFields.get(targetAPI).getDescribe().isUpdateable()){
orderMember.put(targetAPI, member.get(sourceAPI));
}
}
}

orderMember.Order__c = createdOrder.Id;
orderMember.OrderAccess__c = member.OpportunityAccess__c;
if(oppThresholdMap.containsKey(member.Opportunity__r.CurrencyIsoCode) && member.Opportunity__r.Amount < oppThresholdMap.get(member.Opportunity__r.CurrencyIsoCode).Threshold__c) {
if(member.TeamMember__c == member.Opportunity__r.OwnerId) {
orderMember.split__c = member.Split__c;

}
else{
orderMember.split__c = member.Split__c;
}
orderUpdateSet.add(orderMember.Order__c);
}
//system.debug('^OpportunityIDAndAllocationBasis.get(member.Opportunity__c): '+ OpportunityIDAndAllocationBasis.get(member.Opportunity__c) );
if(OpportunityIDAndAllocationBasis.get(member.TeamMember__c) != null){
orderMember.AllocationBasis__c = OpportunityIDAndAllocationBasis.get(member.TeamMember__c);
}
orderTeamToInsertList.add(orderMember);
}
}
}
system.debug('^orderTeamToInsertList: '+orderTeamToInsertList);
insert orderTeamToInsertList;
updateOrderAsRejected(orderUpdateSet);
} */
    /*
** @author : Cloud Sherpas, Inc.
** @date : 03/28/2014
** @description : If Opportunity's Estimated Value is less than Threshold Value
the Related Order record's Approval Status marked as "Rejected"
** @paramaters : set of Order Record Ids
** @returns : none
** @Updates : Logic added to mark the Rejected Reason for the Order when Threshold is not Met
** @Update Date : 05/15/2014
*/
    /*private void updateOrderAsRejected(Set<Id> orderIdSet) {
list<Order__c> orderUpdateList = new list<Order__c>();
for(Id orderId : orderIdSet) {
Order__c o = new Order__c();
o.Id = orderId;
o.Approval_Status__c = 'Rejected';
o.RejectedReason__c = 'Minimum threshold not met';
orderUpdateList.add(o);
}
if(!orderUpdateList.isEmpty()) {
update orderUpdateList;
}
}*/


    /*
** @author : Appirio
** @date : 12/29/2015
** @description : Set Opportunity Owner to default profile owner
** @paramaters : list of Opportunities
** @returns : nothing
*/

    public void SetOpportunityOfRecordType(list<Opportunity> pOpportunityList){
        Profile_Permissions__c profilePermission = Profile_Permissions__c.getInstance(UserInfo.getProfileId());
        for(Opportunity oOpportunity : pOpportunityList){
            if(profilePermission.Converted_From_Lead_RecordType__c != null || profilePermission.Converted_From_Lead_RecordType__c != ''){
                Schema.RecordTypeInfo rtInfo = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(profilePermission.Converted_From_Lead_RecordType__c);
                if(rtInfo != null){
                    Id oppRecordTypeId = rtInfo.getRecordTypeId();
                    oOpportunity.RecordTypeId = oppRecordTypeId ;
                }
            }
        }
    }





    /*
** @author : Cloud Sherpas, Inc.
** @date : 03/20/2014
** @description : Set Opportunity of Lead RecordType Owner to the related Account Owner
** @paramaters : list of Opportunities, Map of Account Id to Account
** @returns : nothing
*/
    public void SetOpportunityOfLeadRecordTypeOwnerToAccountOwner(list<Opportunity> pOpportunityList, map<Id, Account> pAccountIdToAccountMap){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','SetOpportunityOfLeadRecordTypeOwnerToAccountOwner');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        //JFreese Appirio 3/2/17 S-456572
        if (OrderTriggerHandler.CreatingCreditOpportunity == true){
            String dbg='^^^NOT processing this opportunity, as OrderTriggerHandler.CreatingCreditOpportunity='+OrderTriggerHandler.CreatingCreditOpportunity+': ';
            dbg += 'it is a Credit Opportunity created by OrderTriggerHelper.createCreditOpportunity(),\n';
            dbg += 'which set the opportunity owner to the original opp owner if that owner is a PPC user, ';
            dbg += 'else it set it to the account owner, so this method is being bypassed.';
            system.debug(dbg);
            return;
        }

        // set the Opportunity
        //JFreese Appirio 3/1/16 Originally this referenced the Lead recordType, changed to Opportunity recordType 8/28/15
        Id opportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Opportunity').getRecordTypeId();
        Id opportunityGCSOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('GCS Opportunity').getRecordTypeId();
        system.debug('Check***************' + opportunityGCSOppRecordTypeId );
        for(Opportunity oOpportunity : pOpportunityList){
            system.debug('Check***************' + pAccountIdToAccountMap.containsKey(oOpportunity.AccountId) );
            if(pAccountIdToAccountMap.containsKey(oOpportunity.AccountId)){

                // does RecordTypeId for Opportunity match the Lead Record Type
                if(oOpportunity.RecordTypeId == opportunityRecordTypeId || oOpportunity.RecordTypeId == opportunityGCSOppRecordTypeId){
                    system.debug('Check***************');
                    // set Opportunity Owner id to the Account Owner Id
                    system.debug('Check $$$$$$$$$' + oOpportunity.OwnerId );
                    system.debug('Check $$$$$$$$$' + pAccountIdToAccountMap.get(oOpportunity.AccountId).OwnerId );
                    oOpportunity.OwnerId = pAccountIdToAccountMap.get(oOpportunity.AccountId).OwnerId;
                    system.debug('Check $$$$$$$$$' + oOpportunity.OwnerId );
                }
            }
        }
    }

    /*
** @author : Cloud Sherpas, Inc.
** @date : 03/31/2014
** @description : Set Opportunity of Opportunity RecordType Owner to the related Account Owner
** @paramaters : list of Opportunities, Map of Account Id to Account
** @returns : nothing
*/
    public void SetOpportunityOfOpportunityRecordTypeOwnerToAccountOwner(list<Opportunity> pOpportunityList, map<Id, Account> pAccountIdToAccountMap){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','SetOpportunityOfOpportunityRecordTypeOwnerToAccountOwner');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        //JFreese Appirio 3/2/17 S-456572
        if (OrderTriggerHandler.CreatingCreditOpportunity == true){
            String dbg='^^^NOT processing this opportunity, as OrderTriggerHandler.CreatingCreditOpportunity='+OrderTriggerHandler.CreatingCreditOpportunity+': ';
            dbg += 'it is a Credit Opportunity created by OrderTriggerHelper.createCreditOpportunity(),\n';
            dbg += 'which set the opportunity owner to the original opp owner if that owner is a PPC user, ';
            dbg += 'else it set it to the account owner, so this method is being bypassed.';
            system.debug(dbg);
            return;
        }

        set<id> accountIdSet = CreateAccountIdSet(pOpportunityList);
        Id oppLockedRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Opportunity Locked').getRecordTypeId();
        //--------------------------
        //Id opportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Opportunity').getRecordTypeId();
        //Id opportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Opportunity Dummy Record Type').getRecordTypeId();
        //Jeff L Commented out for query optimization
        //map<Id, Account> accountIdToAccountMap = new map<Id, Account>([SELECT Id,OwnerId, (SELECT Id, UserId__c, TeamMemberRole__c ,AccountAccessLevel__c FROM Account_Team_Members__r WHERE TeamMemberRole__c like '%Sales%' ORDER BY CreatedDate ASC) FROM Account WHERE Id IN : accountIdSet]);
        map<Id, Account> accountIdToAccountMap = new Map<Id,Account>();
        for(Account a : queryAccountList()){
            accountIdToAccountMap.put(a.Id,a);
        }
        map<id,id> AccountIdSecondaryUserIdMap = new map<id,id>();

        for(Opportunity oOpportunity : pOpportunityList){
            //Jeff L commenting out this logic due to I-191877
            //if(oOpportunity.RecordTypeId == opportunityRecordTypeId){
            //system.debug('DEBUG SECONDARY LOGIC' + accountIdToAccountMap.get(oOpportunity.AccountId).AccountTeamMembers.size());
            if(accountIdToAccountMap.containskey(oOpportunity.AccountId)){
                integer count = 0;
                for(Account_Team_Member__c oAccountTeamMember : accountIdToAccountMap.get(oOpportunity.AccountId).Account_Team_Members__r ){
                    system.debug('DEBUG SECONDARY LOGIC Owner Id: ' + oOpportunity.OwnerId + ' ATM User Id ' + oAccountTeamMember.UserId__c);

                    if(pAccountIdToAccountMap.get(oOpportunity.AccountId).OwnerId != oAccountTeamMember.UserId__c){
                        AccountIdSecondaryUserIdMap.put(oOpportunity.AccountId,oAccountTeamMember.UserId__c);
                        break;
                    }
                }
            }
            //  }
        }

        //-------------------------

        // set the Opportunity
        for(Opportunity oOpportunity : pOpportunityList){

            if(pAccountIdToAccountMap.containsKey(oOpportunity.AccountId)){
                //Jeff L commenting out this logic due to I-191877
                // does RecordTypeId for Opportunity match the Lead Record Type
                //if(oOpportunity.RecordTypeId == opportunityRecordTypeId){

                // set Opportunity Owner id to the Account Owner Id
                system.debug('check &&&&&&&&&&&&&' + oOpportunity.OwnerId );
                system.debug('check &&&&&&&&&&&&&' + pAccountIdToAccountMap.get(oOpportunity.AccountId).OwnerId );
                oOpportunity.OwnerId = pAccountIdToAccountMap.get(oOpportunity.AccountId).OwnerId;
                system.debug('check &&&&&&&&&&&&&' + oOpportunity.OwnerId );

                if(AccountIdSecondaryUserIdMap.containskey(oOpportunity.AccountId)){
                    oOpportunity.SecondarySalesRep__c = AccountIdSecondaryUserIdMap.get(oOpportunity.AccountId);
                }
            }
        }
    }


    /*
** @author : Cloud Sherpas, Inc.
** @date : 04/08/2014
** @description : Set the initial pricebook of each opportunity when created
** @paramaters : list of Opportunities
** @returns : nothing
*/
    public void SetPricebookOfEveryCreatedOpportunity(list<Opportunity> pOpportunityList){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','SetPricebookOfEveryCreatedOpportunity');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        //list<Opportunity> oppToBeUpdated = [SELECT Pricebook2Id FROM Opportunity WHERE Id IN :CreateOpportunityIdSet(pOpportunityList)];

        list<Pricebook2> standardPricebook = [SELECT Id FROM Pricebook2 WHERE IsActive = true AND IsStandard = true LIMIT 1];
        system.debug('%%standardPricebook%%'+standardPricebook);
        if(standardPricebook != null && standardPricebook.size() > 0){
            for(Opportunity opp : pOpportunityList){
                opp.Pricebook2Id = standardPricebook[0].Id;
            }
            //update oppToBeUpdated;
            system.debug(LoggingLevel.INFO, 'Updated Opportunity pricebooks: ' + pOpportunityList);
            return;
        }
        system.debug('\n\nWarning: No available standard pricebook to set as the default pricebook.\n\n');
    }

    /*
** @author : Cloud Sherpas, Inc.
** @date : 03/26/2014
** @Story : 0738
** @Element : 1642
** @description : Set the Allocation Splits for Primary and Secondary Sales Reps
** @paramaters : map of Opporunity Id to Updated Opportunity, map of Opporunity Id to Old Opportunity
** @returns : nothing
** @update - updates the order team
*/
    public void SetAllocationSplitsForPrimaryAndSecondarySalesRep(map<ID, Opportunity> pOpportunityMapNew, map<ID, Opportunity> pOpportunityMapOld){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','SetAllocationSplitsForPrimaryAndSecondarySalesRep');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        list<OpportunityTeamMember__c> opportunityTeamMembersToUpdateList = new list<OpportunityTeamMember__c>();

        list<AllocationSplit__c> allocationSplitList = CreateAllocationSplitList();
        system.debug('^^allocationSplitList : ' + allocationSplitList);
        map<Id, list<OpportunityTeamMember__c>> opportunityIdToListofOppTeamMembersMap = CreateOpportunityIdToListofOpportunityTeamMembersMap(pOpportunityMapNew.KeySet());
        list<OrderTeam__c> OrderTeamToUpdate = new list<OrderTeam__c>();
        OpportunityIDAndAllocationBasis = new Map<Id, String>();

        //for(Opportunity oppty : [SELECT Apttus_Approval__Approval_Status__c, Id, IsClosed, IsWon, StageName, Owner.Country, Owner.TeamingChannel__c, SecondarySalesRep__r.Country, SecondarySalesRep__r.TeamingChannel__c, TeamingType__c FROM Opportunity WHERE Id IN : pOpportunityMapNew.KeySet()]){
        List<Opportunity> queryOpps = queryOpportunity();
        for(Opportunity oppty : queryOpps){
            if (queryOpps.size() <= cutoff || oppty.Id == debugId){ //JFreese Appirio S-435483 4/10/17
                system.debug('oppty'+oppty);
                system.debug('$$$$$'+oppty.Apttus_Approval__Approval_Status__c+'%%%'+pOpportunityMapOld.get(oppty.Id).Apttus_Approval__Approval_Status__c);
            }
            if(oppty.Apttus_Approval__Approval_Status__c != pOpportunityMapOld.get(oppty.Id).Apttus_Approval__Approval_Status__c && (oppty.Apttus_Approval__Approval_Status__c == 'Approved' || oppty.Apttus_Approval__Approval_Status__c == 'No Approval Needed')){

                for(AllocationSplit__c allSplit : allocationSplitList){
                    //system.debug('^^oppty.Owner.Country: '+ oppty.Owner.Country + ' ^oppty.Owner.TeamingChannel__c: '+oppty.Owner.TeamingChannel__c + ' ^oppty.SecondarySalesRep__r.Country: '+ oppty.SecondarySalesRep__r.Country + ' ^oppty.SecondarySalesRep__r.TeamingChannel__c: '+ oppty.SecondarySalesRep__r.TeamingChannel__c + ' ^oppty.TeamingType__c:'+ oppty.TeamingType__c);
                    if(allSplit.PrimarySalesRepCountry__c == oppty.Owner.Country && allSplit.PrimaryRepTeamingChannel__c == oppty.Owner.TeamingChannel__c && allSplit.SecondarySalesRepCountry__c == oppty.SecondarySalesRep__r.Country && allSplit.SecondaryRepTeamingChannel__c == oppty.SecondarySalesRep__r.TeamingChannel__c && allSplit.TeamingType__c == oppty.TeamingType__c){
                        //system.debug('^^^! ');
                        //if(allSplit.PrimaryAllocationBasis__c == 'Net' || allSplit.SecondaryAllocationBasis__c =='Net' ){
                        if(opportunityIdToListofOppTeamMembersMap.ContainsKey(oppty.Id)){
                            if (queryOpps.size() <= cutoff || oppty.Id == debugId){ //JFreese Appirio S-435483 4/10/17
                                system.debug('^^^!1 ' + allSplit.PrimaryRep__c);
                                system.debug('^^^!2 ' + allSplit.SecondaryRep__c);
                            }
                            for(OpportunityTeamMember__c oppTeamMember : opportunityIdToListofOppTeamMembersMap.get(oppty.Id)){

                                if(oppty.OwnerId == oppTeamMember.TeamMember__c){
                                    oppTeamMember.Split__c = allSplit.PrimaryRep__c;
                                    opportunityTeamMembersToUpdateList.add(oppTeamMember);
                                    OpportunityIDAndAllocationBasis.put(oppty.OwnerId, allSplit.PrimaryAllocationBasis__c);
                                }
                                if(oppty.SecondarySalesRep__c == oppTeamMember.TeamMember__c){
                                    oppTeamMember.Split__c = allSplit.SecondaryRep__c;
                                    opportunityTeamMembersToUpdateList.add(oppTeamMember);
                                    OpportunityIDAndAllocationBasis.put(oppty.SecondarySalesRep__c, allSplit.SecondaryAllocationBasis__c);
                                }
                            }
                        }
                    }
                }
            }
        }
        /*system.debug('^OpportunityIDAndAllocationBasis: '+ OpportunityIDAndAllocationBasis);
Map<Id,Id> OrderIdAndOpportunityMap = new Map<Id,Id>();
if(OpportunityIDAndAllocationBasis.size() > 0){
for(Order__c o: [SELECT Id, Opportunity__c FROM Order__c WHERE Opportunity__c IN: OpportunityIDAndAllocationBasis.keySet()]){
OrderIdAndOpportunityMap.put(o.Id,o.Opportunity__c);
}
}
system.debug('^OrderIdAndOpportunityMap: '+ OrderIdAndOpportunityMap);
if(OrderIdAndOpportunityMap.size() > 0){
for(OrderTeam__c ot : [SELECT Id, AllocationBasis__c, Order__c FROM OrderTeam__c WHERE Order__c IN: OrderIdAndOpportunityMap.keySet()]){
ot.AllocationBasis__c = OpportunityIDAndAllocationBasis.get(OrderIdAndOpportunityMap.get(ot.Order__c));
OrderTeamToUpdate.add(ot);
}
}
system.debug('^OrderTeamToUpdate: '+ OrderTeamToUpdate);
if(OrderTeamToUpdate.size() > 0 ){
try{
update OrderTeamToUpdate;
}catch(Exception e){
throw BaseApplicationException.NewException(METHODNAME, e.getMessage(), 'Failed to update Order Team.');
}
}*/

        system.debug(LoggingLevel.DEBUG, METHODNAME + '\n\nOPPORTUNITY TEAM MEMBERS LIST :: ' + opportunityTeamMembersToUpdateList + '\n\n');

        if(!opportunityTeamMembersToUpdateList.isEmpty()){
            UpdateOpportunityTeamMembers(opportunityTeamMembersToUpdateList);
        }
    }

    /*
** @author : Cloud Sherpas, Inc.
** @date : 03/26/2014
** @description : Creates a list of all Allocation Splits
** @paramaters : none
** @returns : List of Allocation Splits
*/
    private list<AllocationSplit__c> CreateAllocationSplitList(){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','CreateAllocationSplitList');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        list<AllocationSplit__c> allocationSplitList = [SELECT PrimaryRep__c, SecondaryRep__c, PrimaryAllocationBasis__c, SecondaryAllocationBasis__c, PrimarySalesRepCountry__c, PrimaryRepTeamingChannel__c, SecondarySalesRepCountry__c, SecondaryRepTeamingChannel__c, TeamingType__c FROM AllocationSplit__c];

        return allocationSplitList;
    }

    /*
** @author : Cloud Sherpas, Inc.
** @date : 03/26/2014
** @description : Creates Opportunity Id to Opportunity Team Member List Map
** @paramaters : Set of Opportunity Ids
** @returns : Map of Opportunity Ids to Opportunity Team Members List
*/
    private map<Id, list<OpportunityTeamMember__c>> CreateOpportunityIdToListofOpportunityTeamMembersMap(set<Id> pOpportunityIdSet){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','CreateOpportunityIdToListofOpportunityTeamMembersMap');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        map<Id, list<OpportunityTeamMember__c>> opportunityIdToListofOppTeamMembersMap = new map<Id, list<OpportunityTeamMember__c>>();

        for(Opportunity oppty : queryOpportunity()){
            opportunityIdToListofOppTeamMembersMap.put(oppty.Id, oppty.Opportunity_Team_Members__r);
        }

        return opportunityIdToListofOppTeamMembersMap;

    }

    /*
** @author : Cloud Sherpas, Inc.
** @date : 03/26/2014
** @description : Creates a list of all Allocation Splits
** @paramaters : none
** @returns : List of Allocation Splits
*/
    private void UpdateOpportunityTeamMembers(list<OpportunityTeamMember__c> pOpportunityTeamMemberList){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','UpdateOpportunityTeamMembers');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        system.debug('^pOpportunityTeamMemberList: '+pOpportunityTeamMemberList );
        try{
            Set<OpportunityTeamMember__c> otmc= new Set<OpportunityTeamMember__c>();
            otmc.addAll(pOpportunityTeamMemberList);
            List<OpportunityTeamMember__c> pOpportunityTeamMemberListToUpdate = new List<OpportunityTeamMember__c>(otmc);
            update pOpportunityTeamMemberListToUpdate;
            //update pOpportunityTeamMemberList;
        }catch(DMLException dmlex){
            throw BaseApplicationException.NewException(METHODNAME, dmlex.getMessage(), 'Update to Allocation Splits for Primary and Secondary Sales Rep failed');
        }
    }

    /*
** @author : Cloud Sherpas, Inc.
** @date : 03/28/2014
** @description : ...
** @paramaters : ...
** @returns : ...
*/
    public void SetRepMangersOnOpportunity(list<Opportunity> pOpportunityList, map<Id,Opportunity> pUpdatedOpportunityMap, map<Id,Opportunity> pOldOpportunityMap){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','SetRepMangersOnOpportunity');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        for(Opportunity oppty : pOpportunityList){

            if(pUpdatedOpportunityMap != NULL){
                if(pUpdatedOpportunityMap.containsKey(oppty.Id)){

                    if(pUpdatedOpportunityMap.get(oppty.Id).OwnerId != pOldOpportunityMap.get(oppty.Id).OwnerId){
                        SetPrimaryRepMangers(oppty, pOpportunityList.size());
                    }

                    if(pUpdatedOpportunityMap.get(oppty.Id).SecondarySalesRep__c != pOldOpportunityMap.get(oppty.Id).SecondarySalesRep__c){
                        SetSecondaryRepMangers(oppty, pOpportunityList.size());
                    }
                }
            }else{
                SetPrimaryRepMangers(oppty, pOpportunityList.size());

                if(!String.isBlank(oppty.SecondarySalesRep__c)){
                    SetSecondaryRepMangers(oppty, pOpportunityList.size());
                }
            }
        }
    }

    /*
** @author : Cloud Sherpas, Inc.
** @date : 03/28/2014
** @description : ...
** @paramaters : ...
** @returns : ...
*/
    private void SetPrimaryRepMangers(Opportunity pOpportunity, Integer oppSize){

        if (oppSize <= cutoff){ //JFreese Appirio S-435483 4/10/17
            final string METHODNAME = CLASSNAME.replace('METHODNAME','SetPrimaryRepMangers');
            system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        }

        if(UserIdToUserMap.containsKey(pOpportunity.OwnerId) && !String.isBlank(UserIdToUserMap.get(pOpportunity.OwnerId).ManagerId)){
            pOpportunity.PrimaryRepManager__c = UserIdToUserMap.get(pOpportunity.OwnerId).ManagerId;
        }else{
            pOpportunity.PrimaryRepManager__c = NULL;
        }

        if(UserIdToUserMap.containsKey(pOpportunity.PrimaryRepManager__c) && !String.isBlank(UserIdToUserMap.get(pOpportunity.PrimaryRepManager__c).ManagerId)){
            pOpportunity.PrimaryRep2ndManager__c = UserIdToUserMap.get(pOpportunity.PrimaryRepManager__c).ManagerId;
        }else{
            pOpportunity.PrimaryRep2ndManager__c = NULL;
        }

        if(UserIdToUserMap.containsKey(pOpportunity.PrimaryRep2ndManager__c) && !String.isBlank(UserIdToUserMap.get(pOpportunity.PrimaryRep2ndManager__c).ManagerId)){
            pOpportunity.PrimaryRep3rdManager__c = UserIdToUserMap.get(pOpportunity.PrimaryRep2ndManager__c).ManagerId;
        }else{
            pOpportunity.PrimaryRep3rdManager__c = NULL;
        }
    }

    /*
** @author : Cloud Sherpas, Inc.
** @date : 03/28/2014
** @description : ...
** @paramaters : ...
** @returns : ...
*/
    private void SetSecondaryRepMangers(Opportunity pOpportunity, Integer oppSize){

        if (oppSize <= cutoff){ //JFreese Appirio S-435483 4/10/17
            final string METHODNAME = CLASSNAME.replace('METHODNAME','SetSecondaryRepMangers');
            system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        }

        if(!String.isEmpty(pOpportunity.SecondarySalesRep__c)){

            if(UserIdToUserMap.containsKey(pOpportunity.SecondarySalesRep__c) && !String.isBlank(UserIdToUserMap.get(pOpportunity.SecondarySalesRep__c).ManagerId)){
                pOpportunity.SecondaryRepManager__c = UserIdToUserMap.get(pOpportunity.SecondarySalesRep__c).ManagerId;
            }else{
                pOpportunity.SecondaryRepManager__c = NULL;
            }

            if(UserIdToUserMap.containsKey(pOpportunity.SecondaryRepManager__c) && !String.isBlank(UserIdToUserMap.get(pOpportunity.SecondaryRepManager__c).ManagerId)){
                pOpportunity.SecondaryRep2ndManager__c = UserIdToUserMap.get(pOpportunity.SecondaryRepManager__c).ManagerId;
            }else{
                pOpportunity.SecondaryRep2ndManager__c = NULL;
            }

            if(UserIdToUserMap.containsKey(pOpportunity.SecondaryRep2ndManager__c) && !String.isBlank(UserIdToUserMap.get(pOpportunity.SecondaryRep2ndManager__c).ManagerId)){
                pOpportunity.SecondaryRep3rdManager__c = UserIdToUserMap.get(pOpportunity.SecondaryRep2ndManager__c).ManagerId;
            }else{
                pOpportunity.SecondaryRep3rdManager__c = NULL;
            }
        }
    }

    /*
** @author : Cloud Sherpas, Inc.
** @date : 03/28/2014
** @description : This will copy all the Account team member whic contains sales to the Opportunity team member of Opportunity creation.
** @paramaters : list of Opportunity
** @returns : none
*/
    public void copyAccountSalesTeamMemToOppSalesTeamMem(list<Opportunity> listOpportunities){
        list<Opportunity> pOpportunity = new list<opportunity>();
        Id opportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Opportunity').getRecordTypeId();
        for(Opportunity oOpportunity : listOpportunities){
            if(oOpportunity.RecordTypeId != opportunityRecordTypeId){
                pOpportunity.add(oOpportunity);
            }
        }
        if(pOpportunity != null && pOpportunity.size()>0){
            set<id> accountIdSet = CreateAccountIdSet(pOpportunity);
            map<id, AccountShare> userIdAccountShareMap = new map<id,AccountShare>();
            for(AccountShare ActShare : [Select id,OpportunityAccessLevel,RowCause,UserOrGroupId,AccountId FROM AccountShare WHERE AccountId IN: accountIdSet AND RowCause ='Sales Team']){
                userIdAccountShareMap.put(ActShare.UserOrGroupId,ActShare );
            }
            // set the Opportunity

            //Jeff L commented out for consolidation
            //map<Id, Account> accountIdToAccountMap = new map<Id, Account>([SELECT Id, (SELECT Id, UserId__c, TeamMemberRole__c ,AccountAccessLevel__c FROM Account_Team_Members__r WHERE TeamMemberRole__c like '%Sales%' ORDER BY CreatedDate ASC) FROM Account WHERE Id IN : accountIdSet]);
            Map<Id, Account> accountIdToAccountMap = new Map<Id, Account>();
            for(Account a : queryAccountList()){
                accountIdToAccountMap.put(a.Id, a);
            }
            system.debug('MAp'+accountIdToAccountMap);
            list<OpportunityTeamMember__c > opportunityTeamMembersToInsertList = new list<OpportunityTeamMember__c >();
            for(Opportunity oOpportunity : pOpportunity){

                if(accountIdToAccountMap.containskey(oOpportunity.AccountId)){
                    integer count = 0;
                    Boolean matchedSecondarySalesRep = false;
                    system.debug(accountIdToAccountMap.get(oOpportunity.AccountId).name+accountIdToAccountMap.get(oOpportunity.AccountId).Account_Team_Members__r);
                    for(Account_Team_Member__c oAccountTeamMember : accountIdToAccountMap.get(oOpportunity.AccountId).Account_Team_Members__r ){
                        OpportunityTeamMember__c oppTeamMember = new OpportunityTeamMember__c ();
                        oppTeamMember.TeamMember__c = oAccountTeamMember.UserId__c;

                        if(oOpportunity.OwnerId == oAccountTeamMember.UserId__c){
                            oppTeamMember.TeamRole__c = 'Primary Sales Rep';
                            oppTeamMember.Split__c = 100.0;
                            //oppTeamMember.TeamRole__c = 'Sales Rep';
                            count ++;
                        } else {
                            oppTeamMember.Split__c = 0.0;
                            oppTeamMember.TeamRole__c = 'Sales Rep';
                            count ++;
                        }

                        /*if(oOpportunity.OwnerId == oAccountTeamMember.UserId){
oppTeamMember.TeamRole__c = 'Primary Sales Rep';
}else{
if(count == 0){
oppTeamMember.TeamRole__c = 'Sales Rep';
}else{
oppTeamMember.TeamRole__c = 'Sales Rep';
}

count++;
}*/
                        oppTeamMember.Opportunity__c = oOpportunity.Id;
                        if(!userIdAccountShareMap.isEmpty()){
                            if(userIdAccountShareMap.containskey(oAccountTeamMember.UserId__c)){
                                if(userIdAccountShareMap.get(oAccountTeamMember.UserId__c).OpportunityAccessLevel != 'None'){
                                    if(userIdAccountShareMap.get(oAccountTeamMember.UserId__c).OpportunityAccessLevel == 'Read'){
                                        oppTeamMember.OpportunityAccess__c = 'Read Only';
                                    }else if(userIdAccountShareMap.get(oAccountTeamMember.UserId__c).OpportunityAccessLevel == 'Edit'){
                                        oppTeamMember.OpportunityAccess__c = 'Read/Write';

                                    }
                                }
                            }
                        }
                        opportunityTeamMembersToInsertList.add(oppTeamMember);
                    }
                    if(count > 0){
                        OpportunityTeamMember__c oppTeamMember = new OpportunityTeamMember__c ();
                        oppTeamMember.TeamMember__c = oOpportunity.OwnerId;
                        oppTeamMember.Split__c = 100.0;
                        oppTeamMember.TeamRole__c = 'Primary Sales Rep';
                        //oppTeamMember.TeamRole__c = 'Sales Rep';
                        oppTeamMember.Opportunity__c = oOpportunity.Id;
                        oppTeamMember.OpportunityAccess__c = 'Read/Write';
                        opportunityTeamMembersToInsertList.add(oppTeamMember);
                    }

                    //Jeff L added code to add the secondary Sales rep to the opportunity team
                    if(oOpportunity.SecondarySalesRep__c != null){
                        OpportunityTeamMember__c oppteamMember = new OpportunityTeamMember__c();
                        oppTeamMember.TeamMember__c = oOpportunity.SecondarySalesRep__c;
                        oppTeamMember.Split__c = 100.0;
                        oppTeamMember.TeamRole__c = 'Sales Rep';
                        oppTeamMember.Opportunity__c = oOpportunity.Id;
                        oppTeamMember.OpportunityAccess__c = 'Read/Write';
                        opportunityTeamMembersToInsertList.add(oppTeamMember);
                    }
                }

            }
            opportunityTeamMembersToInsertList = removeDuplicate(opportunityTeamMembersToInsertList);

            system.debug('\n\nTEST: Opp team members to be inserted:\n' + opportunityTeamMembersToInsertList + '\n\n');
            if(!opportunityTeamMembersToInsertList .isEmpty()){
                // Set System Generated = true So email would not sent
                for(OpportunityTeamMember__c oppTeamMember : opportunityTeamMembersToInsertList){
                    oppTeamMember.System_Generated__c = true;
                }
                insert opportunityTeamMembersToInsertList;
            }

        }

    }

    /*
** @author : Cloud Sherpas, Inc.
** @date : 03/28/2014
** @description : setCredit Status on Opportuntiy from Account
** @paramaters : list of Opportunity
** @returns : none
*/
    public void setCreditStatus(list<Opportunity> pOpportunity){
        map<id,String> AccountIdCreditStatusMap = new map<id,String>();

        // create an Account Id set
        set<Id> accountIdSet = CreateAccountIdSet(pOpportunity);

        //validate Opportunity Creation
        //Opportunity can only be create against Account where credit status == OK or status == Approved Prepay
        //Jeff L commented out to consolidate queries 10/13
        //for(Account act: [SELECT id, CreditStatus__c FROM Account WHERE id IN: accountIdSet ]){
        for(Account act : queryAccountList()){
            if(accountIdSet.contains(act.Id)){
                AccountIdCreditStatusMap.put(act.id,act.CreditStatus__c);
            }
        }

        for(Opportunity opp: pOpportunity ){
            if(!AccountIdCreditStatusMap.isEmpty()){
                if(AccountIdCreditStatusMap.containskey(opp.Accountid)){
                    opp.CreditStatus__c = AccountIdCreditStatusMap.get(opp.Accountid);
                }
            }
        }

    }

    /*
** @author : Cloud Sherpas, Inc.
** @date : 03/28/2014
** @description : Create Opportunity Competitors from Competitive Landscapes related to Account
** @paramaters : list of Opportunity
** @returns : none
*/
    public void CreateOpportunityCompetitorsFromCompetitiveLandscapesRelatedToAccounts(list<Opportunity> pOpportunityList){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','CreateOpportunityCompetitorsFromCompetitiveLandscapesRelatedToAccounts');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        set<id> accountIdSet = this.CreateAccountIdSet(pOpportunityList);

        //Jeff L Commented out for query optimization
        //map<Id,Account> accountIdToAccountMap = new map<Id,Account>([SELECT Id, (SELECT AccountCountry__c, CurrencyIsoCode, Id, Competitor__c FROM Competitive_Landscapes__r WHERE Competitor__c != NULL) FROM Account WHERE Id IN : accountIdSet]);
        map<Id,Account> accountIdToAccountMap = new map<Id,Account>();
        for(Account a : queryAccountList()){
            accountIDToAccountMap.put(a.Id,a);
        }

        list<OpportunityCompetitor__c> opptyCompetitorToBeInsertedList = new list<OpportunityCompetitor__c>();

        for(Opportunity oppty : pOpportunityList){

            if(accountIdToAccountMap.containsKey(oppty.AccountId)){
                if(!accountIdToAccountMap.get(oppty.AccountId).Competitive_Landscapes__r.isEmpty()){
                    for(CompetitiveLandscape__c compLandScape : accountIdToAccountMap.get(oppty.AccountId).Competitive_Landscapes__r){
                        OpportunityCompetitor__c opptyCompetitor = new OpportunityCompetitor__c();
                        opptyCompetitor.Opportunity__c = oppty.Id;
                        //opptyCompetitor.Name = compLandScape.Competitor__c;
                        opptyCompetitor.Competitor__c = compLandScape.Competitor__c;
                        opptyCompetitor.Account_Country__c = compLandScape.AccountCountry__c;
                        opptyCompetitor.CurrencyIsoCode = compLandScape.CurrencyIsoCode;

                        opptyCompetitorToBeInsertedList.add(opptyCompetitor);
                    }
                }
            }
        }
        system.debug(LoggingLevel.DEBUG, METHODNAME + '\n\nLIST OF OPPORTUNITY COMPETITORS TO BE INSERTED :: ' + opptyCompetitorToBeInsertedList + '\n\n');
        insert opptyCompetitorToBeInsertedList;
    }

    /*
** @author : Cloud Sherpas, Inc.
** @date : 03/11/2014
** @description : ...q
** @paramaters : Opportunity Id Set, Primary Team Member Type to List of Opportunities Map
** @returns : nothing

public void UpdatePrimaryOpportunityTeamMembers(set<Id> pOpportunityIdSet ,map<String, list<Opportunity>> pPrimaryTeamMemberTypeToListOfOpportunityMap){

final string METHODNAME = CLASSNAME.replace('METHODNAME','UpdatePrimaryOpportunityTeamMembers');
system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

Boolean hasPrimarySalesRep;
Boolean hasSecondarySalesRep;

// create list for insert
list<OpportunityTeamMember> opportunityTeamMemberToInsertList = new list<OpportunityTeamMember>();
map<string,OpportunityTeamMember__c> customOpportunityTeamMembersToInsertList = new map<string,OpportunityTeamMember__c>();

// create list for update
list<OpportunityTeamMember> OpportunityTeamMembersToUpdateList = new list<OpportunityTeamMember>();
list<OpportunityTeamMember__c> customOpportunityTeamMembersToUpdateList = new list<OpportunityTeamMember__c>();
list<OpportunityTeamMember> OpportunityTeamMembersToUpdateListUpdated = new list<OpportunityTeamMember>();
list<OpportunityTeamMember__c> customOpportunityTeamMembersToUpdateListUpdated = new list<OpportunityTeamMember__c>();

// create User Id to Custom Opportunity Team Member map for setting Opportunity Sharing rules
map<Id,OpportunityTeamMember__c> userIdToCustomOpportunityTeamMemberMap = new map<Id,OpportunityTeamMember__c>();

// create and populate a list of Opportunities related to Opportunity Team Members
list<Opportunity> OpportunityList = [SELECT Id, SecondarySalesRep__c, (SELECT Id, OpportunityId, UserId, TeamMemberRole FROM OpportunityTeamMembers) FROM Opportunity WHERE Id IN : pOpportunityIdSet];

// create and populate a list of Custom Opportunity Team Members related to the Opportunities related to Opportunity Team Members
list<OpportunityTeamMember__c> customOpportunityTeamMemberList = [SELECT Id, Opportunity__c, TeamMember__c,OpportunityAccess__c FROM OpportunityTeamMember__c WHERE Opportunity__c IN : pOpportunityIdSet];

// create an Opportunity Id to a map of User Id to Custom Opportunity Team Member map
map<Id, map<Id, OpportunityTeamMember__c>> OpportunityIdToMapOfUserIdToCustomOportunityTeamMemberMap = new  map<Id, map<Id, OpportunityTeamMember__c>>();

// load the Opportunity Id to a map of User Id to Custom Opportunity Team Member map
for(OpportunityTeamMember__c oCustomOpportunityTeamMember : customOpportunityTeamMemberList){
if(OpportunityIdToMapOfUserIdToCustomOportunityTeamMemberMap.ContainsKey(oCustomOpportunityTeamMember.Opportunity__c)){
OpportunityIdToMapOfUserIdToCustomOportunityTeamMemberMap.get(oCustomOpportunityTeamMember.Opportunity__c).put(oCustomOpportunityTeamMember.TeamMember__c, oCustomOpportunityTeamMember);
}else{
OpportunityIdToMapOfUserIdToCustomOportunityTeamMemberMap.put(oCustomOpportunityTeamMember.Opportunity__c, new map<Id, OpportunityTeamMember__c>());
OpportunityIdToMapOfUserIdToCustomOportunityTeamMemberMap.get(oCustomOpportunityTeamMember.Opportunity__c).put(oCustomOpportunityTeamMember.TeamMember__c, oCustomOpportunityTeamMember);
}
}

for(Opportunity oOpportunity : OpportunityList){
if(pPrimaryTeamMemberTypeToListOfOpportunityMap.get('PrimarySalesRep') != NULL){
for(Opportunity oOpportunityPrimarySalesRep : pPrimaryTeamMemberTypeToListOfOpportunityMap.get('PrimarySalesRep')){

hasPrimarySalesRep = false;

for(OpportunityTeamMember oOpportunityTeamMember : oOpportunity.OpportunityTeamMembers){

// Remove the current Primary Sales Rep by setting Team Member Role to Sales Rep
if(oOpportunityTeamMember.OpportunityId == oOpportunityPrimarySalesRep.Id && oOpportunityTeamMember.TeamMemberRole == 'Sales Rep'){
oOpportunityTeamMember.TeamMemberRole = 'Sales Rep';
OpportunityTeamMembersToUpdateList.add(oOpportunityTeamMember);

// Remove the current Primary Sales Rep by setting Custom Team Member Role to Sales Rep
if(OpportunityIdToMapOfUserIdToCustomOportunityTeamMemberMap.containskey(oOpportunityTeamMember.OpportunityId)){
if(OpportunityIdToMapOfUserIdToCustomOportunityTeamMemberMap.get(oOpportunityTeamMember.OpportunityId).containskey(oOpportunityTeamMember.UserId)){
OpportunityIdToMapOfUserIdToCustomOportunityTeamMemberMap.get(oOpportunityTeamMember.OpportunityId).get(oOpportunityTeamMember.UserId).TeamRole__c = 'Sales Rep';
customOpportunityTeamMembersToUpdateList.add(OpportunityIdToMapOfUserIdToCustomOportunityTeamMemberMap.get(oOpportunityTeamMember.OpportunityId).get(oOpportunityTeamMember.UserId));
}
}
}

// User is already an Opportunity Team Member - Update from current role to Primary Sales Rep
if(oOpportunityTeamMember.OpportunityId == oOpportunityPrimarySalesRep.Id && oOpportunityTeamMember.UserId == oOpportunityPrimarySalesRep.OwnerId){
oOpportunityTeamMember.TeamMemberRole = 'Sales Rep';
OpportunityTeamMembersToUpdateList.add(oOpportunityTeamMember);
hasPrimarySalesRep = true;

if(OpportunityIdToMapOfUserIdToCustomOportunityTeamMemberMap.containskey(oOpportunityTeamMember.OpportunityId)){
if(OpportunityIdToMapOfUserIdToCustomOportunityTeamMemberMap.get(oOpportunityTeamMember.OpportunityId).containskey(oOpportunityTeamMember.UserId)){
OpportunityIdToMapOfUserIdToCustomOportunityTeamMemberMap.get(oOpportunityTeamMember.OpportunityId).get(oOpportunityTeamMember.UserId).TeamRole__c = 'Sales Rep';
customOpportunityTeamMembersToUpdateList.add(OpportunityIdToMapOfUserIdToCustomOportunityTeamMemberMap.get(oOpportunityTeamMember.OpportunityId).get(oOpportunityTeamMember.UserId));
}
}
}
}

if(!hasPrimarySalesRep){

OpportunityTeamMember primarySalesRepMember = new OpportunityTeamMember();
primarySalesRepMember.OpportunityId = oOpportunityPrimarySalesRep.Id;
primarySalesRepMember.UserId = oOpportunityPrimarySalesRep.OwnerId;
primarySalesRepMember.TeamMemberRole = 'Sales Rep';

opportunityTeamMemberToInsertList.add(primarySalesRepMember);

OpportunityTeamMember__c customPrimarySalesRepMember = new OpportunityTeamMember__c();
customPrimarySalesRepMember.Opportunity__c =  oOpportunityPrimarySalesRep.Id;
customPrimarySalesRepMember.TeamMember__c =  oOpportunityPrimarySalesRep.OwnerId;
customPrimarySalesRepMember.TeamRole__c = 'Sales Rep';
customPrimarySalesRepMember.OpportunityAccess__c = 'Read/Write';
String otmKey = (string)oOpportunityPrimarySalesRep.Id + (string)oOpportunityPrimarySalesRep.OwnerId;
customOpportunityTeamMembersToInsertList.put(otmKey, customPrimarySalesRepMember);
userIdToCustomOpportunityTeamMemberMap.put(oOpportunityPrimarySalesRep.OwnerId, customPrimarySalesRepMember);

}
}
}

if(pPrimaryTeamMemberTypeToListOfOpportunityMap.get('SecondarySalesRep') != NULL){

for(Opportunity oOpportunitySecondarySalesRep : pPrimaryTeamMemberTypeToListOfOpportunityMap.get('SecondarySalesRep')){

hasSecondarySalesRep = false;

for(OpportunityTeamMember oOpportunityTeamMember : oOpportunity.OpportunityTeamMembers){

//Remove the current Secondary Sales Rep by setting Team Member Role to Sales Rep
if(oOpportunityTeamMember.OpportunityId == oOpportunitySecondarySalesRep.Id && oOpportunityTeamMember.TeamMemberRole == 'Sales Rep'){
oOpportunityTeamMember.TeamMemberRole = 'Sales Rep';
OpportunityTeamMembersToUpdateList.add(oOpportunityTeamMember);

if(OpportunityIdToMapOfUserIdToCustomOportunityTeamMemberMap.containskey(oOpportunityTeamMember.OpportunityId)){
if(OpportunityIdToMapOfUserIdToCustomOportunityTeamMemberMap.get(oOpportunityTeamMember.OpportunityId).containskey(oOpportunityTeamMember.UserId)){
OpportunityIdToMapOfUserIdToCustomOportunityTeamMemberMap.get(oOpportunityTeamMember.OpportunityId).get(oOpportunityTeamMember.UserId).TeamRole__c = 'Sales Rep';
customOpportunityTeamMembersToUpdateList.add(OpportunityIdToMapOfUserIdToCustomOportunityTeamMemberMap.get(oOpportunityTeamMember.OpportunityId).get(oOpportunityTeamMember.UserId));
}
}
}

// User is already an Opportunity Team Member - Update from current role to Secondary Sales Rep
if(oOpportunityTeamMember.OpportunityId == oOpportunitySecondarySalesRep.Id && oOpportunityTeamMember.UserId == oOpportunitySecondarySalesRep.SecondarySalesRep__c){
oOpportunityTeamMember.TeamMemberRole = 'Sales Rep';
OpportunityTeamMembersToUpdateList.add(oOpportunityTeamMember);
hasSecondarySalesRep = true;

if(OpportunityIdToMapOfUserIdToCustomOportunityTeamMemberMap.containskey(oOpportunityTeamMember.OpportunityId)){
if(OpportunityIdToMapOfUserIdToCustomOportunityTeamMemberMap.get(oOpportunityTeamMember.OpportunityId).containskey(oOpportunityTeamMember.UserId)){
OpportunityIdToMapOfUserIdToCustomOportunityTeamMemberMap.get(oOpportunityTeamMember.OpportunityId).get(oOpportunityTeamMember.UserId).TeamRole__c = 'Sales Rep';
customOpportunityTeamMembersToUpdateList.add(OpportunityIdToMapOfUserIdToCustomOportunityTeamMemberMap.get(oOpportunityTeamMember.OpportunityId).get(oOpportunityTeamMember.UserId));
}
}
}
}

if(!hasSecondarySalesRep){
OpportunityTeamMember SecondarySalesRepMember = new OpportunityTeamMember();
SecondarySalesRepMember.OpportunityId = oOpportunity.id;
SecondarySalesRepMember.UserId = oOpportunity.SecondarySalesRep__c;
SecondarySalesRepMember.TeamMemberRole = 'Sales Rep';

opportunityTeamMemberToInsertList.add(SecondarySalesRepMember);

OpportunityTeamMember__c customSecondarySalesRepMember = new OpportunityTeamMember__c();
customSecondarySalesRepMember.Opportunity__c = oOpportunity.id;
customSecondarySalesRepMember.TeamMember__c = oOpportunity.SecondarySalesRep__c;
customSecondarySalesRepMember.TeamRole__c = 'Sales Rep';
customSecondarySalesRepMember.OpportunityAccess__c= 'Read/Write';
String otmKey = (string)oOpportunity.id  + (string)oOpportunity.SecondarySalesRep__c;
customOpportunityTeamMembersToInsertList.put( otmKey, customSecondarySalesRepMember);
userIdToCustomOpportunityTeamMemberMap.put(oOpportunity.SecondarySalesRep__c,customSecondarySalesRepMember);
}
}
}
}

// Update Opportunity Team Members and Custom Opportunity Team Members
if(!OpportunityTeamMembersToUpdateList.isEmpty()){
UpdateOpportunityTeamMembers(OpportunityTeamMembersToUpdateList);
UpdateCustomOpportunityTeamMembers(customOpportunityTeamMembersToUpdateList);

}

// Insert new Custom Opportunity Team Members
if(!customOpportunityTeamMembersToInsertList.isEmpty()){

// remove any list items from that contain null User Ids for Opportunity Team Members to be inserted
list<OpportunityTeamMember__c> validatedCustomOpportunityTeamMemberToInsertList = CreateValidateCustomOpportunityTeamMemberList(customOpportunityTeamMembersToInsertList.values());

// insert list of Custom Opportunity Team Members
if(!validatedCustomOpportunityTeamMemberToInsertList.isEmpty()){
InsertCustomOpportunityTeamMembers(validatedCustomOpportunityTeamMemberToInsertList);
}
}

// create new Opportunity Share for newly createded Opportunity Team Members
if(!opportunityTeamMemberToInsertList.isEmpty()){
CreateNewOpportunityShare(CreateNewOpportunityTeamMember(opportunityTeamMemberToInsertList, userIdToCustomOpportunityTeamMemberMap));
}
}
*/
    /*
** @author : Cloud Sherpas, Inc.
** @date : 03/11/2014
** @description : Updates list of Account Team Members
** @paramaters : Opportunity Team Member list
** @returns : Nothing
*/
    //Commented because it is not called from anywhere
    /*
    private void UpdateOpportunityTeamMembers(list<OpportunityTeamMember> pOpportunityTeamMemberToUpdateList){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','UpdateOpportunityTeamMembers');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        try{
            //update pOpportunityTeamMemberToUpdateList;
        }catch(DMLException dmlex){
            throw BaseApplicationException.NewException(METHODNAME, dmlex.getMessage(), 'Update to Opportunity Team Members Failed');
        }
    }
   */
    /*
** @author : Cloud Sherpas, Inc.
** @date : 03/11/2014
** @description : Updates list of Custom Opportunity Team Members
** @paramaters : Custom Opportunity Team Member list
** @returns : Nothing

private void UpdateCustomOpportunityTeamMembers(list<OpportunityTeamMember__c> pCustomOpportunityTeamMembersToUpdateList){

final string METHODNAME = CLASSNAME.replace('METHODNAME','UpdateCustomAccountTeamMembers');
system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

try{
//update pCustomOpportunityTeamMembersToUpdateList;
}catch(DMLException dmlex){
throw BaseApplicationException.NewException(METHODNAME, dmlex.getMessage(), 'Update to Custom Opportunity Team Members Failed');
}
}
*/
    /*
** @author : Cloud Sherpas, Inc.
** @date : 03/11/2014
** @description : Validates list by removing any list items that contains null User Ids for Custom Opportunity Team Members
** @paramaters : Custom Opportunity Team Member list
** @returns : Custom Opportunity Team Member list

private list<OpportunityTeamMember__c> CreateValidateCustomOpportunityTeamMemberList(list<OpportunityTeamMember__c> pCustomOpportunityTeamMemberList){

final string METHODNAME = CLASSNAME.replace('METHODNAME','CreateValidateCustomOpportunityTeamMemberList');
system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

list<OpportunityTeamMember__c > validatedCustomOpportunityTeamMemberList = new list<OpportunityTeamMember__c>();

for(OpportunityTeamMember__c oCustomOpportunityTeamMember : pCustomOpportunityTeamMemberList){
if(!String.isBlank(oCustomOpportunityTeamMember.TeamMember__c)){
validatedCustomOpportunityTeamMemberList.add(oCustomOpportunityTeamMember);
}
}

return validatedCustomOpportunityTeamMemberList;
}
*/
    /*
** @author : Cloud Sherpas, Inc.
** @date : 03/11/2014
** @description : Validates list by removing any list items that contains null User Ids for Custom Opportunity Team Members
** @paramaters : Custom Opportunity Team Member list
** @returns : Custom Opportunity Team Member list

private void InsertCustomOpportunityTeamMembers(list<OpportunityTeamMember__c> pValidatedCustomOpportunityTeamMemberToInsertList){

final string METHODNAME = CLASSNAME.replace('METHODNAME','InsertCustomOpportunityTeamMembers');
system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

try{
Set<OpportunityTeamMember__c> otmToBeInsertSet = new Set<OpportunityTeamMember__c>();
otmToBeInsertSet.addAll(pValidatedCustomOpportunityTeamMemberToInsertList);
List<OpportunityTeamMember__c> otmToBeInsert = new List<OpportunityTeamMember__c>(otmToBeInsertSet);
if(!otmToBeInsert.isEmpty()){
insert otmToBeInsert;
}
//insert pValidatedCustomOpportunityTeamMemberToInsertList;
}catch(DMLException dmlex){
throw BaseApplicationException.NewException(METHODNAME, dmlex.getMessage(), 'Update to Custom Opportunity Team Members Failed');
}
}
*/

    /*
** @author : Cloud Sherpas, Inc.
** @date : 03/11/2014
** @description : ...
** @paramaters : OpportunitySharelist
** @returns : nothing

private void CreateNewOpportunityShare(list<OpportunityShare> pAOpportunityShareToInsertList){

final string METHODNAME = CLASSNAME.replace('METHODNAME','CreateNewOpportunityShare');
system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

Database.SaveResult[] sharingRuleSaveResult = Database.insert(pAOpportunityShareToInsertList,false);

//insert the new shares
Integer newShareCnt = 0;

for(Database.SaveResult saveResult: sharingRuleSaveResult){
if(!saveResult.isSuccess()){
Database.Error saveResultErrorMessage = saveResult.getErrors()[0];
system.debug(LoggingLevel.DEBUG, METHODNAME + '\n\nERROR ADDING SHARING:'+ pAOpportunityShareToInsertList[newShareCnt]+'::'+ saveResultErrorMessage);
}
newShareCnt++;
}
}
*/
    /*
** @author : Cloud Sherpas, Inc.
** @date : 03/11/2014
** @description : ...
** @paramaters : Opportunity Team Member list
** @returns : Opportunity Share list

private list<OpportunityShare> CreateNewOpportunityTeamMember(list<OpportunityTeamMember> pTeamMemberToInsertList, map<Id,OpportunityTeamMember__c> pUserIdToCustomOpportunityTeamMemberMap){

final string METHODNAME = CLASSNAME.replace('METHODNAME','CreateNewOpportunityTeamMember');
system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

Set<OpportunityTeamMember> otm = new Set<OpportunityTeamMember>();
otm.addAll(pTeamMemberToInsertList);
List<OpportunityTeamMember> pOpportunityTeamMemberToInsertList = new List<OpportunityTeamMember>(otm);

list<OpportunityShare> OpportunityShareToInsertList = new list<OpportunityShare>();

Database.SaveResult[] teamMemberSaveResults = Database.insert(pOpportunityTeamMemberToInsertList,false);

//insert any valid members then add their share entry if they were successfully added
Integer newMemberCnt=0;

for(Database.SaveResult saveResult : teamMemberSaveResults){
if(!saveResult.isSuccess()){
Database.Error saveResultErrorMessage =saveResult.getErrors()[0];
system.debug(LoggingLevel.DEBUG, METHODNAME + '\n\nERROR ADDING TEAM MEMBER:'+ saveResultErrorMessage);
}else{
if(pUserIdToCustomOpportunityTeamMemberMap != NULL){
if(!pUserIdToCustomOpportunityTeamMemberMap.IsEmpty()){
if(pUserIdToCustomOpportunityTeamMemberMap.containsKey(pOpportunityTeamMemberToInsertList[newMemberCnt].UserId)){
OpportunityShareToInsertList.add(new OpportunityShare(UserOrGroupId=pOpportunityTeamMemberToInsertList[newMemberCnt].UserId,
OpportunityId=pOpportunityTeamMemberToInsertList[newMemberCnt].OpportunityId,
OpportunityAccessLevel=pUserIdToCustomOpportunityTeamMemberMap.get(pOpportunityTeamMemberToInsertList[newMemberCnt].UserId).OpportunityAccess__c));
}
}else{
OpportunityShareToInsertList.add(new OpportunityShare(UserOrGroupId=pOpportunityTeamMemberToInsertList[newMemberCnt].UserId, OpportunityId=pOpportunityTeamMemberToInsertList[newMemberCnt].OpportunityId, OpportunityAccessLevel='Read/Write'));
}
}else{
OpportunityShareToInsertList.add(new OpportunityShare(UserOrGroupId=pOpportunityTeamMemberToInsertList[newMemberCnt].UserId, OpportunityId=pOpportunityTeamMemberToInsertList[newMemberCnt].OpportunityId, OpportunityAccessLevel='Read/Write'));
}
}
newMemberCnt++;
}

return OpportunityShareToInsertList;
}
*/
    /*
** @author : Cloud Sherpas, Inc.
** @date : 04/11/2014
** @description : Set Opportunity Key Initiative to Account Key Initiative
** @paramaters : Opportunity Team Member list
** @returns : nothing
*/
    public void SetOpportunityKeyInitiativeToAccountKeyInitiative(list<Opportunity> pOpportunityList){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','SetOpportunityKeyInitiativeToAccountKeyInitiative');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        map<Id, Account> accountIdToAccountMap = CreateAccountIdToAccountMap(CreateAccountIdSet(pOpportunityList));

        for(Opportunity oppty : pOpportunityList){

            if(accountIdToAccountMap.containsKey(oppty.AccountId)){
                if(oppty.KeyInitiative__c == null || oppty.KeyInitiative__c == ''){
                    oppty.KeyInitiative__c = accountIdToAccountMap.get(oppty.AccountId).KeyInitiative__c;

                }
            }
        }
    }
    /*
** @author : Appirio (Jeff L)
** @date : 11/09/15
** @description : Generate a new OM Processing Case when the opportunity is switched to IsValidationRequest (called from the ready for validation button)
** @returns : nothing
*/
    public void generateOMProccessingCase (Opportunity[] pOpportunityList, Map<Id,Opportunity> pOldOpportunityMap){
        final String CLASSNAME = '\n\n**** OpportunityTriggerHelper.METHODNAME()';
        final string METHODNAME = CLASSNAME.replace('METHODNAME','generateOMProccessingCase');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        set<Id> setOppIDs = new set<Id>();
        List<Opportunity> oppsWithCasesToCreate = new List<Opportunity>();
        //try{

            //Fetching the assignment rules on case
            /*AssignmentRule AR = new AssignmentRule();
AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];

//Creating the DMLOptions for "Assign using active assignment rules" checkbox
Database.DMLOptions dmlOpts = new Database.DMLOptions();
if(AR!=NULL) {
dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
}
system.debug('\n\n\n\n\n**dmlOpts: '+ dmlOpts +'\n\n\n\n');
*/
            for(Opportunity opp: pOpportunityList){
                if(opp.IsValidationRequest__c == true && pOldOpportunityMap.get(opp.Id).IsValidationRequest__c == false) {
                    system.debug('!!!Opp QuoteId ' + opp.Id);
                    setOppIDs.add(opp.Id);
                    oppsWithCasesToCreate.add(opp);
                }
            }

            map<Id, Apttus_Proposal__Proposal__c> mapQuote = new map<Id, Apttus_Proposal__Proposal__c>();
            system.debug(LoggingLevel.WARN, '<<++>>' + [Select ID,Primay_Quote_Total_Match__c,Region_Group_based_on_OSD__c,Order_Type__c,ParentOrder__c,Selling_Country__c,Apttus_Proposal__Opportunity__c, CurrencyIsoCode, recordType.Name from Apttus_Proposal__Proposal__c Where Apttus_Proposal__Opportunity__c IN :setOppIDs AND Apttus_Proposal__Primary__c = True]);
            system.debug(LoggingLevel.WARN, '<<++>>' + setOppIDs);
            for(Apttus_Proposal__Proposal__c prop : [Select ID,Primay_Quote_Total_Match__c,Region_Group_based_on_OSD__c,Order_Type__c,ParentOrder__c,Selling_Country__c,Apttus_Proposal__Opportunity__c, CurrencyIsoCode, recordType.Name from Apttus_Proposal__Proposal__c Where Apttus_Proposal__Opportunity__c IN :setOppIDs AND Apttus_Proposal__Primary__c = True]){
                mapQuote.put(prop.Apttus_Proposal__Opportunity__c,prop);
            }
            
            system.debug(LoggingLevel.WARN, '<<++>>' + mapQuote);
            
            map<String, map<String, Id>> result = Utility.GetRecordTypeIdsBySObjectNameSet(new set<String>{'Case'});
            String recordId = result.get('Case').get('OM Processing Request');
            system.debug('\n\n\n\n\n**recordId: '+ recordId +'\n\n\n\n');
            List<Case> CasesToInsert = new List<Case>();
            for(Opportunity opp: oppsWithCasesToCreate){
                Case c = new Case();
                //opp.IsValidationRequest__c = false;
                c.Subject = 'Validation Request for Opportunity: '+ opp.Name;
                c.Description = 'Please validate the Contract attached to the opportunity with the Primary Quote.';
                c.RecordTypeId = recordId;
                c.AccountId = opp.AccountId;
                c.Opportunity__c = opp.Id;
                c.Order_Type__c = mapQuote.get(opp.Id).Order_Type__c;
                c.Group__c = mapQuote.get(opp.Id).Region_Group_based_on_OSD__c;
                c.Quote_SellingCountry__c = mapQuote.get(opp.Id).Selling_Country__c;
                c.Order__c = mapQuote.get(opp.Id).ParentOrder__c;
                c.Quote_Total__c = mapQuote.get(opp.Id).Primay_Quote_Total_Match__c;
                c.CurrencyIsoCode = mapQuote.get(opp.Id).CurrencyIsoCode;
                c.SystemGenerated__c = True;
                system.debug('====opp.Id =='+opp.Id +'==== mapQuote.get(opp.Id)=='+ mapQuote.get(opp.Id));
                if(mapQuote != null && mapQuote.containskey(opp.Id)) {
                    c.Quote_SellingCountry__c = mapQuote.get(opp.Id).Selling_Country__c;
                    c.Proposal_ID__c = mapQuote.get(opp.Id).ID;
                    if(mapQuote.get(opp.Id).RecordType.Name.contains('Rebill')){
                        c.Subject += ' Rebill';
                    }
                }
                //c.setOptions(dmlOpts);
                CasesToInsert.add(c);
            }
            if(!CasesToInsert.isEmpty()){
                CaseTriggerHandler.ExecuteTriggers = false;
                insert CasesToInsert;
                CaseTriggerHandler.ExecuteTriggers = true;
            }
        /*}catch(Exception dmlex){
            ExceptionLog.add(dmlex.getTypeName(), 'OpportunityTriggerHelper', 'generateOMProccessingCase', dmlex.getMessage());
            throw BaseApplicationException.NewException('OpportunityTriggerHelper.generateOMProccessingCase()', dmlex.getMessage());
        }*/
    }


    // It will remove duplicate opp team members based on member Id
    public list<OpportunityTeamMember__c> removeDuplicate(list<OpportunityTeamMember__c > lstOppTeamMember) {
        list<OpportunityTeamMember__c > resultList = new list<OpportunityTeamMember__c >();
        map<Id,set<Id>> oppToTeamMember = new map<Id,set<Id>>();
        for(OpportunityTeamMember__c member : lstOppTeamMember){
            if(!oppToTeamMember.containsKey(member.Opportunity__c)){
                oppToTeamMember.put(member.Opportunity__c, new set<Id>());
                oppToTeamMember.get(member.Opportunity__c).add(member.TeamMember__c);
                resultList.add(member);
            }
            else {
                if(oppToTeamMember.containsKey(member.Opportunity__c)){
                    set<Id> setTeamMember =  oppToTeamMember.get(member.Opportunity__c);
                    if(setTeamMember != null && !setTeamMember.contains(member.TeamMember__c)){
                        oppToTeamMember.get(member.Opportunity__c).add(member.TeamMember__c);
                        resultList.add(member);
                    }
                }

            }
        }

        return resultList;
    }

    /*
** @author : Apttus
** @date : 08/06/2014
** @description : User Story S-323572 - Approval Process should be rejected(Cancelled) if Primary/Secondary SalesRep is added/changed
** or estimated value field is updated in the opportunity
** @paramaters : list of Opportunity
** @returns : none
*/
    public void CancelApprovalProcess(Map<Id, Opportunity> pNewOpportunityMap, Map<Id, Opportunity> pOldOpportunityMap){
        Set<Id> oppIds = new Set<Id>();

        map<string,string> reasonForRejections = new map<string,string>();
        for(Id oppId:pNewOpportunityMap.keySet())
        {
            Opportunity newOpp = pNewOpportunityMap.get(oppId);
            Opportunity oldOpp = pOldOpportunityMap.get(oppId);
            string reasons;
            if(newOpp.OwnerId != oldOpp.OwnerId || newOpp.SecondarySalesRep__c != oldOpp.SecondarySalesRep__c || (oldOpp.SecondarySalesRep__c != null  && newOpp.SecondarySalesRep__c== null))
            {
                reasons = 'Approval is rejected due to the opportunity team change.';
            }

            if(oldOpp.Amount >= 2500 && newOpp.Amount < 2500)
            {
                reasons = 'Approval is rejected due to the minimum threshold not being met.';
            }
            if(string.isNotBlank(reasons))
            {
                reasonForRejections.put(oppId, reasons);
            }
        }
        //system.debug('reasonForRejections-->' + reasonForRejections);

        try{
            if(reasonForRejections.size() > 0)
            {
                List<Apttus_Approval__Approval_Request__c> relatedApprovalRequests = [Select Id,Apttus_Approval__Related_Opportunity__c,Apttus_Approval__Approval_Status__c from Apttus_Approval__Approval_Request__c
                                                                                      Where Apttus_Approval__Related_Opportunity__c IN: pNewOpportunityMap.keySet()
                                                                                      AND Apttus_Approval__Approval_Status__c != 'Approved' AND Apttus_Approval__Approval_Status__c != 'Rejected'
                                                                                      AND Apttus_Approval__Approval_Status__c != 'Cancelled' AND Apttus_Approval__Approval_Status__c != 'Not Submitted'];
                Set<Id> oppsWhichNeedsToBeCancelled = new Set<Id>();

                if(relatedApprovalRequests.size() > 0)
                {

                    for(Apttus_Approval__Approval_Request__c appRequests:relatedApprovalRequests)
                    {
                        if(reasonForRejections.containsKey(appRequests.Apttus_Approval__Related_Opportunity__c))
                        {
                            oppsWhichNeedsToBeCancelled.add(appRequests.Apttus_Approval__Related_Opportunity__c);
                        }
                    }

                    //system.debug('oppsWhichNeedsToBeCancelled-->' + oppsWhichNeedsToBeCancelled);
                    for(Id oppId:oppsWhichNeedsToBeCancelled)
                    {
                        pNewOpportunityMap.get(oppId).Apttus_Approval__Approval_Status__c='Rejected';
                    }
                    //Approval Rejection and Email process will be done asynchronously.
                    //Appirio J Freese 6/14/16 I-221832 Fix for "Too many queueable jobs added to the queue: 2"
                    if (Personal_Settings__c.getInstance().Send_Emails__c == true){
                        System.enqueueJob(new APTS_QueueOppAprrovalRejectEmail(oppsWhichNeedsToBeCancelled,reasonForRejections));
                    }
                }
            }
        }catch(Exception e){
            throw BaseApplicationException.NewExceptionWithInnerException('CancelApprovalProcess',
                                                                          e.getMessage()+'\nStack Trace: '+e.getStackTraceString(), 'Failed to Reject the Approval Process.', e);
        }
    }

    /* Method created by Appirio, updates the Opportunity Team member record for the Secondary Team member
* on the opportunity
*
*
*/
    public void updateSecondaryTeamMember(List<Opportunity> pNewOpportunity, Map<ID,Opportunity> pOldOpportunityMap){
        Set<ID> oppsToQuery = new Set<ID>();
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
        system.debug('Inside updateSecondaryTeamMember');
        for(Opportunity o : pNewOpportunity){
            if(o.SecondarySalesRep__c != pOldOpportunityMap.get(o.Id).SecondarySalesRep__c){
                oppsToQuery.add(o.Id);
                oppMap.put(o.Id, o);
            }
        }
        system.debug('list of oppIDs = ' + oppsToQuery);

        //First lets find the team members that already exist and remove any opportunities from our list that
        //might need an update
        //Jeff L commented out for Query consolidation
        //For(OpportunityTeamMember__c oTM : [Select Id, TeamMember__c, Opportunity__c from OpportunityTeamMember__c Where Opportunity__c in :oppsToQuery]){
        For(OpportunityTeamMember__c oTM : queryTeamMember()){
            if(oppMap.containsKey(oTM.Opportunity__c)){
                if(oppMap.get(oTM.Opportunity__c).SecondarySalesRep__c == oTM.TeamMember__c){
                    oppsToQuery.remove(oTM.Opportunity__c);
                }
            }
        }

        //Now that we have removed opportunities that already have the secondary sales rep added to the opportunitiy team
        //we can go ahead and create all of our new opportunity team members based off of the opportunity Set
        List<OpportunityTeamMember__c> opportunityTeamMembersToInsertList = new List<OpportunityTeamMember__c>();
        for(Id oId : oppsToQuery){
            Opportunity oOpportunity = oppMap.get(oID);
            OpportunityTeamMember__c oppteamMember = new OpportunityTeamMember__c();
            oppTeamMember.TeamMember__c = oOpportunity.SecondarySalesRep__c;
            oppTeamMember.Split__c = 0.0;
            oppTeamMember.TeamRole__c = 'Sales Rep';
            oppTeamMember.Opportunity__c = oOpportunity.Id;
            oppTeamMember.OpportunityAccess__c = 'Read/Write';
            opportunityTeamMembersToInsertList.add(oppTeamMember);
        }

        insert opportunityTeamMembersToInsertList;

    }

    // Make chatter on oppportunity When SLA checkbox = true
    //Jeff L moved this into the trigger handler
    public void chatterOnOpportunity(list<Opportunity> listOpportunities,map<Id,Opportunity> oldMap){
        set<Id> accIds = new set<Id>();
        set<Id> ownerIds = new set<Id>();
        Utility util = Utility.newInstance();
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
        //Jeff L commented out to use usermap instead
        //map<Id, User> userMap = new map<Id,User>([Select Id,ManagerId from User Where Id IN :ownerIds]);
        Map<Id,User> userMap = UserIdToUserMap;
        //Jeff L Commented out to use new query framework
        //map<Id,Account> accountMap = new map<Id,Account>([Select Id,Organization__c from Account Where Id IN :accIds]);
        map<Id,Account> accountMap = new map<Id,Account>();
        for(Account a : queryAccountList()){
            if(accIDs.contains(a.Id)){
                accountMap.put(a.id, a);
            }
        }
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
    }

    // This method is used for updating the Opportunity team member custom object field Team Member to opportunity owner field
    // reference task - T-408190
    //Update method in due of Issue I-167744
    //Jeff L Moved this issue into helper code
    public void updateTeamMember(list<Opportunity> listOpportunities, map<Id,Opportunity> oldMap){
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
        if (listOpportunities.size() <= cutoff){ //JFreese Appirio S-435483 4/10/17
            system.debug('mapOpportunityOwner'+mapOpportunityOwner);
        }
        if(mapOpportunityOwner != null && mapOpportunityOwner.size() > 0){
            //Opportunity Team members Query for the changed owner Opps
            // Jeff L commented out for query optimization
            //for(OpportunityTeamMember__c oppmember:[Select TeamMember__c,TeamRole__c,Opportunity__c,TeamMember__r.Name from OpportunityTeamMember__c where Opportunity__c
            for(OpportunityTeamMember__c oppMember : queryTeamMember()){
                //         in:mapOpportunityOwner.keyset()]){
                if(!oppTeamMembers.keySet().contains(oppmember.Opportunity__c)){
                    oppTeamMembers.put(oppmember.Opportunity__c, new List<OpportunityTeamMember__c>());
                }
                oppTeamMembers.get(oppmember.Opportunity__c).add(oppmember);
            }
        }

        if (listOpportunities.size() <= cutoff){ //JFreese Appirio S-435483 4/10/17
            system.debug('oppTeamMembers'+oppTeamMembers);
        }
        if(mapOpportunityOwner != null && mapOpportunityOwner.size()>0 && oppTeamMembers.size()>0){
            Map<Id,OpportunityTeamMember__c> listOpportunityTeamMember = new Map<Id,OpportunityTeamMember__c>();
            list<OpportunityTeamMember__c> deleteOpportunityTeamMember = new list<OpportunityTeamMember__c>();
            //JFreese Appirio 12/6/16 Update to prevent Duplicate IDs in List exception
            Set<Id> deleteOpportunityTeamMemberIds = new Set<Id>();
            List<OpportunityTeamMember__c> teamMembers = new list<OpportunityTeamMember__c>();
            OpportunityTeamMember__c member;
            Boolean primarySalesRepExists = false;
            Boolean sameMemberExists = false;
            for(Id oppId : mapOpportunityOwner.KeySet()){
                primarySalesRepExists = false;
                sameMemberExists = false;
                //updated by Vivek if condition due to null pointer in map.
                if(oppTeamMembers.containsKey(oppId)){
                    teamMembers = oppTeamMembers.get(oppId);
                }
                for(OpportunityTeamMember__c oppmember: teamMembers){
                    if(oppmember.TeamMember__c == mapOpportunityOwner.get(oppId) ){
                        //deleteOpportunityTeamMember.add(oppmember);
                        oppmember.TeamRole__c = 'Primary Sales Rep';
                        if(!listOpportunityTeamMember.containsKey(oppmember.id)){
                            listOpportunityTeamMember.put(oppmember.id,oppmember);
                        }
                        sameMemberExists = true;
                        primarySalesRepExists = true;
                    }
                }
                if (listOpportunities.size() <= cutoff){ //JFreese Appirio S-435483 4/10/17
                    system.debug('teamMembers'+teamMembers);
                    system.debug('sameMemberExists'+sameMemberExists+'deleteOpportunityTeamMemberIds'+deleteOpportunityTeamMemberIds);
                }
                for(OpportunityTeamMember__c oppmember: teamMembers){

                    if(oppmember.TeamRole__c == 'Primary Sales Rep' && oppmember.TeamMember__c != mapOpportunityOwner.get(oppId)){
                        primarySalesRepExists = true;
                        if(sameMemberExists && !deleteOpportunityTeamMemberIds.contains(oppmember.Id)){
                            deleteOpportunityTeamMember.add(oppmember);
                            deleteOpportunityTeamMemberIds.add(oppmember.Id);
                        } /*else {
oppmember.TeamMember__c = mapOpportunityOwner.get(oppmember.Opportunity__c);
listOpportunityTeamMember.add(oppmember);
}*/
                    }
                }

                if (listOpportunities.size() <= cutoff){ //JFreese Appirio S-435483 4/10/17
                    system.debug('deleteOpportunityTeamMember'+deleteOpportunityTeamMember);
                    system.debug('primarySalesRepExists'+primarySalesRepExists);
                }
                if(!primarySalesRepExists){
                    OpportunityTeamMember__c oppTeamMember = new OpportunityTeamMember__c ();
                    oppTeamMember.TeamMember__c = mapOpportunityOwner.get(oppId);
                    oppTeamMember.Split__c = 100.0;
                    oppTeamMember.TeamRole__c = 'Primary Sales Rep';
                    oppTeamMember.Opportunity__c = oppId;
                    oppTeamMember.OpportunityAccess__c = 'Read/Write';
                    if(!listOpportunityTeamMember.containsKey(oppTeamMember.id)){
                        listOpportunityTeamMember.put(oppTeamMember.id,oppTeamMember);
                    }
                }
            }
            if (listOpportunities.size() <= cutoff){ //JFreese Appirio S-435483 4/10/17
               system.debug('!!!!!!!!!!!deleteOpportunityTeamMember'+deleteOpportunityTeamMember);
            }
            if(deleteOpportunityTeamMember != null && deleteOpportunityTeamMember.size()>0){
                delete deleteOpportunityTeamMember;
            }
            if (listOpportunities.size() <= cutoff){ //JFreese Appirio S-435483 4/10/17
               system.debug('!!!!!!Insode Update member after delete'+listOpportunityTeamMember);
            }
            if(!listOpportunityTeamMember.values().isEmpty()){
                upsert listOpportunityTeamMember.values();
            }
        }
    }

    //SBerron - 2/09/17 - S-461740
    //Set cloned opportunity record type to account organization
    public void updateClonedOpptyRecordType(list<Opportunity> pOpportunityList) {
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateClonedOpptyRecordType');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        List<Opportunity> cloned = new List<Opportunity>();
        Set<Id> accSet = new Set<Id>();
        Map<Opportunity, Id> oppToSourceOpptyIdMap = new Map<Opportunity, Id>(); //Map to hold source opportunity
        Id rebillOppty = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'Rebill Opportunity');

        for (Opportunity opp : pOpportunityList) {
            if (opp.isClone() && opp.RecordTypeId != rebillOppty) {
                cloned.add(opp);
                accSet.add(opp.AccountId);
                oppToSourceOpptyIdMap.put(opp, opp.getCloneSourceId());
            }
        }

        if (cloned.size() == 0) {
            System.debug('----Not cloned opportunity - returning');
            return;
        }

        Map<Id, Opportunity> oppIdtoSourceOpptyMap = new Map<Id, Opportunity>(); //Map of Source Id to Source opportunity
        for (Opportunity opp : [SELECT Id, OpportunityType__c FROM Opportunity WHERE Id IN :oppToSourceOpptyIdMap.values()]) {
            oppIdtoSourceOpptyMap.put(opp.Id, opp);
        }
        System.debug('----oppIdtoSourceOpptyMap ' + oppIdtoSourceOpptyMap);

        Id euSalesRepOppty = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'EU - Sales Rep Opportunity');
        Id naSalesRepOppty = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'NA - Sales Rep Opportunity');
        Id apacSalesRepOppty = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'APAC - Sales Rep Opportunity');
        Map<Id, String> accIdToOrganizationMap = new Map<Id, String>();
        for (Account a : [SELECT Id, Organization__c FROM Account WHERE Id in :accSet]) {
            accIdToOrganizationMap.put(a.Id, a.Organization__c);
        }

        for (Opportunity opp : cloned) {
            opp.OpportunityType__c = oppIdtoSourceOpptyMap.get(oppToSourceOpptyIdMap.get(opp)).OpportunityType__c;
            if (accIdToOrganizationMap.get(opp.AccountId) == 'Europe') {
                opp.Organization__c = 'Europe';
                opp.RecordTypeId = euSalesRepOppty;
            }
            else if (accIdToOrganizationMap.get(opp.AccountId) == 'North America') {
                opp.Organization__c = 'North America';
                opp.RecordTypeId = naSalesRepOppty;
            }
            if (accIdToOrganizationMap.get(opp.AccountId) == 'Asia Pacific') {
                opp.Organization__c = 'Asia Pacific';
                opp.RecordTypeId = apacSalesRepOppty;
            }
        }
    }

    //SBerron - Appirio - 2/17/17 - S-442900
    //If Opportunity.InternationalDeal == true update the opportunity splits with matching Sales Allocation Splits (RevenueRecognitionSplits__c)
    //@param Opportunity List
    //@returns none
    //public void updateOpptySplit(list<Opportunity> pOpportunityList, Map<Id, Opportunity> pOldOpportunityMap) {
        public void updateOpptySplit(list<Opportunity> pOpportunityList, map<Id,Opportunity> pOldOpportunityMap) {
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateOpptySplit');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        String customException = '';
        try {
            if (Method_Kill_List__c.getInstance('updateOpptySplit').Kill_Method__c) {
                System.debug('updateOpptySplit killed by custom setting');
                return;
            }

            //Get list of international opportunities
            List<Opportunity> internationalOpptyList = new List<Opportunity>();
            Set<Id> internationalOpptyIdSet = new Set<Id>();
            Set<Id> ownerIds = new Set<Id>();
            if (pOpportunityList.size() <= cutoff){ //JFreese Appirio S-435483 4/10/17
                system.debug(' ##List '+pOpportunityList);
            }
            for (Opportunity opp : pOpportunityList) {
                if (pOpportunityList.size() <= cutoff || opp.Id == debugId){ //JFreese Appirio S-435483 4/10/17
                    System.debug('----opp ' + opp);
                }
                if (opp.InternationalDeal__c
                    && opp.Manual_Split_Updates__c != true
                    && opp.Amount != 0
                    && (opp.StageName == 'Stage 1 - Needs Assessment'
                        || opp.StageName == 'Stage 2 - Proposal'
                        || opp.StageName == 'Stage 3 - Quote'
                        //SBerron - S-473201 - 03/14/17
                        || (OrderTriggerHandler.CreatingCreditOpportunity != null && OrderTriggerHandler.CreatingCreditOpportunity))) {
                    internationalOpptyList.add(opp);
                    internationalOpptyIdSet.add(opp.Id);
                    ownerIds.add(opp.OwnerId);
                }
            }

            //if oppty was intl and now isn't, reset the splits
            List<Opportunity> opptyToReset = new List<Opportunity>();
            system.debug('##List## '+pOpportunityList);
            for (Opportunity opp : pOpportunityList) {
                    system.debug('$$$'+opp.Manual_Split_Updates__c + ' msu' + opp.InternationalDeal__c + ' new' + pOldOpportunityMap.get(opp.Id).InternationalDeal__c + 'old');
                if (opp.Manual_Split_Updates__c != true && opp.InternationalDeal__c == false && pOldOpportunityMap.get(opp.Id).InternationalDeal__c == true) {
                    opptyToReset.add(opp);
                }
            }
            if (opptyToReset.size() > 0) {
                resetOpportunitySplits(opptyToReset);
            }

            if (internationalOpptyList.size() == 0) {
                System.debug('Exiting updateOpptySplit - no international opportunities to generate splits for.');
                return;
            }

            //Need to reset the splits where owner has 100% so upsert does not fail
            //resetOpportunitySplits(pOpportunityList);
            //resetOpportunitySplits(pOpportunityList, pOldOpportunityMap);

            //Populate opptyIdToLineItem. Map of oppty Id to list of opportunity line items
            Map<Id, List<OpportunityLineItem>> opptyIdToLineItem = new Map<Id, List<OpportunityLineItem>>();
            if (internationalOpptyIdSet.size() > 0) {
                for (OpportunityLineItem opptyLineItem : [SELECT Id, Alma_Product__c, ProductFamily__c, OpportunityId, Split_Country__c, TotalPrice, Proposal_Line_Item__r.Apttus_Proposal__Proposal__r.Selling_Country__c
                                                          FROM OpportunityLineItem
                                                          WHERE OpportunityId IN :internationalOpptyIdSet]) {
                    if (!opptyIdToLineItem.containsKey(opptyLineItem.OpportunityId)) {
                        List<OpportunityLineItem> opptyLine = new List<OpportunityLineItem>();
                        opptyLine.add(opptyLineItem);
                        opptyIdToLineItem.put(opptyLineItem.OpportunityId, opptyLine);
                    }
                    else {
                        opptyIdToLineItem.get(opptyLineItem.OpportunityId).add(opptyLineItem);
                    }
                }
            }

            if (pOpportunityList.size() <= cutoff){ //JFreese Appirio S-435483 4/10/17
                System.debug('----opptyIdToLineItem ' + opptyIdToLineItem);
            }

            //Populate opptyToOpptySplitMap. Map of oppty Id to list of Opportunity Splits
            Map<Id, List<OpportunitySplit>> opptyToOpptySplitMap = new Map<Id, List<OpportunitySplit>>();
            if (internationalOpptyList.size() > 0) {
                for (OpportunitySplit opptySplit : [SELECT Id, SplitOwnerId, SplitPercentage, SplitAmount, OpportunityId, Split_Amount_Country_Currency__c, Country__c
                                                    FROM OpportunitySplit
                                                    WHERE OpportunityId IN :internationalOpptyList]) {
                    if (!opptyToOpptySplitMap.containsKey(opptySplit.OpportunityId)) {
                        List<OpportunitySplit> opptySplitList = new List<OpportunitySplit>();
                        opptySplitList.add(opptySplit);
                        opptyToOpptySplitMap.put(opptySplit.OpportunityId, opptySplitList);
                    }
                    else {
                        opptyToOpptySplitMap.get(opptySplit.OpportunityId).add(opptySplit);
                    }
                }
            }

            if (pOpportunityList.size() <= cutoff){ //JFreese Appirio S-435483 4/10/17
                System.debug('----opptyToOpptySplitMap ' + opptyToOpptySplitMap);
            }

            //Populate set of countries and product families to be used for finding Sales Allocation and Country Revenue Splits
            Set<String> countries = new Set<String>();
            Set<String> productFamilies = new Set<String>();
            for (Opportunity opp : internationalOpptyList) {
                if (opptyToOpptySplitMap.containsKey(opp.Id)) {
                    if (opptyIdToLineItem.size() > 0) {
                        if (opptyIdToLineItem.get(opp.Id) != null) {
                            for (OpportunityLineItem opptyLineItem : opptyIdToLineItem.get(opp.Id)) {
                            if (opptyLineItem.Split_Country__c != null) {
                                countries.add(opptyLineItem.Split_Country__c);
                            }
                            productFamilies.add(opptyLineItem.ProductFamily__c);
                            }
                        }
                    }
                    if (pOpportunityList.size() <= cutoff){ //JFreese Appirio S-435483 4/10/17
                        System.debug('----productFamilies ' + productFamilies);
                        System.debug('----countries ' + countries);
                    }
                }
            }

            //Populate Map of Revenue Recogntion split Ids to revenue Recognition Split
            Map<Id, RevenueRecognitionSplits__c> rrIdToRrMap = new Map<Id, RevenueRecognitionSplits__c>();
            //Map of string to Revenue Recognition Split. The string will be generated below and contain the product family and country.
            //This only matches one Sales AllocationSplit and will be unique.
            Map<String, RevenueRecognitionSplits__c> countryProductFamilyToRrMap = new Map<String, RevenueRecognitionSplits__c>();
            if (productFamilies != null && productFamilies != null) {
                for(RevenueRecognitionSplits__c rrs : [SELECT Id, PostingLocation__c, ProductFamily__c
                                                       FROM RevenueRecognitionSplits__c
                                                       WHERE ProductFamily__c IN :productFamilies
                                                            AND PostingLocation__c IN :countries]){
                    rrIdToRrMap.put(rrs.Id, rrs);
                    String temp = rrs.PostingLocation__c + '#' + rrs.ProductFamily__c;
                    countryProductFamilyToRrMap.put(temp, rrs);
                }
            }
            if (pOpportunityList.size() <= cutoff){ //JFreese Appirio S-435483 4/10/17
                System.debug('----rrIdToRrMap ' + rrIdToRrMap);
                System.debug('----countryProductFamilyToRrMap ' + countryProductFamilyToRrMap);
            }

            //Populate map of opportunity line item to Revenue Recognition split based on country and product family
            Map<Id, RevenueRecognitionSplits__c> opptyLineItemIdToRrSplitMap = new Map<Id, RevenueRecognitionSplits__c>();
            for (Id id : opptyIdToLineItem.keyset()) {
                List<OpportunityLineItem> opptyProducts = opptyIdToLineItem.get(id);
                for (OpportunityLineItem oppProduct : opptyProducts) {
                    String temp = oppProduct.Split_Country__c + '#' + oppProduct.ProductFamily__c;
                    RevenueRecognitionSplits__c rrs = countryProductFamilyToRrMap.get(temp);
                    if (rrs != null) {
                        opptyLineItemIdToRrSplitMap.put(oppProduct.Id, rrs);
                    }
                }
            }

            if (pOpportunityList.size() <= cutoff){ //JFreese Appirio S-435483 4/10/17
                System.debug('----opptyLineItemIdToRrSplitMap ' + opptyLineItemIdToRrSplitMap);
            }

            //Populate map of Revenue Recognition Split Ids to Country Revenue Split
            Map<Id, List<Country_Revenue_Split__c>> rrIdToCrMap = new Map <Id, List<Country_Revenue_Split__c>>();
            if (rrIdToRrMap != null) {
                for (Country_Revenue_Split__c crs : [SELECT Id, Name, SplitPercentage__c, RevenueRecognitionSplit__c
                                                     FROM Country_Revenue_Split__c
                                                     WHERE RevenueRecognitionSplit__c IN :rrIdToRrMap.keySet()]) {
                    if (!rrIdToCrMap.containsKey(crs.RevenueRecognitionSplit__c)) {
                        List<Country_Revenue_Split__c> countryRevenueSplits = new List<Country_Revenue_Split__c>();
                        countryRevenueSplits.add(crs);
                        rrIdToCrMap.put(crs.RevenueRecognitionSplit__c, countryRevenueSplits);
                    }
                    else {
                        rrIdToCrMap.get(crs.RevenueRecognitionSplit__c).add(crs);
                    }
                }
            }
            if (pOpportunityList.size() <= cutoff){ //JFreese Appirio S-435483 4/10/17
                System.debug('----rrIdToCrMap ' + rrIdToCrMap);
            }

            //Map of opportunity owner Ids to their user record Location
            //Used when creating oppty splits so the custom settings defined don't override the split for the owner's country
            Map<Id, String> userIdToLocationMap = new Map<Id, String>();
            for (User u : [SELECT Id, Name, Location__c FROM User WHERE Id in :ownerIds]) {
                userIdToLocationMap.put(u.Id, u.Location__c);
            }
            if (pOpportunityList.size() <= cutoff){ //JFreese Appirio S-435483 4/10/17
                System.debug('----userIdToLocationMap ' + userIdToLocationMap);
            }

            //Map of custom settings
            Map<String, Opportunity_Split_Owners__c> customSettingMap = Opportunity_Split_Owners__c.getAll();

            //Time to generate the list of opportunity splits to upsert
            List<OpportunitySplit> listSplitsToUpsert = new List<OpportunitySplit>();
            List<OpportunitySplit> listSplitsToInsertZero = new List<OpportunitySplit>();
            Map<String, Decimal> opptyOwnerIdToPercentage = new Map<String, Decimal>();

            for (Opportunity oppty : internationalOpptyList) {
                //Map to contain splits. Important to keep a map of the owner Id to the split so if there
                //are more than one Country revenue splits, it gets added to opportunity split
                Map<Id, OpportunitySplit> splitsToUpsert = new Map<Id, OpportunitySplit>();
                Decimal total = oppty.Amount;

                //SBerron - S-473201 - 03/14/17
                //If oppty amount is negative (credit), set it positive for splits calculation
                if (total < 0) {
                    total *= -1;
                }

                List<OpportunitySplit> splits = opptyToOpptySplitMap.get(oppty.Id);
                List<OpportunityLineItem> lineItems = opptyIdToLineItem.get(oppty.Id);
                Map<String, AlmaProductSalesAllocationSplits__c> almaCustomSettingSplitMap = AlmaProductSalesAllocationSplits__c.getAll();
                Decimal sumTotal = 0.00;
                Decimal percent;

                //Nullifying existing splits to ensure that sum = 100%
                for (OpportunitySplit sp: splits) {
                    if (pOpportunityList.size() <= cutoff || oppty.Id == debugId){ //JFreese Appirio S-435483 4/10/17
                        System.debug('----setting to 0 ' + sp);
                    }
                    sp.SplitPercentage = 0.00;
                    splitsToUpsert.put(sp.SplitOwnerId, sp);
                }
                //if (total != 0) {
                    if (lineItems != null) {
                        for (OpportunityLineItem li : lineItems) {
                            if (pOpportunityList.size() <= cutoff || oppty.Id == debugId){ //JFreese Appirio S-435483 4/10/17
                                System.debug('----li ' + li);
                            }

                            //SBerron - 3/27/17 - S-474813
                            //Line items with alma splits need to be created differently
                            if (li.Alma_Product__c && li.Split_Country__c != null) {
                                if (pOpportunityList.size() <= cutoff || oppty.Id == debugId){ //JFreese Appirio S-435483 4/10/17
                                    System.debug('Alma Product');
                                }

                                Decimal almaTotal = 100;
                                Decimal almaSplitPercentage = almaCustomSettingSplitMap.get(li.Split_Country__c).SplitPercentage__c;

                                if (li.Split_Country__c != null && almaCustomSettingSplitMap.containsKey(li.Split_Country__c)) {
                                    if (pOpportunityList.size() <= cutoff || oppty.Id == debugId){ //JFreese Appirio S-435483 4/10/17
                                        System.debug('----almaCustomSettingSplitMap.get(li.Split_Country__c)' + almaCustomSettingSplitMap.get(li.Split_Country__c));
                                    }
                                    OpportunitySplit newAlmaOpptySplit = new OpportunitySplit();
                                    percent = ((almaSplitPercentage * li.TotalPrice) / total).setScale(2);

                                    newAlmaOpptySplit.SplitOwnerId = customSettingMap.get(li.Split_Country__c).Owner_Id__c;
                                    newAlmaOpptySplit.SplitPercentage = percent;
                                    newAlmaOpptySplit.OpportunityId = oppty.Id;
                                    newAlmaOpptySplit.Country__c = li.Split_Country__c;

                                if (splitsToUpsert.get(newAlmaOpptySplit.SplitOwnerId) != null) {
                                            splitsToUpsert.get(newAlmaOpptySplit.SplitOwnerId).SplitPercentage += newAlmaOpptySplit.SplitPercentage;
                                            splitsToUpsert.get(newAlmaOpptySplit.SplitOwnerId).Country__c = li.Split_Country__c;
                                        }
                                        else {
                                            splitsToUpsert.put(newAlmaOpptySplit.SplitOwnerId, newAlmaOpptySplit);
                                        }

                                    almaTotal -= almaSplitPercentage;
                                    sumTotal += percent;

                                    if (pOpportunityList.size() <= cutoff || oppty.Id == debugId){ //JFreese Appirio S-435483 4/10/17
                                        System.debug('----newAlmaOpptySplit ' + newAlmaOpptySplit);
                                    }
                                    if (almaTotal > 0) {
                                        percent = ((almaTotal * li.TotalPrice) / total).setScale(2);
                                        String country = li.Proposal_Line_Item__r.Apttus_Proposal__Proposal__r.Selling_Country__c;

                                        splitsToUpsert.get(oppty.OwnerId).SplitPercentage += percent;

                                        if (country != null) {
                                            splitsToUpsert.get(oppty.OwnerId).Country__c = country;
                                        }

                                        sumTotal += percent;
                                        if (pOpportunityList.size() <= cutoff || oppty.Id == debugId){ //JFreese Appirio S-435483 4/10/17
                                            System.debug('----remaining percent ' + percent);
                                        }
                                    }

                                }

                            }
                            else {
                                RevenueRecognitionSplits__c rrs = opptyLineItemIdToRrSplitMap.get(li.Id);
                                if (pOpportunityList.size() <= cutoff || oppty.Id == debugId){ //JFreese Appirio S-435483 4/10/17
                                    System.debug('----rrs ' + rrs);
                                }
                                if (rrs != null) {
                                    List<Country_Revenue_Split__c> countryRevenueSplits = rrIdToCrMap.get(rrs.Id);
                                    if (pOpportunityList.size() <= cutoff || oppty.Id == debugId){ //JFreese Appirio S-435483 4/10/17
                                        System.debug('----countryRevenueSplits ' + countryRevenueSplits);
                                    }
                                    if (countryRevenueSplits != null) {
                                        for (Country_Revenue_Split__c crs : countryRevenueSplits) {
                                            if (pOpportunityList.size() <= cutoff || oppty.Id == debugId){ //JFreese Appirio S-435483 4/10/17
                                                System.debug('----crs in loop ' + crs);
                                            }
                                            OpportunitySplit newOpptySplit = new OpportunitySplit();

                                            //We want to give the opportunity owner credit, not the default user for the country defined in custom setting.
                                            if (userIdToLocationMap.get(oppty.OwnerId) == crs.Name) {
                                                newOpptySplit.SplitOwnerId = oppty.OwnerId;
                                            }
                                            else if (customSettingMap.get(crs.Name) != null){
                                                newOpptySplit.SplitOwnerId = customSettingMap.get(crs.Name).Owner_Id__c;
                                            }
                                            else {
                                                customException += ' NO MATCHING CUSTOM SETTING FOR OPPORTUNITY SPLIT OWNER COUNTRY: ' + crs.Name;
                                            }
                                            //find a country revenue's % of the total oppty
                                            if (pOpportunityList.size() <= cutoff || oppty.Id == debugId){ //JFreese Appirio S-435483 4/10/17
                                                System.debug('----crs.SplitPercentage ' + crs.SplitPercentage__c);
                                                System.debug('----li.TotalPrice' + li.TotalPrice);
                                                System.debug('----percent ' + (crs.SplitPercentage__c * li.TotalPrice) / total);
                                            }

                                            percent = ((crs.SplitPercentage__c * li.TotalPrice) / total).setScale(2);
                                            //SBerron - S-473201 - 03/14/17
                                            //if If line item amount is negative (credit), set it positive for splits calculation
                                            if (percent < 0) {
                                                percent *= -1;
                                            }
                                            sumTotal += percent;
                                            newOpptySplit.SplitPercentage = percent;
                                            newOpptySplit.Country__c = crs.Name;
                                            newOpptySplit.OpportunityId = oppty.Id;
                                            //splitsToUpsert.add(newOpptySplit);
                                            if (splitsToUpsert.get(newOpptySplit.SplitOwnerId) != null) {
                                                splitsToUpsert.get(newOpptySplit.SplitOwnerId).SplitPercentage += newOpptySplit.SplitPercentage;
                                                splitsToUpsert.get(newOpptySplit.SplitOwnerId).Country__c = crs.Name;
                                            }
                                            else {
                                                splitsToUpsert.put(newOpptySplit.SplitOwnerId, newOpptySplit);
                                            }

                                            if (pOpportunityList.size() <= cutoff || oppty.Id == debugId){ //JFreese Appirio S-435483 4/10/17
                                                System.debug('----newOpptySplit ' + newOpptySplit);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                //}
                System.debug('----sumTotal ' +sumTotal);

                //Splits MUST = 100.00 exactly when upserted, otherwise there will be a failure. This ensures that the sum is 100%
                //In addition, any extra % that wasn't in a split is given to the oppty owner's split.
                //If the oppty owner's split's country gets 0% (rare but possible), it is possible for the split to have an amount of $.01 due to SF rounding
                //Matt Keefe knows and is okay with this
                //List<OpportunitySplit> tempList = splitsToUpsert.values();
                Decimal diff = 100.00 - sumTotal;
                System.debug('----diff ' + diff);
                //tempList[tempList.size()-1].SplitPercentage += diff;
                if (splitsToUpsert.get(oppty.OwnerId).SplitPercentage + diff >= 0) {
                    splitsToUpsert.get(oppty.OwnerId).SplitPercentage += diff;
                }
                else {
                    for (Id splitId : splitsToUpsert.keySet()) {
                        if (splitsToUpsert.get(splitId).SplitPercentage + diff >= 0) {
                            splitsToUpsert.get(splitId).SplitPercentage += diff;
                            break;
                        }
                    }
                }
                listSplitsToUpsert.addAll(splitsToUpsert.values());
            }

            for (OpportunitySplit oppSplit : listSplitsToUpsert) {
                if (oppSplit.Id == null) {
                    String mapKey = oppSplit.OpportunityId + '#' + oppSplit.SplitOwnerId;
                    Decimal percent = oppSplit.SplitPercentage;
                    opptyOwnerIdToPercentage.put(mapKey, percent);
                    oppSplit.SplitPercentage = 0.00;
                    listSplitsToInsertZero.add(oppSplit);
                }
            }
            if (pOpportunityList.size() <= cutoff){ //JFreese Appirio S-435483 4/10/17
                System.debug('----listSplitsToInsertZero ' + listSplitsToInsertZero);
                System.debug('----opptyOwnerIdToPercentage ' + opptyOwnerIdToPercentage);
            }

            if (listSplitsToInsertZero.size() > 0) {
                insert listSplitsToInsertZero;
            }
            if (pOpportunityList.size() <= cutoff){ //JFreese Appirio S-435483 4/10/17
                System.debug('----listSplitsToUpsert BEFORE ' + listSplitsToUpsert);
            }
            for (OpportunitySplit split : listSplitsToUpsert) {
                String mapKey = split.OpportunityId + '#' + split.SplitOwnerId;
                if (opptyOwnerIdToPercentage.containsKey(mapKey)) {
                    split.SplitPercentage = opptyOwnerIdToPercentage.get(mapKey);
                }
            }

            if (pOpportunityList.size() <= cutoff){ //JFreese Appirio S-435483 4/10/17
                System.debug('----listSplitsToUpsert AFTER' + listSplitsToUpsert);
            }
            if (listSplitsToUpsert.size() > 0) {
                upsert listSplitsToUpsert;
            }
        }
        catch(Exception e) {
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Failed to upsert Opportunity Splits. Please see system log for details. ' + '<br/>' + customException + '<br/>' + e.getMessage() + e.getLineNumber(),e);
        }
    }

    //SBerron - Appirio - 2/27/17 - S-442900
    //Reset the opportunity split owner to 100. Necessary to run every time to reset splits for owner to have 100%
    //If not done, there is an edge case where the upsert process causes the sum != 100%
    //@param New Opportunity Split List, Old Opportunity Map
    //@returns none
    //public void resetOpportunitySplits(List<Opportunity> pUpdatedOpportunities, Map<Id,Opportunity> pOpportunityMapOld) {
        public void resetOpportunitySplits(List<Opportunity> pUpdatedOpportunities) {
        final string METHODNAME = CLASSNAME.replace('METHODNAME','resetOpportunitySplits');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try {
            List<Opportunity> opptyToUpdate = new List<Opportunity>();
            List<OpportunitySplit> splitsToUpdate = new List<OpportunitySplit>();

            for (Opportunity oppty : pUpdatedOpportunities) {
                System.debug('----oppty ' + oppty);
                //if (oppty.Manual_Split_Updates__c == false && pOpportunityMapOld.get(oppty.Id).Manual_Split_Updates__c == true) {
                if (!oppty.Manual_Split_Updates__c) {
                    opptyToUpdate.add(oppty);
                }
            }

            if (opptyToUpdate.size() == 0) {
                System.debug('EXITING - No Opportunity Splits to reset');
                return;
            }

            Map<Id, List<OpportunitySplit>> opptyToOpptySplitMap = new Map<Id, List<OpportunitySplit>>();
            for (OpportunitySplit opptySplit: [SELECT Id, SplitOwnerId, SplitPercentage, OpportunityId
                                                FROM OpportunitySplit
                                                WHERE OpportunityId IN :opptyToUpdate]) {
                if (!opptyToOpptySplitMap.containsKey(opptySplit.OpportunityId)) {
                    List<OpportunitySplit> opptySplitList = new List<OpportunitySplit>();
                    opptySplitList.add(opptySplit);
                    opptyToOpptySplitMap.put(opptySplit.OpportunityId, opptySplitList);
                }
                else {
                    opptyToOpptySplitMap.get(opptySplit.OpportunityId).add(opptySplit);
                }
            }

            for (Opportunity opp : opptyToUpdate) {
                for (Id oppId : opptyToOpptySplitMap.keySet()) {
                    List<OpportunitySplit> opptySplitList = opptyToOpptySplitMap.get(oppId);
                    for (OpportunitySplit oppSplit : opptySplitList) {
                        if (oppSplit.SplitOwnerId == opp.OwnerId) {
                            oppSplit.SplitPercentage = 100.00;
                        }
                        else {
                            oppSplit.SplitPercentage = 0;
                        }
                        splitsToUpdate.add(oppSplit);
                    }
                }
            }
            System.debug('----splitsToUpdate ' + splitsToUpdate);
            if (splitsToUpdate.size() > 0) {
                update splitsToUpdate;
            }
        }
        catch (Exception e) {
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Failed to reset Opportunity Splits. Please see system log for details. ' + e.getMessage() + e.getLineNumber(),e);
        }
    }

    /*
** @author : Apttus
** @date : 11/10/2016
** @description : S-418868 : Shall only be allowed for Stage 4 proposals in 'Accepted Offline' status
** Setting back to stage 3 should also:
**  Set record type back to Proposal (from proposal locked)
**  Set Overall Quote Status to 'In Progress'
**  Set approval status to 'Not Submitted'
**  Allow user to create new cart configuration
**  re-validate for approvals and require new round if needed 
** @paramaters : list of Opportunity
** @returns : none
*/
    public void updateQuptesForStage3(Map<Id, Opportunity> pNewOpportunityMap, Map<Id, Opportunity> pOldOpportunityMap){
        Set<Id> oppIds = new Set<Id>();
        for(Opportunity opp : pNewOpportunityMap.values()){
            if(opp.StageName == 'Stage 3 - Quote' && pOldOpportunityMap.get(opp.Id).StageName == 'Stage 4 - Won'){
                oppIds.add(opp.Id);
            }
        }

        if(oppIds.Size() > 0){
//            Set<String> setValidProfileNames = new Set<String>{'Order Management (EU)','Service Manager (EU)','Service Rep (EU)','System Administrator','Sales Operations (EU) TA','Sales Operations (TA)'};
            //JFreese Appirio 3/8/17 Populating the set this way as it does not break color highlighting of all code that follows
            Set<String> setValidProfileNames = new Set<String>();
            setValidProfileNames.add('Order Management (EU)');
            setValidProfileNames.add('Service Manager (EU)');
            setValidProfileNames.add('Service Rep (EU)');
            setValidProfileNames.add('System Administrator');
            setValidProfileNames.add('Sales Operations (EU) TA');
            setValidProfileNames.add('Sales Operations (TA)');

                Map<Id, Profile> mapValidProfileID = new Map<Id, Profile>(
                    [
                        Select
                        Id,Name
                        From Profile
                        Where name in : setValidProfileNames
                    ]
                );

            if(mapValidProfileID.Containskey(userinfo.getProfileId())){
                List<Apttus_Proposal__Proposal__c> proposalList = [
                    SELECT
                    Id,RecordTypeId ,
                    Apttus_Proposal__Opportunity__c,
                    QuoteStatus__c , Apttus_QPApprov__Approval_Status__c
                    FROM Apttus_Proposal__Proposal__c
                    WHERE Apttus_Proposal__Opportunity__c IN: oppIds and QuoteStatus__c = 'Accepted Offline'
                ];
                if(proposalList.Size() > 0){
                    for(Apttus_Proposal__Proposal__c objProposal : proposalList){
                        objProposal.RecordTypeId = Schema.Sobjecttype.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Proposal').getRecordTypeId();
                        objProposal.QuoteStatus__c = 'In Progress';
                        objProposal.Apttus_QPApprov__Approval_Status__c = 'Not Submitted';
                        objProposal.signed_indicator__c = false;
                        objProposal.Apttus_Proposal__Approval_Stage__c = 'Draft';
                        objProposal.Locked__c = false;
                    }
                    ApttusProposalTriggerHandler.ExecuteTriggersFromOpportunityUpdate = false;
                    Update proposalList;
                    ApttusProposalTriggerHandler.ExecuteTriggersFromOpportunityUpdate = true;
                }
            }
        }
    }


    /*
This method removes the opportunity split record for previous opportunity owner when
owner changes in case of closed opportunity (refer to S-452703)
By Vikas Menon, 27 Jan 2017
*/
    public void removeSplitWhenOwnerChangesonClosedOppty(List<Opportunity> pNewOpportunity, Map<Id, Opportunity> pOldOpportunityMap){

        Set<Id> oppIds = new Set<Id>();
        Map<Id,List<OpportunityteamMember>> mapTeamOwners = new Map<Id,List<OpportunityteamMember>>();
        Map<Id,List<OpportunitySplit>> mapSplitOwners = new Map<Id,List<OpportunitySplit>>() ;
        List<OpportunitySplit > deleteSplitList = new List<OpportunitySplit >();
        List<OpportunityteamMember> deleteTeamList = new List<OpportunityteamMember>();
        //Getting List Of ClosedOpportunities where Owner has Changed
        for(Opportunity OppObj : pNewOpportunity){
            if (pNewOpportunity.size() <= cutoff || OppObj.Id == debugId){ //JFreese Appirio S-435483 4/10/17
                system.debug(' CLosed '+ oppObj.isClosed + ' New ' + oppObj.ownerId + ' Old ' + pOldOpportunityMap.get(OppObj.id).ownerId);
            }
            if(oppObj.isClosed && oppObj.ownerId != pOldOpportunityMap.get(OppObj.id).ownerId){
                if (pNewOpportunity.size() <= cutoff || OppObj.Id == debugId){ //JFreese Appirio S-435483 4/10/17
                    system.debug('&&Called');
                }
                oppIds.add(oppObj.id);
            }
        }

        if(oppIds.isEmpty()){
            return;
        }

        //MAp Of Opportunity Id to Split Owners List
        for(OpportunitySplit oppSplit : [SELECT SplitOwnerId,opportunityId FROM OpportunitySplit where OpportunityId in : oppIds]){
            if(!mapSplitOwners.containskey(oppSplit.opportunityId)){
                mapSplitOwners.put(oppSplit.opportunityId,new List<OpportunitySplit >());
            }
            mapSplitOwners.get(oppSplit.opportunityId).add(oppSplit);
        }

        system.debug('###'+mapSplitOwners);
        //MAp Of Opportunity Id to Team Members List
        for(OpportunityteamMember oppTeam : [SELECT UserID ,opportunityId FROM OpportunityteamMember where OpportunityId in :oppIds]){
            if(!mapTeamOwners.containskey(oppTeam.opportunityId)){
                mapTeamOwners.put(oppTeam.opportunityId,new List<OpportunityteamMember>());
            }
            mapTeamOwners.get(oppTeam.opportunityId).add(oppTeam);
        }

        system.debug('###'+mapTeamOwners);


        for(opportunity opp  : pNewOpportunity){
            //Checling if the Split Owner Id is same as Opportunity Owner Id
            if(mapSplitOwners.containsKey(opp.id)){
                for(OpportunitySplit  oppSplit : mapSplitOwners.get(opp.id)){
                    if(oppSplit.splitownerid == pOldOpportunityMap.get(opp.id).ownerID){
                        //List to Delete Previous Split Opportunity Owner
                        deleteSplitList.add(oppSplit);
                    }
                }
            }
            if(mapTeamOwners.containsKey(opp.id)){
                for(OpportunityTeamMember oppTeam : mapTeamOwners.get(opp.id)){
                    //Checling if the Team Member Id is same as Opportunity Owner Id
                    if(oppTeam.userID == pOldOpportunityMap.get(opp.id).ownerID){
                        //List to Delete Previous Team Opportunity Member
                        deleteTeamList.add(oppTeam);
                    }
                }
            }
        }
        system.debug('@@@deleteSplitList'+deleteSplitList);
        system.debug('@@@deleteTeamList'+deleteTeamList);


        if(!deleteSplitList.isEmpty()){
            delete deleteSplitList;
        }
        if(!deleteTeamList.isEmpty()){
            delete deleteTeamList;
        }
    }

    /*
        This method creates a new default sales credit split record on opportunity creation (refer to S-462090)
        By Vikas Menon, 06 March 2017
    */
    public void createDefaultSalesCreditOnOpportunity(List<Opportunity> pNewOpportunity) {

        List<Sales_Credit_Splits__c> salesCreditList = new List<Sales_Credit_Splits__c>();
        Sales_Credit_Splits__c salesCreditObj;
        // Create default Sales_Credit_Splits__c record
        for(Opportunity opp : pNewOpportunity){
            salesCreditObj = new Sales_Credit_Splits__c();
            salesCreditObj.Opportunity__c = opp.Id;
            salesCreditObj.Teaming_Rep__c = opp.ownerId;
            salesCreditObj.Teaming_rep_split_for_Revenue__c = 100;
            salesCreditObj.Teaming_Rep_Type__c = 'Revenue';
            //Added by -- Prashant Gupta, Appirio, S-473432 03/27/2017
            salesCreditObj.Bypass_Validation_Rules__c = true;
            //End
            salesCreditList.add(salesCreditObj);
        }
        if(!salesCreditList.isEmpty()){
            insert salesCreditList;
        }

    }

    /*
    @Description : When opportunity owner changes then this method will update the sales credit split record's Team Rep to related opportunity owner (refer to S-473433)
    Author : Vikas Menon, 23 March 2017
    */
    public void updateSalesCreditSplitSalesRep(List<Opportunity> pNewOpportunity, Map<Id, Opportunity> pOldOpportunityMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateSalesCreditSplitSalesRep');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        Map<Id, Opportunity> mapOpp = new Map<Id, Opportunity>();

        for(Opportunity o : pNewOpportunity) {
            if (pNewOpportunity.size() <= cutoff || o.Id == debugId){ //JFreese Appirio S-435483 4/10/17
                system.debug(LoggingLevel.INFO,'<<<<<>>>>>' + pOldOpportunityMap.get(o.id).OwnerId + '<<OLd>>'  +o.OwnerID);
                if(pOldOpportunityMap.get(o.id).OwnerId != o.OwnerId ){
                    mapOpp.put(o.id, o);
                }
            }
        }

        if(!mapOpp.isEmpty()){
            List<Sales_Credit_Splits__c> SalesCreditSplits = new List<Sales_Credit_Splits__c>();

            for(Sales_Credit_Splits__c split :  [SELECT Id, Teaming_Rep__c ,opportunity__r.OwnerId, Opportunity__c
                                                 FROM Sales_Credit_Splits__c
                                                 WHERE  Opportunity__c IN :mapOpp.keyset()]){
                //SBerron - 4/04/17 - I-267113 && I-267178
                //Was previously updating all sales credit split owners. Now we only update the split of the past owner of the oppty to the new owner
                if (pOldOpportunityMap.containskey(split.Opportunity__c)) {
                     if(pOldOpportunityMap.get(split.Opportunity__c).OwnerId == split.Teaming_Rep__c){
                         split.Teaming_Rep__c = mapOpp.get(split.Opportunity__c).OwnerId;
                         //Added by -- Prashant Gupta, Appirio, I-266242 03/27/2017
                         split.Bypass_Validation_Rules__c = true;
                         //End
                         SalesCreditSplits.add(split);
                     }
                }
            }
            System.debug('----SalesCreditSplits ' + SalesCreditSplits);
            if(!SalesCreditSplits.isEmpty()){
                update SalesCreditSplits;
            }
        }
    }

}