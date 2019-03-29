//
//  TransactionCardType.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 04/03/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

enum TransactionCard {

    struct State {

        struct UI {

            enum Action {
                case none
                case update
                case insertRows(rows: [Row], insertIndexPaths: [IndexPath], deleteIndexPaths: [IndexPath])
                case editContact(DomainLayer.DTO.Contact)
            }

            var sections: [Section]
            var action: Action
        }

        struct Core {

            enum ContactMutation {
                case contact(DomainLayer.DTO.Contact)
                case deleted
            }

            let kind: Kind
            var contacts: [String: ContactMutation]
            var showingAllRecipients: Bool
        }

        enum Action {
            case get
        }

        var ui: UI
        var core: Core
    }

    enum Kind {
        case order(DomainLayer.DTO.Dex.MyOrder)
        case transaction(DomainLayer.DTO.SmartTransaction)

        var transaction: DomainLayer.DTO.SmartTransaction? {
            switch self {
            case .transaction(let tx):
                return tx

            default:
                return nil
            }
        }

        var order: DomainLayer.DTO.Dex.MyOrder? {
            switch self {
            case .order(let order):
                return order

            default:
                return nil
            }
        }
    }

    enum Event {
        case viewDidAppear
        case showAllRecipients
        case addContact(contact: DomainLayer.DTO.Contact)
        case editContact(contact: DomainLayer.DTO.Contact)
        case deleteContact(contact: DomainLayer.DTO.Contact)
    }

    struct Section: SectionProtocol {
        var rows: [Row]
    }

    enum Row {
        case general(TransactionCardGeneralCell.Model)
        case address(TransactionCardAddressCell.Model)
        case keyValue(TransactionCardKeyValueCell.Model)
        case keyBalance(TransactionCardKeyBalanceCell.Model)
        case massSentRecipient(TransactionCardMassSentRecipientCell.Model)
        case dashedLine(TransactionCardDashedLineCell.Model)
        case actions(TransactionCardActionsCell.Model)
        case description(TransactionCardDescriptionCell.Model)
        case exchange(TransactionCardExchangeCell.Model)
        case order(TransactionCardOrderCell.Model)
        case assetDetail(TransactionCardAssetDetailCell.Model)
        case showAll(TransactionCardShowAllCell.Model)
        case status(TransactionCardStatusCell.Model)
        case asset(TransactionCardAssetCell.Model)
        case sponsorshipDetail(TransactionCardSponsorshipDetailCell.Model)
    }
}
