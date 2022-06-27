/// Class representing configurations of the [DocumentScanner].
class DocumentScannerOptions {

  /// The duration is seconds to wait before capturing the frame for process.
  final int preparingDuration;

  const DocumentScannerOptions({
    this.preparingDuration = 2,
  });

  Map<String, dynamic> toMap() {
    return {
      "preparingDuration": preparingDuration,
    };
  }
}
