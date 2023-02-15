//
//  Home.swift
//  BedTimeSlider
//
//  Created by Abdullah Karaboğa on 15.02.2023.
//

import SwiftUI

struct Home: View {

    @State var startAngle: Double = 0
    @State var toAngle: Double = 180

    @State var startProgress: CGFloat = 0
    @State var toProgress: CGFloat = 0.5

    var body: some View {

        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today")
                        .font(.title.bold())

                    Text("Good Morning Abdullah Karaboğa")

                }.frame(maxWidth: .infinity, alignment: .leading)
            }

            SleepTimeSlider()
                .padding(.top, 50)

            Button {

            } label: {
                Text("Start Sleep")
                    .foregroundColor(.white)
                    .padding(.vertical)
                    .padding(.horizontal, 40)
                    .background((.blue), in: Capsule())
            }
                .padding(.top, 45)

            HStack(spacing: 25) {

                VStack {
                    Label {
                        Text("Bedtime")
                            .foregroundColor(.black)
                    } icon: {
                        Image(systemName: "moon.fill")
                            .foregroundColor(.blue)
                    }
                        .font(.callout)
                    Text(getTime(angle: startAngle).formatted(date: .omitted, time: .shortened))
                        .font(.title2.bold())
                }
                    .frame(maxWidth: .infinity, alignment: .center)

                VStack {
                    Label {
                        Text("Wakeup")
                            .foregroundColor(.black)
                    } icon: {
                        Image(systemName: "alarm")
                            .foregroundColor(.blue)
                    }
                        .font(.callout)
                    Text(getTime(angle: toAngle).formatted(date: .omitted, time: .shortened))
                        .font(.title2.bold())
                }
                    .frame(maxWidth: .infinity, alignment: .center)

            }
                .padding()
                .background(.black.opacity(0.06), in: RoundedRectangle(cornerRadius: 15))
                .padding(.top, 35)

        }
            .padding()
            .frame(maxHeight: .infinity, alignment: .top)
    }

    @ViewBuilder
    func SleepTimeSlider() -> some View {
        GeometryReader { proxy in

            let width = proxy.size.width

            ZStack {

                ForEach(1...60, id: \.self) { index in
                    Rectangle()
                        .fill(index % 5 == 0 ? .black : .gray)
                        .frame(width: 2, height: index % 5 == 0 ? 10 : 5)
                        .offset(y: (width - 60) / 2)
                        .rotationEffect(.init(degrees: Double(index) * 6))

                    let texts = [6, 9, 12, 3]
                    ForEach(texts.indices, id: \.self) { index in
                        Text("\(texts[index])")
                            .font(.caption.bold())
                            .foregroundColor(.black)
                            .rotationEffect(.init(degrees: Double(index) * -90))
                            .offset(y: (width - 90) / 2)
                            .rotationEffect(.init(degrees: Double(index) * 90))
                    }
                }

                Circle()
                    .stroke(.black.opacity(0.06), lineWidth: 40)

                let reverseRotation = (startProgress > toProgress) ? -Double((1 - startProgress) * 360) : 0

                Circle()
                    .trim(from: startProgress > toProgress ? 0 : startProgress, to: toProgress + (-reverseRotation / 360))
                    .stroke(.blue, style: StrokeStyle(lineWidth: 40, lineCap: .round, lineJoin: .round))
                    .rotationEffect(.init(degrees: -90))
                    .rotationEffect(.init(degrees: reverseRotation))

                Image(systemName: "moon.fill")
                    .font(.callout)
                    .foregroundColor(.blue)
                    .frame(width: 30, height: 30)
                    .rotationEffect(.init(degrees: 90))
                    .rotationEffect(.init(degrees: -startAngle))
                    .background(.white, in: Circle())
                    .offset(x: width / 2)
                    .rotationEffect(.init(degrees: startAngle))
                    .gesture(

                    DragGesture().onChanged({ value in
                        onDrag(value: value, fromSlider: true)
                    })

                ) .rotationEffect(.init(degrees: -90))



                Image(systemName: "alarm")
                    .font(.callout)
                    .foregroundColor(.blue)
                    .frame(width: 30, height: 30)
                    .rotationEffect(.init(degrees: 90))
                    .rotationEffect(.init(degrees: -toAngle))
                    .background(.white, in: Circle())
                    .offset(x: width / 2)
                    .rotationEffect(.init(degrees: toAngle))
                    .gesture(

                    DragGesture().onChanged({ value in
                        onDrag(value: value)
                    })


                ) .rotationEffect(.init(degrees: -90))


                VStack(spacing: 6) {
                    Text("\(getTimeDifference().0) hr")
                        .font(.largeTitle.bold())
                    Text("\(getTimeDifference().1) min")
                        .foregroundColor(.gray)
                }
                    .scaleEffect(1.1)

            }

        }
            .frame(width: screenBounds().width / 1.6, height: screenBounds().width / 1.6)
    }

    func onDrag(value: DragGesture.Value, fromSlider: Bool = false) {

        let vector = CGVector(dx: value.location.x, dy: value.location.y)

        let radians = atan2(vector.dy - 15, vector.dx - 15)

        var angle = radians * 180 / .pi
        if angle < 0 { angle = 360 + angle }

        let progress = angle / 360

        if fromSlider {

            self.startAngle = angle
            self.startProgress = progress

        } else {

            self.toAngle = angle
            self.toProgress = progress
        }

    }

    func getTime (angle: Double) -> Date {

        let progress = angle / 30

        let hour = Int(progress)

        let remainder = (progress.truncatingRemainder(dividingBy: 1) * 12).rounded()

        var minute = remainder * 5
        minute = (minute > 55 ? 55 : minute)

        let formatter = DateFormatter()

        formatter.dateFormat = "hh:mm:ss"

        if let date = formatter.date(from: "\(hour):\(Int(remainder)):00") {
            return date
        }
        return .init()
    }

    func getTimeDifference() -> (Int, Int) {
        let calendar = Calendar.current

        let result = calendar.dateComponents([.hour, .minute], from: getTime(angle: startAngle), to: getTime(angle: toAngle))
        return (result.hour ?? 0, result.minute ?? 0)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}

extension View {
    func screenBounds() -> CGRect {
        return UIScreen.main.bounds
    }
}
