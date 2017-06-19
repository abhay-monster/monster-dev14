public with sharing class KnowledgeModel {
    static final String CLASSNAME = '\n\n**** KnowledgeModel.METHODNAME()';
    public static final String ROOT_URL = '/app';
    
    private static String GetLanguage(String pLanguage){
        return pLanguage == null ? 'en_US' : pLanguage;
    }
    
    //FOR TRAINING AND TUTORIAL TAB 
    public static TATArticleData getTrainingAndTutorialData(String pLanguage){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','getTrainingAndTutorialData');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{            
            map<Id, Knowledge_Parent_Article__c> parentArticles = new map<Id, Knowledge_Parent_Article__c>(
                                                                            [SELECT Id, Section_Title__c, Summary__c, Section_Header__c
                                                                            FROM Knowledge_Parent_Article__c
                                                                            WHERE LanguageCode__c = :GetLanguage(pLanguage)]);
            
            Training_Tutorial__ka[] articleList = [SELECT Id FROM Training_Tutorial__ka];                                                           
            Training_Tutorial__kav[] versionList = [SELECT Title, Id, Knowledge_Parent_Article__c, Summary, ArticleBody__c,
                                                                PDF__c, Purple_Link__c, Green_Link__c, Blue_Link__c, Doc__c
                                                                FROM Training_Tutorial__kav 
                                                                WHERE Knowledge_Parent_Article__c IN :parentArticles.keySet()
                                                                AND KnowledgeArticleId IN :articleList
                                                                AND PublishStatus = 'Online'
                                                                AND IsLatestVersion = true
                                                                ORDER BY CreatedDate ASC];
            
            map<Id, TATArticleWrap> parentArticleIdToModelMap = new map<Id, TATArticleWrap>();
            
            for(Training_Tutorial__kav kav : versionList){
                if(!parentArticleIdToModelMap.containsKey(kav.Knowledge_Parent_Article__c)){
                    TATArticleWrap pa = new TATArticleWrap();
                    pa.Articles = new TATArticleGroup[]{};
                    parentArticleIdToModelMap.put(kav.Knowledge_Parent_Article__c, pa);
                }
                if(parentArticleIdToModelMap.containsKey(kav.Knowledge_Parent_Article__c)){             
                    TATArticle ka = new TATArticle();
                    ka.Record = kav;
                    ka.Icons = createTATIconsFromArticles(kav);
                    parentArticleIdToModelMap.get(kav.Knowledge_Parent_Article__c).addArticles(ka);
                }
            }
            
            TATArticleData outputData = new TATArticleData();
            list<TATLink[]> links = new list<TATLink[]>();
            Id SectionHeaderToRemoveId;
            for(Knowledge_Parent_Article__c pa : parentArticles.values()){
                TATArticleWrap paw = parentArticleIdToModelMap.containsKey(pa.Id) ? parentArticleIdToModelMap.get(pa.Id) : new TATArticleWrap();
                paw.Record = pa;
                if(!parentArticleIdToModelMap.containsKey(pa.Id)){
                    parentArticleIdToModelMap.put(pa.Id, paw);
                }
                
                if(links.size() == 0 || (links.size() > 0 && links[links.size() -1].size() == 4)){
                    links.add(new TATLink[]{});
                }
                if(pa.Section_Title__c != null && pa.Section_Header__c != null){
                    TATLink link = new TATLink();
                    link.Label = pa.Section_Title__c;
                    link.HashTag = pa.Section_Title__c.replace(' ', '_');
                    links[links.size() - 1].add(link);
                }
                if(pa.Section_Header__c != null && parentArticles.containsKey(pa.Section_Header__c)){
                    outputData.Record = parentArticles.get(pa.Section_Header__c);
                    SectionHeaderToRemoveId = pa.Section_Header__c;
                }
            }
            if(SectionHeaderToRemoveId != null){
                parentArticleIdToModelMap.remove(SectionHeaderToRemoveId);
            }
            outputData.Links = links;
            outputData.Articles = parentArticleIdToModelMap.values();
            
            return outputData;
        }catch(Exception e){
            system.debug('Error: ' + e);
            system.debug('Error trace: ' + e.getStackTraceString());
            return null;
        }
    }
    
    private static TATIcon[] createTATIconsFromArticles(Training_Tutorial__kav pKav){
        TATConstants constants = new TATConstants();
        
        TATIcon[] icons = new TATIcon[]{};
        
        TATIcon[] PDFIcons = createTATIconsFromString(pKav.PDF__c, constants.PDF);
        if(PDFIcons.size() > 0) icons.addAll(PDFIcons);
        
        TATIcon[] DocIcons = createTATIconsFromString(pKav.Doc__c, constants.DOC);
        if(DocIcons.size() > 0) icons.addAll(DocIcons);
        
        TATIcon[] PurpleIcons = createTATIconsFromString(pKav.Purple_Link__c, constants.PURPLE);
        if(PurpleIcons.size() > 0) icons.addAll(PurpleIcons);
        
        TATIcon[] GreenIcons = createTATIconsFromString(pKav.Green_Link__c, constants.GREEN);
        if(GreenIcons.size() > 0) icons.addAll(GreenIcons);
        
        TATIcon[] BlueIcons = createTATIconsFromString(pKav.Blue_Link__c, constants.BLUE);
        if(BlueIcons.size() > 0) icons.addAll(BlueIcons);
        
        return icons;
    }
    
    private static TaTIcon[] createTATIconsFromString(String pIcons, String IconStyle){
        TATIcon[] icons = new TATIcon[]{};
        if(pIcons == null){
            return icons;
        }
        String[] txtList = pIcons.split(',');
        for(String txt : txtList){
            TATIcon icon = new TATIcon(txt, IconStyle);
            icons.add(icon);
        }
        return icons;
    }
    
    public class TATConstants{
        public final String PDF = 'PDF_IMG';
        public final String DOC = 'DOC_IMG';
        public final String BLUE = 'BLUE_IMG';
        public final String GREEN = 'GREEN_IMG';
        public final String PURPLE = 'PURPLE_IMG';
    }
    
    public class TATIcon{
        public String URL {get; set;}
        public Boolean isPDF {get; set;}
        public Boolean isDOC {get; set;}
        public Boolean isGREEN {get; set;}
        public Boolean isBLUE {get; set;}
        public Boolean isPURPLE {get; set;}
        
        public TATIcon(String pURL, String pStyle){
            TATConstants constants = new TATConstants();
            
            URL = pURL;
            isPDF = pStyle == constants.PDF ? true : false;
            isDOC = pStyle == constants.DOC ? true : false;
            isGREEN = pStyle == constants.GREEN ? true : false;
            isBLUE = pStyle == constants.BLUE ? true : false;
            isPURPLE = pStyle == constants.PURPLE ? true : false;
        }
    }
    
    public class TATArticleData{
        public Knowledge_Parent_Article__c Record {get; set;}
        
        public list<TATLink[]> Links {get{
            if(Links == null){
                list<TATLink[]> output = new list<TATLink[]>();
                output.add(new TATLink[]{});
                return output;
            }else{
                return Links;
            }
        } set;}
        
        public TATArticleWrap[] Articles {get{
            return Articles == null ? new TATArticleWrap[]{} : Articles;
        } set;}
    }
    
    public class TATLink{
        public String Label {get; set;}
        public String HashTag {get; set;}
    }
    
    public class TATArticleWrap{
        public String URL {get{return Record.Section_Title__c == null ? '' : Record.Section_Title__c.replace(' ', '_');}}
        public Knowledge_Parent_Article__c Record {get; set;}
        public TATArticleGroup[] Articles {get{return Articles != null ? Articles : new TATArticleGroup[]{};} set;}
        
        public void addArticles(TATArticle pArticle){
            TATArticleGroup g;
            if(Articles.size() == 0 || (Articles.size() > 0 && Articles[Articles.size() - 1].Done)){
                g = new TATArticleGroup();
                Articles.add(g);
            }else{
                g = Articles[Articles.size() - 1];              
            }           
            g.add(pArticle);
        }
    }
    
    public class TATArticleGroup{
        public TATArticle Left {get; set;}
        public TATArticle Right {get; set;}
        public Boolean Done {get{ return Left != null && Right != null;}}
        public  void add(TATArticle pArticle){
            if(Left == null){
                Left = pArticle;
            }else{
                Right = pArticle;
            }
        }
    }
    
    public class TATArticle{
        public TATIcon[] Icons {get; set;}
        public Training_Tutorial__kav Record {get; set;}
    }
    
    //FOR OVERVIEW TAB
    /* Jeff L. Commented out due to missing G_ka
    public static OverviewCategory[] getOverviewCategories(String pLanguage){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','getOverviewCategories');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        map<String, OverviewCategory> output = new map<String, OverviewCategory>();
        try{
            G_ka[] articleList = [SELECT Id FROM G_ka];
            
            String kavQuery = 'SELECT Title, UrlName, Show_in_Overview_Category__c, Video_Link__c '
                                    + 'FROM G_kav '
                                    + 'WHERE '
                                    + 'language = \''+GetLanguage(pLanguage)+'\' '
                                    + 'AND PublishStatus = \'Online\' '
                                    + 'AND IsLatestVersion = true '
                                    + 'AND KnowledgeArticleId IN :articleList  '
                                    + 'AND (Show_in_Overview_Category__c != \'\' OR Show_in_Overview_Category__c != null)';
            G_kav[] versionList = Database.query(kavQuery);
            
            for(G_kav v : versionList){
                if(!output.containsKey(v.Show_in_Overview_Category__c)){
                    OverviewCategory cat = new OverviewCategory();
                    cat.CategoryTitle = v.Show_in_Overview_Category__c;
                    cat.items = new OverviewItem[]{};
                    output.put(v.Show_in_Overview_Category__c, cat);
                }
                OverviewItem item = new OverviewItem();
                item.label = v.Title;
                item.PageLink = v.UrlName;
                item.VideoLink = v.Video_Link__c;
                output.get(v.Show_in_Overview_Category__c).items.add(item);
            }
        }catch(Exception e){
            system.debug('\n\nError on getOverviewCategories: ' + e + '\n\n');
        }
        return output.values();
    }*/
    public class OverviewCategory{
        public String CategoryTitle {get; set;}
        public OverviewItem[] items {get; set;}
    }
    public class OverviewItem{
        public String label {get; set;}
        public String PageLink {get; set;}
        public String VideoLink {get; set;}
        public Boolean HasVideo {get{return !(VideoLink == null);}}
    }
}