public with sharing class OpportunitySplitTriggerHelper {
	final String CLASSNAME = '\n\n**** OpportunitySplitTriggerHelper.METHODNAME()';
    public Org_Settings__c orgSettings = Org_Settings__c.getInstance();
    public Integer cutoff = Integer.valueOf(orgSettings.Debug_Log_Record_Count_Cutoff__c); //JFreese Appirio S-435483 4/10/17
    public Id debugId = orgSettings.Debug_Log_Record_ID__c; //JFreese Appirio S-435483 4/11/17

	public OpportunitySplitTriggerHelper() {
	}

   	/* @Name: insertRecordinOLIManager
    *  @Author: ???
    *  @Params: List of Opportunity Splits, Map of Opportunity Splits
    *  @Returns: void
    *  @Description: Inserts order line item manager when a opportunity
    				 split record is inserted
    */
	public void insertRecordinOLIManager(OpportunitySplit[] pNewpportunitySplit, map<ID, OpportunitySplit> newOpportunitySplitMap){
		final string METHODNAME = CLASSNAME.replace('METHODNAME','insertRecordinOLIManager');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Set<Id> oppIds = new Set<Id>(); //JFreese Appirio S-435483 4/10/17
        Map<ID, OpportunitySplit> oppList = new Map<ID, OpportunitySplit>();
        Map<ID,ID> ordMap = new Map<ID,ID>();
        Map<ID, Order__c> ordoppMap = new Map<ID, Order__c>();
        List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();

        List<Order_Line_Item_Manager__c> oLIManagersAdd = new List<Order_Line_Item_Manager__c>();
        For(OpportunitySplit oppSFirst : pNewpportunitySplit){
            oppList.put(oppSFirst.OpportunityId, oppSFirst);
            oppIds.add(oppSFirst.OpportunityId);
        }
        if (oppIds.size() <= cutoff){ //JFreese Appirio S-435483 4/10/17
            system.debug('check 2 oppList' + oppList);
        }
        if(!oppList.keySet().isEmpty()){
            for(Order__c ord : [Select Id, Opportunity__c,Opportunity__r.Owner.Id, Opportunity__r.OwnerId,Opportunity__r.Owner.Name from Order__c where Opportunity__c IN :oppList.keySet()]){
                if (oppIds.size() <= cutoff || ord.Opportunity__c == debugId){ //JFreese Appirio S-435483 4/10/17
                    system.debug('check 5 ord' + ord);
                    system.debug('check 6 ord.Opportunity__r.OwnerId' + ord.Opportunity__r.OwnerId);
                    system.debug('check 7 oppList.get(ord.Opportunity__c).SplitOwnerId' + oppList.get(ord.Opportunity__c).SplitOwnerId);
                }
               // if(ord.Opportunity__r.OwnerId != oppList.get(ord.Opportunity__c).SplitOwnerId){
                    ordMap.put(ord.Id,oppList.get(ord.Opportunity__c).SplitOwnerId);
                    if (oppIds.size() <= cutoff || ord.Opportunity__c == debugId){ //JFreese Appirio S-435483 4/10/17
                        system.debug('check running?');
                    }
                //}
            }
            if (oppIds.size() <= cutoff){ //JFreese Appirio S-435483 4/10/17
                system.debug('check 3 ordMap' + ordMap);
            }
            if(!ordMap.keySet().isEmpty()){

                for(Order_Line_item__c OLIFirst : [Select Id,Order__c,Order__r.Opportunity__c,Order__r.Opportunity__r.Owner.Name from Order_Line_Item__c where Order__c IN :ordMap.keySet()]){
                    oliList.add(OLIFirst);
                }
            }
        }

        String profileName = [Select Name from Profile Where Id  =: userinfo.getProfileId()].Name ;
        if (oppIds.size() <= cutoff){ //JFreese Appirio S-435483 4/10/17
            system.debug('check 4 oliList' + oliList);
        }
        if(!oliList.isEmpty()){
        	OrderLineItemTriggerHelper olihelper = new OrderLineItemTriggerHelper(profileName);
        	olihelper.populateSecondOppSplitLookup(oliList);
        }
    }


   	/* @Name: deleteRecordOLIM
    *  @Author: ???
    *  @Params: List of Opportunity Splits
    *  @Returns: void
    *  @Description: Upserts or deletes Order Line Item Manager records to re-adjust
    				 the hierarchy when a delete occurs
    */
	public void deleteRecordOLIM(OpportunitySplit[] pOldOpportunitySplit){
		final string METHODNAME = CLASSNAME.replace('METHODNAME','deleteRecordOLIM');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Set<ID> userDeleted = new Set<Id>();
        Set<Id> oppList = new Set<Id>();
        Set<Id> oliList = new Set<Id>();
        Set<Id> oliupsert = new Set<Id>();
        Set<Id> olimdelete = new Set<Id>();
        Map<Id, List<Order_Line_Item_Manager__c>> maptoOLIM = new Map<Id, List<Order_Line_Item_Manager__c>>();
        List<Order_Line_Item_Manager__c> olimList = new List<Order_Line_Item_Manager__c>();
        List<Order_Line_Item_Manager__c> olimListupsert = new List<Order_Line_Item_Manager__c>();

        For(OpportunitySplit oppSFirst : pOldOpportunitySplit){
        	userDeleted.add(oppSFirst.SplitOwnerId);
        	oppList.add(oppSFirst.OpportunityId);
        }

        For(Order_Line_item__c ordList : [Select Id, Order__c, Order__r.Opportunity__c from Order_Line_item__c where Order__r.Opportunity__c IN :oppList]){
        	oliList.add(ordList.Id);
        }

        if (oppList.size() <= cutoff){ //JFreese Appirio S-435483 4/10/17
            system.debug('---- oliList'+ oliList);
        }
        if(!userDeleted.isEmpty() && !oliList.isEmpty()){
        	system.debug('---- running');
        	for(Order_Line_Item_Manager__c olim : [Select Id,Manager__c,Sales_Rep_ID__c ,Manager_Hierarchy_Level__c,Order_Line_item__c, Secondary_Sales_Rep__c From Order_Line_Item_Manager__c where Secondary_Sales_Rep__c = true AND Order_Line_item__c
        		IN : oliList order by Manager_Hierarchy_Level__c ]){
        		if(!maptoOLIM.containsKey(olim.Order_Line_item__c)){
        			maptoOLIM.put(olim.Order_Line_item__c  ,new list<Order_Line_Item_Manager__c >());
        		}
        		maptoOLIM.get(olim.Order_Line_item__c).add(olim );
        	}
            if (oppList.size() <= cutoff){ //JFreese Appirio S-435483 4/10/17
            	system.debug('---- maptoOLIM'+ maptoOLIM);
            }

        	for(Id oliId : maptoOLIM.keySet()){
                if (oppList.size() <= cutoff){ //JFreese Appirio S-435483 4/10/17
            		system.debug('---- maptoOLIM.keySet() '+maptoOLIM.keySet());
                }
        		boolean hasDeleted = false;
        		Decimal countofDelete = 11;
        		Decimal deletedlevel = 0;
        		Boolean flag = true;
        		for(Order_Line_Item_Manager__c olim : maptoOLIM.get(oliId )){
                    if (oppList.size() <= cutoff){ //JFreese Appirio S-435483 4/10/17
            			system.debug('---- maptoOLIM.get(oliId ) '+maptoOLIM.get(oliId ));
            			system.debug('---- userDeleted '+userDeleted);
                    }
                     //if(userDeleted.contains(olim.Manager__c)){
                 	if(userDeleted.contains(olim.Sales_Rep_ID__c)){
                        if (oppList.size() <= cutoff){ //JFreese Appirio S-435483 4/10/17
                     		system.debug('---- running2');
                        }
                 		deletedlevel =  olim.Manager_Hierarchy_Level__c;
                 	}
                 	if(deletedlevel != 0 && (olim.Manager_Hierarchy_Level__c - deletedlevel > 0 && olim.Manager_Hierarchy_Level__c - deletedlevel < 10)){
                        if (oppList.size() <= cutoff){ //JFreese Appirio S-435483 4/10/17
                     		system.debug('---- running3');
                        }
                 		olimList.add(olim);
                 		olimdelete.add(olim.Manager__c);
                 	}

                 	if(userDeleted.contains(olim.Sales_Rep_ID__c)){
                        if (oppList.size() <= cutoff){ //JFreese Appirio S-435483 4/10/17
                     		system.debug('---- running4');
                        }
                 		olimList.add(olim);
                 		hasDeleted = true;
                 		countofDelete = olim.Manager_Hierarchy_Level__c;

                 	}
                 	else if(hasDeleted && !olimdelete.contains(olim.Manager__c)){
                        if (oppList.size() <= cutoff){ //JFreese Appirio S-435483 4/10/17
                     		system.debug('---- running5');
                        }
                 		olim.Manager_Hierarchy_Level__c = olim.Manager_Hierarchy_Level__c - 10;
                 		if(flag){
                            if (oppList.size() <= cutoff){ //JFreese Appirio S-435483 4/10/17
                 			    system.debug('---- running6');
                            }
                 			olim.Manager_Hierarchy_Level__c = countofDelete ;
                 			flag = false;
                 		}
                 		olimListupsert.add(olim);

                 	}
                }

            }

        }
        if (oppList.size() <= cutoff){ //JFreese Appirio S-435483 4/10/17
            system.debug('---- olimList'+ olimList);
        }
        try{
	        if(olimList.size()>0){
        		delete olimList;
	        }
	        if(olimListupsert.size()>0){
	        	upsert olimListupsert;
	        }
        } catch (Exception ex){
        	//This is needed to display the correct
        	//validation message on delete for ValidateUserPermission
        	system.debug('Error encountered ' + ex.getMessage());
        }

    }

   	/* @Name: validateUserPermission
    *  @Author: Jeff L (Appirio)
    *  @Params: List of Opportunity Splits, Map of Opportunity Splits
    *  @Returns: void
    *  @Description: This method is used to determine if the current user has permission
    				 to update the opportunity splits.  If the opportunity for the
    				 split is Stage 5, then only certain users can edit the splits
    */
    public void validateUserPermission(List<OpportunitySplit> pNewOpportunitySplits){
		final string METHODNAME = CLASSNAME.replace('METHODNAME','validateUserPermission');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
    	//if we have this permission then we don't need to check the Opportunity
    	//Stage at all
    	if(PermissionCheck.hasPermission('Edit_Stage_5_Splits')){
    		system.debug('User had the correct permission, returning');
    		return;
    	}

    	//Get the Opportunities related to the splits
    	Map<Id,List<OpportunitySplit>> oppToSplitMap = new Map<Id,List<OpportunitySplit>>();

    	for(OpportunitySplit os : pNewOpportunitySplits){
    		if(oppToSplitMap.get(os.OpportunityId) == null){
    			oppToSplitMap.put(os.OpportunityId, new List<OpportunitySplit>());
    		}
    		oppToSplitMap.get(os.OpportunityId).add(os);
    	}

    	//if the stage is 5 then we add errors to all the opportunity splits
    	//for that opp
    	for(Opportunity opp : [SELECT Id, StageName FROM Opportunity
    							WHERE Id in :oppToSplitMap.keySet()
    							AND StageName = 'Stage 5 - Verified by Finance' ]){

			for(OpportunitySplit split : oppToSplitMap.get(opp.Id)){
				system.debug('adding Error to split ' +split.Id);
				split.addError(Label.Opp_Split_Permission_Error);
			}
    	}
    }
}