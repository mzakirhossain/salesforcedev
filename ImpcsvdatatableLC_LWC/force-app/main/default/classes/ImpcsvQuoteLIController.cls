public with sharing class ImpcsvQuoteLIController {

 public class WCcsvQL{ //wrapper/container class
        @AuraEnabled public String ITEM_PART_ID {get;set;}
        @AuraEnabled public String ITEM_DESC {get;set;}
        @AuraEnabled public String ITEM_QTY {get;set;}
        @AuraEnabled public String ITEM_UNIT {get;set;}
        @AuraEnabled public String SELL {get;set;}
        @AuraEnabled public String STATUS {get;set;}
        @AuraEnabled public String Product2Id {get;set;}

        @AuraEnabled public String STATUStext {get;set;}

        @AuraEnabled public String StatusCSSClass {get;set;}
        @AuraEnabled public String Statusicon {get;set;}

        
    }

    @AuraEnabled
    public static list<WCcsvQL> processCSVFile(Id idContentDocument,Id recordId,String isimportcsv){
        list<WCcsvQL> wclstcsvQL = new list<WCcsvQL>();

        try{         
        if(isimportcsv=='true'){
                System.debug('csvRowData true ===> '+idContentDocument+' recordId '+recordId+'-'+isimportcsv);

            if(idContentDocument != null) {
                // getting File Data based on document id 
                ContentVersion objVersion = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:idContentDocument];
                // split the file data
                list<String> lstCSVLines = objVersion.VersionData.toString().split('\n');
                Decimal qnty;
                Decimal unitprice;
                for(Integer i = 1; i < lstCSVLines.size(); i++){
                    WCcsvQL objCsvQL = new WCcsvQL();

                    list<String> csvRowData = lstCSVLines[i].split(',');
                    if (!csvRowData.isEmpty()) {

                        objCsvQL.ITEM_PART_ID = csvRowData[1];
                        objCsvQL.ITEM_DESC = csvRowData[2];
                        objCsvQL.ITEM_QTY = csvRowData[3];
                        objCsvQL.ITEM_UNIT = csvRowData[4];
                        objCsvQL.SELL = csvRowData[10];       

                          try {                                         
                            qnty=Decimal.valueOf(csvRowData[3]);
                            unitprice = Decimal.valueOf(csvRowData[10]);

                                String Product2 = [select id from Product2 where Vendor_Part__c =: csvRowData[1]].Id;
                                String PricebookEntryId = [select id from PricebookEntry where Product2Id =: Product2].Id;                                        

                                    if (!String.isBlank(Product2) && !String.isBlank(PricebookEntryId)){                                    
                                        objCsvQL.STATUS = 'Success';
                                        objCsvQL.Product2Id = Product2;
                                        objCsvQL.STATUStext = 'Matched';
                                        objCsvQL.Statusicon = 'action:approval';  
                                        objCsvQL.StatusCSSClass = 'slds-text-color_success';                                                                                
                                    }else {
                                        objCsvQL.STATUS = 'Failed';
                                        objCsvQL.STATUStext = 'No-Product-Found';
                                        objCsvQL.Statusicon = 'action:close';     
                                        objCsvQL.StatusCSSClass = 'slds-text-color_error';  
                                    }
                                } catch (Exception ex) {
                                        objCsvQL.STATUS = 'Failed';
                                        objCsvQL.STATUStext = 'No-Product-Found';
                                        objCsvQL.Statusicon = 'action:close';                
                                        objCsvQL.StatusCSSClass = 'slds-text-color_error';  
                                    System.debug('Exception csv import soql: '+ex.getMessage());                                    
                                }
                        wclstcsvQL.add(objCsvQL);
                    }
                }
                    // if(!wclstcsvQL.isEmpty()) {
                    //     deleteContent(idContentDocument);
                    // }
                }
            }        
            else if(isimportcsv=='false'){  
                System.debug('csvRowData false ===> '+idContentDocument+' recordId '+recordId+'-'+isimportcsv);

                SaveProductsQuote(idContentDocument,recordId);
            }
        }    
        catch (Exception ex) {
                throw new AuraHandledException(ex.getMessage());
        }                     
        return wclstcsvQL;            
    }
    public static void SaveProductsQuote(Id idContentDocument,Id recordId){
        list<QuoteLineItem> lstQL = new list<QuoteLineItem>();

        if(idContentDocument != null && recordId != null ) {
                // getting File Data based on document id 
                ContentVersion objVersion = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:idContentDocument];
                // split the file data
                list<String> lstCSVLines = objVersion.VersionData.toString().split('\n');

                for(Integer i = 1; i < lstCSVLines.size(); i++){
                    QuoteLineItem quotelineitemObj = new QuoteLineItem() ;

                    list<String> csvRowData = lstCSVLines[i].split(',');
                    if (!csvRowData.isEmpty()) {
                            try {
                                String Product2 = [select id from Product2 where Vendor_Part__c =: csvRowData[1]].Id;
                                    if (!String.isBlank(Product2)){                                    

                                        quotelineitemObj.Quantity = Decimal.valueOf(csvRowData[3]);
                                        quotelineitemObj.QuoteId = recordId;
                                        quotelineitemObj.UnitPrice = Decimal.valueOf(csvRowData[10]);

                                        quotelineitemObj.Product2Id = Product2;
                                        quotelineitemObj.PricebookEntryId = [select id from PricebookEntry where Product2Id =: Product2].Id;                                        

                                        if (!String.isBlank(quotelineitemObj.PricebookEntryId)){                                    
                                            lstQL.add(quotelineitemObj);
                                        }
                                    }
                                } catch (Exception ex) {    
                                    System.debug('Exception while adding product in QL list: '+ex.getMessage());
                                }
                    }
                }
                    upsert lstQL;
        }
        // return '';
    }

    public static void deleteContent(Id idContentDocument){

        // Set < Id > setContentVerIds = new Set < Id >();
        // for ( FeedItem FI : [ SELECT Id, RelatedRecordId FROM FeedItem ] ) { 
        //         //Add your required where condition
        // if ( String.isNotBlank(FI.RelatedRecordId) )
        // setContentVerIds.add(FI.RelatedRecordId);//RelatedRecordId is the Content Version Id
        // }

        List < ContentDocument > listFiles = new List < ContentDocument >();
        for ( ContentVersion CV : [ SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: idContentDocument ] )
        listFiles.add(new ContentDocument(Id = CV.ContentDocumentId));

        if ( listFiles.size() > 0 )
        delete listFiles;
    }
}