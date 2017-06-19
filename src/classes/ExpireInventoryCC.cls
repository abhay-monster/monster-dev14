public with sharing class ExpireInventoryCC {
    
    public String selectedAction {get; set;}
    public String SelectedOli {get;set;}
    public String selectedProposalID {get;set;}
    public String outputHTMLTable { get; set; }
    public List<Order_Line_Item__c> EligibleOrderList {get; set;}
    
    public String message { get; set; }
    private Id OrderID;

    public ExpireInventoryCC(){
        message = '';
        outputHTMLTable = '';
        if(ApexPages.currentPage().getParameters().containsKey('Id')){
            OrderID = ApexPages.currentPage().getParameters().get('Id');
            System.debug('Oder Id are >>>>>>>> ' + OrderID );
        }
        
        if(OrderID != null){
            generateOutput();
        }
    }
     
    public list<SelectOption> actionList {
       get {
       // List<String> actionL = new List<String>();
            if (actionList == null) {
                actionList = new list<SelectOption>();
                Schema.DescribeFieldResult fieldResult =  Order_Line_Item__c.Credit_Expire__c.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
                   for( Schema.PicklistEntry f : ple)
                   { 
                   	if(f.getValue() != 'Quantity')
                      actionList.add(new SelectOption(f.getLabel(), f.getValue()));
                   }       
                   //return options;
            }
            return actionList;
        }
       private set;
    } 
    
    
    private void generateOutput(){
        System.debug(LoggingLevel.INFO,'\n\nInside generateOutput \n\n');
        
        EligibleOrderList = getOrders();
        system.debug('eligibleorders'+EligibleOrderList);
        
    }
    //updated due to I-187005
    private List<Order_Line_Item__c> getOrders(){
        System.debug(LoggingLevel.INFO,'\n\nInside getOrders \n\n');
        
        
       // Date currentDate = system.today();
        List<Order_Line_Item__c> rawOrderList = new List<Order_Line_Item__c>();
        map<Id, Order_Line_Item__c[]> orderIdToOLIList = null;
        
        //rawOrderList = [SELECT Name, Id,Credit_Expire__c,Status__c,(SELECT ID FROM Line_Item_Attributes__r WHERE Unlimited__c = 'Unlimited')  FROM Order_Line_Item__c  
        //                        WHERE Order__c =:OrderID AND Status__c != 'Expired'];
                    
        for(Order_Line_Item__c oli : [SELECT Name, Id,Product__r.Name,Credit_Expire__c,Status__c,(SELECT Id,SiteLicenseID__c  FROM License_IDs__r),(SELECT ID FROM Line_Item_Attributes__r WHERE Unlimited__c = 'Unlimited')  FROM Order_Line_Item__c  
                                WHERE Order__c =:OrderID AND Status__c != 'Expired']){
            if(oli.Line_Item_Attributes__r != null && oli.Line_Item_Attributes__r.size() > 0){
                rawOrderList.add(oli);
            }
        }
        
       // rawOrderList = orderIdToOLIList.get(OrderID);
        system.debug('!@!@!@'+rawOrderList);
        return rawOrderList ;
    }
    
    public String displayStr(String input){
        if(input == null) return '';
        return input;
    }
    public String displayInt(Decimal input){
        if(input == null) return '';
        return ((Decimal)input).intValue()+'';
    }
    public String displayDec(Decimal input){
        if(input == null) return '';
        return input.setScale(2).toPlainString();
    }
    public String displayDt(Date input){
        if(input == null) return '';
        return Datetime.newInstanceGmt(input.year(), input.month(), input.day()).formatGmt('MM/dd/yyyy');
    }
    public String displayCurr(String iso, Decimal input){
        if(input == null) return '';
        return iso + ' ' + displayDec(input);
    }
    
    public PageReference selectQuoteID() {
        SelectedOli = ApexPages.currentPage().getParameters().get('radioSelectValue');
        return null;
    }
    
    public PageReference onClickNext() {
        List<Order_Line_Item__c> tobeUpdated = new List<Order_Line_Item__c>();
    	set<Id> oliIds = new Set<Id>();
        if(SelectedOli != null){
        
            List<Order_Line_Item__c> getOli = new List<Order_Line_Item__c>([SELECT Name, Status__c, Quantity2__c,Credit_Expire__c FROM Order_Line_Item__c WHERE Id =:SelectedOli] );
            for(Order_Line_Item__c oliFirst: getOli ){
                   oliFirst.Status__c = 'Expired';
                   oliFirst.Quantity2__c = 0;
                   tobeUpdated.add(oliFirst);
                   oliIds.add(oliFirst.Id);
                   BizAppsSiteModel.TerminateAllLicenses(oliFirst.Id);
            }
            update tobeUpdated;
            
       }
        return new PageReference('/' + OrderID);
    }
    
    public PageReference onClickCancel() {
      //  return new PageReference('/' + AccountID);
      return new PageReference('/' + OrderID);
    } 
}