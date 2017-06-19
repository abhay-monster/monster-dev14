public with sharing class OpportunityLineItemTriggerHelper {
	final String CLASSNAME = '\n\n**** OpportunityLineItemTriggerHelper.METHODNAME()';

	public OpportunityLineItemTriggerHelper() {

	}

	public void callSetInternationalOppty(OpportunityLineItem[] pNewOpportunityLineItem) {
		final string METHODNAME = CLASSNAME.replace('METHODNAME','callSetInternationalOppty');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
		Set<Id> opptyIds = new Set<Id>();

		//Appirio JFreese I-266918 & I-266684 4/3/17 Bypass on the QP Line Item delete when the QP is approved
		Set<Id> allOpptyIDs = new Set<ID>();
		for (OpportunityLineItem oppli : pNewOpportunityLineItem){ allOpptyIDs.add(oppli.OpportunityId); }
		List<Apttus_Proposal__Proposal__c> qps = [SELECT Id, Apttus_QPApprov__Approval_Status__c, Apttus_Proposal__Opportunity__c
		FROM Apttus_Proposal__Proposal__c WHERE Apttus_Proposal__Primary__c = true AND Apttus_Proposal__Opportunity__c IN: allOpptyIDs];
		Set<Id> bypassSetInternationalOppty = new Set<Id>();
		for(Apttus_Proposal__Proposal__c qp : qps){
			if (qp.Apttus_QPApprov__Approval_Status__c == 'Approved' && Trigger.isDelete){
				bypassSetInternationalOppty.add(qp.Apttus_Proposal__Opportunity__c);
				system.debug('Proposal '+qp.Id+' has Approval Status='+qp.Apttus_QPApprov__Approval_Status__c+
					         ' and we are in the DELETE trigger, so bypass SetInternationalOppty for oppprtunity '+
					         qp.Apttus_Proposal__Opportunity__c);
			}
		}

		for (OpportunityLineItem oppLineItem : pNewOpportunityLineItem) {
			System.debug('----runSetInternationalOppty ' + 	oppLineItem.runSetInternationalOppty__c);
			//Formula field to determine if oppty is stage 1, 2 or 3
			if (oppLineItem.runSetInternationalOppty__c && !bypassSetInternationalOppty.contains(oppLineItem.OpportunityId)) {
				opptyIds.add(oppLineItem.OpportunityId);
			}
		}
		System.debug('opptyIds ' + opptyIds);
		if (opptyIds.size() > 0) {

			/*Appirio JFreese I-266918 & I-266684 4/3/17
			  When a cart needs no approvals to be finalized, ApttusProposalTriggerHelper calls a queueable,
			  which works fine with the future setInternationalOppty.
			  But if the proposal needs approvals, when the last approval is submitted,
			  the future CPQWebService.asyncFinalizeConfigurationAndSync is called instead,
			  and it conflicts with the future setInternationalOppty.
			  So if in a queueable call a future, and if in a future call as a queueable*/
	        String dbg = '^^^Preparing to make an asynchronous call to setInternationalOppty\n';
	        if (system.isQueueable()){
	            dbg += 'We are already in a queueable job: Limits.getQueueableJobs(): '+Limits.getQueueableJobs()+' out of '+Limits.getLimitQueueableJobs()+', ';
	            dbg += 'so call setInternationalOppty in a future call.';
	            system.debug(dbg);
	            futureSetInternationalOppty(opptyIds);
	        }else{
	            if (system.isFuture()){
	                dbg += 'We are not in a queueable but are in a future job: Limits.getQueueableJobs(): '+Limits.getQueueableJobs()+' out of '+Limits.getLimitQueueableJobs()+', ';
	            }else{
	                dbg += 'We are not in either a queueable or a future job: Limits.getQueueableJobs(): '+Limits.getQueueableJobs()+' out of '+Limits.getLimitQueueableJobs()+', ';
	            }
	            dbg += 'so call setInternationalOppty in a queueable.';
	            system.debug(dbg);

                queueableSetInternationalOppty q = new queueableSetInternationalOppty();
                q.opptyIds = opptyIds;
                system.debug('^^^Calling queueable queueableSetInternationalOppty()');
                System.enqueueJob(q);
	        }
		}
	}

    /*
    @author : JFreese I-266918 & I-266684 4/3/17
    @description : Queueable class & future method for setInternationalOppty
    */
    public class queueableSetInternationalOppty implements Queueable {
        public Set<Id> opptyIds;

        public void execute(QueueableContext context){
            system.debug('^^^Inside queueable queueableSetInternationalOppty()');
            setInternationalOppty(opptyIds);
        }
    }

    @Future
	public static void futureSetInternationalOppty(Set<Id> opptyIds) {
		setInternationalOppty(opptyIds);
	}


	//SBerron - Appirio - 2/28/17 - S-460286
    //If any opportunity line items are international (OpportunityLineItem.Split_Country__c != Opportunity.Owner.Location__c)
    //set InternationalDeal__c = true. Otherwise, set it to false
    //@param Opportunity Line Item Set
    //@returns none
    //Made into a future method as this was causing issues with first product insert on oppty. Oppty was being marked international,
    //so splits were being calculated, but the product hadn't been inserted and oppty amount formula recalculated.
    //In addition, oppty update must happen every time to trigger split recalculation, so commented out check of previous values
	public static void setInternationalOppty(Set<Id> opptyIdSet) {
		final String CLASSNAME = '\n\n**** OpportunityLineItemTriggerHelper.METHODNAME()';
		final string METHODNAME = CLASSNAME.replace('METHODNAME','setInternationalOppty');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        try {
        	/*
	        Set<Id> opportunityIdSet = new Set<Id>();
	        for (OpportunityLineItem oli : pNewOpportunityLineItem) {
	        	opportunityIdSet.add(oli.OpportunityId);
	        }
	        */

	        Map<Id, List<OpportunityLineItem>> opportunityIdToLineItemMap = new Map<Id, List<OpportunityLineItem>>();
	        for (OpportunityLineItem oli : [SELECT Id, OpportunityId, Split_Country__c, Opportunity.Owner.Location__c, Opportunity.International_Upsell__c
	        								FROM OpportunityLineItem
	        								WHERE OpportunityId IN :opptyIdSet]) {
	        	System.debug('----Opportunity.International_Upsell__c ' + Opportunity.International_Upsell__c);
	        	if (opportunityIdToLineItemMap.containsKey(oli.OpportunityId)) {
	        		opportunityIdToLineItemMap.get(oli.OpportunityId).add(oli);
	        	}
	        	else {
	        		List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>{oli};
	        		opportunityIdToLineItemMap.put(oli.OpportunityId, lineItems);
	        	}
	        }
	        System.debug('----opportunityIdToLineItemMap ' + opportunityIdToLineItemMap);

	        Map<Id, Opportunity> opptyIdToOpptyMap = new Map<Id, Opportunity>();
	        for (Opportunity opp : [SELECT Id, International_Upsell__c
	        						FROM Opportunity
	        						WHERE Id IN :opptyIdSet]) {
	        	opptyIdToOpptyMap.put(opp.Id, opp);
	        }

	        //if oppty has no line items and isn't marked intl. upsell, set oppty international deal flag to false
	        List<Id> opptyList = new List<Id>();
	        List<Id> emptyOpptyList = new List<Id>();
	        opptyList.addAll(opptyIdSet);
	        for (Id oppId : opptyList) {
	        	if (!opportunityIdToLineItemMap.containsKey(oppId) && opptyIdToOpptyMap.containsKey(oppId)) {
	        		if (!opptyIdToOpptyMap.get(oppId).International_Upsell__c) {
	        			emptyOpptyList.add(oppId);
	        		}
	        	}
	        }
	        System.debug('----emptyOpptyList ' + emptyOpptyList);

	        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
	        if (opportunityIdToLineItemMap != null) {
		        for (Id oppId : opportunityIdToLineItemMap.keySet()) {
		        	Boolean isInternational = false;
		        	Boolean internationUpsell;
		        	for (OpportunityLineItem oli : opportunityIdToLineItemMap.get(oppId)) {
		        		System.debug('----oli ' + oli);
		        		internationUpsell = oli.Opportunity.International_Upsell__c;
		        		String ownerCountry = oli.Opportunity.Owner.Location__c;

		        		if ((oli.Split_Country__c != null && oli.Split_Country__c != ownerCountry) || oli.Opportunity.International_Upsell__c) {
		        			isInternational = true;
		        		}
		        	}
		        	Opportunity oppToUpdate = new Opportunity(Id = oppId);
		        	oppToUpdate.InternationalDeal__c = isInternational;
		        	opportunitiesToUpdate.add(oppToUpdate);
		        	/*
		        	if (isInternational) {
		        		if (!currentInternational) {
		        			Opportunity oppToUpdate = new Opportunity(Id = oppId);
		        			oppToUpdate.InternationalDeal__c = true;
		        			opportunitiesToUpdate.add(oppToUpdate);
		        		}
		        	}
		        	else {
		        		if (currentInternational) {
		        			Opportunity oppToUpdate = new Opportunity(Id = oppId);
		        			oppToUpdate.InternationalDeal__c = false;
		        			opportunitiesToUpdate.add(oppToUpdate);
		        		}
		        	}
					*/
		        }
		    }
		    //If opportunity has no line items, set to international to false
		    for (Id oppId: emptyOpptyList) {
		    	Opportunity oppToUpdate = new Opportunity(Id = oppId);
		        oppToUpdate.InternationalDeal__c = false;
		        opportunitiesToUpdate.add(oppToUpdate);
		    }

	        System.debug('----opportunitiesToUpdate ' + opportunitiesToUpdate);
	        if (opportunitiesToUpdate.size() > 0) {
	        	update opportunitiesToUpdate;
	        }
	    }
	    catch(Exception e) {
	    	throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Failed to update Opportunity.InternationalDeal. ' + '<br/>' + e.getMessage() + e.getLineNumber(),e);
	    }
	}

	//SBerron - Appirio - 3/22/17 - I-265178
    //On oppLineItem creation, split country must be set. When you click 'Make Primary' on existing quote, the country is not
    //writing back to split country
    //@param Opportunity Line Item List
    //@returns none
    public void setSplitCountry(OpportunityLineItem[] pNewOpportunityLineItem) {
    	final string METHODNAME = CLASSNAME.replace('METHODNAME','setSplitCountry');
    	system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

    	try {
	    	Set<Id> lineItemsToProcess = new Set<Id>();
	    	for (OpportunityLineItem oli: pNewOpportunityLineItem) {
	    		if (oli.Proposal_Line_Item__c != null) {
	    			lineItemsToProcess.add(oli.Id);
	    		}
	    	}

	    	List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
	    	for (OpportunityLineItem oli : [SELECT ID, Split_Country__c, Proposal_Line_Item__r.PostingLocation__c, Proposal_Line_Item__r.Apttus_QPConfig__AttributeValueId__r.Posting_Locations__c, Proposal_Line_Item__r.Apttus_QPConfig__AttributeValueId__r.Country__c
	    									FROM OpportunityLineItem
	    									WHERE Id IN :lineItemsToProcess]) {
	    		oliList.add(oli);
	    	}

	    	Schema.DescribeFieldResult fieldResult = OpportunityLineItem.Split_Country__c.getDescribe();
	        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			Set<String> lstPickvals=new Set<String>();
		    for (Schema.PicklistEntry a : ple ) {
				lstPickvals.add(a.getValue());
			}

			System.debug('----lstPickvals ' + lstPickvals);

	    	List<OpportunityLineItem> oppLineItemsToUpdate = new List<OpportunityLineItem>();
	    	for (OpportunityLineItem oli : oliList) {
	    		String lineItemLocation = oli.Proposal_Line_Item__r.PostingLocation__c;
				String attributePostingLocation = oli.Proposal_Line_Item__r.Apttus_QPConfig__AttributeValueId__r.Posting_Locations__c;
				String attributeCountry = oli.Proposal_Line_Item__r.Apttus_QPConfig__AttributeValueId__r.Country__c;

	            if (lineItemLocation != null && lstPickvals.contains(lineItemLocation) && lineItemLocation != oli.Split_Country__c) {
	                oli.Split_Country__c = lineItemLocation;
	                oppLineItemsToUpdate.add(oli);
	            }
	            else if (attributePostingLocation != null && lstPickvals.contains(attributePostingLocation) && lineItemLocation != oli.Split_Country__c) {
	                oli.Split_Country__c = attributePostingLocation;
	                oppLineItemsToUpdate.add(oli);
	            }
	            else if (attributeCountry != null && lstPickvals.contains(attributeCountry) && lineItemLocation != oli.Split_Country__c) {
	                oli.Split_Country__c = attributeCountry;
	                oppLineItemsToUpdate.add(oli);
	            }
	    	}

	    	System.debug('----oppLineItemsToUpdate ' + oppLineItemsToUpdate);
	    	if (oppLineItemsToUpdate != null) {
	    		update oppLineItemsToUpdate;
	    	}
	    }
	    catch(Exception e) {
	    	throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Failed to update Opportunity Line Item Split Country. ' + '<br/>' + e.getMessage() + e.getLineNumber(),e);
	    }
    }

}