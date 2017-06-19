/**
 * @author Dino Brinas
 * @date 12.23.14
 * @description Test Class for AddContactController.
 */
@isTest
private class AddContactControllerTest {
  //declare static variables
    static Personal_Settings__c personalSettings;
    static Apttus_Proposal__Proposal_Line_Item__c proLineItem;
    static Apttus_Proposal__Proposal__c prop;
    static Account acc;
    static Opportunity opp;
    /** 
     * @author Andre Calimlim
     * @date 12.23.14
     * @description static method to create test data records
     * @param AccountName - String value for the name field of Account
     * @param setPersonalSettings - Boolean value to set the personal Settings on which triggers/Validations to run
     */
    static void createRec(Boolean setPersonalSettings){
        personalSettings = TestDataSetupUtility.buildPersonalSetting();
        if(setPersonalSettings){
            personalSettings.Trigger_Order__c = true;
            personalSettings.Trigger_Account__c = true;
            personalSettings.Trigger_Opportunity__c = true;
            personalSettings.Validation_Account__c = true;
            personalSettings.Validation_Opportunity__c = true;
        }
        insert personalSettings;
        insert TestDataSetupUtility.buildMaximumCustomerNumberSetting();
        insert TestDataSetupUtility.buildWebServiceEndpointSetting();
        insert TestDataSetupUtility.buildIntegrationConfigSetting();
        insert TestDataSetupUtility.buildCaseTriggerSetting();
        
        acc = TestDataSetupUtility.createTestAccountWithShipping('Test Account');
        insert acc;
        
        opp = TestDataSetupUtility.createTestOpportunity('Test Opp ', acc.Id);
        insert opp;

        OpportunityCompetitor__c competitor = TestDataSetupUtility.createOpportunityCompetitor(opp);
        insert competitor;
        
        prop = TestDataSetupUtility.createApttusProposal(opp);
        prop.Apttus_Proposal__Account__c = acc.Id;
        insert prop;
        
        proLineItem = TestDataSetupUtility.createProposalLineItem(prop.Id);
        insert proLineItem;
        
    }

//4/1/16  Sylvester Agyen(Appirio) - Commented out method. Actual test was already commented out. Isn't performing any additional tests
    /** 
     * @author Andre Calimlim
     * @date 12.23.14
     * @description testMethod to check that a junction record will be created for Quote Page.
     */
 /*   static testMethod void testForQuotePage(){
        createRec(true);
        Test.starttest();


        PageReference pageRef = Page.AddContacts;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('ProposalId', prop.Id);
        system.debug('pageRef >>>>' + pageRef);

        AddContactController controller = new AddContactController();
        
        //AddContactController.wrapperC wr = new AddContactController.wrapperC();
        
        controller.wc[0].conlist2.FirstName = 'Test FirstName';
        controller.wc[0].conlist2.LastName = 'Test LastName';
        controller.wc[0].conlist2.Email = 'test@cloudsherpas.com';
        controller.wc[0].conlist2.Phone = '9123456789';

        controller.SaveContact();

        /*
        List<ProductUserQuoteLine2OrderLine__c> quoteToOrder = [SELECT id, Contact_Name__r.LastName, Order_Line_Item__c from ProductUserQuoteLine2OrderLine__c 
                                                             WHERE Proposal_Line_Item__c =: controller.wc[0].conlist2.ProposalLineItem__c];
        //Test Junction record is created with no Order Line Item yet
      //  System.assertEquals(null, quoteToOrder[0].Order_Line_Item__c);
     //   System.assertEquals('Test LastName', quoteToOrder[0].Contact_Name__r.LastName);
      //  System.assertEquals(quoteToOrder.size(), 1);
        
        //Update the Opportunity to create the Order and Order Line Item
        opp.StageName='Stage 2 - Proposal';
         opp.Skip_Stage_Validation__c = true;
        update opp;
        opp.StageName='Stage 3 - Quote';
         opp.Skip_Stage_Validation__c = true;
        update opp;
        opp.OrderCreated__c = true;
        opp.StageName='Stage 4 - Won';
        opp.Skip_Stage_Validation__c = true;
        update opp;
        
        List<Order__c> orderList = [Select Id from Order__c where Opportunity__c = :opp.Id];
       // System.assert(orderList.size() > 0);
        List<Order_Line_Item__c> orderLineItemList = [Select Id from Order_Line_Item__c where Order__c = : orderList[0].Id];
       // System.assert(orderLineItemList.size() > 0);
        List<ProductUserQuoteLine2OrderLine__c> quoteToOrderAfterInsertOrder = [SELECT id, Contact_Name__r.LastName, Order_Line_Item__c from ProductUserQuoteLine2OrderLine__c 
                                                             WHERE Proposal_Line_Item__c =: proLineItem.Id];
        //Test Junction record is updated with the Order Line Item created
      //  System.assertEquals(orderLineItemList[0].Id, quoteToOrderAfterInsertOrder[0].Order_Line_Item__c);
      */
 //       Test.stoptest();        
 //  }  //Sylvester Agyen


    /** 
     * @author Andre Calimlim
     * @date 12.23.14
     * @description testMethod to check that a junction record will be created for Quote Line Item that will only have the value for the Order Line Item once the line item has been created.
     */
    static testMethod void testQuoteLineItemPage(){
        Personal_Settings__c mysettings = TestDataSetupUtility.buildPersonalSetting();
        mysettings.Trigger_Order__c = true;
            mysettings.Trigger_Account__c = false;
            mysettings.Trigger_Opportunity__c = false;
            mysettings.Validation_Account__c = false;
            mysettings.Validation_Opportunity__c = false;
        insert mysettings;
        Test.startTest();
        system.debug('testOrderSellingCountry start');
        Account slyacc = TestDataSetupUtility.createTestAccount('tom 90 test', 'North America', UserInfo.getUserId());
        slyacc.Phone = '1234009891';
        slyacc.ShippingStreet = 'gfrd S';
        slyacc.ShippingCity = 'NY';
        slyacc.ShippingPostalCode = '12345';
        slyacc.Website = 'www.mol.com';
        slyacc.Phone = '4500045344';
        slyacc.AccountStatus__c = 'Customer';
        insert slyacc;
        system.debug('testOrderSellingCountry acc' + slyacc);

        Opportunity slyopp =    TestDataSetupUtility.createTestOpportunity('nowoppsly', slyacc.id);
        slyopp.OrderCreated__c = true;
        system.debug('before test acc insert');
        insert slyopp;

         system.debug('testOrderSellingCountry opp' + slyopp);

        Contact simpleContact =        TestDataSetupUtility.createTestContact(slyopp.AccountId, 'slyFirst', 'slyLast', 'slycontact@email.com');
        simpleContact.Phone = '0009999888';
        insert simpleContact;
        system.debug('testOrderSellingCountry contact ' + simpleContact);

        Apttus_Proposal__Proposal__c slyproposal = TestDataSetupUtility.createProposal( slyacc.id, slyopp.id, 'slyCOMPANY');
        insert slyproposal;
        system.debug('testOrderSellingCountry proposal' + slyproposal);

        Apttus_Proposal__Proposal_Line_Item__c slyPLI = TestDataSetupUtility.createProposalLineItem(slyproposal.id);
        insert slyPLI;

        Order__c simpleStandardOrder = TestDataSetupUtility.createOrder(slyacc.id, simpleContact.Id);
            
            simpleStandardOrder.OrderStatus__c = 'Open';
            simpleStandardOrder.Posting_Contact__c = simpleContact.id;
            simpleStandardOrder.MAPPSentToVerificationBy2__c = Userinfo.getUserId();
            simpleStandardOrder.MAPPBillingAccount__c = slyacc.Id;
            simpleStandardOrder.MAPPBillingContact__c = simpleContact.id;
            simpleStandardOrder.MAPP_Archive_Posting_Contact__c = simpleContact.id;
        insert simpleStandardOrder;

        Product2 simpleProduct = TestDataSetupUtility.createProduct('test', false);
            simpleProduct.Product_Line__c = 'Job Accessories--Inventory';
            simpleProduct.Family= 'Resume';
            simpleProduct.ProductCode = 'QUOTE BUNDLE';
            simpleProduct.APTPS_Rev_Share__c  = 10;
        insert simpleProduct;
        Order_Line_Item__c simpleLI = TestDataSetupUtility.createOrderLineItem(simpleStandardOrder.Id);
            simpleLI.Product__c = simpleProduct.Id;
            simpleLI.startDate__c = Date.newInstance(2015, 1, 1);
            simpleLI.endDate__c = Date.newInstance(2015, 2, 1);
        insert simpleLI;

        simpleContact.ProposalLineItem__c = slyPLI.id;
        update simpleContact;

        ProductUserQuoteLine2OrderLine__c junctionObj = TestDataSetupUtility.createJunctionObjectWithOrderItem(slyproposal.Id,slyPLI.id,simpleLI.id);
        insert junctionObj;

        PageReference pageRef = Page.AddContacts;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('ProposalId', slyPLI.Id);
        system.debug('pageRef >>>>' + pageRef);

         AddContactController controller = new AddContactController();
        AddContactController.wrapperC wr = new AddContactController.wrapperC();
        wr.conlist2 = simpleContact;
        wr.quoteItemId = slyPLI.id;
        system.debug('QUOTELINEITEM 1 WR  '+wr);
        List<AddContactController.wrapperC> wrapperList = new List<AddContactController.wrapperC>();
        wrapperList.add(wr);
        system.debug('QUOTELINEITEMIDLIST1  '+wrapperList);
        controller.wc = wrapperList;

        controller.SaveContact();

        List<ProductUserQuoteLine2OrderLine__c> quoteToOrder = [SELECT id, Contact_Name__r.LastName, Order_Line_Item__c from ProductUserQuoteLine2OrderLine__c 
                                                             WHERE Proposal_Line_Item__c =: slyPLI.Id];
        //Test Junction record is created with no Order Line Item yet
        //System.assertEquals(null, quoteToOrder[0].Order_Line_Item__c);
        //System.assertEquals('Test LastName', quoteToOrder[0].Contact_Name__r.LastName);
        System.assertEquals(quoteToOrder.size(), 2);
        
        
        Test.stoptest();        
    }
    /** 
     * @author Andre Calimlim
     * @date 12.23.14
     * @description testMethod to create a junction record based from junction record that has been already created.
     */
    static testMethod void testForOrderLineItemPage(){
        Personal_Settings__c mysettings = TestDataSetupUtility.buildPersonalSetting();
        mysettings.Trigger_Order__c = true;
            mysettings.Trigger_Account__c = false;
            mysettings.Trigger_Opportunity__c = false;
            mysettings.Validation_Account__c = false;
            mysettings.Validation_Opportunity__c = false;
        insert mysettings;
        Test.startTest();
        system.debug('testOrderSellingCountry start');
        Account slyacc = TestDataSetupUtility.createTestAccount('tom 90 test', 'North America', UserInfo.getUserId());
        slyacc.Phone = '1234009891';
        slyacc.ShippingStreet = 'gfrd S';
        slyacc.ShippingCity = 'NY';
        slyacc.ShippingPostalCode = '12345';
        slyacc.Website = 'www.mol.com';
        slyacc.Phone = '4500045344';
        slyacc.AccountStatus__c = 'Customer';
        insert slyacc;
        system.debug('testOrderSellingCountry acc' + slyacc);

        Opportunity slyopp =    TestDataSetupUtility.createTestOpportunity('nowoppsly', slyacc.id);
        slyopp.OrderCreated__c = true;
        system.debug('before test acc insert');
        insert slyopp;

         system.debug('testOrderSellingCountry opp' + slyopp);

        Contact simpleContact =        TestDataSetupUtility.createTestContact(slyopp.AccountId, 'slyFirst', 'slyLast', 'slycontact@email.com');
        simpleContact.Phone = '3334444444';
        insert simpleContact;
        system.debug('testOrderSellingCountry contact ' + simpleContact);

        Apttus_Proposal__Proposal__c slyproposal = TestDataSetupUtility.createProposal( slyacc.id, slyopp.id, 'slyCOMPANY');
        insert slyproposal;
        system.debug('testOrderSellingCountry proposal' + slyproposal);

        Apttus_Proposal__Proposal_Line_Item__c slyPLI = TestDataSetupUtility.createProposalLineItem(slyproposal.id);
        insert slyPLI;

        Order__c simpleStandardOrder = TestDataSetupUtility.createOrder(slyacc.id, simpleContact.Id);
            
            simpleStandardOrder.OrderStatus__c = 'Open';
            simpleStandardOrder.Posting_Contact__c = simpleContact.id;
            simpleStandardOrder.MAPPSentToVerificationBy2__c = Userinfo.getUserId();
            simpleStandardOrder.MAPPBillingAccount__c = slyacc.Id;
            simpleStandardOrder.MAPPBillingContact__c = simpleContact.id;
            simpleStandardOrder.MAPP_Archive_Posting_Contact__c = simpleContact.id;
        insert simpleStandardOrder;

        Product2 simpleProduct = TestDataSetupUtility.createProduct('test', false);
            simpleProduct.Product_Line__c = 'Job Accessories--Inventory';
            simpleProduct.Family= 'Resume';
            simpleProduct.ProductCode = 'QUOTE BUNDLE';
            simpleProduct.APTPS_Rev_Share__c  = 10;
        insert simpleProduct;
        Order_Line_Item__c simpleLI = TestDataSetupUtility.createOrderLineItem(simpleStandardOrder.Id);
            simpleLI.Product__c = simpleProduct.Id;
            simpleLI.startDate__c = Date.newInstance(2015, 1, 1);
            simpleLI.endDate__c = Date.newInstance(2015, 2, 1);
        insert simpleLI;

        ProductUserQuoteLine2OrderLine__c junctionObj = TestDataSetupUtility.createJunctionObjectWithOrderItem(slyproposal.Id,slyPLI.id,simpleLI.id);
        insert junctionObj;
        
        simpleContact.ProposalLineItem__c = slyPLI.id;
        update simpleContact;

        PageReference pageRef = Page.AddContacts;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('ProposalId', simpleLI.Id);
        system.debug('pageRef >>>>' + pageRef);

        AddContactController.wrapperC wr = new AddContactController.wrapperC();
        wr.conlist2 = simpleContact;
        wr.quoteItemId = slyPLI.id;

        List<AddContactController.wrapperC> wrapperList = new List<AddContactController.wrapperC>();
        wrapperList.add(wr);
        system.debug('QUOTELINEITEMIDLIST2  '+wrapperList);

        AddContactController controller = new AddContactController();
        controller.wc = wrapperList;
        system.debug('controllerwrapper '+ controller.wc);
        controller.SaveContact();
        controller.csvFileBody = Blob.valueof('myString,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a\nmyString,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a');
        controller.importCSVFile();
        controller.Cancel();
        Integer rowLimit =controller.rowLimit;
        Attachment att = controller.att;
        String[] lineIdList = controller.lineIdList;
        List<ProductUserQuoteLine2OrderLine__c> quoteToOrder = [SELECT id, Contact_Name__r.LastName, Order_Line_Item__c from ProductUserQuoteLine2OrderLine__c 
                                                             WHERE Proposal_Line_Item__c =: slyPLI.Id];
        //Test Junction record is created with no Order Line Item yet
        //System.assertEquals(oli.Id, quoteToOrder[quoteToOrder.size() - 1].Order_Line_Item__c);
        //System.assertEquals('Test LastName', quoteToOrder[quoteToOrder.size() - 1].Contact_Name__r.LastName);
        
        Test.stoptest();           
    }


   //*************************************4/1/16 Sylvester Agyen - commented out method. Not perfoming additional tests
    /** 
     * @author Jeff Lescarbeau
     * @date 11/5/2015
     * @description testMethod to test the new duplication logic
     */
 /*   static testMethod void testForDuplicates(){
        createRec(false);
        
        Test.starttest();
        contact c = new Contact();
        c.Account = acc;
        c.FirstName = 'Test FirstName';
        c.LastName = 'Test LastName';
        c.Email = 'test@cloudsherpas.com';
        c.Phone = '09123456789';

        insert c;

        PageReference pageRef = Page.AddContacts;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('ProposalId', prop.Id);
        system.debug('pageRef >>>>' + pageRef);

        AddContactController controller = new AddContactController();
        
        //AddContactController.wrapperC wr = new AddContactController.wrapperC();
        
        controller.wc[0].conlist2.FirstName = 'Test FirstName';
        controller.wc[0].conlist2.LastName = 'Test LastName';
        controller.wc[0].conlist2.Email = 'test@cloudsherpas.com';
        controller.wc[0].conlist2.Phone = '09123456789';

        controller.SaveContact();
        Test.stoptest();           
    }  */  
}