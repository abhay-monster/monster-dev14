/***********************************************************************************************************
 * Appirio, Inc
 * Name         : ruleProcessorTest
 * Created By   : Rohit B. (Appirio)
 * Purpose      : Test class of ruleProcessor
 * Created Date : 10/Oct/2015
 *
 * Date Modified                Modified By             Description of the update
 * [Date]						[Person Name]			[Short Description]
 **********************************************************************************************************/
@isTest
private class ruleProcessorTest {
	static Account acct = null;
	static Account account;
	static Apttus_Proposal__Proposal__c proposal_n;

	@isTest 
	static void test_method_one() {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
	    User manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
		insert manager;
	    User testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
	    testUser.ManagerId = manager.Id;
	    testUser.Discount_Threshold__c  = 10.0;
	    insert testuser;
		
		Apttus_Config2__ConfigSystemProperties__c sysProp = new Apttus_Config2__ConfigSystemProperties__c();
		sysProp.Name = 'System Properties';
		sysProp.Apttus_Config2__DefaultProductsPage__c = 'test123';
		sysProp.Apttus_Config2__ViewCartPage__c = 'testing234e4523';
		insert sysProp;

		Apttus_Proposal__Proposal__c proposal = null;
		acct = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TestAcct_28_07_15');
		insert acct;
		Contact con = TestDataSetupUtility.createTestContact(acct.Id, 'Test_Last', 'Test_First', 'test@test.com');
		insert con;
		Opportunity oppt = TestDataSetupUtility.createTestOpportunity('TestOppt_28_07_15', acct.Id);
		insert oppt;
		proposal = TestDataSetupUtility.createProposal('TEST_PROP_28_07_15', acct.Id, oppt.Id, 'test', false);
		insert proposal;

		Apttus_Config2__ProductConfiguration__c prodConfig = new Apttus_Config2__ProductConfiguration__c(Apttus_QPConfig__Proposald__c=proposal.Id,Apttus_Config2__AccountId__c=acct.Id);
		insert prodConfig;
		
///////////////////////////////////////////////////////////////////////////////////////////
        
        // create Product
        Product2 product = TestDataSetupUtility.createProduct('Test product1', false); 
	    product.Convert_From__c = true;
	    product.ProductCode = 'testcode';
	    insert product;

        // create Attribute_Value_Group__c
        Attribute_Value_Group__c attr_group_value = new Attribute_Value_Group__c();
        attr_group_value.Indexing_Key__c = 'Proposal:Contract_Duration__c = 1 Month';
        insert attr_group_value;

        List<Attribute_Value__c> lstAV = new List<Attribute_Value__c>();
        lstAV.add(TestDataSetupUtility.createAttributeValue('Product_Name__c', 'Product', 'OptionProduct1', 1, false));
        lstAV.add(TestDataSetupUtility.createAttributeValue('Selling_Country__c', 'Proposal', 'United States', 4, false));
        lstAV.add(TestDataSetupUtility.createAttributeValue('Apttus_QPConfig__PriceListId__r.Name', 'Proposal', 'USD Price List', 1, false));
        insert lstAV;

        // create Attribute_Value_Group_Member__c
        List<Attribute_Value_Group_Member__c> lstAVGM = new List<Attribute_Value_Group_Member__c>();
        lstAVGM.add(new Attribute_Value_Group_Member__c(
	        Attribute_Value_Group__c = attr_group_value.Id,
	        Attribute_Value__c = lstAV[0].Id,
        	Product_Code__c = product.ProductCode,
        	Attribute_Value_Name_Manual__c = 'AVNM'
        ));

        lstAVGM.add(new Attribute_Value_Group_Member__c(
        	Attribute_Value_Group__c = attr_group_value.Id,
	        Attribute_Value__c = lstAV[1].Id,
        	Product_Code__c = product.ProductCode,
        	Attribute_Value_Name_Manual__c = 'AVNM'
        ));

        lstAVGM.add(new Attribute_Value_Group_Member__c(
        	Attribute_Value_Group__c = attr_group_value.Id,
	        Attribute_Value__c = lstAV[2].Id,
	        Product_Code__c = product.ProductCode,
	        Attribute_Value_Name_Manual__c = 'AVNM'
	    ));

        insert lstAVGM;        
	    
	    // create Apttus_Config2__ClassificationName__c
	    Apttus_Config2__ClassificationName__c category = new Apttus_Config2__ClassificationName__c();
	    category.Name = 'Test Option Group 2';
	    category.Apttus_Config2__HierarchyLabel__c = 'Test Option Group 2';
	    insert category;
	    
	    // create Apttus_Config2__ClassificationHierarchy__c
	    Apttus_Config2__ClassificationHierarchy__c ch = new Apttus_Config2__ClassificationHierarchy__c();
	    ch.Name = 'new hierarchy';
	    ch.Apttus_Config2__Label__c = 'Test Option Group 2';
	    ch.Apttus_Config2__HierarchyId__c = category.Id;
	    insert ch;
	    
	    // create Apttus_Config2__ProductOptionGroup__c
	    Apttus_Config2__ProductOptionGroup__c pog = new Apttus_Config2__ProductOptionGroup__c();
	    pog.Apttus_Config2__Sequence__c = 1;
	    pog.Apttus_Config2__ProductId__c = product.Id;
	    pog.Apttus_Config2__OptionGroupId__c = ch.Id;
	    insert pog;
	    
	    // create Apttus_Config2__ProductOptionComponent__c
	    Apttus_Config2__ProductOptionComponent__c poc = new Apttus_Config2__ProductOptionComponent__c();
	    poc.Apttus_Config2__Sequence__c =1;
	    poc.Apttus_Config2__ProductOptionGroupId__c = pog.Id;
	    insert poc;
	    
	    // create product attribute rule definitions
        Product_Attribute_Rule_Definitions__c pard = new Product_Attribute_Rule_Definitions__c();
        pard.Controlling_Attribute_Value_Group__c = attr_group_value.Id;
        pard.active__c = true;
        pard.Primary_Product__c = product.Id;
        pard.Product_Option_Group__c = pog.Id;
        insert pard;
	    
	    account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        system.debug('after account ' + account);
        insert account;
	        
	        
        //create Opportunity
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', account.Id);
        opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'GCS Opportunity');
        insert opp;
        
        
        
        Product2 product1 = TestDataSetupUtility.createProduct('Test Product2', false);
        product.Convert_From__c = true;
        insert product1;
        
        //Create price list
        Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
        insert priceList; 
        
        Apttus_Config2__PriceListItem__c pli = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 10, Apttus_Config2__ProductId__c = product.Id, Apttus_Config2__ChargeType__c = 'Standard Price');
    	insert pli;
        
        //create proposal
        proposal_n = TestDataSetupUtility.createProposal('Test Proposal', account.Id, opp.Id, 'Accepted Online', false);
        proposal_n.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Apttus_Proposal__Proposal__c', 'Proposal');
        proposal_n.Apttus_QPConfig__PriceListId__c = priceList.id;        
        
        insert proposal_n;	
        
    
        Apttus_Config2__ProductConfiguration__c config = TestDataSetupUtility.createTestProductConfig(proposal_n,account,priceList);
        insert config;
        //System.debug('config:'+config);
	   
	    Apttus_Config2__LineItem__c aptusLineItem = TestDataSetupUtility.createLineItemApttus(config.Id);
        aptusLineItem.Apttus_Config2__StartDate__c=System.today();
        aptusLineItem.Apttus_Config2__EndDate__c=System.today()+60;
        aptusLineItem.Apttus_Config2__Comments__c='test';
        aptusLineItem.Apttus_Config2__ProductId__c = product.Id;
		aptusLineItem.Apttus_Config2__ProductOptionId__c = poc.Id ;
		aptusLineItem.Apttus_Config2__LineNumber__c = 1;
		//aptusLineItem.Apttus_Config2__OptionId__c = product.Id;
        insert aptusLineItem;
	   

//////////////////////////////////////////////////////////////////////////////////////////
		
		//ApexPages.currentPage().getParameters().put('configRequestId',getProductConfig().Id);
		ApexPages.currentPage().getParameters().put('id',prodConfig.Id);
		//Apttus_config2__lineItem__c lineItem = createLineItem();
		product = new Product2(Product_Line__c='TEST',Discount_Threshold__c=20.00,Name='Test Product');
		insert product;
		
		List<Apttus_config2__lineItem__c> lstLineItem = new List<Apttus_config2__lineItem__c>();
		
		Apttus_config2__lineItem__c lineItem = new Apttus_config2__lineItem__c(Apttus_Config2__ConfigurationId__c=prodConfig.Id,
		Attributes_Defaulted__c=false,
		Apttus_Config2__OptionId__c=product.Id,
		Apttus_Config2__PrimaryLineNumber__c=5,
		Apttus_Config2__LineNumber__c=6,
		Apttus_Config2__ItemSequence__c=7,
		Apttus_Config2__LineType__c='Option');
		lstLineItem.add(lineItem);
		Apttus_config2__lineItem__c lineItem1 = new Apttus_config2__lineItem__c(Apttus_Config2__ConfigurationId__c=prodConfig.Id,
		Attributes_Defaulted__c=false,
		Apttus_Config2__OptionId__c=product.Id,
		Apttus_Config2__PrimaryLineNumber__c=5,
		Apttus_Config2__LineNumber__c=6,
		Apttus_Config2__ItemSequence__c=7,
		Apttus_Config2__LineType__c='Product/Service');
		lstLineItem.add(lineItem1);
		insert lstLineItem;
		lineItem.Apttus_Config2__ProductId__c = product.Id;
		lineItem.Apttus_Config2__ProductOptionId__c = poc.Id ;
		lineItem.Apttus_Config2__OptionId__c = product.Id;
	
		lineItem.Apttus_Config2__LineNumber__c = 2;
		//insert lineItem;
		List<Id> listLineItemId = new List<Id>{lineItem.Apttus_Config2__OptionId__c, aptusLineItem.Apttus_Config2__OptionId__c};
		
		Apttus_Config2__ProductAttributeGroup__c prodAttrGrp = new Apttus_Config2__ProductAttributeGroup__c();
		insert prodAttrGrp;
		
		Apttus_Config2__ProductAttributeGroupMember__c prodAttrGrpMember = new Apttus_Config2__ProductAttributeGroupMember__c(Apttus_Config2__AttributeGroupId__c=prodAttrGrp.Id,name='Tst Member',Apttus_Config2__Sequence__c=6);
		insert prodAttrGrpMember;
		
		Apttus_Config2__ProductAttribute__c prodAttr = new Apttus_Config2__ProductAttribute__c(Apttus_Config2__AttributeGroupId__c=prodAttrGrp.Id,Apttus_Config2__Field__c='test',Apttus_Config2__Sequence__c=6);
		List<Apttus_Config2__ProductAttribute__c> listProdAttr = new List<Apttus_Config2__ProductAttribute__c>{prodAttr};
		insert listProdAttr;
		pard = [select id, Controlling_Attribute_Value_Group__c,Dependent_Attribute_Value_Group__c from Product_Attribute_Rule_Definitions__c where id = :pard.Id limit 1];
        Test.startTest();
	        //map<Id,productRuleHelper.productRuleInfo>  ruleHeapByProductId = productRuleHelper.QueryPardRulesByOptions(new list<Id>{lineItem.Apttus_Config2__OptionId__c},new set<Id>{pog.Id}); 
	        productRuleHelper.productRuleInfo prodRuleInstance= new productRuleHelper.productRuleInfo(); //ruleHeapByProductId.get(lineItem.Apttus_Config2__OptionId__c);
	        //prodRuleInstance.attValGrpByPardId
	        prodRuleInstance.attValGrpByPardId.put(pard.id,new list<Id>{pard.Controlling_Attribute_Value_Group__c,
		                                             pard.Dependent_Attribute_Value_Group__c});
		 	prodRuleInstance.groupMembersByGroupId.put(attr_group_value.Id,new List<Attribute_Value_Group_Member__c>{lstAVGM[0]});
	        ruleProcessor ruleProcessInstance=new ruleProcessor(prodRuleInstance,proposal_n, null);
	        list<string> fieldAPINames = new list<string> {'Product_Name__c','Geography__c','Quantity__c'};
	        ruleProcessInstance.processRules(fieldAPINames, 'Test Product')   ;         
		Test.stopTest();
	}
    
    @isTest 
    static void test_method_Two() {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
	    User manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
		insert manager;
	    User testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
	    testUser.ManagerId = manager.Id;
	    testUser.Discount_Threshold__c  = 10.0;
	    insert testuser;
		
		Apttus_Config2__ConfigSystemProperties__c sysProp = new Apttus_Config2__ConfigSystemProperties__c();
		sysProp.Name = 'System Properties';
		sysProp.Apttus_Config2__DefaultProductsPage__c = 'test123';
		sysProp.Apttus_Config2__ViewCartPage__c = 'testing234e4523';
		insert sysProp;

		Apttus_Proposal__Proposal__c proposal = null;
		acct = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TestAcct_28_07_15');
		insert acct;
		Contact con = TestDataSetupUtility.createTestContact(acct.Id, 'Test_Last', 'Test_First', 'test@test.com');
		insert con;
		Opportunity oppt = TestDataSetupUtility.createTestOpportunity('TestOppt_28_07_15', acct.Id);
		insert oppt;
		proposal = TestDataSetupUtility.createProposal('TEST_PROP_28_07_15', acct.Id, oppt.Id, 'test', false);
		insert proposal;

		Apttus_Config2__ProductConfiguration__c prodConfig = new Apttus_Config2__ProductConfiguration__c(Apttus_QPConfig__Proposald__c=proposal.Id,Apttus_Config2__AccountId__c=acct.Id);
		insert prodConfig;
		
///////////////////////////////////////////////////////////////////////////////////////////
        
        // create Product
        Product2 product = TestDataSetupUtility.createProduct('Test product1', false); 
	    product.Convert_From__c = true;
	    product.ProductCode = 'testcode';
	    insert product;

        // create Attribute_Value_Group__c
        Attribute_Value_Group__c attr_group_value = new Attribute_Value_Group__c();
        attr_group_value.Indexing_Key__c = 'Proposal:Contract_Duration__c = 1 Month';
        insert attr_group_value;
        
                Attribute_Value_Group__c attr_group_value2 = new Attribute_Value_Group__c();
        attr_group_value2.Indexing_Key__c = 'Monster Extended Rush Powered hide';
        insert attr_group_value2;

        List<Attribute_Value__c> lstAV = new List<Attribute_Value__c>();
        lstAV.add(TestDataSetupUtility.createAttributeValue('Product_Name__c', 'Product', 'OptionProduct1', 1, false));
        lstAV.add(TestDataSetupUtility.createAttributeValue('Selling_Country__c', 'Proposal', 'United States', 4, false));
        lstAV.add(TestDataSetupUtility.createAttributeValue('Apttus_QPConfig__PriceListId__r.Name', 'Proposal', 'USD Price List', 1, false));
        insert lstAV;
		
        // create Attribute_Value_Group_Member__c
        List<Attribute_Value_Group_Member__c> lstAVGM = new List<Attribute_Value_Group_Member__c>();
        lstAVGM.add(new Attribute_Value_Group_Member__c(
	        Attribute_Value_Group__c = attr_group_value.Id,
	        Attribute_Value__c = lstAV[1].Id,                                   
        	Product_Code__c = product.ProductCode,
        	Attribute_Value_Name_Manual__c = 'AVNM'
        ));

        lstAVGM.add(new Attribute_Value_Group_Member__c(
        	Attribute_Value_Group__c = attr_group_value.Id,
	        Attribute_Value__c = lstAV[1].Id,
        	Product_Code__c = product.ProductCode,
        	Attribute_Value_Name_Manual__c = 'AVNM'
        ));

        lstAVGM.add(new Attribute_Value_Group_Member__c(
        	Attribute_Value_Group__c = attr_group_value.Id,
	        Attribute_Value__c = lstAV[2].Id,
	        Product_Code__c = product.ProductCode,
	        Attribute_Value_Name_Manual__c = 'AVNM'
	    ));

        insert lstAVGM;        
	    
         // create Attribute_Value_Group_Member__c
        List<Attribute_Value_Group_Member__c> lstAVGM2 = new List<Attribute_Value_Group_Member__c>();
        lstAVGM2.add(new Attribute_Value_Group_Member__c(
	        Attribute_Value_Group__c = attr_group_value2.Id,
	        Attribute_Value__c = lstAV[1].Id,                                   
        	Product_Code__c = product.ProductCode,
        	Attribute_Value_Name_Manual__c = 'AVNM'
        ));

        lstAVGM2.add(new Attribute_Value_Group_Member__c(
        	Attribute_Value_Group__c = attr_group_value2.Id,
	        Attribute_Value__c = lstAV[1].Id,
        	Product_Code__c = product.ProductCode,
        	Attribute_Value_Name_Manual__c = 'AVNM'
        ));

        lstAVGM2.add(new Attribute_Value_Group_Member__c(
        	Attribute_Value_Group__c = attr_group_value2.Id,
	        Attribute_Value__c = lstAV[2].Id,
	        Product_Code__c = product.ProductCode,
	        Attribute_Value_Name_Manual__c = 'AVNM'
	    ));

        insert lstAVGM2; 
	    // create Apttus_Config2__ClassificationName__c
	    Apttus_Config2__ClassificationName__c category = new Apttus_Config2__ClassificationName__c();
	    category.Name = 'Test Option Group 2';
	    category.Apttus_Config2__HierarchyLabel__c = 'Test Option Group 2';
	    insert category;
	    
	    // create Apttus_Config2__ClassificationHierarchy__c
	    Apttus_Config2__ClassificationHierarchy__c ch = new Apttus_Config2__ClassificationHierarchy__c();
	    ch.Name = 'new hierarchy';
	    ch.Apttus_Config2__Label__c = 'Test Option Group 2';
	    ch.Apttus_Config2__HierarchyId__c = category.Id;
	    insert ch;
	    
	    // create Apttus_Config2__ProductOptionGroup__c
	    Apttus_Config2__ProductOptionGroup__c pog = new Apttus_Config2__ProductOptionGroup__c();
	    pog.Apttus_Config2__Sequence__c = 1;
	    pog.Apttus_Config2__ProductId__c = product.Id;
	    pog.Apttus_Config2__OptionGroupId__c = ch.Id;
	    insert pog;
	    
	    // create Apttus_Config2__ProductOptionComponent__c
	    Apttus_Config2__ProductOptionComponent__c poc = new Apttus_Config2__ProductOptionComponent__c();
	    poc.Apttus_Config2__Sequence__c =1;
	    poc.Apttus_Config2__ProductOptionGroupId__c = pog.Id;
	    insert poc;
	    
	    // create product attribute rule definitions
        Product_Attribute_Rule_Definitions__c pard = new Product_Attribute_Rule_Definitions__c();
        pard.Controlling_Attribute_Value_Group__c = attr_group_value.Id;
        pard.Dependent_Attribute_Value_Group__c = attr_group_value2.Id;
        pard.active__c = true;
        pard.Primary_Product__c = product.Id;
        pard.Product_Option_Group__c = pog.Id;
        insert pard;
	    
	    account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        system.debug('after account ' + account);
        insert account;
	        
	        
        //create Opportunity
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', account.Id);
        opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'GCS Opportunity');
        insert opp;
        
        
        
        Product2 product1 = TestDataSetupUtility.createProduct('Test Product2', false);
        product.Convert_From__c = true;
        insert product1;
        
        //Create price list
        Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
        insert priceList; 
        
        Apttus_Config2__PriceListItem__c pli = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 10, Apttus_Config2__ProductId__c = product.Id, Apttus_Config2__ChargeType__c = 'Standard Price');
    	insert pli;
        
        //create proposal
        proposal_n = TestDataSetupUtility.createProposal('Test Proposal', account.Id, opp.Id, 'Accepted Online', false);
        proposal_n.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Apttus_Proposal__Proposal__c', 'Proposal');
        proposal_n.Apttus_QPConfig__PriceListId__c = priceList.id;        
        
        insert proposal_n;	
        
    
        Apttus_Config2__ProductConfiguration__c config = TestDataSetupUtility.createTestProductConfig(proposal_n,account,priceList);
        insert config;
        //System.debug('config:'+config);
	   
	    Apttus_Config2__LineItem__c aptusLineItem = TestDataSetupUtility.createLineItemApttus(config.Id);
        aptusLineItem.Apttus_Config2__StartDate__c=System.today();
        aptusLineItem.Apttus_Config2__EndDate__c=System.today()+60;
        aptusLineItem.Apttus_Config2__Comments__c='test';
        aptusLineItem.Apttus_Config2__ProductId__c = product.Id;
		aptusLineItem.Apttus_Config2__ProductOptionId__c = poc.Id ;
		aptusLineItem.Apttus_Config2__LineNumber__c = 1;
		//aptusLineItem.Apttus_Config2__OptionId__c = product.Id;
        insert aptusLineItem;
	   

//////////////////////////////////////////////////////////////////////////////////////////
		
		//ApexPages.currentPage().getParameters().put('configRequestId',getProductConfig().Id);
		ApexPages.currentPage().getParameters().put('id',prodConfig.Id);
		//Apttus_config2__lineItem__c lineItem = createLineItem();
		product = new Product2(Product_Line__c='TEST',Discount_Threshold__c=20.00,Name='Test Product');
		insert product;
		
		List<Apttus_config2__lineItem__c> lstLineItem = new List<Apttus_config2__lineItem__c>();
		
		Apttus_config2__lineItem__c lineItem = new Apttus_config2__lineItem__c(Apttus_Config2__ConfigurationId__c=prodConfig.Id,
		Attributes_Defaulted__c=false,
		Apttus_Config2__OptionId__c=product.Id,
		Apttus_Config2__PrimaryLineNumber__c=5,
		Apttus_Config2__LineNumber__c=6,
		Apttus_Config2__ItemSequence__c=7,
		Apttus_Config2__LineType__c='Option');
		lstLineItem.add(lineItem);
		Apttus_config2__lineItem__c lineItem1 = new Apttus_config2__lineItem__c(Apttus_Config2__ConfigurationId__c=prodConfig.Id,
		Attributes_Defaulted__c=false,
		Apttus_Config2__OptionId__c=product.Id,
		Apttus_Config2__PrimaryLineNumber__c=5,
		Apttus_Config2__LineNumber__c=6,
		Apttus_Config2__ItemSequence__c=7,
		Apttus_Config2__LineType__c='Product/Service');
		lstLineItem.add(lineItem1);
		insert lstLineItem;
		lineItem.Apttus_Config2__ProductId__c = product.Id;
		lineItem.Apttus_Config2__ProductOptionId__c = poc.Id ;
		lineItem.Apttus_Config2__OptionId__c = product.Id;
	
		lineItem.Apttus_Config2__LineNumber__c = 2;
		//insert lineItem;
		List<Id> listLineItemId = new List<Id>{lineItem.Apttus_Config2__OptionId__c, aptusLineItem.Apttus_Config2__OptionId__c};
		
		Apttus_Config2__ProductAttributeGroup__c prodAttrGrp = new Apttus_Config2__ProductAttributeGroup__c();
		insert prodAttrGrp;
		
		Apttus_Config2__ProductAttributeGroupMember__c prodAttrGrpMember = new Apttus_Config2__ProductAttributeGroupMember__c(Apttus_Config2__AttributeGroupId__c=prodAttrGrp.Id,name='Tst Member',Apttus_Config2__Sequence__c=6);
		insert prodAttrGrpMember;
		
		Apttus_Config2__ProductAttribute__c prodAttr = new Apttus_Config2__ProductAttribute__c(Apttus_Config2__AttributeGroupId__c=prodAttrGrp.Id,Apttus_Config2__Field__c='test',Apttus_Config2__Sequence__c=6);
		List<Apttus_Config2__ProductAttribute__c> listProdAttr = new List<Apttus_Config2__ProductAttribute__c>{prodAttr};
		insert listProdAttr;
		pard = [select id, Controlling_Attribute_Value_Group__c,Dependent_Attribute_Value_Group__c from Product_Attribute_Rule_Definitions__c where id = :pard.Id AND Dependent_Attribute_Value_Group__c != NULL limit 1];
        Test.startTest();
	        //map<Id,productRuleHelper.productRuleInfo>  ruleHeapByProductId = productRuleHelper.QueryPardRulesByOptions(new list<Id>{lineItem.Apttus_Config2__OptionId__c},new set<Id>{pog.Id}); 
	        productRuleHelper.productRuleInfo prodRuleInstance= new productRuleHelper.productRuleInfo(); //ruleHeapByProductId.get(lineItem.Apttus_Config2__OptionId__c);
	        //prodRuleInstance.attValGrpByPardId
	        prodRuleInstance.attValGrpByPardId.put(pard.id,new list<Id>{pard.Controlling_Attribute_Value_Group__c,
		                                             pard.Dependent_Attribute_Value_Group__c});
        	System.debug('lstAV[1].Id'+lstAV[1]);  
        	System.debug('MS TEST lstAVGM'+lstAVGM[0].Attribute_Value__c);
        	System.debug('MS TEST lstAVGM'+lstAVGM[0].Attribute_Value__r.Attributes_Name__c);
        	System.debug('MS TEST lstAVGM'+lstAVGM[0].Attribute_Value__r.Attribute_Values__c);
        	System.debug('MS TEST lstAVGM'+lstAVGM[0].Attribute_Value__r.Attribute_Type__c);
        	List<Attribute_Value_Group_Member__c> LstAVGMA = [select Attribute_Value_Name__c,
                                                             Attribute_Record_Value__c,
                                                             Attribute_Value_Type__c,                                                             
                                                             attribute_Value_Group__c,
                                                             Attribute_Value__c,
                                                              Product_Code__c,
                                                                Attribute_Value_Name_Manual__c
                                                            		FROM Attribute_Value_Group_Member__c
                                                            	WHERE id = :lstAVGM[0].id] ;
        List<Attribute_Value_Group_Member__c> LstAVGMA2 = [select Attribute_Value_Name__c,
                                                             Attribute_Record_Value__c,
                                                             Attribute_Value_Type__c,                                                             
                                                             attribute_Value_Group__c,
                                                             Attribute_Value__c,
                                                              Product_Code__c,
                                                                Attribute_Value_Name_Manual__c
                                                            		FROM Attribute_Value_Group_Member__c
                                                            	WHERE id = :lstAVGM2[0].id] ; 
		 	prodRuleInstance.groupMembersByGroupId.put(attr_group_value.Id,LstAVGMA);
        	prodRuleInstance.groupMembersByGroupId.put(attr_group_value2.Id,LstAVGMA2);
	        ruleProcessor ruleProcessInstance=new ruleProcessor(prodRuleInstance,proposal_n, null);
	        list<string> fieldAPINames = new list<string> {'Product_Name__c','Geography__c','Quantity__c'};
	        ruleProcessInstance.processRules(fieldAPINames, 'Test Product')   ;         
		Test.stopTest();
	}
    
    
     @isTest 
    static void test_method_Three() {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
	    User manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
		insert manager;
	    User testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
	    testUser.ManagerId = manager.Id;
	    testUser.Discount_Threshold__c  = 10.0;
	    insert testuser;
		
		Apttus_Config2__ConfigSystemProperties__c sysProp = new Apttus_Config2__ConfigSystemProperties__c();
		sysProp.Name = 'System Properties';
		sysProp.Apttus_Config2__DefaultProductsPage__c = 'test123';
		sysProp.Apttus_Config2__ViewCartPage__c = 'testing234e4523';
		insert sysProp;

		Apttus_Proposal__Proposal__c proposal = null;
		acct = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TestAcct_28_07_15');
		insert acct;
		Contact con = TestDataSetupUtility.createTestContact(acct.Id, 'Test_Last', 'Test_First', 'test@test.com');
		insert con;
		Opportunity oppt = TestDataSetupUtility.createTestOpportunity('TestOppt_28_07_15', acct.Id);
		insert oppt;
		proposal = TestDataSetupUtility.createProposal('TEST_PROP_28_07_15', acct.Id, oppt.Id, 'test', false);
		insert proposal;

		Apttus_Config2__ProductConfiguration__c prodConfig = new Apttus_Config2__ProductConfiguration__c(Apttus_QPConfig__Proposald__c=proposal.Id,Apttus_Config2__AccountId__c=acct.Id);
		insert prodConfig;
		
///////////////////////////////////////////////////////////////////////////////////////////
        
        // create Product
        Product2 product = TestDataSetupUtility.createProduct('Test product1', false); 
	    product.Convert_From__c = true;
	    product.ProductCode = 'testcode';
	    insert product;

        // create Attribute_Value_Group__c
        Attribute_Value_Group__c attr_group_value = new Attribute_Value_Group__c();
        attr_group_value.Indexing_Key__c = 'Proposal:Contract_Duration__c = 1 Month';
        insert attr_group_value;
        
                Attribute_Value_Group__c attr_group_value2 = new Attribute_Value_Group__c();
        attr_group_value2.Indexing_Key__c = 'Monster Extended Rush Powered hide';
        insert attr_group_value2;

        List<Attribute_Value__c> lstAV = new List<Attribute_Value__c>();
        lstAV.add(TestDataSetupUtility.createAttributeValue('Posting_Locations__c', 'Proposal', 'Selling_Country__c', 1, false));
        lstAV.add(TestDataSetupUtility.createAttributeValue('Selling_Country__c', 'Proposal', 'Selling_Country__c', 4, false));
        lstAV.add(TestDataSetupUtility.createAttributeValue('Apttus_QPConfig__PriceListId__r.Name', 'Proposal', 'USD Price List', 1, false));
        insert lstAV;
		
        // create Attribute_Value_Group_Member__c
        List<Attribute_Value_Group_Member__c> lstAVGM = new List<Attribute_Value_Group_Member__c>();
        lstAVGM.add(new Attribute_Value_Group_Member__c(
	        Attribute_Value_Group__c = attr_group_value.Id,
	        Attribute_Value__c = lstAV[0].Id,                                   
        	Product_Code__c = product.ProductCode,
        	Attribute_Value_Name_Manual__c = 'AVNM'
        ));

        lstAVGM.add(new Attribute_Value_Group_Member__c(
        	Attribute_Value_Group__c = attr_group_value.Id,
	        Attribute_Value__c = lstAV[1].Id,
        	Product_Code__c = product.ProductCode,
        	Attribute_Value_Name_Manual__c = 'AVNM'
        ));

        lstAVGM.add(new Attribute_Value_Group_Member__c(
        	Attribute_Value_Group__c = attr_group_value.Id,
	        Attribute_Value__c = lstAV[2].Id,
	        Product_Code__c = product.ProductCode,
	        Attribute_Value_Name_Manual__c = 'AVNM'
	    ));

        insert lstAVGM;        
	    
         // create Attribute_Value_Group_Member__c
        List<Attribute_Value_Group_Member__c> lstAVGM2 = new List<Attribute_Value_Group_Member__c>();
        lstAVGM2.add(new Attribute_Value_Group_Member__c(
	        Attribute_Value_Group__c = attr_group_value2.Id,
	        Attribute_Value__c = lstAV[1].Id,                                   
        	Product_Code__c = product.ProductCode,
        	Attribute_Value_Name_Manual__c = 'AVNM'
        ));

        lstAVGM2.add(new Attribute_Value_Group_Member__c(
        	Attribute_Value_Group__c = attr_group_value2.Id,
	        Attribute_Value__c = lstAV[1].Id,
        	Product_Code__c = product.ProductCode,
        	Attribute_Value_Name_Manual__c = 'AVNM'
        ));

        lstAVGM2.add(new Attribute_Value_Group_Member__c(
        	Attribute_Value_Group__c = attr_group_value2.Id,
	        Attribute_Value__c = lstAV[2].Id,
	        Product_Code__c = product.ProductCode,
	        Attribute_Value_Name_Manual__c = 'AVNM'
	    ));

        insert lstAVGM2; 
	    // create Apttus_Config2__ClassificationName__c
	    Apttus_Config2__ClassificationName__c category = new Apttus_Config2__ClassificationName__c();
	    category.Name = 'Test Option Group 2';
	    category.Apttus_Config2__HierarchyLabel__c = 'Test Option Group 2';
	    insert category;
	    
	    // create Apttus_Config2__ClassificationHierarchy__c
	    Apttus_Config2__ClassificationHierarchy__c ch = new Apttus_Config2__ClassificationHierarchy__c();
	    ch.Name = 'new hierarchy';
	    ch.Apttus_Config2__Label__c = 'Test Option Group 2';
	    ch.Apttus_Config2__HierarchyId__c = category.Id;
	    insert ch;
	    
	    // create Apttus_Config2__ProductOptionGroup__c
	    Apttus_Config2__ProductOptionGroup__c pog = new Apttus_Config2__ProductOptionGroup__c();
	    pog.Apttus_Config2__Sequence__c = 1;
	    pog.Apttus_Config2__ProductId__c = product.Id;
	    pog.Apttus_Config2__OptionGroupId__c = ch.Id;
	    insert pog;
	    
	    // create Apttus_Config2__ProductOptionComponent__c
	    Apttus_Config2__ProductOptionComponent__c poc = new Apttus_Config2__ProductOptionComponent__c();
	    poc.Apttus_Config2__Sequence__c =1;
	    poc.Apttus_Config2__ProductOptionGroupId__c = pog.Id;
	    insert poc;
	    
	    // create product attribute rule definitions
        Product_Attribute_Rule_Definitions__c pard = new Product_Attribute_Rule_Definitions__c();
        pard.Controlling_Attribute_Value_Group__c = attr_group_value.Id;
        pard.Dependent_Attribute_Value_Group__c = attr_group_value2.Id;
        pard.active__c = true;
        pard.Primary_Product__c = product.Id;
        pard.Product_Option_Group__c = pog.Id;
        insert pard;
	    
	    account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        system.debug('after account ' + account);
        insert account;
	        
	        
        //create Opportunity
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', account.Id);
        opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'GCS Opportunity');
        insert opp;
        
        
        
        Product2 product1 = TestDataSetupUtility.createProduct('Test Product2', false);
        product.Convert_From__c = true;
        insert product1;
        
        //Create price list
        Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
        insert priceList; 
        
        Apttus_Config2__PriceListItem__c pli = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 10, Apttus_Config2__ProductId__c = product.Id, Apttus_Config2__ChargeType__c = 'Standard Price');
    	insert pli;
        
        //create proposal
        proposal_n = TestDataSetupUtility.createProposal('Test Proposal', account.Id, opp.Id, 'Accepted Online', false);
        proposal_n.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Apttus_Proposal__Proposal__c', 'Proposal');
        proposal_n.Apttus_QPConfig__PriceListId__c = priceList.id;        
        
        insert proposal_n;	
        
    
        Apttus_Config2__ProductConfiguration__c config = TestDataSetupUtility.createTestProductConfig(proposal_n,account,priceList);
        insert config;
        //System.debug('config:'+config);
	   
	    Apttus_Config2__LineItem__c aptusLineItem = TestDataSetupUtility.createLineItemApttus(config.Id);
        aptusLineItem.Apttus_Config2__StartDate__c=System.today();
        aptusLineItem.Apttus_Config2__EndDate__c=System.today()+60;
        aptusLineItem.Apttus_Config2__Comments__c='test';
        aptusLineItem.Apttus_Config2__ProductId__c = product.Id;
		aptusLineItem.Apttus_Config2__ProductOptionId__c = poc.Id ;
		aptusLineItem.Apttus_Config2__LineNumber__c = 1;
		//aptusLineItem.Apttus_Config2__OptionId__c = product.Id;
        insert aptusLineItem;
	   

//////////////////////////////////////////////////////////////////////////////////////////
		
		//ApexPages.currentPage().getParameters().put('configRequestId',getProductConfig().Id);
		ApexPages.currentPage().getParameters().put('id',prodConfig.Id);
		//Apttus_config2__lineItem__c lineItem = createLineItem();
		product = new Product2(Product_Line__c='TEST',Discount_Threshold__c=20.00,Name='Test Product');
		insert product;
		
		List<Apttus_config2__lineItem__c> lstLineItem = new List<Apttus_config2__lineItem__c>();
		
		Apttus_config2__lineItem__c lineItem = new Apttus_config2__lineItem__c(Apttus_Config2__ConfigurationId__c=prodConfig.Id,
		Attributes_Defaulted__c=false,
		Apttus_Config2__OptionId__c=product.Id,
		Apttus_Config2__PrimaryLineNumber__c=5,
		Apttus_Config2__LineNumber__c=6,
		Apttus_Config2__ItemSequence__c=7,
		Apttus_Config2__LineType__c='Option');
		lstLineItem.add(lineItem);
		Apttus_config2__lineItem__c lineItem1 = new Apttus_config2__lineItem__c(Apttus_Config2__ConfigurationId__c=prodConfig.Id,
		Attributes_Defaulted__c=false,
		Apttus_Config2__OptionId__c=product.Id,
		Apttus_Config2__PrimaryLineNumber__c=5,
		Apttus_Config2__LineNumber__c=6,
		Apttus_Config2__ItemSequence__c=7,
		Apttus_Config2__LineType__c='Product/Service');
		lstLineItem.add(lineItem1);
		insert lstLineItem;
		lineItem.Apttus_Config2__ProductId__c = product.Id;
		lineItem.Apttus_Config2__ProductOptionId__c = poc.Id ;
		lineItem.Apttus_Config2__OptionId__c = product.Id;
	
		lineItem.Apttus_Config2__LineNumber__c = 2;
		//insert lineItem;
		List<Id> listLineItemId = new List<Id>{lineItem.Apttus_Config2__OptionId__c, aptusLineItem.Apttus_Config2__OptionId__c};
		ruleProcessor.attributeValue test1 = new ruleProcessor.attributeValue(lstAVGM[0]);
        ruleProcessor.attributeValue test2 = new ruleProcessor.attributeValue(test1);
		Apttus_Config2__ProductAttributeGroup__c prodAttrGrp = new Apttus_Config2__ProductAttributeGroup__c();
		insert prodAttrGrp;
		
		Apttus_Config2__ProductAttributeGroupMember__c prodAttrGrpMember = new Apttus_Config2__ProductAttributeGroupMember__c(Apttus_Config2__AttributeGroupId__c=prodAttrGrp.Id,name='Tst Member',Apttus_Config2__Sequence__c=6);
		insert prodAttrGrpMember;
		
		Apttus_Config2__ProductAttribute__c prodAttr = new Apttus_Config2__ProductAttribute__c(Apttus_Config2__AttributeGroupId__c=prodAttrGrp.Id,Apttus_Config2__Field__c='test',Apttus_Config2__Sequence__c=6);
		List<Apttus_Config2__ProductAttribute__c> listProdAttr = new List<Apttus_Config2__ProductAttribute__c>{prodAttr};
		insert listProdAttr;
		pard = [select id, Controlling_Attribute_Value_Group__c,Dependent_Attribute_Value_Group__c from Product_Attribute_Rule_Definitions__c where id = :pard.Id AND Dependent_Attribute_Value_Group__c != NULL limit 1];
        Test.startTest();
	        //map<Id,productRuleHelper.productRuleInfo>  ruleHeapByProductId = productRuleHelper.QueryPardRulesByOptions(new list<Id>{lineItem.Apttus_Config2__OptionId__c},new set<Id>{pog.Id}); 
	        productRuleHelper.productRuleInfo prodRuleInstance= new productRuleHelper.productRuleInfo(); //ruleHeapByProductId.get(lineItem.Apttus_Config2__OptionId__c);
	        //prodRuleInstance.attValGrpByPardId
	        prodRuleInstance.attValGrpByPardId.put(pard.id,new list<Id>{pard.Controlling_Attribute_Value_Group__c,
		                                             pard.Dependent_Attribute_Value_Group__c});
        	System.debug('lstAV[1].Id'+lstAV[1]);  
        	System.debug('MS TEST lstAVGM'+lstAVGM[0].Attribute_Value__c);
        	System.debug('MS TEST lstAVGM'+lstAVGM[0].Attribute_Value__r.Attributes_Name__c);
        	System.debug('MS TEST lstAVGM'+lstAVGM[0].Attribute_Value__r.Attribute_Values__c);
        	System.debug('MS TEST lstAVGM'+lstAVGM[0].Attribute_Value__r.Attribute_Type__c);
        	List<Attribute_Value_Group_Member__c> LstAVGMA = [select Attribute_Value_Name__c,
                                                             Attribute_Record_Value__c,
                                                             Attribute_Value_Type__c,                                                             
                                                             attribute_Value_Group__c,
                                                             Attribute_Value__c,
                                                              Product_Code__c,
                                                                Attribute_Value_Name_Manual__c
                                                            		FROM Attribute_Value_Group_Member__c
                                                            	WHERE id = :lstAVGM[0].id] ;
        List<Attribute_Value_Group_Member__c> LstAVGMA2 = [select Attribute_Value_Name__c,
                                                             Attribute_Record_Value__c,
                                                             Attribute_Value_Type__c,                                                             
                                                             attribute_Value_Group__c,
                                                             Attribute_Value__c,
                                                              Product_Code__c,
                                                                Attribute_Value_Name_Manual__c
                                                            		FROM Attribute_Value_Group_Member__c
                                                            	WHERE id = :lstAVGM2[0].id] ; 
		 	prodRuleInstance.groupMembersByGroupId.put(attr_group_value.Id,LstAVGMA);
        	prodRuleInstance.groupMembersByGroupId.put(attr_group_value2.Id,LstAVGMA2);
	        ruleProcessor ruleProcessInstance=new ruleProcessor(prodRuleInstance,proposal_n, null);
	        list<string> fieldAPINames = new list<string> {'Product_Name__c','Geography__c','Quantity__c'};
	        ruleProcessInstance.processRules(fieldAPINames, 'Test Product')   ;      
        
		Test.stopTest();
	}
    
   
}