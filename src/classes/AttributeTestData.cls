/*

Depends upon TestDataSetupUtility.cls for account creatoin
Master data to be inserted while migrating the data:Line number 111 

Todos:

write different test methods for gotopricing custom controller
rule processror
productruleHelper
CascadeAttributes
BundleOptionExt1.

Remove the unused classes.
Update: 09/11/2015

*/


@istest
private with sharing class AttributeTestData {
    
    
    
    /**********************************************************************************************************/
    static testMethod void testStandAloneProductsAttributes() 
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
                                                                        
        Apttus_Config2__ClassificationName__c newCategory = TestDataSetupUtility.getCategory('optiongroup1', 'optiongroup1', 'Option Group');
        insert newCategory;
                                
        Apttus_Config2__ClassificationHierarchy__c newCategoryHierarchy = TestDataSetupUtility.getCategoryHierarchy('optiongroup1', 'Category1', newCategory);
        insert newCategoryHierarchy;

        Apttus_Config2__ProductOptionGroup__c prodOptionGrp = TestDataSetupUtility.getProductOptionGroup(newCategoryHierarchy, bundle_product);
        insert   prodOptionGrp;
        
        Apttus_Config2__ProductOptionComponent__c prodOptComp_pso3= TestDataSetupUtility.CreateOptionComponents(prodOptionGrp.id,//Id OptionGroupId,
                                                                                       standalone_product.id,//Id OptionId,
                                                                                       bundle_product.id,//Id parentProductId,
                                                                                       'Option',//string relationshipType
                                                                                       1, true);
                                
        Apttus_Config2__ProductOptionComponent__c prodOptComp_pso5=TestDataSetupUtility.CreateOptionComponents(prodOptionGrp.id,//Id OptionGroupId,
                                                                                       standalone_product.id,//Id OptionId,
                                                                                       bundle_product.id,//Id parentProductId,
                                                                                        'Option',//string relationshipType
                                                                                        3, true);
         
        
            
        // STEP IV - Create a new quote/proposal
        Apttus_Proposal__Proposal__c proposalSO = TestDataSetupUtility.createQuoteOrProposal('Test Configure', 
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
         Apttus_Config2__ProductAttributeValue__c prodAttrValue1=TestDataSetupUtility.CreateProductAttribureValue(lineItemSO.id, true);                                                       
        
        
         Apttus_Config2__LineItem__c lineItemSO2 = TestDataSetupUtility.createLineItem(configSO.Id,//configId
                                                                null,//groupId
                                                                2,//line number
                                                                true,//Is primary line
                                                                1,//itemseq
                                                                'Product/Service',//linetype
                                                                standalone_product.Id,//product Id
                                                                true,//boolean customizable
                                                                prodOptComp_pso5.id,//productOptionId
                                                                null,//OptionId,
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
                                                                
         Apttus_Config2__ProductAttributeValue__c prodAttrValue2=TestDataSetupUtility.CreateProductAttribureValue(lineItemSO2.id, true); 
                                                                
        
        Apttus_Config2__ProductAttributeGroupMember__c ACPG = TestDataSetupUtility.createProdAttGroupMember(standalone_product.id, true) ;                                                                        
        List<Product_Attribute_Rule_Definitions__c> pardList = TestDataSetupUtility.createPARDRelatedRecords(standalone_product.id, null, true);
        
       
       
       Test.startTest();
       
       Test.setCurrentPageReference(page.ProductAttributeOverride); 
       apexpages.currentPage().getParameters().put('id',lineItemSO2.id);
       apexpages.currentPage().getParameters().put('configRequestId',tempObject.id);
       ApexPages.StandardController sc = new ApexPages.standardController(lineItemSO2);
       
       system.assertNotEquals(standalone_product.id,null);
       list<Product_Attribute_Rule_Definitions__c> prodPardList = [SELECT Id,Name 
                                                                   FROM Product_Attribute_Rule_Definitions__c  
                                                                   Where Primary_Product__c =:standalone_product.id 
                                                                   and 
                                                                   //Bundle_Product__c=null and
                                                                   active__c=true order by sequence__c  
                                                                   ];
       
       //System.assert(prodPardList.size()==0,'AttributeTestData:No Pard Records Found');   
       System.assertNotEquals(prodPardList.size(),0);
       productAttributeStandaloneExtension1 prodAttExt=new productAttributeStandaloneExtension1(sc);
       //prodAttExt.result.IsPricePending=false;
       //apexpages.getMessages();
       //if(apexpages.hasMessages(apexpages.severity.error))
       //system.assert(false,''+apexpages.getMessages());
       for(apexpages.Message mymessage:apexpages.getMessages())
       {
        system.debug('@@@@mymessage'+mymessage);
       }
       prodAttExt.attchange();
       prodAttExt.pricingcalls();
       prodAttExt.updatepricingcalls();
       prodAttExt.midContractDuration();
       
       sc=null;
       sc = new ApexPages.standardController(lineItemSO2);
       
       system.assertNotEquals(standalone_product.id,null);
       prodAttExt=null;
       prodAttExt=new productAttributeStandaloneExtension1(sc); 
       prodAttExt.attchange();


        proposalSO=[ select id,name,Upgrade_Proposal__c,APTS_Quote_Type__c
                     from Apttus_Proposal__Proposal__c 
                   where id=:proposalSO.id];

       update proposalSO;

       lineItemSO2=[ select id,name,Apttus_Config2__LineStatus__c

                     from Apttus_Config2__LineItem__c
                     where id=:lineItemSO2.id];
       lineItemSO2.Apttus_Config2__LineStatus__c='Amended';  

       update lineItemSO2;          
       
       sc=null;
       sc = new ApexPages.standardController(lineItemSO2);
       
       system.assertNotEquals(standalone_product.id,null);
       prodAttExt=null;
       prodAttExt=new productAttributeStandaloneExtension1(sc); 
       prodAttExt.attchange();

       proposalSO.APTS_Quote_Type__c='Product Extension';
       update proposalSO;
       lineItemSO2.Apttus_Config2__LineStatus__c = 'Renewed';
       update lineItemSO2;
       
       sc=null;
       sc = new ApexPages.standardController(lineItemSO2);
       
       system.assertNotEquals(standalone_product.id,null);
       prodAttExt=null;
       prodAttExt=new productAttributeStandaloneExtension1(sc); 
       prodAttExt.attchange();

       proposalSO.APTS_Quote_Type__c='Product Conversion';
       update proposalSO;
       lineItemSO2.Apttus_Config2__LineStatus__c = 'Converted';
       update lineItemSO2;

       sc=null;
       sc = new ApexPages.standardController(lineItemSO2);
       
       system.assertNotEquals(standalone_product.id,null);
       prodAttExt=null;
       prodAttExt=new productAttributeStandaloneExtension1(sc); 
       prodAttExt.attchange();



       //Upgrade_Proposal__c,Apttus_Config2__LineStatus__c='Amended'

      //MidContract_Proposal__c,Apttus_Config2__LineStatus__c='Incremented'

      //APTS_Quote_Type__c == 'Product Extension', lineItem.Apttus_Config2__LineStatus__c == 'Renewed'
      //APTS_Quote_Type__c == 'Product Conversion' , Apttus_Config2__LineStatus__c == 'Converted'
        
       Test.stopTest();
    }
    
    /*
       Test Bundles
    */
     static testMethod void testBundleProducts()
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
                                                                        
        
       /* Apttus_Config2__ProductOptionGroup__c prodOptionGrp=new Apttus_Config2__ProductOptionGroup__c(Apttus_Config2__Sequence__c=0,
                                                                                                        Apttus_Config2__MinOptions__c=0,
                                                                                                        Apttus_Config2__MaxOptions__c=100,
                                                                                                        Apttus_Config2__ProductId__c=bundle_product.id,
                                                                                                        Apttus_Config2__OptionGroupId__c=[select id from Apttus_Config2__ClassificationHierarchy__c 
                                                                                                                                          where Apttus_Config2__HierarchyId__r.Apttus_Config2__Type__c='Option Group' limit 1].id 
                                                                                                        
                                                                                                        );    
         insert   prodOptionGrp;
        
        Apttus_Config2__ProductOptionComponent__c prodOptComp_pso3= CreateOptionComponents(prodOptionGrp.id,//Id OptionGroupId,
                                                                                       standalone_product.id,//Id OptionId,
                                                                                       bundle_product.id,//Id parentProductId,
                                                                                       'Option',//string relationshipType
                                                                                       1
                                                                                       );
                                
          Apttus_Config2__ProductOptionComponent__c prodOptComp_pso5=CreateOptionComponents(prodOptionGrp.id,//Id OptionGroupId,
                                                                                       standalone_product.id,//Id OptionId,
                                                                                       bundle_product.id,//Id parentProductId,
                                                                                        'Option',//string relationshipType
                                                                                        3);
         
        
        
       
      */

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
     

         Apttus_Proposal__Proposal__c proposalSO = TestDataSetupUtility.createQuoteOrProposal('Test Configure', 
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
                                                                   'Group A',
                                                                   true);  
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
         Apttus_Config2__ProductAttributeValue__c prodAttrValue1=TestDataSetupUtility.CreateProductAttribureValue(lineItemSO.id, true);                                                       
        
        
         Apttus_Config2__LineItem__c lineItemSO2 = TestDataSetupUtility.createLineItem(configSO.Id,//configId
                                                                null,//groupId
                                                                2,//line number
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
      Apttus_Config2__ProductAttributeValue__c prodAttrValue2=TestDataSetupUtility.CreateProductAttribureValue(lineItemSO2.id, true); 
     

       Apttus_Config2__LineItem__c lineItemSO3 = TestDataSetupUtility.createLineItem(configSO.Id,//configId
                                                                null,//groupId
                                                                2,//line number
                                                                true,//Is primary line
                                                                1,//itemseq
                                                                'Option',//linetype
                                                                bundle_product.Id,//product Id
                                                                true,//boolean customizable
                                                                prodOptionComponent2.id,//productOptionId
                                                                standalone_product.id,//OptionId, 
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
       Apttus_Config2__ProductAttributeValue__c prodAttrValue3=TestDataSetupUtility.CreateProductAttribureValue(lineItemSO3.id, true); 
       
        Apttus_Config2__LineItem__c lineItemx=[select id,name,Apttus_Config2__OptionId__c,
                                               Apttus_Config2__ProductOptionId__r.Apttus_Config2__ProductOptionGroupId__c
                                              from
                                              Apttus_Config2__LineItem__c
                                              where id=:lineItemSO2.id ];
      
       Apttus_Config2__ProductAttributeGroupMember__c ACPG = TestDataSetupUtility.createProdAttGroupMember(lineItemSO2.Apttus_Config2__OptionId__c, true) ;                                                                        
       List<Product_Attribute_Rule_Definitions__c> pardList = TestDataSetupUtility.createPARDRelatedRecords(lineItemx.Apttus_Config2__OptionId__c, lineItemx.Apttus_Config2__ProductOptionId__r.Apttus_Config2__ProductOptionGroupId__c, true);
       

      Test.startTest();

       Test.setCurrentPageReference(page.OptionAttributeOverride); 
       apexpages.currentPage().getParameters().put('id',lineItemSO2.id);
       apexpages.currentPage().getParameters().put('configRequestId',tempObject.id);
       ApexPages.StandardController sc = new ApexPages.standardController(lineItemSO2);
       
      //system.assertNotEquals(standalone_product.id,null);
       Id OptionId=lineItemSO2.Apttus_Config2__OptionId__c;
       System.debug('TestProdOpID'+prodOptionComponent1.id); 
       Id Product_Option_Group=lineItemSO2.Apttus_Config2__ProductOptionId__r.Apttus_Config2__ProductOptionGroupId__c;
       System.debug('TestPOG'+Product_Option_Group);
       

       
       system.assertNotEquals(OptionId,null);
       system.assertNotEquals(lineItemSO2.Apttus_Config2__ProductOptionId__c,null);
       system.assertEquals(lineItemSO2.Apttus_Config2__ProductOptionId__c,prodOptionComponent1.id);
       system.assertEquals(lineItemx.Apttus_Config2__ProductOptionId__r.Apttus_Config2__ProductOptionGroupId__c,prodOptionComponent1.Apttus_Config2__ProductOptionGroupId__c);
       system.assertNotEquals(OptionId,null);
       
      

      List<Product_Attribute_Rule_Definitions__c> prodPardList1=[SELECT Id,Name,
                                  bundle_product__r.name,Primary_Product__r.name
                                  
                                  FROM Product_Attribute_Rule_Definitions__c 
                                  where Primary_Product__c=:lineItemSO2.Apttus_Config2__OptionId__c];
       System.assertNotEquals(prodPardList1.size(),0);

       List<Product_Attribute_Rule_Definitions__c> prodPardList2=[SELECT Id,Name,
                                  bundle_product__r.name,Primary_Product__r.name
                                  
                                  FROM Product_Attribute_Rule_Definitions__c 
                                  where Product_Option_Group__c=:Product_Option_Group];
       //System.assertNotEquals(prodPardList2.size(),0);



      /*List<Product_Attribute_Rule_Definitions__c> prodPardList=[SELECT Id,Name,
                                  bundle_product__r.name,Primary_Product__r.name
                                  
                                  FROM Product_Attribute_Rule_Definitions__c 
                                  Where active__c=true and sequence__c>0 
                                  //and 
                                  //((Primary_Product__c =:OptionId  and Product_Option_Group__c=null) 
                                  //  or
                                  // (Primary_Product__c =:OptionId and Product_Option_Group__c=: Product_Option_Group)
                                  //)
                                  //order by Primary_Product__c,Product_Option_Group__c nulls first,sequence__c

                                  ];    
        System.assertNotEquals(prodPardList.size(),0);     */                                                                
        //Apexpages.addMessage(new apexpages.Message(apexpages.severity.info,'Rules Size'+prodPardList.size()));    
        Id BundleId=bundle_product.id;
        List<Id> productIds=new list<Id>{option_product.Id,standalone_product.id};                   
        List<Apttus_Config2__ProductOptionComponent__c> productComponents= [Select ID,Apttus_Config2__ComponentProductId__c,
                                                                               Is_Leading_option__c,Copy_Fields_from_Lead__c
                                                                               FROM Apttus_Config2__ProductOptionComponent__c where
                                                                                Apttus_Config2__ComponentProductId__c IN: productIds and 
                                                                                Apttus_Config2__ParentProductId__c=:BundleId];

       
       system.assertNotEquals(productComponents.size(),0);
       for(Apttus_Config2__ProductOptionComponent__c pc:productComponents){
       pc.Copy_Fields_from_Lead__c='Contract_Duration__c';

       }

       update productComponents;
       //System.assert(prodPardList.size()==0,'AttributeTestData:No Pard Records Found');   
       
       BundleOptionAttributeExt1 prodAttExt=new BundleOptionAttributeExt1(sc);
       //prodAttExt.result.IsPricePending=false;
       //apexpages.getMessages();
       if(apexpages.hasMessages(apexpages.severity.error))
       system.assert(false,''+apexpages.getMessages());
       
        prodAttExt.attchange();
        //prodAttExt.excludeDependents(prodPardList[0].id);
       //prodAttExt.lockDependents(prodPardList[0].id);

       prodAttExt.pricingcalls();
       prodAttExt.updatepricingcalls();
       prodAttExt.midContractDuration();
       
       
       for(list<Product_Attribute_Rule_Definitions__c> pardToUpdate:[select id,action__c 
                                                                  from Product_Attribute_Rule_Definitions__c
                                                                  where Id In: prodPardList1])
       {
         for(Product_Attribute_Rule_Definitions__c pard:pardToUpdate)
         {
           pard.action__c='Exclude';

         }

         update pardToUpdate;

       }

       sc=null;
       sc = new ApexPages.standardController(lineItemSO2);
       
       //system.assertNotEquals(standalone_product.id,null);
       prodAttExt=null;
       prodAttExt=new BundleOptionAttributeExt1(sc); 
       prodAttExt.attchange();


       for(list<Product_Attribute_Rule_Definitions__c> pardToUpdate:[select id,action__c 
                                                                  from Product_Attribute_Rule_Definitions__c
                                                                  where Id In: prodPardList1])
       {
         for(Product_Attribute_Rule_Definitions__c pard:pardToUpdate)
         {
           pard.action__c='Lock';

         }

         update pardToUpdate;

       }

       sc=null;
       sc = new ApexPages.standardController(lineItemSO2);
       
       //system.assertNotEquals(standalone_product.id,null);
       prodAttExt=null;
       prodAttExt=new BundleOptionAttributeExt1(sc); 
       prodAttExt.attchange();



       Test.stopTest();
       //BundleOptionAttributeExt1                                                        
         
    }

    static testMethod void testGotoPricingController()
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
                                                                        
        
       /* Apttus_Config2__ProductOptionGroup__c prodOptionGrp=new Apttus_Config2__ProductOptionGroup__c(Apttus_Config2__Sequence__c=0,
                                                                                                        Apttus_Config2__MinOptions__c=0,
                                                                                                        Apttus_Config2__MaxOptions__c=100,
                                                                                                        Apttus_Config2__ProductId__c=bundle_product.id,
                                                                                                        Apttus_Config2__OptionGroupId__c=[select id from Apttus_Config2__ClassificationHierarchy__c 
                                                                                                                                          where Apttus_Config2__HierarchyId__r.Apttus_Config2__Type__c='Option Group' limit 1].id 
                                                                                                        
                                                                                                        );    
         insert   prodOptionGrp;
        
        Apttus_Config2__ProductOptionComponent__c prodOptComp_pso3= CreateOptionComponents(prodOptionGrp.id,//Id OptionGroupId,
                                                                                       standalone_product.id,//Id OptionId,
                                                                                       bundle_product.id,//Id parentProductId,
                                                                                       'Option',//string relationshipType
                                                                                       1
                                                                                       );
                                
          Apttus_Config2__ProductOptionComponent__c prodOptComp_pso5=CreateOptionComponents(prodOptionGrp.id,//Id OptionGroupId,
                                                                                       standalone_product.id,//Id OptionId,
                                                                                       bundle_product.id,//Id parentProductId,
                                                                                        'Option',//string relationshipType
                                                                                        3);
         
        
        
       
      */

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
     

         Apttus_Proposal__Proposal__c proposalSO = TestDataSetupUtility.createQuoteOrProposal('Test Configure', 
                                                                        opp.id,
                                                                        Date.today(), 
                                                                        Date.today().addMonths(12), 
                                                                        priceListSO.Id,
                                                                        Date.today(),
                                                                        '3 Years',
                                                                        true,
                                                                        true);
        
         
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
         Apttus_Config2__ProductAttributeValue__c prodAttrValue1=TestDataSetupUtility.CreateProductAttribureValue(lineItemSO.id, true);                                                       
        
        
         Apttus_Config2__LineItem__c lineItemSO2 = TestDataSetupUtility.createLineItem(configSO.Id,//configId
                                                                null,//groupId
                                                                2,//line number
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
      Apttus_Config2__ProductAttributeValue__c prodAttrValue2=TestDataSetupUtility.CreateProductAttribureValue(lineItemSO2.id, true); 
     

       Apttus_Config2__LineItem__c lineItemSO3 = TestDataSetupUtility.createLineItem(configSO.Id,//configId
                                                                null,//groupId
                                                                2,//line number
                                                                true,//Is primary line
                                                                1,//itemseq
                                                                'Option',//linetype
                                                                bundle_product.Id,//product Id
                                                                true,//boolean customizable
                                                                prodOptionComponent2.id,//productOptionId
                                                                standalone_product.id,//OptionId, 
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
       Apttus_Config2__ProductAttributeValue__c prodAttrValue3=TestDataSetupUtility.CreateProductAttribureValue(lineItemSO3.id, true); 
       
        Apttus_Config2__LineItem__c lineItemx=[select id,name,Apttus_Config2__OptionId__c,
                                               Apttus_Config2__ProductOptionId__r.Apttus_Config2__ProductOptionGroupId__c
                                              from
                                              Apttus_Config2__LineItem__c
                                              where id=:lineItemSO2.id ];
      
        Apttus_Config2__ProductAttributeGroupMember__c ACPG = TestDataSetupUtility.createProdAttGroupMember(lineItemSO2.Apttus_Config2__OptionId__c, true) ;                                                                        
        List<Product_Attribute_Rule_Definitions__c> pardList = TestDataSetupUtility.createPARDRelatedRecords(lineItemx.Apttus_Config2__OptionId__c, lineItemx.Apttus_Config2__ProductOptionId__r.Apttus_Config2__ProductOptionGroupId__c, true);
    }
}