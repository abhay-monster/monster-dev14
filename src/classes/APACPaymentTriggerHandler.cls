/**=====================================================================
* Appirio, Inc
* Trigger Name: APACPaymentTriggerHandler
* Description: Trigger handler class for custom object APTS_APAC_Payment__c
* Created Date: [08/08/2016]
* Created By: Gaurav Gupta (Appirio)
*
* Date Modified                Modified By                  Description of the update
=====================================================================*/
public without sharing class APACPaymentTriggerHandler{
    
/**=====================================================================
** @author : (Gaurav Gupta)Appirio, Inc
** @date : [08/08/2016]
** @description : Handler beforeinsert logic of custom object APTS_APAC_Payment__c
** @paramaters : nothing
** @returns : nothing
** Date Modified                Modified By                  Description of the update
=====================================================================*/   
    public void beforeInsert(List<APTS_APAC_Payment__c> apacPaymentNewList, Map<Id, APTS_APAC_Payment__c> oldMap){
        checkForBackDatedQuotes(apacPaymentNewList);
        
    }
/**=====================================================================
** @author : Appirio, Inc
** @date : [08/08/2016]
** @description : Handler before Update logic of custom object APTS_APAC_Payment__c
** @paramaters : nothing
** @returns : nothing
** Date Modified                Modified By                  Description of the update
=====================================================================*/  
    public void beforeUpdate(List<APTS_APAC_Payment__c> apacPaymentNewList, Map<Id, APTS_APAC_Payment__c> oldMap){
        checkForBackDatedQuotes(apacPaymentNewList);
    }
    
    
    
    private void checkForBackDatedQuotes(List<APTS_APAC_Payment__c> apacPaymentNewList){
        list<id> lstProposalIds = new list<id> ();
        for (APTS_APAC_Payment__c apac : apacPaymentNewList){
            lstProposalIds.add(apac.Proposal__c);
        }
        
        list<order__c> lstorders = [select OrderDate__c from Order__c where QuoteProposal__c IN :lstProposalIds order by OrderDate__c DESC LIMIT 1] ;
        date MaxOrderDate ;
        if(lstorders.size() > 0){
            MaxOrderDate = lstorders [0].OrderDate__c ;
            
            for (APTS_APAC_Payment__c apac : apacPaymentNewList){
                if(apac.Due_Date__c < MaxOrderDate )
                    apac.adderror('Selected date is prior to Proposal date ,please select today\'s date or a future date');
            }
            
        }

    }
    
    
}