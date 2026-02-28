/// Message template options for vehicle reports
///
/// Provides pre-defined message templates for common reporting scenarios.
/// Each option includes a display text (shown in UI) and a message template
/// where 'XXXX' is replaced with the actual vehicle number.
enum MessageOption {
  /// Vehicle is blocking a path or driveway
  blocking(
    'Blocking Path',
    'Your vehicle XXXX is blocking my way. Could you please move it? Thank you for your cooperation.',
  ),

  /// Vehicle is parked in an improper location
  improperParking(
    'Improper Parking',
    'Your vehicle XXXX appears to be parked improperly. Please check on it to avoid any issues. Thank you.',
  ),

  /// Vehicle is parked in someone else's designated slot
  parkedOnMySlot(
    'Parked in My Slot',
    'It looks like your vehicle XXXX is parked in my designated slot. Kindly move it at your earliest convenience. Thank you.',
  ),

  /// Vehicle headlights are left on
  headlightOn(
    'Headlight Is On',
    'Just a friendly heads-up, the headlights of your vehicle XXXX are still on. You might want to check it to save your battery. Thanks!',
  ),

  /// Vehicle key is left in the vehicle
  keyInVehicle(
    'Key in Vehicle',
    'I noticed the key for your vehicle XXXX has been left in it. Please retrieve it for security. Thank you.',
  ),

  /// Vehicle is not locked or has open door/window
  vehicleNotLocked(
    'Vehicle Not Locked',
    'It appears your vehicle XXXX may be unlocked or a door/window is not properly closed. Please check on it to ensure it is secure. Thank you.',
  ),

  /// Vehicle has sustained damage
  vehicleDamaged(
    'Vehicle Damaged',
    'I am writing to inform you that your vehicle XXXX has unfortunately sustained some damage. Please come and inspect it as soon as possible.',
  );

  const MessageOption(this.displayText, this.messageTemplate);

  /// User-friendly display text for the message option
  final String displayText;

  /// Template message with XXXX placeholder for vehicle number
  final String messageTemplate;

  /// Get the final message with vehicle number replaced
  ///
  /// [vehicleNumber] - The registration number to insert into template
  /// Returns the message with XXXX replaced by the actual vehicle number
  String getMessage(String vehicleNumber) {
    return messageTemplate.replaceAll('XXXX', vehicleNumber);
  }
}
