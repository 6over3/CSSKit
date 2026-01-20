// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

/// A CSS `<image>` value.
/// https://www.w3.org/TR/css-images-4/#image-values
public enum CSSImage: Equatable, Sendable, Hashable {
    /// A URL reference to an image.
    case url(CSSUrl)

    /// A gradient.
    case gradient(CSSGradient)

    /// An image-set().
    case imageSet(CSSImageSet)

    /// A cross-fade().
    case crossFade(CSSCrossFade)

    /// The element() function for rendering another element as an image.
    case element(String)

    /// The none value.
    case none
}

// MARK: - CSSImageSet

/// An image-set() value for resolution-based image selection.
/// https://www.w3.org/TR/css-images-4/#image-set-notation
public struct CSSImageSet: Equatable, Sendable, Hashable {
    /// The image options in the set.
    public let options: [CSSImageSetOption]

    /// Creates an image set.
    public init(options: [CSSImageSetOption]) {
        self.options = options
    }
}

/// An option within an image-set().
public struct CSSImageSetOption: Equatable, Sendable, Hashable {
    /// The image (URL or gradient).
    public let image: CSSImageSetImage

    /// The resolution (optional, e.g., 2x or 300dpi).
    public let resolution: CSSResolution?

    /// The MIME type hint (optional).
    public let type: String?

    /// Creates an image set option.
    public init(image: CSSImageSetImage, resolution: CSSResolution? = nil, type: String? = nil) {
        self.image = image
        self.resolution = resolution
        self.type = type
    }
}

/// The image part of an image-set option.
public enum CSSImageSetImage: Equatable, Sendable, Hashable {
    /// A URL reference.
    case url(CSSUrl)
    /// A string (which is treated as a URL).
    case string(CSSString)
    /// A gradient.
    case gradient(CSSGradient)
}

// MARK: - CSSCrossFade

/// A cross-fade() value for blending images.
/// https://www.w3.org/TR/css-images-4/#cross-fade-function
public struct CSSCrossFade: Equatable, Sendable, Hashable {
    /// The images to blend with their percentages.
    public let arguments: [CSSCrossFadeArgument]

    /// Creates a cross-fade.
    public init(arguments: [CSSCrossFadeArgument]) {
        self.arguments = arguments
    }
}

/// An argument to cross-fade().
public struct CSSCrossFadeArgument: Equatable, Sendable, Hashable {
    /// The percentage (optional, auto-calculated if omitted).
    public let percentage: CSSPercentage?

    /// The image.
    public let image: CSSCrossFadeImage

    /// Creates a cross-fade argument.
    public init(percentage: CSSPercentage? = nil, image: CSSCrossFadeImage) {
        self.percentage = percentage
        self.image = image
    }
}

/// The image part of a cross-fade argument.
public enum CSSCrossFadeImage: Equatable, Sendable, Hashable {
    /// A URL reference.
    case url(CSSUrl)
    /// A gradient.
    case gradient(CSSGradient)
    /// A color.
    case color(Color)
}

// MARK: - Parsing

extension CSSImage {
    /// Parses an `<image>` value.
    static func parse(_ input: Parser) -> Result<CSSImage, BasicParseError> {
        // Try none
        if input.tryParse({ $0.expectIdentMatching("none") }).isOK {
            return .success(.none)
        }

        let location = input.currentSourceLocation()
        let state = input.state()

        // Try URL first
        if case let .success(url) = CSSUrl.parse(input) {
            return .success(.url(url))
        }

        input.reset(state)

        // Try gradient
        if case let .success(gradient) = CSSGradient.parse(input) {
            return .success(.gradient(gradient))
        }

        input.reset(state)

        // Try image-set
        if case let .success(token) = input.next() {
            if case let .function(name) = token {
                let funcName = name.value.lowercased()

                if funcName == "image-set" || funcName == "-webkit-image-set" {
                    let result: Result<CSSImageSet, ParseError<Never>> = input.parseNestedBlock { args in
                        CSSImageSet.parse(args).mapError { $0.asParseError() }
                    }
                    switch result {
                    case let .success(imageSet):
                        return .success(.imageSet(imageSet))
                    case let .failure(error):
                        return .failure(error.basic)
                    }
                }

                if funcName == "cross-fade" || funcName == "-webkit-cross-fade" {
                    let result: Result<CSSCrossFade, ParseError<Never>> = input.parseNestedBlock { args in
                        CSSCrossFade.parse(args).mapError { $0.asParseError() }
                    }
                    switch result {
                    case let .success(crossFade):
                        return .success(.crossFade(crossFade))
                    case let .failure(error):
                        return .failure(error.basic)
                    }
                }

                if funcName == "element" || funcName == "-moz-element" {
                    let result: Result<String, ParseError<Never>> = input.parseNestedBlock { args in
                        args.expectIdent().map(\.value).mapError { $0.asParseError() }
                    }
                    switch result {
                    case let .success(id):
                        return .success(.element(id))
                    case let .failure(error):
                        return .failure(error.basic)
                    }
                }
            }
        }

        return .failure(location.newBasicError(.endOfInput))
    }
}

extension CSSImageSet {
    static func parse(_ input: Parser) -> Result<CSSImageSet, BasicParseError> {
        var options: [CSSImageSetOption] = []

        while !input.isExhausted {
            // Parse image
            let image: CSSImageSetImage

            if case let .success(url) = CSSUrl.parse(input) {
                image = .url(url)
            } else if case let .success(str) = CSSString.parse(input) {
                image = .string(str)
            } else if case let .success(gradient) = CSSGradient.parse(input) {
                image = .gradient(gradient)
            } else {
                break
            }

            // Parse resolution
            var resolution: CSSResolution?
            if case let .success(res) = CSSResolution.parse(input) {
                resolution = res
            }

            // Parse type()
            var mimeType: String?
            if input.tryParse({ $0.expectFunctionMatching("type") }).isOK {
                let typeResult: Result<String, ParseError<Never>> = input.parseNestedBlock { args in
                    args.expectString().map(\.value).mapError { $0.asParseError() }
                }
                if case let .success(t) = typeResult {
                    mimeType = t
                }
            }

            options.append(CSSImageSetOption(image: image, resolution: resolution, type: mimeType))

            // Try comma for next option
            if input.tryParse({ $0.expectComma() }).isOK {
                continue
            }
            break
        }

        if options.isEmpty {
            return .failure(input.newBasicError(.endOfInput))
        }

        return .success(CSSImageSet(options: options))
    }
}

extension CSSCrossFade {
    static func parse(_ input: Parser) -> Result<CSSCrossFade, BasicParseError> {
        var arguments: [CSSCrossFadeArgument] = []

        while !input.isExhausted {
            // Parse optional percentage first
            var percentage: CSSPercentage?
            if case let .success(pct) = CSSPercentage.parse(input) {
                percentage = pct
            }

            // Parse image
            let image: CSSCrossFadeImage

            if case let .success(color) = Color.parse(input) {
                image = .color(color)
            } else if case let .success(url) = CSSUrl.parse(input) {
                image = .url(url)
            } else if case let .success(gradient) = CSSGradient.parse(input) {
                image = .gradient(gradient)
            } else {
                // If we got percentage but no image, break
                break
            }

            arguments.append(CSSCrossFadeArgument(percentage: percentage, image: image))

            // Try comma for next argument
            if input.tryParse({ $0.expectComma() }).isOK {
                continue
            }
            break
        }

        if arguments.isEmpty {
            return .failure(input.newBasicError(.endOfInput))
        }

        return .success(CSSCrossFade(arguments: arguments))
    }
}

// MARK: - ToCss

extension CSSImage: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .url(url):
            url.serialize(dest: &dest)
        case let .gradient(gradient):
            gradient.serialize(dest: &dest)
        case let .imageSet(imageSet):
            imageSet.serialize(dest: &dest)
        case let .crossFade(crossFade):
            crossFade.serialize(dest: &dest)
        case let .element(id):
            dest.write("element(#")
            serializeIdentifier(id, dest: &dest)
            dest.write(")")
        case .none:
            dest.write("none")
        }
    }
}

extension CSSImageSet: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write("image-set(")
        for (i, option) in options.enumerated() {
            if i > 0 { dest.write(", ") }
            option.serialize(dest: &dest)
        }
        dest.write(")")
    }
}

extension CSSImageSetOption: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        image.serialize(dest: &dest)
        if let res = resolution {
            dest.write(" ")
            res.serialize(dest: &dest)
        }
        if let type {
            dest.write(" type(\"")
            dest.write(type)
            dest.write("\")")
        }
    }
}

extension CSSImageSetImage: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .url(url):
            url.serialize(dest: &dest)
        case let .string(str):
            str.serialize(dest: &dest)
        case let .gradient(gradient):
            gradient.serialize(dest: &dest)
        }
    }
}

extension CSSCrossFade: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        dest.write("cross-fade(")
        for (i, arg) in arguments.enumerated() {
            if i > 0 { dest.write(", ") }
            arg.serialize(dest: &dest)
        }
        dest.write(")")
    }
}

extension CSSCrossFadeArgument: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        if let pct = percentage {
            pct.serialize(dest: &dest)
            dest.write(" ")
        }
        image.serialize(dest: &dest)
    }
}

extension CSSCrossFadeImage: CSSSerializable {
    public func serialize(dest: inout some CSSWriter) {
        switch self {
        case let .url(url):
            url.serialize(dest: &dest)
        case let .gradient(gradient):
            gradient.serialize(dest: &dest)
        case let .color(color):
            color.serialize(dest: &dest)
        }
    }
}
