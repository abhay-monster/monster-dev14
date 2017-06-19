public without sharing class ChangePrimarySalesRepAccountCC {

    public string newOwnerId{get;set;}
    
    final String CLASSNAME = '\n\n**** ChangePrimarySalesRepAccountCC.METHODNAME()';
    public String accId{get;set;}
    public String recId{get;set;}
    public String ownId{get;set;}
    public Account name{get;set;}
    public Account acc{get;set;}
    public ChangePrimarySalesRepAccountCC(ApexPages.Standardcontroller sc){
    accId =  ApexPages.currentPage().getParameters().get('AccountId');
    recId =  ApexPages.currentPage().getParameters().get('RecordType');
    getAccountToUpdate();
    }
    
    public void getAccountToUpdate(){
    name = new Account();
        if(recId == '012110000004Pkt'){
            acc = [SELECT FirstName,LastName, OwnerId, Owner.FirstName, Owner.LastName, DoNotReassign__c FROM Account WHERE ID =: accId];
            
            String fullName = '';
            if(acc.FirstName != null){
                fullname += acc.FirstName + ' ';
            }
            if(acc.LastName != null){
                fullname += acc.LastName;
            }
            name.Name = fullname;
        } else {
            acc = [SELECT Name, OwnerId, Owner.FirstName, Owner.LastName, DoNotReassign__c FROM Account WHERE ID =: accId];
            name.Name = acc.Name;
       }
        ownId = acc.OwnerId; // Old Account Owner
        acc.OwnerId = null; // New Acc Owner will be saved in this variable
    }
    
    public PageReference saveNewOwner(){
    //system.assert(false , companyDiscussed);
        final string METHODNAME = CLASSNAME.replace('METHODNAME','saveNewOwner');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
        system.debug('^^^OwnerId'+acc.OwnerId);
        system.debug('^^^Account'+acc);
            if(!acc.DoNotReassign__c){
                String searchString;
                //hack to access component value;
                for (String s : ApexPages.currentPage().getParameters().keySet()) {
                    if (s.contains('targetName')) {
                        searchString = ApexPages.currentPage().getParameters().get(s);
                        break;
                    }
                }
                system.debug('>>>>>>>Search>>>>>'+searchString);
                
                if (String.isBlank(acc.OwnerId) && String.isNotBlank(searchString)) {
                    searchString = '%'+searchString+'%';
                    list<User> owners = [SELECT Id FROM User WHERE Name LIKE :searchString];
                    system.debug('>>>>>>>Owners>>>>>'+owners);
                    if (owners.size() == 0) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'No matches found.'));
                        return null;
                    } else if (owners.size() > 1) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Multiple items found. Click icon to refine search.'));
                        return null;
                    } else {
                        acc.OwnerId = owners[0].Id;
                    }
                }
                if(!(ownId == acc.OwnerId)){
                    OwnerChangeThreshold__c ownerChangeThreshold = OwnerChangeThreshold__c.getOrgDefaults();
                    try{
                        Integer totalRecordsToUpdate = 0;
                        for(Account a : AccountTriggerHelper.getChangedAccounts(new set<Id>{acc.Id})){ 
                        
                            if(!a.Opportunities.isEmpty()){
                                totalRecordsToUpdate += a.Opportunities.size();
                                
                            }
            
                            if(!a.Contacts.isEmpty()){
                                totalRecordsToUpdate += a.Contacts.size();
                            }
                            /*if(!a.Tasks.isEmpty()){
                                totalRecordsToUpdate += a.Tasks.size();
                            }
                            if(!a.Events.isEmpty()){
                                totalRecordsToUpdate += a.Events.size();
                            }*/
                        }
                         totalRecordsToUpdate +=  [SELECT count()  FROM Task WHERE Status = 'Open' AND  AccountId = :acc.Id and ownerId = :ownId];
                    
                        totalRecordsToUpdate += [SELECT count() FROM Event WHERE EventStatus__c = 'Open' AND  AccountId = :acc.Id and ownerId = :ownId];
                    
                         update acc;
                        system.debug('totalRecordsToUpdate:::'+totalRecordsToUpdate);
                        if(ownerChangeThreshold != null &&  totalRecordsToUpdate > ownerChangeThreshold.Threshold__c){
                             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Due to the large number of records associated to this account, the Owner change will take a few minutes.  You will be notified by email when complete.'));
                            return null;
                        }
                    
                       
                    } catch (Exception e) {
                        ApexPages.addMessages(e);
                        return null;
                    }
                }
            } else if(acc.OwnerId == null){
                return null;
            }

            PageReference pgRef = new PageReference('/'+ accId);
            pgRef.setRedirect(true);
            return pgRef;
        }catch(DMLException e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage()));
            ExceptionLog.add('DMLException', 'ChangePrimarySalesRepAccountCC', 'save', e.getMessage());
            //throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Failed to update. Please see system log for details.', e);
            return null;
        }
    }
    
    public PageReference cancel(){
        PageReference pgRef = new PageReference('/'+ accId);
        pgRef.setRedirect(true);
        return pgRef;
    }  
}