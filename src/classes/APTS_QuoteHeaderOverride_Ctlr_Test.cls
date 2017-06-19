@isTest
Private Class APTS_QuoteHeaderOverride_Ctlr_Test{

    static Apttus_Proposal__Proposal__c proposal;
    static Apttus_Proposal__Proposal__c proposal1;
    static testmethod void testAPTS_QuoteHeaderOverride_Ctlr(){
        prepareData();
        Test.startTest();
        ApexPages.StandardController std = new ApexPages.StandardController(proposal );
        APTS_QuoteHeaderOverride_Ctlr ctrl = new APTS_QuoteHeaderOverride_Ctlr(std );
        //system.assert(ctrl.proposalSO != null);
        ctrl.doRedirect();
        ctrl.submitforApprovalswithComment();
        
        
       
        std = new ApexPages.StandardController(proposal1);
        ctrl = new APTS_QuoteHeaderOverride_Ctlr(std );
        ctrl.doRedirect(); 
        
        Test.stopTest(); 
    }
    
    static void prepareData(){
     Account acc = TestDataSetupUtility.createTestAccount('test',null,null);
     insert acc;
     Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test-Opp', acc.Id);
     insert opp;
     
     proposal = TestDataSetupUtility.createProposal('Test Proposal', acc.Id, opp.Id, 'Accepted Online', false);
     //proposal.Apttus_QPConfig__PriceListId__c = price.id;
     proposal.APTS_Enforce_Rollup_Summary_Calc__c = true;
     
     proposal1 = TestDataSetupUtility.createProposal('Test Proposal', acc.Id, opp.Id, 'Accepted Online', false);
     //proposal.Apttus_QPConfig__PriceListId__c = price.id;
     proposal1.APTS_Enforce_Rollup_Summary_Calc__c = true;
     proposal1.APTS_Fire_Approvals__c = true;
     insert (new List<Apttus_Proposal__Proposal__c>{proposal,proposal1});
     
     Apttus_Proposal__Proposal_Line_Item__c lineitem = TestDataSetupUtility.createProposalLineItem(proposal.Id);
     lineitem.Apttus_QPConfig__OptionPrice__c = null;
     lineitem.Apttus_QPConfig__LineStatus__c = 'New';
     lineitem.APTS_Is_Agency_Commission_Different__c = 1;
     lineitem.Apttus_QPConfig__NetPrice__c = 10000;
      lineitem.APTS_Extended_List_Price__c= 100;
      lineitem.Apttus_QPConfig__BaseExtendedPrice__c = 1;
      
      
      Apttus_Proposal__Proposal_Line_Item__c lineitem1 = TestDataSetupUtility.createProposalLineItem(proposal1.Id);
     lineitem1.Apttus_QPConfig__OptionPrice__c = null;
     lineitem1.Apttus_QPConfig__LineStatus__c = 'New';
     lineitem1.APTS_Is_Agency_Commission_Different__c = 1;
     lineitem1.Apttus_QPConfig__NetPrice__c = 10000;
      lineitem1.APTS_Extended_List_Price__c= 100;
      lineitem1.Apttus_QPConfig__BaseExtendedPrice__c = 1;
     insert (new List<Apttus_Proposal__Proposal_Line_Item__c>{lineitem,lineitem1}) ;
     
    } 
    

}