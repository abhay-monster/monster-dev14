@isTest
private class paymentDetailsTriggerTest{

 static testMethod void paymentDetails_Test(){
 	try{
    Payment_Details__c paymentDetails;
    User u1 = [SELECT Id FROM User WHERE profileId IN (SELECT id FROM Profile WHERE Name = 'System Administrator') AND isActive = TRUE LIMIT 1];
    
    System.RunAs(u1){
        Test.StartTest();
        paymentDetails = new Payment_Details__c();
        paymentDetails.Name = 'Test';
        paymentDetails.Active__c = true;
        paymentDetails.PaymentFrequency__c ='Quarterly';
        //paymentDetails.Default_for_Partner_Proposal__c = true;
        paymentDetails.Organization__c = 'North America';
        paymentDetails.PaymentTerm__c='30 days + EOM';
        paymentDetails.Default_for_Partner_Proposal__c = true;
        insert paymentDetails;
        
        
       system.debug('xcsc'+ [Select id,Name,
                                                                 Default_for_Partner_Proposal__c,Active__c,
                                                                 Organization__c FROM Payment_Details__c 
                                                                 WHERE Active__c = true AND
                                                                 Default_for_Partner_Proposal__c = true AND
                                                                 Organization__c != null]);
        Test.Stoptest();
      }  
 	}
 	catch(exception e){
 		
 	}
    
    }
    
    
    static testMethod void paymentDetails_Test1(){
 
    Payment_Details__c paymentDetails;
    User u1 = [SELECT Id FROM User WHERE profileId IN (SELECT id FROM Profile WHERE Name = 'System Administrator') AND isActive = TRUE LIMIT 1];
    
    System.RunAs(u1){
        Test.StartTest();
        paymentDetails = new Payment_Details__c();
        paymentDetails.Name = 'Test';
        paymentDetails.Active__c = true;
        paymentDetails.PaymentFrequency__c ='Monthly';
        //paymentDetails.Default_for_Partner_Proposal__c = true;
        paymentDetails.Organization__c = 'North America';
        paymentDetails.PaymentTerm__c='Non-Standard';
       // paymentDetails.Default_for_Partner_Proposal__c = true;
        insert paymentDetails;
        
        
       system.debug('xcsc'+ [Select id,Name,
                                                                 Default_for_Partner_Proposal__c,Active__c,
                                                                 Organization__c FROM Payment_Details__c 
                                                                 WHERE Active__c = true AND
                                                                 Default_for_Partner_Proposal__c = true AND
                                                                 Organization__c != null]);
        Test.Stoptest();
      }  
        
    
    }
        
}