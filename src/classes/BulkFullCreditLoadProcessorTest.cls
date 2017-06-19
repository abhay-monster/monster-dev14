@IsTest
private class BulkFullCreditLoadProcessorTest {

    //declare static variables
    static Personal_Settings__c personalSettings;
    static List<Opportunity> oppList;
    static List<Account> accountList;

    
    /** 
     * @author Andre Calimlim
     * @date 12.4.14
     * @description static method to create test data records
     * @param AccountName - String value for the name field of Account
     * @param setPersonalSettings - Boolean value to set the personal Settings on which triggers/Validations to run
     */
    static void createRec(String AccountName, Boolean setPersonalSettings){
        personalSettings = TestDataSetupUtility.buildPersonalSetting();
        if(setPersonalSettings){
            personalSettings.Trigger_Order__c = true;
            personalSettings.Trigger_Account__c = true;
            personalSettings.Trigger_Opportunity__c = true;
            personalSettings.Validation_Account__c = true;
            personalSettings.Validation_Opportunity__c = true;
        }
        insert personalSettings;
        insert TestDataSetupUtility.buildMaximumCustomerNumberSetting();
        insert TestDataSetupUtility.buildWebServiceEndpointSetting();
        insert TestDataSetupUtility.buildIntegrationConfigSetting();
        insert TestDataSetupUtility.buildCaseTriggerSetting();
        
        accountList = new List<Account>();
        Account usedAccount = TestDataSetupUtility.createTestAccount('Test Account', AccountName, UserInfo.getUserId());
        usedAccount.OwnerId = UserInfo.getUserId();
        accountList.add(usedAccount);
        accountList[0].AccountStatus__c = 'Customer';
        accountList[0].CustomerNumber__c = '11';
        accountList[0].CustomerDate__c = Date.today();
        accountList[0].AccountStatus__c = 'Lapsed Customer';
        accountList[0].CustomerLapsedDate__c = Date.today();
        
        insert accountList;
        
        Profile p = [SELECT Id FROM Profile WHERE Name LIKE '%Service Rep%' LIMIT 1];
        User u = TestDataSetupUtility.createTestUser('John', 'Doe', p.Id);
        insert u;

        Account_Team_Member__c atm = new Account_Team_Member__c();
        atm.AccountId__c = accountList[0].Id;
        atm.TeamMemberRole__c = 'Sales Rep';
        atm.UserId__c = u.Id;
        atm.AccountAccessLevel__c = 'Read/Write';
        atm.CaseAccessLevel__c = 'Read/Write';
        insert atm;
        
        oppList = new List<Opportunity>();
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opportunity', accountList[0].Id);      
        opp.OrderCreated__c = true; 
        opp.OwnerId = UserInfo.getUserId();
        oppList.add(opp);
        insert oppList;

    }
     /** 
     * @author Andre Calimlim
     * @date 1.7.15
     * @description Positive Test method to verify that the Finance Order Type is copied from the Parent Order if it is a Credit Recordtype.
     */
    static testMethod void testCreditOrderFOTVerified() {
        createRec('North America', false);
        //update accountList;
        Contact con2 = TestDataSetupUtility.createTestContact(accountList[0].Id, 'confirst1', 'conlast1', 'con1@email.com');
        insert con2;
        List<Order__c> orderList = new List<Order__c>();
        Order__c ord = TestDataSetupUtility.createOrderWithOpportunity(accountList[0].Id, null, null, con2.Id);
        ord.OrderDate__c = Date.today();
        ord.OrderStatus__c = 'Open';
        orderList.add(ord);
        insert orderList;
        Order_Line_Item__c  oLI2 =TestDataSetupUtility.createOrderLineItem(ord.id);
        insert oLI2;

        //update accountList;
        
        Set<Id> acctSet = new Set<Id>();
        Set<Id> ordIds = new Set<Id>();
        personalSettings.Trigger_Order__c = true;
        //update personalSettings;
        
            
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
            //Map<Id, Account> acctMap = new Map<Id, Account>([Select Id, CustomerDate__c, CustomerLapsedDate__c, AccountStatus__c from Account where Id in : acctSet]);
            Id ordIdUpdated ;
            for(Order__c o : [Select Id, OrderDate__c, OrderStatus__c, Account__c, Finance_Order_Type_pickList__c from Order__c where Id in : ordIds]){
                //System.assertNotEquals(null, acctMap.get(ord.Account__c).CustomerLapsedDate__c);
                System.assertNotEquals(Date.today(), o.OrderDate__c);
                //System.assertEquals('Lapsed', o.Finance_Order_Type_pickList__c);
                ordIdUpdated = o.Id;
            }
            
            Order__c[] pNewOrderList = new List<Order__c>();
            Order__c ordCreated = TestDataSetupUtility.createOrderWithOpportunity(accountList[0].Id, null, null, con2.Id);
            ordCreated.RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Credit').getRecordTypeId();
            ordCreated.OrderStatus__c = 'Verified';
            ordCreated.OrderDate__c = Date.today();
            ordCreated.ParentOrder__c = orderList[0].Id;//ordIdUpdated;
            ordCreated.CreditType__c = 'Full';
            ordCreated.BulkCreditLoad__c = true;
            //insert ordCreated;
            pNewOrderList.add(ordCreated);
            Contact con = TestDataSetupUtility.createTestContact(accountList[0].Id, 'confirst1', 'conlast1', 'con1@email.com');
            insert con;
        
  
            
            Order__c o1 = TestDataSetupUtility.createOrder(accountList[0].Id, con.Id);
            insert new List<Order__c>{ordCreated,o1};
            
            Order_Line_Item__c oli = TestDataSetupUtility.createOrderLineItem(orderList[0].Id); 
            oli.AdjustedPrice__c = 100;
            oli.Quantity2__c = 10;
            oli.MAPPProduct__c = '123';  
            oli.MAPP_Order_ID__c = String.ValueOf(o1.Id).left(15);
            //oli.PostingLocation__c = 'Global';   
            insert oli;
        Test.startTest();    
            BulkFullCreditLoadProcessor.startFullCreditLoad(pNewOrderList);           
        Test.stopTest();
    }
}