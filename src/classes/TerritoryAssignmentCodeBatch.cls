/**===========================================================================
 * J Freese, Appirio, Inc
 * Name: TerritoryAssignmentCodeBatch
 * Description: Batch process to set the Posting Zip Country based upon Posting Address Zip codes
 * There are many of them on Prod and we need to use Salesforce regex to determine the probable country,
 * thus a batch class
 * 4/25/16
 ============================================================================*/
global class TerritoryAssignmentCodeBatch implements Database.Batchable<sObject>, Database.Stateful{

    global String updateErrors = '';
    global Integer batch_ct = 0;
    global Integer record_ct = 0;
    global Integer scopeSize = 0;
    global Integer fixed_ct = 0;
    global Map<String, String> CountryToFullRegex = new Map<String, String>();
    global List<String> countries = new List<String>();
    global String org = UserInfo.getOrganizationId();
    global Set<String> devQAOrg = new Set<String>{'00Dq0000000BLIlEAO','00D17000000AHfBEAW'}; //Dev & QA org IDs

    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
        //Set <Id> Ids = new Set<Id>{'a4mq00000004NHV','a4mq00000004NHz'};
        String query = 'SELECT Id, AccountCountry__c, PostingZipCodeStart__c, PostingZipCodeEnd__c, ' +
                       'Zip_Code_Start_Number__c, Zip_Code_End_Number__c, ' +
                       'SalesChannel__c, AccountGroup__c, Segment__c ' +
                       'FROM TerritoryAssignmentCode__c WHERE ' +
                       '(PostingZipCodeStart__c != null AND PostingZipCodeEnd__c != null) AND ' +
                       '(Zip_Code_Start_Number__c = null OR Zip_Code_End_Number__c = null OR ' +
                       ' AccountCountry__c = null OR SalesChannel__c = null OR ' +
                       ' AccountGroup__c = null OR Segment__c = null) '
                       //+ 'AND ID in: IDs'
                       //+ 'Limit 10'
                       ;
        system.debug('TerritoryAssignmentCodeBatch :: START :: query ' + query);

        for(Zipcode_Configuration__c config : Zipcode_Configuration__c.getAll().values()){
            countries.add(config.Name);
            CountryToFullRegex.put(config.Name, config.Full_Regex__c);
        }

        return Database.getQueryLocator(query);
        //return null;
    }

    // Execute Method
    global void execute(Database.BatchableContext BC, List<TerritoryAssignmentCode__c> scope){
        batch_ct++;
        record_ct += scope.size();
        if (scopeSize==0){
            scopeSize = scope.size();
        }

        List<TerritoryAssignmentCode__c> tobeUpdated = new List<TerritoryAssignmentCode__c>();
        for (TerritoryAssignmentCode__c tac : scope){
            for (String c : countries){
                if(Pattern.matches(CountryToFullRegex.get(c), tac.PostingZipCodeStart__c) &&
                   Pattern.matches(CountryToFullRegex.get(c), tac.PostingZipCodeEnd__c)){
                    //system.debug('tac=' + tac.id + ' set country to ' + c);
                    if (tac.AccountCountry__c != null && tac.AccountCountry__c != c){
                        String msg = 'Overwriting AccountCountry__c=' + tac.AccountCountry__c + ' with ' + c +
                                     ' for TAC ID ' + tac.Id +
                                     ', PostingZipCodeStart__c = ' + tac.PostingZipCodeStart__c +
                                     ', PostingZipCodeEnd__c = ' + tac.PostingZipCodeEnd__c + '\n\n';
                        updateErrors += msg;
                    }
                    tac.AccountCountry__c = c;

                    if (devQAOrg.contains(org)){ //populate missing required fields if on Dev or QA
                        if (tac.SalesChannel__c == null){tac.SalesChannel__c = 'Fieldsales';}
                        if (tac.AccountGroup__c == null){tac.AccountGroup__c = 'Branch';}
                        if (tac.Segment__c == null)     {tac.Segment__c      = 'Commercial';}
                    }
                    tobeUpdated.add(tac);
                }
            }
        }
       if(!tobeUpdated.isEmpty()){
            fixed_ct += tobeUpdated.size();
            updateErrors += ArchiveHelper.doUpdate('TerritoryAssignmentCode__c', tobeUpdated);
        }
    }

    // Finish Method
    global void finish(Database.BatchableContext BC){
        String objectName = 'TerritoryAssignmentCode__c';
        String summary = '';
        summary += record_ct + ' ' + objectName + ' records were processed ';
        summary += 'in ' + batch_ct + ' batches of up to ' + scopeSize + ' records each.<BR><BR>';
        summary += 'The following counts of records were flagged for territory assignment code:<BR>';
        summary += fixed_ct + ' ' + objectName + ' record(s) were fixed<BR>';
        SetSendToEmailFlag.fromTerritory = true;
        ArchiveHelper.processType = 'updating';
        ArchiveHelper.subjectText = 'Territory Assignment Code of';
        ArchiveHelper.sendEmail(objectName, summary, updateErrors);
    }
}