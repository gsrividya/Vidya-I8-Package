/* 
Class Name        : I8Constants
Purpose/Overview  : Constants class for I8
Author            : Purview Ltd.
Code Coverage     :  100%
Change History    : 
*/
public class I8Constants{
    // Status Fields
    public string STATUS_BUILD{get;set;}
    public string STATUS_REVIEW {get;set;}
    public string STATUS_SCHEDULED{get;set;}
    public string STATUS_FREEZE{get;set;}
    public string STATUS_IMPINPROGRESS{get;set;}
    public string STATUS_BOINPROGRESS{get;set;}
    public string STATUS_READY{get;set;}
    public string STATUS_WAITING {get;set;}
    public string STATUS_RUNNING {get;set;}
    public string STATUS_IMP_COMP{get;set;}
    public string STATUS_SOE_COMP{get;set;}
    public string STATUS_BO_COMP {get;set;}
    public string STATUS_COMPLETED{get;set;}
    public string STATUS_FORCE_COMP{get;set;}
    public string STATUS_SUSPENDED {get;set;}
    public string STATUS_RERUN{get;set;}
    public string STATUS_ABANDONED{get;set;}
    public string STATUS_CLOSE {get;set;}
    public string STATUS_OPEN{get;set;}
    public string STATUS_BUILD_JUMP{get;set;}
    public string STATUS_REVIEW_JUMP{get;set;}
    public string STATUS_SCHEDULED_JUMP{get;set;}
    public string STATUS_FREEZE_JUMP{get;set;}
    public string STATUS_WAITING_JUMP {get;set;}
    public string STATUS_TOBE_RELEASED {get;set;}
    public string STATUS_COMP_JUMP{get;set;}
    public string STATUS_JUMP{get;set;}
    public string JUMP{get;set;}
    public string BO_MANUAL{get;set;}
    public string BO_AUTOMATED{get;set;}
    
    //Phase Fields
    public string STAGE_PRE{get;set;}
    public string STAGE_IMP{get;set;}
    public string STAGE_POST{get;set;}
    public string STAGE_BACKOUT {get;set;}
    
    // Dependency strings
    public string LINKDEP{get;set;}
    public string INTERNALDEP {get;set;}
    public string EXTERNALDEP {get;set;}
    public string NODEP {get;set;}
    public string PREDECESSOR {get;set;}
    public string SUCCESSOR{get;set;}
    public string DEP_FS{get;set;}
    public string DEP_SS{get;set;}
    
    //SOE QA Review and WalkThrough fields
    public string SOE_QA_INP {get;set;}
    public string SOE_NONE {get;set;}
    public string SOE_FEEDBACK{get;set;}
    public string SOE_COMPLETE {get;set;}
    
    // SOE Context Fields
    public string CONTEXT_IMP{get;set;}
    public string CONTEXT_BO{get;set;}
    
    //Stack Start and End Titles
    public string PRE_STACK_START {get;set;}
    public string IMP_STACK_START {get;set;}
    public string POST_STACK_START {get;set;}
    public string BOIMP_STACK_START{get;set;}
    public string BOPOST_STACK_START {get;set;}
    public string END_CKP {get;set;}
    public string START_CKP{get;set;}
    
    public I8Constants(){
        STATUS_BUILD = 'Build';
        STATUS_REVIEW = 'Review';
        STATUS_SCHEDULED = 'Scheduled';
        STATUS_FREEZE = 'Freeze';
        STATUS_IMPINPROGRESS = 'Imp In Progress';
        STATUS_BOINPROGRESS = 'BO In Progress';
        STATUS_READY = 'Ready';
        STATUS_WAITING = 'Waiting';
        STATUS_RUNNING = 'Running';
        STATUS_IMP_COMP = 'Imp Completed';
        STATUS_SOE_COMP = 'SOE Completed';
        STATUS_BO_COMP = 'BO Completed';
        STATUS_COMPLETED = 'Completed';
        STATUS_SUSPENDED = 'Suspended';
        STATUS_ABANDONED = 'Abandoned';
        STATUS_TOBE_RELEASED  = 'To Be Released';
        STATUS_RERUN = 'ReRun';
        STAGE_PRE = 'Pre';
        STAGE_IMP = 'Imp';
        STAGE_POST = 'Post';
        STAGE_BACKOUT = 'BackOut';
        LINKDEP = 'Link';
        INTERNALDEP = 'Internal';
        EXTERNALDEP = 'External';
        NODEP = 'None';
        PREDECESSOR = 'Predecessors';
        SUCCESSOR= 'Successors';
        DEP_FS= 'FS';
        DEP_SS= 'SS';
        SOE_QA_INP = 'In Progress';
        SOE_NONE = 'None';
        SOE_FEEDBACK = 'Feedback';
        SOE_COMPLETE = 'Complete';
        CONTEXT_IMP = 'Implementation';
        CONTEXT_BO = 'BackOut';
        PRE_STACK_START = 'Pre-Imp Stack';
        IMP_STACK_START = 'Imp Stack';
        POST_STACK_START = 'Post-Imp Stack';
        BOIMP_STACK_START = 'BO Implementation';
        BOPOST_STACK_START = 'BO Post Implementation';
        END_CKP = ' Trl';
        START_CKP =' Hdr';
        STATUS_OPEN = 'Open';
        STATUS_CLOSE = 'Closed';
        STATUS_BUILD_JUMP = 'Build-Jump';
        STATUS_REVIEW_JUMP = 'Review-Jump';
        STATUS_SCHEDULED_JUMP = 'Scheduled-Jump';
        STATUS_FREEZE_JUMP = 'Freeze-Jump';
        STATUS_WAITING_JUMP = 'Waiting-Jump';
        STATUS_COMP_JUMP = 'Completed-Jump';
        STATUS_FORCE_COMP = 'Force Completed';
        STATUS_JUMP = 'Jump';
        JUMP = '-Jump';
        BO_MANUAL = 'Manual';
        BO_AUTOMATED ='Automated';
    }
}