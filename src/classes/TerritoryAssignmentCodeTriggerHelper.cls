public without sharing class TerritoryAssignmentCodeTriggerHelper {

  final String CLASSNAME = '\n\n**** TerritoryAssignmentCodeTriggerHelper .METHODNAME()';
  private Map<String, String> CountryToFormat = new Map<String, String>();
  private Map<String, String> CountryToTacRegex = new Map<String, String>();
  private Map<String, String> CountryToTacError = new Map<String, String>();
  private Map<String, String> CountryToFullRegex = new Map<String, String>();
  private Map<String, String> CountryToFullError = new Map<String, String>();
  private Map<String, String> CountryToClean = new Map<String, String>();
  private Map<String, String> AlphaToNum = new Map<String, String>{'A' => '00', 'B' => '01', 'C' => '02', 'D' => '03', 'E' => '04',
                                                                   'F' => '05', 'G' => '06', 'H' => '07', 'I' => '08', 'J' => '09',
                                                                   'K' => '10', 'L' => '11', 'M' => '12', 'N' => '13', 'O' => '14',
                                                                   'P' => '15', 'Q' => '16', 'R' => '17', 'S' => '18', 'T' => '19',
                                                                   'U' => '20', 'V' => '21', 'W' => '22', 'X' => '23', 'Y' => '24',
                                                                   'Z' => '25'};

/*
** @author : Appirio (Jonathan Freese)
** @date : 04/21/16
** @description : static method that instantiates a new instance of the class
** @parameters : nothing
** @returns : a new instance of the TerritoryAssignmentCodeTriggerHelper class
*/
  public static TerritoryAssignmentCodeTriggerHelper NewTriggerHelper(){

      TerritoryAssignmentCodeTriggerHelper newHelper = new TerritoryAssignmentCodeTriggerHelper();
      return newHelper;
  }

/*
** @author : Appirio (Jonathan Freese)
** @date : 04/21/16
** @description : this method is the class constructor
** @parameters : nothing
** @returns : a new instance of the TerritoryAssignmentCodeTriggerHelper class
*/
  private TerritoryAssignmentCodeTriggerHelper(){

      final string METHODNAME = CLASSNAME.replace('METHODNAME','TerritoryAssignmentCodeTriggerHelper');
      system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

      for(Zipcode_Configuration__c config : Zipcode_Configuration__c.getAll().values()){
          CountryToFormat.put(config.Name.toUppercase(), config.AlphaNumeric_Format__c);
          CountryToTacRegex.put(config.Name.toUppercase(), config.TAC_Regex__c);
          CountryToTacError.put(config.Name.toUppercase(), config.TAC_Error_Message__c);
          CountryToFullRegex.put(config.Name.toUppercase(), config.Full_Regex__c);
          CountryToFullError.put(config.Name.toUppercase(), config.Full_Error_Message__c);
          CountryToClean.put(config.Name.toUppercase(), config.Cleaning_Regex__c);
      }
  }


/*
** @author : Appirio (Jonathan Freese)
** @date : 04/21/16
** @description : Validate the Posting Zipcodes and populate their numeric equivalents
** @returns : nothing
*/
    public void process_Zipcodes(TerritoryAssignmentCode__c[] pTAC){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','process_Zipcodes');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        List<String> zipcodes = new List<String>{'PostingZipCodeStart__c','PostingZipCodeEnd__c'};
        List<String> zipnums  = new List<String>{'Zip_Code_Start_Number__c','Zip_Code_End_Number__c'};
        List<Integer> nums = new List<Integer>{0,0};

        try{
          for(TerritoryAssignmentCode__c tac : pTAC){
            if (tac.AccountCountry__c != null){
              //for(String thisZip : zipcodes){
              for(Integer i = 0; i < 2; i++){
                if (tac.get(zipcodes[i]) != null){
                  String zipvalue = String.valueOf(tac.get(zipcodes[i]));
                  String result = isValid_Zipcode(zipvalue, tac.AccountCountry__c, true, true);
                  //String result = 'isValid';

                  if (result == 'isValid'){
                    //system.debug('Success!!');
                    String result2 = ZipToNumber(zipValue, tac.AccountCountry__c);
                    if(result2.isNumeric()){
                      nums[i] = Integer.valueOf(result2);
                      tac.put(zipnums[i], nums[i]);
                    }
                    else{
                      system.debug('ZipToNumber failed with ' + result2);
                      tac.put(zipnums[i], 0); //erase the numeric zipcode
                      tac.addError(result2);
                      return;
                    }
                  }
                  else{
                    system.debug('isValid_Zipcode failed with ' + result);
                    tac.addError(result);
                    return;
                  }
                  system.debug('Posting zipcode: ' + zipcodes[i] + ' = ' + zipvalue + ', ' + zipnums[i] + ' = ' + tac.get(zipnums[i]));
                }
                if (i == 1 && nums[0] > nums[1]){
                  tac.addError ('Error: Ending zipcode must be greater than or equal to the starting zipcode');
                }
              }
            }
          }
        }
        catch(Exception e){
            ExceptionLog.add('Exception', 'TerritoryAssignmentCodeTriggerHelper', 'validate_Zipcodes', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to process zipcodes' ,e);
        }
    }

/*
** @author : Appirio (Jonathan Freese)
** @date : 04/21/16
** @description : Validate a zipcode format
** @returns : result string
*/
    public String isValid_Zipcode(String zipcode, String country, Boolean isTAC, Boolean failOnNoConfig){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','isValid_Zipcode');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        /*This method is used to validate a zipcode against a regular expression.

          When validating a start/end zipcode for Territory Assignment Codes (TACs), it may be
          desirable to allow partial zipcodes, as for Canada, which allows A1A 1A1 or just A1A.

          Therefore, two sets of regex and accompanying error messages were set up, so that when this method
          is used for TAC validation it will allow A1A but when it is used for full zipcodes it requires A1A 1A1.

          Also, when validating TAC zipcodes failOnNoConfig is set to true so a formal error message is returned.
          If validating a full zipcode it returns a quiet error message which can be caught to handle the
          validation as not applicable.*/

        String result = '';
        String regex = '';
        String error = '';

        try{
          if (CountryToTacRegex != null && CountryToTacRegex.containskey(country.toUppercase())){
            if (isTAC){
              regex = String.valueof(CountryToTacRegex.get(country.toUppercase()));
              error = String.valueof(CountryToTacError.get(country.toUppercase()));
            }
            else {
              regex = String.valueof(CountryToFullRegex.get(country.toUppercase()));
              error = String.valueof(CountryToFullError.get(country.toUppercase()));
            }

            if(Pattern.matches(regex, zipcode)){
              result = 'isValid';
            }
            else{
              result = error;
            }
          }
          else if(failOnNoConfig) {
            result = 'Error: Please see your administrator.  No custom Setting Zipcode_Configuration__c record found for Posting Zip Code Country: ' + country;
          }
          else {
            result = 'No Zipcode_Configuration__c record found';
          }
          system.debug('Result of isValid_Zipcode(' + zipcode + ',' + country + ',' + isTAC + ',' + failOnNoConfig + '): regex = ' + regex + ', result = ' + result);
          return result;
        }
        catch(Exception e){
            ExceptionLog.add('Exception', 'TerritoryAssignmentCodeTriggerHelper', 'isValid_Zipcode', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to validate a specified zipcode' ,e);
        }
    }

/*
** @author : Appirio (Jonathan Freese)
** @date : 04/21/16
** @description : Determine the numeric "equivalent" of a given zipcode
** @returns : numeric string
*/
    public String ZipToNumber(String zipcode, String country){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','ZipToNumber');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        String result='';
        String alpha = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        String num  = '0123456789';

        try{
          if (CountryToFormat != null && CountryToFormat.containskey(country.toUppercase())){
            if(CountryToFormat.get(country.toUppercase()).replaceAll('[dA]', '') != ''){
              result = 'Error: Please see your administrator.  Invalid format ' + CountryToFormat.get(country.toUppercase());
              return result;
            }
            List<String> format = CountryToFormat.get(country.toUppercase()).split('');

            if(zipcode != ''){
              String clean = zipcode.replaceAll(CountryToClean.get(country.toUppercase()), '');
              List<String> cleaned = clean.split('');

              for (Integer i = 0; i < format.size(); i++) {
                if (i < cleaned.size()){
                  if(format[i] == 'd'){
                    if (!num.contains(cleaned[i])){
                      result = 'Error: Invalid character # ' + (i+1) + ' in cleaned zipcode ' + clean + ', format = ' + CountryToFormat.get(country.toUppercase());
                      return result;
                    }
                    else {
                      result += cleaned[i];
                    }
                  }
                  else{
                    if (!alpha.contains(cleaned[i])){
                      result = 'Error: Invalid character # ' + (i+1) + ' in cleaned zipcode ' + clean + ', format = ' + CountryToFormat.get(country.toUppercase());
                      return result;
                    }
                    else {
                      result += AlphaToNum.get(cleaned[i]);
                    }
                  }
                }
                else{
                  if(format[i] == 'd'){
                      result += '0';
                  }
                  else{
                      result += '00';
                  }
                }
              }
              //System.debug('Zipcode = '+ zipcode + ' ZipToNumber Result = ' + result);
            }
            else{
              result = 'Error: No zipcode provided';
            }
          }
          else{
            result = 'No Zipcode_Configuration__c record found';
          }
          system.debug('Result of ZipToNumber(' + zipcode + ',' + country + ') = ' + result);
          return result;
        }
        catch(Exception e){
            ExceptionLog.add('Exception', 'TerritoryAssignmentCodeTriggerHelper', 'ZipToNumber', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to get numeric equivalent of a zipcode' ,e);
        }
    }


}