/*
*   Author: CloudSherpas Inc.
*   Created Date: 11/28/2014
*   Description: A controller for the TransferCustomLookup  
*/
public with sharing class TransferCustonLookupCC {
    public string searchString{get;set;} // search keyword
    public string accountRelated{get;set;} // Related account
    public List<Xcode__c> xCodeList{get;set;}
    Transient List<XcodeAccount__c> xCodeAccountList{get;set;}
    public Set<Id> xCodeIds{get;set;}
    //Instantiate the StandardSetController
    public ApexPages.StandardSetController con{get; set;}
    public List<XcodeDesc> AllSearchXcodeRecs {get;set;}
    Map<String, String> mpStateCountry;
    public List<Xcode__c> AllSearchUsers
    {
        get
        {
            if(con != null)
                return (List<Xcode__c>)con.getRecords();
            else
                return null ;
        }
        set;}
    
    public Account camp {get; set;}
    
    public string getFormTag() {
        return System.currentPageReference().getParameters().get('frm');
    }  
    
    // used by the visualforce page to send the link to the right dom element for the text box
      public string getTextBox() {
        return System.currentPageReference().getParameters().get('txt');
      }
    //Clean the searchstring
    private String cleanQuery(String qry){
        qry = '%' +qry+ '%';
        qry = qry.replace('*','%');
        qry = qry.replace('%%','%');
        qry = qry.replace('?','_');
        qry = qry.replace('\'',' ');
        qry = qry.replace('__','_');
        return qry = string.escapeSingleQuotes(qry);
    }
    
    public TransferCustonLookupCC()
    {   
        accountRelated = System.currentPageReference().getParameters().get('idfield');
        //searchString = System.currentPageReference().getParameters().get('namefield');
        searchString = 'x';
        AllSearchUsers = new List<Xcode__c>() ;
    }
    
    public void Search(){   
        //Account stStr = new Account();
        //stStr = [SELECT Id FROM Account];
        try{
            xCodeAccountList = new List<XcodeAccount__c>();
            AllSearchXcodeRecs = new List<XcodeDesc>(); 
            xCodeIds = new Set<Id>();
            if(String.isBlank(searchString)== false){
                String searchTerm = cleanQuery(searchString);
                
                //String query = 'SELECT Id, Name, Account__c, Xcode__c FROM XcodeAccount__c WHERE Account__c =' + accountRelated;
                //xCodeAccountList = Database.query(query);
                
                // Changes Start by GG : I-191161
                xCodeAccountList = [SELECT Id, Name, Account__c, Xcode__c FROM XcodeAccount__c where Xcode__c != null and xcode__r.Name LIKE : searchTerm];
                for(XcodeAccount__c xc : xCodeAccountList){
                    if(xc.Xcode__c != null){
                        xCodeIds.add(xc.Xcode__c);
                    }
                }
                xCodeList = [SELECT Id, Name FROM Xcode__c WHERE Id in: xCodeIds /*AND Name LIKE : searchTerm*/  LIMIT 1000];
                // Changes End by GG : I-191161
                
                con = new ApexPages.StandardSetController(xCodeList);
                con.setPageSize(10);
            }
        }catch(Exception e){
            system.debug('Error: ' + e);
            system.debug('Trace: ' + e.getStackTraceString() + '\n\n');
        }
    }
    //Boolean to check if there are more records after the present displaying records
    public Boolean hasNext
    {
        get
        {
            return con.getHasNext();
        }
        set;
    }
 
    //Boolean to check if there are more records before the present displaying records
    public Boolean hasPrevious
    {
        get
        {
            return con.getHasPrevious();
        }
        set;
    }
 
    //Page number of the current displaying records
    public Integer pageNumber
    {
        get
        {
            return con.getPageNumber();
        }
        set;
    }
    public Xcode__c[] getXcodes(){
        return con.getRecords();
    }
    //Returns the previous page of records
    public PageReference previous()
    {
        con.previous();
        return null;
    }
 
    //Returns the next page of records
    public PageReference next()
    {
        con.next();
        return null;
    }
    
    public class XcodeDesc{ 
        public XcodeAccount__c XRec{get;set;}
        public XcodeDesc(){}
    } 
}