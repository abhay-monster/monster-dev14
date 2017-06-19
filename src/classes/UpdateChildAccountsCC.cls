public without sharing class UpdateChildAccountsCC {
    final String CLASSNAME = '\n\n**** UpdateChildAccountsCC.METHODNAME()';  
    public RegistrationNumber__c regNumber{get;set;}
    public String regNumId{get;set;}
    public list<Account> updateAccountList = new List<Account>();
    public RegistrationNumber__c rn;
     
    public UpdateChildAccountsCC(ApexPages.StandardController controller) {
        final string METHODNAME = CLASSNAME.replace('METHODNAME','UpdateChildAccountsCC') + ' - constructor';
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        regNumber = (RegistrationNumber__c)controller.getRecord();        
        regNumId = regNumber.Id;
        system.debug(LoggingLevel.DEBUG, METHODNAME + '\n\nRegistration ID :: ' + regNumId + '\n\n');
        rn = [SELECT Id, PaymentDetails__c, ApplyPaymentDetails__c FROM RegistrationNumber__c WHERE Id=: regNumId];
    }
    
    public PageReference updateAccounts() {
        
        for(Account acc : [SELECT Id, AgencyCommission__c, AgencyFlag__c, CrRefComment__c, CreditCheckReferenceNumber__c, 
                            CreditLimit__c, CreditStatus__c, DirectDebit__c, DirectDebitDiscount__c, PaymentDetails__c,
                            POComments__c, PORequired__c, SelfBilling__c, SpecialBillingInstructions__c, ShippingStreet, ShippingCountry,
                            ShippingCity, ShippingPostalCode, ShippingState FROM Account WHERE Registration__c =: regNumId]) {

            if(regNumber.AgencyCommissionCheck__c && regNumber.AgencyCommission__c!=NULL && regNumber.AgencyFlag__c) {
                acc.AgencyCommission__c = regNumber.AgencyCommission__c;
            }            
            if(regNumber.AgencyFlagCheck__c && regNumber.AgencyFlag__c!=NULL) {
                acc.AgencyFlag__c= regNumber.AgencyFlag__c;
            }                            
            if(regNumber.CreditCheckReferenceNumberCheck__c && regNumber.CreditCheckReferenceNumber__c!=NULL) {
                acc.CreditCheckReferenceNumber__c = regNumber.CreditCheckReferenceNumber__c;
            }
            if(regNumber.CreditlimitCheck__c && regNumber.CreditLimit__c!=NULL) {
                acc.CreditLimit__c = regNumber.CreditLimit__c;
            }
            if(regNumber.CreditStatusCheck__c && regNumber.CreditStatus__c!=NULL) {
                acc.CreditStatus__c = regNumber.CreditStatus__c;
            }
            if(regNumber.CrRefCommentCheck__c && regNumber.CrRefComment__c!=NULL) {
                acc.CrRefComment__c = regNumber.CrRefComment__c;
            }
            if(regNumber.DirectDebitCheck__c && regNumber.DirectDebit__c) {
                acc.DirectDebit__c = regNumber.DirectDebit__c;
            }
            if(regNumber.DirectDebitDiscountCheck__c && regNumber.DirectDebitDiscount__c) {
                acc.DirectDebitDiscount__c = regNumber.DirectDebitDiscount__c;
            }
            /*if(regNumber.PaymentmethodCheck__c && regNumber.PaymentMethod__c!=NULL) {
                acc.PaymentMethod__c = regNumber.PaymentMethod__c;
            }*/
            system.debug('\n\n\n\n\n\n**regNumber.ApplyPaymentDetails__c: ' + rn.ApplyPaymentDetails__c +'\nrn.PaymentDetails__c: '+rn.PaymentDetails__c+'\n\n\n');
            if(rn.ApplyPaymentDetails__c && rn.PaymentDetails__c!=NULL) {
                acc.PaymentDetails__c = rn.PaymentDetails__c;
            }
            if(regNumber.POcommentsCheck__c && regNumber.POComments__c!=NULL ) {
            acc.POComments__c = regNumber.POComments__c;
            }
            if(regNumber.PORequiredCheck__c && regNumber.PORequired__c) {
                acc.PORequired__c = regNumber.PORequired__c;
            }
            if(regNumber.PostingCityCheck__c && regNumber.PostingCity__c!=NULL) {
                acc.ShippingCity = regNumber.PostingCity__c;
            }
            if(regNumber.PostingCountryCheck__c && regNumber.PostingCountry__c!=NULL) {
                acc.ShippingCountry = regNumber.PostingCountry__c;
            }
            if(regNumber.PostingStateProvinceCheck__c && regNumber.PostingStateProvince__c!=NULL) {
                acc.ShippingState = regNumber.PostingStateProvince__c;
            }
            if(regNumber.PostingStreetCheck__c && regNumber.PostingStreet__c!=NULL ) {
                acc.ShippingStreet = regNumber.PostingStreet__c;
            }
            if(regNumber.PostingZipPostalCodeCheck__c && regNumber.PostingZipPostalCode__c!=NULL) {
                acc.ShippingPostalCode = regNumber.PostingZipPostalCode__c;
            }
            if(regNumber.SelfBillingCheck__c && regNumber.SelfBilling__c) {
                acc.SelfBilling__c = regNumber.SelfBilling__c;
            }
            if(regNumber.CreditCheckReferenceNumberCheck__c && regNumber.CreditCheckReferenceNumber__c!=NULL) {
                acc.CreditCheckReferenceNumber__c = regNumber.CreditCheckReferenceNumber__c;
            }
            updateAccountList.add(acc);                                        
        }
        
        if(!updateAccountList.isEmpty()) {
            update updateAccountList;
        }
        return new PageReference('/' + regNumId);
    } 

}