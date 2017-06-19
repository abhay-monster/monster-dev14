@isTest
public with sharing class APTS_ValidationCallBackTest {
    /*
        Name : APTS_LineItem_Helper
        Description : This is test class for validation call back. 
        Created By : Apttus
    */  

    static Apttus_Proposal__Proposal__c proposal;
    static User manager, testUser;
    static Account account;
    static testMethod void TemplateGeneration() 
     {
        //create config custom class properties
        Apttus_Config2__ConfigCustomClasses__c configCustomClassesProperty = new Apttus_Config2__ConfigCustomClasses__c();
        configCustomClassesProperty.Name = 'Config Custom Classes';
        configCustomClassesProperty.Apttus_Config2__ValidationCallbackClass__c = 'APTS_ValidationCallBack';
        insert configCustomClassesProperty;
        
         Apttus_Config2__ConfigSystemProperties__c ConfigSysProp = new Apttus_Config2__ConfigSystemProperties__c();
         ConfigSysProp.Name = 'System Properties';
         ConfigSysProp.Apttus_Config2__ViewCartCustomFields__c = 'AgencyCommission__c,APTS_Is_Default_Adjustment_Done__c,APTS_Is_Trial_Product__c,Select__c,DerivedFromLineItemId__c,Apttus_Config2__ConfigurationId__r.Grand_Total_decimal__c,Apttus_Config2__ConfigurationId__r.Quote_Type__c,APTS_Product_Name__c,'; 
         ConfigSysProp.Apttus_Config2__ViewCartCustomFields2__c ='APTS_Max_Discount__c,APTS_Product_Code__c,quantity_backup__c,Apttus_Config2__AttributeValueId__r.Job_Aids__c,Apttus_Config2__AttributeValueId__r.Recordings__c,Apttus_Config2__AttributeValueId__r.type__c,Override_Discount_Cap__c,System_Discount__c';
        insert ConfigSysProp;         
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        insert manager;
        testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        testUser.Discount_Threshold__c  = 10.0;
        insert testuser;
        
         APTS_Validation_Error_Control__c errorController = new APTS_Validation_Error_Control__c();
            errorController.Profile_Name__c=''+[Select Name from Profile where Id =: userinfo.getProfileid()].name;
            errorController.name='test';
            insert errorController;
        
        System.runAs(testUser){
            // Create test account
            account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
            system.debug('after account ' + account);
            insert account;
            
            
            //create Opportunity
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', account.Id);
            opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'Opportunity');
            opp.OpportunityType__c = 'Re-Bill';
            insert opp;
            
            //Create product2
            Product2 product = TestDataSetupUtility.createProduct('Test product1', false); 
            product.Convert_From__c = true;
            product.Is_Trial_Product__c = true;
            product.ProductCode = 'QUOTE BUNDLE';
            product.Max_Allowed_Option_Quantity_Sum__c=10;
            product.Min_Allowed_Option_Quantity_Sum__c=11;
            insert product;
            
            //Create price list
            Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
            insert priceList; 
            
            //create proposal
            proposal = TestDataSetupUtility.createProposal('Test Proposal', account.Id, opp.Id, 'Accepted Online', false);
            proposal.Apttus_QPConfig__PriceListId__c = priceList.id;    
            proposal.APTS_Quote_Type__c='Re-Bill';
            proposal.AgencyCommission__c = 12;
            proposal.Upgrade_Proposal__c=true;
            insert proposal;    
        
            Apttus_Config2__ProductConfiguration__c config = TestDataSetupUtility.createTestProductConfig(proposal,account,priceList);
            insert config;
            
            Apttus_Config2__AssetLineItem__c test_AssetLineItem = new Apttus_Config2__AssetLineItem__c(Name = 'test value');
            test_AssetLineItem.Apttus_Config2__AccountId__c = account.Id;
            test_AssetLineItem.Apttus_Config2__ProductId__c = product.id;
            test_AssetLineItem.Apttus_Config2__EndDate__c = Date.today() + 365;
            test_AssetLineItem.Available_Quantity__c = 2;
            insert test_AssetLineItem;
            
            Apttus_Config2__LineItem__c aptusLineItem = TestDataSetupUtility.createLineItemApttus(config.Id);

            aptusLineItem.Apttus_Config2__ItemSequence__c = 1.00;
            aptusLineItem.Apttus_Config2__AdjustmentAmount__c = 300;
            aptusLineItem.Apttus_Config2__AdjustmentType__c = '% Discount Off List';
            aptusLineItem.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem.Apttus_Config2__LineStatus__c = 'New';
            aptusLineItem.Apttus_Config2__BaseProductId__c = product.id;
            aptusLineItem.Apttus_Config2__PricingStatus__c = 'Complete';
            aptusLineItem.Apttus_Config2__ProductId__c = product.id;
            aptusLineItem.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            aptusLineItem.Apttus_Config2__EndDate__c = System.Today();
            aptusLineItem.Apttus_Config2__BasePrice__c = 12.23;
            aptusLineItem.AgencyCommission__c  = 12;
            aptusLineItem.Apttus_Config2__HasOptions__c=true;
            aptusLineItem.Apttus_Config2__IsPrimaryLine__c=true;
            aptusLineItem.Apttus_Config2__LineType__c='Option';
            aptusLineItem.Apttus_Config2__ExtendedPrice__c = 12.23;
            aptusLineItem.Apttus_Config2__ListPrice__c = 100;
            insert aptusLineItem;
            
            aptusLineItem = [select id,Apttus_Config2__AdjustmentAmount__c,Apttus_Config2__AdjustmentType__c, Apttus_Config2__ItemSequence__c,Apttus_Config2__LineNumber__c,
                            Apttus_Config2__LineStatus__c,Apttus_Config2__BaseProductId__c,Apttus_Config2__PricingStatus__c,
                            Apttus_Config2__ProductId__c,Apttus_Config2__AssetLineItemId__c,Apttus_Config2__EndDate__c,Apttus_Config2__BasePrice__c,
                            AgencyCommission__c,APTS_Is_Trial_Product__c from Apttus_Config2__LineItem__c where id =: aptusLineItem.Id];
            update aptusLineItem;
            
            Apttus_Config2__LineItem__c aptusLineItem2 = TestDataSetupUtility.createLineItemApttus(config.Id);

            aptusLineItem2.Apttus_Config2__ItemSequence__c = 1.00;
            aptusLineItem2.Apttus_Config2__StartDate__c = System.today() - 10;
            aptusLineItem2.Apttus_Config2__AdjustmentAmount__c = 300;
            aptusLineItem2.Apttus_Config2__AssetLineItemId__c  = test_AssetLineItem.Id;
            aptusLineItem2.Apttus_Config2__AdjustmentType__c = '% Discount Off List';
            aptusLineItem2.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem2.Apttus_Config2__LineStatus__c = 'Incremented';
            aptusLineItem2.Apttus_Config2__BaseProductId__c = product.id;
            aptusLineItem2.Apttus_Config2__PricingStatus__c = 'Complete';
            aptusLineItem2.Apttus_Config2__ProductId__c = product.id;
            aptusLineItem2.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            aptusLineItem2.Apttus_Config2__EndDate__c = System.Today() + 234;
            aptusLineItem2.Apttus_Config2__BasePrice__c = 12.23;
            aptusLineItem2.AgencyCommission__c  = 12;
            aptusLineItem2.Apttus_Config2__HasOptions__c=true;
            aptusLineItem2.Apttus_Config2__IsPrimaryLine__c=true;
            aptusLineItem2.Apttus_Config2__ExtendedPrice__c = 12.23;
            aptusLineItem2.Apttus_Config2__ListPrice__c = 100;
            insert aptusLineItem2;
            
            aptusLineItem2 = [select id,Apttus_Config2__StartDate__c,APTS_Asset_Line_Item_End_Date__c,Apttus_Config2__AdjustmentAmount__c,Apttus_Config2__AdjustmentType__c, Apttus_Config2__ItemSequence__c,Apttus_Config2__LineNumber__c,
                            Apttus_Config2__LineStatus__c,Apttus_Config2__BaseProductId__c,Apttus_Config2__PricingStatus__c,
                            Apttus_Config2__ProductId__c,Apttus_Config2__AssetLineItemId__c,Apttus_Config2__EndDate__c,Apttus_Config2__BasePrice__c,
                            AgencyCommission__c,APTS_Is_Trial_Product__c from Apttus_Config2__LineItem__c where id =: aptusLineItem2.Id];
            update aptusLineItem2;
            
            
            Apttus_Config2__ProductAttributeValue__c test_ProductAttributeValue = new Apttus_Config2__ProductAttributeValue__c(
                                                    Apttus_Config2__LineItemId__c = aptusLineItem.Id);
            insert test_ProductAttributeValue;
             
             APTS_Discount_Threshold__c dt = new APTS_Discount_Threshold__c();
             dt.APTS_Attribute_API_Name__c = 'Country__c';
             dt.APTS_Attribute_Value__c = 'United States';
             dt.APTS_Max_Discount__c = 40;
             dt.APTS_Product__c = product.id;
             dt.APTS_Is_Product_Only_Max_Discount__c = false;
             insert dt;
            
            List<Apttus_Config2__LineItem__c> OLItemList = new List<Apttus_Config2__LineItem__c>{aptusLineItem,aptusLineItem2};
            
            Update OLItemList;
            
            List<Apttus_Config2__TempRenew__c> tempList = new List<Apttus_Config2__TempRenew__c>();
            
            Apttus_Config2__TempRenew__c temprenew = new Apttus_Config2__TempRenew__c();
            temprenew.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.Id;
            temprenew.Name = 'temp renew 1';
            temprenew.Apttus_Config2__Quantity__c = 5;
            temprenew.Apttus_Config2__StartDate__c = System.today() - 1;
            tempList.add(temprenew);
            
            Apttus_Config2__TempRenew__c temprenew1 = new Apttus_Config2__TempRenew__c();
            temprenew1.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.Id;
            temprenew1.Name = 'temp renew 2';
            temprenew1.Apttus_Config2__Quantity__c = 5;
            temprenew1.Apttus_Config2__StartDate__c = System.today() + 20;
            temprenew1.Apttus_Config2__EndDate__c = System.today();
            tempList.add(temprenew1);
            
            Apttus_Config2__TempRenew__c temprenew2 = new Apttus_Config2__TempRenew__c();
            temprenew2.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.Id;
            temprenew2.Name = 'temp renew 2';
            temprenew2.Apttus_Config2__Quantity__c = 5;
            temprenew2.Apttus_Config2__EndDate__c = System.today();
            tempList.add(temprenew2);
            insert tempList;
//            Test.startTest();
            Apttus_Config2.CallbackTester.testValidationCallback(config.Id, OLItemList, tempList, new APTS_ValidationCallBack());
            APTS_ValidationCAllback.getLineItemSO();

            Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO request = new Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO();
            request.CartId = config.id;
            request.LineNumber = OLItemList[0].Apttus_Config2__LineNumber__c;
            
            Apttus_CPQApi.CPQ.ComputeNetPriceResponseDO priceResponse = Apttus_CPQApi.CPQWebService.computeNetPriceForBundle(request);
            
            /* Added by Apttus Support*/
           
          
           
            
            config = TestDataSetupUtility.createTestProductConfig(proposal,account,priceList);
            insert config;
            
            //Apttus_Config2.CallbackTester.testValidationCallback(config.Id, OLItemList, tempList, new APTS_ValidationCallBack());
            //APTS_ValidationCAllback.getLineItemSO();

            request = new Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO();
            request.CartId = config.id;
            request.LineNumber = OLItemList[0].Apttus_Config2__LineNumber__c;
            
            priceResponse = Apttus_CPQApi.CPQWebService.computeNetPriceForBundle(request);
            /*    ------    */
            
            
  //          Test.stopTest();
        }
    }
    static testMethod void TemplateGeneration2() 
     {
        //create config custom class properties
        Apttus_Config2__ConfigCustomClasses__c configCustomClassesProperty = new Apttus_Config2__ConfigCustomClasses__c();
        configCustomClassesProperty.Name = 'Config Custom Classes';
        configCustomClassesProperty.Apttus_Config2__ValidationCallbackClass__c = 'APTS_ValidationCallBack';
        insert configCustomClassesProperty;
        
         Apttus_Config2__ConfigSystemProperties__c ConfigSysProp = new Apttus_Config2__ConfigSystemProperties__c();
         ConfigSysProp.Name = 'System Properties';
         ConfigSysProp.Apttus_Config2__ViewCartCustomFields__c = 'AgencyCommission__c,APTS_Is_Default_Adjustment_Done__c,APTS_Is_Trial_Product__c,Select__c,DerivedFromLineItemId__c,Apttus_Config2__ConfigurationId__r.Grand_Total_decimal__c,Apttus_Config2__ConfigurationId__r.Quote_Type__c,APTS_Product_Name__c,'; 
         ConfigSysProp.Apttus_Config2__ViewCartCustomFields2__c ='APTS_Max_Discount__c,APTS_Product_Code__c,quantity_backup__c,Apttus_Config2__AttributeValueId__r.Job_Aids__c,Apttus_Config2__AttributeValueId__r.Recordings__c,Apttus_Config2__AttributeValueId__r.type__c,Override_Discount_Cap__c,System_Discount__c,';
        insert ConfigSysProp;         
         
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        insert manager;
        testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        testUser.Discount_Threshold__c  = 10.0;
        insert testuser;
        
        System.runAs(testUser){
            // Create test account
            account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
            system.debug('after account ' + account);
            insert account;
            
            
            //create Opportunity
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', account.Id);
            opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'Opportunity');
            insert opp;
            
            //Create product2
            Product2 product = TestDataSetupUtility.createProduct('Test product1', false); 
            product.Convert_From__c = true;
            product.Is_Trial_Product__c = true;
            product.ProductCode = 'QUOTE BUNDLE';
            insert product;
            
            //Create price list
            Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
            insert priceList; 
            
            //create proposal
            proposal = TestDataSetupUtility.createProposal('Test Proposal', account.Id, opp.Id, 'Accepted Online', false);
            proposal.Apttus_QPConfig__PriceListId__c = priceList.id;    
            proposal.MidContract_Proposal__c = false;
            proposal.AgencyCommission__c = 12;
            proposal.APTS_Quote_Type__c='Product Conversion';
            insert proposal;    
        
            Apttus_Config2__ProductConfiguration__c config = TestDataSetupUtility.createTestProductConfig(proposal,account,priceList);
            insert config;
            
            Apttus_Config2__AssetLineItem__c test_AssetLineItem = new Apttus_Config2__AssetLineItem__c(Name = 'test value');
            test_AssetLineItem.Apttus_Config2__AccountId__c = account.Id;
            test_AssetLineItem.Apttus_Config2__ProductId__c = product.id;
            test_AssetLineItem.Apttus_Config2__EndDate__c = Date.today() + 365;
            insert test_AssetLineItem;
            
            Apttus_Config2__LineItem__c aptusLineItem = TestDataSetupUtility.createLineItemApttus(config.Id);

            aptusLineItem.Apttus_Config2__ItemSequence__c = 1.00; 
            aptusLineItem.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem.Apttus_Config2__LineStatus__c = 'New';
            aptusLineItem.Apttus_Config2__BaseProductId__c = product.id;
            aptusLineItem.Apttus_Config2__PricingStatus__c = 'Complete';
            aptusLineItem.Apttus_Config2__ProductId__c = product.id;
            aptusLineItem.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            aptusLineItem.Apttus_Config2__EndDate__c = System.Today();
            aptusLineItem.Apttus_Config2__BasePrice__c = 12.23;
            aptusLineItem.AgencyCommission__c  = 12;
            aptusLineItem.Apttus_Config2__AdjustmentType__c = 'Discount Amount'; //'% Discount Off List';
            aptusLineItem.Apttus_Config2__ExtendedPrice__c = 12.23;
            aptusLineItem.Apttus_Config2__AdjustmentAmount__c = 300;
            aptusLineItem.Apttus_Config2__ListPrice__c = 100;
            insert aptusLineItem;
            
             Apttus_Config2__LineItem__c aptusLineItem1 = TestDataSetupUtility.createLineItemApttus(config.Id);

            aptusLineItem1.Apttus_Config2__ItemSequence__c = 1.00; 
            aptusLineItem1.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem1.Apttus_Config2__LineStatus__c = 'New';
            aptusLineItem1.Apttus_Config2__BaseProductId__c = product.id;
            aptusLineItem1.Apttus_Config2__PricingStatus__c = 'Complete';
            aptusLineItem1.Apttus_Config2__ProductId__c = product.id;
            aptusLineItem1.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            aptusLineItem1.Apttus_Config2__EndDate__c = System.Today();
            aptusLineItem1.Apttus_Config2__BasePrice__c = 12.23;
            aptusLineItem1.AgencyCommission__c  = 12;
            aptusLineItem1.Apttus_Config2__AdjustmentType__c = 'Price Override'; //'% Discount Off List';
            aptusLineItem1.Apttus_Config2__ExtendedPrice__c = 12.23;
            aptusLineItem1.Apttus_Config2__AdjustmentAmount__c = 300;
            aptusLineItem1.Apttus_Config2__ListPrice__c = 100;
            insert aptusLineItem1;
            
            aptusLineItem = [select id,Apttus_Config2__ItemSequence__c,Apttus_Config2__LineNumber__c,
                            Apttus_Config2__LineStatus__c,Apttus_Config2__BaseProductId__c,Apttus_Config2__PricingStatus__c,
                            Apttus_Config2__ProductId__c,Apttus_Config2__AssetLineItemId__c,Apttus_Config2__EndDate__c,Apttus_Config2__BasePrice__c,
                            AgencyCommission__c,APTS_Is_Trial_Product__c from Apttus_Config2__LineItem__c where id =: aptusLineItem.Id];
            update aptusLineItem;
            
            Apttus_Config2__ProductAttributeValue__c test_ProductAttributeValue = new Apttus_Config2__ProductAttributeValue__c(
                                                    Apttus_Config2__LineItemId__c = aptusLineItem.Id);
            insert test_ProductAttributeValue;
             
             APTS_Discount_Threshold__c dt = new APTS_Discount_Threshold__c();
             dt.APTS_Attribute_API_Name__c = 'Country__c';
             dt.APTS_Attribute_Value__c = 'United States';
             dt.APTS_Max_Discount__c = 40;
             dt.APTS_Product__c = product.id;
             dt.APTS_Is_Product_Only_Max_Discount__c = false;
             insert dt;
            
            List<Apttus_Config2__LineItem__c> OLItemList = new List<Apttus_Config2__LineItem__c>{aptusLineItem};
            
            Update OLItemList;
            
            List<Apttus_Config2__TempRenew__c> tempList = new List<Apttus_Config2__TempRenew__c>();
            
            Apttus_Config2__TempRenew__c temprenew = new Apttus_Config2__TempRenew__c();
            temprenew.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.Id;
            temprenew.Name = 'temp renew 1';
            temprenew.Apttus_Config2__StartDate__c = System.today() - 1;
            tempList.add(temprenew);
            
            Apttus_Config2__TempRenew__c temprenew1 = new Apttus_Config2__TempRenew__c();
            temprenew1.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.Id;
            temprenew1.Name = 'temp renew 2';
            temprenew1.Apttus_Config2__StartDate__c = System.today() + 20;
            temprenew1.Apttus_Config2__EndDate__c = System.today();
            tempList.add(temprenew1);
            
            Apttus_Config2__TempRenew__c temprenew2 = new Apttus_Config2__TempRenew__c();
            temprenew2.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.Id;
            temprenew2.Name = 'temp renew 2';
            temprenew2.Apttus_Config2__EndDate__c = System.today();
            tempList.add(temprenew2);
            insert tempList;
//            Test.startTest();
            Apttus_Config2.CallbackTester.testValidationCallback(config.Id, OLItemList, tempList, new APTS_ValidationCallBack());
            APTS_ValidationCAllback.getLineItemSO();

            Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO request = new Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO();
            request.CartId = config.id;
            request.LineNumber = OLItemList[0].Apttus_Config2__LineNumber__c;
            
            Apttus_CPQApi.CPQ.ComputeNetPriceResponseDO priceResponse = Apttus_CPQApi.CPQWebService.computeNetPriceForBundle(request);
            
  //          Test.stopTest();
        }
    }
    static testMethod void TemplateGeneration23() 
     {
         Apttus_Config2__ConfigSystemProperties__c ConfigSysProp = new Apttus_Config2__ConfigSystemProperties__c();
         ConfigSysProp.Name = 'System Properties';
         ConfigSysProp.Apttus_Config2__ViewCartCustomFields__c = 'AgencyCommission__c,APTS_Is_Default_Adjustment_Done__c,APTS_Is_Trial_Product__c,Select__c,DerivedFromLineItemId__c,Apttus_Config2__ConfigurationId__r.Grand_Total_decimal__c,Apttus_Config2__ConfigurationId__r.Quote_Type__c,APTS_Product_Name__c,';          
         ConfigSysProp.Apttus_Config2__ViewCartCustomFields2__c ='APTS_Max_Discount__c,APTS_Product_Code__c,quantity_backup__c,Apttus_Config2__AttributeValueId__r.Job_Aids__c,Apttus_Config2__AttributeValueId__r.Recordings__c,Apttus_Config2__AttributeValueId__r.type__c,Override_Discount_Cap__c,System_Discount__c,';
        insert ConfigSysProp;         
         
        //create config custom class properties
        Apttus_Config2__ConfigCustomClasses__c configCustomClassesProperty = new Apttus_Config2__ConfigCustomClasses__c();
        configCustomClassesProperty.Name = 'Config Custom Classes';
        configCustomClassesProperty.Apttus_Config2__ValidationCallbackClass__c = 'APTS_ValidationCallBack';
        insert configCustomClassesProperty;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        insert manager;
        testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        testUser.Discount_Threshold__c  = 10.0;
        insert testuser;
        
        System.runAs(testUser){
            // Create test account
            account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
            system.debug('after account ' + account);
            insert account;
            
            
            //create Opportunity
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', account.Id);
            opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'Opportunity');
            insert opp;
            
            //Create product2
            Product2 product = TestDataSetupUtility.createProduct('Test product1', false); 
            product.Convert_From__c = true;
            product.Is_Trial_Product__c = true;
            product.ProductCode = 'QUOTE BUNDLE';
            insert product;
            
            //Create price list
            Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
            insert priceList; 
            
            //create proposal
            proposal = TestDataSetupUtility.createProposal('Test Proposal', account.Id, opp.Id, 'Accepted Online', false);
            proposal.Apttus_QPConfig__PriceListId__c = priceList.id;    
            proposal.APTS_Quote_Type__c = 'Product Extension';
            proposal.AgencyCommission__c = 12;
            insert proposal;    
        
            Apttus_Config2__ProductConfiguration__c config = TestDataSetupUtility.createTestProductConfig(proposal,account,priceList);
            insert config;
            
            Apttus_Config2__AssetLineItem__c test_AssetLineItem = new Apttus_Config2__AssetLineItem__c(Name = 'test value');
            test_AssetLineItem.Apttus_Config2__AccountId__c = account.Id;
            test_AssetLineItem.Apttus_Config2__ProductId__c = product.id;
            test_AssetLineItem.Apttus_Config2__EndDate__c = System.Today();
            insert test_AssetLineItem;
            
            Apttus_Config2__LineItem__c aptusLineItem = TestDataSetupUtility.createLineItemApttus(config.Id);

            aptusLineItem.Apttus_Config2__ItemSequence__c = 1.00; 
            aptusLineItem.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem.Apttus_Config2__LineStatus__c = 'New';
            aptusLineItem.Apttus_Config2__BaseProductId__c = product.id;
            aptusLineItem.Apttus_Config2__PricingStatus__c = 'Complete';
            aptusLineItem.Apttus_Config2__ProductId__c = product.id;
            aptusLineItem.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            aptusLineItem.Apttus_Config2__EndDate__c = System.Today();
            aptusLineItem.Apttus_Config2__BasePrice__c = 12.23;
            aptusLineItem.AgencyCommission__c  = 12;
            aptusLineItem.Apttus_Config2__AdjustmentType__c = '% Discount Off List';
            aptusLineItem.Apttus_Config2__ExtendedPrice__c = 12.23;
            aptusLineItem.Apttus_Config2__AdjustmentAmount__c = 300;
            aptusLineItem.Apttus_Config2__ListPrice__c = 100;
            insert aptusLineItem;
            
            aptusLineItem = [select id,Apttus_Config2__ItemSequence__c,Apttus_Config2__LineNumber__c,
                            Apttus_Config2__LineStatus__c,Apttus_Config2__BaseProductId__c,Apttus_Config2__PricingStatus__c,
                            Apttus_Config2__ProductId__c,Apttus_Config2__AssetLineItemId__c,Apttus_Config2__EndDate__c,Apttus_Config2__BasePrice__c,
                            AgencyCommission__c,APTS_Is_Trial_Product__c from Apttus_Config2__LineItem__c where id =: aptusLineItem.Id];
            update aptusLineItem;
            
            Apttus_Config2__ProductAttributeValue__c test_ProductAttributeValue = new Apttus_Config2__ProductAttributeValue__c(
                                                    Apttus_Config2__LineItemId__c = aptusLineItem.Id);
            insert test_ProductAttributeValue;
             
             APTS_Discount_Threshold__c dt = new APTS_Discount_Threshold__c();
             dt.APTS_Attribute_API_Name__c = 'Country__c';
             dt.APTS_Attribute_Value__c = 'United States';
             dt.APTS_Max_Discount__c = 40;
             dt.APTS_Product__c = product.id;
             dt.APTS_Is_Product_Only_Max_Discount__c = false;
             insert dt;
            
            List<Apttus_Config2__LineItem__c> OLItemList = new List<Apttus_Config2__LineItem__c>{aptusLineItem};
            
            Update OLItemList;
            
            List<Apttus_Config2__TempRenew__c> tempList = new List<Apttus_Config2__TempRenew__c>();
            
            Apttus_Config2__TempRenew__c temprenew = new Apttus_Config2__TempRenew__c();
            temprenew.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.Id;
            temprenew.Name = 'temp renew 1';
            temprenew.Apttus_Config2__StartDate__c = System.today() - 1;
            temprenew.Apttus_Config2__EndDate__c = System.today();
            tempList.add(temprenew);
            
            Apttus_Config2__TempRenew__c temprenew1 = new Apttus_Config2__TempRenew__c();
            temprenew1.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.Id;
            temprenew1.Name = 'temp renew 2';
            temprenew1.Apttus_Config2__StartDate__c = System.today() + 20;
            temprenew1.Apttus_Config2__EndDate__c = System.today();
            tempList.add(temprenew1);
            
            Apttus_Config2__TempRenew__c temprenew2 = new Apttus_Config2__TempRenew__c();
            temprenew2.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.Id;
            temprenew2.Name = 'temp renew 2';
            temprenew2.Apttus_Config2__EndDate__c = System.today();
            tempList.add(temprenew2);
            insert tempList;
//            Test.startTest();
            Apttus_Config2.CallbackTester.testValidationCallback(config.Id, OLItemList, tempList, new APTS_ValidationCallBack());
            APTS_ValidationCAllback.getLineItemSO();

            Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO request = new Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO();
            request.CartId = config.id;
            request.LineNumber = OLItemList[0].Apttus_Config2__LineNumber__c;
            
            Apttus_CPQApi.CPQ.ComputeNetPriceResponseDO priceResponse = Apttus_CPQApi.CPQWebService.computeNetPriceForBundle(request);
            
  //          Test.stopTest();
        }
    }
    
    
    static testMethod void TemplateGenerationProductConversion() 
     {
         Apttus_Config2__ConfigSystemProperties__c ConfigSysProp = new Apttus_Config2__ConfigSystemProperties__c();
         ConfigSysProp.Name = 'System Properties';
         ConfigSysProp.Apttus_Config2__ViewCartCustomFields__c = 'AgencyCommission__c,APTS_Is_Default_Adjustment_Done__c,APTS_Is_Trial_Product__c,Select__c,DerivedFromLineItemId__c,Apttus_Config2__ConfigurationId__r.Grand_Total_decimal__c,Apttus_Config2__ConfigurationId__r.Quote_Type__c,APTS_Product_Name__c,';          
         ConfigSysProp.Apttus_Config2__ViewCartCustomFields2__c ='APTS_Max_Discount__c,APTS_Product_Code__c,quantity_backup__c,Apttus_Config2__AttributeValueId__r.Job_Aids__c,Apttus_Config2__AttributeValueId__r.Recordings__c,Apttus_Config2__AttributeValueId__r.type__c,Override_Discount_Cap__c,System_Discount__c,';
        insert ConfigSysProp;         
         
        //create config custom class properties
        Apttus_Config2__ConfigCustomClasses__c configCustomClassesProperty = new Apttus_Config2__ConfigCustomClasses__c();
        configCustomClassesProperty.Name = 'Config Custom Classes';
        configCustomClassesProperty.Apttus_Config2__ValidationCallbackClass__c = 'APTS_ValidationCallBack';
        insert configCustomClassesProperty;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        insert manager;
        testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        testUser.Discount_Threshold__c  = 10.0;
        insert testuser;
        
        System.runAs(testUser){
            // Create test account
            account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
            system.debug('after account ' + account);
            insert account;
            
            
            //create Opportunity
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', account.Id);
            opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'Opportunity');
            insert opp;
            
            //Create product2
            Product2 product = TestDataSetupUtility.createProduct('Test product1', false); 
            product.Convert_From__c = true;
            product.Is_Trial_Product__c = true;
            product.ProductCode = 'QUOTE BUNDLE';
            insert product;
            
            //Create price list
            Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
            insert priceList; 
            
            //create proposal
            proposal = TestDataSetupUtility.createProposal('Test Proposal', account.Id, opp.Id, 'Accepted Online', false);
            proposal.Apttus_QPConfig__PriceListId__c = priceList.id;    
            proposal.APTS_Quote_Type__c = 'Product Extension';
            proposal.AgencyCommission__c = 12;
            proposal.Conversion_Proposal__c = true;
            insert proposal;    
        
            Apttus_Config2__ProductConfiguration__c config = TestDataSetupUtility.createTestProductConfig(proposal,account,priceList);
            insert config;
            
            Apttus_Config2__AssetLineItem__c test_AssetLineItem = new Apttus_Config2__AssetLineItem__c(Name = 'test value');
            test_AssetLineItem.Apttus_Config2__AccountId__c = account.Id;
            test_AssetLineItem.Apttus_Config2__ProductId__c = product.id;
            test_AssetLineItem.Apttus_Config2__EndDate__c = System.Today();
            insert test_AssetLineItem;
            
            Apttus_Config2__LineItem__c aptusLineItem = TestDataSetupUtility.createLineItemApttus(config.Id);

            aptusLineItem.Apttus_Config2__ItemSequence__c = 1.00; 
            aptusLineItem.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem.Apttus_Config2__LineStatus__c = 'New';
            aptusLineItem.Apttus_Config2__BaseProductId__c = product.id;
            aptusLineItem.Apttus_Config2__PricingStatus__c = 'Complete';
            aptusLineItem.Apttus_Config2__ProductId__c = product.id;
            aptusLineItem.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            aptusLineItem.Apttus_Config2__EndDate__c = System.Today();
            aptusLineItem.Apttus_Config2__BasePrice__c = 12.23;
            aptusLineItem.AgencyCommission__c  = 12;
            aptusLineItem.Apttus_Config2__AdjustmentType__c = '% Discount Off List';
            aptusLineItem.Apttus_Config2__ExtendedPrice__c = 12.23;
            aptusLineItem.Apttus_Config2__AdjustmentAmount__c = 300;
            aptusLineItem.Apttus_Config2__ListPrice__c = 100;
            insert aptusLineItem;
            
             Apttus_Config2__LineItem__c aptusLineItem1 = TestDataSetupUtility.createLineItemApttus(config.Id);

            aptusLineItem1.Apttus_Config2__ItemSequence__c = 1.00; 
            aptusLineItem1.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem1.Apttus_Config2__LineStatus__c = 'New';
            aptusLineItem1.Apttus_Config2__BaseProductId__c = product.id;
            aptusLineItem1.Apttus_Config2__PricingStatus__c = 'Complete';
            aptusLineItem1.Apttus_Config2__ProductId__c = product.id;
            aptusLineItem1.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            aptusLineItem1.Apttus_Config2__EndDate__c = System.Today();
            aptusLineItem1.Apttus_Config2__BasePrice__c = 12.23;
            aptusLineItem1.AgencyCommission__c  = 12;
            aptusLineItem1.Apttus_Config2__AdjustmentType__c = 'Base Price Override'; //'% Discount Off List';
            aptusLineItem1.Apttus_Config2__ExtendedPrice__c = 12.23;
            aptusLineItem1.Apttus_Config2__AdjustmentAmount__c = 300;
            aptusLineItem1.Apttus_Config2__ListPrice__c = 100;
            insert aptusLineItem1;
            
            aptusLineItem = [select id,Apttus_Config2__ItemSequence__c,Apttus_Config2__LineNumber__c,
                            Apttus_Config2__LineStatus__c,Apttus_Config2__BaseProductId__c,Apttus_Config2__PricingStatus__c,
                            Apttus_Config2__ProductId__c,Apttus_Config2__AssetLineItemId__c,Apttus_Config2__EndDate__c,Apttus_Config2__BasePrice__c,
                            AgencyCommission__c,APTS_Is_Trial_Product__c from Apttus_Config2__LineItem__c where id =: aptusLineItem.Id];
            update aptusLineItem;
            
            Apttus_Config2__ProductAttributeValue__c test_ProductAttributeValue = new Apttus_Config2__ProductAttributeValue__c(
                                                    Apttus_Config2__LineItemId__c = aptusLineItem.Id);
            insert test_ProductAttributeValue;
             
             APTS_Discount_Threshold__c dt = new APTS_Discount_Threshold__c();
             dt.APTS_Attribute_API_Name__c = 'Country__c';
             dt.APTS_Attribute_Value__c = 'United States';
             dt.APTS_Max_Discount__c = 40;
             dt.APTS_Product__c = product.id;
             dt.APTS_Is_Product_Only_Max_Discount__c = false;
             insert dt;
            
            List<Apttus_Config2__LineItem__c> OLItemList = new List<Apttus_Config2__LineItem__c>{aptusLineItem};
            
            Update OLItemList;
            
            List<Apttus_Config2__TempRenew__c> tempList = new List<Apttus_Config2__TempRenew__c>();
            
            Apttus_Config2__TempRenew__c temprenew = new Apttus_Config2__TempRenew__c();
            temprenew.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.Id;
            temprenew.Name = 'temp renew 1';
            temprenew.Apttus_Config2__StartDate__c = System.today() - 1;
            temprenew.Apttus_Config2__EndDate__c = System.today();
            tempList.add(temprenew);
            
            Apttus_Config2__TempRenew__c temprenew1 = new Apttus_Config2__TempRenew__c();
            temprenew1.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.Id;
            temprenew1.Name = 'temp renew 2';
            temprenew1.Apttus_Config2__StartDate__c = System.today() + 20;
            temprenew1.Apttus_Config2__EndDate__c = System.today();
            tempList.add(temprenew1);
            
            Apttus_Config2__TempRenew__c temprenew2 = new Apttus_Config2__TempRenew__c();
            temprenew2.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.Id;
            temprenew2.Name = 'temp renew 2';
            temprenew2.Apttus_Config2__EndDate__c = System.today();
            tempList.add(temprenew2);
            insert tempList;

            Apttus_Config2.CallbackTester.testValidationCallback(config.Id, OLItemList, tempList, new APTS_ValidationCallBack());
            APTS_ValidationCAllback.getLineItemSO();

            Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO request = new Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO();
            request.CartId = config.id;
            request.LineNumber = OLItemList[0].Apttus_Config2__LineNumber__c;
            
            Apttus_CPQApi.CPQ.ComputeNetPriceResponseDO priceResponse = Apttus_CPQApi.CPQWebService.computeNetPriceForBundle(request);
            

        }
    }
    
        static testMethod void ZeroPriceTest() 
     {
         Apttus_Config2__ConfigSystemProperties__c ConfigSysProp = new Apttus_Config2__ConfigSystemProperties__c();
         ConfigSysProp.Name = 'System Properties';
         //ConfigSysProp.Apttus_Config2__ViewCartCustomFields__c = 'AgencyCommission__c,APTS_Is_Default_Adjustment_Done__c,APTS_Is_Trial_Product__c,Select__c,DerivedFromLineItemId__c,Apttus_Config2__ConfigurationId__r.Grand_Total_decimal__c,Apttus_Config2__ConfigurationId__r.Quote_Type__c,APTS_Product_Name__c,System_Discount__c,'; 
         ConfigSysProp.Apttus_Config2__ViewCartCustomFields__c = 'AgencyCommission__c,APTS_Is_Default_Adjustment_Done__c,APTS_Is_Trial_Product__c,Select__c,DerivedFromLineItemId__c,Apttus_Config2__ConfigurationId__r.Grand_Total_decimal__c,Apttus_Config2__ConfigurationId__r.Quote_Type__c,APTS_Product_Name__c,';          
         //ConfigSysProp.Apttus_Config2__ViewCartCustomFields2__c ='APTS_Max_Discount__c,APTS_Product_Code__c,APTS_Product_Family__c,quantity_backup__c,Apttus_Config2__AttributeValueId__r.Job_Aids__c,Apttus_Config2__AttributeValueId__r.Recordings__c,Apttus_Config2__AttributeValueId__r.type__c,Override_Discount_Cap__c,';
         ConfigSysProp.Apttus_Config2__ViewCartCustomFields2__c ='APTS_Max_Discount__c,APTS_Product_Code__c,Apttus_Config2__AttributeValueId__r.Job_Aids__c,Apttus_Config2__AttributeValueId__r.Recordings__c,Apttus_Config2__AttributeValueId__r.type__c,Override_Discount_Cap__c,System_Discount__c,APTS_Product_Family__c,';
        insert ConfigSysProp;         
         
        //create config custom class properties
        Apttus_Config2__ConfigCustomClasses__c configCustomClassesProperty = new Apttus_Config2__ConfigCustomClasses__c();
        configCustomClassesProperty.Name = 'Config Custom Classes';
        configCustomClassesProperty.Apttus_Config2__ValidationCallbackClass__c = 'APTS_ValidationCallBack';
        insert configCustomClassesProperty;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        insert manager;
        testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        testUser.Discount_Threshold__c  = 10.0;
        insert testuser;
        
        System.runAs(testUser){
            // Create test account
            account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
            system.debug('after account ' + account);
            insert account;
            
            
            //create Opportunity
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', account.Id);
            opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'Opportunity');
            insert opp;
            
            //Create product2
            Product2 product = TestDataSetupUtility.createProduct('Test product1', false); 
            product.Convert_From__c = true;
            product.Is_Trial_Product__c = true;
            product.ProductCode = 'QUOTE BUNDLE';
            product.Min_Quantity__c=5;
            insert product;
            
            //Create price list
            Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
            insert priceList; 
            
            Apttus_Config2__PriceListItem__c pli = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 0, Apttus_Config2__ProductId__c = product.Id, Apttus_Config2__ChargeType__c = 'Standard Price' ,Allow_Zero_Price_based_on_attribute__c =True);
            insert pli;
            
            //create proposal
            proposal = TestDataSetupUtility.createProposal('Test Proposal', account.Id, opp.Id, 'Accepted Online', false);
            proposal.Apttus_QPConfig__PriceListId__c = priceList.id;    
            proposal.APTS_Quote_Type__c = 'Product Extension';
            proposal.AgencyCommission__c = 12;
            insert proposal;    
        
            Apttus_Config2__ProductConfiguration__c config = TestDataSetupUtility.createTestProductConfig(proposal,account,priceList);
            insert config;
            
            
            
            Apttus_Config2__LineItem__c aptusLineItem = TestDataSetupUtility.createLineItemApttus(config.Id);

            aptusLineItem.Apttus_Config2__ItemSequence__c = 1.00; 
            aptusLineItem.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem.Apttus_Config2__LineStatus__c = 'New';
            aptusLineItem.Apttus_Config2__BaseProductId__c = product.id;
            aptusLineItem.Apttus_Config2__PricingStatus__c = 'Complete';
            aptusLineItem.Apttus_Config2__ProductId__c = product.id;
            aptusLineItem.Apttus_Config2__PriceListItemId__c = pli.id;
            aptusLineItem.Apttus_Config2__EndDate__c = System.Today();
            aptusLineItem.Apttus_Config2__BasePrice__c = 0; 
            aptusLineItem.Apttus_Config2__ListPrice__c = 0 ;
            aptusLineItem.Apttus_Config2__IsPrimaryLine__c  = True;
            aptusLineItem.Apttus_Config2__HasOptions__c= True;
            aptusLineItem.Apttus_Config2__LineType__c = 'Product/Service';
            aptusLineItem.Apttus_Config2__AdjustmentType__c = '% Discount Off List';
            aptusLineItem.Apttus_Config2__ExtendedPrice__c = 12.23;
            aptusLineItem.Apttus_Config2__AdjustmentAmount__c = 300;
            aptusLineItem.Apttus_Config2__ListPrice__c = 100;
            aptusLineItem.Apttus_Config2__Quantity__c=10;
            insert aptusLineItem;
            
            
           
           

            
            aptusLineItem = [select id,Apttus_Config2__ItemSequence__c,Apttus_Config2__LineNumber__c,
                            Apttus_Config2__LineStatus__c,Apttus_Config2__BaseProductId__c,Apttus_Config2__PricingStatus__c,Apttus_Config2__PriceListItemId__c,
                            Apttus_Config2__ProductId__c,Apttus_Config2__AssetLineItemId__c,Apttus_Config2__EndDate__c,Apttus_Config2__BasePrice__c,
                            AgencyCommission__c,APTS_Is_Trial_Product__c from Apttus_Config2__LineItem__c where id =: aptusLineItem.Id];
            update aptusLineItem;
            
            Apttus_Config2__ProductAttributeValue__c test_ProductAttributeValue = new Apttus_Config2__ProductAttributeValue__c(
                                                    Apttus_Config2__LineItemId__c = aptusLineItem.Id , a_r_interval__c = '100');
            insert test_ProductAttributeValue;
             
             APTS_Discount_Threshold__c dt = new APTS_Discount_Threshold__c();
             dt.APTS_Attribute_API_Name__c = 'Country__c';
             dt.APTS_Attribute_Value__c = 'United States';
             dt.APTS_Max_Discount__c = 40;
             dt.APTS_Product__c = product.id;
             dt.APTS_Is_Product_Only_Max_Discount__c = false;
             insert dt;
            
            List<Apttus_Config2__LineItem__c> OLItemList = new List<Apttus_Config2__LineItem__c>{aptusLineItem};
            
            Update OLItemList;
            
            List<Apttus_Config2__TempRenew__c> tempList = new List<Apttus_Config2__TempRenew__c>();
            
            Apttus_Config2__TempRenew__c temprenew = new Apttus_Config2__TempRenew__c();
            temprenew.Name = 'temp renew 1';
            temprenew.Apttus_Config2__StartDate__c = System.today() - 1;
            temprenew.Apttus_Config2__EndDate__c = System.today();
            tempList.add(temprenew);
            
            Apttus_Config2__TempRenew__c temprenew1 = new Apttus_Config2__TempRenew__c();
            temprenew1.Name = 'temp renew 2';
            temprenew1.Apttus_Config2__StartDate__c = System.today() + 20;
            temprenew1.Apttus_Config2__EndDate__c = System.today();
            tempList.add(temprenew1);
            
            Apttus_Config2__TempRenew__c temprenew2 = new Apttus_Config2__TempRenew__c();
            temprenew2.Name = 'temp renew 2';
            temprenew2.Apttus_Config2__EndDate__c = System.today();
            tempList.add(temprenew2);
            insert tempList;
            
             Zero_Attribute_Values__c oZero = new Zero_Attribute_Values__c(Price_List_Item__c = aptusLineItem.Apttus_Config2__PriceListItemId__c ,Attribute_Field__c = 'A/R Interval' ,Attribute_Value__c = '100'); 

            insert oZero;
             SYstem.debug('oZero'+oZero);
              SYstem.debug('aptusLineItem.Apttus_Config2__PriceListItemId__c'+aptusLineItem.Apttus_Config2__PriceListItemId__c);
              SYstem.debug('pli.id'+pli.id);
//            Test.startTest();
            Apttus_Config2.CallbackTester.testValidationCallback(config.Id, OLItemList, tempList, new APTS_ValidationCallBack());
            APTS_ValidationCAllback.getLineItemSO();

            Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO request = new Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO();
            request.CartId = config.id;
            request.LineNumber = OLItemList[0].Apttus_Config2__LineNumber__c;
            
            Apttus_CPQApi.CPQ.ComputeNetPriceResponseDO priceResponse = Apttus_CPQApi.CPQWebService.computeNetPriceForBundle(request);
            
  //          Test.stopTest();
        }
    }
    
    static testMethod void TemplateGenerationValidateZeroPrice() 
     {
        //create config custom class properties
        Apttus_Config2__ConfigCustomClasses__c configCustomClassesProperty = new Apttus_Config2__ConfigCustomClasses__c();
        configCustomClassesProperty.Name = 'Config Custom Classes';
        configCustomClassesProperty.Apttus_Config2__ValidationCallbackClass__c = 'APTS_ValidationCallBack';
        insert configCustomClassesProperty;
        
         Apttus_Config2__ConfigSystemProperties__c ConfigSysProp = new Apttus_Config2__ConfigSystemProperties__c();
         ConfigSysProp.Name = 'System Properties';
         ConfigSysProp.Apttus_Config2__ViewCartCustomFields__c = 'AgencyCommission__c,APTS_Is_Default_Adjustment_Done__c,APTS_Is_Trial_Product__c,Apttus_Config2__PriceListItemId__c,DerivedFromLineItemId__c,Apttus_Config2__ConfigurationId__r.Grand_Total_decimal__c,Apttus_Config2__ConfigurationId__r.Quote_Type__c,'; 
         ConfigSysProp.Apttus_Config2__ViewCartCustomFields2__c ='APTS_Product_Name__c,APTS_Max_Discount__c,System_Discount__c,quantity_backup__c,APTS_Product_Code__c,Apttus_Config2__AttributeValueId__r.Recordings__c,Override_Discount_Cap__c,Product_or_Option_Id__c,Apttus_Config2__PriceListItemId__c,';
        insert ConfigSysProp;         
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        insert manager;
        testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        testUser.Discount_Threshold__c  = 10.0;
        insert testuser;
        
         APTS_Validation_Error_Control__c errorController = new APTS_Validation_Error_Control__c();
            errorController.Profile_Name__c=''+[Select Name from Profile where Id =: userinfo.getProfileid()].name;
            errorController.name='test';
            insert errorController;
        
        System.runAs(testUser){
            // Create test account
            account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
            system.debug('after account ' + account);
            insert account;
            
            
            //create Opportunity
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', account.Id);
            opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'Opportunity');
            opp.OpportunityType__c = 'Re-Bill';
            insert opp;
            
            //Create product2
            Product2 product = TestDataSetupUtility.createProduct('Test product1', false); 
            product.Convert_From__c = true;
            product.Is_Trial_Product__c = true;
            product.ProductCode = 'QUOTE BUNDLE';
            product.Max_Allowed_Option_Quantity_Sum__c=10;
            product.Min_Allowed_Option_Quantity_Sum__c=11;
            insert product;
            
            //Create price list
            Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
            insert priceList; 
            
            Apttus_Config2__PriceListItem__c pli = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 0, Apttus_Config2__ProductId__c = product.Id, Apttus_Config2__ChargeType__c = 'Standard Price' ,Allow_Zero_Price_based_on_attribute__c =True);
            insert pli;
            
            //create proposal
            proposal = TestDataSetupUtility.createProposal('Test Proposal', account.Id, opp.Id, 'Accepted Online', false);
            proposal.Apttus_QPConfig__PriceListId__c = priceList.id;    
            proposal.APTS_Quote_Type__c='Re-Bill';
            proposal.AgencyCommission__c = 12;
            insert proposal;    
        
            Apttus_Config2__ProductConfiguration__c config = TestDataSetupUtility.createTestProductConfig(proposal,account,priceList);
            insert config;
            
            Apttus_Config2__AssetLineItem__c test_AssetLineItem = new Apttus_Config2__AssetLineItem__c(Name = 'test value');
            test_AssetLineItem.Apttus_Config2__AccountId__c = account.Id;
            test_AssetLineItem.Apttus_Config2__ProductId__c = product.id;
            test_AssetLineItem.Apttus_Config2__EndDate__c = Date.today() + 365;
            test_AssetLineItem.Available_Quantity__c = 2;
            insert test_AssetLineItem;
            
            Apttus_Config2__LineItem__c aptusLineItem = TestDataSetupUtility.createLineItemApttus(config.Id);

            aptusLineItem.Apttus_Config2__ItemSequence__c = 1.00;
            aptusLineItem.Apttus_Config2__AdjustmentAmount__c = 300;
            aptusLineItem.Apttus_Config2__AdjustmentType__c = '% Discount Off List';
            aptusLineItem.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem.Apttus_Config2__LineStatus__c = 'New';
            aptusLineItem.Apttus_Config2__BaseProductId__c = product.id;
            aptusLineItem.Apttus_Config2__PricingStatus__c = 'Complete';
            aptusLineItem.Apttus_Config2__ProductId__c = product.id;
            aptusLineItem.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            aptusLineItem.Apttus_Config2__EndDate__c = System.Today();
            aptusLineItem.Apttus_Config2__BasePrice__c = 12.23;
            aptusLineItem.AgencyCommission__c  = 12;
            aptusLineItem.Apttus_Config2__HasOptions__c=true;
            aptusLineItem.Apttus_Config2__IsPrimaryLine__c=true;
            aptusLineItem.Apttus_Config2__LineType__c='Option';
            aptusLineItem.Apttus_Config2__ExtendedPrice__c = 12.23;
            aptusLineItem.Apttus_Config2__ListPrice__c = 0;
            aptusLineItem.Apttus_Config2__PriceListItemId__c = pli.ID;
            insert aptusLineItem;
            
            aptusLineItem = [select id,Apttus_Config2__AdjustmentAmount__c,Apttus_Config2__AdjustmentType__c, Apttus_Config2__ItemSequence__c,Apttus_Config2__LineNumber__c,
                            Apttus_Config2__LineStatus__c,Apttus_Config2__BaseProductId__c,Apttus_Config2__PricingStatus__c,Apttus_Config2__PriceListItemId__c,
                            Apttus_Config2__ProductId__c,Apttus_Config2__AssetLineItemId__c,Apttus_Config2__EndDate__c,Apttus_Config2__BasePrice__c,
                            AgencyCommission__c,APTS_Is_Trial_Product__c from Apttus_Config2__LineItem__c where id =: aptusLineItem.Id];
            update aptusLineItem;
            
            Apttus_Config2__LineItem__c aptusLineItem2 = TestDataSetupUtility.createLineItemApttus(config.Id);

            aptusLineItem2.Apttus_Config2__ItemSequence__c = 1.00;
            aptusLineItem2.Apttus_Config2__StartDate__c = System.today() - 10;
            aptusLineItem2.Apttus_Config2__AdjustmentAmount__c = 300;
            aptusLineItem2.Apttus_Config2__AssetLineItemId__c  = test_AssetLineItem.Id;
            aptusLineItem2.Apttus_Config2__AdjustmentType__c = '% Discount Off List';
            aptusLineItem2.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem2.Apttus_Config2__LineStatus__c = 'Incremented';
            aptusLineItem2.Apttus_Config2__BaseProductId__c = product.id;
            aptusLineItem2.Apttus_Config2__PricingStatus__c = 'Complete';
            aptusLineItem2.Apttus_Config2__ProductId__c = product.id;
            aptusLineItem2.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            aptusLineItem2.Apttus_Config2__EndDate__c = System.Today() + 234;
            aptusLineItem2.Apttus_Config2__BasePrice__c = 12.23;
            aptusLineItem2.AgencyCommission__c  = 12;
            aptusLineItem2.Apttus_Config2__HasOptions__c=true;
            aptusLineItem2.Apttus_Config2__IsPrimaryLine__c=true;
            aptusLineItem2.Apttus_Config2__ExtendedPrice__c = 12.23;
            aptusLineItem2.Apttus_Config2__ListPrice__c = 100;
            insert aptusLineItem2;
            
            aptusLineItem2 = [select id,Apttus_Config2__StartDate__c,APTS_Asset_Line_Item_End_Date__c,Apttus_Config2__AdjustmentAmount__c,Apttus_Config2__AdjustmentType__c, Apttus_Config2__ItemSequence__c,Apttus_Config2__LineNumber__c,
                            Apttus_Config2__LineStatus__c,Apttus_Config2__BaseProductId__c,Apttus_Config2__PricingStatus__c,Apttus_Config2__PriceListItemId__c ,
                            Apttus_Config2__ProductId__c,Apttus_Config2__AssetLineItemId__c,Apttus_Config2__EndDate__c,Apttus_Config2__BasePrice__c,
                            AgencyCommission__c,APTS_Is_Trial_Product__c from Apttus_Config2__LineItem__c where id =: aptusLineItem2.Id];
            update aptusLineItem2;
            
            
            Apttus_Config2__ProductAttributeValue__c test_ProductAttributeValue = new Apttus_Config2__ProductAttributeValue__c(
                                                    Apttus_Config2__LineItemId__c = aptusLineItem.Id);
            insert test_ProductAttributeValue;
             
             APTS_Discount_Threshold__c dt = new APTS_Discount_Threshold__c();
             dt.APTS_Attribute_API_Name__c = 'Country__c';
             dt.APTS_Attribute_Value__c = 'United States';
             dt.APTS_Max_Discount__c = 40;
             dt.APTS_Product__c = product.id;
             dt.APTS_Is_Product_Only_Max_Discount__c = false;
             insert dt;
            
            List<Apttus_Config2__LineItem__c> OLItemList = new List<Apttus_Config2__LineItem__c>{aptusLineItem,aptusLineItem2};
            
            Update OLItemList;
            
            Zero_Attribute_Values__c oZero = new Zero_Attribute_Values__c(Price_List_Item__c = aptusLineItem.Apttus_Config2__PriceListItemId__c ,Attribute_Field__c = 'A/R Interval' ,Attribute_Value__c = '100'); 

            insert oZero;
            
            List<Apttus_Config2__TempRenew__c> tempList = new List<Apttus_Config2__TempRenew__c>();
            
            Apttus_Config2__TempRenew__c temprenew = new Apttus_Config2__TempRenew__c();
            temprenew.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.Id;
            temprenew.Name = 'temp renew 1';
            temprenew.Apttus_Config2__Quantity__c = 5;
            temprenew.Apttus_Config2__StartDate__c = System.today() - 1;
            tempList.add(temprenew);
            
            Apttus_Config2__TempRenew__c temprenew1 = new Apttus_Config2__TempRenew__c();
            temprenew1.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.Id;
            temprenew1.Name = 'temp renew 2';
            temprenew1.Apttus_Config2__Quantity__c = 5;
            temprenew1.Apttus_Config2__StartDate__c = System.today() + 20;
            temprenew1.Apttus_Config2__EndDate__c = System.today();
            tempList.add(temprenew1);
            
            Apttus_Config2__TempRenew__c temprenew2 = new Apttus_Config2__TempRenew__c();
            temprenew2.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.Id;
            temprenew2.Name = 'temp renew 2';
            temprenew2.Apttus_Config2__Quantity__c = 5;
            temprenew2.Apttus_Config2__EndDate__c = System.today();
            tempList.add(temprenew2);
            insert tempList;
//            Test.startTest();
            Apttus_Config2.CallbackTester.testValidationCallback(config.Id, OLItemList, tempList, new APTS_ValidationCallBack());
            APTS_ValidationCAllback.getLineItemSO();

            Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO request = new Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO();
            request.CartId = config.id;
            request.LineNumber = OLItemList[0].Apttus_Config2__LineNumber__c;
            
            Apttus_CPQApi.CPQ.ComputeNetPriceResponseDO priceResponse = Apttus_CPQApi.CPQWebService.computeNetPriceForBundle(request);
            
            /* Added by Apttus Support*/
           
          
           
            
            config = TestDataSetupUtility.createTestProductConfig(proposal,account,priceList);
            insert config;
            
            //Apttus_Config2.CallbackTester.testValidationCallback(config.Id, OLItemList, tempList, new APTS_ValidationCallBack());
            //APTS_ValidationCAllback.getLineItemSO();

            request = new Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO();
            request.CartId = config.id;
            request.LineNumber = OLItemList[0].Apttus_Config2__LineNumber__c;
            
            priceResponse = Apttus_CPQApi.CPQWebService.computeNetPriceForBundle(request);
            /*    ------    */
            
            
  //          Test.stopTest();
        }
    }
    
}