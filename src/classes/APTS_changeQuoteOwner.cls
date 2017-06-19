public without sharing class APTS_changeQuoteOwner {
    /*
** @author : Apttus.
** @date : 06/30/2014
** @Story: 329971

** @description :  task ownership
** @paramaters : 
** @returns : nothing
*/
    private id ProposalId;
    
    public APTS_changeQuoteOwner()
    {
        ProposalId = System.currentPageReference().getParameters(). get( 'id' );
    }
    
    public PageReference ChangeOwner()
    {
        
        try{
            
            
          
            Apttus_Proposal__Proposal__c oProp= [Select Id, ownerId,Apttus_Proposal__Opportunity__c
                                                 from Apttus_Proposal__Proposal__c where id =:ProposalId];
            
            oProp.ownerId = UserInfo.getUserId();
            update oProp;
            
            List<OpportunityShare> OppList  = [select id,OpportunityAccessLevel,OpportunityId,UserOrGroupId FROM OpportunityShare 
                                               where UserOrGroupId = :oProp.ownerID  
                                               AND (OpportunityAccessLevel ='Edit' OR OpportunityAccessLevel = 'All')
                                               AND  OpportunityId = :oProp.Apttus_Proposal__Opportunity__c] ;
            If(OppList.size() <= 0)
            {
                OpportunityShare OppShare= new OpportunityShare();
                OppShare.OpportunityAccessLevel ='Edit';
                OppShare.OpportunityId =oProp.Apttus_Proposal__Opportunity__c;
                OppShare.UserOrGroupId = UserInfo.getUserId();
                System.debug('OppShare'+OppShare);
                insert OppShare;
            }
            List<Apttus_Proposal__Proposal__c>  proposalList = [select id, 
                                                                Apttus_Proposal__Opportunity__c ,                                                                
                                                                APTS_Quote_Type__c,
                                                                Latest_End_Date__c,RecordType.Name,Apttus_Proposal__Opportunity__r.RecordType.Name,
                                                                APTS_Enforce_Rollup_Summary_Calc__c,APTS_Fire_Approvals__c,Approval_Comments__c,
                                                                ownerId,
                                                                // Updated by Vrs
                                                                Agency__c,                                                                
                                                                TotalDiscount__c,
                                                                Manager1__c,
                                                                Discount_Authority_Manager1__c,
                                                                Manager2__c,
                                                                Discount_Authority_Manager2__c,
                                                                Manager3__c,
                                                                Discount_Authority_Manager3__c,
                                                                Manager4__c,
                                                                Discount_Authority_Manager4__c,
                                                                Manager5__c,
                                                                Discount_Authority_Manager5__c,
                                                                Manager6__c,
                                                                Discount_Authority_Manager6__c,
                                                                Manager7__c,
                                                                Discount_Authority_Manager7__c,
                                                                Manager8__c,
                                                                Discount_Authority_Manager8__c,
                                                                Manager9__c,
                                                                Discount_Authority_Manager9__c,
                                                                Manager10__c,
                                                                Discount_Authority_Manager10__c,
                                                                MidContract_Proposal__c,
                                                                Upgrade_Proposal__c,
                                                                Long_Term_Contract__c ,                                                        
                                                                Organization__c
                                                                from Apttus_Proposal__Proposal__c where id =:ProposalId];
            
            
            AptsQuoteApprovalHelper.updateManager(proposalList);
            proposalList[0].APTS_Fire_Approvals__c = false;
            ApttusProposalTriggerHandler.ExecuteTriggers = false;
            update proposalList;
            ApttusProposalTriggerHandler.ExecuteTriggers = true;
            
            PageReference Pg = new PageReference('/'+ProposalId);
            return Pg;
            
            return null;
        }
        
        catch(Exception e)
        {
            apexpages.addMessage(new apexpages.Message(apexpages.severity.ERROR,''+e.getMessage()));
            System.debug('System Error'+e.getLineNumber()+e.getMessage());
              return null;
        }
          return null;
    }
}