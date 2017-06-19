@isTest
public with sharing class CaseTriggerHelperTest {
    static Account testAccount,testAccount2 ;
    static Opportunity opp,opp1;
    static Apttus_Proposal__Proposal__c pro;
    static Order__c ord;
    static Contact testContact1;
    static Contact testContact2;
    static CaseTriggerSettings__c triggerSettings;
    static Group testGroup;
    static Order_Line_Item__c oli;
    static List<CaseRoutingRule__c> lstCaseRoutingRule = new List<CaseRoutingRule__c>();
    static User testAdminUser;
    //static EmailTemplate eTemplate = new EmailTemplate(Name = 'Test',DeveloperName = 'Test_template',isActive = true);
    @future
    static void createTEmplate(){
        EmailTemplate eTemplate = new EmailTemplate(Name = 'Test',DeveloperName = 'Test_template',isActive = true);
        insert eTemplate;
    }


   static void createTestData(){
        IntegrationConfig__c  integConfigSettings = new IntegrationConfig__c(Name ='USPS Integration',
                                                                            Timeout__c=60000,
                                                                            IsPaypalTest__c=true,
                                                                            EndpointName__c='USPSAddressValidation',
                                                                            Username__c='562CLOUD2615');
        insert integConfigSettings;

        testGroup = new Group(Name='test group', Type='Queue');
        insert testGroup;
        QueueSobject mappingObject = new QueueSobject(QueueId = testGroup.Id, SobjectType = 'Case');
        System.runAs(new User(Id = UserInfo.getUserId()))
        {insert mappingObject;}

        String groupId =   testGroup.Id;
        User_Queue_IDs__c userQueueIDs = new User_Queue_IDs__c(ADOPS_Queue__c = groupId.substring(0, 15), Queue_Credit_Limit_Support__c = groupId.substring(0, 15));
        insert userQueueIDs;

        WebServiceEndpoint__c wsEndpoint = new WebServiceEndpoint__c(Name='USPSAddressValidation', Endpoint__c='http://production.shippingapis.com/ShippingAPI.dll');
        insert wsEndpoint;

        triggerSettings = new CaseTriggerSettings__c(CaseOwnerQueueName__c='ADOPS');
        //insert triggerSettings;

        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        testAdminUser = TestDataSetupUtility.createTestUser('TestFistName', 'TestLastName', adminProfile.Id);
        insert testAdminUser;


        testAccount = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TEST PB Account');//, 'North America', UserInfo.getUserId());
        testAccount.Phone = '+18008008000';
        //testAccount.BillingCountry = 'Philippines';
        testAccount.BillingCountry = 'United States';
        testAccount.ShippingCountry = 'United States';
        testAccount.ShippingState = null;
        testAccount.PrimaryServiceRep__c = testAdminUser.id;
        //testAccount.Organization__c = 'Europe';
        testAccount.Organization__c = 'North America';
        testAccount.ServiceTier__c = 'Core';
        testAccount2 = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TEST PB Account');//, 'North America', UserInfo.getUserId());
        testAccount2.Phone = '+18008008000';
        //testAccount2.BillingCountry = 'Philippines';
        testAccount2.BillingCountry = 'Germany';
        //testAccount.ShippingCountry = 'Germany';
        testAccount2.PrimaryServiceRep__c = testAdminUser.id;
        testAccount2.Organization__c = 'Europe';
        testAccount2.ServiceTier__c = 'Core';
        insert new List<Account>{testAccount,testAccount2};
        testContact1 = TestDataSetupUtility.createTestContact(testAccount.Id, 'PrimaryBillingTestLastnameOne', 'PrimaryBillingTestFirstnameOne', 'email1@testContact.com');
        testContact1.PrimaryBillingContact__c = true;
        insert testContact1;
      	/*dps*/
		testContact2 = TestDataSetupUtility.createTestContact(testAccount2.Id, 'PrimaryBillingTestLastnameOne', 'PrimaryBillingTestFirstnameOne', 'email1@testContact.com');
        testContact2.PrimaryBillingContact__c = true;
        insert testContact2;

        opp = TestDataSetupUtility.createTestOpportunity('testopp', testAccount.Id);
        opp1 = TestDataSetupUtility.createTestOpportunity('testopp', testAccount.Id);
        insert new List<Opportunity>{opp,opp1};

        pro = TestDataSetupUtility.createProposal(opp.Id);
        pro.RecordTypeId  = Utility.GetRecordTypeIdBySObjectNameAndType('Apttus_Proposal__Proposal__c', 'GCS Proposal');
        pro.Selling_Country__c  = 'Germany';
        Apttus_Proposal__Proposal__c pro1 = TestDataSetupUtility.createProposal(opp1.Id);
        pro1.RecordTypeId  = Utility.GetRecordTypeIdBySObjectNameAndType('Apttus_Proposal__Proposal__c', 'GCS Proposal');
        pro1.Selling_Country__c  = 'Germany';
        insert new List<Apttus_Proposal__Proposal__c>{pro,pro1};
        Group grp = new Group(Name = 'ADOPS',type = 'Queue');

        CaseRoutingRule__c rule1 = new CaseRoutingRule__c();
        rule1.Name = 'test 1';
        rule1.Routing_Status__c = 'Active';
        rule1.QuoteSellingCountry__c = 'Germany';
        rule1.CaseRecordType__c = 'OM Processing Request';
        rule1.SFDC_Routing_Address__c = 'gcsnatestsf';
        lstCaseRoutingRule.add(rule1);
        CaseRoutingRule__c rule2 = new CaseRoutingRule__c();
        rule2.Name = 'test 2';
        rule2.Routing_Status__c = 'Active';
        rule2.QuoteSellingCountry__c = '';
        rule2.CaseRecordType__c = 'OM Processing Request';
        rule2.SFDC_Routing_Address__c = 'gcsnatestsf';
        lstCaseRoutingRule.add(rule2);

        CaseRoutingRule__c rule3 = new CaseRoutingRule__c();
        rule3.Name = 'test 3';
        rule3.Routing_Status__c = 'Active';
        rule3.QuoteSellingCountry__c = 'Germany';
        rule3.CaseRecordType__c = 'Request re Credit Limit';
        lstCaseRoutingRule.add(rule3);
        CaseRoutingRule__c rule4 = new CaseRoutingRule__c();
        rule4.Name = 'test 4';
        rule4.Routing_Status__c = 'Active';
        rule4.QuoteSellingCountry__c = '';
        rule4.CaseRecordType__c = 'Request re Credit Limit';
        lstCaseRoutingRule.add(rule4);

        CaseRoutingRule__c rule5 = new CaseRoutingRule__c();
        rule5.Name = 'test 5';
        rule5.Routing_Status__c = 'Active';
        rule5.QuoteSellingCountry__c = 'Germany';
        rule5.CaseRecordType__c = 'GCS';
        lstCaseRoutingRule.add(rule5);
        CaseRoutingRule__c rule6 = new CaseRoutingRule__c();
        rule6.Name = 'test 6';
        rule6.Routing_Status__c = 'Active';
        rule6.QuoteSellingCountry__c = '';
        rule6.CaseRecordType__c = 'GCS';

        lstCaseRoutingRule.add(rule6);

        CaseRoutingRule__c rule7 = new CaseRoutingRule__c();
        rule7.Name = 'test 7';
        rule7.Routing_Status__c = 'Active';
        rule7.QuoteSellingCountry__c = 'Germany';
        rule7.CaseRecordType__c = 'Credit Request';
        rule7.Assign_to_Verified_By__c = true;
        rule7.Routing_Status__c = 'Debug';
        lstCaseRoutingRule.add(rule7);

        CaseRoutingRule__c rule8 = new CaseRoutingRule__c();
        rule8.Name = 'Catch All Rule';
        rule8.Routing_Status__c = 'Active';
        rule8.QuoteSellingCountry__c = '';
        rule8.CaseRecordType__c = '';
        rule8.Assign_to_Verified_By__c = true;
        //rule8.ForwardIncomingEmailTo__c = 'test@gmail.com';
        lstCaseRoutingRule.add(rule8);


        Product2 prod = TestDataSetupUtility.createProduct('Monster Standard Job Ad', true);

        // TKOM Added for S-464557 and S-445214
        CaseRoutingRule__c ruleProdImpNAMedia = new CaseRoutingRule__c();
        ruleProdImpNAMedia.Name = 'test - ruleProdImpNAMedia';
        ruleProdImpNAMedia.Routing_Status__c = 'Active';
        ruleProdImpNAMedia.RecordTypeId = TestDataSetupUtility.getRecordTypeId('Internal', 'CaseRoutingRule__c');
        ruleProdImpNAMedia.Organization__c = 'North America';
        ruleProdImpNAMedia.CaseRecordType__c = 'Product Implementation';
        ruleProdImpNAMedia.Media_Product__c = true;
        //ruleProdImp.Assign_To_Primary_Service_Rep__c = true;
        //ruleProdImp.Assign_to_Verified_By__c = true;
        lstCaseRoutingRule.add(ruleProdImpNAMedia);

        // TKOM Added for S-464557 and S-445214
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
        lstCaseRoutingRule.add(ruleProdImpNAProdFam);

        // TKOM Added for S-464557 and S-445214
        CaseRoutingRule__c ruleProdImpNAProdName = new CaseRoutingRule__c();
        ruleProdImpNAProdName.Name = 'test - ruleProdImpNAProdName';
        ruleProdImpNAProdName.Routing_Status__c = 'Active';
        ruleProdImpNAProdName.RecordTypeId = TestDataSetupUtility.getRecordTypeId('Internal', 'CaseRoutingRule__c');
        ruleProdImpNAProdName.Organization__c = 'North America';
        ruleProdImpNAProdName.CaseRecordType__c = 'Product Implementation';
        ruleProdImpNAProdName.Service_Tier__c = 'Core';
        ruleProdImpNAProdName.Product_Name__c = prod.Id;
        //ruleProdImp.Assign_To_Primary_Service_Rep__c = true;
        //ruleProdImp.Assign_to_Verified_By__c = true;
        lstCaseRoutingRule.add(ruleProdImpNAProdName);

        // TKOM Added for S-464557 and S-445214
        CaseRoutingRule__c ruleProdImpNASvcTier = new CaseRoutingRule__c();
        ruleProdImpNASvcTier.Name = 'test - ruleProdImpNASvcTier';
        ruleProdImpNASvcTier.Routing_Status__c = 'Active';
        ruleProdImpNASvcTier.RecordTypeId = TestDataSetupUtility.getRecordTypeId('Internal', 'CaseRoutingRule__c');
        ruleProdImpNASvcTier.Organization__c = 'North America';
        ruleProdImpNASvcTier.CaseRecordType__c = 'Product Implementation';
        ruleProdImpNASvcTier.Service_Tier__c = 'Core';
        //ruleProdImp.Assign_To_Primary_Service_Rep__c = true;
        //ruleProdImp.Assign_to_Verified_By__c = true;
        lstCaseRoutingRule.add(ruleProdImpNASvcTier);

        // TKOM Added for S-464557 and S-445214
        CaseRoutingRule__c ruleProdImpEUAgency = new CaseRoutingRule__c();
        ruleProdImpEUAgency.Name = 'test - ruleProdImpEUAgency';
        ruleProdImpEUAgency.Routing_Status__c = 'Active';
        ruleProdImpEUAgency.RecordTypeId = TestDataSetupUtility.getRecordTypeId('Internal', 'CaseRoutingRule__c');
        ruleProdImpEUAgency.Organization__c = 'Europe';
        ruleProdImpEUAgency.CaseRecordType__c = 'Product Implementation';
        //ruleProdImpEUAgency.Agency_Account__c = ''; // need ID of Agency Account here
        //ruleProdImp.Assign_To_Primary_Service_Rep__c = true;
        //ruleProdImp.Assign_to_Verified_By__c = true;
        lstCaseRoutingRule.add(ruleProdImpEUAgency);

        // TKOM Added for S-464557 and S-445214
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
        lstCaseRoutingRule.add(ruleProdImpEUProdFam);

        // TKOM Added for S-464557 and S-445214
        CaseRoutingRule__c ruleProdImpEUProdName = new CaseRoutingRule__c();
        ruleProdImpEUProdName.Name = 'test - ruleProdImpEUProdName';
        ruleProdImpEUProdName.Routing_Status__c = 'Active';
        ruleProdImpEUProdName.RecordTypeId = TestDataSetupUtility.getRecordTypeId('Internal', 'CaseRoutingRule__c');
        ruleProdImpEUProdName.Organization__c = 'Europe';
        ruleProdImpEUProdName.CaseRecordType__c = 'Product Implementation';
        ruleProdImpEUProdName.Service_Tier__c = 'Core';
        ruleProdImpEUProdName.Product_Name__c = prod.Id;
        ruleProdImpEUProdFam.Posting_Country__c = 'Germany';
        ruleProdImpEUProdFam.Proposal_Language__c = 'German';
        //ruleProdImp.Assign_To_Primary_Service_Rep__c = true;
        //ruleProdImp.Assign_to_Verified_By__c = true;
        lstCaseRoutingRule.add(ruleProdImpEUProdName);

        // TKOM Added for S-464557 and S-445214
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
        lstCaseRoutingRule.add(ruleProdImpEUSvcTier);

        TestDataSetupUtility.createCatchAllRule();


        insert lstCaseRoutingRule;

        // TKOM: S-445214: move this line above Prod Imp caseRoutingRules, as some of them require this product to be set on the rule.
        // Product2 prod = TestDataSetupUtility.createProduct('Prod1', true);

        ord = TestDataSetupUtility.createOrderWithOpportunity(testAccount.Id, opp.Id, null, testContact1.id);
        ord.SentToVerificationBy2__c = testAdminUser.Id  ;
        // ord.OrderStatus__c = 'Sent To Verification';  // commented out this line - order should be open, will send to verification in the prodimp test method.
        ord.OrderStatus__c = 'Open';
        ord.BillingAccount__c = testAccount.id;
        ord.ShippingAccount__c  = testAccount.id;
       // ord.BillingContact__c = testContact1.id;
        ord.Posting_Contact__c = testContact1.id;
        insert ord;

        oli = TestDataSetupUtility.createOrderLineItem(ord.Id);
        oli.product__c = prod.Id;
        insert oli;

       /* Case mainCase = new Case(
            AccountId = testAccount.Id,
            ContactId = testContact1.Id,
            Status = 'New',
            Category__c = 'Browser Issue',
            Issue__c = 'Other',
            SubIssue__c = 'Other',
            Subject = 'TEST Subject Parent',
            CustomerProblemDetail__c = 'TEST Details Parent' ,
            Order__c = ord.id ,
            Quote_SellingCountry__c =  'Germany',
            Proposal_ID__c = pro.Id
           // RecordTypeId = caseProductImplementationRecordTypeId
        );

        insert mainCase;

        CaseTriggerHelper.populateCaseRoutingRuleProduct(mainCase, rule7, ord);*/

        /*EmailMessage newEmail = new EmailMessage();

    newEmail.FromAddress = 'test@abc.org';
    newEmail.Incoming = True;
    newEmail.ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com';
    newEmail.Subject = 'Test email';
    newEmail.TextBody = '23456 ';
    newEmail.ParentId = mainCase.Id;
    newEmail.Headers = 'X-SFDC-Original-RCPT: gcsnatestsf@1vig92yaz0harrpvg8besbhklmvhj2qnwlsdjoi6phjy5nkl1k.q-blileao.cs21.case.sandbox.salesforce.com';

     insert newEmail;

     CaseTriggerHelper.sendAutoReponseEmail(mainCase,rule7, newEmail);
    // CaseTriggerHelper.sendAutoReponseEmail(mainCase,rule8, newEmail);
     CaseTriggerHelper.sendAutoReponseEmail(mainCase,rule6, newEmail);*/
   }

    /*   @isTest
       static void test_populateCaseRoutingRuleProduct(){

       Personal_Settings__c personalSettings = new Personal_Settings__c();
        personalSettings.trigger_case__c = true;
        insert personalSettings;

        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            User testUser = TestDataSetupUtility.createTestUser('TestFistName', 'TestLastName', adminProfile.Id);
            insert testUser;

     //   Id caseProductImplementationRecordTypeId = OrderAndCaseRecordTypes.get('Case').get('Product Implementation');
          testAccount = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TEST PB Account');//, 'North America', UserInfo.getUserId());
            testAccount.Phone = '+18008008000';
            testAccount.BillingCountry = 'Philippines';
            testAccount.PrimaryServiceRep__c = testUser.id;
            testAccount.Organization__c = 'Europe';
            testAccount.ServiceTier__c = 'Core';

            insert testAccount;

            testContact1 = TestDataSetupUtility.createTestContact(testAccount.Id, 'PrimaryBillingTestLastnameOne', 'PrimaryBillingTestFirstnameOne', 'email1@testContact.com');
            testContact1.PrimaryBillingContact__c = true;
            insert testContact1;

            opp = TestDataSetupUtility.createTestOpportunity('testopp', testAccount.Id);
            insert opp;

             ord = TestDataSetupUtility.createOrderWithOpportunity(testAccount.Id, opp.Id, null, testContact1.id);
            ord.SentToVerificationBy2__c = testUser.Id  ;
            ord.OrderStatus__c = 'Sent To Verification';
            ord.BillingAccount__c = testAccount.id;
            ord.ShippingAccount__c  = testAccount.id;
           // ord.BillingContact__c = testContact1.id;
            ord.Posting_Contact__c = testContact1.id;
            insert ord;
         Test.startTest();
        Case mainCase = new Case(
                AccountId = testAccount.Id,
                ContactId = testContact1.Id,
                Status = 'New',
                Category__c = 'Browser Issue',
                Issue__c = 'Other',
                SubIssue__c = 'Other',
                Subject = 'TEST Subject Parent',
                CustomerProblemDetail__c = 'TEST Details Parent' ,
                Order__c = ord.id ,
                Quote_SellingCountry__c =  'Germany',
                Proposal_ID__c = pro.Id
               // RecordTypeId = caseProductImplementationRecordTypeId
            );



        insert mainCase;
         CaseRoutingRule__c rule7 = new CaseRoutingRule__c();
            rule7.Name = 'test 7';
            rule7.Routing_Status__c = 'Active';
            rule7.QuoteSellingCountry__c = 'Germany';
            rule7.CaseRecordType__c = 'Credit Request';
            lstCaseRoutingRule.add(rule7);
            CaseRoutingRule__c rule8 = new CaseRoutingRule__c();
            rule8.Name = 'Catch All Rule';
            rule8.Routing_Status__c = 'Active';
            rule8.QuoteSellingCountry__c = '';
            rule8.CaseRecordType__c = 'Credit Request';
            rule7.Assign_to_Verified_By__c  = true;
            insert rule7;


        //CaseTriggerHelper.populateCaseRoutingRuleProduct(mainCase, rule7, ord);
        Test.StopTest();


       }
*/


          public static testMethod void testcaseAssignContact() {

            createTestData();
            List<Account> accList = new List<Account>();
            List<Contact> conList = new List<Contact>();
            List<Case> caseList = new List<Case>();

            Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            map<String, map<String, Id>> CaseRecordTypes = Utility.GetRecordTypeIdsBySObjectNameSet(new set<string>{'Case'});
            Personal_Settings__c personalSettings = new Personal_Settings__c();
            personalSettings.trigger_case__c = true;
            insert personalSettings;

            Test.startTest();

            // For Business Account
            Account acc1 = TestDataSetupUtility.createTestAccount('Business Account Test','Europe',UserInfo.getUserId());
            accList.add(acc1);
            Account acc2 = TestDataSetupUtility.createPersonAccount();
            acc2.PersonEmail = 'personcon1@email.com';
            accList.add(acc2);
            insert accList;

            Contact con1 =  TestDataSetupUtility.createTestContact(acc1.Id, 'Businessfirst1', 'Businessconlast1', 'businesscon1@email.com');
            conList.add(con1);
            //Contact con2 =  TestDataSetupUtility.createTestContact(acc2.Id, 'Personfirst1', 'Personconlast1', 'personcon1@email.com');
            //conList.add(con2);
            insert conList;

            Case case1 = TestDataSetupUtility.createTestNewAccountRequestCase('Europe',UserInfo.getUserId());
            case1.AccountId = acc1.Id;
            case1.SuppliedEmail = 'businesscon1@email.com';
            caseList.add(case1);

            Case case2 = TestDataSetupUtility.createTestNewAccountRequestCase('Europe',UserInfo.getUserId());
            //case2.AccountId = acc1.Id;
            case2.SuppliedEmail = 'personcon1@email.com';
            caseList.add(case2);


            Case case3 = TestDataSetupUtility.createTestNewAccountRequestCase('Europe',UserInfo.getUserId());
            //case3.AccountId = acc1.Id;
            case3.SuppliedEmail = 'contactnotexists1@email.com';
            case3.SuppliedName = 'Ram Sharma';
            caseList.add(case3);
            insert caseList;

            Test.stopTest();

        }



       public static testMethod void testCase1() {
        createTestData();

        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        map<String, map<String, Id>> CaseRecordTypes = Utility.GetRecordTypeIdsBySObjectNameSet(new set<string>{'Case'});
        Id caseProductImplementationRecordTypeId = CaseRecordTypes.get('Case').get('Product Implementation');
        Id caseGCSRecordTypeId = CaseRecordTypes.get('Case').get('GCS');
        Id caseCreditRequesteRecId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Request').getRecordTypeId();
        ID omProcessingReuestRecordtypeid = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OM Processing Request').getRecordTypeId();

        Personal_Settings__c personalSettings = new Personal_Settings__c();
        personalSettings.trigger_case__c = true;
        insert personalSettings;

        Case mainCase = new Case(
                AccountId = testAccount.Id,
                ContactId = testContact1.Id,
                Status = 'Closed',
                ParentId=null,
                Category__c = 'Browser Issue',
                Issue__c = 'Other',
                SubIssue__c = 'Other',
                Subject = 'TEST Subject Parent',
                CustomerProblemDetail__c = 'TEST Details Parent' ,
                Order__c = ord.id ,
                Quote_SellingCountry__c =  'Germany',
                Proposal_ID__c = pro.Id,
                RecordTypeId = omProcessingReuestRecordtypeid
            );

        insert mainCase;

        List<CaseRoutingRule__c> lstCRR = [SELECT Id, Name, OwnerID, CaseRecordType__c, CaseStatus__c, CaseSubStatus__c,
                                            CaseIssue__c, CaseSubIssue__c, CaseBusinessHours__c, CaseLanguage__c,
                                            FirstContactCommitmentHours__c, ResolutionCommitmentHours__c, CaseOrigin__c,
                                            SystemGenerated__c FROM CaseRoutingRule__c WHERE Name = 'test 1'];
        //CaseTriggerHelper cth = CaseTriggerHelper.NewTriggerHelper(adminProfile.Id);
        //CaseTriggerHelper.populateCaseRoutingRuleInfo(mainCase, lstCRR[0]);

        insert triggerSettings;

        System.runAs(testAdminUser) {
            List<Case> caseList = new List<case>();
            List<Case> childCaseList = new List<Case>();
            childCaseList.add( new Case(AccountId = testAccount.Id,ContactId = testContact1.Id,
                    Status = 'Closed',Category__c = 'Browser Issue',Issue__c = 'Other',
                    SubIssue__c = 'Other',Subject = 'TEST Subject Parent',CustomerProblemDetail__c = 'TEST Details Parent' ,
                    Order__c = ord.id ,Proposal_ID__c = pro.Id,parentId = mainCase.Id,Quote_SellingCountry__c =  'Germany',
                    RecordTypeId = caseProductImplementationRecordTypeId));
            childCaseList.add( new Case(AccountId = testAccount.Id,ContactId = testContact1.Id,
                    Status = 'New',Category__c = 'Browser Issue',Issue__c = 'Other',
                    SubIssue__c = 'Other',Subject = 'TEST Subject Parent',CustomerProblemDetail__c = 'TEST Details Parent' ,
                    Order__c = ord.id ,Proposal_ID__c = pro.Id, parentId = mainCase.Id,Quote_SellingCountry__c =  'Germany',
                    RecordTypeId = caseProductImplementationRecordTypeId));
            childCaseList.add( new Case(AccountId = testAccount.Id,ContactId = testContact1.Id,
                    Status = 'New',Category__c = 'Browser Issue',Issue__c = 'Other',
                    SubIssue__c = 'Other',Subject = 'TEST Subject Parent',CustomerProblemDetail__c = 'TEST Details Parent' ,
                    Order__c = ord.id ,Proposal_ID__c = pro.Id,parentId = mainCase.Id,Quote_SellingCountry__c =  'Germany',
                    RecordTypeId = caseCreditRequesteRecId));
            childCaseList.add( new Case(AccountId = testAccount.Id,ContactId = testContact1.Id,
                    Status = 'Cancelled',Category__c = 'Browser Issue',Issue__c = 'Other',
                    SubIssue__c = 'Other',Subject = 'TEST Subject Parent',CustomerProblemDetail__c = 'TEST Details Parent' ,
                    Order__c = ord.id ,Proposal_ID__c = pro.Id,parentId = mainCase.Id,
                    RecordTypeId = omProcessingReuestRecordtypeid));
            CaseTriggerHandler.ExecuteTriggers = true;
            CaseTriggerHandler.RunCount = 0;
            insert childCaseList;
            Test.startTest();
                //insert mainCase2;
                //mainCase = [Select Id, Order__c,parentId,RecordTypeId from Case Where Id =:maincase2.Id];
                System.debug('==maincase==2='+mainCase);
                //childCaseList[0].AccountId = testAccount2.Id;
                childCaseList[0].OwnerId = testGroup.Id;
                CaseTriggerHandler.ExecuteTriggers = true;
                CaseTriggerHandler.RunCount = 0;
                CaseTriggerHandler.bypassRuncount = false;
                childCaseList[0].FirstContactCommitment__c = 19;
                childCaseList[0].ResolutionCommitment__c =20;
                update childCaseList[0];

            CaseTriggerHelper helper =  CaseTriggerHelper.NewTriggerHelper('');
            helper.isMediaProduct('Media: Career Ad Network');
            Test.stopTest();
        }
    }

    public static testMethod void testCase2() {
        createTestData();

        map<String, map<String, Id>> CaseRecordTypes = Utility.GetRecordTypeIdsBySObjectNameSet(new set<string>{'Case'});
        Id caseProductImplementationRecordTypeId = CaseRecordTypes.get('Case').get('Product Implementation');
        Id caseGCSRecordTypeId = CaseRecordTypes.get('Case').get('GCS');
        Id caseCreditRequesteRecId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Request').getRecordTypeId();
        ID omProcessingReuestRecordtypeid = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OM Processing Request').getRecordTypeId();

        Personal_Settings__c personalSettings = new Personal_Settings__c();
        personalSettings.trigger_case__c = true;
        personalSettings.Validation_Account__c = false;
        insert personalSettings;

        Method_Kill_List__c testCustomSetting = new Method_Kill_List__c(Name='updateOpptySplit', Kill_Method__c=false);
        insert testCustomSetting;

         Case mainCase = new Case(
                AccountId = testAccount.Id,
                ContactId = testContact1.Id,
                Status = 'Closed',
                ParentId=null,
                Category__c = 'Browser Issue',
                Issue__c = 'Other',
                SubIssue__c = 'Other',
                Subject = 'TEST Subject Parent',
                CustomerProblemDetail__c = 'TEST Details Parent' ,
                Order__c = ord.id ,
                Proposal_ID__c = pro.Id,
                RecordTypeId = caseProductImplementationRecordTypeId
            );


        insert mainCase;
        insert triggerSettings;

        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User testUser = TestDataSetupUtility.createTestUser('Test', 'Test', adminProfile.Id);
        //insert testUser;
        System.runAs(testUser) {
            List<Case> caseList = new List<Case>();
            caseList.add( new Case(AccountId = testAccount.Id, ContactId = testContact1.Id,
                    Status = 'Closed',Category__c = 'Browser Issue',Issue__c = 'Other',
                    SubIssue__c = 'Other',Subject = 'TEST Subject Parent',CustomerProblemDetail__c = 'TEST Details Parent' ,
                    Order__c = ord.id ,Opportunity__c = opp.Id,parentId = mainCase.Id,
                    RecordTypeId = omProcessingReuestRecordtypeid));
            /*caseList.add( new Case(AccountId = testAccount.Id,ContactId = testContact1.Id,
                    Status = 'New',Category__c = 'Browser Issue',Issue__c = 'Other',
                    SubIssue__c = 'Other',Subject = 'TEST Subject Parent',CustomerProblemDetail__c = 'TEST Details Parent' ,
                    Order__c = ord.id ,Proposal_ID__c = pro.Id,
                    RecordTypeId = omProcessingReuestRecordtypeid));
            caseList.add( new Case(AccountId = testAccount2.Id,ContactId = testContact1.Id,
                    Status = 'New',Category__c = 'Browser Issue',Issue__c = 'Other',
                    SubIssue__c = 'Other',Subject = 'TEST Subject Parent',CustomerProblemDetail__c = 'TEST Details Parent' ,
                    Order__c = ord.id ,Opportunity__c = opp1.Id,
                    RecordTypeId = omProcessingReuestRecordtypeid));*/

            CaseTriggerHandler.ExecuteTriggers = true;
            CaseTriggerHandler.RunCount = 0;

            insert caseList;
            //insert mainCase2;
            //mainCase = [Select Id, Order__c,parentId,RecordTypeId from Case Where Id =:maincase2.Id];
            System.debug('==maincase==2='+mainCase);

            Test.startTest();
                Account acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
                insert acc;

                Contact con = TestDataSetupUtility.createTestContact(acc.Id, 'Test_Last', 'Test_First', 'test@test.com');
                insert con;

                Opportunity oppt = TestDataSetupUtility.createTestOpportunity('TestOppt_04_Nov_2015', acc.Id);
                insert oppt;

                caseList[0].AccountId = acc.Id;
                caseList[0].ContactId = con.Id;
                caseList[0].Opportunity__c = oppt.Id;

                CaseTriggerHandler.ExecuteTriggers = true;
                CaseTriggerHandler.bypassRuncount= false;
                CaseTriggerHandler.Runcount= 0;
                try{
                 update caseList;
                 CaseTriggerHandler.ExecuteTriggers = true;
                //CaseTriggerHandler.bypassRuncount= true;
                 CaseTriggerHandler.Runcount= 0;
                 mainCase.OwnerId = testUser.Id;
                 mainCase.Status = 'Closed';
                 update mainCase;
                }catch(Exception e){}
                delete mainCase;
                undelete mainCase;
            Test.stopTest();
        }
    }

    public static testMethod void testCase3() {
        createTestData();
		system.debug('<<in test3>>');
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        Personal_Settings__c personalSettings = new Personal_Settings__c();
        personalSettings.trigger_case__c = true;
        personalSettings.Validation_Account__c = false;
        insert personalSettings;

        Method_Kill_List__c testCustomSetting = new Method_Kill_List__c(Name='updateOpptySplit', Kill_Method__c=false);
        insert testCustomSetting;

        //Org_Settings__c orgSettings = new Org_Settings__c(System_Administrator_Profile_Name__c='System Administrator');
        //insert orgSettings;

        map<String, map<String, Id>> CaseRecordTypes = Utility.GetRecordTypeIdsBySObjectNameSet(new set<string>{'Case'});
        //Id caseParentRecordTypeId = CaseRecordTypes.get('Case').get('Parent/Child Relationship');
        Id caseParentRecordTypeId = CaseRecordTypes.get('Case').get('Product Implementation');
        Id caseRegistrationRecordTypeID = CaseRecordTypes.get('Case').get('Registration/VATFiscal Code');
        User testUser = TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);

        system.debug('!!!RecordTypes ' + caseParentRecordTypeId + ' ' + caseRegistrationRecordTypeID);
        List<Case> lstCase = new List<Case>();
        System.runAs (testUser) {
            Case parentCase = new Case(
                AccountId = testAccount.Id,
                ContactId = testContact1.Id,
                Status = 'Closed',
                Category__c = 'Browser Issue',
                Issue__c = 'Other',
                SubIssue__c = 'Other',
                Subject = 'TEST Subject Parent',
                CustomerProblemDetail__c = 'TEST Details Parent' ,
                RecordTypeId = caseParentRecordTypeId,
                OrderLineItem__c = oli.id,
                Order__c = ord.Id
            );
           // insert parentCase;
            lstCase.add(parentCase);

            Case mainCase = new Case(
                AccountId = testAccount.Id,
                ContactId = testContact1.Id,
                Status = 'New',
                Category__c = 'Browser Issue',
                Issue__c = 'Other',
                SubIssue__c = 'Other',
                Subject = 'TEST Subject Parent',
                CustomerProblemDetail__c = 'TEST Details Parent' ,
                ParentId = parentcase.Id,
                order__c = ord.Id,
                RecordTypeId = caseRegistrationRecordTypeID
            );
            lstCase.add(mainCase);
			/*Case mainCase2 = new Case(
                AccountId = testAccount2.Id,
                ContactId = testContact2.Id,
                Status = 'New',
                Category__c = 'Browser Issue',
                Issue__c = 'Other',
                SubIssue__c = 'Other',
                Subject = 'TEST Subject Parent',
                CustomerProblemDetail__c = 'TEST Details Parent' ,
                ParentId = parentcase.Id,
                order__c = ord.Id,
                RecordTypeId = caseRegistrationRecordTypeID
            );
            lstCase.add(mainCase2);*/
            insert lstCase;
        }
        //Id Id1 = lstCase[1].Id;
        //system.debug('<<Id1>>'+Id1);
        Map<ID, Case> mapOldCase = new Map<Id, Case>();
        mapOldCase.put(lstCase[0].Id, lstCase[0]);
        mapOldCase.put(lstCase[1].Id, lstCase[1]);
        system.debug('<<lstCase[0].Id>>' + lstCase[0].Id + '<<lstCase[1].Id>>' + lstCase[1].Id);
        //mapOldCase.put(lstCase[2].Id, lstCase[2]);

        system.runAs(testUser) {
            testGroup = new Group(Name='test group', Type='Queue');
            insert testGroup;
            System.runAs ( new User(Id = UserInfo.getUserId()) ) {
                QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
                insert testQueue;

                Test.startTest();
                    //Case mainCase = new Case(Id = .Id);
                    lstCase[0].OwnerId = testGroup.Id;
                    lstCase[1].Status = 'Closed';
                    lstCase[1].OwnerId = testGroup.Id;
                	//lstCase[2].Status = 'Closed';
                    //lstCase[2].OwnerId = testGroup.Id;
                    //lstCase[2].ParentId = Id1;
                    CaseTriggerHandler.ExecuteTriggers = true;
                    CaseTriggerHandler.bypassRuncount= true;

                    update lstCase;

                Test.stopTest();
                Map<ID, Case> mapNewCase = new Map<Id, Case>();
                mapOldCase.put(lstCase[0].Id, lstCase[0]);
                mapOldCase.put(lstCase[1].Id, lstCase[1]);
                //mapOldCase.put(lstCase[2].Id, lstCase[2]);

                CaseTriggerHelper cth = CaseTriggerHelper.NewTriggerHelper(p.Id);
                //cth.closeParentCase2(lstCase);
                cth.calculateCaseBusinessHours(lstCase, mapOldCase);
                cth.AllChildCaseMediaTypeIsClosed(mapNewCase, mapOldCase);
                cth.copyQueueNameToGroupField(lstCase);
            }
        }
    }

    public static testMethod void testCase4() {

        createTestData();

        Personal_Settings__c personalSettings = new Personal_Settings__c();
        personalSettings.trigger_case__c = true;
        personalSettings.Validation_Account__c = false;
        insert personalSettings;


        map<String, map<String, Id>> CaseRecordTypes = Utility.GetRecordTypeIdsBySObjectNameSet(new set<string>{'Case'});
        ID omProcessingReuestRecordtypeid = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OM Processing Request').getRecordTypeId();
        ID creditLimitRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Request re Credit Limit').getRecordTypeId();
        ID newRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Account Request').getRecordTypeId();
        ID creditRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Request').getRecordTypeId();
        ID gcsRecordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('GCS').getRecordTypeId();

        List<Case> lstCase = new List<Case>();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Case case1 = new Case(
                AccountId = testAccount.Id,
                ContactId = testContact1.Id,
                Status = 'New',
                Category__c = 'Browser Issue',
                Issue__c = 'Other',
                SubIssue__c = 'Other',
                Subject = 'TEST Subject Parent',
                CustomerProblemDetail__c = 'TEST Details Parent' ,
                RecordTypeId = omProcessingReuestRecordtypeid
            );
            lstCase.add(case1);

            Case case2 = new Case(
                AccountId = testAccount.Id,
                ContactId = testContact1.Id,
                Status = 'New',
                Category__c = 'Browser Issue',
                Issue__c = 'Other',
                SubIssue__c = 'Other',
                Subject = 'TEST Subject Parent',
                CustomerProblemDetail__c = 'TEST Details Parent' ,
                order__c = ord.Id,
                RecordTypeId = creditLimitRecordTypeId
            );
            lstCase.add(case2);

            Case case3 = new Case(
                AccountId = testAccount.Id,
                ContactId = testContact1.Id,
                Status = 'New',
                Category__c = 'Browser Issue',
                Issue__c = 'Other',
                SubIssue__c = 'Other',
                Subject = 'TEST Subject Parent',
                CustomerProblemDetail__c = 'TEST Details Parent' ,
                order__c = ord.Id,
                RecordTypeId = newRequestRecordTypeId
            );
            lstCase.add(case3);

            Case case4 = new Case(
                AccountId = testAccount.Id,
                ContactId = testContact1.Id,
                Status = 'New',
                Category__c = 'Browser Issue',
                Issue__c = 'Other',
                SubIssue__c = 'Other',
                Subject = 'TEST Subject Parent',
                CustomerProblemDetail__c = 'TEST Details Parent' ,
                order__c = ord.Id,
                RecordTypeId = creditRequestRecordTypeId
            );
            lstCase.add(case4);

            Test.startTest();
                insert lstCase;
            Test.stopTest();
        }
    }


    public static testMethod void testCase5() {
        //createTEmplate();
        createTestData();
        //EmailTemplate eTemplate = [select id from EmailTemplate limit 1];
        CaseRoutingRule__c rule9 = new CaseRoutingRule__c();
            rule9.Name = 'Test Rule';
            rule9.Routing_Status__c = 'Debug';
        	rule9.FromAddressforAutoResponse__c = 'customerervice@monster.com';
            rule9.AutoResponseTemplate__c = 'Test';
            rule9.CaseRecordType__c = 'Credit Request';
         insert rule9;
        Personal_Settings__c personalSettings = new Personal_Settings__c();
        personalSettings.trigger_case__c = true;
        insert personalSettings;
        User testUser = TestDataSetupUtility.createTestUser('Integration', 'MAPP', TestDataSetupUtility.PROFILE_ID);
        testUser.FirstName = 'Integration';
        testUser.LastName = 'MAPP';
        insert testUser;


        Case case1;
        List<Case> lstCase = new List<Case>();
        Test.startTest();
        System.runAs ( testUser ) {

            CaseRoutingRule__c rule8 = new CaseRoutingRule__c();
            rule8.Name = 'Test Rule';
            rule8.Routing_Status__c = 'Debug';
            rule8.AutoResponseTemplate__c = 'Test';
            rule8.FromAddressforAutoResponse__c = 'customerervice@monster.com';
            rule8.CaseRecordType__c = 'Credit Request';
         insert rule8;
           /* case1 = new Case(
                AccountId = testAccount.Id,
                ContactId = testContact1.Id,
                Status = 'New',
                Category__c = 'Browser Issue',
                Issue__c = 'Other',
                SubIssue__c = 'Other',
                Subject = 'TEST Subject Parent',
                SuppliedEmail= 'test_mail@test.com',
                CustomerProblemDetail__c = 'TEST Details Parent'
                //RecordTypeId = omProcessingReuestRecordtypeid
            );

            case1.Case_Routing_Rule__c = rule8.Id;
            lstCase.add(case1); */
           Case case2 = new Case(
                AccountId = testAccount.Id,
                ContactId = testContact1.Id,
                Status = 'New',
                Category__c = 'Browser Issue',
                Issue__c = 'Other',
                SubIssue__c = 'Other',
                Subject = 'TEST Subject Parent',
                SuppliedEmail= 'test_mail@test.com',
                SuppliedName = 'test mail',
                CustomerProblemDetail__c = 'TEST Details Parent'
                //RecordTypeId = omProcessingReuestRecordtypeid
            );
            lstCase.add(case2);
            CaseTriggerHandler.ExecuteTriggers = true;
            CaseTriggerHandler.bypassRuncount= true;

            insert lstCase;
        }



        Test.stopTest();

    }
    //SBerron - 04/05/17 - Commented for .07 deployment
    //public static testMethod void testCaseProdImp() {
    //    // TKOM Added for S-464557 and S-445214 - still work in progress
    //    createTestData();
    //    system.debug('<<in testCaseProdImp>>');
    //    Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

    //    Personal_Settings__c personalSettings = new Personal_Settings__c();
    //    personalSettings.trigger_case__c = true;
    //    personalSettings.Validation_Account__c = false;
    //    insert personalSettings;

    //    //Org_Settings__c orgSettings = new Org_Settings__c(System_Administrator_Profile_Name__c='System Administrator');
    //    //insert orgSettings;

    //    map<String, map<String, Id>> CaseRecordTypes = Utility.GetRecordTypeIdsBySObjectNameSet(new set<string>{'Case'});
    //    Id caseParentRecordTypeId = CaseRecordTypes.get('Case').get('Product Implementation');
    //    User testUser = TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);

    //    List<Case> lstCase = new List<Case>();
    //    System.runAs (testUser) {
    //      ord.OrderStatus__c = 'Sent To Verification';
    //      //update ord;

    //      /*  Case parentCase = new Case(
    //            AccountId = testAccount.Id,
    //            AgencyLookup__c = null, //Agency Id to be set here for Agency scenario
    //            ContactId = testContact1.Id,
    //            Status = 'New',
    //            Category__c = 'Support',
    //            //Issue__c = 'Other',
    //            //SubIssue__c = 'Other',
    //            Subject = 'Product Implementation Case for ' + testAccount.Name + ' ' + ord.Name,
    //            //CustomerProblemDetail__c = 'TEST Details Parent' ,
    //            RecordTypeId = caseParentRecordTypeId,
    //            //OrderLineItem__c = oli.id,
    //            Sub_Type__c = 'Line Item Fulfillment',
    //            Order__c = ord.Id,
    //            Proposal_ID__c = pro.Id
    //        );
    //       // insert parentCase;
    //        lstCase.add(parentCase);


    //        insert lstCase;*/
    //    }
    //    //Id Id1 = lstCase[1].Id;
    //    //system.debug('<<Id1>>'+Id1);
    //    Map<ID, Case> mapOldCase = new Map<Id, Case>();
    //    mapOldCase.put(lstCase[0].Id, lstCase[0]);
    //    //mapOldCase.put(lstCase[1].Id, lstCase[1]);
    //    //system.debug('<<lstCase[0].Id>>' + lstCase[0].Id + '<<lstCase[1].Id>>' + lstCase[1].Id);
    //    //mapOldCase.put(lstCase[2].Id, lstCase[2]);

    //    /*system.runAs(testUser) {
    //        testGroup = new Group(Name='test group', Type='Queue');
    //        insert testGroup;
    //        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
    //            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
    //            insert testQueue;

    //            Test.startTest();
    //                //Case mainCase = new Case(Id = .Id);
    //                lstCase[0].OwnerId = testGroup.Id;
    //                //lstCase[1].Status = 'Closed';
    //                //lstCase[1].OwnerId = testGroup.Id;
    //                //lstCase[2].Status = 'Closed';
    //                //lstCase[2].OwnerId = testGroup.Id;
    //                //lstCase[2].ParentId = Id1;
    //                CaseTriggerHandler.ExecuteTriggers = true;
    //                CaseTriggerHandler.bypassRuncount= true;

    //                update lstCase;

    //            Test.stopTest();
    //            Map<ID, Case> mapNewCase = new Map<Id, Case>();
    //            mapOldCase.put(lstCase[0].Id, lstCase[0]);
    //            //mapOldCase.put(lstCase[1].Id, lstCase[1]);
    //            //mapOldCase.put(lstCase[2].Id, lstCase[2]);

    //            CaseTriggerHelper cth = CaseTriggerHelper.NewTriggerHelper(p.Id);
    //            //cth.closeParentCase2(lstCase);
    //            cth.calculateCaseBusinessHours(lstCase, mapOldCase);
    //            cth.AllChildCaseMediaTypeIsClosed(mapNewCase, mapOldCase);
    //            cth.copyQueueNameToGroupField(lstCase);
    //            cth.isMediaProduct(pro.Name);
    //        }
    //    }*/
    //} // END testCaseProdImp
}