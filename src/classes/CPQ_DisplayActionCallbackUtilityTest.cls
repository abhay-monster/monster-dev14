/* 
*Class Name : CPQ_DisplayActionCallbackUtilityTest
*Description :This test class test Action Callback.
*Created By  :Viraj
*Created On  :10/25/2016

* Modification log:
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*Developer                  Date                           Modification Id                       Description
*Viraj                     10/25/2016
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*
*
*/
@isTest
private class CPQ_DisplayActionCallbackUtilityTest{
    
    static testMethod void testActionCustomCallBack(){
        //Insert the User Role record
            UserRole oUserRole=  new UserRole(name = 'Test');
            insert oUserRole;
            
            //Insert the User record
            
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
            User ocreateUser  = new User(Alias = 'standt', Email='test@olympus.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,UserRoleId = oUserRole.id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='stestUser@testorg.com',EmployeeNumber='1234');
            insert ocreateUser;
            
            // Run Test Logic as Test User
            system.runAs(ocreateUser){
                Test.StartTest();
                //Insert the Account record
                Account oAccount = new Account();
                oAccount.Name='Test Account';
                oAccount.BillingPostalCode='12345';    
                insert oAccount;
                
                //Insert the AccountTeamMember record
                
                AccountTeamMember ATM=new AccountTeamMember(AccountId=oAccount.Id,TeamMemberRole='Test',UserId=ocreateUser.Id);
                insert ATM;
                
                //Insert the Opportunity record
                
                Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Opportunity; 
                Opportunity oOpportunity = new Opportunity();
                oOpportunity.AccountId = oAccount.Id;
                oOpportunity.Name='Test';
                oOpportunity.StageName = 'Stage 1 - Needs Assessment';
                oOpportunity.CloseDate = System.today();
                insert oOpportunity ;
                

                //Insert the Proposal record
                Apttus_Proposal__Proposal__c NewProposal = new Apttus_Proposal__Proposal__c();
                NewProposal.Apttus_Proposal__Proposal_Name__c='TestProposal';
                NewProposal.Apttus_Proposal__Opportunity__c=oOpportunity.id;         
                NewProposal.Apttus_Proposal__Account__c=oAccount.id;  
                insert NewProposal;
                
                
                
                
                //Insert the ProductConfiguration record
                Apttus_Config2__ProductConfiguration__c NewProductConf = new Apttus_Config2__ProductConfiguration__c(name='Product Config -'+ NewProposal.Apttus_Proposal__Proposal_Name__c,
                            Apttus_QPConfig__Proposald__c=NewProposal.id,Apttus_Config2__BusinessObjectId__c=NewProposal.id,Apttus_Config2__BusinessObjectType__c='Proposal');
                
                insert NewProductConf;
                system.debug('*************' +NewProductConf); 
                
                Apttus_Config2__ConfigCustomClasses__c oCustomSetting = new Apttus_Config2__ConfigCustomClasses__c();
                oCustomSetting .Name= 'Test';
                oCustomSetting.Apttus_Config2__DisplayActionCallbackCalss__c = 'CPQ_DisplayActionCallbackUtilityTest';
                insert oCustomSetting;
                Apttus_Config2__ConfigCustomDisplayActions__c  actionSO = new Apttus_Config2__ConfigCustomDisplayActions__c();
                actionSo.Apttus_Config2__DisplayType__c = 'Cart Line Item';
                actionSo.Apttus_Config2__ActionName__c = 'CustomAction24';
                Apttus_Config2.DisplayActionInfo disp  = new Apttus_Config2.DisplayActionInfo(actionSo);
                List<Apttus_Config2.DisplayActionInfo> displayActions = new List<Apttus_Config2.DisplayActionInfo>();
                displayActions.add(disp);
                Apttus_Config2.ProductConfiguration cart;
                Apttus_Config2.CustomClass.ActionParams params = new Apttus_Config2.CustomClass.ActionParams ();
                //Apttus_Config2.ActionParams cClass= new Apttus_Config2.ActionParams();
                //CPQ_DisplayActionCallbackUtility contlr= new CPQ_DisplayActionCallbackUtility();
                CPQ_DisplayActionCallbackUtility.prodConfigObj = NewProductConf;
                CPQ_DisplayActionCallbackUtility.ActionInfoList = displayActions ;
                CPQ_DisplayActionCallbackUtility.setActionProperties(null);
                //CPQ_DisplayActionCallbackUtility.start(cart,displayActions);
               
          }
    }
}