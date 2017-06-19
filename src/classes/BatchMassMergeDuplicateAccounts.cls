global class BatchMassMergeDuplicateAccounts implements Database.Batchable<sObject>,Database.Stateful {

    //Sberron - S-481334 - 05/03
    //Made changes throughout batch class. Improved email message by sending list of successes and properly counting failures.
    //listAccToProcess was initially a  'top level' variable, leading to accounts in it getting processed more than once,
    //and an innacurate email containing duplicates.

    Set<Id> setAccIds;
    Id duplicateMergeTypeId;
    global Integer batch_ct = 0;
    global Integer record_ct = 0;
    global Integer err_ct = 0;
    global Integer successCount = 0;
    global Integer caserecord_ct = 0;
    global Integer caseErr_ct = 0;
    global Integer scopeSize = 0,count=0;
    global String error = '',result='',success='',caseErrors = '';
    //Sberron - S-481334 - 05/04
    //Put the winning and losingAccounts at the top level
    Set<Id> losingAccounts = new Set<Id>();
    Set<Id> winningAccounts = new Set<Id>();
    

    public BatchMassMergeDuplicateAccounts(list<Account> listSelectedAcc) {
        setAccIds = new Set<Id>();
        duplicateMergeTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Merge Duplicate').getRecordTypeId();
        for(Account acc : listSelectedAcc) {
            setAccIds.add(acc.Id);
            losingAccounts.add(acc.Id);
            winningAccounts.add(acc.Merge_Winner__c);
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {

        String query = 'SELECT Id, Name, AccountStatus__c,AccountID__c, Organization__c, Merge_Winner__r.AccountID__c';
                query += ' FROM Account ';
                query += ' WHERE Id IN: setAccIds';
                system.debug('=======query=====' + query);

        return Database.getQueryLocator(query);
    }

    /*   Description : This method is modified So case updation and email functionality is moved to finish method and we also send
                        case error summary addition to that
         Modified by : Vikas Menon, 10 April 2017 (S-469530)
    */

    global void execute(Database.BatchableContext BC, List<Account> scope) {

        Map<Id, Account> mapMergeAccIdToLosingAcc = new Map<Id, Account>();
        AccountMergeHelper accHelper = new AccountMergeHelper();
        List<Account> listAccToProcess = new List<Account>();
        Map<Id, Boolean> accToErrorMap = new Map<Id, Boolean>();
        Set<Id> setLossingAccToReject = new Set<Id>();

        batch_ct++;
        record_ct += scope.size();
        if (scopeSize ==0){scopeSize = scope.size();}

        System.debug('----losingAccounts ' + losingAccounts);

        for(Account a : scope) {
            System.debug('----acc in Scope ' + a);
            mapMergeAccIdToLosingAcc.put(a.Merge_Winner__c, a);
            accToErrorMap.put(a.Id, false);

           if(losingAccounts.contains(a.Id) && winningAccounts.contains(a.Id)) {
                setLossingAccToReject.add(a.Id);
                System.debug('----ACCOOUNT ' + a);
                if (accToErrorMap.get(a.Id) == false) {
                    err_ct++;    
                    error += '<b>•</b> Merge Winner (' + a.AccountID__c +  ') cannot be merge into another account (' + a.Merge_Winner__r.AccountID__c + ') in the same mass merge process. <br/>';
                    accToErrorMap.put(a.Id, true);
                }
            } 
        }
        System.debug('----mapMergeAccIdToLosingAcc ' + mapMergeAccIdToLosingAcc);

        for(Account accts : [SELECT Id, Name, AccountID__c, Merge_Winner__c, Merge_Winner__r.AccountID__c, Merge_Winner__r.Merge_Winner__c
                            FROM Account
                            WHERE Id IN : mapMergeAccIdToLosingAcc.keySet()]) {
            System.debug('----accts ' + accts);

            if(mapMergeAccIdToLosingAcc.containsKey(accts.Id)) {
                if(accts.AccountID__c == mapMergeAccIdToLosingAcc.get(accts.Id).AccountID__c) {
                    //mapMergeWinnerToAccId.put(accts.Merge_Winner__c, accts.Id);
                    setLossingAccToReject.add(mapMergeAccIdToLosingAcc.get(accts.Id).Id);
                }   
            }
        }


        system.debug('=====setLossingAccToReject========' + setLossingAccToReject);
        for(Account acc : scope) {
            System.debug('accts in scope: ' + acc);
            if(!setLossingAccToReject.contains(acc.Id)) {
                System.debug('----Acc added to listAccToProcess ' + acc.Id + acc.Name);
                listAccToProcess.add(acc);
            }
        }
        System.debug('----listAccToProcess = ' + listAccToProcess);
        for(Account a : listAccToProcess) {
            try {
                System.debug('----Acc to process' + a.ID + a.Name);
                //Sberron - mergeAccounts returns a string with the result of merge. Use this to set errors/successes accordingly
                String res = accHelper.mergeAccounts(a.Merge_Winner__c, a.Id);
                System.debug('----res ' + res);
                if (res == 'success') {
                    successCount++;
                    success += '<b>•</b> ' + a.AccountID__c + ' successfully merged into '  + a.Merge_Winner__r.AccountID__c + '. <br>';
                }
                else {
                    error += '<b>•</b> ' + a.AccountID__c + ' failed to merge into ' + a.Merge_Winner__r.AccountID__c + ' due to the following error: ' + res + '<br/>';
                    if (accToErrorMap.get(a.Id) == false) {
                        err_ct++;
                        accToErrorMap.put(a.Id, true);
                    }
                }
                
            } catch(Exception e) {
                error += '<b>•</b> ' + a.AccountID__c + ' failed to merge into ' + a.Merge_Winner__r.AccountID__c + ' due to the following error: ' + e.getMessage() + '<br/>';
                if (accToErrorMap.get(a.Id) == false) {
                    err_ct++;
                    accToErrorMap.put(a.Id, true);
                }
            }
        }
        List<Case> listCaseToUpdate = new List<Case>();
        // Update the case
        for(Case c : [SELECT Id, RecordTypeId,Duplicate_Account__c,Duplicate_Account__r.Name
                        FROM Case
                        WHERE RecordTypeId =: duplicateMergeTypeId
                        AND status = 'Open'
                        AND Duplicate_Account__c IN : listAccToProcess]) {

            c.status = 'Closed';
            listCaseToUpdate.add(c);

        }
        system.debug('====Batch==listCaseToUpdate===' + listCaseToUpdate);

        if(!listCaseToUpdate.isEmpty()){
                caserecord_ct += listCaseToUpdate.size();
                List<Database.SaveResult> updateResults;
                updateResults = Database.update(listCaseToUpdate, false);
                for(Integer i=0;i<updateResults.size();i++){
                    if (!updateResults.get(i).isSuccess()){
                        // DML operation failed
                        Database.Error error = updateResults.get(i).getErrors().get(0);
                        String failedDML = error.getMessage();
                        caseErr_ct++;
                        system.debug('^^^ ERROR: '+failedDML);
                        caseErrors += 'Case Record ID '+listCaseToUpdate.get(i).id + ' with Duplicate Account ' + listCaseToUpdate.get(i).Duplicate_Account__c + ' has Failed on Update. ERROR :' + failedDML + '<br/><br/>';
                    }
                }
        }
        System.debug('----success = ' + success);
    }

     /*  Description : This method is modified So case updation and email functionality is moved to finish method from execute method and
                        we also send case error summary addition to that
         Modified by : Vikas Menon, 10 April 2017 (S-469530)
    */

    global void finish(Database.BatchableContext BC) {

        BatchMassMergeDuplicateAccounts__c cs = BatchMassMergeDuplicateAccounts__c.getInstance();
        String summary = '';
        System.debug('----finish success ' + success);
        // Summary contains results of merge
        summary += record_ct +' Account merges were processed in <b>'+ batch_ct +'</b> batch(es) of up to <b>'+ cs.Batch_size__c.round(System.RoundingMode.DOWN) + '</b> records each.<br/>';

        if(err_ct > 0) {
            summary += '<b>'+ err_ct + '</b> merges failed due to error(s) shown below, resulting in <b>' + (record_ct - err_ct)+'</b> successful merges.<br/><br/>';
        }

        if (successCount > 0) {
            summary += '<b> The following ' + (record_ct - err_ct) + ' merges succeeded: </b><br/>' + success + '<br/>';
        }

        if(err_ct > 0 || caseErr_ct > 0) {

            if(err_ct > 0) {
                summary += '<b>The following ' + err_ct + ' error(s) were encountered:</b><br/>';
                summary +=  error;
            }
            // Error summary for Case
            if(caseErr_ct > 0) {
                summary += '<br/><br/><br/><b>Case Errors Summary:</b> ';
                summary += caserecord_ct + ' Case(s) were processed during Account merge(s)<br/>';
                summary += 'The following <b>'+ caseErr_ct  + '</b> error(s) were encountered:<br/><br/>';
                summary +=  caseErrors+'<br/>';
            }
            String process = 'Account Merge';
            String objectName = 'Account';
            List<String> ccAddresses = new List<String>();
            String cc_Addresses = cs.CC_addresses__c;
            if (cc_Addresses != '' && cc_Addresses!=null){
                ccAddresses = cc_Addresses.split(',');
            }

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            List<String> toAddresses = new List<String>();
            toAddresses.add(UserInfo.getUserEmail());
            mail.setToAddresses(toAddresses);
            if (ccAddresses.size() > 0){
                mail.setCcAddresses(ccAddresses);
            }
            String username = UserInfo.getUserName().toUpperCase();
            String org = '';
            if (username.contains('MONSTER')){
              org = username.mid(username.indexOf('.COM') + 5, 30);
            }
            else {
              org = 'OrgId ' + UserInfo.getOrganizationId();
            }

            String subject = process + ' of ' + org + ' ' + objectName + ' Records';
            mail.setSubject(subject);


            String body = '',header = '';
            body += '<b>Salesforce Org:</b> ' + org + '<br/>';
            body += '<b>'+process + ' User:</b> ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + '<br/><br/>';
            body += '<b>'+process + ' Summary:</b> ' + summary + '<br/><br/>';

            mail.setHtmlBody(body);

            List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.Email[] { mail });

            if (!results.get(0).isSuccess()) {
                system.debug('********** Email Failed - Attempt Followup ***********');
                System.StatusCode statusCode = results.get(0).getErrors()[0].getStatusCode();
                String errorMessage = results.get(0).getErrors()[0].getMessage();

                Messaging.SingleEmailMessage errmail = new Messaging.SingleEmailMessage();

                errmail.setToAddresses(toAddresses);
                errmail.setSubject(subject);

                String errbody = '';
                errbody += 'The ' + process.toLowerCase() + ' email failed to send correctly.  Send results were as follows:<BR>';
                errbody += 'System status code: ' + statusCode +'<BR>';
                errbody += 'Error message: ' + errorMessage +'<BR>';

                String combined = header + errbody;
                errmail.setHtmlBody(combined);
                Messaging.sendEmail(new Messaging.Email[] { errmail });
            }
            else{
                system.debug('********** Email sent OK ***********');
            }
        }
    }

}