/*
** @author : Cloud Sherpas Inc.
** @date : 09/18/2014
** @description : ProductConfigration trigger class to handle CRUD events. 
*/
public with sharing class ApttusProductConfigTriggerHandler extends BaseTriggerHandler{

    final String CLASSNAME = '\n\n**** ApttusProposalTriggerHandler.METHODNAME()';
    private integer BatchSize = 0;
    private ProductConfigTriggerHelper helper;
    public static Boolean ExecuteTriggers = true;
    private static Integer RunCount = 0;
    public static Boolean PreventRecursion = true;

/*  
** @author : Cloud Sherpas Inc.
** @date : 09/18/2014
** @description : the class constructor method
** @paramaters : a Boolean value indicating if a trigger is executing or not, an Integer value indicating the number of records in the batch/list
** @returns : nothing
** @sample call : ApttusProductConfigTriggerHandler handler = new ApttusProductConfigTriggerHandler(Trigger.isExecuting, Trigger.size);
*/
    public ApttusProductConfigTriggerHandler(boolean isExecuting, integer pTriggerSize){
        
        // trigger is executing
        TriggerIsExecuting = isExecuting;
        
        // set batch size
        BatchSize = pTriggerSize;
        
        // set current User profile
        //Profile currentUserProfile = [Select Name From Profile where Id = :UserInfo.getProfileId()];
        
        // intantiate new trigger helper
        helper = ProductConfigTriggerHelper.NewTriggerHelper();
        /*
            note - developer may want to create new or extent the base helper class specific to an sObject (i.e. AccountTriggerHelper)
        */
    }


/*   
** @author : Cloud Sherpas Inc.
** @date : 09/18/2014
** @description :  this method handles the 'after insert' event for the trigger; it's purpose is to ...
** @paramaters : an array of Apttus_Proposal__Proposal__c objects
** @returns : nothing
*/
/* // This code is being commented out because not being used anywhere and coded by cloud sherpas.
    public void OnBeforeInsert(Apttus_Config2__ProductConfiguration__c[] pApttusProductConfigurationList){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        //Skip updating Oppty in Cloning the Proposal
        //OpportunityTriggerHandler.SKIP_OPPORTUNITY_UPDATE = true;
                
        try{
            if(ExecuteTriggers && IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                
        
            }               
        }
        catch(BaseApplicationException bae){
            throw bae;
        }
        catch(Exception ex){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }
    }*/
/*   
** @author : Cloud Sherpas Inc.
** @date : 09/18/2014
** @description :  this method handles the 'after insert' event for the trigger; it's purpose is to ...
** @paramaters : an array of Apttus_Config2__ProductConfiguration__c objects
** @returns : nothing
*/
/* // This code is being commented out because not being used anywhere and coded by cloud sherpas.
    public void OnAfterInsert(Apttus_Config2__ProductConfiguration__c[] pNewApttusProductConfiguration, map<Id, Apttus_Config2__ProductConfiguration__c> pOldApttusProductConfigurationMap){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        //Skip updating Oppty in Cloning the Proposal
        //OpportunityTriggerHandler.SKIP_OPPORTUNITY_UPDATE = true;
                
        try{
            if(ExecuteTriggers && IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                //setting of QuoteCreated__c flag when an Apptus_proposal is created
                


               
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                            
            }               
        }
        catch(BaseApplicationException bae){
            throw bae;
        }
        catch(Exception ex){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }
    }
    */
/*   
** @author : Cloud Sherpas Inc.
** @date : 09/18/2014
** @description :  this method handles the 'before Update' event for the trigger; it's purpose is to ...
** @paramaters : an array of Apttus_Config2__ProductConfiguration__c objects
** @returns : nothing
*/
/* // This code is being commented out because not being used anywhere and coded by cloud sherpas.
    public void OnBeforeUpdate( Apttus_Config2__ProductConfiguration__c[] pOldApttusProductConfigurationList, Apttus_Config2__ProductConfiguration__c[] pUpdatedApttusProductConfigurationList, map<Id, Apttus_Config2__ProductConfiguration__c> pUpdatedApttusProductConfigurationMap, map<Id, Apttus_Config2__ProductConfiguration__c> pOldApttusProductConfigurationMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeUpdate');
        system.debug('**** OnBeforeUpdate prevent Recursion RunCount:'+ ApttusProductConfigTriggerHandler.RunCount + ' PreventRecursion:' + PreventRecursion);
        if(ApttusProductConfigTriggerHandler.RunCount > 0 && PreventRecursion){
            return;
        }
        try{
            if(ExecuteTriggers && IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                
                //helper.setFireApprovalsFlag(pUpdatedApttusProductConfigurationList, pOldApttusProductConfigurationMap);
                
                
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
              
                RunCount++;
                system.debug('Apttus Proposal Handler Run Count: ' + RunCount); 
            }               
        }
        catch(BaseApplicationException bae){
            throw bae;
        }
        catch(Exception ex){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }
    }
    */
/*   
** @author : APttus.
** @date : 07/10/2015
** @description :  this method handles the 'after update' event for the trigger; it's purpose is to Changed the Proposal Status if no Approval is neede...
** @paramaters : an array of Apttus_Config2__ProductConfiguration__c objects
** @returns : nothing
*/
    public void OnAfterUpdate(Apttus_Config2__ProductConfiguration__c[] pNewApttusProductConfiguration, map<Id, Apttus_Config2__ProductConfiguration__c> pOldApttusProductConfigurationMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterUpdate');
        //system.debug('**** OnAfterUpdate prevent Recursion RunCount:'+ ApttusProductConfigTriggerHandler.RunCount + ' PreventRecursion:' + PreventRecursion);
        //system.debug('in handler Apttus_Config2__ProductConfiguration__c onAfterupdate');
        if(ApttusProductConfigTriggerHandler.RunCount > 1 && PreventRecursion){
            //system.debug('*** SKIP Trigger Product Configuration OnAfterUpdate.');
            return;
        }
        //System.debug('Trigger context:\n ExecuteTriggers :'+ExecuteTriggers+'\nIsTriggerContext :'+IsTriggerContext+'\nIsVisualforcePageContext :'+IsVisualforcePageContext+'\n IsWebServiceContext :'+IsWebServiceContext+'\nIsExecuteAnonymousContext: '+IsExecuteAnonymousContext);
        
        //try{
            //if(ExecuteTriggers && IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
               
                //Story 1089 - Compare yoy discount and Net amount for Customer Account
                helper.calculateYOYDiscount(pNewApttusProductConfiguration, pOldApttusProductConfigurationMap);
                
                // call Custom_field_set_proposal_NSSA_approval for long term contracts, signed indicator, Custom Sponsorship, 
                // Custom International Sponsorship, Earliest_Start_Date, Latest_End_Date.
                helper.Custom_field_set_proposal_NSSA_approvals(pNewApttusProductConfiguration, pOldApttusProductConfigurationMap);
                //helper.config_QuoteApproval(pNewApttusProductConfiguration, pOldApttusProductConfigurationMap);
                //helper.config_QuoteTax(pNewApttusProductConfiguration, pOldApttusProductConfigurationMap);
                // calculate Avalara tax for the finilized configrations
                helper.config_Saved(pNewApttusProductConfiguration, pOldApttusProductConfigurationMap);
                AvalaraModel_Cart.getQuoteTaxFromConfig(pNewApttusProductConfiguration);
              //  helper.CartFinalize(pNewApttusProductConfiguration, pOldApttusProductConfigurationMap);
                
            //}               
        //}
        /*catch(BaseApplicationException bae){
            throw bae;
        }
        catch(Exception ex){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }*/
    }
    
/*   
** @author : Cloud Sherpas Inc.
** @date : 03/07/2014
** @description :  this method handles the 'after delete' event for the trigger; it's purpose is to ...
** @paramaters : an array of Apttus_Config2__ProductConfiguration__c objects
** @returns : nothing
*/
/* // This code is being commented out because not being used anywhere and coded by cloud sherpas.
    public void OnAfterDelete(Apttus_Config2__ProductConfiguration__c[] pApttusProductConfiguration){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterDlete');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
                
        try{
            if(ExecuteTriggers && IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                             
            }               
        }
        catch(BaseApplicationException bae){
            throw bae;
        }
        catch(Exception ex){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }
    }
    */
}