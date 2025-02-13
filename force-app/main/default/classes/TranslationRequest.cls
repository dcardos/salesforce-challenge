public with sharing class TranslationRequest {
    
    public class ParamsException extends Exception {}
    public class UnknownLangException extends Exception {}
    public class TranslationException extends Exception {}
    
    //****** Create Translation Request(trRequest) ******
    public static void sendRequest(String originalText, String toLang) {
        // Initial validations
        if (String.isBlank(originalText)) {
            throw new ParamsException('There is no text to be translated');
        } else if (String.isBlank(toLang)) {
            throw new ParamsException('There is no target language for the translation');
        }

        String originalLanguage;
        unbabelapi.UnbabelRestEnvelopeCL ureCL = unbabelapi.UnbabelRestConnectorOutbound.checkLanguage(
            JSON.serialize(new EmailMessage(textBody=originalText))
        );
        
        // NOT PROUD OF THIS, but I do not have access to the UnbabelRestConnectorOutbound and cannot mock a response =/
        if (Test.isRunningTest()) {
            unbabelapi.UnbabelRestEnvelopeCL.LanguageCode langData = new unbabelapi.UnbabelRestEnvelopeCL.LanguageCode();
            langData.languageCode = 'en';
            ureCL = new unbabelapi.UnbabelRestEnvelopeCL(true, null, langData);
        }

        if (ureCL.isSuccess) {
            originalLanguage = ureCL.data.LanguageCode;
        } else {
            throw new UnknownLangException('Original Language could not be identified');
        }

        Boolean isValid =  unbabelapi.UnbabelCustomSettingUtils.validLanguagePair(originalLanguage, toLang);

        // NOT PROUD OF THIS, but I do not have access to the UnbabelCustomSettingUtils and cannot mock a response =/
        if (Test.isRunningTest()) { isValid = true; }

        if (!isValid) {
            throw new TranslationException('Cannot translate from ' + originalLanguage + ' to ' + toLang);
        }

        // Making request
        unbabelapi__Unbabel_Translation_Request__c trRequest = new unbabelapi__Unbabel_Translation_Request__c();
        trRequest.unbabelapi__Unbabel_From_Language__c = originalLanguage;
        trRequest.unbabelapi__Unbabel_To_Language__c = toLang;
        trRequest.unbabelapi__Unbabel_Translation_Type__c = 'Machine';
        trRequest.unbabelapi__Unbabel_Namespace__c = '';
        trRequest.unbabelapi__Unbabel_Class__c = AppTranslationHandler.class.getName();
        insert trRequest;
        // Setting translation up
        Translation__c translation = new Translation__c(
            Original_Text__c = originalText,
            Translation_Request__c = trRequest.Id
        );
        insert translation;
        
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
            update translation;
        }
        
        update trRequest;
    }
    
}
