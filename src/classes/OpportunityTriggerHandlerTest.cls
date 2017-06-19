@isTest
private class OpportunityTriggerHandlerTest {

    private static Account testAccount;
    private static Account testAcc;
    private static list<User> testUsers;

    static{
        testUsers = createTestUsers();
        testAccount = createTestAccount();
        testAcc = createTestAccount();
        testAcc.AgencyFlag__c = true;
        testAcc.CreditStatus__c = 'OK';
        update testAcc;

    }

    public static list<User> createTestUsers(){
        list<User> tUserList = new list<User>();

        Profile tProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Sales Rep (NA)' LIMIT 1];

        User tUser1 = TestDataSetupUtility.createTestUser('FName1', 'Testing1', tProfile.Id);
        tUserList.add(tUser1);

        User tUser2 = TestDataSetupUtility.createTestUser('FName2', 'Testing2', tProfile.Id);
        tUserList.add(tUser2);

        insert tUserList;
        return tUserList;
    }

    public static Account createTestAccount(){

        Account tAccount = new Account();
        tAccount.Name ='testAccount';
        tAccount.OwnerId = testUsers[0].Id;



        insert tAccount;
        return tAccount;
    }

    static testMethod void updateSkipValidationToFalseTest() {
        Personal_Settings__c ps = new Personal_Settings__c();
        ps.trigger_opportunity__c = true;
        insert ps;

        Method_Kill_List__c testCustomSetting = new Method_Kill_List__c(Name='updateOpptySplit', Kill_Method__c=false);
        insert testCustomSetting;

        Opportunity opp =  new Opportunity();

        opp.Skip_Stage_Validation__c = true;
        opp.AccountId = testAccount.Id;
        opp.Name = 'testOppty';
        opp.OwnerId = testUsers[1].Id;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Opportunity Dummy Record Type').getRecordTypeId();
        DateTime dt2 = system.now().addDays(10);
        opp.CloseDate = dt2.date();
        opp.StageName = 'Lead';

        Test.startTest();
        insert opp;
        Apttus_Proposal__Proposal__c prop = TestDataSetupUtility.createApttusProposal(opp);
        //insert prop;

        //opp = [select id,]
        OpportunityTriggerHandler.RunCount = 0;
        BaseTriggerHandler.SkipOppUpdateToPreventRecursion = false;
        OpportunityTriggerHandler.SKIP_OPPORTUNITY_UPDATE = false;
        OpportunityTriggerHandler.ExecuteTriggers = true;
        //opp.Skip_Stage_Validation__c = false;
        System.debug('oldowner::'+opp.OwnerId +'new::'+ testUsers[0].Id);
        opp.OwnerId = testUsers[0].Id;
        opp.SecondarySalesRep__c = testUsers[1].Id;
        update opp;

        OpportunityTriggerHandler.RunCount = 0;
        BaseTriggerHandler.SkipOppUpdateToPreventRecursion = false;
        OpportunityTriggerHandler.SKIP_OPPORTUNITY_UPDATE = false;
        OpportunityTriggerHandler.ExecuteTriggers = true;
        opp.IsValidationRequest__c = true;

        try{
        update opp;
        }catch(Exception e){}

        delete opp;
        undelete opp;
        Test.stopTest();

    }

    static testMethod void OnBeforeInsertUnitTest() {

       Profile proSysAdm = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

       User tUserSysAdm = TestDataSetupUtility.createTestUser('FName1', 'Testing1', proSysAdm.Id);


       System.runAs(tUserSysAdm){

        Personal_Settings__c ps = new Personal_Settings__c();
        ps.trigger_opportunity__c = true;
        insert ps;

        Method_Kill_List__c testCustomSetting = new Method_Kill_List__c(Name='updateOpptySplit', Kill_Method__c=false);
        insert testCustomSetting;


        Opportunity testOppty = new Opportunity();

        testOppty.AccountId = testAccount.Id;
        testOppty.Name = 'testOppty';
        testOppty.OwnerId = testUsers[1].Id;
        testOppty.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Opportunity').getRecordTypeId();
        DateTime dt = system.now().addDays(10);
        testOppty.CloseDate = dt.date();
        testOppty.StageName = 'Lead';

        insert testOppty;
        AccountTeamMember actMember = new AccountTeamMember();
        actMember.AccountId = testAccount.Id;
        actMember.TeamMemberRole = 'Sales';
        actMember.UserId = testUsers[1].Id;
        insert actMember;

        Opportunity testOppty1 = new Opportunity();

        testOppty1.AccountId = testAccount.Id;
        testOppty1.Name = 'testOppty';
        testOppty1.OwnerId = testUsers[1].Id;
        testOppty1.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Opportunity Dummy Record Type').getRecordTypeId();
        DateTime dt2 = system.now().addDays(10);
        testOppty1.CloseDate = dt2.date();
        testOppty1.StageName = 'Lead';

        insert testOppty1;

        AccountShare ActShare = new AccountShare();
        //ActShare.RowCause = 'Rule';
        ActShare.AccountId = testAccount.Id;
        ActShare.OpportunityAccessLevel = 'Edit';
        ActShare.UserOrGroupId =  testUsers[1].Id;
        ActShare.AccountAccessLevel = 'Edit';
        insert ActShare;

        testOppty.Name = 'testOppty1';
        testOppty.Agency__c = testAcc.Id;
        update testOppty;

        Opportunity newOppty = [Select Id, OwnerId FROM Opportunity WHERE Id = :testOppty.Id];
        System.Assert(newOppty.OwnerId == testUsers[1].Id);

        delete newOppty ;

        undelete newOppty ;
       }
    }
    
    //S-418868 Modified By - Appttus Support || Date: 2016-10-11
    static testMethod void updateQuptesForStage3Test() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        insert manager;
        User testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        testUser.Discount_Threshold__c  = 10.0;
        testUser.Apttus_Approval_Escalation__c  = true;
        insert testuser;

        Method_Kill_List__c testCustomSetting = new Method_Kill_List__c(Name='updateOpptySplit', Kill_Method__c=false);
        insert testCustomSetting;
        
        System.runAs(testUser){
            
             // Create test account
            Account account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
            insert account;
            
            PageReference pageRef = Page.ProposalDeepClone;
            Test.setCurrentPage(pageRef);

            //create Opportunity
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', account.Id);
            opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'GCS Opportunity');
            opp.StageName = 'Stage 4 - Won';
            insert opp;
            
            Personal_Settings__c ps = new Personal_Settings__c();
            ps.trigger_opportunity__c = true;
            insert ps;
            
            

            test.Starttest();
            
            //Create price list
            Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
            insert priceList; 
            
            
            // create proposal
            Apttus_Proposal__Proposal__c  proposal_n = new Apttus_Proposal__Proposal__c();
            proposal_n.Apttus_Proposal__Account__c = account.Id;
            proposal_n.Apttus_Proposal__Opportunity__c = opp.Id;
            proposal_n.Language__c = 'English';
            proposal_n.Selling_Country__c = 'Austria';
            proposal_n.Apttus_QPConfig__PriceListId__c = priceList.Id;
            proposal_n.BillingStreet__c = 'something';
            proposal_n.BillingCity__c = 'something';
            proposal_n.BillingCountry__c = 'Algeria';
            proposal_n.BillingZipPostalCode__c = 'something';
            proposal_n.QuoteStatus__c = 'Accepted Offline';
            insert proposal_n;
            
            opp.StageName = 'Stage 4 - Won';
            update opp;
            
            proposal_n.QuoteStatus__c = 'Accepted Offline';
            update proposal_n;
            
            OpportunityTriggerHandler.PreventRecursion = false;
            OpportunityTriggerHandler.SKIP_OPPORTUNITY_UPDATE = false;
            BaseTriggerHandler.SkipOppUpdateToPreventRecursion = false;
            
            
            opp.Skip_Stage_Validation__c  = true;
            opp.StageName = 'Stage 3 - Quote';
            update opp;
            
            test.Stoptest();
        }
       
    }

    
}