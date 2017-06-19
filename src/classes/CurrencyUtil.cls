/****************************************************************************************
*Currency Conversion The code assumes the Corporate Currency is USD
*****************************************************************************************/
public class CurrencyUtil {
  
  //Store conversion rates, in a static Map to act as cache
  private static Map<String,Double> mpCurrencyConversionRate = new Map<String,Double>();
  private static String CORPORATE_ISOCODE = 'USD';
  
  
  //=====================================//
  //Normal No Args constructor
  //====================================//
  public CurrencyUtil() {
  }
  
  //If a lot of conversion needs to happen, pass in all the currency codes
  public CurrencyUtil(Set<String> setCurrencyISOCodes){
    queryAndLoadConversionRate(setCurrencyISOCodes);
  }
  
  
  //====================================================================//
  //A shortcut method that converts amount to USD from Source Currency
  //=====================================================================//
  public Decimal convertToUSD(String sourceISOCode,Decimal amount) {
    return convertCurrency(sourceISOCode,amount,CORPORATE_ISOCODE);     
  }
  
  
  //@sourceCurrency => Source currency containing the actual amount
  //@destinationCurrency => Destination Currency the target currency in which amount should be converted
  //@Amount => The Amount in Source Currency that needs to converted
  //===================================================================================//
  public Decimal convertCurrency(String sourceISOCode,Decimal amount,String destinationISOCode) {
    loadConversionRates(sourceISOCode,destinationISOCode);
    System.debug('===@@@mpCurrencyConversionRate==='+mpCurrencyConversionRate);
    //Convert the input amount to USD just by multiplying the conversion rate
    //eg 1 Dollar = 50 INR  
    System.debug('====@@@destinationISOCode==='+destinationISOCode + '==amount=='+amount); 
    if(sourceISOCode == CORPORATE_ISOCODE) {
      if(mpCurrencyConversionRate.containsKey(destinationISOCode) && amount != null) {
        
        return amount * mpCurrencyConversionRate.get(destinationISOCode);  
      }
    }
    
      //Convert the amount into USD
      Decimal computeAmount = 0;
      if(mpCurrencyConversionRate.containsKey(sourceISOCode) && amount != null){
       computeAmount = amount / mpCurrencyConversionRate.get(sourceISOCode);
      }  
      if(destinationISOCode != CORPORATE_ISOCODE) {
      //reconvert the USD to destination currency
      if(mpCurrencyConversionRate.containsKey(destinationISOCode)){
        computeAmount = computeAmount * mpCurrencyConversionRate.get(destinationISOCode);
      }
    }
    return computeAmount;
  }
 
  
  //================================================================//
  //Check if the already have the rates, if yes dont load again
  //================================================================//
  private void loadConversionRates(String currency1,String currency2) {
    Set<String> setCurrency = new Set<String>();
    if(!mpCurrencyConversionRate.containsKey(currency1) && currency1 != null) {
      setCurrency.add(currency1);
    }
  
    if(!mpCurrencyConversionRate.containsKey(currency2) && currency2 != null) {
      setCurrency.add(currency2);
    }
    if(setCurrency.size() == 0) return;
    
    queryAndLoadConversionRate(setCurrency);
  }
  
  //========================================================================//
  //Query Salesforce and load the latest conversion Rate
  //========================================================================//
  private void queryAndLoadConversionRate(Set<String> setCurrencyISOCode) {
    for(CurrencyType currencyType: [SELECT IsoCode,ConversionRate 
                                             FROM CurrencyType 
                                             WHERE IsoCode IN: setCurrencyISOCode and IsoCode != null and ConversionRate != null]){          
      mpCurrencyConversionRate.put(currencyType.IsoCode,currencyType.ConversionRate);        
    }
  }
  
}