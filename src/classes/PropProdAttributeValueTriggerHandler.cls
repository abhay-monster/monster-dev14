public with sharing class PropProdAttributeValueTriggerHandler extends BaseTriggerHandler{
    final String CLASSNAME = '\n\n**** PropProdAttributeValueTriggerHandler.METHODNAME()';
    private integer BatchSize = 0;
    private TriggerHelper helper;
    private PropProdAttributeValueTriggerHelper lineItemHelper;
   
/*  
** @author : Cloud Sherpas Inc.
** @date : 06/30/2014
** @description : the class constructor method
** @paramaters : a Boolean value indicating if a trigger is executing or not, an Integer value indicating the number of records in the batch/list
** @returns : nothing
** @sample call : ApttusProposalLineItemTriggerHandler handler = new ApttusProposalLineItemTriggerHandler(Trigger.isExecuting, Trigger.size);
*/
    public PropProdAttributeValueTriggerHandler(boolean isExecuting, integer pTriggerSize){
        
        // trigger is executing
        TriggerIsExecuting = isExecuting;
        
        // set batch size
        BatchSize = pTriggerSize;//
         
        // intantiate new trigger helper
        lineItemHelper = PropProdAttributeValueTriggerHelper.NewTriggerHelper();
        /*
            note - developer may want to create new or extent the base helper class specific to an sObject (i.e. AccountTriggerHelper)
        */
    }
/*
** @author : Cloud Sherpas Inc.
** @date : 06/30/2014
** @description :  this method handles the 'after insert' event for the trigger; it's purpose is to ...
** @paramaters : an array of Account objects
** @returns : nothing
*/
    public void OnAfterInsert(Apttus_QPConfig__ProposalProductAttributeValue__c[] pUpdatedLineItems){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
            
            lineItemHelper.populatePostingLocation(pUpdatedLineItems);
            lineItemHelper.updateOpptyLineItem(pUpdatedLineItems);
               
            /*
                note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                       and call the methods from handler.
            */
            
        }
    }
/*
** @author : Cloud Sherpas Inc.
** @date : 06/30/2014
** @description :  this method handles the 'after insert' event for the trigger; it's purpose is to ...
** @paramaters : an array of Account objects
** @returns : nothing
*/
    public void OnBeforeUpdate(List<Apttus_QPConfig__ProposalProductAttributeValue__c> pUpdatedLineItems, map<ID, Apttus_QPConfig__ProposalProductAttributeValue__c> pLineItemsIdToOldLineItemsMap){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
            
            lineItemHelper.updatePostingLocation(pUpdatedLineItems, pLineItemsIdToOldLineItemsMap);
               
            /*
                note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                       and call the methods from handler.
            */            
        }               
       
    }

    //SBerron - Appirio - 3/02/17 - S-442900
    public void onAfterUpdate(List<Apttus_QPConfig__ProposalProductAttributeValue__c> pUpdatedLineItems, map<ID, Apttus_QPConfig__ProposalProductAttributeValue__c> pLineItemsIdToOldLineItemsMap) {
        final string METHODNAME = CLASSNAME.replace('METHODNAME','onAfterUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        lineItemHelper.updateOpptyLineItem(pUpdatedLineItems);
    } 
}