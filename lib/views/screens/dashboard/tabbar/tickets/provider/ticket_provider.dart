import 'package:flutter/cupertino.dart';
import 'package:makula_oem/helper/model/open_ticket_model.dart';

class TicketProvider with ChangeNotifier {
  OpenTicket _ticketItem = OpenTicket();

  OpenTicket get ticketItem => _ticketItem;

  bool _isClosedShowing = false;
  bool _isSendBtnVisible = false;
  String _ticketStatus = "";

  bool get isClosedShowing => _isClosedShowing;

  bool get isSendBtnVisible => _isSendBtnVisible;

  String get ticketStatus => _ticketStatus;

  void setTicketItemDetails(OpenTicket item) {
    _ticketItem = item;
    notifyListeners();
  }

  void setIsClosedValue(bool isClosed) {
    _isClosedShowing = isClosed;
    notifyListeners();
  }

  void setIsSendBtnVisible(bool visible) {
    _isSendBtnVisible = visible;
    notifyListeners();
  }
  void setTicketStatus(String status) {
    _ticketStatus = status;
    notifyListeners();
  }
}
