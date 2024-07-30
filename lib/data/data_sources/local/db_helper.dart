import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/data_types/file_data.dart';
import '../../../core/data_types/image_data.dart';
import '../../models/friend_model.dart';
import '../../models/message_model.dart';
import '../../models/user_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), ApiConstants.databaseName),
      onCreate: (db, version) async {
        // bảng user
        await db.execute('''
          CREATE TABLE ${ApiConstants.userTable} (
            ${ApiConstants.username} TEXT PRIMARY KEY,
            ${ApiConstants.fullName} TEXT,
            ${ApiConstants.avatar} TEXT,
            ${ApiConstants.token} TEXT
          )
        ''');
        // bảng friend
        await db.execute('''
          CREATE TABLE ${ApiConstants.friendTable}(
            ${ApiConstants.friendId} TEXT PRIMARY KEY,
            ${ApiConstants.fullName} TEXT,
            ${ApiConstants.username} TEXT,
            ${ApiConstants.avatar} TEXT,
            ${ApiConstants.content} TEXT,
            ${ApiConstants.files} TEXT,   
            ${ApiConstants.images} TEXT,
            ${ApiConstants.isSend} INTEGER,
            ${ApiConstants.isOnline} INTEGER,
            ${ApiConstants.nickname} TEXT
          )
        ''');

        // bảng files
        await db.execute('''
          CREATE TABLE ${ApiConstants.fileTable}(
            ${ApiConstants.idUnder} TEXT PRIMARY KEY,
            ${ApiConstants.urlFile} TEXT,
            ${ApiConstants.filename} TEXT,
            ${ApiConstants.messageId} TEXT,
            FOREIGN KEY (${ApiConstants.messageId}) 
            REFERENCES messages(${ApiConstants.messageId}) ON DELETE CASCADE
          )
        ''');

        // bảng images
        await db.execute('''
          CREATE TABLE ${ApiConstants.imageTable}(
            ${ApiConstants.idUnder} TEXT PRIMARY KEY,
            ${ApiConstants.urlImage} TEXT,
            ${ApiConstants.filename}  TEXT,
            ${ApiConstants.messageId} TEXT,
            FOREIGN KEY (${ApiConstants.messageId}) REFERENCES messages(${ApiConstants.messageId}) ON DELETE CASCADE
          )
        ''');
        // bảng dữ liệu ảnh
        await db.execute('''
          CREATE TABLE ${ApiConstants.imageDataTable}(
            ${ApiConstants.id} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${ApiConstants.urlImage} TEXT UNIQUE,
            ${ApiConstants.imageData} BLOB
          )
        ''');
      },
      version: 1,
    );
  }

  Future<void> insertOrUpdateUser(UserModel user) async {
    // tạo hoặc cập nhật thông tin người dùng
    final db = await database;
    await db.transaction((txn) async {
      await txn.rawInsert('''
      INSERT OR REPLACE INTO ${ApiConstants.userTable}(${ApiConstants.username}, 
      ${ApiConstants.fullName}, ${ApiConstants.avatar}, ${ApiConstants.token})
      VALUES(?, ?, ?, ?)
    ''', [user.userName, user.fullName, user.avatar, user.token]);
    });
  }

  Future<UserModel?> getUser() async {
    // Lấy thông tin người dùng
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query(ApiConstants.userTable, limit: 1);
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<void> insertNickname(String friendID, String nickname) async {
    // thêm biệt danh cho bạn bè
    final db = await database;
    await db.update(
      ApiConstants.friendTable,
      {ApiConstants.nickname: nickname},
      where: '${ApiConstants.friendId} = ?',
      whereArgs: [friendID],
    );
  }

  Future<List<FriendModel>> getAllFriends() async {
    // lấy danh sách bạn bè, chỉ sử dụng khi không có mạng
    final db = await database;
    final List<Map<String, dynamic>> allFriends =
        await db.query(ApiConstants.friendTable);
    return allFriends
        .map((friendMap) => FriendModel.fromMap(friendMap))
        .toList();
  }

  Future<List<FriendModel>> updateAllFriends(
      List<FriendModel> friendList) async {
    // cập nhật hoặc chèn danh sách bạn bè từ server
    final db = await database;
    // Lấy danh sách bạn bè cũ
    final List<Map<String, dynamic>> currentFriends =
        await db.query(ApiConstants.friendTable);

    // Nếu danh sách bạn bè cũ rỗng, chèn danh sách mới và return friendList
    if (currentFriends.isEmpty) {
      final Batch batch = db.batch();
      for (FriendModel friend in friendList) {
        batch.insert(ApiConstants.friendTable, friend.toMap());
      }
      await batch.commit(noResult: true);
      return friendList;
    }

    // Tạo map lưu nickname của bạn bè hiện tại
    final Map<String, String?> nicknameMap = {
      for (var row in currentFriends)
        row[ApiConstants.friendId] as String:
            row[ApiConstants.nickname] as String?
    };

    final Batch batch = db.batch();

    // Cập nhật hoặc chèn bạn bè mới
    for (FriendModel friend in friendList) {
      final Map<String, Object?> updateData = friend.toMap();

      if (nicknameMap.containsKey(friend.friendID)) {
        if (nicknameMap[friend.friendID] != null) {
          updateData[ApiConstants.nickname] = nicknameMap[friend.friendID];
        }
        batch.update(
          ApiConstants.friendTable,
          updateData,
          where: '${ApiConstants.friendId} = ?',
          whereArgs: [friend.friendID],
        );
      } else {
        batch.insert(ApiConstants.friendTable, updateData);
      }
    }

    await batch.commit(noResult: true);

    // Lấy danh sách bạn bè sau khi cập nhật
    final List<Map<String, dynamic>> updatedFriends =
        await db.query(ApiConstants.friendTable);
    return updatedFriends
        .map((friendMap) => FriendModel.fromMap(friendMap))
        .toList();
  }

  Future<void> createMessageTable(String friendId) async {
    // tạo bảng tin nhắn cho từng bạn bè
    final db = await database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS messages_$friendId (
        ${ApiConstants.id} TEXT PRIMARY KEY,
        ${ApiConstants.content} TEXT,
        ${ApiConstants.isSend} INTEGER,
        ${ApiConstants.createdAt} TEXT,
        ${ApiConstants.messageType} INTEGER
      )
    ''');
  }

  Future<void> insertMessage(String friendId, MessageModel message) async {
    // thêm 1 tin nhắn mới, dùng khi gửi tin nhắn
    final db = await database;
    await createMessageTable(friendId);
    await db.insert('messages_$friendId', message.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);

    // Insert files and images
    for (FileData file in message.files) {
      await db.insert(
          ApiConstants.fileTable,
          {
            ApiConstants.idUnder: file.id,
            ApiConstants.urlFile: file.urlFile,
            ApiConstants.filename: file.fileName,
            ApiConstants.messageId: message.id,
          },
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    for (ImageData image in message.images) {
      await db.insert(
          ApiConstants.imageTable,
          {
            ApiConstants.idUnder: image.id,
            ApiConstants.urlImage: image.urlImage,
            ApiConstants.filename: image.fileName,
            ApiConstants.messageId: message.id,
          },
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> insertMessages(
      String friendId, List<MessageModel> messages) async {
    // thêm 1 danh sách tin nhắn vào db
    final db = await database;
    await createMessageTable(friendId);
    for (MessageModel message in messages) {
      await db.insert('messages_$friendId', message.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);

      // Insert files and images
      for (FileData file in message.files) {
        await db.insert(
            ApiConstants.fileTable,
            {
              ApiConstants.idUnder: file.id,
              ApiConstants.urlFile: file.urlFile,
              ApiConstants.filename: file.fileName,
              ApiConstants.messageId: message.id,
            },
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      for (ImageData image in message.images) {
        await db.insert(
            ApiConstants.imageTable,
            {
              ApiConstants.idUnder: image.id,
              ApiConstants.urlImage: image.urlImage,
              ApiConstants.filename: image.fileName,
              ApiConstants.messageId: message.id,
            },
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }
  }

  Future<List<MessageModel>> getMessages(String friendId) async {
    // lấy danh sách tin nhắn
    try {
      final db = await database;
      await createMessageTable(friendId);
      final List<Map<String, dynamic>> maps =
          await db.query('messages_$friendId');
      List<MessageModel> messages = [];
      for (var map in maps) {
        var msg = MessageModel.fromJson(map);
        // Get files and images for each message
        final List<Map<String, dynamic>> fileMaps = await db.query(
            ApiConstants.fileTable,
            where: '${ApiConstants.messageId} = ?',
            whereArgs: [msg.id]);
        final List<Map<String, dynamic>> imageMaps = await db.query(
            ApiConstants.imageTable,
            where: '${ApiConstants.messageId} = ?',
            whereArgs: [msg.id]);

        List<FileData> files =
            fileMaps.map((map) => FileData.fromJson(map)).toList();
        List<ImageData> images =
            imageMaps.map((map) => ImageData.fromJson(map)).toList();

        messages.add(MessageModel(
          id: msg.id,
          content: msg.content,
          files: files,
          images: images,
          isSend: msg.isSend,
          createdAt: msg.createdAt,
          messageType: msg.messageType,
        ));
      }
      return messages;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> insertImage(String imageUrl, Uint8List image) async {
    final db = await database;
    Map<String, dynamic> row = {
      ApiConstants.urlImage: imageUrl,
      ApiConstants.imageData: image,
    };

    await db.insert(
      ApiConstants.imageDataTable,
      row,
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<Uint8List> getImage(String imageUrl) async {
    // lấy ảnh từ db ra, chỉ dùng lúc mất mạng
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      ApiConstants.imageDataTable,
      where: '${ApiConstants.urlImage} = ?',
      whereArgs: [imageUrl],
      limit: 1,
    );
    return maps.first[ApiConstants.imageData];
  }

  Future<void> deleteDatabase() async {
    // xóa database lúc đăng xuất
    final db = await database;

    // Xóa tất cả các bảng
    await db.delete(ApiConstants.friendTable);
    await db.delete(ApiConstants.userTable);
    await db.delete(ApiConstants.fileTable);
    await db.delete(ApiConstants.imageTable);
    await db.delete(ApiConstants.imageDataTable);

    // tìm kiếm và xóa các bảng tin nhắn với bạn bè
    final List<Map<String, dynamic>> tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name LIKE 'messages_%'");
    for (var table in tables) {
      String tableName = table['name'];
      await db.execute("DROP TABLE IF EXISTS $tableName");
    }

    // Optional: reset the database instance
    _database = null;
    await _initDatabase();
  }
}

String hashSHA256(String input) {
  var bytes = utf8.encode(input);
  var digest = sha256.convert(bytes);

  return digest.toString();
}

String encryptAES(String plainText, String hashedPassword) {
  final key = encrypt.Key.fromUtf8(hashedPassword);
  final iv = encrypt.IV.fromLength(16); // IV có độ dài 16 byte

  final encrypter = encrypt.Encrypter(encrypt.AES(key));

  final encrypted = encrypter.encrypt(plainText, iv: iv);
  return encrypted.base64;
}

// Hàm giải mã với AES
String decryptAES(String encryptedText, String hashedPassword) {
  final key = encrypt.Key.fromUtf8(hashedPassword);
  final iv = encrypt.IV.fromLength(16); // IV có độ dài 16 byte

  final encrypter = encrypt.Encrypter(encrypt.AES(key));

  final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
  return decrypted;
}
