import 'package:flutter/material.dart';
import 'socio_economic_result_page.dart';

class SocioEconomicSearchPage extends StatefulWidget {
  const SocioEconomicSearchPage({super.key});

  @override
  State<SocioEconomicSearchPage> createState() =>
      _SocioEconomicSearchPageState();
}

class _SocioEconomicSearchPageState extends State<SocioEconomicSearchPage> {
  String selectedCountry = 'Bahrain'; // Default selection
  String selectedEconomicIndicator = 'GDP'; // Default economic indicator
  String selectedIndustrialIndicator =
      'Manufacturing'; // Default industrial indicator

  final List<Map<String, String>> countries = [
    {'name': 'Bahrain', 'flag': 'assets/flags/bahrain.png'},
    {'name': 'Kuwait', 'flag': 'assets/flags/kuwait.png'},
    {'name': 'Oman', 'flag': 'assets/flags/oman.png'},
    {'name': 'Qatar', 'flag': 'assets/flags/qatar.png'},
    {'name': 'Saudi Arabia', 'flag': 'assets/flags/saudi.png'},
    {'name': 'UAE', 'flag': 'assets/flags/uae.png'},
    {'name': 'GCC', 'flag': 'assets/flags/gcc.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Socio-Economic Search'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 1,
            color: Colors.grey[100], // Very light gray
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: countries.map((country) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCountry = country['name']!;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8), // Add spacing between flags
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selectedCountry == country['name']
                                    ? Colors.blue
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              backgroundImage: AssetImage(country['flag']!),
                              radius: 30,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    decoration:
                        const InputDecoration(labelText: 'Economic Indicator'),
                    value: selectedEconomicIndicator,
                    onChanged: (newValue) {
                      setState(() {
                        selectedEconomicIndicator = newValue!;
                      });
                    },
                    items: <String>['GDP', 'Inflation', 'Unemployment']
                        .map<DropdownMenuItem<String>>((value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                        labelText: 'Industrial Indicator'),
                    value: selectedIndustrialIndicator,
                    onChanged: (newValue) {
                      setState(() {
                        selectedIndustrialIndicator = newValue!;
                      });
                    },
                    items: <String>['Manufacturing', 'Construction', 'Services']
                        .map<DropdownMenuItem<String>>((value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to result page with selected options
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SocioEconomicResultPage(
                            country: selectedCountry,
                            economicIndicator: selectedEconomicIndicator,
                            industrialIndicator: selectedIndustrialIndicator,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Background color
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Search',
                      style: TextStyle(color: Colors.white), // Text color
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
