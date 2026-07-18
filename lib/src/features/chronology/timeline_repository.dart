import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sewabukti/src/core/auth/auth_controller.dart';
import 'package:sewabukti/src/core/config/app_config.dart';
import 'package:sewabukti/src/core/preferences/preferences_providers.dart';
import 'package:sewabukti/src/features/chronology/timeline_event.dart';

class TimelineException implements Exception {
  const TimelineException(this.code);
  final String code;
  @override
  String toString() => 'TimelineException($code)';
}

abstract interface class TimelineRepository {
  Future<List<TimelineEvent>> list(String caseId);
  Future<void> create(
    String caseId, {
    required String eventDate,
    String? eventTime,
    required String title,
    String? description,
    required List<String> evidenceIds,
  });
  Future<void> update(TimelineEvent event);
  Future<void> delete(String eventId);
  Future<void> reorder(String caseId, List<String> orderedIds);
}

class RemoteTimelineRepository implements TimelineRepository {
  RemoteTimelineRepository(this._ref);

  final Ref _ref;

  Uri _fn(String name) =>
      Uri.parse('${AppConfig.supabaseUrl}/functions/v1/$name');

  Map<String, String> _headers() {
    final String? token = _ref.read(authControllerProvider).idToken;
    if (token == null) throw const TimelineException('not_authenticated');
    return <String, String>{
      'Authorization': 'Bearer $token',
      'apikey': AppConfig.supabaseAnonKey,
      'Content-Type': 'application/json',
    };
  }

  Future<http.Response> _post(String fn, Map<String, dynamic> body) async {
    try {
      return await http.post(
        _fn(fn),
        headers: _headers(),
        body: jsonEncode(body),
      );
    } on TimelineException {
      rethrow;
    } catch (_) {
      throw const TimelineException('network_error');
    }
  }

  void _check(http.Response r) {
    if (r.statusCode != 200 && r.statusCode != 201) {
      throw const TimelineException('request_failed');
    }
  }

  @override
  Future<List<TimelineEvent>> list(String caseId) async {
    final http.Response r = await _post('list-timeline', <String, dynamic>{
      'case_id': caseId,
    });
    _check(r);
    final List<dynamic> events =
        (jsonDecode(r.body) as Map<String, dynamic>)['events']
            as List<dynamic>? ??
        <dynamic>[];
    return events
        .map((dynamic e) => TimelineEvent.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> create(
    String caseId, {
    required String eventDate,
    String? eventTime,
    required String title,
    String? description,
    required List<String> evidenceIds,
  }) async {
    _check(
      await _post('create-timeline-event', <String, dynamic>{
        'case_id': caseId,
        'event_date': eventDate,
        'event_time': ?eventTime,
        'title': title,
        'description': ?description,
        'evidence_ids': evidenceIds,
      }),
    );
  }

  @override
  Future<void> update(TimelineEvent event) async {
    _check(
      await _post('update-timeline-event', <String, dynamic>{
        'event_id': event.id,
        'event_date': event.eventDate,
        'event_time': ?event.eventTime,
        'title': event.title,
        'description': ?event.description,
        'evidence_ids': event.evidenceIds,
      }),
    );
  }

  @override
  Future<void> delete(String eventId) async {
    _check(
      await _post('delete-timeline-event', <String, dynamic>{
        'event_id': eventId,
      }),
    );
  }

  @override
  Future<void> reorder(String caseId, List<String> orderedIds) async {
    _check(
      await _post('reorder-timeline', <String, dynamic>{
        'case_id': caseId,
        'ordered_ids': orderedIds,
      }),
    );
  }
}

/// Demo repository: events persist to `shared_preferences` (MVP has one case,
/// so a single list is used).
class LocalTimelineRepository implements TimelineRepository {
  LocalTimelineRepository(this._prefs);

  final SharedPreferences _prefs;
  static const String _key = 'local_timeline';

  List<TimelineEvent> _read() {
    final String? raw = _prefs.getString(_key);
    if (raw == null) return <TimelineEvent>[];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map((dynamic e) => TimelineEvent.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return <TimelineEvent>[];
    }
  }

  Future<void> _writeAll(List<TimelineEvent> events) async {
    await _prefs.setString(
      _key,
      jsonEncode(events.map((TimelineEvent e) => e.toJson()).toList()),
    );
  }

  @override
  Future<List<TimelineEvent>> list(String caseId) async {
    final List<TimelineEvent> events = _read()
      ..sort((TimelineEvent a, TimelineEvent b) {
        final int byOrder = a.sortOrder.compareTo(b.sortOrder);
        return byOrder != 0 ? byOrder : a.eventDate.compareTo(b.eventDate);
      });
    return events;
  }

  @override
  Future<void> create(
    String caseId, {
    required String eventDate,
    String? eventTime,
    required String title,
    String? description,
    required List<String> evidenceIds,
  }) async {
    final List<TimelineEvent> events = _read();
    final int nextOrder = events.isEmpty
        ? 0
        : events
                  .map((TimelineEvent e) => e.sortOrder)
                  .reduce((int a, int b) => a > b ? a : b) +
              1;
    events.add(
      TimelineEvent(
        id: 'tl-${DateTime.now().microsecondsSinceEpoch}',
        eventDate: eventDate,
        eventTime: eventTime,
        title: title,
        description: description,
        sortOrder: nextOrder,
        evidenceIds: evidenceIds,
      ),
    );
    await _writeAll(events);
  }

  @override
  Future<void> update(TimelineEvent event) async {
    final List<TimelineEvent> events = _read()
        .map((TimelineEvent e) => e.id == event.id ? event : e)
        .toList();
    await _writeAll(events);
  }

  @override
  Future<void> delete(String eventId) async {
    await _writeAll(
      _read().where((TimelineEvent e) => e.id != eventId).toList(),
    );
  }

  @override
  Future<void> reorder(String caseId, List<String> orderedIds) async {
    final List<TimelineEvent> events = _read();
    final Map<String, TimelineEvent> byId = <String, TimelineEvent>{
      for (final TimelineEvent e in events) e.id: e,
    };
    final List<TimelineEvent> reordered = <TimelineEvent>[];
    for (int i = 0; i < orderedIds.length; i++) {
      final TimelineEvent? e = byId[orderedIds[i]];
      if (e != null) reordered.add(e.copyWith(sortOrder: i));
    }
    await _writeAll(reordered);
  }
}

final Provider<TimelineRepository> timelineRepositoryProvider =
    Provider<TimelineRepository>((Ref ref) {
      if (AppConfig.hasBackend) return RemoteTimelineRepository(ref);
      return LocalTimelineRepository(ref.read(sharedPreferencesProvider));
    });
