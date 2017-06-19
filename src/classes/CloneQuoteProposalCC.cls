public class CloneQuoteProposalCC {
  private Map<String, Map<String, Schema.SObjectField>> sObjectAndFields;
    private Apttus_Proposal__Proposal__c ParentQuote;
    private Apttus_Proposal__Proposal__c ClonedQuote;
    private String nameOfQuote;
    public String ErrorMessage{get;set;}
    public string stringURL{get;set;}
    public Boolean showAlert{get;set;}
    public CloneQuoteProposalCC(ApexPages.StandardController controller){
        
    }
/**
* @description A method that will be executed once the page is called. 
* @author Cloudsherpas
* @date 6-03-2014
* @param none
* @returns none
*/     
    public void executeMethod(){
        nameOfQuote =  ApexPages.currentPage().getParameters().get('quoteName');
        //Cloning Opportunity and Quote
        try {
            if(nameOfQuote != null ){   
                showAlert = false;
                getAllFields(); 
                //getOpportunities(nameOfOpportunity); 
                getQuotes(nameOfQuote);
                //Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Rebill Opportunity').getRecordTypeId();
                //ClonedOpportunity = ParentOpportunity.clone(false,true,false,true);
                //ClonedOpportunity.RecordTypeId = oppRecordTypeId;
                //ClonedOpportunity.CreditOrder__c = idOfOrder;
                //insert ClonedOpportunity;
                ClonedQuote = ParentQuote.clone(false,true,false,true);
                ClonedQuote.CopiedQuoteId__c = nameOfQuote;
                insert ClonedQuote;
            }else{
                showAlert = true;
                ErrorMessage = 'Quote should not be null.';
            }
        } catch (Exception e){
            showAlert = true;
            ErrorMessage = e.getMessage();
         }
         String orig = URL.getCurrentRequestUrl().toExternalForm();
         //Modify the URL
         String orig2 = orig.replace('&save_new=1','').replace('&sfdc.override=1','');
         stringURL = '/'+ nameOfQuote;
    }
/**
* @description Gets all field detail of Apttus_Proposal__Proposal__c based on the Id
* @author Cloudsherpas
* @date 6-03-2014
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
* @description Gets all field detail of Apttus_Proposal__Proposal__c
* @author Cloudsherpas
* @date 6-03-2014
* @param none
* @returns none
*/     
    private void getAllFields(){
        Utility util = new Utility();
        sObjectAndFields = util.getAllSObjectFieldsBySObjectName(new Set<String>{'Apttus_Proposal__Proposal__c'});
    }  
}