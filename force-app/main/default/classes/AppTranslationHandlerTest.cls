@isTest
private class AppTranslationHandlerTest {
    @isTest
    static void AppTranslationHandlerTestOK() {
        unbabelapi__Unbabel_Translation_Request__c tr = TestDataFactory.getTranslationRequest(null);
        insert tr;
        Translation__c translation = TestDataFactory.getTranslation('Hello World', tr.Id);
        insert translation;        
        tr.unbabelapi__Unbabel_sObject_Id__c = translation.id;
        update tr;
        
        Map<String, String> dataNoObj = new Map<String, String>{'Id' => translation.Id, 'content' => 'Olá Mundo'};
        unbabelapi.UnbabelRestEnvelope env = new unbabelapi.UnbabelRestEnvelope(true, null, dataNoObj);

        AppTranslationHandler translationHandler = new AppTranslationHandler();
        translationHandler.execute(env, tr);

        System.assertEquals(
            'Olá Mundo', 
            [SELECT translated_text__c FROM Translation__c].translated_text__c, 
            'Translation record was not properly updated with the translated text'
        );
    }

    @isTest
    static void AppTranslationHandlerTestException() {
        unbabelapi__Unbabel_Translation_Request__c tr = TestDataFactory.getTranslationRequest(null);
        
        Map<String, String> dataNoObj = new Map<String, String>{'Id' => null, 'content' => null};
        unbabelapi.UnbabelRestEnvelope env = new unbabelapi.UnbabelRestEnvelope(true, 'Test error', dataNoObj);

        AppTranslationHandler translationHandler = new AppTranslationHandler();
        try {
            translationHandler.execute(env, tr);
        } catch(AppTranslationHandler.TransIdException ex) {
            System.assertEquals(
                'Could not find the translation record Id in the API response', 
                ex.getMessage(), 
                'Exception was not properly set'
            );
        }
    }
}
