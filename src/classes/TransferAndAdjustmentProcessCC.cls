public with sharing class TransferAndAdjustmentProcessCC {
    final String CLASSNAME = '\n\n**** TransferAndAdjustmentProcessCC.METHODNAME()';
    private final Integer MAX_INIT_LINE_NUM = 5;
    private final String DEFAULT_PROCESS = 'adjustment';
    private final set<String> PROCESS_TYPE = new set<String>{'adjustment', 'transfer'};
    private transient Attachment myDocument;
    public list<Transfer_Adjustment_Transaction__c>  AdjustmentID;
    public Transfer_Adjustment_Transaction__c Adjustment ;
    public Id oldLicense;
    public Id transferFromXcode;

    public Attachment myDoc
    {
        get
        {
            if(myDocument==null)
            {
                myDocument = new Attachment();
            }
            return myDocument;
        }
        set;
    }

    public String ProcessType {
        get;
        set{
            if(PROCESS_TYPE.contains(value)){
                    ProcessType = value;
            }
        }
    }

    private String FromAccount;
    public String AccId{get;set;}

    private List<Id> RecordId;
    private string rId;
    private Id account_Id;
    public Order_Line_Item__c OrderLineItem {get; private set;}
    public Order_Line_Item__c[]  OrderLineItemList {get{return new Order_Line_Item__c[]{OrderLineItem};}}

    public LicenseIDWrap[] LicenseIDList {get;set;}
    //Added by Prashant Gupta (Appirio) S-445860 && S-483764, 10-May-17
    public List<LicenseIDWrap> SelectedLicenseIDList {get;set;}
    //ENd
    private LicenseID__c LicenseID;

    public LineWrapList[] LineWraps {get; set;}
    private map<Id,LineWrapList> LineWrapMap;
    public String LicenseIDClicked {get; set;}

    public LicenseID__c CurrentLicenseID {get{return LicenseID;}}
    public Boolean ShowTransferParts {get{return ProcessType != DEFAULT_PROCESS;}}
    public Boolean ShowAdjustmentParts {get{return !ShowTransferParts;}}
    public Boolean ShowListBlock {get; set;}

    public String LineToAdd {get; set;}
    public String ProcessTypeText {get{return ProcessType.capitalize();}}

    public SelectOption[] ProcessTypeOptionList {
        get{
            SelectOption[] options = new SelectOption[]{};
            if(ProcessType == DEFAULT_PROCESS){
                options.add(new SelectOption('adjustment','Adjustment'));
                options.add(new SelectOption('transfer','Transfer'));
            }else{
                options.add(new SelectOption('transfer','Transfer'));
                options.add(new SelectOption('adjustment','Adjustment'));
            }
            return options;
        }
    }

    public SelectOption[] AdjustmentTypeOptions {
        get{
            SelectOption[] options = new SelectOption[]{};
            options.add(new SelectOption('Increase','Increase'));
            options.add(new SelectOption('Decrease','Decrease'));
            return options;
        }
    }

    public Boolean DisableSave {get{return LineWraps == null || LineWraps.size() == 0;}}
    public String InitMessage {get{return DisableSave ? 'No selected License ID.' : '';}}

    public SelectOption[] LineNumOptionList {
        get{
            String[] values = new String[]{'1','2','3','5','10'};
            SelectOption[] options = new SelectOption[]{};
            for(String i : values){
                options.add(new SelectOption(i,i));
            }
            return options;
        }
    }

    public String[] AjaxOutput {get; set;}

    public String[] SyncStatus {get; set;}
    private map<String, Integer> SiteQuantityMap;

    public LicenseID__c[] LicenseNotSync  {get; set;}
    public LicenseID__c[] LicenseNotAvailable {get; set;}
    public LicenseID__c[] NullSiteLicense  {get; set;}
    public Boolean HasSyncError {get{ return LicenseNotSync.size() > 0 || LicenseNotAvailable.size() > 0 || NullSiteLicense.size() > 0;}}

    public TransferAndAdjustmentProcessCC(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','TransferAndAdjustmentProcessCC');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        ShowListBlock = true;
        if(ApexPages.currentPage().getParameters().containsKey('FromAccount')){
            FromAccount = ApexPages.currentPage().getParameters().get('FromAccount');
            //AccId = ApexPages.currentPage().getParameters().get('FromAccountId');
            account_Id = ApexPages.currentPage().getParameters().get('FromAccountId');
        }
        if(ApexPages.currentPage().getParameters().containsKey('type')){
            ProcessType = ApexPages.currentPage().getParameters().get('type');
        }
        ProcessType = PROCESS_TYPE.contains(ProcessType) ? ProcessType : DEFAULT_PROCESS;

        if(ApexPages.currentPage().getParameters().containsKey('Id')){
            //Mitali Nahar Appirio S-402215 4/4/2017 to handle bulk OrderLineItems
            rId = ApexPages.currentPage().getParameters().get('Id');
            RecordId = rid.split(',');
            System.debug('----RecordId ' + RecordId);
            init();
        }else{
            AddPageError('Error: no record ID to process.');
        }
        //Added by Prashant Gupta (Appirio) S-445860 && S-483764, 04-May-17
        SelectedLicenseIDList = new List<LicenseIDWrap>();
        //End
    }

    public void init(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','init');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            AjaxOutput = new String[]{};
            LineWraps = new LineWrapList[]{};
            LineWrapMap = new map<Id,LineWrapList>();

            Order_Line_Item__c[] OrderLineItemResult = [
                SELECT
                    Id,
                    Name,
                    Order__c,
                    Order__r.Account__c,
                    Order__r.OrderStatus__c,
                    Order__r.SiteDestination__c,
                    Order__r.RemainingCreditAmount__c,
                    EndDate__c,
                    AdjustmentReason__c,
                    AdjustmentType__c,
                    TrackingTicketID__c,
                    Notes__c,
                    Contract_Duration__c,
                    Has_Auto_Refresh__c,
                    Has_Bolding__c,
                    Job_Board_ID__c,
                    License_Provision_Method__c,
                    PostingDuration__c,
                    PostingLocationGroup__c,
                    PostingLocationGroupID__c,
                    Refresh_Interval__c,
                    Tier_Id__c,
                    Unlimited_Job_Postings__c,
                    Status__c,
                    Result__c,
                    ResultDescription__c,
                    (SELECT
                        Id,
                        Name,
                        OrderLineItem__c,
                        OrderLineItem__r.CreatedDate,
                        CreatedDate,
                        TransferAmount__c,
                        Xcode__c,
                        OriginalLicenseID__c,
                        Xcode__r.IntegrationXcode__c,
                        OrderLineItem__r.Quantity2__c,
                        AvailableInventory__c,
                        SiteLicenseID__c,
                        AdditionalActions__c,
                     	Product_Name__c//S-448898
                    FROM License_IDs__r
                    ORDER BY SiteLicenseID__c)
                FROM Order_Line_Item__c WHERE Id in :RecordId
            ];
            system.debug('OrderLineItemResult: ' + OrderLineItemResult);

            if(OrderLineItemResult.size() > 0){
                map<String, LicenseID__c> SFLicenseMap = new map<String, LicenseID__c>();
                Set<String> SFLicensesToSend = new Set<String>();
                NullSiteLicense = new LicenseID__c[]{};
                //Mitali Nahar Appirio S-402215 4/4/2017 for handling more than one OrderLineItems passed from the previous page
                //JFreese Appirio S-402215 4/15/2017 Fix indentation
                for( Order_Line_Item__c OrderLineItem1 : OrderLineItemResult){
                    OrderLineItem = OrderLineItem1;
                    //Ended

                    //JFreese Appirio S-402215 4/15/2017 Need to add OLI to a list, else it is just set to the last one

                    AccId = OrderLineItem.Order__r.Account__c;
                    long firstLicenseCreatedDate = 0;
                    long timeDiff = 0;
                    for(LicenseID__c lid : OrderLineItem.License_IDs__r){
                        /*S-445896 JFreese Appirio 12/1/16 only send one License ID to Site, to avoid APEX Heap error.
                          Per Apttus (Sivaganesh Ramakrishnan 13Nov2016) sending any license in a family
                          tree returns the whole tree structure, so we only need to send one.
                          NOTE:  We could make SFLicenseToSend just a String rather than a Set<String>,
                                 but by leaving it a set the changes in BizAppSiteModel are minimized.
                          S-460237 JFreese 01/06/17 This fix failed for Monster Complete Job Ad,
                          for which the original order gets 3 licenses, one for each of the 3 component products.
                          It appears that the concept of family is related to each component product,
                          not to the actual product.  So send all of the original license(s).*/
                        if (firstLicenseCreatedDate == 0){firstLicenseCreatedDate = lid.CreatedDate.getTime();}

                        if(lid.SiteLicenseID__c != null){
                            SFLicenseMap.put(lid.SiteLicenseID__c, lid);
                            timeDiff = lid.CreatedDate.getTime() - firstLicenseCreatedDate;
                            if (timeDiff < 120000){ //should be zero for all originals, but allow for 2 minutes
                                SFLicensesToSend.add(lid.SiteLicenseID__c);
                            }
                        }else{
                            NullSiteLicense.add(lid);
                        }
                    }
                    system.debug('SFLicenseMap=' + SFLicenseMap + '\nNullSiteLicense=' + NullSiteLicense);
                    system.debug('SFLicensesToSend='+SFLicensesToSend);

                    //Salesforce and Site quantity synchronization
                    SyncStatus = new String[]{};
                    if(!SFLicenseMap.isEmpty()){
                        if(!test.isRunningTest()){
                            SiteQuantityMap = BizAppsSiteModel.GetLicenseAndRelativesForCreditRequest(SFLicensesToSend);
                        }else{
                            SiteQuantityMap = new map<String, Integer>();
                            SiteQuantityMap.put('1234' ,123 );
                        }
                    }else{
                        SiteQuantityMap = new map<String, Integer>();
                    }
                    system.debug('SiteQuantityMap='+SiteQuantityMap);

                    LicenseNotAvailable = new LicenseID__c[]{};
                    LicenseNotSync = new LicenseID__c[]{};

                    for(String siteId : SFLicenseMap.keySet()){
                        if(SiteQuantityMap.containsKey(siteId)){
                            LicenseID__c currentLicense = SFLicenseMap.get(siteId);
                            if(currentLicense.AvailableInventory__c != SiteQuantityMap.get(siteId)){
                                LicenseNotSync.add(currentLicense);
                                system.debug('License Not Synched: ID=' + currentLicense.Id + ', AvailableInventory__c=' + currentLicense.AvailableInventory__c + ', Site Inventory=' + SiteQuantityMap.get(siteId));
                            }
                        }else{
                            licenseNotAvailable.add(SFLicenseMap.remove(siteId));
                            system.debug ('License Not Available: siteID=' + siteId);
                        }
                    }

                    //creating lines
                    LicenseIDList = new LicenseIDWrap[]{};
                    if(!SFLicenseMap.isEmpty()){
                        for(LicenseID__c lid : SFLicenseMap.values()){
                            if(lid.SiteLicenseID__c != null){
                                    LicenseIDWrap item = new LicenseIDWrap(lid);
                                    LicenseIDList.add(item);
                                    system.debug('Adding License ID ' + lid.Id + ', SiteLicenseID__c=' + lid.SiteLicenseID__c);
                            }
                        }
                    }
                    checkEligibilityOfTransfer();
                    //Mitali Nahar Appirio S-402215 4/4/2017
                   // return;
                }
           // AjaxOutput.add('Init Error: No Order Line Item retrieved.');
           //Ended
            }else{ //JFreese Appirio S-402215 4/15/2017
                AjaxOutput.add('Init Error: No Order Line Item retrieved.');
            }
        }catch(Exception e){
            AjaxOutput.add('Init Error: ' + e);
        }
    }

    private void checkEligibilityOfTransfer(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','checkEligibilityOfTransfer');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        ShowListBlock = true;
        AjaxOutput.clear();
        Boolean hasError = false;
        if(ProcessType != DEFAULT_PROCESS){
            if(OrderLineItem.Order__r.OrderStatus__c != 'Verified' && OrderLineItem.Order__r.OrderStatus__c != 'Paid in Full' && OrderLineItem.Order__r.OrderStatus__c != 'Invoiced'
               && OrderLineItem.Order__r.OrderStatus__c != 'Closed' && OrderLineItem.Order__r.OrderStatus__c != 'Sent To Verification' && OrderLineItem.Order__r.OrderStatus__c != 'Finance Hold'){
                    AjaxOutput.add('Invalid Order Status: ' + OrderLineItem.Order__r.OrderStatus__c);
                    hasError = true;
            }
            if(OrderLineItem.Order__r.RemainingCreditAmount__c <= 1){
                    AjaxOutput.add('Invalid Order Remaining Credit Amount: ' + OrderLineItem.Order__r.RemainingCreditAmount__c);
                    hasError = true;
            }
            if(OrderLineItem.EndDate__c <= system.today()){
                    AjaxOutput.add('Invalid Order Line Item End Date: ' + OrderLineItem.EndDate__c.format());
                    hasError = true;
            }
            if(OrderLineItem.Status__c == 'Expired'){
                    AjaxOutput.add('Invalid Order Line Item Status: ' + OrderLineItem.Status__c);
                    hasError = true;
            }
            if(OrderLineItem.License_IDs__r == null || OrderLineItem.License_IDs__r.isEmpty()){
                    AjaxOutput.add('No licenses to transfer.');
                    hasError = true;
            }
            if(hasError){
                    ShowListBlock = false;
                    AjaxOutput.add('');
            }
        }
    }

    public void AddLicense(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','AddLicense');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            AjaxOutput.clear();
            LineWraps.clear();
            LineWrapMap.clear();
            //Added by Prashant Gupta (Appirio) S-445860 && S-483764, 04-May-17
            SelectedLicenseIDList.clear();
            //End
            for(LicenseIDWrap wrap : LicenseIDList){
                if(wrap.IsAdded){
//                    Object initLines = wrap.LicenseID.OrderLineItem__r.Quantity2__c < MAX_INIT_LINE_NUM ? wrap.LicenseID.OrderLineItem__r.Quantity2__c : MAX_INIT_LINE_NUM;
                    //JFreese S-447283 extra fix: set and limit lines to available, not original provision
                    Object initLines = wrap.LicenseID.AvailableInventory__c < MAX_INIT_LINE_NUM ? wrap.LicenseID.AvailableInventory__c : MAX_INIT_LINE_NUM;
                    initLines = ProcessType == DEFAULT_PROCESS ? 1 : initLines;
                    system.debug('initLines='+initLines);

                    LineWrapList oLineWrapList = new LineWrapList();
                    oLineWrapList.ParentLicenseId = wrap.LicenseID;
                    oldLicense = wrap.LicenseID.Id;
                    transferFromXcode = wrap.LicenseID.Xcode__c;
                    oLineWrapList.LineWraps = new LineWrap[]{};

                    system.debug('oLineWrapList='+oLineWrapList);

                    AddLines(initLines, oLineWrapList);
                    LineWrapMap.put(oLineWrapList.ParentLicenseId.Id, oLineWrapList);
                    LineWraps.add(oLineWrapList);
                    //Added by Prashant Gupta (Appirio) S-445860 && S-483764, 04-May-17
                    SelectedLicenseIDList.add(wrap);
                    //End
                }
            }
            system.debug('LineWraps=' + LineWraps);
        }catch(Exception e){
            AddPageError('Init Error: ' + e);
            AddPageError('Trace: ' + e.getStackTraceString());
        }
    }

    private void AddPageError(String txt){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','AddPageError');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        ApexPages.Message PageError = new ApexPages.Message(ApexPages.Severity.FATAL, txt);
        ApexPages.addMessage(PageError);
    }

    private void AddLines(Object pLineCount, LineWrapList pLineWrapList){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','AddLines');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        for(Integer i = 0; i < ParseInt(pLineCount); i++){
            pLineWrapList.LineWraps.add(new LineWrap());
        }
    }

    private Integer ParseInt(Object pNum){
        return pNum == null ? 0 : Integer.valueOf(pNum);
    }

    public void DeleteLines(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','DeleteLines');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        AjaxOutput.clear();
        LineWrapList wrapList = LineWrapMap.get(Id.valueOf(LicenseIDClicked));
        if(wrapList != null){
            Integer lineCount = ParseInt(wrapList.LineToAdd);
            system.debug('LineWraps.size()=' + LineWraps.size() + ', linecount=' + linecount);
            if(wrapList.LineWraps.size() == 1){
                AjaxOutput.add('Unable to delete last line.');
            }else if(lineCount > wrapList.LineWraps.size()){
                AjaxOutput.add('Unable to delete more than ' + String.valueOf(wrapList.LineWraps.size() - 1) + ' line(s).');
            }
            Integer endCount = (wrapList.LineWraps.size() - lineCount);
            endCount = endCount < 1 ? 1 : endCount;
            for(Integer i = wrapList.LineWraps.size(); i > endCount; i--){
                    wrapList.LineWraps.remove(i - 1);
            }
        }
    }

    public void CreateLines(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','CreateLines');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        AjaxOutput.clear();
        LineWrapList wrapList = LineWrapMap.get(Id.valueOf(LicenseIDClicked));
        if(wrapList != null){
            Integer lineCount = ParseInt(wrapList.LineToAdd);
            Integer addableLines = Integer.valueOf(wrapList.ParentLicenseId.AvailableInventory__c - wrapList.LineWraps.size());
            //JFreese S-447283 extra fix: set and limit lines to available, not original provision & clean up messaging
            system.debug('Available=' + wrapList.ParentLicenseId.AvailableInventory__c +
                         ', wrapList.LineWraps.size()=' + wrapList.LineWraps.size() +
                         ', addableLines=' + addableLines +
                         ', lineCount=' + lineCount);
            if((lineCount + wrapList.LineWraps.size()) <= wrapList.ParentLicenseId.AvailableInventory__c){
                AddLines(lineCount, wrapList);
            }else{
                AjaxOutput.add('Lines can not exceed quantity of Order Line Item.');
                if (addableLines == 0){
                    AjaxOutput.add('You cannot add any more lines.');
                }else {
                    AjaxOutput.add('You can only add ' + addableLines + ' more line(s).');
                }
                AjaxOutput.add('Current Number of Line(s): ' + wrapList.LineWraps.size());
                AjaxOutput.add('Current Available Inventory: ' + Integer.valueOf(wrapList.ParentLicenseId.AvailableInventory__c));
            }
            return;
        }
    }

    public void ChangeProcess(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','ChangeProcess');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        AjaxOutput.clear();
        AddLicense();
        checkEligibilityOfTransfer();
    }

    public void SyncLicenses(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','SyncLicenses');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        AjaxOutput.clear();
        try{
            LicenseID__c[] syncedLiceseList = new LicenseID__c[]{};
            for(LicenseID__c unsynced : LicenseNotSync){
                if(SiteQuantityMap.containsKey(unsynced.SiteLicenseID__c)){
                    unsynced.AvailableInventory__c = SiteQuantityMap.get(unsynced.SiteLicenseID__c);
                    syncedLiceseList.add(unsynced);
                }
            }
            if(!syncedLiceseList.isEmpty()){
                update syncedLiceseList;
                AjaxOutput.add('Successfully synchronized ' + syncedLiceseList.size() + ' License(s).');
            }
        }catch(Exception e){
            system.debug('\n\nError: ' +e+ '\n\n' + e.getStackTraceString() + '\n\n');
            AjaxOutput.add('An error occured while synchronizing quantities.');
        }
    }

    public PageReference Save(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','Save');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        AjaxOutput.clear();
        String[] saveOutput = new String[]{};
        map<Id,map<Id, TransferAndAdjustmentProcessCC.LineWrapList[]>> pLineWrapswithLicense = new map<Id,map<Id, TransferAndAdjustmentProcessCC.LineWrapList[]>>();
        map<Id, map<Id, Order_Line_Item__c>> pOrderLineItemMapwithLicense = new map<Id, map<Id, Order_Line_Item__c>>();
        List<Transfer_Adjustment_Transaction__c> adjustments = new List<Transfer_Adjustment_Transaction__c>();
        List<id> oldLicenseIdList = new List<Id>();
        map<Id, Decimal> mapLicenseWithOldInventory = new Map<Id, Decimal>();
        map<Id, Decimal> mapLicenseWithNewInventory = new Map<Id, Decimal>();
        map<Id, Id> oldtoNewLicenseId = new map<Id,Id>();
        map<Id, Decimal> mapOldLicenseTooriginalQuantity = new map<Id,Decimal>();
        map<Id, Decimal> mapOldLicenseToupdatedQuantity = new map<Id,Decimal>();
        List<Transfer_Adjustment_Transaction__c> transfers = new List<Transfer_Adjustment_Transaction__c>();
        map<Id, Set<Id>> licensetoLicenseIdSet = new map<Id, Set<Id>>();

        system.debug('LicenseIDList='+LicenseIDList);
        system.debug('LineWraps='+LineWraps);

        /*S-447283 Jfreese 10/19/16 No changes to this method other than adding system.debugs.
          This logic is not creating Transfer_Adjustment_Transaction__c records properly
          (at least for transfers).  It is creating a record for each element in the LicenseIDList,
          using the first populated AccXId in the linewraps to set the transfer_To.
          Instead it should be walking through the LineWraps heirarchy once, making a Transfer_Adjustment_Transaction__c
          record for each lineWrap which has both the amount and AccXId set (and throw an error if only one of the
          two is set).  Also, the transfer updates after the callout to BizAppsSiteModel are not working.
          These problems are way outside the scope of this story and may be fixed under a future issue*/
        
        //Added by Prashant Gupta (Appirio) S-445860 && S-483764, 04-May-17
        for(LicenseIDWrap wrap : SelectedLicenseIDList){
        //End
            system.debug('\n^^^Processing License ID ' + wrap.LicenseID.Name);
            if(wrap.IsAdded){
                oldLicense = wrap.LicenseID.Id;
                transferFromXcode = wrap.LicenseID.Xcode__c;

                oldLicenseIdList.add(oldLicense);
                system.debug('wrap.IsAdded=' + wrap.IsAdded + ', oldLicense=' + oldLicense + ', transferFromXcode=' + transferFromXcode);
            }

            String adjustType;
            string transfer_To;
            Id transferTo;
            //Added by Prashant Gupta (Appirio) S-445860 && S-483764, 04-May-17
            //system.debug('Number of LID sections selected: LineWraps.size()=' + LineWraps.size());
            /* 
            //commented out to replace with newer updated code
            for(integer i = 0; i < LineWraps.size(); i++){
                for(integer j =0; j<LineWraps[i].LineWraps.size();j++){
                    if(LineWraps[i].LineWraps[j].AccXId != null){
                        transfer_To = LineWraps[i].LineWraps[j].AccXId;
                        if(transfer_To!=null && transfer_To != ''){
                            transferTo = Id.valueOf(transfer_To);
                            system.debug('i=' + i + ', j=' + j + 'transfer_To=' + transferTo + ', Amount=' + LineWraps[i].LineWraps[j].Amount);
                        }
                        break;
                    }
                }
            }
            */
            
            for(LineWrapList LWrap : LineWraps){
                if(LWrap.ParentLicenseId.ID == wrap.LicenseID.ID)
                    for(LineWrap lnWrap : LWrap.LineWraps){
                        if(LnWrap.AccXId != null){
                            transfer_To = LnWrap.AccXId;
                            if(transfer_To!=null && transfer_To != ''){
                                transferTo = Id.valueOf(transfer_To);
                                system.debug('transfer_To=' + transferTo + ', Amount=' + LnWrap.Amount);
                            }
                            break;
                        }
                    }
            }
            //End
            LicenseID__c newLicenseID = null;

            for(integer k =0; k< OrderLineItemList.size();k++){
                if(OrderLineItemList.get(k).AdjustmentType__c!=null){
                    adjustType = OrderLineItemList.get(k).AdjustmentType__c;
                    break;
                }
            }
            if(ProcessType == DEFAULT_PROCESS){//Adjustment
                map<Id, TransferAndAdjustmentProcessCC.LineWrapList[]> pLineWraps = new map<Id, TransferAndAdjustmentProcessCC.LineWrapList[]>();
                pLineWraps.put(OrderLineItem.Id, LineWraps);
                pLineWrapswithLicense.put(oldLicense, pLineWraps);
                map<Id, Order_Line_Item__c> pOrderLineItemMap = new map<Id, Order_Line_Item__c>();
                pOrderLineItemMap.put(OrderLineItem.Id, OrderLineItem);
                pOrderLineItemMapwithLicense.put(oldLicense, pOrderLineItemMap);
                //Decimal OldInventory = [SELECT Id,AvailableInventory__c FROM LicenseID__c where ID =: oldLicense LIMIT 1].AvailableInventory__c;
                //if(!test.isRunningTest())
                //saveOutput.addAll(BizAppsSiteModel.AdjustmentIntegrationProcess(pLineWraps, pOrderLineItemMap));
                Transfer_Adjustment_Transaction__c adjustment = new Transfer_Adjustment_Transaction__c();
                adjustment.Account__c = account_Id;
                adjustment.Order_ID__c = OrderLineItem.Order__c;
                adjustment.Transfer_Adjustment_Date__c = system.today();
                adjustment.Transferred_From_XCode__c  = transferFromXcode;
                adjustment.Old_License_ID__c = oldLicense;
                // added per I-208945
                adjustment.Notes__c = OrderLineItem.Notes__c;

                //adjustment.Transferred_To_XCode__c = transferTo;
                adjustment.Adjustment_Type__c = adjustType;
                adjustments.add(adjustment);
                //insert adjustment;
                //System.assert(false,adjustment.Id);

                //AdjustmentID = adjustment.Id;

                // if(transferTo !=null){ not populated for an adjustment
                //  for(LicenseID__c licence: [select NAme from LicenseID__c WHERE Xcode__c =: transferTo
                //                                   ORDER BY CreatedDate LIMIT 1]){
                //           newLicenseID = licence;
                //  }
                //}
                //Decimal newInventory = [SELECT Id,AvailableInventory__c FROM LicenseID__c where ID =: oldLicense].AvailableInventory__c;
                    //if(!test.isRunningTest())
                    //if(newLicenseID != null){ not populated for an adjustment
                     //adjustment.New_License_ID__c = newLicenseID.Id;
                     //adjustment.Original_Quantity__c = OldInventory;
                     //adjustment.Updated_Quantity__c = newInventory;
                     //update adjustment;
                //}


            }else{//transfer
                //saveOutput.addAll(BizAppsSiteModel.TransferIntegrationProcess(LineWraps, OrderLineItem));

                Transfer_Adjustment_Transaction__c transfer = new Transfer_Adjustment_Transaction__c();
                transfer.Account__c = account_Id;
                transfer.Order_ID__c = OrderLineItem.Order__c;
                transfer.Transfer_Adjustment_Date__c = system.today();
                transfer.Old_License_ID__c = oldLicense;

                transfer.Transferred_From_XCode__c  = transferFromXcode;
                transfer.Transferred_To_XCode__c = transferTo;
                // added per I-208945
                transfer.Notes__c = OrderLineItem.Notes__c;
                system.debug('Transfer transaction: oldLicense=' + oldLicense + ', transferFromXcode=' + transferFromXcode + ', transferTo=' + transferTo);
                //transfer.Adjustment_Type__c = adjustType;
                transfers.add(transfer);
                 //AdjustmentID = transfer.Id;
                /*
                if(transferTo !=null){
                  for(LicenseID__c licence: [select NAme from LicenseID__c WHERE Xcode__c =: transferTo
                                                   ORDER BY CreatedDate DESC LIMIT 1]){
                           newLicenseID = licence;
                  }
                }
                if(newLicenseID == null){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select a Transfer to Xcode from the lookup');
                    ApexPages.addMessage(myMsg);
                    return null;
                }
                oldtoNewLicenseId.put(oldLicense, newLicenseID.Id);
                Set<ID> licenseIdSet = new Set<Id>{newLicenseID.Id,oldLicense};
                licensetoLicenseIdSet.put(oldLicense, licenseIdSet);
                Map<Id,Decimal> licenseToInventoryMap = new Map<Id,Decimal>();
                for(LicenseID__c license: [SELECT Id,AvailableInventory__c FROM LicenseID__c where ID IN :licenseIdSet]){

                    licenseToInventoryMap.put(license.Id,license.AvailableInventory__c);
                }
                Decimal originalQuantity = licenseToInventoryMap.get(oldLicense) + licenseToInventoryMap.get(newLicenseID.Id);
                mapOldLicenseTooriginalQuantity.put(oldLicense, originalQuantity);
                Decimal updatedQuantity = licenseToInventoryMap.get(oldLicense);
                mapOldLicenseToupdatedQuantity.put(oldLicense, updatedQuantity);
                */
                //if(newLicenseID != null){

                    //transfer.New_License_ID__c = newLicenseID.Id;
                    //transfer.Original_Quantity__c = originalQuantity;
                    //transfer.Updated_Quantity__c = updatedQuantity;
                    //update transfer;
                 //}
            }
     // }
        } //end of for(LicenseIDWrap wrap : LicenseIDList)

        List<Transfer_Adjustment_Transaction__c> updateAdjustments = new List<Transfer_Adjustment_Transaction__c>();
        List<Transfer_Adjustment_Transaction__c> updatetransfers = new List<Transfer_Adjustment_Transaction__c>();

        if(ProcessType == DEFAULT_PROCESS){//Adjustment
            for(LicenseID__c license : [SELECT Id,AvailableInventory__c FROM LicenseID__c where ID IN: oldLicenseIdList ]){
                mapLicenseWithOldInventory.put(license.Id, license.AvailableInventory__c);
            }
            for(Id licenseId : oldLicenseIdList){
                saveOutput.addAll(BizAppsSiteModel.AdjustmentIntegrationProcess(pLineWrapswithLicense.get(licenseId), pOrderLineItemMapwithLicense.get(licenseId)));
            }
            Database.Insert(adjustments);
            AdjustmentID = adjustments;
            for(LicenseID__c license : [SELECT Id,AvailableInventory__c FROM LicenseID__c where ID IN: oldLicenseIdList ]){
                mapLicenseWithNewInventory.put(license.Id, license.AvailableInventory__c);
            }
            for(Transfer_Adjustment_Transaction__c adjustment : adjustments){
                Transfer_Adjustment_Transaction__c adj = new Transfer_Adjustment_Transaction__c();
                adj.Id = adjustment.Id;
                adj.Original_Quantity__c = mapLicenseWithOldInventory.get(adjustment.Old_License_ID__c);
                adj.Updated_Quantity__c = mapLicenseWithNewInventory.get(adjustment.Old_License_ID__c);
                updateAdjustments.add(adj);

            }
            Database.Update(updateAdjustments);
        } else {//Transfer
            system.debug('Before Bizapps - LineWraps='+LineWraps);
            saveOutput.addAll(BizAppsSiteModel.TransferIntegrationProcess(LineWraps, OrderLineItem));
            //Updated by Prashant Gupta (Appirio) S-445860 && S-483764, 04-May-17
            Map<id,LicenseID__c> newLicenseMap = new Map<id,LicenseID__c>();
            if(BizAppsSiteModel.newLicenseMap!=null && !BizAppsSiteModel.newLicenseMap.isempty())
                newLicenseMap = BizAppsSiteModel.newLicenseMap;
            //End
            system.debug('After Bizapps - LineWraps='+LineWraps);
            system.debug('OrderLineItem='+OrderLineItem);
            system.debug('saveOutput='+saveOutput);
            system.debug('transfers='+transfers);
            Database.Insert(transfers);
            AdjustmentID = transfers;
            for(Transfer_Adjustment_Transaction__c transfer : transfers){
                Transfer_Adjustment_Transaction__c trns = new Transfer_Adjustment_Transaction__c();
                trns.Id = transfer.Id;
                //transfer.New_License_ID__c = oldtoNewLicenseId.get(transfer.Old_License_ID__c);
                //transfer.Original_Quantity__c = mapOldLicenseTooriginalQuantity.get(transfer.Old_License_ID__c);
                //transfer.Updated_Quantity__c = mapOldLicenseToupdatedQuantity.get(transfer.Old_License_ID__c);
                //Updated by Prashant Gupta (Appirio) S-445860 && S-483764, 04-May-17
                system.debug('<<newLicenseMap>>' + newLicenseMap);
                //transfer.New_License_ID__c =  LineWraps[0].LineWraps[0].License.Id;//oldtoNewLicenseId.get(transfer.Old_License_ID__c);
                transfer.New_License_ID__c = newLicenseMap.get(transfer.Old_License_ID__c).id;
                //ENd
                transfer.Original_Quantity__c = LineWraps[0].LineWraps[0].License.AvailableInventory__c ;//mapOldLicenseTooriginalQuantity.get(transfer.Old_License_ID__c);
                transfer.Updated_Quantity__c = LineWraps[0].LineWraps[0].License.AvailableInventory__c; //mapOldLicenseToupdatedQuantity.get(transfer.Old_License_ID__c);
                system.debug('transfer.ID=' + transfer.Id + ', transfer.New_License_ID__c=' + transfer.New_License_ID__c + ', transfer.Original_Quantity__c=' + transfer.Original_Quantity__c + ',transfer.Updated_Quantity__c=' + transfer.Updated_Quantity__c);
                system.debug('trns.ID=' + trns.Id + ', trns.New_License_ID__c=' + trns.New_License_ID__c + ', trns.Original_Quantity__c=' + trns.Original_Quantity__c + ',trns.Updated_Quantity__c=' + trns.Updated_Quantity__c);
                //Updated by Prashant Gupta (Appirio) S-445860 && S-483764, 04-May-17
                updatetransfers.add(transfer);
                //End
            }
            Database.Update(updatetransfers);
        }
        AjaxOutput.addAll(saveOutput);
        return null;
    }


    public PageReference upload(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','upload');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        if(AdjustmentID == null){
            ApexPages.Message PageError = new ApexPages.Message(ApexPages.Severity.FATAL, 'Please save the adjustment before uploading the attachment');
            ApexPages.addMessage(PageError);
            return null;
        }
        try{
            /*if(myDoc.Id == null) {
                list<attachment> lstAttachmentToinsert = new list<attachment>();
                for(Transfer_Adjustment_Transaction__c adId : AdjustmentID){
                    attachment a = new attachment ();
                    a.parentId = adId.id;
                    lstAttachmentToinsert.add(a);
                }

                insert lstAttachmentToinsert;

            }
            else {*/
            Attachment newAttach;
            list<Attachment> lstAttachmentToInsert = new list<Attachment> ();
            for(Transfer_Adjustment_Transaction__c adId : AdjustmentID){
                newAttach = new Attachment();
                newAttach.Body =  myDoc.Body;
                newAttach.Name =  myDoc.Name;
                newAttach.parentId = adId.id;
                lstAttachmentToInsert.add(newAttach);
                //insert newAttach;
                //myDoc = newAttach;
            }
            if(!lstAttachmentToInsert.isempty()){
                insert lstAttachmentToInsert;
                myDoc = lstAttachmentToInsert[0];
            }
            //}
        } catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment' + e.getmessage()));
            return null;
        }
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));
        return new PageReference(getUploadURL());
    }

    public String getUploadURL(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','getUploadURL');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        if(FromAccount != null && FromAccount == 'true' && OrderLineItem.Order__r.Account__c != null){
            return '/apex/TransferAndAdjustmentProcess?FromAccount=' +FromAccount + '&FromAccountId=' + OrderLineItem.Order__r.Account__c + '&Id' + OrderLineItem.Id + '&type=' +   ProcessType ;
        }
        return '/' + RecordId;
    }



    public PageReference Back(){
        return new PageReference(getBackURL());
    }

    public String getBackURL(){
        if(FromAccount != null && FromAccount == 'true' && OrderLineItem.Order__r.Account__c != null){
                return '/apex/TransferAdjustmentAccountAccess?AccountID=' + OrderLineItem.Order__r.Account__c;
        }
        return '/' + RecordId;
    }

    public class LineWrapList{
        public String LineToAdd {get; set;}
        public LineWrap[] LineWraps {get; set;}
        public LicenseID__c ParentLicenseId {get; set;}
    }

    public class LineWrap{
        public Integer Amount {get; set;}
        public LicenseID__c License {get; set;}
        public String AccXcode {get; set;}
        public String AccXId {get; set;}
        public String AccId {get; set;}

        public LineWrap(){
            License = new LicenseID__c();
            Amount = 0;
            AccXcode = '';
            AccXId = '';
            AccId = '';
        }
    }

    public class LicenseIDWrap{
        public LicenseID__c LicenseID {get; set;}
        public Boolean IsAdded {get; set;}

        public LicenseIDWrap(LicenseID__c pLicenseID){
            IsAdded = false;
            LicenseID = pLicenseID;
        }
    }
}