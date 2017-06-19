@isTest

public with sharing class OpportunityTeamMemberTriggerTest{

static OpportunityTeamMember__c testOpportunityTeamMember;
static OpportunityTeamMember__c testOpportunityTeamMember2;
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
	static testmethod void testPositiveInsert(){

	OpportunityTeamMember__c testOpportunityTeamMember1;
	testOpportunityTeamMember1 = new OpportunityTeamMember__c();
	testOpportunityTeamMember1.Opportunity__c = testOpportunity.Id;
	testOpportunityTeamMember1.TeamMember__c = testuser.Id;
	testOpportunityTeamMember1.TeamRole__c='Primary Sales Rep';

	insert testOpportunityTeamMember1;

	testOpportunityTeamMember2 = new OpportunityTeamMember__c();
	testOpportunityTeamMember2.Opportunity__c = testOpportunity.Id;
	testOpportunityTeamMember2.TeamMember__c = testuser.Id;
	testOpportunityTeamMember2.TeamRole__c='Secondary Sales Rep';

	insert testOpportunityTeamMember2;

	}
	
	static testmethod void testNegativeInsertandAfterUpdateandAfterDelete(){

	testOpportunityTeamMember = new OpportunityTeamMember__c();
	testOpportunityTeamMember.Opportunity__c = testOpportunity.Id;
	testOpportunityTeamMember.TeamMember__c = testuser.Id;
	testOpportunityTeamMember.TeamRole__c='Sales Rep';

	insert testOpportunityTeamMember;

	testOpportunityTeamMember.TeamRole__c='Overlay Rep';
	testOpportunityTeamMember.ProductFamily__c='Job Posting';

	update testOpportunityTeamMember;

	testOpportunityTeamMember.TeamRole__c='Sales Rep';

	update testOpportunityTeamMember;

	delete testOpportunityTeamMember;
	}

}