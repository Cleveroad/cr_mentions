import 'package:cr_mentions/cr_mentions.dart';
import 'package:cr_mentions_example/models/message_model.dart';
import 'package:cr_mentions_example/models/user_model.dart';
import 'package:cr_mentions_example/utils/utils.dart';
import 'package:cr_mentions_example/widgets/save_button.dart';
import 'package:flutter/material.dart';

class AddTextPage extends StatefulWidget {
  const AddTextPage({Key? key}) : super(key: key);

  @override
  State<AddTextPage> createState() => _AddTextPageState();
}

class _AddTextPageState extends State<AddTextPage> {
  late final _mentionCtr = MentionTextController(lastMention: _lastMention);
  final _lastMention = ValueNotifier<MentionModel?>(null);
  final _usersMentioned = <MentionData<UserModel>>[];

  final _snackBar = SnackBar(
    content: const Text(
      'Message has saved successfully!',
      style: TextStyle(color: Colors.deepOrange),
    ),
    backgroundColor: Colors.white,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
    shape: RoundedRectangleBorder(
      side: const BorderSide(color: Colors.deepOrange, width: 0.5),
      borderRadius: BorderRadius.circular(24),
    ),
    elevation: 1,
  );

  @override
  void initState() {
    super.initState();
    _lastMention.addListener(_mentionsListener);
  }

  @override
  void dispose() {
    _mentionCtr.dispose();
    _lastMention.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        toolbarHeight: 100,
        title: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _mentionCtr,
                decoration: _inputDecoration,
                minLines: 1,
                maxLines: 3,
                style: const TextStyle(fontSize: 15),
              ),
            ),
            const SizedBox(width: 14),
            SaveButton(onSaved: _onSaved),
          ],
        ),
      ),
      body: ListView.builder(
          itemCount: _usersMentioned.length,
          itemBuilder: (_, index) {
            final user = _usersMentioned[index];
            return ListTile(
              onTap: () => _onUserTapped(user),
              title: Text(user.data?.fullName ?? ''),
              subtitle: Text('${_mentionCtr.tag}${user.mentionName}'),
            );
          }),
    );
  }

  OutlineInputBorder get _borderStyle => OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.white),
      );

  InputDecoration get _inputDecoration => InputDecoration(
        fillColor: Colors.white,
        enabledBorder: _borderStyle,
        focusedBorder: _borderStyle,
        filled: true,
        contentPadding: const EdgeInsets.only(
          left: 12,
          top: 10,
          right: 12,
          bottom: 10,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        isDense: true,
        hintText: 'Enter text',
      );

  void _mentionsListener() {
    final mention = _lastMention.value;
    if (mention != null) {
      final text = mention.mentionName ?? '@';
      _makeQueryAndTryRequestSuggestions(text);
    } else {
      _clearUserList();
    }
  }

  void _makeQueryAndTryRequestSuggestions(String query) {
    String? searchQuery = _mentionCtr.makeQuerySuggestions(query);
    if (searchQuery != null) {
      if (searchQuery.isNotEmpty) {
        _searchSimulation(searchQuery);
      } else {
        _usersMentioned.addAll(usersList);
        setState(() {});
      }
    } else {
      _clearUserList();
    }
  }

  void _clearUserList() {
    _usersMentioned.clear();
    setState(() {});
  }

  void _searchSimulation(String searchQuery) {
    _usersMentioned.clear();

    _usersMentioned.addAll(
      usersList.where(
        (user) {
          final mentionName = user.mentionName;
          if (mentionName != null) {
            return mentionName.contains(searchQuery);
          } else {
            return false;
          }
        },
      ).toList(),
    );
    setState(() {});
  }

  void _onUserTapped(MentionData<UserModel> model) {
    _mentionCtr.insertMention(model);
    _usersMentioned.clear();
  }

  void _onSaved() {
    messages.add(
      MessageModel(
        text: _mentionCtr.text,
        mentions:
            _mentionCtr.getMentionsListWithoutTag(isTextTrimmed: true) ?? [],
      ),
    );

    _mentionCtr.clear();
    _usersMentioned.clear();
    ScaffoldMessenger.of(context).showSnackBar(_snackBar);
  }
}
