public class CategoryDAO {
    public static List<Category__c> getByIds(Set<Id> categoryIds) {
        if (categoryIds == null || categoryIds.isEmpty()) return new List<Category__c>();
        return [SELECT Id, Default_Discount__c FROM Category__c WHERE Id IN :categoryIds];
    }
}
