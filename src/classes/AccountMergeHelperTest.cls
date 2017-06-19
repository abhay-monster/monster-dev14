@isTest

Private Class AccountMergeHelperTest{
    static Account winningAcc, losingAcc, accounttest;
    static List<XcodeAccount__c> xCodeList = new List<XcodeAccount__c>();
    static testmethod void testAccountMergeHelper(){
        prepareData();
        
        User sysAdmin;
        sysAdmin = TestDataSetupUtility.createUser('System Administrator', true);
        System.runAs(sysAdmin){
            Test.startTest();
            
                AccountMergeHelper helper = new AccountMergeHelper();
            
            
                helper.mergeAccounts(winningAcc.Id, losingAcc.Id);
                // Verify data is populated in class variables
                 
              
                
                System.assert(helper.winningAccount != null);
            
         
                System.assert(helper.losingAccount != null);
            
           
                System.assert(helper.dupeXCodesList != null);
                System.assert(helper.dupePartnersList != null);
                System.assert(helper.dupeCompetitorsList != null);
                       
                helper.reparentChildAccounts();
                System.assert(helper.forUpdAccountList!= null);
                //Added 
                AccountMergeHelper.DeletingOfPrimaryXCodeImplemention(xCodeList);
               
            
            prepareData();
            losingAcc.IsGlobalHQ__c = true;
            winningAcc.IsGlobalHQ__c = true;
            
            List <Account> testList = [SELECT  Id,Name,ParentId,GlobalHQAccount__c,DomesticHQAccount__c,IsGlobalHQ__c,IsDomesticHQ__c,
              (SELECT Id,Name,ParentId,GlobalHQAccount__c,DomesticHQAccount__c FROM ChildAccounts),
              (SELECT Id,Name,ParentId,GlobalHQAccount__c,DomesticHQAccount__c FROM GlobalHQAccounts__r),
              (SELECT Id,Name,ParentId,GlobalHQAccount__c,DomesticHQAccount__c FROM DomesticHQAccounts__r)
      FROM    Account
      WHERE   Id =: losingAcc.Id
      OR      Id =: winningAcc.Id];
            System.debug('query result is ' + testlist);
            
            winningAcc.DateMerged__c = System.today() ;
            winningAcc.customerDate__c = System.today() ;
            winningAcc.ResumeExpires__c = System.today()+3;
            winningAcc.JobPostzExpires__c = System.today()+5;
            losingAcc.DateMerged__C = System.today() -1 ;
            losingAcc.customerDate__c = System.today() ;
            losingAcc.ResumeExpires__c = System.today();
            losingAcc.JobPostzExpires__c = System.today();
            
            update winningAcc;
            update losingAcc;
           
            helper.mergeAccounts(winningAcc.Id, losingAcc.Id);
           
           
            Test.stopTest();
        }
       
    }
    
    static void prepareData(){
         
         RegistrationNumber__c rn = TestDataSetupUtility.createRegistrationNumber(true);
         RegistrationNumber__c rn1 = TestDataSetupUtility.createRegistrationNumber(true);
       
         winningAcc = TestDataSetupUtility.createTestAccount('Winning-Account',null,null);
         winningAcc.NewspaperStatus__c = 'Partner Exclusive';
         winningAcc.DUNSNumber = null;
         winningAcc.registration__c = rn1.id; 
         winningAcc.AgencyFlag__c = true;
         winningAcc.CreditStatus__c = 'ok';
     //  winningAcc.IsGlobalHQ__c = true;
    //    winningAcc.GlobalHQAccount__c = testAcc.Id;
        winningAcc.AccountStatus__c = 'Lapsed Customer';
        winningAcc.Score__c = 50;
        winningAcc.Fax_Number_Mobile_Phone_Do_Not_call__c = false;
        winningAcc.Fax_Number_National_Do_Not_Call__c = false;
        winningAcc.FaxDoNotCall__c = false;
        //winningAcc.OtherPhone_Mobile_Do_Not_Call__pc = true;
       // winningAcc.OtherPhone_National_Do_Not_Call_Registry__pc = true;
        winningAcc.OtherDoNotCall__c = false;
        winningAcc.Phone_Mobile_Do_Not_Call__c = false;
        winningAcc.Phone_National_Do_Not_Call_Registry__c = false;
        winningAcc.PhoneDoNotCall__c = false;
        winningAcc.BillingAddressDoNotMail__c = false;
        winningAcc.DoNotMail__c = false;
        winningAcc.PostingAddressDoNotMail__c = false;
      
        
         insert winningAcc ;
                Account testAcc = TestDataSetupUtility.createTestAccount('Global HQ Account', null, null);
        testAcc.GlobalHQAccount__c = winningAcc.Id;
        
        insert testAcc;
         
        
         Contact con = TestDataSetupUtility.createTestContact(winningAcc.Id, 'Win', 'Contact', 'wincon@gmail.com');
         insert con;
         
         Contact con1 = TestDataSetupUtility.createTestContact(winningAcc.Id, 'Win', 'Contact', 'losecon1@gmail.com');
         insert con1;
         
         Contact con2 = TestDataSetupUtility.createTestContact(winningAcc.Id, 'Lose', 'Con', 'losecon1@gmail.com');
        con2.FirstName = 'Con';
        con2.LastName = 'Lose';
         insert con2;
         
         //Added for T-566570
         Contact con8 = TestDataSetupUtility.createTestContact(winningAcc.Id, 'Lose', 'Con', 'losecon8@gmail.com');
        con8.FirstName = 'Con';
        con8.LastName = 'Lose';
         insert con8;
         
         Opportunity opportunitytest =  TestDataSetupUtility.createTestOpportunity('TestAccount1', userinfo.getuserid());
         opportunitytest.Accountid =  winningAcc.id;
         insert opportunitytest;
         
         
         losingAcc= TestDataSetupUtility.createTestAccountWithShipping('Losing-account');
         losingAcc.NewspaperStatus__c = 'Monster Exclusive';
         losingAcc.DUNSNumber = '12' ;
         losingAcc.Registration__c = rn.id;
      //losingAcc.IsGlobalHQ__c = true;
     //   losingAcc.GlobalHQAccount__c = testAcc.Id;
        losingAcc.AccountStatus__c = 'Customer';
        losingAcc.Score__c = 5;
        losingAcc.RegistrationNumber__c = 'testreg';
        losingAcc.OtherPhone__c = '989898' ;
        losingAcc.CreditStatus__c = 'Suspend';
        losingAcc.Fax = '7878';
        losingAcc.Fax_Number_Mobile_Phone_Do_Not_call__c = true;
        losingAcc.Fax_Number_National_Do_Not_Call__c = true;
        losingAcc.FaxDoNotCall__c = true;
        //losingAcc.OtherPhone_Mobile_Do_Not_Call__pc = true;
        //losingAcc.OtherPhone_National_Do_Not_Call_Registry__pc = true;
        losingAcc.OtherDoNotCall__c = true;
        losingAcc.Phone_Mobile_Do_Not_Call__c = true;
        losingAcc.Phone_National_Do_Not_Call_Registry__c = true;
        losingAcc.PhoneDoNotCall__c = true;
        losingAcc.BillingAddressDoNotMail__c = true;
        losingAcc.DoNotMail__c = true;
        losingAcc.PostingAddressDoNotMail__c = true;
       // losingAcc.DomesticHQAccount__c = testAcc.Id;
        losingAcc.ParentId = testAcc.Id;
    
         insert losingAcc;
                Account testAcc1 = TestDataSetupUtility.createTestAccount('Global HQ Account', null, null);
        testAcc1.GlobalHQAccount__c = losingAcc.Id;
        
        insert testAcc1;
         
         Account testOtherAcc = TestDataSetupUtility.createTestAccountWithShipping('Other-account');
         testOtherAcc.Registration__c = rn.id;
         insert testOtherAcc;
         
         rn.PrimaryBillingAccount__c = losingAcc.id;
         update rn;
         
        Contact con3 = TestDataSetupUtility.createTestContact(losingAcc.Id, 'Lose', 'Con', 'losecon@gmail.com');
        con3.LastName = 'Lose';
        con3.FirstName = 'Con';
         con3.PrimaryBillingContact__c = true;
         con3.PrimarySalesContact__c = true;
         con3.PrimaryServiceContact__c = true;
         
         //Added for T-566570
         con3.DONOTCALL = true;
         con3.AlternateDoNotEmail__c = true;
         con3.Home_Customer_Requested_Do__c = true;
         con3.Mobile_Customer_Requested_Do__c = true;
         con3.HasOptedOutOfFax = true;
         con3.HasOptedOutOfEmail = true;
         con3.AssistantPhone = '123456789';
         con3.MobilePhone = '123456789';
         con3.HomePhone = '123456789';
         con3.Phone='12344';
         insert con3;
         
        Contact con4 = TestDataSetupUtility.createTestContact(losingAcc.Id, 'Lose1', 'Con1', 'losecon112@gmail.com');
         insert con4;         
         
         Contact con5 = TestDataSetupUtility.createTestContact(losingAcc.Id, 'Lose', 'Con', 'loseco1n@gmail.com');
         con5.PrimaryBillingContact__c = true;
         con5.PrimarySalesContact__c = true;
         con5.PrimaryServiceContact__c = true;
         /*con.DoNotCall = true;
         con.AlternateDoNotEmail__c = true;
         con.Home_Customer_Requested_Do__c = true;
         con.Mobile_Customer_Requested_Do__c = true;
         con.HasOptedOutOfFax = true;
         con.HasOptedOutOfEmail = true;*/
         con5.MobilePhone = '1234567890';
         con5.Phone = '1234567890';
         con5.Email = 'abc123@gmail.com';
         con5.Fax = '1234567';
         con5.HomePhone = '1234567090';
         con5.AlternateEmail__c = 'abc123456@gmail.com';
         insert con5;
         
         Xcode__c xcode = new Xcode__c();        
         xcode.name = 'test1';
         insert xcode ;
         
         XcodeAccount__c xAcc = new XcodeAccount__c ();
         xAcc.Xcode__c = xcode.Id;
         xAcc.Account__c = winningAcc.Id;
         xAcc.IsPrimary__C = True;
         insert xAcc;
         xCodeList.add(xAcc);
        
        //Added 
         XcodeAccount__c xAcc2 = new XcodeAccount__c ();
         xAcc2.Xcode__c = xcode.Id;
         xAcc2.Account__c = winningAcc.Id;
         xAcc2.IsPrimary__C = True;
         insert xAcc2;
         xCodeList.add(xAcc2);
         
         XcodeAccount__c xAcc1 = new XcodeAccount__c ();
         xAcc1.Xcode__c = xcode.Id;
         xAcc1.Account__c = losingAcc.Id;
         insert xAcc1;
         xCodeList.add(xAcc1);
         
         Order__c ord = TestDataSetupUtility.createOrder(losingAcc.Id);
         ord.BillingContact__c = con3.id;
         ord.AgencyBillingContact__c = con3.id;
         ord.contact__c = con3.id;
         ord.Contact_for_Training__c = con3.id;
         ord.Posting_Contact__c = con3.id;
         ord.AgencyBillingContact__c = con3.id;
         ord.Primary_Contact__c = con3.id;
         ord.Send_Welcome_Letter_to__c = con3.id;
         ord.ShippingContact__c = con3.id;
         ord.PrContact__c = con3.id;
         insert ord;
         
         Opportunity opp =  TestDataSetupUtility.createTestOpportunity('TestAccount1', userinfo.getuserid());
         opp.Accountid =  losingAcc.id;
         opp.Champion__c = con3.id;
         opp.Economic_Buyer__c = con3.id;
         opp.Lead_Contact__c = con3.id;
         insert opp;
         
         Apttus_Proposal__Proposal__c ap = TestDataSetupUtility.createProposal(opp.Id);
         ap.AgencyBillingContact__c = con3.id;
         ap.BillContact__c = con3.id;
         ap.Contact__c = con3.id;
         ap.Contact_for_Training__c = con3.id;
         ap.Contact_for_Training__c = con3.id;
         ap.PostingContact__c = con3.id;
         ap.PrContact__c = con3.id;
         ap.Apttus_Proposal__Primary_Contact__c = con3.id;
         ap.Primary_Customer_Contact__c = con3.id;
         ap.Send_Welcome_Letter_to__c = con3.id;
         ap.billContact__c = con3.id;
         ap.PostingContact__c = con3.id;
         insert ap;
         
        Event ev = new Event();
        ev.Whoid=con3.id;
        ev.DurationInMinutes = 10;
        ev.ActivityDateTime = system.today();
        insert ev;
        
        Task ts = new Task();
        ts.whoId= con3.id;
        insert ts;
         
         // Related Partner 1
         RelatedPartner__c partner = new RelatedPartner__c();
         partner.Account__c = losingAcc.Id;
         partner.Partner__c = winningAcc.Id;
         //system.debug('---------------------' + opportunitytest.id);
         partner.Role__c = 'Agency';
         partner.AgencyType__c = 'Billing';        
         insert partner;
         
         CompetitiveLandscape__c comp = new CompetitiveLandscape__c ();
         comp.Account__c = winningAcc.Id;
         comp.Competitor__c = 'Apec';
         insert comp;
         
         comp = new CompetitiveLandscape__c ();
         comp.Account__c = losingAcc.Id;
         comp.Competitor__c = 'Apec';
         insert comp;
         
         Account acc= TestDataSetupUtility.createTestAccountWithShipping('Winning-Child-Account');
      
          acc.parentId =  winningAcc.Id;
          insert acc;
          
          acc= TestDataSetupUtility.createTestAccountWithShipping('Losing-Child-Account');
      
          acc.parentId =  losingAcc.Id;
          insert acc;
          
          acc= TestDataSetupUtility.createTestAccountWithShipping('Winning-HQ-Account');
          acc.DomesticHQAccount__c = losingAcc.Id; 
          insert acc;
          
          acc= TestDataSetupUtility.createTestAccountWithShipping('Winning-HQ1-Account');
          acc.DomesticHQAccount__c = winningAcc.Id; 
          insert acc;          
          //gd
          List<contact> conList = new List<Contact>();
        for(Contact c: [Select id from  Contact where id =: con.id ]){
            c.DoNotCall = true ;
            c.AlternateDoNotEmail__c = true;
                c.Home_Customer_Requested_Do__c = true;
                c.Mobile_Customer_Requested_Do__c = true;
                c.HasOptedOutOfFax = true;
                c.HasOptedOutOfEmail = true;
                c.AssistantPhone = '123456';  
         c.MobilePhone = '234567890';
            c.HomePhone = '234567890';
            c.Phone = '234567890';
            c.Email = 'a@b.com';
            conList.add(c);
             
        }
        try{
        AccountMergeHelper amh = new AccountMergeHelper();
        amh.mergeLosingContact(conlist);
        }
        catch(Exception e){
            
        }
    } 
}