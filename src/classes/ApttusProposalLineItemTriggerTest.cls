@isTest

public with sharing class ApttusProposalLineItemTriggerTest{

    /*static testMethod void createData(){ 
        //TestDataSetupUtility testData = new TestDataSetupUtility();
        
        Personal_Settings__c personal  = new Personal_Settings__c();
        personal = TestDataSetupUtility.buildPersonalSetting();
        personal.Trigger_Quote__c = true;
        //insert personal;


        Account acc  = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        insert acc;

        List<Contact> lstCon = new List<Contact>();
        Contact con = TestDataSetupUtility.createTestContact(acc.Id, 'Test 1', 'Last 1', 'test@test.com');
        lstCon.add(con);
        Contact con2 = TestDataSetupUtility.createTestContact(acc.Id, 'Test 2', 'Last 2', 'con@test.com');
        lstCon.add(con2);
        insert lstCon;

        acc.PrimaryBillingContact__c = lstCon[0].Id;
        update acc;

        Opportunity opp = TestDataSetupUtility.createTestOpportunity('TestOpp' , acc.Id);
        insert opp;


        Apttus_Proposal__Proposal__c proposal = TestDataSetupUtility.createProposal(opp.Id);
        proposal.BillContact__c = lstCon[0].Id;
        proposal.PostingContact__c = lstCon[1].Id;
        proposal.Apttus_Proposal__Primary__c = true;
        insert proposal;

        Product2 product = TestDataSetupUtility.createProduct('Test Product' ,  true);

        Apttus_Config2__PriceList__c aptusConfigPriceList = TestDataSetupUtility.createPriceList('TestPrice',true);


        Apttus_Config2__ProductConfiguration__c aptusConfig = TestDataSetupUtility.createTestProductConfig(proposal , acc , aptusConfigPriceList);
        aptusConfig.Apttus_Config2__Status__c = 'Finalized';

        insert aptusConfig;

        Apttus_Config2__LineItem__c aptusLineItem = TestDataSetupUtility.createLineItemApttus(aptusConfig.Id);
        
        
        insert aptusLineItem;
        Apttus_Config2__ProductAttributeGroup__c aptusGroup = TestDataSetupUtility.createGroup('TestGroup');
        insert aptusGroup;

        Apttus_Config2__ProductAttributeGroupMember__c aptusGrpMember = TestDataSetupUtility.createProductGroupMember('TestGroupMember' , aptusGroup.Id,product.Id);
        
        insert aptusGrpMember; 




        Apttus_Proposal__Proposal_Line_Item__c proposalLineItem = TestDataSetupUtility.createProposalLineItem(proposal.Id);
        //proposalLineItem.Apttus_Proposal__Primary__c = true;
        proposalLineItem.Apttus_Proposal__Proposal__c = proposal.Id;
        proposalLineItem.Apttus_QPConfig__ConfigurationId__c = aptusConfig.Id;
        proposalLineItem.Apttus_Proposal__Product__c = product.Id;
        proposalLineItem.Apttus_QPConfig__DerivedFromId__c = aptusLineItem.Id;
        insert proposalLineItem; 
        
        //new Apttus_Proposal__Proposal_Line_Item__c();
        Terms_and_Conditions__c term = new Terms_and_Conditions__c(Name ='TestTerm');//TestDataSetupUtility.createTermAndCondition('TestTerm');
        term.Product__c = product.Id;

        insert term;

        //pricebook2 pricebook = new pricebook2();
        //pricebook.name='Standard Price Book'
        //insert pricebook;
        
        ApttusProposalLineItemTriggerHandler handler = new ApttusProposalLineItemTriggerHandler(true , 1);
        delete proposalLineITem;
        undelete proposalLineITem;

        
    } */
    
    static testMethod void createData(){ 
        //TestDataSetupUtility testData = new TestDataSetupUtility();
        
        Personal_Settings__c personal  = new Personal_Settings__c();
        personal = TestDataSetupUtility.buildPersonalSetting();
        personal.Trigger_Quote__c = true;
        insert personal;

        Sales_Channel_Cross_Reference__c crossRef = TestDataSetupUtility.salesChannelCrossReference();
        insert crossRef;

        Account acc  = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        insert acc;

        List<Contact> lstCon = new List<Contact>();
        Contact con = TestDataSetupUtility.createTestContact(acc.Id, 'Test 1', 'Last 1', 'test@test.com');
        lstCon.add(con);
        Contact con2 = TestDataSetupUtility.createTestContact(acc.Id, 'Test 2', 'Last 2', 'con@test.com');
        lstCon.add(con2);
        insert lstCon;

        acc.PrimaryBillingContact__c = lstCon[0].Id;
        update acc;

        Opportunity opp = TestDataSetupUtility.createTestOpportunity('TestOpp' , acc.Id);
        insert opp;
    
        Product2 product = TestDataSetupUtility.createProduct('Test Product' ,  true);
        Product2 productx =  TestDataSetupUtility.createProduct('Test Product1' ,  true);
		Product2 producty =  TestDataSetupUtility.createProduct('Test Product2' ,  true);
        
        Apttus_Config2__PriceList__c aptusConfigPriceList = TestDataSetupUtility.createPriceList('TestPrice',true);


        Apttus_Proposal__Proposal__c proposal1 = TestDataSetupUtility.createProposal(opp.Id);
        proposal1.BillContact__c = lstCon[0].Id;
        proposal1.PostingContact__c = lstCon[1].Id;
        proposal1.Apttus_Proposal__Primary__c = true;
        proposal1.Apttus_Proposal__Opportunity__c = opp.id ;
       
        insert proposal1;
        system.debug('santoshdebuggingID'+proposal1.id);
        system.debug('santoshdebuggingprimary'+proposal1.Apttus_Proposal__Primary__c);
        system.debug('santoshdebuggingprimary'+[select id,Apttus_Proposal__Primary__c FROM Apttus_Proposal__Proposal__c where id = :proposal1.id]);

      


        Apttus_Config2__ProductConfiguration__c aptusConfig = TestDataSetupUtility.createTestProductConfig(proposal1 , acc , aptusConfigPriceList);
        aptusConfig.Apttus_Config2__Status__c = 'Finalized';

        insert aptusConfig;

        Apttus_Config2__LineItem__c aptusLineItem = TestDataSetupUtility.createLineItemApttus(aptusConfig.Id);
        
        
        insert aptusLineItem;
        Apttus_Config2__ProductAttributeGroup__c aptusGroup = TestDataSetupUtility.createGroup('TestGroup');
        insert aptusGroup;

        Apttus_Config2__ProductAttributeGroupMember__c aptusGrpMember = TestDataSetupUtility.createProductGroupMember('TestGroupMember' , aptusGroup.Id,product.Id);
        
        insert aptusGrpMember; 
        
        Id pricebookId = Test.getStandardPricebookId();
        pricebook2 pb = new pricebook2(id = pricebookId);
        upsert pb;
        
        system.debug('pricebookId***'+pricebookId);
        // 1. Insert a price book entry for the standard price book.
        // Standard price book entries require the standard price book ID we got earlier.
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = product.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        PricebookEntry standardPrice2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = producty.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice2;
        
      
        
        // Create a custom price book
        Pricebook2 customPB = new Pricebook2(Name='Standard Price Book', isActive=true);
        insert customPB;
        
        // 2. Insert a price book entry with a custom price.
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = product.Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice;
        
        PricebookEntry customPrice2 = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = producty.Id,
            UnitPrice = 13000, IsActive = true);
        insert customPrice2;
        
        
       
        
         
            
        
        AVA_SFCORE__TaxNowSetting__c TNS = New AVA_SFCORE__TaxNowSetting__c(name = 'TestSetting', AVA_SFCORE__Active_Setting__c = TRUE);
        insert TNS ;
        
      

Test.startTest() ;
        
        Apttus_Proposal__Proposal_Line_Item__c proposalLineItem = TestDataSetupUtility.createProposalLineItem(proposal1.Id);    
        
        proposalLineItem.Apttus_Proposal__Proposal__c = proposal1.Id;
        proposalLineItem.Apttus_QPConfig__ConfigurationId__c = aptusConfig.Id;
        proposalLineItem.Apttus_QPConfig__DerivedFromId__c = aptusLineItem.Id;
        insert proposalLineItem; 
        
 		 proposalLineItem.Apttus_Proposal__Product__c = product.Id;
       update proposalLineItem ; 
 
        Apttus_Proposal__Proposal_Line_Item__c proposalLineItem2 = TestDataSetupUtility.createProposalLineItem(proposal1.Id);    
        
        proposalLineItem2.Apttus_Proposal__Proposal__c = proposal1.Id;
        proposalLineItem2.Apttus_QPConfig__ConfigurationId__c = aptusConfig.Id;
        proposalLineItem2.Apttus_QPConfig__DerivedFromId__c = aptusLineItem.Id;
        insert proposalLineItem2; 
        
 		 proposalLineItem2.Apttus_Proposal__Product__c = producty.Id;
       update proposalLineItem2 ; 
        
         Apttus_Proposal__Proposal_Line_Item__c proposalLineItem3 = TestDataSetupUtility.createProposalLineItem(proposal1.Id);    
        
        proposalLineItem3.Apttus_Proposal__Proposal__c = proposal1.Id;
        proposalLineItem3.Apttus_QPConfig__ConfigurationId__c = aptusConfig.Id;
        proposalLineItem3.Apttus_QPConfig__DerivedFromId__c = aptusLineItem.Id;
        insert proposalLineItem3; 
        
 		 proposalLineItem3.Apttus_Proposal__Product__c = producty.Id;
       update proposalLineItem3 ; 
        
        
        
          OpportunityLineItem oli1 = new OpportunityLineItem (Quantity=2, OpportunityId=opp.Id, TotalPrice=10, PriceBookEntryId= standardPrice.id); 
		insert oli1; 
        
        	OpportunityLineItem oli2 = new OpportunityLineItem (Quantity=2, OpportunityId=opp.Id, TotalPrice=10,PriceBookEntryId= standardPrice2.id, Proposal_Line_Item__c = proposalLineItem3.id); 
		insert oli2; 
        
        
        
          
		// Steps to call The SyncLineItemssWithOpportunityLineItems      
       
        Map<id ,Apttus_Proposal__Proposal_Line_Item__c> NewMp = new Map<id ,Apttus_Proposal__Proposal_Line_Item__c> ();
        NewMp.put(proposalLineItem.id , proposalLineItem) ;
        NewMp.put(proposalLineItem2.id , proposalLineItem2) ;
        NewMp.put(proposalLineItem3.id , proposalLineItem3) ;
        list<Apttus_Proposal__Proposal_Line_Item__c> NewLS = new list<Apttus_Proposal__Proposal_Line_Item__c> ();
        NewLS.add(proposalLineItem);
        NewLS.add(proposalLineItem2);
        NewLS.add(proposalLineItem3);
        ApttusProposalLineItemTriggerHandler.syncLineItemsWithOpportunityLineItems(NewLS,NewMp);
       
        //new Apttus_Proposal__Proposal_Line_Item__c();
        Terms_and_Conditions__c term = new Terms_and_Conditions__c(Name ='TestTerm');//TestDataSetupUtility.createTermAndCondition('TestTerm');
        term.Product__c = product.Id;

        insert term;

        
        
        
        ApttusProposalLineItemTriggerHandler handler = new ApttusProposalLineItemTriggerHandler(true , 1);
        delete proposalLineITem;
        undelete proposalLineITem;
        
     
Test.stopTest();
        
    } 

//Added by : karsan prajapati, when proposal line item location get changed
    static testMethod void testMoethod1(){ 
        //TestDataSetupUtility testData = new TestDataSetupUtility();
        
        Personal_Settings__c personal  = new Personal_Settings__c();
        personal = TestDataSetupUtility.buildPersonalSetting();
        personal.Trigger_Quote__c = true;
        insert personal;

        Sales_Channel_Cross_Reference__c crossRef = TestDataSetupUtility.salesChannelCrossReference();
        insert crossRef;

        Account acc  = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        insert acc;

        List<Contact> lstCon = new List<Contact>();
        Contact con = TestDataSetupUtility.createTestContact(acc.Id, 'Test 1', 'Last 1', 'test@test.com');
        lstCon.add(con);
        Contact con2 = TestDataSetupUtility.createTestContact(acc.Id, 'Test 2', 'Last 2', 'con@test.com');
        lstCon.add(con2);
        insert lstCon;

        acc.PrimaryBillingContact__c = lstCon[0].Id;
        update acc;

        Opportunity opp = TestDataSetupUtility.createTestOpportunity('TestOpp' , acc.Id);
        insert opp;
    
        Product2 product = TestDataSetupUtility.createProduct('Test Product' ,  true);
        product.Family = 'PPC';
        Product2 productx =  TestDataSetupUtility.createProduct('Test Product1' ,  true);
        productx.Family = 'PPC';
		Product2 producty =  TestDataSetupUtility.createProduct('Test Product2' ,  true);
        producty.Family = 'PPC';
        
        update product;
        update productx;
        update producty;
        
        Apttus_Config2__PriceList__c aptusConfigPriceList = TestDataSetupUtility.createPriceList('TestPrice',true);


        Apttus_Proposal__Proposal__c proposal1 = TestDataSetupUtility.createProposal(opp.Id);
        proposal1.BillContact__c = lstCon[0].Id;
        proposal1.PostingContact__c = lstCon[1].Id;
        proposal1.Apttus_Proposal__Primary__c = true;
        proposal1.Apttus_Proposal__Opportunity__c = opp.id ;
       
        insert proposal1;
        system.debug('santoshdebuggingID'+proposal1.id);
        system.debug('santoshdebuggingprimary'+proposal1.Apttus_Proposal__Primary__c);
        system.debug('santoshdebuggingprimary'+[select id,Apttus_Proposal__Primary__c FROM Apttus_Proposal__Proposal__c where id = :proposal1.id]);

      


        Apttus_Config2__ProductConfiguration__c aptusConfig = TestDataSetupUtility.createTestProductConfig(proposal1 , acc , aptusConfigPriceList);
        aptusConfig.Apttus_Config2__Status__c = 'Finalized';

        insert aptusConfig;

        Apttus_Config2__LineItem__c aptusLineItem = TestDataSetupUtility.createLineItemApttus(aptusConfig.Id);
        
        
        insert aptusLineItem;
        Apttus_Config2__ProductAttributeGroup__c aptusGroup = TestDataSetupUtility.createGroup('TestGroup');
        insert aptusGroup;

        Apttus_Config2__ProductAttributeGroupMember__c aptusGrpMember = TestDataSetupUtility.createProductGroupMember('TestGroupMember' , aptusGroup.Id,product.Id);
        
        insert aptusGrpMember; 
        
        Id pricebookId = Test.getStandardPricebookId();
        pricebook2 pb = new pricebook2(id = pricebookId);
        upsert pb;
        
        system.debug('pricebookId***'+pricebookId);
        // 1. Insert a price book entry for the standard price book.
        // Standard price book entries require the standard price book ID we got earlier.
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = product.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        PricebookEntry standardPrice2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = producty.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice2;
        PricebookEntry standardPrice3 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = productx.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice3;
      
        
        // Create a custom price book
        Pricebook2 customPB = new Pricebook2(Name='Standard Price Book', isActive=true);
        insert customPB;
        
        // 2. Insert a price book entry with a custom price.
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = product.Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice;
        
        PricebookEntry customPrice2 = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = producty.Id,
            UnitPrice = 13000, IsActive = true);
        insert customPrice2;
        
        
        AVA_SFCORE__TaxNowSetting__c TNS = New AVA_SFCORE__TaxNowSetting__c(name = 'TestSetting', AVA_SFCORE__Active_Setting__c = TRUE);
        insert TNS ;
        
        Test.startTest() ;
        
        Apttus_Proposal__Proposal_Line_Item__c proposalLineItem = TestDataSetupUtility.createProposalLineItem(proposal1.Id);    
        
        proposalLineItem.Apttus_Proposal__Proposal__c = proposal1.Id;
        proposalLineItem.Apttus_QPConfig__ConfigurationId__c = aptusConfig.Id;
        proposalLineItem.Apttus_QPConfig__DerivedFromId__c = aptusLineItem.Id;
        insert proposalLineItem; 
        
 		proposalLineItem.Apttus_Proposal__Product__c = product.Id;
 		proposalLineItem.PostingLocation__c = 'Ahmedabad';
        update proposalLineItem ; 
 
        Apttus_Proposal__Proposal_Line_Item__c proposalLineItem2 = TestDataSetupUtility.createProposalLineItem(proposal1.Id);    
        
        proposalLineItem2.Apttus_Proposal__Proposal__c = proposal1.Id;
        proposalLineItem2.Apttus_QPConfig__ConfigurationId__c = aptusConfig.Id;
        proposalLineItem2.Apttus_QPConfig__DerivedFromId__c = aptusLineItem.Id;
        insert proposalLineItem2; 
        
 		proposalLineItem2.Apttus_Proposal__Product__c = productx.Id;
 		proposalLineItem2.PostingLocation__c = 'Ahmedabad';
        update proposalLineItem2 ; 
        
        Apttus_Proposal__Proposal_Line_Item__c proposalLineItem3 = TestDataSetupUtility.createProposalLineItem(proposal1.Id);    
        
        proposalLineItem3.Apttus_Proposal__Proposal__c = proposal1.Id;
        proposalLineItem3.Apttus_QPConfig__ConfigurationId__c = aptusConfig.Id;
        proposalLineItem3.Apttus_QPConfig__DerivedFromId__c = aptusLineItem.Id;
        insert proposalLineItem3; 
        
 		proposalLineItem3.Apttus_Proposal__Product__c = producty.Id;
 		proposalLineItem3.PostingLocation__c = 'Ahmedabad';
        update proposalLineItem3 ; 
        
        
        
        OpportunityLineItem oli1 = new OpportunityLineItem (Quantity=2, OpportunityId=opp.Id, TotalPrice=10, PriceBookEntryId= standardPrice.id); 
		insert oli1; 
        
        OpportunityLineItem oli2 = new OpportunityLineItem (Quantity=2, OpportunityId=opp.Id, TotalPrice=10,PriceBookEntryId= standardPrice2.id, Proposal_Line_Item__c = proposalLineItem3.id); 
		insert oli2; 
        
		// Steps to call The SyncLineItemssWithOpportunityLineItems      
       
        Map<id ,Apttus_Proposal__Proposal_Line_Item__c> NewMp = new Map<id ,Apttus_Proposal__Proposal_Line_Item__c> ();
        NewMp.put(proposalLineItem.id , proposalLineItem) ;
        NewMp.put(proposalLineItem2.id , proposalLineItem2) ;
        NewMp.put(proposalLineItem3.id , proposalLineItem3) ;
        list<Apttus_Proposal__Proposal_Line_Item__c> NewLS = new list<Apttus_Proposal__Proposal_Line_Item__c> ();
        NewLS.add(proposalLineItem);
        NewLS.add(proposalLineItem2);
        NewLS.add(proposalLineItem3);
        ApttusProposalLineItemTriggerHandler.syncLineItemsWithOpportunityLineItems(NewLS,NewMp);
       
        //new Apttus_Proposal__Proposal_Line_Item__c();
        Terms_and_Conditions__c term = new Terms_and_Conditions__c(Name ='TestTerm');//TestDataSetupUtility.createTermAndCondition('TestTerm');
        term.Product__c = product.Id;

        insert term;


        ApttusProposalLineItemTriggerHandler handler = new ApttusProposalLineItemTriggerHandler(true , 1);
        delete proposalLineITem;
        undelete proposalLineITem;
        
     
        Test.stopTest();
        
    }

//Added by : karsan prajapati, when Trigger_Quote__c = false;
    static testMethod void testMethod2(){ 
        //TestDataSetupUtility testData = new TestDataSetupUtility();
        
        Personal_Settings__c personal  = new Personal_Settings__c();
        personal = TestDataSetupUtility.buildPersonalSetting();
        personal.Trigger_Quote__c = false;
        insert personal;

        Sales_Channel_Cross_Reference__c crossRef = TestDataSetupUtility.salesChannelCrossReference();
        insert crossRef;

        Account acc  = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        insert acc;

        List<Contact> lstCon = new List<Contact>();
        Contact con = TestDataSetupUtility.createTestContact(acc.Id, 'Test 1', 'Last 1', 'test@test.com');
        lstCon.add(con);
        Contact con2 = TestDataSetupUtility.createTestContact(acc.Id, 'Test 2', 'Last 2', 'con@test.com');
        lstCon.add(con2);
        insert lstCon;

        acc.PrimaryBillingContact__c = lstCon[0].Id;
        update acc;

        Opportunity opp = TestDataSetupUtility.createTestOpportunity('TestOpp' , acc.Id);
        insert opp;
    
        Product2 product = TestDataSetupUtility.createProduct('Test Product' ,  true);
        product.Family = 'PPC';
        Product2 productx =  TestDataSetupUtility.createProduct('Test Product1' ,  true);
        productx.Family = 'PPC';
		Product2 producty =  TestDataSetupUtility.createProduct('Test Product2' ,  true);
        producty.Family = 'PPC';
        
        update product;
        update productx;
        update producty;
        
        Apttus_Config2__PriceList__c aptusConfigPriceList = TestDataSetupUtility.createPriceList('TestPrice',true);


        Apttus_Proposal__Proposal__c proposal1 = TestDataSetupUtility.createProposal(opp.Id);
        proposal1.BillContact__c = lstCon[0].Id;
        proposal1.PostingContact__c = lstCon[1].Id;
        proposal1.Apttus_Proposal__Primary__c = true;
        proposal1.Apttus_Proposal__Opportunity__c = opp.id ;
       
        insert proposal1;
        system.debug('santoshdebuggingID'+proposal1.id);
        system.debug('santoshdebuggingprimary'+proposal1.Apttus_Proposal__Primary__c);
        system.debug('santoshdebuggingprimary'+[select id,Apttus_Proposal__Primary__c FROM Apttus_Proposal__Proposal__c where id = :proposal1.id]);

      


        Apttus_Config2__ProductConfiguration__c aptusConfig = TestDataSetupUtility.createTestProductConfig(proposal1 , acc , aptusConfigPriceList);
        aptusConfig.Apttus_Config2__Status__c = 'Finalized';

        insert aptusConfig;

        Apttus_Config2__LineItem__c aptusLineItem = TestDataSetupUtility.createLineItemApttus(aptusConfig.Id);
        
        
        insert aptusLineItem;
        Apttus_Config2__ProductAttributeGroup__c aptusGroup = TestDataSetupUtility.createGroup('TestGroup');
        insert aptusGroup;

        Apttus_Config2__ProductAttributeGroupMember__c aptusGrpMember = TestDataSetupUtility.createProductGroupMember('TestGroupMember' , aptusGroup.Id,product.Id);
        
        insert aptusGrpMember; 
        
        Id pricebookId = Test.getStandardPricebookId();
        pricebook2 pb = new pricebook2(id = pricebookId);
        upsert pb;
        
        system.debug('pricebookId***'+pricebookId);
        // 1. Insert a price book entry for the standard price book.
        // Standard price book entries require the standard price book ID we got earlier.
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = product.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        PricebookEntry standardPrice2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = producty.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice2;
        PricebookEntry standardPrice3 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = productx.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice3;
        
      
        
        // Create a custom price book
        Pricebook2 customPB = new Pricebook2(Name='Standard Price Book', isActive=true);
        insert customPB;
        
        // 2. Insert a price book entry with a custom price.
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = product.Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice;
        
        PricebookEntry customPrice2 = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = producty.Id,
            UnitPrice = 13000, IsActive = true);
        insert customPrice2;
        
        
        AVA_SFCORE__TaxNowSetting__c TNS = New AVA_SFCORE__TaxNowSetting__c(name = 'TestSetting', AVA_SFCORE__Active_Setting__c = TRUE);
        insert TNS ;
        
        Test.startTest() ;
        
        Apttus_Proposal__Proposal_Line_Item__c proposalLineItem = TestDataSetupUtility.createProposalLineItem(proposal1.Id);    
        
        proposalLineItem.Apttus_Proposal__Proposal__c = proposal1.Id;
        proposalLineItem.Apttus_QPConfig__ConfigurationId__c = aptusConfig.Id;
        proposalLineItem.Apttus_QPConfig__DerivedFromId__c = aptusLineItem.Id;
        proposalLineItem.Sales_Credit__c = 100;
        insert proposalLineItem; 
        
 		proposalLineItem.Apttus_Proposal__Product__c = product.Id;
        update proposalLineItem ; 
 
        Apttus_Proposal__Proposal_Line_Item__c proposalLineItem2 = TestDataSetupUtility.createProposalLineItem(proposal1.Id);    
        
        proposalLineItem2.Apttus_Proposal__Proposal__c = proposal1.Id;
        proposalLineItem2.Apttus_QPConfig__ConfigurationId__c = aptusConfig.Id;
        proposalLineItem2.Apttus_QPConfig__DerivedFromId__c = aptusLineItem.Id;
        proposalLineItem2.Sales_Credit__c = 100;
        insert proposalLineItem2; 
        
 		proposalLineItem2.Apttus_Proposal__Product__c = productx.Id;
        update proposalLineItem2 ; 
        
        Apttus_Proposal__Proposal_Line_Item__c proposalLineItem3 = TestDataSetupUtility.createProposalLineItem(proposal1.Id);    
        
        proposalLineItem3.Apttus_Proposal__Proposal__c = proposal1.Id;
        proposalLineItem3.Apttus_QPConfig__ConfigurationId__c = aptusConfig.Id;
        proposalLineItem3.Apttus_QPConfig__DerivedFromId__c = aptusLineItem.Id;
        proposalLineItem3.Sales_Credit__c = 100;
        insert proposalLineItem3; 
        
 		proposalLineItem3.Apttus_Proposal__Product__c = producty.Id;
        update proposalLineItem3 ; 
        
        
        
        OpportunityLineItem oli1 = new OpportunityLineItem (Quantity=2, OpportunityId=opp.Id, TotalPrice=10, PriceBookEntryId= standardPrice.id); 
		insert oli1; 
        
        OpportunityLineItem oli2 = new OpportunityLineItem (Quantity=2, OpportunityId=opp.Id, TotalPrice=10,PriceBookEntryId= standardPrice2.id, Proposal_Line_Item__c = proposalLineItem3.id); 
		insert oli2; 
        
		// Steps to call The SyncLineItemssWithOpportunityLineItems      
       
        Map<id ,Apttus_Proposal__Proposal_Line_Item__c> NewMp = new Map<id ,Apttus_Proposal__Proposal_Line_Item__c> ();
        NewMp.put(proposalLineItem.id , proposalLineItem) ;
        NewMp.put(proposalLineItem2.id , proposalLineItem2) ;
        NewMp.put(proposalLineItem3.id , proposalLineItem3) ;
        list<Apttus_Proposal__Proposal_Line_Item__c> NewLS = new list<Apttus_Proposal__Proposal_Line_Item__c> ();
        NewLS.add(proposalLineItem);
        NewLS.add(proposalLineItem2);
        NewLS.add(proposalLineItem3);
        ApttusProposalLineItemTriggerHandler.syncLineItemsWithOpportunityLineItems(NewLS,NewMp);
       
        //new Apttus_Proposal__Proposal_Line_Item__c();
        Terms_and_Conditions__c term = new Terms_and_Conditions__c(Name ='TestTerm');//TestDataSetupUtility.createTermAndCondition('TestTerm');
        term.Product__c = product.Id;

        insert term;


        ApttusProposalLineItemTriggerHandler handler = new ApttusProposalLineItemTriggerHandler(true , 1);
        delete proposalLineITem;
        undelete proposalLineITem;
        
     
        Test.stopTest();
        
    }
}