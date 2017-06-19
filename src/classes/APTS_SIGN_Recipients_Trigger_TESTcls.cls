@isTest

public class APTS_SIGN_Recipients_Trigger_TESTcls {
    static testMethod void testRecipients1() {
        
        //create account
        List<Account> accountsList = new List<Account>();
        Account account1 = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account for Recipient');
        accountsList.add(account1);
        
        Account account2 = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Agency Account');
        account2.AgencyFlag__c = true;
        account2.CreditStatus__c = 'Ok';
        
        accountsList.add(account2);
        insert accountsList;
        
        //create contact
        
        List<Contact> testContactList = new List<Contact>();
        
        Contact testContact = new Contact(FirstName = 'newRecipient', LastName = 'Contact1');
        testContact.Email = 'text.1@apttus.com';
        testContact.AccountId = account1.Id;
        testContactList.add(testContact);        
        
        Contact testContact2 = new Contact(FirstName = 'newRecipient', LastName = 'Contact2');
        testContact2.Email = 'text.2@apttus.com';
        testContact2.AccountId = account2.Id;

        testContactList.add(testContact2);
        insert testContactList; 
        
        RelatedPartner__c partner = new RelatedPartner__c();
        partner.Account__c = account1.id;
        partner.AgencyType__c = 'Agency';        
        partner.Partner__c = account2.id;
        
        insert partner;       
        
        // create echosign_dev1__SIGN_Recipients__c object
        echosign_dev1__SIGN_Recipients__c recipientsObject = new echosign_dev1__SIGN_Recipients__c();
        recipientsObject.Name = 'New recipientsObjectject';
        recipientsObject.echosign_dev1__Recipient_Type__c = 'Contact';
        recipientsObject.echosign_dev1__Contact__c = testContact2.Id;
        
        echosign_dev1__SIGN_Recipients__c recipientsObject2 = new echosign_dev1__SIGN_Recipients__c();
        recipientsObject2.Name = 'New recipientsObjectject';
        recipientsObject2.echosign_dev1__Recipient_Type__c = 'Contact';
        recipientsObject2.echosign_dev1__Contact__c = testContact2.Id;       
        
        test.startTest();
        try{
            insert recipientsObject;
            insert recipientsObject2;
            recipientsObject2.echosign_dev1__Email_Address__c = 'apttus@apttus.com';
            update recipientsObject2;
        } Catch (Exception ex) {
            
        }
        test.stopTest();
    }
       
    static testMethod void testRecipients2() {
        
        Profile pr = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User usr = TestDataSetupUtility.createTestUser('Test User', 'System Admin', pr.Id);
        insert usr ;
        
        System.runAs(usr){
            //create account
            List<Account> accountsList = new List<Account>();
            Account account1 = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account for Recipient');
            accountsList.add(account1);
            
            Account account2 = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Agency Account');
            account2.AgencyFlag__c = true;
            account2.CreditStatus__c = 'Ok';
            accountsList.add(account2);
            
            insert accountsList;
            List<Contact> testContactList = new List<Contact>();
            
            //create contact
            Contact testContact = new Contact(FirstName = 'newRecipient', LastName = 'Contact1');
            testContact.Email = usr.email;
            testContact.AccountId = account1.Id;
            
            testContactList.add(testContact);
            
            Contact testContact2 = new Contact(FirstName = 'newRecipient', LastName = 'Contact2');
            testContact2.Email = 'text.2@apttus.com';
            testContact2.AccountId = account2.Id;

            testContactList.add(testContact2);
            insert testContactList;
            
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('TestOpp', account1.Id);
            insert opp;
            
            Apttus_Proposal__Proposal__c Prop = TestDataSetupUtility.createProposal(opp.Id);
            insert Prop;
            
            // create agreement
            echosign_dev1__SIGN_Agreement__c newAgreement = new echosign_dev1__SIGN_Agreement__c();
            newAgreement.Name = 'testAgreement';
            newAgreement.echosign_dev1__Recipient__c = testContact.Id;
            newAgreement.echosign_dev1__Account__c = account1.Id;
            //newAgreement.Quote_Proposal__c = Prop.Id;
            newAgreement.Apttus_QPESign__Apttus_Proposal__c = Prop.Id;
            insert newAgreement;
            
            RelatedPartner__c partner = new RelatedPartner__c();
            partner.Account__c = account1.id;
            partner.AgencyType__c = 'Agency';        
            partner.Partner__c = account2.id;
            
            insert partner;
            
            List<echosign_dev1__SIGN_Recipients__c> recipientsList = new List<echosign_dev1__SIGN_Recipients__c>(); 
            
            echosign_dev1__SIGN_Recipients__c recipientsObject = new echosign_dev1__SIGN_Recipients__c();
            recipientsObject.Name = 'New recipientsObjectject';
            recipientsObject.echosign_dev1__Agreement__c = newAgreement.Id;
            recipientsObject.echosign_dev1__Recipient_Type__c = 'Contact';
            recipientsObject.echosign_dev1__Contact__c = testContact2.Id;
            
            
            echosign_dev1__SIGN_Recipients__c recipientsObject2 = new echosign_dev1__SIGN_Recipients__c();
            recipientsObject2.Name = 'New recipientsObjectject2';
            recipientsObject2.echosign_dev1__Agreement__c = newAgreement.Id;
            recipientsObject2.echosign_dev1__Recipient_Type__c = 'Contact';
            recipientsObject2.echosign_dev1__Contact__c = testContact2.Id;
            
            //recipientsList.add(recipientsObject2);
            
            test.startTest();
            insert recipientsObject;
            insert recipientsObject2;
 
            System.debug('ContactAccountCheck:' + recipientsObject.Contact_Account__c);
            recipientsObject.echosign_dev1__Contact__c = testContact.Id;
            recipientsObject.echosign_dev1__Email_Address__c = 'apttus@apttus.com';
            recipientsObject2.echosign_dev1__Email_Address__c = 'apttus@apttus.com';
                       
            update recipientsObject;
            update recipientsObject2;
            test.stopTest();
        }
    }
    
    static testMethod void testRecipients3() {
        
        Profile pr = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User usr = TestDataSetupUtility.createTestUser('Test User', 'System Admin', pr.Id);
        insert usr ;
        
        System.runAs(usr){
            //create account
            List<Account> accountsList = new List<Account>();
            Account account1 = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account for Recipient');
            accountsList.add(account1);
            
            Account account2 = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Agency Account');
            account2.AgencyFlag__c = true;
            account2.CreditStatus__c = 'Ok';
            accountsList.add(account2);
            
            insert accountsList;
            List<Contact> testContactList = new List<Contact>();
            
            //create contact
            Contact testContact = new Contact(FirstName = 'newRecipient', LastName = 'Contact1');
            testContact.Email = usr.email;
            testContact.AccountId = account1.Id;
            
            testContactList.add(testContact);
            
            Contact testContact2 = new Contact(FirstName = 'newRecipient', LastName = 'Contact2');
            testContact2.Email = 'text.2@apttus.com';
            testContact2.AccountId = account2.Id;

            testContactList.add(testContact2);
            insert testContactList;
            
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('TestOpp', account1.Id);
            insert opp;
            
            Apttus_Proposal__Proposal__c Prop = TestDataSetupUtility.createProposal(opp.Id);
            insert Prop;
            
            // create agreement
            echosign_dev1__SIGN_Agreement__c newAgreement = new echosign_dev1__SIGN_Agreement__c();
            newAgreement.Name = 'testAgreement';
            newAgreement.echosign_dev1__Recipient__c = testContact.Id;
            newAgreement.echosign_dev1__Account__c = account1.Id;
            //newAgreement.Quote_Proposal__c = Prop.Id;
            newAgreement.Apttus_QPESign__Apttus_Proposal__c = Prop.Id;
            insert newAgreement;
            
            RelatedPartner__c partner = new RelatedPartner__c();
            partner.Account__c = account1.id;
            partner.AgencyType__c = 'Agency';        
            partner.Partner__c = account2.id;
            
            insert partner;           
            
            echosign_dev1__SIGN_Recipients__c recipientsObject = new echosign_dev1__SIGN_Recipients__c();
            recipientsObject.Name = 'New recipientsObjectject';
            recipientsObject.echosign_dev1__Agreement__c = newAgreement.Id;
            recipientsObject.echosign_dev1__Recipient_Type__c = 'Contact';
            recipientsObject.echosign_dev1__Contact__c = testContact2.Id;            
            
            echosign_dev1__SIGN_Recipients__c recipientsObject2 = new echosign_dev1__SIGN_Recipients__c();
            recipientsObject2.Name = 'New recipientsObjectject2';
            recipientsObject2.echosign_dev1__Agreement__c = newAgreement.Id;
            recipientsObject2.echosign_dev1__Recipient_Type__c = 'Contact';
            recipientsObject2.echosign_dev1__Contact__c = testContact.Id;
            
            test.startTest();
            insert recipientsObject2;
            insert recipientsObject;
            try{
                //recipientsObject2.Id ='';
                recipientsObject2.Id ='000000000000';
                
               // recipientsObject2.Id ='';
                update recipientsObject2;
               }catch(Exception e){             
               }
            test.stopTest();
        }
    }
}