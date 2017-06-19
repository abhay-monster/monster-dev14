/*
** @author : Cloud Sherpas Inc.
** @date : 04/27/2014
** @description :   class that supports the 'SalesAttainmentTriggerHandler' class; it provides the methods called from those classes
*/
public with sharing class SalesAttainmentTriggerHelper {
  final String CLASSNAME = '\n\n**** SalesAttainmentTriggerHelper.METHODNAME()';
    
    // ********* PROPERTIES ***********
    private String UserProfileName{get; private set;}
    
/*
** @author : Cloud Sherpas Inc.
** @date : 04/29/2014
** @description : static method that instantiates a new instance of the class & sets the user's profile name member variable
** @paramaters : a string - the profile name for the current user
** @returns : a new instance of the SalesQuotaTriggerHelper class
*/
    public static SalesAttainmentTriggerHelper NewTriggerHelper(String pUserProfileName){
        
        //final string METHODNAME = CLASSNAME.replace('METHODNAME','NewTriggerHelper');
        //system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        SalesAttainmentTriggerHelper newHelper = new SalesAttainmentTriggerHelper(pUserProfileName);
        return newHelper;
    }
    
/*
** @author : Cloud Sherpas, Inc.
** @date : 04/29/2014
** @description : this method is the class constructor
** @paramaters : none
** @returns : nothing
*/
    private SalesAttainmentTriggerHelper(String pUserProfileName){  
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','SalesAttainmentTriggerHelper');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        UserProfileName = pUserProfileName;
    }
 
/*
** @author : Cloud Sherpas, Inc.
** @date : 04/29/2014
** @description : Populate the Sales Attainment's fields with those of the related user's field.
** @paramaters : List of updated Users
** @returns : nothing
*/   
    public void populateSalesAttainmentFields(List<Sales_Attainment__c> pSalesAttainments){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populateSalesQuotasFields');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        Map<Id,Sales_Quotas__c> SalesQuotasMap = new Map<Id,Sales_Quotas__c>();
        set<Id> salesQuotasIds = new set<Id>();
        for(Sales_Attainment__c sa : pSalesAttainments){
            salesQuotasIds.add(sa.SalesQuota__c);
        }
        if(salesQuotasIds.size() >0){
            for(Sales_Quotas__c sq: [SELECT Id, Name__r.PositionSalesGroup__c, Name__r.PositionSalesChannel__c, Name__r.UserPositionRegion__c   FROM Sales_Quotas__c WHERE Id IN : salesQuotasIds]){
                SalesQuotasMap.put(sq.Id, sq);
                system.debug('\n\n\n\n PositionRegion__c: '+ sq.Name__r.UserPositionRegion__c);
            }
        }
        if(SalesQuotasMap.size() > 0){
            for(Sales_Attainment__c sa : pSalesAttainments){
                sa.PositionSalesGroup__c = SalesQuotasMap.get(sa.SalesQuota__c).Name__r.PositionSalesGroup__c ;
                sa.PositionSalesChannel__c = SalesQuotasMap.get(sa.SalesQuota__c).Name__r.PositionSalesChannel__c ;
                sa.PositionRegion__c = SalesQuotasMap.get(sa.SalesQuota__c).Name__r.UserPositionRegion__c ;
            }
        }
    }  

}