@isTest
private class TranslationRequestTest {

    @isTest
    static void sendRequestTest() {
        TranslationRequest.sendRequest('English translation test', 'pt');
        System.assertEquals(1, [SELECT count() FROM Translation__c], 'A translation record should have been created');
        System.assertEquals(1, [SELECT count() FROM unbabelapi__Unbabel_Translation_Request__c], 'A translation request record should have been created');
    }
}
