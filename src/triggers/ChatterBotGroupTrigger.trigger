trigger ChatterBotGroupTrigger on CollaborationGroup ( after insert, after update, before delete ) {

    if ( Trigger.isInsert || Trigger.isUpdate ) {

        new ChatterBotGroupTriggerHandler().upsertChatterBotGroups( Trigger.new );

    } else if ( Trigger.isDelete ) {

        new ChatterBotGroupTriggerHandler().deleteChatterBotGroups( Trigger.old );

    }

}