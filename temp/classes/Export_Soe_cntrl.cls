/* 
Class Name        : Export_Soe_cntrl 
Test Class Name   : Test_ExportSOE
Purpose/Overview  : To Export SOE and Tasks into CSV or PDF 
Author            : Purview Ltd.
Code Coverage     : 95%
Change History    : 

*/
public with sharing class Export_Soe_cntrl {
    public String selectradio { get; set; }
    public boolean displaypopup { get; set; }
    public list<String> leftselected { get; set; }
    public String DownloadSoe { get; set; }
    public boolean SelectList { get; set; }
    public String SearchValue { get; set; }
    public list<String> Rightselected { get; set; }
    public string PageName{get;set;}
    public soe__C soelist{get;set;}
    public list<string> leftlist{get;set;}
    public list<string> rightlist{get;set;}
    public Map<string,string> colMap{get;set;}
    public List<SelectOption> SOE_Options{get;set;}
    public string fieldsdisplay{get;set;}
    public string errormsg {get;set;}
    boolean SOE_Access;
    
    public Export_Soe_cntrl(){
        errormsg = null;
        PageName = ApexPages.CurrentPage().getParameters().get('Page');
        SelectList=false; 
        displaypopup=false;
        leftlist=new list<string>();
        rightlist= new list<string>(); 
        colMap = new map<string,string>(); 
        soelist=new soe__C();     
        SOE_Access = Utils.isAccessible('i8__SOE__c');  
        if(PageName != 'tab')
            SelectedSOEdownload();
        else
            getSOEOptions();     
            colMap.put('SOETitle','I8__SOE_Title__c');
            colMap.put('Pre-Imp Stage','I8__Pre_Implementation_Stage__c');
            colMap.put('Programme','I8__Programme__c');
            colMap.put('Post-Imp Stage','I8__Post_Implementation_Stage__c');
            colMap.put('Project','I8__Project__c');
            colMap.put('BackOut Stage','I8__BackOut_Stage__c');
            colMap.put('Department','I8__Department__c'); 
            colMap.put('Template','I8__Is_Template__c');
            colMap.put('WalkThrough Required','I8__WalkThrough_Required__c');
            colMap.put('QA Manager','I8__QA_Manager__c');
            colMap.put('QA Review Required','I8__QA_Review_Required__c');
            colMap.put('Audio Call No','I8__Conference_Call_No__c');
            colMap.put('RAG','I8__RAG__c');
            colMap.put('Change Request No','I8__Change_Record__c');    
            colMap.put('Template','I8__Is_Template__c');
            colMap.put('Imp Duration','I8__Imp_Duration__c'); 
            colMap.put('Summary','I8__Summary__c');         
            colMap.put('Baseline Start','I8__Baseline_Start__c');       
            colMap.put('Status','I8__Status__c');
            leftlist.addall(colMap.keyset());
    } 
    public List<SelectOption> getSOEOptions(){
        SOE_Options = new List<SelectOption>();
        if(SOE_Access )
            for(SOE__c soe : [select id,Name,SOE_Title__c from SOE__c where Is_Template__c = false order by Name desc])
                SOE_Options.add(new selectoption(soe.id,soe.Name+' - '+soe.SOE_Title__c));
        return SOE_Options;
    }
    public void SOE_List(){
        errormsg = null;
        SOE_Options = new List<SelectOption>();
        String val='%'+SearchValue +'%';
        if(SOE_Access )
            for(SOE__c soe : [select id,Name,SOE_Title__c from SOE__c where (SOE_Title__c Like: val  or Name Like:val )and Is_Template__c = false])
                SOE_Options.add(new selectoption(soe.id,soe.Name+' - '+soe.SOE_Title__c));
    }
    public void SelectedSOEdownload(){
        if(SOE_Access ){
            if(PageName == 'tab')
                soelist= [Select id,Name,SOE_Title__c,Status__c,BackOut_Stage__c,Change_Record__c,Programme__c,Project__c,Conference_Call_No__c,Post_Implementation_Stage__c,Pre_Implementation_Stage__c,Department__c,Summary__c,Task_Late_Threshold_mins__c,QA_Review_Required__c,Imp_Duration__c ,Baseline_Start__c,WalkThrough_Required__c,QA_Manager__c from SOE__C where id =: DownloadSoe ];
            else{ 
                DownloadSoe = ApexPages.CurrentPage().getParameters().get('Id');
                if(DownloadSoe != null)
                soelist= [Select id,Name,SOE_Title__c,Status__c,Department__r.Name,BackOut_Stage__c,Change_Record__c,Programme__c,Project__c,Conference_Call_No__c,Post_Implementation_Stage__c,Pre_Implementation_Stage__c,Department__c,Summary__c,Task_Late_Threshold_mins__c,QA_Review_Required__c,Imp_Duration__c ,Baseline_Start__c,WalkThrough_Required__c,QA_Manager__c from SOE__C where id=:DownloadSoe];
                SelectList = true;
            }
        }
    }    
    public PageReference CancelSOE() {        
        if(PageName != 'tab')
            DownloadSoe=null; 
        return new pagereference('/'+SOE__c.sobjecttype.getDescribe().getKeyPrefix()+'/o');
    }    
    public PageReference Select_soe() {
        errormsg = null;
        if(DownloadSoe == '' || DownloadSoe == null){
           errormsg  =System.Label.CloneSOE007;
        }else{
            SelectList = true;
            if(SOE_Access )
                soelist=[Select id,Name,SOE_Title__c,Status__c,Department__r.Name,BackOut_Stage__c,Change_Record__c,Programme__c,Project__c,Conference_Call_No__c,Post_Implementation_Stage__c,Pre_Implementation_Stage__c,Department__c,Summary__c,Task_Late_Threshold_mins__c,QA_Review_Required__c,Imp_Duration__c ,WalkThrough_Required__c,Baseline_Start__c ,QA_Manager__c from SOE__C where Is_Template__c=false and id=:DownloadSoe]; 
       }
        return null;
    }    
    public PageReference AddFields() {
        if(leftselected .size()>0){
            rightlist.addAll(leftselected );
            for( integer i=0; i<leftlist.Size(); i++){
                for(string j: leftselected ){
                    if(leftlist[i] == j)
                        leftlist.remove(i);
                }
            }
        }
        return null;
    }
    public list<selectoption> getleftFields(){
        list<selectoption> options = new list<selectoption>();       
        for(String s : leftlist) {
            options.add(new selectoption(s,s));
        }
        return options;
    }        
    public list<selectoption> getRightfileds() {
        list<selectoption> options = new list<selectoption>();
        for(String i : rightlist) {
            options.add(new selectoption(i,i));
        }
        return options ;
    }
    public PageReference DeleteFields() {
        if(Rightselected .size()>0){
            leftlist.addAll(Rightselected );
            for( integer i=0; i<rightlist.Size(); i++){
                for(string j: Rightselected ){
                    if(rightlist[i] == j)
                        rightlist.remove(i);
                }
            }
        }
        return null;
    }    
    public PageReference Export_method() {
     if(Utils.isAccessible('i8__Task__c')){
        displaypopup=true;
       }else{errormsg = System.Label.ADMIN001;}                            
        return null;
    }    
    public PageReference DownloadSoe_method() {
      Savepoint sp = Database.setSavepoint();
        try{                       
           fieldsdisplay='';
        for(integer i=0;i<rightlist.size();i++){ 
             if( colMap.get(rightlist[i]) == 'Programme__c')
                 fieldsdisplay +=  'Programme__r.Name'; 
            else if( colMap.get(rightlist[i]) == 'Project__c')
                 fieldsdisplay +=  'Project__r.Name';
            else if( colMap.get(rightlist[i]) == 'Department__c')
                 fieldsdisplay +=  'Department__r.Name'; 
            else if( colMap.get(rightlist[i]) == 'QA_Manager__c')
                 fieldsdisplay +=  'QA_Manager__r.Name';       
            else  
             fieldsdisplay+=colMap.get(rightlist[i]);
            if(i<=rightlist.Size()-2){                    
                fieldsdisplay+=','; 
            } 
        } 
        if(fieldsdisplay == '')
            fieldsdisplay = 'Name';
        if(selectradio == 'pdf' && DownloadSoe != null && DownloadSoe !='0')
            return new PageReference ('/apex/Export_pdfmainpage?id='+DownloadSoe+'&fields='+fieldsdisplay); 
        else if(selectradio == 'CSV' && DownloadSoe != null && DownloadSoe !='0')
            return new PageReference ('/apex/Export_csvpage?id='+DownloadSoe +'&fields='+fieldsdisplay);
        }
        catch(Exception e){
           Database.rollback(sp);
           LogFactory.error('Export_Soe_cntrl ', 'DownloadSoe_method', '', e.getMessage() + '' + e.getStackTraceString());  
           LogFactory.SaveLog(); 
           errormsg  = e.getMessage();                  
        }
        return null;  
    }    
    public PageReference close_method() {
        displaypopup =false;
        SelectList=false;
         if(PageName == 'tab')
        DownloadSoe = null;      
        return null;
    }    
    public PageReference Clear_search() {
        errormsg = null;
        SelectList=false; 
        DownloadSoe = null;   
        SearchValue ='';      
        return null;
    }    
}