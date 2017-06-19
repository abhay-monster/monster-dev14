/***************************************************************************************************************************
 * Class Name   : KnowledgeModelTest
 * Created By   : Rohit B. (Appirio)
 * Class Purpose: Test class of KnowledgeModel class 
 * Created Date : July 20, 2015
 * 
 * Class Date Modified          Modified By                     Description of the update
 * 07/Sept/2015                 Rohit B (Appirio)               Modified setupData function; Created knowledgeUser
****************************************************************************************************************************/
@isTest
private class KnowledgeModelTest {
    
    @isTest 
    static void getTrainingAndTutorialData_IsTest() {
        User usrTest = [Select Id from User where Profile.Name =: 'System Administrator' and isActive = true limit 1];
        system.runAs(usrTest) {
            Test.startTest();
                System.assert(KnowledgeModel.getTrainingAndTutorialData('en_US') != NULL);
            Test.stopTest();

        } // END system.runAs(usrTest) {
    } // END static void getTrainingAndTutorialData_IsTest() {
    
    @testSetup
    static void setupData() {
        //User usr = [SELECT Id, Name from User WHERE Profile.Name =: 'System Administrator' and isActive = true LIMIT 1];
        Account acc = new Account (
            Name = 'newAcc1'
        );  
        //insert acc;

        Contact con = new Contact (
            AccountId = acc.id,
            Email='test123@gmail.com',
            LastName = 'portalTestUser'
        );


        Profile p = [select Id,name from Profile where Profile.Name =: 'System Administrator' limit 1];
        UserRole uRole = [select Id,name from UserRole limit 1];
        User user = TestDataSetupUtility.createTestUser('Bobbart ', 'McKnowledge', p.Id);
        user.userRoleId = uRole.Id;
        user.ContactId = con.Id;
        user.userPermissionsKnowledgeUser = true; 

/*
        new User(
            profileId = p.id,
            userroleId = uRole.Id,      //Added by Rohit B on 07/Sept/2015 
            username = 'newUser@yahoo.com ' ,
            email = 'pb@ff.com',
            emailencodingkey = 'UTF-8',
            localesidkey = 'en_US',
            languagelocalekey = 'en_US',
            timezonesidkey = 'America/Los_Angeles',
            alias='nuser',
            lastname='lastname',
            contactId = con.id,
            userPermissionsKnowledgeUser = true
        );*/
        
        System.runAs(user) {
            Knowledge_Parent_Article__c parentKPA = new Knowledge_Parent_Article__c (
                Section_Title__c = 'Test Parent Section Title',
                LanguageCode__c = 'en_US'
            );
            insert parentKPA;
    
            Knowledge_Parent_Article__c childKPA = new Knowledge_Parent_Article__c (
                Section_Title__c = 'Test Child Section Title',
                Section_Header__c = parentKPA.Id,
                LanguageCode__c = 'en_US'
            );
            insert childKPA;
            
            String hashString = '1000' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
            Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
            String hexDigest = EncodingUtil.convertToHex(hash);

            Training_Tutorial__kav TT = new Training_Tutorial__kav(
                Title = 'Test Title', 
                Knowledge_Parent_Article__c = childKPA.Id, 
                Summary = 'Test Summary', 
                ArticleBody__c = 'Test Body',
                PDF__c = 'Something', 
                Purple_Link__c = 'Purple Link', 
                Green_Link__c = 'Green Link', 
                Blue_Link__c = 'Blue Link', 
                Doc__c = 'Something',
                UrlName = hexDigest 
            );
            insert TT;
    
            Training_Tutorial__kav insertedTT = [Select KnowledgeArticleId from Training_Tutorial__kav where ID =: TT.Id];
    
            KbManagement.PublishingService.publishArticle(insertedTT.KnowledgeArticleId, true);
        } // END System.runAs(usr) {
    } // END static void setupData() {
} // END private class KnowledgeModelTest {