/**
* @author Original: Robby Angeles
* @date Original: 20 DEC 2014 
* @description Test Class for removing account to program relationship
*/ 
@isTest
public with sharing class RemoveAccountToProgramCCTest {
    /*
    * 
    * @author Original: Robby Angeles  
    * @date Original: 20 DEC 2014 
    * @description verifies removal of account to program relationship
    */ 
    public static testMethod void testAccountProgramRelationshipRemoval(){
        //build test data
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User testUser = TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);
        insert testUser;
        //test accounts
        list<Account> accList = new list<Account>();
        for(Integer i=0;i<10;i++){
            accList.add(TestDataSetupUtility.createTestAccount('TESTACC ' + i, 'TESTORG ' + i, testUser.Id));
        }        
        insert accList;

        //test program
        Program__c prog = TestDataSetupUtility.createAccountProgram('Test Program');
        insert prog;
        
        //assign program to accounts;
        for(Account acc:accList){
            acc.AccountProgram__c = prog.Id;
        }
        update accList;
        
        Test.startTest();
          //reference page and page controller passing the program id and account id
          Test.setCurrentPage(Page.RemoveAccountToProgram);
          ApexPages.currentPage().getParameters().put('accId', accList[0].Id);
          ApexPages.currentPage().getParameters().put('prgId', prog.Id);
        
          //reference page controller
          RemoveAccountToProgramCC contAccToProg = new RemoveAccountToProgramCC(); 
          contAccToProg.removeAccountToProgram();
        Test.stopTest();
        
        //assert number of accounts related to program is less by 1.
        Integer accCnt = 0;
        for(Account acc :[select Id from Account where AccountProgram__c =:prog.Id]){
            accCnt++;
        }
        system.assert(accCnt == 9);
    }
    
    /** 
    * @author Original: Robby Angeles  
    * @date Original: 20 DEC 2014 
    * @description force exception on the page
    */ 
    public static testMethod void testExceptionHandling(){
        //test program
        Program__c prog = TestDataSetupUtility.createAccountProgram('Test Program');
        insert prog;
        
        Test.startTest();
          //specify an invalid Id
          //reference page and page controller passing the program id and account id
          Test.setCurrentPage(Page.RemoveAccountToProgram);
          ApexPages.currentPage().getParameters().put('accId', 'INVALIDID');
          ApexPages.currentPage().getParameters().put('prgId', prog.Id);
            
          //reference page controller
          RemoveAccountToProgramCC contAccToProg = new RemoveAccountToProgramCC(); 
          contAccToProg.removeAccountToProgram();
        Test.stopTest();
        
        //Verify error message on page
        for(Log__c lg :[select Id, Error_Record_Id__c, Message__c 
                        from Log__c 
                        order by lastmodifieddate desc limit 1]){
            system.debug('@@1 ' + lg.Error_Record_Id__c);
            system.debug('@@2 ' + lg.Message__c);
        }
    } 
}