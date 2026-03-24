import 'package:ehnama3ak/core/widgets/app_button.dart';
import 'package:ehnama3ak/core/utils/responsive.dart';
import 'package:ehnama3ak/screen_tap/help_screen/widgets/help_item.dart';
import 'package:ehnama3ak/screen_tap/help_screen/widgets/support_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ehnama3ak/features/help_support/presentation/controllers/help_cubit.dart';
import 'package:ehnama3ak/features/help_support/presentation/controllers/help_state.dart';

class DoctorHelpScreen extends StatefulWidget {
  const DoctorHelpScreen({super.key});

  @override
  State<DoctorHelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<DoctorHelpScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HelpCubit>().fetchContactInfo();
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not launch $url')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: BlocConsumer<HelpCubit, HelpState>(
        listener: (context, state) {
          if (state.status == HelpStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
            context.read<HelpCubit>().resetStatus();
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(Responsive.padding(context, 20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Help',
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 28),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: Responsive.spacing(context, 30)),

                HelpItem(
                  icon: Icons.help_outline,
                  title: 'FAQs',
                  subtitle: 'find answers to common questions',
                  onTap: () => _showFaqs(context),
                ),
                HelpItem(
                  icon: Icons.chat_bubble_outline,
                  title: 'Chat With Us',
                  subtitle: 'get support via live chat',
                  onTap: () => _launchUrl('https://wa.me/yournumber'),
                ),
                HelpItem(
                  icon: Icons.call_outlined,
                  title: 'Call Us',
                  subtitle: 'reach our support team',
                  onTap: () {
                    if (state.contactInfo != null) {
                      _launchUrl('tel:${state.contactInfo!.phone}');
                    }
                  },
                ),
                HelpItem(
                  icon: Icons.support_agent,
                  title: 'Support Tickets',
                  subtitle: 'manage your support requests',
                  onTap: () => _showTickets(context),
                ),
                SizedBox(height: Responsive.spacing(context, 30)),

                Center(
                  child: Text(
                    'Prefer To Email Or Call ?',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: Responsive.fontSize(context, 16),
                    ),
                  ),
                ),
                SizedBox(height: Responsive.spacing(context, 16)),

                // Responsive button layout
                screenWidth < 400
                    ? Column(
                        children: [
                          _emailButton(context),
                          SizedBox(height: Responsive.spacing(context, 12)),
                          _callButton(context, state.contactInfo?.phone),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(child: _emailButton(context)),
                          SizedBox(width: Responsive.spacing(context, 15)),
                          Expanded(
                            child: _callButton(
                              context,
                              state.contactInfo?.phone,
                            ),
                          ),
                        ],
                      ),
                SizedBox(height: Responsive.spacing(context, 30)),

                Text(
                  'Contact Support',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 18),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: Responsive.spacing(context, 16)),

                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.padding(context, 20),
                  ),
                  child: ContactItem(
                    icon: Icons.email,
                    text: state.contactInfo?.email ?? 'support@gmail.com',
                    onTap: () {
                      _launchUrl(
                        'mailto:${state.contactInfo?.email ?? 'support@gmail.com'}',
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.padding(context, 20),
                  ),
                  child: const Divider(),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.padding(context, 20),
                  ),
                  child: ContactItem(
                    icon: Icons.call,
                    text: state.contactInfo?.phone ?? '+44 123 456 789',
                    onTap: () {
                      _launchUrl(
                        'tel:${state.contactInfo?.phone ?? '+44123456789'}',
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _emailButton(BuildContext context) {
    return AppButton(
      label: 'Send Email',
      onPressed: () => _showSendEmailDialog(context),
      icon: Icons.email_rounded,
      height: Responsive.height(context, 0.05).clamp(40, 50),
      radius: Responsive.borderRadius(context, 10),
      iconSize: Responsive.iconSize(context, 15),
      textStyle: TextStyle(
        fontSize: Responsive.fontSize(context, 13),
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _callButton(BuildContext context, String? phone) {
    return AppButton(
      label: 'Call Us',
      onPressed: () {
        if (phone != null) _launchUrl('tel:$phone');
      },
      icon: Icons.call,
      height: Responsive.height(context, 0.05).clamp(40, 50),
      radius: Responsive.borderRadius(context, 10),
      iconSize: Responsive.iconSize(context, 15),
      textStyle: TextStyle(
        fontSize: Responsive.fontSize(context, 14),
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void _showFaqs(BuildContext context) {
    context.read<HelpCubit>().fetchFaqs();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocBuilder<HelpCubit, HelpState>(
        builder: (context, state) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'FAQs',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                Expanded(
                  child: state.status == HelpStatus.loading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: state.faqs.length,
                          itemBuilder: (context, index) {
                            final faq = state.faqs[index];
                            return ExpansionTile(
                              title: Text(
                                faq.question,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(faq.answer),
                                ),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showTickets(BuildContext context) {
    context.read<HelpCubit>().fetchUserTickets();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocBuilder<HelpCubit, HelpState>(
        builder: (context, state) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Support Tickets',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _showCreateTicketDialog(context),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: state.status == HelpStatus.loading
                      ? const Center(child: CircularProgressIndicator())
                      : state.tickets.isEmpty
                      ? const Center(child: Text('No tickets found'))
                      : ListView.builder(
                          itemCount: state.tickets.length,
                          itemBuilder: (context, index) {
                            final ticket = state.tickets[index];
                            return ListTile(
                              title: Text(ticket.subject),
                              subtitle: Text(ticket.description),
                              trailing: Chip(label: Text(ticket.status)),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCreateTicketDialog(BuildContext context) {
    final subjectController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (diagContext) => AlertDialog(
        title: const Text('Create Ticket'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(labelText: 'Subject'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(diagContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<HelpCubit>().createTicket(
                subjectController.text,
                descController.text,
              );
              Navigator.pop(diagContext);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showSendEmailDialog(BuildContext context) {
    final subjectController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (diagContext) => AlertDialog(
        title: const Text('Send Support Email'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(labelText: 'Subject'),
            ),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(labelText: 'Message'),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(diagContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<HelpCubit>().sendSupportEmail(
                subjectController.text,
                messageController.text,
              );
              Navigator.pop(diagContext);
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
