# Build and Run Instructions

## 🚀 **Quick Start**

### **Prerequisites**

- **Xcode**: 15.0 or later
- **Swift**: 6.1 or later
- **iOS**: 17.0+ (for SwiftData support)
- **macOS**: 14.0+ (for development)

### **1. Clone the Repository**

```bash
git clone https://github.com/manozghale/shopping-list-module.git
cd shopping-list-module
```

### **2. Open in Xcode**

```bash
open Package.swift
```

### **3. Build the Project**

```bash
swift build
```

### **4. Run Tests**

```bash
swift test
```

## 📱 **Running on iOS Simulator**

### **Option 1: Using Xcode**

1. Open `Package.swift` in Xcode
2. Select a target device (iPhone 15, iPad, etc.)
3. Press `Cmd + R` to build and run
4. The module will run in the simulator

### **Option 2: Using Swift Package Manager**

```bash
# Build for iOS
swift build -Xswiftc -target -Xswiftc arm64-apple-ios17.0

# Run tests on iOS
swift test -Xswiftc -target -Xswiftc arm64-apple-ios17.0
```

## 🧪 **Testing Instructions**

### **Run All Tests**

```bash
swift test
```

### **Run Specific Test Categories**

```bash
# Model tests only
swift test --filter ModelTests

# ViewModel tests only
swift test --filter ViewModelTests

# Repository tests only
swift test --filter RepositoryTests

# Integration tests only
swift test --filter IntegrationTests

# UI tests only
swift test --filter UIIntegrationTests
```

### **Run Tests with Verbose Output**

```bash
swift test --verbose
```

### **Run Tests with Coverage**

```bash
swift test --enable-code-coverage
```

## 🔧 **Development Setup**

### **1. Install Dependencies**

The project has no external dependencies, but you may want to install development tools:

```bash
# Install SwiftLint (optional)
brew install swiftlint

# Install XcodeGen (optional)
brew install xcodegen
```

### **2. Configure Development Environment**

```bash
# Set up git hooks (if available)
git config core.hooksPath .githooks

# Install pre-commit hooks
pre-commit install
```

### **3. Code Quality Checks**

```bash
# Run SwiftLint (if installed)
swiftlint lint

# Run SwiftLint with autocorrect
swiftlint lint --fix
```

## 📦 **Integration Instructions**

### **SwiftUI Integration**

```swift
import SwiftUI
import ShoppingListModule

struct ContentView: View {
    var body: some View {
        NavigationView {
            ShoppingListModule.createView()
        }
    }
}
```

### **UIKit Integration**

```swift
import UIKit
import ShoppingListModule

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        Task {
            let shoppingListVC = try await ShoppingListModule.createViewController()
            addChild(shoppingListVC)
            view.addSubview(shoppingListVC.view)
            shoppingListVC.didMove(toParent: self)
        }
    }
}
```

## 🏗 **Build Configurations**

### **Debug Build**

```bash
swift build -c debug
```

### **Release Build**

```bash
swift build -c release
```

### **Build for Specific Platform**

```bash
# iOS
swift build -Xswiftc -target -Xswiftc arm64-apple-ios17.0

# macOS
swift build -Xswiftc -target -Xswiftc arm64-apple-macos14.0

# iOS Simulator
swift build -Xswiftc -target -Xswiftc x86_64-apple-ios17.0-simulator
```

## 🔍 **Troubleshooting**

### **Common Build Issues**

#### **1. Swift Version Issues**

```bash
# Check Swift version
swift --version

# Should be 6.1 or later
```

#### **2. Xcode Version Issues**

```bash
# Check Xcode version
xcodebuild -version

# Should be 15.0 or later
```

#### **3. iOS Deployment Target**

If you get deployment target errors:

```bash
# Build with specific deployment target
swift build -Xswiftc -target -Xswiftc arm64-apple-ios17.0
```

#### **4. SwiftData Issues**

If SwiftData is not found:

- Ensure iOS 17.0+ deployment target
- Check that SwiftData is imported in your project
- Verify Xcode 15.0+ is being used

### **Test Issues**

#### **1. Test Failures**

```bash
# Run tests with detailed output
swift test --verbose

# Run specific failing test
swift test --filter TestName
```

#### **2. Mock Data Issues**

```bash
# Clear test data
swift test --filter MockDataTests
```

## 📊 **Performance Testing**

### **Memory Profiling**

```bash
# Build with profiling
swift build -c release

# Run with Instruments
instruments -t Allocations -D trace.trace ./path/to/binary
```

### **Performance Benchmarks**

```bash
# Run performance tests
swift test --filter PerformanceTests
```

## 🚀 **Deployment**

### **Archive for App Store**

1. Open project in Xcode
2. Select "Any iOS Device" as target
3. Product → Archive
4. Follow App Store Connect instructions

### **Create Framework**

```bash
# Build framework
swift build -c release

# The framework will be in .build/release/
```

## 📋 **Environment Variables**

### **Development**

```bash
export SHOPPING_LIST_ENV=development
export SHOPPING_LIST_API_URL=http://localhost:8080
export SHOPPING_LIST_ENABLE_LOGGING=true
```

### **Production**

```bash
export SHOPPING_LIST_ENV=production
export SHOPPING_LIST_API_URL=https://api.yourdomain.com
export SHOPPING_LIST_ENABLE_LOGGING=false
```

## 🔧 **Configuration**

### **ShoppingListConfiguration**

```swift
let configuration = ShoppingListConfiguration(
    apiBaseURL: URL(string: "https://your-api.com"),
    enableBackgroundSync: true,
    maxRetries: 3,
    isTestMode: false
)
```

### **Environment-Specific Configurations**

```swift
// Development
let devConfig = ShoppingListConfiguration.development

// Production
let prodConfig = ShoppingListConfiguration.production

// Testing
let testConfig = ShoppingListConfiguration.testing
```

## 📱 **Platform Support**

### **iOS**

- **Minimum**: iOS 17.0
- **Recommended**: iOS 17.0+
- **Features**: Full feature set with SwiftData

### **macOS**

- **Minimum**: macOS 14.0
- **Recommended**: macOS 14.0+
- **Features**: Full feature set (development/testing)

### **iPadOS**

- **Minimum**: iPadOS 17.0
- **Features**: Full feature set with adaptive UI

## 🔄 **Continuous Integration**

### **GitHub Actions Example**

```yaml
name: Build and Test

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build
        run: swift build
      - name: Test
        run: swift test
```

### **Local CI**

```bash
#!/bin/bash
# ci.sh
set -e

echo "Building project..."
swift build

echo "Running tests..."
swift test

echo "Running linting..."
swiftlint lint

echo "All checks passed!"
```

## 📚 **Additional Resources**

### **Documentation**

- [API Documentation](API_DOCUMENTATION.md)
- [Architecture Guide](DESIGN_DOC.md)
- [Testing Guide](TESTING_GUIDE.md)

### **Examples**

- [Basic Integration](examples/BasicIntegration.swift)
- [Advanced Usage](examples/AdvancedUsage.swift)
- [Custom UI](examples/CustomUI.swift)

### **Support**

- [GitHub Issues](https://github.com/manozghale/shopping-list-module/issues)
- [Documentation Wiki](https://github.com/manozghale/shopping-list-module/wiki)
- [Community Discussions](https://github.com/manozghale/shopping-list-module/discussions)

---

**Need help?** Check the [troubleshooting section](#troubleshooting) or open an issue on GitHub.
