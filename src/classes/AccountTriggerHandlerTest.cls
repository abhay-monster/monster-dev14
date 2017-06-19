@isTest
private class AccountTriggerHandlerTest {
    private static Personal_Settings__c personalSettings;
        
    @testSetup
    static void  setupData(){
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        personalSettings = TestDataSetupUtility.buildPersonalSetting();
        personalSettings.Trigger_Account__c = true;
        personalSettings.Send_Emails__c = true;
        insert personalSettings;
        Org_Settings__c orgSetting = new Org_Settings__c();
        orgSetting.Fraud_Profile_Name__c = 'System Administrator';
        orgSetting.Generic_Fraud_User_Id__c = adminProfile.Id;
        insert orgSetting;
        TestDataSetupUtility.createZipcodeConfiguration();
    }
    static void prepareData(){
        personalSettings = [select id,Trigger_Order__c from Personal_Settings__c limit 1];
        
    } 
  static testMethod void testPrimaryAgencyContact(){ 
        //build personal settings
        /*Personal_Settings__c persSett = TestDataSetupUtility.buildPersonalSetting();
        persSett.Trigger_Account__c = true;
        insert persSett;*/
        prepareData();
        Payment_Details__c paymentDetails = TestDataSetupUtility.createTestPaymentDetails('North America' , 'Monthly', 'Net 10');
        paymentDetails.PaymentMethod__c = 'Invoice';
        paymentDetails.Active__c  = true;
        insert paymentDetails;
        PaymentDetails__c paymentDet = new PaymentDetails__c ();
        paymentDet.Name = 'North America';
        paymentDet.Id__c = paymentDetails.Id;
        insert paymentDet;
        
        list<Account> accountList = new list<Account>();
        Account usedAccount = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account -1');
        accountList.add(usedAccount);
        
        Account agencyAccount = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Agency Account -1');
        agencyAccount.AgencyFlag__c = true;
        accountList.add(agencyAccount);
        
        Contact primaryAgencyContact = TestDataSetupUtility.createTestContact(agencyAccount.Id, 'Doe', 'John', 'email@test.com');
        primaryAgencyContact.PrimarySalesContact__c = true;
        insert primaryAgencyContact;
        accountList.add(TestDataSetupUtility.createTestAccount('Test Account-3', 'North America', UserInfo.getUserId()));
        insert accountList;
        
        RelatedPartner__c partner = new RelatedPartner__c();
        partner.Account__c = usedAccount.Id;
        partner.Partner__c = agencyAccount.Id;
        partner.Role__c = 'Agency';
        partner.AgencyType__c = 'Third Party';
        insert partner;
        
        Account testAccount = [SELECT PrimaryRelatedAgency__r.Partner__c, PrimaryAgencyContact__c FROM Account WHERE Id = :usedAccount.Id];
        //system.assertEquals(testAccount.PrimaryRelatedAgency__r.Partner__c, agencyAccount.Id);
        String testName = primaryAgencyContact.Name;
        system.debug('Contact Name: ' + testName);
        //system.assertEquals(testAccount.PrimaryAgencyContact__c, primaryAgencyContact.FirstName + ' ' + primaryAgencyContact.LastName);
        
        accountList[1].ParentId = accountList[0].Id;
        accountList[1].DunsNumber = '232332';
        update accountList[1];
    }
    
    static testMethod void testAccountWithoutTerritory () {
        WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c();
        endpoint.Endpoint__c = 'USPS Integration';
        endpoint.Name = 'USPS Integration';
        insert endpoint;
        
        IntegrationConfig__c integSett = TestDataSetupUtility.buildIntegrationConfigSetting();
        integSett.Name = 'USPS Integration';
        integSett.EndpointName__c = endpoint.Name;
        integSett.PaypalRedirectURL__c = endpoint.Endpoint__c;
        insert integSett;
        /*Personal_Settings__c persSett = TestDataSetupUtility.buildPersonalSetting();
        persSett.Trigger_Account__c = true;
        persSett.Send_Emails__c = true;
        insert persSett;*/
        List<Account> accountList = new List<Account>();
        accountList.add( TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account -2'));
        accountList.add( TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account2'));
        accountList[0].Organization__c = 'Europe';
        accountList[1].MAPP_Country__c = 'US';
        accountList[1].SalesRepLogin__c ='ECOMM';
        accountList[1].DBEmployeeTotal__c = 2;
        accountList[1].Industry_ID__c= '39';
        accountList[1].AccountGroup__c= 'Client'; 
        accountList[1].SalesChannel__c = 'Agency';
        accountList[1].ShippingPostalCode = '12345';
        accountList[1].CreatedDate = System.now();
        TerritoryAssignment__c ta = new TerritoryAssignment__c();
        insert ta;
        TerritoryAssignmentCode__c tac = new TerritoryAssignmentCode__c(AccountGroup__c =accountList[1].AccountGroup__c,
                                                                        NamedAccount__c =accountList[1].accountID__c, SalesChannel__c = accountList[1].SalesChannel__c,
                                                                        AccountCountry__c = accountList[1].ShippingCountry,
                                                                        PostingZipCodeStart__c = '123450000', PostingZipCodeEnd__c = '123459999',
                                                                     TerritoryAssignment__c=ta.Id);
        insert tac;   
          
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User testUser = TestDataSetupUtility.createTestUser('Test', 'Test', adminProfile.Id);
        insert testUser;
        System.runAs(testUser) {
            Test.startTest();
                SetSendToEmailFlag.fromTerritory = true;
                AccountTriggerHandler.RunCount = 0;
                AccountTriggerHandler.ExecuteTriggers = true; 
                accountList[0].ShippingPostalCode = '12345';
                insert accountList;
            Test.stopTest();
        }
    }

    static testMethod void testCreditLimitForAccounts () {
        
        //build personal settings
        //Personal_Settings__c persSett = TestDataSetupUtility.buildPersonalSetting();
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User testUser = TestDataSetupUtility.createTestUser('Generic', 'Generic', adminProfile.Id);
        testUser.FirstName = 'Generic';
        testUser.LastName = 'Generic';
        //testUser.UserRoleId = role.Id;
        insert testUser;
        Id userId = Userinfo.getUserId();
        System.runAs(testUser) {
            /*Org_Settings__c orgSetting = new Org_Settings__c();
            orgSetting.Fraud_Profile_Name__c = 'System Administrator';
            orgSetting.Generic_Fraud_User_Id__c =  adminProfile.Id;
            //orgSetting.Generic_Fraud_User_Id__c = testUser.Id;
            insert orgSetting;
            persSett.Trigger_Account__c = true;
            persSett.Send_Emails__c = true;
            insert persSett;*/
            Payment_Details__c paymentDetails = TestDataSetupUtility.createTestPaymentDetails('Europe1','Single Payment','30 days + EOM');
            //insert paymentDetails; 
            
            WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c();
            endpoint.Endpoint__c = 'USPS Integration';
            endpoint.Name = 'USPS Integration';
            insert endpoint;
            
            IntegrationConfig__c integSett = TestDataSetupUtility.buildIntegrationConfigSetting();
            integSett.Name = 'USPS Integration';
            integSett.EndpointName__c = endpoint.Name;
            integSett.PaypalRedirectURL__c = endpoint.Endpoint__c;
            insert integSett;
            DandBCompany dandBCompany = new DandBCompany(Name = 'Test',DunsNumber = '604061267',ParentOrHqDunsNumber = '123456789');
            insert dandBCompany;
            CountryLimit__c cl = TestDataSetupUtility.createCountryLimit('United States', 'US', 2000, 'Staffing');
            insert cl;
            Program__c program = TestDataSetupUtility.createAccountProgram('Test Prog');
            insert program ;
            Test.startTest();
            Account testAccount = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account 0');
            testAccount.Organization__c = 'Europe';
            testAccount.Account_Type__c = 'Staffing';
            testAccount.Payment_Method__c = 'Credit Card';
            testAccount.Payment_Frequency__c = 'Single Payment';
            testAccount.Payment_Term__c = '30 days + EOM';
            //testAccount.DunsNumber = '123456789';
            testAccount.Phone = '+1.555.555.1212';
            testAccount.AccountProgram__c = program.Id;
            insert testAccount;
            testAccount.DunsNumber = '123456789';
            update testAccount;
            Account a = [Select Id, CreditLimit__c, SalesChannel__c, ShippingCountryCode From Account Where Id =: testAccount.Id];
            system.assertEquals('US', a.ShippingCountryCode);
            //system.assertEquals(2000, a.CreditLimit__c);    
            //system.assertEquals('Staffing', a.SalesChannel__c);
            ////
            testAccount.OwnerId = userId; 
            /////
            AccountTriggerHandler.RunCount =0;
            testAccount.Payment_Frequency__c = 'Quarterly';
            update testAccount;        
            list<Account> accountList = new list<Account>();
            accountList.add( TestDataSetupUtility.createTestAccountWithShippingAndBilling('Parent Account2'));
            accountList[0].DandbCompanyId = dandBCompany.Id;
            AccountTriggerHandler.ExecuteTriggers = true; 
            AccountTriggerHandler.RunCount =0;
            
            accountList.add( TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Agency Account 0'));
            accountList[1].DandbCompanyId = dandBCompany.Id;
            accountList[1].AgencyFlag__c = true;
            accountList[1].ParentId = testAccount.Id; 
            accountList.add( TestDataSetupUtility.createTestAccountWithShippingAndBilling('Child Account 0'));
            accountList[1].RegistrationNumber__c = '55433434';
            accountList[2].ParentId = testAccount.Id;
            accountList[2].Account_Type__c = 'ADP';
            accountList[2].AccountStatus__c = 'Candidate';
            accountList[2].PrimaryServiceRep__c= testUser.Id;
            accountList[2].RegistrationNumber__c = '323223432';
            accountList[2].CreditStatus__c = 'Fraud';
            accountList[2].MAPP_Country__c = 'NL';
            insert accountList;
            
            //insert prop;
            //update
            AccountTriggerHandler.ExecuteTriggers = true; 
            AccountTriggerHandler.RunCount =0;
            accountList[2].ParentId = accountList[0].Id;
            //accountList[2].AccountStatus__c = 'Customer';
            accountList[1].AccountStatus__c = 'Fraud';
            accountList[2].PrimaryServiceRep__c= UserInfo.getUserId();
            accountList[2].DunsNumber = '2232332';
            accountList[2].OwnerId = testUser.Id; 
            accountList[2].MAPP_Country__c = 'BE';
            try{
            update new List<Account>{accountList[2],accountList[1]};
            }catch(Exception e){}
            Test.stopTest();
        }
    }
    
    static testMethod void testChangeOwner(){
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        /*Org_Settings__c orgSetting = new Org_Settings__c();
        orgSetting.Fraud_Profile_Name__c = 'System Administrator';
        orgSetting.Generic_Fraud_User_Id__c = adminProfile.Id;
        insert orgSetting;
        Personal_Settings__c persSett = TestDataSetupUtility.buildPersonalSetting();
        persSett.Trigger_Account__c = true;
        insert persSett;*/
        User testUser = TestDataSetupUtility.createTestUser('Generic', 'TestLastName', adminProfile.Id);
        testUser.FirstName = 'Generic';
        testUser.LastName = 'Generic';
        insert testUser;
        
        WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c();
        endpoint.Endpoint__c = 'USPS Integration';
        endpoint.Name = 'USPS Integration';
        insert endpoint;
        
        IntegrationConfig__c integSett = TestDataSetupUtility.buildIntegrationConfigSetting();
        integSett.Name = 'USPS Integration';
        integSett.EndpointName__c = endpoint.Name;
        integSett.PaypalRedirectURL__c = endpoint.Endpoint__c;
        insert integSett;
        
        Lead ld = TestDataSetupUtility.createTestLead();
        //ld.Posting_City__c = 'JP';
        //ld.Posting_Country__c = 'United States';
        //ld.Posting_State_Province__c = 'Alabama';
        //ld.Posting_Street__c = 'JLN';
        ld.Posting_Zip_Postal_Code__c = '302017';
        Lead ld2 = TestDataSetupUtility.createTestLead();
        insert new List<Lead>{ld,ld2};

        list<Account> accountList = new list<Account>();
        accountList.add( TestDataSetupUtility.createTestAccountWithShippingAndBilling('Parent Account2'));
        accountList[0].CreditStatus__c = 'Approved PrePay'; 
        accountList[0].LeadId__c = ld.Id;
        accountList.add( TestDataSetupUtility.createTestAccountWithShippingAndBilling('Parent Account1'));
        accountList[1].MAPP_Country__c = 'US';
        accountList[1].SalesRepLogin__c ='ECOMM';
        accountList[1].DBEmployeeTotal__c = 2;
        accountList[1].Industry_ID__c= '39'; 
        accountList.add( TestDataSetupUtility.createTestAccountWithShippingAndBilling('Parent Account2'));
        accountList[1].LeadId__c = ld2.Id;
        
        
        AccountTriggerHelper helper = AccountTriggerHelper.NewTriggerHelper('System Administrator');
        
        insert accountList;
        Contact con = TestDataSetupUtility.createTestContact(accountList[0].Id, 'LastName', 'FirstName', 'testEmail@dfgdf.com');
        insert con;
        Order__c ord = TestDataSetupUtility.createOrder(accountList[0].Id, con.Id);
        ord.OrderStatus__c = 'Verified';
        insert ord;
        Order_Line_Item__c oli = TestDataSetupUtility.createOrderLineItem(ord.Id);
        insert oli;
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp ', accountList[0].Id);
        insert opp;
        Task task= new Task(WhatId = accountList[0].Id, Status = 'Open',ActivityDate = Date.today().addDays(1));
        insert task;
        Event evnt = new Event(WhatId = accountList[0].Id,EventStatus__c = 'Open',DurationInMinutes=12,ActivityDateTime = Date.today().addDays(1));
        insert evnt; 
        Apttus_Proposal__Proposal__c prop = TestDataSetupUtility.createApttusProposal(opp);
        prop.Apttus_Proposal__Account__c = accountList[0].Id;
        prop.Apttus_Proposal__ExpectedStartDate__c = Date.today();
        prop.QuoteStatus__c = 'In Progress';
        prop.BillContact__c = con.id;
        prop.PostingContact__c = con.id;
        prop.BillingAccount__c = accountList[0].Id;
        insert prop;

        
        AccountTriggerHandler.ExecuteTriggers = true; 
        AccountTriggerHandler.RunCount =0;

        accountList[0].OwnerId = testUser.Id;
        accountList[1].OwnerId = testUser.Id;

        Test.startTest();
        update accountList;
        
        helper.AssignAccountsFromMAPP(accountList);
        Test.stopTest(); 
    }
    
    static testMethod void testMethod1(){
        //build personal settings
        /*Personal_Settings__c persSett = TestDataSetupUtility.buildPersonalSetting();
        Org_Settings__c orgSetting = new Org_Settings__c();
        orgSetting.Fraud_Profile_Name__c = 'System Administrator';
        orgSetting.Generic_Fraud_User_Id__c = userinfo.getProfileId();
        insert orgSetting;
        persSett.Trigger_Account__c = true;
        insert persSett;*/
        //Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User testUser = TestDataSetupUtility.createTestUser('Generic', 'Generic', userinfo.getProfileId());
        testUser.FirstName = 'Generic';
        insert testUser;

        Lead ld = TestDataSetupUtility.createTestLead();
        insert ld;

        list<Account> accountList = new list<Account>();
        accountList.add( TestDataSetupUtility.createTestAccountWithShippingAndBilling('Parent Account 2'));
        accountList[0].DunsNumber = '21232332';
        accountList[0].MAPP_Country__c = 'FR';
        accountList[0].CreatedDate = System.now();
        accountList[0].Primary_Xcode__c = 'Test';

        accountList.add( TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Agency Account'));
        accountList[1].ParentId = accountList[0].Id; 
        accountList[1].AgencyFlag__c = true;
        accountList[1].MAPP_Country__c = 'CA';
        accountList[1].RegistrationNumber__c = '55433434';
        accountList[1].CreatedDate = System.now();
        accountList[1].PrimaryServiceRep__c = UserInfo.getUserId();
        accountList[1].Primary_Xcode__c = 'Test 1';

        accountList.add( TestDataSetupUtility.createTestAccountWithShippingAndBilling('Child Account'));
        accountList[2].ParentId = accountList[1].Id; 
        accountList[2].MAPP_Country__c = 'UK';
        accountList[2].CreatedDate = System.now();
        accountList[2].OwnerId = testUser.Id;
        accountList[2].PrimaryServiceRep__c = testUser.Id;
        accountList[2].Primary_Xcode__c = 'Test 2';
        //accountList[2].LeadId__c = ld.Id;
        accountList[2].RegistrationNumber__c = '5543343Q';
        insert accountList;
        accountList.add( TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account2'));
        
        Set<Id> accIDs = new Set<Id>{accountList[0].Id, accountList[1].Id, accountList[2].Id};
        AccountTriggerHelper helper = new AccountTriggerHelper();
        helper.ReplaceAccountTeamMember(accIDs);

        Xcode__c xc = new Xcode__c(
            Name = 'Test XCode'
        );
        insert xc;

        List<XcodeAccount__c> lstXA = new List<XcodeAccount__c>();
        lstXA.add(new XcodeAccount__c(
            Account__c = accountList[0].Id,
            Xcode__c = xc.Id
        ));
        lstXA.add( new XcodeAccount__c(
            Account__c = accountList[1].Id,
            Xcode__c = xc.Id
        ));
        lstXA.add( new XcodeAccount__c(
            Account__c = accountList[2].Id,
            Xcode__c = xc.Id
        ));
        insert lstXA;
        //AccountCleanInfo aci = new AccountCleanInfo( AccountId =accountList[2].Id ,isDifferentStreet =true);
        //insert aci;
        System.runAs(testUser){
            Test.startTest();
                accountList[2].DomesticHQAccount__c = accountList[0].Id;
                accountList[2].GlobalHQAccount__c = accountList[1].Id;
                accountList[2].Primary_Xcode__c = 'Test 5';
                accountList[2].PrimaryServiceRep__c = UserInfo.getUserId();
                accountList[1].PrimaryServiceRep__c = testUser.Id;
                AccountTriggerHandler.RunCount =0;
                AccountTriggerHandler.ExecuteTriggers = true; 
                update accountList[2];
            Test.stopTest();
        }
    }
    
    static testMethod void testInsertCustomerNumberforAccounts(){
        WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c();
        endpoint.Endpoint__c = 'USPS Integration';
        endpoint.Name = 'USPS Integration';
        insert endpoint;
        
        IntegrationConfig__c integSett = TestDataSetupUtility.buildIntegrationConfigSetting();
        integSett.Name = 'USPS Integration';
        integSett.EndpointName__c = endpoint.Name;
        integSett.PaypalRedirectURL__c = endpoint.Endpoint__c;
        insert integSett;
        
        Test.startTest();
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User testUser = TestDataSetupUtility.createTestUser('Integration', 'MAPP', adminProfile.Id);
        testUser.FirstName = 'Integration';
        testUser.LastName = 'MAPP';
        insert testUser;
        /*Personal_Settings__c persSett = TestDataSetupUtility.buildPersonalSetting();
        persSett.Trigger_Account__c = true;
        insert persSett;*/
        Account testAccount = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        System.runAs(testUser){
            system.assertEquals(UserInfo.getName() , 'Integration MAPP');
            testAccount.Organization__c = 'Europe';
            testAccount.Account_Type__c = 'Staffing';
            testAccount.AccountStatus__c = 'Candidate';
            testAccount.RegistrationNumber__c = '55433434';
            insert testAccount;
            Account testAccount2 = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account2');
            testAccount2.RegistrationNumber__c = '55433434';
            insert testAccount2;
            
        }
        testAccount.AccountStatus__c = 'Candidate';
        update testAccount;
        AccountTriggerHandler.RunCount =0;
        AccountTriggerHandler.ExecuteTriggers = true;       
        testAccount.AccountStatus__c = 'Customer';
        try{
            update testAccount;
        }catch(Exception e){}
        
        Test.stopTest();
    }  

    static testMethod void testMethod_populateprimaryAgencyContact(){
        WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c();
        endpoint.Endpoint__c = 'USPS Integration';
        endpoint.Name = 'USPS Integration';
        insert endpoint;
        
        IntegrationConfig__c integSett = TestDataSetupUtility.buildIntegrationConfigSetting();
        integSett.Name = 'USPS Integration';
        integSett.EndpointName__c = endpoint.Name;
        integSett.PaypalRedirectURL__c = endpoint.Endpoint__c;
        insert integSett;
        //build personal settings
        /*Personal_Settings__c persSett = TestDataSetupUtility.buildPersonalSetting();
        persSett.Send_Emails__c = true;
        persSett.Trigger_Account__c = true;
        insert persSett;
*/
        Org_Settings__c orgSetting = new Org_Settings__c();
        orgSetting.Fraud_Profile_Name__c = 'System Administrator';
        orgSetting.Generic_Fraud_User_Id__c = userinfo.getUserId();
        insert orgSetting;
        
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User testUser = TestDataSetupUtility.createTestUser('Generic', 'Generic', adminProfile.Id);
        testUser.FirstName = 'Generic';
        insert testUser;

        list<Account> accountList = new list<Account>();
        accountList.add( TestDataSetupUtility.createTestAccountWithShippingAndBilling('Parent Account2'));
        accountList[0].DunsNumber = '21232332';
        accountList[0].MAPP_Country__c = 'IT';
        accountList[0].CreatedDate = System.now();

        accountList.add( TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Agency Account 1'));
        accountList[1].ParentId = accountList[0].Id; 
        accountList[1].AgencyFlag__c = true;
        accountList[1].MAPP_Country__c = 'DK';
        accountList[1].RegistrationNumber__c = '55433434';
        accountList[1].CreatedDate = System.now();

        insert accountList;
        
        RelatedPartner__c relatedPrtner = TestDataSetupUtility.createTestRelatedPartner(accountList[0].Id, accountList[1].Id);
        insert relatedPrtner;
        
        System.runAs(testUser){
            
            Test.startTest();
                Account acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('New Related Partner Account');
                acc.ParentId = accountList[1].Id; 
                acc.MAPP_Country__c = 'SE';
                acc.CreatedDate = System.now();
                acc.PrimaryRelatedAgency__c = relatedPrtner.Id;
                acc.AccountStatus__c = 'Fraud';
                acc.DomesticHQAccount__c = accountList[0].Id;
                acc.GlobalHQAccount__c = accountList[1].Id;
                AccountTriggerHandler.RunCount =0;
                //AccountTriggerHandler.ExecuteTriggers = true;  
                insert acc;
            Test.stopTest();
        }
    }
    
    @isTest
    static void testIntegrationOrder() {
        User integrationUser = TestDataSetupUtility.createUser('System Administrator',false); 
        integrationUser.FirstName= 'Integration';
        integrationUser.LastName = 'MAPP';
        User user2 = TestDataSetupUtility.createUser('System Administrator',false); 
        insert new List<User>{user2,integrationUser}; 
        
        Payment_Details__c paymentDetails = TestDataSetupUtility.createTestPaymentDetails('Asia Pacific' , 'Monthly', 'Net 10');
        paymentDetails.PaymentMethod__c = 'Invoice';
        paymentDetails.Active__c  = true;
        insert paymentDetails;
        PaymentDetails__c paymentDet = new PaymentDetails__c ();
        paymentDet.Name = 'Asia Pacific';
        paymentDet.Id__c = paymentDetails.Id;
        insert paymentDet;
        
        /*Personal_Settings__c  personalSettings = TestDataSetupUtility.buildPersonalSetting();
        personalSettings.Trigger_Account__c = true;
        insert personalSettings;
        */
       Account acc = TestDataSetupUtility.createTestAccount('Test Account', 'North America', UserInfo.getUserId());
       acc.Partner_Flag__c = true;
       acc.AgencyFlag__c = true;
       //insert acc;
        
        Account acc1 = TestDataSetupUtility.createTestAccount('Test 123 Account', 'Asia Pacific', UserInfo.getUserId());
        acc1.Phone = '1234567891';
        acc1.ShippingStreet = 'Red S';
        acc1.ShippingCity = 'NY';
        acc1.ShippingPostalCode = '12345';
        acc1.Website = 'www.abc1.com';
        acc1.Phone = '4534445344';
        acc1.AccountStatus__c = 'Customer';
        acc1.DunsNumber = '232332';
        Account acc2 = TestDataSetupUtility.createTestAccount('Test 123 Account2', 'Europe', UserInfo.getUserId());
        System.runAs(integrationUser){
            Test.startTest();
            insert new List<Account>{acc,acc1,acc2};
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Oppty' , acc.id);
            insert opp;
            
            Contact con1 = TestDataSetupUtility.createTestContact(acc1.id,'test','Con','aon122@gmail.com'); 
            insert con1;
            
            Order__c ord = TestDataSetupUtility.createOrder(acc1.Id, con1.Id);
            ord.OrderStatus__c = 'Open';
            //ord.QuoteProposal__c = proposal.id;
            ord.AccountOrganization__c = 'North America';
            ord.opportunity__c = opp.id;
            ord.CR_Status_Comment__c = 'testing Comments';
            ord.Approval_Status__c = 'Re-Open';
            ord.ShippingContact__c = con1.Id;
            ord.BillingAccount__c = acc1.id;
            ord.Agency__c = acc1.Id;
            ord.Account__c = acc1.Id;
            ord.MAPP_Payment_Frequency__c = 'Invoice';
            ord.OrderStatus__c = 'Verified';
            //ord.StartDate__c = Date.today();
            insert ord;
            Order_Line_Item__c oli = TestDataSetupUtility.createOrderLineItem(ord.Id);
            insert oli;
            acc1.OwnerId = user2.Id;
            acc1.ParentId = acc.Id;
            acc1.DunsNumber = null;
            AccountTriggerHandler.RunCount =0;
            AccountTriggerHandler.ExecuteTriggers = true; 
            update acc1;
            acc1.ParentId = null;
            AccountTriggerHandler.RunCount =0;
            AccountTriggerHandler.ExecuteTriggers = true; 
            update acc1;
            Test.StopTest();
        }
   }
   @isTest
    static void testsendemail() {
        /*Personal_Settings__c  personalSettings = TestDataSetupUtility.buildPersonalSetting();
        personalSettings.Trigger_Account__c = true;
        insert personalSettings;*/
        User usr = [Select Id from User Where Id = :UserInfo.getUserId()];
        System.runAs(usr) {
        List<Account> accList = new List<Account>();
        //accList.add(TestDataSetupUtility.createTestAccount('Test Account', 'North America', UserInfo.getUserId()));
        accList.add(TestDataSetupUtility.createPersonAccount());
        accList.add(TestDataSetupUtility.createTestAccount('Test Account2', 'North America', UserInfo.getUserId()));
        //accList[0].RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Account', 'Person Account');
        
        List<Case> caseList = new List<Case>();
        caseList.add(TestDataSetupUtility.createTestNewAccountRequestCase('North America',UserInfo.getUserId()));
        caseList[0].RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Case', 'New Account Request');
        caseList.add(TestDataSetupUtility.createTestNewAccountRequestCase('North America',UserInfo.getUserId()));
        caseList[1].RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Case', 'New Account Request');
        caseList.add(TestDataSetupUtility.createTestNewAccountRequestCase('North America',UserInfo.getUserId()));
        insert caseList;
        caseList[2].ownerId = UserInfo.getUserId();
        update caseList[2];
        accList[0].Related_Case__pc = caseList[2].id;
        accList[0].FirstName = 'Test';
        accList[0].LastName = 'Account';
        insert accList;
        caseList[0].AccountID = accList[0].Id;
        caseList[1].AccountID = accList[1].Id;
        update caseList;
        Test.startTest();
         accList[0].Lead_Account_Status__c = 'Active';
        accList[1].Lead_Account_Status__c = 'Rejected';
        
        AccountTriggerHandler.ExecuteTriggers = true; 
        AccountTriggerHandler.RunCount =0;
        
        update accList;
        Test.stopTest(); 
        
        }
    } 
    
    @isTest
    static void testAccParent() {
        /*Personal_Settings__c  personalSettings = TestDataSetupUtility.buildPersonalSetting();
        personalSettings.Trigger_Account__c = true;*/
        Payment_Details__c paymentDetails = TestDataSetupUtility.createTestPaymentDetails('Europe' , 'Monthly', 'Net 10');
        paymentDetails.PaymentMethod__c = 'Invoice';
        paymentDetails.Set_as_Default_for__c = 'Europe';
        paymentDetails.Active__c  = true;
        insert paymentDetails;
        PaymentDetails__c paymentDet = new PaymentDetails__c ();
        paymentDet.Name = 'Europe';
        paymentDet.Id__c = paymentDetails.Id;
        insert paymentDet;
        
        Program__c program = TestDataSetupUtility.createAccountProgram('Test Prog');
        insert program ;
        List<Account> accList = new List<Account>();
        //insert personalSettings;
        Test.startTest();
        Account acc = TestDataSetupUtility.createTestAccount('John', 'Europe', UserInfo.getUserId());
        //acc.ShippingCountry__c = 'Austria';
        //insert acc;
        accList.add(TestDataSetupUtility.createTestAccount('Test Account2', 'Europe', UserInfo.getUserId()));
        accList.add(TestDataSetupUtility.createTestAccount('Test Account3', 'Europe', UserInfo.getUserId()));
        accList.add(TestDataSetupUtility.createTestAccount('Test Account4', 'Europe', UserInfo.getUserId()));
        //accList.add(TestDataSetupUtility.createTestAccount('Test Account2', 'Europe', UserInfo.getUserId()));
        
            
        
        accList[1].AccountProgram__c = program.Id; 
        //accList[1].ParentId = acc.Id; 
        insert accList;
        
        accList[0].ParentId = accList[1].Id; 
        AccountTriggerHandler.ExecuteTriggers = true; 
        AccountTriggerHandler.RunCount =0;
        
        update accList[0];
        
        accList[1].ParentId = accList[2].Id; 
        AccountTriggerHandler.ExecuteTriggers = true; 
        AccountTriggerHandler.RunCount =0;
        
        update accList[1];
        Test.stopTest();
    } 
}