import 'dart:convert';
import 'dart:io';
import 'package:dart_telegram_bot/telegram_entities.dart';
import 'package:http/http.dart' as http;
import 'package:dart_telegram_bot/dart_telegram_bot.dart';

class MyBot extends Bot {
  final String openExchangeRatesToken;
  final String openWeatherMapToken;

  MyBot(String token, this.openExchangeRatesToken, this.openWeatherMapToken)
      : super(token: token);

  Future<Future<Message>> onBotCommand(Bot bot, Update update) async {
    var args = BotCommandParser.fromMessage(update.message!)!.args;
    if (args.isEmpty) {
      return bot.sendMessage(
        ChatID(update.message!.chat.id),
        'No arguments provided',
      );
    }

    switch (args[0]) {
      case 'курс':
        if (args.length != 2) {
          return bot.sendMessage(
            ChatID(update.message!.chat.id),
            'Invalid number of arguments. Usage: курс {валюта}',
          );
        }
        var currency = args[1].toUpperCase();
        var rate = await getCurrencyRate(currency);
        return bot.sendMessage(
          ChatID(update.message!.chat.id),
          'Курс $currency: $rate',
        );
      case 'погода':
        if (args.length != 3) {
          return bot.sendMessage(
            ChatID(update.message!.chat.id),
            'Invalid number of arguments. Usage: погода {страна} {город}',
          );
        }
        var country = args[1];
        var city = args[2];
        var weather = await getWeather(country, city);
        return bot.sendMessage(
          ChatID(update.message!.chat.id),
          'Погода в $city, $country: $weather',
        );
      default:
        return bot.sendMessage(
          ChatID(update.message!.chat.id),
          'Unknown command',
        );
    }
  }

  @override
  Future<void> onReady(Bot bot) async {
    print('Bot ${bot.name} ready');
    onCommand('курс', onBotCommand);
    onCommand('погода', onBotCommand);
    await start(clean: true);
  }

  Future<String> getCurrencyRate(String currency) async {
    var url = Uri.parse(
        'https://openexchangerates.org/api/latest.json?app_id=$openExchangeRatesToken&base=USD');
    var response = await http.get(url);
    var data = jsonDecode(response.body);
    var rates = data['rates'];
    var rate = rates[currency];
    return rate.toString();
  }

  Future<String> getWeather(String country, String city) async {
    var url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city,$country&appid=$openWeatherMapToken');
    var response = await http.get(url);
    var data = jsonDecode(response.body);
    var weather = data['weather'][0]['description'];
    return weather;
  }
}

void main() async {
  var token = Platform.environment['токен для бота телеграм'];
  var openExchangeRatesToken =
      Platform.environment['токен для валюты'];
  var openWeatherMapToken = Platform.environment['токен для погоды'];

  MyBot(token ?? '', openExchangeRatesToken ?? '', openWeatherMapToken ?? '')
      .onReady(Bot(token: '$token'));
}
