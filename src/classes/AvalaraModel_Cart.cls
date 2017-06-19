global class AvalaraModel_Cart {
/*******************************************************************************************
 JHF 3/16/16 If you make any changes to this file, be sure to
 check to see if the same change is needed in AvalaraModel.cls

 Or better yet, refactor these when time permits to use a common source for code in common.
 Jeff L: 3/31/16 - refactored! Moved relevant code into AvalaraModel.  Just left stubs here since
 they called from a variety of places in the cart
********************************************************************************************/

    public static String IsToCommit = 'false';

    private AvalaraSchema.RequestHeader Header;
    public String RawResult;

    public AvalaraModel_Cart(AvalaraSchema.RequestHeader pHeader){
        system.debug('\n\n **** Inside AvalaraModel_Cart.AvalaraModel_Cart()');

        Header = pHeader;
    }

    /*public AvalaraSchema.GetTaxResponse GetTax(AvalaraSchema.GetTaxRequest pRequest){
        system.debug('\n\n **** Inside AvalaraModel_Cart.GetTax()');
        AvalaraSchema.GetTaxResponse errorResponse = new AvalaraSchema.GetTaxResponse();

        try{
            HttpResponse getTaxResponse = invoke(pRequest.serialize());
            String JSonString = getTaxResponse.getBody();

            //system.debug('\n\n' + JSonString + '\n\n');

           if(getTaxResponse.getStatusCode() != 200){
              //When Http Error occurs
                if(getTaxResponse.getStatusCode() == 500){
                    AvalaraSchema.GetTaxErrorResponse error500 = (AvalaraSchema.GetTaxErrorResponse)JSON.deserialize(JSonString, AvalaraSchema.GetTaxErrorResponse.class);
                    errorResponse.Messages = error500.Messages;
                    errorResponse.ResultCode = 'Error';
                }else{
                    errorResponse.ResultCode = 'Http Status: ' + getTaxResponse.getStatusCode();

                    AvalaraSchema.Message errorMsg = new AvalaraSchema.Message();
                    errorMsg.Severity = 'Error';

                    errorMsg.RefersTo = getTaxResponse.getStatus();
                    errorMsg.Summary = 'Romete server responded with ' + errorResponse.ResultCode;
                    errorMsg.Details = '';

                    errorResponse.Messages = new AvalaraSchema.Message[]{errorMsg};
                }

                    errorResponse.TimeStamp = String.valueOf(DateTime.now());

                    return errorResponse;
        }

        return (AvalaraSchema.GetTaxResponse)JSON.deserialize(JSonString, AvalaraSchema.GetTaxResponse.class);
    }catch(Exception e){
            system.debug('\n\nError: ' + e + '\n\n');
            errorResponse.ResultCode = 'Internal Error';
            AvalaraSchema.Message errorMsg = new AvalaraSchema.Message();
            errorMsg.Severity = 'Error';

            errorMsg.RefersTo = '';
            errorMsg.Summary = 'A problem has occurred & processing cannot complete successfully - please see system log for details.';
            errorMsg.Details = '' + e;
            errorResponse.Messages = new AvalaraSchema.Message[]{errorMsg};
        }
        return errorResponse;
    }*/

    /*private static AvalaraSchema.RequestHeader getAvalaraSetting(){
        Utility.IntegrationSetting setting = Utility.getIntegrationSetting('Avalara Integration');

        if(setting == null || setting.AvalaraClient == null || setting.AvalaraCompanyCode == null || setting.Username == null || setting.Password == null){
            system.debug('\n\nInvalid Avalara Integration setting.\n\nSettings:'+JSON.serializePretty(setting)+'\n\n\n');
            return null;
        }

        AvalaraSchema.RequestHeader header = new AvalaraSchema.RequestHeader();
        header.EndPoint = setting.Endpoint;
        header.Client = setting.AvalaraClient;
        header.CompanyCode = setting.AvalaraCompanyCode;
        header.Password = setting.Password;
        header.Username = setting.Username;
        header.Country = setting.AvalaraCountry;
        return header;
    }*/

    /*private String getAuthorizationHeader(){
        system.debug('\n\n **** Inside getAuthorizationHeader.getAuthorizationHeader()');

        Blob headerValue = Blob.valueOf(Header.Username+':'+Header.Password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        return authorizationHeader;
    }*/

    /*private HttpResponse invoke(String ReqBody){
        system.debug('\n\n **** Inside AvalaraModel_Cart.invoke()');

        HttpRequest req = new HttpRequest();
        req.setMethod(Header.Method);
        req.setHeader('Authorization', getAuthorizationHeader());
        req.setEndPoint(Header.EndPoint);
        req.setBody(ReqBody);

        Http h = new Http();
        HttpResponse res = h.send(req);
        return res;
    }*/

    /*public AvalaraSchema.GetTaxRequest configGenerateRequest(Apttus_Config2__ProductConfiguration__c config){
        system.debug('\n\n **** Inside AvalaraModel_Cart.ProposalGenerateRequest()');

        AvalaraSchema.GetTaxRequest request = new AvalaraSchema.GetTaxRequest();

        request.IsToCommitDocument = IsToCommit == null ? 'false' : IsToCommit; //needs additional considerations

        request.BusinessIdentificationNo = config.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.VATNumber__c;
        request.CustomerCode = config.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.AccountID__c;

        request.DetailLevel = 'Line';
        request.CompanyCode = config.Apttus_QPConfig__Proposald__r.Avalara_CompanyCode__c;
        request.CurrencyCode = config.Apttus_QPConfig__Proposald__r.CurrencyIsoCode;
        request.DocCode = config.Apttus_QPConfig__Proposald__r.Name;
        request.DocDate = config.Apttus_QPConfig__Proposald__r.Avalara_DocDate__c; //Date.today();
        //request.DocType = request.IsToCommitDocument == 'false' ? 'SalesInvoice' : 'SalesOrder';
        request.DocType = 'SalesInvoice';
        //request.Status = 'uncommitted';

        return request;
    }*/

    /*public AvalaraSchema.GetTaxRequest OrderGenerateRequest(Order__c pOrder){
        system.debug('\n\n **** Inside AvalaraModel.OrderGenerateRequest()');

        AvalaraSchema.GetTaxRequest request = new AvalaraSchema.GetTaxRequest();

        request.IsToCommitDocument = IsToCommit == null ? 'false' : IsToCommit; //needs additional considerations

        request.BusinessIdentificationNo = pOrder.Account__r.VATNumber__c;
        request.CustomerCode = pOrder.Account__r.AccountID__c;

        request.DetailLevel = 'Line';
        request.CompanyCode = pOrder.Avalara_CompanyCode__c;
        request.CurrencyCode = pOrder.CurrencyIsoCode;
        request.DocCode = pOrder.Name;
        request.DocDate = pOrder.QuoteProposal__r.Avalara_DocDate__c;
        request.DocType = 'SalesInvoice';

        return request;
    }*/

    @future (callout=true)
    public static void configAsyncTaxRateProcessing(set<Id> pConfigIdSet){
        AvalaraModel.configStartTaxRateProcessing(pConfigIdSet);
    }

    /*public static void configStartTaxRateProcessing(set<Id> pConfigIdSet){
        system.debug('\n\n **** Inside AvalaraModel_Cart.configStartTaxRateProcessing()');
        try{
            Apttus_Config2__ProductConfiguration__c[] Config = [
                SELECT
                    Id, Name,
                    Apttus_Config2__AccountId__r.VATNumber__c,
                    Apttus_Config2__AccountId__r.AccountID__c,
                    Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__c,
                    Apttus_QPConfig__Proposald__r.Selling_Country__c,
                    Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.VATNumber__c,
                    Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.AccountID__c,
                    Apttus_QPConfig__Proposald__r.StateProvinceTaxCode__c,
                    Apttus_QPConfig__Proposald__r.Apttus_Proposal__Sales_Tax_Percent__c,

                    Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.ShippingStreet,
                    Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.ShippingCity,
                    Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.ShippingStateCode,
                    Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.ShippingCountryCode,
                    Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.ShippingPostalCode,

                    //Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.BillingStreet,
                    //Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.BillingCity,
                    //Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.BillingStateCode,
                    //Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.BillingCountryCode,
                    //Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.BillingPostalCode,


                    Apttus_QPConfig__Proposald__r.Name,
                    Apttus_QPConfig__Proposald__r.Avalara_CompanyCode__c,
                    Apttus_QPConfig__Proposald__r.Avalara_DocDate__c,
                    Apttus_QPConfig__Proposald__r.CurrencyIsoCode

                FROM Apttus_Config2__ProductConfiguration__c
                WHERE Id IN : pConfigIdSet
            ];
            //Account.BillingStreet
            //Apttus_Proposal__Proposal__c.
            //system.debug('Config  :'+Config);
            if(Config.size() == 1){
                Apttus_Config2__ProductConfiguration__c currentConfig = Config[0];

                AvalaraSchema.RequestHeader header = getAvalaraSetting();

                AvalaraModel_Cart model = new AvalaraModel_Cart(header);
                AvalaraSchema.GetTaxRequest requestWrap = model.configGenerateRequest(currentConfig);
                requestWrap.Lines = new AvalaraSchema.Line[]{};
                requestWrap.Addresses = new AvalaraSchema.Address[]{};

                //line creation
                Apttus_Config2__LineItem__c[] lineItemList = [
                    SELECT Id, Name, Apttus_Config2__ProductId__r.ProductCode,
                                Apttus_Config2__ProductId__r.Description, Apttus_Config2__Quantity__c, Net_Total__c,
                                //for result
                                APTS_Tax_Amount__c,
                                APTS_Tax_Rate__c,
                                APTS_Tax_Code__c,
                                VATNationalTaxCode__c,
                                StateProvinceTaxCode__c,
                                VATNationalTaxRate__c,
                                StateTaxRate__c,
                                CountyTaxRate__c,
                                CityTaxRate__c,
                    			Apttus_Config2__ProductId__r.Apttus_Config2__ConfigurationType__c,
								Apttus_Config2__IsPrimaryLine__c,
                    			Apttus_Config2__LineType__c,
                                SpecialTaxJurisdictionRate__c,
                                VATNationalTaxAmount__c,
                                StateTaxAmount__c,
                                CountyTaxAmount__c,
                                CityTaxAmount__c,

                                SpecialTaxJurisdictionAmount__c,
                                Apttus_Config2__NetPrice__c,
                                Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.APTS_Quote_Type__c,
                                Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Organization__c

                    FROM Apttus_Config2__LineItem__c
                    WHERE Apttus_Config2__ConfigurationId__c = :currentConfig.Id
                ];
                //system.debug('line item details:' +lineItemList);
                if(lineItemList.size() > 0){
                    AvalaraSchema.Address ShippingAddress = new AvalaraSchema.Address();
                    ShippingAddress.AddressCode = 'Shipping';

                    ShippingAddress.Line1 = currentConfig.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.ShippingStreet;
                    ShippingAddress.City = currentConfig.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.ShippingCity;
                    ShippingAddress.Region = currentConfig.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.ShippingStateCode;
                    ShippingAddress.Country = currentConfig.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.ShippingCountryCode;
                    ShippingAddress.PostalCode = currentConfig.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.ShippingPostalCode;
                    requestWrap.Addresses.add(ShippingAddress);


                    AvalaraSchema.Address OriginAddress = new AvalaraSchema.Address();
                    OriginAddress.AddressCode = 'Origin';

                    String OriginCountry = currentConfig.Apttus_QPConfig__Proposald__r.Selling_Country__c == null ? Utility.DEFAULT_AVALARA_ADDRESS : currentConfig.Apttus_QPConfig__Proposald__r.Selling_Country__c;
                    AvalaraAddressInfo__c OriginAddressInfo = Utility.getAvalaraAddressInfo(OriginCountry);

                    OriginAddress.Line1 = OriginAddressInfo.Address1__c;
                    OriginAddress.Line2 = OriginAddressInfo.Address2__c;
                    OriginAddress.Line3 = OriginAddressInfo.Address3__c;
                    OriginAddress.City = OriginAddressInfo.City__c;
                    OriginAddress.Region = OriginAddressInfo.StateProvince__c;
                    OriginAddress.Country = OriginAddressInfo.CountryCode__c;
                    OriginAddress.PostalCode = OriginAddressInfo.ZIPPostalCode__c;
                    requestWrap.Addresses.add(OriginAddress);

                    //system.debug('requestWrap.Addresses'+ requestWrap.Addresses);
                    for(Apttus_Config2__LineItem__c lineitem : lineItemList){
                        //I-203406 - Tax line was calcuating for Bundle header line as welll
                        If(lineitem.Apttus_Config2__ProductId__r.Apttus_Config2__ConfigurationType__c =='Bundle' && lineitem.Apttus_Config2__LineType__c =='Product/Service')
                        {
                            Continue;
                        }
                        AvalaraSchema.Line line = new AvalaraSchema.Line();
                        line.LineNo = lineitem.Name;
                        line.DestinationCode = ShippingAddress.AddressCode;
                        line.OriginCode = OriginAddress.AddressCode;//BillingAddress.AddressCode;
                        line.ItemCode = lineitem.Apttus_Config2__ProductId__r.ProductCode;
                        line.Description = lineitem.Apttus_Config2__ProductId__r.Description;
                        line.Qty = lineItem.Apttus_Config2__Quantity__c;

                        if(lineitem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.APTS_Quote_Type__c == 'Agency' &&
                            lineitem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Organization__c == 'North America'){
                                line.Amount = lineItem.Apttus_Config2__NetPrice__c;
                            }else{
                                line.Amount = lineItem.Net_Total__c;
                            }

                        requestWrap.Lines.add(line);
                       // system.debug(' Line added :'+line);

                    }
                }

                system.debug('\n\nAvalara request (AvalaraModel_Cart.configStartTaxRateProcessing): \n' + JSON.serializePretty(requestWrap) + '\n\n');
                AvalaraSchema.GetTaxResponse avalaraResponse = model.GetTax(requestWrap);
                system.debug('\n\nAvalara result (AvalaraModel_Cart.configStartTaxRateProcessing): \n' + JSON.serializePretty(avalaraResponse) + '\n\n');

                processGetTaxResponse(avalaraResponse, currentConfig, lineItemList);
            }
        }catch(Exception e){
            system.debug('\n\nAvalara Integration Error: ' + e + '\nTrace: ' + e.getStackTraceString() + '\n\n');
        }
    }*/

    /*private static void processGetTaxResponse(AvalaraSchema.GetTaxResponse pResponse,Apttus_Config2__ProductConfiguration__c pConfig,Apttus_Config2__LineItem__c  [] pLineitems){
        system.debug('\n\n **** Inside AvalaraModel_Cart.processGetTaxResponse()');
        //Apttus_Proposal__Proposal__c pProposal = new Apttus_Proposal__Proposal__c();//pConfig.Apttus_QPConfig__Proposald__r
        //pProposal = pConfig.Apttus_QPConfig__Proposald__r;
        pConfig.Avalara_Response_Code__c = pResponse.ResultCode;
        String resultMsg = 'Results: \n';
        if(pResponse.Messages != null){
            for(AvalaraSchema.Message msg : pResponse.Messages){
                resultMsg += '\nSeverity:' + msg.Severity;
                resultMsg += '\nRefersTo:' + msg.RefersTo;
                resultMsg += '\nSummary:' + msg.Summary;
                resultMsg += '\nDetails:' + msg.Details;
            }
        }else{
            resultMsg = null;
        }
        pConfig.Avalara_Response_Message__c = resultMsg;
        pConfig.Avalara_TimeStamp__c = pResponse.TimeStamp;
        Decimal totalTaxPercent = 0;
        //tax detail prep
        map<String, AvalaraSchema.TaxDetail> taxSummaryMap = new map<String, AvalaraSchema.TaxDetail>();
        map<String, AvalaraSchema.TaxDetail> specialTaxSummaryMap = new map<String, AvalaraSchema.TaxDetail>();
        if(pResponse.TaxSummary != null && pResponse.TaxSummary.size() > 0){
            for(AvalaraSchema.TaxDetail detail : pResponse.TaxSummary){
                if(detail.JurisType == AvalaraSchema.JURIS_TYPE_SPECIAL){
                    specialTaxSummaryMap.put(detail.JurisCode, detail);
                }else {
                    taxSummaryMap.put(detail.JurisType, detail);
                }
            }
        }

        //Line Item Processing start
        if(pResponse.TaxLines != null){
            map<String, AvalaraSchema.TaxLine> proposalLineNameToTaxLine = new map<String, AvalaraSchema.TaxLine>();
            for(AvalaraSchema.TaxLine tax : pResponse.TaxLines){
                proposalLineNameToTaxLine.put(tax.LineNo, tax);
            }

            if(!proposalLineNameToTaxLine.isEmpty()){
                Apttus_Config2__LineItem__c [] linesToBeUpdated = new Apttus_Config2__LineItem__c[]{};
                for(Apttus_Config2__LineItem__c line : pLineitems){
                    if(proposalLineNameToTaxLine.containsKey(line.Name)){
                        AvalaraSchema.TaxLine tax = proposalLineNameToTaxLine.get(line.Name);
                        line.APTS_Tax_Code__c = tax.TaxCode;
                        line.APTS_Tax_Rate__c = Utility.getPercentage(tax.Rate);
                        line.APTS_Tax_Amount__c = tax.Tax;



                        String countryCode = pConfig.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.ShippingCountryCode == null ? '' : pConfig.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.ShippingCountryCode.toLowerCase();
                        String stateCode = pConfig.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.ShippingStateCode == null ? '' : pConfig.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.ShippingStateCode.toLowerCase();

                        //ca = Canada, qc = Quebec, sk = Saskatchewan, us = United States
                        Boolean validForVATNationalValues = countryCode != 'us' && !(countryCode == 'ca' && (stateCode == 'qc' || stateCode == 'sk'));
                        Boolean validForStateValues = !validForVATNationalValues;

                        if(validForStateValues){
                        line.StateProvinceTaxCode__c = tax.TaxCode;
                        //pProposal.StateProvinceTaxCode__c = tax.TaxCode;
                        }else{
                            line.StateProvinceTaxCode__c = null;
                            //pProposal.StateProvinceTaxCode__c = null;
                        }

                        if(validForVATNationalValues){
                            line.VATNationalTaxCode__c = tax.TaxCode;
                            line.VATNationalTaxRate__c = Utility.getPercentage(tax.Rate);
                            line.VATNationalTaxAmount__c = tax.Tax;
                        }else{
                            line.VATNationalTaxCode__c = null;
                            line.VATNationalTaxRate__c = null;
                            line.VATNationalTaxAmount__c = null;
                        }
                        totalTaxPercent += Utility.getPercentage(tax.Rate);

                        AvalaraSchema.TaxDetail stateDetail = taxSummaryMap.get(AvalaraSchema.JURIS_TYPE_STATE);
                        if(stateDetail != null && validForStateValues){
                            //system.debug('stateDetail.Rate'+stateDetail.Rate+'\n tax.Taxable '+tax.Taxable+'\n  stateDetail.Rate'+stateDetail.Rate);
                            line.StateTaxRate__c = Utility.getPercentage(stateDetail.Rate);
                            line.StateTaxAmount__c = tax.Taxable * stateDetail.Rate;
                        }else{
                            line.StateTaxRate__c = null;
                            line.StateTaxAmount__c = null;
                        }

                        AvalaraSchema.TaxDetail countyDetail = taxSummaryMap.get(AvalaraSchema.JURIS_TYPE_COUNTY);
                        if(countyDetail != null && validForStateValues){
                            line.CountyTaxRate__c = Utility.getPercentage(countyDetail.Rate);
                            line.CountyTaxAmount__c = tax.Taxable * countyDetail.Rate;
                        }else{
                            line.CountyTaxRate__c = null;
                            line.CountyTaxAmount__c = null;
                        }

                        AvalaraSchema.TaxDetail cityDetail = taxSummaryMap.get(AvalaraSchema.JURIS_TYPE_CITY);
                        if(cityDetail != null  && validForStateValues){
                            line.CityTaxRate__c = Utility.getPercentage(cityDetail.Rate);
                            line.CityTaxAmount__c = tax.Taxable * cityDetail.Rate;
                        }else{
                            line.CityTaxRate__c = null;
                            line.CityTaxAmount__c = null;
                        }

                        //special jurisdiction tax population
                        if(!specialTaxSummaryMap.isEmpty() && specialTaxSummaryMap.size() <= 4 && validForStateValues){
                            AvalaraSchema.TaxDetail[] specialTaxes = specialTaxSummaryMap.values();
                            //system.debug('\n\nSpecial Taxes: ' + specialTaxes.size() + '\n\n');
                            Double jurisAmount = 0;
                            Double jurisRate = 0;

                            for(Integer i = 1; i <= specialTaxes.size(); i++){
                                Double tRate = Utility.getPercentage(specialTaxes[i - 1].Rate);
                                line.put('SpecialTaxJurisdictionRate' + i + '__c', tRate);
                                jurisRate += tRate;

                                Double tAmount = tax.Taxable * specialTaxes[i - 1].Rate;
                                line.put('SpecialTaxJurisdictionAmount' + i + '__c', tAmount);
                                jurisAmount += tax.Taxable * specialTaxes[i - 1].Rate;
                            }

                            line.SpecialTaxJurisdictionAmount__c = jurisAmount == 0 && jurisRate == 0 ? null : jurisAmount;
                            line.SpecialTaxJurisdictionRate__c = jurisRate == 0 ? null : jurisRate;
                        }else{
                            line.SpecialTaxJurisdictionRate__c = null;
                            line.SpecialTaxJurisdictionAmount__c = null;
                        }

                        linesToBeUpdated.add(line);
                    }
                }

                if(!linesToBeUpdated.isEmpty()){
                    update linesToBeUpdated;
                }
            }
        }
        //Line Item Processing end
        //pProposal.Apttus_Proposal__Sales_Tax_Percent__c = totalTaxPercent;
        ApttusProductConfigTriggerHandler.ExecuteTriggers = false;
        //ApttusProposalTriggerHandler.ExecuteTriggers = false;
        update pConfig;
        //update pProposal;
    }*/

    webservice static Boolean getQuoteTaxFromConfigbutton(Id pConfigId){
        try{
            system.debug('\n\nCalling asyncronous Avalara callout method.\n\n'+pConfigId);
            AvalaraModel.configStartTaxRateProcessing(new set<Id>{pConfigId});
            return true;
        }catch(Exception e){
            system.debug('\n\n getQuoteTaxeFromButton error:' + e + '\n\n');
            return false;
        }
    }

    public static void getQuoteTaxFromConfig(Apttus_Config2__ProductConfiguration__c[] pNewApttusProductConfiguration){
        system.debug('***# in method Avalaracart.getQuoteTaxforconfig');
        Set<Id> finalizedConfigIds = new set<Id>();

       for(Apttus_Config2__ProductConfiguration__c eachProdConfig : pNewApttusProductConfiguration){
          if(eachProdConfig.Apttus_Config2__Status__c == 'Finalized'){
                    system.debug('***# adding Config to the List:'+eachProdConfig);
                    finalizedConfigIds.add(eachProdConfig.ID);
          }
       }
        // if there are no Config then exit this method.
       if(finalizedConfigIds.isEmpty()){
          // system.debug('***# no Configs in Finalized status.');
           return;
       }
       system.debug('***# Config status = Finalized List :'+finalizedConfigIds);
        try{
            system.debug('\n\nCalling asyncronous Avalara callout method.\n\n'+finalizedConfigIds);
            configAsyncTaxRateProcessing(finalizedConfigIds);

        }catch(Exception e){
            system.debug('\n\n getQuoteTaxeFromButton error:' + e + '\n\n');

        }
    }

    /*public static void ProposalProcessTaxRate(Apttus_Proposal__Proposal__c[] pProposalList, map<Id, Apttus_Proposal__Proposal__c> pProposalOldMap){
        system.debug('\n\n **** Inside AvalaraModel_Cart.ProposalProcessTaxRate()');

        if(Utility.IsNotValidTestRecord('Id', pProposalList, new set<String>{'a0m11000001MmuI'})){
            system.debug('\n\nInvalid test data\n\n');
            //return;
        }

        set<Id> proposalIds = new set<Id>();
        for(Apttus_Proposal__Proposal__c prop : pProposalList){
            system.debug('\n\n Proposal: ' + prop.Name + '\nNew QuoteStatus__c: ' + prop.QuoteStatus__c + '\nOld QuoteStatus__c: ' + pProposalOldMap.get(prop.Id).QuoteStatus__c);
            if((pProposalOldMap == null || pProposalOldMap.get(prop.Id).QuoteStatus__c != 'Sent for Approval') && prop.QuoteStatus__c == 'Sent for Approval'){
                proposalIds.add(prop.Id);
            }
            if((pProposalOldMap == null || pProposalOldMap.get(prop.Id).QuoteStatus__c != 'Presented Quote') && prop.QuoteStatus__c == 'Presented Quote'){
                proposalIds.add(prop.Id);
            }
        }
        if(proposalIds.size() == 0){
            system.debug('\n\nNo proposal ready for Avalara GetTax Processing\n\n');
            return;
        }

        system.debug('\n\nCalling asyncronous Avalara callout method.\n\n');
        ProposalAsyncTaxRateProcessing(proposalIds);
    }


    public static void hardcodedTest(){
        String output = '';
        AvalaraSchema.GetTaxRequest req = new AvalaraSchema.GetTaxRequest();
        req.DocDate = Date.today();
        //req.CustomerCode = 'Cutomer 1';
        req.DocCode = 'Doc 1';
        req.DocType = 'SalesInvoice';

        AvalaraSchema.Address address = new AvalaraSchema.Address();
        address.AddressCode = '1';
        address.Line1 = '100 Ravine Lane NE';
        address.City = 'Bainbridge Island';
        address.Region = 'WA';
        address.PostalCode = '98110';
        req.Addresses = new AvalaraSchema.Address[]{address};

        AvalaraSchema.Line line = new AvalaraSchema.Line();
        line.LineNo = '1';
        line.DestinationCode = '1';
        line.OriginCode = '1';
        line.Qty = 1;
        line.Amount = 10;
        req.Lines = new AvalaraSchema.Line[]{line};

        /*AvalaraSchema.RequestHeader reqHeader = new AvalaraSchema.RequestHeader();
        reqHeader.EndPoint = 'https://development.avalara.net/1.0/tax/get';
        //reqHeader.EndPoint = 'http://requestb.in/nms3m3nm';
        reqHeader.Username = 'booz.espiridion@cloudsherpas.com';
        reqHeader.Password = 'b00zAv@lar';
        reqHeader.Client = 'TestCustomRestModel';
        reqHeader.CompanyCode = 'APITrialCompany';*/
    /*
        AvalaraSchema.RequestHeader reqHeader = new AvalaraSchema.RequestHeader();
        reqHeader.EndPoint = 'https://development.avalara.net/1.0/tax/get';
        reqHeader.Client = 'Monster Worldwide, Inc.';
        reqHeader.CompanyCode = 'MWW';
        //header.EndPoint = Utility.getWebServiceEnpoint('BoozDummyEndpoint');
        reqHeader.Password = 'Cloud$herpas2014';
        reqHeader.Username = 'cloudsherpas';

        AvalaraModel_Cart model = new AvalaraModel_Cart(reqHeader);
        try{
            output += 'GetTax: ' + JSON.serializePretty(model.GetTax(req));
        }catch(Exception e){
            output += 'Error: ' + e;
            output += '\n\n' + model.invoke(req.serialize()) + '\n\n';
        }

        system.debug(output);
    }
    */
}