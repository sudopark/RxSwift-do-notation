# RxSwift-do-extension


RxSwift [do notation](https://en.wikibooks.org/wiki/Haskell/do_notation) using Swift Concurrency async/await syntax

```swift
func loadHighestPriceItemInfo() -> Maybe<HighestPriceItemInfo> {
    
    return storeService.highestPriceItemID()
        .flatMap { itemID in
            guard var item = try await storeService.loadItem(itemID).value,
                  let seller = try await userService.loadUser(item.sellerID).value
            else {
                throw ...
            }
            item.convertedPrice = try await priceConverter.convertPrice(item.price, to: "BTC").value
            return HighestPriceItemInfo(item, seller)
        }
}
```
