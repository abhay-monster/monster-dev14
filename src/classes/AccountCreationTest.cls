/**
 */
@isTest
private class AccountCreationTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Account acc = new Account(name='testAcc');
        insert acc;
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        AccountCreation ac = new AccountCreation(sc);
        FieldsId__c fId = new FieldsId__c(Name='AccountOrganization');
        insert fId;
        Test.startTest();
        ac.executeMethod();
        Test.stopTest();
    }
}