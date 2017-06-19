//Author - Sunny Gill (T-421554)
public with sharing class PaypalResponseController {
    private String quoteId;
    public PaypalResponseController(){
    
    }
    
    public PageReference updateQuote(){
        quoteId = ApexPages.currentPage().getParameters().get('USER1');
        String paypalRefNo = ApexPages.currentPage().getParameters().get('PPREF');
        String resultCode= ApexPages.currentPage().getParameters().get('RESULT');
        String resultMessage = ApexPages.currentPage().getParameters().get('RESPMSG');
        String transactionTime = ApexPages.currentPage().getParameters().get('TRANSTIME');
    
    if(quoteId != null){
        Apttus_Proposal__Proposal__c quote = [SELECT Id FROM Apttus_Proposal__Proposal__c WHERE id =: quoteId];
        quote.PaypalReferenceNumber__c = paypalRefNo;
        quote.PaypalResultCode__c = resultCode;
        quote.PaypalResultMessage__c = resultMessage;
        quote.PaypalTransactionTime__c = DateTime.parse(transactionTime);
        
        update quote;
    }
        AvalaraModel.setIstoCommit(quoteId );
        return new PageReference('/'+quoteId);
    }
}