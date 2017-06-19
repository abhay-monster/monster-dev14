/*
** @author : Cloud Sherpas Inc.
** @date : 03/07/2014
** @description : Account trigger class to handle CRUD events. 
*/
public without sharing class AccountTeamMemberTriggerHandler extends BaseTriggerHandler{ 

    final String CLASSNAME = '\n\n**** AccountTeamMemberTriggerHandler.METHODNAME()';
    private integer BatchSize = 0;
    private TriggerHelper helper;
    public static boolean CanThrowError=true; // Also used in class TriggerHelperWithoutSharing. So that users can delete memembers via code but not manually.

/*  
** @author : Cloud Sherpas Inc.
** @date : 03/07/2014
** @description : the class constructor method
** @paramaters : a Boolean value indicating if a trigger is executing or not, an Integer value indicating the number of records in the batch/list
** @returns : nothing
** @sample call : AccountTeamMemberTriggerHandler handler = new AccountTeamMemberTriggerHandler(Trigger.isExecuting, Trigger.size);
*/
    public AccountTeamMemberTriggerHandler(boolean isExecuting, integer pTriggerSize){
        //
        // trigger is executing
        TriggerIsExecuting = isExecuting;
        
        // set batch size
        BatchSize = pTriggerSize;
        
        // set current User profile
       //TimW 9/10/14 Removed as not used and extraneous query Profile currentUserProfile = [Select Name From Profile where Id = :UserInfo.getProfileId()];
        
        // intantiate new trigger helper
        helper = TriggerHelper.NewTriggerHelper(''); // TimW 9/10/14 Removed reference to currentUserProfile.name
        /*
            note - developer may want to create new or extent the base helper class specific to an sObject (i.e. AccountTriggerHelper)
        */
    }
    
/*
** @author : Cloud Sherpas Inc.
** @date : 03/07/2014
** @description :  this method handles the 'before insert' event for the trigger; it's purpose is to ...
** @paramaters : an array of Account objects
** @returns : nothing
*/
    public void OnBeforeInsert(Account_Team_Member__c[] pAccountTeamMember){
        if (Personal_Settings__c.getInstance().trigger_account_team_members__c==false){
            return; // If triggers are off, then exit the method
        }
        
        set<Id> setAccountIds = new set<Id>();
        
        for(Account_Team_Member__c accTeamMember : pAccountTeamMember){
            setAccountIds.add(accTeamMember.AccountId__c);
        }
        
        Map<id,Account> mapRelatedAccounts = new Map<id,Account>([select id, OwnerId from Account
                                                                  where Id IN:setAccountIds]);
                                                                  
        for(Account_Team_Member__c accTeamMember : pAccountTeamMember){
            accTeamMember.OwnerId = mapRelatedAccounts.get(accTeamMember.AccountId__c).OwnerId;
        }
                                                                  
        
        checkOrganizationForTAProfile(pAccountTeamMember);
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeInsert');
        preventDuplicacy(pAccountTeamMember);
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        
            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                // <write code here> 
                //helper.updateAccountDataLastTeamed(pAccountTeamMember);           
                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                */
            }               
        
    }
    
/*
** @author :       Jyoti Agarwal
** @date   :       10 June 2015  
** @description :  This method handles the 'before insert' event for the trigger
                   It prevenmts insertion of duplicaye team members 
** @paramaters :   Array of AccountTeamMembers
** @returns :      Void
*/    
    
    private static void preventDuplicacy(List<Account_Team_Member__c> memberLst){
        
        Map<Id,List<Account_Team_Member__c>> accountIdToMembersMap = new Map<Id,List<Account_Team_Member__c>>();
        Set<Id> userIdSet = new Set<Id>();
        Set<Id> accountIdSet = new Set<Id>();
        
        // To store USer IDs And AcountIds for the inserted Account Team members
        for(Account_Team_Member__c member : memberLst){
            
            userIdSet.add(member.UserId__c);
            accountIdSet.add(member.AccountId__c);
        }
        
        // To create accountIdToMembersMap which stores account id and related list of account team members
        for(Account_Team_Member__c teamMember : [SELECT Id,UserId__c,TeamMemberRole__c ,AccountId__c
                                                 FROM Account_Team_Member__c WHERE UserId__c IN :userIdSet
                                                 AND AccountId__c IN : accountIdSet]){
                                                    
             if(accountIdToMembersMap.containsKey(teamMember.AccountId__c)){ 
                
                accountIdToMembersMap.get(teamMember.AccountId__c).add(teamMember);
             }else{
                 
                 accountIdToMembersMap.put(teamMember.AccountId__c, new List<Account_Team_Member__c> {teamMember});
             }                                      
        }
        
        // To check if account team memeber with same user Id and role already exists on the account
        for(Account_Team_Member__c member : memberLst){
            
            if(accountIdToMembersMap.containsKey(member.AccountId__c)){
                
                List<Account_Team_Member__c> acountTeamMemberLst = accountIdToMembersMap.get(member.AccountId__c);
                for(Account_Team_Member__c teamMember : acountTeamMemberLst){
                    
                    if(teamMember.UserId__c == member.UserId__c && teamMember.TeamMemberRole__c == member.TeamMemberRole__c 
                        && teamMember.AccountId__c == member.AccountId__c){
                            
                            member.addError(Label.Duplicate_Account_Team);
                            break;
                        }
                }
            }
        }
        
        
    }

/*   
** @author : Cloud Sherpas Inc.
** @date : 03/07/2014
** @description :  this method handles the 'after insert' event for the trigger; it's purpose is to ...
** @paramaters : an array of Account_Team_Member__c objects
** @returns : nothing
*/
    public void OnAfterInsert(Account_Team_Member__c[] pAccountTeamMember){
        if (Personal_Settings__c.getInstance().trigger_account_team_members__c==false){
            return; // If triggers are off, then exit the method
        }        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
                
        
            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                
                   helper.CreateAccountTeamMembers(pAccountTeamMember);
                
                
                
                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                */              
            }               
        
    }

/*    
**  @author : Cloud Sherpas Inc.
**  @date : 03/07/2014
**  @description :  this method handles the 'before update' event for the trigger; it's purpose is to ...
**  @paramaters : array of old Account_Team_Member__c objects, array of new Account_Team_Member__c object, map of new Account_Team_Members, map of old Account_Team_Members
**  @returns : nothing
*/
    public void OnBeforeUpdate(Account_Team_Member__c[] pOldAccountTeamMembers, Account_Team_Member__c[] pUpdatedAccountTeamMembers, map<ID, Account_Team_Member__c> pAccountIdToOldAccountMap, map<ID, Account_Team_Member__c> pAccountIdToUpdatedAccountMap){     
        if (Personal_Settings__c.getInstance().trigger_account_team_members__c==false){
            return; // If triggers are off, then exit the method
        }
        checkOrganizationForTAProfile(pUpdatedAccountTeamMembers);        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeUpdate');        
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        /*set<Id> accountIdSet = new set<Id>();
        for(Account_Team_Member__c atm : pUpdatedAccountTeamMembers){
            accountIdSet.add(atm.AccountId__c);
        }
        
        map<Id,Account> accountIdToAccountMap = new map<Id,Account>([SELECT Id, PrimaryServiceRep__c FROM Account WHERE Id IN : accountIdSet]);
        system.debug(LoggingLevel.DEBUG, METHODNAME + '\n\nACCOUNT ID TO ACCOUNT MAP :: ' + accountIdToAccountMap + '\n\n');
        list<Account> accountsToUpdateList = new list<Account>();
        */
        
        //preventDuplicacy(pUpdatedAccountTeamMembers);

        
            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                
                for(Account_Team_Member__c oAccountTeamMembers : pUpdatedAccountTeamMembers){
                    if(pAccountIdToOldAccountMap.get(oAccountTeamMembers.Id).TeamMemberRole__c == 'Primary Sales Rep' && pAccountIdToUpdatedAccountMap.get(oAccountTeamMembers.Id).TeamMemberRole__c != 'Primary Sales Rep'){
                        if(pAccountIdToUpdatedAccountMap.get(oAccountTeamMembers.Id).TeamMemberRole__c != 'Unassigned'){
                           // throw BaseApplicationException.NewException(METHODNAME, 'Cannot remove Primary Sales Rep by editing Team Members Role');
                        }
                        
                        if(pAccountIdToUpdatedAccountMap.get(oAccountTeamMembers.Id).TeamMemberRole__c == 'Unassigned'){
                            oAccountTeamMembers.TeamMemberRole__c = 'Sales Rep';
                        }
                    }
                    
                    /*system.debug(LoggingLevel.DEBUG, METHODNAME + '\n\nOLD TEAM MEMBER ROLE :: ' + pAccountIdToOldAccountMap.get(oAccountTeamMembers.Id).TeamMemberRole__c + '\n\nNew TEAM MEMBER ROLE :: ' + pAccountIdToUpdatedAccountMap.get(oAccountTeamMembers.Id).TeamMemberRole__c + '\n\n');
                    if(pAccountIdToOldAccountMap.get(oAccountTeamMembers.Id).TeamMemberRole__c == 'Primary Service Rep' && pAccountIdToUpdatedAccountMap.get(oAccountTeamMembers.Id).TeamMemberRole__c != 'Primary Service Rep'){
                        
                        if(accountIdToAccountMap.containskey(oAccountTeamMembers.AccountId__c)){
                            system.debug(LoggingLevel.DEBUG, METHODNAME + '\n\nACCOUNT ID TO ACCOUNT MAP CONTAINS KEY :: ' + oAccountTeamMembers.AccountId__c + '\n\n');
                            system.debug(LoggingLevel.DEBUG, METHODNAME + '\n\nACCOUNT PRIMARY SERVICE REP BEFORE MOD :: ' + accountIdToAccountMap.get(oAccountTeamMembers.AccountId__c).PrimaryServiceRep__c  + '\n\n');
                            accountIdToAccountMap.get(oAccountTeamMembers.AccountId__c).PrimaryServiceRep__c = null;
                            system.debug(LoggingLevel.DEBUG, METHODNAME + '\n\nACCOUNT PRIMARY SERVICE REP AFTER MOD :: ' + accountIdToAccountMap.get(oAccountTeamMembers.AccountId__c).PrimaryServiceRep__c  + '\n\n');
                            accountsToUpdateList.add(accountIdToAccountMap.get(oAccountTeamMembers.AccountId__c));
                        }                       
                    }*/
                }
                
                /*if(!accountsToUpdateList.isEmpty()){
                    system.debug(LoggingLevel.DEBUG, METHODNAME + '\n\nACCOUNT TO UPDATE LIST IS NOT NULL OR EMPTY :: ' + accountsToUpdateList.size() + '\n\n');
                    system.debug(LoggingLevel.DEBUG, METHODNAME + '\n\nACCOUNT TO UPDATE LIST :: ' + accountsToUpdateList + '\n\n');
                    
                    update accountsToUpdateList;
                    
                }*/
                
                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                */             
            }
              
    }
/*   
**  @author : Cloud Sherpas Inc.
**  @date : 03/07/2014
**  @description :  this method handles the 'after update' event for the trigger; it's purpose is to ...
**  @paramaters : array of old Account_Team_Member__c objects, array of new Account_Team_Member__c object, map of new Account_Team_Members, map of old Account_Team_Members
**  @returns : nothing
*/
    public void OnAfterUpdate(Account_Team_Member__c[] pOldAccountTeamMembers, Account_Team_Member__c[] pUpdatedAccountTeamMembers, map<ID, Account_Team_Member__c> pAccountIdToOldAccountMap, map<ID, Account_Team_Member__c> pAccountIdToUpdatedAccountMap){
        if (Personal_Settings__c.getInstance().trigger_account_team_members__c==false){
            return; // If triggers are off, then exit the method
        }     

        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        set<Id> accountIdSet = new set<Id>();
        for(Account_Team_Member__c atm : pUpdatedAccountTeamMembers){
            accountIdSet.add(atm.AccountId__c);
        }
        
        map<Id,Account> accountIdToAccountMap = new map<Id,Account>([SELECT Id, PrimaryServiceRep__c FROM Account WHERE Id IN : accountIdSet]);
        list<Account> accountsToUpdateList = new list<Account>();
        
        
            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){              
                
                helper.UpdatePrimaryServiceRepOnAccount(pUpdatedAccountTeamMembers, pAccountIdToOldAccountMap, pAccountIdToUpdatedAccountMap);
                
                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                */      
            }
        
    }

/*  
**  @author : Cloud Sherpas Inc.
**  @date : 03/07/2014
**  @description :  this method handles the 'before delete' event for the trigger; it's purpose is to ...
**  @paramaters : array of old Account objects, map of old Account_Team_Members
**  @returns : nothing
*/
    public void OnBeforeDelete(Account_Team_Member__c[] pOldAccountTeamMembers, map<Id, Account_Team_Member__c> pOldAccountTeamMemberMap){
        if (Personal_Settings__c.getInstance().trigger_account_team_members__c==false){
            return; // If triggers are off, then exit the method
        }
        checkOrganizationForTAProfile(pOldAccountTeamMembers);  
        if(SetSendToEmailFlag.fromTerritory){
            return;
        }      
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeDelete'); 
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        list<AccountTeamMember> accountTeamMemberToDelete = new list<AccountTeamMember>();
        list<Account> accountsToUpdateList = new list<Account>();
        
        map<Id,map<Id,Account>> userIdToMapAccountIdToAccountMap = new map<Id,map<Id,Account>>();
        
        set<Id> accountIdSet = new set<Id>();
             
        for(Account_Team_Member__c oAccountTeamMember : pOldAccountTeamMembers ){
            accountIdSet.add(oAccountTeamMember.AccountId__c);
        }
        
        map<Id,map<Id, AccountTeamMember>> accountIdToMapofUserIdToAccountTeamMemberListMap = new map<Id,map<Id, AccountTeamMember>>();
        
        list<Account> accountList = [SELECT Id, PrimaryServiceRep__c, (SELECT Id, UserId, TeamMemberRole FROM AccountTeamMembers) FROM Account WHERE ID IN : accountIdSet];
        
        for(Account oAccount : accountList){
            if(!oAccount.AccountTeamMembers.IsEmpty()){
                
                accountIdToMapofUserIdToAccountTeamMemberListMap.put(oAccount.Id, new map<Id, AccountTeamMember>()); 
                        
                for(AccountTeamMember atm : oAccount.AccountTeamMembers){
                    accountIdToMapofUserIdToAccountTeamMemberListMap.get(oAccount.Id).put(atm.UserId, atm);                 
                        
                    if(atm.TeamMemberRole == 'Primary Service Rep'){
                        if(userIdToMapAccountIdToAccountMap.ContainsKey(atm.UserId)){
                            userIdToMapAccountIdToAccountMap.get(atm.UserId).put(oAccount.Id, oAccount);
                        }
                        else{
                            userIdToMapAccountIdToAccountMap.put(atm.UserId, new map<Id, Account>());
                            userIdToMapAccountIdToAccountMap.get(atm.UserId).put(oAccount.Id, oAccount);                             
                        }
                    }
                }
            }
        }
                
        
            //if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                
                for(Account_Team_Member__c oAccountTeamMember : pOldAccountTeamMembers ){
                    if(oAccountTeamMember.TeamMemberRole__c == 'Primary Sales Rep'){
                        if(CanThrowError)
                            oAccountTeamMember.addError('Cannot Delete the Primary Sales Rep.Use the Primary Sales Rep field on Account to change this team member.');
                        //throw BaseApplicationException.NewException(METHODNAME, 'Cannot Delete the Primary Sales Rep');
                    }else{
                        if(accountIdToMapofUserIdToAccountTeamMemberListMap.containsKey(oAccountTeamMember.AccountId__c) && accountIdToMapofUserIdToAccountTeamMemberListMap.get(oAccountTeamMember.AccountId__c).containskey(oAccountTeamMember.UserId__c)){
                            
                            if(oAccountTeamMember.TeamMemberRole__c == 'Primary Service Rep'){
                                Account accountToUpdate=null;
                                if(userIdToMapAccountIdToAccountMap.containsKey(oAccountTeamMember.UserId__c) && userIdToMapAccountIdToAccountMap.get(oAccountTeamMember.UserId__c).containsKey(oAccountTeamMember.AccountId__c)){
                                    accountToUpdate = userIdToMapAccountIdToAccountMap.get(oAccountTeamMember.UserId__c).get(oAccountTeamMember.AccountId__c);
                                }
                                    
                                
                                if (accountToUpdate!=null){
                                    accountsToUpdateList.add(accountToUpdate);
                                }
                            }
                            
                            if(oAccountTeamMember.TeamMemberRole__c == accountIdToMapofUserIdToAccountTeamMemberListMap.get(oAccountTeamMember.AccountId__c).get(oAccountTeamMember.UserId__c).TeamMemberRole){
                                accountTeamMemberToDelete.add(accountIdToMapofUserIdToAccountTeamMemberListMap.get(oAccountTeamMember.AccountId__c).get(oAccountTeamMember.UserId__c));                         
                            }
                        }
                    }
                }
                
                if(!accountsToUpdateList.IsEmpty()){
                    for(Account oAccount : accountsToUpdateList){
                        oAccount.PrimaryServiceRep__c = null;
                    }
                    
                    update accountsToUpdateList;
                }
                delete accountTeamMemberToDelete;
                //helper.updateAccountDataLastUnteamed(pOldAccountTeamMembers);
                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                */      
            //}
        
    }

/*
**  @author : Cloud Sherpas Inc.
**  @date : 03/11/2014
**  @description :  this method handles the 'after delete' event for the trigger; it's purpose is to ...
**  @paramaters : array of old Account_Team_Member__c objects, map of old Account_Team_Members
**  @returns : nothing
*/  
    public void OnAfterDelete(list<Account_Team_Member__c> oldCustomAccTeamMembers){
        if (Personal_Settings__c.getInstance().trigger_account_team_members__c==false){
            return; // If triggers are off, then exit the method
        }
        system.debug('run after update>>>'+SetSendToEmailFlag.runAfterUpdate);
        if(SetSendToEmailFlag.fromTerritory || SetSendToEmailFlag.runAfterUpdate){
            return;
        }        
        
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterDelete');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        
            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                
                helper.UpdatePrimaryServiceRep(oldCustomAccTeamMembers);
                helper.updateAccountDataLastUnteamed(oldCustomAccTeamMembers);
                       
                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                */      
            }
        
    }

/*  
**  @author : Cloud Sherpas Inc.
**  @date : 03/07/2014
**  @description :  this method handles the 'Undeleted' event for the trigger; it's purpose is to ...
**  @paramaters : array of new Account_Team_Member__c object
**  @returns : nothing
*/      
    public void OnUndeleted(Account_Team_Member__c[] pUndeletedAccountTeamMembers){
        if (Personal_Settings__c.getInstance().trigger_account_team_members__c==false){
            return; // If triggers are off, then exit the method
        }        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnUndeleted');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        
            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                // <write code here>
                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                */      
            }
        
    }
    
    /*  
    **  @author : Appirio 
    **  @date : 09/July/2015
    **  @description :  
    **  @paramaters : array of new Account_Team_Member__c object
    **  @returns : nothing
    */     
    public void checkOrganizationForTAProfile(Account_Team_Member__c[] pUndeletedAccountTeamMembers) {
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        //system.assert(false , profileName);
        system.debug('Profile Name :: '+profileName);
        //Added xxx to Sales Ops TA profile below to temporarily allow the profile to change acct teams globally per I-227046
        if(profileName == 'xxxSales Operations (TA)'){
            User u = [select Organisation__c from user where id = : UserInfo.getUserId() ];
            Set<id> setAccountIds = new Set<Id>();
            for(Account_Team_Member__c accTeamMember : pUndeletedAccountTeamMembers){
                setAccountIds.add(accTeamMember.AccountId__c);
            }
            
            Map< Id ,Account> mapAccountIds = new Map< Id ,Account>([Select Organization__c from Account where Id IN : setAccountIds]);
            for(Account_Team_Member__c accTeamMember : pUndeletedAccountTeamMembers){
                if((mapAccountIds.containsKey(accTeamMember.AccountId__c) && 
                   mapAccountIds.get(accTeamMember.AccountId__c).Organization__c != u.Organisation__c) 
                   || u.Organisation__c == Null || u.Organisation__c == ''){
                    accTeamMember.adderror('You can only update Account Teams for Accounts which are in your org.');
                }
            }
        }
    }    
    
     
}