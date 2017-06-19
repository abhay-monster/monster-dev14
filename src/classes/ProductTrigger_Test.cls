@isTest

Private Class ProductTrigger_Test{
    static Product2 prod;
    static testmethod void testProductTrigger(){
        
        Test.startTest();
        prepareData();
        ProductTriggerHelper helper = ProductTriggerHelper.NewTriggerHelper();
        helper.Sellingcountry_Expand(new List<Product2>{prod});        
        prod = [ Select Id,Eligible_Selling_Country__c ,Eligible_Selling_Country_New__c from Product2 Where Id = :prod.Id ];
        System.assert(prod.Eligible_Selling_Country_New__c != null );
        prod.Eligible_Selling_Country__c= null;
        update prod;
        helper.Sellingcountry_Expand(new List<Product2>{prod});        
        System.assert(prod.Eligible_Selling_Country_New__c == null );
        delete prod;
        
        undelete prod;
        Test.stopTest();
    }
    
    static void prepareData(){
     Account acc = TestDataSetupUtility.createTestAccount('test',null,null);
     insert acc;
     
     prod = TestDataSetupUtility.createProduct('test', false);
     prod.Product_Line__c = 'Job Accessories--Inventory';
     prod.Family= 'Resume';  
     prod.Eligible_Selling_Country__c = 'Canada;France';  
     insert prod;
     
     
    } 

}