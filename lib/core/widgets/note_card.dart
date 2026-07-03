import 'package:intl/intl.dart';
import '../../models/note_model.dart';
import '../theme/app_text_styles.dart';
import '../utils/import_to_export.dart';

/// Displays a single [NoteModel] in the Home list.
/// Tapping opens the note for editing; the trailing icon deletes it.
class NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: isDark ? AppColors.noteCardColorDark : AppColors.noteCardColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        title: Text(
          note.title,
          style: semiboldPoppins(16, textColor: isDark ? AppColors.whiteColor : AppColors.blackColor),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              note.description,
              style: regularPoppins(14, textColor: isDark ? AppColors.whiteColor : AppColors.blackColor),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              // Show last-updated time so users know how fresh a note is.
              DateFormat('MMM d, yyyy • h:mm a').format(note.updatedAt),
              style: regularPoppins(11, textColor: AppColors.greyColor),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.error),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
