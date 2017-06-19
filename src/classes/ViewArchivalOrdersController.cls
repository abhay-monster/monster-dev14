public with sharing class ViewArchivalOrdersController{
    
    public String SelectedOli {get;set;}
    public List<Order__c> EligibleOrderList {get; set;}
    
    private Id accId;

    public ViewArchivalOrdersController(){
    
        if(ApexPages.currentPage().getParameters().containsKey('AccId')){
            accId = ApexPages.currentPage().getParameters().get('AccId');
            System.debug('accId >>>>>>> ' + accId );
        }
        
        if(accId != null){
            EligibleOrderList  = new List<Order__c>();
            EligibleOrderList  = generateOutput();
        }
    }
     
    
    private List<Order__c> generateOutput(){
        System.debug(LoggingLevel.INFO,'\n\nInside generateOutput \n\n');
        
        
        for(Order__c ordFirst: [Select Id,Name,OrderStatus__c,NetTotalAmount__c, ArchivalStatus__c from Order__c Where Account__c = :accId AND ArchivalStatus__c = 'Archived']){
            EligibleOrderList.add(ordFirst);
        }
                
        if(EligibleOrderList.isEmpty()) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'There are No Archival Orders associated to Account'));
        }
        
        return EligibleOrderList;
        
    }
    
    
    public PageReference selectQuoteID() {
        SelectedOli = ApexPages.currentPage().getParameters().get('radioSelectValue');
        system.debug('Check ++++++' + SelectedOli );
        return null;
    }
    
    public PageReference onClickNext() {
        List<Order__c> tobeUpdated = new List<Order__c>();
    
        if(SelectedOli != null){
        
            List<Order__c> getOrd = new List<Order__c>([SELECT Id,ArchivalStatus__c FROM Order__c WHERE Id =:SelectedOli] );
            for(Order__c oliFirst: getOrd ){
                   oliFirst.ArchivalStatus__c = '';
                   tobeUpdated.add(oliFirst);
            }
            update tobeUpdated;
       }
        return new PageReference('/' + accId);
    }
    
    public PageReference onClickCancel() {
      //  return new PageReference('/' + AccountID);
      return new PageReference('/' + accId);
    } 
}