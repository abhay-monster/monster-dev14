public class ArchiveHelper {
  public static string subjectText {get;set;}
  public static string processType {get;set;}

  //Submit the updates and capture information on updates which fail
  public static String doUpdate(String objName, List<SObject> thisList){
    String result = '';
    Database.SaveResult[] updateResults = Database.update(thisList, false);

    for (Integer i=0; i < updateResults.size(); i++) {
      if (!updateResults.get(i).isSuccess()) {
          Database.Error error = updateResults.get(i).getErrors().get(0);
              result += system.now().formatGMT('HH:mm:ss') + ' (GMT) ' + objName + ' Id ' + thisList.get(i).Id + ' Update Error: ' + error.getStatusCode() +
                        ' - Error Message: ' + error.getMessage() + ' - Field(s) Involved: ' + error.getFields() + '<BR>';
        }
    }
    return result;
  }


  public static Void sendEmail(String objectName, String summary, String updateErrors) {
    //Set up default values if nothing has been specified
    if(subjectText == null){
      subjectText = 'Archiving of';
    }
    if(processType == null){
      processType = 'Archiving';
    }

    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

    List<String> toAddresses = new List<String>();
    toAddresses.add(UserInfo.getUserEmail());
    mail.setToAddresses(toAddresses);

    String username = UserInfo.getUserName().toUpperCase();
    String org = '';
    if (username.contains('MONSTER')){
      org = username.mid(username.indexOf('.COM') + 5, 30);
    }
    else {
      org = 'OrgId ' + UserInfo.getOrganizationId();
    }

    String subject = subjectText + ' ' + org + ' ' + objectName + ' Records';
    if (updateErrors != ''){
      subject += ' Encountered Problem(s)';
    }
    else {
      subject += ' Was Successful';
    }
    mail.setSubject(subject);

    String header = '';
    String body = '';
    header += 'Salesforce Org: ' + org + '<BR>';
    header += processType + ' User: ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + '<BR>';
    header += processType + ' Summary: ' + summary + '<BR><BR>';

    if (updateErrors == ''){
        body += 'No problems were encountered in ' + processType.toLowerCase() + ' the records.';
    } else {
      body += 'The following problem(s) were encountered, ';
      body += 'each of which reduces the associated count shown above:<BR><BR>';
      body += updateErrors;
    }

    String combined = header + body;
    mail.setHtmlBody(combined);

    List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.Email[] { mail });
    if (!results.get(0).isSuccess()) {
        system.debug('********** Email Failed - Attempt Followup ***********');
        System.StatusCode statusCode = results.get(0).getErrors()[0].getStatusCode();
        String errorMessage = results.get(0).getErrors()[0].getMessage();

        Messaging.SingleEmailMessage errmail = new Messaging.SingleEmailMessage();

        errmail.setToAddresses(toAddresses);
        errmail.setSubject(processType + ' of ' + org + ' ' + objectName + ' Records Had Problems');

        String errbody = '';
        errbody += 'The ' + processType.toLowerCase() + ' email failed to send correctly.  Send results were as follows:<BR>';
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