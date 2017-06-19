global class KnowledgeURLRewriter implements Site.UrlRewriter{
    final String CLASSNAME = '\n\n**** KnowledgeURLRewriter.METHODNAME()';
    
    //accepted values for parameter 0 or usedFor
    private Set<String> TabSet = new Set<String>{'overview','answers','training_tutorials', 'ask'};
    private Set<String> UsedForSet = new Set<String>{'seeker','employer'};
    
    global PageReference mapRequestUrl(PageReference yourFriendlyUrl){
      final string METHODNAME = CLASSNAME.replace('METHODNAME','mapRequestUrl');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        String[] currentURL = yourFriendlyUrl.getUrl().split('/');
        String tab = 'answers';
        String type = 'seeker';
        String language = 'en_US';
        String article = 'list';
        for(Integer i = 1; i < currentURL.size(); i++){
            if(i == 1){
                language = currentURL[i];
            }   
            if(i == 2){
                if(UsedForSet.contains(currentURL[i].toLowerCase())){
                    type = currentURL[i].toLowerCase();
                }
            }
            if(i == 3){
                if(TabSet.contains(currentURL[i].toLowerCase())){
                    tab = currentURL[i].toLowerCase();
                }
            }
            if(i == 4){
                article = currentURL[i];
            }
        }
        
        Schema.DescribeFieldResult languages = Schema.Sobjecttype.Training_Tutorial__kav.fields.language;
        for(Schema.PicklistEntry pe : languages.getPicklistValues()){
            if(pe.getValue().toLowerCase() == language.toLowerCase()){
                language = pe.getValue();
            }
        }
        
        String urlToUse = KnowledgeModel.ROOT_URL + '?';
        urlToUse += 'language=' + language + '&';
        urlToUse += 'tab=' + tab + '&';
        urlToUse += 'type=' + type + '&';
        urlToUse += 'article=' + article;
        PageReference usedUrl = new PageReference(urlToUse);
        return usedUrl; 
        return null;
    }
    
    global PageReference[] generateUrlFor(PageReference[] yourSalesforceUrls){
        /*final string METHODNAME = CLASSNAME.replace('METHODNAME','generateUrlFor');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        */
        return null;  
    } 
}