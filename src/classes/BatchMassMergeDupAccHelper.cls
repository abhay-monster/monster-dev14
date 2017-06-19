/**********************************************************************************************************
Author : Deepanshu Soni (Appirio)
Date Created : 04-OCT-2016
Task Referrence : I-189352
Description :  For sending a summary email whenever BatchMassMergeDuplicateAccounts class finds a Merge Winner being deleted
**********************************************************************************************************/

public class BatchMassMergeDupAccHelper {

  public static Void sendEmail(String objectName, String summary) {


    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    List<String> toAddresses = new List<String>();
    toAddresses.addAll(EmailAddresses__c.getInstance('BatchMassMergeDuplicateAccounts').BatchAccountList__c.split(','));
    mail.setToAddresses(toAddresses);

    String username = UserInfo.getUserName().toUpperCase();
    String org = '';
    if (username.contains('MONSTER')){
      org = username.mid(username.indexOf('.COM') + 5, 30);
    }
    else {
      org = 'OrgId ' + UserInfo.getOrganizationId();
    }

    String subject = ' ' ;
    subject += org + ' ' + objectName + ' Records';
    String header = '';
    String body = '';
    header += 'Salesforce Org: ' + org + '<BR>';
    header +=' User: ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + '<BR>';
    header += ' Exception';
    body += ' Summary: ' + summary + '<BR><BR>';



    String combined = header + body;
    mail.setHtmlBody(combined);

    List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.Email[] { mail });
    if (!results.get(0).isSuccess()) {
        system.debug('********** Email Failed - Attempt Followup ***********');
        System.StatusCode statusCode = results.get(0).getErrors()[0].getStatusCode();
        String errorMessage = results.get(0).getErrors()[0].getMessage();

        Messaging.SingleEmailMessage errmail = new Messaging.SingleEmailMessage();

        errmail.setToAddresses(toAddresses);
        errmail.setSubject(org + ' ' + objectName + ' Records Had Problems');

        String errbody = '';
        errbody += 'The email failed to send correctly.  Send results were as follows:<BR>';
        errbody += 'System status code: ' + statusCode +'<BR>';
        errbody += 'Error message: ' + errorMessage +'<BR>';

        combined = header + errbody;
        errmail.setHtmlBody(combined);
        Messaging.sendEmail(new Messaging.Email[] { errmail });
    }
    else{
        system.debug('********** Email sent OK ***********');
    }
  }

}