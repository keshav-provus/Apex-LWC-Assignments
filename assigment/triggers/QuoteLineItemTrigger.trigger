trigger QuoteLineItemTrigger on QuoteLineItem (before insert, before update) {
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        QuoteLineItemTriggerHandler.processQuoteLineItems(Trigger.new);
    }
}