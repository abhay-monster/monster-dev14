// 
// (c) 2016 Appirio, Inc.
//
// The point of this class is to use the SeeAllData annotation to 
// test functionality of the code for handling queries with large data 
// volumes.  As we run into other non-selective query issues we can add tests
// for those as well
//
// 21 Jul 2016 - Jeff Lescarbeau - Initial creation 
//

@isTest (SeeAllData=true)
private class LargeSOQLTest {
	
	@isTest static void CreateCaseForAlphaAccountsTest() {

		Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		User testUser = TestDataSetupUtility.createTestUser('Integration', 'MAPP', adminProfile.Id);
		testUser.FirstName = 'Integration';
		testUser.LastName = 'MAPP';
		insert testUser;
		/*Personal_Settings__c persSett = TestDataSetupUtility.buildPersonalSetting();
		persSett.Trigger_Account__c = true;
		insert persSett;*/
		Account testAccount = TestDataSetupUtility.createTestAccountWithShipping('Test Account');
		Test.startTest();
		System.runAs(testUser){
		    system.assertEquals(UserInfo.getName() , 'Integration MAPP');
		    testAccount.CreditStatus__c = 'Not Okay';
		    testAccount.Organization__c = 'Europe';
		    testAccount.Account_Type__c = 'Staffing';
		    testAccount.AccountStatus__c = 'Candidate';
		    testAccount.RegistrationNumber__c = '9999984453215642356478975'; //this is much larger than the number really is, shouldn't cause any collissions
		    insert testAccount;
		}
		Test.stopTest();
	}
	
}