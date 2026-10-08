import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:makula_oem/helper/model/list_machines.dart';
import 'package:makula_oem/helper/utils/colors.dart';
import 'package:makula_oem/helper/utils/flavor_const.dart';
import 'package:makula_oem/helper/utils/routes.dart';
import 'package:makula_oem/helper/utils/utils.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/machines/provider/machine_provider.dart';
import 'package:makula_oem/views/widgets/makula_text_view.dart';
import 'package:provider/provider.dart';

class MachineWidget extends StatelessWidget {
  const MachineWidget({Key? key, required ListOwnCustomerMachines item})
      : _item = item,
        super(key: key);

  final ListOwnCustomerMachines _item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 6, top: 6),
      child: Card(
        elevation: 4,
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xffffffff),
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1f000000),
                offset: Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            horizontalTitleGap: 16,
            leading: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: (_item.image == null || _item.image?.isEmpty == true) &&
                        (_item.customers?[0].oem?.thumbnail == null ||
                            _item.customers?[0].oem?.thumbnail?.isEmpty == true)
                    ? defaultImage()
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: CachedNetworkImage(
                            height: 56,
                            fit: BoxFit.cover,
                            width: 56,
                            placeholder: (context, url) => const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator.adaptive(),
                                  ),
                                ),
                            errorWidget: (context, url, error) =>
                                defaultImage(),
                            httpHeaders: const {'Referer': referer},
                            imageUrl: _item.image != null ||
                                    _item.image?.isEmpty != true
                                ? _item.image.toString()
                                : _item.customers![0].oem!.thumbnail.toString()),
                      )),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextView(
                    text: _item.name.toString(),
                    textColor: textColorDark,
                    isEllipsis: true,
                    textFontWeight: FontWeight.w700,
                    fontSize: 14),
                const SizedBox(
                  height: 12,
                ),
              ],
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextView(
                    text: _item.serialNumber.toString(),
                    textColor: textColorLight,
                    textFontWeight: FontWeight.w700,
                    fontSize: 13),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset("assets/images/total_tickets.svg"),
                    const SizedBox(
                      width: 4,
                    ),
                    TextView(
                        text: _item.totalOpenTickets.toString(),
                        textColor: textColorLight,
                        textFontWeight: FontWeight.w700,
                        fontSize: 13),
                  ],
                ),
              ],
            ),
            onTap: () {
              context
                  .read<MachineProvider>()
                  .setMachineId(_item.sId.toString());
              context
                  .read<MachineProvider>()
                  .setMachineName(_item.name.toString());
              Navigator.pushNamed(context, machineDetailScreenRoute);
            },
          ),
        ),
      ),
    );
  }

/* _getSignS3Download(String url , BuildContext context) async {
    context.showCustomDialog();
    var mUrl = url.replaceAll("https://workloads-staging-makula-technology-gmbh.s3.amazonaws.com/", "");
    var result = await MachineViewModel().getSignS3Download(mUrl);
    result.join(
            (failed) => {
          Navigator.pop(context),
          console("failed => " + failed.exception.toString())
        },
            (loaded) => {Navigator.pop(context), _launchURL(loaded.data)},
            (loading) => {console("loading => ")});
  }*/

}
