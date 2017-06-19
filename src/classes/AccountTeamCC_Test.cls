@isTest
public class AccountTeamCC_Test {
    static testMethod void testAccountTeamCC() {    
        Account acc = TestDataSetupUtility.createTestAccount('Test','test',UserInfo.getUserId());
        insert acc;
       	Account_Team_Member__c atm = new Account_Team_Member__c();
        atm.AccountId__c = acc.Id;
        atm.TeamMemberRole__c = 'Sales Rep';
        atm.UserId__c = UserInfo.getUserId();
        atm.AccountAccessLevel__c = 'Read/Write';
        atm.CaseAccessLevel__c = 'Read/Write';
        insert atm;
        
        ApexPages.currentPage().getParameters().put('aid',acc.id);
        ApexPages.currentPage().getParameters().put('act','removeall');
        AccountTeamCC  accTeamController = new AccountTeamCC ();
        accTeamController.OnClick_Save();
        accTeamController.OnClick_SaveAndMore();   
        accTeamController.OnClick_Cancel();
        accTeamController.DeleteAll();
        
        
    }
}