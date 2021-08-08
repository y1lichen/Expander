//
//  ContentView.swift
//  Expander
//
//  Created by 陳奕利 on 2021/8/8.
//

import SwiftUI

struct ContentView: View {
    @StateObject var model = ExpanderModel()
    var body: some View {
        Text("\(model.text)")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
