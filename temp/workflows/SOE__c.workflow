<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Sending_mail_when_QA_Comleted</fullName>
        <description>Sending mail when QA Comleted</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approvals/QA_Complete_for_SOE</template>
    </alerts>
    <alerts>
        <fullName>When_SOE_Is_cloned_Default_Imp_Manager_will_receive_mail</fullName>
        <description>When SOE Is cloned, Default Imp Manager will receive mail</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Notifications/SOE_Cloned_Imp_Manager_Mail_Template</template>
    </alerts>
    <fieldUpdates>
        <fullName>QA_Review_In_Progress</fullName>
        <field>QA_Review__c</field>
        <literalValue>In Progress</literalValue>
        <name>QA Review In Progress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>QA_Review_To_Completed</fullName>
        <field>QA_Review__c</field>
        <literalValue>Complete</literalValue>
        <name>QA Review To Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>QA_Review_To_FeedBack</fullName>
        <field>QA_Review__c</field>
        <literalValue>Feedback</literalValue>
        <name>QA Review To FeedBack</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SOE_RAG_to_Red</fullName>
        <field>SOE_RAG__c</field>
        <literalValue>Red</literalValue>
        <name>SOE RAG to Red</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SOE_Rag_to_Amber</fullName>
        <field>SOE_RAG__c</field>
        <literalValue>Amber</literalValue>
        <name>SOE Rag to Amber</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SOE_Rag_to_Green</fullName>
        <field>SOE_RAG__c</field>
        <literalValue>Green</literalValue>
        <name>SOE Rag to Green</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SOE_Status_is_Imp_Completed</fullName>
        <field>Status__c</field>
        <literalValue>Imp Completed</literalValue>
        <name>SOE Status is Imp Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SOE_Status_is_SOE_Completed</fullName>
        <field>Status__c</field>
        <literalValue>SOE Completed</literalValue>
        <name>SOE Status is SOE Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SOE_status_to_BO_Completed</fullName>
        <field>Status__c</field>
        <literalValue>BO Completed</literalValue>
        <name>SOE status to BO Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SOE_status_to_SOE_BO_Completed</fullName>
        <field>Status__c</field>
        <literalValue>SOE BO Completed</literalValue>
        <name>SOE status to SOE BO Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_WlakThrough_To_Compelte</fullName>
        <field>WalkThrough__c</field>
        <literalValue>Complete</literalValue>
        <name>Update WalkThrough  To Compelte</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_WlakThrough_To_In_Progress</fullName>
        <field>WalkThrough__c</field>
        <literalValue>In Progress</literalValue>
        <name>Update WalkThrough  To In Progress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Get SOE Palnned End to MIS</fullName>
        <active>true</active>
        <criteriaItems>
            <field>SOE__c.Max_Planned_End__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>If BO  is  Completed or not</fullName>
        <actions>
            <name>SOE_status_to_SOE_BO_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(ISPICKVAL( Status__c , &apos;BO Completed&apos;),  Not_Comp_BO_Post_Stacks__c=   Comp_BO_Post_Stacks__c, Comp_BO_Post_Stacks__c != 0)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>If BO is Imp Completed or not</fullName>
        <actions>
            <name>SOE_status_to_BO_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(ISPICKVAL( Status__c , &apos;BO In Progress&apos;), IF(Not_Comp_BO_Imp_Stacks__c=  Comp_BO_Imp_Stacks__c,true,false), Comp_BO_Imp_Stacks__c != 0)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>If SOE is  Completed or not</fullName>
        <actions>
            <name>SOE_Status_is_SOE_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(ISPICKVAL( Status__c , &apos;Imp Completed&apos;),  Not_Comp_Post_Stacks__c =   Comp_Post_Stacks__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>If SOE is Imp Completed or not</fullName>
        <actions>
            <name>SOE_Status_is_Imp_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(ISPICKVAL( Status__c , &apos;Imp In Progress&apos;), IF(Not_Comp_Imp_Stacks__c  =  Comp_Imp_Stacks__c ,true,false))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>RAG Update to Amber</fullName>
        <actions>
            <name>SOE_Rag_to_Amber</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( NOT(ISNULL( Schedule_Start__c )), Max_End_Time__c  &gt;  Schedule_End__c, Max_End_Time__c &lt;=  Warning_Zone__c   , NOT(ISPICKVAL(SOE_RAG__c , &apos;Amber&apos;))  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>RAG Update to Green</fullName>
        <actions>
            <name>SOE_Rag_to_Green</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( NOT(ISNULL( Schedule_Start__c )), Max_End_Time__c  &lt;=  Schedule_End__c , NOT(ISPICKVAL(SOE_RAG__c , &apos;Green&apos;))  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>RAG Update to Red</fullName>
        <actions>
            <name>SOE_RAG_to_Red</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( NOT(ISNULL( Schedule_Start__c )), Max_End_Time__c  &gt;  Warning_Zone__c , NOT(ISPICKVAL(SOE_RAG__c , &apos;Red&apos;))  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>When SOE Is cloned%2C Imp Manager will receive mail</fullName>
        <actions>
            <name>When_SOE_Is_cloned_Default_Imp_Manager_will_receive_mail</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(NOT( ISNULL( Cloned_SOE__c ) ),NOT( ISBLANK( Cloned_SOE__c ) ))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
