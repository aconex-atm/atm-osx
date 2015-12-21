import Cocoa


struct Toilet {
    var id: String
    var occupied: Bool
}
class StatusMenuController: NSObject{
    
    @IBOutlet weak var statusMenu: NSMenu!
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    let occupied = NSImage(named: "occupied")
    let vacant = NSImage(named: "vacant")
    let atmApi: AtmApi = AtmApi()
    
    override func awakeFromNib() {
        let icon = NSImage(named: "statusIcon")
        statusItem.image = icon
        statusItem.menu = statusMenu
        updateStatus()
        
        let refreshTimer = NSTimer(timeInterval: 1.0, target: self, selector: "updateStatus", userInfo: nil, repeats: true)
        
        NSRunLoop.mainRunLoop().addTimer(refreshTimer, forMode:NSRunLoopCommonModes)
    }

    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }
    
    func updateStatus() {
        atmApi.fetchStatus("1") { toilet in

            if(toilet.occupied) {
                NSLog("toilet on level \(toilet.id) is occupied")
                self.statusItem.image = self.occupied
            } else {
                NSLog("toilet on level \(toilet.id) is vacant")
                self.statusItem.image = self.vacant
            }
        }
    }
}