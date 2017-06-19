/*
** @author : Apptus- Viraj Rana.
** @date : 11/09/2016
** @description : To Escalte the Approval on Quote
*/

Public class APTS_EscalateApprovalOnQuote{
    Public List<String> lstAR {get;set;}
    Public String strARId {get;set;}
    public APTS_EscalateApprovalOnQuote(ApexPages.StandardController controller) {
        String queryString = ApexPages.currentPage().getParameters().get('id');
        System.debug('queryString ' + queryString );
        Apttus_Proposal__Proposal__c  objProposal = [Select id,Name from Apttus_Proposal__Proposal__c  where id =: queryString ];  
        lstAR = new List<String>();        
        
        List<Apttus_Approval__Approval_Request__c> lstApprovalRequest = [
                                                                            Select id,
                                                                                    ApprovalAction__c 
                                                                            From Apttus_Approval__Approval_Request__c 
                                                                            Where Quote_id__c =: objProposal.Name
                                                                        ];
        if(lstApprovalRequest.Size() > 0){
            for(Apttus_Approval__Approval_Request__c objRequest : lstApprovalRequest){
                System.debug('objRequest.ApprovalAction__c' + objRequest.ApprovalAction__c);
                if(!String.Isblank(objRequest.ApprovalAction__c) && objRequest.ApprovalAction__c.Contains('Escalate')){
                   lstAR.add(objRequest.Id);
                }
            }            
        }
        
        if(lstAR.Size() == 0 || lstApprovalRequest.Size() == 0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'There is no any approval to Escalate'));
            return ;
        }
        strARId = JSON.serialize(lstAR);
    }

    
    //Remote method will call the product method.
    @RemoteAction
    Public static String ApprovalRequestEscalate(String RequestID) {
        try {
            // invoke escalate webservice api call
            Apttus_Approval.ApprovalsWebService.escalateRequest(RequestID);
            return '';
            
        } catch (Exception ex) {
            return '';
            //return ex.getMessage();
        } 
    }
    
}