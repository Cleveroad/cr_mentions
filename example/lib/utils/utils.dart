import 'package:cr_mentions/scr/models/mention_data.dart';
import 'package:cr_mentions_example/models/message_model.dart';
import 'package:cr_mentions_example/models/user_model.dart';

final List<MessageModel> messages = [];

final usersList = <MentionData<UserModel>>[
  MentionData<UserModel>(
    mentionName: 'xerown',
    data: UserModel(
      firstName: 'Mark',
      lastName: 'Robinson',
    ),
    id: 0,
  ),
  MentionData<UserModel>(
    mentionName: 'nerm',
    data: UserModel(
      firstName: 'Zane',
      lastName: 'Meyers',
    ),
    id: 1,
  ),
  MentionData<UserModel>(
    mentionName: 'aty',
    data: UserModel(
      firstName: 'Aty',
      lastName: 'Nuclear',
    ),
    id: 2,
  ),
  MentionData<UserModel>(
    mentionName: 'soe',
    data: UserModel(
      firstName: 'Simon',
      lastName: 'Fellin',
    ),
    id: 3,
  ),
  MentionData<UserModel>(
    mentionName: 'wetogha',
    data: UserModel(
      firstName: 'William',
      lastName: 'Brilce',
    ),
    id: 4,
  ),
  MentionData<UserModel>(
    mentionName: 'conhatana',
    data: UserModel(
      firstName: 'Darrell',
      lastName: 'Trujillo',
    ),
    id: 5,
  ),
  MentionData<UserModel>(
    mentionName: 'lllaidemi',
    data: UserModel(
      firstName: 'Lilyana',
      lastName: 'Hutchinson',
    ),
    id: 6,
  ),
  MentionData<UserModel>(
    mentionName: 'ynneinod',
    data: UserModel(
      firstName: 'Alexzander',
      lastName: 'Levy',
    ),
    id: 7,
  ),
  MentionData<UserModel>(
    mentionName: 'cisusioto',
    data: UserModel(
      firstName: 'Beckham',
      lastName: 'Patton',
    ),
    id: 8,
  ),
  MentionData<UserModel>(
    mentionName: 'pannnania',
    data: UserModel(
      firstName: 'Tristan',
      lastName: 'Patterson',
    ),
    id: 9,
  ),
];
