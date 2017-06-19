@isTest
private class APTS_QueueOppAprrovalRejectEmail_Test {

	private static testMethod void rejectMailMethod() {

        Account acc  = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
    	insert acc;
        
        Id PROFILE_ID = [select Id From Profile Where Name = 'System Administrator'].Id;
     	User usr1=TestDataSetupUtility.createTestUser('tst1','test1',PROFILE_ID);
     	User usr2=TestDataSetupUtility.createTestUser('tst2','test2',PROFILE_ID);
     	User usr3=TestDataSetupUtility.createTestUser('tst3','test3',PROFILE_ID);
     	User usr4=TestDataSetupUtility.createTestUser('tst4','test4',PROFILE_ID);
     	usr1.Email='sample@gmail.com';
     	usr2.Email='sample@gmail.com';
     	usr3.Email='sample@gmail.com';
     	usr4.Email='sample@gmail.com';
     	List<user> userList=new List<user>();
     	userList.add(usr1);
     	userList.add(usr2);
     	userList.add(usr3);
     	userList.add(usr4);
     	insert userList;
        
        List<Opportunity> oppList=new List<Opportunity>();
		oppList.add(TestDataSetupUtility.createTestOpportunity('TestOpp' , acc.Id));

		oppList[0].SecondarySalesRep__c=userList[0].Id;
		oppList[0].Amount=1000;

		
		
		insert oppList;
		
		Id PROFILE_ID1 = [select Id From Profile Where Name = 'System Administrator'].Id;
     	User user1=TestDataSetupUtility.createTestUser('test1','test1',PROFILE_ID1);
     	User user2=TestDataSetupUtility.createTestUser('test2','test2',PROFILE_ID1);
     	User user3=TestDataSetupUtility.createTestUser('test3','test3',PROFILE_ID1);
     	User user4=TestDataSetupUtility.createTestUser('test4','test4',PROFILE_ID1);
        user1.Email='sample1@gmail.com';
     	user2.Email='sample11@gmail.com';
     	user3.Email='sample12@gmail.com';
     	user4.Email='sample13@gmail.com';
     	List<user> userList1=new List<user>();
     	userList1.add(user1);
     	userList1.add(user2);
     	userList1.add(user3);
     	userList1.add(user4);
     	insert userList1;
     	OpportunityTeamMember__c teamMember=new OpportunityTeamMember__c(Opportunity__c=oppList[0].Id,TeamMember__c=user1.Id,TeamRole__c='Sales Rep');
     	OpportunityTeamMember__c teamMember1=new OpportunityTeamMember__c(Opportunity__c=oppList[0].Id,TeamMember__c=user2.Id,TeamRole__c='Sales Rep');
     	OpportunityTeamMember__c teamMember2=new OpportunityTeamMember__c(Opportunity__c=oppList[0].Id,TeamMember__c=user3.Id,TeamRole__c='Sales Rep');
     	OpportunityTeamMember__c teamMember3=new OpportunityTeamMember__c(Opportunity__c=oppList[0].Id,TeamMember__c=user4.Id,TeamRole__c='Sales Rep');
        List<OpportunityTeamMember__c> oppTeamMember=new List<OpportunityTeamMember__c>();
        oppTeamMember.add(teamMember);
        oppTeamMember.add(teamMember1);
        oppTeamMember.add(teamMember2);
        oppTeamMember.add(teamMember3);
        insert oppTeamMember;
		
		Set<Id> oppListId=new Set<Id>();
		oppListId.add(oppList[0].Id);
		
		map<string,string> reasonMap=new Map<String, String>();
		reasonMap.put(oppList[0].Id,'for test');

     	
     	APTS_QueueOppAprrovalRejectEmail queueApprovalrjctMail=new APTS_QueueOppAprrovalRejectEmail(oppListId,reasonMap);
     	Test.startTest();
     	System.enqueueJob(queueApprovalrjctMail);
     	Test.stopTest();

        
	}

}