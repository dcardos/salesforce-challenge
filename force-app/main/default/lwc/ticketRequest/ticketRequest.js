import { LightningElement, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';
import getSupportedLangs from '@salesforce/apex/TicketServerController.getSupportedLangs';
import getTranslations from '@salesforce/apex/TicketServerController.getTranslations';
import requestTranslation from '@salesforce/apex/TicketServerController.requestTranslation';

const columns = [
    { label: 'From Language', fieldName: 'From_Language__c' },
    { label: 'Original Text', fieldName: 'Original_Text__c' },
    { label: 'To Language', fieldName: 'To_Language__c'  },
    { label: 'Translated Text', fieldName: 'Translated_Text__c' },
    { label: 'Status', fieldName: 'Status__c' }
];

export default class App extends LightningElement {
    @track targetLang;
    @track columns = columns;
    @track error;
    @track translations;
    @track originalText;
    subscription = {};
    wiredTranslationsResult; //so it can be refreshed programmatically

    @wire(getSupportedLangs)
    supportedLangs;

    @wire(getTranslations)
    wiredAccounts(result) {
        this.wiredTranslationsResult = result;
        if (result.data) {
            this.translations = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.translations = undefined;
        }
    }

    get options() {
        return this.supportedLangs.data;
    }

    connectedCallback() {
        // initialize component
        // Callback invoked whenever a new event message is received
        const messageCallback = function (response) {
            console.log('New message received : ', JSON.stringify(response));
            // Response contains the payload of the new message received
            return refreshApex(this.wiredTranslationsResult);
        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe('/topic/TranslationRequestUpdates', -1, messageCallback).then(response => {
            // Response contains the subscription information on successful subscribe call
            console.log('Successfully subscribed to : ', JSON.stringify(response.channel));
            this.subscription = response;
        });
    }

    handleTextChange(event) {
        this.originalText = event.target.value;
    }

    handleLangChange(event) {
        this.targetLang = event.detail.value;
    }

    handleSubmit() {
        requestTranslation({ originalText: this.originalText, toLang: this.targetLang })
            .then(result => {
                console.log(result);
                this.error = undefined;
                return refreshApex(this.wiredTranslationsResult);
            })
            .catch(error => {
                console.log(error);
                this.error = error;
            });
    }

    disconnectedCallback() {
        // Invoke unsubscribe method of empApi
        unsubscribe(this.subscription, response => {
            console.log('unsubscribe() response: ', JSON.stringify(response));
            // Response is true for successful unsubscribe
        });
    }

    registerErrorListener() {
        // Invoke onError empApi method
        onError(error => {
            console.error('Received error from server: ', JSON.stringify(error));
            // Error contains the server-side error
        });
    }
}
