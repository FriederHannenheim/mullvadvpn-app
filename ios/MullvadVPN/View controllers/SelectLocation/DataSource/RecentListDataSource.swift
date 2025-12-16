//
//  RecentListDataSource.swift
//  MullvadVPN
//
//  Created by Mojgan on 2025-11-18.
//  Copyright © 2025 Mullvad VPN AB. All rights reserved.
//

import Foundation
import MullvadLogging
import MullvadSettings
import MullvadTypes

class RecentListDataSource: LocationDataSourceProtocol {
    private(set) var nodes = [LocationNode]()
    let allLocationDataSource: AllLocationDataSource
    let customListsDataSource: CustomListsDataSource

    init(_ allLocationDataSource: AllLocationDataSource, customListsDataSource: CustomListsDataSource) {
        self.allLocationDataSource = allLocationDataSource
        self.customListsDataSource = customListsDataSource
    }

    func reload(_ recents: [UserSelectedRelays]) {
        nodes = Array(
            recents.compactMap { userSelectedRelays in
                let allLocationNode = allLocationDataSource.node(by: userSelectedRelays)
                guard
                    let node =
                        customListsDataSource.node(by: userSelectedRelays)
                        ?? allLocationNode
                else { return nil }

                return RecentLocationNode(
                    name: node.name,
                    code: node.code,
                    locations: node.locations,
                    isActive: node.isActive,
                    parent: node.root.asCustomListNode,  // Preserve the parent only when the node originates from a custom list
                    children: node.children,
                    showsChildren: false,  // Recents shouldn't be expandable
                    isHiddenFromSearch: true,  // Recents shouldn't be searchable
                    locationInfo: allLocationNode)

            }
            .prefix(3)
        )

    }

    func node(by selectedRelays: UserSelectedRelays) -> LocationNode? {
        nodes.first { node in
            node.userSelectedRelays == selectedRelays
        }
    }
}
