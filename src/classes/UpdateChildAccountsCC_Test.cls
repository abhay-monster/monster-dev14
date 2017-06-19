@isTest
public class UpdateChildAccountsCC_Test {
	static testMethod void testUpdateChildAccountsCC() {
        Account usedAccount = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        
        RegistrationNumber__c rn = new RegistrationNumber__c();
        rn.name = 'test';
        rn.AgencyCommission__c = 1 ;
        rn.AgencyCommissionCheck__c = true;
        rn.AgencyFlag__c = true;
        rn.AgencyFlagCheck__c = true;
        rn.CreditCheckReferenceNumberCheck__c = true;
        rn.CreditCheckReferenceNumber__c = 'true';
        rn.CreditlimitCheck__c = true;
        rn.CreditLimit__c = 12;
        rn.CreditStatusCheck__c = true;
        rn.CreditStatus__c  = 'Ok';
        rn.CrRefCommentCheck__c = true;
        rn.CrRefComment__c = 'tes';
        rn.DirectDebitCheck__c = true;
        rn.DirectDebit__c = true;
        rn.DirectDebitDiscountCheck__c = true;
        rn.DirectDebitDiscount__c = true;
        rn.POComments__c = 'sadsad';
        rn.POcommentsCheck__c = true;
        rn.PORequired__c = true;
        rn.PORequiredCheck__c = true;
        rn.PostingCityCheck__c = true;
        rn.PostingCity__c = 'sada';
        rn.PostingCountryCheck__c = true;
        rn.PostingCountry__c = 'Andorra';
        rn.PostingStateProvinceCheck__c = true;
        //rn.PostingStateProvince__c='Alabama';
        rn.PostingStreetCheck__c = true;
        rn.PostingStreet__c = 'sda';
        rn.PostingZipPostalCodeCheck__c = true;
        rn.PostingZipPostalCode__c = 'sad';
        rn.SelfBillingCheck__c = true;
        rn.SelfBilling__c = true;
        rn.CreditCheckReferenceNumberCheck__c = true;
        rn.CreditCheckReferenceNumber__c = 'ss';
        insert rn;
        usedAccount.Registration__c  = rn.id;
        insert usedAccount;
        ApexPages.StandardController sc = new ApexPages.standardController(rn);
        UpdateChildAccountsCC  controller = new UpdateChildAccountsCC (sc);
        controller.updateAccounts();
    }
}