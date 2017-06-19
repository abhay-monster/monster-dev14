/*
** @author : Cloud Sherpas Inc.
** @date : 06/24/2014
** @description :   class that supports the 'CreditRequestLineItemTriggerHandler' class; it provides the methods called from those classes
*/
public with sharing class CreditRequestLineItemTriggerHelper {
  final String CLASSNAME = '\n\n**** CreditRequestLineItemTriggerHelper.METHODNAME()';
    
    // ********* PROPERTIES ***********
    private String UserProfileName{get; private set;}
    private Map<String, Map<String, Schema.SObjectField>> sObjectAndFields;
    
    /*
** @author : Cloud Sherpas Inc.
** @date : 06/24/2014
** @description : static method that instantiates a new instance of the class & sets the user's profile name member variable
** @paramaters : a string - the profile name for the current user
** @returns : a new instance of the CreditRequestTriggerHelper class
*/
    public static CreditRequestLineItemTriggerHelper NewTriggerHelper(String pUserProfileName){
        
        //final string METHODNAME = CLASSNAME.replace('METHODNAME','NewTriggerHelper');
        //system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        CreditRequestLineItemTriggerHelper newHelper = new CreditRequestLineItemTriggerHelper(pUserProfileName);
        return newHelper;
    }
    
/*
** @author : Cloud Sherpas Inc.
** @date : 06/24/2014
** @description : static method that instantiates a new instance of the class
** @paramaters : nothing
** @returns : a new instance of the CreditRequestTriggerHelper class
*/
    public static CreditRequestLineItemTriggerHelper NewTriggerHelper(){
        
        //final string METHODNAME = CLASSNAME.replace('METHODNAME','NewTriggerHelper');
        //system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        CreditRequestLineItemTriggerHelper newHelper = new CreditRequestLineItemTriggerHelper('');
        return newHelper;
    }

    /*
    ** @author : Cloud Sherpas, Inc.
    ** @date : 06/24/2014
    ** @description : this method is the class constructor
    ** @paramaters : none
    ** @returns : nothing
    */
    private CreditRequestLineItemTriggerHelper(String pUserProfileName){  
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','CreditRequestLineItemTriggerHelper');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        UserProfileName = pUserProfileName;
    }
    
    /**
    * @description Validate the input for Credit Amount and Quantity
    * @author Cloudsherpas
    * @story 0780
    * @element E1660
    * @date 06/25/2014
    * @param none
    * @returns none
    */  
    Public void ValidateOrderLineItems(List<CreditRequestLineItem__c> crLineItems){
        /*for(CreditRequestLineItem__c crli : crLineItems ){
            if(crli.CreditAmount__c > crli.AvailableCreditAmount__c){
                crli.addError('Credit Amount should not be greater than the available credit amount.');
            }
            if(crli.Quantity__c > crli.OrderLineItemQuantity__c){
                crli.addError('Quantity should not be greater than the available quantity.');
            }
        }*/
    }

     /**
    * @description Copy order line item line type to credit request line item item type
    * @author Sylvester Agyen (Appirio, Inc)
    * @date 05/04/2016
    * @param crLineItems - new credit request line items
    * @returns none
    */  
    Public void populateLineType(List<CreditRequestLineItem__c> crLineItems){
        //Get order line item ids from credit request line item
        Set<Id>olis = new Set<Id>();
        List<CreditRequestLineItem__c>crliToProcess = new List<CreditRequestLineItem__c>();
        for(CreditRequestLineItem__c crli : crLineItems ){
            if(crli.Order_Line_Item__c != null){
                olis.add(crli.Order_Line_Item__c);
                crliToProcess.add(crli);
            }
        }
        //Query order line items
        if(olis != null){
            List<Order_Line_Item__c>results = [select id, LineType__c from Order_Line_Item__c where id IN:olis];
            if(results.size() > 0){
                //Match credit request line items to order line items
                for(CreditRequestLineItem__c li : crliToProcess){
                    for(Order_Line_Item__c oli : results){
                        if(li.Order_Line_Item__c == oli.id){
                            li.LineType__c = oli.LineType__c;
                        }
                    }
                }
            }
        }
    }
    
}