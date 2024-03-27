//
//  LongPressButton.swift
//  LongPressButton
//
//  Created by 김건우 on 3/27/24.
//

import SwiftUI

struct LongPressButton: View {
    
    // MARK: - Wrapper Properties
    @State private var timer = Timer.publish(every: 0.01, on: .current, in: .common).autoconnect()
    @State private var count: CGFloat = 0
    @State private var progress: CGFloat = 0
    
    @State private var isHolding: Bool = false
    @State private var isFinished: Bool = false
    
    // MARK: - Properties
    var text: String
    var duration: CGFloat
    var tintColor: Color
    var loadingTintColor: Color
    var holdingScale: CGFloat
    var shape: AnyShape
    var verticalPadding: CGFloat
    var horizontalPadding: CGFloat
    var action: () -> ()
    
    // MARK: - Intializer
    init(
        text: String,
        duration: CGFloat = 1,
        tintColor: Color,
        loadingTintColor: Color,
        holdingScale: CGFloat = 0.95,
        shape: AnyShape = .init(.capsule),
        verticalPadding: CGFloat = 10,
        horizontalPadding: CGFloat = 20,
        action: @escaping () -> Void
    ) {
        self.text = text
        self.duration = duration
        self.tintColor = tintColor
        self.loadingTintColor = loadingTintColor
        self.holdingScale = holdingScale
        self.shape = shape
        self.verticalPadding = verticalPadding
        self.horizontalPadding = horizontalPadding
        self.action = action
    }
    
    // MARK: - Body
    var body: some View {
        Text(text)
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)
            .background {
                ZStack(alignment: .leading) {
                    GeometryReader { geometry in
                        let size = geometry.size
                        
                        Rectangle()
                            .fill(tintColor.gradient)
                        
                        Rectangle()
                            .fill(loadingTintColor)
                            .frame(width: size.width * progress)
                    }
                }
            }
            .clipShape(shape)
            .contentShape(shape)
            .scaleEffect(isHolding ? holdingScale : 1)
            .animation(.snappy, value: isHolding)
            // 롱-프레스 제스처 추가
            .gesture(longPressGesture)
            // 드래그 제스처 추가
            // ⭐️ SimultenousGesture가 아닌 연달아 gesture를 추가하는 이유는 제스처를 순서대로 처리해야 되기 때문임
            .gesture(dragGesture)
            // ⭐️ Combine - 매 시간 주기에 따라 클로저를 실행함
            .onReceive(timer) { _ in
                // 버튼 누른 시간이 1초 경과하지 않으면
                if isHolding, progress < 1 {
                    // count값 증가, loadingRectangle Width 비율 수정
                    count += 0.01
                    progress = max(min(count / duration, 1), 0)
                }
            }
            .onAppear {
                // 버튼이 나타나면 Timer 중지시킴
                cancelTimer()
            }
    }
    
    // MARK: - Gesture
    var longPressGesture: some Gesture {
        // 1초 동안 롱-프레스 제스처 구현
        LongPressGesture(minimumDuration: duration)
            // ⭐️ 제스처의 상태가 바뀌는 걸 감지함
            // 클릭하면 매개변수가 true인 클로저가 실행됨
            .onChanged { holding in
                startTimer() // 타이머 시작
                isHolding = holding
            }
            // 1초 동안 롱-프레스를 하고나면 클로저가 실행됨
            .onEnded { finished in
                isFinished = finished // 상태값 갱신

                resetButton() // 버튼 리셋
                cancelTimer() // 타이머 취소
                action() // 버튼 액션 실행
            }
    }
    
    var dragGesture: some Gesture {
        // 드래그 제스처 구현
        DragGesture(minimumDistance: 0)
            .onEnded { _ in
                // 롱-프레스가 완료되었다면
                guard !isFinished else { return } // 실행하지 않음

                resetButton() // 버튼 리셋
                cancelTimer() // 타이머 취소
            }
    }
    
    // MARK: - Timer
    private func startTimer() {
        timer = Timer.publish(every: 0.01, on: .current, in: .common)
            .autoconnect()
    }
    
    private func cancelTimer() {
        timer.upstream
            .connect()
            .cancel()
    }
    
    // MARK: - Helper
    private func resetButton() {
        count = .zero
        progress = .zero
        
        isHolding = false
        isFinished = false
    }
}

// MARK: - Preview
#Preview {
    LongPressButton(
        text: "Hold to Increase",
        tintColor: Color.black,
        loadingTintColor: Color.white.opacity(0.3),
        verticalPadding: 10,
        horizontalPadding: 10
    ) {
        print("Press Button!")
    }
}
