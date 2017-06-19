/*
* Purpose : This class handles the submit approval functionality of Proposal.
* Created Date : July-07-2015
*/

public with sharing class APTS_ApprovalSubmissionController{  
    
    Id proposalId;
    Apttus_Config2__ProductConfiguration__c configuration;
    List<Apttus_Approval__Approval_Request__c> AllApprovalRequests ;
    Apttus_Approval.SubmissionComments cmnts;
     boolean isStepLevelComment = false;
     boolean isProcessLevelComment = false;
    Map<string,Apttus_Approval.SubmissionComments.StepComment> stepCmntsMap = new Map<string,Apttus_Approval.SubmissionComments.StepComment>();
    public List<ApprovalStep> AllApprovalSteps {get;set;}
    public String SubmitComment {get;set;}
    public Boolean ShowApprovalStepSection {get;set;}
    public Boolean ShowOkButtonAndCommentSection {get;set;}
    public APTS_ApprovalSubmissionController()
    {
        proposalId = ApexPages.CurrentPage().getParameters().get('sObjectId');
        system.debug('proposalId-->' + proposalId);
        AllApprovalSteps = new  List<ApprovalStep>();
        ShowApprovalStepSection = true;
        ShowOkButtonAndCommentSection = false;
    }
    
    public PageReference BackToProposal()
    {
        PageReference returnPage = new PageReference('/' + proposalId);                        
        return returnPage; 
    }
    
    public PageReference SubmitApproval()
    {
        //PageReference returnPage = new PageReference('/' + proposalId);                        
        //return returnPage; 
        ShowApprovalStepSection = false;
        ShowOkButtonAndCommentSection = true;
       return null;
    }
    
    public PageReference doOk()
    {
        
        if(string.isEmpty(SubmitComment))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Approval comment is required.'));
            return null;
        }
        else
        {
            boolean isApprovalSubmited = false;
            if(isStepLevelComment)
            {
                for(ApprovalStep currentApproval:AllApprovalSteps)
                {
                    if(currentApproval.VisibleCommentField)
                    {
                        if(stepCmntsMap.ContainsKey(currentApproval.StepName))
                        {
                            Apttus_Approval.SubmissionComments.StepComment currentStep = stepCmntsMap.get(currentApproval.StepName);
                            currentStep.setStepComment(currentApproval.Comment);
                             cmnts.addStepComment(currentStep);
                        }
                       
                    }
                }
            }
            if(isProcessLevelComment)
            {
                cmnts.setProcessComment(SubmitComment);
            }
            if(isProcessLevelComment || isStepLevelComment)
            {
                isApprovalSubmited = Apttus_Approval.ApprovalsWebService.submitForApprovals('Apttus_Config2__ProductConfiguration__c',configuration.Id);
            }
            else
            {
                isApprovalSubmited = Apttus_Approval.ApprovalsWebService.submitForApprovalsWithComments('Apttus_Config2__ProductConfiguration__c',configuration.Id,cmnts);
            }
            
            if(!isApprovalSubmited)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Approval couldn\'t submitted successfully' ));
                
            }
            else
            {
                Apttus_Proposal__Proposal__c proposalToUpdate = new Apttus_Proposal__Proposal__c(Id=proposalId,Approval_Comments__c=SubmitComment,Allow_To_Edit_Approval_Comment__c= True );
                update proposalToUpdate;
                proposalToUpdate.Allow_To_Edit_Approval_Comment__c = False;
                update proposalToUpdate;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Approval submitted successfully' ));
                
            }
        }
        ShowApprovalStepSection = false;
        ShowOkButtonAndCommentSection = false;
        return null;
    }
    
    //This method fetches all the attachments of agreement
    public PageReference PreviewApprovals()
    {
        try
        {
           configuration =  [Select Id,Apttus_Config2__VersionNumber__c,
                                Apttus_QPConfig__Proposald__r.APTS_Quote_Type__c
                             from Apttus_Config2__ProductConfiguration__c Where Apttus_QPConfig__Proposald__c =: proposalId
                             AND (Apttus_Config2__Status__c != 'Superseded' AND Apttus_Config2__Status__c != 'Abandoned' AND Apttus_Config2__Status__c != null )
                             Limit 1];
          if(configuration != null)
          {
             
                
                boolean isPreviewable = Apttus_Approval.ApprovalsWebService.previewApprovals('Apttus_Config2__ProductConfiguration__c',configuration.Id);
                boolean isApprovalRequired = Apttus_Approval.ApprovalsWebService.isApprovalRequired('Apttus_Config2__ProductConfiguration__c',configuration.Id);
                cmnts = Apttus_Approval.ApprovalsWebService.checkIfCommentsRequired(configuration.Id, 'Apttus_Config2__ProductConfiguration__c');
            
              List<Apttus_Approval.SubmissionComments.StepComment> stepCmnts = new List<Apttus_Approval.SubmissionComments.StepComment>();
            
              if(cmnts != null)
              {
                  
                  isStepLevelComment = cmnts.isStepLevelComment();
                  isProcessLevelComment = cmnts.isProcessLevelComment();
                  iF(isStepLevelComment)
                  {
                      stepCmnts = cmnts.getStepCommentList();
                      for(Apttus_Approval.SubmissionComments.StepComment stepCmnt:stepCmnts)
                      {
                          stepCmntsMap.put(stepCmnt.getStepName(),stepCmnt);
                      }
                  }
              }
              
               if(isPreviewable && isApprovalRequired)
               {
                   //AllApprovalRequests = new List<Apttus_Approval__Approval_Request__c>();
                   AllApprovalRequests = [Select Id,Apttus_Approval__StepNameLink__c,Apttus_Approval__StepSequence__c,Apttus_Approval__StepSequenceString__c,
                           Apttus_Approval__StepLabel__c,
                           Apttus_Approval__Sequence__c,
                           Apttus_Approval__Approval_Status__c,
                           Apttus_Approval__Assigned_To_Name__c,
                           Apttus_Approval__Request_Comments__c from Apttus_Approval__Approval_Request__c where Apttus_CQApprov__CartId__c =: configuration.Id Order By Apttus_Approval__StepSequence__c];
                   
                   for(Apttus_Approval__Approval_Request__c currentRequest:AllApprovalRequests)
                   {
                       ApprovalStep appStep;

                        boolean shouldCommentVisible = false;
                       if(isStepLevelComment && stepCmnts.size() > 0)
                       {
                           shouldCommentVisible = CheckIfCommentShouldbeVisible(currentRequest.Apttus_Approval__StepLabel__c);
                       }
                       
                       
                       
                       appStep = new ApprovalStep(currentRequest.Apttus_Approval__StepLabel__c,currentRequest.Apttus_Approval__StepSequenceString__c,currentRequest,currentRequest.Apttus_Approval__Request_Comments__c,shouldCommentVisible);
                                             
                       AllApprovalSteps.add(appStep);
                   }
               }
              else
              {
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'This record does not meet the entry criteria of any active approval processes. Please contact your administrator for assistance.' ));
                  ShowApprovalStepSection = False;
                  return null;
                  
              }
           }
           return null;
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error occured on PreviewApprovals: ' + ex.getMessage() + '  Line:' + ex.getLineNumber()));
            return null;
        }
    }
    
    private boolean CheckIfCommentShouldbeVisible(string stepName)
    {
        if(stepCmntsMap.containsKey(stepName))
            return true;        
        return false;
    }
    
    public class ApprovalStep
    {
        public string StepName {get;set;}
        public string StepSequence {get;set;}
        public List<Apttus_Approval__Approval_Request__c> requestsUnderCurrentStep {get;set;}
        public String Comment {get;set;}
        public boolean VisibleCommentField {get;set;}
        
        public ApprovalStep(string stepName,string stepSequence,Apttus_Approval__Approval_Request__c approvalRequest,string comment,boolean commentFieldVisible)
        {
            this.StepName = stepName;
            this.StepSequence = stepSequence;
            this.requestsUnderCurrentStep  = new List<Apttus_Approval__Approval_Request__c>{approvalRequest};
            this.Comment = comment;
            this.VisibleCommentField = commentFieldVisible;
        }
    }
}