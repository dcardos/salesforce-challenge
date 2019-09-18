@isTest
private class TicketServerControllerTest {

    @isTest
    static void getSupportedLangsTest() {
        List<TicketServerController.PicklistItem> supportedLangs = TicketServerController.getSupportedLangs();
        System.assert(supportedLangs != null);
        System.assert(supportedLangs.size() >= 28);

        for (TicketServerController.PicklistItem item : supportedLangs) {
            System.assert(String.isNotBlank(item.label));
            System.assert(String.isNotBlank(item.value));
            System.assert(item.label.containsNone(':'));
            System.assert(item.value.containsNone(':'));
        }
    }

    @isTest
    static void getTranslationsTest() {
        List<Translation__c> translations;
        insert TestDataFactory.getTranslationList('Hello World from system mode', 75);

        // Testing method and sharring rules for new user
        System.runAs(TestDataFactory.getNewUser()) {
            insert TestDataFactory.getTranslationList('Hello World from new user', 75);
            translations = TicketServerController.getTranslations();
            System.assertEquals(75, translations.size(), 'Sharing rules were not enforced');
            for (Translation__c translation : translations) {
                System.assertEquals(
                    'Hello World from new user', 
                    translation.Original_Text__c, 
                    'Users can see other\'s records'
                );
            }
        }

        // Testing that in system mode all records are visible
        translations = TicketServerController.getTranslations();
        System.assertEquals(150, translations.size(), 'Method did not returned the records properly');
    }

    @isTest
    static void requestTranslationTest() {
        TicketServerController.requestTranslation('Hello World will not go through', 'pt');
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
    
}
