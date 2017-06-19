//Classes header section:
/**
 * Company     : Apttus Inc.
 * Description: A class that performs functionality of sync with opportunity button on Proposal page
 * History     : 
 * [22.MAY.2015] Sweety Agrawal    - Code creation
 */


public class APTS_SyncWithOpportunityController  {
    //ID
    public ID ProposalID { get; set; }
    //STATIC FINAL    
    private static final string ID_PAGE_PARAMETER = 'ID';
    //List
    List<Apttus_Proposal__Proposal_Line_Item__c> lstProposallineItem = new List<Apttus_Proposal__Proposal_Line_Item__c>();
    //SObject
    Apttus_Proposal__Proposal_Line_Item__c oProposallineItem { get; set; }
        
    //Constructor
    public APTS_SyncWithOpportunityController(){
         //Fetch query variables and assign back
        ProposalID =  ApexPages.currentPage().getParameters().get(ID_PAGE_PARAMETER);
        
    }
    
    public PageReference SyncWithOpportunity()
    {
        pagereference pg = null;
        Map<Id, Apttus_Proposal__Proposal_Line_Item__c> mapNewProposalLineItem = new Map<Id,Apttus_Proposal__Proposal_Line_Item__c>();
        
        try{
         	
            lstProposallineItem = [SELECT Id from Apttus_Proposal__Proposal_Line_Item__c where Apttus_Proposal__Proposal__c = :ProposalID];                            
            for(Apttus_Proposal__Proposal_Line_Item__c oProposalLineItem : lstProposallineItem)
            {
                mapNewProposalLineItem.put(oProposalLineItem.id, oProposalLineItem);
            }            
            
            ApttusProposalLineItemTriggerHandler.syncLineItemsWithOpportunityLineItems(lstProposallineItem, mapNewProposalLineItem);
            pg = new pagereference('/'+ProposalID);
        }
        catch(Exception ex){
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, ex.getMessage())); 
        } 
        System.debug('pg'+pg);     
        return pg;  
    }
}