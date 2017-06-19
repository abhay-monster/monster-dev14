/*
** @author : Cloud Sherpas Inc.
** @date : 03/07/2014
** @description : CompetitiveLandscape__c trigger class to handle CRUD events. 
*/
public with sharing class CompetitiveLandscapeTriggerHandler extends BaseTriggerHandler{

    final String CLASSNAME = '\n\n**** CompetitiveLandscapeTriggerHandler.METHODNAME()';
    private integer BatchSize = 0;
    private CompetitiveLandscapeTriggerHelper helper;

/*  
** @author : Cloud Sherpas Inc.
** @date : 04/03/2014
** @description : the class constructor method
** @paramaters : a Boolean value indicating if a trigger is executing or not, an Integer value indicating the number of records in the batch/list
** @returns : nothing
** @sample call : CompetitiveLandscapeTriggerHandler handler = new CompetitiveLandscapeTriggerHandler(Trigger.isExecuting, Trigger.size);
*/
    public CompetitiveLandscapeTriggerHandler(boolean isExecuting, integer pTriggerSize){
        
        // trigger is executing
        TriggerIsExecuting = isExecuting;
        
        // set batch size
        BatchSize = pTriggerSize;
        
        // set current User profile
        Profile currentUserProfile = [Select Name From Profile where Id = :UserInfo.getProfileId()];
        
        // intantiate new trigger helper
        helper = CompetitiveLandscapeTriggerHelper.NewTriggerHelper(currentUserProfile.Name);
        /*
            note - developer may want to create new or extent the base helper class specific to an sObject (i.e. AccountTriggerHelper)
        */
    }
    
/*
** @author : Cloud Sherpas Inc.
** @date : 04/03/2014
** @description :  this method handles the 'before insert' event for the trigger; it's purpose is to ...
** @paramaters : an array of CompetitiveLandscape__c objects
** @returns : nothing
*/
    public void OnBeforeInsert(CompetitiveLandscape__c[] pCompetitiveLandscape){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        try{
            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                
                // <write code here>
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
            system.debug(LoggingLevel.DEBUG, METHODNAME + ' :: ERROR MESSAGE = ' + ex.getMessage() + '\n\n');
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }
    }

/*   
** @author : Cloud Sherpas Inc.
** @date : 04/03/2014
** @description :  this method handles the 'after insert' event for the trigger; it's purpose is to ...
** @paramaters : an array of CompetitiveLandscape__c objects
** @returns : nothing
*/
    public void OnAfterInsert(CompetitiveLandscape__c[] pCompetitiveLandscape){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
                
        try{
            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                
                // <write code here>
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
**  @author : Cloud Sherpas Inc.
**  @date : 04/03/2014
**  @description :  this method handles the 'before update' event for the trigger; it's purpose is to ...
**  @paramaters : array of old CompetitiveLandscape__c objects, array of new CompetitiveLandscape__c object, map of new Accounts, map of old Accounts
**  @returns : nothing
*/
    public void OnBeforeUpdate(CompetitiveLandscape__c[] pOldAccounts, CompetitiveLandscape__c[] pUpdatedAccounts, map<ID, CompetitiveLandscape__c> pAccountIdToOldAccountMap, map<ID, CompetitiveLandscape__c> pAccountIdToUpdatedAccountMap){     
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        try{
            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
               // <write code here>
                
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
**  @author : Cloud Sherpas Inc.
**  @date : 04/03/2014
**  @description :  this method handles the 'after update' event for the trigger; it's purpose is to ...
**  @paramaters : array of old CompetitiveLandscape__c objects, array of new CompetitiveLandscape__c object, map of new Accounts, map of old Accounts
**  @returns : nothing
*/
    public void OnAfterUpdate(CompetitiveLandscape__c[] pOldAccounts, CompetitiveLandscape__c[] pUpdatedAccounts, map<ID, CompetitiveLandscape__c> pAccountIdToOldAccountMap, map<ID, CompetitiveLandscape__c> pAccountIdToUpdatedAccountMap){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        try{
            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                
                // <write code here>

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
**  @author : Cloud Sherpas Inc.
**  @date : 04/03/2014
**  @description :  this method handles the 'before delete' event for the trigger; it's purpose is to ...
**  @paramaters : array of old CompetitiveLandscape__c objects, map of old Accounts
**  @returns : nothing
*/
    public void OnBeforeDelete(CompetitiveLandscape__c[] pOldAccounts, map<ID, SObject> pAccountMapOld){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeDelete');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        try{
            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                // <write code here>
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
**  @author : Cloud Sherpas Inc.
**  @date : 04/03/2014
**  @description :  this method handles the 'after delete' event for the trigger; it's purpose is to ...
**  @paramaters : array of old CompetitiveLandscape__c objects, map of old Accounts
**  @returns : nothing
*/  
    public void OnAfterDelete(CompetitiveLandscape__c[] pOldAccounts, map<ID, SObject> pAccountMapOld){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterDelete');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        try{
            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                // <write code here>
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
**  @author : Cloud Sherpas Inc.
**  @date : 04/03/2014
**  @description :  this method handles the 'Undeleted' event for the trigger; it's purpose is to ...
**  @paramaters : array of new CompetitiveLandscape__c object
**  @returns : nothing
*/       
    public void OnUndeleted(CompetitiveLandscape__c[] pUndeletedAccounts){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnUndeleted');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        try{
            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                // <write code here>
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
}