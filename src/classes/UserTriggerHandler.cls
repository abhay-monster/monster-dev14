/*
** @author : Cloud Sherpas Inc.
** @date : 04/23/2014
** @description : User trigger class to handle CRUD events. 
*/
public with sharing class UserTriggerHandler extends BaseTriggerHandler{ 
    
    final String CLASSNAME = '\n\n**** UserTriggerHandler.METHODNAME()';
    private integer BatchSize = 0;
    //private boolean TriggerIsExecuting;
    private UserTriggerHelper helper;
/*  
** @author : Cloud Sherpas Inc.
** @date : 04/23/2014
** @description : the class constructor method
** @paramaters : a Boolean value indicating if a trigger is executing or not, an Integer value indicating the number of records in the batch/list
** @returns : nothing
** @sample call : UserTriggerHandler handler = new UserTriggerHandler(Trigger.isExecuting, Trigger.size);
*/
    public UserTriggerHandler(boolean isExecuting, integer pTriggerSize){
        
        // trigger is executing
        TriggerIsExecuting = isExecuting;
        
        // set batch size
        BatchSize = pTriggerSize;
        
        // set current User profile
        Profile currentUserProfile = [Select Name From Profile where Id = :UserInfo.getProfileId()];
        
        // intantiate new trigger helper
        helper = UserTriggerHelper.NewTriggerHelper(currentUserProfile.Name);
        /*
            note - developer may want to create new or extent the base helper class specific to an sObject (i.e. AccountTriggerHelper)
        */
    }

/*   
** @author : Cloud Sherpas Inc.
** @date : 05/20/2014
** @description :  this method handles the 'after insert' event for the trigger; it's purpose is to ...
** @paramaters : List of new Users, Map of User Ids to Users
** @returns : nothing
*/
    public void OnAfterInsert(User[] pNewUsers, map<Id,User> pUserIdToNewUserMap){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){ 
        
             UserTriggerHelper.AddNewUserToMonsterPhoneList(pUserIdToNewUserMap.keySet());
            
            /*
                note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                       and call the methods from handler.
            */              
        }               
       
    }

/*   
** @author : Cloud Sherpas Inc.
** @date : 05/21/2014
** @description :  this method handles the 'before update' event for the trigger; it's purpose is to ...
** @paramaters : an array of Apttus_Proposal__Proposal__c objects
** @returns : nothing
*/
    public void OnBeforeUpdate(User[] poldUsers,User[] pUpdatedUsers, map<Id,User> pUserIdToUpdatedUserMap , map<Id,User> pUserIdToOldUserMap ){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
                
        
            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){                
                       
                //helper.UpdateMonsterPhoneList(pUpdatedUsers, pUserIdToUpdatedUserMap);
                
                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                */              
            }               
       
    }
       
/*   
** @author : Cloud Sherpas Inc.
** @date : 04/09/2014
** @description :  this method handles the 'after update' event for the trigger; it's purpose is to ...
** @paramaters : an array of Apttus_Proposal__Proposal__c objects
** @returns : nothing
*/
    public void OnAfterUpdate(User[] poldUsers,User[] pUpdatedUsers, map<Id,User> pUserIdToUpdatedUserMap , map<Id,User> pUserIdToOldUserMap ){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
                
        
        if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
            
            helper.UpdateSalesQuotas(pUpdatedUsers, pUserIdToOldUserMap);
            
            //helper.UpdateMonsterPhoneList(pUpdatedUsers, pUserIdToUpdatedUserMap);
            helper.ManageMonsterPhoneList(pUserIdToUpdatedUserMap);
            
            /*
                note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                       and call the methods from handler.
            */              
        }               
       
    } 
}