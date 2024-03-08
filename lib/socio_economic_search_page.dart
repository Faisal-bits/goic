import 'package:flutter/material.dart';
import 'socio_economic_result_page.dart'; // Ensure this file exists

class SocioEconomicSearchPage extends StatefulWidget {
  @override
  _SocioEconomicSearchPageState createState() =>
      _SocioEconomicSearchPageState();
}

class _SocioEconomicSearchPageState extends State<SocioEconomicSearchPage> {
  String selectedCountry = 'Bahrain'; // Default selection
  String selectedEconomicIndicator = 'GDP'; // Default economic indicator

  final List<Map<String, String>> countries = [
    {'name': 'Bahrain', 'flag': 'assets/flags/bahrain.png'},
    {'name': 'Kuwait', 'flag': 'assets/flags/kuwait.jpeg'},
    {'name': 'Oman', 'flag': 'assets/flags/oman.jpeg'},
    {'name': 'Qatar', 'flag': 'assets/flags/qatar.png'},
    {'name': 'Saudi Arabia', 'flag': 'assets/flags/saudi.jpeg'},
    {'name': 'UAE', 'flag': 'assets/flags/uae.jpeg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Socio-Economic Search'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 20,
                runSpacing: 20,
                children: countries.map((country) {
                  bool isSelected = selectedCountry == country['name'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCountry = country['name']!;
                      });
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(isSelected
                              ? 2
                              : 0), // Padding for the border effect
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.black, width: 2)
                                : null,
                          ),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage(country['flag']!),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          country['name']!,
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: isSelected ? Colors.black : null,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              Text(
                "Select an Economic Indicator",
                style: Theme.of(context).textTheme.headline6,
              ),
              DropdownButton<String>(
                value: selectedEconomicIndicator,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedEconomicIndicator = newValue!;
                  });
                },
                items: <String>['GDP', 'Inflation', 'Unemployment']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SocioEconomicResultPage(
                          selectedCountry, selectedEconomicIndicator),
                    ),
                  );
                },
                child: Text('Search'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue[
                      700], // Use a specific shade of blue to match your app theme
                  onPrimary: Colors.white, // foreground
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
