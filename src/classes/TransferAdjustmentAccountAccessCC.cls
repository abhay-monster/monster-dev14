global with sharing class TransferAdjustmentAccountAccessCC {
    final String CLASSNAME = '\n\n**** TransferAdjustmentAccountAccessCC.METHODNAME()';
    public String selectedAction {get; set;}
    public String selectedProposalID {get;set;}
    public String outputHTMLTable { get; set; }
    public String siteIdArray {get; set;}
    public Integer pageIndex {get;set;} //index used for pagination
    private STATIC Integer recordsPerPage = 100; // # of records for the page
    public String orderId {get; set;}
    public Date orderStartDate {get; set;}
    public Date orderEndDate {get; set;}
    

    public String message { get; set; }
    private Id AccountID;
    private  Map<Id,Order__c> rawOrderMap;
    private  List<Order_Line_Item__c> rawOrderLineItemList;
    private  map<String, LicenseID__c> siteIdToLicense;
    private List<OrderWrap> EligibleOrderList;


    //Updated by Prashant Gupta (Appirio) S-457163, 04/05/17
    Public List<SelectOption> searchMethodList {get {
            if (searchMethodList == null) {
                searchMethodList = new list<SelectOption>();
                searchMethodList.add(new SelectOption('0','--NONE--'));
                searchMethodList.add(new SelectOption('1','Order ID'));
                searchMethodList.add(new SelectOption('2','Order Line Item name'));
                searchMethodList.add(new SelectOption('3','Order Start Date'));
                searchMethodList.add(new SelectOption('4','Order End Date'));
                searchMethodList.add(new SelectOption('5','Xcode'));
                searchMethodList.add(new SelectOption('6','Resource License ID'));
                searchMethodList.add(new SelectOption('7','Product'));
            }
            return searchMethodList;
        }
        set;}
    Public String searchMethodValue {get;set;}
    Public String searchText{get;set;}
    Public Date searchDate{get;set;}
    public boolean showSearchBoxText{get;set;}
    public boolean showSearchBoxDate{get;set;}
    //End
    //this populates the select list with the options
    public list<SelectOption> actionList {
        get {
            if (actionList == null) {
                actionList = new list<SelectOption>();
                actionList.add(new SelectOption('','Please Select One'));
                actionList.add(new SelectOption('transfer','Transfer'));
                actionList.add(new SelectOption('adjust','Adjustment'));
            }
            return actionList;
        }
        private set;
    }

    public TransferAdjustmentAccountAccessCC(){
        //Updated by Prashant Gupta (Appirio) S-457163, 04/05/17
        showSearchBoxText = false;
        showSearchBoxDate = false;
        orderId = null;
        //End
        final string METHODNAME = CLASSNAME.replace('METHODNAME','Constructor');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        message = '';
        outputHTMLTable = '';
        siteIdArray = '[]';
        pageIndex = 0; // initialize the page index to 0
        if(ApexPages.currentPage().getParameters().containsKey('AccountID')){
            AccountID = ApexPages.currentPage().getParameters().get('AccountID');
        }
    }

    //This is the main method of this page - it creates the HTML table that gets
    //rendered
    @testvisible private void generateOutput(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','generateOutput');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        //this will be null the first time the page is called - or if the selected
        //action is changed
        //if(EligibleOrderList == null){
            //Commented and Added by Prashant Gupta (Appirio) S-457163, 04/05/17
            //EligibleOrderList = getOrders();
            EligibleOrderList = getOrdersNew();
            //End
        //}
        system.debug('eligibleorders'+EligibleOrderList);
        String outputHTML = '';

        if(EligibleOrderList != null && !EligibleOrderList.isEmpty()){
            system.debug('EligibleOrders are not null or empty');
            Integer loopStart = 0;
            Integer loopEnd;

            //if(loopStart + recordsPerPage < EligibleOrderList.size()){
            //    loopEnd = loopStart + recordsPerPage;
            //} else {
                loopEnd = EligibleOrderList.size();
            //}

            outputHTML += '<table id=\'report\'> ';
            outputHTML += '<thead> ';
            outputHTML += '    <tr> ';
            outputHTML += '    <th></th> ';
            outputHTML += '    <th>Order Number</th> ';
            outputHTML += '    <th>Order Status</th> ';
            //outputHTML += '    <th>Remaining Credit Amount</th> ';
            outputHTML += '    </tr> ';
            outputHTML += '</thead> ';
            outputHTML += '<tbody> ';
            for(Integer i=loopStart; i<loopEnd; i++){
                OrderWrap orderWrap = EligibleOrderList.get(i);
                Order__c order = orderWrap.order;
                outputHTML += '    <tr class=\'proprow\'> ';
                //outputHTML += '         <td> ';
                //outputHTML += '             <input type=\'radio\' value=\''+order.ID+'\' id=\'radioComp\' name=\'radioComp\' onchange=\'setSelectedProposal()\' /> ';
                //outputHTML += '         </td> ';
                outputHTML += '       <td class=\'tdarrow\'><div class=\'arrow\'></div></td> ';
                //Updated by Prashant Gupta (Appirio) S-457163, 04/05/17
                outputHTML += '       <td class="alignleft">'+displayStr(EligibleOrderList.get(i).orderName)+'</td> ';
                //End
                outputHTML += '       <td class="alignleft">'+displayStr(order.OrderStatus__c)+'</td> ';
                //outputHTML += '       <td class="alignleft">$'+displayInt(order.GrossRemainingCreditAmount__c)+'</td> ';
                outputHTML += ' </tr> ';

                outputHTML += '<tr class=\'itemrow\' style=\'display: none\'> ';
                outputHTML += ' <td></td>';
                outputHTML += ' <td colspan=\'3\'> ';
                outputHTML += '     <table id=\'lineItems\'> ';
                outputHTML += '     <thead> ';
                outputHTML += '         <tr> ';
                outputHTML += '         <th></th>';
                outputHTML += '         <th>Order Line Item Name</th> ';
                outputHTML += '         <th>Product</th> ';
                outputHTML += '         <th>Product Line</th> ';
                outputHTML += '         <th>Start date</th> ';
                outputHTML += '         <th>End date</th> ';
                outputHTML += '         <th>Xcode</th> ';
                outputHTML += '         <th>Available Quantity</th> ';
                outputHTML += '         <th>Resource License ID</th> ';
                outputHTML += '         </tr> ';
                outputHTML += '     </thead> ';
                outputHTML += '     <tbody> ';
                for(Order_Line_Item__c oli : orderWrap.lines){
                    outputHTML += '     <tr> ';
                    outputHTML += '       <td> ';
                   // Mitali Nahar Appirio S-402215 4/4/2017 to select more than one OrderLineItems
                    outputHTML += '           <input type=\'checkbox\' value=\''+oli.ID+'\' id=\'radioComp\' name='+order.ID+ ' class='+order.ID+ ' onchange=\'setSelectedProposal("'+order.ID+'")\' /> ';
                    outputHTML += '       </td> ';
                    outputHTML += '       <td class="alignleft">'+displayStr(oli.Name) + '</td> ';
                    outputHTML += '       <td class="alignleft">'+displayStr(oli.Product__r.Name) + '</td> ';
                    outputHTML += '       <td class="alignleft">'+displayStr(oli.ProductLine__c) + '</td> ';
                    outputHTML += '       <td class="alignleft">'+displayDt(oli.StartDate__c) + '</td> ';
                    outputHTML += '       <td class="alignleft">'+displayDt(oli.EndDate__c) + '</td> ';
                    //outputHTML += '       <td class="alignleft">'+displayInt(oli.AvailableInventory__c) + '</td> ';

                    outputHTML += '       <td>';
                    for(LicenseID__c linc : oli.License_IDs__r) {
                        outputHTML += '    <table> <tr> ';
                        outputHTML += '       <td class="alignleft">' + displayStr(linc.Xcode__r.name) + '</td> ';
                        outputHTML += '     </tr></table> ';

                    }
                    outputHTML += '     </td> ';


                    outputHTML += '       <td>';
                    for(LicenseID__c linc : oli.License_IDs__r) {
                        outputHTML += '    <table> <tr> ';
                        outputHTML += '       <td class="alignleft">' + displayInt(linc.AvailableInventory__c) + '</td> ';
                        outputHTML += '     </tr></table> ';

                    }
                    outputHTML += '     </td> ';


                    outputHTML += '       <td>';
                    for(LicenseID__c linc : oli.License_IDs__r) {
                        outputHTML += '    <table> <tr> ';
                        outputHTML += '       <td class="alignleft">' + displayStr(linc.SiteLicenseID__c) + '</td> ';
                        outputHTML += '     </tr></table> ';

                    }
                    outputHTML += '     </td> ';
                    outputHTML += '     </tr> ';
                }
                outputHTML += '     </tbody> ';
                outputHTML += '     </table> ';
                outputHTML += ' </td> ';
                outputHTML += ' </tr> ';
            }
            outputHTML += '</tbody> ';
            outputHTML += '</table> ';
        }else{
            outputHTML += 'No eligible records found.';
        }
        outputHTMLTable = outputHTML;
    }
//Commented by Prashant Gupta (Appirio) S-457163, 04/05/17
//replaced with new getOrders function
/*
    private OrderWrap[] getOrders(){
    //system.assert(false , orderStartDate + '>>>>>' + orderEndDate+ '>>>>>' + orderId);
        final string METHODNAME = CLASSNAME.replace('METHODNAME','getOrders');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
            if(orderStartDate > orderEndDate && orderId == ''){
                
                message = 'Please enter Order Start Date less than Order End Date';
                return new OrderWrap[]{};
            }
        
        
        if(selectedAction == null || selectedAction == ''){
            message = '';
            return new OrderWrap[]{};
        }
        message = '';
        Integer offStart = pageIndex * recordsPerPage;
        system.debug('OFFSET:::' + offStart);
        Date currentDate = system.today();
        Map<Id,Order__c> rawOrderList = null;
        map<Id, Order_Line_Item__c[]> orderIdToOLIList = null;
    //Changes Start :  By Gaurav Gupta on 13/dec/2016 for T-559080 
			String Query = 'SELECT Id, Name, OrderStatus__c, GrossRemainingCreditAmount__c FROM Order__c WHERE  Account__c =:AccountID AND OrderStatus__c IN (\'Verified\',\'Sent To Verification\',\'Closed\',\'Paid in Full\', \'Invoiced\',\'Finance Hold\') '; 
            if(orderId != '')
                Query += 'and name = :orderId ' ;
            else{
            if(orderStartDate != null)
                Query += 'and OrderDate__c >= :orderStartDate ' ;
            if(orderEndDate != null)
                Query += 'and OrderDate__c <= :orderEndDate ' ;
            }
            if(orderId == '')
                Query += 'ORDER BY OrderDate__c Desc ' ;
            if(orderStartDate != null || orderEndDate != null)
                Query += 'LIMIT :recordsPerPage OFFSET :offStart ' ;
    
      
        if(selectedAction == 'transfer'){
            
                            		
           rawOrderList = new Map<Id,Order__c>(//[SELECT Id, Name, OrderStatus__c, GrossRemainingCreditAmount__c
                            //FROM Order__c WHERE  Account__c =:AccountID
                            //AND OrderStatus__c IN ('Verified','Sent To Verification','Closed','Paid in Full', 'Invoiced')
                            //ORDER BY OrderDate__c Desc LIMIT :recordsPerPage OFFSET :offStart]
                            (List<Order__c>)Database.query(Query)                            
                            );
                            //I-195731 - Zero Value  and closed orders should also be available to select the order for transfer
                             //AND GrossRemainingCreditAmount__c > 1

            orderIdToOLIList = getValidOrderLines2([SELECT Name, Id, Order__c, AvailableInventory__c, GrossRemainingCreditAmount__c, ProductLine__c, Product__r.Name, StartDate__c, EndDate__c,
                                 (SELECT Id, Name, Xcode__r.name, AvailableInventory__c, SiteLicenseID__c,OrderLineItem__c
                                    FROM License_IDs__r )
                                FROM Order_Line_Item__c
                                WHERE Order__c in :rawOrderList.keyset()
                                   AND EndDate__c > :currentDate AND Status__c != 'Expired'
                                   ORDER BY Name ]);


        } else {
            rawOrderList = new Map<Id,Order__c> (//[SELECT Id, Name, OrderStatus__c, GrossRemainingCreditAmount__c
                            //FROM Order__c WHERE  Account__c =:AccountID AND OrderStatus__c IN ('Verified','Sent To Verification','Closed','Paid in Full', 'Invoiced')  LIMIT :recordsPerPage OFFSET :offStart]
                            (List<Order__c>)Database.query(Query)           
                            );
            orderIdToOLIList = getValidOrderLines2([SELECT Name, Id, Order__c, AvailableInventory__c, GrossRemainingCreditAmount__c, ProductLine__c, Product__r.Name, StartDate__c, EndDate__c,
                                 (SELECT Id, Name, Xcode__r.name, AvailableInventory__c, SiteLicenseID__c,OrderLineItem__c
                                    FROM License_IDs__r )
                                FROM Order_Line_Item__c
                                WHERE Order__c in :rawOrderList.keyset()
                                ORDER BY StartDate__c Desc]);

        }
    //Changes End :  By Gaurav Gupta on 13/dec/2016 for T-559080 
        
        System.debug('[RB] : TransferAdjustmentAccountAccessCC.getOrders :: rawOrderList = ' + rawOrderList);
        System.debug('[RB] : TransferAdjustmentAccountAccessCC.getOrders :: orderIdToOLIList = ' + orderIdToOLIList);

        OrderWrap[] output = new OrderWrap[]{};

        for(Order__c rawOrder : rawOrderList.values()){
            if(orderIdToOLIList.containsKey(rawOrder.Id)){
                OrderWrap validOrder = new OrderWrap();
                validOrder.order = rawOrder;
                validOrder.lines = orderIdToOLIList.get(rawOrder.Id);
                output.add(validOrder);
            }
        }
        system.debug('rawOrderList.size()=' + rawOrderList.size() + ', orderIdToOLIList.size()=' + orderIdToOLIList.size() + ', output.size()='+output.size());
        system.debug('[RB] : TransferAdjustmentAccountAccessCC.getOrders :: output = ' + output);
        return output;
    }
*/
//End
    private map<Id, Order_Line_Item__c[]> getValidOrderLines2(Order_Line_Item__c[] pRawLines){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','getValidOrderLines2');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        /*siteIdToLicense = new map<String, LicenseID__c>();
        map<String, Integer> SiteQuantityMap = new Map<String, Integer>();*/

        set<Id> validOLIIdSet = new set<Id>();
        for(Order_Line_Item__c line : pRawLines){
            Boolean validOLI = false;
            if(line.License_IDs__r.size() > 0){
                if(selectedAction == 'transfer'){
                    if(line.AvailableInventory__c > 0){
                        validOLI = true;
                    }
                }else if(selectedAction == 'adjust'){
                    validOLI = true;
                }

            }
            if(validOLI){
                validOLIIdSet.add(line.Id);
            }
        }

        /*for(String siteId : siteIdToLicense.keySet()){
            Boolean validOLI = false;
            system.debug('OUTSIDEIF'+siteId);
            if(SiteQuantityMap.containsKey(siteId)){
                system.debug('INSIDEIF');
                if(selectedAction == 'transfer'){
                    if(SiteQuantityMap.get(siteId) > 0){
                        validOLI = true;
                    }
                }else if(selectedAction == 'adjust'){
                    validOLI = true;
                }
            }

            if(validOLI){
                validOLIIdSet.add(siteIdToLicense.get(siteId).OrderLineItem__c);
            }
        }*/

        map<Id, Order_Line_Item__c[]> orderIdToOrderLineListMap = new map<Id, Order_Line_Item__c[]>();
        for(Order_Line_Item__c line : pRawLines){
            if(validOLIIdSet.contains(line.Id)){
                if(!orderIdToOrderLineListMap.containsKey(line.Order__c)){
                    orderIdToOrderLineListMap.put(line.Order__c, new Order_Line_Item__c[]{});
                }
                orderIdToOrderLineListMap.get(line.Order__c).add(line);
            }
        }

        return orderIdToOrderLineListMap;
    }

//Updated by Prashant Gupta (Appirio) S-457163, 04/05/17
    public class OrderWrap{
        Order__c order;
        String orderName;
        Order_Line_Item__c[] lines;
        
        public OrderWrap(){
        order = new Order__c();
        orderName = null;
        lines = new Order_Line_Item__c[]{};
        }
    }
//End

/*
    private map<Id, Order_Line_Item__c[]> getValidOrderLines(Order_Line_Item__c[] pRawLines){
        siteIdToLicense = new map<String, LicenseID__c>();

        for(Order_Line_Item__c line : pRawLines){
            for(LicenseID__c license : line.License_IDs__r){
                if(license.SiteLicenseID__c != null){
                    try{
                        //Integer num = Integer.valueOf(license.SiteLicenseID__c);
                        siteIdToLicense.put(license.SiteLicenseID__c, license);
                    }catch(TypeException e){
                        system.debug('\n\n LicenseID\'s SiteLicenseID__c  error:' + e + '\n\n');
                    }
                }
            }
        }

        map<String, Integer> SiteQuantityMap;
        if(!siteIdToLicense.isEmpty()){
            SiteQuantityMap = BizAppsSiteModel.GetLicenseAndRelativesForCreditRequest(siteIdToLicense.keySet());

            //Jeff L 08/17 - added an extra case if SiteQuantityMap is null then we want to mark it as empty instead
            if(SiteQuantityMap == null){
                SiteQuantityMap = new map<String, Integer>();
                if(Test.isRunningTest()){
                    SiteQuantityMap.put('123123123123',1);
                }
            }
        }else{
            SiteQuantityMap = new map<String, Integer>();
        }

        set<Id> validOLIIdSet = new set<Id>();
        for(String siteId : siteIdToLicense.keySet()){
            Boolean validOLI = false;
            system.debug('OUTSIDEIF'+siteId);
            if(SiteQuantityMap.containsKey(siteId)){
                system.debug('INSIDEIF');
                if(selectedAction == 'transfer'){
                    if(SiteQuantityMap.get(siteId) > 0){
                        validOLI = true;
                    }
                }else if(selectedAction == 'adjust'){
                    validOLI = true;
                }
            }

            if(validOLI){
                validOLIIdSet.add(siteIdToLicense.get(siteId).OrderLineItem__c);
            }
        }

        map<Id, Order_Line_Item__c[]> orderIdToOrderLineListMap = new map<Id, Order_Line_Item__c[]>();
        for(Order_Line_Item__c line : pRawLines){
            if(validOLIIdSet.contains(line.Id)){
                if(!orderIdToOrderLineListMap.containsKey(line.Order__c)){
                    orderIdToOrderLineListMap.put(line.Order__c, new Order_Line_Item__c[]{});
                }
                orderIdToOrderLineListMap.get(line.Order__c).add(line);
            }
        }

        return orderIdToOrderLineListMap;
    }
*/
    //private map<Id, Order_Line_Item__c[]> getValidOrderLines2(Order_Line_Item__c[] pRawLines){
    //    siteIdToLicense = new map<String, LicenseID__c>();

    //    for(Order_Line_Item__c line : pRawLines){
    //        for(LicenseID__c license : line.License_IDs__r){
    //            if(license.SiteLicenseID__c != null){
    //                try{
    //                    //Integer num = Integer.valueOf(license.SiteLicenseID__c);
    //                    siteIdToLicense.put(license.SiteLicenseID__c, license);
    //                }catch(TypeException e){
    //                    system.debug('\n\n LicenseID\'s SiteLicenseID__c  error:' + e + '\n\n');
    //                }
    //            }
    //        }
    //    }

    //    map<String, Integer> SiteQuantityMap;
    //    if(!siteIdToLicense.isEmpty()){
    //        SiteQuantityMap = BizAppsSiteModel.GetLicenseAndRelativesForCreditRequest(siteIdToLicense.keySet());

    //        //Jeff L 08/17 - added an extra case if SiteQuantityMap is null then we want to mark it as empty instead
    //        if(SiteQuantityMap == null){
    //            SiteQuantityMap = new map<String, Integer>();
    //            if(Test.isRunningTest()){
    //                SiteQuantityMap.put('123123123123',1);
    //            }
    //        }
    //    }else{
    //        SiteQuantityMap = new map<String, Integer>();
    //    }

    //    set<Id> validOLIIdSet = new set<Id>();
    //    for(String siteId : siteIdToLicense.keySet()){
    //        Boolean validOLI = false;
    //        system.debug('OUTSIDEIF'+siteId);
    //        if(SiteQuantityMap.containsKey(siteId)){
    //            system.debug('INSIDEIF');
    //            if(selectedAction == 'transfer'){
    //                if(SiteQuantityMap.get(siteId) > 0){
    //                    validOLI = true;
    //                }
    //            }else if(selectedAction == 'adjust'){
    //                validOLI = true;
    //            }
    //        }

    //        if(validOLI){
    //            validOLIIdSet.add(siteIdToLicense.get(siteId).OrderLineItem__c);
    //        }
    //    }

    //    map<Id, Order_Line_Item__c[]> orderIdToOrderLineListMap = new map<Id, Order_Line_Item__c[]>();
    //    for(Order_Line_Item__c line : pRawLines){
    //        if(validOLIIdSet.contains(line.Id)){
    //            if(!orderIdToOrderLineListMap.containsKey(line.Order__c)){
    //                orderIdToOrderLineListMap.put(line.Order__c, new Order_Line_Item__c[]{});
    //            }
    //            orderIdToOrderLineListMap.get(line.Order__c).add(line);
    //        }
    //    }

    //    return orderIdToOrderLineListMap;
    //}

    public String displayStr(String input){
        if(input == null) return '';
        return input;
    }
    public String displayInt(Decimal input){
        if(input == null) return '';
        return ((Decimal)input).intValue()+'';
    }
    public String displayDec(Decimal input){
        if(input == null) return '';
        return input.setScale(2).toPlainString();
    }
    public String displayDt(Date input){
        if(input == null) return '';
        return Datetime.newInstanceGmt(input.year(), input.month(), input.day()).formatGmt('MM/dd/yyyy');
    }
    public String displayCurr(String iso, Decimal input){
        if(input == null) return '';
        return iso + ' ' + displayDec(input);
    }

    public PageReference onSelectAction() {
        System.debug(LoggingLevel.INFO,'\n\nInside onSelectAction \n\n');

        if(AccountID != null){
            EligibleOrderList = null; //nullify the list so we re-query
            generateOutput();
        }
        return null;
    }

    public PageReference selectQuoteID() {
        selectedProposalID = ApexPages.currentPage().getParameters().get('radioSelectValue');
        return null;
    }

    public PageReference onClickNext() {
        if(selectedProposalID != null){
            return new PageReference('/apex/TransferAndAdjustmentProcess?Id=' + selectedProposalID + '&FromAccount=true&type=' + selectedAction + '&FromAccountId=' + AccountId);
        }
        return null;
    }

    public PageReference onClickCancel() {
        return new PageReference('/' + AccountID);
    }

    public PageReference onClickNextPage() {
        //increment the page index, and regenerate our output;
        pageIndex++;
        generateOutput();
        return null;
    }

    public PageReference onClickPreviousPage() {
        //decrement the page index and regenerate our output
        pageIndex--;
        generateOutput();
        return null;
    }

    public Boolean renderNext {
        get{
            system.debug('inside of renderNext');
            /*
            if(EligibleOrderList != null){
                        system.debug('EligibleOrderList ' + EligibleOrderList.size());
                    } else {
                        system.debug('eligible order list is null ' + EligibleOrderList);
                    }
                    system.debug('pageIndex ' + pageIndex);
                    system.debug('recordsPerPage ' + recordsPerPage);
                    */
            if(EligibleOrderList == null){
                return false;
            } else {
                //if((pageIndex + 1) * recordsPerPage > EligibleOrderList.size()){
                system.debug('EligibleOrderList.size()=' + EligibleOrderList.size());
                return EligibleOrderList.size() == 0 ? false : true;
                /*
                return false;
                            } else {
                                return true;
                            }
                */
            }

        }
    }

    //public PageReference onSelectAction2() {
    //    System.debug(LoggingLevel.INFO,'\n\nInside onSelectAction \n\n');

    //    if(AccountID != null){
    //        getOrders2();
    //    }
    //    return null;
    //}

    //private void getOrders2(){
    //    System.debug(LoggingLevel.INFO,'\n\nInside getOrders2 \n\n');

    //    if(selectedAction == null || selectedAction == ''){
    //        //return new OrderWrap[]{};
    //    }

    //    Date currentDate = system.today();
    //    //map<Id, Order_Line_Item__c[]> orderIdToOLIList = null;

    //    if(selectedAction == 'transfer'){
    //       TransferAdjustmentAccountAccessCC.rawOrderMap = new Map<Id,Order__c>([SELECT Id, Name, OrderStatus__c, GrossRemainingCreditAmount__c
    //                        FROM Order__c WHERE  Account__c =:AccountID
    //                        AND OrderStatus__c IN ('Verified','Sent To Verification','Closed','Paid in Full', 'Invoiced')]);
    //                        /*I-195731 - Zero Value  and closed orders should also be available to select the order for transfer*/
    //                         /*AND GrossRemainingCreditAmount__c > 1*/

    //        TransferAdjustmentAccountAccessCC.rawOrderLineItemList = [SELECT Name, Id, Order__c, AvailableInventory__c, GrossRemainingCreditAmount__c, ProductLine__c, Product__r.Name, StartDate__c, EndDate__c,
    //                             (SELECT Id, Name, AvailableInventory__c, SiteLicenseID__c,OrderLineItem__c
    //                                FROM License_IDs__r )
    //                            FROM Order_Line_Item__c
    //                            WHERE Order__c in :rawOrderMap.keyset()
    //                               AND EndDate__c > :currentDate AND Status__c != 'Expired'];
    //        getValidOrderLines2(rawOrderLineItemList);


    //    } else {
    //        TransferAdjustmentAccountAccessCC.rawOrderMap = new Map<Id,Order__c> ([SELECT Id, Name, OrderStatus__c, GrossRemainingCreditAmount__c
    //                        FROM Order__c WHERE  Account__c =:AccountID AND OrderStatus__c IN ('Verified','Sent To Verification','Closed','Paid in Full', 'Invoiced')]);
    //        TransferAdjustmentAccountAccessCC.rawOrderLineItemList = [SELECT Name, Id, Order__c, AvailableInventory__c, GrossRemainingCreditAmount__c, ProductLine__c, Product__r.Name, StartDate__c, EndDate__c,
    //                             (SELECT Id, Name, AvailableInventory__c, SiteLicenseID__c,OrderLineItem__c
    //                                FROM License_IDs__r )
    //                            FROM Order_Line_Item__c
    //                            WHERE Order__c in :rawOrderMap.keyset()];
    //        getValidOrderLines2(rawOrderLineItemList);

    //    }
        //System.debug('[RB] : TransferAdjustmentAccountAccessCC.getOrders :: rawOrderList = ' + rawOrderList);
        //System.debug('[RB] : TransferAdjustmentAccountAccessCC.getOrders :: orderIdToOLIList = ' + orderIdToOLIList);

        //OrderWrap[] output = new OrderWrap[]{};

        /*for(Order__c rawOrder : rawOrderList.values()){
            if(orderIdToOLIList.containsKey(rawOrder.Id)){
                OrderWrap validOrder = new OrderWrap();
                validOrder.order = rawOrder;
                validOrder.lines = orderIdToOLIList.get(rawOrder.Id);
                output.add(validOrder);
            }
        }
        system.debug('[RB] : TransferAdjustmentAccountAccessCC.getOrders :: output = ' + output);*/
        //return output;
    //}

    //private void getValidOrderLines2(Order_Line_Item__c[] pRawLines){
    //    siteIdToLicense = new map<String, LicenseID__c>();

    //    for(Order_Line_Item__c line : pRawLines){
    //        for(LicenseID__c license : line.License_IDs__r){
    //            if(license.SiteLicenseID__c != null){
    //                try{
    //                    //Integer num = Integer.valueOf(license.SiteLicenseID__c);
    //                    siteIdToLicense.put(license.SiteLicenseID__c, license);
    //                }catch(TypeException e){
    //                    system.debug('\n\n LicenseID\'s SiteLicenseID__c  error:' + e + '\n\n');
    //                }
    //            }
    //        }
    //    }

    //    TransferAdjustmentAccountAccessCC.siteIdToLicense = siteIdToLicense;

    //    String returnString = '[';
    //    for(String s : siteIdToLicense.keySet()){
    //        returnString += '\'' + s + '\'';
    //        returnString += ',';
    //    }
    //    returnString = returnString.removeEnd(',');
    //    returnString += ']';

    //    siteIdArray = returnString;

    //    system.debug('SiteIdArray? ' +siteIdArray);


        /*map<String, Integer> SiteQuantityMap;
        if(!siteIdToLicense.isEmpty()){
            SiteQuantityMap = BizAppsSiteModel.GetLicenseAndRelativesForCreditRequest(siteIdToLicense.keySet());

            //Jeff L 08/17 - added an extra case if SiteQuantityMap is null then we want to mark it as empty instead
            if(SiteQuantityMap == null){
                SiteQuantityMap = new map<String, Integer>();
                if(Test.isRunningTest()){
                    SiteQuantityMap.put('123123123123',1);
                }
            }
        }else{
            SiteQuantityMap = new map<String, Integer>();
        }

        set<Id> validOLIIdSet = new set<Id>();
        for(String siteId : siteIdToLicense.keySet()){
            Boolean validOLI = false;
            system.debug('OUTSIDEIF'+siteId);
            if(SiteQuantityMap.containsKey(siteId)){
                system.debug('INSIDEIF');
                if(selectedAction == 'transfer'){
                    if(SiteQuantityMap.get(siteId) > 0){
                        validOLI = true;
                    }
                }else if(selectedAction == 'adjust'){
                    validOLI = true;
                }
            }

            if(validOLI){
                validOLIIdSet.add(siteIdToLicense.get(siteId).OrderLineItem__c);
            }
        }

        map<Id, Order_Line_Item__c[]> orderIdToOrderLineListMap = new map<Id, Order_Line_Item__c[]>();
        for(Order_Line_Item__c line : pRawLines){
            if(validOLIIdSet.contains(line.Id)){
                if(!orderIdToOrderLineListMap.containsKey(line.Order__c)){
                    orderIdToOrderLineListMap.put(line.Order__c, new Order_Line_Item__c[]{});
                }
                orderIdToOrderLineListMap.get(line.Order__c).add(line);
            }
        }

        return orderIdToOrderLineListMap;*/
 //   }

    //webservice static boolean parseLicIds(String jsonString){
    //    Map<String,Integer> SiteQuantityMap = (Map<String,Integer>)JSON.deserialize(jsonString, Map<String,Integer>.class);

    //    if(SiteQuantityMap == null){
    //        SiteQuantityMap = new map<String, Integer>();
    //        if(Test.isRunningTest()){
    //            SiteQuantityMap.put('123123123123',1);
    //        }
    //    }

    //    siteIdToLicense = TransferAdjustmentAccountAccessCC.siteIdToLicense;
    //    set<Id> validOLIIdSet = new set<Id>();
    //    for(String siteId : TransferAdjustmentAccountAccessCC.siteIdToLicense.keySet()){
    //        Boolean validOLI = false;
    //        system.debug('OUTSIDEIF'+siteId);
    //        if(SiteQuantityMap.containsKey(siteId)){
    //            system.debug('INSIDEIF');
    //            if(selectedAction == 'transfer'){
    //                if(SiteQuantityMap.get(siteId) > 0){
    //                    validOLI = true;
    //                }
    //            }else if(selectedAction == 'adjust'){
    //                validOLI = true;
    //            }
    //        }

    //        if(validOLI){
    //            validOLIIdSet.add(siteIdToLicense.get(siteId).OrderLineItem__c);
    //        }
    //    }

    //    map<Id, Order_Line_Item__c[]> orderIdToOrderLineListMap = new map<Id, Order_Line_Item__c[]>();
    //    for(Order_Line_Item__c line : rawOrderLineItemList){
    //        if(validOLIIdSet.contains(line.Id)){
    //            if(!orderIdToOrderLineListMap.containsKey(line.Order__c)){
    //                orderIdToOrderLineListMap.put(line.Order__c, new Order_Line_Item__c[]{});
    //            }
    //            orderIdToOrderLineListMap.get(line.Order__c).add(line);
    //        }
    //    }

    //    OrderWrap[] EligibleOrderList = new OrderWrap[]{};
    //    //orderIdToOrderLineListMap;

    //    for(Order__c rawOrder : rawOrderMap.values()){
    //        if(orderIdToOrderLineListMap.containsKey(rawOrder.Id)){
    //            OrderWrap validOrder = new OrderWrap();
    //            validOrder.order = rawOrder;
    //            validOrder.lines = orderIdToOrderLineListMap.get(rawOrder.Id);
    //            EligibleOrderList.add(validOrder);
    //        }
    //    }

    //    //OrderWrap[] EligibleOrderList = getOrders();
    //    system.debug('eligibleorders'+EligibleOrderList);
    //    String outputHTML = '';
    //    if(EligibleOrderList != null && !EligibleOrderList.isEmpty()){
    //        outputHTML += '<table id=\'report\'> ';
    //        outputHTML += '<thead> ';
    //        outputHTML += '    <tr> ';
    //        outputHTML += '    <th></th> ';
    //        outputHTML += '    <th>Order Number</th> ';
    //        outputHTML += '    <th>Order Status</th> ';
    //        //outputHTML += '    <th>Remaining Credit Amount</th> ';
    //        outputHTML += '    </tr> ';
    //        outputHTML += '</thead> ';
    //        outputHTML += '<tbody> ';
    //        for(OrderWrap orderWrap : EligibleOrderList){
    //            Order__c order = orderWrap.order;
    //            outputHTML += '    <tr class=\'proprow\'> ';
    //            //outputHTML += '         <td> ';
    //            //outputHTML += '             <input type=\'radio\' value=\''+order.ID+'\' id=\'radioComp\' name=\'radioComp\' onchange=\'setSelectedProposal()\' /> ';
    //            //outputHTML += '         </td> ';
    //            outputHTML += '       <td class=\'tdarrow\'><div class=\'arrow\'></div></td> ';
    //            outputHTML += '       <td class="alignleft">'+displayStr(order.Name)+'</td> ';
    //            outputHTML += '       <td class="alignleft">'+displayStr(order.OrderStatus__c)+'</td> ';
    //            //outputHTML += '       <td class="alignleft">$'+displayInt(order.GrossRemainingCreditAmount__c)+'</td> ';
    //            outputHTML += ' </tr> ';

    //            outputHTML += '<tr class=\'itemrow\'> ';
    //            outputHTML += ' <td></td>';
    //            outputHTML += ' <td colspan=\'3\'> ';
    //            outputHTML += '     <table id=\'lineItems\'> ';
    //            outputHTML += '     <thead> ';
    //            outputHTML += '         <tr> ';
    //            outputHTML += '         <th></th>';
    //            outputHTML += '         <th>Order Line Item Name</th> ';
    //            outputHTML += '         <th>Product</th> ';
    //            outputHTML += '         <th>Product Line</th> ';
    //            outputHTML += '         <th>Start date</th> ';
    //            outputHTML += '         <th>End date</th> ';
    //            outputHTML += '         <th>Available Quantity</th> ';
    //            outputHTML += '         <th>Resource License ID</th> ';
    //            outputHTML += '         </tr> ';
    //            outputHTML += '     </thead> ';
    //            outputHTML += '     <tbody> ';
    //            for(Order_Line_Item__c oli : orderWrap.lines){
    //                outputHTML += '     <tr> ';
    //                outputHTML += '       <td> ';
    //                outputHTML += '           <input type=\'radio\' value=\''+oli.ID+'\' id=\'radioComp\' name=\'radioComp\' onchange=\'setSelectedProposal()\' /> ';
    //                outputHTML += '       </td> ';
    //                outputHTML += '       <td class="alignleft">'+displayStr(oli.Name) + '</td> ';
    //                outputHTML += '       <td class="alignleft">'+displayStr(oli.Product__r.Name) + '</td> ';
    //                outputHTML += '       <td class="alignleft">'+displayStr(oli.ProductLine__c) + '</td> ';
    //                outputHTML += '       <td class="alignleft">'+displayDt(oli.StartDate__c) + '</td> ';
    //                outputHTML += '       <td class="alignleft">'+displayDt(oli.EndDate__c) + '</td> ';
    //                //outputHTML += '       <td class="alignleft">'+displayInt(oli.AvailableInventory__c) + '</td> ';

    //                outputHTML += '       <td>';
    //                for(LicenseID__c linc : oli.License_IDs__r) {
    //                    outputHTML += '    <table> <tr> ';
    //                    outputHTML += '       <td class="alignleft">' + displayInt(linc.AvailableInventory__c) + '</td> ';
    //                    outputHTML += '     </tr></table> ';

    //                }
    //                outputHTML += '     </td> ';


    //                outputHTML += '       <td>';
    //                for(LicenseID__c linc : oli.License_IDs__r) {
    //                    outputHTML += '    <table> <tr> ';
    //                    outputHTML += '       <td class="alignleft">' + displayStr(linc.SiteLicenseID__c) + '</td> ';
    //                    outputHTML += '     </tr></table> ';

    //                }
    //                outputHTML += '     </td> ';
    //                outputHTML += '     </tr> ';
    //            }
    //            outputHTML += '     </tbody> ';
    //            outputHTML += '     </table> ';
    //            outputHTML += ' </td> ';
    //            outputHTML += ' </tr> ';
    //        }
    //        outputHTML += '</tbody> ';
    //        outputHTML += '</table> ';
    //    }else{
    //        outputHTML += 'No record to display.';
    //    }
    //    outputHTMLTable = outputHTML;

    //    return true;
    //}

    //webservice static String getLicsWebService(List<String> pSiteLicenseIdSet){
    //    Set<String> paramSet = new Set<String>(pSiteLicenseIdSet);
    //    Map<String,Integer> siteIDtoQuantityMap = BizAppsSiteModel.GetLicenseAndRelativesForCreditRequest(paramSet);

    //    return JSON.serialize(siteIDtoQuantityMap);
    //}
    
//Added by Prashant Gupta (Appirio) S-457163, 04/05/17    
    public PageReference SearchSelection() {
        System.debug(LoggingLevel.INFO,'\n\nInside SearchSelection \n\n');
        if(AccountID != null){
            if(searchMethodValue.equals('3') || searchMethodValue.equals('4')){
                showSearchBoxDate = True;
                showSearchBoxText = False;
            }else if(searchMethodValue.equals('0')){
                showSearchBoxDate = False;
                showSearchBoxText = False;
            }else{
                showSearchBoxDate = False;
                showSearchBoxText = True;
            }
        }
        return null;
    }
    
    public OrderWrap[] getOrdersNew(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','getOrders');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
            
            String QueryBegin = 'SELECT Name, Id, Order__c, AvailableInventory__c, GrossRemainingCreditAmount__c, ProductLine__c, Product__r.Name, StartDate__c, EndDate__c, Primary_Resource_License_ID__c, Order__r.OrderDate__c,Order__r.OrderStatus__c,Order__r.Name, Order__r.Id, Order__r.ExpectedStartDate__c, Xcode_calc__c, (SELECT Id, Name, Xcode__r.name, AvailableInventory__c, SiteLicenseID__c,OrderLineItem__c FROM License_IDs__r ) FROM Order_Line_Item__c WHERE  Order__r.Account__c =:AccountID AND Order__r.OrderStatus__c IN (\'Verified\',\'Sent To Verification\',\'Closed\',\'Paid in Full\', \'Invoiced\',\'Finance Hold\')';
            Set<ID> orderLI_Set = new Set<ID>();
            
            if(orderStartDate > orderEndDate && orderId == ''){
                message = 'Please enter Order Start Date less than Order End Date';
                return new OrderWrap[]{};
            }
            
            if(selectedAction == null || selectedAction == ''){
                message = '';
                return new OrderWrap[]{};
            }
            
            message = '';
            Integer offStart = pageIndex * recordsPerPage;
            system.debug('OFFSET:::' + offStart);
            Date currentDate = system.today();
            
            if(orderId != '' && orderId!=null)
                QueryBegin += ' AND Order__r.name = :orderId ' ;
            else{
                if(orderStartDate != null)
                    QueryBegin += ' AND Order__r.OrderDate__c >= :orderStartDate ' ;
                if(orderEndDate != null)
                    QueryBegin += ' AND Order__r.OrderDate__c <= :orderEndDate ' ;
            }

            if(searchMethodValue!=null && searchMethodValue.equals('1') && !String.isBlank(searchText)){
                    QueryBegin += ' AND Order__r.Name LIKE \'%'+searchText+'%\'';
            }else if(searchMethodValue!=null && searchMethodValue.equals('2') &&!String.isBlank(searchText)){
                    QueryBegin += ' AND Name LIKE \'%'+searchText+'%\'';
            }else if(searchMethodValue!=null && searchMethodValue.equals('3') && searchDate!=NULL){
                    QueryBegin += ' AND StartDate__c = :searchDate ';
            }else if(searchMethodValue!=null && searchMethodValue.equals('4') && searchDate!=NULL){
                    QueryBegin += ' AND EndDate__c = :searchDate ';
            }else if(searchMethodValue!=null && searchMethodValue.equals('5') && !String.isBlank(searchText)){
                //Prashant I-273973
                String searchString = '%' + searchText + '%';
                orderLI_Set.clear();
                for(LicenseID__c lice : [SELECT Id, Name, SiteLicenseID__c,OrderLineItem__c,Xcode__c, Xcode__r.Name FROM LicenseID__c WHERE Xcode__c != null AND Xcode__r.Name LIKE :searchString AND OrderLineItem__c !=null]){
                    orderLI_Set.add(lice.OrderLineItem__c);
                }
                QueryBegin += ' AND ID IN : orderLI_Set';
                //End
            }else if(searchMethodValue!=null && searchMethodValue.equals('6') && !String.isBlank(searchText)){
                //Prashant I-273973
                orderLI_Set.clear();
                for(LicenseID__c lice : [SELECT Id, Name, SiteLicenseID__c,OrderLineItem__c FROM LicenseID__c WHERE SiteLicenseID__c = :searchText AND OrderLineItem__c !=null]){
                    orderLI_Set.add(lice.OrderLineItem__c);
                }
                QueryBegin += ' AND ID IN : orderLI_Set';
                //End
            }else if(searchMethodValue!=null && searchMethodValue.equals('7') && !String.isBlank(searchText)){
                    QueryBegin += ' AND Product__r.Name LIKE \'%'+searchText+'%\' ';
            }
            
            
            QueryBegin += ' AND Order__c != NULL ';
            List<Order_Line_Item__c> orderLineItemList = new List<Order_Line_Item__c>();
            
            if(selectedAction == 'transfer'){
                QueryBegin += ' AND EndDate__c > :currentDate AND Status__c != \'Expired\' ORDER BY ';
                if(orderId == '')
                    QueryBegin += 'Order__r.OrderDate__c Desc , Name ';
                else 
                    QueryBegin += 'Name ';
                orderLineItemList = Database.query(QueryBegin);
            }else {
                QueryBegin += ' ORDER BY ';
                if(orderId == '')
                    QueryBegin += 'Order__r.OrderDate__c Desc , StartDate__c Desc';
                else
                    QueryBegin += 'StartDate__c Desc';
                orderLineItemList = Database.query(QueryBegin);
            }
            
            Map<id,OrderWrap> OrderMap = new Map<id,OrderWrap>();
            
            for(Order_Line_Item__c oli : orderLineItemList){
                Order__c newOrder = new Order__c();
                newOrder.id = oli.Order__r.Id;
                newOrder.ExpectedStartDate__c = oli.Order__r.ExpectedStartDate__c;
                newOrder.OrderDate__c = oli.Order__r.OrderDate__c;
                newOrder.OrderStatus__c = oli.Order__r.OrderStatus__c;
                
                if(OrderMap!=null && !orderMap.isEmpty() && orderMap.containsKey(oli.Order__r.id)){
                    orderMap.get(oli.Order__r.id).lines.add(oli);
                }else{
                    OrderWrap WrapOrder = new OrderWrap();
                    WrapOrder.Order = newOrder;
                    WrapOrder.orderName = oli.Order__r.Name;
                    WrapOrder.lines.add(oli);
                    orderMap.put(oli.Order__r.id,WrapOrder);
                }
                
            }
            
        return OrderMap.values();
    }
//End
}