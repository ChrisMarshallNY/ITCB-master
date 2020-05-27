extension Array where Element: CBAttribute {
    public subscript(_ inUUIDString: String) -> Element! {
        for element in self where element.uuid.uuidString == inUUIDString {
            return element
        }
        
        return nil
    }
}
