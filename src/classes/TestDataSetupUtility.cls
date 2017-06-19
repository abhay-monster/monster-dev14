/*
** @author : Cloud Sherpas Inc.
** @date : 03/07/2014
** @description : Utility Factory class for generateing Unit Test objects.
*/
@isTest
public class TestDataSetupUtility
{
    public static Id PROFILE_ID = [select Id From Profile Where Name = 'System Administrator'].Id;
    public static Id SALESREP_APAC_PROFILE_ID = [select Id From Profile Where Name = 'Sales Rep (APAC)'].Id;
    public static Id SALESOP_NA_PROFILE_ID = [select Id From Profile Where Name = 'Sales Operations (NA)'].Id;
    //public static Id SALESOP_EU_PROFILE_ID = [select Id From Profile Where Name = 'Sales Operations (EU)'].Id; Commented out 12/28/15, not being used in this class
    //public static Id SALESOP_APAC_PROFILE_ID = [select Id From Profile Where Name = 'Sales Operations (APAC)'].Id; Added per I-197559, not being used in this class
    public static Id FINANCE_NA_PROFILE_ID = [select Id From Profile Where Name = 'Finance (NA)'].Id;
    public static Id ORDERMGMT_NA_PROFILE_ID = [select Id From Profile Where Name like 'Order Management (NA)'].Id;
    public static Map < String, Schema.SObjectType > GLOBAL_MAP = Schema.getGlobalDescribe();
    private static Map < String, Schema.DescribeSObjectResult > mapSobjectDescribe = new Map < String, Schema.DescribeSObjectResult > ();

    public static Apttus_Config2__ProductConfiguration__c createTestProductConfig(Apttus_Proposal__Proposal__c proposal, Account acc,Apttus_Config2__PriceList__c price) {
        Apttus_Config2__ProductConfiguration__c config = new Apttus_Config2__ProductConfiguration__c();
        config.Name = 'Product Config - 1 posting';
        config.Apttus_Config2__VersionNumber__c = 1;
        config.Apttus_Config2__SummaryGroupType__c = 'Category';
        config.Apttus_Config2__Status__c = 'New';
        config.Apttus_QPConfig__Proposald__c = proposal.id;
        config.Apttus_Config2__BusinessObjectId__c = 'a0mq0000000Ra0bAAC';
        config.Apttus_Config2__BusinessObjectType__c = 'Proposal';
        config.Apttus_Config2__AccountId__c = acc.id;
        config.Apttus_Config2__EffectivePriceListId__c = price.Id;
        config.Apttus_Config2__PriceListId__c = price.id;
        config.Apttus_Config2__ExpectedStartDate__c = (System.now()).date();
        config.Apttus_Config2__ExpectedEndDate__c = (System.now()).date().addDays(30);
        config.Apttus_Config2__IsTransient__c = true;
        return config;
    }

    public static Account createTestAccount(String name, String orgName, Id repOwnerId) {
        Id businessAccount =  Utility.GetRecordTypeIdBySObjectNameAndType('Account', 'Business Accounts');

        Account accAccount = new Account(Name = name+ String.valueOf(Math.random()),
            PrimaryServiceRep__c = repOwnerId,
            BillingStreet = 'Green Street',
            BillingCity = 'NY',
            BillingState = 'California',
            BillingPostalCode = '95123',
            //ShippingPostalCode = '95123',
            BillingCountry = 'United States',
            Type = 'Vendor',
            Website = 'www.xyz.com',
            Organization__c = orgName,
            Phone = '9124576517',
            CreditStatus__c ='Ok',
            ShippingCity = 'Shipping City',
          ShippingPostalCode = '3344',
          ShippingState = 'California',
          ShippingStreet = '2298 PostingStreet',
          ShippingCountry = 'United States',
          AcctMatchingRuleEnabled__c = false,
          RecordTypeId = businessAccount);
        return accAccount;
    }
    public static Id getRecordTypeId(String recTypeName, String sObjectName) {
        if (!mapSobjectDescribe.containsKey(sObjectName)) {
            Schema.DescribeSObjectResult sobjectDescribe = GLOBAL_MAP.get(sObjectName).getDescribe();
            mapSobjectDescribe.put(sObjectName, sobjectDescribe);
        }
        Schema.DescribeSObjectResult DescribeSObjectResultObj = mapSobjectDescribe.get(sObjectName);
        Map < String, Schema.RecordTypeInfo > rtMapByName = DescribeSObjectResultObj.getRecordTypeInfosByName();
        Id recordTypeId = rtMapByName != null && rtMapByName.containsKey(recTypeName) ? rtMapByName.get(recTypeName).getRecordTypeId() : null;
        return recordTypeId;
    }
    public static Account createTestAccountWithShipping(String nam){
        Id businessAccount =  Utility.GetRecordTypeIdBySObjectNameAndType('Account', 'Business Accounts');

        Account acc = new Account();
        acc.Name = nam+ String.valueOf(Math.random());
        acc.AcctMatchingRuleEnabled__c = false;
        acc.ShippingCity = 'Shipping City';
        acc.ShippingPostalCode = '33440';
        acc.ShippingCountryCode = 'US';
        acc.ShippingState = 'California';
        acc.ShippingStreet = '2298 PostingStreet';
        acc.BillingStreet = 'Green Street';
        acc.BillingCity = 'NY';
        acc.BillingCountry = 'United States';
        acc.BillingState = 'California';
        acc.BillingPostalCode = '95123';
        acc.Phone = '9124576511';
        acc.RecordTypeId = businessAccount;
        return acc;
    }

    public static Account createTestAccountWithShippingAndBilling(String nam){
        Id businessAccount =  Utility.GetRecordTypeIdBySObjectNameAndType('Account', 'Business Accounts');
        Account acc = new Account();
        acc.Name = nam+ String.valueOf(Math.random());
        acc.AcctMatchingRuleEnabled__c = false;
        acc.ShippingCity = 'Shipping City';
        acc.ShippingPostalCode = '33440';
        //acc.ShippingCountryCode = 'US';
        acc.ShippingState = 'California';
        acc.ShippingStreet = '2298 PostingStreet';
        acc.ShippingCountry = 'United States';
        acc.BillingCountry = 'United States';
        acc.CreditStatus__c = 'Ok';
        acc.Phone = '9124576543';
        acc.RecordTypeId = businessAccount;
        return acc;
    }

    public static Program__c createAccountProgram(String name){
        Program__c accProgram = new Program__c();
        accProgram.Name = name;
        return accProgram;
    }

    public static Apttus_Proposal__Proposal__c createApttusProposal(Opportunity opp){
        List<RecordType> rtypes = [Select Name, Id From RecordType where sObjectType='Apttus_Proposal__Proposal__c' and isActive=true];
        Map<String,String> accountRecordTypes = new Map<String,String>{};
        for(RecordType rt: rtypes)
           accountRecordTypes.put(rt.Name,rt.Id);

        Contact con = createTestContact(opp.AccountId, 'confirst1', 'conlast1', 'con1@email.com');
        Contact con2 = createTestContact(opp.AccountId, 'confirst2', 'conlast2', 'con2@email.com');
        List<Contact> cList = new List<Contact>();
        cList.add(con);
        cList.add(con2);
        insert cList;

        Apttus_Proposal__Proposal__c prop = new Apttus_Proposal__Proposal__c();
            prop.Apttus_Proposal__Proposal_Name__c = 'Proposal for ' + opp.Name;
            //prop.Currency__c = 'USD Price List';
            prop.Apttus_Proposal__Opportunity__c = opp.Id;
            prop.Selling_Country__c ='United States';
            prop.Language__c ='English';
            prop.RecordTypeId = accountRecordTypes.get('Proposal');
            prop.BillingAccount__c = opp.AccountId;
            prop.BillContact__c = con.Id;
            prop.PostingContact__c = con2.Id;
            return prop;
    }

    public static OpportunityCompetitor__c createOpportunityCompetitor(Opportunity o){
        OpportunityCompetitor__c competitor = new OpportunityCompetitor__c();
            competitor.Account_Country__c = 'United States';
            competitor.Competitor__c = 'LinkedIn';
            competitor.Opportunity__c = o.Id;
            competitor.Name = 'Competitor for ' + o.Name;
            return competitor;
    }

    public static Case createTestNewAccountRequestCase(String org, Id primaryRep) {

        Id rtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Account Request').getRecordTypeId();
        Case caseRec = new Case(RecordTypeId = rtId, Account_Name__c = 'Test Account', Organization__c = org, BillingStreet__c = '30thF PhilamLife Tower', BillingCity__c = 'Makati City',
                        BillingZipPostalCode__c = '1226', BillingStateProvince__c = 'Manila', BillingCountry__c = 'Philippines', FirstName__c = 'Test', LastName__c = 'Contact',
                        PrimarySalesRepID__c = primaryRep, SalesChannel__c = 'Agency', AccountPhone__c = '+631111111', Description='test desc');
        return caseRec;
    }

    public static CaseRoutingRule__c createCaseRoutingRecord() {
        //EmailTemplate et = [Select id, developername, IsActive From EmailTemplate Where IsActive = true Limit 1];
        CaseRoutingRule__c caseRouting = new CaseRoutingRule__c();
        caseRouting.InboundEmailAddress__c = 'test1@test.com';
        caseRouting.EmailBodyContains__c = 'Test Email';
        caseRouting.EmailSubjectContains__c = 'Test Body Email';
        //caseROuting.AutoResponseTemplate__c = et.DeveloperName;
        caseRouting.Routing_Status__c = 'Active';
        return caseRouting;
    }

    public static List<CaseRoutingRule__c> createProdImpRoutingRules(){
      // TKOM Added for S-445214
      List<CaseRoutingRule__c> lstProdImpRoutingRules = new List<CaseRoutingRule__c>();
      CaseRoutingRule__c ruleProdImpNAMedia = new CaseRoutingRule__c();
      ruleProdImpNAMedia.Name = 'test - ruleProdImpNAMedia';
      ruleProdImpNAMedia.Routing_Status__c = 'Active';
      ruleProdImpNAMedia.RecordTypeId = TestDataSetupUtility.getRecordTypeId('Internal', 'CaseRoutingRule__c');
      ruleProdImpNAMedia.Organization__c = 'North America';
      ruleProdImpNAMedia.CaseRecordType__c = 'Product Implementation';
      ruleProdImpNAMedia.Media_Product__c = true;
      //ruleProdImp.Assign_To_Primary_Service_Rep__c = true;
      //ruleProdImp.Assign_to_Verified_By__c = true;
      lstProdImpRoutingRules.add(ruleProdImpNAMedia);


      CaseRoutingRule__c ruleProdImpNAProdFam = new CaseRoutingRule__c();
      ruleProdImpNAProdFam.Name = 'test - ruleProdImpNAProdFam';
      ruleProdImpNAProdFam.Routing_Status__c = 'Active';
      ruleProdImpNAProdFam.RecordTypeId = TestDataSetupUtility.getRecordTypeId('Internal', 'CaseRoutingRule__c');
      ruleProdImpNAProdFam.Organization__c = 'North America';
      ruleProdImpNAProdFam.CaseRecordType__c = 'Product Implementation';
      ruleProdImpNAProdFam.Service_Tier__c = 'Core';
      ruleProdImpNAProdFam.Product_Family__c = 'Job Posting';
      //ruleProdImp.Assign_To_Primary_Service_Rep__c = true;
      //ruleProdImp.Assign_to_Verified_By__c = true;
      lstProdImpRoutingRules.add(ruleProdImpNAProdFam);


      CaseRoutingRule__c ruleProdImpNAProdName = new CaseRoutingRule__c();
      ruleProdImpNAProdName.Name = 'test - ruleProdImpNAProdName';
      ruleProdImpNAProdName.Routing_Status__c = 'Active';
      ruleProdImpNAProdName.RecordTypeId = TestDataSetupUtility.getRecordTypeId('Internal', 'CaseRoutingRule__c');
      ruleProdImpNAProdName.Organization__c = 'North America';
      ruleProdImpNAProdName.CaseRecordType__c = 'Product Implementation';
      ruleProdImpNAProdName.Service_Tier__c = 'Core';
      //ruleProdImpNAProdName.Product_Name__c = prod.Id; // need to populate in the test class with same product as on case.
      //ruleProdImp.Assign_To_Primary_Service_Rep__c = true;
      //ruleProdImp.Assign_to_Verified_By__c = true;
      lstProdImpRoutingRules.add(ruleProdImpNAProdName);


      CaseRoutingRule__c ruleProdImpNASvcTier = new CaseRoutingRule__c();
      ruleProdImpNASvcTier.Name = 'test - ruleProdImpNASvcTier';
      ruleProdImpNASvcTier.Routing_Status__c = 'Active';
      ruleProdImpNASvcTier.RecordTypeId = TestDataSetupUtility.getRecordTypeId('Internal', 'CaseRoutingRule__c');
      ruleProdImpNASvcTier.Organization__c = 'North America';
      ruleProdImpNASvcTier.CaseRecordType__c = 'Product Implementation';
      ruleProdImpNASvcTier.Service_Tier__c = 'Core';
      //ruleProdImp.Assign_To_Primary_Service_Rep__c = true;
      //ruleProdImp.Assign_to_Verified_By__c = true;
      lstProdImpRoutingRules.add(ruleProdImpNASvcTier);


      CaseRoutingRule__c ruleProdImpEUAgency = new CaseRoutingRule__c();
      ruleProdImpEUAgency.Name = 'test - ruleProdImpEUAgency';
      ruleProdImpEUAgency.Routing_Status__c = 'Active';
      ruleProdImpEUAgency.RecordTypeId = TestDataSetupUtility.getRecordTypeId('Internal', 'CaseRoutingRule__c');
      ruleProdImpEUAgency.Organization__c = 'Europe';
      ruleProdImpEUAgency.CaseRecordType__c = 'Product Implementation';
      //ruleProdImpEUAgency.Agency_Account__c = ''; // need ID of Agency Account here
      //ruleProdImp.Assign_To_Primary_Service_Rep__c = true;
      //ruleProdImp.Assign_to_Verified_By__c = true;
      lstProdImpRoutingRules.add(ruleProdImpEUAgency);


      CaseRoutingRule__c ruleProdImpEUProdFam = new CaseRoutingRule__c();
      ruleProdImpEUProdFam.Name = 'test - ruleProdImpEUProdFam';
      ruleProdImpEUProdFam.Routing_Status__c = 'Active';
      ruleProdImpEUProdFam.RecordTypeId = TestDataSetupUtility.getRecordTypeId('Internal', 'CaseRoutingRule__c');
      ruleProdImpEUProdFam.Organization__c = 'Europe';
      ruleProdImpEUProdFam.CaseRecordType__c = 'Product Implementation';
      ruleProdImpEUProdFam.Service_Tier__c = 'Core';
      ruleProdImpEUProdFam.Product_Family__c = 'Job Posting';
      ruleProdImpEUProdFam.Posting_Country__c = 'Germany';
      ruleProdImpEUProdFam.Proposal_Language__c = 'German';
      //ruleProdImp.Assign_To_Primary_Service_Rep__c = true;
      //ruleProdImp.Assign_to_Verified_By__c = true;
      lstProdImpRoutingRules.add(ruleProdImpEUProdFam);


      CaseRoutingRule__c ruleProdImpEUProdName = new CaseRoutingRule__c();
      ruleProdImpEUProdName.Name = 'test - ruleProdImpEUProdName';
      ruleProdImpEUProdName.Routing_Status__c = 'Active';
      ruleProdImpEUProdName.RecordTypeId = TestDataSetupUtility.getRecordTypeId('Internal', 'CaseRoutingRule__c');
      ruleProdImpEUProdName.Organization__c = 'Europe';
      ruleProdImpEUProdName.CaseRecordType__c = 'Product Implementation';
      ruleProdImpEUProdName.Service_Tier__c = 'Core';
      //ruleProdImpEUProdName.Product_Name__c = prod.Id; // need to populate in the test class with same product as on case.
      ruleProdImpEUProdFam.Posting_Country__c = 'Germany';
      ruleProdImpEUProdFam.Proposal_Language__c = 'German';
      //ruleProdImp.Assign_To_Primary_Service_Rep__c = true;
      //ruleProdImp.Assign_to_Verified_By__c = true;
      lstProdImpRoutingRules.add(ruleProdImpEUProdName);


      CaseRoutingRule__c ruleProdImpEUSvcTier = new CaseRoutingRule__c();
      ruleProdImpEUSvcTier.Name = 'test - ruleProdImpEUSvcTier';
      ruleProdImpEUSvcTier.Routing_Status__c = 'Active';
      ruleProdImpEUSvcTier.RecordTypeId = TestDataSetupUtility.getRecordTypeId('Internal', 'CaseRoutingRule__c');
      ruleProdImpEUSvcTier.Organization__c = 'Europe';
      ruleProdImpEUSvcTier.Posting_Country__c = 'Germany';
      ruleProdImpEUSvcTier.Proposal_Language__c = 'German';
      ruleProdImpEUSvcTier.CaseRecordType__c = 'Product Implementation';
      ruleProdImpEUSvcTier.Service_Tier__c = 'Core';
      //ruleProdImp.Assign_To_Primary_Service_Rep__c = true;
      //ruleProdImp.Assign_to_Verified_By__c = true;
      lstProdImpRoutingRules.add(ruleProdImpEUSvcTier);
      
      insert lstProdImpRoutingRules;
      return lstProdImpRoutingRules;

    }

    //creates a catch all rule and sets it in org settings
    public static void createCatchAllRule() {
        Group catchAllQueue = [select Id from Group where DeveloperName = 'Catch_All_Queue' Limit 1];
        CaseRoutingRule__c caseRouting = new CaseRoutingRule__c();
        caseRouting.Routing_Status__c = 'Debug';
        caseRouting.Name = 'Catch All Rule';
        caseRouting.OwnerID = catchAllQueue.Id;

        insert caseRouting;

        Org_Settings__c orgSetting = Org_Settings__c.getOrgDefaults();
        orgSetting.Catch_All_Rule__c = caseRouting.Id;
        orgSetting.SetupOwnerId = UserInfo.getOrganizationId(); //need this to make sure it gets assigned as the org default.
        upsert orgSetting;
    }

    public static Contact createTestContact(Id AccountId, String LastName, String FirstName, String Email) {
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        Contact conContact = new Contact();
        conContact.AccountId = AccountId;
        conContact.LastName = LastName + randomInt;
        conContact.FirstName = FirstName + randomInt;
        conContact.Email = randomInt + Email;
        conContact.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Contact', 'Contact');
        conContact.MatchingRuleEnabled__c = false;
        conContact.Phone='(555)-555-5555';
        return conContact;
    }

    public static Account createPersonAccount(){
        Id personAccountRecordType = Utility.GetRecordTypeIdBySObjectNameAndType('Account', 'Person Account');
        Account newPersonAccount = new Account();
        newPersonAccount.FirstName = 'Joe';
        newPersonAccount.LastName = 'Bloggs';
        newPersonAccount.PersonEmail = 'test@test.com';
        newPersonAccount.RecordTypeId = personAccountRecordType;
        return newPersonAccount;
    }

    public static Product2 createTestProduct(String ProductName) {
        /*
        Product2 prodProduct = new Product2(Name = ProductName, isActive = true);
        */
        return null;
    }

    public static User createTestUser(String FirstName, String LastName, Id ProfileId) {

        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User usr = new User(Email = uniqueName + '@test' + orgId + '.org',
            Username = uniqueName + '@test' + orgId + '.org',
            Alias = uniqueName.substring(18, 23),
            EmailEncodingKey='UTF-8',LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = ProfileId, isActive = true,
            TimeZoneSidKey='America/New_York', location__c = 'United States',
            FirstName=FirstName, LastName=LastName);
        return usr;
    }
    public static User createTestUser(String FistName, String LastName, Id ProfileId, String Org) {

        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User usr = new User(Email = uniqueName + '@test' + orgId + '.org',
            Username = uniqueName + '@test' + orgId + '.org', Organisation__c = Org,
            Alias = uniqueName.substring(18, 23),
            EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = ProfileId, isActive = true,
            TimeZoneSidKey='America/New_York', location__c = 'United States');
        return usr;
    }
    public static Lead createTestLead() {

        Lead ldLead = new Lead( LastName = 'Test User',
            Company = 'Test Company',
            Phone = '8005551212',
            Fax = '8005551212',
            Email = 'sumit.shingavi@cloudsherpas.com',
            Street = '123 Main Street',
            City = 'Pleasantville',
            State = 'New Jersey',
            PostalCode = '66666',
            Country = 'United States',
            Status = '0 - Open',
        //    Competitor__c = 'Other',
            Copy_Address_to_Billing_Address__c = true);

        return ldLead;
    }

    public static Opportunity createTestOpportunity(String Nam, Id AccId) {
        Opportunity opp = new Opportunity();
                opp.Name = Nam;
                opp.StageName = 'Stage 1 - Needs Assessment';
                opp.CloseDate = system.today() + 20;
                opp.AccountId = AccId;
                opp.Lost_Reason__c = 'Credit Risk';
                opp.TeamingType__c = 'Named';

        return opp;
    }

    public static OpportunityLineItem createFullOpportunityLineItem(Id opportunityId){
        Product2 p2 = createTestProduct2('Test Product');
        insert p2;
        PriceBookentry priceBookEnt = createTestPriceBookEntry(p2.Id);
        insert priceBookEnt;
        OpportunityLineItem testOppLineItem = createTestOpportunityLineItem(opportunityId, priceBookent.Id);
        return testOppLineItem;
    }

    public static OpportunityLineItem createTestOpportunityLineItem(Id opportunityId, Id priceBookEntryId){
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = opportunityId;
        oli.PricebookEntryId = priceBookEntryId;
        oli.Quantity = 1;
        oli.TotalPrice = 100;

        return oli;
    }

    public static Product2 createTestProduct2(String name){
        Product2 p2 = new Product2();
        p2.Name = name;
        p2.isActive = true;
        return p2;
    }
    public static PriceBookEntry createTestPriceBookEntry(ID product2Id){
        PriceBookEntry pbe = new PriceBookEntry();
        pbe.priceBook2Id = Test.getStandardPricebookId();
        pbe.product2Id = product2Id;
        pbe.isActive = true;
        pbe.UnitPrice = 400;
        pbe.CurrencyISOCode = 'USD';
        return pbe;
    }


    public static Sales_Quotas__c createTestSalesQuota(Id Userid) {
        Sales_Quotas__c sq = new Sales_Quotas__c();
        sq.Name__c = UserId;
        return sq;
    }

    public static Sales_Attainment__c createTestSalesAttainment(Id SalesQuotaId) {
        Sales_Attainment__c sa = new Sales_Attainment__c();
        sa.SalesQuota__c = SalesQuotaId;
        sa.StartDate__c = date.newInstance(2014, 10, 01);
        sa.EndDate__c = date.newInstance(2014, 10, 31);
        return sa;
    }

    public static Campaign createTestCampaign(String Nam) {
        /*
        Campaign camp = new Campaign(Name = Nam);
        */
        return null;
    }

    public static CampaignMember createTestCampMember(String campId, String conId, String leadId, String stat) {
        /*
        CampaignMember campMem = new CampaignMember(CampaignId = campId, ContactId = conId, Status = Stat, LeadId = leadId);
        */
        return null;
    }

    public static CountryLimit__c createCountryLimit (string countryName, string countryCode, decimal creditlimit, string salesChannel) {
        CountryLimit__c cl = new CountryLimit__c();
        cl.Name = countryName;
        cl.Country_Code__c = countryCode;
        cl.CreditLimit__c = creditlimit;
        cl.SalesChannel__c = salesChannel;
        return cl;
    }

    public static Order__c createOrder(Id AccountId) {
        Order__c ord = new Order__c();
        ord.Account__c = AccountId;
        return ord;
    }
    public static Order__c createOrder(Id AccountId, Id contactId) {
        Order__c ord = new Order__c();
        ord.Account__c = AccountId;
        ord.BillingContact__c = contactId;
        return ord;
    }

    public static Order_Line_Item__c createOrderLineItem(Id OrderId) {
        Order_Line_Item__c orderLine = new Order_Line_Item__c();
        orderLine.Order__c = OrderId;
        orderLine.PostingLocation__c = 'France';
        return orderLine;
    }

    public static Line_Item_Attribute__c createLineItemAttribute(Id OrderLineId, Id ProposalLineId) {
        Line_Item_Attribute__c lineItem = new Line_Item_Attribute__c();
        lineItem.Order_Line_Item__c = OrderLineId;
        lineItem.LineItemId__c = ProposalLineId;
        return lineItem;
    }

    public static Apttus_Proposal__Proposal__c createProposal(Id OpportunityId) {
        Opportunity oppty = [SELECT Id, AccountId FROM Opportunity WHERE Id =: OpportunityId];

        Id accId = oppty.AccountId;
        system.debug('!!AccountID ' +oppty.AccountId);
        //Create Payment Details
        Payment_Details__c payDet = createTestPaymentDetails('Asia Pacific', 'Pre-Paid', 'Immediate');
        payDet.Default_for_Partner_Proposal__c = false;
        payDet.Active__c = true;
        paydet.Non_Standard_Payment__c = false;
        paydet.PaymentMethod__c = 'Invoice';
        system.debug('***********************Insert Payment Detail***************');
        insert payDet;

        //Create Entity ID
        RegistrationNumber__c entID = New RegistrationNumber__c();

        //Update Account
        Account acc = [SELECT Id, Registration__c, PrimaryBillingContact__c FROM Account WHERE Id =: accId];

        //if this is null then we need to insert one, if it is not null then that means we have already
        //inserted this in the context of this test already - if we insert another we might mess up
        //another already inserted proposal
        if(acc.registration__c == null){
            //Create Entity ID
            entID.PaymentDetails__c = payDet.Id;
            entId.Organization__c = 'Asia Pacific';

            system.debug('***********************Insert Entity ID***************');
            insert entID;

            acc.Registration__c = entID.Id;
            system.debug('***********************Update Account***************');
            update acc;

            entId.PrimaryBillingAccount__c = accId;
            update entId;
        }

        Contact con;
        Contact con2;
        //if this is null then we need to insert one, if it is not null then that means we have already
        //inserted this in the context of this test already - if we insert another we might mess up
        //another already inserted proposal
        if(acc.PrimaryBillingContact__c == null){
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = dateString + randomInt;

            con = createTestContact(accId, 'confirst1', 'conlast1' + uniqueName, uniqueName + '@facebook.dude.com');
            system.debug('***********************Insert Contacts***************');
            /*insert con;

            acc.PrimaryBillingContact__c = con.Id;
            update acc;
            */
        } else {
            con = [Select Id from Contact where Id = :acc.PrimaryBillingContact__c LIMIT 1];
        }
        List<contact> con2Check = new List<contact>([Select Id from Contact where AccountId = :acc.Id AND PrimarySalesContact__c = true LIMIT 1]);

        if(con2Check.size() == 0){
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = dateString + randomInt;
            con2 = createTestContact(accId, 'confirst', 'conlast' + uniqueName, uniqueName + '@radcoder.com');
            con2.PrimarySalesContact__c = true;
            //insert con2;
        } else{
            con2 = con2Check[0];
        }

        if(acc.PrimaryBillingContact__c == null || con2Check.size() == 0  ){
            List<contact> con2Insert = new List<contact>();
            if(acc.PrimaryBillingContact__c == null)
                con2Insert.add(con);
            if(con2Check.size() == 0)
                con2Insert.add(con2);
            insert con2Insert;

            if(acc.PrimaryBillingContact__c == null){
                acc.PrimaryBillingContact__c = con.Id;
                update acc;
            }
        }


        Apttus_Proposal__Proposal__c prop = new Apttus_Proposal__Proposal__c();
            prop.Apttus_Proposal__Account__c = oppty.AccountId;
            prop.Apttus_Proposal__Opportunity__c = opportunityId;
            prop.Entity_ID__c = acc.Registration__c;
            prop.BillContact__c = con.Id;
            prop.PostingContact__c = con2.Id;
            prop.Selling_Country__c ='United States';
            prop.Language__c ='English';
        //  Prop.Apttus_Proposal__Primary__c = True ;
            prop.Payment1_Term__c =  'Immediate';
        prop.Payment1_Frequency__c = 'Pre-Paid';
        prop.Payment_Method1__c =  'Invoice';
        prop.BillContact__c =con2.Id;
        return prop;
    }

    public static Apttus_Proposal__Proposal__c createProposal(Id accId,Id OpportunityId, String accountOrganization) {
        //Create Payment Details
        Payment_Details__c payDet = createTestPaymentDetails(accountOrganization, 'Pre-Paid', 'Immediate');
        payDet.Default_for_Partner_Proposal__c = false;
        payDet.Active__c = true;
        paydet.Non_Standard_Payment__c = false;
        paydet.PaymentMethod__c = 'Invoice';
        system.debug('***********************Insert Payment Detail***************');
        insert payDet;
        //Create Entity ID
        RegistrationNumber__c entID = New RegistrationNumber__c();
            entID.PaymentDetails__c = payDet.Id;
            entId.Organization__c = accountOrganization;
            insert entID;

            system.debug('***********************Update Account***************');
            //update acc;



        Contact con;
        Contact con2;
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = dateString + randomInt;

            con = createTestContact(accId, 'confirst1', 'conlast1' + uniqueName, uniqueName + '@facebook.dude.com');
            con2 = createTestContact(accId, 'confirst', 'conlast' + uniqueName, uniqueName + '@radcoder.com');
            con2.PrimarySalesContact__c = true;
            system.debug('***********************Insert Contacts***************');
            //insert new List<Contact>{con,con2};
        //insert entID;

        Account acc = new Account(Id = accId);
            acc.Registration__c = entID.Id;
            //acc.PrimaryBillingContact__c = con.Id;
            update acc;
        entId.PrimaryBillingAccount__c = accId;
            update entId;

        Apttus_Proposal__Proposal__c prop = new Apttus_Proposal__Proposal__c();
            prop.Apttus_Proposal__Account__c = acc.Id;
            prop.Apttus_Proposal__Opportunity__c = opportunityId;
            prop.Entity_ID__c = acc.Registration__c;
            //prop.BillContact__c = con.Id;
            //prop.PostingContact__c = con2.Id;
            prop.Selling_Country__c ='United States';
            prop.Language__c ='English';
        //  Prop.Apttus_Proposal__Primary__c = True ;
            prop.Payment1_Term__c =  'Immediate';
        prop.Payment1_Frequency__c = 'Pre-Paid';
        prop.Payment_Method1__c =  'Invoice';
        //prop.BillContact__c =con2.Id;
        prop.AccountOrganization__c = accountOrganization;
        return prop;
    }

    public static Apttus_Proposal__Proposal__c createProposal(Id OpportunityId, String accountOrganization) {
        Opportunity oppty = [SELECT Id, AccountId FROM Opportunity WHERE Id =: OpportunityId];

        Id accId = oppty.AccountId;
        system.debug('!!AccountID ' +oppty.AccountId);
        //Create Payment Details
        Payment_Details__c payDet = createTestPaymentDetails(accountOrganization, 'Pre-Paid', 'Immediate');
        payDet.Default_for_Partner_Proposal__c = false;
        payDet.Active__c = true;
        paydet.Non_Standard_Payment__c = false;
        paydet.PaymentMethod__c = 'Invoice';
        system.debug('***********************Insert Payment Detail***************');
        insert payDet;

        //Create Entity ID
        RegistrationNumber__c entID = New RegistrationNumber__c();

        //Update Account
        Account acc = [SELECT Id, Registration__c, PrimaryBillingContact__c FROM Account WHERE Id =: accId];

        //if this is null then we need to insert one, if it is not null then that means we have already
        //inserted this in the context of this test already - if we insert another we might mess up
        //another already inserted proposal
        if(acc.registration__c == null){
            //Create Entity ID
            entID.PaymentDetails__c = payDet.Id;
            entId.Organization__c = accountOrganization;

            system.debug('***********************Insert Entity ID***************');
            insert entID;

            acc.Registration__c = entID.Id;
            system.debug('***********************Update Account***************');
            update acc;

            entId.PrimaryBillingAccount__c = accId;
            update entId;
        }

        Contact con;
        Contact con2;
        //if this is null then we need to insert one, if it is not null then that means we have already
        //inserted this in the context of this test already - if we insert another we might mess up
        //another already inserted proposal
        if(acc.PrimaryBillingContact__c == null){
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = dateString + randomInt;

            con = createTestContact(accId, 'confirst1', 'conlast1' + uniqueName, uniqueName + '@facebook.dude.com');
            system.debug('***********************Insert Contacts***************');
            insert con;

            acc.PrimaryBillingContact__c = con.Id;
            update acc;
        } else {
            con = [Select Id from Contact where Id = :acc.PrimaryBillingContact__c LIMIT 1];
        }
        List<contact> con2Check = new List<contact>([Select Id from Contact where AccountId = :acc.Id AND PrimarySalesContact__c = true LIMIT 1]);

        if(con2Check.size() == 0){
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = dateString + randomInt;
            con2 = createTestContact(accId, 'confirst', 'conlast' + uniqueName, uniqueName + '@radcoder.com');
            con2.PrimarySalesContact__c = true;
            insert con2;
        } else{
            con2 = con2Check[0];
        }


        Apttus_Proposal__Proposal__c prop = new Apttus_Proposal__Proposal__c();
            prop.Apttus_Proposal__Account__c = oppty.AccountId;
            prop.Apttus_Proposal__Opportunity__c = opportunityId;
            prop.Entity_ID__c = acc.Registration__c;
            prop.BillContact__c = con.Id;
            prop.PostingContact__c = con2.Id;
            prop.Selling_Country__c ='United States';
            prop.Language__c ='English';
        //  Prop.Apttus_Proposal__Primary__c = True ;
            prop.Payment1_Term__c =  'Immediate';
        prop.Payment1_Frequency__c = 'Pre-Paid';
        prop.Payment_Method1__c =  'Invoice';
        prop.BillContact__c =con2.Id;
        prop.AccountOrganization__c = accountOrganization;
        return prop;
    }

    public static Apttus_Proposal__Proposal_Line_Item__c createProposalLineItem(Id ProposalId) {
        Apttus_Proposal__Proposal_Line_Item__c proLineItem = new Apttus_Proposal__Proposal_Line_Item__c();
        proLineItem.Apttus_Proposal__Quantity__c = 1;
        proLineItem.Apttus_QPConfig__Quantity2__c = 1;
        proLineItem.Apttus_Proposal__Proposal__c = ProposalId;
        return proLineItem;
    }

    public static Order__c createOrderWithOpportunity(Id AccountId, Id OpportunityId, Id ProposalId, Id ContactId) {
        Order__c ord = new Order__c();
        ord.Account__c = AccountId;
        ord.BillingAccount__c = AccountId; //Jeff L added due to a new validation rule
        ord.Opportunity__c = OpportunityId;
        ord.BillingContact__c  = ContactId;
        //ord.QuoteProposal__c = ProposalId;
        return ord;
    }

    public static Order__c createOrderWithOpportunity(Id AccountId, Id OpportunityId, Id ProposalId) {
        Order__c ord = new Order__c();
        ord.Account__c = AccountId;
        ord.BillingAccount__c = AccountId; //Jeff L added due to a new validation rule
        ord.Opportunity__c = OpportunityId;
        ord.QuoteProposal__c = ProposalId;
        return ord;
    }

    public static Credit_Request__c createCreditRequest(ID orderId) {
        Credit_Request__c cr = new Credit_Request__c();
        cr.RequestDate__c = system.now().date();
        cr.Type__c = 'Inventory';
        cr.CreditReason__c = 'Technical Issue';
        cr.ApprovalStatus__c = 'Approved';
        cr.Order__c = orderId;
        cr.PrimarySalesRep__c = UserInfo.getUserId(); //added this due to some new logic in credit request trigger

        return cr;
    }
    public static CreditRequestLineItem__c createCreditRequestLineItem(ID creditReq) {
        CreditRequestLineItem__c cr = new CreditRequestLineItem__c();
        cr.Credit_Request__c = creditReq;
        return cr;
    }

    public static Invoices__c createInvoice(Id orderId, Id contactId) {
        Invoices__c inv = new Invoices__c();
        inv.Order__c = orderId;
        inv.InvoiceNumber__c = String.valueOf(math.rint(math.random()*100000));
        inv.Billingcontact__c = contactId;
        inv.AmountOutstanding__c = 1000;
        inv.AmountPaidtoDate__c = 250;
        inv.InvoiceDate__c = Date.today();
        inv.InvoiceAmount__c = 1250;
        return inv;
    }
    /* public static Credit_Request__c createCreditRequest(Id OrderId) {
        Credit_Request__c cr = new Credit_Request__c();
        cr.RequestDate__c = system.now().date();
        cr.Type__c = 'Inventory';
        cr.ApprovalStatus__c = 'Appro

        return cr;
    }*/
    public static Task createTask(Id AccId) {
        Task t = new Task();
        t.WhatId = AccId;
        t.Status = 'Open';
        t.Subject = 'eMail';
        t.Priority = '3 - Medium';
        t.ActivityDate = system.now().Date();
        return t;
    }
    /**
     * @author Andre Calimlim
     * @date 12.4.14
     * @description Utility class to build the Standard Report custom setting
     */
    public static Standard_Reports__c buildStdReportSetting(String name, String rptId){
        Standard_Reports__c setting = new Standard_Reports__c(
        Name = name,
        Report_Id__c = rptId
        );

        return setting;
    }
    /**
     * @author Andre Calimlim
     * @date 12.4.14
     * @description Utility class to build the Maximum Customer Number custom setting
     */
    public static MaximumCustomerNumber__c buildMaximumCustomerNumberSetting(){
        MaximumCustomerNumber__c setting = new MaximumCustomerNumber__c(
            MaxCustNum__c = 1
        );

        return setting;
    }
    /**
     * @author Andre Calimlim
     * @date 12.12.14
     * @description Utility class to build the WebService Endpoint custom setting
     */
    public static WebServiceEndpoint__c buildWebServiceEndpointSetting(){
        WebServiceEndpoint__c setting = new WebServiceEndpoint__c(
            Name='USPSAddressValidation',
            Endpoint__c='http://production.shippingapis.com/ShippingAPI.dll'
        );

        return setting;
    }
    /**
     * @author Andre Calimlim
     * @date 12.12.14
     * @description Utility class to build the Integration Config custom setting
     */
    public static IntegrationConfig__c buildIntegrationConfigSetting(){
        IntegrationConfig__c setting = new IntegrationConfig__c(
            Name='USPS Integration',
            EndpointName__c = 'USPSAddressValidation',
            Timeout__c = 60000,
            USPSUserID__c = '562CLOUD2615',
            IsPaypalTest__c = true
        );

        return setting;
    }
    /**
     * @author Andre Calimlim
     * @date 12.12.14
     * @description Utility class to build the Case Trigger custom setting
     */
    public static CaseTriggerSettings__c buildCaseTriggerSetting(){
        CaseTriggerSettings__c setting = new CaseTriggerSettings__c(CaseOwnerQueueName__c='ADOPS');

        return setting;
    }

    /**
     * @author Andre Calimlim
     * @date 12.12.14
     * @description Utility class to build the CountryCode custom setting
     */
    public static CountryCode__c buildCountryCodeSetting(String countryName, String code){
        CountryCode__c setting = new CountryCode__c(Name=countryName, Country_Code__c='PH');

        return setting;
    }
    /**
     * @author Andre Calimlim
     * @date 12.4.14
     * @description Utility class to create the Order Comment record
     */
    public static Order_Comment__c createTestOrderComment(Id orderId, String description, String strType){
        Order_Comment__c rec = new Order_Comment__c(
        Order__c = orderId,
        Description__c = description,
        Type__c = strType
        );

        return rec;
    }

     /**
     * @author Jonathan Freese (Appirio)
     * @date 08/22/15
     * @description Utility class to create the BatchUser record
     */
    public static BatchUser__c createBatchUser(Id userId){
        BatchUser__c rec = new BatchUser__c(
        Name = 'Archiver',
        ID__c = userId
        );

        return rec;
    }

    /**
     * @author Jonathan Freese (Appirio)
     * @date 04/26/16
     * @description Utility class to create a Zipcode Configuration record
     */
    public static Zipcode_Configuration__c buildZipcodeConfiguration(String country, String format, String tacREgex, String fullRegex){
        Zipcode_Configuration__c config = new Zipcode_Configuration__c(
            name = country,
            TAC_Regex__c = tacRegex,
            Full_Regex__c = fullRegex,
            AlphaNumeric_Format__c = format,
            Cleaning_Regex__c = '[-\\s]',
            Full_Error_Message__c = 'Full error message',
            TAC_Error_Message__c = 'TAC error message'
        );
        return config;
    }

    /**
     * @author Andre Calimlim
     * @date 12.4.14
     * @description Utility class to build the Standard Report custom setting
     */
    public static Personal_Settings__c buildPersonalSetting(){
        Personal_Settings__c setting = new Personal_Settings__c(
        Send_Emails__c = false,
        Trigger_Account__c = false,
        Trigger_Account_Contact_Association__c = false,
        Trigger_Account_Team_Members__c = false,
        Trigger_Activity__c = false,
        Trigger_Case__c = false,
        Trigger_Contact__c = false,
        Trigger_Opportunity__c = false,
        Trigger_Order__c = false,
        Trigger_Quote__c = false,
        Trigger_Strategic_Account_Plan__c = false,
        Validation_Account__c = false,
        Validation_Contact__c = false,
        Validation_Opportunity__c = false,
        Validation_Quote__c = false,
        Validation_Territory_Assignment_Code__c = false
        );

        return setting;
   }
   /*
   ** @author : robby angeles
   ** @date : 12/5/2014
   ** @description : utility to build account level value custom setting
   */
   public static Account_Level_Values__c buildAccountLevelSetting(){
        Account_Level_Values__c accValSett = new Account_Level_Values__c();
        accValSett.Purchasing_Parent__c          = 'Purchasing Parent';
        accValSett.Purchasing_Child__c           = 'Purchasing Child';
        accValSett.Purchasing_Stand_Alone__c     = 'Purchasing Stand-Alone';
        accValSett.Non_Purchasing_Parent__c      = 'Non-Purchasing Parent';
        accValSett.Non_Purchasing_Child__c       = 'Non-Purchasing Child';
        accValSett.Non_Purchasing_Stand_Alone__c = 'Non-Purchasing Stand-Alone';
        accValSett.Non_Purchasing_Account_Test_Value__c = 'Negated';
        accValSett.Purchasing_Account_Test_Value__c = 'Open';

        return AccValSett;
   }

   /*
   ** @author : Jeff Lescarbeau
   ** @date : 12/4/2015
   ** @description : utility to build taxNow custom setting, needed for Opp line items
   */
   public static void buildTaxNowCustomSetting() {
        AVA_SFCORE__TaxNowSetting__c TNS = New AVA_SFCORE__TaxNowSetting__c(name = 'TestSetting', AVA_SFCORE__Active_Setting__c = TRUE);
        insert TNS;
   }

   /*
   ** @author : divino brinas
   ** @date : 12/12/2014
   ** @description : utility to create juction object that has no order line item
   */
   public static ProductUserQuoteLine2OrderLine__c createJunctionObjectNoOrderItem(Id proposalId, Id proposalItemId){
        ProductUserQuoteLine2OrderLine__c quoteToOrder = new ProductUserQuoteLine2OrderLine__c();
        quoteToOrder.Quote_Proposal__c             = proposalId;
        quoteToOrder.Proposal_Line_Item__c         = proposalItemId;

        return quoteToOrder;
   }
   /*
   ** @author : divino brinas
   ** @date : 12/12/2014
   ** @description : utility to create juction object
   */
   public static ProductUserQuoteLine2OrderLine__c createJunctionObjectWithOrderItem(Id proposalId, Id proposalItemId, Id orderItemId){
        ProductUserQuoteLine2OrderLine__c quoteToOrder = new ProductUserQuoteLine2OrderLine__c();
        quoteToOrder.Quote_Proposal__c             = proposalId;
        quoteToOrder.Proposal_Line_Item__c         = proposalItemId;
        quoteToOrder.Order_Line_Item__c            = orderItemId;

        return quoteToOrder;
   }

   /*
   ** @author : Gaurav Gupta(Appirio)
   ** @date : 14/05/2014
   ** @description : utility to create CompetitiveLandscape__c object
   */
   public static CompetitiveLandscape__c createCompetitiveLandscape(Id accountId , Boolean isInsert){
    CompetitiveLandscape__c c = new CompetitiveLandscape__c();
    c.Account__c = accountId;
    if(isInsert)
        insert c;
    return c;

   }

   /*
   ** @author : Harshit Jain(Appirio)
   ** @date : 22/05/2014
   ** @description : utility to create Product2 object
   */
   public static Product2 createProduct(String ProductName, Boolean isInsert) {
        Product2 prodProduct = new Product2(Name = ProductName, isActive = true);
        prodProduct.Discount_Threshold__c = 1;
        if(isInsert)
                insert prodProduct;
        return prodProduct;
    }


    /*
   ** @author : Harshit Jain(Appirio)
   ** @date : 22/05/2014
   ** @description : utility to create assertLineItem object
   */
   public static Apttus_Config2__AssetLineItem__c createAssetLineItem(String assetName, Id accountId, Boolean isInsert) {
        Apttus_Config2__AssetLineItem__c aLineItem = new Apttus_Config2__AssetLineItem__c();
        aLineItem.Name = assetName;
        aLineItem.Apttus_Config2__AccountId__c  = accountId;

        if(isInsert)
                insert aLineItem;
        return aLineItem;
    }

   /*
   ** @author : Harshit Jain(Appirio)
   ** @date : 22/05/2014
   ** @description : utility to create proposal object
   */
    public static Apttus_Proposal__Proposal__c createProposal(String name, Id accountId, Id opportunityId, String status, Boolean isInsert){
        List<RecordType> rtypes = [Select Name, Id From RecordType where sObjectType='Apttus_Proposal__Proposal__c' and isActive=true];
        Map<String,String> accountRecordTypes = new Map<String,String>{};
        for(RecordType rt: rtypes)
           accountRecordTypes.put(rt.Name,rt.Id);

        Apttus_Proposal__Proposal__c prop = createProposal(opportunityId);
        prop.Apttus_Proposal__Proposal_Name__c = 'Proposal for ' + name;
        prop.QuoteStatus__c = status;
        prop.RecordTypeId = accountRecordTypes.get('Proposal');
        if(isInsert)
            insert prop;

        return prop;
        /*Opportunity oppty = [SELECT Id, AccountId FROM Opportunity WHERE Id =: OpportunityId];

        Id accId = oppty.AccountId;
        //Create Payment Details
        Payment_Details__c payDet = createTestPaymentDetails('123TestOrganization', 'frequency', 'paymentTerm');
        payDet.Default_for_Partner_Proposal__c = false;
        payDet.Active__c = true;
        paydet.Non_Standard_Payment__c = false;
        system.debug('***********************Insert Payment Detail***************');
        insert payDet;

        //Create Entity ID
        RegistrationNumber__c entID = New RegistrationNumber__c();

        //Update Account
        Account acc = [SELECT Id, Registration__c, PrimaryBillingContact__c FROM Account WHERE Id =: accId];

        //if this is null then we need to insert one, if it is not null then that means we have already
        //inserted this in the context of this test already - if we insert another we might mess up
        //another already inserted proposal
        if(acc.registration__c == null){
            //Create Entity ID
            entID.PaymentDetails__c = payDet.Id;
            entId.Organization__c = '123TestOrganization';

            system.debug('***********************Insert Entity ID***************');
            insert entID;

            acc.Registration__c = entID.Id;
            system.debug('***********************Update Account***************');
            update acc;

            entId.PrimaryBillingAccount__c = accId;
            update entId;
        }

        Contact con;
        Contact con2;
        //if this is null then we need to insert one, if it is not null then that means we have already
        //inserted this in the context of this test already - if we insert another we might mess up
        //another already inserted proposal
        if(acc.PrimaryBillingContact__c == null){
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt1 = Integer.valueOf(math.rint(math.random()*1000000));
            Integer randomInt2 = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName1 = dateString + randomInt1;
            String uniqueName2 = dateString + randomInt2;

            con = createTestContact(accId, 'confirst1', 'conlast1' + uniqueName1, uniqueName1 + '@facebook.dude.com');
            con2 = createTestContact(accId, 'confirst', 'conlast' + uniqueName2, uniqueName2 + '@radcoder.com');
            system.debug('***********************Insert Contacts***************');
            insert con;
            con2.PrimarySalesContact__c = true;
            insert con2;

            acc.PrimaryBillingContact__c = con.Id;
            update acc;
        } else {
            con = [Select Id from Contact where Id = :acc.PrimaryBillingContact__c LIMIT 1];
            con2 = [Select Id from Contact where AccountId = :acc.Id AND PrimarySalesContact__c = true LIMIT 1];
        }

        system.debug('Account!! ' + acc.PrimaryBillingContact__c);
        system.debug('Contact ' + con);
        system.debug('accountId ' + accId);
        system.debug('opportunity Account Id ' + oppty.AccountId);

        Apttus_Proposal__Proposal__c prop = new Apttus_Proposal__Proposal__c();
            prop.Apttus_Proposal__Proposal_Name__c = 'Proposal for ' + name;
            prop.Apttus_Proposal__Account__c = oppty.AccountId;
            prop.Apttus_Proposal__Opportunity__c = opportunityId;
            prop.Entity_ID__c = acc.Registration__c;
            prop.BillContact__c = con.Id;
            prop.PostingContact__c = con2.Id;
            prop.Selling_Country__c ='United States';
            prop.Language__c ='English';
            prop.QuoteStatus__c = status;
            prop.RecordTypeId = accountRecordTypes.get('Proposal');
            if(isInsert)
                insert prop;
            return prop;*/
    }


    /*
   ** @author : Harshit Jain(Appirio)
   ** @date : 22/05/2014
   ** @description : utility to create proiceList object
   */
    public static Apttus_Config2__PriceList__c createPriceList(String name,Boolean isInsert){

        Apttus_Config2__PriceList__c price = new Apttus_Config2__PriceList__c();
        price.Apttus_Config2__Active__c = true;
        price.Name = name;
        if(isInsert)
            insert price;
        return price;
    }


    public static Dependent_Attribute_workflow_object__c createDependentAttributeWorkflow(){

       Dependent_Attribute_workflow_object__c  obj = new Dependent_Attribute_workflow_object__c();
       obj.Attribute_type__c = 'Proposal';
       obj.attribute_values__c = 'ArchivalStatus__c';
       obj.Dependent_workflow_Ext_Id__c= '1234';
       return obj;

    }

    /*public static Apttus_QPConfig__ProposalProductAttributeValue__c createProposalProductAttributeValue(){
        Apttus_QPConfig__ProposalProductAttributeValue__c  config = new Apttus_QPConfig__ProposalProductAttributeValue__c ();

        return config;
    }*/
    public static Apttus_Config2__LineItem__c createLineItemApttus(Id aptusconfigId){
        Apttus_Config2__LineItem__c aptusLineItem = new Apttus_Config2__LineItem__c (
            Apttus_Config2__ConfigurationId__c = aptusConfigId,
            Apttus_Config2__ItemSequence__c = 1.00,
            Apttus_Config2__LineNumber__c = 1.00,
            Apttus_Config2__PrimaryLineNumber__c = 12);
        return aptusLineItem;
    }

    public static Apttus_Config2__ProductAttributeGroup__c createGroup(String name){
        Apttus_Config2__ProductAttributeGroup__c aptusGroup = new Apttus_Config2__ProductAttributeGroup__c(Name = name);
        return aptusGroup;
    }


    public static Apttus_Config2__ProductAttributeGroupMember__c createProductGroupMember(String name,Id aptusGroupId, Id productId){
        Apttus_Config2__ProductAttributeGroupMember__c aptusGrpMember = new Apttus_Config2__ProductAttributeGroupMember__c();
        aptusGrpMember.Name = name;
        aptusGrpMember.Apttus_Config2__AttributeGroupId__c = aptusGroupId;
        aptusGrpMember.Apttus_Config2__ProductId__c = productId;
        aptusGrpMember.Apttus_Config2__Sequence__c = 123;
        return aptusGrpMember;
    }

    public static void buildAgencyValidationSetting(){

    }


    public static RelatedPartner__c createTestRelatedPartner(Id accountId, Id agencyAccountId){
        RelatedPartner__c partner = new RelatedPartner__c();
        partner.Account__c = accountId;
        partner.Partner__c = agencyAccountId;
        partner.Role__c = 'Agency';
        partner.AgencyType__c = 'Third Party';
        return partner;
    }


    public static Payment_Details__c createTestPaymentDetails(String organization, String frequency, String paymentTerm){
        Payment_Details__c paymentDetails = new Payment_Details__c();
        paymentDetails.Name = 'Test';
        paymentDetails.Active__c = true;
        paymentDetails.PaymentFrequency__c =frequency;
        //paymentDetails.Default_for_Partner_Proposal__c = true;
        paymentDetails.Organization__c = organization;
        paymentDetails.PaymentTerm__c=paymentTerm;
        paymentDetails.Default_for_Partner_Proposal__c = true;
        return  paymentDetails;

    }

    public static User createUser(String profileName, Boolean isInsert){
        User testUser = new User();
        Profile p;
        List<Profile> listProfile = [SELECT Id from Profile where Name = :profileName];
        if(listProfile.size() > 0) {
            p = listProfile[0];
        } else {
            return null;
        }
        testUser = new User(alias = 'AdmUsr', email='standarduser' + Math.random()  + '@testorg.com',
                                    emailencodingkey='UTF-8',  lastname='Test', languagelocalekey='en_US',
                                    localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles',
                                    username='teststandarduser' + Math.random() + '@testorg.com', IsActive=true,
                                    CompanyName = 'test Company');
        if(isInsert){
            insert testUser;
        }
        return testUser;
    }

    public static RegistrationNumber__c createRegistrationNumber(Boolean isInsert){
        RegistrationNumber__c rn = new RegistrationNumber__c();
        rn.name = 'test';
        rn.AgencyCommission__c = 1 ;
        rn.AgencyCommissionCheck__c = true;
        rn.AgencyFlag__c = true;
        rn.AgencyFlagCheck__c = true;
        rn.CreditCheckReferenceNumberCheck__c = true;
        rn.CreditCheckReferenceNumber__c = 'true';
        rn.CreditlimitCheck__c = true;
        rn.CreditLimit__c = 12;
        rn.CreditStatusCheck__c = true;
        rn.CreditStatus__c  = 'Ok';
        rn.CrRefCommentCheck__c = true;
        rn.CrRefComment__c = 'tes';
        rn.DirectDebitCheck__c = true;
        rn.DirectDebit__c = true;
        rn.DirectDebitDiscountCheck__c = true;
        rn.DirectDebitDiscount__c = true;
        rn.POComments__c = 'sadsad';
        rn.POcommentsCheck__c = true;
        rn.PORequired__c = true;
        rn.PORequiredCheck__c = true;
        rn.PostingCityCheck__c = true;
        rn.PostingCity__c = 'sada';
        rn.PostingCountryCheck__c = true;
        rn.PostingCountry__c = 'Andorra';
        rn.PostingStateProvinceCheck__c = true;
        //rn.PostingStateProvince__c='Alabama';
        rn.PostingStreetCheck__c = true;
        rn.PostingStreet__c = 'sda';
        rn.PostingZipPostalCodeCheck__c = true;
        rn.PostingZipPostalCode__c = 'sad';
        rn.SelfBillingCheck__c = true;
        rn.SelfBilling__c = true;
        rn.CreditCheckReferenceNumberCheck__c = true;
        rn.CreditCheckReferenceNumber__c = 'ss';
        if(isInsert)
            insert rn;
        return rn;
    }

    //this method is migrated from EKBController_Test Class by Rohit B on 23/Sept/2015
    public static Brand__c createBrand(Boolean isInsert){
        Brand__c b = new Brand__c();
        b.Brand_Tag__c = 'monster';
        b.Default_Tab__c = 'Answers';
        b.Active__c = true;
        b.Is_Master__c = true;
        b.Home_Section_1__c = 'Administration';
        b.Home_Section_2__c = 'Fraud';
        b.Home_Section_3__c = 'Resume';
        b.Home_Section_4__c = 'Support';
        b.Language__c = 'English';
        b.Categories__c = 'Login/Password;Account Profile;Privacy and Security;Career Advice/Getting Hired;Disable/Cancel Account;Email Alerts;Job Apply;Job Search;Potential Fraud/Spam;Resume;Troubleshooting/Site Error';
        if(isInsert)
            insert b;
        return b;
    }
    //this method is migrated from EKBController_Test Class by Rohit B on 23/Sept/2015
    public static Contact_Us_Options__c createCUO(ID BrandId, Boolean isInsert){
        Contact_Us_Options__c cuo = new Contact_Us_Options__c();
        cuo.Brand__c = BrandId;
        cuo.Active__c = true;
        cuo.Main_Content_Title__c = 'Test for Test class';
        if(isInsert)
            insert cuo;
        return cuo;
    }
    //this method is migrated from EKBController_Test Class by Rohit B on 23/Sept/2015
    public static Answers__kav createAnswer(Boolean isInsert){
        Answers__kav answer = new Answers__kav();
        answer.urlname = 'urlname';
        answer.title = 'loren ipsum';
        answer.summary = 'loren ipsum';
        answer.Body__c = 'loren ipsum';
        if(isInsert)
            insert answer;
        return answer;
    }
    //this method is migrated from EKBController_Test Class by Rohit B on 23/Sept/2015
    public static Article_Relationship__c createAR(Id BrandId, Answers__kav answer, String DataCategory, Boolean isInsert){
        Article_Relationship__c ar = new Article_Relationship__c();
        ar.Brand__c = BrandId;
        ar.Article_Type__c = 'Answer';
        ar.Data_Category_Name__c = DataCategory;
        ar.Knowledge_Article_Id__c = answer.id;
        ar.Article_Id__c = answer.knowledgearticleid;
        ar.Times_found_useful__c = 0;
        ar.Times_not_found_useful__c = 0;
        if(isInsert)
            insert ar;
        return ar;
    }

    //Created Data Categories for Answer Article Type on EKBControllerTests
    public static Answers__DataCategorySelection assignDataCategoryToAnswer(ID articleId, String DataCategoryGroupName, String DataCategoryName){
    Answers__DataCategorySelection dataCategory = new Answers__DataCategorySelection();
    dataCategory.ParentId = articleId;
    dataCategory.DataCategoryGroupName = DataCategoryGroupName;
    dataCategory.DataCategoryName = DataCategoryName;
    return dataCategory;
    }

    //Created Email Message for Email2Csae functioanlity
    public static EmailMessage createEmailMessage(Id CaseId, Boolean Incoming, Boolean isInsert){
        EmailMessage em = new emailmessage();
        em.fromaddress = 'Test@test.com';
        em.toaddress = 'test1@test.com';
        em.subject = 'Test Email Testing1234';
        em.textbody = 'Test Body Email Testing1234';
        em.Headers = 'X-SFDC-Original-RCPT: gcsnatestsf@1vig92yaz0harrpvg8besbhklmvhj2qnwlsdjoi6phjy5nkl1k.q-blileao.cs21.case.sandbox.salesforce.com';
        em.Incoming = Incoming;
        em.parentid = CaseId;
        if(isInsert) insert em;
        return em;
    }
    //this method is migrated from gotopricingCtrlTest Class by Rohit B on 23/Sept/2015
    public static Product2 createProduct(String productName,
                                   String productCode,
                                   String productFamily,
                                   String productDesc,
                                   String configType,
                                   String unitOfMeasure,
                                   Boolean customizable,
                                   Date effectiveDate,
                                   Date expirationDate,
                                   Boolean isInsert) {
        // create a new product
        Product2 product = new Product2(Name=productName);
        product.ProductCode = productCode; // product code
        product.Family = productFamily; // product family
        product.Description = productDesc; // description
        product.Apttus_Config2__ConfigurationType__c = configType; // configuration type
        product.Apttus_Config2__Uom__c = unitOfMeasure; // unit of measure
        product.Apttus_Config2__Customizable__c = customizable; // customizable
        product.Apttus_Config2__EffectiveDate__c = effectiveDate; // effective date
        product.Apttus_Config2__ExpirationDate__c = expirationDate; // expiration date

        if(isInsert) // insert product
            insert product;
        return product;
    }
    //this method is migrated from gotopricingCtrlTest Class by Rohit B on 23/Sept/2015
    public static Apttus_Config2__PriceList__c createPriceList(String priceListName,
                                                         String priceListDesc,
                                                         Date effectiveDate,
                                                         Date expirationDate,
                                                         Boolean isInsert) {
        // create a new pricelist
        Apttus_Config2__PriceList__c priceListSO = new Apttus_Config2__PriceList__c(Name = priceListName, OwnerId = UserInfo.getUserId());
        priceListSO.Apttus_Config2__Description__c = priceListDesc; // description
        priceListSO.Apttus_Config2__EffectiveDate__c = effectiveDate; // effective date
        priceListSO.Apttus_Config2__ExpirationDate__c = expirationDate; // expiration date
        priceListSO.Apttus_Config2__Active__c = true; // active

        if(isInsert) // insert price list
            insert priceListSO;
        return priceListSO;
    }
    //this method is migrated from gotopricingCtrlTest Class by Rohit B on 23/Sept/2015
    public static Apttus_Config2__PriceListItem__c createPriceListItem(ID priceListId,
                                                                 ID productId,
                                                                 String chargeType,
                                                                 String priceType,
                                                                 String priceMethod,
                                                                 Decimal listPrice,
                                                                 Decimal minPrice,
                                                                 Decimal maxPrice,
                                                                 String minMaxPriceAppliesTo,
                                                                 Date effectiveDate,
                                                                 Date expirationDate,
                                                                 boolean active,
                                                                 Boolean isInsert) {
        // create a new pricelist item
        Apttus_Config2__PriceListItem__c itemSO = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceListId);
        itemSO.Apttus_Config2__ProductId__c = productId; // product id
        itemSO.Apttus_Config2__ChargeType__c = chargeType; // charge type
        itemSO.Apttus_Config2__PriceType__c = priceType; // price type
        itemSO.Apttus_Config2__PriceMethod__c = priceMethod; // price method
        itemSO.Apttus_Config2__ListPrice__c = listPrice; // list price
        itemSO.Apttus_Config2__MinPrice__c = minPrice; // min price
        itemSO.Apttus_Config2__MaxPrice__c = maxPrice; // max price
        itemSO.Apttus_Config2__MinMaxPriceAppliesTo__c = minMaxPriceAppliesTo; // max price
        itemSO.Apttus_Config2__EffectiveDate__c = effectiveDate; // effective date
        itemSO.Apttus_Config2__ExpirationDate__c = expirationDate; // expiration date
        itemSO.Apttus_Config2__Active__c =  active; // active

        if(isInsert) // insert price list item
            insert itemSO;
        return itemSO;
    }
    //this method is migrated from gotopricingCtrlTest Class by Rohit B on 23/Sept/2015
    public static Apttus_Proposal__Proposal__c createQuoteOrProposal(String qpName,
                                                               ID opptyId,
                                                               Date approvalDate,
                                                               Date expirationDate,
                                                               ID priceListId,
                                                               Date pricingDate,
                                                               String maintDuration,
                                                               boolean stubyearquote,
                                                               Boolean isInsert) {
        Opportunity opty = new Opportunity(ID=opptyId);
        Contact con = createTestContact(opty.AccountId, 'confirst1', 'conlast1', 'con1@email.com');
        Contact con2 = createTestContact(opty.AccountId, 'confirst2', 'conlast2', 'con2@email.com');
        List<Contact> conList = new List<Contact>();
        conList.add(con);
        conList.add(con2);
        insert conList;
        // create a new quote/proposal
        Apttus_Proposal__Proposal__c proposalSO = new Apttus_Proposal__Proposal__c(OwnerId = UserInfo.getUserId());
        proposalSO.Apttus_Proposal__Proposal_Name__c = qpName; // proposal name
        proposalSO.Apttus_Proposal__Opportunity__c = opptyId; // opportunity
        proposalSO.Apttus_Proposal__Proposal_Approval_Date__c = approvalDate; // approval date
        proposalSO.Apttus_Proposal__Proposal_Expiration_Date__c = date.today().addMonths(8); // expiration date
        proposalSO.Apttus_Proposal__ExpectedStartDate__c = Date.today(); // expected start date
        proposalSO.Apttus_Proposal__ExpectedEndDate__c = Date.today().addMonths(12); // expected end date
        proposalSO.Apttus_QPConfig__PriceListId__c = priceListId; // price list id
        proposalSO.Apttus_QPConfig__PricingDate__c = pricingDate; // pricing date
        // Monster specific Feilds
        proposalSO.Selling_Country__c='United States';
        proposalSO.Latest_End_Date__c=date.today().addYears(1);
        proposalSO.Apttus_QPConfig__ConfigurationFinalizedDate__c = null;

        proposalSO.BillContact__c = con.Id;
        proposalSO.PostingContact__c = con2.Id;
        //proposalSO.Entity_ID__c = entID.Id;
        proposalSO.BillingAccount__c = opty.AccountId;
        proposalSO.Pricing_Channel__c = 'Agency';
        proposalSO.BillingStreet__c = 'Green Street 11';
        proposalSO.BillingCity__c = 'NY';
        proposalSO.BillingZipPostalCode__c = '96123';
        proposalSO.BillingCountry__c = 'United States';

        if(isInsert) // insert Quote/Proposal
            insert proposalSO;
        return proposalSO;
    }
    //this method is migrated from gotopricingCtrlTest Class by Rohit B on 23/Sept/2015
    public static Apttus_Config2__ProductConfiguration__c createProductConfiguration(String configName,
                                                                               Integer versionNbr,
                                                                               ID bObjectId,
                                                                               String bObjectType,
                                                                               String groupType,
                                                                               ID priceListId,
                                                                               ID ancestorId,
                                                                               String status,
                                                                               Datetime finalizedDate,
                                                                               Datetime effectiveDate,
                                                                               Boolean isTransient,
                                                                               String configDesc,
                                                                               Boolean isInsert) {
        // create a new classification name
        Apttus_Config2__ProductConfiguration__c configSO = new Apttus_Config2__ProductConfiguration__c(Name = configName, OwnerId = UserInfo.getUserId());
        configSO.Apttus_Config2__VersionNumber__c = versionNbr;  // version number
        configSO.Apttus_Config2__SummaryGroupType__c = groupType;  // summary group type
        configSO.Apttus_Config2__BusinessObjectId__c = bObjectId;  // business object
        configSO.Apttus_Config2__BusinessObjectType__c = bObjectType;  // business object type
        configSO.Apttus_QPConfig__Proposald__c = bObjectId;  // proposal id
        configSO.Apttus_Config2__PriceListId__c = priceListId;  // price list id
        configSO.Apttus_Config2__AncestorId__c = ancestorId;  // ancestor id
        configSO.Apttus_Config2__Status__c = status;  // status
        configSO.Apttus_Config2__IsTransient__c = isTransient;  // is transient
        configSO.Apttus_Config2__FinalizedDate__c = finalizedDate;  // finalized date
        configSO.Apttus_Config2__EffectiveDate__c = effectiveDate;  // effective date
        configSO.Apttus_Config2__Description__c = configDesc;  // description

        if(isInsert) // insert product configuration
            insert configSO;
        return configSO;
    }
    //this method is migrated from gotopricingCtrlTest Class by Rohit B on 23/Sept/2015
    public static Apttus_Config2__AdHocGroup__c createAdHocGroup(String groupName,
                                                           ID configId,
                                                           String groupDesc,
                                                           Boolean isInsert) {
        // create a new ad hoc group
        Apttus_Config2__AdHocGroup__c groupSO = new Apttus_Config2__AdHocGroup__c(Name = groupName, Apttus_Config2__ConfigurationId__c = configId);
        groupSO.Apttus_Config2__Description__c = groupDesc;  // description

        if(isInsert) // insert ad hoc group
            insert groupSO;
        return groupSO;
    }
    //this method is migrated from gotopricingCtrlTest Class by Rohit B on 23/Sept/2015
    public static Apttus_Config2__LineItem__c createLineItem(ID configId,
                                                       ID groupId,
                                                       Integer lineNumber,
                                                       Boolean isPrimaryLine,
                                                       Integer itemSeq,
                                                       String lineType,
                                                       ID productId,
                                                       Boolean customizable,
                                                       ID productOptionId,
                                                       ID optionId,
                                                       ID classId,
                                                       String classHierarchy,
                                                       Decimal quantity,
                                                       Boolean isQtyModifiable,
                                                       String uom,
                                                       Integer term,
                                                       ID priceListId,
                                                       ID plItemId,
                                                       String priceType,
                                                       String priceMethod,
                                                       String chargeType,
                                                       String frequency,
                                                       Boolean allowManualAdj,
                                                       Boolean allocateGroupAdj,
                                                       Decimal listPrice,
                                                       Decimal basePrice,
                                                       String basePriceMethod,
                                                       Decimal baseExtPrice,
                                                       Decimal optionPrice,
                                                       Decimal extPrice,
                                                       integer primarylineNumber,
                                                       Boolean isInsert) {
        // create a new line item
        Apttus_Config2__LineItem__c lineItemSO = new Apttus_Config2__LineItem__c(
                                                    Apttus_Config2__ConfigurationId__c = configId);
        lineItemSO.Apttus_Config2__LineNumber__c = lineNumber;  // line number
        lineItemSO.Apttus_Config2__IsPrimaryLine__c = isPrimaryLine;  // primary line
        lineItemSO.Apttus_Config2__PrimaryLineNumber__c=primarylineNumber;  // item sequence
        lineItemSO.Apttus_Config2__ItemSequence__c = itemSeq;
        lineItemSO.Apttus_Config2__SummaryGroupId__c = groupId;  // summary group id
        lineItemSO.Apttus_Config2__LineType__c = lineType;  // line type
        lineItemSO.Apttus_Config2__ProductId__c = productId;  // product id
        lineItemSO.Apttus_Config2__Customizable__c = customizable;  // customizable
        lineItemSO.Apttus_Config2__ProductOptionId__c = productOptionId;  // product option id
        lineItemSO.Apttus_Config2__OptionId__c = optionId;  // option id
        lineItemSO.Apttus_Config2__ClassificationId__c = classId;  // classification id
        lineItemSO.Apttus_Config2__ClassificationHierarchy__c = classHierarchy;  // classification hierarchy
        lineItemSO.Apttus_Config2__Quantity__c = quantity;  // quantity
        lineItemSO.Apttus_Config2__IsQuantityModifiable__c = isQtyModifiable;  // quantity modifiable
        lineItemSO.Apttus_Config2__Uom__c = uom;  // uom
        lineItemSO.Apttus_Config2__Term__c = term;  // term
        lineItemSO.Apttus_Config2__PriceListId__c = priceListId;  // price list id
        lineItemSO.Apttus_Config2__PriceListItemId__c = plItemId;  // price list item id
        lineItemSO.Apttus_Config2__PriceType__c = priceType;  // price type
        lineItemSO.Apttus_Config2__PriceMethod__c = priceMethod;  // price method
        lineItemSO.Apttus_Config2__ChargeType__c = chargeType;  // charge type
        lineItemSO.Apttus_Config2__Frequency__c = frequency;  // frequency
        lineItemSO.Apttus_Config2__AllowManualAdjustment__c = allowManualAdj;  // allow manual adjustment
        lineItemSO.Apttus_Config2__AllocateGroupAdjustment__c = allocateGroupAdj;  // allocate group adjustment
        lineItemSO.Apttus_Config2__ListPrice__c = listPrice;  // list price
        lineItemSO.Apttus_Config2__BasePrice__c = basePrice;  // base price
        lineItemSO.Apttus_Config2__BasePriceMethod__c = basePriceMethod;  // base price mthod
        lineItemSO.Apttus_Config2__BaseExtendedPrice__c = baseExtPrice;  // base extended price
        lineItemSO.Apttus_Config2__OptionPrice__c = optionPrice;  // option price
        lineItemSO.Apttus_Config2__ExtendedPrice__c = extPrice;  // extended price
        lineItemSO.Apttus_Config2__Description__c = 'Test Description';  // description
        lineItemSO.Apttus_Config2__Term__c = 1;
        lineItemSO.Apttus_Config2__PricingStatus__c = 'Pending';
        lineItemSO.Apttus_Config2__SyncStatus__c = 'Pending';

        if(isInsert)  // Insert Line Item
            insert lineItemSO;
        return lineItemSO;
    }
    //this method is migrated from gotopricingCtrlTest Class by Rohit B on 23/Sept/2015
    public static Apttus_Config2__ProductOptionComponent__c CreateOptionComponents(Id OptionGroupId,
                                                                                    Id OptionId,
                                                                                    Id parentProductId,
                                                                                    string relationshipType,
                                                                                    integer sequence,
                                                                                    Boolean isInsert) {
        Apttus_Config2__ProductOptionComponent__c prodOptionComp = new Apttus_Config2__ProductOptionComponent__c(
                                                                    Apttus_Config2__RelationshipType__c=relationshipType,
                                                                    Apttus_Config2__ProductOptionGroupId__c=OptionGroupId,
                                                                    Apttus_Config2__ParentProductId__c=parentProductId,
                                                                    Apttus_Config2__ComponentProductId__c=OptionId,
                                                                    Apttus_Config2__InclusionCriteria__c=null,
                                                                    Apttus_Config2__Sequence__c=sequence,
                                                                    Apttus_Config2__Default__c=true,
                                                                    Apttus_Config2__MinQuantity__c=1,
                                                                    Apttus_Config2__MaxQuantity__c=1,
                                                                    Apttus_Config2__DefaultQuantity__c=1);
        if(isInsert)  // Insert Option Component
            insert prodOptionComp;
        return prodOptionComp;
    }
    //this method is migrated from gotopricingCtrlTest Class by Rohit B on 23/Sept/2015
    public static Apttus_Config2__ProductAttributeValue__c CreateProductAttribureValue(Id lineItemId, Boolean isInsert)
    {
        Apttus_Config2__ProductAttributeValue__c productAttributevalue = new Apttus_Config2__ProductAttributeValue__c();
        productAttributevalue.Apttus_Config2__LineItemId__c=lineItemId;

        if(isInsert)
            insert productAttributevalue;
        return productAttributevalue;
    }
    //this method is migrated from gotopricingCtrlTest Class by Rohit B on 23/Sept/2015
    public static List<Apttus_Config2__ProductAttribute__c> createProductAttributes(Id AttributeGroupId, Boolean isInsert)
    {
        list<Apttus_Config2__ProductAttribute__c> prodAttList=new list<Apttus_Config2__ProductAttribute__c>();
        prodAttList.add(new Apttus_Config2__ProductAttribute__c(Apttus_Config2__AttributeGroupId__c=AttributeGroupId,
                                                                                         Apttus_Config2__Field__c='Geography__c',
                                                                                         Apttus_Config2__Sequence__c=1
                                                                                         ));
        prodAttList.add(new Apttus_Config2__ProductAttribute__c(Apttus_Config2__AttributeGroupId__c=AttributeGroupId,
                                                                                         Apttus_Config2__Field__c='Country__c',
                                                                                         Apttus_Config2__Sequence__c=2
                                                                                         ));
        prodAttList.add(new Apttus_Config2__ProductAttribute__c(Apttus_Config2__AttributeGroupId__c=AttributeGroupId,
                                                                                         Apttus_Config2__Field__c='Contract_Duration__c',
                                                                                         Apttus_Config2__Sequence__c=3
                                                                                         ));
        prodAttList.add(new Apttus_Config2__ProductAttribute__c(Apttus_Config2__AttributeGroupId__c=AttributeGroupId,
                                                                                         Apttus_Config2__Field__c='Posting_Duration__c',
                                                                                         Apttus_Config2__Sequence__c=4
                                                                                         ));
        prodAttList.add(new Apttus_Config2__ProductAttribute__c(Apttus_Config2__AttributeGroupId__c=AttributeGroupId,
                                                                                         Apttus_Config2__Field__c='Posting_Locations__c',
                                                                                         Apttus_Config2__Sequence__c=5
                                                                                         ));
        prodAttList.add(new  Apttus_Config2__ProductAttribute__c(Apttus_Config2__AttributeGroupId__c=AttributeGroupId,
                                                                                         Apttus_Config2__Field__c='Product_Name__c',
                                                                                         Apttus_Config2__Sequence__c=6
                                                                                         ));
        prodAttList.add(new  Apttus_Config2__ProductAttribute__c(Apttus_Config2__AttributeGroupId__c=AttributeGroupId,
                                                                                         Apttus_Config2__Field__c='Program_Name__c',
                                                                                         Apttus_Config2__Sequence__c=7
                                                                                         ));
        prodAttList.add(new Apttus_Config2__ProductAttribute__c(Apttus_Config2__AttributeGroupId__c=AttributeGroupId,
                                                                                         Apttus_Config2__Field__c='Posting_Location__c',
                                                                                         Apttus_Config2__Sequence__c=8
                                                                                         ));
        prodAttList.add(new Apttus_Config2__ProductAttribute__c(Apttus_Config2__AttributeGroupId__c=AttributeGroupId,
                                                                                         Apttus_Config2__Field__c='Location__c',
                                                                                         Apttus_Config2__Sequence__c=9
                                                                                         ));
        prodAttList.add(new Apttus_Config2__ProductAttribute__c(Apttus_Config2__AttributeGroupId__c=AttributeGroupId,
                                                                                         Apttus_Config2__Field__c='License_Duration__c',
                                                                                         Apttus_Config2__Sequence__c=10
                                                                                         ));
        prodAttList.add(new Apttus_Config2__ProductAttribute__c(Apttus_Config2__AttributeGroupId__c=AttributeGroupId,
                                                                                         Apttus_Config2__Field__c='service_Duration__c',
                                                                                         Apttus_Config2__Sequence__c=11
                                                                                         ));
        prodAttList.add(new Apttus_Config2__ProductAttribute__c(Apttus_Config2__AttributeGroupId__c=AttributeGroupId,
                                                                                         Apttus_Config2__Field__c='Duration__c',
                                                                                         Apttus_Config2__Sequence__c=12
                                                                                         ));
        prodAttList.add(new Apttus_Config2__ProductAttribute__c(Apttus_Config2__AttributeGroupId__c=AttributeGroupId,
                                                                                         Apttus_Config2__Field__c='Fixed_Location__c',
                                                                                         Apttus_Config2__Sequence__c=13
                                                                                         ));
        prodAttList.add(new Apttus_Config2__ProductAttribute__c(Apttus_Config2__AttributeGroupId__c=AttributeGroupId,
                                                                                         Apttus_Config2__Field__c='Industries_Multi__c',
                                                                                         Apttus_Config2__Sequence__c=14
                                                                                         ));

        if(isInsert)
            insert prodAttList;
        return prodAttList;
    }
    //this method is migrated from gotopricingCtrlTest Class by Rohit B on 23/Sept/2015
    public static Apttus_Config2__ProductAttributeGroupMember__c createProdAttGroupMember(Id productId, Boolean isInsert)
    {
        Apttus_Config2__ProductAttributeGroup__c prodAttGrp = new Apttus_Config2__ProductAttributeGroup__c(
                                                                    Name='AttributeGroupName1',
                                                                    Apttus_Config2__BusinessObject__c='Apttus_Config2__ProductAttributeValue__c');
        insert prodAttGrp;

        List<Apttus_Config2__ProductAttribute__c> lstACP = createProductAttributes(prodAttGrp.id, true);

        Apttus_Config2__ProductAttributeGroupMember__c prodAttGrpMember = new Apttus_Config2__ProductAttributeGroupMember__c(
                                                                            Apttus_Config2__ProductId__c=productId,
                                                                            Apttus_Config2__Sequence__c=1,
                                                                            Apttus_Config2__FieldUpdateCriteriaIds__c=null,
                                                                            Apttus_Config2__AttributeGroupId__c=prodAttGrp.Id);
        if(isInsert)
            insert prodAttGrpMember;
        return prodAttGrpMember;
    }
    //this method is migrated from gotopricingCtrlTest Class by Rohit B on 23/Sept/2015
    public static Attribute_Value_Group_Member__c createAttributeValueGroupMember(Id AttributeValueGroupId,
                                                                                    Id AttributeValudId,
                                                                                    String ProductCode,
                                                                                    Boolean isInsert) {
        Attribute_Value_Group_Member__c avgm = new Attribute_Value_Group_Member__c( Attribute_Value_Group__c = AttributeValueGroupId,
                                                                                    Attribute_Value__c = AttributeValudId,
                                                                                    Product_Code__c = ProductCode);
        if(isInsert)
            insert avgm;
        return avgm;
    }
    //this method is migrated from gotopricingCtrlTest Class by Rohit B on 23/Sept/2015
    public static Attribute_Value__c createAttributeValue(String AttributeName,
                                                            String AttributeType,
                                                            String AttributeValues,
                                                            Integer Sequence,
                                                            Boolean isInsert) {
        Attribute_Value__c av = new Attribute_Value__c( Attributes_Name__c = AttributeName,
                                                            Attribute_Type__c = AttributeType,
                                                            Attribute_Values__c = AttributeValues,
                                                            Sequence__c = Sequence);
        if(isInsert)
            insert av;
        return av;
    }
    //this method is migrated from gotopricingCtrlTest Class by Rohit B on 23/Sept/2015
    public static List<Product_Attribute_Rule_Definitions__c> createPARDRelatedRecords(Id primaryProductId,
                                                                                        Id OptionGroupId,
                                                                                        Boolean isInsert) {
        List<Product_Attribute_Rule_Definitions__c> pardList = new List<Product_Attribute_Rule_Definitions__c>();
        Attribute_Value_Group__c ctrlGrp1=new Attribute_Value_Group__c();
        Attribute_Value_Group__c depGrp1=new Attribute_Value_Group__c();
        list<Attribute_Value_Group__c> avgList = new List<Attribute_Value_Group__c>{ctrlGrp1, depGrp1};
        insert avgList;

        Attribute_Value__c avc1 = createAttributeValue('Product_Name__c', 'Product', 'OptionProduct1', 1, true);
        createAttributeValueGroupMember(ctrlGrp1.id, avc1.id, 'BundleProduct1', true);

        Attribute_Value__c avd1 = createAttributeValue('Contract_Duration__c', 'Product', '11 Months', 2, true);
        createAttributeValueGroupMember(depGrp1.id, avd1.id, 'BundleProduct1', true);

        Product_Attribute_Rule_Definitions__c pard1 = new Product_Attribute_Rule_Definitions__c(
                                                            Action__c='Include',
                                                            Active__c=true,
                                                            sequence__c=1,
                                                            Controlling_Attribute_Value_Group__c=avgList[0].id,
                                                            Dependent_Attribute_Value_Group__c=avgList[1].id,
                                                            Hide__c=false,
                                                            Primary_Product__c=primaryProductId,
                                                            Product_Option_Group__c=OptionGroupId);
        pardList.add(pard1);
       /*******************************************************Pard1*************************************/

       /*******************************************************Pard2*************************************/
        Attribute_Value_Group__c ctrlGrp2=new Attribute_Value_Group__c();
        Attribute_Value_Group__c depGrp2 =new Attribute_Value_Group__c();
        list<Attribute_Value_Group__c> avgList1=new List<Attribute_Value_Group__c>{ctrlGrp2, depGrp2};
        insert avgList1;

        Attribute_Value__c avc2 = createAttributeValue('Selling_Country__c', 'Proposal', 'United States', 4, true);
        createAttributeValueGroupMember(ctrlGrp2.id, avc2.id, 'OptionProduct1', true);

        Attribute_Value__c avc3 = createAttributeValue('Apttus_QPConfig__PriceListId__r.Name', 'Proposal', 'USD Price List', 1, true);
        createAttributeValueGroupMember(ctrlGrp2.id, avc3.id, 'OptionProduct1', true);

        Attribute_Value__c avd2 = createAttributeValue('Posting_Location__c', 'Product', 'United Kingdom', 3, true);
        createAttributeValueGroupMember(depGrp2.id, avd2.id, 'OptionProduct1', true);

        Attribute_Value__c avd3 = createAttributeValue('Posting_Location__c', 'Product', 'United States', 3, true);
        createAttributeValueGroupMember(depGrp2.id, avd3.id, 'OptionProduct1', true);

        Product_Attribute_Rule_Definitions__c pard2 = new Product_Attribute_Rule_Definitions__c(
                                                            Action__c='Include',
                                                            Active__c=true,
                                                            sequence__c=2,
                                                            Controlling_Attribute_Value_Group__c=ctrlGrp2.id,
                                                            Dependent_Attribute_Value_Group__c=DepGrp2.id,
                                                            Hide__c=false,
                                                            Primary_Product__c=primaryProductId,
                                                            Product_Option_Group__c=OptionGroupId);
        pardList.add(pard2);
       /*******************************************************Pard2*************************************/
       /*******************************************************Pard3*************************************/
        Attribute_Value_Group__c ctrlGrp3=new Attribute_Value_Group__c();
        Attribute_Value_Group__c depGrp3=new Attribute_Value_Group__c();
        list<Attribute_Value_Group__c> avgList3=new List<Attribute_Value_Group__c>{ctrlGrp3, depGrp3};
        insert avgList3;

        Attribute_Value__c avc4 = createAttributeValue('Product_Name__c', 'Product', 'OptionProduct1', 1, true);
        createAttributeValueGroupMember(ctrlGrp3.id, avc4.id, 'StandAlone1', true);

        Attribute_Value__c avc5 = createAttributeValue('Geography__c', 'Product', 'National', 1, true);
        createAttributeValueGroupMember(ctrlGrp3.id, avc5.id, 'StandAlone1', true);

        Attribute_Value__c avc6 = createAttributeValue('Posting_Location__c', 'Product', 'United States', 3, true);
        createAttributeValueGroupMember(depGrp3.id, avc6.id, 'StandAlone1', true);

        Attribute_Value__c avd4 = createAttributeValue('Location__c', 'Proposal', 'Selling_Country__c', 2, true);
        createAttributeValueGroupMember(depGrp3.id, avd4.id, 'StandAlone1', true);

        Product_Attribute_Rule_Definitions__c pard3 = new Product_Attribute_Rule_Definitions__c(
                                                            Action__c='Include',
                                                            Active__c=true,
                                                            sequence__c=1,
                                                            Controlling_Attribute_Value_Group__c=ctrlGrp3.id,
                                                            Dependent_Attribute_Value_Group__c=DepGrp3.id,
                                                            Hide__c=false,
                                                            Primary_Product__c=primaryProductId,
                                                            Product_Option_Group__c=OptionGroupId);
        pardList.add(pard3);
       /*******************************************************Pard4*************************************/
       /*******************************************************Pard456*************************************/
        Product_Attribute_Rule_Definitions__c pard4 = new Product_Attribute_Rule_Definitions__c(
                                                            Action__c='Hide',
                                                            Active__c=true,
                                                            sequence__c=1,
                                                            Controlling_Attribute_Value_Group__c=ctrlGrp1.id,
                                                            Dependent_Attribute_Value_Group__c=DepGrp1.id,
                                                            Hide__c=false,
                                                            Primary_Product__c=primaryProductId,
                                                            Product_Option_Group__c=OptionGroupId);
        pardList.add(pard4);

        Product_Attribute_Rule_Definitions__c pard5 = new Product_Attribute_Rule_Definitions__c(
                                                            Action__c='Lock',
                                                            Active__c=true,
                                                            sequence__c=1,
                                                            Controlling_Attribute_Value_Group__c=ctrlGrp1.id,
                                                            Dependent_Attribute_Value_Group__c=DepGrp1.id,
                                                            Hide__c=false,
                                                            Primary_Product__c=primaryProductId,
                                                            Product_Option_Group__c=OptionGroupId);
        pardList.add(pard5);
        Product_Attribute_Rule_Definitions__c pard6 = new Product_Attribute_Rule_Definitions__c(
                                                            Action__c='Exclude',
                                                            Active__c=true,
                                                            sequence__c=1,
                                                            Controlling_Attribute_Value_Group__c=ctrlGrp1.id,
                                                            Dependent_Attribute_Value_Group__c=DepGrp1.id,
                                                            Hide__c=false,
                                                            Primary_Product__c=primaryProductId,
                                                            Product_Option_Group__c=OptionGroupId);
        pardList.add(pard6);
       /*******************************************************Pard567*************************************/
       /***************************************************************************************************/
        // for covering the parseAttributeValueMap method
        Attribute_Value_Group__c ctrlGrp5=new Attribute_Value_Group__c();
        Attribute_Value_Group__c depGrp5=new Attribute_Value_Group__c();
        list<Attribute_Value_Group__c> avgList5=new List<Attribute_Value_Group__c>{ctrlGrp5, depGrp5};
        insert avgList5;

        Attribute_Value__c avcx5 = createAttributeValue('Apttus_QPConfig__PriceListId__r.Name', 'Proposal', 'USD Price List', 5, true);
        createAttributeValueGroupMember(ctrlGrp5.id, avcx5.id, 'StandAlone1', true);

        Attribute_Value__c avcx5_1 = createAttributeValue('Contract_Duration__c', 'Product', '11 Months', 2, true);
        createAttributeValueGroupMember(ctrlGrp5.id, avcx5_1.id, 'StandAlone1', true);

        Attribute_Value__c avcx5_2 = createAttributeValue('Apttus_QPConfig__PriceListId__r.Name', 'Proposal', 'Apttus_QPConfig__PriceListId__r.Name', 5, true);
        createAttributeValueGroupMember(ctrlGrp5.id, avcx5_2.id, 'StandAlone1', true);

        Attribute_Value__c avcx5_3 = createAttributeValue('Posting_Location__c', 'Product', 'Country__c', 5, true);
        createAttributeValueGroupMember(ctrlGrp5.id, avcx5_3.id, 'StandAlone1', true);


        Attribute_Value__c avdx5 = createAttributeValue('Contract_Duration__c', 'Product', '11 Months', 2, true);
        createAttributeValueGroupMember(depGrp5.id, avdx5.id, 'StandAlone1', true);

        Product_Attribute_Rule_Definitions__c pard8 = new Product_Attribute_Rule_Definitions__c(
                                                            Action__c='Include',
                                                            Active__c=true,
                                                            sequence__c=1,
                                                            Controlling_Attribute_Value_Group__c=avgList5[0].id,
                                                            Dependent_Attribute_Value_Group__c=avgList5[1].id,
                                                            Hide__c=false,
                                                            Primary_Product__c=primaryProductId,
                                                            Product_Option_Group__c=OptionGroupId);
        pardList.add(pard8);
        if(isInsert)
            insert pardList;
        return pardList;
       /******************************************************************************************************/
    }
    //this method is migrated from gotopricingCtrlTest Class by Rohit B on 23/Sept/2015
    public static Apttus_Config2__ClassificationName__c getCategory(String categoryName,
                                                                    String categoryLabel,
                                                                    String categoryType) {
        Apttus_Config2__ClassificationName__c newCategory = new Apttus_Config2__ClassificationName__c();
        newCategory.Name = categoryName;
        newCategory.Apttus_Config2__HierarchyLabel__c = categoryLabel;
        newCategory.Apttus_Config2__Type__c = categoryType;
        newCategory.Apttus_Config2__Active__c = true;
        return newCategory;
    }
    //this method is migrated from gotopricingCtrlTest Class by Rohit B on 23/Sept/2015
    public static Apttus_Config2__ClassificationHierarchy__c getCategoryHierarchy(String catHierarchyName,
                                                                                    String catHierarchyLabel,
                                                                                    Apttus_Config2__ClassificationName__c categoryRec) {
        Apttus_Config2__ClassificationHierarchy__c newCategoryHierarchy = new Apttus_Config2__ClassificationHierarchy__c();
        newCategoryHierarchy.Name = catHierarchyName;
        newCategoryHierarchy.Apttus_Config2__Label__c = catHierarchyLabel;
        newCategoryHierarchy.Apttus_Config2__Left__c = 1;
        newCategoryHierarchy.Apttus_Config2__Right__c = 2;
        newCategoryHierarchy.Apttus_Config2__Level__c = 0;
        newCategoryHierarchy.Apttus_Config2__HierarchyId__c = categoryRec.Id;
        newCategoryHierarchy.Apttus_Config2__Modifiable__c = true;
        newCategoryHierarchy.Apttus_Config2__MinOptions__c = 1;
        newCategoryHierarchy.Apttus_Config2__MaxOptions__c = 1;
        newCategoryHierarchy.Apttus_Config2__IncludeInTotalsView__c = true;

        return newCategoryHierarchy;
    }
    //this method is migrated from gotopricingCtrlTest Class by Rohit B on 23/Sept/2015
    public static Apttus_Config2__ProductOptionGroup__c getProductOptionGroup(Apttus_Config2__ClassificationHierarchy__c categoryHierarchy,
                                                                                Product2 bundleProduct) {
        Apttus_Config2__ProductOptionGroup__c prodOptionGroup = new Apttus_Config2__ProductOptionGroup__c();
        prodOptionGroup.Apttus_Config2__Sequence__c = 0;
        prodOptionGroup.Apttus_Config2__ModifiableType__c = 'Variable';
        prodOptionGroup.Apttus_Config2__Left__c = 1;
        prodOptionGroup.Apttus_Config2__Right__c = 2;
        prodOptionGroup.Apttus_Config2__Level__c = 0;
        prodOptionGroup.Apttus_Config2__IsLeaf__c = true;
        prodOptionGroup.Apttus_Config2__RootOptionGroupId__c = categoryHierarchy.Id;
        prodOptionGroup.Apttus_Config2__RootSequence__c = 1;
        prodOptionGroup.Apttus_Config2__OptionGroupId__c = categoryHierarchy.Id;
        prodOptionGroup.Apttus_Config2__ProductId__c = bundleProduct.Id;
        prodOptionGroup.Apttus_Config2__MinOptions__c = 0;
        prodOptionGroup.Apttus_Config2__MaxOptions__c = 999;

        return prodOptionGroup;
    }
    //this method is migrated from gotopricingCtrlTest Class by Rohit B on 23/Sept/2015
    public static Apttus_Config2__ProductOptionComponent__c getProductOptionComponent(Product2 optionProduct,
                                                                                        Apttus_Config2__ProductOptionGroup__c prodOptionGroup,
                                                                                        Product2 bundleProduct) {
        Apttus_Config2__ProductOptionComponent__c prodOptionComponent = new Apttus_Config2__ProductOptionComponent__c();
        prodOptionComponent.Apttus_Config2__ComponentProductId__c = optionProduct.Id;
        prodOptionComponent.Apttus_Config2__RelationshipType__c = 'Option';
        prodOptionComponent.Apttus_Config2__Sequence__c = 1;
        prodOptionComponent.Apttus_Config2__ProductOptionGroupId__c = prodOptionGroup.Id;
        prodOptionComponent.Apttus_Config2__ParentProductId__c = bundleProduct.Id;
        prodOptionComponent.Apttus_Config2__Default__c=true;

        return prodOptionComponent;
    }

    public static TerritoryAssignment__c createTerritoryAssignment(Id pOwnerId){
        TerritoryAssignment__c ta = new TerritoryAssignment__c();
        ta.OwnerId = pOwnerId;

        return ta;
    }

    public static TerritoryAssignmentCode__c createTerritoryAssignmentCode(Id pTAId, String pAccountCountry, String pAccountGroup, String pAccount_Size,
                                                                            String pEmployee_Size_Code, String pNamedAccount, String pPostingZipCodeStart,
                                                                            String pPostingZipCodeEnd, String pSalesChannel, String pSegment){
        TerritoryAssignmentCode__c tac = new TerritoryAssignmentCode__c();
        tac.TerritoryAssignment__c = pTAId;
        tac.AccountCountry__c = pAccountCountry;
        tac.AccountGroup__c = pAccountGroup;
        tac.Account_Size__c = pAccount_Size;
        tac.Employee_Size_Code__c = pEmployee_Size_Code;
        tac.NamedAccount__c = pNamedAccount;
        tac.PostingZipCodeEnd__c = pPostingZipCodeEnd;
        tac.PostingZipCodeStart__c = pPostingZipCodeStart;
        tac.SalesChannel__c = pSalesChannel;
        tac.Segment__c = pSegment;

        return tac;
    }

    public static TerritoryAssignmentTeamMember__c createTerritoryAssignmentTeamMember(Id pTAId, Id pUserId){
        TerritoryAssignmentTeamMember__c tam = new TerritoryAssignmentTeamMember__c();
        tam.TerritoryAssignment__c = pTAId;
        tam.TeamMember__c = pUserId;
        tam.AccountAccessLevel__c = 'Read/Write';
        tam.TeamMemberRole__c = 'Sales Rep';
        tam.CaseAccessLevel__c = 'Read/Write';
        tam.OpportunityAccessLevel__c = 'Read/Write';

        return tam;
    }
    public static void createZipcodeConfiguration(){
        List<Zipcode_Configuration__c> configList = new List<Zipcode_Configuration__c>();
        configList.add( new Zipcode_Configuration__c(Name = 'Canada',AlphaNumeric_Format__c = 'AdAdAd',
        Cleaning_Regex__c = '[\\s]', Full_Regex__c = '^[A-Z]\\d[A-Z]\\s*\\d[A-Z]\\d$', TAC_Regex__c = '^[A-Z]\\d[A-Z](?:\\s*\\d[A-Z]\\d)?$',
        Full_Error_Message__c = 'Sorry, zipcodes must be of the form A1A 1A1 where A is a letter from A-Z and 1 is a number from 0-9'
        , TAC_Error_Message__c = 'Sorry, zipcodes must be of the form A1A 1A1 (or just A1A) where A is a letter from A-Z and 1 is a number from 0-9'
        ));
        configList.add( new Zipcode_Configuration__c(Name = 'United States',AlphaNumeric_Format__c = 'ddddddddd',
        Cleaning_Regex__c = '[\\s]', Full_Regex__c = '^\\d{5}(?:[-\\s]*\\d{4})?$', TAC_Regex__c = '^\\d{5}(?:[-\\s]*\\d{4})?$',
        Full_Error_Message__c = 'Sorry, zipcodes must be of the form XXXXX or XXXXX-XXXX where X is a number from 0-9'
        , TAC_Error_Message__c = 'Sorry, zipcodes must be of the form XXXXX or XXXXX-XXXX where X is a number from 0-9'
        ));
        insert configList;
   }

   public static Sales_Channel_Cross_Reference__c salesChannelCrossReference(){
    Sales_Channel_Cross_Reference__c sccr = salesChannelCrossReference(UserInfo.getUserId());

    return sccr;
   }

   public static Sales_Channel_Cross_Reference__c salesChannelCrossReference(Id userId){
    Sales_Channel_Cross_Reference__c sccr = new Sales_Channel_Cross_Reference__c();
    User u = [Select Id,Combined_Region__c,Position_Organization__c,PositionSalesChannel__c
                                              from User Where Id = :userId Limit 1];
    sccr.Combined_Region__c = u.Combined_Region__c;
    sccr.Position_Organization__c = u.Position_Organization__c;
    sccr.Position_Sales_Channel__c = u.PositionSalesChannel__c;
    sccr.Selling_Country__c = 'United States';

    system.debug('sccr ' + sccr);
    return sccr;
   }
}