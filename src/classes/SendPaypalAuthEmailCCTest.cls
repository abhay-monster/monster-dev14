@isTest
public class SendPaypalAuthEmailCCTest {
    static testmethod void testSendPaypalAuthEmailCC()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u  = TestDataSetupUtility.createTestUser('TestFistName', 'TestLastName', p.Id);
        insert u ;    
        System.runAs(u) 
        {
            Test.startTest();
            
            Account testAccount = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TEST PB Account');//, 'North America', UserInfo.getUserId());
            testAccount.Phone = '+18008008000';
            testAccount.BillingCountry = 'Philippines';
            testAccount.PrimaryServiceRep__c = u.id;
            testAccount.Organization__c = 'Europe';
            testAccount.ServiceTier__c = 'Core';
            insert testAccount;

            Contact testContact = TestDataSetupUtility.createTestContact(testAccount.Id, 'Dang-Smith', 'Bodiddly', 'dangSBo@BodidalyBBQ.co.uk');
            insert testContact;
            
            Order__c order = TestDataSetupUtility.createOrder(testAccount.Id, testContact.Id);
            order.IsPaypalAuthorizationEmailSent__c = true;
            insert order;
            
            Invoices__c invoice = TestDataSetupUtility.createInvoice(order.Id, testContact.Id);
            insert invoice;

            ApexPages.currentPage().getParameters().put('Id',invoice.Id);
            SendPaypalAuthEmailCC obj = new SendPaypalAuthEmailCC();
            obj.prepSendEmail();
            obj.sendEmail();
            
            system.assertEquals(obj.Message, 'Email sent.');
            Test.stopTest();
        }
    }
}