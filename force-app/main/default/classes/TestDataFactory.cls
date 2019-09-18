public class TestDataFactory {
    @TestVisible
    private static unbabelapi__Unbabel_Translation_Request__c getTranslationRequest(Id objId) {
        unbabelapi__Unbabel_Translation_Request__c trRequest = new unbabelapi__Unbabel_Translation_Request__c();
        trRequest.unbabelapi__Unbabel_From_Language__c = 'en';
        trRequest.unbabelapi__Unbabel_To_Language__c = 'pt';
        trRequest.unbabelapi__Unbabel_Translation_Type__c = 'Machine';
        trRequest.unbabelapi__Unbabel_Namespace__c = '';
        trRequest.unbabelapi__Unbabel_Class__c = AppTranslationHandler.class.getName();
        trRequest.unbabelapi__Unbabel_sObject_Id__c = objId;
        trRequest.unbabelapi__Unbabel_sObject__c = '';
        trRequest.unbabelapi__Unbabel_Status__c = 'Translation Requested';
        trRequest.unbabelapi__Unbabel_Translation_Requested_Datetime__c = System.now();
        return trRequest;
    }

    @TestVisible
    private static Translation__c getTranslation(String originalText) {
        Translation__c translation = new Translation__c(
            Original_Text__c = originalText
        );
        return  translation;
    }

    @TestVisible
    private static List<Translation__c> getTranslationList(String originalText, Integer size) {
        List<Translation__c> translationList = new List<Translation__c>();
        for (Integer i = 0; i < size; i++) {
            translationList.add(getTranslation(originalText));
        }
        return  translationList;
    }

    @TestVisible
    private static User getNewUser() {
        Profile userProfile = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User newUser = new User(
            Alias = 'standt', 
            Email='standarduser@unbabelchallenge.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',
            ProfileId = userProfile.Id, 
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standarduser@unbabelchallenge.com.test'
        );
        return newUser;
    }
}
