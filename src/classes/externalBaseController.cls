public with sharing class externalBaseController {
 
 public string brand {get; set;}
 public string lang{get; set;}
 public Map<String,String> tabs{get; set;}
 Public Id brandId;

public externalBaseController (ApexPages.StandardController controller){
    brand = ApexPages.currentPage().getParameters().get('Brand');
    lang= ApexPages.currentPage().getParameters().get('Lang');
    List<Brand__c> brandList = new List<Brand__c>();
   // List<String> tabs = new List<String>();
   // String temp 
    List<Brand__c> ibrandList = new List<Brand__c>([Select Id, Name, Tabs__c, Language__c From Brand__c Where Name =:brand]);
    
    tabs = new Map<String,String>();
    if(ibrandList.size() >1){
        for(Brand__c brandFirst : ibrandList){
            if(brandFirst.Language__c == lang){
                brandList.add(brandFirst);
                for(String s :brandFirst.Tabs__c.split(';')){
                  tabs.put(s,s);
                }
            }
            brandId  = brandFirst.id;
        }
    }
    else{
    brandList = ibrandList;
    for(Brand__c brandFirst : brandList){
        for(String s :brandFirst.Tabs__c.split(';')){
          tabs.put(s,s);
          brandId  = brandFirst.id;
        }
    }
    }
    
    
    
    system.debug('Check ************************' + tabs);
    
}

public void contactUs(){

List<Contact_Us_Options__c> contactUsLst = new List<Contact_Us_Options__c>();

Contact_Us_Options__c contactingOptions ;
//brandId = 'a6pq00000008Oax';
system.debug('***brandId***' +brandId);
if(brandId!=null){
    wrapperList = new list<contactWrapper>();
    contactUsLst = [SELECT Id,Brand__c,Display_Twitter_Handle__c,Display_Text_Chat_Link__c,Display_Phone_Number__c,Display_Hours_of_Operation__c,Contact_Us_Twitter_Handle__c,Contact_Us_Text_Chat_Link__c,Contact_Us_Phone_Number__c,Contact_Us_Hours_of_Operation__c
    FROM Contact_Us_Options__c WHERE Brand__c =: brandId AND Active__c = True];
    }
    
    if(contactUsLst.size()>0){
       contactingOptions = contactUsLst.get(0);
       
        if(contactingOptions.Display_Twitter_Handle__c){
            string handle = (string)contactingOptions.Contact_Us_Twitter_Handle__c ;
            wrapperList.add(new contactWrapper('Twitter Handle', handle));
        }
        
        if(contactingOptions.Display_Text_Chat_Link__c){
            
            string textchatLink = (string)contactingOptions.Contact_Us_Text_Chat_Link__c ;
            wrapperList.add(new contactWrapper('Text chat Link', textchatLink));
        }   
        
        if(contactingOptions.Display_Phone_Number__c){
            
            string phone = (string)contactingOptions.Contact_Us_Phone_Number__c ;
            wrapperList.add(new contactWrapper('Contact Phone', phone));
        }
        
        if(contactingOptions.Display_Hours_of_Operation__c){
            
            string hoursOfOperation = (string)contactingOptions.Contact_Us_Hours_of_Operation__c ;
            wrapperList.add(new contactWrapper('Hours of operation', hoursOfOperation));
        }
            
    }
}
public list<contactWrapper> wrapperList {get; set;}
public class contactWrapper{
    public string key {get; set;}
    public string value {get; set;}
    public contactWrapper(string mapKey, string mapValue){
        this.key = mapKey;
        this.value = mapValue;
    }
}



}