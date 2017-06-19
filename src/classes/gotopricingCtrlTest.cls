@isTest
public with sharing class gotopricingCtrlTest {
  
  @isTest
  static void testGotoPricingController()
  { 
    Account account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
    insert account;
    Opportunity opp = new Opportunity(Name = 'Apttus Test Opty', 
                                      AccountId = account.Id, StageName='Stage 2 - Qualify Target', 
                                      //Competitors__c = '**None**', 
                                      CloseDate = Date.today().addYears(1),
                                      pricebook2Id=test.getStandardPricebookId());
    opp.AccountId = account.Id;
    opp.CloseDate = Date.today();        
    insert opp;
    
    
    opp = [Select id,StageName from Opportunity where id =:opp.id];
    
    
  // STEP I - Create a product 
    Product2 bundle_product = TestDataSetupUtility.createProduct('BundleProduct1',
                                       'BundleProduct1',
                                       'TEST Apttus',
                                       'TestApttus',
                                       'Bundle',
                                       'Each',
                                       true,
                                       Date.today(), 
                                       Date.today().addMonths(12),
                                       true);
                                       
   
     Product2 Option_product = TestDataSetupUtility.createProduct('OptionProduct1',
                                        'OptionProduct1',
                                        'TestApttus3',
                                        'TestApttus3',
                                        'Option',
                                        'Each',
                                        true,
                                        Date.today(), 
                                        Date.today().addMonths(12),
                                        true);
    
    Product2 standalone_product = TestDataSetupUtility.createProduct('StandAlone1',
                                        'StandAlone1',
                                        'TestApttus2',
                                        'TestApttus2',
                                        'Standalone',
                                        'Each',
                                        true,
                                        Date.today(), 
                                        Date.today().addMonths(12),
                                        true);
                                        
                                         
    
     // STEP II - Create a new price list
    Apttus_Config2__PriceList__c priceListSO = TestDataSetupUtility.createPriceList('USD Price List', 
                                                               'Price list for Apttus',
                                                               Date.today(), 
                                                               Date.today().addMonths(12),
                                                               true);   
    
    // STEP III - Create price list items
    Apttus_Config2__PriceListItem__c plItem_bundle = TestDataSetupUtility.createPriceListItem(priceListSO.Id,
                                                                    bundle_product.Id,
                                                                    'Subscription Fee', 
                                                                    'Recurring',
                                                                    'Per Unit',
                                                                    9485,
                                                                    9000,
                                                                    10000,
                                                                    'Unit Price',
                                                                    Date.today(), 
                                                                    Date.today().addMonths(12),
                                                                    true, true);
                                                                    
    
    Apttus_Config2__PriceListItem__c plItem_Option = TestDataSetupUtility.createPriceListItem(priceListSO.Id,
                                                                     Option_product.Id,
                                                                    'Subscription Fee', 
                                                                    'Recurring',
                                                                    'Per Unit',
                                                                    1685,
                                                                    1500,
                                                                    1800,
                                                                    'Unit Price',
                                                                    Date.today(), 
                                                                    Date.today().addMonths(12),
                                                                    true, true);
                                                                   
    Apttus_Config2__PriceListItem__c plItem_standalone = TestDataSetupUtility.createPriceListItem(priceListSO.Id,
                                                                     standalone_product.Id,
                                                                    'Subscription Fee', 
                                                                    'Recurring',
                                                                    'Per Unit',
                                                                    1685,
                                                                    1500,
                                                                    1800,
                                                                    'Unit Price',
                                                                    Date.today(), 
                                                                    Date.today().addMonths(12),
                                                                    true, true);

    //Start: Create optiongroup, classification hierarchy, optioncomponent.
        
    Apttus_Config2__ClassificationName__c newCategory = TestDataSetupUtility.getCategory('optiongroup1', 'optiongroup1', 'Option Group');
    insert newCategory;
                            
    Apttus_Config2__ClassificationHierarchy__c newCategoryHierarchy = TestDataSetupUtility.getCategoryHierarchy('optiongroup1', 'Category1', newCategory);
    insert newCategoryHierarchy;
                            
    Apttus_Config2__ProductOptionGroup__c prodOptionGroup = TestDataSetupUtility.getProductOptionGroup(newCategoryHierarchy, bundle_product);
    insert prodOptionGroup;
                            
    Apttus_Config2__ProductOptionComponent__c prodOptionComponent1 = TestDataSetupUtility.getProductOptionComponent(Option_product, prodOptionGroup, bundle_product);
    Apttus_Config2__ProductOptionComponent__c prodOptionComponent2 = TestDataSetupUtility.getProductOptionComponent(standalone_product, prodOptionGroup, bundle_product);
                           
    List<Apttus_Config2__ProductOptionComponent__c> lstprodOptionComponent = new List<Apttus_Config2__ProductOptionComponent__c>{prodOptionComponent1, prodOptionComponent2 };
    insert lstprodOptionComponent;


    //End:Create optiongroup, classification hierarchy, optioncomponent.

    // STEP IV - Create a new quote/proposal
 

    Apttus_Proposal__Proposal__c proposalSO = TestDataSetupUtility.CreateQuoteOrProposal('Test Configure', 
                                                                    opp.id,
                                                                    Date.today(), 
                                                                    Date.today().addMonths(12), 
                                                                    priceListSO.Id,
                                                                    Date.today(),
                                                                    '3 Years',
                                                                    true, true);
    
     
    proposalSO.Apttus_QPConfig__PriceListId__c=priceListSO.Id; 
                                                               
     
    
    // STEP V - create a new configuration object
    Apttus_Config2__ProductConfiguration__c configSO = TestDataSetupUtility.createProductConfiguration('Pricing Callback Test',
                                                                                  1,
                                                                                  proposalSO.Id,
                                                                                  'Proposal',
                                                                                  'Ad Hoc',
                                                                                  priceListSO.Id,//proposalSO.Apttus_QPConfig__PriceListId__c,
                                                                                  null,
                                                                                  'Finalized',
                                                                                  null,
                                                                                  Datetime.now(),
                                                                                  true,
                                                                                  'Pricing Callback Test',
                                                                                  true);
    
    Apttus_Config2__TempObject__c tempObject=new Apttus_Config2__TempObject__c(); 
    insert tempObject;                                                                             
   
    // STEP VI - Create new ad hoc groups
    Apttus_Config2__AdHocGroup__c adGroupSO = TestDataSetupUtility.createAdHocGroup('Group A',
                                                               configSO.Id,
                                                               'Group A', true);  
    // STEP VII - Create new line items
    Apttus_Config2__LineItem__c lineItemSO = TestDataSetupUtility.createLineItem(configSO.Id,//configId
                                                            null,//groupId
                                                            1,//line number
                                                            true,//Is primary line
                                                            1,//itemseq
                                                            'Product/Service',//linetype
                                                            bundle_product.Id,//product Id
                                                            true,//boolean customizable
                                                            null,//productOptionId
                                                            null,//OptionId,
                                                            null,//classid
                                                            null,//string classhierarchy
                                                            1,//qty
                                                            true,//isQtymodifiable
                                                            'Each',//UOM
                                                            1,//term
                                                            priceListSO.Id,//pricelistId
                                                            plItem_bundle.Id,//price list item
                                                            'One Time',//price type
                                                            'Per Unit',// price method
                                                            'Subscription Fee', // charge type
                                                            null,//frequency
                                                            true,//allow manual adj
                                                            true,//allocate group adj
                                                            9485,//listprice
                                                            9485,//baseprice
                                                            'Per Unit',//baserpricemethod
                                                            9485,//optionprice
                                                            null,//extprice
                                                            9485,
                                                            1, true);
    Apttus_Config2__ProductAttributeValue__c prodAttrValue1 = TestDataSetupUtility.CreateProductAttribureValue(lineItemSO.id, true);                                                       
    
    
    Apttus_Config2__LineItem__c lineItemSO2 = TestDataSetupUtility.createLineItem(configSO.Id,//configId
                                                                null,//groupId
                                                                1,//line number
                                                                true,//Is primary line
                                                                1,//itemseq 
                                                                'Option',//linetype
                                                                bundle_product.Id,//product Id
                                                                true,//boolean customizable
                                                                prodOptionComponent1.id,//productOptionId
                                                                Option_product.id,//OptionId, 
                                                                null,//classid 
                                                                null,//string classhierarchy
                                                                1,//qty
                                                                true,//isQtymodifiable
                                                                'Each',//UOM
                                                                1,//term
                                                                priceListSO.Id,//pricelistId
                                                                plItem_standalone.Id,//price list item
                                                                'Recurring',//price type
                                                                'Per Unit',// price method
                                                                null,// 'Subscription Fee', // charge type
                                                                null,//frequency
                                                                true,//allow manual adj
                                                                true,//allocate group adj
                                                                9485,//listprice
                                                                9485,//baseprice
                                                                'Per Unit',//baserpricemethod
                                                                9485,//optionprice
                                                                null,//extprice
                                                                9485,
                                                                2, true);
    Apttus_Config2__ProductAttributeValue__c prodAttrValue2 = TestDataSetupUtility.CreateProductAttribureValue(lineItemSO2.id, true); 
       
    Apttus_Config2__LineItem__c lineItemx=[select id,name,Apttus_Config2__OptionId__c,
                                               Apttus_Config2__ProductOptionId__r.Apttus_Config2__ProductOptionGroupId__c
                                              from
                                              Apttus_Config2__LineItem__c
                                              where id=:lineItemSO2.id ];

    system.assertNotEquals(lineItemx.Apttus_Config2__ProductOptionId__r.Apttus_Config2__ProductOptionGroupId__c,null);
    system.assertNotEquals(prodOptionComponent1.Apttus_Config2__ProductOptionGroupId__c,null);
    system.assertEquals(lineItemx.Apttus_Config2__ProductOptionId__r.Apttus_Config2__ProductOptionGroupId__c,prodOptionComponent1.Apttus_Config2__ProductOptionGroupId__c);                                        
        
    Apttus_Config2__ProductAttributeGroupMember__c ACPG = TestDataSetupUtility.createProdAttGroupMember(lineItemSO2.Apttus_Config2__OptionId__c, true);
    List<Product_Attribute_Rule_Definitions__c> pardList = TestDataSetupUtility.createPARDRelatedRecords(lineItemx.Apttus_Config2__OptionId__c,lineItemx.Apttus_Config2__ProductOptionId__r.Apttus_Config2__ProductOptionGroupId__c, true);
     
    Apttus_Config2__ConfigSystemProperties__c configproperties=new Apttus_Config2__ConfigSystemProperties__c(name='System Properties',Apttus_Config2__DefaultProductsPage__c='prodCatalogPage',Apttus_Config2__ViewCartPage__c='prodCatalogPage');
    insert configproperties;

    Test.startTest(); 

    Test.setCurrentPage(page.CustomGoToPricing);
    //Test.setCurrentPageReference(page.OptionAttributeOverride); 
    apexpages.currentPage().getParameters().put('id',ConfigSO.id);
    apexpages.currentPage().getParameters().put('configRequestId',tempObject.id);
      
    Id OptionId=lineItemx.Apttus_Config2__OptionId__c;
    Id Product_Option_Group=lineItemx.Apttus_Config2__ProductOptionId__r.Apttus_Config2__ProductOptionGroupId__c;
     
    /*
      Updated: 09/12/2015
    */    

    system.assertNotEquals(Product_Option_Group,null);  
    system.assertNotEquals(OptionId,null);
    system.assertNotEquals(lineItemSO2.Apttus_Config2__ProductOptionId__c,null);
    system.assertEquals(lineItemSO2.Apttus_Config2__ProductOptionId__c,prodOptionComponent1.id);
    system.assertEquals(lineItemx.Apttus_Config2__ProductOptionId__r.Apttus_Config2__ProductOptionGroupId__c,prodOptionComponent1.Apttus_Config2__ProductOptionGroupId__c);
       
        
      

    List<Product_Attribute_Rule_Definitions__c> prodPardList1=[SELECT Id,Name,
                                bundle_product__r.name,Primary_Product__r.name
                                
                                FROM Product_Attribute_Rule_Definitions__c 
                                where Primary_Product__c=:lineItemSO2.Apttus_Config2__OptionId__c];
    System.assertNotEquals(prodPardList1.size(),0);

    List<Product_Attribute_Rule_Definitions__c> prodPardList3=[SELECT Id,Name,
                                bundle_product__r.name,Primary_Product__r.name
                                
                                FROM Product_Attribute_Rule_Definitions__c 
                                where Product_Option_Group__c!=null];
    System.assertNotEquals(prodPardList3.size(),0); 

    List<Product_Attribute_Rule_Definitions__c> prodPardList2=[SELECT Id,Name,
                                bundle_product__r.name,Primary_Product__r.name
                                
                                FROM Product_Attribute_Rule_Definitions__c 
                                where Product_Option_Group__c=:Product_Option_Group];
    System.assertNotEquals(prodPardList2.size(),0);  
     
    GoToPricingCustomController gtpController=new GoToPricingCustomController();
    gtpController.processLines();
    gtpController.doCancel();

    Test.stopTest();

  }    
}