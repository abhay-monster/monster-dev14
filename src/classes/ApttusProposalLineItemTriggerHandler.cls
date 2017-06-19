/*
** @author : Cloud Sherpas Inc.
** @date : 06/30/2014
** @description : Apttus_Proposal__Proposal_Line_Item__c trigger class to handle CRUD events.
*/
public class ApttusProposalLineItemTriggerHandler extends BaseTriggerHandler{

    final String CLASSNAME = '\n\n**** ApttusProposalLineItemTriggerHandler.METHODNAME()';
    private integer BatchSize = 0;
    private TriggerHelper helper;
    private static Integer RunCount = 0;
    private ApttusProposalLineItemTriggerHelper lineItemHelper;
    public static Boolean ExecuteTriggers = true;// changes for locking issue in echosign
    /*
** @author : Cloud Sherpas Inc.
** @date : 06/30/2014
** @description : the class constructor method
** @paramaters : a Boolean value indicating if a trigger is executing or not, an Integer value indicating the number of records in the batch/list
** @returns : nothing
** @sample call : ApttusProposalLineItemTriggerHandler handler = new ApttusProposalLineItemTriggerHandler(Trigger.isExecuting, Trigger.size);
*/
    public ApttusProposalLineItemTriggerHandler(boolean isExecuting, integer pTriggerSize){

        // trigger is executing
        TriggerIsExecuting = isExecuting;

        // set batch size
        BatchSize = pTriggerSize;//

        // intantiate new trigger helper
        lineItemHelper = ApttusProposalLineItemTriggerHelper.NewTriggerHelper();
        /*
note - developer may want to create new or extent the base helper class specific to an sObject (i.e. AccountTriggerHelper)
*/
    }

    /*
** @author : Cloud Sherpas Inc.
** @date : 04/09/2014
** @description :  this method handles the 'before insert' event for the trigger; it's purpose is to ...
** @paramaters : an array of Apttus_Proposal__Proposal_Line_Item__c objects
** @returns : nothing
*/
    public void OnBeforeInsert(Apttus_Proposal__Proposal_Line_Item__c[] pApttusProposalLineItemList){
        if (Personal_Settings__c.getInstance().Trigger_Quote__c ==false){
            return; // If triggers are off, then exit the method
        }        








        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        //system.debug('IsTriggerContext :'+ IsTriggerContext+'\n IsVisualforcePageContext : '+IsVisualforcePageContext);
        //system.debug('IsWebServiceContext : '+IsWebServiceContext+'\n IsExecuteAnonymousContext : '+IsExecuteAnonymousContext);


        //try{
        //if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
        //update Attribute Display on Proposal Line Item  with its product Attributes having  Show_on_Report__c = True
        lineItemHelper.AttributeDisplayPLI(pApttusProposalLineItemList);
        lineItemHelper.SalesCredit(pApttusProposalLineItemList);    //S-386409
        setPartnerRevenueShareOnLineItems(pApttusProposalLineItemList);
        populateAgencyCommision(pApttusProposalLineItemList);
        
        //}

       
        
        //}
        /*catch(BaseApplicationException bae){
throw bae;
}
catch(Exception ex){
throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
}*/
    }



    public void setPartnerRevenueShareOnLineItems(Apttus_Proposal__Proposal_Line_Item__c[] pApttusProposalLineItemList){

        set<string> productFamilySet = new Set<string>();
        set<string> siteChannelds = new Set<string>();
        set<string> agencylds = new Set<string>();
        


        map<string,string> maplineItem = new map<string,string>();
        map<string, string> mapProdFamilyToPartner = new map<string, string>();
        map<string, Decimal> mapRevenueSharePartner = new map<string, Decimal>();
        for(Apttus_Proposal__Proposal_Line_Item__c lineItem : pApttusProposalLineItemList) {

            if(lineItem.Apttus_Proposal__Proposal__c != null) {
                maplineItem.put(lineItem.Id, lineItem.Apttus_Proposal__Proposal__c);
            }

            if(lineItem.ProductFamily__c != null){
                productFamilySet.add(lineItem.ProductFamily__c);
            }
        }
        System.debug('@@==productFamilySet===='+productFamilySet);
        System.debug('@@==maplineItem.values===='+maplineItem.values());
        map<Id, Apttus_Proposal__Proposal__c> proposalMap = new map<Id, Apttus_Proposal__Proposal__c> ([Select Id , Agency__c,Site_Channel_ID__c
                                                                                                        from Apttus_Proposal__Proposal__c Where Id IN :maplineItem.values()]);

        for(Apttus_Proposal__Proposal__c p : proposalMap.values()){
            if(p.Site_Channel_ID__c != null){
                siteChannelds.add(p.Site_Channel_ID__c);
            }else if(p.Agency__c != null){
                agencylds.add(p.Agency__c);
            }
        }

        System.debug('@@==siteChannelds===='+siteChannelds);

        for(Partner_Revenue_Share__c partnerRevenueShare : [Select Id, Product_Family__c, SiteChannelID__c,Partner__c,RevenueShare__c from Partner_Revenue_Share__c
                                                            Where Product_Family__c IN :productFamilySet and (SiteChannelID__c IN :siteChannelds OR Partner__c in :agencylds)] ) {

                                                                mapProdFamilyToPartner.put(partnerRevenueShare.Product_Family__c+partnerRevenueShare.SiteChannelID__c, partnerRevenueShare.Id);
                                                                mapRevenueSharePartner.put(partnerRevenueShare.Product_Family__c+partnerRevenueShare.SiteChannelID__c,partnerRevenueShare.RevenueShare__c);
                                                                
                                                                //Partner
                                                                mapProdFamilyToPartner.put(partnerRevenueShare.Product_Family__c+partnerRevenueShare.Partner__c, partnerRevenueShare.Id);
                                                                mapRevenueSharePartner.put(partnerRevenueShare.Product_Family__c+partnerRevenueShare.Partner__c,partnerRevenueShare.RevenueShare__c);
                                                            }

        System.debug('@@==mapProdFamilyToPartner===='+mapProdFamilyToPartner);

        for(Apttus_Proposal__Proposal_Line_Item__c lineItem : pApttusProposalLineItemList) {
            string key = '';
            if(lineItem.ProductFamily__c != null){
                key = lineItem.ProductFamily__c;
            }

            if(lineItem.Apttus_Proposal__Proposal__c != null && proposalMap.containsKey(lineItem.Apttus_Proposal__Proposal__c)){
                if(proposalMap.get(lineItem.Apttus_Proposal__Proposal__c).Site_Channel_ID__c != null) {
                    key += proposalMap.get(lineItem.Apttus_Proposal__Proposal__c).Site_Channel_ID__c;
                }else if(proposalMap.get(lineItem.Apttus_Proposal__Proposal__c).Agency__c != null){
                    key += proposalMap.get(lineItem.Apttus_Proposal__Proposal__c).Agency__c;
                }
            }

            System.debug('@@==key===='+key);

            if(mapProdFamilyToPartner.containsKey(key)) {
                lineItem.Partner_Revenue_Share__c  =  mapProdFamilyToPartner.get(key);
                lineItem.Revenue_Share_Percent__c = mapRevenueSharePartner.get(key);
                System.debug('@@==lineItem.Partner_Revenue_Share__c===='+lineItem.Partner_Revenue_Share__c);
            }

        }


    }

    /*
** @author : Cloud Sherpas Inc.
** @date : 06/30/2014
** @description :  this method handles the 'after insert' event for the trigger; it's purpose is to ...
** @paramaters : an array of Account objects
** @returns : nothing
*/
    public void OnAfterInsert(Apttus_Proposal__Proposal_Line_Item__c[] pUpdatedLineItems, map<ID, Apttus_Proposal__Proposal_Line_Item__c> pLineItemsIdToOldLineItemsMap , map<ID, Apttus_Proposal__Proposal_Line_Item__c> pLineItemsIdToNewLineItemsMap){
        if (Personal_Settings__c.getInstance().Trigger_Quote__c ==false){
            return; // If triggers are off, then exit the method
        }






        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        try{
            //if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){

            //lineItemHelper.updateChildPostingLocation(pUpdatedLineItems, pLineItemsIdToOldLineItemsMap);

             lineItemHelper.Terms_and_Condition_on_proposal(pUpdatedLineItems);

             syncLineItemsWithOpportunityLineItems(pUpdatedLineItems , pLineItemsIdToNewLineItemsMap);

             //Update By Vivek for T-435062
              // set Opportunity International Deal checkbox
              setOptyInternationalDeal(pUpdatedLineItems, pLineItemsIdToOldLineItemsMap);

              

            /*
note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
and call the methods from handler.
*/
            
            //}
        }
        catch(BaseApplicationException bae){
            throw bae;
        }
        catch(Exception ex){
            system.debug(LoggingLevel.DEBUG, METHODNAME + ' :: ERROR MESSAGE = ' + ex.getMessage() + '\n\n Line Item'+ex.getLineNumber());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }
        //Update By Vivek for T-435062
        // set Opportunity International Deal checkbox
        //setOptyInternationalDeal(pUpdatedLineItems);
        System.debug('----End of ApttusProposalLineItemTriggerHandler.OnAfterInsert');
    }

    public void OnBeforeDelete(Apttus_Proposal__Proposal_Line_Item__c[] pApttusProposalLineItemList ){

        list<OpportunityLineItem> lstOppLineItems= [SELECT Product2Id ,
                                                    PricebookEntryId ,
                                                    OpportunityId ,
                                                    Proposal_Line_Item__c ,
                                                    TotalPrice
                                                    FROM OpportunityLineItem
                                                    where Proposal_Line_Item__c IN : pApttusProposalLineItemList
                                                    and Order_Line_Item_Custom__c = Null];
        if(lstOppLineItems.size() > 0)
            delete lstOppLineItems;
    }

    public static void syncLineItemsWithOpportunityLineItems(Apttus_Proposal__Proposal_Line_Item__c[] newLineItems , Map<id ,Apttus_Proposal__Proposal_Line_Item__c> mapNewProposalLineItems ){


        set<id> setOpportunityIds = new set<id>();
        set<id> setProducts = new set<id>();
        set<string> oppCurrencyISOCode = new set<string>();
        list<OpportunityLineItem> lstOppLineItemToUpdate = new list<OpportunityLineItem>();
        list<OpportunityLineItem> lstOppLineItemToInsert = new list<OpportunityLineItem>();
        list<OpportunityLineItem> lstOppLineItemToDelete = new list<OpportunityLineItem>();
        String sIsoCode;

        system.debug('hi Im Here');

        try{
             list<Apttus_Proposal__Proposal_Line_Item__c> lstUpdatedProposalLineItems=null;
            //I-211343 changes
            if(mapNewProposalLineItems!=null && mapNewProposalLineItems.size()>0)
            {
                lstUpdatedProposalLineItems = [SELECT Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__c ,
                                                                                    Apttus_Proposal__Product__c ,Apttus_QPConfig__OptionId__c, Apttus_QPConfig__HasOptions__c,
                                                                                    Gross_Total__c ,
                                                                                    Net_Total__c ,
                                                                                    Apttus_Proposal__Proposal__r.Organization__c,
                                                                                    Quantity1__c ,
                                                                                    Apttus_Proposal__Proposal__c,
                                                                                    Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__r.CurrencyIsoCode,
                                                                                    Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__r.Organization__c,
                                                                                    Apttus_QPConfig__IsOptionRollupLine__c,
                                                                                    Sales_Credit__c  ,
                                                                                    Apttus_Proposal__Proposal__r.CurrencyIsoCode
                                                                                    From Apttus_Proposal__Proposal_Line_Item__c where
                                                                                    id IN :newLineItems
                                                                                    AND Apttus_Proposal__Product__c != null
                                                                                    AND Apttus_Proposal__Proposal__r.Apttus_Proposal__Primary__c = True];
            }
            else
            {
                lstUpdatedProposalLineItems = [SELECT Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__c ,
                                                                                    Apttus_Proposal__Product__c ,Apttus_QPConfig__OptionId__c, Apttus_QPConfig__HasOptions__c,
                                                                                    Gross_Total__c ,
                                                                                    Net_Total__c ,
                                                                                    Apttus_Proposal__Proposal__r.Organization__c,
                                                                                    Quantity1__c ,
                                                                                    Apttus_Proposal__Proposal__c,
                                                                                    Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__r.CurrencyIsoCode,
                                                                                    Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__r.Organization__c,
                                                                                    Apttus_QPConfig__IsOptionRollupLine__c,
                                                                                    Sales_Credit__c,
                                                                                    Apttus_Proposal__Proposal__r.CurrencyIsoCode
                                                                                    From Apttus_Proposal__Proposal_Line_Item__c where
                                                                                    id IN :newLineItems
                                                                                    AND Apttus_Proposal__Product__c != null];
            }
            //system.assert(false , lstUpdatedProposalLineItems);

        if(lstUpdatedProposalLineItems.size() > 0) {

            system.debug('Hi I Entered into the loop');
            for(Apttus_Proposal__Proposal_Line_Item__c proposalLineItem : lstUpdatedProposalLineItems){
                setOpportunityIds.add(proposalLineItem.Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__c);
                if(proposalLineItem.Apttus_QPConfig__OptionId__c != null)
                    setProducts.add(proposalLineItem.Apttus_QPConfig__OptionId__c);
                else
                    setProducts.add(proposalLineItem.Apttus_Proposal__Product__c);
                
                //////////////////////////
                if(proposalLineItem.Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__r.CurrencyIsoCode != null && 
                   proposalLineItem.Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__r.CurrencyIsoCode != '')
                oppCurrencyISOCode.add(proposalLineItem.Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__r.CurrencyIsoCode);
                else
                  oppCurrencyISOCode.add(proposalLineItem.Apttus_Proposal__Proposal__r.CurrencyIsoCode);  
                
                sIsoCode = proposalLineItem.Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__r.CurrencyIsoCode;
            }

            List<PriceBookEntry> priceBookList1 = [SELECT Id, Product2Id, Product2.Id, Product2.Name, IsActive,
                                                              Product2.ProductCode, Product2.Description
                                                   FROM PriceBookEntry WHERE Product2Id IN : setProducts
                                                   AND PriceBook2.isStandard=true
                                                   AND CurrencyIsoCode IN:oppCurrencyISOCode
                                                  ];

            map <id,id> mapProductPricebook1 = new map < id , id >();
            map<id, boolean> mapPriceBookActive = new map <Id,Boolean>();
            map<id, string> mapPriceBookProductCode = new map <Id,string>();
            map<id, string> mapPriceBookDescription = new map <Id,string>();

            for(PriceBookEntry pBE1 : priceBookList1){
                system.debug('***priceBookList1 pBE1: '+pBE1 + ', Product2.Name='+pBE1.Product2.Name+', Product2.ProductCode='+pBE1.Product2.ProductCode+', Product2.Description='+pBE1.Product2.Description);
                if(!mapPriceBookActive.containskey(pBE1.Product2Id))
                {
                    mapProductPricebook1.put(pBE1.Product2Id ,  pBE1.id );
                    mapPriceBookActive.put(pBE1.Product2Id, pBE1.IsActive);
                    mapPriceBookProductCode.put(pBE1.Product2Id, pBE1.Product2.ProductCode);
                    mapPriceBookDescription.put(pBE1.Product2Id, pBE1.Product2.Description);
                }

            }

            List<PriceBookEntry> priceBookListToUpdate = new List<PriceBookEntry>();
            PriceBookEntry PriceBookEntryToUpdate = new PriceBookEntry();

            List<PriceBookEntry> priceBookListToUpsert = new List<PriceBookEntry>();
            PriceBookEntry PriceBookEntryToUpsert = new PriceBookEntry();

            //Query for the standard Pricebook
            list<pricebook2> stdpricebooklist=[select id,name
                                               from pricebook2
                                               where name='Standard Price Book' limit 1];
            system.debug('stdpricebooklist***'+stdpricebooklist);
            for(ID productID : setProducts)
            {
                if(mapPriceBookActive.containskey(productID) &&
                  (mapPriceBookProductCode.get(productID) == 'QUOTE BUNDLE' ||
                   mapPriceBookDescription.get(productID) == 'Oppty Forecasting Product')
                  ){
                   system.debug('***Ignoring bundle header record: ProductID='+productID+', ID='+mapProductPricebook1.get(productID)+' ProductCode='+mapPriceBookProductCode.get(productID)+', Description='+mapPriceBookDescription.get(productID));
                }
                else if(mapPriceBookActive.containskey(productID) && mapPriceBookActive.get(productID) == false)
                {
                    PriceBookEntryToUpsert.Id = mapProductPricebook1.get(productID);
                    PriceBookEntryToUpsert.IsActive = true;
                    system.debug('***Setting to active (existing) ID='+PriceBookEntryToUpsert.Id);
                    priceBookListToUpsert.add(PriceBookEntryToUpsert);
                }
                else if(!mapPriceBookActive.containskey(productID))
                {
                    PriceBookEntryToUpsert.Product2Id = productID;
                    PriceBookEntryToUpsert.IsActive = true;
                    system.debug('***Setting to active (new) ID='+PriceBookEntryToUpsert.Id);
                    PriceBookEntryToUpsert.CurrencyIsoCode = sIsoCode;
                    PriceBookEntryToUpsert.UnitPrice = 0;
                    if(!stdpricebooklist.isEmpty())
                        PriceBookEntryToUpsert.Pricebook2Id = stdpricebooklist[0].id;
                    
                    if(PriceBookEntryToUpsert.Product2Id !=null && PriceBookEntryToUpsert.CurrencyIsoCode!=null )
                    priceBookListToUpsert.add(PriceBookEntryToUpsert);

                    PriceBookEntryToUpsert = new PriceBookEntry();
                }
            }
            upsert priceBookListToUpsert;
            system.debug('priceBookListToUpsert'+priceBookListToUpsert);

            List<PriceBookEntry> priceBookList = [SELECT Id, Product2Id, Product2.Id, Product2.Name,IsActive
                                                  FROM PriceBookEntry WHERE Product2Id IN : setProducts
                                                  AND PriceBook2.isStandard=true
                                                  AND CurrencyIsoCode IN:oppCurrencyISOCode
                                                 ];
            map <id,id> mapProductPricebook = new map < id , id >();
            for(PriceBookEntry pBE : priceBookList){
                if(!mapProductPricebook.containskey(pBE.Product2Id))
                {
                    mapProductPricebook.put(pBE.Product2Id ,  pBE.id );
                }

            }
            system.debug('mapProductPricebook'+mapProductPricebook);
            //Finding if there any exisitng Opp Products
            Map<id , OpportunityLineItem> mapOppLineItems= new Map<id , OpportunityLineItem>([SELECT Product2Id ,
                                                                                              PricebookEntryId ,
                                                                                              OpportunityId ,
                                                                                              Proposal_Line_Item__c ,
                                                                                              TotalPrice
                                                                                              FROM OpportunityLineItem
                                                                                              where OpportunityId IN : setOpportunityIds
                                                                                              /*AND Proposal_Line_Item__c IN:lstUpdatedProposalLineItems*/]);
            Boolean flagToDelete;

            Map<id , list<OpportunityLineItem>> mapOppToOppLineItems = new Map<id , list<OpportunityLineItem>>();
            for(OpportunityLineItem oppLineItem : mapOppLineItems.values()){

                if(!mapOppToOppLineItems.containskey(oppLineItem.OpportunityId))
                    mapOppToOppLineItems.put(oppLineItem.OpportunityId , new list<OpportunityLineItem>());

                mapOppToOppLineItems.get(oppLineItem.OpportunityId).add(oppLineItem);

                //Delete Opp line items which are not related to any of the proposal line items
                flagToDelete=true;
                for(Apttus_Proposal__Proposal_Line_Item__c proposalLineItem : lstUpdatedProposalLineItems){
                    if(oppLineItem.Proposal_Line_Item__c == proposalLineItem.id)
                        flagToDelete=false;
                }
                if(flagToDelete){
                    lstOppLineItemToDelete.add(oppLineItem);
                    system.debug('^^^Flagging for Deletion oppLineItem='+oppLineItem);
                }
            }

            // Insert / Update the opp Line Items

            OpportunityLineItem  oppLineItemToInsert;
            Boolean flagToInsert ;

            for(Apttus_Proposal__Proposal_Line_Item__c proposalLineItem : lstUpdatedProposalLineItems){
                flagToInsert = True ;
                if(mapOppToOppLineItems.containskey(proposalLineItem.Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__c)){
                    for(OpportunityLineItem oppLineItem : mapOppToOppLineItems.get(proposalLineItem.Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__c)){

                        if(oppLineItem.Proposal_Line_Item__c == proposalLineItem.id){
                            flagToInsert = false ;

                            oppLineItem.Proposal_Line_Item__c = proposalLineItem.Id;
                            
                            if(proposalLineItem.Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__r.Organization__c == 'North America')
                                oppLineItem.TotalPrice =   proposalLineItem.Net_Total__c;
                            else
                                oppLineItem.TotalPrice =   proposalLineItem.Gross_Total__c;
                            oppLineItem.Quantity = proposalLineItem.Quantity1__c;
                            lstOppLineItemToUpdate.add(oppLineItem);
                        }

                    }
                }

                if(flagToInsert == True){
                    //I-191905
                    if( (proposalLineItem.Apttus_QPConfig__OptionId__c == null && mapProductPricebook.containsKey(proposalLineItem.Apttus_Proposal__Product__c)) ||
                            (proposalLineItem.Apttus_QPConfig__OptionId__c != null && mapProductPricebook.containsKey(proposalLineItem.Apttus_QPConfig__OptionId__c))){
                        if(proposalLineItem.Apttus_QPConfig__HasOptions__c == false && proposalLineItem.Apttus_QPConfig__IsOptionRollupLine__c == false
                          && proposalLineItem.Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__c != null)
                        {
                            oppLineItemToInsert = new OpportunityLineItem();
                            oppLineItemToInsert.OpportunityId = proposalLineItem.Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__c ;

                            if(proposalLineItem.Apttus_QPConfig__OptionId__c != null)
                                oppLineItemToInsert.PricebookEntryId = mapProductPricebook.get(proposalLineItem.Apttus_QPConfig__OptionId__c);
                            else
                                oppLineItemToInsert.PricebookEntryId = mapProductPricebook.get(proposalLineItem.Apttus_Proposal__Product__c);
                            oppLineItemToInsert.Proposal_Line_Item__c = proposalLineItem.Id;
                            if(proposalLineItem.Quantity1__c == null ){
                                mapNewProposalLineItems.get(proposalLineItem.Id).adderror('Please enter a non zero quantity in Proposal Line item');
                                return ;
                            }
                            system.debug('*** Quantity? ' + proposalLineItem.Quantity1__c);
                            oppLineItemToInsert.Quantity = proposalLineItem.Quantity1__c;
                            
                            if(proposalLineItem.Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__r.Organization__c == 'North America')
                                oppLineItemToInsert.TotalPrice =   proposalLineItem.Net_Total__c;
                            else
                                oppLineItemToInsert.TotalPrice =   proposalLineItem.Gross_Total__c;

         
                            //S-386409 - TOtal price will be based on sales credit
                            //oppLineItemToInsert.TotalPrice = proposalLineItem.Sales_Credit__c;
                            lstOppLineItemToInsert.add(oppLineItemToInsert);
                        }

                    } else {
                        if(mapNewProposalLineItems == null ){ // in case its called from proposal trigger
                            trigger.newMap.get(proposalLineItem.Apttus_Proposal__Proposal__c).adderror('Please make sure that all the line items have products that do have their price book entry');

                        }else{

                            mapNewProposalLineItems.get(proposalLineItem.Id).adderror('Only products having pricebook entries can be added');
                        }
                        return;
                    }
                }
            }

        }
        system.debug('lstOppLineItemToInsert'+lstOppLineItemToInsert);
        system.debug('lstOppLineItemToUpdate'+lstOppLineItemToUpdate);

        

        if(lstOppLineItemToInsert.size() > 0)
            insert lstOppLineItemToInsert;

        if(lstOppLineItemToUpdate.size() > 0)
            update lstOppLineItemToUpdate;

        if(lstOppLineItemToDelete.size() > 0)
            delete lstOppLineItemToDelete;

        }
        catch(BaseApplicationException bae){
            
                throw bae;
        }
        catch(Exception ex){
            system.debug(LoggingLevel.DEBUG,  'syncLineItemsWithOpportunityLineItems  :: ERROR MESSAGE = ' + ex.getMessage() + '\n\n Line Item'+ex.getLineNumber());
            throw BaseApplicationException.NewExceptionWithInnerException('syncLineItemsWithOpportunityLineItems', 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }
    }


    private void populateAgencyCommision(Apttus_Proposal__Proposal_Line_Item__c[] newLineItems){

        set<id> setProposalIds = new set<id>();
        for(Apttus_Proposal__Proposal_Line_Item__c ApttusProposalLineItem : newLineItems){
            setProposalIds .add(ApttusProposalLineItem .Apttus_Proposal__Proposal__c);
        }

        Map<id, Apttus_Proposal__Proposal__c> newLineItemsRelatedProposal=
            new Map<id,Apttus_Proposal__Proposal__c>([SELECT AgencyCommission__c
                                                      FROM Apttus_Proposal__Proposal__c
                                                      WHERE ID IN:setProposalIds ]);




        for(Apttus_Proposal__Proposal_Line_Item__c ApttusProposalLineItem : newLineItems){
            if(newLineItemsRelatedProposal .containsKey(ApttusProposalLineItem.Apttus_Proposal__Proposal__c) && newLineItemsRelatedProposal .get(ApttusProposalLineItem.Apttus_Proposal__Proposal__c).AgencyCommission__c != Null)
                ApttusProposalLineItem.AgencyCommission__c = newLineItemsRelatedProposal .get(ApttusProposalLineItem.Apttus_Proposal__Proposal__c).AgencyCommission__c ;
        }

    }





    /*
** @author : Cloud Sherpas Inc.
** @date : 06/30/2014
** @description :  this method handles the 'Before update' event for the trigger; it's purpose is to ...
** @paramaters : an array of Account objects
** @returns : nothing
*/
    /*
** author : Piyush Jain
** date : 07/17/2015
** description :  Commenting onBeforeUpdate method as it is not calling any method from Helper Class.
*/
    /* public void OnBeforeUpdate(Apttus_Proposal__Proposal_Line_Item__c[] pUpdatedLineItems, map<ID, Apttus_Proposal__Proposal_Line_Item__c> pLineItemsIdToOldLineItemsMap){
if (Personal_Settings__c.getInstance().Trigger_Quote__c ==false){
return; // If triggers are off, then exit the method
}
final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeInsert');
system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

//try{
//if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){

//lineItemHelper.updateChildPostingLocation(pUpdatedLineItems, pLineItemsIdToOldLineItemsMap);
/**** NO LONGER REQUIRED BY MONSTER
lineItemHelper.convertPricingToInteger(pUpdatedLineItems);
*/

    /*
note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
and call the methods from handler.
*/

    //}
    //}
    /*catch(BaseApplicationException bae){
throw bae;
}
catch(Exception ex){
system.debug(LoggingLevel.DEBUG, METHODNAME + ' :: ERROR MESSAGE = ' + ex.getMessage() + '\n\n');
throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
}
}*/

    /*
** @author : Cloud Sherpas Inc.
** @date : 06/30/2014
** @description :  this method handles the 'Before update' event for the trigger; it's purpose is to ...
** @paramaters : an array of Account objects
** @returns : nothing
*/
    public void OnAfterUpdate(Apttus_Proposal__Proposal_Line_Item__c[] pUpdatedLineItems, map<ID, Apttus_Proposal__Proposal_Line_Item__c> pLineItemsIdToOldLineItemsMap, map<ID, Apttus_Proposal__Proposal_Line_Item__c> pLineItemsIdToNewLineItemsMap){
        System.debug('----ExecuteTriggers ' + ExecuteTriggers);


        if (Personal_Settings__c.getInstance().Trigger_Quote__c ==false){
            return; // If triggers are off, then exit the method
        }






        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        RunCount++;
        if(RunCount > 1){
            System.debug('----Runcount ' + Runcount);
            //Jeff L moved this here for I-198335, we were skipping it when Apttus makes its updates
            setOptyInternationalDeal(pUpdatedLineItems, pLineItemsIdToOldLineItemsMap);
            return;
        } 


        try{
            //if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){

            lineItemHelper.Mass_edit_update(pUpdatedLineItems );
            //}
            //}  
            // changes for locking issue in echosign
            if(ExecuteTriggers   )     {
                
                syncLineItemsWithOpportunityLineItems(pUpdatedLineItems, pLineItemsIdToNewLineItemsMap);


                //Update By Vivek for T-435062
                // set Opportunity International Deal checkbox 
                setOptyInternationalDeal(pUpdatedLineItems, pLineItemsIdToOldLineItemsMap);
            } 
            
        }
        catch(BaseApplicationException bae){
            throw bae;
        }
        catch(Exception ex){
            system.debug(LoggingLevel.DEBUG, METHODNAME + ' :: ERROR MESSAGE = ' + ex.getMessage() + '\n\n Line Item'+ex.getLineNumber());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }
        System.debug('----End of ApttusProposalLineItemTriggerHandler.OnAfterUpdate');
    }

    //Update By Vivek for T-435062
    // set Opportunity International Deal checkbox
    /*public void setOptyInternationalDeal(List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItems){

        map<Id , List<Apttus_Proposal__Proposal_Line_Item__c>> orderIdToproposalLineItems = new map<Id , List<Apttus_Proposal__Proposal_Line_Item__c>>();
        Map<Id,Id> orderOptyIds = new Map<Id,Id>();
        Map<Id,Id> OptyOwnerIdUpdate = new Map<Id,Id>();
        set<Id> quoteIds = new set<Id>();
        set<Id> optyIds = new set<Id>();
        List<Opportunity> tobeUpdated = new List<Opportunity>();
        List<Order__c> tobeUpdatedOrders = new List<Order__c>();
        List<Apttus_Proposal__Proposal__c> proposalLst = new List<Apttus_Proposal__Proposal__c>();

        System.debug('In setOptyInternationalDeal==');

        for(Apttus_Proposal__Proposal_Line_Item__c proposalItem : proposalLineItems){
           
            if(proposalItem.Primary_Rep_Manager__r.country != proposalItem.PostingLocation__c){
                quoteIds.add(proposalItem.Apttus_Proposal__Proposal__c);
                orderOptyIds.put(proposalItem.Id,proposalItem.Apttus_Proposal__Proposal__c);
            }
        }
        for(Apttus_Proposal__Proposal__c proposal : [Select Id, International_Deal__c,Apttus_Proposal__Opportunity__c,Apttus_Proposal__Opportunity__r.InternationalDeal__c
                                                     from Apttus_Proposal__Proposal__c
                                                     where id in : quoteIds ]){
                                                         optyIds.add(proposal.Apttus_Proposal__Opportunity__c);
                                                         if(proposal.International_Deal__c != true){
                                                             proposal.International_Deal__c = true;
                                                             proposalLst.add(proposal);
                                                         }
                                                     }


        for(Order__c ord :[Select Id,International_Deal__c From Order__c Where QuoteProposal__c IN : quoteIds]){
            if(ord.International_Deal__c != true){
                ord.International_Deal__c = true;
                tobeUpdatedOrders.add(ord);
            }
        }
        for(Opportunity opty :[Select Id,InternationalDeal__c From Opportunity Where Id IN : optyIds]){
            if(opty.InternationalDeal__c != true){
                opty.InternationalDeal__c = true;
                tobeUpdated.add(opty);
            }
        }

        if(!proposalLst.isEmpty()){
            update proposalLst;
        }
        if(!tobeUpdatedOrders.isEmpty()){
            update tobeUpdatedOrders;
        }

        if(!tobeUpdated.isEmpty()){
            update tobeUpdated;
        }

        System.debug('Out setOptyInternationalDeal=='+tobeUpdated);

    }*/
    
    public void setOptyInternationalDeal(List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItems, Map<Id,Apttus_Proposal__Proposal_Line_Item__c> pOldProposalLineItemMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','setOptyInternationalDeal');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        //To determine if a record is an internation deal we need to check the
        //Posting country on the line item vs the country specified on the 
        //Quote owners user record.  IF they are different, then it is an 
        //international deal.

        //Sberron - I-263670 - 3/10/17 - commenting setOptyInternationalDeal to prevent unecessary calls and SOQL
        Boolean runMethod = false;
        for (Apttus_Proposal__Proposal_Line_Item__c pli : proposalLineItems) {
            System.debug('----pli.PostingLocation__c: ' + pli.PostingLocation__c);
            if (pOldProposalLineItemMap != null) {
                System.debug('----pOldProposalLineItemMap: ' + pOldProposalLineItemMap.get(pli.Id).PostingLocation__c);
            }
            if ((pli.PostingLocation__c != null && pOldProposalLineItemMap != null)
                && (pli.PostingLocation__c != pOldProposalLineItemMap.get(pli.Id).PostingLocation__c)) {
                runMethod = true;
            }
        }

        if (!runMethod) {
            System.debug('----Exiting setOptyInternationalDeal as posting location has not changed.');
            return;
        }

        map<Id , List<Apttus_Proposal__Proposal_Line_Item__c>> orderIdToproposalLineItems = new map<Id , List<Apttus_Proposal__Proposal_Line_Item__c>>();
        Map<Id,Id> orderOptyIds = new Map<Id,Id>();
        Map<Id,Id> OptyOwnerIdUpdate = new Map<Id,Id>();
        set<Id> quoteIds = new set<Id>();
        set<Id> optyIds = new set<Id>();
        set<Id> userIds = new set<Id>();
        List<Opportunity> tobeUpdated = new List<Opportunity>();
        List<Order__c> tobeUpdatedOrders = new List<Order__c>();
        List<Apttus_Proposal__Proposal__c> quotetobeProcessed = new List<Apttus_Proposal__Proposal__c>();
        List<Apttus_Proposal__Proposal__c> proposalLst = new List<Apttus_Proposal__Proposal__c>();
        map<Id,Apttus_Proposal__Proposal__c> mapQuote = new  map<Id,Apttus_Proposal__Proposal__c>();
        List<Apttus_Proposal__Proposal_Line_Item__c> lineItemsToCheck = new List<Apttus_Proposal__Proposal_Line_Item__c>();

        //proposalLineItems = [Select Id,Apttus_Proposal__Proposal__c,PostingLocation__c from Apttus_Proposal__Proposal_Line_Item__c Where Id IN :proposalLineItems];
        boolean isUpdate = (pOldProposalLineItemMap != null);

        for(Apttus_Proposal__Proposal_Line_Item__c proposalItem : proposalLineItems){
            if(proposalItem.Apttus_Proposal__Proposal__c != null){
                if(isUpdate){
                    //if its an update lets check to see if the posting location has updated
                    //Jeff L commented this out since we have to check child objects for this detail unfortunately
                    //if(proposalItem.PostingLocation__c != pOldProposalLineItemMap.get(proposalItem.ID).PostingLocation__c){
                        quoteIds.add(proposalItem.Apttus_Proposal__Proposal__c);
                        lineItemsToCheck.add(proposalItem); 
                    //}
                } else {
                    //this means its an insert, so we only care if the field is not null
                    //Jeff L commented this out since we have to check child objects for this detail unfortunately
                    //if(proposalItem.PostingLocation__c != null){
                        quoteIds.add(proposalItem.Apttus_Proposal__Proposal__c);
                        lineItemsToCheck.add(proposalItem);
                    //}
                }           
            }
        }

        //no need to run rest of logic if no line items match
        if(lineItemsToCheck.size() == 0){
            return; 
        }

        //Added By Viraj Rana: 09-Jan-2017, S-457086 : Too Many SOQL queries - set Oppty International Deals flag.
        if(quoteIds.Size() > 0){
            for(Apttus_Proposal__Proposal__c proposal : [Select Id, ownerId,International_Deal__c,Apttus_Proposal__Opportunity__c,Apttus_Proposal__Opportunity__r.InternationalDeal__c
                                                         from Apttus_Proposal__Proposal__c
                                                         where id in : quoteIds ]){
                mapQuote.put(proposal.Id, proposal);
                userIds.add(proposal.ownerId);
            }
          
        
            Map<Id,User> mapUser = new map<Id,User>([Select Id, country from User Where Id IN :userIds]);
            Map<Id,String> lineItemToCountry = new Map<Id,String>();
            Set<Id> propLineAttrToQuery = new Set<Id>();
    
            for(Apttus_Proposal__Proposal_Line_Item__c proposalItem : lineItemsToCheck){
                String lineItemCountry;
    
    
                //Order of fields to check for Country I-225901:
                //Apttus_Proposal__Proposal_Line_Item__c.PostingLocation__c
                //Apttus_QPConfig__ProposalProductAttributeValue__c.Posting_Locations__c
                //Apttus_QPConfig__ProposalProductAttributeValue__c.Country__c
    
                if(String.isNotBlank(ProposalItem.PostingLocation__c)){
                    if(ProposalItem.PostingLocation__c == 'Match Country'){
                        lineItemCountry = ProposalItem.Selling_Country__c;
                    } else{
                        lineItemCountry = ProposalItem.PostingLocation__c;
                    }
    
                    lineItemToCountry.put(proposalItem.Id,lineItemCountry);
                } else {
                    //this means we need to query the Apttus_QPConfig__ProposalProductAttributeValue__c
                    //to check the other two values there
                    propLineAttrToQuery.add(proposalItem.Id);
    
                }
            }
            
            if(propLineAttrToQuery.Size() > 0){
                //now query for any attribute values that we have to check
                for(Apttus_QPConfig__ProposalProductAttributeValue__c attr : [
                    SELECT Id,Posting_Locations__c,Country__c,Apttus_QPConfig__LineItemId__c 
                    FROM Apttus_QPConfig__ProposalProductAttributeValue__c
                    WHERE Apttus_QPConfig__LineItemId__c IN :propLineAttrToQuery]){
        
                    if(String.isNotBlank(attr.Posting_Locations__c)){
                        lineItemToCountry.put(attr.Apttus_QPConfig__LineItemId__c, attr.Posting_Locations__c);
                    } else if(String.isNotBlank(attr.Country__c)){
                        lineItemToCountry.put(attr.Apttus_QPConfig__LineItemId__c, attr.Country__c);
                    }
                }
            }
    
            for(Apttus_Proposal__Proposal_Line_Item__c proposalItem : lineItemsToCheck){
    
                Apttus_Proposal__Proposal__c quote = mapQuote.get(proposalItem.Apttus_Proposal__Proposal__c);
                String lineItemCountryCheck = lineItemToCountry.get(proposalItem.Id);
                String userCountryToCheck;
    
                if(quote != null && mapUser.containsKey(quote.ownerId)){
                    userCountryToCheck = mapUser.get(quote.ownerId).Country;
                }
            
                system.debug('!!Proposal Line Item Posting Location ' + lineItemCountryCheck);
                if((lineItemCountryCheck != null && userCountryToCheck != null && lineItemCountryCheck != 'Select One') && (lineItemCountryCheck != userCountryToCheck)){
                    quotetobeProcessed.add(quote);
                    orderOptyIds.put(proposalItem.Id,proposalItem.Apttus_Proposal__Proposal__c);
                }
            }
            for(Apttus_Proposal__Proposal__c proposal : quotetobeProcessed){
    
                optyIds.add(proposal.Apttus_Proposal__Opportunity__c);
                System.debug('----proposal.International_Deal__c ' + proposal.International_Deal__c);
                if(proposal.International_Deal__c != true){
                     proposal.International_Deal__c = true;
                     proposalLst.add(proposal);
                }
            }
    
            for(Order__c ord :[Select Id,International_Deal__c From Order__c Where QuoteProposal__c IN : quoteIds]){
                System.debug('----ord.International_Deal__c ' + ord.International_Deal__c);
                if(ord.International_Deal__c != true){
                    ord.International_Deal__c = true;
                    tobeUpdatedOrders.add(ord);
                }
            }
            for(Opportunity opty :[Select Id,InternationalDeal__c From Opportunity Where Id IN : optyIds]){
                System.debug('----opty.InternationalDeal__c  ' + opty.InternationalDeal__c );
                if(opty.InternationalDeal__c != true){
                    opty.InternationalDeal__c = true;
                    tobeUpdated.add(opty);
                }
            }
            System.debug('----proposalLst: ' + proposalLst);
            System.debug('----tobeUpdatedOrders: ' + tobeUpdatedOrders);
            System.debug('----tobeUpdated: ' + tobeUpdated);
    
            if(!proposalLst.isEmpty()){
                //Added By Viraj Rana : 09-Jan-2017 : S-457086 : Too Many SOQL queries - set Oppty International Deals flag.
                ApttusProposalTriggerHandler.ExecuteTriggers = false;
                update proposalLst;
                ApttusProposalTriggerHandler.ExecuteTriggers = true;
            }
            if(!tobeUpdatedOrders.isEmpty()){
                //Added By Viraj Rana : 09-Jan-2017 : S-457086 : Too Many SOQL queries - set Oppty International Deals flag.
                OrderTriggerHandler.ExecuteTriggers = false;
                update tobeUpdatedOrders;
                OrderTriggerHandler.ExecuteTriggers = true;
            }
    
            if(!tobeUpdated.isEmpty()){
                //Added By Viraj Rana : 09-Jan-2017 : S-457086 : Too Many SOQL queries - set Oppty International Deals flag.
                Utility.ExecuteOpportunityTrigger = false;
                update tobeUpdated;
                Utility.ExecuteOpportunityTrigger = true;
            }
        }
    }

    /*public void SyncRelatedOrderLineItemProductHierarchyFields(Apttus_Proposal__Proposal_Line_Item__c[] pUpdatedLineItems, map<ID,                                                                                           Apttus_Proposal__Proposal_Line_Item__c> pLineItemsIdToOldLineItemsMap){

List<Apttus_Proposal__Proposal_Line_Item__c> lineItemToUpdate = new List<Apttus_Proposal__Proposal_Line_Item__c>();
List<Order_Line_Item__c>  orderItems = new  List<Order_Line_Item__c>();
for(Apttus_Proposal__Proposal_Line_Item__c item : pUpdatedLineItems) {
if( item.Product_Family__c != pLineItemsIdToOldLineItemsMap.get(item.Id).Product_Family__c ||
item.Product_Cateogry__c != pLineItemsIdToOldLineItemsMap.get(item.Id).Product_Cateogry__c ||
item.Product_SubCategory__c != pLineItemsIdToOldLineItemsMap.get(item.Id).Product_SubCategory__c ||
item.Media_Group__c != pLineItemsIdToOldLineItemsMap.get(item.Id).Media_Group__c ||
item.Media_Type__c != pLineItemsIdToOldLineItemsMap.get(item.Id).Media_Type__c) {
lineItemToUpdate.add(item);
}
}
Map<Id ,Apttus_Proposal__Proposal_Line_Item__c> mapProposals =  new Map<Id ,Apttus_Proposal__Proposal_Line_Item__c>([select Product_Family__c,
Product_Cateogry__c ,
Product_SubCategory__c ,
Media_Group__c ,
Media_Type__c
from Apttus_Proposal__Proposal_Line_Item__c
where Id IN :lineItemToUpdate]);

List<Order_Line_Item__c>  orderLineItems = [ Select Id, ProposalLineItem__c,Order__c,Order__r.OrderStatus__c,Product_family__c,Product_Category__c,  Sub_Category__c, Media_Group__c,Media_Type__c from Order_Line_Item__c Where ProposalLineItem__c IN :lineItemToUpdate and Order__c != null];



Apttus_Proposal__Proposal_Line_Item__c proposal ;
For(Order_Line_Item__c oLI : orderLineItems){
String status = oLI.Order__r.OrderStatus__c;
if(status == 'Verified' || status == 'Resubmitted' || status == 'Negated'
|| status == 'Paid' || status == 'Full' || status == 'Invoiced' || status == 'Closed'){
if(oLI.ProposalLineItem__c != null && mapProposals.containsKey(oLI.ProposalLineItem__c)){
proposal = mapProposals.get(oLI.ProposalLineItem__c);
if(proposal != null) {
oLI.Product_family__c = proposal.Product_Family__c;
oLI.Product_Category__c = proposal.Product_Cateogry__c;
oLI.Sub_Category__c = proposal.Product_SubCategory__c;
oLI.Media_Group__c  = proposal.Media_Group__c ;
oLI.Media_Type__c = proposal.Media_Type__c;
orderItems.add(oLI);
}
}
}
}

if(!orderItems.isEmpty()){
update orderItems;
}

} */

}