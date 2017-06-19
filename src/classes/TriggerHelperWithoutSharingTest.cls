@isTest
private class TriggerHelperWithoutSharingTest{

 static List<Account> accList;
 static List<Account_Team_Member__c> teamMemberList ;
 static List<Task> lstTasks;
 static testMethod void TestingController_Test(){
 	
 	prepareData();

 	TriggerHelperWithoutSharing obj = TriggerHelperWithoutSharing.getInstance();
 	lstTasks = [Select Id,AccountId,CreatedDate,ownerId from Task Where Id IN :lstTasks];
 	map<Id,Account> accountMap = new map<Id,Account>([Select ID,OwnerId from Account Where Id IN :accList]);
 	obj.updateMaxActivityDateAndOwnerOfAccount(lstTasks);
 	map<String, list<Account>> mapAccTeam = new map<String, list<Account>>();
 	for(Account_Team_Member__c member : teamMemberList){
 		if(!mapAccTeam.containsKey(member.TeamMemberRole__c)) {
 			mapAccTeam.put(member.TeamMemberRole__c,new list<Account>());
 		}
 		mapAccTeam.get(member.TeamMemberRole__c).add(accountMap.get(member.AccountId__c));
 	}
 	obj.UpdatePrimaryAccountTeamMembers2(accountMap.keySet(), mapAccTeam);
 
 }

 static void prepareData(){

 		accList = new List<Account>();
 		teamMemberList = new List<Account_Team_Member__c>();
 		lstTasks = new List<Task>();

 		Account acc = TestDataSetupUtility.createTestAccountWithShipping('Test-Acc-1');
 		insert acc;
 		accList.add(acc);

 		Account_Team_Member__c teamMember = new Account_Team_Member__c();
 		teamMember.AccountId__c = acc.Id;
 		teamMember.UserId__c = UserInfo.getUserId();
 		teamMember.TeamMemberRole__c = 'PrimarySalesRep';
 		insert teamMember;
 		teamMemberList.add(teamMember);

 		
 		Task tsk = TestDataSetupUtility.createTask(acc.Id);
 		insert tsk;
 		lstTasks.add(tsk);
 }

 
}