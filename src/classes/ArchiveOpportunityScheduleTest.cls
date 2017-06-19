@isTest
private class ArchiveOpportunityScheduleTest {

    static BatchUser__c batchuser;

    static testMethod void testBatch(){
        User usr = TestDataSetupUtility.createTestUser('Integration','MAPP',UserInfo.getProfileId());
        usr.FirstName =  'Integration';
        usr.LastName =  'MAPP';
        insert usr;

        User usr2 = TestDataSetupUtility.createTestUser('','',UserInfo.getProfileId());
        usr2.FirstName =  'Archive';
        usr2.LastName =  'Owner';
        insert usr2;

        batchuser = TestDataSetupUtility.createBatchUser(usr2.Id);
        insert batchUser;

        Test.startTest();
        System.runAs(usr){
        Id oppRT =  Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'Lead');
        Account acc = TestDataSetupUtility.createTestAccount('Test Account', 'North America', UserInfo.getUserId());
        insert acc;
        Contact con = TestDataSetupUtility.createTestContact(acc.Id, 'PrimaryBillingTestLastnameOne', 'PrimaryBillingTestFirstnameOne', 'email1@testContact.com');
        con.PrimaryBillingContact__c = true;
        insert con;
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('test',acc.Id);
        opp.InternationalDeal__c = true;
        opp.recordTypeId = oppRT;
        insert opp;

        Order__c order = new Order__c(Account__c=acc.Id,Opportunity__c=opp.Id,OrderStatus__c='Sent To Verification');
        order.BillingAccount__c = acc.id;
        order.ShippingAccount__c = acc.id;
        insert order;

        Opportunity opp2 = TestDataSetupUtility.createTestOpportunity('test1',acc.Id);
        opp2.InternationalDeal__c = true;
        opp2.recordTypeId = oppRT;
        Opportunity opp3 = TestDataSetupUtility.createTestOpportunity('test2',acc.Id);
        opp3.InternationalDeal__c = true;
        opp3.Organization__c = 'Asia Pacific';
        opp3.recordTypeId = oppRT;
        Opportunity opp4 = TestDataSetupUtility.createTestOpportunity('test3',null);
        opp4.InternationalDeal__c = true;
        opp4.recordTypeId = oppRT;
        Opportunity opp5 = TestDataSetupUtility.createTestOpportunity('test4',acc.Id);
        opp5.InternationalDeal__c = true;
        opp5.Organization__c = 'Europe';
        opp5.recordTypeId = oppRT;
        insert new List<Opportunity>{opp2, opp3, opp4, opp5};
         Apttus_Config2__PriceList__c price = TestDataSetupUtility.createPriceList('USD Price List', false);
        insert price;
        Apttus_Proposal__Proposal__c proposal = TestDataSetupUtility.createProposal('Test Proposal', acc.Id, opp.Id, 'Accepted Online', false);
        proposal.Apttus_QPConfig__PriceListId__c = price.id;
        proposal.Suppress_Invoice_Detail__c = 'Suppress Unit Price and Net Total Detail';
        insert proposal;
        Order__c ord = TestDataSetupUtility.createOrderWithOpportunity(acc.Id, opp.Id, null, con.Id);
        ord.SentToVerificationBy2__c = usr.Id  ;
        ord.OrderStatus__c = 'Sent To Verification';
        ord.BillingAccount__c = acc.id;
       // ord.BillingContact__c = con.id;
        ord.Posting_Contact__c = con.id;
        ord.QuoteProposal__c = proposal.Id;
        ord.ShippingAccount__c = acc.id;
        insert ord;
        Apttus_Proposal__Proposal__c testAPP = TestDataSetupUtility.createApttusProposal(opp);
        testAPP.Apttus_Proposal__Account__c = acc.Id;
        insert testAPP;
        ArchiveOpportunitySchedule batch = new ArchiveOpportunitySchedule();
        String sch = '0 0 23 * * ?';
        system.schedule('Test Check', sch, batch);
        }
        Test.stopTest();
    }

    //static testMethod void testArchiveOpportunityBatch(){
    //    ArchiveOpportunityBatch batch = new ArchiveOpportunityBatch();
    //    Database.executeBatch(batch);
    //}
}