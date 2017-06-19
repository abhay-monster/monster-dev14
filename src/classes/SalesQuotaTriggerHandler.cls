/*
** @author : Cloud Sherpas Inc.
** @date : 04/23/2014
** @description : Sales Quotas trigger class to handle CRUD events. 
*/
public with sharing class SalesQuotaTriggerHandler extends BaseTriggerHandler{
    
    final String CLASSNAME = '\n\n**** SalesQuotaTriggerHandler.METHODNAME()';
    private integer BatchSize = 0;
    //private boolean TriggerIsExecuting;
    private SalesQuotaTriggerHelper helper;
    
/*  
** @author : Cloud Sherpas Inc.
** @date : 04/23/2014
** @description : the class constructor method
** @paramaters : a Boolean value indicating if a trigger is executing or not, an Integer value indicating the number of records in the batch/list
** @returns : nothing
** @sample call : SalesQuotaTriggerHandler handler = new SalesQuotaTriggerHandler(Trigger.isExecuting, Trigger.size);
*/
    public SalesQuotaTriggerHandler(boolean isExecuting, integer pTriggerSize){
        
        // trigger is executing
        TriggerIsExecuting = isExecuting;
        
        // set batch size
        BatchSize = pTriggerSize;
        
        // set current User profile
        Profile currentUserProfile = [Select Name From Profile where Id = :UserInfo.getProfileId()];
        
        // intantiate new trigger helper
        helper = SalesQuotaTriggerHelper.NewTriggerHelper(currentUserProfile.Name);
        /*
            note - developer may want to create new or extent the base helper class specific to an sObject (i.e. AccountTriggerHelper)
        */
    }
    
/*   
** @author : Cloud Sherpas Inc.
** @date : 04/23/2014
** @description :  this method handles the 'before Insert' event for the trigger; it's purpose is to ...
** @paramaters : an array of User objects
** @returns : nothing
*/
    public void onBeforeInsert(Sales_Quotas__c[] pSalesQuotas){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','onBeforeInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
                
       
            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                
                helper.populateSalesQuotasFields(pSalesQuotas);
                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                */              
            }               
        
    } 
}