//
//  DexInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/25/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

private enum Constants {
    static let pair = "/v0" + "/pairs"
}

final class DexListInteractor: DexListInteractorProtocol {
   
    private let dexRepository = FactoryRepositories.instance.dexRepository
    private let authorizationInteractor = FactoryInteractors.instance.authorization
    private let disposeBag = DisposeBag()
    private let environmentRepository = FactoryRepositories.instance.environmentRepository
    
    func pairs() -> Observable<[DexList.DTO.Pair]> {
        
        return authorizationInteractor.authorizedWallet().flatMap({ [weak self] (wallet) -> Observable<[DexList.DTO.Pair]> in
            guard let owner = self else { return Observable.empty() }
            
            return Observable.merge([owner.dexRepository.list(by: wallet.wallet.address),
                                     owner.dexRepository.listListener(by: wallet.wallet.address)])
                
                .flatMap({ [weak self] (pairs) -> Observable<[DexList.DTO.Pair]> in
                                        
                    guard let owner = self else { return Observable.empty() }
                    if pairs.count == 0 {
                        return Observable.just([])
                    }
                    else {
                        return owner.environmentRepository.accountEnvironment(accountAddress: wallet.wallet.address).flatMap({ [weak self] (environment) -> Observable<[DexList.DTO.Pair]> in
                            
                            guard let owner = self else { return Observable.empty() }
                            return owner.getList(by: pairs, environment: environment)
                        })
                    }
            })
        })
    }
}

private extension DexListInteractor {
    
    func getList(by pairs: [DexMarket.DTO.Pair], environment: Environment) -> Observable<[DexList.DTO.Pair]> {
        
        return Observable.create({ [weak self] (subscribe) -> Disposable in

            guard let owner = self else { return Disposables.create() }
            let req = owner.getListPairs(by: pairs, environment: environment, complete: { (pairs, error) in
                subscribe.onNext(pairs)
            })
            return Disposables.create {
                req.cancel()
            }
        })
    }
    
    func getListPairs(by pairs: [DexMarket.DTO.Pair], environment: Environment, complete:@escaping(_ pairs: [DexList.DTO.Pair], _ error: ResponseTypeError?) -> Void) -> DataRequest {
        
        var url = environment.servers.dataUrl.relativeString + Constants.pair
        
        for pair in pairs {
            if (url as NSString).range(of: "?").location == NSNotFound {
                url.append("?")
            }
            if url.last != "?" {
                url.append("&")
            }
            url.append("pairs=" + pair.amountAsset.id + "/" + pair.priceAsset.id)
        }
        
        //TODO: need change to Observer network
        return NetworkManager.getRequestWithUrl(url, parameters: nil) { (info, error) in
            
            if let info = info {

                var listPairs: [DexList.DTO.Pair] = []

                for (index, item) in info["data"].arrayValue.enumerated() {
                    
                    let localPair = pairs[index]
                    
                    let amountAsset = Dex.DTO.Asset(id: localPair.amountAsset.id,
                                                    name: localPair.amountAsset.name,
                                                    shortName: localPair.amountAsset.shortName,
                                                    decimals: localPair.amountAsset.decimals)
                    
                    let priceAsset = Dex.DTO.Asset(id: localPair.priceAsset.id,
                                                   name: localPair.priceAsset.name,
                                                   shortName: localPair.priceAsset.shortName,
                                                   decimals: localPair.priceAsset.decimals)
                
                    let info = item["data"]
                    let firstPrice = Money(value: Decimal(info["firstPrice"].doubleValue), amountAsset.decimals)
                    let lastPrice = Money(value: Decimal(info["lastPrice"].doubleValue), amountAsset.decimals)
                    
                    let pair = DexList.DTO.Pair(firstPrice: firstPrice,
                                                lastPrice: lastPrice,
                                                amountAsset: amountAsset,
                                                priceAsset: priceAsset,
                                                isGeneral: localPair.isGeneral,
                                                sortLevel: localPair.sortLevel)
                    listPairs.append(pair)
                }
                
                complete(listPairs, nil)
            }
            else {
                complete([], error)
            }
        }
    }
}
