/* 
Class Name        : Soe_AllAttachments_Cntrl
Test Class Name   : Test_Soe_AllAttachments_Cntrl
Purpose/Overview  : Display all Audio files attached to the SOE.
Author            : Purview Ltd.
Code Coverage     : 100%.
Change History    : 
*/
public with sharing class Soe_AllAttachments_Cntrl {
 public List<Attachment> listAttachment {get;set;}
    public Soe__c soe {get;set;}
    
    public Soe_AllAttachments_Cntrl(ApexPages.StandardController controller) {
        soe = (Soe__c )controller.getRecord();
        listAttachment = new List<Attachment>();
        if(Schema.SObjectType.Attachment.isAccessible())
            listAttachment = [Select Id, ContentType, Name from Attachment where ParentId = :soe.Id];          
    }
    public pagereference openCancel(){
        return new pagereference ('/apex/AllTasks_ClientSide?id='+SOE.Id);
    }
}