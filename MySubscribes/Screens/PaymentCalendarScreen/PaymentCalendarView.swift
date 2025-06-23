//
//  PaymentCalendarView.swift
//  MySubscribes
//
//  Created by apple on 22.06.2025.
//

import SwiftUI


struct PaymentCalendarView: View {
    @State private var selectedDate: Date? = nil
    @State private var currentMonth: Date = Date()
    
    let calendar = Calendar.current

    // Example payment dates
    let paymentDates: [Date] = [
        Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 5))!,
        Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 12))!,
        Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 24))!
    ]
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Button("<") {
                    changeMonth(by: -1)
                }
                Spacer()
                Text(monthYearString(from: currentMonth))
                    .font(.headline)
                Spacer()
                Button(">") {
                    changeMonth(by: 1)
                }
            }
            .padding()
            
            // Days of week
            HStack {
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                    Text(day).frame(maxWidth: .infinity)
                }
            }
            
            // Days grid
            LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
                ForEach(daysInMonth(), id: \.self) { date in
                    let day = calendar.component(.day, from: date)
                    let isSelected = calendar.isDate(date, inSameDayAs: selectedDate ?? Date())
                    let isPaymentDate = paymentDates.contains { calendar.isDate($0, inSameDayAs: date) }

                    Text("\(day)")
                        .frame(height: 40)
                        .frame(maxWidth: .infinity)
                        .background(
                            isSelected ? Color.blue.opacity(0.3) :
                            (isPaymentDate ? Color.green.opacity(0.3) : Color.clear)
                        )
                        .clipShape(Circle())
                        .onTapGesture {
                            selectedDate = date
                        }
                }
            }
            Spacer()
        }
        .padding()
    }

    // Helpers

    func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }

    func changeMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newDate
        }
    }

    func daysInMonth() -> [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else {
            return []
        }

        let weekdayOffset = calendar.component(.weekday, from: firstOfMonth) - calendar.firstWeekday
        let offset = weekdayOffset >= 0 ? weekdayOffset : weekdayOffset + 7

        var days: [Date] = []

        for i in 0..<range.count + offset {
            if i < offset {
                days.append(Date.distantPast)
            } else {
                if let date = calendar.date(byAdding: .day, value: i - offset, to: firstOfMonth) {
                    days.append(date)
                }
            }
        }

        return days.filter { $0 != Date.distantPast }
    }
}
#Preview {
    PaymentCalendarView()
}
