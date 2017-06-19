/*
@author : Rayson Landeta
@description : Test the MontersLinksComponentCC
@date : 06/5/2014
*/
@isTest
private class MonsterLinksComponentCCTest{
    static Account testAccount;
    static User testUser;
    /*
    @author : Rayson Landeta
    @description : Test the getLinks method
    @date : 06/5/2014
    */
    static testMethod void testOnGetLinks(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.TeamingChannel__c  = 'Partner';
        insert testuser;
    
        testAccount = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test ABC Account');
    
        insert testAccount;
        
        PageReference pageRef = Page.AccountAdvancedQuote;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',testAccount.id);
        
        MonsterLinksComponentCC mLinks = new MonsterLinksComponentCC();
        insert new Monster_links__c(Object_Name__c = 'Account', Name = 'TestLink',Link__c='{ACCOUNTADDRESS}',Country__c='General');
        
        
        //Account acc = new Account(Name = 'TestAccount', Organization__c = 'Europe', Account_Currency__c = 'USD - U.S. Dollar');
        //insert acc;
        Test.starttest();
            mLinks.getLinks();
      //      system.assertEquals(mLinks.monsterLinks[0].Name , 'Account'); 
        Test.stoptest();
    }
    
    static testMethod void testOnGetLinks1(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.TeamingChannel__c  = 'Partner';
        insert testuser;
        
        testAccount = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TEST PB Account');//, 'North America', UserInfo.getUserId());
        testAccount.Phone = '+18008008000';
        testAccount.BillingCountry = 'Philippines';
        testAccount.PrimaryServiceRep__c = testUser.id;
        testAccount.Organization__c = 'Europe';
        testAccount.ServiceTier__c = 'Core';
        insert testAccount;
        Contact testContact1 = TestDataSetupUtility.createTestContact(testAccount.Id, 'PrimaryBillingTestLastnameOne', 'PrimaryBillingTestFirstnameOne', 'email1@testContact.com');
        testContact1.PrimaryBillingContact__c = true;
        insert testContact1;
        
         Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opportunity', testAccount.Id); 
        insert opp;
        Order__c ord = TestDataSetupUtility.createOrderWithOpportunity(testAccount.Id, opp.Id, null);
        ord.SentToVerificationBy2__c = testUser.Id  ;
        ord.OrderStatus__c = 'Sent To Verification';
        ord.BillingAccount__c = testAccount.id;
        ord.BillingContact__c = testContact1.id; 
        ord.Posting_Contact__c = testContact1.id; 
        ord.ShippingAccount__c = testAccount.id;
        insert ord;
         Order_Line_Item__c oli = TestDataSetupUtility.createOrderLineItem(ord.Id); 
         insert oli;
           
        List<Case> childCaseList = new List<Case>();
           
        map<String, map<String, Id>> CaseRecordTypes = Utility.GetRecordTypeIdsBySObjectNameSet(new set<string>{'Case'});
        Id caseProductImplementationRecordTypeId = CaseRecordTypes.get('Case').get('Product Implementation');
        Id caseGCSRecordTypeId = CaseRecordTypes.get('Case').get('GCS');

        Case mainCase = new Case(
                AccountId = testAccount.Id,
                ContactId = testContact1.Id,
                Status = 'New',
                Category__c = 'Browser Issue',
                Issue__c = 'Other',
                SubIssue__c = 'Other',
                Subject = 'TEST Subject Parent',
                CustomerProblemDetail__c = 'TEST Details Parent' ,
                order__c = ord.id ,
                RecordTypeId = caseProductImplementationRecordTypeId                
            
            );

        insert mainCase;
        
        PageReference pageRef = Page.AccountAdvancedQuote;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id',mainCase.id);
        
        MonsterLinksComponentCC mLinks = new MonsterLinksComponentCC();
        
        
        insert new Monster_links__c(Object_Name__c = 'Case', Name = 'TestLink1',Link__c='{USERNAME}',Country__c='Germany');
        insert new Monster_links__c(Object_Name__c = 'Opportunity', Name = 'TestLink2',Link__c='{ACCOUNTADDRESS}',Country__c='Poland');
        insert new Monster_links__c(Object_Name__c = 'Case', Name = 'TestLink3',Link__c='{ACCOUNTADDRESS}',Country__c='Austria');
        insert new Monster_links__c(Object_Name__c = 'Case', Name = 'TestLink4',Link__c='{ACCOUNTADDRESS}',Country__c='UK');
        insert new Monster_links__c(Object_Name__c = 'Case', Name = 'TestLink5',Link__c='{ACCOUNTADDRESS}',Country__c='Brazil');
        insert new Monster_links__c(Object_Name__c = 'Case', Name = 'TestLink6',Link__c='{ACCOUNTADDRESS}',Country__c='Switzerland');
        insert new Monster_links__c(Object_Name__c = 'Case', Name = 'TestLink7',Link__c='{ACCOUNTADDRESS}',Country__c='Turkey');
        insert new Monster_links__c(Object_Name__c = 'Case', Name = 'TestLink8',Link__c='{ACCOUNTADDRESS}',Country__c='Russia');
        insert new Monster_links__c(Object_Name__c = 'Case', Name = 'TestLink9',Link__c='{ACCOUNTADDRESS}',Country__c='Slovakia');
        insert new Monster_links__c(Object_Name__c = 'Case', Name = 'TestLink10',Link__c='{ACCOUNTADDRESS}',Country__c='Ireland');
        insert new Monster_links__c(Object_Name__c = 'Case', Name = 'TestLink21',Link__c='{ACCOUNTADDRESS}',Country__c='Netherlands');
        insert new Monster_links__c(Object_Name__c = 'Case', Name = 'TestLink22',Link__c='{ACCOUNTADDRESS}',Country__c='Czech');
        insert new Monster_links__c(Object_Name__c = 'Case', Name = 'TestLink23',Link__c='{ACCOUNTADDRESS}',Country__c='Mexico');
        insert new Monster_links__c(Object_Name__c = 'Case', Name = 'TestLink24',Link__c='{ACCOUNTADDRESS}',Country__c='Sweden');
        insert new Monster_links__c(Object_Name__c = 'Case', Name = 'TestLink25',Link__c='{ACCOUNTADDRESS}',Country__c='Italy');
        insert new Monster_links__c(Object_Name__c = 'Case', Name = 'TestLink26',Link__c='{ACCOUNTADDRESS}',Country__c='France');
        insert new Monster_links__c(Object_Name__c = 'Case', Name = 'TestLink27',Link__c='{ACCOUNTADDRESS}',Country__c='Norway');
        insert new Monster_links__c(Object_Name__c = 'Case', Name = 'TestLink28',Link__c='{ACCOUNTADDRESS}',Country__c='latin America');
        insert new Monster_links__c(Object_Name__c = 'Case', Name = 'TestLink29',Link__c='{ACCOUNTADDRESS}',Country__c='Denmark');
        
        //Account acc = new Account(Name = 'TestAccount', Organization__c = 'Europe', Account_Currency__c = 'USD - U.S. Dollar');
        //insert acc;
        Test.starttest();
            mLinks.getLinks();
      //      system.assertEquals(mLinks.monsterLinks[0].Name , 'Account'); 
        Test.stoptest();
    }
}