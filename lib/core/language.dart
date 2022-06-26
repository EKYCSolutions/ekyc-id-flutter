import 'models/language.dart';

const Map<String, Map<Language, String>> LANGUAGE = {
  "initializing": {
    Language.EN: "Initializing",
    Language.KH: "កំពុងចាប់ផ្តើម",
  },
  "preparing": {
    Language.EN: "Preparing",
    Language.KH: "កំពុងរៀបចំ",
  },
  "processing": {
    Language.EN: "Processing",
    Language.KH: "ដំណើរការ",
  },
  "move_back": {
    Language.EN: "Move Back",
    Language.KH: "កាន់អោយឆ្ងាយ",
  },
  "move_closer": {
    Language.EN: "Move Closer",
    Language.KH: "កាន់អោយជិត",
  },
  "scan_the_front_of_the_document": {
    Language.EN: "Scan the front of the document",
    Language.KH: "ស្កេនផ្នែកខាងមុខនៃឯកសារ",
  },
  "scan_the_back_of_the_document": {
    Language.EN: "Scan the back of the document",
    Language.KH: "ស្កេនផ្នែកខាងក្រោយនៃឯកសារ",
  },
  "place_document_at_the_center": {
    Language.EN: "Place the object at the center",
    Language.KH: "ដាក់ឯកសារនៅកណ្តាល",
  },
  "place_face_at_the_center": {
    Language.EN: "Place your face at the center",
    Language.KH: "ដាក់មុខរបស់អ្នកនៅកណ្តាល",
  },
  "face_not_found": {
    Language.EN: "Can not get face from card.",
    Language.KH: "មិនអាចទាញយកមុខពីកាត",
  },
  "multiple_faces_found": {
    Language.EN: "Multiple Faces Detected",
    Language.KH: "ចាប់បានមុខលើសពីមួយ",
  },
  "document_not_found": {
    Language.EN: "Can not grab document from image",
    Language.KH: "មិនអាចទាញយកកាតចេញពីរូបភាព",
  },
};
