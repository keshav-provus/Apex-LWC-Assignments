trigger QuoteLineItemTrigger on QuoteLineItem (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            QuoteLineItemTriggerHandler.beforeInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            QuoteLineItemTriggerHandler.beforeUpdate(Trigger.oldMap, Trigger.new);
        }
    }
}