@isTest
public with sharing class GoToPricingCustomController_Test {
	
	static Account acct = null;
	static Apttus_Config2__ProductConfiguration__c prodConfig = null;
	
	static testMethod void testGoToPricingCustomController(){
		Test.startTest();
		
		createCustomSetting();
		
		prodConfig = getProductConfig();
		//ApexPages.currentPage().getParameters().put('configRequestId',getProductConfig().Id);
		ApexPages.currentPage().getParameters().put('id',prodConfig.Id);
		Apttus_config2__lineItem__c lineItem = createLineItem();
		List<Id> listLineItemId = new List<Id>{lineItem.Apttus_Config2__OptionId__c};
		GoToPricingCustomController controller = new GoToPricingCustomController();
		System.assert(controller != null);
		list<Apttus_config2__lineItem__c> listLineItems = controller.getLineItems();
		System.assert(listLineItems != null);
		PageReference pr = controller.doCancel();
		System.assert(pr != null);
		controller.processLines();
		//controller.getProductAttributeValue();

		Apttus_Config2__ProductAttributeGroup__c prodAttrGrp = new Apttus_Config2__ProductAttributeGroup__c();
		insert prodAttrGrp;
		
		Apttus_Config2__ProductAttributeGroupMember__c prodAttrGrpMember = new Apttus_Config2__ProductAttributeGroupMember__c(Apttus_Config2__AttributeGroupId__c=prodAttrGrp.Id,name='Tst Member',Apttus_Config2__Sequence__c=6);
		insert prodAttrGrpMember;
		
		Apttus_Config2__ProductAttribute__c prodAttr = new Apttus_Config2__ProductAttribute__c(Apttus_Config2__AttributeGroupId__c=prodAttrGrp.Id,Apttus_Config2__Field__c='test',Apttus_Config2__Sequence__c=6);
		List<Apttus_Config2__ProductAttribute__c> listProdAttr = new List<Apttus_Config2__ProductAttribute__c>{prodAttr};
		insert listProdAttr;
		GoToPricingCustomController.getAttributeFieldList(listProdAttr);
		
		try {
			GoToPricingCustomController.getFieldsByProductId(listLineItemId);
		} Catch(Exception e) {}
		
		Test.stopTest();
	}
	
	private static void createCustomSetting(){
		Apttus_Config2__ConfigSystemProperties__c sysProp = new Apttus_Config2__ConfigSystemProperties__c();
		sysProp.Name = 'System Properties';
		sysProp.Apttus_Config2__DefaultProductsPage__c = 'test123';
		sysProp.Apttus_Config2__ViewCartPage__c = 'testing234e4523';
		insert sysProp;
	}
	
	private static Apttus_Config2__ProductConfiguration__c getProductConfig(){
		Apttus_Proposal__Proposal__c proposal = getProposal();
		prodConfig = new Apttus_Config2__ProductConfiguration__c(Apttus_QPConfig__Proposald__c=proposal.Id,Apttus_Config2__AccountId__c=acct.Id);
		insert prodConfig;
		return prodConfig;
	}
	
	private static Apttus_config2__lineItem__c createLineItem(){
		Product2 product = new Product2(Product_Line__c='TEST',Discount_Threshold__c=20.00,Name='Test Product');
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
		return lstLineItem[0];
	}
	
	private static Apttus_Proposal__Proposal__c getProposal(){
		Apttus_Proposal__Proposal__c proposal = null;
		acct = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TestAcct_28_07_15');
		insert acct;
		Contact con = TestDataSetupUtility.createTestContact(acct.Id, 'Test_Last', 'Test_First', 'test@test.com');
		insert con;
		Opportunity oppt = TestDataSetupUtility.createTestOpportunity('TestOppt_28_07_15', acct.Id);
		insert oppt;
		proposal = TestDataSetupUtility.createProposal('TEST_PROP_28_07_15', acct.Id, oppt.Id, 'test', false);
		insert proposal;
	return proposal;
}
    
}