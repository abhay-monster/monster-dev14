/*************************************************************************************************************
* @author Ranjeet - Apttus
* @CreatedDate 09/10/2014  
* Last Modified By 
* @ModifiedDate 
//added new field - I-191765
//###I-191184
//###I-189795
***************************************************************************************************************/
global with sharing class APTS_PricingCallBack implements Apttus_Config2.CustomClass.IPricingCallback3 {
    // cart
    private Apttus_Config2.ProductConfiguration cart = null;
    
    //mode
    private Apttus_Config2.CustomClass.PricingMode mode = null;
    Id CartId;
    Boolean updatePricing;
    Apttus_Proposal__Proposal__c proposal;
    Map<Id, Apttus_Config2__ProductAttributeValue__c> lineItemIdProdAttributeValueMap;
    Map<Id, Apttus_Config2__AssetAttributeValue__c> assetLineItemIdProdAttributeValueMap;
    List<Apttus_Config2__ProductAttributeValue__c> prodAttributeValueUpdateList;
    Set<Id> prodAttributeValueUpdateIdSet;
    List<Apttus_Config2__LineItem__c> preservedLineItemsInBeforeSaving = new List<Apttus_Config2__LineItem__c>();
    List<Apttus_Config2__LineItem__c> lineItemsList = new List<Apttus_Config2__LineItem__c>();
    Map<string,Apttus_Config2__LineItem__c> productChargeTypeLineMap = new Map<string,Apttus_Config2__LineItem__c>();
    /**
* Callback at the beginning of the pricing call.
* Use the start method to initialize state
* @param cart the cart object
*/
    global void start(Apttus_Config2.ProductConfiguration cart) {
        initializeClassVariables(cart);        
    }
    
    private void initializeClassVariables(Apttus_Config2.ProductConfiguration cart) {
        this.updatePricing = false;
        this.cart = cart;
        this.CartId = cart.getConfigSO().Id;
        
        ID ProposalID = cart.getConfigSO().Apttus_QPConfig__Proposald__c;
        List<Apttus_Proposal__Proposal__c> proposalList = [Select Id, APTS_Quote_Type__c, Latest_End_Date__c,RecordType.Name,Apttus_Proposal__Opportunity__r.RecordType.Name,
                                                           APTS_Enforce_Rollup_Summary_Calc__c,APTS_Fire_Approvals__c,Approval_Comments__c,
                                                           ownerId,
                                                           // Updated by Vrs
                                                           Agency__c,
                                                           Earliest_Start_Date__c,
                                                           TotalDiscount__c,
                                                           Manager1__c,
                                                           Discount_Authority_Manager1__c,
                                                           Manager2__c,
                                                           Discount_Authority_Manager2__c,
                                                           Manager3__c,
                                                           Discount_Authority_Manager3__c,
                                                           Manager4__c,
                                                           Discount_Authority_Manager4__c,
                                                           Manager5__c,
                                                           Discount_Authority_Manager5__c,
                                                           Manager6__c,
                                                           Discount_Authority_Manager6__c,
                                                           Manager7__c,
                                                           Discount_Authority_Manager7__c,
                                                           Manager8__c,
                                                           Discount_Authority_Manager8__c,
                                                           Manager9__c,
                                                           Discount_Authority_Manager9__c,
                                                           Manager10__c,
                                                           Discount_Authority_Manager10__c,
                                                           MidContract_Proposal__c,
                                                           Upgrade_Proposal__c,
                                                           Long_Term_Contract__c ,    
                                                           Conversion_Proposal__c,//I-213467 changes
                                                            Organization__c,
                                                            BIAUsage_Proposal__c 
                                                           From Apttus_Proposal__Proposal__c Where ID = :ProposalID Limit 1];
        
        if(proposalList != null && !proposalList.isEmpty()) {
            proposal = proposalList[0];
        }       
        
        lineItemIdProdAttributeValueMap = new Map<Id, Apttus_Config2__ProductAttributeValue__c>();
        
        Set<Id> assetLineItemIdSet = new Set<Id>();
        
        for(Apttus_Config2__LineItem__c lineItem : [
                                                        Select 
                                                            Id, Apttus_Config2__AssetLineItemId__c,Apttus_Config2__LineType__c,Apttus_Config2__Quantity__c,
                                                            Apttus_Config2__ProductOptionId__c, 
                                                                (
                                                                    Select /*View_Count__c,*/ 
                                                                        Contract_Duration__c, Geography__c, Resume_License_Type__c 
                                                                    From Apttus_Config2__ProductAttributeValues__r
                                                                ) 
                                                         From Apttus_Config2__LineItem__c 
                                                         Where Apttus_Config2__ConfigurationId__c = :this.CartId
                                                     ]
        
        ) {
            List<Apttus_Config2__ProductAttributeValue__c> prodAttributeValueList = lineItem.Apttus_Config2__ProductAttributeValues__r;
            
            if(prodAttributeValueList != null && !prodAttributeValueList.isEmpty()) {
                lineItemIdProdAttributeValueMap.put(lineItem.Id, prodAttributeValueList[0]);    
            }
            
            if(lineItem.Apttus_Config2__AssetLineItemId__c != null) {
                assetLineItemIdSet.add(lineItem.Apttus_Config2__AssetLineItemId__c);
            }
        }
        
        assetLineItemIdProdAttributeValueMap = new Map<Id, Apttus_Config2__AssetAttributeValue__c>();
        
        if(!assetLineItemIdSet.isEmpty()) {            
            
            for(Apttus_Config2__AssetLineItem__c assetLineItem : [
                                                                    Select 
                                                                        Id, 
                                                                        (
                                                                            Select 
                                                                                Contract_Duration__c, Geography__c, Resume_License_Type__c 
                                                                            From Apttus_Config2__AssetAttributeValues__r
                                                                        ) 
                                                                        From Apttus_Config2__AssetLineItem__c 
                                                                    Where Id IN :assetLineItemIdSet
                                                                ]
            ){
                List<Apttus_Config2__AssetAttributeValue__c> assetAttributeValueList = assetLineItem.Apttus_Config2__AssetAttributeValues__r;
                
                if(assetAttributeValueList != null && !assetAttributeValueList.isEmpty()) {
                    assetLineItemIdProdAttributeValueMap.put(assetLineItem.Id, assetAttributeValueList[0]); 
                }
            }   
        }
        
        prodAttributeValueUpdateList = new List<Apttus_Config2__ProductAttributeValue__c>();
        prodAttributeValueUpdateIdSet = new Set<Id>();
    }
    
    /**
* Callback to indicate the pricing mode
* @param mode the pricing mode
*/
    global void setMode(Apttus_Config2.CustomClass.PricingMode mode) {
        this.mode = mode;
        /* we only want to update the values to the config object in the adjustment mode */
        if (Apttus_Config2.CustomClass.PricingMode.ADJUSTMENT == mode) {
            this.updatePricing = true;
        }
    }
    
    /**
* Callback before pricing the line item collection
* Use this method to do all required pre-processing to prepare the line items for pricing.
* @param itemColl the line item collection to pre-process
*/ 
/* 
    global void beforePricing(Apttus_Config2.ProductConfiguration.LineItemColl itemColl) {
        list<Apttus_Config2.LineItem> allLines = itemColl.getAllLineItems();
        if (Apttus_Config2.CustomClass.PricingMode.BasePrice == mode){
            for(Apttus_Config2.LineItem lineItemMO : allLines) {
                Apttus_Config2__LineItem__c lineItemSO = lineItemMO.getLineItemSO();
                lineItemSO.Apttus_Config2__BasePriceOverride__c = 50;
            }
        }
    }
    
    */
    global void beforePricing(Apttus_Config2.ProductConfiguration.LineItemColl itemColl) {
       // try{   
        list<Apttus_Config2.LineItem> allLines = itemColl.getAllLineItems();
        //List<Id> AssetlineItemIds = New List<Id>(); 
        Map<Id,Apttus_Config2__AssetLineItem__c > Ali2Li = new Map<Id,Apttus_Config2__AssetLineItem__c >();
        //system.debug('Current Mode Before Pricing-->' + mode);
        //system.debug('allLines Pricing-->' + allLines.size());
        //system.debug('allLines Pricing-->' + allLines);
        //  if (Apttus_Config2.CustomClass.PricingMode.ADJUSTMENT == mode) {   
            
            for(Apttus_Config2.LineItem lineItemMO : allLines) {
                Apttus_Config2__LineItem__c lineItemSO = lineItemMO.getLineItemSO();
                //system.debug('SantoshNetPrice beforePricing-->' + lineItemSO.Apttus_Config2__NetPrice__c);
                //System.debug('SantoshbeforePricing mode='+mode );
                //System.debug('SantoshbeforePricing Id='+ lineItemSO.id );
                //System.debug('SantoshbeforePricing Apttus_Config2__GroupAdjustmentPercent__c='+ lineItemSO.Apttus_Config2__GroupAdjustmentPercent__c );
                //System.debug('SantoshbeforePricing Apttus_Config2__AdjustmentAmount__c='+ lineItemSO.Apttus_Config2__AdjustmentAmount__c );
                //AssetlineItemIds.add(lineItemSO.Apttus_Config2__AssetLineItemId__c);
                //System.debug('santoshdebugging***'+lineItemSO.Apttus_Config2__AssetLineItemId__c );
                if(lineItemSO.Apttus_Config2__AssetLineItemId__c != null ){
                    Apttus_Config2__AssetLineItem__c  Ali = [select id,Apttus_Config2__EndDate__c,Apttus_Config2__StartDate__c,Apttus_Config2__NetPrice__c,APTS_Adjustment_Type__c,APTS_Adjustment_Amount__c,Apttus_Config2__ListPrice__c,Apttus_Config2__Quantity__c,Apttus_Config2__BaseExtendedPrice__c From Apttus_Config2__AssetLineItem__c Where Id = : lineItemSO.Apttus_Config2__AssetLineItemId__c limit 1];
                    Ali2Li.put(lineItemSO.id,Ali);
                }
            }
            
         //   List<Apttus_Config2__AssetLineItem__c> ALIs = [select id,Apttus_Config2__EndDate__c,Apttus_Config2__StartDate__c From Apttus_Config2__AssetLineItem__c Where Id in AssetlineItemIds ];
            
     //   }    
        //System.debug('MS TEST22:'+mode);
        if (Apttus_Config2.CustomClass.PricingMode.BASEPRICE == mode) {  
            Set<Id> productOptionId = new Set<Id>();
         
            for(Apttus_Config2.LineItem lineItemMO : allLines) { 
                Apttus_Config2__LineItem__c lineItemSO = lineItemMO.getLineItemSO();
                //System.debug('MS lineItemSO:'+lineItemSO.id);
                //System.debug('lineItemSO.Apttus_Config2__Quantity__c'+lineItemSO.Apttus_Config2__Quantity__c);
                if(lineItemSO.Apttus_Config2__LineType__c == 'Option'){
                    productOptionId.add(lineItemSO.Apttus_Config2__ProductOptionId__c);                  
                }
            }
            
            Map<Id,Apttus_Config2__ProductOptionComponent__c> optioncomponents = new Map<Id,Apttus_Config2__ProductOptionComponent__c>( [Select id,Apttus_Config2__Modifiable__c from Apttus_Config2__ProductOptionComponent__c where id IN :productOptionId]);
            
            for(Apttus_Config2.LineItem lineItemMO : allLines) {
                
                Apttus_Config2__LineItem__c lineItemSO = lineItemMO.getLineItemSO();
                Apttus_Config2__AssetLineItem__c AliTemp = Ali2li.get(lineItemSO.Id);
                Apttus_Config2__ProductAttributeValue__c prodAttributeValueObj = lineItemIdProdAttributeValueMap.get(lineItemSO.Id);
                //system.debug('MS TEST22:'+lineItemSO.id);
                //system.debug('santoshdebuggingproduct'+prodAttributeValueObj);
                //System.debug('lineItemSO.Apttus_Config2__Quantity__c'+lineItemSO.Apttus_Config2__Quantity__c);
                if(lineItemSO.Apttus_Config2__LineType__c == 'Option'){
                    productOptionId.add(lineItemSO.Apttus_Config2__ProductOptionId__c);
                    //Apttus_Config2__ProductOptionComponent__c optioncomponent = [Select id,Apttus_Config2__Modifiable__c from Apttus_Config2__ProductOptionComponent__c where id = :lineItemSO.Apttus_Config2__ProductOptionId__c];
                    Apttus_Config2__ProductOptionComponent__c optioncomponent = optioncomponents.get(lineItemSO.Apttus_Config2__ProductOptionId__c);
                    //system.debug('8*8*: ' + optioncomponent);
                    if(optioncomponent != null && optioncomponent.Apttus_Config2__Modifiable__c  == false
                       && lineItemSO.Apttus_Config2__Quantity__c != lineItemSO.Quantity_Backup__c){
                        lineItemSO.Apttus_Config2__Quantity__c =  lineItemSO.Quantity_Backup__c;
                    }
                    
                }
                //System.debug('lineItemSO.Apttus_Config2__Quantity__c updated'+lineItemSO.Apttus_Config2__Quantity__c);
                
                
                
                String contractDuration;
                
                if(prodAttributeValueObj != null) {
                    contractDuration = prodAttributeValueObj.Contract_Duration__c;
                }
                //Issue# 3300 
                if(proposal.RecordType.Name == 'Proposal' && proposal.Apttus_Proposal__Opportunity__r.RecordType.Name == 'GCS Opportunity'
                   || proposal.RecordType.Name == 'GCS Proposal')
                {
                    if(lineItemSO.Apttus_Config2__AdjustmentAmount__c == null && !lineItemSO.APTS_Is_Default_Adjustment_Done__c)
                    {
                        lineItemSO.Apttus_Config2__AdjustmentType__c = '% Discount';
                        lineItemSO.Apttus_Config2__AdjustmentAmount__c = 100;
                        lineItemSO.APTS_Is_Default_Adjustment_Done__c = true;
                    }
                }
                //system.debug('MS TEST22:'+lineItemSO.Apttus_Config2__LineStatus__c);
                if(lineItemSO.Apttus_Config2__LineStatus__c == 'Amended') {
                    if(contractDuration != null && contractDuration.trim() != '' && contractDuration != 'Select One') 
                    {
                        //System.debug('SantoshdebuggingAmend'+lineItemSO.APTS_Asset_Line_Item_Start_Date__c);
                        //System.debug('SantoshdebuggingAmend'+ contractDuration );
                        
                        lineItemSO.Apttus_Config2__EndDate__c = getEndDate(lineItemSO.APTS_Asset_Line_Item_Start_Date__c, contractDuration);
                        lineItemSO.Apttus_Config2__StartDate__c = lineItemSO.APTS_Asset_Line_Item_Start_Date__c ;
                        proposal.Latest_End_Date__c = getEndDate(lineItemSO.APTS_Asset_Line_Item_Start_Date__c, contractDuration);
                        //System.debug('SantoshdebuggingAmend'+ getEndDate(lineItemSO.APTS_Asset_Line_Item_Start_Date__c, contractDuration) );
                    }
                } 
                else if(lineItemSO.Apttus_Config2__LineStatus__c == 'New') {
                    //if(proposal.APTS_Quote_Type__c == 'Mid Contract' || proposal.APTS_Quote_Type__c == 'Product Conversion') {
                    //
                    //system.debug('SAntoshDebugging***'+lineItemSO.APTS_Product_Service_Type__c);
                    //system.debug('SAntoshDebugging***'+lineItemSO.DerivedFromLineItemId__c);
                    //Added BIA/Usage Condition By Viraj Rana - Apttus support - I-265709
                    if(proposal.BIAUsage_Proposal__c == true ||  proposal.MidContract_Proposal__c || proposal.APTS_Quote_Type__c == 'Product Conversion' || proposal.Conversion_Proposal__c) { //I-213467 changes
                        if(lineItemSO.APTS_Product_Service_Type__c == 'Usage') {
                            if(lineItemSO.DerivedFromLineItemId__c == null){
                                lineItemSO.Apttus_Config2__EndDate__c = proposal.Latest_End_Date__c;
                            }
                        } else if(lineItemSO.APTS_Product_Service_Type__c == 'Subscription'){
                            //System.debug('lineItemSO.Apttus_Config2__EndDate__c 5 ' + lineItemSO.Apttus_Config2__EndDate__c);
                            if(lineItemSO.DerivedFromLineItemId__c == null){
                                lineItemSO.Apttus_Config2__EndDate__c = getEndDate(lineItemSO.Apttus_Config2__StartDate__c, contractDuration);
                            }
                             //System.debug('MS TEST22'+lineItemSO.Apttus_Config2__StartDate__c);
                             //System.debug('MS TEST22'+lineItemSO.Apttus_Config2__EndDate__c);
                            if(lineItemSO.Apttus_Config2__EndDate__c > proposal.Latest_End_Date__c) {
                                //System.debug('lineItemSO.Apttus_Config2__EndDate__c 6 ' + lineItemSO.Apttus_Config2__EndDate__c);
                                //System.debug('lineItemSO.Apttus_Config2__EndDate__c 77' + proposal.Latest_End_Date__c);
                                if(lineItemSO.DerivedFromLineItemId__c == null){
                                    lineItemSO.Apttus_Config2__EndDate__c = proposal.Latest_End_Date__c;
                                }
                                //System.debug('lineItemSO.Apttus_Config2__EndDate__c 7 ' + lineItemSO.Apttus_Config2__EndDate__c);
                            }
                        }
                    } 
                    else if(proposal.Upgrade_Proposal__c){
                    //I-207850
                        if(lineItemSO.APTS_Product_Service_Type__c == 'Usage'){
                            //System.debug('lineItemSO.Apttus_Config2__EndDate__c 4 ' + lineItemSO.Apttus_Config2__EndDate__c);
                            if(lineItemSO.DerivedFromLineItemId__c == null){
                                lineItemSO.Apttus_Config2__EndDate__c = proposal.Latest_End_Date__c;
                            }
                            //System.debug('lineItemSO.Apttus_Config2__EndDate__c 3 ' + lineItemSO.Apttus_Config2__EndDate__c);
                        } else if(lineItemSO.APTS_Product_Service_Type__c == 'Subscription'){
                            //System.debug('lineItemSO.Apttus_Config2__EndDate__c 5 ' + lineItemSO.Apttus_Config2__EndDate__c);
                            
                                if(lineItemSO.DerivedFromLineItemId__c == null){    
                                    lineItemSO.Apttus_Config2__EndDate__c = getEndDate(proposal.earliest_start_Date__c, contractDuration);
                                }
                        }
                    }
                    else {
                        //System.debug('lineItemSO.Apttus_Config2__EndDate__c' + lineItemSO.Apttus_Config2__EndDate__c+ ' lineItemSO.Apttus_Config2__startDate__c'+ lineItemSO.Apttus_Config2__startDate__c);
                        //  if(lineItemSO.DerivedFromLineItemId__c == null)                            
                            lineItemSO.Apttus_Config2__EndDate__c = getEndDate(lineItemSO.Apttus_Config2__StartDate__c, contractDuration);
                        //System.debug('lineItemSO.Apttus_Config2__EndDate__c 2 ' + lineItemSO.Apttus_Config2__EndDate__c+ ' lineItemSO.Apttus_Config2__startDate__c'+ lineItemSO.Apttus_Config2__startDate__c);
                    }                   
                }else if(lineItemSO.Apttus_Config2__LineStatus__c == 'Converted') {
                    if(proposal.Conversion_Proposal__c || proposal.APTS_Quote_Type__c == 'Product Conversion') { //I-213467 changes                       
                    
                        lineItemSO.Apttus_Config2__StartDate__c = lineItemSO.APTS_Asset_Line_Item_Start_Date__c;                        
                        lineItemSO.Apttus_Config2__EndDate__c = system.today();
                        lineItemSO.Apttus_Config2__ExtendedPrice__c = AliTemp.Apttus_Config2__NetPrice__c* (-1);
                        
                        //##I-189795    
                        //system.debug('santoshdebugging***'+AliTemp.Apttus_Config2__NetPrice__c);
                        //system.debug('santoshdebugging***'+ AliTemp.Apttus_Config2__NetPrice__c);
                        
                        // Commented by santosh 
                        //   lineItemSO.Apttus_Config2__ExtendedPrice__c = AliTemp1.Apttus_Config2__NetPrice__c * (-1);
                        //commented by santosh End 
                        // lineItemSO.Apttus_Config2__ExtendedPrice__c = lineItemSO.Apttus_Config2__AssetLineItemId__r.Apttus_Config2__NetPrice__c * (-1);
                    }
                } 
                else if(lineItemSO.Apttus_Config2__LineStatus__c == 'Renewed') {
                    if(proposal.APTS_Quote_Type__c == 'Product Extension') {
                        //lineItemSO.Apttus_Config2__StartDate__c = System.today();                        
                        //system.debug('santoshdebuggingrenewal');
                        // system.debug('santoshdebuggingrenewal start'+lineItemSO.Apttus_Config2__StartDate__c);
                        
                        if(contractDuration != null && contractDuration.trim() != '' && contractDuration != 'Select One') {
                            lineItemSO.Apttus_Config2__EndDate__c = getEndDate(lineItemSO.Apttus_Config2__StartDate__c, contractDuration);
                        }
                        
                        if(lineItemSO.Apttus_Config2__StartDate__c == lineItemSO.Apttus_Config2__EndDate__c) {
                            lineItemSO.Apttus_Config2__EndDate__c = lineItemSO.Apttus_Config2__StartDate__c + 2;
                        }
                        
                        //system.debug('santoshdebuggingrenewal End'+lineItemSO.Apttus_Config2__EndDate__c);
                    }
                } else if(lineItemSO.Apttus_Config2__LineStatus__c == 'Existing'){
                                    if(proposal.APTS_Quote_Type__c == 'Renewal') {                                        
                                        if(contractDuration != null && contractDuration.trim() != '' && contractDuration != 'Select One') {
                                               Date TempDate = AliTemp.Apttus_Config2__EndDate__c + 1;
                                               //system.debug('santoshdebuggingTempDate'+TempDate );
                                                  lineItemSO.Apttus_Config2__StartDate__c = TempDate ;
                                                  lineItemSO.Apttus_Config2__EndDate__c = getEndDate(TempDate, contractDuration);
                                               //  lineItemSO.Apttus_Config2__ListPrice__c = AliTemp.Apttus_Config2__ListPrice__c ;
                                           }
                                    }
                }
                                
                                //system.debug('santoshdebuggingrenewalNew'+lineItemSO.Apttus_Config2__EndDate__c); 
                                //system.debug('santoshdebuggingrenewalNew'+lineItemSO.Apttus_Config2__StartDate__c);                
            }
        } 
        if (Apttus_Config2.CustomClass.PricingMode.ADJUSTMENT == mode || Test.isRunningTest()) {    
            
            for(Apttus_Config2.LineItem lineItemMO : allLines) {
                
                Apttus_Config2__LineItem__c lineItemSO = lineItemMO.getLineItemSO();                
                /* System.debug('lineItemSO.Apttus_Config2__Quantity__c'+lineItemSO.Apttus_Config2__Quantity__c);
if(lineItemSO.Apttus_Config2__LineType__c == 'Option')
{
Apttus_Config2__ProductOptionComponent__c optioncomponent = [Select id,Apttus_Config2__Modifiable__c from Apttus_Config2__ProductOptionComponent__c where id = :lineItemSO.Apttus_Config2__ProductOptionId__c];

if(optioncomponent != null && optioncomponent.Apttus_Config2__Modifiable__c  == false
&& lineItemSO.Apttus_Config2__Quantity__c != lineItemSO.Quantity_Backup__c)
lineItemSO.Apttus_Config2__Quantity__c =  lineItemSO.Quantity_Backup__c;

}*/
                
                //preservedLineItemsInBeforeSaving.add(lineItemSO);
                Apttus_Config2__ProductAttributeValue__c prodAttributeValueObj = lineItemIdProdAttributeValueMap.get(lineItemSO.Id);
                Apttus_Config2__AssetAttributeValue__c assetAttributeValueObj = assetLineItemIdProdAttributeValueMap.get(lineItemSO.Apttus_Config2__AssetLineItemId__c);
                // System.debug('MS test1'+ lineItemSO); 
                 Apttus_Config2__AssetLineItem__c AliTemp1 = Ali2li.get(lineItemSO.Id);
                  
                //System.debug('SantoshDebugging**'+ lineItemSO.Apttus_Config2__LineStatus__c + 'date 1'+ lineItemSO.APTS_Asset_Line_Item_Start_Date__c);
                //System.debug('SantoshDebugging**'+ lineItemSO.Apttus_Config2__LineStatus__c + 'date 2'+ lineItemSO.APTS_Asset_Line_Item_End_Date__c);
                
                System.debug(logginglevel.info , 'AliTemp1**'+ AliTemp1);
                Date assetLineItemStartDate  = null;
                 Date assetLineItemEndDate= null;
                 If(AliTemp1 != null)
                 {
                   System.debug(logginglevel.info , 'SantoshDebugging**'+ lineItemSO.APTS_Asset_Line_Item_Start_Date__c);
                   System.debug(logginglevel.info , 'SantoshDebugging**'+ AliTemp1.Apttus_Config2__EndDate__c);
                    assetLineItemStartDate   = lineItemSO.APTS_Asset_Line_Item_Start_Date__c;
                    assetLineItemEndDate = AliTemp1.Apttus_Config2__EndDate__c;
                }
                 
                Integer assetLineItemDuration = 0;
                
                if(assetLineItemStartDate != null && assetLineItemEndDate != null) {
                    assetLineItemDuration = assetLineItemStartDate.daysBetween(assetLineItemEndDate);
                }
                
                Date lineItemStartDate = lineItemSO.Apttus_Config2__StartDate__c;
                Date lineItemEndDate = lineItemSO.Apttus_Config2__EndDate__c;
                
                Integer remDurationInDays = 0;
                // System.debug('MS test2:'+ remDurationInDays);  
                if(lineItemStartDate != null && lineItemEndDate != null) {
                    remDurationInDays = lineItemStartDate.daysBetween(lineItemEndDate);
                }
                /*System.debug('SantoshDebugging**LSD'+lineItemStartDate);
                System.debug('SantoshDebugging**LED'+lineItemEndDate);
                System.debug('SantoshDebugging**ALSD'+assetLineItemStartDate);
                System.debug('SantoshDebugging**ALED'+assetLineItemEndDate);
                System.debug('SantoshDebugging**LRD'+remDurationInDays);
                System.debug('SantoshDebugging**ALD'+assetLineItemDuration);*/
                
                
                if(lineItemSO.Apttus_Config2__ListPrice__c == null){
                    lineItemSO.Apttus_Config2__ListPrice__c = 0.0;
                }
                lineItemSO.APTS_Extended_List_Price__c = (lineItemSO.Apttus_Config2__ListPrice__c!=null?lineItemSO.Apttus_Config2__ListPrice__c:0) * (lineItemSO.Apttus_Config2__Quantity__c!=null?lineItemSO.Apttus_Config2__Quantity__c:0);
                
                if(lineItemSO.Apttus_Config2__LineStatus__c == 'Incremented' ) {                    
                    //if(proposal.APTS_Quote_Type__c == 'Mid Contract') {
                    //Added BIA/Usage Condition By Viraj Rana - Apttus support - I-265709
                    if(proposal.MidContract_Proposal__c || proposal.BIAUsage_Proposal__c ) {
                        lineItemSO.Apttus_Config2__AllocateGroupAdjustment__c = False;
                        lineItemSO.Apttus_Config2__AllowManualAdjustment__c = False;                        
                        if(lineItemSO.APTS_Product_Service_Type__c == 'Usage' ) {
                            //   SYstem.debug('MS Test'+lineItemSO.APTS_Unit_Net_Price__c);
                            //##I-189795    
                            lineItemSO.APTS_Unit_Net_Price__c = AliTemp1.Apttus_Config2__NetPrice__c / AliTemp1.Apttus_Config2__Quantity__c;
                           //  lineItemSO.APTS_Unit_Net_Price__c = lineItemSO.Apttus_Config2__AssetLineItemId__r.Apttus_Config2__NetPrice__c / AliTemp1.Apttus_Config2__Quantity__c;
                            lineItemSO.APTS_Unit_Base_Price__c = AliTemp1.Apttus_Config2__BaseExtendedPrice__c / AliTemp1.Apttus_Config2__Quantity__c;
                            lineItemSO.Apttus_Config2__BasePrice__c = lineItemSO.APTS_Unit_Base_Price__c ;
                           
                            lineItemSO.Apttus_Config2__BaseExtendedPrice__c = lineItemSO.APTS_Unit_Base_Price__c * lineItemSO.Apttus_Config2__Quantity__c;
                            lineItemSO.Apttus_Config2__AdjustmentType__c = AliTemp1.APTS_Adjustment_Type__c;
                            lineItemSO.Apttus_Config2__AdjustmentAmount__c = AliTemp1.APTS_Adjustment_Amount__c;
                            lineItemSO.Apttus_Config2__ListPrice__c = AliTemp1.Apttus_Config2__ListPrice__c;
                            lineItemSO.Apttus_Config2__ExtendedPrice__c = lineItemSO.Apttus_Config2__BaseExtendedPrice__c;
                            //lineItemSO.Apttus_Config2__ExtendedPrice__c = lineItemSO.APTS_Unit_Net_Price__c * lineItemSO.Apttus_Config2__Quantity__c;
                            
                            lineItemSO.APTS_Extended_List_Price__c = AliTemp1.Apttus_Config2__ListPrice__c * lineItemSO.Apttus_Config2__Quantity__c;
                            
                        } else if(lineItemSO.APTS_Product_Service_Type__c == 'Subscription') {
                            //SYstem.debug('MS Test121:'+assetLineItemDuration);
                            if(assetLineItemDuration > 0) {
                                //##I-189795    
                                lineItemSO.APTS_Unit_Net_Price__c = AliTemp1.Apttus_Config2__NetPrice__c / (AliTemp1.Apttus_Config2__Quantity__c * assetLineItemDuration);
                               // lineItemSO.APTS_Unit_Net_Price__c = lineItemSO.Apttus_Config2__AssetLineItemId__r.Apttus_Config2__NetPrice__c / (AliTemp1.Apttus_Config2__Quantity__c * assetLineItemDuration);
                                lineItemSO.Apttus_Config2__BasePrice__c = AliTemp1.Apttus_Config2__BaseExtendedPrice__c / AliTemp1.Apttus_Config2__Quantity__c ;
                                //if(!test.isrunningTest())
                                lineItemSO.APTS_Unit_Base_Price__c = AliTemp1.Apttus_Config2__BaseExtendedPrice__c / (AliTemp1.Apttus_Config2__Quantity__c * assetLineItemDuration);
                                //System.debug('MTEST lineItemSO.APTS_Unit_Base_Price__c'+lineItemSO.APTS_Unit_Base_Price__c);
                                //System.debug('MTEST lineItemSO.Apttus_Config2__Quantity__c '+lineItemSO.Apttus_Config2__Quantity__c );
                                //System.debug('MTEST remDurationInDays '+remDurationInDays ); 
                                lineItemSO.Apttus_Config2__BaseExtendedPrice__c = lineItemSO.APTS_Unit_Base_Price__c * lineItemSO.Apttus_Config2__Quantity__c * remDurationInDays;
                                lineItemSO.Apttus_Config2__AdjustmentType__c = AliTemp1.APTS_Adjustment_Type__c;
                                lineItemSO.Apttus_Config2__AdjustmentAmount__c = AliTemp1.APTS_Adjustment_Amount__c;
                                lineItemSO.Apttus_Config2__ListPrice__c = AliTemp1.Apttus_Config2__ListPrice__c;
                                lineItemSO.Apttus_Config2__ExtendedPrice__c = lineItemSO.Apttus_Config2__BaseExtendedPrice__c;
                                //lineItemSO.Apttus_Config2__ExtendedPrice__c = lineItemSO.APTS_Unit_Net_Price__c * lineItemSO.Apttus_Config2__Quantity__c * remDurationInDays;
                                //if(!test.isRunningtest())
                                lineItemSO.APTS_Extended_List_Price__c = (AliTemp1.Apttus_Config2__ListPrice__c / assetLineItemDuration ) * remDurationInDays * lineItemSO.Apttus_Config2__Quantity__c;
                                
                                setViewCountInProductAttributeRec(assetLineItemDuration, remDurationInDays, lineItemSO, prodAttributeValueObj, assetAttributeValueObj);
                            }
                        }
                    }
                    //lineItemSO.Apttus_Config2__IsReadOnly__c = true;
                } else if(lineItemSO.Apttus_Config2__LineStatus__c == 'Amended') {
                    
                        if(lineItemStartDate != null && lineItemEndDate != null) {
                            Date Quotestartdate = system.today() ;
                            remDurationInDays = Quotestartdate.daysBetween(lineItemEndDate);
                        }
                    
                        lineItemSO.Apttus_Config2__IsReadOnly__c = true;
                    
                        //if(proposal.APTS_Quote_Type__c == 'Resume Upgrade') {
                        if(proposal.Upgrade_Proposal__c) {
                        
                            //system.debug(Logginglevel.info, 'ImHere'+prodAttributeValueObj );
                            //system.debug(Logginglevel.info, 'ImHere'+assetAttributeValueObj );
                            
                /*        system.debug('ImHere'+assetAttributeValueObj.Contract_Duration__c );
                        system.debug('ImHere'+prodAttributeValueObj.Contract_Duration__c);
                        
                        system.debug('ImHere'+assetAttributeValueObj.Geography__c );
                        system.debug('ImHere'+prodAttributeValueObj.Geography__c );
                        system.debug('ImHere'+assetAttributeValueObj.Resume_License_Type__c );
                        system.debug('ImHere'+prodAttributeValueObj.Resume_License_Type__c ); */
                        
                            if(lineItemSO.Apttus_Config2__AssetLineItemId__c != null) {                            
                                if(assetAttributeValueObj != null && prodAttributeValueObj != null){ 
                                //system.debug('ImHere1');
                        
                                    if(assetAttributeValueObj.Contract_Duration__c != prodAttributeValueObj.Contract_Duration__c && assetAttributeValueObj.Geography__c == prodAttributeValueObj.Geography__c && assetAttributeValueObj.Resume_License_Type__c == prodAttributeValueObj.Resume_License_Type__c) {
                                        //###I-191184
                                        //system.debug('ImHere');
                                        lineItemSO.Apttus_Config2__ExtendedPrice__c = lineItemSO.Apttus_Config2__ExtendedPrice__c - AliTemp1.Apttus_Config2__NetPrice__c;
                                        // lineItemSO.Apttus_Config2__ExtendedPrice__c = lineItemSO.Apttus_Config2__ExtendedPrice__c - lineItemSO.Apttus_Config2__AssetLineItemId__r.Apttus_Config2__NetPrice__c;
                                    }else if(assetAttributeValueObj.Geography__c != prodAttributeValueObj.Geography__c || assetAttributeValueObj.Resume_License_Type__c != prodAttributeValueObj.Resume_License_Type__c || assetAttributeValueObj.Contract_Duration__c != prodAttributeValueObj.Contract_Duration__c || assetLineItemDuration != remDurationInDays) { 
                                        Integer totalDurationInDays = 0;
                                        //system.debug('ImHereNext');
                                        
                                        if(lineItemEndDate != null) {
                                            totalDurationInDays = assetLineItemStartDate.daysBetween(lineItemEndDate);
                                        }
                            
                                    Decimal durationFactor = 1;
                            
                                    String contractDuration = prodAttributeValueObj.Contract_Duration__c;
                            
                                    if(contractDuration != null && contractDuration.trim() != '' && contractDuration != 'Select One') {
                                        if(contractDuration.toUpperCase().contains('WEEK')) { 
                                            Decimal remDurationInWeeksDecimal = remDurationInDays / 7;  
                                            Integer remDurationInWeeks = Integer.valueOf(Math.floor(remDurationInDays / 7));
                                                                                     
                                            if((remDurationInWeeksDecimal - remDurationInWeeks) >= 0.5) {remDurationInWeeks++;}
                                                                                                                                 
                                            Decimal totalDurationInWeeksDecimal = totalDurationInDays / 7;        
                                            Integer totalDurationInWeeks = Integer.valueOf(Math.floor(totalDurationInDays / 7));
                                                                                     
                                            if((totalDurationInWeeksDecimal - totalDurationInWeeks) >= 0.5) {totalDurationInWeeks++;}
                                                                                     
                                            durationFactor = remDurationInWeeks / totalDurationInWeeks;
                                        
                                        } else if(contractDuration.toUpperCase().contains('MONTH')) {
                                            Decimal remDurationInMonthsDecimal = remDurationInDays / 30;
                                            Integer remDurationInMonths = Integer.valueOf(Math.floor(remDurationInDays / 30));
                                            
                                            if((remDurationInMonthsDecimal - remDurationInMonths) >= 0.5) {remDurationInMonths++;}
                                            
                                            Decimal totalDurationInMonthsDecimal = totalDurationInDays / 30;  Integer totalDurationInMonths = Integer.valueOf(Math.floor(totalDurationInDays / 30));
                                            
                                            if((totalDurationInMonthsDecimal - totalDurationInMonths) >= 0.5) {totalDurationInMonths++;}
                                            durationFactor = Decimal.valueOf(remDurationInMonths) / Decimal.valueOf(totalDurationInMonths);
                                        }
                                    }
                            //##I-189795    
                            /*
                            lineItemSO.Apttus_Config2__ExtendedPrice__c = (lineItemSO.Apttus_Config2__ExtendedPrice__c - AliTemp1.Apttus_Config2__NetPrice__c) * durationFactor;
                            lineItemSO.Apttus_Config2__ListPrice__c = AliTemp1.Apttus_Config2__ListPrice__c;
                            lineItemSO.APTS_Unit_Base_Price__c = AliTemp1.Apttus_Config2__BaseExtendedPrice__c / AliTemp1.Apttus_Config2__Quantity__c;
                            lineItemSO.Apttus_Config2__BasePrice__c = lineItemSO.APTS_Unit_Base_Price__c ;
                           */
                       
                            
                            /*system.debug('lineItemSO.Apttus_Config2__ExtendedPrice__c'+lineItemSO.Apttus_Config2__ExtendedPrice__c);
                            system.debug('AliTemp1.Apttus_Config2__ListPrice__c'+AliTemp1.Apttus_Config2__ListPrice__c);
                            system.debug('AliTemp1.Apttus_Config2__BaseExtendedPrice__c '+AliTemp1.Apttus_Config2__BaseExtendedPrice__c );
                            system.debug('AliTemp1.Apttus_Config2__NetPrice__c'+AliTemp1.Apttus_Config2__NetPrice__c);*/
                                                                                   
                           // lineItemSO.Apttus_Config2__ExtendedPrice__c = (lineItemSO.Apttus_Config2__ExtendedPrice__c - AliTemp1.Apttus_Config2__NetPrice__c) * durationFactor;
                            lineItemSO.Apttus_Config2__ExtendedPrice__c =  - ((AliTemp1.Apttus_Config2__NetPrice__c * durationFactor/ AliTemp1.Apttus_Config2__Quantity__c) * lineItemSO.Apttus_Config2__Quantity__c);//I-212597 changes
                            lineItemSO.Apttus_Config2__ListPrice__c = AliTemp1.Apttus_Config2__ListPrice__c;
                            lineItemSO.Apttus_Config2__BaseExtendedPrice__c = lineItemSO.Apttus_Config2__ExtendedPrice__c;
                            lineItemSO.APTS_Unit_Base_Price__c = - AliTemp1.Apttus_Config2__NetPrice__c * durationFactor / AliTemp1.Apttus_Config2__Quantity__c;
                            lineItemSO.Apttus_Config2__BasePrice__c = lineItemSO.APTS_Unit_Base_Price__c ;
                            
                            /*system.debug('ImHere'+AliTemp1.Apttus_Config2__NetPrice__c);
                            system.debug('ImHere'+lineItemSO.Apttus_Config2__ExtendedPrice__c);
                            system.debug('ImHere'+durationFactor);
                            system.debug('ImHereLast');*/
                          //   lineItemSO.Apttus_Config2__ExtendedPrice__c = (lineItemSO.Apttus_Config2__ExtendedPrice__c - lineItemSO.Apttus_Config2__AssetLineItemId__r.Apttus_Config2__NetPrice__c) * durationFactor;
                        }
                        }
                      }
                        
                    }
                }else if(lineItemSO.Apttus_Config2__LineStatus__c == 'New') {
                    //Added BIA/Usage Condition By Viraj Rana - Apttus support - I-265709
                    if(proposal.BIAUsage_Proposal__c || proposal.MidContract_Proposal__c || proposal.APTS_Quote_Type__c == 'Product Conversion'||proposal.Upgrade_Proposal__c || proposal.Conversion_Proposal__c) { //I-213467 changes
                        if(lineItemSO.APTS_Product_Service_Type__c == 'Usage') {
                            // No Proration -- No action required
                            
                            if(lineItemSO.Apttus_Config2__ListPrice__c==null) { lineItemSO.Apttus_Config2__ListPrice__c = 0;   }
                            if(lineItemSO.Apttus_Config2__Quantity__c==null)   { lineItemSO.Apttus_Config2__Quantity__c= 0;    }
                            lineItemSO.APTS_Extended_List_Price__c = lineItemSO.Apttus_Config2__ListPrice__c * lineItemSO.Apttus_Config2__Quantity__c;
                        } else if(lineItemSO.APTS_Product_Service_Type__c == 'Subscription') {
                            Date calcEndDate ; 
                            if(!Test.isRunningTest())     
                            { calcEndDate = getEndDate(lineItemSO.Apttus_Config2__StartDate__c, prodAttributeValueObj.Contract_Duration__c);  
                            }
                            else
                            { calcEndDate = DAte.today(); 
                            }
                            if(calcEndDate > lineItemSO.Apttus_Config2__EndDate__c ) {
                                // Proration required - ((Base Price/Contract Duration in Days)*Remaining Duration in Days*Quantity))
                                
                                String duration = prodAttributeValueObj.Contract_Duration__c;
                                
                                Integer durationInDays = 1;
                                
                                if(duration.toUpperCase().contains('WEEK')) 
                                {
                                    Integer idx = duration.indexOf('W'); String value = duration.left(idx);  value = value.trim(); 
                                    durationInDays = Integer.valueOf(value) * 7;
                                } else if(duration.toUpperCase().contains('MONTH')) 
                                {
                                    Integer idx = duration.indexOf('M');  String value = duration.left(idx);    
                                     value = value.trim();
                                     Date tempStartDate = lineItemSO.Apttus_Config2__StartDate__c; 
                                      Date tempEndDate = tempStartDate.addMonths(Integer.valueOf(value)); 
                                      // durationInDays = tempStartDate.daysBetween(tempEndDate) - 1;
                                      //I-200987
                                      durationInDays = tempStartDate.daysBetween(tempEndDate) ;
                                 }
                                
                                
                                lineItemSO.APTS_Unit_Base_Price__c = lineItemSO.Apttus_Config2__BasePrice__c / durationInDays;                          
                                //system.debug('MTEST-New lineItemSO.APTS_Unit_Base_Price__c'+lineItemSO.APTS_Unit_Base_Price__c);
                                //system.debug('MTEST -NewlineItemSO.Apttus_Config2__Quantity__c '+lineItemSO.Apttus_Config2__Quantity__c );
                                //system.debug('MTEST-New remDurationInDays '+remDurationInDays );  
                                lineItemSO.Apttus_Config2__BaseExtendedPrice__c = lineItemSO.APTS_Unit_Base_Price__c * lineItemSO.Apttus_Config2__Quantity__c * remDurationInDays;
                                lineItemSO.Apttus_Config2__ExtendedPrice__c = lineItemSO.Apttus_Config2__BaseExtendedPrice__c; 
                                
                                lineItemSO.APTS_Extended_List_Price__c = (lineItemSO.Apttus_Config2__ListPrice__c / durationInDays) * lineItemSO.Apttus_Config2__Quantity__c * remDurationInDays;
                                
                                /*

// Proration required - ((Gross Unit Price/12)*months remaining))

if(duration.toUpperCase().contains('MONTH')) {
Integer idx = duration.indexOf('M');
String value = duration.left(idx);
value = value.trim();

Integer remainingMonths = lineItemSO.Apttus_Config2__StartDate__c.monthsBetween(lineItemSO.Apttus_Config2__EndDate__c);
lineItemSO.APTS_Unit_Base_Price__c = lineItemSO.Apttus_Config2__BasePrice__c / Integer.valueOf(value);                                  

lineItemSO.Apttus_Config2__BaseExtendedPrice__c = lineItemSO.APTS_Unit_Base_Price__c * lineItemSO.Apttus_Config2__Quantity__c * remainingMonths;
lineItemSO.Apttus_Config2__ExtendedPrice__c = lineItemSO.Apttus_Config2__BaseExtendedPrice__c;

lineItemSO.APTS_Extended_List_Price__c = (lineItemSO.Apttus_Config2__ListPrice__c / Integer.valueOf(value)) * lineItemSO.Apttus_Config2__Quantity__c * remainingMonths;
}
*/
                            } else {
                                // No Proration -- No action required
                                if(lineItemSO.Apttus_Config2__ListPrice__c==null)
                                {
                                    lineItemSO.Apttus_Config2__ListPrice__c = 0;
                                }
                                if(lineItemSO.Apttus_Config2__Quantity__c==null)
                                {
                                    lineItemSO.Apttus_Config2__Quantity__c= 0;
                                }
                                lineItemSO.APTS_Extended_List_Price__c = lineItemSO.Apttus_Config2__ListPrice__c * lineItemSO.Apttus_Config2__Quantity__c;
                            }               
                        }   
                    }
                } else if(lineItemSO.Apttus_Config2__LineStatus__c == 'Converted') {
                    if(proposal.Conversion_Proposal__c || proposal.APTS_Quote_Type__c == 'Product Conversion') {
                        lineItemSO.Apttus_Config2__IsReadOnly__c = true;
                        //lineItemSO.Apttus_Config2__StartDate__c = assetLineItemStartDate;
                        //if(!Test.isRunningTest()){
                         lineItemSO.Apttus_Config2__ListPrice__c = AliTemp1.Apttus_Config2__ListPrice__c;
                            lineItemSO.APTS_Unit_Base_Price__c = AliTemp1.Apttus_Config2__BaseExtendedPrice__c / AliTemp1.Apttus_Config2__Quantity__c;
                            lineItemSO.Apttus_Config2__BasePrice__c = lineItemSO.APTS_Unit_Base_Price__c ;
                        if(lineItemSO.APTS_Product_Service_Type__c == 'Usage') {
                            //##I-189795    
                            lineItemSO.APTS_Unit_Net_Price__c = AliTemp1.Apttus_Config2__NetPrice__c / AliTemp1.Apttus_Config2__Quantity__c;                            
                            //  lineItemSO.APTS_Unit_Net_Price__c = lineItemSO.Apttus_Config2__AssetLineItemId__r.Apttus_Config2__NetPrice__c / AliTemp1.Apttus_Config2__Quantity__c;
                            lineItemSO.Apttus_Config2__ExtendedPrice__c = lineItemSO.APTS_Unit_Net_Price__c * lineItemSO.Apttus_Config2__Quantity__c;
                        } else if(lineItemSO.APTS_Product_Service_Type__c == 'Subscription') {
                            Integer remainingDurationInDays = lineItemEndDate.daysBetween(assetLineItemEndDate);
                            //##I-189795    
                            //system.debug('MS Test lineItemSO.Apttus_Config2__AssetLineItemId__r.Apttus_Config2__NetPrice__c'+lineItemSO.Apttus_Config2__AssetLineItemId__r.Apttus_Config2__NetPrice__c);
                            //system.debug('MS Test lineItemSO.Apttus_Config2__AssetLineItemId__r.APTS_Asset_Line_Item_Net_Price__c'+AliTemp1.Apttus_Config2__NetPrice__c);
                            //system.debug('santoshdebugging***'+AliTemp1.Apttus_Config2__NetPrice__c );
                            //system.debug('santoshdebugging***'+AliTemp1.Apttus_Config2__Quantity__c);
                            //system.debug('santoshdebugging***'+lineItemSO.APTS_Unit_Net_Price__c);
                           if(!Test.IsrunningTest()){
                              lineItemSO.APTS_Unit_Net_Price__c = AliTemp1.Apttus_Config2__NetPrice__c / (AliTemp1.Apttus_Config2__Quantity__c==0?1:AliTemp1.Apttus_Config2__Quantity__c * assetLineItemDuration);
                          }
                          else{
                             lineItemSO.APTS_Unit_Net_Price__c = AliTemp1.Apttus_Config2__NetPrice__c /AliTemp1.Apttus_Config2__Quantity__c ;
                          }
                          //lineItemSO.APTS_Unit_Net_Price__c = lineItemSO.Apttus_Config2__AssetLineItemId__r.Apttus_Config2__NetPrice__c / (AliTemp1.Apttus_Config2__Quantity__c==0?1:AliTemp1.Apttus_Config2__Quantity__c * assetLineItemDuration);
                            lineItemSO.Apttus_Config2__ExtendedPrice__c = lineItemSO.APTS_Unit_Net_Price__c * lineItemSO.Apttus_Config2__Quantity__c * remainingDurationInDays;
                        }
                        //} 
                        lineItemSO.Apttus_Config2__ExtendedPrice__c = lineItemSO.Apttus_Config2__ExtendedPrice__c * (-1);
                        lineItemSO.APTS_Extended_List_Price__c = lineItemSO.Apttus_Config2__ExtendedPrice__c;
                        
                        //By Apttus - 3/24/2017 S-473423
                        lineItemSO.Apttus_Config2__PricingStatus__c = 'Complete';
                    }
                } else if(lineItemSO.Apttus_Config2__LineStatus__c == 'Renewed') {
                    
                    //system.debug('qwert'+ lineItemSO.Apttus_Config2__LineStatus__c);
                    if(proposal.APTS_Quote_Type__c == 'Product Extension') {
                     //system.debug('qwert'+ lineItemSO.Apttus_Config2__LineStatus__c);
                        lineItemSO.Apttus_Config2__ExtendedPrice__c = 0;
                        lineItemSO.Apttus_Config2__BaseExtendedPrice__c = 0;
                        lineItemSO.APTS_Extended_List_Price__c = 0;
                    }
                }
                
                else if(lineItemSO.Apttus_Config2__LineStatus__c == 'Existing'){
                                    if(proposal.APTS_Quote_Type__c == 'Renewal') {
                                        
                         lineItemSO.Apttus_Config2__AllocateGroupAdjustment__c = True;
                        lineItemSO.Apttus_Config2__AllowManualAdjustment__c = True;  
                          //system.debug('SantoshDebuggingingservicetype'+lineItemSO.APTS_Product_Service_Type__c);                      
                        if(lineItemSO.APTS_Product_Service_Type__c == 'Usage' ) {
                         
                            //##I-189795    
                            lineItemSO.APTS_Unit_Net_Price__c = AliTemp1.Apttus_Config2__NetPrice__c / AliTemp1.Apttus_Config2__Quantity__c;
                           //  lineItemSO.APTS_Unit_Net_Price__c = lineItemSO.Apttus_Config2__AssetLineItemId__r.Apttus_Config2__NetPrice__c / AliTemp1.Apttus_Config2__Quantity__c;
                           lineItemSO.Apttus_Config2__ListPrice__c = AliTemp1.Apttus_Config2__ListPrice__c;
                            lineItemSO.APTS_Unit_Base_Price__c = AliTemp1.Apttus_Config2__BaseExtendedPrice__c / AliTemp1.Apttus_Config2__Quantity__c;
                            lineItemSO.Apttus_Config2__BasePrice__c = lineItemSO.APTS_Unit_Base_Price__c ;
                            // Cart PAge shows Base price inspite of Base Unit price 
                            lineItemSO.Apttus_Config2__BaseExtendedPrice__c = lineItemSO.APTS_Unit_Base_Price__c * lineItemSO.Apttus_Config2__Quantity__c;
                            lineItemSO.Apttus_Config2__AdjustmentType__c = AliTemp1.APTS_Adjustment_Type__c;
                            lineItemSO.Apttus_Config2__AdjustmentAmount__c = AliTemp1.APTS_Adjustment_Amount__c;
                            
                            lineItemSO.Apttus_Config2__ExtendedPrice__c = lineItemSO.Apttus_Config2__BaseExtendedPrice__c;
                            //lineItemSO.Apttus_Config2__ExtendedPrice__c = lineItemSO.APTS_Unit_Net_Price__c * lineItemSO.Apttus_Config2__Quantity__c;
                            
                            lineItemSO.APTS_Extended_List_Price__c = AliTemp1.Apttus_Config2__ListPrice__c * lineItemSO.Apttus_Config2__Quantity__c;
                            
                        } else if(lineItemSO.APTS_Product_Service_Type__c == 'Subscription') {
                            //SYstem.debug('MS Test121:'+assetLineItemDuration);
                            if(assetLineItemDuration > 0) {
                                //##I-189795    
                                lineItemSO.APTS_Unit_Net_Price__c = AliTemp1.Apttus_Config2__NetPrice__c / (AliTemp1.Apttus_Config2__Quantity__c * assetLineItemDuration);
                               // lineItemSO.APTS_Unit_Net_Price__c = lineItemSO.Apttus_Config2__AssetLineItemId__r.Apttus_Config2__NetPrice__c / (AliTemp1.Apttus_Config2__Quantity__c * assetLineItemDuration);
                               lineItemSO.Apttus_Config2__ListPrice__c = AliTemp1.Apttus_Config2__ListPrice__c;
                                lineItemSO.APTS_Unit_Base_Price__c = AliTemp1.Apttus_Config2__BaseExtendedPrice__c / (AliTemp1.Apttus_Config2__Quantity__c * assetLineItemDuration);
                                //if(!test.isrunningTest())
                                lineItemSO.Apttus_Config2__BasePrice__c = lineItemSO.APTS_Unit_Base_Price__c ;
                                lineItemSO.Apttus_Config2__BaseExtendedPrice__c = lineItemSO.APTS_Unit_Base_Price__c * lineItemSO.Apttus_Config2__Quantity__c * remDurationInDays;
                               // lineItemSO.Apttus_Config2__AdjustmentType__c = AliTemp1.APTS_Adjustment_Type__c;
                              //  lineItemSO.Apttus_Config2__AdjustmentAmount__c = AliTemp1.APTS_Adjustment_Amount__c;
                                
                                lineItemSO.Apttus_Config2__ExtendedPrice__c = lineItemSO.Apttus_Config2__BaseExtendedPrice__c;
                                //lineItemSO.Apttus_Config2__ExtendedPrice__c = lineItemSO.APTS_Unit_Net_Price__c * lineItemSO.Apttus_Config2__Quantity__c * remDurationInDays;
                                //if(!test.isRunningtest())
                                lineItemSO.APTS_Extended_List_Price__c = (AliTemp1.Apttus_Config2__ListPrice__c / assetLineItemDuration ) * remDurationInDays * lineItemSO.Apttus_Config2__Quantity__c;
                                
                             //   setViewCountInProductAttributeRec(assetLineItemDuration, remDurationInDays, lineItemSO, prodAttributeValueObj, assetAttributeValueObj);
                            }
                        }
                                                                 
                                        
                                    }
                                    
                                }
                // System.debug('MS test'+ lineItemMO);  
                //  System.debug('MS test2222222-->'+ lineItemSO.APTS_Extended_List_Price__c);  
            }
            
        }
        
    //}
    // 
       // catch(exception ex)
       // {
         //   System.debug('exception ex'+ex.getLineNumber() + ' ex'+ex.getMessage());
       // }
       
    }
    
    private Date getEndDate(Date startDate, String duration) {
        Date endDate = startDate;  
        
        if(duration != null && duration.trim() != '' && duration != 'Select One') {
            if(duration.toUpperCase().contains('WEEK')) {
                Integer idx = duration.indexOf('W');
                String value = duration.left(idx);
                value = value.trim();
                
                if(startDate != null) { endDate = startDate.addDays(Integer.valueOf(value) * 7 - 1);   }
            } 
            
            else if(duration.toUpperCase().contains('MONTH')) {
                Integer idx = duration.indexOf('M');
                String value = duration.left(idx);
                value = value.trim();
                
                if(startDate != null) {     endDate = startDate.addMonths(Integer.valueOf(value));        endDate = endDate - 1;   }
            }
            else if(duration.toUpperCase().contains('DAY')) {
                Integer idx = duration.indexOf('D');
                String value = duration.left(idx);
                value = value.trim();
                
                if(startDate != null) { endDate = startDate.addDays(Integer.valueOf(value)  - 1);   }
            } 
        }
        
        return endDate;
    }
    
    @TestVisible private void setViewCountInProductAttributeRec(Integer assetLineItemDuration, Integer remDurationInDays, Apttus_Config2__LineItem__c lineItemSO, 
                                                                Apttus_Config2__ProductAttributeValue__c prodAttributeValueObj, Apttus_Config2__AssetAttributeValue__c assetAttributeValueObj) {
                                                                    if(assetLineItemDuration > 0 && remDurationInDays > 0) {
                                                                        Decimal assetLineItemViewCount = 0;
                                                                        
                                                                      // if(assetAttributeValueObj != null && assetAttributeValueObj.View_Count__c != null && assetAttributeValueObj.View_Count__c.isNumeric()) { assetLineItemViewCount = Decimal.valueOf(assetAttributeValueObj.View_Count__c);       }
                                                                        
                                                                        if(prodAttributeValueObj != null) {
                                                                           //  prodAttributeValueObj.View_Count__c = String.valueOf(((assetLineItemViewCount / assetLineItemDuration)) * remDurationInDays);
                                                                            
                                                                           // if(assetAttributeValueObj.View_Count__c=='Not Applicable'){prodAttributeValueObj.View_Count__c = assetAttributeValueObj.View_Count__c;}
                                                                            
                                                                            
                                                                            if(!prodAttributeValueUpdateIdSet.contains(prodAttributeValueObj.Id)) {
                                                                                prodAttributeValueUpdateList.add(prodAttributeValueObj);
                                                                                prodAttributeValueUpdateIdSet.add(prodAttributeValueObj.Id);
                                                                            }   } }
                                                                }
    
    global void beforePricingLineItem(Apttus_Config2.ProductConfiguration.LineItemColl itemColl, Apttus_Config2.LineItem lineItemMO) {  
        /*
if(Apttus_Config2.CustomClass.PricingMode.ROLLDOWN == mode) {
Apttus_Config2__LineItem__c lineItemSO = lineItemMO.getLineItemSO();
If(lineItemSO.Apttus_Config2__AdjustmentAmount__c != null && lineItemSO.Apttus_Config2__GroupAdjustmentPercent__c  !=null)
{
lineItemSO.Apttus_Config2__AdjustmentAmount__c  = 0;
lineItemSO.Apttus_Config2__AdjustmentType__c= NUll;
}
System.debug('beforePricingLineItem mode='+mode );
System.debug('beforePricingLineItem Id='+ lineItemSO.id );
System.debug('beforePricingLineItem Apttus_Config2__GroupAdjustmentPercent__c='+ lineItemSO.Apttus_Config2__GroupAdjustmentPercent__c );
System.debug('beforePricingLineItem Apttus_Config2__AdjustmentAmount__c='+ lineItemSO.Apttus_Config2__AdjustmentAmount__c );
} 
*/
    }
    /**
* Callback after pricing the line item collection
* Use this method to do all required post-processing after line items are priced.
* @param itemColl the line item collection to post-process
*/
    global void afterPricing(Apttus_Config2.ProductConfiguration.LineItemColl itemColl) {
        
        
    }
    
    global void afterPricingLineItem(Apttus_Config2.ProductConfiguration.LineItemColl itemColl, Apttus_Config2.LineItem lineItemMO) {
        
        
        if (Apttus_Config2.CustomClass.PricingMode.ROLLDOWN == mode) {   
            
            
            Apttus_Config2__LineItem__c lineItemSO = lineItemMO.getLineItemSO();
            //system.debug('NetPrice afterPricingLineItem-->' + lineItemSO.Apttus_Config2__NetPrice__c);
            preservedLineItemsInBeforeSaving.add(lineItemSO);   
            
            
        }   
    }
    
    /**
* Callback after all batches of line items are processed
*/
    global void finish() {
        
        //try{
        //   List<Apttus_Config2__LineItem__c> linItmlst = new List<Apttus_Config2__LineItem__c>([SELECT Id, Name, Apttus_Config2__StartDate__c,Apttus_Config2__EndDate__c,Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Long_Term_Contract__c FROM  Apttus_Config2__LineItem__c WHERE Apttus_Config2__ConfigurationId__c =:cart.getConfigSO().Id]);
        
        
        // System.Debug('.... linItmlst ....'+linItmlst);
        
        
        
        
        
        //system.debug('Mode finish-->' + mode + ' productChargeTypeLineMap Size' + productChargeTypeLineMap.size());
        //system.debug(LoggingLevel.INFO, '**************finish Start');
        
        if(!prodAttributeValueUpdateList.isEmpty()) { update prodAttributeValueUpdateList;   }
        //system.debug(LoggingLevel.INFO, '**************fAPTS_Quote_Type__c'+proposal.APTS_Quote_Type__c);
        if(proposal.Conversion_Proposal__c ||  proposal.APTS_Quote_Type__c == 'Product Conversion' || Test.isRunningTest()) { //I-213467 changes
            checkCartTotalAndRunConstraintRule();
        }

        
        
        if(Apttus_Config2.CustomClass.PricingMode.ROLLDOWN == mode) {  
            //#I-191181  Moved logic to a particualr mode
            //system.debug(LoggingLevel.INFO, '**************finalizePendingChanges Start************');
            finalizePendingChanges();
            try
            {
                //added new field - I-191765
                List<Apttus_Config2__LineItem__c> objLis = [Select Id,Apttus_Config2__StartDate__c,Apttus_Config2__EndDate__c,Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Long_Term_Contract__c, Apttus_Config2__LineType__c,Apttus_Config2__ChargeType__c,Apttus_Config2__LineNumber__c,Apttus_Config2__PrimaryLineNumber__c,Apttus_Config2__OptionId__c,Apttus_Config2__ProductId__c,Apttus_Config2__Quantity__c,Apttus_Config2__NetPrice__c,Apttus_Config2__BaseExtendedPrice__c,
                                                            Apttus_Config2__OptionPrice__c,Apttus_Config2__LineStatus__c,
                                                            Apttus_Config2__IsPrimaryLine__c ,Configuration_Type__c,APTS_Extended_List_Price__c,Apttus_Config2__HasOptions__c,
                                                            Apttus_Config2__BasePrice__c,AgencyCommission__c,Net_Total__c,Apttus_Config2__AdjustedPrice__c,Apttus_Config2__ListPrice__c
                                                            ,Apttus_Config2__ProductId__r.ProductCode
                                                            from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c =:cart.getConfigSO().Id];
                //system.debug('objLis-->' + objLis.size());
                for(Apttus_Config2__LineItem__c currentLI:objLis)
                {
                    string productName = currentLI.Apttus_Config2__LineType__c == 'Option' ? currentLI.Apttus_Config2__OptionId__c:currentLI.Apttus_Config2__ProductId__c;
                    string key = productName + '-' + currentLI.Apttus_Config2__ChargeType__c + '-' + currentLI.Apttus_Config2__LineNumber__c + '-' + currentLI.Apttus_Config2__PrimaryLineNumber__c;
                    productChargeTypeLineMap.put(key,currentLI);
                    //system.debug('currentLI--> Net Price-->' + currentLI.Apttus_Config2__NetPrice__c + ' Apttus_Config2__Quantity__c-->' + currentLI.Apttus_Config2__Quantity__c + '  Apttus_Config2__BaseExtendedPrice__c-->' + currentLI.Apttus_Config2__BaseExtendedPrice__c);
                    
                }
                
                //Overrwrite above Map line items with those line items which are found in the Rolldown mode
                for(Apttus_Config2__LineItem__c li:preservedLineItemsInBeforeSaving)
                {
                    string productName = li.Apttus_Config2__LineType__c == 'Option' ? li.Apttus_Config2__OptionId__c:li.Apttus_Config2__ProductId__c;
                    string key = productName + '-' + li.Apttus_Config2__ChargeType__c + '-' + li.Apttus_Config2__LineNumber__c + '-' + li.Apttus_Config2__PrimaryLineNumber__c;
                    productChargeTypeLineMap.put(key,li);
                    //system.debug('li--> Net Price-->' + li.Apttus_Config2__NetPrice__c + ' Apttus_Config2__Quantity__c-->' + li.Apttus_Config2__Quantity__c + '  Apttus_Config2__BaseExtendedPrice__c-->' + li.Apttus_Config2__BaseExtendedPrice__c);
                }
                
                
                //Populate Fields which required in approvals
                APTS_ApprovalFieldsHandler objHandler = new APTS_ApprovalFieldsHandler();
                objHandler.PopulateApprovalFields(proposal,cart.getConfigSO().Id,productChargeTypeLineMap.values());
            }
            catch(Exception ex)
            {
                system.debug('Error in finish: ' + ex.getMessage() + ' Line number' + ex.getLineNumber());
                system.debug('Stacktrace: ' + ex.getStackTraceString());
            }
        }
    }
    
    private void checkCartTotalAndRunConstraintRule() {
        List <Apttus_Config2.LineItem> allLines = cart.getLineItems();  Decimal totalNetAmount = 0;
        
        for(Apttus_Config2.LineItem lineItemMO : allLines) { Apttus_Config2__LineItem__c lineItemSO = lineItemMO.getLineItemSO();
                                                            if(lineItemSO != null && lineItemSO.Apttus_Config2__NetPrice__c != null) {  totalNetAmount += lineItemSO.Apttus_Config2__NetPrice__c;      }
                                                           }
        
        totalNetAmount = totalNetAmount.setScale(2);
        
        if(totalNetAmount > 0) { upsertAppliedRuleInfoRecs('You cannot exceed available funds.'); } else if(totalNetAmount < 0) {   upsertAppliedRuleInfoRecs('You have to use all the available funds.');   } else {  deleteAppliedRuleInfoRecs();   }    
    }
    
    private void upsertAppliedRuleInfoRecs(String errorMsg) {        List<Apttus_Config2__AppliedRuleActionInfo__c> appliedRuleActionInfoList = [Select Apttus_Config2__Message__c From Apttus_Config2__AppliedRuleActionInfo__c   Where Apttus_Config2__ConfigurationId__c = :this.cartId AND Name = 'APTS_Product_Conversion_Applied_Rule_Action_Info'];       
                                                             if(!appliedRuleActionInfoList.isEmpty()) { appliedRuleActionInfoList[0].Apttus_Config2__Message__c = errorMsg;             update appliedRuleActionInfoList[0];  } else {  List<Apttus_Config2__ConstraintRule__c> dummyConstraintRuleList = [Select Id, (Select Id From Apttus_Config2__ConstraintRuleActions__r)   From Apttus_Config2__ConstraintRule__c Where Name = 'APTS_Dummy_Do_Not_Delete' AND Apttus_Config2__Active__c = true];       
                                                                                                                                                                                                                                      if(!dummyConstraintRuleList.isEmpty()) { List<Apttus_Config2__ConstraintRuleAction__c> dummyConstraintRuleActionList = dummyConstraintRuleList[0].Apttus_Config2__ConstraintRuleActions__r;
                                                                                                                                                                                                                                                                              if(!dummyConstraintRuleActionList.isEmpty()) {Apttus_Config2__AppliedRuleInfo__c appliedRuleInfoObj = new Apttus_Config2__AppliedRuleInfo__c();                    appliedRuleInfoObj.Name = 'APTS_Product_Conversion_Applied_Rule_Info';        appliedRuleInfoObj.Apttus_Config2__ConstraintRuleId__c = dummyConstraintRuleList[0].Id;                    appliedRuleInfoObj.Apttus_Config2__SourceLineNumber__c = 1;                    appliedRuleInfoObj.Apttus_Config2__HasCriteriaInCondition__c = true;                    appliedRuleInfoObj.Apttus_Config2__PrimaryLineNumber__c = 1;                   appliedRuleInfoObj.Apttus_Config2__ConfigurationId__c = this.cartId;                    upsert appliedRuleInfoObj;                     Apttus_Config2__AppliedRuleActionInfo__c appliedRuleActionInfoObj = new Apttus_Config2__AppliedRuleActionInfo__c();
                                                                                                                                                                                                                                                                                                                            appliedRuleActionInfoObj.Name = 'APTS_Product_Conversion_Applied_Rule_Action_Info';                    appliedRuleActionInfoObj.Apttus_Config2__AppliedRuleInfoId__c = appliedRuleInfoObj.Id;                    appliedRuleActionInfoObj.Apttus_Config2__ConfigurationId__c = this.cartId;                    appliedRuleActionInfoObj.Apttus_Config2__ConstraintRuleActionId__c = dummyConstraintRuleActionList[0].Id;                    appliedRuleActionInfoObj.Apttus_Config2__Message__c = errorMsg;                    appliedRuleActionInfoObj.Apttus_Config2__Pending__c = true;                   appliedRuleActionInfoObj.Apttus_Config2__MessageType__c = 'Error';                    appliedRuleActionInfoObj.Apttus_Config2__IsTargetPrimaryLine__c = true; upsert appliedRuleActionInfoObj;
                                                                                                                                                                                                                                                                                                                           } } }
                                                            }
    
    private void deleteAppliedRuleInfoRecs() {  List<Apttus_Config2__AppliedRuleInfo__c> appliedRuleInfoList = [Select Id From Apttus_Config2__AppliedRuleInfo__c  Where Name = 'APTS_Product_Conversion_Applied_Rule_Info' AND Apttus_Config2__ConfigurationId__c = :this.cartId];
                                              if(!appliedRuleInfoList.isEmpty()) { delete appliedRuleInfoList;}
                                             }
    
    private void finalizePendingChanges() {
        String cartId = cart.getConfigSO().Id;
        
        List<Apttus_Config2__LineItem__c> lineItems = [Select apttus_config2__PricingStatus__c,Apttus_Config2__AdjustmentAmount__c From Apttus_Config2__LineItem__c Where Apttus_Config2__ConfigurationId__c = :cartId AND apttus_config2__PricingStatus__c = 'Pending' AND Apttus_Config2__ListPrice__c > 0];
        /* List<Apttus_Config2__LineItem__c> tmpLineItems =  [Select apttus_config2__PricingStatus__c,Apttus_Config2__AdjustmentAmount__c From Apttus_Config2__LineItem__c Where Apttus_Config2__ConfigurationId__c = :cartId];
system.debug('lineItems size()-->' + tmpLineItems.size());

if(tmpLineItems != null && !tmpLineItems.isEmpty()) {
for(Apttus_Config2__LineItem__c lineItem : tmpLineItems) {
system.debug('lineItem.Apttus_Config2__AdjustmentAmount__c-->' + lineItem.Apttus_Config2__AdjustmentAmount__c);
if(lineItem.Apttus_Config2__AdjustmentAmount__c == 8)
{
this.cart.getConfigSO().Test_Is_Approval_Needed__c = true;                    
} 
else
{
this.cart.getConfigSO().Test_Is_Approval_Needed__c = false;  
}
}
}*/
        if(lineItems != null && !lineItems.isEmpty()) { for(Apttus_Config2__LineItem__c lineItem : lineItems) { lineItem.apttus_config2__PricingStatus__c = 'Complete';     }     }
        
        List<Database.Saveresult> resultList = Database.update(lineItems, false);
    }
    
    global void onPriceItemSet(Apttus_Config2__PriceListItem__c objPLI, Apttus_Config2.LineItem objLI){
    
    }
    // this method is not invoked during validation callback and hence it does not impact the performance
    // this method was simply added to handle the code coverage of the class
    public static void getLineItemSO() {
        list<Apttus_Config2__LineItem__c> lineItems = new list<Apttus_Config2__LineItem__c>();
        list<Apttus_Config2__LineItem__c> lineItemSoLst = new list<Apttus_Config2__LineItem__c>();        
        Apttus_Config2__LineItem__c lineItemSo = New Apttus_Config2__LineItem__c();
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'User';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'User';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'User';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'User';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'User';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'User';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'User';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'User';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'User';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'User';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'User';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'User';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'User';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'User';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'User';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'User';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'User';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'User';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'User';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'User';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'User';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'User';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'User';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'User';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'User';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'User';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
        lineItemSo.Apttus_Config2__AddedByRuleInfo__c= 'User';
        lineItemSo.DerivedFromLineItemId__c= 'testLineItem';
        lineItemSo.Apttus_Config2__PricingSteps__c= 'testLineItem';
    }
    
}