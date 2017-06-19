@isTest
private class UpdateCaseOwnersTest{

    static testMethod void testUnitMethod(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User usr =  TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);
        insert usr;
        Id personAccountId = TestDataSetupUtility.getRecordTypeId('Person Account','Account');
        Account testPersonAcc = TestDataSetupUtility.createTestAccountWithShipping('PersonAcc');
        insert testPersonAcc;
        Case cse = TestDataSetupUtility.createTestNewAccountRequestCase('Europe',usr.Id);
        cse.AccountId = testPersonAcc.Id;
        System.runAs(usr){
            insert cse;
        }
        Test.startTest();
        ID[]caseIdList = new List<Id>{cse.Id};
//        caseIdList.add(cse.Id);

        UpdateCaseOwners.determineCaseOwnership( caseIdList);
        UpdateCaseOwners.updateCaseOwnership( caseIdList);
        
        Test.stopTest();
    }

}