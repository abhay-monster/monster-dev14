@isTest
global class CodeCoverageHTTPMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        String str_body = '{\"size\":411,\"totalSize\":411,\"done\":true,\"queryLocator\":null,\"entityTypeName\":\"ApexCodeCoverageAggregate\",'+
          ' \"records\":[{\"attributes\":{\"type\":\"ApexCodeCoverageAggregate\",\"url\":\"/services/data/v35.0/tooling/sobjects/ApexCodeCoverageAggregate/715q00000004Y4HAAU\"},\"ApexClassOrTriggerId\":\"01qq00000004TxIAAU\",\"NumLinesCovered\":0,\"NumLinesUncovered\":13,\"Coverage\":{\"coveredLines\":[],\"uncoveredLines\":[]}},'+
           '{\"attributes\":{\"type\":\"ApexCodeCoverageAggregate\",\"url\":\"/services/data/v35.0/tooling/sobjects/ApexCodeCoverageAggregate/715q00000004Y5FAAU\"},\"ApexClassOrTriggerId\":\"01qq00000004TxXAAU\",\"NumLinesCovered\":9,\"NumLinesUncovered\":2,\"Coverage\":{\"coveredLines\":[4,7,13,17,23,26,33,37,44],\"uncoveredLines\":[50,51]}},'+
           '{\"attributes\":{\"type\":\"ApexCodeCoverageAggregate\",\"url\":\"/services/data/v35.0/tooling/sobjects/ApexCodeCoverageAggregate/715q00000004scGAAQ\"},\"ApexClassOrTriggerId\":\"01pq00000006jeMAAQ\",\"NumLinesCovered\":3,\"NumLinesUncovered\":0,\"Coverage\":{\"coveredLines\":[2,3,4],\"uncoveredLines\":[]}},'+
           '{\"attributes\":{\"type\":\"ApexCodeCoverageAggregate\",\"url\":\"/services/data/v35.0/tooling/sobjects/ApexCodeCoverageAggregate/715160000000RnDAAU\"},\"ApexClassOrTriggerId\":\"01p16000004kBq0AAE\",\"NumLinesCovered\":0,\"NumLinesUncovered\":7,\"Coverage\":{\"coveredLines\":[6,8,9,10,12,14],\"uncoveredLines\":[15]}},'+
           '{\"attributes\":{\"type\":\"ApexCodeCoverageAggregate\",\"url\":\"/services/data/v35.0/tooling/sobjects/ApexCodeCoverageAggregate/715160000000RnEAAU\"},\"ApexClassOrTriggerId\":\"01p16000004kBq3AAE\",\"NumLinesCovered\":0,\"NumLinesUncovered\":31,\"Coverage\":{\"coveredLines\":[2,3,4,5,6,7,8,9,25,26,27,28,29,30,31,32,33,34,35,36],\"uncoveredLines\":[11,12,13,14,15,16,17,21,22,37,38]}},'+
           '{\"attributes\":{\"type\":\"ApexCodeCoverageAggregate\",\"url\":\"/services/data/v35.0/tooling/sobjects/ApexCodeCoverageAggregate/71516000000Qz8EAAS\"},\"ApexClassOrTriggerId\":\"01pG0000004C46bIAC\",\"NumLinesCovered\":89,\"NumLinesUncovered\":14,\"Coverage\":{\"coveredLines\":[3,6,8,9,10,11,12,15,17,18,19,20,24,27,28,29,30,31,32,33,34,35,44,45,47,48,49,50,51,52,53,54,57,58,59,60,61,71,72,73,76,77,78,79,80,81,82,85,86,87,90,91,92,95,96,97,101,102,104,105,106,107,113,114,115,123,124,125,126,127,128,129,135,136,142,146,148,155,157,158,166,167,168,171,179,180,182,183,184],\"uncoveredLines\":[4,7,14,62,63,108,109,137,138,143,151,152,161,162]}},'+
           '{\"attributes\":{\"type\":\"ApexCodeCoverageAggregate\",\"url\":\"/services/data/v35.0/tooling/sobjects/ApexCodeCoverageAggregate/715G0000000QyXvIAK\"},\"ApexClassOrTriggerId\":\"01pG0000004ahfuIAA\",\"NumLinesCovered\":8,\"NumLinesUncovered\":1,\"Coverage\":{\"coveredLines\":[5,7,9,10,11,12,14,17],\"uncoveredLines\":[15]}},'+
          ' {\"attributes\":{\"type\":\"ApexCodeCoverageAggregate\",\"url\":\"/services/data/v35.0/tooling/sobjects/ApexCodeCoverageAggregate/715G0000000QyXwIAK\"},\"ApexClassOrTriggerId\":\"01pG0000004ahfwIAA\",\"NumLinesCovered\":36,\"NumLinesUncovered\":5,\"Coverage\":{\"coveredLines\":[8,10,11,14,15,18,20,25,26,29,30,33,34,38,39,40,43,49,50,53,54,55,58,61,62,63,64,65,66,67,68,69,70,71,72,73],\"uncoveredLines\":[21,35,41,44,45]}},'+
          ' {\"attributes\":{\"type\":\"ApexCodeCoverageAggregate\",\"url\":\"/services/data/v35.0/tooling/sobjects/ApexCodeCoverageAggregate/715G0000000QyXxIAK\"},\"ApexClassOrTriggerId\":\"01pG0000004ahfqIAA\",\"NumLinesCovered\":23,\"NumLinesUncovered\":5,\"Coverage\":{\"coveredLines\":[4,7,9,12,13,14,15,16,18,19,22,24,25,26,27,29,30,31,32,34,37,38,48],\"uncoveredLines\":[39,40,43,44,45]}}]}';
        System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(str_body);
        res.setStatusCode(200);
        return res;
    }
}