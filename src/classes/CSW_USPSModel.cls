public class CSW_USPSModel {
    private static final String CITY_STATE_LOOKUP = 'CityStateLookup';
    public static final String SUCCESS = 'Success';
    public static final String FAILED = 'Failed';
    
    private String Endpoint;
    private String UserID;
    private String[] ZipList;
    private AddressXMLTagsWrap AddressXMLTags = new AddressXMLTagsWrap();
    public Boolean IsTest = true;
    
    //CSW_USPSModel USPSConnector = new CSW_USPSModel('USER_ID', Utility.getWebServiceEnpoint('USPSAddressValidation'));
    public CSW_USPSModel(String pUserID, String pEndpoint){
        UserID = pUserID;
        ZipList = new String[]{};
        Endpoint = pEndpoint + '?API='+CITY_STATE_LOOKUP+'&XML=';
        system.debug('\n\nUsed Endpoint: ' + Endpoint + '\n\n');
    }
    
    public void addZip(String pZip){
        ZipList.add(pZip);
    }
    
    public Response Send(){
        String request = '<CityStateLookupRequest USERID="' + UserID + '">';
        for(Integer i = 0; i < ZipList.size(); i++){
            request += '<ZipCode ID= "'+i+'">';
                request += '<Zip5>' + ZipList[i] + '</Zip5>';
            request += '</ZipCode>';
        }
        request += '</CityStateLookupRequest>';
        
        request = EncodingUtil.urlEncode(request, 'UTF-8');
        
        return Connect(Endpoint + request);
    }
    
    private Response Connect(String pRequest){
        Response result = new Response();
        String rawStringResponse = '';
        try{
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setEndpoint(pRequest);
            req.setTimeout(60000);
            Http connection = new Http();
            
            if(IsTest || Test.isRunningTest()){
            	rawStringResponse = testResponse();
            	system.debug('==rawStringResponse=='+rawStringResponse);
               // result.Addresses = parseAddresses(testResponse());
            }
            else{
            	HttpResponse response = connection.send(req);
            	rawStringResponse = response.getBody();
            }
            result.Addresses = parseAddresses(rawStringResponse);
			system.debug('==result.Addresses=='+result.Addresses);
            if(result.Addresses.size() > 0){
                if(result.Addresses[0].ErrorNumber != null){
                    result.Result = FAILED;
                    result.Message = 'Error Number: ' + result.Addresses[0].ErrorNumber + 
                    '\nDescription: ' + result.Addresses[0].Description +
                    '\nSource: ' + result.Addresses[0].Source;
                }else{
                    result.Result = SUCCESS;
                    result.Message = 'Address validation webservice callout succeeded.';
                }
            }else{
                result.Result = FAILED;
                result.Message = 'No address info obtained.';
            }
        }catch(Exception e){
            result.Result = FAILED;
            result.Message = 'Address validation webservice callout failed.\nError: ' + e;
        }
        system.debug('\n\nUSPS Address Validation: ' + result.Message + '\nRaw response: ' + rawStringResponse + '\nURI: ' + pRequest + '\n\n');
        return result;
    }
    
    private Address[] parseAddresses(String pRawXML){
        Address[] output = new Address[]{};
        XmlStreamReader reader = new XmlStreamReader(pRawXML);
        while(reader.hasNext()){
            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == AddressXMLTags.ZipCode){
                output.add(parseAddress(reader));
            }
            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == AddressXMLTags.Error){
                output.add(parseError(reader));
            }
            reader.next();
        }
        system.debug('\n\n' + output + '\n\n');
        return output;
    }
    
    @TestVisible private Address parseError(XmlStreamReader pReader){
        String currentTag;
        Address currentAddress = new Address();
        while(pReader.hasNext()){
            if(pReader.getEventType() == XmlTag.START_ELEMENT){
                currentTag = pReader.getLocalName();
            }
            if(pReader.getEventType() == XmlTag.END_ELEMENT && pReader.getLocalName() == AddressXMLTags.Error){
                break;
            }else if(pReader.getEventType() == XmlTag.CHARACTERS){
                String val = pReader.getText();
                if(currentTag == AddressXMLTags.ErrorNumber){
                    currentAddress.ErrorNumber = val;
                }else if(currentTag == AddressXMLTags.Description){
                    currentAddress.Description = val;
                }else if(currentTag == AddressXMLTags.Source){
                    currentAddress.Source = val;
                }
            }
            pReader.next();
        }
        return currentAddress;
    }
    
    private Address parseAddress(XmlStreamReader pReader){
        String currentTag;
        Address currentAddress = new Address();
        while(pReader.hasNext()){
            if(pReader.getEventType() == XmlTag.START_ELEMENT){
                currentTag = pReader.getLocalName();
            }
            if(pReader.getEventType() == XmlTag.END_ELEMENT && pReader.getLocalName() == AddressXMLTags.ZipCode){
                break;
            }else if(pReader.getEventType() == XmlTag.CHARACTERS){
                String val = pReader.getText();
                if(currentTag == AddressXMLTags.Zip5){
                    currentAddress.Zip5 = val;
                }else if(currentTag == AddressXMLTags.City){
                    currentAddress.City = val;
                }else if(currentTag == AddressXMLTags.State){
                    currentAddress.State = val;
                }
            }
            pReader.next();
        }
        return currentAddress;
    }
    
    public class Response{
        public String Result;
        public String Message;
        public Address[] Addresses;
    }
    
    public class Address{
        public String Zip5;
        public String City {get; set{
            City = value;
            if(City != null){
                String[] strs = City.split(' ');
                String output = '';
                for(String s : strs){
                    output += s.toLowerCase().capitalize() + ' ';
                }
                CityFormatted = output.removeEnd(' ');
            }else{
                CityFormatted = null;
            }
        }}
        
        public String State;
        
        public String CityFormatted;
        
        public String ErrorNumber;
        public String Description;
        public String Source;
    }
    
    public class AddressXMLTagsWrap {
        //for valid responses
        public final String ZipCode = 'ZipCode'; 
        public final String Zip5 = 'Zip5';
        public final String City = 'City';
        public final String State = 'State';
        
        //for error responses
        public final String Error = 'Error';
        public final String ErrorNumber = 'Number';
        public final String Description = 'Description';
        public final String Source = 'Source';
    }
    
    public static void UpdateAccountAddress(Account[] pNewAccount, map<Id, Account> pOldAccountMap){
        system.debug('\n\n**** Inside CSW_USPSModel.UpdateAccountAddress()');
        system.debug('\n\nCurrent User ID: ' + UserInfo.getUserId());
        if(pNewAccount.size() > 1){
            system.debug('Not valid record');
            return;//only works for ui creation or update
        }
        
        set<Id> AccountIdToUpdate = new set<Id>();
        for(Account a : pNewAccount){
            Boolean Address1Changed;
            Boolean Address2Changed;
            Boolean hasUSAddress;
            
            if(a.IsPersonAccount){
                Address1Changed = (pOldAccountMap == null) ? true : a.PersonMailingPostalCode != pOldAccountMap.get(a.Id).PersonMailingPostalCode ||
                                                                                            a.PersonMailingCountryCode != pOldAccountMap.get(a.Id).PersonMailingCountryCode;
                                                                                            
                Address2Changed = (pOldAccountMap == null) ? true : a.PersonOtherPostalCode != pOldAccountMap.get(a.Id).PersonOtherPostalCode ||
                                                                                            a.PersonOtherCountryCode != pOldAccountMap.get(a.Id).PersonOtherCountryCode;
                
                hasUSAddress = (a.PersonMailingCountryCode != null && a.PersonMailingCountryCode.toUpperCase() == 'US') || 
                                        (a.PersonOtherCountryCode != null && a.PersonOtherCountryCode.toUpperCase() == 'US');
            }else{
                Address1Changed = (pOldAccountMap == null) ? true : a.BillingPostalCode != pOldAccountMap.get(a.Id).BillingPostalCode ||
                                                                                            a.BillingCountryCode != pOldAccountMap.get(a.Id).BillingCountryCode;
                                                                                            
                Address2Changed = (pOldAccountMap == null) ? true : a.ShippingPostalCode != pOldAccountMap.get(a.Id).ShippingPostalCode ||
                                                                                            a.ShippingCountryCode != pOldAccountMap.get(a.Id).ShippingCountryCode;
                
                hasUSAddress = (a.BillingCountryCode != null && a.BillingCountryCode.toUpperCase() == 'US') || 
                                        (a.ShippingCountryCode != null && a.ShippingCountryCode.toUpperCase() == 'US');
            }
            
            system.debug('\n\nhasUSAddress? :' + hasUSAddress + '\n\n');
            
            if((Address1Changed || Address2Changed) && hasUSAddress){
                AccountIdToUpdate.add(a.Id);
            }
            
            if(AccountIdToUpdate.size() > 0){
                if(System.IsBatch() == false && System.isFuture() == false){  // JArvind - Added if condition for S-456699 - 2017.03 release - 1/6/17
                    invokeUSPSAccountAddressUpdate(AccountIdToUpdate);
                }
            }
        }
    }
    
    @future (callout=true)
    private static void invokeUSPSAccountAddressUpdate(set<Id> AccountIdSet){
        system.debug('\n\n**** Inside CSW_USPSModel.UpdateAccountAddress()');
        try{
            Account[] accountList = [SELECT IsPersonAccount, PersonMailingPostalCode, PersonOtherPostalCode,
                                                 BillingPostalCode, ShippingPostalCode, Id
                                                FROM Account WHERE Id IN :AccountIdSet];
                                                
            map<String, Account[]> postalToAccountList = new map<String, Account[]>();
            for(Account a : accountList){
                if(a.IsPersonAccount){
                    if(!postalToAccountList.containsKey(a.PersonMailingPostalCode)){
                        postalToAccountList.put(a.PersonMailingPostalCode, new Account[]{a});
                    }else{
                        postalToAccountList.get(a.PersonMailingPostalCode).add(a);
                    }
                    if(!postalToAccountList.containsKey(a.PersonOtherPostalCode)){
                        postalToAccountList.put(a.PersonOtherPostalCode, new Account[]{a});
                    }else{
                        postalToAccountList.get(a.PersonOtherPostalCode).add(a);
                    }
                }else{
                    if(!postalToAccountList.containsKey(a.BillingPostalCode)){
                        postalToAccountList.put(a.BillingPostalCode, new Account[]{a});
                    }else{
                        postalToAccountList.get(a.BillingPostalCode).add(a);
                    }
                    if(!postalToAccountList.containsKey(a.ShippingPostalCode)){
                        postalToAccountList.put(a.ShippingPostalCode, new Account[]{a});
                    }else{
                        postalToAccountList.get(a.ShippingPostalCode).add(a);
                    }
                }
            }
            
            Utility.IntegrationSetting setting = Utility.getIntegrationSetting('USPS Integration');
            
            if(setting == null || setting.USPSUserID == null){
                system.debug('\n\nInvalid USPS Integration setting.\n\nSettings:'+JSON.serializePretty(setting)+'\n\n\n');
                return;
            }
            
            CSW_USPSModel connection = new CSW_USPSModel(setting.USPSUserID, setting.Endpoint);
            //CSW_USPSModel connection = new CSW_USPSModel('562CLOUD2615', Utility.getWebServiceEnpoint('USPSAddressValidation'));
            connection.IsTest = false;
            for(String zip : postalToAccountList.keySet()){
                connection.addZip(zip);
            }
            CSW_USPSModel.Response result = connection.Send();
            
            map<Id, Account> PAAccount = new map<Id, Account>();
            map<Id, Account> BSAccount = new map<Id, Account>();
            
            if(result.Result == CSW_USPSModel.SUCCESS){
                for(Address addressResult : result.Addresses){
                    if(postalToAccountList.containsKey(addressResult.Zip5)){
                        for(Account a : postalToAccountList.get(addressResult.Zip5)){
                            if(a.IsPersonAccount){
                                if(a.PersonMailingPostalCode == addressResult.Zip5){
                                    a.PersonMailingCity = addressResult.CityFormatted;
                                    a.PersonMailingStateCode = toUpper(addressResult.State);
                                }
                                if(a.PersonOtherPostalCode == addressResult.Zip5){
                                    a.PersonOtherCity = addressResult.CityFormatted;
                                    a.PersonOtherStateCode = toUpper(addressResult.State);
                                }
                                if(!PAAccount.containsKey(a.Id)){
                                    PAAccount.put(a.Id, a);
                                }
                            }else{
                                if(a.BillingPostalCode == addressResult.Zip5){
                                    a.BillingCity = addressResult.CityFormatted;
                                    a.BillingStateCode = toUpper(addressResult.State);
                                }
                                if(a.ShippingPostalCode == addressResult.Zip5){
                                    a.ShippingCity = addressResult.CityFormatted;
                                    a.ShippingStateCode = toUpper(addressResult.State);
                                }
                                if(!BSAccount.containsKey(a.Id)){
                                    BSAccount.put(a.Id, a);
                                }
                            }
                        }
                    }
                }
                
                if(PAAccount.size() > 0){
                    update PAAccount.values();
                }
                if(BSAccount.size() > 0){
                    update BSAccount.values();
                }
            }else{
                system.debug('\n\nUSPS Result: ' + result.Result + '\nDescription:\n' + result.Message + '\n\n');
            }
        }catch(Exception e){
            throw BaseApplicationException.NewExceptionWithInnerException('invokeUSPSAccountAddressUpdate', 'Account address update using USPS throws an error.', e);
        }
    } 
    
    private static String toUpper(String pStr){
        return pStr == null ? null : pStr.toUpperCase();
    }
    
    private static String testResponse(){
        return '<CityStateLookupResponse>' +
                                '<ZipCode ID="0">' +
                                    '<Zip5>90210</Zip5>' +
                                    '<City>BEVERLY HILLS</City>' +
                                    '<State>CA</State>' +
                                    '<Number>111</Number>'+
                                    '<Error>sdfsfdsf</Error>'+
                                    '<Description>fdfdf</Description>'+
                                    '<Source>fdfdfdf</Source>'+
                                '</ZipCode>' +
                                '<ZipCode ID="1">' +
                                    '<Zip5>20770</Zip5>' +
                                    '<City>GREENBELT</City>' +
                                    '<State>MD</State>' +
                                '</ZipCode>' +
                            '</CityStateLookupResponse>';
    }
    
    public static void test(Boolean pIsTest){
        CSW_USPSModel connection = new CSW_USPSModel('562CLOUD2615', Utility.getWebServiceEnpoint('USPSAddressValidation'));
        connection.IsTest = pIsTest;
        connection.addZip('90210');
        connection.addZip('20770');
        CSW_USPSModel.Response result = connection.Send();
        
        String output = '\n\n';
        output += 'Address Validation Test\n';
        output += '\nResult: ' + result.Result;
        output += '\nResult: ' + result.Message;
        output += '\nAddresses: ';
        if(result.Result == SUCCESS){
            Integer c = 0;
            for(CSW_USPSModel.Address a : result.Addresses){
                if(a.ErrorNumber != null){
                    
                }else{
                    output += '\n  Address ' + c;
                    output += '\n    Zip ' + a.Zip5;
                    output += '\n    City ' + a.City;
                    output += '\n    State ' + a.State + '\n';
                }
            }
        }else{
            output += 'None';
        }
        output += '\n\n';
        
        system.debug(output);
    } 
}