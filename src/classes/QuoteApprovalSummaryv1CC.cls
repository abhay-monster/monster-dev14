/*
* @description A second controller for QuoteApprovalSummaryv1 page.
* @author Cloudsherpas
* @date 7-31-2014
* @param none
* @returns none
*/
public class QuoteApprovalSummaryv1CC {
    public Apttus_Approval__Approval_Request__c apptus{get;set;}
    public QuoteApprovalSummaryv1CC(ApexPages.StandardController controller){
        apptus = new Apttus_Approval__Approval_Request__c();
    } 
    
    /*
    * @description Approve method that saves on Approve the values entered by the user on the Approval request.
    * @author Cloudsherpas
    * @date 7-31-2014
    * @param none
    * @returns: on approve return to proposal.
    */
    
    public pagereference approve(){
        Id ApprovalRequestId = ApexPages.currentPage().getParameters().get('id');
        Id proposalid;
        Apttus_Approval__Approval_Request__c aaar = [SELECT Id,
                                                            RejectedReason__c,
                                                            Apttus_Approval__Approver_Comments__c,
                                                            Apttus_QPApprov__ProposalId__c,
                                                            Apttus_Approval__Assigned_To_Name__c,
                                                            Apttus_Approval__PrevAssignedToName__c,
                                                            Apttus_Approval__Assigned_To_Id__c,
                                                            Apttus_Approval__PrevAssignedToId__c
                                                            FROM Apttus_Approval__Approval_Request__c WHERE id =: ApprovalRequestId];
       proposalid = aaar.Apttus_QPApprov__ProposalId__c;
       system.debug('*******aaar values'+aaar);
       Profile p = [Select Name from Profile where Id =: userinfo.getProfileid()];
       system.debug('profile name :'+p.name);
       system.debug('getName() :'+userinfo.getName());
       system.debug('current username  :'+userinfo.getUserName());
       system.debug('get userid :'+userinfo.getUserId());
       if(aaar.Apttus_Approval__Assigned_To_Name__c  != userinfo.getName()){
          /* Sales Operations profile user should be able to approve any Requests 
           * if the current user is a Sales Operations profile and the request is not assigned to him then assigne the request and call the webservice for approval.
          */
           if(p.name.contains('Sales Operations')){
               aaar.Apttus_Approval__PrevAssignedToName__c = aaar.Apttus_Approval__Assigned_To_Name__c;
               aaar.Apttus_Approval__PrevAssignedToId__c = aaar.Apttus_Approval__Assigned_To_Id__c;
               aaar.Apttus_Approval__Assigned_To_Id__c = userinfo.getUserId();
               aaar.Apttus_Approval__Assigned_To_Name__c = userinfo.getName();
               try{
                   update aaar;
               }catch (DmlException de) {
                        Integer numErrors = de.getNumDml();
                        String Ex = '';
                        System.debug('getNumDml=' + numErrors);
                        for(Integer i=0;i<numErrors;i++) {
                            //System.debug('getDmlFieldNames=' + de.getDmlFieldNames(i));
                            //System.debug('getDmlMessage=' + de.getDmlMessage(i)); 
                             Ex += de.getDmlMessage(i);
                        }
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,Ex));
                        return null;
               }
           }
       }
       system.debug('updated AAAR :'+aaar);
       Boolean status;
       if(!test.isrunningTest())
           status = Apttus_Approval.ApprovalsWebService.approveRequest(ApprovalRequestId,apptus.Apttus_Approval__Approver_Comments__c);
       else
           status = true;
           
           system.debug('status :'+status);
           if(status){
               PageReference CRPage = new PageReference('/'+ proposalid);
               CRPage.setRedirect(true);
               return CRPage;
           }
       return null;
    }
    
    /*
    * @description A method that saves on Reject the values entered by the user on the Approval request.
    * @author Cloudsherpas
    * @date 7-31-2014
    * @param none
    * @returns none
    */

    public pagereference save(){
        Id ApprovalRequestId = ApexPages.currentPage().getParameters().get('id');
        Id proposalid;
        system.debug('^ApprovalRequestId: '+ ApprovalRequestId);
        List<Apttus_Approval__Approval_Request__c> ApprovalRequestListToUpdate = new List<Apttus_Approval__Approval_Request__c>();
        for(Apttus_Approval__Approval_Request__c aaar : [SELECT Id, RejectedReason__c, Apttus_Approval__Approver_Comments__c, Apttus_QPApprov__ProposalId__c FROM Apttus_Approval__Approval_Request__c WHERE id =: ApprovalRequestId]){
            system.debug('^apptus.RejectedReason__c: '+ apptus.RejectedReason__c);
            proposalid = aaar.Apttus_QPApprov__ProposalId__c;
            aaar.RejectedReason__c = apptus.RejectedReason__c;
            if(apptus.RejectedReason__c == null){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please specify Rejected Reason'));
                return null;
            }
            String prevComment ='';
            if(aaar.Apttus_Approval__Approver_Comments__c != null){
                prevComment = aaar.Apttus_Approval__Approver_Comments__c+ '\n\n ';
            }else{
                prevComment = '';
            }
            aaar.Apttus_Approval__Approver_Comments__c = prevComment + Datetime.now()+'\n('+userinfo.getName() +') '+ apptus.Apttus_Approval__Approver_Comments__c;
            aaar.Apttus_Approval__Approval_Status__c = 'Rejected';
            
            ApprovalRequestListToUpdate.add(aaar);
        }
        system.debug('^ApprovalRequestListToUpdate: '+ ApprovalRequestListToUpdate);
        if(!ApprovalRequestListToUpdate.isEmpty()){
            try{
                update ApprovalRequestListToUpdate;
            }catch (DmlException de) {
                Integer numErrors = de.getNumDml();
                String Ex = '';
                System.debug('getNumDml=' + numErrors);
                for(Integer i=0;i<numErrors;i++) {
                    //System.debug('getDmlFieldNames=' + de.getDmlFieldNames(i));
                    //System.debug('getDmlMessage=' + de.getDmlMessage(i)); 
                     Ex += de.getDmlMessage(i);
                }
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,Ex));
                return null;
             }
                             
            
        }
        Apttus_Proposal__Proposal__c prop = [select id, Apttus_QPApprov__Approval_Status__c from Apttus_Proposal__Proposal__c where id =:proposalid];
        if(prop!= null){
        prop.Apttus_QPApprov__Approval_Status__c  = 'Rejected';
        update prop;
        }
        PageReference CRPage = new PageReference('/'+ proposalid);
        CRPage.setRedirect(true);
        return CRPage;
    }
}