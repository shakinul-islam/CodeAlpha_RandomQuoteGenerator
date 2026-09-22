class Quote {
  final String text;
  final String author;

  Quote({required this.text, required this.author});

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      text: json['quote'] ?? json['content'] ?? 'No quote found.',
      author: json['author'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() => {
    'quote': text,
    'author': author,
  };
}