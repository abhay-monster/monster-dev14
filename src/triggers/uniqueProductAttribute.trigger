trigger uniqueProductAttribute on Apttus_Config2__ProductAttributeGroupMember__c (before insert, before update) {

    if(trigger.isBefore){
        Set<Id> prodIdSet = new Set<Id>();
        Set<Id> prodAttrGrpIdSet = new Set<Id>();
        Map<String,List<String>> presentProdAttb = new Map<String,list<String>>();
        //Map<String,List<String>> newProdAttb = new Map<String,List<String>>();
        Map<String,List<String>> presentAttbGrpToAttrbMap = new Map<String,List<String>>();
        //Map<String,List<String>> newAttbGrpToAttrbMap = new Map<String,List<String>>();
        //Map<String,List<String>> presentprodToAttbgrpMap = new Map<String,List<String>>();
        Map<String,List<String>> prodAndAttGrpIdMap = new Map<String,list<String>>();
        
        //List<Apttus_Config2__ProductAttribute__c> presentAttributes = new List<Apttus_Config2__ProductAttribute__c>();
        //List<Apttus_Config2__ProductAttribute__c> newAttributes = new List<Apttus_Config2__ProductAttribute__c>();
        Map<String,List<String>> newProdAndAttGrpIdMap = new Map<String,list<String>>();
        
        for(Apttus_Config2__ProductAttributeGroupMember__c gm : trigger.new){                    
            prodIdSet.add(gm.Apttus_Config2__ProductId__c);
            prodAttrGrpIdSet.add(gm.Apttus_Config2__AttributeGroupId__c);
            
            if(newProdAndAttGrpIdMap.containsKey(gm.Apttus_Config2__ProductId__c)){
                newProdAndAttGrpIdMap.get(gm.Apttus_Config2__ProductId__c).add(gm.Apttus_Config2__AttributeGroupId__c);    
            } else {
                newProdAndAttGrpIdMap.put(gm.Apttus_Config2__ProductId__c, new List<String>{gm.Apttus_Config2__AttributeGroupId__c});
            }
            //prodAndAttGrpMap.put(gm.Apttus_Config2__ProductId__c,gm.Apttus_Config2__AttributeGroupId__c); 
        }
        
        System.debug('[RB] - trigger.new : ' + trigger.new);
        System.debug('[RB] - prodIdSet : ' + prodIdSet);
        System.debug('[RB] - prodAttrGrpIdSet : ' + prodAttrGrpIdSet);
        for(Apttus_Config2__ProductAttributeGroupMember__c grp : trigger.new){
            
            if(prodAndAttGrpIdMap.containsKey(grp.Apttus_Config2__ProductId__c)){
                
                prodAndAttGrpIdMap.get(grp.Apttus_Config2__ProductId__c).add(grp.Apttus_Config2__AttributeGroupId__c);
            } else {
                prodAndAttGrpIdMap.put(grp.Apttus_Config2__ProductId__c, new List<String>{grp.Apttus_Config2__AttributeGroupId__c});
            }
        }
        
        for(Apttus_Config2__ProductAttribute__c attb : [Select Id, Apttus_Config2__AttributeGroupId__c, 
                                    Apttus_Config2__Field__c FROM Apttus_Config2__ProductAttribute__c
                                    WHERE Apttus_Config2__AttributeGroupId__c IN :prodAttrGrpIdSet]){
            if(presentAttbGrpToAttrbMap.containsKey(attb.Apttus_Config2__AttributeGroupId__c)){
                presentAttbGrpToAttrbMap.get(attb.Apttus_Config2__AttributeGroupId__c).add(attb.Apttus_Config2__Field__c);
            } else {
                presentAttbGrpToAttrbMap.put(attb.Apttus_Config2__AttributeGroupId__c, new List<String>{attb.Apttus_Config2__Field__c});
            }
        }
        System.debug('[RB] - prodAndAttGrpIdMap : ' + prodAndAttGrpIdMap);
        System.debug('[RB] - presentAttbGrpToAttrbMap : ' + presentAttbGrpToAttrbMap);
        for(String prodId: prodAndAttGrpIdMap.keySet()){
            if(presentProdAttb.containsKey(prodId)){
                for(String str: prodAndAttGrpIdMap.get(prodId)){
                    if(presentAttbGrpToAttrbMap.size()>0)
                        presentProdAttb.get(prodId).addAll(presentAttbGrpToAttrbMap.get(str));                    
                }                   
            } else {
                List<String> attributes = new List<String>();
                for(String str: prodAndAttGrpIdMap.get(prodId)){
                    if(presentAttbGrpToAttrbMap.size()>0)
                        attributes.addAll(presentAttbGrpToAttrbMap.get(str));                    
                }
                presentProdAttb.put(prodId, attributes);
            }
        }                       
    }
}