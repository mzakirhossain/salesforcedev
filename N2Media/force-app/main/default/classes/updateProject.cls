public with sharing class updateProject {
    @AuraEnabled
    public static void updateProjectFiletype(Id idContentDocument,Id recordId,String type){

        WorkOrder WOToUpdate;
        ContentDocument CDoUpdate;
        try{         
            WOToUpdate = 
                    [SELECT Permit__c,Plat_of_Survey__c,Project_Name__c FROM WorkOrder WHERE Id=:recordId LIMIT 1];
            CDoUpdate = 
                    [SELECT Title FROM ContentDocument WHERE Id=:idContentDocument LIMIT 1];

            if(type=='plats'){
                WOToUpdate.Plat_of_Survey__c = true;
                CDoUpdate.Title='Plats of Survey for Project'+WOToUpdate.Project_Name__c;
            }
            else if(type=='permits'){
                WOToUpdate.Permit__c = true;
                CDoUpdate.Title='Permits for Project'+WOToUpdate.Project_Name__c;
            }
            update WOToUpdate;                    
            update CDoUpdate;                    
        }
        catch(Exception ex){}
    }
}