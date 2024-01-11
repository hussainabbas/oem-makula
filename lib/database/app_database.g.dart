// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  LoginMobileDao? _loginMobileDaoInstance;

  CurrentUserDao? _userDaoInstance;

  GetOemStatusesResponseDao? _oemStatusDaoInstance;

  ListUserOpenTicketsDao? _userOpenTicketListDaoInstance;

  ListUserCloseTicketsDao? _userCloseTicketListDaoInstance;

  ListOpenTicketsDao? _listOpenTicketsDaoInstance;

  ListCloseTicketsDao? _listCloseTicketsDaoInstance;

  GetTicketDetailResponseDao? _getTicketDetailResponseDaoInstance;

  ListAssigneeDao? _getListAssigneeInstance;

  ProcedureTemplatesDao? _procedureTemplatesInstance;

  ListOwnOemProcedureTemplatesDao? _getProcedureByIdResponseDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 4,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `LoginMobile` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `token` TEXT, `refreshToken` TEXT)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `CurrentUser` (`sId` TEXT, `name` TEXT, `username` TEXT, `role` TEXT, `email` TEXT, `info` TEXT, `organizationType` TEXT, `notificationChannelGroupName` TEXT, `organizationName` TEXT, `chatToken` TEXT, `notificationChannel` TEXT, `chatUUID` TEXT, `chatKeys` TEXT, PRIMARY KEY (`sId`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `StatusData` (`id` INTEGER, `listOwnOemOpenTickets` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ListOwnOemOpenTickets` (`id` INTEGER, `oem` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `OemStatus` (`id` INTEGER, `statuses` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ListUserOpenTickets` (`id` INTEGER, `openTicket` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Facility` (`sId` TEXT, `name` TEXT, `urlOemFacility` TEXT, `totalMachines` INTEGER, `totalOpenTickets` INTEGER, `generalAccessUrl` TEXT, PRIMARY KEY (`sId`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `MachineInformation` (`sId` TEXT, `name` TEXT, `serialNumber` TEXT, `description` TEXT, `documentationFiles` TEXT, `issues` TEXT, `image` TEXT, `thumbnail` TEXT, `totalOpenTickets` INTEGER, `slug` TEXT, PRIMARY KEY (`sId`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ListUserCloseTickets` (`id` INTEGER, `closeTickets` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `GetOwnOemTicketById` (`sId` TEXT, `ticketId` TEXT, `title` TEXT, `user` TEXT, `assignee` TEXT, `facility` TEXT, `machine` TEXT, `description` TEXT, `notes` TEXT, `chat` TEXT, `status` TEXT, `createdAt` TEXT, `ticketChatChannels` TEXT, `procedures` TEXT, PRIMARY KEY (`sId`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ListOpenTickets` (`id` INTEGER, `openTicket` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ListCloseTickets` (`id` INTEGER, `closeTickets` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ListAssignee` (`id` TEXT, `listOwnOemSupportAccounts` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ListOwnOemSupportAccounts` (`sId` TEXT, `name` TEXT, `username` TEXT, `role` TEXT, `email` TEXT, `access` INTEGER, `userType` TEXT, `userCredentialsSent` INTEGER, `isOem` INTEGER, `emailNotification` INTEGER, `totalActiveTickets` INTEGER, `organizationName` TEXT, `organizationType` TEXT, PRIMARY KEY (`sId`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Procedures` (`id` INTEGER, `procedure` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Procedure` (`sId` TEXT, `name` TEXT, `description` TEXT, `state` TEXT, `createdAt` TEXT, `updatedAt` TEXT, `pdfUrl` TEXT, PRIMARY KEY (`sId`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `GetProcedureTemplatesResponse` (`id` INTEGER, `listOwnOemProcedureTemplates` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ListOwnOemProcedureTemplates` (`sId` TEXT, `name` TEXT, `state` TEXT, `pdfUrl` TEXT, `description` TEXT, `createdAt` TEXT, `updatedAt` TEXT, `signatures` TEXT, `children` TEXT, `pageHeader` TEXT, `value` TEXT NOT NULL, PRIMARY KEY (`sId`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `SignatureModel` (`sId` TEXT, `signatoryTitle` TEXT, `name` TEXT, `date` TEXT, `signatureUrl` TEXT, PRIMARY KEY (`sId`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ChildrenModel` (`sId` TEXT, `type` TEXT, `name` TEXT, `description` TEXT, `value` TEXT NOT NULL, `isRequired` INTEGER, `options` TEXT, `tableOption` TEXT, `attachments` TEXT, `children` TEXT, PRIMARY KEY (`sId`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `AttachmentsModel` (`sId` TEXT, `name` TEXT, `type` TEXT, `url` TEXT, `size` TEXT, PRIMARY KEY (`sId`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `OptionsModel` (`sId` TEXT, `name` TEXT, PRIMARY KEY (`sId`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ColumnsModel` (`sId` TEXT, `heading` TEXT, `width` INTEGER, `value` TEXT NOT NULL, PRIMARY KEY (`sId`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  LoginMobileDao get loginMobileDao {
    return _loginMobileDaoInstance ??=
        _$LoginMobileDao(database, changeListener);
  }

  @override
  CurrentUserDao get userDao {
    return _userDaoInstance ??= _$CurrentUserDao(database, changeListener);
  }

  @override
  GetOemStatusesResponseDao get oemStatusDao {
    return _oemStatusDaoInstance ??=
        _$GetOemStatusesResponseDao(database, changeListener);
  }

  @override
  ListUserOpenTicketsDao get userOpenTicketListDao {
    return _userOpenTicketListDaoInstance ??=
        _$ListUserOpenTicketsDao(database, changeListener);
  }

  @override
  ListUserCloseTicketsDao get userCloseTicketListDao {
    return _userCloseTicketListDaoInstance ??=
        _$ListUserCloseTicketsDao(database, changeListener);
  }

  @override
  ListOpenTicketsDao get listOpenTicketsDao {
    return _listOpenTicketsDaoInstance ??=
        _$ListOpenTicketsDao(database, changeListener);
  }

  @override
  ListCloseTicketsDao get listCloseTicketsDao {
    return _listCloseTicketsDaoInstance ??=
        _$ListCloseTicketsDao(database, changeListener);
  }

  @override
  GetTicketDetailResponseDao get getTicketDetailResponseDao {
    return _getTicketDetailResponseDaoInstance ??=
        _$GetTicketDetailResponseDao(database, changeListener);
  }

  @override
  ListAssigneeDao get getListAssignee {
    return _getListAssigneeInstance ??=
        _$ListAssigneeDao(database, changeListener);
  }

  @override
  ProcedureTemplatesDao get procedureTemplates {
    return _procedureTemplatesInstance ??=
        _$ProcedureTemplatesDao(database, changeListener);
  }

  @override
  ListOwnOemProcedureTemplatesDao get getProcedureByIdResponseDao {
    return _getProcedureByIdResponseDaoInstance ??=
        _$ListOwnOemProcedureTemplatesDao(database, changeListener);
  }
}

class _$LoginMobileDao extends LoginMobileDao {
  _$LoginMobileDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _loginMobileInsertionAdapter = InsertionAdapter(
            database,
            'LoginMobile',
            (LoginMobile item) => <String, Object?>{
                  'id': item.id,
                  'token': item.token,
                  'refreshToken': item.refreshToken
                }),
        _loginMobileDeletionAdapter = DeletionAdapter(
            database,
            'LoginMobile',
            ['id'],
            (LoginMobile item) => <String, Object?>{
                  'id': item.id,
                  'token': item.token,
                  'refreshToken': item.refreshToken
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<LoginMobile> _loginMobileInsertionAdapter;

  final DeletionAdapter<LoginMobile> _loginMobileDeletionAdapter;

  @override
  Future<LoginMobile?> getLoginResponseFromDb() async {
    return _queryAdapter.query('SELECT * FROM LoginMobile LIMIT 1',
        mapper: (Map<String, Object?> row) => LoginMobile(
            token: row['token'] as String?,
            refreshToken: row['refreshToken'] as String?));
  }

  @override
  Future<void> insertLoginMobileOemIntoDb(LoginMobile loginMobileOem) async {
    await _loginMobileInsertionAdapter.insert(
        loginMobileOem, OnConflictStrategy.replace);
  }

  @override
  Future<void> deleteLoginMobileOem(LoginMobile loginMobileOem) async {
    await _loginMobileDeletionAdapter.delete(loginMobileOem);
  }
}

class _$CurrentUserDao extends CurrentUserDao {
  _$CurrentUserDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _currentUserInsertionAdapter = InsertionAdapter(
            database,
            'CurrentUser',
            (CurrentUser item) => <String, Object?>{
                  'sId': item.sId,
                  'name': item.name,
                  'username': item.username,
                  'role': item.role,
                  'email': item.email,
                  'info': item.info,
                  'organizationType': item.organizationType,
                  'notificationChannelGroupName':
                      item.notificationChannelGroupName,
                  'organizationName': item.organizationName,
                  'chatToken': item.chatToken,
                  'notificationChannel': item.notificationChannel,
                  'chatUUID': item.chatUUID,
                  'chatKeys': _chatKeysConverter.encode(item.chatKeys)
                }),
        _currentUserDeletionAdapter = DeletionAdapter(
            database,
            'CurrentUser',
            ['sId'],
            (CurrentUser item) => <String, Object?>{
                  'sId': item.sId,
                  'name': item.name,
                  'username': item.username,
                  'role': item.role,
                  'email': item.email,
                  'info': item.info,
                  'organizationType': item.organizationType,
                  'notificationChannelGroupName':
                      item.notificationChannelGroupName,
                  'organizationName': item.organizationName,
                  'chatToken': item.chatToken,
                  'notificationChannel': item.notificationChannel,
                  'chatUUID': item.chatUUID,
                  'chatKeys': _chatKeysConverter.encode(item.chatKeys)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<CurrentUser> _currentUserInsertionAdapter;

  final DeletionAdapter<CurrentUser> _currentUserDeletionAdapter;

  @override
  Future<CurrentUser?> getCurrentUserDetailsFromDb() async {
    return _queryAdapter.query('SELECT * FROM CurrentUser LIMIT 1',
        mapper: (Map<String, Object?> row) => CurrentUser(
            sId: row['sId'] as String?,
            name: row['name'] as String?,
            username: row['username'] as String?,
            role: row['role'] as String?,
            email: row['email'] as String?,
            info: row['info'] as String?,
            organizationType: row['organizationType'] as String?,
            notificationChannelGroupName:
                row['notificationChannelGroupName'] as String?,
            organizationName: row['organizationName'] as String?,
            chatToken: row['chatToken'] as String?,
            chatUUID: row['chatUUID'] as String?,
            notificationChannel: row['notificationChannel'] as String?,
            chatKeys: _chatKeysConverter.decode(row['chatKeys'] as String?)));
  }

  @override
  Future<void> insertCurrentUserDetailsIntoDb(CurrentUser data) async {
    await _currentUserInsertionAdapter.insert(data, OnConflictStrategy.replace);
  }

  @override
  Future<void> deleteCurrentUserResponse(CurrentUser data) async {
    await _currentUserDeletionAdapter.delete(data);
  }
}

class _$GetOemStatusesResponseDao extends GetOemStatusesResponseDao {
  _$GetOemStatusesResponseDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _statusDataInsertionAdapter = InsertionAdapter(
            database,
            'StatusData',
            (StatusData item) => <String, Object?>{
                  'id': item.id,
                  'listOwnOemOpenTickets':
                      _listOwnOemOpenTicketsListModelConverter
                          .encode(item.listOwnOemOpenTickets)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<StatusData> _statusDataInsertionAdapter;

  @override
  Future<List<StatusData>> findAllGetOemStatusesResponses() async {
    return _queryAdapter.queryList('SELECT * FROM StatusData',
        mapper: (Map<String, Object?> row) => StatusData(
            listOwnOemOpenTickets: _listOwnOemOpenTicketsListModelConverter
                .decode(row['listOwnOemOpenTickets'] as String?)));
  }

  @override
  Future<void> insertGetOemStatusesResponse(StatusData entity) async {
    await _statusDataInsertionAdapter.insert(
        entity, OnConflictStrategy.replace);
  }
}

class _$ListUserOpenTicketsDao extends ListUserOpenTicketsDao {
  _$ListUserOpenTicketsDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _listUserOpenTicketsInsertionAdapter = InsertionAdapter(
            database,
            'ListUserOpenTickets',
            (ListUserOpenTickets item) => <String, Object?>{
                  'id': item.id,
                  'openTicket': _listOpenTicketConverter.encode(item.openTicket)
                }),
        _listUserOpenTicketsUpdateAdapter = UpdateAdapter(
            database,
            'ListUserOpenTickets',
            ['id'],
            (ListUserOpenTickets item) => <String, Object?>{
                  'id': item.id,
                  'openTicket': _listOpenTicketConverter.encode(item.openTicket)
                }),
        _listUserOpenTicketsDeletionAdapter = DeletionAdapter(
            database,
            'ListUserOpenTickets',
            ['id'],
            (ListUserOpenTickets item) => <String, Object?>{
                  'id': item.id,
                  'openTicket': _listOpenTicketConverter.encode(item.openTicket)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ListUserOpenTickets>
      _listUserOpenTicketsInsertionAdapter;

  final UpdateAdapter<ListUserOpenTickets> _listUserOpenTicketsUpdateAdapter;

  final DeletionAdapter<ListUserOpenTickets>
      _listUserOpenTicketsDeletionAdapter;

  @override
  Future<List<ListUserOpenTickets>?> getListUserOpenTickets() async {
    return _queryAdapter.queryList('SELECT * FROM ListUserOpenTickets',
        mapper: (Map<String, Object?> row) => ListUserOpenTickets(
            openTicket:
                _listOpenTicketConverter.decode(row['openTicket'] as String?)));
  }

  @override
  Future<void> insertListUserOpenTickets(
      ListUserOpenTickets listUserOpenTickets) async {
    await _listUserOpenTicketsInsertionAdapter.insert(
        listUserOpenTickets, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateListUserOpenTickets(
      ListUserOpenTickets listUserOpenTickets) async {
    await _listUserOpenTicketsUpdateAdapter.update(
        listUserOpenTickets, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteListUserOpenTickets(
      ListUserOpenTickets listUserOpenTickets) async {
    await _listUserOpenTicketsDeletionAdapter.delete(listUserOpenTickets);
  }
}

class _$ListUserCloseTicketsDao extends ListUserCloseTicketsDao {
  _$ListUserCloseTicketsDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _listUserCloseTicketsInsertionAdapter = InsertionAdapter(
            database,
            'ListUserCloseTickets',
            (ListUserCloseTickets item) => <String, Object?>{
                  'id': item.id,
                  'closeTickets':
                      _listOpenTicketConverter.encode(item.closeTickets)
                }),
        _listUserCloseTicketsUpdateAdapter = UpdateAdapter(
            database,
            'ListUserCloseTickets',
            ['id'],
            (ListUserCloseTickets item) => <String, Object?>{
                  'id': item.id,
                  'closeTickets':
                      _listOpenTicketConverter.encode(item.closeTickets)
                }),
        _listUserCloseTicketsDeletionAdapter = DeletionAdapter(
            database,
            'ListUserCloseTickets',
            ['id'],
            (ListUserCloseTickets item) => <String, Object?>{
                  'id': item.id,
                  'closeTickets':
                      _listOpenTicketConverter.encode(item.closeTickets)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ListUserCloseTickets>
      _listUserCloseTicketsInsertionAdapter;

  final UpdateAdapter<ListUserCloseTickets> _listUserCloseTicketsUpdateAdapter;

  final DeletionAdapter<ListUserCloseTickets>
      _listUserCloseTicketsDeletionAdapter;

  @override
  Future<List<ListUserCloseTickets>?> getListUserCloseTickets() async {
    return _queryAdapter.queryList('SELECT * FROM ListUserCloseTickets',
        mapper: (Map<String, Object?> row) => ListUserCloseTickets(
            closeTickets: _listOpenTicketConverter
                .decode(row['closeTickets'] as String?)));
  }

  @override
  Future<void> insertListUserCloseTickets(
      ListUserCloseTickets listUserOpenTickets) async {
    await _listUserCloseTicketsInsertionAdapter.insert(
        listUserOpenTickets, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateListUserCloseTickets(
      ListUserCloseTickets listUserOpenTickets) async {
    await _listUserCloseTicketsUpdateAdapter.update(
        listUserOpenTickets, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteListUserCloseTickets(
      ListUserCloseTickets listUserOpenTickets) async {
    await _listUserCloseTicketsDeletionAdapter.delete(listUserOpenTickets);
  }
}

class _$ListOpenTicketsDao extends ListOpenTicketsDao {
  _$ListOpenTicketsDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _listOpenTicketsInsertionAdapter = InsertionAdapter(
            database,
            'ListOpenTickets',
            (ListOpenTickets item) => <String, Object?>{
                  'id': item.id,
                  'openTicket': _listOpenTicketConverter.encode(item.openTicket)
                }),
        _listOpenTicketsUpdateAdapter = UpdateAdapter(
            database,
            'ListOpenTickets',
            ['id'],
            (ListOpenTickets item) => <String, Object?>{
                  'id': item.id,
                  'openTicket': _listOpenTicketConverter.encode(item.openTicket)
                }),
        _listOpenTicketsDeletionAdapter = DeletionAdapter(
            database,
            'ListOpenTickets',
            ['id'],
            (ListOpenTickets item) => <String, Object?>{
                  'id': item.id,
                  'openTicket': _listOpenTicketConverter.encode(item.openTicket)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ListOpenTickets> _listOpenTicketsInsertionAdapter;

  final UpdateAdapter<ListOpenTickets> _listOpenTicketsUpdateAdapter;

  final DeletionAdapter<ListOpenTickets> _listOpenTicketsDeletionAdapter;

  @override
  Future<List<ListOpenTickets>?> getListOpenTickets() async {
    return _queryAdapter.queryList('SELECT * FROM ListOpenTickets',
        mapper: (Map<String, Object?> row) => ListOpenTickets(
            openTicket:
                _listOpenTicketConverter.decode(row['openTicket'] as String?)));
  }

  @override
  Future<void> insertListOpenTickets(ListOpenTickets listOpenTickets) async {
    await _listOpenTicketsInsertionAdapter.insert(
        listOpenTickets, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateListOpenTickets(ListOpenTickets listOpenTickets) async {
    await _listOpenTicketsUpdateAdapter.update(
        listOpenTickets, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteListOpenTickets(ListOpenTickets listOpenTickets) async {
    await _listOpenTicketsDeletionAdapter.delete(listOpenTickets);
  }
}

class _$ListCloseTicketsDao extends ListCloseTicketsDao {
  _$ListCloseTicketsDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _listCloseTicketsInsertionAdapter = InsertionAdapter(
            database,
            'ListCloseTickets',
            (ListCloseTickets item) => <String, Object?>{
                  'id': item.id,
                  'closeTickets':
                      _listOpenTicketConverter.encode(item.closeTickets)
                }),
        _listCloseTicketsUpdateAdapter = UpdateAdapter(
            database,
            'ListCloseTickets',
            ['id'],
            (ListCloseTickets item) => <String, Object?>{
                  'id': item.id,
                  'closeTickets':
                      _listOpenTicketConverter.encode(item.closeTickets)
                }),
        _listCloseTicketsDeletionAdapter = DeletionAdapter(
            database,
            'ListCloseTickets',
            ['id'],
            (ListCloseTickets item) => <String, Object?>{
                  'id': item.id,
                  'closeTickets':
                      _listOpenTicketConverter.encode(item.closeTickets)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ListCloseTickets> _listCloseTicketsInsertionAdapter;

  final UpdateAdapter<ListCloseTickets> _listCloseTicketsUpdateAdapter;

  final DeletionAdapter<ListCloseTickets> _listCloseTicketsDeletionAdapter;

  @override
  Future<List<ListCloseTickets>?> getListCloseTickets() async {
    return _queryAdapter.queryList('SELECT * FROM ListCloseTickets',
        mapper: (Map<String, Object?> row) => ListCloseTickets(
            closeTickets: _listOpenTicketConverter
                .decode(row['closeTickets'] as String?)));
  }

  @override
  Future<void> insertListCloseTickets(ListCloseTickets data) async {
    await _listCloseTicketsInsertionAdapter.insert(
        data, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateListCloseTickets(ListCloseTickets data) async {
    await _listCloseTicketsUpdateAdapter.update(data, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteListCloseTickets(ListCloseTickets data) async {
    await _listCloseTicketsDeletionAdapter.delete(data);
  }
}

class _$GetTicketDetailResponseDao extends GetTicketDetailResponseDao {
  _$GetTicketDetailResponseDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _getOwnOemTicketByIdInsertionAdapter = InsertionAdapter(
            database,
            'GetOwnOemTicketById',
            (GetOwnOemTicketById item) => <String, Object?>{
                  'sId': item.sId,
                  'ticketId': item.ticketId,
                  'title': item.title,
                  'user': _currentUserConverter.encode(item.user),
                  'assignee': _currentUserConverter.encode(item.assignee),
                  'facility': _facilityConverter.encode(item.facility),
                  'machine': _machineInformationConverter.encode(item.machine),
                  'description': item.description,
                  'notes': item.notes,
                  'chat': item.chat,
                  'status': item.status,
                  'createdAt': item.createdAt,
                  'ticketChatChannels':
                      _listStringConverter2.encode(item.ticketChatChannels),
                  'procedures': _listProceduresConverter.encode(item.procedures)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<GetOwnOemTicketById>
      _getOwnOemTicketByIdInsertionAdapter;

  @override
  Future<GetOwnOemTicketById?> getTicketDetailResponseById(String id) async {
    return _queryAdapter.query(
        'SELECT * FROM GetOwnOemTicketById WHERE sId = ?1',
        mapper: (Map<String, Object?> row) => GetOwnOemTicketById(
            sId: row['sId'] as String?,
            ticketId: row['ticketId'] as String?,
            title: row['title'] as String?,
            user: _currentUserConverter.decode(row['user'] as String?),
            assignee: _currentUserConverter.decode(row['assignee'] as String?),
            facility: _facilityConverter.decode(row['facility'] as String?),
            description: row['description'] as String?,
            notes: row['notes'] as String?,
            chat: row['chat'] as String?,
            status: row['status'] as String?,
            createdAt: row['createdAt'] as String?,
            machine:
                _machineInformationConverter.decode(row['machine'] as String?),
            procedures:
                _listProceduresConverter.decode(row['procedures'] as String?),
            ticketChatChannels: _listStringConverter2
                .decode(row['ticketChatChannels'] as String?)),
        arguments: [id]);
  }

  @override
  Future<void> insertOrUpdateTicketDetailResponse(
      GetOwnOemTicketById ticketDetailResponse) async {
    await _getOwnOemTicketByIdInsertionAdapter.insert(
        ticketDetailResponse, OnConflictStrategy.replace);
  }
}

class _$ListAssigneeDao extends ListAssigneeDao {
  _$ListAssigneeDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _listAssigneeInsertionAdapter = InsertionAdapter(
            database,
            'ListAssignee',
            (ListAssignee item) => <String, Object?>{
                  'id': item.id,
                  'listOwnOemSupportAccounts':
                      _listOwnOemSupportAccountsConverter
                          .encode(item.listOwnOemSupportAccounts)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ListAssignee> _listAssigneeInsertionAdapter;

  @override
  Future<ListAssignee?> findAssignee() async {
    return _queryAdapter.query('SELECT * FROM ListAssignee LIMIT 1',
        mapper: (Map<String, Object?> row) => ListAssignee(
            listOwnOemSupportAccounts: _listOwnOemSupportAccountsConverter
                .decode(row['listOwnOemSupportAccounts'] as String?)));
  }

  @override
  Future<void> insertListAssignee(ListAssignee listAssignee) async {
    await _listAssigneeInsertionAdapter.insert(
        listAssignee, OnConflictStrategy.replace);
  }
}

class _$ProcedureTemplatesDao extends ProcedureTemplatesDao {
  _$ProcedureTemplatesDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _getProcedureTemplatesResponseInsertionAdapter = InsertionAdapter(
            database,
            'GetProcedureTemplatesResponse',
            (GetProcedureTemplatesResponse item) => <String, Object?>{
                  'id': item.id,
                  'listOwnOemProcedureTemplates':
                      _listOwnOemProcedureTemplatesModelConverter
                          .encode(item.listOwnOemProcedureTemplates)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<GetProcedureTemplatesResponse>
      _getProcedureTemplatesResponseInsertionAdapter;

  @override
  Future<List<GetProcedureTemplatesResponse>> getAllProcedureTemplates() async {
    return _queryAdapter.queryList(
        'SELECT * FROM GetProcedureTemplatesResponse',
        mapper: (Map<String, Object?> row) => GetProcedureTemplatesResponse(
            listOwnOemProcedureTemplates:
                _listOwnOemProcedureTemplatesModelConverter
                    .decode(row['listOwnOemProcedureTemplates'] as String?)));
  }

  @override
  Future<GetProcedureTemplatesResponse?> getProcedureTemplates() async {
    return _queryAdapter.query(
        'SELECT * FROM GetProcedureTemplatesResponse LIMIT 1',
        mapper: (Map<String, Object?> row) => GetProcedureTemplatesResponse(
            listOwnOemProcedureTemplates:
                _listOwnOemProcedureTemplatesModelConverter
                    .decode(row['listOwnOemProcedureTemplates'] as String?)));
  }

  @override
  Future<void> insertOrUpdate(GetProcedureTemplatesResponse response) async {
    await _getProcedureTemplatesResponseInsertionAdapter.insert(
        response, OnConflictStrategy.abort);
  }
}

class _$ListOwnOemProcedureTemplatesDao
    extends ListOwnOemProcedureTemplatesDao {
  _$ListOwnOemProcedureTemplatesDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _listOwnOemProcedureTemplatesInsertionAdapter = InsertionAdapter(
            database,
            'ListOwnOemProcedureTemplates',
            (ListOwnOemProcedureTemplates item) => <String, Object?>{
                  'sId': item.sId,
                  'name': item.name,
                  'state': item.state,
                  'pdfUrl': item.pdfUrl,
                  'description': item.description,
                  'createdAt': item.createdAt,
                  'updatedAt': item.updatedAt,
                  'signatures':
                      _listSignatureModalConverter.encode(item.signatures),
                  'children': _listChildrenModalConverter.encode(item.children),
                  'pageHeader': item.pageHeader,
                  'value': _dynamicValueConverter.encode(item.value)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ListOwnOemProcedureTemplates>
      _listOwnOemProcedureTemplatesInsertionAdapter;

  @override
  Future<ListOwnOemProcedureTemplates?> getProcedureById(String id) async {
    return _queryAdapter.query(
        'SELECT * FROM ListOwnOemProcedureTemplates WHERE sId = ?1',
        mapper: (Map<String, Object?> row) => ListOwnOemProcedureTemplates(
            sId: row['sId'] as String?,
            name: row['name'] as String?,
            description: row['description'] as String?,
            createdAt: row['createdAt'] as String?,
            updatedAt: row['updatedAt'] as String?,
            signatures: _listSignatureModalConverter
                .decode(row['signatures'] as String?),
            children:
                _listChildrenModalConverter.decode(row['children'] as String?),
            state: row['state'] as String?,
            pdfUrl: row['pdfUrl'] as String?,
            value: _dynamicValueConverter.decode(row['value'] as String?),
            pageHeader: row['pageHeader'] as String?),
        arguments: [id]);
  }

  @override
  Future<void> insertListOwnOemProcedureTemplatesById(
      ListOwnOemProcedureTemplates template) async {
    await _listOwnOemProcedureTemplatesInsertionAdapter.insert(
        template, OnConflictStrategy.replace);
  }
}

// ignore_for_file: unused_element
final _chatKeysConverter = ChatKeysConverter();
final _listOwnOemOpenTicketsListModelConverter =
    ListOwnOemOpenTicketsListModelConverter();
final _oemStatusModelConverter = OemStatusModelConverter();
final _statusesListModelConverter = StatusesListModelConverter();
final _currentUserConverter = CurrentUserConverter();
final _facilityConverter = FacilityConverter();
final _machineInformationConverter = MachineInformationConverter();
final _listStringConverter = ListStringConverter();
final _listStringConverter2 = ListStringConverter2();
final _listProceduresConverter = ListProceduresConverter();
final _procedureConverter = ProcedureConverter();
final _listOwnOemProcedureTemplatesModelConverter =
    ListOwnOemProcedureTemplatesModelConverter();
final _listSignatureModalConverter = ListSignatureModalConverter();
final _listChildrenModalConverter = ListChildrenModalConverter();
final _listAttachmentsModelConverter = ListAttachmentsModelConverter();
final _listOptionsModelConverter = ListOptionsModelConverter();
final _tableOptionModelConverter = TableOptionModelConverter();
final _listColumnsModelConverter = ListColumnsModelConverter();
final _procedureTemplatesConverter = ProcedureTemplatesConverter();
final _listOpenTicketConverter = ListOpenTicketConverter();
final _listOwnOemSupportAccountsConverter =
    ListOwnOemSupportAccountsConverter();
final _dynamicValueConverter = DynamicValueConverter();
