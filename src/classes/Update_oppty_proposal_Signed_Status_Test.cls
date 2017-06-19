@isTest

Private Class Update_oppty_proposal_Signed_Status_Test{
    static echosign_dev1__SIGN_Agreement__c echoSign;
    static Apttus_Proposal__Proposal__c apttus;
    static testmethod void testUpdate_oppty_proposal_Signed_Status(){
        prepareData();
        Test.startTest();
        echoSign.echosign_dev1__Status__c = 'Signed';
        update echoSign;
        // Verify related Apttus_Proposal__Proposal__c  field 'QuoteStatus__c ' is updated
        apttus = [SELECT signed_indicator__c, QuoteStatus__c FROM Apttus_Proposal__Proposal__c 
                                                             WHERE Id = :apttus.Id ];
        system.assert(apttus.signed_indicator__c == true);
        system.assert(apttus.QuoteStatus__c  == 'Accepted Online');
        
        Test.stopTest();
    }
    
    static void prepareData(){
     Account acc = TestDataSetupUtility.createTestAccount('test',null,null);
     insert acc;
     
     Opportunity opp = TestDataSetupUtility.createTestOpportunity('TestOpp', acc.Id);
     insert opp;
     
     apttus = TestDataSetupUtility.createApttusProposal(opp);
     apttus.Apttus_Proposal__Account__c = acc.Id;
     insert apttus;
     
     echoSign = new echosign_dev1__SIGN_Agreement__c ();
     echoSign.echosign_dev1__Account__c = acc.Id;
     echoSign.Apttus_QPESign__Apttus_Proposal__c = apttus.Id;     
     insert echoSign ;
    } 

}