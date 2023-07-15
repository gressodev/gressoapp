//
// This is a generated file, do not edit!
// Generated by R.swift, see https://github.com/mac-cain13/R.swift
//

import Foundation
import RswiftResources
import UIKit

private class BundleFinder {}
let R = _R(bundle: Bundle(for: BundleFinder.self))

struct _R {
  let bundle: Foundation.Bundle
  var string: string { .init(bundle: bundle, preferredLanguages: nil, locale: nil) }
  var color: color { .init(bundle: bundle) }
  var image: image { .init(bundle: bundle) }
  var font: font { .init(bundle: bundle) }
  var file: file { .init(bundle: bundle) }
  var storyboard: storyboard { .init(bundle: bundle) }

  func string(bundle: Foundation.Bundle) -> string {
    .init(bundle: bundle, preferredLanguages: nil, locale: nil)
  }
  func string(locale: Foundation.Locale) -> string {
    .init(bundle: bundle, preferredLanguages: nil, locale: locale)
  }
  func string(preferredLanguages: [String], locale: Locale? = nil) -> string {
    .init(bundle: bundle, preferredLanguages: preferredLanguages, locale: locale)
  }
  func color(bundle: Foundation.Bundle) -> color {
    .init(bundle: bundle)
  }
  func image(bundle: Foundation.Bundle) -> image {
    .init(bundle: bundle)
  }
  func font(bundle: Foundation.Bundle) -> font {
    .init(bundle: bundle)
  }
  func file(bundle: Foundation.Bundle) -> file {
    .init(bundle: bundle)
  }
  func storyboard(bundle: Foundation.Bundle) -> storyboard {
    .init(bundle: bundle)
  }
  func validate() throws {
    try self.font.validate()
    try self.storyboard.validate()
  }

  struct project {
    let developmentRegion = "en"
  }

  /// This `_R.string` struct is generated, and contains static references to 1 localization tables.
  struct string {
    let bundle: Foundation.Bundle
    let preferredLanguages: [String]?
    let locale: Locale?
    var localizable: localizable { .init(source: .init(bundle: bundle, tableName: "Localizable", preferredLanguages: preferredLanguages, locale: locale)) }

    func localizable(preferredLanguages: [String]) -> localizable {
      .init(source: .init(bundle: bundle, tableName: "Localizable", preferredLanguages: preferredLanguages, locale: locale))
    }


    /// This `_R.string.localizable` struct is generated, and contains static references to 1 localization keys.
    struct localizable {
      let source: RswiftResources.StringResource.Source

      /// en translation: TRY-ON
      ///
      /// Key: try-on
      ///
      /// Locales: en, ru, es-419
      var tryOn: RswiftResources.StringResource { .init(key: "try-on", tableName: "Localizable", source: source, developmentValue: "TRY-ON", comment: nil) }
    }
  }

  /// This `_R.color` struct is generated, and contains static references to 1 colors.
  struct color {
    let bundle: Foundation.Bundle

    /// Color `AccentColor`.
    var accentColor: RswiftResources.ColorResource { .init(name: "AccentColor", path: [], bundle: bundle) }
  }

  /// This `_R.image` struct is generated, and contains static references to 8 images.
  struct image {
    let bundle: Foundation.Bundle

    /// Image `bag`.
    var bag: RswiftResources.ImageResource { .init(name: "bag", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `favorites`.
    var favorites: RswiftResources.ImageResource { .init(name: "favorites", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `home`.
    var home: RswiftResources.ImageResource { .init(name: "home", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `menuButtonIcon`.
    var menuButtonIcon: RswiftResources.ImageResource { .init(name: "menuButtonIcon", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `squares`.
    var squares: RswiftResources.ImageResource { .init(name: "squares", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `stars`.
    var stars: RswiftResources.ImageResource { .init(name: "stars", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `sun`.
    var sun: RswiftResources.ImageResource { .init(name: "sun", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `virtualTryOnIcon`.
    var virtualTryOnIcon: RswiftResources.ImageResource { .init(name: "virtualTryOnIcon", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }
  }

  /// This `_R.font` struct is generated, and contains static references to 18 fonts.
  struct font: Sequence {
    let bundle: Foundation.Bundle

    /// Font `Jost-Black`.
    var jostBlack: RswiftResources.FontResource { .init(name: "Jost-Black", bundle: bundle, filename: "Jost Black.ttf") }

    /// Font `Jost-BlackItalic`.
    var jostBlackItalic: RswiftResources.FontResource { .init(name: "Jost-BlackItalic", bundle: bundle, filename: "Jost BlackItalic.ttf") }

    /// Font `Jost-Bold`.
    var jostBold: RswiftResources.FontResource { .init(name: "Jost-Bold", bundle: bundle, filename: "Jost Bold.ttf") }

    /// Font `Jost-BoldItalic`.
    var jostBoldItalic: RswiftResources.FontResource { .init(name: "Jost-BoldItalic", bundle: bundle, filename: "Jost BoldItalic.ttf") }

    /// Font `Jost-ExtraBold`.
    var jostExtraBold: RswiftResources.FontResource { .init(name: "Jost-ExtraBold", bundle: bundle, filename: "Jost ExtraBold.ttf") }

    /// Font `Jost-ExtraBoldItalic`.
    var jostExtraBoldItalic: RswiftResources.FontResource { .init(name: "Jost-ExtraBoldItalic", bundle: bundle, filename: "Jost ExtraBoldItalic.ttf") }

    /// Font `Jost-ExtraLight`.
    var jostExtraLight: RswiftResources.FontResource { .init(name: "Jost-ExtraLight", bundle: bundle, filename: "Jost ExtraLight.ttf") }

    /// Font `Jost-ExtraLightItalic`.
    var jostExtraLightItalic: RswiftResources.FontResource { .init(name: "Jost-ExtraLightItalic", bundle: bundle, filename: "Jost ExtraLightItalic.ttf") }

    /// Font `Jost-Italic`.
    var jostItalic: RswiftResources.FontResource { .init(name: "Jost-Italic", bundle: bundle, filename: "Jost Italic.ttf") }

    /// Font `Jost-Light`.
    var jostLight: RswiftResources.FontResource { .init(name: "Jost-Light", bundle: bundle, filename: "Jost Light.ttf") }

    /// Font `Jost-LightItalic`.
    var jostLightItalic: RswiftResources.FontResource { .init(name: "Jost-LightItalic", bundle: bundle, filename: "Jost LightItalic.ttf") }

    /// Font `Jost-Medium`.
    var jostMedium: RswiftResources.FontResource { .init(name: "Jost-Medium", bundle: bundle, filename: "Jost Medium.ttf") }

    /// Font `Jost-MediumItalic`.
    var jostMediumItalic: RswiftResources.FontResource { .init(name: "Jost-MediumItalic", bundle: bundle, filename: "Jost MediumItalic.ttf") }

    /// Font `Jost-Regular`.
    var jostRegular: RswiftResources.FontResource { .init(name: "Jost-Regular", bundle: bundle, filename: "Jost Regular.ttf") }

    /// Font `Jost-SemiBold`.
    var jostSemiBold: RswiftResources.FontResource { .init(name: "Jost-SemiBold", bundle: bundle, filename: "Jost SemiBold.ttf") }

    /// Font `Jost-SemiBoldItalic`.
    var jostSemiBoldItalic: RswiftResources.FontResource { .init(name: "Jost-SemiBoldItalic", bundle: bundle, filename: "Jost SemiBoldItalic.ttf") }

    /// Font `Jost-Thin`.
    var jostThin: RswiftResources.FontResource { .init(name: "Jost-Thin", bundle: bundle, filename: "Jost Thin.ttf") }

    /// Font `Jost-ThinItalic`.
    var jostThinItalic: RswiftResources.FontResource { .init(name: "Jost-ThinItalic", bundle: bundle, filename: "Jost ThinItalic.ttf") }

    func makeIterator() -> IndexingIterator<[RswiftResources.FontResource]> {
      [jostBlack, jostBlackItalic, jostBold, jostBoldItalic, jostExtraBold, jostExtraBoldItalic, jostExtraLight, jostExtraLightItalic, jostItalic, jostLight, jostLightItalic, jostMedium, jostMediumItalic, jostRegular, jostSemiBold, jostSemiBoldItalic, jostThin, jostThinItalic].makeIterator()
    }
    func validate() throws {
      for font in self {
        if !font.canBeLoaded() { throw RswiftResources.ValidationError("[R.swift] Font '\(font.name)' could not be loaded, is '\(font.filename)' added to the UIAppFonts array in this targets Info.plist?") }
      }
    }
  }

  /// This `_R.file` struct is generated, and contains static references to 18 resource files.
  struct file {
    let bundle: Foundation.Bundle

    /// Resource file `Jost Black.ttf`.
    var jostBlackTtf: RswiftResources.FileResource { .init(name: "Jost Black", pathExtension: "ttf", bundle: bundle, locale: LocaleReference.none) }

    /// Resource file `Jost BlackItalic.ttf`.
    var jostBlackItalicTtf: RswiftResources.FileResource { .init(name: "Jost BlackItalic", pathExtension: "ttf", bundle: bundle, locale: LocaleReference.none) }

    /// Resource file `Jost Bold.ttf`.
    var jostBoldTtf: RswiftResources.FileResource { .init(name: "Jost Bold", pathExtension: "ttf", bundle: bundle, locale: LocaleReference.none) }

    /// Resource file `Jost BoldItalic.ttf`.
    var jostBoldItalicTtf: RswiftResources.FileResource { .init(name: "Jost BoldItalic", pathExtension: "ttf", bundle: bundle, locale: LocaleReference.none) }

    /// Resource file `Jost ExtraBold.ttf`.
    var jostExtraBoldTtf: RswiftResources.FileResource { .init(name: "Jost ExtraBold", pathExtension: "ttf", bundle: bundle, locale: LocaleReference.none) }

    /// Resource file `Jost ExtraBoldItalic.ttf`.
    var jostExtraBoldItalicTtf: RswiftResources.FileResource { .init(name: "Jost ExtraBoldItalic", pathExtension: "ttf", bundle: bundle, locale: LocaleReference.none) }

    /// Resource file `Jost ExtraLight.ttf`.
    var jostExtraLightTtf: RswiftResources.FileResource { .init(name: "Jost ExtraLight", pathExtension: "ttf", bundle: bundle, locale: LocaleReference.none) }

    /// Resource file `Jost ExtraLightItalic.ttf`.
    var jostExtraLightItalicTtf: RswiftResources.FileResource { .init(name: "Jost ExtraLightItalic", pathExtension: "ttf", bundle: bundle, locale: LocaleReference.none) }

    /// Resource file `Jost Italic.ttf`.
    var jostItalicTtf: RswiftResources.FileResource { .init(name: "Jost Italic", pathExtension: "ttf", bundle: bundle, locale: LocaleReference.none) }

    /// Resource file `Jost Light.ttf`.
    var jostLightTtf: RswiftResources.FileResource { .init(name: "Jost Light", pathExtension: "ttf", bundle: bundle, locale: LocaleReference.none) }

    /// Resource file `Jost LightItalic.ttf`.
    var jostLightItalicTtf: RswiftResources.FileResource { .init(name: "Jost LightItalic", pathExtension: "ttf", bundle: bundle, locale: LocaleReference.none) }

    /// Resource file `Jost Medium.ttf`.
    var jostMediumTtf: RswiftResources.FileResource { .init(name: "Jost Medium", pathExtension: "ttf", bundle: bundle, locale: LocaleReference.none) }

    /// Resource file `Jost MediumItalic.ttf`.
    var jostMediumItalicTtf: RswiftResources.FileResource { .init(name: "Jost MediumItalic", pathExtension: "ttf", bundle: bundle, locale: LocaleReference.none) }

    /// Resource file `Jost Regular.ttf`.
    var jostRegularTtf: RswiftResources.FileResource { .init(name: "Jost Regular", pathExtension: "ttf", bundle: bundle, locale: LocaleReference.none) }

    /// Resource file `Jost SemiBold.ttf`.
    var jostSemiBoldTtf: RswiftResources.FileResource { .init(name: "Jost SemiBold", pathExtension: "ttf", bundle: bundle, locale: LocaleReference.none) }

    /// Resource file `Jost SemiBoldItalic.ttf`.
    var jostSemiBoldItalicTtf: RswiftResources.FileResource { .init(name: "Jost SemiBoldItalic", pathExtension: "ttf", bundle: bundle, locale: LocaleReference.none) }

    /// Resource file `Jost Thin.ttf`.
    var jostThinTtf: RswiftResources.FileResource { .init(name: "Jost Thin", pathExtension: "ttf", bundle: bundle, locale: LocaleReference.none) }

    /// Resource file `Jost ThinItalic.ttf`.
    var jostThinItalicTtf: RswiftResources.FileResource { .init(name: "Jost ThinItalic", pathExtension: "ttf", bundle: bundle, locale: LocaleReference.none) }
  }

  /// This `_R.storyboard` struct is generated, and contains static references to 1 storyboards.
  struct storyboard {
    let bundle: Foundation.Bundle
    var launchScreen: launchScreen { .init(bundle: bundle) }

    func launchScreen(bundle: Foundation.Bundle) -> launchScreen {
      .init(bundle: bundle)
    }
    func validate() throws {
      try self.launchScreen.validate()
    }


    /// Storyboard `Launch Screen`.
    struct launchScreen: RswiftResources.StoryboardReference, RswiftResources.InitialControllerContainer {
      typealias InitialController = UIKit.UIViewController

      let bundle: Foundation.Bundle

      let name = "Launch Screen"
      func validate() throws {

      }
    }
  }
}