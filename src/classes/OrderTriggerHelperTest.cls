/**
* @author Andre Calimlim
* @date 12.4.14
* @description Test Class for OrderTriggerHelper.
*/
@isTest
private class OrderTriggerHelperTest {
    //declare static variables
    static Personal_Settings__c personalSettings;
    static List<Opportunity> oppList;
    static List<Account> accountList;
    static Contact con;
    static Product2 prod;

    /**
* @author Andre Calimlim
* @date 12.4.14
* @description static method to create test data records
* @param AccountName - String value for the name field of Account
* @param setPersonalSettings - Boolean value to set the personal Settings on which triggers/Validations to run
*/
    @testSetup
    static void  createRec(){
        personalSettings = TestDataSetupUtility.buildPersonalSetting();
        //personalSettings.Trigger_Order__c = true;
        /*if(setPersonalSettings){
personalSettings.Trigger_Order__c = true;
personalSettings.Trigger_Account__c = true;
personalSettings.Trigger_Opportunity__c = true;
personalSettings.Validation_Account__c = true;
personalSettings.Validation_Opportunity__c = true;
}*/
        insert personalSettings;
        insert TestDataSetupUtility.buildMaximumCustomerNumberSetting();
        insert TestDataSetupUtility.buildWebServiceEndpointSetting();
        insert TestDataSetupUtility.buildIntegrationConfigSetting();
        insert TestDataSetupUtility.buildCaseTriggerSetting();

        accountList = new List<Account>();
        Account usedAccount = TestDataSetupUtility.createTestAccount('Test Account', 'North America', UserInfo.getUserId());
        usedAccount.OwnerId = UserInfo.getUserId();
        accountList.add(usedAccount);
        //accountList.add(TestDataSetupUtility.createTestAccount('Test Account2', AccountName, UserInfo.getUserId()));
        accountList[0].AccountStatus__c = 'Customer';
        accountList[0].CustomerNumber__c = '11';
        accountList[0].CustomerDate__c = Date.today();
        accountList[0].shippingCountry = 'United States';
        //accountList[1].AccountStatus__c = 'Lapsed Customer';
        //accountList[1].CustomerLapsedDate__c = Date.today();

        insert accountList;

        con = TestDataSetupUtility.createTestContact(accountList.get(0).id,'test','Con','abccon@gmail.com');
        insert con;


        Profile p = [SELECT Id FROM Profile WHERE Name LIKE '%Service Rep%' LIMIT 1];
        User u = TestDataSetupUtility.createTestUser('John', 'Doe', p.Id);
        insert u;

        Method_Kill_List__c testCustomSetting = new Method_Kill_List__c(Name='updateOpptySplit', Kill_Method__c=false);
        insert testCustomSetting;

        Account_Team_Member__c atm = new Account_Team_Member__c();
        atm.AccountId__c = accountList[0].Id;
        atm.TeamMemberRole__c = 'Sales Rep';
        atm.UserId__c = u.Id;
        atm.AccountAccessLevel__c = 'Read/Write';
        atm.CaseAccessLevel__c = 'Read/Write';
        insert atm;
        Payment_Details__c paymentDetails = TestDataSetupUtility.createTestPaymentDetails('North America' , 'Monthly', 'Net 10');
        paymentDetails.PaymentMethod__c = 'Invoice';
        paymentDetails.Active__c  = true;
        insert paymentDetails;
        oppList = new List<Opportunity>();
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opportunity', accountList[0].Id);
        opp.OrderCreated__c = true;
        opp.OwnerId = UserInfo.getUserId();
        oppList.add(opp);
        insert oppList;
        
        //Added
        Sales_Credit_Splits__c scs = new Sales_Credit_Splits__c(Opportunity__c = oppList[0].id,Teaming_Rep__c = userInfo.getUserId(),
                                       Teaming_rep_split_for_Revenue__c = 100 , Teaming_Rep_Type__c = 'Revenue');
                                       insert scs;

    }
    static void prepareData(){
        personalSettings = [select id,Trigger_Order__c from Personal_Settings__c limit 1];
        oppList = [Select Id, AccountId, Name from Opportunity ];
        accountList = [Select Id from Account  ];
        con = [Select Id from Contact Limit 1];
        prod = TestDataSetupUtility.createTestProduct2('Monster Standard Job Ad');
        prod.Family = 'Job Posting';
        insert prod;

    }

    @isTest
    static void testOrderVerifiedNAAccount2() {

        //createRec('North America', false);
        prepareData();
        personalSettings.Trigger_Order__c = true;
        //update personalSettings;
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User testUser = TestDataSetupUtility.createTestUser('Integration', 'MAP', adminProfile.Id);
        testUser.FirstName= 'Integration';
        testUser.LastName = 'MAPP';
        Id userId = Userinfo.getUserId();
        insert testUser;

        System.runAs(testUser) {
            //system.assertEquals(UserInfo.getName(),'Integration MAPP');
            //system.debug('$$$$$User$' + UserInfo.getName());
            /* oppList[0].StageName='Stage 2 - Proposal';
update oppList;
oppList[0].StageName='Stage 3 - Quote';
update oppList;
oppList[0].StageName='Stage 4 - Won';
update oppList;*/

            Partner_Revenue_Share__c  partner = new Partner_Revenue_Share__c ();
            partner.Partner__c = accountList[0].Id;
            partner.SiteChannelID__c = 'Test';
            insert partner;

            Account testingAccount = [Select Id From Account where ID=: accountList[0].Id];

            testingAccount.Organization__c = 'Test Org';
            update testingAccount;
            List<Order__c> orderList = new List<Order__c>();
            update personalSettings;
            Order__c ord = TestDataSetupUtility.createOrderWithOpportunity(testingAccount.Id, oppList[0].Id, null, con.Id);
            ord.BillingAccount__c = accountList[0].id;
            ord.Entity_ID__c = null;
            ord.OrderStatus__c = 'Open';
            ord.SiteChannelID__c  = 'Test11';
            ord.MAPP_Payment_Frequency__c = 'Test';

            system.debug('OTH - TESTCLASS order status '+ord.OrderStatus__c);
            orderList.add(ord);
            Test.startTest();
            insert orderList;
            Order_Line_Item__c oli = TestDataSetupUtility.createOrderLineItem(ord.Id);
            oli.AdjustedPrice__c = 5;
            oli.Quantity2__c = 3;
            oli.startDate__c = date.Today();
            oli.EndDate__C = date.Today();
            insert oli;

            Order_Line_Item__c myresult = [SELECT Id,Name,order__c
                                           FROM Order_Line_Item__c WHERE Id=: oli.id];

            system.debug('******oli item ****' +myresult );

            LicenseID__c licenseId = new LicenseID__c();
            licenseId.OrderLineItem__c = oli.id;
            licenseId.SiteLicenseID__c = '00998';
            insert licenseId ;

            Test.stopTest();
        }
    }
    /**
* @author Andre Calimlim
* @date 12.4.14
* @description Positive Test method to verify that the order status is verified for NA, and Product Implementation Case is created.
*/
    @isTest
    static void testOrderVerifiedNAAccount() {

        //createRec('North America', false);
        prepareData();
        personalSettings.Trigger_Order__c = true;
        //update personalSettings;
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User testUser = TestDataSetupUtility.createTestUser('Integration', 'MAPP', adminProfile.Id);
        //User testUser = TestDataSetupUtility.createTestUser('TEST', 'TEST', adminProfile.Id);  // TKOM prod imp routing doesn't get called for MAPP user - should use a different user name.
        testUser.FirstName= 'Integration';
        testUser.LastName = 'MAPP';
        Id userId = Userinfo.getUserId();
        insert testUser;

        System.runAs(testUser) {
            //system.assertEquals(UserInfo.getName(),'Integration MAPP');
            //system.debug('$$$$$User$' + UserInfo.getName());
            /* oppList[0].StageName='Stage 2 - Proposal';
update oppList;
oppList[0].StageName='Stage 3 - Quote';
update oppList;
oppList[0].StageName='Stage 4 - Won';
update oppList;*/

            Partner_Revenue_Share__c  partner = new Partner_Revenue_Share__c ();
            partner.Partner__c = accountList[0].Id;
            partner.SiteChannelID__c = 'Test';
            insert partner;

            Account testingAccount = [Select Id From Account where ID=: accountList[0].Id];
            testingAccount.AccountStatus__c = 'Customer';
            //update testingAccount;
            List<Order__c> orderList = new List<Order__c>();
            Order__c ord = TestDataSetupUtility.createOrderWithOpportunity(testingAccount.Id, oppList[0].Id, null, con.Id);
            ord.BillingAccount__c = accountList[0].id;
            ord.Entity_ID__c = null;
            ord.SiteChannelID__c  = 'Test';
            orderList.add(ord);
            insert orderList;

            //Account usedAccount1 = new Account();
            //usedAccount1.Name = 'Testing123';
            //usedAccount1.PrimaryServiceRep__c = testUser.Id;
            ///usedAccount1.OwnerId = testUser.Id;


            // TestDataSetupUtility.createTestAccount('Test Account123', 'AccountName345', testUser.Id);
            //insert usedAccount1;

            //Order__c ord1 = TestDataSetupUtility.createOrderWithOpportunity(usedAccount1.Id, oppList[0].Id, null, con.Id);
            //ord1.BillingAccount__c = usedAccount1.id;
            //ord1.Entity_ID__c = null;
            //ord1.SiteChannelID__c  = 'Test';
            //insert ord1;



            List<Order_Line_Item__c> OLIList = new List<Order_Line_Item__c>();
            Order_Line_Item__c oli = TestDataSetupUtility.createOrderLineItem(ord.Id);
            oli.AdjustedPrice__c = 5;
            oli.Quantity2__c = 3;
            insert oli;

            Order_Line_Item__c item = [SELECT Id,Name,order__c
                                       FROM Order_Line_Item__c WHERE Id=: oli.id];

            system.debug('******item ****' +item );

            LicenseID__c licenseId = new LicenseID__c();
            licenseId.OrderLineItem__c = oli.id;
            licenseId.SiteLicenseID__c = 'Test';
            insert licenseId ;


            Set<Id> ordIds = new Set<Id>();
            for(Order__c o : orderList){
                ordIds.add(o.Id);
            }
            // personalSettings.Trigger_Order__c = true;
            update personalSettings;

            Test.startTest();
            List<Order__c> orderForUpdate;

            con = TestDataSetupUtility.createTestContact(accountList.get(0).id,'test1x','Con1x','abczzzcon@gmail.com');
            insert con;

            orderForUpdate = [Select OrderStatus__c from Order__c where Id in : ordIds];
            for(Order__c o : orderForUpdate){
                o.OrderStatus__c = 'Sent to Verification';
                o.Posting_Contact__c = con.id;
                o.BillingContact__c= con.id;
                o.BillingAccount__c = accountList.get(0).id;
                o.Agency__c = accountList.get(0).id; //TKOM S-445214 added for testing agency routing.

            }
            update orderForUpdate;
        }

        Test.stopTest();
        // System.assertEquals('Verified', [Select OrderStatus__c from Order__c where Id = :orderList[0].Id].OrderStatus__c);
        // System.assertEquals('Product Implementation', [Select RecordType.Name from Case where Order__c = : orderForUpdate[0].Id].RecordType.Name);
    }

    /**
* @author Cloudsherpas
* @date 12.4.14
* @description Positive Test method to verify that the order status is Sent To Verification for Non-NA, Product Implementation Case is created, and Account Status is Customer , and CustomerNumber has incremented
*/
    @isTest
    static  void testOrderSTVNonNAAct() {
        //createRec('Asia', false);
        prepareData();

        /*  oppList[0].StageName='Stage 2 - Proposal';
update oppList;
oppList[0].StageName='Stage 3 - Quote';
update oppList;
oppList[0].StageName='Stage 4 - Won';
update oppList;*/



        List<Order__c> orderList = new List<Order__c>();
        Order__c ord = TestDataSetupUtility.createOrderWithOpportunity(accountList[0].Id, oppList[0].Id, null, con.Id);
        ord.BillingAccount__c = accountList[0].id;
        ord.Entity_ID__c = null;
        orderList.add(ord);
        insert orderList;

        prod = TestDataSetupUtility.createProduct('Test Product 1',false);
        prod.ProductCode = 'M20194XJOB';
        insert prod;

        List<Order_Line_Item__c> OLIList = new List<Order_Line_Item__c>();
        Order_Line_Item__c oli = TestDataSetupUtility.createOrderLineItem(ord.Id);
        oli.Product__c = prod.Id;
        insert oli;

        Order_Line_Item__c item = [SELECT Id,Name,order__c FROM Order_Line_Item__c WHERE Id=: oli.id];

        system.debug('******item ****' +item );

        LicenseID__c licenseId = new LicenseID__c();
        licenseId.OrderLineItem__c = oli.id;
        //licenseId.SiteLicenseID__c = 'Test';
        insert licenseId ;

        Set<Id> ordIds = new Set<Id>();
        for(Order__c o : orderList){
            ordIds.add(o.Id);
        }
        personalSettings.Trigger_Order__c = true;
        update personalSettings;
        Test.startTest();

        List<Order__c> orderForUpdate = [Select OrderStatus__c,Posting_Contact__c from Order__c where Id in : ordIds];
        for(Order__c o : orderForUpdate){
            o.OrderStatus__c = 'Sent To Verification';
            o.Posting_Contact__c = con.id;
            o.BillingContact__c= con.id;

        }
        update orderForUpdate;


        Test.stopTest();
        System.assertEquals('Sent To Verification', [Select OrderStatus__c from Order__c where Id = :orderList[0].Id].OrderStatus__c);
        //System.assertEquals('Product Implementation', [Select RecordType.Name from Case where Order__c = : orderList[0].Id].RecordType.Name);
        List<Account> acc = [Select CustomerNumber__c, AccountStatus__c from Account where Id = : orderList[0].Account__c];
        // System.assertEquals('2', acc[0].CustomerNumber__c);
        System.assertEquals('Customer', acc[0].AccountStatus__c);

    }

    /**
* @author Cloudsherpas
* @date 12.4.14
* @description Positive Test method for creating a Product Implementation case if Order status is Sent to Verification and Record Type is Standard.
*/
    @isTest
    static void testCreateProductImplementationCase() {
        //createRec('North America', false);
        prepareData();
        List<CaseRoutingRule__c> lstProdImpRoutingRules = TestDataSetupUtility.createProdImpRoutingRules();
        //lstProdImpRoutingRules.ProductName__c = prod;
        for (CaseRoutingRule__c cRR : lstProdImpRoutingRules) {
          // Set the product on case routing rules to match the Case that will be set on the product later
          if (cRR.Name.Contains('ProdName')) cRR.Product_Name__c = prod.Id;
        }



        Test.startTest();
        personalSettings.Trigger_Order__c = true;
        personalSettings.Trigger_Case__c = true;
        update personalSettings;

        Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', 'Price list for Apttus',
                                                                                      Date.today(), Date.today().addMonths(12), true);
        Apttus_Proposal__Proposal__c proposal = TestDataSetupUtility.CreateQuoteOrProposal('Test Configure',
                                                                                           oppList[0].id, Date.today(), Date.today().addMonths(12),
                                                                                           priceList.Id, Date.today(), '3 Years', true, false);
        proposal.Payment1_Term__c =  'Net 10';
        proposal.Payment1_Frequency__c = 'Monthly';
        proposal.Payment_Method1__c =  'Invoice';
        proposal.Earliest_Start_Date__c = Date.today();
        proposal.Latest_End_Date__c = Date.today().addYears(1);

        insert proposal;

        List<Order__c> orderList = new List<Order__c>();
        Order__c ord = TestDataSetupUtility.createOrderWithOpportunity(AccountList[0].Id, null, proposal.Id, con.Id);
        ord.Payment_Term_text__c =  'Net 10';
        ord.Payment_Frequency__c = 'Monthly';
        ord.Payment_Method_text__c =  'Invoice';
        ord.AccountOrganization__c = 'North America';
        ord.Organization__c = 'North America';
        ord.OrderStatus__c = 'Open';
        ord.Posting_Contact__c = con.id;
        ord.MAPPQuoteProposal__c = proposal.Id;
        ord.MAPPSentToVerificationBy2__c = Userinfo.getUserId();
        ord.MAPP_Price_List__c = priceList.Id;
        ord.MAPPPriceListId__c = priceList.Id;
        ord.MAPPBillingAccount__c = AccountList[0].Id;
        ord.MAPPBillingContact__c = con.id;
        ord.MAPP_Archive_Posting_Contact__c = con.id;
        ord.MAPP_Archive_Posting_Customer_PO__c = con.id;
        orderList.add(ord);

        insert orderList;

        Order_Line_Item__c oli = TestDataSetupUtility.createOrderLineItem(ord.Id);
        oli.Product__c = prod.Id;
        oli.Order__c = orderlist[0].id;
        oli.Account_lkp__c = Accountlist[0].id;
        insert oli;

        orderlist[0].OrderStatus__c = 'Sent To Verification';
        update orderlist[0];

        //System.assertEquals('Product Implementation', [Select RecordType.Name from Case where Order__c = : orderList[0].Id].RecordType.Name);
        Test.stopTest();


    }

    /**
* @author Andre Calimlim
* @date 12.4.14
* @description Negative Test method to verify that no Product Implementation Case will be created.
*/
    @isTest
    static  void testUpdateSTVWithNoCase() {

        //createRec('North America', true);
        prepareData();
        personalSettings.Trigger_Order__c = true;
        update personalSettings;
        /*  oppList[0].StageName='Stage 2 - Proposal';
update oppList;
oppList[0].StageName='Stage 3 - Quote';
update oppList;
oppList[0].StageName='Stage 4 - Won';*/
        //  update oppList;
        Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', 'Price list for Apttus',
                                                                                      Date.today(), Date.today().addMonths(12), true);
        Apttus_Proposal__Proposal__c proposal = TestDataSetupUtility.CreateQuoteOrProposal('Test Configure',
                                                                                           oppList[0].id, Date.today(), Date.today().addMonths(12),
                                                                                           priceList.Id, Date.today(), '3 Years', true, false);
        proposal.Payment1_Term__c =  'Net 10';
        proposal.Payment1_Frequency__c = 'Monthly';
        proposal.Payment_Method1__c =  'Invoice';
        proposal.Earliest_Start_Date__c = Date.today();
        proposal.Latest_End_Date__c = Date.today().addYears(1);

        insert proposal;
        List<Order__c> orderList = new List<Order__c>();
        Order__c ord = TestDataSetupUtility.createOrderWithOpportunity(accountList[0].Id, oppList[0].Id, proposal.Id, con.Id);
        ord.BillingAccount__c = accountList[0].id;
        ord.Entity_ID__c = null;
        ord.Payment_Term_text__c =  'Net 10';
        ord.Payment_Frequency__c = 'Monthly';
        ord.Payment_Method_text__c =  'Invoice';
        ord.AccountOrganization__c = 'North America';
        ord.Organization__c = 'North America';
        orderList.add(ord);

        insert orderList;
        Test.startTest();
        List<Order_Line_Item__c> OLIList = new List<Order_Line_Item__c>();
        Order_Line_Item__c oli = TestDataSetupUtility.createOrderLineItem(ord.Id);
        oli.Owner_on_Start_Date__c = userInfo.getUserId();
        insert oli;

        Order_Line_Item__c item = [SELECT Id,Name,order__c
                                   FROM Order_Line_Item__c WHERE Id=: oli.id];

        system.debug('******item ****' +item );

        LicenseID__c licenseId = new LicenseID__c();
        licenseId.OrderLineItem__c = oli.id;
        //licenseId.SiteLicenseID__c = 'Test';
        insert licenseId ;

        Set<Id> ordIds = new Set<Id>();
        for(Order__c o : orderList){
            ordIds.add(o.Id);
        }

        TestDataSetupUtility.createTestPaymentDetails('North America','Single Payment','30 days + EOM');


        List<Order__c> orderForUpdate;


        orderForUpdate = [Select OrderStatus__c from Order__c where Id in : ordIds];
        for(Order__c o : orderForUpdate){
            o.OrderStatus__c = 'Sent To Verification';
            o.Posting_Contact__c = con.id;
            o.BillingContact__c= con.id;
        }
        update orderForUpdate;


        Test.stopTest();

        //  System.assertEquals('Verified', [Select OrderStatus__c from Order__c where Id = :orderList[0].Id].OrderStatus__c);
        //  System.assertEquals(true, [Select RecordType.Name from Case where Order__c = : orderForUpdate[0].Id].isEmpty());
    }

    /**
* @author Andre Calimlim
* @date 1.7.15
* @description Positive Test method to verify that the Finance Order Type is New and order status is verified when created.
*/
    @isTest
    static  void testNewFOTVerified() {

        //createRec('North America', true);
        prepareData();
        personalSettings.Trigger_Order__c = true;
        personalSettings.Trigger_Account__c = true;
        personalSettings.Trigger_Opportunity__c = true;
        personalSettings.Validation_Account__c = true;
        personalSettings.Validation_Opportunity__c = true;
        update personalSettings;
        accountList[0].AccountStatus__c = 'Customer';
        accountList[0].CustomerNumber__c = '11';
        accountList[0].CustomerDate__c = Date.today();
        //update accountList;
        Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', 'Price list for Apttus',
                                                                                      Date.today(), Date.today().addMonths(12), true);
        Apttus_Proposal__Proposal__c proposal = TestDataSetupUtility.CreateQuoteOrProposal('Test Configure',
                                                                                           oppList[0].id, Date.today(), Date.today().addMonths(12),
                                                                                           priceList.Id, Date.today(), '3 Years', true, false);
        proposal.Payment1_Term__c =  'Net 10';
        proposal.Payment1_Frequency__c = 'Monthly';
        proposal.Payment_Method1__c =  'Invoice';
        proposal.Earliest_Start_Date__c = Date.today();
        proposal.Latest_End_Date__c = Date.today().addYears(1);

        insert proposal;
        List<Order__c> orderList = new List<Order__c>();
        Order__c ord = TestDataSetupUtility.createOrderWithOpportunity(accountList[0].Id, null, proposal.Id, con.Id);
        ord.OrderDate__c = Date.today();
        ord.OrderStatus__c = 'Verified';
        ord.Payment_Term_text__c =  'Net 10';
        ord.Payment_Frequency__c = 'Monthly';
        ord.Payment_Method_text__c =  'Invoice';
        ord.AccountOrganization__c = 'North America';
        ord.Organization__c = 'North America';
        orderList.add(ord);

        Test.startTest();

        insert orderList;


        Set<Id> ordIds = new Set<Id>();
        for(Order__c o : orderList){
            ordIds.add(o.Id);
        }



        List<Order__c> orderForUpdate = [Select OrderStatus__c, Finance_Order_Type_pickList__c from Order__c where Id in : ordIds];
        for(Order__c o : orderForUpdate){
            //System.assertEquals('New', o.Finance_Order_Type_pickList__c);
        }

        Test.stopTest();

    }

    /**
* @author Andre Calimlim
* @date 1.7.15
* @description Positive Test method to verify that the Finance Order Type is Existing when updated.
*/
    @isTest
    static  void testExistingFOTVerified() {

        //createRec('North America', false);
        prepareData();
        accountList[0].AccountStatus__c = 'Customer';
        accountList[0].CustomerNumber__c = '11';
        accountList[0].CustomerDate__c = Date.today();
        update accountList;
        Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', 'Price list for Apttus',
                                                                                      Date.today(), Date.today().addMonths(12), true);
        Apttus_Proposal__Proposal__c proposal = TestDataSetupUtility.CreateQuoteOrProposal('Test Configure',
                                                                                           oppList[0].id, Date.today(), Date.today().addMonths(12),
                                                                                           priceList.Id, Date.today(), '3 Years', true, false);
        proposal.Payment1_Term__c =  'Net 10';
        proposal.Payment1_Frequency__c = 'Monthly';
        proposal.Payment_Method1__c =  'Invoice';
        proposal.Earliest_Start_Date__c = Date.today();
        proposal.Latest_End_Date__c = Date.today().addYears(1);

        insert proposal;
        List<Order__c> orderList = new List<Order__c>();
        Order__c ord = TestDataSetupUtility.createOrderWithOpportunity(accountList[0].Id, null, proposal.Id, con.Id);
        ord.OrderDate__c = Date.today();
        ord.Payment_Term_text__c =  'Net 10';
        ord.Payment_Frequency__c = 'Monthly';
        ord.Payment_Method_text__c =  'Invoice';
        ord.AccountOrganization__c = 'North America';
        ord.Organization__c = 'North America';
        ord.OrderStatus__c = 'Open';
        orderList.add(ord);
        insert orderList;
        personalSettings.Trigger_Order__c = true;
        update personalSettings;

        Set<Id> ordIds = new Set<Id>();
        Test.startTest();

        for(Order__c o : orderList){
            ordIds.add(o.Id);
        }



        List<Order__c> orderForUpdate = [Select OrderStatus__c, OrderDate__c, Finance_Order_Type_pickList__c from Order__c where Id in : ordIds];
        list<Order_Line_Item__c> lstOLI = new    list<Order_Line_Item__c>();
        for(Order__c o : orderForUpdate){
            System.assertEquals(Date.today(), o.OrderDate__c);
            o.OrderStatus__c = 'Verified';
            o.OrderDate__c = Date.today().addDays(365);

            lstOLI.add(TestDataSetupUtility.createOrderLineItem(ord.id));
        }

        if(lstOLI.size()>0)
            insert lstOLI ;
        update orderForUpdate;
        ordIds.clear();
        for(Order__c o : orderForUpdate){
            ordIds.add(o.Id);
        }

        for(Order__c o : [Select OrderDate__c, OrderStatus__c, Finance_Order_Type_pickList__c from Order__c where Id in : ordIds]){
            System.assertEquals('Closed', o.OrderStatus__c); //automatically closed because it has no OLI per I-224844
            System.assertNotEquals(Date.today(), o.OrderDate__c);
            //System.assertEquals('Existing', o.Finance_Order_Type_pickList__c);
        }

        Test.stopTest();

    }
    /**
* @author Andre Calimlim
* @date 1.7.15
* @description Negative Test method to verify that the Finance Order Type Existing will not be set if Order Status is New.
*/
    @isTest
    static  void testExistingFOTNew() {

        //createRec('North America', false);
        prepareData();
        accountList[0].AccountStatus__c = 'Customer';
        accountList[0].CustomerNumber__c = '11';
        accountList[0].CustomerDate__c = Date.today();
        //update accountList;
        List<Order__c> orderList = new List<Order__c>();
        Order__c ord = TestDataSetupUtility.createOrderWithOpportunity(accountList[0].Id, null, null, con.Id);
        ord.OrderDate__c = Date.today();
        ord.OrderStatus__c = 'Verified';
        orderList.add(ord);
        insert orderList;
        personalSettings.Trigger_Order__c = true;
        update personalSettings;

        Set<Id> ordIds = new Set<Id>();
        Test.startTest();

        for(Order__c o : orderList){
            ordIds.add(o.Id);
        }



        List<Order__c> orderForUpdate = [Select Account__c, OrderStatus__c, OrderDate__c, Finance_Order_Type_pickList__c from Order__c where Id in : ordIds];
        for(Order__c o : orderForUpdate){
            //System.assertEquals('New', o.Finance_Order_Type_pickList__c);
            //System.assertEquals(Date.today(), o.OrderDate__c);
            o.OrderStatus__c = 'Open';
            o.OrderDate__c = Date.today().addDays(5);
        }
        update orderForUpdate;
        ordIds.clear();
        for(Order__c o : orderForUpdate){
            ordIds.add(o.Id);
        }

        for(Order__c o : [Select OrderDate__c, OrderStatus__c, Finance_Order_Type_pickList__c from Order__c where Id in : ordIds]){
            System.assertEquals('Open', o.OrderStatus__c);
            System.assertNotEquals(Date.today(), o.OrderDate__c);
            //System.assertEquals('New', o.Finance_Order_Type_pickList__c);
        }
        Test.stopTest();

    }
    /**
* @author Andre Calimlim
* @date 1.7.15
* @description Positive Test method to verify that the Finance Order Type is Winback when updated.
*/
    @isTest
    static  void testWinbackFOTVerified() {

        //createRec('North America', false);
        prepareData();
        accountList[0].AccountStatus__c = 'Customer';
        accountList[0].CustomerNumber__c = '11';
        accountList[0].CustomerDate__c = Date.today();
        //update accountList;
        List<Order__c> orderList = new List<Order__c>();
        Order__c ord = TestDataSetupUtility.createOrderWithOpportunity(accountList[0].Id, null, null, con.Id);
        ord.OrderDate__c = Date.today();
        ord.OrderStatus__c = 'Open';
        orderList.add(ord);
        insert orderList;

        accountList[0].AccountStatus__c = 'Lapsed Customer';
        accountList[0].CustomerLapsedDate__c = Date.today();
        //update accountList;

        Set<Id> acctSet = new Set<Id>();
        Set<Id> ordIds = new Set<Id>();
        personalSettings.Trigger_Order__c = true;
        update personalSettings;
        Test.startTest();

        for(Order__c o : orderList){
            ordIds.add(o.Id);
            acctSet.add(o.Account__c);
        }



        List<Order__c> orderForUpdate = [Select OrderStatus__c, OrderDate__c, Finance_Order_Type_pickList__c from Order__c where Id in : ordIds];
        list<Order_Line_Item__c> lstOrderItem = new   list<Order_Line_Item__c>();

        for(Order__c o : orderForUpdate){

            System.assertEquals(Date.today(), o.OrderDate__c);
            o.OrderStatus__c = 'Verified';
            o.OrderDate__c = Date.today().addDays(396);
            lstOrderItem.add(TestDataSetupUtility.createOrderLineItem(ord.id));
        }
        if(lstOrderItem.size()>0)
            insert lstOrderItem;
        update orderForUpdate;
        ordIds.clear();
        for(Order__c o : orderForUpdate){
            ordIds.add(o.Id);
        }
        Map<Id, Account> acctMap = new Map<Id, Account>([Select Id, CustomerDate__c, CustomerLapsedDate__c, AccountStatus__c from Account where Id in : acctSet]);
        List<Order__c> orderUpdated = [Select OrderDate__c, OrderStatus__c, Account__c, Finance_Order_Type_pickList__c from Order__c where Id in : ordIds];
        for(Order__c o : orderUpdated){
            // System.assertNotEquals(null, acctMap.get(ord.Account__c).CustomerLapsedDate__c);
            System.assertNotEquals(Date.today(), o.OrderDate__c);
            //   System.assertEquals('Winback', o.Finance_Order_Type_pickList__c);
        }
        Test.stopTest();

    }

    /**
* @author Andre Calimlim
* @date 1.7.15
* @description Positive Test method to verify that the Finance Order Type is Lapsed when updated.
*/
    @isTest
    static  void testLapsedFOTClosed() {

        //createRec('North America', false);
        prepareData();
        accountList[0].AccountStatus__c = 'Customer';
        accountList[0].CustomerNumber__c = '11';
        accountList[0].CustomerDate__c = Date.today();
        //update accountList;
        List<Order__c> orderList = new List<Order__c>();
        Order__c ord = TestDataSetupUtility.createOrderWithOpportunity(accountList[0].Id, null, null, con.Id);
        ord.OrderDate__c = Date.today();
        ord.OrderStatus__c = 'Verified';
        orderList.add(ord);
        insert orderList;

        accountList[0].AccountStatus__c = 'Lapsed Customer';
        accountList[0].CustomerLapsedDate__c = Date.today();
        //update accountList;

        Set<Id> acctSet = new Set<Id>();
        Set<Id> ordIds = new Set<Id>();
        personalSettings.Trigger_Order__c = true;
        update personalSettings;
        Test.startTest();

        for(Order__c o : orderList){
            ordIds.add(o.Id);
            acctSet.add(o.Account__c);
        }



        List<Order__c> orderForUpdate = [Select OrderStatus__c, OrderDate__c, Finance_Order_Type_pickList__c from Order__c where Id in : ordIds];
        for(Order__c o : orderForUpdate){

            System.assertEquals(Date.today(), o.OrderDate__c);
            o.OrderStatus__c = 'Verified';
            o.OrderDate__c = Date.today().addDays(365);
        }
        update orderForUpdate;
        ordIds.clear();
        for(Order__c o : orderForUpdate){
            ordIds.add(o.Id);
        }
        Map<Id, Account> acctMap = new Map<Id, Account>([Select Id, CustomerDate__c, CustomerLapsedDate__c, AccountStatus__c from Account where Id in : acctSet]);
        List<Order__c> orderUpdated = [Select OrderDate__c, OrderStatus__c, Account__c, Finance_Order_Type_pickList__c from Order__c where Id in : ordIds];
        for(Order__c o : orderUpdated){
            //System.assertNotEquals(null, acctMap.get(ord.Account__c).CustomerLapsedDate__c);
            System.assertNotEquals(Date.today(), o.OrderDate__c);
            //System.assertEquals('Lapsed', o.Finance_Order_Type_pickList__c);
        }
        Test.stopTest();

    }

    /**
* @author Andre Calimlim
* @date 1.7.15
* @description Positive Test method to verify that the Finance Order Type is copied from the Parent Order if it is a Credit Recordtype.
*/
    @isTest
    static  void testCreditOrderFOTVerified() {

        //createRec('North America', false);
        prepareData();
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User testUser = TestDataSetupUtility.createTestUser('Test', 'Test', adminProfile.Id);
        Id userId = Userinfo.getUserId();
        insert testUser;
        System.runAs(testUser) {
            accountList[0].AccountStatus__c = 'Customer';
            accountList[0].CustomerNumber__c = '11';
            accountList[0].CustomerDate__c = Date.today();
            //update accountList;
            Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', 'Price list for Apttus',
                                                                                          Date.today(), Date.today().addMonths(12), true);
            Apttus_Proposal__Proposal__c proposal = TestDataSetupUtility.CreateQuoteOrProposal('Test Configure',
                                                                                               oppList[0].id, Date.today(), Date.today().addMonths(12),
                                                                                               priceList.Id, Date.today(), '3 Years', true, false);

            proposal.Payment1_Term__c =  'Net 10';
            proposal.Payment1_Frequency__c = 'Monthly';
            proposal.Payment_Method1__c =  'Invoice';
            proposal.Earliest_Start_Date__c = Date.today();
            proposal.Latest_End_Date__c = Date.today().addYears(1);
            insert proposal;
            List<Order__c> orderList = new List<Order__c>();
            Order__c ord = TestDataSetupUtility.createOrderWithOpportunity(accountList[0].Id, null, proposal.Id, con.Id);
            ord.OrderDate__c = Date.today();
            ord.OrderStatus__c = 'Open';
            ord.Payment_Term_text__c =  'Net 10';
            ord.Payment_Frequency__c = 'Monthly';
            ord.Payment_Method_text__c =  'Invoice';
            ord.AccountOrganization__c = 'North America';
            ord.Organization__c = 'North America';
            //ord.OrderStatus__c = 'Verified';
            insert ord;

            Order_Line_Item__c  oLI2 =TestDataSetupUtility.createOrderLineItem(ord.id);
            insert oLI2;
            ord.OrderStatus__c = 'Verified';
            update ord;
            Order__c creditOrd = TestDataSetupUtility.createOrderWithOpportunity(accountList[0].Id, null, proposal.Id, con.Id);

            //orderList.add(ord);
            creditOrd.OrderDate__c = Date.today();
            creditOrd.OrderStatus__c = 'Open';
            creditOrd.Payment_Term_text__c =  'Net 10';
            creditOrd.Payment_Frequency__c = 'Monthly';
            creditOrd.Payment_Method_text__c =  'Invoice';
            creditOrd.AccountOrganization__c = 'North America';
            creditOrd.Organization__c = 'North America';
            insert orderList;
            creditOrd.RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Credit').getRecordTypeId();
            creditOrd.ParentOrder__c = ord.Id;
            accountList[0].AccountStatus__c = 'Lapsed Customer';
            accountList[0].CustomerLapsedDate__c = Date.today();
            //update accountList;
            orderList.add(creditOrd);
            Set<Id> acctSet = new Set<Id>();
            Set<Id> ordIds = new Set<Id>();
            creditOrd.MAPPPrimarySalesRep__c = userId;
            insert creditOrd;

            personalSettings.Trigger_Order__c = true;
            update personalSettings;

            Test.startTest();

            for(Order__c o : orderList){
                ordIds.add(o.Id);
                acctSet.add(o.Account__c);
            }



            List<Order__c> orderForUpdate = [Select OrderStatus__c, OrderDate__c, Finance_Order_Type_pickList__c from Order__c where Id in : ordIds];
            for(Order__c o : orderForUpdate){

                System.assertEquals(Date.today(), o.OrderDate__c);
                o.OrderStatus__c = 'Verified';
                o.OrderDate__c = Date.today().addDays(365);
            }
            //update orderForUpdate;
            ordIds.clear();
            for(Order__c o : orderForUpdate){
                ordIds.add(o.Id);
            }
            Map<Id, Account> acctMap = new Map<Id, Account>([Select Id, CustomerDate__c, CustomerLapsedDate__c, AccountStatus__c from Account where Id in : acctSet]);
            Id ordIdUpdated;
            for(Order__c o : [Select Id, OrderDate__c, OrderStatus__c, Account__c, Finance_Order_Type_pickList__c from Order__c where Id in : ordIds]){
                //System.assertNotEquals(null, acctMap.get(ord.Account__c).CustomerLapsedDate__c);
                //System.assertNotEquals(Date.today(), o.OrderDate__c);
                //System.assertEquals('Lapsed', o.Finance_Order_Type_pickList__c);
                ordIdUpdated = o.Id;
            }


            OrderTriggerHandler.executeUpdateTrigger = true;
            Order_Line_Item__c  oLI1 =TestDataSetupUtility.createOrderLineItem(creditOrd.id);
            insert oLI1;
            creditOrd.OrderStatus__c = 'Verified';
            creditOrd.OrderDate__c = Date.today().addDays(365);
            creditOrd.MAPPPrimarySalesRep__c = userId;
            update creditOrd;
            for(Order__c o : [Select OrderDate__c, OrderStatus__c, Account__c, Finance_Order_Type_pickList__c from Order__c where Id = : creditOrd.Id]){
                //System.assertEquals(Date.today(), o.OrderDate__c);
                //System.assertEquals('Lapsed', o.Finance_Order_Type_pickList__c);
            }

            delete orderForUpdate;

            Test.stopTest();
        }
    }

    /**
* @author Jerick Laurio
* @date 1.7.15
* @description Positive Test method to verify that the Finance Order Type is copied from the Parent Order if it is a Credit Recordtype.
*/
    @isTest
    static  void testOrderCreation() {
        //createRec('SampleAcctName', false);
        //oppList[0].Stagename = 'Stage 4 - Won';
        prepareData();
        personalSettings.Trigger_Opportunity__c = true;
        personalSettings.Trigger_Order__c = true;
        update personalSettings;
        oppList[0].Stagename = 'Stage 4 - Won';
        oppList[0].OrderCreated__c = true;
        //oppList[0].OwnerId = UserInfo.getUserId();
        OpportunityTriggerHandler.RunCount = 0;
        BaseTriggerHandler.SkipOppUpdateToPreventRecursion =false;
        update oppList;



    }
    @isTest
    static  void EarliestProductStartDate() {
        /*//personalSettings = TestDataSetupUtility.buildPersonalSetting();
Account acc = TestDataSetupUtility.createTestAccount('Test Account', 'North America', UserInfo.getUserId());
//insert acc;
Contact con1 = TestDataSetupUtility.createTestContact(acc.id,'test','Con','aon122@gmail.com');
//insert con1;*/
        prepareData();
        Order__c ord = TestDataSetupUtility.createOrder(accountList[0].Id, con.Id);
        insert ord;
        Order_Line_Item__c oLI = TestDataSetupUtility.createOrderLineItem(ord.Id);
        oLi.Earliest_Product_Start_Date__c = Date.today();
        Order_Line_Item__c oLI1 = TestDataSetupUtility.createOrderLineItem(ord.Id);
        oLi.Earliest_Product_Start_Date__c = Date.today().addDays(100);
        Order_Line_Item__c oLI2 = TestDataSetupUtility.createOrderLineItem(ord.Id);
        oLi.Earliest_Product_Start_Date__c = Date.today().addDays(200);
        Order_Line_Item__c oLI3 = TestDataSetupUtility.createOrderLineItem(ord.Id);
        oLi.Earliest_Product_Start_Date__c = Date.today().addDays(400);
        oLI.NetCreditAmount__c = 100;
        oLI1.NetCreditAmount__c = 100;
        oLI2.NetCreditAmount__c = 100;
        oli.NetRemainingCreditAmount__c = null;
        oli.GrossRemainingCreditAmount__c = null;

        insert new List<Order_Line_Item__c>{oLI, oLI1, oLI2, oLI3};
            personalSettings.Trigger_Order__c = true;
        update personalSettings;


        Credit_Request__c creditrequest = TestDataSetupUtility.createCreditRequest(ord.id);
        insert creditrequest;
        CreditRequestLineItem__c crl = new CreditRequestLineItem__c();
        crl.CreditCondition__c = 'Full';
        crl.Credit_Request__c = creditRequest.Id;
        crl.Order_Line_Item__c = oli.id;
        crl.TaxAmount__c = 10;
        crl.AvailableCreditAmount__c = 10;
        crl.CreditAmount__c = 10;
        crl.NetCreditAmount__c = 10;
        crl.NetRemainingCreditAmount__c = 10;
        crl.NetTotalAmount__c = 10;
        crl.VATNationalTaxAmount__c = 10;
        crl.Unit_Price__c = 10;
        insert crl;

        oli.CreditRequestLineItem__c = crl.id;
        oli1.CreditRequestLineItem__c = crl.id;
        oli2.CreditRequestLineItem__c = crl.id;
        oli3.CreditRequestLineItem__c = crl.id;

        update new List<Order_Line_Item__c>{oli,oli1,oli2,oli3};

            ord.RecordTypeId =  Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Credit');
        ord.OrderStatus__c = 'Negated';
        update ord;

    }
    // Test method to cover T-424791 piece of code
    @isTest
    static  void testIsValidOnOrder(){
        /*personalSettings = TestDataSetupUtility.buildPersonalSetting();
personalSettings.Trigger_Order__c = true;
insert personalSettings;
Account acc = TestDataSetupUtility.createTestAccount('Test Account', 'North America', UserInfo.getUserId());
insert acc;
Contact con1 = TestDataSetupUtility.createTestContact(acc.id,'test','Con','aon122@gmail.com');
insert con1;*/
        prepareData();
        personalSettings.Trigger_Order__c = true;
        update personalSettings;
        Order__c ord = TestDataSetupUtility.createOrder(accountList[0].Id, con.Id);
        ord.OrderStatus__c = 'Open';
        ord.Sent_to_Verification__c = false;
        insert ord;

        ord = [Select isValid__c,OrderStatus__c,Payment_Frequency__c,Sent_to_Verification__c from Order__c Where Id = :ord.Id];


        ord.OrderStatus__c = 'Finance Hold';
        ord.Payment_Frequency__c = '6 - Monthly';
        ord.Sent_to_Verification__c = true;
        update ord;

        ord = [Select isValid__c,OrderStatus__c,Payment_Frequency__c,Sent_to_Verification__c from Order__c Where Id = :ord.Id];
        //system.assertEquals(ord.isValid__c,'Valid');

    }

    @isTest
    static void testQuoteProposal(){

        /*Account acc = TestDataSetupUtility.createTestAccount('Test Account', 'North America', UserInfo.getUserId());
insert acc;
Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Oppty' , acc.id);
insert opp;
personalSettings = TestDataSetupUtility.buildPersonalSetting();
personalSettings.Trigger_Order__c = true;
personalSettings.Trigger_Account__c = true;
personalSettings.Trigger_Opportunity__c = true;
personalSettings.Validation_Account__c = true;
personalSettings.Validation_Opportunity__c = true;

insert personalSettings;*/
        prepareData();
        personalSettings.Trigger_Order__c = true;
        personalSettings.Trigger_Account__c = true;
        personalSettings.Trigger_Opportunity__c = true;
        personalSettings.Validation_Account__c = true;
        personalSettings.Validation_Opportunity__c = true;
        update personalSettings;
        Payment_Details__c paymentDetails = TestDataSetupUtility.createTestPaymentDetails('North America' , 'Monthly', 'Net 10');
        paymentDetails.PaymentMethod__c = 'Invoice';
        paymentDetails.Active__c  = true;
        //insert paymentDetails;
        Apttus_Proposal__Proposal__c  proposal = TestDataSetupUtility.createApttusProposal(oppList[0]);
        //proposal.PaymentDetails__c = paymentDetails.id;
        proposal.Payment1_Term__c =  'Net 10';
        proposal.Payment1_Frequency__c = 'Monthly';
        proposal.Payment_Method1__c =  'Invoice';
        proposal.Earliest_Start_Date__c = Date.today();
        proposal.Latest_End_Date__c = Date.today().addYears(1);

        insert proposal;
        //Contact con1 = TestDataSetupUtility.createTestContact(acc.id,'test','Con','aon122@gmail.com');
        //insert con1;
        Order__c ord = TestDataSetupUtility.createOrder(accountList[0].Id, con.Id);
        ord.OrderStatus__c = 'Open';
        ord.QuoteProposal__c = proposal.id;
        ord.Payment_Term_text__c =  'Net 10';
        ord.Payment_Frequency__c = 'Monthly';
        ord.Payment_Method_text__c =  'Invoice';
        ord.AccountOrganization__c = 'North America';
        ord.Organization__c = 'North America';
        ord.opportunity__c = oppList[0].id;
        ord.Posting_Contact__c = con.id;
        insert ord;
        OrderTriggerHandler.executeUpdateTrigger = false;
        ord.Approval_Status__c = 'Rejected';
        update ord;
        OrderTriggerHandler.executeUpdateTrigger = false;
        ord.Approval_Status__c = 'Re-Open';
        update ord;

    }

    @isTest
    static void testSetOpportunityApprovalstatusToRejected() {
        /*Account acc = TestDataSetupUtility.createTestAccount('Test Account', 'North America', UserInfo.getUserId());
insert acc;
Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Oppty' , acc.id);
insert opp;

personalSettings = TestDataSetupUtility.buildPersonalSetting();

*/
        prepareData();
        personalSettings.Trigger_Order__c = true;
        personalSettings.Trigger_Account__c = true;
        personalSettings.Trigger_Opportunity__c = true;
        personalSettings.Validation_Account__c = true;
        personalSettings.Validation_Opportunity__c = true;
        update personalSettings;
        OrderTriggerHandler.ExecuteTriggers = true;

        Payment_Details__c paymentDetails = TestDataSetupUtility.createTestPaymentDetails('North America' , 'Monthly', 'Net 10');
        paymentDetails.PaymentMethod__c = 'Invoice';
        paymentDetails.Active__c  = true;
        //insert paymentDetails;
        Apttus_Proposal__Proposal__c  proposal = TestDataSetupUtility.createApttusProposal(oppList[0]);
        proposal.Create_Assets__c = false;
        proposal.Payment1_Term__c =  'Net 10';
        proposal.Payment1_Frequency__c = 'Monthly';
        proposal.Payment_Method1__c =  'Invoice';
        proposal.Earliest_Start_Date__c = Date.today();
        proposal.Latest_End_Date__c = Date.today().addYears(1);

        insert proposal;

        //Contact con1 = TestDataSetupUtility.createTestContact(acc.id,'test','Con','aon122@gmail.com');
        //insert con1;
        Order__c ord = TestDataSetupUtility.createOrder(accountList[0].Id, con.Id);
        ord.OrderStatus__c = 'Open';
        ord.QuoteProposal__c = proposal.id;
        ord.Payment_Term_text__c =  'Net 10';
        ord.Payment_Frequency__c = 'Monthly';
        ord.Payment_Method_text__c =  'Invoice';
        ord.AccountOrganization__c = 'North America';
        ord.Organization__c = 'North America';
        ord.opportunity__c = oppList[0].id;
        ord.Approval_Status__c = 'Re-Open';
        ord.BillingAccount__c = accountList[0].Id;
        ord.Posting_Contact__c = con.id;

        insert ord;

        OrderTriggerHandler.executeUpdateTrigger = true;
        ord.Approval_Status__c = 'Rejected';
        ord.OrderStatus__c = 'Rejected';
        update ord;

        for(Opportunity oppr : [SELECT Apttus_Approval__Approval_Status__c FROM Opportunity WHERE Id =: oppList[0].Id]){
            system.assertEquals(oppr.Apttus_Approval__Approval_Status__c, 'Rejected');
        }

        for(Apttus_Proposal__Proposal__c  proposal1 : [Select Id, Active__c From Apttus_Proposal__Proposal__c Where Id =: proposal.Id]) {
            system.assertEquals(proposal1.Active__c, true);
        }

        Test.startTest();
        Order_Line_Item__c  oLI2 =TestDataSetupUtility.createOrderLineItem(ord.id);
        insert oLI2;
        ord.OrderStatus__c = 'Verified';
        update ord;

        Test.stopTest();

    }

    @isTest
    static void testSetOpportunityApprovalstatusToRejected2() {
        //Jeff L Created this method  9/6/16 - splitting out some of the logic that was
        //being tested as part of testSetOpportunityApprovalstatusToRejected

        prepareData();
        personalSettings.Trigger_Order__c = true;
        personalSettings.Trigger_Account__c = true;
        personalSettings.Trigger_Opportunity__c = true;
        personalSettings.Validation_Account__c = true;
        personalSettings.Validation_Opportunity__c = true;
        update personalSettings;
        OrderTriggerHandler.ExecuteTriggers = true;


        /**/
        Account acc = TestDataSetupUtility.createTestAccount('Test Account', 'North America', UserInfo.getUserId());
        acc.Partner_Flag__c = true;
        acc.AgencyFlag__c = true;
        acc.Organization__c = 'TestOrg';
        acc.Suppress_Invoice_Detail__c = null;

        insert new List<Account>{acc};
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Oppty' , acc.id);
        insert opp;

        Contact con1 = TestDataSetupUtility.createTestContact(acc.id,'test','Con','aon122@gmail.com');
        con1.PrimarySalesContact__c = true;
        insert con1;

        Test.startTest();

        List<Order__c> orderList = new List<Order__c>();
        Order__c ord2 = TestDataSetupUtility.createOrder(acc.Id, con1.Id);
        ord2.OrderStatus__c = 'Open';
        ord2.SiteChannelID__c = '123234';
        insert ord2;

        Test.stopTest();

    }

    @isTest
    static void testPopulateOrderPrimarySalesRepFromMAPP() {
        /*Account acc = TestDataSetupUtility.createTestAccount('Test Account', 'North America', UserInfo.getUserId());
acc.AccountStatus__c = 'Candidate';
insert acc;
personalSettings = TestDataSetupUtility.buildPersonalSetting();
personalSettings.Trigger_Order__c = true;
insert personalSettings;
Contact con1 = TestDataSetupUtility.createTestContact(acc.id,'test','Con','aon122@gmail.com');
insert con1;

*/
        prepareData();
        personalSettings.Trigger_Order__c = true;
        update personalSettings;
        //Create price list
        Apttus_Config2__PriceList__c price = TestDataSetupUtility.createPriceList('USD Price List', false);
        insert price;
        Payment_Details__c paymentDetails = TestDataSetupUtility.createTestPaymentDetails('North America' , 'Monthly', 'Net 10');
        paymentDetails.PaymentMethod__c = 'Invoice';
        paymentDetails.Active__c  = false;
        //insert paymentDetails;

        Order__c ord1 = TestDataSetupUtility.createOrder(accountList[0].Id, con.Id);
        ord1.OrderStatus__c = 'Open';
        ord1.Payment_Term_text__c =  'Net 10';
        ord1.Payment_Frequency__c = 'Monthly';
        ord1.Payment_Method_text__c =  'Invoice';
        ord1.AccountOrganization__c = 'North America';
        ord1.Organization__c = 'North America';
        ord1.Approval_Status__c = 'Re-Open';
        ord1.MAPP_Price_List__c = price.Name;
        ord1.MAPPPrimarySalesRep__c = Userinfo.getUserName();//usr.Username;
        //ord1.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Credit');
        ord1.Account__c = accountList[0].Id;
        Test.startTest();
        insert ord1;
        ord1.AccountOrganization__c = 'Europe';
        update ord1;
        List<Order__c> orderList = new List<Order__c>();
        orderList.add(ord1);
        OrderTriggerHelper helper = OrderTriggerHelper.NewTriggerHelper();
        helper.AssignOrderFromMAPP(orderList);
        Test.stopTest();
    }
    @isTest
    static void testNegateClosedCases() {
        /*Account acc = TestDataSetupUtility.createTestAccount('Test Account', 'North America', UserInfo.getUserId());
acc.AccountStatus__c = 'Candidate';
insert acc;
Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Oppty' , acc.id);
insert opp;
personalSettings = TestDataSetupUtility.buildPersonalSetting();
personalSettings.Trigger_Order__c = true;
personalSettings.Trigger_Account__c = true;
personalSettings.Trigger_Opportunity__c = true;
personalSettings.Validation_Account__c = true;
personalSettings.Validation_Opportunity__c = true;
insert personalSettings;
*/
        prepareData();
        personalSettings.Trigger_Order__c = true;
        personalSettings.Trigger_Account__c = true;
        personalSettings.Trigger_Opportunity__c = true;
        personalSettings.Validation_Account__c = true;
        personalSettings.Validation_Opportunity__c = true;
        update personalSettings;
        //Create price list
        Apttus_Config2__PriceList__c price = TestDataSetupUtility.createPriceList('USD Price List', false);
        insert price;
        OrderTriggerHandler.ExecuteTriggers = true;
        Payment_Details__c paymentDetails = TestDataSetupUtility.createTestPaymentDetails('North America' , 'Monthly', 'Net 10');
        paymentDetails.PaymentMethod__c = 'Invoice';
        paymentDetails.Active__c  = false;
        //insert paymentDetails;

        Apttus_Proposal__Proposal__c  proposal = TestDataSetupUtility.createApttusProposal(oppList[0]);
        proposal.Create_Assets__c = false;
        proposal.Payment1_Term__c =  'Net 10';
        proposal.Payment1_Frequency__c = 'Monthly';
        proposal.Payment_Method1__c =  'Invoice';
        proposal.Earliest_Start_Date__c = Date.today();
        proposal.Latest_End_Date__c = Date.today().addYears(1);

        insert proposal;

        Id CreditRecordtypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Credit');
        Id ProductImplementationCaseRecordtypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Case', 'Product Implementation');
        //Contact con1 = TestDataSetupUtility.createTestContact(acc.id,'test','Con','aon122@gmail.com');
        //insert con1;
        /*Order__c ordp1 = TestDataSetupUtility.createOrder(accountList[0].Id, con.Id);
ordp1.OrderStatus__c = 'Open';
ordp1.QuoteProposal__c = proposal.id;
ordp1.Payment_Term_text__c =  'Net 10';
ordp1.Payment_Frequency__c = 'Monthly';
ordp1.Payment_Method_text__c =  'Invoice';
ordp1.AccountOrganization__c = 'North America';
ordp1.opportunity__c = oppList[0].id;
ordp1.Approval_Status__c = 'Re-Open';
ordp1.MAPP_Price_List__c = price.Id;
insert ordp1;*/
        Order__c ord1 = TestDataSetupUtility.createOrder(accountList[0].Id, con.Id);
        ord1.OrderStatus__c = 'Open';
        ord1.QuoteProposal__c = proposal.id;
        ord1.Payment_Term_text__c =  'Net 10';
        ord1.Payment_Frequency__c = 'Monthly';
        ord1.Payment_Method_text__c =  'Invoice';
        ord1.AccountOrganization__c = 'North America';
        ord1.Organization__c = 'North America';
        ord1.opportunity__c = oppList[0].id;
        ord1.Approval_Status__c = 'Re-Open';
        ord1.MAPP_Price_List__c = price.Id;
        //ord1.ParentOrder__c = accountList[0].Id;
        //ord1.MAPPPrimarySalesRep__c = Userinfo.getUserId();
        ord1.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Credit');
        ord1.Account__c = accountList[0].Id;
        ord1.Posting_Contact__c = con.id;
        insert ord1;
        //system.debug('<<orderid>>'+ord1.Id);
        Order_Line_Item__c oli = TestDataSetupUtility.createOrderLineItem(ord1.Id);
        oli.Owner_on_Start_Date__c = userInfo.getUserId();
        insert oli;
        Credit_Request__c creditrequest = TestDataSetupUtility.createCreditRequest(ord1.id);
        insert creditrequest;
        CreditRequestLineItem__c crl = new CreditRequestLineItem__c();
        crl.CreditCondition__c = 'Full';
        crl.Credit_Request__c = creditRequest .Id;
        crl.Order_Line_Item__c = oli.id;
        crl.TaxAmount__c = 10;
        crl.AvailableCreditAmount__c = 10;
        crl.CreditAmount__c = 10;
        crl.NetCreditAmount__c = 10;
        crl.NetRemainingCreditAmount__c = 10;
        crl.NetTotalAmount__c = 10;
        crl.VATNationalTaxAmount__c = 10;
        crl.Unit_Price__c = 10;
        insert crl;
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User usr =  TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);
        insert usr;
        System.runAs(usr){

            List<Case> caseList = new List<Case>();
            Case cas = TestDataSetupUtility.createTestNewAccountRequestCase('Europe', usr.Id);
            cas.OrderLineItem__c = oli.Id;
            cas.RecordTypeId = ProductImplementationCaseRecordtypeId;
            cas.Order__c = ord1.Id;
            cas.Status = 'Closed';
            //Case cas2 = TestDataSetupUtility.createTestNewAccountRequestCase('Europe', usr.Id);
            // cas2.OrderLineItem__c = oli.Id;
            // cas2.RecordTypeId = ProductImplementationCaseRecordtypeId;
            //cas2.Order__c = ord1.Id;
            //cas2.Status = 'Open';
            Test.startTest();
            insert cas;
            caseList.add(cas);
            //caseList.add(cas2);
            caseList.add(TestDataSetupUtility.createTestNewAccountRequestCase('Europe', usr.Id));
            caseList[1].OrderLineItem__c = oli.Id;
            caseList[1].RecordTypeId = ProductImplementationCaseRecordtypeId;
            caseList[1].Order__c = ord1.Id;
            caseList[1].Status = 'Open';
            caseList[1].ParentId = cas.Id;
            insert caseList[1];
            List<Order__c> ordList = new List<Order__c>();

            ordList.add( TestDataSetupUtility.createOrder(accountList[0].Id));
            ordList.add( TestDataSetupUtility.createOrder(accountList[0].Id));

            for(Order__c ord : ordList){
                ord.OrderStatus__c = 'Open';
                ord.QuoteProposal__c = proposal.id;
                ord.Payment_Term_text__c =  'Net 10';
                ord.Payment_Frequency__c = 'Monthly';
                ord.Payment_Method_text__c =  'Invoice';
                ord.AccountOrganization__c = 'North America';
                ord.Organization__c = 'North America';
                ord.opportunity__c = oppList[0].id;
                ord.Approval_Status__c = 'Re-Open';
                ord.ParentOrder__c = ord1.Id;
                ord.Account__c = accountList[0].Id;
                ord.CreditRequest__c = creditrequest.Id;
                ord.CreditType__c = 'Full' ;
                ord.OrderStatus__c = 'Verified';
            }
            ordList[0].RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Credit');
            ordList[1].RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Negate');

            insert ordList;
            system.debug('<<ordList>>'+ordList);
            OrderTriggerHelper helper = OrderTriggerHelper.NewTriggerHelper();
            helper.PreventCreationOfCreditOrder(ordList);
            Test.stopTest();
        }
    }





    @isTest
    static void testIntegrationOrder() {

        Account acc = TestDataSetupUtility.createTestAccount('Test Account', 'North America', UserInfo.getUserId());
        acc.Partner_Flag__c = true;
        acc.AgencyFlag__c = true;
        acc.Suppress_Invoice_Detail__c = null;

        Account acc2 = TestDataSetupUtility.createTestAccount('Testing Account2', 'Europe', UserInfo.getUserId());
        acc2.Phone = '6543876598';
        //acc2.PrimaryRelatedAgency__c = partner.Id;
        //insert acc2;
        insert new List<Account>{acc,acc2};
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Oppty' , acc.id);
        insert opp;




        prepareData();
        RelatedPartner__c partner = new RelatedPartner__c();
        partner.Account__c = acc2.id;
        partner.Partner__c = acc.Id;
        partner.AgencyType__c = 'Billing';
        partner.role__c = 'Agency';

        insert partner;
        Account acc1 = TestDataSetupUtility.createTestAccount('Test 123 Account', 'Asia Pacific', UserInfo.getUserId());
        acc1.Phone = '1234567891';
        acc1.ShippingStreet = 'Red S';
        acc1.ShippingCity = 'NY';
        acc1.ShippingPostalCode = '12345';
        acc1.Website = 'www.abc1.com';
        acc1.Phone = '4534445344';
        acc1.AccountStatus__c = 'Customer';
        acc1.PrimaryRelatedAgency__c = partner.Id;

        insert acc1;
        Partner_Revenue_Share__c  partnerRS = new Partner_Revenue_Share__c ();
        partnerRS.Partner__c = acc1.Id;
        partnerRS.SiteChannelID__c = '123234';
        //insert partnerRS;
        Contact con1 = TestDataSetupUtility.createTestContact(acc1.id,'test','Con','aon122@gmail.com');
        insert con1;
        User integrationUser = TestDataSetupUtility.createUser('System Administrator',false);
        integrationUser.FirstName= 'Integration';
        integrationUser.LastName = 'MAPP';
        insert integrationUser;
        acc1.OwnerId = integrationUser.Id;
        update acc1;

        //personalSettings = TestDataSetupUtility.buildPersonalSetting();

        //Turn off a couple of our triggers using personal settings:
        //this is to reduce # of SOQL errors during test class run
        personalSettings.Trigger_Order__c = true;
        personalSettings.Trigger_Account__c = false;
        personalSettings.Trigger_Contact__c = false;
        personalSettings.Trigger_Opportunity__c = false;
        personalSettings.Trigger_Case__c = false;
        personalSettings.Trigger_Quote__c = false;
        personalSettings.Validation_Account__c = true;
        personalSettings.Validation_Opportunity__c = true;
        update personalSettings;

        OrderTriggerHandler.ExecuteTriggers = true;
        OrderTriggerHandler.executeUpdateTrigger = true;

        List<Order__c> orderList = new List<Order__c>();
        Order__c ord = TestDataSetupUtility.createOrder(acc1.Id, con1.Id);
        ord.OrderStatus__c = 'Open';
        //ord.QuoteProposal__c = proposal.id;
        ord.AccountOrganization__c = 'North America';
        ord.opportunity__c = oppList[0].id;
        ord.CR_Status_Comment__c = 'testing Comments';
        ord.Approval_Status__c = 'Re-Open';
        ord.ShippingContact__c = con1.Id;
        ord.BillingAccount__c = acc1.id;
        ord.Agency__c = acc.Id;
        ord.Account__c = acc1.Id;
        ord.MAPP_Payment_Frequency__c = 'Invoice';
        ord.MAPPBillingAccount__c  = acc1.Id;
        ord.MAPPBillingContact__c =con1.Id;
        ord.MAPP_Archive_Posting_Contact__c = con1.Id;
        ord.MAPP_Archive_Posting_Customer_PO__c = 'PO';
        ord.OrderStatus__c = 'Open';
        ord.PrimarySalesRep__c = UserInfo.getUserId();
        ord.SiteChannelID__c = '123234';
        orderList.add(ord);
        orderList.add(TestDataSetupUtility.createOrder(acc1.Id, con1.Id));
        orderList.add(TestDataSetupUtility.createOrder(acc.Id, con1.Id));
        orderList.add(TestDataSetupUtility.createOrder(acc.Id, con1.Id));
        orderList.add(TestDataSetupUtility.createOrder(acc.Id, con1.Id));
        orderList.add(TestDataSetupUtility.createOrder(acc.Id, con1.Id));
        orderList.add(TestDataSetupUtility.createOrder(acc.Id, con1.Id));
        orderList.add(TestDataSetupUtility.createOrder(acc.Id, con1.Id));
        orderList.add(TestDataSetupUtility.createOrder(acc.Id, con1.Id));
        orderList.add(TestDataSetupUtility.createOrder(acc.Id, con1.Id));
        orderList[1].MAPP_Payment_Frequency__c = 'PayPal';
        orderList[2].MAPP_Payment_Frequency__c = 'EU Net 20';
        orderList[3].MAPP_Payment_Frequency__c = 'Pre-Paid';
        orderList[4].MAPP_Payment_Frequency__c = 'Zero Value';
        orderList[5].MAPP_Payment_Frequency__c = 'EU Pre-Pai';
        orderList[6].MAPP_Payment_Frequency__c = 'EU Net 15';
        orderList[7].MAPP_Payment_Frequency__c = 'EU Net 30';
        orderList[8].MAPP_Payment_Frequency__c = 'EU Net 45';
        orderList[1].OrderStatus__c = 'Pending Processing';
        orderList[2].OrderStatus__c = 'Pending Processing';
        orderList[2].RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Credit');
        orderList[2].MAPPPrimarySalesRep__c = Userinfo.getUserId();
        System.runAs(integrationUser){
            Test.startTest();

            for(Order__C o :orderList){
                o.OrderStatus__c = 'Open';
            }

            // insert orderList;
            list<Order_Line_Item__c> lstOrdList = new list<Order_Line_Item__c>();
            for(Order__C o :orderList){
                o.OrderStatus__c = 'Open';
                lstOrdList.add(TestDataSetupUtility.createOrderLineItem(ord.id) );
            }
            //update orderList;
            //update lstOrdList;
            Test.StopTest();
        }
    }

    @isTest
    static void testIntegrationOrderUpdate() {

        Account acc = TestDataSetupUtility.createTestAccount('Test Account', 'North America', UserInfo.getUserId());
        acc.Partner_Flag__c = true;
        acc.AgencyFlag__c = true;
        acc.Suppress_Invoice_Detail__c = null;

        Account acc2 = TestDataSetupUtility.createTestAccount('Testing Account2', 'Europe', UserInfo.getUserId());
        acc2.Phone = '6543876598';
        //acc2.PrimaryRelatedAgency__c = partner.Id;
        //insert acc2;
        insert new List<Account>{acc,acc2};
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Oppty' , acc.id);
        insert opp;




        prepareData();
        RelatedPartner__c partner = new RelatedPartner__c();
        partner.Account__c = acc2.id;
        partner.Partner__c = acc.Id;
        partner.AgencyType__c = 'Billing';
        partner.role__c = 'Agency';

        insert partner;
        Account acc1 = TestDataSetupUtility.createTestAccount('Test 123 Account', 'Asia Pacific', UserInfo.getUserId());
        acc1.Phone = '1234567891';
        acc1.ShippingStreet = 'Red S';
        acc1.ShippingCity = 'NY';
        acc1.ShippingPostalCode = '12345';
        acc1.Website = 'www.abc1.com';
        acc1.Phone = '4534445344';
        acc1.AccountStatus__c = 'Customer';
        acc1.PrimaryRelatedAgency__c = partner.Id;
        acc1.Partner_Flag__c = true;
        insert acc1;
        Partner_Revenue_Share__c  partnerRS = new Partner_Revenue_Share__c ();
        partnerRS.Partner__c = acc1.Id;
        partnerRS.SiteChannelID__c = '123234';
        //insert partnerRS;
        Contact con1 = TestDataSetupUtility.createTestContact(acc1.id,'test','Con','aon122@gmail.com');
        Contact con2 = TestDataSetupUtility.createTestContact(acc.id,'test1','Con','aon122@gmail.com');
        insert  new List<Contact>{con2,con1};
            User integrationUser = TestDataSetupUtility.createUser('System Administrator',false);
        integrationUser.FirstName= 'Integration';
        integrationUser.LastName = 'MAPP';
        insert integrationUser;
        acc1.OwnerId = integrationUser.Id;
        update acc1;

        Apttus_Proposal__Proposal__c proposal1 = TestDataSetupUtility.createProposal( acc.id, opp.id, 'COMPANY1');
        insert proposal1;
        OrderTriggerHandler.ExecuteTriggers = true;
        OrderTriggerHandler.executeUpdateTrigger = true;

        List<Order__c> orderList = new List<Order__c>();
        Order__c ord = TestDataSetupUtility.createOrder(acc1.Id, con1.Id);
        ord.OrderStatus__c = 'Open';
        ord.QuoteProposal__c = proposal1.id;
        ord.AccountOrganization__c = 'North America';
        ord.opportunity__c = opp.id;
        ord.CR_Status_Comment__c = 'testing Comments';
        ord.Approval_Status__c = 'Re-Open';
        ord.ShippingContact__c = con1.Id;
        ord.BillingAccount__c = acc1.id;
        ord.Agency__c = acc.Id;
        ord.Account__c = acc1.Id;
        ord.MAPP_Payment_Frequency__c = 'Invoice';
        ord.MAPPBillingAccount__c  = acc1.Id;
        ord.MAPPBillingContact__c =con1.Id;
        ord.MAPP_Archive_Posting_Contact__c = con1.Id;
        ord.MAPP_Archive_Posting_Customer_PO__c = 'PO';
        ord.OrderStatus__c = 'Verified';
        ord.PrimarySalesRep__c = UserInfo.getUserId();
        ord.SiteChannelID__c = '123234';
        orderList.add(ord);
        orderList.add(TestDataSetupUtility.createOrder(acc1.Id, con1.Id));
        orderList.add(TestDataSetupUtility.createOrder(acc.Id, con1.Id));

        orderList[2].QuoteProposal__c = proposal1.id;
        orderList[1].QuoteProposal__c = proposal1.id;



        orderList[2].RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Credit');
        insert orderList;
        Apttus_Proposal__Proposal__c proposal = TestDataSetupUtility.createProposal( acc.id, opp.id, 'COMPANY');
        insert proposal;
        //Turn off a couple of our triggers using personal settings:
        //this is to reduce # of SOQL errors during test class run
        personalSettings.Trigger_Order__c = true;
        personalSettings.Trigger_Account__c = false;
        personalSettings.Trigger_Contact__c = false;
        personalSettings.Trigger_Opportunity__c = false;
        personalSettings.Trigger_Case__c = false;
        personalSettings.Trigger_Quote__c = false;
        personalSettings.Validation_Account__c = true;
        personalSettings.Validation_Opportunity__c = true;
        update personalSettings;


        System.runAs(integrationUser){
            Test.startTest();
            //orderList[2].Account__c = acc1.Id;
            orderList[2].MAPPPrimarySalesRep__c = integrationUser.Id;


            orderList[1].QuoteProposal__c = proposal.Id;
            orderList[0].QuoteProposal__c = proposal.Id;
            orderList[2].QuoteProposal__c = proposal.Id;
            orderList[0].Agency__c = acc1.Id;
            try{

                update orderList;


            }catch(BaseApplicationException e){}
            catch(DmlException e){}
            catch(Exception e){}
            Test.StopTest();
        }
    }





    //Sylvester Agyen (Appirio)
    //3/14/2016

    static testMethod void testOrderSellingCountry(){
        /*Personal_Settings__c mysettings = TestDataSetupUtility.buildPersonalSetting();
mysettings.Trigger_Opportunity__c = true;
mysettings.Trigger_Order__c = true;
insert mysettings;

system.debug('testOrderSellingCountry start');
Account slyacc = TestDataSetupUtility.createTestAccount('Test 546 test', 'North America', UserInfo.getUserId());
slyacc.Phone = '1234509891';
slyacc.ShippingStreet = 'Red S';
slyacc.ShippingCity = 'NY';
slyacc.ShippingPostalCode = '12345';
slyacc.Website = 'www.vhf.com';
slyacc.Phone = '4534445344';
slyacc.AccountStatus__c = 'Customer';
insert slyacc;
system.debug('testOrderSellingCountry acc' + slyacc);
*/
        prepareData();
        personalSettings.Trigger_Opportunity__c = true;
        personalSettings.Trigger_Order__c = true;
        update personalSettings;
        accountList[0].Phone = '1234509891';
        accountList[0].ShippingStreet = 'Red S';
        accountList[0].ShippingCity = 'NY';
        accountList[0].ShippingPostalCode = '12345';
        accountList[0].Website = 'www.vhf.com';
        accountList[0].Phone = '4534445344';
        accountList[0].AccountStatus__c = 'Customer';
        update accountList[0];

        Opportunity slyopp =    TestDataSetupUtility.createTestOpportunity('nowoppsly', accountList[0].id);
        slyopp.OrderCreated__c = false;
        slyopp.Organization__c = 'North America';
        system.debug('before test acc insert');
        insert slyopp;
        
        Payment_Details__c pdetail = new Payment_Details__c(Organization__c='North America',PaymentMethod__c='Invoice',PaymentFrequency__c='Single Payment',PaymentTerm__c='30 days + EOM',CurrencyIsoCode='USD',Name='Test',Active__c=true);
        insert pdetail;

        //system.debug('testOrderSellingCountry opp' + slyopp);

        //Contact slycon =        TestDataSetupUtility.createTestContact(slyopp.AccountId, 'slyFirst', 'slyLast', 'slycontact@email.com');
        //insert slycon;
        //system.debug('testOrderSellingCountry contact ' + slycon);

        Apttus_Proposal__Proposal__c slyproposal = TestDataSetupUtility.createProposal( accountList[0].id, slyopp.id, 'North America');
        slyproposal.Payment1_Frequency__c = 'Single Payment';
        slyproposal.Payment_Method1__c = 'Invoice';
        slyproposal.Payment1_Term__c = '30 days + EOM';
        insert slyproposal;
        
        system.debug('testOrderSellingCountry proposal' + slyproposal);

        Apttus_Proposal__Proposal_Line_Item__c slyPLI = TestDataSetupUtility.createProposalLineItem(slyproposal.id);
        insert slyPLI;
        system.debug('testOrderSellingCountry proposalLI' + slyPLI);

        Test.startTest();

        slyopp.OrderCreated__c=true;
        slyopp.Stagename = 'Stage 4 - Won';

        OpportunityTriggerHandler.RunCount = 0;
        BaseTriggerHandler.SkipOppUpdateToPreventRecursion =false;

        update slyopp;
        system.debug('testOrderSellingCountry opp' + slyopp);

        List<Order__c>slyorder = [select id from Order__c where Opportunity__c=:slyopp.id];
        List<Order_Line_Item__c>slyorderLI = [select id, startDate__c, endDate__c from Order_Line_Item__c where Order__c=:slyorder[0].id ];
        system.assertEquals(slyorderLI.size(),1 );

        slyorderLI[0].startDate__c =Date.newInstance(2015, 2, 17);
        slyorderLI[0].endDate__c = Date.newInstance(2016, 2, 17);
        update slyorderLI;
        system.debug('vvv orginalLIDATES start' +slyorderLI[0].startDate__c+ 'end '+slyorderLI[0].endDate__c);

        Payment_Details__c pd = [select id,Organization__c,PaymentFrequency__c,PaymentMethod__c,PaymentTerm__c,Name from Payment_Details__c limit 1];

        pd.Name = 'Leave Blank';
        pd.Organization__c = 'North America';
        pd.PaymentFrequency__c = 'Single Payment';
        pd.PaymentMethod__c = 'Credit';
        pd.PaymentTerm__c = 'Immediate';
        upsert  pd;

        Credit_Request__c slycr = new Credit_Request__c();
        slycr.RequestDate__c = system.now().date();
        slycr.Type__c = 'Inventory';
        slycr.CreditReason__c = 'Tax Error';
        //slycr.ApprovalStatus__c = 'Approved';
        slycr.ApprovalStatus__c = 'Not Submitted';
        slycr.CreditScenario__c = 'Credit';
        slycr.Order__c = slyorder[0].id;
        slycr.PrimarySalesRep__c = UserInfo.getUserId();
        insert slycr;

        CreditRequestLineItem__c slycrLI = new CreditRequestLineItem__c();
        slycrLI.Credit_Request__c = slycr.id;
        slycrLI.Order_Line_Item__c = slyorderLI[0].id;
        slycrLI.TaxAmount__c = 10;
        slycrLI.AvailableCreditAmount__c = 10;
        slycrLI.CreditAmount__c = 10;
        slycrLI.NetCreditAmount__c = 10;
        slycrLI.NetRemainingCreditAmount__c = 10;
        slycrLI.NetTotalAmount__c = 10;
        slycrLI.VATNationalTaxAmount__c = 10;
        slycrLI.Unit_Price__c = 10;
        insert slycrLI;

        system.debug('creditrequest1 ' + slycr);
        slycr.ApprovalStatus__c = 'Approved';
        update slycr;

        system.debug('creditrequest2 ' + slycr);

        Test.stopTest();
        List<Order__c>results = [select id, Selling_Country__c, Quote_Selling_Country__c, ParentOrder__c, ParentOrder__r.Quote_Selling_Country__c from Order__c where CreditRequest__c=:slycr.id];
        system.debug('testresults '+results);
        system.assert(results.size() > 0);
        system.assertEquals(results[0].Selling_Country__c,results[0].ParentOrder__r.Quote_Selling_Country__c);
    }

    @isTest
    static void testPopulateSalesRep() {

        prepareData();
        personalSettings.Trigger_Order__c = true;
        update personalSettings;

        OrderTriggerHandler.ExecuteTriggers = true;
        OrderTriggerHandler.executeUpdateTrigger = false;

        User integrationUser = TestDataSetupUtility.createUser('System Administrator',false);
        integrationUser.FirstName= 'Integration';
        integrationUser.LastName = 'MAPP';
        integrationUser.Network_Domain_Login__c = '123';
        insert integrationUser;

        System.runAs(integrationUser) {

            Account acc = TestDataSetupUtility.createTestAccount('Test Account', 'North America', UserInfo.getUserId());
            acc.Partner_Flag__c = true;
            acc.AgencyFlag__c = true;
            acc.Organization__c = 'TestOrg';
            acc.Suppress_Invoice_Detail__c = null;

            Account acc2 = TestDataSetupUtility.createTestAccount('Testing Account2', 'Europe', UserInfo.getUserId());
            acc2.Phone = '6543876598';
            acc.Organization__c = 'TestOrg';
            insert new List<Account>{acc,acc2};
                Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Oppty' , acc.id);
            insert opp;


            RelatedPartner__c partner = new RelatedPartner__c();
            partner.Account__c = acc2.id;
            partner.Partner__c = acc.Id;
            partner.AgencyType__c = 'Billing';
            partner.role__c = 'Agency';
            insert partner;
            Account acc1 = TestDataSetupUtility.createTestAccount('Test 123 Account', 'Asia Pacific', UserInfo.getUserId());
            acc1.Phone = '1234567891';
            acc1.ShippingStreet = 'Red S';
            acc1.ShippingCity = 'NY';
            acc1.ShippingPostalCode = '12345';
            acc1.Website = 'www.abc1.com';
            acc1.Phone = '4534445344';
            acc1.AccountStatus__c = 'Customer';
            acc1.PrimaryRelatedAgency__c = partner.Id;
            insert acc1;
            Partner_Revenue_Share__c  partnerRS = new Partner_Revenue_Share__c ();
            partnerRS.Partner__c = acc1.Id;
            partnerRS.SiteChannelID__c = '123234';
            partnerRS.MB_Live_Channel_Flag__c = true;
            partnerRS.MB_Sales_Rep_Login__c = '123';
            insert partnerRS;
            
            
            Contact con1 = TestDataSetupUtility.createTestContact(acc1.id,'test','Con','aon122@gmail.com');
            insert con1;


            Test.startTest();


            List<Order__c> orderList = new List<Order__c>();
            Order__c ord = TestDataSetupUtility.createOrder(acc.Id, con1.Id);
            ord.OrderStatus__c = 'Open';
            ord.SiteChannelID__c = '123234';
            insert ord;

            Order__c ord1 = TestDataSetupUtility.createOrder(acc.Id, con1.Id);
            ord1.OrderStatus__c = 'Open';
            ord1.SiteChannelID__c = '';
            insert ord1;

            /*Code added by Deepanshu for populateSalesRepsFields()*/
            ord.Opportunity__c=opp.Id;
            update ord;
            ord1.Opportunity__c=opp.Id;
            update ord1;

            Test.StopTest();

        }

    }

    ///11-01-2017 Mitali Nahar Shadowed under Vikas Menon

    static testMethod void testOrdertest(){

        Account acc = TestDataSetupUtility.createTestAccount('Test Account', 'North America', UserInfo.getUserId());
        acc.Partner_Flag__c = true;
        acc.AgencyFlag__c = true;
        acc.Suppress_Invoice_Detail__c = null;

        Account acc2 = TestDataSetupUtility.createTestAccount('Testing Account2', 'Europe', UserInfo.getUserId());
        acc2.Phone = '6543876598';
        //acc2.PrimaryRelatedAgency__c = partner.Id;
        //insert acc2;
        insert new List<Account>{acc,acc2};
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Oppty' , acc.id);
        insert opp;




        prepareData();
        RelatedPartner__c partner = new RelatedPartner__c();
        partner.Account__c = acc2.id;
        partner.Partner__c = acc.Id;
        partner.AgencyType__c = 'Billing';
        partner.role__c = 'Agency';

        insert partner;
        Account acc1 = TestDataSetupUtility.createTestAccount('Test 123 Account', 'Asia Pacific', UserInfo.getUserId());
        acc1.Phone = '1234567891';
        acc1.ShippingStreet = 'Red S';
        acc1.ShippingCity = 'NY';
        acc1.ShippingPostalCode = '12345';
        acc1.Website = 'www.abc1.com';
        acc1.Phone = '4534445344';
        acc1.AccountStatus__c = 'Customer';
        acc1.PrimaryRelatedAgency__c = partner.Id;
        acc1.Partner_Flag__c = true;
        insert acc1;
        Partner_Revenue_Share__c  partnerRS = new Partner_Revenue_Share__c ();
        partnerRS.Partner__c = acc1.Id;
        partnerRS.SiteChannelID__c = '123234';
        //insert partnerRS;
        Contact con1 = TestDataSetupUtility.createTestContact(acc1.id,'test','Con','aon122@gmail.com');
        Contact con2 = TestDataSetupUtility.createTestContact(acc.id,'test1','Con','aon122@gmail.com');
        insert  new List<Contact>{con2,con1};
            User integrationUser = TestDataSetupUtility.createUser('System Administrator',false);
        integrationUser.FirstName= 'Integration';
        integrationUser.LastName = 'MAPP';
        insert integrationUser;
        acc1.OwnerId = integrationUser.Id;
        update acc1;

        Apttus_Proposal__Proposal__c proposal1 = TestDataSetupUtility.createProposal( acc.id, opp.id, 'COMPANY1');
        insert proposal1;
        OrderTriggerHandler.ExecuteTriggers = true;
        OrderTriggerHandler.executeUpdateTrigger = true;

        List<Order__c> orderList = new List<Order__c>();
        Order__c ord = TestDataSetupUtility.createOrder(acc1.Id, con1.Id);
        ord.OrderStatus__c = 'Open';
        ord.QuoteProposal__c = proposal1.id;
        ord.AccountOrganization__c = 'North America';
        ord.opportunity__c = opp.id;
        ord.CR_Status_Comment__c = 'testing Comments';
        ord.Approval_Status__c = 'Re-Open';
        ord.ShippingContact__c = con1.Id;
        ord.BillingAccount__c = acc1.id;
        ord.Agency__c = acc.Id;
        ord.Account__c = acc1.Id;
        ord.MAPP_Payment_Frequency__c = 'Invoice';
        ord.MAPPBillingAccount__c  = acc1.Id;
        ord.MAPPBillingContact__c =con1.Id;
        ord.MAPP_Archive_Posting_Contact__c = con1.Id;
        ord.MAPP_Archive_Posting_Customer_PO__c = 'PO';
        ord.OrderStatus__c = 'Verified';
        ord.PrimarySalesRep__c = UserInfo.getUserId();
        ord.SiteChannelID__c = '123234';
        orderList.add(ord);
        orderList.add(TestDataSetupUtility.createOrder(acc1.Id, con1.Id));
        orderList.add(TestDataSetupUtility.createOrder(acc.Id, con1.Id));

        orderList[2].QuoteProposal__c = proposal1.id;
        orderList[1].QuoteProposal__c = proposal1.id;



        orderList[2].RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Credit');
        insert orderList;
        Apttus_Proposal__Proposal__c proposal = TestDataSetupUtility.createProposal( acc.id, opp.id, 'COMPANY');
        insert proposal;
        //Turn off a couple of our triggers using personal settings:
        //this is to reduce # of SOQL errors during test class run
        personalSettings.Trigger_Order__c = true;
        personalSettings.Trigger_Account__c = false;
        personalSettings.Trigger_Contact__c = false;
        personalSettings.Trigger_Opportunity__c = false;
        personalSettings.Trigger_Case__c = false;
        personalSettings.Trigger_Quote__c = false;
        personalSettings.Validation_Account__c = true;
        personalSettings.Validation_Opportunity__c = true;
        update personalSettings;


        System.runAs(integrationUser){
            Test.startTest();
            //orderList[2].Account__c = acc1.Id;
            orderList[2].MAPPPrimarySalesRep__c = integrationUser.Id;

            orderList[0].Agency__c = acc1.Id;
            orderList[1].QuoteProposal__c = null;
            orderList[0].QuoteProposal__c = null;
            orderList[2].QuoteProposal__c = null;

            try{
                update orderList;

            }catch(BaseApplicationException e){}
            catch(DmlException e){}
            catch(Exception e){}
            Test.StopTest();
        }

    }

    @isTest
    static  void testOtest() {
        Account acc = TestDataSetupUtility.createTestAccount('Test Account', 'North America', UserInfo.getUserId());
        acc.Partner_Flag__c = true;
        acc.AgencyFlag__c = true;
        acc.Suppress_Invoice_Detail__c = null;

        Account acc2 = TestDataSetupUtility.createTestAccount('Testing Account2', 'Europe', UserInfo.getUserId());
        acc2.Phone = '6543876598';
        //acc2.PrimaryRelatedAgency__c = partner.Id;
        //insert acc2;
        insert new List<Account>{acc,acc2};
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Oppty' , acc.id);
        insert opp;




        prepareData();
        RelatedPartner__c partner = new RelatedPartner__c();
        partner.Account__c = acc2.id;
        partner.Partner__c = acc.Id;
        partner.AgencyType__c = 'Billing';
        partner.role__c = 'Agency';

        insert partner;
        Account acc1 = TestDataSetupUtility.createTestAccount('Test 123 Account', 'Asia Pacific', UserInfo.getUserId());
        acc1.Phone = '1234567891';
        acc1.ShippingStreet = 'Red S';
        acc1.ShippingCity = 'NY';
        acc1.ShippingPostalCode = '12345';
        acc1.Website = 'www.abc1.com';
        acc1.Phone = '4534445344';
        acc1.AccountStatus__c = 'Customer';
        acc1.PrimaryRelatedAgency__c = partner.Id;
        acc1.Partner_Flag__c = true;
        insert acc1;
        Partner_Revenue_Share__c  partnerRS = new Partner_Revenue_Share__c ();
        partnerRS.Partner__c = acc1.Id;
        partnerRS.SiteChannelID__c = '123234';
        //insert partnerRS;
        Contact con1 = TestDataSetupUtility.createTestContact(acc1.id,'test','Con','aon122@gmail.com');
        Contact con2 = TestDataSetupUtility.createTestContact(acc.id,'test1','Con','aon122@gmail.com');
        insert  new List<Contact>{con2,con1};
            User integrationUser = TestDataSetupUtility.createUser('System Administrator',false);
        integrationUser.FirstName= 'Integration';
        integrationUser.LastName = 'MAPP';
        insert integrationUser;
        acc1.OwnerId = integrationUser.Id;
        update acc1;

        Apttus_Proposal__Proposal__c proposal1 = TestDataSetupUtility.createProposal( acc.id, opp.id, 'COMPANY1');
        insert proposal1;
        OrderTriggerHandler.ExecuteTriggers = true;
        OrderTriggerHandler.executeUpdateTrigger = true;

        List<Order__c> orderList = new List<Order__c>();
        Order__c ord = TestDataSetupUtility.createOrder(acc1.Id, con1.Id);
        ord.OrderStatus__c = 'Open';
        ord.QuoteProposal__c = proposal1.id;
        ord.AccountOrganization__c = 'North America';
        ord.opportunity__c = opp.id;
        ord.CR_Status_Comment__c = 'testing Comments';
        ord.Approval_Status__c = 'Re-Open';
        ord.ShippingContact__c = con1.Id;
        ord.BillingAccount__c = acc1.id;
        ord.Agency__c = acc.Id;
        ord.Account__c = acc1.Id;
        ord.MAPP_Payment_Frequency__c = 'Invoice';
        ord.MAPPBillingAccount__c  = acc1.Id;
        ord.MAPPBillingContact__c =con1.Id;
        ord.MAPP_Archive_Posting_Contact__c = con1.Id;
        ord.MAPP_Archive_Posting_Customer_PO__c = 'PO';
        ord.OrderStatus__c = 'Verified';
        ord.PrimarySalesRep__c = UserInfo.getUserId();
        ord.SiteChannelID__c = '123234';
        orderList.add(ord);
        orderList.add(TestDataSetupUtility.createOrder(acc1.Id, con1.Id));
        orderList.add(TestDataSetupUtility.createOrder(acc.Id, con1.Id));

        orderList[2].QuoteProposal__c = proposal1.id;
        orderList[1].QuoteProposal__c = proposal1.id;



        orderList[2].RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Credit');
        insert orderList;
        Apttus_Proposal__Proposal__c proposal = TestDataSetupUtility.createProposal( acc.id, opp.id, 'COMPANY');
        insert proposal;
        //Turn off a couple of our triggers using personal settings:
        //this is to reduce # of SOQL errors during test class run
        personalSettings.Trigger_Order__c = true;
        personalSettings.Trigger_Account__c = false;
        personalSettings.Trigger_Contact__c = false;
        personalSettings.Trigger_Opportunity__c = false;
        personalSettings.Trigger_Case__c = false;
        personalSettings.Trigger_Quote__c = false;
        personalSettings.Validation_Account__c = true;
        personalSettings.Validation_Opportunity__c = true;
        update personalSettings;


        System.runAs(integrationUser){
            Test.startTest();
            //orderList[2].Account__c = acc1.Id;
            orderList[2].MAPPPrimarySalesRep__c = integrationUser.Id;

            orderList[0].Agency__c = acc1.Id;
            orderList[1].QuoteProposal__c = null;
            orderList[0].QuoteProposal__c = null;
            orderList[2].QuoteProposal__c = null;
            Apttus_Proposal__Proposal_Line_Item__c slyPLI = TestDataSetupUtility.createProposalLineItem(proposal.id);
            insert slyPLI;
            Order_Line_Item__c oitem = TestDataSetupUtility.createOrderLineItem(orderList[0].Id);
            oitem.NetTotalAmount__c = 10;
            oitem.ProposalLineItem__c = slyPLI.id;
            insert oitem;
            OrderTriggerHelper helper = OrderTriggerHelper.NewTriggerHelper();
            try{
                update orderList;
                helper.AssignOrderFromMAPP(orderList);
                helper.AssignOrderTeamMembersFromMAPP(orderList);
            }catch(BaseApplicationException e){}
            catch(DmlException e){}
            catch(Exception e){}
            Test.StopTest();
        }

    }


    static testmethod void testcredittest(){

        prepareData();

        List<Order__c> orderList = new List<Order__c>();
        Order__c ord = TestDataSetupUtility.createOrderWithOpportunity(accountList[0].Id, oppList[0].Id, null, con.Id);
        ord.BillingAccount__c = accountList[0].id;
        ord.Entity_ID__c = null;
        ord.RecordTypeId =  Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Ecomm');
        ord.PrimarySalesRep__c = UserInfo.getUserId();
        orderList.add(ord);
        insert orderList;

        prod = TestDataSetupUtility.createProduct('Test Product 1',false);
        prod.ProductCode = 'M20194XJOB';
        insert prod;

        List<Order_Line_Item__c> OLIList = new List<Order_Line_Item__c>();
        Order_Line_Item__c oli = TestDataSetupUtility.createOrderLineItem(ord.Id);
        oli.Product__c = prod.Id;
        insert oli;

        Order_Line_Item__c item = [SELECT Id,Name,order__c FROM Order_Line_Item__c WHERE Id=: oli.id];

        system.debug('******item ****' +item );

        LicenseID__c licenseId = new LicenseID__c();
        licenseId.OrderLineItem__c = oli.id;
        //licenseId.SiteLicenseID__c = 'Test';
        insert licenseId ;

        Set<Id> ordIds = new Set<Id>();
        for(Order__c o : orderList){
            ordIds.add(o.Id);
        }
        personalSettings.Trigger_Order__c = true;
        update personalSettings;
        List<Order__c> orderForUpdate = [Select OrderStatus__c,Posting_Contact__c from Order__c where Id in : ordIds];
        for(Order__c o : orderForUpdate){
            o.OrderStatus__c = 'Paid in full';
            o.Posting_Contact__c = con.id;
            o.BillingContact__c= con.id;

        }

        Test.startTest();
        update orderForUpdate;
        Test.stopTest();

    }

    /**
* @author Deepanshu Soni (APPIRIO)
* @date 17-feb-2017
*/
    @isTest
    static  void testspopulatepayGoOrders() {
         List<Order__c> orderList = new List<Order__c>();
        prepareData();
        personalSettings.Trigger_Order__c = true;
        update personalSettings;

        Xcode__c xcode = new Xcode__c();
        xcode.name = 'xpaygoTest';
        insert xcode ;
        XcodeAccount__c xAcc = new XcodeAccount__c ();
        xAcc.Xcode__c = xcode.Id;
        xAcc.Account__c = accountList[0] .Id;
        insert xAcc;

        Xcode__c xcode1 = new Xcode__c();
        xcode1.name = 'Test';
        insert xcode1 ;
        XcodeAccount__c xAcc1 = new XcodeAccount__c ();
        xAcc1.Xcode__c = xcode1.Id;
        xAcc1.Account__c = accountList[0] .Id;
        insert xAcc1;

        //Create price list
        Apttus_Config2__PriceList__c price = TestDataSetupUtility.createPriceList('USD Price List', false);
        insert price;

            //Added
            Partner_Revenue_Share__c  partnerRS1 = new Partner_Revenue_Share__c ();
            partnerRS1.Partner__c = accountList[0].Id;
            partnerRS1.SiteChannelID__c = '123234';
            partnerRS1.MB_Live_Channel_Flag__c = false;
            partnerRS1.MB_Sales_Rep_Login__c = '123';
            insert partnerRS1;


        //Case when channel is 58 and scode starts with xpaygo
        Order__c ord1 = TestDataSetupUtility.createOrder(accountList[0].Id, con.Id);
        ord1.OrderStatus__c = 'Open';
        ord1.Organization__c = 'North America';
        ord1.Payment_Term_text__c =  'Net 10';
        ord1.Payment_Frequency__c = 'Monthly';
        ord1.Payment_Method_text__c =  'Invoice';
        ord1.AccountOrganization__c = 'North America';
        ord1.Organization__c = 'North America';
        ord1.Approval_Status__c = 'Re-Open';
        ord1.MAPP_Price_List__c = price.Name;
        ord1.MAPPPrimarySalesRep__c = Userinfo.getUserName();
        ord1.Account__c = accountList[0].Id;
        ord1.BillingAccount__c = accountList[0].id;
        //ord1.Entity_ID__c = null;
        ord1.SiteChannelID__c = '58';
        ord1.Xcode__c=xcode.Id;
        ord1.MAPP_Payment_Frequency__c = 'Paypal';
        ord1.CreditCardTransactionResponseCode__c = '1234';
         orderList.add(ord1);
        
     
       
        //to test when xcode is Not Like 'xnppaygo%'
        Order__c ord2 = TestDataSetupUtility.createOrder(accountList[0].Id, con.Id);
        ord2.OrderStatus__c = 'Open';
        ord2.Organization__c = 'North America';
        ord2.Payment_Term_text__c =  'Net 10';
        ord2.Payment_Frequency__c = 'Monthly';
        ord2.Payment_Method_text__c =  'Invoice';
        ord2.AccountOrganization__c = 'North America';
        ord2.Organization__c = 'North America';
        ord2.Approval_Status__c = 'Re-Open';
        ord2.MAPP_Price_List__c = price.Name;
        ord2.MAPPPrimarySalesRep__c = Userinfo.getUserName();
        ord2.Account__c = accountList[0].Id;
        ord2.BillingAccount__c = accountList[0].id;
        //ord2.Entity_ID__c = null;
        ord2.SiteChannelID__c = '58';
        ord2.Xcode__c=xcode1.Id;
        ord2.MAPP_Payment_Frequency__c = 'Pre-Paid';
        ord2.CreditCardTransactionResponseCode__c = '1234';
         orderList.add(ord2);

        //to test when sales channel is 58 and payment frequency is not pre-paid
        Order__c ord3 = TestDataSetupUtility.createOrder(accountList[0].Id, con.Id);
        ord3.OrderStatus__c = 'Open';
        ord3.Organization__c = 'North America';
        ord3.Payment_Term_text__c =  'Net 10';
        ord3.Payment_Frequency__c = 'Monthly';
        ord3.Payment_Method_text__c =  'Invoice';
        ord3.AccountOrganization__c = 'North America';
        ord3.Organization__c = 'North America';
        ord3.Approval_Status__c = 'Re-Open';
        ord3.MAPP_Price_List__c = price.Name;
        ord3.MAPPPrimarySalesRep__c = Userinfo.getUserName();
        ord3.Account__c = accountList[0].Id;
        ord3.BillingAccount__c = accountList[0].id;
        //ord3.Entity_ID__c = null;
        ord3.SiteChannelID__c = '58';
        ord3.Xcode__c=xcode1.Id;
        ord3.MAPP_Payment_Frequency__c = 'Paypal';
        ord3.CreditCardTransactionResponseCode__c = '1234';
         orderList.add(ord3);

        // to test when sales channel is 13/14 and payment frequency is pre-paid
        Order__c ord4 = TestDataSetupUtility.createOrder(accountList[0].Id, con.Id);
        ord4.OrderStatus__c = 'Open';
        ord4.Organization__c = 'United States';
        ord4.Payment_Term_text__c =  'Net 10';
        ord4.Payment_Frequency__c = 'Monthly';
        ord4.Payment_Method_text__c =  'Invoice';
        ord4.AccountOrganization__c = 'North America';
        ord4.Organization__c = 'North America';
        ord4.Approval_Status__c = 'Re-Open';
        ord4.MAPP_Price_List__c = price.Name;
        ord4.MAPPPrimarySalesRep__c = Userinfo.getUserName();
        ord4.Account__c = accountList[0].Id;
        ord4.BillingAccount__c = accountList[0].id;
        //ord4.Entity_ID__c = null;
        ord4.SiteChannelID__c = '13';
        ord4.salesChannel__c = 'Partner';
        ord4.Xcode__c=xcode1.Id;
        ord4.MAPP_Payment_Frequency__c = 'Pre-Paid';
        ord4.CreditCardTransactionResponseCode__c = '1234';
         orderList.add(ord4);

        //testing when sales channel is 13/14 and payment frequency is not credit card
        Order__c ord5 = TestDataSetupUtility.createOrder(accountList[0].Id, con.Id);
        ord5.OrderStatus__c = 'Open';
        ord5.Organization__c = 'United States';
        ord5.Payment_Term_text__c =  'Net 10';
        ord5.Payment_Frequency__c = 'Monthly';
        ord5.Payment_Method_text__c =  'Invoice';
        ord5.AccountOrganization__c = 'North America';
        ord5.Organization__c = 'North America';
        ord5.Approval_Status__c = 'Re-Open';
        ord5.MAPP_Price_List__c = price.Name;
        ord5.MAPPPrimarySalesRep__c = Userinfo.getUserName();
        ord5.Account__c = accountList[0].Id;
        ord5.BillingAccount__c = accountList[0].id;
        //ord5.Entity_ID__c = null;
        ord5.SiteChannelID__c = '13';
        ord5.salesChannel__c = 'Partner';
        ord5.Xcode__c=xcode1.Id;
        ord5.MAPP_Payment_Frequency__c = 'Paypal';
        ord5.CreditCardTransactionResponseCode__c = '1234';
         orderList.add(ord5);


  Account testAcc = TestDataSetupUtility.createTestAccount('Test Account', 'North America', UserInfo.getUserId());
       testAcc.shippingCOuntry='United States';
       testAcc.shippingstate = 'California';
       insert testAcc; 
        
        
        
         Order__c ord6 = TestDataSetupUtility.createOrder(accountList[0].Id, con.Id);
        ord6.OrderStatus__c = 'Open';
        ord6.Organization__c = 'United States';
        ord6.Payment_Term_text__c =  'Net 10';
        ord6.Payment_Frequency__c = 'Monthly';
        ord6.Payment_Method_text__c =  'Invoice';
        ord6.AccountOrganization__c = 'North America';
        ord6.Organization__c = 'North America';
        ord6.Approval_Status__c = 'Re-Open';
        ord6.MAPP_Price_List__c = price.Name;
        ord6.MAPPPrimarySalesRep__c = Userinfo.getUserName();
        ord6.Account__c = testAcc.Id;
        ord6.BillingAccount__c = testAcc.id;
        //ord6.Entity_ID__c = null;
        ord6.SiteChannelID__c = '58';
        ord6.salesChannel__c = 'Partner';
        ord6.Xcode__c=xcode1.Id;
        ord6.MAPP_Payment_Frequency__c = 'Pre-Paid';
        ord6.CreditCardTransactionResponseCode__c = '1234';
        // orderList.add(ord6);

        Test.startTest();
       // insert ord1;
        //insert ord2;
        //insert ord3;
        //insert ord4;
        //insert ord5;


        //accountList[0].shippingCOuntry = 'United States';
        //update accountList[0];
        //system.assert(false,'Result '+accountList[0].shippingCOuntry);
       //insert ord6;
       //List<Order__C> ordx = [Select Mapp_Payment_Frequency__c,SiteChannelID__c,PostingCountry__c from Order__c where PostingCountry__c = 'United States']  ;
        //system.assert(false,'Order List '+ ordx);
       // orderList.add(ord1);
        // orderList.add(ord2);
         // orderList.add(ord3);
       //  orderList.add(ord4);
         // orderList.add(ord5);
         // orderList.add(ord6);
        insert orderList;

        Order_Line_Item__c oli = TestDataSetupUtility.createOrderLineItem(orderList.get(0).Id);
        oli.AdjustedPrice__c = 5;
        oli.Quantity2__c = 3;
        oli.startDate__c = date.Today();
        oli.EndDate__C = date.Today();
        insert oli;

        List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
        oliList.add(oli);
       // oliList.add(oli1);

        
        // orderList.add(ord6);


        OrderTriggerHelper helper = OrderTriggerHelper.NewTriggerHelper();
        helper.ordersList = orderList;
        helper.populatepayGoOrders(orderList);
        Test.stopTest();


    }
    
    
    
    @isTest
    static  void testspopulatepayGoOrders1() {
         List<Order__c> orderList = new List<Order__c>();
        prepareData();
        personalSettings.Trigger_Order__c = true;
        update personalSettings;

        Xcode__c xcode = new Xcode__c();
        xcode.name = 'xpaygoTest';
        insert xcode ;
        XcodeAccount__c xAcc = new XcodeAccount__c ();
        xAcc.Xcode__c = xcode.Id;
        xAcc.Account__c = accountList[0] .Id;
        insert xAcc;

        Xcode__c xcode1 = new Xcode__c();
        xcode1.name = 'Test';
        insert xcode1 ;
        XcodeAccount__c xAcc1 = new XcodeAccount__c ();
        xAcc1.Xcode__c = xcode1.Id;
        xAcc1.Account__c = accountList[0] .Id;
        insert xAcc1;

        //Create price list
        Apttus_Config2__PriceList__c price = TestDataSetupUtility.createPriceList('USD Price List', false);
        insert price;

            //Added
            Partner_Revenue_Share__c  partnerRS1 = new Partner_Revenue_Share__c ();
            partnerRS1.Partner__c = accountList[0].Id;
            partnerRS1.SiteChannelID__c = '5812';
            partnerRS1.MB_Live_Channel_Flag__c = True;
            partnerRS1.MB_Sales_Rep_Login__c = '123';
            insert partnerRS1;


       

  Account testAcc = TestDataSetupUtility.createTestAccount('Test Account', 'North America', UserInfo.getUserId());
       testAcc.shippingCOuntry='United States';
       testAcc.shippingstate = 'California';
       insert testAcc; 
        
        
        Order__c ord5 = TestDataSetupUtility.createOrder(accountList[0].Id, con.Id);
        ord5.OrderStatus__c = 'Open';
        ord5.Organization__c = 'United States';
        ord5.Payment_Term_text__c =  'Net 10';
        ord5.Payment_Frequency__c = 'Monthly';
        ord5.Payment_Method_text__c =  'Invoice';
        ord5.AccountOrganization__c = 'North America';
        ord5.Organization__c = 'North America';
        ord5.Approval_Status__c = 'Re-Open';
        ord5.MAPP_Price_List__c = price.Name;
        ord5.MAPPPrimarySalesRep__c = Userinfo.getUserName();
        ord5.Account__c = testAcc.Id;
        ord5.BillingAccount__c = testAcc.id;
        //ord5.Entity_ID__c = null;
        ord5.SiteChannelID__c = '58';
        ord5.salesChannel__c = 'Partner';
        ord5.Xcode__c=xcode1.Id;
        ord5.MAPP_Payment_Frequency__c = 'Pre-Paid';
        ord5.CreditCardTransactionResponseCode__c = '1234';
         orderList.add(ord5);
        
         Order__c ord6 = TestDataSetupUtility.createOrder(accountList[0].Id, con.Id);
        ord6.OrderStatus__c = 'Open';
        ord6.Organization__c = 'United States';
        ord6.Payment_Term_text__c =  'Net 10';
        ord6.Payment_Frequency__c = 'Monthly';
        ord6.Payment_Method_text__c =  'Invoice';
        ord6.AccountOrganization__c = 'North America';
        ord6.Organization__c = 'North America';
        ord6.Approval_Status__c = 'Re-Open';
        ord6.MAPP_Price_List__c = price.Name;
        ord6.MAPPPrimarySalesRep__c = Userinfo.getUserName();
        ord6.Account__c = accountList[0].Id;
        ord6.BillingAccount__c = accountList[0].id;
        //ord6.Entity_ID__c = null;
        ord6.SiteChannelID__c = '5812';
        ord6.salesChannel__c = 'Partner';
        ord6.Xcode__c=xcode1.Id;
        ord6.MAPP_Payment_Frequency__c = 'Pre-Paid';
        ord6.CreditCardTransactionResponseCode__c = '1234';
         orderList.add(ord6);

        Test.startTest();
      
        insert orderList;

        Order_Line_Item__c oli = TestDataSetupUtility.createOrderLineItem(orderList.get(0).Id);
        oli.AdjustedPrice__c = 5;
        oli.Quantity2__c = 3;
        oli.startDate__c = date.Today();
        oli.EndDate__C = date.Today();
        insert oli;

        List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
        oliList.add(oli);
       // oliList.add(oli1);

        
        // orderList.add(ord6);


        OrderTriggerHelper helper = OrderTriggerHelper.NewTriggerHelper();
        helper.ordersList = orderList;
        helper.populatepayGoOrders(orderList);
        Test.stopTest();


    }


}