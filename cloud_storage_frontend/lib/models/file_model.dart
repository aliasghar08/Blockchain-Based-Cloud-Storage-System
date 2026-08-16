class FileModel {
  final String cid;
  final String fileName;
  final int fileSize;
  final String fileType;
  final String owner;
  final DateTime uploadTime;

  FileModel({
    required this.cid,
    required this.fileName,
    required this.fileSize,
    required this.fileType,
    required this.owner,
    required this.uploadTime,
  });
}
