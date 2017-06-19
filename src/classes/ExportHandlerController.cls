Public class ExportHandlerController{

    Public ExportHandlerController(){
    }
    
    Public Pagereference exportCustomFields(){
        
        PageReference PR = New PAgeReference('/apex/ExportCustomFields');
        return PR;
    }

}