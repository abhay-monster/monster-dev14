@isTest
public class StrategicAccountPlanNewCCTest {
    static testmethod void testStrategicAccountPlanNewCC()
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
            
            
            Strategic_Account_Plan__c saptest = new Strategic_Account_Plan__c(Account_Name__c =testAccount.Id);
            insert saptest;
            
            Contact con = TestDataSetupUtility.createTestContact(testAccount.Id, 'confirst1', 'conlast1', 'con1@email.com');
            insert con;
            Order__c testOrder = TestDataSetupUtility.createOrder(testAccount.Id, con.Id);
            testOrder.OrderStatus__c='Open' ; 
            insert testOrder;
            
            Order_Line_Item__c orderLineItem = TestDataSetupUtility.createOrderLineItem(testOrder.Id);
            insert orderLineItem;
            
            ApexPages.StandardController sc = new ApexPages.StandardController(saptest);
            StrategicAccountPlanNewCC obj = new StrategicAccountPlanNewCC(sc);
            
            product2 prod = TestDataSetupUtility.createProduct('test Prod',true);
            
            list<Task> taklst1 = obj.MonsterAnalysisTaskList;
            list<Task> taklst2 = obj.ClientAnalysisTaskList;
            String str = obj.NewTabAsPDF;
            
            StrategicAccountPlanNewCC.AccountStrategyRow childObj = new StrategicAccountPlanNewCC.AccountStrategyRow('Test',saptest.Account_Name__c);
            childObj = new StrategicAccountPlanNewCC.AccountStrategyRow('Test','Test',saptest.Account_Name__c,prod.Id);
            childObj = new StrategicAccountPlanNewCC.AccountStrategyRow('Test','Test', prod.Id, saptest.Account_Name__c, null, 0, 0); 
            double quant = childObj.quantity;
            double price = childObj.netPrice;
            date endDt = childObj.endDate;
            list<StrategicAccountPlanNewCC.AccountStrategyRow> rowData = obj.asRowData;
            
            Strategic_Account_Plan__c tmpSapList = [SELECT Goal__c, Strategy__c, Name, Account_Name__c, Account_Name__r.AccountStatus__c,
                         Account_Name__r.GlobalHQAccount__c, Account_Name__r.Region__c, BillingAgency__c,
                         Account_Name__r.PrimaryAgencyContact__c, Account_Name__r.NumberofLocations__c,
                         Account_Name__r.NumberofEmployeesTotal__c, Trial_Candidate__c, At_Risk_Account__c,
                         Additional_Account_Commentary__c, Long_Term_Strategy__c, Short_Term_Strategy__c,
                         Account_Name__r.OwnerId, Account_Name__r.PrimarySalesManager__c,
                         Account_Name__r.PrimaryServiceRep__c, Account_Name__r.NAP__c, Account_Name__r.MasterHQ__c,
                         Centralized_Buying__c, Client_Turnover_Rate__c, Number_of_Hires__c, Key_Initiative__c,
                         Penetration_Level__c, Level_Justification__c,
                         Total_Account_Opportunity__c, International_Online_Budget__c, Domestic_Online_Budget__c,
                         Newspaper_Value__c, Account_Name__r.TotalSpend1YearPrior__c, Account_Name__r.TotalSpend2yearPrior__c,
                         Account_Name__r.Last12MonthsSpend__c, Account_Name__r.Hierarchy12MonthSpend__c,
                         Monster_Business_Objective__c, Monster_Strengths__c, Monster_Weaknesses__c,
                         ApplyScreens__c,InterestCapture__c,SourceAttribution__c,SourceAttributionTag__c,
                         ApplyTimeHours__c,ApplyTimeMinutes__c,JobPostingTemplate__c,
                         Client_Business_Objective__c, Value__c, Opportunity_Area__c,MeasurementofSuccess__c,VendorEvaluationKeyMetrics__c,
                         JobPostingMethod__c,ApplyMethod__c,ApplyMethodLocation__c,ATS_Vendor__c,CustomApplyRedirect__c,Opportunity_WWK__c, Objectives_WWK__c, Recruiter_Habits_WWK__c, Technology_WWK__c,
                         Cost_of_Not_Purchasing_WWK__c, Opportunity_TBD__c, Objectives_TBD__c, Recruiter_Habits_TBD__c,
                         Technology_TBD__c, Cost_of_Not_Purchasing_TBD__c,Additional_Budget_Available__c,Additional_Budget_Source__c,
                          Account_Name__r.Parent_Account_Number__c,Agency_Billed__c, Recordtype.Name, of_Crawled_Jobs__c,All_Jobs_URL__c,Career_Center_URL__c,Date_Received__c,Estimated_Budget__c,
                          Sales_Channel__c,Tracking_Enabled__c,Tracking_Enabled_Detail__c,Website__c,Plan_Type__c,Global_HQ_Account__c,Account_Status__c,Parent_Account_ID__c,Region__c,Primary_Agency_Contact__c,
                          Number_of_Locations__c,Number_of_Employees_Total__c, Account_Activity__c, Account_Classification__c, Injestion_Type__c 
                    FROM Strategic_Account_Plan__c WHERE ID =: saptest.Id];
            
            obj.PrimarySalesManager ='test';
            Map<String, String> tmpStrategicLabels = obj.StrategicLabels;
            system.assertEquals(tmpSapList, obj.sapLIst);
            
            Test.stopTest();
        }
    }
}