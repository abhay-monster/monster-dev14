/**
 * @author Andre Calimlim
 * @date 12.17.14
 * @description Test Class for OrderCommentTriggerHelper.
 */
@isTest
private class OrderCommentTriggerHelperTest {
  //declare static variables
    static Personal_Settings__c personalSettings;
    static List<Order__c> orderList;
    static List<Order_Comment__c> orderCommentList;
    /** 
     * @author Andre Calimlim
     * @date 12.17.14
     * @description static method to create test data records
     * @param numRec - Integer value to specify number of Order Comments to create
     */
    static void createRec(Integer numRec, Boolean setPersonalSettings){
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
        
        List<Account> accountList = new List<Account>();
        Account usedAccount = TestDataSetupUtility.createTestAccount('Test Account', 'North America', UserInfo.getUserId());
        accountList.add(usedAccount);
        
        insert accountList;
        
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opportunity', accountList[0].Id);      
        oppList.add(opp);
        insert oppList;

        orderList = new List<Order__c>();
        Order__c ord = TestDataSetupUtility.createOrderWithOpportunity(accountList[0].Id, oppList[0].Id, null);

        orderList.add(ord);
        insert orderList;
        
        orderCommentList = new List<Order_Comment__c>();
        for(Integer i = 0; i < numRec; i++){
            Order_Comment__c newRec = TestDataSetupUtility.createTestOrderComment(orderList[0].Id, 'Test Description ' + i, null);
            orderCommentList.add(newRec);
        }
    }
    /** 
     * @author Andre Calimlim
     * @date 12.17.14
     * @description Positive Test method to verify that the Order Description__c / Last Comment from the recent related List (Order Comment) on creation is the same.
     */
    static testMethod void testCreateOrderComment() {
        
        createRec(3, false);
        
        Test.startTest();
            insert orderCommentList;
            System.assertEquals('Test Description 2', [Select Description__c from Order__c where Id = : orderList[0].Id].Description__c);
        Test.stopTest();
    }
    
    /** 
     * @author Andre Calimlim
     * @date 12.17.14
     * @description Positive Test method to verify that the Order Description__c / Last Comment from the recent Updated Order Comment is the same.
     */
    static testMethod void testUpdateOrderComment() {
        
        createRec(3, false);
        insert orderCommentList;
        
               
        Test.startTest();
            Order__c testOrder = [Select Description__c from Order__c where Id =: orderCommentList[0].Order__c];
            testOrder.Description__c = 'Updated Comment';
            update testOrder;
            System.assertEquals('Updated Comment', [Select Description__c from Order__c where Id = : testOrder.Id].Description__c);
        Test.stopTest();
    } 
    
    /* Test method for updat*/
    
     static testMethod void testUpdateOrderCommentDescription() {
        createRec(1, false);
        insert orderCommentList;
        
        Order_Comment__c newRec = [ Select Id, Order__c,Description__c  from Order_Comment__c Where Id = :orderCommentList[0].Id ];
        newRec.Description__c = 'Test-Description';
        update newRec;
        
        Order__c o = [ Select Id,Description__c from Order__c Where Id = :newRec.Order__c];
        // Verify Description is copied on order
        System.assert(o.Description__c == 'Test-Description');
    
    }
    
    
}