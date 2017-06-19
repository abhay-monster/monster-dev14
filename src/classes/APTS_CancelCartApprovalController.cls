public class APTS_CancelCartApprovalController
{
   
    Apttus_Config2__ProductConfiguration__c configuration;
    public boolean IsApprovalCancelled{get;set;}
    public String proposalId{get;set;}
    public APTS_CancelCartApprovalController()
    {
        proposalId = ApexPages.CurrentPage().getParameters().get('sObjectId');
    }
    
    public void CancelApprovalRequest()
    {
       configuration =  [Select Id,Apttus_Config2__VersionNumber__c from Apttus_Config2__ProductConfiguration__c Where Apttus_QPConfig__Proposald__c =: proposalId
                             AND (Apttus_Config2__Status__c != 'Superseded' AND Apttus_Config2__Status__c != 'Abandoned' AND Apttus_Config2__Status__c != null )
                             Limit 1];
         system.debug('configuration -->' + configuration);                
          if(configuration != null)
          {
              
                IsApprovalCancelled = Apttus_Approval.ApprovalsWebService.cancelApprovals('Apttus_Config2__ProductConfiguration__c',configuration.Id);
                system.debug('IsApprovalCancelled -->' + IsApprovalCancelled );  
          }
    }
}