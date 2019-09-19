import { LightningElement, track, wire } from 'lwc';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';
import getSupportedLangs from '@salesforce/apex/TicketServerController.getSupportedLangs';
import getTotalTrans from '@salesforce/apex/TicketServerController.getTotalTrans';
import getTranslations from '@salesforce/apex/TicketServerController.getTranslations';
import requestTranslation from '@salesforce/apex/TicketServerController.requestTranslation';

const columns = [
    { label: 'From Language', fieldName: 'From_Language__c' },
    { label: 'Original Text', fieldName: 'Original_Text__c' },
    { label: 'To Language', fieldName: 'To_Language__c'  },
    { label: 'Translated Text', fieldName: 'Translated_Text__c' },
    { label: 'Status', fieldName: 'Status__c' }
];

const numTranslations = 7; // number of records to be returned for the table

export default class App extends LightningElement {
    @track loading = true;
    @track targetLang;
    @track columns = columns;
    @track error;
    @track translations;
    @track originalText;
    @track isBtnNewerDisabled = true;
    @track isBtnOlderDisabled;
    firstRecordDateTime;
    lastRecordDateTime;
    firstRecPos = 0;
    LastRecPos = numTranslations - 1;
    subscription = {};
    wiredTranslationsResult; //so it can be refreshed programmatically

    @wire(getSupportedLangs)
    supportedLangs;

    @wire(getTotalTrans)
    totalTrans;

    get options() {
        return this.supportedLangs.data;
    }

    refreshTable = (createdDateFilter, olderDataFlag) => {    
        if (createdDateFilter) {
            if (olderDataFlag === false) {
                // button to get newer translations clicked
                if (this.firstRecPos === 0) {
                    return;
                }
            } else {
                // button to get older translations clicked
                if (this.LastRecPos === this.totalTrans.data-1) {
                    return;
                }
            }
        }
        this.loading = true;
        getTranslations({numRecords: numTranslations, dateFilter: createdDateFilter, older: olderDataFlag})
            .then(result => {
                this.firstRecordDateTime = result[0].CreatedDate;
                this.lastRecordDateTime = result[result.length-1].CreatedDate;
                this.error = undefined;
                if (createdDateFilter) {
                    if (olderDataFlag === false) {
                        // button to get newer translations clicked
                        this.firstRecPos -= this.translations.length;
                        this.LastRecPos -= this.translations.length;
                    } else {
                        // button to get older translations clicked
                        this.firstRecPos += result.length;
                        this.LastRecPos += result.length;
                    }
                }
                this.translations = result;
            })
            .catch(error => {
                this.error = error;
                this.translations = undefined;
            })
            .finally(() => {
                this.loading = false;
            });
    }

    connectedCallback() {
        // initialize component
        // Callback invoked whenever a new event message is received
        const messageCallback = (function (response) {
            console.log('New message received: ', JSON.stringify(response));
            this.refreshTable(null);
        }).bind(this);

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe('/topic/TranslationUpdates', -1, messageCallback).then(response => {
            // Response contains the subscription information on successful subscribe call
            console.log('Successfully subscribed to : ', JSON.stringify(response.channel));
            this.subscription = response;
        });

        // initializing table
        this.refreshTable(null);
    }

    handleTextChange(event) {
        this.originalText = event.target.value;
    }

    handleLangChange(event) {
        this.targetLang = event.detail.value;
    }

    handleSubmit() {
        const allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        if (allValid && this.targetLang) {
            this.loading = true;
            requestTranslation({ originalText: this.originalText, toLang: this.targetLang })
                .then(() => {
                    this.error = undefined;
                    this.refreshTable(this.lastRecordDateTime);
                })
                .catch(error => {
                    console.error(error);
                    this.error = error;
                })
                .finally(() => {
                    this.loading = false;
                });
        } else if (!this.targetLang) {
            let picklistCmp = this.template.querySelector('lightning-combobox');
            picklistCmp.reportValidity();
        }
    }

    handleNewerTrans() {
        this.refreshTable(this.firstRecordDateTime, false);
    }

    handleOlderTrans() {
        this.refreshTable(this.lastRecordDateTime, true);
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
