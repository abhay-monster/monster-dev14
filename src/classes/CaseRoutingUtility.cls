public without sharing class CaseRoutingUtility {
    final static String CLASSNAME = '\n\n**** CaseRoutingUtility.METHODNAME()';
    private static List<CaseRoutingRule__c> allRoutingRules;
    private static List<CaseRoutingRule__c> emailRoutingRules;
    private static List<CaseRoutingRule__c> internalRoutingRules;
    private static Map<String,String> criteriaMap;

    /* @Name: getCaseRoutingRules
    *  @Author: Jeff L (Appirio)
    *  @Params: None
    *  @Returns: List<CaseRoutingRule__c>
    *  @Description: gets all of the routing rules for Case Routing Rules (all)
    */
    public static List<CaseRoutingRule__c> getCaseRoutingRules(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','getCaseRoutingRules');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        if(allRoutingRules == null){
            allRoutingRules = [SELECT Id, Name, OwnerId, InboundEmailAddress__c, caseBusinessHours__c, CaseContactSource__c, BusinessProcess__c,Routing_Status__c,
                                                    CaseIssue__c, CaseLanguage__c, CaseOrigin__c, CaseOwner__c, CaseRecordType__c, CaseStatus__c,
                                                    CaseSubIssue__c,CaseSubStatus__c, FirstContactCommitmentHours__c, ResolutionCommitmentHours__c, SystemGenerated__c,
                                                    ForwardIncomingEmailTo__c,EmailBodyContains__c,EmailHeaderContains__c,EmailSubjectContains__c,Case_Subject__c,
                                                    FromAddressforAutoResponse__c,QuoteSellingCountry__c,SenderEmailContains__c,Current_User_Country__c, Billing_Country__c,
                                                    AutoResponseTemplate__c, Case_Priority__c, Order_Type__c, Fraud_Monitor_Type__c, Account__c, Quote_Record_Type__c, Service_Tier__c,
                                                    Organization__c, Category__c,Assign_to_Verified_By__c, SFDC_Routing_Address__c, Case_Request_Type__c, Product_Family__c,	Product_Line__c,	Product_Name__c, Product_Name__r.Name,	Proposal_Language__c,	Posting_Country__c,	Media_Product__c,	Assign_To_Primary_Service_Rep__c,	Agency_Account__c, Agency_Account__r.Name, Group__c

                                                FROM CaseRoutingRule__c Where Routing_Status__c IN ('Active','Debug')];
                                                //Sberron - 1/12/17 - S-445804
                                                    // Added Skip_Case_Creation__c && Attachment_File_Types__c
                                                    // TKOM add for S-445214: , Product_Family__c,	Product_Line__c,	Product_Name__c, Product_Name__r.Name,	Proposal_Language__c,	Posting_Country__c,	Media_Product__c,	Assign_To_Primary_Service_Rep__c,	Agency_Account__c, Agency_Account__r.Name
                                                    // TKOM add for S-473311: Group__c
        }
        return allRoutingRules;
    }

    /* @Name: getCaseRoutingRulesEmail
    *  @Author: Jeff L (Appirio)
    *  @Params: None
    *  @Returns: List<CaseRoutingRule__c>
    *  @Description: gets all of the routing rules for Case Routing Rules (Email)
    */
    public static List<CaseRoutingRule__c> getCaseRoutingRulesEmail(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','getCaseRoutingRulesEmail');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        if(emailRoutingRules == null){
            emailRoutingRules = [SELECT Id, Name, OwnerId, InboundEmailAddress__c, caseBusinessHours__c, CaseContactSource__c, BusinessProcess__c,Routing_Status__c,
                                                    CaseIssue__c, CaseLanguage__c, CaseOrigin__c, CaseOwner__c, CaseRecordType__c, CaseStatus__c,
                                                    CaseSubIssue__c,CaseSubStatus__c, FirstContactCommitmentHours__c, ResolutionCommitmentHours__c, SystemGenerated__c,
                                                    ForwardIncomingEmailTo__c,EmailBodyContains__c,EmailHeaderContains__c,EmailSubjectContains__c,Case_Subject__c,
                                                    FromAddressforAutoResponse__c,QuoteSellingCountry__c,SenderEmailContains__c,Current_User_Country__c, Billing_Country__c,
                                                    AutoResponseTemplate__c, Case_Priority__c, Order_Type__c, Fraud_Monitor_Type__c, Account__c, Quote_Record_Type__c, Service_Tier__c,
                                                    Organization__c, Category__c,Assign_to_Verified_By__c, SFDC_Routing_Address__c, Case_Request_Type__c, Product_Family__c,	Product_Line__c,	Product_Name__c, Product_Name__r.Name,	Proposal_Language__c,	Posting_Country__c,	Media_Product__c,	Assign_To_Primary_Service_Rep__c,	Agency_Account__c, Agency_Account__r.Name, Group__c
                                                FROM CaseRoutingRule__c Where Routing_Status__c IN ('Active','Debug') and RecordType.Name = 'Email'];
                                                //Sberron - 1/12/17 - S-445804
                                                    // Added Skip_Case_Creation__c && Attachment_File_Types__c
                                                    // TKOM add for S-445214: , Product_Family__c,	Product_Line__c,	Product_Name__c, Product_Name__r.Name,	Proposal_Language__c,	Posting_Country__c,	Media_Product__c,	Assign_To_Primary_Service_Rep__c,	Agency_Account__c, Agency_Account__r.Name
                                                    // TKOM add for S-473311: Group__c
        }
        return emailRoutingRules;
    }

    /* @Name: getCaseRoutingRulesWeb
    *  @Author: Shyam S (Appirio)
    *  @Params: None
    *  @Returns: List<CaseRoutingRule__c>
    *  @Description: gets all of the routing rules for Case Routing Rules (Web)
    */
    public static List<CaseRoutingRule__c> getCaseRoutingRulesWeb(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','getCaseRoutingRulesWeb');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        if(emailRoutingRules == null){
            emailRoutingRules = [SELECT Id, Name, OwnerId, InboundEmailAddress__c, caseBusinessHours__c, CaseContactSource__c, BusinessProcess__c,Routing_Status__c,
                                                    CaseIssue__c, CaseLanguage__c, CaseOrigin__c, CaseOwner__c, CaseRecordType__c, CaseStatus__c,
                                                    CaseSubIssue__c,CaseSubStatus__c, FirstContactCommitmentHours__c, ResolutionCommitmentHours__c, SystemGenerated__c,
                                                    ForwardIncomingEmailTo__c,EmailBodyContains__c,EmailHeaderContains__c,EmailSubjectContains__c,Case_Subject__c,
                                                    FromAddressforAutoResponse__c,QuoteSellingCountry__c,SenderEmailContains__c,Current_User_Country__c, Billing_Country__c,
                                                    AutoResponseTemplate__c, Case_Priority__c, Order_Type__c, Fraud_Monitor_Type__c, Account__c, Quote_Record_Type__c, Service_Tier__c,
                                                    Organization__c, Category__c,Assign_to_Verified_By__c, SFDC_Routing_Address__c, Case_Request_Type__c, Product_Family__c,	Product_Line__c,	Product_Name__c, Product_Name__r.Name,	Proposal_Language__c,	Posting_Country__c,	Media_Product__c,	Assign_To_Primary_Service_Rep__c,	Agency_Account__c, Agency_Account__r.Name, Group__c
                                                FROM CaseRoutingRule__c Where Routing_Status__c IN ('Active','Debug') and RecordType.Name = 'Web'];
                                                //Sberron - 1/12/17 - S-445804
                                                    // Added Skip_Case_Creation__c && Attachment_File_Types__c
                                                    // TKOM add for S-445214: , Product_Family__c,	Product_Line__c,	Product_Name__c, Product_Name__r.Name,	Proposal_Language__c,	Posting_Country__c,	Media_Product__c,	Assign_To_Primary_Service_Rep__c,	Agency_Account__c, Agency_Account__r.Name
                                                    // TKOM add for S-473311: Group__c
        }
        return emailRoutingRules;
    }

    /* @Name: getCaseRoutingRulesEmail
    *  @Author: Jeff L (Appirio)
    *  @Params: None
    *  @Returns: List<CaseRoutingRule__c>
    *  @Description: gets all of the routing rules for Case Routing Rules (Internal)
    */
    public static List<CaseRoutingRule__c> getCaseRoutingRulesInternal(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','getCaseRoutingRulesInternal');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        if(internalRoutingRules == null){
            internalRoutingRules = [SELECT Id, Name, OwnerId, InboundEmailAddress__c, caseBusinessHours__c, CaseContactSource__c, BusinessProcess__c,Routing_Status__c,
                                                    CaseIssue__c, CaseLanguage__c, CaseOrigin__c, CaseOwner__c, CaseRecordType__c, CaseStatus__c,
                                                    CaseSubIssue__c,CaseSubStatus__c, FirstContactCommitmentHours__c, ResolutionCommitmentHours__c, SystemGenerated__c,
                                                    ForwardIncomingEmailTo__c,EmailBodyContains__c,EmailHeaderContains__c,EmailSubjectContains__c,Case_Subject__c,
                                                    FromAddressforAutoResponse__c,QuoteSellingCountry__c,SenderEmailContains__c,Current_User_Country__c, Billing_Country__c,
                                                    AutoResponseTemplate__c, Case_Priority__c, Order_Type__c, Fraud_Monitor_Type__c, Account__c, Quote_Record_Type__c, Service_Tier__c,
                                                    Organization__c, Category__c,Assign_to_Verified_By__c, Case_Request_Type__c, Product_Family__c,	Product_Line__c,	Product_Name__c, Product_Name__r.Name,	Proposal_Language__c,	Posting_Country__c,	Media_Product__c,	Assign_To_Primary_Service_Rep__c,	Agency_Account__c, Agency_Account__r.Name, Group__c
                                                FROM CaseRoutingRule__c Where Routing_Status__c IN ('Active','Debug') and RecordType.Name = 'Internal'];
                                                //Sberron - 1/12/17 - S-445804
                                                    // Added Skip_Case_Creation__c && Attachment_File_Types__c
                                                    // TKOM add for S-445214: , Product_Family__c,	Product_Line__c,	Product_Name__c, Product_Name__r.Name,	Proposal_Language__c,	Posting_Country__c,	Media_Product__c,	Assign_To_Primary_Service_Rep__c,	Agency_Account__c, Agency_Account__r.Name
                                                    // TKOM add for S-473311: Group__c
        }
        return internalRoutingRules;
    }

    /* @Name: getCriteriaMap
    *  @Author: Jeff L (Appirio)
    *  @Params: none
    *  @Returns: Map<String,String>
    *  @Description: this logic contains the case routing rule criteria fields
                    API names, and the corresponding emailMessage API names
                    Can be modified in the future if more fields wanted to be added
                    for comparison - didn't want to create another custom setting.
    */
    public static Map<String,String> getCriteriaMap(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','getCriteriaMap');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        if(criteriaMap == null){
            criteriaMap = new Map<String,String>{
                'SenderEmailContains__c' => 'FromAddress',
                'EmailBodyContains__c' => 'TextBody',
                'EmailHeaderContains__c' => 'Headers',
                'EmailSubjectContains__c' => 'Subject'
            };
        }
        return criteriaMap;
    }
}