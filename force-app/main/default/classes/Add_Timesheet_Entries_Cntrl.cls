/* 
Class Name        : Add_Timesheet_Entries_Cntrl
Test Class Name   : Test_Add_Timesheet_Entries
Purpose/Overview  : To override Edit page of Timesheet. To enter Timesheet and LineItems in Single Page.
Author            : Purview Ltd.
Code Coverage     : 100%.
Change History    : 
*/
public with sharing class Add_Timesheet_Entries_Cntrl{
    public Timesheet__c TSObj{get; set;}
    public Boolean PBS1 {get; set;}
    public Boolean LINEITEM {get; set;}
    public string GetID {get; set;}
    public list<Timesheet_Entry__c> TSEntrylist{get;set;}
    public list<Timesheet_Entry__c> TSEntrylist1{get;set;}
    public list<Timesheet_Entry__c> Original_TSEntrylist;
    list<Timesheet_Entry__c> TSEntrylist2;
    public list<wrapperclass> TSEntrywraplist{get;set;}
    public integer EntryCount{get;set;}
    public integer count{get;set;}
    public String errorMessage{get;set;}
    public Boolean error{get;set;}
    
    public Add_Timesheet_Entries_Cntrl(ApexPages.StandardController controller) {
        error=false;
        PBS1 = True;
        LINEITEM = FALSE;
        count = 0;
        GetID = ApexPages.CurrentPage().getParameters().get('Id');
        TSEntrylist= new List<Timesheet_Entry__c>();
        TSEntrylist1= New List<Timesheet_Entry__c>();
        TSEntrywraplist= new list<wrapperclass>();
        TSEntrylist2=new list<Timesheet_Entry__c>();
        if(Utils.isAccessible('I8__Timesheet__c')&& Utils.isAccessible('I8__Timesheet_Entry__c') ){
            Original_TSEntrylist = new List<Timesheet_Entry__c>();
            TSObj=[select id,Name,PayPeriod_Start__c,PayPeriod_End__c,Rate_Card_Per_Hour__c,Total_Hours__c,Status__c,Manager__c,Pay_Total__c,ownerid from Timesheet__c  where id=: GetID];
            if(TsObj.Status__c != 'New' && TsObj.Status__c != 'Rejected'){
                errorMessage = System.Label.AddTimeSheetEntries001;
                Error = true;
            }
            TSEntrylist=[select id,Start__c,End__c,SOE__c,Task__c,Timesheet__c,Net_Pay__c,Worked_Hours__c from Timesheet_Entry__c  where Timesheet__c =:GetID ]; 
            if(TSEntrylist.SIze() > 0){
                for(Timesheet_Entry__c tsentry: TSEntrylist){
                    Original_TSEntrylist.add(tsentry.clone(true,true,false,true));
                }
                TSentryWraperlist(TSEntrylist);
            }
            else
                NewLI();
        } else{  error=true;    errormessage = System.Label.ADMIN001;}
    }
    public class wrapperclass{
        public Timesheet_Entry__c TSEntry{get;set;}
        public Integer counterWrap{get;set;}    
        public wrapperclass(Timesheet_Entry__c tse,integer cnt){       
            this.TSEntry = Tse;
            this.counterWrap = cnt;
        }
    } 
    public void TSentryWraperlist(list<Timesheet_Entry__c> TSEntrylist ){
        TSEntrywraplist=new list<wrapperclass>();
        for(Timesheet_Entry__c TSE: TSEntrylist){           
            TSEntrywraplist.add(new wrapperclass(TSE,count+1));
            count++; 
        } 
    } 
    public PageReference Create() {
        Boolean displayError = false;
        Error = False;
        Savepoint sp = Database.setSavepoint();
        try{
            list<Timesheet_Entry__c> InsertList = new list<Timesheet_Entry__c>();
            list<Timesheet_Entry__c> UpdateList = new list<Timesheet_Entry__c>();
            
            for(Integer i=0; i < TSEntrywraplist.size(); i++){
                TSEntrywraplist[i].TSEntry.Timesheet__c = GetID;
                if(TSEntrywraplist[i].TSEntry.Id == null)
                    insertList.add(TSEntrywraplist[i].TSEntry);
                else 
                    UpdateList.add(TSEntrywraplist[i].TSEntry);
            }
            if( Utils.isCreateable('i8__Timesheet_Entry__c')) {
                for(Timesheet_Entry__c TSEntry : InsertLIst){
                    Error  = Tsentry_Validations(TSEntry);
                    if(Error  == true )
                        return null;
                }  
                if(InsertList.Size() > 0 && Utils.isCreateable('i8__Timesheet_Entry__c'))   
                    insert InsertList;
            }  
            else if(InsertList.Size() > 0){  displayError = true;      errorMessage = System.Label.AddTask006;   }
            list<Timesheet_Entry__c> TSEList = new list<Timesheet_Entry__c>();
            if( Utils.isUpdateable('i8__Timesheet_Entry__c')) {              
                for(Timesheet_Entry__c TSEntry : UpdateList){
                    Error  = Tsentry_Validations(TSEntry);
                    if(Error  == true )
                        return null;
                    else {
                        for(Timesheet_Entry__c TSEntrylist : Original_TSEntrylist){
                            if(TSEntry.Id == TSEntrylist.Id && TSEntry != TSEntrylist)
                                TSEList.add(TSEntry);
                        }                        
                    }                    
                } 
                if(TSEList.Size() > 0 && Utils.isUpdateable('i8__Timesheet_Entry__c'))
                    update TSEList;
            }  
            else if(TSEList.Size() > 0){
                displayError = true;  errorMessage =    System.Label.AddTask007 ;
            } 
            if(TSEntrylist1.size() > 0 ){
                if(Schema.sObjectType.Timesheet_Entry__c.isDeletable())
                    delete TSEntrylist1;
                else{ displayError = true;   errormessage = System.Label.AddTask008;  }
            }            
            if(displayError == false){
                PBS1 = False;
                return new pagereference('/'+GetID);
            } 
            else
                return null;                   
        }
        catch(Exception e){
            Database.rollback(sp);
            LogFactory.error('Add_Timesheet_Entries_Cntrl', 'Create', '', e.getMessage() + '' + e.getStackTraceString());  
            LogFactory.SaveLog(); 
            error = true;
            errorMessage = e.getMessage();                  
        }
        return Null;
    }
    
    public boolean Tsentry_Validations(Timesheet_Entry__c TSEntry){
        boolean bool = false;
        if(TSEntry.Start__c == null || TSEntry.End__c == null){ 
            TSEntry.Start__c.adderror(System.Label.AddTimeSheetEntries002);
            bool  = True;
        } 
        if(TSEntry.SOE__c == null){ 
            TSEntry.SOE__c.adderror(System.Label.AddTimeSheetEntries006);
            bool  = True;
        } 
        if((TsObj.PayPeriod_End__c!=null)&&(TSEntry != null)&&(TSEntry.End__c >TsObj.PayPeriod_End__c)){ 
            TSEntry.End__c.adderror(System.Label.AddTimeSheetEntries003);     
            bool  = True;
        }
        if(TSEntry.Start__c>TSEntry.End__c){  
            TSEntry.Start__c.adderror(System.Label.AddTimeSheetEntries004); 
            bool  = True;
        }
        if((TSEntry.Start__c != null) && (TsObj.PayPeriod_Start__c!= null) && (TSEntry.Start__c < TsObj.PayPeriod_Start__c)){   
            TSEntry.Start__c.adderror(System.Label.AddTimeSheetEntries005);
            bool  = True;
        }  
      if(bool  == False){
            Decimal d   = (Decimal)(TSEntry.End__c.getTime() - TSEntry.Start__c.getTime())/(1000*60*60);
            TSEntry.Total_Hours__c = Math.round(d);            
            TSEntry.Net_Pay__c = TsObj.Rate_Card_Per_Hour__c * TSEntry.Total_Hours__c;   
            TSEntryList2.add(TSEntry); 
        }  
        return bool;
    }
    
    Public PageReference NewLI(){       
        wrapperclass WC = New wrapperclass(New Timesheet_Entry__c(TimeSheet__c = TsObj.Id),TSEntrywraplist.size()+1);
        TSEntrywraplist.add(WC);        
        return null;
    }
    Public PageReference deleteLI(){
        for(Integer i=0; i<TSEntrywraplist.size(); i++){
            if(TSEntrywraplist[i].counterwrap == entrycount && TSEntrywraplist[i].TSEntry.id != null){
                TSEntrylist1.add(TSEntrywraplist[i].TSEntry);
                TSEntrywraplist.remove(i);               
            }else if(TSEntrywraplist[i].counterwrap == entrycount  && TSEntrywraplist[i].TSEntry.id == null){
                TSEntrywraplist.remove(i);
            }
        }
        return null; 
    }
}