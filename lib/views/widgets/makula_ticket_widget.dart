import 'package:badges/badges.dart' as badges;
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:makula_oem/helper/model/get_status_response.dart';
import 'package:makula_oem/helper/model/open_ticket_model.dart';
import 'package:makula_oem/helper/utils/colors.dart';
import 'package:makula_oem/helper/utils/constants.dart';
import 'package:makula_oem/helper/utils/extension_functions.dart';
import 'package:makula_oem/helper/utils/utils.dart';
import 'package:makula_oem/views/screens/dashboard/dashboard_provider.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/details/ticket_detail_screen.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/provider/ticket_provider.dart';
import 'package:makula_oem/views/widgets/makula_text_view.dart';
import 'package:provider/provider.dart';

class TicketWidget extends StatelessWidget {
  const TicketWidget(
      {super.key, required OpenTicket? item, required this.statusData})
      : _item = item;

  final OpenTicket? _item;
  final StatusData? statusData;

  // BuildContext? mContext;

  @override
  Widget build(BuildContext context) {
    var isUnread = _item!.channelsWithCount > 0;
    String? status = "Open";
    String statusColor = "#EE0064";
    console("ticketType => ${_item?.status}");
    statusData?.listOwnOemOpenTickets?[0].oem?.statuses?.forEach((element) {
      console("ticketType 2 => ${element.sId} -- ${element.color} -- ${element.label}");
      if (element.sId == _item?.status) {
        console("ticketType => ${element.color}");
        status = element.label;
        statusColor = element.color ?? "#EE0064";
      }
    });
  //  console("ticketType => ${statusData?.listOwnOemOpenTickets?[0].oem?.statuses?.firstWhere((status) => status.sId == _item?.status)}");
    // Statuses? foundStatus =
    //     statusData?.listOwnOemOpenTickets?[0].oem?.statuses?.firstWhere(
    //   (status) => status.sId == _item?.status,
    // );


    var ticketType = _item?.ticketType ?? ticketTypeServiceRequest;
    return isUnread
        ? _unreadTicket(context, isUnread, status ?? "Open", ticketType, statusColor )
        : _readTicket(context, isUnread, status ?? "Open", ticketType, statusColor);
  }

  Widget _itemWidget(BuildContext context, bool isUnread, String status,
      String ticketType, String statusColor) {

    String? assigneeName;
    if (_item?.assignee != null) {
      assigneeName = _item?.assignee?.name?.toUpperCase();
    } else if (_item?.user != null) {
      assigneeName = _item?.user?.name?.toUpperCase();
    } else {
      assigneeName = notYetAssigned.toUpperCase();
    }


    console("assigneeName => $assigneeName");
    console("assigneeName => ${_item?.user?.name?.toUpperCase()}");
    console("assigneeName => ${_item?.assignee?.name?.toUpperCase()}");
    return GestureDetector(
      onTap: () async {
        context.read<TicketProvider>().setTicketItemDetails(_item!);
        context
            .read<DashboardProvider>()
            .setChannelId(_item?.ticketChatChannels![0].toString() ?? "");
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) =>
                  TicketDetailScreen(
                    channelId: _item?.ticketChatChannels![0].toString() ??
                        "",
                    ticket: _item!,
                  )),

        );

        // Navigator.of(context).pushNamed(ticketDetailScreenRoute);
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            ListTile(
                leading: Container(
                  alignment: Alignment.topLeft,
                  width: MediaQuery.of(context).size.width * 0.12,
                  child: isUnread
                      ? _unreadImage(isUnread, status, ticketType)
                      : _readImage(isUnread, status, ticketType),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextView(
                        text: _item?.machine?.name.toString().trim() ?? "",
                        textColor: primaryColor,
                        isEllipsis: true,
                        textFontWeight: FontWeight.w500,
                        fontSize: 12),
                    const SizedBox(
                      height: 2,
                    ),
                    TextView(
                        text: _item?.title.toString().trim() ?? "",
                        textColor: textColorDark,
                        textFontWeight: FontWeight.w600,
                        isEllipsis: true,
                        fontSize: 14),
                    const SizedBox(
                      height: 8,
                    ),
                    TextView(
                        text:
                            "${_item?.createdAt!.formatDate(dateFormatYYYMMddTHHmmssSSSZ, dateFormatYYYYddMM)} •  ${_item?.ticketId.toString()}",
                        textColor: textColorLight,
                        textFontWeight: FontWeight.w600,
                        fontSize: 10),
                  ],
                )),
            const SizedBox(
              height: 8,
            ),
            Opacity(
              opacity: 0.5,
              child: Container(
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                width: MediaQuery.of(context).size.width,
                height: 1,
                color: borderColor,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(12, 2, 12, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          status != "Closed" // CLOSED
                              ? "assets/images/assignee.svg"
                              : "assets/images/ic_assignee_closed.svg",
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        Expanded(
                          child: TextView(
                              text: assigneeName ?? "",
                              textColor: textColorLight,
                              textFontWeight: FontWeight.w600,
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                    decoration: BoxDecoration(
                      color: hexStringToColor2F(statusColor),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: TextView(
                        text: status.toUpperCase(),
                        textColor: hexStringToColor(statusColor),
                        textFontWeight: FontWeight.w600,
                        fontSize: 12),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _unreadTicket(BuildContext context, bool isUnread, String status,
      String ticketType, String statusColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: const Color(0xffffffff),
      child: _itemWidget(context, isUnread, status, ticketType, statusColor),
    );
  }

  Widget _readTicket(BuildContext context, bool isUnread, String status,
      String ticketType, String statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xffffffff),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: _itemWidget(context, isUnread, status, ticketType, statusColor),
    );
  }

  Widget _unreadImage(bool isUnread, String status, String ticketType) {
    return badges.Badge(
      position: BadgePosition.bottomStart(bottom: 2, start: -2),
      badgeContent: Text(
        _item?.channelsWithCount.toString() ?? "",
        style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Manrope',
            fontSize: 12,
            fontWeight: FontWeight.bold),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        alignment: Alignment.topCenter,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset("assets/images/rectangle.svg",
                color: ticketType != ticketTypeServiceRequest
                    ? onHoldContainerColor
                    : getContainerFrontColor2(status)),
            SvgPicture.asset(
                ticketType == ticketTypeServiceRequest
                    ? status == "closed"
                        ? "assets/images/close_ticket.svg"
                        : "assets/images/ticket.svg"
                    : "assets/images/spare_part.svg",
                color: ticketType != ticketTypeServiceRequest
                    ? onHoldStatusColor
                    : getContainerFrontColor(status)),
          ],
        ),
      ),
    );
  }

  Widget _readImage(bool isUnread, String status, String ticketType) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SvgPicture.asset(
          "assets/images/rectangle.svg",
          color: status == "closed"
              ? closedContainerColor
              : ticketType == ticketTypeServiceRequest
                  ? getContainerBgColor(status)
                  : onHoldContainerColor,
        ),
        SvgPicture.asset(
          ticketType == ticketTypeServiceRequest
              ? status == "closed"
                  ? "assets/images/close_ticket.svg"
                  : "assets/images/ticket.svg"
              : "assets/images/spare_part.svg",
          color: status == "closed"
              ? closedStatusColor
              : ticketType == ticketTypeServiceRequest
                  ? getContainerFrontColor(status)
                  : onHoldStatusColor,
        ),
      ],
    );
  }
}
