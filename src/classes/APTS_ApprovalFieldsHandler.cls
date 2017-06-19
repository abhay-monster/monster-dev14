public class APTS_ApprovalFieldsHandler
{
    //private Apttus_Proposal__Proposal__c proposal;
    private Id proposalId;
     
    public  Apttus_Proposal__Proposal__c proposalSO{get;set;}
    public boolean addComments{get;set;}
    
    public APTS_ApprovalFieldsHandler() {
        //proposal = (Apttus_Proposal__Proposal__c)stdController.getRecord();        
        //addComments = false;
    }
    
    /*public PageReference doRedirect() {
        final string METHODNAME = CLASSNAME.replace('METHODNAME','doRedirect');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        PageReference pg;
         
        if(proposal != null) {
            proposal = [Select APTS_Enforce_Rollup_Summary_Calc__c, APTS_Fire_Approvals__c, APTS_Count_Of_Agency_Comm_Diff_Lines__c, 
                TotalBaseExtendedPrice__c, GrossOrderAmount__c, Quote_Total__c, ownerId, TotalDiscount__c, Manager1__c, 
                Discount_Authority_Manager1__c, Manager2__c, Discount_Authority_Manager2__c, Manager3__c, Discount_Authority_Manager3__c, 
                Manager4__c, Discount_Authority_Manager4__c, Manager5__c, Discount_Authority_Manager5__c, Manager6__c, Discount_Authority_Manager6__c, 
                Manager7__c, Discount_Authority_Manager7__c, Manager8__c, Discount_Authority_Manager8__c, Manager9__c, Discount_Authority_Manager9__c, 
                Manager10__c, Discount_Authority_Manager10__c, AgencyCommission__c
                From Apttus_Proposal__Proposal__c Where Id = :proposal.Id];
                
            if(proposal.APTS_Enforce_Rollup_Summary_Calc__c || proposal.APTS_Fire_Approvals__c) {
                doRollupSummaryCalc(proposal);
                proposal.APTS_Enforce_Rollup_Summary_Calc__c = false;
                
                Boolean fireApprovals = proposal.APTS_Fire_Approvals__c;
                
                if(fireApprovals) {
                    addComments = true;
                    pg = null;
                }
                else {
                    addComments = false;
                    pg = new PageReference('/' + proposal.Id + '?nooverride=1');
                }
                 
                ApttusProposalTriggerHandler.ExecuteTriggers = false;                
                update proposal;
            }
            else{
                pg = new PageReference('/' + proposal.Id + '?nooverride=1');
            }

        }
     
        return pg;
    }*/
    
    public void PopulateApprovalFields(Apttus_Proposal__Proposal__c currentProposal,String cartId,List<Apttus_Config2__LineItem__c> lineItems){      
      
     proposalSO = currentProposal;
      
      //boolean submitApprovals = proposalSO.APTS_Fire_Approvals__c;
      //if(proposalSO.APTS_Enforce_Rollup_Summary_Calc__c || proposalSO.APTS_Fire_Approvals__c)
      {
          system.debug(LoggingLevel.INFO, '**************Before doRollupSummaryCalc'); 
          
          ClearApprovalTriggeringFields(proposalSO);
          doRollupSummaryCalc(proposalSO,cartId,lineItems);
          system.debug(LoggingLevel.INFO, '**************After doRollupSummaryCalc');  
          List<Apttus_Proposal__Proposal__c> proposalList = new List<Apttus_Proposal__Proposal__c>();
          proposalList.add(proposalSO);
          system.debug(' before gTermApproval Inside');
         // for asset based propsal No need to chech Longterm approval 
         
         if(!(proposalSO.MidContract_Proposal__c  || proposalSO.Upgrade_Proposal__c  || proposalSO.APTS_Quote_Type__c == 'Product Conversion' ))
          checkLongTermApproval(proposalSO,lineItems); 
          
          AptsQuoteApprovalHelper.updateManager(proposalList);
          proposalSO.APTS_Fire_Approvals__c = false;
      }
    
      
      ApttusProposalTriggerHandler.ExecuteTriggers = false;
      update proposalSO;
        
       CheckforApprovals(proposalSO,cartId);
      update proposalSO;

      ApttusProposalTriggerHandler.ExecuteTriggers = true;
      
    }

    
    
    private void doRollupSummaryCalc(Apttus_Proposal__Proposal__c proposal,String cartId,List<Apttus_Config2__LineItem__c> lineItems) {
         /* List<Apttus_Config2__LineItem__c> lineItems = [Select Apttus_Config2__BaseExtendedPrice__c,Net_Total__c,Apttus_Config2__OptionPrice__c,
                                                         Apttus_Config2__LineStatus__c,Apttus_Config2__NetPrice__c,APTS_Extended_List_Price__c,Apttus_Config2__Quantity__c
                                                         From Apttus_Config2__LineItem__c Where Apttus_Config2__ConfigurationId__c = :cartId ];
      
      */
        system.debug(LoggingLevel.INFO, 'lineItems'+lineItems);
        if(!lineItems.isEmpty()) {
            //system.debug(LoggingLevel.INFO, '111111111111111111111111');
            Integer countOfAgencyCommDiffLines = 0;
            Decimal totalBaseExtendedPrice = 0;
            Decimal grossOrderAmount = 0;
            Decimal quoteTotal = 0;
            Decimal grossTotal = 0;
            Decimal baseTotal = 0;
            Set<Id> productIds = new Set<Id>();
            
            Decimal grossThresoldTotal = 0;
            Decimal baseThresoldTotal = 0;
            system.debug(LoggingLevel.INFO, '222222222222222222222222222');
            for(Apttus_Config2__LineItem__c lineItemObj : lineItems) {
            if(lineItemObj.Apttus_Config2__LineStatus__c != 'Amended'){
               // System.debug('lineItemObj '+lineItemObj );
                 //System.debug('RestrictedConversion__c--> '+lineItemObj.Apttus_Config2__ProductId__r.RestrictedConversion__c ); 
                //countOfAgencyCommDiffLines += Integer.valueOf(proposalLineItemObj.APTS_Is_Agency_Commission_Different__c);
                if(proposal.APTS_Quote_Type__c == 'Product Conversion')
                {
                    if(lineItemObj.Apttus_Config2__LineType__c == 'Option')
                    {
                        productIds.add(lineItemObj.Apttus_Config2__OptionId__c);
                    }
                    else
                    {
                        productIds.add(lineItemObj.Apttus_Config2__ProductId__c);
                    }
                }
                if(lineItemObj.Apttus_Config2__OptionPrice__c == null) {
                //I-  173150  Start-- Net amount was not calcuating proper if quantity is changed 
                   // quoteTotal += lineItemObj.Net_Total__c;
                     quoteTotal += lineItemObj.Apttus_Config2__NetPrice__c;
                    //I-  173150 End-- Net amount was not calcuating proper if quantity is changed 
                    system.debug(LoggingLevel.INFO, 'lineItemObj.Net_Total__c  ::::::::::::::::::::::: ' + lineItemObj.Net_Total__c);
                    system.debug(LoggingLevel.INFO, 'lineItemObj.Apttus_Config2__NetPrice__c  ::::::::::::::::::::::: ' + lineItemObj.Apttus_Config2__NetPrice__c);
                    system.debug(LoggingLevel.INFO, 'lineItemObj.Apttus_Config2__AdjustedPrice__c  ::::::::::::::::::::::: ' + lineItemObj.Apttus_Config2__AdjustedPrice__c);
                    if(lineItemObj.Apttus_Config2__LineStatus__c == 'New') {                    
                        if(lineItemObj.Apttus_Config2__BaseExtendedPrice__c == null)
                            lineItemObj.Apttus_Config2__BaseExtendedPrice__c = 0.0;
                        totalBaseExtendedPrice += lineItemObj.Apttus_Config2__BaseExtendedPrice__c;
                        //grossOrderAmount += lineItemObj.Net_Total__c;
                        System.debug('santoshdebug***1'+grossOrderAmount );
                         
                          System.debug('santoshdebug***2'+grossOrderAmount );
                    }
                    
                    grossOrderAmount += GetNetGrossOrderAmount(lineItemObj);
                }
                
               /* if((lineItemObj.Apttus_Config2__LineType__c == 'Product/Service' && lineItemObj.Apttus_Config2__HasOptions__c == true) ||
                    (lineItemObj.Apttus_Config2__LineType__c == 'Option' && lineItemObj.Apttus_Config2__ListPrice__c != lineItemObj.Apttus_Config2__BasePrice__c))
                {
                    //Do nothing
                    System.debug('in');
                }
                else
                {
                    grossTotal += (lineItemObj.Apttus_Config2__NetPrice__c!=null)?lineItemObj.Apttus_Config2__NetPrice__c:0;
                    baseTotal +=(lineItemObj.APTS_Extended_List_Price__c!=null)? lineItemObj.APTS_Extended_List_Price__c:0;
                }*/
                 
                //added new field - I-191765
             //   if((lineItemObj.Configuration_Type__c == 'Standalone') ||
                   if((lineItemObj.Apttus_Config2__LineType__c   == 'Product/Service' && lineItemObj.Apttus_Config2__IsPrimaryLine__c && !lineItemObj.Apttus_Config2__HasOptions__c)       ||
                    (lineItemObj.Apttus_Config2__LineType__c == 'Option' && lineItemObj.Apttus_Config2__ListPrice__c == lineItemObj.Apttus_Config2__BasePrice__c)
                      ) 
                {
                    If (lineItemObj.Apttus_Config2__NetPrice__c != null && lineItemObj.Apttus_Config2__NetPrice__c >= 0 ) //I-202078  fix
                   // if(lineItemObj.Apttus_Config2__LineStatus__c != 'Amended'){
                    {  
                    grossTotal += (lineItemObj.Apttus_Config2__NetPrice__c!=null)?lineItemObj.Apttus_Config2__NetPrice__c:0;
                    baseTotal +=(lineItemObj.APTS_Extended_List_Price__c!=null)? lineItemObj.APTS_Extended_List_Price__c:0;
                        system.debug('Mukesh Midcontract Flag --> '+proposal.MidContract_Proposal__c );
                        if(proposal.MidContract_Proposal__c)
                        {
                            if(lineItemObj.Apttus_Config2__LineStatus__c == 'New'){
                                grossThresoldTotal += (lineItemObj.Apttus_Config2__NetPrice__c!=null)?lineItemObj.Apttus_Config2__NetPrice__c:0;
                                baseThresoldTotal  +=(lineItemObj.APTS_Extended_List_Price__c!=null)? lineItemObj.APTS_Extended_List_Price__c:0;
                            }
                            
                        }
                        else
                        {
                                grossThresoldTotal += (lineItemObj.Apttus_Config2__NetPrice__c!=null)?lineItemObj.Apttus_Config2__NetPrice__c:0;
                                baseThresoldTotal  +=(lineItemObj.APTS_Extended_List_Price__c!=null)? lineItemObj.APTS_Extended_List_Price__c:0;
                        }
                    }
                   // }
                   
                
                }                
                
                system.debug(LoggingLevel.INFO, 'grossTotal 13 ::::::::::::::::::::::::::::: ' + grossTotal);
                system.debug(LoggingLevel.INFO, 'baseTotal 13 :::::::::::::::::::::::::::: ' + baseTotal + ' Quantity-->' + lineItemObj.Apttus_Config2__Quantity__c);
            }
           } 
            //system.debug(LoggingLevel.INFO, 'Quote_Total__c 2 ::::::::::::::::::::::: ' + quoteTotal); 
            //proposal.APTS_Count_Of_Agency_Comm_Diff_Lines__c = countOfAgencyCommDiffLines;
            proposal.TotalBaseExtendedPrice__c = totalBaseExtendedPrice;
            proposal.GrossOrderAmount__c = grossOrderAmount;
             // replaced Quote_Total__c with Net_Total__c due to I-191155
            //proposal.Quote_Total__c = quoteTotal;  
            
            system.debug(LoggingLevel.INFO, 'grossTotal 2 ::::::::::::::::::::::: ' + grossTotal);
            //system.debug('APTS_ApprovalFieldsHandler');
            /* Jeff L Commented out as part of S-323592
            if(grossTotal != 0) {
                proposal.AgencyCommission__c = (grossTotal - quoteTotal) / grossTotal * 100;  
            } else {
                proposal.AgencyCommission__c = 0;
            }
            */
            system.debug('grossTotal ::::::::::::::::::::--> ' + grossTotal);
            system.debug('baseTotal :::::::::::::::::::-->' + baseTotal);
            system.debug('roposal.TotalDiscount__c 1 :::::::::::::::::::-->' + proposal.TotalDiscount__c);
            if(baseTotal != null && baseTotal > 0) {
                proposal.TotalDiscount__c = (1 - (grossTotal/baseTotal)) * 100;
            }
            system.debug('roposal.TotalDiscount__c 2 :::::::::::::::::::-->' + proposal.TotalDiscount__c);
            
            if(baseThresoldTotal != null && baseThresoldTotal > 0) {
                proposal.Total_Thresold_Discretionary_Discount__c = (1 - (grossThresoldTotal/baseThresoldTotal)) * 100;
            }
            else
                proposal.Total_Thresold_Discretionary_Discount__c=0;
            
            system.debug('proposal.Total_Thresold_Discretionary_Discount__c :::::::::::::::::::-->' + proposal.Total_Thresold_Discretionary_Discount__c);
           /*Jeff L Commented out as part of S-323592 
           if(string.IsBlank(proposal.Agency__c))
            {
             proposal.AgencyCommission__c=null; 
            }*/
           //system.debug('TotalDiscount__c ::::::::::::::::::: ' + proposal.TotalDiscount__c);
           //
           
           //Populate Proposal field in Conversions where the originating contract has < 60 days remaining
           if(proposal.APTS_Quote_Type__c == 'Product Conversion')
           {
               if(proposal.Latest_End_Date__c < Date.today().addDays(60))
               {
                   proposal.APTS_Is_Original_Quote_End_Date_Less__c = true;
               }
               
               if(productIds != null && !productIds.isEmpty())
               {
                   boolean isRestrictedConversion = false;
                   List<Product2> products = [Select Id,RestrictedConversion__c from Product2 where Id In:productIds];
                   for(Product2 prod:products)
                   {
                       if(prod.RestrictedConversion__c)
                       {
                           isRestrictedConversion = true;
                           break;
                       }
                   }
                   proposal.APTS_Is_Restricted_Conversion__c = isRestrictedConversion;
               }
           }
        }
    
    }
    
    private void ClearApprovalTriggeringFields(Apttus_Proposal__Proposal__c proposal)
    {
        if(proposal != null)
        {
          proposal.APTS_Is_Original_Quote_End_Date_Less__c = false; 
            proposal.APTS_Is_Restricted_Conversion__c = false;
        }
    }
    
    private decimal GetNetGrossOrderAmount(Apttus_Config2__LineItem__c line)
    {
        decimal netTotal = 0;
        decimal grossTotal = 0;
        if(line != null)
        {
            decimal grossUnitPrice = 0;
            if(line.Apttus_Config2__Quantity__c != null && line.Apttus_Config2__Quantity__c > 0)
            {
                grossUnitPrice = line.Apttus_Config2__NetPrice__c / line.Apttus_Config2__Quantity__c;
            }
            decimal netUnitPrice = grossUnitPrice;
            if(line.AgencyCommission__c != null && grossUnitPrice > 0)
            {
                netUnitPrice = grossUnitPrice - ((grossUnitPrice * line.AgencyCommission__c)/100);
            }
            netTotal = (netUnitPrice!=null?netUnitPrice:0) * (line.Apttus_Config2__Quantity__c!=null?line.Apttus_Config2__Quantity__c:0);
            grossTotal = (grossUnitPrice !=null?grossUnitPrice:0) * (line.Apttus_Config2__Quantity__c!=null?line.Apttus_Config2__Quantity__c:0);
            system.debug('GetNetGrossOrderAmount-NetPrice-->' + line.Apttus_Config2__NetPrice__c);
        }
        system.debug('GetNetGrossOrderAmount-netTotal-->' + netTotal  );
        return grossTotal ;
    }
    
    private void checkLongTermApproval(Apttus_Proposal__Proposal__c Prop,List<Apttus_Config2__LineItem__c> lineItems)
    {
        list<Date> Earliest_Start_Date = new list<Date>();
        list<Date> Latest_End_Date = new list<Date>();
        String Organizationoppty = Prop.Organization__c;
        System.debug('checkLongTermApproval Organizationoppty'+Organizationoppty);
        Map <String, List<Apttus_Config2__LineItem__c>> prodcode_configLineList = 
            new Map<String, List<Apttus_Config2__LineItem__c>>();
        System.debug('checkLongTermApproval lineItems'+lineItems);
        List<Apttus_Config2__LineItem__c> temp;
        for(Apttus_Config2__LineItem__c oTempLine: lineItems)
        {
            // put the if condition for issue I-206656
            if(  !((string)oTempLine.Configuration_Type__c=='Bundle' &&  (string)oTempLine.Apttus_Config2__LineType__c=='Product/Service') ){
                    string product_code = (string)oTempLine.Apttus_Config2__ProductId__r.ProductCode;
                    if(prodcode_configLineList.containsKey(product_code)){
                        temp = prodcode_configLineList.get(product_code);
                    }else{
                        temp = new List<Apttus_Config2__LineItem__c>();
                    }
                    temp.add(oTempLine);
                    prodcode_configLineList.put(product_code, temp);
                    
                    if(oTempLine.Apttus_Config2__StartDate__c != null && oTempLine.Apttus_Config2__LineStatus__c == 'New')
                    {
                        Earliest_Start_Date.add(oTempLine.Apttus_Config2__StartDate__c);
                    }
                    if(oTempLine.Apttus_Config2__EndDate__c != null && oTempLine.Apttus_Config2__LineStatus__c == 'New')
                    {
                        Latest_End_Date.add(oTempLine.Apttus_Config2__EndDate__c);
                    }
            }
                
           
            
        }
        
        Earliest_Start_Date.sort();
        Latest_End_Date.sort();
        
        Prop.Earliest_Start_Date__c = null;  
        Prop.Latest_End_Date__c = null;
        //  system.debug('***# Earliest_Start_Date List:'+Earliest_Start_Date);
        // system.debug('***# Latest_End_Date List:'+Latest_End_Date);
        System.debug('Earliest_Start_Date'+Earliest_Start_Date);
        if(!Earliest_Start_Date.isEmpty())
        {
            System.debug('Earliest_Start_Date'+Earliest_Start_Date.get(0));
            Prop.Earliest_Start_Date__c = Earliest_Start_Date.get(0);
        }
        if(!Latest_End_Date.isEmpty())
        {
            System.debug('Latest_End_Date'+Latest_End_Date.get(Latest_End_Date.size()-1));
            Prop.Latest_End_Date__c = Latest_End_Date.get(Latest_End_Date.size()-1);
        }
        System.debug('checkLongTermApproval prodcode_configLineList'+prodcode_configLineList);
        Boolean islongterm = NSSA_approvals_Util.isanyproductlongterm(prodcode_configLineList);
        System.debug('checkLongTermApproval islongterm'+islongterm);
        Prop.Long_Term_Contract__c = islongterm;
        
        // if any of the product is Early_Renewals  if Organization = "north americia"
        Boolean Early_Renewals = False;
        if(Organizationoppty == 'North America'){
            // min(PLI Apttus_QPConfig__StartDate__c)  > proposal.Earliest_Start_Date__c+ 1 month or 
            // min(PLI Apttus_QPConfig__StartDate__c) in next year
             System.debug('checkLongTermApproval islongterm'+Prop.Earliest_Start_Date__c);
            If(Prop.Earliest_Start_Date__c == null)
            {
                Prop.Earliest_Start_Date__c =Date.today();
            }
            Early_Renewals = NSSA_approvals_Util.isEarly_Renewals(prodcode_configLineList, Prop.Earliest_Start_Date__c);
            System.debug('checkLongTermApproval Early_Renewals'+Early_Renewals);
        }
         Prop.Early_Renewals__c = Early_Renewals; 
    }
    
    Public void CheckforApprovals(Apttus_Proposal__Proposal__c Prop ,Id ProdConfig){
        
        boolean isApprovalrequired =  Apttus_Approval.ApprovalsWebService.isApprovalRequired('Apttus_Config2__ProductConfiguration__c', ProdConfig); 
        System.debug('CheckforApprovals isApprovalrequired'+isApprovalrequired);
        if(!isApprovalrequired){
            Prop.Apttus_QPApprov__Approval_Status__c='No Approval Needed';
        }
        else {
           Prop.Apttus_QPApprov__Approval_Status__c= 'Approval Required';         
        }
        
        
        
    }
}