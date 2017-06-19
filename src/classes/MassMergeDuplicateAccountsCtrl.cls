public with sharing class MassMergeDuplicateAccountsCtrl {
    
    public static List<Account> lstAccToDisplay {get; set;}
    public String selectedOrg {get; set;}
    public List<MergeWrapper> wrappers {get; set;}
    private Integer nextIdent=0;
    public List<Account> listSelectedRec {get;set;}
    public Boolean isDataSteward {get;set;}
    public boolean batchProcessed {get;set;}
    public String batchStatus {get; set;}
    public String message {get; set;}
    public String createdByUserName {get;set;}
    public DateTime createdBatchDate {get;set;}
    public Boolean batchInProcess {get;set;}
            
    public MassMergeDuplicateAccountsCtrl() {
        isDataSteward = isUserDataSteward();
        List<SelectOption> orgOption = getOrganisations();
        setOrganisations(orgOption.get(0).getLabel());
        fetchAccounts();
        listSelectedRec = new List<Account>();
        batchProcessed = false; 
        batchInProcess = false;
        //getProcessingMessage();
    }
    
    public PageReference fetchAccounts() {
        wrappers = new List<MergeWrapper>();
        for(Account acc : [SELECT Id, AccountID__c, Organization__c, Name, Merge_Winner__r.AccountID__c, IsPersonAccount 
                                        FROM Account
                                        WHERE Merge_Winner__c != null 
                                        AND Organization__c =: selectedOrg
                                        AND SalesChannel__c != 'Agency']) {
            
            wrappers.add(new MergeWrapper(nextIdent++, acc));   
        }                           
        return null;
    }
    
    public void setOrganisations(String orgNew) {
        this.selectedOrg = orgNew;
    }
    
    public List<SelectOption> getOrganisations() {
        List<selectOption> options = new List<selectOption>(); 
        System.debug('In getstatusses');
        Schema.DescribeFieldResult field = Schema.sObjectType.Account.fields.Organization__c;
        List<Schema.PicklistEntry> picklist = field.getPicklistValues();
        for(Schema.PicklistEntry p : picklist) {
            if(p.isDefaultValue() && getOrganisations() == null) {
                setOrganisations(p.getLabel());
            }
            SelectOption so = new Selectoption(p.getLabel(), p.getLabel());
            options.add(so);
        } 
        System.debug('Options size ' +options.size());
        return options;
    }
    
    public void runAccountMergeBatch() {
        listSelectedRec = new List<Account>();
        for(MergeWrapper wr : wrappers) {
            if(wr.isSelected) {
                listSelectedRec.add(wr.acc);
            }
        }
        
        if(listSelectedRec.size() > 0) {
            // To restict batch size a custom setting is created (as per T-592384) by Vikas Menon on 7 April 2017
            BatchMassMergeDuplicateAccounts__c cs = BatchMassMergeDuplicateAccounts__c.getInstance();
            Integer batchSize = 200;
            if(cs.Batch_size__c > 0) {
                batchSize = Integer.valueOf(cs.Batch_size__c);
            }

            BatchMassMergeDuplicateAccounts batch = new BatchMassMergeDuplicateAccounts(listSelectedRec); 
            Database.executeBatch(batch, batchSize);
            batchProcessed = true;
            getProcessingMessage();
        }
    }
    
    public void removeAccount() {
        
        listSelectedRec = new List<Account>();
        for(MergeWrapper wr : wrappers) {
            if(wr.isSelected) {
                wr.acc.Merge_Winner__c = null;
                listSelectedRec.add(wr.acc);
            }
        }
        
        if(listSelectedRec.size() > 0) {
            update listSelectedRec;
            fetchAccounts();
        }
        
    }
    
    public Boolean isUserDataSteward() {
        Id profileId=userinfo.getProfileId();
        String profileName = [Select Id,Name from Profile where Id=:profileId].Name;
        if(profileName == 'Data Steward') {
            return true;
        }
        return false;
    }
    
    public class MergeWrapper {
        public Boolean isSelected {get; set;}
        public Account acc  {get; set;}
        public Integer ident {get; set;}
        
        public MergeWrapper(Integer inIdent, Account acct){
            ident=inIdent;
            isSelected = false;
            acc = acct;
        }
        
    }
    
    public PageReference getProcessingMessage(){
        //if(batchProcessed){
            Double itemsProcessed;
            Double totalItems ;
            
            for(AsyncApexJob a : [SELECT TotalJobItems, Status, NumberOfErrors, MethodName, JobType, JobItemsProcessed, Id, 
                                    CreatedDate, CreatedById, CompletedDate, ApexClassId, ApexClass.Name , CreatedBy.Name
                                    FROM AsyncApexJob 
                                    WHERE ApexClass.Name = 'BatchMassMergeDuplicateAccounts' 
                                    ORDER By CreatedDate desc limit 1]){
                itemsProcessed = a.JobItemsProcessed;
                totalItems = a.TotalJobItems;
                batchStatus = a.Status;
                createdByUserName = a.CreatedBy.Name;  
                createdBatchDate = a.CreatedDate;
            }
            
            if(totalItems != 0 && ((itemsProcessed  / totalItems) * 100.0).intValue() != 100 ){
                batchStatus = 'In Progress';
                batchInProcess = true;
                batchInProcess = true;
            } else {
                batchInProcess = false;
                batchStatus = 'Completed';
            }
            //Determine the percent complete based on the number of batches complete and set message
            if(totalItems == 0){
                //A little check here as we don't want to divide by 0.
                message =  'Batch Job 0% Complete' + ' : Started By - ' + createdByUserName + ' : at - ' + createdBatchDate;
            }else{
                message = 'Batch Job ' + String.valueof(((itemsProcessed  / totalItems) * 100.0).intValue())+'% Complete. An email will be sent with merge results.' + ' : Started By - ' + createdByUserName + ' : at - ' + createdBatchDate;
            }

        //} else {
        if(!batchProcessed){
            message = 'Batch Job not yet executed !!';
        }
        return null;
    }
}