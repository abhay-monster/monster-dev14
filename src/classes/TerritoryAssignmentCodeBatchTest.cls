@isTest
public class TerritoryAssignmentCodeBatchTest {

    @testSetup
    static void preTestSetup(){
        insert TestDataSetupUtility.buildPersonalSetting();
        insert TestDataSetupUtility.buildZipcodeConfiguration('United States','ddddddddd','^\\d{5}(?:[-\\s]*\\d{4})?$','^\\d{5}(?:[-\\s]*\\d{4})?$');
        insert TestDataSetupUtility.buildZipcodeConfiguration('Canada','AdAdAd','^[A-Z]\\d[A-Z](?:\\s*\\d[A-Z]\\d)?$','^[A-Z]\\d[A-Z]\\s*\\d[A-Z]\\d$');


        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User runningUser = TestDataSetupUtility.createTestUser('TestRunFirst', 'TestRunLast', p.Id);
        User owningUser = TestDataSetupUtility.createTestUser('TestOwnerFirst', 'TestOwnerLast', p.Id);
        List<User> userList = new List<User>();
        userList.add(runningUser);
        userList.add(owningUser);
        insert userList;

        //Now lets insert the territory assignment objects
        TerritoryAssignment__c ta = TestDataSetupUtility.createTerritoryAssignment(owningUser.Id);
        insert ta;

        List<TerritoryAssignmentCode__c> tacList = new List<TerritoryAssignmentCode__c>();
        //                                                                                   TAC ID, Acct Country, Acct Group, Acct Size, EmpSize, Named Acct, Zip Start, Zip End, Sales Channel, Segment
        TerritoryAssignmentCode__c tac1 = TestDataSetupUtility.createTerritoryAssignmentCode(ta.ID, 'United States', 'Branch', null, null, null, '05401-1234', '05402', null, 'Commercial');
        tacList.add(tac1);
        TerritoryAssignmentCode__c tac2 = TestDataSetupUtility.createTerritoryAssignmentCode(ta.ID, 'Canada', null, 'Mid-Market', null, null, 'K7G 1R1', 'K7G 1R6', 'Telesales', null);
        tacList.add(tac2);
        insert tacList;
    }

    @isTest
    static void runTerritoryAssignment() {
        //we have to query our test users to get their details first
        User runningUser;
        for(User u: [Select Id, Name, LastName from User Where LastName='TestRunLast']){
                runningUser = u;
        }

        System.runAs(runningUser) {
            Test.startTest();

            //this is the real test
            TerritoryAssignmentCodeBatch batch = new TerritoryAssignmentCodeBatch();
            ID batchprocessid = Database.executeBatch(batch);

            Test.stopTest();
        }

        TerritoryAssignmentCode__c US;
        TerritoryAssignmentCode__c CA;

        for(TerritoryAssignmentCode__c tac: [Select Id, AccountCountry__c, PostingZipCodeStart__c, PostingZipCodeEnd__c,
        									 Zip_Code_Start_Number__c, Zip_Code_End_Number__c
                                             from TerritoryAssignmentCode__c]){
            if(tac.PostingZipCodeStart__c == '05401-1234'){
            	US=tac;
            }
            if(tac.PostingZipCodeStart__c == 'K7G 1R1'){
            	CA=tac;
            }
            system.debug('tac=' + tac);
        }

		System.assertEquals('United States', US.AccountCountry__c);
		System.assertEquals(54011234, US.Zip_Code_Start_Number__c);
		System.assertEquals('Canada', CA.AccountCountry__c);
		System.assertEquals(107061171, CA.Zip_Code_Start_Number__c);
    }
}