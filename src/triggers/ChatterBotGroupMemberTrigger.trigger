trigger ChatterBotGroupMemberTrigger on CollaborationGroupMember ( after insert, after update, before delete ) {

    if ( Trigger.isInsert || Trigger.isUpdate ) {

        new ChatterBotGroupMemberTriggerHandler().upsertChatterBotGroupMembers( Trigger.new );

    } else if ( Trigger.isDelete ) {

        new ChatterBotGroupMemberTriggerHandler().deleteChatterBotGroupMembers( Trigger.old );

    }

}