/*
* @Author : Apttus
* @Created Date : 28-05-2015
*
*/
trigger paymentDetailsTrigger on Payment_Details__c (before insert,before update) {

    map<String,Payment_Details__c> mapOrgtoPaymentDetails = new map<String,Payment_Details__c>();
    
    list<Payment_Details__c> defaultPaymentDetailsList = [Select id,Name,
                                                                 Default_for_Partner_Proposal__c,Active__c,
                                                                 Organization__c FROM Payment_Details__c 
                                                                 WHERE Active__c = true AND
                                                                 Default_for_Partner_Proposal__c = true AND
                                                                 Organization__c != null];
                                                                 
    for(Payment_Details__c paymentDetailSO : defaultPaymentDetailsList){
    
        if(!mapOrgtoPaymentDetails.containskey(paymentDetailSO.Organization__c)){
            
            mapOrgtoPaymentDetails.put(paymentDetailSO.Organization__c,paymentDetailSO);
            
        }    
    }
    
    
    for(Payment_Details__c paymentDetailSO : trigger.new){
        
        if(paymentDetailSO.Default_for_Partner_Proposal__c == true){
        if(mapOrgtoPaymentDetails.containskey(paymentDetailSO.Organization__c) && paymentDetailSO.Id != mapOrgtoPaymentDetails.get(paymentDetailSO.Organization__c).Id){
            paymentDetailSO.addError('Default partner proposal payment detail already exists for organization ' + paymentDetailSO.Organization__c);
        }
        }
        
        // Changes Start by Gaurav for Task : T-421862
        if(paymentDetailSO.PaymentFrequency__c == 'Monthly')
            paymentDetailSO.True_Term__c = 30;
        if(paymentDetailSO.PaymentFrequency__c == 'Quarterly')
            paymentDetailSO.True_Term__c = 90;
        if(paymentDetailSO.PaymentFrequency__c == 'Semi-Annual')
            paymentDetailSO.True_Term__c = 180;
        if(paymentDetailSO.PaymentFrequency__c == 'Annual')
            paymentDetailSO.True_Term__c = 360;
            
        if(paymentDetailSO.PaymentFrequency__c.contains('Non-Standard') || paymentDetailSO.PaymentTerm__c.contains('Non-Standard') )
            paymentDetailSO.Non_Standard_Payment__c= True;
            
                     
        // Changes End by Gaurav for Task : T-421862
        
        
    } 

}