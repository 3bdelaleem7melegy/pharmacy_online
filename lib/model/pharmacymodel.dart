
import 'package:pharmacy_online/model/patient_model.dart';

class Pharmacy {
  final String? id;
  final String date;
  final String description;
  final Patient patient;
  final String type;
  final String day;
  final String doctorname;
  Pharmacy({
    required this.type,
    this.id,
    required this.date,
    required this.doctorname,
    required this.day,
    required this.patient,
    required this.description,
  });

  factory Pharmacy.formJson(Map<String, dynamic> json) {
    return Pharmacy(
      type: json['type'],
      id: json['id'],
      date: json['date'] ?? '',
      doctorname: json['doctorname'] ?? '',
      day: json['day'] ?? '',
      description: json['description'] ?? '',
      patient: Patient.formJson(json['patient']),
    );
  }

  Map<String, dynamic> toFireStore() {
    return {
      "id": id,
      "date": date,
      "day": day,
      "doctorname": doctorname,
      "description": description,
      "patient": patient.toFireStore(),
      "type": type,
    };
  }
}
