@isTest
private class APTS_ReadOnlyAttribute_Test {

	private static testMethod void testReadOnlyAttribute() {
                   
        Account acc  = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        insert acc;

		Opportunity opp = TestDataSetupUtility.createTestOpportunity('TestOpp' , acc.Id);
        insert opp;
		
		Apttus_Config2__PriceList__c aptusConfigPriceList = TestDataSetupUtility.createPriceList('TestPrice',true);
		
        Account billingAcc  = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Billing Account');
		insert billingAcc;
       
		Apttus_Proposal__Proposal__c proposal = TestDataSetupUtility.createProposal(opp.Id);
		Contact c=TestDataSetupUtility.createTestContact(billingAcc.Id,'test1','test1', 'sample1@gmail.com');
		insert c;
		Contact c1=TestDataSetupUtility.createTestContact(acc.Id,'test2','test2', 'sample2@gmail.com');
		insert c1;
		proposal.Apttus_QPConfig__PriceListId__c=aptusConfigPriceList.Id;
		proposal.BillingAccount__c = billingAcc.Id;
		proposal.BillContact__c = c.Id;
		proposal.Apttus_Proposal__Account__c=acc.Id;
		proposal.PostingContact__c = c1.Id;

		insert proposal;
		
		List<Product2> productList = new List<Product2>();
		productList.add(TestDataSetupUtility.createProduct('Test Product' ,  false));
		productList.add(TestDataSetupUtility.createProduct('Test Product2' ,  false));
        insert productList;
        
        List<Apttus_Config2__PriceListItem__c> pliList=new list<Apttus_Config2__PriceListItem__c>();
		Apttus_Config2__PriceListItem__c pli_1=new Apttus_Config2__PriceListItem__c(Apttus_Config2__Active__c=true,Apttus_Config2__PriceListId__c=aptusConfigPriceList.Id,Apttus_Config2__ProductId__c=productList[0].Id);
		Apttus_Config2__PriceListItem__c pli_2=new Apttus_Config2__PriceListItem__c(Apttus_Config2__Active__c=true,Apttus_Config2__PriceListId__c=aptusConfigPriceList.Id,Apttus_Config2__ProductId__c=productList[1].Id);	
	    pliList.add(pli_1);
		pliList.add(pli_2);
		insert pliList;
		
		Apttus_Config2__ProductConfiguration__c aptusConfig = TestDataSetupUtility.createTestProductConfig(proposal , acc , aptusConfigPriceList);
		aptusConfig.Apttus_Config2__Status__c = 'Finalized';
		insert aptusConfig;
		
		
		List<Apttus_Config2__LineItem__c> aptusLineItemList = new List<Apttus_Config2__LineItem__c>();
		aptusLineItemList.add(TestDataSetupUtility.createLineItemApttus(aptusConfig.Id));
		aptusLineItemList[0].Select__c = true;
		aptusLineItemList[0].Apttus_Config2__ProductId__c = productList[0].Id;
		aptusLineItemList[0].Apttus_Config2__StartDate__c = Date.today();
		aptusLineItemList[0].Apttus_Config2__EndDate__c = Date.today();
		aptusLineItemList[0].Apttus_Config2__IsPrimaryLine__c = true;
		aptusLineItemList[0].Apttus_Config2__LineType__c='Product/Service';
		aptusLineItemList[0].Apttus_Config2__HasOptions__c= false;
		aptusLineItemList[0].Apttus_Config2__LineNumber__c = 1;
		aptusLineItemList[0].Apttus_Config2__PriceListId__c=aptusConfigPriceList.Id;
		aptusLineItemList[0].Apttus_Config2__PriceListItemId__c=pliList[0].Id;
	
		insert aptusLineItemList;
		
		string sUrl  = '/apex/ProductAttributeReadOnly?id='+aptusLineItemList[0].Id;
        PageReference pg = new PageReference(surl);
        Test.setCurrentPage(pg);
		
		Test.startTest();
		
		APTS_ReadOnlyAttribute rdOnlyAttribute=new APTS_ReadOnlyAttribute();
		PageReference pg1=rdOnlyAttribute.Redirect();
		
		Test.stopTest();
		
		
	}
    
    private static testMethod void testReadOnlyAttribute2() {
                   
        Account acc  = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        insert acc;

		Opportunity opp = TestDataSetupUtility.createTestOpportunity('TestOpp' , acc.Id);
        insert opp;
		
		Apttus_Config2__PriceList__c aptusConfigPriceList = TestDataSetupUtility.createPriceList('TestPrice',true);
		
        Account billingAcc  = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Billing Account');
		insert billingAcc;
       
		Apttus_Proposal__Proposal__c proposal = TestDataSetupUtility.createProposal(opp.Id);
		Contact c=TestDataSetupUtility.createTestContact(billingAcc.Id,'test1','test1', 'sample1@gmail.com');
		insert c;
		Contact c1=TestDataSetupUtility.createTestContact(acc.Id,'test2','test2', 'sample2@gmail.com');
		insert c1;
		proposal.Apttus_QPConfig__PriceListId__c=aptusConfigPriceList.Id;
		proposal.BillingAccount__c = billingAcc.Id;
		proposal.BillContact__c = c.Id;
		proposal.Apttus_Proposal__Account__c=acc.Id;
		proposal.PostingContact__c = c1.Id;

		insert proposal;
		
		List<Product2> productList = new List<Product2>();
		productList.add(TestDataSetupUtility.createProduct('Test Product' ,  false));
		productList.add(TestDataSetupUtility.createProduct('Test Product2' ,  false));
        insert productList;
        
        List<Apttus_Config2__PriceListItem__c> pliList=new list<Apttus_Config2__PriceListItem__c>();
		Apttus_Config2__PriceListItem__c pli_1=new Apttus_Config2__PriceListItem__c(Apttus_Config2__Active__c=true,Apttus_Config2__PriceListId__c=aptusConfigPriceList.Id,Apttus_Config2__ProductId__c=productList[0].Id);
		Apttus_Config2__PriceListItem__c pli_2=new Apttus_Config2__PriceListItem__c(Apttus_Config2__Active__c=true,Apttus_Config2__PriceListId__c=aptusConfigPriceList.Id,Apttus_Config2__ProductId__c=productList[1].Id);	
	    pliList.add(pli_1);
		pliList.add(pli_2);
		insert pliList;
		
		Apttus_Config2__ProductConfiguration__c aptusConfig = TestDataSetupUtility.createTestProductConfig(proposal , acc , aptusConfigPriceList);
		aptusConfig.Apttus_Config2__Status__c = 'Finalized';
		insert aptusConfig;
		
		
		List<Apttus_Config2__LineItem__c> aptusLineItemList = new List<Apttus_Config2__LineItem__c>();
		aptusLineItemList.add(TestDataSetupUtility.createLineItemApttus(aptusConfig.Id));
		aptusLineItemList[0].Select__c = true;
		aptusLineItemList[0].Apttus_Config2__ProductId__c = productList[0].Id;
		aptusLineItemList[0].Apttus_Config2__StartDate__c = Date.today();
		aptusLineItemList[0].Apttus_Config2__EndDate__c = Date.today();
		aptusLineItemList[0].Apttus_Config2__IsPrimaryLine__c = true;
		aptusLineItemList[0].Apttus_Config2__LineType__c='Product/Service';
		aptusLineItemList[0].Apttus_Config2__HasOptions__c= true;
		aptusLineItemList[0].Apttus_Config2__LineNumber__c = 1;
		aptusLineItemList[0].Apttus_Config2__PriceListId__c=aptusConfigPriceList.Id;
		aptusLineItemList[0].Apttus_Config2__PriceListItemId__c=pliList[0].Id;
	
		insert aptusLineItemList;
        
        
        Apttus_Config2__TempObject__c tempObject  = new Apttus_Config2__TempObject__c();
        tempObject.Apttus_Config2__ConfigurationId__c = aptusConfig.id;
        insert tempObject;
		
		string sUrl  = '/apex/ProductAttributeReadOnly?id='+aptusLineItemList[0].Id;
        PageReference pg = new PageReference(surl);
        Test.setCurrentPage(pg);
		
		Test.startTest();
		
		APTS_ReadOnlyAttribute rdOnlyAttribute=new APTS_ReadOnlyAttribute();
		PageReference pg1=rdOnlyAttribute.Redirect();
		
		Test.stopTest();
		
		
	}
    
    private static testMethod void testReadOnlyAttribut3() {
                   
        Account acc  = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        insert acc;

		Opportunity opp = TestDataSetupUtility.createTestOpportunity('TestOpp' , acc.Id);
        insert opp;
		
		Apttus_Config2__PriceList__c aptusConfigPriceList = TestDataSetupUtility.createPriceList('TestPrice',true);
		
        Account billingAcc  = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Billing Account');
		insert billingAcc;
       
		Apttus_Proposal__Proposal__c proposal = TestDataSetupUtility.createProposal(opp.Id);
		Contact c=TestDataSetupUtility.createTestContact(billingAcc.Id,'test1','test1', 'sample1@gmail.com');
		insert c;
		Contact c1=TestDataSetupUtility.createTestContact(acc.Id,'test2','test2', 'sample2@gmail.com');
		insert c1;
		proposal.Apttus_QPConfig__PriceListId__c=aptusConfigPriceList.Id;
		proposal.BillingAccount__c = billingAcc.Id;
		proposal.BillContact__c = c.Id;
		proposal.Apttus_Proposal__Account__c=acc.Id;
		proposal.PostingContact__c = c1.Id;

		insert proposal;
		
		List<Product2> productList = new List<Product2>();
		productList.add(TestDataSetupUtility.createProduct('Test Product' ,  false));
		productList.add(TestDataSetupUtility.createProduct('Test Product2' ,  false));
        insert productList;
        
        List<Apttus_Config2__PriceListItem__c> pliList=new list<Apttus_Config2__PriceListItem__c>();
		Apttus_Config2__PriceListItem__c pli_1=new Apttus_Config2__PriceListItem__c(Apttus_Config2__Active__c=true,Apttus_Config2__PriceListId__c=aptusConfigPriceList.Id,Apttus_Config2__ProductId__c=productList[0].Id);
		Apttus_Config2__PriceListItem__c pli_2=new Apttus_Config2__PriceListItem__c(Apttus_Config2__Active__c=true,Apttus_Config2__PriceListId__c=aptusConfigPriceList.Id,Apttus_Config2__ProductId__c=productList[1].Id);	
	    pliList.add(pli_1);
		pliList.add(pli_2);
		insert pliList;
		
		Apttus_Config2__ProductConfiguration__c aptusConfig = TestDataSetupUtility.createTestProductConfig(proposal , acc , aptusConfigPriceList);
		aptusConfig.Apttus_Config2__Status__c = 'Finalized';
		insert aptusConfig;
		
		
		List<Apttus_Config2__LineItem__c> aptusLineItemList = new List<Apttus_Config2__LineItem__c>();
		aptusLineItemList.add(TestDataSetupUtility.createLineItemApttus(aptusConfig.Id));
		aptusLineItemList[0].Select__c = true;
		aptusLineItemList[0].Apttus_Config2__ProductId__c = productList[0].Id;
		aptusLineItemList[0].Apttus_Config2__StartDate__c = Date.today();
		aptusLineItemList[0].Apttus_Config2__EndDate__c = Date.today();
		aptusLineItemList[0].Apttus_Config2__IsPrimaryLine__c = true;
		aptusLineItemList[0].Apttus_Config2__LineType__c='Product/Service';
		aptusLineItemList[0].Apttus_Config2__HasOptions__c= true;
		aptusLineItemList[0].Apttus_Config2__LineNumber__c = 1;
		aptusLineItemList[0].Apttus_Config2__PriceListId__c=aptusConfigPriceList.Id;
		aptusLineItemList[0].Apttus_Config2__PriceListItemId__c=pliList[0].Id;
	
		insert aptusLineItemList;
        		
		string sUrl  = '/apex/ProductAttributeReadOnly?id='+aptusLineItemList[0].Id;
        PageReference pg = new PageReference(surl);
        Test.setCurrentPage(pg);
		
		Test.startTest();
		
		APTS_ReadOnlyAttribute rdOnlyAttribute=new APTS_ReadOnlyAttribute();
		PageReference pg1=rdOnlyAttribute.Redirect();
		
		Test.stopTest();
		
		
	}

}