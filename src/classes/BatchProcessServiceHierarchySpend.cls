/**
 * @description Batch Service Class that ...
 * @author Cloudsherpas
 * @company Cloud Sherpas Inc.
 * @date 28.MAY.2014
 */
public with sharing class BatchProcessServiceHierarchySpend {   
    private final String CLASSNAME = '\n\n **** BatchProcessServiceHierarchySpend.'; 
    private set<Id> TopLevelAccountSet;
    private Integer Jobs = 0;
    private String TrackMessage = '<br />Hierarchy12MonthSpend<br /><br />';
    
    public BatchProcessServiceHierarchySpend(set<Id> pTopLevelAccountSet){
        TopLevelAccountSet = pTopLevelAccountSet;
    }
        
/**
 * @description Build the query string for the GetQueryLocator
 * @author Cloudsherpas
 * @date 28.MAY.2014
 * @param none
 * @returns Query String
 */
    public String GetQuery(){
        
        final String METHODNAME = CLASSNAME + 'GetQuery()';
        
        StringBuilder sb = StringBuilder.NewStringBuilder();
        
        sb.AppendLine('SELECT Id, Hierarchy12MonthSpend__c, Last12MonthsSpend__c, Name FROM Account WHERE Id IN :TopLevelAccountSet');
        if(Test.isRunningTest()){
            sb.AppendLine(' LIMIT 200 ');
        }
        // build query here
        system.debug('\n\n QUERY :: ' + sb.AsString()+ '\n\n');             
        return sb.AsString();
    }   

/**
 * @description Set the QueryLocator
 * @author Cloudsherpas
 * @date 28.MAY.2014
 * @param Query String
 * @returns Database.Querylocator
 */
    public Database.Querylocator GetQueryLocator(String pQuery){
        
        final String METHODNAME = CLASSNAME + 'GetQueryLocator()';
        
        return Database.getQueryLocator(pQuery);
    }
    
/**
 * @description ...
 * @author Cloudsherpas
 * @date 28.MAY.2014
 * @param SObject list
 * @returns Nothing
 */
    public void ProcessBatch(list<SObject> scope){
        
        final String METHODNAME = CLASSNAME + 'ProcessBatch()';     
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside ') + ' with Scope Size'+ scope.size() +'\n\n');
        Jobs++;
        map<Id, Account> accountToUpdate = new map<Id,Account>();
        // write batch code here
        try{
            TrackMessage += '<br /><br />Job ' + Jobs;
            system.debug('Batch Job ' + Jobs);
            
            Account[] extractedAccounts = (Account[])scope;
            map<Id, Account[]> topAccountIdToHierarchyAccounts = new map<Id, Account[]>();
            for(Account a : extractedAccounts){
                topAccountIdToHierarchyAccounts.put(a.Id, getAllAccountsInHierarchy(a));
            }
            
            map<Id, Double> topAccountIdToHierarchySpend = new map<Id, Double>();
            for(Account ap : extractedAccounts){
                system.debug('Top Level Account: ' + ap.Name);
                TrackMessage += '<br />Top Level Account: ' + ap.Name + ' = ' + parseDouble(ap.Last12MonthsSpend__c);
                Double hierarchy12MonthSpend = 0;
                if(topAccountIdToHierarchyAccounts.containsKey(ap.Id)){
                    for(Account ac : topAccountIdToHierarchyAccounts.get(ap.Id)){
                        system.debug('Item: ' + ac.Name + ' = ' + parseDouble(ac.Last12MonthsSpend__c));
                        //TrackMessage += '<br />Item: ' + ac.Name + ' = ' + parseDouble(ac.Last12MonthsSpend__c);
                        hierarchy12MonthSpend += parseDouble(ac.Last12MonthsSpend__c);
                    }
                }
                system.debug('Total Hierarchy Spend: ' + hierarchy12MonthSpend);
                TrackMessage += '<br /><br />Total Hierarchy Spend: ' + hierarchy12MonthSpend;
                topAccountIdToHierarchySpend.put(ap.Id, hierarchy12MonthSpend);
            }
            
            for(Account ap : extractedAccounts){
                ap.Hierarchy12MonthSpend__c = topAccountIdToHierarchySpend.get(ap.Id);
                if(!accountToUpdate.containsKey(ap.Id)){
                    accountToUpdate.put(ap.Id, ap);
                }
                if(topAccountIdToHierarchyAccounts.containsKey(ap.Id)){
                    for(Account ac : topAccountIdToHierarchyAccounts.get(ap.Id)){
                        ac.Hierarchy12MonthSpend__c = topAccountIdToHierarchySpend.get(ap.Id);
                        if(!accountToUpdate.containsKey(ac.Id)){
                            accountToUpdate.put(ac.Id, ac);
                        }
                    }
                }
            }
            //update accountToUpdate.values();
            SetSendToEmailFlag.byPassTrigger = true;
            Database.SaveResult[] srList1 = Database.update(accountToUpdate.values(), false);
            TrackMessage += '<br />SOQL Queries: ' + Limits.getQueries() + ' / ' + Limits.getLimitQueries() + '<br />';
        }catch(DMLException e){
            system.debug('Execute DML error occured: ' + e);
            TrackMessage += '<br />Execute DML error occured: ' + e + '<br />';
            for(Integer i = 0; i < e.getNumDml(); i++){
                system.debug('<br />Record that fails: ' + accountToUpdate.values()[e.getDmlIndex(i)] + '<br />');
                TrackMessage += '<br />Record that fails: ' + accountToUpdate.values()[e.getDmlIndex(i)] + '<br />';
            }
        }catch(Exception e){
            TrackMessage += '<br />Execute error: ' + e;
            TrackMessage += '<br />Trace: ' + e.getStackTraceString();
        }
        //checks to see if TrackMessage contains string that is too large that might cause Heap Limit exception
        if(Limits.getHeapSize() * 1.3 > Limits.getLimitHeapSize()){
            //when TrackMessage is too large sends the email containing the string then reset the string
            //senEmail();
        }
    }
    
    public Account[] getAllAccountsInHierarchy(Account pExtractedAccount){
        Account[] output = new Account[]{};
        output.add(pExtractedAccount);
        system.debug('-Account Hierarchy Query');
        Account[] childAccounts = [SELECT Name, Id, Hierarchy12MonthSpend__c, Last12MonthsSpend__c FROM Account WHERE ParentId = :pExtractedAccount.Id];
        system.debug('Extracted child account: ' + childAccounts);
        if(childAccounts.size() > 0){
            set<Id> childAccountIdSet = new set<Id>();
            for(Account a : childAccounts){
                output.add(a);
                childAccountIdSet.add(a.Id);
            }
            output.addAll(getAllAccountsInHierarchy(childAccountIdSet));
        }
        return output;
    }
    
    public Account[] getAllAccountsInHierarchy(Set<Id> pExtractedAccounts){
        Account[] output = new Account[]{};
        system.debug('-Account Hierarchy Query');
        Account[] childAccounts = [SELECT Name, Id, Hierarchy12MonthSpend__c, Last12MonthsSpend__c FROM Account WHERE ParentId IN :pExtractedAccounts];
        system.debug('Extracted child account: ' + childAccounts);
        if(childAccounts.size() > 0){
            set<Id> childAccountIdSet = new set<Id>();
            for(Account a : childAccounts){
                output.add(a);
                childAccountIdSet.add(a.Id);
            }
            output.addAll(getAllAccountsInHierarchy(childAccountIdSet));
        }
        return output;
    }
    
    private Double parseDouble(Object val){
        return val == null ? 0 : Double.valueOf(val);
    }
/**
 * @description Sends an email of the status of this batch process
 * @author Cloudsherpas
 * @date 28.MAY.2013
 * @param Nothing
 * @returns Nothing
 */ 
    /*private void senEmail(){
        Messaging.Singleemailmessage mail = new Messaging.Singleemailmessage();
        mail.setCcAddresses(new String[]{'booz.espiridion@cloudsherpas.com'});
        mail.setSubject('Hierarchy Lat 12 Months Spend Batch Apex Notification');
        mail.setSenderDisplayName('Salesforce.com');
        mail.setHtmlBody(TrackMessage);
        Messaging.sendEmail(new Messaging.Email[]{mail}, false);
        
        TrackMessage = '<br />Hierarchy12MonthSpend<br /><br />';
    }*/
    
    
/**
 * @description ...
 * @author Cloudsherpas
 * @date 28.MAY.2014
 * @param SObject list
 * @returns Nothing
 */
    public void FinishBatch(){
        
        final String METHODNAME = CLASSNAME + 'FinishBatch()';      
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        //senEmail();
        // write finish code here
    }            
}