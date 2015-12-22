import Cocoa
import Starscream

struct Toilet {
    var id: String
    var occupied: Bool
}

class StatusMenuController: NSObject {

    @IBOutlet weak var statusMenu: NSMenu!

    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    let occupied = NSImage(named: "occupied")
    let vacant = NSImage(named: "vacant")
    let atmApi: AtmApi = AtmApi(id: "1")

    override func awakeFromNib() {
        let icon = NSImage(named: "statusIcon")
        statusItem.image = icon
        statusItem.menu = statusMenu
        subscribeOn()
    }

    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }

    func subscribeOn() {
        atmApi.subscribeOn(statusUpdated)
    }

    func statusUpdated(toilet: Toilet) {
        if (toilet.occupied) {
            NSLog("toilet on level \(toilet.id) is occupied")
            self.statusItem.image = self.occupied
        } else {
            NSLog("toilet on level \(toilet.id) is vacant")
            self.statusItem.image = self.vacant
        }
    }
}