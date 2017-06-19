@isTest
private class ExpireInventoryCCTest {
    public static final String PROFILE_SYS_ADMIN = 'System Administrator';
    static Order__c pOrder;
    static Order_Line_Item__c orderLine1,orderLine2,orderLine3;
    static testMethod void testExpireInventory(){
        User sysAdmin;
        sysAdmin = createUser(PROFILE_SYS_ADMIN, true);
        System.runAs(sysAdmin){
            createData();
            Pagereference pg = Page.ExpireInventory;
            pg.getParameters().put('Id',pOrder.Id);
            pg.getParameters().put('radioSelectValue',  orderLine1.Id);
            Test.setCurrentPage(pg);
            Test.startTest();
                ExpireInventoryCC controller = new ExpireInventoryCC();
                List<SelectOption> options = controller.actionList;
                System.assert(options != null , 'Select has options');
                controller.displayStr(null);
                controller.displayStr('Test');
                controller.displayInt(null);
                controller.displayInt(12.23);
                controller.displayDec(null);
                controller.displayDec(12.22);
                controller.displayDt(null);
                controller.displayDt(Date.today());
                controller.displayCurr('INR', null);
                controller.displayCurr('INR', 12.23);
                PageReference pg1 = controller.selectQuoteId(); 
                System.assert(pg1 == null);
                PageReference pg2 = controller.onClickNext();
                System.assert(pg2.getUrl().contains(pOrder.Id));
                PageReference pg3 = controller.onClickCancel();
                System.assert(pg3.getUrl().contains(pOrder.Id));
                String str1 = controller.selectedAction;
                String str2 = controller.selectedProposalId;
            Test.stopTest();
        }
    }
    
    static void createData(){
        Account acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TESTACCCCH1 ');
        acc.ShippingCountryCode = 'IN';
        acc.ShippingCountry = 'India';
        acc.ShippingState = '';
        Account acc1 = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TESTACCCCH ');
        insert (new List<Account>{acc,acc1});
        Contact con = TestDataSetupUtility.createTestContact(acc.Id, 'confirst1', 'conlast1', 'con1@email.com');
        insert con;
        pOrder = TestDataSetupUtility.createOrder(acc.Id, con.Id);
        
        pOrder.Organization__c = 'North America';
        pOrder.Pricing_Channel__c = 'Agency';
        
        insert (pOrder);
        orderLine1 = TestDataSetupUtility.createOrderLineItem(pOrder.id);
        orderLine2 = TestDataSetupUtility.createOrderLineItem(pOrder.id);
        orderLine3 = TestDataSetupUtility.createOrderLineItem(pOrder.id);
        insert (new List<Order_Line_Item__c>{orderLine1,orderLine2,orderLine3}); 
    }
    
    private static User createUser(String profileName, Boolean isInsert){
        User testUser = new User();
        Profile p;
        List<Profile> listProfile = [SELECT Id from Profile where Name = :profileName];
        if(listProfile.size() > 0) {
            p = listProfile[0];
        } else {
            return null;
        }
        testUser = new User(alias = 'AdmUsr', email='standarduser' + Math.random()  + '@testorg.com',
                                    emailencodingkey='UTF-8',  lastname='Test', languagelocalekey='en_US',
                                    localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', 
                                    username='teststandarduser' + Math.random() + '@testorg.com', IsActive=true,
                                    CompanyName = 'test Company');
        if(isInsert){
            insert testUser;
        }
        return testUser;
    }
}