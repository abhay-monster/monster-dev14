@isTest
public class TerritoryAssignmentBatchTest {
	static final Integer BULK_RECORD_LIMIT = 100;
    static final String SOBJECT_EVENT = 'Event';
    static final String EVENT_RECORD_TYPE_ACTION_PLAN_EVENT = 'Action Plan Event';
    static final Datetime SYSTEM_CURRENT_TIME = System.now().addSeconds(300);

    @testSetup
    static void preTestSetup(){
        insert TestDataSetupUtility.buildPersonalSetting();
        TestDataSetupUtility.buildTaxNowCustomSetting();
        insert TestDataSetupUtility.buildZipcodeConfiguration('United States','ddddddddd','^\\d{5}(?:[-\\s]*\\d{4})?$','^\\d{5}(?:[-\\s]*\\d{4})?$');
        insert TestDataSetupUtility.buildZipcodeConfiguration('Canada','AdAdAd','^[A-Z]\\d[A-Z](?:\\s*\\d[A-Z]\\d)?$','^[A-Z]\\d[A-Z]\\s*\\d[A-Z]\\d$');


        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User runningUser = TestDataSetupUtility.createTestUser('TestRunFirst', 'TestRunLast', p.Id);
        User owningUser = TestDataSetupUtility.createTestUser('TestOwnerFirst', 'TestOwnerLast', p.Id);
        List<User> userList = new List<User>();
        userList.add(runningUser);
        userList.add(owningUser);
        insert userList;

        //Next up is inserting our various test accounts
        List<Account> accInsertList = new List<Account>();
        /*JHF Appirio I-190489 Do not include zipcode evaluation for batch runs
        Account testZipCodeAccount = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TEST Territory Account');
        testZipCodeAccount.Name = 'TEST Territory Account';
        testZipCodeAccount.ShippingPostalCode = '11111';
        accInsertList.add(testZipCodeAccount);*/

        Account testNamedAccount = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Named Account');
        testNamedAccount.Name = 'Test Named Account';
        accInsertList.add(testNamedAccount);

        /*JHF Appirio I-190489 Do not include zipcode evaluation for batch runs
        Account testCriteriaAccount = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Testing Criteria Account');
        testCriteriaAccount.Name ='Testing Criteria Account';
        testCriteriaAccount.ShippingCountry = 'United States';
        testCriteriaAccount.AccountGroup__c = 'ECOMM';
        testCriteriaAccount.SalesChannel__c = 'ECOMM';
        testCriteriaAccount.ShippingPostalCode = '12345';
        accInsertList.add(testCriteriaAccount);*/

        Account nonMatchingAccount = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Non Matching testing Account');
        nonMatchingAccount.name = 'Non Matching testing Account';
        nonMatchingAccount.ShippingPostalCode = '12345';
        nonMatchingAccount.AccountGroup__c = 'Telesales';

        accInsertList.add(nonMatchingAccount);

        insert accInsertList;

        //Now lets insert the territory assignment objects
        TerritoryAssignment__c ta = TestDataSetupUtility.createTerritoryAssignment(owningUser.Id);
        insert ta;

        List<TerritoryAssignmentCode__c> tacList = new List<TerritoryAssignmentCode__c>();
        //                                                                                   TAC ID, Acct Country, Acct Group, Acct Size, EmpSize, Named Acct, Zip Start, Zip End, Sales Channel, Segment
        TerritoryAssignmentCode__c tac1 = TestDataSetupUtility.createTerritoryAssignmentCode(ta.ID, 'United States', 'Branch', null, null, null, '11111', '11112', 'Fieldsales', null);
        tacList.add(tac1);
        TerritoryAssignmentCode__c tac2 = TestDataSetupUtility.createTerritoryAssignmentCode(ta.ID, 'United States', 'ECOMM', null, null, null, '12344', '12345', 'ECOMM', null);
        tacList.add(tac2);

        //For the named account we need to get the AccountId before we insert the Territory Assignment Code
        testNamedAccount = [Select ID, AccountID__c from Account where Id = :testNamedAccount.Id Limit 1];
        TerritoryAssignmentCode__c tac3 = TestDataSetupUtility.createTerritoryAssignmentCode(ta.ID, null, null, null, null, testNamedAccount.AccountID__c, null, null, null, null);
        tacList.add(tac3);

        insert tacList;

        //now finally lets do the Team Member portion
        TerritoryAssignmentTeamMember__c tam = TestDataSetupUtility.createTerritoryAssignmentTeamMember(ta.Id, runningUser.Id);
        insert tam;

    }

    @isTest
    static void runTerritoryAssignment() {
        //we have to query our test users to get their details first
        User runningUser;
        User owningUser;
        for(User u: [Select Id, Name, LastName from User Where LastName='TestRunLast' OR LastName='TestOwnerLast']){
            if(u.LastName == 'TestRunLast'){
                runningUser = u;
            }
            if(u.LastName == 'TestOwnerLast'){
                owningUser = u;
            }
        }

        System.runAs(runningUser) {

            Test.startTest();


            //this is the real test
            TerritoryAssignmentBatch batch = new TerritoryAssignmentBatch();
            ID batchprocessid = Database.executeBatch(batch);

            Test.stopTest();
        }

        //now lets do our asserts!
        //First lets query our accounts
        //Account testZipCodeAccount;
        Account testNamedAccount;
        //Account testCriteriaAccount;
        ACcount nonMatchingAccount;

        Set<Id> accIdSet = new Set<Id>();
        For(Account a : [Select Id, OwnerId, Name FROM Account]){
            system.debug('Name of Account? ' + Account.Name);
            /*if(a.Name == 'TEST Territory Account'){
                testZipCodeAccount = a;
            }*/
            if(a.Name =='Test Named Account'){
                testNamedAccount = a;
            }
            /*if(a.Name =='Testing Criteria Account'){
                testCriteriaAccount = a;
            }*/
            if(a.Name =='Non Matching testing Account'){
                nonMatchingAccount = a;
            }
            accIdSet.add(a.Id);
        }

        //now that we have the accounts lets check the Account Team Members
        Map<Id,Account_Team_Member__c> actToTeam = new Map<Id,Account_Team_Member__c>();
        For(Account_Team_Member__c atm : [SELECT Id, AccountId__c, UserId__c FROM Account_Team_Member__c
                                                    WHERE AccountId__c in :accIdSet
                                                    AND UserId__c = :runningUser.Id]){
            actToTeam.put(atm.AccountId__c, atm);
        }


        //Now for our Asserts
        //System.assertEquals(owningUser.Id, testZipCodeAccount.OwnerId);
        System.assertEquals(owningUser.Id, testNamedAccount.OwnerId);
        //System.assertEquals(owningUser.Id, testCriteriaAccount.OwnerId);
        System.assertNotEquals(owningUser.Id, nonMatchingAccount.OwnerId);

        //System.assertEquals(runningUser.Id, actToTeam.get(testZipCodeAccount.Id).UserId__c );
        System.assertEquals(runningUser.Id, actToTeam.get(testNamedAccount.Id).UserId__c );
        //System.assertEquals(runningUser.Id, actToTeam.get(testCriteriaAccount.Id).UserId__c );
        System.assertEquals(null,actToTeam.get(nonMatchingAccount.Id));

    }

    @isTest
    static void batchScheduleTest(){
        Test.startTest();
        //this is in here just to cover the schedule class
        String chronExpression = '' + SYSTEM_CURRENT_TIME.second() + ' ' + SYSTEM_CURRENT_TIME.minute() + ' ' + SYSTEM_CURRENT_TIME.hour() + ' ' + SYSTEM_CURRENT_TIME.day() + ' ' + SYSTEM_CURRENT_TIME.month() + ' ? ' + SYSTEM_CURRENT_TIME.year();
        String jobId = system.schedule('TerritoryAssignmentSchedule Test Class', chronExpression, new TerritoryAssignmentSchedule());
        CronTrigger ct = [Select Id, CronExpression, TimesTriggered, NextFireTime
                            FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(chronExpression, ct.CronExpression);

        Test.stopTest();

    }
}