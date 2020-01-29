import { LightningElement, track, api } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import updateProject from '@salesforce/apex/updateProject.updateProjectFiletype';

export default class UploadProjFiles extends LightningElement {
    @api recordId;
    @track error;

    get acceptedFormats() {
        return ['.pdf','.png','.jpg','.jpeg'];
    }

    PermitsUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        updateProject({idContentDocument : uploadedFiles[0].documentId, recordId: this.recordId, type : "permits"});
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success!!',
                message: 'Permits File upload.',
                variant: 'success',
            }),
        );
    }

    PlatssUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        updateProject({idContentDocument : uploadedFiles[0].documentId, recordId: this.recordId, type : "plats"});

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success!!',
                message: 'Plats File upload.',
                variant: 'success',
            }),
        );        
    }

}