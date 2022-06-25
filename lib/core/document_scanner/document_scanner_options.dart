class DocumentScannerOptions {
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
