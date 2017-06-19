@isTest
private class CalculateBusinessHoursAges_Test {

static Case caseObj;
static testMethod void testBeforeInsert() {
    Test.startTest();
    prepareData();
    Case cs = [ SELECT Id,Time_With_Customer__c,Time_With_Support__c,Last_Status_Change__c
                FROM Case WHERE Id = :caseObj.Id ];
    //System.assert(cs.Last_Status_Change__c != null);
    System.assert(cs.Time_With_Customer__c == 0);
    System.assert(cs.Time_With_Support__c == 0);   
    
    Test.stopTest();
}

static testMethod void testBeforeUpdate() {
    Test.startTest();
    prepareData();
    caseObj.status = 'Open';
    update caseObj;
    Case cs = [ SELECT Id,Time_With_Customer__c,Time_With_Support__c,Last_Status_Change__c
                FROM Case WHERE Id = :caseObj.Id ];
  //  System.assert(cs.Time_With_Customer__c > 0);
    Test.stopTest();
}


static void prepareData(){
    Account acc = TestDataSetupUtility.createTestAccount('test',null,null);
    insert acc;
    Contact con = TestDataSetupUtility.createTestContact(acc.Id,'test','Con','abccon@gmail.com'); 
    insert con;
    
    Stop_Status__c ss = new Stop_Status__c(name = 'New');
    insert ss;
    
    caseObj = new Case(
                AccountId = acc.Id,
                ContactId = con.Id,
                Status = 'New',
                Category__c = 'Browser Issue',
                Issue__c = 'Other',
                SubIssue__c = 'Other',
                Subject = 'TEST Subject Parent',
                CustomerProblemDetail__c = 'TEST Details Parent'
     );

     insert caseObj;
}


}