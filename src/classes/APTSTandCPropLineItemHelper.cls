/*
** @author :Apttus
** @date : 06/06/2016
** @description : Terms_and_Conditions_Proposal_Line_Item__c trigger helper class 
*/
public without sharing class APTSTandCPropLineItemHelper {

    final String CLASSNAME = '\n\n**** APTSTandCPropLineItemHelper.METHODNAME()';
    
      public static APTSTandCPropLineItemHelper NewTriggerHelper(){

        APTSTandCPropLineItemHelper newHelper = new APTSTandCPropLineItemHelper();
        return newHelper;
    }
     private APTSTandCPropLineItemHelper(){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','APTSTandCPropLineItemHelper');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
    }
    
     /*
    ** @author : Apttus
    ** @date : 06/06/2016
    ** @description : this method copies the term text of terms and conditions proposal line item to proposal line item
    ** @paramaters : list of Terms_and_Conditions_Proposal_Line_Item__c records
    ** @returns : nothing
    ** @Updated: changed By: Viraj Rana , Date:11/18/2016 , I-244118/S-452858 - Error When Finalizing Card With Monster Standard Job Ad
    */
    public void populateTandC (Terms_and_Conditions_Proposal_Line_Item__c[] TandCList){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populateTandC');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        Set<Apttus_Proposal__Proposal_Line_Item__c> PLIset = new Set<Apttus_Proposal__Proposal_Line_Item__c>();
        Set<Id> PLIIDset = new Set<Id>();
        List<Apttus_Proposal__Proposal_Line_Item__c> PLIList = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        for(Terms_and_Conditions_Proposal_Line_Item__c TandC :TandCList){
            
            
            //I-244118/S-452858 - Error When Finalizing Card With Monster Standard Job Ad
            //Changed By: Viraj Rana: updated if condition.
            if(TandC.Proposal_Line_Item__c!=null && !PLIIDset.contains(TandC.Proposal_Line_Item__c)){
                Apttus_Proposal__Proposal_Line_Item__c pLI = new Apttus_Proposal__Proposal_Line_Item__c();
                pLI.ID=TandC.Proposal_Line_Item__c;
                pLI.Terms_and_Condition_Term_Text__c=TandC.Term_text__c;
                PLIset.add(pLI);
                PLIIDset.add(pLI.ID);
            }
        }
        
        if(!PLIset.isEmpty()){
            PLIList.addAll(PLIset);
            ApttusProposalLineItemTriggerHandler.ExecuteTriggers=false;
            update PLIList;
        }
    }
    
        
}