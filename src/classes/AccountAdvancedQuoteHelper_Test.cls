@isTest
public class AccountAdvancedQuoteHelper_Test {
    // @author: Aakash Khatri
    static User manager, testUser;
    static Account account;
    static Apttus_Proposal__Proposal__c proposal_n;
    
    static testMethod void testAccountAdvancedQuoteHelper() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        insert manager;
        testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        testUser.Discount_Threshold__c  = 10.0;
        insert testuser;
        
        System.runAs(testUser){ 
            // create account
            account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
            system.debug('after account ' + account);
            insert account;
            
            //create Opportunity
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp2', account.Id);
            opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'GCS Opportunity');
            insert opp;
            
            Contact con = TestDataSetupUtility.createTestContact(account.Id, 'confirst1', 'conlast1', 'con1@email.com');
            insert con;
            
            //Create product2
            Product2 product = TestDataSetupUtility.createProduct('Test product25', false); 
            product.Convert_From__c = true;
            product.Eligible_Selling_Country__c = 'Austria';
            product.Quote_Pricing_Channel__c = 'Agency';
            product.Service_Type__c ='Usage';
            product.RU_Eligible__c = true;
            product.Convert_From__c = true;
            product.Product_Extension_Eligible__c = true;
            insert product;
            
            // create product eligibility matrix
            Product_Eligibility_Matrix__c ematrix = new Product_Eligibility_Matrix__c();
            ematrix.Is_Mid_Contract_Eligibile__c = true;
            ematrix.Product__c = product.Id;
            ematrix.Country__c = 'Austria';
            insert ematrix;
            
            //Create price list
            Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
            insert priceList; 
            
            Apttus_Config2__PriceListItem__c pli = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 10, Apttus_Config2__ProductId__c = product.Id, Apttus_Config2__ChargeType__c = 'Standard Price');
            insert pli;
            
            // create proposal
            Apttus_Proposal__Proposal__c prop = new Apttus_Proposal__Proposal__c();
            prop.Apttus_Proposal__Account__c = account.Id;
            prop.Apttus_Proposal__Opportunity__c = opp.Id;
            //prop.Name = 'Temp Prop';
            prop.Language__c = 'English';
            prop.Selling_Country__c = 'Austria';
            prop.Apttus_QPConfig__PriceListId__c = priceList.Id;
            prop.BillingStreet__c = 'something';
            prop.BillingCity__c = 'something';
            prop.BillingCountry__c = 'Algeria';
            prop.BillingZipPostalCode__c = 'something';
            prop.QuoteStatus__c = 'Accepted Online';
            insert prop;
            
            
            // create AssetLineItem object // auto insert in TestDataSetupUtility
            Apttus_Config2__AssetLineItem__c aLineItem = TestDataSetupUtility.createAssetLineItem('Asset temp', account.Id, true);
            aLineItem.Apttus_Config2__ProductId__c = product.Id;
            aLineItem.Apttus_Config2__EndDate__c = System.Today() + 100;
            aLineItem.Apttus_Config2__StartDate__c = System.Today() - 1;
            aLineItem.Apttus_Config2__NetPrice__c = 1;
            aLineItem.Proposal__c = prop.Id;
            upsert aLineItem;
            
            Apttus_Config2__AssetLineItem__c aLineItem2 = TestDataSetupUtility.createAssetLineItem('Asset temp', account.Id, true);
            aLineItem2.Apttus_Config2__ProductId__c = product.Id;
            aLineItem2.Apttus_Config2__EndDate__c = System.Today() + 100;
            aLineItem2.Apttus_Config2__StartDate__c = System.Today() - 1;
            aLineItem2.Proposal__c = prop.Id;
            aLineItem2.Apttus_Config2__NetPrice__c = 1;
            upsert aLineItem2;
            
            List<Apttus_Config2__AssetLineItem__c> assetLineList = new List<Apttus_Config2__AssetLineItem__c>();
            insert assetLineList;
            
           /*
           quoteIDAssetLineItemMap = new Map<ID, List<Apttus_Config2__AssetLineItem__c>>();
           */
            //Test.startTest();
            AccountAdvancedQuoteHelper quoteHelper = new AccountAdvancedQuoteHelper();
            quoteHelper.getQuoteByAccountAction('Mid Contract', account.Id);
            // covering null condition
            quoteHelper.getQuoteByAccountAction('Anything Random', account.Id);
            
            Id temp_Id1 = quoteHelper.executeAccountActions(null, '', account.Id);
            Id temp_Id2 = quoteHelper.executeAccountActions('Product Extension', prop.Id, account.Id);
            Id temp_Id3 = quoteHelper.executeAccountActions('Resume Upgrade', prop.Id, account.Id);
            Id temp_Id4 = quoteHelper.executeAccountActions('Renewal', prop.Id, account.Id);
            Id temp_Id5 = quoteHelper.executeAccountActions('Product Conversion', prop.Id, account.Id);
            Id temp_Id6 = quoteHelper.executeAccountActions('Mid Contract', prop.Id, account.Id);
            
            //Test.stopTest();
        }
    }
    
    static testMethod void testAccountAdvancedQuoteHelper2() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        insert manager;
        testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        testUser.Discount_Threshold__c  = 10.0;
        insert testuser;
        
        System.runAs(testUser){ 
            
            // create account
            account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account2');
            system.debug('after account ' + account);
            insert account;
            
            //create Opportunity
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp2', account.Id);
            opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'GCS Opportunity');
            insert opp;
            
            Contact con = TestDataSetupUtility.createTestContact(account.Id, 'confirst1', 'conlast1', 'con1@email.com');
            insert con;
            
            //Create product2
            Product2 product = TestDataSetupUtility.createProduct('Test product25', false); 
            product.Convert_From__c = true;
            product.Eligible_Selling_Country__c = 'Austria';
            product.Quote_Pricing_Channel__c = 'Agency';
            product.Service_Type__c ='Usage';
            product.RU_Eligible__c = true;
            product.Convert_From__c = true;
            product.Product_Extension_Eligible__c = true;
            insert product;
            
            //Create price list
            Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
            insert priceList; 
            
            Apttus_Config2__PriceListItem__c pli = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 10, Apttus_Config2__ProductId__c = product.Id, Apttus_Config2__ChargeType__c = 'Standard Price');
            insert pli;
            /*
            //create proposal
            proposal_n = TestDataSetupUtility.createProposal('Test Proposal', account.Id, opp.Id, 'Accepted Online', false);
            proposal_n.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Apttus_Proposal__Proposal__c', 'Proposal');
            proposal_n.Apttus_QPConfig__PriceListId__c = priceList.id; 
            proposal_n.Language__c = 'English';
            proposal_n.APTS_Quote_Type__c = 'Product Conversion';
            system.debug('*****************:proposal ' + proposal_n.Language__c);
            insert proposal_n;
            */
            
            // create proposal
            Apttus_Proposal__Proposal__c prop = new Apttus_Proposal__Proposal__c();
            prop.Apttus_Proposal__Account__c = account.Id;
            prop.Apttus_Proposal__Opportunity__c = opp.Id;
            //prop.Name = 'Temp Prop';
            prop.Language__c = 'English';
            prop.Selling_Country__c = 'Austria';
            prop.Apttus_QPConfig__PriceListId__c = priceList.Id;
            prop.BillingStreet__c = 'something';
            prop.BillingCity__c = 'something';
            prop.BillingCountry__c = 'Algeria';
            prop.BillingZipPostalCode__c = 'something';
            prop.QuoteStatus__c = 'Accepted Online';
            insert prop;
            
            
            // create AssetLineItem object // auto insert in TestDataSetupUtility
            Apttus_Config2__AssetLineItem__c aLineItem = TestDataSetupUtility.createAssetLineItem('Asset temp', account.Id, true);
            aLineItem.Apttus_Config2__ProductId__c = product.Id;
            aLineItem.Apttus_Config2__EndDate__c = System.Today() + 100;
            aLineItem.Apttus_Config2__StartDate__c = System.Today() - 1;
            aLineItem.Proposal__c = prop.Id;
            upsert aLineItem;
            
            Apttus_Config2__AssetLineItem__c aLineItem2 = TestDataSetupUtility.createAssetLineItem('Asset temp', account.Id, true);
            aLineItem2.Apttus_Config2__ProductId__c = product.Id;
            aLineItem2.Apttus_Config2__EndDate__c = System.Today() + 100;
            aLineItem2.Apttus_Config2__StartDate__c = System.Today() - 1;
            aLineItem2.Proposal__c = prop.Id;
            upsert aLineItem2;
            
            List<Apttus_Config2__AssetLineItem__c> assetLineList = new List<Apttus_Config2__AssetLineItem__c>();
            insert assetLineList;
            
            // create order
            Order__c ord = TestDataSetupUtility.createOrder(account.Id,con.Id);
            ord.QuoteProposal__c = prop.Id;
            insert ord;
            
            // create order line item object
            Order_Line_Item__c ordli = TestDataSetupUtility.createOrderLineItem(ord.Id);
            ordli.AssetLineItemId__c = aLineItem.Id;
            insert ordli;
            
            // create LicenseID__c
            LicenseID__c licenseid = new LicenseID__c();
            licenseid.OrderLineItem__c = ordli.Id;
            licenseid.SiteLicenseID__c = '244447425';
            insert licenseid;
            
            /*
            // create IntegrationConfig__c
            IntegrationConfig__c ic = new IntegrationConfig__c();
            ic.Name = 'Site Integration';
            //ic.AvalaraClient__c = 'Monster Worldwide, Inc.';
            //ic.AvalaraCompanyCode__c = 'MWW';
            //ic.AvalaraCountry__c = 'MWW';
            ic.EndpointName__c = 'MonsterBizAppsSiteRouter';
            //ic.IsPaypalTest__c = true;
            //ic.Password__c = '6NvqAGdhXM^y';
            ic.Timeout__c = 120000;
            //ic.Username__c = 'jlescarbeau@appirio.com';
            insert ic;
            
            //create WebServiceEndpoint__c 
            WebServiceEndpoint__c  wendPoint = new WebServiceEndpoint__c ();
            wendPoint.Name = 'MonsterBizAppsSiteRouter';
            wendPoint.Endpoint__c = 'http://devcrmservice.bizapps.monster.com:1087/Monster.BizApps.SiteRouter/SiteRouterService.svc/legacy';
            insert wendPoint;
            */
            
            //Test.startTest();
            
            //Test.setMock(WebServiceMock.class, AccountAdvancedQuoteHelper.class);

            AccountAdvancedQuoteHelper quoteHelper = new AccountAdvancedQuoteHelper();
            quoteHelper.getQuoteByAccountAction('Resume Upgrade', account.Id);
            quoteHelper.getQuoteByAccountAction('Product Extension', account.Id);
            quoteHelper.getQuoteByAccountAction('Renewal', account.Id);
            //quoteHelper.getQuoteByAccountAction('Product Conversion', account.Id);
            
            Id temp_Id1 = quoteHelper.executeAccountActions(null, '', account.Id);
            Id temp_Id2 = quoteHelper.executeAccountActions('Product Extension', prop.Id, account.Id);
            Id temp_Id3 = quoteHelper.executeAccountActions('Resume Upgrade', prop.Id, account.Id);
            Id temp_Id4 = quoteHelper.executeAccountActions('Renewal', prop.Id, account.Id);
            Id temp_Id5 = quoteHelper.executeAccountActions('Product Conversion', prop.Id, account.Id);
            Id temp_Id6 = quoteHelper.executeAccountActions('Mid Contract', prop.Id, account.Id);
            
            //Test.stopTest();
        }
    }
}