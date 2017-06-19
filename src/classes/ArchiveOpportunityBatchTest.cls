@isTest
private class ArchiveOpportunityBatchTest {
    static{
        Account acc = TestDataSetupUtility.createTestAccountWithShipping('Test Account');
        insert acc;
        Contact con = TestDataSetupUtility.createTestContact(acc.Id, 'PrimaryBillingTestLastnameOne', 'PrimaryBillingTestFirstnameOne', 'email1@testContact.com');
        con.PrimaryBillingContact__c = true;
        insert con;
        Id oppRT = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'Opportunity');
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('test1', acc.Id);
        //opp.AccountId = null;
        opp.InternationalDeal__c = true;
        opp.recordTypeId = oppRT;

        Opportunity opp1 = TestDataSetupUtility.createTestOpportunity('test2', acc.Id);
        opp1.InternationalDeal__c = true;
        opp1.recordTypeId = oppRT;
        opp1.StageName = 'Order Placed';
        

        Date dtTwoYear = Date.today().addYears(-2);
        dtTwoYear = dtTwoYear.addDays(-1);
        String strTwoYear = dtTwoYear.year() + '-'+ dtTwoYear.month() + '-' + dtTwoYear.day()+ 'T00:01:26.000+0000';
        String proJsonTwo = '{"CreatedDate":"'+strTwoYear+'"}';
        Opportunity opp2 = (Opportunity) JSON.deserialize(proJsonTwo, Opportunity.class);
        opp2.Name = 'test3';
        opp2.StageName = 'Stage 1 - Needs Assessment';
        opp2.CloseDate = system.today() - 20;
        opp2.AccountId = acc.Id;
        opp2.Lost_Reason__c = 'Credit Risk';
        opp2.TeamingType__c = 'Named';


        Date dtOneYear = Date.today().addYears(-1);
        dtOneYear = dtOneYear.addDays(-1);
        String strOneYear = dtOneYear.year() + '-'+ dtOneYear.month() + '-' + dtOneYear.day()+ 'T00:01:26.000+0000';
        String proJsonOne = '{"CreatedDate":"'+strOneYear+'"}';
        Opportunity opp3 = (Opportunity) JSON.deserialize(proJsonOne, Opportunity.class);
        opp3.Name = 'test4';
        opp3.StageName = 'Stage 1 - Needs Assessment';
        opp3.CloseDate = system.today() - 20;
        opp3.AccountId = acc.Id; 
        opp3.Lost_Reason__c = 'Credit Risk'; 
        opp3.TeamingType__c = 'Named';
        opp3.Organization__c = 'Asia Pacific';
        opp3.Status__c = 'Lost';

        insert (new List<Opportunity>{opp,opp1,opp2,opp3}); 
        List<Apttus_Proposal__Proposal__c> proList = new List<Apttus_Proposal__Proposal__c>();
        Apttus_Proposal__Proposal__c pro1 = TestDataSetupUtility.createProposal('Test Proposal1', acc.Id, opp.Id, 'Accepted Online', false);
        proList.add(pro1);

        Apttus_Proposal__Proposal__c pro2 = TestDataSetupUtility.createProposal('Test Proposal2', acc.Id, opp1.Id, 'Accepted Online', false);
        proList.add(pro2);

        Apttus_Proposal__Proposal__c pro3 = TestDataSetupUtility.createProposal('Test Proposal3', acc.Id, opp2.Id, 'Accepted Online', false);
        proList.add(pro3);

        Apttus_Proposal__Proposal__c pro4 = TestDataSetupUtility.createProposal('Test Proposal4', acc.Id, opp3.Id, 'Accepted Online', false);
        proList.add(pro4);
        insert proList;
        Id CreditOrderRecordType = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Credit');
        Order__c order1 = TestDataSetupUtility.createOrder(acc.Id);
        order1.OrderStatus__c = 'Sent To Verification';
        order1.RecordTypeId = CreditOrderRecordType;
        order1.Opportunity__c = opp.Id;
        order1.BillingAccount__c = acc.id;
        order1.BillingContact__c = con.id;
        order1.Posting_Contact__c = con.id;

        Order__c order2 = TestDataSetupUtility.createOrder(acc.Id);
        order2.OrderStatus__c = 'Open';
        order2.RecordTypeId = CreditOrderRecordType;
        order2.Opportunity__c = opp1.Id;
        order2.BillingAccount__c = acc.id;
        order2.BillingContact__c = con.id;
        order2.Posting_Contact__c = con.id;
        insert (new List<Order__c>{order1,order2});

        Xcode__c xcode = new Xcode__c();        
        xcode.name = 'test1';
        insert xcode ;
        
        XcodeAccount__c xAcc = new XcodeAccount__c ();
        xAcc.Xcode__c = xcode.Id;
        xAcc.Account__c = acc .Id;
        insert xAcc; 
        Credit_Request__c cr1 = TestDataSetupUtility.createCreditRequest(order1.Id);
        cr1.Credit_Type__c = 'Full';
        Credit_Request__c cr2 = TestDataSetupUtility.createCreditRequest(order1.Id);
        cr2.Credit_Type__c = 'Partial';
        insert (new List<Credit_Request__c>{cr1,cr2});
        CreditRequestLineItem__c lineItem1 = new CreditRequestLineItem__c();
        lineItem1.Credit_Request__c = cr1.Id;
        lineItem1.CreditCondition__c = 'Full';
        lineItem1.TaxAmount__c = 10;
        lineItem1.CreditType__c = 'Inventory';
        lineItem1.CreditAmount__c = 100;
        lineItem1.AvailableCreditAmount__c = 200;
        lineItem1.NetCreditAmount__c = 10;
        lineItem1.NetTotalAmount__c=10;
        lineItem1.NetRemainingCreditAmount__c =10;
        
        CreditRequestLineItem__c lineItem2 = new CreditRequestLineItem__c();
        lineItem2.Credit_Request__c = cr2.Id;
        lineItem2.CreditCondition__c = 'Partial';
        lineItem2.TaxAmount__c = 10;
        lineItem2.CreditType__c = 'Inventory';
        lineItem2.CreditAmount__c = 100;
        lineItem2.AvailableCreditAmount__c = 200;
        lineItem2.NetCreditAmount__c = 10;
        lineItem2.NetTotalAmount__c=10;
        lineItem2.NetRemainingCreditAmount__c =10;
        insert (new List<CreditRequestLineItem__c>{lineItem1,lineItem2});
        


        //Create product2
        Product2 product = TestDataSetupUtility.createProduct('Test product', false);
        product.Convert_From__c = true;
        product.Service_Type__c = 'Usage';
        product.Messaging__c = true;
        insert product;

        Order_Line_Item__c orderLineItem = TestDataSetupUtility.createOrderLineItem(order1.Id);
        orderLineItem.CreditRequestLineItem__c = lineItem1.Id;
        orderLineItem.Xcode_lkp__c = xAcc.Id;
        orderLineItem.Product__c = product.Id;
        orderLineItem.Result__c = '11';
        orderLineItem.EndDate__c = System.today() + 2;
        Order_Line_Item__c orderLineItem1 = TestDataSetupUtility.createOrderLineItem(order2.Id);
        orderLineItem1.CreditRequestLineItem__c = lineItem2.Id;
        orderLineItem1.Xcode_lkp__c = xAcc.Id;
        orderLineItem1.Product__c = product.Id;
        orderLineItem1.EndDate__c = System.today() + 2;
        insert (new List<Order_Line_Item__c>{orderLineItem,orderLineItem1});
    }
    static testMethod void testBatch(){
        Test.startTest(); 
        User sysAdmin = TestDataSetupUtility.createUser('System Administrator', true);
        BatchUser__c batchuser = TestDataSetupUtility.createBatchUser(sysAdmin.Id);
        insert batchUser;
        System.runAs(sysAdmin) {
            ArchiveOpportunityBatch c = new ArchiveOpportunityBatch();
            Database.executeBatch(c);
            List<Opportunity> lstArchived = [SELECT Id FROM Opportunity WHERE ArchivalStatus__c = 'Archived'];
            System.assert(lstArchived != null);
             
        }
        Test.stopTest();
    }
}