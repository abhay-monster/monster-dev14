public without sharing class Utility {
    final String CLASSNAME = '\n\n**** Utility.METHODNAME()\n\n';
    private static Utility instance;

    //These static properties are used to control whether the triggerhandler code will fire
    //Mainly used to stop recursive triggers from firiing an racking up SOQL limits
    public static Boolean ExecuteOpportunityTrigger{get; set;}

    public static Utility newInstance(){
        return instance == null ? new Utility() : instance;
    }

    public Utility(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','Utility') + ' - constructor';
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
    }

    public static List<RecordType> AllRecordsTypes {

        get{
            if(AllRecordsTypes == null){
                AllRecordsTypes = [SELECT Id, Name, SobjectType FROM RecordType LIMIT 50000];
            }
            return AllRecordsTypes;
        }
        set;
    }



    public class IntegrationSetting{
        public String AvalaraClient;
        public String AvalaraCompanyCode;
        public String AvalaraCountry;
        public String Endpoint;
        public Integer Timeout;
        public String Username;
        public String Password;
        public String USPSUserID;
        public String PaypalPartner;public String PaypalRedirectURL;
        public String PaypalMode;
        public String PaypalVendor;
    }
    public static IntegrationSetting getIntegrationSetting(String pSettingName){
        IntegrationSetting output = new IntegrationSetting();
        try{
            IntegrationConfig__c setting = IntegrationConfig__c.getValues(pSettingName);
            if(setting == null){
                system.debug('\n\nSetting extraction error: '+pSettingName+' Name not found. \nPlease check IntegrationConfig__c custom setting.\n\n');
            }

            output.AvalaraClient = setting.AvalaraClient__c;
            output.AvalaraCompanyCode = setting.AvalaraCompanyCode__c;
            output.Endpoint = getWebServiceEnpoint(setting.EndpointName__c);
            output.Timeout = Integer.ValueOf(setting.Timeout__c);
            output.Username = setting.Username__c;
            output.Password = setting.Password__c;
            output.USPSUserID = setting.USPSUserID__c;
            output.AvalaraCountry = setting.AvalaraCountry__c;
            output.PaypalPartner = setting.PaypalPartner__c;
            output.PaypalVendor = setting.PaypalVendor__c;
            output.PaypalRedirectURL = getWebServiceEnpoint(setting.PaypalRedirectURL__c);
            output.PaypalMode = setting.IsPaypalTest__c == true ? 'TEST' : 'LIVE';
        }catch(Exception e){
            throw BaseApplicationException.NewException('Utility.getWebServiceEnpoint()',
            'IntegrationSetting initialization error: Please check IntegrationConfig__c custom setting.');
        }
        system.debug('\n\nIntegration Setting for ' +pSettingName + ': ' +JSON.serializePretty(output)+'\n\n');
        return output;
    }

    public static String getWebServiceEnpoint(String pSettingName){
        system.debug('\n\n**** Inside Utility.getWebServiceEnpoint\nSetting Name: ' + pSettingName + '\n\n');
        try{
            WebServiceEndpoint__c endpoint = WebServiceEndpoint__c.getValues(pSettingName);
            if(endpoint == null){
                system.debug('\n\nEndpoint extraction error: '+pSettingName+' Name not found. \nPlease check WebServiceEndpoint__c custom setting.\n\n');
            }
            return endpoint.Endpoint__c;
        }catch(Exception e){
            throw BaseApplicationException.NewException('Utility.getWebServiceEnpoint()',
            'Endpoint initialization error: Please check WebServiceEndpoint__c custom setting.');
        }
        return null;
    }

    public static final String DEFAULT_AVALARA_ADDRESS = 'United States';
    public static AvalaraAddressInfo__c getAvalaraAddressInfo(String pSellingContry){
        system.debug('\n\n**** Inside Utility.getAvalaraAddressInfo\nSetting Name: ' + pSellingContry + '\n\n');
        try{
            AvalaraAddressInfo__c addressInfo = AvalaraAddressInfo__c.getValues(pSellingContry);
            if(addressInfo == null){
                addressInfo = AvalaraAddressInfo__c.getValues(DEFAULT_AVALARA_ADDRESS);
                system.debug('\n\nAvalaraAddressInfo extraction warning: '+pSellingContry+' Name not found. \nPlease check AvalaraAddressInfo__c custom setting\n Defaulting address to '+DEFAULT_AVALARA_ADDRESS+'.\n\n');
                if(addressInfo == null){
                    system.debug('\n\nAvalaraAddressInfo extraction error: Default Avalara Address not found: '+DEFAULT_AVALARA_ADDRESS+'. \nPlease check AvalaraAddressInfo__c custom setting.\n\n');
                }
            }
            return addressInfo;
        }catch(Exception e){
            throw BaseApplicationException.NewException('Utility.getAvalaraAddressInfo()',
            'Address initialization error: Please check AvalaraAddressInfo__c custom setting.');
        }
        return null;
    }

    public static String GetCurrencyByCountry(String pCountry){
        system.debug('\n\n**** Inside Utility.GetCurrencyFromCountry\nCountry: ' + pCountry + '\n\n');
        try{
            if(pCountry != null && pCountry != ''){
                CurrencyByCountry__c ISO = CurrencyByCountry__c.getValues(pCountry);
                if(ISO != null){
                    return ISO.ISOCode__c;
                }
                system.debug('\n\nInvalid country: ' + pCountry + '.\nNo Currency ISO code retrieved.\n\n');
            }

        }catch(Exception e){
            String ErrorMsg = 'Error: ' + e;
            system.debug('\n\n' + ErrorMsg + '\n\n');
            if(ErrorMsg.contains('Custom Setting Name too long')){
                map<String, CurrencyByCountry__c> allData = CurrencyByCountry__c.getAll();
                for(String key : allData.keySet()){
                    if(pCountry.contains(key)){
                        String ISOFromException = allData.get(key).ISOCode__c;
                        system.debug('\n\nExtracted ISO Code: ' + ISOFromException + '\n\n');
                        return ISOFromException;
                    }
                }
            }
        }
        return 'false';
    }

    public Map<String, Map<String, String>> getSObjectsFieldsLabels(Set<String> SObjectNameSet){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','getSObjectsFieldsLabels');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Map<String, Map<String, Schema.SObjectField>> sobjectFields = getAllSObjectFieldsBySObjectName(SObjectNameSet);
        Map<String, Map<String, String>> output = new Map<String, Map<String, String>>();

        for(String sObjectName : SObjectNameSet){
            if(sobjectFields.get(sObjectName) != null){
                Map <String, String> APINameToLabel = new Map<String, String>();
                for(String fieldAPIName : sobjectFields.get(sObjectName).keySet()){
                    DescribeFieldResult fieldDescribe = sObjectFields.get(sObjectName).get(fieldAPIName).getDescribe();
                    APINameToLabel.put(fieldAPIName, fieldDescribe.getLabel());
                }

                output.put(sObjectName, APINameToLabel);
            }else{
                output.put(sObjectName, null);
            }
        }
        return output;
    }

    public Map<String, Map<String, Schema.SObjectField>> getAllSObjectFieldsBySObjectName(Set<String> SObjectNameSet){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','getAllSObjectFieldsBySObjectName');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Map<String, Schema.SObjectType> SObjects = getAllSpecifiedSObjects(SObjectNameSet);

        Map<String, Map<String, Schema.SObjectField>> output = new Map<String, Map<String, Schema.SObjectField>>();

        for(String sObjectName : SObjectNameSet){
            if(SObjects.get(sObjectName) != null){
                output.put(sObjectName, SObjects.get(sObjectName).getDescribe().fields.getMap());
            }else{
                output.put(sObjectName, null);
            }
        }
        return output;
    }

    public Map<String, Schema.SObjectType> getAllSpecifiedSObjects(Set<String> SObjectNameSet){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','getAllSpecifiedSObjects');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Map<String, Schema.SObjectType> allSObjects = Schema.getGlobalDescribe();

        Map<String, Schema.SObjectType> sObjectSet = new Map<String, Schema.SObjectType>();
        for(String sObjectName : SObjectNameSet){
            if(allSObjects.containsKey(sObjectName)){
                sObjectSet.put(sObjectName, allSObjects.get(sObjectName));
            }else{
                system.debug('\n\ngetAllSpecifiedSObjects warning: Invalid SObject Name \''+sObjectName+'\'\n\n');
                sObjectSet.put(sObjectName, null);
            }
        }
        return sObjectSet;
    }

    private static map<String, map<String, Id>> RecordTypeCache;
    private static map<String, map<Id, String>> RecordTypeCache2;

    private static set<String> getFromCache(Set<String> pSObjectName, map<String, map<String, Id>> pTargetOutput){
        set<String> output = new set<String>();
        for(String s : pSObjectName){
            if(RecordTypeCache.containsKey(s)){
                pTargetOutput.put(s, RecordTypeCache.get(s));
            }else{
                output.add(s);
            }
        }
        return output;
    }

    public static Id GetRecordTypeIdBySObjectNameAndType(String pSObjectName, String pRecordTypeName){
        if(RecordTypeCache != null && RecordTypeCache.containsKey(pSObjectName)){
            return RecordTypeCache.get(pSObjectName).get(pRecordTypeName);
        }
        map<String, map<String, Id>> result =  GetRecordTypeIdsBySObjectNameSet(new Set<String>{pSObjectName});
        return result.containsKey(pSObjectName)? result.get(pSObjectName).get(pRecordTypeName) : null;
    }

    public static map<string,id> GetRecordTypeIdsbyName(String pSObjectName){
        if(RecordTypeCache == null){
            RecordTypeCache = new map<String, map<String, Id>>();
        }
        else if(RecordTypeCache.containsKey(pSObjectName)){
            return RecordTypeCache.get(pSObjectName);
        }
        // Move query to setter method
        //RecordType[] recTypeList = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType IN :usedSObjectNameSet];
        Map<String,Id> output = new Map<String,id>();
        RecordType[] recTypeList = AllRecordsTypes;
        for(RecordType rec : recTypeList){
            if(rec.SobjectType == pSObjectName){
                System.Debug('###'+rec);
                output.put(rec.Name, rec.Id);
            }
            if(!RecordTypeCache.containsKey(pSObjectName)){
                RecordTypeCache.put(pSObjectName,new Map<string,id>());
            }
            RecordTypeCache.get(pSObjectName).put(rec.Name, rec.Id);
        }
        return output;
    }

    public static map<Id,String> GetRecordTypeNamesbyIds(String pSObjectName){
        if(RecordTypeCache2 == null){
            RecordTypeCache2 = new map<String, map<Id, String>>();
        }
        else if(RecordTypeCache2.containsKey(pSObjectName)){
            return RecordTypeCache2.get(pSObjectName);
        }
        // Move query to setter method
        //RecordType[] recTypeList = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType IN :usedSObjectNameSet];
        Map<Id,String> output = new Map<Id,String>();
        RecordType[] recTypeList = AllRecordsTypes;
        for(RecordType rec : recTypeList){
            if(rec.SobjectType == pSObjectName){
                output.put(rec.Id, rec.Name);
            }
            if(!RecordTypeCache2.containsKey(pSObjectName)){
                RecordTypeCache2.put(pSObjectName,new Map<Id,String>());
            }
            RecordTypeCache2.get(pSObjectName).put(rec.id, rec.Name);
        }
        return output;
    }

    public static map<String, map<String, Id>> GetRecordTypeIdsBySObjectNameSet(Set<String> pSObjectNameSet){
        if(RecordTypeCache == null){
            RecordTypeCache = new map<String, map<String, Id>>();
        }
        map<String, map<String, Id>> output = new map<String, map<String,Id>>();

        Set<String> usedSObjectNameSet = getFromCache(pSObjectNameSet, output);
        if(usedSObjectNameSet.size() == 0){
            return output;
        }
        // Move query to setter method
        //RecordType[] recTypeList = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType IN :usedSObjectNameSet];

        RecordType[] recTypeList = AllRecordsTypes;
        for(RecordType rec : recTypeList){
            if(!output.containsKey(rec.SobjectType)){
                output.put(rec.SobjectType, new map<String, Id>());
            }
            output.get(rec.SobjectType).put(rec.Name, rec.Id);
            RecordTypeCache.put(rec.SobjectType, output.get(rec.SobjectType));
        }
        return output;
    }

    public static Double parseDouble(Object val){
        return val == null ? 0 : Double.valueOf(val);
    }

    public static Boolean IsNotValidTestRecord(String fieldToCheck, SObject[] pRecordsToTest, set<String> pTestRecordIdSet){
        try{
            for(SObject testRecord : pRecordsToTest){
                if(!pTestRecordIdSet.contains(String.valueOf(testRecord.get(fieldToCheck)).left(15))){
                    system.debug('Invalid Test Record');
                    return true;
                }
            }
        }catch(Exception e){
            system.debug('Error in IsValidTestRecord: ' + e);
        }
        return false;
    }

    public static Double getPercentage(Object pVal){
        return pVal == null ? 0 : Double.valueOf(pVal) * 100;
    }

    public static void triggerOpportunityOrderCreation(Id pOppId){
        Opportunity[] parentOppList = [SELECT Id, OrderCreated__c FROM Opportunity WHERE Id = :pOppId];
        if(parentOppList != null && !parentOppList.isEmpty()){
            parentOppList[0].OrderCreated__c = true;
            update parentOppList[0];
        }
    }


    public void postChatterFeed(String recordId, set<String> mentionIds,String postText) {

        ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
        messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

        ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
        textSegment.text = 'Hi ';
        messageInput.messageSegments.add(textSegment);

        for(String id : mentionIds){
            ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
            mentionSegment.id = id; // The ID of the user to mention.
            messageInput.messageSegments.add(mentionSegment);
        }

        textSegment = new ConnectApi.TextSegmentInput();
        textSegment.text = postText;
        messageInput.messageSegments.add(textSegment);

        ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
        input.body = messageInput;
        input.subjectId = recordId;

        ConnectApi.FeedElement  fi = ConnectApi.ChatterFeeds.postFeedElement(null, input, null);
    }

    /*private static List<CaseRoutingRule__c> listCaseRoutingRules;

    public static List<CaseRoutingRule__c> getCaseRoutingRules(){
        if(listCaseRoutingRules == null){
            listCaseRoutingRules = [SELECT Id, Name, OwnerId, InboundEmailAddress__c, caseBusinessHours__c, CaseContactSource__c, BusinessProcess__c,Routing_Status__c,
                                                    CaseIssue__c, CaseLanguage__c, CaseOrigin__c, CaseOwner__c, CaseRecordType__c, CaseStatus__c,
                                                    CaseSubIssue__c,CaseSubStatus__c, FirstContactCommitmentHours__c, ResolutionCommitmentHours__c, SystemGenerated__c,
                                                    ForwardIncomingEmailTo__c,EmailBodyContains__c,EmailHeaderContains__c,EmailSubjectContains__c,Case_Subject__c,
                                                    FromAddressforAutoResponse__c,QuoteSellingCountry__c,SenderEmailContains__c,Current_User_Country__c, Billing_Country__c,
                                                    AutoResponseTemplate__c, Case_Priority__c, Order_Type__c, Fraud_Monitor_Type__c, Account__c, Quote_Record_Type__c, Service_Tier__c,
                                                    Organization__c, Category__c,Assign_to_Verified_By__c, SFDC_Routing_Address__c
                                                FROM CaseRoutingRule__c Where Routing_Status__c IN ('Active','Debug')];
        }
        return listCaseRoutingRules;
    }

    public static List<CaseRoutingRule__c> getCaseRoutingRulesEmail(){
        //if(listCaseRoutingRules == null){
            return [SELECT Id, Name, OwnerId, InboundEmailAddress__c, caseBusinessHours__c, CaseContactSource__c, BusinessProcess__c,Routing_Status__c,
                                                    CaseIssue__c, CaseLanguage__c, CaseOrigin__c, CaseOwner__c, CaseRecordType__c, CaseStatus__c,
                                                    CaseSubIssue__c,CaseSubStatus__c, FirstContactCommitmentHours__c, ResolutionCommitmentHours__c, SystemGenerated__c,
                                                    ForwardIncomingEmailTo__c,EmailBodyContains__c,EmailHeaderContains__c,EmailSubjectContains__c,Case_Subject__c,
                                                    FromAddressforAutoResponse__c,QuoteSellingCountry__c,SenderEmailContains__c,Current_User_Country__c, Billing_Country__c,
                                                    AutoResponseTemplate__c, Case_Priority__c, Order_Type__c, Fraud_Monitor_Type__c, Account__c, Quote_Record_Type__c, Service_Tier__c,
                                                    Organization__c, Category__c,Assign_to_Verified_By__c, SFDC_Routing_Address__c
                                                FROM CaseRoutingRule__c Where Routing_Status__c IN ('Active','Debug') and RecordType.Name = 'Email'];
        //}
        //return listCaseRoutingRules;
    }

    public static List<CaseRoutingRule__c> getCaseRoutingRulesInternal(){
        // if(listCaseRoutingRules == null){
            return  [SELECT Id, Name, OwnerId, InboundEmailAddress__c, caseBusinessHours__c, CaseContactSource__c, BusinessProcess__c,Routing_Status__c,
                                                    CaseIssue__c, CaseLanguage__c, CaseOrigin__c, CaseOwner__c, CaseRecordType__c, CaseStatus__c,
                                                    CaseSubIssue__c,CaseSubStatus__c, FirstContactCommitmentHours__c, ResolutionCommitmentHours__c, SystemGenerated__c,
                                                    ForwardIncomingEmailTo__c,EmailBodyContains__c,EmailHeaderContains__c,EmailSubjectContains__c,Case_Subject__c,
                                                    FromAddressforAutoResponse__c,QuoteSellingCountry__c,SenderEmailContains__c,Current_User_Country__c, Billing_Country__c,
                                                    AutoResponseTemplate__c, Case_Priority__c, Order_Type__c, Fraud_Monitor_Type__c, Account__c, Quote_Record_Type__c, Service_Tier__c,
                                                    Organization__c, Category__c,Assign_to_Verified_By__c
                                                FROM CaseRoutingRule__c Where Routing_Status__c IN ('Active','Debug') and RecordType.Name = 'Internal'];
        //}
        //return listCaseRoutingRules;
    }*/

    private static Map<String,Id> mapEmailTemplates;

    public static Map<String,Id> getEmailTemplates(){
        if(mapEmailTemplates == null){
            List<EmailTemplate> listEmailTemplates = [SELECT Id, DeveloperName FROM EmailTemplate Where IsActive = true];

            mapEmailTemplates = new Map<String,id>();
            for(EmailTemplate et:listEmailTemplates){
                mapEmailTemplates.put(et.DeveloperName,et.Id);
            }
        }
        return mapEmailTemplates;
    }

    public static String GetMappPrimarySalesRep(String pCountry){
        system.debug('\n\n**** Inside Utility.GetMappPrimarySalesRep\nCountry: ' + pCountry + '\n\n');
        try{

            if(pCountry != null && pCountry != ''){
                MappPrimarySalesRep__c alias = MappPrimarySalesRep__c.getValues(pCountry);
                if(alias != null){
                    system.debug('alias.Username' + alias.UserAlias__c );
                    return alias.UserAlias__c;
                }
                system.debug('\n\nInvalid country: ' + pCountry + '.\nNo default primary sales rep retrieved.\n\n');
            }

        }catch(Exception e){
             throw BaseApplicationException.NewException('Utility.GetMappPrimarySalesRep()',
            'Default MappPrimarySalesrep error: Please check  MappPrimarySalesRep__c custom setting.');

        }
        return null;
    }

    /*
    ** @author : Appirio (J Freese)
    ** @date : 2/20/17
    ** @description : Generic Send Email method from ArchiveHelper.cls
    ** @returns : nothing
    */
    public static Void sendEmail(String process, String objectName, List<String> ccAddresses, String summary, String errors, String customSubject) {
    system.debug('***** Inside Utility.sendEmail *****');

    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

    List<String> toAddresses = new List<String>();
    toAddresses.add(UserInfo.getUserEmail());
    mail.setToAddresses(toAddresses);

    if (ccAddresses.size() > 0){
        mail.setCcAddresses(ccAddresses);
    }
    String username = UserInfo.getUserName().toUpperCase();
    String org = '';
    if (username.contains('MONSTER')){
      org = username.mid(username.indexOf('.COM') + 5, 30);
    }
    else {
      org = 'OrgId ' + UserInfo.getOrganizationId();
    }

    String subject = process + ' of ' + org + ' ' + objectName + ' Records';
    if (errors != ''){
      subject += ' Encountered Problem(s)';
    }
    else {
      subject += ' Was Successful';
    }
    //Appirio JFreese 4/25/17 S-481980 add customSubject to sendEmail
    if (customSubject != null && customSubject != ''){
        subject = customSubject;
    }
    mail.setSubject(subject);

    String header = '';
    String body = '';
    header += 'Salesforce Org: ' + org + '<BR>';
    header += process + ' User: ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + '<BR>';
    header += process + ' Summary: ' + summary + '<BR><BR>';

    if (errors == ''){
        body += 'No problems were encountered in ' + process + ' processing of the records.';
    } else {
      body += 'The following error(s) were encountered:<BR><BR>';
      body += errors;
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
        errmail.setSubject(subject);

        String errbody = '';
        errbody += 'The ' + process.toLowerCase() + ' email failed to send correctly.  Send results were as follows:<BR>';
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

    //utility to test if a fields on two records are equal
    public static Boolean isFieldEqual(sObject record1, sObject record2, String fieldToTest)
    {
        return record1.get(fieldToTest) == record2.get(fieldToTest);
    }

    //utility to test if a field on two records are equal, takes a map
    public static Boolean isFieldEqual(sObject record1, Map<Id,sObject> record2Map, String fieldToTest){
        return isFieldEqual(record1,record2Map.get(record1.Id),fieldToTest);
    }

    //utility to test if a field on two records are different
    public static Boolean isFieldDifferent(sObject record1, sObject record2, String fieldToTest)
    {
        return !isFieldEqual(record1,record2,fieldToTest);
    }

    //utility to test if a field on two records are different, takes a map
    public static Boolean isFieldDifferent(sObject record1, Map<Id,sObject> record2Map, String fieldToTest){
        return isFieldDifferent(record1,record2Map.get(record1.Id),fieldToTest);
    }

    //Use this function to determine if the currently running user is the Integration Mapp user.
    @testVisible private static boolean isIntegrationMapp;
    public static boolean isCurrentUserIntegrationMapp()
    {
        if(isIntegrationMapp == null)
        {
            isIntegrationMapp = UserInfo.getName() == 'Integration MAPP';
        }

        return isIntegrationMapp;
    }


    //JFreese Appirio S-435483 4/10/17 Copy from TABatchVirtualQueueable
    public static TA_Records_per_Queueable__mdt getCustomMetadata(){
        TA_Records_per_Queueable__mdt returnSetting =
            [Select DeveloperName,
               /*AccountTeamMember__c,*/
               Activity__c, Contact__c, Opportunity__c,
               /*OpportunityTeamMember__c,*/
               Proposal__c,
               /*Set_TA_Team_Member_flag_on_Existing_ATM__c, Set_TA_Team_Member_flag_on_Existing_OTM__c,*/
               Debug_Mode__c, Bypass_Validation_Rules__c
               from TA_Records_per_Queueable__mdt
               where DeveloperName='Master' Limit 1];

        return returnSetting;
    }

}