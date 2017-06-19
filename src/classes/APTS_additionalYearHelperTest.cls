@isTest
public class APTS_additionalYearHelperTest {


   private static testMethod void  testControllerBundle(){
    Account acc  = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');

		insert acc;

		Opportunity opp = TestDataSetupUtility.createTestOpportunity('TestOpp' , acc.Id);

		insert opp;

		Apttus_Proposal__Proposal__c proposal = TestDataSetupUtility.createProposal(opp.Id);

		insert proposal;
		
		List<Product2> productList = new List<Product2>();
		productList.add(TestDataSetupUtility.createProduct('Test Product' ,  false));
		productList.add(TestDataSetupUtility.createProduct('Test Product2' ,  false));
		productList.add(TestDataSetupUtility.createProduct('Test Product3' ,  false));
		productList[0].Apttus_Config2__ConfigurationType__c = 'Bundle';
		productList[1].Apttus_Config2__ConfigurationType__c = 'Bundle';
	    productList[2].Apttus_Config2__ConfigurationType__c = 'Bundle';
		insert productList;
		
		Apttus_Config2__PriceList__c aptusConfigPriceList = TestDataSetupUtility.createPriceList('TestPrice',true);
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
		aptusLineItemList.add(TestDataSetupUtility.createLineItemApttus(aptusConfig.Id));
		aptusLineItemList[1].Select__c = true;
		aptusLineItemList[1].Apttus_Config2__ProductId__c = productList[1].Id;
		aptusLineItemList[1].Apttus_Config2__EndDate__c = Date.today();
		aptusLineItemList[1].Apttus_Config2__StartDate__c = Date.today();
		aptusLineItemList[1].Apttus_Config2__IsPrimaryLine__c = true;
		aptusLineItemList[1].Apttus_Config2__HasOptions__c= true;
		aptusLineItemList[1].Apttus_Config2__LineType__c='Product/Service';
		aptusLineItemList[1].Apttus_Config2__LineNumber__c = 2;
		aptusLineItemList.add(TestDataSetupUtility.createLineItemApttus(aptusConfig.Id));
		aptusLineItemList[2].Select__c = true;
		aptusLineItemList[2].Apttus_Config2__ProductId__c = productList[2].Id;
		aptusLineItemList[2].Apttus_Config2__StartDate__c = Date.today();
		aptusLineItemList[2].Apttus_Config2__IsPrimaryLine__c = true;
		aptusLineItemList[2].Apttus_Config2__StartDate__c = Date.today();
		aptusLineItemList[2].Apttus_Config2__LineNumber__c = 3;
		aptusLineItemList[2].Apttus_Config2__LineType__c='Product/Service';
		aptusLineItemList[2].Apttus_Config2__HasOptions__c= true;
		
		Apttus_Config2__ClassificationName__c categorySample=new Apttus_Config2__ClassificationName__c(Name='sample category',Apttus_Config2__HierarchyLabel__c='sample category',Apttus_Config2__Active__c = true,Apttus_Config2__Type__c='Option Group');
        insert categorySample;
        Apttus_Config2__ClassificationHierarchy__c catHierarchy=new Apttus_Config2__ClassificationHierarchy__c(Name = 'catHierarchyName', Apttus_Config2__Label__c = 'catHierarchyName',Apttus_Config2__HierarchyId__c = categorySample.Id);
        insert catHierarchy;
        Apttus_Config2__ProductOptionGroup__c optionGrp =new Apttus_Config2__ProductOptionGroup__c(Apttus_Config2__OptionGroupId__c = catHierarchy.Id,
        Apttus_Config2__ProductId__c =  productList[2].id, Apttus_Config2__Sequence__c = 1, Apttus_Config2__MinOptions__c = 1,Apttus_Config2__MaxOptions__c = 100);
        insert optionGrp;
        Apttus_Config2__ProductOptionComponent__c prodOptComponent1=new Apttus_Config2__ProductOptionComponent__c(Apttus_Config2__ProductOptionGroupId__c = optionGrp.Id,Apttus_Config2__MinQuantity__c = 0,Apttus_Config2__MaxQuantity__c = 25,Apttus_Config2__RelationshipType__c = 'Option',  Apttus_Config2__Sequence__c = 1,Apttus_Config2__ComponentProductId__c =  productList[2].id);
		
		insert aptusLineItemList;
		 
		 
		List<Apttus_Config2__ProductAttributeValue__c> pavList = NEW List<Apttus_Config2__ProductAttributeValue__c>(); 
		pavList.add( new Apttus_Config2__ProductAttributeValue__c(
        	Apttus_Config2__LineItemId__c = aptusLineItemList[0].Id,Posting_Locations__c = 'India'));
        
        pavList.add( new Apttus_Config2__ProductAttributeValue__c(
        	Apttus_Config2__LineItemId__c = aptusLineItemList[1].Id,Posting_Locations__c = 'United States'));
        	
        pavList.add( new Apttus_Config2__ProductAttributeValue__c(
        	Apttus_Config2__LineItemId__c = aptusLineItemList[2].Id,Posting_Locations__c = 'United States'));
        
        insert pavList;
		Test.startTest();
		Apexpages.currentpage().getparameters().put('id',aptusConfig.Id);
		APTS_additionalYearHelper  ctrl = new APTS_additionalYearHelper(aptusConfig.Id);
		//ctrl.URLQueryParameters();
		try{
			Boolean result=ctrl.GenerateAdditionalYearsForSelectedLineItem(aptusLineItemList[0].Id,3,aptusConfig.Id);
			Boolean result1=ctrl.GenerateAdditionalYearsForSelectedLineItem(aptusLineItemList[1].Id,3,aptusConfig.Id);
			Boolean result2=ctrl.GenerateAdditionalYearsForSelectedLineItem(aptusLineItemList[2].Id,3,aptusConfig.Id);
		}catch(Exception e){} 
		Test.stopTest();
	}
	
	private static testMethod void  testControllerStandalone(){
		Account acc  = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');

		insert acc;

		Opportunity opp = TestDataSetupUtility.createTestOpportunity('TestOpp' , acc.Id);

		insert opp;

		Apttus_Proposal__Proposal__c proposal = TestDataSetupUtility.createProposal(opp.Id);

		insert proposal;
		
		List<Product2> productList = new List<Product2>();
		productList.add(TestDataSetupUtility.createProduct('Test Product' ,  false));
		productList.add(TestDataSetupUtility.createProduct('Test Product2' ,  false));
		productList.add(TestDataSetupUtility.createProduct('Test Product3' ,  false));
	   productList.add(TestDataSetupUtility.createProduct('Test Product4' ,  false));
		productList[0].Apttus_Config2__ConfigurationType__c = 'Standalone';
		productList[1].Apttus_Config2__ConfigurationType__c = 'Standalone';
		productList[2].Apttus_Config2__ConfigurationType__c = 'Standalone';
		productList[3].Apttus_Config2__ConfigurationType__c = 'Standalone';
		insert productList;
		
		Apttus_Config2__PriceList__c aptusConfigPriceList = TestDataSetupUtility.createPriceList('TestPrice',true);
		Apttus_Config2__ProductConfiguration__c aptusConfig = TestDataSetupUtility.createTestProductConfig(proposal , acc , aptusConfigPriceList);
		aptusConfig.Apttus_Config2__Status__c = 'Finalized';
		insert aptusConfig;
		
		
		
		List<Apttus_Config2__LineItem__c> aptusLineItemList = new List<Apttus_Config2__LineItem__c>();
		aptusLineItemList.add(TestDataSetupUtility.createLineItemApttus(aptusConfig.Id));
		aptusLineItemList[0].Select__c = true;
		aptusLineItemList[0].Apttus_Config2__ProductId__c = productList[0].Id;
		aptusLineItemList[0].Apttus_Config2__StartDate__c = Date.today();
		aptusLineItemList[0].Apttus_Config2__IsPrimaryLine__c = true;
		aptusLineItemList[0].Apttus_Config2__LineNumber__c = 1;
		
		aptusLineItemList.add(TestDataSetupUtility.createLineItemApttus(aptusConfig.Id));
		aptusLineItemList[1].Select__c = true;
		aptusLineItemList[1].Apttus_Config2__ProductId__c = productList[1].Id;
		aptusLineItemList[1].Apttus_Config2__StartDate__c = Date.today();
		aptusLineItemList[1].Apttus_Config2__IsPrimaryLine__c = true;
		aptusLineItemList[1].Apttus_Config2__LineNumber__c = 2;
	
		aptusLineItemList.add(TestDataSetupUtility.createLineItemApttus(aptusConfig.Id));
		aptusLineItemList[2].Select__c = true;
		aptusLineItemList[2].Apttus_Config2__ProductId__c = productList[2].Id;
		aptusLineItemList[2].Apttus_Config2__StartDate__c = Date.today();
		aptusLineItemList[2].Apttus_Config2__IsPrimaryLine__c = true;
		aptusLineItemList[2].Apttus_Config2__LineNumber__c = 3;
	
		aptusLineItemList.add(TestDataSetupUtility.createLineItemApttus(aptusConfig.Id));
		aptusLineItemList[3].Select__c = true;
		aptusLineItemList[3].Apttus_Config2__ProductId__c = productList[3].Id;
		aptusLineItemList[3].Apttus_Config2__StartDate__c = Date.today();
		aptusLineItemList[3].Apttus_Config2__IsPrimaryLine__c = true;
		aptusLineItemList[3].Apttus_Config2__LineNumber__c = 4;
	
		
		
		insert aptusLineItemList;
		 
		List<Apttus_Config2__ProductAttributeValue__c> pavList = NEW List<Apttus_Config2__ProductAttributeValue__c>(); 
		pavList.add( new Apttus_Config2__ProductAttributeValue__c(
        	Apttus_Config2__LineItemId__c = aptusLineItemList[0].Id,Posting_Locations__c = 'India',Contract_Duration__c='10 Month'));
        
        pavList.add( new Apttus_Config2__ProductAttributeValue__c(
        	Apttus_Config2__LineItemId__c = aptusLineItemList[1].Id,Posting_Locations__c = 'United States',Contract_Duration__c='10 Day'));
        	
        pavList.add( new Apttus_Config2__ProductAttributeValue__c(
        	Apttus_Config2__LineItemId__c = aptusLineItemList[2].Id,Posting_Locations__c = 'United States',Contract_Duration__c='10 Year'));
        	
        pavList.add( new Apttus_Config2__ProductAttributeValue__c(
        	Apttus_Config2__LineItemId__c = aptusLineItemList[3].Id,Posting_Locations__c = 'United States',Contract_Duration__c='10 week'));
        
        insert pavList;
		Test.startTest();
		Apexpages.currentpage().getparameters().put('id',aptusConfig.Id);
		APTS_additionalYearHelper  ctrl = new APTS_additionalYearHelper(aptusConfig.Id);
		//ctrl.URLQueryParameters(); 
		try{
			Boolean result=ctrl.GenerateAdditionalYearsForSelectedLineItem(aptusLineItemList[0].Id,3,aptusConfig.Id);
		    Boolean result1=ctrl.GenerateAdditionalYearsForSelectedLineItem(aptusLineItemList[1].Id,3,aptusConfig.Id);
			Boolean result2=ctrl.GenerateAdditionalYearsForSelectedLineItem(aptusLineItemList[2].Id,3,aptusConfig.Id);
			Boolean result3=ctrl.GenerateAdditionalYearsForSelectedLineItem(aptusLineItemList[3].Id,3,aptusConfig.Id);
		}catch(Exception e){}
		Test.stopTest();
       
	}
}