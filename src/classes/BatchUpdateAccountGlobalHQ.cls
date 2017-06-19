/**
* @author Appirio J Freese S-470365
* @date   Mar 18, 2017
* @description batch class to update the GlobalHQ of child accounts in hierarchy
*/


global class BatchUpdateAccountGlobalHQ implements Database.Batchable<sObject>, Database.Stateful
{
    BatchUpdateAccountGlobalHQ__c settings = BatchUpdateAccountGlobalHQ__c.getOrgDefaults();
    private map<Id, Account> parentAccounts;
    private Map<Id,Id> newGlobalHQ;
    global String errors = '';
    global String summary = '';
    global Integer batch_ct = 0;
    global Integer record_ct = 0;
    global Integer err_ct = 0;
    global Integer scopeSize = 0;
    global String csv = 'Id, GlobalHQAccount__c\n';
    public static Boolean RunningBatchUpdateAccountGlobalHQ {get;set;}

    global BatchUpdateAccountGlobalHQ(map<Id, Account> parentAccounts, Map<Id,Id> newGlobalHQ) {
        this.parentAccounts = parentAccounts;
        this.newGlobalHQ = newGlobalHQ;
        /*newGlobalHQ is a map of Id to the new GlobalHQ.  It comes in with one record per parent with the pearent's current (updated) GlobalHQ.
          As we query for each generation of children, we create a newGlobalHQ record for each child which specifies the parent's GlobalHQ.
          The Start method just passes a query of all child IDs to the Execute, which looks up the new GlobalHQ from the map,
          assigns it to the child and updates the child.*/
        RunningBatchUpdateAccountGlobalHQ = false;
    }

    global Database.Querylocator start(Database.BatchableContext BC)
    {
        Set<Id> AccountIDs = new Set<Id>();
        map<Id, Account> NewParentAccounts = new map<Id, Account>();
        List<Account> ChildAccounts = new List<Account>();
        Integer ctr = 0;
        String queryStr = '';
        String addOn = settings.Query_Add_On__c;


        summary = 'The following Parent account(s) were updated, leading to processing of all children in the hierarchy:<br>';
        for (Id thisId : parentAccounts.keySet()){
            summary += thisId+' ('+parentAccounts.get(thisId).Name+')<br>';
        }
        summary += '<br><br>';


        queryStr = 'SELECT Id, GlobalHQAccount__c, Name, ParentId FROM Account WHERE ParentId IN (';
        for(String id : parentAccounts.keySet()){
            queryStr += '\'' + id + '\',';
        }
        queryStr = queryStr.left(queryStr.length() - 1);
        queryStr += ')';
        if (addOn != null && addOn != ''){
            queryStr += addOn;
        }
        system.debug('queryStr = '+ queryStr);

        ChildAccounts = Database.query(queryStr);
        if (ChildAccounts.size() == 0){summary += 'No child accounts found to process.';}
        else {
            Boolean notDone = true;
            do {
                ctr++;
                system.debug('Generation '+ctr+': '+ChildAccounts.size()+' children');
                for(Account acc : ChildAccounts){
                    if (! AccountIDs.contains(acc.Id)){
                        AccountIDs.add(acc.Id);
                        NewParentAccounts.put(acc.Id, acc);
                        if (newGlobalHQ.containsKey(acc.parentId)){
                            newGlobalHQ.put(acc.Id,newGlobalHQ.get(acc.parentId));
                            csv += acc.Id+', '+newGlobalHQ.get(acc.parentId)+'\n';
                        }
                        else {
                            //This should never be encountered, but report it if it does
                            errors += 'Start Error, parent globalHQ record not found: ID='+acc.Id+', GlobalHQAccount__c='+acc.GlobalHQAccount__c+'<br>';
                        }
                    }
                }
                queryStr = 'SELECT Id, GlobalHQAccount__c, Name, ParentId FROM Account WHERE ParentId IN (';
                for(String id : NewParentAccounts.keySet()){
                    queryStr += '\'' + id + '\',';
                }
                queryStr = queryStr.left(queryStr.length() - 1);
                queryStr += ')';
                if (addOn != null && addOn != ''){
                    queryStr += addOn;
                }
                system.debug('queryStr = '+ queryStr);

                ChildAccounts = Database.query(queryStr);
                NewParentAccounts.clear();

                if (ChildAccounts.size() == 0){
                    notDone = false;
                }
                else if (ctr == 200){
                    errors += 'Halting the Start method to prevent Too Many SOQL 201 error!!<br>';
                    errors += 'Apparently one of the original accounts has a hierarchy with more than 200 generations(!!)<br>';
                    errors += 'The child accounts down to and including the 200th generation will be updatedby in the Execute method,<br>';
                    errors += 'but the descendants of the 200th generation will need to be fixed indpendently.<br>';
                    errors += 'The 200th generation accounts are as follows:<br>';
                    for(Account acc : ChildAccounts){
                        errors += acc.Id+' '+acc.Name+'<br>';
                    }
                    notDone = false;
                }
            } while (notDone);
        }

        system.debug('AccountIDs.size() = '+AccountIDs.size()+', newGlobalHQ.size()='+newGlobalHQ.size()+', SOQL query count='+Limits.getQueries());
        String query = 'SELECT Id, Name, GlobalHQAccount__c FROM Account where Id IN: AccountIDs';
        system.debug('**Account to update** '+Database.getQueryLocator(query));
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope)
    {
        System.debug('Execute called');
        final String CLASSNAME = '\n\n**** BatchUpdateAccountGlobalHQ.METHODNAME()';
        final string METHODNAME = CLASSNAME.replace('METHODNAME','Execute');

        RunningBatchUpdateAccountGlobalHQ = true; // use this to bypass AccountTriggerHelper.updateDescendantsOftheUpdatedAccount()

        batch_ct++;
        record_ct += scope.size();
        if (scopeSize ==0){scopeSize = scope.size();}

        try{
                list<Account> accountsForUpdList = new list<Account>();

                for(Account acc : scope){
                    if (newGlobalHQ.containsKey(acc.Id)){
                            if (acc.GlobalHQAccount__c == newGlobalHQ.get(acc.Id)){
                            }
                        acc.GlobalHQAccount__c = newGlobalHQ.get(acc.Id);
                        //Added on 4/4/17 for S-473622 by Mitali Nahar
                        acc.Bypass_All_Validation_Rules__c = true;
                        accountsForUpdList.add(acc);
                    }
                    else {
                        //This should never be encountered, but report it if it does
                        errors += 'Error, new globalHQ record not found: ID='+acc.Id+', GlobalHQAccount__c='+acc.GlobalHQAccount__c+'<br>';
                    }
                }

                system.debug('%%List to Update '+accountsForUpdList);
                List<Database.SaveResult> updateResults;
                updateResults = Database.update(accountsForUpdList, false);
                for(Integer i=0;i<updateResults.size();i++){
                    if (!updateResults.get(i).isSuccess()){
                        // DML operation failed
                        Database.Error error = updateResults.get(i).getErrors().get(0);
                        String failedDML = error.getMessage();
                        err_ct++;
                        system.debug('^^^ ERROR: '+failedDML);
                        errors += 'Batch '+batch_ct+' error on ID '+accountsForUpdList.get(i).id+': '+failedDML+'<BR>';
                    }
                }
        }
        catch(exception e){
            //list down the account Ids for possible reference
            string accIds = ' List of Account Ids: [';
            for(Account acc:scope){
                accIds += '\'' + string.valueOf(acc.Id) + '\':';
            }
            accIds += ']';
            errors += 'Batch '+batch_ct+' General Failure!!<BR>';
        }
    }

    global void finish(Database.BatchableContext BC)
    {
        if (settings.Debug__c == true || errors != ''){
            ContentVersion file = new ContentVersion(
                title = 'newGlobalHQ.csv',
                versionData = Blob.valueOf(csv),
                pathOnClient = '/newGlobalHQ.csv'
            );
            insert file;
            System.debug(file);
        }

        String process = 'Account GlobalHQ Update';
        String objectName = 'Account';
        List<String> ccAddresses = new List<String>();
        String cc_Addresses = settings.CC_Addresses__c;
        if (cc_Addresses != '' && cc_Addresses!=null){
            ccAddresses = cc_Addresses.split(',');
        }
        summary += record_ct + ' child ' + objectName + ' records were processed ';
        summary += 'in ' + batch_ct + ' batch(es) of up to ' + scopeSize + ' records each.<BR><BR>';
        if (err_ct > 0){
            summary += 'The '+err_ct+' error(s) shown below represent child accounts which could not be updated, reducing the number ';
            summary += 'of accounts updated from '+record_ct+' to '+(record_ct - err_ct)+'<BR>';
        }

        //Appirio JFreese 4/25/17 S-481980 add customSubject to sendEmail
        Utility.sendEmail(process, objectName, ccAddresses, summary, errors, '');
    }
}