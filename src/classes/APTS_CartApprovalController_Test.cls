@isTest
public class APTS_CartApprovalController_Test {
    // @author: Aakash Khatri
    static User manager, testUser;
    static Account account;
    static Apttus_Proposal__Proposal__c proposal_n;
    static testMethod void testCartApprovalController() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        insert manager;
        testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        testUser.Discount_Threshold__c  = 10.0;
        insert testuser;
        
        System.runAs(testUser){
            /*
            //Create Payment Details
            Payment_Details__c payDet = TestDataSetupUtility.createTestPaymentDetails('123TestOrganization', 'frequency', 'paymentTerm');
            payDet.Default_for_Partner_Proposal__c = false;
            payDet.Active__c = true;
            paydet.Non_Standard_Payment__c = false;
            system.debug('***********************Insert Payment Detail***************');
            insert payDet;
        
            //Create Entity ID
            RegistrationNumber__c entID = New RegistrationNumber__c();
            entID.PaymentDetails__c = payDet.Id;
            entId.Organization__c = '123TestOrganization';
            system.debug('***********************Insert Entity ID***************');
            insert entID;
            */
            // Create test account
            account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
            system.debug('after account ' + account);
            //account.Registration__c = entID.Id;
           
            //System.debug('Xdebug__ account entityid: ' + account.Registration__c);
            insert account;
            
            //entID.PrimaryBillingAccount__c = account.Id;
            //update entId;
            /*
            // create contact
            Contact contact1 = new Contact();
            contact1.Account = account;
            System.debug('Xdebug__contact account id: ' + contact1.Account.Id);
            contact1.LastName = 'something'; 
            contact1.EntityID__c = entID.Id;
            insert contact1;
            
            account.PrimaryBillingContact__c = contact1.Id;
            update account;
            */
            //create Opportunity
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', account.Id);
            opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'GCS Opportunity');
            insert opp;
            
            //Create product2
            Product2 product = TestDataSetupUtility.createProduct('Test product5', false); 
            product.Convert_From__c = true;
            product.Eligible_Selling_Country__c = 'Austria';
            product.Quote_Pricing_Channel__c = 'Agency';
            insert product;
            
            //Create price list
            Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
            insert priceList; 
            
            Apttus_Config2__PriceListItem__c pli = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 10, Apttus_Config2__ProductId__c = product.Id, Apttus_Config2__ChargeType__c = 'Standard Price');
            insert pli;
            
            
            
            
            /*
            //create proposal
            proposal_n = TestDataSetupUtility.createProposal('Test Proposal', account.Id, opp.Id, 'Accepted Online', false);
            proposal_n.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Apttus_Proposal__Proposal__c', 'Proposal');
            proposal_n.Apttus_QPConfig__PriceListId__c = priceList.id; 
            proposal_n.Language__c = 'English';
            proposal_n.APTS_Quote_Type__c = 'Product Conversion';
            system.debug('*****************:proposal ' + proposal_n.Language__c);
            
            insert proposal_n;
            
            */
            // create proposal
            proposal_n = new Apttus_Proposal__Proposal__c();
            proposal_n.Apttus_Proposal__Account__c = account.Id;
            proposal_n.Apttus_Proposal__Opportunity__c = opp.Id;
            proposal_n.Language__c = 'English';
            proposal_n.Selling_Country__c = 'Austria';
            proposal_n.Apttus_QPConfig__PriceListId__c = priceList.Id;
            proposal_n.BillingStreet__c = 'something';
            proposal_n.BillingCity__c = 'something';
            proposal_n.BillingCountry__c = 'Algeria';
            proposal_n.BillingZipPostalCode__c = 'something';
            proposal_n.QuoteStatus__c = 'Accepted Online';
            insert proposal_n;
            
            Apttus_Config2__ProductConfiguration__c config = TestDataSetupUtility.createTestProductConfig(proposal_n,account,priceList);
            config.Apttus_Config2__Status__c = 'Finalized';
            insert config;
            //System.debug('config:'+config);
        
            Apttus_Config2__LineItem__c aptusLineItem = TestDataSetupUtility.createLineItemApttus(config.Id);
            aptusLineItem.Apttus_Config2__StartDate__c=System.today();
            aptusLineItem.Apttus_Config2__EndDate__c=System.today()+60;
            aptusLineItem.Apttus_Config2__LineStatus__c = 'Converted';
            aptusLineItem.Apttus_Config2__LineType__c = 'Product/Service';            
            aptusLineItem.Apttus_Config2__IsPrimaryLine__c = true;
            aptusLineItem.Apttus_Config2__Comments__c='test';
            aptusLineItem.Apttus_Config2__ConfigurationId__c = config.Id;
            
            insert aptusLineItem;


            Apttus_Proposal__Proposal_Line_Item__c propLineItem2 = New Apttus_Proposal__Proposal_Line_Item__c();
            propLineItem2.Apttus_QPConfig__ConfigurationId__c = config.Id;
            propLineItem2.Apttus_Proposal__Product__c=product.Id;
            propLineItem2.Apttus_QPConfig__NetPrice__c=3400;
            propLineItem2.Apttus_QPConfig__BaseExtendedPrice__c=2040;
            propLineItem2.Apttus_QPConfig__DerivedFromId__c=aptusLineItem.Id;
            propLineItem2.Apttus_Proposal__Proposal__c =proposal_n.Id;
            //propLineItem2.Proposal_Locked__c = proposal_n.ID;
            insert propLineItem2;
            propLineItem2 = [select Id,Apttus_QPConfig__ConfigurationId__c, Quote_Language__c,Configuration_Status__c, ProposalLineItemId__c,Apttus_Proposal__Product__c,Apttus_QPConfig__NetPrice__c,
            Apttus_QPConfig__BaseExtendedPrice__c, Apttus_QPConfig__DerivedFromId__c,Apttus_QPConfig__StartDate__c,Apttus_QPConfig__EndDate__c,
            Apttus_QPConfig__Comments__c,
            Apttus_Proposal__Proposal__c from Apttus_Proposal__Proposal_Line_Item__c where Id = :propLineItem2.Id];
            
            Apttus_Proposal__Proposal_Line_Item__c propLineItem3 = New Apttus_Proposal__Proposal_Line_Item__c();
            propLineItem3.Apttus_QPConfig__ConfigurationId__c = config.Id;
            propLineItem3.Apttus_Proposal__Product__c=product.Id;
            propLineItem3.Apttus_QPConfig__NetPrice__c=4000;
            propLineItem3.Apttus_QPConfig__BaseExtendedPrice__c=2500;
            propLineItem3.Apttus_QPConfig__DerivedFromId__c=aptusLineItem.Id;
            propLineItem3.Apttus_Proposal__Proposal__c =proposal_n.Id;
            //propLineItem3.Proposal_Locked__c = proposal_n.ID;
            insert propLineItem3;
            propLineItem3 = [select Id,Apttus_QPConfig__ConfigurationId__c, Quote_Language__c,Configuration_Status__c, ProposalLineItemId__c,Apttus_Proposal__Product__c,Apttus_QPConfig__NetPrice__c,
            Apttus_QPConfig__BaseExtendedPrice__c, Apttus_QPConfig__DerivedFromId__c,Apttus_QPConfig__StartDate__c,Apttus_QPConfig__EndDate__c,
            Apttus_QPConfig__Comments__c,
            Apttus_Proposal__Proposal__c from Apttus_Proposal__Proposal_Line_Item__c where Id = :propLineItem3.Id];
            
            Apttus_Proposal__Proposal_Line_Item__c propLineItem4 = New Apttus_Proposal__Proposal_Line_Item__c();
            propLineItem4.Apttus_QPConfig__ConfigurationId__c = config.Id;
            propLineItem4.Apttus_Proposal__Product__c=product.Id;
            propLineItem4.Apttus_QPConfig__NetPrice__c=5000;
            propLineItem4.Apttus_QPConfig__BaseExtendedPrice__c=2600;
            propLineItem4.Apttus_QPConfig__DerivedFromId__c=aptusLineItem.Id;
            propLineItem4.Apttus_Proposal__Proposal__c =proposal_n.Id;
            insert propLineItem4;
            propLineItem4 = [select Id,Apttus_QPConfig__ConfigurationId__c, Quote_Language__c,Configuration_Status__c, ProposalLineItemId__c,Apttus_Proposal__Product__c,Apttus_QPConfig__NetPrice__c,
            Apttus_QPConfig__BaseExtendedPrice__c, Apttus_QPConfig__DerivedFromId__c,Apttus_QPConfig__StartDate__c,Apttus_QPConfig__EndDate__c,
            Apttus_QPConfig__Comments__c,
            Apttus_Proposal__Proposal__c from Apttus_Proposal__Proposal_Line_Item__c where Id = :propLineItem4.Id];
            
            
            system.debug('*****************:propLineItem2 ' + propLineItem2.Quote_Language__c + ' ********* ' + propLineItem2.ProposalLineItemId__c);
            system.debug('*****************:propLineItem3 ' + propLineItem3.Quote_Language__c + ' ********* ' + propLineItem3.ProposalLineItemId__c);
            update propLineItem2;
            update propLineItem3;
            Apttus_Proposal__Proposal_Line_Item__c[] listLineItem2 = new Apttus_Proposal__Proposal_Line_Item__c[]{propLineItem2, propLineItem3,propLineItem4};
          
            
            id IdAMendmentsRT;
        if( Apttus__APTS_Agreement__c.SObjectType.getDescribe().getRecordTypeInfosByName ().get('STTLMT') != null )
        {
            IdAMendmentsRT = Apttus__APTS_Agreement__c.SObjectType.getDescribe().getRecordTypeInfosByName ().get('STTLMT'). getRecordTypeId();
        }
 
        Apttus__APTS_Agreement__c agmt= new Apttus__APTS_Agreement__c();
        agmt.Apttus__Account__c = account.Id;
        agmt.Name = 'Test Agreement';
        
        insert agmt;
        ApexPages.currentPage().getParameters().get('cartId');
        Apttus__Agreement_Clause__c oClass = new Apttus__Agreement_Clause__c(Apttus__Agreement__c=agmt.Id);
        Apttus__Agreement_Clause__c oClass1= new Apttus__Agreement_Clause__c(Apttus__Agreement__c=agmt.Id);
        Apttus__Agreement_Clause__c oClass2= new Apttus__Agreement_Clause__c(Apttus__Agreement__c=agmt.Id);
        List<Apttus__Agreement_Clause__c> agreementClauseList=new List<Apttus__Agreement_Clause__c>();
        agreementClauseList.add(oClass);
        agreementClauseList.add(oClass1);
        agreementClauseList.add(oClass2);
        insert agreementClauseList;
 
        
        
             
        testUser = Apttus_Approval.TestSupport.getUserSO(testUser.Id);
        
        Apttus_Approval__Approval_Process__c processSO  = new Apttus_Approval__Approval_Process__c();
        processSo.Apttus_Approval__Process_Name__c = 'New Aproval Process';
        processSO.Apttus_Approval__Object_Name__c = 'Apttus__APTS_Agreement__c';
        processSO.Apttus_Approval__Object_Label__c = 'Agreement';
        insert processSO;
        
        Apttus_Approval__ApprovalProcessInstance__c api = new Apttus_Approval__ApprovalProcessInstance__c();
        api.Apttus_Approval__BusinessObjectId__c = 'Apttus__APTS_Agreement__c';
        api.Name = 'Test Approval Process Instance';
        api.Apttus_Approval__ApprovalProcessId__c = processSO.Id;
        insert api;
        
        Apttus_Approval__Approval_Request__c requestSO = Apttus_Approval.TestSupport.createAssignmentRequest(testUser,
                                                                                                             processSO.Id,
                                                                                                             agmt.Id,
                                                                                                           'Test Agreement;');
        requestSO.Apttus_Approval__ProcessInstanceId__c = api.Id;
        requestSO.Apttus_Approval__Approval_Status__c = 'Cancelled';
        upsert requestSO;
              
            APTS_CartApprovalController controller  = new APTS_CartApprovalController();
            controller.cartId = config.Id;
            controller.RequestId = requestSO.Id;
            controller.ProposalID = proposal_n.Id;
            
            //String temp = controller.getinstanceurl();
            boolean showflag = controller.getshowflag();
            boolean notifyflag = controller.getNotifyflag();
            boolean productConversion = controller.getProductConversion();
            List<APTS_CartApprovalController.wrapperConfigLineItems> listNewLineItem = controller.GetListNewLineItem();
            List<Apttus_Proposal__Proposal_Line_Item__c> ListOfProposalLineItems = controller.GetListOfProposalLineItems();
            Account ac_temp = controller.getAccountObj();
            Apttus_Approval__Approval_Request__c ar_temp = controller.getApprovalRequestObj();
            controller.ListOfTermApprovalLineItems =  controller.GetApprovalHistory();
            List<APTS_CartApprovalController.wrapperConfigLineItems>  temp_list2 = controller.GetListExistingLineItem();
            try {
                String tempString = controller.getinstanceurl();
            }catch(Exception e) {
                System.debug('Error in getinstanceurl method : ' + e );
            }

        } 
    }
    
    static testMethod void testCartApprovalController2() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
        insert manager;
        testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
        testUser.ManagerId = manager.Id;
        testUser.Discount_Threshold__c  = 10.0;
        insert testuser;
        
        System.runAs(testUser){
            
            //Create Payment Details
            Payment_Details__c payDet = TestDataSetupUtility.createTestPaymentDetails('123TestOrganization', 'frequency', 'paymentTerm');
            payDet.Default_for_Partner_Proposal__c = false;
            payDet.Active__c = true;
            paydet.Non_Standard_Payment__c = false;
            system.debug('***********************Insert Payment Detail***************');
            insert payDet;
        
            //Create Entity ID
            RegistrationNumber__c entID = New RegistrationNumber__c();
            entID.PaymentDetails__c = payDet.Id;
            entId.Organization__c = '123TestOrganization';
            system.debug('***********************Insert Entity ID***************');
            insert entID;
            
            // Create test account
            account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
            system.debug('after account ' + account);
            account.Registration__c = null;
            //account.Registration__c = entId.Id;
            insert account;
            
            //account = [select id,X15DigitAccountId__c, Registration__c,Name ,ShippingCity, ShippingPostalCode,
           // ShippingCountry, ShippingState, ShippingStreet, BillingStreet,BillingCity, BillingCountry,BillingState,BillingPostalCode,
            //Phone,RecordTypeId, CreditStatus__c from Account];
            
            //update account; 
            // Create contact
            Contact con = new Contact();
            con.AccountId = account.Id;
            
            con.LastName = 'Some_Last_Name';
            con.FirstName = 'Some_First_Name';
            con.Email = 'some@email.com';
            insert con;
            
            //con = [select id, AccountId, LastName, FirstName, Email, Account_ID_Text__c from Contact]; 
            //update con;
            
            //create Opportunity
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', account.Id);
            opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'GCS Opportunity');
            insert opp;
            
            //Create product2
            Product2 product = TestDataSetupUtility.createProduct('Test product5', false); 
            product.Convert_From__c = true;
            product.Eligible_Selling_Country_New__c = 'Austria';
            product.Pricing_Channel__c = 'Agency';
            insert product;
            
            Product2 product1 = TestDataSetupUtility.createProduct('Test Product2', false);
            product.Convert_From__c = true;
            insert product1;
            
            //Create price list
            Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
            insert priceList; 
            
            Apttus_Config2__PriceListItem__c pli = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 10, Apttus_Config2__ProductId__c = product.Id, Apttus_Config2__ChargeType__c = 'Standard Price');
            insert pli;
            
            /*
            //create proposal
            proposal_n = TestDataSetupUtility.createProposal('Test Proposal', account.Id, opp.Id, 'Accepted Online', false);
            proposal_n.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Apttus_Proposal__Proposal__c', 'Proposal');
            proposal_n.Apttus_QPConfig__PriceListId__c = priceList.id; 
            proposal_n.Language__c = 'English';
            proposal_n.APTS_Quote_Type__c = 'AdComms';
            system.debug('*****************:proposal ' + proposal_n.Language__c);
            
            
            proposal_n.Entity_ID__c = null;
            proposal_n.BillingAccount__c = account.Id;
            proposal_n.BillContact__c = con.ID;
            
            //proposal_n.BillContact__r.Account = account;
            //proposal_n.BillContact__r.Account.Registration__c = entId.Id;
            
            System.debug('*123#* Contact: ' + con.Account.Registration__c + '  +' + proposal_n.BillContact__r.Account.Registration__c + ' + ' + proposal_n.Entity_ID__c);
            
            
            System.debug('*123#* Bill Contact: ' + proposal_n.BillContact__r.AccountId + ' +' + account.AccountID__c +' +' + account.Id);
            //System.debug('*123#*Bill Contact Account Entity ID : ' + proposal_n.BillContact__r.Account.Registration__c);
            System.debug('*123#*Should be equal to Quote/Proposal Entity Id : ' + proposal_n.Entity_ID__c);
            //System.debug('*123#*Bill Contact Account ID : ' + proposal_n.BillContact__r.Account.Id);
            //System.debug('*123#*Should be equal to Quote/Proposal Account ID : ' + proposal_n.BillingAccount__r.Id);
            //System.debug('*123#* Quote/Proposal entity id: ' + proposal_n.Entity_ID__c);
            insert proposal_n;
            
            System.debug('*123#* Contact: ' + con);
            System.debug('*123#* Bill Contact: ' + proposal_n.BillContact__r.AccountId );
            System.debug('*123#*Bill Contact Account Entity ID : ' + proposal_n.BillContact__r.Account.Registration__c);
            System.debug('*123#*Should be equal to Quote/Proposal Entity Id : ' + proposal_n.Entity_ID__c);
            System.debug('*123#*Bill Contact Account ID : ' + proposal_n.BillContact__r.Account.Id);
            System.debug('*123#*Should be equal to Quote/Proposal Account ID : ' + proposal_n.BillingAccount__r.Id);
            System.debug('*123#* Quote/Proposal entity id: ' + proposal_n.Entity_ID__c);
            */
            
            // create proposal
            proposal_n = new Apttus_Proposal__Proposal__c();
            proposal_n.Apttus_Proposal__Account__c = account.Id;
            proposal_n.Apttus_Proposal__Opportunity__c = opp.Id;
            proposal_n.Language__c = 'English';
            proposal_n.Selling_Country__c = 'Austria';
            proposal_n.Apttus_QPConfig__PriceListId__c = priceList.Id;
            proposal_n.BillingStreet__c = 'something';
            proposal_n.BillingCity__c = 'something';
            proposal_n.BillingCountry__c = 'Algeria';
            proposal_n.BillingZipPostalCode__c = 'something';
            proposal_n.QuoteStatus__c = 'Accepted Online';
            insert proposal_n;
            
            
        
            Apttus_Config2__ProductConfiguration__c config = TestDataSetupUtility.createTestProductConfig(proposal_n,account,priceList);
            config.Apttus_Config2__Status__c = 'Finalized';
            insert config;
            //System.debug('config:'+config);
        
            Apttus_Config2__LineItem__c aptusLineItem = TestDataSetupUtility.createLineItemApttus(config.Id);
            aptusLineItem.Apttus_Config2__StartDate__c=System.today();
            aptusLineItem.Apttus_Config2__EndDate__c=System.today()+60;
            aptusLineItem.Apttus_Config2__LineStatus__c = 'New';
            aptusLineItem.Apttus_Config2__LineType__c = 'Product/Service';
            aptusLineItem.Apttus_Config2__IsPrimaryLine__c = true;
            aptusLineItem.Apttus_Config2__Comments__c='test';
            aptusLineItem.Apttus_Config2__ProductId__c = product.Id;
            insert aptusLineItem;

            Apttus_Proposal__Proposal_Line_Item__c propLineItem2 = New Apttus_Proposal__Proposal_Line_Item__c();
            
            propLineItem2.Apttus_QPConfig__ConfigurationId__c = config.Id;
            propLineItem2.Apttus_Proposal__Product__c=product.Id;
            propLineItem2.Apttus_QPConfig__NetPrice__c=3400;
            propLineItem2.Apttus_QPConfig__BaseExtendedPrice__c=2040;
            propLineItem2.Apttus_QPConfig__DerivedFromId__c=aptusLineItem.Id;
            propLineItem2.Apttus_Proposal__Proposal__c =proposal_n.Id;
            //propLineItem2.Proposal_Locked__c = proposal_n.ID;
            insert propLineItem2;
            propLineItem2 = [select Id,Apttus_QPConfig__ConfigurationId__c, Quote_Language__c,Configuration_Status__c, ProposalLineItemId__c,Apttus_Proposal__Product__c,Apttus_QPConfig__NetPrice__c,
            Apttus_QPConfig__BaseExtendedPrice__c, Apttus_QPConfig__DerivedFromId__c,Apttus_QPConfig__StartDate__c,Apttus_QPConfig__EndDate__c,
            Apttus_QPConfig__Comments__c,
            Apttus_Proposal__Proposal__c from Apttus_Proposal__Proposal_Line_Item__c where Id = :propLineItem2.Id];
            
            Apttus_Proposal__Proposal_Line_Item__c propLineItem3 = New Apttus_Proposal__Proposal_Line_Item__c();
            propLineItem3.Apttus_QPConfig__ConfigurationId__c = config.Id;
            propLineItem3.Apttus_Proposal__Product__c=product1.Id;
            propLineItem3.Apttus_QPConfig__NetPrice__c=4000;
            propLineItem3.Apttus_QPConfig__BaseExtendedPrice__c=2500;
            propLineItem3.Apttus_QPConfig__DerivedFromId__c=aptusLineItem.Id;
            propLineItem3.Apttus_Proposal__Proposal__c =proposal_n.Id;
            //propLineItem3.Proposal_Locked__c = proposal_n.ID;
            insert propLineItem3;
            propLineItem3 = [select Id,Apttus_QPConfig__ConfigurationId__c, Quote_Language__c,Configuration_Status__c, ProposalLineItemId__c,Apttus_Proposal__Product__c,Apttus_QPConfig__NetPrice__c,
            Apttus_QPConfig__BaseExtendedPrice__c, Apttus_QPConfig__DerivedFromId__c,Apttus_QPConfig__StartDate__c,Apttus_QPConfig__EndDate__c,
            Apttus_QPConfig__Comments__c,
            Apttus_Proposal__Proposal__c from Apttus_Proposal__Proposal_Line_Item__c where Id = :propLineItem3.Id];
            
            Apttus_Proposal__Proposal_Line_Item__c propLineItem4 = New Apttus_Proposal__Proposal_Line_Item__c();
            propLineItem4.Apttus_QPConfig__ConfigurationId__c = config.Id;
            propLineItem4.Apttus_Proposal__Product__c=product.Id;
            propLineItem4.Apttus_QPConfig__NetPrice__c=5000;
            propLineItem4.Apttus_QPConfig__BaseExtendedPrice__c=2600;
            propLineItem4.Apttus_QPConfig__DerivedFromId__c=aptusLineItem.Id;
            propLineItem4.Apttus_Proposal__Proposal__c =proposal_n.Id;
            insert propLineItem4;
            propLineItem4 = [select Id,Apttus_QPConfig__ConfigurationId__c, Quote_Language__c,Configuration_Status__c, ProposalLineItemId__c,Apttus_Proposal__Product__c,Apttus_QPConfig__NetPrice__c,
            Apttus_QPConfig__BaseExtendedPrice__c, Apttus_QPConfig__DerivedFromId__c,Apttus_QPConfig__StartDate__c,Apttus_QPConfig__EndDate__c,
            Apttus_QPConfig__Comments__c,
            Apttus_Proposal__Proposal__c from Apttus_Proposal__Proposal_Line_Item__c where Id = :propLineItem4.Id];
            
            
            system.debug('*****************:propLineItem2 ' + propLineItem2.Quote_Language__c + ' ********* ' + propLineItem2.ProposalLineItemId__c);
            system.debug('*****************:propLineItem3 ' + propLineItem3.Quote_Language__c + ' ********* ' + propLineItem3.ProposalLineItemId__c);
            update propLineItem2;
            update propLineItem3;
            Apttus_Proposal__Proposal_Line_Item__c[] listLineItem2 = new Apttus_Proposal__Proposal_Line_Item__c[]{propLineItem2, propLineItem3,propLineItem4};
          
            
            id IdAMendmentsRT;
        if( Apttus__APTS_Agreement__c.SObjectType.getDescribe().getRecordTypeInfosByName ().get('STTLMT') != null )
        {
            IdAMendmentsRT = Apttus__APTS_Agreement__c.SObjectType.getDescribe().getRecordTypeInfosByName ().get('STTLMT'). getRecordTypeId();
        }
 
        Apttus__APTS_Agreement__c agmt= new Apttus__APTS_Agreement__c();
        agmt.Apttus__Account__c = account.Id;
        agmt.Name = 'Test Agreement';
        
        insert agmt;
        ApexPages.currentPage().getParameters().get('cartId');
        Apttus__Agreement_Clause__c oClass = new Apttus__Agreement_Clause__c(Apttus__Agreement__c=agmt.Id);
        Apttus__Agreement_Clause__c oClass1= new Apttus__Agreement_Clause__c(Apttus__Agreement__c=agmt.Id);
        Apttus__Agreement_Clause__c oClass2= new Apttus__Agreement_Clause__c(Apttus__Agreement__c=agmt.Id);
        List<Apttus__Agreement_Clause__c> agreementClauseList=new List<Apttus__Agreement_Clause__c>();
        agreementClauseList.add(oClass);
        agreementClauseList.add(oClass1);
        agreementClauseList.add(oClass2);
        insert agreementClauseList;
 
        
             
        testUser = Apttus_Approval.TestSupport.getUserSO(testUser.Id);
        
        Apttus_Approval__Approval_Process__c processSO  = new Apttus_Approval__Approval_Process__c();
        processSo.Apttus_Approval__Process_Name__c = 'New Aproval Process';
        processSO.Apttus_Approval__Object_Name__c = 'Apttus__APTS_Agreement__c';
        processSO.Apttus_Approval__Object_Label__c = 'Agreement';
        insert processSO;
        
        Apttus_Approval__ApprovalProcessInstance__c api = new Apttus_Approval__ApprovalProcessInstance__c();
        api.Apttus_Approval__BusinessObjectId__c = 'Apttus__APTS_Agreement__c';
        api.Name = 'Test Approval Process Instance';
        api.Apttus_Approval__ApprovalProcessId__c = processSO.Id;
        insert api;
        
        Apttus_Approval__Approval_Request__c requestSO = Apttus_Approval.TestSupport.createAssignmentRequest(testUser,
                                                                                                             processSO.Id,
                                                                                                             agmt.Id,
                                                                                                           'Test Agreement;');
        requestSO.Apttus_Approval__ProcessInstanceId__c = api.Id;
        requestSO.Apttus_Approval__Approval_Status__c = 'Cancelled';
        upsert requestSO;
            
        Apttus_Config2__ProductAttributeGroup__c aptusGroup = TestDataSetupUtility.createGroup('TestGroup');
        insert aptusGroup;
    
        Apttus_Config2__ProductAttributeGroupMember__c aptusGrpMember = TestDataSetupUtility.createProductGroupMember('TestGroupMember' , aptusGroup.Id,product.Id);
        insert aptusGrpMember;     
            
        Apttus_Config2__ProductAttribute__c prodAttr = new Apttus_Config2__ProductAttribute__c(Apttus_Config2__AttributeGroupId__c=aptusGroup.Id,Apttus_Config2__Field__c='CurrencyIsoCode',Apttus_Config2__Sequence__c=6);
        prodAttr.Show_on_Report__c = true;
        List<Apttus_Config2__ProductAttribute__c> listProdAttr = new List<Apttus_Config2__ProductAttribute__c>{prodAttr};
        insert listProdAttr;
            
        Apttus_Config2__ProductAttributeValue__c pav = new Apttus_Config2__ProductAttributeValue__c();
        pav.Apttus_Config2__LineItemId__c = aptusLineItem.ID;
        pav.CurrencyIsoCode = 'USD';
        pav.Product_Type__c = 'Sourcing Services-GL';
        insert pav;
            
            APTS_CartApprovalController controller  = new APTS_CartApprovalController();
            controller.cartId = config.Id;
            controller.RequestId = requestSO.Id;
            controller.ProposalID = proposal_n.Id;
            
            //String temp = controller.getinstanceurl();
            boolean showflag = controller.getshowflag();
            boolean notifyflag = controller.getNotifyflag();
            boolean productConversion = controller.getProductConversion();
            List<APTS_CartApprovalController.wrapperConfigLineItems> listNewLineItem = controller.GetListNewLineItem();
            List<Apttus_Proposal__Proposal_Line_Item__c> ListOfProposalLineItems = controller.GetListOfProposalLineItems();
            Account ac_temp = controller.getAccountObj();
            Apttus_Approval__Approval_Request__c ar_temp = controller.getApprovalRequestObj();
            controller.ListOfTermApprovalLineItems =  controller.GetApprovalHistory();
            List<APTS_CartApprovalController.wrapperConfigLineItems>  temp_list2 = controller.GetListExistingLineItem();
            try {
                String tempString = controller.getinstanceurl();
            }catch(Exception e) {
                System.debug('Error in getinstanceurl method : ' + e );
            }

        } 
    }
}