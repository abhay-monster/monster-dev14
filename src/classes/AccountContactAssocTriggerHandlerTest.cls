/**

 */
@isTest
private class AccountContactAssocTriggerHandlerTest {

    static testMethod void myUnitTest() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = [select id,alias from User where ProfileId =: p.Id and isActive = true limit 1];
        
        System.runAs(u) {        
            //TO DO: implement unit test
            Account acc = new Account(Name='testAcc');
            insert acc;
            AccountContactAssociation__c aca = new AccountContactAssociation__c(Account__c=acc.Id);
            insert aca;
            Personal_Settings__c ps = new Personal_Settings__c();
            ps.Trigger_Account_Contact_Association__c = true;
            insert ps;
            AccountContactAssociation__c aca1 = new AccountContactAssociation__c(Account__c=acc.Id);
            insert aca1;
            update aca;
        }
    }
}