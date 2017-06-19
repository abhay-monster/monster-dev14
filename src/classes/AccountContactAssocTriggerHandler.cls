/*
** @author : Cloud Sherpas Inc.
** @date : 03/07/2014
** @description : AccountContactAssociation__c trigger class to handle CRUD events. 
*/

public without sharing class AccountContactAssocTriggerHandler extends BaseTriggerHandler{
    final String CLASSNAME = '\n\n**** AccountContactAssocTriggerHandler.METHODNAME()';
    private integer BatchSize = 0;
    private TriggerHelper helper;
    private AccountContactAssocTriggerHelper accountHelper;
    private Profile CurrentUserProfile;

/*  
** @author : Cloud Sherpas Inc.
** @date : 03/07/2014
** @description : the class constructor method
** @paramaters : a Boolean value indicating if a trigger is executing or not, an Integer value indicating the number of records in the batch/list
** @returns : nothing
** @sample call : AccountContactAssocTriggerHandler handler = new AccountContactAssocTriggerHandler(Trigger.isExecuting, Trigger.size);
*/
    public AccountContactAssocTriggerHandler(boolean isExecuting, integer pTriggerSize){
        
        // trigger is executing
        TriggerIsExecuting = isExecuting;
        
        // set batch size
        BatchSize = pTriggerSize;//
         
        // set current User profile
        CurrentUserProfile = [Select Name From Profile where Id = :UserInfo.getProfileId()];
        
        // intantiate new trigger helper
        accountHelper = AccountContactAssocTriggerHelper.NewTriggerHelper(CurrentUserProfile.Name);
        /*
            note - developer may want to create new or extent the base helper class specific to an sObject (i.e. AccountTriggerHelper)
        */
    }
    
/*
** @author : Cloud Sherpas Inc.
** @date : 07/18/2014
** @description :  this method handles the 'before insert' event for the trigger; it's purpose is to ...
** @paramaters : an array of Account objects
** @returns : nothing
*/
    public void OnBeforeInsert(AccountContactAssociation__c[] pAccount){
        if (Personal_Settings__c.getInstance().Trigger_Account_Contact_Association__c ==false){
            return; // If triggers are off, then exit the method
        }
        System.debug('IsTriggerContext::::::: ' + IsTriggerContext);
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        
            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                accountHelper.validatePrimarySalesContact(pAccount);
                accountHelper.SetPrimarySalesContact(pAccount);
                accountHelper.checkDupeContact(pAccount);
                
                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                */
                
            }               
       
    }  

/*    
**  @author : Cloud Sherpas Inc.
**  @date : 07/18/2014
**  @description :  this method handles the 'before update' event for the trigger; it's purpose is to ...
**  @paramaters : array of old Account objects, array of new Account object, map of new Accounts, map of old Accounts
**  @returns : nothing
*/
    public void OnBeforeUpdate(AccountContactAssociation__c[] pOldACA, AccountContactAssociation__c[] pUpdatedACA, map<ID, AccountContactAssociation__c> pAccountIdToOldACAMap, map<ID, AccountContactAssociation__c> pAccountIdToUpdatedACAMap){     
        if (Personal_Settings__c.getInstance().Trigger_Account_Contact_Association__c ==false){
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        
            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                accountHelper.validatePrimarySalesContact(pUpdatedACA);
                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                */              
            }
       
              
    } 
}