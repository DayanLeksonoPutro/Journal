import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:uuid/uuid.dart';
import '../models/category.dart';
import '../providers/journal_provider.dart';

class TemplateJurnalScreen extends StatelessWidget {
  const TemplateJurnalScreen({super.key});

  List<JournalCategory> get _predefinedTemplates => [
        JournalCategory(
          id: 'tpl_sholat',
          name: 'Ibadah Harian',
          colorIndex: 0,
          iconName: 'checkCircle',
          fields: [
            FieldDefinition(
                id: 'subuh',
                label: 'Subuh',
                type: FieldType.checkbox,
                isSuccessIndicator: true),
            FieldDefinition(
                id: 'dzuhur',
                label: 'Dzuhur',
                type: FieldType.checkbox,
                isSuccessIndicator: true),
            FieldDefinition(
                id: 'ashar',
                label: 'Ashar',
                type: FieldType.checkbox,
                isSuccessIndicator: true),
            FieldDefinition(
                id: 'maghrib',
                label: 'Maghrib',
                type: FieldType.checkbox,
                isSuccessIndicator: true),
            FieldDefinition(
                id: 'isya',
                label: 'Isya',
                type: FieldType.checkbox,
                isSuccessIndicator: true),
            FieldDefinition(
                id: 'tilawah',
                label: 'Tilawah (Halaman)',
                type: FieldType.number),
          ],
        ),
        JournalCategory(
          id: 'tpl_trading',
          name: 'Trading Log',
          colorIndex: 0,
          iconName: 'lineChart',
          fields: [
            FieldDefinition(
                id: 'pair', label: 'Pair/Ticker', type: FieldType.text),
            FieldDefinition(
                id: 'setup', label: 'Setup/Strategy', type: FieldType.text),
            FieldDefinition(
                id: 'pnl', label: 'Profit/Loss', type: FieldType.number),
            FieldDefinition(
                id: 'is_win',
                label: 'Result (Win)',
                type: FieldType.checkbox,
                isSuccessIndicator: true),
            FieldDefinition(
                id: 'chart_ss',
                label: 'Chart Screenshot',
                type: FieldType.imagePair),
            FieldDefinition(id: 'notes', label: 'Notes', type: FieldType.text),
          ],
        ),
        JournalCategory(
          id: 'tpl_work',
          name: 'Produktifitas Kerja',
          colorIndex: 0,
          iconName: 'book',
          fields: [
            FieldDefinition(
                id: 'tasks',
                label: 'Task Selesai',
                type: FieldType.number,
                isSuccessIndicator: true),
            FieldDefinition(
                id: 'focus', label: 'Jam Fokus', type: FieldType.number),
            FieldDefinition(
                id: 'meeting', label: 'Catatan Meeting', type: FieldType.text),
            FieldDefinition(
                id: 'blocker', label: 'Hambatan', type: FieldType.text),
          ],
        ),
        JournalCategory(
          id: 'tpl_gym',
          name: 'Fitness & Gym',
          colorIndex: 0,
          iconName: 'dumbbell',
          fields: [
            FieldDefinition(
                id: 'exercise', label: 'Latihan', type: FieldType.text),
            FieldDefinition(
                id: 'weight', label: 'Berat (kg)', type: FieldType.number),
            FieldDefinition(
                id: 'sets', label: 'Sets x Reps', type: FieldType.text),
            FieldDefinition(
                id: 'cardio', label: 'Cardio (menit)', type: FieldType.number),
          ],
        ),
        JournalCategory(
          id: 'tpl_finance',
          name: 'Catatan Keuangan',
          colorIndex: 0,
          iconName: 'shoppingCart',
          fields: [
            FieldDefinition(
                id: 'item', label: 'Barang/Jasa', type: FieldType.text),
            FieldDefinition(
                id: 'amount', label: 'Nominal', type: FieldType.number),
            FieldDefinition(
                id: 'category',
                label: 'Kategori (Makan/Transp/etc)',
                type: FieldType.text),
          ],
        ),
        JournalCategory(
          id: 'tpl_diet',
          name: 'Diet & Nutrisi',
          colorIndex: 0,
          iconName: 'checkCircle',
          fields: [
            FieldDefinition(
                id: 'water',
                label: 'Minum Air (Gelas)',
                type: FieldType.number,
                isSuccessIndicator: true),
            FieldDefinition(
                id: 'calories', label: 'Total Kalori', type: FieldType.number),
            FieldDefinition(
                id: 'fasting', label: 'Puasa (Jam)', type: FieldType.number),
            FieldDefinition(
                id: 'mood', label: 'Kondisi Perut', type: FieldType.text),
          ],
        ),
        JournalCategory(
          id: 'tpl_mood',
          name: 'Mood & Gratitude',
          colorIndex: 0,
          iconName: 'journal',
          fields: [
            FieldDefinition(
                id: 'mood_score', label: 'Mood (1-10)', type: FieldType.number),
            FieldDefinition(
                id: 'grateful',
                label: 'Hal yang Disyukuri',
                type: FieldType.text),
            FieldDefinition(
                id: 'highlight',
                label: 'Kejadian Berkesan',
                type: FieldType.text),
          ],
        ),
        JournalCategory(
          id: 'tpl_learning',
          name: 'Belajar & Kursus',
          colorIndex: 0,
          iconName: 'book',
          fields: [
            FieldDefinition(
                id: 'topic', label: 'Topik Belajar', type: FieldType.text),
            FieldDefinition(
                id: 'duration',
                label: 'Durasi (menit)',
                type: FieldType.number),
            FieldDefinition(
                id: 'summary', label: 'Ringkasan', type: FieldType.text),
          ],
        ),
        JournalCategory(
          id: 'tpl_travel',
          name: 'Travel Journal',
          colorIndex: 0,
          iconName: 'airplane',
          fields: [
            FieldDefinition(
                id: 'destination', label: 'Destinasi', type: FieldType.text),
            FieldDefinition(
                id: 'rating',
                label: 'Rating Pengalaman (1-5)',
                type: FieldType.number),
            FieldDefinition(
                id: 'food', label: 'Kuliner Terbaik', type: FieldType.text),
          ],
        ),
        JournalCategory(
          id: 'tpl_book_rev',
          name: 'Review Buku',
          colorIndex: 0,
          iconName: 'book',
          fields: [
            FieldDefinition(
                id: 'title', label: 'Judul Buku', type: FieldType.text),
            FieldDefinition(
                id: 'author', label: 'Penulis', type: FieldType.text),
            FieldDefinition(
                id: 'takeaway',
                label: 'Pelajaran Penting',
                type: FieldType.text),
          ],
        ),
        JournalCategory(
          id: 'tpl_pet',
          name: 'Pet Care',
          colorIndex: 0,
          iconName: 'checkCircle',
          fields: [
            FieldDefinition(
                id: 'food',
                label: 'Memberi Makan',
                type: FieldType.checkbox,
                isSuccessIndicator: true),
            FieldDefinition(
                id: 'vitamin', label: 'Vitamin/Obat', type: FieldType.checkbox),
            FieldDefinition(
                id: 'notes', label: 'Catatan Kesehatan', type: FieldType.text),
          ],
        ),
        JournalCategory(
          id: 'tpl_home',
          name: 'Perawatan Rumah',
          colorIndex: 0,
          iconName: 'settings',
          fields: [
            FieldDefinition(
                id: 'task', label: 'Pekerjaan', type: FieldType.text),
            FieldDefinition(
                id: 'cost', label: 'Biaya (Rp)', type: FieldType.number),
            FieldDefinition(
                id: 'is_done',
                label: 'Selesai',
                type: FieldType.checkbox,
                isSuccessIndicator: true),
          ],
        ),
        JournalCategory(
          id: 'tpl_garden',
          name: 'Kebun & Tanaman',
          colorIndex: 0,
          iconName: 'leaf',
          fields: [
            FieldDefinition(
                id: 'plant', label: 'Nama Tanaman', type: FieldType.text),
            FieldDefinition(
                id: 'watered',
                label: 'Sudah Disiram',
                type: FieldType.checkbox,
                isSuccessIndicator: true),
            FieldDefinition(
                id: 'fertilizer', label: 'Pupuk (Tipe)', type: FieldType.text),
          ],
        ),
        JournalCategory(
          id: 'tpl_relationship',
          name: 'Relationship & Family',
          colorIndex: 0,
          iconName: 'journal',
          fields: [
            FieldDefinition(
                id: 'call',
                label: 'Telepon Keluarga',
                type: FieldType.checkbox),
            FieldDefinition(
                id: 'quality_time',
                label: 'Quality Time (Menit)',
                type: FieldType.number),
            FieldDefinition(
                id: 'gift', label: 'Pemberian/Hadiah', type: FieldType.text),
          ],
        ),
      ];

  void _addTemplate(BuildContext context, JournalCategory template) {
    final journalProvider =
        Provider.of<JournalProvider>(context, listen: false);

    if (journalProvider.categories.any((c) => c.name == template.name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Template "${template.name}" sudah ada!')),
      );
      return;
    }

    final newCategory = JournalCategory(
      id: const Uuid().v4(),
      name: template.name,
      colorIndex: template.colorIndex,
      iconName: template.iconName,
      fields: List.from(template.fields),
    );

    journalProvider.addCategory(newCategory);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Template "${template.name}" berhasil ditambahkan!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Template Jurnal'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _predefinedTemplates.length,
        itemBuilder: (context, index) {
          final template = _predefinedTemplates[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            color:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: _getCategoryIcon(template.iconName,
                  color: Theme.of(context).colorScheme.primary),
              title: Text(
                template.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${template.fields.length} Field tersedia'),
              trailing: iconoir.Plus(
                color: Theme.of(context).colorScheme.primary,
              ),
              onTap: () => _addTemplate(context, template),
            ),
          );
        },
      ),
    );
  }

  Widget _getCategoryIcon(String? iconName, {Color? color}) {
    const double size = 32;
    switch (iconName) {
      case 'lineChart':
        return iconoir.GraphUp(width: size, height: size, color: color);
      case 'checkCircle':
        return iconoir.CheckCircle(width: size, height: size, color: color);
      case 'shoppingCart':
        return iconoir.Cart(width: size, height: size, color: color);
      case 'dumbbell':
        return iconoir.Gym(width: size, height: size, color: color);
      case 'book':
        return iconoir.Book(width: size, height: size, color: color);
      case 'airplane':
        return iconoir.Airplane(width: size, height: size, color: color);
      case 'settings':
        return iconoir.Settings(width: size, height: size, color: color);
      case 'leaf':
        return iconoir.Flower(width: size, height: size, color: color);
      default:
        return iconoir.Journal(width: size, height: size, color: color);
    }
  }
}
