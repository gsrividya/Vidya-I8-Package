<aura:application extends="force:slds">
    <aura:handler name="init" value="{!this}" action="{!c.doInit}" />
    <aura:attribute name="SOEId" type="string"/>
    <c:AllTasksMain_Cmp SOEId="{!v.SOEId}" />
</aura:application>