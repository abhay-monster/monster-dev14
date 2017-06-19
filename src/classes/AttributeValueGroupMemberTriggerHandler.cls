public class AttributeValueGroupMemberTriggerHandler {
    
    //public static void RollupNamesToList(Set<ID> avgmIds, Set<Id> attValueIds, List<Attribute_Value_Group_Member__c> groupMembersList){
    
    public static void RollupNamesToList(Set<ID> avgmIds){
    
        Map<String,Map<String,String>> productAttributeMap = new Map<String,Map<String,String>>(); // Map of AVG Id to Map of Product Attribute Name and Values concatenated as String.
        Map<String,Map<String,String>> proposalAttributeMap = new Map<String,Map<String,String>>(); // Map of AVG Id to Map of Product Attribute Name and Values concatenated as String.
        Map<String,String> finalProdAttMap = new Map<String,String>(); // Map of AVG Record Id to final product indexing string.
        Map<String,String> finalProposalAttMap = new Map<String,String>(); // Map of AVG Record Id to final proposal indexing string.
        List<Attribute_Value_Group__c> updateAVGList = new List<Attribute_Value_Group__c>(); // List of Attribute Value Group records tobe updated.
        Map<String,Integer> attributeSequenceMap = getAttributeSequenceMap();
        Set<Id> avgIdSet = new Set<Id>();
        List<String> sortedProductAttributes;
        List<String> sortedProposalAttributes;
        System.debug('****** attributeSequenceMap: '+attributeSequenceMap);
        
        for(Attribute_Value_Group_Member__c avgm: [Select Id, Attribute_Value__c, Attribute_Value_Group__c, Attribute_Record_Value__c, Attribute_Value_Name__c, Attribute_Value_Type__c, Attribute_Value_Sequence__c From Attribute_Value_Group_Member__c Where Id IN:avgmIds ORDER BY Attribute_Value_Sequence__c]){
            avgIdSet.add(avgm.Attribute_Value_Group__c);
        }
        // Rewriting the query in the for loop to Query the attribute group member records in a sequence. Sequence is specified in the Formula field in the object.
        for(Attribute_Value_Group_Member__c gm: [Select Id, Attribute_Value__c, Attribute_Value_Group__c, Attribute_Record_Value__c, Attribute_Value_Name__c, Attribute_Value_Type__c, Attribute_Value_Sequence__c From Attribute_Value_Group_Member__c Where Attribute_Value_Group__c IN:avgIdSet ORDER BY Attribute_Value_Sequence__c]){
            System.debug('********* gm: '+gm);
            
            // Constructing the productAttributeMap in the if condition.
            if(gm.Attribute_Value_Type__c == 'Product'){
                System.debug('****** gm.Attribute_Value_Type__c: '+gm.Attribute_Value_Type__c);
                System.debug('****** productAttributeMap: '+productAttributeMap);
                if(productAttributeMap.containsKey(gm.Attribute_Value_Group__c)){
                    if(productAttributeMap.get(gm.Attribute_Value_Group__c).containsKey(gm.Attribute_Value_Name__c) && !productAttributeMap.get(gm.Attribute_Value_Group__c).get(gm.Attribute_Value_Name__c).contains(gm.Attribute_Record_Value__c)){
                        String str = productAttributeMap.get(gm.Attribute_Value_Group__c).get(gm.Attribute_Value_Name__c);
                        str = str + ',' + gm.Attribute_Record_Value__c;
                        productAttributeMap.get(gm.Attribute_Value_Group__c).put(gm.Attribute_Value_Name__c, str);
                        
                        System.debug('****** productAttributeMap: '+productAttributeMap);
                    } else {
                        productAttributeMap.get(gm.Attribute_Value_Group__c).put(gm.Attribute_Value_Name__c, gm.Attribute_Record_Value__c);
                    }
                } else {
                    
                    Map<String,String> attributeMap = new Map<String,String>();
                    attributeMap.put(gm.Attribute_Value_Name__c, gm.Attribute_Record_Value__c);
                    productAttributeMap.put(gm.Attribute_Value_Group__c,attributeMap);
                }
                System.debug('****** productAttributeMap: '+productAttributeMap);
            // Constructing the proposalAttributeMap in the else if condition.
            } else if(gm.Attribute_Value_Type__c == 'Proposal'){
                
                if(proposalAttributeMap.containsKey(gm.Attribute_Value_Group__c)){
                    /*if(!proposalAttributeMap.get(gm.Attribute_Value_Group__c).containsKey(gm.Attribute_Value_Name__c)){
                        proposalAttributeMap.get(gm.Attribute_Value_Group__c).put(gm.Attribute_Value_Name__c, gm.Attribute_Record_Value__c);
                    }*/
                    if(proposalAttributeMap.get(gm.Attribute_Value_Group__c).containsKey(gm.Attribute_Value_Name__c) && !proposalAttributeMap.get(gm.Attribute_Value_Group__c).get(gm.Attribute_Value_Name__c).contains(gm.Attribute_Record_Value__c)){
                        String str = proposalAttributeMap.get(gm.Attribute_Value_Group__c).get(gm.Attribute_Value_Name__c);
                        str = str + ',' + gm.Attribute_Record_Value__c;
                        proposalAttributeMap.get(gm.Attribute_Value_Group__c).put(gm.Attribute_Value_Name__c, str);
                        
                        
                    } else {
                        proposalAttributeMap.get(gm.Attribute_Value_Group__c).put(gm.Attribute_Value_Name__c, gm.Attribute_Record_Value__c);
                    }
                } else {
                    
                    //gm.addError('Test--->'+gm.Attribute_Value_Group__c+'--->'+gm.Attribute_Value_Name__c);
                    Map<String,String> attributeMap = new Map<String,String>();
                    attributeMap.put(gm.Attribute_Value_Name__c, gm.Attribute_Record_Value__c);
                    proposalAttributeMap.put(gm.Attribute_Value_Group__c,attributeMap);
                }
            } // End of IF Condition.... 
        } // End of For Loop.....
        
        if(!productAttributeMap.isEmpty())
            for(String key: productAttributeMap.keySet()){
                sortedProductAttributes = new List<String>();
                for(String attKey: productAttributeMap.get(key).keySet()){
                    addAttributes(sortedProductAttributes, attKey, attributeSequenceMap);
                }
                
                if(sortedProductAttributes.size()>0){
                    String format = '';
                    for(String attribute: sortedProductAttributes){
                        format = format + attribute + ' = '+ productAttributeMap.get(key).get(attribute) + ';';
                    }
                    finalProdAttMap.put(key,format);
                }
            }
        System.debug('************** finalProdAttMap: '+finalProdAttMap);
         
        if(!proposalAttributeMap.isEmpty())
            for(String key: proposalAttributeMap.keySet()){
                sortedProposalAttributes = new List<String>();
                for(String attKey: proposalAttributeMap.get(key).keySet()){
                    addAttributes(sortedProposalAttributes, attKey, attributeSequenceMap);
                }
                
                String format = '';
                    for(String attribute: sortedProposalAttributes){
                        format = format + attribute + ' = '+ proposalAttributeMap.get(key).get(attribute) + ';';
                    }
                    finalProposalAttMap.put(key,format);
                
                if(sortedProductAttributes!=null && sortedProductAttributes.size()>0){
                    }
            }
            
        
        for(String avgKey: finalProdAttMap.keySet()){
            
            Attribute_Value_Group__c avg = new Attribute_Value_Group__c();
            avg.Id = avgKey;
            avg.Indexing_Key__c = 'Product:'+ finalProdAttMap.get(avgKey);
            
            if(finalProposalAttMap.containsKey(avgKey)){
                avg.Indexing_Key__c = avg.Indexing_Key__c + ' '+ 'Proposal:'+ finalProposalAttMap.get(avgKey);
            }
            
            updateAVGList.add(avg);
            
            finalProdAttMap.remove(avgKey);
            finalProposalAttMap.remove(avgKey);
        }
        
        if(finalProdAttMap.size()>0){
            for(String avgKey: finalProdAttMap.keySet()){
                Attribute_Value_Group__c avg = new Attribute_Value_Group__c();
                avg.Id = avgKey;
                avg.Indexing_Key__c = 'Product:'+ finalProdAttMap.get(avgKey);
                updateAVGList.add(avg);
            }
        }
        
        if(finalProposalAttMap.size()>0){
            for(String avgKey: finalProposalAttMap.keySet()){
                Attribute_Value_Group__c avg = new Attribute_Value_Group__c();
                avg.Id = avgKey;
                avg.Indexing_Key__c = 'Proposal:'+ finalProposalAttMap.get(avgKey);
                updateAVGList.add(avg);
            }
        }
        
        try{
            update updateAVGList;
        } Catch(exception e){
            system.debug('********* exception e: '+e.getMessage());
        }
    }
    
    /**Constructing the attributeSequenceMap. This map will contain the API Names of Product and Proposal fields as the key
          *and the sequence number from the Product Attribute Object as the value. */
    public static Map<String,Integer> getAttributeSequenceMap(){
        
        Map<String,Integer> sequenceMap = new Map<String,Integer>();
        for(Apttus_Config2__ProductAttribute__c prod: [Select Apttus_Config2__Field__c, Apttus_Config2__Sequence__c, IsProposalAttribute__c From Apttus_Config2__ProductAttribute__c ORDER BY Apttus_Config2__Sequence__c]){
            sequenceMap.put(prod.Apttus_Config2__Field__c, Integer.valueOf(prod.Apttus_Config2__Sequence__c));
        }
        
        return sequenceMap;
    }
    
    public static String sortAttributesList(List<Attribute_Value__c> attributeList){
        
        Map<String,String> productFieldsMap = new Map<String,String>();
        Map<String,String> proposalFieldsMap = new Map<String,String>();
        List<String> sortedProductAttributes = new List<String>();
        List<String> sortedProposalAttributes = new List<String>();
        Map<String,Integer> attSeqMap = getAttributeSequenceMap();
        String productFormat = '';
        String proposalFormat = '';
        String returnString = '';
        for(Attribute_Value__c value: attributeList){
            String str = '';                        
            if(value.Attribute_Type__c == 'Product'){
               /*if(!productFieldsMap.containsKey(value.Attributes_Name__c)){
                   productFieldsMap.put(value.Attributes_Name__c, value.Attribute_Values__c);
               } */
               if(productFieldsMap.containsKey(value.Attributes_Name__c) && !productFieldsMap.get(value.Attributes_Name__c).contains(value.Attribute_Values__c)){
                   str = productFieldsMap.get(value.Attributes_Name__c);
                   str = str + ',' + value.Attribute_Values__c;
                   productFieldsMap.put(value.Attributes_Name__c,str); 
               } else {
                   productFieldsMap.put(value.Attributes_Name__c, value.Attribute_Values__c);       
               }
            } else if(value.Attribute_Type__c == 'Proposal'){
                /*if(proposalFieldsMap.containsKey(value.Attributes_Name__c)){
                    proposalFieldsMap.put(value.Attributes_Name__c, value.Attribute_Values__c);
                }  */  
                if(proposalFieldsMap.containsKey(value.Attributes_Name__c) && !proposalFieldsMap.get(value.Attributes_Name__c).contains(value.Attribute_Values__c)){
                   str = proposalFieldsMap.get(value.Attributes_Name__c);
                   str = str + ',' + value.Attribute_Values__c;
                   proposalFieldsMap.put(value.Attribute_Type__c,str); 
               } else {
                   proposalFieldsMap.put(value.Attributes_Name__c, value.Attribute_Values__c);       
               }                
            } // End of if else ladder.
        } // End of for loop.
        
        System.debug('*********** attributeList: '+attributeList);
        System.debug('*********** productFieldsMap: '+productFieldsMap);
        System.debug('*********** proposalFieldsMap: '+proposalFieldsMap);
        for(String attKey: productFieldsMap.keySet()){
            addAttributes(sortedProductAttributes, attKey, attSeqMap);
        }
        
        if(sortedProductAttributes.size()>0){
            productFormat = 'Product:';
            for(String attribute: sortedProductAttributes){
                productFormat = productFormat + attribute + ' = '+ productFieldsMap.get(attribute) + ';';
            }
        }
        
        for(String attKey: proposalFieldsMap.keySet()){
            addAttributes(sortedProposalAttributes, attKey, attSeqMap);
        }
        
        if(sortedProposalAttributes.size()>0){
            proposalFormat = 'Proposal:';
            for(String attribute: sortedProposalAttributes){
                proposalFormat = proposalFormat + attribute + ' = '+ proposalFieldsMap.get(attribute) + ';';
            }
        }
        
        returnString = productFormat;
        if(!String.isBlank(proposalFormat)){
            returnString = returnString + ' ' + proposalFormat;
        }
        
        return returnString;
    }
    
    
    public static void addAttributes(List<String> attributes, String newAttribute, Map<String,Integer> attributeSequenceMap) {
        Integer position = attributes.size();
        for (Integer i = 0; i < attributes.size(); i++) {
            if (attributeSequenceMap.get(newAttribute) < attributeSequenceMap.get(attributes[i])) {
                position = i;
                break;
            }
        }
        
        if (position == attributes.size()) {
            attributes.add(newAttribute);
        } else {
            attributes.add(position, newAttribute);
        }
    }
    /*
    
    Apttus Inc 
    Create the AVGs, Associate to PARD, Assoicate to products from AVGMs
    
    */


public static void UpsertMemberParents(list<Attribute_Value_Group_Member__c> newList)
    {

    Attribute_Value_Group__c CAVG = null;
    Attribute_Value_Group__c DAVG = null;
    Map<Decimal, Product_Attribute_Rule_Definitions__c> mapAVGMPard = new Map<Decimal, Product_Attribute_Rule_Definitions__c>();


    Set<String> setUniqueAVs = new Set<String>();

     for(Attribute_Value_Group_Member__c AVGM: newList)
     {     

      System.debug('AVGM With 2 ' + AVGM);
      Product2 Product1 =[select id,name,
                        (select id,name,
                                Controlling_Attribute_Value_Group__c,
                                Dependent_Attribute_Value_Group__c,
                                Sequence__c
                         from Product_Attribute_Rule_Definition__r) 
                        from product2 where productCode=:AVGM.Product_Code__c LIMIT 1];

        Product_Attribute_Rule_Definitions__c PARD = null;



        //List<Product_Attribute_Rule_Definitions__c> listNewPards = new List<Product_Attribute_Rule_Definitions__c>();

        
        for(Product_Attribute_Rule_Definitions__c ProdPard:product1.getSObjects('Product_Attribute_Rule_Definition__r') )
        {

            setUniqueAVs.add(AVGM.Product_Code__c + 
                            String.ValueOf(Integer.valueOf(AVGM.PARD__c)) + 
                            String.ValueOf(AVGM.Attribute_Value__c).left(15)  +
                            String.ValueOf(AVGM.Group_Record_Identifier__c)

                            );

            System.debug('INSIDE PRODUCT LOOP' + ProdPard);
            System.debug('INSIDE PRODUCT LOOP AVGM ' + AVGM.PARD__c);
            if ((ProdPard != null)){
                if(ProdPard.sequence__c==AVGM.PARD__c)
                {
                    PARD=ProdPard;
                    mapAVGMPard.put(AVGM.PARD__c, ProdPard);

                } else {

                }
            }
        }

        System.debug('PARD Outside PARD == NULL' + PARD);

        if (PARD == null){

            List<Attribute_Value_Group__c> listAVG = new List<Attribute_Value_Group__c>();
            //Attribute_Value_Group__c AVG1 = new Attribute_Value_Group__c();
            //Attribute_Value_Group__c AVG2 = new Attribute_Value_Group__c();
            CAVG = new Attribute_Value_Group__c();
            DAVG = new Attribute_Value_Group__c();

            listAVG.add(CAVG);
            listAVG.add(DAVG);

            System.debug('LIST SIZE' + listAVG);

            insert listAVG;

            Product_Attribute_Rule_Definitions__c newPard = new Product_Attribute_Rule_Definitions__c();
            newPard.Primary_Product__c = product1.id;
            newPard.Sequence__c = AVGM.PARD__c;
            newPard.Action__c = 'include';
            newPard.Active__c = true;
            newPard.Controlling_Attribute_Value_Group__c = CAVG.id;
            newPard.Dependent_Attribute_Value_Group__c = DAVG.id;

            insert newPard;

            if(AVGM.Group_Record_Identifier__c=='CTRL'){

            System.Debug('INSERT DATA ' + AVGM);
            //AVGM.Attribute_Value_Group__c=   PARD.Controlling_Attribute_Value_Group__c;
                AVGM.Attribute_Value_Group__c = CAVG.id;
            } 
            if (AVGM.Group_Record_Identifier__c=='DEP'){
            //AVGM.Attribute_Value_Group__c=PARD.Dependent_Attribute_Value_Group__c;
            AVGM.Attribute_Value_Group__c = DAVG.id;
            }


        }




            System.debug('AVGM' + AVGM);



     }

     System.debug('SETUU' + setUniqueAVs);
     LIST<Attribute_Value_Group_Member__c>
        listAVGM = [Select Id, name, UniqueAV__c from Attribute_Value_Group_Member__c 
        WHERE UniqueAV__c IN : setUniqueAVs];

    DELETE listAVGM;


    Product_Attribute_Rule_Definitions__c pard2;
    for (Attribute_Value_Group_Member__c AVGM: newList){
        pard2 = mapAVGMPard.get(AVGM.PARD__c);

        List<Attribute_Value_Group__c> listAVG = new List<Attribute_Value_Group__c>();

        system.debug('AVGM 2' + AVGM);

        if (AVGM.Group_Record_Identifier__c == 'CTRL'){
            if (pard2.Controlling_Attribute_Value_Group__c == null){
                CAVG = new Attribute_Value_Group__c();
                insert CAVG;
                AVGM.Attribute_Value_Group__c = CAVG.id;
            } else {
                AVGM.Attribute_Value_Group__c =  pard2.Controlling_Attribute_Value_Group__c;
            }
        }

        if (AVGM.Group_Record_Identifier__c == 'DEP' ){

            if (pard2.Dependent_Attribute_Value_Group__c == null){
                DAVG = new Attribute_Value_Group__c();
                insert DAVG;
                AVGM.Attribute_Value_Group__c = DAVG.Id;
            }  else {
                AVGM.Attribute_Value_Group__c =  pard2.Dependent_Attribute_Value_Group__c;
            }
        }

        
        //Id ctrlAVG = 

    }



  }

 public static void UpsertMemberParents2(list<Attribute_Value_Group_Member__c> newList)
    {

    Attribute_Value_Group__c CAVG = null;
    Attribute_Value_Group__c DAVG = null;
    Map<Decimal, Product_Attribute_Rule_Definitions__c> mapAVGMPard = new Map<Decimal, Product_Attribute_Rule_Definitions__c>();
    Map<String, Attribute_Value_Group_Member__c> mapExistingAVGM = new Map<String, Attribute_Value_Group_Member__c>();

     for(Attribute_Value_Group_Member__c AVGM: newList)
     {     

      System.debug('AVGM With 2 ' + AVGM);
      Product2 Product1 =[select id,name,
                        (select id,name,
                                Controlling_Attribute_Value_Group__c,
                                Dependent_Attribute_Value_Group__c,
                                Sequence__c
                         from Product_Attribute_Rule_Definition__r) 
                        from product2 where productCode=:AVGM.Product_Code__c LIMIT 1];

        Product_Attribute_Rule_Definitions__c PARD = null;



        //List<Product_Attribute_Rule_Definitions__c> listNewPards = new List<Product_Attribute_Rule_Definitions__c>();

        
        for(Product_Attribute_Rule_Definitions__c ProdPard:product1.getSObjects('Product_Attribute_Rule_Definition__r') )
        {

            System.debug('INSIDE PRODUCT LOOP' + ProdPard);
            System.debug('INSIDE PRODUCT LOOP AVGM ' + AVGM.PARD__c);
            if ((ProdPard != null)){
                if(ProdPard.sequence__c==AVGM.PARD__c)
                {
                    PARD=ProdPard;
                    mapAVGMPard.put(AVGM.PARD__c, ProdPard);

                } else {

                }
            }
        }

        System.debug('PARD Outside PARD == NULL' + PARD);

        if (PARD == null){

            List<Attribute_Value_Group__c> listAVG = new List<Attribute_Value_Group__c>();
            //Attribute_Value_Group__c AVG1 = new Attribute_Value_Group__c();
            //Attribute_Value_Group__c AVG2 = new Attribute_Value_Group__c();
            CAVG = new Attribute_Value_Group__c();
            DAVG = new Attribute_Value_Group__c();

            listAVG.add(CAVG);
            listAVG.add(DAVG);

            System.debug('LIST SIZE' + listAVG);

            insert listAVG;

            Product_Attribute_Rule_Definitions__c newPard = new Product_Attribute_Rule_Definitions__c();
            newPard.Primary_Product__c = product1.id;
            newPard.Sequence__c = AVGM.PARD__c;
            newPard.Action__c = 'include';
            newPard.Active__c = true;
            newPard.Controlling_Attribute_Value_Group__c = CAVG.id;
            newPard.Dependent_Attribute_Value_Group__c = DAVG.id;

            insert newPard;

            if(AVGM.Group_Record_Identifier__c=='CTRL'){

            System.Debug('INSERT DATA ' + AVGM);
            //AVGM.Attribute_Value_Group__c=   PARD.Controlling_Attribute_Value_Group__c;
                AVGM.Attribute_Value_Group__c = CAVG.id;
            } 
            if (AVGM.Group_Record_Identifier__c=='DEP'){
            //AVGM.Attribute_Value_Group__c=PARD.Dependent_Attribute_Value_Group__c;
                AVGM.Attribute_Value_Group__c = DAVG.id;
            }


        }




            System.debug('AVGM' + AVGM);



     }



    Product_Attribute_Rule_Definitions__c pard2;
    for (Attribute_Value_Group_Member__c AVGM: newList){
        pard2 = mapAVGMPard.get(AVGM.PARD__c);

        System.debug('Pard88' + Pard2);
        System.debug('Map AVGM Size' + mapAVGMPard.size());

        List<Attribute_Value_Group__c> listAVG = new List<Attribute_Value_Group__c>();

        if (AVGM.Group_Record_Identifier__c == 'CTRL'){
            if (pard2.Controlling_Attribute_Value_Group__c == null){
                CAVG = new Attribute_Value_Group__c();
                insert CAVG;
                AVGM.Attribute_Value_Group__c = CAVG.id;
            } else {
               AVGM.Attribute_Value_Group__c =  pard2.Controlling_Attribute_Value_Group__c;
            }
        }

        if (AVGM.Group_Record_Identifier__c == 'DEP' ){

            if (pard2.Dependent_Attribute_Value_Group__c == null){
                DAVG = new Attribute_Value_Group__c();
                insert DAVG;
                AVGM.Attribute_Value_Group__c = DAVG.Id;
            }  else {
                AVGM.Attribute_Value_Group__c =  pard2.Dependent_Attribute_Value_Group__c;
            }
        }

        
        //Id ctrlAVG = 

    }



  }





 
}