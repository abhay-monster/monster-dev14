@isTest
public with sharing class ContactTriggerHelperTest {
    static testMethod void testPrimaryBillingContact() {
        AccountTriggerHandler.ExecuteTriggers = true;
        Personal_Settings__c personalSettings = new Personal_Settings__c();
        personalSettings.Trigger_Contact__c = true;
        personalSettings.Validation_Account__c = false;
        insert personalSettings;
        
        IntegrationConfig__c  integConfigSettings = new IntegrationConfig__c(Name ='USPS Integration', 
                                                                             Timeout__c=60000,
                                                                             IsPaypalTest__c=true,
                                                                             EndpointName__c='USPSAddressValidation',
                                                                             Username__c='562CLOUD2615');
        insert integConfigSettings;
        
        WebServiceEndpoint__c wsEndpoint = new WebServiceEndpoint__c(Name='USPSAddressValidation', Endpoint__c='http://production.shippingapis.com/ShippingAPI.dll');
        insert wsEndpoint;
        
        list<Account> accountList = new list<Account>();
        Account testAccount = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TEST PB Account');//, 'North America', UserInfo.getUserId());
        testAccount.Phone = '+18008008000';
        testAccount.BillingCountry = 'Philippines';
        
        
        testAccount.DunsNumber = '21232332';
        testAccount.MAPP_Country__c = 'IT';
        testAccount.CreatedDate = System.now();
        insert testAccount;
        accountList.add(testAccount);
        accountList.add( TestDataSetupUtility.createTestAccountWithShippingAndBilling('Parent Account2'));
        
        
        
        
        accountList.add( TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Agency Account 1'));
        accountList[1].ParentId = testAccount.Id; 
        accountList[1].AgencyFlag__c = true;
        accountList[1].MAPP_Country__c = 'DK';
        accountList[1].RegistrationNumber__c = '55433434';
        accountList[1].CreatedDate = System.now();
        
        insert accountList[1];
        
        Account testAccount2=TestDataSetupUtility.createTestAccountWithShippingAndBilling('TEST PB Account2');   
         testAccount2.Phone = '+18008008900';
        testAccount2.BillingCountry = 'India';
        
        
        testAccount2.DunsNumber = '21232333';
        testAccount2.MAPP_Country__c = 'IT';
        testAccount2.CreatedDate = System.now();
        insert testAccount2;
        accountList[2].ParentId = testAccount2.Id; 
        accountList[2].AgencyFlag__c = true;
        accountList[2].MAPP_Country__c = 'DK';
        accountList[2].RegistrationNumber__c = '55433434';
        accountList[2].CreatedDate = System.now();
        
        
        accountList.add(testAccount2);
        insert accountList[2];
        System.debug('see the size of accountlist '+accountList.size());
        RelatedPartner__c relatedPrtner = TestDataSetupUtility.createTestRelatedPartner(testAccount.Id, accountList[1].Id);
        insert relatedPrtner;
        testAccount.PrimaryRelatedAgency__c = relatedPrtner.Id;
        
         RelatedPartner__c relatedPrtner2 = TestDataSetupUtility.createTestRelatedPartner(testAccount2.Id, accountList[2].Id);
        insert relatedPrtner2;
        testAccount.PrimaryRelatedAgency__c = relatedPrtner2.Id;
        
        
        List<Contact> contactList = new List<Contact>();
        Contact testContact1 = TestDataSetupUtility.createTestContact(testAccount.Id, 'PrimaryBillingTestLastnameOne', 'PrimaryBillingTestFirstnameOne', 'email1@testContact.com');
        testContact1.PrimaryBillingContact__c = true;
        testContact1.PrimarySalesContact__c = true;
        testContact1.InternetType__c = 'Internet Billing';
        
        
        contactList.add(testContact1);
        insert contactList[0];
        
 
        /*Case case1 = new Case(
AccountId = testAccount.Id,
ContactId = testContact1.Id,
Status = 'New',
Category__c = 'Browser Issue',
Issue__c = 'Other',
SubIssue__c = 'Other',
Subject = 'TEST Subject Parent',
//RecordTypeId = caseParentRecordTypeId,
CustomerProblemDetail__c = 'TEST Details Parent'
);
insert case1;
*/
        Contact testContact2 = TestDataSetupUtility.createTestContact(testAccount.Id, 'PrimaryBillingTestLastnameTwo', 'PrimaryBillingTestFirstnameTwo', 'email2@testContact.com');
        testContact2.InternetType__c = 'Internet Primary';
        contactList.add(testContact2);
        System.debug('see the debug '+testContact2.AccountId+'see '+testAccount.Id);
       // contactList[1].PrimarySalesContact__c = true;
        contactList[1].PrimaryServiceContact__c = true;
        // contactList[1].PrimaryBillingContact__c = false;
         //contactList[1].InternetType__c = 'Internet Billing';
        
        Contact testContact3 = TestDataSetupUtility.createTestContact(testAccount2.Id, 'PrimaryBillingTestLastnameThree', 'PrimaryBillingTestFirstnameThree', 'email3@testContact.com');
        //testContact3.PrimaryBillingContact__c = true;
        testContact3.PrimarySalesContact__c = false;
        testContact3.PrimaryServiceContact__c = false;
        
        contactList.add(testContact3);
  /*      
// For testing onBeforeInsert Methods
Account testAccount4 = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Parent Test Account');
Account testAccount5 = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Partner Test Account_2');
testAccount5.ParentId = testAccount4.Id;
accountList.add(testAccount4);
accountList.add(testAccount5);
Contact testContact4 = TestDataSetupUtility.createTestContact(testAccount4.Id, 'Contact4', 'Test4', 'testContact4@test.com');
testContact4.PrimarySalesContact__c = true;
contactList.add(testContact4);
RelatedPartner__c relatdPartnr1 = TestDataSetupUtility.createTestRelatedPartner(testAccount4.Id, testAccount5.Id);
insert relatdPartnr1;
testAccount4.PrimaryRelatedAgency__c = relatdPartnr1.Id;

*/
        List<Case> getList=new List<Case>();
        
        
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            // insert contactList;
            
            Case case1 = new Case(
                AccountId = testAccount.Id,
                ContactId = testContact1.Id,
                Status = 'New',
                Category__c = 'Browser Issue',
                Issue__c = 'Other',
                SubIssue__c = 'Other',
                Subject = 'TEST Subject Parent',
                //RecordTypeId = caseParentRecordTypeId,
                CustomerProblemDetail__c = 'TEST Details Parent'
            );
            insert case1;
            
            Case case2 = new Case(
                AccountId = testAccount2.Id,
                ContactId = testContact2.Id,
                Status = 'New',
                Category__c = 'Browser Issue',
                Issue__c = 'Other',
                SubIssue__c = 'Other',
                Subject = 'TEST Subject Parent',
                //RecordTypeId = caseParentRecordTypeId,
                CustomerProblemDetail__c = 'TEST Details Parent'
            );
            insert case2;
          
            Test.startTest();
     
            //insert contactList;
            
           
           // contactList[1].PrimarySalesContact__c = true;
          // contactList[1].PrimaryServiceContact__c = true;
            getList=[SELECT ID from Case 
                     WHERE Status='New'];
            Id conId=getList[0].Id;
            contactList[1].Related_Case__c = conId;
             
            //contactList[2].InternetType__c = 'Internet Billing';
            //contactList[2].PrimaryBillingContact__c = true;
            insert contactList[1];
             insert contactList[2];
            //insert contactList;
        
            //System.debug('See Vaibhav '+case.Id);
            
            // System.assert(false,'==@@@@ConId'+conId+'===@@@Related_Case__c=='+contactList[1].Related_Case__c);
            
           // contactList[1].PrimarySalesContact__c = true;
            //contactList[1].PrimaryServiceContact__c = true;
           // update contactList[1];
            //update contactList[0];
            
          // List<Contact> getList1=new List<Contact>();
            
          //  getList1=[SELECT Related_Case__c from Contact 
           //           WHERE ID=:contactList[1].Id];
           // System.debug('Look for the related case '+getList1[0].Related_Case__c);
            // System.assert(false,'==@@@@ConId'+conId+'===@@@Related_Case__c=='+getList1[0].Related_Case__c);
            
            
            contactList[1].PrimarySalesContact__c = false;
           contactList[1].PrimaryServiceContact__c = !contactList[1].PrimaryServiceContact__c;
           // contactList[1].PrimaryServiceContact__c=false;
            update contactList[1];
             contactList[2].InternetType__c = 'Internet Billing';
            contactList[2].PrimaryBillingContact__c = true;
            //contactList[2].PrimaryServiceContact__c=true;
            //update contactList[2];
            //contactList[2].PrimaryBillingContact__c = true;
             
           // update contactList[1];
            delete contactList[2];
          /*  // Jyothi start of new code
            AccountContactAssociation__c accountAsso;
            Account testAccountForAgency=TestDataSetupUtility.createTestAccountWithShippingAndBilling('TEST PB Account2');   
            Contact testContactForAgency = TestDataSetupUtility.createTestContact(testAccountForAgency.Id, 'PrimaryAgencyLastname', 'PrimaryAgencyFirstname', 'emailAgency3@testContact.com');
            accountAsso = new AccountContactAssociation__c(PrimarySalesContact__c=false, Account__c=testAccountForAgency.id, Contact__c = testContactForAgency.id);       
            testAccountForAgency.Primary_Agency_Contact__c = testContactForAgency.Id; 
            insert accountAsso;
            
            insert testContactForAgency;
            testAccountForAgency.Primary_Agency_Contact__c = testContactForAgency.Id; 
            update accountAsso;
            delete testContactForAgency;
        */    // Jyothi End of new code
            ContactTriggerHelper obj=ContactTriggerHelper.NewTriggerHelper();
            obj.fixEcomm(contactList);
            Test.stopTest();
    }
        
        //ContactTriggerHelper cth = ContactTriggerHelper.NewTriggerHelper();
        //cth.uncheckOtherPrimaryBillingContacts(contactList);
        //cth.setPrimaryBillingContact(contactList); 
        
        Contact assertContact = [SELECT Id, PrimaryBillingContact__c FROM Contact WHERE Id=: testContact1.Id];
        //System.assertEquals(assertContact.PrimaryBillingContact__c, false);
        
        Account assertAccount = [SELECT Id, PrimaryBillingContact__c FROM Account WHERE Id=:testAccount.Id];
        //System.assertEquals(assertAccount.PrimaryBillingContact__c, contactList[1].Id);
        
        
    }
  
}