import '../../../core/constants/app_strings.dart';
import '../../../core/utils/import_to_export.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../controllers/note_form_controller.dart';

/// Full-screen form for both creating and editing a note - see
/// [NoteFormController] for how it decides which mode it's in.
class NoteFormView extends GetView<NoteFormController> {
  const NoteFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.isEditing ? AppStrings.editNote : AppStrings.addNote),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  controller: controller.titleController,
                  label: AppStrings.noteTitle,
                  validator: Validators.noteTitle,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.descriptionController,
                  label: AppStrings.noteDescription,
                  maxLines: 8,
                ),
                const SizedBox(height: 28),
                // Obx rebuilds just the button to show/hide the loading spinner
                // while the Firestore write is in flight.
                Obx(
                  () => CustomButton(
                    label: AppStrings.save,
                    isLoading: controller.isLoading.value,
                    onPressed: controller.save,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
