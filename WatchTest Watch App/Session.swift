//
//  Session.swift
//  WatchTest Watch App
//
//  Created by Landon West on 1/2/24.
//

import SwiftUI

struct Session: View {
    
    @State var sessionTime: Int
    @State var makes = 0
    
    var body: some View {
        
        VStack {
            Text("\(makes)")
                .padding(.top, 15)
                .font(.system(size: 30))
                .fontWeight(.semibold)
            
            Spacer()
            
            Button(action: {
                makes = makes + 1
            }) {
                Image(systemName: "basketball")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 125, height: 165)
                    .fontWeight(.ultraLight)
                
            }
            .edgesIgnoringSafeArea(.all)
            .tint(.green)
            .buttonStyle(.bordered)
               .buttonBorderShape(.roundedRectangle(radius: 40))

            
        }
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    Session(sessionTime: 5)
}
