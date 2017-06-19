public with sharing class ProductTriggerHelper {
    final String CLASSNAME = '\n\n**** ProductConfigTriggerHelper.METHODNAME()';
/*
** @author : Cloud Sherpas Inc.
** @date : 11/18/2014
** @description : static method that instantiates a new instance of the class & sets the user's profile name member variable
** @paramaters : a string - the profile name for the current user
** @returns : a new instance of the ProductConfigTriggerHelper class
*/
    public static ProductTriggerHelper NewTriggerHelper(){
        
        ProductTriggerHelper newHelper = new ProductTriggerHelper();
        return newHelper;
    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 11/18/2014
** @description : this method is the class constructor
** @paramaters : String user profile name
** @returns : nothing
*/
    private ProductTriggerHelper(){  
        final string METHODNAME = CLASSNAME.replace('METHODNAME','ProductConfigTriggerHelper');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
    }
    
/*
** @author : Clud Sherpas, Inc.
** @date : 11/18/2014
** @description : store Eligible_Selling_Country__c multi select picklist field to Eligible_Selling_Country_New__c in coma saperated format.
** @paramaters : list of product2 Ids records
** @returns : nothing 
** @Story : 2480
**/
    public void Sellingcountry_Expand(Product2[] pNewProduct){
        system.debug(LoggingLevel.INFO, 'Inside Sellingcountry_Expand');
        
        for(Product2 eachProdConfig : pNewProduct){
            
              if(eachProdConfig.Eligible_Selling_Country__c != null){
                  String Eligible_Selling_Country_New;
                  String Eligible_Selling_Country_New2 ;
                  integer icountryLength = 0;
                  for( String eachsellingcountry : eachProdConfig.Eligible_Selling_Country__c.split(';')){
                      If(icountryLength + eachsellingcountry.length() <= 255)
                      {
                      Eligible_Selling_Country_New =  Eligible_Selling_Country_New == null? eachsellingcountry : Eligible_Selling_Country_New +',' + eachsellingcountry;
                       icountryLength = Eligible_Selling_Country_New.length();
                      }
                      else
                      {
                          Eligible_Selling_Country_New2 =  Eligible_Selling_Country_New2 == null? eachsellingcountry : Eligible_Selling_Country_New2 +',' + eachsellingcountry;
                      }
                  }
                  eachProdConfig.Eligible_Selling_Country_New__c = Eligible_Selling_Country_New;
                  eachProdConfig.Eligible_Selling_Country_New2__c = Eligible_Selling_Country_New2; 
              }else if(eachProdConfig.Eligible_Selling_Country__c == null && eachProdConfig.Eligible_Selling_Country_New__c != null){
                        eachProdConfig.Eligible_Selling_Country_New__c = null;
              }
              
               if(eachProdConfig.Pricing_Channel__c != null){
                  String Quote_Pricing_Channel;
                  for( String eachpricingchannel : eachProdConfig.Pricing_Channel__c.split(';')){
                      Quote_Pricing_Channel =  Quote_Pricing_Channel == null ? eachpricingchannel : Quote_Pricing_Channel +',' + eachpricingchannel ;
                  }
                  eachProdConfig.Quote_Pricing_Channel__c = Quote_Pricing_Channel;
              }else if(eachProdConfig.Pricing_Channel__c  == null && eachProdConfig.Quote_Pricing_Channel__c != null){
                        eachProdConfig.Quote_Pricing_Channel__c = null;
              }
        }
    }
    
    public void populateOrderQuotaType(Product2[] pNewProduct){
        system.debug(LoggingLevel.INFO, 'Inside Sellingcountry_Expand');
        
        List<Order_Line_Item__c> listOLI = new List<Order_Line_Item__c>();
        Map<Id,Product2> productmap = new Map<Id,Product2>();
        
        For(Product2 proFirst : [Select Id, Product_Type__c from Product2 Where Id IN :pNewProduct]){
            productmap.put(proFirst.Id,proFirst);
        }
        
        For(Order_Line_Item__c oli : [Select Id, Quota_Type__c,Order_Line_Item__c.Product__c from Order_Line_Item__c where Product__c IN :pNewProduct]){
                if(oli.Quota_Type__c == null && (productmap.containsKey(oli.Product__c) || productmap.get(oli.Product__c).Product_Type__c != null)){
                
                    oli.Quota_Type__c = productmap.get(oli.Product__c).Product_Type__c;
                    if(productmap.get(oli.Product__c).Product_Type__c == 'Premium')
                        oli.Quota_Type__c = 'Strategic' ;
                    }
                        
                    
                 listOLI.add(oli);
            }
            
         if(!listOLI.isEmpty()){
             update listOLI;
         }   
        
        }
    
    }