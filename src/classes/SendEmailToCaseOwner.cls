global class SendEmailToCaseOwner
{
    webservice static void sendEmail(Id csId) 
    { 
        Case cs = [SELECT Id, CaseNumber , ownerId FROM Case WHERE  Id = :csId];
        set<Id> userIds = new set<Id>();
        System.debug('==cs.ownerId ==='+cs.ownerId);
        for(GroupMember  gm : [Select Id, UserOrGroupId,GroupId,Group.type From GroupMember Where GroupId = :cs.ownerId ]){
            if (((String)gm.UserOrGroupId).startsWith('005'))
            {
                userIds.add(gm.UserOrGroupId);
            }
        }
        System.debug('==userIds==='+userIds);
        
        String caseURL= System.URL.getSalesforceBaseURL().toExternalForm()+ '/' +csId;
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();  
        for(Id userId : userIds)  
        {     
           Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
           string body = 'Case ' + cs.CaseNumber + ' has been assigned to you.  Please click on the link below to view the record <br>' + '<a href ="'+ caseURL + '" >'+  caseURL + '</a>';  
           mail.setSubject('Case Assigned to you');  
           mail.setTargetObjectId(userId );  
           mail.setSaveAsActivity(false);  
           //mail.fromAddress('noreply@salesforce.com');
           mail.setHtmlBody(body);  
           mails.add(mail);  
        }  
        system.debug('Check &&&&&&&&&&&&' + cs.Id);
        
        for(Group GrpEmailQueue:[Select id, Email From Group where id =: cs.ownerId and Email !=null LIMIT 1]){         
           Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
           string body = 'Case ' + cs.CaseNumber + ' has been assigned to Queue.  Please click on the link below to view the record <br>' + '<a href ="'+ caseURL + '" >'+  caseURL + '</a>';  
           mail.setSubject('Case Assigned to Queue');  
           //mail.setTargetObjectId(cs.Id);  
           mail.setSaveAsActivity(false);  
           //mail.fromAddress('noreply@salesforce.com');
           String[] toAddresses = new String[] {GrpEmailQueue.Email};
           System.debug('>>>>'+toAddresses );
           mail.setToAddresses(toAddresses);
           mail.setHtmlBody(body);  
           mails.add(mail);
         }
        Messaging.sendEmail(mails);                
    }
}