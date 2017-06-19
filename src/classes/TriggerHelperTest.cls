//
// (c) 2015 Appirio, Inc.
//
//  Test class for TriggerHelper
//
// Sep 03, 2015     Vivek Ojha      Original 
//
@isTest
private class TriggerHelperTest {

    static testMethod void myUnitTest() {
        
        Test.startTest();
        IntegrationConfig__c intConfig = new IntegrationConfig__c(
            Name = 'USPS Integration',
            AvalaraClient__c = '',
            AvalaraCompanyCode__c = '',
            AvalaraCountry__c = '',
            EndpointName__c = 'USPSAddressValidation',
            Password__c = '',
            PaypalPartner__c = '',
            PaypalRedirectURL__c = '',
            PaypalVendor__c = '',
            Timeout__c = 120000,
            Username__c = '',
            USPSUserID__c = '562CLOUD2615'
        );
        insert intConfig;
        
        WebServiceEndpoint__c wse = new WebServiceEndpoint__c(Name='USPSAddressValidation', Endpoint__c='http://production.shippingapis.com/ShippingAPI.dll');
        insert wse;

        List<Account> actLst = new List<Account>();
        //List<Account_Team_Member__c> atmLst = new List<Account_Team_Member__c>();
        
        Personal_Settings__c ps = new Personal_Settings__c();
        ps.Trigger_Account_Contact_Association__c = true;
        Id PROFILE_ID = [select Id From Profile Where Name = 'Standard User'].Id;        
        insert ps;
        
        Id PROFILE_ID2 = [select Id From Profile Where Name = 'System Administrator'].Id;
        
        User u=TestDataSetupUtility.createTestUser('test','test',PROFILE_ID);
        insert u;
        
         User usr=TestDataSetupUtility.createTestUser('test2','test',PROFILE_ID2);
        insert usr;
        
        Account acc = TestDataSetupUtility.createTestAccount('Test','test',UserInfo.getUserId());
        acc.OwnerId= u.id;
        
        
 
        actLst.add(acc);
        insert actLst;
        
        AccountTeamMember mem1 =  new AccountTeamMember();
        mem1.AccountId = actLst[0].Id;
        mem1.UserId = usr.id;
        mem1.TeamMemberRole = 'Primary Sales Rep';
        insert mem1;
        
      
        
        List<Contact> contList = new List<Contact>();
        Contact contact2 = TestDataSetupUtility.createTestContact(acc.Id, 'Test Last Name', 'Test First Name', 'test@gmail.com');
       // contact2.AccountId=acc.Id;
        contact2.InternetType__c = 'Internet Billing';
        contact2.PrimaryBillingContact__c=true;
        contact2.PrimarySalesContact__c=true;
        contact2.PrimaryServiceContact__c=true;
        contList.add(contact2);
        //insert contact2;
        insert contList;
        
        TriggerHelper helper1 = new TriggerHelper();
        //helper1.CreatePrimaryAccountTeamMembers(actLst);
        
        
        TriggerHelper helper2 = TriggerHelper.NewTriggerHelper('test');
        TriggerHelper helper3 = TriggerHelper.NewTriggerHelper();
        
        List<Account_Team_Member__c> lstATM;
        
        lstATM = new List<Account_Team_Member__c>();
        
        lstATM.add(new Account_Team_Member__c(
            AccountId__c = acc.Id,
            TeamMemberRole__c = 'Sales Rep',
            UserId__c = UserInfo.getUserId(),
            AccountAccessLevel__c = 'Read/Write',
            CaseAccessLevel__c = 'Read/Write'
        ));
        lstATM.add(new Account_Team_Member__c(
            AccountId__c = acc.Id,
            TeamMemberRole__c = 'PrimarySalesRep',
            UserId__c = TestDataSetupUtility.createUser('System Administrator', true).Id,
            AccountAccessLevel__c = 'Read/Write',
            CaseAccessLevel__c = 'Read/Write'
        ));
        System.debug('hello world see '+usr.Id);
        System.assertNotEquals(u.Id, lstATM[1].UserId__c);
        System.debug('Hello World1 '+u.Id);
        System.debug('Hello World2 '+ lstATM[1].UserId__c);
        System.debug('Hello World2 '+ lstATM[0].UserId__c);
        
        lstATM.add(new Account_Team_Member__c(
            AccountId__c = acc.Id,
            TeamMemberRole__c = 'Service Rep',
            UserId__c = TestDataSetupUtility.createUser('System Administrator', true).Id,
            AccountAccessLevel__c = 'Read/Write',
            CaseAccessLevel__c = 'Read/Write'
        ));
        lstATM.add(new Account_Team_Member__c(
            AccountId__c = acc.Id,
            TeamMemberRole__c = 'Primary Service Rep',
            UserId__c = TestDataSetupUtility.createUser('System Administrator', true).Id,
            AccountAccessLevel__c = 'Read/Write',
            CaseAccessLevel__c = 'Read/Write'
        ));
        System.runAs(usr)
               
        {       
            lstATM[1].UserId__c= UserInfo.getUserId();
            System.debug('Hello World Primary Sales changed user Id '+lstATM[1].TeamMemberRole__c+'-'+lstATM[1].UserId__c);
            
            insert lstATM;
         
        }
        helper1.CreateAccountTeamMembers(lstATM);
       
       // helper1.ManagePrimarySalesAndServiceContact(contList);
        
        map<Id,Account> accountMap = new map<Id,Account>([Select ID,OwnerId,PrimaryServiceRep__c from Account Where Id =: acc.Id]);
        map<String, list<Account>> mapAccTeam = new map<String, list<Account>>();
        map<Id,Account_Team_Member__c> mapAT = new map<Id,Account_Team_Member__c>();
        for(Account_Team_Member__c member : [Select ID,TeamMemberRole__c,AccountId__c from Account_Team_Member__c ]){
            if(!mapAccTeam.containsKey(member.TeamMemberRole__c)) {
                mapAccTeam.put(member.TeamMemberRole__c,new list<Account>());
            }
            mapAccTeam.get(member.TeamMemberRole__c).add(accountMap.get(member.AccountId__c));
            
            if(!mapAT.containsKey(member.id)) {
                mapAT.put(member.id,member);
            }
           
        }
        helper1.UpdatePrimaryServiceRepOnAccount(lstATM,mapAT,mapAT);
        //helper1.UpdatePrimaryAccountTeamMembers(accountMap.keySet(), mapAccTeam);
        //system.debug('***mapAccTeam*' +mapAccTeam);
        //helper1.UpdatePrimaryAccountTeamMembers2(accountMap.keySet(), mapAccTeam);
        //helper1.CreatePrimaryAccountTeamMember(acc);
       // helper1.CreateAccountTeamMembers(lstATM);
        helper1.SyncStandardAndCustomAccountTeamMembers(new set<Id>{acc.Id});
        helper1.updateAccountDataLastUnteamed(lstATM);
        helper1.UpdateAccountTeamMembers(lstATM);
        helper1.UpdateContactOrganization(new set<Id>{acc.Id});
        helper1.UpdatePrimaryServiceRep(lstATM); 
          System.debug('Checkthislistintest '+contList);
        //helper1.ManagePrimarySalesAndServiceContact(contList);
      
       // helper1.ManagePrimarySalesAndServiceContact(contlist);
        Test.stopTest();
    
    }
}