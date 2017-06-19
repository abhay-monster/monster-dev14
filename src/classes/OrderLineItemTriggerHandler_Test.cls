@isTest
private Class OrderLineItemTriggerHandler_Test{

    //static Order_Line_Item__c oli; 
    //, oli12;
    //static Order_Line_Item__c oliX;
    //static Order__c o;
    //static List<User> usr = new List<User>();
    static Account acc;
    static Contact con;
    static Order__c ord;
    static Opportunity opp;
    static Product2 prod;
    static Apttus_Proposal__Proposal__c prop;
    //static Apttus_Proposal__Proposal__c prop;
    //static XcodeAccount__c xAcc;

    @testSetup
    static void setupTestData(){
        Personal_Settings__c psetting = TestDataSetupUtility.buildPersonalSetting();
        psetting.Trigger_Order__c = true;
        insert psetting;

        TestDataSetupUtility.buildTaxNowCustomSetting();
        
        Product2 prodTest = TestDataSetupUtility.createProduct('test', false);
        prodTest.Product_Line__c = 'Job Accessories--Inventory';
        prodTest.Family= 'Resume';
        prodTest.ProductCode = 'QUOTE BUNDLE';
        prodTest.APTPS_Rev_Share__c  = 10;
        insert prodTest;

        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prodTest.Id,
            UnitPrice = 10000, IsActive = true,CurrencyIsoCode = 'USD');
        insert standardPrice;
        
        Account testacc = TestDataSetupUtility.createTestAccount('Test Account', 'North America', UserInfo.getUserId());
        testacc.WinbackDate__c = Date.today().addDays(-100); // PC 1/23 - added for T-566564 (increase class coverage)
        insert testacc; 

        Xcode__c xcode = new Xcode__c();
        xcode.name = 'test';
        insert xcode;
         
        XcodeAccount__c xAcc = new XcodeAccount__c ();
        xAcc.Xcode__c = xcode.Id;
        xAcc.Account__c = testacc.Id;
        xAcc.IsPrimary__c = true;
        insert xAcc;
         
        Opportunity testopp = TestDataSetupUtility.createTestOpportunity('test',testacc.Id);
        testopp.CurrencyISOCode = 'USD';
        testopp.InternationalDeal__c = true;
        insert testopp;
         
        RevenueRecognitionSplits__c rev = new RevenueRecognitionSplits__c ();
        rev.PostingLocation__c = 'Global';
        rev.ProductFamily__c = 'Resume';
        insert rev;
         
        Country_Revenue_Split__c rsplit = new Country_Revenue_Split__c ();
        rsplit.RevenueRecognitionSplit__c = rev.Id;
        insert rsplit ;
         
        Contact testCon = TestDataSetupUtility.createTestContact(testacc.Id, 'confirst1', 'conlast1', 'con1@email.com');
        insert testCon;
         
        Apttus_Proposal__Proposal__c testprop = TestDataSetupUtility.createApttusProposal(testopp);
        insert testprop;
        Apttus_Config2__PriceList__c aptusConfigPriceList = TestDataSetupUtility.createPriceList('TestPrice',true);
        
        Apttus_Config2__ProductConfiguration__c aptusConfig = TestDataSetupUtility.createTestProductConfig(testprop , testacc , aptusConfigPriceList);
        aptusConfig.Apttus_Config2__Status__c = 'Finalized';

        insert aptusConfig;

        Apttus_Config2__LineItem__c aptusLineItem = TestDataSetupUtility.createLineItemApttus(aptusConfig.Id);
        
        insert aptusLineItem;
        Apttus_Proposal__Proposal_Line_Item__c proposalLineItem = TestDataSetupUtility.createProposalLineItem(testprop.Id);    
        proposalLineItem.Apttus_QPConfig__ConfigurationId__c = aptusConfig.Id;
        proposalLineItem.Apttus_QPConfig__DerivedFromId__c = aptusLineItem.Id;
        proposalLineItem.Apttus_Proposal__Product__c = prodTest.Id;
        insert proposalLineItem;     
        Apttus_QPConfig__ProposalProductAttributeValue__c ProposalProductAttr = new Apttus_QPConfig__ProposalProductAttributeValue__c ();        
        ProposalProductAttr.Apttus_QPConfig__LineItemId__c = proposalLineItem.Id;
        ProposalProductAttr.Posting_Locations__c = 'Asia Pacific';
        insert ProposalProductAttr;
        Apttus_Config2__ClassificationName__c newCategory = TestDataSetupUtility.getCategory('optiongroup1', 'optiongroup1', 'Option Group');
        insert newCategory;
                                
        Apttus_Config2__ClassificationHierarchy__c newCategoryHierarchy = TestDataSetupUtility.getCategoryHierarchy('optiongroup1', 'Category1', newCategory);
        insert newCategoryHierarchy;
        
        Partner_Revenue_Share__c  rs1 = new Partner_Revenue_Share__c ();
        rs1.Partner__c  = testacc.Id;
        rs1.Product_Family__c = 'Resume';
        rs1.RevenueSHare__c =10;  
        rs1.Primary__c = true;
        rs1.SiteChannelID__c = '121';
        insert rs1;

        Order__c testOrder = TestDataSetupUtility.createOrder(testacc.Id, testCon.Id);
        testOrder.AgencyCommission__c = 100;
        testOrder.Archive_Billing_Xcode__c = 'test' ;
        testOrder.Opportunity__c = testopp.Id;
        //testOrder.QuoteProposal__c = prop.Id;
        
        insert testOrder;

         
        /*Order_Line_Item__c testOli = TestDataSetupUtility.createOrderLineItem(o.Id);
        testOli.AdjustedPrice__c = 100;
        testOli.Quantity2__c = 10;
        testOli.MAPPProduct__c = prodTest.ProductCode;  
        testOli.MAPP_Order_ID__c = String.ValueOf(testord.Id).left(15);
        testOli.PostingLocation__c = 'Global'; */ 
    }

    static void prepareData(){
        opp = [Select Id, AccountId, Name from Opportunity Limit 1]; //should only be one inserted opportunity at this point
        acc = [Select Id from Account Limit 1];
        prod = [Select ID, ProductCode from Product2 Limit 1];
        con = [Select Id from Contact Limit 1];
        ord = [Select Id from Order__c Limit 1];
        prop = [Select Id from Apttus_Proposal__Proposal__c Limit 1];
    } 

    static testmethod void testOrderLineItem2(){
        prepareData(); 
        /*Apttus_Proposal__Proposal__c prop = TestDataSetupUtility.createApttusProposal(opp);
        insert prop;
        Apttus_Config2__PriceList__c aptusConfigPriceList = TestDataSetupUtility.createPriceList('TestPrice',true);
        
        Apttus_Config2__ProductConfiguration__c aptusConfig = TestDataSetupUtility.createTestProductConfig(prop , acc , aptusConfigPriceList);
        aptusConfig.Apttus_Config2__Status__c = 'Finalized';

        insert aptusConfig;

        Apttus_Config2__LineItem__c aptusLineItem = TestDataSetupUtility.createLineItemApttus(aptusConfig.Id);
        
        
        insert aptusLineItem;
        Apttus_Proposal__Proposal_Line_Item__c proposalLineItem = TestDataSetupUtility.createProposalLineItem(prop.Id);    
        proposalLineItem.Apttus_QPConfig__ConfigurationId__c = aptusConfig.Id;
        proposalLineItem.Apttus_QPConfig__DerivedFromId__c = aptusLineItem.Id;
        proposalLineItem.Apttus_Proposal__Product__c = prod.Id;
        insert proposalLineItem;     
        Apttus_QPConfig__ProposalProductAttributeValue__c ProposalProductAttr = new Apttus_QPConfig__ProposalProductAttributeValue__c ();        
        ProposalProductAttr.Apttus_QPConfig__LineItemId__c = proposalLineItem.Id;
        ProposalProductAttr.Posting_Locations__c = 'Asia Pacific';
        insert ProposalProductAttr;
        Apttus_Config2__ClassificationName__c newCategory = TestDataSetupUtility.getCategory('optiongroup1', 'optiongroup1', 'Option Group');
        insert newCategory;
                                
        Apttus_Config2__ClassificationHierarchy__c newCategoryHierarchy = TestDataSetupUtility.getCategoryHierarchy('optiongroup1', 'Category1', newCategory);
        insert newCategoryHierarchy;

        Partner_Revenue_Share__c  rs1 = new Partner_Revenue_Share__c ();
        rs1.Partner__c  = acc.Id;
        rs1.Product_Family__c = 'Resume';
        rs1.RevenueSHare__c =10;  
        rs1.Primary__c = true;
        rs1.SiteChannelID__c = '121';
        insert rs1;  */

        Apttus_QPConfig__ProposalProductAttributeValue__c ProposalProductAttr = [Select Id from Apttus_QPConfig__ProposalProductAttributeValue__c Limit 1];
        Apttus_Config2__ClassificationHierarchy__c newCategoryHierarchy = [Select Id from Apttus_Config2__ClassificationHierarchy__c Limit 1];
        Test.startTest();        
        /*Order__c ord1 = TestDataSetupUtility.createOrder(acc.Id, con.Id);
        ord1.Agency__c = acc.Id;
        ord1.SiteChannelID__c = '121';
        ord1.MAPP_Order_ID__c = String.ValueOf(ord.Id).left(15);
        ord1.Archive_Billing_Xcode__c = 'test';
        insert ord1;*/
        Order_Line_Item__c oli1 = TestDataSetupUtility.createOrderLineItem(ord.Id);
        Order_Line_Item__c oli = TestDataSetupUtility.createOrderLineItem(ord.Id);
        oli.MAPPAttributeValueId__c = ProposalProductAttr.Id;
        oli.MAPPClassificationId__c = newCategoryHierarchy.Id;
        
        try{
            insert new List<Order_Line_Item__c>{oli,oli1};
        }catch(Exception e){}
        Test.stopTest();
    }
    static testmethod void testOrderLineItem(){
        prepareData();
        ord.MAPP_Order_ID__c = String.ValueOf(ord.Id).left(15);
        update ord;
        List<User> usr = new List<User>();
        for(Integer i=0; i<2; i++) {
            usr.add(TestDataSetupUtility.createTestUser('Integration','MAPP',UserInfo.getProfileId()));
        }
        usr[1].FirstName =  'Integration';
        usr[1].LastName =  'NotMAPP';
        insert usr;

        Test.startTest();        
        System.runAs(usr[0]){
            //oli.MAPPAttributeValueId__c = 'test';
            //oli.MAPPClassificationId__c ='test';
            //try{
            //insert oli;
            //}catch(Exception e){}
            //Order__c ord1 = TestDataSetupUtility.createOrder(acc.Id, con.Id);
            //ord1.Agency__c = acc.Id;
            //ord1.MAPP_Order_ID__c = String.ValueOf(ord.Id).left(15);
            //insert ord1;
            //prop = TestDataSetupUtility.createApttusProposal(opp);
            //insert prop;
            Order_Line_Item__c oli = TestDataSetupUtility.createOrderLineItem(ord.Id);
            oli.Proposal__c = prop.Id;
            oli.Product__c = prod.Id;
            oli.AdjustedPrice__c = 100;
            oli.Quantity2__c = 10;
            oli.MAPPProduct__c = prod.ProductCode; 
            oli.MAPP_Order_ID__c = String.ValueOf(ord.Id).left(15);
            oli.PostingLocation__c = 'Global';
            oli.Earliest_Product_Start_Date__c = Date.today();
            oli.Account_lkp__c = acc.id;
            //oli.NetUnitPrice__c = 100; // PC 1/26/17 - T-566564
            if(oli == null) {
                System.debug('oli is null');
            }
            else {
                  System.debug('oli is NOT null');
                  insert oli;
            }
          
            OrderLineItemTriggerHelper helper = OrderLineItemTriggerHelper.NewTriggerHelper('');            
            oli = [Select Id, Product__c,MAPP_Order_ID__c from Order_Line_Item__c  Where Id = :oli.Id]; 
            List<Order_Line_Item__c> lstitem = new List<Order_Line_Item__c>();
            lstitem.add(oli);
            helper.OrderLineItemList = lstitem;
            //helper.SubtractQuantityAndNetPriceToParentLineItem(new Map<Id, Order_Line_Item__c>([ Select Id from Order_Line_Item__c 
            //                                                                                      Where Id IN : lstitem ]));
            
            Case cas = TestDataSetupUtility.createTestNewAccountRequestCase('North America',usr[1].Id);
            cas.OrderLineItem__c = oli.Id;
            insert cas;
            
            try{
                helper.CloseCase(lstitem);
            }catch(Exception e){}
            
            lstitem = [select id,Product__r.Product_Line__c from Order_Line_Item__c where id in :lstitem];
            helper.CloseCase(lstitem);
            for(Order_Line_Item__c orderItem : [Select Id, Product__c, Order__c from Order_Line_Item__c  Where Id = :oli.Id]){
                system.assert(orderItem.Order__c  != null);
            }


        } 
        System.runAs(usr[1]) {
            Order_Line_Item__c oliX = TestDataSetupUtility.createOrderLineItem(ord.Id);
            oliX.AdjustedPrice__c = 100;
            oliX.Proposal__c = prop.Id;
            oliX.Product__c = prod.Id;
            oliX.Quantity2__c = 10;
            oliX.MAPPProduct__c = prod.ProductCode; 
            oliX.MAPP_Order_ID__c = String.ValueOf(ord.Id).left(15);
            oliX.PostingLocation__c = 'Global';
            oliX.Earliest_Product_Start_Date__c = Date.today();
            //insert oliX;
            //delete oliX;
        }
        Test.stopTest();
    }
    

    
    static testMethod void EarliestProductStartDate1() {
        prepareData();
        List<User> usr = new List<User>();
        for(Integer i=0; i<2; i++) {
            usr.add(TestDataSetupUtility.createTestUser('First','Last'+i,UserInfo.getProfileId()));
        }
        insert usr;
        /*Account acc2 = TestDataSetupUtility.createTestAccount('Test Account', 'North America', UserInfo.getUserId());
        insert acc2;
        Contact con2 = TestDataSetupUtility.createTestContact(acc2.Id, 'confirst1', 'conlast1', 'con1@email.com');
        insert con2;
        ord = TestDataSetupUtility.createOrder(acc.Id, con.Id);
        insert ord;*/
        Order_Line_Item__c oLI0 = TestDataSetupUtility.createOrderLineItem(ord.Id);
        oLI0.Earliest_Product_Start_Date__c = Date.today();
        Order_Line_Item__c oLI1 = TestDataSetupUtility.createOrderLineItem(ord.Id);
        oLI1.Earliest_Product_Start_Date__c = Date.today().addDays(100);
        Order_Line_Item__c oLI2 = TestDataSetupUtility.createOrderLineItem(ord.Id);
        oLI2.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Order_Line_Item__c', 'Credit Order Line Item');
        oLI2.NetCreditAmount__c = 100;
        oLI2.Earliest_Product_Start_Date__c = Date.today().addDays(200);
        oLI2.Owner_on_Start_Date__c = usr[1].Id; 
        Order_Line_Item__c oLI3 = TestDataSetupUtility.createOrderLineItem(ord.Id);
        oLI3.Earliest_Product_Start_Date__c = Date.today().addDays(400);
        /*
        oLI0.NetUnitPrice__c = 10; // PC 1/26/17 - T-566564
        oLI0.Quantity2__c = 1; // PC 1/26/17 - T-566564
        oLI1.NetUnitPrice__c = 100; // PC 1/26/17 - T-566564
        oLI1.Quantity2__c = 5; // PC 1/26/17 - T-566564
        oLI2.NetUnitPrice__c = 100; // PC 1/26/17 - T-566564
        oLI2.Quantity2__c = 5; // PC 1/26/17 - T-566564
        oLI3.NetUnitPrice__c = 100; // PC 1/26/17 - T-566564
        oLI3.Quantity2__c = 5; // PC 1/26/17 - T-566564
        */
        Test.StartTest();
        insert new List<Order_Line_Item__c>{oLI0, oLI1, oLI2, oLI3};
        
        ord.OrderStatus__c = 'Negated';
        update ord;
        
        oLI2.Earliest_Product_Start_Date__c = Date.today().addDays(400);
        OrderLineItemTriggerHandler.ExecuteReportingUpdate = true;
        OrderLineItemTriggerHandler.ExecuteSynch = true;
        OrderLineItemTriggerHandler.RunCount = 0;
        oLI2.Owner_on_Start_Date__c = usr[0].Id; 
        update oLI2;
        Test.stopTest();
    }   
    
    static testMethod void testNetTotal() {
        prepareData();
        List<User> usr = new List<User>();
        for(Integer i=0; i<2; i++) {
            usr.add(TestDataSetupUtility.createTestUser('First','Last'+i,UserInfo.getProfileId()));
        }
        insert usr;
        /*Account acc2 = TestDataSetupUtility.createTestAccount('Test Account', 'North America', UserInfo.getUserId());
        insert acc2;
        Contact con2 = TestDataSetupUtility.createTestContact(acc2.Id, 'confirst1', 'conlast1', 'con1@email.com');
        insert con2;
        Order__c ord2 = TestDataSetupUtility.createOrder(acc2.Id, con2.Id);
        insert ord2;*/
        Order_Line_Item__c oLI0 = TestDataSetupUtility.createOrderLineItem(ord.Id);
        oLI0.Earliest_Product_Start_Date__c = Date.today();
        oLI0.Product__c = prod.Id;
        oLI0.Account_lkp__c = acc.id;
        Order_Line_Item__c oLI1 = TestDataSetupUtility.createOrderLineItem(ord.Id);
        oLI1.Product__c = prod.Id;
        oLI1.Earliest_Product_Start_Date__c = Date.today().addDays(100);
        oLI1.Owner_on_Start_Date__c = null;
        oLI1.Account_lkp__c = acc.id;
        Order_Line_Item__c oLI2 = TestDataSetupUtility.createOrderLineItem(ord.Id);
        oLI2.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Order_Line_Item__c', 'Credit Order Line Item');
        oLI2.NetCreditAmount__c = 100;
        oLI2.Earliest_Product_Start_Date__c = Date.today().addDays(200);
        oLI2.Owner_on_Start_Date__c = usr[1].Id;
        oLI2.Quantity2__c = 2;
        oLI2.Product__c = prod.Id;
        oLI2.Account_lkp__c = acc.id;
        Order_Line_Item__c oli = TestDataSetupUtility.createOrderLineItem(ord.Id);
        oli.AdjustedPrice__c = 100;
        oli.Quantity2__c = 10;
        oli.MAPPProduct__c = prod.ProductCode;  
        oli.MAPP_Order_ID__c = String.ValueOf(ord.Id).left(15);
        oli.PostingLocation__c = 'Global';
        oli.Owner_on_Start_Date__c = usr[1].Id;
        oli.Product__c = prod.Id;
        oli.Account_lkp__c = acc.id;
             
        Order_Line_Item__c oLI3 = TestDataSetupUtility.createOrderLineItem(ord.Id);
        oLI3.Earliest_Product_Start_Date__c = Date.today().addDays(400);
        oLI3.Product__c = prod.Id;
        oLI3.Account_lkp__c = acc.id;
        /*
        oli.NetUnitPrice__c = 10; // PC 1/26/17 - T-566564
        //oli.Quantity2__c = 1; // PC 1/26/17 - T-566564
        oLI0.NetUnitPrice__c = 10; // PC 1/26/17 - T-566564
        oLI0.Quantity2__c = 1; // PC 1/26/17 - T-566564
        oLI1.NetUnitPrice__c = 100; // PC 1/26/17 - T-566564
        oLI1.Quantity2__c = 5; // PC 1/26/17 - T-566564
        oLI2.NetUnitPrice__c = 100; // PC 1/26/17 - T-566564
        //oLI2.Quantity2__c = 5; // PC 1/26/17 - T-566564
        oLI3.NetUnitPrice__c = 100; // PC 1/26/17 - T-566564
        oLI3.Quantity2__c = 5; // PC 1/26/17 - T-566564
        */
        OrderLineItemTriggerHandler.ExecuteSynch = false;

        Test.startTest();
        System.debug('**Limits before insert' + Limits.getQueries());
        insert new List<Order_Line_Item__c>{oli,oLI0, oLI1, oLI2, oLI3};
        System.debug('**Limits after intsert ' + Limits.getQueries());
        ord.OrderStatus__c = 'Negated';
        OrderTriggerHandler.executeUpdateTrigger = false;
        update ord;
        OrderTriggerHandler.executeUpdateTrigger = true;

        oli = [Select Owner_on_Start_Date__c,Quantity2__c,ProductFamily__c,Id From Order_Line_Item__c o where o.Id = :oli.Id  ];
        
        system.debug('ProductFamily__c:::'+oLI2.ProductFamily__c );
        oLI2.Earliest_Product_Start_Date__c = Date.today().addDays(400);
        OrderLineItemTriggerHandler.ExecuteReportingUpdate = true;
        //OrderLineItemTriggerHandler.ExecuteSynch = true;
        OrderLineItemTriggerHandler.RunCount = 0;
        oLI2.Owner_on_Start_Date__c = usr[0].Id; 
        oLI2.Quantity2__c = 4;
        oli.Owner_on_Start_Date__c = usr[0].Id;
        oli.Quantity2__c = 4;

        update new List<Order_Line_Item__c>{oli,oLI2};
        Test.stopTest();
    }   
        
    static testMethod void populateManagersLookup(){
        prepareData();
        List<User> usr = new List<User>();  
        /*Product2 p = new product2(name='x');
        insert p;

        Product2 p2 = new product2(name='y');
        insert p2;*/
        
        //Id pricebookId = Test.getStandardPricebookId();
        //system.debug ('$$pricebookId$$' +pricebookId);
        //PricebookEntry standardPrice = new PricebookEntry(
        //    Pricebook2Id = pricebookId, Product2Id = prod.Id,
        //    UnitPrice = 10000, IsActive = true,CurrencyIsoCode = 'USD');
        //insert standardPrice;

         
        for(Integer i=0; i<10; i++) {
            usr.add(TestDataSetupUtility.createTestUser('First','Last'+i,UserInfo.getProfileId()));
        }
        usr[0].FirstName =  'Integration';
        usr[0].LastName =  'MAPP';
        insert usr;
        usr[1].managerId =usr[2].Id;
        usr[2].managerId =usr[3].Id;
        usr[3].managerId =usr[4].Id;
        usr[4].managerId =usr[5].Id;
        usr[5].managerId =usr[6].Id;
        usr[6].managerId =usr[7].Id;
        usr[7].managerId =usr[8].Id;
        usr[8].managerId =usr[9].Id;        
        update usr;

        ord.OrderStatus__c = 'Invoiced';
        //ord.Opportunity__c = opp.id;
        OrderTriggerHandler.executeUpdateTrigger = false;
        update ord;
        OrderTriggerHandler.executeUpdateTrigger = true;
        Test.startTest();        
        System.runAs(usr[0]){
            //ord = TestDataSetupUtility.createOrder(acc.Id, con.Id);
            //ord.OrderStatus__c = 'Invoiced';
            //ord.Opportunity__c = opp.id;
            //OrderTriggerHandler.executeUpdateTrigger = false;
            //update ord;
            //OrderTriggerHandler.executeUpdateTrigger = true;
            //Apttus_Proposal__Proposal__c prop = TestDataSetupUtility.createApttusProposal(opp);
            //insert prop;
            Order_Line_Item__c oli = TestDataSetupUtility.createOrderLineItem(ord.Id);
            oli.Proposal__c = prop.Id;
            oli.Product__c = prod.Id;
            oli.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Order_Line_Item__c', 'Credit Order Line Item');
            oli.NetCreditAmount__c = 100;
            oli.AdjustedPrice__c = 100;
            oli.Quantity2__c = 10;
            oli.MAPPProduct__c = '123'; 
            oli.MAPP_Order_ID__c = String.ValueOf(ord.Id).left(15);
            oli.PostingLocation__c = 'Global';
            oli.Earliest_Product_Start_Date__c = Date.today();
            oli.Owner_on_Start_Date__c = null; 
            oli.Account_lkp__c = acc.id;
            //insert oli;
            
            Order_Line_Item__c oli12 = TestDataSetupUtility.createOrderLineItem(ord.Id);
            oli12.Proposal__c = prop.Id;
            oli12.Product__c = prod.Id;
            oli12.AdjustedPrice__c = 900;
            oli12.Quantity2__c = 100;
            oli12.MAPPProduct__c = '1234'; 
            oli12.MAPP_Order_ID__c = String.ValueOf(ord.Id).left(15);
            oli12.PostingLocation__c = 'Global';
            oli12.Earliest_Product_Start_Date__c = Date.today();
            oli12.LineType__c = 'Option';
            oli12.Owner_on_Start_Date__c = usr[1].Id; 
            oli12.Account_lkp__c = acc.id;
            
            OrderLineItemTriggerHandler.ExecuteSynch = true;
            insert new List<Order_Line_Item__c>{oli,oli12};
            
            oli12.Owner_on_Start_Date__c = usr[2].Id; 
            oli12.Earliest_Product_Start_Date__c = Date.today() + 5;
            OrderLineItemTriggerHandler.ExecuteReportingUpdate = true;
            OrderLineItemTriggerHandler.ExecuteSynch = true;
            update oli12;
        }
        
        Test.stopTest();
    }   

    /* Sylvester AGyen (Appirio)
     * Testing start and end dates of rebill order's line item
     * 3/16/2016
    */
    static testMethod void testRebillDates(){
        OrderTriggerHandler.ExecuteTriggers = false;
        OrderTriggerHandler.executeUpdateTrigger = false;
        //create order
        Test.startTest();
        Account simpleAcc = TestDataSetupUtility.createTestAccount('SimpleAcc', 'North America', UserInfo.getUserId());
            simpleAcc.BillingStreet = '11 roading street';
            simpleAcc.BillingCity = 'CA';
            simpleAcc.BillingState = 'California';
            simpleAcc.BillingPostalCode = '95123';
            simpleAcc.BillingCountry = 'United States';
            simpleAcc.Type = 'Vendor';
            simpleAcc.Website = 'www.bosstestppp.com';
            simpleAcc.Organization__c = 'nani';
            simpleAcc.Phone = '6667778888';
            simpleAcc.CreditStatus__c ='Ok';
            simpleAcc.ShippingCity = 'Shihell';
            simpleAcc.ShippingPostalCode = '80356';
            simpleAcc.ShippingState = 'California';
            simpleAcc.ShippingStreet = '98 ROadworks';
            simpleAcc.ShippingCountry = 'United States';
            simpleAcc.WinbackDate__c = Date.today().addDays(-100); // PC 1/19 - added for T-566564 (increase class coverage)
            
        insert simpleAcc;
        Contact simpleContact = TestDataSetupUtility.createTestContact(simpleAcc.id,'simpleaccroad','no','accroad@e.com'); 
        insert simpleContact;


        Order__c simpleStandardOrder = TestDataSetupUtility.createOrder(simpleAcc.id, simpleContact.Id);
            
            simpleStandardOrder.OrderStatus__c = 'Open';
            simpleStandardOrder.Posting_Contact__c = simpleContact.id;
            simpleStandardOrder.MAPPSentToVerificationBy2__c = Userinfo.getUserId();
            simpleStandardOrder.MAPPBillingAccount__c = simpleAcc.Id;
            simpleStandardOrder.MAPPBillingContact__c = simpleContact.id;
            simpleStandardOrder.MAPP_Archive_Posting_Contact__c = simpleContact.id;
        insert simpleStandardOrder;

        //create order line item
        Product2 simpleProduct = TestDataSetupUtility.createProduct('test', false);
            simpleProduct.Product_Line__c = 'Job Accessories--Inventory';
            simpleProduct.Family= 'Resume';
            simpleProduct.ProductCode = 'QUOTE BUNDLE';
            simpleProduct.APTPS_Rev_Share__c  = 10;
        insert simpleProduct;

        Order_Line_Item__c simpleLI = TestDataSetupUtility.createOrderLineItem(simpleStandardOrder.Id);
            simpleLI.Product__c = simpleProduct.Id;
            simpleLI.startDate__c = Date.newInstance(2015, 1, 1);
            simpleLI.endDate__c = Date.newInstance(2015, 2, 1);
            simpleLI.Account_lkp__c = Simpleacc.id;
        insert simpleLI;

        Date startingDate = simpleLI.startDate__c;
        Date endingDate = simpleLI.endDate__c;


        //create rebill order
        String  recType = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Rebill Order').getRecordTypeId();
        Order__c simpleRebillOrder = TestDataSetupUtility.createOrder(simpleAcc.id, simpleContact.Id);
            simpleRebillOrder.RecordTypeId = recType;
            simpleRebillOrder.ParentOrder__c = simpleStandardOrder.id;
            simpleRebillOrder.OrderStatus__c = 'Open';
            simpleRebillOrder.Posting_Contact__c = simpleContact.id;
            //simpleRebillOrder.MAPPSentToVerificationBy2__c = Userinfo.getUserId();
            simpleRebillOrder.MAPPBillingAccount__c = simpleAcc.Id;
            simpleRebillOrder.MAPPBillingContact__c = simpleContact.id;
            //simpleRebillOrder.MAPP_Archive_Posting_Contact__c = simpleContact.id;
        insert simpleRebillOrder;

        //create rebill order line item
        Order_Line_Item__c simpleRLI = new Order_Line_Item__c();
         simpleRLI.Order__c = simpleRebillOrder.id;
         simpleRLI.PostingLocation__c = 'USA';
         simpleRLI.Product__c = simpleProduct.id;
         simpleRLI.Account_lkp__c = simpleAcc.id;
        insert simpleRLI;
        Test.stopTest();

         //validate dates
        List<Order_Line_Item__c>results = [select id,Order_Record_Type__c, Order__c, Product__c, startDate__c, endDate__c from Order_Line_Item__c where id=:simpleRLI.id];
        system.assert(results.size() >0);
        //system.assertEquals(results[0].startDate__c, startingDate);
        //system.assertEquals(results[0].endDate__c, endingDate);

    }
    
    static testMethod void testAgencyCommision() {
        
       
        Account acc2 = TestDataSetupUtility.createTestAccount('Test Account', 'North America', UserInfo.getUserId());
        acc2.WinbackDate__c = Date.today().addDays(-100); // PC 1/23 - added for T-566564 (increase class coverage)
        insert acc2;
        Contact con2 = TestDataSetupUtility.createTestContact(acc2.Id, 'confirst1', 'conlast1', 'con1@email.com');
        insert con2;
        Order__c ordRec = TestDataSetupUtility.createOrder(acc2.Id, con2.Id);
        //ordRec.Agency__c = acc2.Id;
        ordRec.Opportunity__c = null;
        ordRec.SiteChannelID__c = '123234';
        insert ordRec;
        
        Partner_Revenue_Share__c  partnerRS = new Partner_Revenue_Share__c ();
        partnerRS.Partner__c = acc2.Id;
        partnerRS.SiteChannelID__c = '123234';
        partnerRS.MB_Live_Channel_Flag__c = true;
        partnerRS.MB_Sales_Rep_Login__c = '123';
         partnerRS.Product_Family__c = 'Media';
        insert partnerRS;
        
        
        Product2 prod1 = TestDataSetupUtility.createProduct('Test Product 1',false);
        prod1.ProductCode = 'M20194XJOB';
        prod1.Family = 'Media';
        insert prod1;
        
        Product2 prod2 = TestDataSetupUtility.createProduct('Test Product 1',false);
        prod2.ProductCode = 'M20194XJOB';
        prod2.Family = 'Media';
        insert prod2;
        
        Id pricebookId1 = Test.getStandardPricebookId();
        PricebookEntry standardPrice1 = new PricebookEntry(
        Pricebook2Id = pricebookId1 , Product2Id = prod1.Id,
         UnitPrice = 10000, IsActive = true,CurrencyIsoCode = 'USD');
        insert standardPrice1 ;
        
      
        
        Order_Line_Item__c oLI0 = TestDataSetupUtility.createOrderLineItem(ordRec.Id);
        oLI0.Product__c = prod1.Id;   
        oLI0.OptionId__c = prod2.Id;  
        OrderLineItemTriggerHandler.ExecuteReportingUpdate = true;
        OrderLineItemTriggerHandler.ExecuteSynch = true;
        Test.StartTest();
        insert oLI0;
        
        Test.stopTest();
    
    } // end testAgencyCommission


} // end Class OrderLineItemTriggerHandler_Test