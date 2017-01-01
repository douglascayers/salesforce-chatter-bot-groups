/**
 * Developed by Doug Ayers
 * douglascayers.com
 */
trigger ChatterBotGroupTrigger on CollaborationGroup ( after insert, after update, before delete ) {

    ChatterBotGroupTriggerHandler handler = new ChatterBotGroupTriggerHandler();

    if ( Trigger.isInsert || Trigger.isUpdate ) {

        handler.upsertChatterBotGroups( Trigger.new );

    } else if ( Trigger.isDelete ) {

        handler.deleteChatterBotGroups( Trigger.old );

    }

}