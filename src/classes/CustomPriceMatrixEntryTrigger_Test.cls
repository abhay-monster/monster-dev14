@isTest

public class CustomPriceMatrixEntryTrigger_Test {
        
    // @author: Aakash Khatri
    static User manager, testUser;
    static Account account;
    static Apttus_Proposal__Proposal__c proposal_n;
    static Map<ID, List<Integer>> discreteDimNumbers;
    static Apttus_Config2__PriceMatrix__c config_price_m;
    static Apttus_Config2__PriceMatrix__c config_price_m2;
    static testMethod void testLineItems() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        insert manager;
        testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        testUser.Discount_Threshold__c  = 10.0;
        insert testuser;
        Personal_Settings__c ps = new Personal_Settings__c(SetupOwnerId=testuser.ID);
		ps.Trigger_PriceMatrixEntry__c  =true;    
		insert ps;
        Method_Kill_List__c testCustomSetting = new Method_Kill_List__c(Name='updateOpptySplit', Kill_Method__c=false);
        insert testCustomSetting;
        System.runAs(testUser){
            // Create test account
            account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
            account.Phone='+1234567890';
            system.debug('after account ' + account);
            AccountTriggerHandler.ExecuteTriggers=false;
            insert account;
            
            
            //create Opportunity
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', account.Id);
            opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'GCS Opportunity');
            insert opp;
            
            //Create product2
            Product2 product = TestDataSetupUtility.createProduct('Test product1', false); 
            product.Convert_From__c = true;
            insert product;
            
            Product2 product1 = TestDataSetupUtility.createProduct('Test Product2', false);
            product.Convert_From__c = true;
            insert product1;
            
            //Create price list
            Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
            insert priceList; 
            
            Apttus_Config2__PriceListItem__c pli = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 10, Apttus_Config2__ProductId__c = product.Id, Apttus_Config2__ChargeType__c = 'Standard Price');
            insert pli;
        
            // create Apttus_Config2__PriceDimension__c
            Apttus_Config2__PriceDimension__c new_pd = new Apttus_Config2__PriceDimension__c();
            new_pd.Name = 'With Talent Matching';
            new_pd.Apttus_Config2__Datasource__c = 'With_Talent_Matching__c';
            insert new_pd;
            
            // create Apttus_Config2__PriceMatrix__c
            config_price_m = new Apttus_Config2__PriceMatrix__c();
            config_price_m.Apttus_Config2__Sequence__c = 1;
            config_price_m.Apttus_Config2__PriceListItemId__c = pli.Id ;
            config_price_m.Apttus_Config2__Dimension1Id__c = new_pd.Id;
            config_price_m.Apttus_Config2__Dimension1ValueType__c = 'Discrete';
            config_price_m.Apttus_Config2__Dimension2Id__c = new_pd.Id;
            config_price_m.Apttus_Config2__Dimension2ValueType__c = 'Discrete';
            config_price_m.Apttus_Config2__Dimension3Id__c = new_pd.Id;
            config_price_m.Apttus_Config2__Dimension3ValueType__c = 'Discrete';
            config_price_m.Apttus_Config2__Dimension4Id__c = new_pd.Id;
            config_price_m.Apttus_Config2__Dimension4ValueType__c = 'Discrete';
            config_price_m.Apttus_Config2__Dimension5Id__c = new_pd.Id;
            config_price_m.Apttus_Config2__Dimension5ValueType__c = 'Discrete';
            config_price_m.Apttus_Config2__Dimension6Id__c = new_pd.Id;
            config_price_m.Apttus_Config2__Dimension6ValueType__c = 'Discrete';
            
            insert config_price_m;
            
            config_price_m2 = new Apttus_Config2__PriceMatrix__c();
            config_price_m2.Apttus_Config2__Sequence__c = 1;
            config_price_m2.Apttus_Config2__PriceListItemId__c = pli.Id ;
            insert config_price_m2;
            
            // create Apttus_Config2__PriceMatrixEntry__c
            Apttus_Config2__PriceMatrixEntry__c config_PME = new Apttus_Config2__PriceMatrixEntry__c();
            config_PME.Apttus_Config2__PriceMatrixId__c = config_price_m.Id;
            config_PME.Apttus_Config2__Sequence__c = 1;
            insert config_PME;
            
            Apttus_Config2__PriceMatrixEntry__c config_PME2 = new Apttus_Config2__PriceMatrixEntry__c();
            config_PME2.Apttus_Config2__PriceMatrixId__c = config_price_m2.Id;
            config_PME2.Apttus_Config2__Sequence__c = 1;
            insert config_PME2;
        
        }
         discreteDimNumbers = new Map<ID, List<Integer>>();           
         discreteDimNumbers.put(config_price_m2.id, new List<Integer>{1,2,3,4,5,6});
         discreteDimNumbers.put(config_price_m.id,new List<Integer>{1,2,3,4,5,6});             

        config_price_m.Apttus_Config2__Dimension6Id__c = null;
        update config_price_m;
            
    }
}