import 'package:flutter/material.dart';
import '../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../core/routing/app_navigation.dart';
import '../models/article_model.dart';
import 'article_list_screen.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({Key? key}) : super(key: key);

  List<InsightSection> _getSampleData() {
    return [
      InsightSection(
        title: "Knowing Your Cycle",
        categories: [
          InsightCategory(
            title: "Understanding the Menstrual Cycle",
            bannerImage: "assets/images/cycle.jpg",
            articles: [
              Article(
                title: "Apa Itu Menstruasi dan Bagaimana Siklusnya Bekerja?",
                summary: "Pelajari secara mendalam proses biologis menstruasi, komponen darah, fluktuasi hormon, dan pentingnya mencatat siklus Anda.",
                content: "Menstruasi adalah fenomena pengelupasan lapisan dalam rahim (endometrium) dan pendarahan berkala yang dipengaruhi oleh perubahan hormon seksual secara periodik yang disekresikan oleh ovarium.\n\nKecuali pada wanita setelah kehamilan dan menopause, menstruasi terjadi sekitar sebulan sekali. Menstruasi dimulai saat pubertas (disebut menarke) dan berhenti secara permanen setelah menopause.\n\nKomponen Utama Darah Haid\nKomponen utama menstruasi adalah darah. Selain itu, terdapat sisa-sisa jaringan endometrium, sel-sel inflamasi, lendir serviks, serta sel-sel epitel vagina yang terkelupas. Pendarahan menstruasi tidak mudah membeku dalam kondisi normal karena adanya enzim fibrinolitik alami.\n\nSiklus Menstruasi Tidak Selalu Tepat 28 Hari\nPanjang siklus menstruasi rata-rata berkisar antara 21 hingga 35 hari. Hanya sekitar 10%-15% wanita yang memiliki siklus tepat 28 hari, jadi Anda tidak perlu khawatir jika siklus Anda sedikit bervariasi.\n\nSelain itu, setidaknya 20% wanita mengalami siklus tidak teratur. Pendarahan haid umumnya berlangsung selama 3–7 hari, dengan rata-rata 5 hari, dan total kehilangan darah dalam satu siklus berkisar antara 15–75 ml.",
                imageUrl: "https://images.unsplash.com/photo-1518895949257-7621c3c786d7?q=80&w=600&auto=format&fit=crop",
                category: "Understanding the Menstrual Cycle",
              ),
              Article(
                title: "4 Fase Utama dalam Siklus Menstruasi",
                summary: "Penjelasan detail mengenai Fase Menstruasi, Folikular, Ovulasi, dan Luteal beserta perubahan fisik dan emosionalnya.",
                content: "Siklus menstruasi terbagi menjadi 4 fase biologis yang berkelanjutan:\n\n1. Fase Menstruasi (Hari 1-7):\nFase ini dimulai pada hari pertama darah keluar. Kadar hormon estrogen dan progesteron berada di titik terendah karena tidak terjadi pembuahan sel telur. Lapisan endometrium meluruh. Gejala yang umum dirasakan meliputi lemas, kram perut ringan hingga sedang, dan perubahan suasana hati.\n\n2. Fase Folikular (Hari 1-14):\nDimulai bersamaan dengan fase menstruasi dan berlanjut hingga masa ovulasi. Otak merangsang pelepasan Follicle Stimulating Hormone (FSH) untuk mematangkan folikel di dalam ovarium. Estrogen meningkat tajam untuk mempertebal kembali jaringan endometrium. Di fase ini Anda akan merasa lebih bertenaga, fokus, dan percaya diri.\n\n3. Fase Ovulasi (Sekitar Hari 14):\nLonjakan Luteinizing Hormone (LH) memicu pelepasan sel telur matang dari ovarium menuju tuba falopi. Ini adalah puncak masa subur. Sel telur bertahan hidup selama 12–24 jam. Gejalanya mencakup peningkatan suhu tubuh basal dan lendir serviks yang menjadi bening serta elastis seperti putih telur.\n\n4. Fase Luteal (Hari 15-28):\nBekas folikel berubah menjadi korpus luteum yang menghasilkan progesteron. Hormon ini menjaga dinding rahim tetap tebal dan siap menerima sel telur yang dibuahi. Jika tidak ada pembuahan, korpus luteum menyusut, hormon anjlok, dan gejala PMS (Pra-Menstruasi) mulai muncul sebelum siklus baru dimulai.",
                imageUrl: "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?q=80&w=600&auto=format&fit=crop",
                category: "Understanding the Menstrual Cycle",
              ),
            ],
          ),
          InsightCategory(
            title: "Hormones & Balance",
            bannerImage: "https://images.unsplash.com/photo-1516549655169-df83a0774514?q=80&w=600&auto=format&fit=crop",
            articles: [
              Article(
                title: "Mengenal 4 Hormon Utama Pengendali Siklus Wanita",
                summary: "Estrogen, Progesteron, FSH, dan LH: Cara kerja, fungsi tubuh, dan efek ketidakseimbangannya.",
                content: "Sistem reproduksi wanita diatur secara cermat oleh empat hormon utama:\n\n1. Estrogen:\nHormon ini bertugas membangun dan menebalkan dinding rahim, meningkatkan elastisitas kulit, menjaga kesehatan tulang, serta memicu produksi lendir serviks masa subur.\n\n2. Progesteron:\nDipertahankan setelah ovulasi untuk menenangkan rahim dan mendukung kehamilan. Progesteron memiliki efek menenangkan sistem saraf, namun kadar tinggi tanpa imbangan estrogen dapat memicu kembung, sembelit, dan payudara nyeri.\n\n3. FSH (Follicle Stimulating Hormone):\nDihasilkan oleh kelenjar hipofisis di otak untuk mengendalikan matangnya folikel telur di ovarium.\n\n4. LH (Luteinizing Hormone):\nHormon pemicu utama ovulasi. Tanpa lonjakan LH yang cukup, sel telur tidak akan dilepaskan dari folikel.",
                imageUrl: "https://images.unsplash.com/photo-1576091160550-2173dba999ef?q=80&w=600&auto=format&fit=crop",
                category: "Hormones & Balance",
              ),
              Article(
                title: "Tanda-Tanda Ketidakseimbangan Hormon pada Wanita",
                summary: "Ciri-ciri fisik dan mental ketika hormon estrogen dan progesteron tidak seimbang.",
                content: "Ketidakseimbangan hormon sering terjadi akibat stres kronis, pola makan buruk, atau masalah medis tertentu. Tanda-tandanya meliputi:\n\n- Siklus haid yang tidak teratur atau sering melompat bulan.\n- Jerawat membandel di area rahang dan dagu.\n- Peningkatan berat badan yang sulit dikontrol.\n- Rasa lelah berlebihan meskipun tidur cukup.\n- Perubahan suasana hati ekstrim dan kecemasan tinggi menjelang haid.",
                imageUrl: "https://images.unsplash.com/photo-1516549655169-df83a0774514?q=80&w=600&auto=format&fit=crop",
                category: "Hormones & Balance",
              ),
            ],
          ),
          InsightCategory(
            title: "Cervical Mucus & Fertile Window",
            bannerImage: "https://images.unsplash.com/photo-1518611012118-696072aa579a?q=80&w=600&auto=format&fit=crop",
            articles: [
              Article(
                title: "Cara Menentukan Masa Subur Lewat Lendir Serviks",
                summary: "Panduan praktis mengamati tekstur dan konsistensi cairan vagina harian.",
                content: "Lendir serviks diproduksi oleh leher rahim dan mengalami perubahan tekstur yang signifikan sepanjang siklus akibat efek kadar estrogen:\n\n- Pasca Menstruasi (Hari 1–3 setelah haid): Vagina terasa agak kering dan tidak ada lendir yang tersisa.\n- Fase Pra-Ovulasi: Lendir mulai muncul dengan warna keruh, agak lengket, atau bertesktur seperti krim makanan.\n- Puncak Masa Subur (Saat Ovulasi): Lendir berubah menjadi bening, licin, dan dapat diregangkan hingga beberapa sentimeter tanpa putus (mirip dengan putih telur mentah).\n\nLendir bening licin ini berfungsi menyediakan nutrisi dan mempermudah sperma berenang menuju sel telur. Setelah ovulasi selesai, lendir akan kembali kental atau kering kembali.",
                imageUrl: "https://images.unsplash.com/photo-1506126613408-eca07ce68773?q=80&w=600&auto=format&fit=crop",
                category: "Cervical Mucus & Fertile Window",
              ),
            ],
          ),
          InsightCategory(
            title: "Basal Body Temperature (BBT)",
            bannerImage: "https://images.unsplash.com/photo-1584017911766-d451b3d0e843?q=80&w=600&auto=format&fit=crop",
            articles: [
              Article(
                title: "Mendeteksi Ovulasi Menggunakan Suhu Tubuh Basal",
                summary: "Teknik mencatat suhu terendah tubuh di pagi hari untuk mengonfirmasi pembuahan.",
                content: "Suhu Tubuh Basal (BBT) adalah suhu tubuh paling dasar yang diukur sesaat setelah bangun tidur di pagi hari, sebelum melakukan aktivitas fisik apapun termasuk beranjak dari tempat tidur.\n\nCara Melakukannya:\nGunakan termometer basal (yang memiliki akurasi dua angka di belakang koma). Ukur suhu di bawah lidah setiap pagi pada jam yang sama.\n\nGrafik Suhu:\nSebelum ovulasi, BBT berada di kisaran rendah (sekitar 36.1°C – 36.4°C). Begitu ovulasi terjadi, hormon progesteron yang dilepaskan akan menaikkan suhu tubuh sebesar 0.2°C – 0.5°C hingga siklus berakhir.",
                imageUrl: "https://images.unsplash.com/photo-1584017911766-d451b3d0e843?q=80&w=600&auto=format&fit=crop",
                category: "Basal Body Temperature (BBT)",
              ),
            ],
          ),
        ],
      ),
      InsightSection(
        title: "Menstrual FAQs",
        categories: [
          InsightCategory(
            title: "Irregular Periods",
            bannerImage: "https://images.unsplash.com/photo-1508672019048-805479767513?q=80&w=600&auto=format&fit=crop",
            articles: [
              Article(
                title: "Penyebab Utama Menstruasi Datang Tidak Teratur",
                summary: "Faktor-faktor pemicu siklus lambat, terlalu cepat, atau sering meloncat bulan.",
                content: "Siklus menstruasi dianggap tidak teratur jika panjangnya kurang dari 21 hari atau lebih dari 35 hari secara berturut-turut.\n\nFaktor Penyebab Utama:\n1. Stres Kronis: Stres meningkatkan kadar hormon kortisol yang dapat memblokir sinyal otak ke ovarium.\n2. Pola Makan & Diet Ketat: Tubuh yang kekurangan energi akan menunda ovulasi untuk menghemat kalori.\n3. Sindrom Polikistik Ovarium (PCOS): Ketidakseimbangan androgen yang menghambat pematangan folikel.\n4. Gangguan Tiroid: Kelenjar tiroid yang terlalu aktif (hipertiroid) atau kurang aktif (hipotiroid) memengaruhi hormon reproduksi.",
                imageUrl: "https://images.unsplash.com/photo-1508672019048-805479767513?q=80&w=600&auto=format&fit=crop",
                category: "Irregular Periods",
              ),
            ],
          ),
          InsightCategory(
            title: "Delayed Menstruation",
            bannerImage: "https://images.unsplash.com/photo-1579684385127-1ef15d508118?q=80&w=600&auto=format&fit=crop",
            articles: [
              Article(
                title: "Berapa Hari Batas Normal Telat Haid dan Kapan Harus Berobat?",
                summary: "Panduan praktis membedakan telat haid wajar dan gejala gangguan medis.",
                content: "Keterlambatan haid selama 1 hingga 7 hari dari perkiraan jadwal masih tergolong normal karena tubuh manusia dipengaruhi banyak variabel harian.\n\nKapan Harus Khawatir?\nJika keterlambatan mencapai lebih dari 14 hari tanpa adanya tes kehamilan positif, atau jika Anda melewatkan 3 siklus berturut-turut (kondisi amenore sekunder), Anda disarankan melakukan pemeriksaan dokter spesialis kebidanan dan kandungan untuk evaluasi USG rahim.",
                imageUrl: "https://images.unsplash.com/photo-1579684385127-1ef15d508118?q=80&w=600&auto=format&fit=crop",
                category: "Delayed Menstruation",
              ),
            ],
          ),
          InsightCategory(
            title: "Spotting vs Normal Flow",
            bannerImage: "https://images.unsplash.com/photo-1512290900673-0498a4d70428?q=80&w=600&auto=format&fit=crop",
            articles: [
              Article(
                title: "Membedakan Flek Cokelat (Spotting) dan Darah Menstruasi",
                summary: "Kenali perbedaan volume, warna, dan penyebab timbulnya flek di luar periode haid.",
                content: "Flek atau spotting adalah perdarahan ringan yang biasanya berupa tetesan merah tua atau cokelat pada celana dalam tanpa memerlukan pembalut tebal.\n\nPenyebab Flek di Luar Jadwal:\n- Pendarahan Implantasi: Terjadi 1–2 minggu setelah pembuahan saat janin menempel di rahim.\n- Pendarahan Ovulasi: Lonjakan hormon ringan saat pelepasan sel telur.\n- Efek Kontrasepsi: Awal penggunaan pil KB atau IUD.",
                imageUrl: "https://images.unsplash.com/photo-1512290900673-0498a4d70428?q=80&w=600&auto=format&fit=crop",
                category: "Spotting vs Normal Flow",
              ),
            ],
          ),
          InsightCategory(
            title: "Heavy Bleeding (Menorrhagia)",
            bannerImage: "https://images.unsplash.com/photo-1505751172876-fa1923c5c528?q=80&w=600&auto=format&fit=crop",
            articles: [
              Article(
                title: "Mengenal Menoragia: Pendarahan Haid Berlebihan",
                summary: "Tanda-tanda perdarahan berlebih dan efeknya terhadap anemia.",
                content: "Menoragia terjadi jika haid berlangsung lebih dari 7 hari atau Anda harus mengganti pembalut penuh setiap 1–2 jam secara terus-menerus.\n\nBahaya Menoragia:\nPendarahan hebat dapat memicu anemia defisiensi besi yang ditandai dengan kulit pucat, napas pendek, pusing, dan rasa lelah ekstrem. Kondisi ini sering disebabkan oleh miom, polip rahim, atau gangguan penebalan dinding rahim.",
                imageUrl: "https://images.unsplash.com/photo-1505751172876-fa1923c5c528?q=80&w=600&auto=format&fit=crop",
                category: "Heavy Bleeding (Menorrhagia)",
              ),
            ],
          ),
        ],
      ),
      InsightSection(
        title: "Easing the Discomfort",
        categories: [
          InsightCategory(
            title: "Relieving Period Cramps",
            bannerImage: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=600&auto=format&fit=crop",
            articles: [
              Article(
                title: "Solusi Meredakan Dismenore (Kram Perut Haid)",
                summary: "Langkah-langkah alami dan pertolongan medis untuk meredakan kram perut bawah.",
                content: "Kram haid (dismenore) disebabkan oleh kontraksi otot rahim yang dipicu oleh pelepasan senyawa kimia prostaglandin.\n\nLangkah Penanganan Mandiri:\n1. Kompres Hangat: Tempelkan botol berisi air hangat atau bantalan pemanas di perut bagian bawah selama 15–20 menit.\n2. Minuman Herbal: Minum seduhan jahe hangat atau teh chamomile yang kaya senyawa antiinflamasi.\n3. Pijatan Ringan: Pijat lembut area perut bawah melingkar menggunakan minyak esensial lavender.\n4. Obatan Pereda Nyeri: Jika nyeri tidak tertahankan, gunakan obat pereda nyeri jenis NSAID seperti Ibuprofen sesuai petunjuk.",
                imageUrl: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=600&auto=format&fit=crop",
                category: "Relieving Period Cramps",
              ),
            ],
          ),
          InsightCategory(
            title: "Managing Mood Swings",
            bannerImage: "https://images.unsplash.com/photo-1490645935967-10de6ba17061?q=80&w=600&auto=format&fit=crop",
            articles: [
              Article(
                title: "Mengendalikan Emosi dan Perubahan Suasana Hati Saat PMS",
                summary: "Tips menjaga kesehatan mental dan stabilitas emosi menjelang hari menstruasi.",
                content: "Perubahan kadar estrogen dan progesteron secara drastis jelang haid dapat mempengaruhi neurotransmiter serotonin yang mengatur kebahagiaan.\n\nTips Stabilitas Emosi:\n- Kurangi Asupan Kafein dan Gula: Mencegah perubahan gula darah drastis yang memicu kecemasan.\n- Olahraga Ringan: Jalan kaki 20 menit membantu otak melepaskan hormon endorfin.\n- Tidur Teratur: Cukupi waktu tidur 7–8 jam per malam untuk menjaga regulasi emosi.",
                imageUrl: "https://images.unsplash.com/photo-1490645935967-10de6ba17061?q=80&w=600&auto=format&fit=crop",
                category: "Managing Mood Swings",
              ),
            ],
          ),
          InsightCategory(
            title: "Nutrition & Diet Tips",
            bannerImage: "https://images.unsplash.com/photo-1498837167922-ddd27525d352?q=80&w=600&auto=format&fit=crop",
            articles: [
              Article(
                title: "Panduan Makanan Nutrisi Saat Menstruasi",
                summary: "Menu pilihan kaya zat besi, magnesium, dan Omega-3 untuk kebugaran tubuh.",
                content: "Nutrisi yang tepat membantu mempercepat pemulihan energi selama pendarahan:\n\n- Makanan Kaya Zat Besi: Bayam, daging sapi tanpa lemak, dan kacang-kacangan meregenerasi sel darah.\n- Makanan Kaya Magnesium: Cokelat hitam (dark chocolate), pisang, dan alpukat merelaksasi kontraksi otot.\n- Asam Lemak Omega-3: Ikan salmon dan biji chia bertindak sebagai pereda peradangan alami.",
                imageUrl: "https://images.unsplash.com/photo-1498837167922-ddd27525d352?q=80&w=600&auto=format&fit=crop",
                category: "Nutrition & Diet Tips",
              ),
            ],
          ),
          InsightCategory(
            title: "Exercise & Stretches",
            bannerImage: "https://images.unsplash.com/photo-1518611012118-696072aa579a?q=80&w=600&auto=format&fit=crop",
            articles: [
              Article(
                title: "Gerakan Peregangan Yoga Ringan Meredakan Ketegangan Panggul",
                summary: "Pose yoga sederhana untuk melemaskan panggul dan pinggang yang tegang.",
                content: "Aktivitas fisik ringan terbukti memperlancar sirkulasi darah panggul tanpa membebankan tubuh:\n\n1. Child's Pose (Balasana): Duduk bertumpu pada tumit dan rebahkan dada ke depan untuk merenggangkan punggung bawah.\n2. Cat-Cow Pose: Melemaskan tulang belakang dan otot perut bagian bawah secara perlahan.",
                imageUrl: "https://images.unsplash.com/photo-1518611012118-696072aa579a?q=80&w=600&auto=format&fit=crop",
                category: "Exercise & Stretches",
              ),
            ],
          ),
        ],
      ),
    ];
  }

  Widget _buildBannerImage(String path) {
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        height: 180,
        width: 220,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 180,
            width: 220,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
          );
        },
      );
    }
    return Image.network(
      path,
      height: 180,
      width: 220,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 180,
          width: 220,
          color: Colors.grey[200],
          child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sections = _getSampleData();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF9F7FB), Color(0xFFFAF2F7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Text(
                  "Insights",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2B4E),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: sections.length,
                  itemBuilder: (context, sectionIdx) {
                    final section = sections[sectionIdx];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                          child: Text(
                            section.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 270,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: section.categories.length,
                            itemBuilder: (context, catIdx) {
                              final cat = section.categories[catIdx];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ArticleListScreen(category: cat),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 220,
                                  margin: const EdgeInsets.only(right: 18),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: _buildBannerImage(cat.bannerImage),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        cat.title,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF333333),
                                          height: 1.2,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    );
                  },
                ),
              ),
              AppBottomNavBar(
                currentTab: AppNavTab.insights,
                onTabSelected: (tab) => handleAppNavTap(context, tab),
              ),
            ],
          ),
        ),
      ),
    );
  }
}