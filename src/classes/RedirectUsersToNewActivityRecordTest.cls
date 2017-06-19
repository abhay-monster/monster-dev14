@isTest

Private Class RedirectUsersToNewActivityRecordTest{
    static Account acc;
    static Opportunity opp;
    static Contact con;
    static Apttus_Proposal__Proposal__c proposal;
    static Profile_Permissions__c permission;
    static testmethod void testRedirectUsersToNewActivity(){
        prepareData();
        Test.startTest();
        ApexPages.currentPage().getParameters().put('Account_Id','');
        ApexPages.currentPage().getParameters().put('Opportunity_Id','');
        ApexPages.currentPage().getParameters().put('Contact_Id','');
        ApexPages.currentPage().getParameters().put('Proposal_Id','');
        
        
        ApexPages.StandardController std = new ApexPages.StandardController(acc);        
        ApexPages.currentPage().getParameters().put('Account_Id',acc.Id);
        ApexPages.currentPage().getParameters().put('Activity_type','Task');
        RedirectUsersToNewActivityRecord controller = new RedirectUsersToNewActivityRecord(std );
        controller.redirectUser();
        
        ApexPages.currentPage().getParameters().put('Contact_Id',con.Id);
        ApexPages.currentPage().getParameters().put('Activity_type','Event');
        controller = new RedirectUsersToNewActivityRecord(std );
        controller.redirectUser();
        
        ApexPages.currentPage().getParameters().put('Opportunity_Id',opp.Id);
        ApexPages.currentPage().getParameters().put('Activity_type','Event');
        
        permission.Task_Redirect__c = false;
        permission.Event_Redirect__c = false;
        update permission;
        controller = new RedirectUsersToNewActivityRecord(std );
        controller.redirectUser();
        
        ApexPages.currentPage().getParameters().put('Proposal_Id',proposal.Id);
        ApexPages.currentPage().getParameters().put('Activity_type','Task');
        controller = new RedirectUsersToNewActivityRecord(std );
        controller.redirectUser();
        
        ApexPages.currentPage().getParameters().put('Activity_type','Log A Call');
        controller = new RedirectUsersToNewActivityRecord(std );
        controller.redirectUser();
        
        ApexPages.currentPage().getParameters().put('Activity_type','Log A Call');
        permission.Task_Redirect__c = true;
        permission.Event_Redirect__c = true;        
        update permission;
        controller = new RedirectUsersToNewActivityRecord(std );
        controller.redirectUser();
       
        
        
        Test.stopTest();
    }
    
    static void prepareData(){
     acc = TestDataSetupUtility.createTestAccount('test',null,null);
     insert acc;
     
     opp = TestDataSetupUtility.createTestOpportunity('test',acc.Id);
     insert opp;
     
     con = TestDataSetupUtility.createTestContact(acc.Id,'test','test','abcd4545@gmail.com');
     insert con ;
     
     proposal = TestDataSetupUtility.createProposal(opp.Id);
     //proposal.Apttus_Proposal__Account__c = acc.Id;
     insert proposal ;
     
     permission = new Profile_Permissions__c ();
     permission.setupOwnerId = UserInfo.getProfileID();
     permission.Task_Redirect__c = true;
     permission.Event_Redirect__c = true;
     insert permission;
     
     
    } 

}