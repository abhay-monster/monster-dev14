@isTest
private class ArchiveAccountScheduleTest {

  static BatchUser__c batchuser;

  static testMethod void testBatch(){
    User usr = TestDataSetupUtility.createTestUser('Integration','MAPP',UserInfo.getProfileId());
        usr.FirstName =  'Integration';
        usr.LastName =  'MAPP';
        insert usr;
      	system.debug('Insert userMapp');

        User usr2 = TestDataSetupUtility.createTestUser('','',UserInfo.getProfileId());
        usr2.FirstName =  'Archive';
        usr2.LastName =  'Owner';
        insert usr2;
      	system.debug('Insert usr2');
      
        User usr3 = TestDataSetupUtility.createTestUser('','',UserInfo.getProfileId());
        usr3.FirstName =  null;
        usr3.LastName =  'APAC_DEL';
        insert usr3;
        batchuser = TestDataSetupUtility.createBatchUser(usr2.Id);
        insert batchUser;
      	system.debug('Insert batchUser');
      
              User usr4 = TestDataSetupUtility.createTestUser('','',UserInfo.getProfileId());
        usr4.FirstName =  null;
        usr4.LastName =  'INACIVE';
        insert usr4;
      	system.debug('Insert usr4');
      

        Test.startTest();
       
            list<account> lstAccountToinsert = new list<account>();
        Account acc = TestDataSetupUtility.createTestAccount('Test Account', 'North America', UserInfo.getUserId());
            insert acc;
      		system.debug('Insert acc');

         System.runAs(usr3){
            Account acc2 = TestDataSetupUtility.createTestAccount('Test Account2', 'North America', UserInfo.getUserId());
            acc2.AccountStatus__c = 'Candidate';
            acc2.CreditStatus__c = 'OK';
             acc2.OwnerId = usr3.id;
            insert acc2;
            system.debug('Account2 created');
         }
            
       
       System.runAs(usr){
       Contact con = TestDataSetupUtility.createTestContact(acc.Id, 'PrimaryBillingTestLastnameOne', 'PrimaryBillingTestFirstnameOne', 'email1@testContact.com');
        con.PrimaryBillingContact__c = true;
        insert con;
        system.debug('Inserted contact');

       Opportunity opp = TestDataSetupUtility.createTestOpportunity('test',acc.Id);
      opp.InternationalDeal__c = true;
      insert opp;
      system.debug('Inserted opportunity');

       Apttus_Config2__PriceList__c price = TestDataSetupUtility.createPriceList('USD Price List', false);
        insert price;
        system.debug('Inserted Price');

      Apttus_Proposal__Proposal__c proposal = TestDataSetupUtility.createProposal('Test Proposal', acc.Id, opp.Id, 'Accepted Online', false);
        proposal.Apttus_QPConfig__PriceListId__c = price.id;
        proposal.Suppress_Invoice_Detail__c = 'Suppress Unit Price and Net Total Detail';
        insert proposal;
        system.debug('Insert Proposal');
           
        /*System.runAs(usr4){//T-566440 erroring due to duplicate record if the below code is uncommented
            Account acc1 = TestDataSetupUtility.createTestAccount('Test Account1', 'North America', UserInfo.getUserId());
            acc1.AccountStatus__c = 'Out of Business';
            acc1.CreditStatus__c = 'OK';
            acc1.OwnerId = usr3.id;
            insert acc1;
            system.debug('Account1 created');
            
      Apttus_Proposal__Proposal__c proposal1 = TestDataSetupUtility.createProposal('Test Proposal', acc1.Id, opp.Id, 'Accepted Online', false);
        proposal1.Apttus_QPConfig__PriceListId__c = price.id;
        proposal1.Suppress_Invoice_Detail__c = 'Suppress Unit Price and Net Total Detail';
        insert proposal1; 
        system.debug('Insert proposal1');
        }*/
           

           
            
            Order__c o = new Order__c();
            o.OrderStatus__c = 'Verified';
            o.OrderDate__c = Date.today().addMonths(-11);
            o.Account__c = proposal.Apttus_Proposal__Account__c;
            o.QuoteProposal__c = proposal.Id;
            o.Opportunity__c =proposal.Apttus_Proposal__Opportunity__c;
            o.BillingAccount__c = o.Account__c;
            o.ShippingAccount__c = o.Account__c;
            
            insert o;
            
 Order_Line_Item__c test_OrderLineItem = new Order_Line_Item__c (
        Order__c = o.Id , EndDate__c = system.today()+1

        );

        insert test_OrderLineItem;            
            
            Event evnt = new Event(WhatId = acc.Id,EventStatus__c = 'Open',DurationInMinutes=12,ActivityDateTime = Date.today());
            insert evnt; 
           system.debug('Insert evnt');
           Case mainCase = new Case(
                AccountId = acc.Id,
                ContactId = con.Id,
                Status = 'New',
                Category__c = 'Browser Issue',
                Issue__c = 'Other',
                SubIssue__c = 'Other',
                Subject = 'TEST Subject Parent',
                CustomerProblemDetail__c = 'TEST Details Parent' ,
                Order__c = o.id ,
                Quote_SellingCountry__c =  'Germany',
                Proposal_ID__c = proposal.Id
               // RecordTypeId = caseProductImplementationRecordTypeId
            );

            insert mainCase;
           system.debug('Insert maincase');
            
            

      ArchiveAccountSchedule batch = new ArchiveAccountSchedule();
      String sch = '0 0 23 * * ?';
    system.schedule('Test Check 17', sch, batch);
        
        Test.stopTest();
  }
}
}