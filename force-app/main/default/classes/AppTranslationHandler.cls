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
                                        
        return env;
    }    

}
