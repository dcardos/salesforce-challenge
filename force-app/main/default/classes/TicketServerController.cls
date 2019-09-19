public with sharing class TicketServerController {

    @TestVisible
    class PicklistItem {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String value {get;set;}

        public PicklistItem(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<PicklistItem> getSupportedLangs() {
        Schema.DescribeFieldResult picklistUsingGlobal = SObjectType.unbabelapi__Unbabel_Translation_Request__c.fields.unbabelapi__Unbabel_Languages__c;
        List<PicklistEntry> entries = picklistUsingGlobal.getPicklistValues();
        List<PicklistItem> languages = new List<PicklistItem>();
        for (PicklistEntry entry : entries) {
            if (entry.isActive()) {
                languages.add(new PicklistItem(
                    entry.getLabel().split(':')[1],
                    entry.getValue().split(':')[0]
                ));
            }
        }
        return languages;
    }

    @AuraEnabled(cacheable=true)
    public static Integer getTotalTrans() {
        return [SELECT count() FROM Translation__c];
    }

    @AuraEnabled
    public static List<Translation__c> getTranslations(Integer numRecords, Datetime dateFilter, Boolean older) {
        if (dateFilter == null) {
            dateFilter = System.now();
        }
        if (older == null || older) {
            return [
                SELECT Id, From_Language__c, Original_Text__c, To_Language__c, Translated_Text__c, Status__c, Error_Message__c, CreatedDate
                FROM Translation__c
                WHERE CreatedDate < :dateFilter
                ORDER BY CreatedDate DESC
                LIMIT :numRecords
            ];
        } else {
            List<Translation__c> translationsInversed = [
                SELECT Id, From_Language__c, Original_Text__c, To_Language__c, Translated_Text__c, Status__c, Error_Message__c, CreatedDate
                FROM Translation__c
                WHERE CreatedDate > :dateFilter
                ORDER BY CreatedDate ASC
                LIMIT :numRecords
            ];
            // Sorting CreatedDate Desc so it is consistent
            List<Translation__c> translationReversed = new List<Translation__c>();
            for (Integer i = translationsInversed.size()-1; i >= 0; i--) {
                translationReversed.add(translationsInversed[i]);
            }
            return translationReversed;
        }
        
    }

    @AuraEnabled
    public static void requestTranslation(String originalText, String toLang) {
        TranslationRequest.sendRequest(originalText, toLang);
    }
}
