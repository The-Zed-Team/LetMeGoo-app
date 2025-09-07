import 'package:flutter/material.dart';
import 'package:letmegoo/constants/app_theme.dart';
import 'package:letmegoo/widgets/compactreportcard.dart';
import 'package:letmegoo/widgets/customstatustag.dart';
import 'package:letmegoo/widgets/messagecard.dart';
import 'package:letmegoo/widgets/replymessagecard.dart';
import 'package:letmegoo/widgets/swipetoconfirmcard.dart';

class Message2 extends StatefulWidget {
  final String? vehicleNumber;

  const Message2({super.key, this.vehicleNumber});

  @override
  State<Message2> createState() => _Message2State();
}

class _Message2State extends State<Message2> {
  String? selectedReply; // to store the selected reply message

  void sendReply(String message) {
    setState(() {
      selectedReply = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(170),
        child: Material(
          color: AppColors.background,
          elevation: 4,
          shadowColor: AppColors.textPrimary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              Container(
                padding: const EdgeInsets.only(top: 10, left: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: AppColors.textPrimary,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 80),
                    Text(
                      widget.vehicleNumber ?? "LMG-00-0000",
                      style: AppFonts.bold20(),
                    ),
                  ],
                ),
              ),
              Compactreportcard(
                title: "Anonymous",
                timestamp: "15:47 | 23rd July 2025 | KL00AA0000",
                location: "Thejaswini, Phase 1, Technopark",
                status: "Active",
                profileImage: null,
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Messagecard(
                        profileImage: null,
                        mainImage: const NetworkImage(
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/2019_Toyota_Corolla_Icon_Tech_VVT-i_Hybrid_1.8.jpg/1200px-2019_Toyota_Corolla_Icon_Tech_VVT-i_Hybrid_1.8.jpg',
                        ),
                        message:
                            "Hi, your car is blocking my path. Please move it urgently.",
                      ),
                    ],
                  ),
                ),
                Container(width: double.infinity),
                if (selectedReply != null)
                  Replymessagecard(message: selectedReply!, profileImage: null),

                SwipeToConfirmCard(onSwipe: () {}),

                const SizedBox(height: 110),
              ],
            ),
          ),

          if (selectedReply == null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.background.withOpacity(0.9),
                      blurRadius: 18,
                      spreadRadius: 10,
                      offset: const Offset(0, -10),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => sendReply("I'm stuck elsewhere."),
                        child: const Customstatustag(
                          message: "Stuck elsewhere",
                          borderColor: AppColors.darkRed,
                          backgroundColor: AppColors.lightRed,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap:
                            () =>
                                sendReply("My car is blocked by another car."),
                        child: const Customstatustag(
                          message: "Blocked by another car",
                          borderColor: AppColors.darkGreen,
                          backgroundColor: AppColors.lightGreen,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => sendReply("I'm on the way."),
                        child: const Customstatustag(
                          message: "On the way",
                          borderColor: AppColors.darkGreen,
                          backgroundColor: AppColors.lightGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
