public class APTS_additionalYearHelper
{

    //ID
    private id config_id;
    private Id lineitemid;
    private Id newLineItemId;  
    private Id pricelistId; 
    
    //Integer
    private Integer currentYearDays;
    private integer years;
    private Integer Duration = 0;
    private Integer year = 0;
    private Integer iCount = 0;
    
    //Sobject
    private Apttus_Config2__LineItem__c oLineItem;
    private Apttus_Config2__ProductAttributeValue__c mainProdAttr;
    private Apttus_Config2__ProductAttributeValue__c newProdAttr = new Apttus_Config2__ProductAttributeValue__c();
    
    //List
    private List<Apttus_Config2__LineItem__c> lstLineItems;
    private List<Apttus_Config2__LineItem__c> newLiItem = new List<Apttus_Config2__LineItem__c>();                
    private List<Decimal> lineNumbers = new List<Decimal>();
    private List<Apttus_Proposal__Proposal__c> lstProposal = new List<Apttus_Proposal__Proposal__c>();
    
    //String
    private String strSOQLTemp;
    private String sDuration;
    private String sDurationInDays;
    private string sPAVSoql;
    
    //Map
    private Map<String,String> mapKeyValueMainProdAttr = new Map<String,String>();
    private Map<Id,Id> mapOldOptionToNewOptionIds = new Map<Id,Id>();
    private Map<String, Schema.SObjectField> mapStrSobject;
    
    //Decimal
    private Decimal lineNumber;
    
    //Date
    private date newLineItemStartDate, newLineItemEndDate;
    private date newLineItemStartDateBundle,newLineItemEndDateBundle;
    private date newLineItemStartDateOption,newLineItemEndDateOption;
    
    public APTS_additionalYearHelper(id configIdPara)
    {        
        //capture the parameters for redirecting the user back to cart page.
        config_id  = configIdPara; 
        DaysInCurrentYear();
        SOQLForProdAttribute();
    }
    
    public boolean GenerateAdditionalYearsForSelectedLineItem(id lineId, integer yearsarge, id config_id)
    {        
        years  = yearsarge;
        Apttus_Config2__LineItem__c oItem  = [Select id,Select__c,Apttus_Config2__LineNumber__c,Apttus_Config2__ProductId__c,Name,Apttus_Config2__AdjustmentType__c,Apttus_Config2__Quantity__c,Apttus_Config2__AdjustmentAmount__c,Apttus_Config2__EndDate__c
                                              ,Apttus_Config2__PrimaryLineNumber__c,Apttus_Config2__ExtendedPrice__c,
                                              Apttus_Config2__AdjustedPrice__c,Apttus_Config2__BasePrice__c,APTS_Extended_List_Price__c,
                                              Apttus_Config2__LineSequence__c,
												Apttus_Config2__Term__c,

                                              Configuration_Type__c,Apttus_Config2__StartDate__c,Duration__c,Apttus_Config2__HasOptions__c,Apttus_Config2__LineType__c,Contract_Duration__c,
                                              (select id,Apttus_Config2__IsTransient__c,Contract_Duration__c from Apttus_Config2__ProductAttributeValues__r)  
                                              from Apttus_Config2__LineItem__c  where id= :lineId]; 
        
        //if line item type is standalone
        if(oItem.Apttus_Config2__LineType__c == 'Product/Service' && oItem.Apttus_Config2__HasOptions__c == false)
        {
            CopystandaloneLineItem(oItem);
        }
        else  if(oItem.Apttus_Config2__LineType__c == 'Product/Service' && oItem.Apttus_Config2__HasOptions__c == true)
        {
            copyBundleWithOptions(oItem );
        } 
        return true;
    }
    
    private void CopystandaloneLineItem(Apttus_Config2__LineItem__c oItem)
    {
        //Loop through years to create additional years
        for(iCount = 0; iCount < years -1; iCount++)
        {   
            year++;
            /******  Copy standalone/bundle product API   *******/
            Apttus_CPQApi.CPQ.AddMultiProductRequestDO requests = new Apttus_CPQApi.CPQ.AddMultiProductRequestDO();
            requests.CartId = config_id;        
            requests.SelectedProducts = new List<Apttus_CPQApi.CPQ.SelectedProductDO>();
            //Use if we ned to copy custom fields along that
            Apttus_CPQApi.CPQ.SelectedProductDO prodDO = new Apttus_CPQApi.CPQ.SelectedProductDO();
            prodDO.CustomFields = new list<string>();
            prodDO.ProductId = oItem.Apttus_Config2__ProductId__c; //product id
            prodDO.Quantity = 1;
           
            prodDO.CustomFields.add('DerivedFromLineItemId__c');
            prodDO.CustomFields.add('Apttus_Config2__AdjustmentType__c');
            prodDO.CustomFields.add('Apttus_Config2__Quantity__c');
            prodDO.CustomFields.add('Apttus_Config2__AdjustmentAmount__c');
            prodDO.CustomFields.add('Apttus_Config2__StartDate__c');
            prodDO.CustomFields.add('Apttus_Config2__EndDate__c');
          //  prodDO.CustomFields.add('Apttus_Config2__PrimaryLineNumber__c');
            prodDO.CustomFields.add('Apttus_Config2__ExtendedPrice__c');
            prodDO.CustomFields.add('Apttus_Config2__AdjustedPrice__c');
            prodDO.CustomFields.add('Apttus_Config2__BasePrice__c');
            prodDO.CustomFields.add('APTS_Extended_List_Price__c');
            prodDO.CustomFields.add('Apttus_Config2__ConfigStatus__c');
            prodDO.CustomFields.add('Apttus_Config2__PricingStatus__c');
            //added MS
            prodDO.CustomFields.add('Apttus_Config2__Term__c');
            prodDO.CustomFields.add('Apttus_Config2__LineSequence__c');
            
            Apttus_Config2__LineItem__c li = new Apttus_Config2__LineItem__c();    
            
            if(oItem.Apttus_Config2__StartDate__c != null)
            {   
                newLineItemStartDate = oItem.Apttus_Config2__StartDate__c.addYears(year);
                li.Apttus_Config2__StartDate__c = newLineItemStartDate;
            }
            
            if(newLineItemStartDate != null)
            {   
                newLineItemEndDate = CalculateDateBasedOnDuration(newLineItemStartDate, oItem.Contract_Duration__c);
                li.Apttus_Config2__EndDate__c = newLineItemEndDate;
            }
            
            if(iCount == 0)
                li.DerivedFromLineItemId__c = oItem.id;
             else                          
                li.DerivedFromLineItemId__c = newLineItemId;     
                
            li.Apttus_Config2__AdjustmentType__c = oItem.Apttus_Config2__AdjustmentType__c;
            li.Apttus_Config2__Quantity__c = oItem.Apttus_Config2__Quantity__c;
            li.Apttus_Config2__AdjustmentAmount__c = oItem.Apttus_Config2__AdjustmentAmount__c;            
         //   li.Apttus_Config2__PrimaryLineNumber__c = oItem.Apttus_Config2__PrimaryLineNumber__c ;
            li.Apttus_Config2__ExtendedPrice__c = oItem.Apttus_Config2__ExtendedPrice__c;
            li.Apttus_Config2__AdjustedPrice__c = oItem.Apttus_Config2__AdjustedPrice__c;
            li.Apttus_Config2__BasePrice__c = oItem.Apttus_Config2__BasePrice__c;
            li.APTS_Extended_List_Price__c = oItem.APTS_Extended_List_Price__c;
            //ADDED MS
            li.Apttus_Config2__LineSequence__c = oItem.Apttus_Config2__LineSequence__c;
            li.Apttus_Config2__Term__c = oItem.Apttus_Config2__Term__c;
            //ENDED MS
            li.Apttus_Config2__ConfigStatus__c = 'NA';
            li.Apttus_Config2__PricingStatus__c = 'Pending';
            prodDO.CustomData = li;             
            
            requests.SelectedProducts.add(prodDO);
            Apttus_CPQApi.CPQ.AddMultiProductResponseDO response = Apttus_CPQApi.CPQWebService.addMultiProducts(requests);
            /******  Copy standalone/bundle product API   *******/
            
            lineNumbers = response.LineNumbers;
            if(lineNumbers.size() > 0)
                lineNumber = lineNumbers[0];
           
            //un select the selected checkbox and update line item
            oItem.Select__c = false;
            update oItem;            
            
            if(iCount == 0)
                lineitemid = oItem.id;
            else 
                lineitemid = newLineItemId;
           
            //create sql to fetch new line item based on derived from id field of old line item
            String soql= 'Select id, Apttus_Config2__StartDate__c, (' + sPAVSoql + ' from Apttus_Config2__ProductAttributeValues__r) from Apttus_Config2__LineItem__c where Apttus_Config2__IsPrimaryLine__c = true and Apttus_Config2__LineNumber__c   ='+ lineNumber +' and Apttus_Config2__ConfigurationId__c =: config_id';
            newLiItem = database.query(soql);            
           
            newLineItemId = newLiItem[0].id;
            newLineItemStartDate =  newLiItem[0].Apttus_Config2__StartDate__c;
            
            mapOldOptionToNewOptionIds.put(oItem.id, newLiItem[0].id); 
            SetAttributeForNewOptions(mapOldOptionToNewOptionIds);
        }
    }
    
    private void copyBundleWithOptions(Apttus_Config2__LineItem__c oItem)
    {         
        List<Apttus_Config2__ProductConfiguration__c> lstProdConfig = [Select Apttus_QPConfig__Proposald__c from Apttus_Config2__ProductConfiguration__c where id =:config_id];
        if(lstProdConfig.size() > 0)
            lstProposal = [Select Apttus_QPConfig__PriceListId__c from Apttus_Proposal__Proposal__c where id =: lstProdConfig[0].id];
        if(lstProposal.size() > 0)
            pricelistId = lstProposal[0].Apttus_QPConfig__PriceListId__c;        
        
        List<Apttus_Config2__LineItem__c> lstLineItemsToCopy = [Select id,Apttus_Config2__LineType__c,
                                                                Apttus_Config2__OptionId__c,Apttus_Config2__LineNumber__c,                                                                
                                                                Apttus_Config2__ProductId__c,Name,Apttus_Config2__AdjustmentType__c,
                                                                Apttus_Config2__Quantity__c,Apttus_Config2__AdjustmentAmount__c,
                                                                Apttus_Config2__EndDate__c,Apttus_Config2__PrimaryLineNumber__c,
                                                                Apttus_Config2__ExtendedPrice__c,Apttus_Config2__AdjustedPrice__c,
                                                                Apttus_Config2__BasePrice__c,APTS_Extended_List_Price__c,
                                                                Configuration_Type__c,Duration__c,Apttus_Config2__StartDate__c,Contract_Duration__c,(select id,Apttus_Config2__IsTransient__c,Contract_Duration__c from Apttus_Config2__ProductAttributeValues__r)                     
                                                                from Apttus_Config2__LineItem__c
                                                                where Apttus_Config2__ConfigurationId__c =:config_id];
        Map<Id,Apttus_Config2__LineItem__c> mapProdToOptionIds = new Map<Id,Apttus_Config2__LineItem__c>();
        Set<Id> optionIds = new Set<Id>();
        
        for(Apttus_Config2__LineItem__c oItem1 : lstLineItemsToCopy)
        {
            if(oItem.Apttus_Config2__ProductId__c == oItem1.Apttus_Config2__ProductId__c 
            && oItem.Apttus_Config2__LineNumber__c == oItem1.Apttus_Config2__LineNumber__c 
            && oItem1.Apttus_Config2__LineType__c == 'Option')
            {    
                mapProdToOptionIds.put(oItem1.Apttus_Config2__OptionId__c, oItem1);
                optionIds.add(oItem1.Apttus_Config2__OptionId__c);                
            }
        } 
        
        //Loop through years to create additional years
        for(iCount = 0; iCount < years -1; iCount++)
        { 
            year++;
            Apttus_CPQApi.CPQ.AddBundleRequestDO request = new Apttus_CPQApi.CPQ.AddBundleRequestDO();
            request.CartId = config_id;
            request.SelectedBundle = new Apttus_CPQApi.CPQ.SelectedBundleDO();
            request.SelectedBundle.SelectedProduct = new Apttus_CPQApi.CPQ.SelectedProductDO();
            request.SelectedBundle.SelectedProduct.ProductId = oItem.Apttus_Config2__ProductId__c;
            request.SelectedBundle.SelectedProduct.Quantity = 1;  
            
            request.SelectedBundle.SelectedProduct.CustomFields = new list<string>();
            request.SelectedBundle.SelectedProduct.CustomFields.add('DerivedFromLineItemId__c');
            request.SelectedBundle.SelectedProduct.CustomFields.add('Apttus_Config2__AdjustmentType__c');
            request.SelectedBundle.SelectedProduct.CustomFields.add('Apttus_Config2__Quantity__c');
            request.SelectedBundle.SelectedProduct.CustomFields.add('Apttus_Config2__AdjustmentAmount__c');
            request.SelectedBundle.SelectedProduct.CustomFields.add('Apttus_Config2__StartDate__c');
            request.SelectedBundle.SelectedProduct.CustomFields.add('Apttus_Config2__EndDate__c');
           // request.SelectedBundle.SelectedProduct.CustomFields.add('Apttus_Config2__PrimaryLineNumber__c');
            request.SelectedBundle.SelectedProduct.CustomFields.add('Apttus_Config2__ExtendedPrice__c');
            request.SelectedBundle.SelectedProduct.CustomFields.add('Apttus_Config2__AdjustedPrice__c');
            request.SelectedBundle.SelectedProduct.CustomFields.add('Apttus_Config2__BasePrice__c');
            request.SelectedBundle.SelectedProduct.CustomFields.add('APTS_Extended_List_Price__c');
            request.SelectedBundle.SelectedProduct.CustomFields.add('Apttus_Config2__ConfigStatus__c');
            request.SelectedBundle.SelectedProduct.CustomFields.add('Apttus_Config2__AddedBy__c');
            request.SelectedBundle.SelectedProduct.CustomFields.add('Apttus_Config2__Comments__c');
            Apttus_Config2__LineItem__c li = new Apttus_Config2__LineItem__c();
            if(iCount == 0)
            {                
                if(oItem.Apttus_Config2__StartDate__c != null)
                    newLineItemStartDateBundle = oItem.Apttus_Config2__StartDate__c.addYears(1);
                li.Apttus_Config2__StartDate__c = newLineItemStartDateBundle;
                
                if(oItem.Apttus_Config2__StartDate__c != null)
                    newLineItemEndDateBundle = oItem.Apttus_Config2__StartDate__c.addYears(2);
                li.Apttus_Config2__EndDate__c = newLineItemEndDateBundle;
            }
            else
            {  
                if(newLineItemStartDateBundle != null)
                {
                    newLineItemStartDateBundle = newLineItemStartDateBundle.addYears(1); 
                    li.Apttus_Config2__StartDate__c = newLineItemStartDateBundle;
                }
                if(newLineItemEndDateBundle != null)
                {
                    newLineItemEndDateBundle = newLineItemEndDateBundle.addYears(1);
                    li.Apttus_Config2__EndDate__c = newLineItemEndDateBundle;
                }                 
            }
            li.DerivedFromLineItemId__c = oItem.id;
            li.Apttus_Config2__AdjustmentType__c = oItem.Apttus_Config2__AdjustmentType__c;
            li.Apttus_Config2__Quantity__c = oItem.Apttus_Config2__Quantity__c;
            li.Apttus_Config2__AdjustmentAmount__c = oItem.Apttus_Config2__AdjustmentAmount__c;           
         //   li.Apttus_Config2__PrimaryLineNumber__c = oItem.Apttus_Config2__PrimaryLineNumber__c ;
            li.Apttus_Config2__ExtendedPrice__c = oItem.Apttus_Config2__ExtendedPrice__c;
            li.Apttus_Config2__AdjustedPrice__c = oItem.Apttus_Config2__AdjustedPrice__c;
            li.Apttus_Config2__BasePrice__c = oItem.Apttus_Config2__BasePrice__c;
            li.APTS_Extended_List_Price__c = oItem.APTS_Extended_List_Price__c;
            li.Apttus_Config2__ConfigStatus__c = 'NA';
            li.Apttus_Config2__AddedBy__c = 'Sweety Agrawal';
            request.SelectedBundle.SelectedProduct.CustomData = li;     
           
            set<Id> optionProductIdSet = new set<Id>();//Prepare set of option product Ids which needs to be added
            list<Apttus_CPQApi.CPQ.SelectedOptionDO> selectedOptDOList = new list<Apttus_CPQApi.CPQ.SelectedOptionDO>();
            Apttus_CPQApi.CPQ.ProductOptionGroupSearchResultDO result = Apttus_CPQApi.CPQWebService.getOptionGroupsForPriceListProduct(pricelistId, oItem.Apttus_Config2__ProductId__c);//a23q00000001DgyAAE
            system.debug(result);
            if(result.HasOptionGroups) {
                list<Apttus_CPQApi.CPQ.ProductOptionGroupDO> prodOptGrpDOList = result.OptionGroups;
                for(Apttus_CPQApi.CPQ.ProductOptionGroupDO prodOptGrpDO : prodOptGrpDOList) {
                    if(prodOptGrpDO.HasOptionComponents) {
                        list<Apttus_CPQApi.CPQ.ProductOptionComponentDO> prodOptCompDOList = new list<Apttus_CPQApi.CPQ.ProductOptionComponentDO>();                                      
                        prodOptCompDOList = prodOptGrpDO.OptionComponents;
                        
                        for(Apttus_CPQApi.CPQ.ProductOptionComponentDO prodOptCompDO :prodOptCompDOList) { 
                          if(optionIds.contains(prodOptCompDO.ComponentProductId)) {
                              Apttus_CPQApi.CPQ.SelectedOptionDO selectedOptDO = new Apttus_CPQApi.CPQ.SelectedOptionDO();
                              selectedOptDO.ComponentId = prodOptCompDO.ComponentId;              
                              selectedOptDO.ComponentProductId = prodOptCompDO.ComponentProductId;                
                              selectedOptDO.Quantity = 1;  
                              
                              selectedOptDO.CustomFields.add('DerivedFromLineItemId__c');
                              selectedOptDO.CustomFields.add('Apttus_Config2__AdjustmentType__c');
                              selectedOptDO.CustomFields.add('Apttus_Config2__Quantity__c');
                              selectedOptDO.CustomFields.add('Apttus_Config2__AdjustmentAmount__c');
                              selectedOptDO.CustomFields.add('Apttus_Config2__StartDate__c');
                              selectedOptDO.CustomFields.add('Apttus_Config2__EndDate__c');
                          //    selectedOptDO.CustomFields.add('Apttus_Config2__PrimaryLineNumber__c');
                              selectedOptDO.CustomFields.add('Apttus_Config2__ExtendedPrice__c');
                              selectedOptDO.CustomFields.add('Apttus_Config2__AdjustedPrice__c');
                              selectedOptDO.CustomFields.add('Apttus_Config2__BasePrice__c');
                              selectedOptDO.CustomFields.add('APTS_Extended_List_Price__c');
                              selectedOptDO.CustomFields.add('Apttus_Config2__ConfigStatus__c');
                              selectedOptDO.CustomFields.add('Apttus_Config2__AddedBy__c');
                              
                              li = new Apttus_Config2__LineItem__c();
                              li.DerivedFromLineItemId__c = mapProdToOptionIds.get(prodOptCompDO.ComponentProductId).id;
                              li.Apttus_Config2__AdjustmentType__c = mapProdToOptionIds.get(prodOptCompDO.ComponentProductId).Apttus_Config2__AdjustmentType__c ; 
                              li.Apttus_Config2__Quantity__c = mapProdToOptionIds.get(prodOptCompDO.ComponentProductId).Apttus_Config2__Quantity__c; 
                              li.Apttus_Config2__AdjustmentAmount__c = mapProdToOptionIds.get(prodOptCompDO.ComponentProductId).Apttus_Config2__AdjustmentAmount__c; 
                          //    li.Apttus_Config2__PrimaryLineNumber__c = mapProdToOptionIds.get(prodOptCompDO.ComponentProductId).Apttus_Config2__PrimaryLineNumber__c ; 
                              li.Apttus_Config2__ExtendedPrice__c = mapProdToOptionIds.get(prodOptCompDO.ComponentProductId).Apttus_Config2__ExtendedPrice__c; 
                              li.Apttus_Config2__AdjustedPrice__c = mapProdToOptionIds.get(prodOptCompDO.ComponentProductId).Apttus_Config2__AdjustedPrice__c; 
                              li.Apttus_Config2__BasePrice__c = mapProdToOptionIds.get(prodOptCompDO.ComponentProductId).Apttus_Config2__BasePrice__c; 
                              li.APTS_Extended_List_Price__c = mapProdToOptionIds.get(prodOptCompDO.ComponentProductId).APTS_Extended_List_Price__c; 
                              li.Apttus_Config2__ConfigStatus__c = 'NA';
                              li.Apttus_Config2__AddedBy__c = 'Sweety Agrawal';
                                                            
                              if(mapProdToOptionIds.get(prodOptCompDO.ComponentProductId).Apttus_Config2__StartDate__c != null)
                              {
                                  newLineItemStartDateOption = (mapProdToOptionIds.get(prodOptCompDO.ComponentProductId).Apttus_Config2__StartDate__c).addYears(year);
                                  li.Apttus_Config2__StartDate__c = newLineItemStartDateOption;
                              }
                              
                              if(newLineItemStartDateOption != null)
                              {
                                  newLineItemEndDateOption = CalculateDateBasedOnDuration(newLineItemStartDateOption, mapProdToOptionIds.get(prodOptCompDO.ComponentProductId).Contract_Duration__c);
                                  li.Apttus_Config2__EndDate__c = newLineItemEndDateOption;
                              }                             
                              selectedOptDO.CustomData = li;
                              selectedOptDOList.add(selectedOptDO);
                         }
                        }
                    }
                }                
            }
            
            if(selectedOptDOList.size()>0)
           {
                request.SelectedBundle.SelectedOptions = selectedOptDOList ;
           }
            Apttus_CPQApi.CPQ.AddBundleResponseDO response = Apttus_CPQApi.CPQWebService.addBundle(request);
            lineNumber = response.LineNumber;
            if(iCount == 0)
                lineitemid = oItem.id;
            else 
                lineitemid = newLineItemId;
            
            String soql= 'Select id,Apttus_Config2__Comments__c,Apttus_Config2__ProductId__c,Apttus_Config2__LineNumber__c,Apttus_Config2__LineType__c,Apttus_Config2__StartDate__c,DerivedFromLineItemId__c,Apttus_Config2__EndDate__c from Apttus_Config2__LineItem__c where Apttus_Config2__LineNumber__c  ='+ lineNumber +' and Apttus_Config2__ConfigurationId__c =: config_id';
            newLiItem = database.query(soql);            
            if(newLiItem.size() > 0)
            {
                for(Integer iItemCount = 0; iItemCount < newLiItem.size(); iItemCount++)
                {                   
                    if(newLiItem[iItemCount].Apttus_Config2__LineType__c == 'Product/Service')
                    {                        
                        newLineItemId = newLiItem[iItemCount].id;                        
                    }
                    else if(newLiItem[iItemCount].Apttus_Config2__LineType__c == 'Option')
                    {
                        mapOldOptionToNewOptionIds.put(newLiItem[iItemCount].DerivedFromLineItemId__c, newLiItem[iItemCount].id);                        
                    }
                }
            }            
            SetAttributeForNewOptions(mapOldOptionToNewOptionIds);
            //un select the selected checkbox and update line item
            oItem.Select__c = false;
            update oItem;             
        }
    }    
      
    private void DaysInCurrentYear()
    {
        Integer year = System.Today().year();
        if(math.mod(year,400) == 0 || (math.mod(year,4) == 0 && math.mod(year,100) != 0))
            currentYearDays = 366;
        else
            currentYearDays = 365;
    }
    
    private Date CalculateDateBasedOnDuration(Date dateToUpdate, String sDuration)
    {
        System.debug('sDuration'+sDuration);
        if(sDuration != null)
        {
            if(sDuration.toUpperCase().trim().contains('MONTH'))
            {            
                sDurationInDays = sDuration.substring(0, sDuration.toUpperCase().trim().indexOf('MONTH')).trim();
                Duration = integer.valueof(sDurationInDays);
                dateToUpdate = dateToUpdate.addMonths(Duration);
                return dateToUpdate;
            }
            
            if(sDuration.toUpperCase().trim().contains('DAY'))
            {            
                sDurationInDays = sDuration.substring(0, sDuration.toUpperCase().trim().indexOf('DAY')).trim();
                Duration = integer.valueof(sDurationInDays);
            }
            else if(sDuration.toUpperCase().trim().contains('WEEK'))
            {            
                sDurationInDays = sDuration.substring(0, sDuration.toUpperCase().trim().indexOf('WEEK')).trim();
                Duration = integer.valueof(sDurationInDays) * 7;
            }
            else if(sDuration.toUpperCase().trim().contains('YEAR'))
            {            
                sDurationInDays = sDuration.substring(0, sDuration.toUpperCase().trim().indexOf('YEAR')).trim();
                Duration = integer.valueof(sDurationInDays) * currentYearDays;
            }
            dateToUpdate = dateToUpdate.adddays(Duration);
            return dateToUpdate;   
        }
        return null; 
    }
     
    private void SOQLForProdAttribute()
    {
        Apttus_Config2__ProductAttributeValue__c prodAttr = new Apttus_Config2__ProductAttributeValue__c();
        // get all ProductAttributeValue fields from database schema
        Schema.SObjectType objectType = prodAttr.getSObjectType();
        set<String> prodAttrFields = objectType.getDescribe().fields.getMap().keySet();
        mapStrSobject = objectType.getDescribe().fields.getMap();
        Map<String,String> mapKeyValueProdAttr = new Map<String,String>();
        sPAVSoql = 'select ';
        
        for(String fieldName : mapStrSobject.keySet()) {
            if(mapStrSobject.get(fieldName).getDescribe().isUpdateable()) {
                sPAVSoql += fieldName +','; 
            }
        }        
        sPAVSoql = sPAVSoql.substring(0, sPAVSoql.length() - 1);        
    }
    
    private Map<String, String> GetProdAttrbuteValuesWithFields(Apttus_Config2__ProductAttributeValue__c attrValueResults)
    {
        Apttus_Config2__ProductAttributeValue__c prodAttr = new Apttus_Config2__ProductAttributeValue__c();
        // get all ProductAttributeValue fields from database schema
        Schema.SObjectType objectType = prodAttr.getSObjectType();
        set<String> prodAttrFields = objectType.getDescribe().fields.getMap().keySet();
        Map<String,String> mapOptionKeyValueProdAttr = new Map<String,String>();
        
        // put field values of first record into a map..
        for (string fld :prodAttrFields){
            try{
                mapOptionKeyValueProdAttr.put(fld, string.valueOf(attrValueResults.get(fld)));               
            } catch (exception e){
                system.debug(fld);
            }
        }
        return mapOptionKeyValueProdAttr;
    }
    
    private void SetAttributeForNewOptions(Map<Id, Id> mapOldOptionToNewOptionIds)
    {
        Map<Id, Apttus_Config2__ProductAttributeValue__c> mapOldOptionIdsPAV = new Map<Id, Apttus_Config2__ProductAttributeValue__c>();
        Map<Id, Apttus_Config2__ProductAttributeValue__c> mapNewOptionIdsPAV = new Map<Id, Apttus_Config2__ProductAttributeValue__c>();
        Map<Id, Map<String,String>> mapOldOptionLIIdToPAVKV = new Map<Id, Map<String, string>>();            
        List<Id> lstOldOptionIds = new List<Id>();
        List<Id> lstNewOptionIds = new List<Id>();
        Map<String, String> mapOptionKeyValueProdAttr = new Map<String,String>();
        List<Apttus_Config2__ProductAttributeValue__c> lstPAVToUpdate = new List<Apttus_Config2__ProductAttributeValue__c>();        
        
        //Loop through map of old and new option line item id and add them separately in two list 
        for(Id optionId : mapOldOptionToNewOptionIds.keySet())
        {
            lstOldOptionIds.add(optionId);
            lstNewOptionIds.add(mapOldOptionToNewOptionIds.get(optionid));
        }        
        String sOldOptionIds = String.join(lstOldOptionIds, '\',\'');
        String sNewOptionIds = String.join(lstNewOptionIds, '\',\'');
        
        //prepare soql to fetch PAV data for old option line item ids
        String sPAVSoqlOldOption = sPAVSoql + ' from Apttus_Config2__ProductAttributeValue__c where Apttus_Config2__LineItemId__c in (\'' +sOldOptionIds+'\')' ;       
        //use soql and fetch PAV, store in list 
        List<Apttus_Config2__ProductAttributeValue__c> lstOldOptionPAV = database.query(sPAVSoqlOldOption);        
        for(Apttus_Config2__ProductAttributeValue__c oPAV : lstOldOptionPAV)
        {
            //fetch pav record of old option lineitem id and pass to function GetProdAttrbuteValuesWithFields that will return map of key,value key ==> field name, value ==> value
            mapOldOptionLIIdToPAVKV.put(oPAV.Apttus_Config2__LineItemId__c, GetProdAttrbuteValuesWithFields(oPAV));
            mapOldOptionIdsPAV.put(oPAV.Apttus_Config2__LineItemId__c, oPAV);
        }
        
        //prepare soql to fetch PAV data for new option line item ids
        String sPAVSoqlNewOption = sPAVSoql + ' from Apttus_Config2__ProductAttributeValue__c where Apttus_Config2__LineItemId__c in (\'' +sNewOptionIds+'\')';        
        //use soql and fetch PAV, store in list 
        List<Apttus_Config2__ProductAttributeValue__c> lstNewOptionPAV = database.query(sPAVSoqlNewOption);                
        for(Apttus_Config2__ProductAttributeValue__c oPAV : lstNewOptionPAV)
        {
            mapNewOptionIdsPAV.put(oPAV.Apttus_Config2__LineItemId__c, oPAV);
        }
        
        for(Id optionId : mapOldOptionToNewOptionIds.keySet())
        {            
            if(optionid == mapOldOptionIdsPAV.get(optionId).Apttus_Config2__LineItemId__c)
            {                
                Apttus_Config2__ProductAttributeValue__c newProdAttr = mapNewOptionIdsPAV.get(mapOldOptionToNewOptionIds.get(optionid));
                 for(String key :  mapOldOptionLIIdToPAVKV.get(optionid).keySet())
                 {                
                     if(key == 'Apttus_Config2__LineItemId__c')
                         newProdAttr.put(key,mapOldOptionToNewOptionIds.get(optionId));   
                     else if(key != 'id' && mapStrSobject.get(key).getDescribe().getType() == Schema.DisplayType.Boolean)
                         newProdAttr.put(key,Boolean.valueOf(mapOldOptionLIIdToPAVKV.get(optionid).get(key)));
                     else if(key != 'id' && mapStrSobject.get(key).getDescribe().getType() ==   Schema.DisplayType.Double)
                     {
                         Decimal dValue = null;
                         
                         if((mapOldOptionLIIdToPAVKV.get(optionid)).get(key) != null)
                             dValue = Decimal.valueOf((mapOldOptionLIIdToPAVKV.get(optionid)).get(key));
                         newProdAttr.put(key,dValue);
                     }
                     else if(key != 'id')
                     {
                         newProdAttr.put(key,(mapOldOptionLIIdToPAVKV.get(optionid)).get(key));
                     }
                 } 
                lstPAVToUpdate.add(newProdAttr);
            }            
        }        
        update lstPAVToUpdate; 
    }
      
}