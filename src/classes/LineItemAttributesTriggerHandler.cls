/*
** @author : Cloud Sherpas Inc.
** @date : 06/11/2014
** @description : Credit Request trigger class to handle CRUD events.
*/
public with sharing class LineItemAttributesTriggerHandler extends BaseTriggerHandler{

    final String CLASSNAME = '\n\n**** LineItemAttributesTriggerHandler.METHODNAME()';
    private integer BatchSize = 0;
    //private boolean TriggerIsExecuting;
    private LineItemAttributesTriggerHelper helper;
/*
** @author : Cloud Sherpas Inc.
** @date : 06/18/2014
** @description : the class constructor method
** @paramaters : a Boolean value indicating if a trigger is executing or not, an Integer value indicating the number of records in the batch/list
** @returns : nothing
** @sample call : LineItemAttributesTriggerHandler handler = new LineItemAttributesTriggerHandler(Trigger.isExecuting, Trigger.size);
*/
    public LineItemAttributesTriggerHandler(boolean isExecuting, integer pTriggerSize){

        // trigger is executing
        TriggerIsExecuting = isExecuting;

        // set batch size
        BatchSize = pTriggerSize;

        // set current User profile
        Profile currentUserProfile = [Select Name From Profile where Id = :UserInfo.getProfileId()];

        // intantiate new trigger helper
        helper = LineItemAttributesTriggerHelper.NewTriggerHelper();
        /*
            note - developer may want to create new or extent the base helper class specific to an sObject (i.e. AccountTriggerHelper)
        */
    }

/*
** @author : Appirio (Jonathan F)
** @date : 04/03/16
*/
    public void OnBeforeInsert(List<Line_Item_Attribute__c> lineItemAttribute){
        if (Personal_Settings__c.getInstance().Trigger_Order__c ==false){
            system.debug('LineItemAttributes Trigger deactivated because Personal_Settings__c.Trigger_Order__c == false');
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        if(UserInfo.getName() == 'Integration MAPP'){
            for(Line_Item_Attribute__c lia : lineItemAttribute){
                System.debug('^^^ MAPP Insert Line_Item_Attribute__c ' + lia);
            }
            helper.fixEcomm(lineItemAttribute);
            
        }
        //helper.PopulateRefreshInterval(lineItemAttribute);//I-198905/I-211033//commented out as its no more required
    }


/*
** @author : Cloud Sherpas Inc.
** @date : 06/18/2014
** @description :  this method handles the 'after insert' event for the trigger; it's purpose is to ...
** @paramaters : List of new Line Item Attributes
** @returns : nothing
*/
    public void OnAfterInsert(List<Line_Item_Attribute__c> lineItemAttribute){
        if (Personal_Settings__c.getInstance().Trigger_Order__c ==false){
            system.debug('LineItemAttributes Trigger deactivated because Personal_Settings__c.Trigger_Order__c == false');
            return; // If triggers are off, then exit the method
        }

        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
            helper.afterCreate(lineItemAttribute);
        }
        //Update By Vivek for T-435078
       // Ensure ALL international orders are flagged correctly
       setOrderInternationalDeal(lineItemAttribute);
       
    }

/*
** @author : Cloud Sherpas Inc.
** @date : 06/18/2014
** @description :  this method handles the 'after update' event for the trigger; it's purpose is to ...
** @paramaters : an array of Line Item Attribute
** @returns : nothing
*/
    public void OnAfterUpdate(List<Line_Item_Attribute__c> lineItemAttribute){
        if (Personal_Settings__c.getInstance().Trigger_Order__c ==false){
            system.debug('LineItemAttributes Trigger is off due to personal settings for this user');
            return; // If triggers are off, then exit the method
        }

        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                helper.afterCreate(lineItemAttribute);
        }
        //Update By Vivek for T-435078
       // Ensure ALL international orders are flagged correctly
       setOrderInternationalDeal(lineItemAttribute);
    }


    //Update By Vivek for T-435078
    // Ensure ALL international orders are flagged correctly
    public void setOrderInternationalDeal(List<Line_Item_Attribute__c> lineItemsAtt){

        set<Id> lineItemIds = new set<Id>();
        set<Id> ordIds = new set<Id>();
        List<Order__c> tobeUpdatedOrders = new List<Order__c>();

        System.debug('In setOrderInternationalDeal ==');

        for(Line_Item_Attribute__c lineItem : lineItemsAtt){
            if(lineItem.Geography__c == 'International' || lineItem.Geography__c == 'Regional'){
                lineItemIds.add(lineItem.Order_Line_Item__c);

            }
        }

        for(Order_Line_Item__c ordLineItem : [Select Id, Order__c from Order_Line_Item__c
                              where id in : lineItemIds ]){
                                ordIds.add(ordLineItem.Order__c);
                              }


       for(Order__c ord :[Select Id,International_Deal__c From Order__c Where Id IN : ordIds]){
            ord.International_Deal__c = true;
            tobeUpdatedOrders.add(ord);
        }
        if(!tobeUpdatedOrders.isEmpty()){
           update tobeUpdatedOrders;
        }

        System.debug('Out setOrderInternationalDeal=='+tobeUpdatedOrders);

    }



}