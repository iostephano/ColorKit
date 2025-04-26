# ColorKit – Extract Dominant Colors from Images

**ColorKit** is an iOS application that allows users to **extract the most dominant colors** from any image in their photo library or camera, and view them in an intuitive palette with options for **HEX** or **RGB** formats.

## Key Features

- **Extract dominant colors**: Load an image from the gallery or camera and get a color palette automatically.
- **Toggle between HEX and RGB formats**: Instantly switch how colors are displayed.
- **Optimized color detection**: Prioritizes visible, distinct, and dominant tones.
- **Reset functionality**: Clear the current image and palette with a simple tap on the "X" button.
- **Beautiful dark-themed interface**: Clean and modern look, optimized for dark mode.

## Installation

Follow these steps to clone and run the project in your development environment:

1. Clone the repository:
    
    ```bash
    git clone https://github.com/your_username/colorkit.git
    ```
    
2. Open the project in **Xcode**.
3. Make sure you are using **iOS 14+** and **Swift 5**.
4. Run the app on a simulator or a real device.

## Code Structure

```bash
📂 ColorKit
├── 📂 ColorKit
│   ├── AppDelegate.swift              # App setup
│   ├── SceneDelegate.swift            # Window and root controller setup
│   ├── ViewController.swift           # Main screen: image selection and palette display
│   ├── ColorExtractor.swift           # Logic for extracting dominant colors
│   ├── ColorPaletteView.swift         # Custom view for showing color circles and codes
├── 📂 Assets.xcassets                  # App icons and assets
├── 📂 LaunchScreen.storyboard          # Launch screen
├── Info.plist                         # App configuration
```

## Technologies Used

- **Swift**
- **UIKit** – For building the user interface and handling interactions
- **UIImagePickerController** – For selecting images from gallery or camera
- **Core Graphics** – For optimized pixel data analysis
- **Auto Layout** – For responsive and adaptable UI design

## Project Goal

ColorKit is designed for **artists, designers, and developers** who need a fast and easy way to **extract meaningful color palettes** from any image. It is ideal for branding, UI inspiration, and digital art workflows.

## License

This project is licensed under the **MIT License**.
