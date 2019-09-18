@isTest
private class TranslationRequestTest {

    @isTest
    static void sendRequestTest() {
        TranslationRequest.sendRequest('English translation test', 'pt');
        System.assertEquals(
            1, 
            [SELECT count() FROM Translation__c], 
            'A translation record should have been created'
        );
        System.assertEquals(
            1, 
            [SELECT count() FROM unbabelapi__Unbabel_Translation_Request__c], 
            'A translation request record should have been created'
        );
        System.assertEquals(
            'Request Error', 
            [SELECT Status__c FROM Translation__c].Status__c, 
            'A translation request with error status should have been placed'
        );
    }

    @isTest
    static void sendRequestTestExceptions() {
        try {
            TranslationRequest.sendRequest(null, 'pt');
        } catch (TranslationRequest.ParamsException ex) {
            System.assertEquals('There is no text to be translated', ex.getMessage());
        }

        try {
            TranslationRequest.sendRequest(null, null);
        } catch (TranslationRequest.ParamsException ex) {
            System.assertEquals('There is no text to be translated', ex.getMessage());
        }

        try {
            TranslationRequest.sendRequest('I am here now', null);
        } catch (TranslationRequest.ParamsException ex) {
            System.assertEquals('There is target language for the translation', ex.getMessage());
        }
    }
}
