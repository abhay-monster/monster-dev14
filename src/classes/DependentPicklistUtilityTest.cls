// 
// (c) 2016 Appirio, Inc.
//
// Test class for DependentPicklistUtility
//
// 24-Nov-2016    Shyam Sundar    Original

@isTest
private class DependentPicklistUtilityTest {
    static testMethod void testGetDependentOptions(){ 
        DependentPicklistUtility.TPicklistEntry objTPickList = new DependentPicklistUtility.TPicklistEntry();
    
       
        // Test GetDependentOptions with asserts
        system.assertNotEquals(DependentPicklistUtility.GetDependentOptions('Case', 'BillingCountry__c', 'BillingStateProvince__c'), null);
        
    }
}