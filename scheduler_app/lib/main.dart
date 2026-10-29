import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kGreen = Color(0xFF4DCB8B);
const kDark = Color(0xFF006650);
const kOrange = Color(0xFFFF7A45);
const kPeri = Color(0xFF8C95FA);
const kSand = Color(0xFFFFBD76);
const kNavy = Color(0xFF1B1F8F);
const kGrey = Color(0xFFF4F4F4);
const kMuted = Color(0xFFB0B0B8);
const kInk = Color(0xFF222222);

const _letters = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
const _weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String hm(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
bool sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

void main() => runApp(const App());

class Event {
  Event({String? id, required this.title, this.note = '', this.room = '', this.person = '', required this.start, required this.end})
      : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  final String id;
  final String title, note, room, person;
  final DateTime start, end;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'note': note,
        'room': room,
        'person': person,
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
      };

  factory Event.fromJson(Map<String, dynamic> j) => Event(
        id: j['id'],
        title: j['title'],
        note: j['note'] ?? '',
        room: j['room'] ?? '',
        person: j['person'] ?? '',
        start: DateTime.parse(j['start']),
        end: DateTime.parse(j['end']),
      );
}

class Store extends ChangeNotifier {
  final List<Event> events = [];

  Future<void> load() async {
    final raw = (await SharedPreferences.getInstance()).getString('events');
    if (raw != null) {
      events
        ..clear()
        ..addAll((jsonDecode(raw) as List).map((e) => Event.fromJson(e as Map<String, dynamic>)));
    }
    _commit(persist: false);
  }

  void save(Event e) {
    events.removeWhere((x) => x.id == e.id);
    events.add(e);
    _commit();
  }

  void remove(Event e) {
    events.removeWhere((x) => x.id == e.id);
    _commit();
  }

  List<Event> on(DateTime d) => events.where((e) => sameDay(e.start, d)).toList();

  Future<void> _commit({bool persist = true}) async {
    events.sort((a, b) => a.start.compareTo(b.start));
    notifyListeners();
    if (persist) {
      (await SharedPreferences.getInstance()).setString('events', jsonEncode(events.map((e) => e.toJson()).toList()));
    }
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Nux Scheduler',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: kOrange),
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const Shell(),
      );
}

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  final store = Store();
  int tab = 0;
  DateTime day = DateTime.now();

  @override
  void initState() {
    super.initState();
    store.load();
  }

  Future<void> edit([Event? e]) async {
    final result = await showModalBottomSheet<Event>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (_) => EventForm(event: e, day: day),
    );
    if (result != null) {
      store.save(result);
      setState(() => day = DateTime(result.start.year, result.start.month, result.start.day));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: ListenableBuilder(
          listenable: store,
          builder: (_, _) => tab == 0
              ? HomePage(store, onEdit: edit)
              : SchedulePage(store, day: day, onDay: (d) => setState(() => day = d), onEdit: edit),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => edit(),
          backgroundColor: kOrange,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
        bottomNavigationBar: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(children: [
              _NavItem(Icons.home_outlined, tab == 0, () => setState(() => tab = 0)),
              _NavItem(Icons.calendar_month_outlined, tab == 1, () => setState(() => tab = 1)),
            ]),
          ),
        ),
      );
}

class _NavItem extends StatelessWidget {
  const _NavItem(this.icon, this.selected, this.onTap);
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
        child: InkWell(
          onTap: onTap,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 28, color: selected ? kOrange : kMuted),
            const SizedBox(height: 4),
            CircleAvatar(radius: 2.5, backgroundColor: selected ? kOrange : Colors.transparent),
          ]),
        ),
      );
}

class HomePage extends StatelessWidget {
  const HomePage(this.store, {super.key, required this.onEdit});
  final Store store;
  final ValueChanged<Event> onEdit;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = store.on(now).length;
    final next = store.events.where((e) => e.end.isAfter(now)).take(3).toList();
    final subjects = <String, int>{};
    for (final e in store.events) {
      subjects[e.title] = (subjects[e.title] ?? 0) + 1;
    }
    final names = subjects.keys.toList();
    const palette = [(kOrange, kSand), (kPeri, kNavy), (kGreen, kDark)];

    return ColoredBox(
      color: kDark,
      child: SafeArea(
        bottom: false,
        child: Column(children: [
          SizedBox(
            height: 190,
            child: Stack(children: [
              Positioned(right: 16, top: 10, child: Icon(Icons.public, size: 150, color: kGreen.withValues(alpha: .6))),
              Positioned(
                left: 24,
                top: 32,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Hello!', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    today == 0 ? 'Nothing planned today' : '$today event${today == 1 ? '' : 's'} today',
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ]),
              ),
            ]),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
              child: ListView(padding: const EdgeInsets.only(top: 28, bottom: 90), children: [
                const _Heading('Subjects', 'Recommendations for you'),
                SizedBox(
                  height: 137,
                  child: names.isEmpty
                      ? const Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Text('Add an event with + to see your subjects here.', style: TextStyle(color: kMuted)))
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: names.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (_, i) => _SubjectCard(names[i], subjects[names[i]]!, palette[i % palette.length]),
                        ),
                ),
                const SizedBox(height: 28),
                const _Heading('Your Schedule', 'Next lessons'),
                if (next.isEmpty)
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Text('No upcoming events.', style: TextStyle(color: kMuted))),
                for (var i = 0; i < next.length; i++)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                    child: EventCard(next[i], hot: i == 0, showWhen: true, onEdit: () => onEdit(next[i]), onDelete: () => store.remove(next[i])),
                  ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.title, this.sub);
  final String title, sub;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: kInk)),
          Text(sub, style: const TextStyle(fontSize: 15, color: kMuted)),
        ]),
      );
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard(this.name, this.count, this.colors);
  final String name;
  final int count;
  final (Color, Color) colors;

  @override
  Widget build(BuildContext context) => Container(
        width: 170,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: colors.$1, borderRadius: BorderRadius.circular(20)),
        child: Stack(children: [
          Positioned(right: -24, top: -24, child: CircleAvatar(radius: 52, backgroundColor: colors.$2)),
          const Positioned(right: 8, top: 10, child: Icon(Icons.more_vert, color: Colors.white, size: 20)),
          const Positioned(left: 18, top: 18, child: Icon(Icons.menu_book_rounded, color: Colors.white)),
          Positioned(
            left: 18,
            right: 12,
            bottom: 16,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
              Text('$count lesson${count == 1 ? '' : 's'}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
          ),
        ]),
      );
}

class SchedulePage extends StatelessWidget {
  const SchedulePage(this.store, {super.key, required this.day, required this.onDay, required this.onEdit});
  final Store store;
  final DateTime day;
  final ValueChanged<DateTime> onDay;
  final ValueChanged<Event> onEdit;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final sunday = DateTime(day.year, day.month, day.day - day.weekday % 7);
    final items = store.on(day);
    final hot = items.indexWhere((e) => e.end.isAfter(now));

    return SafeArea(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
          child: Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final d = await showDatePicker(context: context, initialDate: day, firstDate: DateTime(2000), lastDate: DateTime(2100));
                  if (d != null) onDay(d);
                },
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(children: [
                    Text('${day.day}', style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: kInk, height: 1)),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(_weekdays[day.weekday % 7], style: const TextStyle(fontSize: 16, color: kMuted)),
                      Text('${_months[day.month - 1]} ${day.year}', style: const TextStyle(fontSize: 16, color: kMuted)),
                    ]),
                  ]),
                ),
              ),
            ),
            Material(
              color: kGreen.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onDay(DateTime.now()),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Text('Today', style: TextStyle(color: kGreen, fontSize: 18, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ]),
        ),
        GestureDetector(
          onHorizontalDragEnd: (d) {
            final v = d.primaryVelocity ?? 0;
            if (v.abs() > 200) onDay(DateTime(day.year, day.month, day.day + (v < 0 ? 7 : -7)));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: [
              for (var i = 0; i < 7; i++) _weekCell(DateTime(sunday.year, sunday.month, sunday.day + i), i),
            ]),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 12, 24, 8),
          child: Row(children: [
            SizedBox(width: 64, child: Text('Time', style: TextStyle(color: kMuted, fontSize: 16))),
            Text('Course', style: TextStyle(color: kMuted, fontSize: 16)),
          ]),
        ),
        Expanded(
          child: items.isEmpty
              ? const Center(child: Text('Nothing scheduled.\nTap + to add an event.', textAlign: TextAlign.center, style: TextStyle(color: kMuted, fontSize: 16)))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (_, i) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    SizedBox(
                      width: 64,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(hm(items[i].start), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kInk)),
                          const SizedBox(height: 6),
                          Text(hm(items[i].end), style: const TextStyle(fontSize: 15, color: kMuted)),
                        ]),
                      ),
                    ),
                    Expanded(child: EventCard(items[i], hot: i == hot, onEdit: () => onEdit(items[i]), onDelete: () => store.remove(items[i]))),
                  ]),
                ),
        ),
      ]),
    );
  }

  Widget _weekCell(DateTime d, int i) {
    final selected = sameDay(d, day);
    final busy = store.on(d).isNotEmpty;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onDay(d),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: selected ? kOrange : null, borderRadius: BorderRadius.circular(14)),
          child: Column(children: [
            Text(_letters[i], style: TextStyle(fontSize: 12, color: selected ? Colors.white : kMuted)),
            const SizedBox(height: 6),
            Text('${d.day}', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: selected ? Colors.white : kInk)),
            const SizedBox(height: 4),
            CircleAvatar(radius: 2, backgroundColor: busy ? (selected ? Colors.white : kGreen) : Colors.transparent),
          ]),
        ),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  const EventCard(this.e, {super.key, this.hot = false, this.showWhen = false, required this.onEdit, required this.onDelete});
  final Event e;
  final bool hot, showWhen;
  final VoidCallback onEdit, onDelete;

  @override
  Widget build(BuildContext context) {
    final fg = hot ? Colors.white : kInk;
    final icon = hot ? Colors.white : kMuted;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: hot ? kGreen : kGrey, borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(e.title, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600, color: fg))),
          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
            child: Padding(padding: const EdgeInsets.all(4), child: Icon(Icons.more_vert, color: fg, size: 20)),
          ),
        ]),
        if (showWhen)
          Text('${_weekdays[e.start.weekday % 7]}, ${e.start.day} ${_months[e.start.month - 1]} · ${hm(e.start)}–${hm(e.end)}', style: TextStyle(fontSize: 13, color: fg)),
        if (e.note.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 2), child: Text(e.note, style: TextStyle(fontSize: 14, color: fg))),
        if (e.room.isNotEmpty || e.person.isNotEmpty) const SizedBox(height: 12),
        if (e.room.isNotEmpty) _Line(Icon(Icons.location_on_outlined, size: 18, color: icon), e.room, fg),
        if (e.room.isNotEmpty && e.person.isNotEmpty) const SizedBox(height: 8),
        if (e.person.isNotEmpty)
          _Line(
            CircleAvatar(
              radius: 9,
              backgroundColor: hot ? Colors.white : kSand,
              child: Text(e.person[0].toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: hot ? kGreen : kInk)),
            ),
            e.person,
            fg,
          ),
      ]),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.leading, this.text, this.color);
  final Widget leading;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(children: [
        SizedBox(width: 18, child: leading),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(fontSize: 14, color: color))),
      ]);
}

class EventForm extends StatefulWidget {
  const EventForm({super.key, this.event, required this.day});
  final Event? event;
  final DateTime day;

  @override
  State<EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  late final title = TextEditingController(text: widget.event?.title);
  late final note = TextEditingController(text: widget.event?.note);
  late final room = TextEditingController(text: widget.event?.room);
  late final person = TextEditingController(text: widget.event?.person);
  late DateTime start = widget.event?.start ?? DateTime(widget.day.year, widget.day.month, widget.day.day, 9);
  late DateTime end = widget.event?.end ?? start.add(const Duration(hours: 1));
  String? error;

  @override
  void dispose() {
    for (final c in [title, note, room, person]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> pickDate() async {
    final d = await showDatePicker(context: context, initialDate: start, firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (d == null) return;
    setState(() {
      start = DateTime(d.year, d.month, d.day, start.hour, start.minute);
      end = DateTime(d.year, d.month, d.day, end.hour, end.minute);
    });
  }

  Future<void> pickTime(bool isStart) async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(isStart ? start : end));
    if (t == null) return;
    final v = DateTime(start.year, start.month, start.day, t.hour, t.minute);
    setState(() {
      if (isStart) {
        end = v.add(end.difference(start));
        start = v;
      } else {
        end = v;
      }
    });
  }

  void submit() {
    if (title.text.trim().isEmpty) {
      setState(() => error = 'Please enter a title');
    } else if (!end.isAfter(start)) {
      setState(() => error = 'End time must be after start time');
    } else {
      Navigator.pop(
        context,
        Event(id: widget.event?.id, title: title.text.trim(), note: note.text.trim(), room: room.text.trim(), person: person.text.trim(), start: start, end: end),
      );
    }
  }

  Widget field(TextEditingController c, String label) => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: TextField(
          controller: c,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: kGrey,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.viewInsetsOf(context).bottom + 24),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(widget.event == null ? 'New event' : 'Edit event', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            field(title, 'Title'),
            field(note, 'Details (e.g. Chapter 1)'),
            field(room, 'Room / location'),
            field(person, 'Person'),
            const SizedBox(height: 12),
            Wrap(spacing: 8, children: [
              ActionChip(avatar: const Icon(Icons.event, size: 18), label: Text('${start.day} ${_months[start.month - 1]} ${start.year}'), onPressed: pickDate),
              ActionChip(avatar: const Icon(Icons.schedule, size: 18), label: Text('From ${hm(start)}'), onPressed: () => pickTime(true)),
              ActionChip(avatar: const Icon(Icons.schedule, size: 18), label: Text('To ${hm(end)}'), onPressed: () => pickTime(false)),
            ]),
            if (error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(error!, style: const TextStyle(color: Colors.red))),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: kOrange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: submit,
                child: const Text('Save', style: TextStyle(fontSize: 16)),
              ),
            ),
          ]),
        ),
      );
}
