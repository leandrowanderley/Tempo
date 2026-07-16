//
//  ScrollEdgeFadeOverlay.swift
//  Tempo
//
//  Fade sutil no topo da área rolável, logo abaixo do header fixo (.safeAreaInset),
//  pra suavizar a transição em vez de cortar o conteúdo em seco. Aplicar com
//  .overlay(alignment: .top) na ScrollView, ANTES do .safeAreaInset do header
//  (senão o overlay fica alinhado ao topo do header, não da área rolável).
//
//  IMPORTANTE: o fade cobre sempre os primeiros `height` pontos da área rolável,
//  mesmo parada no topo — por isso o conteúdo precisa de .padding(.top, ScrollEdgeFadeOverlay.height)
//  pra o fade cair em espaço vazio no repouso, e não sempre em cima do primeiro card.
//

import SwiftUI

struct ScrollEdgeFadeOverlay: View {
    static let height: CGFloat = 24

    var height: CGFloat = ScrollEdgeFadeOverlay.height

    var body: some View {
        LinearGradient(
            colors: [Color.tempoBackground, Color.tempoBackground.opacity(0)],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: height)
        .allowsHitTesting(false)
    }
}
