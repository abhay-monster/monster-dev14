/*
** @author : Cloud Sherpas Inc.
** @date : 03/24/2014
** @description : StrategicAccountPlanCC Page Controller Class
*/
public with sharing class StrategicAccountPlanCC {
    
    final String CLASSNAME = '\n\n**** StrategicAccountPlanCC.METHODNAME()';
    
    private Account PageAccount{get;set;}
    
    public StrategicAccountModel SAModel{get;set;}
    public String AccountId{get;set;}
    public String tempString{get;set;}
    
    //getter of the current page plus the render as pdf url param set to true
    //for new tab pdf rendering of the page
    public String NewTabAsPDF {
        get{
            String param = '?';
            for(String pName : ApexPages.currentPage().getParameters().keySet()){
                param += pName + '=' + ApexPages.currentPage().getParameters().get(pName) + '&';
            }
            return '/apex/StrategicAccountPlanPDF' + param;
        }
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 03/24/2014
** @description : constructor
** @paramaters : none
** @returns : nothing
*/      
    public StrategicAccountPlanCC(ApexPages.StandardController controller){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','StrategicAccountPlanCC') + ' - constructor';
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        PageAccount = (Account)controller.getRecord();        
        AccountId = PageAccount.Id;
        system.debug(LoggingLevel.DEBUG, METHODNAME + '\n\nAccount ID :: ' + AccountId + '\n\n');
        SAModel = new StrategicAccountModel(AccountId);
    }
    
    public class AccountStrategyRow {
        public string productName {get; private set;}
        public string accountName {get; private set;}
        public Id accountId {get; private set;}
        public Id productId {get; private set;}
        //public date endDate {get; private set;}
        //public decimal quantity {get; private set;}
        //public decimal netPrice {get; private set;}               
        public list<AccountStrategyRow> asRow {get; private set;}
        
        public AccountStrategyRow(string accountName, Id accountId) {
            this.accountName = accountName;
            this.accountId = accountId;
            this.asRow = new list<AccountStrategyRow>();
        }
        
        public AccountStrategyRow(string accountName, string productName, Id accountId, Id productId ) {
            this.accountName = accountName;
            this.productName = productName;
            this.accountId = accountId;
            this.productId = productId;
            this.asRow = new list<AccountStrategyRow>();
        }       
        
        public AccountStrategyRow(string productName, string accountName, id productId, id accountId, date endDate, decimal quantity, decimal netPrice) {
            this.productName = productName;
            this.productId = productId;
            this.accountName = accountName;
            this.accountId = accountId;
            this.endDate = endDate;
            this.quantity = quantity;
            this.netPrice = netPrice;
            this.asRow = new list<AccountStrategyRow>();
            
        }
        public double quantity {
          get {
            if (quantity == null  || quantity == 0) {
              quantity = 0;
              if ( asRow.IsEmpty() == false) {
                for (AccountStrategyRow sub : asRow) {
                  quantity += sub.quantity == null ? 0 : sub.quantity;
                }
              }
            }
            return quantity;
          }
          private set;
        }
        public double netPrice {
          get {
            if (netPrice == null  || netPrice == 0) {
              netPrice = 0;
              if ( asRow.IsEmpty() == false) {
                for (AccountStrategyRow sub : asRow) {
                  netPrice += sub.netPrice == null ? 0 : sub.netPrice;
                }
              }
            }
            return netPrice;
          }
          private set;
        }
        public date endDate {
          get {
            date previousDate;
            if (endDate == null) {
              if ( asRow.IsEmpty() == false) {
                for (AccountStrategyRow sub : asRow) {
                  if(previousDate==NULL || previousDate< sub.endDate) {
                      endDate = sub.endDate;
                      previousDate = sub.endDate;
                  }
                }
              }
            }
            return endDate;
          }
          private set;
        }                               
    }
    
    public list<AccountStrategyRow> mAccountStrategyRow;
    public list<AccountStrategyRow> asRowData {
        get {
            mAccountStrategyRow = new list<AccountStrategyRow>();
            AccountStrategyRow detailRows;
            AccountStrategyRow totalRow;
            AccountStrategyRow productGrouping = null;
            AccountStrategyRow oliGrouping = null;
            Id previousProductId = null;
            Id previousOLIId = null;
            datetime previousEndDate = null;
            list<Order_Line_Item__c> oliList = [SELECT NetUnitPrice__c, Quantity__c, EndDate__c,    Product__c, Product__r.Name, Order__c, Order__r.OrderStatus__c, Order__r.Account__c, Order__r.Account__r.Name  
                                                FROM Order_Line_Item__c
                                                WHERE Order__r.Account__c =:AccountId 
                                                AND Order__r.OrderStatus__c In  ('Open - Ecomm','Open','Sent To Verification','Verified','Invoiced','Finance Hold')
                                                order by Order__r.Account__r.Name, Product__c ];
            
            //system.assertequals(oliList[0] , null);
            if(!oliList.isEmpty()) {                                    
                detailRows = new AccountStrategyRow(oliList[0].Order__r.Account__r.Name, oliList[0].Order__r.Account__c);
                totalRow = new AccountStrategyRow(oliList[0].Order__r.Account__r.Name, oliList[0].Order__r.Account__c);
            }                                 
            for(Order_Line_Item__c oli : oliList) {
                if(productGrouping==null || previousProductId!= oli.Product__c) {
                    productGrouping = new AccountStrategyRow(oli.Order__r.Account__r.Name, oli.Product__r.Name, oli.Order__r.Account__c, oli.Product__c);                                        
                    detailRows.asRow.add(productGrouping );
                }
                
                if( previousOLIId!=oli.Id) {
                    oliGrouping = new AccountStrategyRow(oli.Product__r.Name, oli.Order__r.Account__r.Name, oli.Product__c, oli.Order__r.Account__c,  oli.EndDate__c, oli.quantity__c, oli.NetUnitPrice__c);
                    productGrouping.asRow.add(oliGrouping );
                    
                }
                
                previousOLIId = oli.Id;
                previousProductId = oli.Product__c;
                if(oli.quantity__c!=NULL) {
                    totalRow.quantity += oli.quantity__c; 
                }
                if(oli.NetUnitPrice__c!=NULL) {
                    totalRow.netPrice += oli.NetUnitPrice__c; 
                }                
            }
            if(detailRows!=NULL){
                mAccountStrategyRow.add(detailRows);    
            }
            mAccountStrategyRow.add(totalRow);                        
            return mAccountStrategyRow;                                 
        }
        set;
    }   
}