/***********************************************************************************************************
* Appirio, Inc
* Name         : productAttributeStandaloneExtension1Test
* Created By   : ??
* Purpose      : Test class of productAttributeStandaloneExtension1
* Created Date : ??
*
* Date Modified                Modified By             Description of the update
* Sep 01, 2015                 Rohit B. (Appirio)      created some additional test data and called function
**********************************************************************************************************/

@isTest
public class productAttributeStandaloneExtension1Test{
    static Apttus_Config2__LineItem__c aptusLineItem;
    static Attribute_Value__c attributeValue1;
    static User u;
    static List<Product_Attribute_Rule_Definitions__c> lstProductAttributes;
    
    static testMethod void testDependent() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        u = TestDataSetupUtility.createTestUser('TestFistName', 'TestLastName', p.Id);
        insert u;
        Apttus_Config2__AssetLineItem__c test_AssetLineItem = new Apttus_Config2__AssetLineItem__c(
            Name = 'test value');
        insert test_AssetLineItem;
        Apttus_Config2__AssetAttributeValue__c assetVal = new Apttus_Config2__AssetAttributeValue__c();
        assetVal.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
        System.runAs(u) {
            
            createTestData();
            
            PageReference pageRef = Page.ProductAttributeOverride;
            pageRef.getParameters().put('id', aptusLineItem.Id);
            Test.setCurrentPage(pageRef);
            Test.startTest();
            productAttributeStandaloneExtension1 ctrl = new productAttributeStandaloneExtension1(new ApexPages.StandardController(aptusLineItem));
            String systemflow = ctrl.sysflow;
            String debugString = ctrl.debugString;
            String pardPathStr = ctrl.pardPath;
            ctrl.Mid_Contract = false;
            ctrl.Product_Extension = false;
            ctrl.Product_Conversion = false;
            ctrl.hascontrollerproposalheader = true;
            List<string> atributevl = new List<string>();
            atributevl.add(attributeValue1.Id);
            ctrl.pardDependentMap.put(String.valueOf(lstProductAttributes[0].Id), atributevl);
            ctrl.productAttributeValueMap.put(attributeValue1.Id, attributeValue1);
            ctrl.Attchange();
            
            ctrl.includeDependents(lstProductAttributes[0].Id,new Map<String,String>());
            ctrl.excludeDependents(lstProductAttributes[0].Id);
            ctrl.hideDependents(lstProductAttributes[0].Id);
            ctrl.lockDependents(lstProductAttributes[0].Id);
            Test.stopTest();
        }
    }
    
    static testMethod void testPageLoad() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        u = TestDataSetupUtility.createTestUser('TestFistName', 'TestLastName', p.Id);
        insert u;
        System.runAs(u) {
            
            createTestData();
            
            PageReference pageRef = Page.ProductAttributeOverride;
            pageRef.getParameters().put('id', aptusLineItem.Id);
            Test.setCurrentPage(pageRef);
            Test.startTest();
            productAttributeStandaloneExtension1 ctrl = new productAttributeStandaloneExtension1(new ApexPages.StandardController(aptusLineItem));
            String systemflow = ctrl.sysflow;
            String debugString = ctrl.debugString;
            String pardPathStr = ctrl.pardPath;
            ctrl.Mid_Contract = false;
            ctrl.Product_Extension = false;
            ctrl.Product_Conversion = false;
            ctrl.hascontrollerproposalheader = true;
            ctrl.Attchange();
            
            // Added by Rohit B on 01/Sept/2015 for some condition passing data             --START--
            ctrl.Mid_Contract = true;
            ctrl.Product_Extension = true;
            ctrl.Product_Conversion = true;
            ctrl.hascontrollerproposalheader = false;
            ctrl.Attchange();
            // Added by Rohit B on 01/Sept/2015 for some condition passing data             --END--
            Test.stopTest();
        }
    }
    
    static testMethod void testController(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        u = TestDataSetupUtility.createTestUser('TestFistName', 'TestLastName', p.Id);
        insert u;
        System.runAs(u) {
            
            createTestData();
            Attribute_Value__c attributeValue5 = new Attribute_Value__c();
            attributeValue5.Attribute_Type__c = 'Proposal';
            attributeValue5.Attributes_Name__c = 'AgencyCommission__c';
            attributeValue5.Attribute_Values__c = 'AgencyCommission__c';
            attributeValue5.Sequence__c = 5;
            
            Attribute_Value__c attributeValue6 = new Attribute_Value__c();
            attributeValue6.Attributes_Name__c = 'AgencyIO__c';
            attributeValue6.Attribute_Values__c = 'AgencyIO__c';
            attributeValue6.Attribute_Type__c = 'Proposal';
            attributeValue6.Sequence__c = 6;
            
            insert (new List<Attribute_Value__c>{attributeValue5,attributeValue6});
            PageReference pageRef = Page.ProductAttributeOverride;
            pageRef.getParameters().put('id', aptusLineItem.Id);
            Test.setCurrentPage(pageRef);
            Test.startTest();
            productAttributeStandaloneExtension1 ctrl = new productAttributeStandaloneExtension1(new ApexPages.StandardController(aptusLineItem));
            String systemflow = ctrl.sysflow;
            String debugString = ctrl.debugString;
            String pardPathStr = ctrl.pardPath;
            ctrl.Mid_Contract = false;
            ctrl.Product_Extension = false;
            ctrl.Product_Conversion = false;
            ctrl.hascontrollerproposalheader = true;
            
            ctrl.Attchange();
            productAttributeStandaloneExtension1.AttClassTemplateItem objItem = new productAttributeStandaloneExtension1.AttClassTemplateItem('Test','Test','Test',new List<String>(),new String[]{'Multiselect 1'},Null,Null,Null,Null);
            objItem.getAttrbOption();
            Test.stopTest();
        }
    }
    static void createTestData() {
        
        
        Personal_Settings__c personal = new Personal_Settings__c();
        personal = TestDataSetupUtility.buildPersonalSetting(); 
        personal.Trigger_Quote__c = true;
        insert personal;

        Sales_Channel_Cross_Reference__c crossRef = TestDataSetupUtility.salesChannelCrossReference();
        insert crossRef;

        Account acct = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TEST PB Account'); //, 'North America', UserInfo.getUserId());
        acct.Phone = '+18008008000';
        acct.BillingCountry = 'Philippines';
        acct.PrimaryServiceRep__c = u.id;
        acct.Organization__c = 'Europe';
        acct.ServiceTier__c = 'Core';
        insert acct;
        
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('test opp', acct.id);
        
        insert opp;
        
        Apttus_Proposal__Proposal__c proposal = TestDataSetupUtility.createProposal(opp.Id);
        proposal.AgencyIO__c = 'Tesst';
        proposal.AgencyCommission__c  = 11;
        proposal.Upgrade_Proposal__c = true;
        //insert proposal;
        
        // Added by Rohit B on 01/Sept/2015 for some condition passing data             --START--
        Apttus_Proposal__Proposal__c proposal_new = TestDataSetupUtility.createProposal(opp.Id);
        proposal_new.AgencyIO__c = 'Tesst';
        proposal_new.Upgrade_Proposal__c = true;
        proposal_new.AgencyCommission__c  = 11;
        insert new List<Apttus_Proposal__Proposal__c>{proposal_new, proposal};
            // Added by Rohit B on 01/Sept/2015 for some condition passing data             --END--
            
            Product2 product = TestDataSetupUtility.createProduct('Test Product', false);
        Product2 product1 = TestDataSetupUtility.createProduct('Test Product1', false);
        insert (new List<Product2>{product,product1});
        Apttus_Config2__PriceList__c aptusConfigPriceList = TestDataSetupUtility.createPriceList('TestPrice', true);
        
        
        Apttus_Config2__ProductConfiguration__c aptusConfig = TestDataSetupUtility.createTestProductConfig(proposal, acct, aptusConfigPriceList);
        aptusConfig.Apttus_Config2__Status__c = 'Finalized';
        insert aptusConfig;
        
        Apttus_Config2__AssetLineItem__c test_AssetLineItem = new Apttus_Config2__AssetLineItem__c(
            Name = 'test value');
        insert test_AssetLineItem;
        aptusLineItem = TestDataSetupUtility.createLineItemApttus(aptusConfig.Id);
        aptusLineItem.Apttus_Config2__ItemSequence__c = 1.00; 
        aptusLineItem.Apttus_Config2__LineNumber__c = 1.00;
        aptusLineItem.Apttus_Config2__LineStatus__c = 'Amended';
        aptusLineItem.Apttus_Config2__BaseProductId__c = product.id;
        aptusLineItem.Apttus_Config2__OptionId__c = product1.id;
        aptusLineItem.Apttus_Config2__PricingStatus__c = 'Complete';
        aptusLineItem.Apttus_Config2__ProductId__c = product.id;
        aptusLineItem.Apttus_Config2__AssetLineItemId__c = test_AssetLineItem.id;
        aptusLineItem.Apttus_Config2__EndDate__c = System.Today();
        aptusLineItem.Apttus_Config2__BasePrice__c = 12.23;
        aptusLineItem.AgencyCommission__c  = 11;
        //aptusLineItem.Apttus_Config2__LineStatus__c = 'Amended';
        insert aptusLineItem;
        
        Apttus_Config2__ProductAttributeGroup__c aptusGroup = TestDataSetupUtility.createGroup('TestGroup');
        insert aptusGroup;
        
        Apttus_Config2__ProductAttributeValue__c test_ProductAttributeValue = new Apttus_Config2__ProductAttributeValue__c(
            Apttus_Config2__LineItemId__c = aptusLineItem.Id, Account_Type__c = 'N/A');
        insert test_ProductAttributeValue;
        
        attributeValue1 = new Attribute_Value__c();
        attributeValue1.Attributes_Name__c = 'AgencyCommission__c';
        attributeValue1.Attribute_Values__c = 'AgencyCommission__c';
        attributeValue1.Attribute_Type__c = 'Proposal';
        attributeValue1.Sequence__c = 1;
        
        Attribute_Value__c attributeValue2 = new Attribute_Value__c();
        attributeValue2.Attributes_Name__c = 'AgencyIO__c';
        attributeValue2.Attribute_Values__c = 'AgencyIO__c';
        attributeValue2.Attribute_Type__c = 'Proposal';
        attributeValue2.Sequence__c = 2;
        
        Attribute_Value__c attributeValue3 = new Attribute_Value__c();
        attributeValue3.Attributes_Name__c = 'country__c';
        attributeValue3.Attribute_Values__c = 'country__c';
        attributeValue3.Attribute_Type__c = 'Product';
        attributeValue3.Sequence__c = 3;
        
        Attribute_Value__c attributeValue4 = new Attribute_Value__c();
        attributeValue4.Attributes_Name__c = 'name';
        attributeValue4.Attribute_Values__c = 'name';
        attributeValue4.Attribute_Type__c = 'Product';
        attributeValue4.Sequence__c = 4;
        
        Attribute_Value__c attributeValue5 = new Attribute_Value__c();
        attributeValue5.Attributes_Name__c = 'Industries_Multi__c';
        attributeValue5.Attribute_Values__c = 'Administrative';
        attributeValue5.Attribute_Type__c = 'Product';
        attributeValue5.Sequence__c = 5;
        
        /*// Added by Rohit B on 01/Sept/2015 for some condition passing data           --START--
Attribute_Value__c attributeValue5 = new Attribute_Value__c(
Attributes_Name__c = 'Contract_Duration__c',
Attribute_Values__c = 'Contract_Duration__c',
Attribute_Type__c = 'Product',
Sequence__c = 5
);

Attribute_Value__c attributeValue6 = new Attribute_Value__c(
Attributes_Name__c = 'Zip_Code__c',
Attribute_Values__c = 'Zip_Code__c',
Attribute_Type__c = 'Product',
Sequence__c = 6
);

Attribute_Value__c attributeValue7 = new Attribute_Value__c(
Attributes_Name__c = 'Product_Start_Date__c',
Attribute_Values__c = 'Product_Start_Date__c',
Attribute_Type__c = 'Product',
Sequence__c = 7
);*/
        // Added by Rohit B on 01/Sept/2015 for some condition passing data             --END--
        
        insert (new List<Attribute_Value__c>{attributeValue1,attributeValue2,attributeValue3,attributeValue5});//,attributeValue4,attributeValue5,attributeValue6,attributeValue7});
        
        Attribute_Value_Group__c attributeGroup = new Attribute_Value_Group__c();
        attributeGroup.Indexing_Key__c = 'Test';
        insert attributeGroup;
        
        Attribute_Value_Group_Member__c member1  = new Attribute_Value_Group_Member__c ();
        member1.Attribute_Value__c = attributeValue1.Id;
        member1.Attribute_Value_Group__c = attributeGroup.Id;
        Attribute_Value_Group_Member__c member2  = new Attribute_Value_Group_Member__c ();
        member2.Attribute_Value__c = attributeValue2.Id;
        member2.Attribute_Value_Group__c = attributeGroup.Id;
        Attribute_Value_Group_Member__c member3  = new Attribute_Value_Group_Member__c ();
        member3.Attribute_Value__c = attributeValue3.Id;
        member3.Attribute_Value_Group__c = attributeGroup.Id;
        Attribute_Value_Group_Member__c member4  = new Attribute_Value_Group_Member__c ();
        member4.Attribute_Value__c = attributeValue4.Id;
        member4.Attribute_Value_Group__c = attributeGroup.Id;
        
        Attribute_Value_Group_Member__c member5  = new Attribute_Value_Group_Member__c ();
        member5.Attribute_Value__c = attributeValue5.Id;
        member5.Attribute_Value_Group__c = attributeGroup.Id;
        
        
        try{
            insert (new List<Attribute_Value_Group_Member__c>{member1,member2,member3,member4,member5});
        }catch(Exception e){
            System.debug('Exception is **'+e);
        }
        Apttus_Config2__ProductAttribute__c prodAttr1 = new Apttus_Config2__ProductAttribute__c(Apttus_Config2__AttributeGroupId__c=aptusGroup.Id,Apttus_Config2__Field__c=attributeValue1.Attributes_Name__c,Apttus_Config2__Sequence__c=1);
        Apttus_Config2__ProductAttribute__c prodAttr2 = new Apttus_Config2__ProductAttribute__c(Apttus_Config2__AttributeGroupId__c=aptusGroup.Id,Apttus_Config2__Field__c=attributeValue2.Attributes_Name__c,Apttus_Config2__Sequence__c=2);
        Apttus_Config2__ProductAttribute__c prodAttr3 = new Apttus_Config2__ProductAttribute__c(Apttus_Config2__AttributeGroupId__c=aptusGroup.Id,Apttus_Config2__Field__c=attributeValue3.Attributes_Name__c,Apttus_Config2__Sequence__c=3);
        Apttus_Config2__ProductAttribute__c prodAttr4 = new Apttus_Config2__ProductAttribute__c(Apttus_Config2__AttributeGroupId__c=aptusGroup.Id,Apttus_Config2__Field__c=attributeValue4.Attributes_Name__c,Apttus_Config2__Sequence__c=4);
        Apttus_Config2__ProductAttribute__c prodAttr5 = new Apttus_Config2__ProductAttribute__c(Apttus_Config2__AttributeGroupId__c=aptusGroup.Id,Apttus_Config2__Field__c=attributeValue5.Attributes_Name__c,Apttus_Config2__Sequence__c=5);
        List<Apttus_Config2__ProductAttribute__c> listProdAttr = new List<Apttus_Config2__ProductAttribute__c>{prodAttr1,prodAttr2,prodAttr3,prodAttr4,prodAttr5 };
            insert listProdAttr;
        
        Apttus_Config2__ProductAttributeGroupMember__c aptusGrpMember = TestDataSetupUtility.createProductGroupMember('TestGroupMember', aptusGroup.Id, product.Id);
        insert aptusGrpMember;
        
        lstProductAttributes = new List<Product_Attribute_Rule_Definitions__c>();
        //    List<Product_Attribute_Rule_Definitions__c> lstProductAttributes1 = new List<Product_Attribute_Rule_Definitions__c>();
        //   List<Product_Attribute_Rule_Definitions__c> lstProductAttributes2 = new List<Product_Attribute_Rule_Definitions__c>();
        //   List<Product_Attribute_Rule_Definitions__c> lstProductAttributes3 = new List<Product_Attribute_Rule_Definitions__c>();
        //   List<Product_Attribute_Rule_Definitions__c> lstProductAttributes4 = new List<Product_Attribute_Rule_Definitions__c>();
        
        for(Integer i = 0; i<5 ;i++){
            Product_Attribute_Rule_Definitions__c pard = new Product_Attribute_Rule_Definitions__c();
            pard.Bundle_Product__c = null;
            pard.Primary_Product__c = product.Id;
            pard.Active__c = true;
            pard.Controlling_Attribute_Value_Group__c = attributeGroup.Id;
            if(Math.mod(i,2) ==  0)
                pard.Action__c = 'Copy';
            else
                pard.Action__c = 'Locked';
            lstProductAttributes.add(pard);
            //   lstProductAttributes1.add(pard);
            //   lstProductAttributes2.add(pard);
            //   lstProductAttributes3.add(pard);
            
        }
        // Added by Rohit B on 01/Sept/2015 for some condition passing data             --START--
        /*   lstProductAttributes.add(new Product_Attribute_Rule_Definitions__c(
Bundle_Product__c = null,
Primary_Product__c = product.Id,
Active__c = true,
Controlling_Attribute_Value_Group__c = attributeGroup.Id,
Action__c = 'Include'
));*/
        lstProductAttributes.add(new Product_Attribute_Rule_Definitions__c(
            Bundle_Product__c = null,
            Primary_Product__c = product.Id,
            Active__c = true,
            Controlling_Attribute_Value_Group__c = attributeGroup.Id,
            Action__c = 'Exclude'
        ));
        lstProductAttributes.add(new Product_Attribute_Rule_Definitions__c(
            Bundle_Product__c = null,
            Primary_Product__c = product.Id,
            Active__c = true,
            Controlling_Attribute_Value_Group__c = attributeGroup.Id,
            Action__c = 'Hide'
        ));
        lstProductAttributes.add(new Product_Attribute_Rule_Definitions__c(
            Bundle_Product__c = null,
            Primary_Product__c = product.Id,
            Active__c = true,
            Controlling_Attribute_Value_Group__c = attributeGroup.Id,
            Action__c = 'Lock'
        ));
        // Added by Rohit B on 01/Sept/2015 for some condition passing data             --END--
        try{
            insert lstProductAttributes;
        }catch(Exception e){
            System.debug('Exception is **'+e);
        }    
        /*      try{
insert lstProductAttributes1;
}catch(Exception e){
System.debug('Exception is **'+e);
} 

try{
insert lstProductAttributes2;
}catch(Exception e){
System.debug('Exception is **'+e);
}

try{
insert lstProductAttributes3;
}catch(Exception e){
System.debug('Exception is **'+e);
}
*/   
        aptusLineItem.Apttus_Config2__AttributeValueId__c = test_ProductAttributeValue.Id;
        update aptusLineItem;       
    }
    
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
        
        Apttus_Config2__AssetAttributeValue__c assetVal = new Apttus_Config2__AssetAttributeValue__c();
        assetVal.Apttus_Config2__AssetLineItemId__c = lineItemSO2.id;
        //insert assetVal;
        
        Test.startTest();
        
        Test.setCurrentPageReference(page.ProductAttributeOverride); 
        apexpages.currentPage().getParameters().put('id',lineItemSO2.id);
        apexpages.currentPage().getParameters().put('configRequestId',tempObject.id);
        apexpages.currentPage().getParameters().put('APIName','Industries_Multi__c');
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
        proposalSO.Upgrade_Proposal__c = true;
        update proposalSO;
        
        lineItemSO2=[ select id,name,Apttus_Config2__LineStatus__c
                     
                     from Apttus_Config2__LineItem__c
                     where id=:lineItemSO2.id];
        lineItemSO2.Apttus_Config2__LineStatus__c='Amended';  
        
        update lineItemSO2;          
        
        prodAttExt.selectclick();
        prodAttExt.unselectclick();
            
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
        
        proposalSO.MidContract_Proposal__c=true;
        update proposalSO;
        lineItemSO2.Apttus_Config2__LineStatus__c = 'Incremented';
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
    
    
    ////////////////////////
    
    private static testMethod  void testproductAttribute1(){
        
        
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
        productAttributeStandaloneExtension1 prodAttExt=new productAttributeStandaloneExtension1(sc);
        
        //prodAttExt.result.IsPricePending=false;
        //apexpages.getMessages();
        if(apexpages.hasMessages(apexpages.severity.error))
            //system.assert(false,''+apexpages.getMessages());
            
            prodAttExt.attchange();
        //prodAttExt.excludeDependents(prodPardList[0].id);
        //prodAttExt.lockDependents(prodPardList[0].id);
        //gd
        try{    
            prodAttExt.pricingcalls();
            prodAttExt.updatepricingcalls();
            prodAttExt.midContractDuration();
            
            //prodAttExt.cascadeAttributesOnLeadConfiguration();
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
        prodAttExt=new productAttributeStandaloneExtension1(sc); 
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
        List<Product_Attribute_Rule_Definitions__c> listPRD = [Select Id,Name,
                                                               bundle_product__r.name,Primary_Product__r.name 
                                                               FROM Product_Attribute_Rule_Definitions__c ];
        sc=null;
        sc = new ApexPages.standardController(lineItemSO2);
        
        //system.assertNotEquals(standalone_product.id,null);
        prodAttExt=null;
        prodAttExt=new productAttributeStandaloneExtension1(sc); 
        
        //Apttus_Config2__ProductAttributeValue__c attr = prodAttExt.getProdAttSO();
        List<Attribute_Value__c> valueLst = [select Attributes_Name__c,Attribute_Type__c,Attribute_Values__c
                                             from Attribute_value__c];
        prodAttExt.creatgroups(valueLst);
        prodAttExt.attchange();
        List<productAttributeStandaloneExtension1.AttClassTemplateItem> template = prodAttExt.getAttClassTemplateItemList();
        prodAttExt.updateProductAttributeValue(); 
        //prodAttExt.sortAttributes();
        Map<String,string> newMap = new Map<String,String>();
        
        
        //prodAttExt.MakeRequired();
        
        Test.stopTest();
    }
}