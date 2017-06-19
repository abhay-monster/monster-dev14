public with sharing class NSSA_approvals_Util {
/*
** @author : Clud Sherpas, Inc.
** @date : 9/18/2014
** @description :for a proposal all line items per Product if there is long term contract i:e months between  Earlystartdate, Latestenddate > 12
** @paramaters : Map of  productcode list of Apttus_Config2__LineItem__c records
** @returns : Boolean value  
*/
    public static Boolean isanyproductlongterm(Map <String,List<Apttus_Config2__LineItem__c>> configLiProducts){

        system.debug('in class: NSSA_approvals_Util method:isanyproductlongterm');
        system.debug(' map configLiProducts'+configLiProducts);
        for(String eachonfigLiProducts: configLiProducts.keyset()){
            list<Date> StartDate = new List<Date>();
            list<Date> EndDate = new List<Date>();
            list<Apttus_Config2__LineItem__c> LIlist = configLiProducts.get(eachonfigLiProducts);
            for(Apttus_Config2__LineItem__c tempLI : LIlist){
                if(tempLI.Apttus_Config2__StartDate__c != null)
                    StartDate.add(tempLI.Apttus_Config2__StartDate__c);
                if(tempLI.Apttus_Config2__EndDate__c != null)
                    EndDate.add(tempLI.Apttus_Config2__EndDate__c);
            }
            StartDate.sort();
            EndDate.sort();
            try{
                if(!LIlist.isEmpty() && !StartDate.isEmpty() && !EndDate.isEmpty()){
                    Date Earlystartdate = StartDate.get(0);
                    Date Latestenddate = EndDate.get(EndDate.size()-1);
                    decimal months_between = 0.00;
                    if(Earlystartdate!= null && Latestenddate!= null)
                        months_between = getMonthsBetweendates(Earlystartdate,Latestenddate);
                    system.debug('Earlystartdate :'+ Earlystartdate+' <>Latestenddate '+Latestenddate );
                    system.debug(' difference between dates'+months_between);
                    //if (Earlystartdate.day() < Latestenddate.day()) months_between--; else months_between++;
                    system.debug(' difference between dates'+months_between);
                    if(Earlystartdate!= null && Latestenddate!= null && months_between > 12 ){
                        return true;
                    }
                }
            }catch(Exception ex){
                system.debug(' Exception:'+ex.getMessage());
			}
        }

        return false;
    }
/*
** @author : Clud Sherpas, Inc.
** @date : 9/18/2014
** @description :calculates the months_between two dates 
** @paramaters : 2 dates 
** @returns : decimal 
*/    
    
   public static decimal getMonthsBetweendates(Date startDate, Date endDate){
       
        System.debug('getMonthsBetweendates startDate'+startDate+' endDate'+endDate);
        decimal n = startDate.monthsBetween(endDate);
       System.debug('getMonthsBetweendates n'+n);
       System.debug('getMonthsBetweendates endDate.day() '+endDate.day()+' startDate.day() '+startDate.day());
        if (endDate.day() > startDate.day())
        {
            n++;
        }
         System.debug(n);
           return n.setScale(2, roundingMode.HALF_UP); 
      
       /*Old logic Commented out-I-196986
        if( startDate.month()== endDate.month() && startDate.year()== endDate.year() )
        {
            n =  decimal.valueOf((startDate.daysBetween(endDate) + 1 )) 
                        / decimal.valueOf(date.daysInMonth(startDate.year(),startDate.month()));
        }
        else
        {
            Integer monthsBetween = startDate.monthsBetween(endDate)-1;
            decimal firstMonth = decimal.valueOf(date.daysInMonth(startDate.year() , startDate.month())-startDate.day()+1) 
                                    / decimal.valueOf(date.daysInMonth(startDate.year(), startDate.month()));
            decimal lastMonth =  decimal.valueOf(endDate.toStartOfMonth().daysBetween(endDate)+1)  
                                      / decimal.valueOf(date.daysInMonth(endDate.year(), endDate.month()));
            n =  firstMonth + monthsBetween + lastMonth;         
        }

        return n.setScale(2, roundingMode.HALF_UP);    
*/
    }
    
    
/*
** @author : Clud Sherpas, Inc.
** @date : 9/18/2014
** @description :for a proposal all line items per Product if there is sEarly_Renewals i:e Earlystartdate for a product > contract start date of proposal or Earlystartdate in next year
** @paramaters : Map of  productcode list of Apttus_Config2__LineItem__c records
** @returns : Boolean value  
*/
    
    public static Boolean isEarly_Renewals(Map <String,List<Apttus_Config2__LineItem__c>> configLiProducts, Date ContractStartDate){
        system.debug('in class: NSSA_approvals_Util method:isEarly_Renewals');
        system.debug(' map configLiProducts'+configLiProducts);
        for(String eachonfigLiProducts: configLiProducts.keyset()){
            list<Date> StartDate = new List<Date>();
            List<Apttus_Config2__LineItem__c> LIlist = configLiProducts.get(eachonfigLiProducts);
            for(Apttus_Config2__LineItem__c tempLI : LIlist){
                if(tempLI.Apttus_Config2__StartDate__c != null)
                     StartDate.add(tempLI.Apttus_Config2__StartDate__c);
                
            }
            StartDate.sort();
            if(!LIlist.isEmpty() && !StartDate.isEmpty()){
                Date Earlystartdate = StartDate.get(0);
                Date todaysdate = Date.today();
                System.debug('isEarly_Renewals Earlystartdate:'+Earlystartdate);
                System.debug('isEarly_Renewals ContractStartDate:'+ContractStartDate);
                if(Earlystartdate != null && ContractStartDate != null)
                if(Earlystartdate > ContractStartDate.addMonths(1) || Earlystartdate.year() > todaysdate.year() ){
                    
                    return true;
                }
            }
       
        }
    return false; 
    }

}