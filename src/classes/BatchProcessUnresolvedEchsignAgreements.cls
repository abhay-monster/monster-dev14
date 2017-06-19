/*
** @author Appirio J Freese S-473744
* @date   4/12/2017
* @description batch class to process unresolved Adobe Echosign agreements
*/

global class BatchProcessUnresolvedEchsignAgreements implements Schedulable
{

    global void execute(SchedulableContext scMain) {
        BatchProcessUnresolvedEchsignAgreements__c settings = BatchProcessUnresolvedEchsignAgreements__c.getValues('Defaults');
        String process = '';
        String objectName = 'Fix Unresolved Echosign Agreements:';
        String noAgs = 'No Agreements were found to process';
        String summary = noAgs;
        String errors = '';
        String thisError = '';
        String dbg = '';
        String dme = '';
        List<String> resolved = new List<String>{'Completed','Failed'};
        Boolean sendEmail = false;
        List<echosign_dev1__SIGN_Agreement__c> agreementsToUpdate = new List<echosign_dev1__SIGN_Agreement__c>();

        DateTime thisRun = dateTime.now();
        Integer minBetween = Integer.ValueOf(settings.minutesBetweenRuns__c);
        Integer numInt = Integer.ValueOf(settings.numIntervalsToProcess__c);

        DateTime startTime = thisRun.addMinutes(minBetween * (numInt + 1) * -1);
        DAtetime endTime = thisRun.addMinutes(minBetween * -1);
        dbg = 'minutesBetweenRuns='+settings.minutesBetweenRuns__c;
        dbg += ', numIntervalsToProcess='+settings.numIntervalsToProcess__c;
        dbg += ', thisRun='+thisRun+', startTime='+startTime+', endTime='+endTime;
        system.debug(dbg);

        if(!settings.isActive__c){
            system.debug('Not processing agreements as settings.isActive__c='+settings.isActive__c);
        }else{
            List<echosign_dev1__SIGN_Agreement__c> ags = [SELECT Id,
                                                          echosign_dev1__Status__c,
                                                          echosign_dev1__Data_Mapping_Result__c,
                                                          echosign_dev1__Data_Mapping_Error__c,
                                                          echosign_dev1__Opportunity__c,
                                                          echosign_dev1__Opportunity__r.orderCreated__c,
                                                          Apttus_QPESign__Apttus_Proposal__r.name,
                                                          echosign_dev1__DateSigned__c
                                                          FROM echosign_dev1__SIGN_Agreement__c
                                                          WHERE echosign_dev1__Status__c = 'Signed' AND
                                                          echosign_dev1__Data_Mapping_Result__c NOT IN: resolved AND
                                                          echosign_dev1__DateSigned__c >= : startTime AND
                                                          echosign_dev1__DateSigned__c <= : endTime ];

            for (echosign_dev1__SIGN_Agreement__c ag : ags){
                thisError = '';

                if (summary == noAgs) summary = 'The following '+ags.size()+' agreement(s) were found to process:<br><br>';
                dbg = '('+ag.Apttus_QPESign__Apttus_Proposal__r.name+') ';
                dbg += 'Agreement ID='+ag.Id+', Status='+ag.echosign_dev1__Status__c;
                dbg += ', Data_Mapping_Result='+ag.echosign_dev1__Data_Mapping_Result__c;
                dbg += ', echosign_dev1__Opportunity__c='+ag.echosign_dev1__Opportunity__c;
                if (ag.echosign_dev1__Opportunity__c != null){
                    dbg += ', echosign_dev1__Opportunity__r.OrderCreated__c='+ag.echosign_dev1__Opportunity__r.orderCreated__c;
                }
                dbg += '<br>echosign_dev1__Data_Mapping_Error__c='+ag.echosign_dev1__Data_Mapping_Error__c+'<br>';
                dbg += 'DateSigned__c='+ag.echosign_dev1__DateSigned__c;
                dbg += ', Current time (GMT)='+thisRun+'<br><br>';
                summary += dbg;
                system.debug(dbg);

                if(ag.echosign_dev1__Opportunity__c == null){
                    thisError += 'ERROR: ('+ag.Apttus_QPESign__Apttus_Proposal__r.name+') Agreement ID '+ag.Id+' has no opportunity.<br>';
                }
                else if (ag.echosign_dev1__Opportunity__r.OrderCreated__c == true){
                    thisError += 'ERROR: ('+ag.Apttus_QPESign__Apttus_Proposal__r.name+') Agreement ID '+ag.Id+' - Opportunity already has an order even though agreement is unresolved.<br>';
                }

                if (ag.echosign_dev1__Data_Mapping_Error__c != null){
                    thisError += 'ERROR: ('+ag.Apttus_QPESign__Apttus_Proposal__r.name+') Agreement ID '+ag.Id+'  - Data Mapping Error is populated even though agreement is unresolved.<br>';
                }

                if (ag.echosign_dev1__Data_Mapping_Result__c == 'Processing'){
                    thisError += 'ERROR: ('+ag.Apttus_QPESign__Apttus_Proposal__r.name+') Agreement ID '+ag.Id+' - Data Mapping Result has been Processing for at least '+settings.minutesBetweenRuns__c+' minutes.<br>';
                }
                else if (ag.echosign_dev1__Data_Mapping_Result__c != null){
                    thisError += 'ERROR: ('+ag.Apttus_QPESign__Apttus_Proposal__r.name+') Agreement ID '+ag.Id+' - Unknown Data Mapping Result: '+ag.echosign_dev1__Data_Mapping_Result__c+'<br>';
                }

                if (thisError != ''){
                    system.debug('Got error(s): '+thisError);
                    if (errors == '') errors = 'Note: Agreements with errors were ignored & not updated (no order created).<br>';
                    errors += thisError;
                }else{
                    system.debug('Ready to generate Order');
                    ag.echosign_dev1__Data_Mapping_Result__c='Failed';
                    dme = 'Agreement resolved by BatchProcessUnresolvedEchsignAgreements.cls '+thisRun;
                    ag.echosign_dev1__Data_Mapping_Error__c=dme;
                    agreementsToUpdate.add(ag);
                }
            }
            summary += 'Agreement(s) ';
            if (errors != '') summary += '(which had no errors) ';
            summary += 'were updated to set the Data Mapping Result to "Failed" and <br>the Data Mapping Error to "'+dme+'"<br>';
            summary += 'which results in a callout to APTS_echoSign_IQueue and creation of the order.';


            if(agreementsToUpdate.size() > 0){
                system.debug('Submitting '+agreementsToUpdate.size()+' opp(s) for order generation.');

                thisError='';
                List<Database.SaveResult> updateResults;
                updateResults = Database.update(agreementsToUpdate, false);
                for(Integer i=0;i<updateResults.size();i++){
                    if (!updateResults.get(i).isSuccess()){
                        // DML operation failed
                        Database.Error error = updateResults.get(i).getErrors().get(0);
                        String failedDML = error.getMessage();
                        system.debug('^^^ ERROR: '+failedDML);
                        thisError += 'ERROR: ('+agreementsToUpdate.get(i).Apttus_QPESign__Apttus_Proposal__r.name+')';
                        thisError += ' Agreement ID '+agreementsToUpdate.get(i).id+': '+failedDML+'<BR>';
                    }
                }
                /*try {
                    update agreementsToUpdate;
                } catch (System.DmlException e) {
                    for (Integer i = 0; i < e.getNumDml(); i++) {
                        thisError += 'ERROR: Agreement '+e.getDmlId(i)+' - '+e.getDmlMessage(i);
                        if (e.getDmlType(i) != null) thisError += ', Status Code: '+e.getDmlType(i);
                        thisError += '<br>';
                    }
                }*/
                if (thisError != ''){
                    if (errors == ''){
                        errors = 'Note: All agreement(s) were updated, resulting in the following DML error(s):<br>';
                    }else{
                        errors += '<br><br>Note: The agreement(s) which were updated resulted in the following DML error(s):<br>';
                    }
                    errors += thisError;
                    system.debug('DML Error(s): '+thisError);
                }
            }

            if (settings.sendEmailAlways__c == true) sendEmail = true;
            else if (settings.sendEmailWhenFindUnresolvedAgreements__c == true && ags.size() > 0) sendEmail = true;
            else if (errors != '') sendEmail = true;
            else system.debug('No need to send an email');

            if (sendEmail){
                List<String> ccAddresses = new List<String>();
                String cc_Addresses = settings.CC_Addresses__c;
                if (cc_Addresses != '' && cc_Addresses!=null){
                    ccAddresses = cc_Addresses.split(',');
                }

                //Make a custom subject which shows the number of agreements processed
                String username = UserInfo.getUserName().toUpperCase();
                String org = '';
                if (username.contains('MONSTER')){
                    org = username.mid(username.indexOf('.COM') + 5, 30);
                }
                else {
                    org = 'OrgId ' + UserInfo.getOrganizationId();
                }

                String subject = org+' '+objectName;
                if (errors != ''){
                    subject += ' Problem(s) Encountered';
                }
                else {
                    subject += ' Success';
                    if (ags.size() > 0) subject += ' ('+ags.size()+' agreements)';
                }

                Utility.sendEmail(process, objectName, ccAddresses, summary, errors, subject);
            }
        }
    }
}