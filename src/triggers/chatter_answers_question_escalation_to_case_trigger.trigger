trigger chatter_answers_question_escalation_to_case_trigger on Question (after update) {
    // Shyam - 5/3/2017 - S-473243 
    // Shyam - 5/5/2017 - S-473241
    List<Case> lstCases = new List<Case>();
    for (Question q: [select Id, Priority, (Select Id from Cases), Title, Body, CommunityId, createdById, createdBy.AccountId, createdBy.ContactId from Question where Id IN :Trigger.new]) {
        if (q.Priority == 'high' && (q.Cases == null || q.Cases.size() == 0) && Trigger.oldMap.get(q.id).Priority != 'high') {
            Case newCase = new Case(Origin='Chatter Answers', OwnerId=q.CreatedById, QuestionId=q.Id, CommunityId=q.CommunityId, Subject=q.Title, Description = (q.Body == null? null: q.Body.stripHtmlTags()), AccountId=q.CreatedBy.AccountId, ContactId=q.CreatedBy.ContactId);
            
            //if(test.isRunningTest()){
            //    newCase.OwnerId = null;
            //}
            lstCases.add(newCase);
        }
    }
    try {
        if(lstCases.size() > 0){
            insert lstCases;
        }
    } catch (Exception e) {
        String subjectText = 'Case Escalation exception in site ' + Site.getName();
        String bodyText = 'Case Escalation on Question having ID: ' + trigger.new.get(0).Id + ' has failed with the following message: ' + e.getMessage() +
            '\n\nStacktrace: ' + e.getStacktraceString();

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        list<string> toAddresses = new list<string>();
         if(!test.isRunningTest()){
        toAddresses .add(Site.getAdminEmail() );
            }
            if(test.isRunningTest()){
                toAddresses.add('abc@gmail.com');
            }

        mail.setReplyTo('no-reply@salesforce.com');
        mail.setSenderDisplayName('Salesforce Chatter Answers User');

        // The default sender is the portal user causing this trigger to run, to change this, set an organization-wide address for
        // the portal user profile, and set the ID in the following line.
        // mail.setOrgWideEmailAddressId(orgWideEmailAddressId);
        mail.setToAddresses(toAddresses);
        mail.setSubject(subjectText);
        mail.setPlainTextBody(bodyText);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}