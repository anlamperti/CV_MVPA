/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI
import HealthKit

struct BpmChart: View {
    
    var workout: HKWorkout
    let data: [BpmMeasurement] = []
  
  let tempGradient = Gradient(colors: [
    .purple,
    Color(red: 0, green: 0, blue: 139.0/255.0),
    .blue,
    Color(red: 30.0/255.0, green: 144.0/255.0, blue: 1.0),
    Color(red: 0, green: 191/255.0, blue: 1.0),
    Color(red: 135.0/255.0, green: 206.0/255.0, blue: 250.0/255.0),
    .green,
    .yellow,
    .orange,
    Color(red: 1.0, green: 140.0/255.0, blue: 0.0),
    .red,
    Color(red: 139.0/255.0, green: 0.0, blue: 0.0)
  ])
  
  func yHeight(_ height: CGFloat, range: Int) -> CGFloat {
    height / CGFloat(range)
  }
  
  func xHeight(_ width: CGFloat, count: Int) -> CGFloat {
    width / CGFloat(count)
  }
  
  func xOffset(_ date: Date, width: CGFloat) -> CGFloat {
      CGFloat(Calendar.current.ordinality(of: .second, in: .minute, for: date)!) * width
  }
  
  func yOffset(_ value: Double, height: CGFloat) -> CGFloat {
    CGFloat(value + 10) * height
  }
  
  func yLabelOffset(_ line: Int, height: CGFloat) -> CGFloat {
    height - self.yOffset(Double(line * 10), height: self.yHeight(height, range: 110))
  }
  
//  func offsetFirstOfMonth(_ month: Int, width: CGFloat) -> CGFloat {
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "M/d/yyyy"
//    let foM = dateFormatter.date(from: "\(month)/1/2018")!
//    let dayWidth = self.dayWidth(width, count: 365)
//    return self.dayOffset(foM, dWidth: dayWidth)
//  }
  
//  func monthAbbreviationFromInt(_ month: Int) -> String {
//    let ma = Calendar.current.shortMonthSymbols
//    return ma[month - 1]
//  }
  
  
  var body: some View {
    // 1
    GeometryReader { reader in
        
        // BPM Data
        
        ForEach(self.data, id: \.self) { sample in
        // 2
        Path { p in
          // 3
          let dWidth = self.xHeight(reader.size.width, count: 600)
          let dHeight = self.yHeight(reader.size.height, range: 200)
          // 4
          let xOffset = self.xOffset(sample.date, width: dWidth)
          // 5
            let yOffset = self.yOffset(Double(sample.value), height: dHeight)
          // 6
            let center = CGPoint(x: xOffset, y: yOffset)
            p.addArc(center: center, radius: 1, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 360), clockwise: true)
          // 7
        }.stroke(LinearGradient(
          gradient: self.tempGradient,
          startPoint: .init(x: 0.0, y: 1.0),
          endPoint: .init(x: 0.0, y: 0.0)))
      }
      // 1
        
        // Y - BPM Grid Lines
        
      ForEach(-1..<11) { line in
        // 2
        Group {
          Path { path in
            // 3
            let y = self.yLabelOffset(line, height: reader.size.height)
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: reader.size.width, y: y))
            // 4
          }.stroke(line == 0 ? Color.black : Color.gray)
          // 5
          if line >= 0 {
            Text("\(line * 10)")
              .offset(x: 10, y: self.yLabelOffset(line, height: reader.size.height))
          }
        }
      }
        
        // X - Second Grid Lines
        
//      ForEach(1..<13) { month in
//        Group {
//          Path { path in
//            let dOffset = self.offsetFirstOfMonth(month, width: reader.size.width)
//
//            path.move(to: CGPoint(x: dOffset, y: reader.size.height))
//            path.addLine(to: CGPoint(x: dOffset, y: 0))
//          }.stroke(Color.gray)
//          Text("\(self.monthAbbreviationFromInt(month))")
//            .font(.subheadline)
//            .offset(
//              x: self.offsetFirstOfMonth(month, width: reader.size.width) +
//                5 * self.dayWidth(reader.size.width, count: 365),
//              y: reader.size.height - 25.0)
//        }
//      }
    }
  }
}
