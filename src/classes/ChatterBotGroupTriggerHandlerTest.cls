/**
 * Developed by Doug Ayers
 * douglascayers.com
 */
@isTest
private class ChatterBotGroupTriggerHandlerTest {

    @isTest
    static void test_auto_create_chatter_bot_group() {

        Chatter_Bot_Groups_Setting__c settings = Chatter_Bot_Groups_Setting__c.getInstance();
        settings.auto_create_public_chatter_groups__c = true;
        upsert settings;

        Test.startTest();

        CollaborationGroup grp = new CollaborationGroup(
            name = 'Test Group',
            collaborationType = 'Public'
        );

        insert grp;

        Test.stopTest();

        System.assertEquals( 1, [ SELECT count() FROM Chatter_Bot_Group__c WHERE chatter_group_id__c = :grp.id ] );

    }

    @isTest
    static void test_no_auto_create_chatter_bot_group() {

        Chatter_Bot_Groups_Setting__c settings = Chatter_Bot_Groups_Setting__c.getInstance();
        settings.auto_create_public_chatter_groups__c = false;
        upsert settings;

        Test.startTest();

        CollaborationGroup grp = new CollaborationGroup(
            name = 'Test Group',
            collaborationType = 'Public'
        );

        insert grp;

        Test.stopTest();

        System.assertEquals( 0, [ SELECT count() FROM Chatter_Bot_Group__c WHERE chatter_group_id__c = :grp.id ] );

    }

    @isTest
    static void test_update_group() {

        CollaborationGroup grp = new CollaborationGroup(
            name = 'Test Group',
            collaborationType = 'Public'
        );

        insert grp;

        Chatter_Bot_Group__c chatterBotGroup = new Chatter_Bot_Group__c(
            chatter_group_id__c = grp.id,
            active__c = true
        );

        insert chatterBotGroup;

        Test.startTest();

        update grp;

        Test.stopTest();

        chatterBotGroup = [ SELECT id, chatter_group_id__c, group_name__c, collaboration_type__c FROM Chatter_Bot_Group__c WHERE id = :chatterBotGroup.id ];

        System.assertEquals( grp.id, chatterBotGroup.chatter_group_id__c );
        System.assertEquals( grp.name, chatterBotGroup.group_name__c );
        System.assertEquals( grp.collaborationType, chatterBotGroup.collaboration_type__c );

    }

    @isTest
    static void test_delete_group() {

        Chatter_Bot_Groups_Setting__c settings = Chatter_Bot_Groups_Setting__c.getInstance();
        settings.auto_create_public_chatter_groups__c = true;
        upsert settings;

        CollaborationGroup grp = new CollaborationGroup(
            name = 'Test Group',
            collaborationType = 'Public'
        );

        insert grp;

        System.assertEquals( 1, [ SELECT count() FROM Chatter_Bot_Group__c WHERE chatter_group_id__c = :grp.id ] );

        Test.startTest();

        delete grp;

        Test.stopTest();

        System.assertEquals( 0, [ SELECT count() FROM Chatter_Bot_Group__c WHERE chatter_group_id__c = :grp.id ] );

    }

}