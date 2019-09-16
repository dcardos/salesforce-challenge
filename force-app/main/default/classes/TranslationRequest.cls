public with sharing class TranslationRequest {
    
    class Message {
    
        private String Id;
        private String content;
        
        public Message( String Id, String content) {
            this.Id = Id;        
            this.content = content;
        }
    }
    
    //****** Create Translation Request(trRequest) ******
    public static void sendRequest(String originalText, String toLang) {
        // TODO: throw a custom exception if originalText or toLang is null

        // TODO: check the from language automatically using api and if from-to is valid!

        unbabelapi__Unbabel_Translation_Request__c trRequest = new unbabelapi__Unbabel_Translation_Request__c();

        Translation__c translation = new Translation__c(
            Original_Text__c = originalText
        );

        try {
            insert translation;
        } catch (DmlException ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
        }
    
        trRequest.unbabelapi__Unbabel_From_Language__c = 'en';
        trRequest.unbabelapi__Unbabel_To_Language__c = toLang;
        trRequest.unbabelapi__Unbabel_Translation_Type__c = 'Machine';
        trRequest.unbabelapi__Unbabel_Namespace__c = '';
        //specify the name of the class to handle the translation
        trRequest.unbabelapi__Unbabel_Class__c = 'AppTranslationHandler';
        
        
        Set<String> translatedFields = new Set<String>{'Original_Text__c'};
        
        //Request Translation to Unbabel
        unbabelapi.UnbabelRestEnvelope ure = unbabelapi.UnbabelRestConnectorOutbound.requestTranslation(
            translation, trRequest, translatedFields
        );
        
        
        //Sets the trRequest fields
        trRequest.unbabelapi__Unbabel_sObject_Id__c = translation.id;
        trRequest.unbabelapi__Unbabel_sObject__c = '';
        
        //if request is successfull updates the Translation Request status to "Translation Requested" and inserts the TRs            
        if (ure.isSuccess) {    
            trRequest.unbabelapi__Unbabel_Status__c = 'Translation Requested';
            trRequest.unbabelapi__Unbabel_Translation_Requested_Datetime__c = System.now();
        
        //If the request fails updates the Translation Request status to "Request Error" and inserts the TRs
        } else {
            trRequest.unbabelapi__Unbabel_Status__c = 'Request Error';
            trRequest.unbabelapi__Unbabel_Error_Log__c = ure.message;
            translation.Error_Message__c = ure.message;
        }
        
        try {
            insert trRequest;
            translation.Translation_Request__c = trRequest.id;
            update translation;
        } catch (DmlException ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
        }
    }
    
}
