/**
* @description Controller class for the knowledge landing page
* @author Cloudsherpas
* @date 7-10-2014
*/
public with sharing class KnowledgeHomeCC {
  final String CLASSNAME = '\n\n**** KnowledgeHomeCC.METHODNAME()';
    
    public String[] tests {get{return tests == null ? new String[]{} : tests;} set;}
    
    public Boolean showOverview {get{return tab == 'overview';}}
    public Boolean showAnswers {get{return tab == 'answers';}}
    public Boolean showTuts {get{return tab == 'training_tutorials';}}
    public Boolean showAsk {get{return tab == 'ask';}}
    public Boolean showSearch {get{return !showTuts;}}
    
    public String PageLanguage {get{return language;}}
    
    private String language;
    private String type;
    private String tab;
    private String article;
/**
* @description The constuctor
* @author Cloudsherpas
* @date 7-10-2014
*/     
    public KnowledgeHomeCC(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','Contructor');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        tests = new String[]{};
        language = ApexPages.currentPage().getParameters().get('language');
        type = ApexPages.currentPage().getParameters().get('type');
        tab = ApexPages.currentPage().getParameters().get('tab');
        article = ApexPages.currentPage().getParameters().get('article');
        
        if(ApexPages.currentPage().getParameters().size() > 0){
            tests.add('URL Parameters:');
            for(String p : ApexPages.currentPage().getParameters().keySet()){
                tests.add(p+' = ' +ApexPages.currentPage().getParameters().get(p));
            }
        }
    }
    
    public String getCurrentTab(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','getCurrentTab');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        return tab;
    }
    
    public String getCurrentState(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','getCurrentState');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        String output = KnowledgeModel.ROOT_URL;
        output += language == '' ? '' : '/' + language;
        output += type == '' ? '' : '/' + type;
        return output;
    }
    
    public KnowledgeModel.OverviewCategory[] getOverviewCats(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','getOverviewCats');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        if(showOverview){
            try{
               //Jeff L. commented out due to issue with method return KnowledgeModel.getOverviewCategories(PageLanguage);
            }catch(Exception e){
                tests.add('ERROR: ' + e);
            }
        }
        return new KnowledgeModel.OverviewCategory[]{};
    }
    
    public KnowledgeModel.TATArticleData getTATData(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','getTATData');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        if(showTuts){
            try{
                return KnowledgeModel.getTrainingAndTutorialData(PageLanguage);
            }catch(Exception e){
                tests.add('ERROR: ' + e);
            }
        }
        return new KnowledgeModel.TATArticleData();
    } 
}