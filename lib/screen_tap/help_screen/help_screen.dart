import 'package:ehnama3ak/core/widgets/app_button.dart';
import 'package:ehnama3ak/core/utils/responsive.dart';
import 'package:ehnama3ak/core/localization/app_localizations.dart';
import 'package:ehnama3ak/screen_tap/help_screen/widgets/support_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ehnama3ak/features/help_support/presentation/controllers/help_cubit.dart';
import 'package:ehnama3ak/features/help_support/presentation/controllers/help_state.dart';
import 'widgets/help_item.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});
  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HelpCubit>().fetchContactInfo();
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: BlocConsumer<HelpCubit, HelpState>(
        listener: (context, state) {
          if (state.status == HelpStatus.failure && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!), backgroundColor: Colors.red),
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
                  child: Text(l10n.helpTitle,
                      style: TextStyle(fontSize: Responsive.fontSize(context, 28), fontWeight: FontWeight.w600)),
                ),
                SizedBox(height: Responsive.spacing(context, 30)),
                HelpItem(
                  icon: Icons.help_outline,
                  title: l10n.faqs,
                  subtitle: l10n.findAnswers,
                  onTap: () => _showFaqs(context, l10n),
                ),
                HelpItem(
                  icon: Icons.chat_bubble_outline,
                  title: l10n.chatWithUs,
                  subtitle: l10n.getSupportChat,
                  onTap: () => _launchUrl('https://wa.me/yournumber'),
                ),
                HelpItem(
                  icon: Icons.call_outlined,
                  title: l10n.callUs,
                  subtitle: l10n.reachSupport,
                  onTap: () {
                    if (state.contactInfo != null) _launchUrl('tel:${state.contactInfo!.phone}');
                  },
                ),
                HelpItem(
                  icon: Icons.support_agent,
                  title: l10n.supportTickets,
                  subtitle: l10n.manageRequests,
                  onTap: () => _showTickets(context, l10n),
                ),
                SizedBox(height: Responsive.spacing(context, 30)),
                Center(
                  child: Text(l10n.preferEmailOrCall,
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: Responsive.fontSize(context, 16))),
                ),
                SizedBox(height: Responsive.spacing(context, 16)),
                screenWidth < 400
                    ? Column(children: [
                        _emailButton(context, l10n),
                        SizedBox(height: Responsive.spacing(context, 12)),
                        _callButton(context, state.contactInfo?.phone, l10n),
                      ])
                    : Row(children: [
                        Expanded(child: _emailButton(context, l10n)),
                        SizedBox(width: Responsive.spacing(context, 15)),
                        Expanded(child: _callButton(context, state.contactInfo?.phone, l10n)),
                      ]),
                SizedBox(height: Responsive.spacing(context, 30)),
                Text(l10n.contactSupport,
                    style: TextStyle(fontSize: Responsive.fontSize(context, 18), fontWeight: FontWeight.w600)),
                SizedBox(height: Responsive.spacing(context, 16)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.padding(context, 20)),
                  child: ContactItem(
                    icon: Icons.email,
                    text: state.contactInfo?.email ?? 'support@gmail.com',
                    onTap: () => _launchUrl('mailto:${state.contactInfo?.email ?? 'support@gmail.com'}'),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.padding(context, 20)),
                  child: const Divider(),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.padding(context, 20)),
                  child: ContactItem(
                    icon: Icons.call,
                    text: state.contactInfo?.phone ?? '+44 123 456 789',
                    onTap: () => _launchUrl('tel:${state.contactInfo?.phone ?? '+44123456789'}'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _emailButton(BuildContext context, AppLocalizations l10n) {
    return AppButton(
      label: l10n.sendEmail,
      onPressed: () => _showSendEmailDialog(context, l10n),
      icon: Icons.email_rounded,
      height: Responsive.height(context, 0.05).clamp(40, 50),
      radius: Responsive.borderRadius(context, 10),
      iconSize: Responsive.iconSize(context, 15),
      textStyle: TextStyle(fontSize: Responsive.fontSize(context, 13), color: Colors.white, fontWeight: FontWeight.bold),
    );
  }

  Widget _callButton(BuildContext context, String? phone, AppLocalizations l10n) {
    return AppButton(
      label: l10n.callUs,
      onPressed: () { if (phone != null) _launchUrl('tel:$phone'); },
      icon: Icons.call,
      height: Responsive.height(context, 0.05).clamp(40, 50),
      radius: Responsive.borderRadius(context, 10),
      iconSize: Responsive.iconSize(context, 15),
      textStyle: TextStyle(fontSize: Responsive.fontSize(context, 14), color: Colors.white, fontWeight: FontWeight.bold),
    );
  }

  void _showFaqs(BuildContext context, AppLocalizations l10n) {
    context.read<HelpCubit>().fetchFaqs();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocBuilder<HelpCubit, HelpState>(
        builder: (context, state) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            Text(l10n.faqs, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: state.status == HelpStatus.loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: state.faqs.length,
                      itemBuilder: (context, index) {
                        final faq = state.faqs[index];
                        return ExpansionTile(
                          title: Text(faq.question, style: const TextStyle(fontWeight: FontWeight.bold)),
                          children: [Padding(padding: const EdgeInsets.all(16), child: Text(faq.answer))],
                        );
                      },
                    ),
            ),
          ]),
        ),
      ),
    );
  }

  void _showTickets(BuildContext context, AppLocalizations l10n) {
    context.read<HelpCubit>().fetchUserTickets();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocBuilder<HelpCubit, HelpState>(
        builder: (context, state) => Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.supportTickets, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.add), onPressed: () => _showCreateTicketDialog(context, l10n)),
              ],
            ),
            const Divider(),
            Expanded(
              child: state.status == HelpStatus.loading
                  ? const Center(child: CircularProgressIndicator())
                  : state.tickets.isEmpty
                      ? Center(child: Text(l10n.noTicketsFound))
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
          ]),
        ),
      ),
    );
  }

  void _showCreateTicketDialog(BuildContext context, AppLocalizations l10n) {
    final subjectCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (diagContext) => AlertDialog(
        title: Text(l10n.createTicket),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: subjectCtrl, decoration: InputDecoration(labelText: l10n.subject)),
            TextField(controller: descCtrl, decoration: InputDecoration(labelText: l10n.descriptionLabel), maxLines: 3),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(diagContext), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () {
              context.read<HelpCubit>().createTicket(subjectCtrl.text, descCtrl.text);
              Navigator.pop(diagContext);
            },
            child: Text(l10n.submit),
          ),
        ],
      ),
    );
  }

  void _showSendEmailDialog(BuildContext context, AppLocalizations l10n) {
    final subjectCtrl = TextEditingController();
    final messageCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (diagContext) => AlertDialog(
        title: Text(l10n.sendSupportEmail),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: subjectCtrl, decoration: InputDecoration(labelText: l10n.subject)),
            TextField(controller: messageCtrl, decoration: InputDecoration(labelText: l10n.messageLabel), maxLines: 5),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(diagContext), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () {
              context.read<HelpCubit>().sendSupportEmail(subjectCtrl.text, messageCtrl.text);
              Navigator.pop(diagContext);
            },
            child: Text(l10n.send),
          ),
        ],
      ),
    );
  }
}
