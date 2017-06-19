public with sharing class APTS_ReadOnlyAttribute {
    public id lineItemId;
    public APTS_ReadOnlyAttribute()
    {
        lineItemId = System.currentPageReference().getParameters().get('id');
    }
	
    public pageReference Redirect()
    {
        
        try{
            Apttus_Config2__LineItem__c oLine = [select id,
                                                 Apttus_Config2__ConfigurationId__c,
                                                 Apttus_Config2__LineType__c,
                                                 Apttus_Config2__IsPrimaryLine__c,
                                                 Apttus_Config2__HasOptions__c                                                 
                                                FROM Apttus_Config2__LineItem__c
                                                WHERE id = :lineItemId];
            
            List<Apttus_Config2__TempObject__c> TempObjectList = [select id 
                                                                 	FROM Apttus_Config2__TempObject__c
                                                                 Where Apttus_Config2__ConfigurationId__c  = :oLine.Apttus_Config2__ConfigurationId__c];
            
            
            If(oLine.Apttus_Config2__LineType__c == 'Product/Service' && !oLine.Apttus_Config2__HasOptions__c )
            {
                string sUrl  = '/apex/ProductAttributeReadOnly?id='+lineItemId;
                PageReference pg = new PageReference(surl); 
                return pg;
            }
            else
            {
                string sUrl  = '/apex/OptionAttributeOverride?callerPage=SelectConfigProducts&flow=Default&configRequestId='+TempObjectList[0].id+'&id='+lineItemId;
                 PageReference pg = new PageReference(surl); 
                return pg;
            }
        }
        catch(exception e) 
        {
            
            return null;
        }
        
        return null;
            
    }
}