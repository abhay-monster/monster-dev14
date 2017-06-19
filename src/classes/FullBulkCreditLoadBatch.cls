/*
   Modified by Vikas Menon on 4 May 2017 (T-600174) with following updates :
   1. Used new custom setting : FullBulkCreditLoadBatch__c
   2. Move the filter parent orders logic to start method from execute method
   3. Added the limit clause to query
   
*/

global class FullBulkCreditLoadBatch implements Database.Batchable<sObject>,Database.Stateful {

    global Integer batch_ct = 0;
    global Integer record_ct = 0;
    global Integer scopeSize = 0;
    global FullBulkCreditLoadBatch__c fullCreditLoadsetting;
    global Database.QueryLocator start(Database.BatchableContext BC) {

        fullCreditLoadsetting = FullBulkCreditLoadBatch__c.getInstance();
        SObjectType orderType = Schema.getGlobalDescribe().get('Order__c');
        //Map<String,Schema.SObjectField> orderFields = orderType.getDescribe().fields.getMap();
        Set<Id> orderIds = new Set<Id>();
        Set<Id> parentOrders = new Set<Id>();
        String query = 'SELECT ';
        query += 'Id FROM Order__c Where Cancelled_by_Ecom_Screening__c=true and IntegrationStatus__c = \'Processed\'';
        // Add limit to query from custom setting
        if(fullCreditLoadsetting != null && fullCreditLoadsetting.Limit__c != null && fullCreditLoadsetting.Limit__c > 0){
            query += ' Limit ' + Integer.valueOf(fullCreditLoadsetting.Limit__c);
        }
        system.debug('^^^query = '+query);
        // Filter orders having Cancelled_by_Ecom_Screening__c=true and IntegrationStatus__c = 'Processed'
        List<Order__c> orderList = database.query(query); 
        // find the orders which having already credit orders
        for(Order__c o : [Select Id, RecordType.Name, ParentOrder__c from Order__c
                          Where ParentOrder__c IN :orderList and RecordType.Name = 'Credit']){
            parentOrders.add(o.ParentOrder__c);
        }
        // Remove orders from list having credit orders
        for(Order__c o : orderList){
            if(!parentOrders.contains(o.Id)){
                orderIds.add(o.Id);
            }
        }
        system.debug('^^^Orders to be processed = '+orderIds);
        // Execute query with only orders which don't have any credit order
        query = 'SELECT Id';
        //SBerron - S-472117 - 05/09/17
        //Commented out as completely unnecessary
        //for(String sourceAPI : orderFields.keySet()){
        //    query += sourceAPI + ',';
        //}
        //query = query.removeEnd(',');
        query += ' FROM Order__c Where Id IN :orderIds';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Order__c> orders) {

        system.debug('^^^orders.size() = '+orders.size());
        batch_ct++;
        record_ct += orders.size();
        if (scopeSize ==0){scopeSize = orders.size();}
        if(orders.isEmpty()) return;
        
        /******** Moved this logic to start method **********
        List<Order__c> ordersToProcess = new  List<Order__c>();
        map<Id,List<Id>> mapOrderToChild = new map<Id,List<Id>>();
        for(Order__c o : [Select Id, RecordType.Name,ParentOrder__c from Order__c
                          Where ParentOrder__c IN :orders and RecordType.Name = 'Credit']){
           if(!mapOrderToChild.containsKey(o.ParentOrder__c)) {
              mapOrderToChild.put(o.ParentOrder__c, new List<Id>());
           }
           mapOrderToChild.get(o.ParentOrder__c).add(o.Id);
        }
        for(Order__c o : orders) {
            if(!mapOrderToChild.containsKey(o.Id)){
                ordersToProcess.add(o);
            }
        }
        System.debug('******ordersToProcess*** size: ' + ordersToProcess.size());
        for (Order__c o : ordersToProcess){
            system.debug('ID: '+o.Id+' name: '+o.name);
        }*/
         // Call bulkfullcreditload class
        BulkFullCreditLoadProcessor processor = new BulkFullCreditLoadProcessor(orders);          
        
    }


    /*   Written by Vikas Menon 21 Dec, 2016 (Refer to S-445826)
         This Finish method is used to send email notification to users
         about the status of running batch apex in case of errors.
    
    */
    global void finish(Database.BatchableContext BC) {
    
    
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,  
                       TotalJobItems, CreatedBy.Email, ExtendedStatus  
                       from AsyncApexJob where Id = :BC.getJobId()];  
        String subjectText = '';
        String objectName = 'Order';
        String processType = '';
        String updateErrors = '';  
        String summary = '';
        summary += record_ct + ' ' + objectName + ' records were processed ';
        summary += 'in ' + batch_ct + ' batches of up to ' + scopeSize + ' records each.<BR><BR>';
        
        if(subjectText == ''){
            subjectText = 'Full bulk Credit Load Batch';
        }
        if(processType == ''){
            processType = 'Processing of';
        }
        if(a.ExtendedStatus != null) {
            updateErrors = a.ExtendedStatus;
        }
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        if(fullCreditLoadsetting != null && fullCreditLoadsetting.CC_Addresses__c != null) {  
            String[] toAddresses = fullCreditLoadsetting.CC_Addresses__c.split(',');
            mail.setToAddresses(toAddresses);
            String username = UserInfo.getUserName().toUpperCase();
            String org = '';
            if (username.contains('MONSTER')){
              org = username.mid(username.indexOf('.COM') + 5, 30);
            }
            else {
              org = 'OrgId ' + UserInfo.getOrganizationId();
            }
    
            String subject = subjectText + ' ' + org + ' ' + objectName + ' Records';
            if (updateErrors != ''){
              subject += ' Encountered Problem(s)';
            }
            else {
              subject += ' Was Successful';
            }
            
            mail.setSubject(subject);
    
            String header = '';
            String body = '';
            header += 'Salesforce Org: ' + org + '<BR>';
            header += processType + ' User: ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + '<BR>';
            header += processType + ' Summary: ' + summary + '<BR><BR>';
    
            if (updateErrors == ''){
                body += 'No problems were encountered in ' + processType.toLowerCase() + ' the records.';
            } else {
              body += 'The following problem(s) were encountered, ';
              body += 'each of which reduces the associated count shown above:<BR><BR>';
              body += updateErrors;
            }
    
            String combined = header + body;
            mail.setHtmlBody(combined);
            // We are sending emails in case of errors
            if (updateErrors != ''){
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.Email[] { mail });  
            }     
        }
    }
}