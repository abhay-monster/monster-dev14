// TKOM: added for S-435311 
public with sharing class massCloseCaseExtension {

    ApexPages.StandardSetController setCon;
    public String subStat {get; set;} 
    public String stat {get; set;}
    //public String errMessage { get; set; }

    //public boolean renderErrMsg {get;set;}
    public boolean disableSaveBtn {get;set;}

    public massCloseCaseExtension(ApexPages.StandardSetController controller) { 
        system.debug('massCloseCaseExtension - constructor method');
        setCon = controller;
        
        //errMessage = ''; 
        disableSaveBtn = true; 
        //renderErrMsg = false;
        stat = 'Closed';
        subStat = '--None--';
        system.debug('massCloseCaseExtension - constructor method:  disableSaveBtn = '+ disableSaveBtn + ' :: subStat = ' + subStat);
        
        // if no records are selected, prompt user to go back to the list view.
        if(getSelectedSize() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No records selected for update - please return to the Case list to select records to be updated.'));    
            //errMessage = 'No records selected for update - please return to the Case list to select records to be updated.';
            disableSaveBtn = true;
            //renderErrMsg = true;
        }
        else verifySubStatus();
    }
    
    // method below adapted from: https://help.salesforce.com/apex/HTViewSolution?id=000176201&language=en_US
    public List<SelectOption> getSubStatuses()

        {
           // Build the picklist values.  This is tricky - we can't use apex:inputfield because it is possible to select cases that have multiple record types. 
           // the VF page doesn't know which one to use, so it uses the logged in user's profile "Default" record type to decide which picklist values to show.
           // Doing it dynamically this way is better (we get all possible values on the picklist), except now we lose the dependency with Status.
           // There is apex/javascript code out there to do this, but it is fairly complicated to implement, I think.
           // See: 
           // https://success.salesforce.com/ideaView?id=08730000000h1y6AAA 
           // http://titancronus.com/blog/2014/05/01/salesforce-acquiring-dependent-picklists-in-apex/ 
           //
           system.debug('massCloseCaseExtension - getSubStatuses method: disableSaveBtn = '+ disableSaveBtn);
           List<SelectOption> options = new List<SelectOption>();
        
           Schema.DescribeFieldResult fieldResult = Case.SubStatus__c.getDescribe();
           List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
           options.add(new SelectOption('--None--', '--None--'));
           for( Schema.PicklistEntry f : ple)
           {
              options.add(new SelectOption(f.getLabel(), f.getValue()));
           }       
           return options;
         }
         
    public integer getSelectedSize() {
        system.debug('massCloseCaseExtension - getSelectedSize method: disableSaveBtn = '+ disableSaveBtn);
        system.debug('setCon.getSelected().size() = '+setCon.getSelected().size());
        // number of records selected using checkboxes on the list view when the mass close cases button was clicked
        if (setCon.getSelected().size() == 0) {
            //renderErrMsg = true; 
            disableSaveBtn = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No records selected for update - please return to the Case list to select records to be updated.'));    
        }
        return setCon.getSelected().size();
    }
    
    public integer getListViewRecordsSize() {
        system.debug('massCloseCaseExtension - getListViewRecordsSize method: disableSaveBtn = '+ disableSaveBtn);
        system.debug('setCon.getRecords().size() = '+setCon.getRecords().size());
        // number of records returned by the list view when the mass close cases button was clicked
        return setCon.getRecords().size();
    }
    
    public void verifySubStatus(){
            disableSaveBtn = true;
            subStat = Apexpages.currentPage().getParameters().get('subStatus');
            
            system.debug('in method verifySubStatus.  subStat = ' + subStat + ' : disableSaveBtn = '+ disableSaveBtn);
            // Check for the '--None--' value and force the user to pick a different value before Saving           
            if(subStat == '--None--' ){
               //errMessage = subStat; //used for debugging
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please choose a valid SubStatus, you cannot use "' + subStat +'."'));
           }
           
           else {disableSaveBtn = false; getSelectedSize();}
    }
    
    public PageReference save(){
        // override standard controller save method
        return setCon.save();
    }       
}