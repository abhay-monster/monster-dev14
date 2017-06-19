/**********************************************************************************************************
Author : Deepanshu Soni (JDC)
Date Created : 19-AUG-2019
Task Referrence : T-528251
Description :  For sending a summary email whenever the Execute step encounters an error
**********************************************************************************************************/

public class BatchAccountUpdateHelper {

  public static Void sendEmail(String objectName, String errorAccount, String summary) {


    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    List<String> toAddresses = new List<String>();
    toAddresses.addAll(EmailAddresses__c.getInstance('Batch Account List 1').BatchAccountList__c.split(',')); ////contains comma seperated email ids from a custom list by the name - Batch Account List 1
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
	header += ' Error thrown on this Account' + errorAccount;
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
  
  //reference sample
  /* User primarySaleRep = newPrimarySaleRepUsersMap.get(uAccount.OwnerId);
	User oldprimarySaleRep = oldPrimarySaleRepUsersMap.get(uAccount.Id);
	if(primarySaleRep != null){
    if(primarySaleRep.Email != oldprimarySaleRep.Email){
		String msg = 'The account ' + uAccount.Name + ' ('+ uAccount.AccountId__c  +') has been reassigned from ';
        msg+= oldprimarySaleRep.FirstName + ' ' +oldprimarySaleRep.LastName+ ' to ' +primarySaleRep.FirstName + ' ' + primarySaleRep.LastName;
        msg+= '. <br/>' + fullFileURL;
        Messaging.Singleemailmessage mail = new Messaging.Singleemailmessage();
        mail.setToAddresses(new String[]{primarySaleRep.Email});
        mail.setSubject('An account has been reassigned to you.');
        mail.setSenderDisplayName('Salesforce.com');
        mail.setHtmlBody(msg);
        Messaging.sendEmail(new Messaging.Email[]{mail}, false);
     }*/
}