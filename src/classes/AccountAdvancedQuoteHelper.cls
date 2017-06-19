/*
** @author : Cloud Sherpas Inc.
** @date : 09/08/2014
** @description : AccountAdvancedQuoteHelper Page Controller Class
*/
public class AccountAdvancedQuoteHelper {
    private Map<Id,String> proposalsVerifiedOrder = new Map<Id,String>();
    private Map<Id,Id> proposalsVerifiedOrderID = new Map<Id,id>();  // I-171251 -APTTUS

    public static String MidContractQuote   = 'Mid Contract';
    public static String ResumeUpgrade      = 'Resume Upgrade';
    public static String ProductConversion  = 'Product Conversion';
    public static String ProductExtension   = 'Product Extension';
    public static String Renewal            = 'Renewal';
    public static String BIAUsage           = 'BIA/Usage';

    //ProposalID <> AssetLintItem List
    public Map<ID, List<Apttus_Config2__AssetLineItem__c>> quoteIDAssetLineItemMap;

    public String message = '';

    /* Get list of Proposal Line Item based on Action selected from Account Page
     **/
    public String getQuoteByAccountAction(String selectedAction, ID accountID){
        System.debug(LoggingLevel.INFO,'Inside getQuoteByAccountAction:'+selectedAction);
        message = '';
        List<Apttus_Config2__AssetLineItem__c> assetLineList;
        //try{
            if(selectedAction == MidContractQuote){
                assetLineList = getAssetLineItems(selectedAction, accountID);
                Set<String> productIDCountrySet = getProductEligibilityMatrix(assetLineList);
                return getMCQDisplayLineItems(assetLineList, productIDCountrySet);
            }else if(selectedAction == ResumeUpgrade ||
                        selectedAction == ProductConversion ||
                        selectedAction == ProductExtension  ||
                        selectedAction == Renewal){
                assetLineList = getAssetLineItems(selectedAction, accountID);
                return getDisplayLineItems(assetLineList);
            }else if(selectedAction == BIAUsage){
                assetLineList = getAssetLineItems(selectedAction, accountID);
                return getDisplayLineItems(assetLineList);
            }
        /*}catch(Exception ex){
            System.debug(LoggingLevel.INFO,'Exception occured in getQuoteByAccountAction:' + ex.getMessage());
            message = ex.getMessage();
        }*/
        return null;
    }

    //for Mid Contract Quote and RU
    public List<Apttus_Config2__AssetLineItem__c> getAssetLineItems(String selectedAction, ID accountID){
        System.debug(LoggingLevel.INFO,'Inside getAssetLineItems selectedAction:' + selectedAction +
                                                ' accountID:' + accountID);
        List<Apttus_Config2__AssetLineItem__c> assetLineList = new List<Apttus_Config2__AssetLineItem__c>();
        String queryStr = '';
            queryStr += 'Select ID, ';
            queryStr += '   Apttus_Config2__ProductId__c,';
            queryStr += '   Apttus_Config2__ProductId__r.Name,';
            queryStr += '   Apttus_Config2__ProductId__r.ProductCode,';
            queryStr += '   Apttus_Config2__ProductId__r.Service_Type__c,';
            queryStr += '   Available_Quantity__c, CurrencyIsoCode,';
            queryStr += '   Apttus_Config2__BasePrice__c,';
            queryStr += '   Apttus_Config2__NetPrice__c,';
            queryStr += '   Apttus_Config2__Quantity__c,';
            queryStr += '   Apttus_Config2__StartDate__c,';
            queryStr += '   Apttus_Config2__EndDate__c,';
            queryStr += '   Proposal__c,';
            queryStr += '   Proposal__r.Name,';
            queryStr += '   Proposal__r.Apttus_Proposal__Opportunity__r.Name,';
            queryStr += '   Proposal__r.Apttus_Proposal__Account__r.Name,';
            queryStr += '   Proposal__r.Earliest_Start_Date__c,';
            queryStr += '   Proposal__r.Latest_End_Date__c,';
            queryStr += '   Proposal__r.Apttus_Proposal__Proposal_Name__c,';
            queryStr += '   Proposal__r.CurrencyIsoCode,';
            queryStr += '   Proposal__r.NetOrderAmount__c,';
            queryStr += '   Proposal__r.Selling_Country__c,';
            queryStr += '   Proposal__r.QuoteStatus__c';
            queryStr += ' From Apttus_Config2__AssetLineItem__c';
            queryStr += ' Where Apttus_Config2__AccountId__c = :accountID';

            // Added By Viraj Rana || 2016-12-21 || S-444777
            
            if(selectedAction == BIAUsage){
                //queryStr += ' And Proposal__r.OpportunityStage__c = \'BIA/Usage\'';
                queryStr += ' And (Order_Line_Item__r.Order__r.OrderStatus__c = \'Verified\' or Order_Line_Item__r.Order__r.OrderStatus__c = \'Closed\')';

            }
            queryStr += ' And Proposal__r.APTS_Opportunity_Record_Type__c <> \'GCS Opportunity\'';

            if(selectedAction == ProductExtension || selectedAction == Renewal){
                //End Date within 30 Days
                queryStr += ' AND Apttus_Config2__EndDate__c > TODAY ';
                queryStr += ' AND Apttus_Config2__EndDate__c <= NEXT_N_DAYS:30 ';
            }else if(selectedAction == ProductConversion){
                //queryStr += ' AND Apttus_Config2__EndDate__c > NEXT_N_DAYS:60 ';
                queryStr += ' AND Apttus_Config2__EndDate__c > TODAY ';
                queryStr += ' AND Apttus_Config2__StartDate__c < TODAY ';
            }else if(selectedAction == BIAUsage){            // Added By Viraj Rana || 2016-12-21 || S-444777
                queryStr += ' AND ((Proposal__r.Payment1_Frequency__c = \'Contingent W/ Contract\' and  Proposal__r.Latest_End_Date__c>= LAST_N_DAYS:60 ) ' +
                            ' OR (Proposal__r.Payment1_Frequency__c = \'Contingent N/ Contract\' and Proposal__r.Latest_End_Date__c >= LAST_N_DAYS:60 ))';
                            
                            
                            

            }else{
                queryStr += ' AND ( ( Apttus_Config2__ProductId__r.Service_Type__c = \'Subscription\' AND';
                queryStr += '   Apttus_Config2__EndDate__c > NEXT_N_DAYS:30) ';
                queryStr += '      OR';
                queryStr += '   ( Apttus_Config2__ProductId__r.Service_Type__c = \'Usage\' AND';
                queryStr += '     Apttus_Config2__EndDate__c > NEXT_N_DAYS:2)';
                queryStr += '     )';
            }
            if(selectedAction == MidContractQuote){
                queryStr += ' AND Apttus_Config2__ProductId__c IN ';                        //Check if Product is MCQ Eligible
                queryStr += '   (Select Product__c ';
                queryStr += '    From Product_Eligibility_Matrix__c ';
                queryStr += '    Where Is_Mid_Contract_Eligibile__c = true )';
               queryStr += '    AND Apttus_Config2__NetPrice__c <> 0 ';
            }else if(selectedAction == ResumeUpgrade){
                queryStr += ' AND Apttus_Config2__ProductId__r.RU_Eligible__c = true ';     //Check if Product is RU Eligible
            }else if(selectedAction == ProductConversion){
                queryStr += ' AND Apttus_Config2__ProductId__r.Convert_From__c = true ';    //Check if Product is PC Eligible
            }else if(selectedAction == ProductExtension){
                queryStr += ' AND Apttus_Config2__ProductId__r.Product_Extension_Eligible__c = true ';  //Check if Product is PE Eligible
            }
            queryStr += ' AND Proposal__r.QuoteStatus__c IN (\'Accepted Online\', \'Accepted Offline\') ';
            queryStr += ' Order By Apttus_Config2__EndDate__c DESC';

        System.debug(LoggingLevel.INFO,'Query:>>' + queryStr);
        assetLineList = Database.query(queryStr);
        System.debug(LoggingLevel.INFO,'Query Results:' + assetLineList);
        if(selectedAction == ProductConversion  &&
            assetLineList != null               &&
            !assetLineList.isEmpty()){
                //Set Available Quantity for Selected Asset
                assetLineList = setAvailableLicenses(assetLineList);
        }

        return assetLineList;
    }

    //for Product Eligibility Matrix
    public Set<String> getProductEligibilityMatrix(List<Apttus_Config2__AssetLineItem__c> assetLineList){
        System.debug(LoggingLevel.INFO,'Inside getProductEligibilityMatrix');
        Set<String> productIDCountrySet = new Set<String>(); // ProductID # Country
        Set<ID> productIDSet = new Set<ID>();

        for(Apttus_Config2__AssetLineItem__c assetLineItem : assetLineList){
            productIDSet.add(assetLineItem.Apttus_Config2__ProductId__c);
        }
        System.debug(LoggingLevel.INFO,'productIDSet:'+productIDSet);

        for(Product_Eligibility_Matrix__c pem: [Select Product__c, Country__c
                                                From Product_Eligibility_Matrix__c
                                                Where Is_Mid_Contract_Eligibile__c = true
                                                And Product__c IN :productIDSet]){
            productIDCountrySet.add(pem.Product__c + '#' + pem.Country__c);
        }
        System.debug(LoggingLevel.INFO,'productIDCountrySet:'+productIDCountrySet);

        return productIDCountrySet;
    }

    //Get Display Items for Mid Contract Quote
    public String getMCQDisplayLineItems(List<Apttus_Config2__AssetLineItem__c> assetLineList,
                                            Set<String> productIDCountrySet){
        System.debug(LoggingLevel.INFO,'Inside getMCQDisplayLineItems productIDCountrySet:' + productIDCountrySet);
        String proposalDisplayHTML = '';
        List<Apttus_Proposal__Proposal__c> proposalList = new List<Apttus_Proposal__Proposal__c>();
        Set<Id> proposalIds = new Set<Id>();
        quoteIDAssetLineItemMap = new Map<ID, List<Apttus_Config2__AssetLineItem__c>>();
        List<Apttus_Config2__AssetLineItem__c> quoteAssetLineList;
        String key;

        for(Apttus_Config2__AssetLineItem__c assetLineItem : assetLineList){
            key = assetLineItem.Apttus_Config2__ProductId__c + '#' + assetLineItem.Proposal__r.Selling_Country__c;
            //Check if Product is MCQ Eligible for the Quote Selling Country
            System.debug(LoggingLevel.INFO,'Asset Line Item: ' + assetLineItem.Id + ' key:' + key);
            if(productIDCountrySet.contains(key)){
                //Add eligible asset to the Instance Map
                System.debug(LoggingLevel.INFO,'Eligible Proposal ID : ' + assetLineItem.Proposal__c);
                if(quoteIDAssetLineItemMap.containsKey(assetLineItem.Proposal__c)){
                    quoteAssetLineList = quoteIDAssetLineItemMap.get(assetLineItem.Proposal__c);
                }else{
                    quoteAssetLineList = new List<Apttus_Config2__AssetLineItem__c>();
                    proposalList.add(assetLineItem.Proposal__r);
                    proposalIds.add(assetLineItem.Proposal__c);
                }
                quoteAssetLineList.add(assetLineItem);
                quoteIDAssetLineItemMap.put(assetLineItem.Proposal__c, quoteAssetLineList);
            }
        }//for

        //Get Display Proposal Line List
        if(!proposalList.isEmpty()){
            GetProposalsValidOrder(proposalIds);
            proposalDisplayHTML = getDisplayHTMLTable(proposalList);
        }

        System.debug(LoggingLevel.INFO,'proposalDisplayHTML:' + proposalDisplayHTML);
        return proposalDisplayHTML;
    }

    //Issue# I-159729 (3314)
    private void GetProposalsValidOrder(Set<Id> proposalIds)
    {
        if(proposalIds != null)
        {
          for(Order_Line_Item__c currentOrderLine:[Select Id,Order__r.Name,Order__r.QuoteProposal__c From Order_Line_Item__c where Order__r.QuoteProposal__c IN :proposalIds and AssetLineItemId__r.Proposal__c IN :proposalIds])
          {
               proposalsVerifiedOrder.put(currentOrderLine.Order__r.QuoteProposal__c, currentOrderLine.Order__r.Name);
               proposalsVerifiedOrderId.put(currentOrderLine.Order__r.QuoteProposal__c, currentOrderLine.Order__c);
          }
        }
    }

    //Get Display Items for RU/PC Quote
    public String getDisplayLineItems(List<Apttus_Config2__AssetLineItem__c> assetLineList){
        System.debug(LoggingLevel.INFO,'Inside getDisplayLineItems assetLineList:' + assetLineList);
        List<Apttus_Proposal__Proposal__c> proposalList = new List<Apttus_Proposal__Proposal__c>();
        Set<Id> proposalIds = new Set<Id>();
        String proposalDisplayHTML = '';

        quoteIDAssetLineItemMap = new Map<ID, List<Apttus_Config2__AssetLineItem__c>>();
        List<Apttus_Config2__AssetLineItem__c> quoteAssetLineList;

        for(Apttus_Config2__AssetLineItem__c assetLineItem : assetLineList){
            System.debug(LoggingLevel.INFO,'Proposal ID : ' + assetLineItem.Proposal__c);
            if(quoteIDAssetLineItemMap.containsKey(assetLineItem.Proposal__c)){
                quoteAssetLineList = quoteIDAssetLineItemMap.get(assetLineItem.Proposal__c);
            }else{
                quoteAssetLineList = new List<Apttus_Config2__AssetLineItem__c>();
                proposalList.add(assetLineItem.Proposal__r);
                proposalIds.add(assetLineItem.Proposal__c);
            }
            quoteAssetLineList.add(assetLineItem);
            quoteIDAssetLineItemMap.put(assetLineItem.Proposal__c, quoteAssetLineList);

        }//for

        //Get Display Proposal Line List
        if(!proposalList.isEmpty()){
            GetProposalsValidOrder(proposalIds);
           proposalDisplayHTML = getDisplayHTMLTable(proposalList);

        }

        System.debug(LoggingLevel.INFO,'proposalDisplayHTML:' + proposalDisplayHTML);
        return proposalDisplayHTML;
    }

    /*
        Method to generate output HTML Table
    */
    public String getDisplayHTMLTable(List<Apttus_Proposal__Proposal__c> proposalList){
        System.debug(LoggingLevel.INFO,'Inside getDisplayHTMLTable proposalList:' + proposalList);
        List<Apttus_Config2__AssetLineItem__c> quoteAssetLineList;

        //Generate Proposal Display Row
        String outputHTML = '';
        outputHTML += '<table id=\'report\'> ';
        outputHTML += '<thead> ';
        outputHTML += '    <tr> ';
        outputHTML += '    <th></th> ';
        outputHTML += '    <th></th> ';
        outputHTML += '    <th>Proposal ID</th> ';
        outputHTML += '    <th>Proposal Name</th> ';
        outputHTML += '    <th>Opportunity</th> ';
        outputHTML += '    <th>Account</th> ';
        outputHTML += '    <th>Order #</th> ';
        outputHTML += '    <th>Contract Start Date</th> ';
        outputHTML += '    <th>Contract End Date</th> ';
        outputHTML += '    <th>Quote Total Net Amount</th> ';
        outputHTML += '    <th>Quote Status</th> ';
        //outputHTML += '      <th>Quote Agency Commission %</th> ';
        outputHTML += '    </tr> ';
        outputHTML += '</thead> ';
        outputHTML += '<tbody> ';
        for(Apttus_Proposal__Proposal__c proposal : proposalList){
            outputHTML += '    <tr class=\'proprow\'> ';
            outputHTML += '       <td> ';
            outputHTML += '           <input type=\'radio\' value=\''+proposal.ID+'\' id=\'radioComp\' name=\'radioComp\' onchange=\'setSelectedProposal()\' /> ';
            outputHTML += '       </td> ';
            outputHTML += '       <td class=\'tdarrow\'><div class=\'arrow\'></div></td> ';
            outputHTML += '       <td class="alignleft">'+displayStr(proposal.Name)+'</td> ';
            outputHTML += '       <td class="alignleft">'+displayStr(proposal.Apttus_Proposal__Proposal_Name__c)+'</td> ';
            outputHTML += '       <td class="alignleft">'+displayStr(proposal.Apttus_Proposal__Opportunity__r.Name)+'</td> ';
            outputHTML += '       <td class="alignleft">'+displayStr(proposal.Apttus_Proposal__Account__r.Name)+'</td> ';
            outputHTML += '       <td class="alignleft">'+displayStr(proposalsVerifiedOrder.get(proposal.Id))+'</td> ';
            outputHTML += '       <td>'+displayDt(proposal.Earliest_Start_Date__c)+'</td> ';
            outputHTML += '       <td>'+displayDt(proposal.Latest_End_Date__c)+'</td> ';
            outputHTML += '       <td class="alignright">'+displayCurr(proposal.CurrencyIsoCode, proposal.NetOrderAmount__c)+'</td> ';
            outputHTML += '       <td>'+displayStr(proposal.QuoteStatus__c)+'</td> ';
            //outputHTML += '         <td>'+displayDec(proposal.AgencyCommission__c)+'</td> ';
            outputHTML += '    </tr> ';
            outputHTML += '    <tr class=\'itemrow\'> ';
            outputHTML += ' <td></td> ';
            outputHTML += ' <td></td> ';
            outputHTML += ' <td colspan=\'8\'> ';
            outputHTML += '     <table id=\'lineItems\'> ';
            outputHTML += '     <thead> ';
            outputHTML += '         <tr> ';
            outputHTML += '         <th>Product Name</th> ';
            outputHTML += '         <th>Product Code</th> ';
            outputHTML += '         <th>Base Price</th> ';
            outputHTML += '         <th>Net Price</th> ';
            outputHTML += '         <th>Quantity</th> ';
            outputHTML += '         <th>Start Date</th> ';
            outputHTML += '         <th>End Date</th> ';
            outputHTML += '         </tr> ';
            outputHTML += '     </thead> ';
            outputHTML += '     <tbody> ';
            if(quoteIDAssetLineItemMap.containsKey(proposal.ID)){
                quoteAssetLineList = quoteIDAssetLineItemMap.get(proposal.ID);
                for(Apttus_Config2__AssetLineItem__c assetLineItem : quoteAssetLineList){
                    outputHTML += '     <tr> ';
                    outputHTML += '       <td class="alignleft">'+displayStr(assetLineItem.Apttus_Config2__ProductId__r.Name) + '</td> ';
                    outputHTML += '       <td class="alignleft">'+displayStr(assetLineItem.Apttus_Config2__ProductId__r.ProductCode) +'</td> ';
                    outputHTML += '       <td class="alignright">'+displayCurr(assetLineItem.CurrencyIsoCode, assetLineItem.Apttus_Config2__BasePrice__c) +'</td> ';
                    outputHTML += '       <td class="alignright">'+displayCurr(assetLineItem.CurrencyIsoCode, assetLineItem.Apttus_Config2__NetPrice__c) +'</td> ';
                    outputHTML += '       <td>'+displayInt(assetLineItem.Apttus_Config2__Quantity__c) +'</td> ';
                    outputHTML += '       <td>'+displayDt(assetLineItem.Apttus_Config2__StartDate__c) +'</td> ';
                    outputHTML += '       <td>'+displayDt(assetLineItem.Apttus_Config2__EndDate__c) +'</td> ';
                    outputHTML += '     </tr> ';
                }//for
            }//if

            outputHTML += '     </tbody> ';
            outputHTML += '     </table> ';
            outputHTML += ' </td> ';
            outputHTML += ' </tr> ';
        }//for

        outputHTML += '</tbody> ';
        outputHTML += '</table> ';

        System.debug(LoggingLevel.INFO,'outputHTML:' + outputHTML);
        return outputHTML;
    }

    public ID executeAccountActions(String selectedAction, String selectedProposalID, ID accountID){
        System.debug(LoggingLevel.INFO,'Inside executeAccountActions selectedAction:' + selectedAction +
                                                ' selectedProposalID:' + selectedProposalID +
                                                ' accountID:' + accountID);
        message = '';
        ID newProposalID = null;
        if(selectedProposalID == null || selectedProposalID.trim() == ''){
            message = 'Please Select a Proposal.';
            return null;
        }
        Savepoint sp = null;
        try{
            if(selectedAction == MidContractQuote   ||
                selectedAction == Renewal           ||
                selectedAction == ResumeUpgrade     ||
                selectedAction == ProductConversion ||
                selectedAction == ProductExtension ||
                selectedAction == BIAUsage){

                System.debug('*123#:' +quoteIDAssetLineItemMap + ' : ' + selectedProposalID );
                List<Apttus_Config2__AssetLineItem__c> assetLineList = new List<Apttus_Config2__AssetLineItem__c> ();
                // commented for I-230717
                /*if(selectedAction == ProductConversion){
                    assetLineList = setAvailableLicenses2(quoteIDAssetLineItemMap.get(selectedProposalID));
                }*/
                assetLineList = quoteIDAssetLineItemMap.get(selectedProposalID);
                System.debug('*123#:' +assetLineList );
                //Set Savepoint
                sp = Database.setSavepoint();
                //  Clear All - Asset Flag and Allowed Actions
                clearAccountAssetsFlag(accountID);
                //  Update Assets Flag and Allowed Actions(MCQ-Increment / RU-Amend / PC-Cancel) related to selected Proposal.
                updateAssetsForProposal(assetLineList, selectedAction);
                //  Create Oppty and Proposal related to Account
                newProposalID = createOpptyandQuote(selectedProposalID, selectedAction);

            }
        }catch(Exception ex){
            //Rollback incase of Exceptions
            if(sp != null){
                Database.rollback(sp);
                System.debug(LoggingLevel.ERROR,'Error: Roll Back the transaction.');
            }
            System.debug(LoggingLevel.ERROR,'Exception occured in getQuoteByAccountAction:' + ex.getMessage());
            System.debug(LoggingLevel.ERROR,'Exception StackTrace:' + ex.getStackTraceString());
            message += ' Error Details:'+ex.getMessage();
            return null;
        }
        return newProposalID;
    }

    /*  Create Oppty related to Account
     * Create new Proposal related to the Oppty with Appropriate Quote Type.
     **/
    public ID createOpptyandQuote(String selectedProposalID, String selectedAction){
        System.debug(LoggingLevel.INFO,'Inside createOpptyandQuote selectedProposalID' + selectedProposalID);
        //TODO: Update Original Asset Query to Fetch Proposal and Oppty Details.
        String queryStr = '';
            queryStr += ' Select ID, Name,AgencyCommission__c,';
            queryStr += '  APTS_Quote_Type__c, RecordTypeID,';
            queryStr += '  Earliest_Start_Date__c, Latest_End_Date__c,';
            queryStr += '  Apttus_QPConfig__PriceListId__c,';
            queryStr += '  CurrencyIsoCode, Language__c,';
            queryStr += '  Selling_Country__c,';
            queryStr += '  Apttus_Proposal__Account__c, Apttus_Proposal__Account__r.Name,';
            queryStr += '  Apttus_Proposal__Opportunity__c,';
            queryStr += '  Apttus_Proposal__Opportunity__r.RecordTypeID,';
            queryStr += '  Apttus_Proposal__Opportunity__r.Organization__c,';
            queryStr += '  Apttus_Proposal__Account__r.Organization__c,';
            queryStr += '  BillingAccount__r.Payment_Method__c,';
            queryStr += '  Agency__c,';
            queryStr += '  Agency__r.AgencyCommission__c,';
            queryStr += '  Local_Agency_Address__c,';
            queryStr += '  AgencyBillingContact__c,';
            queryStr += '  Payment1_Frequency__c,';
            queryStr += '  Payment1_Term__c,';
            queryStr += '  Payment_Method1__c,';
            queryStr += '  AgencyIO__c,';
            queryStr += '  BIAUsage_Proposal__c ,';
            queryStr += '  Agency_Billing_Contact_Email_Address__c,';
            queryStr += '  Apttus_Proposal__Opportunity__r.OpportunitySource__c';
            queryStr += ' From Apttus_Proposal__Proposal__c';
            queryStr += ' Where ID = :selectedProposalID';

        System.debug(LoggingLevel.INFO,'queryStr' + queryStr);
        Apttus_Proposal__Proposal__c oldProposal = Database.query(queryStr);
        System.debug(LoggingLevel.INFO,'Query Results:' + oldProposal);

        //Create Opportunity
        Opportunity oppty = new Opportunity();
        try{
            oppty.Name = selectedAction + '-' + oldProposal.Apttus_Proposal__Account__r.Name + '-' + Datetime.now().format('MM/dd/yyyy');
            If(oldProposal.Apttus_Proposal__Opportunity__r.RecordTypeID!=null ){
                oppty.RecordTypeId = oldProposal.Apttus_Proposal__Opportunity__r.RecordTypeID;
            }
            else
            {
                 ID opptyRecordID ;

                if(oldProposal.Apttus_Proposal__Account__r.Organization__c=='North America'){
                     opptyRecordID= Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity','NA - Sales Rep Opportunity');
                }
                else if(oldProposal.Apttus_Proposal__Account__r.Organization__c=='Europe'){
                    opptyRecordID= Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity','EU - Sales Rep Opportunity');
                }
                else
                {
                    opptyRecordID= Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity','Opportunity');
                }


                 oppty.RecordTypeId =opptyRecordID;

            }
            oppty.OpportunitySource__c = 'Quote';
            if(selectedAction == ProductExtension){
                oppty.OpportunityType__c = 'Make Good';
            }if(selectedAction == Renewal){
                oppty.OpportunityType__c = 'Renewal';
            }else{
                oppty.OpportunityType__c = 'Upsell';
                oppty.IsAssetOpportunity__c = True;
            }
            oppty.Amount = 1.0;
            oppty.Skip_Stage_Validation__c = true;


            //S-444777 - Apttus
            if(selectedAction == BIAUsage){
                oppty.StageName = 'BIA/Usage';
                oppty.Type = 'BIA/Usage';
                oppty.OpportunityType__c = 'BIA/Usage';

                oppty.CloseDate = System.Today().addMonths(1).toStartofMonth().addDays(-1);

                if(oldProposal.Payment1_Frequency__c == 'Contingent W/ Contract'){
                    oppty.Commitment_Type__c = 'Commitment';
                    oppty.Include_BIA_Usage_in_Forecast__c = false;
                    oppty.ForecastCategoryName = 'Omitted';
                }else if(oldProposal.Payment1_Frequency__c == 'Contingent N/ Contract'){
                    oppty.Commitment_Type__c = 'No Commitment';
                    oppty.Include_BIA_Usage_in_Forecast__c = True;
                    oppty.ForecastCategoryName = 'Commit';
                }
            }else{
                oppty.StageName = 'Stage 2 - Proposal';         ///I-176319 - Apttus
                oppty.CloseDate = Datetime.now().addMonths(1).dateGMT();
            }

            oppty.AccountID = oldProposal.Apttus_Proposal__Account__c;
            oppty.CurrencyIsoCode = oldProposal.CurrencyIsoCode;
            if(oldProposal.Apttus_Proposal__Opportunity__r.Organization__c!=null)
                oppty.Organization__c = oldProposal.Apttus_Proposal__Opportunity__r.Organization__c;
            else
                oppty.Organization__c = oldProposal.Apttus_Proposal__Account__r.Organization__c;


            System.debug(LoggingLevel.INFO,'Before opportunity Insert:' + oppty);
            insert oppty;
            System.debug(LoggingLevel.INFO,'After opportunity Insert');
        }catch(Exception ex){
            System.debug(LoggingLevel.INFO,'Create Oppty Exception StackTrace:' + ex.getStackTraceString());
            message += 'Error while creating Opportunity.';
            throw ex;
        }

        //Create Proposal
        Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c();
        try{
            if(selectedAction == BIAUsage){
                //proposal = oldProposal;
                proposal.Payment_Method1__c = oldProposal.BillingAccount__r.Payment_Method__c;
                proposal.Payment1_Term__c = oldProposal.Payment1_Term__c;
                proposal.APTS_Quote_Type__c = 'BIA/Usage';
                proposal.BIAUsage_Proposal__c = true;
                System.debug('oldProposal' + oldProposal.Payment1_Frequency__c);
                if(oldProposal.Payment1_Frequency__c == 'Contingent W/ Contract'){
                    proposal.Payment1_Frequency__c = 'Usage W/ Contract';
                }else if(oldProposal.Payment1_Frequency__c == 'Contingent N/ Contract'){
                    proposal.Payment1_Frequency__c = 'Usage N/ Contract';
                }else{
                    proposal.Payment1_Frequency__c = oldProposal.Payment1_Frequency__c;
                }
                System.debug('proposal' + proposal.Payment1_Frequency__c);
            }else{
                proposal.APTS_Quote_Type__c = GetAppropriateQuoteTypeForProposal(selectedAction);
            }
            System.debug('proposal' + proposal.Payment1_Frequency__c);
            proposal.RecordTypeId = oldProposal.RecordTypeId;
//B)    For S-319250 – 0944            //story 944
            if(selectedAction == MidContractQuote){
                proposal.MidContract_Proposal__c = true;
            }
            if(selectedAction == ResumeUpgrade){
                proposal.Upgrade_Proposal__c = true;
            }
            // I-213467 changes
            if(selectedAction == ProductConversion){
                proposal.Conversion_Proposal__c = true;
            }



            proposal.Apttus_Proposal__Proposal_Name__c = selectedAction + '-' + oldProposal.Apttus_Proposal__Account__r.Name + '-' + Datetime.now().format('MM/dd/yyyy');
            proposal.Apttus_Proposal__Opportunity__c = oppty.ID;
            proposal.Earliest_Start_Date__c = oldProposal.Earliest_Start_Date__c;
            proposal.Latest_End_Date__c = oldProposal.Latest_End_Date__c;
            proposal.Apttus_QPConfig__PriceListId__c = oldProposal.Apttus_QPConfig__PriceListId__c;
            proposal.CurrencyIsoCode = oldProposal.CurrencyIsoCode;
            proposal.Selling_Country__c = oldProposal.Selling_Country__c;
            proposal.Apttus_Proposal__Account__c = oldProposal.Apttus_Proposal__Account__c;
            proposal.RelatedQuoteProposal__c = selectedProposalID;
            proposal.Language__c = oldProposal.Language__c;

            //changes for I-227642
            proposal.Agency__c = oldProposal.Agency__c;
            proposal.Local_Agency_Address__c = oldProposal.Local_Agency_Address__c;
            proposal.AgencyBillingContact__c=oldProposal.AgencyBillingContact__c;
            proposal.Agency_Billing_Contact_Email_Address__c =oldProposal.Agency_Billing_Contact_Email_Address__c;
            proposal.AgencyIO__c =oldProposal.AgencyIO__c;

            //I-227642 By Viraj Rana
            if(oldProposal.Agency__c!=null){
                //proposal.AgencyCommission__c = oldProposal.Agency__r.AgencyCommission__c;
                proposal.AgencyCommission__c = oldProposal.AgencyCommission__c;
            }
            //changes for I-227642

         //   proposal.OrigOrderMCRUConv__c = proposalsVerifiedOrderID.get(oldProposal.id);   //Issue-I-171251
            proposal.Orig_Order_link__c = proposalsVerifiedOrderID.get(oldProposal.id);   //Issue-I-171251


            System.debug(LoggingLevel.INFO,'Before Proposal Insert:' + proposal);
            insert proposal;
            System.debug(LoggingLevel.INFO,'After Proposal Insert:' + proposal);
        }catch(Exception ex){
            System.debug(LoggingLevel.INFO,'Exception while inserting Proposal. StackTrace:' + ex.getStackTraceString());
            message += 'Error while inserting Quote/Proposal.';
            throw ex;
        }
        return proposal.ID;
    }

    //  Clear All - Asset Flag and Allowed Actions
    public void clearAccountAssetsFlag(ID accountID){
        System.debug(LoggingLevel.INFO,'Inside clearAccountAssetsFlag accountID:' + accountID);
        List<Apttus_Config2__AssetLineItem__c> assetLineList = [Select ID, Is_Advanced_Quote_Item__c, Apttus_Config2__AllowedActions__c
                                                                From Apttus_Config2__AssetLineItem__c
                                                                Where Apttus_Config2__AccountId__c = :accountID
                                                                AND (Is_Advanced_Quote_Item__c = true
                                                                    OR Apttus_Config2__AllowedActions__c != null)];
        System.debug(LoggingLevel.INFO,'assetLineList:' + assetLineList);
        for(Apttus_Config2__AssetLineItem__c assetLineItem : assetLineList){
            assetLineItem.Is_Advanced_Quote_Item__c = false;
            assetLineItem.Apttus_Config2__AllowedActions__c = null;
        }
        if(assetLineList != null && !assetLineList.isEmpty()){
            System.debug(LoggingLevel.INFO,'before update assetLineList');
            update assetLineList;
            System.debug(LoggingLevel.INFO,'after update assetLineList');
        }
    }

    //  Update Assets Flag and Allowed Actions(MCQ-Increment / RU-Amend) related to selected Proposal.
    public void updateAssetsForProposal(List<Apttus_Config2__AssetLineItem__c> assetLineList, String selectedAction){
        System.debug(LoggingLevel.INFO,'Inside updateAssetsForProposal:' + assetLineList + ' selectedAction:'+selectedAction);
        String allowedActions;
        if(selectedAction == MidContractQuote ||
            selectedAction == BIAUsage
        ){
            allowedActions = 'Increment';
        }else if(selectedAction == ResumeUpgrade){
            allowedActions = 'Amend';
        }else if(selectedAction == ProductConversion){
            allowedActions = 'Cancel';
        }else if(selectedAction == ProductExtension ||
                 selectedAction == Renewal){
            allowedActions = 'Renew';
        }
        for(Apttus_Config2__AssetLineItem__c assetLineItem : assetLineList){
            assetLineItem.Is_Advanced_Quote_Item__c = true;
            assetLineItem.Apttus_Config2__AllowedActions__c = allowedActions;
        }
        System.debug(LoggingLevel.INFO,'before update assetLineList');
        update assetLineList;
        System.debug(LoggingLevel.INFO,'after update assetLineList');
    }

    public String displayStr(String input){
        if(input == null) return '';
        return input;
    }
    public String displayInt(Decimal input){
        if(input == null) return '';
        return ((Decimal)input).intValue()+'';
    }
    public String displayDec(Decimal input){
        if(input == null) return '';
        return input.setScale(2).toPlainString();
    }
    public String displayDt(Date input){
        if(input == null) return '';
        return Datetime.newInstanceGmt(input.year(), input.month(), input.day()).formatGmt('MM/dd/yyyy');
    }
    public String displayCurr(String iso, Decimal input){
        if(input == null) return '';
        return iso + ' ' + displayDec(input);
    }

    //Inventory Related
    public List<Apttus_Config2__AssetLineItem__c> setAvailableLicenses(List<Apttus_Config2__AssetLineItem__c> assetLineList){
        //Query all related licenses IDs
        System.debug(LoggingLevel.INFO, 'Inside setAvailableLicenses assetLineList:' + assetLineList);
        Map<ID, Apttus_Config2__AssetLineItem__c> otherAssetLineMap = new Map<ID, Apttus_Config2__AssetLineItem__c>();
        Map<ID, Apttus_Config2__AssetLineItem__c> usageAssetLineMap = new Map<ID, Apttus_Config2__AssetLineItem__c>();

        Map<String, ID> licenseAssetIDMap = new Map<String, ID>();

        for(Apttus_Config2__AssetLineItem__c assetLine : assetLineList){
            if(assetLine.Apttus_Config2__ProductId__r.Service_Type__c == 'Usage'){
                assetLine.Available_Quantity__c = 0; //Reset Available Quantity for Usage Based Products
                usageAssetLineMap.put(assetLine.ID, assetLine);
            }else{
                otherAssetLineMap.put(assetLine.ID, assetLine);
            }
        }
        System.debug(LoggingLevel.INFO, '>> usageAssetLineMap:' + usageAssetLineMap);
        if(usageAssetLineMap.isEmpty()){
            System.debug(LoggingLevel.INFO, 'No Usage Assets Found. Returning remaining Asset list:'+otherAssetLineMap);
            return otherAssetLineMap.values();
        }

        Set<String> LicenseIDSet = new Set<String>();
        Map<String, Integer> responseMap = new Map<String, Integer>();
        for(LicenseID__c license : [Select Id, SiteLicenseID__c,
                                        AvailableInventory__c,
                                        OrderLineItem__r.AssetLineItemId__c
                                    From LicenseID__c
                                    Where OrderLineItem__r.AssetLineItemId__c IN :usageAssetLineMap.keySet()
                                    AND SiteLicenseID__c != null]){

            if(license.SiteLicenseID__c != null && license.AvailableInventory__c != null){
                responseMap.put(license.SiteLicenseID__c, Math.round(license.AvailableInventory__c));
                LicenseIDSet.add(license.SiteLicenseID__c);
                licenseAssetIDMap.put(license.SiteLicenseID__c, license.OrderLineItem__r.AssetLineItemId__c);
            }
        }
        System.debug(LoggingLevel.INFO,'>> LicenseIDSet:' + LicenseIDSet);
        if(LicenseIDSet.isEmpty()){
            System.debug(LoggingLevel.INFO, 'No Licenses found for Usage Assets. Returning remaining Asset list:'+otherAssetLineMap);
            return otherAssetLineMap.values();
        }
        //Call webservice
        System.debug(LoggingLevel.INFO,'Before calling getInventoryData:' + LicenseIDSet);
        //Jeff L, hack for Apex timeout issue
        //Map<String, Integer> responseMap = getInventoryData(LicenseIDSet);


        //Summarice the Available Quantity per Asset
        Integer availableQuantity;
        Apttus_Config2__AssetLineItem__c asset;

        //Parse the Response.
        if(responseMap != null && !responseMap.isEmpty()){
            for(String licenseID : responseMap.keySet()){
                availableQuantity = responseMap.get(licenseID);
                if(availableQuantity != null && availableQuantity != 0){
                    asset = usageAssetLineMap.get(licenseAssetIDMap.get(licenseID));
                    if(asset != null){
                        System.debug(LoggingLevel.INFO, 'Before Updating AssetID :' + asset.ID +
                                        ' asset.availableQuantity' + asset.Available_Quantity__c +
                                        ' availableQuantity:' + availableQuantity);
                        if(asset.Available_Quantity__c == null) asset.Available_Quantity__c = 0;
                        asset.Available_Quantity__c += availableQuantity;
                        System.debug(LoggingLevel.INFO,'After Updating asset.availableQuantity' + asset.Available_Quantity__c);
                    }else{
                        System.debug(LoggingLevel.INFO,'Error: No Asset Mapping defined for License ID' + licenseID);
                    }
                }
            }//for
        }//If Response NULL

        //Remove Asset Line Items with Available Quantity = 0
        Set<Id> assetIDSet = usageAssetLineMap.keySet();
        System.debug(LoggingLevel.INFO,'Before removing 0 Available Quantity:' + usageAssetLineMap);
        for(Id assetID : assetIDSet){
            asset = usageAssetLineMap.get(assetID);
            if(asset.Available_Quantity__c == null ||
               asset.Available_Quantity__c <= 0){
                   usageAssetLineMap.remove(assetID);
               }
        }//for
        System.debug(LoggingLevel.INFO,'After removing 0 Available Quantity:' + usageAssetLineMap);

        //Merge all Asset Line Items into one Map
        otherAssetLineMap.putAll(usageAssetLineMap);
        System.debug(LoggingLevel.INFO,'Exit setAvailableLicenses assetLineMap:' + otherAssetLineMap);

        return otherAssetLineMap.values();
    }

    //Inventory Related
    //This one is a hack to get around an issue where we are recieving too much data from SFDC in the getInventory callout,
    //we only make the call now at this point
    public List<Apttus_Config2__AssetLineItem__c> setAvailableLicenses2(List<Apttus_Config2__AssetLineItem__c> assetLineList){
        //Query all related licenses IDs
        System.debug(LoggingLevel.INFO, 'Inside setAvailableLicenses assetLineList:' + assetLineList);
        Map<ID, Apttus_Config2__AssetLineItem__c> otherAssetLineMap = new Map<ID, Apttus_Config2__AssetLineItem__c>();
        Map<ID, Apttus_Config2__AssetLineItem__c> usageAssetLineMap = new Map<ID, Apttus_Config2__AssetLineItem__c>();

        Map<String, ID> licenseAssetIDMap = new Map<String, ID>();

        for(Apttus_Config2__AssetLineItem__c assetLine : assetLineList){
            if(assetLine.Apttus_Config2__ProductId__r.Service_Type__c == 'Usage'){
                assetLine.Available_Quantity__c = 0; //Reset Available Quantity for Usage Based Products
                usageAssetLineMap.put(assetLine.ID, assetLine);
            }else{
                otherAssetLineMap.put(assetLine.ID, assetLine);
            }
        }
        System.debug(LoggingLevel.INFO, '>> usageAssetLineMap:' + usageAssetLineMap);
        if(usageAssetLineMap.isEmpty()){
            System.debug(LoggingLevel.INFO, 'No Usage Assets Found. Returning remaining Asset list:'+otherAssetLineMap);
            return otherAssetLineMap.values();
        }

        Set<String> LicenseIDSet = new Set<String>();
        //Map<String, Integer> responseMap = new Map<String, Integer>();
        for(LicenseID__c license : [Select Id, SiteLicenseID__c,
                                        AvailableInventory__c,
                                        OrderLineItem__r.AssetLineItemId__c
                                    From LicenseID__c
                                    Where OrderLineItem__r.AssetLineItemId__c IN :usageAssetLineMap.keySet()
                                    AND SiteLicenseID__c != null]){

            if(license.SiteLicenseID__c != null){
                //responseMap.put(license.SiteLicenseID__c, Math.round(license.AvailableInventory__c));
                LicenseIDSet.add(license.SiteLicenseID__c);
                licenseAssetIDMap.put(license.SiteLicenseID__c, license.OrderLineItem__r.AssetLineItemId__c);
            }
        }
        System.debug(LoggingLevel.INFO,'>> LicenseIDSet:' + LicenseIDSet);
        if(LicenseIDSet.isEmpty()){
            System.debug(LoggingLevel.INFO, 'No Licenses found for Usage Assets. Returning remaining Asset list:'+otherAssetLineMap);
            return otherAssetLineMap.values();
        }
        //Call webservice
        System.debug(LoggingLevel.INFO,'Before calling getInventoryData:' + LicenseIDSet);
        Map<String, Integer> responseMap = getInventoryData(LicenseIDSet);


        //Summarice the Available Quantity per Asset
        Integer availableQuantity;
        Apttus_Config2__AssetLineItem__c asset;

        //Parse the Response.
        if(responseMap != null && !responseMap.isEmpty()){
            for(String licenseID : responseMap.keySet()){
                availableQuantity = responseMap.get(licenseID);
                if(availableQuantity != null && availableQuantity != 0){
                    asset = usageAssetLineMap.get(licenseAssetIDMap.get(licenseID));
                    if(asset != null){
                        System.debug(LoggingLevel.INFO, 'Before Updating AssetID :' + asset.ID +
                                        ' asset.availableQuantity' + asset.Available_Quantity__c +
                                        ' availableQuantity:' + availableQuantity);
                        if(asset.Available_Quantity__c == null) asset.Available_Quantity__c = 0;
                        asset.Available_Quantity__c += availableQuantity;
                        System.debug(LoggingLevel.INFO,'After Updating asset.availableQuantity' + asset.Available_Quantity__c);
                    }else{
                        System.debug(LoggingLevel.INFO,'Error: No Asset Mapping defined for License ID' + licenseID);
                    }
                }
            }//for
        }//If Response NULL

        //Remove Asset Line Items with Available Quantity = 0
        Set<Id> assetIDSet = usageAssetLineMap.keySet();
        System.debug(LoggingLevel.INFO,'Before removing 0 Available Quantity:' + usageAssetLineMap);
        for(Id assetID : assetIDSet){
            asset = usageAssetLineMap.get(assetID);
            if(asset.Available_Quantity__c == null ||
               asset.Available_Quantity__c <= 0){
                   usageAssetLineMap.remove(assetID);
               }
        }//for
        System.debug(LoggingLevel.INFO,'After removing 0 Available Quantity:' + usageAssetLineMap);

        //Merge all Asset Line Items into one Map
        otherAssetLineMap.putAll(usageAssetLineMap);
        System.debug(LoggingLevel.INFO,'Exit setAvailableLicenses assetLineMap:' + otherAssetLineMap);

        return otherAssetLineMap.values();
    }

    //Return Map LicenseID and AvailableQuantity
    public Map<String, Integer> getInventoryData(Set<String> LicenseIDSet){
        System.debug(LoggingLevel.INFO,'Inside getInventoryData LicenseIDSet:' + LicenseIDSet);
        Map<String, Integer> responseMap = BizAppsSiteModel.GetLicenseAndRelativesForCreditRequest(LicenseIDSet);
        System.debug(LoggingLevel.INFO,'responseMap:' + responseMap);
        return responseMap;
    }

    //story 944
    //(Quote Type ( Picklist on the Quote/Proposal Object) should be set to 'Upsell' for MidContract and Resume Upgrade Proposals.)
    private string GetAppropriateQuoteTypeForProposal(string selectedAction)
    {
        if(selectedAction == MidContractQuote || selectedAction == ResumeUpgrade)
        {
            return 'Upsell';
        }
        return selectedAction;
    }
}