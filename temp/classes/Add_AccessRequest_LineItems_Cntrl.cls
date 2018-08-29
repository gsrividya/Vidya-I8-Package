/* 
Class Name        : Add_AccessRequest_LineItems_Cntrl 
Test Class Name   : Test_Access_Request_Cntrl
Purpose/Overview  : To Add Line Items to Access Request
Author            : Purview Ltd.
Code Coverage     : 100%
Change History    : 

*/
public with sharing class Add_AccessRequest_LineItems_Cntrl {
    public string errormessage {get;set;}
    public Access_Request__c AR {get; set;}
    Public Id RequestId{get;set;}
    public List<wrapclass> WrapperList{get;set;} 
    public integer EntryCount{get;Set;}
    public boolean output{get;set;}
    public list<Access_Request_Line_Item__c> DeleteLIstARLI{get;set;}
    public list<Access_Request_Line_Item__c> Orig_ARLIMap;

    public Add_AccessRequest_LineItems_Cntrl(ApexPages.StandardController controller) {
        RequestId = ApexPAges.CurrentPage().getParameters().get('id');
        output = false;
        errormessage = null;
        if(Utils.isAccessible('I8__Access_Request__c') && Utils.isAccessible('I8__Access_Request_Line_Item__c')){
             Orig_ARLIMAp = new list<Access_Request_Line_Item__c>();
             DeleteLIstARLI = new list<Access_Request_LIne_Item__c>();
             if(Schema.sObjectTYpe.ProcessInstance.isAccessible())
             AR = [select id,name,(select id,name,Access_Granted_Status__c,Requested_User_ID__c,Overall_Status__c,Requested_User__c ,Access_Dropped__c,Request_Raised__c,Access_Verified__c,ACR_Type_Other__c,Access_Type_Other__c,
                End_Time__c,Start_Time__c,Environment_Other__c,Access_Request_ID__c,Access_Request_Type__c,Access_Type__c,Additional_Comments__c,Application_Access__c,Environment__c from Access_Request_Line_Items__r order by name)
                Domain_ID__c,Domain__c,Deactivate__c,Implementation_Manager__c,End_Time__c,Clone_ID__c,Start_Time__c,Request_Description__c,Request_Raised_Status__c,
                SOE__c,Task__c,(select status from ProcessInstances order by createddate desc) from Access_Request__c where id =: RequestId];
            if(AR.Access_Request_Line_Items__r.SIze() > 0){
                  AddToWrapperLIst(AR.Access_Request_Line_Items__r);
                  for (Access_Request_Line_Item__c arli : AR.Access_Request_Line_Items__r)
                      Orig_ARLIMap.add(arli.clone(true,true,false,true));
            } else
                  AddRow();
             If(AR.ProcessInstances.size() > 0 && AR.ProcessInstances[0].status == 'Pending')
                    output = true;
         }
         else { errormessage = System.Label.ADMIN001;}
    }
    public void AddToWrapperLIst(list<Access_Request_Line_Item__c> AREntrylist ){
        WrapperList = new list<wrapclass>();   
        integer count =0;     
        for(Access_Request_Line_Item__c ARE: AREntrylist){                         
            WrapperList.add(new wrapclass(ARE,count));
            count++;
        }  
    }
    public class wrapclass{
        public Integer counterWrap{get;set;}  
        public Access_Request_Line_Item__c ARLI {get; set;}
        public wrapclass(Access_Request_Line_Item__c LI,integer c){       
            this.ARLI=LI;
            this.counterWrap=c;
        }
    }  
    public void addRow(){ 
        if(WrapperList == null)
             WrapperList = new list<wrapclass>(); 
        WrapperLIst.Add(new wrapclass(new Access_Request_Line_Item__c(Request_Raised__c = AR.Request_Raised_Status__c),WrapperLIst.Size()));
    }  
    public void DeleteRow(){
        for(Integer i=0; i < WrapperLIst.size(); i++){
            if(WrapperLIst[i].counterWrap == EntryCount){
                if(WrapperLIst[i].ARLI.Id != null)
                    DeleteLIstARLI.add(WrapperLIst[i].ARLI);
                WrapperLIst.remove(i);
            }
        }
        list<wrapclass> WrapperList1 = new list<wrapclass>();
        for(Integer i=0; i < WrapperLIst.size(); i++)
             WrapperLIst1.add(new wrapclass(wrapperlist[i].ARLI,i));
        WrapperLIst.clear();
        WrapperLIst.AddAll(WrapperLIst1);   
    }
    public pagereference SaveLineItems(){
        Boolean displayError = False;
        boolean bool = false;
        errorMessage = null;
        list<Access_Request_line_Item__c> LIstARLI = new list<Access_Request_LIne_Item__c>();
        try{
            list<Access_Request_Line_Item__c> InsertList = new list<Access_Request_Line_Item__c>();
            list<Access_Request_Line_Item__c> UpdateList = new list<Access_Request_Line_Item__c>();
            for(Integer i=0; i < WrapperList.size(); i++){
                WrapperLIst[i].ARLI.Access_Request_ID__c = RequestId;
                if(WrapperList[i].ARLI.Id == null)
                    insertList.add(WrapperList[i].ARLI);
                else 
                    UpdateList.add(WrapperLIst[i].ARLI);
            }
             if( Utils.isCreateable('i8__Access_Request_Line_Item__c')) {
                 for(Access_Request_Line_Item__c arli : InsertLIst){
                    bool = ARLI_Validations(arli);
                    if(bool == true )
                        return null;
                 }  
                 if(InsertList.Size() > 0 && Utils.isCreateable('i8__Access_Request_Line_Item__c'))                    
                         insert InsertList;
            }  
            else if(InsertList.Size() > 0){  displayError = true;     errorMessage = System.Label.AddTask006;   }
            list<Access_Request_Line_Item__c> arlilist1 = new list<Access_Request_Line_Item__c>();
            if( Utils.isUpdateable('i8__Access_Request_Line_Item__c')   ) {              
                 for(Access_Request_Line_Item__c arli : UpdateList){
                    bool = ARLI_Validations(arli);
                    if(bool == true )
                        return null;
                    else {
                        for(Access_Request_Line_Item__c  arli1 : Orig_ARLIMap){
                            if(arli.Id == arli1.Id && arli != arli1)
                                arlilist1.add(arli);
                        }                        
                    }                    
                 } 
                 if(arlilist1.Size() > 0 && Utils.isUpdateable('i8__Access_Request_Line_Item__c'))                    
                         update arlilist1;
            }  
            else if(arlilist1.Size() > 0){
                 displayError = true;  
                 errorMessage =    System.Label.AddTask007 ;               
            }    
                 if(DeleteLIstARLI.Size() > 0){
                    if(Schema.sObjectType.Access_Request_Line_Item__c.isDeletable())
                        delete DeleteLIstARLI;
                    else {  displayError = true;  errorMessage =    System.Label.AddTask008 ;  }
                 }
                 if(displayError == False)
                    return new pagereference('/'+RequestId);
        }catch(Exception e){
           LogFactory.error('Access_Request_Cntrl', 'SaveLineItems', '', e.getMessage() + '' + e.getStackTraceString());         
           errorMessage = e.getMessage();
           LogFactory.SaveLog();
        }
        return null;
    }
    public boolean ARLI_Validations(Access_Request_Line_Item__c arli){
        boolean bool = false;
        If(ARLI.Start_Time__c == null ){
            ARLI.Start_Time__c.adderror(System.Label.AccessRequest001);
            bool = true;
        }
        If(ARLI.End_Time__c == null){
           ARLI.End_Time__c.adderror(System.Label.AccessRequest002);
            bool = true;
        }
        If(ARLI.End_Time__c < ARLI.Start_Time__c){
            ARLI.End_Time__c.adderror(System.Label.AccessRequest003);
            bool = true;
        }
        If(ARLI.Start_Time__c < AR.Start_Time__c || ARLI.End_Time__c > AR.End_Time__c){
            ARLI.Start_Time__c.adderror(System.Label.AccessRequest004);
            bool = true;
        }                
        If(String.isempty(ARLI.Requested_User__c)){
            ARLI.Requested_User__c.adderror(System.Label.AccessRequest005);
            bool = true;
        }
        If((ARLI.Access_Request_Type__c == 'Other') && (ARLI.ACR_Type_Other__c== NULL || ARLI.ACR_Type_Other__c== '')){
            ARLI.ACR_Type_Other__c.adderror(System.Label.AccessRequest006);
            bool = true;
        }
        If((ARLI.Environment__c == 'Other') && (ARLI.Environment_Other__c== NULL || ARLI.Environment_Other__c== '')){
            ARLI.Environment_Other__c.adderror(System.Label.AccessRequest007);
            bool = true;
        }  
        If((ARLI.Access_Type__c == 'Other') && (ARLI.Access_Type_Other__c== NULL || ARLI.Access_Type_Other__c== '')){
            ARLI.Access_Type_Other__c.adderror(System.Label.AccessRequest008);
            bool = true;
        }
        return bool;
    }
    public pagereference CancelPage(){
        return new pagereference('/'+RequestId);
    }
}