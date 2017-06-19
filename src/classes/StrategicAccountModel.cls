public with sharing class StrategicAccountModel {
    
    final String CLASSNAME = '\n\n**** StrategicAccountModel.METHODNAME()\n\n';
    
    public Account StrategicAccount{get;set;}
    
    public list<Contact> ContactList{get;set;}
    public list<CompetitiveLandscape__c> CompetitiveLandscapeList{get;set;}
    public list<ProposedSolution__c> ProposedSolutionList {get; set;}
    private list<Task> TaskList{get;set;}
    
    
    public list<Task> MonsterAnalysisTaskList{
        get{
            if(MonsterAnalysisTaskList == NULL){
                MonsterAnalysisTaskList = new list<Task>();
            }
            return MonsterAnalysisTaskList;
        }
        set;
    }
    public list<Task> ClientAnalysisTaskList{
        get{
            if(ClientAnalysisTaskList == NULL){
                ClientAnalysisTaskList = new list<Task>();
            }
            return ClientAnalysisTaskList;
        }
        set;
    }
    public String PrimarySalesManager{get;set;}
    public ProposedSolution__c ProposedProductTotal {get; set;}
    
    //for PDF Rendering
    public Map<String, String> AccountLabels {get; private set;}
    public Map<String, String> ContactLabels {get; private set;}
    public Map<String, String> CompetitiveLandscapeLabels {get; private set;}
    public Map<String, String> TaskLabels {get; private set;}
    public Map<String, String> ProposedSolutionLabels {get; private set;}
        
    public StrategicAccountModel(String pAccountId){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','StrategicAccountModel') + ' - constructor';
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        SetModelLists(pAccountId);
        SetAnalysisTaskLists();
        GetSobjectLabelsForPDFRendering();
    }
    
    private void GetSobjectLabelsForPDFRendering(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','StrategicAccountModel') + ' - getSobjectLabelsForPDFRendering';
    system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        Map<String, Map<String, String>> allFieldsBySObject = Utility.newInstance().getSObjectsFieldsLabels(new Set<String>{
            'Account', 'Contact', 'Task', 'CompetitiveLandscape__c', 'ProposedSolution__c'
        });
        AccountLabels = allFieldsBySObject.get('Account');
        system.debug('\n\nRemoving of (WWK) and (TBD) from field labels');
        for(String fieldAPIName : AccountLabels.keySet()){
            if(AccountLabels.get(fieldAPIName).indexOf('(WWK)') != -1){
                String newLabel = AccountLabels.remove(fieldAPIName).remove('(WWK)');
                AccountLabels.put(fieldAPIName, newLabel);
            }
            if(AccountLabels.get(fieldAPIName).indexOf('(TBD)') != -1){
                String newLabel = AccountLabels.remove(fieldAPIName).remove('(TBD)');
                AccountLabels.put(fieldAPIName, newLabel);
            }
        }
        ContactLabels = allFieldsBySObject.get('Contact');
        CompetitiveLandscapeLabels = allFieldsBySObject.get('CompetitiveLandscape__c');
        ProposedSolutionLabels = allFieldsBySObject.get('ProposedSolution__c');
        TaskLabels = allFieldsBySObject.get('Task');
        
        //hardcoded labels
        AccountLabels.put('primarysalesrep', 'Primary Sales Rep');
        AccountLabels.put('sfid', 'Account ID');
        AccountLabels.put('ATSVendor__c','ATS Vendor');
        //Story 1651, E2920
        //Dated Jan152015
        //AccountLabels.put('PrimaryAgencyContact__c','Primary Agency Contact');
        AccountLabels.put('Primary_Agency_Contact__c','Primary Agency Contact');
        AccountLabels.put('Region__c','Region');
        AccountLabels.put('AdditionalBudgetSource__c','Additional Budget Source');
        
        TaskLabels.put('owner', TaskLabels.get('ownerid').removeend('ID'));
        TaskLabels.put('activitydate', TaskLabels.get('activitydate').removeEnd('Only'));
        
        system.debug('ContactLabels : ' + ContactLabels);
        system.debug('CompetitiveLandscapeLabels : ' + CompetitiveLandscapeLabels);
        system.debug('TaskLabels : ' + TaskLabels);
    }
    
    private void SetModelLists(String pAccountId){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','SetModelLists');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        //Story 1651, E2920
        //Dated Jan152015
        StrategicAccount = [SELECT AccountID__c,AccountStatus__c,AdditionalAccountCommentary__c, AdditonalBudgetAvailable__c,AtRiskAccount__c,CentralizedBuying__c,ClientBusinessObjective__c,CustEmplSize__c,DomesticOnlineBudget__c,Goal__c,Id,KeyInitiative__c,InternationalOnlineBudget__c,Last12MonthsSpend__c,LevelJustification__c,LongTermStrategy__c,MasterHQ__c,MonsterBusinessObjective__c,Name, NewspaperValue__c,NumberofHires__c, NumberofLocations__c,OpportunityArea__c,OwnerId,ParentId,PenetrationLevel__c,PrimaryServiceRep__c,ShortTermStrategy__c,Strategy__c,Strengths__c,TotalAccountOpportunity__c,TotalSpend1YearPrior__c,TotalSpend2yearPrior__c,TrialCandidate__c,Value__c,Weaknesses__c,
                                                                OpportunityWWK__c, TechnologyWWK__c, RecruiterContactHabbitWWK__c, ObjectivesWWK__c, CostofNotPurchasingWWK__c,
                                                                OpportunityTBD__c, TechnologyTBD__c, RecruiterContactHabitsTBD__c, ObjectivesTBD__c, CostofNotPurchasingTBD__c,
                                                                NumberOfEmployees, NAP__c, PrimarySalesManager__c, Primary_Agency_Contact__c, Region__c, AdditionalBudgetSource__c, ATSVendor__c,
                                                                AgencyBilled__c, Hierarchy12MonthSpend__c, PrimaryRelatedAgency__c, ClientTurnoverRate__c,
                                (SELECT ActivityDate,Description,Id,Owner.Name,Status,Subject, AnalysisType__c FROM Tasks),
                                (SELECT Competitor__c, ContractValue__c,ExpDate__c,Hire__c,Id,Name,RelationshipStanding__c,TotalJobs__c FROM Competitive_Landscapes__r), 
                                (SELECT BusinessObjective__c,ContactType__c,Coverage__c,Email,Id,JobPosition__c,Motivation__c,Name,PotentialObjection__c,PrimaryPhoneNumber__c,Role__c,Status__c FROM Contacts),
                                (SELECT ProductDivision__c, ProductGroup__c, ProposedValue__c, ProblemAddressed__c FROM Proposed_Solutions__r)
                            FROM Account 
                            WHERE Id = :pAccountId];
        
        ContactList = StrategicAccount.Contacts;
        system.debug(LoggingLevel.DEBUG, METHODNAME + '\n\nCONTACT LIST :: ' + ContactList + '\n\n');
        CompetitiveLandscapeList = StrategicAccount.Competitive_Landscapes__r;
        system.debug(LoggingLevel.DEBUG, METHODNAME + '\n\nCOMPETITIVE LANDSCAPE LIST :: ' + CompetitiveLandscapeList + '\n\n');
        ProposedSolutionList = StrategicAccount.Proposed_Solutions__r;
        system.debug(LoggingLevel.DEBUG, METHODNAME + '\n\nPROPOSED SOLUTION LIST :: ' + ProposedSolutionList + '\n\n');
        TaskList = StrategicAccount.Tasks;
        system.debug(LoggingLevel.DEBUG, METHODNAME + '\n\nTASK LIST :: ' + TaskList + '\n\n');
        
        //adding of Proposed Product Total
        if(ProposedSolutionList != null && ProposedSolutionList.size() > 0){
            system.debug('Compute Proposed Product Total');
            ProposedProductTotal = new ProposedSolution__c();
            ProposedProductTotal.ProductDivision__c = 'Proposed Product Total';
            ProposedProductTotal.ProposedValue__c = 0;
            for(ProposedSolution__c ps : ProposedSolutionList){
                if(ps.ProposedValue__c != null){
                    ProposedProductTotal.ProposedValue__c += ps.ProposedValue__c;
                }
            }
            if(ApexPages.currentPage().getUrl().indexOf('StrategicAccountPlanPDF') == -1){
                ProposedSolutionList.add(ProposedProductTotal);
            }
            system.debug('ProposedProductTotal.ProposedValue__c: ' + ProposedProductTotal.ProposedValue__c);
        }
    }
    
    private void SetAnalysisTaskLists(){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','SetAnalysisTaskLists');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        if(!TaskList.isEmpty()){
            for(Task oTask : TaskList){
                if(oTask.AnalysisType__c == 'Monster Analysis'){
                    MonsterAnalysisTaskList.add(oTask);
                }
                if(oTask.AnalysisType__c == 'Client Analysis'){
                    ClientAnalysisTaskList.add(oTask);
                }
            }
            
            system.debug(LoggingLevel.DEBUG, METHODNAME + '\n\nMONSTER TASK LIST :: ' + MonsterAnalysisTaskList + '\n\n');
            system.debug(LoggingLevel.DEBUG, METHODNAME + '\n\nCLIENT TASK LIST :: ' + ClientAnalysisTaskList + '\n\n');
            
        }
    }
}