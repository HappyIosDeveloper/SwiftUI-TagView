//
//  TagView.swift
//  EventApp
//
//  Created by Ahmadreza on 10/15/21.
//  Copyright © 2021 Alexani. All rights reserved.
//

import SwiftUI

struct TagViewItem: Hashable {
    
    var title: String
    var isSelected: Bool
    
    static func == (lhs: TagViewItem, rhs: TagViewItem) -> Bool {
        return lhs.isSelected == rhs.isSelected
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(isSelected)
    }
}

struct TagView: View {
    @State var tags: [TagViewItem]
    @State private var totalHeight = CGFloat.zero       // << variant for ScrollView/List //    = CGFloat.infinity   // << variant for VStack
    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(height: totalHeight)// << variant for ScrollView/List
        //.frame(maxHeight: totalHeight) // << variant for VStack
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        return ZStack(alignment: .topLeading) {
            ForEach(tags.indices) { index in
                item(for: tags[index].title, isSelected: tags[index].isSelected)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width) {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if tags[index].title == self.tags.last!.title {
                            width = 0 //last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {d in
                        let result = height
                        if tags[index].title == self.tags.last!.title {
                            height = 0 // last item
                        }
                        return result
                    }).onTapGesture {
                        tags[index].isSelected.toggle()
                    }
            }
        }.background(viewHeightReader($totalHeight))
    }

    private func item(for text: String, isSelected: Bool) -> some View {
        Text(text)
            .foregroundColor(isSelected ? Colors.primaryBarBackground : Colors.textColor)
            .padding()
            .lineLimit(1)
            .background(isSelected ? Colors.primaryBlue : Colors.primaryBarBackground)
            .frame(height: 36)
            .cornerRadius(18)
            .overlay(Capsule().stroke(Colors.primaryBlue, lineWidth: 1))
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}
