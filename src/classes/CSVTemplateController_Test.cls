@isTest

Private Class CSVTemplateController_Test{
    static  Apttus_Proposal__Proposal__c apttus;
    static Apttus_Proposal__Proposal_Line_Item__c apttusLineItem;
    static Product2 prod;
    static testMethod void testBeforeInsert() {
        Test.startTest();
        prepareData();
        ApexPages.currentPage().getParameters().put('ProposalId', apttus.Id);
        CSVTemplateController controller = new CSVTemplateController();
        System.assert(controller.wc.size() > 0);
        // Other Scenario Where family = Resume
        prod.Family = 'Resume';
        update prod;        
        controller = new CSVTemplateController(); 
        System.assert(controller.wc.size() > 0);       
        Test.stopTest();
    }
    
    static void prepareData(){
     Account acc = TestDataSetupUtility.createTestAccount('test',null,null);
     insert acc;
     
     prod = new Product2(Name = 'Test-Product', isActive = true);
     insert prod;
     
     Opportunity opp = TestDataSetupUtility.createTestOpportunity('TestOpp', acc.Id);
     apttus = TestDataSetupUtility.createApttusProposal(opp);
     apttus.Apttus_Proposal__Account__c = acc.Id;
     insert apttus;
          
     apttusLineItem = TestDataSetupUtility.createProposalLineItem(apttus.Id);
     apttusLineItem.Apttus_Proposal__Product__c = prod.Id;
     apttusLineItem.Apttus_QPConfig__Quantity2__c = 3;
     insert apttusLineItem;
     
    }    
}