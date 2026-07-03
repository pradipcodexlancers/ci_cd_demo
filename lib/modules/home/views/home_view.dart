import '../../../core/constants/app_strings.dart';
import '../../../core/utils/import_to_export.dart';
import '../../../core/widgets/note_card.dart';
import '../../../core/widgets/state_placeholder.dart';
import '../../../routes/app_routes.dart';
import '../controllers/home_controller.dart';

/// Home screen: search bar + sort menu + real-time notes list + FAB to add
/// a note. Handles the loading / error / empty / populated states that
/// come from streaming Firestore data (see [HomeController]).
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  String _sortLabel(NoteSortOption option) {
    switch (option) {
      case NoteSortOption.newest:
        return AppStrings.sortNewest;
      case NoteSortOption.oldest:
        return AppStrings.sortOldest;
      case NoteSortOption.titleAz:
        return AppStrings.sortTitleAz;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.home),
        actions: [
          // Obx rebuilds just the icon so the checkmark tracks the active sort.
          Obx(
            () => PopupMenuButton<NoteSortOption>(
              icon: const Icon(Icons.sort),
              tooltip: AppStrings.sortBy,
              initialValue: controller.sortOption.value,
              onSelected: controller.updateSortOption,
              itemBuilder: (context) => NoteSortOption.values.map((option) {
                return PopupMenuItem(
                  value: option,
                  child: Row(
                    children: [
                      if (option == controller.sortOption.value)
                        const Icon(Icons.check, size: 18)
                      else
                        const SizedBox(width: 18),
                      const SizedBox(width: 8),
                      Text(_sortLabel(option)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Get.toNamed(Routes.profile),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Get.toNamed(Routes.settings),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              onChanged: controller.updateSearchQuery,
              decoration: InputDecoration(
                hintText: AppStrings.searchNotes,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            // Obx rebuilds on loading/error/notes/search/sort changes -
            // whichever state applies is shown.
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return StatePlaceholder(
                  icon: Icons.cloud_off,
                  message: controller.errorMessage.value,
                  actionLabel: AppStrings.retry,
                  onAction: controller.retry,
                );
              }

              final notes = controller.filteredNotes;
              if (notes.isEmpty) {
                return StatePlaceholder(
                  icon: controller.hasAnyNotes ? Icons.search_off : Icons.note_add_outlined,
                  message: controller.hasAnyNotes
                      ? AppStrings.noResultsFound
                      : AppStrings.noNotesYet,
                );
              }

              return ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return NoteCard(
                    note: note,
                    onTap: () => Get.toNamed(Routes.editNote, arguments: note),
                    onDelete: () => controller.deleteNote(note),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.addNote),
        child: const Icon(Icons.add),
      ),
    );
  }
}
