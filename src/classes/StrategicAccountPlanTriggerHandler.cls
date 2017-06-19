/*
** @author : Cloud Sherpas Inc.
** @date : 03/07/2014
** @description : Account trigger class to handle CRUD events. 
*/
public without sharing class StrategicAccountPlanTriggerHandler extends BaseTriggerHandler{
    final String CLASSNAME = '\n\n**** StrategicAccountPlanTriggerHandler.METHODNAME()';
    private integer BatchSize = 0;
    public StrategicAccountPlanTriggerHelper helper;
    private Profile CurrentUserProfile;
    public static Boolean ExecuteTriggers = true;
    private static Integer RunCount = 0;
    public static Boolean FROM_INSERT = false;
    
    /*  
** @author : Cloud Sherpas Inc.
** @date : 03/07/2014
** @description : the class constructor method
** @paramaters : a Boolean value indicating if a trigger is executing or not, an Integer value indicating the number of records in the batch/list
** @returns : nothing
** @sample call : AccountTriggerHandler handler = new AccountTriggerHandler(Trigger.isExecuting, Trigger.size);
*/
    public StrategicAccountPlanTriggerHandler(boolean isExecuting, integer pTriggerSize){
        
        // trigger is executing
        TriggerIsExecuting = isExecuting;
        
        // set batch size
        BatchSize = pTriggerSize;//
        
        // set current User profile
        try{
            //StrategicAccountPlanTriggerHelper helper = new StrategicAccountPlanTriggerHelper();
        }catch(Exception e){
        }
        
        /*
note - developer may want to create new or extent the base helper class specific to an sObject (i.e. AccountTriggerHelper)
*/
    }
    
    /*
** @author : Cloud Sherpas Inc.
** @date : 
** @description :  this method handles the 'before insert' event for the trigger; it's purpose is to ...
** @paramaters : an array of 
** @returns : nothing
*/
    public void OnBeforeInsert(List<Strategic_Account_Plan__c> newStrategicAccountPlanList){
        if (Personal_Settings__c.getInstance().Trigger_Strategic_Account_Plan__c ==false){
            return; // If triggers are off, then exit the method
        }
        
        helper = new StrategicAccountPlanTriggerHelper();
        helper.checkAccount(newStrategicAccountPlanList);
        
        checkCurrentUserAccessOnStrategicPlan(newStrategicAccountPlanList);
    }
    
    /*   
** @author : Cloud Sherpas Inc.
** @date : 09/13/2014
** @description :  this method handles the 'after insert' event for the trigger; it's purpose is to ...
** @paramaters : an array of 
** @returns : nothing
*/
    public void OnAfterInsert(map<ID, Strategic_Account_Plan__c> newStrategicAccountPlanMap){
        if (Personal_Settings__c.getInstance().Trigger_Strategic_Account_Plan__c ==false){
            return; // If triggers are off, then exit the method
        }
        
        helper = new StrategicAccountPlanTriggerHelper();
        helper.updateBillingAgency(newStrategicAccountPlanMap);
        FROM_INSERT = true;
    }
    
    /*    
**  @author : Cloud Sherpas Inc.
**  @date : 03/07/2014
**  @description :  this method handles the 'before update' event for the trigger; it's purpose is to ...
**  @paramaters : array of 
**  @returns : nothing
*/
    public void OnBeforeUpdate(List<Strategic_Account_Plan__c> newStrategicAccountPlanList){
        if (Personal_Settings__c.getInstance().Trigger_Strategic_Account_Plan__c ==false){
            return; // If triggers are off, then exit the method
        }
        
        helper = new StrategicAccountPlanTriggerHelper();
        helper.checkAccount(newStrategicAccountPlanList);   
        checkCurrentUserAccessOnStrategicPlan(newStrategicAccountPlanList);     
    }
    /*   
**  @author : Cloud Sherpas Inc.
**  @date : 03/07/2014
**  @description :  this method handles the 'after update' event for the trigger; it's purpose is to ...
**  @paramaters : array of 
**  @returns : nothing
*/
    public void OnAfterUpdate(map<ID, Strategic_Account_Plan__c> newStrategicAccountPlanMap){
        if (Personal_Settings__c.getInstance().Trigger_Strategic_Account_Plan__c ==false){
            return; // If triggers are off, then exit the method
        }
        
        helper = new StrategicAccountPlanTriggerHelper();
        if(StrategicAccountPlanTriggerHandler.RunCount > 0 && !FROM_INSERT){
            return;
        }
        RunCount++;
        helper.updateBillingAgency(newStrategicAccountPlanMap);
    }
    
    /*  
**  @author : Cloud Sherpas Inc.
**  @date : 03/07/2014
**  @description :  this method handles the 'before delete' event for the trigger; it's purpose is to ...
**  @paramaters : array of
**  @returns : nothing
*/
    public void OnBeforeDelete(Account[] pOldAccounts, map<ID, SObject> pAccountMapOld){
    }
    
    /*
**  @author : Cloud Sherpas Inc.
**  @date : 03/07/2014
**  @description :  this method handles the 'after delete' event for the trigger; it's purpose is to ...
**  @paramaters : array of
**  @returns : nothing
*/  
    public void OnAfterDelete(Account[] pOldAccounts, map<ID, SObject> pAccountMapOld){
    }
    
    /*  
**  @author : Cloud Sherpas Inc.
**  @date : 03/07/2014
**  @description :  this method handles the 'Undeleted' event for the trigger; it's purpose is to ...
**  @paramaters : array of 
**  @returns : nothing
*/       
    public void OnUndeleted(){
    }
    
    /*  
**  @author : Appirio
**  @date : 11/Jun/2015
**  @description :  This method restricts the access of users other than Account Owner, Team, Manager.
**  @paramaters : list of newly inserted records 
**  @returns : nothing
*/      
    
    public void checkCurrentUserAccessOnStrategicPlan(List<Strategic_Account_Plan__c> newStrategicAccountPlanList){  
        set<Id> accountIds = new set<Id>();
        //Fetching account Ids
        for(Strategic_Account_Plan__c newStrategicPlan : newStrategicAccountPlanList){
            accountIds.add(newStrategicPlan.Account_Name__c);
        }
        //Fetching Account records to be used later in code
        map<id , Account> mapAllRealtedAccounts = new map<id , Account>([select OwnerId
                                                                         from Account
                                                                         where Id IN :accountIds ]);
        //Storing account owner Ids to be used later                                                                                
        set<Id> setAccountOwners = new set<Id>();
        for(Account a : mapAllRealtedAccounts.values()){
            setAccountOwners.add(a.OwnerId);
        }
        //fetching Details of the Account owner roles 
        map< Id ,User> mapAccountUsers = new map< Id ,User>([Select  UserRole.Id , 
                                                             UserRole.Name 
                                                             from User u 
                                                             where Id IN :setAccountOwners]);   
        
        set<Id> roleIds = new set<Id>{UserInfo.getUserRoleId()};
        //get the roles below the role of the Logged in User
        set<Id> setOfSubs= getAllSubRoleIds(roleIds);
        //Fetching Account team member of the Accounts   
        system.debug('Check *****************' + accountIds.size()); 
        system.debug('Check *****123************' + accountIds.size()); 
        map<id , Account_Team_Member__c> mapAllRelatedAccountTeamMember= new map<id , Account_Team_Member__c>([select UserId__c ,
                                                                                                               AccountId__c 
                                                                                                               from Account_Team_Member__c
                                                                                                               where AccountId__c IN :accountIds ]);                                                                                                             
        map<id , set<Id>> mapAccountToAccountTeamMemberList = new map<id , set<Id>>();      
        for(Account_Team_Member__c accTeamMember : mapAllRelatedAccountTeamMember.values()){
            if(!mapAccountToAccountTeamMemberList.containskey(accTeamMember.AccountId__c ))
                mapAccountToAccountTeamMemberList .put(accTeamMember.AccountId__c , new set<Id>() );
            
            mapAccountToAccountTeamMemberList.get(accTeamMember.AccountId__c).add(accTeamMember.UserId__c);
        }
        
        for(Strategic_Account_Plan__c newStrategicPlan : newStrategicAccountPlanList){
            Boolean flag = false;
            //Checking if the logged in user is the Account owner
            if(UserInfo.getUserId() == mapAllRealtedAccounts .get(newStrategicPlan.Account_Name__c).OwnerId)
                flag = true;
            
            //Checking if the logged in user is in the Account Team Member List on Account
            if(mapAccountToAccountTeamMemberList .containskey(newStrategicPlan.Account_Name__c) && flag!= true){           
                for(Id userId : mapAccountToAccountTeamMemberList .get(newStrategicPlan.Account_Name__c)){
                    if(userId == UserInfo.getUserId() ) {  
                        flag = true;
                        break;
                    }
                }
                
            }
            //Checking if the current user is above in the role hierachy of the Account owner
            Id accountOwner = mapAllRealtedAccounts .get(newStrategicPlan.Account_Name__c).OwnerId;
            
            if(mapAccountUsers.containskey(accountOwner) && setOfSubs.contains(mapAccountUsers.get(accountOwner).UserRole.Id))
                flag = true;

            //added per I-187239 to give access to Sales Ops TA profiles
            if(newStrategicPlan.Current_User_Profile__c == 'Sales Operations (TA)' || newStrategicPlan.Current_User_Profile__c == 'Sales Operations (EU) TA')
                flag = true;
                
            //changed start by Gaurav Gupta on 19 Jan 2017 for S-461668
            list<PermissionSetAssignment> sAPList = [SELECT PermissionSetId,PermissionSet.Name 
                              FROM PermissionSetAssignment 
                              WHERE AssigneeId= :userinfo.getUserID()
                              AND PermissionSet.Name  = 'PPC_Reps_Access_To_SAP' LIMIT 1] ;
            if(sAPList.size() > 0)
                flag = true;
            //changed end by Gaurav Gupta on 19 Jan 2017 for S-461668
            
            if(flag != true)
                newStrategicPlan .addError('You have insufficient access to Create or Edit this object'); 
        }
        
    }
    
    /*  
**  @author : Appirio
**  @date : 11/Jun/2015
**  @description :  get the Roles below the set of roles passed
**  @paramaters : set of roles Id
**  @returns : set of ids of the roles below the current set of roles
*/      
    
    public static set<Id> getAllSubRoleIds(set<Id> roleIds) {
        set<Id> currentRoleIds = new set<Id>();
        
        // get all of the roles underneath the passed roles
        for(UserRole userRole :[select Id from UserRole where ParentRoleId IN :roleIds AND ParentRoleID != null]){
            currentRoleIds.add(userRole.Id);
        }
        
        // we need to get more rolls by recursion
        if(currentRoleIds.size() > 0){
            currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
        }
        return currentRoleIds;
    }   
    
    
}