global without sharing class AvalaraModel {
/****************************************************
 JHF 3/16/16 If you make any changes to this file, be sure to
 check to see if the same change is needed in AvalaraModel_Cart.cls
 ****************************************************/

  public static final String QUOTE = 'QUOTE';
  public static final String ORDER = 'order';

  public static String IsToCommit = 'false';

  private AvalaraSchema.RequestHeader Header;
  public String RawResult;

  public AvalaraModel(AvalaraSchema.RequestHeader pHeader){
    system.debug('\n\n **** Inside AvalaraModel.AvalaraModel()');

    Header = pHeader;
  }

  public AvalaraSchema.GetTaxResponse GetTax(AvalaraSchema.GetTaxRequest pRequest){
    system.debug('\n\n **** Inside AvalaraModel.GetTax()');
    AvalaraSchema.GetTaxResponse errorResponse = new AvalaraSchema.GetTaxResponse();

    try{
      system.debug('!!!Tax Request ' + '\n' + pRequest.serialize() );

      HttpResponse getTaxResponse = invoke(pRequest.serialize());

      String JSonString = getTaxResponse.getBody();

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
          errorMsg.Summary = 'Remote server responded with ' + errorResponse.ResultCode;
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
  }
//This method will validate the address when any call is made to avalara.
  public static AvalaraSchema.Address2 validateAddress(AvalaraSchema.Address2 pRequest, Id currentAccountId){
    system.debug('\n\n **** Inside AvalaraModel.validateAddress()');
    AvalaraSchema.Address2 responseAddress = new AvalaraSchema.Address2 ();
    try{
        Utility.IntegrationSetting setting = Utility.getIntegrationSetting('ValidateAddress');

        if(setting == null || setting.AvalaraClient == null || setting.AvalaraCompanyCode == null || setting.Username == null || setting.Password == null){
          system.debug('\n\nInvalid Avalara Integration setting.\n\nSettings:'+JSON.serializePretty(setting)+'\n\n\n');
          return null;
        }

        AvalaraSchema.RequestHeader hdr= new AvalaraSchema.RequestHeader();
        hdr.EndPoint = setting.Endpoint;
        hdr.Client = setting.AvalaraClient;
        hdr.CompanyCode = setting.AvalaraCompanyCode;
        hdr.Password = setting.Password;
        hdr.Username = setting.Username;
        hdr.Country = setting.AvalaraCountry;
        hdr.Method = 'GET';
        //Header = hdr;
        Blob headerValue = Blob.valueOf(hdr.Username+':'+hdr.Password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);


        HttpRequest req = new HttpRequest();
        req.setMethod(hdr.Method);
        req.setHeader('Authorization', authorizationHeader );
        system.debug('AuthorizationHeaderValidation ' + authorizationHeader);

        String endpt;
        if(pRequest.Line1 != null || pRequest.Line1 != ''){
          endpt ='Line1='+EncodingUtil.urlEncode(pRequest.Line1, 'UTF-8');
        }
        if(pRequest.Line2 != null && pRequest.Line2 != ''){
            endpt = endpt +'&Line2='+EncodingUtil.urlEncode(pRequest.Line2, 'UTF-8');
        }
         if(pRequest.Line3!= null && pRequest.Line3!= ''){
            endpt = endpt + '&Line3='+EncodingUtil.urlEncode(pRequest.Line3, 'UTF-8');
        }
         if(pRequest.City!= null && pRequest.City!= ''){
            endpt = endpt + '&City'+EncodingUtil.urlEncode(pRequest.City, 'UTF-8');
        }
         if(pRequest.Region!= null && pRequest.Region != ''){
            endpt = endpt +'&Region='+EncodingUtil.urlEncode(pRequest.Region, 'UTF-8');
        }
        if(pRequest.PostalCode!= null && pRequest.PostalCode!= ''){
            endpt = endpt +'&PostalCode='+EncodingUtil.urlEncode(pRequest.PostalCode, 'UTF-8');
        }
        if(pRequest.Country!= null && pRequest.Country!= ''){
            endpt = endpt +'&Country='+EncodingUtil.urlEncode(pRequest.Country, 'UTF-8');
        }

        //req.setEndPoint('https://development.avalara.net/1.0/address/validate?Line1=118+N+Clark+St&Line2=Suite+100&Line3=ATTN+Accounts+Payable&City=Chicago&Region=IL&PostalCode=60602&Country=US' );
        //req.setEndPoint(hdr.EndPoint+endpt);
        //String body = 'Line1='+EncodingUtil.urlEncode('2416 Loudon Pl', 'UTF-8') +'&PostalCode='+EncodingUtil.urlEncode('12309', 'UTF-8');
        req.setEndpoint(hdr.Endpoint+'?'+endpt);

        Http h = new Http();
        HttpResponse getAddressResponse = h.send(req);
        system.debug('Response ' + getAddressResponse );
        system.debug('Response Body ' + getAddressResponse.getBody());
        String JSonString = getAddressResponse.getBody();
        Map<String, Object> tempMap =  (Map<String, Object>)JSON.deserializeuntyped(JSonString);

        Map<String, Object> address =  (Map<String, Object>)tempMap.get('Address');

        Account accToUpdate = new Account(id = currentAccountId);
        //accToUpdate. = responseAddress.AddressCode;
        accToUpdate.ShippingStreet = String.valueOf(address.get('Line1')) ; //+ ' ' + String.valueOf(address.get('Line2')) + ' ' + String.valueOf(address.get('Line3'))
        accToUpdate.ShippingCity = String.valueOf(address.get('City'));
        //accToUpdate.ShippingState = String.valueOf(address.get('Region'));
        accToUpdate.ShippingCountryCode = String.valueOf(address.get('Country'));
        accToUpdate.ShippingPostalCode = String.valueOf(address.get('PostalCode'));
        //accToUpdate. = responseAddress.Latitude;
        //accToUpdate. = responseAddress.Longitude;
        //accToUpdate. = responseAddress.TaxRegionId;
        //accToUpdate. = responseAddress.ResultCode;
        //accToUpdate. = responseAddress.PostNet;
        //accToUpdate. = responseAddress.CarrierRoute;
        //accToUpdate. = responseAddress.FipsCode;
        //accToUpdate. = responseAddress.AddressType;
        system.debug('===accToUpdate.ShippingStreet===' + accToUpdate.ShippingStreet + '===accToUpdate.ShippingCity===' + accToUpdate.ShippingCity );
        system.debug('===accToUpdate.ShippingState===' + accToUpdate.ShippingState );
        system.debug('===accToUpdate.ShippingPostalCode===' + accToUpdate.ShippingPostalCode );
        update accToUpdate;
        system.debug('^^^Completed validateAddress, returning responseAddress:'+responseAddress);
      return responseAddress ;
    }catch(Exception e){
      //system.debug('\n\nError: ' + e + '\n\n' + e.getLineNumber());
      /*Jeff commented out to test
      responseAddress.ResultCode = 'Internal Error';
      AvalaraSchema.Message errorMsg = new AvalaraSchema.Message();
      errorMsg.Severity = 'Error';

      errorMsg.RefersTo = '';
      errorMsg.Summary = 'A problem has occurred & processing cannot complete successfully - please see system log for details.';
      errorMsg.Details = '' + e;
      responseAddress.Messages = new AvalaraSchema.Message[]{errorMsg};*/
      return null;
    }
  }


  private static AvalaraSchema.RequestHeader getAvalaraSetting(){
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
  }

  private String getAuthorizationHeader(){
    system.debug('\n\n **** Inside getAuthorizationHeader.getAuthorizationHeader()');

    Blob headerValue = Blob.valueOf(Header.Username+':'+Header.Password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        system.debug('authorizationHeader TEST ' + authorizationHeader);
        return authorizationHeader;
  }

  private HttpResponse invoke(String ReqBody){
    system.debug('\n\n **** Inside AvalaraModel.invoke()');

    HttpRequest req = new HttpRequest();
        req.setMethod(Header.Method);
        req.setHeader('Authorization', getAuthorizationHeader());
        req.setHeader('Content-Type', 'text/json');
        req.setEndPoint(Header.EndPoint);
        req.setBody(ReqBody);

        Http h = new Http();
        HttpResponse res = null;

        res = h.send(req);

        /*if(!Test.isRunningTest())
            res = h.send(req);
        else{
            res = new HttpResponse();
            res.setHeader('Content-type', 'application/json');
            AvalaraSchema.GetTaxResponse response = new AvalaraSchema.GetTaxResponse();
            AvalaraSchema.Message msg = new AvalaraSchema.Message();
            msg.Name = 'Test';
            AvalaraSchema.TaxDetail taxDetail1 = new AvalaraSchema.TaxDetail();
            taxDetail1.Country = 'United States';
            AvalaraSchema.TaxDetail taxDetail2 = new AvalaraSchema.TaxDetail();
            taxDetail2.Country = 'India';
            taxDetail2.JurisType = AvalaraSchema.JURIS_TYPE_SPECIAL;
            AvalaraSchema.TaxLine taxLine1 = new AvalaraSchema.TaxLine();
            Order_Line_Item__c oli = [SELECT Id,Name FROM Order_Line_Item__c LIMIT 1];
            taxLine1.LineNo = oli.Name;
            response.Messages = new List<AvalaraSchema.Message>{msg};
            response.TaxSummary = new List<AvalaraSchema.TaxDetail>{taxDetail1,taxDetail2};
            response.TaxLines = new List<AvalaraSchema.TaxLine>{taxLine1};
            res.setBody(JSON.serialize(response));
            //res.setBody(hardcodedTest());
            res.setStatusCode(200);
        }*/
        return res;
  }

  public AvalaraSchema.GetTaxRequest ProposalGenerateRequest(Apttus_Proposal__Proposal__c pProposal){
    system.debug('\n\n **** Inside AvalaraModel.ProposalGenerateRequest()');

    AvalaraSchema.GetTaxRequest request = new AvalaraSchema.GetTaxRequest();

    request.IsToCommitDocument = IsToCommit == null ? 'false' : IsToCommit; //needs additional considerations

    //request.BusinessIdentificationNo = pProposal.Apttus_Proposal__Account__r.VATNumber__c;
    request.CustomerCode = pProposal.Apttus_Proposal__Account__r.AccountID__c;

    request.DetailLevel = 'Line';
    request.CompanyCode = pProposal.Avalara_CompanyCode__c;
    request.CurrencyCode = pProposal.CurrencyIsoCode;
    request.DocCode = pProposal.Name;
    request.DocDate = pProposal.Avalara_DocDate__c == null ? Date.today() : pProposal.Avalara_DocDate__c;
    request.DocType = 'SalesInvoice';

    /*T-413106*/
    if(pProposal.BillingAccount__r.Organization__c == 'Europe'){
        request.BusinessIdentificationNo = pProposal.VAT_Number__c;
    }

    return request;
  }

  public AvalaraSchema.GetTaxRequest OrderGenerateRequest(Order__c pOrder){
    system.debug('\n\n **** Inside AvalaraModel.OrderGenerateRequest()');

    AvalaraSchema.GetTaxRequest request = new AvalaraSchema.GetTaxRequest();
    // Commneted below line due to issue I-188987
     //request.IsToCommitDocument = IsToCommit == null ? 'false' : IsToCommit; //needs additional considerations
    if(pOrder.Payment_Method_text__c == 'Invoice') {
       request.IsToCommitDocument = 'false';
    }
    else {
       request.IsToCommitDocument = 'true';
    }
    //request.BusinessIdentificationNo = pOrder.Account__r.VATNumber__c;
     List<RecordType> creditRecordType = [Select id from RecordType where sObjectType = 'Order__c' and developerName ='Credit' ];
     List<RecordType> rebillRecordType = [Select id from RecordType where sObjectType = 'Order__c' and developerName ='RebillOrder' ];
      request.DocCode = pOrder.Name;
      request.CompanyCode = pOrder.Avalara_CompanyCode__c;
      request.DocDate = system.today();
      request.DocType = 'SalesInvoice';
      request.CustomerCode = pOrder.Account__r.AccountID__c;

       String org = pOrder.Account__r.Organization__c ;

       if(org == 'Europe' || org == 'Asia Pacific') {
             if(pOrder.Account__r.Entity_Use_Code__c != '' && pOrder.Account__r.Entity_Use_Code__c != 'Null'){
                request.CustomerUsageType = pOrder.Account__r.Entity_Use_Code__c;
             }
       }

      if(creditRecordType.size() > 0){
        if(pOrder.RecordTypeId == creditRecordType[0].id){

            request.DocCode = pOrder.Name;
            //request.DocDate =  pOrder.QuoteProposal__r.Avalara_DocDate__c;
            request.DocDate =  pOrder.ParentOrder__r.OrderDate__c;

        }else if(pOrder.RecordTypeId == rebillRecordType[0].id){

            // Rebill Orders count as new Order (T-422354)
            request.DocCode = pOrder.Name;
            request.DocDate =  pOrder.QuoteProposal__r.Avalara_DocDate__c;
            request.DocType = 'ReturnOrder';

            AvalaraSchema.TaxOverride pTaxOverride = new AvalaraSchema.TaxOverride();
            pTaxOverride.Reason = '<credit>';
            pTaxOverride.TaxDate = pOrder.QuoteProposal__r.Avalara_DocDate__c;
            pTaxOverride.TaxOverrideType = 'TaxDate';

            request.TaxOverride = pTaxOverride;
        }

      }

    return request;
  }

    public AvalaraSchema.GetTaxRequest configGenerateRequest(Apttus_Config2__ProductConfiguration__c config){
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
        request.DocType = 'SalesInvoice';

        return request;
    }

    @future (callout=true)
    public static void AsyncTaxRateProcessing(set<Id> pIdSet, String pCalledFromObject){
        system.debug('\n\n **** Inside AvalaraModel.AsyncTaxRateProcessing()');
        AsyncTaxRateProcessingMethods(pIdSet, pCalledFromObject);
    }

    public static void AsyncTaxRateProcessingMethods(set<Id> pIdSet, String pCalledFromObject){
        system.debug('\n\n **** Inside AvalaraModel.AsyncTaxRateProcessingMethods()');
        //JFreese Appirio 3/9/17 S-456572 break out the methods so they can be called from AsyncTaxRateProcessing()
        //or in a queueable such as CreditRequestTriggerHelper.QueueableTaxRateProcessing()

        if(pCalledFromObject == QUOTE){
          system.debug('^^^ Calling ProposalStartTaxRateProcessing(' + pIdSet + ')');
          ProposalStartTaxRateProcessing(pIdSet);
        }else if(pCalledFromObject == ORDER){
            system.debug('^^^ Calling OrderStartTaxRateProcessing(' + pIdSet + ')');
            OrderStartTaxRateProcessing(pIdSet);
        }
        else{
            system.debug('^^^ Not Calling anything - pCalledFromObject=' + pCalledFromObject + ', pIdSet=' + pIdSet + ')');
        }
    }

    public static void configStartTaxRateProcessing(set<Id> pConfigIdSet){
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
            Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.Organization__c,

            Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.ShippingStreet,
            Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.ShippingCity,
            Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.ShippingStateCode,
            Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.ShippingCountryCode,
            Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.ShippingPostalCode,

            Apttus_QPConfig__Proposald__r.Agency__r.BillingStreet,
            Apttus_QPConfig__Proposald__r.Agency__r.BillingCity,
            Apttus_QPConfig__Proposald__r.Agency__r.BillingStateCode,
            Apttus_QPConfig__Proposald__r.Agency__r.BillingCountryCode,
            Apttus_QPConfig__Proposald__r.Agency__r.BillingPostalCode,

            Apttus_QPConfig__Proposald__r.Agency__r.ShippingStreet,
            Apttus_QPConfig__Proposald__r.Agency__r.ShippingCity,
            Apttus_QPConfig__Proposald__r.Agency__r.ShippingStateCode,
            Apttus_QPConfig__Proposald__r.Agency__r.ShippingCountryCode,
            Apttus_QPConfig__Proposald__r.Agency__r.ShippingPostalCode,

            //Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.BillingStreet,
            //Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.BillingCity,
            //Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.BillingStateCode,
            //Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.BillingCountryCode,
            //Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.BillingPostalCode,


            Apttus_QPConfig__Proposald__r.Name,
            Apttus_QPConfig__Proposald__r.Avalara_CompanyCode__c,
            Apttus_QPConfig__Proposald__r.Avalara_DocDate__c,
            Apttus_QPConfig__Proposald__r.CurrencyIsoCode,
            Apttus_QPConfig__Proposald__r.APTS_Quote_Type__c

            FROM Apttus_Config2__ProductConfiguration__c
            WHERE Id IN : pConfigIdSet
            ];
            //Account.BillingStreet
            //Apttus_Proposal__Proposal__c.
            //system.debug('Config  :'+Config);
            if(Config.size() == 1){
                Apttus_Config2__ProductConfiguration__c currentConfig = Config[0];

                AvalaraSchema.RequestHeader header = getAvalaraSetting();

                AvalaraModel model = new AvalaraModel(header);
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
                Option_Code__c,
                Apttus_Config2__Description__c,

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
                    if(OriginCountry == 'United Arab Emirates' && currentConfig.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.ShippingCity == 'Dubai'){
                      OriginCountry = 'United Arab Emirates1';
                    }
                    AvalaraAddressInfo__c OriginAddressInfo = Utility.getAvalaraAddressInfo(OriginCountry);

                    //Jeff L commenting out for I-213632
                    //requestWrap.Addresses.add(OriginAddress);

                    /*T-413314*/
                    /*
                    if(currentConfig.Apttus_QPConfig__Proposald__r.APTS_Quote_Type__c == 'Agency' &&
                        currentConfig.Apttus_QPConfig__Proposald__r.Agency__r != null){
                        // I-209135
                        if(currentConfig.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Account__r.Organization__c == 'Europe') {
                              OriginAddress.Line1 = currentConfig.Apttus_QPConfig__Proposald__r.Agency__r.BillingStreet;
                              OriginAddress.City = currentConfig.Apttus_QPConfig__Proposald__r.Agency__r.BillingCity;
                              OriginAddress.Region = currentConfig.Apttus_QPConfig__Proposald__r.Agency__r.BillingStateCode;
                              OriginAddress.Country = currentConfig.Apttus_QPConfig__Proposald__r.Agency__r.BillingCountryCode;
                              OriginAddress.PostalCode = currentConfig.Apttus_QPConfig__Proposald__r.Agency__r.BillingPostalCode;
                        }
                        else {
                              OriginAddress.Line1 = OriginAddressInfo.Address1__c;
                              OriginAddress.Line2 = OriginAddressInfo.Address2__c;
                              OriginAddress.Line3 = OriginAddressInfo.Address3__c;
                              OriginAddress.City = OriginAddressInfo.City__c;
                              OriginAddress.Region = OriginAddressInfo.StateProvince__c;
                              OriginAddress.Country = OriginAddressInfo.CountryCode__c;
                              OriginAddress.PostalCode = OriginAddressInfo.ZIPPostalCode__c;
                              //Sylvester Agyen (4/4/16) - Commented out due to I-209438  - Using selling country as orgin
                            //OriginAddress.Line1 = currentConfig.Apttus_QPConfig__Proposald__r.Agency__r.ShippingStreet;
                            //OriginAddress.City = currentConfig.Apttus_QPConfig__Proposald__r.Agency__r.ShippingCity;
                            //OriginAddress.Region = currentConfig.Apttus_QPConfig__Proposald__r.Agency__r.ShippingStateCode;
                            //OriginAddress.Country = currentConfig.Apttus_QPConfig__Proposald__r.Agency__r.ShippingCountryCode;
                            //OriginAddress.PostalCode = currentConfig.Apttus_QPConfig__Proposald__r.Agency__r.ShippingPostalCode;
                        }
                        requestWrap.Addresses.add(OriginAddress);

                    } else  {*/
                        OriginAddress.Line1 = OriginAddressInfo.Address1__c;
                        OriginAddress.Line2 = OriginAddressInfo.Address2__c;
                        OriginAddress.Line3 = OriginAddressInfo.Address3__c;
                        OriginAddress.City = OriginAddressInfo.City__c;
                        OriginAddress.Region = OriginAddressInfo.StateProvince__c;
                        OriginAddress.Country = OriginAddressInfo.CountryCode__c;
                        OriginAddress.PostalCode = OriginAddressInfo.ZIPPostalCode__c;
                        requestWrap.Addresses.add(OriginAddress);
                    //}

                    //system.debug('requestWrap.Addresses'+ requestWrap.Addresses);
                    for(Apttus_Config2__LineItem__c lineitem : lineItemList){
                        /*Jeff L - we don't want to send the bundle header product if this is a bundle
                        We can tell if this proposal has a bundle on it by the Product code = QUOTE BUNDLE
                        and the line item has a Line type of Product/Service*/
                        if(lineItem.Apttus_Config2__ProductId__r.ProductCode.equalsIgnoreCase('QUOTE BUNDLE') &&
                          lineitem.Apttus_Config2__LineType__c == 'Product/Service'){
                          //if this is a quote bundle then we don't want to send this product to Avalara, we send
                          //the individual products that make up the bundle, but not the product that represents
                          //the bundle
                          system.debug('inside continue');
                          continue;
                        }
                        AvalaraSchema.Line line = new AvalaraSchema.Line();
                        line.LineNo = lineitem.Name;
                        line.DestinationCode = ShippingAddress.AddressCode;
                        line.OriginCode = OriginAddress.AddressCode;

                        /*Jeff L adding logic for Bundle products I-191810
                        *If the line Type field is option, that means this is a bundle product and we retreive the
                        *details for the product from a different field.
                        */
                        String productCode;
                        String productDescription;
                        if(lineitem.Apttus_Config2__LineType__c == 'Option'){
                          productCode = lineItem.Option_Code__c;
                          productDescription = lineItem.Apttus_Config2__Description__c;
                        } else {
                          productCode = lineitem.Apttus_Config2__ProductId__r.ProductCode;
                          productDescription = lineitem.Apttus_Config2__ProductId__r.Description;
                        }
                        line.ItemCode = productCode;
                        line.Description = productDescription;
                        line.Qty = lineItem.Apttus_Config2__Quantity__c;

                        //I-215662 J Freese Appirio 5/4/16
                        if(lineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Organization__c == 'North America'){
                          line.Amount = lineItem.Apttus_Config2__NetPrice__c;
                        } else {
                          line.Amount = lineItem.Net_Total__c;
                        }

                        /* Jeff L commented this out for I-184195, we no longer need to take
                        Agency into account for this requirement.
                        if(lineitem.Order__r.Pricing_Channel__c == 'Agency' &&
                          lineitem.Order__r.Organization__c == 'North America'){
                          line.Amount = lineItem.GrossTotalAmount__c ;
                        }
                        else if(lineitem.Order__r.Pricing_Channel__c == 'Agency'  &&
                          lineitem.Order__r.Organization__c  == 'Europe' ){
                          line.Amount = lineitem.NetTotalAmount__c;

                        }
                        else if (lineitem.Order__r.Pricing_Channel__c == 'Agency'){
                          line.Amount = lineitem.NetTotalAmount__c;
                        } else{
                          line.Amount = lineItem.NetTotalAmount__c;
                        }
                        */
                        //if(lineItem.Order__r.Organization__c == 'North America'){
                        //  line.Amount = lineItem.GrossTotalAmount__c;
                        //} else {
                        //  line.Amount = lineItem.NetTotalAmount__c;
                        //}
                        ////I-203406 - Tax line was calcuating for Bundle header line as welll
                        //If(lineitem.Apttus_Config2__ProductId__r.Apttus_Config2__ConfigurationType__c =='Bundle' && lineitem.Apttus_Config2__LineType__c =='Product/Service')
                        //{
                        //    Continue;
                        //}
                        //AvalaraSchema.Line line = new AvalaraSchema.Line();
                        //line.LineNo = lineitem.Name;
                        //line.DestinationCode = ShippingAddress.AddressCode;
                        //line.OriginCode = OriginAddress.AddressCode;//BillingAddress.AddressCode;
                        //line.ItemCode = lineitem.Apttus_Config2__ProductId__r.ProductCode;
                        //line.Description = lineitem.Apttus_Config2__ProductId__r.Description;
                        //line.Qty = lineItem.Apttus_Config2__Quantity__c;

                        //if(lineitem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.APTS_Quote_Type__c == 'Agency' &&
                        //    lineitem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Organization__c == 'North America'){
                        //    line.Amount = lineItem.Apttus_Config2__NetPrice__c;
                        //}else{
                        //    line.Amount = lineItem.Net_Total__c;
                        //}

                      requestWrap.Lines.add(line);
                    }
                }

                system.debug('\n\nAvalara request (AvalaraModel_Cart.configStartTaxRateProcessing): \n' + JSON.serializePretty(requestWrap) + '\n\n');
                AvalaraSchema.GetTaxResponse avalaraResponse = model.GetTax(requestWrap);
                system.debug('\n\nAvalara result (AvalaraModel_Cart.configStartTaxRateProcessing): \n' + JSON.serializePretty(avalaraResponse) + '\n\n');

                processGetTaxResponseForConfig(avalaraResponse, currentConfig, lineItemList);
            }
        }catch(Exception e){
            system.debug('\n\nAvalara Integration Error: ' + e + '\nTrace: ' + e.getStackTraceString() + '\n\n');
        }
    }

  public static String OrderStartTaxRateProcessing(set<Id> pProposalIdSet){
    system.debug('\n\n **** Inside AvalaraModel.OrderStartTaxRateProcessing()');
    try{
      Order__c[] orders = [
        SELECT Id, Name, Account__c,VAT_Number__c,
          Account__r.VATNumber__c,Agency__c,
          BillingAccount__r.Organization__c,
          Account__r.AccountID__c,
          //Account__r.CustomerNumber__c,
          Pricing_Channel__c,
          Account__r.ShippingStreet,
          Account__r.ShippingCity,
          Account__r.ShippingStateCode,
          Account__r.ShippingCountryCode,
          Account__r.ShippingPostalCode,
          Agency__r.ShippingStreet,
          Agency__r.ShippingCity,
          Agency__r.ShippingStateCode,
          Agency__r.ShippingCountryCode,
          Agency__r.ShippingPostalCode,
          Account__r.BillingStreet,
          Account__r.BillingCity,
          Account__r.BillingStateCode,
          Account__r.BillingCountryCode,
          Account__r.BillingPostalCode,

          Agency__r.BillingStreet,
          Agency__r.BillingCity,
          Agency__r.BillingStateCode,
          Agency__r.BillingCountryCode,
          Agency__r.BillingPostalCode,

          Account__r.Organization__c,
          Account__r.Entity_Use_Code__c,
          Selling_Country__c,
          QuoteProposal__r.Avalara_CompanyCode__c,
          QuoteProposal__r.Avalara_DocDate__c,
          ParentOrder__r.QuoteProposal__r.Avalara_CompanyCode__c,
          ParentOrder__r.OrderDate__c ,
          Avalara_CompanyCode__c,
          CurrencyIsoCode,
          RecordTypeId,
          Payment_Method_text__c
        FROM Order__c
        WHERE Id IN :pProposalIdSet
      ];

      system.debug('\n\nOrders to Process: '+orders+'\n\n');

      if(orders.size() == 1){
        Order__c currentOrder = orders[0];
        Id ecommOrderRT = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Ecomm');

        /*T-462299*/
        if(currentOrder.RecordTypeId == ecommOrderRT)
            return 'Success';

        AvalaraSchema.RequestHeader header = getAvalaraSetting();

        AvalaraModel model = new AvalaraModel(header);
        AvalaraSchema.GetTaxRequest requestWrap = model.OrderGenerateRequest(currentOrder);
        requestWrap.Lines = new AvalaraSchema.Line[]{};
        requestWrap.Addresses = new AvalaraSchema.Address[]{};

        //line creation
        Order_Line_Item__c[] lineItemList = [
          SELECT Id, Name, Product__r.ProductCode,
                Product__r.Description, Quantity2__c, NetUnitPrice__c, NetTotalAmount__c,
                LineType__c, Option_Bundle_Code__c, Description__c,
                //for result
                VATNationalTaxCode__c,
                StateProvinceTaxCode__c,

                VATNationalTaxRate__c,
                 StateTaxRate__c,
                 CountyTaxRate__c,
                 CityTaxRate__c,
                 SpecialTaxJurisdictionRate__c,
                 SpecialTaxJurisdictionRate1__c,
                 SpecialTaxJurisdictionRate2__c,
                 SpecialTaxJurisdictionRate3__c,
                 SpecialTaxJurisdictionRate4__c,

                 VATNationalTaxAmount__c,
                 StateTaxAmount__c,
                 CountyTaxAmount__c,
                 CityTaxAmount__c,
                 SpecialTaxJurisdictionAmount__c,
                 SpecialTaxJurisdictionAmount1__c,
                 SpecialTaxJurisdictionAmount2__c,
                 SpecialTaxJurisdictionAmount3__c,
                 SpecialTaxJurisdictionAmount4__c,
                 Order__r.Pricing_Channel__c,
                 Order__r.Organization__c,
                 GrossTotalAmount__c


          FROM Order_Line_Item__c
          WHERE Order__c = :currentOrder.Id
        ];
        system.debug('lineItemList :'+lineItemList);

        if(lineItemList.size() > 0){
          AvalaraSchema.Address ShippingAddress = new AvalaraSchema.Address();

          ShippingAddress.AddressCode = 'Shipping';

          ShippingAddress.Line1 = currentOrder.Account__r.ShippingStreet;
          ShippingAddress.City = currentOrder.Account__r.ShippingCity;
          ShippingAddress.Region = currentOrder.Account__r.ShippingStateCode;
          ShippingAddress.Country = currentOrder.Account__r.ShippingCountryCode;
          ShippingAddress.PostalCode = currentOrder.Account__r.ShippingPostalCode;
          requestWrap.Addresses.add(ShippingAddress);

          //This shipping address will be used to validate before avalara call.
          AvalaraSchema.Address2 ShippingAddress2 = new AvalaraSchema.Address2();
          ShippingAddress2.AddressCode = 'Shipping';

          ShippingAddress2.Line1 = currentOrder.Account__r.ShippingStreet;
          ShippingAddress2.City = currentOrder.Account__r.ShippingCity;
          ShippingAddress2.Region = currentOrder.Account__r.ShippingStateCode;
          ShippingAddress2.Country = currentOrder.Account__r.ShippingCountryCode;
          ShippingAddress2.PostalCode = currentOrder.Account__r.ShippingPostalCode;

          //For Origin Address update 11-8-2014 Start
          AvalaraSchema.Address OriginAddress = new AvalaraSchema.Address();
          OriginAddress.AddressCode = 'Origin';

          String OriginCountry = currentOrder.Selling_Country__c == null ? Utility.DEFAULT_AVALARA_ADDRESS : currentOrder.Selling_Country__c;
          if(OriginCountry == 'United Arab Emirates' && currentOrder.Account__r.ShippingCity == 'Dubai'){
            OriginCountry = 'United Arab Emirates1';
          }
          AvalaraAddressInfo__c OriginAddressInfo = Utility.getAvalaraAddressInfo(OriginCountry);

          /*T-413314*/
         /*Jeff L commented out for I-213632
         if(currentOrder.Pricing_Channel__c == 'Agency' && currentOrder.Agency__c != null){
              // I-209135
              if(currentOrder.Account__r.Organization__c == 'Europe') {
                  OriginAddress.Line1 = currentOrder.Agency__r.BillingStreet;
                  OriginAddress.City = currentOrder.Agency__r.BillingCity;
                  OriginAddress.Region = currentOrder.Agency__r.BillingStateCode;
                  OriginAddress.Country = currentOrder.Agency__r.BillingCountryCode;
                  OriginAddress.PostalCode = currentOrder.Agency__r.BillingPostalCode;
              }
              else {
                  OriginAddress.Line1 = currentOrder.Agency__r.ShippingStreet;
                  OriginAddress.City = currentOrder.Agency__r.ShippingCity;
                  OriginAddress.Region = currentOrder.Agency__r.ShippingStateCode;
                  OriginAddress.Country = currentOrder.Agency__r.ShippingCountryCode;
                  OriginAddress.PostalCode = currentOrder.Agency__r.ShippingPostalCode;
              }
              requestWrap.Addresses.add(OriginAddress);

          } else  {*/
              OriginAddress.Line1 = OriginAddressInfo.Address1__c;
              OriginAddress.Line2 = OriginAddressInfo.Address2__c;
              OriginAddress.Line3 = OriginAddressInfo.Address3__c;
              OriginAddress.City = OriginAddressInfo.City__c;
              OriginAddress.Region = OriginAddressInfo.StateProvince__c;
              OriginAddress.Country = OriginAddressInfo.CountryCode__c;
              OriginAddress.PostalCode = OriginAddressInfo.ZIPPostalCode__c;
              requestWrap.Addresses.add(OriginAddress);
          //}
          //For Origin Address update 11-8-2014 End

          system.debug('requestWrap.Addresses'+ requestWrap.Addresses);
          for(Order_Line_Item__c lineitem : lineItemList){
            /*Jeff L - we don't want to send the bundle header product if this is a bundle
            We can tell if this proposal has a bundle on it by the Product code = QUOTE BUNDLE
            and the line item has a Line type of Product/Service*/
            if(lineItem.Product__r.ProductCode.equalsIgnoreCase('QUOTE BUNDLE') &&
              lineitem.LineType__c == 'Product/Service'){
              //if this is a quote bundle then we don't want to send this product to Avalara, we send
              //the individual products that make up the bundle, but not the product that represents
              //the bundle
              system.debug('inside continue');
              continue;
            }
            AvalaraSchema.Line line = new AvalaraSchema.Line();
            line.LineNo = lineitem.Name;
            line.DestinationCode = ShippingAddress.AddressCode;
            line.OriginCode = OriginAddress.AddressCode;

            /*Jeff L adding logic for Bundle products I-191810
            *If the line Type field is option, that means this is a bundle product and we retreive the
            *details for the product from a different field.
            */
            String productCode;
            String productDescription;
            if(lineitem.LineType__c == 'Option'){
              productCode = lineItem.Option_Bundle_Code__c;
              productDescription = lineItem.Description__c;
            } else {
              productCode = lineitem.Product__r.ProductCode;
              productDescription = lineitem.Product__r.Description;
            }
            line.ItemCode = productCode;
            line.Description = productDescription;
            line.Qty = lineItem.Quantity2__c;
            line.Amount = lineItem.NetTotalAmount__c;
            /* Jeff L commented this out for I-184195, we no longer need to take
            Agency into account for this requirement.
            if(lineitem.Order__r.Pricing_Channel__c == 'Agency' &&
              lineitem.Order__r.Organization__c == 'North America'){
              line.Amount = lineItem.GrossTotalAmount__c ;
            }
            else if(lineitem.Order__r.Pricing_Channel__c == 'Agency'  &&
              lineitem.Order__r.Organization__c  == 'Europe' ){
              line.Amount = lineitem.NetTotalAmount__c;

            }
            else if (lineitem.Order__r.Pricing_Channel__c == 'Agency'){
              line.Amount = lineitem.NetTotalAmount__c;
            } else{
              line.Amount = lineItem.NetTotalAmount__c;
            }
            */
            if(lineItem.Order__r.Organization__c == 'North America'){
              line.Amount = lineItem.GrossTotalAmount__c;
            } else {
              line.Amount = lineItem.NetTotalAmount__c;
            }

            requestWrap.Lines.add(line);
          }
        system.debug('\n\nAvalara request (AvalaraModel.OrderStartTaxRateProcessing): \n' + JSON.serializePretty(requestWrap) + '\n\n');
        AvalaraSchema.GetTaxResponse avalaraResponse = model.GetTax(requestWrap);

        system.debug('\n\nAvalara result (AvalaraModel.OrderStartTaxRateProcessing): \n' + JSON.serializePretty(avalaraResponse) + '\n\n');
        if(avalaraResponse.ResultCode == 'Error') {
            system.debug('!!!!!!!!!!'+avalaraResponse.Messages[0]);
            return avalaraResponse.Messages[0].Summary;
        }
        system.debug('OriginAddress.Country='+OriginAddress.Country);
        if(ShippingAddress.Country == 'US' || ShippingAddress.Country == 'Canada'){
            validateAddress(ShippingAddress2, currentOrder.Account__c);
        }
        system.debug('^^^Calling processGetTaxResponseForOrder');
        processGetTaxResponseForOrder(avalaraResponse, currentOrder, lineItemList);
        }else {
            return 'No Line Items';

        }
      }
      system.debug('^^^Returning success');
      return 'Success';
    }catch(Exception e){
      system.debug('\n\nAvalara Integration Error: ' + e + '\nTrace: ' + e.getStackTraceString() + '\n\n');
       return null;
    }
  }

  private static void processGetTaxResponseForConfig(AvalaraSchema.GetTaxResponse pResponse,Apttus_Config2__ProductConfiguration__c pConfig,Apttus_Config2__LineItem__c  [] pLineitems){
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
    }

  private static void processGetTaxResponseForOrder(AvalaraSchema.GetTaxResponse pResponse, Order__c pOrder, Order_Line_Item__c[] pLineitems){
    system.debug('\n\n **** Inside AvalaraModel.processGetTaxResponseForOrder()');

    pOrder.AvalaraResponseCode__c = pResponse.ResultCode;
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
    pOrder.AvalaraResponseMessage__c = resultMsg;
    pOrder.Avalara_TimeStamp__c = pResponse.TimeStamp;
    Decimal totalTaxPercent = 0;
    //tax detail prep
    map<String, AvalaraSchema.TaxDetail> taxSummaryMap = new map<String, AvalaraSchema.TaxDetail>();
    map<String, AvalaraSchema.TaxDetail> specialTaxSummaryMap = new map<String, AvalaraSchema.TaxDetail>();
    if(pResponse.TaxSummary != null && pResponse.TaxSummary.size() > 0){
      for(AvalaraSchema.TaxDetail detail : pResponse.TaxSummary){
        if(detail.JurisType == AvalaraSchema.JURIS_TYPE_SPECIAL){
          specialTaxSummaryMap.put(detail.JurisCode, detail);
        }else{
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
        Order_Line_Item__c[] linesToBeUpdated = new Order_Line_Item__c[]{};
        for(Order_Line_Item__c line : pLineitems){
          if(proposalLineNameToTaxLine.containsKey(line.Name)){
            AvalaraSchema.TaxLine tax = proposalLineNameToTaxLine.get(line.Name);

            String countryCode = pOrder.Account__r.ShippingCountryCode == null ? '' : pOrder.Account__r.ShippingCountryCode.toLowerCase();
            String stateCode = pOrder.Account__r.ShippingStateCode == null ? '' : pOrder.Account__r.ShippingStateCode.toLowerCase();

            //ca = Canada, qc = Quebec, sk = Saskatchewan, us = United States
            Boolean validForVATNationalValues = countryCode != 'us' && !(countryCode == 'ca' && (stateCode == 'qc' || stateCode == 'sk'));
            Boolean validForStateValues = !validForVATNationalValues;

            if(validForStateValues){
              line.StateProvinceTaxCode__c = tax.TaxCode;
            }else{
              line.StateProvinceTaxCode__c = null;
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
            if(cityDetail != null && validForStateValues){
              line.CityTaxRate__c = Utility.getPercentage(cityDetail.Rate);
              line.CityTaxAmount__c = tax.Taxable * cityDetail.Rate;
            }else{
              line.CityTaxRate__c = null;
              line.CityTaxAmount__c = null;
            }

            //special jurisdiction tax population
            if(!specialTaxSummaryMap.isEmpty() && specialTaxSummaryMap.size() <= 4 && validForStateValues){
              AvalaraSchema.TaxDetail[] specialTaxes = specialTaxSummaryMap.values();
              system.debug('\n\nSpecial Taxes: ' + specialTaxes.size() + '\n\n');
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

            line.APTS_Tax_Rate__c = Utility.getPercentage(tax.Rate);
            line.APTS_Tax_Amount__c = tax.Tax;

            linesToBeUpdated.add(line);
          }
        }

        if(!linesToBeUpdated.isEmpty()){
          update linesToBeUpdated;
        }

      }
    }
    // validateOrUpdateAddress(pResponse, pOrder.Account__c);
    //Line Item Processing end

    OrderTriggerHandler.ExecuteTriggers = false;
    update pOrder;

  }

  public static String ProposalStartTaxRateProcessing(set<Id> pProposalIdSet){
    system.debug('\n\n **** Inside AvalaraModel.ProposalStartTaxRateProcessing()');
    try{
      Apttus_Proposal__Proposal__c[] proposals = [
        SELECT
          Id, Name,Agency__c,
          Apttus_Proposal__Account__c,
          Apttus_Proposal__Account__r.VATNumber__c,
          BillingAccount__r.Organization__c,
          VAT_Number__c,
          Payment_Method1__c,
          AccountID__c,
          //Apttus_Proposal__Account__r.CustomerNumber__c,
          APTS_Quote_Type__c,
          Agency__r.ShippingStreet,
          Agency__r.ShippingCity,
          Agency__r.ShippingStateCode,
          Agency__r.ShippingCountryCode,
          Agency__r.ShippingPostalCode,
          Agency__r.BillingStreet,
          Agency__r.BillingCity,
          Agency__r.BillingStateCode,
          Agency__r.BillingCountryCode,
          Agency__r.BillingPostalCode,
          Apttus_Proposal__Account__r.ShippingStreet,
          Apttus_Proposal__Account__r.ShippingCity,
          Apttus_Proposal__Account__r.ShippingStateCode,
          Apttus_Proposal__Account__r.ShippingCountryCode,
          Apttus_Proposal__Account__r.ShippingPostalCode,
          //BillingAccount__r.Organization__c,
          Apttus_Proposal__Account__r.BillingStreet,
          Apttus_Proposal__Account__r.BillingCity,
          Apttus_Proposal__Account__r.BillingStateCode,
          Apttus_Proposal__Account__r.BillingCountryCode,
          Apttus_Proposal__Account__r.BillingPostalCode,
          Apttus_Proposal__Account__r.AccountID__c,
          Apttus_Proposal__Account__r.Organization__c,
          Apttus_Proposal__Account__r.Entity_Use_Code__c,
          /*
            BillingStreet__c,
            BillingCity__c,
            BillingStateProvince__c,
            BillingCountry__c,
            BillingZipPostalCode__c,
          */

          Selling_Country__c, //Added 11-8-2014 for Origin Address

          Avalara_CompanyCode__c,
          Avalara_DocDate__c,
          CurrencyIsoCode
        FROM Apttus_Proposal__Proposal__c
        WHERE Id IN :pProposalIdSet
      ];
      //Account.BillingStreet
      //Apttus_Proposal__Proposal__c.
      if(proposals.size() == 1){
        Apttus_Proposal__Proposal__c currentProposal = proposals[0];

        AvalaraSchema.RequestHeader header = getAvalaraSetting();

        AvalaraModel model = new AvalaraModel(header);
        AvalaraSchema.GetTaxRequest requestWrap = model.ProposalGenerateRequest(currentProposal);
        requestWrap.Lines = new AvalaraSchema.Line[]{};
        requestWrap.Addresses = new AvalaraSchema.Address[]{};
        system.debug('!!!requestWrap ' + requestWrap.serialize());
        //line creation
        Apttus_Proposal__Proposal_Line_Item__c[] lineItemList = [
          SELECT Id, Name, Apttus_Proposal__Product__r.ProductCode,
                Apttus_Proposal__Product__r.Description, Apttus_QPConfig__Quantity2__c, Apttus_QPConfig__NetPrice__c,
                Net_Total__c, Gross_Total__c,
                //for result
                VATNationalTaxCode__c,
                StateProvinceTaxCode__c,

                VATNationalTaxRate__c,
                 StateTaxRate__c,
                 CountyTaxRate__c,
                 CityTaxRate__c,
                 SpecialTaxJurisdictionRate__c,
                 SpecialTaxJurisdictionRate1__c,
                 SpecialTaxJurisdictionRate2__c,
                 SpecialTaxJurisdictionRate3__c,
                 SpecialTaxJurisdictionRate4__c,

                 VATNationalTaxAmount__c,
                 StateTaxAmount__c,
                 CountyTaxAmount__c,
                 CityTaxAmount__c,
                 SpecialTaxJurisdictionAmount__c,
                 SpecialTaxJurisdictionAmount1__c,
                 SpecialTaxJurisdictionAmount2__c,
                 SpecialTaxJurisdictionAmount3__c,
                 SpecialTaxJurisdictionAmount4__c,

                 APTS_Tax_Rate__c,
                 APTS_Tax_Amount__c,

                 Apttus_Proposal__Proposal__r.APTS_Quote_Type__c,

                 Apttus_Proposal__Proposal__r.Organization__c,
                 Apttus_Proposal__Proposal__r.AccountOrganization__c,
                 Apttus_QPConfig__LineType__c,
                 Option_Bundle_Code__c,
                 Apttus_Proposal__Description__c

          FROM Apttus_Proposal__Proposal_Line_Item__c
          WHERE Apttus_Proposal__Proposal__c = :currentProposal.Id
        ];
        system.debug('lineItemList :'+lineItemList);

        if(lineItemList.size() > 0){

          // As per issue I-209135, EU Agency will have Agency biling address as destination address

          AvalaraSchema.Address ShippingAddress = new AvalaraSchema.Address();
          //This address will be used to validate the posting address before avalara call.
          AvalaraSchema.Address2 ShippingAddress2 = new AvalaraSchema.Address2();

          if(currentProposal.Agency__c != null && currentProposal.Apttus_Proposal__Account__r.Organization__c == 'Europe'){

            ShippingAddress.AddressCode = 'Shipping';
            ShippingAddress.Line1 = currentProposal.Agency__r.BillingStreet;
            ShippingAddress.City = currentProposal.Agency__r.BillingCity;
            ShippingAddress.Region = currentProposal.Agency__r.BillingStateCode;
            ShippingAddress.Country = currentProposal.Agency__r.BillingCountryCode;
            ShippingAddress.PostalCode = currentProposal.Agency__r.BillingPostalCode;
            requestWrap.Addresses.add(ShippingAddress);

            ShippingAddress2.AddressCode = 'Shipping';
            ShippingAddress2.Line1 = currentProposal.Agency__r.BillingStreet;
            ShippingAddress2.City =  currentProposal.Agency__r.BillingCity;
            ShippingAddress2.Region = currentProposal.Agency__r.BillingStateCode;
            ShippingAddress2.Country = currentProposal.Agency__r.BillingCountryCode;
            ShippingAddress2.PostalCode = currentProposal.Agency__r.BillingPostalCode;

          }
          else {
            ShippingAddress.AddressCode = 'Shipping';
            ShippingAddress.Line1 = currentProposal.Apttus_Proposal__Account__r.ShippingStreet;
            ShippingAddress.City = currentProposal.Apttus_Proposal__Account__r.ShippingCity;
            ShippingAddress.Region = currentProposal.Apttus_Proposal__Account__r.ShippingStateCode;
            ShippingAddress.Country = currentProposal.Apttus_Proposal__Account__r.ShippingCountryCode;
            ShippingAddress.PostalCode = currentProposal.Apttus_Proposal__Account__r.ShippingPostalCode;
            requestWrap.Addresses.add(ShippingAddress);

            ShippingAddress2.AddressCode = 'Shipping';
            ShippingAddress2.Line1 = currentProposal.Apttus_Proposal__Account__r.ShippingStreet;
            ShippingAddress2.City = currentProposal.Apttus_Proposal__Account__r.ShippingCity;
            ShippingAddress2.Region = currentProposal.Apttus_Proposal__Account__r.ShippingStateCode;
            ShippingAddress2.Country = currentProposal.Apttus_Proposal__Account__r.ShippingCountryCode;
            ShippingAddress2.PostalCode = currentProposal.Apttus_Proposal__Account__r.ShippingPostalCode;

          }

          //For Origin Address update 11-8-2014 Start
          AvalaraSchema.Address OriginAddress = new AvalaraSchema.Address();
          OriginAddress.AddressCode = 'Origin';

          String OriginCountry = currentProposal.Selling_Country__c == null ? Utility.DEFAULT_AVALARA_ADDRESS : currentProposal.Selling_Country__c;
          if(OriginCountry == 'United Arab Emirates' && currentProposal.Apttus_Proposal__Account__r.ShippingCity == 'Dubai'){
            OriginCountry = 'United Arab Emirates1';
          }
          AvalaraAddressInfo__c OriginAddressInfo = Utility.getAvalaraAddressInfo(OriginCountry);

          /*T-413314*/

          /* Commented below code for I-209135 as Origin will be Monster Selling Country always*/

          /*if(currentProposal.APTS_Quote_Type__c == 'Agency' && currentProposal.Agency__c != null){
              // I-209135
              if(currentProposal.Apttus_Proposal__Account__r.Organization__c == 'Europe') {
                  OriginAddress.Line1 = currentProposal.Agency__r.BillingStreet;
                  OriginAddress.City = currentProposal.Agency__r.BillingCity;
                  OriginAddress.Region = currentProposal.Agency__r.BillingStateCode;
                  OriginAddress.Country = currentProposal.Agency__r.BillingCountryCode;
                  OriginAddress.PostalCode = currentProposal.Agency__r.BillingPostalCode;
              }
              else {
                  OriginAddress.Line1 = OriginAddressInfo.Address1__c;
                  OriginAddress.Line2 = OriginAddressInfo.Address2__c;
                  OriginAddress.Line3 = OriginAddressInfo.Address3__c;
                  OriginAddress.City = OriginAddressInfo.City__c;
                  OriginAddress.Region = OriginAddressInfo.StateProvince__c;
                  OriginAddress.Country = OriginAddressInfo.CountryCode__c;
                  OriginAddress.PostalCode = OriginAddressInfo.ZIPPostalCode__c;

                  //Sylvester Agyen (4/3/16) - Commented out due to I-209438  - Using selling country as origin
                //OriginAddress.Line1 = currentProposal.Agency__r.ShippingStreet;
                //OriginAddress.City = currentProposal.Agency__r.ShippingCity;
                //OriginAddress.Region = currentProposal.Agency__r.ShippingStateCode;
                //OriginAddress.Country = currentProposal.Agency__r.ShippingCountryCode;
                //OriginAddress.PostalCode = currentProposal.Agency__r.ShippingPostalCode;
              }
              requestWrap.Addresses.add(OriginAddress);
          }
          else  {
          */
             // String OriginCountry = currentProposal.Selling_Country__c == null ? Utility.DEFAULT_AVALARA_ADDRESS : currentProposal.Selling_Country__c;
              //AvalaraAddressInfo__c OriginAddressInfo = Utility.getAvalaraAddressInfo(OriginCountry);

              OriginAddress.Line1 = OriginAddressInfo.Address1__c;
              OriginAddress.Line2 = OriginAddressInfo.Address2__c;
              OriginAddress.Line3 = OriginAddressInfo.Address3__c;
              OriginAddress.City = OriginAddressInfo.City__c;
              OriginAddress.Region = OriginAddressInfo.StateProvince__c;
              OriginAddress.Country = OriginAddressInfo.CountryCode__c;
              OriginAddress.PostalCode = OriginAddressInfo.ZIPPostalCode__c;
              requestWrap.Addresses.add(OriginAddress);
              //For Origin Address update 11-8-2014 End

          //}


          if(currentProposal.Payment_Method1__c == 'Partner'){

              AvalaraSchema.TaxOverride taxOverride = new AvalaraSchema.TaxOverride();
              taxOverride.TaxOverrideType =  'TaxAmount';
              taxOverride.TaxAmount =  0;
              //taxOverride.TaxDate =  ;
              taxOverride.Reason =  'Newspaper';
              requestWrap.TaxOverride = taxOverride;

          }


         String org = currentProposal.Apttus_Proposal__Account__r.Organization__c ;
         if(org == 'Europe' || org == 'Asia Pacific') {
               if(currentProposal.Apttus_Proposal__Account__r.Entity_Use_Code__c != '' && currentProposal.Apttus_Proposal__Account__r.Entity_Use_Code__c != 'Null'){
                  requestWrap.CustomerUsageType = currentProposal.Apttus_Proposal__Account__r.Entity_Use_Code__c;
               }
         }

          for(Apttus_Proposal__Proposal_Line_Item__c lineitem : lineItemList){
            /*Jeff L - we don't want to send the bundle header product if this is a bundle
            We can tell if this proposal has a bundle on it by the Product code = QUOTE BUNDLE
            and the line item has a Line type of Product/Service*/
            system.debug('####Line Item Check ' + lineItem.Apttus_Proposal__Product__r.ProductCode);
            if(lineItem.Apttus_Proposal__Product__r.ProductCode.equalsIgnoreCase('QUOTE BUNDLE') &&
              lineitem.Apttus_QPConfig__LineType__c == 'Product/Service'){
              //if this is a quote bundle then we don't want to send this product to Avalara, we send
              //the individual products that make up the bundle, but not the product that represents
              //the bundle
              system.debug('inside continue');
              continue;
            }
            AvalaraSchema.Line line = new AvalaraSchema.Line();
            line.LineNo = lineitem.Name;
            line.DestinationCode = ShippingAddress.AddressCode;
            line.OriginCode = OriginAddress.AddressCode;//Origin Address update 11-8-2014 Start
            /*Jeff L adding logic for Bundle products I-191810
            *If the line Type field is option, that means this is a bundle product and we retreive the
            *details for the product from a different field.
            */
            String productCode;
            String productDescription;
            if(lineitem.Apttus_QPConfig__LineType__c == 'Option'){
              productCode = lineItem.Option_Bundle_Code__c;
              productDescription = lineItem.Apttus_Proposal__Description__c;
            } else {
              productCode = lineitem.Apttus_Proposal__Product__r.ProductCode;
              productDescription = lineitem.Apttus_Proposal__Product__r.Description;
            }
            line.ItemCode = productCode;
            line.Description = productDescription;
            line.Qty = lineItem.Apttus_QPConfig__Quantity2__c;
            //Jeff L commenting out this logic per I-184195, we want to pass
            //Gross for NA, and Net for EU
            /*if(lineitem.Apttus_Proposal__Proposal__r.APTS_Quote_Type__c == 'Agency' &&
              lineitem.Apttus_Proposal__Proposal__r.Organization__c == 'North America'){
              line.Amount = lineItem.Net_Total__c;
            }
            else if(lineitem.Apttus_Proposal__Proposal__r.APTS_Quote_Type__c == 'Agency' &&
                    lineitem.Apttus_Proposal__Proposal__r.Organization__c == 'Europe' ){
              line.Amount = lineItem.Apttus_QPConfig__NetPrice__c;

            }
            else if (lineitem.Apttus_Proposal__Proposal__r.APTS_Quote_Type__c != 'Agency' ){
              line.Amount = lineItem.Apttus_QPConfig__NetPrice__c;
            }*/

            if(lineitem.Apttus_Proposal__Proposal__r.AccountOrganization__c == 'North America'){
              line.Amount = lineItem.Gross_Total__c;
            } else {
              line.Amount = LineItem.Net_Total__c;
            }

            requestWrap.Lines.add(line);
          }
        //System.assert(false,requestWrap);
        system.debug('\n\nAvalara request (AvalaraModel.ProposalStartTaxRateProcessing): \n' + JSON.serializePretty(requestWrap) + '\n\n');
        AvalaraSchema.GetTaxResponse avalaraResponse = model.GetTax(requestWrap);

        //Updating the account object
        system.debug('\n\nAvalara result (AvalaraModel.ProposalStartTaxRateProcessing): \n' + JSON.serializePretty(avalaraResponse) + '\n\n');
        if(ShippingAddress.Country == 'US' || ShippingAddress.Country == 'Canada'){
            validateAddress(ShippingAddress2, currentProposal.Apttus_Proposal__Account__c);
        }
        system.debug('^^^Calling processGetTaxResponseForProposal');
        processGetTaxResponseForProposal(avalaraResponse, currentProposal, lineItemList);

        }else {

            return 'No Line Items';

        }
      }
      system.debug('^^^Returning success');
      return 'Success';
    }catch(Exception e){
      system.debug('\n\nAvalara Integration Error: ' + e + '\nTrace: ' + e.getStackTraceString() + '\n\n');
       return null;
    }
  }

  //Update Account object if the shipping address is different. (T-408276)
  public static void validateOrUpdateAddress(AvalaraSchema.Address response, Id accountId){
    Account acc = [SELECT ShippingStreet,
          ShippingCity,
          ShippingStateCode,
          ShippingCountryCode,
          ShippingPostalCode FROM Account WHERE Id =: accountId];
          system.debug(acc);


            acc.ShippingPostalCode = response.PostalCode;
            acc.ShippingCountryCode = response.Country ;
            acc.ShippingStateCode = response.Region;
            acc.ShippingCity = response.City;
            acc.ShippingStreet =response.Line1 + ' '+response.Line2+' '+response.Line3;

            Database.Update(acc);


  }

  private static void processGetTaxResponseForProposal(AvalaraSchema.GetTaxResponse pResponse, Apttus_Proposal__Proposal__c pProposal, Apttus_Proposal__Proposal_Line_Item__c[] pLineitems){
    system.debug('\n\n **** Inside AvalaraModel.processGetTaxResponse()');
    pProposal.AvalaraResponseCode__c = pResponse.ResultCode;
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
    pProposal.AvalaraResponseMessage__c = resultMsg;
    pProposal.Avalara_TimeStamp__c = pResponse.TimeStamp;
    Decimal totalTaxPercent = 0;
    //tax detail prep
    map<String, AvalaraSchema.TaxDetail> taxSummaryMap = new map<String, AvalaraSchema.TaxDetail>();
    map<String, AvalaraSchema.TaxDetail> specialTaxSummaryMap = new map<String, AvalaraSchema.TaxDetail>();
    if(pResponse.TaxSummary != null && pResponse.TaxSummary.size() > 0){
      for(AvalaraSchema.TaxDetail detail : pResponse.TaxSummary){
        if(detail.JurisType == AvalaraSchema.JURIS_TYPE_SPECIAL){
          specialTaxSummaryMap.put(detail.JurisCode, detail);
        }else{
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
        Apttus_Proposal__Proposal_Line_Item__c[] linesToBeUpdated = new Apttus_Proposal__Proposal_Line_Item__c[]{};
        for(Apttus_Proposal__Proposal_Line_Item__c line : pLineitems){
          if(proposalLineNameToTaxLine.containsKey(line.Name)){
            AvalaraSchema.TaxLine tax = proposalLineNameToTaxLine.get(line.Name);

            String countryCode = pProposal.Apttus_Proposal__Account__r.ShippingCountryCode == null ? '' : pProposal.Apttus_Proposal__Account__r.ShippingCountryCode.toLowerCase();
            String stateCode = pProposal.Apttus_Proposal__Account__r.ShippingStateCode == null ? '' : pProposal.Apttus_Proposal__Account__r.ShippingStateCode.toLowerCase();

            //ca = Canada, qc = Quebec, sk = Saskatchewan, us = United States
            Boolean validForVATNationalValues = countryCode != 'us' && !(countryCode == 'ca' && (stateCode == 'qc' || stateCode == 'sk'));
            Boolean validForStateValues = !validForVATNationalValues;

            if(validForStateValues){
              line.StateProvinceTaxCode__c = tax.TaxCode;
              pProposal.StateProvinceTaxCode__c = tax.TaxCode;
            }else{
              line.StateProvinceTaxCode__c = null;
              pProposal.StateProvinceTaxCode__c = null;
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
            if(cityDetail != null && validForStateValues){
              line.CityTaxRate__c = Utility.getPercentage(cityDetail.Rate);
              line.CityTaxAmount__c = tax.Taxable * cityDetail.Rate;
            }else{
              line.CityTaxRate__c = null;
              line.CityTaxAmount__c = null;
            }

            //special jurisdiction tax population
            if(!specialTaxSummaryMap.isEmpty() && specialTaxSummaryMap.size() <= 4 && validForStateValues){
              AvalaraSchema.TaxDetail[] specialTaxes = specialTaxSummaryMap.values();
              system.debug('\n\nSpecial Taxes: ' + specialTaxes.size() + '\n\n');
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

            line.APTS_Tax_Rate__c = Utility.getPercentage(tax.Rate);
            line.APTS_Tax_Amount__c = tax.Tax;

            linesToBeUpdated.add(line);
          }
        }

        if(!linesToBeUpdated.isEmpty()){
          system.debug('^^^Updating '+linesToBeUpdated.size()+' lines:'+linesToBeUpdated);
          update linesToBeUpdated;
        }else {
          system.debug('^^^No lines to update');
        }
      }
    }
    //Line Item Processing end
    system.debug(totalTaxPercent);
    pProposal.Apttus_Proposal__Sales_Tax_Percent__c = totalTaxPercent;
    ApttusProposalTriggerHandler.ExecuteTriggers = false;
    system.debug(totalTaxPercent+'!!!!!!!!!!!!!');
    update pProposal;
   // validateOrUpdateAddress(pResponse, pProposal.Apttus_Proposal__Account__c);
  }

  /*Called from Buttons 'Generate Quote Report' & 'Get Tax' on Apttus_Proposal__Proposal__c*/
  webservice static Boolean getQuoteTaxFromButton(Id pProposalId){
    try{
      system.debug('\n\nCalling asyncronous Avalara callout method.\n\n');
      String status = ProposalStartTaxRateProcessing(new set<Id>{pProposalId});
      if(status == 'Success')
        return true;
      else
        return false;
    }catch(Exception e){
      system.debug('\n\n getQuoteTaxeFromButton error:' + e + '\n\n');
      return false;
    }
  }
  /*Called from Buttons 'Send To Verification' on Order__c*/
  webservice static String getOrderTaxFromButton(Id pOrderId){
    try{
      system.debug('\n\nCalling asyncronous Avalara callout method.\n\n');
      String status = OrderStartTaxRateProcessing(new set<Id>{pOrderId});
      return status;
       /*if(status == 'Success')
        return true;
      else
        return false;*/
    }catch(Exception e){
      system.debug('\n\n getorderTaxeFromButton error:' + e + '\n\n');
      return e.getMessage();
    }
  }

  public static String setIstoCommit(Id pProposalId){
      IsToCommit = 'true';
      String status = proposalStartTaxRateProcessing(new set<Id>{pProposalId});
      return status;
  }

  public static void ProposalProcessTaxRate(Apttus_Proposal__Proposal__c[] pProposalList, map<Id, Apttus_Proposal__Proposal__c> pProposalOldMap){
    //commenting because the only needed trigger point is in Generate Quote Button click on quote
    /*system.debug('\n\n **** Inside AvalaraModel.ProposalProcessTaxRate()');

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
    AsyncTaxRateProcessing(proposalIds, QUOTE);*/
  }

  /*public static void OrderProcessTaxRate(Order__c[] pOrderList, map<Id, Order__c> pOrderOldMap){
    //commenting because the only needed trigger point is in Generate Quote Button click on quote
    /*system.debug('\n\n **** Inside AvalaraModel.OrderProcessTaxRate()');

    if(pOrderList.size() > 1){
      system.debug('\n\nOrder update not from UI.\n\n');
      return;
    }

    set<Id> orderIdSet = new set<Id>();

    Id standardOrderRT = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Standard');

    for(Order__c o : pOrderList){
      if(o.QuoteProposal__c != null && o.RecordTypeId == standardOrderRT &&
        (o.OrderStatus__c == 'Sent To Verification' && pOrderOldMap.get(o.Id).OrderStatus__c != 'Sent To Verification')){
        orderIdSet.add(o.Id);
      }
    }

    if(orderIdSet.size() == 0){
      system.debug('\n\nNo order ready for avalara integration.\n\n');
      return;
    }

    system.debug('\n\nCalling AsyncTaxRateProcessing method.\n\n');
    AsyncTaxRateProcessing(orderIdSet, ORDER);
  }*/

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

    AvalaraSchema.RequestHeader reqHeader = new AvalaraSchema.RequestHeader();
    reqHeader.EndPoint = 'https://development.avalara.net/1.0/tax/get';
    reqHeader.Client = 'Monster Worldwide, Inc.';
    reqHeader.CompanyCode = 'MWW';
    //header.EndPoint = Utility.getWebServiceEnpoint('BoozDummyEndpoint');

    //reqHeader.Password = 'Cloud$herpas2014';
    reqHeader.Username = 'salesforce';
    //reqHeader.Username = 'cloudsherpas';
    reqHeader.Password = 'M0nster789';

    AvalaraModel model = new AvalaraModel(reqHeader);
    try{
      output += 'GetTax: ' + JSON.serializePretty(model.GetTax(req));
    }catch(Exception e){
      output += 'Error: ' + e;
      output += '\n\n' + model.invoke(req.serialize()) + '\n\n';
    }

    system.debug(output);
    //return output;
  }



}