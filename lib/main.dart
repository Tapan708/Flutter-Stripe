import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'models/course.dart';
import 'screens/course_detail_screen.dart';
import 'config/stripe_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = StripeConfig.publishableKey;
  await Stripe.instance.applySettings();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Learn Stripes'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Course> courses = [
    Course(
      id: 1,
      name: 'Flutter',
      image: 'https://cdn.iconscout.com/icon/free/png-256/flutter-2038877-1720090.png',
      chapters: ['Introduction to Flutter', 'Widgets', 'State Management', 'Navigation', 'API Integration'],
    ),
    Course(
      id: 2,
      name: 'Java',
      image: 'https://cdn.iconscout.com/icon/free/png-256/java-43-569305.png',
      chapters: ['Java Basics', 'OOP Concepts', 'Collections', 'Exception Handling', 'Multithreading'],
    ),
    Course(
      id: 3,
      name: 'Python',
      image: 'https://cdn.iconscout.com/icon/free/png-256/python-3521655-2945099.png',
      chapters: ['Python Syntax', 'Data Structures', 'Functions', 'Modules', 'File Handling'],
    ),
    Course(
      id: 4,
      name: 'React',
      image: 'https://cdn.iconscout.com/icon/free/png-256/react-1-282599.png',
      chapters: ['React Basics', 'Components', 'Props & State', 'Hooks', 'Context API'],
    ),
    Course(
      id: 5,
      name: 'Node.js',
      image: 'https://cdn.iconscout.com/icon/free/png-256/nodejs-2-226035.png',
      chapters: ['Node.js Basics', 'Express.js', 'Database Integration', 'Authentication', 'Deployment'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CourseDetailScreen(course: course),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Image.network(
                      course.image,
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.code,
                          size: 60,
                          color: Colors.grey,
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    Text(
                      course.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
