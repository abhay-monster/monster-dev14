public without sharing class CustomLookupCtrl {
    public String fieldName {get;set;}   
    public String objName {get;set;}
    public String selectedId {get;set;}
    public SObject currentRecord{get;set;}
    public String selectedRecordName {get;set;}
    public String fieldPopulatingId {get;set;}
    public String fieldSetNameAPI {get;set;}
                  
    public CustomLookupCtrl(){
        fieldName = '';
        objName = '';
        currentRecord = null;
    }
     
    public PageReference getSelectedRecord(){
        if(selectedId != null && selectedId != ''){                 
            string currentRecordId = this.selectedId;       
            if(currentRecordId <> null){
                List<Sobject> sobjectList = Database.query('SELECT Id, ' + this.fieldName + ' FROM ' + this.objName + ' WHERE ID = : currentRecordId');
                
                if(!sobjectList.isEmpty()){
                    this.currentRecord = sobjectList[0];
                    selectedRecordName = (String) sobjectList[0].get('Name');
                }
            }
        }
        return null;
    }   
}