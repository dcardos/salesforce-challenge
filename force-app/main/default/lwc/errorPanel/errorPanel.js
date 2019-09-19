import { LightningElement, api, track } from 'lwc';
import { reduceErrors } from 'c/ldsUtils';

export default class ErrorPanel extends LightningElement {
    /** Generic / user-friendly message */
    @api friendlyMessage = 'We could not process the translation';

    @track viewDetails = true;

    /** Single or array of LDS errors */
    @api errors;

    get errorMessages() {
        return reduceErrors(this.errors);
    }

    handleCheckboxChange(event) {
        this.viewDetails = event.target.checked;
    }
}