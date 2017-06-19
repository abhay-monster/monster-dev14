@isTest
private class PaypalProccessorTest {
	static testMethod void testPayPalProcesssor(){
		Profile sysAdminProfile = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
        
        
        User testUser = TestDataSetupUtility.createTestUser('Test Fname', 'Test Lname', sysAdminProfile.Id);
        insert testUser;
        
        Account acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        acc.BillingCity = 'Charleston';
        acc.BillingCountry = 'United States';
        acc.BillingPostalCode = '29403';
        acc.BillingState = 'South Carolina';
        acc.BillingStreet = 'xxx';
        insert acc;
        Contact con = TestDataSetupUtility.createTestContact(acc.Id, 'PrimaryBillingTestLastnameOne', 'PrimaryBillingTestFirstnameOne', 'email1@testContact.com');
        con.PrimaryBillingContact__c = true;
        insert con;
       
        System.runAs(testUser){
            
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            Test.startTest();
                PaypalProccessor controller = new PaypalProccessor();
              	System.assert(controller.doDirectPayment() != null);
              	controller.pay();
            Test.stopTest();
        }
	}
	
	
	public class MockHttpResponseGenerator implements HttpCalloutMock {
	    // Implement this interface method
	    public HTTPResponse respond(HTTPRequest req) {
	       
	        // Create a fake response
	        HttpResponse res = new HttpResponse();
	        res.setHeader('Content-Type', 'application/xml');
	        res.setBody(sampleResponse);
	        res.setStatusCode(200);
	        return res;
	    }
	}   
	
	
	
	public static String sampleResponse {
   	get{
   		return '<response><Ack>Success</Ack></response>';
   	}
   }
}