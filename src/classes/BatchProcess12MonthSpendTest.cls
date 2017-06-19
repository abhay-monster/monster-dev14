@isTest
public with sharing class BatchProcess12MonthSpendTest {
    static testMethod void test(){
        //parent account creation
        Account[] parentAccounts = new Account[]{};
        for(Integer i = 0; i < 3; i++){
            parentAccounts.add(TestDataSetupUtility.createTestAccountWithShippingAndBilling('Parent  ' + i));
        }
        insert parentAccounts;
        
        //Child account creation
        Map<Id, Account[]> parentIdTochildAccounts = new Map<Id, Account[]>();
        Account[] childAccunts = new Account[]{};
        Opportunity[] oppList = new Opportunity[]{};
        for(Account pa : parentAccounts){
            if(!parentIdTochildAccounts.containsKey(pa.Id)){
                parentIdTochildAccounts.put(pa.Id, new Account[]{});
            }
            Opportunity opp = TestDataSetupUtility.createTestOpportunity('Opp for ' + pa.Name, pa.Id);
            oppList.add(opp);
            
            for(Integer c = 0; c < 2; c++){
                Account ca = TestDataSetupUtility.createTestAccountWithShippingAndBilling(pa.Name + ' Child Account ' + parentIdTochildAccounts.get(pa.Id).size());
                ca.ParentId = pa.Id;
                childAccunts.add(ca);
                parentIdTochildAccounts.get(pa.Id).add(ca);
            }
        }
        
        //insert childAccunts;
        insert oppList;
        
        OpportunityCompetitor__c[] comps = new OpportunityCompetitor__c[]{};
        Apttus_Proposal__Proposal__c[] proposals = new Apttus_Proposal__Proposal__c[]{};
        for(Opportunity opp : oppList){
            OpportunityCompetitor__c competitor = TestDataSetupUtility.createOpportunityCompetitor(opp);
            comps.add(competitor);
            
            Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c();
            proposal.Apttus_Proposal__Account__c = opp.AccountId;
            proposal.Apttus_Proposal__Opportunity__c = opp.Id;
            proposals.add(proposal);
        }
        insert comps;
        insert proposals;
        
        //Order Creation
        Order__c[] OrderList = new Order__c[]{};
        Apttus_Proposal__Proposal_Line_Item__c[] plis = new Apttus_Proposal__Proposal_Line_Item__c[]{};
        for(Apttus_Proposal__Proposal__c p : proposals){
            Apttus_Proposal__Proposal_Line_Item__c pli = new Apttus_Proposal__Proposal_Line_Item__c();
            pli.Apttus_Proposal__Proposal__c = p.Id;
            pli.Apttus_QPConfig__NetPrice__c = 100;
            plis.add(pli);
            
            Order__c o = new Order__c();
            o.OrderStatus__c = 'Verified';
            o.OrderDate__c = Date.today().addMonths(-11);
            o.Account__c = p.Apttus_Proposal__Account__c;
            o.QuoteProposal__c = p.Id;
            o.Opportunity__c = p.Apttus_Proposal__Opportunity__c;
            o.BillingAccount__c = o.Account__c;
            o.ShippingAccount__c = o.Account__c;
            OrderList.add(o);
        }
        insert plis;
        insert OrderList;
        
        Test.StartTest();
            BatchProcessService12MonthSpend service = new BatchProcessService12MonthSpend();
            Date currentDate = Date.today();
            Date last12Months = currentDate.addMonths(-12);
            Account[] accounts = Database.query(service.GetQuery());
            service.ProcessBatch((SObject[])accounts);
            //BatchProcess12MonthSpend batch = new BatchProcess12MonthSpend();
        Test.StopTest();
        for(Account a : [SELECT Name, Hierarchy12MonthSpend__c, Last12MonthsSpend__c FROM Account]){
            system.debug('\n\nName: ' + a.Name+'\n');
            system.debug('\n\t--Hierarchy12MonthSpend__c: ' + a.Hierarchy12MonthSpend__c+'\n');
            system.debug('\n\t--Last12MonthsSpend__cName: ' + a.Last12MonthsSpend__c+'\n');
        }
    }
    
    static testMethod void testGettingAllHierarchyViaTopLevelAccount(){
        Account[] parentAccounts = new Account[]{};
        for(Integer i = 0; i < 3; i++){
            parentAccounts.add(TestDataSetupUtility.createTestAccountWithShippingAndBilling('Parent  ' + i));
        }
        insert parentAccounts;
        
        Map<Id, Account[]> parentIdTochildAccounts = new Map<Id, Account[]>();
        Account[] childAccunts = new Account[]{};
        for(Account pa : parentAccounts){
            if(!parentIdTochildAccounts.containsKey(pa.Id)){
                parentIdTochildAccounts.put(pa.Id, new Account[]{});
            }
            
            for(Integer c = 0; c < 3; c++){
                Account ca = TestDataSetupUtility.createTestAccountWithShippingAndBilling(pa.Name + ' Child Account ' + parentIdTochildAccounts.get(pa.Id).size());
                ca.ParentId = pa.Id;
                childAccunts.add(ca);
                parentIdTochildAccounts.get(pa.Id).add(ca);
            }
        }
        
        insert childAccunts;
        
        Map<Id, Account[]> parentIdTochildAccounts1 = new Map<Id, Account[]>();
        Account[] childAccunts1 = new Account[]{};
        for(Account pa : childAccunts){
            if(!parentIdTochildAccounts1.containsKey(pa.Id)){
                parentIdTochildAccounts1.put(pa.Id, new Account[]{});
            }
            
            for(Integer c = 0; c < 2; c++){
                Account ca = TestDataSetupUtility.createTestAccountWithShippingAndBilling(pa.Name + ' Child Account Inner ' + parentIdTochildAccounts1.get(pa.Id).size());
                ca.ParentId = pa.Id;
                childAccunts1.add(ca);
                parentIdTochildAccounts1.get(pa.Id).add(ca);
            }
        }
        
        insert childAccunts1;
        
        BatchProcessServiceHierarchySpend t = new BatchProcessServiceHierarchySpend(parentIdTochildAccounts.keySet());
        map<Id, Account[]> testMap = new map<Id, Account[]>();
        Integer testChildCount = 0;
        for(Account a : parentAccounts){
            testMap.put(a.Id, t.getAllAccountsInHierarchy(a));
            testChildCount += testMap.get(a.Id).size();
        }
        t.GetQuery();
        t.GetQueryLocator('select id from account');
        t.ProcessBatch(parentAccounts);
        t.getAllAccountsInHierarchy(parentIdTochildAccounts1.keyset());
        t.FinishBatch();
        for(Account pa : parentAccounts){
            system.debug('*Parent ' + pa.Name);
            if(testMap.containsKey(pa.Id)){
                for(Account ca : testMap.get(pa.Id)){
                    system.debug('   - ' + ca.Name);
                }
            }
        }
        system.debug('Test List size: ' + testMap.size());
        //system.assertEquals(testChildCount, childAccunts.size());
    } 
}