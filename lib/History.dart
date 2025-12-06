import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:library_app/providers/Reservation_history_provider.dart';
import 'package:library_app/BookDetailsPage.dart';
import 'package:library_app/Pages/MainPage.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Library App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const UserHistoryPage(),
    );
  }
}

class UserHistoryPage extends ConsumerWidget {
  const UserHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(reservationHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Your Reservations")),
      endDrawer: _buildMenuDrawer(context),
      body: historyAsync.when(
        data: (data) {
          if (data.isEmpty) {
            return const Center(child: Text("No reservations found."));
          }

          final current = data["current"] ?? [];
          final upcoming = data["upcoming"] ?? [];
          final past = data["past"] ?? [];
          final rents = data["rentHistory"] ?? [];

          return DefaultTabController(
            length: 4,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: "Current"),
                    Tab(text: "Upcoming"),
                    Tab(text: "Past"),
                    Tab(text: "Rents"),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      buildList(current),
                      buildList(upcoming),
                      buildList(past),
                      buildRentList(rents),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text("Error: $err")),
      ),
    );
  }

  Widget _buildMenuDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(13),
          children: [
            const Text(
              "Menu",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text("Reservations"),
              onTap: () {
                Navigator.pop(context); // close drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.library_books),
              title: const Text("Browse Books"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                ); // close drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.support_agent),
              title: const Text("Support"),
              onTap: () {
                Navigator.pop(context); // close drawer
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildList(List reservations) {
    if (reservations.isEmpty) {
      return const Center(child: Text("No records"));
    }

    return ListView.builder(
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        final r = reservations[index];
        return Card(
          margin: const EdgeInsets.all(10),
          child: ListTile(
            title: Text(r["BookTitle"] ?? "Unknown Title"),
            subtitle: Text(
              "From: ${r["StartDate"] ?? "Unknown"}\nTo: ${r["DueDate"] ?? "Unknown"}",
            ),
          ),
        );
      },
    );
  }

  Widget buildRentList(List rents) {
    if (rents.isEmpty) {
      return const Center(child: Text("No rent history"));
    }

    return ListView.builder(
      itemCount: rents.length,
      itemBuilder: (context, index) {
        final r = rents[index];
        return Card(
          margin: const EdgeInsets.all(10),
          child: ListTile(
            title: Text(r["BookTitle"] ?? "Unknown Title"),
            subtitle: Text(
              "Rented: ${r["RentDate"] ?? "Unknown"}\nReturned: ${r["ReturnDate"] ?? "Not returned"}",
            ),
          ),
        );
      },
    );
  }
}
