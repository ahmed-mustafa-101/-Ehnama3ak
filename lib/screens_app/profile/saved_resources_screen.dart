import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehnama3ak/screens_app/profile/presentation/cubit/profile_cubit.dart';
import 'package:ehnama3ak/screens_app/profile/presentation/cubit/profile_state.dart';

class SavedResourcesScreen extends StatefulWidget {
  const SavedResourcesScreen({super.key});

  @override
  State<SavedResourcesScreen> createState() => _SavedResourcesScreenState();
}

class _SavedResourcesScreenState extends State<SavedResourcesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadSavedResources();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Resources'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<ProfileCubit>().resetToProfile();
            Navigator.pop(context);
          },
        ),
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is SavedResourcesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ProfileCubit>().loadSavedResources(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is SavedResourcesSuccess) {
            if (state.resources.isEmpty) {
              return const Center(
                child: Text('No saved resources yet.', style: TextStyle(color: Colors.grey)),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.resources.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = state.resources[index];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: item.imageUrl.isNotEmpty
                          ? Image.network(item.imageUrl, width: 60, height: 60, fit: BoxFit.cover)
                          : Container(width: 60, height: 60, color: Colors.grey[300], child: const Icon(Icons.bookmark)),
                    ),
                    title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(item.type, style: const TextStyle(color: Colors.blueAccent)),
                    trailing: const Icon(Icons.open_in_new, color: Colors.grey),
                    onTap: () {
                       // could open URL but not strictly required
                    },
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
