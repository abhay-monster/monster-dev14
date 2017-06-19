public class EKBController {

    public Brand__c Brand {get; set;}
    public String lang {get;set;}
    public String TitleURL {get;set;}
    public String Section1Name {get;set;}
    public String Section2Name {get;set;}
    public String Section3Name {get;set;}
    public String Section4Name {get;set;}
    public List<KnowledgeArticleVersion> Section1 {get;set;}
    public List<KnowledgeArticleVersion> Section2 {get;set;}
    public List<KnowledgeArticleVersion> Section3 {get;set;}
    public List<KnowledgeArticleVersion> Section4 {get;set;}
    public List<KnowledgeArticleVersion> SearchResults {get;set;}
    public KnowledgeArticleVersion Details {get;set;}
    public Sobject Detail {get;set;}
    public Contact_Us_Options__c ContactForm {get;set;}
    public Case ContactUs {get;set;}
    public string SearchString {get;set;}
    public List<Article_Relationship__c> listAr {get;set;}
    public boolean RatingSubmitted {get;set;}
    public ArticleWrapper AW {get;set;}
    public static List<KnowledgeArticleVersion> listSuggest {get;set;}
    public static List<Article_Relationship__c> arSuggest {get;set;}
    public Attachment attach {get;set;}
    private Map<String,List<String>> mapCountryStates {get;set;}
    
    private static Attachment Attachment;

    public Attachment getAttachment(){
        if( Attachment == null){
            Attachment = new Attachment();
        }
        return Attachment;
    }

    public void setAttachment(Attachment attach){
        Attachment = attach;
    }

    //Method called on initialisation of each EKB VF page
    public EKBController(){
        List<Brand__c> lstBrands = new list<Brand__c>();
        if(Brand == null){
            if(apexpages.currentpage().getparameters().get('brand') != null){
                lstBrands = [Select id, ISO_Language__c, Language__c, Available_Country__c, Default_Country__c, Monster_Site__c, Title_URL__c, Home_Section_1__c, Home_Section_2__c, Home_Section_3__c, Home_Section_4__c, Contact_Us__c,Brand_Tag__c, Training__c, Default_Tab__c, Audience__c, Previous_Employers_Field_Visible__c, Company_Name_Visible__c, Categories__c,Dynamic_S_Account__c,Default_Region__c, Footer_1__c, Footer_1_URL__c,Footer_2__c, Footer_2_URL__c,Footer_3__c, Footer_3_URL__c,Footer_4__c, Footer_4_URL__c,Footer_5__c, Footer_5_URL__c
                        From Brand__c
                        Where Active__c = true and Brand_Tag__c = :apexpages.currentpage().getparameters().get('brand') Limit 1];
            }
            else{
                lstBrands = [Select id, ISO_Language__c, Language__c, Available_Country__c, Default_Country__c, Monster_Site__c, Title_URL__c, Home_Section_1__c, Home_Section_2__c, Home_Section_3__c, Home_Section_4__c, Contact_Us__c,Brand_Tag__c, Training__c, Default_Tab__c, Audience__c, Previous_Employers_Field_Visible__c, Company_Name_Visible__c, Categories__c,Dynamic_S_Account__c,Default_Region__c, Footer_1__c, Footer_1_URL__c,Footer_2__c, Footer_2_URL__c,Footer_3__c, Footer_3_URL__c,Footer_4__c, Footer_4_URL__c,Footer_5__c, Footer_5_URL__c
                        From Brand__c
                        Where Is_Master__c = true];
            }
            Brand = lstBrands[0];
            lang = Brand.ISO_Language__c;
            TitleURL = Brand.Title_URL__c;
        }
    }

    //Called on action method of EKBLanding
    //Method decides based on Brand field which page the user should be directed to
    public PageReference setLanding(){

        if(brand.Default_Tab__c == 'Answers'){
            PageReference pageRef = new PageReference('/EKBAnswers?brand='+Brand.Brand_Tag__c);
            pageRef.setRedirect(false);
            return pageRef;
        }
        else if(brand.Default_Tab__c == 'Training'){
            PageReference pageRef = new PageReference('/EKBTraining?brand='+Brand.Brand_Tag__c);
            pageRef.setRedirect(false);
            return pageRef;
        }
        else if(brand.Default_Tab__c == 'Contact Us'){
            PageReference pageRef = new PageReference('/EKBContactUs?brand='+Brand.Brand_Tag__c);
            pageRef.setRedirect(false);
            return pageRef;
        }
        else{
            PageReference pageRef = new PageReference('/EKBHome?brand='+Brand.Brand_Tag__c);
            pageRef.setRedirect(false);
            return pageRef;
        }
    }

    //Called on action method of EKBHome
    //Method creates the lists for each of 4 sections of content
    public pagereference setupHomePage(){
        if(Brand.Home_Section_1__c != null){
            Section1Name = Brand.Home_Section_1__c.replace(' ','_');
            Section1Name = Section1Name.replace('/','_');
        }
        if(Brand.Home_Section_2__c != null){
            Section2Name = Brand.Home_Section_2__c.replace(' ','_');
            Section2Name = Section2Name.replace('/','_');
        }
        if(Brand.Home_Section_3__c != null){
            Section3Name = Brand.Home_Section_3__c.replace(' ','_');
            Section3Name = Section3Name.replace('/','_');
        }
        if(Brand.Home_Section_4__c != null){
            Section4Name = Brand.Home_Section_4__c.replace(' ','_');
            Section4Name = Section4Name.replace('/','_');
        }
        System.Debug('###'+Section1Name);
        System.Debug('###'+Section4Name);
        Set<id> ArticleIds = new Set<id>();

        for(Article_Relationship__c ar:[Select id, Article_Id__c, article_type__c, Data_Category_Name__c From Article_Relationship__c Where Brand__c= :Brand.Id]){
            ArticleIds.add(ar.Article_Id__c);
        }

        if(ArticleIds.size() > 0){
            if(Section1Name != null)Section1 = Database.Query('Select id, Title, KnowledgeArticleId From KnowledgeArticleVersion Where islatestversion = true and publishstatus = \'Online\' and language = :lang and KnowledgeArticleId = :ArticleIds WITH DATA CATEGORY EKB__c AT ('+Section1Name+'__c) Limit 5');
            if(Section2Name != null)Section2 = Database.Query('Select id, Title, KnowledgeArticleId From KnowledgeArticleVersion Where islatestversion = true and publishstatus = \'Online\' and language = :lang and KnowledgeArticleId = :ArticleIds WITH DATA CATEGORY EKB__c AT ('+Section2Name+'__c) Limit 5');
            if(Section3Name != null)Section3 = Database.Query('Select id, Title, KnowledgeArticleId From KnowledgeArticleVersion Where islatestversion = true and publishstatus = \'Online\' and language = :lang and KnowledgeArticleId = :ArticleIds WITH DATA CATEGORY EKB__c AT ('+Section3Name+'__c) Limit 5');
            if(Section4Name != null)Section4 = Database.Query('Select id, Title, KnowledgeArticleId From KnowledgeArticleVersion Where islatestversion = true and publishstatus = \'Online\' and language = :lang and KnowledgeArticleId = :ArticleIds WITH DATA CATEGORY EKB__c AT ('+Section4Name+'__c) Limit 5');
        }
        return null;
    }

    //Called on action method of EKBContactUs
    //Queries for relevant Contact Us Details to render on page
    public pagereference setupContactUs(){
        List<Contact_Us_Options__c> lstCUO = new List<Contact_Us_Options__c>();
        lstCUO = [Select id, Top_Left_Title__c, Top_Left_Body__c, Top_Right_Title__c, Top_Right_Body__c, Main_Content_Title__c, Main_Content_Body__c, Name, Display_Privacy_Message__c From Contact_Us_Options__c Where Id = :Brand.Contact_Us__c];
        if(lstCUO.size() > 0){ContactForm = lstCUO[0];}
        ContactUs = new Case();
        ContactUs.SystemGenerated__c = True;
        RecordType rt = [Select id From RecordType Where SobjectType ='Case' and Name = 'GCS'];
        ContactUs.RecordTypeId = rt.id;
        Contactus.Organization__c = Brand.Default_Region__c;
        ContactUs.BillingCountry__c = Brand.Default_Country__c;
        Attachment = new Attachment();
        
        // S-445811
        //TKOM 1/16/17: I had to comment out the following two lines due to Dev > QA migration failures for S-452049.  Once migration to QA is complete, I will revert it back.
        mapCountryStates = DependentPicklistUtility.GetDependentOptions('Case', 'BillingCountry__c', 'BillingStateProvince__c');
        system.debug(mapCountryStates);
        return null;

    }

    //Called on action method of EKBAnswers
    //Produces a default list of SearchResults
    public pagereference getResults(){
        System.debug('###'+SearchResults);
        Set<id> ArticleIds = new Set<id>();
        List<List<Sobject>> listSearch = new List<list<Sobject>>();

        for(Article_Relationship__c ar:[Select id, Knowledge_Article_Id__c, article_type__c, Article_id__c From Article_Relationship__c Where Brand__c= :Brand.Id]){
            ArticleIds.add(ar.Article_Id__c);
        }
        
        
        SearchString = apexpages.currentpage().getparameters().get('search');

        string type = apexpages.currentpage().getparameters().get('type');
        if(SearchString!= null){
            //SearchResults = Database.Query('Select id, Title, LastModifiedDate, Summary, KnowledgeArticleId From KnowledgeArticleVersion Where KnowledgeArticleId = :ArticleIds and islatestversion = true and PublishStatus = \'Online\' and Language = :lang and (Title Like \'%'+SearchString + '%\' or Summary Like \'%'+SearchString+'%\')');
            // TKOM S-452049 - use "escapeSingleQuotes()" method to handle apostrophe/single quote in search string passed to SOQL query
            listSearch = Search.Query('FIND \'' + string.escapeSingleQuotes(SearchString) + '\' IN ALL FIELDS RETURNING KnowledgeArticleVersion(id, Title, LastModifiedDate, Summary, KnowledgeArticleId WHERE KnowledgeArticleId = :ArticleIds and islatestversion = true and language = :lang and publishstatus = \'Online\')');
            SearchResults = ((List<KnowledgeArticleVersion>)listSearch[0]);
        }
        else if(type != null){
            SearchResults = Database.Query('Select id, Title, LastModifiedDate, Summary, KnowledgeArticleId From KnowledgeArticleVersion Where KnowledgeArticleId = :ArticleIds and PublishStatus = \'Online\' and islatestversion = true WITH DATA CATEGORY EKB__c AT ('+type+'__c)');
        }
        else{
            SearchResults = [Select id, Title, LastModifiedDate, Summary, KnowledgeArticleId
                            From KnowledgeArticleVersion
                            Where KnowledgeArticleId = :ArticleIds and language = :lang and PublishStatus = 'Online' and islatestversion = true ];
        }
        return null;
    }

    //Called on action method of EKBDetail
    //Queries for relevant Article content
    public pagereference getArticleDetails(){
        String id = apexpages.currentpage().getparameters().get('id');
        String url = apexpages.currentpage().getParameters().get('url'); // Jeff L added for I-196028
        String query = 'Select id, title, summary, articletype, LastModifiedDate, KnowledgeArticleId From KnowledgeArticleVersion ';

        /*New requirement - need to be able to query by either Article ID or URL
        *first we will check if query string contains a url or id, and then query based upon that
        Implemented for I-196028*/
        if(url != null){
            query += 'Where PublishStatus=\'Online\' And Language = \'' +Brand.ISO_Language__c+'\' AND UrlName=\''+url+'\'';
            system.debug(query);
            Details = Database.Query(query);
        }
        else if(id != null){
            if(id.startswith('ka')){
                query += 'Where Id = \''+ id + '\' Limit 1';
                Details = Database.Query(query);
            }
            else if(id.startswith('kA')){
                query += 'where publishstatus = \'Online\' and language = :lang and KnowledgeArticleId = \''+id+'\' Limit 1';
                Details = Database.Query(query);
            }
        }

        if(Details != null){
            query = 'select id, title, summary, articletype, LastModifiedDate, Body__c, KnowledgeArticleId';
            query += ' From '+Details.articletype+' Where Id = \''+Details.Id+'\'';
            Detail = Database.query(query);

            //Record = (GCS__kav)Detail;
            aw = new ArticleWrapper();
            aw.ArticleId = String.ValueOf(Detail.get('KnowledgeArticleId'));
            aw.Title = String.ValueOf(Detail.get('Title'));
            aw.Summary = String.ValueOf(Detail.get('Summary'));
            aw.Body = String.ValueOf(Detail.get('Body__c'));
            aw.LastModifiedDate = DateTime.ValueOf(Detail.get('LastModifiedDate'));
        }
        return null;
    }

    //Called on submit case on EKBContact Us
    //Method creates case from populate details
    public pagereference Suggestions(){
        /*ContactUs.Brand__c = Brand.id;
        insert ContactUs;
        if(attachment.body != null){
            attachment.parentId = ContactUs.id;
            insert attachment;
        }*/

        PageReference pageRef = new PageReference('/EKBSuggestions?brand='+Brand.Brand_Tag__c);
        pageRef.setRedirect(false);
        return pageRef;
    }

    @RemoteAction
    public static List<KnowledgeArticleVersion> SuggestedArticles(String Subject, String BrandId, String Language){
        System.Debug('###here');
        arSuggest = [Select id, Article_id__c,Deflected_Cases__c From Article_Relationship__c Where Brand__c = :BrandId];
        Set<id> ArticleIds = new Set<id>();
        for(Article_Relationship__c ar: arSuggest){
            ArticleIds.add(ar.Article_Id__c);
        }

        String type = Subject.replace(' ','_');
        type = type.replace('/','_');

        listSuggest = Database.Query('Select id, Title,Summary, LastModifiedDate, KnowledgeArticleId From KnowledgeArticleVersion Where islatestversion = true and language = :Language and publishstatus = \'Online\' and KnowledgeArticleId IN :articleIds WITH DATA CATEGORY EKB__c AT ('+type+'__c) Limit 5');

        return listSuggest;
        /*string[] categorysplit;
        if(Subject.contains(' ')){
          categorysplit = Subject.split('\\s+');
        }
        else if(Subject.contains('/')){
          categorysplit = Subject.split('/');
        }
        else{
            String query = 'Select id, Title,Summary, LastModifiedDate, KnowledgeArticleId From KnowledgeArticleVersion ';
            query += 'Where islatestversion = true and language = :Language and publishstatus = \'Online\' and (Title Like \'%'+Subject + '%\' or Summary Like \'%'+Subject+'%\') and KnowledgeArticleId IN :articleIds limit 5';
            listSuggest = database.query(query);
            return listSuggest;
        }


        for(String s:categorysplit){
            List<KnowledgeArticleVersion> listkav = new List<KnowledgeArticleVersion>();
            String query = 'Select id, Title,Summary, LastModifiedDate, KnowledgeArticleId From KnowledgeArticleVersion ';
            query += 'Where islatestversion = true and language = :Language and publishstatus = \'Online\' and (Title Like \'%'+s + '%\' or Summary Like \'%'+s+'%\') and KnowledgeArticleId IN :articleIds limit 5';
            System.Debug('###'+query);
            System.Debug('###'+Language);
            System.Debug('###'+ArticleIds);
            listkav = database.query(query);
            if(listkav.size()>0)listSuggest.addall(listkav);
            if(listSuggest.size()>4){break;}
        }
        if(listSuggest.size() == 0)return listSuggest;
        else return listSuggest;*/
    }

    public PageReference QuestionAnswered(){
        //update questions to say correct
        arSuggest = [Select id, Article_id__c,Deflected_Cases__c From Article_Relationship__c Where Brand__c = :Brand.Id];
        System.Debug('###'+arSuggest);
        for(Article_Relationship__c ar:arSuggest){
            if(ar.Deflected_Cases__c != null)ar.Deflected_Cases__c++;
        }
        if(arsuggest.size() > 0)update arSuggest;
        PageReference pageRef = new PageReference('/EKBHome?brand='+Brand.Brand_Tag__c);
        pageRef.setRedirect(false);
        return pageRef;
    }

    public PageReference SubmitCase(){
        InsertCase();
        return null;
    }

    public void InsertCase(){
        List<Contact> listContact = [Select id, Email From Contact Where Email = :ContactUs.SuppliedEmail];
        if(listContact.size()>0) ContactUs.ContactId = listContact[0].id;
        ContactUs.Brand__c = Brand.id;
        ContactUs.ContactSource__c = Brand.Audience__c;
        ContactUs.Language__c = Brand.Language__c;
        ContactUs.SuppliedName = ContactUs.FirstName__c + ' ' + ContactUs.LastName__c;

        insert ContactUs;
        System.Debug('###'+ContactUs);
        System.Debug('###'+attachment);
        if(Attachment.body != null){
            if(ContactUs.id != null){
            Attachment.parentId = ContactUs.id;
            insert Attachment;
        }
            Attachment.clear();
        }
    }

    //Invoked by clicking search on the component EKBSearch
    //Currently only used on Answers page for search but will be extended
    public PageReference searchArticles(){

        PageReference pageRef = new PageReference('/EKBAnswers?brand='+brand.brand_tag__c);
        if(SearchString != null && SearchString.length() > 0)pageRef.getParameters().put('Search',SearchString);

        if(URL.getCurrentRequestUrl().toExternalForm().contains('EKBAnswers')){
            System.Debug('### answers');
            pageRef.setRedirect(false);
        }
        else{
            System.Debug('###other');
            pageRef.setRedirect(true);
        }

        return pageRef;
    }

    //Invoked of EKBDetail to indicated Aricle is useful
    //Number is marked on Article relationship to keep number relative to the Brand rather than the Article
    public PageReference ratedYes(){
        listAR = [Select id, Times_found_useful__c, Times_not_found_useful__c From Article_Relationship__c Where Article_Id__c = :Aw.ArticleId and Brand__c = :Brand.Id];
        if(ListAr.size() > 0){ ListAr[0].Times_found_useful__c ++;}
        update listAR;
        RatingSubmitted = true;
        return null;
    }

    //Invoked of EKBDetail to indicated Aricle is unot seful
    //Number is marked on Article relationship to keep number relative to the Brand rather than the Article
    public PageReference ratedNo(){
        listAR = [Select id, Times_found_useful__c, Times_not_found_useful__c From Article_Relationship__c Where Article_Id__c = :Aw.ArticleId and Brand__c = :Brand.Id];
        if(ListAr.size() > 0){ ListAr[0].Times_not_found_useful__c ++;}
        update listAR;
        RatingSubmitted = true;
        return null;
    }

    //Used to populate the SiteURL for sharing Articles via social
    public string getSiteURL(){
        return Url.getSalesforceBaseUrl().toExternalForm();
    }

    public List<SelectOption> getCategories(){
        string[] Categories = Brand.Categories__c.split(';');
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('',''));
        /*
        for(String s:categories){
            options.add(new selectoption(s,s));
        }
        */
        Schema.DescribeFieldResult fieldR = Brand__c.Categories__c.getDescribe();
        List<Schema.PicklistEntry> pickV = fieldR.getPicklistValues();
        Map<String, String> mapMyFieldTranslation = new Map<String, String>();
         
        for(Schema.PicklistEntry e : pickV){
            mapMyFieldTranslation.put(e.value, e.label);
        }
         
        String optValue = '';
        for(String s:categories){
            optValue = mapMyFieldTranslation.get(s);
            if(optValue == null || optValue == ''){
                optValue = s;
            }
            options.add(new selectoption(s,optValue));
        }
        
        return options;
    }
    
    // Method: getCountries
    // Description: Picklist options for countries filtered by Brand's Default Countries
    // Date: 24-Nov-16
    
    public List<SelectOption> getCountries(){
        string[] Countries = Brand.Available_Country__c.split(';');
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('',''));
        /*
        for(String s:Countries){
            options.add(new selectoption(s,s));
        }
        */
        Schema.DescribeFieldResult fieldR = Brand__c.Available_Country__c.getDescribe();
        List<Schema.PicklistEntry> pickV = fieldR.getPicklistValues();
        Map<String, String> mapMyFieldTranslation = new Map<String, String>();
         
        for(Schema.PicklistEntry e : pickV){
            mapMyFieldTranslation.put(e.value, e.label);
        }
         
        String optValue = '';
        for(String s:Countries){
            optValue = mapMyFieldTranslation.get(s);
            if(optValue == null || optValue == ''){
                optValue = s;
            }
            options.add(new selectoption(s,optValue));
        }
        
        return options;
    }
    
    // Method: getStates
    // Description: Picklist options for states filtered by country
    // Date: 24-Nov-16
    
    public List<SelectOption> getStates(){
        system.debug(ContactUs.BillingCountry__c);
        List<SelectOption> options = new List<SelectOption>();
        if(ContactUs.BillingCountry__c != null && ContactUs.BillingCountry__c != ''){
            for(String s: mapCountryStates.get(ContactUs.BillingCountry__c)){
                system.debug(ContactUs.BillingCountry__c+'--'+s);
                options.add(new selectoption(s,s));
            }
        }
        
        return options;
    }
    
    public String getLogoPath(){
        string Path = 'images/monsterhelpcenter_'+Brand.ISO_Language__c+'.png';
        return Path;
    }

    public class ArticleWrapper{
        public id ArticleId {get;set;}
        public string Title {get;set;}
        public string Summary {get;set;}
        public string Body {get;set;}
        public datetime LastModifiedDate {get;set;}
    }

}