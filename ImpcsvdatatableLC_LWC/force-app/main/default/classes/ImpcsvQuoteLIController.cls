public with sharing class ImpcsvQuoteLIController {

 public class WCcsvQL{
        @AuraEnabled public String ITEM_PART_ID {get;set;}
        @AuraEnabled public String ITEM_DESC {get;set;}
        @AuraEnabled public String ITEM_QTY {get;set;}
        @AuraEnabled public String ITEM_UNIT {get;set;}
        @AuraEnabled public String SELL {get;set;}
        @AuraEnabled public String STATUS {get;set;}
    }
    @AuraEnabled
    public static list<WCcsvQL> processCSVFile(Id idContentDocument){
        list<WCcsvQL> lstcsvQL = new list<WCcsvQL>();

        try{          
        if(idContentDocument != null) {
            // getting File Data based on document id 
            ContentVersion objVersion = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:idContentDocument];
            // split the file data
            list<String> lstCSVLines = objVersion.VersionData.toString().split('\n');
                // System.debug('csvRowData====> '+objVersion);

            for(Integer i = 1; i < lstCSVLines.size(); i++){
                WCcsvQL objCsvQL = new WCcsvQL();

                list<String> csvRowData = lstCSVLines[i].split(',');
                // System.debug('csvRowData====> '+csvRowData);
                objCsvQL.ITEM_PART_ID = csvRowData[1];
                objCsvQL.ITEM_DESC = csvRowData[2];
                objCsvQL.ITEM_QTY = csvRowData[3];
                objCsvQL.ITEM_UNIT = csvRowData[4];
                objCsvQL.SELL = csvRowData[10];
                
                    try {
                        String Product2 = [select id from Product2 where Vendor_Part__c =: csvRowData[1]].Id;
                            if (!String.isBlank(Product2)){
                                objCsvQL.STATUS = 'Matched';
                            }else {
                                objCsvQL.STATUS = 'No Product Found';
                            }
                        } catch (Exception ex) {
                            objCsvQL.STATUS = 'No Product Found';
                        }
                // String Pricebook2 = [Select Id From Pricebook2 Where Name =: 'Standard Price Book'].Id;
                // quotelineitemObj.Product2Id = Product2;
                // quotelineitemObj.QuoteId = recordId;
                lstcsvQL.add(objCsvQL);
            }
                if(!lstcsvQL.isEmpty()) {
                    // insert lstAccsToInsert;
                    deleteContent(idContentDocument);
                }
            }
        }
        catch (Exception ex) {
                throw new AuraHandledException(ex.getMessage());
        }                     
        return lstcsvQL;            
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