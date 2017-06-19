/*
** @author : ???.
** @date : 03/04/2014
** @description : AccountCreation class to handle CRUD events.
**
*/

public with sharing class AccountCreation {
    public string stringURL{get;set;}
    
    public AccountCreation(ApexPages.StandardController controller){
    }
    public void executeMethod(){
        //get the object prefix for Sales_Quotas__c = a48
        DescribeSObjectResult r = Account.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        //get the URL
        String orig = URL.getCurrentRequestUrl().toExternalForm();
        //Modify the URL
        String orig2 = orig.replace('apex/AccountCreation',keyPrefix +'/e').replace('&save_new=1','').replace('&sfdc.override=1','&nooverride=1');
        String AccountOrg;
        for(User u: [SELECT Id, Organisation__c FROM USER WHERE Id =: UserInfo.getUserId()]){
            AccountOrg = u.Organisation__c;
        }
        FieldsId__c AccountFields = FieldsId__c.getValues('AccountOrganization');
        String org = AccountFields.Id__c;
        if(AccountOrg != null){
            stringURL = orig2 + '&'+ org +'='+ AccountOrg;
        }else{
            stringURL= orig2;
        }
    } 
}