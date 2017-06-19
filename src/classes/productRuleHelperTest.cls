//
// (c) 2015 Appirio, Inc.
//
//  Test class for productRuleHelper
//
// Sep 02, 2015     Vivek Ojha      Original 
//
@isTest 
private class productRuleHelperTest {

    static testMethod void test_QueryPardRulesByOptions() {
        
         // create Attribute_Value_Group__c
        Attribute_Value_Group__c attr_group_value = new Attribute_Value_Group__c();
        insert attr_group_value;
        
        // create Product
        Product2 product = TestDataSetupUtility.createProduct('Test product1', false); 
        product.Convert_From__c = true;
        insert product;
        
       // create Attribute_Value_Group_Member__c
        Attribute_Value_Group_Member__c attr_group_member = new Attribute_Value_Group_Member__c();
        attr_group_member.Attribute_Value_Name_Manual__c = 'AVNM';
        attr_group_member.Attribute_Value_Group__c = attr_group_value.Id; 
        insert attr_group_member;
        
        
         
        Apttus_Config2__ClassificationName__c categorySample=new Apttus_Config2__ClassificationName__c(Name='sample category',Apttus_Config2__HierarchyLabel__c='sample category',Apttus_Config2__Active__c = true,Apttus_Config2__Type__c='Option Group');
        insert categorySample;
        Apttus_Config2__ClassificationHierarchy__c catHierarchy=new Apttus_Config2__ClassificationHierarchy__c(Name = 'catHierarchyName', Apttus_Config2__Label__c = 'catHierarchyName',Apttus_Config2__HierarchyId__c = categorySample.Id);
        insert catHierarchy;
        Apttus_Config2__ProductOptionGroup__c optionGrp =new Apttus_Config2__ProductOptionGroup__c(Apttus_Config2__OptionGroupId__c = catHierarchy.Id,
        Apttus_Config2__ProductId__c =  product.id, Apttus_Config2__Sequence__c = 1, Apttus_Config2__MinOptions__c = 1,Apttus_Config2__MaxOptions__c = 100);
        insert optionGrp;
      
         
        // create product attribute rule definitions
        Product_Attribute_Rule_Definitions__c pardRecord = new Product_Attribute_Rule_Definitions__c();
        pardRecord.Controlling_Attribute_Value_Group__c = attr_group_value.Id;
        pardRecord.Primary_Product__c =product.Id;
        pardRecord.Product_Option_Group__c = optionGrp.Id ;
        insert pardRecord;
        
        Test.startTest();
       try{
        productRuleHelper.QueryPardRulesByOptions(new List<Id>{product.Id},new set<Id>{optionGrp.Id});//List<Id> options,set<Id> optionGroupIdset
       }catch(Exception e){
        System.debug('Exception is ****'+e);
       }
        Test.stopTest();
    }
}