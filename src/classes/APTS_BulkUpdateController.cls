public class APTS_BulkUpdateController
{
    
    //ID
    public Id config_id, configRequestID, businessObjectID;
    
    //SObject
    public Apttus_Config2__LineItem__c oItem { get; set;} 
    public List<Apttus_Config2__LineItem__c> lstLineItems;
    
    //LIST
    public List<SelectOption> pickListAdjustmentTypes{get; private set;}
    
    //STRING
    public String sSelectedAdjustmentType {get; set; }
    public String sComments {get; set;}
    
    //DECIMAL
    public string dAdjustmentAmount {get; set;}
    public string dQuantity {get; set;}
    
    //DATETIME
    public String dSelectedDate {get; set; }
    
    //STATIC
    private static final string ID_PAGE_PARAMETER = 'ID';
    private static final string CONFIG_REQUEST_ID_PAGE_PARAMETER = 'configRequestID';
    private static final string BUSINESSOBJECT_ID_PAGE_PARAMETER = 'businessObjectId';
    
    public APTS_BulkUpdateController()
    {
        try
        {  
            config_id = Apexpages.currentpage().getparameters().get('id');
            configRequestID  = ApexPages.currentPage().getParameters().get(CONFIG_REQUEST_ID_PAGE_PARAMETER);
            businessObjectID  = ApexPages.currentPage().getParameters().get(BUSINESSOBJECT_ID_PAGE_PARAMETER);
            
            System.debug('config_id'+config_id);
            oItem = new Apttus_Config2__LineItem__c();
            getLineItems();
            //getAdjustmentTypes();
            //dSelectedDate =  Date.Today().format();
            
        }
        catch(exception e)
        {
            System.debug('Error'+e.getMessage());
        }
    }    
    
    public void getLineItems()
    {
        lstLineItems = [Select id,Apttus_Config2__StartDate__c,Apttus_Config2__AdjustmentAmount__c,
                        Apttus_Config2__AdjustmentType__c,Apttus_Config2__Quantity__c,Apttus_Config2__Comments__c,
                        Apttus_Config2__AllowManualAdjustment__c,Apttus_Config2__IsQuantityModifiable__c                        
                        from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c =: config_id and Select__c = True];
        
        
    }
    
    public void getAdjustmentTypes()
    {
        pickListAdjustmentTypes = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Apttus_Config2__LineItem__c.Apttus_Config2__AdjustmentType__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            pickListAdjustmentTypes.add(new SelectOption(f.getLabel(), f.getValue()));
        }
    }
    
    public PageReference save()
    {
        List<Apttus_Config2__LineItem__c> lstLIToUpdate = new List<Apttus_Config2__LineItem__c>();
        Apttus_Config2__LineItem__c oLIToUpdate = new Apttus_Config2__LineItem__c();
        System.debug('lstLineItems'+lstLineItems);
        pagereference pg = null;
        system.debug('oItem'+oItem);
        for(Apttus_Config2__LineItem__c oItemToUpdate : lstLineItems)
        {
            oLIToUpdate = new Apttus_Config2__LineItem__c();
            
            oLIToUpdate.id = oItemToUpdate.id;
            if(oItem.Apttus_Config2__StartDate__c != null)
                oLIToUpdate.Apttus_Config2__StartDate__c = oItem.Apttus_Config2__StartDate__c;
            
            System.debug('test Apttus_Config2__AllowManualAdjustment__c'+ oLIToUpdate.Apttus_Config2__AllowManualAdjustment__c );
            If(oItemToUpdate.Apttus_Config2__AllowManualAdjustment__c )
            {
                if(oItem.Apttus_Config2__AdjustmentAmount__c != null)
                    oLIToUpdate.Apttus_Config2__AdjustmentAmount__c = oItem.Apttus_Config2__AdjustmentAmount__c;
                if(String.isNotBlank(oItem.Apttus_Config2__AdjustmentType__c))
                    oLIToUpdate.Apttus_Config2__AdjustmentType__c = oItem.Apttus_Config2__AdjustmentType__c;
            }
            System.debug('test '+ oLIToUpdate.Apttus_Config2__IsQuantityModifiable__c );
            If(oItemToUpdate.Apttus_Config2__IsQuantityModifiable__c && oItem.Apttus_Config2__Quantity__c != null)
                oLIToUpdate.Apttus_Config2__Quantity__c = oItem.Apttus_Config2__Quantity__c;
            if(String.isNotBlank(oItem.Apttus_Config2__Comments__c))
                oLIToUpdate.Apttus_Config2__Comments__c = oItem.Apttus_Config2__Comments__c;
            oLIToUpdate.Apttus_Config2__PricingStatus__c = 'Pending';
            oLIToUpdate.Select__c = false; 
            system.debug('oItem'+oLIToUpdate);
            lstLIToUpdate.add(oLIToUpdate);
        }
        System.debug('lstLIToUpdate'+lstLIToUpdate);
        update lstLIToUpdate;
        System.debug('lstLIToUpdate'+lstLIToUpdate);        
        /*Apttus_CpqApi.CPQ.UpdatePriceRequestDO req = new Apttus_CpqApi.CPQ.UpdatePriceRequestDO();
req.CartId = config_id;
Apttus_CpqApi.CPQ.UpdatePriceResponseDO result = Apttus_CpqApi.CPQWebService.updatePriceForCart(req);
*/
        pg = new pagereference('/apex/Apttus_Config2__Pricing?ID='+config_id+'&configRequestID='+configRequestID+'&flow=Default');
        return pg;
    }
    
    public PageReference cancel()
    {
        pagereference pg = null;
        pg = new pagereference('/apex/apttus-config2__CartDetailView?ID='+config_id+'&configRequestID='+configRequestID+'&flow=Default');
        return pg;
    }
}