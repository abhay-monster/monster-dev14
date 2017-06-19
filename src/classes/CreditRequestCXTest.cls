@isTest
private class CreditRequestCXTest{

 static testMethod void creditRequest(){
 
     Profile_Permissions__c pp =new Profile_Permissions__c();
     
     pp.Creates_Valid_Sales_Activity__c=true;
     pp.Delete_Activities__c=true;
     pp.Do_Not_Show_Fraudlent_Order__c=true;
     pp.Event_Redirect__c=true;
     pp.Task_Redirect__c=true;
     pp.Update_Amount_Validation__c=false; 
     insert pp;
                
     Account acc;
     Credit_Request__c creditRequest;
     Order__c order;
     CreditCondition__c credit;
     Order_Line_Item__c lineItem;
     CreditRequestLineItem__c creditRequestLineItem;
     Order_Line_Item__c orderLineItem;
      User usedUserSysAdmin;
     //CreditRequestCX.CreditRequestLineItemWrapper creditWrapper;
     //List<CreditRequestCX.CreditRequestLineItemWrapper> wrapperLst = new List<CreditRequestCX.CreditRequestLineItemWrapper>();
    try{
         String profileIdSysAdmin = TestDataSetupUtility.PROFILE_ID;
        usedUserSysAdmin = TestDataSetupUtility.createTestUser('Test First Name', 'Test Last Name', profileIdSysAdmin,'Asia Pacific' );
        insert usedUserSysAdmin;
        acc = TestDataSetupUtility.createTestAccountWithShipping('Test Account');
        insert acc;
        Contact con = TestDataSetupUtility.createTestContact(acc.Id, 'confirst1', 'conlast1', 'con1@email.com');
        insert con;
        order = TestDataSetupUtility.createOrder(acc.Id, con.Id);
        insert order;
        creditRequest = TestDataSetupUtility.createCreditRequest(order.id);
        creditRequest.CreditReason__c = 'Termination';
        creditRequest.CreditScenario__c = 'Credit';
        insert creditRequest ;
        credit = new CreditCondition__c ();
        credit.Name = 'Full';
        insert credit;
        lineItem = TestDataSetupUtility.createOrderLineItem(order.Id);
        insert lineItem ;

        orderLineItem = TestDataSetupUtility.createOrderLineItem(order.id);
        insert orderLineItem ;

        creditRequestLineItem = new CreditRequestLineItem__c ();
        creditRequestLineItem.Credit_Request__c = creditRequest.id;
        creditRequestLineItem.Order_Line_Item__c = orderLineItem.id;
        creditRequestLineItem.CreditCondition__c = 'Full';
        creditRequestLineItem.TaxAmount__c = 10;
        creditRequestLineItem.CreditType__c = 'Amount';
        creditRequestLineItem.CreditAmount__c = 100;
        creditRequestLineItem.AvailableCreditAmount__c = 200;
        creditRequestLineItem.NetCreditAmount__c = 10;
        creditRequestLineItem.NetTotalAmount__c=10;
        creditRequestLineItem.NetRemainingCreditAmount__c =10;
        //creditRequestLineItem.CreditAmount__c = 2;
        insert creditRequestLineItem;
       //creditWrapper = new CreditRequestCX.CreditRequestLineItemWrapper(creditRequestLineItem,orderLineItem );


       // wrapperLst.add(creditWrapper);
        creditRequest = [Select Id, Order__c,PaymentTerm__c,CreditReason__c, CreditScenario__c,New_Number_of_Installments__c, (Select id, Credit_Request__c  from Credit_Request_Line_Items__r) FROM Credit_Request__c  WHERE iD =: creditRequest.id ];
        //system.assert(false,creditRequest + 'aagsagsg' + creditRequestLineItem);

    }catch(Exception e){
            //system.assert(false,'Test data not created'+e);

       }

       System.runAs(usedUserSysAdmin){


     Test.startTest();
     Credit_Request__c test21 = [Select Id,CreditReason__c,CreditScenario__c,New_Number_of_Installments__c,PaymentTerm__c,Order__c FROM Credit_Request__c WHERE ID =: creditRequest.Id ];
     system.debug('***######creditRequest.CreditReason__c#####*' +test21.CreditReason__c);
      PageReference pageRef = Page.CreditRequest;
      Test.setCurrentPage(pageRef);
      pageRef.getParameters().put('oid', order.Id);
      ApexPages.StandardController controller = new ApexPages.StandardController(creditRequest);
      CreditRequestCX ctrl = new CreditRequestCX(controller);
      CreditRequestCX.CreditRequestLineItemWrapper crliW =new CreditRequestCX.CreditRequestLineItemWrapper(creditRequestLineItem,orderLineItem);
      CreditRequestCX.NonMsgOLIWrap nmolW =new CreditRequestCX.NonMsgOLIWrap(crliW);
      nmolW.title='Test';
      CreditRequestCX.LicenseIDWrapList liwl =new CreditRequestCX.LicenseIDWrapList(crliW);
      liwl.title='Test';
      
      ctrl.CreditRequest = creditRequest;
      ctrl.ComputeCreditquantityForNonMsg();
      //ctrl.CreditRequestLineItemList = wrapperLst;
      ctrl.SelectAllRecord();
      ctrl.refreshCreditCondition();
      ctrl.ChangeCreditConditionEdit();
      ctrl.ChangeCreditConditionInsert();
      ctrl.save();
      ctrl.ComputeCreditAmount();
      ctrl.Cancel();
      ctrl.ComputeCreditquantity();

      String str = ctrl.LineDeleteMsg;
      system.assertNotEquals(ctrl,null);

      PageReference pageRef1 = Page.CreditRequest;
      Test.setCurrentPage(pageRef1);
      ApexPages.StandardController controller1 = new ApexPages.StandardController(creditRequest);
      CreditRequestCX ctrl1 = new CreditRequestCX(controller1);
      //ctrl1.CreditRequestLineItemList = wrapperLst;
      ctrl1.CreditRequest = creditRequest;
      ctrl1.refreshCreditCondition();
       ctrl1.SelectAllRecord();
      ctrl1.ChangeCreditConditionEdit();
      ctrl1.refreshCreditCondition();
      ctrl1.save();
      system.assertNotEquals(ctrl1,null);

      CreditRequest.CreditScenario__c = 'Credit and Rebill';
      ctrl.CreditRequest.CreditReason__c = Label.Technical_Issue;
      ctrl1.refreshCreditCondition();

      ctrl.save();

      ctrl.CreditRequest.CreditReason__c = Label.Billing_Start_Date_Correction;
      ctrl.CreditRequest.Billing_Start_Date__c = null;
      ctrl.save();

      ctrl.CreditRequest.Billing_Start_Date__c = order.BillingStartDt__c;
      ctrl.save();


      ctrl.CreditRequest.CreditReason__c = Label.Payment_type_incorrect;
      ctrl.CreditRequest.Payment_Frequency__c = order.Payment_Frequency__c;
      ctrl.CreditRequest.Payment_Method__c = order.Payment_Method_text__c;
      ctrl.CreditRequest.PaymentTerm__c = order.Payment_Term_text__c ;
      ctrl.CreditRequest.New_Number_of_Installments__c = order.New_Number_of_Installment__c;
      ctrl.save();

      ctrl.CreditRequest.CreditReason__c = Label.Payment_type_incorrect;
      ctrl.CreditRequest.Payment_Frequency__c = 'Pre-Paid';
      ctrl.CreditRequest.Payment_Method__c = 'Invoice';
      ctrl.CreditRequest.PaymentTerm__c = 'Immediate';
      ctrl.save();

      ctrl.CreditRequest.CreditReason__c = Label.Technical_Issue;
      ctrl.save();
      ctrl.CreditRequest.CreditReason__c = null;
      ctrl.save();

      ctrl.CreditRequest = null;

      ApexPages.StandardController controller2 = new ApexPages.StandardController(new Credit_Request__c());
      try{
      CreditRequestCX ctrl2 = new CreditRequestCX(controller2);
      }catch(Exception e){}
        Test.stopTest();
       }


 }

 static testMethod void creditRequest1(){
    Account acc;
     Credit_Request__c creditRequest;
     Order__c order;
     CreditCondition__c credit;
     Order_Line_Item__c lineItem;
     CreditRequestLineItem__c creditRequestLineItem;
     Order_Line_Item__c orderLineItem;
      User usedUserSysAdmin;
     //CreditRequestCX.CreditRequestLineItemWrapper creditWrapper;
     //List<CreditRequestCX.CreditRequestLineItemWrapper> wrapperLst = new List<CreditRequestCX.CreditRequestLineItemWrapper>();
    try{
         String profileIdSysAdmin = TestDataSetupUtility.PROFILE_ID;
        usedUserSysAdmin = TestDataSetupUtility.createTestUser('Test First Name', 'Test Last Name', profileIdSysAdmin,'Asia Pacific' );
        insert usedUserSysAdmin;
        acc = TestDataSetupUtility.createTestAccountWithShipping('Test Account');
        insert acc;
        Contact con = TestDataSetupUtility.createTestContact(acc.Id, 'confirst1', 'conlast1', 'con1@email.com');
        insert con;
        order = TestDataSetupUtility.createOrder(acc.Id, con.Id);
        insert order;
        creditRequest = TestDataSetupUtility.createCreditRequest(order.id);
        creditRequest.CreditReason__c = Label.Technical_Issue;
        //CreditRequest.CreditScenario__c = 'Credit and Rebill';
        //creditRequest.CreditReason__c = Label.Test_Order;
        insert creditRequest ;
        List<CreditCondition__c> ccList = new List<CreditCondition__c>();
        ccList.add( new CreditCondition__c (Name = 'Full'));
        ccList.add( new CreditCondition__c (Name = 'Partial'));
        ccList.add( new CreditCondition__c (Name = 'Tax'));
        insert ccList;
        lineItem = TestDataSetupUtility.createOrderLineItem(order.Id);
        insert lineItem ;

        orderLineItem = TestDataSetupUtility.createOrderLineItem(order.id);
        insert orderLineItem ;

        creditRequestLineItem = new CreditRequestLineItem__c ();
        creditRequestLineItem.Credit_Request__c = creditRequest.id;
        creditRequestLineItem.Order_Line_Item__c = orderLineItem.id;
        creditRequestLineItem.CreditCondition__c = 'Full';
        creditRequestLineItem.TaxAmount__c = 10;
        creditRequestLineItem.CreditType__c = 'Amount';
        creditRequestLineItem.CreditAmount__c = 0;
        creditRequestLineItem.AvailableCreditAmount__c = 200;
        creditRequestLineItem.NetCreditAmount__c = 10;
        creditRequestLineItem.NetTotalAmount__c=10;
        creditRequestLineItem.NetRemainingCreditAmount__c =10;
        creditRequestLineItem.AgencyCommission__c = 1;

        insert creditRequestLineItem;
       //creditWrapper = new CreditRequestCX.CreditRequestLineItemWrapper(creditRequestLineItem,orderLineItem );


       // wrapperLst.add(creditWrapper);
        creditRequest = [Select Id, Order__c,CreditReason__c,PaymentTerm__c, CreditScenario__c,New_Number_of_Installments__c,(Select id, Credit_Request__c  from Credit_Request_Line_Items__r) FROM Credit_Request__c  WHERE iD =: creditRequest.id ];
        //system.assert(false,creditRequest + 'aagsagsg' + creditRequestLineItem);

    }catch(Exception e){
           // system.assert(false,'Test data not created');
       }

       System.runAs(usedUserSysAdmin){

         Test.startTest();
     Credit_Request__c test21 = [Select Id,CreditReason__c,PaymentTerm__c FROM Credit_Request__c WHERE ID =: creditRequest.Id ];
     system.debug('***######creditRequest.CreditReason__c#####*' +test21.CreditReason__c);


      PageReference pageRef1 = Page.CreditRequest;
      Test.setCurrentPage(pageRef1);
      ApexPages.StandardController controller1 = new ApexPages.StandardController(creditRequest);
      CreditRequestCX ctrl1 = new CreditRequestCX(controller1);
      ctrl1.CreditCondition  = 'Full';
      //ctrl1.CreditRequestLineItemList = wrapperLst;
      ctrl1.CreditRequest = creditRequest;
       for(CreditRequestCX.CreditRequestLineItemWrapper crliw : ctrl1.CreditRequestLineItemList){
        crliw.selected = true;
      }
      system.debug('***######creditRequest.CreditReason__c1#####*' +creditRequest.CreditReason__c);
      ctrl1.refreshCreditCondition();
       ctrl1.SelectAllRecord();
      ctrl1.ChangeCreditConditionEdit();
      ctrl1.refreshCreditCondition();
      system.assertNotEquals(ctrl1,null);
      ctrl1.save();
     Test.stopTest();
       }
 }

  static testMethod void creditRequest2(){
    Account acc;
     Credit_Request__c creditRequest;
     Order__c order;
     CreditCondition__c credit;
     Order_Line_Item__c lineItem;
     CreditRequestLineItem__c creditRequestLineItem;
     Order_Line_Item__c orderLineItem;
      User usedUserSysAdmin;
      LicenseID__c licenseId ;
     //CreditRequestCX.creditWrapper;
     //List<CreditRequestCX.CreditRequestLineItemWrapper> wrapperLst = new List<CreditRequestCX.CreditRequestLineItemWrapper>();
    try{
         String profileIdSysAdmin = TestDataSetupUtility.PROFILE_ID;
        usedUserSysAdmin = TestDataSetupUtility.createTestUser('Test First Name', 'Test Last Name', profileIdSysAdmin,'Europe' );
        insert usedUserSysAdmin;
        acc = TestDataSetupUtility.createTestAccountWithShipping('Test Account');
        insert acc;
        Contact con = TestDataSetupUtility.createTestContact(acc.Id, 'confirst1', 'conlast1', 'con1@email.com');
        insert con;
        order = TestDataSetupUtility.createOrder(acc.Id, con.Id);
        insert order;
        creditRequest = TestDataSetupUtility.createCreditRequest(order.id);
        creditRequest.CreditReason__c = 'Incorrect Tax';
        insert creditRequest ;
        credit = new CreditCondition__c ();
        credit.Name = 'Full';
        insert credit;
        lineItem = TestDataSetupUtility.createOrderLineItem(order.Id);
        insert lineItem ;

        orderLineItem = TestDataSetupUtility.createOrderLineItem(order.id);
        insert orderLineItem ;

        licenseId = new LicenseID__c();
        licenseId.OrderLineItem__c = orderLineItem.id;
        licenseId.SiteLicenseID__c = '11';
        insert licenseId ;

        creditRequestLineItem = new CreditRequestLineItem__c ();
        creditRequestLineItem.Credit_Request__c = creditRequest.id;
        creditRequestLineItem.Order_Line_Item__c = orderLineItem.id;
        creditRequestLineItem.CreditCondition__c = 'Full';
        creditRequestLineItem.TaxAmount__c = 10;
        creditRequestLineItem.CreditType__c = 'Amount';
        creditRequestLineItem.CreditAmount__c = 100;
        creditRequestLineItem.AvailableCreditAmount__c = 200;
        creditRequestLineItem.NetCreditAmount__c = 10;
        creditRequestLineItem.NetTotalAmount__c=10;
        creditRequestLineItem.NetRemainingCreditAmount__c =10;
        creditRequestLineItem.AgencyCommission__c = 1;
        insert creditRequestLineItem;
       //creditWrapper = new CreditRequestCX.CreditRequestLineItemWrapper(creditRequestLineItem,orderLineItem );


       // wrapperLst.add(creditWrapper);
        creditRequest = [Select Id, Order__c,CreditReason__c,PaymentTerm__c, CreditScenario__c,New_Number_of_Installments__c, (Select id, Credit_Request__c  from Credit_Request_Line_Items__r) FROM Credit_Request__c  WHERE iD =: creditRequest.id ];
        //system.assert(false,creditRequest + 'aagsagsg' + creditRequestLineItem);

    }catch(Exception e){
            system.assert(false,'Test data not created. '+e);
       }

       System.runAs(usedUserSysAdmin){

         Test.startTest();
         Test.setMock(WebServiceMock.class, new WebServiceMockImpl3());

     Credit_Request__c test21 = [Select Id,CreditReason__c,PaymentTerm__c FROM Credit_Request__c WHERE ID =: creditRequest.Id ];
     system.debug('***######creditRequest.CreditReason__c#####*' +test21.CreditReason__c);


      PageReference pageRef1 = Page.CreditRequest;
      Test.setCurrentPage(pageRef1);
      pageRef1.getParameters().put('oid', order.Id);
      ApexPages.StandardController controller1 = new ApexPages.StandardController(creditRequest);
      CreditRequestCX ctrl1 = new CreditRequestCX(controller1);
     
      //ctrl1.CreditRequestLineItemList = wrapperLst;
      ctrl1.CreditRequest = creditRequest;
     for(CreditRequestCX.CreditRequestLineItemWrapper crliw : ctrl1.CreditRequestLineItemList){
        crliw.selected = true;
      }
      system.debug('***######creditRequest.CreditReason__c1#####*' +creditRequest.CreditReason__c);
      ctrl1.refreshCreditCondition();
       ctrl1.SelectAllRecord();
       ctrl1.ChangeCreditConditionInsert();
      ctrl1.ChangeCreditConditionEdit();
      ctrl1.refreshCreditCondition();
      ctrl1.save();


      for(CreditRequestCX.CreditRequestLineItemWrapper crliw : ctrl1.CreditRequestLineItemList){
         CreditRequestCX.LicenseIDWrapList objLW = new CreditRequestCX.LicenseIDWrapList(crliw);
         objLW.LicenseList = new CreditRequestCX.LicenseIDWrap[]{};
         objLW.addLicense(licenseId,true, 'Partial');
      }
      //crtl1.
      system.assertNotEquals(ctrl1,null);

     Test.stopTest();
       }
 }

 static testMethod void creditRequest3(){
    Account acc;
     Credit_Request__c creditRequest;
     Order__c order;
     CreditCondition__c credit;
     Order_Line_Item__c lineItem;
     CreditRequestLineItem__c creditRequestLineItem;
     Order_Line_Item__c orderLineItem;
      User usedUserSysAdmin;
     //CreditRequestCX.CreditRequestLineItemWrapper creditWrapper;
     //List<CreditRequestCX.CreditRequestLineItemWrapper> wrapperLst = new List<CreditRequestCX.CreditRequestLineItemWrapper>();
    try{
         String profileIdSysAdmin = TestDataSetupUtility.PROFILE_ID;
        usedUserSysAdmin = TestDataSetupUtility.createTestUser('Test First Name', 'Test Last Name', profileIdSysAdmin,'North America' );
        insert usedUserSysAdmin;
        acc = TestDataSetupUtility.createTestAccountWithShipping('Test Account');
        insert acc;
        Contact con = TestDataSetupUtility.createTestContact(acc.Id, 'confirst1', 'conlast1', 'con1@email.com');
        insert con;
        order = TestDataSetupUtility.createOrder(acc.Id, con.Id);
        insert order;
        creditRequest = TestDataSetupUtility.createCreditRequest(order.id);
        creditRequest.CreditReason__c = 'Tax Error';
        insert creditRequest ;
        credit = new CreditCondition__c ();
        credit.Name = 'Tax';
        insert credit;
        lineItem = TestDataSetupUtility.createOrderLineItem(order.Id);
        insert lineItem ;

        orderLineItem = TestDataSetupUtility.createOrderLineItem(order.id);
        insert orderLineItem ;

        creditRequestLineItem = new CreditRequestLineItem__c ();
        creditRequestLineItem.Credit_Request__c = creditRequest.id;
        creditRequestLineItem.Order_Line_Item__c = orderLineItem.id;
        creditRequestLineItem.CreditCondition__c = 'Full';
        creditRequestLineItem.TaxAmount__c = 10;
        creditRequestLineItem.CreditType__c = 'Inventory';
        creditRequestLineItem.CreditAmount__c = 100;
        creditRequestLineItem.AvailableCreditAmount__c = 200;
        creditRequestLineItem.NetCreditAmount__c = 10;
        creditRequestLineItem.NetTotalAmount__c=10;
        creditRequestLineItem.NetRemainingCreditAmount__c =10;
        insert creditRequestLineItem;
       //creditWrapper = new CreditRequestCX.CreditRequestLineItemWrapper(creditRequestLineItem,orderLineItem );


       // wrapperLst.add(creditWrapper);
        creditRequest = [Select Id, Order__c,CreditReason__c,PaymentTerm__c, CreditScenario__c,New_Number_of_Installments__c, (Select id, Credit_Request__c  from Credit_Request_Line_Items__r) FROM Credit_Request__c  WHERE iD =: creditRequest.id ];
        //system.assert(false,creditRequest + 'aagsagsg' + creditRequestLineItem);

    }catch(Exception e){
            system.assert(false,'Test data not created. '+e);
       }

       System.runAs(usedUserSysAdmin){

         Test.startTest();
     Credit_Request__c test21 = [Select Id,CreditReason__c,PaymentTerm__c FROM Credit_Request__c WHERE ID =: creditRequest.Id ];
     system.debug('***######creditRequest.CreditReason__c#####*' +test21.CreditReason__c);


      PageReference pageRef1 = Page.CreditRequest;
      Test.setCurrentPage(pageRef1);
      ApexPages.StandardController controller1 = new ApexPages.StandardController(creditRequest);
      CreditRequestCX ctrl1 = new CreditRequestCX(controller1);
      //ctrl1.CreditRequestLineItemList = wrapperLst;
      ctrl1.CreditRequest = creditRequest;
      system.debug('***######creditRequest.CreditReason__c1#####*' +creditRequest.CreditReason__c);

      for(CreditRequestCX.CreditRequestLineItemWrapper crliw : ctrl1.CreditRequestLineItemList){
        crliw.selected = true;
      }

      ctrl1.refreshCreditCondition();
       ctrl1.SelectAllRecord();
      ctrl1.ChangeCreditConditionEdit();
      ctrl1.refreshCreditCondition();
      ctrl1.save();


      CreditRequestCX.LicenseIDWrap objL = new CreditRequestCX.LicenseIDWrap();
      ctrl1.previous();
      ctrl1.next();
      ctrl1.getprev();
      ctrl1.getnxt();
      system.assertNotEquals(ctrl1,null);

     Test.stopTest();
       }
 }

 static testMethod void creditRequest4(){
    Account acc;
     Credit_Request__c creditRequest;
     Order__c order;
     CreditCondition__c credit;
     Order_Line_Item__c lineItem;
     CreditRequestLineItem__c creditRequestLineItem;
     Order_Line_Item__c orderLineItem;
      User usedUserSysAdmin;
      LicenseID__c licenseId;
     CreditRequestCX.CreditRequestLineItemWrapper creditWrapper;
     //List<CreditRequestCX.CreditRequestLineItemWrapper> wrapperLst = new List<CreditRequestCX.CreditRequestLineItemWrapper>();
    try{
         String profileIdSysAdmin = TestDataSetupUtility.PROFILE_ID;
        usedUserSysAdmin = TestDataSetupUtility.createTestUser('Test First Name', 'Test Last Name', profileIdSysAdmin,'North America' );
        insert usedUserSysAdmin;
        acc = TestDataSetupUtility.createTestAccountWithShipping('Test Account');
        insert acc;
        Contact con = TestDataSetupUtility.createTestContact(acc.Id, 'confirst1', 'conlast1', 'con1@email.com');
        insert con;
        order = TestDataSetupUtility.createOrder(acc.Id, con.Id);
        insert order;
        creditRequest = TestDataSetupUtility.createCreditRequest(order.id);
        creditRequest.CreditReason__c = 'Tax Error';
        insert creditRequest ;
        credit = new CreditCondition__c ();
        credit.Name = 'Tax';
        insert credit;
        lineItem = TestDataSetupUtility.createOrderLineItem(order.Id);
        insert lineItem ;

        orderLineItem = TestDataSetupUtility.createOrderLineItem(order.id);
        insert orderLineItem ;

        licenseId = new LicenseID__c();
        licenseId.OrderLineItem__c = orderLineItem.id;
        licenseId.SiteLicenseID__c = '11';
        insert licenseId ;

        creditRequestLineItem = new CreditRequestLineItem__c ();
        creditRequestLineItem.Credit_Request__c = creditRequest.id;
        creditRequestLineItem.Order_Line_Item__c = orderLineItem.id;
        creditRequestLineItem.CreditCondition__c = 'Full';
        creditRequestLineItem.TaxAmount__c = 10;
        creditRequestLineItem.CreditType__c = 'Inventory';
        creditRequestLineItem.CreditAmount__c = 100;
        creditRequestLineItem.AvailableCreditAmount__c = 200;
        creditRequestLineItem.NetCreditAmount__c = 10;
        creditRequestLineItem.NetTotalAmount__c=10;
        creditRequestLineItem.NetRemainingCreditAmount__c =10;
        insert creditRequestLineItem;
        creditWrapper = new CreditRequestCX.CreditRequestLineItemWrapper(creditRequestLineItem,orderLineItem );


       // wrapperLst.add(creditWrapper);
        creditRequest = [Select Id, Order__c,CreditReason__c,PaymentTerm__c, CreditScenario__c,New_Number_of_Installments__c, (Select id, Credit_Request__c  from Credit_Request_Line_Items__r) FROM Credit_Request__c  WHERE iD =: creditRequest.id ];
        //system.assert(false,creditRequest + 'aagsagsg' + creditRequestLineItem);
        IntegrationConfig__c setting = new IntegrationConfig__c(Name = 'Site Integration', AvalaraClient__c = 'Monster Worldwide, Inc.',
                AvalaraCompanyCode__c = 'MWW', AvalaraCountry__c = 'MWW', EndpointName__c = 'AvalaraDev',IsPaypalTest__c = false,
                Password__c = '6NvqAGdhXM^y',Timeout__c = 60000,Username__c = 'jlescarbeau@appirio.com', PaypalRedirectURL__c = 'PaypalRedirectURL');
            insert setting;
        WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c(Name = 'AvalaraDev', Endpoint__c = 'https://development.avalara.net/1.0/tax/get');
            WebServiceEndpoint__c endpoint2 = new WebServiceEndpoint__c(Name = 'PaypalRedirectURL', Endpoint__c = 'https://payflowlink.paypal.com');
            insert new List<WebServiceEndpoint__c>{endpoint, endpoint2};


        Integration_Attribute__c integration = new Integration_Attribute__c(Name = 'Test' ,Integration_Type__c='MAPP');
        integration.source_object__c = 'Line_Item_Attribute__c';
        List<Integration_Attribute__c> integrationLst = new List<Integration_Attribute__c>();
        integrationLst.add(integration);
        integrationLst.add( new Integration_Attribute__c(Name = 'Test' ,source_object__c = 'Line_Item_Attribute__c',Integration_Type__c='IWS'));
        insert integrationLst;
    }catch(Exception e){
            system.assert(false,'Test data not created');
       }

       System.runAs(usedUserSysAdmin){

         Test.startTest();
         Test.setMock(WebServiceMock.class, new WebServiceMockImpl3());

         Credit_Request__c test21 = [Select Id,CreditReason__c,PaymentTerm__c FROM Credit_Request__c WHERE ID =: creditRequest.Id ];
         system.debug('***######creditRequest.CreditReason__c#####*' +test21.CreditReason__c);



          PageReference pageRef1 = Page.CreditRequest;
          Test.setCurrentPage(pageRef1);
          pageRef1.getParameters().put('oid', order.Id);
          ApexPages.StandardController controller1 = new ApexPages.StandardController(creditRequest);
          CreditRequestCX ctrl1 = new CreditRequestCX(controller1);
          //ctrl1.CreditRequestLineItemList = wrapperLst;
          ctrl1.CreditRequest = creditRequest;
          system.debug('***######creditRequest.CreditReason__c1#####*' +creditRequest.CreditReason__c);

          for(CreditRequestCX.CreditRequestLineItemWrapper crliw : ctrl1.CreditRequestLineItemList){
            crliw.selected = true;
          }


          List<CreditRequestCX.LicenseIDWrap> LicenseList = new List<CreditRequestCX.LicenseIDWrap>();
          CreditRequestCX.LicenseIDWrap objL = new CreditRequestCX.LicenseIDWrap();
          objL.Quantity = '10';
          objL.License = licenseId;
          LicenseList.add(objL);
          List<CreditRequestCX.LicenseIDWrapList> licenseIdWrapList = new List<CreditRequestCX.LicenseIDWrapList>();
          CreditRequestCX.LicenseIDWrapList wrapList = new CreditRequestCX.LicenseIDWrapList(creditWrapper);
          wrapList.LicenseList = LicenseList;

          licenseIdWrapList.add(wrapList);

          CreditRequestCX.LicenseIDModel licenseMod = new CreditRequestCX.LicenseIDModel();
          licenseMod.LicenseIDList = licenseIdWrapList;
          licenseMod.init('full');
          String[] str = licenseMod.saveTempLicenseIds();
          ctrl1.LicenseModel = licenseMod;
          wrapList.addLicense(licenseId,true,'full');

          ctrl1.ComputeCreditquantity();
          ctrl1.refreshCreditCondition();
          ctrl1.SelectAllRecord();
          ctrl1.ChangeCreditConditionEdit();
          ctrl1.refreshCreditCondition();
          ctrl1.save();

          ctrl1.previous();
          ctrl1.next();
          ctrl1.getprev();
          ctrl1.getnxt();
          system.assertNotEquals(ctrl1,null);

         Test.stopTest();
       }
 }

 public class WebServiceMockImpl3 implements WebServiceMock  {
        // Implement this interface method
        public void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {

           v3_monsterBizappsSiterouterSiterouterws.GetMultipleLicenseAndRelativesResp_element responseElement = new v3_monsterBizappsSiterouterSiterouterws.GetMultipleLicenseAndRelativesResp_element();
           v3_monsterBizappsSiterouterSiterouterws.ArrayOfGetLicenseAndRelativesResp elem1 = new v3_monsterBizappsSiterouterSiterouterws.ArrayOfGetLicenseAndRelativesResp();
           responseElement.GetLicenseAndRelativesResponses = elem1;
           elem1.GetLicenseAndRelativesResp = new List<v3_monsterBizappsSiterouterSiterouterws.GetLicenseAndRelativesResp>();
           v3_monsterBizappsSiterouterSiterouterws.GetLicenseAndRelativesResp res = new v3_monsterBizappsSiterouterSiterouterws.GetLicenseAndRelativesResp();
           res.GetLicenseAndRelativesResponseItems = new v3_monsterBizappsSiterouterSiterouterws.ArrayOfGetLicenseAndRelativesResponseItem();
           v3_monsterBizappsSiterouterSiterouterws.GetLicenseAndRelativesResponseItem[] subele = new List<v3_monsterBizappsSiterouterSiterouterws.GetLicenseAndRelativesResponseItem>();
           v3_monsterBizappsSiterouterSiterouterws.GetLicenseAndRelativesResponseItem item = new v3_monsterBizappsSiterouterSiterouterws.GetLicenseAndRelativesResponseItem();
           item.CompanyName = 'xyz company';
           item.ResourceLicenseID =11;
            item.AvailableQuantity =2;
           subele.add(item);
           elem1.GetLicenseAndRelativesResp.add( res);
           res.GetLicenseAndRelativesResponseItems.GetLicenseAndRelativesResponseItem =  subele;
            response.put('response_x', responseElement);
        }
    }
    
 static testMethod void creditRequest5(){
 
                
     Account acc;
     Credit_Request__c creditRequest;
     Order__c order;
     CreditCondition__c credit;
     Order_Line_Item__c lineItem;
     CreditRequestLineItem__c creditRequestLineItem;
     Order_Line_Item__c orderLineItem;
      User usedUserSysAdmin;
     //CreditRequestCX.CreditRequestLineItemWrapper creditWrapper;
     //List<CreditRequestCX.CreditRequestLineItemWrapper> wrapperLst = new List<CreditRequestCX.CreditRequestLineItemWrapper>();
    try{
         String profileIdSysAdmin = TestDataSetupUtility.PROFILE_ID;
        usedUserSysAdmin = TestDataSetupUtility.createTestUser('Test First Name', 'Test Last Name', profileIdSysAdmin,'Asia Pacific' );
        insert usedUserSysAdmin;
        acc = TestDataSetupUtility.createTestAccountWithShipping('Test Account');
        insert acc;
        Contact con = TestDataSetupUtility.createTestContact(acc.Id, 'confirst1', 'conlast1', 'con1@email.com');
        insert con;
        order = TestDataSetupUtility.createOrder(acc.Id, con.Id);
        insert order;
        creditRequest = TestDataSetupUtility.createCreditRequest(order.id);
        creditRequest.CreditReason__c = 'Termination';
        creditRequest.CreditScenario__c = 'Credit';
        insert creditRequest ;
        credit = new CreditCondition__c ();
        credit.Name = 'Full';
        insert credit;
        lineItem = TestDataSetupUtility.createOrderLineItem(order.Id);
        insert lineItem ;

        orderLineItem = TestDataSetupUtility.createOrderLineItem(order.id);
        insert orderLineItem ;

        creditRequestLineItem = new CreditRequestLineItem__c ();
        creditRequestLineItem.Credit_Request__c = creditRequest.id;
        creditRequestLineItem.Order_Line_Item__c = orderLineItem.id;
        creditRequestLineItem.CreditCondition__c = 'Full';
        creditRequestLineItem.TaxAmount__c = 10;
        creditRequestLineItem.CreditType__c = 'Amount';
        creditRequestLineItem.CreditAmount__c = 100;
        creditRequestLineItem.AvailableCreditAmount__c = 200;
        creditRequestLineItem.NetCreditAmount__c = 10;
        creditRequestLineItem.NetTotalAmount__c=10;
        creditRequestLineItem.NetRemainingCreditAmount__c =10;
        //creditRequestLineItem.CreditAmount__c = 2;
        insert creditRequestLineItem;
       //creditWrapper = new CreditRequestCX.CreditRequestLineItemWrapper(creditRequestLineItem,orderLineItem );


       // wrapperLst.add(creditWrapper);
        creditRequest = [Select Id, Order__c,PaymentTerm__c,CreditReason__c, CreditScenario__c,New_Number_of_Installments__c, (Select id, Credit_Request__c  from Credit_Request_Line_Items__r) FROM Credit_Request__c  WHERE iD =: creditRequest.id ];
        //system.assert(false,creditRequest + 'aagsagsg' + creditRequestLineItem);

    }catch(Exception e){
            //system.assert(false,'Test data not created'+e);

       }

       System.runAs(usedUserSysAdmin){


     Test.startTest();
     Credit_Request__c test21 = [Select Id,CreditReason__c,CreditScenario__c,New_Number_of_Installments__c,PaymentTerm__c,Order__c FROM Credit_Request__c WHERE ID =: creditRequest.Id ];
     system.debug('***######creditRequest.CreditReason__c#####*' +test21.CreditReason__c);
      PageReference pageRef = Page.CreditRequest;
      Test.setCurrentPage(pageRef);
      pageRef.getParameters().put('oid', order.Id);
      ApexPages.StandardController controller = new ApexPages.StandardController(creditRequest);
      CreditRequestCX ctrl = new CreditRequestCX(controller);
      CreditRequestCX.CreditRequestLineItemWrapper crliW =new CreditRequestCX.CreditRequestLineItemWrapper(creditRequestLineItem,orderLineItem);
      CreditRequestCX.NonMsgOLIWrap nmolW =new CreditRequestCX.NonMsgOLIWrap(crliW);
      nmolW.title='Test';
      CreditRequestCX.LicenseIDWrapList liwl =new CreditRequestCX.LicenseIDWrapList(crliW);
      liwl.title='Test';
      
      ctrl.CreditRequest = creditRequest;
      ctrl.ComputeCreditquantityForNonMsg();
      //ctrl.CreditRequestLineItemList = wrapperLst;
      ctrl.SelectAllRecord();
      ctrl.refreshCreditCondition();
      ctrl.ChangeCreditConditionEdit();
      ctrl.ChangeCreditConditionInsert();
      ctrl.save();
      ctrl.ComputeCreditAmount();
      ctrl.Cancel();
      ctrl.ComputeCreditquantity();

      String str = ctrl.LineDeleteMsg;
      system.assertNotEquals(ctrl,null);

      PageReference pageRef1 = Page.CreditRequest;
      Test.setCurrentPage(pageRef1);
      ApexPages.StandardController controller1 = new ApexPages.StandardController(creditRequest);
      CreditRequestCX ctrl1 = new CreditRequestCX(controller1);
      //ctrl1.CreditRequestLineItemList = wrapperLst;
      ctrl1.CreditRequest = creditRequest;
      ctrl1.refreshCreditCondition();
       ctrl1.SelectAllRecord();
      ctrl1.ChangeCreditConditionEdit();
      ctrl1.refreshCreditCondition();
      ctrl1.save();
      system.assertNotEquals(ctrl1,null);

      CreditRequest.CreditScenario__c = 'Credit and Rebill';
      ctrl.CreditRequest.CreditReason__c = Label.Technical_Issue;
      ctrl1.refreshCreditCondition();

      ctrl.save();

      ctrl.CreditRequest.CreditReason__c = Label.Billing_Start_Date_Correction;
      ctrl.CreditRequest.Billing_Start_Date__c = null;
      ctrl.save();

      ctrl.CreditRequest.Billing_Start_Date__c = order.BillingStartDt__c;
      ctrl.save();


      ctrl.CreditRequest.CreditReason__c = Label.Payment_type_incorrect;
      ctrl.CreditRequest.Payment_Frequency__c = order.Payment_Frequency__c;
      ctrl.CreditRequest.Payment_Method__c = order.Payment_Method_text__c;
      ctrl.CreditRequest.PaymentTerm__c = order.Payment_Term_text__c ;
      ctrl.CreditRequest.New_Number_of_Installments__c = order.New_Number_of_Installment__c;
      ctrl.save();

      ctrl.CreditRequest.CreditReason__c = Label.Payment_type_incorrect;
      ctrl.CreditRequest.Payment_Frequency__c = 'Pre-Paid';
      ctrl.CreditRequest.Payment_Method__c = 'Invoice';
      ctrl.CreditRequest.PaymentTerm__c = 'Immediate';
      ctrl.save();

      ctrl.CreditRequest.CreditReason__c = Label.Technical_Issue;
      ctrl.save();
      ctrl.CreditRequest.CreditReason__c = null;
      ctrl.save();

      ctrl.CreditRequest = null;

      ApexPages.StandardController controller2 = new ApexPages.StandardController(new Credit_Request__c());
      try{
      CreditRequestCX ctrl2 = new CreditRequestCX(controller2);
      }catch(Exception e){}
        Test.stopTest();
       }


 }
}