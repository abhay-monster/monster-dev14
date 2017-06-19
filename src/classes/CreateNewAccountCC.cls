/**
 * @author Cloud Sherpas Inc.
 * @date 05/09/2014
 * @description This page overrides the URL upon clicking the Create New Account button in Case. 
 */
public class CreateNewAccountCC {
    final String CLASSNAME = '\n\n**** CreateNewAccountCC .METHODNAME()';
    public CreateNewAccountCC(ApexPages.StandardController controller){
        
    }
    public PageReference executeMethod(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','executeMethod');
        Logger.push(METHODNAME, 'Create New Account Page');
        PageReference accountPg = null;
        try{
            String idOfCase =  ApexPages.currentPage().getParameters().get('caseId');
            if(idOfCase != null){
                Case cs = [SELECT Id, 
                                  AccountId,
                                  AccountPhone__c,
                                  URL__c,
                                  AccountGroup__c, 
                                  BillingCity__c, 
                                  BillingCountry__c, 
                                  BillingStateProvince__c, 
                                  BillingStreet__c, 
                                  BillingZipPostalCode__c,
                                  Organization__c,
                                  SalesChannel__c,
                                  Account_Name__c,
                                  AgencyFlag__c,
                                  Description,
                                  CurrencyIsoCode,
                                  PhoneDoNotCall__c,
                                  PhoneExtension__c,
                                  FirstName__c,
                                  LastName__c,
                                  SICCode__c,
                                  SICDescription__c,
                                  RegistrationNumber__c,
                                  PrimarySalesRepID__c,
                                  AccountSource__c,
                                  Title__c,
                                  VATNumber_c__c,
                                  CreatedById,
                                  Company_Type__c,
                                  Employees__c                                                         
                FROM Case
                WHERE Id =: idOfCase];
                User usr = [SELECT Id, Name FROM USER WHERE Id =: cs.PrimarySalesRepID__c];
                //User usrCaseCreator = [SELECT Organisation__c FROM USER WHERE Id =: cs.CreatedById];
                CountryCode__c cc = CountryCode__c.getValues(cs.BillingCountry__c);
                String code = '', city ='', country='', state='',zip='', street='', currencys ='', 
                       Description, salesChannel= '', AccountPhone = '', PhoneExtension = '', regNum ='', vatNum ='', 
                       urlString ='', SICcode ='', accountids='', primarySaleRep ='', countryCD = '', codeST ='', companyType ='',
                       AccountGroup ='';
                Boolean AgencyFlag = false, PhoneDoNotCall = false;
                Integer employees = 0;
                
                if(cs.BillingCountry__c == 'United States'){
                    UnitedStatesCode__c usc = UnitedStatesCode__c.getValues(cs.BillingStateProvince__c);
                    code = cs.BillingStateProvince__c; //usc.StateCode__c; 
                }
                    
                
                            
                //set values to appropriate fields and avoid null
                /*if(usr.Name != null){
                    primarySaleRep  = usr.Name;
                }*/
                if(cs.BillingStateProvince__c != null){
                    codeST = cs.BillingStateProvince__c;
                }
                if(cs.BillingCountry__c != null){
                    country = cs.BillingCountry__c;
                }
                if(cs.Account_Name__c!= null){
                    accountids = cs.Account_Name__c;
                }
                if(cs.BillingCity__c != null){
                    city = cs.BillingCity__c;
                }
                if(cc.Country_Code__c != null){
                    countryCD = cc.Country_Code__c ;
                }
                if(cs.BillingZipPostalCode__c!= null){
                    zip= cs.BillingZipPostalCode__c;
                }
                if(cs.BillingStreet__c!= null){
                    street= cs.BillingStreet__c;
                }
                if(cs.CurrencyIsoCode != null){
                    currencys = cs.CurrencyIsoCode ;
                }
                if(cs.Description != null){
                    Description= cs.Description ;
                }
                if(cs.SalesChannel__c!= null){
                    salesChannel= cs.SalesChannel__c;
                }
                if(cs.RegistrationNumber__c != null){
                    regNum = cs.RegistrationNumber__c ;
                }
                if(cs.VATNumber_c__c != null){
                    vatNum = cs.VATNumber_c__c ;
                }
                if(cs.URL__c  != null){
                    urlString = cs.URL__c ;
                }
                if(cs.SICCode__c!= null){
                    SICcode = cs.SICCode__c;
                }
                if(cs.AccountPhone__c != null){
                    AccountPhone = cs.AccountPhone__c;
                }
                if(cs.PhoneExtension__c != null){
                    PhoneExtension = cs.PhoneExtension__c;
                }
                if(cs.Company_Type__c != null){
                    companyType = cs.Company_type__c;
                } 
                if(cs.AgencyFlag__c != null){
                    AgencyFlag = cs.AgencyFlag__c;
                }  
                if(cs.AccountGroup__c != null){
                    AccountGroup = cs.AccountGroup__c;
                }
                if(cs.PhoneDoNotCall__c != null){
                    PhoneDoNotCall = cs.PhoneDoNotCall__c;
                }                     
                if(cs.Employees__c != null){
                    employees = cs.Employees__c.intValue();
                }
                cs.Status = 'Closed';
                cs.SubStatus__c = 'Resolved';
                //Creation of Account
                
                Account newAccount = new Account();
                newAccount.Name = accountids;
                newAccount.OwnerId = usr.Id;
                newAccount.Phone = AccountPhone;
                newAccount.PhoneExtension__c = PhoneExtension;
                newAccount.Organization__c = cs.Organization__c;
                newAccount.CurrencyIsoCode = currencys;
                newAccount.ShippingCity = city;
                newAccount.ShippingCountry = country;
                newAccount.ShippingCountryCode = countryCD;
                newAccount.ShippingPostalCode = zip;
                newAccount.ShippingState = code;
               // newAccount.ShippingStateCode = code;
                newAccount.ShippingStreet = street;
                newAccount.BillingCity = city;
                newAccount.BillingCountry = country ;
                newAccount.BillingCountryCode = countryCD;
                newAccount.BillingPostalCode = zip;
                newAccount.BillingState = code;
                //newAccount.BillingStateCode = code;
                newAccount.BillingStreet = street;
                newAccount.RegistrationNumber__c = regNum;
                newAccount.VATNumber__c = vatNum;
                newAccount.Sic = SICcode;
                newAccount.CompanyType__c = companyType;
                newAccount.AgencyFlag__c = AgencyFlag;
                newAccount.SalesChannel__c = salesChannel;
                newAccount.AccountGroup__c = AccountGroup;
                newAccount.PhoneDoNotCall__c = PhoneDoNotCall;
                newAccount.NumberOfEmployees = employees;
                newAccount.Website = urlString;
                newAccount.Lead_Account_Status__c = 'Inactive';
                newAccount.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Account', 'Business Accounts');
           
                if((country != null && city!= null && Street != null && zip != null) &&(accountids != null || currencys!= null)){
                    //Creates a new Account
                     insert newAccount;
                     accountPg = new ApexPages.StandardController(newAccount).view();
                        
                      //reference the newly created account to the current case
                      cs.AccountId = newAccount.Id;
                      update cs;   
                   
                }
            }else{     
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.fatal, System.Label.NoCaseInfo));
             }
        }catch(Exception e){
            Logger.debugException(e, null);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.fatal, System.Label.ContactAdministrator + e));
        }
        Logger.pop();
        return accountPg;
    }
}