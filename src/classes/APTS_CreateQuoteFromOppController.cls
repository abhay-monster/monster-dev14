public  class APTS_CreateQuoteFromOppController{
  
  // state
  
  // opportunity
  private ID opptyId = null;
  // proposal id
  private ID proposalId = null;
  
  private Opportunity curerntOpp;
    
    public boolean HasErrors {get;set;}
    /**
   * Class Constructor specifying initial values
   * @param stdController the standard controller
   */
    public APTS_CreateQuoteFromOppController() {
    
   // get the opportunity id
   //this.opptyId = stdController.getId();
   //system.debug('stdController.getId()-->' + stdController.getId());
    
    // read parameters
    this.opptyId = (Id)ApexPages.currentPage().getParameters().get('oppid');
    curerntOpp = GetOpporunity(this.opptyId);    
   
    }
    
    /**
   * Callback invoked when the page is loaded
   * @return the page reference 
   */
    public PageReference createAndRedirect() {
      
      PageReference pageRef = null; 
     
        try {
            
            Id newlyInsertedProposalId =  CreateProposal(opptyId); 
            
            if(newlyInsertedProposalId != null)
            {
                this.proposalId = newlyInsertedProposalId; 
                Apttus_Proposal__Proposal__c newProp = GetNewlyInsertedProposal(this.proposalId);
                System.debug('newProp******'+newProp);
                if(newProp.Apttus_QPConfig__PriceListId__c == null)
                {
                   pageRef = new PageReference('/' + this.proposalId + '/e?retURL=%2F' + this.proposalId);
                   pageRef.setRedirect(true);
                }
                else
                {    
                    pageRef = new PageReference('/apex/Apttus_QPConfig__ProposalConfiguration?id=' + this.proposalId + '&useAdvancedApproval=true');
                    //pageRef = new PageReference('/' + this.proposalId);
                }
            }
            
        } 
        catch (Exception ex)
        {         
            HasErrors  =true;
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            // report error
            ApexPages.addmessages(ex);  
        }
      
     
      return pageRef;
      
    }
    
  
    
  private Id CreateProposal(Id oppId)
  {
      Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c();
        try{            
                proposal.Apttus_Proposal__Opportunity__c = opptyId;
                proposal.Apttus_Proposal__Account__c  =curerntOpp.AccountId;
                proposal.Apttus_Proposal__Proposal_Name__c = curerntOpp.Name;
                proposal.APTS_Quote_Type__c = curerntOpp.OpportunityType__c;
                proposal.BillingAccount__c = curerntOpp.AccountId;

                if(curerntOpp.RecordType.Name == 'Rebill Opportunity'){

                    Id rebillQuoteRecId = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Rebill Proposal').getRecordTypeId();
                    proposal.RecordTypeId = rebillQuoteRecId; 
                }

                // Jeff L. Commented out due to issue: I-186011
                //proposal.BillContact__c = [Select Id,PrimaryBillingContact__c from Account WHERE ID=:curerntOpp.AccountId].PrimaryBillingContact__c;
                //proposal.PostingContact__c = [SELECT Id from Contact where AccountId =: curerntOpp.AccountId LIMIT 1].Id;
                
                insert proposal;
                system.debug('proposal.Apttus_QPConfig__PriceListId__c-->' + proposal.Apttus_QPConfig__PriceListId__c);
                return proposal.Id;
        }
      catch(Exception ex)
      {
          HasErrors = true;
          Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
          //system.debug('Error occured in CreateProposal :' + ex.getMessage());
          return null;
      }
  }
    
 private Apttus_Proposal__Proposal__c GetNewlyInsertedProposal(Id proposalId)
 {
    return [Select Name,Apttus_QPConfig__PriceListId__c,RecordType.Name from Apttus_Proposal__Proposal__c where Id =:proposalId LIMIT 1];
 }
      
  private Opportunity GetOpporunity(Id oppId)
  {
        return [Select Id,Name,AccountId,Account.Name,OpportunityType__c,RecordType.Name from Opportunity where Id=:oppId limit 1];     
  }
  
  /**
   * Performs the cancel action
   * @return the next page reference 
   */
  public PageReference doCancel() {
    // navigate to the opportunity 
    return new PageReference('/' + opptyId);
    
  }
    
     
      
}