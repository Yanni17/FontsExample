//
//  ContentView.swift
//  FontsTutorial
//
//  Created by Ioannis Pechlivanis on 26.02.25.
//

import SwiftUI

struct ContentView: View {
    @State private var isOn = false
    var body: some View {
        VStack(spacing: 20) {
            Text("Dies ist mein Titel")
                .font(Fonts.title)
            Text("dies ist meine caption")
                .font(Fonts.caption)
                .bold()
            
            Button {} label: {
                Text("Login")
            }
            .buttonStyle(CustomButtonStyle())
            
            Toggle("Toggle me", isOn: $isOn)
                .toggleStyle(CustomToggleStyle())
            
        }
        .globalBackground()
    }
}

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(configuration.isPressed ? Color.gray : Color.yellow)
            .foregroundStyle(.black)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.snappy(duration: 0.2), value: configuration.isPressed)
    }
}

struct CustomToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
            
            Spacer()
            
            RoundedRectangle(cornerRadius: 8)
                .fill(configuration.isOn ? Color.blue : Color.gray.opacity(0.3))
                .frame(width: 30, height: 30)
                .overlay(
                    Image(systemName: configuration.isOn ? "checkmark" : "")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .opacity(configuration.isOn ? 1 : 0)
                        .scaleEffect(configuration.isOn ? 1 : 0.5)
                        .animation(.snappy, value: configuration.isOn)
                )
                .onTapGesture {
                    configuration.isOn.toggle()
                }
        }
    }
}

struct GlobalBackground: ViewModifier {
    
    func body(content: Content) -> some View {
        ZStack {
            Color(Color("background")).ignoresSafeArea()
            content
        }
    }
}

extension View {
    func globalBackground() -> some View {
        modifier(GlobalBackground())
    }
}




#Preview {
    ContentView()
}
