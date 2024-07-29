class ApiConstants {
  // tên các trường
  static const String username = 'Username';
  static const String password = 'Password';
  static const String fullName = 'FullName';
  static const String avatar = 'Avatar';
  static const String token = 'token';
  static const String status = 'status';
  static const String data = 'data';
  static const String message = 'message';
  static const String id = 'id';
  static const String idUnder = '_id'; // dùng cho file và image
  static const String friendId = 'FriendID';
  static const String lastTime = 'LastTime';
  static const String content = 'Content';
  static const String files = 'Files';
  static const String images = 'Images';
  static const String isSend = 'isSend';
  static const String isOnline = 'isOnline';
  static const String nickname = 'nickname';
  static const String createdAt = 'CreatedAt';
  static const String messageType = 'MessageType';
  static const String urlFile = 'urlFile';
  static const String urlImage = 'urlImage';
  static const String filename = 'FileName';

  // tên các bảng trong db
  static const databaseName = 'db_chatApp.db';
  static const String userTable = 'userTable';
  static const String friendTable = 'friendTable';
  static const String fileTable = 'fileTable';
  static const String imageTable = 'imageTable';
  static const String imageDataTable = 'images_from_url';
  // trường riêng trong db
  static const String messageId = 'messageId'; // id của message trong các bảng
  static const String imageData = 'image'; // trường lưu dữ liệu ảnh BLOB

  // Giao thức
  static const String type = 'Content-Type';
  static const String contentType = 'application/json; charset=UTF-8';
  static const String auth = 'Authorization';
  static const String bearer = 'Bearer';
  static const String dateFormat = 'hh:mm aa';
  static const String yesterday = 'Hôm qua';
  static const String downloadPath = '/storage/emulated/0/Download/';

  // cấu trúc api
  static const String apiRegister = 'auth/register';
  static const String apiLogin = 'auth/login';
  static const String updateUser = 'user/update';
  static const String infoUser = 'user/info';
  static const String apiListFriend = 'message/list-friend';
  static const String apiSendMessage = 'message/send-message';
  static const String apiGetMessage = 'message/get-message';
  static const String apiAvatar = 'avatar';
  static const String apiFiles = 'files';
  static const String apiImages = 'images';
}
