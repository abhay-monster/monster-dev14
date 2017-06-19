trigger APTS_updateEscalationChain on Apttus_Approval__Approval_Request__c (before update) {
    for(Apttus_Approval__Approval_Request__c req : trigger.oldMap.values()){
        Apttus_Approval__Approval_Request__c newReq = trigger.newMap.get(req.id);
        if(req.Apttus_Approval__Object_Type__c.ToLowerCase().equalsIgnoreCase('apttus_config2__productconfiguration__c')
           && req.Apttus_Approval__EscalateToId__c != newReq.Apttus_Approval__EscalateToId__c 
           && String.IsBlank(req.Apttus_Approval__EscalateToChain__c) 
           && String.IsBlank(newReq.Apttus_Approval__EscalateToChain__c)){
               
               newReq.Is_Escalated_To_User__c = true;
               
           }
        
    }
}