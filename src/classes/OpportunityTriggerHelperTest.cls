@isTest
private class OpportunityTriggerHelperTest {
    
    
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

        upsert tAccount;
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
            //Added
            proposal_n.Apttus_Proposal__Primary__c = true;
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
            
            proposal_n.Apttus_Proposal__Primary__c = true;
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

    
    
    
    
    
    static Account acc;
    static void setupData() {
        IntegrationConfig__c  integConfigSettings = new IntegrationConfig__c(Name ='USPS Integration', 
                                                                             Timeout__c=60000,
                                                                             IsPaypalTest__c=true,
                                                                             EndpointName__c='USPSAddressValidation',
                                                                             Username__c='562CLOUD2615');
        insert integConfigSettings;
        
        WebServiceEndpoint__c wsEndpoint = new WebServiceEndpoint__c(Name='USPSAddressValidation', Endpoint__c='http://production.shippingapis.com/ShippingAPI.dll');
        insert wsEndpoint;
        
        acc = TestDataSetupUtility.createTestAccountWithShipping('Test Account');
        acc.Phone = '+6391245676543';
        acc.Organization__c = 'Europe';
        insert acc;
        
        
    }
    
    @isTest
    static void myTestMethod(){
        setupData();
        
        Personal_Settings__c ps = new Personal_Settings__c();
        ps.trigger_opportunity__c = true;
        insert ps;
        OpportunityTriggerHandler.ExecuteTriggers = true;
        
        Utility util = new Utility();
        Map<String, Map<String, Schema.SObjectField>> sObjectAndFields = util.getAllSObjectFieldsBySObjectName(new Set<String>{
            'Order__c', 'Apttus_Proposal__Proposal__c'
                });
        
        Map<String, Schema.SObjectField> cloned = sObjectAndFields.get('Order__c');
        Map<String, Schema.SObjectField> source = sObjectAndFields.get('Apttus_Proposal__Proposal__c');
        
        String wrong = '\n\nWRONG';
        String correct = '\n\nCORRECT';
        for(String sourceAPI : source.keySet()){
            String clonedAPI = getTargetApttusFieldAPIName(sourceAPI);
            if(!cloned.containsKey(clonedAPI)){
                wrong += '\n\t' + source.get(sourceAPI).getDescribe().getLabel();
            }else{
                correct += '\n\t' + cloned.get(clonedAPI).getDescribe().getLabel();
            }
        }
        system.debug(wrong + correct + '\n\n');
    }
    
    private static String getTargetApttusFieldAPIName(String pSourceAPIName){
        String[] sourceApiSplit = pSourceAPIName.split('__');
        String sourcePrefix = sourceApiSplit.size() > 2 ? sourceApiSplit[0] + '__' : '';
        return sourcePrefix == '' ? pSourceAPIName : pSourceAPIName.removeStart(sourcePrefix);
    }
    
    
    @isTest
    static void test_SetAllocationSplitsForPrimaryAndSecondarySalesRep() {
        Map<Id,Opportunity> newMap = new Map<Id,Opportunity>();
        Map<Id,Opportunity> oldMap = new Map<Id,Opportunity>();
        List<opportunity> newList = new List<opportunity>();
        setupData();
        Personal_Settings__c ps = new Personal_Settings__c();
        ps.trigger_opportunity__c = true;
        insert ps;
        Method_Kill_List__c testCustomSetting = new Method_Kill_List__c(Name='updateOpptySplit', Kill_Method__c=false);
        insert testCustomSetting;
        OpportunityTriggerHandler.ExecuteTriggers = true;
        
        Xcode__c xcode = new Xcode__c(Created_For_Account__c = acc.Id,Name ='xtest');
        insert xcode;
        
        User sysAdmin = TestDataSetupUtility.createUser('System Administrator', false);
        sysAdmin.Country = 'United States';
        sysAdmin.TeamingChannel__c = 'Telesales';
        insert sysAdmin;
        
        User secondRep = TestDataSetupUtility.createUser('System Administrator', false);
        secondRep.username = 'testusernametye56@gmail.com';
        secondRep.Email = 'testeuwuewy3@gmail.com';
        secondRep.Country = 'United Kingdom';
        secondRep.TeamingChannel__c = 'Fieldsales';
        insert secondRep;
        
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Name12345';
        opp.StageName = 'Stage 1 - Needs Assessment';
        opp.CloseDate = system.today() + 20;
        opp.AccountId = acc.Id;
        opp.Lost_Reason__c = 'Credit Risk';
        opp.TeamingType__c = 'New';
        opp.Organization__c   = 'Asia Pacific';
        opp.ownerId = sysAdmin.Id;
        opp.SecondarySalesRep__c = secondRep.Id;
        opp.Apttus_Approval__Approval_Status__c = 'No Approval Needed';
        insert opp;
        Account_team_member__C atm = new Account_Team_member__c(AccountId__C=acc.id,UserId__c=sysadmin.id);
        
        
        for(Opportunity op : [Select Id, Name, Apttus_Approval__Approval_Status__c from Opportunity where Name = 'Name12345']){
            oldMap.put(op.Id, op);
        }
        //oldMap.put(opp.id,opp);
        
        OpportunityTeamMember__c testOpportunityTeamMember1;
        testOpportunityTeamMember1 = new OpportunityTeamMember__c();
        testOpportunityTeamMember1.Opportunity__c = opp.Id;
        testOpportunityTeamMember1.TeamMember__c = sysAdmin.Id;
        testOpportunityTeamMember1.TeamRole__c = 'Primary Sales Rep';
        insert testOpportunityTeamMember1;
        
        OpportunityTeamMember__c testOpportunityTeamMember2;
        testOpportunityTeamMember2 = new OpportunityTeamMember__c();
        testOpportunityTeamMember2.Opportunity__c = opp.Id;
        testOpportunityTeamMember2.TeamMember__c = secondRep.Id;
        testOpportunityTeamMember2.TeamRole__c = 'Secondary Sales Rep';
        insert testOpportunityTeamMember2;
        
        AllocationSplit__c split = new AllocationSplit__c();
        split.PrimarySalesRepCountry__c = 'United States';
        split.PrimaryAllocationBasis__c =  'Gross' ;
        split.TeamingType__c =  'New' ;        
        split.PrimaryRepTeamingChannel__c =  'Telesales' ;
        split.PrimaryRep__c =   100; 
        
        split.SecondarySalesRepCountry__c =  'United Kingdom';
        split.SecondaryRepTeamingChannel__c =  'Fieldsales';       
        
        insert split;         
        
        
        Test.startTest();
         opp.Apttus_Approval__Approval_Status__c = 'Approved';
        opp.Skip_Stage_Validation__c = true;
        opp.Skip_Amount_Validation__c = true;
        update opp;  
        for(Opportunity op : [Select Id, Name, Apttus_Approval__Approval_Status__c from Opportunity where Name = 'Name12345']){
            newMap.put(op.Id, op);
            newList.add(opp);
        }
        //newMap.put(opp.id,opp);
        OpportunityTriggerHelper helper = new OpportunityTriggerHelper();
        //system.assert(false,'new'+newMap+'old'+oldmap);
        helper.OpportunityList = newList;
        helper.SetAllocationSplitsForPrimaryAndSecondarySalesRep(newMap, oldMap);
       // helper.copyAccountSalesTeamMemToOppSalesTeamMem(newList);
        Test.stopTest();
        
    }
    
    
    
    
    
    @isTest
    static void OrderCreationWhenOpportunityOrderCreatedIsTrueTest(){
        setupData();
        
        Personal_Settings__c ps = new Personal_Settings__c();
        ps.trigger_opportunity__c = true;
        insert ps;
        Method_Kill_List__c testCustomSetting = new Method_Kill_List__c(Name='updateOpptySplit', Kill_Method__c=false);
        insert testCustomSetting;
        OpportunityTriggerHandler.ExecuteTriggers = true;
        
        
        Opportunity[] opps = new Opportunity[]{};
            Id recordOppId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'Opportunity');
        
        for(Integer i = 0; i < 10; i++){
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test123456 Opp ' + i, acc.Id);
            opp.recordTypeId = recordOppId;
            opp.OrderCreated__c  = false;
            opp.Apttus_Approval__Approval_Status__c = 'No approval needed';
            opps.add(opp);
        }
        insert opps;
        List<opportunity> opList = new List<Opportunity>();
        for(Opportunity opp : opps){
            opp.OrderCreated__c = true;
            opp.Apttus_Approval__Approval_Status__c = 'Approved';
            opList.add(opp);
        }
        
        User sysAdmin = TestDataSetupUtility.createUser('System Administrator', true);
        System.runAs(sysAdmin){
            Test.startTest();
            //update opps;
            update opList;
            Test.stopTest();
        }
        
        Order__c[] createdOrders = [SELECT Id FROM Order__c WHERE Account__c = :acc.Id and Opportunity__c IN :opps];
        //system.assertEquals(opps.size(), createdOrders.size());
    }
    
    @isTest
    static void SetPricebookOfEveryCreatedOpportunity_Test(){
        setupData();
        
        Personal_Settings__c ps = new Personal_Settings__c();
        ps.trigger_opportunity__c = true;
        insert ps;
        Method_Kill_List__c testCustomSetting = new Method_Kill_List__c(Name='updateOpptySplit', Kill_Method__c=false);
        insert testCustomSetting;
        OpportunityTriggerHandler.ExecuteTriggers = true;
        
        list<Opportunity> opps = new list<Opportunity>();
        for(Integer i = 0; i < 10; i++){
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp ' + i, acc.Id);
            opp.Apttus_Approval__Approval_Status__c = 'No approval needed';
            opps.add(opp);
        }
        Test.startTest();
        insert opps;
        Test.stopTest();
        for(Opportunity o : [SELECT Pricebook2Id FROM Opportunity WHERE Id IN :opps]){
            //system.assert(o.Pricebook2Id != null);
            system.debug('o.PriceBook2Id'+o.Pricebook2Id);
        }
    }
    
    //story 1783, task E2243
    //Added by DinoBrinas
    @isTest
    static void OrderLineItemToJunctionObjectWhenOpportunityOrderCreatedIsFalseTest(){
        setupData();
        
        Personal_Settings__c ps = new Personal_Settings__c();
        ps.trigger_opportunity__c = true;
        insert ps;
        Method_Kill_List__c testCustomSetting = new Method_Kill_List__c(Name='updateOpptySplit', Kill_Method__c=false);
        insert testCustomSetting;
        OpportunityTriggerHandler.ExecuteTriggers = true;
        
        list<Opportunity> opps = new list<Opportunity>();
        for(Integer i = 0; i < 10; i++){
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp ' + i, acc.Id);
            opp.OrderCreated__c = false;
            opps.add(opp);
        }
        insert opps;
        for(Opportunity opp : opps){
            opp.OrderCreated__c = true;
        }
        Test.startTest();
        update opps;
        System.debug('opps   >>>>' + opps);
        List<Order__c> createdOrders = [SELECT Id FROM Order__c WHERE Account__c = :acc.Id and Opportunity__c IN :opps];
        Test.stopTest();
        system.debug('createdOrders>>>>>' + createdOrders);
        //system.assertEquals(opps.size(), createdOrders.size());
    }
    
    /**
* @Author : Apttus - Code Coverage
*/
    @isTest
    static void unUsedMethodsCoverageTest(){
        setupData();
        
        Test.startTest();
        Personal_Settings__c ps = new Personal_Settings__c();
        ps.trigger_opportunity__c = true;
        insert ps;
        Method_Kill_List__c testCustomSetting = new Method_Kill_List__c(Name='updateOpptySplit', Kill_Method__c=false);
        insert testCustomSetting;
        OpportunityTriggerHandler.ExecuteTriggers = true;
        
        list<Opportunity> opps = new list<Opportunity>();
        for(Integer i = 0; i < 10; i++){
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp ' + i, acc.Id);
            opps.add(opp);
        }
        opps[0].amount = 10;
        insert opps;
        
        OpportunityTriggerHelper helper = OpportunityTriggerHelper.NewTriggerHelper();
        helper.CreateOpportunityIdSet(opps);
        Test.stopTest();
    }
    /**
* @Author : Apttus - Code Coverage
*/
    @isTest
    static void testCancelApprovalRequest(){
        Personal_Settings__c ps = new Personal_Settings__c();
        ps.trigger_opportunity__c = true;
        insert ps;
        Method_Kill_List__c testCustomSetting = new Method_Kill_List__c(Name='updateOpptySplit', Kill_Method__c=false);
        insert testCustomSetting;
        OpportunityTriggerHandler.ExecuteTriggers = true;
        
        List<Account> lstAccount = new List<Account>();
        //Account acc = TestDataSetupUtility.createTestAccountWithShipping('Test Account');
        //acc.AgencyFlag__c = true;
        //acc.Phone = '+6391245676543';
        //lstAccount.add(acc);        
        Account acc1 = TestDataSetupUtility.createTestAccountWithShipping('Test Account 1');
        acc1.AgencyFlag__c = true;
        acc1.CreditStatus__c = 'Ok';
        acc1.Partner_Flag__c = true;
        lstAccount.add(acc1);
        Account acc2 = TestDataSetupUtility.createTestAccountWithShipping('Test Account 2');
        acc2.AgencyFlag__c = true;
        acc2.CreditStatus__c = 'Ok';
        acc2.Partner_Flag__c = true;
        lstAccount.add(acc2);
        insert lstAccount;
        
        //RelatedPartner__c is inserted to populate Agency__c field on opportunity object
        List<RelatedPartner__c> lstRP = new List<RelatedPartner__c>();
        lstRP.add(TestDataSetupUtility.createTestRelatedPartner(lstAccount[0].Id, lstAccount[1].Id));
        //lstRP.add(TestDataSetupUtility.createTestRelatedPartner(lstAccount[1].Id, lstAccount[0].Id));
        insert lstRP;
        
        //system.assert(false,lstAccount[0].agencybilled__c +lstAccount[1].agencybilled__c );
        
        list<Opportunity> opps = new list<Opportunity>();
        Opportunity opp1 = TestDataSetupUtility.createTestOpportunity('Test Opp - Team Change', lstAccount[0].Id);
        //opp1.Agency__c = lstAccount[1].Id;
        opp1.SecondarySalesRep__c = null;
        opp1.OrderCreated__c = false;
        opp1.accountId = lstAccount[0].Id;
        opps.add(opp1);
        Opportunity opp2 = TestDataSetupUtility.createTestOpportunity('Test Opp - minThreshold Change', lstAccount[0].Id);
        //Opp2.Amount = 2500;
        //Opp2.Agency__c = lstAccount[1].Id;
        Opp2.OrderCreated__c = false;
        opps.add(opp2);
        Opportunity opp3 = TestDataSetupUtility.createTestOpportunity('Test Opp - Reason420', lstAccount[0].Id);
        opp3.OrderCreated__c = false;
        
        opps.add(opp3);
        insert opps;
        //test.startTest();
        opp3.OrderCreated__c = true;
        update opp3;
        //Test.StopTest();
        
        list<Apttus_Approval__Approval_Request__c> approvalList = new list<Apttus_Approval__Approval_Request__c>();
        Apttus_Approval__Approval_Request__c approvalRequest1 = new Apttus_Approval__Approval_Request__c(Apttus_Approval__Approval_Status__c = 'Notified', Apttus_Approval__Related_Opportunity__c = opp1.id);        
        approvalList.add(approvalRequest1);
        Apttus_Approval__Approval_Request__c approvalRequest2 = new Apttus_Approval__Approval_Request__c(Apttus_Approval__Approval_Status__c = 'Notified', Apttus_Approval__Related_Opportunity__c = opp2.id);        
        approvalList.add(approvalRequest2);
        Apttus_Approval__Approval_Request__c approvalRequest3 = new Apttus_Approval__Approval_Request__c(Apttus_Approval__Approval_Status__c = 'Notified', Apttus_Approval__Related_Opportunity__c = opp3.id);        
        approvalList.add(approvalRequest3);
        
        insert approvalList;
        
        //opp2.Amount = 1000;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='test@testapttus.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='test@testapttus.com');
        
        User u2 = new User(Alias = 'standt', Email='test1@testapttus.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='test1@testapttus.com');
        List<User> uList = new List<User>();
        insert u;
        u2.ManagerId = u.id;
        insert u2;
        
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User testUser = TestDataSetupUtility.createTestUser('Test', 'Test', adminProfile.Id);
        insert testUser;
        System.runAs(testUser) {
            Test.startTest();
            opp1.SecondarySalesRep__c = u2.id;
            opp1.OrderCreated__c = true;
            opp1.Skip_Amount_Validation__c = true;
            opp1.Skip_Stage_Validation__c = true;
            //opp1.Agency__c = lstAccount[2].Id;
            Opp2.OrderCreated__c = true;
            opp2.Skip_Amount_Validation__c = true;
            opp2.Skip_Stage_Validation__c = true;
            //Opp2.Agency__c = lstAccount[2].Id;
            list<Opportunity> oppToUpdate = new list<Opportunity>();
            oppToUpdate.add(opp1);
            oppToUpdate.add(opp2);
            
            update oppToUpdate;
            Test.stopTest();
            /* system.assert(false,[select Skip_Stage_Validation__c ,
Skip_Amount_Validation__c
from opportunity
where id
IN : oppToUpdate]); */
        }
    }
    
    @isTest
    static void test_createOrderWhenOrderIsCreated2() {
        setupData();
        Method_Kill_List__c testCustomSetting = new Method_Kill_List__c(Name='updateOpptySplit', Kill_Method__c=false);
        insert testCustomSetting;
        Xcode__c xcode = new Xcode__c(Created_For_Account__c = acc.Id,Name ='xtest');
        insert xcode;
        
         Id pricebookId = Test.getStandardPricebookId();
        pricebook2 pb = new pricebook2(id = pricebookId,IsActive = true);
        upsert pb;
        
         Product2 product = TestDataSetupUtility.createProduct('Test Product' ,  false);
        product.ProductCode = 'QUOTE BUNDLE';
        insert product;
        
        system.debug('pricebookId***'+pricebookId);
        // 1. Insert a price book entry for the standard price book.
        // Standard price book entries require the standard price book ID we got earlier.
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = product.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Name12345';
        opp.StageName = 'Stage 1 - Needs Assessment';
        opp.CloseDate = system.today() + 20;
        opp.AccountId = acc.Id;
        opp.Lost_Reason__c = 'Credit Risk';
        opp.TeamingType__c = 'Named';
        opp.OrderCreated__c = false;
        opp.AutoCreateOrder__c = true;
        opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'Rebill Opportunity');
        opp.Organization__c   = 'Asia Pacific';
        insert opp;
        
        OpportunityTeamMember__c testOpportunityTeamMember1;
        testOpportunityTeamMember1 = new OpportunityTeamMember__c();
        testOpportunityTeamMember1.Opportunity__c = opp.Id;
        testOpportunityTeamMember1.TeamMember__c = UserInfo.getUserId();
        testOpportunityTeamMember1.TeamRole__c = 'Primary Sales Rep';
        insert testOpportunityTeamMember1;
        
         // payment detail record inserted
        Payment_Details__c pD = new Payment_Details__c(Organization__c='Asia Pacific',PaymentMethod__c='Invoice',PaymentFrequency__c='Single Payment',PaymentTerm__c='30 days + EOM',CurrencyIsoCode='USD',Name='Test',Active__c=true);
        insert pD;
        
        Apttus_Proposal__Proposal__c pro = TestDataSetupUtility.createProposal(opp.Id,'Europe');
        pro.Payment1_Term__c = '30 days + EOM';
        pro.Payment1_Frequency__c = 'Single Payment';
        pro.Payment_Method1__c =  'Invoice';
        pro.RecordTypeId  = Utility.GetRecordTypeIdBySObjectNameAndType('Apttus_Proposal__Proposal__c', 'GCS Proposal');
        pro.Selling_Country__c  = 'Germany';
        pro.AccountOrganization__c   = 'Asia Pacific';
        pro.BillingAccount__c = acc.Id;
        insert pro; 
        
       
        Apttus_Config2__PriceList__c aptusConfigPriceList = TestDataSetupUtility.createPriceList('TestPrice',true);
        
        Apttus_Config2__ProductConfiguration__c aptusConfig = TestDataSetupUtility.createTestProductConfig(pro , acc , aptusConfigPriceList);
        aptusConfig.Apttus_Config2__Status__c = 'Finalized';
        
        insert aptusConfig;
        
        Apttus_Config2__LineItem__c aptusLineItem = TestDataSetupUtility.createLineItemApttus(aptusConfig.Id);
        
        
        insert aptusLineItem;
        Apttus_Config2__ProductAttributeGroup__c aptusGroup = TestDataSetupUtility.createGroup('TestGroup');
        insert aptusGroup;
        
       
        
        
        Apttus_Config2__ProductAttributeGroupMember__c aptusGrpMember = TestDataSetupUtility.createProductGroupMember('TestGroupMember' , aptusGroup.Id,product.Id);
        
        insert aptusGrpMember; 
        
       
        
        Apttus_Proposal__Proposal_Line_Item__c proposalLineItem = TestDataSetupUtility.createProposalLineItem(pro.Id);    
        proposalLineItem.Apttus_QPConfig__ConfigurationId__c = aptusConfig.Id;
        proposalLineItem.Apttus_QPConfig__DerivedFromId__c = aptusLineItem.Id;
        proposalLineItem.Apttus_Proposal__Product__c = product.Id;
        insert proposalLineItem; 
        
        Apttus_QPConfig__ProposalProductAttributeValue__c ProposalProductAttr = new Apttus_QPConfig__ProposalProductAttributeValue__c ();        
        ProposalProductAttr.Apttus_QPConfig__LineItemId__c = proposalLineItem.Id;
        ProposalProductAttr.Posting_Locations__c = 'Asia Pacific';
        insert ProposalProductAttr;
        
        Personal_Settings__c ps = new Personal_Settings__c();
        ps.trigger_opportunity__c = true;
        insert ps;
        OpportunityTriggerHandler.ExecuteTriggers = true;        
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
            User testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
            testUser.TeamingChannel__c  = 'Partner';
            insert testuser;
            
            opp.OrderCreated__c = true;
            opp.OwnerId = testuser.Id;
            
            update opp;
            
            Test.stopTest();
        }
    }
    
    @isTest
    static void test_SLA_Missed() {
        acc = TestDataSetupUtility.createTestAccountWithShipping('Test Account');
        acc.Phone = '+6391245676543';
        acc.Organization__c = 'North America';
        Account acc2 =  TestDataSetupUtility.createTestAccountWithShipping('Test Account 2');
        acc2.Phone = '+6391245676543';
        acc2.Organization__c = 'Europe';
        
        insert new List<Account>{acc,acc2};
            
            Opportunity opp = new Opportunity();
        opp.Name = 'Name12345';
        opp.StageName = 'Stage 1 - Needs Assessment';
        opp.CloseDate = system.today() + 20;
        opp.AccountId = acc.Id;
        opp.Lost_Reason__c = 'Credit Risk';
        opp.TeamingType__c = 'Named';
        opp.OrderCreated__c = false;
        opp.AutoCreateOrder__c = true;
        opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'Rebill Opportunity');
        opp.Organization__c   = 'North America';
        opp.SLA_Missed__c = true;
        
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Name12345';
        opp2.StageName = 'Stage 1 - Needs Assessment';
        opp2.CloseDate = system.today() + 20;
        opp2.AccountId = acc2.Id;
        opp2.Lost_Reason__c = 'Credit Risk';
        opp2.TeamingType__c = 'Named';
        opp2.OrderCreated__c = false;
        opp2.AutoCreateOrder__c = true;
        opp2.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'Rebill Opportunity');
        opp2.SLA_Missed__c = true;
        opp2.Organization__c = 'Europe';
        
        
        Test.startTest();
        insert new List<Opportunity>{opp,opp2};
            Test.stopTest();
    }
    @isTest
    static void test_OwnerChange() {
        acc = TestDataSetupUtility.createTestAccountWithShipping('Test Account');
        acc.Phone = '+6391245676543';
        acc.Organization__c = 'North America';
        insert acc;
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.TeamingChannel__c  = 'Partner';
        insert testuser;
        Personal_Settings__c ps = new Personal_Settings__c();
        ps.trigger_opportunity__c = true; 
        insert ps;
        Method_Kill_List__c testCustomSetting = new Method_Kill_List__c(Name='updateOpptySplit', Kill_Method__c=false);
        insert testCustomSetting;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Name12345';
        opp.StageName = 'Stage 1 - Needs Assessment';
        opp.CloseDate = system.today() + 20;
        opp.AccountId = acc.Id;
        opp.Lost_Reason__c = 'Credit Risk';
        opp.TeamingType__c = 'Named';
        opp.OrderCreated__c = false;
        opp.AutoCreateOrder__c = true;
        opp.Apttus_Approval__Approval_Status__c = 'Not Submitted';

        opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'Rebill Opportunity');
        opp.Organization__c   = 'North America';
        Test.startTest();
        insert opp;
        
        OpportunityTeamMember__c testOpportunityTeamMember1 = new OpportunityTeamMember__c(Opportunity__c = opp.Id,TeamMember__c = UserInfo.getUserId(),TeamRole__c = 'Primary Sales Rep');
        OpportunityTeamMember__c testOpportunityTeamMember2 = new OpportunityTeamMember__c(Opportunity__c = opp.Id,TeamMember__c = testuser.Id,TeamRole__c = 'Sales Rep');
        
        insert new List<OpportunityTeamMember__c>{testOpportunityTeamMember1};
            OpportunityTriggerHandler.ExecuteTriggers = true; 
        
        
        opp.SecondarySalesRep__c = testuser.Id;
        opp.Apttus_Approval__Approval_Status__c = 'No Approval Needed';
        update opp;
        
        opp.Apttus_Approval__Approval_Status__c = 'Approved';
        update opp;
        
        Test.stopTest();
    }
    
    
    @isTest
    static void test_OppTeamMember() {
        acc = TestDataSetupUtility.createTestAccountWithShipping('Test Account');
        acc.Phone = '+6391245676543';
        acc.Organization__c = 'North America';
        insert acc;
        Personal_Settings__c ps = new Personal_Settings__c();
        ps.trigger_opportunity__c = true; 
        ps.trigger_account__c = true; 
        insert ps;
        Method_Kill_List__c testCustomSetting = new Method_Kill_List__c(Name='updateOpptySplit', Kill_Method__c=false);
        insert testCustomSetting;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.TeamingChannel__c  = 'Partner';
        insert testuser;
        
        AccountTeamMember acctm = new AccountTeamMember(TeamMemberRole = 'Sales Rep',UserId = testuser.Id,AccountId = acc.Id);
        //acctm.UserId;
        insert acctm;
        Opportunity opp = new Opportunity();
        opp.Name = 'Name12345';
        opp.StageName = 'Stage 1 - Needs Assessment';
        opp.CloseDate = system.today() + 20;
        opp.AccountId = acc.Id;
        opp.Lost_Reason__c = 'Credit Risk';
        opp.TeamingType__c = 'Named';
        opp.OrderCreated__c = false;
        opp.AutoCreateOrder__c = true;
        opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'Opportunity');
        opp.Organization__c   = 'Europe';
        Test.startTest();
        insert opp;
        
    }
    @isTest
    static void test_MiscFunctionality() {
        //setupData();
        Method_Kill_List__c testCustomSetting = new Method_Kill_List__c(Name='updateOpptySplit', Kill_Method__c=false);
        insert testCustomSetting;

        List<Account> lstAccount = new List<Account>();
        acc = TestDataSetupUtility.createTestAccountWithShipping('Test Account');
        acc.Phone = '+6391245676543';
        acc.Organization__c = 'Europe';
        lstAccount.add(acc);
        Account acc1 = TestDataSetupUtility.createTestAccountWithShipping('Test Account 1');
        acc1.AgencyFlag__c = true;
        acc1.CreditStatus__c = 'Ok';
        acc1.Partner_Flag__c = true;
        lstAccount.add(acc1);
        Account acc2 = TestDataSetupUtility.createTestAccountWithShipping('Test Account 2');
        acc2.AgencyFlag__c = true;
        acc2.CreditStatus__c = 'Ok';
        acc2.Partner_Flag__c = true;
        lstAccount.add(acc2);
        insert lstAccount;
        Opportunity opp = new Opportunity();
        opp.Name = 'Name12345';
        opp.StageName = 'Stage 1 - Needs Assessment';
        opp.CloseDate = system.today() + 20;
        opp.AccountId = lstAccount[0].Id;
        opp.Lost_Reason__c = 'Credit Risk';
        opp.TeamingType__c = 'Named';
        opp.SLA_Missed__c = false;
        opp.Agency__c = lstAccount[1].Id;
        opp.Organization__c = 'Asia Pacific';
        insert opp;
        
        Payment_Details__c pD = new Payment_Details__c(Organization__c='Asia Pacific',PaymentMethod__c='Invoice',PaymentFrequency__c='Single Payment',PaymentTerm__c='30 days + EOM',CurrencyIsoCode='USD',Name='Test',Active__c=true);
        insert pD;
        
        
        
        List<Apttus_Proposal__Proposal__c> proList = new List<Apttus_Proposal__Proposal__c>();
        Apttus_Proposal__Proposal__c pro = TestDataSetupUtility.createProposal(opp.Id);
        pro.Selling_Country__c  = 'Germany';
        pro.AccountOrganization__c   = 'Asia Pacific';
        pro.BillingAccount__c = acc.Id;
        pro.Apttus_Proposal__Primary__c = true;
        pro.Payment1_Term__c = '30 days + EOM';
        pro.Payment1_Frequency__c = 'Single Payment';
        pro.Payment_Method1__c =  'Invoice';
        proList.add(pro);
        /*proList.add(TestDataSetupUtility.createProposal(opp.Id));
        proList[1].AccountOrganization__c   = 'Asia Pacific';
        proList[1].Apttus_Proposal__Primary__c = false;
        proList[1].Payment1_Term__c = '30 days + EOM';
        proList[1].Payment1_Frequency__c = 'Single Payment';
        proList[1].Payment_Method1__c =  'Invoice';
        proList[1].PaymentDetails__c=pD.id;*/
        insert proList;
        
        Personal_Settings__c ps = new Personal_Settings__c();
        ps.trigger_opportunity__c = true; 
        insert ps;
        OpportunityTriggerHandler.ExecuteTriggers = true;        
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            opp.Agency__c = lstAccount[2].Id;
            opp.OrderCreated__c = true;
            opp.AutoCreateOrder__c = false;
            update opp;
            
            delete opp;
            undelete opp;
            
            Test.stopTest();
        }
    }
    
    
    @isTest
    static void testoppTest(){
        setupData();
        Personal_Settings__c ps = new Personal_Settings__c();
        ps.trigger_opportunity__c = true;
        insert ps;
        Method_Kill_List__c testCustomSetting = new Method_Kill_List__c(Name='updateOpptySplit', Kill_Method__c=false);
        insert testCustomSetting;
        OpportunityTriggerHandler.ExecuteTriggers = true;
        
        List<Account> lstAccount = new List<Account>();
        //Account acc = TestDataSetupUtility.createTestAccountWithShipping('Test Account');
        //acc.AgencyFlag__c = true;
        //acc.Phone = '+6391245676543';
        //lstAccount.add(acc);        
        Account acc1 = TestDataSetupUtility.createTestAccountWithShipping('Test Account 1');
        acc1.AgencyFlag__c = true;
        acc1.CreditStatus__c = 'Ok';
        acc1.Partner_Flag__c = true;
        lstAccount.add(acc1);
        Account acc2 = TestDataSetupUtility.createTestAccountWithShipping('Test Account 2');
        acc2.AgencyFlag__c = true;
        acc2.CreditStatus__c = 'Ok';
        acc2.Partner_Flag__c = true;
        lstAccount.add(acc2);
        insert lstAccount;
        
        list<Opportunity> opps = new list<Opportunity>();
        Opportunity opp1 = TestDataSetupUtility.createTestOpportunity('Test Opp - Team Change', lstAccount[0].Id);
        //opp1.Agency__c = lstAccount[1].Id;
        opp1.SecondarySalesRep__c = null;
        opp1.OrderCreated__c = false;
        opp1.dispositionreason__c = 'Price';
        opp1.Skip_Amount_Validation__c = true;
        opp1.Skip_Stage_Validation__c = true;
        opps.add(opp1);
        Opportunity opp2 = TestDataSetupUtility.createTestOpportunity('Test Opp - minThreshold Change', lstAccount[0].Id);
        //Opp2.Amount = 2500;
        //Opp2.Agency__c = lstAccount[1].Id;
        Opp2.OrderCreated__c = false;
        opp2.dispositionreason__c = 'Price';
        opp2.Skip_Amount_Validation__c = true;
        opp2.Skip_Stage_Validation__c = true;
        opps.add(opp2);
        
        insert opps;
        
        
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User testUser = TestDataSetupUtility.createTestUser('Test', 'Test', adminProfile.Id);
        insert testUser;
        
        System.runAs(testUser) { 
            Test.startTest();
            
            list<Opportunity> oppUpdate = [select Skip_Stage_Validation__c ,DispositionReason__c,
                                           Skip_Amount_Validation__c
                                           from opportunity
                                           where id
                                           IN : opps];
            /* system.assert(false,[select Skip_Stage_Validation__c ,
Skip_Amount_Validation__c,DispositionReason__c
from opportunity
where id
IN : oppUpdate]);         */            
            for(Opportunity opp : oppUpdate){
                opp.Skip_Amount_Validation__c = true;
                opp.Skip_Stage_Validation__c = true;
                opp.DispositionReason__c = 'Competition';
            }
            
            update oppupdate;
            Test.stopTest();
            
            /* system.assert(false,[select Skip_Stage_Validation__c ,
Skip_Amount_Validation__c,DispositionReason__c
from opportunity
where id
IN : oppUpdate]); */
        }
        
    }
    
    
}