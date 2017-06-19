@isTest
public class AccountContactAssocTriggerHelper_Test {

	static testMethod void testAccountContactAssocTriggerHelper(){
		Test.startTest();
		AccountContactAssocTriggerHelper helper = AccountContactAssocTriggerHelper.NewTriggerHelper('test');
        AccountContactAssociation__c acctConAssociation = new AccountContactAssociation__c();
        acctConAssociation.PrimarySalesContact__c = true;
        helper.validatePrimarySalesContact(new List<AccountContactAssociation__c>{acctConAssociation});
        helper.SetPrimarySalesContact(new List<AccountContactAssociation__c>{acctConAssociation});
        insert acctConAssociation;
		Test.stopTest();
	}
}