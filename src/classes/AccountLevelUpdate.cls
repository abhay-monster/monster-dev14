/**
* @author Original: robby angeles
* @date   Original: 02 DEC 2014
* @description batch class to tag purchasing account level field values based on predetermined criteria.
* @History - 02 DEC 2014 - robby angeles - created
*/

/************************************************************************************************************************
  I-159680 Jfreese Appirio 1/18/16
  This batch class sets Account.Level__c to indicate that the account is a Parent/Child/StandAlone account
  with or without orders (Purchasing_Account_Flag__c > 0 or == 0, respectively).

  The original Sherpa version processed all accounts, and first time it was run on production,
  the 23,013 batches of 200 accounts took nearly 30 hours to execute.

  David M requested that the code be modified to only process new or recently modified accounts, so a new field
  (LevelNeedsUpdating__c) and workflow rule (Level Needs Updating) were created on account.  This flags new accounts
  or accounts whose parentID or Purchasing_Account_Flag__c have changed in an update, setting LevelNeedsUpdating__c
  to true so it will be selected by the start query.  That flagged all child accounts and (parent) accounts
  whose purchase status changes.

  It did not flag newly designated parent accounts, so initially this class was modified to process the parents of
  all children in each batch, whether or not the parent was in the batch.  But this approach had two problems:
  1) it would not catch accounts which had been a parent of one child and were de-parented by the child account
  2) if the batch consisted solely of 200 children then a total of 400 accounts would need updating, possible DML problem

  Therefore, AccountTriggerHelper.SetParentLevelNeedsUpdating() was created to flick on the LevelNeedsUpdating__c
  for all new and former parent accounts when a child account is created or modified to set or change ParentId.
  ***********************************************************************************************************************/

global class AccountLevelUpdate implements Database.Batchable<sObject>, Database.Stateful
{
    //retrieve Account Level picklist values from custom setting
    Account_Level_Values__c accLevelSett = Account_Level_Values__c.getOrgDefaults();
    global String errors = '';
    global Integer batch_ct = 0;
    global Integer record_ct = 0;
    global Integer err_ct = 0;
    global Integer scopeSize = 0;

    global Database.Querylocator start(Database.BatchableContext BC)
    {
        string query = accLevelSett.query__c;
        system.debug ('^^^ query='+query);
        return Database.getQueryLocator(query);
        return null ;
    }

    global void execute(Database.BatchableContext BC, List<Account> scope)
    {
        final String CLASSNAME = '\n\n**** AccountLevelUpdate.METHODNAME()';
        final string METHODNAME = CLASSNAME.replace('METHODNAME','Execute');
        Logger.push(METHODNAME, Schema.Account.getSObjectType().getDescribe().getName());

        batch_ct++;
        record_ct += scope.size();
        if (scopeSize ==0){scopeSize = scope.size();}

        try{
            string purParent        = accLevelSett.Purchasing_Parent__c;
            string purChild         = accLevelSett.Purchasing_Child__c;
            string purStandAlone    = accLevelSett.Purchasing_Stand_Alone__c;
            string nonPurParent     = accLevelSett.Non_Purchasing_Parent__c;
            string nonPurChild      = accLevelSett.Non_Purchasing_Child__c;
            string nonPurStandAlone = accLevelSett.Non_Purchasing_Stand_Alone__c;
            Boolean resetFlag       = accLevelSett.Reset_LevelNeedsUpdating__c;

            if(!string.isEmpty(purParent) && !string.isEmpty(purChild) && !string.isEmpty(purStandAlone) ||
               !string.isEmpty(nonPurParent) && !string.isEmpty(nonPurChild) && !string.isEmpty(nonPurStandAlone)
            ){

                set<Id> accIdSet = new set<Id>();
                for(Account acc :scope){
                    accIdSet.add(acc.Id);
                }

                //identify the accounts in the batch which are parents (have at least one child)
                set<Id> accIsAParentIdSet = new set<Id>();
                for(AggregateResult ar : [select ParentId, Count(Id) from Account where ParentId IN:accIdSet Group By ParentId]){
                    accIsAParentIdSet.add((Id)ar.get('ParentId'));
                }

                list<Account> accountsForUpdList = new list<Account>();
                //iterate the batch accounts and update the level field based on pre determined conditions
                for(Account acc :scope){

                    //Sberron - S-473220 - 4/26/17
                    //Bypass validations in batch process to avoid preventing updates.
                    acc.Bypass_All_Validation_Rules__c = true;

                    if(resetFlag){
                        acc.LevelNeedsUpdating__c = false;
                    }

                    //conditions for a Purchasing Parent Account
                    if(acc.Purchasing_Account_Flag__c > 0 && accIsAParentIdSet.contains(acc.Id) && acc.Level__c != purParent){
                        acc.Level__c = purParent;
                    }
                    //conditions for a Non-Purchasing Parent Account
                    if(acc.Purchasing_Account_Flag__c == 0 && accIsAParentIdSet.contains(acc.Id) && acc.Level__c != nonPurParent){
                        acc.Level__c = nonPurParent;
                    }
                    //conditions for a Purchasing Child Account
                    if(acc.Purchasing_Account_Flag__c > 0 && !accIsAParentIdSet.contains(acc.Id) && acc.ParentId != null &&
                        acc.Level__c != purChild){
                            acc.Level__c = purChild;
                    }
                    //conditions for a Non-Purchasing Child Account
                    if(acc.Purchasing_Account_Flag__c == 0 && !accIsAParentIdSet.contains(acc.Id) && acc.ParentId != null &&
                        acc.Level__c != nonPurChild){
                            acc.Level__c = nonPurChild;
                    }
                    //conditions for a Purchasing Stand-Alone (not parent or child) Account
                    if(acc.Purchasing_Account_Flag__c > 0 && !accIsAParentIdSet.contains(acc.Id) && acc.ParentId == null
                        && acc.Level__c != purStandAlone){
                            acc.Level__c = purStandAlone;
                    }
                    //conditions for a Non-Purchasing Stand-Alone (not parent or child) Account
                    if(acc.Purchasing_Account_Flag__c == 0 && !accIsAParentIdSet.contains(acc.Id) && acc.ParentId == null
                        && acc.Level__c != nonPurStandAlone){
                            acc.Level__c = nonPurStandAlone;
                    }
                    //update all the accounts in scope, whether or not their Level__c changed (need to unset LevelNeedsUpdating__c)
                    accountsForUpdList.add(acc);
                }

                //update accounts with level value updates
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
                        accountsForUpdList.get(i);//failed record from the list
                        Logger.debugException(Label.CS_AccLevelUpd_AccFailed + ' \n'+ accountsForUpdList.get(i).id + ' \n' + failedDML, accountsForUpdList.get(i).id);
                    }
                }
            }
            else{
                //log an exception if at least one account level settings is blank.
                Logger.debugException(Label.CS_AccLevelUpd_BlankLvlValue);
                errors += 'Batch '+batch_ct+' error: Account_Level_Values__c value(s) are not populated!!<BR>';
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
            Logger.debugException(Label.CS_AccLevelUpd_BatchFailed + ' \n'+ accIds + ' \n' + e.getMessage());
        }
        Logger.pop();
    }

    global void finish(Database.BatchableContext BC)
    {
        String process = 'Account Level Update';
        String objectName = 'Account';
        List<String> ccAddresses = new List<String>();
        String cc_Addresses = accLevelSett.CC_Addresses__c;
        if (cc_Addresses != '' && cc_Addresses!=null){
            ccAddresses = cc_Addresses.split(',');
        }
        String summary = record_ct + ' ' + objectName + ' records were processed ';
        summary += 'in ' + batch_ct + ' batch(es) of up to ' + scopeSize + ' records each.<BR><BR>';
        if (err_ct > 0){
            summary += 'The '+err_ct+' error(s) shown below represent accounts which could not be updated, reducing the number ';
            summary += 'of accounts updated from '+record_ct+' to '+(record_ct - err_ct)+'<BR>';
        }

        //Appirio JFreese 4/25/17 S-481980 add customSubject to sendEmail
        Utility.sendEmail(process, objectName, ccAddresses, summary, errors, '');
    }
}