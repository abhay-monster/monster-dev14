@isTest
public class StrategicAccountModelTest {
	static testmethod void testStrategicAccountModel()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = TestDataSetupUtility.createTestUser('TestFistName', 'TestLastName', p.Id);
        insert u;              
            
        System.runAs(u) 
        {
            Test.startTest();
        
            Account testAccount = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TEST PB Account');//, 'North America', UserInfo.getUserId());
            testAccount.Phone = '+18008008000';
            testAccount.BillingCountry = 'Philippines';
            testAccount.PrimaryServiceRep__c = u.id;
            testAccount.Organization__c = 'Europe';
            testAccount.ServiceTier__c = 'Core';
            insert testAccount;
            
            StrategicAccountModel objb = new StrategicAccountModel(testAccount.Id+'');
            list<Task> tsklst = objb.MonsterAnalysisTaskList;
            list<Task> tskLst2 = objb.ClientAnalysisTaskList;
            
            Contact testContact1 = TestDataSetupUtility.createTestContact(testAccount.Id, 'PrimaryBillingTestLastnameOne', 'PrimaryBillingTestFirstnameOne', 'email1@testContact.com');
            testContact1.PrimaryBillingContact__c = true;
            insert testContact1;
            
            Account StrategicAccount = [SELECT AccountID__c,AccountStatus__c,AdditionalAccountCommentary__c, AdditonalBudgetAvailable__c,AtRiskAccount__c,CentralizedBuying__c,ClientBusinessObjective__c,CustEmplSize__c,DomesticOnlineBudget__c,Goal__c,Id,KeyInitiative__c,InternationalOnlineBudget__c,Last12MonthsSpend__c,LevelJustification__c,LongTermStrategy__c,MasterHQ__c,MonsterBusinessObjective__c,Name, NewspaperValue__c,NumberofHires__c, NumberofLocations__c,OpportunityArea__c,OwnerId,ParentId,PenetrationLevel__c,PrimaryServiceRep__c,ShortTermStrategy__c,Strategy__c,Strengths__c,TotalAccountOpportunity__c,TotalSpend1YearPrior__c,TotalSpend2yearPrior__c,TrialCandidate__c,Value__c,Weaknesses__c,
                                                                OpportunityWWK__c, TechnologyWWK__c, RecruiterContactHabbitWWK__c, ObjectivesWWK__c, CostofNotPurchasingWWK__c,
                                                                OpportunityTBD__c, TechnologyTBD__c, RecruiterContactHabitsTBD__c, ObjectivesTBD__c, CostofNotPurchasingTBD__c,
                                                                NumberOfEmployees, NAP__c, PrimarySalesManager__c, Primary_Agency_Contact__c, Region__c, AdditionalBudgetSource__c, ATSVendor__c,
                                                                AgencyBilled__c, Hierarchy12MonthSpend__c, PrimaryRelatedAgency__c, ClientTurnoverRate__c,
                                (SELECT ActivityDate,Description,Id,Owner.Name,Status,Subject, AnalysisType__c FROM Tasks),
                                (SELECT Competitor__c, ContractValue__c,ExpDate__c,Hire__c,Id,Name,RelationshipStanding__c,TotalJobs__c FROM Competitive_Landscapes__r), 
                                (SELECT BusinessObjective__c,ContactType__c,Coverage__c,Email,Id,JobPosition__c,Motivation__c,Name,PotentialObjection__c,PrimaryPhoneNumber__c,Role__c,Status__c FROM Contacts),
                                (SELECT ProductDivision__c, ProductGroup__c, ProposedValue__c, ProblemAddressed__c FROM Proposed_Solutions__r)
                            FROM Account 
                            WHERE Id = :testAccount.Id];
            
            system.assertEquals(objb.StrategicAccount.Id,StrategicAccount.Id);
            Test.stopTest();
        }
    }
}