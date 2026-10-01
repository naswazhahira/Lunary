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
                title: "What Is Menstruation and How Does the Cycle Work?",
                summary: "Learn about the biological process of menstruation, the components of menstrual blood, hormone fluctuations, and why tracking your cycle matters.",
                content: "Menstruation is the shedding of the lining of the uterus (the endometrium) along with periodic bleeding, driven by cyclical changes in sex hormones released by the ovaries.\n\nExcept during pregnancy and after menopause, menstruation occurs roughly once a month. It begins at puberty (called menarche) and stops permanently after menopause.\n\nMain Components of Menstrual Blood\nThe main component of menstruation is blood. It also contains remnants of endometrial tissue, inflammatory cells, cervical mucus, and shed vaginal epithelial cells. Menstrual blood does not clot easily under normal conditions because of natural fibrinolytic enzymes.\n\nYour Cycle Is Not Always Exactly 28 Days\nThe average menstrual cycle ranges from 21 to 35 days. Only about 10%-15% of women have a cycle of exactly 28 days, so there is no need to worry if yours varies slightly.\n\nIn addition, at least 20% of women experience irregular cycles. Menstrual bleeding usually lasts 3–7 days, averaging 5 days, and total blood loss per cycle ranges from 15–75 ml.",
                imageUrl: "https://images.unsplash.com/photo-1518895949257-7621c3c786d7?q=80&w=600&auto=format&fit=crop",
                category: "Understanding the Menstrual Cycle",
              ),
              Article(
                title: "The 4 Main Phases of the Menstrual Cycle",
                summary: "A detailed look at the Menstrual, Follicular, Ovulation, and Luteal phases and their physical and emotional changes.",
                content: "The menstrual cycle is divided into 4 continuous biological phases:\n\n1. Menstrual Phase (Days 1-7):\nThis phase begins on the first day of bleeding. Estrogen and progesterone are at their lowest because the egg was not fertilized. The endometrial lining sheds. Common symptoms include fatigue, mild to moderate abdominal cramps, and mood changes.\n\n2. Follicular Phase (Days 1-14):\nThis phase starts together with the menstrual phase and continues until ovulation. The brain stimulates the release of Follicle Stimulating Hormone (FSH) to mature follicles in the ovary. Estrogen rises sharply to rebuild the endometrial tissue. In this phase you will likely feel more energetic, focused, and confident.\n\n3. Ovulation Phase (Around Day 14):\nA surge of Luteinizing Hormone (LH) triggers the release of a mature egg from the ovary into the fallopian tube. This is the peak of the fertile window. The egg survives for 12–24 hours. Signs include a rise in basal body temperature and cervical mucus that becomes clear and stretchy like egg white.\n\n4. Luteal Phase (Days 15-28):\nThe empty follicle turns into the corpus luteum, which produces progesterone. This hormone keeps the uterine lining thick and ready to receive a fertilized egg. If there is no fertilization, the corpus luteum shrinks, hormone levels drop, and PMS (premenstrual syndrome) symptoms begin before a new cycle starts.",
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
                title: "Meet the 4 Main Hormones That Control the Female Cycle",
                summary: "Estrogen, Progesterone, FSH, and LH: how they work, what they do in the body, and the effects of imbalance.",
                content: "The female reproductive system is carefully regulated by four main hormones:\n\n1. Estrogen:\nThis hormone builds and thickens the uterine lining, improves skin elasticity, supports bone health, and triggers the production of fertile cervical mucus.\n\n2. Progesterone:\nMaintained after ovulation to calm the uterus and support pregnancy. Progesterone has a calming effect on the nervous system, but high levels without enough estrogen to balance it can cause bloating, constipation, and breast tenderness.\n\n3. FSH (Follicle Stimulating Hormone):\nProduced by the pituitary gland in the brain to control the maturation of egg follicles in the ovaries.\n\n4. LH (Luteinizing Hormone):\nThe main trigger for ovulation. Without a sufficient LH surge, the egg will not be released from the follicle.",
                imageUrl: "https://images.unsplash.com/photo-1576091160550-2173dba999ef?q=80&w=600&auto=format&fit=crop",
                category: "Hormones & Balance",
              ),
              Article(
                title: "Signs of Hormonal Imbalance in Women",
                summary: "Physical and mental signs when estrogen and progesterone are out of balance.",
                content: "Hormonal imbalance often results from chronic stress, poor diet, or certain medical conditions. Signs include:\n\n- Irregular periods or frequently skipped months.\n- Stubborn acne around the jawline and chin.\n- Weight gain that is hard to control.\n- Excessive tiredness even when you get enough sleep.\n- Extreme mood swings and high anxiety before your period.",
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
                title: "How to Identify Your Fertile Window Through Cervical Mucus",
                summary: "A practical guide to observing the texture and consistency of daily vaginal discharge.",
                content: "Cervical mucus is produced by the cervix and changes significantly in texture throughout the cycle due to the effects of estrogen:\n\n- After Menstruation (Days 1–3 after your period): The vagina feels fairly dry and there is little to no mucus.\n- Pre-Ovulation Phase: Mucus begins to appear, cloudy, slightly sticky, or with a creamy texture.\n- Peak Fertility (During Ovulation): Mucus becomes clear, slippery, and can be stretched several centimeters without breaking (similar to raw egg white).\n\nThis clear, slippery mucus provides nutrients and helps sperm swim toward the egg. After ovulation is over, the mucus becomes thick again or dries up.",
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
                title: "Detecting Ovulation Using Basal Body Temperature",
                summary: "A technique for recording your lowest body temperature in the morning to confirm ovulation.",
                content: "Basal Body Temperature (BBT) is your body's lowest resting temperature, measured right after waking up in the morning, before any physical activity, including getting out of bed.\n\nHow to Do It:\nUse a basal thermometer (one that is accurate to two decimal places). Take your temperature under the tongue every morning at the same time.\n\nTemperature Chart:\nBefore ovulation, BBT stays in a lower range (around 36.1°C – 36.4°C). Once ovulation occurs, the progesterone that is released raises your body temperature by 0.2°C – 0.5°C until the cycle ends.",
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
                title: "Main Causes of Irregular Periods",
                summary: "Factors that trigger slow, overly frequent, or frequently skipped cycles.",
                content: "A menstrual cycle is considered irregular if it is shorter than 21 days or longer than 35 days several times in a row.\n\nMain Causes:\n1. Chronic Stress: Stress raises cortisol levels, which can block signals from the brain to the ovaries.\n2. Diet & Strict Dieting: A body low on energy will delay ovulation to conserve calories.\n3. Polycystic Ovary Syndrome (PCOS): An androgen imbalance that hinders follicle maturation.\n4. Thyroid Disorders: An overactive (hyperthyroid) or underactive (hypothyroid) thyroid gland affects reproductive hormones.",
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
                title: "How Many Days Late Is Normal, and When Should You See a Doctor?",
                summary: "A practical guide to telling a normal late period from signs of a medical problem.",
                content: "A period that is 1 to 7 days later than expected is still considered normal, since the human body is affected by many daily variables.\n\nWhen to Be Concerned:\nIf your period is more than 14 days late without a positive pregnancy test, or if you miss 3 cycles in a row (a condition called secondary amenorrhea), you should see an obstetrician-gynecologist for an evaluation, including an ultrasound of the uterus.",
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
                title: "Telling Brown Spotting Apart from Menstrual Blood",
                summary: "Learn the differences in volume, color, and causes of spotting outside your period.",
                content: "Spotting is light bleeding, usually dark red or brown drops on your underwear that do not require a thick pad.\n\nCauses of Spotting Outside Your Period:\n- Implantation Bleeding: Occurs 1–2 weeks after conception when the embryo attaches to the uterus.\n- Ovulation Bleeding: A mild hormone surge when the egg is released.\n- Contraceptive Effects: The start of using birth control pills or an IUD.",
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
                title: "Understanding Menorrhagia: Excessively Heavy Periods",
                summary: "Signs of excessive bleeding and its effect on anemia.",
                content: "Menorrhagia occurs when your period lasts more than 7 days or you need to change a fully soaked pad every 1–2 hours continuously.\n\nThe Dangers of Menorrhagia:\nHeavy bleeding can lead to iron deficiency anemia, marked by pale skin, shortness of breath, dizziness, and extreme fatigue. This condition is often caused by fibroids, uterine polyps, or disorders of the uterine lining.",
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
                title: "Solutions for Easing Dysmenorrhea (Period Cramps)",
                summary: "Natural steps and medical relief to ease lower abdominal cramps.",
                content: "Period cramps (dysmenorrhea) are caused by uterine muscle contractions triggered by the release of chemical compounds called prostaglandins.\n\nSelf-Care Steps:\n1. Warm Compress: Place a hot water bottle or heating pad on your lower abdomen for 15–20 minutes.\n2. Herbal Drinks: Drink warm ginger tea or chamomile tea, which are rich in anti-inflammatory compounds.\n3. Gentle Massage: Gently massage your lower abdomen in circles using lavender essential oil.\n4. Pain Relievers: If the pain is unbearable, use an NSAID pain reliever such as ibuprofen as directed.",
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
                title: "Managing Emotions and Mood Swings During PMS",
                summary: "Tips for protecting your mental health and emotional stability before your period.",
                content: "Drastic changes in estrogen and progesterone levels before your period can affect serotonin, the neurotransmitter that regulates happiness.\n\nTips for Emotional Stability:\n- Cut Back on Caffeine and Sugar: Prevents sharp blood sugar swings that can trigger anxiety.\n- Light Exercise: A 20-minute walk helps the brain release endorphins.\n- Sleep Regularly: Get 7–8 hours of sleep per night to keep your emotions well regulated.",
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
                title: "A Nutrition Guide for Your Period",
                summary: "Menu picks rich in iron, magnesium, and Omega-3 to keep your body feeling good.",
                content: "The right nutrition helps you recover your energy faster during bleeding:\n\n- Iron-Rich Foods: Spinach, lean beef, and legumes help regenerate blood cells.\n- Magnesium-Rich Foods: Dark chocolate, bananas, and avocados help relax muscle contractions.\n- Omega-3 Fatty Acids: Salmon and chia seeds act as natural anti-inflammatories.",
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
                title: "Gentle Yoga Stretches to Relieve Pelvic Tension",
                summary: "Simple yoga poses to loosen a tight pelvis and lower back.",
                content: "Light physical activity has been shown to improve pelvic blood circulation without straining the body:\n\n1. Child's Pose (Balasana): Sit back on your heels and lower your chest forward to stretch the lower back.\n2. Cat-Cow Pose: Slowly loosens the spine and the lower abdominal muscles.",
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
