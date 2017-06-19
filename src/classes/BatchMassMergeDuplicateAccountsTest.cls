/***********************************************************************************************************
 * Appirio, Inc
 * Name         : BatchMassMergeDuplicateAccountsTest
 * Created By   : Rohit B. (Appirio)
 * Purpose      : Test class of BatchMassMergeDuplicateAccounts
 * Created Date : 01/Sept/2015
 *
 * Date Modified                Modified By             Description of the update
 * [Date]						[Person Name]			[Short Description]
 **********************************************************************************************************/
@isTest(SeeAllData=true)
private class BatchMassMergeDuplicateAccountsTest {
	@isTest
	static void test_method_one() {
		User sysAdmin = TestDataSetupUtility.createUser('System Administrator', true);
		System.runAs(sysAdmin){
			Account acc = TestDataSetupUtility.createTestAccount('Test Parent', 'North America', UserInfo.getUserId());
			insert acc;

			List<Account> lstAcc = new List<Account>();
			for(Integer i=0; i<10; i++) {
				Account acc1 = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account '+i);
				acc1.Merge_Winner__c = acc.Id;
				acc1.Organization__c = 'North America';
				acc1.SalesChannel__c = 'ECOMM';
				lstAcc.add(acc1);
			}
			insert lstAcc;
			lstAcc.add(acc);
			Test.startTest();
				BatchMassMergeDuplicateAccounts bm = new BatchMassMergeDuplicateAccounts(lstAcc);
       			Database.executeBatch(bm);
			Test.stopTest();
		}
	}
}