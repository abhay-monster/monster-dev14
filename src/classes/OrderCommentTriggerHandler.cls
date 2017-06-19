public with sharing class OrderCommentTriggerHandler extends BaseTriggerHandler{
    
    final String CLASSNAME = '\n\n**** OrderCommentTriggerHandler.METHODNAME()';
    private integer BatchSize = 0;
    public static Boolean ExecuteTriggers = true;
    OrderCommentTriggerHelper helper;

    /*  
    ** @author : Cloud Sherpas Inc.
    ** @date : 12/11/2014
    ** @description : the class constructor method
    ** @paramaters : a Boolean value indicating if a trigger is executing or not, an Integer value indicating the number of records in the batch/list
    ** @returns : nothing
    ** @sample call : AccountTriggerHandler handler = new AccountTriggerHandler(Trigger.isExecuting, Trigger.size);
    */
    public OrderCommentTriggerHandler(boolean isExecuting, integer pTriggerSize){
        
        // trigger is executing
        TriggerIsExecuting = isExecuting;
        
        // set batch size
        BatchSize = pTriggerSize;
        
        // set current User profile
        Profile currentUserProfile = [Select Name From Profile where Id = :UserInfo.getProfileId() LIMIT 1];
        
        // intantiate new trigger helper
        helper = OrderCommentTriggerHelper.NewTriggerHelper(currentUserProfile.Name);
        /*
            note - developer may want to create new or extent the base helper class specific to an sObject (i.e. AccountTriggerHelper)
        */
    }

    /*   
    ** @author : Cloud Sherpas Inc.
    ** @date : 04/09/2014
    ** @description :  this method handles the 'after insert' event for the trigger; it's purpose is to ...
    ** @paramaters : an array of Order_Comment__c objects
    ** @returns : nothing
    */
    public void OnAfterInsert(List<Order_Comment__c> pNewOrderComment){
        //if (Personal_Settings__c.getInstance().Trigger_Order__c ==false){
            //return; // If triggers are off, then exit the method
        //}        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterInsert');

       
            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                
                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                */              
                helper.copyCommentToOrderHeader(pNewOrderComment);
            }               
       
    }

    /*   
    ** @author : Cloud Sherpas Inc.
    ** @date : 04/09/2014
    ** @description :  this method handles the 'after update' event for the trigger; it's purpose is to ...
    ** @paramaters : an array of Order_Comment__c objects
    ** @returns : nothing
    */
    public void OnAfterUpdate(List<Order_Comment__c> pNewOrderComment, Map<Id, Order_Comment__c> pOldOrderCommentMap){
        //if (Personal_Settings__c.getInstance().Trigger_Order__c ==false){
            //return; // If triggers are off, then exit the method
        //}        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterInsert');

       
            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                
                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                */              
                helper.copyCommentToOrderHeader(pNewOrderComment);
            }               
       
    } 
}