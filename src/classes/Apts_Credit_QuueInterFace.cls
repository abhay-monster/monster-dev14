public class Apts_Credit_QuueInterFace implements Queueable, Database.AllowsCallouts{
    
    private seT<id> OldProposalset;
    
    public Apts_Credit_QuueInterFace(Set<id> ProposalIdsetArge)
    {
        this.OldProposalset = ProposalIdsetArge;
    }
    public void execute(QueueableContext context) {
        APTS_creditHelper oClass = new APTS_creditHelper();
        MAP<id,id> ProposalOrderMap = new MAP<id,id>();
        MAP<id,id> OrderCRMap = new MAP<id,id>();
        MAP<id,id> CRnewOderMap = new MAP<id,id>();
        set<id> Proposalid = new set<id>();
        set<id> orderId = new set<id>();
        List<Apttus_Proposal__Proposal__c> proposalList  = [select id, Orig_Order_link__c 
                                                            FROM Apttus_Proposal__Proposal__c 
                                                            where id = :OldProposalset];
        for(Apttus_Proposal__Proposal__c prop:proposalList)
        {               
            
            
            Proposalid.add(prop.id);
            ProposalOrderMap.put(prop.id, prop.Orig_Order_link__c);  
            orderId.add(prop.Orig_Order_link__c);
            
        }
        
        If(Proposalid.size() >0 )  
        {
            MAP<id,Order__c>  OrderMAP =  APTS_creditHelper.getOrderMAP(orderId);
            list<Credit_Request__c>  CRlist = APTS_creditHelper.GenerateCR(orderId,OrderMAP); 
            
            Insert CRlist; 
            
            
            
            for(Credit_Request__c oTemp: CRlist)
            {
                OrderCRMap.put(oTemp.Order__c, oTemp.id);
            }
            
            
            List<CreditRequestLineItem__c> CRLineItemList = APTS_creditHelper.GenerateLineItems( orderId, ProposalOrderMap,OrderCRMap );
            
            If(CRLineItemList.size() > 0)
            {
                insert CRLineItemList;
            }
            
            list<Credit_Request_License_ID__c> CRLicenseList  = APTS_creditHelper.GenerateLicense(CRLineItemList  );
            if(CRLicenseList.size() > 0)
            {
                insert CRLicenseList;
            }
            
            
            CRlist = [
                        Select id,Name,Order__c,Credit_Type__c 
                        From Credit_Request__c 
                        Where Id In : CRlist
                    ];
            
            list<Order__c> CRorderList  = APTS_creditHelper.GenerateOrder(CRlist, OrderMAP);
            insert CRorderList; 
           
            for(Order__c oTemp: CRorderList)
            {
                CRnewOderMap.put(oTemp.CreditRequest__c, Otemp.id);
            }
            
            List<Order_Line_Item__c> newOLIList = APTS_creditHelper.generateOrderLineItem(CRLineItemList,  CRnewOderMap );
            
            If(newOLIList.size() > 0)
            {
                insert newOLIList;
            }
            
        }
        
        
    }
}