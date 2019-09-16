public with sharing class TicketServerController {

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
                languages.add(new PicklistItem(entry.getLabel(), entry.getValue()));
            }
        }
        return languages;
    }

    @AuraEnabled
    public static Boolean requestTranslation(String originalText, String toLang) {
        
    }
}
