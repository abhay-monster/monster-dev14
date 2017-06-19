@isTest
private class APTS_PricingCallBackTest2 {
	static testMethod void newScenario() {

        Product2 prod = new Product2(Name = 'Laptop X200', 
            Family = 'Hardware');
        insert prod;
        
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id pricebookId = Test.getStandardPricebookId();
        
        // 1. Insert a price book entry for the standard price book.
        // Standard price book entries require the standard price book ID we got earlier.
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        // Create a custom price book
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        // 2. Insert a price book entry with a custom price.
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = prod.Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice;

        Apttus_Config2__ConfigCustomClasses__c customSettingClasses=new Apttus_Config2__ConfigCustomClasses__c(Name='System Propoerties',Apttus_Config2__PricingCallbackClass__c='APTS_PricingCallBack');
        insert customSettingClasses;
        
        
        Apttus_Config2__ConfigSystemProperties__c custprop = new Apttus_Config2__ConfigSystemProperties__c();
        custprop.Name = 'System Properties';
        custprop.Apttus_Config2__ViewCartCustomFields__c = 'Apttus_Config2__ConfigurationId__c,Apttus_Config2__ProductId__r.ProductCode';
        custprop.Apttus_Config2__ViewCartCustomFields2__c = 'Apttus_Config2__ProductId__c,AgencyCommission__c,APTS_Product_Service_Type__c,APTS_Is_Default_Adjustment_Done__c,APTS_Is_Trial_Product__c,Quantity_Backup__c,DerivedFromLineItemId__c';
        insert custprop;
        
        list<Product2> ListOfProd = new list<Product2>();
        ListOfProd.add(new product2(Name='Product1',ProductCode='1',Apttus_Config2__ConfigurationType__c='Standalone',Family='Maintenance'));
        ListOfProd.add(new product2(Name='Product2',ProductCode='2',Apttus_Config2__ConfigurationType__c='Standalone',Family='Professional Services'));
        ListOfProd.add(new product2(Name='Product3',ProductCode='3',Apttus_Config2__ConfigurationType__c='Standalone',Family='Third Party Software'));
        insert ListOfProd;
        
        Account accSO = insertAccount();
        insert accSO;

        Opportunity opptySO = insertOppty(accSO);
        insert opptySO;

        Apttus_Config2__PriceList__c plSO = insertPriceList();
        insert plSO;

        List<Apttus_Config2__PriceListItem__c> pliSOList = new List<Apttus_Config2__PriceListItem__c>();
        pliSOList.add(insertPriceListItem(plSO,ListOfProd[0], 10, 'Maintenance Fee', 'Recurring', 'Per Unit', null,null,null,null,null ));
        pliSOList.add(insertPriceListItem(plSO,ListOfProd[1], 20, 'License Fee', 'Recurring', 'Per Unit', null,null,null,null,null ));
        pliSOList.add(insertPriceListItem(plSO,ListOfProd[2], 30, 'License Fee', 'Recurring', 'Per Unit', null,null,null,null,null ));
        insert pliSOList;

        Apttus_Proposal__Proposal__c propSO = insertQuoteProposal(accSO, opptySO, plSO, null);
        propSO.Apttus_Proposal__Primary__c = True;
        insert propSO;  

        Apttus_Config2__ProductConfiguration__c pcSO=insertProductConfiguration(propSO,'New',plSO,accSO);
        insert pcSO;
        Id cartID=pcSO.Id;
        Apttus_Config2__TempObject__c toSO=insertTempObj(pcSO);
        insert toSO;

        Apttus_Config2__AssetLineItem__c aliSObh=insertAssetLineItem(ListOfProd[0],null,pliSOList[0] ,accSO,'Product/Service',1,1,1,null,null,0,0,0,1,System.today().addDays(-100),System.today().addDays(265)); //@TODO put start/end dates
        insert aliSObh;                                                                

        List<Apttus_Config2__LineItem__c> liSOList = new List<Apttus_Config2__LineItem__c>();
        liSOList.add(insertLineItem(ListOfProd[0], null, cartID, 1, 1, 1, 'Product/Service', plSO, pliSOList[0], true, null,1,'New',null,System.today(),System.today().addDays(365)));
        liSOList.add(insertLineItem(ListOfProd[1], null, cartID, 1, 1, 1, 'Product/Service', plSO, pliSOList[1], true, null,1,'New',null,System.today(),System.today().addDays(365)));
        liSOList.add(insertLineItem(ListOfProd[2], null, cartID, 1, 1, 1, 'Product/Service', plSO, pliSOList[2], true, null,1,'New',null,System.today(),System.today().addDays(365)));
        insert liSOList;

        for(integer i = 0; i < 3; i++){
            //Apttus_Config2.PricingWebService.computeBasicPriceForItemColl(pcSO,new List<Apttus_Config2__LineItem__c>{liSOList[i]});
            Apttus_Config2.PricingWebService.computeNetPriceForItemColl(cartID,i);
        }
        
        Apttus_Config2.CPQWebService.finalizeConfiguration(cartID);
        propSo.Apttus_QPConfig__ConfigurationFinalizedDate__c = DateTime.now();
        update propSo;

    }
     private static Account insertAccount() {
        Account accSO = new Account();
        accSO.NAME = 'Test Account';
        accSO.Industry='Airlines';
        accSO.Type='Active Customer Account';
        return accSO;
    }

    private static Opportunity insertOppty(Account accSO) {
        Opportunity opptySO = new Opportunity();
        opptySO.Name = 'Test Oppty';
        opptySO.AccountId = accSO.ID;
        opptySO.CloseDate = Date.today();
        opptySO.StageName = '2-Discover';
        opptySO.ForecastCategoryName = 'Commit';
        opptySO.Type = 'New Logo';
        opptySO.LeadSource= 'Aspect AE Prospecting';
        opptySO.NextStep='Call';
        return opptySO;
    }
    private static Apttus_Config2__PriceList__c insertPriceList() {
        Apttus_Config2__PriceList__c plSO = new Apttus_Config2__PriceList__c();
        plSO.NAME = 'Test PriceList';
        return plSO;
    }   

    private static Apttus_Config2__PriceListItem__c insertPriceListItem(Apttus_Config2__PriceList__c plSO, Product2 prodSO, Decimal listPrice, string cType,String priceType, String priceMethod,
                                                                            String relatedAdjType, Decimal relatedAdjAmt, String relatedAdjAmtAppliesTo, String priceListGrouping, Decimal defaultQuant) {
        Apttus_Config2__PriceListItem__c pliSO = new Apttus_Config2__PriceListItem__c();
        pliSO.Apttus_Config2__Active__c = true;
        pliSO.Apttus_Config2__PriceType__c = 'One Time';
        if(priceType=='Recurring'){
          pliSO.Apttus_Config2__Frequency__c = 'Yearly';
        }
        pliSO.Apttus_Config2__ListPrice__c = listPrice;
        pliSO.Apttus_Config2__PriceListId__c = plSO.ID;
        pliSO.Apttus_Config2__PriceMethod__c = priceMethod;
        pliSO.Apttus_Config2__PriceUom__c = 'Each';
        pliSO.Apttus_Config2__ProductId__c = prodSO.ID;
        pliSO.Apttus_Config2__ChargeType__c = cType;
        pliSO.Apttus_Config2__RelatedAdjustmentType__c=relatedAdjType;
        pliSO.Apttus_Config2__RelatedAdjustmentAmount__c=relatedAdjAmt;
        pliSO.Apttus_Config2__RelatedAdjustmentAppliesTo__c=relatedAdjAmtAppliesTo;
        pliSO.Apttus_Config2__DefaultQuantity__c= defaultQuant;
        return pliSO;
    }    

    private static Apttus_Proposal__Proposal__c insertQuoteProposal(Account accSO, Opportunity opptySO, Apttus_Config2__PriceList__c plSO, Contact contSO) {
        Apttus_Proposal__Proposal__c propSO = new Apttus_Proposal__Proposal__c();
        propSO.Apttus_Proposal__Proposal_Name__c = 'Test Proposal';
        propSO.Apttus_Proposal__Account__c = accSO.ID;
        propSO.Apttus_Proposal__Opportunity__c =opptySO.ID;
        propSO.Apttus_QPConfig__PriceListId__c = plSO.ID;
        propSO.Apttus_Proposal__Valid_Until_Date__c=Date.today();
        //propSO.License_Term__c='Perpetual';
        propSO.Apttus_Proposal__Approval_Stage__c='Draft';
        return propSO;
    }    
    private static Apttus_Config2__ProductConfiguration__c insertProductConfiguration(Apttus_Proposal__Proposal__c propSO,String status,Apttus_Config2__PriceList__c plSO, Account acctSO){
        Apttus_Config2__ProductConfiguration__c pcSO=new Apttus_Config2__ProductConfiguration__c();
        pcSO.Apttus_Config2__BusinessObjectId__c=propSO.Id;
        pcSO.Apttus_QPConfig__Proposald__c=propSO.Id;
        pcSO.Apttus_Config2__BusinessObjectType__c='Proposal';
        pcSO.Apttus_Config2__PriceListId__c=plSO.Id;
        pcSO.Apttus_Config2__EffectivePriceListId__c=plSO.Id;
        pcSO.Apttus_Config2__Status__c=status;
        pcSO.Apttus_Config2__AccountId__c=acctSO.Id;
        pcSO.Apttus_Config2__VersionNumber__c=1;
        pcSO.Name='Test';
        return pcSO;
    }

    private static Apttus_Config2__TempObject__c insertTempObj(Apttus_Config2__ProductConfiguration__c pcSO){
        Apttus_Config2__TempObject__c toSO=new Apttus_Config2__TempObject__c();
        toSO.Apttus_Config2__ConfigurationId__c=pcSO.Id;
        return toSO;
    }
    private static Apttus_Config2__LineItem__c insertLineItem(Product2 prodSO, Product2 optProdSO, ID cartID, Decimal itemSeq, Decimal lineNum, Decimal primaryLineNum, 
                                                                        string lineType, Apttus_Config2__PriceList__c plSO, Apttus_Config2__PriceListItem__c pliSO, 
                                                                        Boolean isPrimaryLine, Decimal parentBundleLineNumber, Decimal quant, String lineStatus, Apttus_Config2__AssetLineItem__c aliSO,
                                                                        Date startDate, Date endDate) {
        Apttus_Config2__LineItem__c liSO = new Apttus_Config2__LineItem__c();
        liSO.Apttus_Config2__ConfigurationId__c = cartID;
        liSO.Apttus_Config2__ProductId__c = prodSO.ID;
        if(optProdSO != null) {
            liSO.Apttus_Config2__OptionId__c = optProdSO.ID;
        }
        //liSO.Apttus_Config2__Quantity__c = 1;
        liSO.Apttus_Config2__ChargeType__c = pliSO.Apttus_Config2__ChargeType__c;
        liSO.Apttus_Config2__IsPrimaryLine__c = isPrimaryLine;
        liSO.Apttus_Config2__IsPrimaryRampLine__c = true;
        liSO.Apttus_Config2__ItemSequence__c = itemSeq;
        liSO.Apttus_Config2__LineNumber__c  = lineNum;
        liSO.Apttus_Config2__PrimaryLineNumber__c = primaryLineNum;
        liSO.Apttus_Config2__LineStatus__c = lineStatus;
        liSO.Apttus_Config2__LineType__c = lineType;
        liSO.Apttus_Config2__StartDate__c = startDate;
        liSO.Apttus_Config2__EndDate__c = endDate;
        liSO.Apttus_Config2__SellingTerm__c = 1;
        liSO.Apttus_Config2__PriceListId__c = plSO.ID;
        liSO.Apttus_Config2__PriceListItemId__c = pliSO.ID;
        liSO.Apttus_Config2__PriceType__c = pliSO.Apttus_Config2__PriceType__c;
        liSO.Apttus_Config2__PriceMethod__c = pliSO.Apttus_Config2__PriceMethod__c;
        liSO.Apttus_Config2__SellingFrequency__c = pliSO.Apttus_Config2__PriceMethod__c;
        liSO.Apttus_Config2__PricingStatus__c = 'Pending';
        liSO.Apttus_Config2__ListPrice__c = pliSO.Apttus_Config2__ListPrice__c;
        liSO.Apttus_Config2__BasePrice__c = pliSO.Apttus_Config2__ListPrice__c;
        liSO.Apttus_Config2__ExtendedPrice__c = pliSO.Apttus_Config2__ListPrice__c;
        liSO.Apttus_Config2__NetPrice__c = pliSO.Apttus_Config2__ListPrice__c;
        if(parentBundleLineNumber != null) {
            liSO.Apttus_Config2__ParentBundleNumber__c = parentBundleLineNumber;
        }
        liSO.Apttus_Config2__Quantity__c=quant;
        if(aliSO!=null){
            liSO.Apttus_Config2__AssetLineItemId__c=aliSO.Id;
            liSO.Apttus_Config2__AssetQuantity__c=aliSO.Apttus_Config2__Quantity__c;
        }
        return liSO;
    }    

    private static Apttus_Config2__AssetLineItem__c insertAssetLineItem(Product2 prodSO, Product2 optProdSO, Apttus_Config2__PriceListItem__c pliSO, Account acctSO,String lineType, 
                                                                            Decimal itemSeq, Decimal lineNum, Decimal quant, Integer parentBundleNum, Apttus_Config2__AssetLineItem__c bundleAsset,
                                                                            Decimal basePrice, Decimal extendedPrice, Decimal netPrice, Decimal sellingTerm,Date startDate, Date endDate){
        Apttus_Config2__AssetLineItem__c aliSO=new Apttus_Config2__AssetLineItem__c();
        aliSO.Apttus_Config2__ProductId__c=prodSO.Id;
        if(optProdSO!=null){
            aliSO.Apttus_Config2__OptionId__c=optProdSO.Id;
        }
        aliSO.Apttus_Config2__AccountId__c=acctSO.Id;
        aliSO.Apttus_Config2__LineType__c=lineType;
        aliSO.Apttus_Config2__ChargeType__c=pliSO.Apttus_Config2__ChargeType__c;
        aliSO.Apttus_Config2__ItemSequence__c=itemSeq;
        aliSO.Apttus_Config2__LineNumber__c=lineNum;
        aliSO.Apttus_Config2__Quantity__c=quant;
        aliSO.Apttus_Config2__AssetStatus__c='New';
        aliSO.Apttus_Config2__ParentBundleNumber__c=parentBundleNum;
        //aliSO.Apttus_Config2__AttributeValueId__c =prodAttrVal.Id;
        if(parentBundleNum==null){
            //aliSO.Apttus_Config2__HasAttributes__c=true;
            aliSO.Apttus_Config2__HasOptions__c=true;
        }
        if(bundleAsset!=null){
            aliSO.Apttus_Config2__BundleAssetId__c=bundleAsset.Id;
        }
        aliSO.Apttus_Config2__PriceType__c = pliSO.Apttus_Config2__PriceType__c;
        aliSO.Apttus_Config2__PriceMethod__c = pliSO.Apttus_Config2__PriceMethod__c;
        aliSO.Apttus_Config2__SellingFrequency__c = pliSO.Apttus_Config2__Frequency__c;
        aliSO.Apttus_Config2__ListPrice__c = pliSO.Apttus_Config2__ListPrice__c;
        aliSO.Apttus_Config2__BasePriceMethod__c = 'Per Unit';
        aliSO.Apttus_Config2__BasePrice__c = basePrice;
        aliSO.Apttus_Config2__ExtendedPrice__c = extendedPrice;
        aliSO.Apttus_Config2__NetPrice__c = netPrice;
        aliSO.Apttus_Config2__SellingTerm__c=sellingTerm;
        aliSO.Apttus_Config2__StartDate__c=startDate;
        aliSO.Apttus_Config2__EndDate__c=endDate;
        //remember get base price and all from pli
        return aliSO;
    }
}