/*
** @author : APTTUS
** @date : 08/10/2015
** @description : Opportunity Approval Request Cancellation and email notification process
** is done in this class which run asynchronously.
** Story#: S-323572 
*/
public class APTS_QueueOppAprrovalRejectEmail implements Queueable {
    private Set<Id> oppsWhichNeedsToBeCancelled;
    private map<string,string> reasonForRejections = new map<string,string>();
    
    public APTS_QueueOppAprrovalRejectEmail(Set<Id> oppsWhichNeedsToBeCancelled,map<string,string> reasonForRejections)
    {        
        this.oppsWhichNeedsToBeCancelled = oppsWhichNeedsToBeCancelled;
        this.reasonForRejections = reasonForRejections;       
    }
    
    public void execute(QueueableContext context) {
        List<Opportunity> opportunitiesToUpdateStatus = new  List<Opportunity>();
        for(Id oppId:oppsWhichNeedsToBeCancelled)   
        {
            Apttus_Approval.ApprovalsWebService.cancelApprovals('Opportunity',oppId);
            opportunitiesToUpdateStatus.add(new Opportunity(Id=oppId,Apttus_Approval__Approval_Status__c='Rejected'));
        }         
        SendEmailProcess();
        update opportunitiesToUpdateStatus;
    }
    
    //Create email for individual user
    private Messaging.SingleEmailMessage CreateEmailMsg(string receiverEmail,string emailBody,string emailSubject){
        if(string.isNotBlank(receiverEmail)){                     	
            Messaging.SingleEmailMessage EMail = new Messaging.SingleEmailmessage();
            EMail.setToAddresses(new String[]{receiverEmail});
			EMail.setHtmlBody(emailBody);
			EMail.setSubject(emailSubject);
            EMail.saveAsActivity = false;   
            return EMail;
        }
        return null;
    } 
    
    //Send Email to all users which are eligible.
    private void SendEmailProcess()
    {
        String url = 'https://' + System.URL.getSalesforceBaseUrl().getHost().remove('-api' ) + '/' ;
        
        Map<Id,Opportunity> oppInfoMap = new Map<Id,Opportunity>([Select Id,Name,Account.Name,Amount,Owner.Name,Owner.email,OwnerId,SecondarySalesRep__c,SecondarySalesRep__r.Name,SecondarySalesRep__r.email from Opportunity where ID IN:oppsWhichNeedsToBeCancelled]);
        List<OpportunityTeamMember__c> salesRepOppTeamMembers = [Select Id,Opportunity__c,TeamMember__c,TeamMember__r.Name,TeamMember__r.email from OpportunityTeamMember__c where Opportunity__c IN:oppsWhichNeedsToBeCancelled AND TeamRole__c='Sales Rep'];
        Map<Id,List<EmailOpportunityInfo>> OppUsersWhereEmailWillBeSent = new Map<Id,List<EmailOpportunityInfo>>();
             
        for(Id currentOppId:oppInfoMap.keySet())
        {
            List<EmailOpportunityInfo> emailOppInfos = new List<EmailOpportunityInfo>();
            Opportunity currentOpp = oppInfoMap.get(currentOppId);
            
            //Prepare email info for Primary Sales Rep
            if(currentOpp.Owner.email != null)
            {
                EmailOpportunityInfo primarySalesRepOppInfo = new EmailOpportunityInfo();
                primarySalesRepOppInfo.ReceiverEmail = currentOpp.Owner.email;
                primarySalesRepOppInfo.ReceiverName = currentOpp.Owner.Name;
                primarySalesRepOppInfo.Opp = currentOpp;
                primarySalesRepOppInfo.RejectionReason = reasonForRejections.get(currentOppId);
                primarySalesRepOppInfo.OppURL = url + currentOppId;
                emailOppInfos.add(primarySalesRepOppInfo);
            }
            
            //Prepare email info for Secondary Sales Rep
            if(currentOpp.SecondarySalesRep__r.email != null)
            {
                EmailOpportunityInfo secondarySalesRepOppInfo = new EmailOpportunityInfo();
                secondarySalesRepOppInfo.ReceiverEmail = currentOpp.SecondarySalesRep__r.email;
                secondarySalesRepOppInfo.ReceiverName = currentOpp.SecondarySalesRep__r.Name;
                secondarySalesRepOppInfo.Opp = currentOpp;
                secondarySalesRepOppInfo.RejectionReason = reasonForRejections.get(currentOppId);
                secondarySalesRepOppInfo.OppURL = url + currentOppId;
                emailOppInfos.add(secondarySalesRepOppInfo);
            }
            
            OppUsersWhereEmailWillBeSent.put(currentOppId, emailOppInfos);
        }
        
        //Prepare info for all those opportunity team members whose Team Role is 'Sales Rep'
        for(OpportunityTeamMember__c currentTeamMember:salesRepOppTeamMembers)
        {
            if(oppInfoMap.containsKey(currentTeamMember.Opportunity__c))
            {
                Opportunity teamMemberOpp = oppInfoMap.get(currentTeamMember.Opportunity__c);    
                List<EmailOpportunityInfo> emailOppInfos = new List<EmailOpportunityInfo>();
                if(OppUsersWhereEmailWillBeSent.containsKey(currentTeamMember.Opportunity__c))
                {
                    emailOppInfos = OppUsersWhereEmailWillBeSent.get(currentTeamMember.Opportunity__c);
                }
                EmailOpportunityInfo teamMemberOppInfo = new EmailOpportunityInfo();
                teamMemberOppInfo.ReceiverEmail = currentTeamMember.TeamMember__r.email;
                teamMemberOppInfo.ReceiverName = currentTeamMember.TeamMember__r.Name;
                teamMemberOppInfo.Opp = teamMemberOpp;
                teamMemberOppInfo.RejectionReason = reasonForRejections.get(currentTeamMember.Opportunity__c);
                teamMemberOppInfo.OppURL = url + currentTeamMember.Opportunity__c;
                emailOppInfos.add(teamMemberOppInfo);
                OppUsersWhereEmailWillBeSent.put(currentTeamMember.Opportunity__c, emailOppInfos);
            }
        }
       EmailTemplate templateToGetBody = [Select Body from EmailTemplate Where Name='Opportunity Approval Rejection Email' LIMIT 1];
        if(oppsWhichNeedsToBeCancelled.size() > 0)
        {
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            
            for(Id oppId:oppsWhichNeedsToBeCancelled)   
            {
                //Cancel Approvals.
                Apttus_Approval.ApprovalsWebService.cancelApprovals('Opportunity',oppId);
                if(OppUsersWhereEmailWillBeSent.containsKey(oppId))
                {   
                 
                    for(EmailOpportunityInfo emailOppInfo:OppUsersWhereEmailWillBeSent.get(oppId))
                    {
                        string emailBody = GetCancellationEmailBody(emailOppInfo,templateToGetBody);                       
                        Messaging.SingleEmailMessage singleEmailMsg= CreateEmailMsg(emailOppInfo.ReceiverEmail,emailBody,'Approval request is rejected for opportunity: ' + emailOppInfo.Opp.Name);
                        if(singleEmailMsg != null)
                        {
                            emailList.add(singleEmailMsg);
                        }
                       
                    }
                }
            }
            
            //Send email to all elgible users
            if(emailList != null && emailList.size() > 0)
            {
                Messaging.sendEmail(emailList); 
            }
        }
    }
    
  
    //Body of Email
    private string GetCancellationEmailBody(EmailOpportunityInfo emailOppInfo,EmailTemplate templateToGetBody)
    {
         /*string  htmlBody = '<html>';
				htmlBody += '<head>';
				htmlBody +=	'<meta http-equiv="Content-Type" content="text/html; charset=utf-8"></head>';
				htmlBody +=	'<body>';
                htmlBody +=	'[[USERNAME]]:';
                htmlBody +=	'<br><br>';
                htmlBody +=	'Approval Request for Opportunity "[[OPPNAME]]" has been cancelled.';
                htmlBody +=	'<br><br>Opportunity Name: <span id="j_id0:emailTemplate:j_id3:j_id4:j_id24:j_id25:j_id45">[[OPPNAME]]</span>';
    			htmlBody +=	'<br>Owner Full Name: <span id="j_id0:emailTemplate:j_id3:j_id4:j_id24:j_id25:j_id48">[[OWNERNAME]]</span>';
    			htmlBody +=	'<br>Account Name: <span id="j_id0:emailTemplate:j_id3:j_id4:j_id24:j_id25:j_id51">[[ACCOUNTNAME]]</span>';
    			htmlBody +=	'<br>Amount: [[AMOUNT]]';
        		htmlBody +=	'<br>Rejection Reason: [[REJECTIONREASON]]';
                htmlBody +=	'<br>';
                htmlBody +=	'<br>';
                htmlBody +=	'<br>Click on the link below to access the Opportunity:';
                htmlBody +=	'<br><a href="[[OPPURL]]">[[OPPNAME]]</a>';
                htmlBody +=	'<br>';
                htmlBody +=	'<br>';
                htmlBody +=	'<br>';
                htmlBody +=	'</body>';
                htmlBody +=	'</html>';
        */
        	  string  htmlBody = '';
              if(templateToGetBody != null && string.isNotBlank(templateToGetBody.Body))
              {
                  htmlBody = templateToGetBody.Body;
                  htmlBody = htmlBody.replace('[[USERNAME]]', emailOppInfo.ReceiverName);
                  htmlBody = htmlBody.replace('[[OPPNAME]]', emailOppInfo.Opp.Name);
                  htmlBody = htmlBody.replace('[[OWNERNAME]]', emailOppInfo.Opp.Owner.Name);        
                  htmlBody = htmlBody.replace('[[AMOUNT]]', string.valueOf(emailOppInfo.Opp.Amount));
                  htmlBody = htmlBody.replace('[[REJECTIONREASON]]', emailOppInfo.RejectionReason);
                  htmlBody = htmlBody.replace('[[ACCOUNTNAME]]', emailOppInfo.Opp.Account.Name);
                  htmlBody = htmlBody.replace('[[OPPURL]]', emailOppInfo.OppURL);
              }
              return htmlBody;
                  
    }
    
    //Wrapper class which contains the individual email informations
    private class EmailOpportunityInfo
    {
        public string ReceiverEmail {get;set;}
        public string ReceiverName {get;set;}
        public Opportunity Opp {get;set;}
        public string RejectionReason {get;set;}
        public string OppURL {get;set;}
    }
}