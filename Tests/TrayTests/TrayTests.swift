import Testing
@testable import Tray
import SwiftUI

@MainActor
@Test func controllerPushPopAndDismiss() async throws {
    let controller = TrayController()
    #expect(controller.isPresented == false)
    controller.present { Text("Root") }
    #expect(controller.isPresented == true)
    #expect(controller.stack.count == 1)

    controller.push { Text("Next") }
    #expect(controller.stack.count == 2)

    controller.pop()
    #expect(controller.stack.count == 1)

    controller.dismiss()
    #expect(controller.isPresented == false)
    #expect(controller.stack.isEmpty)
}
