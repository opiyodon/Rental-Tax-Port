class VacancyReport {
  final String? propertyId;
  final DateTime? reportDate;
  final bool? inspectionComplete;
  final bool? vacancyConfirmed;

  VacancyReport({
    this.propertyId,
    this.reportDate,
    this.inspectionComplete,
    this.vacancyConfirmed,
  });

  static VacancyReport fromMap(Map<String, dynamic> data, String id) {
    return VacancyReport(
      propertyId: id,
      reportDate: data['reportDate'] != null
          ? DateTime.parse(data['reportDate'])
          : null,
      inspectionComplete: data['inspectionComplete'],
      vacancyConfirmed: data['vacancyConfirmed'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'propertyId': propertyId,
      'reportDate': reportDate?.toIso8601String(),
      'inspectionComplete': inspectionComplete,
      'vacancyConfirmed': vacancyConfirmed,
    };
  }
}