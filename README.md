BlurHash_Shader
------------

[![Pub Version (including pre-releases)](https://img.shields.io/pub/v/blurhash_shader?include_prereleases)](https://pub.dev/packages/flutter_boring_avatars)

This project is a Flutter implementation of **BlurHash**, an algorithm for encoding images into a compact string representation. It is designed to create a visually appealing low-resolution placeholder for images while they are loading, leveraging the power of shaders to speed up rendering.

## Features

- **Shader Acceleration**: By using fragment shaders, it leverages GPU acceleration for fast image rendering, reducing CPU usage.
- **No Flickering**: The component displays immediately without flickering or delays. (Requires shader preloading)

## Getting Started

### Installation

Add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  blurhash_shader: any # or the latest version on Pub
```

### Usage

To use the `BlurHash` widget in your application, follow these steps:

1. Import the package:

```dart
import 'package:blurhash_shader/blurhash_shader.dart';
```

2. Use the `BlurHash` widget in your Flutter tree:

```dart
BlurHash('LEHLk~WB2yk8pyo0adR*.7kCMdnj')
```

### Preload Shaders (optional)

To preload shaders and avoid flickering during their initial use, call the following method at the start of your application:

```dart
void main() async {
  await BlurHash.loadShader();
  runApp(MyApp());
}
```

### Example

Here is a simple example of how to implement the `BlurHash` widget:

```dart
import 'package:flutter/material.dart';
import 'package:blurhash_shader/blurhash_shader.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('BlurHash Example')),
        body: Center(
          child: SizedBox(
            width: 300,
            height: 300,
            child: BlurHash('LEHLk~WB2yk8pyo0adR*.7kCMdnj'),
          ),
        ),
      ),
    );
  }
}
```

### Contributing

Contributions are welcome! If you have suggestions or improvements, please fork the repository and submit a pull request.

### License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

### Acknowledgments

- [BlurHash](https://blurha.sh/) for the original algorithm.
- [flutter_blurhash](https://pub.dev/packages/flutter_blurhash) for the initial implementation.
- Flutter community for their continuous support and contributions.
