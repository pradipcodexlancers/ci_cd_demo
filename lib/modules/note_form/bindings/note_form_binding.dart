import 'package:get/get.dart';
import '../controllers/note_form_controller.dart';

class NoteFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NoteFormController>(() => NoteFormController());
  }
}
