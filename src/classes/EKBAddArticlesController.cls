public class EKBAddArticlesController {

    Id BrandId {get;set;}
    String Language {get;set;}
    Set<id> setExisting = new Set<id>();
    public List<KnowledgeArticleVersion> newArticles;
    public List<ArticleWrapper> listWrapper ;
    public List<ArticleWrapper> listWrapperForConversion = new List<ArticleWrapper>();
    
    public EKBAddArticlesController(){
        BrandId = ApexPages.currentpage().getparameters().get('brand');
        Language = ApexPages.currentpage().getparameters().get('lang');

    }
 
    public List<KnowledgeArticleVersion> getNewArticles(){

        for(Article_Relationship__c ar: [Select id,Knowledge_Article_Id__c From Article_Relationship__c Where Brand__c = :BrandId]){
            setExisting.add(ar.Knowledge_Article_Id__c);
        }
        system.debug('Language ' + Language);

        List<KnowledgeArticleVersion> listArticles = Database.Query('Select id, ArticleNumber, Title,Summary,ArticleType, KnowledgeArticleId From KnowledgeArticleVersion Where Language = \''+language+'\' and PublishStatus = \'Online\' and ArticleType = \'Answers__kav\'');
        List<KnowledgeArticleVersion> newListArticles = new List<KnowledgeArticleVersion>();
        Map<id,String> mapCategories = new Map<id,string>();
        for(Answers__DataCategorySelection a: [select DataCategoryName, Id, ParentId from Answers__DataCategorySelection]){
            mapCategories.put(a.ParentId,a.DataCategoryName);
        }
        System.Debug('###'+listArticles);
        System.debug('###'+setExisting);
        for(KnowledgeArticleVersion kav: listArticles){
            if(setExisting.isEmpty() || !setExisting.contains(kav.id)){
                newListArticles.add(kav);
                ArticleWrapper aw = new ArticleWrapper();
                aw.isSelected = false;
                aw.article = kav;
                aw.DataCategoryName = mapCategories.get(kav.id);
                listWrapper.add(aw);
            }

        }
        return newListArticles;
    }

    public List<ArticleWrapper> getlistWrapper(){

        for(Article_Relationship__c ar: [Select id,Knowledge_Article_Id__c From Article_Relationship__c Where Brand__c = :BrandId]){
            setExisting.add(ar.Knowledge_Article_Id__c);
        }

        List<KnowledgeArticleVersion> listArticles = Database.Query('Select id, Title,ArticleNumber,Summary,ArticleType,KnowledgeArticleId From KnowledgeArticleVersion Where Language = \''+language+'\' and PublishStatus = \'Online\' and ArticleType = \'Answers__kav\' ');
        Map<id,String> mapCategories = new Map<id,string>();
        for(Answers__DataCategorySelection a: [select DataCategoryName, Id, ParentId from Answers__DataCategorySelection]){
            mapCategories.put(a.ParentId,a.DataCategoryName);
        }
        List<KnowledgeArticleVersion> newListArticles = new List<KnowledgeArticleVersion>();
        System.Debug('### listArticles'+listArticles);
        System.debug('### setExisting'+setExisting);
        List<ArticleWrapper> listWrap = new List<ArticleWrapper>();
        for(KnowledgeArticleVersion kav: listArticles){
            if(setExisting.isEmpty() || !setExisting.contains(kav.id)){
                newListArticles.add(kav);
                ArticleWrapper aw = new ArticleWrapper();
                aw.isSelected = false;
                aw.article = kav;
                //aw.DataCategoryName = mapCategories.get(kav.id);
                listWrap.add(aw);
                //Vivek
                listWrapperForConversion.add(aw);
            }

        }
        System.Debug('###'+listWrap);
        System.Debug('###'+listWrapperForConversion);
        //return listWrapperForConversion;
        return listWrap;
    }

    public pagereference add(){
        List<Article_Relationship__c> artRelLst = new List<Article_Relationship__c>();
        System.debug('listWrapperForConversion =='+listWrapperForConversion);
        for(ArticleWrapper art : listWrapperForConversion){
            if(art.isSelected){
                Article_Relationship__c art_Rel = new Article_Relationship__c();
                art_Rel.Knowledge_Article_Id__c =art.article.Id;
                art_Rel.Title__c = art.article.Title;
                art_Rel.Summary__c = art.article.Summary;
                art_Rel.Brand__c =  BrandId;
                art_Rel.Article_Type__c = art.article.ArticleType;
                art_Rel.Article_Id__c = art.article.KnowledgeArticleId;
                //art_Rel.Data_Category_Name__c = art.DataCategoryName;
                art_Rel.Article_Number__c = art.article.ArticleNumber;
                artRelLst.add(art_Rel);
            }
        }
        insert artRelLst;
        System.debug('art_Rel =='+artRelLst);
        return null;
    }

    public pagereference retURL(){
        String returl = ApexPages.currentpage().getparameters().get('returl');
        PageReference pageref = new PageReference('/'+returl);
        return pageref;
    }

    public class ArticleWrapper{
        public boolean isSelected {get;set;}
        public KnowledgeArticleVersion article {get;set;}
        public String DataCategoryName {get;set;}
    }

}