global class IntegrationAttributeManager {
    global class LineItemAttribute {
        webservice id lineItemId {get;set;}
        webservice list<keyValuePair> attributes {get;set;}
    }

    global class KeyValuePair {
        webservice string key {get;set;}
        webservice string value {get;set;}
        public KeyValuePair(string key, string value) {
            this.key = key;
            this.value=value;
        }
    }

    public map<id,IntegrationAttribute> attributes {
        get {
            if (attributes==null){
                attributes = new map<id,IntegrationAttribute>();
                for (integration_attribute__c attribute:[select id, name,source_object__c,
                                                                   Dependent_Attribute_Only__c,source_field__c,filter_field__c, filter_value__c,
                                                        (select id,name, source_value__c, dependent_attribute__c, integration_attribute__r.name from integration_attribute_values__r)
                                                         from integration_attribute__c where integration_type__c includes(:integrationType)
                                                         order by priority__c]) {
                          attributes.put(attribute.id,new IntegrationAttribute(this,attribute));
                    }
            }
            return attributes;
         }
        private set;
    }
    public map<string, list<IntegrationAttribute>> attributesByName{
        get {
            if (attributesByName==null){
                attributesByName = new map<string, list<IntegrationAttribute>>();
                for (IntegrationAttribute attribute:attributes.values()) {
                    if (attributesByName.containsKey(attribute.attribute.name)==false){
                        attributesByName.put(attribute.attribute.name, new List<IntegrationAttribute>());
                    }
                    attributesByName.get(attribute.attribute.name).add(attribute);

              }
            }
            return attributesByName;
        }
        private set;
    }
    public map<id,IntegrationAttribute> primaryAttributes {
        get {
            if (primaryAttributes==null){
                primaryAttributes = new map<id,IntegrationAttribute>();
                for (IntegrationAttribute attribute:attributes.values()) {
                    if (attribute.attribute.Dependent_Attribute_Only__c !=true){
                        primaryAttributes.put(attribute.attribute.id,attribute);
                    }
              }
            }
            return primaryAttributes;
        }
        private set;
    }
    public string integrationType {get;set;}

    public IntegrationAttributeManager(string integrationType){
        this.integrationType = integrationType;
    }

    public class IntegrationAttribute {
        private IntegrationAttributeManager manager;
        public integration_attribute__c attribute;
        private map<string,integration_attribute_value__c> outboundTranslationMap = new map<string,integration_attribute_value__c>();
        private map<string,string> inboundTranslationMap = new map<string,string>();
        public IntegrationAttribute(IntegrationAttributeManager manager, Integration_Attribute__c ia) {
            this.manager = manager;
            attribute = ia;
            for (integration_attribute_value__c iav : ia.integration_attribute_values__r) {
                outboundTranslationMap.put(String.ValueOf(iav.source_value__c), iav);
                inboundTranslationMap.put(iav.name,String.ValueOf(iav.source_value__c));
            }
        }

        public void mapAttributeToRecord(String attributeValue, Sobject obj){
            if (inboundTranslationMap.containsKey(attributeValue) && attribute.source_field__c!=null) {
                object translatedValue = inboundTranslationMap.get(attributeValue);
                translatedValue = (translatedValue=='true' ? true : (translatedValue=='false' ? false : translatedValue));
                obj.put(attribute.source_field__c, translatedValue);

            }
            system.debug('attribute.source_field__c' + attribute.source_field__c);
            system.debug('obj' + obj);
            system.debug('attributeValue' + attributeValue);
            if(attribute.source_field__c == 'Zip_Code__c' && UserInfo.getName() == 'Integration MAPP')
            {
                 system.debug('Insideattributeif');
                 obj.put(attribute.source_field__c, attributeValue); 
                 system.debug('ValueSet');  
            }//AP I-216438 for BoundingBoxPostalCode
        }

        public List<KeyValuePair> getMatchingAttributes(map<string, sobject> sourceMap) {
            list<KeyValuePair> results = new list<KeyValuePair>();
            if (sourceMap.containsKey(attribute.source_object__c)) {
                sobject obj = sourceMap.get(attribute.source_object__c);
                integration_attribute_value__c matchingIAV = null;
                boolean hasFilter = ((attribute.filter_field__c!=null || attribute.filter_field__c!='') && attribute.filter_value__c!=null);
                string filterValue = (hasFilter ? String.valueOf(obj.get(attribute.filter_field__c)) : null);
                boolean isValidRecord = (hasFilter && filterValue == attribute.filter_value__c || hasFilter==false);
                if (isValidRecord && attribute.source_field__c!=null &&obj.get(attribute.source_field__c)!=null && outboundTranslationMap.containsKey(String.ValueOf(obj.get(attribute.source_field__c)))) {
                    matchingIAV = outboundTranslationMap.get(String.ValueOf(obj.get(attribute.source_field__c)));

                }

                if (matchingIAV !=null) {
                    KeyValuePair kvp = new KeyValuePair(matchingIAV.integration_attribute__r.name, matchingIAV.name);
                    results.add(kvp);
                    if (matchingIAV.Dependent_Attribute__c!=null){
                        results.addAll(manager.attributes.get(matchingIAV.Dependent_Attribute__c).getMatchingAttributes(sourceMap));
                    }
                }
            }
            return results;
        }
    }

      public  string generateSoqlFields() {
        string fields = 'id, Order_Line_Item__r.product__c, Order_Line_Item__r.order__c';
        map<string,set<string>> fieldMap = new map<string,set<string>>();
        for (IntegrationAttribute ia : attributes.values()) {
            if (fieldMap.containsKey(ia.attribute.source_object__c)==false) {
                fieldMap.put(ia.attribute.source_object__c, new Set<String>());
            }
                fieldMap.get(ia.attribute.source_object__c).add(ia.attribute.source_field__c);

        }

        for (string sourceObject : fieldMap.keySet()) {
            if (sourceObject.contains('__r')==true){
                fields +=', (select id';
                for (string sourceField : fieldMap.get(sourceObject)) {
                    if (sourceField!=null) {
                        fields += ', ' +  sourceField;
                    }
                }
                fields +=' from ' + sourceObject + ') ';
            } else {
                string objPrefix = '';
                if(sourceObject == 'Order_Line_Item__c'){
                    objPrefix = 'Order_Line_Item__r.';
                }
                if(sourceObject == 'Product'){
                    objPrefix = 'product__r.';
                }
                if(sourceObject == 'Line_Item_Attribute__c'){
                    objPrefix= 'Line_Item_Attribute__c.';
                }
                /*if(sourceObject == 'Apttus_Config2__ProductAttributeValue__c'){
                    objPrefix = 'Apttus_Config2__ProductAttributeValue__c.';
                }*/

                //string objPrefix = (sourceObject=='Order' ? 'order__r.' : (sourceObject=='Product' ? 'product__r.' : ''));
                for (string sourceField : fieldMap.get(sourceObject)) {
                    if (sourceField!=null) {
                        fields += ', ' + objPrefix + sourceField;
                    }
                }
            }
        }
        system.debug('*****fields ' + fields);
        return fields;
    }

    public Sobject transformAttributesToRecord(Sobject obj, List<KeyValuePair>attributes) {
         for (KeyValuePair kvp : attributes){
            if (attributesByName.containsKey(kvp.key)){
                for (IntegrationAttribute ia : attributesByName.get(kvp.key)){
                    ia.mapAttributeToRecord(kvp.value,obj);
                }
            }
        }
        return obj;
    }

    webservice static list<id> upsertAttributeRecords(String integrationType, String attributeObjectName, String relatedObjectFieldName,list<LineItemAttribute> attributes) {
        IntegrationAttributeManager attributeManager = new IntegrationAttributeManager(integrationType);
        List<id> attributeIds = new list<id>();
        map<id,lineItemAttribute> lineItemAttributes = new map<id,lineItemAttribute> ();
        for (LineItemAttribute attribute : attributes) {
            lineItemAttributes.put(attribute.lineItemId,attribute);
        }
        list<sobject> objects = new list<sobject>();

        set<id> relatedObjectIds = lineItemAttributes.keyset();
        map<id,sobject> existingObjects = new map<id,sobject>();
        for (Sobject rec : Database.query('Select Id from ' + attributeObjectName + ' where ' + relatedObjectFieldName + ' in :relatedObjectIds')) {
            existingObjects.put(rec.id, rec);
        }

        for (LineItemAttribute attribute : attributes) {
            Sobject obj = (Sobject)Type.forName(attributeObjectName).newInstance();
            obj.put(relatedObjectFieldName, attribute.lineItemId);

            if (existingObjects.containsKey(attribute.lineItemId)) {
                obj=existingObjects.get(attribute.lineItemId);
                attributeManager.transformAttributesToRecord(obj,attribute.attributes);
                objects.add(obj);
            }
        }

        if (objects.isEmpty()==false){
            upsert objects;
            for (sobject obj:objects){
                attributeIds.add(obj.id);
            }
        }
        return attributeIds;

    }
    webservice static id upsertAttributeRecord(String integrationType, Id relatedRecordId, String attributeObjectName, String relatedObjectFieldName, List<KeyValuePair> attributes){
        IntegrationAttributeManager attributeManager = new IntegrationAttributeManager(integrationType);
        Sobject obj = (Sobject)Type.forName(attributeObjectName).newInstance();
        obj.put(relatedObjectFieldName, relatedRecordId);
        List<Sobject> existingObjects = Database.query('Select Id from ' + attributeObjectName + ' where ' + relatedObjectFieldName + ' =:relatedRecordId');
        if (existingObjects!=null && existingObjects.IsEmpty()==false) {
            obj=existingObjects[0];
            system.debug('intobj' + obj);
        }
        attributeManager.transformAttributesToRecord(obj,attributes);
        system.debug('fieldobj'+ obj);
        upsert obj;
        system.debug('WebOrderNumber' + obj.id);
        return obj.id;
    }
}