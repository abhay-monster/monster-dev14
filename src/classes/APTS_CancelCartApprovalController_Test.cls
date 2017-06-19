@isTest

Private Class APTS_CancelCartApprovalController_Test{
    static Apttus_Proposal__Proposal__c proposal ;   
    static testmethod void testAPTS_CancelCartApprovalController(){
        prepareData();
        Test.startTest();
        ApexPages.CurrentPage().getParameters().put('sObjectId',proposal.Id);
        APTS_CancelCartApprovalController ctrl = new APTS_CancelCartApprovalController();
        try{
            ctrl.CancelApprovalRequest();
        }catch(Exception e){
        System.debug('Exception is '+e);
        }
        Test.stopTest();    
    }
    
    static void prepareData(){
     Account acc = TestDataSetupUtility.createTestAccount('test',null,null);
     insert acc;
     Opportunity opp = TestDataSetupUtility.createTestOpportunity('testOpp', acc.Id);
     insert opp;
     Id oppRT =  Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'Opportunity');
     
     //Account acc = TestDataSetupUtility.createTestAccount('Test Account', 'North America', UserInfo.getUserId());
     //insert acc;
     
     /*Opportunity opp = TestDataSetupUtility.createTestOpportunity('test',acc.Id);
      opp.InternationalDeal__c = true;
      opp.recordTypeId = oppRT;
      insert opp;*/
     
     //proposal = TestDataSetupUtility.createApttusProposal(opp);
     //proposal.Suppress_Invoice_Detail__c = 'Suppress Unit Price and Net Total Detail'; 
     //insert proposal;
     
     proposal = TestDataSetupUtility.createApttusProposal(opp);
     proposal.Apttus_Proposal__Account__c = acc.Id;
     insert proposal; 
     
     Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('PriceList1', true);
     Apttus_Config2__ProductConfiguration__c config = TestDataSetupUtility.createTestProductConfig(proposal,acc,priceList);
     insert config;
     
     

    } 
    
 }