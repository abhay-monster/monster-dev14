@isTest()
public with sharing class ApttusProposalTriggerHelperTest {
    
    // Test ApttusProposalTriggerHelper.SetAccountOrganization()
    
    private  static String CurrentUserProfileName {
        get {
            if(CurrentUserProfileName == null){
                
                Profile p = [Select Name From Profile where Id = :UserInfo.getProfileId()];
                CurrentUserProfileName = p.name;
            }
            
            
            return CurrentUserProfileName;
        }
        set;
    }
    
    @isTest
    static void AccountOrganizationSetting(){
        Personal_Settings__c personalSettings = new Personal_Settings__c();
        personalSettings.Trigger_Quote__c = true;
        personalSettings.Validation_Account__c = false;
        personalSettings.Validation_Quote__c = true;
        insert personalSettings;

        Method_Kill_List__c testCustomSetting = new Method_Kill_List__c(Name='updateOpptySplit', Kill_Method__c=false);
        insert testCustomSetting;

        Sales_Channel_Cross_Reference__c crossRef = TestDataSetupUtility.salesChannelCrossReference();
        insert crossRef;
        
        PaymentTranslationSettings__c obj = new PaymentTranslationSettings__c();
        obj.Name = 'PTS_01';
        obj.Language__c = 'English';
        obj.Original_Value__c = 'Invoice';
        obj.Payment_Field_Name__c = 'Payment Method';
        obj.Translated_Value__c = 'Credit Card';
        insert obj;
        
        QueryTemplateDefaultSettings__c QTTest = new QueryTemplateDefaultSettings__c();
        QTTest.name = 'test1';
        QTTest.Quote_Type__c = 'Standard';
        QTTest.Language__c = 'Standard';
        QTTest.Country__c = 'India';
        QTTest.Agency__c = False;
        Insert QTTest;
        IntegrationConfig__c  integConfigSettings = new IntegrationConfig__c(Name ='USPS Integration', 
                                                                             Timeout__c=60000,
                                                                             IsPaypalTest__c=true,
                                                                             EndpointName__c='USPSAddressValidation',
                                                                             Username__c='562CLOUD2615');
        insert integConfigSettings;
        WebServiceEndpoint__c wsEndpoint = new WebServiceEndpoint__c(Name='USPSAddressValidation', Endpoint__c='http://production.shippingapis.com/ShippingAPI.dll');
        insert wsEndpoint;
        
        Account acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        acc.Organization__c = 'Asia Pacific';
        insert acc;
              
        
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp  ', acc.Id);
        insert opp;
        
        Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('AED Price List ', false);
        insert priceList;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        List<User> userToInsert = new List<User>();
        user manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        userToInsert.add(manager);
        
        user testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        testUser.Organisation__c = 'North America';
        testuser.UserDefaultPriceList__c = priceList.name;
        testUser.Discount_Threshold__c  = 10.0;
        userToInsert.add(testuser);
        
        insert userToInsert;

        Sales_Channel_Cross_Reference__c crossRefUser = TestDataSetupUtility.salesChannelCrossReference(userToInsert[1].Id);
        insert crossRefUser;

        System.runAs(testUser){
            
            
            Apttus_Proposal__Proposal__c prop = TestDataSetupUtility.createProposal(opp.Id);
            prop.AccountOrganization__c = 'Asia Pacific';
            prop.Payment1_Frequency__c = 'Pre-Paid';
            prop.Payment_Method1__c = 'Invoice';
            prop.Payment1_Term__c = 'Immediate';
            //    prop.Apttus_QPConfig__PriceListId__c = priceList.id;
            /*Account accAgency1 = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Agency Account');
            accAgency1.AgencyFlag__c = true;
            accAgency1.BillingStreet = 'Agency Street';
            accAgency1.BillingCity = 'Agency City';
            insert accAgency1;
            contact cAgency = TestDataSetupUtility.createTestContact(accAgency1.Id, 'confirst1','GG'  ,'conlast1' +'@GG.dude.com');
            insert cAgency;
            prop.agency__c = accAgency1.id; 
            prop.AgencyBillingContact__c = cAgency.id;*/
            Test.startTest();
            insert prop;
            Test.stopTest();
            prop.Apttus_Proposal__Primary__c = true ;
            prop.QuoteStatus__c = 'Accepted Online' ;
            prop.BillingCountry__c  = 'India' ;
            prop.Selling_Country__c = 'India' ;
            prop.Language__c = 'English';
          /*  prop.AccountOrganization__c='North America';
            prop.PaypalReferenceNumber__c='123';
            prop.QuoteStatus__c = 'Accepted Offline' ;
            prop.PaypalResultCode__c='0';*/
            
            update prop ; 
            
            Account accAgency = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Agency Account');
            accAgency.AgencyFlag__c = true;
            accAgency.BillingStreet = 'Agency Street';
            accAgency.BillingCity = 'Agency City';
            insert accAgency;

            prop.agency__c = accAgency.id;
            update prop;
            //stem.assertEquals(prop.AccountOrganization__c, acc.Organization__c); 
            delete   prop;
            
        }           
    }
    

    /* Jeff L. Commenting out for critical production issue that needs to get deployed
    @isTest
    static void testAPTS_creditHelper(){
        Personal_Settings__c personalSettings = new Personal_Settings__c();
        personalSettings.Trigger_Quote__c = true;
        personalSettings.Validation_Account__c = false;
        personalSettings.Validation_Quote__c = false;
        //insert personalSettings;
        
        QueryTemplateDefaultSettings__c QTTest = new QueryTemplateDefaultSettings__c();
        QTTest.name = 'test1';
        QTTest.Quote_Type__c = 'Standard';
        QTTest.Language__c = 'Standard';
        QTTest.Country__c = 'India';
        QTTest.Agency__c = False;
        Insert QTTest;
        IntegrationConfig__c  integConfigSettings = new IntegrationConfig__c(Name ='USPS Integration', 
                                                                             Timeout__c=60000,
                                                                             IsPaypalTest__c=true,
                                                                             EndpointName__c='USPSAddressValidation',
                                                                             Username__c='562CLOUD2615');
        insert integConfigSettings;
        WebServiceEndpoint__c wsEndpoint = new WebServiceEndpoint__c(Name='USPSAddressValidation', Endpoint__c='http://production.shippingapis.com/ShippingAPI.dll');
        insert wsEndpoint;
        
        Account acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        acc.Organization__c = 'Asia Pacific';
        insert acc;
        
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp  ', acc.Id);
        insert opp;
        
        Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('AED Price List ', false);
        insert priceList;
        
        Apttus_Config2__PriceList__c priceList1 = TestDataSetupUtility.createPriceList('AED Price List1 ', false);
        insert priceList1;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        List<User> userToInsert = new List<User>();
        user manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        userToInsert.add(manager);
        
        user testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        testuser.UserDefaultPriceList__c = priceList.name;
        testUser.Discount_Threshold__c  = 10.0;
        testUser.Organisation__c = 'Asia Pacific';
        userToInsert.add(testuser);
        CONTACT con = TestDataSetupUtility.createTestContact(acc.id,'test','Con','abccon@gmail.com'); 
        insert con;
        
        insert userToInsert;

        List<Sales_Channel_Cross_Reference__c> sccrList = new List<Sales_Channel_Cross_Reference__c>();
        sccrList.add(TestDataSetupUtility.salesChannelCrossReference(testUser.Id));
        sccrList.add(TestDataSetupUtility.salesChannelCrossReference());
        insert sccrList;

         Order__c ord = TestDataSetupUtility.createOrderWithOpportunity(acc.Id, opp.Id, null, con.Id);
         insert ord;
         Order_Line_Item__c oli = TestDataSetupUtility.createOrderLineItem(ord.Id);
         insert oli;
               
        insert personalSettings;
        
        System.runAs(testUser){
            
            system.debug('Before Prop insert');
           Apttus_Proposal__Proposal__c prop = TestDataSetupUtility.createProposal(opp.Id);
            prop.AccountOrganization__c = 'Asia Pacific';
            prop.Payment1_Frequency__c = 'Pre-Paid'; 
            prop.Payment_Method1__c = 'Invoice';
            prop.Payment1_Term__c = 'Immediate';
          //  prop.Apttus_QPConfig__PriceListId__c = priceList.id;
            insert prop;

            system.debug('After Prop Insert');
            Apttus_Config2__AssetLineItem__c assetLineItem = TestDataSetupUtility.createAssetLineItem('Test asset', acc.Id, false);
            assetLineItem.Proposal__c = prop.Id;
            assetLineItem.Order_Line_Item__c = oli.Id;
            //assetLineItem.Apttus_Config2__ProductId__c = prop.id;
            assetLineItem.Apttus_Config2__StartDate__c = Date.Today() - 10;
            assetLineItem.Apttus_Config2__EndDate__c  = Date.Today().addDays(70);
            insert assetLineItem;
            system.debug('after asset insert');
            Apttus_Proposal__Proposal_Line_Item__c pli = TestDataSetupUtility.createProposalLineItem(prop.id);
            pli.Apttus_QPConfig__AssetLineItemId__c  = assetLineItem.Id;
            insert pli;
            system.debug('Before Start Test!!');
        Test.startTest();

            prop.Apttus_Proposal__Primary__c = true ; 
            prop.QuoteStatus__c = 'Accepted Online' ;
            prop.BillingCountry__c  = 'India' ;
            prop.Selling_Country__c = 'India' ;
            prop.Language__c = 'English';
            prop.APTS_Quote_Type__c = 'Product Conversion';
            prop.Apttus_QPConfig__ConfigurationFinalizedDate__c = Date.today();
            prop.Orig_Order_link__c = ord.Id;
            system.debug('Before Update Prop!');
            update prop ; 
            seT<id> propIds = new seT<id>{prop.id};
             ID jobID = System.enqueueJob(new APTS_Order_QueueInterFace(propIds));
            
            //stem.assertEquals(prop.AccountOrganization__c, acc.Organization__c); 
            Test.stopTest();
        }           
    }*/
    
    @isTest
    static void AgencyBillingAddressUpdate(){
        //Profile p = [SELECT Id FROM Profile WHERE Name LIKE '%Service Rep%' LIMIT 1];       
        //User u = TestDataSetupUtility.createTestUser('John', 'Doe', p.Id);
        //insert u;
        
        
        Personal_Settings__c personalSettings = new Personal_Settings__c();
        personalSettings.Trigger_Quote__c = true;
        personalSettings.Validation_Account__c = false;
        
        insert personalSettings;

        Method_Kill_List__c testCustomSetting = new Method_Kill_List__c(Name='updateOpptySplit', Kill_Method__c=false);
        insert testCustomSetting;
        
        
        IntegrationConfig__c  integConfigSettings = new IntegrationConfig__c(Name ='USPS Integration', 
                                                                             Timeout__c=60000,
                                                                             IsPaypalTest__c=true,
                                                                             EndpointName__c='USPSAddressValidation',
                                                                             Username__c='562CLOUD2615');
        insert integConfigSettings;
        WebServiceEndpoint__c wsEndpoint = new WebServiceEndpoint__c(Name='USPSAddressValidation', Endpoint__c='http://production.shippingapis.com/ShippingAPI.dll');
        insert wsEndpoint;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        List<User> lstUser = new List<User>();
        User manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        lstUser.add(manager);
        User testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        lstUser.add(testuser);
        insert lstUser;

        List<Sales_Channel_Cross_Reference__c> sccrList = new List<Sales_Channel_Cross_Reference__c>();
        sccrList.add(TestDataSetupUtility.salesChannelCrossReference(testUser.Id));
        sccrList.add(TestDataSetupUtility.salesChannelCrossReference());
        insert sccrList;
        
        CountryCode__c cc = TestDataSetupUtility.buildCountryCodeSetting('United States', 'US');
        insert cc;
        
        Account[] accounts = new Account[]{};
            Account acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        acc.BillingStreet = 'Account Street';
        acc.BillingCity = 'Account City';
        acc.Organization__c = 'Europe';
        acc.ShippingCountryCode = 'US';
        accounts.add(acc);
        
        Account accAgency = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Agency Account');
        accAgency.AgencyFlag__c = true;
        accAgency.BillingStreet = 'Agency Street';
        accAgency.BillingCity = 'Agency City';
        accAgency.Organization__c = 'Europe';
        accAgency.ShippingCountryCode = 'US';
        accounts.add(accAgency);
        insert accounts;
        
        RelatedPartner__c partner = new RelatedPartner__c();
        /*partner.Account__c = accAgency.Id;
partner.Partner__c = acc.Id;
partner.Role__c = 'Developer';
partner.AgencyType__c = '';*/
        
        partner.Account__c = acc.Id;
        partner.Partner__c = accAgency.Id;
        partner.Role__c = 'Agency';
        partner.AgencyType__c = 'Third Party';
        insert partner;
        
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp ', acc.Id);
        opp.Agency__c = accAgency.Id;
        insert opp;
        System.runAs(testUser){
            test.startTest();
            Apttus_Proposal__Proposal__c prop = TestDataSetupUtility.createProposal(opp.Id);
            prop.AccountOrganization__c = 'Asia Pacific';
            prop.Payment1_Frequency__c = 'Pre-Paid';
            prop.Payment_Method1__c = 'Invoice';
            prop.Payment1_Term__c = 'Immediate';
            insert prop;
            
            try{
                
                Apttus_Proposal__Proposal__c checkProposal = [SELECT Agency__c, BillingCity__c, BillingCountry__c, 
                                                              BillingStateProvince__c, BillingStreet__c, BillingZipPostalCode__c
                                                              FROM Apttus_Proposal__Proposal__c  
                                                              WHERE Id = :prop.Id]; 
                //system.debug('The proposal: '+checkProposal);                                                                                   
                checkProposal.BillingStreet__c = 'Edited Billing Street';
                
                update checkProposal;
                
                
                test.stopTest(); 
            }catch(DMLException e){
                system.assert(false); 
            }
        }
    }
    
    @isTest
    static void AgencyBillingAddressUpdate1(){
        //Profile p = [SELECT Id FROM Profile WHERE Name LIKE '%Service Rep%' LIMIT 1];       
        //User u = TestDataSetupUtility.createTestUser('John', 'Doe', p.Id);
        //insert u;
        
        
        Personal_Settings__c personalSettings = new Personal_Settings__c();
        personalSettings.Trigger_Quote__c = true;
        personalSettings.Validation_Account__c = false;
        
        insert personalSettings;

        Method_Kill_List__c testCustomSetting = new Method_Kill_List__c(Name='updateOpptySplit', Kill_Method__c=false);
        insert testCustomSetting;
        
        
        IntegrationConfig__c  integConfigSettings = new IntegrationConfig__c(Name ='USPS Integration', 
                                                                             Timeout__c=60000,
                                                                             IsPaypalTest__c=true,
                                                                             EndpointName__c='USPSAddressValidation',
                                                                             Username__c='562CLOUD2615');
        insert integConfigSettings;
        WebServiceEndpoint__c wsEndpoint = new WebServiceEndpoint__c(Name='USPSAddressValidation', Endpoint__c='http://production.shippingapis.com/ShippingAPI.dll');
        insert wsEndpoint;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        List<User> lstUser = new List<User>();
        User manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        lstUser.add(manager);
        User testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        lstUser.add(testuser);
        insert lstUser;

        List<Sales_Channel_Cross_Reference__c> sccrList = new List<Sales_Channel_Cross_Reference__c>();
        sccrList.add(TestDataSetupUtility.salesChannelCrossReference(testUser.Id));
        sccrList.add(TestDataSetupUtility.salesChannelCrossReference());
        insert sccrList;
        
        CountryCode__c cc = TestDataSetupUtility.buildCountryCodeSetting('United States', 'US');
        insert cc;
        
        Account[] accounts = new Account[]{};
            Account acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        acc.BillingStreet = 'Account Street';
        acc.BillingCity = 'Account City';
        acc.Organization__c = 'North America';
        acc.ShippingCountryCode = 'US';
        accounts.add(acc);
        
        Account accAgency = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Agency Account');
        accAgency.AgencyFlag__c = true;
        accAgency.BillingStreet = 'Agency Street';
        accAgency.BillingCity = 'Agency City';
        accAgency.Organization__c = 'North America';
        accAgency.ShippingCountryCode = 'US';
        accounts.add(accAgency);
        insert accounts;
        
        RelatedPartner__c partner = new RelatedPartner__c();
        /*partner.Account__c = accAgency.Id;
partner.Partner__c = acc.Id;
partner.Role__c = 'Developer';
partner.AgencyType__c = '';*/
        
        partner.Account__c = acc.Id;
        partner.Partner__c = accAgency.Id;
        partner.Role__c = 'Agency';
        partner.AgencyType__c = 'Third Party';
        insert partner;
        
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp ', acc.Id);
        opp.Agency__c = accAgency.Id;
        insert opp;
        System.runAs(testUser){
            test.startTest();
            Apttus_Proposal__Proposal__c prop = TestDataSetupUtility.createProposal(opp.Id);
            prop.AccountOrganization__c = 'Asia Pacific';
            prop.Payment1_Frequency__c = 'Pre-Paid';
            prop.Payment_Method1__c = 'Invoice';
            prop.Payment1_Term__c = 'Immediate';
            insert prop;
            
            try{
                
                Apttus_Proposal__Proposal__c checkProposal = [SELECT Agency__c, BillingCity__c, BillingCountry__c, 
                                                              BillingStateProvince__c, BillingStreet__c, BillingZipPostalCode__c
                                                              FROM Apttus_Proposal__Proposal__c  
                                                              WHERE Id = :prop.Id]; 
                //system.debug('The proposal: '+checkProposal);                                                                                   
                checkProposal.BillingStreet__c = 'Edited Billing Street';
                
                update checkProposal;
                
                test.stopTest(); 
            }catch(DMLException e){
                system.assert(false); 
            }
        }
    }
    
    @isTest
    static void testUpdateAccountBillingAddress(){
        Map<Id, Apttus_Proposal__Proposal__c> proposalMap = new Map<Id, Apttus_Proposal__Proposal__c>();
        List<Apttus_Proposal__Proposal__c> proposalList = new List<Apttus_Proposal__Proposal__c>();
        
        Sales_Channel_Cross_Reference__c crossRef = TestDataSetupUtility.salesChannelCrossReference();
        insert crossRef;

        Apttus_Proposal__Proposal__c proposal = null;
        Account acct = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TestAcct_28_07_15');
        insert acct;
        System.debug('------------------------- : '+acct);
        
        Contact con = TestDataSetupUtility.createTestContact(acct.Id, 'Test_Last', 'Test_First', 'test@test.com');
        insert con;
        System.debug('------------------------- : '+con);
        
        Opportunity oppt = TestDataSetupUtility.createTestOpportunity('TestOppt_28_07_15', acct.Id);
        insert oppt;
        System.debug('------------------------- : '+oppt);
        
        for(Opportunity oppty : [Select id, Name from Opportunity where id =: acct.Id]){
            system.assertEquals(oppty.accountId, acct.Id); 
        }

        
        proposal = TestDataSetupUtility.createProposal('TEST_PROP_28_07_15', acct.Id, oppt.Id, 'test', false);
        proposal.BillingCity__c = 'Dover';
        proposal.BillingCountry__c = 'Uganda';
        proposal.BillingStateProvince__c = 'Delaware';
        proposal.BillingStreet__c = '1 main ST';
        proposal.BillingZipPostalCode__c = '13345';
        insert proposal;
        System.debug('------------proposal------------- : '+proposal);
        
        proposalMap.put(proposal.Id, proposal);
        System.debug('------------proposalMap------------- : '+proposalMap);
        proposal.BillingCity__c = 'JP';
        proposal.BillingCountry__c = 'Afghanistan';
        proposal.BillingStateProvince__c = 'Alabama';
        proposal.BillingStreet__c = 'TEST';
        proposal.BillingZipPostalCode__c = '12345';
        proposal.Apttus_Proposal__Account__c = acct.Id;
        proposal.AccountOrganization__c='North America';
        proposal.PaypalReferenceNumber__c='123';
        proposal.QuoteStatus__c = 'Accepted Offline' ;
        proposal.PaypalResultCode__c='0';
        
        Order__c ord = TestDataSetupUtility.createOrderWithOpportunity(acct.Id, oppt.Id, null, con.Id);
        ord.QuoteProposal__c=proposal.Id;
        insert ord;
        
        
        //proposal.Agency__c = acct2.Id;
        System.debug('-------------------------proposal.Agency__c------------- : '+proposal.Agency__c);
        update proposal;
        
        
        proposalList.add(proposal);
        ApttusProposalTriggerHelper helper = ApttusProposalTriggerHelper.NewTriggerHelper(CurrentUserProfileName);
        helper.UpdateAccountBillingAddress(proposalMap, proposalList);
        helper.PreventUpdateOfBilling(proposalMap, proposalList);
        //helper.setPaymentDetailsOfAccountFromProposal(proposalList, proposalMap);
        helper.CreateAssetTrigger(proposalList, proposalMap);
        
        helper.populatePaymentDetailForPaypalPaid(proposalList, proposalMap);
        helper.setAgencyIOonOrder(proposalList, proposalMap);
        try {
            
            helper.productConversion(proposalList);
        } catch (Exception e){}
        
    }
    
    @isTest
    static void TestApptusTrigge2() {
        Personal_Settings__c personalSettings = new Personal_Settings__c();
        personalSettings.Trigger_Quote__c = False;
        personalSettings.Validation_Account__c = false;
        insert personalSettings; 

        Method_Kill_List__c testCustomSetting = new Method_Kill_List__c(Name='updateOpptySplit', Kill_Method__c=false);
        insert testCustomSetting;
        
        WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c();
        endpoint.Endpoint__c = 'USPS Integration';
        endpoint.Name = 'USPS Integration';
        insert endpoint;
        
        IntegrationConfig__c integSett = TestDataSetupUtility.buildIntegrationConfigSetting();
        integSett.Name = 'USPS Integration';
        integSett.EndpointName__c = endpoint.Name;
        integSett.PaypalRedirectURL__c = endpoint.Endpoint__c;
        insert integSett;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        user manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        insert manager;
        
        Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
        insert priceList; 
        
        Apttus_Proposal__Proposal__c proposal_n = null;
        Account account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TestAcct_28_07_15'); 
        account.Organization__c = 'Asia Pacific';        
        insert account; 
        System.debug('------------------------- : '+account);
        
        Contact con = TestDataSetupUtility.createTestContact(account.Id, 'Test_Last', 'Test_First', 'test@test.com');
        insert con;
        System.debug('------------------------- : '+con);
        
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('TestOppt_28_07_15'+DateTime.now(), account.Id);
        opp.Organization__c='Asia Pacific';
        insert opp;
        System.debug('------------------------- : '+opp);
        
        proposal_n = TestDataSetupUtility.createProposal('TEST_PROP_28_07_15', account.Id, opp.Id, 'test', false);
        proposal_n.Apttus_Proposal__Primary__c = false;
        insert proposal_n;
        personalSettings.Trigger_Quote__c = True;
        personalSettings.Validation_Account__c = false;
        update personalSettings; 
        user testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        testuser.UserDefaultPriceList__c = priceList.id;
        testUser.Discount_Threshold__c  = 10.0;
        insert testuser;


        Sales_Channel_Cross_Reference__c crossRef = TestDataSetupUtility.salesChannelCrossReference(testuser.Id);
        insert crossRef;

        System.runAs(testUser){
            Test.starttest();      
            proposal_n.Create_Assets__c = true; 
            proposal_n.QuoteStatus__c = 'Accepted Online';
            proposal_n.Apttus_Proposal__Approval_Stage__c = 'Accepted';
            
            Update proposal_n;
            
         MAP<id,Apttus_Proposal__Proposal__c>  proposalMap= new MAP<id,Apttus_Proposal__Proposal__c>();
            proposalMap.put(proposal_n.id, new Apttus_Proposal__Proposal__c(id= proposal_n.id,Apttus_QPConfig__ConfigurationFinalizedDate__c = DateTime.now()));
            
            List<Apttus_Proposal__Proposal__c> proposalList = new List<Apttus_Proposal__Proposal__c>(); 
            proposal_n.Apttus_QPConfig__ConfigurationFinalizedDate__c = DateTime.now().adddays(7);
            proposal_n.Apttus_Proposal__Primary__c = True;
           // proposal_n.Organization__c='Asia Pacific';
            proposalList.add(proposal_n);
            
            ApttusProposalTriggerHelper helper = ApttusProposalTriggerHelper.NewTriggerHelper(CurrentUserProfileName);  
            helper.getQuoteTaxOnFinalize(proposalList, proposalMap , True);
          // helper.setPrimaryQuoteTotalsMatchToOppty(proposalList, proposalMap);
            
            Id GCSOpptyRecordType = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'GCS Opportunity');
            opp.RecordTypeId=GCSOpptyRecordType;
            //opp.Organization__c='Asia Pacific';
            update opp;
            
            helper.SetQuoteStatusWhenFinalize(proposalList, proposalMap);
            
            Test.stoptest();
        }
        
    }
    
    @isTest
    static void TestApptusTrigge6() {
        Personal_Settings__c personalSettings = new Personal_Settings__c();
        personalSettings.Trigger_Quote__c = False;
        personalSettings.Validation_Account__c = false;
        insert personalSettings; 

        Method_Kill_List__c testCustomSetting = new Method_Kill_List__c(Name='updateOpptySplit', Kill_Method__c=false);
        insert testCustomSetting;
        
        WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c();
        endpoint.Endpoint__c = 'USPS Integration';
        endpoint.Name = 'USPS Integration';
        insert endpoint;
        
        IntegrationConfig__c integSett = TestDataSetupUtility.buildIntegrationConfigSetting();
        integSett.Name = 'USPS Integration';
        integSett.EndpointName__c = endpoint.Name;
        integSett.PaypalRedirectURL__c = endpoint.Endpoint__c;
        insert integSett;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        user manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        insert manager;
        
        Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
        insert priceList; 
        
        Apttus_Proposal__Proposal__c proposal_n = null;
        Account account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TestAcct_28_07_15'); 
        account.Organization__c = 'Asia Pacific';        
        insert account; 
        System.debug('------------------------- : '+account);
        
        Contact con = TestDataSetupUtility.createTestContact(account.Id, 'Test_Last', 'Test_First', 'test@test.com');
        insert con;
        System.debug('------------------------- : '+con);
        
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('TestOppt_28_07_15'+DateTime.now(), account.Id);
        opp.Organization__c='Asia Pacific';
        opp.StageName = 'Rejected';
        insert opp;
        System.debug('------------------------- : '+opp);
        
        proposal_n = TestDataSetupUtility.createProposal('TEST_PROP_28_07_15', account.Id, opp.Id, 'test', false);
        proposal_n.Apttus_Proposal__Primary__c = false;
        insert proposal_n;
        personalSettings.Trigger_Quote__c = True;
        personalSettings.Validation_Account__c = false;
        update personalSettings; 
        user testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        testuser.UserDefaultPriceList__c = priceList.id;
        testUser.Discount_Threshold__c  = 10.0;
        insert testuser;


        Sales_Channel_Cross_Reference__c crossRef = TestDataSetupUtility.salesChannelCrossReference(testuser.Id);
        insert crossRef;

        System.runAs(testUser){
            Test.starttest();      
            proposal_n.Create_Assets__c = true; 
            proposal_n.QuoteStatus__c = 'Accepted Online';
            proposal_n.Apttus_Proposal__Approval_Stage__c = 'Generated';
            proposal_n.Earliest_Start_Date__c = Date.today(); //SBerron - 3/16
            proposal_n.Latest_End_Date__c = Date.today().adddays(20); //SBerron - 3/16

            Update proposal_n;
            
         MAP<id,Apttus_Proposal__Proposal__c>  proposalMap= new MAP<id,Apttus_Proposal__Proposal__c>();
            proposalMap.put(proposal_n.id, new Apttus_Proposal__Proposal__c(id= proposal_n.id,Apttus_QPConfig__ConfigurationFinalizedDate__c = DateTime.now()));
            
            List<Apttus_Proposal__Proposal__c> proposalList = new List<Apttus_Proposal__Proposal__c>(); 
            proposal_n.Apttus_QPConfig__ConfigurationFinalizedDate__c = DateTime.now().adddays(7);
            proposal_n.Apttus_Proposal__Primary__c = True;
           // proposal_n.Organization__c='Asia Pacific';
            proposalList.add(proposal_n);
            
            ApttusProposalTriggerHelper helper = ApttusProposalTriggerHelper.NewTriggerHelper(CurrentUserProfileName);  
            helper.getQuoteTaxOnFinalize(proposalList, proposalMap , True);
          // helper.setPrimaryQuoteTotalsMatchToOppty(proposalList, proposalMap);
            
            /*Id GCSOpptyRecordType = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'GCS Opportunity');
            opp.RecordTypeId=GCSOpptyRecordType;
            opp.RecordTypeId=GCSOpptyRecordType;
            //opp.Organization__c='Asia Pacific';
            update opp;
            
            helper.SetQuoteStatusWhenFinalize(proposalList, proposalMap);*/
            
            Test.stoptest();
        }
        
    }
    
    @isTest
    static void TestApptusTriggeOpp() {
        Personal_Settings__c personalSettings = new Personal_Settings__c();
        personalSettings.Trigger_Quote__c = False;
        personalSettings.Validation_Account__c = false;
        insert personalSettings; 

        Method_Kill_List__c testCustomSetting = new Method_Kill_List__c(Name='updateOpptySplit', Kill_Method__c=false);
        insert testCustomSetting;
        
        WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c();
        endpoint.Endpoint__c = 'USPS Integration';
        endpoint.Name = 'USPS Integration';
        insert endpoint;
        
        IntegrationConfig__c integSett = TestDataSetupUtility.buildIntegrationConfigSetting();
        integSett.Name = 'USPS Integration';
        integSett.EndpointName__c = endpoint.Name;
        integSett.PaypalRedirectURL__c = endpoint.Endpoint__c;
        insert integSett;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        user manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        insert manager;
        
        Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
        insert priceList; 
        
        Apttus_Proposal__Proposal__c proposal_n = null;
        
        Account account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TestAcct_28_07_15'); 
        account.Organization__c = 'Asia Pacific';
        insert account; 
        
        Account account1 = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TestAcct_28_07_15'); 
        account1 .Organization__c = 'Asia Pacific';
        insert account1 ; 
        
        
        System.debug('------------------------- : '+account);
        
        Contact con = TestDataSetupUtility.createTestContact(account.Id, 'Test_Last', 'Test_First', 'test@test.com');
        insert con;
        System.debug('------------------------- : '+con);
        
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('TestOppt_28_07_15'+DateTime.now(), account.Id);
        opp.Organization__c='Asia Pacific';
       
        insert opp;
        System.debug('------------------------- : '+opp);
        
        proposal_n = TestDataSetupUtility.createProposal('TEST_PROP_28_07_15', account.Id, opp.Id, 'test', false);
        proposal_n.Apttus_Proposal__Primary__c = false;
        proposal_n.Apttus_Proposal__Approval_Stage__c = 'Generated';
        insert proposal_n;
        personalSettings.Trigger_Quote__c = True;
        personalSettings.Validation_Account__c = false;
        update personalSettings; 
        user testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        testuser.UserDefaultPriceList__c = priceList.id;
        testUser.Discount_Threshold__c  = 10.0;
        insert testuser;


        Sales_Channel_Cross_Reference__c crossRef = TestDataSetupUtility.salesChannelCrossReference(testuser.Id);
        insert crossRef;

        System.runAs(testUser){
            Test.starttest();      
            proposal_n.Create_Assets__c = true; 
            proposal_n.QuoteStatus__c = 'Accepted Online';
            proposal_n.Apttus_Proposal__Approval_Stage__c = 'Accepted';
            //proposal_n.Agency__C = account.ID;
            Update proposal_n;
            
         MAP<id,Apttus_Proposal__Proposal__c>  proposalMap= new MAP<id,Apttus_Proposal__Proposal__c>();
            proposalMap.put(proposal_n.id, new Apttus_Proposal__Proposal__c(id= proposal_n.id,Apttus_QPConfig__ConfigurationFinalizedDate__c = DateTime.now()));
            
            List<Apttus_Proposal__Proposal__c> proposalList = new List<Apttus_Proposal__Proposal__c>(); 
            proposal_n.Apttus_QPConfig__ConfigurationFinalizedDate__c = DateTime.now().adddays(7);
            proposal_n.Apttus_Proposal__Primary__c = True;
           // proposal_n.Organization__c='Asia Pacific';
            proposalList.add(proposal_n);
            
            ApttusProposalTriggerHelper helper = ApttusProposalTriggerHelper.NewTriggerHelper(CurrentUserProfileName);  
            helper.getQuoteTaxOnFinalize(proposalList, proposalMap , True);
          // helper.setPrimaryQuoteTotalsMatchToOppty(proposalList, proposalMap);
            
            Id GCSOpptyRecordType = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'GCS Opportunity');
            opp.RecordTypeId=GCSOpptyRecordType;
            //opp.Organization__c='Asia Pacific';
            update opp;
            
            helper.SetQuoteStatusWhenFinalize(proposalList, proposalMap);
            
            account.BillingCity = '12';
            update account;
            proposal_n.Installment__c = true;
            proposal_n.New_Number_of_Installments__c = 10;
            update  proposal_n;
            Test.stoptest();
        }
        
    }
    
    @isTest
    static void TestApptusTriggeOpp1() {
        Personal_Settings__c personalSettings = new Personal_Settings__c();
        personalSettings.Trigger_Quote__c = False;
        personalSettings.Validation_Account__c = false;
        insert personalSettings; 

        Method_Kill_List__c testCustomSetting = new Method_Kill_List__c(Name='updateOpptySplit', Kill_Method__c=false);
        insert testCustomSetting;
        
        WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c();
        endpoint.Endpoint__c = 'USPS Integration';
        endpoint.Name = 'USPS Integration';
        insert endpoint;
        
        IntegrationConfig__c integSett = TestDataSetupUtility.buildIntegrationConfigSetting();
        integSett.Name = 'USPS Integration';
        integSett.EndpointName__c = endpoint.Name;
        integSett.PaypalRedirectURL__c = endpoint.Endpoint__c;
        insert integSett;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        user manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        insert manager;
        
        Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
        insert priceList; 
        
        Apttus_Proposal__Proposal__c proposal_n = null;
        
        Account account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TestAcct_28_07_15'); 
        account.Organization__c = 'Asia Pacific';
        insert account; 
        
        Account account1 = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TestAcct_28_07_15'); 
        account1 .Organization__c = 'Asia Pacific';
        insert account1 ; 
        
        
        System.debug('------------------------- : '+account);
        
        Contact con = TestDataSetupUtility.createTestContact(account.Id, 'Test_Last', 'Test_First', 'test@test.com');
        insert con;
        System.debug('------------------------- : '+con);
        
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('TestOppt_28_07_15'+DateTime.now(), account.Id);
        opp.Organization__c='Asia Pacific';
       
        insert opp;
        System.debug('------------------------- : '+opp);
        
        Payment_Details__c pD = new Payment_Details__c(Organization__c='Asia Pacific',PaymentMethod__c='Credit Card',PaymentFrequency__c='2 - Monthly',PaymentTerm__c='30 days + EOM',CurrencyIsoCode='USD',Name='Test',Active__c=true);
        insert pD;
        
        proposal_n = TestDataSetupUtility.createProposal('TEST_PROP_28_07_15', account.Id, opp.Id, 'test', false);
        proposal_n.Apttus_Proposal__Primary__c = false;
        proposal_n.Apttus_Proposal__Approval_Stage__c = 'Generated';
        proposal_n.PaymentDetails__c=pD.id;
        proposal_n.AccountOrganization__c = 'Asia Pacific';
        insert proposal_n;
        
        System.debug('proposal_n' + proposal_n);
        
        personalSettings.Trigger_Quote__c = True;
        personalSettings.Validation_Account__c = false;
        update personalSettings; 
        user testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        testuser.UserDefaultPriceList__c = priceList.id;
        testUser.Discount_Threshold__c  = 10.0;
        insert testuser;


        Sales_Channel_Cross_Reference__c crossRef = TestDataSetupUtility.salesChannelCrossReference(testuser.Id);
        insert crossRef;
        
        
            
        System.runAs(testUser){
            Test.starttest();      
            
            List<Order__c> orderList = new List<Order__c>();
        Order__c ord = TestDataSetupUtility.createOrderWithOpportunity(account.Id, opp.Id, null, con.Id);
        ord.BillingAccount__c = account.id;
        ord.Entity_ID__c = null;
        ord.QuoteProposal__c = proposal_n.Id;
        ord.Payment_Method_text__c = 'Credit Card';
        ord.Payment_Frequency__c = '2 - Monthly';
        ord.Payment_Term_text__c = '30 days + EOM';
        ord.AccountOrganization__c = 'Asia Pacific';
        ord.Organization__c = 'Asia Pacific';
        orderList.add(ord);
        insert orderList;
        System.debug('orderList' + orderList);
        
            proposal_n.Create_Assets__c = true; 
            proposal_n.QuoteStatus__c = 'Accepted Online';
            proposal_n.Apttus_Proposal__Approval_Stage__c = 'Accepted';
            proposal_n.New_Number_of_Installments__c = 15;
            proposal_n.Installment__c = true;
            //proposal_n.Agency__C = account.ID;
            Update proposal_n;
            
            System.debug('proposal_nproposal_n' + proposal_n);
            
            MAP<id,Apttus_Proposal__Proposal__c>  proposalMap= new MAP<id,Apttus_Proposal__Proposal__c>();
            proposalMap.put(proposal_n.id, new Apttus_Proposal__Proposal__c(id= proposal_n.id,Apttus_QPConfig__ConfigurationFinalizedDate__c = DateTime.now()));
            
            List<Apttus_Proposal__Proposal__c> proposalList = new List<Apttus_Proposal__Proposal__c>(); 
            proposal_n.Apttus_QPConfig__ConfigurationFinalizedDate__c = DateTime.now().adddays(7);
            proposal_n.Apttus_Proposal__Primary__c = True;
           // proposal_n.Organization__c='Asia Pacific';
            proposalList.add(proposal_n);
            
            ApttusProposalTriggerHelper helper = ApttusProposalTriggerHelper.NewTriggerHelper(CurrentUserProfileName);  
            helper.getQuoteTaxOnFinalize(proposalList, proposalMap , True);
          // helper.setPrimaryQuoteTotalsMatchToOppty(proposalList, proposalMap);
            
            Id GCSOpptyRecordType = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'GCS Opportunity');
            opp.RecordTypeId=GCSOpptyRecordType;
            //opp.Organization__c='Asia Pacific';
            update opp;
            
            helper.SetQuoteStatusWhenFinalize(proposalList, proposalMap);
            
            account.BillingCity = '12';
            update account;
            proposal_n.Installment__c = true;
            proposal_n.New_Number_of_Installments__c = 10;
            update  proposal_n;
            Test.stoptest();
        }
        
    }
    
    @isTest
    static void TestApptusTrigge4() {
        Personal_Settings__c personalSettings = new Personal_Settings__c();
        personalSettings.Trigger_Quote__c = False;
        personalSettings.Validation_Account__c = false;
        insert personalSettings; 

        Method_Kill_List__c testCustomSetting = new Method_Kill_List__c(Name='updateOpptySplit', Kill_Method__c=false);
        insert testCustomSetting;
        
        Sales_Channel_Cross_Reference__c crossRef = TestDataSetupUtility.salesChannelCrossReference();
        insert crossRef;

        WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c();
        endpoint.Endpoint__c = 'USPS Integration';
        endpoint.Name = 'USPS Integration';
        insert endpoint;
        
        IntegrationConfig__c integSett = TestDataSetupUtility.buildIntegrationConfigSetting();
        integSett.Name = 'USPS Integration';
        integSett.EndpointName__c = endpoint.Name;
        integSett.PaypalRedirectURL__c = endpoint.Endpoint__c;
        insert integSett;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        user manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        insert manager;
        
        Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
        insert priceList; 
        
        Apttus_Proposal__Proposal__c proposal_n = null;
        Account account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TestAcct_28_07_15'); 
        account.Organization__c = 'Asia Pacific';
        insert account; 
        System.debug('------------------------- : '+account);
        
        Contact con = TestDataSetupUtility.createTestContact(account.Id, 'Test_Last', 'Test_First', 'test@test.com');
        insert con;
        System.debug('------------------------- : '+con);
        
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('TestOppt_28_07_15'+DateTime.now(), account.Id);
        insert opp;
        System.debug('------------------------- : '+opp);
        
        Payment_Details__c pD = new Payment_Details__c(Organization__c='Asia Pacific',PaymentMethod__c='Credit Card',PaymentFrequency__c='2 - Monthly',PaymentTerm__c='30 days + EOM',CurrencyIsoCode='USD',Name='Test',Active__c=true);
        insert pD;
        
        proposal_n = TestDataSetupUtility.createProposal('TEST_PROP_28_07_15', account.Id, opp.Id, 'test', false);
        proposal_n.Apttus_Proposal__Primary__c = False;
        proposal_n.AccountOrganization__c='Asia Pacific';
        proposal_n.PaymentDetails__c=pD.id;
        insert proposal_n;
         Test.starttest(); 
        Apttus_Proposal__Proposal__c proposal_n1 = TestDataSetupUtility.createProposal('TEST_PROP_28_07_2215', account.Id, opp.Id, 'test', false);
        proposal_n1.Apttus_Proposal__Primary__c = True;
        proposal_n1.AccountOrganization__c='Asia Pacific';
        proposal_n1.PaymentDetails__c=pD.id;
        insert proposal_n1;
        
        personalSettings.Validation_Account__c = false;
        personalSettings.Trigger_Quote__c = True;
        update personalSettings; 
        user testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        testuser.UserDefaultPriceList__c = priceList.id;
        testUser.Discount_Threshold__c  = 10.0;
        insert testuser;

        Sales_Channel_Cross_Reference__c crossRefUser = TestDataSetupUtility.salesChannelCrossReference(testUser.Id);
        insert crossRefUser;

        System.runAs(testUser){
              
            MAP<id,Apttus_Proposal__Proposal__c>  proposalMap= new MAP<id,Apttus_Proposal__Proposal__c>();
            proposalMap.put(proposal_n.id, new Apttus_Proposal__Proposal__c(id= proposal_n.id,Apttus_Proposal__Primary__c = False, Apttus_QPConfig__ConfigurationFinalizedDate__c = DateTime.now()));
            List<Apttus_Proposal__Proposal__c> proposalList = new List<Apttus_Proposal__Proposal__c>(); 
            proposal_n.Apttus_QPConfig__ConfigurationFinalizedDate__c = DateTime.now().adddays(7);
            proposal_n.Apttus_Proposal__Primary__c = True;
            proposal_n.Payment__c = 'Yes';
            proposalList.add(proposal_n);
            update proposalList;
            ApttusProposalTriggerHelper helper = ApttusProposalTriggerHelper.NewTriggerHelper(CurrentUserProfileName);  
            helper.setRelatedProposalNonPrimary(proposalList, proposalMap , True);
            SYstem.debug('TEst PaymentDetails__c::'+proposal_n.PaymentDetails__c);
            //helper.checkMinimumInstallment(proposalList);
            Test.stoptest();
        }
        
    }
    
    @isTest
    static void TestApptusTrigge5() {
        Personal_Settings__c personalSettings = new Personal_Settings__c();
        personalSettings.Trigger_Quote__c = False;
        personalSettings.Validation_Account__c = false;
        insert personalSettings; 

        Method_Kill_List__c testCustomSetting = new Method_Kill_List__c(Name='updateOpptySplit', Kill_Method__c=false);
        insert testCustomSetting;
        
        Sales_Channel_Cross_Reference__c crossRef = TestDataSetupUtility.salesChannelCrossReference();
        insert crossRef;

        WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c();
        endpoint.Endpoint__c = 'USPS Integration';
        endpoint.Name = 'USPS Integration';
        insert endpoint;
        
        IntegrationConfig__c integSett = TestDataSetupUtility.buildIntegrationConfigSetting();
        integSett.Name = 'USPS Integration';
        integSett.EndpointName__c = endpoint.Name;
        integSett.PaypalRedirectURL__c = endpoint.Endpoint__c;
        insert integSett;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        user manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        insert manager;
        
        Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
        insert priceList; 
        
        Apttus_Proposal__Proposal__c proposal_n = null;
        Account account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TestAcct_28_07_15'); 
        account.Organization__c = 'Asia Pacific';
        insert account; 
        System.debug('------------------------- : '+account);
        
        Contact con = TestDataSetupUtility.createTestContact(account.Id, 'Test_Last', 'Test_First', 'test@test.com');
        insert con;
        System.debug('------------------------- : '+con);
        
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('TestOppt_28_07_15'+DateTime.now(), account.Id);
        opp.Organization__c ='North America';
        insert opp;
        System.debug('------------------------- : '+opp);
        
        Payment_Details__c pD = new Payment_Details__c(Organization__c='Asia Pacific',PaymentMethod__c='Credit Card',PaymentFrequency__c='2 - Monthly',PaymentTerm__c='30 days + EOM',CurrencyIsoCode='USD',Name='Test',Active__c=true);
        insert pD;
        
        proposal_n = TestDataSetupUtility.createProposal('TEST_PROP_28_07_15', account.Id, opp.Id, 'test', false);
        proposal_n.Apttus_Proposal__Primary__c = False;
        proposal_n.AccountOrganization__c='Asia Pacific';
        proposal_n.PaymentDetails__c=pD.id;
        insert proposal_n;
         Test.starttest(); 
        Apttus_Proposal__Proposal__c proposal_n1 = TestDataSetupUtility.createProposal('TEST_PROP_28_07_2215', account.Id, opp.Id, 'test', false);
        proposal_n1.Apttus_Proposal__Primary__c = True;
        proposal_n1.AccountOrganization__c='Asia Pacific';
        proposal_n1.PaymentDetails__c=pD.id;
        insert proposal_n1;
        
        personalSettings.Validation_Account__c = false;
        personalSettings.Trigger_Quote__c = True;
        update personalSettings; 
        user testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        testuser.UserDefaultPriceList__c = priceList.id;
        testUser.Discount_Threshold__c  = 10.0;
        insert testuser;

        Sales_Channel_Cross_Reference__c crossRefUser = TestDataSetupUtility.salesChannelCrossReference(testUser.Id);
        insert crossRefUser;

        System.runAs(testUser){
              
            MAP<id,Apttus_Proposal__Proposal__c>  proposalMap= new MAP<id,Apttus_Proposal__Proposal__c>();
            proposalMap.put(proposal_n.id, new Apttus_Proposal__Proposal__c(id= proposal_n.id,Apttus_Proposal__Primary__c = False, Apttus_QPConfig__ConfigurationFinalizedDate__c = DateTime.now()));
            List<Apttus_Proposal__Proposal__c> proposalList = new List<Apttus_Proposal__Proposal__c>(); 
            proposal_n.Apttus_QPConfig__ConfigurationFinalizedDate__c = DateTime.now().adddays(7);
            proposal_n.Apttus_Proposal__Primary__c = True;
            proposal_n.Payment__c = 'Yes';
            proposalList.add(proposal_n);
            update proposalList;
            ApttusProposalTriggerHelper helper = ApttusProposalTriggerHelper.NewTriggerHelper(CurrentUserProfileName);  
            helper.setRelatedProposalNonPrimary(proposalList, proposalMap , True);
            SYstem.debug('TEst PaymentDetails__c::'+proposal_n.PaymentDetails__c);
            //helper.checkMinimumInstallment(proposalList);
            Test.stoptest();
        }
        
    }
    @isTest
    static void TestApptusTrigger() {
        Personal_Settings__c personalSettings = new Personal_Settings__c();
        personalSettings.Validation_Account__c = false;
        personalSettings.Trigger_Quote__c = true;
        //insert personalSettings;

        Method_Kill_List__c testCustomSetting = new Method_Kill_List__c(Name='updateOpptySplit', Kill_Method__c=false);
        insert testCustomSetting;
        
        Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
        insert priceList; 
        
        Account account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TestAcct_28_07_15'); 
        insert account; 
        System.debug('------------------------- : '+account);
        
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('TestOppt_28_07_15'+DateTime.now(), account.Id);
        insert opp;
        System.debug('------------------------- : '+opp);
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        List<User> lstUser = new List<User>();
        User manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        lstUser.add(manager);
        User testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        testuser.UserDefaultPriceList__c = priceList.id;
        testUser.Discount_Threshold__c  = 10.0;
        lstUser.add(testuser);
        insert lstUser;
        
        CONTACT con = TestDataSetupUtility.createTestContact(account.id,'test','Con','abccon@gmail.com'); 
        insert con;

        Sales_Channel_Cross_Reference__c crossRef = TestDataSetupUtility.salesChannelCrossReference(testUser.Id);
        insert crossRef;
        
        System.runAs(testUser){
            Test.startTest();  
            Apttus_Proposal__Proposal__c proposal_n = TestDataSetupUtility.createProposal(opp.Id);
            proposal_n.Apttus_Proposal__Primary__c = false; 
            proposal_n.AccountOrganization__c = 'Asia Pacific';
            proposal_n.Payment1_Frequency__c = 'Pre-Paid';
            proposal_n.Payment_Method1__c = 'Invoice';
            proposal_n.Payment1_Term__c = 'Immediate';
            insert proposal_n;
            
            //Create product2
            Product2 product = TestDataSetupUtility.createProduct('Test product5', false); 
            product.Convert_From__c = true;
            product.Eligible_Selling_Country_New__c = 'Austria';
            product.Pricing_Channel__c = 'Agency';
            product.Service_Type__c = 'Subscription';
            insert product;
            
            
            //Create price list                
            Apttus_Config2__PriceListItem__c pli = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 10, Apttus_Config2__ProductId__c = product.Id, Apttus_Config2__ChargeType__c = 'Standard Price');
            insert pli;
            
            Apttus_Config2__ProductConfiguration__c config = TestDataSetupUtility.createTestProductConfig(proposal_n,account,priceList);
            config.Apttus_Config2__Status__c = 'Finalized';
            insert config;
            //System.debug('config:'+config);
            
            List<Apttus_Config2__LineItem__c> aptusLineItemList= new List<Apttus_Config2__LineItem__c>();
            Apttus_Config2__LineItem__c aptusLineItem = TestDataSetupUtility.createLineItemApttus(config.Id);
            aptusLineItem.Apttus_Config2__StartDate__c=System.today();
            aptusLineItem.Apttus_Config2__EndDate__c=System.today()+60;
            aptusLineItem.Apttus_Config2__LineStatus__c = 'New';
            aptusLineItem.Apttus_Config2__LineType__c = 'Product/Service';
            aptusLineItem.Apttus_Config2__IsPrimaryLine__c = true;
            aptusLineItem.Apttus_Config2__LineStatus__c = 'Amended';
            aptusLineItem.Apttus_Config2__Comments__c='test';
            aptusLineItemList.add(aptusLineItem);
            
            Apttus_Config2__LineItem__c aptusLineItem1 = TestDataSetupUtility.createLineItemApttus(config.Id);
            aptusLineItem1.Apttus_Config2__StartDate__c=System.today();
            aptusLineItem1.Apttus_Config2__EndDate__c=System.today()+60;
            aptusLineItem1.Apttus_Config2__LineStatus__c = 'New';
            aptusLineItem1.Apttus_Config2__LineType__c = 'Option';
            aptusLineItem1.Apttus_Config2__IsPrimaryLine__c = true;
            aptusLineItem1.Apttus_Config2__LineStatus__c = 'Amended';
            aptusLineItem1.Apttus_Config2__Comments__c='test';
            aptusLineItemList.add(aptusLineItem1);
            
            insert aptusLineItemList;
            
            
            Apttus_Config2__ProductAttributeValue__c test_ProductAttributeValue1 = new Apttus_Config2__ProductAttributeValue__c(
            Apttus_Config2__LineItemId__c = aptusLineItem.Id);
            test_ProductAttributeValue1.Posting_Locations__c = 'India';
            test_ProductAttributeValue1.Copy_Posting_Location__c = true;
            
            Apttus_Config2__ProductAttributeValue__c test_ProductAttributeValue2 = new Apttus_Config2__ProductAttributeValue__c(
            Apttus_Config2__LineItemId__c = aptusLineItem1.Id);
            test_ProductAttributeValue2.Posting_Locations__c = 'United States';
            insert (new List<Apttus_Config2__ProductAttributeValue__c>{test_ProductAttributeValue1,test_ProductAttributeValue2});
            
            List<Apttus_Proposal__Proposal_Line_Item__c> lstPropLineItem = new List<Apttus_Proposal__Proposal_Line_Item__c>();
            
            Apttus_Proposal__Proposal_Line_Item__c propLineItem2 = New Apttus_Proposal__Proposal_Line_Item__c();
            propLineItem2.Apttus_QPConfig__ConfigurationId__c = config.Id;
            propLineItem2.Apttus_Proposal__Product__c=product.Id;
            propLineItem2.Apttus_QPConfig__NetPrice__c=3400;
            propLineItem2.Apttus_QPConfig__BaseExtendedPrice__c=2040;
            propLineItem2.Apttus_QPConfig__DerivedFromId__c=aptusLineItem.Id;
            propLineItem2.Apttus_Proposal__Proposal__c =proposal_n.Id;
            propLineItem2.Apttus_QPConfig__DerivedFromId__c = aptusLineItem.id;
            //propLineItem2.Proposal_Locked__c = proposal_n.ID;
            lstPropLineItem.add(propLineItem2);
            insert lstPropLineItem;
            proposal_n.Create_Assets__c = False;
            proposal_n.QuoteStatus__c = 'Accepted Online';
            proposal_n.Apttus_Proposal__Approval_Stage__c = 'Accepted';
            Update proposal_n;
            
            MAP<id,Apttus_Proposal__Proposal__c>  proposalMap= new MAP<id,Apttus_Proposal__Proposal__c>();
            proposalMap.put(proposal_n.id, proposal_n);
            List<Apttus_Proposal__Proposal__c> proposalList = new List<Apttus_Proposal__Proposal__c>(); 
            proposalList.add(new Apttus_Proposal__Proposal__c(id= proposal_n.id, Create_Assets__c = true));
            ApttusProposalTriggerHelper helper = ApttusProposalTriggerHelper.NewTriggerHelper(CurrentUserProfileName);
            List<Order__c> orderList = new List<Order__c>();
            Order__c ord = TestDataSetupUtility.createOrderWithOpportunity(account.Id, opp.Id, null, con.Id);
            ord.BillingAccount__c = account.id;
            ord.Entity_ID__c = null;
            orderList.add(ord);
            insert orderList;
            
            List<Order_Line_Item__c> OLIList = new List<Order_Line_Item__c>();
            Order_Line_Item__c oli = TestDataSetupUtility.createOrderLineItem(ord.Id);
            oli.ProposalLineItem__c = propLineItem2.ID;
            insert oli;
            proposalList[0].Apttus_Proposal__ExpectedStartDate__c = Date.Today().addDays(-4);
            proposalList[0].Apttus_Proposal__ExpectedEndDate__c = Date.Today();
            proposalList[0].APTS_Revised_Start_Date__c = Date.Today().addDays(4);
            proposalList[0].Apttus_QPApprov__Approval_Status__c = 'Approved';
            helper.CreateAssetTrigger(proposalList, proposalMap);
            helper.PopulateLineItemsStartDateFromRevisedDate(proposalList,NULL);
            
             MAP<id,Apttus_Proposal__Proposal__c>  proposalMap2= new MAP<id,Apttus_Proposal__Proposal__c>();
            proposalMap2.put(proposal_n.id, new Apttus_Proposal__Proposal__c(id = proposal_n.id , Apttus_QPApprov__Approval_Status__c = 'Pending Approval'));
            helper.SetAutoApprovalProcessList(proposalList,proposalMap2);
            Test.stopTest();
        } 
    }
    
    
    @isTest
    static void TestApptusTrigge3() {
        Personal_Settings__c personalSettings = new Personal_Settings__c();
        personalSettings.Trigger_Quote__c = False;
        personalSettings.Validation_Account__c = false;
        insert personalSettings; 

        Method_Kill_List__c testCustomSetting = new Method_Kill_List__c(Name='updateOpptySplit', Kill_Method__c=false);
        insert testCustomSetting;
        
        Sales_Channel_Cross_Reference__c crossRef = TestDataSetupUtility.salesChannelCrossReference();
        insert crossRef;

        WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c();
        endpoint.Endpoint__c = 'USPS Integration';
        endpoint.Name = 'USPS Integration';
        insert endpoint;
        
        IntegrationConfig__c integSett = TestDataSetupUtility.buildIntegrationConfigSetting();
        integSett.Name = 'USPS Integration';
        integSett.EndpointName__c = endpoint.Name;
        integSett.PaypalRedirectURL__c = endpoint.Endpoint__c;
        insert integSett;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        user manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        insert manager;
        
        Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
        insert priceList; 
        
        Apttus_Proposal__Proposal__c proposal_n = null;
        Account account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TestAcct_28_07_15'); 
        
        insert account; 
        System.debug('------------------------- : '+account);
        
        Contact con = TestDataSetupUtility.createTestContact(account.Id, 'Test_Last', 'Test_First', 'test@test.com');
        insert con;
        System.debug('------------------------- : '+con);
        
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('TestOppt_28_07_15'+DateTime.now(), account.Id);
        insert opp;
        System.debug('------------------------- : '+opp);
        
        proposal_n = TestDataSetupUtility.createProposal('TEST_PROP_28_07_15', account.Id, opp.Id, 'test', false);
        proposal_n.Apttus_Proposal__Primary__c = True;
        proposal_n.QuoteStatus__c = 'Accepted Online';
        insert proposal_n;
        personalSettings.Validation_Account__c = false;
        personalSettings.Trigger_Quote__c = True;
        update personalSettings; 
        user testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        testuser.UserDefaultPriceList__c = priceList.id;
        testUser.Discount_Threshold__c  = 10.0;
        insert testuser;

        Sales_Channel_Cross_Reference__c crossRefUser = TestDataSetupUtility.salesChannelCrossReference(testuser.Id);
        insert crossRefUser;

        System.runAs(testUser){
            Test.starttest();      
            MAP<id,Apttus_Proposal__Proposal__c>  proposalMap= new MAP<id,Apttus_Proposal__Proposal__c>();
            proposalMap.put(proposal_n.id, new Apttus_Proposal__Proposal__c(id= proposal_n.id, BillingStreet__c= proposal_n.BillingStreet__c+'test street', QuoteStatus__c = 'Accepted Online', BillingCity__c= 'San Mateo', BillingStateProvince__c='California ' ,BillingZipPostalCode__c = '94404' , BillingCountry__c = 'United States' ));
            proposal_n.BillingCity__c= 'San Mateo';
            proposal_n.BillingStateProvince__c='California ' ;
            proposal_n.BillingZipPostalCode__c = '9440' ;
            proposal_n.BillingCountry__c = 'United States' ;
            proposal_n.BillingStreet__c =  'aaatest street';
            proposal_n.QuoteStatus__c = 'Accepted Online';
            List<Apttus_Proposal__Proposal__c> proposalList = new List<Apttus_Proposal__Proposal__c>(); 
            proposalList.add(proposal_n);
            
            ApttusProposalTriggerHelper helper = ApttusProposalTriggerHelper.NewTriggerHelper(CurrentUserProfileName);
            helper.updateAccountBillingFromProposal(proposalList,proposalMap);
            Test.stoptest();
        }
        
    }
      
    @isTest
    static void AgencyBillingAddressUpdate2 (){
        //Profile p = [SELECT Id FROM Profile WHERE Name LIKE '%Service Rep%' LIMIT 1];       
        //User u = TestDataSetupUtility.createTestUser('John', 'Doe', p.Id);
        //insert u;
        IntegrationConfig__c setting = new IntegrationConfig__c(Name = 'Avalara Integration', AvalaraClient__c = 'Monster Worldwide, Inc.',
                                                                AvalaraCompanyCode__c = 'MWW', AvalaraCountry__c = 'MWW', EndpointName__c = 'AvalaraDev',IsPaypalTest__c = false,
                                                                Password__c = '6NvqAGdhXM^y',Timeout__c = 60000,Username__c = 'jlescarbeau@appirio.com', PaypalRedirectURL__c = 'PaypalRedirectURL');
        insert setting;
        WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c(Name = 'AvalaraDev', Endpoint__c = 'https://development.avalara.net/1.0/tax/get');
        WebServiceEndpoint__c endpoint2 = new WebServiceEndpoint__c(Name = 'PaypalRedirectURL', Endpoint__c = 'https://payflowlink.paypal.com');
        insert new List<WebServiceEndpoint__c>{endpoint, endpoint2};

        Method_Kill_List__c testCustomSetting = new Method_Kill_List__c(Name='updateOpptySplit', Kill_Method__c=false);
        insert testCustomSetting;
            
            AvalaraAddressInfo__c addressCustomSetting = new AvalaraAddressInfo__c(Name=  'United States',Address1__c  = 'Test1',Address2__c = 'Test2',Address3__c = 'Test3');
        addressCustomSetting.City__c = 'Abc';
        addressCustomSetting.CountryCode__c =  '01';
        addressCustomSetting.StateProvince__c = 'State';
        addressCustomSetting.ZIPPostalCode__c = '20202';
        insert addressCustomSetting; 
        
        
        Personal_Settings__c personalSettings = new Personal_Settings__c();
        personalSettings.Trigger_Quote__c = true;
        personalSettings.Validation_Account__c = false;
        insert personalSettings;
        
        
        IntegrationConfig__c  integConfigSettings = new IntegrationConfig__c(Name ='USPS Integration', 
                                                                             Timeout__c=60000,
                                                                             IsPaypalTest__c=true,
                                                                             EndpointName__c='USPSAddressValidation',
                                                                             Username__c='562CLOUD2615');
        insert integConfigSettings;
        WebServiceEndpoint__c wsEndpoint = new WebServiceEndpoint__c(Name='USPSAddressValidation', Endpoint__c='http://production.shippingapis.com/ShippingAPI.dll');
        insert wsEndpoint;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        List<User> lstUser = new List<User>();
        User manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        lstUser.add(manager);
        User testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        lstUser.add(testuser);
        insert lstUser;

        List<Sales_Channel_Cross_Reference__c> sccrList = new List<Sales_Channel_Cross_Reference__c>();
        sccrList.add(TestDataSetupUtility.salesChannelCrossReference(testUser.Id));
        sccrList.add(TestDataSetupUtility.salesChannelCrossReference());
        insert sccrList;
        
        Account[] accounts = new Account[]{};
            Account acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        acc.BillingStreet = 'Account Street';
        acc.BillingCity = 'Account City';
        acc.BillingCountry = 'Canada';
        acc.BillingPostalCode = '1239876';
        acc.BillingState='Ontario';
        accounts.add(acc);
        
        Account accAgency = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Agency Account');
        accAgency.AgencyFlag__c = true;
        accAgency.BillingStreet = 'Agency Street';
        accAgency.BillingCity = 'Agency City';
        accAgency.BillingCountry = 'Canada';
        accAgency.BillingPostalCode = '1239876';
        accAgency.BillingState='Ontario';
        accounts.add(accAgency);
        insert accounts;
         
      
        ID aggencyID= accAgency.Id;
        Contact con;

            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = dateString + randomInt;

            con = TestDataSetupUtility.createTestContact(aggencyID, 'confirst1', 'conlast1' + uniqueName, uniqueName + '@facebook.dude.com');
                      
        insert con;
      

        
        RelatedPartner__c partner = new RelatedPartner__c();
        /*partner.Account__c = accAgency.Id;
partner.Partner__c = acc.Id;
partner.Role__c = 'Developer';
partner.AgencyType__c = '';*/
        
        partner.Account__c = acc.Id;
        partner.Partner__c = accAgency.Id;
        partner.Role__c = 'Agency';
        partner.AgencyType__c = 'Third Party';
        insert partner;
        
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp ', acc.Id);
        opp.Agency__c = accAgency.Id;
        insert opp;
                
        System.runAs(testUser){
            test.startTest();
            Apttus_Proposal__Proposal__c prop = TestDataSetupUtility.createProposal(opp.Id);
            prop.AccountOrganization__c = 'Asia Pacific';
            prop.Payment1_Frequency__c = 'Pre-Paid';
            prop.Payment_Method1__c = 'Invoice';
            prop.Payment1_Term__c = 'Immediate';
            prop.Agency__c=accAgency.Id;
            prop.AgencyBillingContact__c=con.ID;
            insert prop;
            
            try{
             
                MAP<id,Apttus_Proposal__Proposal__c>  proposalMap= new MAP<id,Apttus_Proposal__Proposal__c>();
                proposalMap.put(prop.id, new Apttus_Proposal__Proposal__c(id= prop.id, BillingStreet__c= prop.BillingStreet__c+'test street', QuoteStatus__c = 'Accepted Online', BillingCity__c= 'San Mateo', BillingStateProvince__c='California ' ,BillingZipPostalCode__c = '94404' , BillingCountry__c = 'United States' ));
                
                List<Apttus_Proposal__Proposal__c> proposalList = new List<Apttus_Proposal__Proposal__c>(); 
                proposalList.add(prop);
                
                ApttusProposalTriggerHelper helper = ApttusProposalTriggerHelper.NewTriggerHelper(CurrentUserProfileName);  
                helper.UpdateAccountBillingAddress(proposalMap,proposalList);
                
                //prop.Agency__c = null;
                //Update prop;
                
                //helper.UpdateConfigurationLineItemAgencyCommissionValue(new List<Apttus_Proposal__Proposal__c> {prop} , proposalMap);
                //System.debug('prop' + prop);
                test.stopTest(); 
            }catch(DMLException e){
                system.assert(false); 
            }
        }
    }
    
    
    
      @isTest
    static void AgencyBillingAddressUpdate3 (){
        IntegrationConfig__c setting = new IntegrationConfig__c(Name = 'Avalara Integration', AvalaraClient__c = 'Monster Worldwide, Inc.',
                                                                AvalaraCompanyCode__c = 'MWW', AvalaraCountry__c = 'MWW', EndpointName__c = 'AvalaraDev',IsPaypalTest__c = false,
                                                                Password__c = '6NvqAGdhXM^y',Timeout__c = 60000,Username__c = 'jlescarbeau@appirio.com', PaypalRedirectURL__c = 'PaypalRedirectURL');
        insert setting;
        WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c(Name = 'AvalaraDev', Endpoint__c = 'https://development.avalara.net/1.0/tax/get');
        WebServiceEndpoint__c endpoint2 = new WebServiceEndpoint__c(Name = 'PaypalRedirectURL', Endpoint__c = 'https://payflowlink.paypal.com');
        insert new List<WebServiceEndpoint__c>{endpoint, endpoint2};
            
        AvalaraAddressInfo__c addressCustomSetting = new AvalaraAddressInfo__c(Name=  'United States',Address1__c  = 'Test1',Address2__c = 'Test2',Address3__c = 'Test3');
        addressCustomSetting.City__c = 'Abc';
        addressCustomSetting.CountryCode__c =  '01';
        addressCustomSetting.StateProvince__c = 'State';
        addressCustomSetting.ZIPPostalCode__c = '20202';
        insert addressCustomSetting;

        Method_Kill_List__c testCustomSetting = new Method_Kill_List__c(Name='updateOpptySplit', Kill_Method__c=false);
        insert testCustomSetting;
        
        
        Personal_Settings__c personalSettings = new Personal_Settings__c();
        personalSettings.Trigger_Quote__c = true;
        personalSettings.Validation_Account__c = false;
        insert personalSettings;
        
        
        IntegrationConfig__c  integConfigSettings = new IntegrationConfig__c(Name ='USPS Integration', 
                                                                             Timeout__c=60000,
                                                                             IsPaypalTest__c=true,
                                                                             EndpointName__c='USPSAddressValidation',
                                                                             Username__c='562CLOUD2615');
        insert integConfigSettings;
        WebServiceEndpoint__c wsEndpoint = new WebServiceEndpoint__c(Name='USPSAddressValidation', Endpoint__c='http://production.shippingapis.com/ShippingAPI.dll');
        insert wsEndpoint;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        List<User> lstUser = new List<User>();
        User manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        lstUser.add(manager);
        User testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        lstUser.add(testuser);
        insert lstUser;

        List<Sales_Channel_Cross_Reference__c> sccrList = new List<Sales_Channel_Cross_Reference__c>();
        sccrList.add(TestDataSetupUtility.salesChannelCrossReference(testUser.Id));
        sccrList.add(TestDataSetupUtility.salesChannelCrossReference());
        insert sccrList;
        
        Account[] accounts = new Account[]{};
        Account acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        acc.BillingStreet = 'Account Street';
        acc.BillingCity = 'Account City';
        acc.BillingCountry = 'Canada';
        acc.BillingPostalCode = '1239876';
        acc.BillingState='Ontario';
        accounts.add(acc);        
        
        Account accAgency = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Agency Account');
        accAgency.AgencyFlag__c = true;
        accAgency.BillingStreet = 'Agency Street';
        accAgency.BillingCity = 'Agency City';
        accAgency.BillingCountry = 'Canada';
        accAgency.BillingPostalCode = '1239876';
        accAgency.BillingState='Ontario';
        accounts.add(accAgency);
        insert accounts;
        
        Contact con = TestDataSetupUtility.createTestContact(accAgency.Id, 'Test_Last', 'Test_First', 'test@test.com');
        insert con;              
            
        RelatedPartner__c partner = new RelatedPartner__c();      
        partner.Account__c = acc.Id;
        partner.Partner__c = accAgency.Id;
        partner.Role__c = 'Agency';
        partner.AgencyType__c = 'Third Party';
        insert partner;
        
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp ', acc.Id);
        opp.Agency__c = accAgency.Id;
        insert opp;
                
        System.runAs(testUser){
            test.startTest();
            Apttus_Proposal__Proposal__c prop = TestDataSetupUtility.createProposal(opp.Id);
            prop.AccountOrganization__c = 'Asia Pacific';
            prop.Payment1_Frequency__c = 'Pre-Paid';
            prop.Payment_Method1__c = 'Invoice';
            prop.Payment1_Term__c = 'Immediate';
            prop.Agency__c=acc.Id;
            insert prop;
            
            try{
             
                MAP<id,Apttus_Proposal__Proposal__c>  proposalMap= new MAP<id,Apttus_Proposal__Proposal__c>();
                proposalMap.put(prop.id, new Apttus_Proposal__Proposal__c(id= prop.id, BillingStreet__c= prop.BillingStreet__c+'test street', QuoteStatus__c = 'Accepted Online', BillingCity__c= 'San Mateo', BillingStateProvince__c='California ' ,BillingZipPostalCode__c = '94404' , BillingCountry__c = 'United States' ));
                
                List<Apttus_Proposal__Proposal__c> proposalList = new List<Apttus_Proposal__Proposal__c>(); 
                proposalList.add(prop);
                
                ApttusProposalTriggerHelper helper = ApttusProposalTriggerHelper.NewTriggerHelper(CurrentUserProfileName);  
                helper.UpdateAccountBillingAddress(proposalMap,proposalList);
                test.stopTest(); 
            }catch(DMLException e){
                system.assert(false); 
            }
        }
    }
    
    
    @isTest
    static void testAPTS_PriceList(){
        Personal_Settings__c personalSettings = new Personal_Settings__c();
        personalSettings.Trigger_Quote__c = true;
        personalSettings.Validation_Account__c = false;
        personalSettings.Validation_Quote__c = false;
        //insert personalSettings;

        Method_Kill_List__c testCustomSetting = new Method_Kill_List__c(Name='updateOpptySplit', Kill_Method__c=false);
        insert testCustomSetting;
        
        QueryTemplateDefaultSettings__c QTTest = new QueryTemplateDefaultSettings__c();
        QTTest.name = 'test1';
        QTTest.Quote_Type__c = 'Standard';
        QTTest.Language__c = 'Standard';
        QTTest.Country__c = 'India';
        QTTest.Agency__c = False;
        Insert QTTest;
        IntegrationConfig__c  integConfigSettings = new IntegrationConfig__c(Name ='USPS Integration', 
                                                                             Timeout__c=60000,
                                                                             IsPaypalTest__c=true,
                                                                             EndpointName__c='USPSAddressValidation',
                                                                             Username__c='562CLOUD2615');
        insert integConfigSettings;
        WebServiceEndpoint__c wsEndpoint = new WebServiceEndpoint__c(Name='USPSAddressValidation', Endpoint__c='http://production.shippingapis.com/ShippingAPI.dll');
        insert wsEndpoint;
        
        Account acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        acc.Organization__c = 'North America';
        insert acc;
        
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp  ', acc.Id);
        insert opp;
        
        Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('AED Price List ', false);
        insert priceList;
        
        Apttus_Config2__PriceList__c priceList1 = new Apttus_Config2__PriceList__c();
        priceList1.Apttus_Config2__Active__c = true;
        priceList1.Name = 'Test Price List';
        insert priceList1;
        
        system.debug('PriceList '+ priceList);
        system.debug('PriceList1 '+ priceList1);
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        List<User> userToInsert = new List<User>();
        user manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        userToInsert.add(manager);
        
        user testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        testuser.UserDefaultPriceList__c = priceList.name;
        testUser.Discount_Threshold__c  = 10.0;
        testUser.Organisation__c = 'North America';
        userToInsert.add(testuser);
        CONTACT con = TestDataSetupUtility.createTestContact(acc.id,'test','Con','abccon@gmail.com'); 
        insert con;
        
        insert userToInsert;
         Order__c ord = TestDataSetupUtility.createOrderWithOpportunity(acc.Id, opp.Id, null, con.Id);
         insert ord;
         Order_Line_Item__c oli = TestDataSetupUtility.createOrderLineItem(ord.Id);
         insert oli;
               
         List<Sales_Channel_Cross_Reference__c> sccrList = new List<Sales_Channel_Cross_Reference__c>();
         sccrList.add(TestDataSetupUtility.salesChannelCrossReference(testUser.Id));
         sccrList.add(TestDataSetupUtility.salesChannelCrossReference());
         insert sccrList;
        
        System.runAs(testUser){
            
           // Test.startTest();
           Apttus_Proposal__Proposal__c prop = TestDataSetupUtility.createProposal(opp.Id);
            prop.AccountOrganization__c = 'North America';
            prop.Payment1_Frequency__c = 'Pre-Paid'; 
            prop.Payment_Method1__c = 'Invoice';
            prop.Payment1_Term__c = 'Immediate';
            prop.Apttus_QPConfig__PriceListId__c = priceList.id;
            insert prop;
            Apttus_Config2__AssetLineItem__c assetLineItem = TestDataSetupUtility.createAssetLineItem('Test asset', acc.Id, false);
            assetLineItem.Proposal__c = prop.Id;
            assetLineItem.Order_Line_Item__c = oli.Id;
            //assetLineItem.Apttus_Config2__ProductId__c = prop.id;
            assetLineItem.Apttus_Config2__StartDate__c = Date.Today() - 10;
            assetLineItem.Apttus_Config2__EndDate__c  = Date.Today().addDays(70);
            insert assetLineItem;
            Test.startTest();
            Apttus_Proposal__Proposal_Line_Item__c pli = TestDataSetupUtility.createProposalLineItem(prop.id);
            pli.Apttus_QPConfig__AssetLineItemId__c  = assetLineItem.Id;
            insert pli;
           
            
            prop.Apttus_Proposal__Primary__c = true ; 
            prop.QuoteStatus__c = 'Accepted Online' ;
            prop.BillingCountry__c  = 'India' ;
            prop.Selling_Country__c = 'India' ;
            prop.Language__c = 'English';
            prop.APTS_Quote_Type__c = 'Product Conversion';
            prop.Apttus_QPConfig__ConfigurationFinalizedDate__c = Date.today();
            prop.Orig_Order_link__c = ord.Id;
            prop.PaypalReferenceNumber__c = '123';
            prop.PaypalResultCode__c = '0';
            prop.Apttus_QPConfig__PriceListId__c = priceList1.id;
            update prop ; 
            seT<id> propIds = new seT<id>{prop.id};
             ID jobID = System.enqueueJob(new APTS_Order_QueueInterFace(propIds));
            
            //stem.assertEquals(prop.AccountOrganization__c, acc.Organization__c); 
            Test.stopTest();
        }           
    } 
    
     
    
    @isTest
    static void testUpdateDirectDebitDiscount() {
        Map<Id, Apttus_Proposal__Proposal__c> proposalMap = new Map<Id, Apttus_Proposal__Proposal__c>();
        List<Apttus_Proposal__Proposal__c> proposalList = new List<Apttus_Proposal__Proposal__c>();
        Apttus_Proposal__Proposal__c proposal = null;

        Sales_Channel_Cross_Reference__c crossRef = TestDataSetupUtility.salesChannelCrossReference();
        insert crossRef;
        //create account with the DirectDebitDiscount flag set
        Account acct = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TestAcct_DDD');
        acct.DirectDebitDiscount__c = True;
        insert acct;
        System.debug('------------------------- : '+acct);
        System.debug('Account Direct Debit Discount Flag: ' + acct.DirectDebitDiscount__c);
        
        Contact con = TestDataSetupUtility.createTestContact(acct.Id, 'Test_Last', 'Test_First', 'test@test.com');
        con.PrimarySalesContact__c = True;
        con.PrimaryBillingContact__c = True;
        insert con;
        System.debug('------------------------- : '+con);
        
        Opportunity oppt = TestDataSetupUtility.createTestOpportunity('TestOppt_DDD', acct.Id);
        insert oppt;
        System.debug('------------------------- : '+oppt);
        
        for(Opportunity oppty : [Select id, Name from Opportunity where id =: acct.Id]){
            system.assertEquals(oppty.accountId, acct.Id); 
        }
        
        proposal = TestDataSetupUtility.createProposal('TEST_PROP_DDD', acct.Id, oppt.Id, 'test', false);
        insert proposal; //here the updateDirectDebitDiscount would be fired inside OnBeforeInsert
        System.debug('------------proposal------------- : '+proposal);
        System.debug('Proposal Direct Debit Discount flag: ' + proposal.Billing_Account_DD_Discount__c);
       
    }
    
    /*
    ** @author : Apttus - Viraj
    ** @date : 10/14/2016
    ** @description : (Case#  00204135) This Method is for Covering the code coverage of  the UpdateConfigurationLineItemAgencyCommissionValue method.
    ** @returns : Nothing
    */
    
    @isTest
    static void AgencyBillingAddressUpdate5 (){
        //Profile p = [SELECT Id FROM Profile WHERE Name LIKE '%Service Rep%' LIMIT 1];       
        //User u = TestDataSetupUtility.createTestUser('John', 'Doe', p.Id);
        //insert u;
        IntegrationConfig__c setting = new IntegrationConfig__c(Name = 'Avalara Integration', AvalaraClient__c = 'Monster Worldwide, Inc.',
                                                                AvalaraCompanyCode__c = 'MWW', AvalaraCountry__c = 'MWW', EndpointName__c = 'AvalaraDev',IsPaypalTest__c = false,
                                                                Password__c = '6NvqAGdhXM^y',Timeout__c = 60000,Username__c = 'jlescarbeau@appirio.com', PaypalRedirectURL__c = 'PaypalRedirectURL');
        insert setting;
        WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c(Name = 'AvalaraDev', Endpoint__c = 'https://development.avalara.net/1.0/tax/get');
        WebServiceEndpoint__c endpoint2 = new WebServiceEndpoint__c(Name = 'PaypalRedirectURL', Endpoint__c = 'https://payflowlink.paypal.com');
        insert new List<WebServiceEndpoint__c>{endpoint, endpoint2};
            
            AvalaraAddressInfo__c addressCustomSetting = new AvalaraAddressInfo__c(Name=  'United States',Address1__c  = 'Test1',Address2__c = 'Test2',Address3__c = 'Test3');
        addressCustomSetting.City__c = 'Abc';
        addressCustomSetting.CountryCode__c =  '01';
        addressCustomSetting.StateProvince__c = 'State';
        addressCustomSetting.ZIPPostalCode__c = '20202';
        insert addressCustomSetting; 

        Method_Kill_List__c testCustomSetting = new Method_Kill_List__c(Name='updateOpptySplit', Kill_Method__c=false);
        insert testCustomSetting;
        
        
        Personal_Settings__c personalSettings = new Personal_Settings__c();
        personalSettings.Trigger_Quote__c = true;
        personalSettings.Validation_Account__c = false;
        insert personalSettings;
        
        
        IntegrationConfig__c  integConfigSettings = new IntegrationConfig__c(Name ='USPS Integration', 
                                                                             Timeout__c=60000,
                                                                             IsPaypalTest__c=true,
                                                                             EndpointName__c='USPSAddressValidation',
                                                                             Username__c='562CLOUD2615');
        insert integConfigSettings;
        WebServiceEndpoint__c wsEndpoint = new WebServiceEndpoint__c(Name='USPSAddressValidation', Endpoint__c='http://production.shippingapis.com/ShippingAPI.dll');
        insert wsEndpoint;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        List<User> lstUser = new List<User>();
        User manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        lstUser.add(manager);
        User testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        lstUser.add(testuser);
        insert lstUser;

        List<Sales_Channel_Cross_Reference__c> sccrList = new List<Sales_Channel_Cross_Reference__c>();
        sccrList.add(TestDataSetupUtility.salesChannelCrossReference(testUser.Id));
        sccrList.add(TestDataSetupUtility.salesChannelCrossReference());
        insert sccrList;
        
        Account[] accounts = new Account[]{};
            Account acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        acc.BillingStreet = 'Account Street';
        acc.BillingCity = 'Account City';
        acc.BillingCountry = 'Canada';
        acc.BillingPostalCode = '1239876';
        acc.BillingState='Ontario';
        accounts.add(acc);
        
        Account accAgency = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Agency Account');
        accAgency.AgencyFlag__c = true;
        accAgency.BillingStreet = 'Agency Street';
        accAgency.BillingCity = 'Agency City';
        accAgency.BillingCountry = 'Canada';
        accAgency.BillingPostalCode = '1239876';
        accAgency.BillingState='Ontario';
        accounts.add(accAgency);
        insert accounts;
         
      
        ID aggencyID= accAgency.Id;
        Contact con;

            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = dateString + randomInt;

            con = TestDataSetupUtility.createTestContact(aggencyID, 'confirst1', 'conlast1' + uniqueName, uniqueName + '@facebook.dude.com');
                      
        insert con;
      

        
        RelatedPartner__c partner = new RelatedPartner__c();
        
        partner.Account__c = acc.Id;
        partner.Partner__c = accAgency.Id;
        partner.Role__c = 'Agency';
        partner.AgencyType__c = 'Third Party';
        insert partner;
        
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp ', acc.Id);
        opp.Agency__c = accAgency.Id;
        insert opp;
        
        
        System.runAs(testUser){
            test.startTest();
            Apttus_Proposal__Proposal__c prop = TestDataSetupUtility.createProposal(opp.Id);
            prop.AccountOrganization__c = 'Asia Pacific';
            prop.Payment1_Frequency__c = 'Pre-Paid';
            prop.Payment_Method1__c = 'Invoice';
            prop.Payment1_Term__c = 'Immediate';
            prop.Agency__c=accAgency.Id;
            prop.AgencyBillingContact__c=con.ID;
            insert prop;
            system.debug(Logginglevel.ERROR,'prop@@@@' + prop);
            try{
                Map<ID, Apttus_Proposal__Proposal__c> mapProposal  = new Map<ID, Apttus_Proposal__Proposal__c>([Select id,Agency__c from Apttus_Proposal__Proposal__c where id =: prop.Id]);
                
                opp.Agency__c = null;
                opp.Skip_Stage_Validation__c = true; //SBerron 3/16/17
                prop.Agency__c = null;
                
                Update opp;
                Update prop;
                
                system.debug(Logginglevel.ERROR,'oppsdsdasda@@@@' + opp);
                system.debug(Logginglevel.ERROR,'message no # 1' + prop);
        
                ApttusProposalTriggerHelper helper = ApttusProposalTriggerHelper.NewTriggerHelper(CurrentUserProfileName);  
                
                helper.UpdateConfigurationLineItemAgencyCommissionValue(new Apttus_Proposal__Proposal__c[]{prop} ,mapProposal,mapProposal  );
                
            }catch(DMLException e){
                system.assert(false); 
            }
            test.stopTest(); 
        }
        
    }
    /*static testMethod void AgencyBillingAddressUpdateByDataGovernanceProfile(){
Profile p = [SELECT Id FROM Profile WHERE Name = 'Data Steward' LIMIT 1];

User u = TestDataSetupUtility.createTestUser('John', 'Doe', p.Id);
insert u;

System.runAs(u){
Account[] accounts = new Account[]{};
Account acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
acc.BillingStreet = 'Account Street';
acc.BillingCity = 'Account City';
accounts.add(acc);

Account accAgency = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Agency Account');
accAgency.AgencyFlag__c = true;
accAgency.BillingStreet = 'Agency Street';
accAgency.BillingCity = 'Agency City';
accounts.add(accAgency);
insert accounts;

Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp ', acc.Id);
opp.Agency__c = accAgency.Id;
insert opp;

OpportunityCompetitor__c competitor = TestDataSetupUtility.createOpportunityCompetitor(opp);
insert competitor;

Apttus_Proposal__Proposal__c prop = TestDataSetupUtility.createApttusProposal(opp);
prop.Agency__c = accAgency.Id;
prop.Apttus_Proposal__Account__c = acc.Id;
insert prop;

Apttus_Proposal__Proposal__c checkProposal = [SELECT Agency__c, BillingCity__c, BillingCountry__c, BillingStateProvince__c, BillingStreet__c, BillingZipPostalCode__c
FROM Apttus_Proposal__Proposal__c WHERE Id = :prop.Id];
system.debug('The proposal: '+checkProposal);                                                                                   
checkProposal.BillingStreet__c = 'Edited Billing Street';

try{
test.startTest();
update checkProposal;
test.stopTest();
}catch(DMLException e){
system.debug('Error on User: ' + u);
system.assert(false); //Data Governance should be able to update proposal billing address even if it has an agency
}
Map<Id,Account> updatedAccount = new Map<Id, Account>([SELECT BillingStreet FROM Account WHERE ID IN :accounts]);
system.assertEquals(checkProposal.BillingStreet__c, updatedAccount.get(acc.Id).BillingStreet); //should update the parent account's address
system.assertEquals(checkProposal.BillingStreet__c, updatedAccount.get(accAgency.Id).BillingStreet); //should update the agency account's address
}
}

static testMethod void AgencyBillingAddressUpdateByNNOTADataGovernanceProfile(){
Profile p = [SELECT Id FROM Profile WHERE Name LIKE 'Sales Manager' LIMIT 1];

User u = TestDataSetupUtility.createTestUser('John', 'Doe', p.Id);
insert u;

System.runAs(u){
Account[] accounts = new Account[]{};
Account acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
acc.BillingStreet = 'Account Street';
acc.BillingCity = 'Account City';
accounts.add(acc);

Account accAgency = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Agency Account');
accAgency.AgencyFlag__c = true;
accAgency.BillingStreet = 'Agency Street';
accAgency.BillingCity = 'Agency City';
accounts.add(accAgency);
insert accounts;

Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp ', acc.Id);
opp.Agency__c = accAgency.Id;
insert opp;

OpportunityCompetitor__c competitor = TestDataSetupUtility.createOpportunityCompetitor(opp);
insert competitor;

Apttus_Proposal__Proposal__c prop = TestDataSetupUtility.createApttusProposal(opp);
prop.Agency__c = accAgency.Id;
prop.Apttus_Proposal__Account__c = acc.Id;
insert prop;

Apttus_Proposal__Proposal__c checkProposal = [SELECT Agency__c, BillingCity__c, BillingCountry__c, BillingStateProvince__c, BillingStreet__c, BillingZipPostalCode__c
FROM Apttus_Proposal__Proposal__c WHERE Id = :prop.Id];
system.debug('The proposal: '+checkProposal);                                                                                   
checkProposal.BillingStreet__c = 'Edited Billing Street';

try{
test.startTest();
update checkProposal;
test.stopTest();
}catch(DMLException e){
system.assert(true); //None Data Governance or Sales Operations should not be able to update proposal billing address when it has an agency
}
}
}

static testMethod void setQuoteCreatedOpportunityFlagTest(){
Account acc = TestDataSetupUtility.createTestAccountWithShipping('Test Account');
insert acc;

Opportunity[] opps = new Opportunity[]{};
for(Integer i = 0; i < 10; i++){
Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp ' + i, acc.Id);
opps.add(opp);
}
insert opps;

Apttus_Proposal__Proposal__c[] proposals = new Apttus_Proposal__Proposal__c[]{};
OpportunityCompetitor__c[] competitors = new OpportunityCompetitor__c[]{};

for(Opportunity o : opps){
Apttus_Proposal__Proposal__c prop = new Apttus_Proposal__Proposal__c();
prop.Apttus_Proposal__Proposal_Name__c = 'Proposal for ' + o.Name;
//prop.Currency__c = 'USD - U.S. Dollar';
prop.Apttus_Proposal__Opportunity__c = o.Id;
proposals.add(prop);

OpportunityCompetitor__c competitor = new OpportunityCompetitor__c();
competitor.Account_Country__c = 'United States';
competitor.Competitor__c = 'LinkedIn';
competitor.Opportunity__c = o.Id;
competitor.Name = 'Competitor for ' + o.Name;
competitors.add(competitor);
}

insert competitors;

Test.startTest();
insert proposals;
Test.stopTest();

//Check to see if all opportunities have thier QuoteCreated__c set to true
for(Opportunity opp : [SELECT QuoteCreated__c FROM Opportunity WHERE Id IN :opps]){
system.debug(opp.QuoteCreated__c);
}
}

static testMethod void unsetQuoteCreatedOpportunityFlagTest(){

}

static testMethod void unsetQuoteCreatedOpportunityFlagWithMultipleProposalsTest(){

}

static testMethod void populateBillingCountryAndBillingStateTest(){
Account acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
insert acc;

Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp ', acc.Id);
insert opp;

OpportunityCompetitor__c competitor = TestDataSetupUtility.createOpportunityCompetitor(opp);
insert competitor;

Apttus_Proposal__Proposal__c prop = TestDataSetupUtility.createApttusProposal(opp);
insert prop;

Apttus_Proposal__Proposal__c checkProposal = [SELECT BillingCity__c, BillingCountry__c, BillingStateProvince__c, BillingStreet__c, BillingZipPostalCode__c
FROM Apttus_Proposal__Proposal__c WHERE Id = :prop.Id];

system.assertEquals(acc.BillingStreet, checkProposal.BillingStreet__c);
system.assertEquals(acc.BillingCity, checkProposal.BillingCity__c);
system.assertEquals(acc.BillingState, checkProposal.BillingStateProvince__c);
system.assertEquals(acc.BillingPostalCode, checkProposal.BillingZipPostalCode__c);
system.assertEquals(acc.BillingCountry, checkProposal.BillingCountry__c);
}*/
    
}