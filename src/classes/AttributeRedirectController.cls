/*
Updated 10/29

*/

public with sharing class AttributeRedirectController {
    
    Id lineItemId;
    Id TempId;
    string prefString;
    public string myURL{get;set;}
    public AttributeRedirectController(){
     lineItemId=apexpages.currentpage().getParameters().get('Id');
     string refURL=Apexpages.currentpage().getHeaders().get('Referer');
     
     system.debug('Referer: URL'+refURL);
     myURL=refURL;
     
     String currentURL=string.join(apexpages.currentPage().getParameters().values(),',');
     system.debug('CurrentURL'+currentURL); 
     
     Apttus_Config2__LineItem__c lineItem=[select id,name,
                                    Apttus_Config2__ConfigurationId__c
                                    from Apttus_Config2__LineItem__c
                                    where Id=:lineItemId];
     Apttus_Config2__TempObject__c TempObject=[select id from Apttus_Config2__TempObject__c
                                     where Apttus_Config2__ConfigurationId__c=:lineItem.Apttus_Config2__ConfigurationId__c order by createdDate desc limit 1];
                                     
     prefString='/apex/OptionAttributeOverride?id='+lineItemId+'&callerPage=SelectConfigProducts&configRequestId='+TempObject.id+'&flow=Default';
    }
    
    public pageReference redirect()
    {
     return new pageReference(prefString);
     //return null;
     
    }
    

}