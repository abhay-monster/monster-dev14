public with sharing class OrderCommentTriggerHelper {
    final String CLASSNAME = '\n\n**** OrderCommentTriggerHelper.METHODNAME()';
    private String UserProfileName{get; private set;}
    
    /*
    ** @author : Cloud Sherpas Inc.
    ** @date : 12/11/2014
    ** @description : static method that instantiates a new instance of the class & sets the user's profile name member variable
    ** @paramaters : a string - the profile name for the current user
    ** @returns : a new instance of the OrderCommentTriggerHelper class
    */
    public static OrderCommentTriggerHelper NewTriggerHelper(String pUserProfileName){
        
        //final string METHODNAME = CLASSNAME.replace('METHODNAME','NewTriggerHelper');
        //system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        OrderCommentTriggerHelper newHelper = new OrderCommentTriggerHelper(pUserProfileName);
        return newHelper;
    }
    /*
    ** @author : Cloud Sherpas, Inc.
    ** @date : 04/09/2014
    ** @description : this method is the class constructor
    ** @paramaters : String user profile name
    ** @returns : nothing
    */
    private OrderCommentTriggerHelper(String pUserProfileName){  
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OrderCommentTriggerHelper');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        UserProfileName = pUserProfileName;
    }

    /*
    ** @author : Cloud Sherpas, Inc.
    ** @date : 12/12/2014
    ** @story : 1028
    ** @element : E1948
    ** @description : Copy Most Recent Comment into Order Header Last Comment field
    ** @paramaters : List of Order Line Item, Map of Order Line Item old values
    ** @returns : nothing
    */
    public void copyCommentToOrderHeader(list<Order_Comment__c> pOrderComments){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','createCaseForVerifiedOrders');
        Logger.push(METHODNAME, 'Order_Comment__c');
        //methods variables
        List<Order__c> orderList = new List<Order__c>();
        Set<Id> orderHeaderIds = new Set<Id>();
        Map<Id, String> mapComment = new Map<Id, String>();
        //retrieve order header ids
        for(Order_Comment__c comment: pOrderComments){

            if(comment.Order__c != null){
                orderHeaderIds.add(comment.Order__c);                
                mapComment.put(comment.Order__c, comment.Description__c);                
            }
            
        }
        
        //retrieve all order header record for update
        if(orderHeaderIds.size()>0){
            
            orderList = [SELECT Id, Description__c FROM Order__c WHERE Id IN: orderHeaderIds];
            for(Order__c ord: orderList){
                ord.Description__c = mapComment.get(ord.Id);
            }           
        }

        //DML call
        if(orderList != null && !orderList.isEmpty()){
            OrderTriggerHandler.ExecuteTriggers = false;
            try{
                update orderList;
            }catch(DMLException e){
                Logger.debugException(e,null);
            }
        }
        Logger.pop();
    } 
}