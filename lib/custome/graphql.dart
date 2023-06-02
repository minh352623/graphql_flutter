import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';


class GraphQLDemo extends StatefulWidget {
  @override
  _GraphQLDemoState createState() => _GraphQLDemoState();
}

class _GraphQLDemoState extends State<GraphQLDemo> {
  final HttpLink httpLink = HttpLink(
      'https://hl-amadeus.dev-tn.com/graphql'); // Replace with your server URL
  String queryStart = '''
        query FetchHotels(\$keyword: String!) {
          hotels(keyword: \$keyword) {
      ''';
  String queryEnd = '''
          }
        }
      ''';
  String query = '';

  late GraphQLClient client;
  List<dynamic> hotels = [];
  List<dynamic> column = ['name', 'iataCode'];
  String _inputValue = '';
  @override
  void initState() {
    super.initState();

    client = GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(),
    );
    query = queryStart + column.join(', ').replaceAll(",", " ") + queryEnd;

    fetchData('', query);
  }

  Future<void> fetchData(String keyword, String query) async {
    final QueryOptions options = QueryOptions(
      document: gql(query),
      variables: {'keyword': keyword},
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      print(result.exception.toString());
    } else {
      setState(() {
        hotels = result.data!['hotels'];
      });
      print('hotels: $hotels');
    }
  }

  void _submitForm() {
    // Handle form submission logic here
    query = queryStart + column.join(', ').replaceAll(",", " ") + queryEnd;

    fetchData(_inputValue, query);
    print('Submitted: $_inputValue');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GraphQL Demo'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Form(
              child: TextField(
                onChanged: (value) => {
                  setState(() {
                    _inputValue = value;
                  })
                },
                decoration: InputDecoration(
                  labelText: 'Search',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
          ),
          Form(
            child: MultiSelectFormField(
              autovalidate: AutovalidateMode.disabled,
              title: Text("My workouts", style: TextStyle(fontSize: 16)),
              dataSource: [
                {"value": "distance", "display": "distance"},
                {"value": "hotelId", "display": "hotelId"},
                {"value": "dupeId", "display": "dupeId"},
                {"value": "name", "display": "name"},
                {"value": "iataCode", "display": "iataCode"},
              ],
              textField: 'display',
              valueField: 'value',
              okButtonLabel: 'OK',
              cancelButtonLabel: 'Cancel',
              hintWidget: Text('Select options'),
              initialValue: column,
              onSaved: (value) {
                if (value == null) return;
                setState(() {
                  column = value;
                });
              },
            ),
          ),
          ElevatedButton(
            onPressed: _submitForm,
            child: Text('Submit'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: hotels.length,
              itemBuilder: (context, index) {
                final item = hotels[index];
                  return Column(
                    children: [
                      ListTile(
                        title: Text(item['name']),
                        subtitle: Text(item['iataCode']),
                      ),
                      ListTile(
                        title: Text(item['hotelId']??"no item"),
                        subtitle: Text(item['dupeId'] ??"no dupeId"),
                      ),
                      ListTile(
                        title: Text(item['distance'].toString()??"no distance"),
                      ),
                      Text('---------------')
                    ],
                  );
             
              },
            ),
          ),
        ],
      ),
    );
  }
}
