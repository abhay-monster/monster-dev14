/*
** @author : Cloud Sherpas Inc.
** @date : 04/29/2014
** @description : Sales Attainment trigger class to handle CRUD events. 
*/
public with sharing class SalesAttainmentTriggerHandler extends BaseTriggerHandler{
   final String CLASSNAME = '\n\n**** SalesAttainmentTriggerHelper.METHODNAME()';
    private integer BatchSize = 0;
    //private boolean TriggerIsExecuting;
    private SalesAttainmentTriggerHelper helper;
    
/*  
** @author : Cloud Sherpas Inc.
** @date : 04/29/2014
** @description : the class constructor method
** @paramaters : a Boolean value indicating if a trigger is executing or not, an Integer value indicating the number of records in the batch/list
** @returns : nothing
** @sample call : SalesQuotaTriggerHandler handler = new SalesQuotaTriggerHandler(Trigger.isExecuting, Trigger.size);
*/
    public SalesAttainmentTriggerHandler(boolean isExecuting, integer pTriggerSize){
        
        // trigger is executing
        TriggerIsExecuting = isExecuting;
        
        // set batch size
        BatchSize = pTriggerSize;
        
        // set current User profile
        Profile currentUserProfile = [Select Name From Profile where Id = :UserInfo.getProfileId()];
        
        // intantiate new trigger helper
        helper = SalesAttainmentTriggerHelper.NewTriggerHelper(currentUserProfile.Name);
        /*
            note - developer may want to create new or extent the base helper class specific to an sObject (i.e. AccountTriggerHelper)
        */
    }

/*   
** @author : Cloud Sherpas Inc.
** @date : 04/29/2014
** @description :  this method handles the 'before Insert' event for the trigger; it's purpose is to ...
** @paramaters : an array of Sales Attainment objects
** @returns : nothing
*/
    public void onBeforeInsert(Sales_Attainment__c[] pSalesAttainment){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','onBeforeInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
                
        
        if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
            
            helper.populateSalesAttainmentFields(pSalesAttainment);
            /*
                note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                       and call the methods from handler.
            */              
        }               
        
    }
}