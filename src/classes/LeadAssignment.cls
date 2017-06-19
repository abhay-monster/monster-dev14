/**
 * Appirio, Inc
 * Name             : LeadAssignment
 * Created Date     : 12 Sept 2015 
 * Created By       : Shailendra Singh (Appirio)
 * Description      : Scan all Lead routing rules for each Lead Routing Rules and populate Lead owner based on Rule. As below
 *                    If Country is US check Zipcode and find relevant Routing rule based on Zipcode From and Zipcode To. 
 *                    Then assign the Lead Owner as the Agent specified on the routing rule For the remaining the following should be done.
 *                    Check Country if there is routing rules follow finding the relevant lead routing rule based on this order with the sequence field:
 *                    Check if Lead source is populated 
 *                    Check if Industry is populated
 *                    Check if Employees is populated then use criteria flag to determine if record matches
 *                    Check if Annual Revenue is populated then use criteria flag to determine if record matches
 *                    Check if Country Catch all is populated
 *                    If a record meets one of those criteria as if fitlers through assign the User or the Queue based on what is populated.
 *                    If not is populate assign the Queue owner from the Routing rule named Catch All
 */
public with sharing class LeadAssignment {

    List<Lead_Routing_Rules__c> routingRules;
    List<Lead> leads;
    Map<String, ID> queueMap = new Map<String, ID>(); 
    
    public LeadAssignment(List<Lead> leads) {
        Set<String> queueNames = new Set<string>();
        routingRules = [Select Name, ID, Annual_Revenue__c, City__c, Comments__c, Country__c, Country_Catch_All__c, Criteria__c, Employees__c, Industry__c, Lead_Source__c, 
                        Queue__c, Sequence__c, User__c, ZipCode_From__c, ZipCode_To__c from Lead_Routing_Rules__c ORDER BY Country__c, Sequence__c ASC];
        this.leads = leads; 
        for(Lead_Routing_Rules__c rule : routingRules) {
            if(rule.Queue__c != null) {
                queueNames.add(rule.Queue__c);
            }   
        }
        for(Group g : [select Id, Name from Group where Type = 'Queue' AND Name In :queueNames]) {
            queueMap.put(g.Name, g.id); 
        }
    }
    
    public void assignLeads() {
        String ownerID;
        for(Lead ld : leads) {
            ownerID = null;
            for(Lead_Routing_Rules__c lrl : routingRules) {
                ownerID = evalRule(ld, lrl);
                if(ownerID != null) {
                    break;
                }
            }
            if(ownerID == null) { // fatech Routing rule for country having Catch All
                ownerID = findCatchAllOwner(ld);
            } 
            if(ownerID != null) {
                ld.OwnerId = ownerID;
            }
        }       
    }
    
    private String evalRule(Lead ld, Lead_Routing_Rules__c rule) {
        boolean isSuccess = false;
        if(ld.Posting_Country__c == 'United States' && ld.Posting_Country__c  == rule.Country__c) { // country is USA
        

            String[] zipAccount = new String[]{};
            String[] zipStart = new String[]{};
            String[] zipEnd = new String[]{};
            Boolean flag ;

            if(ld.Posting_Zip_Postal_Code__c != null && ld.Posting_Zip_Postal_Code__c.trim() != ''){
                zipAccount = ld.Posting_Zip_Postal_Code__c.split('-');
                if(zipAccount.size() == 1){
                    zipAccount.add('0000');
                }
            } else {
                isSuccess  = false;
                flag  = true;
            }
            if(zipAccount.isEmpty() || (!zipAccount.isEmpty() && !String.isBlank(zipAccount[0].trim()) && !zipAccount[0].trim().isNumeric())){
                isSuccess  = false;
                flag = true;
            }
            if(rule.ZipCode_From__c != null){
                zipStart = rule.ZipCode_From__c.split('-');
                if(zipStart.size() == 1){
                    zipStart.add('0000');
                }
            }
            if(rule.Zipcode_To__c != null){
                zipEnd = rule.Zipcode_To__c.split('-');
                if(zipEnd.size() == 1){
                    zipEnd.add('9999');
                }
            }
            if(zipStart.isEmpty()){
                zipStart.add('');
            }
            if(zipAccount.isEmpty()){
                zipAccount.add('');
            }
            
            if(!zipStart[0].trim().isNumeric()){
                zipStart[0] = '';
            }
            
            if(zipEnd.isEmpty()){
                zipEnd.add('');
            }
            if(!zipEnd[0].trim().isNumeric()){
                zipEnd[0] = '';
            }
            if(!zipAccount[0].trim().isNumeric()){
                isSuccess  = false;
                flag = true;
            }
           
            if(zipAccount[0].trim().length() <> 5){
                isSuccess  = false;
                flag = true;
            }
            if(zipAccount[0].trim().isNumeric() && !zipAccount[1].trim().isNumeric()){
                zipAccount[1] ='0000';
            }
            if(flag != True){
                if((rule.ZipCode_From__c == null || zipStart[0].trim() == '') && (rule.Zipcode_To__c == null || zipEnd[0].trim() == '')){
                    isSuccess  = false;
                } else if((rule.ZipCode_From__c != null && zipStart[0].trim() != '') && (rule.Zipcode_To__c == null || zipEnd[0].trim() == '')){
                    if(long.valueof(zipAccount[0].trim()) == long.valueof(zipStart[0].trim()) && long.valueof(zipAccount[1].trim()) == long.valueof(zipStart[1].trim())){
                        isSuccess  = true;
                    } else {
                        isSuccess  = false;
                    }
                } else if((rule.ZipCode_From__c == null || zipStart[0].trim() == '') && (rule.Zipcode_To__c != null && zipEnd[0].trim() != '')){
                    if(long.valueof(zipAccount[0].trim()) == long.valueof(zipEnd[0].trim()) && long.valueof(zipAccount[1].trim()) == long.valueof(zipEnd[1].trim())){
                        isSuccess  = true;
                    } else {
                        isSuccess  = false;
                    }
                } else if((rule.ZipCode_From__c != null && zipStart[0].trim() != '') && (rule.Zipcode_To__c != null && zipEnd[0].trim() != '')){
                    if(long.valueof(zipAccount[0].trim()) >= long.valueof(zipStart[0].trim()) && 
                    long.valueof(zipAccount[0].trim()) <= long.valueof(zipEnd[0].trim())){
                        if(long.valueof(zipAccount[1].trim()) >= long.valueof(zipStart[1].trim()) && long.valueof(zipAccount[1].trim()) <= long.valueof(zipEnd[1].trim())){
                            isSuccess  = true;
                        } else {
                            isSuccess  = false;
                        }
                    } else {
                        isSuccess  = false;
                    }
                } 
            }       
        
            /*Integer postalCode = Integer.valueOf(ld.Posting_Zip_Postal_Code__c);

            if(postalCode != null && postalCode >= Integer.ValueOf(rule.ZipCode_From__c) && postalCode <= Integer.ValueOf(rule.Zipcode_To__c) && ld.Posting_City__c == rule.City__c) {
                isSuccess = true;
            }*/
            
            
            if(isSuccess) {
                if(rule.User__c != null) {
                    return rule.User__c;
                } else if(rule.Queue__c != null && queueMap.get(rule.Queue__c) != null) {
                    return queueMap.get(rule.Queue__c);
                }
            }           
        } else if(ld.Posting_Country__c  == rule.Country__c){
            if(ld.LeadSource != null && ld.LeadSource == rule.Lead_Source__c) {
                isSuccess = true;
            }
            if(ld.Industry != null && ld.Industry == rule.Industry__c) {
                isSuccess = true;
            }
            if(ld.NumberOfEmployees != null) {
                if(compareCriteria(Double.valueof(ld.NumberOfEmployees), Double.valueof(rule.Employees__c), rule.Criteria__c)) {
                    isSuccess = true;
                }
            }
            if(ld.AnnualRevenue != null) {
                System.debug('rule =>' + rule);
                System.debug('AnnualRevenue =>' + ld.AnnualRevenue);                
                if(compareCriteria(Double.valueof(ld.AnnualRevenue), Double.valueof(rule.Annual_Revenue__c), rule.Criteria__c)) {
                    isSuccess = true;
                }
            }
            if(isSuccess) {
                if(rule.User__c != null) {
                    return rule.User__c;
                } else if(rule.Queue__c != null && queueMap.get(rule.Queue__c) != null) {
                    return queueMap.get(rule.Queue__c);
                }   
            } 
        }
        return null;
    }
    
    private boolean compareCriteria(Double lval, Double rval, String criteria) {
        if(criteria == '<') {
            if(lval < rval) {
                return true;
            }
        } else if(criteria == '>') {
            if(lval  > rval) {
                return true;
            }           
        }else if(criteria == '=') {
            if(lval == rval) {
                return true;
            }           
        }
        return false;
    }
    
    private ID findCatchAllOwner(Lead ld) {
        for(Lead_Routing_Rules__c rule : routingRules) {
            if(ld.Posting_Country__c == rule.Country__c && rule.Country_Catch_All__c) {
                if(rule.Queue__c != null && queueMap.get(rule.Queue__c) != null) {
                    return queueMap.get(rule.Queue__c);
                }
            }           
        }   
        return null;    
    }
}