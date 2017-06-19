/***********************************************************************************************************
 * Appirio, Inc
 * Name         : MassMergeDuplicateAccountsCtrlTest
 * Created By   : Rohit B. (Appirio)
 * Purpose      : Test class of MassMergeDuplicateAccountsCtrl
 * Created Date : 30/Sept/2015
 *
 * Date Modified                Modified By             Description of the update
 * [Date]                       [Person Name]           [Short Description]
 **********************************************************************************************************/
//(SeeAllData=true) Removed by Mitali (Appirio) 19-04-17 as it was failing test classes with following error : 
//System.UnexpectedException: No more than one executeBatch can be called from within a test method.  
//Please make sure the iterable returned from your start method matches the batch size, resulting in one executeBatch invocation.
@isTest
public with sharing class MassMergeDuplicateAccountsCtrlTest {
    static testMethod void testMethod1(){
        User sysAdmin = TestDataSetupUtility.createUser('System Administrator', true);
        System.runAs(sysAdmin){
            BatchMassMergeDuplicateAccounts__c cs = new BatchMassMergeDuplicateAccounts__c();
            cs.Batch_size__c = 5;
            cs.CC_addresses__c = '';
            insert cs;
            Account acc = TestDataSetupUtility.createTestAccount('Test Parent', 'North America', UserInfo.getUserId());
            insert acc;

            List<Account> lstAcc = new List<Account>();
            Account mergeAcc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
            mergeAcc.Merge_Winner__c = acc.Id;
            mergeAcc.Organization__c = 'North America';
            mergeAcc.SalesChannel__c = 'ECOMM';
            mergeAcc.Phone = '1234567891';
            mergeAcc.BillingCountry = 'United States';
            insert mergeAcc;
            lstAcc.add(mergeAcc);
            Test.startTest();
                MassMergeDuplicateAccountsCtrl.lstAccToDisplay = lstAcc;
                MassMergeDuplicateAccountsCtrl mmda = new MassMergeDuplicateAccountsCtrl();
                mmda.selectedOrg = 'North America';

                MassMergeDuplicateAccountsCtrl.MergeWrapper mw = new MassMergeDuplicateAccountsCtrl.MergeWrapper(1, mergeAcc);
                mw.isSelected = true;

                mmda.setOrganisations('North America');
                mmda.fetchAccounts();
                for(MassMergeDuplicateAccountsCtrl.MergeWrapper wr : mmda.wrappers) {
                    wr.isSelected = true;
                }
                mmda.runAccountMergeBatch();
                mmda.removeAccount();
            Test.stopTest();
        }
    }

}