@isTest
private class BundleOptionAttributeExt1_Test{
    private static testMethod  void testBundleOptionAttributeExt1(){
        //BundleOptionAttributeExt1 tst = new BundleOptionAttributeExt1(null);
        /*
        Account acc = TestDataSetupUtility.createTestAccountWithShipping('testAccount');
        insert acc;
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('TestOpportunity',acc.Id);
        insert opp;
        Apttus_Proposal__Proposal__c prop = TestDataSetupUtility.createApttusProposal(opp);
        insert prop;
        
        Apttus_Config2__PriceList__c price = TestDataSetupUtility.createPriceList('testPrice',true);
        
        Apttus_Config2__ProductConfiguration__c config = TestDataSetupUtility.createTestProductConfig(prop,acc,price);
        insert config;
        
        Apttus_Config2__LineItem__c lineItem = TestDataSetupUtility.createLineItemApttus(config.Id);
        
        Product2 prod = TestDataSetupUtility.createTestProduct2('TestProduct');
        prod.productCode = 'Test';
        insert prod;
        
        Apttus_Config2__ClassificationName__c classify = TestDataSetupUtility.getCategory('test','testlabel', 'testType');
        insert classify;
        Apttus_Config2__ClassificationHierarchy__c hierarchy = TestDataSetupUtility.getCategoryHierarchy('test','testlabel',classify);
        insert hierarchy;
        
        Apttus_Config2__ProductOptionGroup__c productGroup= TestDataSetupUtility.getProductOptionGroup(hierarchy,prod);
        insert productGroup;
        
        Apttus_Config2__ProductOptionComponent__c prodOptionComponent=TestDataSetupUtility.getProductOptionComponent(prod,productGroup,prod);
        insert prodOptionComponent;
        
        
        //List<Product_Attribute_Rule_Definitions__c> listAttriRule = TestDataSetupUtility.createPARDRelatedRecords(prod.Id,productGroup.Id,true);
        //insert listAttriRule;
       
        
        Attribute_Value_Group__c  group1 = new Attribute_Value_Group__c ();
        insert group1;

        Attribute_Value__c  value = new Attribute_Value__c ();
        value.Attributes_Name__c = 'Test';
        value.Sequence__c = 1.00;
        value.Attribute_Type__c = 'Product';
        value.Attribute_Values__c = 'Test__c';
        insert value;

        Attribute_Value_Group_Member__c mem = new Attribute_Value_Group_Member__c ();
        mem.Attribute_Value_Group__c = group1.Id;
        mem.Attribute_Value__c = value.Id;
        mem.Product_Code__c = 'Test';
        insert mem;

        Product_Attribute_Rule_Definitions__c prod1 = new Product_Attribute_Rule_Definitions__c ();
        prod1.Controlling_Attribute_Value_Group__c = group1.Id;
        prod1.Action__c='Include';
        prod1.Hide__c=false;
        //prod1.sequence__c = 1;
        //prod1.Active__c = true;
        prod1.Dependent_Attribute_Value_Group__c = group1.Id;
        prod1.Product_Option_Group__c = productGroup.Id;
        prod1.Leading_Produc_Option__c = prod.id;
        prod1.Primary_Product__c = prod.Id;
        insert prod1;        
        
        Apttus_Config2__AssetLineItem__c assetLineItem = TestDataSetupUtility.createAssetLineItem('TestLineItem',acc.Id,true);
        lineItem.Apttus_Config2__OptionId__c = prod.id;
        lineItem.Apttus_Config2__ProductOptionId__c= prodOptionComponent.Id;
        lineItem.Apttus_Config2__AssetLineItemId__c = assetLineItem.Id;
        lineItem.Apttus_Config2__BasePrice__c = 10.0;
        insert lineItem;
        
        /*
        Attribute_Value_Group__c ctrlGrp1=new Attribute_Value_Group__c();
        Attribute_Value_Group__c depGrp1=new Attribute_Value_Group__c();
        list<Attribute_Value_Group__c> avgList = new List<Attribute_Value_Group__c>{ctrlGrp1, depGrp1};
        insert avgList;

        Attribute_Value__c avc1 = TestDataSetupUtility.createAttributeValue('Product_Name__c', 'Product', 'OptionProduct1', 1, true);
        TestDataSetupUtility.createAttributeValueGroupMember(ctrlGrp1.id, avc1.id, 'BundleProduct1', true);

        Attribute_Value__c avd1 = TestDataSetupUtility.createAttributeValue('Contract_Duration__c', 'Product', '11 Months', 2, true);
        TestDataSetupUtility.createAttributeValueGroupMember(depGrp1.id, avd1.id, 'BundleProduct1', true);
        
        Apttus_Config2__ProductAttributeGroupMember__c groupMember = TestDataSetupUtility.createProdAttGroupMember(prod.Id,true);
        
        Apttus_Config2__ProductAttributeValue__c productAttrvalue = TestDataSetupUtility.CreateProductAttribureValue(lineItem.id,true);
        
        PageReference pageRef = new PageReference('/apex/BundleOptionAttributeExt1?id=' +lineItem.id );
        Test.setCurrentPage(pageRef);
        //create instance of conroller and put Quote.id as the parameter id
        ApexPages.CurrentPage().getparameters().put('id', lineItem.id);
        ApexPages.StandardController sc = new ApexPages.standardController(lineItem);
        BundleOptionAttributeExt1 bundleOptionAttr = new BundleOptionAttributeExt1(sc);
        
        bundleOptionAttr.actionpollar = false;
        bundleOptionAttr.pricecurrency = 'USD';
        bundleOptionAttr.price = 100.0;
        bundleOptionAttr.Qty = 10;
        bundleOptionAttr.Resume_Upgrade = false;
        bundleOptionAttr.Mid_Contract = false;
        bundleOptionAttr.Product_Extension = false;
        bundleOptionAttr.Product_Conversion = false;
        bundleOptionAttr.hascontrollerproposalheader = true;
        //bundleOptionAttr.sysflow = null;
        //bundleOptionAttr.debugString = null;
        
        
        
        bundleOptionAttr.pardDependentMap.put(prod1.Id,new List<String>{value.Id});
        bundleOptionAttr.pardRulesById.put(prod1.Id,prod1);
        bundleOptionAttr.pardControllingmap.put(prod1.Id,new List<String>{value.Id});
        bundleOptionAttr.excludeDependents(prod1.Id);
        bundleOptionAttr.lockDependents(prod1.Id);
        List<Attribute_Value__c> valueLst = new List<Attribute_Value__c>();
        valueLst.add(value);
        bundleOptionAttr.productAttributeValueMap.put(value.Id,value);
       
        bundleOptionAttr.creatgroups(valueLst);
        bundleOptionAttr.LockProductAttributes();
        bundleOptionAttr.midContractDuration();
        bundleOptionAttr.updateProductAttributeValue();
        Map<String,string> newMap = new Map<String,String>();
        bundleOptionAttr.includeDependents(prod1.Id,newMap);
        String fieldSet = 'Additional_Day__c';
        bundleOptionAttr.populatedefaults(fieldSet);
        bundleOptionAttr.sortAttributes();
        pageRef = bundleOptionAttr.Attchange();
        //bundleOptionAttr.ResumeUpgrade();
        //List<SelectOption> sel = bundleOptionAttr.getAttrbOption();
        */
        
         
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
       apexpages.currentPage().getParameters().put('APIName','Industries_Multi__c');
       ApexPages.StandardController sc = new ApexPages.standardController(lineItemSO2);
       
       //system.assertNotEquals(standalone_product.id,null);
       Id OptionId=lineItemSO2.Apttus_Config2__OptionId__c;
       Id Product_Option_Group=lineItemSO2.Apttus_Config2__ProductOptionId__r.Apttus_Config2__ProductOptionGroupId__c;
       
       

       
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
       //System.assertEquals(prodPardList2.size(),0); // gd



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
       //system.assert(false,''+apexpages.getMessages());
       
        prodAttExt.attchange();
        //prodAttExt.excludeDependents(prodPardList[0].id);
       //prodAttExt.lockDependents(prodPardList[0].id);
        //gd
        set<String> setData=new set<String>{'Test1','Test2'};
        try{    
       prodAttExt.pricingcalls();
       prodAttExt.updatepricingcalls();
       prodAttExt.midContractDuration();
       prodAttExt.cascadeAttributesOnLeadConfiguration();
       
        }Catch(exception e){
            
        }
       
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
       
       //Apttus_Config2__ProductAttributeValue__c attr = prodAttExt.getProdAttSO();
       List<Attribute_Value__c> valueLst = [select Attributes_Name__c,Attribute_Type__c,Attribute_Values__c
                                           from Attribute_value__c];
       prodAttExt.creatgroups(valueLst);
       prodAttExt.attchange();
       List<BundleOptionAttributeExt1.AttClassTemplateItem> template = prodAttExt.getAttClassTemplateItemList();
       template[0].inputItemDOUBLE=1.00;
       template[0].inputdate=Date.today();
       template[0].labelValuetype='MultiPicklist';
       prodAttExt.updateProductAttributeValue(); 
       prodAttExt.sortAttributes();
       Map<String,string> newMap = new Map<String,String>();
       BundleOptionAttributeExt1.ProductAttributeValue pav =new BundleOptionAttributeExt1.ProductAttributeValue(1.0,valueLst[0]);
       Integer i=pav.compareTo(pav);
       BundleOptionAttributeExt1.ProductAttributeValue pav1 =new BundleOptionAttributeExt1.ProductAttributeValue(2.0,valueLst[0]);
       Integer j=pav.compareTo(pav1);
       //prodAttExt.includeDependents(null,newMap);
       //prodAttExt.hideDependents(prodPardList1);
       prodAttExt.MakeRequired();
       prodAttExt.selectclick();
        prodAttExt.unselectclick();
        prodAttExt.getSelectedValues(setData);
         prodAttExt.getunSelectedValues(setData);
         List<selectOption> so=template[0].getAttrbOption();
       
       Test.stopTest();
        
        
        
        
    }

}