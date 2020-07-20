//
//  TestView.swift
//  ARWatch
//
//  Created by Hannes Steiner on 20.07.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import SwiftUI

struct TestView: View {
    @State private var textToShow = "Hello AR"
    @State private var showTransaktions = false
    @State private var alert = false
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                RoundedRectangle(cornerRadius: 0)
                    .foregroundColor(.white)
                //                    .fill(LinearGradient(gradient: Gradient(colors: [Color.red, Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                //                    .edgesIgnoringSafeArea(.all)
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("VISA Karte")
                            .font(.largeTitle)
                            .bold()
                        Text("ING DiBa")
                            .font(.callout)
                        Divider()
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .bottom, spacing: 0) {
                                ForEach(0..<30, id: \.self ) { index in
                                    Rectangle().frame(minWidth: 1, maxWidth: 30, minHeight: 30, maxHeight: CGFloat.random(in:30...100))
                                        .padding(.all, 2)
                                        .foregroundColor(.orange)
                                }
                            }
                        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 110, maxHeight: 110)
                        
                        Divider()
                        Button(action: {
                            self.showTransaktions.toggle()
                        }) {
                            HStack(alignment: .center, spacing: 0) {
                                Text("Letzte Transaktionen anzeigen")
                                Spacer()
                                Image(systemName: "arrow.right.arrow.left.square")
                            }.foregroundColor(.accentColor)
                        }
                        if self.showTransaktions {
                            VStack(alignment: .leading, spacing: 3) {
                                HStack(alignment: .center, spacing: 0) {
                                    Text("LIDL")
                                    Spacer()
                                    Text("-12,98€").foregroundColor(.red)
                                }
                                Text("25. Mai 2020")
                                    .font(.footnote)
                                    .foregroundColor(.black).opacity(0.8)
                                Divider()
                            }
                            VStack(alignment: .leading, spacing: 3) {
                                HStack(alignment: .center, spacing: 0) {
                                    Text("Arbeit")
                                    Spacer()
                                    Text("+200,45€")
                                        .foregroundColor(.green)
                                }
                                Text("25. Mai 2020").font(.footnote)
                                    .foregroundColor(.black).opacity(0.8)
                                Divider()
                            }
                            VStack(alignment: .leading, spacing: 3) {
                                HStack(alignment: .center, spacing: 0) {
                                    Text("ALDI")
                                    Spacer()
                                    Text("-32,06€").foregroundColor(.red)
                                }
                                Text("24. Mai 2020").font(.footnote)
                                    .foregroundColor(.black).opacity(0.8)
                                Divider()
                            }
                            VStack(alignment: .leading, spacing: 3) {
                                HStack(alignment: .center, spacing: 0) {
                                    Text("Amazon")
                                    Spacer()
                                    Text("-9,99€").foregroundColor(.red)
                                }
                                Text("23. Mai 2020").font(.footnote)
                                    .foregroundColor(.black).opacity(0.8)
                                Divider()
                            }
                            VStack(alignment: .leading, spacing: 3) {
                                HStack(alignment: .center, spacing: 0) {
                                    Text("DM")
                                    Spacer()
                                    Text("-1,20€").foregroundColor(.red)
                                }
                                Text("20. Mai 2020").font(.footnote)
                                    .foregroundColor(.black).opacity(0.8)
                                Divider()
                            }
                        }
                        Button(action: {
                            self.textToShow = "Karte wird gelöscht löschen..."
                        }) {
                            VStack(alignment: .leading, spacing: 0) {
                                HStack(alignment: .center, spacing: 0) {
                                    Text("Löschen")
                                    Spacer()
                                    Image(systemName: "trash")
                                }.foregroundColor(.red)
                                if self.textToShow == "Karte wird gelöscht löschen..." {
                                    Text(self.textToShow)
                                }
                            }
                        }
                        Divider()
                    }.padding(.horizontal, 5)
                }
            }.frame(width: proxy.size.width/3, height: proxy.size.width/3, alignment: .top)
                .offset(x: proxy.size.width/3, y: -20)
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
            .previewLayout(.fixed(width: 900, height: 900))
    }
}
