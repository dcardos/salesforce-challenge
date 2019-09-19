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
    static void getTotalTransTest() {
        unbabelapi__Unbabel_Translation_Request__c tr = TestDataFactory.getTranslationRequest(null);
        insert tr;
        insert TestDataFactory.getTranslationList('Hello World', tr.Id, 70);
        System.assertEquals(70, TicketServerController.getTotalTrans(), 'Total translations are not correct');
    }

    @isTest
    static void getTranslationsSharingTest() {
        List<Translation__c> translations;
        unbabelapi__Unbabel_Translation_Request__c tr = TestDataFactory.getTranslationRequest(null);
        insert tr;
        insert TestDataFactory.getTranslationList('Hello World from system mode', tr.Id, 70);

        // Testing method and sharring rules for new user
        System.runAs(TestDataFactory.getNewUser()) {
            unbabelapi__Unbabel_Translation_Request__c otherTr = TestDataFactory.getTranslationRequest(null);
            insert otherTr;
            insert TestDataFactory.getTranslationList('Hello World from new user', otherTr.Id, 70);
            translations = TicketServerController.getTranslations(150, null, null);
            System.assertEquals(70, translations.size(), 'Sharing rules were not enforced');
            for (Translation__c translation : translations) {
                System.assertEquals(
                    'Hello World from new user', 
                    translation.Original_Text__c, 
                    'Users can see other\'s records'
                );
            }
        }

        // Testing that in system mode all records are visible
        translations = TicketServerController.getTranslations(150, null, null);
        System.assertEquals(140, translations.size(), 'Method did not returned the records properly');
    }

    @isTest
    static void getTranslationsParamsTest() {
        Datetime checkpoint = System.now();
        unbabelapi__Unbabel_Translation_Request__c tr = TestDataFactory.getTranslationRequest(null);
        insert tr;
        List<Translation__c> translationsOlder = TestDataFactory.getTranslationList('Hello World in the past', tr.Id, 3);
        insert translationsOlder;
        for (Translation__c transOld : translationsOlder) {
            Test.setCreatedDate(transOld.Id, checkpoint.addSeconds(-5));
        }
        List<Translation__c> translationsNewer = TestDataFactory.getTranslationList('Hello World not so much in the past', tr.Id, 2);
        insert translationsNewer;
        for (Translation__c transNew : translationsNewer) {
            Test.setCreatedDate(transNew.Id, checkpoint.addSeconds(+5));
        }
        System.debug([SELECT CreatedDate FROM Translation__c]);
        List<Translation__c> translations = TicketServerController.getTranslations(10, checkpoint, null);
        System.assertEquals(3, translations.size(), 'Method did not returned all the records created before checkpoint datetime');
        translations = TicketServerController.getTranslations(10, null, null);
        System.assertEquals(3, translations.size(), 'Method did not returned all the records created before System.now()');
        translations = TicketServerController.getTranslations(10, checkpoint.addSeconds(10), null);
        System.assertEquals(5, translations.size(), 'Method did not returned all the records');
        translations = TicketServerController.getTranslations(10, checkpoint, false);
        System.assertEquals(2, translations.size(), 'Method did not returned all the records created after checkpoint datetime');
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
