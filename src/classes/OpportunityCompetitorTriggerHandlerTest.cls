//------------------------------------------------------------------------------------------------------------
//  Name: OpportunityCompetitorTriggerHandlerTest
//  Date: 14/05/2015
//  Author: Gaurav (Appirio Ind.)
//  Purpose: test class of trigger , trigger handler and helper class of object OpportunityCompetitor__c
//------------------------------------------------------------------------------------------------------------
@isTest
private class OpportunityCompetitorTriggerHandlerTest {

    static testMethod void testOppCompSyncWithAccComp() {
        Personal_Settings__c ps = new Personal_Settings__c();
        ps.Validation_Account__c = false;
        ps.trigger_opportunity__c = true;
        insert ps;

        Method_Kill_List__c testCustomSetting = new Method_Kill_List__c(Name='updateOpptySplit', Kill_Method__c=false);
        insert testCustomSetting;

        IntegrationConfig__c ic = new IntegrationConfig__c();
        ic.Name = 'USPS Integration';
        ic.EndpointName__c = 'USPSAddressValidation';
        ic.USPSUserID__c = '562CLOUD2615';
        ic.Timeout__c = 60000;
        insert ic;

        WebServiceEndpoint__c wse = new WebServiceEndpoint__c();
        wse.Name = 'USPSAddressValidation';
        wse.Endpoint__c = 'http://production.shippingapis.com/ShippingAPI.dll';
        insert wse;

        Account acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        insert acc;
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', acc.id);
        insert opp;
        //CompetitiveLandscape__c c= TestDataSetupUtility.createCompetitiveLandscape(acc.id , True);
        OpportunityCompetitor__c oppComp = TestDataSetupUtility.createOpportunityCompetitor(opp);
        insert oppComp;
        oppComp = [select id,Account_Country__c,Competitor__c from OpportunityCompetitor__c];

        list<CompetitiveLandscape__c> lstCompOnAcc= [select id,Competitor__c,AccountCountry__c from CompetitiveLandscape__c];
        system.assert(lstCompOnAcc.size() == 1);
        system.assert(oppComp.Account_Country__c == lstCompOnAcc[0].AccountCountry__c);
        // Entering Competitor with duplicate account and country
        OpportunityCompetitor__c oppComp1 = TestDataSetupUtility.createOpportunityCompetitor(opp);
        oppComp1.Account_Country__c = 'Australia';
        oppComp1.Competitor__c = 'Careerjet';
        insert oppComp1;

		system.assert(lstCompOnAcc.size() == 1);
    }
}