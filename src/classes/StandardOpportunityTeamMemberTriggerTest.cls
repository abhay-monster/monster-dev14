@isTest
// Modified by John Hecker (Appirio) 9/4/2015 to test OpportunityTeamMember in addition to OpportunityTeamMember__c

public with sharing class StandardOpportunityTeamMemberTriggerTest{

    static OpportunityTeamMember__c testOpportunityTeamMember;
    static OpportunityTeamMember__c testOpportunityTeamMember2;
    static OpportunityTeamMember StestOpportunityTeamMember;
    static OpportunityTeamMember StestOpportunityTeamMember2;
    static Opportunity testOpportunity;
    static Account testAccount;
    static User testUser;
    static User testUser2;

static{

    Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
    testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
    testUser.TeamingChannel__c  = 'Partner';
    insert testuser;

    testUser2 = TestDataSetupUtility.createTestUser('Test 2', 'System Admin', p.Id);
    testUser2.TeamingChannel__c  = 'Partner';
    insert testuser2;

    testAccount = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test ABC Account');

    insert testAccount;

    testOpportunity=TestDataSetupUtility.createTestOpportunity('Test ABC Opportunity',testAccount.Id);
    //testOpportunity.Owner=testuser2.Id;
    testOpportunity.SecondarySalesRep__c = testUser.Id;
    testOpportunity.Apttus_Approval__Approval_Status__c = 'Rejected';
    testOpportunity.RejectionReason__c = 'Opportunity Team Change';
    testOpportunity.TeamingScenario__c = 'Named';

    insert testOpportunity;

    }

    static testmethod void testAllIUD() {

        testOpportunityTeamMember = new OpportunityTeamMember__c();
        testOpportunityTeamMember.Opportunity__c = testOpportunity.Id;
        testOpportunityTeamMember.TeamMember__c = testuser.Id;
        testOpportunityTeamMember.TeamRole__c='Sales Rep';

        insert testOpportunityTeamMember;
        
        StestOpportunityTeamMember = new OpportunityTeamMember();
        StestOpportunityTeamMember.OpportunityId = testOpportunity.Id;
        StestOpportunityTeamMember.UserId = testuser.Id;
        StestOpportunityTeamMember.TeamMemberRole ='Sales Rep';

        insert StestOpportunityTeamMember;

        testOpportunityTeamMember2 = new OpportunityTeamMember__c();
        testOpportunityTeamMember2.Opportunity__c = testOpportunity.Id;
        testOpportunityTeamMember2.TeamMember__c = testuser2.Id;
        testOpportunityTeamMember2.TeamRole__c='Sales Rep';
        
        insert testOpportunityTeamMember2;
        
        StestOpportunityTeamMember2 = new OpportunityTeamMember();
        StestOpportunityTeamMember2.OpportunityId = testOpportunity.Id;
        StestOpportunityTeamMember2.UserId = testuser2.Id;
        StestOpportunityTeamMember2.TeamMemberRole ='Sales Rep';
        
        insert StestOpportunityTeamMember2;
    }
}