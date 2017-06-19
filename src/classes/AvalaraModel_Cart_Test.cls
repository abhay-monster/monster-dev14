@isTest
private class AvalaraModel_Cart_Test{
	static AvalaraSchema.RequestHeader reqHeader;
	static Apttus_Config2__ProductConfiguration__c aptusConfig;
	static Apttus_Config2__LineItem__c  aptusLineItem1,aptusLineItem2,aptusLineItem3;
	static List<Apttus_Config2__LineItem__c> aptusLineItemList;
	static{
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
}
	static testMethod void testAvalaraCardModel(){
		User sysAdmin;
		sysAdmin = TestDataSetupUtility.createUser('System Administrator', true);
		System.runAs(sysAdmin){
			createData();
			Test.startTest();
				 Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
				AvalaraModel_Cart model = new AvalaraModel_Cart(reqHeader);
				AvalaraModel_Cart.getQuoteTaxFromConfigbutton(aptusConfig.Id);
			Test.stopTest();
		}
	}

	static testMethod void testModelWithNegativeResoponse(){
		User sysAdmin;
		sysAdmin = TestDataSetupUtility.createUser('System Administrator', true);
		System.runAs(sysAdmin){
			createData();
			Test.startTest();
				Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());
				AvalaraModel_Cart model = new AvalaraModel_Cart(reqHeader);
				AvalaraModel_Cart.getQuoteTaxFromConfigbutton(aptusConfig.Id);
			Test.stopTest();
		}
	}

	static testMethod void testModelWithNegativeResoponse1(){
		User sysAdmin;
		sysAdmin = TestDataSetupUtility.createUser('System Administrator', true);
		System.runAs(sysAdmin){
			createData();
			Test.startTest();
				Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator2());
				AvalaraModel_Cart model = new AvalaraModel_Cart(reqHeader);
				AvalaraModel_Cart.getQuoteTaxFromConfigbutton(aptusConfig.Id);
			Test.stopTest();
		}
	}


	static testMethod void testExceptionBlock(){
		User sysAdmin;
		sysAdmin = TestDataSetupUtility.createUser('System Administrator', true);
		System.runAs(sysAdmin){
			createData();
			Test.startTest();
				
				AvalaraModel_Cart model = new AvalaraModel_Cart(reqHeader);
				AvalaraModel_Cart.getQuoteTaxFromConfigbutton(aptusConfig.Id);
			Test.stopTest();
		}
	}
	static void createData(){
		reqHeader = new AvalaraSchema.RequestHeader();
		reqHeader.Username = 'test@gmail.com';
    	reqHeader.Password = '1234';
    	reqHeader.Client = '123';
    	reqHeader.CompanyCode = '1234';   


    	/*Account acc  = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');

		insert acc;

		Opportunity opp = TestDataSetupUtility.createTestOpportunity('TestOpp' , acc.Id);

		insert opp;
		
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

		insert proposal;*/

		List<Account> accountList = new List<Account>();
        Account usedAccount = TestDataSetupUtility.createTestAccountWithShipping('Test Account');
        usedAccount.Phone = '20011111';
        accountList.add(usedAccount);
        insert accountList;
        
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opportunity', accountList[0].Id);
        oppList.add(opp);
        OpportunityTriggerHandler.PreventRecursion = true;
        insert oppList;

        List<Apttus_Proposal__Proposal__c> proList = new List<Apttus_Proposal__Proposal__c>();

        Apttus_Proposal__Proposal__c pro =  TestDataSetupUtility.createProposal('Test Proposal1', accountList[0].Id, oppList[0].Id, 'Accepted Online', false);

        proList.add(pro);
        insert proList;
		
		Apttus_Config2__PriceList__c aptusConfigPriceList = TestDataSetupUtility.createPriceList('TestPrice',true);
		
		List<Product2> productList = new List<Product2>();
		productList.add(TestDataSetupUtility.createProduct('Test Product' ,  false));
		productList.add(TestDataSetupUtility.createProduct('Test Product2' ,  false));
		productList.add(TestDataSetupUtility.createProduct('Test Product3' ,  false));
		productList.add(TestDataSetupUtility.createProduct('Test Product4' ,  false));
		productList[0].Apttus_Config2__ConfigurationType__c = 'Bundle';
		productList[1].Apttus_Config2__ConfigurationType__c = 'Bundle';
	    productList[2].Apttus_Config2__ConfigurationType__c = 'Bundle';
	    productList[3].Apttus_Config2__ConfigurationType__c = 'Standalone';
		insert productList;

        List<Apttus_Config2__PriceListItem__c> pliList=new list<Apttus_Config2__PriceListItem__c>();
		Apttus_Config2__PriceListItem__c pli_1=new Apttus_Config2__PriceListItem__c(Apttus_Config2__Active__c=true,Apttus_Config2__PriceListId__c=aptusConfigPriceList.Id,Apttus_Config2__ProductId__c=productList[0].Id);
		Apttus_Config2__PriceListItem__c pli_2=new Apttus_Config2__PriceListItem__c(Apttus_Config2__Active__c=true,Apttus_Config2__PriceListId__c=aptusConfigPriceList.Id,Apttus_Config2__ProductId__c=productList[1].Id);
		Apttus_Config2__PriceListItem__c pli_3=new Apttus_Config2__PriceListItem__c(Apttus_Config2__Active__c=true,Apttus_Config2__PriceListId__c=aptusConfigPriceList.Id,Apttus_Config2__ProductId__c=productList[2].Id);
        Apttus_Config2__PriceListItem__c pli_4=new Apttus_Config2__PriceListItem__c(Apttus_Config2__Active__c=true,Apttus_Config2__PriceListId__c=aptusConfigPriceList.Id,Apttus_Config2__ProductId__c=productList[3].Id);

		pliList.add(pli_1);
		pliList.add(pli_2);
		pliList.add(pli_3);
		pliList.add(pli_4);
		insert pliList;
		aptusConfig = TestDataSetupUtility.createTestProductConfig(proList[0] , accountList[0] , aptusConfigPriceList);
		aptusConfig.Apttus_Config2__Status__c = 'Finalized';
		insert aptusConfig;

		
		Apttus_Config2__ClassificationName__c categorySample=new Apttus_Config2__ClassificationName__c(Name='sample category',Apttus_Config2__HierarchyLabel__c='sample category',Apttus_Config2__Active__c = true,Apttus_Config2__Type__c='Option Group');
        insert categorySample;
        Apttus_Config2__ClassificationHierarchy__c catHierarchy=new Apttus_Config2__ClassificationHierarchy__c(Name = 'catHierarchyName', Apttus_Config2__Label__c = 'catHierarchyName',Apttus_Config2__HierarchyId__c = categorySample.Id);
        insert catHierarchy;
        Apttus_Config2__ProductOptionGroup__c optionGrp =new Apttus_Config2__ProductOptionGroup__c(Apttus_Config2__OptionGroupId__c = catHierarchy.Id,
        Apttus_Config2__ProductId__c =  productList[2].id, Apttus_Config2__Sequence__c = 1, Apttus_Config2__MinOptions__c = 1,Apttus_Config2__MaxOptions__c = 100);
        insert optionGrp;
        Apttus_Config2__ProductOptionComponent__c prodOptComponent=new Apttus_Config2__ProductOptionComponent__c(Apttus_Config2__ProductOptionGroupId__c = optionGrp.Id,Apttus_Config2__MinQuantity__c = 0,Apttus_Config2__MaxQuantity__c = 25,Apttus_Config2__RelationshipType__c = 'Option',  Apttus_Config2__Sequence__c = 1,Apttus_Config2__ComponentProductId__c =  productList[3].id);
		insert prodOptComponent;
		
		
		
		Apttus_Config2__ProductOptionGroup__c optionGrp1 =new Apttus_Config2__ProductOptionGroup__c(Apttus_Config2__OptionGroupId__c = catHierarchy.Id,
        Apttus_Config2__ProductId__c =  productList[1].id, Apttus_Config2__Sequence__c = 1, Apttus_Config2__MinOptions__c = 1,Apttus_Config2__MaxOptions__c = 100);
        insert optionGrp1;
        Apttus_Config2__ProductOptionComponent__c prodOptComponent1=new Apttus_Config2__ProductOptionComponent__c(Apttus_Config2__ProductOptionGroupId__c = optionGrp1.Id,Apttus_Config2__MinQuantity__c = 0,Apttus_Config2__MaxQuantity__c = 25,Apttus_Config2__RelationshipType__c = 'Option',  Apttus_Config2__Sequence__c = 1,Apttus_Config2__ComponentProductId__c =  productList[3].id);
		insert prodOptComponent1;
		
		
        Apttus_Config2__ProductOptionGroup__c optionGrp2 =new Apttus_Config2__ProductOptionGroup__c(Apttus_Config2__OptionGroupId__c = catHierarchy.Id,
        Apttus_Config2__ProductId__c =  productList[0].id, Apttus_Config2__Sequence__c = 1, Apttus_Config2__MinOptions__c = 1,Apttus_Config2__MaxOptions__c = 100);
        insert optionGrp2;
        Apttus_Config2__ProductOptionComponent__c prodOptComponent2=new Apttus_Config2__ProductOptionComponent__c(Apttus_Config2__ProductOptionGroupId__c = optionGrp1.Id,Apttus_Config2__MinQuantity__c = 0,Apttus_Config2__MaxQuantity__c = 25,Apttus_Config2__RelationshipType__c = 'Option',  Apttus_Config2__Sequence__c = 1,Apttus_Config2__ComponentProductId__c =  productList[1].id);
		insert prodOptComponent2;

		aptusLineItemList = new List<Apttus_Config2__LineItem__c>();
		aptusLineItem1= TestDataSetupUtility.createLineItemApttus(aptusConfig.Id);
		aptusLineItem1.Select__c = true;
		aptusLineItem1.Apttus_Config2__ProductId__c = productList[0].Id;
		aptusLineItem1.Apttus_Config2__StartDate__c = Date.today();
		aptusLineItem1.Apttus_Config2__EndDate__c = Date.today();
		aptusLineItem1.Apttus_Config2__IsPrimaryLine__c = true;
		aptusLineItem1.Apttus_Config2__LineType__c='Product/Service';
		aptusLineItem1.Apttus_Config2__HasOptions__c= true;
		aptusLineItem1.Apttus_Config2__LineNumber__c = 1;
		aptusLineItem1.Apttus_Config2__PriceListId__c=aptusConfigPriceList.Id;
		aptusLineItem1.Apttus_Config2__PriceListItemId__c=pliList[0].Id;
		aptusLineItem1.Apttus_Config2__ClassificationId__c=catHierarchy.Id;
		aptusLineItem1.Apttus_Config2__ProductOptionId__c=prodOptComponent2.Id;
		aptusLineItemList.add(aptusLineItem1);

		aptusLineItem2= TestDataSetupUtility.createLineItemApttus(aptusConfig.Id);
		aptusLineItem2.Select__c = true;
		aptusLineItem2.Apttus_Config2__ProductId__c = productList[1].Id;
		aptusLineItem2.Apttus_Config2__EndDate__c = Date.today();
		aptusLineItem2.Apttus_Config2__StartDate__c = Date.today();
		aptusLineItem2.Apttus_Config2__IsPrimaryLine__c = true;
		aptusLineItem2.Apttus_Config2__HasOptions__c= true;
		aptusLineItem2.Apttus_Config2__LineType__c='Product/Service';
		aptusLineItem2.Apttus_Config2__LineNumber__c = 2;
		aptusLineItem2.Apttus_Config2__PriceListId__c=aptusConfigPriceList.Id;
		aptusLineItem2.Apttus_Config2__PriceListItemId__c=pliList[1].Id;
		aptusLineItem2.Apttus_Config2__ClassificationId__c=catHierarchy.Id;
		aptusLineItem2.Apttus_Config2__ProductOptionId__c=prodOptComponent1.Id;
		aptusLineItemList.add(aptusLineItem2);

		aptusLineItem3= TestDataSetupUtility.createLineItemApttus(aptusConfig.Id);
		aptusLineItem3.Select__c = true;
		aptusLineItem3.Apttus_Config2__ProductId__c = productList[2].Id;
		aptusLineItem3.Apttus_Config2__StartDate__c = Date.today();
		aptusLineItem3.Apttus_Config2__IsPrimaryLine__c = true;
		aptusLineItem3.Apttus_Config2__StartDate__c = Date.today();
		aptusLineItem3.Apttus_Config2__LineNumber__c = 3;
		aptusLineItem3.Apttus_Config2__PriceListId__c=aptusConfigPriceList.Id;
		aptusLineItem3.Apttus_Config2__PriceListItemId__c=pliList[2].Id;
		aptusLineItem3.Apttus_Config2__ClassificationId__c=catHierarchy.Id;
		aptusLineItem3.Apttus_Config2__ProductOptionId__c=prodOptComponent.Id;
		aptusLineItem3.Apttus_Config2__LineType__c='Product/Service';
		aptusLineItem3.Apttus_Config2__HasOptions__c= true;
		aptusLineItemList.add(aptusLineItem3);
	
		insert aptusLineItemList;
		
	}


	public class MockHttpResponseGenerator implements HttpCalloutMock {
	    // Implement this interface method
	    public HTTPResponse respond(HTTPRequest req) {
	        
	        // Create a fake response
	        HttpResponse res = new HttpResponse();
	     
	        res = new HttpResponse(); 
	        res.setHeader('Content-type', 'application/json');
	        AvalaraSchema.GetTaxResponse response = new AvalaraSchema.GetTaxResponse();
	    	AvalaraSchema.Message msg = new AvalaraSchema.Message();
	    	msg.Name = 'Test';
            AvalaraSchema.TaxDetail taxDetail1 = new AvalaraSchema.TaxDetail();
            taxDetail1.Country = 'United States';
            taxDetail1.JurisCode = '12';
            taxDetail1.Rate = 1;
            AvalaraSchema.TaxDetail taxDetail2 = new AvalaraSchema.TaxDetail();
            taxDetail2.Country = 'India';
            taxDetail2.Rate = 2;
            taxDetail2.JurisType = AvalaraSchema.JURIS_TYPE_SPECIAL;
            taxDetail2.JurisCode = '12';
            List<Apttus_Config2__LineItem__c> lineItems = [SELECT Id,Name FROM Apttus_Config2__LineItem__c LIMIT 3];
            AvalaraSchema.TaxLine taxLine1 = new AvalaraSchema.TaxLine();
            taxLine1.LineNo = lineItems[0].Name;
            AvalaraSchema.TaxLine taxLine2 = new AvalaraSchema.TaxLine();
            taxLine2.LineNo = lineItems[1].Name;
            AvalaraSchema.TaxLine taxLine3 = new AvalaraSchema.TaxLine(); 
            taxLine3.LineNo = lineItems[2].Name;  
            AvalaraSchema.TaxAddress  taxAddress = new AvalaraSchema.TaxAddress();
            taxAddress.AddressCode = 'Shipping';   
	    	response.Messages = new List<AvalaraSchema.Message>{msg};
            response.TaxSummary = new List<AvalaraSchema.TaxDetail>{taxDetail1,taxDetail2};
            response.TaxLines = new List<AvalaraSchema.TaxLine>{taxLine1,taxLine2,taxLine3};
            response.TaxAddresses = new List<AvalaraSchema.TaxAddress>{taxAddress};
	        res.setBody(JSON.serialize(response));     
	        
	        res.setStatusCode(200);
	        return res;
	    }
	}   
    

    public class MockHttpResponseGenerator1 implements HttpCalloutMock {
	    // Implement this interface method
	    public HTTPResponse respond(HTTPRequest req) {
	        
	        // Create a fake response
	        HttpResponse res = new HttpResponse();
	     
	        res.setHeader('Content-type', 'application/json');
	        String responseString = '{"Test":{"status":"success"}}';
	        res.setBody(responseString);     
	        
	        res.setStatusCode(404);
	        return res;
	    }
	}   
    
    public class MockHttpResponseGenerator2 implements HttpCalloutMock {
	    // Implement this interface method
	    public HTTPResponse respond(HTTPRequest req) {
	        
	        // Create a fake response
	        HttpResponse res = new HttpResponse();
	     
	        res.setHeader('Content-type', 'application/json');
	        
	        String responseString = '{"Test":{"status":"success"}}';
	        res.setBody(responseString);     
	        
	        res.setStatusCode(500);
	        return res;
	    }
	}  
}