//------------------------------------------------------------------------------------------------------------
//  Name: XCodeTriggerHandler 
//  Date: 04/09/2015
//  Author: Gaurav (Appirio Ind.)
//  Purpose: Trigger handler on Xcode__c Object.
//------------------------------------------------------------------------------------------------------------

public without sharing class XCodeTriggerHandler {

    public void afterInsert(Xcode__c[] newXCodes , Map<id,Xcode__c> mapNewXcode)
    {        
            insertAccountXcodes(newXCodes );
    }
    
    
    
    private void insertAccountXcodes(Xcode__c[] newXCodes){
    
        List<XcodeAccount__c> lstXcodeAccounts = new List<XcodeAccount__c>();
        XcodeAccount__c newXcodeAccount;
        for(Xcode__c xCode : newXCodes){
            //system.assert(false , xCode.Created_For_Account__c);
            if(xCode.Created_For_Account__c != Null){
               newXcodeAccount = new XcodeAccount__c ();
               newXcodeAccount.Account__c =  xCode.Created_For_Account__c ;
               newXcodeAccount.Xcode__c = xCode.id;
               lstXcodeAccounts.add(newXcodeAccount);
            }  
        }
        
        if(lstXcodeAccounts.size() > 0)
            insert lstXcodeAccounts ;
    }
}