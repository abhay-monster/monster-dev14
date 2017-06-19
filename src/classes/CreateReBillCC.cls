/**
* @description Class that will clone the opportunity and quote in a specific Order 
* @author Cloudsherpas
* @date 5-22-2014
*/
public class CreateReBillCC {
    private Map<String, Map<String, Schema.SObjectField>> sObjectAndFields;
    private Opportunity ParentOpportunity;
    private Opportunity ClonedOpportunity;
    private Apttus_Proposal__Proposal__c ParentQuote;
    private Apttus_Proposal__Proposal__c ClonedQuote;
    private String nameOfOpportunity;
    private String nameOfQuote;
    public String ErrorMessage{get;set;}
    public string stringURL{get;set;}
    public Boolean showAlert{get;set;}
    public CreateReBillCC(ApexPages.StandardController controller){
        
    }
/**
* @description A method that will be executed once the page is called. 
* @author Cloudsherpas
* @date 5-22-2014
* @param none
* @returns none
*/     
    public void executeMethod(){
        nameOfOpportunity =  ApexPages.currentPage().getParameters().get('oppName');
        String idOfOrder =  ApexPages.currentPage().getParameters().get('orderId');
        nameOfQuote =  ApexPages.currentPage().getParameters().get('quoteName');
        //Cloning Opportunity and Quote
        try {
            if(nameOfOpportunity != null && nameOfQuote != null ){   
                showAlert = false;
                getAllFields(); 
                getOpportunities(nameOfOpportunity); 
                getQuotes(nameOfQuote);
                Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Rebill Opportunity').getRecordTypeId();
                ClonedOpportunity = ParentOpportunity.clone(false,true,false,true);
                ClonedOpportunity.RecordTypeId = oppRecordTypeId;
                ClonedOpportunity.CreditOrder__c = idOfOrder;
                insert ClonedOpportunity;
                ClonedQuote = ParentQuote.clone(false,true,false,true);
                insert ClonedQuote;
            }else{
                showAlert = true;
                ErrorMessage = 'Opportunity and Quote in order should not be null.';
            }
        } catch (Exception e){
            showAlert = true;
            ErrorMessage = e.getMessage();
         }
         String orig = URL.getCurrentRequestUrl().toExternalForm();
         //Modify the URL
         String orig2 = orig.replace('&save_new=1','').replace('&sfdc.override=1','');
         stringURL = '/'+ idOfOrder;
    }
/**
* @description Gets all field detail of Opportunity based on the Id
* @author Cloudsherpas
* @date 5-22-2014
* @param none
* @returns none
*/        
    private void getOpportunities(String nameOfOpportunity){
        Map<String, Schema.SObjectField> oppFields = sObjectAndFields.get('Opportunity');
        String orderQuery = 'SELECT ';
        for(String sourceAPI : oppFields.keySet()){
            orderQuery += sourceAPI+',';
        }
        orderQuery = orderQuery.removeEnd(',');
        orderQuery += ' FROM Opportunity WHERE Name = : nameOfOpportunity LIMIT 1' ;
        try{
            ParentOpportunity = Database.query(orderQuery);
            if(ParentOpportunity == null){
                showAlert = true;
                ErrorMessage ='No parent order to process.';
            }
        }catch(Exception e){
            showAlert = true;
            ErrorMessage= 'Failed to get the opportunity. Error: '+ e.getMessage();
        }
    }
/**
* @description Gets all field detail of Apttus_Proposal__Proposal__c based on the Id
* @author Cloudsherpas
* @date 5-22-2014
* @param none
* @returns none
*/        
    private void getQuotes(String nameOfQuote){
        Map<String, Schema.SObjectField> oppFields = sObjectAndFields.get('Apttus_Proposal__Proposal__c');
        String orderQuery = 'SELECT ';
        for(String sourceAPI : oppFields.keySet()){
            orderQuery += sourceAPI+',';
        }
        orderQuery = orderQuery.removeEnd(',');
        orderQuery += ' FROM Apttus_Proposal__Proposal__c WHERE Name = : nameOfQuote LIMIT 1' ;
        try{
            ParentQuote = Database.query(orderQuery);
            if(ParentQuote == null){
                
                showAlert = true;
                ErrorMessage ='No parent order to process.';
            }
        }catch(Exception e){
            showAlert = true;
            ErrorMessage= 'Failed to get the opportunity. Error: '+ e.getMessage();
        }
    }
/**
* @description Gets all field detail of Opportunity
* @author Cloudsherpas
* @date 5-22-2014
* @param none
* @returns none
*/     
    private void getAllFields(){
        Utility util = new Utility();
        sObjectAndFields = util.getAllSObjectFieldsBySObjectName(new Set<String>{'Opportunity','Apttus_Proposal__Proposal__c'});
    } 
}