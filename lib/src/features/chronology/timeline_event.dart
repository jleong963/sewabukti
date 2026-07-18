/// One chronology event (§10.5). [eventDate] is ISO `yyyy-MM-dd`; [eventTime]
/// is an optional `HH:mm`. [evidenceIds] link to evidence in the same case.
class TimelineEvent {
  const TimelineEvent({
    required this.id,
    required this.eventDate,
    required this.title,
    this.eventTime,
    this.description,
    this.sortOrder = 0,
    this.evidenceIds = const <String>[],
  });

  final String id;
  final String eventDate;
  final String? eventTime;
  final String title;
  final String? description;
  final int sortOrder;
  final List<String> evidenceIds;

  factory TimelineEvent.fromJson(Map<String, dynamic> json) => TimelineEvent(
    id: (json['id'] ?? '').toString(),
    eventDate: (json['event_date'] ?? '').toString(),
    eventTime: json['event_time'] as String?,
    title: (json['title'] ?? '').toString(),
    description: json['description'] as String?,
    sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    evidenceIds: (json['evidence_ids'] as List<dynamic>? ?? <dynamic>[])
        .map((dynamic e) => e.toString())
        .toList(),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'event_date': eventDate,
    'event_time': eventTime,
    'title': title,
    'description': description,
    'sort_order': sortOrder,
    'evidence_ids': evidenceIds,
  };

  TimelineEvent copyWith({
    String? eventDate,
    String? eventTime,
    String? title,
    String? description,
    int? sortOrder,
    List<String>? evidenceIds,
  }) => TimelineEvent(
    id: id,
    eventDate: eventDate ?? this.eventDate,
    eventTime: eventTime ?? this.eventTime,
    title: title ?? this.title,
    description: description ?? this.description,
    sortOrder: sortOrder ?? this.sortOrder,
    evidenceIds: evidenceIds ?? this.evidenceIds,
  );
}
