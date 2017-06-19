/*
** @author : Cloud Sherpas Inc.
** @date : 04/29/2014
** @description :This page overrides the URL upon clicking the new button. 
*/
public class CreateSalesQuotaCC{
    public string stringURL{get;set;}
    public CreateSalesQuotaCC(ApexPages.StandardController controller){
        //get the object prefix for Sales_Quotas__c = a48
        DescribeSObjectResult r = Sales_Quotas__c.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        //get the URL
        String orig = URL.getCurrentRequestUrl().toExternalForm();
        //Modify the URL
        String orig2 = orig.replace('apex/CreateSalesQuota',keyPrefix +'/e').replace('&save_new=1','').replace('&sfdc.override=1','');
        stringURL = orig2+'&Name=Leave%20Blank&nooverride=1' ;
    } 
    
}