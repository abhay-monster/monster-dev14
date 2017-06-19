/**===========================================================================
 * Appirio, Inc
 * Name: TerritoryAssignmentForBatch
 * Description: Process to assign Accounts based upon Posting Address Zip code
 *
 * Date Modified                Modified By              Description of the update
 * 10th Sep 2015                Parul Gupta              T-431652: Added some methods
 ============================================================================*/
public class TerritoryAssignmentForBatch{
    final String CLASSNAME = '\n\n**** TerritoryAssignmentForBatch.METHODNAME()';
    public static List<TerritoryAssignmentCode__c> batchTerritoryAssignmentCodeList{get;set;}
    public List<Account> accountsToUpdate;
    private List<TerritoryAssignmentTeamMember__c> queryTATMList;

    /*
    ** @author : Cloud Sherpas, Inc.
    ** @date : 08/1/2014
    ** @story : 063
    ** @element : E1867
    ** @description : For Territory assignment
    ** @paramaters : List of Accounts, Map of updated accounts
    ** @returns : nothing
    */

    public String TerritoryAssignment(List<Account> pUpdatedAccounts, List<TerritoryAssignmentCode__c> pTerritoryAssignmentCodesList){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','TerritoryAssignment');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        String updateErrors = '';
        Org_Settings__c orgSettings = Org_Settings__c.getInstance();
        Database.DMLOptions options = new Database.DMLOptions();
        if(orgSettings.Send_Emails_During_Territory_Batch_Run__c == true){
            options.EmailHeader.triggerUserEmail = true;
        }
        else {
            options.EmailHeader.triggerUserEmail = false;
        }

        try{

            TerritoryAssignment taClass = new TerritoryAssignment(pUpdatedAccounts);
            taClass.runUpdate = false;
            taClass.dmlOptions = options;
            taClass.territoryAssignmentCodeList = pTerritoryAssignmentCodesList;
            taClass.runTerritoryAssignment();
            accountsToUpdate = taClass.updateList;
            for(Account a : accountsToUpdate){
                system.debug('Accounts To Update ' + a.Id);
            }
            Set<Id> assignedTerritoryIds = taClass.assignedTerritoryCodeSet;
            List<TerritoryAssignment__c> processedTA = taClass.processedTerritoryAssignments;

            if(accountsToUpdate.size() > 0){
                updateErrors += ArchiveHelper.doUpdate('Account', accountsToUpdate);
                List<Account_Team_Member__c> listATMToUpsert = new List<Account_Team_Member__c>();
                listATMToUpsert = upsertAccountTeamMembers(accountsToUpdate, assignedTerritoryIds);
                try {
                    upsert listATMToUpsert;
                } catch (Exception e) {
                    updateErrors += e.getMessage();
                }

                List<OpportunityTeamMember> listOTMToUpsert = new List<OpportunityTeamMember>();
                listOTMToUpsert = upsertOpportunityTeamMembers(accountsToUpdate, assignedTerritoryIds);
                if(listOTMToUpsert.size() > 0){
                    try {
                        upsert listOTMToUpsert;
                    } catch (Exception e) {
                        updateErrors += e.getMessage();
                    }

                    List<OpportunityShare> listOppShareToUpdate = new List<OpportunityShare>();
                    listOppShareToUpdate = updateOpportunityShares(listOTMToUpsert, assignedTerritoryIds);
                    if(listOppShareToUpdate.size() > 0){
                        try {
                            update listOppShareToUpdate;
                        } catch (Exception e) {
                            updateErrors += e.getMessage();
                        }
                    }
                }
            }
            if(processedTA != null) {
                update processedTA;
            }
        }catch(DMLException e){
           ExceptionLog.add('DMLException', 'AccountTriggerHelper', 'AccountWithoutTerritory', e.getMessage());
           throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to update Account.' ,e);
        }
        return updateErrors;
    }


    /*JHF 3/18/16 move this to a separate method as it is needed several times*/
    private List<TerritoryAssignmentTeamMember__c> queryTATMList(Set<Id> assignedTerritoryIds){
        if(queryTATMList == null){
            queryTATMList = [Select id, TeamMember__c, TeamMemberRole__c, TerritoryAssignment__c,
                             AccountAccessLevel__c, CaseAccessLevel__c, OpportunityAccessLevel__c
                             from TerritoryAssignmentTeamMember__c
                             where TerritoryAssignment__c in : assignedTerritoryIds];
        }
        return queryTATMList;
    }


    /*
        ** @author : Parul Gupta
        ** @date : 09/10/2015
        ** @description : For Territory Team Members
        ** @paramaters : List of Accounts, Set of Ids of territory assignment
        ** @returns : nothing
        */
    private List<Account_Team_Member__c> upsertAccountTeamMembers(List<Account> updatedAccounts, Set<Id> assignedTerritoryIds){


            final string METHODNAME = CLASSNAME.replace('METHODNAME','upsertAccountTeamMembers');
            system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '****  Inside '));
            system.debug('===assignedTerritoryIds======> '+assignedTerritoryIds);

            List<Account_Team_Member__c> upsertList = new List<Account_Team_Member__c>();
            Map<Id, List<TerritoryAssignmentTeamMember__c>> territoryIdToMembersMap = new Map<Id, List<TerritoryAssignmentTeamMember__c>>();
            Map<Id, List<Account_Team_Member__c>> accountIdToMembersMap = new Map<Id, List<Account_Team_Member__c>>();
            for(TerritoryAssignmentTeamMember__c teamMember : queryTATMList(assignedTerritoryIds)){
                if(!territoryIdToMembersMap.containsKey(teamMember.TerritoryAssignment__c)){
                        territoryIdToMembersMap.put(teamMember.TerritoryAssignment__c, new List<TerritoryAssignmentTeamMember__c>());
                }
                territoryIdToMembersMap.get(teamMember.TerritoryAssignment__c).add(teamMember);
            }

            system.debug('===territoryIdToMembersMap======> '+territoryIdToMembersMap);

            for(Account_Team_Member__c teamMember : [SELECT Id, UserId__c, TeamMemberRole__c, AccountId__c,
                                                     AccountAccessLevel__c, CaseAccessLevel__c, OpportunityAccessLevel__c
                                                     FROM Account_Team_Member__c
                                                     where AccountId__c IN : updatedAccounts]){
                 if(!accountIdToMembersMap.containsKey(teamMember.AccountId__c)){
                    accountIdToMembersMap.put(teamMember.AccountId__c, new List<Account_Team_Member__c> ());
                 }
                 accountIdToMembersMap.get(teamMember.AccountId__c).add(teamMember);
            }

            system.debug('====accountIdToMembersMap======> '+ accountIdToMembersMap);

            for(Account acc : updatedAccounts){
                if(territoryIdToMembersMap.get(acc.TerritoryCode__c) != null){
                    upsertList.addAll(getAccountTeamMembers(acc.id, accountIdToMembersMap.get(acc.id), territoryIdToMembersMap.get(acc.TerritoryCode__c)));
                }
            }

            system.debug('====upsertList======> '+ upsertList);
        return upsertList;
    }

    /*JHF Appirio 3/17/16 Same for opportunity team member*/
    private List<OpportunityTeamMember> upsertOpportunityTeamMembers(List<Account> updatedAccounts, Set<Id> assignedTerritoryIds){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','upsertOpportunityTeamMembers');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '****  Inside '));
        system.debug('===assignedTerritoryIds======> '+assignedTerritoryIds);

        List<OpportunityTeamMember> upsertList = new List<OpportunityTeamMember>();
        Map<Id, List<TerritoryAssignmentTeamMember__c>> territoryIdToMembersMap = new Map<Id, List<TerritoryAssignmentTeamMember__c>>();
        Map<Id, List<Id>> accountIdToOppIdMap = new Map<Id, List<Id>>();
        List<Opportunity> updatedOpportunities = new List<Opportunity>();
        Map<Id, List<OpportunityTeamMember>> opportunityIdToMembersMap = new Map<Id, List<OpportunityTeamMember>>();

        for(TerritoryAssignmentTeamMember__c teamMember : queryTATMList(assignedTerritoryIds)){
                if(!territoryIdToMembersMap.containsKey(teamMember.TerritoryAssignment__c)){
                        territoryIdToMembersMap.put(teamMember.TerritoryAssignment__c, new List<TerritoryAssignmentTeamMember__c>());
                }
                territoryIdToMembersMap.get(teamMember.TerritoryAssignment__c).add(teamMember);
        }

        system.debug('===territoryIdToMembersMap======> '+territoryIdToMembersMap);

        for(Opportunity opp : [SELECT Id, status__c, AccountId FROM Opportunity where AccountId IN : updatedAccounts AND
                               isWon = false AND isClosed = false]){ //only open opportunities
            if(!accountIdToOppIdMap.containsKey(opp.AccountId)){
                accountIdToOppIdMap.put(opp.AccountId, new List<Id> ());
            }
            accountIdToOppIdMap.get(opp.AccountId).add(opp.Id);
            updatedOpportunities.add(opp);
        }
        system.debug('====updatedOpportunities======> ' + updatedOpportunities);

        if(updatedOpportunities.size() > 0){
            for(OpportunityTeamMember teamMember : [SELECT Id, OpportunityId, UserId
                                                     FROM OpportunityTeamMember
                                                     where OpportunityId IN : updatedOpportunities]){
                if(!opportunityIdToMembersMap.containsKey(teamMember.OpportunityId)){
                    opportunityIdToMembersMap.put(teamMember.OpportunityId, new List<OpportunityTeamMember> ());
                }
                opportunityIdToMembersMap.get(teamMember.OpportunityId).add(teamMember);
            }
        }

        system.debug('====opportunityIdToMembersMap======> '+ opportunityIdToMembersMap);

        for(Account acc : updatedAccounts){
            if(territoryIdToMembersMap.get(acc.TerritoryCode__c) != null){
                for(Id key : accountIdToOppIdMap.keyset()){
                    if (key == acc.id){
                        for (Id oppId : accountIdToOppIdMap.get(acc.id)){
                            upsertList.addAll(getOpportunityTeamMembers(oppId, opportunityIdToMembersMap.get(oppId), territoryIdToMembersMap.get(acc.TerritoryCode__c)));
                        }
                    }
                }
            }
        }

        system.debug('====upsertList======> '+ upsertList);
        return upsertList;
    }


    /*
        ** @author : Parul Gupta
        ** @date : 09/10/2015
        ** @description : Returns New account team members
        ** @paramaters : Account Id, List of Account_Team_Member__c, List of TerritoryAssignmentTeamMember__c
        ** @returns : nothing
        */
    private List<Account_Team_Member__c> getAccountTeamMembers(Id accountId, List<Account_Team_Member__c> accountTeamMembers,List<TerritoryAssignmentTeamMember__c> territoryTeamMembers){
        List<Account_Team_Member__c> newAccTeamMembers = new List<Account_Team_Member__c>();
        for(TerritoryAssignmentTeamMember__c territoryTM : territoryTeamMembers){
            Account_Team_Member__c accTM = alreadyExists(territoryTM.TeamMember__c, accountTeamMembers);
            if(accTM == null){
                accTM = new Account_Team_Member__c();
                system.debug('Create New Account Team Member record for ' + territoryTM.TeamMember__c);
            }
            accTM.UserId__c = territoryTM.TeamMember__c;
            accTM.TeamMemberRole__c = territoryTM.TeamMemberRole__c;
            accTM.AccountId__c = accountId;
            accTM.AccountAccessLevel__c = territoryTM.AccountAccessLevel__c;
            accTM.CaseAccessLevel__c = territoryTM.CaseAccessLevel__c;
            accTM.OpportunityAccessLevel__c = territoryTM.OpportunityAccessLevel__c;
            newAccTeamMembers.add(accTM);
        }
        return newAccTeamMembers;
    }

    /*JHF Appirio 3/17/16 Same for opportunity team member*/
    private List<OpportunityTeamMember> getOpportunityTeamMembers(Id opportunityId, List<OpportunityTeamMember> opportunityTeamMembers,List<TerritoryAssignmentTeamMember__c> territoryTeamMembers){
        List<OpportunityTeamMember> newOppTeamMembers = new List<OpportunityTeamMember>();
        for(TerritoryAssignmentTeamMember__c territoryTM : territoryTeamMembers){
            OpportunityTeamMember oppTM = alreadyExistsOTM(territoryTM.TeamMember__c, opportunityTeamMembers);
            if(oppTM == null){
                oppTM = new OpportunityTeamMember();
                oppTM.OpportunityId = opportunityId;
                oppTM.UserId = territoryTM.TeamMember__c;
                //oppTM.OpportunityAccessLevel = territoryTM.OpportunityAccessLevel__c; not writeable on Standard OpportunityTeamMember, see updateOpportunityShares()
                system.debug('Create New Opportunity Team Member record for ' + territoryTM.TeamMember__c);
            }
            oppTM.TeamMemberRole = territoryTM.TeamMemberRole__c;
            newOppTeamMembers.add(oppTM);
        }
        return newOppTeamMembers;
    }

    /* JHF Appirio 3/18/16
        OpportunityAccessLevel is not writeable on the standard OpportunityTeamMember,
        so use solution from http://blog.jeffdouglas.com/2011/03/17/opportunityaccesslevel-not-writable/
    */
    private List<OpportunityShare> updateOpportunityShares(List<OpportunityTeamMember> updatedOTM, Set<Id> assignedTerritoryIds){
        List<OpportunityShare> OpportunitySharesToUpdate = new List<OpportunityShare>();

        Map<Id, List<TerritoryAssignmentTeamMember__c>> territoryIdToMembersMap = new Map<Id, List<TerritoryAssignmentTeamMember__c>>();
        Map<Id, List<OpportunityTeamMember>> OTMIdToMembersMap = new Map<Id, List<OpportunityTeamMember>>();
        Map<Id, List<OpportunityShare>> OppIdToShareMap = new Map<Id, List<OpportunityShare>>();
        Set<Id> updatedOpportunities = new Set<Id>();
        Set<Id> teamMembers = new Set<Id>();
        Map<String, String> OSLookup = new Map<String, String>{'Read/Write' => 'Edit', 'Read Only' => 'Read'};


        for (OpportunityTeamMember otm : updatedOTM){
            if(!OTMIdToMembersMap.containsKey(otm.UserId)){
                    OTMIdToMembersMap.put(otm.UserId, new List<OpportunityTeamMember>());
            }
            OTMIdToMembersMap.get(otm.UserId).add(otm);
            updatedOpportunities.add(otm.OpportunityId);
            teamMembers.add(otm.UserId);
        }

        List<OpportunityShare> oppShares = new List<OpportunityShare>();
        oppShares = [SELECT Id, UserOrGroupId, OpportunityId, OpportunityAccessLevel from OpportunityShare
                     WHERE OpportunityId in : updatedOpportunities AND UserOrGroupId in : teamMembers AND RowCause = 'Team'];
        for(OpportunityShare os : oppShares){
            if(!OppIdToShareMap.containsKey(os.OpportunityId)){
                    OppIdToShareMap.put(os.OpportunityId, new List<OpportunityShare>());
            }
            OppIdToShareMap.get(os.OpportunityId).add(os);
        }

        //Find OpportunityShare records for the upserted OpportunityTeamMembers whose OpportunityAccessLevel != the TA Team Member OpportunityAccessLevel__c
        for(TerritoryAssignmentTeamMember__c tm : queryTATMList(assignedTerritoryIds)){
            if(OTMIdToMembersMap.containsKey(tm.TeamMember__c)){
                for(OpportunityTeamMember otm : OTMIdToMembersMap.get(tm.TeamMember__c)){
                    if(OppIdToShareMap.containsKey(otm.OpportunityId)){
                        for(OpportunityShare os : OppIdToShareMap.get(otm.OpportunityId)){
                            if(os.UserOrGroupId == tm.TeamMember__c){
                                if(OSLookup.containsKey(tm.OpportunityAccessLevel__c) && os.OpportunityAccessLevel != OSLookup.get(tm.OpportunityAccessLevel__c)){
                                    system.debug('^^^ Updating OpportunityShare ' + os.Id + ', Opportunity = ' + os.OpportunityId + ', UserOrGroupId=' + os.UserOrGroupId +
                                                 ', OpportunityAccessLevel: TA_TM=' + tm.OpportunityAccessLevel__c + ', oppShare=' + os.OpportunityAccessLevel);
                                    OpportunityShare oppShare = new OpportunityShare();
                                    oppShare.Id = os.Id;
                                    oppShare.OpportunityAccessLevel = OSLookup.get(tm.OpportunityAccessLevel__c);
                                    OpportunitySharesToUpdate.add(oppShare);
                                }
                            }
                        }
                    }
                }
            }
        }
        if(OpportunitySharesToUpdate.size() > 0){
            system.debug('===OpportunitySharesToUpdate======> ' + OpportunitySharesToUpdate);
        }
        else {
            system.debug('===No OpportunitySharesToUpdate======');
        }
        return OpportunitySharesToUpdate;
    }

    /*
        ** @author : Parul Gupta
        ** @date : 09/10/2015
        ** @description : Checks if user is already a account team member
        ** @paramaters : UserId, List of Account Team Members
        ** @returns : Account Team Member
        */
    private Account_Team_Member__c alreadyExists(Id userId, List<Account_Team_Member__c> accountTeamMembers){
        //system.debug('ID Check: ' + userId);
        if(accountTeamMembers != null) {
            for(Account_Team_Member__c accTM : accountTeamMembers){
                system.debug('Existing Account Team Member ' + accTM);
                if(userId == accTM.UserId__c){
                    return accTM;
                }
            }
        }
        return null;
    }

    /*JHF Appirio 3/17/16 Same for opportunity team member*/
    private OpportunityTeamMember alreadyExistsOTM(Id userId, List<OpportunityTeamMember> opportunityTeamMembers){
        //system.debug('ID Check: ' + userId);
        if(opportunityTeamMembers != null) {
            for(OpportunityTeamMember oppTM : opportunityTeamMembers){
                system.debug('Existing Opportunity Team Member ' + oppTM);
                if(userId == oppTM.UserId){
                    return oppTM;
                }
            }
        }
        return null;
    }

    /*
    ** @author : Jeff L (Appirio)
    ** @date : 01/27/2016
    ** @description : builds the query needed for the Territory Assignment Batch class,
                      this query gathers all the Territory Assignment codes that need
                      to be processed and finds all accounts that would meet their requirements
    ** @paramaters : nothing
    ** @returns : String that represents the query that will be performed to loosely find all accounts
    */
    public static string buildBatchQuery(){
        //First thing to do is find all the unprocesed Territory Assigment records to start building our query
        String tQuery;

        Set<String> zipCodeSet = new Set<String>();
        Set<String> namedAccountSet = new Set<String>();
        batchTerritoryAssignmentCodeList = new List<TerritoryAssignmentCode__c>();
        for(TerritoryAssignmentCode__c tac : [Select Id, AccountCountry__c, AccountGroup__c,NamedAccount__c, SalesChannel__c,Segment__c,
                                                //PostingZipCodeStart__c, PostingZipCodeEnd__c, Zip_Code_Start_Number_del__c, Zip_Code_End_Number_del__c,
                                                TerritoryAssignment__c, TerritoryAssignment__r.OwnerId
                                                FROM TerritoryAssignmentCode__c WHERE TerritoryAssignment__r.Processed__c = false ]){

            Boolean addToList = false;
            /*JHF Appirio removed for I-190489
            if(tac.Zip_Code_Start_Number_del__c != null && tac.Zip_Code_End_Number_del__c != null){
                addToList = true;
                zipCodeSet.add('Shipping_Postal_Code_Number__c >= ' + tac.Zip_Code_Start_Number_del__c + ' AND Shipping_Postal_Code_Number__c <= ' + tac.Zip_Code_End_Number_del__c);
            }*/
            if(tac.NamedAccount__c != null){
                addToList = true;
                namedAccountSet.add(tac.NamedAccount__c);
            }

            if(addToList){
                batchTerritoryAssignmentCodeList.add(tac);
            }
        }
        //At this point we have the details that we need to be able to write our account query now.
        //this next logic all deals with putting together the query to get our list of accounts

        tQuery = 'SELECT Id,ShippingStreet,Phone,AccountStatus__c,ShippingCity,ShippingState,';
        tQuery +='CustomerNumber__c,CustomerDate__c,CustomerLapsedDate__c, TerritoryCode__c,';
        tQuery +='ShippingPostalCode,ShippingCountry, BillingPostalCode,AccountGroup__c,';
        tQuery +='SalesChannel__c,Segment__c,OwnerId,AccountID__c,DoNotReassign__c FROM Account WHERE';

        boolean needsOr = false;
        boolean hasWhereClause = false;

        //Lets do the Named account piece first
        if(namedAccountSet.size() > 0){
            tQuery += ' AccountID__c in (';
            for(String name : namedAccountSet){
                tQuery += '\'' + name + '\',';
            }
            //get rid of the last comma
            tQuery = tQuery.left(tQuery.length() - 1);
            tQuery += ')';

            needsOr = true;
            hasWhereClause = true;
        }

        //Now put together the zipcode checking part of the query
        /*JHF Appirio removed for I-190489
        if(zipCodeSet.size() > 0){
            if(needsOr){
                tQuery += ' OR ';
            }

            for(String zipString : zipCodeSet){
                tQuery += '(' + zipString +') OR ';
            }

            tQuery = tQuery.left(tQuery.length() - 4);
            hasWhereClause = true;
        }*/

        if(hasWhereClause == false){
            return null;
        } else {
            return tQuery+' LIMIT 50000 ';
        }
    }
}