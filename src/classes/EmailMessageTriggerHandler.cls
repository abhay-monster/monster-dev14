/*************************************************************************************************************
* Class : EmailMessageTriggerHandler
* @author Mohit Parnami
* @CreatedDate  : 1 Sept 2015
***************************************************************************************************************/
public with sharing class EmailMessageTriggerHandler {
    final String CLASSNAME = '\n\n**** EmailMessageTriggerHandler.METHODNAME()';

    public EmailMessageTriggerHandler(){
        //empty constructer
        //Todo - add in logging framework
    }

    public void afterInsert(List<EmailMessage> newList, Map<Id, EmailMessage> oldMap) {
        final string METHODNAME = CLASSNAME.replace('METHODNAME','afterInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        createNewCase(newList);
        //updateCaseFields(newList);
        emailtoCaseRouting(newList);
    }

    /*T-427392 : A new case needs to be created and the EmailMessage cloned to be associated with the new case.
    If someone responds to an old email thread, this method determines if we need to
    create a new case or re-open the old case
    if the current case is closed > 30 days ago, otherwise it will re-open the old case instead
    */
    private void createNewCase(List<EmailMessage> newList) {
        final string METHODNAME = CLASSNAME.replace('METHODNAME','createNewCase');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        List<Case> listCaseToInsert = new List<Case>();
        Map<Id, EmailMessage> mapCaseIdToEmail = new Map<Id, EmailMessage>();
        List<EmailMessage> listEmailMsgToInsert = new List<EmailMessage>();
        Map<Id, Case> mapEmailMessageIdToNewCase = new Map<Id, Case>();

        Id GCSRecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Case', 'GCS');

        for (EmailMessage em : newList) {
            if(((String)em.parentid).startsWith('500') && em.Incoming){
                mapCaseIdToEmail.put(em.parentid, em);
            }
        }

        System.debug('====mapCaseIdToEmail==='+mapCaseIdToEmail);

        List<Case> listCases = [SELECT id, isClosed, Type, ClosedDate
                        FROM Case
                        WHERE id IN : mapCaseIdToEmail.keySet()];
        System.debug('----listCases ' + listCases);
        List<Case> listCaseUpdates = new List<Case>();

        for(Case cas : listCases) {

            date todaysDate = date.today();

            //System.debug('====cas.isClosed==='+cas.isClosed) +'=========Days diff==='+(Date.valueOf(cas.ClosedDate).daysBetween(todaysDate)));

            if(cas.isClosed == true && (Date.valueOf(cas.ClosedDate).daysBetween(todaysDate)) > 30 ) {
                system.debug('=====mapCaseIdToEmail.containsKey(cas.Id)===' + mapCaseIdToEmail.containsKey(cas.Id));
                //TKOM S-456385 - if the case is closed and older than 30 days, do NOT create a new case - just update the existing case status/substatus (see updateRespondedToCase method below).
                //commented out the following section
                /*
                if(mapCaseIdToEmail.containsKey(cas.Id)) {

                    EmailMessage emessage = mapCaseIdToEmail.get(cas.Id);

                    Case newCase = new Case();
                    newCase.Subject = emessage.Subject;
                    newCase.Description = emessage.TextBody;
                    newCase.Type = cas.Type;
                    newCase.RecordTypeId = GCSRecordTypeId;
                    newCase.SystemGenerated__c = True;

                    listCaseToInsert.add(newCase);
                    mapEmailMessageIdToNewCase.put(emessage.Id, newCase);


                }
                */
            }
        }

        system.debug('=====listCaseToInsert===' + listCaseToInsert);
        if(listCaseToInsert != null && listCaseToInsert.size() > 0) {
            insert listCaseToInsert;
        }


        for(Case cs : listCases) {
                EmailMessage emessage = mapCaseIdToEmail.get(cs.Id);
                EmailMessage clonedEmessage = emessage.clone(false);
                if(mapEmailMessageIdToNewCase.containsKey(emessage.Id)) {
                    Case newInsertedCase = mapEmailMessageIdToNewCase.get(emessage.Id);
                    if(newInsertedCase != null) {
                        clonedEmessage.ParentId = newInsertedCase.Id;
                        listEmailMsgToInsert.add(clonedEmessage);
                    }
                }
        }


        system.debug('=====listEmailMsgToInsert===' + listEmailMsgToInsert);

        if(listEmailMsgToInsert != null && listEmailMsgToInsert.size() > 0) {
            insert listEmailMsgToInsert;
        }
    }



    //T-428211 : Case Routing Rule records based on Inbound Email Address matching To Address on the Email Message record.
    //If only one record is found use that record and proceed
    //if more than one record is matching also match on following fields as well Sender Email Contains, Email Header Contains, Email Subject Contains and Email Body Contains
    //Once matched to related email routing rule. The following fields need to be populated on related Case if populated on Routing rule.
    //Case Status, Case Sub Status, Case Issue, Case Sub Issue, Case Business Hours, Case Owner, Case Record Type, Case Language, Case Origin, First Contact Commitment (Hours),
    // Resolution Commitment (Hours), System Generated
    private void emailtoCaseRouting(List<EmailMessage> newList) {
        final string METHODNAME = CLASSNAME.replace('METHODNAME','emailtoCaseRouting');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        Map<Id,EmailMessageWrapper> caseIdToWrapper = new Map<Id,EmailMessageWrapper>();
        for(EmailMessage em:newList){
            if(em.Incoming){
                EmailMessageWrapper emw = new EmailMessageWrapper(em);
                //emailMessageList.add(emw);
                caseIdToWrapper.put(emw.CaseId,emw);
                //mapEmailMessage.put(em.ParentId,em);
                System.Debug(em.Toaddress + '#' + em.Ccaddress + '#' + em.BccAddress + '###Catch'+em.ParentId);
            }
        }

        List<Case> casesToUpdate = new List<Case>();
        //Now query the cases related to the messages and add to our wrapper class
        For(Case c : [SELECT Id, IsCLosed, Status, ClosedDate, SubStatus__c, CreatedDate,
                            ContactId,AccountId, RecordTypeId,Cloned_Email_To_Case__c,
                        (Select id From EmailMessages)
                        FROM Case
                        WHERE Id IN :caseIdToWrapper.keySet()]){
                            System.debug('==============='+c.EmailMessages.size());
            if(c.EmailMessages.size() > 1){
                //this means that this isn't a new thread, but an existing email thread on an existing case
                //First we need to update the case
                c = updateRespondedToCase(c);
                //then we remove it from our master Map (so it doesn't get used in logic later on in this method)
                caseIdToWrapper.remove(c.Id);
                //the add it to our case update list
                casesToUpdate.add(c);
            } else{
                //this lets us know if this was routed already and a cloned email message was created
                //we do not want to try and route again if this is true (see logic below when multiple routing matches
                //are found for different addresses)
                if(c.Cloned_Email_To_Case__c){
                    caseIdToWrapper.remove(c.Id);
                } else {
                    //update the case info on our wrapper
                    caseIdToWrapper.get(c.Id).emailCase = c;
                }

            }
        }

        if(caseIdToWrapper.isEmpty()){
            //This means there are no new messages to route, only responses
            //we need to update our cases and exit
            update casesToUpdate;
            return;
        }

        //Now we fire off the main reason for all our logic - time to start matching email messages to case routing rules
        EmailRoutingHelper routingHelper = new EmailRoutingHelper(caseIdToWrapper);
        routingHelper.runRoutingLogic();
        casesToUpdate.addAll(routingHelper.casesToBeUpdated);
        List<Case> casesToInsert = routingHelper.casesToBeInserted;
        List<EmailMessageWrapper> clonedWrapperList = routingHelper.clonedEmailWrapperList;
        List<Messaging.SingleEmailMessage> autoResponseEmails = routingHelper.autoResponseMessages;

        if(!casesToUpdate.isEmpty()){
            CaseTriggerHandler.bypassRuncount = true;
            /* TKOM Adding some debugs to help troubleshoot email to case error caused by the update statement in this code block:
            // May be similar or related to I-218297
            //
            // CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY : EmailMessageTrigger: execution of AfterInsert
            //
            // caused by: System.DmlException: Update failed. First exception on row 0 with id 5001600000z2FfeAAE; first error: INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY, insufficient access rights on cross-reference id: []
            //
            // Class.EmailMessageTriggerHandler.emailtoCaseRouting: line 170, column 1
            // Class.EmailMessageTriggerHandler.afterInsert: line 19, column 1
            // Trigger.EmailMessageTrigger: line 5, column 1
            */
            system.debug(':::: current user Id: ' + UserInfo.getUserId());
            system.debug(':::: current user Profile: ' + UserInfo.getProfileId());
            for(Case cs : casesToUpdate) {
                system.debug(':::: casesToUpdate[]: ' + cs.Id);
            }
            // end of debugs
            update casesToUpdate;
            CaseTriggerHandler.bypassRuncount = false;
        }

        if(!casesToInsert.isEmpty()){
            CaseTriggerHandler.bypassRuncount = true;
            insert casesToInsert;
            CaseTriggerHandler.bypassRuncount = false;

            //extra piece of logic for the emailmessages that need their parentId updated
            List<EmailMessage> emailMessageToInsert = new List<EmailMessage>();
            for(EmailMessageWrapper emw : clonedWrapperList){
                EmailMessage em = emw.emailMessage;
                em.ParentId = emw.EmailCase.Id;
                emailMessageToInsert.add(em);
            }

            if(!emailMessageToInsert.isEmpty()){
                insert emailMessageToInsert;
            }
        }

        if(!autoResponseEmails.isEmpty()){
            // TKOM I-223494/S-445840: added try/catch block to avoid "INVALID_EMAIL_ADDRESS" and "REQUIRED_FIELD_MISSING, Either the plain text body or html body must be supplied.: []" errors
            Messaging.SendEmailResult[] results;
            try{
                results = Messaging.sendEmail(autoResponseEmails);
                if (results[0].success) {
                    System.debug('The email was sent successfully.');
                } else {
                    System.debug('The email failed to send: ' + results[0].errors[0].message);
                }
            } catch (EmailException e) {
                System.debug('EmailException - Error Sending autoResponseEmails:' + e);
                // future enhancement - try to update the case/chatter/etc. somehow to indicate that the email couldn't be sent, or implement custom email2case error logging
                // Not sure how to identify the case that caused the error in order to update it.
            }
        }

        //if(CaseTriggerHelper.AutoResponseContactsDelete.size()>0) CaseTriggerHelper.deleteCreatedcontacts(CaseTriggerHelper.AutoResponseContactsDelete);*/
    }

    /* @Name: updateIfEmailResponse
    *  @Author: Jeff L (Appirio)
    *  @Params: A Case
    *  @Returns: A Case
    *  @Description: This method will update some fields on the case since this is
                    a responded to message, not a new message
    */
    private Case updateRespondedToCase(Case pCase){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateRespondedToCase');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        Case updatedCase = pCase;
        pCase.SubStatus__c = 'Updated By Customer';
        // TKOM S-443745: Update Status to Open regardless of current status or age - removed if statement and just set the case status.
        //if(pCase.isClosed == false || (pCase.IsClosed == true && (Date.valueOf(pCase.ClosedDate).daysBetween(date.today())) < 30)){
        pCase.Status = 'Open';
        //}
        system.debug('Updating existing case - Status: ' + pCase.Status + ' & SubStatus: ' + pCase.SubStatus__c);
        return pCase;
    }

    /* @Name: EmailMessageWrapper
    *  @Author: Jeff L (Appirio)
    *  @Description: wrapper class for all the email message functionality
    */
    private class EmailMessageWrapper {
        final String CLASSNAME = '\n\n**** EmailMessageWrapper.METHODNAME()';
        public Case emailCase;
        public Id caseId;
        public Set<String> addressSet;
        public EmailMessage emailMessage;
        //this is the email address that the email was forwarded to as part of Email-to-Case
        public String sfdcIncomingAddress;
        public Map<String,String> headers;
        public Boolean isCloned = false; //defaults to false, set to true if specialClone is used

        public EmailMessageWrapper(EmailMessage pMessage){
            final string METHODNAME = CLASSNAME.replace('METHODNAME','Constructer');
            system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
            this.emailMessage = pMessage;
            this.caseId = pMessage.parentId;
            this.headers = parseHeaders(pMessage.Headers);
            this.sfdcIncomingAddress = getSFDCIncomingEmail(this.headers);
            //put all the to addresses into our address set:
            this.addressSet = new Set<String>();
            addAddressesToSet(pMessage.ToAddress,this.addressSet);
            addAddressesToSet(pMessage.CcAddress,this.addressSet);
            addAddressesToSet(getBCCAddress(pMessage.Headers),this.addressSet);
            system.debug('Addresses ' + this.addressSet.size() + ' ' + this.addressSet);
        }

        /* @Name: addAddressesToSet
        *  @Author: Jeff L (Appirio)
        *  @Params: String of addresses, set of Strings
        *  @Returns: void
        *  @Description: this will check to see if multiple addresses need to be
                Added to the address set, if only one, it will add that single address
        */
        private void addAddressesToSet(String pAddresses, Set<String> pSet){
            final string METHODNAME = CLASSNAME.replace('METHODNAME','addAddressesToSet');
            system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
            if(String.isNotBlank(pAddresses)){
                //if the string contains a comma, then we know there are multiple
                //addresses
                if(pAddresses.contains(';')){
                    for(String address : pAddresses.split(';')){
                        pSet.add(address.trim().toLowerCase());
                    }
                } else {
                    //this means we only have one address
                    pSet.add(pAddresses.toLowerCase());
                }
            }
        }

        /* @Name: parseHeaders
        *  @Author: Jeff L (Appirio)
        *  @Params: String of email headers
        *  @Returns: Map of Key, Values for the headers
        *  @Description: this method will create a key value map of all the email headers
        */
        private Map<String,String> parseHeaders(String pHeaders){
            final string METHODNAME = CLASSNAME.replace('METHODNAME','parseHeaders');
            system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
            Map<String,String> returnHeaderMap = new Map<String,String>();
            String LINE_SEPERATOR = '\n';
            String SPLIT_CHARACTER = ':';
            //system.debug('*** Headers ' + pHeaders);
            for(String fullLine : pHeaders.split(LINE_SEPERATOR)){
                //system.debug('*** FullLine ' + fullLine);
                Integer splitIndex = fullLine.indexOf(SPLIT_CHARACTER);
                //system.debug('*** SplitIndex ' + splitIndex);
                if(splitIndex != -1){
                    String key = fullLine.left(splitIndex);
                    //System.debug('*** Key ' + key);
                    String value = fullLine.right(fullLine.length() - key.length() - 2);
                    //System.debug('*** Value ' + value);
                    returnHeaderMap.put(key,value);
                }
            }
            return returnHeaderMap;
        }
        /* @Name: getSFDCIncomingEmail
        *  @Author: Jeff L (Appirio)
        *  @Params: Map of key values for headers
        *  @Returns: the original salesforce routing address that this email came into
        *  @Description: given a map of headers this will pull out the SFDC routing address
                        based upon a specific string found in the headers
        */
        private String getSFDCIncomingEmail(Map<String,String> pHeaders){
            final string METHODNAME = CLASSNAME.replace('METHODNAME','getSFDCIncomingEmail');
            system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
            String baseEmailAddress = pHeaders.get('X-SFDC-Original-RCPT');
            if(baseEmailAddress != null){
                Integer splitIndex = baseEmailAddress.indexOf('@');
                baseEmailAddress = baseEmailAddress.left(splitIndex).toLowerCase();
            }

            return baseEmailAddress;
        }
        /* @Name: getSFDCIncomingEmail
        *  @Author: Jeff L (Appirio)
        *  @Params: String of Raw Headers
        *  @Returns: uses a regular expression to pull out the email address that exchange forwarded into SFDC
                    This will count as the BCC address, otherwise we are just putting this into a set so a duplicate
                    (In the case where it is the same as the TO or CC address) won't be created.
        */
        private String getBCCAddress(String pHeaders){
            final String METHODNAME = CLASSNAME.replace('METHODNAME','getBCCAddress');
            system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
            String BCC_REGEX = '(for.<)(.*)(>)';
            String returnBCCAddress;
            Pattern bccPattern = Pattern.compile(BCC_REGEX);
            Matcher bccMatcher = bccPattern.matcher(pHeaders);
            system.debug('headers? ' + pHeaders);
            system.debug('Matcher? ' + bccMatcher);

            if(bccMatcher.find()){
                system.debug('Matches ');
                system.debug('Groups? ' + bccMatcher.groupCount());
                returnBCCAddress = bccMatcher.group(2);
            }

            system.debug('bccMatcher? ' + returnBCCAddress);
            return returnBCCAddress;


        }

        /* @Name: specialClone
        *  @Author: Jeff L (Appirio)
        *  @Params: nothing
        *  @Returns: EmailMessageWrapper
        *  @Description: returns a copy of the current EmailMessageWrapper, with a deepclone
                    of the associated case and emailMesssage
        */
        private EmailMessageWrapper specialClone(){
            final string METHODNAME = CLASSNAME.replace('METHODNAME','specialClone');
            system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
            //clone the emailMessage and case first
            EmailMessage clonedMessage = this.emailMessage.clone(false,true,false,false);
            Case clonedCase = this.emailCase.clone(false,true,false,false);
            clonedCase.Cloned_Email_To_Case__c = true;
            clonedCase.Subject = clonedMessage.Subject;
            clonedCase.Description = clonedMessage.TextBody;
            system.debug('clonedCase.Subject? ' + clonedCase.Subject);
            EmailMessageWrapper clonedWrapper = new EmailMessageWrapper(clonedMessage);
            clonedWrapper.caseId = null;
            clonedWrapper.emailCase = clonedCase;
            clonedWrapper.isCloned = true;
            return clonedWrapper;
        }
    }

    private class CaseRoutingRuleWrapper implements Comparable{
        final String CLASSNAME = '\n\n**** EmailMessageWrapper.METHODNAME()';
        public CaseRoutingRule__c routingRule;
        private Integer criteriaCount = 0;

        /* @Name: CaseRoutingRuleWrapper
        *  @Author: Jeff L (Appirio)
        *  @Params: Case Routing Rule
        *  @Returns: CaseRoutingRuleWrapper
        *  @Description: constructor for CaseRoutingRuleWrapper class, initializes
                        variables needed for compareTo method
        */
        public CaseRoutingRuleWrapper(CaseRoutingRule__c pRoutingRule){
            final string METHODNAME = CLASSNAME.replace('METHODNAME','Constructor');
            system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
            this.routingRule = pRoutingRule;
            this.criteriaCount = countCriteria();
        }

        /* @Name: countCriteria
        *  @Author: Jeff L (Appirio)
        *  @Params: Case Routing Rule
        *  @Returns: Integer
        *  @Description: method that returns the number of criteria in the case routing rule.
                        Needed for the compareTo method
        */
        private integer countCriteria(){
            final string METHODNAME = CLASSNAME.replace('METHODNAME','countCriteria');
            system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
            Map<String,String> criteriaMap = CaseRoutingUtility.getCriteriaMap();
            Integer returnCount = 0;

            for(String criteria : criteriaMap.keySet()){

                if(String.isNotBlank((String)this.routingRule.get(criteria))){
                    returnCount++;
                }
            }
            System.debug('----returnCount ' + returnCount);
            return returnCount;
        }

        /* @Name: compareTo
        *  @Author: Jeff L (Appirio)
        *  @Params: Object
        *  @Returns: Integer
        *  @Description: This is our overriden compareTo method, the whole reason for the wrapper class
                        needed for the implements Comparable
        */
        public Integer compareTo(Object compareTo){
            final string METHODNAME = CLASSNAME.replace('METHODNAME','compareTo');
            system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
            CaseRoutingRuleWrapper compareWrapper = (CaseRoutingRuleWrapper)compareTo;


            //specifics for this implementation can be found in the SFDC documentation
            //just search for Comparable.  I have my logic reversed because I want the wrappers
            //with the most criteria to be at the beginning of the list
            if(this.criteriaCount > compareWrapper.criteriaCount){
                return -1;
            } else if(this.criteriaCount < compareWrapper.criteriaCount){
                return 1;
            } else {
                return 0; //this means they are the same
            }
        }
    }

    private class EmailRoutingHelper {
        final String CLASSNAME = '\n\n**** EmailRoutingHelper.METHODNAME()';
        public List<Case> casesToBeUpdated;
        public List<Case> casesToBeInserted;
        public List<EmailMessageWrapper> clonedEmailWrapperList;
        private List<Messaging.SingleEmailMessage> autoResponseMessages;
        private Map<Id,EmailMessageWrapper> wrapperMap;
        private CaseRoutingRule__c cRRCatchAll;
        //used for compiling regex, this way we only have to compile once for criteria tests
        private String BRACKETREGEX = '\\[(.*?)\\]'; //this will match any text between brackets

        public EmailRoutingHelper(Map<Id,EmailMessageWrapper> pWrapperMap){
            final string METHODNAME = CLASSNAME.replace('METHODNAME','Constructor');
            system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
            //this list will contain all the autoresponse messages we need to send
            this.autoResponseMessages = new List<Messaging.SingleEmailMessage>();
            //This list will contain all the cases that will eventually be updated
            this.casesToBeUpdated = new List<Case>();
            //this list will contain any cases that need to be inserted
            this.casesToBeInserted = new List<Case>();
            //this list will contain any messages that need to be inserted
            this.clonedEmailWrapperList = new List<EmailMessageWrapper>();
            this.wrapperMap = pWrapperMap;
            //get the catch all rule - this gets used if no other match is found
            this.cRRCatchAll = getCatchAllRule();
        }

        /* @Name: runRoutingLogic
        *  @Author: Jeff L (Appirio)
        *  @Params: None
        *  @Returns: void
        *  @Description: Method that kicks off all the email routing logic in this class
        */
        public void runRoutingLogic(){
            final string METHODNAME = CLASSNAME.replace('METHODNAME','runRoutingLogic');
            system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
            findRoutingMatches();
        }

        /* @Name: findRoutingMatches
        *  @Author: Jeff L (Appirio)
        *  @Params: None
        *  @Returns: Map<Id,EmailMessageWrapper>
        *  @Description: Big Method that matches up the cases with their respective
                        routing rules
        */
        private void findRoutingMatches(){
            final string METHODNAME = CLASSNAME.replace('METHODNAME','findRoutingMatches');
            system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
            //If we have gotten this far, then there are new cases to route the Logic is as follows:
            /*Order of operations for case routing:
            * 1. Match the SFDC email that the case came into (using X-SFDC-Original-RCPT, use before the @sign)
            * 2.  Find the case routing rules that match and then match the subsequent fields
            *   a. If there are multiple To/cc addresses that match - create and route additional cases THAT Match
                b. If no matches, check to see if there is a catch all for those emails
                c. No catch all for those emails then route them all to the catch all queue.
              3. populate values on case
            */

            //This method gathers all the email to case routing rules together
            Map<String,List<CaseRoutingRuleWrapper>> mapRoutingRules = getEmailRoutingRules();


            for(EmailMessageWrapper emw : wrapperMap.values()){
                system.debug('**** sfdcIncomingAddress ' + emw.sfdcIncomingAddress);
                //1.Match using our incoming email, if no match then it goes to Catch All Rule
                if(!mapRoutingRules.containsKey(emw.sfdcIncomingAddress)){
                    //No matches at all - so we use the catch all rule
                   casesToBeUpdated.add(matchFound(emw.emailCase,emw.emailMessage,cRRCatchAll,autoResponseMessages));
                   continue; //put a continue here since we want the logic to stop when we hit this point
                }

                //Now that the catch all is out of the way we check the count of our routing rule
                //if there is only one, then it's a match - otherwise we have more complex logic to find the
                //match:
                List<CaseRoutingRuleWrapper> potentialCRRList = mapRoutingRules.get(emw.sfdcIncomingAddress);
                if(potentialCRRList.size() == 1){
                    CaseRoutingRule__c matchedRule = potentialCRRList[0].routingRule;
                    casesToBeUpdated.add(matchFound(emw.emailCase,emw.emailMessage,matchedRule,autoResponseMessages));
                    continue; //put a continue here since we want the logic to stop when we hit this point
                }

                //This is the trickiest situation now, we need to try and see if any of the To Addresses Match in our routing rule
                multiplePossibleMatching(emw, PotentialCRRList);
            }
        }

        /* @Name: multiplePossibleMatching
        *  @Author: Jeff L (Appirio)
        *  @Params: EmailMessageWrapper, List<CaseRoutingRule__c>
        *  @Returns: void
        *  @Description: Method that is invoked when we have the case where we need to check if multiple
                        Matches are possible.
        */
        private void multiplePossibleMatching(EmailMessageWrapper pEmailWrapper, List<CaseRoutingRuleWrapper> pPotentialRoutingMatches){
            final string METHODNAME = CLASSNAME.replace('METHODNAME','multiplePossibleMatching');
            system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
            Boolean checkCatchAll = true;
            Integer overallMatchCount = 0;
            CaseRoutingRule__c innerCatchAll = getInnerCatchAllRule(pPotentialRoutingMatches);

            //first we need to initialize a map of possible address matches to 0
            Map<String,Integer> addressMatchingCount = new Map<String,Integer>();
            for(String address : pEmailWrapper.addressSet){
                addressMatchingCount.put(address, 0);
            }

            for(CaseRoutingRuleWrapper testingRuleWrapper : pPotentialRoutingMatches){
                CaseRoutingRule__c testingRule = testingRuleWrapper.routingRule;
                system.debug('potentialRoutingMatch Id ' + testingRule.Id);
                //for now we want to skip the inner catch all rule (if there is one)
                if(testingRule == innerCatchAll){
                    system.debug('testingRule is the same as innerCatchAll');
                    continue;
                }

                for(String address : pEmailWrapper.addressSet){
                    system.debug('**** Address being Matched: ' + address);
                    if(checkRoutingMatch(pEmailWrapper,address,testingRule)){
                        system.debug('**** CheckingRoutingMatch passed!');
                        //if this is 0 then we haven't yet matched this specific address
                        Integer currentAddressMatchCount = addressMatchingCount.get(address);
                        system.debug('**** current Address Matching Count ' + currentAddressMatchCount + ' overallMatchCount: ' + overallMatchCount);
                        if(currentAddressMatchCount == 0){
                            if(overallMatchCount == 0){
                                //if this count is 0, then this is the first match we have found for this routing rule
                                system.debug('**** First Match Found!');
                                casesToBeUpdated.add(matchFound(pEmailWrapper.EmailCase, pEmailWrapper.emailMessage, testingRule, autoResponseMessages));
                            } else {
                                /*if this isn't the first match for this routing rule
                                 *but is the first for this email address, then we have some
                                 *extra logic to perform. We need to create a new case
                                 *and email message (in essence clone the existing one)
                                 *so that we now have more than one case and email message*/
                                 system.debug('*** Multiple Matching found');
                                 EmailMessageWrapper clonedWrapper = pEmailWrapper.specialClone();
                                 clonedEmailWrapperList.add(clonedWrapper);
                                 casesToBeInserted.add(matchFound(clonedWrapper.EmailCase, clonedWrapper.emailMessage, testingRule, autoResponseMessages));
                            }
                            //increment our various checks
                            checkCatchAll = false;
                            overallMatchCount++;
                            currentAddressMatchCount++;
                            addressMatchingCount.put(address,currentAddressMatchCount);
                        }
                    }
                }
            }

            //if there are no matches, we want to check the inner catch all rule
            Boolean catchAllMatch = false;
            if(checkCatchAll && innerCatchAll != null){
                if(checkInnerCatchAllRoutingMatch(pEmailWrapper, innerCatchAll)){
                    casesToBeUpdated.add(matchFound(pEmailWrapper.EmailCase, pEmailWrapper.emailMessage, innerCatchAll, autoResponseMessages));
                    catchAllMatch = true;
                }
            }

            /*if there are still no matches - this might be a case where we have to check for a hidden BCC
            * we don't actually get the BCC from Monster internal emails (doesn't exist in the header or anywhere we can pull from)
            * so we need to test matches against case routing rules that match the SFDC Routing Address, but have no Inbound Email Address
            */
            if(checkCatchAll && !catchAllMatch){
                CaseRoutingRule__c matchedBCC = getBCCCaseRoutingRuleMatch(pEmailWrapper,pPotentialRoutingMatches);
                if(matchedBCC != null){
                    casesToBeUpdated.add(matchFound(pEmailWrapper.EmailCase, pEmailWrapper.emailMessage, matchedBCC, autoResponseMessages));
                    catchAllMatch = true;
                }
            }

            //finally if we checked inner catch all and have no match, then we use
            //the defaul catch all rule
            if(checkCatchAll && !catchAllMatch){
                casesToBeUpdated.add(matchFound(pEmailWrapper.EmailCase, pEmailWrapper.emailMessage, cRRCatchAll, autoResponseMessages));
            }
        }

       /* @Name: checkInnerCatchAllRoutingMatch
        *  @Author: Jeff L (Appirio)
        *  @Params: EmailMessageWrapper, List<CaseRoutingRule__c>
        *  @Returns: Boolean
        *  @Description: this will return true, if any of the addresses match the inner catch all rule that we have found
        */
        private Boolean checkInnerCatchAllRoutingMatch(EmailMessageWrapper pEmailWrapper, CaseRoutingRule__c pInnerCatchAll){
            final string METHODNAME = CLASSNAME.replace('METHODNAME','checkInnerCatchAllRoutingMatch');
            system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
            Boolean isMatch = false;
            isMatch = pEmailWrapper.AddressSet.contains(pInnerCatchAll.InboundEmailAddress__c);

            return isMatch;
        }

        /* @Name: checkRoutingMatch
        *  @Author: Jeff L (Appirio)
        *  @Params: EmailMessageWrapper, String, CaseRoutingRule__c
        *  @Returns: Boolean
        *  @Description: this is the logic that checks if an individual routing rule matches the email message
        */
        private Boolean checkRoutingMatch(EmailMessageWrapper pEmailWrapper, String pEmailAddress, CaseRoutingRule__c pPotentialRoutingMatch){
            final string METHODNAME = CLASSNAME.replace('METHODNAME','checkRoutingMatch');
            system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
            /*Logic is as follows:
            * 1. First check the routing rule's inbound email address - if no match then exit
            * 2. Next we need to check which extra fields we need to test, any of our "contains" fields that are not null
            *    need to be checked (with our special boolean logic operator checks)
            * 3. If everything is a match, then we are good and we return true
            *    Otherwise False!
            */
            Boolean matchFound = false;

            //First check is for Inbound Email address:
            if(pPotentialRoutingMatch.InboundEmailAddress__c == pEmailAddress){
                //Now that we have a match, we need to check each of the other criteria
                matchFound = isMatch(pEmailWrapper,pPotentialRoutingMatch);
            }
            system.debug('**** MatchFound? ' + matchFound);

            return matchFound;
        }

        /* @Name: isMatch
        *  @Author: Jeff L (Appirio)
        *  @Params: EmailMessageWrapper, CaseRoutingRule__c
        *  @Returns: Boolean
        *  @Description: this will iterate over all the criteria in the criteriaMap
                        and will return true if all the criteria passes, false if it doesn't
        */
        private Boolean isMatch(EmailMessageWrapper pEmailMesssageWrapper, CaseRoutingRule__c pPotentialRoutingMatch){
            final string METHODNAME = CLASSNAME.replace('METHODNAME','checkRoutingMatch');
            system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

            CaseRoutingRule__c pMatch = pPotentialRoutingMatch; //shorthand
            EmailMessage msg = pEmailMesssageWrapper.EmailMessage; //shorthand
            Map<String,String> criteriaMap = CaseRoutingUtility.getCriteriaMap();

            Boolean isMatch = false;

            //Now that we have a match, we need to check each of the other criteria
            Boolean allCriteriaPassing = true;
            for(String routingCriteriaField : criteriaMap.keySet()){
                //get the text of the field on the EmailMessage record
                String messageField = (String)msg.get(criteriaMap.get(routingCriteriaField));
                //get the text of the field on the CaseRoutingRule
                String criteriaField = (String)pMatch.get(routingCriteriaField);

                system.debug('routingCriteriaField = ' + routingCriteriaField);
                system.debug('criteriaMap.get(routingCriteriaField) = ' + criteriaMap.get(routingCriteriaField));
                system.debug('criteriaField = ' + criteriaField);
                system.debug('messageField = ' + messageField);


                // TKOM: S-460102
                // check for NULL subject line, as this causes errors in later string comparisons in the criteriaCheck method.
                if(criteriaMap.get(routingCriteriaField) == 'Subject' && String.isEmpty(messageField)){
                    // set the empty value to a non-empty value to avoid string comparison errors.  I tried using a single blank space but it caused the routing to work incorrectly - changed it to a dot (.) and it routs correctly this way.
                    system.debug('SUBJECT IS EMPTY - replace with non-EMPTY character');
                    messageField = '.';
                }
                // if the criteria is not empty, then we need to check it.
                if(String.isNotEmpty(criteriaField) ){
                    //perform our check
                    if(criteriaCheck(criteriaField,messageField) == false){
                        allCriteriaPassing = false;
                    }
                }

                //this means that a criteria has failed, this rule is not a match
                if(allCriteriaPassing == false){
                    isMatch = false; //don't really need to do this, but it makes it more readable
                    break;
                }
            }

            //if we get here and allCriteriaPassing is still true, then we have a match!
            if(allCriteriaPassing == true){
                isMatch = true;
            }

            return isMatch;
        }

        /* @Name: criteriaCheck
        *  @Author: Jeff L (Appirio)
        *  @Params: String, String
        *  @Returns: Boolean
        *  @Description: This is the logic that checks if an individual criteria matches
                        We have special keywords in [ ] that allow basic boolean operands
                        on the criteria - this method evaluates those operands
        */
        private Boolean criteriaCheck(String pRuleCriteria, String pMessageField) {
            final string METHODNAME = CLASSNAME.replace('METHODNAME','criteriaCheck');
            system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

            // TKOM S-440395: added some system.debug messages
            system.debug('pRuleCriteria = ' + pRuleCriteria);
            system.debug('pMessageField = ' + pMessageField);

            //if there are no [ ] then we just do a simple string comparison and return
            if(!pRuleCriteria.contains('[') && !String.isBlank(pMessageField)){ // TKOM S-440395: updated to check for pMessagefield being null
                    return pMessageField.containsIgnoreCase(pRuleCriteria);
            }

            List<String> keywordList = getKeywordList(pRuleCriteria);
            List<String> splitCriteriaField = getSplitCriteriaField(pRuleCriteria);

            //We now have a list of the keywords, and a list of the strings split by those keywords
            //time to start our testing of the pMessageField.
            Boolean isMatched = true;
            Boolean previousMatch;
            for(Integer i=0;i<keywordList.size();i++){
                //first check if the keyword is actually in our set
                if(this.possibleKeywordSet.contains(keywordList[i]) == false){
                    isMatched = false;
                    system.debug('Invalid keyword - skipping match');
                    break;
                }
                Boolean currentMatch = false;
                String keyword = keywordList[i];

                system.debug('*** Keyword being tested ' + keyword);

                //different logic for each keyword - I know this could be simplified
                //but I wrote it out longer so it's easier to understand in the future
                String prevCriteria = splitCriteriaField[i].trim();
                String currCriteria = splitCriteriaField[i+1].trim();
                system.debug('*** criteria being tested ' + currCriteria);
                //previousMatch needs to be initialized in this case
                if(i==0){
                    previousMatch = pMessageField.containsIgnoreCase(prevCriteria);
                    system.debug('initializing previousMatch ' + previousMatch);
                }
                if(keyword == '[AND]'){
                    if(previousMatch &&
                        pMessageField.containsIgnoreCase(currCriteria)){
                        currentMatch = true;
                    } else {
                        currentMatch = false;
                    }
                }
                if(keyword == '[OR]'){
                    if(previousMatch ||
                        pMessageField.containsIgnoreCase(currCriteria)){
                        currentMatch = true;
                    } else {
                        currentMatch = false;
                    }
                }
                if(keyword == '[NOT]'){
                    if(!pMessageField.containsIgnoreCase(currCriteria)){
                        currentMatch = true;
                    } else {
                        currentMatch = false;
                    }
                }
                if(keyword == '[AND NOT]'){
                    if(previousMatch &&
                        !pMessageField.containsIgnoreCase(currCriteria)){
                        currentMatch = true;
                    } else{
                        currentMatch = false;
                    }
                }
                if(keyword == '[OR NOT]'){
                    if(previousMatch ||
                        !pMessageField.containsIgnoreCase(currCriteria)){
                        currentMatch = true;
                    } else{
                        currentMatch = false;
                    }
                }

                //set us up for our next round of tests
                previousMatch = currentMatch;
                isMatched = currentMatch;
            }

            return isMatched;
        }

        /* @Name: searchPattern
        *  @Author: Jeff L (Appirio)
        *  @Params: none
        *  @Returns: Pattern
        *  @Description: This property sets the search pattern and should only compile it once
                        even if it gets accessed multiple times
        */
        private Pattern searchPattern{
            get{
                if(this.searchPattern == null){
                    this.searchPattern = Pattern.compile(BRACKETREGEX);
                }
                return this.searchPattern;

            }
            set{
                searchPattern = value;
            }
        }

        /* @Name: getKeywordList
        *  @Author: Jeff L (Appirio)
        *  @Params: String
        *  @Returns: List<String>
        *  @Description: given a string of criteria, we will pull out any of our keywords
                        Things like [AND] [OR] [NOT] etc. Uses a regex, pattern and matcher
                        to pull out our keywords
        */
        private List<String> getKeywordList(String pRuleCriteria){
            final string METHODNAME = CLASSNAME.replace('METHODNAME','getKeywordList');
            system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
            List<String> returnKeywordList = new List<String>();
            //this is the matcher that we use to find all the keywords
            Matcher keywordMatcher = searchPattern.matcher(pRuleCriteria);
            While(keywordMatcher.find() == true){
                String keyword = pRuleCriteria.substring(keywordMatcher.start(), keywordMatcher.end());
                returnKeywordList.add(keyword);
                system.debug('***inside keyword Matcher :' + keyword);
            }

            return returnKeywordList;
        }

        /* @Name: getSplitCriteriaField
        *  @Author: Jeff L (Appirio)
        *  @Params: String
        *  @Returns: List<String>
        *  @Description: This will pull out all the [AND] [NOT] [OR] and split
                        it into a list of criteria to check
        */
        private List<String> getSplitCriteriaField(String pRuleCriteria){
            final string METHODNAME = CLASSNAME.replace('METHODNAME','getSplitCriteriaField');
            system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

            List<String> returnSplitList;
            String SPLITSTRING = '....';
            String SPLITSTRINGREGX = '\\.\\.\\.\\.';

            String cleanedCriteriaField = pRuleCriteria.replaceAll(BRACKETREGEX,SPLITSTRING); //I used a string that shouldn't be in any of our criteria fields
            //system.debug('**** CleanedCriteriaField ' + cleanedCriteriaField);
            returnSplitList = cleanedCriteriaField.split(SPLITSTRINGREGX);
            //system.debug('**** returnSplitList ' + returnSplitList);

            return returnSplitList;

        }

        /* @Name: possibleKeywordSet
        *  @Author: Jeff L (Appirio)
        *  @Params: None
        *  @Returns: Set<String>
        *  @Description: returns a set of the
        */
        private Set<String> possibleKeywordSet{
            get{
                if(this.possibleKeywordSet == null){
                    this.possibleKeywordSet = new Set<String>{'[AND]','[OR]','[NOT]','[AND NOT]','[OR NOT]'};
                }
                return this.possibleKeywordSet;
            }
            set{
                possibleKeywordSet = value;
            }


        }
        /* @Name: getBCCCaseRoutingRuleMatch
        *  @Author: Jeff L (Appirio)
        *  @Params: List<CaseRoutingRuleWrapper>
        *  @Returns: CaseRoutingRule__c
        *  @Description: given a list of Case routing rules and an email message, we see if there are any matches where
                        The inbound email Address field is blank, but the rest of the criteria match
        */
        private CaseRoutingrule__c getBCCCaseRoutingRuleMatch(EmailMessageWrapper pEmailMesssageWrapper, List<CaseRoutingRuleWrapper> pPotentialRuleList){
            final string METHODNAME = CLASSNAME.replace('METHODNAME','getBCCCaseRoutingRuleMatch');
            system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
            //For BCC emails, we may not have the actual BCC address, so we will need to rely on the
            //SFDC Routing address, and finding any matches where Inbound Email Address is blank on the
            //Case routing rules
            CaseRoutingRule__c matchedRule;
            for(CaseRoutingRuleWrapper ruleWrapper : pPotentialRuleList){
                CaseRoutingRule__c ruleToTest = ruleWrapper.routingRule;
                //we only want to test rules that have a blank inbound email address
                if(String.isBlank(ruleToTest.InboundEmailAddress__c)){
                    if(isMatch(pEmailMesssageWrapper,ruletoTest)){
                        matchedRule = ruleToTest;
                        break; // exit the loop, we found our match
                    }
                }
            }

            return matchedRule;
        }

        /* @Name: getInnerCatchAllRule
        *  @Author: Jeff L (Appirio)
        *  @Params: List<CaseRoutingRuleWrapper>
        *  @Returns: CaseRoutingRule__c
        *  @Description: given a list of Case routing rules, we determine if any of them is a "Catch All Rule"
                        A Catch all rule is defined by having an email address, but no other criteria
        */
        private CaseRoutingRule__c getInnerCatchAllRule(List<CaseRoutingRuleWrapper> pRoutingRuleList){
            final string METHODNAME = CLASSNAME.replace('METHODNAME','getInnerCatchAllRule');
            system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
            CaseRoutingRule__c innerCatchAllRule;
            for(CaseRoutingRuleWrapper wrapperToCheck : pRoutingRuleList){
                CaseRoutingRule__c ruleToCheck = wrapperToCheck.routingRule;
                if( String.isNotBlank(ruleToCheck.InboundEmailAddress__c) &&
                    String.isBlank(ruleToCheck.SenderEmailContains__c) &&
                    String.isBlank(ruleToCheck.EmailBodyContains__c) &&
                    String.isBlank(ruleToCheck.EmailHeaderContains__c) &&
                    String.isBlank(ruleToCheck.EmailSubjectContains__c)){

                    innerCatchAllRule = ruleToCheck;
                }
            }
            return innerCatchAllRule;
        }



        /* @Name: getEmailRoutingRules
        *  @Author: Jeff L (Appirio)
        *  @Params: None
        *  @Returns: Map<String,List<CaseRoutingRuleWrapper>
        *  @Description: gets all of the routing rules for email to case and packs them as
                    SFDC Incoming Address > List of routing rules
        */
        private Map<String,List<CaseRoutingRuleWrapper>> getEmailRoutingRules(){
            final string METHODNAME = CLASSNAME.replace('METHODNAME','getEmailRoutingRules');
            system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
            Map<String,List<CaseRoutingRuleWrapper>> returnMap = new Map<String,List<CaseRoutingRuleWrapper>>();
            For(CaseRoutingRule__c rule : CaseRoutingUtility.getCaseRoutingRulesEmail()){
                if(rule.SFDC_Routing_Address__c != null){
                    //we don't care about anything past the @ sign so lets strip it out
                    String routingAddress = parseRoutingAddress(rule.SFDC_Routing_Address__c);
                    if(returnMap.get(routingAddress) == null){
                        returnMap.put(routingAddress, new List<CaseRoutingRuleWrapper>());
                    }
                    CaseRoutingRuleWrapper crrw = new CaseRoutingRuleWrapper(rule);
                    returnMap.get(routingAddress).add(crrw);
                }
            }

            //Now we have an extra step to sort the criteria, this will sort all the rules with
            //the most criteria fields populated to the top so that they will get evaluated first
            for(String key : returnMap.keySet()){
                returnMap.get(key).sort();
            }

            return returnMap;
        }
        /* @Name: getEmailRoutingRules
        *  @Author: Jeff L (Appirio)
        *  @Params: String
        *  @Returns: String
        *  @Description: returns the routing address, will return the whole string
                        if there is no @ sign, if there is an @ sign then we only return
                        the text before the @ sign
        */
        private String parseRoutingAddress(String pRoutingAddress){
            String returnString;
            if(pRoutingAddress != null){
                integer atIndex = pRoutingAddress.indexOf('@');
                if(atIndex == -1){
                    returnString = pRoutingAddress.toLowerCase();
                } else {
                   returnString = pRoutingAddress.left(atIndex).toLowerCase();
                }
            }
            return returnString;
        }
        /* @Name: getCatchAllRule
        *  @Author: Jeff L (Appirio)
        *  @Params: None
        *  @Returns: CaseRoutingRule__c
        *  @Description: gets the Catch all rule from the org settings custom setting
                         will return null if that setting is blank
        */
        private CaseRoutingRule__c getCatchAllRule(){
            final string METHODNAME = CLASSNAME.replace('METHODNAME','getCatchAllRule');
            system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
            CaseRoutingRule__c returnRule;
            Org_Settings__c orgSetting = Org_Settings__c.getOrgDefaults();
            if(orgSetting.Catch_All_Rule__c != null){
                returnRule = [
                    Select Id, OwnerId, CaseRecordType__c, CaseStatus__c, CaseIssue__c, CaseOrigin__c, Fraud_Monitor_Type__c,
                        CaseContactSource__c, Account__c, CaseSubStatus__c, CaseSubIssue__c, CaseBusinessHours__c, FirstContactCommitmentHours__c,
                        ResolutionCommitmentHours__c, CaseLanguage__c, SystemGenerated__c, BusinessProcess__c, Case_Priority__c,
                        Order_Type__c, Category__c, Routing_Status__c, FromAddressforAutoResponse__c,
                        AutoResponseTemplate__c, ForwardIncomingEmailTo__c, Group__c, Organization__c
                    from CaseRoutingRule__c
                    where Id = :orgSetting.Catch_All_Rule__c
                    LIMIT 1];
            }
            //TKOM S-473311: added Group__c, S-460088: added Organization__c

            if(returnRule == null){
                System.debug(logginglevel.WARN, 'No default case routing rule could be found - this could be an issue!!');
            }
            return returnRule;
        }
        /* @Name: matchFound
        *  @Author: Jeff L (Appirio)
        *  @Params: EmailMessageWrapper, CaseRoutingRule__c, List of autoresponse messages
        *  @Returns: updated Case
        *  @Description: This method is called when a match is found for email routing
                performs the actions when a successful match has been found
        */
        private Case matchFound(Case pCase, EmailMessage pMessage, CaseRoutingRule__c pMatchedRule, List<Messaging.SingleEmailMessage> pEmailResponseList){
            final string METHODNAME = CLASSNAME.replace('METHODNAME','matchFound');
            system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
            Case returnCase = pCase;
            returnCase = CaseTriggerHelper.populateCaseRoutingRuleInfo(returnCase, pMatchedRule);
            if(pMatchedRule.AutoResponseTemplate__c != null){
                pEmailResponseList.addall(CaseTriggerHelper.sendAutoReponseEmail(returnCase,pMatchedRule,pMessage));
            }
            return returnCase;
        }
    }
}