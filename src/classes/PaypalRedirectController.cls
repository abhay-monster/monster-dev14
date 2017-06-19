public class PaypalRedirectController {
    public string secureToken {get; set;}
    public string secureTokenId {get; set;}
    public string quoteId{get; set;}
    
    public PaypalRedirectController(){
        secureToken = ApexPages.currentPage().getParameters().get('SECURETOKEN');
        secureTokenId = ApexPages.currentPage().getParameters().get('SECURETOKENID');
        quoteId= ApexPages.currentPage().getParameters().get('USER1');
    }

}