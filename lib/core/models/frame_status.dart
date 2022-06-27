/// Enum indicating the status of a frame coming from the device's camera.
enum FrameStatus {
  /// The camera is currently initializing.
  INITIALIZING,

  /// The camera is preparing to capture the frame.
  PREPARING,

  /// The camera is currently processing the frame.
  PROCESSING,

  /// There is no document found inside the frame.
  DOCUMENT_NOT_FOUND,

  /// There is a document found in the frame.
  DOCUMENT_FOUND,

  /// The size of the document is too large within the frame.
  DOCUMENT_TOO_BIG,

  /// The size of the document is too small within the frame.
  DOCUMENT_TOO_SMALL,

  /// The document is not in the center of frame.
  DOCUMENT_NOT_IN_CENTER,

  /// The processor cannot grab face from the document.
  CANNOT_GRAB_DOCUMENT,

  /// There is no face found inside the frame.
  NO_FACE_FOUND,

  /// There is a face found inside the frame.
  FACE_FOUND,

  /// The size of the face is too large within the frame.
  FACE_TOO_BIG,

  /// The size of the face is too small within the frame.
  FACE_TOO_SMALL,

  /// The face is not in the center of frame.
  FACE_NOT_IN_CENTER,

  /// There are multiple faces found inside the frame.
  MULTIPLE_FACES_FOUND,

  /// The processor cannot grab the face from the frame.
  CANNOT_GRAB_FACE,
}
