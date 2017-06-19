@isTest
public class APTS_ApacTrigger_Test {
        // @author: Aakash Khatri
    static User manager, testUser;
    static Account account;
    static Apttus_Proposal__Proposal__c proposal_n;
    static testMethod void testLineItems() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        insert manager;
        testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        testUser.Discount_Threshold__c  = 10.0;
        insert testuser;
        
        System.runAs(testUser){
            // Create test account
            account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
            system.debug('after account ' + account);
            insert account;
            
            
            //create Opportunity
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', account.Id);
            opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'GCS Opportunity');
            insert opp;
            
            //Create product2
            Product2 product = TestDataSetupUtility.createProduct('Test product5', false); 
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
            
            //create proposal
            proposal_n = TestDataSetupUtility.createProposal('Test Proposal', account.Id, opp.Id, 'Accepted Online', false);
            proposal_n.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Apttus_Proposal__Proposal__c', 'Proposal');
            proposal_n.Apttus_QPConfig__PriceListId__c = priceList.id; 
            proposal_n.Language__c = 'English';
            system.debug('*****************:proposal ' + proposal_n.Language__c);

            insert proposal_n;  
            
            Apttus_Proposal__Proposal__c proposal_n1 = TestDataSetupUtility.createProposal('Test Proposal', account.Id, opp.Id, 'Accepted Online', false);
            proposal_n1.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Apttus_Proposal__Proposal__c', 'Proposal');
            proposal_n1.Apttus_QPConfig__PriceListId__c = priceList.id; 
            proposal_n1.Language__c = 'French';

            insert proposal_n1; 
            
        
            Apttus_Config2__ProductConfiguration__c config = TestDataSetupUtility.createTestProductConfig(proposal_n,account,priceList);
            config.Apttus_Config2__Status__c = 'Finalized';
            insert config;
            //System.debug('config:'+config);
        
            Apttus_Config2__LineItem__c aptusLineItem = TestDataSetupUtility.createLineItemApttus(config.Id);
            aptusLineItem.Apttus_Config2__StartDate__c=System.today();
            aptusLineItem.Apttus_Config2__EndDate__c=System.today()+60;
            aptusLineItem.Apttus_Config2__Comments__c='test';
            
            insert aptusLineItem;
            
            APTS_APAC_Payment__c apac = new APTS_APAC_Payment__c();
            //apac.Name = 'New APAC';
            apac.Proposal__c = proposal_n.Id;
            insert apac;
            
            apac.Payment_Amount__c = 100;
            update apac;
            
            delete apac;
            undelete apac;
            
            APTS_APAC_Payment__c apac2 = new APTS_APAC_Payment__c();
            //apac2.Name = 'New APAC2';
            apac2.Proposal__c = proposal_n.Id;
            upsert apac2;
            
            apac2.Payment_Amount__c = 100;
            update apac2;
            
            delete apac2;
            undelete apac2;
            
            
        } 
    }
}