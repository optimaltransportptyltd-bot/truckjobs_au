import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const TruckJobsApp());
}

class TruckJobsApp extends StatelessWidget {
  const TruckJobsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TruckJobs AU',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class Job {
  final String id;
  final String status;
  final String title;
  final String company;
  final String location;
  final String licence;
  final String pay;
  final String type;
  final String contact;
  final String description;
  final bool isUrgent;

  const Job({
    this.id = '',
    this.status = 'pending',
    required this.title,
    required this.company,
    required this.location,
    required this.licence,
    required this.pay,
    required this.type,
    required this.contact,
    required this.description,
    required this.isUrgent,
  });

   factory Job.fromFirestore(String id, Map<String, dynamic> data) {
  return Job(
    id: id,
    title: data['title'] ?? '',
    company: data['company'] ?? '',
    location: data['location'] ?? '',
    licence: data['licence'] ?? '',
    pay: data['pay'] ?? 'Pay not listed',
    type: data['type'] ?? '',
    contact: data['contact'] ?? '',
    description: data['description'] ?? 'No description added.',
    isUrgent: data['isUrgent'] ?? false,
    status: data['status'] ?? 'pending',
  );
}
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  final List<Job> jobs = [];
  final List<Job> savedJobs = [];

  void addJob(Job job) {
    setState(() {
      selectedIndex = 0;
    });
  }

  void saveJob(Job job) {
    final alreadySaved = savedJobs.any(
      (savedJob) =>
          savedJob.title == job.title &&
          savedJob.company == job.company &&
          savedJob.contact == job.contact,
    );

    if (!alreadySaved) {
      setState(() {
        savedJobs.add(job);
      });
    }
  }

  void removeSavedJob(Job job) {
    setState(() {
      savedJobs.remove(job);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      JobsPage(jobs: jobs, onSaveJob: saveJob),
      PostJobPage(onJobSubmit: addJob),
      SavedJobsPage(savedJobs: savedJobs, onRemoveJob: removeSavedJob),
      const AdminPinPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('TruckJobs AU'),
      ),
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Jobs'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Post Job',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: 'Admin',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
class JobsPage extends StatefulWidget {
  final List<Job> jobs;
  final Function(Job) onSaveJob;

  const JobsPage({
    super.key,
    required this.jobs,
    required this.onSaveJob,
  });

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  String searchText = '';
  String selectedLicence = 'All';

  Future<void> callEmployer(String phoneNumber) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> whatsappEmployer(Job job) async {
    final cleanNumber = job.contact.replaceAll(' ', '');

    final ausNumber = cleanNumber.startsWith('0')
        ? '61${cleanNumber.substring(1)}'
        : cleanNumber;

    final message =
        'Hi, I am interested in the job: ${job.title} at ${job.company}. Is this job still available?';

    final Uri whatsappUri = Uri.parse(
      'https://wa.me/$ausNumber?text=${Uri.encodeComponent(message)}',
    );

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  Future<void> reportJob(Job job, BuildContext context) async {
    await FirebaseFirestore.instance.collection('reports').add({
      'jobId': job.id,
      'jobTitle': job.title,
      'company': job.company,
      'contact': job.contact,
      'reason': 'Reported by user',
      'createdAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Job reported. Thank you.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
     stream: FirebaseFirestore.instance
    .collection('jobs')
    .where('status', isEqualTo: 'approved')
    .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong loading jobs'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final firebaseJobs = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Job.fromFirestore(doc.id, data);
        }).toList();

        final filteredJobs = firebaseJobs.where((job) {
          final searchLower = searchText.toLowerCase();

          final matchesSearch = job.title.toLowerCase().contains(searchLower) ||
              job.company.toLowerCase().contains(searchLower) ||
              job.location.toLowerCase().contains(searchLower) ||
              job.licence.toLowerCase().contains(searchLower);

          final matchesLicence =
              selectedLicence == 'All' || job.licence.contains(selectedLicence);

          return matchesSearch && matchesLicence;
        }).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Find trucking jobs across Australia',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by city, licence or job title',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  filterChip('All'),
                  filterChip('MR'),
                  filterChip('HR'),
                  filterChip('HC'),
                  filterChip('MC'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Latest Jobs',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text('${filteredJobs.length} found'),
              ],
            ),

            const SizedBox(height: 10),

            if (filteredJobs.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(
                  child: Text(
                    'No jobs found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
              ),

            for (final job in filteredJobs) jobCard(context, job),
          ],
        );
      },
    );
  }

  Widget filterChip(String text) {
    final bool isSelected = selectedLicence == text;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(text),
        selected: isSelected,
        selectedColor: Colors.orange,
        backgroundColor: Colors.orange.shade100,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
        onSelected: (selected) {
          setState(() {
            selectedLicence = text;
          });
        },
      ),
    );
  }

  Widget jobCard(BuildContext context, Job job) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    job.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (job.isUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'URGENT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 6),

            Text(job.company),

            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(Icons.location_on, size: 18),
                const SizedBox(width: 4),
                Text(job.location),
              ],
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              children: [
                Chip(label: Text(job.licence)),
                Chip(label: Text(job.pay)),
                Chip(label: Text(job.type)),
              ],
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  showJobDetails(context, job);
                },
                child: const Text('View Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showJobDetails(BuildContext context, Job job) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      job.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (job.isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'URGENT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 10),

              Text(job.company),

              const SizedBox(height: 16),

              detailRow(Icons.location_on, 'Location', job.location),
              detailRow(Icons.badge, 'Licence', job.licence),
              detailRow(Icons.payments, 'Pay', job.pay),
              detailRow(Icons.work, 'Job Type', job.type),
              detailRow(Icons.phone, 'Contact', job.contact),

              const SizedBox(height: 16),

              const Text(
                'Job Description',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 6),

              Text(job.description),

              const SizedBox(height: 20),

ElevatedButton.icon(
  onPressed: () {
    callEmployer(job.contact);
  },
  icon: const Icon(Icons.phone),
  label: const Text('Call Employer'),
),

const SizedBox(height: 10),

ElevatedButton.icon(
  onPressed: () {
    whatsappEmployer(job);
  },
  icon: const Icon(Icons.chat),
  label: const Text('Apply on WhatsApp'),
),

const SizedBox(height: 10),

OutlinedButton.icon(
  onPressed: () {
    widget.onSaveJob(job);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Job saved')),
    );
  },
  icon: const Icon(Icons.bookmark),
  label: const Text('Save Job'),
),

const SizedBox(height: 10),

OutlinedButton.icon(
  onPressed: () {
    reportJob(job, context);
    Navigator.pop(context);
  },
  icon: const Icon(Icons.report),
  label: const Text('Report Job'),
),
            ],
          ),
        );
      },
    );
  }

  Widget detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange),
          const SizedBox(width: 10),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
class PostJobPage extends StatefulWidget {
  final Function(Job) onJobSubmit;

  const PostJobPage({super.key, required this.onJobSubmit});

  @override
  State<PostJobPage> createState() => _PostJobPageState();
}

class _PostJobPageState extends State<PostJobPage> {
  final titleController = TextEditingController();
  final companyController = TextEditingController();
  final cityController = TextEditingController();
  final payController = TextEditingController();
  final contactController = TextEditingController();
  final descriptionController = TextEditingController();

  String selectedLicence = 'MR';
  String selectedState = 'VIC';
  String selectedJobType = 'Full Time';
  bool isUrgent = false;

  final List<String> licences = ['MR', 'HR', 'HC', 'MC'];
  final List<String> states = [
    'VIC',
    'NSW',
    'QLD',
    'SA',
    'WA',
    'TAS',
    'NT',
    'ACT',
  ];

  final List<String> jobTypes = [
    'Full Time',
    'Part Time',
    'Casual',
    'ABN',
    'Owner Driver',
  ];

  Future<void> submitJob() async {
  if (titleController.text.isEmpty ||
      companyController.text.isEmpty ||
      cityController.text.isEmpty ||
      contactController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill required fields')),
    );
    return;
  }

  final newJob = Job(
    title: titleController.text.trim(),
    company: companyController.text.trim(),
    location: '${cityController.text.trim()}, $selectedState',
    licence: selectedLicence,
    pay: payController.text.trim().isEmpty
        ? 'Pay not listed'
        : payController.text.trim(),
    type: selectedJobType,
    contact: contactController.text.trim(),
    description: descriptionController.text.trim().isEmpty
        ? 'No description added.'
        : descriptionController.text.trim(),
    isUrgent: isUrgent,
  );

  await FirebaseFirestore.instance.collection('jobs').add({
    'title': newJob.title,
    'company': newJob.company,
    'location': newJob.location,
    'licence': newJob.licence,
    'pay': newJob.pay,
    'type': newJob.type,
    'contact': newJob.contact,
    'description': newJob.description,
    'isUrgent': newJob.isUrgent,
    'status': 'pending',
    'createdAt': FieldValue.serverTimestamp(),
  });

  widget.onJobSubmit(newJob);

  titleController.clear();
  companyController.clear();
  cityController.clear();
  payController.clear();
  contactController.clear();
  descriptionController.clear();

  setState(() {
    selectedLicence = 'MR';
    selectedState = 'VIC';
    selectedJobType = 'Full Time';
    isUrgent = false;
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Job saved to Firebase')),
  );
}

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Post a Trucking Job',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        const Text(
          'Add job details. Later we will connect this to Firebase and admin approval.',
          style: TextStyle(color: Colors.grey),
        ),

        const SizedBox(height: 20),

        inputField('Job title *', Icons.work, titleController),
        inputField('Company name *', Icons.business, companyController),
        inputField(
          'City e.g. Melbourne *',
          Icons.location_city,
          cityController,
        ),

        dropdownField(
          label: 'State',
          icon: Icons.map,
          value: selectedState,
          items: states,
          onChanged: (value) {
            setState(() {
              selectedState = value!;
            });
          },
        ),

        dropdownField(
          label: 'Licence needed',
          icon: Icons.badge,
          value: selectedLicence,
          items: licences,
          onChanged: (value) {
            setState(() {
              selectedLicence = value!;
            });
          },
        ),

        inputField(
          'Pay rate e.g. \$45/hr or \$550/day',
          Icons.payments,
          payController,
        ),

        dropdownField(
          label: 'Job type',
          icon: Icons.schedule,
          value: selectedJobType,
          items: jobTypes,
          onChanged: (value) {
            setState(() {
              selectedJobType = value!;
            });
          },
        ),

        inputField('Contact phone number *', Icons.phone, contactController),

        SwitchListTile(
          title: const Text('Mark as urgent job'),
          subtitle: const Text('Urgent jobs will show a red badge'),
          value: isUrgent,
          activeThumbColor: Colors.orange,
          onChanged: (value) {
            setState(() {
              isUrgent = value;
            });
          },
        ),

        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: TextField(
            controller: descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Job description',
              prefixIcon: const Icon(Icons.description),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        ElevatedButton(
          onPressed: submitJob,
          child: const Padding(
            padding: EdgeInsets.all(14),
            child: Text('Submit Job'),
          ),
        ),
      ],
    );
  }

  Widget inputField(
    String hint,
    IconData icon,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget dropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class SavedJobsPage extends StatelessWidget {
  final List<Job> savedJobs;
  final Function(Job) onRemoveJob;

  const SavedJobsPage({
    super.key,
    required this.savedJobs,
    required this.onRemoveJob,
  });

  @override
  Widget build(BuildContext context) {
    if (savedJobs.isEmpty) {
      return const Center(
        child: Text(
          'Saved jobs will appear here',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Saved Jobs',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        for (final job in savedJobs)
          Card(
            margin: const EdgeInsets.only(bottom: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              title: Text(job.title),
              subtitle: Text('${job.company} • ${job.location}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  onRemoveJob(job);
                },
              ),
            ),
          ),
      ],
    );
  }
}
class AdminPinPage extends StatefulWidget {
  const AdminPinPage({super.key});

  @override
  State<AdminPinPage> createState() => _AdminPinPageState();
}

class _AdminPinPageState extends State<AdminPinPage> {
  final pinController = TextEditingController();
  bool isUnlocked = false;

  void checkPin() {
    if (pinController.text.trim() == '2329') {
      setState(() {
        isUnlocked = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wrong admin PIN')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isUnlocked) {
      return const AdminPage();
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.admin_panel_settings,
            size: 70,
            color: Colors.orange,
          ),
          const SizedBox(height: 20),
          const Text(
            'Admin Access',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Enter admin PIN to approve or reject jobs.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: pinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Admin PIN',
              prefixIcon: const Icon(Icons.lock),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: checkPin,
              child: const Text('Unlock Admin'),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  Future<void> approveJob(String jobId, BuildContext context) async {
    await FirebaseFirestore.instance.collection('jobs').doc(jobId).update({
      'status': 'approved',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Job approved')),
    );
  }

  Future<void> rejectJob(String jobId, BuildContext context) async {
    await FirebaseFirestore.instance.collection('jobs').doc(jobId).update({
      'status': 'rejected',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Job rejected')),
    );
  }

  Future<void> deleteReport(String reportId, BuildContext context) async {
    await FirebaseFirestore.instance.collection('reports').doc(reportId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report removed')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Admin Dashboard',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 20),

        const Text(
          'Pending Jobs',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('jobs')
              .where('status', isEqualTo: 'pending')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Error loading pending jobs');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final pendingJobs = snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Job.fromFirestore(doc.id, data);
            }).toList();

            if (pendingJobs.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No pending jobs'),
                ),
              );
            }

            return Column(
              children: [
                for (final job in pendingJobs)
                  Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(job.company),
                          const SizedBox(height: 8),
                          Text(job.location),
                          const SizedBox(height: 8),
                          Text('Licence: ${job.licence}'),
                          Text('Pay: ${job.pay}'),
                          Text('Type: ${job.type}'),
                          Text('Contact: ${job.contact}'),
                          const SizedBox(height: 10),
                          Text(job.description),
                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    approveJob(job.id, context);
                                  },
                                  icon: const Icon(Icons.check),
                                  label: const Text('Approve'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    rejectJob(job.id, context);
                                  },
                                  icon: const Icon(Icons.close),
                                  label: const Text('Reject'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),

        const SizedBox(height: 30),

        const Text(
          'Reported Jobs',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('reports')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Error loading reports');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final reports = snapshot.data!.docs;

            if (reports.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No reported jobs'),
                ),
              );
            }

            return Column(
              children: [
                for (final report in reports)
                  Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Builder(
                        builder: (context) {
                          final data = report.data() as Map<String, dynamic>;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Reported Job',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text('Job: ${data['jobTitle'] ?? 'Unknown'}'),
                              Text('Company: ${data['company'] ?? 'Unknown'}'),
                              Text('Contact: ${data['contact'] ?? 'Unknown'}'),
                              Text('Reason: ${data['reason'] ?? 'Reported by user'}'),
                              const SizedBox(height: 12),

                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    deleteReport(report.id, context);
                                  },
                                  icon: const Icon(Icons.delete),
                                  label: const Text('Remove Report'),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        CircleAvatar(
          radius: 45,
          child: Icon(Icons.person, size: 50),
        ),

        SizedBox(height: 16),

        Center(
          child: Text(
            'Driver / Employer Profile',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),

        SizedBox(height: 20),

        Card(
          child: ListTile(
            leading: Icon(Icons.person),
            title: Text('Name'),
            subtitle: Text('Add your name later'),
          ),
        ),

        Card(
          child: ListTile(
            leading: Icon(Icons.badge),
            title: Text('Licence'),
            subtitle: Text('MR / HR / HC / MC'),
          ),
        ),

        Card(
          child: ListTile(
            leading: Icon(Icons.location_on),
            title: Text('Location'),
            subtitle: Text('Australia'),
          ),
        ),
      ],
    );
  }
}