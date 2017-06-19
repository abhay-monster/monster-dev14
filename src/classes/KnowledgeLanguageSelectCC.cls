public with sharing class KnowledgeLanguageSelectCC {
    private map<String, String> LanguageCodeToLabel;
    private String Prefix;
    private Knowledge_Parent_Article__c ParentArticleRecord;
    public String CancelURL {get; set;}
    
    public Boolean IsDelete {get; set;}
    public Boolean IsDisplay {get{return !IsDelete;}}
    public SelectOption[] LanguageOptions {get; set;}
    public String SelectedLanguage {get; set;}
    public String[] trial {get; set;}
    public String ArticleName {get; set;}
    
    public KnowledgeLanguageSelectCC(ApexPages.Standardcontroller sc){
        try{
            trial = new String[]{};         
            Prefix = Schema.Sobjecttype.Knowledge_Parent_Article__c.getKeyPrefix();
            
            if(ApexPages.currentPage().getParameters().containsKey('Id')){
                Id kpaID = ApexPages.currentPage().getParameters().get('Id');
                ParentArticleRecord = [SELECT Id, Name, LanguageCode__c, LanguageLabel__c FROM Knowledge_Parent_Article__c WHERE Id = :kpaID];
                ArticleName = ParentArticleRecord.Name;
                CancelURL = '/' + ParentArticleRecord.Id;
            }else{
                ParentArticleRecord = new Knowledge_Parent_Article__c();
                ArticleName = 'New';
                CancelURL += '/' + Prefix + '/o';
            }
            
            if(!ApexPages.currentPage().getParameters().containsKey('isDelete')){
                IsDelete = false;
                init();
            }else{
                IsDelete = true;
                CancelURL = '/' + Prefix + '/o';
            }
        }catch(Exception e){
            system.debug('\n\nKnowledgeLanguageSelectCC.Error on SelectLanguage: ' + e + '\n\n');
            trial.add('Error: Unable to initialize. Please contact your administrator.');
        }
    }
    
    public PageReference DeleteCanceledRecord(){
        if(IsDelete){
            delete ParentArticleRecord;
            return new PageReference(CancelURL);
        }
        return null;
    }
    
    private void init(){        
        Map<String, Map<String, Schema.SObjectField>> objFields = Utility.newInstance().getAllSObjectFieldsBySObjectName(new set<String>{'Training_Tutorial__kav'});
        Schema.SObjectField languageField = objFields.get('Training_Tutorial__kav').get('language');
        Schema.DescribeFieldResult fieldDescribe = languageField.getDescribe();
        
        LanguageCodeToLabel = new map<String, String>();
        LanguageOptions = new SelectOption[]{};
        SelectOption[] LanguageOptionsTemp = new SelectOption[]{};
        
        for(Schema.PicklistEntry pe : fieldDescribe.getPicklistValues()){
            if(pe.isActive()){
                SelectOption option = new SelectOption(pe.getValue(), pe.getLabel());
                LanguageCodeToLabel.put(pe.getValue(), pe.getLabel());
                
                if(pe.getLabel() == 'English'){
                    LanguageOptions.add(option);
                    SelectedLanguage = pe.getValue();
                }else{
                    LanguageOptionsTemp.add(option);
                }
            }
        }
        
        LanguageOptions.addAll(LanguageOptionsTemp);
    }
    
    public PageReference SelectLanguage(){
        try{
            if(ParentArticleRecord != null){
                ParentArticleRecord.LanguageCode__c = SelectedLanguage;
                ParentArticleRecord.LanguageLabel__c = LanguageCodeToLabel.get(SelectedLanguage);
                upsert ParentArticleRecord;
            }
            
            return new PageReference('/'+ParentArticleRecord.Id);
        }catch(Exception e){
            system.debug('\n\nKnowledgeLanguageSelectCC.Error on SelectLanguage: ' + e + '\n\n');
            trial.add('Error: Unable to continue. Please contact your administrator.');
            return null;
        }
    }
    
    public PageReference CancelLanguage(){
        return new PageReference(CancelURL);
    } 
}