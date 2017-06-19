@isTest
private class APTS_PricingCallBackTest {
    /*static testMethod void testPricingCallBack(){
        Test.startTest();
        
        APTS_PricingCallBack objCallBack = new APTS_PricingCallBack();
        
        
        Test.stopTest();
    }*/
    static Apttus_Proposal__Proposal__c proposal,proposal1;
    static User manager, testUser;
    static Account account;
    
   
   static testMethod void testPricingCallBack(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        insert manager;
        testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        testUser.Discount_Threshold__c  = 10.0;
        insert testuser;
        

        
        Apttus_Config2__ConfigCustomClasses__c custSetting = new Apttus_Config2__ConfigCustomClasses__c();
        custSetting.Apttus_Config2__PricingCallbackClass__c = 'APTS_PricingCallBack';
        custSetting.Name = 'System Properties';
        custSetting.Apttus_Config2__ValidationCallbackClass__c = 'APTS_ValidationCallBack';
        insert custSetting;
        
        Apttus_Config2__ConfigSystemProperties__c custprop = new Apttus_Config2__ConfigSystemProperties__c();
        custprop.Name = 'System Properties';
        custprop.Apttus_Config2__ViewCartCustomFields__c = 'Apttus_Config2__ConfigurationId__c,Apttus_Config2__ProductId__r.ProductCode,APTS_Asset_Line_Item_Start_Date__c';
        custprop.Apttus_Config2__ViewCartCustomFields2__c = 'Apttus_Config2__ProductId__c,AgencyCommission__c,Quantity_Backup__c,APTS_Product_Service_Type__c,APTS_Is_Default_Adjustment_Done__c,APTS_Is_Trial_Product__c';
        insert custprop;
        
      /*  Apttus_Config2__ConstraintRule__c cr = new Apttus_Config2__ConstraintRule__c(name='APTS_Dummy_Do_Not_Delete', Apttus_Config2__Active__c=true);
            insert cr;
            
        Apttus_Config2__ConstraintRuleAction__c cra = new Apttus_Config2__ConstraintRuleAction__c();
        cra.Apttus_Config2__ConstraintRuleId__c = cr.id;
        cra.name='test';
        insert cra;*/
                
        System.runAs(testUser){
            // Create test account
            account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
            system.debug('after account ' + account);
            insert account;
            
            
            //create Opportunity
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', account.Id);
            opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'GCS Opportunity');
            insert opp;
            
            //Create product2
            Product2 product = TestDataSetupUtility.createProduct('Test product1', false); 
            product.Convert_From__c = true;
            product.Service_Type__c = 'Usage';
            insert product;
            
            Product2 product1 = TestDataSetupUtility.createProduct('Test product1', false); 
            product1.Convert_From__c = true;
            product1.Service_Type__c = 'Subscription';
            insert product1;
            
            //Create price list
            Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
            insert priceList; 
            
            Apttus_Config2__PriceListItem__c pli = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 10, Apttus_Config2__ProductId__c = product.Id, Apttus_Config2__ChargeType__c = 'Standard Price');
            insert pli;
            
            //create proposal
            proposal = TestDataSetupUtility.createProposal('Test Proposal', account.Id, opp.Id, 'Accepted Online', false);
            proposal.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Apttus_Proposal__Proposal__c', 'Proposal');
            proposal.Apttus_QPConfig__PriceListId__c = priceList.id;  
            proposal.MidContract_Proposal__c = true;
            proposal.Upgrade_Proposal__c = true;
            proposal.AgencyCommission__c = 12;
            insert proposal;    
        
            Apttus_Config2__ProductConfiguration__c config = TestDataSetupUtility.createTestProductConfig(proposal,account,priceList);
            insert config;
            
            Apttus_Config2__AssetLineItem__c test_AssetLineItem = new Apttus_Config2__AssetLineItem__c(Name = 'test value');
            test_AssetLineitem.Apttus_Config2__EndDate__c = date.today()+100;
            test_AssetLineitem.Apttus_Config2__StartDate__c = date.today();
             test_AssetLineItem.Apttus_Config2__Quantity__c=10;
            test_AssetLineitem.Apttus_Config2__NetPrice__c = 100 ;
            test_AssetLineitem.APTS_Adjustment_Type__c = 'Price Override' ;
            test_AssetLineitem.APTS_Adjustment_Amount__c = 15;
            test_AssetLineitem.Apttus_Config2__ListPrice__c = 115;
            test_AssetLineitem.Apttus_Config2__Quantity__c = 2;
            test_AssetLineitem.Apttus_Config2__BaseExtendedPrice__c = 125 ;
            insert test_AssetLineItem;
            
            List<Apttus_Config2__LineItem__c> OLItemList = new List<Apttus_Config2__LineItem__c>();
            
            
            Apttus_Config2__LineItem__c aptusLineItem = TestDataSetupUtility.createLineItemApttus(config.Id);

            aptusLineItem.Apttus_Config2__ItemSequence__c = 1.00;
            aptusLineItem.Apttus_Config2__Quantity__c = 10;
            aptusLineItem.APTS_Unit_Base_Price__c = 10;
            aptusLineItem.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem.Apttus_Config2__LineStatus__c = 'New';
            aptusLineItem.Apttus_Config2__BaseProductId__c = product.id;
            aptusLineItem.Apttus_Config2__PricingStatus__c = 'Pending';
            aptusLineItem.Apttus_Config2__ProductId__c = product.id;
            aptusLineItem.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            aptusLineItem.Apttus_Config2__EndDate__c = System.Today();
            aptusLineItem.Apttus_Config2__BasePrice__c = 12.23;
            aptusLineItem.AgencyCommission__c  = 12;

            
            OLItemList.add(aptusLineItem);
            
            Apttus_Config2__LineItem__c aptusLineItem2 = TestDataSetupUtility.createLineItemApttus(config.Id);

            aptusLineItem2.Apttus_Config2__ItemSequence__c = 1.00;
            aptusLineItem2.Apttus_Config2__Quantity__c = 10;
            aptusLineItem2.APTS_Unit_Base_Price__c = 10;
            aptusLineItem2.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem2.Apttus_Config2__LineStatus__c = 'Amended';
            aptusLineItem2.Apttus_Config2__BaseProductId__c = product.id;
            aptusLineItem2.Apttus_Config2__PricingStatus__c = 'Pending';
            aptusLineItem2.Apttus_Config2__ProductId__c = product.id;
            aptusLineItem2.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            //aptusLineItem2.Apttus_Config2__StartDate__c = System.Today();
            aptusLineItem2.Apttus_Config2__EndDate__c = System.Today();
            aptusLineItem2.Apttus_Config2__BasePrice__c = 12.23;
            aptusLineItem2.AgencyCommission__c  = 12;
            
            OLItemList.add(aptusLineItem2);
            
            Apttus_Config2__LineItem__c aptusLineItem3 = TestDataSetupUtility.createLineItemApttus(config.Id);

            aptusLineItem3.Apttus_Config2__ItemSequence__c = 1.00;
            aptusLineItem3.Apttus_Config2__Quantity__c = 10;
            aptusLineItem3.APTS_Unit_Base_Price__c = 10;
            aptusLineItem3.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem3.Apttus_Config2__LineStatus__c = 'Incremented';
            aptusLineItem3.Apttus_Config2__BaseProductId__c = product.id;
            aptusLineItem3.Apttus_Config2__PricingStatus__c = 'Pending';
            aptusLineItem3.Apttus_Config2__ProductId__c = product.id;
            aptusLineItem3.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            aptusLineItem3.Apttus_Config2__EndDate__c = System.Today();
            aptusLineItem3.Apttus_Config2__BasePrice__c = 12.23;
            aptusLineItem3.AgencyCommission__c  = 12;
            aptusLineItem3.Apttus_Config2__LineType__c = 'Option';
            aptusLineItem3.Quantity_Backup__c = 1;
            
            OLItemList.add(aptusLineItem3);
            
             Apttus_Config2__LineItem__c aptusLineItem4 = TestDataSetupUtility.createLineItemApttus(config.Id);

            aptusLineItem4.Apttus_Config2__ItemSequence__c = 1.00;
            aptusLineItem4.Apttus_Config2__Quantity__c = 10;
            aptusLineItem4.APTS_Unit_Base_Price__c = 10;
            aptusLineItem4.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem4.Apttus_Config2__LineStatus__c = 'Incremented';
            aptusLineItem4.Apttus_Config2__BaseProductId__c = product1.id;
            aptusLineItem4.Apttus_Config2__PricingStatus__c = 'Pending';
            aptusLineItem4.Apttus_Config2__ProductId__c = product1.id;
            aptusLineItem4.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            aptusLineItem4.Apttus_Config2__EndDate__c = System.Today()+100;
            aptusLineItem4.Apttus_Config2__BasePrice__c = 12.23;
            aptusLineItem4.AgencyCommission__c  = 12;
            aptusLineItem4.Apttus_Config2__LineType__c = 'Option';
            //aptusLineItem4.APTS_Asset_Line_Item_Start_Date__c = System.Today();
            aptusLineItem4.Quantity_Backup__c = 1;
            
            OLItemList.add(aptusLineItem4);
             
            insert OLItemList;
            
            
            Apttus_Config2__ProductOptionComponent__c poc = new Apttus_Config2__ProductOptionComponent__c();
            poc.Apttus_Config2__Sequence__c = 1;
            poc.Apttus_Config2__Modifiable__c = false;
            poc.Apttus_Config2__ComponentProductId__c = product.Id;
            
            insert poc;
            
            aptusLineItem3.Apttus_Config2__ProductOptionId__c = poc.Id;
            update aptusLineItem3;
            update OLItemList;
          /*  Apttus_Config2__ProductAttributeValue__c  pav = new Apttus_Config2__ProductAttributeValue__c (Apttus_Config2__LineItemId__c=OLItemList[0].id);
        insert pav;
        Apttus_Config2__AssetAttributeValue__c  aav = new Apttus_Config2__AssetAttributeValue__c (View_Count__c =100);
        insert aav;
        
        
        APTS_PricingCallBack objCallBack = new APTS_PricingCallBack();
        objCallBack.setViewCountInProductAttributeRec(10,10,null,pav,aav);
        */
        
                 
                 APTS_PricingCallBack.getLineItemSO();
            
            Apttus_Config2__ProductAttributeValue__c test_ProductAttributeValue = new Apttus_Config2__ProductAttributeValue__c(
                                                    Apttus_Config2__LineItemId__c = aptusLineItem.Id);
            test_ProductAttributeValue.Contract_Duration__c = '2 Months';
            insert test_ProductAttributeValue;
            
             Apttus_Config2__ProductAttributeValue__c test_ProductAttributeValue2 = new Apttus_Config2__ProductAttributeValue__c(
                                                    Apttus_Config2__LineItemId__c = aptusLineItem2.Id);
            test_ProductAttributeValue2.Contract_Duration__c = '2 Weeks';
            insert test_ProductAttributeValue2;
            
            Apttus_Config2__ProductAttributeValue__c test_ProductAttributeValue3 = new Apttus_Config2__ProductAttributeValue__c(
                                                    Apttus_Config2__LineItemId__c = aptusLineItem3.Id);
            test_ProductAttributeValue3.Contract_Duration__c = '2 Days';
            insert test_ProductAttributeValue3;
            
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
            
            Apttus_Config2.CallbackTester.testValidationCallback(config.Id, OLItemList, tempList, new APTS_ValidationCallBack());
            Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO request = new Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO();
            request.CartId = config.id;
            request.LineNumber = OLItemList[0].Apttus_Config2__LineNumber__c;
            
            test.startTest();
            Boolean resFlag = Apttus_Config2.PricingWebService.computeBasePriceForItemColl(config.Id,1);
            resFlag = Apttus_Config2.PricingWebService.computeNetPriceForItemColl(config.Id, 1);
            Apttus_Config2.PricingWebService.computeBasicPriceForItemColl(config, OLItemList);
            test.stopTest();
            
        } 
    } 
      
      static testMethod void testPricingCallBack2(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        insert manager;
        testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        testUser.Discount_Threshold__c  = 10.0;
        insert testuser;
        

        
        Apttus_Config2__ConfigCustomClasses__c custSetting = new Apttus_Config2__ConfigCustomClasses__c();
        custSetting.Apttus_Config2__PricingCallbackClass__c = 'APTS_PricingCallBack';
        custSetting.Name = 'System Properties';
        custSetting.Apttus_Config2__ValidationCallbackClass__c = 'APTS_ValidationCallBack';
        insert custSetting;
        
        Apttus_Config2__ConfigSystemProperties__c custprop = new Apttus_Config2__ConfigSystemProperties__c();
        custprop.Name = 'System Properties';
        custprop.Apttus_Config2__ViewCartCustomFields__c = 'Apttus_Config2__ConfigurationId__c,Apttus_Config2__ProductId__r.ProductCode,APTS_Asset_Line_Item_Start_Date__c';
        custprop.Apttus_Config2__ViewCartCustomFields2__c = 'Apttus_Config2__ProductId__c,AgencyCommission__c,Quantity_Backup__c,APTS_Product_Service_Type__c,APTS_Is_Default_Adjustment_Done__c,APTS_Is_Trial_Product__c';
        insert custprop;
        
      /*  Apttus_Config2__ConstraintRule__c cr = new Apttus_Config2__ConstraintRule__c(name='APTS_Dummy_Do_Not_Delete', Apttus_Config2__Active__c=true);
            insert cr;
            
        Apttus_Config2__ConstraintRuleAction__c cra = new Apttus_Config2__ConstraintRuleAction__c();
        cra.Apttus_Config2__ConstraintRuleId__c = cr.id;
        cra.name='test';
        insert cra;*/
                
        System.runAs(testUser){
            // Create test account
            account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
            system.debug('after account ' + account);
            insert account;
            
            
            //create Opportunity
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', account.Id);
            opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'GCS Opportunity');
            insert opp;
            
            //Create product2
            Product2 product = TestDataSetupUtility.createProduct('Test product1', false); 
            product.Convert_From__c = true;
            product.Service_Type__c = 'Subscription';
            insert product;
            
            
            //Create price list
            Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
            insert priceList; 
            
            Apttus_Config2__PriceListItem__c pli = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 10, Apttus_Config2__ProductId__c = product.Id, Apttus_Config2__ChargeType__c = 'Standard Price');
            insert pli;
            
            //create proposal
            proposal = TestDataSetupUtility.createProposal('Test Proposal', account.Id, opp.Id, 'Accepted Online', false);
            proposal.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Apttus_Proposal__Proposal__c', 'Proposal');
            proposal.Apttus_QPConfig__PriceListId__c = priceList.id;  
            proposal.MidContract_Proposal__c = true;
            proposal.Upgrade_Proposal__c = true;
            proposal.AgencyCommission__c = 12;
            insert proposal;    
        
            Apttus_Config2__ProductConfiguration__c config = TestDataSetupUtility.createTestProductConfig(proposal,account,priceList);
            insert config;
            
            Apttus_Config2__AssetLineItem__c test_AssetLineItem = new Apttus_Config2__AssetLineItem__c(Name = 'test value');
            test_AssetLineitem.Apttus_Config2__EndDate__c = date.today()+100;
            test_AssetLineitem.Apttus_Config2__StartDate__c = date.today();
            test_AssetLineItem.Apttus_Config2__Quantity__c=10;
            test_AssetLineitem.Apttus_Config2__NetPrice__c = 100 ;
            test_AssetLineitem.APTS_Adjustment_Amount__c = 15;
            test_AssetLineitem.Apttus_Config2__ListPrice__c = 115;
            test_AssetLineitem.Apttus_Config2__Quantity__c = 2;
            test_AssetLineitem.Apttus_Config2__BaseExtendedPrice__c = 125 ;
            
            insert test_AssetLineItem;
            
            List<Apttus_Config2__LineItem__c> OLItemList = new List<Apttus_Config2__LineItem__c>();
            
            
            Apttus_Config2__LineItem__c aptusLineItem = TestDataSetupUtility.createLineItemApttus(config.Id);

            aptusLineItem.Apttus_Config2__ItemSequence__c = 1.00;
            aptusLineItem.Apttus_Config2__Quantity__c = 10;
            aptusLineItem.APTS_Unit_Base_Price__c = 10;
            aptusLineItem.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem.Apttus_Config2__LineStatus__c = 'New';
            aptusLineItem.Apttus_Config2__BaseProductId__c = product.id;
            aptusLineItem.Apttus_Config2__PricingStatus__c = 'Pending';
            aptusLineItem.Apttus_Config2__ProductId__c = product.id;
            aptusLineItem.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            aptusLineItem.Apttus_Config2__EndDate__c = System.Today();
            aptusLineItem.Apttus_Config2__BasePrice__c = 12.23;
            aptusLineItem.AgencyCommission__c  = 12;

            
            OLItemList.add(aptusLineItem);
            
            Apttus_Config2__LineItem__c aptusLineItem2 = TestDataSetupUtility.createLineItemApttus(config.Id);

            aptusLineItem2.Apttus_Config2__ItemSequence__c = 1.00;
            aptusLineItem2.Apttus_Config2__Quantity__c = 10;
            aptusLineItem2.APTS_Unit_Base_Price__c = 10;
            aptusLineItem2.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem2.Apttus_Config2__LineStatus__c = 'Amended';
            aptusLineItem2.Apttus_Config2__BaseProductId__c = product.id;
            aptusLineItem2.Apttus_Config2__PricingStatus__c = 'Pending';
            aptusLineItem2.Apttus_Config2__ProductId__c = product.id;
            aptusLineItem2.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            aptusLineItem2.Apttus_Config2__EndDate__c = System.Today();
            aptusLineItem2.Apttus_Config2__BasePrice__c = 12.23;
            aptusLineItem2.AgencyCommission__c  = 12;
            
            OLItemList.add(aptusLineItem2);
            
            Apttus_Config2__LineItem__c aptusLineItem3 = TestDataSetupUtility.createLineItemApttus(config.Id);

            aptusLineItem3.Apttus_Config2__ItemSequence__c = 1.00;
            aptusLineItem3.Apttus_Config2__Quantity__c = 10;
            aptusLineItem3.APTS_Unit_Base_Price__c = 10;
            aptusLineItem3.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem3.Apttus_Config2__LineStatus__c = 'Incremented';
            aptusLineItem3.Apttus_Config2__BaseProductId__c = product.id;
            aptusLineItem3.Apttus_Config2__PricingStatus__c = 'Pending';
            aptusLineItem3.Apttus_Config2__ProductId__c = product.id;
            aptusLineItem3.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            aptusLineItem3.Apttus_Config2__EndDate__c = System.Today();
            //aptusLineItem3.Apttus_Config2__StartDate__c = System.Today() + 3;
            aptusLineItem3.Apttus_Config2__BasePrice__c = 12.23;
            aptusLineItem3.AgencyCommission__c  = 12;
            aptusLineItem3.Apttus_Config2__LineType__c = 'Option';
            aptusLineItem3.Quantity_Backup__c = 1;
            
            OLItemList.add(aptusLineItem3);

             
            insert OLItemList;
            
            
            
            Apttus_Config2__ProductOptionComponent__c poc = new Apttus_Config2__ProductOptionComponent__c();
            poc.Apttus_Config2__Sequence__c = 1;
            poc.Apttus_Config2__Modifiable__c = false;
            poc.Apttus_Config2__ComponentProductId__c = product.Id;
            
            insert poc;
            
            aptusLineItem3.Apttus_Config2__ProductOptionId__c = poc.Id;
            update aptusLineItem3;
            
            aptusLineItem3 = [select id,Apttus_Config2__StartDate__c, Apttus_Config2__ItemSequence__c, Apttus_Config2__Quantity__c , 
                            APTS_Unit_Base_Price__c , Apttus_Config2__LineNumber__c , Apttus_Config2__LineStatus__c, 
                            Apttus_Config2__BaseProductId__c , Apttus_Config2__PricingStatus__c ,Apttus_Config2__ProductId__c ,
                            Apttus_Config2__AssetLineItemId__c ,   Apttus_Config2__EndDate__c , Apttus_Config2__BasePrice__c , AgencyCommission__c  ,
                            Apttus_Config2__LineType__c , Quantity_Backup__c,Apttus_Config2__ProductOptionId__c from Apttus_Config2__LineItem__c where id =: aptusLineItem3.Id];
            
            update aptusLineItem3;
            update OLItemList;
          /*  Apttus_Config2__ProductAttributeValue__c  pav = new Apttus_Config2__ProductAttributeValue__c (Apttus_Config2__LineItemId__c=OLItemList[0].id);
        insert pav;
        Apttus_Config2__AssetAttributeValue__c  aav = new Apttus_Config2__AssetAttributeValue__c (View_Count__c =100);
        insert aav;
        
        
        APTS_PricingCallBack objCallBack = new APTS_PricingCallBack();
        objCallBack.setViewCountInProductAttributeRec(10,10,null,pav,aav);
        */
        
                 
                 APTS_PricingCallBack.getLineItemSO();
            
            Apttus_Config2__ProductAttributeValue__c test_ProductAttributeValue = new Apttus_Config2__ProductAttributeValue__c(
                                                    Apttus_Config2__LineItemId__c = aptusLineItem.Id);
            test_ProductAttributeValue.Contract_Duration__c = '2 Months';
            insert test_ProductAttributeValue;
            
             Apttus_Config2__ProductAttributeValue__c test_ProductAttributeValue2 = new Apttus_Config2__ProductAttributeValue__c(
                                                    Apttus_Config2__LineItemId__c = aptusLineItem2.Id);
            test_ProductAttributeValue2.Contract_Duration__c = '2 Weeks';
            insert test_ProductAttributeValue2;
            
            Apttus_Config2__ProductAttributeValue__c test_ProductAttributeValue3 = new Apttus_Config2__ProductAttributeValue__c(
                                                    Apttus_Config2__LineItemId__c = aptusLineItem3.Id);
            test_ProductAttributeValue3.Contract_Duration__c = '2 Days';
            insert test_ProductAttributeValue3;
            
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
            
            Apttus_Config2.CallbackTester.testValidationCallback(config.Id, OLItemList, tempList, new APTS_ValidationCallBack());
            Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO request = new Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO();
            request.CartId = config.id;
            request.LineNumber = OLItemList[0].Apttus_Config2__LineNumber__c;
            
            //test.startTest();
            Boolean resFlag = Apttus_Config2.PricingWebService.computeBasePriceForItemColl(config.Id,1);
            resFlag = Apttus_Config2.PricingWebService.computeNetPriceForItemColl(config.Id, 1);
            Apttus_Config2.PricingWebService.computeBasicPriceForItemColl(config, OLItemList);
            //test.stopTest();
            
        } 
    }
    
    static testMethod void testPricingCallBack3(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        insert manager;
        testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        testUser.Discount_Threshold__c  = 10.0;
        insert testuser;
        

        
        Apttus_Config2__ConfigCustomClasses__c custSetting = new Apttus_Config2__ConfigCustomClasses__c();
        custSetting.Apttus_Config2__PricingCallbackClass__c = 'APTS_PricingCallBack';
        custSetting.Name = 'System Properties';
        custSetting.Apttus_Config2__ValidationCallbackClass__c = 'APTS_ValidationCallBack';
        insert custSetting;
        
        Apttus_Config2__ConfigSystemProperties__c custprop = new Apttus_Config2__ConfigSystemProperties__c();
        custprop.Name = 'System Properties';
        custprop.Apttus_Config2__ViewCartCustomFields__c = 'Apttus_Config2__ConfigurationId__c,Apttus_Config2__ProductId__r.ProductCode';
        custprop.Apttus_Config2__ViewCartCustomFields2__c = 'Apttus_Config2__ProductId__c,AgencyCommission__c,Quantity_Backup__c,APTS_Product_Service_Type__c,APTS_Is_Default_Adjustment_Done__c,APTS_Is_Trial_Product__c';
        insert custprop;
        
      /*  Apttus_Config2__ConstraintRule__c cr = new Apttus_Config2__ConstraintRule__c(name='APTS_Dummy_Do_Not_Delete', Apttus_Config2__Active__c=true);
            insert cr;
            
        Apttus_Config2__ConstraintRuleAction__c cra = new Apttus_Config2__ConstraintRuleAction__c();
        cra.Apttus_Config2__ConstraintRuleId__c = cr.id;
        cra.name='test';
        insert cra;*/
                
        System.runAs(testUser){
            // Create test account
            account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
            system.debug('after account ' + account);
            insert account;
            
            
            //create Opportunity
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', account.Id);
            opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'GCS Opportunity');
            insert opp;
            
            //Create product2
            Product2 product = TestDataSetupUtility.createProduct('Test product1', false); 
            product.Convert_From__c = true;
            product.Service_Type__c = 'Subscription';
            insert product;
            
            
            
            
            
            //Create price list
            Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
            insert priceList; 
            
            Apttus_Config2__PriceListItem__c pli = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 10, Apttus_Config2__ProductId__c = product.Id, Apttus_Config2__ChargeType__c = 'Standard Price');
            insert pli;
            
            //create proposal
            proposal = TestDataSetupUtility.createProposal('Test Proposal', account.Id, opp.Id, 'Accepted Online', false);
            proposal.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Apttus_Proposal__Proposal__c', 'Proposal');
            proposal.Apttus_QPConfig__PriceListId__c = priceList.id;  
            proposal.MidContract_Proposal__c = true;
            proposal.Upgrade_Proposal__c = true;
            proposal.AgencyCommission__c = 12;
            insert proposal;    
        
            Apttus_Config2__ProductConfiguration__c config = TestDataSetupUtility.createTestProductConfig(proposal,account,priceList);
            insert config;
            
            Apttus_Config2__AssetLineItem__c test_AssetLineItem = new Apttus_Config2__AssetLineItem__c(Name = 'test value');
            test_AssetLineitem.Apttus_Config2__EndDate__c = date.today()+100;
            test_AssetLineitem.Apttus_Config2__StartDate__c = date.today();
            test_AssetLineItem.Apttus_Config2__Quantity__c=10;
            test_AssetLineitem.Apttus_Config2__NetPrice__c = 100 ;
            test_AssetLineitem.APTS_Adjustment_Amount__c = 15;
            test_AssetLineitem.Apttus_Config2__ListPrice__c = 115;
            test_AssetLineitem.Apttus_Config2__Quantity__c = 2;
            test_AssetLineitem.Apttus_Config2__BaseExtendedPrice__c = 125 ;
            insert test_AssetLineItem;
            
            
            Apttus_Config2__AssetAttributeValue__c test_AssetAttribute = new Apttus_Config2__AssetAttributeValue__c();
            test_AssetAttribute.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            test_AssetAttribute.A_R_Interval__c = '0';
            test_AssetAttribute.Ad_Type__c = 'Standard';
            test_AssetAttribute.Associated_ACLID__c = '233';
            test_AssetAttribute.Attribute_Position__c = 'HoverAd';
            test_AssetAttribute.Auto_Refresh_Interval__c = '14 days';
            
            insert test_AssetAttribute;
            
            System.debug('test_AssetLineItem' + test_AssetLineItem);
            
            List<Apttus_Config2__LineItem__c> OLItemList = new List<Apttus_Config2__LineItem__c>();
            
            
            Apttus_Config2__LineItem__c aptusLineItem = TestDataSetupUtility.createLineItemApttus(config.Id);

            aptusLineItem.Apttus_Config2__ItemSequence__c = 1.00;
            aptusLineItem.Apttus_Config2__Quantity__c = 10;
            aptusLineItem.APTS_Unit_Base_Price__c = 10;
            aptusLineItem.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem.Apttus_Config2__LineStatus__c = 'New';
            aptusLineItem.Apttus_Config2__BaseProductId__c = product.id;
            aptusLineItem.Apttus_Config2__PricingStatus__c = 'Pending';
            aptusLineItem.Apttus_Config2__ProductId__c = product.id;
            aptusLineItem.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            aptusLineItem.Apttus_Config2__EndDate__c = System.Today().adddays(10);
            aptusLineItem.Apttus_Config2__BasePrice__c = 12.23;
            aptusLineItem.Apttus_Config2__StartDate__c = System.Today();
            aptusLineItem.AgencyCommission__c  = 12;
            aptusLineItem.Apttus_Config2__ExtendedPrice__c = 10;

            
            OLItemList.add(aptusLineItem);
            
            Apttus_Config2__LineItem__c aptusLineItem2 = TestDataSetupUtility.createLineItemApttus(config.Id);

            aptusLineItem2.Apttus_Config2__ItemSequence__c = 1.00;
            aptusLineItem2.Apttus_Config2__Quantity__c = 10;
            aptusLineItem2.APTS_Unit_Base_Price__c = 10;
            aptusLineItem2.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem2.Apttus_Config2__LineStatus__c = 'Amended';
            aptusLineItem2.Apttus_Config2__BaseProductId__c = product.id;
            aptusLineItem2.Apttus_Config2__PricingStatus__c = 'Pending';
            aptusLineItem2.Apttus_Config2__ProductId__c = product.id;
            aptusLineItem2.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            aptusLineItem2.Apttus_Config2__EndDate__c = System.Today().adddays(10);
            aptusLineItem2.Apttus_Config2__BasePrice__c = 12.23;
            aptusLineItem2.Apttus_Config2__StartDate__c = System.Today();
            aptusLineItem2.AgencyCommission__c  = 12;
            aptusLineItem2.Apttus_Config2__ExtendedPrice__c = 10;
            OLItemList.add(aptusLineItem2);
            
            Apttus_Config2__LineItem__c aptusLineItem3 = TestDataSetupUtility.createLineItemApttus(config.Id);

            aptusLineItem3.Apttus_Config2__ItemSequence__c = 1.00;
            aptusLineItem3.Apttus_Config2__Quantity__c = 10;
            aptusLineItem3.APTS_Unit_Base_Price__c = 10;
            aptusLineItem3.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem3.Apttus_Config2__LineStatus__c = 'Incremented';
            aptusLineItem3.Apttus_Config2__BaseProductId__c = product.id;
            aptusLineItem3.Apttus_Config2__PricingStatus__c = 'Pending';
            aptusLineItem3.Apttus_Config2__ProductId__c = product.id;
            aptusLineItem3.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            aptusLineItem3.Apttus_Config2__EndDate__c = System.Today().adddays(10);
            aptusLineItem3.Apttus_Config2__StartDate__c = System.Today();
            aptusLineItem3.Apttus_Config2__BasePrice__c = 12.23;
            aptusLineItem3.AgencyCommission__c  = 12;
            aptusLineItem3.Apttus_Config2__LineType__c = 'Option';
            aptusLineItem3.Quantity_Backup__c = 1;
            aptusLineItem3.Apttus_Config2__ExtendedPrice__c = 10;
            OLItemList.add(aptusLineItem3);

             
            insert OLItemList;
            
            System.debug('OLItemList' + OLItemList);
            
            Apttus_Config2__ProductOptionComponent__c poc = new Apttus_Config2__ProductOptionComponent__c();
            poc.Apttus_Config2__Sequence__c = 1;
            poc.Apttus_Config2__Modifiable__c = false;
            poc.Apttus_Config2__ComponentProductId__c = product.Id;
            
            insert poc;
            
            aptusLineItem3.Apttus_Config2__ProductOptionId__c = poc.Id;
            update aptusLineItem3;
            
            aptusLineItem3 = [select id,Apttus_Config2__StartDate__c, Apttus_Config2__ItemSequence__c, Apttus_Config2__Quantity__c , 
                            APTS_Unit_Base_Price__c , Apttus_Config2__LineNumber__c , Apttus_Config2__LineStatus__c, 
                            Apttus_Config2__BaseProductId__c , Apttus_Config2__PricingStatus__c ,Apttus_Config2__ProductId__c ,
                            Apttus_Config2__AssetLineItemId__c ,   Apttus_Config2__EndDate__c , Apttus_Config2__BasePrice__c , AgencyCommission__c  ,
                            Apttus_Config2__LineType__c , Quantity_Backup__c,Apttus_Config2__ProductOptionId__c from Apttus_Config2__LineItem__c where id =: aptusLineItem3.Id];
            
            System.debug('aptusLineItem3 ' + aptusLineItem3 );
            update aptusLineItem3;
            update OLItemList;
          /*  Apttus_Config2__ProductAttributeValue__c  pav = new Apttus_Config2__ProductAttributeValue__c (Apttus_Config2__LineItemId__c=OLItemList[0].id);
        insert pav;
        Apttus_Config2__AssetAttributeValue__c  aav = new Apttus_Config2__AssetAttributeValue__c (View_Count__c =100);
        insert aav;
        
        
        APTS_PricingCallBack objCallBack = new APTS_PricingCallBack();
        objCallBack.setViewCountInProductAttributeRec(10,10,null,pav,aav);
        */
        
                 
                 APTS_PricingCallBack.getLineItemSO();
            
            Apttus_Config2__ProductAttributeValue__c test_ProductAttributeValue = new Apttus_Config2__ProductAttributeValue__c(
                                                    Apttus_Config2__LineItemId__c = aptusLineItem.Id);
            test_ProductAttributeValue.Contract_Duration__c = '2 Months';
            insert test_ProductAttributeValue;
            
             Apttus_Config2__ProductAttributeValue__c test_ProductAttributeValue2 = new Apttus_Config2__ProductAttributeValue__c(
                                                    Apttus_Config2__LineItemId__c = aptusLineItem2.Id);
            test_ProductAttributeValue2.Contract_Duration__c = '2 Weeks';
            insert test_ProductAttributeValue2;
            
            Apttus_Config2__ProductAttributeValue__c test_ProductAttributeValue3 = new Apttus_Config2__ProductAttributeValue__c(
                                                    Apttus_Config2__LineItemId__c = aptusLineItem3.Id);
            test_ProductAttributeValue3.Contract_Duration__c = '2 Days';
            insert test_ProductAttributeValue3;
            
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
            
            Apttus_Config2.CallbackTester.testValidationCallback(config.Id, OLItemList, tempList, new APTS_ValidationCallBack());
            Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO request = new Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO();
            request.CartId = config.id;
            request.LineNumber = OLItemList[0].Apttus_Config2__LineNumber__c;
            
            //test.startTest();
            Boolean resFlag = Apttus_Config2.PricingWebService.computeBasePriceForItemColl(config.Id,1);
            resFlag = Apttus_Config2.PricingWebService.computeNetPriceForItemColl(config.Id, 1);
            Apttus_Config2.PricingWebService.computeBasicPriceForItemColl(config, OLItemList);
            //test.stopTest();
            
        } 
    }
       
    static testMethod void testPricingCallBackMidContracts(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        insert manager;
        testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        testUser.Discount_Threshold__c  = 10.0;
        insert testuser;
        
        Apttus_Config2__ConfigCustomClasses__c custSetting = new Apttus_Config2__ConfigCustomClasses__c();
        custSetting.Apttus_Config2__PricingCallbackClass__c = 'APTS_PricingCallBack';
        custSetting.Name = 'System Properties';
        custSetting.Apttus_Config2__ValidationCallbackClass__c = 'APTS_ValidationCallBack';
        insert custSetting;
        
        Apttus_Config2__ConfigSystemProperties__c custprop = new Apttus_Config2__ConfigSystemProperties__c();
        custprop.Name = 'System Properties';
        custprop.Apttus_Config2__ViewCartCustomFields__c = 'Apttus_Config2__ConfigurationId__c,Apttus_Config2__ProductId__r.ProductCode,APTS_Asset_Line_Item_Start_Date__c';
        custprop.Apttus_Config2__ViewCartCustomFields2__c = 'Apttus_Config2__ProductId__c,APTS_Is_Default_Adjustment_Done__c';
        insert custprop;
        
        System.runAs(testUser){
            // Create test account
            account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
            system.debug('after account ' + account);
            insert account;
            
            
            //create Opportunity
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', account.Id);
            opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'GCS Opportunity');
            insert opp;
            
            //Create product2
            List<Product2> productsList = new List<Product2>();
            
            Product2 product = TestDataSetupUtility.createProduct('Test product1', false); 
            product.Convert_From__c = true;
            product.Service_Type__c = 'Usage';
            
            productsList.add(product);
            
            Product2 product2 = TestDataSetupUtility.createProduct('Test product1', false); 
            product2.Convert_From__c = true;
            product2.Service_Type__c = 'Subscription';
            
            
            productsList.add(product2);
            Product2 product3 = TestDataSetupUtility.createProduct('Test product1', false); 
            product3.Convert_From__c = true;
            product3.Service_Type__c = 'Immediate';
            
            
            productsList.add(product3);
            
            insert productsList;
            
            //Create price list
            Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
            insert priceList; 
            
            List<Apttus_Config2__PriceListItem__c> pliList = new List<Apttus_Config2__PriceListItem__c>();
            
            Apttus_Config2__PriceListItem__c pli = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 10, Apttus_Config2__ProductId__c = product.Id, Apttus_Config2__ChargeType__c = 'Standard Price');
            
            Apttus_Config2__PriceListItem__c pli2 = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 10, Apttus_Config2__ProductId__c = product2.Id, Apttus_Config2__ChargeType__c = 'Standard Price');
            Apttus_Config2__PriceListItem__c pli3 = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 10, Apttus_Config2__ProductId__c = product3.Id, Apttus_Config2__ChargeType__c = 'Standard Price');
            
            pliList.add(pli);
            pliList.add(pli2);
            pliList.add(pli3);
            
            
            insert pliList;
            
            //create proposal
            proposal = TestDataSetupUtility.createProposal('Test Proposal', account.Id, opp.Id, 'Accepted Online', false);
            proposal.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Apttus_Proposal__Proposal__c', 'Proposal');
            proposal.Apttus_QPConfig__PriceListId__c = priceList.id;    
            proposal.MidContract_Proposal__c  = true;
            proposal.Latest_End_Date__c  = System.today().addDays(365);
            proposal.AgencyCommission__c = 12;
            
            insert proposal;    
        
            Apttus_Config2__ProductConfiguration__c config = TestDataSetupUtility.createTestProductConfig(proposal,account,priceList);
            insert config;
            
            Apttus_Config2__AssetLineItem__c test_AssetLineItem = new Apttus_Config2__AssetLineItem__c(Name = 'test value');

            test_AssetLineitem.Apttus_Config2__EndDate__c = date.today()+100;
            test_AssetLineitem.Apttus_Config2__StartDate__c = date.today();
            test_AssetLineItem.Apttus_Config2__Quantity__c=10;

            insert test_AssetLineItem;
            
            List<Apttus_Config2__LineItem__c> OLItemList = new List<Apttus_Config2__LineItem__c>();
            
            
            Apttus_Config2__LineItem__c aptusLineItem = TestDataSetupUtility.createLineItemApttus(config.Id);

            aptusLineItem.Apttus_Config2__ItemSequence__c = 1.00; 
            aptusLineItem.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem.Apttus_Config2__LineStatus__c = 'New';
            aptusLineItem.Apttus_Config2__BaseProductId__c = product.id;
            aptusLineItem.Apttus_Config2__PricingStatus__c = 'Pending';
            aptusLineItem.Apttus_Config2__ProductId__c = product.id;
            aptusLineItem.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            aptusLineItem.Apttus_Config2__EndDate__c = System.Today();
            aptusLineItem.Apttus_Config2__BasePrice__c = 12.23;
            aptusLineItem.AgencyCommission__c  = 12;
            aptusLIneItem.Apttus_Config2__Quantity__c=10;            
            aptusLineItem.DerivedFromLineItemId__c = null;
            OLItemList.add(aptusLineItem);
            
            Apttus_Config2__LineItem__c aptusLineItem2 = TestDataSetupUtility.createLineItemApttus(config.Id);

            aptusLineItem2.Apttus_Config2__ItemSequence__c = 1.00; 
            aptusLineItem2.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem2.Apttus_Config2__LineStatus__c = 'New';
            aptusLineItem2.Apttus_Config2__BaseProductId__c = product.id;
            aptusLineItem2.Apttus_Config2__PricingStatus__c = 'Pending';
            aptusLineItem2.Apttus_Config2__ProductId__c = product2.id;
            aptusLineItem2.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            aptusLineItem2.Apttus_Config2__EndDate__c = System.Today();
            aptusLineItem2.Apttus_Config2__BasePrice__c = 12.23;
            aptusLineItem2.AgencyCommission__c  = 12;
            aptusLIneItem2.Apttus_Config2__Quantity__c=10;            
            aptusLineItem2.DerivedFromLineItemId__c = null;
            aptusLineItem2.Apttus_Config2__EndDate__c = System.today().addDays(366);
            
            OLItemList.add(aptusLineItem2);
            
            Apttus_Config2__LineItem__c aptusLineItem3 = TestDataSetupUtility.createLineItemApttus(config.Id);

            aptusLineItem3.Apttus_Config2__ItemSequence__c = 1.00; 
            aptusLineItem3.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem3.Apttus_Config2__LineStatus__c = 'New';
            aptusLineItem3.Apttus_Config2__BaseProductId__c = product.id;
            aptusLineItem3.Apttus_Config2__PricingStatus__c = 'Pending';
            aptusLineItem3.Apttus_Config2__ProductId__c = product2.id;
            aptusLineItem3.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            aptusLineItem3.Apttus_Config2__EndDate__c = System.Today();
            aptusLineItem3.Apttus_Config2__BasePrice__c = 12.23;
            aptusLineItem3.AgencyCommission__c  = 12;
                        aptusLIneItem3.Apttus_Config2__Quantity__c=10;
            OLItemList.add(aptusLineItem3);
            
            insert OLItemList;
            Apttus_Config2__ProductAttributeValue__c test_ProductAttributeValue = new Apttus_Config2__ProductAttributeValue__c(
                                                    Apttus_Config2__LineItemId__c = aptusLineItem.Id);
            insert test_ProductAttributeValue;
            
            
           
            Update OLItemList;
            
            
            test.startTest();
            Boolean resFlag = Apttus_Config2.PricingWebService.computeBasePriceForItemColl(config.Id,1);
            resFlag = Apttus_Config2.PricingWebService.computeNetPriceForItemColl(config.Id, 1);
            Apttus_Config2.PricingWebService.computeBasicPriceForItemColl(config, OLItemList);
                
            test.stopTest();
            
        }      
    }
    
    static testMethod void testPricingCallBackMidContracts2(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        insert manager;
        testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        testUser.Discount_Threshold__c  = 10.0;
        insert testuser;
        
        Apttus_Config2__ConfigCustomClasses__c custSetting = new Apttus_Config2__ConfigCustomClasses__c();
        custSetting.Apttus_Config2__PricingCallbackClass__c = 'APTS_PricingCallBack';
        custSetting.Name = 'System Properties';
        custSetting.Apttus_Config2__ValidationCallbackClass__c = 'APTS_ValidationCallBack';
        insert custSetting;
        
        Apttus_Config2__ConfigSystemProperties__c custprop = new Apttus_Config2__ConfigSystemProperties__c();
        custprop.Name = 'System Properties';
        custprop.Apttus_Config2__ViewCartCustomFields__c = 'Apttus_Config2__ConfigurationId__c,Apttus_Config2__ProductId__r.ProductCode,APTS_Asset_Line_Item_Start_Date__c';
        custprop.Apttus_Config2__ViewCartCustomFields2__c = 'Apttus_Config2__ProductId__c,APTS_Is_Default_Adjustment_Done__c';
        insert custprop;
        
        System.runAs(testUser){
            // Create test account
            account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
            system.debug('after account ' + account);
            insert account;
            
            
            //create Opportunity
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', account.Id);
            opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'GCS Opportunity');
            insert opp;
            
            //Create product2
            List<Product2> productsList = new List<Product2>();
            
            Product2 product = TestDataSetupUtility.createProduct('Test product1', false); 
            product.Convert_From__c = true;
            product.Service_Type__c = 'Usage';
            
            productsList.add(product);
            
            Product2 product2 = TestDataSetupUtility.createProduct('Test product1', false); 
            product2.Convert_From__c = true;
            product2.Service_Type__c = 'Subscription';
            
            
            productsList.add(product2);
            
            insert productsList;
            
            //Create price list
            Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
            insert priceList; 
            
            List<Apttus_Config2__PriceListItem__c> pliList = new List<Apttus_Config2__PriceListItem__c>();
            
            Apttus_Config2__PriceListItem__c pli = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 10, Apttus_Config2__ProductId__c = product.Id, Apttus_Config2__ChargeType__c = 'Standard Price');
            
            Apttus_Config2__PriceListItem__c pli2 = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 10, Apttus_Config2__ProductId__c = product2.Id, Apttus_Config2__ChargeType__c = 'Standard Price');
            
            pliList.add(pli);
            pliList.add(pli2);
            
            
            insert pliList;
            
            //create proposal
            proposal = TestDataSetupUtility.createProposal('Test Proposal', account.Id, opp.Id, 'Accepted Online', false);
            proposal.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Apttus_Proposal__Proposal__c', 'Proposal');
            proposal.Apttus_QPConfig__PriceListId__c = priceList.id;    
            proposal.MidContract_Proposal__c  = true;
            proposal.Latest_End_Date__c  = System.today().addDays(366);
            proposal.APTS_Quote_Type__c = 'Product Conversion';
            proposal.AgencyCommission__c = 12;
            
            insert proposal;    
        
            Apttus_Config2__ProductConfiguration__c config = TestDataSetupUtility.createTestProductConfig(proposal,account,priceList);
            insert config;
            
            Apttus_Config2__AssetLineItem__c test_AssetLineItem = new Apttus_Config2__AssetLineItem__c(Name = 'test value');
            test_AssetLineitem.Apttus_Config2__EndDate__c = date.today()+100;
            test_AssetLineitem.Apttus_Config2__StartDate__c = date.today();
            test_AssetLineItem.Apttus_Config2__Quantity__c=10;
            test_AssetLineitem.Apttus_Config2__NetPrice__c = 100 ;
            test_AssetLineitem.APTS_Adjustment_Type__c = 'Price Override' ;
            test_AssetLineitem.APTS_Adjustment_Amount__c = 15;
            test_AssetLineitem.Apttus_Config2__ListPrice__c = 115;
            test_AssetLineitem.Apttus_Config2__Quantity__c = 2;
            test_AssetLineitem.Apttus_Config2__BaseExtendedPrice__c = 125 ;

            insert test_AssetLineItem;
            
            List<Apttus_Config2__LineItem__c> OLItemList = new List<Apttus_Config2__LineItem__c>();
            
            
            Apttus_Config2__LineItem__c aptusLineItem = TestDataSetupUtility.createLineItemApttus(config.Id);

            aptusLineItem.Apttus_Config2__ItemSequence__c = 1.00; 
            aptusLineItem.Apttus_Config2__Quantity__c = 10;
            aptusLineItem.APTS_Unit_Base_Price__c = 10;
            aptusLineItem.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem.Apttus_Config2__LineStatus__c = 'New';
            aptusLineItem.Apttus_Config2__BaseProductId__c = product.id;
            aptusLineItem.Apttus_Config2__PricingStatus__c = 'Pending';
            aptusLineItem.Apttus_Config2__ProductId__c = product.id;
            aptusLineItem.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            aptusLineItem.Apttus_Config2__EndDate__c = System.Today();
            aptusLineItem.Apttus_Config2__BasePrice__c = 12.23;
            aptusLineItem.AgencyCommission__c  = 12;
            OLItemList.add(aptusLineItem);
            
            Apttus_Config2__LineItem__c aptusLineItem3 = TestDataSetupUtility.createLineItemApttus(config.Id);

            aptusLineItem3.Apttus_Config2__ItemSequence__c = 1.00; 
            aptusLineItem3.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem3.Apttus_Config2__LineStatus__c = 'Converted';
            aptusLineItem3.Apttus_Config2__BaseProductId__c = product.id;
            aptusLineItem3.Apttus_Config2__PricingStatus__c = 'Pending';
            aptusLineItem3.Apttus_Config2__ProductId__c = product2.id;
            aptusLineItem3.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            aptusLineItem3.Apttus_Config2__EndDate__c = System.Today();
            aptusLineItem3.Apttus_Config2__BasePrice__c = 12.23;
            aptusLineItem3.AgencyCommission__c  = 12;
            aptusLineItem3.Apttus_Config2__Quantity__c=10;
            aptusLineItem3.DerivedFromLineItemId__c = null;
            OLItemList.add(aptusLineItem3);
            
            Apttus_Config2__LineItem__c aptusLineItem2 = TestDataSetupUtility.createLineItemApttus(config.Id);

            aptusLineItem2.Apttus_Config2__ItemSequence__c = 1.00; 
            aptusLineItem2.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem2.Apttus_Config2__LineStatus__c = 'New';
            aptusLineItem2.Apttus_Config2__BaseProductId__c = product2.id;
            aptusLineItem2.Apttus_Config2__PricingStatus__c = 'Pending';
            aptusLineItem2.Apttus_Config2__ProductId__c = product2.id;
            aptusLineItem2.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            aptusLineItem2.Apttus_Config2__EndDate__c = System.Today();
            aptusLineItem2.Apttus_Config2__BasePrice__c = 12.23;
            aptusLineItem2.AgencyCommission__c  = 12;
            aptusLIneItem.Apttus_Config2__Quantity__c=10;            
            aptusLineItem2.DerivedFromLineItemId__c = null;
            aptusLineItem2.Apttus_Config2__EndDate__c = System.today().addDays(366);
            
            OLItemList.add(aptusLineItem2);
            
            insert OLItemList;
            Apttus_Config2__ProductAttributeValue__c test_ProductAttributeValue = new Apttus_Config2__ProductAttributeValue__c(
                                                    Apttus_Config2__LineItemId__c = aptusLineItem.Id);
            insert test_ProductAttributeValue;
            
            Apttus_Config2__ProductAttributeValue__c test_ProductAttributeValue2 = new Apttus_Config2__ProductAttributeValue__c(
                                                    Apttus_Config2__LineItemId__c = aptusLineItem3.Id);
            insert test_ProductAttributeValue2;
            
           
            Update OLItemList;
            
            
            test.startTest();
            Boolean resFlag = Apttus_Config2.PricingWebService.computeBasePriceForItemColl(config.Id,1);
            resFlag = Apttus_Config2.PricingWebService.computeNetPriceForItemColl(config.Id, 1);
            Apttus_Config2.PricingWebService.computeBasicPriceForItemColl(config, OLItemList);
                
            test.stopTest();
            
        }
    }
    
    static testMethod void testPricingCallBackMidContracts3(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        insert manager;
        testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        testUser.Discount_Threshold__c  = 10.0;
        insert testuser;
        
        Apttus_Config2__ConfigCustomClasses__c custSetting = new Apttus_Config2__ConfigCustomClasses__c();
        custSetting.Apttus_Config2__PricingCallbackClass__c = 'APTS_PricingCallBack';
        custSetting.Name = 'System Properties';
        custSetting.Apttus_Config2__ValidationCallbackClass__c = 'APTS_ValidationCallBack';
        insert custSetting;
        
        Apttus_Config2__ConfigSystemProperties__c custprop = new Apttus_Config2__ConfigSystemProperties__c();
        custprop.Name = 'System Properties';
        custprop.Apttus_Config2__ViewCartCustomFields__c = 'Apttus_Config2__ConfigurationId__c,Apttus_Config2__ProductId__r.ProductCode,APTS_Asset_Line_Item_Start_Date__c';
        custprop.Apttus_Config2__ViewCartCustomFields2__c = 'Apttus_Config2__ProductId__c,APTS_Is_Default_Adjustment_Done__c';
        insert custprop;
        
        System.runAs(testUser){
            // Create test account
            account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
            system.debug('after account ' + account);
            insert account;
            
            
            //create Opportunity
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', account.Id);
            opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'GCS Opportunity');
            insert opp;
            
            //Create product2
            List<Product2> productsList = new List<Product2>();
            
            Product2 product = TestDataSetupUtility.createProduct('Test product1', false); 
            product.Convert_From__c = true;
            product.Service_Type__c = 'Usage';
            
            productsList.add(product);
            
            
            insert productsList;
            
            //Create price list
            Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
            insert priceList; 
            
            List<Apttus_Config2__PriceListItem__c> pliList = new List<Apttus_Config2__PriceListItem__c>();
            
            Apttus_Config2__PriceListItem__c pli = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 10, Apttus_Config2__ProductId__c = product.Id, Apttus_Config2__ChargeType__c = 'Standard Price');
            
            pliList.add(pli);
            
            
            insert pliList;
            
            //create proposal
            proposal = TestDataSetupUtility.createProposal('Test Proposal', account.Id, opp.Id, 'Accepted Online', false);
            proposal.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Apttus_Proposal__Proposal__c', 'Proposal');
            proposal.Apttus_QPConfig__PriceListId__c = priceList.id;    
            proposal.MidContract_Proposal__c  = true;
            proposal.Latest_End_Date__c  = System.today().addDays(366);
            proposal.APTS_Quote_Type__c = 'Product Extension';
            proposal.AgencyCommission__c = 12;
            
            insert proposal;    
        
            Apttus_Config2__ProductConfiguration__c config = TestDataSetupUtility.createTestProductConfig(proposal,account,priceList);
            insert config;
            
            Apttus_Config2__AssetLineItem__c test_AssetLineItem = new Apttus_Config2__AssetLineItem__c(Name = 'test value');
                        test_AssetLineitem.Apttus_Config2__EndDate__c = date.today()+100;
            test_AssetLineitem.Apttus_Config2__StartDate__c = date.today();
            test_AssetLineItem.Apttus_Config2__Quantity__c=10;

            insert test_AssetLineItem;
            
            List<Apttus_Config2__LineItem__c> OLItemList = new List<Apttus_Config2__LineItem__c>();
            
            
            Apttus_Config2__LineItem__c aptusLineItem = TestDataSetupUtility.createLineItemApttus(config.Id);

            aptusLineItem.Apttus_Config2__ItemSequence__c = 1.00; 
            aptusLineItem.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem.Apttus_Config2__LineStatus__c = 'Renewed';
            aptusLineItem.Apttus_Config2__BaseProductId__c = product.id;
            aptusLineItem.Apttus_Config2__PricingStatus__c = 'Pending';
            aptusLineItem.Apttus_Config2__ProductId__c = product.id;
            aptusLineItem.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            aptusLineItem.Apttus_Config2__EndDate__c = System.Today();
            aptusLineItem.Apttus_Config2__BasePrice__c = 12.23;
            aptusLineItem.AgencyCommission__c  = 12;
            aptusLineItem.DerivedFromLineItemId__c = null;
                        aptusLIneItem.Apttus_Config2__Quantity__c=10;
            aptusLineItem.Apttus_Config2__StartDate__c = System.Today();
            aptusLineItem.Apttus_Config2__EndDate__c = System.Today();
            
            
            OLItemList.add(aptusLineItem);
            
            
            
            insert OLItemList;
            Apttus_Config2__ProductAttributeValue__c test_ProductAttributeValue = new Apttus_Config2__ProductAttributeValue__c(
                                                    Apttus_Config2__LineItemId__c = aptusLineItem.Id);
            test_ProductAttributeValue.Contract_Duration__c = 'Select One';            
            
            insert test_ProductAttributeValue;
            
            
           
            Update OLItemList;
            
            
            test.startTest();
            Boolean resFlag = Apttus_Config2.PricingWebService.computeBasePriceForItemColl(config.Id,1);
            resFlag = Apttus_Config2.PricingWebService.computeNetPriceForItemColl(config.Id, 1);
            Apttus_Config2.PricingWebService.computeBasicPriceForItemColl(config, OLItemList);
                
            test.stopTest();
            
        }
    }
    
    
    static testMethod void testPricingCallBackAdjustmentMode(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        insert manager;
        testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        testUser.Discount_Threshold__c  = 10.0;
        insert testuser;
        
        Apttus_Config2__ConfigCustomClasses__c custSetting = new Apttus_Config2__ConfigCustomClasses__c();
        custSetting.Apttus_Config2__PricingCallbackClass__c = 'APTS_PricingCallBack';
        custSetting.Name = 'System Properties';
        custSetting.Apttus_Config2__ValidationCallbackClass__c = 'APTS_ValidationCallBack';
        insert custSetting;
        
        Apttus_Config2__ConfigSystemProperties__c custprop = new Apttus_Config2__ConfigSystemProperties__c();
        custprop.Name = 'System Properties';
        custprop.Apttus_Config2__ViewCartCustomFields__c = 'Apttus_Config2__ConfigurationId__c,Apttus_Config2__ProductId__r.ProductCode,APTS_Asset_Line_Item_Start_Date__c';
        custprop.Apttus_Config2__ViewCartCustomFields2__c = 'Apttus_Config2__ProductId__c,APTS_Product_Service_Type__c,DerivedFromLineItemId__c';
        insert custprop;
        
        System.runAs(testUser){
            // Create test account
            account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
            system.debug('after account ' + account);
            insert account;
            
            
            //create Opportunity
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', account.Id);
            opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'GCS Opportunity');
            insert opp;
            
            //Create product2
            List<Product2> productsList = new List<Product2>();
            
            Product2 product = TestDataSetupUtility.createProduct('Test product1', false); 
            product.Convert_From__c = true;
            product.Service_Type__c = 'Usage';
            
            productsList.add(product);
            
            
            insert productsList;
            
            //Create price list
            Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
            insert priceList; 
            
            List<Apttus_Config2__PriceListItem__c> pliList = new List<Apttus_Config2__PriceListItem__c>();
            
            Apttus_Config2__PriceListItem__c pli = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 10, Apttus_Config2__ProductId__c = product.Id, Apttus_Config2__ChargeType__c = 'Standard Price');
            
            pliList.add(pli);
            
            
            insert pliList;
            
            //create proposal
            proposal = TestDataSetupUtility.createProposal('Test Proposal', account.Id, opp.Id, 'Accepted Online', false);
            proposal.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Apttus_Proposal__Proposal__c', 'Proposal');
            proposal.Apttus_QPConfig__PriceListId__c = priceList.id;    
            proposal.MidContract_Proposal__c  = true;
            proposal.Latest_End_Date__c  = System.today().addDays(366);
            proposal.APTS_Quote_Type__c = 'Product Extension';
            proposal.AgencyCommission__c = 12;
            
            insert proposal;    
        
            Apttus_Config2__ProductConfiguration__c config = TestDataSetupUtility.createTestProductConfig(proposal,account,priceList);
            insert config;
            
            Apttus_Config2__AssetLineItem__c test_AssetLineItem = new Apttus_Config2__AssetLineItem__c(Name = 'test value');
                        test_AssetLineitem.Apttus_Config2__EndDate__c = date.today()+100;
            test_AssetLineitem.Apttus_Config2__StartDate__c = date.today();
            test_AssetLineItem.Apttus_Config2__Quantity__c=10;
            insert test_AssetLineItem;
            
            Apttus_Config2__AssetAttributeValue__c test_AssetAttribute = new Apttus_Config2__AssetAttributeValue__c();
            test_AssetAttribute.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            test_AssetAttribute.A_R_Interval__c = '0';
            test_AssetAttribute.Ad_Type__c = 'Standard';
            test_AssetAttribute.Associated_ACLID__c = '233';
            test_AssetAttribute.Attribute_Position__c = 'HoverAd';
            test_AssetAttribute.Auto_Refresh_Interval__c = '14 days';
            test_AssetAttribute.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            
            insert test_AssetAttribute;

            
            
            List<Apttus_Config2__LineItem__c> OLItemList = new List<Apttus_Config2__LineItem__c>();
            
            
            Apttus_Config2__LineItem__c aptusLineItem = TestDataSetupUtility.createLineItemApttus(config.Id);

            aptusLineItem.Apttus_Config2__ItemSequence__c = 1.00; 
            aptusLineItem.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem.Apttus_Config2__LineStatus__c = 'New';
            aptusLineItem.Apttus_Config2__BaseProductId__c = product.id;
            aptusLineItem.Apttus_Config2__PricingStatus__c = 'Pending';
            aptusLineItem.Apttus_Config2__ProductId__c = product.id;
            aptusLineItem.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            aptusLineItem.Apttus_Config2__EndDate__c = System.Today();
            aptusLineItem.Apttus_Config2__BasePrice__c = 12.23;
            aptusLineItem.AgencyCommission__c  = 12;
            aptusLineItem.DerivedFromLineItemId__c = null;
            aptusLineItem.Apttus_Config2__AdjustmentAmount__c = 10;
            aptusLineItem.Apttus_Config2__AdjustmentType__c='% Discount';
            //aptusLineItem.Apttus_Config2__NetPrice__c = 50;
                        aptusLIneItem.Apttus_Config2__Quantity__c=10;
            
            OLItemList.add(aptusLineItem);
            
            
            
            insert OLItemList;
            Apttus_Config2__ProductAttributeValue__c test_ProductAttributeValue = new Apttus_Config2__ProductAttributeValue__c(
                                                    Apttus_Config2__LineItemId__c = aptusLineItem.Id);
            
            
            insert test_ProductAttributeValue;
            
            
           
            Update OLItemList;
            
            
            test.startTest();
            Boolean resFlag = Apttus_Config2.PricingWebService.computeBasePriceForItemColl(config.Id,1);
            resFlag = Apttus_Config2.PricingWebService.computeNetPriceForItemColl(config.Id, 1);
            Apttus_Config2.PricingWebService.computeBasicPriceForItemColl(config, OLItemList);
                
            test.stopTest();
            
        }
    }
    static testMethod void testPricingCallBackMidContracts4(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        insert manager;
        testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        testUser.Discount_Threshold__c  = 10.0;
        insert testuser;
        
       Apttus_Config2__ConfigCustomClasses__c custSetting = new Apttus_Config2__ConfigCustomClasses__c();
        custSetting.Apttus_Config2__PricingCallbackClass__c = 'APTS_PricingCallBack';
        custSetting.Name = 'System Properties';
        custSetting.Apttus_Config2__ValidationCallbackClass__c = 'APTS_ValidationCallBack';
        insert custSetting;
        
        Apttus_Config2__ConfigSystemProperties__c custprop = new Apttus_Config2__ConfigSystemProperties__c();
        custprop.Name = 'System Properties';
        custprop.Apttus_Config2__ViewCartCustomFields__c = 'Apttus_Config2__ConfigurationId__c,Apttus_Config2__ProductId__r.ProductCode,APTS_Asset_Line_Item_Start_Date__c';
        custprop.Apttus_Config2__ViewCartCustomFields2__c = 'Apttus_Config2__ProductId__c,AgencyCommission__c,APTS_Product_Service_Type__c,APTS_Is_Default_Adjustment_Done__c';
        insert custprop;
        
        System.runAs(testUser){
            // Create test account
            account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
            system.debug('after account ' + account);
            insert account;
            
            
            //create Opportunity
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', account.Id);
            opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'GCS Opportunity');
            insert opp;
            
            //Create product2
            List<Product2> productsList = new List<Product2>();
            
            Product2 product = TestDataSetupUtility.createProduct('Test product1', false); 
            product.Convert_From__c = true;
            product.Service_Type__c = 'Usage';
            
            productsList.add(product);
            
            
            insert productsList;
            
            //Create price list
            Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
            insert priceList; 
            
            List<Apttus_Config2__PriceListItem__c> pliList = new List<Apttus_Config2__PriceListItem__c>();
            
            Apttus_Config2__PriceListItem__c pli = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 10, Apttus_Config2__ProductId__c = product.Id, Apttus_Config2__ChargeType__c = 'Standard Price');
            
            pliList.add(pli);
            
            
            insert pliList;
            
            //create proposal
            proposal = TestDataSetupUtility.createProposal('Test Proposal', account.Id, opp.Id, 'Accepted Online', false);
            proposal.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Apttus_Proposal__Proposal__c', 'Proposal');
            proposal.Apttus_QPConfig__PriceListId__c = priceList.id;    
            proposal.MidContract_Proposal__c  = true;
            proposal.Latest_End_Date__c  = System.today().addDays(366);
            proposal.APTS_Quote_Type__c = 'Product Extension';
            proposal.AgencyCommission__c = 12;
            
            insert proposal;    
        
            Apttus_Config2__ProductConfiguration__c config = TestDataSetupUtility.createTestProductConfig(proposal,account,priceList);
            insert config;
            
            Apttus_Config2__AssetLineItem__c test_AssetLineItem = new Apttus_Config2__AssetLineItem__c(Name = 'test value');
                       test_AssetLineitem.Apttus_Config2__EndDate__c = date.today()+100;
            test_AssetLineitem.Apttus_Config2__StartDate__c = date.today();
            test_AssetLineItem.Apttus_Config2__Quantity__c=10;

            insert test_AssetLineItem;
            
            List<Apttus_Config2__LineItem__c> OLItemList = new List<Apttus_Config2__LineItem__c>();
            
            
            Apttus_Config2__LineItem__c aptusLineItem = TestDataSetupUtility.createLineItemApttus(config.Id);

            aptusLineItem.Apttus_Config2__ItemSequence__c = 1.00; 
            aptusLineItem.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem.Apttus_Config2__LineStatus__c = 'Renewed';
            aptusLineItem.Apttus_Config2__BaseProductId__c = product.id;
            aptusLineItem.Apttus_Config2__PricingStatus__c = 'Pending';
            aptusLineItem.Apttus_Config2__ProductId__c = product.id;
            aptusLineItem.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
             //aptusLineItem.APTS_Product_Service_Type__c = 'Subscription';
            //aptusLineItem.Apttus_Config2__EndDate__c = System.Today();
            aptusLineItem.Apttus_Config2__BasePrice__c = 12.23;
            aptusLIneItem.Apttus_Config2__Quantity__c=10;
            aptusLineItem.AgencyCommission__c  = 12;
            aptusLineItem.DerivedFromLineItemId__c = null;
            
            aptusLineItem.Apttus_Config2__StartDate__c = System.Today();
            aptusLineItem.Apttus_Config2__EndDate__c = System.Today().addDays(512);
            
            
            OLItemList.add(aptusLineItem);
            
            
            
            insert OLItemList;
            Apttus_Config2__ProductAttributeValue__c test_ProductAttributeValue = new Apttus_Config2__ProductAttributeValue__c(
                                                    Apttus_Config2__LineItemId__c = aptusLineItem.Id);
            test_ProductAttributeValue.Contract_Duration__c = '5 Weeks';            
            
            insert test_ProductAttributeValue;
            
            
           
            Update OLItemList;
            
            
            test.startTest();
            Boolean resFlag = Apttus_Config2.PricingWebService.computeBasePriceForItemColl(config.Id,1);
            resFlag = Apttus_Config2.PricingWebService.computeNetPriceForItemColl(config.Id, 1);
            Apttus_Config2.PricingWebService.computeBasicPriceForItemColl(config, OLItemList);
                
            test.stopTest(); 
            
        }
    }
    
     static testMethod void testPricingCallBackMidContracts5(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        insert manager;
        testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        testUser.Discount_Threshold__c  = 10.0;
        insert testuser;
        
       Apttus_Config2__ConfigCustomClasses__c custSetting = new Apttus_Config2__ConfigCustomClasses__c();
        custSetting.Apttus_Config2__PricingCallbackClass__c = 'APTS_PricingCallBack';
        custSetting.Name = 'System Properties';
        custSetting.Apttus_Config2__ValidationCallbackClass__c = 'APTS_ValidationCallBack';
        insert custSetting;
        
        Apttus_Config2__ConfigSystemProperties__c custprop = new Apttus_Config2__ConfigSystemProperties__c();
        custprop.Name = 'System Properties';
        custprop.Apttus_Config2__ViewCartCustomFields__c = 'Apttus_Config2__ConfigurationId__c,Apttus_Config2__ProductId__r.ProductCode,APTS_Asset_Line_Item_Start_Date__c';
        custprop.Apttus_Config2__ViewCartCustomFields2__c = 'Apttus_Config2__ProductId__c,AgencyCommission__c,APTS_Product_Service_Type__c,APTS_Is_Default_Adjustment_Done__c';
        insert custprop;
        
        System.runAs(testUser){
            // Create test account
            account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
            system.debug('after account ' + account);
            insert account;
            
            
            //create Opportunity
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', account.Id);
            opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'GCS Opportunity');
            insert opp;
            
            //Create product2
            List<Product2> productsList = new List<Product2>();
            
            Product2 product = TestDataSetupUtility.createProduct('Test product1', false); 
            product.Convert_From__c = true;
            product.Service_Type__c = 'Subscription';
            
            productsList.add(product);
            
            
            insert productsList;
            
            //Create price list
            Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
            insert priceList; 
            
            List<Apttus_Config2__PriceListItem__c> pliList = new List<Apttus_Config2__PriceListItem__c>();
            
            Apttus_Config2__PriceListItem__c pli = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 10, Apttus_Config2__ProductId__c = product.Id, Apttus_Config2__ChargeType__c = 'Standard Price');
            
            pliList.add(pli);
            
            
            insert pliList;
            
            //create proposal
            proposal = TestDataSetupUtility.createProposal('Test Proposal', account.Id, opp.Id, 'Accepted Online', false);
            proposal.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Apttus_Proposal__Proposal__c', 'Proposal');
            proposal.Apttus_QPConfig__PriceListId__c = priceList.id;    
            proposal.MidContract_Proposal__c  = true;
            proposal.Latest_End_Date__c  = System.today();
            proposal.APTS_Quote_Type__c = 'Product Extension';
            proposal.AgencyCommission__c = 12;
            
            insert proposal;    
        
            Apttus_Config2__ProductConfiguration__c config = TestDataSetupUtility.createTestProductConfig(proposal,account,priceList);
            insert config;
            
            Apttus_Config2__AssetLineItem__c test_AssetLineItem = new Apttus_Config2__AssetLineItem__c(Name = 'test value');
                       test_AssetLineitem.Apttus_Config2__EndDate__c = date.today()+100;
            test_AssetLineitem.Apttus_Config2__StartDate__c = date.today();
            test_AssetLineItem.Apttus_Config2__Quantity__c=10;

            insert test_AssetLineItem;
            
            List<Apttus_Config2__LineItem__c> OLItemList = new List<Apttus_Config2__LineItem__c>();
            
            
            Apttus_Config2__LineItem__c aptusLineItem = TestDataSetupUtility.createLineItemApttus(config.Id);

            aptusLineItem.Apttus_Config2__ItemSequence__c = 1.00; 
            aptusLineItem.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem.Apttus_Config2__LineStatus__c = 'New';
            aptusLineItem.Apttus_Config2__BaseProductId__c = product.id;
            aptusLineItem.Apttus_Config2__PricingStatus__c = 'Pending';
            aptusLineItem.Apttus_Config2__ProductId__c = product.id;
            aptusLineItem.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
             //aptusLineItem.APTS_Product_Service_Type__c = 'Subscription';
            //aptusLineItem.Apttus_Config2__EndDate__c = System.Today();
            aptusLineItem.Apttus_Config2__BasePrice__c = 12.23;
            aptusLIneItem.Apttus_Config2__Quantity__c=10;
            aptusLineItem.AgencyCommission__c  = 12;
            aptusLineItem.DerivedFromLineItemId__c = null;
            
            aptusLineItem.Apttus_Config2__StartDate__c = System.Today();
            aptusLineItem.Apttus_Config2__EndDate__c = System.Today().addDays(512);
            
            
            OLItemList.add(aptusLineItem);
            
            
            
            insert OLItemList;
            Apttus_Config2__ProductAttributeValue__c test_ProductAttributeValue = new Apttus_Config2__ProductAttributeValue__c(
                                                    Apttus_Config2__LineItemId__c = aptusLineItem.Id);
            test_ProductAttributeValue.Contract_Duration__c = '5 Weeks';            
            
            insert test_ProductAttributeValue;
            
            
           
            Update OLItemList;
            
            
            test.startTest();
            Boolean resFlag = Apttus_Config2.PricingWebService.computeBasePriceForItemColl(config.Id,1);
            resFlag = Apttus_Config2.PricingWebService.computeNetPriceForItemColl(config.Id, 1);
            Apttus_Config2.PricingWebService.computeBasicPriceForItemColl(config, OLItemList);
                
            test.stopTest(); 
            
        }
    }
    
    static testMethod void testPricingCallBackUpgradeProposal(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        insert manager;
        testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        testUser.Discount_Threshold__c  = 10.0;
        insert testuser;
        
       Apttus_Config2__ConfigCustomClasses__c custSetting = new Apttus_Config2__ConfigCustomClasses__c();
        custSetting.Apttus_Config2__PricingCallbackClass__c = 'APTS_PricingCallBack';
        custSetting.Name = 'System Properties';
        custSetting.Apttus_Config2__ValidationCallbackClass__c = 'APTS_ValidationCallBack';
        insert custSetting;
        
        Apttus_Config2__ConfigSystemProperties__c custprop = new Apttus_Config2__ConfigSystemProperties__c();
        custprop.Name = 'System Properties';
        custprop.Apttus_Config2__ViewCartCustomFields__c = 'Apttus_Config2__ConfigurationId__c,Apttus_Config2__ProductId__r.ProductCode,APTS_Asset_Line_Item_Start_Date__c';
        custprop.Apttus_Config2__ViewCartCustomFields2__c = 'Apttus_Config2__ProductId__c,AgencyCommission__c,APTS_Product_Service_Type__c,APTS_Is_Default_Adjustment_Done__c';
        insert custprop;
        
        System.runAs(testUser){
            // Create test account
            account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
            system.debug('after account ' + account);
            insert account;
            
            
            //create Opportunity
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', account.Id);
            opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'GCS Opportunity');
            insert opp;
            
            //Create product2
            List<Product2> productsList = new List<Product2>();
            
            Product2 product = TestDataSetupUtility.createProduct('Test product1', false); 
            product.Convert_From__c = true;
            product.Service_Type__c = 'Usage';
            
            productsList.add(product);
            
            Product2 product22 = TestDataSetupUtility.createProduct('Test product1', false); 
            product22.Convert_From__c = true;
            product22.Service_Type__c = 'Subscription';
            
            productsList.add(product22);
            
            
            insert productsList;
            
            //Create price list
            Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
            insert priceList; 
            
            List<Apttus_Config2__PriceListItem__c> pliList = new List<Apttus_Config2__PriceListItem__c>();
            
            Apttus_Config2__PriceListItem__c pli = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 10, Apttus_Config2__ProductId__c = product.Id, Apttus_Config2__ChargeType__c = 'Standard Price');
            
            pliList.add(pli);
            
            
            insert pliList;
            
            //create proposal
            proposal = TestDataSetupUtility.createProposal('Test Proposal', account.Id, opp.Id, 'Accepted Online', false);
            proposal.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Apttus_Proposal__Proposal__c', 'Proposal');
            proposal.Apttus_QPConfig__PriceListId__c = priceList.id;    
            proposal.Upgrade_Proposal__c  = true;
            proposal.Latest_End_Date__c  = System.today();
            proposal.APTS_Quote_Type__c = 'Product Extension';
            proposal.AgencyCommission__c = 12;
            
            insert proposal;    
            
            proposal1 = TestDataSetupUtility.createProposal('Test Proposal', account.Id, opp.Id, 'Accepted Online', false);
            proposal1.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Apttus_Proposal__Proposal__c', 'Proposal');
            proposal1.Apttus_QPConfig__PriceListId__c = priceList.id;    
            proposal1.Upgrade_Proposal__c  = true;
            proposal1.Latest_End_Date__c  = System.today();
            proposal1.APTS_Quote_Type__c = 'Renewal';
            proposal1.AgencyCommission__c = 12;
            
            insert proposal1;    
        
            Apttus_Config2__ProductConfiguration__c config = TestDataSetupUtility.createTestProductConfig(proposal,account,priceList);
            insert config;
            
            Apttus_Config2__ProductConfiguration__c config1 = TestDataSetupUtility.createTestProductConfig(proposal1,account,priceList);
            insert config1;
            
            Apttus_Config2__AssetLineItem__c test_AssetLineItem = new Apttus_Config2__AssetLineItem__c(Name = 'test value');
                       test_AssetLineitem.Apttus_Config2__EndDate__c = date.today()+100;
            test_AssetLineitem.Apttus_Config2__StartDate__c = date.today();
            test_AssetLineItem.Apttus_Config2__Quantity__c=10;
            test_AssetLineitem.Apttus_Config2__NetPrice__c = 100 ;
            test_AssetLineitem.APTS_Adjustment_Amount__c = 15;
            test_AssetLineitem.Apttus_Config2__ListPrice__c = 115;
            test_AssetLineitem.Apttus_Config2__Quantity__c = 2;
            test_AssetLineitem.Apttus_Config2__BaseExtendedPrice__c = 125 ;
            
            insert test_AssetLineItem;
            
            List<Apttus_Config2__LineItem__c> OLItemList = new List<Apttus_Config2__LineItem__c>();
            
            List<Apttus_Config2__LineItem__c> OLItemList1 = new List<Apttus_Config2__LineItem__c>();
            
            Apttus_Config2__LineItem__c aptusLineItem = TestDataSetupUtility.createLineItemApttus(config.Id);

            aptusLineItem.Apttus_Config2__ItemSequence__c = 1.00; 
            aptusLineItem.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem.Apttus_Config2__LineStatus__c = 'New';
            aptusLineItem.Apttus_Config2__BaseProductId__c = product.id;
            aptusLineItem.Apttus_Config2__PricingStatus__c = 'Pending';
            aptusLineItem.Apttus_Config2__ProductId__c = productsList[0].id;
            aptusLineItem.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            aptusLineItem.Apttus_Config2__BasePrice__c = 12.23;
            aptusLIneItem.Apttus_Config2__Quantity__c=10;
            aptusLineItem.AgencyCommission__c  = 12;
            aptusLineItem.DerivedFromLineItemId__c = null;
            aptusLineItem.Apttus_Config2__StartDate__c = System.Today();
            aptusLineItem.Apttus_Config2__EndDate__c = System.Today().addDays(512);
            
            
            OLItemList.add(aptusLineItem);
            
            
            Apttus_Config2__LineItem__c aptusLineItem1 = TestDataSetupUtility.createLineItemApttus(config.Id);

            aptusLineItem1.Apttus_Config2__ItemSequence__c = 1.00; 
            aptusLineItem1.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem1.Apttus_Config2__LineStatus__c = 'New';
            aptusLineItem1.Apttus_Config2__BaseProductId__c = product22.id;
            aptusLineItem1.Apttus_Config2__PricingStatus__c = 'Pending';
            aptusLineItem1.Apttus_Config2__ProductId__c = productsList[1].id;
            aptusLineItem1.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            aptusLineItem1.Apttus_Config2__BasePrice__c = 12.23;
            aptusLineItem1.Apttus_Config2__Quantity__c=10;
            aptusLineItem1.AgencyCommission__c  = 12;
            aptusLineItem1.DerivedFromLineItemId__c = null;
            aptusLineItem1.Apttus_Config2__StartDate__c = System.Today();
            aptusLineItem1.Apttus_Config2__EndDate__c = System.Today().addDays(512);
            
            OLItemList.add(aptusLineItem1);
            
            
            Apttus_Config2__LineItem__c aptusLineItem2 = TestDataSetupUtility.createLineItemApttus(config1.Id);

            aptusLineItem2.Apttus_Config2__ItemSequence__c = 1.00; 
            aptusLineItem2.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem2.Apttus_Config2__LineStatus__c = 'Existing';
            aptusLineItem2.Apttus_Config2__BaseProductId__c = product22.id;
            aptusLineItem2.Apttus_Config2__PricingStatus__c = 'Pending';
            aptusLineItem2.Apttus_Config2__ProductId__c = productsList[1].id;
            aptusLineItem2.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            aptusLineItem2.Apttus_Config2__BasePrice__c = 12.23;
            aptusLineItem2.Apttus_Config2__Quantity__c=10;
            aptusLineItem2.AgencyCommission__c  = 12;
            aptusLineItem2.DerivedFromLineItemId__c = null;
            aptusLineItem2.Apttus_Config2__StartDate__c = System.Today();
            aptusLineItem2.Apttus_Config2__EndDate__c = System.Today().addDays(512);
            
            OLItemList1.add(aptusLineItem2);
            
            insert OLItemList;
            insert OLItemList1;
            
            Apttus_Config2__ProductAttributeValue__c test_ProductAttributeValue = new Apttus_Config2__ProductAttributeValue__c(
                                                    Apttus_Config2__LineItemId__c = aptusLineItem.Id);
            test_ProductAttributeValue.Contract_Duration__c = '5 Weeks';            
            
            insert test_ProductAttributeValue;
            
            
           
            Update OLItemList;
            
            
            test.startTest();
            Boolean resFlag = Apttus_Config2.PricingWebService.computeBasePriceForItemColl(config.Id,1);
            resFlag = Apttus_Config2.PricingWebService.computeNetPriceForItemColl(config.Id, 1);
            Apttus_Config2.PricingWebService.computeBasicPriceForItemColl(config, OLItemList);
            
            
            Boolean resFlag1 = Apttus_Config2.PricingWebService.computeBasePriceForItemColl(config1.Id,1);
            resFlag1 = Apttus_Config2.PricingWebService.computeNetPriceForItemColl(config1.Id, 1);
            Apttus_Config2.PricingWebService.computeBasicPriceForItemColl(config1, OLItemList1);
                
            test.stopTest(); 
            
        }
    }
    
    static testMethod void testPricingCallBackUpgradeProposalUsage(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        insert manager;
        testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        testUser.Discount_Threshold__c  = 10.0;
        insert testuser;
        
       Apttus_Config2__ConfigCustomClasses__c custSetting = new Apttus_Config2__ConfigCustomClasses__c();
        custSetting.Apttus_Config2__PricingCallbackClass__c = 'APTS_PricingCallBack';
        custSetting.Name = 'System Properties';
        custSetting.Apttus_Config2__ValidationCallbackClass__c = 'APTS_ValidationCallBack';
        insert custSetting;
        
        Apttus_Config2__ConfigSystemProperties__c custprop = new Apttus_Config2__ConfigSystemProperties__c();
        custprop.Name = 'System Properties';
        custprop.Apttus_Config2__ViewCartCustomFields__c = 'Apttus_Config2__ConfigurationId__c,Apttus_Config2__ProductId__r.ProductCode,APTS_Asset_Line_Item_Start_Date__c';
        custprop.Apttus_Config2__ViewCartCustomFields2__c = 'Apttus_Config2__ProductId__c,AgencyCommission__c,APTS_Product_Service_Type__c,APTS_Is_Default_Adjustment_Done__c';
        insert custprop;
        
        System.runAs(testUser){
            // Create test account
            account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
            system.debug('after account ' + account);
            insert account;
            
            
            //create Opportunity
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', account.Id);
            opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'GCS Opportunity');
            insert opp;
            
            //Create product2
            List<Product2> productsList = new List<Product2>();
            
            Product2 product = TestDataSetupUtility.createProduct('Test product1', false); 
            product.Convert_From__c = true;
            product.Service_Type__c = 'Usage';
            
            productsList.add(product);
            
            Product2 product22 = TestDataSetupUtility.createProduct('Test product1', false); 
            product22.Convert_From__c = true;
            product22.Service_Type__c = 'Usage';
            
            productsList.add(product22);
            
            
            insert productsList;
            
            
            Apttus_Config2__AssetLineItem__c test_AssetLineItem = new Apttus_Config2__AssetLineItem__c(Name = 'test value');
                       test_AssetLineitem.Apttus_Config2__EndDate__c = date.today()+100;
            test_AssetLineitem.Apttus_Config2__StartDate__c = date.today();
            test_AssetLineItem.Apttus_Config2__Quantity__c=10;
            test_AssetLineItem.Apttus_Config2__NetPrice__c = 10;
            test_AssetLineItem.Apttus_Config2__BaseExtendedPrice__c = 5;
            test_AssetLineItem.Apttus_Config2__ListPrice__c = 115;
            test_AssetLineItem.Apttus_Config2__StartDate__c = system.today();
            insert test_AssetLineItem;
            
            System.debug(LoggingLevel.Info , [Select id,Apttus_Config2__StartDate__c  from  Apttus_Config2__AssetLineItem__c where id =: test_AssetLineItem.Id]);
            //Create price list
            Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
            insert priceList; 
            
            List<Apttus_Config2__PriceListItem__c> pliList = new List<Apttus_Config2__PriceListItem__c>();
            
            Apttus_Config2__PriceListItem__c pli = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 10, Apttus_Config2__ProductId__c = product.Id, Apttus_Config2__ChargeType__c = 'Standard Price');
            
            pliList.add(pli);
            
            
            insert pliList;
            
            //create proposal
            proposal = TestDataSetupUtility.createProposal('Test Proposal', account.Id, opp.Id, 'Accepted Online', false);
            proposal.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Apttus_Proposal__Proposal__c', 'Proposal');
            proposal.Apttus_QPConfig__PriceListId__c = priceList.id;    
            proposal.Upgrade_Proposal__c  = true;
            proposal.Latest_End_Date__c  = System.today();
            proposal.APTS_Quote_Type__c = 'Product Extension';
            proposal.AgencyCommission__c = 12;
            
            insert proposal;    
            
            proposal1 = TestDataSetupUtility.createProposal('Test Proposal', account.Id, opp.Id, 'Accepted Online', false);
            proposal1.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Apttus_Proposal__Proposal__c', 'Proposal');
            proposal1.Apttus_QPConfig__PriceListId__c = priceList.id;    
            proposal1.Upgrade_Proposal__c  = true;
            proposal1.Latest_End_Date__c  = System.today();
            proposal1.APTS_Quote_Type__c = 'Renewal';
            proposal1.AgencyCommission__c = 12;
            
            insert proposal1;    
        
            Apttus_Config2__ProductConfiguration__c config = TestDataSetupUtility.createTestProductConfig(proposal,account,priceList);
            insert config;
            
            Apttus_Config2__ProductConfiguration__c config1 = TestDataSetupUtility.createTestProductConfig(proposal1,account,priceList);
            insert config1;
            
            
            
            List<Apttus_Config2__LineItem__c> OLItemList = new List<Apttus_Config2__LineItem__c>();
            
            List<Apttus_Config2__LineItem__c> OLItemList1 = new List<Apttus_Config2__LineItem__c>();
            
            Apttus_Config2__LineItem__c aptusLineItem = TestDataSetupUtility.createLineItemApttus(config.Id);

            aptusLineItem.Apttus_Config2__ItemSequence__c = 1.00; 
            aptusLineItem.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem.Apttus_Config2__LineStatus__c = 'New';
            aptusLineItem.Apttus_Config2__BaseProductId__c = product.id;
            aptusLineItem.Apttus_Config2__PricingStatus__c = 'Pending';
            aptusLineItem.Apttus_Config2__ProductId__c = productsList[0].id;
            aptusLineItem.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            aptusLineItem.Apttus_Config2__BasePrice__c = 12.23;
            aptusLIneItem.Apttus_Config2__Quantity__c=10;
            aptusLineItem.AgencyCommission__c  = 12;
            aptusLineItem.DerivedFromLineItemId__c = null;
            aptusLineItem.Apttus_Config2__StartDate__c = System.Today();
            aptusLineItem.Apttus_Config2__EndDate__c = System.Today().addDays(512);
            
            
            OLItemList.add(aptusLineItem);
            
            
            Apttus_Config2__LineItem__c aptusLineItem1 = TestDataSetupUtility.createLineItemApttus(config.Id);

            aptusLineItem1.Apttus_Config2__ItemSequence__c = 1.00; 
            aptusLineItem1.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem1.Apttus_Config2__LineStatus__c = 'New';
            aptusLineItem1.Apttus_Config2__BaseProductId__c = product22.id;
            aptusLineItem1.Apttus_Config2__PricingStatus__c = 'Pending';
            aptusLineItem1.Apttus_Config2__ProductId__c = productsList[1].id;
            aptusLineItem1.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            aptusLineItem1.Apttus_Config2__BasePrice__c = 12.23;
            aptusLineItem1.Apttus_Config2__Quantity__c=10;
            aptusLineItem1.AgencyCommission__c  = 12;
            aptusLineItem1.DerivedFromLineItemId__c = null;
            aptusLineItem1.Apttus_Config2__StartDate__c = System.Today();
            aptusLineItem1.Apttus_Config2__EndDate__c = System.Today().addDays(512);
            
            OLItemList.add(aptusLineItem1);
            
            
            Apttus_Config2__LineItem__c aptusLineItem2 = TestDataSetupUtility.createLineItemApttus(config1.Id);

            aptusLineItem2.Apttus_Config2__ItemSequence__c = 1.00; 
            aptusLineItem2.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem2.Apttus_Config2__LineStatus__c = 'Existing';
            aptusLineItem2.Apttus_Config2__BaseProductId__c = product22.id;
            aptusLineItem2.Apttus_Config2__PricingStatus__c = 'Pending';
            aptusLineItem2.Apttus_Config2__ProductId__c = productsList[1].id;
            aptusLineItem2.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            aptusLineItem2.Apttus_Config2__BasePrice__c = 12.23;
            aptusLineItem2.Apttus_Config2__Quantity__c=10;
            aptusLineItem2.AgencyCommission__c  = 12;
            aptusLineItem2.DerivedFromLineItemId__c = null;
            aptusLineItem2.Apttus_Config2__StartDate__c = System.Today();
            aptusLineItem2.Apttus_Config2__EndDate__c = System.Today().addDays(512);
            
            OLItemList1.add(aptusLineItem2);
            
            insert OLItemList;
            insert OLItemList1;
            
            Apttus_Config2__ProductAttributeValue__c test_ProductAttributeValue = new Apttus_Config2__ProductAttributeValue__c(
                                                    Apttus_Config2__LineItemId__c = aptusLineItem.Id);
            test_ProductAttributeValue.Contract_Duration__c = '5 Weeks';            
            
            insert test_ProductAttributeValue;
            
            
           
            Update OLItemList;
            
            
            test.startTest();
            Boolean resFlag = Apttus_Config2.PricingWebService.computeBasePriceForItemColl(config.Id,1);
            resFlag = Apttus_Config2.PricingWebService.computeNetPriceForItemColl(config.Id, 1);
            Apttus_Config2.PricingWebService.computeBasicPriceForItemColl(config, OLItemList);
            
            
            Boolean resFlag1 = Apttus_Config2.PricingWebService.computeBasePriceForItemColl(config1.Id,1);
            resFlag1 = Apttus_Config2.PricingWebService.computeNetPriceForItemColl(config1.Id, 1);
            Apttus_Config2.PricingWebService.computeBasicPriceForItemColl(config1, OLItemList1);
                
            test.stopTest(); 
            
        }
    }
    
    
    static testMethod void testPricingCallBackUpgradeProposalRenewed(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        insert manager;
        testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        testUser.Discount_Threshold__c  = 10.0;
        insert testuser;
        
       Apttus_Config2__ConfigCustomClasses__c custSetting = new Apttus_Config2__ConfigCustomClasses__c();
        custSetting.Apttus_Config2__PricingCallbackClass__c = 'APTS_PricingCallBack';
        custSetting.Name = 'System Properties';
        custSetting.Apttus_Config2__ValidationCallbackClass__c = 'APTS_ValidationCallBack';
        insert custSetting;
        
        Apttus_Config2__ConfigSystemProperties__c custprop = new Apttus_Config2__ConfigSystemProperties__c();
        custprop.Name = 'System Properties';
        custprop.Apttus_Config2__ViewCartCustomFields__c = 'Apttus_Config2__ConfigurationId__c,Apttus_Config2__ProductId__r.ProductCode,APTS_Asset_Line_Item_Start_Date__c';
        custprop.Apttus_Config2__ViewCartCustomFields2__c = 'Apttus_Config2__ProductId__c,AgencyCommission__c,APTS_Product_Service_Type__c,APTS_Is_Default_Adjustment_Done__c';
        insert custprop;
        
        System.runAs(testUser){
            // Create test account
            account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
            system.debug('after account ' + account);
            insert account;
            
            
            //create Opportunity
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', account.Id);
            opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'GCS Opportunity');
            insert opp;
            
            //Create product2
            List<Product2> productsList = new List<Product2>();
            
            Product2 product = TestDataSetupUtility.createProduct('Test product1', false); 
            product.Convert_From__c = true;
            product.Service_Type__c = 'Usage';
            
            productsList.add(product);
            
            Product2 product22 = TestDataSetupUtility.createProduct('Test product1', false); 
            product22.Convert_From__c = true;
            product22.Service_Type__c = 'Subscription';
            
            productsList.add(product22);
            
            
            insert productsList;
            
            //Create price list
            Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
            insert priceList; 
            
            List<Apttus_Config2__PriceListItem__c> pliList = new List<Apttus_Config2__PriceListItem__c>();
            
            Apttus_Config2__PriceListItem__c pli = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 10, Apttus_Config2__ProductId__c = product.Id, Apttus_Config2__ChargeType__c = 'Standard Price');
            
            pliList.add(pli);
            
            
            insert pliList;
            
            //create proposal
            proposal = TestDataSetupUtility.createProposal('Test Proposal', account.Id, opp.Id, 'Accepted Online', false);
            proposal.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Apttus_Proposal__Proposal__c', 'Proposal');
            proposal.Apttus_QPConfig__PriceListId__c = priceList.id;    
            proposal.Upgrade_Proposal__c  = true;
            proposal.Latest_End_Date__c  = System.today();
            proposal.APTS_Quote_Type__c = 'Product Conversion';
            proposal.AgencyCommission__c = 12;
            
            insert proposal;    
            
            proposal1 = TestDataSetupUtility.createProposal('Test Proposal', account.Id, opp.Id, 'Accepted Online', false);
            proposal1.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Apttus_Proposal__Proposal__c', 'Proposal');
            proposal1.Apttus_QPConfig__PriceListId__c = priceList.id;    
            proposal1.Upgrade_Proposal__c  = true;
            proposal1.Latest_End_Date__c  = System.today();
            proposal1.APTS_Quote_Type__c = 'Renewal';
            proposal1.AgencyCommission__c = 12;
            proposal1.APTS_Quote_Type__c= 'Product Conversion';
            insert proposal1;    
        
            Apttus_Config2__ProductConfiguration__c config = TestDataSetupUtility.createTestProductConfig(proposal,account,priceList);
            insert config;
            
            Apttus_Config2__ProductConfiguration__c config1 = TestDataSetupUtility.createTestProductConfig(proposal1,account,priceList);
            insert config1;
            
            Apttus_Config2__AssetLineItem__c test_AssetLineItem = new Apttus_Config2__AssetLineItem__c(Name = 'test value');
                       test_AssetLineitem.Apttus_Config2__EndDate__c = date.today()+100;
            test_AssetLineitem.Apttus_Config2__StartDate__c = date.today();
            test_AssetLineItem.Apttus_Config2__Quantity__c=10;
            test_AssetLineItem.Apttus_Config2__NetPrice__c =10;
            test_AssetLineItem.Apttus_Config2__BaseExtendedPrice__c = 5;
            insert test_AssetLineItem;
            
            List<Apttus_Config2__LineItem__c> OLItemList = new List<Apttus_Config2__LineItem__c>();
            
            List<Apttus_Config2__LineItem__c> OLItemList1 = new List<Apttus_Config2__LineItem__c>();
            
            Apttus_Config2__LineItem__c aptusLineItem = TestDataSetupUtility.createLineItemApttus(config.Id);

            aptusLineItem.Apttus_Config2__ItemSequence__c = 1.00; 
            aptusLineItem.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem.Apttus_Config2__LineStatus__c = 'Renewed';
            aptusLineItem.Apttus_Config2__BaseProductId__c = product.id;
            aptusLineItem.Apttus_Config2__PricingStatus__c = 'Pending';
            aptusLineItem.Apttus_Config2__ProductId__c = productsList[0].id;
            aptusLineItem.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            aptusLineItem.Apttus_Config2__BasePrice__c = 12.23;
            aptusLIneItem.Apttus_Config2__Quantity__c=10;
            aptusLineItem.AgencyCommission__c  = 12;
            aptusLineItem.DerivedFromLineItemId__c = null;
            aptusLineItem.Apttus_Config2__StartDate__c = System.Today();
            aptusLineItem.Apttus_Config2__EndDate__c = System.Today().addDays(512);
            
            
            OLItemList.add(aptusLineItem);
            
            
            Apttus_Config2__LineItem__c aptusLineItem1 = TestDataSetupUtility.createLineItemApttus(config.Id);

            aptusLineItem1.Apttus_Config2__ItemSequence__c = 1.00; 
            aptusLineItem1.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem1.Apttus_Config2__LineStatus__c = 'Converted';
            
            aptusLineItem1.Apttus_Config2__BaseProductId__c = product22.id;
            aptusLineItem1.Apttus_Config2__PricingStatus__c = 'Pending';
            aptusLineItem1.Apttus_Config2__ProductId__c = productsList[1].id;
            aptusLineItem1.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            aptusLineItem1.Apttus_Config2__BasePrice__c = 12.23;
            aptusLineItem1.Apttus_Config2__Quantity__c=10;
            aptusLineItem1.AgencyCommission__c  = 12;
            aptusLineItem1.DerivedFromLineItemId__c = null;
            aptusLineItem1.Apttus_Config2__StartDate__c = System.Today();
            aptusLineItem1.Apttus_Config2__EndDate__c = System.Today().addDays(512);
            
            OLItemList.add(aptusLineItem1);
            
            
            Apttus_Config2__LineItem__c aptusLineItem2 = TestDataSetupUtility.createLineItemApttus(config1.Id);

            aptusLineItem2.Apttus_Config2__ItemSequence__c = 1.00; 
            aptusLineItem2.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem2.Apttus_Config2__LineStatus__c = 'Renewed';
            aptusLineItem2.Apttus_Config2__BaseProductId__c = product22.id;
            aptusLineItem2.Apttus_Config2__PricingStatus__c = 'Pending';
            aptusLineItem2.Apttus_Config2__ProductId__c = productsList[1].id;
            aptusLineItem2.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            aptusLineItem2.Apttus_Config2__BasePrice__c = 12.23;
            aptusLineItem2.Apttus_Config2__Quantity__c=10;
            aptusLineItem2.AgencyCommission__c  = 12;
            aptusLineItem2.DerivedFromLineItemId__c = null;
            aptusLineItem2.Apttus_Config2__StartDate__c = System.Today();
            aptusLineItem2.Apttus_Config2__EndDate__c = System.Today().addDays(512);
            
            OLItemList1.add(aptusLineItem2);
            
            insert OLItemList;
            insert OLItemList1;
            
            Apttus_Config2__ProductAttributeValue__c test_ProductAttributeValue = new Apttus_Config2__ProductAttributeValue__c(
                                                    Apttus_Config2__LineItemId__c = aptusLineItem.Id);
            test_ProductAttributeValue.Contract_Duration__c = '5 Weeks';            
            
            insert test_ProductAttributeValue;
            
            
           
            Update OLItemList;
            
            
            test.startTest();
            Boolean resFlag = Apttus_Config2.PricingWebService.computeBasePriceForItemColl(config.Id,1);
            resFlag = Apttus_Config2.PricingWebService.computeNetPriceForItemColl(config.Id, 1);
            Apttus_Config2.PricingWebService.computeBasicPriceForItemColl(config, OLItemList);
            
            
            Boolean resFlag1 = Apttus_Config2.PricingWebService.computeBasePriceForItemColl(config1.Id,1);
            resFlag1 = Apttus_Config2.PricingWebService.computeNetPriceForItemColl(config1.Id, 1);
            Apttus_Config2.PricingWebService.computeBasicPriceForItemColl(config1, OLItemList1);
                
            test.stopTest(); 
            
        }
    }
    
    /*static testMethod void testPricingCallBackUpgradeProposalUsage(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        insert manager;
        testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        testUser.Discount_Threshold__c  = 10.0;
        insert testuser;
        
       Apttus_Config2__ConfigCustomClasses__c custSetting = new Apttus_Config2__ConfigCustomClasses__c();
        custSetting.Apttus_Config2__PricingCallbackClass__c = 'APTS_PricingCallBack';
        custSetting.Name = 'System Properties';
        custSetting.Apttus_Config2__ValidationCallbackClass__c = 'APTS_ValidationCallBack';
        insert custSetting;
        
        Apttus_Config2__ConfigSystemProperties__c custprop = new Apttus_Config2__ConfigSystemProperties__c();
        custprop.Name = 'System Properties';
        custprop.Apttus_Config2__ViewCartCustomFields__c = 'Apttus_Config2__ConfigurationId__c,Apttus_Config2__ProductId__r.ProductCode';
        custprop.Apttus_Config2__ViewCartCustomFields2__c = 'Apttus_Config2__ProductId__c,AgencyCommission__c,APTS_Product_Service_Type__c,APTS_Is_Default_Adjustment_Done__c';
        insert custprop;
        
        System.runAs(testUser){
            // Create test account
            account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
            system.debug('after account ' + account);
            insert account;
            
            
            //create Opportunity
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', account.Id);
            opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'GCS Opportunity');
            insert opp;
            
            //Create product2
            List<Product2> productsList = new List<Product2>();
            
            Product2 product = TestDataSetupUtility.createProduct('Test product1', false); 
            product.Convert_From__c = true;
            product.Service_Type__c = 'Subscription';
            
            productsList.add(product);
            
            Product2 product22 = TestDataSetupUtility.createProduct('Test product1', false); 
            product22.Convert_From__c = true;
            product22.Service_Type__c = 'Usage';
            
            productsList.add(product22);
            
            
            insert productsList;
            
            //Create price list
            Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
            insert priceList; 
            
            List<Apttus_Config2__PriceListItem__c> pliList = new List<Apttus_Config2__PriceListItem__c>();
            
            Apttus_Config2__PriceListItem__c pli = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 10, Apttus_Config2__ProductId__c = product.Id, Apttus_Config2__ChargeType__c = 'Standard Price');
            
            pliList.add(pli);
            
            
            insert pliList;
            
            //create proposal
            proposal = TestDataSetupUtility.createProposal('Test Proposal', account.Id, opp.Id, 'Accepted Online', false);
            proposal.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Apttus_Proposal__Proposal__c', 'Proposal');
            proposal.Apttus_QPConfig__PriceListId__c = priceList.id;    
            proposal.Upgrade_Proposal__c  = true;
            proposal.Latest_End_Date__c  = System.today();
            proposal.APTS_Quote_Type__c = 'Product Extension';
            proposal.AgencyCommission__c = 12;
            
            insert proposal;    
            
            proposal1 = TestDataSetupUtility.createProposal('Test Proposal', account.Id, opp.Id, 'Accepted Online', false);
            proposal1.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Apttus_Proposal__Proposal__c', 'Proposal');
            proposal1.Apttus_QPConfig__PriceListId__c = priceList.id;    
            proposal1.Upgrade_Proposal__c  = true;
            proposal1.Latest_End_Date__c  = System.today();
            proposal1.APTS_Quote_Type__c = 'Renewal';
            proposal1.AgencyCommission__c = 12;
            
            insert proposal1;    
        
            Apttus_Config2__ProductConfiguration__c config = TestDataSetupUtility.createTestProductConfig(proposal,account,priceList);
            insert config;
            
            Apttus_Config2__ProductConfiguration__c config1 = TestDataSetupUtility.createTestProductConfig(proposal1,account,priceList);
            insert config1;
            
            Apttus_Config2__AssetLineItem__c test_AssetLineItem = new Apttus_Config2__AssetLineItem__c(Name = 'test value');
                       test_AssetLineitem.Apttus_Config2__EndDate__c = date.today()+100;
            test_AssetLineitem.Apttus_Config2__StartDate__c = date.today();
            test_AssetLineItem.Apttus_Config2__Quantity__c=10;

            insert test_AssetLineItem;
            
            List<Apttus_Config2__LineItem__c> OLItemList = new List<Apttus_Config2__LineItem__c>();
            
            List<Apttus_Config2__LineItem__c> OLItemList1 = new List<Apttus_Config2__LineItem__c>();
            
            Apttus_Config2__LineItem__c aptusLineItem = TestDataSetupUtility.createLineItemApttus(config.Id);

            aptusLineItem.Apttus_Config2__ItemSequence__c = 1.00; 
            aptusLineItem.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem.Apttus_Config2__LineStatus__c = 'New';
            aptusLineItem.Apttus_Config2__BaseProductId__c = product.id;
            aptusLineItem.Apttus_Config2__PricingStatus__c = 'Pending';
            aptusLineItem.Apttus_Config2__ProductId__c = productsList[0].id;
            aptusLineItem.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            aptusLineItem.Apttus_Config2__BasePrice__c = 12.23;
            aptusLIneItem.Apttus_Config2__Quantity__c=10;
            aptusLineItem.AgencyCommission__c  = 12;
            aptusLineItem.DerivedFromLineItemId__c = null;
            aptusLineItem.Apttus_Config2__StartDate__c = System.Today();
            aptusLineItem.Apttus_Config2__EndDate__c = System.Today().addDays(512);
            aptusLineItem.Apttus_Config2__NetPrice__c = 50; 
            //aptusLineItem.APTS_Product_Service_Type__c= 'Usage';          
            
            
            OLItemList.add(aptusLineItem);
            
            
            Apttus_Config2__LineItem__c aptusLineItem1 = TestDataSetupUtility.createLineItemApttus(config.Id);

            aptusLineItem1.Apttus_Config2__ItemSequence__c = 1.00; 
            aptusLineItem1.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem1.Apttus_Config2__LineStatus__c = 'New';
            aptusLineItem1.Apttus_Config2__BaseProductId__c = product22.id;
            aptusLineItem1.Apttus_Config2__PricingStatus__c = 'Pending';
            aptusLineItem1.Apttus_Config2__ProductId__c = productsList[1].id;
            aptusLineItem1.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            aptusLineItem1.Apttus_Config2__BasePrice__c = 12.23;
            aptusLineItem1.Apttus_Config2__Quantity__c=10;
            aptusLineItem1.AgencyCommission__c  = 12;
            aptusLineItem1.DerivedFromLineItemId__c = null;
            aptusLineItem1.Apttus_Config2__StartDate__c = System.Today();
            aptusLineItem1.Apttus_Config2__EndDate__c = System.Today().addDays(512);
            aptusLineItem1.Apttus_Config2__NetPrice__c = 50; 
            OLItemList.add(aptusLineItem1);
            
            
            Apttus_Config2__LineItem__c aptusLineItem2 = TestDataSetupUtility.createLineItemApttus(config1.Id);

            aptusLineItem2.Apttus_Config2__ItemSequence__c = 1.00; 
            aptusLineItem2.Apttus_Config2__LineNumber__c = 1.00;
            aptusLineItem2.Apttus_Config2__LineStatus__c = 'Existing';
            aptusLineItem2.Apttus_Config2__BaseProductId__c = product22.id;
            aptusLineItem2.Apttus_Config2__PricingStatus__c = 'Pending';
            aptusLineItem2.Apttus_Config2__ProductId__c = productsList[1].id;
            aptusLineItem2.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
            aptusLineItem2.Apttus_Config2__BasePrice__c = 12.23;
            aptusLineItem2.Apttus_Config2__Quantity__c=10;
            aptusLineItem2.AgencyCommission__c  = 12;
            aptusLineItem2.DerivedFromLineItemId__c = null;
            aptusLineItem2.Apttus_Config2__StartDate__c = System.Today();
            aptusLineItem2.Apttus_Config2__EndDate__c = System.Today().addDays(512);
            aptusLineItem2.Apttus_Config2__NetPrice__c = 50;
            OLItemList1.add(aptusLineItem2);
            
            insert OLItemList;
            insert OLItemList1;
            
            Apttus_Config2__ProductAttributeValue__c test_ProductAttributeValue = new Apttus_Config2__ProductAttributeValue__c(
                                                    Apttus_Config2__LineItemId__c = aptusLineItem.Id);
            test_ProductAttributeValue.Contract_Duration__c = '5 Weeks';            
            
            insert test_ProductAttributeValue;
            
            
           
            Update OLItemList;
            
            
            test.startTest();
            Boolean resFlag = Apttus_Config2.PricingWebService.computeBasePriceForItemColl(config.Id,1);
            resFlag = Apttus_Config2.PricingWebService.computeNetPriceForItemColl(config.Id, 1);
            Apttus_Config2.PricingWebService.computeBasicPriceForItemColl(config, OLItemList);
            
            
            Boolean resFlag1 = Apttus_Config2.PricingWebService.computeBasePriceForItemColl(config1.Id,1);
            resFlag1 = Apttus_Config2.PricingWebService.computeNetPriceForItemColl(config1.Id, 1);
            Apttus_Config2.PricingWebService.computeBasicPriceForItemColl(config1, OLItemList1);
                
            test.stopTest(); 
            
        }
    }*/
    
}