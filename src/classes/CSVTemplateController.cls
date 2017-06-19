public class CSVTemplateController {
    public List<Contact> conList{get;set;}
    public String proId{get;set;}
    public String[] lineIdList{get;set;}
    public Integer rowLimit{get;set;}
    public List<Apttus_Proposal__Proposal_Line_Item__c> lineItemList{get;set;}
    public String proName {get;set;}
    public List<wrapperC> wc{get;set;}

    public String[] debugger{get;set;}

    public class wrapperC{

      public String prodName {get; set;}
      public Contact conlist2 {get; set;}

    }
    public CSVTemplateController(){
        conList = new List<Contact>();
        proId = ApexPages.currentPage().getParameters().get('ProposalId');
        lineItemList = [SELECT Product_or_Option_Name__c,ProductName__c, Apttus_Proposal__Product__r.Name, Apttus_Proposal__Product__r.Family, Apttus_QPConfig__Quantity2__c, Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__c, Id FROM Apttus_Proposal__Proposal_Line_Item__c WHERE Apttus_Proposal__Proposal__c =: proId];
        debugger = new  String[]{};
        try{
            splitParameter();
        }catch(Exception e){
            debugger.add('ERROR: ' + e);
        }
    }
    public void splitParameter(){
        wc = new list<wrapperC>();
        for(Apttus_Proposal__Proposal_Line_Item__c lineItem : lineItemList){
            proName = lineItem.ProductName__c;
            if(lineItem.Apttus_Proposal__Product__r.Family == 'Resume'){
              rowLimit = lineItem.Apttus_QPConfig__Quantity2__c.intValue();
              for(Integer j=1;j<=rowLimit;j++){
                wrapperC AE = new wrapperC();
                AE.prodName = proName;
                AE.conlist2 = new Contact(AccountId = lineItem.Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__c,
                                      ProposalLineItem__c = lineItem.Id, FirstName = '', LastName= '', Phone = '', Email = '');
                wc.add(AE);
              }
            } else {
                wrapperC AE = new wrapperC();
                AE.prodName = proName;
                AE.conlist2 = new Contact(AccountId = lineItem.Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__c,
                                          ProposalLineItem__c = lineItem.Id, FirstName = '', LastName= '', Phone = '', Email = '');
                wc.add(AE);
            }  
        }
    } 
}