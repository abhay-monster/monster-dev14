/*------------------------------------------------------------------------------
Author:        Siddharth Varshneya
Company:       Appirio
Description:   Test class to test CreateCreditOrderCC class
------------------------------------------------------------------------------*/
@isTest
private class TestCreateCreditOrderCC {

   static testMethod void testCreateCredit(){
        Account acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        insert acc;
        
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp ', acc.Id);
        insert opp;
        
        OpportunityCompetitor__c competitor = TestDataSetupUtility.createOpportunityCompetitor(opp);
        insert competitor;
        
        Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c();
        proposal.Apttus_Proposal__Account__c = acc.Id;
        insert proposal;
        
        Apttus_Proposal__Proposal_Line_Item__c pli = new Apttus_Proposal__Proposal_Line_Item__c();
        pli.Apttus_Proposal__Proposal__c = proposal.Id;
        insert pli;
        
        
        Order__c originalOrder = new Order__c();
        originalOrder.Account__c = acc.Id;
        originalOrder.Opportunity__c = opp.Id;
        originalOrder.QuoteProposal__c = proposal.Id;
        insert originalOrder;
        
        Order_Line_Item__c oli = new Order_Line_Item__c();
        oli.Order__c =  originalOrder.Id;
        insert oli;
        
        Line_Item_Attribute__c attr = new Line_Item_Attribute__c();
        attr.Order_Line_Item__c = oli.Id;
        attr.LineItemId__c = pli.Id;
        insert attr;
        
        System.PageReference clonePage = Page.CreateCreditOrder;        
        clonePage.getParameters().put('size', '1');
        clonePage.getParameters().put('Full', '11');
        clonePage.getParameters().put('li0', oli.Id);
        
        Test.setCurrentPage(clonePage);
        
        Test.startTest();
        CreateCreditOrderCC cc = new CreateCreditOrderCC();
        cc.init(originalOrder.id,'Credit');  
        cc.cloneOrder();
        cc.handleUniqueProcessBefore();
        Test.stopTest();
    }
    
    static testMethod void testCreateCredit1(){
        Account acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        insert acc;
        
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp ', acc.Id);
        insert opp;
        
        OpportunityCompetitor__c competitor = TestDataSetupUtility.createOpportunityCompetitor(opp);
        insert competitor;
        
        Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c();
        proposal.Apttus_Proposal__Account__c = acc.Id;
        insert proposal;
        
        Apttus_Proposal__Proposal_Line_Item__c pli = new Apttus_Proposal__Proposal_Line_Item__c();
        pli.Apttus_Proposal__Proposal__c = proposal.Id;
        insert pli;
        
        
        Order__c originalOrder = new Order__c();
        originalOrder.Account__c = acc.Id;
        originalOrder.Opportunity__c = opp.Id;
        originalOrder.QuoteProposal__c = proposal.Id;
        insert originalOrder;
        
        Order_Line_Item__c oli = new Order_Line_Item__c();
        oli.Order__c =  originalOrder.Id;
        insert oli;
        
        Line_Item_Attribute__c attr = new Line_Item_Attribute__c();
        attr.Order_Line_Item__c = oli.Id;
        attr.LineItemId__c = pli.Id;
        insert attr;
        
        System.PageReference clonePage = Page.CreateCreditOrder;        
        clonePage.getParameters().put('size', '1');
        clonePage.getParameters().put('TaxOnly', '11');
        clonePage.getParameters().put('li0', oli.Id);
        
        Test.setCurrentPage(clonePage);
        
        Test.startTest();
        CreateCreditOrderCC cc = new CreateCreditOrderCC();
        cc.init(originalOrder.id,'Credit');  
        cc.cloneOrder();
        cc.handleUniqueProcessBefore();
        Test.stopTest();
    }
    
    static testMethod void testCreateCredit2(){
        Account acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        insert acc;
        
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp ', acc.Id);
        insert opp;
        
        OpportunityCompetitor__c competitor = TestDataSetupUtility.createOpportunityCompetitor(opp);
        insert competitor;
        
        Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c();
        proposal.Apttus_Proposal__Account__c = acc.Id;
        insert proposal;
        
        Apttus_Proposal__Proposal_Line_Item__c pli = new Apttus_Proposal__Proposal_Line_Item__c();
        pli.Apttus_Proposal__Proposal__c = proposal.Id;
        insert pli;
        
        
        Order__c originalOrder = new Order__c();
        originalOrder.Account__c = acc.Id;
        originalOrder.Opportunity__c = opp.Id;
        originalOrder.QuoteProposal__c = proposal.Id;
        insert originalOrder;
        
        Order_Line_Item__c oli = new Order_Line_Item__c();
        oli.Order__c =  originalOrder.Id;
        insert oli;
        
        Line_Item_Attribute__c attr = new Line_Item_Attribute__c();
        attr.Order_Line_Item__c = oli.Id;
        attr.LineItemId__c = pli.Id;
        insert attr;
        
        System.PageReference clonePage = Page.CreateCreditOrder;        
        clonePage.getParameters().put('size', '1');
        clonePage.getParameters().put('Partial', 'Amount');
        clonePage.getParameters().put('li0', oli.Id);
        
        Test.setCurrentPage(clonePage);
        
        Test.startTest();
        CreateCreditOrderCC cc = new CreateCreditOrderCC();
        cc.init(originalOrder.id,'Credit');  
        cc.cloneOrder();
        cc.handleUniqueProcessBefore();
        Test.stopTest();
    }
    
    static testMethod void testCreateCredit3(){
        Account acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        insert acc;
        
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp ', acc.Id);
        insert opp;
        
        OpportunityCompetitor__c competitor = TestDataSetupUtility.createOpportunityCompetitor(opp);
        insert competitor;
        
        Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c();
        proposal.Apttus_Proposal__Account__c = acc.Id;
        insert proposal;
        
        Apttus_Proposal__Proposal_Line_Item__c pli = new Apttus_Proposal__Proposal_Line_Item__c();
        pli.Apttus_Proposal__Proposal__c = proposal.Id;
        insert pli;
        
        
        Order__c originalOrder = new Order__c();
        originalOrder.Account__c = acc.Id;
        originalOrder.Opportunity__c = opp.Id;
        originalOrder.QuoteProposal__c = proposal.Id;
        insert originalOrder;
        
        Order_Line_Item__c oli = new Order_Line_Item__c();
        oli.Order__c =  originalOrder.Id;
        insert oli;
        
        Line_Item_Attribute__c attr = new Line_Item_Attribute__c();
        attr.Order_Line_Item__c = oli.Id;
        attr.LineItemId__c = pli.Id;
        insert attr;
        
        System.PageReference clonePage = Page.CreateCreditOrder;        
        clonePage.getParameters().put('size', '1');
        clonePage.getParameters().put('Partial', 'Inventory');
        clonePage.getParameters().put('li0', null);
        
        Test.setCurrentPage(clonePage);
        
        Test.startTest();
        CreateCreditOrderCC cc = new CreateCreditOrderCC();
        cc.init(originalOrder.id,'Credit');  
        cc.cloneOrder();
        cc.handleUniqueProcessBefore();
        Test.stopTest();
    }
    
}