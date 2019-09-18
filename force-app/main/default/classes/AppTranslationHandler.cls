global class AppTranslationHandler implements Unbabelapi.ITranslationHandler {

    public class TransIdException extends Exception {}
    
    global Unbabelapi.UnbabelRestEnvelope execute(unbabelapi.UnbabelRestEnvelope env, unbabelapi__Unbabel_Translation_Request__c tr) {        
        if (env.isSuccess) {
            if (env.dataNoObj == null || env.dataNoObj.get('Id') == null) { 
                throw new TransIdException('Could not find the translation record Id in the API response');
            }
            Id translationId = env.dataNoObj.get('Id');
            Translation__c translation = [SELECT Translated_Text__c FROM Translation__c WHERE Id = :translationId];
            translation.Translated_Text__c = env.dataNoObj.get('content');
            update translation;
        }
                                        
        return env;
    }    

}
