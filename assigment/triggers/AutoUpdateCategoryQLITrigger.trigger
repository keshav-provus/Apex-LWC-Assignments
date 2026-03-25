trigger AutoUpdateCategoryQLITrigger on QuoteLineItem (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            AutoUpdateCategoryQLITriggerHandler.beforeInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            AutoUpdateCategoryQLITriggerHandler.beforeUpdate(Trigger.oldMap, Trigger.new);
        }
    }
}
