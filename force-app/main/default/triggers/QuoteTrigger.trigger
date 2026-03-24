trigger QuoteTrigger on Quote (after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        QuoteTriggerHandler.afterUpdate(Trigger.oldMap, Trigger.newMap);
    }
}
