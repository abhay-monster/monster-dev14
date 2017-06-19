global class APTPS_BenchDataUtility implements Database.Batchable<sObject>, Database.Stateful
{
    global Database.QueryLocator start( Database.BatchableContext BC ) 
    {
        return Database.getQueryLocator( [Select Id from Apttus_Proposal__Proposal__c
                                          Where Apttus_Proposal__Opportunity__r.Legacy_Opportunity_ID__c  !=null 
                                          AND Apttus_Proposal__Opportunity__r.Opp_Product_Count__c <= 0 
                                          AND Apttus_Proposal__Primary__c = True
                                          AND Proposal_Line_Item_Count__c > 0 
                                         ] );
    }
    global void execute( Database.BatchableContext BC, List<Apttus_Proposal__Proposal__c> ProposalList )
    { 
        If(ProposalList.size() > 0 )
        {
            MAP<id,Apttus_Proposal__Proposal_Line_Item__c> MAPProposalLineItems = LineItemMAP(ProposalList); 
            
            List<Apttus_Proposal__Proposal_Line_Item__c> ProposalListValue =  SalesCredit(MAPProposalLineItems.values()); 
            if(MAPProposalLineItems.size() > 0) {
                ApttusProposalLineItemTriggerHandler.ExecuteTriggers = False;
                Update ProposalListValue; 
                ApttusProposalLineItemTriggerHandler.ExecuteTriggers = True;
                MAPProposalLineItems = LineItemMAP(ProposalList); 
                
                ApttusProposalLineItemTriggerHandler.syncLineItemsWithOpportunityLineItems(MAPProposalLineItems.values(),MAPProposalLineItems);
            }
            
        }
    }
    
    global void finish( Database.BatchableContext BC )
    {
        
    }
    
    
    public  MAP<id,Apttus_Proposal__Proposal_Line_Item__c>  LineItemMAP(List<Apttus_Proposal__Proposal__c> ProposalList)
    {
        MAP<id,Apttus_Proposal__Proposal_Line_Item__c> MAPProposalLineItems = new  MAP<id,Apttus_Proposal__Proposal_Line_Item__c>
            ([SELECT Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__c ,
              Apttus_Proposal__Product__c ,Apttus_QPConfig__OptionId__c, Apttus_QPConfig__HasOptions__c,
              Gross_Total__c ,
              Net_Total__c ,
              Apttus_Proposal__Proposal__r.Organization__c,
              Quantity1__c ,
              Apttus_Proposal__Proposal__c,
              Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__r.CurrencyIsoCode,
              Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__r.Organization__c,
              Apttus_QPConfig__IsOptionRollupLine__c,
              Rev_Share_Amount__c,
              Sales_Credit__c ,
              Rev_Share__c,
              Rev_Share_Type__c
              From Apttus_Proposal__Proposal_Line_Item__c
              where Apttus_Proposal__Proposal__c  IN :ProposalList
             ]);
        return MAPProposalLineItems;
    }
    public List<Apttus_Proposal__Proposal_Line_Item__c> SalesCredit(List<Apttus_Proposal__Proposal_Line_Item__c> pUpdatedLineItems){
        set<id> products = new set<id>();
        MAP<id,product2> ProductMAP ;
        for(Apttus_Proposal__Proposal_Line_Item__c pli : pUpdatedLineItems)
        {
            products.add(pli.Apttus_Proposal__Product__c);
            
            If(pli.Apttus_QPConfig__OptionId__c != null)
            {
                products.add(pli.Apttus_QPConfig__OptionId__c);
            }
        }
        
        ProductMAP =  new MAP<id,product2>([select  id,APTPS_Rev_Share__c,APTPS_Rev_Share_Type__c
                                            FROM product2 where id = :products]);  
        System.debug ('ProductMAP'+ProductMAP) ;
        for(Apttus_Proposal__Proposal_Line_Item__c pli : pUpdatedLineItems)
        {
            System.debug ('pli.Apttus_QPConfig__OptionId__c'+pli.Apttus_QPConfig__OptionId__c) ;
            
            If(pli.Apttus_QPConfig__OptionId__c != null)
            {
                If(ProductMAP.containsKey(pli.Apttus_QPConfig__OptionId__c))
                {
                    pli.Rev_Share__c= ProductMAP.get(pli.Apttus_QPConfig__OptionId__c).APTPS_Rev_Share__c;
                    pli.Rev_Share_Type__c= ProductMAP.get(pli.Apttus_QPConfig__OptionId__c).APTPS_Rev_Share_Type__c;
                }
            }
            else
            {
                If(ProductMAP.containsKey(pli.Apttus_Proposal__Product__c))
                {
                    pli.Rev_Share__c= ProductMAP.get(pli.Apttus_Proposal__Product__c).APTPS_Rev_Share__c;
                    pli.Rev_Share_Type__c= ProductMAP.get(pli.Apttus_Proposal__Product__c).APTPS_Rev_Share_Type__c;
                }
            }
            System.debug ('pli.Rev_Share_Type__c'+pli.Rev_Share_Type__c) ;
            System.debug ('pli.Net_Total__c'+pli.Net_Total__c) ;
            System.debug ('pli.Gross_Total__c'+pli.Gross_Total__c) ;
           
            If(pli.Rev_Share_Type__c !=null && pli.Rev_Share__c!=null) // I-215209 changes , added null check
            {
                
                Decimal Revshare  = 0 ;
                IF(pli.Rev_Share_Type__c == 'Net')
                {
                    Revshare = pli.Net_Total__c * pli.Rev_Share__c;
                }
                else if(pli.Rev_Share_Type__c== 'Gross' )
                {
                    Revshare = pli.Gross_Total__c * pli.Rev_Share__c;
                }
                System.debug ('pli.Revshare'+Revshare) ;
                pli.Sales_Credit__c  = pli.Net_Total__c - (Revshare/100); 
            }
            else
            {   pli.Sales_Credit__c = 0;
             pli.Sales_Credit__c =pli.Net_Total__c ;
            }
        }
        
        return pUpdatedLineItems;
    }
    
    
    
}