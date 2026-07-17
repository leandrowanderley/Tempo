//
//  ProfileIconCatalog.swift
//  Tempo
//
//  Descobre os ícones de perfil disponíveis em Assets.xcassets. Convenção: icon_1,
//  icon_2, icon_3... Para adicionar mais opções, basta soltar um novo imageset
//  seguindo essa numeração sequencial — nenhuma mudança de código é necessária.
//

import UIKit

enum ProfileIconCatalog {
    static let available: [String] = {
        var icons: [String] = []
        var index = 1
        while UIImage(named: "icon_\(index)") != nil {
            icons.append("icon_\(index)")
            index += 1
        }
        return icons
    }()
}
