global class AppTranslationHandler implements Unbabelapi.ITranslationHandler {
    
    global Unbabelapi.UnbabelRestEnvelope execute(unbabelapi.UnbabelRestEnvelope env, unbabelapi__Unbabel_Translation_Request__c tr) {        
        // Response envelope
        system.debug('env :: ' + env);
        
        // sObject payload
        system.debug('env.data : ' + env.data);
        // Generic payload
        system.debug('env.dataNoObj : ' + env.dataNoObj);
        // translation success
        system.debug('env.isSuccess :: ' + env.isSuccess);
        // error message
        system.debug('env.message :: ' + env.message);

        //Add your code
        if (env.isSuccess) {
            Id translationId = env.dataNoObj.get('Id');
            if (translationId == null) { 
                // TODO: throw an exception
            }
            Translation__c translation = [SELECT Translated_Text__c FROM Translation__c WHERE Id = :translationId];
            translation.Translated_Text__c = env.dataNoObj.get('content');
            try {
                update translation;
            } catch (DmlException ex) {
                System.debug(LoggingLevel.ERROR, ex.getMessage());
            }
        } else {
            // TODO: check options to update error 
        }
                                        
        return env;
    }    

}
