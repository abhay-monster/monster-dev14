public with sharing class productRuleHelper {
	
	class AttributeException Extends Exception
	{}
	// Can only maintain the heap for a single bundle at a time because the query should be given 
	// the query should be given list of options with relevant bundle
	public static map<Id,productRuleInfo> productRuleMap=new map<Id,productRuleInfo>();
    Static list<Id> attValueGroupIdList=new list<Id>();
	
	/*
	 This method queries for the pard and realted attribute value groups and related attribute value group members
	
	*/
	public static map<Id,productRuleInfo> QueryPardRulesByOptions(List<Id> options,set<Id> optionGroupIdset)
	{
		/*list<Product_Attribute_Rule_Definitions__c> prodPardList = [SELECT Id,Name,
                                                                    Controlling_Attribute_Value_Group__c,
                                                                    Dependent_Attribute_Value_Group__c,Hide__c,
                                                                    Primary_Product__c,
                                                                    Action__c,
                                                                    Leading_Produc_Option__c,
                                                                    Leading_Product_Option_Group__c
                                                                    FROM Product_Attribute_Rule_Definitions__c 
                                                                    Where (Primary_Product__c IN:options  
                                                                    OR Bundle_Product__c= : BundleId) and active__c=true 
                                                                    order by sequence__c
                                                                    ];*/
       /* list<Product_Attribute_Rule_Definitions__c> prodPardList = [SELECT Id,Primary_Product__r.name,Bundle_Product__r.name,Name,sequence__c,
																	Controlling_Attribute_Value_Group__r.name,
																	Dependent_Attribute_Value_Group__r.name,Hide__c,
																	Action__c,
																	Leading_Produc_Option__c,Leading_Product_Option_Group__c
																	FROM Product_Attribute_Rule_Definitions__c 
																	Where ((Primary_Product__c IN :Options
																	         and Bundle_Product__c=null
																	        ) 
																			OR 
																		   (Bundle_Product__c= :BundleId 
																			    and Primary_Product__c IN :Options
																			   )
																			) 																	
																		  and active__c=true 
																		  order by primary_product__c ,bundle_product__c nulls first ,sequence__c 
	                                                                ];*/
	                                                                
	      list<Product_Attribute_Rule_Definitions__c> prodPardList=[SELECT Id,Name,
                                                                    bundle_product__r.name,Primary_Product__r.name,
                                                                    Controlling_Attribute_Value_Group__c,
                                                                    Dependent_Attribute_Value_Group__c ,
                                                                    Hide__c,
                                                                    Primary_Product__c,
                                                                    Action__c,
                                                                    sequence__c,
                                                                    Leading_Produc_Option__c,Leading_Product_Option_Group__c,
                                                                    active__c
                                                                    FROM Product_Attribute_Rule_Definitions__c 
                                                                    Where active__c=true and
                                                                    ((Primary_Product__c IN:options  and Product_Option_Group__c=null) 
                                                                      or
                                                                     (Primary_Product__c IN:options and Product_Option_Group__c IN: optionGroupIdset)
                                                                    )
                                                                    order by Primary_Product__c,Product_Option_Group__c nulls first,sequence__c];                                                           
	                                                                
	     Apexpages.addMessage(new apexpages.Message(apexpages.severity.info,'-->'+prodPardlist.size()));                                                           
	    /*list<Product_Attribute_Rule_Definitions__c> prodPardList = [SELECT Id,Primary_Product__r.name,Bundle_Product__r.name,Name,sequence__c,
		 															Controlling_Attribute_Value_Group__r.name,
																	Dependent_Attribute_Value_Group__r.name,Hide__c,
																	Action__c,
																	Leading_Produc_Option__c,Leading_Product_Option_Group__c
																	FROM Product_Attribute_Rule_Definitions__c 
                           Where Primary_Product__c ='01tq0000000dpU2'
                           
                           and active__c=true order by sequence__c];*/
	    //apexpages.addMessage(new apexpages.Message(apexpages.severity.error,'pard size:'+prodPardList.size()));
	                                                                
        /*
          populate the pard map: attValGrpByPardId
        */
        for(Product_Attribute_Rule_Definitions__c  pard:prodPardList ) 
        {
         if(productRuleMap.containsKey(pard.Primary_Product__c))
         {
          productRuleInfo prodruleinstance=productRuleMap.get(pard.Primary_Product__c);
          prodruleinstance.addPardInfo(pard);
         }
         else
         {
          productRuleInfo prodruleinstance=new productRuleInfo();
          prodruleinstance.addPardInfo(pard);
          productRuleMap.put(pard.Primary_Product__c,prodruleinstance);
         }
        }  
        
        /*
          get the list of attrite value group ids to query attribute value members for product rule wrapper
        */
        for(Id productId:productRuleMap.keyset() )
        {
         productRuleInfo prodRuleInfo=productRuleMap.get(productId);
         for(Id pardId:prodRuleInfo.attValGrpByPardId.keyset())
         {
         	list<Id> avgIds=prodRuleInfo.attValGrpByPardId.get(pardId);
         	attValueGroupIdList.addALL(avgIds);
         }
         //list<Id> attvalueGroupIds=prodRuleInfo.attValGrpByPardId.values();
        }  
        
        System.debug('MS Test attValueGroupIdList'+attValueGroupIdList);
        /* MS- START
        map<Id,Attribute_Value_Group__c> attValGroupMemberMap=new map<Id,Attribute_Value_Group__c>([select id,name,
                                                    (select id,name,
                                                     Attribute_Value_Name__c,Attribute_Record_Value__c,Attribute_Value_Type__c
                                                     from 
                                                     Attribute_Value_Junction_Objects__r)
                                                    from Attribute_Value_Group__c
                                                    where Id In:attValueGroupIdList ]);  
		MS-END */
        MAP<id,List<Attribute_Value_Group_Member__c>> MAPAVGM = new MAP<id,List<Attribute_Value_Group_Member__c>>();
        For( Attribute_Value_Group_Member__c oAVM : [select id,name,Attribute_Value_Group__c,
                                                     Attribute_Value_Name__c,Attribute_Record_Value__c,Attribute_Value_Type__c
                                                	FROM Attribute_Value_Group_Member__c 
                                                	WHERE Attribute_Value_Group__c in :attValueGroupIdList])
            {
                If(MAPAVGM.containsKey(oAVM.Attribute_Value_Group__c))
                {
                    MAPAVGM.get(oAVM.Attribute_Value_Group__c).add(oAVM);
                }
                else
                {
                    MAPAVGM.put(oAVM.Attribute_Value_Group__c, new list<Attribute_Value_Group_Member__c>{oAVM});
                }
            }
        
        for(Id productId:productRuleMap.keyset())
        {
         productRuleInfo prodRuleInfo=productRuleMap.get(productId);
         //list<Id> avgIds=prodRuleInfo.attValGrpByPardId.get(pardId);
         for(Id pardId:prodRuleInfo.attValGrpByPardId.keyset())
         {
         //system.assert(pardId==null,'Id Is null'+PardId);
         //Attribute_Value_Group__c avg=prodRuleInfo.attValGrpByPardId.get(pardId);
         for(Id avgId: prodRuleInfo.attValGrpByPardId.get(pardId))
         {
          //system.assert(avgId!=null,'AVGId is null for pard'+ pardId);
         // prodRuleInfo.populateGroupMembersmap(attValGroupMemberMap.get(avgId)); - MS
           prodRuleInfo.populateGroupMembersmap2(avgId,MAPAVGM.get(avgId));
         }
        }  
       }
       //apexpages.addMessage(new apexpages.Message(apexpages.severity.info,''+productRuleMap.get(new list<Id>(productRuleMap.keyset())[0]).attValGrpByPardId));
       //apexpages.addMessage(new apexpages.Message(apexpages.severity.info,''+productRuleMap.get(new list<Id>(productRuleMap.keyset())[0]).groupMembersByGroupId));
                                                                                                   
	 return productRuleMap;
	}
	
	
	
	/*
	 wrapper to hold the rules infomrmation by product.
	*/
	
	public class productRuleInfo{
	 public map<Id,list<Id>> attValGrpByPardId;
	 /*
	  attValGrpByPardId: This contains all the pard rules ids as keys. 
	                     The pair is a list of 1. controlling attribute group Id in the first Element
	                                           2. Dependent Attribute group Id in the second Element
	 */
	 public map<Id,list<Attribute_Value_Group_Member__c>> groupMembersByGroupId;
	 
	 /*
	    groupMembersByGroupId: Attribute values group Ids as keys
	                           Related members as values.  
	 
	 */
	 //static string str;
	 //list<Id> AVGMIds;
	 public productRuleInfo()
	 {
	  attValGrpByPardId=new map<Id,list<Id>>(); 
	  groupMembersByGroupId= new map<Id,list<Attribute_Value_Group_Member__c>>();  
      //AVGMIds=new list<Id>();                                                          
	 }
	 //Product_Attribute_Rule_Definitions__c pard
	 void addPardInfo(Product_Attribute_Rule_Definitions__c pard)
	 {
	  attValGrpByPardId.put(pard.id,new list<Id>{pard.Controlling_Attribute_Value_Group__c,
	                                             pard.Dependent_Attribute_Value_Group__c});
	 }
	 /*
	   This method populates the groupMembersByGroupId.
	 */
        /*MS Start
	 void populateGroupMembersmap(Attribute_Value_Group__c AVG){
	   //System.assertNotEquals(AVG,null);  
	   list<Attribute_Value_Group_Member__c> avgmlist= AVG.getSobjects('Attribute_Value_Junction_Objects__r');
	   
	   if(avgmlist==null)
	      Throw new  AttributeException('Attribute Members Does not Exist for Group:'+AVG.Id);
	   groupMembersByGroupId.put(AVG.Id,avgmlist);
	 }
	 MS END*/
	 void populateGroupMembersmap2(id AVGId, List<Attribute_Value_Group_Member__c> avgmlistArg){
	   //System.assertNotEquals(AVG,null);  
	   list<Attribute_Value_Group_Member__c> avgmlist= avgmlistArg;
	   
	   if(avgmlist==null)
	      Throw new  AttributeException('Attribute Members Does not Exist for Group:'+AVGId);
	   groupMembersByGroupId.put(AVGId,avgmlist);
	 }
        
	}
	
	/*
	  Method to gather the proposal field values
	  Define a method that takes list<productRuleInfo> as argument and populate all the proposal fields 
	*/
	
	

}