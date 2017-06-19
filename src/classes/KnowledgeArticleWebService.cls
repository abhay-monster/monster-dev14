/**
 * Appirio, Inc
 * Name             : KnowledgeArticleWebService
 * Created Date     : 11 Sept 2015
 * Created By       : Shailendra Singh (Appirio)
 * Description      : SOAP webservice to fetch Knowledge Article based on provided filter
 */
global class KnowledgeArticleWebService {

	// fetch Knowledge article based on provided filter
    /*webService static List<CSH__kav> RunAnalyticsReport(Filter filter) {
    	List<CSH__kav> records = Database.query(buildQuery(filter));
        return records;
    }*/



    /* Testing by Jeff L will fetch knowledge upon Knowledge article based on provided RunAnalyticsReport Object*/
    webService static CSVTableSetWrapper RunAnalyticsReport(AnalyticsReport AnalyticsReport, String Delimiter) {
        Filter filter = new Filter();
        for(Filters fil : AnalyticsReport.Filters){
            if(fil.Name == 'm_id'){
                filter.m_id = fil.values;
            }
            if(fil.Name == 'interface_id'){
                filter.interface_id = fil.values;
            }
            if(fil.Name == 'access_id'){
                filter.access_id = fil.values;
            }
        }
        List<CSH__kav> records = Database.query(buildQuery(filter));
        CSVTableSetWrapper csvwT = new CSVTableSetWrapper();
        List<CSVTableSet> tablesetList = new List<CSVTableSet>();
        system.debug('Delimiter RunAnalyticsReport ' + Delimiter);
        if(records.size() > 0 ) { // TKOM S-473219: Added check for empty list to prevent ListException errors.
					tablesetList.add(processIntoTableSet(records[0], Delimiter));
				}
        csvwt.CSVTableSet = tablesetList;

        return csvwt;
    }

    /*********************************************************************/
    /*Used For Jeff L Testing!!!
    // Testing by Jeff L. fetch Knowledge article based on provided filter
    webService static String RunAnalyticsReport2(AnalyticsReport AnalyticsReport, String Delimiter) {
        Filter filter = new Filter();
        for(Filters fil : AnalyticsReport.Filters){
            if(fil.Name == 'm_id'){
                filter.m_id = fil.values;
            }
            if(fil.Name == 'interface_id'){
                filter.interface_id = fil.values;
            }
            if(fil.Name == 'access_id'){
                filter.access_id = fil.values;
            }
        }
        List<CSH__kav> records = Database.query(buildQuery(filter));
        Dom.Document doc = new Dom.Document();
        String nameSpace = 'urn:messages.ws.rightnow.com/v1_2';
        String prefix = 'n0';
        doc.createRootElement('RunAnalyticsReportResponse',nameSpace,prefix);
        system.debug('XML' + doc.toXmlString());
        return doc.toXmlString();
    }*/

    private static CSVTableSet processIntoTableSet(CSH__kav article, string pdelimiter){
        CSVTableSet returnTableSet;
        if(article == null){
            return null;
        } else{
            system.debug('Delimiter!! processIntoTableSet ' + pdelimiter);
            returnTableSet = new CSVTableSet(article, pdelimiter);
        }
        system.debug('ReturnTableSet! ' + returnTableSet);
        return returnTableSet;
    }


    /**
     * Appirio, Inc
     * Name             : CSVTableSetWrapper
     * Created Date     : 03 Nov 2015
     * Created By       : Jeff Lescarbeau (Appirio)
     * Description      : Class used to mimic legacy webservice class for Monster, utilized in KnowledgeArticleWebService.cls
     */
    global class CSVTableSetWrapper {
        webservice List<CSVTableSet> CSVTableSet;
        public CSVTableSetWrapper(){

        }
    }

    /**
     * Appirio, Inc
     * Name             : CSVTableSet
     * Created Date     : 03 Nov 2015
     * Created By       : Jeff Lescarbeau (Appirio)
     * Description      : Class used to mimic legacy webservice class for Monster, utilized in KnowledgeArticleWebService.cls
     *                    This one has some extra logic that puts together the structure for the child classes (columns, rows etc)
     *                    The reason we do this is so that our SOAP api response looks similar to what Monster used previously
     */
    global class CSVTableSet {
        FINAL STRING QUESTION = '""';
        FINAL STRING PLATFORM = 'EveryoneNotLoggedIn,Help,HX,FX,HQ,SMAP,FXSlotted';
        FINAL STRING CATEGORY = 'Support';
        FINAL STRING STATUS = 'Private';
        FINAL STRING WEIGHT = '100';
        String delimiter {get;set;}

        public CSVTableSet() {

        }

        public CSVTableSet(CSH__kav article, String pdelimiter){
            delimiter = pdelimiter;
            system.debug('Delimiter! ' + pdelimiter);
            constructCSVTable(article);
        }

        webservice List<CSVTableListcls> CSVTables;

        private void constructCSVTable(CSH__kav article){
            system.debug('delimiter! constructCSVTable ' + delimiter);
            if(delimiter == null){
                delimiter = '|';
            }
            String row = '';
            row += article.Id + delimiter;
            row += article.m_Id__c + delimiter;
            row += article.Title + delimiter;
            //row += '"' + article.Question__c + '"' + delimiter;
            row += QUESTION + delimiter;
            row += '"' + article.Article_Text__c + '"' + delimiter;
            row += article.language + delimiter;
            row += '"' + PLATFORM + '"' + delimiter;
            row += CATEGORY + delimiter;
            row += STATUS + delimiter;
            row += WEIGHT + delimiter;

            system.debug('Row text' + row);
            CSVTablecls csvT = new CSVTablecls(row, delimiter);
            CSVTableListcls csvTL = new CSVTableListcls();

            csvTL.CSVTable = new List<CSVTablecls>();
            csvTL.CSVTable.add(csvT);

            CSVTables = new List<CSVTableListcls>();
            CSVTables.add(csvTL);
        }
    }

    /**
     * Appirio, Inc
     * Name             : CSVTableListcls
     * Created Date     : 03 Nov 2015
     * Created By       : Jeff Lescarbeau (Appirio)
     * Description      : Class used to mimic legacy webservice class for Monster, utilized in KnowledgeArticleWebService.cls
     */
    global class CSVTableListcls {
        webservice List<CSVTablecls> CSVTable;
        public CSVTableListcls(){

        }
    }

    /**
     * Appirio, Inc
     * Name             : CSVTablecls
     * Created Date     : 03 Nov 2015
     * Created By       : Jeff Lescarbeau (Appirio)
     * Description      : Class used to mimic legacy webservice class for Monster, utilized in KnowledgeArticleWebService.cls
     */
    global class CSVTablecls {
        webservice List<CSVRowClass> Rows;
        webservice String Columns;
        FINAL STRING COLUMNTEXT = 'Answer ID|Meta-Answer ID|Summary|Question|Answer|Language|Access Level|Category|Status|Weight';

        public CSVTablecls(){
        }

        public CSVTablecls(String rowString, String pdelimiter){
            Columns = '';
            //probably shouldn't hard code this, but the information is needed in this exact format by the integration
            Columns += 'Answer ID' + pdelimiter;
            Columns += 'Meta-Answer ID' + pdelimiter;
            Columns += 'Summary' + pdelimiter;
            Columns += 'Question' + pdelimiter;
            Columns += 'Answer' + pdelimiter;
            Columns += 'Language' + pdelimiter;
            Columns += 'Access Level' + pdelimiter;
            Columns += 'Category' + pdelimiter;
            Columns += 'Status' + pdelimiter;
            Columns += 'Weight';

            CSVRowClass csvrc = new CSVRowClass(rowString);
            Rows = new List<CSVRowClass>();
            Rows.add(csvrc);
        }
    }

    /**
     * Appirio, Inc
     * Name             : CSVRowClass
     * Created Date     : 03 Nov 2015
     * Created By       : Jeff Lescarbeau (Appirio)
     * Description      : Class used to mimic legacy webservice class for Monster, utilized in KnowledgeArticleWebService.cls
     */
    global class CSVRowClass {
        webservice String Row;
        public CSVRowClass(){
        }

        public CSVRowClass(String rowString){
            Row = rowString;
        }

    }

    /**
     * Appirio, Inc
     * Name             : Analytics Report
     * Created Date     : 03 Nov 2015
     * Created By       : Jeff Lescarbeau (Appirio)
     * Description      : Class used to mimic legacy webservice class for Monster, utilized in KnowledgeArticleWebService.cls
     */
    global class AnalyticsReport {
        public AnalyticsReport() {

        }

        webservice List<Filters> Filters;
    }

    /**
     * Appirio, Inc
     * Name             : Filters
     * Created Date     : 03 Nov 2015
     * Created By       : Jeff Lescarbeau (Appirio)
     * Description      : Class used to mimic legacy webservice class for Monster, utilized in KnowledgeArticleWebService.cls
     */
    global class Filters{
    webservice String Name;
    webservice String Values;

        public Filters(){

        }
    }

    // translate interface id to language code by looking into custom setting
    private static String translateInterfaceIdToLangCode(String interfaceID) {
    	String langCode = null;
    	Map<String, CSH_Interface_ID__c>  cshInterface = CSH_Interface_ID__c.getAll();
    	for(CSH_Interface_ID__c csh : cshInterface.values()) {
    		if(interfaceID == csh.Identifier__c) {
    			langCode = csh.LangaugeCode__c;
    		}
    	}
    	return langCode;
    }

    // build query to fetch Article by provided filter
    private static String buildQuery(Filter filter) {
    	String langCode = translateInterfaceIdToLangCode(filter.interface_id);
        String queryString;

        if(filter.m_id.startswith('kA')){
            queryString = 'Select id, title, Summary, Article_Text__c, m_id__c, Language From CSH__kav c Where KnowledgeArticleId = \'' + String.escapeSingleQuotes(filter.m_id) + '\' AND Language = \'' + String.escapeSingleQuotes(langCode) + '\' and publishstatus = \'Online\' and islatestversion = true limit 1';
        }
        else if(filter.m_id.startswith('ka')){
            queryString = 'Select id, title, Summary, Article_Text__c, m_id__c, Language From CSH__kav c Where Id = \'' + String.escapeSingleQuotes(filter.m_id) + '\' AND Language = \'' + String.escapeSingleQuotes(langCode) + '\' and publishstatus = \'Online\'';
        }
        else{
            queryString = 'Select id, title, Summary, Article_Text__c, m_id__c, Language From CSH__kav c Where m_id__c = \'' + String.escapeSingleQuotes(filter.m_id) + '\' AND Language = \'' + String.escapeSingleQuotes(langCode) + '\' and publishstatus = \'Online\' and islatestversion = true limit 1';
        }
        system.debug('Query ' + queryString);
    	return queryString;
    }

    // Wrapper class for filters
    global class Filter {
    	webservice String m_id;
    	webservice String interface_id;
        webservice String access_id;
    }


    webService String Delimiter;
    webService String Limited;
    webService String Start;
    webservice Boolean ReturnRawResult;
    webService Boolean DisableMTOM;
}