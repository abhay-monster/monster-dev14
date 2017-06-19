/***********************************************************************************************************
 * Appirio, Inc
 * Name         : BatchMassUpdateUserTest
 * Created By   : Rohit B. (Appirio)
 * Purpose      : Test class of BatchMassUpdateUser
 * Created Date : 01/Sept/2015
 *
 * Date Modified                Modified By             Description of the update
 * [Date]						[Person Name]			[Short Description]
 **********************************************************************************************************/
@isTest
private class BatchMassUpdateUserTest {
	
	@isTest 
	static void test_method_one() {
		User sysAdmin = TestDataSetupUtility.createUser('System Administrator', true);
		System.runAs(sysAdmin){
			List<Mass_User_Update__c> lstMUU = new List<Mass_User_Update__c>();
			for(Integer i=0; i<20; i++) {
				Mass_User_Update__c muu = new Mass_User_Update__c();
				muu.User__c = TestDataSetupUtility.createUser('System Administrator', true).Id;
				muu.Combined_Region__c = 'Government';
				muu.Job_Type__c = 'Retention';
				muu.Position_Account_Size__c = 'Enterprise';
				muu.Position_Group__c = 'Ecomm';
				muu.Position_Job_Title__c = 'Retention';
				muu.Position_Organization__c = 'ECOMM';
				muu.Region__c = 'MGS';
				muu.Region_Group__c = 'India';
				muu.Sales_Channel__c = 'ECOMM';
				muu.Segment__c = 'Government';
				muu.Processed__c = false;
				lstMUU.add(muu);
			}
			insert lstMUU;

			Test.startTest();
				BatchMassUpdateUser bm = new BatchMassUpdateUser();
       			Database.executeBatch(bm);
			Test.stopTest();
		}
	}
	
}