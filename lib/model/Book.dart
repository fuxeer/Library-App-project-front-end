class Book {
  final int BookID;
  final String Title;
  final String Author;
  final String Description;
  final String Category;
  final String Publisher;
  final int PublishYear;
  final double Rating;

  Book({
    required this.BookID,
    required this.Title,
    required this.Author,
    required this.Description,
    required this.Category,
    required this.Publisher,
    required this.PublishYear,
    required this.Rating,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      BookID: json['bookID'],
      Title: json['title'],
      Author: json['author'],
      Description: json['description'],
      Category: json['category'],
      Publisher: json['publisher'],
      PublishYear: json['publishYear'],
      Rating: json['rating'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'BookID': BookID,
      'Title': Title,
      'Author': Author,
      'Description': Description,
      'Category': Category,
      'Publisher': Publisher,
      'PublishYear': PublishYear,
      'Rating': Rating,
    };
  }
}
