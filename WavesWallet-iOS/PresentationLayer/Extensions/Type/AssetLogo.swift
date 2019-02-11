//
//  AssetLogoStyle.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 08.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Kingfisher

enum AssetLogo: String {
    case waves = "waves"
    case usd = "usd"
    case monero = "xmr"
    case litecoin = "ltc"
    case lira = "try"
    case eur = "eur"
    case eth = "eth"
    case dash = "dash"
    case bitcoinCash = "bch"
    case bitcoin = "btc"
    case zcash = "zec"
    case wct = "wavescommunity"
    case bsv = "bsv"
}

extension AssetLogo {
    var image48: UIImage {
        switch self {
        case .waves:
            return Images.logoWaves48.image
        case .usd:
            return Images.logoUsd48.image
        case .monero:
            return Images.logoMonero48.image
        case .litecoin:
            return Images.logoLtc48.image
        case .lira:
            return Images.logoLira48.image
        case .eur:
            return Images.logoEuro48.image
        case .eth:
            return Images.logoEthereum48.image
        case .dash:
            return Images.logoDash48.image
        case .bitcoin:
            return Images.logoBitcoin48.image
        case .bitcoinCash:
            return Images.logoBitcoincash48.image
        case .zcash:
            return Images.logoZec48.image
        case .wct:
            return Images.logoWct48.image
        case .bsv:
            return Images.logoWct48.image
        }
    }
}

//UIFont.systemFont(ofSize: 15)
extension AssetLogo {

    struct Style: Hashable {
        struct Border: Hashable {
            let width: CGFloat
            let color: UIColor
        }

        let size: CGSize
        let font: UIFont
        let border: Border?

        var key: String {
            var key = "\(size.width)_\(size.height)"
            key += "\(font.familyName)_\(font.lineHeight)"

            if let border = border {
                key += "\(border.width)_\(border.color.toHexString())"
            }
            return key
        }
    }

    static func retrieveLogo(url: DomainLayer.DTO.Asset.Icon,
                             style: Style) -> Observable<UIImage?> {

        return Observable.create({ (observer) -> Disposable in

            let cache = ImageCache.default
            let key = "com.wavesplatform.asset.logo.v5.\(url).\(style.key)"

            let workItem = cache.retrieveImage(forKey: key,
                                               options: nil,
                                               completionHandler: { image, _ in
                                                    observer.onNext(image)
            })

            return Disposables.create {
                if workItem?.isCancelled == false {
                    workItem?.cancel()
                }
            }
        })
    }

    static func downloadLogo(path: String) -> Observable<UIImage?> {

        return Observable.create({ (observer) -> Disposable in

            let url = URL(string: path)!
            let downloader = ImageDownloader.default
            let workItem = downloader.downloadImage(with: url,
                                                    retrieveImageTask: nil,
                                                    options: nil,
                                                    progressBlock: nil) { (image, error, url, data) in

                                                        if let data = data, let pic = UIImage(data: data) {
                                                            observer.onNext(pic)
                                                            observer.onCompleted()
                                                        } else {
                                                            observer.onNext(nil)
                                                            observer.onCompleted()
                                                        }
            }

            return Disposables.create {
                workItem?.cancel()
            }
        })
    }

    static func logo(icon: DomainLayer.DTO.Asset.Icon,
                     style: Style) -> Observable<UIImage> {

        return retrieveLogo(url: icon, style: style)
            .flatMap({ (image) -> Observable<UIImage> in
                if let image = image {
                    return Observable.just(image)
                } else {
                    if let url = icon.url {
                        let download = downloadLogo(path: url)
                            .flatMap({ (image) ->  Observable<UIImage> in
                                let image = createLogo(name: icon.name,
                                                       image: image,
                                                       style: style)
                                return Observable.just(image!)
                            })

                        return Observable.merge([localLogo(icon: icon, style: style), download])
                    } else {
                        return localLogo(icon: icon,
                                         style: style)
                    }
                }
            })
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global(qos: .background)))
            .sweetDebug("Test \(arc4random() % 100)")

    }

    static func localLogo(icon: DomainLayer.DTO.Asset.Icon,
                          style: Style) -> Observable<UIImage> {

        return retrieveLogo(url: icon, style: style)
            .flatMap({ (image) -> Observable<UIImage> in
                if let image = image {
                    return Observable.just(image)
                } else {
                    let image = createLogo(name: icon.name,
                                           image: image,
                                           style: style) ?? UIImage()
                    return Observable.just(image)
                }
            })
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global(qos: .background)))
    }

    static func logo(url: DomainLayer.DTO.Asset.Icon,
                     style: Style,
                     completionHandler: @escaping ((UIImage) -> Void)) -> DispatchWorkItem?
    {
        let cache = ImageCache.default
        let key = "com.wavesplatform.asset.logo.v1.\(url).\(style.key)"

//        if let path = url.url {
////            var downloadTask: RetrieveImageDownloadTask = downloadLogo(path: path) { (image) in
////
////            }
//
//
//        } else {
//
//        }

        let workItem = cache.retrieveImage(forKey: key,
                                   options: nil,
                                   completionHandler: { image, _ in
                                    if let image = image {
                                        completionHandler(image)
                                    } else {

//                                        if let image = createLogo(name: url, style: style) {
//                                            cache.store(image, forKey: key)
//                                            completionHandler(image)
//                                        }
                                    }
        })

//        workItem?.notify(queue: DispatchQueue.main, execute: {
//
//        })


        return workItem
    }

//    static func downloadLogo(path: String, completionHandler: ((UIImage?) -> Void)) -> RetrieveImageDownloadTask? {
//
//        let url = URL(string: path)!
//        let downloader = ImageDownloader.default
//        let workItem = downloader.downloadImage(with: url, retrieveImageTask: nil, options: nil, progressBlock: nil) { (image, error, url, data) in
//            completionHandler(image)
//        }
//
//        return workItem
//    }

    static func createLogo(name: String,
                           image: UIImage?,
                           style: Style) -> UIImage? {

        let size = style.size
        let font = style.font

        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.saveGState()

        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context.addPath(UIBezierPath(roundedRect: rect, cornerRadius: rect.height * 0.5).cgPath)
        context.clip()

        if let image = image {

            context.setFillColor(UIColor.white.cgColor)
            context.fill(rect)
            image.draw(in: CGRect(x: 0,
                                  y: 0,
                                  width: size.width,
                                  height: size.height),
                        blendMode: .normal,
                        alpha: 1)
        } else {
            let color = UIColor.colorAsset(name: name)
            context.setFillColor(color.cgColor)
            context.fill(rect)
            if let first = name.first {
                let symbol = String(first).uppercased()
                let style = NSMutableParagraphStyle()
                style.alignment = .center
                let attributedString = NSAttributedString(string: symbol,
                                                          attributes: [.foregroundColor: UIColor.white,
                                                                       .font: font,
                                                                       .paragraphStyle: style])
                let sizeStr = attributedString.size()

                attributedString.draw(with: CGRect(x: (size.width - sizeStr.width) * 0.5,
                                                   y: (size.height - sizeStr.height) * 0.5,
                                                   width: sizeStr.width,
                                                   height: sizeStr.height),
                                      options: [.usesLineFragmentOrigin],
                                      context: nil)
            }
        }

        if let border = style.border {
            context.addArc(center: CGPoint(x: size.width * 0.5, y: size.height * 0.5), radius: size.height * 0.5, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: false)
            context.setLineWidth(border.width)
            context.setStrokeColor(border.color.cgColor)
            context.strokePath()
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return image
    }
}
