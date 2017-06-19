trigger APTS_attachment on Attachment (before insert) {
    
    if(Trigger.IsBefore && Trigger.IsInsert)
    {
        set<id> ParentIds = new set<id>();
        Boolean bFNameSigned = false;
            
        For(Attachment oTemp : Trigger.New)
        {
            if(oTemp.ParentId.getSObjectType() == Apttus_Proposal__Proposal__c.getsObjectType())                                 
            {
                ParentIds.add(oTemp.ParentId); 
                //mapPropIDToDescription.put(oTemp.ParentId, oTemp.Description);               
            }
        }
        MAP<id,Apttus_Proposal__Proposal__c> ProposalMap = new MAP<id,Apttus_Proposal__Proposal__c>(
                                                                    [select id ,name, QuoteDocNo__c
                                                                     from Apttus_Proposal__Proposal__c 
                                                                        where id =:ParentIds]
                                                                                );
        If(ProposalMap.size() > 0 )
        {
         For(Attachment oTemp : Trigger.New)
        {
            if(oTemp.ParentId.getSObjectType() == Apttus_Proposal__Proposal__c.getsObjectType())                                 
            {
                string sDate= string.valueof(DateTime.now());
                sDate = sDate.replace('-', '');
                sDate = sDate.replace(':', '');
                sDate = sDate.replace(' ', '');
                Apttus_Proposal__Proposal__c OQuote  = ProposalMap.get(oTemp.ParentId);
                if(string.isblank(oTemp.Description) )
                {
                    oTemp.Description ='';
                }
               oTemp.Description = oTemp.Description +' '+ OQuote.QuoteDocNo__c;
               OQuote.QuoteDocNo__c = OQuote.name +' ' +sDate+'Z';
                
               if(oTemp.Name.contains('signed'))
                   bFNameSigned = true;
            } 
        }
        //FutureMethodUpdatePropFrmAtt.processRecords(ParentIds);
        
        if(!bFNameSigned)
        	Update ProposalMap.values();
       }
        
    }

}