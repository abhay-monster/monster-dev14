public with sharing class KB_Global_Search_and_Replace {
    Public Integer nArticlesWithLinksCount {get;set;}
    Public Transient List<SObject> kav {get;set;}

    Public String strArticleType {get;set;}
    Public String strPublishStatus {get;set;}
    Public String strLanguage {get;set;}

    Public String[] strFields {get;set;}
    Public String strSearchFields {get;set;}
    
    Public String strSearchString {get;set;}
    Public String strReplacementString {get;set;}
    
    Public String strApexBatchId {get;set;}
    Public Decimal nArticlesSearched {get;set;}
    Public Decimal nArticlesSelected {get;set;}
    Public Decimal nArticlesUpdated {get;set;}    
    Public String strSearchStatus {get;set;}
    
    Public Boolean bSearchOnly {get;set;}
    Public Boolean bDisableRegex {get;set;}
    Public Boolean bCaseSensitive {get;set;}
    Public Boolean bPublishNewVersion {get;set;}    
    Public Boolean bMultiLingualKB;
    Public Boolean bProcessing {get;set;}

    //builds a picklist of article types
    public List<selectOption> getArticleTypes() {
        List<selectOption> options = new List<selectOption>(); 
        options.add(new selectOption('None', 'Select an Article Type'));
        
        Map<String, Schema.SObjectType> mapGlobalDescribe = Schema.getGlobalDescribe();
        Set<String> setMapKeys = mapGlobalDescribe.keySet();
        
        for (String key : setMapKeys) {
            Schema.SObjectType objectType = mapGlobalDescribe.get(key);
            if (key.endsWith('__kav')) {
                options.add(new selectOption(key, objectType.getDescribe().getLabel()));             
            }
        }        
                                        
        return options; 
    } 
    
    //builds a picklist of article types
    public List<selectOption> getPublishStatus() {
        List<selectOption> options = new List<selectOption>(); 
        options.add(new selectOption('Draft', 'Draft')); 
        options.add(new selectOption('Online', 'Published')); 
        //options.add(new selectOption('Archived', 'Archived')); 
                                        
        return options; 
    }     
    
    // Builds a picklist of language codes
    public List<selectOption> getLanguage() {
        // Derive list of active knowledge langauges from KnowledgeArticle object
        Schema.Describefieldresult describeLanguage = KnowledgeArticleVersion.fields.Language.getDescribe();
        List<Schema.PicklistEntry> listLanguage = describeLanguage.getPicklistValues();
        
        if (listLanguage.size() > 1) bMultiLingualKB = true;

        List<selectOption> options = new List<selectOption>(); 
        // Search for default Language, force to top of list if present
        String strDefaultLanguage = '';
        for (Schema.PicklistEntry pe: listLanguage) {
            if (pe.isActive() && pe.isDefaultValue()) {
                options.add(new selectOption(pe.getValue(), '***'));
                strDefaultLanguage = pe.getValue();
                break;
            }
        }           
        for (Schema.PicklistEntry pe: listLanguage) {
            if (pe.isActive() && !(pe.getValue().equals(strDefaultLanguage))) {
                options.add(new selectOption(pe.getValue(), pe.getLabel()));
            }
        }        
                             
        return options; 
    }     
 
    public List<SelectOption> getArticleFields() {
        if (this.strArticleType == null || this.strArticleType.equals('None')) return null;
        
        sObject sObjArticleType = Schema.getGlobalDescribe().get(strArticleType).newSObject();
        Schema.DescribeSObjectResult descArticleType = sObjArticleType.getSObjectType().getDescribe();
        Map<String, Schema.SObjectField> mapArticleTypeFields = descArticleType.fields.getMap();        
    
        List<SelectOption> options = new List<SelectOption>();
            
        Set<String> setFieldNames = mapArticleTypeFields.keySet();
        for (String strFieldName : setFieldNames) {
            Schema.DescribeFieldResult descSObjectField = mapArticleTypeFields.get(strFieldName).getDescribe();
        
            if (descSObjectField.getType() == Schema.DisplayType.String
                || descSObjectField.getType() == Schema.DisplayType.TextArea) {
                
                // Toss out all unsupported (internal or metadata) text fields
                String strFieldNameLC = strFieldName.toLowerCase();
                
                if (strFieldNameLC.equals('urlname'))continue;
                if (strFieldNameLC.equals('articlenumber')) continue;
                if (strFieldNameLC.endsWith('name__s')) continue; // FILE field type label (field__name__s)
                
                options.add(new SelectOption(strFieldName, descSObjectField.getLabel()));                  
            }
        }
        
        return options;
    }
     
    public KB_Global_Search_and_Replace() {
        bSearchOnly = false;
        bDisableRegex = false;
        bCaseSensitive = false;
        bPublishNewVersion = true;
        bMultiLingualKB = false;
        bProcessing = false;

        this.strFields = new String[]{};
        if (strSearchString == null) strSearchString = '';
        
        this.strSearchStatus = 'Waiting for User Input';
        this.nArticlesSearched = 0;
        this.nArticlesSelected = 0;
        this.nArticlesUpdated = 0;      
        
        this.strArticleType = 'None';
        this.strLanguage = 'en_US';
    }
        
    public void performSearch() {
        if (!Test.isRunningTest()) {
            strSearchFields = '';
            for (String strFieldSelection : strFields) {
                if (strSearchFields.length()>0) strSearchFields += ',';
                strSearchFields += strFieldSelection;
            }           
        } else {      
            strSearchFields = 'Title';          
        }
        
        if (!(strSearchFields.length()>0)) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'No Search Field(s) Selected');
            ApexPages.AddMessage(msg);          
        } else {
            String strRegexString = strSearchString;
            if (bDisableRegex) strRegexString = '\\Q'+strRegexString+'\\E';
            if (!bCaseSensitive) strRegexString = '(?i)'+strRegexString;
            
            Integer nActiveBatchJobs = [select count() from AsyncApexJob where JobType = 'BatchApex' and status in ('Queued','Processing','Preparing')];
    
            if(nActiveBatchJobs > 4){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Maximum of 5 Active Batch Jobs Allowed');
                ApexPages.AddMessage(msg);
                this.strSearchStatus = 'System Busy - Please try your request later';            
            } else {        
                BatchKnowledgeGlobalSearch batch =
                new BatchKnowledgeGlobalSearch(bSearchOnly, bPublishNewVersion, bMultiLingualKB,
                    strArticleType, strPublishStatus, strLanguage, 
                    strSearchFields, strRegexString, strReplacementString);
                if (!Test.isRunningTest()) {        
                    try {
                        this.strApexBatchId = Database.executeBatch(batch, 500);
                        this.strSearchStatus = 'Searching...';  
                        this.bProcessing = true;          
                    } catch (Exception ex){
                        String errMsg = ex.getMessage();
                        system.Debug('*** KB Global Search and Replace *** - Exception:'+errMsg);
                        this.strSearchStatus = 'System Busy - Please try your request later';
                    } 
                }
            }
        }
        
        this.nArticlesSearched = 0;
        this.nArticlesSelected = 0;
        this.nArticlesUpdated = 0;          
    }
          
    public void refresh() {
        String strQuery = '';
        System.debug('this.strApexBatchId='+this.strApexBatchId);
        List<KB_Global_Search_History__c> listSearchHistory = new List<KB_Global_Search_History__c>();
        
        strQuery += 'SELECT Articles_Searched__c, Articles_Selected__c, Articles_Updated__c, Apex_Replacement_BatchId__c';
        strQuery += ' FROM KB_Global_Search_History__c';
        strQuery += ' WHERE Apex_BatchId__c LIKE \'%'+this.strApexBatchId+'%\' ';
        
        listSearchHistory = Database.query(strQuery);
        
        /*
        [SELECT Articles_Searched__c,
            Articles_Selected__c, Articles_Updated__c, Apex_Replacement_BatchId__c
            FROM KB_Global_Search_History__c WHERE Apex_BatchId__c LIKE '%:this.strApexBatchId%'];
        */
        
        if (listSearchHistory != null && listSearchHistory.size() >0) {
                
            this.strSearchStatus = 'Search Complete';
            
            this.nArticlesSearched = listSearchHistory[0].Articles_Searched__c;
            this.nArticlesSelected = listSearchHistory[0].Articles_Selected__c; 
            this.nArticlesUpdated = listSearchHistory[0].Articles_Updated__c;             
            String replacementJobId = listSearchHistory[0].Apex_Replacement_BatchId__c;
            
            if (!bSearchOnly) {
                if (replacementJobId.equals('Not Executed')) {
                    this.strSearchStatus+='-Replacement Not Executed';
                    this.bProcessing = false;
                } else {
                    strQuery = '';
                    List<AsyncApexJob> jobList = new List<AsyncApexJob>();
                    strQuery += 'SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems';
                    strQuery += ' FROM AsyncApexJob';
                    strQuery += ' WHERE Id =\''+replacementJobId+'\' ';
                    
                    jobList = Database.query(strQuery);            
                    
                    if (jobList != null && jobList.size()>0) {
                        AsyncApexJob job = jobList[0];
                        /*[Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems 
                              from AsyncApexJob where Id =:replacementJobId];     */
                        if (job.Status.equals('Processing')) {
                            this.strSearchStatus+='-Replacement Pending';
                            this.bProcessing = true;  
                        }        
                        if (job.Status.equals('Completed')) {
                            this.strSearchStatus+='-Replacement Complete'; 
                            this.bProcessing = false;
                        }
                    }  
                }
            } else {
                this.bProcessing = false;
            }           
        }        
    } 
}