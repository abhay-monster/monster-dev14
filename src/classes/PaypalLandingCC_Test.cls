@isTest
public with sharing class PaypalLandingCC_Test {
    
    //Auth Transaction
    public static testMethod void AuthorizeCreditCardSecureTokenGeneration(){
        Profile GuestUserProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Credit Card Processing Profile'];
        
        system.debug('\n\nCurrent Profile: ' + GuestUserProfile + '\n\n');
        
        User testUser = TestDataSetupUtility.createTestUser('Test Fname', 'Test Lname', GuestUserProfile.Id);
        insert testUser;
        
        Account acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        insert acc;
        
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opportunity', acc.Id);
        opp.StageName = 'Stage 4 - Won';
        insert opp;
        
        Apttus_Proposal__Proposal__c prop = TestDataSetupUtility.createApttusProposal(opp);
        Apttus_Proposal__Proposal__c prop2 = TestDataSetupUtility.createApttusProposal(opp);
        prop2.AvalaraResponseCode__c = 'Success';
        insert new List<Apttus_Proposal__Proposal__c>{prop,prop2};
        
        Apttus_Proposal__Proposal__c usedProp = [SELECT Id, PaypalHashedId__c FROM Apttus_Proposal__Proposal__c WHERE Id = :prop.Id];
        Apttus_Proposal__Proposal__c usedProp2 = [SELECT Id, PaypalHashedId__c FROM Apttus_Proposal__Proposal__c WHERE Id = :prop2.Id];
        
        WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c();
        endpoint.Endpoint__c = 'http://www.test.com';
        endpoint.Name = 'PaypalEndpoint';
        insert endpoint;
        
        IntegrationConfig__c config = new IntegrationConfig__c();
        config.Name = 'Paypal US';
        config.EndpointName__c = endpoint.Name;
        config.PaypalPartner__c = 'SF';
        config.PaypalVendor__c = 'TEST';
        config.Username__c = 'TEST';
        config.IsPaypalTest__c = true;
        config.PaypalRedirectURL__c = endpoint.Name;
        config.Password__c = 'TEST';
        insert config;
        
        System.runAs(testUser){
            system.debug('\n\nHashed ID: ' + usedProp.PaypalHashedId__c + '\n\n');
            
            PageReference landingPage = Page.PaypalLanding;
            landingPage.getParameters().put('recordID', usedProp.PaypalHashedId__c);
            
            Test.setCurrentPage(landingPage);
            
            landingPage.getParameters().put('BILLTOFIRSTNAME', 'first');
            landingPage.getParameters().put('BILLTOLASTNAME', 'last');
            PaypalLandingCC landingController = new PaypalLandingCC();
            landingController.init();
            system.debug('\n\n' + landingController.getMessage() + '\n\n');         
            system.debug('\n\n' + landingController.GetRedirectURL() + '\n\n');
            
            landingPage.getParameters().put('CARDTYPE', '0');
            landingPage.getParameters().put('recordID', usedProp2.PaypalHashedId__c);
            
            landingController = new PaypalLandingCC();
            landingController.init();
            system.debug('\n\n' + landingController.getMessage() + '\n\n');         
            system.debug('\n\n' + landingController.GetRedirectURL() + '\n\n');
            
            landingPage.getParameters().put('CARDTYPE', '1');
            landingController = new PaypalLandingCC();
            landingPage.getParameters().put('CARDTYPE', '2');
            landingController = new PaypalLandingCC();
            
        }
    }
    
    public static testMethod void AuthorizeCreditCardProcessing(){
        Profile GuestUserProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Credit Card Processing Profile'];
        
        system.debug('\n\nCurrent Profile: ' + GuestUserProfile + '\n\n');
        
        User testUser = TestDataSetupUtility.createTestUser('Test Fname', 'Test Lname', GuestUserProfile.Id);
        insert testUser;
        
        Account acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        acc.BillingCity = 'Charleston';
        acc.BillingCountry = 'United States';
        acc.BillingPostalCode = '29403';
        acc.BillingState = 'South Carolina';
        acc.BillingStreet = 'xxx';
        insert acc;
        
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opportunity', acc.Id);
        opp.StageName = 'Stage 4 - Won';
        insert opp;
        
        Apttus_Proposal__Proposal__c prop = TestDataSetupUtility.createApttusProposal(opp);
        prop.PaypalSecureTokenID__c = '176266609134031722';
        insert prop;
        
        Apttus_Proposal__Proposal__c usedProp = [SELECT Id, PaypalHashedId__c, PaypalSecureTokenID__c FROM Apttus_Proposal__Proposal__c WHERE Id = :prop.Id];
        
        WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c();
        endpoint.Endpoint__c = 'http://www.test.com';
        endpoint.Name = 'PaypalEndpoint';
        insert endpoint;
        
        WebServiceEndpoint__c endpoint2 = new WebServiceEndpoint__c();
        endpoint2.Endpoint__c = 'http://www.PaypalRedirectURL.com';
        endpoint2.Name = 'PaypalRedirectURL';
        insert endpoint2;
        
        IntegrationConfig__c config = new IntegrationConfig__c();
        config.Name = 'Paypal US';
        config.EndpointName__c = endpoint.Name;
        config.PaypalPartner__c = 'SF';
        config.PaypalVendor__c = 'TEST';
        config.Username__c = 'TEST';
        config.IsPaypalTest__c = true;
        config.PaypalRedirectURL__c = endpoint.Name;
        config.Password__c = 'TEST';
        insert config;
        
        System.runAs(testUser){
            system.debug('\n\nHashed ID: ' + usedProp.PaypalHashedId__c + '\n\n');
            
            PageReference landingPage = Page.PaypalLanding;
            landingPage.getParameters().put('status', 'success');
            landingPage.getParameters().put('SECURETOKENID', usedProp.PaypalSecureTokenID__c);
            landingPage.getParameters().put('TRANSTIME', String.valueOf(system.now()));
            landingPage.getParameters().put('RESPMSG', 'Approved');
            landingPage.getParameters().put('RESULT', '0');
            landingPage.getParameters().put('CARDTYPE', '3');
            landingPage.getHeaders().put('Origin', endpoint2.Endpoint__c);
            Test.setCurrentPage(landingPage);
            
            Test.startTest();
                PaypalLandingCC landingController = new PaypalLandingCC();
                
                system.debug('\n\n' + landingController.GetRedirectURL() + '\n\n');
                system.debug('\n\n' + landingController.getMessage() + '\n\n'); 
            Test.stopTest();
        }
    }
    
    public static testMethod void AuthorizeCreditCardSecureTokenGenerationErrors(){
        Profile GuestUserProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Credit Card Processing Profile'];
        
        system.debug('\n\nCurrent Profile: ' + GuestUserProfile + '\n\n');
        
        User testUser = TestDataSetupUtility.createTestUser('Test Fname', 'Test Lname', GuestUserProfile.Id);
        insert testUser;
        
        Account acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        insert acc;
        
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opportunity', acc.Id);
        opp.StageName = 'Stage 4 - Won';
        insert opp;
        
        Apttus_Proposal__Proposal__c prop = TestDataSetupUtility.createApttusProposal(opp);
        insert prop;
        
        Apttus_Proposal__Proposal__c usedProp = [SELECT Id, PaypalHashedId__c FROM Apttus_Proposal__Proposal__c WHERE Id = :prop.Id];
        
        WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c();
        endpoint.Endpoint__c = 'http://www.test.com';
        endpoint.Name = 'PaypalEndpoint';
        insert endpoint;
        
        IntegrationConfig__c config = new IntegrationConfig__c();
        config.Name = 'Paypal US';
        config.EndpointName__c = endpoint.Name;
        config.PaypalPartner__c = 'SF';
        config.PaypalVendor__c = 'TEST';
        config.Username__c = 'TEST';
        config.IsPaypalTest__c = true;
        config.PaypalRedirectURL__c = endpoint.Name;
        config.Password__c = 'TEST';
        insert config;
        
        System.runAs(testUser){
            system.debug('\n\nHashed ID: ' + usedProp.PaypalHashedId__c + '\n\n');
            
            PageReference landingPage = Page.PaypalLanding;
            
            Test.setCurrentPage(landingPage);
            
            landingPage.getParameters().put('CARDTYPE', '5');
            PaypalLandingCC landingController = new PaypalLandingCC();
            landingController.init();
            system.debug('\n\n' + landingController.getMessage() + '\n\n');         
            system.debug('\n\n' + landingController.GetRedirectURL() + '\n\n');
        }
    }
    
    public static testMethod void AuthorizeCreditCardProcessingWithOrderCreatedFirst(){
        Profile GuestUserProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Credit Card Processing Profile'];
        
        system.debug('\n\nCurrent Profile: ' + GuestUserProfile + '\n\n');
        
        User testUser = TestDataSetupUtility.createTestUser('Test Fname', 'Test Lname', GuestUserProfile.Id);
        insert testUser;
        
        Account acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        acc.BillingCity = 'Charleston';
        acc.BillingCountry = 'United States';
        acc.BillingPostalCode = '29403';
        acc.BillingState = 'South Carolina';
        acc.BillingStreet = 'xxx';
        insert acc;
        
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opportunity', acc.Id);
        opp.StageName = 'Stage 4 - Won';
        insert opp;
        
        Apttus_Proposal__Proposal__c prop = TestDataSetupUtility.createApttusProposal(opp);
        prop.PaypalSecureTokenID__c = '176266609134031722';
        insert prop;
        
        opp = new Opportunity(Id = opp.Id, OrderCreated__c = true);
        update opp;
        
        Apttus_Proposal__Proposal__c usedProp = [SELECT Id, PaypalHashedId__c, PaypalSecureTokenID__c FROM Apttus_Proposal__Proposal__c WHERE Id = :prop.Id];
        
        WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c();
        endpoint.Endpoint__c = 'http://www.test.com';
        endpoint.Name = 'PaypalEndpoint';
        insert endpoint;
        
        WebServiceEndpoint__c endpoint2 = new WebServiceEndpoint__c();
        endpoint2.Endpoint__c = 'http://www.PaypalRedirectURL.com';
        endpoint2.Name = 'PaypalRedirectURL';
        insert endpoint2;
        
        IntegrationConfig__c config = new IntegrationConfig__c();
        config.Name = 'Paypal US';
        config.EndpointName__c = endpoint.Name;
        config.PaypalPartner__c = 'SF';
        config.PaypalVendor__c = 'TEST';
        config.Username__c = 'TEST';
        config.IsPaypalTest__c = true;
        config.PaypalRedirectURL__c = endpoint.Name;
        config.Password__c = 'TEST';
        insert config;
        
        System.runAs(testUser){
            system.debug('\n\nHashed ID: ' + usedProp.PaypalHashedId__c + '\n\n');
            
            PageReference landingPage = Page.PaypalLanding;
            landingPage.getParameters().put('SECURETOKENID', usedProp.PaypalSecureTokenID__c);
            landingPage.getHeaders().put('Origin', endpoint2.Endpoint__c);
            landingPage.getParameters().put('status', 'success');
            landingPage.getParameters().put('CARDTYPE', '4');
            Test.setCurrentPage(landingPage);
            
            Test.startTest();
                PaypalLandingCC landingController = new PaypalLandingCC();
                landingPage.getParameters().remove('status');
            
                system.debug('\n\n' + landingController.GetRedirectURL() + '\n\n');
                system.debug('\n\n' + landingController.getMessage() + '\n\n');
                
                
            Test.stopTest();
        }
    }
    
    public static testMethod void processAuthReturnedData(){
        Profile GuestUserProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Credit Card Processing Profile'];
        
        system.debug('\n\nCurrent Profile: ' + GuestUserProfile + '\n\n');
        
        User testUser = TestDataSetupUtility.createTestUser('Test Fname', 'Test Lname', GuestUserProfile.Id);
        insert testUser;
        
        Account acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        insert acc;
        
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opportunity', acc.Id);
        opp.StageName = 'Stage 4 - Won';
        opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'Rebill Opportunity');
        opp.Apttus_Approval__Approval_Status__c =  'No Approval Needed';
        insert opp;
        
        Apttus_Proposal__Proposal__c prop = TestDataSetupUtility.createApttusProposal(opp);
        prop.PaypalReferenceNumber__c = 'A11C7C9A8FDE';
        prop.PaypalResultCode__c = '0';
        prop.PaypalResultMessage__c = 'Approved';
        prop.PaypalSecureTokenID__c = '176266609134031722';
        //prop2.AvalaraResponseCode__c = 'Success';
        insert new List<Apttus_Proposal__Proposal__c>{prop};
        Apttus_Proposal__Proposal_Line_Item__c pli = TestDataSetupUtility.createProposalLineItem(prop.Id);
        insert pli;
        Apttus_QPConfig__ProposalProductAttributeValue__c pav = new Apttus_QPConfig__ProposalProductAttributeValue__c(Apttus_QPConfig__LineItemId__c = pli.Id);
        insert pav;
        Apttus_Proposal__Proposal__c usedProp = [SELECT Id, PaypalHashedId__c,PaypalSecureTokenID__c FROM Apttus_Proposal__Proposal__c WHERE Id = :prop.Id];
        //Apttus_Proposal__Proposal__c usedProp2 = [SELECT Id, PaypalHashedId__c FROM Apttus_Proposal__Proposal__c WHERE Id = :prop2.Id];
        
        WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c();
        endpoint.Endpoint__c = 'http://www.test.com';
        endpoint.Name = 'PaypalEndpoint';
        insert endpoint;
        WebServiceEndpoint__c endpoint2 = new WebServiceEndpoint__c();
        endpoint2.Endpoint__c = 'http://www.PaypalRedirectURL.com';
        endpoint2.Name = 'PaypalRedirectURL';
        insert endpoint2;
        Personal_Settings__c personalSettings = new Personal_Settings__c();
        personalSettings.Trigger_Account__c = true;
        insert personalSettings; 
        Xcode__c xcode = new Xcode__c(Created_For_Account__c = acc.Id,Name ='xtest');
        insert xcode;
        
        IntegrationConfig__c config = new IntegrationConfig__c();
        config.Name = 'Paypal US';
        config.EndpointName__c = endpoint.Name;
        config.PaypalPartner__c = 'SF';
        config.PaypalVendor__c = 'TEST';
        config.Username__c = 'TEST';
        config.IsPaypalTest__c = true;
        config.PaypalRedirectURL__c = endpoint.Name;
        config.Password__c = 'TEST';
        insert config;
        Test.startTest();
        System.runAs(testUser){
            system.debug('\n\nHashed ID: ' + usedProp.PaypalHashedId__c + '\n\n');
            
            PageReference landingPage = Page.PaypalLanding;
            //landingPage.getParameters().put('recordID', usedProp.PaypalHashedId__c);
            landingPage.getParameters().put('status', 'success');
            landingPage.getHeaders().put('Origin', endpoint2.Endpoint__c);
            landingPage.getParameters().put('SECURETOKENID', usedProp.PaypalSecureTokenID__c);
            landingPage.getParameters().put('TRANSTIME', String.valueOf(system.now()));
            landingPage.getParameters().put('RESPMSG', 'Approved');
            landingPage.getParameters().put('RESULT', '0');
            
            Test.setCurrentPage(landingPage);
            
            landingPage.getParameters().put('BILLTOFIRSTNAME', 'first');
            landingPage.getParameters().put('BILLTOLASTNAME', 'last');
            PaypalLandingCC landingController = new PaypalLandingCC();
            
            system.debug('\n\n' + landingController.getMessage() + '\n\n'); 
            landingPage.getParameters().remove('status');
                    
            system.debug('\n\n' + landingController.GetRedirectURL() + '\n\n');
            
            system.debug('\n\n' + landingController.GetRedirectURL() + '\n\n');
        }
        Test.stopTest();
    }
    //Capture Transactions
    public static testMethod void CapturePaypalPayment(){
        Profile GuestUserProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Credit Card Processing Profile'];
        
        system.debug('\n\nCurrent Profile: ' + GuestUserProfile + '\n\n');
        
        User testUser = TestDataSetupUtility.createTestUser('Test Fname', 'Test Lname', GuestUserProfile.Id);
        insert testUser;
        
        Account acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        acc.BillingCity = 'Charleston';
        acc.BillingCountry = 'United States';
        acc.BillingPostalCode = '29403';
        acc.BillingState = 'South Carolina';
        acc.BillingStreet = 'xxx';
        insert acc;
        
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opportunity', acc.Id);
        opp.StageName = 'Stage 4 - Won';
        insert opp;
        
        Apttus_Proposal__Proposal__c prop = TestDataSetupUtility.createApttusProposal(opp);
        prop.PaypalReferenceNumber__c = 'A11C7C9A8FDE';
        prop.PaypalResultCode__c = '0';
        prop.PaypalResultMessage__c = 'Approved';
        prop.PaypalSecureTokenID__c = '176266609134031722';
        //prop.PaypalTransactionTime__c = system.now();
        insert prop;
        
        Apttus_Proposal__Proposal__c usedProp = [SELECT Id, PaypalHashedId__c FROM Apttus_Proposal__Proposal__c WHERE Id = :prop.Id];
        
        WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c();
        endpoint.Endpoint__c = 'http://www.test.com';
        endpoint.Name = 'PaypalEndpoint';
        insert endpoint;
        
        IntegrationConfig__c config = new IntegrationConfig__c();
        config.Name = 'Paypal US';
        config.EndpointName__c = endpoint.Name;
        config.PaypalPartner__c = 'SF';
        config.PaypalVendor__c = 'TEST';
        config.Username__c = 'TEST';
        config.IsPaypalTest__c = true;
        config.PaypalRedirectURL__c = endpoint.Name;
        config.Password__c = 'TEST';
        insert config;
        
        Order__c order = new Order__c();
        order.Account__c = acc.Id;
        order.Opportunity__c = opp.Id;
        order.QuoteProposal__c = usedProp.Id;
        order.OrderStatus__c = 'Sent To Verification';
        order.BillingAccount__c = acc.Id;
        order.ShippingAccount__c = acc.Id;
        insert order;
        Order_Line_Item__c  oLI2 =TestDataSetupUtility.createOrderLineItem(order.id);
        insert oLI2;

        order.OrderStatus__c = 'Verified';
        update order;
        
        Case orderCase = new Case();
        orderCase.Order__c = order.Id;
        orderCase.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Case', 'Product Implementation');
        insert orderCase;
        
        map<Id, Case> mapParam = new map<Id, Case>();
        mapParam.put(orderCase.Id, orderCase);
        
        PaypalModel.PaypalCaptureTransaction(new Case[]{new Case(Id = orderCase.Id, Order__c = order.Id, Status = 'Closed', RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Case', 'Product Implementation'))}, mapParam);
    }
    
    //Capture Transactions
    public static testMethod void testInvoices(){
        Profile GuestUserProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Credit Card Processing Profile'];
        
        system.debug('\n\nCurrent Profile: ' + GuestUserProfile + '\n\n');
        
        User testUser = TestDataSetupUtility.createTestUser('Test Fname', 'Test Lname', GuestUserProfile.Id);
        insert testUser;
        
        Account acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        insert acc;
        
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opportunity', acc.Id);
        opp.StageName = 'Stage 4 - Won';
        insert opp;
        
        Apttus_Proposal__Proposal__c prop = TestDataSetupUtility.createApttusProposal(opp);
        Apttus_Proposal__Proposal__c prop2 = TestDataSetupUtility.createApttusProposal(opp);
        prop2.AvalaraResponseCode__c = 'Success';
        insert new List<Apttus_Proposal__Proposal__c>{prop,prop2};
        
        Apttus_Proposal__Proposal__c usedProp = [SELECT Id, PaypalHashedId__c FROM Apttus_Proposal__Proposal__c WHERE Id = :prop.Id];
        
        WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c();
        endpoint.Endpoint__c = 'http://www.test.com';
        endpoint.Name = 'PaypalEndpoint';
        insert endpoint;
        
        IntegrationConfig__c config = new IntegrationConfig__c();
        config.Name = 'Paypal US';
        config.EndpointName__c = endpoint.Name;
        config.PaypalPartner__c = 'SF';
        config.PaypalVendor__c = 'TEST';
        config.Username__c = 'TEST';
        config.IsPaypalTest__c = true;
        config.PaypalRedirectURL__c = endpoint.Name;
        config.Password__c = 'TEST';
        insert config;
        
        Order__c order = new Order__c();
        order.Account__c = acc.Id;
        order.Opportunity__c = opp.Id;
        order.QuoteProposal__c = usedProp.Id;
        order.OrderStatus__c = 'Sent To Verification';
        order.BillingAccount__c = acc.Id;
        order.ShippingAccount__c = acc.Id;
        insert order;
        Order_Line_Item__c  oLI1 =TestDataSetupUtility.createOrderLineItem(order.id);
        insert oLI1;        
        
        order.OrderStatus__c = 'Verified';
        update order;
        
        Invoices__c invoice = new Invoices__c();
        invoice.Order__c = order.Id;
        insert invoice;
        System.runAs(testUser){
            Test.startTest();
            
            system.assertNotEquals(null,usedProp.PaypalHashedId__c);
            PageReference landingPage = Page.PaypalLanding;
            Test.setCurrentPage(landingPage);
            landingPage.getParameters().put('recordID', usedProp.PaypalHashedId__c); 
            landingPage.getParameters().put('TRANSTIME', String.valueOf(system.now()));
            landingPage.getParameters().put('IS_INVOICE', 'true');
            landingPage.getParameters().put('USER1', invoice.Id);
            PaypalLandingCC landingController = new PaypalLandingCC();
            landingController.init();
            system.debug('\n\n' + landingController.getMessage() + '\n\n');         
            system.debug('\n\n' + landingController.GetRedirectURL() + '\n\n');
            landingPage.getParameters().put('status', 'success');
              landingController = new PaypalLandingCC();
            landingController.init();
           system.debug('\n\n' + landingController.getMessage() + '\n\n');         
            system.debug('\n\n' + landingController.GetRedirectURL() + '\n\n');
            Test.stopTest();
        }
    }
    
    //Refund Transactions
    public static testMethod void RefundPaypalPayment(){
        Profile GuestUserProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Credit Card Processing Profile'];
        
        system.debug('\n\nCurrent Profile: ' + GuestUserProfile + '\n\n');
        
        User testUser = TestDataSetupUtility.createTestUser('Test Fname', 'Test Lname', GuestUserProfile.Id);
        insert testUser;
        
        Account acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        acc.BillingCity = 'Charleston';
        acc.BillingCountry = 'United States';
        acc.BillingPostalCode = '29403';
        acc.BillingState = 'South Carolina';
        acc.BillingStreet = 'xxx';
        insert acc;
        
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opportunity', acc.Id);
        opp.StageName = 'Stage 4 - Won';
        insert opp;
        
        Apttus_Proposal__Proposal__c prop = TestDataSetupUtility.createApttusProposal(opp);
        prop.PaypalReferenceNumber__c = 'A11C7C9A8FDE';
        prop.PaypalResultCode__c = '0';
        prop.PaypalResultMessage__c = 'Approved';
        prop.PaypalSecureTokenID__c = '176266609134031722';
        prop.PaypalTransactionTime__c = system.now();
        insert prop;
        
        Apttus_Proposal__Proposal__c usedProp = [SELECT Id, PaypalHashedId__c FROM Apttus_Proposal__Proposal__c WHERE Id = :prop.Id];
        
        WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c();
        endpoint.Endpoint__c = 'http://www.test.com';
        endpoint.Name = 'PaypalEndpoint';
        insert endpoint;
        
        IntegrationConfig__c config = new IntegrationConfig__c();
        config.Name = 'Paypal US';
        config.EndpointName__c = endpoint.Name;
        config.PaypalPartner__c = 'SF';
        config.PaypalVendor__c = 'TEST';
        config.Username__c = 'TEST';
        config.IsPaypalTest__c = true;
        config.PaypalRedirectURL__c = endpoint.Name;
        config.Password__c = 'TEST';
        insert config;
        
        Order__c order = new Order__c();
        order.Account__c = acc.Id;
        order.Opportunity__c = opp.Id;
        order.QuoteProposal__c = usedProp.Id;
        order.OrderStatus__c = 'Sent To Verification';
        order.PaypalCaptureResultCode__c = '0';
        order.PaypalCaptureResultMessage__c = 'Approved';
        order.BillingAccount__c = acc.Id;
        order.ShippingAccount__c = acc.Id;
        insert order;
        
        Test.startTest();
            PaypalModel.refundPaypalTransaction(order.Id);
        Test.stopTest();
    }  
}