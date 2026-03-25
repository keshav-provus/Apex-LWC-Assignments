public class QuoteLineItemTriggerHandler {
    public static void processQuoteLineItems(List<QuoteLineItem> newItems) {
        Set<Id> categoryIds = new Set<Id>();
        for (QuoteLineItem qli : newItems) {
            if (qli.Category__c != null) {
                categoryIds.add(qli.Category__c);
            }
        }
        
        if (categoryIds.isEmpty()) {
            return;
        }
        
        Map<Id, Category__c> categoryMap = new Map<Id, Category__c>(CategoryDAO.getByIds(categoryIds));
        
        List<Quantitiy_Tier__c> quantityTiers = QuantityTierDAO.getByCategories(categoryIds);
        
        for (QuoteLineItem qli : newItems) {
            if (qli.Category__c == null) {
                continue; 
            }
            
            Decimal categoryDiscount = 0.0;
            if (categoryMap.containsKey(qli.Category__c) && categoryMap.get(qli.Category__c).Default_Discount__c != null) {
                categoryDiscount = categoryMap.get(qli.Category__c).Default_Discount__c;
            }
            
            Decimal quantityDiscount = 0.0;
            Decimal currentQuantity = qli.Quantity != null ? qli.Quantity : 0.0;
            
            for (Quantitiy_Tier__c tier : quantityTiers) {
                if (tier.Category__c == qli.Category__c) {
                    Decimal minQty = tier.Minimum_Quantity__c != null ? tier.Minimum_Quantity__c : 0.0;
                    Decimal maxQty = tier.Maximum_Quantity__c != null ? tier.Maximum_Quantity__c : 999999999.0;
                    
                    if (currentQuantity >= minQty && currentQuantity <= maxQty) {
                        quantityDiscount = tier.Discount__c != null ? tier.Discount__c : 0.0;
                        break; 
                    }
                }
            }
            
            qli.Category_Based_Discount__c = categoryDiscount;
            qli.Quantitiy_Tier_Discount__c = quantityDiscount;
            
            Decimal offeredDiscount = qli.Offered_Discount__c != null ? qli.Offered_Discount__c : 0.0;
            qli.Discount = categoryDiscount + quantityDiscount + offeredDiscount;
        }
    }
}