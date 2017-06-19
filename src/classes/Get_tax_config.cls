public class Get_tax_config {
public Id configId {get; set;}
public Id configRequestId {get; set;}

public PageReference Get_Tax(){
    configId = System.currentPageReference().getParameters().get('id');
    configRequestId = System.currentPageReference().getParameters().get('configRequestId');
    Boolean result = AvalaraModel_Cart.getQuoteTaxFromConfigbutton(configId);
    if(result){
        System.debug('success tax call');
        PageReference Cart = new PageReference('/apex/Apttus_config2__CartDetailView?id='+configId+'&configRequestId='+configRequestId);
        Cart.setRedirect(true);
        return Cart;
    }else{
        System.debug('fail tax call');
        PageReference Cart = new PageReference('/apex/Apttus_config2__CartDetailView?id='+configId+'&configRequestId='+configRequestId);
        Cart.setRedirect(true);
        return Cart;
        
    }
    
    return null;
}


}