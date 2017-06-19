//
// (c) 2015 Appirio, Inc.
//
//  Test class for AccountAdvancedQuoteCtrl
//
// May 22, 2015     Harshit Jain       Original 
//
@isTest
public with sharing class AccountAdvancedQuoteCtrlTest {
    static Account account;
    static Apttus_Proposal__Proposal__c proposal;
    
    static testMethod void testAccountAdvanceQuote() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = [select id,alias from User where ProfileId =: p.Id and isActive = true limit 1];
        
        System.runAs(u) {        
            Test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(account);
            AccountAdvancedQuoteCtrl accountAdvanceQuoteObj = new AccountAdvancedQuoteCtrl(sc);
            
            PageReference pageRef = Page.AccountAdvancedQuote;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('radioSelectValue',proposal.id);
            
            list<SelectOption> selectOption = accountAdvanceQuoteObj.actionList;
            accountAdvanceQuoteObj.selectedAction = AccountAdvancedQuoteHelper.ProductConversion;
            accountAdvanceQuoteObj.onSelectAction();
            
            system.assertNotEquals(null, accountAdvanceQuoteObj.outputHTMLTable);
            
            accountAdvanceQuoteObj.selectQuoteID();
            accountAdvanceQuoteObj.onClickNext();
            accountAdvanceQuoteObj.onClickCancel();
            
            //Validate with renewal - relevant record not created
            accountAdvanceQuoteObj.selectedAction = AccountAdvancedQuoteHelper.MidContractQuote;
            accountAdvanceQuoteObj.onSelectAction();
            accountAdvanceQuoteObj.onClickNext();
            accountAdvanceQuoteObj.onClickCancel();
            system.assertEquals('', accountAdvanceQuoteObj.outputHTMLTable);
            Test.stopTest();
        }
    }
    
    
    static {
        // Create test account
        account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        system.debug('after account ' + account);
        insert account;
        
        
        //create Opportunity
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', account.Id);
        opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'Opportunity');
        insert opp;
        
        //Create product2
        Product2 product = TestDataSetupUtility.createProduct('Test product', false);
        product.Convert_From__c = true;
        product.Service_Type__c = 'Usage';
        product.Product_Extension_Eligible__c = true;
        insert product;
        
        //Create price list
        Apttus_Config2__PriceList__c price = TestDataSetupUtility.createPriceList('USD Price List', false);
        insert price; 
        
        //create proposal
        proposal = TestDataSetupUtility.createProposal('Test Proposal', account.Id, opp.Id, 'Accepted Online', false);
        proposal.Apttus_QPConfig__PriceListId__c = price.id;
        insert proposal;
        
        //create AssetLineItem
        Apttus_Config2__AssetLineItem__c assetLineItem = TestDataSetupUtility.createAssetLineItem('Test asset', account.Id, false);
        assetLineItem.Proposal__c = proposal.Id;
        assetLineItem.Apttus_Config2__ProductId__c = product.id;
        assetLineItem.Apttus_Config2__StartDate__c = Date.Today() - 10;
        assetLineItem.Apttus_Config2__EndDate__c  = Date.Today().addDays(70);
        insert assetLineItem;
        
        //create Apttus_Config2__AssetLineItem__c 
        Apttus_Config2__AssetLineItem__c assetConfigLineItems = TestDataSetupUtility.createAssetLineItem('Test 1 ' ,account.Id ,False );
            Product2 prodProduct =TestDataSetupUtility.createProduct('Testp' , false);
            prodProduct.Convert_From__c = true;
            prodProduct.Product_Extension_Eligible__c = true;
            insert prodProduct;
        assetConfigLineItems.Apttus_Config2__StartDate__c = Date.Today() - 5;
        assetConfigLineItems.Apttus_Config2__EndDate__c = date.today() +120 ;
        assetConfigLineItems.Apttus_Config2__ProductId__c = prodProduct.id;
        assetConfigLineItems.Proposal__c = proposal.id;
        insert assetConfigLineItems;
    }
}