import { LightningElement, track, wire } from 'lwc';
import getSupportedLangs from '@salesforce/apex/TicketServerController.getSupportedLangs';

const columns = [
    { label: 'From Language', fieldName: 'fromLang' },
    { label: 'Original Text', fieldName: 'originalText' },
    { label: 'To Language', fieldName: 'toLang'  },
    { label: 'Translated Text', fieldName: 'amount' },
    { label: 'Status', fieldName: 'status' },
];

export default class App extends LightningElement {
    @track targetLang;
    @track translations = [];
    @track columns = columns;
    @track error;
    @track supportedLangs;

    @wire(getSupportedLangs)
    supportedLangs;

    get options() {
        return this.supportedLangs.data;
    }

    handleChange(event) {
        this.targetLang = event.detail.value;
    }
}
