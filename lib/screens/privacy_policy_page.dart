import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letmegoo/constants/app_theme.dart';

class PrivacyPolicyPage extends ConsumerStatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  ConsumerState<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends ConsumerState<PrivacyPolicyPage> {
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
          "Privacy Policy",
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
                            Icons.shield_outlined,
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
                                "Privacy Policy",
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
                                "Effective Date:20.07.2025",
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
                                "Last Updated: 20.07.2025",
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
                "1. Introduction",
                "Welcome to LetMeGoo, a utility application owned and operated by Richinnovations Technologies Pvt. Ltd. (\"we,\" \"us,\" or \"our\"). This Privacy Policy explains how we collect, use, protect, and handle your personal information when you use the LetMeGoo mobile application and related services (collectively, the \"Service\").\n\n"
                    "Company Details:\n"
                    "• Company Name: Richinnovations Technologies Pvt. Ltd.\n"
                    "• Registered Address: KSUM, Ground Floor, Tejaswini, Technopark, Trivandrum, Kerala PIN 695581\n"
                    "• Contact Email: sales@richinnovationsplc.com\n\n"
                    "By using LetMeGoo, you agree to the collection and use of information in accordance with this Privacy Policy.",
                screenWidth,
                isTablet,
                isLargeScreen,
              ),

              _buildSection(
                context,
                "2. Information We Collect",
                "2.1 Mandatory Information\n"
                    "When you register with LetMeGoo, we collect the following mandatory information:\n"
                    "• Personal Information: Full name, phone number, email address\n"
                    "• Vehicle Information: Vehicle registration number, vehicle type\n"
                    "• Account Information: Username, password (encrypted)\n\n"
                    "2.2 Optional Information\n"
                    "You may choose to provide additional information to enhance your experience:\n"
                    "• Vehicle Details: Fuel type, vehicle color, model, year\n"
                    "• Personal Information: Date of birth\n"
                    "• Location Data: Vehicle location when sending messages (only when actively using messaging feature)\n"
                    "• Communication Preferences: Privacy settings for name and phone number visibility",
                screenWidth,
                isTablet,
                isLargeScreen,
              ),

              _buildSection(
                context,
                "3. How We Use Your Information",
                "3.1 Primary Purposes\n"
                    "• Service Delivery: Facilitate communication between vehicle owners when parking assistance is needed\n"
                    "• Vehicle Identification: Match vehicle registration numbers with registered users\n"
                    "• Notification Services: Send alerts when someone needs to contact you about your vehicle\n"
                    "• Privacy Controls: Honor your privacy settings regarding name and phone number visibility\n\n"
                    "3.2 Secondary Purposes\n"
                    "• Service Improvement: Analyze usage patterns to enhance app functionality\n"
                    "• Customer Support: Respond to inquiries, technical issues, and user feedback\n"
                    "• Security: Detect and prevent fraudulent activity, spam, and misuse\n"
                    "• Legal Compliance: Comply with applicable laws and regulations",
                screenWidth,
                isTablet,
                isLargeScreen,
              ),

              _buildSection(
                context,
                "4. Information Sharing and Disclosure",
                "4.1 No Third-Party Sharing\n"
                    "We do not share your personal information with third parties for their marketing or commercial purposes. Your data remains within the LetMeGoo ecosystem.\n\n"
                    "4.2 Limited User-to-User Sharing\n"
                    "• Information is shared between users only as necessary for the parking assistance service\n"
                    "• Users control their privacy settings to determine what information is visible to others\n"
                    "• When privacy settings hide your name and phone number, other users only receive notifications without your personal details",
                screenWidth,
                isTablet,
                isLargeScreen,
              ),

              _buildSection(
                context,
                "5. Privacy Controls and User Rights",
                "5.1 Privacy Settings\n"
                    "• Name Visibility: Choose to hide or display your name to other users\n"
                    "• Phone Number Visibility: Control whether your phone number is visible to others\n"
                    "• Location Sharing: Control when and how your location is shared\n"
                    "• Communication Preferences: Manage notification settings and messaging preferences\n\n"
                    "5.2 Your Rights\n"
                    "• Access: Request a copy of your personal data\n"
                    "• Correction: Update or correct inaccurate information\n"
                    "• Deletion: Request deletion of your account and associated data\n"
                    "• Portability: Request your data in a machine-readable format",
                screenWidth,
                isTablet,
                isLargeScreen,
              ),

              _buildSection(
                context,
                "6. Data Security and Protection",
                "6.1 Security Measures\n"
                    "• Encryption: All sensitive data is encrypted in transit and at rest\n"
                    "• Access Controls: Strict employee access controls and authentication requirements\n"
                    "• Regular Audits: Periodic security assessments and vulnerability testing\n"
                    "• Secure Infrastructure: Industry-standard security protocols and monitoring\n\n"
                    "6.2 Data Retention\n"
                    "• Active Accounts: Data retained while your account remains active\n"
                    "• Deleted Accounts: Data permanently deleted within 30 working days of account deletion\n"
                    "• Legal Requirements: Some data may be retained longer if required by law",
                screenWidth,
                isTablet,
                isLargeScreen,
              ),

              _buildSection(
                context,
                "7. Children's Privacy",
                "LetMeGoo is not intended for use by children under 18 years of age. We do not knowingly collect personal information from children under 18. If we become aware that we have collected personal information from a child under 18, we will take steps to delete such information.",
                screenWidth,
                isTablet,
                isLargeScreen,
              ),

              _buildSection(
                context,
                "8. Data Breach Notification",
                "In the event of a data breach that may affect your personal information, we will:\n"
                    "• Notify affected users within 72 hours of discovering the breach\n"
                    "• Provide details about what information was involved\n"
                    "• Explain steps we are taking to address the breach\n"
                    "• Offer guidance on protecting yourself",
                screenWidth,
                isTablet,
                isLargeScreen,
              ),

              _buildSection(
                context,
                "9. Changes to This Privacy Policy",
                "We may update this Privacy Policy from time to time. When we make changes:\n"
                    "• We will post the updated policy in the app\n"
                    "• We will notify users of significant changes via email or app notification\n"
                    "• The \"Last Updated\" date will reflect when changes were made\n"
                    "• Continued use of the service constitutes acceptance of the updated policy",
                screenWidth,
                isTablet,
                isLargeScreen,
              ),

              _buildSection(
                context,
                "10. Contact Information",
                "For questions, concerns, or requests regarding this Privacy Policy or your personal information, please contact us:\n\n"
                    "Email: sales@richinnovationsplc.com\n"
                    "Address: Richinnovations Technologies Pvt. Ltd.\n"
                    "KSUM, Ground Floor, Tejaswini, Technopark\n"
                    "Trivandrum, Kerala PIN 695581, India\n\n"
                    "Response Time: We will respond to your inquiries within 7 business days.",
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
                      "By using LetMeGoo, you acknowledge that you have read, understood, and agree to be bound by this Privacy Policy.",
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
