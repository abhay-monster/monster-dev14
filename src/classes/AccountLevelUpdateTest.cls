/**
* @author Original: Robby Angeles
* @date Original: 5 DEC 2014 
* @description Test Class for scheduling batch of account level update.
*/
@isTest
public with sharing class AccountLevelUpdateTest {
    /** 
    * @author Original: Robby Angeles  
    * @date Original: 5 DEC 2014 
    * @description verifies correct update on account level values
    */
    public static testMethod void testAccountLevelUpdateBatch(){
        //build custom setting
        Account_Level_Values__c accValSettings = TestDataSetupUtility.buildAccountLevelSetting();
        accValSettings.query__c = 'Select Id, Level__c, Purchasing_Account_Flag__c, ParentId from Account WHERE recordtype.name != \'Person Account\' AND LevelNeedsUpdating__c = true limit 5';
        insert accValSettings;
        //build test data
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User testUser = TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);
        insert testUser;
        //test parent accounts
        list<Account> accParList = new list<Account>();
        list<Contact> conList = new list<Contact>();
        for(Integer i=0;i<100;i++){
            accParList.add(TestDataSetupUtility.createTestAccount('TESTACC ' + i, 'TESTORG ' + i, testUser.Id));
        }  
        insert accParList;
        
        for(Integer i=0;i<100;i++){
            conList.add(TestDataSetupUtility.createTestContact(accParList[i].Id, 'confirst1', 'conlast1', 'con1@email.com'));
        }  
        insert conList;
        
        //test child accounts
        list<Account> accChildList = new list<Account>();
        for(Integer i=0;i<20;i++){
            Account child = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TESTACCCCH ' + i);
            //child.BillingState = 'UTAH'; 
            //child.BillingCity = 'NYC';
            child.ParentId = accParList[i].Id;
            accChildList.add(child);
        }  
        system.debug('Check ' + accChildList);
        insert accChildList;
        
        Test.startTest();
        //test orders    
        list<Order__c> ordList = new list<Order__c>();
        //build orders for child accounts
        for(Integer i=0;i<20;i++){
            Order__c tempOrd = TestDataSetupUtility.createOrder(accChildList[i].Id, conList[i].Id);
            system.debug('Check' + tempOrd );
            if(i<10){
                tempOrd.OrderStatus__c = accValSettings.Purchasing_Account_Test_Value__c;
            }
            else if(i < 20){ 
                tempOrd.OrderStatus__c = accValSettings.Non_Purchasing_Account_Test_Value__c;
            }
            ordList.add(tempOrd);
        }
        //build orders for parent accounts
        for(Integer i=0;i<40;i++){
            Order__c tempOrd = TestDataSetupUtility.createOrder(accParList[i].Id, conList[i].Id);
            if(i < 10){
                tempOrd.OrderStatus__c = accValSettings.Purchasing_Account_Test_Value__c;
            }
            else if(i < 20){ 
                tempOrd.OrderStatus__c = accValSettings.Non_Purchasing_Account_Test_Value__c;
            }
            else if(i < 30){
                tempOrd.OrderStatus__c = accValSettings.Purchasing_Account_Test_Value__c;
            }
            else if(i < 40){ 
                tempOrd.OrderStatus__c = accValSettings.Non_Purchasing_Account_Test_Value__c;
            }
            ordList.add(tempOrd);
        }
        insert ordList;
        
        //collate parent account and child account ids for assertion after tests
        set<Id> allAccIdsSet = new set<Id>();
        //ids for purchasing parent
        set<Id> purParIdsSet = new set<Id>();
        //ids for purchasing child
        set<Id> purChdIdsSet = new set<Id>();
        //ids for purchasing stand alone
        set<Id> purSAIdsSet = new set<Id>();
        //ids for non-purchasing parent
        set<Id> nonPurParIdsSet = new set<Id>();
        //ids for non-purchasing child
        set<Id> nonPurChdIdsSet = new set<Id>();
        //ids for non-purchasing stand alone
        set<Id> nonPurSAIdsSet = new set<Id>();
        
        //collect child account Ids
        for(Integer i = 0 ; i < 20; i++){
            allAccIdsSet.add(accChildList[i].Id);
            if(i < 10){
                //purchasing child
                purChdIdsSet.add(accChildList[i].Id);
            }
            else{
                //non purchasing child
                nonPurChdIdsSet.add(accChildList[i].Id);
            }
        }
        
        //collect parent account Ids
        for(Integer i = 0 ; i < 100; i++){
            allAccIdsSet.add(accParList[i].Id);
            if(i < 10){
                //purchasing parent
                purParIdsSet.add(accParList[i].Id);
            }
            else if(i < 20){
                //non-purchasing parent
                nonPurParIdsSet.add(accParList[i].Id);
            }
            else if(i < 30){
                //purchasing standalone
                purSAIdsSet.add(accParList[i].Id);
            }
            else if(i < 40){
                //non-purchasing standalone
                nonPurSAIdsSet.add(accParList[i].Id);
            }
        }
        
        AccountLevelUpdate accLevelBatch = new AccountLevelUpdate();
       
           //Run batchable class
           database.executebatch(accLevelBatch);
        Test.stopTest();
        //assert account level values are correct.
     /*   for(Account acc : [select Id, Level__c from Account where Id IN :allAccIdsSet]){
            if(purParIdsSet.contains(acc.Id)){
                system.assertEquals(acc.Level__c, accValSettings.Purchasing_Parent__c);
            }
            else if(nonPurParIdsSet.contains(acc.Id)){
                system.assertEquals(acc.Level__c, accValSettings.Non_Purchasing_Parent__c);
            }
            else if(purSAIdsSet.contains(acc.Id)){
                system.assertEquals(acc.Level__c, accValSettings.Purchasing_Stand_Alone__c);
            }
            else if(nonPurSAIdsSet.contains(acc.Id)){
                system.assertEquals(acc.Level__c, accValSettings.Non_Purchasing_Stand_Alone__c);
            }
            else if(purChdIdsSet.contains(acc.Id)){
                system.assertEquals(acc.Level__c, accValSettings.Purchasing_Child__c);
            }
            else if(nonPurChdIdsSet.contains(acc.Id)){
                system.assertEquals(acc.Level__c, accValSettings.Non_Purchasing_Child__c);
            }
            else{
                //remaining 60 accounts are non purchasing stand alones
                system.assertEquals(acc.Level__c, accValSettings.Non_Purchasing_Stand_Alone__c);
            }
        } */
    }
    
    /** 
    * @author Original: Robby Angeles  
    * @date Original: 9 DEC 2014 
    * @description verifies error handling if account level custom setting does not exist.
    */
    public static testMethod void testAccountLevelSettingCheck(){
        //build custom setting
        Account_Level_Values__c accValSettings = TestDataSetupUtility.buildAccountLevelSetting();
        accValSettings.query__c = 'Select Id, Level__c, Purchasing_Account_Flag__c, ParentId from Account WHERE recordtype.name != \'Person Account\' AND LevelNeedsUpdating__c = true limit 5';
        insert accValSettings;
        
        //build test data
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User testUser = TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);
        insert testUser;
        //test parent accounts
        list<Account> accParList = new list<Account>();
        for(Integer i=0;i<10;i++){
            accParList.add(TestDataSetupUtility.createTestAccount('TESTACC ' + i, 'TESTORG ' + i, testUser.Id));
        }  
        insert accParList;  
         
        AccountLevelUpdate accLevelBatch = new AccountLevelUpdate();
       
        Test.startTest();
           //Run batchable class
           database.executebatch(accLevelBatch);
        Test.stopTest();
        for(Log__c log : [select Id,Message__c from Log__c order by createddate desc LIMIT 1]){
            //verify error message on missing custom setting value is catched 
            system.assert(log.Message__c.contains(Label.CS_AccLevelUpd_BlankLvlValue));
        }
    }  
}