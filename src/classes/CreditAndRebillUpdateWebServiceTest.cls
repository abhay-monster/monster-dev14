@isTest
private class CreditAndRebillUpdateWebServiceTest {


	@isTest
	static void testOne() {
		Personal_Settings__c personalSettings = TestDataSetupUtility.buildPersonalSetting();
        //personalSettings.Trigger_Order__c = true;
        /*if(setPersonalSettings){
            personalSettings.Trigger_Order__c = true;
            personalSettings.Trigger_Account__c = true;
            personalSettings.Trigger_Opportunity__c = true;
            personalSettings.Validation_Account__c = true;
            personalSettings.Validation_Opportunity__c = true;
        }*/
        insert personalSettings;
        insert TestDataSetupUtility.buildMaximumCustomerNumberSetting();
        insert TestDataSetupUtility.buildWebServiceEndpointSetting();
        insert TestDataSetupUtility.buildIntegrationConfigSetting();
        insert TestDataSetupUtility.buildCaseTriggerSetting();

        List<Account> accountList = new List<Account>();
        Account usedAccount = TestDataSetupUtility.createTestAccount('Test Account', 'North America', UserInfo.getUserId());
        usedAccount.OwnerId = UserInfo.getUserId();
        accountList.add(usedAccount);
        //accountList.add(TestDataSetupUtility.createTestAccount('Test Account2', AccountName, UserInfo.getUserId()));
        accountList[0].AccountStatus__c = 'Customer';
        accountList[0].CustomerNumber__c = '11';
        accountList[0].CustomerDate__c = Date.today();
        //accountList[1].AccountStatus__c = 'Lapsed Customer';
        //accountList[1].CustomerLapsedDate__c = Date.today();

        insert accountList;

        Contact con = TestDataSetupUtility.createTestContact(accountList.get(0).id,'test','Con','abccon@gmail.com');
        insert con;


        Profile p = [SELECT Id FROM Profile WHERE Name LIKE '%Service Rep%' LIMIT 1];
        User u = TestDataSetupUtility.createTestUser('John', 'Doe', p.Id);
        insert u;

        Account_Team_Member__c atm = new Account_Team_Member__c();
        atm.AccountId__c = accountList[0].Id;
        atm.TeamMemberRole__c = 'Sales Rep';
        atm.UserId__c = u.Id;
        atm.AccountAccessLevel__c = 'Read/Write';
        atm.CaseAccessLevel__c = 'Read/Write';
        insert atm;
        Payment_Details__c paymentDetails = TestDataSetupUtility.createTestPaymentDetails('North America' , 'Monthly', 'Net 10');
        paymentDetails.PaymentMethod__c = 'Invoice';
        paymentDetails.Active__c  = true;
        insert paymentDetails;
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opportunity', accountList[0].Id);
        opp.OrderCreated__c = true;
        opp.OwnerId = UserInfo.getUserId();
        oppList.add(opp);
        insert oppList;

        Order__c ord = TestDataSetupUtility.createOrderWithOpportunity(usedAccount.Id, oppList[0].Id, null, con.Id);
        ord.BillingAccount__c = accountList[0].id;
        ord.Entity_ID__c = null;
        ord.OrderStatus__c = 'Open';
        ord.SiteChannelID__c  = 'Test11';
        ord.MAPP_Payment_Frequency__c = 'Test';	

        insert ord;

        List<Id> ordIdList = new List<Id>();
        ordIdList.add(ord.Id);

        Test.startTest();
        CreditAndRebillUpdateWebService.updateRecords(ordIdList);
        Test.stopTest();

        Order__c testOrder = [Select Id, OrderStatus__c from Order__c where Id = :ord.Id Limit 1];

        system.assertEquals(testOrder.OrderStatus__c, 'Sent To Verification');

	}
	
}