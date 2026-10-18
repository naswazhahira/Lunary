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
                title: "Understanding Your Period — What Happens During Your Menstrual Cycle?",
                summary: "Your menstrual cycle is more than the days when you experience bleeding. It is a recurring process involving hormones, the ovaries, and the uterus that prepares the body for a possible pregnancy.",
                content: """Introduction
Your menstrual cycle is more than the days when you experience bleeding. It is a recurring process involving hormones, the ovaries, and the uterus that prepares the body for a possible pregnancy.

Understanding this process can help you recognize changes in your body, estimate when your next period may begin, and identify symptoms that deserve attention.

Although many people describe the menstrual cycle as lasting 28 days, cycles do not always follow the same schedule. Cycle length and symptoms can vary from person to person and sometimes from month to month.

A menstrual tracker can help you observe these changes without expecting your body to follow an exact calendar every time.

1. The Menstrual Phase: When Your Period Begins
The first day of menstrual bleeding is counted as Day 1 of your cycle.

During this phase, the uterus sheds the lining that developed during the previous cycle. This lining leaves the body through the vagina as menstrual blood and tissue.

Menstrual bleeding commonly lasts around two to seven days, although individual experiences vary.

You may experience symptoms such as:
- Abdominal or lower-back cramps.
- Fatigue or lower energy.
- Headaches.
- Bloating.
- Changes in appetite.
- Emotional sensitivity.

These symptoms are not identical for everyone. Some people feel relatively comfortable during menstruation, while others experience symptoms that affect their daily routines.

What can help?
Prioritize comfort, eat regular meals, stay hydrated, and use heat therapy if you experience cramps. Record your bleeding intensity and symptoms in your tracker to understand your personal pattern.

2. The Follicular Phase: Preparing for Ovulation
The follicular phase begins on the first day of your period and continues until ovulation.

During this phase, the brain releases hormones that stimulate the ovaries to develop follicles. Each follicle contains an immature egg, and usually one becomes dominant. Meanwhile, estrogen levels rise and help the uterine lining develop again.

As your period ends, you may notice that your energy levels or mood begin to improve. However, these changes are not guaranteed, and they should not be treated as rules for how you must feel.

Some people notice changes in cervical mucus as ovulation approaches. It may become clearer, wetter, and more slippery.

What can help?
Use this time to observe your energy, sleep, and mood. If you feel more energetic, you may enjoy scheduling activities that require concentration or physical effort. If you do not notice a difference, that is also normal.

3. The Ovulation Phase: When an Egg Is Released
Ovulation occurs when an ovary releases an egg. In a typical cycle, this happens before the next period, but the exact timing varies.

Ovulation is often estimated as occurring about 14 days before the next menstrual period rather than always on Day 14. A calendar-based prediction cannot confirm the exact day ovulation occurs.

Some people notice mild pelvic discomfort, changes in cervical mucus, or an increase in sexual desire around this time. Others notice no obvious symptoms.

Pregnancy is possible when sperm are present around the fertile window, which includes the days leading up to ovulation and shortly afterward.

What can help?
If you are tracking your cycle for general health awareness, record any changes you observe. If you are trying to avoid pregnancy, do not rely on a period-tracking app alone as a contraceptive method.

4. The Luteal Phase: Preparing for the Next Period
After ovulation, the body produces more progesterone to support the uterine lining. If pregnancy does not occur, hormone levels eventually fall, and the next menstrual period begins.

During the luteal phase, some people experience premenstrual syndrome (PMS).

Possible symptoms include:
- Mood swings or irritability.
- Breast tenderness.
- Bloating.
- Food cravings.
- Headaches.
- Changes in sleep.
- Fatigue or difficulty concentrating.

PMS symptoms may begin in the days or weeks before menstruation and usually improve after the period starts. Their intensity can vary between individuals and cycles.

What can help?
Maintain regular sleep, eat balanced meals, stay physically active when comfortable, and plan time for relaxation. Tracking symptoms across several cycles can help you understand whether they follow a recurring pattern.

Why Is Tracking Your Cycle Important?
Recording your period is useful for more than predicting the next bleeding date. It can help you recognize changes in your menstrual health.

Consider tracking the following:
- Period start and end dates: Helps estimate cycle length and bleeding duration
- Bleeding intensity: Helps identify unusually heavy or light periods
- Pain level: Reveals patterns in cramps and discomfort
- Mood: Helps you recognize recurring emotional changes
- Sleep and energy: Helps you observe changes in fatigue and rest
- Other symptoms: Creates a useful record for healthcare appointments

A tracking app estimates future dates based on information you have entered. It cannot diagnose a condition, confirm ovulation, or guarantee when your next period will begin.

What Is a Normal Menstrual Cycle?
There is no single cycle length that applies to everyone. For many adults, cycles around 21–35 days can be normal, while cycle patterns may be more variable during adolescence and around the transition to menopause.

A period that changes occasionally does not automatically indicate a health problem. However, repeated irregularity, unusually heavy bleeding, severe pain, or a sudden change from your usual pattern deserves attention.

Final Thoughts
Understanding the menstrual cycle helps you recognize what is happening inside your body rather than treating every symptom as a surprise.

By tracking your dates, symptoms, and personal experiences, you can develop a clearer picture of your cycle. The goal is not to make your body follow a perfect schedule, but to help you recognize your normal patterns and notice meaningful changes.""",
                imageUrl: "assets/images/menstrual_cycle.jpeg",
                category: "Understanding the Menstrual Cycle",
              ),
            ],
          ),
          // Kategori lama yang tidak ada di GDocs tetap dipertahankan
          InsightCategory(
            title: "Hormones & Balance",
            bannerImage: "assets/images/hormone_balance.jpeg",
            articles: [
              Article(
                title: "Meet the 4 Main Hormones That Control the Female Cycle",
                summary: "Estrogen, Progesterone, FSH, and LH: how they work, what they do in the body, and the effects of imbalance.",
                content: "The female reproductive system is carefully regulated by four main hormones:\n\n1. Estrogen:\nThis hormone builds and thickens the uterine lining, improves skin elasticity, supports bone health, and triggers the production of fertile cervical mucus.\n\n2. Progesterone:\nMaintained after ovulation to calm the uterus and support pregnancy. Progesterone has a calming effect on the nervous system, but high levels without enough estrogen to balance it can cause bloating, constipation, and breast tenderness.\n\n3. FSH (Follicle Stimulating Hormone):\nProduced by the pituitary gland in the brain to control the maturation of egg follicles in the ovaries.\n\n4. LH (Luteinizing Hormone):\nThe main trigger for ovulation. Without a sufficient LH surge, the egg will not be released from the follicle.",
                imageUrl: "assets/images/hormones1.jpeg",
                category: "Hormones & Balance",
              ),
              Article(
                title: "Signs of Hormonal Imbalance in Women",
                summary: "Physical and mental signs when estrogen and progesterone are out of balance.",
                content: "Hormonal imbalance often results from chronic stress, poor diet, or certain medical conditions. Signs include:\n\n- Irregular periods or frequently skipped months.\n- Stubborn acne around the jawline and chin.\n- Weight gain that is hard to control.\n- Excessive tiredness even when you get enough sleep.\n- Extreme mood swings and high anxiety before your period.",
                imageUrl: "assets/images/hormones2.jpeg",
                category: "Hormones & Balance",
              ),
            ],
          ),
          InsightCategory(
            title: "Cervical Mucus & Fertile Window",
            bannerImage: "assets/images/cervical_mucus.jpeg",
            articles: [
              Article(
                title: "How to Identify Your Fertile Window Through Cervical Mucus",
                summary: "A practical guide to observing the texture and consistency of daily vaginal discharge.",
                content: "Cervical mucus is produced by the cervix and changes significantly in texture throughout the cycle due to the effects of estrogen:\n\n- After Menstruation (Days 1–3 after your period): The vagina feels fairly dry and there is little to no mucus.\n- Pre-Ovulation Phase: Mucus begins to appear, cloudy, slightly sticky, or with a creamy texture.\n- Peak Fertility (During Ovulation): Mucus becomes clear, slippery, and can be stretched several centimeters without breaking (similar to raw egg white).\n\nThis clear, slippery mucus provides nutrients and helps sperm swim toward the egg. After ovulation is over, the mucus becomes thick again or dries up.",
                imageUrl: "assets/images/cervical2.jpeg",
                category: "Cervical Mucus & Fertile Window",
              ),
            ],
          ),
          InsightCategory(
            title: "Basal Body Temperature (BBT)",
            bannerImage: "assets/images/bbt.jpeg",
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
            bannerImage: "assets/images/irregular.jpeg",
            articles: [
              Article(
                title: "Main Causes of Irregular Periods",
                summary: "Factors that trigger slow, overly frequent, or frequently skipped cycles.",
                content: "A menstrual cycle is considered irregular if it is shorter than 21 days or longer than 35 days several times in a row.\n\nMain Causes:\n1. Chronic Stress: Stress raises cortisol levels, which can block signals from the brain to the ovaries.\n2. Diet & Strict Dieting: A body low on energy will delay ovulation to conserve calories.\n3. Polycystic Ovary Syndrome (PCOS): An androgen imbalance that hinders follicle maturation.\n4. Thyroid Disorders: An overactive (hyperthyroid) or underactive (hypothyroid) thyroid gland affects reproductive hormones.",
                imageUrl: "assets/images/irregular2.jpeg",
                category: "Irregular Periods",
              ),
            ],
          ),
          InsightCategory(
            title: "Delayed Menstruation",
            bannerImage: "assets/images/delayed.jpeg",
            articles: [
              Article(
                title: "Delayed Menstruation — Common Causes and What You Can Do",
                summary: "A delayed period does not automatically mean that something is wrong. Understand the possible causes including stress, weight changes, exercise, and pregnancy.",
                content: """Introduction
Waiting for your period to arrive can sometimes be stressful, especially when the expected date passes without any signs of menstruation.

A delayed period does not automatically mean that something is wrong. Menstrual cycles can vary naturally, and several factors can influence when bleeding begins.

Stress, changes in weight, intense exercise, pregnancy, hormonal conditions, and certain medications can all affect menstrual timing.

Understanding the possible causes can help you decide what to do next instead of relying on assumptions or worrying about every change in your cycle.

What Does It Mean to Have a Late Period?
A period is considered late when it has not started around the time you expected it to begin.
However, menstrual tracking apps estimate future periods based on previous dates. They cannot predict the exact start date with certainty.
Your cycle may occasionally be shorter or longer than usual. This can happen even when you are generally healthy.

1. Pregnancy
If you have had sex that could result in pregnancy, pregnancy is an important possible cause of a missed period. Home pregnancy tests detect the hormone hCG in urine. Most tests can be used from the first day of a missed period. If you do not know when your period is due, follow the test instructions; testing at least 21 days after the last unprotected sex is a useful general guideline.

2. Stress and Emotional Pressure
Stress can affect the hormonal systems involved in ovulation and menstruation. Period timing may change during particularly stressful periods, such as examinations, major life changes, family difficulties, or prolonged emotional strain.

3. Sudden Changes in Weight or Eating Habits
Significant weight loss, weight gain, or inadequate energy intake can affect the hormones responsible for ovulation. Restrictive eating, skipping meals frequently, or exercising intensely without adequate nutrition may disrupt menstrual cycles.

4. Intense Exercise and Physical Strain
Physical activity supports general health, but very intense exercise combined with insufficient nutrition or inadequate recovery can interfere with normal reproductive hormone function.

5. Hormonal Conditions
Several medical conditions can affect menstrual timing. For example, polycystic ovary syndrome (PCOS) can be associated with irregular or infrequent periods. Thyroid disorders and other hormonal conditions can also disrupt the menstrual cycle.

6. Medications and Contraception
Some hormonal contraceptives can change bleeding patterns. Depending on the method, periods may become lighter, less frequent, irregular, or absent.

7. Adolescence and Perimenopause
Menstrual cycles may be less predictable during the first years after menstruation begins. Hormonal changes during perimenopause can also make periods irregular.

What Should You Do When Your Period Is Late?
Step 1: Check your cycle history
Step 2: Consider a pregnancy test
Step 3: Review recent changes
Step 4: Seek medical advice when needed

When Should You See a Healthcare Professional?
Consider seeking medical advice if:
- You have missed three periods in a row.
- Your cycles have become persistently irregular.
- Your period is late and you have unexplained weight changes or unusual fatigue.
- You have other symptoms that concern you.

Can You Make Your Period Come Faster?
There is no universally safe home remedy that reliably makes a delayed period start. Be cautious with online recommendations involving high doses of vitamins, herbal preparations, or unprescribed hormonal medicines.

Final Thoughts
A late period can have many explanations, and one delayed cycle does not automatically indicate a serious problem.""",
                imageUrl: "assets/images/delayed2.jpeg",
                category: "Delayed Menstruation",
              ),
            ],
          ),
          // Kategori Spotting tidak ada di GDocs, tetap dipertahankan
          InsightCategory(
            title: "Spotting vs Normal Flow",
            bannerImage: "assets/images/spotting.jpeg",
            articles: [
              Article(
                title: "Telling Brown Spotting Apart from Menstrual Blood",
                summary: "Learn the differences in volume, color, and causes of spotting outside your period.",
                content: "Spotting is light bleeding, usually dark red or brown drops on your underwear that do not require a thick pad.\n\nCauses of Spotting Outside Your Period:\n- Implantation Bleeding: Occurs 1–2 weeks after conception when the embryo attaches to the uterus.\n- Ovulation Bleeding: A mild hormone surge when the egg is released.\n- Contraceptive Effects: The start of using birth control pills or an IUD.",
                imageUrl: "assets/images/spotting2.jpeg",
                category: "Spotting vs Normal Flow",
              ),
            ],
          ),
          InsightCategory(
            title: "Heavy Bleeding (Menorrhagia)",
            bannerImage: "assets/images/heavy_bleeding.jpeg",
            articles: [
              // Di-update penuh dari GDocs
              Article(
                title: "Heavy Menstrual Bleeding (Menorrhagia) — Signs, Causes, and Treatment",
                summary: "Bleeding that is unusually heavy, lasts longer than expected, or interferes with everyday activities may indicate a condition that deserves medical attention.",
                content: """Introduction
Menstrual bleeding varies from person to person. Some people have relatively light periods, while others experience heavier bleeding.

However, bleeding that is unusually heavy, lasts longer than expected, or interferes with everyday activities may indicate a condition that deserves medical attention.

The term menorrhagia has traditionally been used to describe heavy menstrual bleeding. Today, healthcare professionals often use the broader term heavy menstrual bleeding to describe bleeding that significantly affects a person's physical, emotional, social, or practical quality of life.

Heavy periods are not something you should automatically accept as normal, especially when they leave you exhausted or interfere with daily activities. Treatment options are available, and the right approach depends on the underlying cause.

How Can You Recognize Heavy Menstrual Bleeding?
You may be experiencing heavy menstrual bleeding if you notice one or more of the following:
- You need to change your pad or tampon every one to two hours.
- You regularly need to use more than one menstrual product at a time.
- You pass large blood clots.
- Your period lasts longer than seven days.
- Bleeding frequently leaks through your clothes or bedding.
- You avoid activities because you are worried about bleeding.
- You feel unusually tired, weak, or short of breath.

What Causes Heavy Menstrual Bleeding?
1. Hormonal Changes: Changes in ovulation or hormonal balance can affect the pattern and amount of menstrual bleeding.
2. Uterine Fibroids and Polyps: Growths in or around the uterus/uterine lining.
3. Bleeding Disorders: Conditions affecting blood clotting.
4. Certain Medications and Contraceptives: Some medications can affect menstrual bleeding.
5. Other Medical Conditions: Conditions involving the uterus, ovaries, or hormonal system.

Why Is Heavy Bleeding a Health Concern?
Repeated blood loss can lead to iron deficiency and iron-deficiency anemia.
Possible symptoms include persistent fatigue, weakness, dizziness, headaches, pale skin, shortness of breath, and difficulty concentrating.

What Should You Do If Your Period Is Heavy?
1. Track Your Bleeding
2. Pay Attention to Your Energy Levels
3. Eat Iron-Rich Foods
4. Arrange a Medical Appointment

When Is Heavy Bleeding an Emergency?
Seek urgent medical care if you are bleeding heavily and feel faint, have significant dizziness or weakness, experience chest pain or shortness of breath, or soak through a pad/tampon every hour for two consecutive hours.

Final Thoughts
Heavy menstrual bleeding can affect both your physical health and your quality of life, but it is treatable.""",
                imageUrl: "assets/images/heavy1.jpeg",
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
            bannerImage: "assets/images/cramps.jpeg",
            articles: [
              // Menggabungkan seluruh materi relaksasi & kram dari GDocs ke dalam 2 artikel lengkap
              Article(
                title: "Relieving Period Discomfort — A Guide to Feeling Better During Your Period",
                summary: "Several simple self-care practices may help reduce discomfort and make your period easier to manage.",
                content: """Introduction
Menstruation is a natural part of the menstrual cycle, but that does not mean it always feels comfortable. For some people, their period comes with abdominal cramps, back pain, bloating, headaches, breast tenderness, fatigue, or changes in mood.

1. Use Heat Therapy to Relax Your Muscles
Applying warmth to your lower abdomen or lower back is one of the simplest ways to ease menstrual cramps. A heating pad, warm compress, or hot water bottle can help relax the muscles and make cramping feel more manageable.

2. Stay Hydrated Throughout the Day
Drinking enough water supports your body's normal functions and can help you feel better when you are menstruating.

3. Prioritize Rest and Quality Sleep
Fatigue is common around menstruation. Try to maintain a consistent sleep schedule and give yourself enough time to rest.

4. Eat Regular, Balanced Meals
Try to include a combination of carbohydrates, protein, healthy fats, fruits, and vegetables in your meals.

5. Choose Gentle Movement
Walking, gentle yoga, stretching, and light cycling may help some people feel more comfortable.

6. Create a Personal Period Comfort Kit
- Your preferred menstrual products.
- A spare pair of underwear.
- Pain-relief medication.
- A reusable heat pack or heat patch.
- Water and a snack.

7. Track Your Symptoms
Record when your period begins and ends, how intense your cramps are, and your energy levels.

When Should You Seek Medical Advice?
Seek medical advice if your pain is severe, gets progressively worse, or interferes with your daily activities.""",
                imageUrl: "assets/images/cramps1.jpeg",
                category: "Relieving Period Cramps",
              ),
              Article(
                title: "Period Cramps Explained — Causes, Relief, and When to Seek Help",
                summary: "Learn what causes menstrual cramps and which approaches may help make symptoms manageable.",
                content: """Introduction
Period cramps can feel like a dull ache, pressure, or tightening in the lower abdomen.

Why Do Period Cramps Happen?
During menstruation, the uterus contracts to help shed its lining. The body produces natural substances called prostaglandins that contribute to these contractions. Higher prostaglandin activity is associated with stronger uterine contractions (primary dysmenorrhea). Secondary dysmenorrhea is associated with underlying conditions like endometriosis or fibroids.

Practical Relief Options:
1. Apply Heat to the Lower Abdomen
2. Try Gentle Exercise and Stretching
3. Rest and Improve Your Sleep Routine
4. Consider Pain-Relief Medication Safely (NSAIDs)
5. Keep a Record of Your Pain

When Are Period Cramps a Warning Sign?
Seek medical advice if cramps regularly prevent you from attending school or work, if pain is severe/worsening, or if pain occurs outside menstruation.""",
                imageUrl: "assets/images/cramps2.jpeg",
                category: "Relieving Period Cramps",
              ),
            ],
          ),
          InsightCategory(
            title: "Managing Mood Swings",
            bannerImage: "assets/images/moodSwing.jpeg",
            articles: [
              // Di-update dari GDocs
              Article(
                title: "Managing Mood Swings Before and During Your Period",
                summary: "Understand PMS emotional symptoms and discover strategies like sleep protection, stress management, and clear communication to navigate mood changes.",
                content: """Introduction
Have you ever felt unusually emotional, irritable, anxious, or tired in the days before your period? These experiences can often be associated with premenstrual syndrome (PMS).

Why Can Your Mood Change Around Your Period?
Hormonal fluctuations throughout the menstrual cycle may influence the systems involved in mood regulation. Sleep quality, stress, physical discomfort, and personal circumstances also affect how you feel.

Practical Strategies:
1. Recognize Your Emotional Patterns
2. Protect Your Sleep
3. Move Your Body in Ways You Enjoy
4. Eat Regular, Balanced Meals
5. Practice Stress-Management Techniques
6. Communicate Your Needs

When Should You Seek Professional Support?
If mood symptoms consistently interfere with relationships, academic performance, work, or daily functioning, consider speaking with a healthcare professional (e.g., to evaluate for PMDD).""",
                imageUrl: "assets/images/mood.jpeg",
                category: "Managing Mood Swings",
              ),
            ],
          ),
          InsightCategory(
            title: "Nutrition & Diet Tips",
            bannerImage: "https://images.unsplash.com/photo-1498837167922-ddd27525d352?q=80&w=600&auto=format&fit=crop",
            articles: [
              // Di-update dari GDocs
              Article(
                title: "Nutrition and Diet Tips for a Healthier Menstrual Cycle",
                summary: "Focus on building consistent eating habits rich in iron, complex carbs, protein, calcium, and hydration to support your energy and digestion.",
                content: """Introduction
Food plays an important role in supporting your overall health throughout the menstrual cycle. A balanced diet can help provide the nutrients your body needs.

1. Include Iron-Rich Foods: Beef, fish, eggs, beans, lentils, tofu, tempeh, spinach. Pair plant iron with vitamin C.
2. Choose Complex Carbohydrates: Brown rice, oats, whole-grain bread, potatoes.
3. Get Enough Protein: Eggs, chicken, fish, tofu, tempeh, beans, yogurt.
4. Include Calcium-Rich Foods: Milk, yogurt, cheese, leafy greens.
5. Eat Fruits and Vegetables Regularly: Bananas, oranges, guava, spinach, carrots.
6. Stay Hydrated and Pay Attention to Bloating: Drink water regularly.
7. Understand Caffeine, Sugar, and Cravings: Aim for balance rather than strict avoidance.
8. Be Careful with Supplements and Menstrual Diet Trends: Discuss supplements with a qualified professional.

Example of a Balanced Day of Eating:
- Breakfast: Oatmeal with banana, yogurt, and nuts.
- Lunch: Rice, grilled fish or tempeh, and green vegetables.
- Snack: Guava or an orange with a handful of nuts.
- Dinner: Chicken, tofu, or beans with vegetables and rice or potatoes.""",
                imageUrl: "https://images.unsplash.com/photo-1498837167922-ddd27525d352?q=80&w=600&auto=format&fit=crop",
                category: "Nutrition & Diet Tips",
              ),
            ],
          ),
          InsightCategory(
            title: "Exercise & Stretches",
            bannerImage: "assets/images/Calm.jpeg",
            articles: [
              // Di-update dari GDocs
              Article(
                title: "Exercises and Stretches to Help You Feel Better During Your Period",
                summary: "Discover low-impact movements like walking, Child's Pose, Cat-Cow, and pelvic tilts to relieve muscle stiffness and pelvic tension.",
                content: """Introduction
Gentle physical activity can help some people manage menstrual discomfort and improve their mood.

1. Walking: A Simple Way to Stay Active (Start with 5-10 minutes at an easy pace).
2. Child's Pose: Kneel, lower upper body forward onto a mat, extend arms, and breathe slowly.
3. Cat-Cow Stretch: On hands and knees, gently arch back on inhale and round back on exhale.
4. Knees-to-Chest Stretch: Lie on back and draw knees gently toward chest for 15-30 seconds.
5. Gentle Seated Forward Fold: Sit with extended legs and lean forward from your hips.
6. Pelvic Tilts: Lie on back with knees bent and gently tilt pelvis to press lower back toward the floor.
7. Try Low-Impact Cardio: Swimming or stationary cycling at a comfortable intensity.

A Gentle 10-Minute Period Movement Routine:
1. Gentle walking or marching (2 min warm-up)
2. Cat-Cow Stretch (2 min)
3. Child's Pose (2 min)
4. Knees-to-Chest Stretch (2 min)
5. Slow breathing and rest (2 min)""",
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
