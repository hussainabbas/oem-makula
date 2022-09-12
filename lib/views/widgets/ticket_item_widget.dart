import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:makula_oem/helper/model/open_ticket_model.dart';
import 'package:makula_oem/helper/utils/colors.dart';
import 'package:makula_oem/helper/utils/constants.dart';
import 'package:makula_oem/helper/utils/extension_functions.dart';
import 'package:makula_oem/helper/utils/routes.dart';
import 'package:makula_oem/helper/utils/utils.dart';
import 'package:makula_oem/views/screens/dashboard/dashboard_provider.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/details/ticket_detail_screen.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/provider/ticket_provider.dart';
import 'package:makula_oem/views/widgets/makula_text_view.dart';
import 'package:provider/provider.dart';

class TicketItemWidget extends StatelessWidget {
  const TicketItemWidget({Key? key, required OpenTicket item})
      : _item = item,
        super(key: key);

  final OpenTicket _item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        context.read<TicketProvider>().setTicketItemDetails(_item);
        context
            .read<DashboardProvider>()
            .setChannelId(_item.ticketChatChannels![0].toString());
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TicketDetailScreen(channelId: _item.ticketChatChannels![0].toString() , ticket: _item,)
          ),
        );
      },
      contentPadding: EdgeInsets.zero,
      leading: Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(
            "assets/images/rectangle.svg",
            color: getContainerBgColor(_item.status.toString()),
          ),
          _item.status == "closed"
              ? SvgPicture.asset(
                  "assets/images/close_ticket.svg",
                  color: getContainerFrontColor(_item.status.toString()),
                )
              : SvgPicture.asset(
                  "assets/images/ticket.svg",
                  color: getContainerFrontColor(_item.status.toString()),
                ),
        ],
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: TextView(
                text: _item.title.toString(),
                textColor: textColorDark,
                isEllipsis: true,
                textFontWeight: FontWeight.w700,
                fontSize: 14),
          ),
          const SizedBox(
            height: 8,
          )
        ],
      ),
      subtitle: Row(
        children: [
          TextView(
              text: _item.status.toString().toUpperCase(),
              textColor: getStatusColor(_item.status.toString()),
              textFontWeight: FontWeight.w600,
              fontSize: 12),
          const SizedBox(
            width: 20,
          ),
          TextView(
              text: _item.createdAt!
                  .formatDate(dateFormatYYYMMddTHHmmssSSSZ, dateFormatYYYYddMM)
                  .toUpperCase(),
              textColor: textColorLight,
              textFontWeight: FontWeight.w500,
              fontSize: 12),
        ],
      ),
    );
  }
}
