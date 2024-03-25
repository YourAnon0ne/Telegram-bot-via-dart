import 'dart:convert';
import 'dart:io';

import 'package:dart_telegram_bot/dart_telegram_bot.dart';
import 'package:dart_telegram_bot/telegram_entities.dart';
import 'package:http/http.dart' as http;

class MyBot extends Bot {
  MyBot(String token) : super(token: token);

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
        var currency = args[1];
        var rate = await getCurrencyRate(currency);
        return bot.sendMessage(
          ChatID(update.message!.chat.id),
          'Курс $currency: $rate',
        );
      case 'погода':
        if (args.length != 2) {
          return bot.sendMessage(
            ChatID(update.message!.chat.id),
            'Invalid number of arguments. Usage: погода {страна/город}',
          );
        }
        var location = args[1];
        var weather = await getWeather(location);
        return bot.sendMessage(
          ChatID(update.message!.chat.id),
          'Погода в $location: $weather',
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


  @override
  Future<void> onUpdate(Future<void> Function(Bot, Update) handler) async {
    super.onUpdate(handler);
  }

  Future<Future<Message>> onBotCallbackQuery(Bot bot, CallbackQuery callbackQuery) async {
    var args = callbackQuery.data?.split(' ');
    var chatId = callbackQuery.message!.chat.id;

    switch (args?[0]) {
      case 'курс':
        if (args?.length != 2) {
          return bot.sendMessage(
            ChatID(chatId),
            'Invalid number of arguments. Usage: курс {валюта}',
          );
        }
        var currency = args?[1];
        var rate = await getCurrencyRate(currency!);
        return bot.sendMessage(
          ChatID(chatId),
          'Курс $currency: $rate',
        );
      case 'погода':
        if (args?.length != 2) {
          return bot.sendMessage(
            ChatID(chatId),
            'Invalid number of arguments. Usage: погода {страна/город}',
          );
        }
        var location = args?[1];
        var weather = await getWeather(location!);
        return bot.sendMessage(
          ChatID(chatId),
          'Погода в $location: $weather',
        );
      default:
        return bot.sendMessage(
          ChatID(chatId),
          'Unknown command',
        );
    }
  }

  Future<String> getCurrencyRate(String currency) async {
    // Ваш код для получения курса валюты
    return '10'; // Пример
  }

  Future<String> getWeather(String location) async {
    // Ваш код для получения погоды
    return 'Солнечно'; // Пример
  }
}

void main() async {
  var token = Platform.environment['7013856621:AAG-mO45dfP_iZAcz7pytvWfZR0dx31oyQQ'];

  if (token == null) {
    print('Ошибка: Токен бота не был найден в переменных окружения.');
    return;
  }

  var bot = MyBot(token);
  await bot.onReady(bot); // Передаем экземпляр класса bot в метод onReady
}
