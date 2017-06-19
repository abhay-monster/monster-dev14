public without sharing class PropProdAttributeValueTriggerHelper {
  final String CLASSNAME = '\n\n**** PropProdAttributeValueTriggerHelper.METHODNAME()';
   
/*
** @author : Cloud Sherpas Inc.
** @date : 04/17/2014
** @description : static method that instantiates a new instance of the class & sets the user's profile name member variable
** @paramaters : a string - the profile name for the current user
** @returns : a new instance of the ApttusProposalLineItemTriggerHelper class
*/
       public static PropProdAttributeValueTriggerHelper NewTriggerHelper(string profilename){
       return NewTriggerHelper();
       }
    public static PropProdAttributeValueTriggerHelper NewTriggerHelper(){
        
        //final string METHODNAME = CLASSNAME.replace('METHODNAME','NewTriggerHelper');
        //system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        PropProdAttributeValueTriggerHelper newHelper = new PropProdAttributeValueTriggerHelper();
        return newHelper;
    }
    
/*
** @author : Cloud Sherpas, Inc.
** @date : 04/09/2014
** @description : this method is the class constructor
** @paramaters : String user profile name
** @returns : nothing
*/
    private PropProdAttributeValueTriggerHelper(){  
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','PropProdAttributeValueTriggerHelper');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
       
    }
 /*
** @author : Cloud Sherpas, Inc.
** @date : 06/30/2014
** @Story: 0813
** @element: E1713
** @description : this method updates the posting Location field on Proposal Line Item
** @paramaters : 
** @returns : nothing
*/
    public void updatePostingLocation(List<Apttus_QPConfig__ProposalProductAttributeValue__c> pUpdatedAttributeValues, map<ID, Apttus_QPConfig__ProposalProductAttributeValue__c> pUpdatedAttributeValuesToOldMap){  
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateChildPostingLocation');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        set<Id> pPAttributeValueIds = new set<Id>();
        Map<Id, Apttus_QPConfig__ProposalProductAttributeValue__c> pPAttributeValueMap = new map<Id,Apttus_QPConfig__ProposalProductAttributeValue__c>();
        for(Apttus_QPConfig__ProposalProductAttributeValue__c ppav : pUpdatedAttributeValues){
            if(ppav.Posting_Locations__c != pUpdatedAttributeValuesToOldMap.get(ppav.Id).Posting_Locations__c){
                pPAttributeValueIds.add(ppav.Apttus_QPConfig__LineItemId__c);
                pPAttributeValueMap.put(ppav.Apttus_QPConfig__LineItemId__c, ppav);
            }
        }
        List<Apttus_Proposal__Proposal_Line_Item__c> LineItemAttributeToUpdate = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        if(!pPAttributeValueIds.isEmpty()){
            for(Apttus_Proposal__Proposal_Line_Item__c lia : [SELECT Id, PostingLocation__c FROM Apttus_Proposal__Proposal_Line_Item__c WHERE Id IN: pPAttributeValueIds and Apttus_Proposal__Product__r.Messaging__c = true]){
                if(pPAttributeValueMap.get(lia.Id) != null){
                    lia.PostingLocation__c = pPAttributeValueMap.get(lia.Id).Posting_Locations__c;
                    LineItemAttributeToUpdate.add(lia);
                }
            }
        }
        try{
            if(!LineItemAttributeToUpdate.isEmpty()){
                update LineItemAttributeToUpdate;
            }
        }catch(Exception e){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Failed to update Posting Location. Please see system log for details.', e);
        }   
    }      
/*
** @author : Cloud Sherpas, Inc.
** @date : 06/30/2014
** @Story: 0813
** @element: E1713
** @description : this method populates the posting Location field on Proposal Line Item
** @paramaters : 
** @returns : nothing
*/
    public void populatePostingLocation(List<Apttus_QPConfig__ProposalProductAttributeValue__c> pUpdatedAttributeValues){  
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populatePostingLocation');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        set<Id> pPAttributeValueIds = new set<Id>();
        Map<Id, Apttus_QPConfig__ProposalProductAttributeValue__c> pPAttributeValueMap = new map<Id,Apttus_QPConfig__ProposalProductAttributeValue__c>();
        for(Apttus_QPConfig__ProposalProductAttributeValue__c ppav : pUpdatedAttributeValues){
                pPAttributeValueIds.add(ppav.Apttus_QPConfig__LineItemId__c);
                pPAttributeValueMap.put(ppav.Apttus_QPConfig__LineItemId__c, ppav);
        }
        List<Apttus_Proposal__Proposal_Line_Item__c> LineItemAttributeToUpdate = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        if(!pPAttributeValueIds.isEmpty()){
            for(Apttus_Proposal__Proposal_Line_Item__c lia : [SELECT Id, PostingLocation__c FROM Apttus_Proposal__Proposal_Line_Item__c WHERE Id IN: pPAttributeValueIds and Apttus_Proposal__Product__r.Messaging__c = true]){
                if(pPAttributeValueMap.get(lia.Id) != null){
                    lia.PostingLocation__c = pPAttributeValueMap.get(lia.Id).Posting_Locations__c;
                    LineItemAttributeToUpdate.add(lia);
                }
            }
        }
        try{
            if(!LineItemAttributeToUpdate.isEmpty()){
               update LineItemAttributeToUpdate;
            }   
        }catch(Exception e){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Cannot to populate Posting Location. Please see system log for details.', e);
        }
    }

    //SBerron - Appirio - 2/17/17 - S-442900
    //Writeback to opportunity line item.split_country__c
    //@param List of updated product attribute line item, map of old product attribute line items
    //@returns none
    public void updateOpptyLineItem(List<Apttus_QPConfig__ProposalProductAttributeValue__c> pUpdatedLineItems) {
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateOpptyLineItem');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        try {
            Set<Id> pLineItemIds = new Set <Id>();
            for (Apttus_QPConfig__ProposalProductAttributeValue__c pAttVal : pUpdatedLineItems) {
                pLineItemIds.add(pAttVal.Apttus_QPConfig__LineItemId__c);
            }

            Map<Id,OpportunityLineItem> propLineItemIdToOppLineItem = new Map<Id,OpportunityLineItem>();
            if (pLineItemIds != null) {
                for (OpportunityLineItem oppLineItem : [SELECT Id, Split_Country__c,Proposal_Line_Item__c, Proposal_Line_Item__r.PostingLocation__c FROM OpportunityLineItem WHERE Proposal_Line_Item__c IN :pLineItemIds]) {
                    propLineItemIdToOppLineItem.put(oppLineItem.Proposal_Line_Item__c, oppLineItem);
                }
            }
            System.debug('----propLineItemIdToOppLineItem ' + propLineItemIdToOppLineItem);

            List<OpportunityLineItem> opptyLineItemsToUpdate = new List<OpportunityLineItem>();
            if (propLineItemIdToOppLineItem != null) {
                //SBerron - 3/23/17 - changed picklist field where values are being pulled from to OpportunityLineItem.Split_Country__c
                Schema.DescribeFieldResult fieldResult = OpportunityLineItem.Split_Country__c.getDescribe();
                //Schema.DescribeFieldResult fieldResult = OpportunitySplit.Country__c.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                Set<String> lstPickvals=new Set<String>();
                for (Schema.PicklistEntry a : ple ) {
                    lstPickvals.add(a.getValue());
                }
                System.debug('----lstPickvals ' + lstPickvals);

                for (Apttus_QPConfig__ProposalProductAttributeValue__c prodAttValue : pUpdatedLineItems) {
                    if (propLineItemIdToOppLineItem.containsKey(prodAttValue.Apttus_QPConfig__LineItemId__c)) {
                        OpportunityLineItem oppLineItem = propLineItemIdToOppLineItem.get(prodAttValue.Apttus_QPConfig__LineItemId__c);
                        String lineItemLocation = propLineItemIdToOppLineItem.get(prodAttValue.Apttus_QPConfig__LineItemId__c).Proposal_Line_Item__r.PostingLocation__c;
                        String attributePostingLocation = prodAttValue.Posting_Locations__c;
                        String attributeCountry = prodAttValue.Country__c;

                        if (lineItemLocation != null && lstPickvals.contains(lineItemLocation)) {
                            oppLineItem.Split_Country__c = lineItemLocation;
                            opptyLineItemsToUpdate.add(oppLineItem);
                        }
                        else if (attributePostingLocation != null && lstPickvals.contains(attributePostingLocation)) {
                            oppLineItem.Split_Country__c = attributePostingLocation;
                            opptyLineItemsToUpdate.add(oppLineItem);
                        }
                        else if (attributeCountry != null && lstPickvals.contains(attributeCountry)) {
                            oppLineItem.Split_Country__c = attributeCountry;
                            opptyLineItemsToUpdate.add(oppLineItem);
                        }

                        System.debug('----lineItemLocation ' + lineItemLocation);
                        System.debug('----attributePostingLocation ' + attributePostingLocation);
                        System.debug('----attributeCountry ' + attributeCountry);
                    }
                }
            }
            System.debug('----opptyLineItemsToUpdate ' + opptyLineItemsToUpdate);
            if (opptyLineItemsToUpdate != null) {
                update opptyLineItemsToUpdate;
            }
        }
        catch (Exception e) {
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Cannot update opportunity line item split_country__c. Please see system log for details. ', e);
        }
    }
}