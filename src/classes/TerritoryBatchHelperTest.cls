@isTest
public class TerritoryBatchHelperTest {
	static testmethod void unittest1()
    {
        insert TestDataSetupUtility.buildZipcodeConfiguration('United States','ddddddddd','^\\d{5}(?:[-\\s]*\\d{4})?$','^\\d{5}(?:[-\\s]*\\d{4})?$');
        insert TestDataSetupUtility.buildZipcodeConfiguration('Canada','AdAdAd','^[A-Z]\\d[A-Z](?:\\s*\\d[A-Z]\\d)?$','^[A-Z]\\d[A-Z]\\s*\\d[A-Z]\\d$');

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        //User u = [select id,alias from User where ProfileId =: p.Id and isActive = true limit 1];
		User u = TestDataSetupUtility.createTestUser('TestFistName', 'TestLastName', p.Id);
        insert u;
        System.runAs(u)
        {
            Test.startTest();

            List<Account> accList = new List<Account>();
            Account testAccount = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TEST PB Account');//, 'North America', UserInfo.getUserId());
            testAccount.Phone = '+18008008000';
            testAccount.PrimaryServiceRep__c = u.id;
            testAccount.Organization__c = 'North America';
            testAccount.ServiceTier__c = 'Core';
            testAccount.DoNotReassign__c = false;
            testAccount.AccountGroup__c = 'Telesales Acquisition';
            testAccount.ShippingPostalCode = '05401-1234';
            testAccount.SalesChannel__c = 'Partner';
            testAccount.SalesChannel__c = 'Commercial';
            insert testAccount;

            testAccount.ShippingCountry = 'United States';
            testAccount.ShippingPostalCode = '05401-2345';
            update testAccount;

            accList.add(testAccount);

            system.debug('=====> accList : '+accList);
            String accountId = [Select AccountId__c from Account where Id = : testAccount.Id].AccountId__c;
            system.debug('=====> accList 1 : '+[Select AccountId__c from Account where Id = : testAccount.Id].AccountId__c);

            TerritoryAssignment__c taObj = new TerritoryAssignment__c();
            insert taObj;

            List<TerritoryAssignmentCode__c> tacList = new List<TerritoryAssignmentCode__c>();

            //                                                                                      TAC ID, Acct Country, Acct Group, Acct Size, EmpSize, Named Acct, Zip Start, Zip End, Sales Channel, Segment
            TerritoryAssignmentCode__c tacObj1 = TestDataSetupUtility.createTerritoryAssignmentCode(taObj.ID, 'United States', 'Telesales Acquisition', null, null, null, '05401', '05402', 'Partner', 'Commercial');
            TerritoryAssignmentCode__c tacObj2 = TestDataSetupUtility.createTerritoryAssignmentCode(taObj.ID, 'United States', 'Active', null, null, null, '05401', '05402', 'Partner', 'Commercial');
            TerritoryAssignmentCode__c tacObj3 = TestDataSetupUtility.createTerritoryAssignmentCode(taObj.ID, 'United States', 'Telesales Acquisition', null, null, null, '05401', '05402', 'Agency', 'Commercial');
            TerritoryAssignmentCode__c tacObj4 = TestDataSetupUtility.createTerritoryAssignmentCode(taObj.ID, 'United States', 'Telesales Acquisition', null, null, null, '05401', '05402', 'Partner', 'Commercial');

            tacList.add(tacObj1);
            tacList.add(tacObj2);
            tacList.add(tacObj3);
            tacList.add(tacObj4);

            insert tacList;

            TerritoryBatchHelper terrAssignObj = new TerritoryBatchHelper();
            terrAssignObj.AccountWithoutTerritory(accList);

            system.assertEquals([Select AccountId__c from Account where Id = : testAccount.Id].AccountId__c, accountId);
            Test.stopTest();
        }
    }
    static testmethod void unittest2()
    {

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        //User u = [select id,alias from User where ProfileId =: p.Id and isActive = true limit 1];
    		User u = TestDataSetupUtility.createTestUser('TestFistName', 'TestLastName', p.Id);
        insert u;
        System.runAs(u)
        {
            Test.startTest();

            List<Account> accList = new List<Account>();
            Account testAccount = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TEST PB Account');//, 'North America', UserInfo.getUserId());
            testAccount.Phone = '+18008008000';
            testAccount.PrimaryServiceRep__c = u.id;
            testAccount.Organization__c = 'North America';
            testAccount.ServiceTier__c = 'Core';
            testAccount.DoNotReassign__c = false;
            testAccount.AccountGroup__c = 'Telesales Acquisition';
            testAccount.ShippingPostalCode = '05401-1234';
            testAccount.SalesChannel__c = 'Partner';
            testAccount.SalesChannel__c = 'Commercial';
            insert testAccount;

            testAccount.ShippingCountry = 'United States';
            testAccount.ShippingPostalCode = '05401-2345';
            update testAccount;

            accList.add(testAccount);

            system.debug('=====> accList : '+accList);
            String accountId = [Select AccountId__c from Account where Id = : testAccount.Id].AccountId__c;
            system.debug('=====> accList 1 : '+[Select AccountId__c from Account where Id = : testAccount.Id].AccountId__c);

            TerritoryAssignment__c taObj = new TerritoryAssignment__c();
            insert taObj;

            List<TerritoryAssignmentCode__c> tacList = new List<TerritoryAssignmentCode__c>();


            //                                                                                      TAC ID, Acct Country, Acct Group, Acct Size, EmpSize, Named Acct, Zip Start, Zip End, Sales Channel, Segment
            TerritoryAssignmentCode__c tacObj5 = TestDataSetupUtility.createTerritoryAssignmentCode(taObj.ID, 'United States', 'Telesales Acquisition', null, null, null, '05401', '05402', 'Partner', 'Commercial');
            TerritoryAssignmentCode__c tacObj6 = TestDataSetupUtility.createTerritoryAssignmentCode(taObj.ID, 'United States', 'Active', null, null, null, '05401', '05402', 'Partner', 'Commercial');

            tacList.add(tacObj5);
            tacList.add(tacObj6);

            insert tacList;

            TerritoryBatchHelper terrAssignObj = new TerritoryBatchHelper();
            terrAssignObj.AccountWithoutTerritory(accList);
            system.assertEquals([Select AccountId__c from Account where Id = : testAccount.Id].AccountId__c, accountId);
            Test.stopTest();
        }
    }
    static testmethod void unittest3()
    {

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        //User u = [select id,alias from User where ProfileId =: p.Id and isActive = true limit 1];
		User u = TestDataSetupUtility.createTestUser('TestFistName', 'TestLastName', p.Id);
        insert u;
        System.runAs(u)
        {
            Test.startTest();

            List<Account> accList = new List<Account>();
            Account testAccount = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TEST PB Account');//, 'North America', UserInfo.getUserId());
            testAccount.Phone = '+18008008000';
            testAccount.PrimaryServiceRep__c = u.id;
            testAccount.Organization__c = 'North America';
            testAccount.ServiceTier__c = 'Core';
            testAccount.DoNotReassign__c = false;
            testAccount.AccountGroup__c = 'Telesales Acquisition';
            testAccount.ShippingPostalCode = '05401-1234';
            testAccount.SalesChannel__c = 'Partner';
            testAccount.SalesChannel__c = 'Commercial';
            insert testAccount;

            testAccount.ShippingCountry = 'United States';
            testAccount.ShippingPostalCode = '05401-2345';
            update testAccount;

            accList.add(testAccount);

            system.debug('=====> accList : '+accList);
            String accountId = [Select AccountId__c from Account where Id = : testAccount.Id].AccountId__c;
            system.debug('=====> accList 1 : '+[Select AccountId__c from Account where Id = : testAccount.Id].AccountId__c);

            TerritoryAssignment__c taObj = new TerritoryAssignment__c();
            insert taObj;

            List<TerritoryAssignmentCode__c> tacList = new List<TerritoryAssignmentCode__c>();

            //                                                                                      TAC ID, Acct Country, Acct Group, Acct Size, EmpSize, Named Acct, Zip Start, Zip End, Sales Channel, Segment
            TerritoryAssignmentCode__c tacObj1 = TestDataSetupUtility.createTerritoryAssignmentCode(taObj.ID, 'United States', 'Telesales Acquisition', null, null, null, '05401', '05402', 'Partner', 'Commercial');

            tacList.add(tacObj1);

            insert tacList;

            TerritoryBatchHelper terrAssignObj = new TerritoryBatchHelper();
            terrAssignObj.AccountWithoutTerritory(accList);
            system.assertEquals([Select AccountId__c from Account where Id = : testAccount.Id].AccountId__c, accountId);
            Test.stopTest();
        }
    }
    static testmethod void unittest4()
    {

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        //User u = [select id,alias from User where ProfileId =: p.Id and isActive = true limit 1];
		User u = TestDataSetupUtility.createTestUser('TestFistName', 'TestLastName', p.Id);
        insert u;
        System.runAs(u)
        {
            Test.startTest();

            List<Account> accList = new List<Account>();
            Account testAccount = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TEST PB Account');//, 'North America', UserInfo.getUserId());
            testAccount.Phone = '+18008008000';
            testAccount.PrimaryServiceRep__c = u.id;
            testAccount.Organization__c = 'North America';
            testAccount.ServiceTier__c = 'Core';
            testAccount.DoNotReassign__c = false;
            testAccount.AccountGroup__c = 'Telesales Acquisition';
            testAccount.ShippingPostalCode = '05401-1234';
            testAccount.SalesChannel__c = 'Partner';
            testAccount.SalesChannel__c = 'Commercial';
            insert testAccount;

            testAccount.ShippingCountry = 'United States';
            testAccount.ShippingPostalCode = '05401-2345';
            update testAccount;

            accList.add(testAccount);

            system.debug('=====> accList : '+accList);
            String accountId = [Select AccountId__c from Account where Id = : testAccount.Id].AccountId__c;
            system.debug('=====> accList 1 : '+[Select AccountId__c from Account where Id = : testAccount.Id].AccountId__c);

            TerritoryAssignment__c taObj = new TerritoryAssignment__c();
            insert taObj;

            List<TerritoryAssignmentCode__c> tacList = new List<TerritoryAssignmentCode__c>();

            //                                                                                      TAC ID, Acct Country, Acct Group, Acct Size, EmpSize, Named Acct, Zip Start, Zip End, Sales Channel, Segment
            TerritoryAssignmentCode__c tacObj1 = TestDataSetupUtility.createTerritoryAssignmentCode(taObj.ID, 'United States', 'Telesales Acquisition', null, null, null, '05401', '05402', 'Partner', 'Commercial');

            tacList.add(tacObj1);

            insert tacList;

            TerritoryBatchHelper terrAssignObj = new TerritoryBatchHelper();
            terrAssignObj.AccountWithoutTerritory(accList);
            system.assertEquals([Select AccountId__c from Account where Id = : testAccount.Id].AccountId__c, accountId);
            Test.stopTest();
        }
    }
    static testmethod void unittest5()
    {

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        //User u = [select id,alias from User where ProfileId =: p.Id and isActive = true limit 1];
		User u = TestDataSetupUtility.createTestUser('TestFistName', 'TestLastName', p.Id);
        insert u;
        System.runAs(u)
        {
            Test.startTest();

            List<Account> accList = new List<Account>();
            Account testAccount = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TEST PB Account');//, 'North America', UserInfo.getUserId());
            testAccount.Phone = '+18008008000';
            testAccount.PrimaryServiceRep__c = u.id;
            testAccount.Organization__c = 'North America';
            testAccount.ServiceTier__c = 'Core';
            testAccount.DoNotReassign__c = false;
            testAccount.AccountGroup__c = 'Telesales Acquisition';
            testAccount.ShippingPostalCode = '05401-1234';
            testAccount.SalesChannel__c = 'Partner';
            testAccount.SalesChannel__c = 'Commercial';
            insert testAccount;

            testAccount.ShippingCountry = 'United States';
            testAccount.ShippingPostalCode = '05401-2345';
            update testAccount;

            accList.add(testAccount);

            system.debug('=====> accList : '+accList);
            String accountId = [Select AccountId__c from Account where Id = : testAccount.Id].AccountId__c;
            system.debug('=====> accList 1 : '+[Select AccountId__c from Account where Id = : testAccount.Id].AccountId__c);

            TerritoryAssignment__c taObj = new TerritoryAssignment__c();
            insert taObj;

            List<TerritoryAssignmentCode__c> tacList = new List<TerritoryAssignmentCode__c>();

            //                                                                                      TAC ID, Acct Country, Acct Group, Acct Size, EmpSize, Named Acct, Zip Start, Zip End, Sales Channel, Segment
            TerritoryAssignmentCode__c tacObj1 = TestDataSetupUtility.createTerritoryAssignmentCode(taObj.ID, 'United States', 'Telesales Acquisition', null, null, null, '05401', '05402', 'Partner', 'Commercial');

            tacList.add(tacObj1);

            insert tacList;

            TerritoryBatchHelper terrAssignObj = new TerritoryBatchHelper();
            terrAssignObj.AccountWithoutTerritory(accList);
            system.assertEquals([Select AccountId__c from Account where Id = : testAccount.Id].AccountId__c, accountId);
            Test.stopTest();
        }
    }
     static testmethod void unittest6()
    {

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        //User u = [select id,alias from User where ProfileId =: p.Id and isActive = true limit 1];
		User u = TestDataSetupUtility.createTestUser('TestFistName', 'TestLastName', p.Id);
        insert u;
        System.runAs(u)
        {
            Test.startTest();

            List<Account> accList = new List<Account>();
            Account testAccount = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TEST PB Account');//, 'North America', UserInfo.getUserId());
            testAccount.Phone = '+18008008000';
            testAccount.PrimaryServiceRep__c = u.id;
            testAccount.Organization__c = 'North America';
            testAccount.ServiceTier__c = 'Core';
            testAccount.DoNotReassign__c = false;
            testAccount.AccountGroup__c = 'Telesales Acquisition';
            testAccount.ShippingPostalCode = '05401-1234';
            testAccount.SalesChannel__c = 'Partner';
            testAccount.SalesChannel__c = 'Commercial';
            insert testAccount;

            testAccount.ShippingCountry = 'United States';
            testAccount.ShippingPostalCode = '05401-2345';
            update testAccount;

            accList.add(testAccount);

            system.debug('=====> accList : '+accList);
            String accountId = [Select AccountId__c from Account where Id = : testAccount.Id].AccountId__c;
            system.debug('=====> accList 1 : '+[Select AccountId__c from Account where Id = : testAccount.Id].AccountId__c);

            TerritoryAssignment__c taObj = new TerritoryAssignment__c();
            insert taObj;

            List<TerritoryAssignmentCode__c> tacList = new List<TerritoryAssignmentCode__c>();

            //                                                                                      TAC ID, Acct Country, Acct Group, Acct Size, EmpSize, Named Acct, Zip Start, Zip End, Sales Channel, Segment
            TerritoryAssignmentCode__c tacObj1 = TestDataSetupUtility.createTerritoryAssignmentCode(taObj.ID, 'United States', 'Telesales Acquisition', null, null, null, '05401', '05402', 'Partner', 'Commercial');

            tacList.add(tacObj1);

            insert tacList;

            TerritoryBatchHelper terrAssignObj = new TerritoryBatchHelper();
            terrAssignObj.AccountWithoutTerritory(accList);
            system.assertEquals([Select AccountId__c from Account where Id = : testAccount.Id].AccountId__c, accountId);
            Test.stopTest();
        }
    }
}