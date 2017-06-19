/**
 *  Apttus Config & Pricing
 *  CustomPriceMatrixEntryTrigger
 *   
 */
trigger CustomPriceMatrixEntryTrigger on Apttus_Config2__PriceMatrixEntry__c (before insert, before update) {

    // value types
    static final String VALUETYPE_DISCRETE = 'Discrete';
    
    // null value
    static final String DISCRETE_VALUE_NA = 'N/A';
    
    // Trigger body
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
          if (Personal_Settings__c.getInstance().Trigger_PriceMatrixEntry__c ==false){
            return; // If triggers are off, then exit the method
        }
        // discrete dimensions
        Map<ID, List<Integer>> discreteDimNumbers = new Map<ID, List<Integer>>();
        
        // Shyam - 5/3/2017 - S-473243 
        Map<Id, Apttus_Config2__PriceMatrix__c> mapPMatrix = new Map<Id, Apttus_Config2__PriceMatrix__c>();
    
        for (Apttus_Config2__PriceMatrixEntry__c entrySO : Trigger.new) {
            mapPMatrix.put(entrySO.Apttus_Config2__PriceMatrixId__c, null);
        }
        
        mapPMatrix = getMatrixSO(mapPMatrix.keySet());
        
        // default currency code from the pricelist associated with the price list item
        for (Apttus_Config2__PriceMatrixEntry__c entrySO : Trigger.new) {
            // if SOQL limit reached, stop 
            if (Limits.getQueries() == Limits.getLimitQueries()) {
                break;
                
            }
            // get the discrete dimension for the matrix
            List<Integer> dimNumbers = discreteDimNumbers.get(entrySO.Apttus_Config2__PriceMatrixId__c);
            if (dimNumbers == null) {
                Apttus_Config2__PriceMatrix__c matrixSO = mapPMatrix.get(entrySO.Apttus_Config2__PriceMatrixId__c);
                // get the list of discrete dimensions
                dimNumbers = getDiscreteDimensionNumbers(matrixSO);
                // add to the collection
                discreteDimNumbers.put(entrySO.Apttus_Config2__PriceMatrixId__c, dimNumbers);
                
            }
            
            // build the entry key for discrete dimensions
           
            //entrySO.addError('--> entry key'+entrySO.Entry_Key__c);
            entrySO.Entry_Key__c = (!dimNumbers.isEmpty() 
                                    ? createEntryKey(entrySO, dimNumbers) 
                                    : null);
            
        }
            
    }
    
    /**
     * Gets the price matrix sobject for the given matrix id
     * @param matrixId the price matrix id to retrieve
     * @return the price matrix sobject 
     */
    private static Map<Id, Apttus_Config2__PriceMatrix__c> getMatrixSO(Set<Id> matrixId) {
        
        // get the price matrix
        return new Map<Id, Apttus_Config2__PriceMatrix__c>([SELECT Id,
                                                                Name,
                                                                Apttus_Config2__MatrixType__c,
                                                                Apttus_Config2__Dimension6ValueType__c,
                                                                Apttus_Config2__Dimension6Id__c,
                                                                Apttus_Config2__Dimension6Id__r.Name,
                                                                Apttus_Config2__Dimension5ValueType__c,
                                                                Apttus_Config2__Dimension5Id__c,
                                                                Apttus_Config2__Dimension5Id__r.Name,
                                                                Apttus_Config2__Dimension4ValueType__c,
                                                                Apttus_Config2__Dimension4Id__c,
                                                                Apttus_Config2__Dimension4Id__r.Name,
                                                                Apttus_Config2__Dimension3ValueType__c,
                                                                Apttus_Config2__Dimension3Id__c,
                                                                Apttus_Config2__Dimension3Id__r.Name,
                                                                Apttus_Config2__Dimension2ValueType__c,
                                                                Apttus_Config2__Dimension2Id__c,
                                                                Apttus_Config2__Dimension2Id__r.Name,
                                                                Apttus_Config2__Dimension1ValueType__c,
                                                                Apttus_Config2__Dimension1Id__c,
                                                                Apttus_Config2__Dimension1Id__r.Name
                                                         FROM Apttus_Config2__PriceMatrix__c
                                                         WHERE Id IN :matrixId]);
        
        
    }
    
    /**
     * Gets the list of discrete dimension numbers from the given matrix sobject
     * @param matrixSO the price matrix sobject
     * @return the list of discrete dimension numbers
     */
    private static List<Integer> getDiscreteDimensionNumbers(Apttus_Config2__PriceMatrix__c matrixSO) {
        
        List<Integer> discreteDimNumbers = new List<Integer>();
        // iterate through all dimensions for the entry and locate discrete range dimensions
        for (Integer i = 0; i < 6; i++) {
            Integer dimNumber = i+1;
            if (dimNumber == 1 && 
                matrixSO.Apttus_Config2__Dimension1Id__c != null &&
                matrixSO.Apttus_Config2__Dimension1ValueType__c == VALUETYPE_DISCRETE) {
                discreteDimNumbers.add(dimNumber);
                
            } else if (dimNumber == 2 && 
                       matrixSO.Apttus_Config2__Dimension2Id__c != null &&
                       matrixSO.Apttus_Config2__Dimension2ValueType__c == VALUETYPE_DISCRETE) {
                       discreteDimNumbers.add(dimNumber);
                
            } else if (dimNumber == 3 && 
                       matrixSO.Apttus_Config2__Dimension3Id__c != null &&
                       matrixSO.Apttus_Config2__Dimension3ValueType__c == VALUETYPE_DISCRETE) {
                       discreteDimNumbers.add(dimNumber);
                
            } else if (dimNumber == 4 && 
                       matrixSO.Apttus_Config2__Dimension4Id__c != null &&
                       matrixSO.Apttus_Config2__Dimension4ValueType__c == VALUETYPE_DISCRETE) {
                       discreteDimNumbers.add(dimNumber);
                
            } else if (dimNumber == 5 && 
                       matrixSO.Apttus_Config2__Dimension5Id__c != null &&
                       matrixSO.Apttus_Config2__Dimension5ValueType__c == VALUETYPE_DISCRETE) {
                       discreteDimNumbers.add(dimNumber);
                
            } else if (dimNumber == 6 && 
                       matrixSO.Apttus_Config2__Dimension6Id__c != null &&
                       matrixSO.Apttus_Config2__Dimension6ValueType__c == VALUETYPE_DISCRETE) {
                       discreteDimNumbers.add(dimNumber);
                
            }
            
        }
        
        return discreteDimNumbers;
        
    }
    
    /**
     * Creates the entry key for the given list of discrete dimension numbers
     * @param entrySO the price matrix entry to create the key for
     * @param dimNumbers the list of discrete dimension numbers
     * @return the entry key
     */
    private static String createEntryKey(Apttus_Config2__PriceMatrixEntry__c entrySO, List<Integer> dimNumbers) {
        
        String key = '';
        for (Integer dimNumber : dimNumbers) {
            String value = getDimensionValue(entrySO, dimNumber);
            key += (value != null && value.trim().length() > 0 ? value.trim() : DISCRETE_VALUE_NA);
            
        }
        
        return key;
        
    }
    
    /**
     * Gets the value for the dimension associated with the given dimension number
     * @param entrySO the price matrix entry sobject
     * @param dimNumber the dimension number to get the value for
     * @return the dimension value or null if there is no value
     */
    private static String getDimensionValue(Apttus_Config2__PriceMatrixEntry__c entrySO, Integer dimNumber) {
        
        // check all dimensions 
        if (dimNumber == 1) {
            // first dimension ((alphanumeric))
            return entrySO.Apttus_Config2__Dimension1Value__c;
        
        } else if (dimNumber == 2) {
            // second dimension (alphanumeric)
            return entrySO.Apttus_Config2__Dimension2Value__c;
            
        } else if (dimNumber == 3) {
            // third dimension (alphanumeric)
            return entrySO.Apttus_Config2__Dimension3Value__c;
            
        } else if (dimNumber == 4) {
            // fourth dimension (alphanumeric)
            return entrySO.Apttus_Config2__Dimension4Value__c;
            
        } else if (dimNumber == 5) {
            // fifth dimension (alphanumeric)
            return entrySO.Apttus_Config2__Dimension5Value__c;
            
        } else if (dimNumber == 6) {
            // sixth dimension (alphanumeric)
            return entrySO.Apttus_Config2__Dimension6Value__c;
            
        }
        
        return null;
    
    }
    
}