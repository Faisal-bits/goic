import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';

final Logger logger = Logger('FirestoreDataCorrection');

Future<void> correctLikesCountTypes() async {
  final QuerySnapshot<Map<String, dynamic>> postsSnapshot =
      await FirebaseFirestore.instance.collection('posts').get();

  for (var doc in postsSnapshot.docs) {
    final data = doc.data(); // Data is a Map<String, dynamic>

    final dynamic likesCount = data['likesCount'];
    if (likesCount != null && likesCount is double) {
      // Check for non-null and double
      logger.info("Correcting likesCount for document ${doc.id}");
      await doc.reference.update({'likesCount': likesCount.toInt()});
    }
  }
}
