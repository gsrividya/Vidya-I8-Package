/* 
Class Name        : Search_and_Replace_cntrl
Test Class Name   : Test_Search_and_Replace_cntrl
Purpose/Overview  : To search and replace some fields with particular values.
Author            : Purview Ltd.
Code Coverage     : 100%.
Change History    : 
*/
public with sharing class Search_and_Replace_cntrl {
    public map<string,string> map1{get;set;}
    public set<string> strings{get;set;} 
    public String strng { get; set; }
    public boolean selectall { get; set; }
    public boolean str1 {get;set;}
    public string str{get;set;}
    public Task__c taskobj { get; set; }
    public id SOEid{get;set;}
    public SOE__c SOEobj{get;set;}
    public boolean Technical_DetailCheck { get; set; }
    public boolean DescriptionCheck { get; set; }
    public boolean TitleCheck { get; set; }    
    public boolean Filter_check { get; set; }
    public String Replace { get; set; }
    public String Search_string { get; set; }
    public list<WrapperTasks> WrapperList{get;set;}
    public list<task__c> TaskList{get;set;}
    public list<task__C> TaskList1{get;set;}
    public string SearchValue{get;set;}
    public list<string> searchlist1{get;set;}  
    public boolean checkboxvalue{get;set;}
    public boolean displayPopup {get; set;}
    Public Map<Id,Id> ImpMgrMap{get;set;}
    public string ImpMgrMapKey{get;set;}
    public boolean error{get;set;}
    public string errormessage{get;set;}
    boolean Task_Access;
    
    public Search_and_Replace_cntrl(){  
        strings = new set<string>();       
        taskobj = new Task__c ();
        map1=new map<string,string>();
        SOEobj=new SOE__c();
        taskobj.Stage_Level__c='Implementation';
        SearchValue='';
        Search_string ='';
        checkboxvalue=false;
        Filter_check =true; 
        displayPopup = false; 
        error = false;
        strng='';        
        checkboxvalue = false;
        SOEid=Apexpages.currentPage().getParameters().get('id'); 
        Task_Access = Utils.isAccessible('i8__Task__c');
        if(Task_Access){
            if(Utils.isAccessible('i8__SOE__c'))
                SOEobj=[select id,name,SOE_Title__c,State__c,status__c,QA_Review_Required__c,QA_Review__c,WalkThrough_Required__c,WalkThrough__c from SOE__c where id=:SOEId];
            ImpMgrMap = new Map<Id,Id>();
            if(Utils.isAccessible('i8__SOE_Team_Member__c'))
            for( SOE_Team_Member__c imp : [select Id,Name,Team_Member__r.Salesforce_User__c,Access_Level__c  from SOE_Team_Member__c where SOE__c =: SOEObj.Id  and Access_Level__c = 'Read' ])  
                ImpMgrMap.put(imp.Team_Member__r.Salesforce_User__c,imp.Team_Member__r.Salesforce_User__c);
            ImpMgrMapKey = string.valueof(ImpMgrMap.keyset()).replace('{', '').replace('{', '');
            TaskList1= new list<task__c>();
            searchlist1=new list<string>();
            TaskList =[select id,SOE__C,Is_Stack__c,State__c,Status__c,Stage_Level__c,Type__c ,End_Stack__c,ID_Text__c,Id_After_Decimal__c,Stage__c,Task_Title__c,Id_Before_Decimal__c,Technical_Detail__c,Description__c from Task__C where SOE__c =:SOEid and Stage_Level__c =: taskobj.Stage_Level__c order by Id_Before_Decimal__c,Id_After_Decimal__c,Stage__c asc limit 1000]; 
            TaskWithWrapper(TaskList);
        }else {error = true;errormessage = System.Label.ADMIN001;}
    }
    public class WrapperTasks{
        public boolean check{get;set;}
        public Task__c task{get;set;}
        public WrapperTasks(boolean b,Task__c t){
            check = b;
            task =t;
        }
    }
    public void TaskWithWrapper(list<Task__c> TaskList){
        WrapperList = new List<WrapperTasks>();
        for(Task__c t: TaskList )  {  
            WrapperList.add(new WrapperTasks(false,t));
        } 
    }
    public void Go_Method() {  
        error = false;
        if(Task_ACCESS){
            if(SearchValue!= ''){ 
                String Search1 = '%' + SearchValue + '%';
                TaskList1 = [select id,SOE__C,Is_Stack__c,Type__c,State__c,Status__c,Stage_Level__c ,End_Stack__c,ID_Text__c,Id_After_Decimal__c,Stage__c,Task_Title__c,Id_Before_Decimal__c,Technical_Detail__c,Description__c
                             from Task__c where SOE__c=: SOEId and Stage_Level__c =: taskobj.Stage_Level__c And (Stage__c like :Search1 or ID_Text__c like :Search1 or Task_Title__c like :Search1 or Status__c like :Search1  ) order by Id_After_Decimal__c,Id_Before_Decimal__c asc ];
            }
            else{
                TaskList1= [select id,SOE__C,Is_Stack__c,State__c,Type__c,Status__c,Stage_Level__c ,End_Stack__c,ID_Text__c,Id_After_Decimal__c,Stage__c,Task_Title__c,Id_Before_Decimal__c,Technical_Detail__c,Description__c from Task__C where SOE__c =:SOEid and Stage_Level__c =: taskobj.Stage_Level__c order by Id_Before_Decimal__c,Id_After_Decimal__c asc];
                TaskWithWrapper(TaskList1);
            }
            TaskWithWrapper(TaskList1); 
            if(SearchValue=='' ){
                TaskList1= [select id,SOE__C,Is_Stack__c,State__c,Status__c,Type__c,Stage_Level__c ,End_Stack__c,ID_Text__c,Id_After_Decimal__c,Stage__c,Task_Title__c,Id_Before_Decimal__c,Technical_Detail__c,Description__c from Task__C where SOE__c =:SOEid and Stage_Level__c =: taskobj.Stage_Level__c order by Id_Before_Decimal__c,Id_After_Decimal__c asc];
                TaskWithWrapper(TaskList1);
            } 
        } else{error = true;errormessage = System.Label.ADMIN001;}                                     
        SearchValue='';            
    }
    public PageReference Replace_action() {    
        if(Task_Access && Utils.isUpdateable('i8__Task__c')) {
            Savepoint sp = Database.setSavepoint();
            try{
                error = false;
                list<task__c> taskchecklist= new list<task__c>(); 
                if(Search_string == '' || Search_string == null){
                    errormessage = SYstem.Label.SOEReplace001;
                    error = true;
                    return null;
                }        
                for(WrapperTasks wt:WrapperList ){
                    if(wt.check == true)
                        taskchecklist.add(wt.task);   
                }
                if(taskchecklist.size()==0){
                    errormessage  = SYstem.Label.SOEReplace002;
                    error = true;
                    return null;
                }
                for(task__c t2:taskchecklist){
                    if(TitleCheck == true){
                        str= t2.Task_Title__c;
                        str1=str.contains(Search_string );
                        if(str1==true){
                            t2.Task_Title__c=str.replace(Search_string ,replace);}
                    }
                    if(DescriptionCheck == true){
                        str=t2.Description__c ;
                        if(str=='' || str ==null){
                            errormessage  = SYstem.Label.SOEReplace003 ;
                            error = true;
                            return null;
                        }
                        else{
                            str1=str.contains(Search_string);
                            if(str1==true){
                                t2.Description__c =str.replace(Search_string ,replace);}                
                        }
                    }   
                    if(Technical_DetailCheck == true){
                        str=t2.Technical_Detail__c;
                        if(str=='' || str ==null){               
                            errormessage  = SYstem.Label.SOEReplace004;
                            error = true;
                        }
                        else{
                            str1=str.contains(Search_string );
                            if(str1==true){
                                t2.Technical_Detail__c =str.replace(Search_string ,replace);} 
                        }     
                    }  
                }
                LogFactory.info('Search_and_Replace_cntrl', 'Replace_action', 'Replace String', replace ,'Line - 145'); 
                if(Utils.isUpdateable('i8__Task__c'))    
                    update taskchecklist;
                TaskList =[select id,SOE__C,Is_Stack__c,State__c,Status__c,Stage_Level__c,Type__c ,End_Stack__c,ID_Text__c,Id_After_Decimal__c,Stage__c,Task_Title__c,Id_Before_Decimal__c,Technical_Detail__c,Description__c from Task__C where SOE__c =:SOEid and Stage_Level__c =: taskobj.Stage_Level__c order by Id_Before_Decimal__c,Id_After_Decimal__c asc];
                TaskWithWrapper(TaskList);
                Search_string='';
                Replace='';
                TitleCheck= false;
                DescriptionCheck=false;
                Technical_DetailCheck=false;
            }catch(Exception e){
                Database.rollback(sp);
                LogFactory.error('Search_and_Replace_cntrl', 'Replace_action', '', e.getMessage() + '' + e.getStackTraceString());          
                error = true; 
                errormessage = e.getMessage();                  
             }
         }  else {error = true;errormessage = System.Label.ADMIN001;LogFactory.debug('Search_and_Replace_Cntrl', 'Replace Method', 'TaskInfo ', System.Label.ADMIN001,'Line - 170');}       
         LogFactory.SaveLog();
        return null;
    }
    public void SelectAllCheckbox(){
        if(SelectAll == true){
            for(integer i=0;i< WrapperList.size() ; i++)
                WrapperList[i].check = true;             
        }
        else{
            for(integer i=0;i< WrapperList.size() ; i++)
                WrapperList[i].check = false;
        }     
    } 
    public PageReference cancel_method() {
        return new PageReference('/apex/AllTasks_ClientSide?id='+SOEid);
    }    
    public PageReference Clear_Method() {
        SearchValue='';
        if(Task_Access)
            TaskList1= [select id,SOE__C,Is_Stack__c,State__c,Status__c,Type__c,Stage_Level__c ,End_Stack__c,ID_Text__c,Id_After_Decimal__c,Stage__c,Task_Title__c,Id_Before_Decimal__c,Technical_Detail__c,Description__c from Task__C where SOE__c =:SOEid and Stage_Level__c =: taskobj.Stage_Level__c order by Id_Before_Decimal__c,Id_After_Decimal__c asc];
        TaskWithWrapper(TaskList1);
        return null;
    }
}