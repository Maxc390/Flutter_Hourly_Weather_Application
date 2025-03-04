import 'dart:convert';
import 'dart:ui';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/hourly_forecast_item.dart';
import 'package:weather_app/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String city = 'Juja';
  late Future weather;
  Future getCurrentWeather() async {
    try {
      final res = await http.get(Uri.parse(
          'http://api.openweathermap.org/data/2.5/forecast?q=$city&APPID=$openWeatherApiKey'));
      final data = jsonDecode(res.body);
      if (data['cod'] != '200') {
        throw data['message'];
      }
      return data;
      // temp = data['list'][0]['main']['temp'];
    } catch (e) {
      e.toString();
    }
    // print(res?.body);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    weather = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleTextStyle:
            const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        centerTitle: true,
        title: const Text('Weather App'),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  weather = getCurrentWeather();
                });
              },
              icon: const Icon(Icons.refresh))
        ],
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          final data = snapshot.data!;
          final currentWeather = data['list'][0];
          // final forecastlist = data['list'];
          final currentTemp = currentWeather['main']['temp'];
          final currentSky = currentWeather['weather'][0]['main'];
          final currentPressure = currentWeather['main']['pressure'];
          final humidity = currentWeather['main']['humidity'];
          final windSpeed = currentWeather['wind']['speed'];
          // print(currentWeather);
          // print(forecastlist);
          // print(windSpeed);
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Icon(Icons.location_on), Text(city)],
                    ),
                  ),
                ),
                //maincard
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                '${(currentTemp - 273.15).toStringAsFixed(2)}°C',
                                style: const TextStyle(
                                    fontSize: 32, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              Icon(
                                currentSky == 'Clouds' || currentSky == 'Rain'
                                    ? Icons.cloud
                                    : Icons.sunny,
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                currentSky,
                                style: const TextStyle(fontSize: 20),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                //weather forecast

                const Text(
                  'Hourly ForeCast',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     children: [
                //       for (int i = 1; i < 6; i++)
                //         HourlyForecastItem(
                //           icon: forecastlist[i]['weather'][0]['main'] ==
                //                       'Clouds' ||
                //                   forecastlist[i]['weather'][0]['main'] ==
                //                       'Rain'
                //               ? Icons.cloud
                //               : Icons.sunny,
                //           time: forecastlist[i]['dt'].toString(),
                //           temperature:
                //               forecastlist[i]['main']['temp'].toString(),
                //         )
                //     ],
                //   ),
                // ),
                // RenderBox
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        final hourlyForeCast = data['list'][index + 1];
                        final hourlyTemp =
                            '${(hourlyForeCast['main']['temp'] - 273.15).toStringAsFixed(2)}°C';

                        final hourlySky =
                            data['list'][index + 1]['weather'][0]['main'];
                        final time = DateTime.parse(hourlyForeCast['dt_txt']);
                        return HourlyForecastItem(
                          icon: hourlySky == 'Clouds' || hourlySky == 'Rain'
                              ? Icons.cloud
                              : Icons.sunny,
                          time: DateFormat.j().format(time),
                          temperature: hourlyTemp.toString(),
                        );
                      }),
                ),
                const SizedBox(height: 20),

                //Additional  Information
                const Text(
                  'Additional Information',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  // color: Colors.red,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      AdditionalInfoWidget(
                        icon: Icons.water_drop,
                        label: 'Humidity',
                        num: humidity.toString(),
                      ),
                      AdditionalInfoWidget(
                          icon: Icons.air,
                          label: 'Wind Speed',
                          num: windSpeed.toString()),
                      AdditionalInfoWidget(
                        icon: Icons.beach_access,
                        label: 'Pressure',
                        num: currentPressure.toString(),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class AdditionalInfoWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final String num;
  const AdditionalInfoWidget(
      {super.key, required this.icon, required this.label, required this.num});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 15),
        ),
        const SizedBox(height: 8),
        Text(num,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }
}


// class AdditionalInformationItem extends StatelessWidget {
//   const AdditionalInformationItem({super.key,final Icon? icon,final String? text,final String? num});

//   @override
//   Widget build(BuildContext context) {
//     text='';
//     return const Card(
//                     elevation: 0,
//                     child: Padding(
//                       padding: EdgeInsets.all(8.0),
//                       child: Column(
//                         children: [
//                           Icon(
//                             Icons.water_drop,
//                             size: 32,
//                           ),
//                           SizedBox(height: 8),
//                           Text(
//                             ,
//                             style: TextStyle(fontSize: 20),
//                           ),
//                           SizedBox(height: 8),
//                           Text('94',
//                               style: TextStyle(
//                                   fontSize: 24, fontWeight: FontWeight.bold)),
//                         ],
//                       ),
//                     ),
//                   );
//   }
// }