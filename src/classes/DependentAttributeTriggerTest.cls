@isTest

Private Class DependentAttributeTriggerTest{
    static Dependent_Attribute_workflow_object__c  attribute;
    
    static testmethod void testDependentAttributeTrigger(){
         attribute = TestDataSetupUtility.createDependentAttributeWorkflow();
         attribute.DEP_attrib_values__c = 'English';
         attribute.Attribute_type__c = 'Language T & C';         
         insert attribute ;
         
         attribute = TestDataSetupUtility.createDependentAttributeWorkflow();
         attribute.attribute_values__c = 'Asset_Product_Family__c';
         attribute.Attribute_type__c = 'Proposal';
         attribute.DEP_attrib_values__c = 'Ad_Size__c';
         insert attribute; 
         
         attribute = TestDataSetupUtility.createDependentAttributeWorkflow();
         attribute.attribute_values__c = '300x250';
         attribute.Attribute_type__c = 'Product';
         attribute.DEP_attrib_values__c = 'Ad_Size__c';
         insert attribute; 
         
    }
    
}