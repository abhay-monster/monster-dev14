public without sharing class ProductConfigTriggerHelper {
    final String CLASSNAME = '\n\n**** ProductConfigTriggerHelper.METHODNAME()';
/*
** @author : Cloud Sherpas Inc.
** @date : 09/18/2014
** @description : static method that instantiates a new instance of the class & sets the user's profile name member variable
** @paramaters : a string - the profile name for the current user
** @returns : a new instance of the ProductConfigTriggerHelper class
*/
    public static ProductConfigTriggerHelper NewTriggerHelper(){
        
        ProductConfigTriggerHelper newHelper = new ProductConfigTriggerHelper();
        return newHelper;
    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 09/18/2014
** @description : this method is the class constructor
** @paramaters : String user profile name
** @returns : nothing
*/
    private ProductConfigTriggerHelper(){  
        final string METHODNAME = CLASSNAME.replace('METHODNAME','ProductConfigTriggerHelper');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
    }

/*
** @author : Clud Sherpas, Inc.
** @date : 10/09/2014
** @description : Calculate yoy discount for this proposal. Takes only first Finalized Configuration in the list. 
    Cannot bulkify because of the yoy calculations.
** @paramaters : list of Apttus_Proposal__Proposal__c Ids records
** @returns : nothing 
** @Story 1089
**/


    public void calculateYOYDiscount(Apttus_Config2__ProductConfiguration__c[] pNewProductConfig, map<Id, Apttus_Config2__ProductConfiguration__c> pOldProductConfigMap){
        //Get first Finalized Configuration
       // system.debug(LoggingLevel.INFO, 'Inside calculateYOYDiscount');
        Apttus_Config2__ProductConfiguration__c prodConfig;
        for(Apttus_Config2__ProductConfiguration__c eachProdConfig : pNewProductConfig){
              if(eachProdConfig.Apttus_Config2__Status__c == 'Finalized' &&
                    pOldProductConfigMap.get(eachProdConfig.ID).Apttus_Config2__Status__c != 'Finalized'){
                    //    system.debug(LoggingLevel.INFO, 'Calculate YOY for Config'+eachProdConfig);
                        prodConfig = eachProdConfig;
                        break;
              }
        }
        
        if(prodConfig == null){
           // system.debug(LoggingLevel.INFO, 'No Finalized ProductConfiguration');
            return;
        }
        
        //Calculate Quarter Dates
        Date currentDate = Date.today();
        Date thisQuarterStartDate = firstDateOfFq(currentDate, 1 );
        Date thisQuarterEndDate = lastDateOfFq(currentDate, 1 );
        
        //Last year
        currentDate = currentDate.addMonths(-12);
        Date lastQuarterStartDate = firstDateOfFq(currentDate, 1 );
        Date lastQuarterEndDate = lastDateOfFq(currentDate, 1 );
        
        system.debug(LoggingLevel.INFO, 'Dates: thisQuarterStartDate'+ thisQuarterStartDate +
                                        ' thisQuarterEndDate:' + thisQuarterEndDate +
                                        ' lastQuarterStartDate:'+ lastQuarterStartDate +
                                        ' lastQuarterEndDate:' + lastQuarterEndDate);

        //Get Last year Qarter Results
        List<AggregateResult> queryResults = [SELECT Sum(QuoteProposal__r.GrossOrderAmount__c) Net, 
                                                Avg(QuoteProposal__r.TotalDiscount__c) Discount 
                                            FROM Order__c 
                                            Where Account__c = :prodConfig.Apttus_Config2__AccountId__c
                                            AND OrderStatus__c = 'Verified'
                                            AND Account__r.AccountStatus__c = 'Customer'
                                            AND OrderDate__c >= :lastQuarterStartDate
                                            AND OrderDate__c <= :lastQuarterEndDate
                                            Group BY Account__c];
        
        if(queryResults == null || queryResults.isEmpty()){
          //  system.debug(LoggingLevel.INFO, 'No Last Year YOY Order Results Returned for Config:'+prodConfig);
            return;
        }
        try{
            Decimal prevTotalOrderAmount = (Decimal) queryResults[0].get('Net');
            prevTotalOrderAmount = (prevTotalOrderAmount == null) ? 0 : prevTotalOrderAmount;
            
            Decimal prevAvgOrderDiscount = (Decimal) queryResults[0].get('Discount');
            prevAvgOrderDiscount = (prevAvgOrderDiscount == null) ? 0 : prevAvgOrderDiscount;
            
           System.debug('Last Year : Net Order Amount:' + prevTotalOrderAmount + 
                         ' Average Discount:' + prevAvgOrderDiscount);
            
            //Get This Quarter Results
            queryResults = [SELECT Sum(QuoteProposal__r.GrossOrderAmount__c) Net, 
                                    Avg(QuoteProposal__r.TotalDiscount__c) Discount 
                            FROM Order__c 
                            Where Account__c = :prodConfig.Apttus_Config2__AccountId__c
                            AND OrderStatus__c = 'Verified'
                            AND Account__r.AccountStatus__c = 'Customer'
                            AND OrderDate__c >= :thisQuarterStartDate
                            AND OrderDate__c <= :thisQuarterEndDate
                            Group BY Account__c];

            Decimal totalOrderAmount = 0;
            Decimal avgOrderDiscount = 0;
            
            if(queryResults == null || queryResults.isEmpty()){
               // system.debug(LoggingLevel.INFO, 'No Current Qarter Order Results Returned for Config:'+prodConfig);
            }else{
                totalOrderAmount = (Decimal) queryResults[0].get('Net');
                totalOrderAmount = (totalOrderAmount == null) ? 0 : totalOrderAmount;
                
                avgOrderDiscount = (Decimal) queryResults[0].get('Discount');
                avgOrderDiscount = (avgOrderDiscount == null) ? 0 : avgOrderDiscount;
            }
            System.debug('This Quarter : Net Order Amount:' + totalOrderAmount + 
                                        ' Average Discount:' + avgOrderDiscount);
            
            //Add Current Quote Total
            queryResults = [SELECT Sum(Apttus_Config2__NetPrice__c) Net, 
                                    Avg(Apts_Discount_del__c) Discount 
                            FROM Apttus_Config2__LineItem__c
                            Where Apttus_Config2__ConfigurationId__c = :prodConfig.ID
                            Group BY Apttus_Config2__ConfigurationId__c];
            
            if(queryResults == null || queryResults.isEmpty()){
               // system.debug(LoggingLevel.INFO, 'No Current Configurations Results Returned for Config:'+prodConfig);
                return;
            }
            
            Decimal totalConfigAmount = (Decimal) queryResults[0].get('Net');
            totalConfigAmount = (totalConfigAmount == null) ? 0 : totalConfigAmount;
                 
            Decimal avgConfigDiscount = (Decimal) queryResults[0].get('Discount');
            avgConfigDiscount = (avgConfigDiscount == null) ? 0 : avgConfigDiscount;
            
            Boolean isFinanceApprovalRequired = false;
            /*  Business Requirement    
             * QTD total Gross Value down & Discount  up    - Finance Approval Required
             *  QTD total Gross Value down & Discount down  - Finance Approval Required
             *  QTD total Gross Value up & Discount up      - Finance Approval Required
             *  QTD total Gross Value up & Discount down    - Finance Approval not Required
             **/
            if(totalConfigAmount + totalOrderAmount < prevTotalOrderAmount){
                //QTD total Gross Value down
                isFinanceApprovalRequired = true;
            }else if(totalConfigAmount + totalOrderAmount > prevTotalOrderAmount &&
                    ((avgConfigDiscount + avgOrderDiscount) / 2.0) > prevAvgOrderDiscount){
                //QTD total Gross Value up & Discount up
                isFinanceApprovalRequired = true;
            }
            
            //Update Proposal YOY_Discount__c field.
            Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c();
                proposal.Id = prodConfig.Apttus_QPConfig__Proposald__c;
                proposal.YOY_Discount__c = isFinanceApprovalRequired;
            //system.debug(LoggingLevel.INFO, 'Before update proposal:'+proposal);
            update proposal;
            
        }catch(Exception ex){
            System.debug('Exception occured:'+ex.getMessage());
            System.debug('Exception Trace:'+ex.getStackTraceString());
            return;
        }
    }
    
    public Date firstDateOfFq(Date currentDate, Integer fiscalYearStartMonth ){
        Integer offset = currentDate.month() + 12 - fiscalYearStartMonth;
        offset = Math.mod(offset, 3);
        return currentDate.addMonths(-offset).toStartOfMonth();
    }
    
    public Date lastDateOfFq(Date currentDate, Integer fiscalYearStartMonth ){
        Date d = firstDateOfFq(currentDate, fiscalYearStartMonth );
        return d.addMonths(3).addDays(-1);
    }
    
/*
** @author : Clud Sherpas, Inc.
** @date : 9/18/2014
** @description : Set the NSSA Approval fields long term contracts, signed indicator, Custom Sponsorship, Custom International Sponsorship, 
    Earliest_Start_Date, Latest_End_Date.
** @paramaters : list of Apttus_Proposal__Proposal__c Ids records
** @returns : nothing 
*/
   public void Custom_field_set_proposal_NSSA_approvals(Apttus_Config2__ProductConfiguration__c[] pNewApttusProductConfiguration, 
                                                        map<Id, Apttus_Config2__ProductConfiguration__c> pOldApttusProductConfigurationMap){
      // system.debug('***# in Trigger Custom_field_set_proposal_NSSA_approvals');
       final string METHODNAME = CLASSNAME.replace('METHODNAME','Custom_field_set_proposal_NSSA_approvals');
       system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
       List<Id> finalizedConfigIds = new List<Id>();

       for(Apttus_Config2__ProductConfiguration__c eachProdConfig : pNewApttusProductConfiguration){
          if(eachProdConfig.Apttus_Config2__Status__c == 'Finalized' &&
                pOldApttusProductConfigurationMap.get(eachProdConfig.ID).Apttus_Config2__Status__c != 'Finalized'){
                  //  system.debug('***# adding Config to the List:'+eachProdConfig);
                    finalizedConfigIds.add(eachProdConfig.ID);
          }
       }
        // if there are no Config then exit this method.
       if(finalizedConfigIds.isEmpty()){
         //  system.debug('***# no Configs in Finalized status.');
           return;
       }
      // system.debug('***# Config status = Finalized List :'+finalizedConfigIds);

        List<Apttus_Config2__LineItem__c> allConfigLineList = 
            [ Select Id,
                 Apttus_Config2__LineStatus__c,
                 Apttus_Config2__ProductId__r.ProductCode,
                 Apttus_Config2__ProductId__r.Product_Type__c,
                 Apttus_Config2__ProductId__r.Family,
                 Apts_Discount_del__c, 
                 Apttus_Config2__StartDate__c, 
                 Apttus_Config2__EndDate__c,
                 Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c,
                 Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Organization__c,
                 Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.hasCustom_International_Sponsorship__c,
                 Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Excessive_Discount__c,
                 Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.hasCustom_Sponsorship__c,
                 Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Earliest_Start_Date__c,
                 Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Latest_End_Date__c,
                 Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Long_Term_Contract__c,
                 Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Early_Renewals__c,
                 Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.APTS_Quote_Type__c,
                 Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.APTS_Fire_Approvals__c
             From Apttus_Config2__LineItem__c 
             Where Apttus_Config2__ConfigurationId__c in :finalizedConfigIds];
                                                            
        Map<Id,Apttus_Proposal__Proposal__c> proposalMap = new Map<Id,Apttus_Proposal__Proposal__c>();
        Map<Id, List<Apttus_Config2__LineItem__c>> propIDLineItemMap = new Map<Id, List<Apttus_Config2__LineItem__c>>();
        List<Apttus_Config2__LineItem__c> tempLineList;
                                                            
        // create a Map <proposal Id, List of Config Lineitem>
        for(Apttus_Config2__LineItem__c configLine: allConfigLineList){
            ID proposalID = configLine.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c;
            if(propIDLineItemMap.containsKey(proposalID)){
                tempLineList = propIDLineItemMap.get(proposalID);
             }else{
                tempLineList = new List<Apttus_Config2__LineItem__c>();
             }
            tempLineList.add(configLine);
            propIDLineItemMap.put(proposalID, tempLineList);
            // create a Map of <proposal Id, Proposal fields>
            if(!proposalMap.containsKey(proposalID)){
                proposalMap.put(proposalID, configLine.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r);
            }
        }//for line item
                                                            
       // system.debug('***# List of all Proposals :' + proposalMap);
                                                  
        for(Apttus_Proposal__Proposal__c eachproposal: proposalMap.values()){
            tempLineList = new List<Apttus_Config2__LineItem__c>(); 
           
            if(proposalMap.containsKey(eachproposal.ID)){
                tempLineList = propIDLineItemMap.get(eachproposal.ID);
            }
           // system.debug('***# Config Line Item List  :'+tempLineList);
           
            String Organizationoppty = eachproposal.Organization__c;
            Boolean has_Custom_International_Sponsorship = false;
            Boolean has_Custom_Sponsorship = false;
            Boolean Excessive_Discount = false;
            Boolean Early_Renewals = false;
            Boolean hasPremiumproduct = false;
            list<Date> Earliest_Start_Date = new list<Date>();
            list<Date> Latest_End_Date = new list<Date>();
            String product_code;
            String Product_type;
            Boolean Product_Extension_Approval = false;
            Boolean Product_Family_Media = false;
            Map <String, List<Apttus_Config2__LineItem__c>> prodcode_configLineList = 
                                    new Map<String, List<Apttus_Config2__LineItem__c>>();
            
            for(Apttus_Config2__LineItem__c configLine : tempLineList){
                if(configLine.Apttus_Config2__ProductId__r.Product_Type__c == 'Premium'){
                    hasPremiumproduct = true;
                    break;
                }
            }
            
            for(Apttus_Config2__LineItem__c configLine :tempLineList){
                //system.debug('***# Start Date:' + configLine.Apttus_Config2__StartDate__c);
                //system.debug('***# End Date:' + configLine.Apttus_Config2__EndDate__c);
                
                product_code = (string)configLine.Apttus_Config2__ProductId__r.ProductCode;
                Product_type = (string)configLine.Apttus_Config2__ProductId__r.Product_Type__c;
                
                //system.debug('***# product code '+product_code+
                 //            ' \n eachproposal.hasCustom_International_Sponsorship__c'+eachproposal.hasCustom_International_Sponsorship__c);
                
                // logic to get the Earliest Product Start Date and Latest Product End Date 
                if(configLine.Apttus_Config2__StartDate__c != null && 
                    configLine.Apttus_Config2__LineStatus__c != 'Converted')
                        Earliest_Start_Date.add(configLine.Apttus_Config2__StartDate__c);
                
                if(configLine.Apttus_Config2__EndDate__c != null && 
                    configLine.Apttus_Config2__LineStatus__c != 'Converted')
                        Latest_End_Date.add(configLine.Apttus_Config2__EndDate__c);
                    
                  // for Quote type = Product Extension any of the lineitem diff between end date and start date > 2  
                if(eachproposal.APTS_Quote_Type__c == 'Product Extension'){
                     Integer numberDaysdetween = configLine.Apttus_Config2__StartDate__c.daysBetween(configLine.Apttus_Config2__EndDate__c);
                     if(numberDaysdetween > 2){
                         Product_Extension_Approval = true;
                     }
                    
                }
                
                //if there is a product is of  Custom International Sponsorship or Custom Sponsorship
                if(product_code == '11228X02M' ){
                    has_Custom_International_Sponsorship = true; 
                }
                if (product_code == '11797X12M' ){
                    has_Custom_Sponsorship = true;
                }
                
                List<Apttus_Config2__LineItem__c> temp;
                if(prodcode_configLineList.containsKey(product_code)){
                    temp = prodcode_configLineList.get(product_code);
                }else{
                    temp = new List<Apttus_Config2__LineItem__c>();
                }
                temp.add(configLine);
                prodcode_configLineList.put(product_code, temp);
                
                if(hasPremiumproduct && Product_type == 'Core' && configLine.Apts_Discount_del__c > 35){
                    Excessive_Discount = true;
                }
                //f the quote type is product conversion and Line type = new and Product family = Media
                if(eachproposal.APTS_Quote_Type__c == 'Product Conversion' && configLine.Apttus_Config2__LineStatus__c == 'New' && configLine.Apttus_Config2__ProductId__r.Family == 'Media'){
                    Product_Family_Media = true;
                }
            }//Line Item For loop
           
            // if there is a Excessive Discountmake this field as checked.
            eachproposal.Excessive_Discount__c = Excessive_Discount;
            // if there is a product of Custom International Sponsorship
            eachproposal.hasCustom_International_Sponsorship__c = has_Custom_International_Sponsorship;
            // if there is a product of Custom Sponsorship
            eachproposal.hasCustom_Sponsorship__c = has_Custom_Sponsorship;
            // for Quote type = Product Extension any of the lineitem diff between end date and start date > 2
            eachproposal.Product_Extension_Approval__c = Product_Extension_Approval;
            // for Quote type = Product Conversion any of the new Lineitems product family is Media
            eachproposal.PC_Media_Product_Indicator__c = Product_Family_Media;
            // populate Earliest Product Start Date and Latest Product End Date
            Earliest_Start_Date.sort();
            Latest_End_Date.sort();

            eachproposal.Earliest_Start_Date__c = null;
            eachproposal.Latest_End_Date__c = null;
         //  system.debug('***# Earliest_Start_Date List:'+Earliest_Start_Date);
           // system.debug('***# Latest_End_Date List:'+Latest_End_Date);
            
            if(!Earliest_Start_Date.isEmpty())
                eachproposal.Earliest_Start_Date__c = Earliest_Start_Date.get(0);
            if(!Latest_End_Date.isEmpty())
                eachproposal.Latest_End_Date__c = Latest_End_Date.get(Latest_End_Date.size()-1);
            
            // long term contracts 
            Boolean islongterm = NSSA_approvals_Util.isanyproductlongterm(prodcode_configLineList);
            eachproposal.Long_Term_Contract__c = islongterm;
            
            // if any of the product is Early_Renewals  if Organization = "north americia"
            
            if(Organizationoppty == 'North America'){
                // min(PLI Apttus_QPConfig__StartDate__c)  > proposal.Earliest_Start_Date__c+ 1 month or 
                // min(PLI Apttus_QPConfig__StartDate__c) in next year
                Early_Renewals = NSSA_approvals_Util.isEarly_Renewals(prodcode_configLineList, eachproposal.Earliest_Start_Date__c);
            }
            eachproposal.Early_Renewals__c = Early_Renewals;
            if(!eachproposal.APTS_Fire_Approvals__c)
                eachproposal.APTS_Fire_Approvals__c = true;
      }
                                                            
      if(!proposalMap.isEmpty()){
         // system.debug('***# Updating Proposal :' + proposalMap.values());
          update proposalMap.values();
      }
   }
   
/*
** @author : Clud Sherpas, Inc.
** @date : 10/23/2014
** @description : 
** @paramaters : list of configration Ids records
** @returns : nothing 
*/ /* // This code is being commented out because not being used anywhere and coded by cloud sherpas.
   public void config_QuoteApproval(Apttus_Config2__ProductConfiguration__c[] pNewApttusProductConfiguration, 
                                                        map<Id, Apttus_Config2__ProductConfiguration__c> pOldApttusProductConfigurationMap){
       system.debug('***# in Trigger config_QuoteApproval');
       final string METHODNAME = CLASSNAME.replace('METHODNAME','config_QuoteApproval');
       system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
       Set<Id> Proposalid = new Set<Id>();

       for(Apttus_Config2__ProductConfiguration__c eachProdConfig : pNewApttusProductConfiguration){
          if(eachProdConfig.Apttus_Config2__Status__c == 'Finalized'
              && pOldApttusProductConfigurationMap.get(eachProdConfig.ID).Apttus_Config2__Status__c != 'Finalized'
              && eachProdConfig.Apttus_QPConfig__Proposald__c != null){
                    system.debug('***# adding Config to the List:'+eachProdConfig);
                    Proposalid.add(eachProdConfig.Apttus_QPConfig__Proposald__c);
          }
       }
        // if there are no Config then exit this method.
       if(Proposalid == null || Proposalid.isEmpty()){
           system.debug('***# no Configs in Finalized status.');
           return;
       }
       
       List<Apttus_Proposal__Proposal__c> proposallist = [Select Id,
                                                                 ownerId,
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
                                                                 Discount_Authority_Manager10__c
                                                                 FROM Apttus_Proposal__Proposal__c where Id IN:Proposalid];
        AptsQuoteApprovalHelper.updateManager(proposallist);
        update proposallist;
                                                        
  }
  */
  public void config_Saved(Apttus_Config2__ProductConfiguration__c[] pNewApttusProductConfiguration, 
                                                        map<Id, Apttus_Config2__ProductConfiguration__c> pOldApttusProductConfigurationMap){
      // system.debug('***# config_save');
       final string METHODNAME = CLASSNAME.replace('METHODNAME','config_save');
       system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
       Set<Id> Proposalid = new Set<Id>();

       for(Apttus_Config2__ProductConfiguration__c eachProdConfig : pNewApttusProductConfiguration){
          if(eachProdConfig.Apttus_Config2__Status__c == 'Saved'
              && eachProdConfig.Apttus_QPConfig__Proposald__c != null){
                  //  system.debug('***# adding Config to the List:'+eachProdConfig);
                    Proposalid.add(eachProdConfig.Apttus_QPConfig__Proposald__c);
          }
       }
        // if there are no Config then exit this method.
       if(Proposalid == null || Proposalid.isEmpty()){
          // system.debug('***# no Configs in Saved status.');
           return;
       }
       
       List<Apttus_Proposal__Proposal__c> proposallist = [Select Id,
                                                                 APTS_Enforce_Rollup_Summary_Calc__c
                                                                 FROM Apttus_Proposal__Proposal__c where Id IN:Proposalid];
        List<Apttus_Proposal__Proposal__c> updateproposallist = new List<Apttus_Proposal__Proposal__c>();                                                       
       for(Apttus_Proposal__Proposal__c eachproposal : proposallist){
           if(!eachproposal.APTS_Enforce_Rollup_Summary_Calc__c){
              eachproposal.APTS_Enforce_Rollup_Summary_Calc__c = true;
              updateproposallist.add(eachproposal);
        
           }
       }
        if(!updateproposallist.isEmpty())
            update proposallist;
                                                        
  }
  /*
  public void CartFinalize(Apttus_Config2__ProductConfiguration__c[] pNewApttusProductConfiguration, 
                                                        map<Id, Apttus_Config2__ProductConfiguration__c> pOldApttusProductConfigurationMap){
     //  system.debug('***# config_save');
       final string METHODNAME = CLASSNAME.replace('METHODNAME','CartFinalize');
       Set<Id> Proposalid = new Set<Id>();
       boolean isApprovalRequired = true;
       for(Apttus_Config2__ProductConfiguration__c eachProdConfig : pNewApttusProductConfiguration){
          if(eachProdConfig.Apttus_Config2__Status__c == 'Finalized'
              && eachProdConfig.Apttus_QPConfig__Proposald__c != null
              &&  eachProdConfig.Apttus_Config2__FinalizedDate__c != pOldApttusProductConfigurationMap.get(eachProdConfig.Id).Apttus_Config2__FinalizedDate__c){
                   isApprovalRequired = Apttus_Approval.ApprovalsWebService.isApprovalRequired('Apttus_Config2__ProductConfiguration__c', eachProdConfig.Id);
                  if(!isApprovalRequired)
                  {
                      Proposalid.add(eachProdConfig.Apttus_QPConfig__Proposald__c);
                      isApprovalRequired = false;
                  }
          }
       }
        // if there are no Config then exit this method.
       if(Proposalid == null || Proposalid.isEmpty()){
         //  system.debug('***# no Configs in Finalized status.');
           return;
       }
       
        List<Apttus_Proposal__Proposal__c> updateproposallist = new List<Apttus_Proposal__Proposal__c>();   
       if(!isApprovalRequired)
       {                                                                                                                     
           for(Id propid : Proposalid){
               updateproposallist.add(new Apttus_Proposal__Proposal__c(Id=propid,Apttus_QPApprov__Approval_Status__c='No Approval Needed'));
           }
       }  
        if(!updateproposallist.isEmpty())
            update updateproposallist;
                                                        
  }
  
    */
    /*
    ** @author : Ranjeet, Apttus Inc.
    ** @date : 10/24/2014
    ** @description : 
    ** @paramaters : list of configration Ids records
    ** @returns : nothing 
    */
    //Commenting out this code as this is no longer used
    /*
    public void setFireApprovalsFlag(Apttus_Config2__ProductConfiguration__c[] pNewApttusProductConfiguration, 
                                                        map<Id, Apttus_Config2__ProductConfiguration__c> pOldApttusProductConfigurationMap){
    
        for(Apttus_Config2__ProductConfiguration__c productConfigObj : pNewApttusProductConfiguration) {
            if(productConfigObj.Apttus_Config2__Status__c != pOldApttusProductConfigurationMap.get(productConfigObj.Id).Apttus_Config2__Status__c && 
                productConfigObj.Apttus_Config2__Status__c == 'Finalized') {
                
                productConfigObj.APTS_Fire_Approvals__c = true;
            }
        }
    }
    */
   
}