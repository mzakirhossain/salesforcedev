import { LightningElement, track, api } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import processCSVFile from '@salesforce/apex/ImpcsvQuoteLIController.processCSVFile';

/* eslint-disable no-console */
 /* eslint-disable no-alert */

const columns = [
    { label: 'Item Part Id', fieldName: 'ITEM_PART_ID', sortable: "true"}, 
    { label: 'Product Name', fieldName: 'ITEM_DESC', sortable: "true" },
    { label: 'Quantity', fieldName: 'ITEM_QTY', sortable: "true", type:'number'},
    { label: 'Unit', fieldName: 'ITEM_UNIT', sortable: "true"}, 
    { label: 'Unit Price', fieldName: 'SELL', sortable: "true", type:'number'},
    { label: 'Status', fieldName: 'STATUS', sortable: "true"}
];

export default class ImpcsvQuoteLI extends LightningElement {
    @api recordId;
    @track error;
    @track columns = columns;
    @track data;

    @track sortBy;
    @track sortDirection

    // accepted parameters
    get acceptedFormats() {
        return ['.csv'];
    }
    @track isSaveButton;
    @track isRetryButton;
    @track isSaveIgnoreButton;

    @api documentId;

    JsUploadFinished(event) {
        
        // this.isButtonDisabled="false";

        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;

        // calling apex class
        this.documentId=uploadedFiles[0].documentId;

        processCSVFile({idContentDocument : this.documentId, recordId: this.recordId, isimportcsv : "true"})
        .then(result => {
            // window.console.log('dataresult ===> '+JSON.stringify(result));
            this.data = result;

            let resultArr =result;            
            let objSearch = null; 
            objSearch = resultArr.find(o => o.STATUS === 'No Product Found');            
            // window.console.log('dataresult obj===> '+JSON.stringify(objSearch));
             
            // window.console.log('dataresult obj length===> '+Object.entries(objSearch).length);

            if(typeof objSearch != "undefined" && Object.entries(objSearch).length > 0){
                this.isRetryButton="true";
                this.isSaveIgnoreButton="true";
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Warning, Some products are not MATCHED!!',
                        message: 'Please Retry or Save with ignore those products.!!',
                        variant: 'warning',
                        // mode:'sticky',
                    }),
                );     
            }

            if(typeof objSearch === "undefined"){
                this.isSaveButton="true";
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success!!',
                        message: 'All Products are uploaded successfully, please review and save to Quote!!!',
                        variant: 'success',
                        // mode:'sticky',
                    }),
                );
            }
        })
        .catch(error => {
            // this.error = error;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error to uploaded Products!!',
                    message: (error),
                    variant: 'error',
                    // mode:'sticky',
                }),
            );     
        })
    }
        
    SaveProductsQuoteJS(event) {
        // calling apex class
        processCSVFile({idContentDocument : this.documentId, recordId: this.recordId, isimportcsv : "false"})
        .then(result => {
            this.isRetryButton="";
            this.isSaveIgnoreButton="";
            this.isSaveButton="";

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!!',
                    message: 'Products are Saved successfully in QL!!!',
                    variant: 'success',
                    // mode:'sticky',
                }),
            );
        })
        .catch(error => {
            // this.error = error;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error to save Products to Quote!!',
                    message: (error),
                    variant: 'error',
                    // mode:'sticky',
                }),
            );     
        })

    }

    handleSortdata(event) {
        // field name
        this.sortBy = event.detail.fieldName;

        // sort direction
        this.sortDirection = event.detail.sortDirection;

        // calling sortdata function to sort the data based on direction and selected field
        this.sortData(event.detail.fieldName, event.detail.sortDirection);
    }

    sortData(fieldname, direction) {
        // serialize the data before calling sort function
        let parseData = JSON.parse(JSON.stringify(this.data));

        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };

        // cheking reverse direction 
        let isReverse = direction === 'asc' ? 1: -1;

        // sorting data 
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';

            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });

        // set the sorted data to data table data
        this.data = parseData;

    }    
}