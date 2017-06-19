@isTest

Private Class PropProdAttributeValueTriggerTest{
    static Apttus_QPConfig__ProposalProductAttributeValue__c ProposalProductAttr;
    static Apttus_Proposal__Proposal_Line_Item__c lineItem;
    static testmethod void testPropProdAttributeValueTrigger(){

        prepareData();

        Test.startTest();
        // Verify that Proposal line item posting location updated by Apttus_QPConfig__ProposalProductAttributeValue__c object
        lineItem = [SELECT Id, PostingLocation__c FROM Apttus_Proposal__Proposal_Line_Item__c WHERE Id = :lineItem.Id];
        ProposalProductAttr = [SELECT Id, Posting_Locations__c FROM Apttus_QPConfig__ProposalProductAttributeValue__c
                               WHERE Id = :ProposalProductAttr.Id];

        System.assertEquals(lineItem.PostingLocation__c ,ProposalProductAttr.Posting_Locations__c );

        // When we update record the line item should be updated with posting location
        ProposalProductAttr.Posting_Locations__c = 'Global';
        update ProposalProductAttr;

        lineItem = [SELECT Id, PostingLocation__c FROM Apttus_Proposal__Proposal_Line_Item__c WHERE Id = :lineItem.Id];
        ProposalProductAttr = [SELECT Id, Posting_Locations__c FROM Apttus_QPConfig__ProposalProductAttributeValue__c
                               WHERE Id = :ProposalProductAttr.Id];

        System.assertEquals(lineItem.PostingLocation__c ,ProposalProductAttr.Posting_Locations__c );

        Test.stopTest();
    }

    static void prepareData(){
     Account acc = TestDataSetupUtility.createTestAccount('test',null,null);
     insert acc;

     Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', acc.Id);
     insert opp;

     Apttus_Proposal__Proposal__c proposal = TestDataSetupUtility.createApttusProposal(opp);
     insert proposal;

        Product2 prod= TestDataSetupUtility.createProduct('Test', false);
        prod.Messaging__c = true;
        insert prod;

     lineItem= TestDataSetupUtility.createProposalLineItem(Proposal.Id);
        lineItem.Apttus_Proposal__Product__c = prod.Id;
     insert lineItem;

     ProposalProductAttr = new Apttus_QPConfig__ProposalProductAttributeValue__c ();
     ProposalProductAttr.Apttus_QPConfig__LineItemId__c = lineItem.Id;
     ProposalProductAttr.Posting_Locations__c = 'Europe';
     insert ProposalProductAttr;
    }

}