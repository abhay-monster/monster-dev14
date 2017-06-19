@isTest
private class AccountTeamMemberTriggerHandlerTest{

    static testMethod void accountTeamMemberTest(){
  
    User u1 = [SELECT Id FROM User WHERE profileId IN (SELECT id FROM Profile WHERE Name = 'System Administrator') AND isActive = TRUE LIMIT 1];
    System.RunAs(u1){ 
        Test.startTest(); 
        AccountTeamMemberTriggerHandler accountHandler = new AccountTeamMemberTriggerHandler(true,4);
        List<Account_Team_Member__c> memberLst = new List<Account_Team_Member__c>();
        Account a= new account(name='test',billingcountry='india');
        try{
            insert a;
        }catch(Exception e){
            system.assert(false,'Task not created');
        }
    
        User userId1 = [SELECT id,name FROM USER WHERE id =:UserInfo.getUserId()];
        Personal_Settings__c setting = new Personal_Settings__c();
        setting.Trigger_Account_Team_Members__c = true;
        try{
            insert setting ;
        }catch(Exception e){
            system.assert(false,'Account not Inserted');
        }
        
        accountteammember atm= new accountteammember();
        atm.AccountId=a.id;
        atm.userid= userId1.Id;
        atm.teammemberrole='Primary Service Rep';
        try{
            insert atm;  
        }catch(Exception e){
            system.assert(false,'AccountteammeberNotinserted');
        }  
           
        Account_Team_Member__c member = new Account_Team_Member__c();
        member.AccountId__c = a.id;
        member.UserId__c = userId1.Id;
        member.TeamMemberRole__c = 'Primary Service Rep';
        try{
            insert member ;
            memberLst.add(member );
        }catch(Exception e){
        system.assert(false,'Team Member not Inserted');
        }
    
        try{
            member.TeamMemberRole__c = 'Channel Manager'; 
            update member;
            accountHandler.OnUndeleted(memberLst);
            delete member;
        }catch(Exception e){
        system.assert(false,'Problem Updating team member');
        }
        
      Test.stopTest();
        } 
    }
    
    static testMethod void testDuplicateAccountTeamMember(){
  
    User u1 = [SELECT Id FROM User WHERE profileId IN (SELECT id FROM Profile WHERE Name = 'System Administrator') AND isActive = TRUE LIMIT 1];
    System.RunAs(u1){ 
        Test.startTest(); 
        AccountTeamMemberTriggerHandler accountHandler = new AccountTeamMemberTriggerHandler(true,4);
        List<Account_Team_Member__c> memberLst = new List<Account_Team_Member__c>();
        Account a= new account(name='test',billingcountry='india');
        try{
            insert a;
        }catch(Exception e){
            system.assert(false,'Task not created');
        }
    
        User userId1 = [SELECT id,name FROM USER WHERE id =:UserInfo.getUserId()];
        Personal_Settings__c setting = new Personal_Settings__c();
        setting.Trigger_Account_Team_Members__c = true;
        try{
            insert setting ;
        }catch(Exception e){
            system.assert(false,'Account not Inserted');
        }
        
        accountteammember atm= new accountteammember();
        atm.AccountId=a.id;
        atm.userid= userId1.Id;
        atm.teammemberrole='Primary Service Rep';
        try{
            insert atm;  
        }catch(Exception e){
            system.assert(false,'AccountteammeberNotinserted');
        }  
           
        Account_Team_Member__c member = new Account_Team_Member__c();
        member.AccountId__c = a.id;
        member.UserId__c = userId1.Id;
        member.TeamMemberRole__c = 'Primary Service Rep';
        try{
            insert member ;
            memberLst.add(member );
        }catch(Exception e){
        system.assert(false,'Team Member not Inserted');
        }
    
        member = new Account_Team_Member__c();
        member.AccountId__c = a.id;
        member.UserId__c = userId1.Id;
        member.TeamMemberRole__c = 'Primary Service Rep';
        try{
            insert member ;
            memberLst.add(member );
        }catch(Exception e){
        system.assert(true);
        }
        
      Test.stopTest();
        } 
    }
    
    // Method Test trigger functionality with User of profile - Sales Operations (TA)
    static testMethod void testWithSalesOperations(){ 
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Operations (TA)' LIMIT 1];
    User testUser = TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);
    insert testUser;
    system.runas(testUser){
    
    Test.startTest();
    
        AccountTeamMemberTriggerHandler accountHandler = new AccountTeamMemberTriggerHandler(true,4);
        List<Account_Team_Member__c> memberLst = new List<Account_Team_Member__c>();
        Account a= new account(name='test',billingcountry='india');
        try{
            insert a;
        }catch(Exception e){
            system.assert(false,'Task not created');
        }
    
        User userId1 = [SELECT id,name FROM USER WHERE id =:UserInfo.getUserId()];
        Personal_Settings__c setting = new Personal_Settings__c();
        setting.Trigger_Account_Team_Members__c = true;
        try{
            insert setting ;
        }catch(Exception e){
            system.assert(false,'Account not Inserted');
        }
        
        AccountTeamMember atm= new AccountTeamMember();
        atm.AccountId=a.id;
        atm.userid= userId1.Id;
        atm.teammemberrole='Primary Service Rep';
        try{
            insert atm;  
        }catch(Exception e){
            system.assert(false);
        }   
        
        Account_Team_Member__c member = new Account_Team_Member__c();
        member.AccountId__c = a.id;
        member.UserId__c = userId1.Id;
        member.TeamMemberRole__c = 'Primary Service Rep';
        try{
            insert member ;
        }catch(Exception e){
        system.assert(true);
        }   
        Test.stopTest();
        } 
    }
    
    // Method Test trigger functionality with User of profile - Sales Operations (TA)
    /*static testMethod void testWithoutTriggerSetting(){ 
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Operations (TA)' LIMIT 1];
    User testUser = TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);
    insert testUser;
    system.runas(testUser){
    
    Test.startTest();
    
        AccountTeamMemberTriggerHandler accountHandler = new AccountTeamMemberTriggerHandler(true,4);
        List<Account_Team_Member__c> memberLst = new List<Account_Team_Member__c>();
        Account a= new account(name='test',billingcountry='india');
        try{
            insert a;
        }catch(Exception e){
            system.assert(false,'Task not created');
        }
    
        User userId1 = [SELECT id,name FROM USER WHERE id =:UserInfo.getUserId()];
        Personal_Settings__c setting = new Personal_Settings__c();
        setting.Trigger_Account_Team_Members__c = false;
        try{
            insert setting ;
        }catch(Exception e){
            system.assert(false,'Account not Inserted');
        }
        
        AccountTeamMember atm= new AccountTeamMember();
        atm.AccountId=a.id;
        atm.userid= userId1.Id;
        atm.teammemberrole='Primary Service Rep';
        try{
            insert atm;  
        }catch(Exception e){
            system.assert(false);
        }      
        Test.stopTest();
        } 
    }*/
}