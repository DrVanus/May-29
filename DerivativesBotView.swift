//
//  DerivativesBotView.swift
//  CryptoSage
//
//  Created by DM on 5/29/25.
//

import SwiftUI

struct DerivativesBotView: View {
    @StateObject private var viewModel = DerivativesBotViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab Picker
            Picker("", selection: $viewModel.selectedTab) {
                ForEach(DerivativesBotViewModel.BotTab.allCases) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .padding(.top)
            
            // Content
            Group {
                switch viewModel.selectedTab {
                case .chat:
                    DerivativesChatView(viewModel: viewModel)
                case .strategy:
                    DerivativesStrategyConfigView(viewModel: viewModel)
                case .risk:
                    DerivativesRiskAccountsView(viewModel: viewModel)
                }
            }
            
            Spacer()
        }
        .navigationBarTitle("Derivatives Bot", displayMode: .inline)
    }
}

// MARK: - Subviews

struct DerivativesChatView: View {
    @ObservedObject var viewModel: DerivativesBotViewModel
    @State private var messageText: String = ""
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(viewModel.chatMessages) { msg in
                    ChatMessageRow(message: msg)
                }
            }
            
            HStack {
                TextField("Enter your strategy...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Send") {
                    viewModel.sendChatMessage(messageText)
                    messageText = ""
                }
                .padding(.leading, 4)
            }
            .padding()
        }
    }
}

struct DerivativesStrategyConfigView: View {
    @ObservedObject var viewModel: DerivativesBotViewModel
    
    var body: some View {
        Form {
            Section(header: Text("Grid Settings")) {
                TextField("Lower Price", text: $viewModel.lowerPrice)
                    .keyboardType(.decimalPad)
                TextField("Upper Price", text: $viewModel.upperPrice)
                    .keyboardType(.decimalPad)
                TextField("Grid Levels", text: $viewModel.gridLevels)
                    .keyboardType(.numberPad)
                TextField("Order Volume", text: $viewModel.orderVolume)
                    .keyboardType(.decimalPad)
            }
            
            Button("Generate Bot Config") {
                viewModel.generateDerivativesConfig()
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

struct DerivativesRiskAccountsView: View {
    @ObservedObject var viewModel: DerivativesBotViewModel
    
    var body: some View {
        Form {
            Section(header: Text("Exchange & Market")) {
                Picker("Exchange", selection: $viewModel.selectedExchange) {
                    ForEach(viewModel.availableDerivativesExchanges) { ex in
                        Text(ex.name).tag(Optional(ex))
                    }
                }
                Picker("Market", selection: $viewModel.selectedMarket) {
                    ForEach(viewModel.marketsForSelectedExchange) { m in
                        Text(m.title).tag(Optional(m))
                    }
                }
            }
            
            Section(header: Text("Risk Management")) {
                Stepper(value: $viewModel.leverage, in: 1...viewModel.maxLeverage) {
                    Text("Leverage: \(viewModel.leverage)x")
                }
                Toggle("Isolated Margin", isOn: $viewModel.isIsolated)
            }
            
            Section {
                Button(viewModel.isRunning ? "Stop Bot" : "Start Bot") {
                    viewModel.toggleDerivativesBot()
                }
                .foregroundColor(.white)
                .padding()
                .background(viewModel.isRunning ? Color.red : Color.green)
                .cornerRadius(8)
            }
        }
    }
}

// MARK: - Supporting Views

struct ChatMessageRow: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .top) {
            Text(message.sender).bold()
            Text(message.text)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

struct DerivativesBotView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DerivativesBotView()
        }
    }
}
