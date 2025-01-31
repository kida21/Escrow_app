class Contract {
  final String id;
  final String clientId;
  final String freelancerId;

  Contract({
    required this.id,
    required this.clientId,
    required this.freelancerId,
  });

  factory Contract.fromMap(Map<String, dynamic> data, String id) {
    return Contract(
      id: id,
      clientId: data['clientId'],
      freelancerId: data['freelancerId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'freelancerId': freelancerId,
    };
  }
}
