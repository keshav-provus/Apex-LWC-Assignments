trigger QLICategoryTrigger on QuoteLineItem (before insert, before update) {
    QLICategoryHandler.processCategoryUpdate(Trigger.new);
}