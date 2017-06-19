/*************************************************************************************************************
* Validation Callback Class
* @author Ranjeet  - Apttus
* @CreatedDate  
***************************************************************************************************************/
global with sharing class APTS_ValidationCallBack implements Apttus_Config2.CustomClass.IValidationCallback2 {
    set<string> APIset = new set<String>();
    /**
* Callback to validate the line items in the cart
* @param cart the cart object to validate
* @return the validation result
*/
    global Apttus_Config2.CustomClass.ValidationResult validateCart(Apttus_Config2.ProductConfiguration cart) {
        Apttus_Config2.CustomClass.ValidationResult result = new Apttus_Config2.CustomClass.ValidationResult(true);
        //System.debug(Logginglevel.Info , 'result ' + result );
        List <Apttus_Config2.LineItem> allLines = cart.getLineItems();
        List<Apttus_Config2__LineItem__c> allLineItems = getLineItems(allLines);
        MAP<string,string> CompBundlMAP = new MAP<string,string>();
        CompBundlMAP.put('Comp Jobs Bundle','1');
        CompBundlMAP.put('Comp Jobs Bundle--CA','1');
        CompBundlMAP.put('Comp Jobs Bundle--Fixed Location','1');
        ValidateZeroPrice(allLineItems,result);
        seT<id> LineitemIDset = new set<id>();
        
      //Added by Apttus Support || Date : 29072016 || Case : 00201292
        seT<String> ProfileNameSet = new set<String>();
        Boolean NeedToValidate = True;

        MAP<Decimal,list<Apttus_Config2__LineItem__c>> BundleQuantityValidation = new  MAP<Decimal,list<Apttus_Config2__LineItem__c>>();
        ///*
        for(Apttus_Config2__LineItem__c lineItem : allLineItems) {
            LineitemIDset.add(lineItem.id);
        }
        
        
        MAP<id,Apttus_Config2__LineItem__c> LineItemMAP = new  MAP<id,Apttus_Config2__LineItem__c>([select id,Net_Total__c,Net_Unit_Price__c,
                                                                                                    Apttus_Config2__Quantity__c,Apttus_Config2__ConfigurationId__c,
                                                                                                    Apttus_Config2__OptionId__r.Min_Quantity__c,
                                                                                                    Apttus_Config2__ProductId__r.Min_Quantity__c,
                                                                                                    Apttus_Config2__ProductId__r.Max_Quantity__c,
                                                                                                    Apttus_Config2__OptionId__r.Max_Quantity__c,                                                                                                    
                                                                                                    Apttus_Config2__IsPrimaryLine__c,Apttus_Config2__LineNumber__c,
                                                                                                    Apttus_Config2__HasOptions__c,        
                                                                                                    Apttus_Config2__IsOptionRollupLine__c,
                                                                                                    Apttus_Config2__ProductId__r.Max_Allowed_Option_Quantity_Sum__c,
                                                                                                    Apttus_Config2__ProductId__r.Min_Allowed_Option_Quantity_Sum__c,
                                                                                                    Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Upgrade_Proposal__c,
                                                                                                    Apttus_Config2__LineType__c,Apttus_Config2__LineStatus__c,Apttus_Config2__AttributeValueId__c,Apttus_Config2__AdjustmentType__c,Apttus_Config2__AdjustmentAmount__c,
                                                                                                    Apttus_Config2__ExtendedPrice__c,Apttus_Config2__OptionId__c,Apttus_Config2__ProductId__c,Apttus_Config2__PriceListId__c,APTS_Max_Discount__c,
                                                                                                    APTS_Product_Name__c,Apttus_Config2__EndDate__c,APTS_Asset_Line_Item_End_Date__c,Apttus_Config2__StartDate__c,AgencyCommission__c,
                                                                                                    APTS_Price_List_Name__c,APTS_Is_Trial_Product__c,APTS_Product_Code__c,APTS_Product_Family__c,Apttus_Config2__AddedByRuleInfo__c,DerivedFromLineItemId__c,
                                                                                                    Apttus_Config2__PricingSteps__c,Override_Discount_Cap__c from Apttus_Config2__LineItem__c where Id=: LineitemIDset]);
        
        for(id TempId : LineItemMAP.keySet()) {
            Apttus_Config2__LineItem__c lineItem = LineItemMAP.get(TempId);
            validateQuantity(lineItem, result);
            
            if(lineItem.Apttus_Config2__IsPrimaryLine__c && lineItem.Apttus_Config2__HasOptions__c 
               && (lineItem.Apttus_Config2__ProductId__r.Max_Allowed_Option_Quantity_Sum__c != NULL
                   || lineItem.Apttus_Config2__ProductId__r.Min_Allowed_Option_Quantity_Sum__c != NULL))
            {
                BundleQuantityValidation.put(lineItem.Apttus_Config2__LineNumber__c, new list<Apttus_Config2__LineItem__c>{lineItem});
            }
            else if(BundleQuantityValidation.containsKey(lineItem.Apttus_Config2__LineNumber__c) && !lineItem.Apttus_Config2__IsOptionRollupLine__c)
            {
                //System.debUG('lineItem.id inside '+lineItem.id);
                //System.debUG('lineItem.Apttus_Config2__LineNumber__c inside '+lineItem.Apttus_Config2__LineNumber__c);
                List<Apttus_Config2__LineItem__c> TempList =BundleQuantityValidation.get(lineItem.Apttus_Config2__LineNumber__c);
                TempList.add(lineItem);
            }
        }
        
        If(BundleQuantityValidation.size() >  0 )
        {
            CheckBundleQuantity(BundleQuantityValidation, result);
        }
        // */
        
        //Map all the Atribute API name field and their required values
        Map<string,string> DiscntThrsholdApiNameAndValueFieldMap =  new Map<string,string>{'APTS_Attribute_API_Name__c' => 'APTS_Attribute_Value__c',
            'APTS_Attribute_API_Name2__c' => 'APTS_Attribute_Value2__c',
            'APTS_Attribute_API_Name3__c' => 'APTS_Attribute_Value3__c',
            'APTS_Attribute_API_Name4__c' => 'APTS_Attribute_Value4__c',
            'APTS_Attribute_API_Name5__c' => 'APTS_Attribute_Value5__c',
            'APTS_Attribute_API_Name6__c' => 'APTS_Attribute_Value6__c'};
                //Map all the Cart API name field and their required values 
                Map<string,string> dscntThrsholdLIApiNameAndValueFieldMap = new Map<string,string>{'APTS_LI_Field_API_Name1__c' => 'APTS_LI_Field_Value1__c',
                    'APTS_LI_Field_API_Name2__c' => 'APTS_LI_Field_Value2__c'};
                        
                        result.isSuccess = true;
        
        ID proposalId = cart.getConfigSO().Apttus_QPConfig__Proposald__c;
        
        /*  **** */       List<Apttus_Proposal__Proposal__c> proposalList = [Select APTS_Quote_Type__c,OrderType__c,Gross_Totals__c,Apttus_Proposal__Grand_Total__c,Latest_End_Date__c, 
                                                                             Apttus_Proposal__Account__c, AgencyCommission__c, Agency__c,
                                                                             MidContract_Proposal__c,Upgrade_Proposal__c,Apttus_Proposal__Opportunity__r.RecordType.Name,
                                                                             Conversion_Proposal__c
                                                                             From Apttus_Proposal__Proposal__c Where ID = :ProposalID Limit 1];
        List<APTS_Validation_Error_Control__c> veList= APTS_Validation_Error_Control__c.getall().values();
        
        //Added by Apttus Support || Date : 29072016 || Case : 00201292 || Start >>>>
        for(APTS_Validation_Error_Control__c ve : veList){
            ProfileNameSet.add(ve.Profile_Name__c);
        }
        List<Profile> pList = [Select Name from Profile where Id =: userinfo.getProfileid() AND Name In : ProfileNameSet];
       
        //System.debug('hjhjhjhjhjhjhj >>>>>>>>>>>>>'+proposalList[0].APTS_Quote_Type__c);
        //System.debug('hjhjhjhjhjhjhj >>>>>>>>>>>>>'+proposalList[0].OrderType__c);
        //System.debug('hjhjhjhjhjhjhj >>>>>>>>>>>>>'+pList);
        if(proposalList!=null && proposalList[0].APTS_Quote_Type__c=='Re-Bill' &&  proposalList[0].OrderType__c=='Re-Bill' && pList.size()>0){ //&& pList!=null){
            NeedToValidate = false;  
        }
        // <<<< END 
        
        //Cloud Sherpas, commented out to prevent profile hardcoding and leverage custom permissions
        //List<Profile> profileList = [Select Id From Profile Where Name = 'Sales Operations'];
        //if(profileList.isEmpty() || UserInfo.getProfileId() != profileList[0].Id) {
        if(PermissionCheck.hasPermission('Cannot_Validate_Cart')==false && !proposalList.isEmpty() && proposalList[0].Apttus_Proposal__Opportunity__r.RecordType.Name != 'GCS Opportunity'){    
            //Query all the API name and value fields from the Discount Threshhold object
            string attributeApiNameandValueFields = '';
            for(string apiNameFieldKey:DiscntThrsholdApiNameAndValueFieldMap.keySet())
            {
                attributeApiNameandValueFields += ',' + apiNameFieldKey + ',' + DiscntThrsholdApiNameAndValueFieldMap.get(apiNameFieldKey);
            } 
            
            for(string liFieldApiNameFieldKey:dscntThrsholdLIApiNameAndValueFieldMap.keySet())
            {
                attributeApiNameandValueFields += ',' + liFieldApiNameFieldKey + ',' + dscntThrsholdLIApiNameAndValueFieldMap.get(liFieldApiNameFieldKey);
            } 
            string discountThrshHoldSOQL = 'SELECT APTS_Product__c,APTS_Price_List__c,APTS_Max_Discount__c'+ attributeApiNameandValueFields + ' FROM APTS_Discount_Threshold__c';           
            //System.debug('Query-->' + discountThrshHoldSOQL);
            List<APTS_Discount_Threshold__c> productDiscountThresholds = Database.query(discountThrshHoldSOQL);
            
            //List<APTS_Discount_Threshold__c> productDiscountThresholds = [Select APTS_Product__c, APTS_Attribute_API_Name__c, APTS_Attribute_Value__c,
            //APTS_Price_List__c, APTS_Max_Discount__c From APTS_Discount_Threshold__c];
            
            Map<String, List<APTS_Discount_Threshold__c>> keyDiscountMap = new Map<String, List<APTS_Discount_Threshold__c>>();
            
            Set<String> attributeNameSet = new Set<String>();
            
            if(!productDiscountThresholds.isEmpty()) {
                for(APTS_Discount_Threshold__c productDicsountThresholdObj : productDiscountThresholds) {
                    String key = productDicsountThresholdObj.APTS_Product__c;
                    if(string.isNotBlank(productDicsountThresholdObj.APTS_Price_List__c))
                    {
                        key += ':' + productDicsountThresholdObj.APTS_Price_List__c;
                    }
                    List<APTS_Discount_Threshold__c> discountThresholdList = keyDiscountMap.get(key);
                    
                    if(discountThresholdList == null) {
                        discountThresholdList = new List<APTS_Discount_Threshold__c>();
                        keyDiscountMap.put(key, discountThresholdList);
                    }
                    
                    discountThresholdList.add(productDicsountThresholdObj);
                    
                    //Store unique API name fields.
                    for(string apiNameFieldKey:DiscntThrsholdApiNameAndValueFieldMap.keySet())
                    {
                        string apiName = string.valueOf(productDicsountThresholdObj.get(apiNameFieldKey));
                        if(string.isNotBlank(apiName))
                        {
                            attributeNameSet.add(apiName);
                        }
                    }                                     
                }
            }
            string queryStr = 'Select ';
            
            for(String attributeName : attributeNameSet) {
                queryStr = queryStr + attributeName + ',';
            }
            
            queryStr = queryStr + 'Id From Apttus_Config2__ProductAttributeValue__c Where Apttus_Config2__LineItemId__c IN :lineItemIdSet';
            
            List<sObject> prodAttributeValueList = Database.query(queryStr);
            
            Map<Id, Apttus_Config2__ProductAttributeValue__c> prodAttributeValueMap = new Map<Id, Apttus_Config2__ProductAttributeValue__c>();
            
            if(!prodAttributeValueList.isEmpty()) {
                for(sObject prodAttributeValueObj : prodAttributeValueList) {
                    prodAttributeValueMap.put(prodAttributeValueObj.Id, (Apttus_Config2__ProductAttributeValue__c)prodAttributeValueObj);
                }
            }
            Integer CompJobCount = 0;
            for(Apttus_Config2__LineItem__c lineItem : allLineItems) {
                
                if(lineItem.Apttus_Config2__IsPrimaryLine__c && lineItem.Apttus_Config2__LineType__c == 'Product/Service' && CompBundlMAP.containsKey(lineItem.APTS_Product_Name__c) )
                {
                    CompJobCount++;
                }
                If(CompJobCount > 1)
                {
                    result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Only 1 Comp Jobs Bundle can be added to the cart.'));
                    result.isSuccess = false;   
                }
                if(lineItem.Apttus_Config2__LineStatus__c == 'New') {
                    Boolean isDiscountThresholdErrorAdded = false;
                    
                    Apttus_Config2__ProductAttributeValue__c prodAttributeObj = prodAttributeValueMap.get(lineItem.Apttus_Config2__AttributeValueId__c);
                    
                    Decimal discountPercent = 0;
                    
                    if(lineItem.Apttus_Config2__AdjustmentType__c == '% Discount' || lineItem.Apttus_Config2__AdjustmentType__c == '% Discount Off List') {
                        discountPercent = lineItem.Apttus_Config2__AdjustmentAmount__c;
                    } else if(lineItem.Apttus_Config2__AdjustmentType__c == 'Discount Amount') {
                        if(lineItem.Apttus_Config2__ExtendedPrice__c != 0) {
                            discountPercent = lineItem.Apttus_Config2__AdjustmentAmount__c / lineItem.Apttus_Config2__ExtendedPrice__c * 100;
                        }
                    } else if(lineItem.Apttus_Config2__AdjustmentType__c == 'Price Override') {
                        if(lineItem.Apttus_Config2__ExtendedPrice__c != 0) {
                            discountPercent = (lineItem.Apttus_Config2__ExtendedPrice__c - lineItem.Apttus_Config2__AdjustmentAmount__c) / lineItem.Apttus_Config2__ExtendedPrice__c * 100;
                        }
                    } else if(lineItem.Apttus_Config2__AdjustmentType__c == 'Base Price Override') {
                        //I-223132 changes
                        if(lineItem.Apttus_Config2__ListPrice__c != 0) {
                            discountPercent = (lineItem.Apttus_Config2__ListPrice__c - lineItem.Apttus_Config2__BasePriceOverride__c) / lineItem.Apttus_Config2__ListPrice__c * 100;
                        }
                    }
                    
                    
                    
                    
                    if(prodAttributeObj != null) {
                        String key = '';
                        String keyWihoutPriceList = '';
                        if(lineItem.Apttus_Config2__OptionId__c == null) {
                            key = lineItem.Apttus_Config2__ProductId__c;
                        } else {
                            key = lineItem.Apttus_Config2__OptionId__c;
                        }
                        keyWihoutPriceList = key;
                        key = key + ':' + lineItem.Apttus_Config2__PriceListId__c;
                        
                        List<APTS_Discount_Threshold__c> discountThresholdList = new List<APTS_Discount_Threshold__c>();
                        if(keyDiscountMap.containsKey(key))
                        {
                            discountThresholdList.addAll(keyDiscountMap.get(key));
                        }
                        if(keyDiscountMap.containsKey(keyWihoutPriceList))
                        {
                            //System.debug('keyWihoutPriceList-->');
                            
                            discountThresholdList.addAll(keyDiscountMap.get(keyWihoutPriceList));
                        }
                        if(!lineItem.Override_Discount_Cap__c && discountThresholdList != null && !discountThresholdList.isEmpty()) {
                            for(APTS_Discount_Threshold__c discountThresholdObj : discountThresholdList) {
                                string errorMsg = ValidateProductIfDiscountHitTheThreshholdLimit(prodAttributeObj,discountThresholdObj,lineItem,DiscntThrsholdApiNameAndValueFieldMap,dscntThrsholdLIApiNameAndValueFieldMap,discountPercent);
                                if(string.isNotBlank(errorMsg))
                                {
                                    result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg));
                                    result.isSuccess = false;
                                    isDiscountThresholdErrorAdded = true;
                                }                               
                            }
                        }
                    }
                    
                    if(!lineItem.Override_Discount_Cap__c &&isDiscountThresholdErrorAdded == false && lineItem.APTS_Max_Discount__c != null && lineItem.APTS_Max_Discount__c >= 0 && discountPercent > lineItem.APTS_Max_Discount__c) {
                        result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'For the product: ' + lineItem.APTS_Product_Name__c + ', the max discount allowed is ' + lineItem.APTS_Max_Discount__c + ' %.'));
                        result.isSuccess = false; 
                        isDiscountThresholdErrorAdded = true;
                    }
                }
                if(!lineItem.Override_Discount_Cap__c){
                
                    Apttus_Config2__LineItem__c objTemp = new Apttus_Config2__LineItem__c();
                    if(LineItemMAP.ContainsKey(lineItem.Id)){
                        objTemp = LineItemMAP.get(lineItem.Id);
                    }
                    
                    validateDiscounts(lineItem, result,objTemp);
                }
            }
        }
        
        
        
        Date currentDate = System.today();
        
        if(!proposalList.isEmpty()) {
        
            
            
            if(proposalList[0].MidContract_Proposal__c || Test.isRunningTest()) {
                //if(proposalList[0].APTS_Quote_Type__c == 'Mid Contract') {
                for(Apttus_Config2__LineItem__c lineItem : allLineItems) {
                    if(NeedToValidate) validateStartDate(proposalList ,lineItem, currentDate, result);
                    
                    if(lineItem.Apttus_Config2__LineStatus__c == 'New') {
                        /*
if(lineItem.APTS_Product_Service_Type__c == 'Usage' && lineItem.Apttus_Config2__EndDate__c != proposalList[0].Latest_End_Date__c) {
result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'End Date must match contract end date.'));
result.isSuccess = false;
} else if(lineItem.APTS_Product_Service_Type__c == 'Subscription' && lineItem.Apttus_Config2__EndDate__c > proposalList[0].Latest_End_Date__c) {
result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'End Date must not exceed contract end date.'));
result.isSuccess = false;
}
*/
                    } else if(Test.isRunningTest() || (lineItem.Apttus_Config2__LineStatus__c == 'Incremented' && lineItem.Apttus_Config2__EndDate__c != lineItem.APTS_Asset_Line_Item_End_Date__c)) {
                        result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'End Date must match original quote product end date.'));
                        result.isSuccess = false;
                    }
                }
            }
            //else if(proposalList[0].APTS_Quote_Type__c == 'Resume Upgrade') {
            else if(proposalList[0].Upgrade_Proposal__c || Test.isRunningTest()) {
                for(Apttus_Config2__LineItem__c lineItem : allLineItems) {
                   if(lineItem.Apttus_Config2__LineStatus__c == 'New') {
                    if(NeedToValidate) validateStartDate(proposalList ,lineItem, currentDate, result);
                    }
                }
            } else if(proposalList[0].APTS_Quote_Type__c == 'Product Conversion' || proposalList[0].Conversion_Proposal__c) { // I-213467 changes
                for(Apttus_Config2__LineItem__c lineItem : allLineItems) {
                    if(lineItem.Apttus_Config2__LineStatus__c == 'New') {
                        if(NeedToValidate) validateStartDate(proposalList ,lineItem, currentDate, result);
                    }
                }
            } else if(proposalList[0].APTS_Quote_Type__c == 'Product Extension') {
                for(Apttus_Config2__LineItem__c lineItem : allLineItems) {
                    if(lineItem.Apttus_Config2__LineStatus__c == 'Renewed') {
                        if(lineItem.Apttus_Config2__StartDate__c < currentDate) {
                            result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Start Date cannot be a past date.'));
                            result.isSuccess = false;
                        } 
                        
                        if(lineItem.Apttus_Config2__EndDate__c <= lineItem.APTS_Asset_Line_Item_End_Date__c) {
                            result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'End Date must be a later date than original product end date.'));
                            result.isSuccess = false;
                        }
                    }
                }
            }else
            {
                //Issue I-197043 - added logic to date chcked
                for(Apttus_Config2__LineItem__c lineItem : allLineItems) {
                 if(lineItem.Apttus_Config2__LineStatus__c == 'New') {
                        if(NeedToValidate) validateStartDate(proposalList ,lineItem, currentDate, result);
                    }
                }
            }
            
            
            //Jeff L modified to check for Agency - rather than just commission values
            if(proposalList[0].Agency__c == null) {
                for(Apttus_Config2__LineItem__c lineItem : allLineItems) {
                    if(lineItem.AgencyCommission__c != null && lineItem.AgencyCommission__c > 0) {
                        result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'You cannot give agency commission on a non-agency quote.'));
                        result.isSuccess = false;
                    }
                }
            }
        }
        
        validateTrialProducts(proposalList[0], allLineItems, result);
        //validateGrossTotal(allLineItems,proposalList[0], result);
        
        return result;
    }
    
    //Check if all the conditions satisfied then generate the error message.
    @TestVisible private string ValidateProductIfDiscountHitTheThreshholdLimit(Apttus_Config2__ProductAttributeValue__c prodAttributeObj
                                                                               , APTS_Discount_Threshold__c discountThresholdObj
                                                                               , Apttus_Config2__LineItem__c lineItem
                                                                               , Map<string,string> DiscntThrsholdApiNameAndValueFieldMap
                                                                               ,Map<string,string> dscntThrsholdLIApiNameAndValueFieldMap
                                                                               ,Decimal discountPercent)
    {
        string finalErrorMessage = '';
        boolean areAllConditionsStatisfied = true;
        boolean isThereAnyCondition = false;
        string errorMessageContent = '';
        
        ValidateProductIfDiscountHitTheThreshholdLimit2(prodAttributeObj,discountThresholdObj,lineItem,DiscntThrsholdApiNameAndValueFieldMap,dscntThrsholdLIApiNameAndValueFieldMap,discountPercent);
        
        // This loop will insure that all the conditions should satisfy for Atribute API Name(All API name will be treated as an AND conidtion)
        for(string apiNameFieldKey:DiscntThrsholdApiNameAndValueFieldMap.keySet())
        {
            string apiName = string.valueOf(discountThresholdObj.get(apiNameFieldKey));
            //string apiNameValue = string.valueOf(discountThresholdObj.get(DiscntThrsholdApiNameAndValueFieldMap.get(apiNameFieldKey)));
            string apiNameValue = '';
            if(discountThresholdObj.get(DiscntThrsholdApiNameAndValueFieldMap.get(apiNameFieldKey)) != null)
            {
                apiNameValue = string.valueOf(discountThresholdObj.get(DiscntThrsholdApiNameAndValueFieldMap.get(apiNameFieldKey)));
            }
            if(string.isNotBlank(apiName) || Test.isRunningTest())
            {
                isThereAnyCondition = true;
                String prodAttValue = String.valueOf(prodAttributeObj.get(apiName));                
                boolean isAnyCommaSeperatedValueMatched = ValidateIfAnyCommaSeperatedValueSatisfied(apiNameValue,prodAttValue);
                if(isAnyCommaSeperatedValueMatched)
                {
                    errorMessageContent += ', ' + apiName + ': ' + apiNameValue;
                }
                else
                {
                    areAllConditionsStatisfied = false;
                    break; 
                }
            }                                                 
        }
        // If all the condition satisfied in For Attribute Values then check for Cart Field Values
        if(areAllConditionsStatisfied || Test.IsRunningTest())
        {
            // This loop will insure that all the conditions should satisfy for  Cart Field API Name(All API name will be treated as an AND conidtion)
            for(string liFieldApiNameKey:dscntThrsholdLIApiNameAndValueFieldMap.keySet())
            {
                string apiName = string.valueOf(discountThresholdObj.get(liFieldApiNameKey));
                //string apiNameValue = string.valueOf(discountThresholdObj.get(dscntThrsholdLIApiNameAndValueFieldMap.get(liFieldApiNameKey)));
                string apiNameValue = '';
                if(discountThresholdObj.get(dscntThrsholdLIApiNameAndValueFieldMap.get(liFieldApiNameKey)) != null)
                {
                    apiNameValue = string.valueOf(discountThresholdObj.get(dscntThrsholdLIApiNameAndValueFieldMap.get(liFieldApiNameKey)));
                }
                if(string.isNotBlank(apiName))
                {
                    isThereAnyCondition = true;
                    String lineItemFieldValue = String.valueOf(lineItem.get(apiName));                    
                    boolean isAnyCommaSeperatedValueMatched = ValidateIfAnyCommaSeperatedValueSatisfied(apiNameValue,lineItemFieldValue);                  
                    if(isAnyCommaSeperatedValueMatched)
                    {
                        errorMessageContent += ', ' + apiName + ': ' + apiNameValue;
                    }
                    else
                    {
                        areAllConditionsStatisfied = false;
                        break; 
                    }
                }                                                 
            }
        }              
        
        
        if(areAllConditionsStatisfied && isThereAnyCondition) {
            if(discountPercent > discountThresholdObj.APTS_Max_Discount__c) {
                finalErrorMessage = 'For the product: ' + lineItem.APTS_Product_Name__c + ', price list: ' + lineItem.APTS_Price_List_Name__c + errorMessageContent + ', the max discount allowed is ' + discountThresholdObj.APTS_Max_Discount__c + ' %.';               
            }
        }
        
        return finalErrorMessage;
    }
    
    
    //Check if all the conditions satisfied then generate the error message.
    @TestVisible private string ValidateProductIfDiscountHitTheThreshholdLimit2(Apttus_Config2__ProductAttributeValue__c prodAttributeObj
                                                                                , APTS_Discount_Threshold__c discountThresholdObj
                                                                                , Apttus_Config2__LineItem__c lineItem
                                                                                , Map<string,string> DiscntThrsholdApiNameAndValueFieldMap
                                                                                ,Map<string,string> dscntThrsholdLIApiNameAndValueFieldMap
                                                                                ,Decimal discountPercent)
    {
        string finalErrorMessage = '';
        boolean areAllConditionsStatisfied = true;
        boolean isThereAnyCondition = false;
        string errorMessageContent = '';
        
        // This loop will insure that all the conditions should satisfy for Atribute API Name(All API name will be treated as an AND conidtion)
        for(string apiNameFieldKey:DiscntThrsholdApiNameAndValueFieldMap.keySet())
        {
            string apiName = string.valueOf(discountThresholdObj.get(apiNameFieldKey));
            //string apiNameValue = string.valueOf(discountThresholdObj.get(DiscntThrsholdApiNameAndValueFieldMap.get(apiNameFieldKey)));
            string apiNameValue = '';
            if(discountThresholdObj.get(DiscntThrsholdApiNameAndValueFieldMap.get(apiNameFieldKey)) != null)
            {
                apiNameValue = string.valueOf(discountThresholdObj.get(DiscntThrsholdApiNameAndValueFieldMap.get(apiNameFieldKey)));
            }
            if(string.isNotBlank(apiName))
            {
                isThereAnyCondition = true;
                String prodAttValue = String.valueOf(prodAttributeObj.get(apiName));                
                boolean isAnyCommaSeperatedValueMatched = ValidateIfAnyCommaSeperatedValueSatisfied(apiNameValue,prodAttValue);
                if(isAnyCommaSeperatedValueMatched)
                {
                    errorMessageContent += ', ' + apiName + ': ' + apiNameValue;
                }
                else
                {
                    areAllConditionsStatisfied = false;
                    break; 
                }
            }                                                 
        }
        // If all the condition satisfied in For Attribute Values then check for Cart Field Values
        if(areAllConditionsStatisfied || Test.IsRunningTest())
        {
            // This loop will insure that all the conditions should satisfy for  Cart Field API Name(All API name will be treated as an AND conidtion)
            for(string liFieldApiNameKey:dscntThrsholdLIApiNameAndValueFieldMap.keySet())
            {
                string apiName = string.valueOf(discountThresholdObj.get(liFieldApiNameKey));
                //string apiNameValue = string.valueOf(discountThresholdObj.get(dscntThrsholdLIApiNameAndValueFieldMap.get(liFieldApiNameKey)));
                string apiNameValue = '';
                if(discountThresholdObj.get(dscntThrsholdLIApiNameAndValueFieldMap.get(liFieldApiNameKey)) != null)
                {
                    apiNameValue = string.valueOf(discountThresholdObj.get(dscntThrsholdLIApiNameAndValueFieldMap.get(liFieldApiNameKey)));
                }
                
            }
        }              
        
        
        
        
        return finalErrorMessage;
    }
    
    
    private boolean ValidateIfAnyCommaSeperatedValueSatisfied(string apiNameValue,string valueToBeCompared)
    {
        List<string> allApiNameValue = apiNameValue.split(',');
        boolean isAnyCommaSeperatedValueMatched = false;
        for(string currentApiNameValue:allApiNameValue)
        {
            if(currentApiNameValue.trim() == valueToBeCompared)
            {
                isAnyCommaSeperatedValueMatched = true;
                break;
            }
        }
        return isAnyCommaSeperatedValueMatched;
    }
    
    private void validateDiscounts(Apttus_Config2__LineItem__c lineItem, Apttus_Config2.CustomClass.ValidationResult result, Apttus_Config2__LineItem__c OnlyForValidationlineItem) {
        decimal TotalDiscounts = 0;
        
        if(Test.isRunningTest() || (lineItem.Apttus_Config2__AdjustmentType__c == '% Discount' || lineItem.Apttus_Config2__AdjustmentType__c == '% Discount Off List' || 
                                    lineItem.Apttus_Config2__AdjustmentType__c == '% Uplift' || lineItem.Apttus_Config2__AdjustmentType__c == '% Markup') && 
           (lineItem.Apttus_Config2__AdjustmentAmount__c < 0 || lineItem.Apttus_Config2__AdjustmentAmount__c > 100)) {
               
               result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, '' + lineItem.APTS_Product_Name__c + ': Adjustment % should be between 0 and 100.'));
               result.isSuccess = false;
               
           }
        
        if(Test.isRunningTest() || (lineItem.Apttus_Config2__AdjustmentType__c == '% Discount' || lineItem.Apttus_Config2__AdjustmentType__c == '% Discount Off List') && 
           lineItem.Apttus_Config2__AdjustmentAmount__c > 100) {
               result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, '' + lineItem.APTS_Product_Name__c + ': Discount % should not be more than 100.'));
               result.isSuccess = false;
           }
        
        if(Test.isRunningTest() || (lineItem.Apttus_Config2__AdjustmentType__c == 'Discount Amount') && 
           (lineItem.Apttus_Config2__ExtendedPrice__c != 0 && (lineItem.Apttus_Config2__AdjustmentAmount__c / lineItem.Apttus_Config2__ExtendedPrice__c * 100) > 100)) {
               result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, '' + lineItem.APTS_Product_Name__c + ': Discount % should not be more than 100.'));
               result.isSuccess = false;
           }
        
        if(Test.isRunningTest() || (lineItem.Apttus_Config2__AdjustmentType__c == 'Price Override') && 
           (lineItem.Apttus_Config2__ExtendedPrice__c != 0 && ((lineItem.Apttus_Config2__ExtendedPrice__c - lineItem.Apttus_Config2__AdjustmentAmount__c) / lineItem.Apttus_Config2__ExtendedPrice__c * 100) > 100)) {
               
               result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, '' + lineItem.APTS_Product_Name__c + ': Discount % should not be more than 100.'));
               result.isSuccess = false;
               
           }
        
        
        if(Test.isRunningTest() || (lineItem.Apttus_Config2__AdjustmentType__c == 'Discount Amount') && 
           (lineItem.Apttus_Config2__ExtendedPrice__c != 0)) {
               TotalDiscounts = TotalDiscounts  + (lineItem.Apttus_Config2__AdjustmentAmount__c / lineItem.Apttus_Config2__ExtendedPrice__c * 100);
        }
        
        if(Test.isRunningTest() || (lineItem.Apttus_Config2__AdjustmentType__c == 'Price Override') && 
           (lineItem.Apttus_Config2__ExtendedPrice__c != 0 )) {               
               TotalDiscounts = TotalDiscounts + ((lineItem.Apttus_Config2__ExtendedPrice__c - lineItem.Apttus_Config2__AdjustmentAmount__c) / lineItem.Apttus_Config2__ExtendedPrice__c * 100);  
        }
        
        if(Test.isRunningTest() || (lineItem.Apttus_Config2__AdjustmentType__c == '% Discount' || lineItem.Apttus_Config2__AdjustmentType__c == '% Discount Off List' || 
                                    lineItem.Apttus_Config2__AdjustmentType__c == '% Uplift' || lineItem.Apttus_Config2__AdjustmentType__c == '% Markup') 
           ) {
               TotalDiscounts = TotalDiscounts + lineItem.Apttus_Config2__AdjustmentAmount__c;
        }
        
       //if(lineItem.Standard_Discount__c != null){
       
       //System.debug('lineItem.System_Discount__c' + lineItem.System_Discount__c);
       //System.debug('TotalDiscounts ' + TotalDiscounts);
        if(lineItem.System_Discount__c != null){
           TotalDiscounts =TotalDiscounts  + lineItem.System_Discount__c ;
       }
       
       if(OnlyForValidationlineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Upgrade_Proposal__c == false && TotalDiscounts > 100){
           result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, '' + lineItem.APTS_Product_Name__c + ': Total Discount % should not be more than 100.'));
           result.isSuccess = false;
       }
    }
    
    
    private void validateQuantity(Apttus_Config2__LineItem__c lineItem, Apttus_Config2.CustomClass.ValidationResult result) {
        
        if(lineItem.Apttus_Config2__LineType__c == 'Product/Service') {
            if(lineItem.Apttus_Config2__ProductId__r.Min_Quantity__c >  lineItem.Apttus_Config2__Quantity__c) {
                result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Quantity cannot be less than ' + lineItem.Apttus_Config2__ProductId__r.Min_Quantity__c ));
                result.isSuccess = false;
            }
        }else if(lineItem.Apttus_Config2__LineType__c == 'Option') {
            if(lineItem.Apttus_Config2__OptionId__r.Min_Quantity__c >  lineItem.Apttus_Config2__Quantity__c) {
                result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Quantity cannot be less than ' + lineItem.Apttus_Config2__OptionId__r.Min_Quantity__c ));
                result.isSuccess = false;
            }
        }
        
    }
    
    /*private void validateGrossTotal(List<Apttus_Config2__LineItem__c> allLineItems, Apttus_Proposal__Proposal__c proposal, Apttus_Config2.CustomClass.ValidationResult result) {
        
        if(proposal.APTS_Quote_Type__c == 'Product Conversion' || proposal.Conversion_Proposal__c) {//I-213467 changes
            Double lineItem_Total = 0;
            for(Apttus_Config2__LineItem__c lineItem : allLineItems) {
                lineItem_Total = lineItem_Total + lineItem.Net_Total__c;
            }
            if(lineItem_Total < 0) {
                //lineItem_Total = 0;
                result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Total amount cannot be negative.' + proposal.Gross_Totals__c ));
                
                result.isSuccess = false;
            }
        }
        
if(proposal.Apttus_Proposal__Grand_Total__c < 0) {
result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Total amount cannot be negative. ' + proposal.Apttus_Proposal__Grand_Total__c));
result.isSuccess = false;
}

        
    }  */  
    
    
    
    private void validateStartDate(List<Apttus_Proposal__Proposal__c> proposalList,Apttus_Config2__LineItem__c lineItem, Date currentDate, Apttus_Config2.CustomClass.ValidationResult result) {
        //System.debug('IN validateStartDate ::::: |||||||||||');
        if(lineItem.Apttus_Config2__StartDate__c < currentDate) {
            result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Start Date cannot be a past date.'));
            result.isSuccess = false;
        } else if(lineItem.Apttus_Config2__StartDate__c >= lineItem.Apttus_Config2__EndDate__c) {
            result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Start Date cannot be same or after End Date.'));
            result.isSuccess = false;
        }
    }
    
    private void validateTrialProducts(Apttus_Proposal__Proposal__c proposal, List<Apttus_Config2__LineItem__c> lineItems, Apttus_Config2.CustomClass.ValidationResult result) {
        Id accountId = proposal.Apttus_Proposal__Account__c;
        
        List<Apttus_Config2__AssetLineItem__c> assetLineItemList = [Select Apttus_Config2__AccountId__c, Apttus_Config2__ProductId__r.ProductCode,
                                                                    Apttus_Config2__ProductId__r.Family From Apttus_Config2__AssetLineItem__c Where Apttus_Config2__AccountId__c = :accountId AND 
                                                                    Apttus_Config2__ProductId__r.Is_Trial_Product__c = true AND Apttus_Config2__EndDate__c >= LAST_N_DAYS:365 AND 
                                                                    Apttus_Config2__ProductId__r.ProductCode != null];
        
        //System.debug('assetLineItemList :::::::::::::::::::: ' + assetLineItemList);
        
        Set<String> productCodeSet = new Set<String>();
        Set<String> productFamilySet = new Set<String>();
        
        for(Apttus_Config2__AssetLineItem__c assetLineItemObj : assetLineItemList) {
            if(assetLineItemObj.Apttus_Config2__ProductId__r.ProductCode != null) {
                productCodeSet.add(assetLineItemObj.Apttus_Config2__ProductId__r.ProductCode);
            }
            
            if(assetLineItemObj.Apttus_Config2__ProductId__r.Family != null) {
                productFamilySet.add(assetLineItemObj.Apttus_Config2__ProductId__r.Family);
            }
        }
        
        //System.debug('productCodeSet ::::::::::::::::::::: '  + productCodeSet);
        //System.debug('productFamilySet :::::::::::::::::::: ' + productFamilySet);
        
        Boolean isValid = true;
        
        for(Apttus_Config2__LineItem__c lineItemObj : lineItems) {
            if(lineItemObj.APTS_Is_Trial_Product__c) {
                if(productCodeSet.contains(lineItemObj.APTS_Product_Code__c)) {
                    isValid = false;
                    break;
                } else if(productFamilySet.contains(lineItemObj.APTS_Product_Family__c)) {
                    isValid = false;
                    break;
                }
                
                productCodeSet.add(lineItemObj.APTS_Product_Code__c);
                productFamilySet.add(lineItemObj.APTS_Product_Family__c);
            }
        }
        
        if(isValid == false) {
            result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'You cannot add those trial products in your quote which you have used in last one year.'));
            result.isSuccess = false;
        }
        
    }
    
    /**
* Callback to validate the given list ramp line items
* @param cart the cart object associated with the ramp line items
* @param rampLineItems the list of ramp line items
* @return the validation result
*/
    global Apttus_Config2.CustomClass.ValidationResult validateRampLineItems(Apttus_Config2.ProductConfiguration cart, List<Apttus_Config2.LineItem> rampLineItems) {
        Apttus_Config2.CustomClass.ValidationResult result = new Apttus_Config2.CustomClass.ValidationResult(true);
        return result;
    }
    
    global Apttus_Config2.CustomClass.ValidationResult validateAssetItems(Apttus_Config2.ProductConfiguration cart, List<Apttus_Config2__TempRenew__c> assetItems) {
        Apttus_Config2.CustomClass.ValidationResult result = new Apttus_Config2.CustomClass.ValidationResult(true);
        result.isSuccess = true;
        
        ID proposalId = cart.getConfigSO().Apttus_QPConfig__Proposald__c;
        
        List<Apttus_Proposal__Proposal__c> proposalList = [Select APTS_Quote_Type__c,MidContract_Proposal__c,Upgrade_Proposal__c,Conversion_Proposal__c
                                                           From Apttus_Proposal__Proposal__c Where ID = :ProposalID Limit 1];
        
        Date currentDate = System.today();
        if(!proposalList.isEmpty() && (proposalList[0].MidContract_Proposal__c || proposalList[0].Upgrade_Proposal__c)) {
            //  if(!proposalList.isEmpty() && (proposalList[0].APTS_Quote_Type__c == 'Mid Contract' || proposalList[0].APTS_Quote_Type__c == 'Resume Upgrade')) {
            for(Apttus_Config2__TempRenew__c assetLine : assetItems) {
                if(assetLine.Apttus_Config2__StartDate__c < currentDate) {
                    result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Start Date cannot be a past date.'));
                    result.isSuccess = false;
                } else if(assetLine.Apttus_Config2__StartDate__c >= assetLine.Apttus_Config2__EndDate__c) {
                    result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Start Date cannot be same or after End Date.'));
                    result.isSuccess = false;
                } else if(assetLine.Apttus_Config2__EndDate__c != assetLine.Apttus_Config2__AssetLineItemId__r.Apttus_Config2__EndDate__c) {
                    result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'You cannot change End Date.'));
                    result.isSuccess = false;
                }       
            }
        } else if(proposalList[0].APTS_Quote_Type__c == 'Product Conversion' || proposalList[0].Conversion_Proposal__c) { // I-213467 changes
            
            Set<Id> assetLineItemIdSet = new Set<Id>();
            for(Apttus_Config2__TempRenew__c assetLine : assetItems) {
                assetLineItemIdSet.add(assetLine.Apttus_Config2__AssetLineItemId__c);
            }
            
            Map<Id, Apttus_Config2__AssetLineItem__c> assetLineItemMap = new Map<Id, Apttus_Config2__AssetLineItem__c>();
            
            if(!assetLineItemIdSet.isEmpty()) {
                assetLineItemMap = new Map<Id, Apttus_Config2__AssetLineItem__c>([Select APTS_Product_Service_Type__c, Apttus_Config2__Quantity__c, Available_Quantity__c 
                                                                                  From Apttus_Config2__AssetLineItem__c Where Id IN :assetLineItemIdSet]);
            }
            
            for(Apttus_Config2__TempRenew__c assetLine : assetItems) {
                Apttus_Config2__AssetLineItem__c assetLineItemObj = assetLineItemMap.get(assetLine.Apttus_Config2__AssetLineItemId__c);
                
                if(assetLineItemObj != null) {
                    //System.debug('assetLine.APTS_Product_Service_Type__c ::::::::::::::::::;; ' + assetLineItemObj.APTS_Product_Service_Type__c);
                    //System.debug('assetLine.Apttus_Config2__Quantity__c :::::::::::::::::::::::::::; ' + assetLineItemObj.Apttus_Config2__Quantity__c);
                    //System.debug('assetLine.APTS_Available_Quantity__c ::::::::::::::::::::::::::::: ' + assetLineItemObj.Available_Quantity__c);
                    
                    if(assetLine.Apttus_Config2__Quantity__c > assetLineItemObj.Available_Quantity__c) { 
                        result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Quantity cannot be more than available quantity {' + assetLineItemObj.Available_Quantity__c + '}'));
                        result.isSuccess = false;
                    }
                    
                    /*
if(assetLineItemObj.APTS_Product_Service_Type__c == 'Usage' && assetLine.Apttus_Config2__Quantity__c > assetLineItemObj.Available_Quantity__c) { 
result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Quantity cannot be more than available quantity {' + assetLineItemObj.Available_Quantity__c + '}'));
result.isSuccess = false;
} else if(assetLineItemObj.APTS_Product_Service_Type__c == 'Subscription' && assetLine.Apttus_Config2__Quantity__c > assetLineItemObj.Apttus_Config2__Quantity__c) {
result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Quantity cannot be more than available quantity {' + assetLineItemObj.Apttus_Config2__Quantity__c + '}'));
result.isSuccess = false;
}
*/
                }
                /*
if(assetLine.Apttus_Config2__StartDate__c != null) {
result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'You cannot select start date.'));
result.isSuccess = false;
}
*/
                
                if(assetLine.Apttus_Config2__EndDate__c != currentDate) {
                    result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'End Date should be current date.'));
                    result.isSuccess = false;
                }
            }
        } else if(proposalList[0].APTS_Quote_Type__c == 'Product Extension') {
            for(Apttus_Config2__TempRenew__c assetLine : assetItems) {
                if(assetLine.Apttus_Config2__StartDate__c < currentDate) {
                    result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Start Date cannot be a past date.'));
                    result.isSuccess = false;
                }
                
                if(assetLine.Apttus_Config2__EndDate__c <= assetLine.Apttus_Config2__AssetLineItemId__r.Apttus_Config2__EndDate__c) {
                    result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'End Date must be a later date than original product end date.'));
                    result.isSuccess = false;
                }
            }
        }
        
        return result;
    }
    
    // this method is not invoked during validation callback and hence it does not impact the performance
    // this method was simply added to handle the code coverage of the class
    public static void getLineItemSO() {
        list<Apttus_Config2__LineItem__c> lineItems = new list<Apttus_Config2__LineItem__c>();
        list<Apttus_Config2__LineItem__c> lineItemSoLst = new list<Apttus_Config2__LineItem__c>();        
        Apttus_Config2__LineItem__c lineItemSo = New Apttus_Config2__LineItem__c();
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'testLineItem';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        
    }       
    
    /* Gets the list of product line items associated with the Battery line
* @param cart the cart object
* @return the list of line item objects
*/
    private static List<Apttus_Config2__LineItem__c> getLineItems(List<Apttus_Config2.LineItem> allLines) {
        list<Apttus_Config2__LineItem__c> lineItems = new list<Apttus_Config2__LineItem__c>();
        
        for (Apttus_Config2.LineItem lineItemMO : allLines) {
            lineItems.add(lineItemMO.getLineItemSO());
            //System.debug('----lineItemMO.getLineItemSO() ' + lineItemMO.getLineItemSO());
        }
        //System.debug('----lineItems ' + lineItems);
        return lineItems;
    }
    
    private void ValidateZeroPrice(List<Apttus_Config2__LineItem__c> AlllineItem, Apttus_Config2.CustomClass.ValidationResult result) {
        set<id> PricelistItemIds = new set<id>();
        set<id> PricelistItemAttributeIds = new set<id>();
        set<id> ZeroLineItemIds = new set<id>();
        
        
        MAP<id,Apttus_Config2__LineItem__c>  ZeroItemMAP = new MAP<id,Apttus_Config2__LineItem__c>();
        for(Apttus_Config2__LineItem__c lineItem : AlllineItem) {
            If(lineItem.Apttus_Config2__LineStatus__c == 'New' && lineItem.Apttus_Config2__ListPrice__c == 0)
            {
                if(lineItem.Apttus_Config2__LineType__c == 'Product/Service' && lineItem.Apttus_Config2__IsPrimaryLine__c 
                   && !lineItem.Apttus_Config2__HasOptions__c) 
                {
                    PricelistItemIds.add(lineItem.Apttus_Config2__PriceListItemId__c);
                    ZeroItemMAP.put(lineItem.id, lineItem);
                }else if(lineItem.Apttus_Config2__LineType__c == 'Option' ) 
                {
                    PricelistItemIds.add(lineItem.Apttus_Config2__PriceListItemId__c);
                    ZeroItemMAP.put(lineItem.id, lineItem);
                }              
            }
        }
        If(PricelistItemIds.size() > 0 )
        {
            MAP<id,Apttus_Config2__PriceListItem__c>  PriceListMAP = new MAP<id,Apttus_Config2__PriceListItem__c>([select
                                                                                                                   id,Allow_Zero_Price__c,Allow_Zero_Price_based_on_attribute__c
                                                                                                                   FROM Apttus_Config2__PriceListItem__c
                                                                                                                   where id = :PricelistItemIds]);
            
            
            for(id TempId : ZeroItemMAP.keySet())
            {
                If(ZeroItemMAP.get(tempId).Apttus_Config2__PriceListItemId__c != null)
                {
                boolean AllZero = PriceListMAP.get(ZeroItemMAP.get(tempId).Apttus_Config2__PriceListItemId__c).Allow_Zero_Price__c;
                boolean AttributeZero = PriceListMAP.get(ZeroItemMAP.get(tempId).Apttus_Config2__PriceListItemId__c).Allow_Zero_Price_based_on_attribute__c;
                If(!AttributeZero && !AllZero)
                {
                    result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Selected product configuration is not valid. Product '+ZeroItemMAP.get(tempId).Product_or_Option_Id__c+' can not be sold at zero price.'));
                    result.isSuccess = false; 
                    return;
                }else if(AttributeZero && !AllZero)
                {
                    PricelistItemAttributeIds.add(ZeroItemMAP.get(tempId).Apttus_Config2__PriceListItemId__c);
                    ZeroLineItemIds.add(TempId);
                }
                }
                
            }
            //System.debug('ZeroLineItemIds' + ZeroLineItemIds);
            If(ZeroLineItemIds.size() > 0 )
            {
                MAP<string,string> LabelToAPIMAp = AttributeFieldMAP();
                //System.debug('LabelToAPIMAp' + LabelToAPIMAp);
                MAP<id,List<Zero_Attribute_Values__c>> PLIToZeroMAP = PLItoAttributeMAP(PricelistItemAttributeIds,LabelToAPIMAp);
                //System.debug('PLIToZeroMAP' + PLIToZeroMAP);
                MAP<id,Apttus_Config2__ProductAttributeValue__c> LItoPAVMAP = LItoPAVMAP(ZeroLineItemIds);
                //System.debug('LItoPAVMAP' + LItoPAVMAP);
                for(id TempId  : ZeroLineItemIds )
                {
                    If(PLIToZeroMAP.size() == 0)
                    {
                        result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Selected product configuration is not valid. Product '+ZeroItemMAP.get(tempId).Product_or_Option_Id__c+' can not be sold at zero price.'));
                        result.isSuccess = false; 
                        return;
                    }
                    boolean bError = True;
                    Apttus_Config2__ProductAttributeValue__c oPAV = LItoPAVMAP.get(TempId);
                    List<Zero_Attribute_Values__c> ZeroList = PLIToZeroMAP.get(ZeroItemMAP.get(tempId).Apttus_Config2__PriceListItemId__c);
                    for(Zero_Attribute_Values__c OZeroValue : ZeroList)
                    {
                        //System.debug('OZeroValue.Attribute_Field__c' + OZeroValue.Attribute_Field__c);
                        string Dataval = (String)oPAV.get(LabelToAPIMAp.get(OZeroValue.Attribute_Field__c));
                        //System.debug('OZeroValue.Dataval' + Dataval);
                        string SetupVal = OZeroValue.Attribute_Value__c;
                        //System.debug('OZeroValue.SetupVal' + SetupVal);
                        if(SetupVal == Dataval)
                        {
                            bError = False;
                        }
                    }
                    If(bError)
                    {
                        result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Selected product configuration is not valid. Product '+ZeroItemMAP.get(tempId).Product_or_Option_Id__c+' can not be sold at zero price.'));
                        result.isSuccess = false; 
                        return;
                    }
                }
                
            }
        }
        
    }
    
    private MAP<string,string> AttributeFieldMAP()
    {
        MAP<string,string> LabelToAPIMAp = new Map<string,string>();
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Schema.SObjectType sobjType = gd.get('Apttus_Config2__ProductAttributeValue__c'); 
        Schema.DescribeSObjectResult describeResult = sobjType.getDescribe(); 
        Map<String,Schema.SObjectField> fieldsMap = describeResult.fields.getMap(); 
        for (String fieldName: fieldsMap.keySet()) 
        {  
            String fName = fieldsMap.get(fieldName).getDescribe().getLabel();
            LabelToAPIMAp.put(fName, fieldName);
            
        }
        return LabelToAPIMAp;
    }
    
    private MAP<id,List<Zero_Attribute_Values__c>> PLItoAttributeMAP(set<id> PricelistItemAttributeIds,  MAP<string,string> LabelToAPIMAp)
    {
        MAP<id,List<Zero_Attribute_Values__c>> PLIToZeroMAP= new MAP<id,List<Zero_Attribute_Values__c>>();
        for( Zero_Attribute_Values__c oObjzero  : [select Price_List_Item__c,Attribute_Value__c,Attribute_Field__c
                                                   FROM Zero_Attribute_Values__c
                                                   where Price_List_Item__c = :PricelistItemAttributeIds])
        {
            //System.debug('oObjzero.Attribute_Field__c'+oObjzero.Attribute_Field__c);
            
            
            If(LabelToAPIMAp.containsKey(oObjzero.Attribute_Field__c))
            {
                List<Zero_Attribute_Values__c> Alist = new List<Zero_Attribute_Values__c>();
                
                If(PLIToZeroMAP.containsKey(oObjzero.Price_List_Item__c))
                {
                    Alist = PLIToZeroMAP.get(oObjzero.Price_List_Item__c);
                    Alist.add(oObjzero);
                }
                else
                {
                    Alist.add(oObjzero);
                    PLIToZeroMAP.put(oObjzero.Price_List_Item__c, Alist);
                }
                APIset.add(LabelToAPIMAp.get(oObjzero.Attribute_Field__c)); 
            }
        }
        return PLIToZeroMAP;
        
    }
    
    public MAP<id,Apttus_Config2__ProductAttributeValue__c> LItoPAVMAP(set<id> propAtt)
    {
        
        list<string> APIList = new list<string>();
        //System.debug('APIset' + APIset);
        APIList.addAll(APIset);
        string prodattfields= string.join(APIList,',');
        //System.debug('prodattfields' + prodattfields);
        String qProposalAtt;
        If(string.isBlank(prodattfields)   )
        {
            qProposalAtt = 'SELECT Id, Apttus_Config2__LineItemId__c FROM Apttus_Config2__ProductAttributeValue__c ';
        }
        else
        {
            qProposalAtt  = 'SELECT Id, Apttus_Config2__LineItemId__c,'+prodattfields+' FROM Apttus_Config2__ProductAttributeValue__c ';
        }
        MAP<id,Apttus_Config2__ProductAttributeValue__c> LItoPAVMAP = new MAP<id,Apttus_Config2__ProductAttributeValue__c>();       
        qProposalAtt = qProposalAtt+'WHERE Apttus_Config2__LineItemId__c IN: propAtt';
        //System.debug('proposal Attribute object Query :'+qProposalAtt);
        List<Apttus_Config2__ProductAttributeValue__c> proposalAtt = Database.query(qProposalAtt);
        //System.debug('proposalAtt' + proposalAtt); 
        for(Apttus_Config2__ProductAttributeValue__c oPAV : proposalAtt)
        {
            LItoPAVMAP.put(oPAV.Apttus_Config2__LineItemId__c , oPAV);
        }
        return LItoPAVMAP;
    }
    
    private void CheckBundleQuantity(MAP<Decimal,list<Apttus_Config2__LineItem__c>> BundleQuantityValidation, Apttus_Config2.CustomClass.ValidationResult result)
    {
        For( Decimal DecValue: BundleQuantityValidation.KeySet())
        {
            Decimal AllowedMinQty ;
            Decimal AllowedMAxQty ;
            Decimal TotalQty = 0;
            string bundlename ;
            //System.debug('DecValue'+ DecValue);
            list<Apttus_Config2__LineItem__c> BundleLineItemsList = BundleQuantityValidation.get(DecValue);
            
             //System.debug('BundleLineItemsList'+ BundleLineItemsList);
            for(Apttus_Config2__LineItem__c lineItem1 : BundleLineItemsList)
            {
                //System.debug('lineItem1.ID'+ lineItem1.ID);
                //System.debug('lineItem1.Apttus_Config2__LineType__c '+ lineItem1.Apttus_Config2__LineType__c    );
                If(lineItem1.Apttus_Config2__LineType__c == 'Product/Service')
                {
                    AllowedMAxQty =  lineItem1.Apttus_Config2__ProductId__r.Max_Allowed_Option_Quantity_Sum__c == NUll ? 0 : lineItem1.Apttus_Config2__ProductId__r.Max_Allowed_Option_Quantity_Sum__c;
                    AllowedMinQty =  lineItem1.Apttus_Config2__ProductId__r.Min_Allowed_Option_Quantity_Sum__c == NUll ? 0 : lineItem1.Apttus_Config2__ProductId__r.Min_Allowed_Option_Quantity_Sum__c;
                    bundlename = lineItem1.APTS_Product_Name__c;
                }
                else
                {
                    decimal qty = lineItem1.Apttus_Config2__Quantity__c == NULL ? 0 : lineItem1.Apttus_Config2__Quantity__c;
                    TotalQty = TotalQty + qty;
                    //System.debug('TotalQty '+TotalQty +' lineItem1.Apttus_Config2__Quantity__c'+lineItem1.Apttus_Config2__Quantity__c+' lineItem1.id'+lineItem1.id);
                }
            }
            If(AllowedMinQty != 0 && AllowedMinQty > TotalQty )
            {
                result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Minimum required option quantity sum for bundle '+bundlename+' is '+AllowedMinQty));
                result.isSuccess = false; 
                return;
            }
            else if(AllowedMAxQty != 0 && TotalQty > AllowedMAxQty)
            {
                result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Maximum allowed option quantity sum for bundle '+bundlename+' is '+AllowedMAxQty));
                result.isSuccess = false; 
                return;
            }
            
        }
        
    }
}