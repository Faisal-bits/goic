import 'package:flutter/material.dart';
import 'socio_economic_result_page.dart'; // Assume this is the results page

class SocioEconomicSearchPage extends StatefulWidget {
  @override
  _SocioEconomicSearchPageState createState() =>
      _SocioEconomicSearchPageState();
}

class _SocioEconomicSearchPageState extends State<SocioEconomicSearchPage> {
  String selectedCountry = 'Bahrain'; // Default value
  String selectedEconomicIndicator = 'GDP'; // Default value
  String selectedComparisonMode = 'Yearly'; // Default value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Socio-Economic Search')),
      body: Column(
        children: [
          Wrap(
            // Displaying GCC countries in circles
            spacing: 10,
            children: List.generate(6, (index) {
              // Example country list, replace with actual
              List<String> countries = [
                'Bahrain',
                'Kuwait',
                'Oman',
                'Qatar',
                'Saudi Arabia',
                'UAE'
              ];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCountry = countries[index];
                  });
                },
                child: CircleAvatar(
                  child:
                      Text(countries[index][0]), // First letter of country name
                ),
              );
            }),
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
          // Add similar DropdownButton for selectedComparisonMode
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SocioEconomicResultPage(
                        selectedCountry, selectedEconomicIndicator)),
              );
            },
            child: Text('Search'),
          ),
        ],
      ),
    );
  }
}
