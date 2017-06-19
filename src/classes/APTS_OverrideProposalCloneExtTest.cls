/* 
* Class Name  : APTS_OverrideProposalCloneExtTest
* Description : Extension for APTS_OverrideProposalCloneExtTest
              : test class for the APTS_OverrideProposalCloneExt.
* Created By  : Viraj Rana
* Created On  : 11/28/2016
*
* Modification log:                                                                       
*/ 

@isTest()
public with sharing class APTS_OverrideProposalCloneExtTest{
    
    static testMethod void testAPTS_OverrideProposalCloneExtTest(){
        Apttus_Proposal__Proposal__c proposal = null;
        Account acct = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TestAcct_28_07_15');
        insert acct;
        Contact con = TestDataSetupUtility.createTestContact(acct.Id, 'Test_Last', 'Test_First', 'test@test.com');
        insert con;
        
       //create Opportunity
       Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', acct.Id);
       opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'GCS Opportunity');
       insert opp;
            
       proposal = TestDataSetupUtility.createProposal('TEST_PROP_28_07_15', acct.Id, opp.Id, 'test', false);
       
       insert proposal;
        
       //Create product2
       Product2 product = TestDataSetupUtility.createProduct('Test product5', false); 
       product.Convert_From__c = true;
       product.APTPS_Rev_Share__c=10;
       product.APTPS_Rev_Share_Type__c='Net';
       insert product;
       
       Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
       insert priceList; 
               
       Apttus_Config2__ProductConfiguration__c config = TestDataSetupUtility.createTestProductConfig(proposal,acct,priceList);
       config.Apttus_Config2__Status__c = 'Saved';
       insert config;
       config.Apttus_Config2__Status__c = 'Finalized';
       update config;
       
       Apttus_Config2__LineItem__c lineitem = TestDataSetupUtility.createLineItemApttus(config.ID);
       lineitem.Apttus_Config2__ProductId__c = product.Id;
       //insert lineitem;
       
       Apttus_Config2__ProductAttributeValue__c pav = new Apttus_Config2__ProductAttributeValue__c();
        pav.Apttus_Config2__LineItemId__c = lineitem.ID;
        pav.CurrencyIsoCode = 'USD';
        pav.Product_Type__c = 'Sourcing Services-GL';
        //insert pav;
        
       Apttus_Proposal__Proposal_Line_Item__c propLineItem = New Apttus_Proposal__Proposal_Line_Item__c();
       propLineItem.Apttus_QPConfig__ConfigurationId__c = config.Id;
       propLineItem.Apttus_QPConfig__NetPrice__c=3400;
       propLineItem.Apttus_QPConfig__BaseExtendedPrice__c=2040;
       propLineItem.Apttus_Proposal__Proposal__c =proposal.Id; 
       propLineItem.Apttus_QPConfig__OptionId__c = null;
       propLineItem.Rev_Share_Type__c='Net';
       propLineItem.Apttus_QPConfig__OptionId__c=product.ID;
       propLineItem.Rev_Share__c=10;
       propLineItem.Apttus_Proposal__Product__c = product.Id;
       propLineItem.Apttus_QPConfig__DerivedFromId__c = lineitem.Id;
       insert propLineItem;
       
       Apttus_QPConfig__ProposalProductAttributeValue__c objPAV = new Apttus_QPConfig__ProposalProductAttributeValue__c();
       objPAV.Apttus_QPConfig__LineItemId__c = propLineItem.Id;
       insert objPAV;
       
       Apttus_Config2__AppliedRuleInfo__c objInfo = new Apttus_Config2__AppliedRuleInfo__c();
       objInfo.Apttus_Config2__ConfigurationId__c = config.Id;
       insert objInfo;       
        
       test.starttest();
        PageReference myVfPage = Page.ProposalDeepClone;
        Test.setCurrentPage(myVfPage);
        
        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('id',proposal.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(proposal);
        APTS_OverrideProposalCloneExt objClone = new APTS_OverrideProposalCloneExt(sc);
        objClone.init();
        
        APTS_OverrideProposalCloneExt.CloneChildRecords(objClone.NewProductConfigIds,objClone.OldConfigID,objClone.NewProposalID);
        APTS_OverrideProposalCloneExt.ClonLineItemRecords(objClone.NewProductConfigIds,objClone.OldConfigID,objClone.NewProposalID, objClone.sRecordId);
        objClone.doCancel();
       test.stopTest();
       
    }
    
    static testMethod void testAPTS_OverrideProposalCloneExtExceptionTest(){
        Apttus_Proposal__Proposal__c proposal = null;
        Account acct = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TestAcct_28_07_15');
        insert acct;
        Contact con = TestDataSetupUtility.createTestContact(acct.Id, 'Test_Last', 'Test_First', 'test@test.com');
        insert con;
        
       //create Opportunity
       Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', acct.Id);
       opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'GCS Opportunity');
       insert opp;
            
       proposal = TestDataSetupUtility.createProposal('TEST_PROP_28_07_15', acct.Id, opp.Id, 'test', false);
       
       insert proposal;
        
       //Create product2
       Product2 product = TestDataSetupUtility.createProduct('Test product5', false); 
       product.Convert_From__c = true;
       product.APTPS_Rev_Share__c=10;
       product.APTPS_Rev_Share_Type__c='Net';
       insert product;
       
       Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
       insert priceList; 
               
       Apttus_Config2__ProductConfiguration__c config = TestDataSetupUtility.createTestProductConfig(proposal,acct,priceList);
       config.Apttus_Config2__Status__c = 'Saved';
       insert config;
       config.Apttus_Config2__Status__c = 'Finalized';
       update config;
       
       Apttus_Config2__LineItem__c lineitem = TestDataSetupUtility.createLineItemApttus(config.ID);
       lineitem.Apttus_Config2__ProductId__c = product.Id;
       insert lineitem;
       
       Apttus_Config2__ProductAttributeValue__c pav = new Apttus_Config2__ProductAttributeValue__c();
        pav.Apttus_Config2__LineItemId__c = lineitem.ID;
        pav.CurrencyIsoCode = 'USD';
        pav.Product_Type__c = 'Sourcing Services-GL';
        insert pav;
        
       Apttus_Proposal__Proposal_Line_Item__c propLineItem = New Apttus_Proposal__Proposal_Line_Item__c();
       propLineItem.Apttus_QPConfig__ConfigurationId__c = config.Id;
       propLineItem.Apttus_QPConfig__NetPrice__c=3400;
       propLineItem.Apttus_QPConfig__BaseExtendedPrice__c=2040;
       propLineItem.Apttus_Proposal__Proposal__c =proposal.Id; 
       propLineItem.Apttus_QPConfig__OptionId__c = null;
       propLineItem.Rev_Share_Type__c='Net';
       propLineItem.Apttus_QPConfig__OptionId__c=product.ID;
       propLineItem.Rev_Share__c=10;
       propLineItem.Apttus_Proposal__Product__c = product.Id;
       propLineItem.Apttus_QPConfig__DerivedFromId__c = lineitem.Id;
       insert propLineItem;
       
       Apttus_QPConfig__ProposalProductAttributeValue__c objPAV = new Apttus_QPConfig__ProposalProductAttributeValue__c();
       objPAV.Apttus_QPConfig__LineItemId__c = propLineItem.Id;
       insert objPAV;
       
       Apttus_Config2__AppliedRuleInfo__c objInfo = new Apttus_Config2__AppliedRuleInfo__c();
       objInfo.Apttus_Config2__ConfigurationId__c = config.Id;
       insert objInfo;       
        
       test.starttest();
        PageReference myVfPage = Page.ProposalDeepClone;
        Test.setCurrentPage(myVfPage);
        
        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('id',proposal.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(proposal);
        APTS_OverrideProposalCloneExt objClone = new APTS_OverrideProposalCloneExt(sc);
        objClone.init();
        
        APTS_OverrideProposalCloneExt.CloneChildRecords(objClone.NewProductConfigIds,objClone.OldConfigID,objClone.NewProposalID);
        APTS_OverrideProposalCloneExt.ClonLineItemRecords(objClone.NewProductConfigIds,objClone.OldConfigID,objClone.NewProposalID, objClone.sRecordId);
        objClone.doCancel();
       test.stopTest();
       
    }
}