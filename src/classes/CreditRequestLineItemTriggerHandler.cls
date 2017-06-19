/*
** @author : Cloud Sherpas Inc.
** @date : 04/29/2014
** @description : Credit Request Line Item trigger class to handle CRUD events. 
*/
public class CreditRequestLineItemTriggerHandler extends BaseTriggerHandler{
  final String CLASSNAME = '\n\n**** CreditRequestLineItemTriggerHandler.METHODNAME()';
    private integer BatchSize = 0;
    //private boolean TriggerIsExecuting;
    private CreditRequestLineItemTriggerHelper helper;
    
/*  
** @author : Cloud Sherpas Inc.
** @date : 04/29/2014
** @description : the class constructor method
** @paramaters : a Boolean value indicating if a trigger is executing or not, an Integer value indicating the number of records in the batch/list
** @returns : nothing
** @sample call : CreditRequestLineItemTriggerHelper handler = new CreditRequestLineItemTriggerHelper(Trigger.isExecuting, Trigger.size);
*/
    public CreditRequestLineItemTriggerHandler(boolean isExecuting, integer pTriggerSize){
        
        // trigger is executing
        TriggerIsExecuting = isExecuting;
        
        // set batch size
        BatchSize = pTriggerSize;
        
        // set current User profile
        Profile currentUserProfile = [Select Name From Profile where Id = :UserInfo.getProfileId()];
        
        // intantiate new trigger helper
        helper = CreditRequestLineItemTriggerHelper.NewTriggerHelper(currentUserProfile.Name);
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
    public void onBeforeInsert(CreditRequestLineItem__c[] pCreditRequestLineItem){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','onBeforeInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
                
        try{
            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                
                helper.ValidateOrderLineItems(pCreditRequestLineItem);
                helper.populateLineType(pCreditRequestLineItem);
                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                */              
            }               
        }
        catch(Exception ex){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }
    } 
}