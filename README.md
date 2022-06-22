<!--  -->
## Informacje o projekcie

Aplikacja mobilna iOS parsująca stronę www.arxiv.org, czyli elektronicznego archiwum preprintów. Możliwe jest subskrybowane podkategorii (dzięki czemu listy publikacji są zapisywane w bazie), pobieranie pdf-ów lub otwieranie ich w Safari. 

### Używane narzędzia programistyczne

* [Xcode](https://developer.apple.com/xcode/)
* [SwiftSoup](https://github.com/scinfu/SwiftSoup)
* [DropDown](https://cocoapods.org/pods/DropDown)
* [Realm](https://realm.io/)
* [Alamofire](https://github.com/Alamofire/Alamofire/)



## Sposób uruchomienia


1. Sklonuj repozytorium.
   ```sh
   git clone https://github.com/ArturkuB/arxivWebFeediOS.git
   ```
2. Zainstaluj CocoaPods na komputerze z system Mac OS.
   ```sh
	sudo gem install cocoapods
   ```
3. Nawiguj do folderu sklonowanego repozytorium zawierającego `Podfile`
   ```sh
   pod install
   ```
4. Uruchom `arxivWebFeed.xcworkspace` za pomocą Xcode
  
<!-- USAGE EXAMPLES -->
## Prezentacja
<p align="center">
    <img src="http://drive.google.com/uc?export=view&id=1srbUxX-L9N-TTpIL74p6Mb2D4ScwarF5" alt="Logo" width="450" height="890">
</p>

## License

Distributed under the Apache 2.0 License. See `LICENSE.md` for more information.


