global class BatchKnowledgeGlobalSearch implements Database.Batchable<sObject>, Database.Stateful {
    Public String strArticleType;
    Public String strPublishStatus;
    Public String strLanguage;
    
    Private String strApexSearchJobId = ''; 
    Private String strApexReplacementJobId = ''; 
    
    Private Boolean bSearchOnly = false;
    Private Boolean bPublishNewVersion = true;
    Private Boolean bMultiLingualKB = false;
    Private Boolean bExecuteReplacement = false;

    Private List<String> listSelectedArticles;
    Private integer nMaxSizePlainTextBody = 16384; // Arbitrary - Have no idea how large the plain text body can be
        
    public String strSearchFields = ''; 
    public List<String> listSearchFields; 
    public String strSearchString = '';
    public String strReplacementString = '';

    public Integer UpdateCount = 0;
    public Integer TotalCount = 0;
    
    global BatchKnowledgeGlobalSearch(
        Boolean bSearchOnly, Boolean bPublishNewVersion, Boolean bMultiLingualKB,
        String strArticleType, String strPublishStatus, String strLanguage,
        String strSearchFields, String strSearchString, String strReplacementString) {
        
        //Future use: Date dateLastModifiedFrom, Date dateLastModifiedTo) {
        
        this.bSearchOnly = bSearchOnly;
        this.bPublishNewVersion = bPublishNewVersion;
        this.bMultiLingualKB = bMultiLingualKB;

        this.strArticleType = strArticleType;
        this.strPublishStatus = strPublishStatus;
        this.strLanguage = strLanguage;
        this.strSearchFields = strSearchFields;    
        this.listSearchFields = strSearchFields.split(',');
        this.strSearchString = strSearchString;
        this.strReplacementString = strReplacementString;
        
        this.listSelectedArticles = new List<String>();
        this.TotalCount = 0;
        this.UpdateCount = 0;        
    } 
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        this.strApexSearchJobId = BC.getJobId();
        
        // Return record Ids for all articles that meet high-level publish status and 
        // language constraints.  Note that internal and custom field values
        // are not returned here but, rather, in the execute method.  This minimizes
        // the physical size of the query locator and avoids governor constraints.
        String strQuery = '';
        strQuery += 'SELECT Id FROM '+this.strArticleType;
        strQuery += ' WHERE PublishStatus = \''+this.strPublishStatus+'\'';
        strQuery += ' AND Language = \''+this.strLanguage+'\'';
		
        return database.getquerylocator(strQuery);      
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
    	// Record Ids are concatenated to allow all articles
    	// for this batch scope to be returned in a single SOQL query
        String strScopeIds = '';
        for (sObject scopeObject : scope) {
            if (strScopeIds.length()>0) strScopeIds += ',';
            strScopeIds += '\''+(String)scopeObject.Id+'\'';
        }        
        
        // Base SOQL construct
        String strQuery = '';
        
        // Return all records for this batch scope in a single SOQL query, including internal
        // and custom field values for each article
        strQuery += 'SELECT Id, KnowledgeArticleId, ArticleNumber';
        // Include Title if not explicitly selected as a search field for email notification (log) purposes
        if (strSearchFields.toLowerCase().indexOf('title')<0) strQuery += ', Title';
        if (bMultiLingualKB) strQuery += ', IsMasterLanguage';        
        if (strSearchFields != null && strSearchFields.length()>0) strQuery += ','+strSearchFields;
        strQuery += ' FROM '+this.strArticleType;          
        strQuery += ' WHERE Id IN ('+strScopeIds+')';

        List <sObject> articles = new List<sObject>();
        
        try {
        	articles = Database.query(strQuery);
            globalSearchandReplace(articles);
        } catch (Exception ex){
            String errMsg = ex.getMessage();
            system.Debug(errMsg);
        } 
    }
    
    public void globalSearchAndReplace(List<sObject> batchArticles){
    	// Compile the user-defined search expression
        String strRegEx = this.strSearchString;
        Pattern strSearchStringPattern = Pattern.compile(strRegEx);  
        
        // Initialize list of replacement tasks (work items) for this batch scope
        List<KB_Global_Search_And_Replace__c> listGSR = new List<KB_Global_Search_And_Replace__c>();
        
        // Iterate across all articles queried in a single batch scope
        for(sObject article : batchArticles) {
            this.TotalCount++;
            
            // Determine if one (or more) selected field values contains the user-defined search expression.
            // This logic is used to identify which field(s) in a specific article require replacement.
            // The physical replacement is performed by a separate class (BatchKnowledgeGlobalReplace) to
            // support the much smaller scope size (50) required due to governor constraints specific to
            // knowledge article updates (which are not bulk-enabled) 
            String strReplacementFields = '';              
            if (listSearchFields.size() > 0) {
                for (String strFieldName: listSearchFields) {
                	// Apply pattern to next field value
                    String strFieldValue = (String)article.get(strFieldName);
                    if (strFieldValue == null) continue;
                    Matcher matcher = strSearchStringPattern.matcher(strFieldValue);

					// If this field value contains at least one occurrence of pattern, add to list
                    if (matcher.find()) {
                        if (strReplacementFields.length()>0) strReplacementFields += ',';
                        strReplacementFields +=strFieldName;
                    }
                }
            }
            
            // If at least one field has been identified, add article to replacement queue and audit log
            if (strReplacementFields.length()>0) {
                this.UpdateCount++;  

				// Add selected article to audit log
                this.listSelectedArticles.add('Article Number='+(String)article.get('ArticleNumber')+
                    ' Title='+(String)article.get('Title')+' Language='+strLanguage+'\n');
                
                // If performing a physical replacement, add new record (replacement task) to work queue.  This record
                // serves to identify those articles to be processed in the BatchKnowledgeGlobalReplace class.
                // These records stand independently and identify which field(s) in a specific article require replacement.
                if (!bSearchOnly) {         
                    KB_Global_Search_And_Replace__c modifyArticle = new KB_Global_Search_And_Replace__c();
                    
                    // Copy metadata from batch article to work queue
                    modifyArticle.Apex_BatchId__c = this.strApexSearchJobId;
                    modifyArticle.ArticleId__c = article.Id;
                    modifyArticle.Article_Type__c = this.strArticleType;
                    modifyArticle.ArticleNumber__c = (String)article.get('ArticleNumber'); 
                    modifyArticle.KnowledgeArticleId__c = (String)article.get('KnowledgeArticleId'); 
                    modifyArticle.PublishStatus__c = this.strPublishStatus;
                    modifyArticle.PublishNewVersion__c = String.valueOf(this.bPublishNewVersion);
                    modifyArticle.Language__c = String.valueOf(this.strLanguage);
                    modifyArticle.Field_Names__c = strReplacementFields;
                    modifyArticle.Search_String__c = this.strSearchString;
                    modifyArticle.Replacement_String__c = this.strReplacementString;
					if (bMultiLingualKB) {
						modifyArticle.IsMasterLanguage__c = String.valueOf((Boolean)article.get('IsMasterLanguage'));
					} else {
						modifyArticle.IsMasterLanguage__c = 'NA';
					}                

					// Add replacement task to list
                  	listGSR.add(modifyArticle);
                }                
            }
        }
        
        // If at least one replacement task has been identified, insert into physical work queue
        if (!bSearchOnly && listGSR != null && listGSR.size() > 0) {
        	this.bExecuteReplacement = true;
            try {
                Database.insert(listGSR);      
            } catch (Exception ex){
                String errMsg = ex.getMessage();
                system.Debug(errMsg);
            } 
         }        

    }
    
    global void finish(Database.BatchableContext BC) {
        // Launch physical replacement batch class, if required.  Note that the scope size defined
        // for the replacement batch job is limited to 50 articles.  This is required to avoid governor
        // constraints related to article updates which must be processed independently since the 
        // KbManagement.PublishingService class is not bulk-enabled.
        if (!bSearchOnly) {
        	if (bExecuteReplacement) {
            	BatchKnowledgeGlobalReplace batch = new BatchKnowledgeGlobalReplace(this.strApexSearchJobId);
            	this.strApexReplacementJobId = Database.executeBatch(batch, 50);  
        	} else {
        		this.strApexReplacementJobId = 'Not Executed'; 
        	} 
        } else {
        	this.strReplacementString = '**Search Only - No Replacement**';
        }
   
        KB_Global_Search_History__c searchHistory = new KB_Global_Search_History__c();
        // In parent controller, the Database.executebatch method only returns first 15 characters of job id
        searchHistory.Apex_BatchId__c = this.strApexSearchJobId;
        searchHistory.Articles_Searched__c = TotalCount;
        searchHistory.Articles_Selected__c = UpdateCount; 
        searchHistory.Apex_Replacement_BatchId__c = this.strApexReplacementJobId;
        searchHistory.Search_String__c = this.strSearchString;
        searchHistory.Replacement_String__c = this.strReplacementString;
        searchHistory.Field_Names__c = this.strSearchFields;
        searchHistory.Article_Type__c = this.strArticleType;
        searchHistory.PublishStatus__c = this.strPublishStatus;
        searchHistory.Language__c = this.strLanguage;
        searchHistory.PublishNewVersion__c = String.valueOf(this.bPublishNewVersion);
        
        try {
            Database.insert(searchHistory);      
        } catch (Exception ex){
            String errMsg = ex.getMessage();
            system.Debug(errMsg);
        }                          
                                    
        // Query the AsyncApexJob object to retrieve the current job's metadata.
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
           TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :this.strApexSearchJobId];             
               
        // Email the Batch Job's submitter that the Job is finished.
        // Note that this requires the email administration->deliverability->access level to be set to All Email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Salesforce Knowledge Global Search and Replace-Search Complete');
        String strPlainTextBody = 

         'Article Type='+this.strArticleType+'\n'+
         'Publish Status='+this.strPublishStatus+'\n'+
         'PublishNewVersion='+String.valueOf(this.bPublishNewVersion)+'\n'+
         'Language='+this.strLanguage+'\n'+             
         'Search Fields='+this.strSearchFields+'\n'+
         'Search String='+this.strSearchString+'\n'+
         'Replacement String='+this.strReplacementString+'\n\n\n'+
         'Total number of articles searched='+TotalCount+'\n'+
         'Total number of articles selected for update='+UpdateCount+'\n';
         
         if (!bExecuteReplacement) strPlainTextBody += '[No Replacement Job Executed]\n';
         
         strPlainTextBody += '\n\n'+
         'Salesforce.com Job Statistics:\n'+
         'Number of Errors='+a.NumberOfErrors+'\n'+
         'Status='+a.Status+'\n\n'+
         'Articles Identified for Replacement:\n';
             
        Integer nLogTitleCount = 0;
        if (this.listSelectedArticles != null && this.listSelectedArticles.size() > 0) {
            for (String strArticleLog : this.listSelectedArticles) {
                if (strPlainTextBody.length()<nMaxSizePlainTextBody ) {
                    nLogTitleCount++;
                    strPlainTextBody += strArticleLog+'\n';
                } else {
                    strPlainTextBody += '...'+(UpdateCount-nLogTitleCount)+' titles omitted';
                    break;
                }
            }
        } else {
            strPlainTextBody += 'None';
        }
         
        mail.setPlainTextBody(strPlainTextBody);
          
        if (!Test.isRunningTest()) {  
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });         
        }
    
    }
}