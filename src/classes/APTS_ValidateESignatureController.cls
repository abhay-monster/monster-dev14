public class APTS_ValidateESignatureController
{
    public string ProposalId {get;set;}
    public boolean IsBadCreditStatus {get;set;}
   
    public void ValidateForEsignature()
    {
        IsBadCreditStatus = false;
        ProposalId = ApexPages.CurrentPage().getParameters().get('id');
        List<Apttus_Proposal__Proposal__c>  approvalRequests=  [Select Id,APTS_Credit_Status__c from Apttus_Proposal__Proposal__c where Id=: ProposalId ];
        
        if(approvalRequests != null && approvalRequests.size() > 0)
        {
        
            Apttus_Proposal__Proposal__c currentProposal = approvalRequests[0];            
            if(currentProposal.APTS_Credit_Status__c != null &&  currentProposal.APTS_Credit_Status__c != 'Ok')
            {
                IsBadCreditStatus = true;
            }
        }
    }

}