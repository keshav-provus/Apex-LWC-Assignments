public class QuoteLineItemTriggerHandler {

    public static void beforeInsert(List<QuoteLineItem> newItems) {
        processQuoteLineItems(newItems);
    }

    public static void beforeUpdate(Map<Id, QuoteLineItem> oldMap, List<QuoteLineItem> newItems) {
        processQuoteLineItems(newItems);
    }
    
    private static void processQuoteLineItems(List<QuoteLineItem> newItems) {
        Set<Id> productIds = new Set<Id>();
        for (QuoteLineItem qli : newItems) {
            if (qli.Product2Id != null) {
                productIds.add(qli.Product2Id);
            }
        }
        
        // 1. Map Product2 to get Category__c
        Map<Id, Product2> productMap = new Map<Id, Product2>();
        if (!productIds.isEmpty()) {
            productMap = new Map<Id, Product2>([SELECT Id, Category__c FROM Product2 WHERE Id IN :productIds]);
        }
        
        Set<Id> categoryIds = new Set<Id>();
        for (QuoteLineItem qli : newItems) {
            // Re-assign Category from Product2 if available (Ported from existing trigger)
            if (qli.Product2Id != null && productMap.containsKey(qli.Product2Id)) {
                qli.Category__c = productMap.get(qli.Product2Id).Category__c;
            }
            if (qli.Category__c != null) {
                categoryIds.add(qli.Category__c);
            }
        }
        
        if (categoryIds.isEmpty()) {
            return;
        }
        
        // 2. Query Category__c to get Default_Discount__c
        Map<Id, Category__c> categoryMap = new Map<Id, Category__c>([
            SELECT Id, Default_Discount__c 
            FROM Category__c 
            WHERE Id IN :categoryIds
        ]);
        
        // 3. Query Quantitiy_Tier__c for matching discounts
        List<Quantitiy_Tier__c> quantityTiers = [
            SELECT Id, Category__c, Minimum_Quantity__c, Maximum_Quantity__c, Discount__c
            FROM Quantitiy_Tier__c
            WHERE Category__c IN :categoryIds
        ];
        
        // 4. Calculate Discounts for each QuoteLineItem
        for (QuoteLineItem qli : newItems) {
            if (qli.Category__c == null) {
                continue; // Cannot apply category/quantity discount without a category
            }
            
            // A. Get Category Discount
            Decimal categoryDiscount = 0.0;
            if (categoryMap.containsKey(qli.Category__c) && categoryMap.get(qli.Category__c).Default_Discount__c != null) {
                categoryDiscount = categoryMap.get(qli.Category__c).Default_Discount__c;
            }
            
            // B. Get Quantity Discount
            Decimal quantityDiscount = 0.0;
            Decimal currentQuantity = qli.Quantity != null ? qli.Quantity : 0.0;
            
            for (Quantitiy_Tier__c tier : quantityTiers) {
                if (tier.Category__c == qli.Category__c) {
                    Decimal minQty = tier.Minimum_Quantity__c != null ? tier.Minimum_Quantity__c : 0.0;
                    Decimal maxQty = tier.Maximum_Quantity__c != null ? tier.Maximum_Quantity__c : 999999999.0;
                    
                    if (currentQuantity >= minQty && currentQuantity <= maxQty) {
                        quantityDiscount = tier.Discount__c != null ? tier.Discount__c : 0.0;
                        break; // Found matching tier
                    }
                }
            }
            
            // C. Assign output fields (matching names from the original Flow)
            qli.Category_Based_Discount__c = categoryDiscount;
            qli.Quantitiy_Tier_Discount__c = quantityDiscount;
            
            // Total Discount: Category Discount + Quantity Discount + Offered Discount (default 0)
            Decimal offeredDiscount = qli.Offered_Discount__c != null ? qli.Offered_Discount__c : 0.0;
            qli.Discount = categoryDiscount + quantityDiscount + offeredDiscount;
        }
    }
}
