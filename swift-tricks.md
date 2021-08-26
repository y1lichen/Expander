SwiftUI is an powerful framework for creating ios mobile app,
However, its customisation isn't mature enough for developers to
create an fully functional macos desktop application.
Although Apple had improved a lot of functionalities for SwiftUI,
most of them currently only support newer macos system (Big Sur+).


### - embed AppKit in SwiftUI

> using "NSViewControllerRepresentable"

struct XXXiew: NSViewControllerRepresentable {
	func makeNSViewController(context: Context) -> some NSViewController {
		return XXXContoller()
	}
	func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {
	}
}

> create a viewcontroller as usual

class XXXContoller: NSViewController {
}

### - create navigation toolbar for SwiftUI lifecycle app (support macos 10.15+)

[how I create toolbar](./Expander/View/ToolBar.swift)

### key-press detecting

=> add global observer and get keycode by using NSEvent.keyCode
NOTE: Both NSEvent or CGEvent can't detect the input of secure textfield.
