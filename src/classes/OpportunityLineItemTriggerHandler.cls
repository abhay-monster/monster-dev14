public class OpportunityLineItemTriggerHandler extends BaseTriggerHandler{
    final String CLASSNAME = '\n\n**** OpportunityLineItemTriggerHandler.METHODNAME()';
    public static Integer RunCount = 0;
    public static Boolean PreventRecursion = true;
    private OpportunityLineItemTriggerHelper helper;

    public OpportunityLineItemTriggerHandler (boolean isExecuting, integer pTriggerSize){
        helper = new OpportunityLineItemTriggerHelper();
    }

    public void onBeforeInsert(OpportunityLineItem[] pNewOpportunityLineItem) {
        if (Personal_Settings__c.getInstance().Trigger_Opportunity_Line_Item__c == false){
            return; // If triggers are off, then exit the method
        }

        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
    }

    public void OnAfterInsert(OpportunityLineItem[] pNewOpportunityLineItem, map<ID, OpportunityLineItem> pNewOpportunityLineItemMap){
        if (Personal_Settings__c.getInstance().Trigger_Opportunity_Line_Item__c == false){
            return; // If triggers are off, then exit the method
        }

        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        helper.setSplitCountry(pNewOpportunityLineItem);
    }

    public void OnBeforeUpdate(OpportunityLineItem[] pNewOpportunityLineItem, map<ID, OpportunityLineItem> pNewOpportunityLineItemMap) {
        if (Personal_Settings__c.getInstance().Trigger_Opportunity_Line_Item__c == false){
            return; // If triggers are off, then exit the method
        }

        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        RunCount++;
    }

    public void OnAfterUpdate(OpportunityLineItem[] pNewOpportunityLineItem, map<ID, OpportunityLineItem> pNewOpportunityLineItemMap) {
        if (Personal_Settings__c.getInstance().Trigger_Opportunity_Line_Item__c == false){
            return; // If triggers are off, then exit the method
        }

        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        //Appirio JFreese I-266918 & I-266684 4/3/17
        if(OpportunityLineItemTriggerHandler.RunCount > 1 && PreventRecursion){
            system.debug('^^^ OpportunityLineItemTriggerHandler Bypassing OnAfterUpdate Runcount=' + OpportunityLineItemTriggerHandler.RunCount + ', PreventRecursion=' + PreventRecursion);
            return;
        }

        //helper.setInternationalOppty(pNewOpportunityLineItem);
        helper.callSetInternationalOppty(pNewOpportunityLineItem);
    }

    public void OnBeforeDelete(OpportunityLineItem[] pOldOpportunityLineItem, map<ID, OpportunityLineItem> pOldOpportunityLineItemMap) {
        if (Personal_Settings__c.getInstance().Trigger_Opportunity_Line_Item__c == false){
            return; // If triggers are off, then exit the method
        }

        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeDelete');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
    }
    public void OnAfterDelete(OpportunityLineItem[] pOldOpportunityLineItem, map<ID, OpportunityLineItem> pOldOpportunityLineItemMap) {
        if (Personal_Settings__c.getInstance().Trigger_Opportunity_Line_Item__c == false){
            return; // If triggers are off, then exit the method
        }

        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterDelete');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        helper.callSetInternationalOppty(pOldOpportunityLineItem);
    }
}