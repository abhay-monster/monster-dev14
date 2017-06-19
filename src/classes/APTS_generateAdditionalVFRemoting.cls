public class APTS_generateAdditionalVFRemoting {


    //ID
    
        public static string LineIds{get;set;} 
        public string URLQueryPara{get;set;}
        public integer iYear {get;set;}
    
    //Sobject

    private static Apttus_Config2__ProductAttributeValue__c mainProdAttr;
    
    //List
//    private List<Apttus_Config2__LineItem__c> lstLineItems;

     private static MAP<id,Apttus_Config2__LineItem__c> MAPlineItem ;
    //String
    private static String strSOQLTemp;
    
    //Map
    private static Map<String,String> mapKeyValueMainProdAttr = new Map<String,String>();
    private static Map<String, Schema.SObjectField> mapStrSobject;
    static List<Apttus_Config2__LineItem__c> newLiItem = new List<Apttus_Config2__LineItem__c>();
                
    public integer years { get; set; }
     static Apttus_Config2__ProductAttributeValue__c newProdAttr = new Apttus_Config2__ProductAttributeValue__c();
    
    public string URLQueryParameters{
        get{
            URLQueryParameters=''+URL.getCurrentRequestUrl().getQuery();
            return URLQueryParameters;            
        }set{
            URLQueryParameters=value;
        }
        
    }

    public APTS_generateAdditionalVFRemoting ()
    {
    try{
    
        URLQueryPara = URL.getCurrentRequestUrl().getQuery();
         //capture the parameters for redirecting the user back to cart page.
         id  config_id = Apexpages.currentpage().getparameters().get('id');
         System.debug('config_id'+config_id);
           MAPlineItem = new MAP<id,Apttus_Config2__LineItem__c>([Select id,Select__c,Apttus_Config2__LineNumber__c,Apttus_Config2__ProductId__c,Name,Apttus_Config2__AdjustmentType__c,Apttus_Config2__Quantity__c,Apttus_Config2__AdjustmentAmount__c,Apttus_Config2__EndDate__c
                         ,Apttus_Config2__PrimaryLineNumber__c,Apttus_Config2__ExtendedPrice__c,Apttus_Config2__AdjustedPrice__c,Apttus_Config2__BasePrice__c,APTS_Extended_List_Price__c,Configuration_Type__c,
                         (select id,Apttus_Config2__IsTransient__c,Contract_Duration__c from Apttus_Config2__ProductAttributeValues__r)  
                         from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c = :config_id AND Select__c = True]);
                         
                         if(MAPlineItem.size() > 0 )
                         {
                       List<id>  setLinId1 = new List<id>(MAPlineItem.keyset());  
                       LineIds =  string.join(setLinId1,',') ; 
                       }
                       else
                       {
                           LineIds  = '';
                       }
                       }
                       catch(exception e)
                       {
                         System.debug('Error'+e.getMessage()+e.getLineNumber() );
                       }
    }
     
   
    
      @RemoteAction
     public static boolean GenerateAdditionalYearsForSelectedLineItem(id lineId, integer years, id config_id)
    {        
    
        APTS_additionalYearHelper oHelper = new APTS_additionalYearHelper( config_id);
        return oHelper.GenerateAdditionalYearsForSelectedLineItem(lineId, years,  config_id);
              // years = 3;

           }
    
    
    
}