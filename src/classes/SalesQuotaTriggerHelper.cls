/*
** @author : Cloud Sherpas Inc.
** @date : 04/23/2014
** @description :   class that supports the 'SalesQuotaTriggerHandler' class; it provides the methods called from those classes
*/
public with sharing class SalesQuotaTriggerHelper {
    final String CLASSNAME = '\n\n**** TriggerHelper.METHODNAME()';
    
    // ********* PROPERTIES ***********
    private String UserProfileName{get; private set;}
    
/*
** @author : Cloud Sherpas Inc.
** @date : 04/23/2014
** @description : static method that instantiates a new instance of the class & sets the user's profile name member variable
** @paramaters : a string - the profile name for the current user
** @returns : a new instance of the SalesQuotaTriggerHelper class
*/
    public static SalesQuotaTriggerHelper NewTriggerHelper(String pUserProfileName){
        
        //final string METHODNAME = CLASSNAME.replace('METHODNAME','NewTriggerHelper');
        //system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        SalesQuotaTriggerHelper newHelper = new SalesQuotaTriggerHelper(pUserProfileName);
        return newHelper;
    }
    
/*
** @author : Cloud Sherpas, Inc.
** @date : 04/23/2014
** @description : this method is the class constructor
** @paramaters : none
** @returns : nothing
*/
    private SalesQuotaTriggerHelper(String pUserProfileName){  
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','SalesQuotaTriggerHelper');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        UserProfileName = pUserProfileName;
    }
    
/*
** @author : Cloud Sherpas, Inc.
** @date : 04/23/2014
** @description : Populate the Sales Quota's fields with those of the related user's field.
** @paramaters : List of updated Users
** @returns : nothing
*/   
    public void populateSalesQuotasFields(List<Sales_Quotas__c> pSalesQuotas){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populateSalesQuotasFields');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        Map<Id,User> UserMap = new Map<Id,User>();
        Map<Id,String> UserManagerMap = new Map<Id,String>();
        set<Id> UserManagerSet = new set<Id>();
        set<Id> salesQuotasUserIds = new set<Id>();
        for(Sales_Quotas__c sq : pSalesQuotas){
            salesQuotasUserIds.add(sq.Name__c);
        }
        if(salesQuotasUserIds.size() >0){
            for(User usr : [SELECT Id, Name, ManagerId, Title, Extension, Phone, Organisation__c,  DefaultCurrencyIsoCode, PositionSalesGroup__c, PositionSalesChannel__c, UserPositionRegion__c, Division__c, Location__c, Status__c FROM User WHERE Id IN:salesQuotasUserIds]){
                UserMap.put(usr.Id, usr);
                UserManagerSet.add(usr.ManagerId);
            }
        }
        for(User usr : [SELECT Id, Name, Alias, ManagerId FROM User WHERE Id IN: UserManagerSet]){
            UserManagerMap.put(usr.Id, usr.Alias);
        }
        if(UserMap.size() > 0){
            for(Sales_Quotas__c sq : pSalesQuotas){
                sq.CurrencyIsoCode = UserMap.get(sq.Name__c).DefaultCurrencyIsoCode;
                sq.Organisation__c = UserMap.get(sq.Name__c).Organisation__c;
                sq.Ext__c = UserMap.get(sq.Name__c).Extension;
                sq.Name = UserMap.get(sq.Name__c).Name;
                sq.Position__c = UserMap.get(sq.Name__c).Title;
                sq.WorkPhone__c = UserMap.get(sq.Name__c).Phone;
                sq.Division__c = UserMap.get(sq.Name__c).Division__c ;
                sq.Location__c = UserMap.get(sq.Name__c).Location__c ;
                sq.Status__c = UserMap.get(sq.Name__c).Status__c ;
            }
        }
    } 
}