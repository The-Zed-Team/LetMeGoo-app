import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letmegoo/constants/app_theme.dart';

class TermsAndConditionsPage extends ConsumerStatefulWidget {
  const TermsAndConditionsPage({super.key});

  @override
  ConsumerState<TermsAndConditionsPage> createState() =>
      _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState
    extends ConsumerState<TermsAndConditionsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isLargeScreen = screenWidth > 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size:
                screenWidth *
                (isLargeScreen
                    ? 0.025
                    : isTablet
                    ? 0.035
                    : 0.06),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Terms and Conditions",
          style: AppFonts.bold20().copyWith(
            fontSize:
                screenWidth *
                (isLargeScreen
                    ? 0.022
                    : isTablet
                    ? 0.032
                    : 0.05),
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isLargeScreen ? 800 : double.infinity,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.02),

              // Header Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(screenWidth * 0.03),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.article_outlined,
                            color: AppColors.primary,
                            size:
                                screenWidth *
                                (isLargeScreen
                                    ? 0.03
                                    : isTablet
                                    ? 0.04
                                    : 0.06),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Terms and Conditions",
                                style: AppFonts.bold20().copyWith(
                                  fontSize:
                                      screenWidth *
                                      (isLargeScreen
                                          ? 0.02
                                          : isTablet
                                          ? 0.03
                                          : 0.045),
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Effective Date: 20.07.2025",
                                style: AppFonts.regular14().copyWith(
                                  fontSize:
                                      screenWidth *
                                      (isLargeScreen
                                          ? 0.014
                                          : isTablet
                                          ? 0.02
                                          : 0.032),
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                "Last Updated: 20.07.2025 | Version: 1.0",
                                style: AppFonts.regular14().copyWith(
                                  fontSize:
                                      screenWidth *
                                      (isLargeScreen
                                          ? 0.014
                                          : isTablet
                                          ? 0.02
                                          : 0.032),
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.025),

              // Content Sections
              _buildSection(
                context,
                "1. Introduction and Acceptance",
                "Welcome to LetMeGoo, a utility application operated by Richinnovations Technologies Pvt. Ltd. (\"Company,\" \"we,\" \"us,\" or \"our\"). These Terms and Conditions (\"Terms\") govern your use of the LetMeGoo mobile application and related services (collectively, the \"Service\").\n\n"
                    "Company Details:\n"
                    "• Company Name: Richinnovations Technologies Pvt. Ltd.\n"
                    "• Registered Address: KSUM, Ground Floor, Tejaswini, Technopark, Trivandrum, Kerala PIN 695581\n"
                    "• Contact Email: sales@richinnovationsplc.com\n\n"
                    "By downloading, installing, accessing, or using LetMeGoo, you agree to be legally bound by these Terms. If you do not agree to these Terms, you must not use the Service.",
                screenWidth,
                isTablet,
                isLargeScreen,
              ),

              _buildSection(
                context,
                "2. Service Description",
                "2.1 Purpose\n"
                    "LetMeGoo is a utility application designed to facilitate communication between vehicle owners when parking assistance is needed. The Service allows registered users to:\n"
                    "• Register their vehicles with contact information\n"
                    "• Search for registered vehicles by registration number\n"
                    "• Send notifications and messages to vehicle owners\n"
                    "• Request assistance for parking-related issues\n\n"
                    "2.2 Voluntary Registration\n"
                    "The Service is effective only when vehicle owners voluntarily register with LetMeGoo. We cannot facilitate communication with unregistered vehicle owners.\n\n"
                    "2.3 Service Philosophy\n"
                    "Our approach is based on the principle that \"something is better than nothing\" - while we cannot solve all parking-related issues, we aim to provide a helpful tool for the community of registered users.",
                screenWidth,
                isTablet,
                isLargeScreen,
              ),

              _buildSection(
                context,
                "3. Eligibility and Account Registration",
                "3.1 Age Requirement\n"
                    "You must be at least 18 years old to use the Service. By using LetMeGoo, you represent and warrant that you meet this age requirement.\n\n"
                    "3.2 Vehicle Ownership\n"
                    "You may only register vehicles that you own, lease, or have legal authority to operate. Registering vehicles without proper authority is prohibited.\n\n"
                    "3.3 Account Registration Requirements\n"
                    "To use the Service, you must provide:\n"
                    "• Mandatory Information: Full name, valid phone number, email address, vehicle registration number, vehicle type\n"
                    "• Optional Information: Fuel type, date of birth, additional vehicle details\n"
                    "• Accurate Information: All information must be current, complete, and accurate\n\n"
                    "3.4 Account Security\n"
                    "• You are responsible for maintaining the confidentiality of your account credentials\n"
                    "• You must notify us immediately of any unauthorized access to your account\n"
                    "• You are liable for all activities that occur under your account",
                screenWidth,
                isTablet,
                isLargeScreen,
              ),

              _buildSection(
                context,
                "4. User Responsibilities and Conduct",
                "4.1 Lawful Use\n"
                    "You agree to use the Service only for lawful purposes and in accordance with these Terms. You will not use the Service to:\n"
                    "• Violate any applicable laws or regulations\n"
                    "• Infringe upon the rights of others\n"
                    "• Harass, threaten, or intimidate other users\n"
                    "• Transmit harmful, offensive, or inappropriate content\n\n"
                    "4.2 Vehicle Information Accuracy\n"
                    "• You must provide accurate and current vehicle registration information\n"
                    "• You must update your information promptly when changes occur\n"
                    "• Providing false vehicle information may result in account termination\n\n"
                    "4.3 Respectful Communication\n"
                    "• All communications through the Service must be respectful and professional\n"
                    "• You may not use the Service to send spam, promotional content, or irrelevant messages\n"
                    "• Messages should be limited to parking-related assistance requests",
                screenWidth,
                isTablet,
                isLargeScreen,
              ),

              _buildSection(
                context,
                "5. Prohibited Activities",
                "You agree not to:\n"
                    "• Use the Service for any commercial purposes without authorization\n"
                    "• Attempt to gain unauthorized access to the Service or other users' accounts\n"
                    "• Reverse engineer, decompile, or disassemble the application\n"
                    "• Introduce viruses, malware, or other harmful code\n"
                    "• Create fake accounts or impersonate others\n"
                    "• Use automated systems or bots to access the Service\n"
                    "• Collect user data for unauthorized purposes\n"
                    "• Interfere with the proper functioning of the Service\n"
                    "• Abuse the notification system or send excessive messages\n"
                    "• Use the Service for commercial purposes without prior written consent",
                screenWidth,
                isTablet,
                isLargeScreen,
              ),

              _buildSection(
                context,
                "6. Intellectual Property Rights",
                "6.1 Company Ownership\n"
                    "LetMeGoo, including all content, features, functionality, software, text, images, graphics, logos, and trademarks, is owned by Richinnovations Technologies Pvt. Ltd. and is protected by Indian and international copyright, trademark, and other intellectual property laws.\n\n"
                    "6.2 Limited License\n"
                    "We grant you a limited, non-exclusive, non-transferable, revocable license to use the Service for personal, non-commercial purposes in accordance with these Terms.\n\n"
                    "6.3 Trademark Rights\n"
                    "\"LetMeGoo\" and associated logos are trademarks of Richinnovations Technologies Pvt. Ltd. You may not use these trademarks without our prior written consent.",
                screenWidth,
                isTablet,
                isLargeScreen,
              ),

              _buildSection(
                context,
                "7. Service Availability and Modifications",
                "7.1 Service Availability\n"
                    "• We strive to maintain continuous Service availability but do not guarantee uninterrupted access\n"
                    "• The Service may be temporarily unavailable due to maintenance, updates, or technical issues\n"
                    "• We are not liable for any inconvenience caused by Service unavailability\n\n"
                    "7.2 Service Modifications\n"
                    "• We reserve the right to modify, suspend, or discontinue the Service at any time\n"
                    "• We will provide reasonable notice of significant changes when possible\n"
                    "• Continued use of the Service after modifications constitutes acceptance of the changes\n\n"
                    "7.3 Updates and Upgrades\n"
                    "• We may release updates to improve functionality, security, or user experience\n"
                    "• Some updates may be mandatory for continued Service access",
                screenWidth,
                isTablet,
                isLargeScreen,
              ),

              _buildSection(
                context,
                "8. Disclaimer of Warranties",
                "8.1 \"As Is\" Service\n"
                    "THE SERVICE IS PROVIDED \"AS IS\" AND \"AS AVAILABLE\" WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.\n\n"
                    "8.2 No Service Guarantees\n"
                    "We do not warrant that:\n"
                    "• The Service will meet your specific requirements\n"
                    "• The Service will be uninterrupted, timely, secure, or error-free\n"
                    "• The results obtained from using the Service will be accurate or reliable\n"
                    "• Any defects in the Service will be corrected\n\n"
                    "8.3 Third-Party Content\n"
                    "We are not responsible for the accuracy, completeness, or reliability of any user-generated content or third-party information accessed through the Service.",
                screenWidth,
                isTablet,
                isLargeScreen,
              ),

              _buildSection(
                context,
                "9. Limitation of Liability",
                "9.1 Liability Limitation\n"
                    "TO THE MAXIMUM EXTENT PERMITTED BY LAW, RICHINNOVATIONS TECHNOLOGIES PVT. LTD. SHALL NOT BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES, INCLUDING BUT NOT LIMITED TO LOSS OF PROFITS, DATA, OR USE, ARISING OUT OF OR IN CONNECTION WITH YOUR USE OF THE SERVICE.\n\n"
                    "9.2 Maximum Liability\n"
                    "Our total liability to you for all claims arising out of or relating to the Service shall not exceed the amount you have paid us in the twelve (12) months preceding the claim, or INR 1,000, whichever is greater.\n\n"
                    "9.3 User Interactions\n"
                    "• We are not responsible for interactions between users\n"
                    "• Disputes between users must be resolved directly between the parties involved\n"
                    "• We may, but are not obligated to, mediate disputes or provide assistance",
                screenWidth,
                isTablet,
                isLargeScreen,
              ),

              _buildSection(
                context,
                "10. Account Termination",
                "10.1 Termination by User\n"
                    "• You may terminate your account at any time through the app settings\n"
                    "• Upon termination, your data will be deleted in accordance with our Privacy Policy\n"
                    "• You may create a new account after termination if desired\n\n"
                    "10.2 Termination by Company\n"
                    "We may suspend or terminate your account at any time if you:\n"
                    "• Violate these Terms or our Privacy Policy\n"
                    "• Engage in fraudulent or harmful activities\n"
                    "• Provide false information\n"
                    "• Misuse the Service or harass other users\n"
                    "• Fail to respond to our communications regarding account issues\n\n"
                    "10.3 Effect of Termination\n"
                    "Upon termination, your access to the Service will be immediately revoked and your data will be deleted according to our data retention policy.",
                screenWidth,
                isTablet,
                isLargeScreen,
              ),

              _buildSection(
                context,
                "11. Dispute Resolution",
                "11.1 Governing Law\n"
                    "These Terms are governed by and construed in accordance with the laws of India, without regard to conflict of law principles.\n\n"
                    "11.2 Jurisdiction\n"
                    "Any disputes arising out of or relating to these Terms or the Service shall be subject to the exclusive jurisdiction of the courts in Trivandrum, Kerala, India.\n\n"
                    "11.3 Informal Resolution\n"
                    "Before initiating formal legal proceedings, parties agree to attempt to resolve disputes through good faith negotiations.\n\n"
                    "11.4 Arbitration\n"
                    "If informal resolution fails, disputes may be submitted to binding arbitration under the Arbitration and Conciliation Act, 2015, in Trivandrum, Kerala.\n\n"
                    "11.5 Class Action Waiver\n"
                    "You agree that any dispute resolution proceedings will be conducted only on an individual basis and not in a class, consolidated, or representative action.",
                screenWidth,
                isTablet,
                isLargeScreen,
              ),

              _buildSection(
                context,
                "12. Special Provisions for Parking Utility Services",
                "12.1 No Emergency Service\n"
                    "LetMeGoo is not an emergency service. For emergencies, contact local authorities or emergency services directly.\n\n"
                    "12.2 Traffic and Parking Law Compliance\n"
                    "• Users must comply with all applicable traffic and parking laws\n"
                    "• The Service does not override legal parking restrictions\n"
                    "• Users are responsible for ensuring their parking is legal\n\n"
                    "12.3 Vehicle Safety\n"
                    "• Users are solely responsible for their vehicle's security\n"
                    "• The Service does not provide physical vehicle protection\n"
                    "• We recommend standard vehicle security measures\n\n"
                    "12.4 Community Guidelines\n"
                    "• Users should be courteous and patient\n"
                    "• Response to parking requests is voluntary\n"
                    "• Aggressive or threatening behavior is prohibited",
                screenWidth,
                isTablet,
                isLargeScreen,
              ),

              _buildSection(
                context,
                "13. Updates to Terms",
                "13.1 Modification Rights\n"
                    "We reserve the right to modify these Terms at any time. When we make changes:\n"
                    "• We will post the updated Terms in the app\n"
                    "• We will notify users of material changes via email or app notification\n"
                    "• The \"Last Updated\" date will reflect when changes were made\n\n"
                    "13.2 Acceptance of Changes\n"
                    "Continued use of the Service after Terms modification constitutes acceptance of the updated Terms.\n\n"
                    "13.3 Rejection of Changes\n"
                    "If you do not agree to modified Terms, you must stop using the Service and may terminate your account.",
                screenWidth,
                isTablet,
                isLargeScreen,
              ),

              _buildSection(
                context,
                "14. Contact Information",
                "For questions about these Terms or the Service, please contact us:\n\n"
                    "Email: sales@richinnovationsplc.com\n"
                    "Company: Richinnovations Technologies Pvt. Ltd.\n"
                    "Address: KSUM, Ground Floor, Tejaswini, Technopark, Trivandrum, Kerala PIN 695581, India\n\n"
                    "Response Time: We will respond to inquiries within 7 business days.",
                screenWidth,
                isTablet,
                isLargeScreen,
              ),

              // Acknowledgment Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.primary,
                          size:
                              screenWidth *
                              (isLargeScreen
                                  ? 0.025
                                  : isTablet
                                  ? 0.035
                                  : 0.05),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Text(
                          "Acknowledgment",
                          style: AppFonts.semiBold16().copyWith(
                            fontSize:
                                screenWidth *
                                (isLargeScreen
                                    ? 0.018
                                    : isTablet
                                    ? 0.028
                                    : 0.04),
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenWidth * 0.03),
                    Text(
                      "By using LetMeGoo, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions. This agreement is written in English. In case of any translation, the English version shall prevail.",
                      style: AppFonts.regular14().copyWith(
                        fontSize:
                            screenWidth *
                            (isLargeScreen
                                ? 0.015
                                : isTablet
                                ? 0.022
                                : 0.035),
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.04),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String content,
    double screenWidth,
    bool isTablet,
    bool isLargeScreen,
  ) {
    return Container(
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.02,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppFonts.semiBold18().copyWith(
              fontSize:
                  screenWidth *
                  (isLargeScreen
                      ? 0.018
                      : isTablet
                      ? 0.028
                      : 0.042),
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: screenWidth * 0.03),
          Text(
            content,
            style: AppFonts.regular14().copyWith(
              fontSize:
                  screenWidth *
                  (isLargeScreen
                      ? 0.015
                      : isTablet
                      ? 0.022
                      : 0.035),
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
