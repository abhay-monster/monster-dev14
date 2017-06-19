/**
 * @description 
                    -Batch Service Class that Computes Last12MonthsSpend__c of every Account that has an Order which has an 
                     OrderStatus__c of 'Sent to A/R' and OrderDate is in the past 12 months 
                    -This will also extracts the top most account in an account hierarchy.
                    -Then after all accounts have been processed execute a batch process that will compute Hierarchy12MonthSpend__c of an account hierarchy
                     based on the extracted top level accounts
 * @Story 0270
 * @Element  E1504
 * @author Cloudsherpas
 * @company Cloud Sherpas Inc.
 * @date 28.MAY.2013
 */
public with sharing class BatchProcessService12MonthSpend {
    private final String CLASSNAME = '\n\n **** BatchProcessService12MonthSpend.';
    private String TrackMessage = '';
    private Integer Jobs = 0;
    private set<Id> ParentAccountIdSet = new set<Id>(); 
/**
 * @description Build the query string for the GetQueryLocator
 * @author B. Cheek
 * @date 25.MAR.2013
 * @param none
 * @returns Query String
 */
    public String GetQuery(){       
        final String METHODNAME = CLASSNAME + 'GetQuery()';
        
        StringBuilder sb = StringBuilder.NewStringBuilder();
        sb.AppendLine('SELECT Id, Last12MonthsSpend__c, ParentId, Name FROM Account WHERE NumberofOrders__c > 0 ORDER BY ParentId');
        if(Test.isRunningTest()){
            sb.AppendLine(' LIMIT 200 ');
        }
        system.debug('\n\n QUERY :: ' + sb.AsString()+ '\n\n');             
        return sb.AsString();
    }   

/**
 * @description Set the QueryLocator
 * @author B. Cheek
 * @date 25.MAR.2013
 * @param Query String
 * @returns Database.Querylocator
 */
    public Database.Querylocator GetQueryLocator(String pQuery){
        
        final String METHODNAME = CLASSNAME + 'GetQueryLocator()';
        return Database.getQueryLocator(pQuery);
    }
    
/**
 * @description ...
 * @author B. Cheek
 * @date 25.MAR.2013
 * @param SObject list
 * @returns Nothing
 */
    public void ProcessBatch(list<SObject> scope){
        Jobs++;
        final String METHODNAME = CLASSNAME + 'ProcessBatch()';     
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside ') + ' with Scope Size'+ scope.size() +'\n\n');
        TrackMessage += '<br /><br />Job ' + Jobs;
        system.debug('Batch Job ' + Jobs);
        map<Id, Account> accountMap = new map<Id, Account>();
        try{
            Account[] extractedAccount = (Account[])scope;
            TrackMessage += '<br />Scope size: ' + extractedAccount.size();
            
            set<Id> CurrentParentIdSet = new set<Id>();
            for(Account acc : extractedAccount){
                if(acc.ParentId != null && !ParentAccountIdSet.contains(acc.ParentId)){ 
                    //if this account has a parent account and it is not yet currently added on the top level account ids
                    //then this account's parent might potentially be a top level account
                    CurrentParentIdSet.add(acc.ParentId);
                }
                accountMap.put(acc.Id, acc);
            }
            Date currentDate = Date.today();
            Date last12Months = currentDate.addMonths(-12);
            
            Order__c[] orderList = [SELECT ForHierarchy12MonthSpend__c, NetOrderAmount2__c, Account__c, Name, Account__r.Name FROM Order__c WHERE OrderStatus__c = 'Verified' AND 
                                        (OrderDate__c > :last12Months AND OrderDate__c <= :currentDate) AND Account__c IN :accountMap.keySet()];
            system.debug('Verified Order size: ' + orderList.size());
            map<Id, Double> AccountIdTo12MonthSpend = new map<Id, Double>();
            system.debug('Processing Last12MonthsSpend__c');
            for(Order__c o : orderList){
                if(!AccountIdTo12MonthSpend.containsKey(o.Account__c)){
                    AccountIdTo12MonthSpend.put(o.Account__c, 0);
                }
                
                Double parent12MonthSpend = parseDouble(AccountIdTo12MonthSpend.remove(o.Account__c));
                parent12MonthSpend += parseDouble(o.ForHierarchy12MonthSpend__c);
                AccountIdTo12MonthSpend.put(o.Account__c, parent12MonthSpend);
                system.debug(o.Account__r.Name+ '\'s ' + o.Name + ' = ' + parseDouble(o.ForHierarchy12MonthSpend__c));
                system.debug('Current Account Spend: ' + parent12MonthSpend);
            }
            
            system.debug('Updating Account Last12MonthsSpend__c');
            for(Account a : accountMap.values()){
                system.debug(a.Name);
                if(AccountIdTo12MonthSpend.containsKey(a.Id)){
                    accountMap.get(a.Id).Last12MonthsSpend__c = AccountIdTo12MonthSpend.get(a.Id);
                    system.debug('Last12MonthsSpend__c ' + accountMap.get(a.Id).Last12MonthsSpend__c);
                }
            }
            
            //update accountMap.values();
            SetSendToEmailFlag.byPassTrigger = true;
            Database.SaveResult[] srList1 = Database.update(accountMap.values(), false);
            getParentAccount(CurrentParentIdSet);
        }catch(DMLException e){
            system.debug('Execute DML error occured: ' + e);
            TrackMessage += '<br />Execute DML error occured: ' + e + '<br />';
            for(Integer i = 0; i < e.getNumDml(); i++){
                system.debug('<br />Record that fails: ' + accountMap.values()[e.getDmlIndex(i)] + '<br />');
                TrackMessage += '<br />Record that fails: ' + accountMap.values()[e.getDmlIndex(i)] + '<br />';
            }
        }catch(Exception e){
            system.debug('Execute error occured: ' + e);
            TrackMessage += '<br />Execute error occured: ' + e;
        }
        //checks to see if TrackMessage contains string that is too large that might cause Heap Limit exception
        if(Limits.getHeapSize() * 1.3 > Limits.getLimitHeapSize()){
            //when TrackMessage is too large sends the email containing the string then reset the string
            //senEmail();
            TrackMessage = '';
        }
    }
/**
 * @description Extracts the top most account on the account hierarchy
 * @author Cloudsherpas
 * @date 28.MAY.2013
 * @param Set op Account Id extracted from the current scope
 * @returns Nothing
 */ 
    private void getParentAccount(set<Id> pPotentialParentId){
        if(pPotentialParentId == null || pPotentialParentId.size() == 0) return; //if there's no pPotentialParentId then get out of this method
        
        try{
            Account[] parenAccount = [SELECT ParentId, Id FROM Account WHERE Id IN :pPotentialParentId];
            set<Id> potentialTopLevel = new set<Id>();
            for(Account a : parenAccount){
                if(a.ParentId == null){ 
                    //when parent is null then this is a top level account
                    ParentAccountIdSet.add(a.Id);
                }else if(!ParentAccountIdSet.contains(a.ParentId)){ 
                    //when there's a parent for this account check to see if it's not yet added on the top level account id set
                    //if it's not yet added the parent is might possibly by a top level account
                    potentialTopLevel.add(a.ParentId);
                }
            }
            
            if(potentialTopLevel.size() > 0){
                //if there're still potential top level account run this method again until all top level account id is extracted
                getParentAccount(potentialTopLevel);
            }
        }catch(Exception e){
            system.debug('GetParentAccount error occured: ' + e);
            TrackMessage += '<br />GetParentAccount error occured: ' + e;
        }
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
        mail.setSubject('Lat 12 Months Spend Batch Apex Notification');
        mail.setSenderDisplayName('Salesforce.com');
        mail.setHtmlBody(TrackMessage);
        Messaging.sendEmail(new Messaging.Email[]{mail}, false);
    }*/
    
    
/**
 * @description ...
 * @author B. Cheek
 * @date 25.MAR.2013
 * @param SObject list
 * @returns Nothing
 */
    public void FinishBatch(){
        final String METHODNAME = CLASSNAME + 'FinishBatch()';      
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        TrackMessage += '<br /><br />Final Method';
        // write finish code here
        try{
            system.debug('<br />Top Level Account Count: ' + ParentAccountIdSet.size());
            TrackMessage += '</br>Current Parent Account Count: ' + ParentAccountIdSet.size();
            
            BatchProcessHierarchySpend batch = new BatchProcessHierarchySpend(ParentAccountIdSet);
            ID batchprocessid = Database.executeBatch(batch,1);
        }catch(Exception e){
            TrackMessage += '<br />Error occured: ' + e;
        }
        //senEmail();
    }            
}