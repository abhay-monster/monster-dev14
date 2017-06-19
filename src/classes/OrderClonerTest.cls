@isTest
public with sharing class OrderClonerTest {
    
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
        clonePage.getParameters().put('li0', oli.Id);
        
        Test.setCurrentPage(clonePage);
        
        Test.startTest();
        CreateCreditOrderCC cc = new CreateCreditOrderCC();
        cc.cloneOrder();
        Test.stopTest();
    }
    
    static testMethod void testAdjustment(){
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
        
        System.PageReference clonePage = Page.AdjustmentOrder;      
        clonePage.getParameters().put('id', originalOrder.Id);
        
        Test.setCurrentPage(clonePage);
        
        Test.startTest();
        AdjustmentOrderCC cc = new AdjustmentOrderCC();
        cc.cloneOrder();
        Test.stopTest();
        
        cc.handleUniqueProcessBefore();
    }
    
    static testMethod void testNegate(){
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
        
        System.PageReference clonePage = Page.NegateOrder;      
        clonePage.getParameters().put('id', originalOrder.Id);
        
        Test.setCurrentPage(clonePage);
        
        Test.startTest();
        NegateOrderCC cc = new NegateOrderCC();
        cc.cloneOrder();
        cc.getChangeTypeVal();
        cc.ChangeTypeLabel = 'Negate';
        cc.Save();
        Test.stopTest(); 
    }
    
    static testMethod void testReBill(){
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
        
        //System.PageReference clonePage = Page.CreateReBill;
        //ApexPages.CurrentPage().getparameters().put('oppId', newOpportunity.id);
        //ApexPages.StandardController sc = new ApexPages.standardController(newOpportunity);       
        ApexPages.CurrentPage().getParameters().put('oppName', opp.Name);
        ApexPages.CurrentPage().getParameters().put('quoteName', proposal.Name);
        ApexPages.CurrentPage().getParameters().put('orderId', originalOrder.Id);
        ApexPages.StandardController sc = new ApexPages.standardController(originalOrder); 
        //Test.setCurrentPage(clonePage);
        Test.startTest();
        CreateReBillCC cc = new CreateReBillCC(sc);
        cc.executeMethod();
        Test.stopTest();
    } 
}